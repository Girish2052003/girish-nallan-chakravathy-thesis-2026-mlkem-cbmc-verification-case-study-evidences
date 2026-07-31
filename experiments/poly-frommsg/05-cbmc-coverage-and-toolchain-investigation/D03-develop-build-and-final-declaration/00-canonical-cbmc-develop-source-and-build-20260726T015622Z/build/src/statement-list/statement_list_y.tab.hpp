/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YYSTATEMENT_LIST_WORKSPACE_BUILD_SRC_STATEMENT_LIST_STATEMENT_LIST_Y_TAB_HPP_INCLUDED
# define YY_YYSTATEMENT_LIST_WORKSPACE_BUILD_SRC_STATEMENT_LIST_STATEMENT_LIST_Y_TAB_HPP_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yystatement_listdebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    TOK_VERSION = 258,             /* "VERSION"  */
    TOK_BEGIN = 259,               /* "BEGIN"  */
    TOK_FUNCTION_BLOCK = 260,      /* "FUNCTION_BLOCK"  */
    TOK_END_FUNCTION_BLOCK = 261,  /* "END_FUNCTION_BLOCK"  */
    TOK_FUNCTION = 262,            /* "FUNCTION"  */
    TOK_END_FUNCTION = 263,        /* "END_FUNCTION"  */
    TOK_VAR_INPUT = 264,           /* "VAR_INPUT"  */
    TOK_VAR_INOUT = 265,           /* "VAR_IN_OUT"  */
    TOK_VAR_OUTPUT = 266,          /* "VAR_OUTPUT"  */
    TOK_VAR_STATIC = 267,          /* "VAR"  */
    TOK_VAR_TEMP = 268,            /* "VAR_TEMP"  */
    TOK_VAR_CONSTANT = 269,        /* "VAR CONSTANT"  */
    TOK_END_VAR = 270,             /* "END_VAR"  */
    TOK_NETWORK = 271,             /* "NETWORK"  */
    TOK_TITLE = 272,               /* "TITLE"  */
    TOK_TAG = 273,                 /* "TAG"  */
    TOK_END_TAG = 274,             /* "END_TAG"  */
    TOK_INT = 275,                 /* "Int"  */
    TOK_DINT = 276,                /* "DInt"  */
    TOK_REAL = 277,                /* "Real"  */
    TOK_BOOL = 278,                /* "Bool"  */
    TOK_VOID = 279,                /* "Void"  */
    TOK_LOAD = 280,                /* "L"  */
    TOK_TRANSFER = 281,            /* "T"  */
    TOK_CALL = 282,                /* "CALL"  */
    TOK_NOP = 283,                 /* "NOP"  */
    TOK_SET_RLO = 284,             /* "SET"  */
    TOK_CLR_RLO = 285,             /* "CLR"  */
    TOK_SET = 286,                 /* "S"  */
    TOK_RESET = 287,               /* "R"  */
    TOK_NOT = 288,                 /* "NOT"  */
    TOK_AND = 289,                 /* "A"  */
    TOK_AND_NOT = 290,             /* "AN"  */
    TOK_OR = 291,                  /* "O"  */
    TOK_OR_NOT = 292,              /* "ON"  */
    TOK_XOR = 293,                 /* "X"  */
    TOK_XOR_NOT = 294,             /* "XN"  */
    TOK_AND_NESTED = 295,          /* "A("  */
    TOK_AND_NOT_NESTED = 296,      /* "AN("  */
    TOK_OR_NESTED = 297,           /* "O("  */
    TOK_OR_NOT_NESTED = 298,       /* "ON("  */
    TOK_XOR_NESTED = 299,          /* "X("  */
    TOK_XOR_NOT_NESTED = 300,      /* "XN("  */
    TOK_NESTING_CLOSED = 301,      /* ")"  */
    TOK_ASSIGN = 302,              /* "="  */
    TOK_CONST_ADD = 303,           /* "+"  */
    TOK_ACCU_INT_ADD = 304,        /* "+I"  */
    TOK_ACCU_INT_SUB = 305,        /* "-I"  */
    TOK_ACCU_INT_MUL = 306,        /* "*I"  */
    TOK_ACCU_INT_DIV = 307,        /* "/I"  */
    TOK_ACCU_INT_EQ = 308,         /* "==I"  */
    TOK_ACCU_INT_NEQ = 309,        /* "<>I"  */
    TOK_ACCU_INT_GT = 310,         /* ">I"  */
    TOK_ACCU_INT_LT = 311,         /* "<I"  */
    TOK_ACCU_INT_GTE = 312,        /* ">=I"  */
    TOK_ACCU_INT_LTE = 313,        /* "<=I"  */
    TOK_ACCU_REAL_ADD = 314,       /* "+R"  */
    TOK_ACCU_REAL_SUB = 315,       /* "-R"  */
    TOK_ACCU_REAL_MUL = 316,       /* "*R"  */
    TOK_ACCU_REAL_DIV = 317,       /* "/R"  */
    TOK_ACCU_REAL_EQ = 318,        /* "==R"  */
    TOK_ACCU_REAL_NEQ = 319,       /* "<>R"  */
    TOK_ACCU_REAL_GT = 320,        /* ">R"  */
    TOK_ACCU_REAL_LT = 321,        /* "<R"  */
    TOK_ACCU_REAL_GTE = 322,       /* ">=R"  */
    TOK_ACCU_REAL_LTE = 323,       /* "<=R"  */
    TOK_ACCU_DINT_ADD = 324,       /* "+D"  */
    TOK_ACCU_DINT_SUB = 325,       /* "-D"  */
    TOK_ACCU_DINT_MUL = 326,       /* "*D"  */
    TOK_ACCU_DINT_DIV = 327,       /* "/D"  */
    TOK_ACCU_DINT_EQ = 328,        /* "==D"  */
    TOK_ACCU_DINT_NEQ = 329,       /* "<>D"  */
    TOK_ACCU_DINT_GT = 330,        /* ">D"  */
    TOK_ACCU_DINT_LT = 331,        /* "<D"  */
    TOK_ACCU_DINT_GTE = 332,       /* ">=D"  */
    TOK_ACCU_DINT_LTE = 333,       /* "<=D"  */
    TOK_ASSIGNMENT = 334,          /* ":="  */
    TOK_JUMP_UNCONDITIONAL = 335,  /* "JU"  */
    TOK_JUMP_CONDITIONAL = 336,    /* "JC"  */
    TOK_JUMP_CONDITIONAL_NOT = 337, /* "JCN"  */
    TOK_INT_LITERAL = 338,         /* TOK_INT_LITERAL  */
    TOK_BOOL_LITERAL = 339,        /* TOK_BOOL_LITERAL  */
    TOK_REAL_LITERAL = 340,        /* TOK_REAL_LITERAL  */
    TOK_IDENTIFIER = 341,          /* TOK_IDENTIFIER  */
    TOK_TITLE_VALUE = 342,         /* TOK_TITLE_VALUE  */
    TOK_VERSION_VALUE = 343,       /* TOK_VERSION_VALUE  */
    TOK_LABEL = 344                /* TOK_LABEL  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yystatement_listlval;


int yystatement_listparse (statement_list_parsert &statement_list_parser, void *scanner);


#endif /* !YY_YYSTATEMENT_LIST_WORKSPACE_BUILD_SRC_STATEMENT_LIST_STATEMENT_LIST_Y_TAB_HPP_INCLUDED  */
