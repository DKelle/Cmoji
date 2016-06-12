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
int yywrap();
void parsecomment();
void parseblockcomment();

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
comment1 \{
comment2 \(\*
string   \'(.*)?\'
delim    [ \t\n]
ws       ({delim})+
letter   [A-Za-z]
rnumber  {digit}+
fnumber  {digit}+(\.{digit}+)?(e[+\-]?{digit}+)?

%%
{ws}      { /* no action and no return */ }

array       {return(maketoken(RESERVED,ARRAY));}
downto      {return(maketoken(RESERVED,DOWNTO));}
function    {return(maketoken(RESERVED,FUNCTION));}
of          {return(maketoken(RESERVED,OF));}
repeat      {return(maketoken(RESERVED,REPEAT));}
until       {return(maketoken(RESERVED,UNTIL));}
begin       {return(maketoken(RESERVED,BEGINBEGIN));}
else        {return(maketoken(RESERVED,ELSE));}
goto        {return(maketoken(RESERVED,GOTO));}
packed      {return(maketoken(RESERVED,PACKED));}
set         {return(maketoken(RESERVED,SET));}
var         {return(maketoken(RESERVED,VAR));}
case        {return(maketoken(RESERVED,CASE));}
end         {return(maketoken(RESERVED,END));}
if          {return(maketoken(RESERVED,IF));}
procedure   {return(maketoken(RESERVED,PROCEDURE));}
then        {return(maketoken(RESERVED,THEN));}
while       {return(maketoken(RESERVED,WHILE));}
const       {return(maketoken(RESERVED,CONST));}
file        {return(maketoken(RESERVED,FILEFILE));}
label       {return(maketoken(RESERVED,LABEL));}
program     {return(maketoken(RESERVED,PROGRAM));}
to          {return(maketoken(RESERVED,TO));}
with        {return(maketoken(RESERVED,WITH));}
do          {return(maketoken(RESERVED,DO));}
for         {return(maketoken(RESERVED,FOR));}
nil         {return(maketoken(RESERVED,NIL));}
record      {return(maketoken(RESERVED,RECORD));}
type        {return(maketoken(RESERVED,TYPE));}


{comment1}  {parsecomment();}
{comment2} {parseblockcomment();}
{number}  {return(install_number());}

"+"       {return(maketoken(OPERATOR, PLUS));}
"-"       {return(maketoken(OPERATOR, MINUS));}
"*"       {return(maketoken(OPERATOR, TIMES));}
"/"       {return(maketoken(OPERATOR, DIVIDE));}
"<"       {return(maketoken(OPERATOR, LT));}
"< ="      {return(maketoken(OPERATOR, LE));}
"="       {return(maketoken(OPERATOR, EQ));}
">"       {return(maketoken(OPERATOR, GT));}
"> ="      {return(maketoken(OPERATOR, GE));}
"<>"      {return(maketoken(OPERATOR, NE));}

","   {return(maketoken(DELIMITER,COMMA));} 
";"   {return(maketoken(DELIMITER,SEMICOLON));} 
":"   {return(maketoken(DELIMITER,COLON));} 
"("   {return(maketoken(DELIMITER,LPAREN));} 
")"   {return(maketoken(DELIMITER,RPAREN));} 
"["   {return(maketoken(DELIMITER,LBRACKET));} 
"]"   {return(maketoken(DELIMITER,RBRACKET));} 
".."  {return(maketoken(DELIMITER,DOTDOT));} 


%%

/* Note that lex always returns two values:
   1. "What is it?": a small integer such as NUMBER that indicates the
      kind of item that was found; this is the return() value.
   2. The value itself.  This is yylval, which points to a TOKEN.   */


void parsecomment()
{       
    while (input() != '}');
}

void parseblockcomment()
{       
    loop:
    while (input() != '*');
    switch (input())
    {
	case ')': break;
        case '*': unput('*');
        default: goto loop;
    }
}

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
    
    return maketoken(NUMBERTOK, num);
}

/* Make simple tokens. */
int maketoken(int type, int which)
{
    printf("making token %d", which);
    yylval = (TOKEN) talloc();  /* Make new token, set yylval to point to it */
    yylval->tokentype = type;
    if (type == RESERVED)
    {
	yylval->whichval = which - RESERVED_BIAS;
    }
    else if (type == OPERATOR)
    {
	yylval->whichval = which - OPERATOR_BIAS;
    }  
    else if (type == DELIMITER)
    {
	yylval->whichval = which - DELIMITER_BIAS;
    }
    else if (type == NUMBERTOK)
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

int install_rnum()
{
    int rnum;
    yylval = (TOKEN) talloc();
    yylval->tokentype = NUMBERTOK;
    yylval->datatype = INTEGER;

    rnum = atoi(yytext);

    yylval->intval = rnum;
    return(NUMBER);

}

int yywrap() 
{ 
     /* lex may need this. */
    return(1);  
}       
