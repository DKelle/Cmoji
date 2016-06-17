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

#define OPERATOR        258 /* token types */
#define DELIMITER       259
#define RESERVED        260
#define IDENTIFIERTOK   261
#define NUMBERTOK       262

#define LOOP        279 /* reserved numbers */
#define LOOP1       280
#define TO          281
#define PRINT       282
#define SILENCE     283
#define FUNCALL     284
#define DEF         285
#define IF          286
#define ELIF        287
#define ELSE        288
#define RET         289
#define SLEEP       290
#define FUNCTION    291
#define HALT        292
#define RESERVED_BIAS   (LOOP - 1)

#define PLUSOP          263 /* operator numbers */
#define MINUSOP         264
#define TIMESOP         265
#define DIVIDEOP        266
#define EQOP            267
#define LTOP            268
#define LEOP            269
#define GEOP            270
#define GTOP            271
#define IFOP            272
#define NEOP            273
#define ANDOP           274
#define OROP            275
#define NOTOP           276
#define GOTOOP          293
#define LABELOP         294
#define OPERATOR_BIAS   (PLUSOP - 1) 

#define LPAREN  277 /* delimeter numbers */
#define RPAREN  278
#define DELIMITER_BIAS (LPAREN - 1)

#define INTEGER    	0	/* datatype numbers */
#define IDENTIFIER	1
#define NUMBER 		2

#define YYTOKENTYPE 0 
