/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1


/* Substitute the variable and function names.  */
#define yyparse         yystatement_listparse
#define yylex           yystatement_listlex
#define yyerror         yystatement_listerror
#define yydebug         yystatement_listdebug
#define yynerrs         yystatement_listnerrs
#define yylval          yystatement_listlval
#define yychar          yystatement_listchar

/* First part of user prologue.  */
#line 1 "/workspace/source/src/statement-list/parser.y"


// This parser is based on the IEC standard 61131-3 which, among other things,
// includes a BNF grammar for the Instruction List (IL) language. The
// Statement List language (STL) by Siemens complies with the standards 
// defined by the IEC, although some modifications were made for compatibility
// reasons. As a consequence, the general language structure specified by the 
// IEC is similar to the structure of STL, but there are differences between
// their syntax and some language features (In general, Siemens implements more
// language features in STL than described in the standard).

#ifdef STATEMENT_LIST_DEBUG
#define YYDEBUG 1
#endif
#define PARSER statement_list_parser

#include "statement_list_parser.h"
#include "converters/convert_string_value.h"
#include "converters/statement_list_types.h"

#include <util/bitvector_types.h>
#include <util/std_code.h>

#include <iterator>

int yystatement_listlex(void *);
char *yystatement_listget_text(void *);

int yystatement_listerror(
  statement_list_parsert &statement_list_parser,
  void *scanner,
  const std::string &error)
{
  statement_list_parser.parse_error(error, yystatement_listget_text(scanner));
  return 0;
}

#define YYSTYPE unsigned
#define YYSTYPE_IS_TRIVIAL 1

#include "statement_list_y.tab.h"

// Visual Studio
#ifdef _MSC_VER
// Disable warnings for possible loss of data.
#pragma warning(disable:4242)
#pragma warning(disable:4244)
// Disable warning for signed/unsigned mismatch.
#pragma warning(disable:4365)
// Disable warning for switch with default but no case labels.
#pragma warning(disable:4065)
// Disable warning for unreachable code.
#pragma warning(disable:4702)
#endif
#line 162 "/workspace/source/src/statement-list/parser.y"

/*** Grammar rules ***********************************************************/

// The follwing abbreviations will be used:
//   Zom: "Zero or more", eqivalent to the '*' quantifier
//   Opt: "Optional", equivalent to the '?' quantifier
//   Oom: "One or more", equivalent to the '+' quantifier

#line 142 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

#include "statement_list_y.tab.hpp"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_TOK_VERSION = 3,                /* "VERSION"  */
  YYSYMBOL_TOK_BEGIN = 4,                  /* "BEGIN"  */
  YYSYMBOL_TOK_FUNCTION_BLOCK = 5,         /* "FUNCTION_BLOCK"  */
  YYSYMBOL_TOK_END_FUNCTION_BLOCK = 6,     /* "END_FUNCTION_BLOCK"  */
  YYSYMBOL_TOK_FUNCTION = 7,               /* "FUNCTION"  */
  YYSYMBOL_TOK_END_FUNCTION = 8,           /* "END_FUNCTION"  */
  YYSYMBOL_TOK_VAR_INPUT = 9,              /* "VAR_INPUT"  */
  YYSYMBOL_TOK_VAR_INOUT = 10,             /* "VAR_IN_OUT"  */
  YYSYMBOL_TOK_VAR_OUTPUT = 11,            /* "VAR_OUTPUT"  */
  YYSYMBOL_TOK_VAR_STATIC = 12,            /* "VAR"  */
  YYSYMBOL_TOK_VAR_TEMP = 13,              /* "VAR_TEMP"  */
  YYSYMBOL_TOK_VAR_CONSTANT = 14,          /* "VAR CONSTANT"  */
  YYSYMBOL_TOK_END_VAR = 15,               /* "END_VAR"  */
  YYSYMBOL_TOK_NETWORK = 16,               /* "NETWORK"  */
  YYSYMBOL_TOK_TITLE = 17,                 /* "TITLE"  */
  YYSYMBOL_TOK_TAG = 18,                   /* "TAG"  */
  YYSYMBOL_TOK_END_TAG = 19,               /* "END_TAG"  */
  YYSYMBOL_TOK_INT = 20,                   /* "Int"  */
  YYSYMBOL_TOK_DINT = 21,                  /* "DInt"  */
  YYSYMBOL_TOK_REAL = 22,                  /* "Real"  */
  YYSYMBOL_TOK_BOOL = 23,                  /* "Bool"  */
  YYSYMBOL_TOK_VOID = 24,                  /* "Void"  */
  YYSYMBOL_TOK_LOAD = 25,                  /* "L"  */
  YYSYMBOL_TOK_TRANSFER = 26,              /* "T"  */
  YYSYMBOL_TOK_CALL = 27,                  /* "CALL"  */
  YYSYMBOL_TOK_NOP = 28,                   /* "NOP"  */
  YYSYMBOL_TOK_SET_RLO = 29,               /* "SET"  */
  YYSYMBOL_TOK_CLR_RLO = 30,               /* "CLR"  */
  YYSYMBOL_TOK_SET = 31,                   /* "S"  */
  YYSYMBOL_TOK_RESET = 32,                 /* "R"  */
  YYSYMBOL_TOK_NOT = 33,                   /* "NOT"  */
  YYSYMBOL_TOK_AND = 34,                   /* "A"  */
  YYSYMBOL_TOK_AND_NOT = 35,               /* "AN"  */
  YYSYMBOL_TOK_OR = 36,                    /* "O"  */
  YYSYMBOL_TOK_OR_NOT = 37,                /* "ON"  */
  YYSYMBOL_TOK_XOR = 38,                   /* "X"  */
  YYSYMBOL_TOK_XOR_NOT = 39,               /* "XN"  */
  YYSYMBOL_TOK_AND_NESTED = 40,            /* "A("  */
  YYSYMBOL_TOK_AND_NOT_NESTED = 41,        /* "AN("  */
  YYSYMBOL_TOK_OR_NESTED = 42,             /* "O("  */
  YYSYMBOL_TOK_OR_NOT_NESTED = 43,         /* "ON("  */
  YYSYMBOL_TOK_XOR_NESTED = 44,            /* "X("  */
  YYSYMBOL_TOK_XOR_NOT_NESTED = 45,        /* "XN("  */
  YYSYMBOL_TOK_NESTING_CLOSED = 46,        /* ")"  */
  YYSYMBOL_TOK_ASSIGN = 47,                /* "="  */
  YYSYMBOL_TOK_CONST_ADD = 48,             /* "+"  */
  YYSYMBOL_TOK_ACCU_INT_ADD = 49,          /* "+I"  */
  YYSYMBOL_TOK_ACCU_INT_SUB = 50,          /* "-I"  */
  YYSYMBOL_TOK_ACCU_INT_MUL = 51,          /* "*I"  */
  YYSYMBOL_TOK_ACCU_INT_DIV = 52,          /* "/I"  */
  YYSYMBOL_TOK_ACCU_INT_EQ = 53,           /* "==I"  */
  YYSYMBOL_TOK_ACCU_INT_NEQ = 54,          /* "<>I"  */
  YYSYMBOL_TOK_ACCU_INT_GT = 55,           /* ">I"  */
  YYSYMBOL_TOK_ACCU_INT_LT = 56,           /* "<I"  */
  YYSYMBOL_TOK_ACCU_INT_GTE = 57,          /* ">=I"  */
  YYSYMBOL_TOK_ACCU_INT_LTE = 58,          /* "<=I"  */
  YYSYMBOL_TOK_ACCU_REAL_ADD = 59,         /* "+R"  */
  YYSYMBOL_TOK_ACCU_REAL_SUB = 60,         /* "-R"  */
  YYSYMBOL_TOK_ACCU_REAL_MUL = 61,         /* "*R"  */
  YYSYMBOL_TOK_ACCU_REAL_DIV = 62,         /* "/R"  */
  YYSYMBOL_TOK_ACCU_REAL_EQ = 63,          /* "==R"  */
  YYSYMBOL_TOK_ACCU_REAL_NEQ = 64,         /* "<>R"  */
  YYSYMBOL_TOK_ACCU_REAL_GT = 65,          /* ">R"  */
  YYSYMBOL_TOK_ACCU_REAL_LT = 66,          /* "<R"  */
  YYSYMBOL_TOK_ACCU_REAL_GTE = 67,         /* ">=R"  */
  YYSYMBOL_TOK_ACCU_REAL_LTE = 68,         /* "<=R"  */
  YYSYMBOL_TOK_ACCU_DINT_ADD = 69,         /* "+D"  */
  YYSYMBOL_TOK_ACCU_DINT_SUB = 70,         /* "-D"  */
  YYSYMBOL_TOK_ACCU_DINT_MUL = 71,         /* "*D"  */
  YYSYMBOL_TOK_ACCU_DINT_DIV = 72,         /* "/D"  */
  YYSYMBOL_TOK_ACCU_DINT_EQ = 73,          /* "==D"  */
  YYSYMBOL_TOK_ACCU_DINT_NEQ = 74,         /* "<>D"  */
  YYSYMBOL_TOK_ACCU_DINT_GT = 75,          /* ">D"  */
  YYSYMBOL_TOK_ACCU_DINT_LT = 76,          /* "<D"  */
  YYSYMBOL_TOK_ACCU_DINT_GTE = 77,         /* ">=D"  */
  YYSYMBOL_TOK_ACCU_DINT_LTE = 78,         /* "<=D"  */
  YYSYMBOL_TOK_ASSIGNMENT = 79,            /* ":="  */
  YYSYMBOL_TOK_JUMP_UNCONDITIONAL = 80,    /* "JU"  */
  YYSYMBOL_TOK_JUMP_CONDITIONAL = 81,      /* "JC"  */
  YYSYMBOL_TOK_JUMP_CONDITIONAL_NOT = 82,  /* "JCN"  */
  YYSYMBOL_TOK_INT_LITERAL = 83,           /* TOK_INT_LITERAL  */
  YYSYMBOL_TOK_BOOL_LITERAL = 84,          /* TOK_BOOL_LITERAL  */
  YYSYMBOL_TOK_REAL_LITERAL = 85,          /* TOK_REAL_LITERAL  */
  YYSYMBOL_TOK_IDENTIFIER = 86,            /* TOK_IDENTIFIER  */
  YYSYMBOL_TOK_TITLE_VALUE = 87,           /* TOK_TITLE_VALUE  */
  YYSYMBOL_TOK_VERSION_VALUE = 88,         /* TOK_VERSION_VALUE  */
  YYSYMBOL_TOK_LABEL = 89,                 /* TOK_LABEL  */
  YYSYMBOL_90_ = 90,                       /* ':'  */
  YYSYMBOL_91_ = 91,                       /* ','  */
  YYSYMBOL_92_ = 92,                       /* ';'  */
  YYSYMBOL_93_ = 93,                       /* '#'  */
  YYSYMBOL_94_ = 94,                       /* '('  */
  YYSYMBOL_YYACCEPT = 95,                  /* $accept  */
  YYSYMBOL_init = 96,                      /* init  */
  YYSYMBOL_Var_Decl_Init = 97,             /* Var_Decl_Init  */
  YYSYMBOL_Variable_List = 98,             /* Variable_List  */
  YYSYMBOL_Zom_Separated_Variable_Name = 99, /* Zom_Separated_Variable_Name  */
  YYSYMBOL_Variable_Name = 100,            /* Variable_Name  */
  YYSYMBOL_Simple_Spec_Init = 101,         /* Simple_Spec_Init  */
  YYSYMBOL_Simple_Spec = 102,              /* Simple_Spec  */
  YYSYMBOL_Elem_Type_Name = 103,           /* Elem_Type_Name  */
  YYSYMBOL_Numeric_Type_Name = 104,        /* Numeric_Type_Name  */
  YYSYMBOL_Int_Type_Name = 105,            /* Int_Type_Name  */
  YYSYMBOL_Sign_Int_Type_Name = 106,       /* Sign_Int_Type_Name  */
  YYSYMBOL_DInt_Type_Name = 107,           /* DInt_Type_Name  */
  YYSYMBOL_Sign_DInt_Type_Name = 108,      /* Sign_DInt_Type_Name  */
  YYSYMBOL_Real_Type_Name = 109,           /* Real_Type_Name  */
  YYSYMBOL_Bool_Type_Name = 110,           /* Bool_Type_Name  */
  YYSYMBOL_Opt_Assignment = 111,           /* Opt_Assignment  */
  YYSYMBOL_Derived_FB_Name = 112,          /* Derived_FB_Name  */
  YYSYMBOL_FB_Decl = 113,                  /* FB_Decl  */
  YYSYMBOL_Version_Label = 114,            /* Version_Label  */
  YYSYMBOL_Zom_FB_General_Var_Decls = 115, /* Zom_FB_General_Var_Decls  */
  YYSYMBOL_FB_General_Var_Decl = 116,      /* FB_General_Var_Decl  */
  YYSYMBOL_FB_IO_Var_Decls = 117,          /* FB_IO_Var_Decls  */
  YYSYMBOL_FB_Input_Decls = 118,           /* FB_Input_Decls  */
  YYSYMBOL_Zom_FB_Input_Decl = 119,        /* Zom_FB_Input_Decl  */
  YYSYMBOL_FB_Input_Decl = 120,            /* FB_Input_Decl  */
  YYSYMBOL_FB_Output_Decls = 121,          /* FB_Output_Decls  */
  YYSYMBOL_Zom_FB_Output_Decl = 122,       /* Zom_FB_Output_Decl  */
  YYSYMBOL_FB_Output_Decl = 123,           /* FB_Output_Decl  */
  YYSYMBOL_FB_Inout_Decls = 124,           /* FB_Inout_Decls  */
  YYSYMBOL_Zom_FB_Inout_Decl = 125,        /* Zom_FB_Inout_Decl  */
  YYSYMBOL_FB_Inout_Decl = 126,            /* FB_Inout_Decl  */
  YYSYMBOL_FB_Static_Decls = 127,          /* FB_Static_Decls  */
  YYSYMBOL_Zom_FB_Static_Decl = 128,       /* Zom_FB_Static_Decl  */
  YYSYMBOL_FB_Static_Decl = 129,           /* FB_Static_Decl  */
  YYSYMBOL_FB_Body = 130,                  /* FB_Body  */
  YYSYMBOL_Func_Decl = 131,                /* Func_Decl  */
  YYSYMBOL_Derived_Func_Name = 132,        /* Derived_Func_Name  */
  YYSYMBOL_Func_Return_Value = 133,        /* Func_Return_Value  */
  YYSYMBOL_Zom_Func_General_Var_Decls = 134, /* Zom_Func_General_Var_Decls  */
  YYSYMBOL_Func_General_Var_Decl = 135,    /* Func_General_Var_Decl  */
  YYSYMBOL_IO_Var_Decls = 136,             /* IO_Var_Decls  */
  YYSYMBOL_Input_Decls = 137,              /* Input_Decls  */
  YYSYMBOL_Zom_Input_Decl = 138,           /* Zom_Input_Decl  */
  YYSYMBOL_Input_Decl = 139,               /* Input_Decl  */
  YYSYMBOL_Inout_Decls = 140,              /* Inout_Decls  */
  YYSYMBOL_Zom_Inout_Decl = 141,           /* Zom_Inout_Decl  */
  YYSYMBOL_Inout_Decl = 142,               /* Inout_Decl  */
  YYSYMBOL_Output_Decls = 143,             /* Output_Decls  */
  YYSYMBOL_Zom_Output_Decl = 144,          /* Zom_Output_Decl  */
  YYSYMBOL_Output_Decl = 145,              /* Output_Decl  */
  YYSYMBOL_Temp_Decls = 146,               /* Temp_Decls  */
  YYSYMBOL_Zom_Temp_Decl = 147,            /* Zom_Temp_Decl  */
  YYSYMBOL_Temp_Decl = 148,                /* Temp_Decl  */
  YYSYMBOL_Constant_Decls = 149,           /* Constant_Decls  */
  YYSYMBOL_Zom_Constant_Decl = 150,        /* Zom_Constant_Decl  */
  YYSYMBOL_Constant_Decl = 151,            /* Constant_Decl  */
  YYSYMBOL_Func_Body = 152,                /* Func_Body  */
  YYSYMBOL_Zom_IL_Network = 153,           /* Zom_IL_Network  */
  YYSYMBOL_IL_Network = 154,               /* IL_Network  */
  YYSYMBOL_Opt_TITLE_VALUE = 155,          /* Opt_TITLE_VALUE  */
  YYSYMBOL_Opt_Instruction_List = 156,     /* Opt_Instruction_List  */
  YYSYMBOL_Instruction_List = 157,         /* Instruction_List  */
  YYSYMBOL_Oom_IL_Instruction = 158,       /* Oom_IL_Instruction  */
  YYSYMBOL_IL_Instruction = 159,           /* IL_Instruction  */
  YYSYMBOL_Opt_Label = 160,                /* Opt_Label  */
  YYSYMBOL_IL_Label = 161,                 /* IL_Label  */
  YYSYMBOL_Instruction = 162,              /* Instruction  */
  YYSYMBOL_IL_Simple_Operation = 163,      /* IL_Simple_Operation  */
  YYSYMBOL_Opt_Operand = 164,              /* Opt_Operand  */
  YYSYMBOL_IL_Simple_Operator = 165,       /* IL_Simple_Operator  */
  YYSYMBOL_IL_Operand = 166,               /* IL_Operand  */
  YYSYMBOL_Variable_Access = 167,          /* Variable_Access  */
  YYSYMBOL_Constant = 168,                 /* Constant  */
  YYSYMBOL_IL_Invocation = 169,            /* IL_Invocation  */
  YYSYMBOL_Call = 170,                     /* Call  */
  YYSYMBOL_Callee_Name = 171,              /* Callee_Name  */
  YYSYMBOL_Opt_Param_List = 172,           /* Opt_Param_List  */
  YYSYMBOL_Oom_Param_Assignment = 173,     /* Oom_Param_Assignment  */
  YYSYMBOL_Param_Assignment = 174,         /* Param_Assignment  */
  YYSYMBOL_Opt_Data_Block = 175,           /* Opt_Data_Block  */
  YYSYMBOL_Tag_Decl = 176,                 /* Tag_Decl  */
  YYSYMBOL_Opt_Tag_List = 177,             /* Opt_Tag_List  */
  YYSYMBOL_Tag_List = 178                  /* Tag_List  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_uint8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

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


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
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

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

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
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
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
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  2
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   230

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  95
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  84
/* YYNRULES -- Number of rules.  */
#define YYNRULES  184
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  238

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   344


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,    93,     2,     2,     2,     2,
      94,     2,     2,     2,    91,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    90,    92,
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
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   173,   173,   174,   175,   176,   181,   190,   198,   204,
     212,   221,   225,   229,   233,   234,   235,   236,   240,   244,
     252,   256,   264,   272,   279,   284,   290,   294,   308,   315,
     321,   328,   329,   330,   331,   335,   336,   337,   341,   348,
     354,   361,   369,   376,   382,   389,   397,   404,   410,   417,
     425,   432,   438,   445,   453,   461,   475,   479,   483,   490,
     496,   503,   504,   505,   509,   510,   511,   515,   522,   528,
     535,   539,   546,   552,   559,   563,   570,   576,   583,   587,
     594,   600,   607,   611,   618,   624,   631,   639,   647,   653,
     660,   671,   673,   680,   682,   690,   694,   699,   708,   716,
     718,   725,   729,   730,   734,   744,   746,   753,   758,   763,
     768,   773,   778,   783,   788,   793,   798,   803,   808,   813,
     818,   823,   828,   833,   838,   843,   848,   853,   858,   863,
     868,   873,   878,   883,   888,   893,   898,   903,   908,   913,
     918,   923,   928,   933,   938,   943,   948,   953,   958,   963,
     968,   973,   978,   983,   988,   993,   998,  1003,  1008,  1013,
    1018,  1023,  1028,  1036,  1037,  1041,  1045,  1052,  1053,  1054,
    1058,  1071,  1079,  1088,  1093,  1099,  1104,  1112,  1120,  1127,
    1134,  1141,  1143,  1149,  1155
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "\"VERSION\"",
  "\"BEGIN\"", "\"FUNCTION_BLOCK\"", "\"END_FUNCTION_BLOCK\"",
  "\"FUNCTION\"", "\"END_FUNCTION\"", "\"VAR_INPUT\"", "\"VAR_IN_OUT\"",
  "\"VAR_OUTPUT\"", "\"VAR\"", "\"VAR_TEMP\"", "\"VAR CONSTANT\"",
  "\"END_VAR\"", "\"NETWORK\"", "\"TITLE\"", "\"TAG\"", "\"END_TAG\"",
  "\"Int\"", "\"DInt\"", "\"Real\"", "\"Bool\"", "\"Void\"", "\"L\"",
  "\"T\"", "\"CALL\"", "\"NOP\"", "\"SET\"", "\"CLR\"", "\"S\"", "\"R\"",
  "\"NOT\"", "\"A\"", "\"AN\"", "\"O\"", "\"ON\"", "\"X\"", "\"XN\"",
  "\"A(\"", "\"AN(\"", "\"O(\"", "\"ON(\"", "\"X(\"", "\"XN(\"", "\")\"",
  "\"=\"", "\"+\"", "\"+I\"", "\"-I\"", "\"*I\"", "\"/I\"", "\"==I\"",
  "\"<>I\"", "\">I\"", "\"<I\"", "\">=I\"", "\"<=I\"", "\"+R\"", "\"-R\"",
  "\"*R\"", "\"/R\"", "\"==R\"", "\"<>R\"", "\">R\"", "\"<R\"", "\">=R\"",
  "\"<=R\"", "\"+D\"", "\"-D\"", "\"*D\"", "\"/D\"", "\"==D\"", "\"<>D\"",
  "\">D\"", "\"<D\"", "\">=D\"", "\"<=D\"", "\":=\"", "\"JU\"", "\"JC\"",
  "\"JCN\"", "TOK_INT_LITERAL", "TOK_BOOL_LITERAL", "TOK_REAL_LITERAL",
  "TOK_IDENTIFIER", "TOK_TITLE_VALUE", "TOK_VERSION_VALUE", "TOK_LABEL",
  "':'", "','", "';'", "'#'", "'('", "$accept", "init", "Var_Decl_Init",
  "Variable_List", "Zom_Separated_Variable_Name", "Variable_Name",
  "Simple_Spec_Init", "Simple_Spec", "Elem_Type_Name", "Numeric_Type_Name",
  "Int_Type_Name", "Sign_Int_Type_Name", "DInt_Type_Name",
  "Sign_DInt_Type_Name", "Real_Type_Name", "Bool_Type_Name",
  "Opt_Assignment", "Derived_FB_Name", "FB_Decl", "Version_Label",
  "Zom_FB_General_Var_Decls", "FB_General_Var_Decl", "FB_IO_Var_Decls",
  "FB_Input_Decls", "Zom_FB_Input_Decl", "FB_Input_Decl",
  "FB_Output_Decls", "Zom_FB_Output_Decl", "FB_Output_Decl",
  "FB_Inout_Decls", "Zom_FB_Inout_Decl", "FB_Inout_Decl",
  "FB_Static_Decls", "Zom_FB_Static_Decl", "FB_Static_Decl", "FB_Body",
  "Func_Decl", "Derived_Func_Name", "Func_Return_Value",
  "Zom_Func_General_Var_Decls", "Func_General_Var_Decl", "IO_Var_Decls",
  "Input_Decls", "Zom_Input_Decl", "Input_Decl", "Inout_Decls",
  "Zom_Inout_Decl", "Inout_Decl", "Output_Decls", "Zom_Output_Decl",
  "Output_Decl", "Temp_Decls", "Zom_Temp_Decl", "Temp_Decl",
  "Constant_Decls", "Zom_Constant_Decl", "Constant_Decl", "Func_Body",
  "Zom_IL_Network", "IL_Network", "Opt_TITLE_VALUE",
  "Opt_Instruction_List", "Instruction_List", "Oom_IL_Instruction",
  "IL_Instruction", "Opt_Label", "IL_Label", "Instruction",
  "IL_Simple_Operation", "Opt_Operand", "IL_Simple_Operator", "IL_Operand",
  "Variable_Access", "Constant", "IL_Invocation", "Call", "Callee_Name",
  "Opt_Param_List", "Oom_Param_Assignment", "Param_Assignment",
  "Opt_Data_Block", "Tag_Decl", "Opt_Tag_List", "Tag_List", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-121)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-96)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int8 yypact[] =
{
    -121,    15,  -121,   -65,   -63,   -62,  -121,  -121,  -121,  -121,
      27,  -121,   -58,  -121,    48,    16,   -62,   -54,  -121,    43,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,    48,   -50,    35,  -121,  -121,
      27,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,    44,  -121,  -121,  -121,
      57,   -14,    -9,    -8,    -7,    -6,     1,  -121,    47,    58,
    -121,  -121,    12,   -16,  -121,     0,  -121,    12,     5,  -121,
      12,     6,  -121,    12,     7,  -121,  -121,     8,  -121,    12,
       9,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,    68,    46,   -43,  -121,    48,    11,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,    57,     2,
       3,     4,  -121,    17,  -121,  -121,  -121,  -121,  -121,   -62,
    -121,  -121,    13,  -121,  -121,    14,  -121,  -121,    18,  -121,
      -4,  -121,  -121,  -121,  -121,  -121,  -121,  -121,    -3,  -121,
     100,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
      19,  -121,   -31,  -121,   -63,  -121,   -62,  -121,  -121,  -121,
    -121,  -121,  -121,    21,  -121,   -62,    20,  -121,   -62,  -121,
      24,   -32,  -121,   -31,  -121,   -62,  -121,  -121
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       5,     0,     1,     0,     0,   182,     2,     3,     4,    26,
       0,    56,     0,    10,     0,     0,   181,     0,    30,     0,
      19,    21,    22,    23,   184,    11,    12,    13,    14,    18,
      15,    20,    16,    17,   180,     0,     0,     0,    57,    58,
       0,   183,    28,    89,    40,    48,    44,    52,    81,    85,
      29,    31,    35,    36,    37,    32,     0,    33,    34,    60,
      54,     0,     0,     0,     0,     0,     0,    27,     0,     0,
      88,    38,    25,     0,     9,     0,    46,    25,     0,    42,
      25,     0,    50,    25,     0,    79,    82,     0,    83,    25,
       0,    89,    69,    73,    77,    59,    61,    64,    66,    65,
      62,    63,     0,     0,     0,    41,     0,     7,    39,    49,
      47,    45,    43,    53,    51,    80,    86,    84,    87,     0,
       0,     0,    55,    92,   167,   168,   169,    24,     6,     0,
      67,    70,     0,    71,    74,     0,    75,    78,     0,    91,
     100,     8,    68,    72,    76,   101,    90,    93,   100,    97,
       0,    99,    96,   107,   108,   171,   109,   155,   156,   157,
     158,   159,   141,   142,   143,   144,   145,   146,   147,   148,
     149,   150,   151,   152,   153,   154,   110,   111,   112,   113,
     114,   115,   116,   117,   118,   119,   120,   121,   122,   123,
     124,   125,   126,   127,   128,   129,   130,   131,   132,   133,
     134,   135,   136,   137,   138,   139,   140,   160,   161,   162,
       0,   102,   106,   103,     0,    98,     0,   166,   104,   105,
     164,   163,   172,   179,   165,     0,   174,   178,     0,   170,
       0,     0,   176,     0,   173,     0,   177,   175
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
    -121,  -121,   -37,  -121,  -121,    -5,   -25,    75,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,   -46,  -121,  -121,    55,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -118,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,    39,  -121,  -121,    40,  -121,  -121,  -121,    22,  -121,
    -121,  -121,  -121,  -121,   -39,  -121,  -121,  -121,  -121,  -121,
    -121,  -117,  -121,    79,  -121,  -121,  -121,  -121,  -121,  -120,
    -121,  -121,  -121,  -121
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_uint8 yydefgoto[] =
{
       0,     1,    72,    73,   107,    74,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,   105,    10,     6,    18,
      37,    50,    51,    52,    61,    75,    53,    63,    81,    54,
      62,    78,    55,    64,    84,    56,     7,    12,    40,    68,
      95,    96,    97,   119,   132,    98,   120,   135,    99,   121,
     138,    57,    65,    87,    58,    66,    90,   102,    60,    70,
     140,   146,   147,   148,   149,   150,   151,   210,   211,   218,
     212,   219,   220,   221,   213,   214,   223,   229,   231,   232,
     226,     8,    15,    16
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      14,    71,   -94,   -95,   -94,   -95,    76,    79,    82,    85,
      41,    35,   -94,   -95,   234,     2,    88,   130,   133,   136,
       3,     9,     4,    11,    13,    77,    80,    83,    86,    89,
      17,   109,    19,     5,   111,    34,    36,   113,    42,    43,
     124,   125,   126,   116,    44,    45,    46,    47,    48,    49,
      67,    91,   124,   125,   126,    13,    92,    93,    94,   235,
      48,    49,   216,    20,    21,    22,    23,    38,    20,    21,
      22,    23,    13,    69,   106,   103,   122,    13,    13,    13,
      13,   128,   131,   134,   137,   145,   145,    13,    13,    13,
      13,   104,   108,   123,    39,    59,   222,   110,   112,   114,
     115,   117,   129,   233,   139,   142,   143,   100,   101,   152,
     144,   215,   225,   118,   228,   237,   236,     0,     0,     0,
       0,     0,     0,     0,   141,   153,   154,   155,   156,   157,
     158,   159,   160,   161,   162,   163,   164,   165,   166,   167,
     168,   169,   170,   171,   172,   173,   174,   175,   176,   177,
     178,   179,   180,   181,   182,   183,   184,   185,   186,   187,
     188,   189,   190,   191,   192,   193,   194,   195,   196,   197,
     198,   199,   200,   201,   202,   203,   204,   205,   206,     0,
     207,   208,   209,   127,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   217,     0,     0,
       0,   224,     0,     0,     0,     0,     0,     0,     0,     0,
     227,     0,     0,   230,     0,     0,     0,     0,   217,     0,
     230
};

static const yytype_int16 yycheck[] =
{
       5,    15,     6,     6,     8,     8,    15,    15,    15,    15,
      35,    16,    16,    16,    46,     0,    15,    15,    15,    15,
       5,    86,     7,    86,    86,    62,    63,    64,    65,    66,
       3,    77,    90,    18,    80,    19,    90,    83,    88,     4,
      83,    84,    85,    89,     9,    10,    11,    12,    13,    14,
       6,     4,    83,    84,    85,    86,     9,    10,    11,    91,
      13,    14,    93,    20,    21,    22,    23,    24,    20,    21,
      22,    23,    86,    16,    90,    17,     8,    86,    86,    86,
      86,   106,   119,   120,   121,    89,    89,    86,    86,    86,
      86,    79,    92,    47,    19,    40,   214,    92,    92,    92,
      92,    92,    91,    79,    87,    92,    92,    68,    68,   148,
      92,    92,    91,    91,    94,   235,   233,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   129,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    65,    66,    67,    68,    69,
      70,    71,    72,    73,    74,    75,    76,    77,    78,    -1,
      80,    81,    82,   104,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   212,    -1,    -1,
      -1,   216,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     225,    -1,    -1,   228,    -1,    -1,    -1,    -1,   233,    -1,
     235
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    96,     0,     5,     7,    18,   113,   131,   176,    86,
     112,    86,   132,    86,   100,   177,   178,     3,   114,    90,
      20,    21,    22,    23,   101,   102,   103,   104,   105,   106,
     107,   108,   109,   110,    19,   100,    90,   115,    24,   102,
     133,   101,    88,     4,     9,    10,    11,    12,    13,    14,
     116,   117,   118,   121,   124,   127,   130,   146,   149,   114,
     153,   119,   125,   122,   128,   147,   150,     6,   134,    16,
     154,    15,    97,    98,   100,   120,    15,    97,   126,    15,
      97,   123,    15,    97,   129,    15,    97,   148,    15,    97,
     151,     4,     9,    10,    11,   135,   136,   137,   140,   143,
     146,   149,   152,    17,    79,   111,    90,    99,    92,   111,
      92,   111,    92,   111,    92,    92,   111,    92,   153,   138,
     141,   144,     8,    47,    83,    84,    85,   168,   101,    91,
      15,    97,   139,    15,    97,   142,    15,    97,   145,    87,
     155,   100,    92,    92,    92,    89,   156,   157,   158,   159,
     160,   161,   159,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    61,
      62,    63,    64,    65,    66,    67,    68,    69,    70,    71,
      72,    73,    74,    75,    76,    77,    78,    80,    81,    82,
     162,   163,   165,   169,   170,    92,    93,   100,   164,   166,
     167,   168,   132,   171,   100,    91,   175,   100,    94,   172,
     100,   173,   174,    79,    46,    91,   166,   174
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_uint8 yyr1[] =
{
       0,    95,    96,    96,    96,    96,    97,    98,    99,    99,
     100,   101,   102,   103,   104,   104,   104,   104,   105,   106,
     107,   108,   109,   110,   111,   111,   112,   113,   114,   115,
     115,   116,   116,   116,   116,   117,   117,   117,   118,   119,
     119,   120,   121,   122,   122,   123,   124,   125,   125,   126,
     127,   128,   128,   129,   130,   131,   132,   133,   133,   134,
     134,   135,   135,   135,   136,   136,   136,   137,   138,   138,
     139,   140,   141,   141,   142,   143,   144,   144,   145,   146,
     147,   147,   148,   149,   150,   150,   151,   152,   153,   153,
     154,   155,   155,   156,   156,   157,   158,   158,   159,   160,
     160,   161,   162,   162,   163,   164,   164,   165,   165,   165,
     165,   165,   165,   165,   165,   165,   165,   165,   165,   165,
     165,   165,   165,   165,   165,   165,   165,   165,   165,   165,
     165,   165,   165,   165,   165,   165,   165,   165,   165,   165,
     165,   165,   165,   165,   165,   165,   165,   165,   165,   165,
     165,   165,   165,   165,   165,   165,   165,   165,   165,   165,
     165,   165,   165,   166,   166,   167,   167,   168,   168,   168,
     169,   170,   171,   172,   172,   173,   173,   174,   175,   175,
     176,   177,   177,   178,   178
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     2,     2,     2,     0,     3,     2,     3,     0,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     2,     0,     1,     6,     3,     2,
       0,     1,     1,     1,     1,     1,     1,     1,     3,     3,
       0,     2,     3,     3,     0,     2,     3,     3,     0,     2,
       3,     3,     0,     2,     2,     8,     1,     1,     1,     2,
       0,     1,     1,     1,     1,     1,     1,     3,     3,     0,
       1,     3,     3,     0,     1,     3,     3,     0,     1,     3,
       3,     0,     1,     3,     3,     0,     2,     2,     2,     0,
       5,     1,     0,     1,     0,     1,     2,     1,     3,     1,
       0,     1,     1,     1,     2,     1,     0,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     2,     1,     1,     1,     1,
       4,     1,     1,     3,     0,     3,     1,     3,     2,     0,
       3,     1,     0,     3,     2
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
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
        yyerror (statement_list_parser, scanner, YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


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




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value, statement_list_parser, scanner); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, statement_list_parsert &statement_list_parser, void *scanner)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  YY_USE (statement_list_parser);
  YY_USE (scanner);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, statement_list_parsert &statement_list_parser, void *scanner)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep, statement_list_parser, scanner);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
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
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule, statement_list_parsert &statement_list_parser, void *scanner)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)], statement_list_parser, scanner);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule, statement_list_parser, scanner); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
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






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep, statement_list_parsert &statement_list_parser, void *scanner)
{
  YY_USE (yyvaluep);
  YY_USE (statement_list_parser);
  YY_USE (scanner);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (statement_list_parsert &statement_list_parser, void *scanner)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


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

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex (scanner);
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
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
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
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
| yyreduce -- do a reduction.  |
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
  case 6: /* Var_Decl_Init: Variable_List ':' Simple_Spec_Init  */
#line 182 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      for(auto &sym : parser_stack(yyval).operands())
        sym = symbol_exprt(sym.get(ID_identifier), parser_stack(yyvsp[0]).type());
    }
#line 1533 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 7: /* Variable_List: Variable_Name Zom_Separated_Variable_Name  */
#line 191 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1542 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 8: /* Zom_Separated_Variable_Name: Zom_Separated_Variable_Name ',' Variable_Name  */
#line 199 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 1551 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 9: /* Zom_Separated_Variable_Name: %empty  */
#line 204 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_entry);
      
    }
#line 1561 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 10: /* Variable_Name: TOK_IDENTIFIER  */
#line 213 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval) = 
      symbol_exprt::typeless(parser_stack(yyvsp[0]).get(ID_value));
    }
#line 1571 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 19: /* Sign_Int_Type_Name: "Int"  */
#line 245 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).type() = get_int_type();
    }
#line 1580 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 21: /* Sign_DInt_Type_Name: "DInt"  */
#line 257 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).type() = get_dint_type();
    }
#line 1589 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 22: /* Real_Type_Name: "Real"  */
#line 265 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).type() = get_real_type();
    }
#line 1598 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 23: /* Bool_Type_Name: "Bool"  */
#line 273 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).type() = get_bool_type();
    }
#line 1607 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 24: /* Opt_Assignment: ":=" Constant  */
#line 280 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
    }
#line 1615 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 25: /* Opt_Assignment: %empty  */
#line 284 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
    }
#line 1623 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 27: /* FB_Decl: "FUNCTION_BLOCK" Derived_FB_Name Version_Label Zom_FB_General_Var_Decls FB_Body "END_FUNCTION_BLOCK"  */
#line 296 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_function_block);
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-4])), 
        std::move(parser_stack(yyvsp[-3])));
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-2])),
        std::move(parser_stack(yyvsp[-1])));
      PARSER.add_function_block(parser_stack(yyval));
    }
#line 1637 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 28: /* Version_Label: "VERSION" ':' TOK_VERSION_VALUE  */
#line 309 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
    }
#line 1645 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 29: /* Zom_FB_General_Var_Decls: Zom_FB_General_Var_Decls FB_General_Var_Decl  */
#line 316 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 1654 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 30: /* Zom_FB_General_Var_Decls: %empty  */
#line 321 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_decls);
    }
#line 1663 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 38: /* FB_Input_Decls: "VAR_INPUT" Zom_FB_Input_Decl "END_VAR"  */
#line 342 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 1671 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 39: /* Zom_FB_Input_Decl: Zom_FB_Input_Decl FB_Input_Decl ';'  */
#line 349 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1680 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 40: /* Zom_FB_Input_Decl: %empty  */
#line 354 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_input);
    }
#line 1689 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 41: /* FB_Input_Decl: Var_Decl_Init Opt_Assignment  */
#line 362 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 1698 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 42: /* FB_Output_Decls: "VAR_OUTPUT" Zom_FB_Output_Decl "END_VAR"  */
#line 370 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 1706 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 43: /* Zom_FB_Output_Decl: Zom_FB_Output_Decl FB_Output_Decl ';'  */
#line 377 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1715 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 44: /* Zom_FB_Output_Decl: %empty  */
#line 382 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_output);
    }
#line 1724 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 45: /* FB_Output_Decl: Var_Decl_Init Opt_Assignment  */
#line 390 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 1733 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 46: /* FB_Inout_Decls: "VAR_IN_OUT" Zom_FB_Inout_Decl "END_VAR"  */
#line 398 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 1741 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 47: /* Zom_FB_Inout_Decl: Zom_FB_Inout_Decl FB_Inout_Decl ';'  */
#line 405 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1750 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 48: /* Zom_FB_Inout_Decl: %empty  */
#line 410 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_inout);
    }
#line 1759 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 49: /* FB_Inout_Decl: Var_Decl_Init Opt_Assignment  */
#line 418 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 1768 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 50: /* FB_Static_Decls: "VAR" Zom_FB_Static_Decl "END_VAR"  */
#line 426 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 1776 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 51: /* Zom_FB_Static_Decl: Zom_FB_Static_Decl FB_Static_Decl ';'  */
#line 433 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1785 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 52: /* Zom_FB_Static_Decl: %empty  */
#line 438 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_static);
    }
#line 1794 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 53: /* FB_Static_Decl: Var_Decl_Init Opt_Assignment  */
#line 446 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 1803 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 54: /* FB_Body: "BEGIN" Zom_IL_Network  */
#line 454 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
    }
#line 1811 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 55: /* Func_Decl: "FUNCTION" Derived_Func_Name ':' Func_Return_Value Version_Label Zom_Func_General_Var_Decls Func_Body "END_FUNCTION"  */
#line 463 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_function);
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-6])),
      std::move(parser_stack(yyvsp[-4])), std::move(parser_stack(yyvsp[-3])));
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-2])), 
        std::move(parser_stack(yyvsp[-1])));
      PARSER.add_function(parser_stack(yyval));
    }
#line 1825 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 57: /* Func_Return_Value: "Void"  */
#line 480 "/workspace/source/src/statement-list/parser.y"
    {
      parser_stack(yyval).set(ID_statement_list_type, ID_statement_list_return);
    }
#line 1833 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 58: /* Func_Return_Value: Simple_Spec  */
#line 484 "/workspace/source/src/statement-list/parser.y"
    {
      parser_stack(yyval).set(ID_statement_list_type, ID_statement_list_return);
    }
#line 1841 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 59: /* Zom_Func_General_Var_Decls: Zom_Func_General_Var_Decls Func_General_Var_Decl  */
#line 491 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 1850 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 60: /* Zom_Func_General_Var_Decls: %empty  */
#line 496 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_decls);
    }
#line 1859 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 67: /* Input_Decls: "VAR_INPUT" Zom_Input_Decl "END_VAR"  */
#line 516 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 1867 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 68: /* Zom_Input_Decl: Zom_Input_Decl Input_Decl ';'  */
#line 523 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1876 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 69: /* Zom_Input_Decl: %empty  */
#line 528 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_input);
    }
#line 1885 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 71: /* Inout_Decls: "VAR_IN_OUT" Zom_Inout_Decl "END_VAR"  */
#line 540 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 1893 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 72: /* Zom_Inout_Decl: Zom_Inout_Decl Inout_Decl ';'  */
#line 547 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1902 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 73: /* Zom_Inout_Decl: %empty  */
#line 552 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_inout);
    }
#line 1911 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 75: /* Output_Decls: "VAR_OUTPUT" Zom_Output_Decl "END_VAR"  */
#line 564 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 1919 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 76: /* Zom_Output_Decl: Zom_Output_Decl Output_Decl ';'  */
#line 571 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1928 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 77: /* Zom_Output_Decl: %empty  */
#line 576 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_output);
    }
#line 1937 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 79: /* Temp_Decls: "VAR_TEMP" Zom_Temp_Decl "END_VAR"  */
#line 588 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 1945 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 80: /* Zom_Temp_Decl: Zom_Temp_Decl Temp_Decl ';'  */
#line 595 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1954 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 81: /* Zom_Temp_Decl: %empty  */
#line 600 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_temp);
    }
#line 1963 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 83: /* Constant_Decls: "VAR CONSTANT" Zom_Constant_Decl "END_VAR"  */
#line 612 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 1971 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 84: /* Zom_Constant_Decl: Zom_Constant_Decl Constant_Decl ';'  */
#line 619 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])));
    }
#line 1980 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 85: /* Zom_Constant_Decl: %empty  */
#line 624 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_var_constant);
    }
#line 1989 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 86: /* Constant_Decl: Var_Decl_Init Opt_Assignment  */
#line 632 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 1998 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 87: /* Func_Body: "BEGIN" Zom_IL_Network  */
#line 640 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
    }
#line 2006 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 88: /* Zom_IL_Network: Zom_IL_Network IL_Network  */
#line 648 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 2015 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 89: /* Zom_IL_Network: %empty  */
#line 653 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_networks);
    }
#line 2024 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 90: /* IL_Network: "NETWORK" "TITLE" "=" Opt_TITLE_VALUE Opt_Instruction_List  */
#line 661 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_network);
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])), 
        std::move(parser_stack(yyvsp[0])));
    }
#line 2035 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 92: /* Opt_TITLE_VALUE: %empty  */
#line 673 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval) = convert_title("");
    }
#line 2044 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 94: /* Opt_Instruction_List: %empty  */
#line 682 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_instructions);
    }
#line 2053 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 96: /* Oom_IL_Instruction: Oom_IL_Instruction IL_Instruction  */
#line 695 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 2062 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 97: /* Oom_IL_Instruction: IL_Instruction  */
#line 700 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_instructions);
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 2072 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 98: /* IL_Instruction: Opt_Label Instruction ';'  */
#line 709 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-2])));
    }
#line 2081 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 100: /* Opt_Label: %empty  */
#line 718 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
       // ID of expression is nil to indicate that there is no label
    }
#line 2090 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 104: /* IL_Simple_Operation: IL_Simple_Operator Opt_Operand  */
#line 735 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_instruction);
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-1])), 
        std::move(parser_stack(yyvsp[0])));
    }
#line 2101 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 106: /* Opt_Operand: %empty  */
#line 746 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      // ID of expression is nil to indicate that there is no operand
    }
#line 2110 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 107: /* IL_Simple_Operator: "L"  */
#line 754 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_load);
    }
#line 2119 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 108: /* IL_Simple_Operator: "T"  */
#line 759 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_transfer);
    }
#line 2128 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 109: /* IL_Simple_Operator: "NOP"  */
#line 764 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_nop);
    }
#line 2137 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 110: /* IL_Simple_Operator: "+"  */
#line 769 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_const_add);
    }
#line 2146 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 111: /* IL_Simple_Operator: "+I"  */
#line 774 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_add);
    }
#line 2155 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 112: /* IL_Simple_Operator: "-I"  */
#line 779 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_sub);
    }
#line 2164 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 113: /* IL_Simple_Operator: "*I"  */
#line 784 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_mul);
    }
#line 2173 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 114: /* IL_Simple_Operator: "/I"  */
#line 789 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_div);
    }
#line 2182 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 115: /* IL_Simple_Operator: "==I"  */
#line 794 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_eq);
    }
#line 2191 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 116: /* IL_Simple_Operator: "<>I"  */
#line 799 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_neq);
    }
#line 2200 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 117: /* IL_Simple_Operator: ">I"  */
#line 804 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_gt);
    }
#line 2209 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 118: /* IL_Simple_Operator: "<I"  */
#line 809 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_lt);
    }
#line 2218 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 119: /* IL_Simple_Operator: ">=I"  */
#line 814 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_gte);
    }
#line 2227 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 120: /* IL_Simple_Operator: "<=I"  */
#line 819 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_int_lte);
    }
#line 2236 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 121: /* IL_Simple_Operator: "+R"  */
#line 824 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_add);
    }
#line 2245 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 122: /* IL_Simple_Operator: "-R"  */
#line 829 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_sub);
    }
#line 2254 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 123: /* IL_Simple_Operator: "*R"  */
#line 834 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_mul);
    }
#line 2263 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 124: /* IL_Simple_Operator: "/R"  */
#line 839 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_div);
    }
#line 2272 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 125: /* IL_Simple_Operator: "==R"  */
#line 844 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_eq);
    }
#line 2281 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 126: /* IL_Simple_Operator: "<>R"  */
#line 849 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_neq);
    }
#line 2290 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 127: /* IL_Simple_Operator: ">R"  */
#line 854 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_gt);
    }
#line 2299 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 128: /* IL_Simple_Operator: "<R"  */
#line 859 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_lt);
    }
#line 2308 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 129: /* IL_Simple_Operator: ">=R"  */
#line 864 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_gte);
    }
#line 2317 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 130: /* IL_Simple_Operator: "<=R"  */
#line 869 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_real_lte);
    }
#line 2326 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 131: /* IL_Simple_Operator: "+D"  */
#line 874 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_add);
    }
#line 2335 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 132: /* IL_Simple_Operator: "-D"  */
#line 879 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_sub);
    }
#line 2344 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 133: /* IL_Simple_Operator: "*D"  */
#line 884 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_mul);
    }
#line 2353 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 134: /* IL_Simple_Operator: "/D"  */
#line 889 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_div);
    }
#line 2362 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 135: /* IL_Simple_Operator: "==D"  */
#line 894 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_eq);
    }
#line 2371 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 136: /* IL_Simple_Operator: "<>D"  */
#line 899 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_neq);
    }
#line 2380 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 137: /* IL_Simple_Operator: ">D"  */
#line 904 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_gt);
    }
#line 2389 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 138: /* IL_Simple_Operator: "<D"  */
#line 909 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_lt);
    }
#line 2398 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 139: /* IL_Simple_Operator: ">=D"  */
#line 914 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_gte);
    }
#line 2407 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 140: /* IL_Simple_Operator: "<=D"  */
#line 919 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_accu_dint_lte);
    }
#line 2416 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 141: /* IL_Simple_Operator: "A"  */
#line 924 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_and);
    }
#line 2425 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 142: /* IL_Simple_Operator: "AN"  */
#line 929 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_and_not);
    }
#line 2434 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 143: /* IL_Simple_Operator: "O"  */
#line 934 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_or);
    }
#line 2443 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 144: /* IL_Simple_Operator: "ON"  */
#line 939 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_or_not);
    }
#line 2452 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 145: /* IL_Simple_Operator: "X"  */
#line 944 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_xor);
    }
#line 2461 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 146: /* IL_Simple_Operator: "XN"  */
#line 949 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_xor_not);
    }
#line 2470 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 147: /* IL_Simple_Operator: "A("  */
#line 954 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_and_nested);
    }
#line 2479 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 148: /* IL_Simple_Operator: "AN("  */
#line 959 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_and_not_nested);
    }
#line 2488 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 149: /* IL_Simple_Operator: "O("  */
#line 964 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_or_nested);
    }
#line 2497 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 150: /* IL_Simple_Operator: "ON("  */
#line 969 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_or_not_nested);
    }
#line 2506 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 151: /* IL_Simple_Operator: "X("  */
#line 974 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_xor_nested);
    }
#line 2515 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 152: /* IL_Simple_Operator: "XN("  */
#line 979 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_xor_not_nested);
    }
#line 2524 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 153: /* IL_Simple_Operator: ")"  */
#line 984 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_nesting_closed);
    }
#line 2533 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 154: /* IL_Simple_Operator: "="  */
#line 989 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_assign);
    }
#line 2542 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 155: /* IL_Simple_Operator: "SET"  */
#line 994 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_set_rlo);
    }
#line 2551 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 156: /* IL_Simple_Operator: "CLR"  */
#line 999 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_clr_rlo);
    }
#line 2560 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 157: /* IL_Simple_Operator: "S"  */
#line 1004 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_set);
    }
#line 2569 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 158: /* IL_Simple_Operator: "R"  */
#line 1009 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_reset);
    }
#line 2578 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 159: /* IL_Simple_Operator: "NOT"  */
#line 1014 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_not);
    }
#line 2587 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 160: /* IL_Simple_Operator: "JU"  */
#line 1019 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_jump_unconditional);
    }
#line 2596 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 161: /* IL_Simple_Operator: "JC"  */
#line 1024 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_jump_conditional);
    }
#line 2605 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 162: /* IL_Simple_Operator: "JCN"  */
#line 1029 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_jump_conditional_not);
    }
#line 2614 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 165: /* Variable_Access: '#' Variable_Name  */
#line 1042 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
    }
#line 2622 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 166: /* Variable_Access: Variable_Name  */
#line 1046 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
    }
#line 2630 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 170: /* IL_Invocation: Call Callee_Name Opt_Data_Block Opt_Param_List  */
#line 1059 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).id(ID_statement_list_instruction);
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-3])), 
        std::move(parser_stack(yyvsp[-2])), std::move(parser_stack(yyvsp[-1])));    
      std::move(parser_stack(yyvsp[0]).operands().begin(), 
        parser_stack(yyvsp[0]).operands().end(), 
        std::back_inserter(parser_stack(yyval).operands()));
    }
#line 2644 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 171: /* Call: "CALL"  */
#line 1072 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).id(ID_statement_list_call);
    }
#line 2653 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 172: /* Callee_Name: Derived_Func_Name  */
#line 1080 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval) = 
        symbol_exprt::typeless(parser_stack(yyvsp[0]).get(ID_value));
    }
#line 2663 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 173: /* Opt_Param_List: '(' Oom_Param_Assignment ")"  */
#line 1089 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-1];
    }
#line 2671 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 174: /* Opt_Param_List: %empty  */
#line 1093 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
    }
#line 2679 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 175: /* Oom_Param_Assignment: Oom_Param_Assignment ',' Param_Assignment  */
#line 1100 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 2688 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 176: /* Oom_Param_Assignment: Param_Assignment  */
#line 1105 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[0])));
    }
#line 2697 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 177: /* Param_Assignment: Variable_Name ":=" IL_Operand  */
#line 1113 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      parser_stack(yyval) = code_frontend_assignt(std::move(parser_stack(yyvsp[-2])),
        std::move(parser_stack(yyvsp[0])));
    }
#line 2707 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 178: /* Opt_Data_Block: ',' Variable_Name  */
#line 1121 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[0];
      parser_stack(yyval).set(
        ID_statement_list_type, ID_statement_list_data_block);
    }
#line 2717 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 179: /* Opt_Data_Block: %empty  */
#line 1127 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
    }
#line 2725 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 180: /* Tag_Decl: "TAG" Opt_Tag_List "END_TAG"  */
#line 1135 "/workspace/source/src/statement-list/parser.y"
    {
      PARSER.add_tag_list(parser_stack(yyvsp[-1]));
    }
#line 2733 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 182: /* Opt_Tag_List: %empty  */
#line 1143 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
    }
#line 2741 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 183: /* Tag_List: Tag_List Variable_Name Simple_Spec_Init  */
#line 1150 "/workspace/source/src/statement-list/parser.y"
    {
      yyval = yyvsp[-2];
      symbol_exprt sym{parser_stack(yyvsp[-1]).get(ID_identifier), parser_stack(yyvsp[0]).type()};
      parser_stack(yyval).add_to_operands(std::move(sym));
    }
#line 2751 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;

  case 184: /* Tag_List: Variable_Name Simple_Spec_Init  */
#line 1156 "/workspace/source/src/statement-list/parser.y"
    {
      newstack(yyval);
      symbol_exprt sym{parser_stack(yyvsp[-1]).get(ID_identifier), parser_stack(yyvsp[0]).type()};
      parser_stack(yyval).add_to_operands(std::move(sym));
    }
#line 2761 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"
    break;


#line 2765 "/workspace/build/src/statement-list/statement_list_y.tab.cpp"

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
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (statement_list_parser, scanner, YY_("syntax error"));
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
                      yytoken, &yylval, statement_list_parser, scanner);
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
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

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

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
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
                  YY_ACCESSING_SYMBOL (yystate), yyvsp, statement_list_parser, scanner);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (statement_list_parser, scanner, YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval, statement_list_parser, scanner);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp, statement_list_parser, scanner);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 1162 "/workspace/source/src/statement-list/parser.y"

