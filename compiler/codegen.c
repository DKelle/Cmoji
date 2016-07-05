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

/* Set DEBUGGEN to 1 for debug printouts of code generation */
#define DEBUGGEN 0

#define DB		        0		
#define DB_OPERATOR 	1 
#define DB_ARITH		2
#define DB_OPEN     	4
#define DB_FUNCALL	8
#define DB_GOTO		16

int nextlabel;    /* Next available label number */
int stkframesize;   /* total stack frame size */
/* Top-level entry for code generator.
   pcode    = pointer to code:  (program foo (output) (progn ...))
         */
int freeregs[16];

/*Entry point for code generator */
void gencode(TOKEN pcode)
{  
    init();
    TOKEN name, code;
    genc(pcode);
}

void genc(TOKEN pcode)
{
    TOKEN code = pcode;
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
    TOKEN lhs;
    TOKEN rhs;
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
            if(DEBUGGEN & DB_OPERATOR)printf("found eq\n");
            //generate the RHS, and put it into LHS.
            //gen lhs even though it is just a var. This will tell us which register to mov into
            lhs = code->operands;
            reg = genarith(lhs);
            //RHS may be some arithmetic expression, so generate code for it
            rhs = lhs->link;
            switch(rhs->tokentype)
            {
                //if RHS is just a number, we can just gen code for the mov now
                case NUMBERTOK:
                    genimmediate(rhs->whichval, reg);
                    if(DEBUGGEN & DB_OPERATOR)
                        printf("generating immediate %d early\n", rhs->whichval);
                    return;
                default:
                    reg2 = genarith(rhs);
                    break;
            }
            //The value of RHS is in reg2. Move reg2 to reg
            genmov(reg2, reg);
            //reg2 should be opened up for later use. opening reg will do nothing since it is a var
            openreg(reg2);
            openreg(reg);
            break;
    }
}

/*Generate some arithmetic expression into a register, and return the regitser */

int genarith(TOKEN code)
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
            //then do the operation into reg1
            lhs = code->operands;
            rhs = lhs->link;
            reg = genarith(lhs);
            reg2 = genarith(rhs);
            //Generate this inst into reg. reg2 should now be open for later use
            genmath(code->whichval, reg, reg2, reg);
            openreg(reg2);
            return reg;
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
