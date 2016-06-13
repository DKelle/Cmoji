/* token.h           token definitions         ; 24 Dec 12  */

/* Copyright (c) 2012 Gordon S. Novak Jr. and
   The University of Texas at Austin. */

/* Token structure and constant definitions, assuming Bison token numbers */

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

/* 09 Feb 00; 06 Jul 12; 01 Aug 12
 */
                                 /* token data structure */
typedef struct tokn {
  int    tokentype;  /* OPERATOR, DELIMITER, RESERVED, IDENTIFIERTOK, NUMBERTOK */
  int    datatype;   /* INTEGER, IDENTIFIER, NUMBER */
  struct symtbr * symtype;
  struct symtbr * symentry;
  struct tokn * operands;
  struct tokn * link;
  union { char  tokenstring[16];   /* values of different types, overlapped */
          int   which;
          int   intnum;
          double realnum; } tokenval;
  } *TOKEN;

/* The following alternative kinds of values share storage in the token
   record.  Only one of the following can be present in a given token.  */
#define whichval  tokenval.which
#define intval    tokenval.intnum
#define realval   tokenval.realnum
#define stringval tokenval.tokenstring

#define OPERATOR       	0	/* token types */
#define DELIMITER      	1
#define RESERVED       	2
#define IDENTIFIERTOK  	3
#define NUMBERTOK	    4 

#define LOOP		1	/* reserved numbers */
#define LOOP1  		2
#define TO 		    3
#define PRINT  		4
#define SILENCE 	5
#define FUNCALL		6
#define DEF 		7
#define IF 		    8
#define ELIF   		9
#define ELSE   		10
#define RET 		11
#define SLEEP  		12
#define FUNCTION   	13

#define PLUSOP         	1	/* operator numbers */
#define MINUSOP       	2
#define TIMESOP        	3
#define DIVIDEOP       	4
#define EQOP           	5
#define LTOP           	6
#define LEOP           	7
#define GEOP          	8
#define GTOP          	9
#define IFOP          	10
#define NEOP            11
#define ANDOP         	12
#define OROP          	13
#define NOTOP         	14

#define LPAREN 		1	/* delimter numbers */
#define RPAREN 		2

#define INTEGER    	0	/* datatype numbers */
#define IDENTIFIER	1
#define NUMBER 		2

#define YYTOKENTYPE 0 
