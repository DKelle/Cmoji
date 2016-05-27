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

%token IDENTIFIER STRING NUMBER   /* token types */

%token PLUS MINUS TIMES DIVIDE    /* Operators */
%token ASSIGN EQ NE LT LE GE GT POINT DOT AND OR NOT DIV MOD IN

%token COMMA                      /* Delimiters */
%token SEMICOLON COLON LPAREN RPAREN LBRACKET RBRACKET DOTDOT

%token ARRAY BEGINBEGIN           /* Lex uses BEGIN */
%token CASE CONST DO DOWNTO ELSE END FILEFILE FOR FUNCTION GOTO IF LABEL NIL
%token OF PACKED PROCEDURE PROGRAM RECORD REPEAT SET THEN TO TYPE UNTIL
%token VAR WHILE WITH


%%

/*  program    :  statement DOT                  { parseresult = $1; }
             ;*/

  program    	:  PROGRAM IDENTIFIER LPAREN idlist RPAREN SEMICOLON lblock DOT
                                       		/* Maybe this? { $$ = makeprogn($1,cons($2, $3)); } */
						{parseresult = makeprogram($2, makeprogn($3, $4), $7); }
		;
  idlist	: IDENTIFIER COMMA idlist	{ $$ = cons($1, $3); }
		| IDENTIFIER			{ $$ = cons($1, NULL); }
  field_list 	: fields SEMICOLON field_list	{ $$ = nconc($1, $3); }	
		| fields 			{ $$ = $1; }
		;
  fields	: idlist COLON type		{ $$ = instfields($1, $3); }
		;
  lblock	: LABEL numlist SEMICOLON cblock{ $$ = $4; }
		| cblock			{ $$ = $1; }
		;
  numlist	: NUMBER			/* Do something here */
		| NUMBER COMMA numlist	
		;
  cblock	: CONST cdef_list tblock	{ $$ = $3; }
		| tblock			{ $$ = $1; }
		;
  cdef_list	: cdef SEMICOLON
		| cdef SEMICOLON cdef_list
		;
  cdef		: IDENTIFIER EQ constant	{ instconst($1, $3); }
		;
  tblock 	: TYPE tdef_list vblock		{ $$ = $3; }
		| vblock			{ $$ = $1; }
		;
  tdef_list	: tdef SEMICOLON
		| tdef SEMICOLON tdef_list
		;
  tdef		: IDENTIFIER EQ type		{ insttype($1, $3); }
		;
  vblock	: VAR vdef_list block		{ $$ = $3; }
		| block				{ $$ = $1; }
		;
  vdef_list	: vdef SEMICOLON vdef_list 
		| vdef SEMICOLON
		;
  vdef		: idlist COLON type		{ instvars($1, $3); }
  		;
  simpletype_list: simpletype 			{ $$ = $1; }
		| simpletype COMMA simpletype_list
						{ $$ = cons($1, $3); }
		;
  simpletype 	: IDENTIFIER			{ $$ = findtype($1); }
		| LPAREN idlist RPAREN		{ $$ = instenum($2); }
		| constant DOTDOT constant	{ $$ = instdotdot($1, $2, $3); }
		;
  type		: simpletype			{ $$ = $1; }
		| RECORD field_list END		{ $$ = instrec($1, $2); }
		| POINT IDENTIFIER		{ $$ = instpoint($1, $2); }
		| ARRAY LBRACKET simpletype RBRACKET OF type
						{ $$ = instarray($3, $6); }
		| ARRAY LBRACKET simpletype_list RBRACKET OF type
						{ $$ = instmultiarray($3, $6); }
		;
  block		: BEGINBEGIN statement endpart  { $$ = makeprogn($1,cons($2,$3)); }
		;
  statement	: BEGINBEGIN statement endpart	{ $$ = makeprogn($1,cons($2, $3)); }
             	| if				{ $$ = $1; }
             	| assignment			{ $$ = $1; }
		| forloop			{ $$ = $1; }
		| whileloop			{ $$ = $1; }
		| funcall			{ $$ = $1; }
		| REPEAT statementlist UNTIL expr 
						{ $$ = makeprogn($1, makerepeat($1, $2, $3, $4)); }
		| label				{ $$ = $1; }
		| GOTO NUMBER			{ $$ = dogoto($1, $2); }
		;
  statementlist : statement			{ $$ = $1; }
		| statement SEMICOLON statementlist
						{ $$ = cons($1, $3); }
		;
  if		: IF expr THEN statement endif	{ $$ = makeif($1, $2, $4, $5); }
		;
  forloop	: FOR assignment TO expr DO statement
             					{ $$ = makeprogn($1, makefor( 1, $1, $2, $3, $4, $5, $6)); } 
		| FOR assignment DOWNTO expr DO statement
             					{ $$ = makeprogn($1, makefor(-1, $1, $2, $3, $4, $5, $6)); } 
		;
  whileloop	: WHILE expr DO statement  { $$ = makewhile($1, $2, $3, $4); }
		;
  funcall	: IDENTIFIER LPAREN exprlist RPAREN
						{ $$ = makefuncall($4, $1, $3); }
		;
  assignment 	: variable ASSIGN expr		{ $$ = binop($2, $1, $3); }
             	;
  variable 	: IDENTIFIER			{ $$ = addsymentry($1); }
		| variable LBRACKET expr RBRACKET
						{ $$ = makearef($1, $3, $2); }
 		| variable LBRACKET exprlist RBRACKET
						{ $$ = makemultiaref($1, $3, $2); }
		| variable DOT IDENTIFIER	{ $$ = reducedot($1, $2, $3); }/*{ $$ = makearef($1, $3, $2); }*/
		| variable POINT 		{ $$ = reducepoint($1, $2); }
		;
  exprlist	: expr COMMA exprlist		{ $$ = cons($1, $3); }
		| expr				{ $$ = cons($1, NULL); }
		;
  expr		: expr compareop simpleexpr	{ $$ = binop($2, $1, $3); }
		| simpleexpr			{ $$ = $1; }
		;
  simpleexpr	: simpleexpr adop term 		{ $$ = maybefloat(binop($2, $1, $3)); }
             	| term				{ $$ = $1; }
		| adop term			{ $$ = givesign($1,$2); }
             	;
  term       	: term mulop factor		{ $$ = maybefloat(binop($2, $1, $3)); }
             	| factor			{ $$ = $1; }
             	;
  factor     	: LPAREN expr RPAREN		{ $$ = $2; }
		| uconstant			{ $$ = $1; }
		| variable			{ $$ = $1; }
		| funcall			{ $$ = $1; }
		| NOT factor			{ $$ = negate($1); }
             	;
  uconstant	: NUMBER			{ $$ = $1; }
		| NIL				{ $$ = makenumbertok(0); }
		| STRING			{ $$ = $1; }
		;
  constant 	: adop IDENTIFIER		{ $$ = makeconst($1, $2); } /*{ $$ = $2; } /*need to do something with the adop here */
		| IDENTIFIER			{ $$ = makeuconstorvariable($1); }
		| adop NUMBER			{ $$ = makeconst($1,$2); } /*need to do something with the adop here */
		| NUMBER			{ $$ = $1; }
		| STRING			{ $$ = $1; }
		;
  label		: NUMBER COLON statement	{ $$ = makeprogn($2, dolabel($1, $1, $3)); }
  adop		: PLUS				{ $$ = $1; }
		| MINUS				{ $$ = $1; }
		;
  mulop		: TIMES				{ $$ = $1; }
		| DIVIDE			{ $$ = $1; }
		;
  compareop	: EQ				{ $$ = $1; }
		| LT				{ $$ = $1; }
		| GT				{ $$ = $1; }
		| NE				{ $$ = $1; }
		| LE				{ $$ = $1; }
		| GE				{ $$ = $1; }
		| IN				{ $$ = $1; }
		;	

/* ~~~~~~~~~~~~~~~~~~~~~~~~~ MY CODE ABOVE HERE ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */;


  endpart    	:  SEMICOLON statement endpart    { $$ = cons($2, $3); }
             	|  END                            { $$ = NULL; }
             	;
  endif      	:  ELSE statement                 { $$ = $2; }
             	|  /* empty */                    { $$ = NULL; }
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

TOKEN binop(TOKEN op, TOKEN lhs, TOKEN rhs)        /* reduce binary operator */
{

    //rhs may be a symbol
    if(rhs != NULL)
    {
        SYMBOL rhssym = searchst(rhs->stringval);
        if(rhssym && rhssym->kind == CONSTSYM) 
        {
            rhs = makenumbertok(rhssym->constval.intnum);
        }
    }
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

TOKEN makeprogram(TOKEN name, TOKEN args, TOKEN statements)
{ 
    TOKEN tok = talloc();

    args->link = statements;
    name->link = args;

    tok->tokentype = OPERATOR;
    tok->whichval = PROGRAMOP;
    tok->operands = name;
    if (DEBUG & DB_MAKEPROGRAM)
    { 
	printf("makeprogram\n");
	dbugprinttok(tok);
	dbugprinttok(name);
	dbugprinttok(args);
        dbugprinttok(statements);
    };
    return tok;
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


TOKEN makeprogn(TOKEN tok, TOKEN statements)
{ 
    tok->tokentype = OPERATOR;
    tok->whichval = PROGNOP;
    tok->operands = statements;
    if (DEBUG & DB_MAKEPROGN)
    { 
	printf("makeprogn\n");
	dbugprinttok(tok);
        dbugprinttok(statements);
    };
    return tok;
}

/* makewhile makes structures for a while statement.                
   tok and tokb are (now) unused tokens that are recycled. */       
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
    
}

/* makefor makes structures for a for statement.
   sign is 1 for normal loop, -1 for downto.
   asg is an assignment statement, e.g. (:= i 1)
   endexpr is the end expression
   tok, tokb and tokc are (now) unused tokens that are recycled. */
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

/* makefuncall makes a FUNCALL operator and links it to the fn and args.
   tok is a (now) unused token that is recycled. */
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
}

/* makearef makes an array reference operation.                   
   off is be an integer constant token                            
   tok (if not NULL) is a (now) unused token that is recycled. */ 
TOKEN makearef(TOKEN var, TOKEN off, TOKEN tok)
{
    tok = makeoperatortok(AREFOP);
    var->link = off;

    SYMBOL arrsym = searchst(var->stringval)->datatype;
    SYMBOL basicsym = arrsym->datatype;
    TOKEN aref = makeoperatortok(AREFOP);

    SYMBOL constsym = searchst(off->stringval);
    if(constsym && constsym->kind == CONSTSYM) {
	off = makenumbertok(constsym->constval.intnum);
    }

    //this is used for constant offset eg arr[4]
    int offnum = (off->intval - arrsym->lowbound) * basicsym->size;
    aref->operands = var;

    //this is used for variable offset eg arr[i]
    TOKEN plus = makeoperatortok(PLUSOP);
    TOKEN minuslow = makenumbertok(-1 * arrsym->lowbound * basicsym->size);
    TOKEN times = makeoperatortok(TIMESOP);
    TOKEN size = makenumbertok(basicsym->size);

    TOKEN timesop = binop(times, size, off);
    TOKEN plusop = binop(plus, minuslow, timesop);

    TOKEN offsettok = (off->tokentype == IDENTIFIERTOK) ? plusop : makenumbertok(offnum);
    var->link = offsettok;
    var->datatype = IDENTIFIERTOK;
    aref->symtype = basicsym;
    return aref;
}


TOKEN makemultiaref(TOKEN var, TOKEN off, TOKEN tok)
{

    //Put all the boundslist into an array, so we can walk down the array backwards
    TOKEN boundsarr[20]; //TODO: dont hard code this
    int count = 0;
    TOKEN pointer = off;

    while(pointer != NULL)
    {
	boundsarr[count] = pointer;
	pointer = pointer->link;
	count += 1;
    }
    count -= 1;
   
    int i = 0;
    TOKEN arr = makearef(var, boundsarr[count], NULL);    
    for(i = count-1; i >= 0; i--)
    {
    	arr = makearef(var, boundsarr[count], NULL);    
    }

    return arr;
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

/* makerepeat makes structures for a repeat statement.                
   tok and tokb are (now) unused tokens that are recycled. */         
TOKEN makerepeat(TOKEN tok, TOKEN statements, TOKEN tokb, TOKEN expr)
{        
    TOKEN labeltok = makelabel();
    TOKEN gototok = makegoto(labeltok->operands->intval);
    TOKEN emptyprogn = makeprogn(copytok(tok), NULL);
    TOKEN iftok = makeif(copytok(tok), expr, emptyprogn, gototok);

    //Add the 'if' block to after all of the statemnts inside the repeat
    TOKEN temp = statements;
    while(temp->link != NULL)
    {
    	temp = temp->link;
	
    }
    temp->link = iftok;

    labeltok->link = statements;
    TOKEN progntok = makeprogn(copytok(tok), labeltok);

    return progntok;
}

TOKEN makeconst(TOKEN sign, TOKEN tok)
{
    tok = makenumbertok(tok->intval);
    return tok;
}

TOKEN makeuconstorvariable(TOKEN tok)
{

    SYMBOL c = searchst(tok->stringval);

    if(c->kind==CONSTSYM)
    {
        switch(c->basicdt)
        {
	    case INTEGER:
	        tok = makenumbertok(c->constval.intnum);
	        break;
	    case REAL:
	        tok = makerealtok(c->constval.realnum);
	        break;
	    case STRING:
	        break;
    	}
    }

    if(DEBUG & DB_MAKECONST) dbugprinttok(tok);
    tok->symentry = c;
    return tok; 

}

/* makesubrange makes a SUBRANGE symbol table entry, puts the pointer to it
   into tok, and returns tok. */                                           
TOKEN makesubrange(TOKEN tok, int low, int high)
{
    SYMBOL sym = symalloc(); 
    sym->kind = SUBRANGE;
    sym->basicdt = INTEGER;
    sym->size = 4;
    sym->lowbound = low;
    sym->highbound = high;
    tok->symtype = sym;
    return tok;
}

TOKEN reducepoint(TOKEN var, TOKEN point)
{
    point = makeoperatortok(POINTEROP);
    point->operands = var;
    return point;
}

/* reducedot handles a record reference.
   dot is a (now) unused token that is recycled. */
TOKEN reducedot(TOKEN var, TOKEN dot, TOKEN field)
{
    TOKEN tempvar = var;
    if(var->whichval == AREFOP)
    {
	int isplus = 0;
	//We are already an array ref. Use the symbol we already installed to get the new offset
	TOKEN off = var->operands->link;
	//This may be a binop eg arr[i]
	if(off->tokentype == OPERATOR && off->whichval == PLUSOP)
	{
	    isplus = 1;
	    off = off->operands;
	}
	int offset = off->intval;
	SYMBOL sym = var->symtype;
        //once we have the symbol, step through until we find the field we want
	sym = sym->datatype->datatype;
        while(strcmp(field->stringval, sym->namestring) != 0)                           
        {         
	    sym = sym->link;
	}            
	TOKEN newoff = makenumbertok(offset+sym->offset);
	newoff->link = off->link;
	newoff->operands = off->operands;
	if(isplus) var->operands->link->operands = newoff;
	else var->operands->link = newoff;
	var->symtype = sym;                                                                   
	return var;
    }
    else
    {
        //This might be a pointer with the variable as its operand
        while(tempvar->operands != NULL)
        {
            tempvar = tempvar->operands;
        }
                                                                                                        
        SYMBOL rec = searchst(tempvar->stringval)->datatype->datatype->datatype->datatype->datatype;
        //once we have the record, step throgh until we find the field we are looking for
        while(strcmp(field->stringval, rec->namestring) != 0)
        {
            rec = rec->link;
        }

        TOKEN aref = makeoperatortok(AREFOP);
        aref->operands = var;
        aref->symtype = rec->datatype;
        var->link = makenumbertok(rec->offset);
        return aref;
    }
}

TOKEN maybefloat(TOKEN binop)
{
    TOKEN arg1 = binop->operands;
    TOKEN arg2 = arg1->link;
    TOKEN f;

    //Make sure that the operands are not operators themselves
    if(arg1->operands != NULL || arg2->operands != NULL)
    {
	return binop;
    }

    //If our operands are IDs, we must find their types
    if(arg1->tokentype == IDENTIFIERTOK)
    {
	arg1 = findtype(arg1);
    }
    if(arg2->tokentype == IDENTIFIERTOK)
    {
	arg2 = findtype(arg2);
    }

    //if one token is a float, and the other is not, cast the non-float
    if(arg1->datatype == REAL ^ arg2->datatype == REAL)
    {
	if(arg1->datatype == REAL)
	{
	    f = makefloat(arg2);
	    arg1->link = f;
	}
	else
	{
	    f = makefloat(arg1);
	    binop->operands = f;
	    f->link = arg2;
	}
    }

    return binop;
}

/* makefloat forces the item tok to be floating, by floating a constant 
   or by inserting a FLOATOP operator */                                
TOKEN makefloat(TOKEN tok)
{
    TOKEN ret;
    //check to see if we are floating a var or a const
    if(tok->tokentype == NUMBERTOK)
    {
	ret = makerealtok((float)(tok->intval));
    }
    else
    {
	ret = makeoperatortok(FLOATOP);
	ret->operands = tok;
    }
    
    return ret;
}

//TODO: make sure works with non basic dts
//Not sure if the if statement should have 'type->kind == POINTERSYM'
TOKEN findtype(TOKEN tok)
{

    SYMBOL typ;
    
    typ = searchst(tok->stringval);

    if(DEBUG && DB_FINDTYPE)
    {
	printf("finding symbol for string %s\n",tok->stringval);
	dbprsymbol(typ);
    } 

    tok->symtype = typ;
    if( typ->kind == BASICTYPE || typ->kind == POINTERSYM || typ->kind == VARSYM)
    {
	tok->datatype = typ->basicdt;
    }
    return tok;
}

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

void instlabel(TOKEN tok)
{
    tok->operands = makenumbertok(labelnumber);
    labelnumber = labelnumber + 1;
    //Do something to install the label, and then incrememtn the lavel counter
}

/* instdotdot installs a .. subrange in the symbol table.   
   dottok is a (now) unused token that is recycled. */      
TOKEN instdotdot(TOKEN lowtok, TOKEN dottok, TOKEN hightok)
{
    int low = lowtok->intval;
    int high = hightok->intval;
    return makesubrange(dottok, low, high);   
}
                                                            
/* instfields will install type in a list idlist of field name tokens:
   re, im: real    put the pointer to REAL in the RE, IM tokens.
   typetok is a token whose symtype is a symbol table pointer.
   Note that nconc() can be used to combine these lists after instrec() */
TOKEN instfields(TOKEN idlist, TOKEN typetok)
{

    typetok = findtype(typetok);


    TOKEN pointer = idlist;
    SYMBOL cursymbol; 
    
    while(pointer != NULL)
    {
	pointer->symtype = makesym(pointer->stringval);
	pointer->symtype->size = typetok->symtype->size;
	pointer->symtype->datatype = typetok->symtype;
	pointer->datatype = typetok->datatype;
	pointer = pointer->link;
    }

    pointer = idlist;
    while(pointer != NULL)
    {
	pointer = pointer->link;
    }
    return idlist;

}


/* instrec will install a record definition.  Each token in the linked list 
   argstok has a pointer its type.  rectok is just a trash token to be
   used to return the result in its symtype */
//TODO: Look at mod. I don't know if I'm doing totalsize correctly. SHould padding be taken care of for me?
TOKEN instrec(TOKEN rectok, TOKEN argstok)
{

    if(DEBUG & DB_INSTREC)
    {
	printf("inside instrec\n");
    }


    //Make rectoks datatype be a linked list of all argstok symtypes
    TOKEN pointer = argstok;
    int totalsize = 0;
    while(pointer != NULL)
    {
	if(pointer->link != NULL) pointer->symtype->link = pointer->link->symtype;
	
	strcpy(pointer->stringval, pointer->symtype->namestring);
 	int mod = (totalsize%pointer->symtype->size);
	pointer->symtype->offset = (mod == 0) ? totalsize : totalsize+pointer->symtype->size - mod;
	totalsize += (mod == 0) ? pointer->symtype->size : pointer->symtype->size-mod+pointer->symtype->size; 
	pointer = pointer->link;
    }

    SYMBOL rec = symalloc();
    rec->kind = RECORDSYM;
    rec->datatype = argstok->symtype;
    rec->size = totalsize;
    rectok->symtype = rec;
    return rectok;
    // do something
}


/* instenum installs an enumerated subrange in the symbol table, 
   e.g., type color = (red, white, blue)                         
   by calling makesubrange and returning the token it returns. */
TOKEN instenum(TOKEN idlist)
{
    int low = 0;
    int high = -1;
    TOKEN pointer = idlist;
    TOKEN inttok;
    while(pointer != NULL)
    {
	high += 1;
	inttok = makenumbertok(high);
	instconst(pointer, inttok);
	pointer = pointer->link;
    }

    TOKEN temp = talloc();
    return makesubrange(temp, low, high);

}                                   
                                                                 
/* instpoint will install a pointer type in symbol table */
TOKEN instpoint(TOKEN tok, TOKEN typename)
{
    SYMBOL sym = symalloc();
    SYMBOL typesym = searchins(typename->stringval);
    sym->datatype = typesym;
    sym->kind = POINTERSYM;
    sym->size = 8;
    tok->symtype = sym;
    tok->datatype = POINTER;
    return tok;
}


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
    sym->basicdt = typesym->basicdt; /* some student programs use this */ 
    sym->constval = typesym->constval;
   
    if (DEBUG & DB_INSTCONST) printst();
}

/* instarray installs an array declaration into the symbol table.
   bounds points to a SUBRANGE symbol table entry.
   The symbol table pointer is returned in token typetok. */
TOKEN instarray(TOKEN bounds, TOKEN typetok)
{
    SYMBOL sym = symalloc();
    SYMBOL symtype = typetok->symtype;
    SYMBOL subsym = bounds->symtype;
    sym->datatype = symtype;
    sym->size = (subsym->highbound - subsym->lowbound + 1) * symtype->size;
    sym->lowbound = subsym->lowbound;
    sym->highbound = subsym->highbound;
    sym->kind = ARRAYSYM;
    typetok->symtype = sym;
    return typetok;
    
}

TOKEN instmultiarray(TOKEN boundslist, TOKEN typetok)
{

    //Put all the boundslist into an array, so we can walk down the array backwards
    TOKEN boundsarr[20]; //TODO: dont hard code this
    int count = 0;
    TOKEN pointer = boundslist;

    while(pointer != NULL)
    {
	boundsarr[count] = pointer;
	pointer = pointer->link;
	count += 1;
    }
    count -= 1;
   
    int i = 0;
    TOKEN arr = instarray(boundsarr[count], typetok);    
    for(i = count-1; i >= 0; i--)
    {
	arr = instarray(boundsarr[i], arr);
    }

    return arr;
}

/* insttype will install a type name in symbol table.      
   typetok is a token containing symbol table pointers. */ 
void insttype(TOKEN typename, TOKEN typetok)
{
    SYMBOL sym, typesym; int align;
    if (DEBUG & DB_INSTTYPE)
    {
        printf("INSTTYPE\n");
        dbugprinttok(typetok);
        dbugprinttok(typename);
    };

    typesym = typetok->symtype;

    if(typesym == NULL) printf("uh oh - NULL\n");

    align = alignsize(typesym);
 
    sym = searchins(typename->stringval);
    sym->kind = TYPESYM;
    sym->size = typesym->size;

    sym->highbound = typesym->highbound;
    sym->lowbound = typesym->lowbound;

    sym->datatype = typesym;
    sym->basicdt = typesym->basicdt; /* some student programs use this */ 

    if (DEBUG & DB_INSTTYPE) printst();
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

TOKEN addsymentry(TOKEN id)
{
    SYMBOL sym = id->symentry;
    SYMBOL c = searchst(id->stringval);

    if(c->kind==CONSTSYM)
    {
        switch(c->basicdt)
        {
            case INTEGER:
                id = makenumbertok(c->constval.intnum);
                break;
            case REAL:
                id = makerealtok(c->constval.realnum);
                break;
            case STRING:
                break;
        }
    }

    if(DEBUG & DB_MAKECONST) dbugprinttok(id);
    id->datatype = c->basicdt;
    id->symentry = c;
    return id;

}

TOKEN makenumbertok(int val)
{
    TOKEN tok = talloc();
    tok->tokentype = NUMBERTOK;
    tok->datatype = INTEGER;
    tok->intval = val;
    return tok;
}

TOKEN makestringtok(char* val)
{
    TOKEN tok = talloc();
    tok->tokentype = STRINGTOK;
    strcpy(tok->stringval, val);
    return tok;
}

TOKEN makerealtok(float val)
{
    TOKEN tok = talloc();
    tok->tokentype = NUMBERTOK;
    tok->datatype = REAL;
    tok->realval = val;
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

TOKEN nconc(TOKEN lista, TOKEN listb) 
{
    TOKEN ahead = lista;
    while(ahead->link != NULL) ahead = ahead->link;
    ahead->link = listb;


    TOKEN pointer = lista;
    return lista;
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

 
yyerror(s)
  char * s;
  { 
  fputs(s,stderr); putc('\n',stderr);
  }

main()
{ 
    int res;
    initsyms();
    res = yyparse();
//    printst();
//    printf("yyparse result = %8d\n", res);
    
//    if (DEBUG & DB_PARSERES) dbugprinttok(parseresult);
//    ppexpr(parseresult);           /* Pretty-print the result tree */
    gencode(parseresult, blockoffs[blocknumber], labelnumber);
}
