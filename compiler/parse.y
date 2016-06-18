%{     /* pars1.y    Pascal Parser      Gordon S. Novak Jr.  ; 30 Jul 13   */

/* Copyright (c) 2013 Gordon S. Novak Jr. and
   The University of Texas at Austin. */

/* 14 Feb 01; 01 Oct 04; 02 Mar 07; 27 Feb 08; 24 Jul 09; 02 Aug 12 */

/*
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program; if not, see <http://www.gnu.org/licenses/>.
  */


/* NOTE:   Copy your lexan.l lexical analyzer to this directory.      */

       /* To use:
                     make pars1y              has 1 shift/reduce conflict
                     pars1y                   execute the parser
                     i:=j .
                     ^D                       control-D to end input

                     pars1y                   execute the parser
                     begin i:=j; if i+j then x:=a+b*c else x:=a*b+c; k:=i end.
                     ^D

                     pars1y                   execute the parser
                     if x+y then if y+z then i:=j else k:=2.
                     ^D

           You may copy pars1.y to be parse.y and extend it for your
           assignment.  Then use   make parser   as above.
        */

        /* Yacc reports 1 shift/reduce conflict, due to the ELSE part of
           the IF statement, but Yacc's default resolves it in the right way.*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "token.h"
#include "lexan.h"
#include "parse.h"

        /* define the type of the Yacc stack element to be TOKEN */

#define YYSTYPE TOKEN

TOKEN parseresult;

%}

/* Order of tokens corresponds to tokendefs.c; do not change */

%token OPERATOR DELIMETER RESERVED IDENTIFIERTOK NUMBERTOK  /* token types */

%token PLUSOP MINUSOP TIMESOP DIVIDEOP                      /* operators */
%token EQOP LTOP LEOP GEOP GTOP IFOP NEOP ANDOP OROP NOTOP

%token LPAREN RPAREN                                        /* Delimiters */

%token LOOP LOOP1 TO PRINT SILENCE FUNCALL                  /* Resereved */
%token DEF IF ELIF ELSE RET SLEEP FUNCTION HALT

%%
program : statement_list HALT				
        | PRINT			{parseresult = $1;}
        |			{parseresult = makenumbertok(4);}
		;

statement_list  : statement statement_list
                | statement
                ;

statement   : declaration
            | if
            | assignment
            | funcall
            | loop
            ;

declaration : DEF var
            | DEF assignment
            ;

if          : IF expression LPAREN statement_list RPAREN
            | IF expression LPAREN statement_list RPAREN elif
            ;

assignment  : var EQOP expression
            ;

funcall     : FUNCALL IDENTIFIERTOK 
            ;

loop        : LOOP expression LPAREN statement_list RPAREN
            | LOOP range LPAREN statement_list RPAREN
            | LOOP1 LPAREN statement_list RPAREN
            ;

var         : IDENTIFIERTOK
            ;

expression  : expression compare_op simple_expression
            | simple_expression
            ;

elif        : ELIF expression LPAREN statement_list RPAREN
            | ELIF expression LPAREN statement_list RPAREN else
            ;

range       : number TO number
            ;

compare_op  : EQOP | LTOP | LEOP | GTOP | GEOP
            ;

simple_expression   : term
                    | simple_expression add_op term
                    ;

else    : ELSE LPAREN statement_list RPAREN
        ;

number  : var
        | NUMBERTOK

term    : term times_op factor
        | factor
        ;

add_op  : PLUSOP | MINUSOP | OROP
        ;

times_op    : TIMESOP | DIVIDEOP | ANDOP
            ;

factor  : NUMBERTOK
        | var
        | LPAREN expression RPAREN
        ;


%%

/* You should add your own debugging flags below, and add debugging
   printouts to your programs.

   You will want to change DEBUG to turn off printouts once things
   are working.
  */

#define DEBUG           0 	/* set bits here for debugging, 0 = off  */

#define DB_CONS       	1		/* bit to trace cons */
#define DB_BINOP      	2		/* bit to trace binop */
#define DB_MAKEIF     	4		/* bit to trace makeif */
#define DB_MAKEPROGN  	8		/* bit to trace makeprogn */
#define DB_PARSERES   	16		/* bit to trace parseresult */
#define DB_MAKEPROGRAM  32
#define DB_MAKELABEL 	64
#define DB_MAKEFOR	128	
#define DB_MAKEFUNCALL  256 
#define DB_INSTCONST	512
#define DB_MAKECONST	1024
#define DB_INSTTYPE	2048
#define DB_FINDTYPE	4096
#define DB_INSTREC	8192
int labelnumber = 0;  /* sequential counter for internal label numbers */
int labels[10000]; //use this so we can mape user defined label number -> internal label numbering
   /*  Note: you should add to the above values and insert debugging
       printouts in your routines similar to those that are shown here.     */

TOKEN cons(TOKEN item, TOKEN list)           /* add item to front of list */
{
    item->link = list;
    if (DEBUG & DB_CONS)
    { 
	printf("cons\n");
        dbugprinttok(item);
        dbugprinttok(list);
    };
    return item;
}

TOKEN printsomething(TOKEN prgm)
{
	printf("got to here\n");
    return prgm;
}

TOKEN binop(TOKEN op, TOKEN lhs, TOKEN rhs)        /* reduce binary operator */
{

    op->operands = lhs;          /* link operands to operator       */
    lhs->link = rhs;             /* link second operand to first    */
    rhs->link = NULL;            /* terminate operand list          */
    if (DEBUG & DB_BINOP)
    { 
	printf("binop\n");
        dbugprinttok(op);
        dbugprinttok(lhs);
        dbugprinttok(rhs);
    };
    return op;
}

TOKEN makeif(TOKEN tok, TOKEN exp, TOKEN thenpart, TOKEN elsepart)
{  
    tok->tokentype = OPERATOR;  /* Make it look like an operator   */
    tok->whichval = IFOP;
    if (elsepart != NULL) elsepart->link = NULL;
    thenpart->link = elsepart;
    exp->link = thenpart;
    tok->operands = exp;
    if (DEBUG & DB_MAKEIF)
    { 
	printf("makeif\n");
        dbugprinttok(tok);
        dbugprinttok(exp);
        dbugprinttok(thenpart);
        dbugprinttok(elsepart);
    };
    return tok;
}


/* makewhile makes structures for a while statement.                
   tok and tokb are (now) unused tokens that are recycled.        
TOKEN makewhile(TOKEN tok, TOKEN expr, TOKEN tokb, TOKEN statement)
{
    //create the label and goto that we will jump back to
    TOKEN label = makelabel();
    TOKEN gototok = makegoto(label->operands->intval);
   
    //put the goto at the end of the statementlist
    TOKEN temp = statement->operands; 
    while(temp->link != NULL)         
    {                                 
        temp = temp->link;            
    }                                 
    temp->link = gototok;        
    //Use the condition we just made to create the iftok   
    TOKEN iftok = makeif(tokb, expr, statement, NULL);

    label->link = iftok;

    temp = copytok(tok);
    TOKEN prog = makeprogn(temp, label);

    return prog;
    
}*/

/* makefor makes structures for a for statement.
   sign is 1 for normal loop, -1 for downto.
   asg is an assignment statement, e.g. (:= i 1)
   endexpr is the end expression
   tok, tokb and tokc are (now) unused tokens that are recycled. 
TOKEN makefor(int sign, TOKEN tok, TOKEN asg, TOKEN tokb, TOKEN endexpr, TOKEN tokc, TOKEN statement)
{
    TOKEN labeltok = makelabel();
    asg->link = labeltok;

    //Make a copy of the indentifier used in the asg
    TOKEN idtok = copytok(asg->operands);
    //create an operator token that uses LTE as the operator
    TOKEN optok = makeoperatortok(LEOP);
    //Use the two tokens we made (and the endexpr) to create the conditiontok
    TOKEN condition = binop(optok, idtok, endexpr);

    statement = makeprogn(talloc(), statement);
    //Use the condition we just made to create the iftok
    TOKEN iftok = makeif(tokb, condition, statement, NULL);
    //This iftok should be the labels link
    labeltok->link = iftok;

    //Make the i+1/i-1 node
    int incop = (sign == 1) ? PLUSOP : MINUSOP;
    TOKEN exprtok = binop(makeoperatortok(incop), copytok(idtok), makenumbertok(1));
    //Make the i = (incop) node
    TOKEN incrementtok = binop(makeoperatortok(ASSIGNOP), copytok(idtok), exprtok);


    //Make the increment happen after the statemtn has executed by finding the statements last link
    TOKEN temp = statement->operands;
    while(temp->link != NULL)
    {
    	temp = temp->link;
    }
    temp->link = incrementtok;

    //Make the goto node, so we continuously do *statemnt*
    TOKEN gototok = makegoto(labeltok->operands->intval);
    //Make sure the goto executes after the increment/decrement
    incrementtok->link = gototok;

    if(DEBUG & DB_MAKEFOR)
    {
	printf("makefor\n");
	dbugprinttok(tok);
	dbugprinttok(asg);
	dbugprinttok(endexpr);
	dbugprinttok(statement);
    }

    return asg;
}
*/

/* makefuncall makes a FUNCALL operator and links it to the fn and args.
   tok is a (now) unused token that is recycled.
//TODO: size isn't quite right for new
TOKEN makefuncall(TOKEN tok, TOKEN fn, TOKEN args)
{

    tok->tokentype = OPERATOR;
    tok->whichval = FUNCALLOP;

    if(strcmp(fn->stringval, "new") == 0)
    {
	TOKEN ret = makeoperatortok(ASSIGNOP);
	SYMBOL obj = searchst(args->stringval);
	fn->link = makenumbertok(obj->datatype->datatype->datatype->size);
	tok->operands = fn;
	args->link = tok;
	ret->operands = args;

	return ret;
    }
    else
    {
        fn->link = args;
        tok->operands = fn;
    }

    if(DEBUG & DB_MAKEFUNCALL)
    {
	printf("makefor\n");
	dbugprinttok(tok);
	dbugprinttok(fn);
	dbugprinttok(args);
    }

    return tok;
}*/

/* dogoto is the action for a goto statement.      
   tok is a (now) unused token that is recycled. */
TOKEN dogoto(TOKEN tok, TOKEN labeltok)
{
    int num = labels[labeltok->intval];
    TOKEN numbertok = makenumbertok(num);
    TOKEN gototok = makeoperatortok(GOTOOP);
    gototok->operands = numbertok; 
    return gototok;
}

/* dolabel is the action for a label of the form   <number>: <statement>
   tok is a (now) unused token that is recycled. */                     
TOKEN dolabel(TOKEN labeltok, TOKEN tok, TOKEN statement)
{
    int usernum = labeltok->intval;
    tok = copytok(tok);
    tok->tokentype = OPERATOR;
    tok->whichval = LABELOP;
    tok->link = statement;
    //Make sure that this actually instals the operands
    instlabel(tok);
    labels[usernum] = tok->operands->intval;

    if (DEBUG & DB_MAKELABEL)
    { 
	printf("makelabel\n");
	dbugprinttok(tok);
    };
    return tok;
}

TOKEN makelabel()
{
    TOKEN tok = talloc();
    tok->tokentype = OPERATOR;
    tok->whichval = LABELOP;

    //Make sure that this actually instals the operands
    instlabel(tok);

    if (DEBUG & DB_MAKELABEL)
    { 
	printf("makelabel\n");
	dbugprinttok(tok);
    };
    return tok;
}

TOKEN makegoto(int labelnum)
{
    TOKEN tok = makeoperatortok(GOTOOP);
    TOKEN labeltok = makenumbertok(labelnum);
    tok->operands = labeltok;
    return tok;
}

TOKEN makeconst(TOKEN sign, TOKEN tok)
{
    tok = makenumbertok(tok->intval);
    return tok;
}

/*
TOKEN findid(TOKEN tok)
{
    SYMBOL sym, typ;
    
    sym = searchst(tok->stringval);
    tok->symentry = sym;
    typ = sym->datatype;
    tok->symtype = typ;
    if( typ->kind == BASICTYPE || typ->kind == POINTERSYM)
    {
	tok->datatype = typ->basicdt;
    }
    return tok;
}
*/

void instlabel(TOKEN tok)
{
    tok->operands = makenumbertok(labelnumber);
    labelnumber = labelnumber + 1;
    //Do something to install the label, and then incrememtn the lavel counter
}

/*
void instconst(TOKEN idtok, TOKEN consttok)
{
    SYMBOL sym, typesym; int align;
    if (DEBUG & DB_INSTCONST)
    {
        printf("instconst\n");
        dbugprinttok(idtok);
        dbugprinttok(consttok);
    };

    //Make sure the consttok knows what kind of constant it is (real, int, string)
    switch(consttok->datatype)
    {
	case INTEGER:
	    typesym = searchst("integer");
	    typesym->constval.intnum = consttok->intval;
	    break;
	case REAL:
	    typesym = searchst("real");
	    typesym->constval.realnum = consttok->realval;
	    break;
	case STRING:
	    typesym = searchst("string");
	    strcpy(typesym->constval.stringconst, consttok->stringval);
	    break;
    }

    if(typesym == NULL) printf("uh oh - NULL\n");

    align = alignsize(typesym);
 
    sym = insertsym(idtok->stringval);
    sym->kind = CONSTSYM;
    sym->size = typesym->size;


    sym->datatype = typesym;
    sym->basicdt = typesym->basicdt; 
    sym->constval = typesym->constval;
   
    if (DEBUG & DB_INSTCONST) printst();
}
*/

TOKEN givesign(TOKEN sign, TOKEN tok)
{
    if(sign->whichval==MINUSOP)
    {
	TOKEN neg = makeoperatortok(MINUSOP);
	neg->operands = tok;
 	return neg;
    }
    return tok;
}

TOKEN negate(TOKEN tok) 
{
    return makenumbertok(-tok->intval);
}

TOKEN makenumbertok(int val)
{

    TOKEN tok = talloc();
    tok->tokentype = NUMBERTOK;
    tok->datatype = INTEGER;
    tok->intval = val;
    return tok;
}

TOKEN makeoperatortok(int val)
{
    TOKEN tok = talloc();
    tok->tokentype = OPERATOR;
    tok->datatype = INTEGER;
    tok->whichval = val;
    return tok;
}

TOKEN copytok(TOKEN tok)
{
    TOKEN cpy = talloc();
    cpy->tokentype = tok->tokentype;
    cpy->tokenval = tok->tokenval;
    return cpy;
}

/* This function is inside instvars.c

int wordaddress(int n, int wordsize)
{ 
    return ((n + wordsize - 1) / wordsize) * wordsize; 
}
*/

 
int yyerror(s)
  char * s;
{ 
  fputs(s,stderr); putc('\n',stderr);
  return 0;
}

int main()
{ 
    int res;
    //initsyms();a
    res = yyparse();
//    printst();
//    printf("yyparse result = %8d\n", res);
    
//    if (DEBUG & DB_PARSERES) dbugprinttok(parseresult);
    dbugprinttok(parseresult);
    ppexpr(parseresult);           /* Pretty-print the result tree */
//    gencode(parseresult, blockoffs[blocknumber], labelnumber);
    return 0;
}
