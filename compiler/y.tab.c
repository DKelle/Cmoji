/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.0.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* Copy the first part of user declarations.  */
#line 1 "parse.y" /* yacc.c:339  */
     /* pars1.y    Pascal Parser      Gordon S. Novak Jr.  ; 30 Jul 13   */

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


#line 127 "y.tab.c" /* yacc.c:339  */

# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif


/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IDENTIFIER = 258,
    STRING = 259,
    NUMBER = 260,
    PLUS = 261,
    MINUS = 262,
    TIMES = 263,
    DIVIDE = 264,
    ASSIGN = 265,
    EQ = 266,
    NE = 267,
    LT = 268,
    LE = 269,
    GE = 270,
    GT = 271,
    POINT = 272,
    DOT = 273,
    AND = 274,
    OR = 275,
    NOT = 276,
    DIV = 277,
    MOD = 278,
    IN = 279,
    COMMA = 280,
    SEMICOLON = 281,
    COLON = 282,
    LPAREN = 283,
    RPAREN = 284,
    LBRACKET = 285,
    RBRACKET = 286,
    DOTDOT = 287,
    ARRAY = 288,
    BEGINBEGIN = 289,
    CASE = 290,
    CONST = 291,
    DO = 292,
    DOWNTO = 293,
    ELSE = 294,
    END = 295,
    FILEFILE = 296,
    FOR = 297,
    FUNCTION = 298,
    GOTO = 299,
    IF = 300,
    LABEL = 301,
    NIL = 302,
    OF = 303,
    PACKED = 304,
    PROCEDURE = 305,
    PROGRAM = 306,
    RECORD = 307,
    REPEAT = 308,
    SET = 309,
    THEN = 310,
    TO = 311,
    TYPE = 312,
    UNTIL = 313,
    VAR = 314,
    WHILE = 315,
    WITH = 316
  };
#endif
/* Tokens.  */
#define IDENTIFIER 258
#define STRING 259
#define NUMBER 260
#define PLUS 261
#define MINUS 262
#define TIMES 263
#define DIVIDE 264
#define ASSIGN 265
#define EQ 266
#define NE 267
#define LT 268
#define LE 269
#define GE 270
#define GT 271
#define POINT 272
#define DOT 273
#define AND 274
#define OR 275
#define NOT 276
#define DIV 277
#define MOD 278
#define IN 279
#define COMMA 280
#define SEMICOLON 281
#define COLON 282
#define LPAREN 283
#define RPAREN 284
#define LBRACKET 285
#define RBRACKET 286
#define DOTDOT 287
#define ARRAY 288
#define BEGINBEGIN 289
#define CASE 290
#define CONST 291
#define DO 292
#define DOWNTO 293
#define ELSE 294
#define END 295
#define FILEFILE 296
#define FOR 297
#define FUNCTION 298
#define GOTO 299
#define IF 300
#define LABEL 301
#define NIL 302
#define OF 303
#define PACKED 304
#define PROCEDURE 305
#define PROGRAM 306
#define RECORD 307
#define REPEAT 308
#define SET 309
#define THEN 310
#define TO 311
#define TYPE 312
#define UNTIL 313
#define VAR 314
#define WHILE 315
#define WITH 316

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);



/* Copy the second part of user declarations.  */

#line 297 "y.tab.c" /* yacc.c:358  */

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE
# if (defined __GNUC__                                               \
      && (2 < __GNUC__ || (__GNUC__ == 2 && 96 <= __GNUC_MINOR__)))  \
     || defined __SUNPRO_C && 0x5110 <= __SUNPRO_C
#  define YY_ATTRIBUTE(Spec) __attribute__(Spec)
# else
#  define YY_ATTRIBUTE(Spec) /* empty */
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# define YY_ATTRIBUTE_PURE   YY_ATTRIBUTE ((__pure__))
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# define YY_ATTRIBUTE_UNUSED YY_ATTRIBUTE ((__unused__))
#endif

#if !defined _Noreturn \
     && (!defined __STDC_VERSION__ || __STDC_VERSION__ < 201112)
# if defined _MSC_VER && 1200 <= _MSC_VER
#  define _Noreturn __declspec (noreturn)
# else
#  define _Noreturn YY_ATTRIBUTE ((__noreturn__))
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")\
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif


#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYSIZE_T yynewbytes;                                            \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / sizeof (*yyptr);                          \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, (Count) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYSIZE_T yyi;                         \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  4
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   271

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  62
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  41
/* YYNRULES -- Number of rules.  */
#define YYNRULES  97
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  191

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   316

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint8 yyrline[] =
{
       0,    83,    83,    87,    88,    89,    90,    92,    94,    95,
      97,    98,   100,   101,   103,   104,   106,   108,   109,   111,
     112,   114,   116,   117,   119,   120,   122,   124,   125,   128,
     129,   130,   132,   133,   134,   135,   137,   140,   142,   143,
     144,   145,   146,   147,   148,   150,   151,   153,   154,   157,
     159,   161,   164,   166,   169,   171,   172,   174,   176,   177,
     179,   180,   182,   183,   185,   186,   187,   189,   190,   192,
     193,   194,   195,   196,   198,   199,   200,   202,   203,   204,
     205,   206,   208,   209,   210,   212,   213,   215,   216,   217,
     218,   219,   220,   221,   227,   228,   230,   231
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 0
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "IDENTIFIER", "STRING", "NUMBER", "PLUS",
  "MINUS", "TIMES", "DIVIDE", "ASSIGN", "EQ", "NE", "LT", "LE", "GE", "GT",
  "POINT", "DOT", "AND", "OR", "NOT", "DIV", "MOD", "IN", "COMMA",
  "SEMICOLON", "COLON", "LPAREN", "RPAREN", "LBRACKET", "RBRACKET",
  "DOTDOT", "ARRAY", "BEGINBEGIN", "CASE", "CONST", "DO", "DOWNTO", "ELSE",
  "END", "FILEFILE", "FOR", "FUNCTION", "GOTO", "IF", "LABEL", "NIL", "OF",
  "PACKED", "PROCEDURE", "PROGRAM", "RECORD", "REPEAT", "SET", "THEN",
  "TO", "TYPE", "UNTIL", "VAR", "WHILE", "WITH", "$accept", "program",
  "idlist", "field_list", "fields", "lblock", "numlist", "cblock",
  "cdef_list", "cdef", "tblock", "tdef_list", "tdef", "vblock",
  "vdef_list", "vdef", "simpletype_list", "simpletype", "type", "block",
  "statement", "statementlist", "if", "forloop", "whileloop", "funcall",
  "assignment", "variable", "exprlist", "expr", "simpleexpr", "term",
  "factor", "uconstant", "constant", "label", "adop", "mulop", "compareop",
  "endpart", "endif", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316
};
# endif

#define YYPACT_NINF -146

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-146)))

#define YYTABLE_NINF -79

#define yytable_value_is_error(Yytable_value) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     -33,    24,    29,     9,  -146,    51,    35,    33,    51,    42,
    -146,    66,    25,    76,    77,    78,    51,    69,  -146,  -146,
    -146,  -146,    56,    61,    25,    87,    86,   133,    25,   133,
      -2,  -146,  -146,  -146,  -146,  -146,   101,  -146,    84,   -15,
      71,    89,    90,   110,   -12,   100,   103,    94,   106,  -146,
     133,    25,    -2,  -146,    27,  -146,  -146,  -146,  -146,  -146,
     164,   133,  -146,  -146,    92,   160,    46,    68,  -146,  -146,
     164,   108,    85,   175,    25,  -146,  -146,   133,  -146,   132,
     133,   146,  -146,    76,    77,    58,    28,  -146,    78,    28,
    -146,    51,   113,   241,  -146,  -146,   133,   133,  -146,   222,
    -146,  -146,  -146,  -146,  -146,  -146,  -146,    25,   133,   164,
    -146,  -146,   164,    68,    25,   133,    25,    -2,   247,  -146,
     115,   216,  -146,  -146,  -146,  -146,    20,  -146,  -146,  -146,
     112,   144,    51,   136,    51,  -146,  -146,   130,  -146,  -146,
    -146,  -146,   133,   182,   189,  -146,   138,    46,    68,  -146,
    -146,   247,  -146,  -146,  -146,  -146,  -146,  -146,  -146,   149,
     217,   152,   141,   156,   146,  -146,    25,    25,    25,  -146,
    -146,   176,    26,    28,  -146,    51,  -146,  -146,  -146,  -146,
     135,   217,   161,  -146,  -146,    28,  -146,   183,    28,  -146,
    -146
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,     0,     0,     0,     1,     0,     4,     0,     0,     0,
       3,     0,     0,     0,     0,     0,     0,     0,     9,    13,
      18,    23,    55,     0,     0,     0,     0,     0,     0,     0,
       0,    39,    41,    42,    43,    40,     0,    45,     0,     0,
       0,    10,     0,     0,     0,     0,     0,     0,     0,     2,
       0,     0,     0,    55,     0,    46,    76,    74,    83,    84,
       0,     0,    75,    72,    71,     0,    63,    65,    68,    70,
       0,    47,     0,     0,     0,    95,    37,     0,    59,     0,
       0,     0,    12,    14,     0,     0,     0,    17,    19,     0,
      22,    25,     0,    61,    82,    38,     0,     0,    73,     0,
      87,    90,    88,    91,    92,    89,    93,     0,     0,     0,
      85,    86,     0,    66,     0,     0,     0,     0,    54,    58,
       0,     0,    78,    81,    80,    16,     0,    15,    11,     8,
      29,     0,     0,     0,     0,    32,    21,     0,    20,    26,
      24,    53,     0,     0,     0,    69,    97,    62,    64,    67,
      48,    44,    52,    94,    57,    56,    77,    79,    34,     0,
       0,     0,     0,     6,     0,    60,     0,     0,     0,    49,
      30,     0,     0,     0,    33,     0,    31,    51,    50,    96,
       0,     0,     0,     7,     5,     0,    28,    27,     0,    36,
      35
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -146,  -146,    -5,    39,  -146,  -146,   126,   131,   134,  -146,
     179,   137,  -146,   195,   151,  -146,    62,  -145,   -87,   197,
      -3,   150,  -146,  -146,  -146,    -8,   223,   -11,   -70,   -22,
     142,   -59,   -48,  -146,   -75,  -146,   -40,  -146,  -146,   -44,
    -146
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     2,    46,   162,   163,    17,    42,    18,    39,    40,
      19,    44,    45,    20,    47,    48,   171,   135,   136,    21,
      71,    72,    31,    32,    33,    63,    35,    64,    92,    93,
      66,    67,    68,    69,   137,    37,    70,   112,   108,    76,
     169
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
       7,    36,   139,    10,    34,    65,   125,    73,    95,    30,
     120,   113,    98,    36,    36,   172,    34,    36,     1,    12,
      34,    52,    12,   156,    74,   157,   109,     3,    22,     4,
      23,   130,   123,   124,    58,    59,   187,     5,    75,    99,
      36,   126,    15,    34,    16,   131,   126,    16,    94,   126,
     148,   181,    58,    59,     6,   118,   132,   182,   121,    24,
       8,   133,     9,    36,   149,    96,    34,    25,    11,    26,
      27,   117,   165,   153,   143,   144,   110,   111,    28,    38,
     134,    43,    41,    97,    50,    29,   183,    49,    51,   176,
      53,    55,    12,   151,    13,    81,    36,    83,   189,    34,
      12,   190,    13,    36,   146,    36,    34,   109,    34,    78,
      79,    77,    14,   152,    84,    15,    85,    16,    78,    79,
     126,    86,    80,    15,   126,    16,    88,   159,    12,   161,
      89,    80,    91,   126,   114,   119,    22,    56,    57,    58,
      59,   126,   141,   115,   -78,   126,   154,   158,   126,   122,
     123,   124,    58,    59,    60,    36,    36,    36,    34,    34,
      34,    61,   164,   177,   178,   179,   160,    22,    56,    57,
     161,   100,   101,   102,   103,   104,   105,   168,   170,   173,
      62,   174,   175,   185,   106,    60,   100,   101,   102,   103,
     104,   105,    61,   100,   101,   102,   103,   104,   105,   106,
     100,   101,   102,   103,   104,   105,   106,   180,   181,   188,
     128,    62,   116,   106,   184,   107,   129,   127,    82,   166,
     130,   123,   124,    58,    59,   138,   167,   100,   101,   102,
     103,   104,   105,   100,   101,   102,   103,   104,   105,    87,
     106,   142,   140,   186,    90,   132,   106,   155,    54,     0,
     147,   145,   100,   101,   102,   103,   104,   105,   100,   101,
     102,   103,   104,   105,   150,   106,   142,     0,     0,     0,
       0,   106
};

static const yytype_int16 yycheck[] =
{
       5,    12,    89,     8,    12,    27,    81,    29,    52,    12,
      80,    70,    60,    24,    25,   160,    24,    28,    51,    34,
      28,    24,    34,     3,    26,     5,    66,     3,     3,     0,
       5,     3,     4,     5,     6,     7,   181,    28,    40,    61,
      51,    81,    57,    51,    59,    17,    86,    59,    51,    89,
     109,    25,     6,     7,     3,    77,    28,    31,    80,    34,
      25,    33,    29,    74,   112,    38,    74,    42,    26,    44,
      45,    74,   142,   117,    96,    97,     8,     9,    53,     3,
      52,     3,     5,    56,    28,    60,   173,    18,    27,   164,
       3,     5,    34,   115,    36,    11,   107,    26,   185,   107,
      34,   188,    36,   114,   107,   116,   114,   147,   116,    17,
      18,    10,    46,   116,    25,    57,    26,    59,    17,    18,
     160,    11,    30,    57,   164,    59,    26,   132,    34,   134,
      27,    30,    26,   173,    26,     3,     3,     4,     5,     6,
       7,   181,    29,    58,    32,   185,    31,     3,   188,     3,
       4,     5,     6,     7,    21,   166,   167,   168,   166,   167,
     168,    28,    32,   166,   167,   168,    30,     3,     4,     5,
     175,    11,    12,    13,    14,    15,    16,    39,    29,    27,
      47,    40,    26,    48,    24,    21,    11,    12,    13,    14,
      15,    16,    28,    11,    12,    13,    14,    15,    16,    24,
      11,    12,    13,    14,    15,    16,    24,    31,    25,    48,
      84,    47,    37,    24,   175,    55,    85,    83,    39,    37,
       3,     4,     5,     6,     7,    88,    37,    11,    12,    13,
      14,    15,    16,    11,    12,    13,    14,    15,    16,    44,
      24,    25,    91,   181,    47,    28,    24,    31,    25,    -1,
     108,    29,    11,    12,    13,    14,    15,    16,    11,    12,
      13,    14,    15,    16,   114,    24,    25,    -1,    -1,    -1,
      -1,    24
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    51,    63,     3,     0,    28,     3,    64,    25,    29,
      64,    26,    34,    36,    46,    57,    59,    67,    69,    72,
      75,    81,     3,     5,    34,    42,    44,    45,    53,    60,
      82,    84,    85,    86,    87,    88,    89,    97,     3,    70,
      71,     5,    68,     3,    73,    74,    64,    76,    77,    18,
      28,    27,    82,     3,    88,     5,     4,     5,     6,     7,
      21,    28,    47,    87,    89,    91,    92,    93,    94,    95,
      98,    82,    83,    91,    26,    40,   101,    10,    17,    18,
      30,    11,    72,    26,    25,    26,    11,    75,    26,    27,
      81,    26,    90,    91,    82,   101,    38,    56,    94,    91,
      11,    12,    13,    14,    15,    16,    24,    55,   100,    98,
       8,     9,    99,    93,    26,    58,    37,    82,    91,     3,
      90,    91,     3,     4,     5,    96,    98,    70,    68,    69,
       3,    17,    28,    33,    52,    79,    80,    96,    73,    80,
      76,    29,    25,    91,    91,    29,    82,    92,    93,    94,
      83,    91,    82,   101,    31,    31,     3,     5,     3,    64,
      30,    64,    65,    66,    32,    90,    37,    37,    39,   102,
      29,    78,    79,    27,    40,    26,    96,    82,    82,    82,
      31,    25,    31,    80,    65,    48,    78,    79,    48,    80,
      80
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    62,    63,    64,    64,    65,    65,    66,    67,    67,
      68,    68,    69,    69,    70,    70,    71,    72,    72,    73,
      73,    74,    75,    75,    76,    76,    77,    78,    78,    79,
      79,    79,    80,    80,    80,    80,    80,    81,    82,    82,
      82,    82,    82,    82,    82,    82,    82,    83,    83,    84,
      85,    85,    86,    87,    88,    89,    89,    89,    89,    89,
      90,    90,    91,    91,    92,    92,    92,    93,    93,    94,
      94,    94,    94,    94,    95,    95,    95,    96,    96,    96,
      96,    96,    97,    98,    98,    99,    99,   100,   100,   100,
     100,   100,   100,   100,   101,   101,   102,   102
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     8,     3,     1,     3,     1,     3,     4,     1,
       1,     3,     3,     1,     2,     3,     3,     3,     1,     2,
       3,     3,     3,     1,     3,     2,     3,     1,     3,     1,
       3,     3,     1,     3,     2,     6,     6,     3,     3,     1,
       1,     1,     1,     1,     4,     1,     2,     1,     3,     5,
       6,     6,     4,     4,     3,     1,     4,     4,     3,     2,
       3,     1,     3,     1,     3,     1,     2,     3,     1,     3,
       1,     1,     1,     2,     1,     1,     1,     2,     1,     2,
       1,     1,     3,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     3,     1,     2,     0
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                  \
do                                                              \
  if (yychar == YYEMPTY)                                        \
    {                                                           \
      yychar = (Token);                                         \
      yylval = (Value);                                         \
      YYPOPSTACK (yylen);                                       \
      yystate = *yyssp;                                         \
      goto yybackup;                                            \
    }                                                           \
  else                                                          \
    {                                                           \
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;                                                  \
    }                                                           \
while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256



/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)

/* This macro is provided for backward compatibility. */
#ifndef YY_LOCATION_PRINT
# define YY_LOCATION_PRINT(File, Loc) ((void) 0)
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*----------------------------------------.
| Print this symbol's value on YYOUTPUT.  |
`----------------------------------------*/

static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  FILE *yyo = yyoutput;
  YYUSE (yyo);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  YYUSE (yytype);
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyoutput, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yytype_int16 *yyssp, YYSTYPE *yyvsp, int yyrule)
{
  unsigned long int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[yyssp[yyi + 1 - yynrhs]],
                       &(yyvsp[(yyi + 1) - (yynrhs)])
                                              );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
yystrlen (const char *yystr)
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            /* Fall through.  */
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYSIZE_T *yymsg_alloc, char **yymsg,
                yytype_int16 *yyssp, int yytoken)
{
  YYSIZE_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
  YYSIZE_T yysize = yysize0;
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat. */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Number of reported tokens (one for the "unexpected", one per
     "expected"). */
  int yycount = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[*yyssp];
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYSIZE_T yysize1 = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (! (yysize <= yysize1
                         && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
                    return 2;
                  yysize = yysize1;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    YYSIZE_T yysize1 = yysize + yystrlen (yyformat);
    if (! (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
      return 2;
    yysize = yysize1;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          yyp++;
          yyformat++;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
{
  YYUSE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        YYSTYPE *yyvs1 = yyvs;
        yytype_int16 *yyss1 = yyss;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * sizeof (*yyssp),
                    &yyvs1, yysize * sizeof (*yyvsp),
                    &yystacksize);

        yyss = yyss1;
        yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yytype_int16 *yyss1 = yyss;
        union yyalloc *yyptr =
          (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
                  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 85 "parse.y" /* yacc.c:1646  */
    {parseresult = makeprogram((yyvsp[-6]), makeprogn((yyvsp[-5]), (yyvsp[-4])), (yyvsp[-1])); }
#line 1533 "y.tab.c" /* yacc.c:1646  */
    break;

  case 3:
#line 87 "parse.y" /* yacc.c:1646  */
    { (yyval) = cons((yyvsp[-2]), (yyvsp[0])); }
#line 1539 "y.tab.c" /* yacc.c:1646  */
    break;

  case 4:
#line 88 "parse.y" /* yacc.c:1646  */
    { (yyval) = cons((yyvsp[0]), NULL); }
#line 1545 "y.tab.c" /* yacc.c:1646  */
    break;

  case 5:
#line 89 "parse.y" /* yacc.c:1646  */
    { (yyval) = nconc((yyvsp[-2]), (yyvsp[0])); }
#line 1551 "y.tab.c" /* yacc.c:1646  */
    break;

  case 6:
#line 90 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1557 "y.tab.c" /* yacc.c:1646  */
    break;

  case 7:
#line 92 "parse.y" /* yacc.c:1646  */
    { (yyval) = instfields((yyvsp[-2]), (yyvsp[0])); }
#line 1563 "y.tab.c" /* yacc.c:1646  */
    break;

  case 8:
#line 94 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1569 "y.tab.c" /* yacc.c:1646  */
    break;

  case 9:
#line 95 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1575 "y.tab.c" /* yacc.c:1646  */
    break;

  case 12:
#line 100 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1581 "y.tab.c" /* yacc.c:1646  */
    break;

  case 13:
#line 101 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1587 "y.tab.c" /* yacc.c:1646  */
    break;

  case 16:
#line 106 "parse.y" /* yacc.c:1646  */
    { instconst((yyvsp[-2]), (yyvsp[0])); }
#line 1593 "y.tab.c" /* yacc.c:1646  */
    break;

  case 17:
#line 108 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1599 "y.tab.c" /* yacc.c:1646  */
    break;

  case 18:
#line 109 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1605 "y.tab.c" /* yacc.c:1646  */
    break;

  case 21:
#line 114 "parse.y" /* yacc.c:1646  */
    { insttype((yyvsp[-2]), (yyvsp[0])); }
#line 1611 "y.tab.c" /* yacc.c:1646  */
    break;

  case 22:
#line 116 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1617 "y.tab.c" /* yacc.c:1646  */
    break;

  case 23:
#line 117 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1623 "y.tab.c" /* yacc.c:1646  */
    break;

  case 26:
#line 122 "parse.y" /* yacc.c:1646  */
    { instvars((yyvsp[-2]), (yyvsp[0])); }
#line 1629 "y.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 124 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1635 "y.tab.c" /* yacc.c:1646  */
    break;

  case 28:
#line 126 "parse.y" /* yacc.c:1646  */
    { (yyval) = cons((yyvsp[-2]), (yyvsp[0])); }
#line 1641 "y.tab.c" /* yacc.c:1646  */
    break;

  case 29:
#line 128 "parse.y" /* yacc.c:1646  */
    { (yyval) = findtype((yyvsp[0])); }
#line 1647 "y.tab.c" /* yacc.c:1646  */
    break;

  case 30:
#line 129 "parse.y" /* yacc.c:1646  */
    { (yyval) = instenum((yyvsp[-1])); }
#line 1653 "y.tab.c" /* yacc.c:1646  */
    break;

  case 31:
#line 130 "parse.y" /* yacc.c:1646  */
    { (yyval) = instdotdot((yyvsp[-2]), (yyvsp[-1]), (yyvsp[0])); }
#line 1659 "y.tab.c" /* yacc.c:1646  */
    break;

  case 32:
#line 132 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1665 "y.tab.c" /* yacc.c:1646  */
    break;

  case 33:
#line 133 "parse.y" /* yacc.c:1646  */
    { (yyval) = instrec((yyvsp[-2]), (yyvsp[-1])); }
#line 1671 "y.tab.c" /* yacc.c:1646  */
    break;

  case 34:
#line 134 "parse.y" /* yacc.c:1646  */
    { (yyval) = instpoint((yyvsp[-1]), (yyvsp[0])); }
#line 1677 "y.tab.c" /* yacc.c:1646  */
    break;

  case 35:
#line 136 "parse.y" /* yacc.c:1646  */
    { (yyval) = instarray((yyvsp[-3]), (yyvsp[0])); }
#line 1683 "y.tab.c" /* yacc.c:1646  */
    break;

  case 36:
#line 138 "parse.y" /* yacc.c:1646  */
    { (yyval) = instmultiarray((yyvsp[-3]), (yyvsp[0])); }
#line 1689 "y.tab.c" /* yacc.c:1646  */
    break;

  case 37:
#line 140 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeprogn((yyvsp[-2]),cons((yyvsp[-1]),(yyvsp[0]))); }
#line 1695 "y.tab.c" /* yacc.c:1646  */
    break;

  case 38:
#line 142 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeprogn((yyvsp[-2]),cons((yyvsp[-1]), (yyvsp[0]))); }
#line 1701 "y.tab.c" /* yacc.c:1646  */
    break;

  case 39:
#line 143 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1707 "y.tab.c" /* yacc.c:1646  */
    break;

  case 40:
#line 144 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1713 "y.tab.c" /* yacc.c:1646  */
    break;

  case 41:
#line 145 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1719 "y.tab.c" /* yacc.c:1646  */
    break;

  case 42:
#line 146 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1725 "y.tab.c" /* yacc.c:1646  */
    break;

  case 43:
#line 147 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1731 "y.tab.c" /* yacc.c:1646  */
    break;

  case 44:
#line 149 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeprogn((yyvsp[-3]), makerepeat((yyvsp[-3]), (yyvsp[-2]), (yyvsp[-1]), (yyvsp[0]))); }
#line 1737 "y.tab.c" /* yacc.c:1646  */
    break;

  case 45:
#line 150 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1743 "y.tab.c" /* yacc.c:1646  */
    break;

  case 46:
#line 151 "parse.y" /* yacc.c:1646  */
    { (yyval) = dogoto((yyvsp[-1]), (yyvsp[0])); }
#line 1749 "y.tab.c" /* yacc.c:1646  */
    break;

  case 47:
#line 153 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1755 "y.tab.c" /* yacc.c:1646  */
    break;

  case 48:
#line 155 "parse.y" /* yacc.c:1646  */
    { (yyval) = cons((yyvsp[-2]), (yyvsp[0])); }
#line 1761 "y.tab.c" /* yacc.c:1646  */
    break;

  case 49:
#line 157 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeif((yyvsp[-4]), (yyvsp[-3]), (yyvsp[-1]), (yyvsp[0])); }
#line 1767 "y.tab.c" /* yacc.c:1646  */
    break;

  case 50:
#line 160 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeprogn((yyvsp[-5]), makefor( 1, (yyvsp[-5]), (yyvsp[-4]), (yyvsp[-3]), (yyvsp[-2]), (yyvsp[-1]), (yyvsp[0]))); }
#line 1773 "y.tab.c" /* yacc.c:1646  */
    break;

  case 51:
#line 162 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeprogn((yyvsp[-5]), makefor(-1, (yyvsp[-5]), (yyvsp[-4]), (yyvsp[-3]), (yyvsp[-2]), (yyvsp[-1]), (yyvsp[0]))); }
#line 1779 "y.tab.c" /* yacc.c:1646  */
    break;

  case 52:
#line 164 "parse.y" /* yacc.c:1646  */
    { (yyval) = makewhile((yyvsp[-3]), (yyvsp[-2]), (yyvsp[-1]), (yyvsp[0])); }
#line 1785 "y.tab.c" /* yacc.c:1646  */
    break;

  case 53:
#line 167 "parse.y" /* yacc.c:1646  */
    { (yyval) = makefuncall((yyvsp[0]), (yyvsp[-3]), (yyvsp[-1])); }
#line 1791 "y.tab.c" /* yacc.c:1646  */
    break;

  case 54:
#line 169 "parse.y" /* yacc.c:1646  */
    { (yyval) = binop((yyvsp[-1]), (yyvsp[-2]), (yyvsp[0])); }
#line 1797 "y.tab.c" /* yacc.c:1646  */
    break;

  case 55:
#line 171 "parse.y" /* yacc.c:1646  */
    { (yyval) = addsymentry((yyvsp[0])); }
#line 1803 "y.tab.c" /* yacc.c:1646  */
    break;

  case 56:
#line 173 "parse.y" /* yacc.c:1646  */
    { (yyval) = makearef((yyvsp[-3]), (yyvsp[-1]), (yyvsp[-2])); }
#line 1809 "y.tab.c" /* yacc.c:1646  */
    break;

  case 57:
#line 175 "parse.y" /* yacc.c:1646  */
    { (yyval) = makemultiaref((yyvsp[-3]), (yyvsp[-1]), (yyvsp[-2])); }
#line 1815 "y.tab.c" /* yacc.c:1646  */
    break;

  case 58:
#line 176 "parse.y" /* yacc.c:1646  */
    { (yyval) = reducedot((yyvsp[-2]), (yyvsp[-1]), (yyvsp[0])); }
#line 1821 "y.tab.c" /* yacc.c:1646  */
    break;

  case 59:
#line 177 "parse.y" /* yacc.c:1646  */
    { (yyval) = reducepoint((yyvsp[-1]), (yyvsp[0])); }
#line 1827 "y.tab.c" /* yacc.c:1646  */
    break;

  case 60:
#line 179 "parse.y" /* yacc.c:1646  */
    { (yyval) = cons((yyvsp[-2]), (yyvsp[0])); }
#line 1833 "y.tab.c" /* yacc.c:1646  */
    break;

  case 61:
#line 180 "parse.y" /* yacc.c:1646  */
    { (yyval) = cons((yyvsp[0]), NULL); }
#line 1839 "y.tab.c" /* yacc.c:1646  */
    break;

  case 62:
#line 182 "parse.y" /* yacc.c:1646  */
    { (yyval) = binop((yyvsp[-1]), (yyvsp[-2]), (yyvsp[0])); }
#line 1845 "y.tab.c" /* yacc.c:1646  */
    break;

  case 63:
#line 183 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1851 "y.tab.c" /* yacc.c:1646  */
    break;

  case 64:
#line 185 "parse.y" /* yacc.c:1646  */
    { (yyval) = maybefloat(binop((yyvsp[-1]), (yyvsp[-2]), (yyvsp[0]))); }
#line 1857 "y.tab.c" /* yacc.c:1646  */
    break;

  case 65:
#line 186 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1863 "y.tab.c" /* yacc.c:1646  */
    break;

  case 66:
#line 187 "parse.y" /* yacc.c:1646  */
    { (yyval) = givesign((yyvsp[-1]),(yyvsp[0])); }
#line 1869 "y.tab.c" /* yacc.c:1646  */
    break;

  case 67:
#line 189 "parse.y" /* yacc.c:1646  */
    { (yyval) = maybefloat(binop((yyvsp[-1]), (yyvsp[-2]), (yyvsp[0]))); }
#line 1875 "y.tab.c" /* yacc.c:1646  */
    break;

  case 68:
#line 190 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1881 "y.tab.c" /* yacc.c:1646  */
    break;

  case 69:
#line 192 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[-1]); }
#line 1887 "y.tab.c" /* yacc.c:1646  */
    break;

  case 70:
#line 193 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1893 "y.tab.c" /* yacc.c:1646  */
    break;

  case 71:
#line 194 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1899 "y.tab.c" /* yacc.c:1646  */
    break;

  case 72:
#line 195 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1905 "y.tab.c" /* yacc.c:1646  */
    break;

  case 73:
#line 196 "parse.y" /* yacc.c:1646  */
    { (yyval) = negate((yyvsp[-1])); }
#line 1911 "y.tab.c" /* yacc.c:1646  */
    break;

  case 74:
#line 198 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1917 "y.tab.c" /* yacc.c:1646  */
    break;

  case 75:
#line 199 "parse.y" /* yacc.c:1646  */
    { (yyval) = makenumbertok(0); }
#line 1923 "y.tab.c" /* yacc.c:1646  */
    break;

  case 76:
#line 200 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1929 "y.tab.c" /* yacc.c:1646  */
    break;

  case 77:
#line 202 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeconst((yyvsp[-1]), (yyvsp[0])); }
#line 1935 "y.tab.c" /* yacc.c:1646  */
    break;

  case 78:
#line 203 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeuconstorvariable((yyvsp[0])); }
#line 1941 "y.tab.c" /* yacc.c:1646  */
    break;

  case 79:
#line 204 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeconst((yyvsp[-1]),(yyvsp[0])); }
#line 1947 "y.tab.c" /* yacc.c:1646  */
    break;

  case 80:
#line 205 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1953 "y.tab.c" /* yacc.c:1646  */
    break;

  case 81:
#line 206 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1959 "y.tab.c" /* yacc.c:1646  */
    break;

  case 82:
#line 208 "parse.y" /* yacc.c:1646  */
    { (yyval) = makeprogn((yyvsp[-1]), dolabel((yyvsp[-2]), (yyvsp[-2]), (yyvsp[0]))); }
#line 1965 "y.tab.c" /* yacc.c:1646  */
    break;

  case 83:
#line 209 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1971 "y.tab.c" /* yacc.c:1646  */
    break;

  case 84:
#line 210 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1977 "y.tab.c" /* yacc.c:1646  */
    break;

  case 85:
#line 212 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1983 "y.tab.c" /* yacc.c:1646  */
    break;

  case 86:
#line 213 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1989 "y.tab.c" /* yacc.c:1646  */
    break;

  case 87:
#line 215 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 1995 "y.tab.c" /* yacc.c:1646  */
    break;

  case 88:
#line 216 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 2001 "y.tab.c" /* yacc.c:1646  */
    break;

  case 89:
#line 217 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 2007 "y.tab.c" /* yacc.c:1646  */
    break;

  case 90:
#line 218 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 2013 "y.tab.c" /* yacc.c:1646  */
    break;

  case 91:
#line 219 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 2019 "y.tab.c" /* yacc.c:1646  */
    break;

  case 92:
#line 220 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 2025 "y.tab.c" /* yacc.c:1646  */
    break;

  case 93:
#line 221 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 2031 "y.tab.c" /* yacc.c:1646  */
    break;

  case 94:
#line 227 "parse.y" /* yacc.c:1646  */
    { (yyval) = cons((yyvsp[-1]), (yyvsp[0])); }
#line 2037 "y.tab.c" /* yacc.c:1646  */
    break;

  case 95:
#line 228 "parse.y" /* yacc.c:1646  */
    { (yyval) = NULL; }
#line 2043 "y.tab.c" /* yacc.c:1646  */
    break;

  case 96:
#line 230 "parse.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[0]); }
#line 2049 "y.tab.c" /* yacc.c:1646  */
    break;

  case 97:
#line 231 "parse.y" /* yacc.c:1646  */
    { (yyval) = NULL; }
#line 2055 "y.tab.c" /* yacc.c:1646  */
    break;


#line 2059 "y.tab.c" /* yacc.c:1646  */
      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = (char *) YYSTACK_ALLOC (yymsg_alloc);
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 234 "parse.y" /* yacc.c:1906  */


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
