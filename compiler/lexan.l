%{    /* lex2.l -- partial lex specification for Pascal    22 Jul 13 */

/* Copyright (c) 2013 Gordon S. Novak Jr. and The University of Texas at Austin
   */

/* This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see <http://www.gnu.org/licenses/>. */

/* To use:
        make lex2
        lex2
        x < 3.14            */

/* This file will work as given on a simple input such as:
   if i<j then x := 3.14

   Copy this file to lexan.l and expand it for your assignment.
   Use:
        make lexer
        lexer <graph1.pas
   */

#include <ctype.h>
#include "token.h"
#include "lexan.h"

int maketoken(int type, int which);
int install_number();
int install_id();
int yywrap();

/* If the lex yytext buffer turns out to be too small to hold comments,
   add the following lines:
 #undef YYLMAX
 #define YYLMAX 256
 */

TOKEN yylval;     /* This is the type of the lexical analyzer result */

%}

/* regular definitions */

digit0 [0]
digit1 [1]
digit2 [2]
digit3 [3]
digit4 [4]
digit5 [5]
digit6 [6]
digit7 [7]
digit8 [8]
digit9 [9]

digit	({digit0}|{digit1}|{digit2}|{digit3}|{digit4}|{digit5}|{digit6}|{digit7}|{digit8}|{digit9})
number  ({digit}+[ ]*?)+
delim    [ \t\n]
ws       ({delim})+
var     (var){digit}+

%%
{ws}        { /* no action and no return */ }
{number}    {return(install_number());}
{var}       {return(install_id());}


loop		{return(maketoken(RESERVED,LOOP));}
loop1		{return(maketoken(RESERVED,LOOP1));}
point		{return(maketoken(RESERVED,TO));}
print		{return(maketoken(RESERVED,PRINT));}
silence		{return(maketoken(RESERVED,SILENCE));}
funcall		{return(maketoken(RESERVED,FUNCALL));}
def         {return(maketoken(RESERVED,DEF));}
if		    {return(maketoken(RESERVED,IF));}
elif		{return(maketoken(RESERVED,ELIF));}
else		{return(maketoken(RESERVED,ELSE));}
ret		    {return(maketoken(RESERVED,RET));}
sleep		{return(maketoken(RESERVED,SLEEP));}
function    {return(maketoken(RESERVED,FUNCTION));}

"+"       	{return(maketoken(OPERATOR, PLUSOP));}
"-"       	{return(maketoken(OPERATOR, MINUSOP));}
"*"       	{return(maketoken(OPERATOR, TIMESOP));}
"/"       	{return(maketoken(OPERATOR, DIVIDEOP));}
"<"       	{return(maketoken(OPERATOR, LTOP));}
"< ="     	{return(maketoken(OPERATOR, LEOP));}
"="       	{return(maketoken(OPERATOR, EQOP));}
">"       	{return(maketoken(OPERATOR, GTOP));}
"> ="     	{return(maketoken(OPERATOR, GEOP));}
and         {return(maketoken(OPERATOR, ANDOP));}
not         {return(maketoken(OPERATOR, NOTOP));}
or          {return(maketoken(OPERATOR, OROP));}

"("		    {return(maketoken(DELIMITER,LPAREN));} 
")" 		{return(maketoken(DELIMITER,RPAREN));} 

%%

/* Note that lex always returns two values:
   1. "What is it?": a small integer such as NUMBER that indicates the
      kind of item that was found; this is the return() value.
   2. The value itself.  This is yylval, which points to a TOKEN.   */

int install_number()
{
    int num = 0;

    char test[80];
    char *sep = " ";
    char *word, *brkt;

    strcpy(test, yytext);

    for (word = strtok_r(test, sep, &brkt);
      word;
      word = strtok_r(NULL, sep, &brkt))
    {
        num *= 10;
	num += atoi(word);
    }
    
    maketoken(NUMBERTOK, num);
    return (NUMBER);
}

int install_id()
{ 
    int i, c, n;
    yylval = (TOKEN) talloc();  /* Make new token, set yylval to point to it */
    yylval->tokentype = IDENTIFIERTOK;
    n = yyleng;            /* number of characters */
    if ( n > 15 )
    {
	    n = 15;
    }

    for (i = 0; i < n ; i++)
    { 
	    c = yytext[i];
        /* if (islower(c)) c = toupper(c); */ /* to raise to upper case */
        yylval->stringval[i] = c;
    };

    yylval->stringval[n] = '\0';
          /* printf("id  %10s   n = %4d\n", yytext, n); */
    return(IDENTIFIER);
}

/* Make simple tokens. */
int maketoken(int type, int which)
{
    yylval = (TOKEN) talloc();  /* Make new token, set yylval to point to it */
    yylval->tokentype = type;
    if (type == NUMBERTOK)
    {
	    yylval->intval = which;
        yylval->datatype = INTEGER;
    }
    else
    {
	    yylval->whichval = which;
    }
    return(which);
}

int yywrap() 
{ 
     /* lex may need this. */
    return(1);  
}       
