/* codgen.c       Generate Assembly Code for x86         15 May 13   */

/* Copyright (c) 2013 Gordon S. Novak Jr. and The University of Texas at Austin
    */

/* Starter file for CS 375 Code Generation assignment.           */
/* Written by Gordon S. Novak Jr.                  */

/* This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License (file gpl.text) for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "token.h"
#include "genasm.h"
#include "codegen.h"
#include "lexan.h"
#include "parse.h"
/* Set DEBUGGEN to 1 for debug printouts of code generation */
#define DEBUGGEN 0 

#define DB		        0		
#define DB_OPERATOR 	1 
#define DB_ARITH		2
#define DB_OPEN     	4
#define DB_GOTO		16

int nextlabel;    /* Next available label number */
int stkframesize;   /* total stack frame size */
/* Top-level entry for code generator.
   pcode    = pointer to code:  (program foo (output) (progn ...))
         */
int freeregs[16];
FILE *fout;
int DEBUGASM;

/*Entry point for code generator */
void gencode(TOKEN pcode, int maxlabel, int debug)
{ 
    DEBUGASM = debug;
    init();
    TOKEN name, code;
    nextlabel = maxlabel + 1;
    genc(pcode);
    //After we have generated all of the code, make sure we also generate a halt
    genhalt();

    //Test to make sure that we have freed all of registers
    int i = 11;
    for(i = 11; i < 16; i ++)
    {
        if(!freeregs[i])
        {
            printf("WARNING: there are unfreed registers\n");
        }
    }

    //make sure to close a.cms
    closefile();

}

void genc(TOKEN pcode)
{
    TOKEN code = pcode;
    if(!pcode)
        return;
    switch(code->tokentype)
    {
        case OPERATOR:
           genoperator(pcode);
           break;
        default:
           break;
    }
}

void genoperator(TOKEN code)
{
    int reg;
    int reg2;
    int lhsreg;
    TOKEN lhs;
    TOKEN rhs;
    TOKEN op;
    switch(code->whichval)
    {
        case STATEMENTOP - OPERATOR_BIAS:
            if(DEBUGGEN & DB_OPERATOR) printf("found a statement op\n");
            code = code->operands;
            //we found a statement list. gen all of the statements in it
            while(code)
            {
                genc(code);
                code = code->link;
            }
            break;
        case EQOP - OPERATOR_BIAS:
            if(DEBUGGEN & DB_OPERATOR)printf("found eq - %s\n", lhs->stringval);
            //generate the RHS, and put it into LHS.
            //gen lhs even though it is just a var. This will tell us which register to mov into
            lhs = code->operands;
            //RHS may be some arithmetic expression, so generate code for it
            rhs = lhs->link;
            switch(rhs->tokentype)
            {
                printf("inside rhs\n");
                //if RHS is just a number, we can just gen code for the mov now
                case NUMBERTOK:
                    //We we are moving into a var, supply that register number to movi
                    if(lhs->tokentype == IDENTIFIERTOK)
                    {
                       reg = atoi(lhs->stringval+3);
                    }
                    genimmediate(rhs->whichval, reg);
                    if(DEBUGGEN & DB_OPERATOR)
                        printf("generating immediate %d early\n", rhs->whichval);
                    return;
                default:
                    //if RHS is an operator, (var = 1+2) we have to gen the arithmatic (1+2)
                    //We want to gen directly into LHS, so get the reg number
                    lhsreg = atoi(lhs->stringval+3);
                    reg2 = genarith(rhs, lhsreg);
                    break;
            }
            //reg2 should be opened up forV later use. opening reg will do nothing since it is a var
            openreg(reg2);
            break;
        case ELIFOP - OPERATOR_BIAS:
        case IFOP - OPERATOR_BIAS:
            op = code->operands;
            lhs = op->operands;
            rhs = lhs->link;
            reg = genarith(lhs, -1);
            reg2 = genarith(rhs, -1);
            //This will flip the condition of the if, and generate and jlt instruction
            int iflabel = getlabel(); 
            genif(op, reg, reg2, iflabel); //This will say 'if not condition, jump'
            openreg(reg);
            openreg(reg2);
            TOKEN then = op->link;
            genc(then); //generate the 'then part' of the if
            int iflabel2 = getlabel();
            //gen the 'elif' or 'else' if there is one 
            TOKEN el = then->link;
            genjump(iflabel2);
            genlabel(iflabel);
            if(el)
                genc(el);
            genlabel(iflabel2);
            break;
        case ELSEOP - OPERATOR_BIAS:
            //If we are genearting an else, then we have already gen'd an if
            //the if that was already gen'd will jump to here if the condition is false
            //so we only need to gen the statement list right here
            lhs = code->operands;
            genc(lhs);
            break;
        case PRINTOP - OPERATOR_BIAS:
            op = code->operands;
            //We are either printing a variable, or a constant (number or string)
            int type = code->operands->tokentype;
            switch(type)
            {
                case RESERVED:
                    //We are going to use FFF to represent a newline character
                    op = code->operands;
                    int temp = 4095;
                    genprintc(temp);
                    break;
                case IDENTIFIERTOK:
                    op = code->operands;
                    //We have an identifer. Are we printing a variable or a string?
                    reg = genarith(op, -1);
                    genprint(reg);
                    openreg(reg);
                    break;
                case NUMBERTOK:
                    //We need to break each character into a different printtok
                    op = code->operands;
                    int num = op->whichval;
                    char str[16];
                    sprintf(str, "%d", num);
                    for(int i = 0; i < strlen(str); i++)
                    {
                        char *c = str+i;
                        int printval = str[i];
                        genprintc(printval);
                    }
                    break;

            }
            break;
        case LABELOP - OPERATOR_BIAS:
            op = code->operands;
            int label = op->whichval;
            genlabel(label);
            break;
        case GOTOOP - OPERATOR_BIAS:
            op = code->operands;
            int jmp = op->whichval;
            genjump(jmp);
            break;
        case HALTOP - OPERATOR_BIAS:
            genhalt();
            break;
    }
}

/*Generate some arithmetic expression into a register, and return the regitser */

int genarith(TOKEN code, int dest)
{
    TOKEN lhs;
    TOKEN rhs;

    int reg;
    int reg2;
    //This will either be an operator (+ - * /), an immediate, or a var
    switch(code->tokentype)
    {
        case IDENTIFIERTOK:
            //the string value is varX. Cut off the 'var' to get the register number
            reg = atoi(code->stringval+3);
            if(DEBUGGEN & DB_ARITH)
                printf("about to get the reg %d from the string %s\n",reg, code->stringval);
            return reg;
            break;
        case NUMBERTOK:
            if(DEBUGGEN & DB_ARITH)
                printf("genarith found a numbertok\n");
            //This is an immediate. Get an open register, and move this value into it
            reg = getreg();
            genimmediate(code->whichval, reg);
            return reg;
            break;
        case OPERATOR:
            if(DEBUGGEN & DB_ARITH)
                printf("genarith found an operator\n");
            //This is either a +, -, *, or /. Generate both LHS and RHS
            //then do the operation into dest 
            
            lhs = code->operands;
            rhs = lhs->link;
            reg = genarith(lhs, -1);
            reg2 = genarith(rhs, -1);

            //If we haven't already been given a destination to gen into, then we must grab one
            dest =  (dest >= 0) ? dest : getreg();
            genmath(code->whichval, reg, reg2, dest);
            openreg(reg);
            openreg(reg2);
            return dest;
    }
    return 0; 
}
void init()
{
    int i = 0;
    //The first 10 regs are always in use
    for(i = 0; i < 16; i++)
    {
        freeregs[i] = (i > 10);
    }
    
    //Open the a.cms file for genasm to write to
    openfile(DEBUGASM);
}

/*Used to get an open register to generate code into */
int getreg()
{
    int i = 0;
    for(i = 0; i < 16; i++)
    {
        if(freeregs[i])
        {
            freeregs[i] = 0;
            return i;
        }
    }
    return -1;
}

/*Make a register available for use again */
void openreg(int reg)
{
    if(reg > 10)
    {
        freeregs[reg] = 1;
        if(DEBUGGEN & DB_OPEN) 
            printf("freeing reg %d\n",reg);
    }
}

int getlabel()
{
    int ret = nextlabel;
    nextlabel = nextlabel + 1;
    return ret;
}

void genmove(int src, int dest)
{
    int reg = getreg();
    genimmediate(0, reg);
    genmath(PLUSOP - OPERATOR_BIAS, src, reg, dest);
    openreg(reg);
}
