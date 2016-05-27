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
#include "token.h"
#include "symtab.h"
#include "genasm.h"
#include "codegen.h"

void genc(TOKEN code);

/* Set DEBUGGEN to 1 for debug printouts of code generation */
#define DEBUGGEN 0

#define DB		0		
#define DB_LABEL 	1 
#define DB_IF		2
#define DB_PROGN	4
#define DB_FUNCALL	8
#define DB_GOTO		16

int nextlabel;    /* Next available label number */
int stkframesize;   /* total stack frame size */

int intreginuse[RMAX] = { 0 };
int floatreginuse[FMAX] = { 0 };
int labelmap[1001] = { 0 };
int jumpmap[12] = { 0 };
int intopmap[5] = { 0 };
int floatopmap[5] = { 0 };
/* Top-level entry for code generator.
   pcode    = pointer to code:  (program foo (output) (progn ...))
   varsize  = size of local storage in bytes
   maxlabel = maximum label number used so far

Add this line to the end of your main program:
    gencode(parseresult, blockoffs[blocknumber], labelnumber);
The generated code is printed out; use a text editor to extract it for
your .s file.
         */

/*Entry point for code generator */
void gencode(TOKEN pcode, int varsize, int maxlabel)
{  
    TOKEN name, code;
    name = pcode->operands;
    code = name->link->link;
    nextlabel = maxlabel + 1;
    stkframesize = asmentry(name->stringval,varsize);
    initmaps();
    genc(code);
    asmexit(name->stringval);
}

/* initialize maps to use for later */
void initmaps() 
{
    jumpmap[EQOP] = JE;
    jumpmap[NEOP] = JNE;
    jumpmap[LTOP] = JL;
    jumpmap[LEOP] = JLE;
    jumpmap[GTOP] = JG;
    jumpmap[GEOP] = JGE;

    intopmap[PLUSOP] = ADDL;
    intopmap[MINUSOP] = SUBL;
    intopmap[TIMESOP] = IMULL;
    intopmap[DIVIDEOP] = DIVL;

    floatopmap[PLUSOP] = ADDSD;
    floatopmap[MINUSOP] = SUBSD;
    floatopmap[TIMESOP] = MULSD;
    floatopmap[DIVIDEOP] = DIVSD; 
}

/* Given the operator and a register, generates an instruction */
int getoperatorinst(int operator, int reg)
{
    if(reg >= FBASE)
    {
	return floatopmap[operator];
    }
    else
    {
	return intopmap[operator];
    }
}

/* Get a label number to use */
int getlabel()
{
    int labelnum = nextlabel;
    nextlabel = nextlabel + 1; 
    return labelnum;
}

/* Request to use a specific label number */
int requestlabel(int requestednum)
{
    int num = getlabel();
    labelmap[requestednum] = num;
    return num;
}

/* Trivial version: always returns RBASE + 0 */
/* Get a register.   */
/* Need a type parameter or two versions for INTEGER or REAL */
int getreg(int kind)
{
    if(kind != FLOAT) {
	return getintreg();
    }
    else
	return getfloatreg();
}

/* Gets an integer register to use for an instruction */
int getintreg()
{
    int i = 0;
    for(i = RBASE; i <= RMAX; i++)
    {
	if(!intreginuse[i]) {
	    intreginuse[i] = 1;
	    return i;
	}
    }
    return -1;
}

/* Gets a real register to be used for an instruction */
int getfloatreg()
{
    int i = 0;
    for(i = FBASE; i <= FMAX; i++)
    {
	if(!floatreginuse[i]) {
	    floatreginuse[i] = 1;
	    return i;
	}
    }
    return -1;
}

/* Decides whether it should free an integer or float register */
void freereg(int reg)
{
    if(reg >= FBASE) 
	freefloatreg(reg);
    else
	freeintreg(reg);
}

/* frees an integer register to be used again in another instruction */
void freeintreg(int reg)
{
    intreginuse[reg] = 0;
}

/* Frees a float register to be used again in another instruction */
void freefloatreg(int reg)
{
    floatreginuse[reg] = 0;
}

/* given a register, tells if its in use */
int reginuse(int reg)
{
    if(reg >= FBASE)
    {
	return floatreginuse[reg];
    }
    return intreginuse[reg];
}

/* given a register, will return whether it is an INTEGER reg, or a FLOAT reg */
int getregtype(int reg)
{
    if(reg >= FBASE) return FLOAT;
    return INTEGER;
}

/* Stores a register to temporary stack */
void storetotemp(int reg)
{
    asmsttemp(reg);
    freereg(reg);
}

/* Given a TOKEN it will return the correct instruction to move the data */
int getmoveinst(TOKEN code)
{

    SYMBOL sym = searchst(code->stringval);
    int inst = MOVL;
    if(code->datatype == REAL )
    {
	inst = MOVSD;
    }
    //if this var is a pointer, use MOVQ
    if(sym != NULL && sym->datatype != NULL && sym->datatype->datatype != NULL && sym->datatype->datatype->kind == POINTERSYM)
    {
	inst = MOVQ;
    }
    else if(sym != NULL)
    {
	//if this var is a float, use MOVSD
	while(sym->datatype != NULL) sym = sym->datatype;
	if(strcmp(sym->namestring, "real") == 0) inst = MOVSD;
    }

    return inst;
}

/* Given a TOKEN it will return the correct instruction to cmp the data */
int getcmpinst(TOKEN code)
{

    SYMBOL sym = searchst(code->stringval);
    int inst = CMPL;
    //if this var is a pointer, use MOVQ
    if(sym != NULL && sym->datatype != NULL && sym->datatype->datatype != NULL && sym->datatype->datatype->kind == POINTERSYM)
    {
	inst = CMPQ;
    }
    else if(sym != NULL)
    {
	//if this var is a float, use MOVSD
	while(sym->datatype != NULL) sym = sym->datatype;
	if(strcmp(sym->namestring, "real") == 0) inst = CMPSD;
    }

    return inst;
}

/* generates asm for a pointer refence of the form John^.field = C */
/* parameter reg is the register that contains data of C */
/* inst will either be MOVL or MOVQ */
/* return the register the data is put into */
int genpoint(TOKEN point, int inst, int reg)
{
    TOKEN lhs = point->operands;
    int lhsreg, off;

    lhsreg = genarith(lhs);
    off = point->link->intval;
    //generate the reference
    asmstr(inst, reg, off, lhsreg, "^. ");
    return lhsreg;

}

/* has almost the same funcitonality as genarith, but caller supplies a reg to gen into */
void genintoreg(TOKEN code, int reg)
{
    printf("looking at %s\n", code->stringval);
    dbugprinttok(code);
    TOKEN lhs, rhs;
    SYMBOL sym;
    int offs = 0, reg2 = 0, inst = 0, num = 0;
    inst = (reg >= FBASE) ? MOVSD : MOVL;
    switch(code->tokentype)
    {
	case OPERATOR:
	    lhs = code->operands;
	    rhs = lhs->link;
	    switch(lhs->whichval)
	    {
		case POINTEROP:
		    offs = rhs->intval;
		    reg2 = genarith(lhs->operands);

		    //gnerate the instruction
		    asmldr(inst, offs, reg2, reg, "^. ");
		    freereg(reg2);

		break;
	    }
	break;
	case NUMBERTOK:
            switch (code->datatype)
            {
                case INTEGER:
                    num = code->intval;
                    if ( num >= MINIMMEDIATE && num <= MAXIMMEDIATE )
                    asmimmed(inst, num, reg);
                break;
                case REAL:
		    num = getlabel();
		    //create a label to represent the float, then move it to a reg
		    makeflit(code->realval, num);
		    asmldflit(inst, num, reg);
                break;
            }
	break;
	case IDENTIFIERTOK:
	    sym = searchst(code->stringval);
	    if(!sym) printf("genintoreg - FOUND THE PROMBLE\n");
            offs = sym->offset - stkframesize; /* net offset of the var   */


	    asmld(inst, offs, reg, code->stringval);
	break;
	default:
	    printf("got here");
	break; 
    }
}


/* Trivial version */
/* Generate code for arithmetic expression, return a register number */
int genarith(TOKEN code)
{
    int num, reg, reg2, offs, inst;
    SYMBOL sym;
    
    //TOKENs needed for case OPERATOR
    TOKEN lhs, rhs, funcname, param;
    if (DEBUGGEN)
    {
        printf("genarith\n");
        dbugprinttok(code);
    }
    switch ( code->tokentype )
    {
        case NUMBERTOK:
	    reg = (code->datatype == REAL) ? getreg(FLOAT) : getreg(INTEGER);
	    genintoreg(code, reg);
        break;
        case IDENTIFIERTOK:
	    reg = (code->datatype == REAL) ? getreg(FLOAT) : getreg(INTEGER);
	    genintoreg(code, reg);
        break;
        case OPERATOR:
	    switch(code->whichval)
	    {
		case FLOATOP:
		    lhs = code->operands;
		    reg = getreg(FLOAT);
		    reg2 = genarith(lhs);
		    asmfloat(reg2,reg);
		    freereg(reg2);
		break;
		case FUNCALLOP:
		    funcname = code->operands;
		    param = funcname->link;


		    
		    //Since we are about to call a function, the param needs to be in xmm0
		    if(floatreginuse[XMM0])
		    {
			storetotemp(XMM0);
		        reg = genarith(param);
			reg2 = getreg(FLOAT);
		        if(strcmp(funcname->stringval, "new") == 0)
		        {
			    asmrr(MOVL, reg, EDI);
		        }
		        asmcall(funcname->stringval);
			asmldtemp(reg2);
			freereg(reg);
			reg = reg2;

		    }
		    else
		    {
		        reg = genarith(param);

		        if(strcmp(funcname->stringval, "new") == 0)
		        {
		    	    asmrr(MOVL, reg, EDI);
		        }

		        asmcall(funcname->stringval);
		    }
		    
		break;
		case AREFOP:
		    lhs = code->operands;
		    switch(lhs->datatype)
		    {
			case OPERATOR:
			    //Since we are here, this must be a pointer referemce
			    rhs = lhs->link;
			    lhs = lhs->operands;
			    offs = rhs->intval;
			    reg2 = genarith(lhs);

			    //generate the instruction
			    TOKEN temp = lhs;
			    while(temp->operands != NULL) temp = temp->operands;
			    
			    //If this pointer is a float type, we have to gen into an xmm reg
			    sym = searchst(temp->stringval);
			    while(sym && sym->datatype != NULL && sym->kind != RECORDSYM)
			    {
				sym = sym->datatype;
			    }
			    //We have found the recordsym, now index into it by the offset to get the basicdt
			    int currsize = 0;
			    sym = sym->datatype;
			    while(currsize < offs)
			    {
				sym = sym->link;
				currsize += sym->size;
			    }
			    //Now that we have the right field of the array, get its datatype
			    while(sym->datatype != NULL) sym = sym->datatype;
			    
			    if(strcmp(sym->namestring,"real") == 0) 
			    {
				inst = MOVSD;
			        reg = getreg(FLOAT);
			    }
			    else
			    {
				inst = MOVQ;
			        reg = getreg(INTEGER);
			    }

			    asmldr(inst, offs, reg2, reg, "^. ");
			    freereg(reg2);
			break;
			case IDENTIFIERTOK:

			    //Since we are here, this must an array reference
			    rhs = lhs->link;
			    //Find out our type, and then gen RHS into that type of register
			    sym = searchst(lhs->stringval);
			    while(sym->datatype != NULL) sym = sym->datatype;
			    int tempint = (strcmp(sym->namestring, "real") == 0) ? FLOAT : INTEGER;
			    //Get a register that matches our datatype
			    //reg2 = genarith(rhs);

			    inst = tempint == FLOAT ? MOVSD : MOVL;
			    SYMBOL sym = searchst(lhs->stringval);
			    //offs=rhs->intval;
              		    offs = sym->offset - stkframesize;
			    reg2 = genarith(rhs);
			    reg = getreg(tempint);

			    //If we aren't using MOVL, we need to sign extend 
			    if(inst != MOVL)
			    {
			        asmop(CLTQ);
			    }

			    asmldrr(inst, offs, reg2, reg, lhs->stringval);
			    freereg(reg2);
			break;
		    }
		break;
		default:
		    //There is a chance we are working with a minusOP that is being used to negate rather than subract
		    if(code->whichval == MINUSOP && code->operands->link == NULL)
		    {
			lhs = code->operands;
			reg = genarith(lhs);
			//put 0 into a register, and use it to negate
			reg2 = getreg(FLOAT);
			asmfneg(reg, reg2);
			freereg(reg2);
		    }
		    else //We are either a subtraction (not a negation) or another math operation (+, *, /, ...)
		    {
                        lhs = code->operands;
                        rhs = lhs->link;
                        reg = genarith(lhs);
                        reg2 = genarith(rhs);

                        //if one reg is int, and the other is float, then fix the float
                        if(getregtype(reg) != getregtype(reg2))
                        {
                            if(getregtype(reg) == FLOAT)
                            {
                                int temp = reg;
                                freereg(reg);
                                reg = getreg(INTEGER);
                                asmfix(temp, reg);
                            }
                            else
                            {
                                int temp = reg2;
                                freereg(reg2);
                                reg2 = getreg(INTEGER);
                                asmfix(temp, reg2);
                            }
                        }
                        asmrr(getoperatorinst(code->whichval, reg2), reg2, reg);
                        freereg(reg2);
		    }
		break;
	    }
        break;
    }
    return reg;
}

/* Generate code for a Statement from an intermediate-code form */
void genc(TOKEN code)
{

    TOKEN tok, lhs, rhs, comp, thentok, elsetok;
    //tokens needed to gen funcalls
    TOKEN funcname, param, temptok;
    int reg, reg2, labelnum, labelnum2, offs, inst, tempint;
    SYMBOL sym;

    if ( code->tokentype != OPERATOR )
    {
        printf("Bad code token");
        dbugprinttok(code);
    }
    switch ( code->whichval )
    {
        case PROGNOP:
            tok = code->operands;
            while ( tok != NULL )
            {
		if(DB & DB_PROGN)
		{
		    printf("found progn: \n");
		    dbugprinttok(tok);
		}
                genc(tok);
                tok = tok->link;
            }
        break;
        case ASSIGNOP:

	    lhs = code->operands;
	    switch(lhs->tokentype) 
	    {
		case OPERATOR:
		    switch(lhs->whichval)
		    {
			case AREFOP:
			    //dbugprinttok(lhs); //AREF
			    //dbugprinttok(lhs->operands); // ^
			    //dbugprinttok(lhs->operands->link); // 32
			    //dbugprinttok(lhs->operands->operands);// John
			    rhs = lhs->link;
			    lhs = lhs->operands;
			    switch(lhs->tokentype)
			    {
				case OPERATOR:
			    	    reg2 = genarith(rhs);

				    //decide whether this should be MOVL or MOVQ - MOVQ is rhs is a pointer
				    inst = getmoveinst(rhs);
				    reg = genpoint(lhs, inst, reg2);
				    freereg(reg2);
				break;
				case IDENTIFIERTOK:
				    //We are an array reference
				    //Find out our type, and then gen RHS into that type of register
				    sym = searchst(lhs->stringval);
				    while(sym->datatype != NULL) sym = sym->datatype;
				    int tempint = (strcmp(sym->namestring, "real") == 0) ? FLOAT : INTEGER;
				    //Get a register that matches our datatype
				    reg2 = getreg(tempint);
				    genintoreg(rhs, reg2);
				    inst = getmoveinst(lhs);
				    SYMBOL sym = searchst(lhs->stringval);
                    		    offs = sym->offset - stkframesize;
				    reg = genarith(lhs->link);
				    
				    //If we aren't using MOVL, we need to sign extend
				    if(inst != MOVL) 
				    {
				        asmop(CLTQ);
				    }

				    asmstrr(inst, reg2, offs, reg, lhs->stringval);
				    freereg(reg2);
				break;
			    }
			    freereg(reg);
			break;
		    }
		break;
		default:
                    //if lhs is an aref, we must genarith it
                    rhs = lhs->link;
                    /* generate rhs into a register */
                    reg = genarith(rhs);

                     /* assumes lhs is a simple var  */
                    sym = searchst(lhs->stringval);
                    if(!sym) printf("ASSIGN - FOUND THE PROMBLE: %s\n", lhs->stringval);

                    /* net offset of the var   */
                    offs = sym->offset - stkframesize;

                    /* store value into lhs  */
                    switch (code->operands->datatype)
                    {
                        case INTEGER:
			    inst = getmoveinst(lhs);
                            asmst(inst, reg, offs, lhs->stringval);
                            freereg(reg);
                        break;
                        case REAL:
                            asmst(MOVSD, reg, offs, lhs->stringval);
                            freereg(reg);
                        break;
                        default:
                            printf("in default: %d\n", code->operands->datatype);
                            freereg(reg);
                        break;

                        /* Free the register we used to temporarily store data into */
                    }
		break;
		//about to set up this switch
		//lhs is either an operator, or a var	
	    }

        break;
	case LABELOP:
	    if(DB & DB_LABEL)
	    {
		printf("found label\n");
		dbugprinttok(code);
		dbugprinttok(code->operands);
		dbugprinttok(code->link);
	    }
	    int num = requestlabel(code->operands->intval);
	    asmlabel(num);
	break;
	case IFOP:
	    comp = code->operands;
	    thentok = comp->link;
	    elsetok = thentok->link;
	    lhs = comp->operands;
	    rhs = lhs->link;
	    if(DB & DB_IF)
	    {
		printf("found if\n");
		dbugprinttok(comp);
	    }

	    //Gen code for loading the left and right hand sides 
	    reg = genarith(lhs);
	    reg2 = genarith(rhs);
	    //compare the two registers, and jump depending on the result
	    inst = jumpmap[comp->intval];


	    asmrr(getcmpinst(lhs), reg2, reg);
	    labelnum = getlabel();
	    asmjump(inst, labelnum);
	    labelnum2 = getlabel();

	    //Gen the 'else' if there is one
	    if(elsetok) genc(elsetok);
	    asmjump(JMP, labelnum2);

	    //TODO not sure if freeing here is completely safe	
 	    freereg(reg);
	    freereg(reg2);

	    //Generate the lables and code for the 'then' and the 'else'
	    asmlabel(labelnum);
	    genc(thentok);
	    asmlabel(labelnum2); //After this label is where the code after the 'then' and 'else' blocks with be generated

	break;
	case FUNCALLOP:
	    funcname = code->operands;
	    param = funcname->link;
	    if(DB & DB_FUNCALL)
	    {
		printf("in funcall\n");
		dbugprinttok(code); //funcall
		dbugprinttok(funcname); //writeline
		dbugprinttok(param); //*
		printf("here:%d\n", param->tokentype);
	    }
	    //We must move our parameter somewhere. If string, EDI, else getreg()
	    if(param->tokentype == STRINGTOK)
	    {
		reg = EDI;
		labelnum = getlabel();
		makeblit(param->stringval, labelnum);
		asmlitarg(labelnum, reg);
	    	asmcall(funcname->stringval);
	    }
	    else
	    {
		reg = genarith(param);

		//Apend either an i or an f to the end of the function call
		char funcend = reg >= FBASE ? 'f' : 'i';
		char* func = funcname->stringval;
		size_t len = strlen(func);
		func[len++] = funcend;
		func[len] = '\0';

		if(reg < FBASE) asmrr(MOVL, reg, EDI);
		//because we are about to call a function, we need the param to be in either eax or xmm0
		int desiredreg = (reg >= FBASE) ? FBASE : reg;
		if(desiredreg != reg)
		{
		    //we dont have the desired reg, so we must get it
		    storetotemp(desiredreg);
		    inst = (desiredreg == FBASE) ? MOVSD : MOVL;
		    asmrr(inst,reg,desiredreg);
		    asmcall(func);
		    asmldtemp(desiredreg);
		    
		}
		else
		{
		    asmcall(func);
		}

		freereg(reg);	
	    }
	    freereg(reg);
	break;
	case GOTOOP:
	    labelnum = code->operands->intval;
	    asmjump(JMP, labelmap[labelnum]);
	    if(DB & DB_GOTO) printf("found goto\n");
	break;
	case AREFOP:
	    printf("Found arefop\n");
	break;
    }
}
