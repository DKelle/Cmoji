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

%token PLUSOP MINUSOP TIMESOP DIVIDEOP MODOP                     /* operators */
%token EQOP LTOP LEOP GEOP GTOP IFOP ELIFOP ELSEOP NEOP ANDOP OROP NOTOP
%token GOTOOP LABELOP STATEMENTOP SLEEPOP PRINTOP HALTOP NEWLINEOP

%token LPAREN RPAREN                                        /* Delimiters */

%token LOOP LOOP1 TO PRINT SILENCE FUNCALL                  /* Resereved */
%token DEF IF ELIF ELSE RET SLEEP FUNCTION HALT NEWLINE

%%
program : statement_list   {parseresult = $1;}		
        ;

statement   : if            { $$ = $1; }
            | assignment    { $$ = $1; }
            | funcall       { $$ = $1; }
            | loop          { $$ = $1; }
            | print         { $$ = $1; }
            | halt          { $$ = $1; }
            ;

statement_list  : statement statement_list  { $$ = makestatements($1, $2);}
                | statement                 { $$ = makestatements($1, NULL);  }
                ;

if          : IF comparator LPAREN statement_list RPAREN        { $$ = makeif($1, $2, $4, NULL); }
            | IF comparator LPAREN statement_list RPAREN elif   { $$ = makeif($1, $2, $4, $6); }
            ;

assignment  : var EQOP expression { $$ = binop($2, $1, $3); }
            ;

funcall     : FUNCALL IDENTIFIERTOK 
            ;

loop        : LOOP comparator LPAREN statement_list RPAREN  { $$ = makeloop($1, $2, $3, $4); }
            | LOOP range LPAREN statement_list RPAREN       { $$ = makerangeloop($1, $2, $3, $4); }
            | LOOP1 LPAREN statement_list RPAREN            { $$ = makeloopone($1, $3); }
            ;

var         : IDENTIFIERTOK { $$ = $1; }
            ;

expression  : expression compare_op simple_expression       { $$ = binop($2,$1,$3);}
            | simple_expression                             { $$ = $1; }
            ;

comparator  : expression compare_op simple_expression   { $$ = binop($2,$1,$3); }
            ;

elif        : ELIF expression LPAREN statement_list RPAREN      { $$ = makeelif($1, $2, $4, NULL); }
            | ELIF expression LPAREN statement_list RPAREN elif { $$ = makeelif($1, $2, $4, $6); }
            | ELIF expression LPAREN statement_list RPAREN else { $$ = makeelif($1, $2, $4, $6); }
            | else                                              { $$ = $1;  }
            ;

range       : number TO number  { $$ = cons($1, $3); }
            ;

compare_op  : LTOP | LEOP | GTOP | GEOP | EQOP
            ;

simple_expression   : term                          { $$ = $1; }
                    | simple_expression add_op term { $$ = binop($2,$1,$3);}
                    ;

else    : ELSE LPAREN statement_list RPAREN         { $$ = makeelse($1, $3); }
        ;

number  : var
        | NUMBERTOK

term    : term times_op factor  {$$ = binop($2,$1,$3);}
        | factor                { $$ = $1; }
        ;

add_op  : PLUSOP | MINUSOP | OROP
        ;

times_op    : TIMESOP | DIVIDEOP | MODOP | ANDOP 
            ;

factor  : NUMBERTOK                 { $$ = $1; }
        | var                       { $$ = $1; }
        | LPAREN expression RPAREN  { $$ = $2; }
        ;

print   : PRINT printexpr  {$$ = makeprint($1, $2); }
        ;

printexpr : expression          {$$ = $1;}
          | expression NEWLINE  {$$ = cons($1, $2); }
          | NEWLINE             {$$ = $1;}
          ;

halt    : HALT              { $$ = makehalt($1); }

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

//TODO find a better way to get an open reg for the counter
#define COUNTERREG 10

/* takes in a statement and a statment list, and links them together */
TOKEN makestatements(TOKEN stmnt1, TOKEN stmnt2)
{
    TOKEN tok = talloc();
    //it is possible that stmnt2 already has a statement 
    //if so, then we don't need to create one, otherwise we do
    if(stmnt2 && stmnt2->tokentype == OPERATOR && stmnt2->whichval == STATEMENTOP - OPERATOR_BIAS)
    {
        tok = stmnt2->operands;
        stmnt2->operands = stmnt1;
        stmnt1->link = tok;
        tok = stmnt2;
    }
    else
    {
        tok = makestatement(talloc(), cons(stmnt1, stmnt2));
    }   
    return tok;
}

/* Takes in the print token, and creates a PRINTOP token */
TOKEN makeprint(TOKEN print, TOKEN operands)
{
	print->tokentype = OPERATOR;
	print->whichval = PRINTOP - OPERATOR_BIAS;
	print->operands = operands;
    if(operands->whichval == NEWLINE - RESERVED_BIAS)
    {
        operands->whichval = NEWLINEOP - OPERATOR_BIAS;
    }
    else if(operands->link != NULL)
    {
        //The line we are printing ends with a new line character. 
        operands->link->whichval = NEWLINEOP - OPERATOR_BIAS;
    }
	return print;
}

/* Used as a filler operator, which can act on two sequential operations */
TOKEN makestatement(TOKEN tok, TOKEN statements)
{
    tok->tokentype = OPERATOR;
    tok->whichval = STATEMENTOP - OPERATOR_BIAS;
    tok->operands = statements;
    return tok;
}

/* Takes in an if, the condition, and an else, and creates an AST */
TOKEN makeif(TOKEN tok, TOKEN exp, TOKEN thenpart, TOKEN elsepart)
{
    tok->tokentype = OPERATOR;  /* Make it look like an operator   */
    tok->whichval = IFOP - OPERATOR_BIAS;
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
    
    }
    return tok;
}

/* Takes in a statement, and sets it as the operands of an ELSEOP */
TOKEN makeelse(TOKEN tok, TOKEN stmnt)
{
    tok->tokentype = OPERATOR;
    tok->whichval = ELSEOP - OPERATOR_BIAS;
    tok->operands = stmnt;
    return tok;
}

/* Takes in an elif, the condition, and an else, and creates an AST */
TOKEN makeelif(TOKEN tok, TOKEN exp, TOKEN thenpart, TOKEN elsepart)
{
    tok->tokentype = OPERATOR;
    tok->whichval = ELIFOP - OPERATOR_BIAS;
    if (elsepart != NULL) elsepart->link = NULL;
    thenpart->link = elsepart;
    exp->link = thenpart;
    tok->operands = exp;
    if (DEBUG & DB_MAKEIF)
    {
        printf("make elif\n");
        dbugprinttok(exp);
        dbugprinttok(thenpart);
        dbugprinttok(elsepart);
    
    }
    return tok;
}

/* makeloopone creates a range loop going from 1 -> 3 (repeates only 2 times) */
TOKEN makeloopone(TOKEN tok, TOKEN statements)
{
    //Create the 1 -> 3 range
    TOKEN one = makenumbertok(1);
    TOKEN three = makenumbertok(3);
    TOKEN range = cons(one,three);

    //create a rangeloop with the new range, and the statements we were passed
    TOKEN loop = makerangeloop(tok, range, copytok(tok), statements);
    return loop;
}

/* makerangeloop makes structures for a while statement using a range.
   tok and tokb are (now) unused tokens that are recycled. */
TOKEN makerangeloop(TOKEN tok, TOKEN range, TOKEN tokb, TOKEN statement)
{
    //create the expression from the given range (num1 < num2)
    TOKEN start = makevartok(COUNTERREG);
    TOKEN end = range->link;
    dbugprinttok(end);
    TOKEN le = makeoperatortok(LTOP);
    TOKEN expr = binop(le, start, end);

    //now we have to make sure we initialize the counter var
    TOKEN val = copytok(range);
    TOKEN eq = makeoperatortok(EQOP);
    TOKEN init = binop(eq, copytok(start), val);

    //before we make the loop, add an increment to the end of 'statement'
    TOKEN temp = statement->operands;
    TOKEN plus = makeoperatortok(PLUSOP);
    TOKEN one = makenumbertok(1);
    TOKEN addition = binop(plus, copytok(start), one);
    TOKEN inc = binop(copytok(eq), copytok(start), addition);
    while(temp->link)
    {
        temp = temp->link;
    }
    temp->link = inc;

    //Now create the loop using the created expr, and the new statement
    TOKEN loop = makeloop(tok, expr, tokb, statement);

    //insert the init between the 'statement' and 'label' of the loop
    TOKEN label = loop->operands;
    init->link = label;
    loop->operands = init;
    return loop;
}

/* makeloop makes structures for a while statement.
   tok and tokb are (now) unused tokens that are recycled. */
TOKEN makeloop(TOKEN tok, TOKEN expr, TOKEN tokb, TOKEN statement)
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
    TOKEN prog = makestatement(temp, label);

    return prog;
}

/* Takes in a halt token, and produced a HALTOP */
TOKEN makehalt(TOKEN tok)
{
    printf("starting to make halt\n");
    tok->tokentype = OPERATOR;
    tok->whichval = HALTOP - OPERATOR_BIAS;
    printf("dont making halt\n");
    return tok;
}

/* Takes in a register number, and creates a var token using that reg */
TOKEN makevartok(int reg)
{
    TOKEN tok = talloc();
    tok->tokentype = IDENTIFIERTOK;
 
    char buf[10];
    sprintf(buf, "var%d", reg);
    strcpy(tok->stringval, buf);
    return tok;
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
    //If both LHS and RHS are numbetrtoks, we can reduce immediately
    if(lhs->tokentype == NUMBERTOK && rhs->tokentype == NUMBERTOK)
    {
        int num;
        switch(op->whichval)
        {
            case PLUSOP - OPERATOR_BIAS:
                return makenumbertok(lhs->whichval + rhs->whichval);
                break;
            case MINUSOP - OPERATOR_BIAS:
                return makenumbertok(lhs->whichval - rhs->whichval);
                break;
            case TIMESOP - OPERATOR_BIAS:
                return makenumbertok(lhs->whichval * rhs->whichval);
                break;
            case DIVIDEOP - OPERATOR_BIAS:
                return makenumbertok(lhs->whichval / rhs->whichval);
            case MODOP - OPERATOR_BIAS:
                return makenumbertok(lhs->whichval % rhs->whichval);
                break;
        }
    }

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
    tok->whichval = LABELOP - OPERATOR_BIAS;

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
    tok->whichval = val - OPERATOR_BIAS;
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
    
    if(DEBUG > 0)
    {
        dbugprinttok(parseresult);
        ppexpr(parseresult);           /* Pretty-print the result tree */
    }   
//    ppexpr(parseresult);           /* Pretty-print the result tree */
    gencode(parseresult, labelnumber, (DEBUG > 0));
    return 0;
}
