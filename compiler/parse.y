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
%token GOTOOP LABELOP PROGNOP SLEEPOP PRINTOP

%token LPAREN RPAREN                                        /* Delimiters */

%token LOOP LOOP1 TO PRINT SILENCE FUNCALL                  /* Resereved */
%token DEF IF ELIF ELSE RET SLEEP FUNCTION HALT

%%
program : statement_list   {parseresult = $1;}		
        | print             {parseresult = $1;}        
        ;

statement   : declaration   { $$ = $1; }
            | if
            | assignment    { $$ = makestatement($1); }
            | funcall
            | loop          { $$ = $1; }
            | print         { $$ = $1; }
            ;

statement_list  : statement statement_list  {$$ = makeprogn(copytok($1),cons($1,$2));}
                | statement                 { $$ = makestatement($1);  }
                ;

declaration : DEF var           { $$ = NULL; }
            | DEF assignment    { $$ = $2; }
            ;

if          : IF expression LPAREN statement_list RPAREN
            | IF expression LPAREN statement_list RPAREN elif
            ;

assignment  : var EQOP expression { $$ = binop($2, $1, $3); }
            ;

funcall     : FUNCALL IDENTIFIERTOK 
            ;

loop        : LOOP expression LPAREN statement_list RPAREN
            | LOOP range LPAREN statement_list RPAREN       { $$ = binop($1, $2, $3); }
            | LOOP1 LPAREN statement_list RPAREN
            ;

var         : IDENTIFIERTOK { $$ = $1; }
            ;

expression  : expression compare_op simple_expression       { $$ = binop($2,$1,$3);}
            | simple_expression                         { $$ = $1; }
            ;

elif        : ELIF expression LPAREN statement_list RPAREN
            | ELIF expression LPAREN statement_list RPAREN else
            ;

range       : number TO number  { $$ = cons($1, $3); }
            ;

compare_op  : LTOP | LEOP | GTOP | GEOP
            ;

simple_expression   : term                          { $$ = $1; }
                    | simple_expression add_op term { $$ = binop($2,$1,$3);}
                    ;

else    : ELSE LPAREN statement_list RPAREN
        ;

number  : var
        | NUMBERTOK

term    : term times_op factor  {$$ = binop($2,$1,$3);}
        | factor                { $$ = $1; }
        ;

add_op  : PLUSOP | MINUSOP | OROP
        ;

times_op    : TIMESOP | DIVIDEOP | ANDOP
            ;

factor  : NUMBERTOK                 { $$ = $1; }
        | var
        | LPAREN expression RPAREN
        ;

print   : PRINT expression  {$$ = makeprint($1, $2); }
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


TOKEN makeprint(TOKEN print, TOKEN operands)
{
	print->tokentype = OPERATOR;
	print->whichval = PRINTOP - OPERATOR_BIAS;
	print->operands = operands;
	return print;
}

TOKEN makeprogn(TOKEN tok, TOKEN statements)
{
    tok->tokentype = OPERATOR;
    tok->whichval = PROGNOP - OPERATOR_BIAS;
    printf("progn is %d\n", PROGNOP-OPERATOR_BIAS);  
    tok->operands = statements;
    return tok;
}


TOKEN makeloop(TOKEN range, TOKEN stmn )
{
    range->operands = stmn;
    return range;
}

TOKEN makestatement(TOKEN statement)
{
    return statement;
}

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

TOKEN binop(TOKEN op, TOKEN lhs, TOKEN rhs)        /* reduce binary operator */
{

    op->operands = lhs;          /* link operands to operator       */
    lhs->link = rhs;             /* link second operand to first    */
    if(rhs) rhs->link = NULL;            /* terminate operand list          */
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

void instlabel(TOKEN tok)
{
    tok->operands = makenumbertok(labelnumber);
    labelnumber = labelnumber + 1;
    //Do something to install the label, and then incrememtn the lavel counter
}

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
    printf("yyparse result = %8d\n", res);
    
//    if (DEBUG & DB_PARSERES) dbugprinttok(parseresult);
    dbugprinttok(parseresult);
    ppexpr(parseresult);           /* Pretty-print the result tree */
//    gencode(parseresult, blockoffs[blocknumber], labelnumber);
    return 0;
}
