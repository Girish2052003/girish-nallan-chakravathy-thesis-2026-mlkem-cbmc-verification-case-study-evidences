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
#define yyparse         yyansi_cparse
#define yylex           yyansi_clex
#define yyerror         yyansi_cerror
#define yydebug         yyansi_cdebug
#define yynerrs         yyansi_cnerrs
#define yylval          yyansi_clval
#define yychar          yyansi_cchar

/* First part of user prologue.  */
#line 1 "/workspace/source/src/ansi-c/parser.y"


/*
 * This parser is based on:
 *
 * c5.y, a ANSI-C grammar written by James A. Roskind.
 * "Portions Copyright (c) 1989, 1990 James A. Roskind".
 * (http://www.idiom.com/free-compilers/,
 * ftp://ftp.infoseek.com/ftp/pub/c++grammar/,
 * ftp://ftp.sra.co.jp/.a/pub/cmd/c++grammar2.0.tar.gz)
 */

#ifdef ANSI_C_DEBUG
#define YYDEBUG 1
#endif
#define PARSER (*ansi_c_parser)

#include "ansi_c_parser.h"

int yyansi_clex();
extern char *yyansi_ctext;

static ansi_c_parsert *ansi_c_parser;
int yyansi_cparse(void);
int yyansi_cparse(ansi_c_parsert &_ansi_c_parser)
{
  ansi_c_parser = &_ansi_c_parser;
  return yyansi_cparse();
}

int yyansi_cerror(const std::string &error);

#include "parser_static.inc"

#include "literals/convert_integer_literal.h"

#include "ansi_c_y.tab.h"

#include <util/mathematical_expr.h>

#ifdef _MSC_VER
// possible loss of data
#pragma warning(disable:4242)
// possible loss of data
#pragma warning(disable:4244)
// signed/unsigned mismatch
#pragma warning(disable:4365)
// switch with default but no case labels
#pragma warning(disable:4065)
// unreachable code
#pragma warning(disable:4702)
#endif

// statements have right recursion, deep nesting of statements thus
// requires more stack space
#define YYMAXDEPTH 25600
#line 297 "/workspace/source/src/ansi-c/parser.y"

/************************************************************************/
/*** rules **************************************************************/
/************************************************************************/

#line 141 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"

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

#include "ansi_c_y.tab.hpp"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_TOK_AUTO = 3,                   /* "auto"  */
  YYSYMBOL_TOK_BOOL = 4,                   /* "bool"  */
  YYSYMBOL_TOK_BITINT = 5,                 /* "_BitInt"  */
  YYSYMBOL_TOK_BREAK = 6,                  /* "break"  */
  YYSYMBOL_TOK_COMPLEX = 7,                /* "complex"  */
  YYSYMBOL_TOK_CASE = 8,                   /* "case"  */
  YYSYMBOL_TOK_CHAR = 9,                   /* "char"  */
  YYSYMBOL_TOK_CONST = 10,                 /* "const"  */
  YYSYMBOL_TOK_CONTINUE = 11,              /* "continue"  */
  YYSYMBOL_TOK_DEFAULT = 12,               /* "default"  */
  YYSYMBOL_TOK_DO = 13,                    /* "do"  */
  YYSYMBOL_TOK_DOUBLE = 14,                /* "double"  */
  YYSYMBOL_TOK_ELSE = 15,                  /* "else"  */
  YYSYMBOL_TOK_ENUM = 16,                  /* "enum"  */
  YYSYMBOL_TOK_EXTERN = 17,                /* "extern"  */
  YYSYMBOL_TOK_FLOAT = 18,                 /* "float"  */
  YYSYMBOL_TOK_FOR = 19,                   /* "for"  */
  YYSYMBOL_TOK_GOTO = 20,                  /* "goto"  */
  YYSYMBOL_TOK_IF = 21,                    /* "if"  */
  YYSYMBOL_TOK_INLINE = 22,                /* "inline"  */
  YYSYMBOL_TOK_INT = 23,                   /* "int"  */
  YYSYMBOL_TOK_LONG = 24,                  /* "long"  */
  YYSYMBOL_TOK_REGISTER = 25,              /* "register"  */
  YYSYMBOL_TOK_RESTRICT = 26,              /* "restrict"  */
  YYSYMBOL_TOK_RETURN = 27,                /* "return"  */
  YYSYMBOL_TOK_SHORT = 28,                 /* "short"  */
  YYSYMBOL_TOK_SIGNED = 29,                /* "signed"  */
  YYSYMBOL_TOK_SIZEOF = 30,                /* "sizeof"  */
  YYSYMBOL_TOK_STATIC = 31,                /* "static"  */
  YYSYMBOL_TOK_STRUCT = 32,                /* "struct"  */
  YYSYMBOL_TOK_SWITCH = 33,                /* "switch"  */
  YYSYMBOL_TOK_TYPEDEF = 34,               /* "typedef"  */
  YYSYMBOL_TOK_TYPEOF_UNQUAL = 35,         /* "typeof_unqual"  */
  YYSYMBOL_TOK_UNION = 36,                 /* "union"  */
  YYSYMBOL_TOK_UNSIGNED = 37,              /* "unsigned"  */
  YYSYMBOL_TOK_VOID = 38,                  /* "void"  */
  YYSYMBOL_TOK_VOLATILE = 39,              /* "volatile"  */
  YYSYMBOL_TOK_WCHAR_T = 40,               /* "wchar_t"  */
  YYSYMBOL_TOK_WHILE = 41,                 /* "while"  */
  YYSYMBOL_TOK_ARROW = 42,                 /* "->"  */
  YYSYMBOL_TOK_INCR = 43,                  /* "++"  */
  YYSYMBOL_TOK_DECR = 44,                  /* "--"  */
  YYSYMBOL_TOK_SHIFTLEFT = 45,             /* "<<"  */
  YYSYMBOL_TOK_SHIFTRIGHT = 46,            /* ">>"  */
  YYSYMBOL_TOK_LE = 47,                    /* "<="  */
  YYSYMBOL_TOK_GE = 48,                    /* ">="  */
  YYSYMBOL_TOK_EQ = 49,                    /* "=="  */
  YYSYMBOL_TOK_NE = 50,                    /* "!="  */
  YYSYMBOL_TOK_ANDAND = 51,                /* "&&"  */
  YYSYMBOL_TOK_OROR = 52,                  /* "||"  */
  YYSYMBOL_TOK_ELLIPSIS = 53,              /* "..."  */
  YYSYMBOL_TOK_MULTASSIGN = 54,            /* "*="  */
  YYSYMBOL_TOK_DIVASSIGN = 55,             /* "/="  */
  YYSYMBOL_TOK_MODASSIGN = 56,             /* "%="  */
  YYSYMBOL_TOK_PLUSASSIGN = 57,            /* "+="  */
  YYSYMBOL_TOK_MINUSASSIGN = 58,           /* "-="  */
  YYSYMBOL_TOK_SHLASSIGN = 59,             /* "<<="  */
  YYSYMBOL_TOK_SHRASSIGN = 60,             /* ">>="  */
  YYSYMBOL_TOK_ANDASSIGN = 61,             /* "&="  */
  YYSYMBOL_TOK_XORASSIGN = 62,             /* "^="  */
  YYSYMBOL_TOK_ORASSIGN = 63,              /* "|="  */
  YYSYMBOL_TOK_GCC_IDENTIFIER = 64,        /* TOK_GCC_IDENTIFIER  */
  YYSYMBOL_TOK_MSC_IDENTIFIER = 65,        /* TOK_MSC_IDENTIFIER  */
  YYSYMBOL_TOK_TYPEDEFNAME = 66,           /* TOK_TYPEDEFNAME  */
  YYSYMBOL_TOK_INTEGER = 67,               /* TOK_INTEGER  */
  YYSYMBOL_TOK_FLOATING = 68,              /* TOK_FLOATING  */
  YYSYMBOL_TOK_CHARACTER = 69,             /* TOK_CHARACTER  */
  YYSYMBOL_TOK_STRING = 70,                /* TOK_STRING  */
  YYSYMBOL_TOK_ASM_STRING = 71,            /* TOK_ASM_STRING  */
  YYSYMBOL_TOK_INT8 = 72,                  /* "__int8"  */
  YYSYMBOL_TOK_INT16 = 73,                 /* "__int16"  */
  YYSYMBOL_TOK_INT32 = 74,                 /* "__int32"  */
  YYSYMBOL_TOK_INT64 = 75,                 /* "__int64"  */
  YYSYMBOL_TOK_PTR32 = 76,                 /* "__ptr32"  */
  YYSYMBOL_TOK_PTR64 = 77,                 /* "__ptr64"  */
  YYSYMBOL_TOK_TYPEOF = 78,                /* "typeof"  */
  YYSYMBOL_TOK_GCC_AUTO_TYPE = 79,         /* "__auto_type"  */
  YYSYMBOL_TOK_GCC_FLOAT16 = 80,           /* "_Float16"  */
  YYSYMBOL_TOK_GCC_FLOAT32 = 81,           /* "_Float32"  */
  YYSYMBOL_TOK_GCC_FLOAT32X = 82,          /* "_Float32x"  */
  YYSYMBOL_TOK_GCC_FLOAT80 = 83,           /* "__float80"  */
  YYSYMBOL_TOK_GCC_FLOAT64 = 84,           /* "_Float64"  */
  YYSYMBOL_TOK_GCC_FLOAT64X = 85,          /* "_Float64x"  */
  YYSYMBOL_TOK_GCC_FLOAT128 = 86,          /* "_Float128"  */
  YYSYMBOL_TOK_GCC_FLOAT128X = 87,         /* "_Float128x"  */
  YYSYMBOL_TOK_GCC_INT128 = 88,            /* "__int128"  */
  YYSYMBOL_TOK_GCC_DECIMAL32 = 89,         /* "_Decimal32"  */
  YYSYMBOL_TOK_GCC_DECIMAL64 = 90,         /* "_Decimal64"  */
  YYSYMBOL_TOK_GCC_DECIMAL128 = 91,        /* "_Decimal128"  */
  YYSYMBOL_TOK_GCC_ASM = 92,               /* "__asm__"  */
  YYSYMBOL_TOK_GCC_ASM_PAREN = 93,         /* "__asm__ (with parentheses)"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE = 94,         /* "__attribute__"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_ALIGNED = 95, /* "aligned"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_TRANSPARENT_UNION = 96, /* "transparent_union"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_PACKED = 97,  /* "packed"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_VECTOR_SIZE = 98, /* "vector_size"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_MODE = 99,    /* "mode"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_GNU_INLINE = 100, /* "__gnu_inline__"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_WEAK = 101,   /* "weak"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_ALIAS = 102,  /* "alias"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_SECTION = 103, /* "section"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_NORETURN = 104, /* "noreturn"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_CONSTRUCTOR = 105, /* "constructor"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_DESTRUCTOR = 106, /* "destructor"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_FALLTHROUGH = 107, /* "fallthrough"  */
  YYSYMBOL_TOK_GCC_ATTRIBUTE_USED = 108,   /* "used"  */
  YYSYMBOL_TOK_GCC_LABEL = 109,            /* "__label__"  */
  YYSYMBOL_TOK_MSC_ASM = 110,              /* "__asm"  */
  YYSYMBOL_TOK_MSC_BASED = 111,            /* "__based"  */
  YYSYMBOL_TOK_CW_VAR_ARG_TYPEOF = 112,    /* "_var_arg_typeof"  */
  YYSYMBOL_TOK_BUILTIN_VA_ARG = 113,       /* "__builtin_va_arg"  */
  YYSYMBOL_TOK_GCC_BUILTIN_TYPES_COMPATIBLE_P = 114, /* "__builtin_types_compatible_p"  */
  YYSYMBOL_TOK_GCC_BUILTIN_HAS_ATTRIBUTE = 115, /* "__builtin_has_attribute"  */
  YYSYMBOL_TOK_CLANG_BUILTIN_CONVERTVECTOR = 116, /* "__builtin_convertvector"  */
  YYSYMBOL_TOK_OFFSETOF = 117,             /* "__offsetof"  */
  YYSYMBOL_TOK_ALIGNOF = 118,              /* "__alignof__"  */
  YYSYMBOL_TOK_MSC_TRY = 119,              /* "__try"  */
  YYSYMBOL_TOK_MSC_FINALLY = 120,          /* "__finally"  */
  YYSYMBOL_TOK_MSC_EXCEPT = 121,           /* "__except"  */
  YYSYMBOL_TOK_MSC_LEAVE = 122,            /* "__leave"  */
  YYSYMBOL_TOK_MSC_DECLSPEC = 123,         /* "__declspec"  */
  YYSYMBOL_TOK_MSC_FORCEINLINE = 124,      /* "__forceinline"  */
  YYSYMBOL_TOK_INTERFACE = 125,            /* "__interface"  */
  YYSYMBOL_TOK_CDECL = 126,                /* "__cdecl"  */
  YYSYMBOL_TOK_STDCALL = 127,              /* "__stdcall"  */
  YYSYMBOL_TOK_FASTCALL = 128,             /* "__fastcall"  */
  YYSYMBOL_TOK_CLRCALL = 129,              /* "__clrcall"  */
  YYSYMBOL_TOK_FORALL = 130,               /* "forall"  */
  YYSYMBOL_TOK_EXISTS = 131,               /* "exists"  */
  YYSYMBOL_TOK_ACSL_FORALL = 132,          /* "\\forall"  */
  YYSYMBOL_TOK_ACSL_EXISTS = 133,          /* "\\exists"  */
  YYSYMBOL_TOK_ACSL_LAMBDA = 134,          /* "\\lambda"  */
  YYSYMBOL_TOK_ACSL_LET = 135,             /* "\\let"  */
  YYSYMBOL_TOK_ARRAY_OF = 136,             /* "array_of"  */
  YYSYMBOL_TOK_CPROVER_BITVECTOR = 137,    /* "__CPROVER_bitvector"  */
  YYSYMBOL_TOK_CPROVER_FLOATBV = 138,      /* "__CPROVER_floatbv"  */
  YYSYMBOL_TOK_CPROVER_FIXEDBV = 139,      /* "__CPROVER_fixedbv"  */
  YYSYMBOL_TOK_CPROVER_ATOMIC = 140,       /* "__CPROVER_atomic"  */
  YYSYMBOL_TOK_CPROVER_BOOL = 141,         /* "__CPROVER_bool"  */
  YYSYMBOL_TOK_CPROVER_THROW = 142,        /* "__CPROVER_throw"  */
  YYSYMBOL_TOK_CPROVER_CATCH = 143,        /* "__CPROVER_catch"  */
  YYSYMBOL_TOK_CPROVER_TRY = 144,          /* "__CPROVER_try"  */
  YYSYMBOL_TOK_CPROVER_FINALLY = 145,      /* "__CPROVER_finally"  */
  YYSYMBOL_TOK_CPROVER_ID = 146,           /* "__CPROVER_ID"  */
  YYSYMBOL_TOK_CPROVER_LOOP_INVARIANT = 147, /* "__CPROVER_loop_invariant"  */
  YYSYMBOL_TOK_CPROVER_DECREASES = 148,    /* "__CPROVER_decreases"  */
  YYSYMBOL_TOK_CPROVER_REQUIRES = 149,     /* "__CPROVER_requires"  */
  YYSYMBOL_TOK_CPROVER_ENSURES = 150,      /* "__CPROVER_ensures"  */
  YYSYMBOL_TOK_CPROVER_ASSIGNS = 151,      /* "__CPROVER_assigns"  */
  YYSYMBOL_TOK_CPROVER_FREES = 152,        /* "__CPROVER_frees"  */
  YYSYMBOL_TOK_IMPLIES = 153,              /* "==>"  */
  YYSYMBOL_TOK_EQUIVALENT = 154,           /* "<==>"  */
  YYSYMBOL_TOK_XORXOR = 155,               /* "^^"  */
  YYSYMBOL_TOK_TRUE = 156,                 /* "TRUE"  */
  YYSYMBOL_TOK_FALSE = 157,                /* "FALSE"  */
  YYSYMBOL_TOK_REAL = 158,                 /* "__real__"  */
  YYSYMBOL_TOK_IMAG = 159,                 /* "__imag__"  */
  YYSYMBOL_TOK_ALIGNAS = 160,              /* "_Alignas"  */
  YYSYMBOL_TOK_ATOMIC_TYPE_QUALIFIER = 161, /* "_Atomic"  */
  YYSYMBOL_TOK_ATOMIC_TYPE_SPECIFIER = 162, /* "_Atomic()"  */
  YYSYMBOL_TOK_GENERIC = 163,              /* "_Generic"  */
  YYSYMBOL_TOK_IMAGINARY = 164,            /* "_Imaginary"  */
  YYSYMBOL_TOK_NORETURN = 165,             /* "_Noreturn"  */
  YYSYMBOL_TOK_STATIC_ASSERT = 166,        /* "_Static_assert"  */
  YYSYMBOL_TOK_THREAD_LOCAL = 167,         /* "_Thread_local"  */
  YYSYMBOL_TOK_NULLPTR = 168,              /* "nullptr"  */
  YYSYMBOL_TOK_CONSTEXPR = 169,            /* "constexpr"  */
  YYSYMBOL_TOK_BIT_CAST = 170,             /* "__builtin_bit_cast"  */
  YYSYMBOL_TOK_SCANNER_ERROR = 171,        /* TOK_SCANNER_ERROR  */
  YYSYMBOL_TOK_SCANNER_EOF = 172,          /* TOK_SCANNER_EOF  */
  YYSYMBOL_TOK_CATCH = 173,                /* "catch"  */
  YYSYMBOL_TOK_CHAR16_T = 174,             /* "char16_t"  */
  YYSYMBOL_TOK_CHAR32_T = 175,             /* "char32_t"  */
  YYSYMBOL_TOK_CLASS = 176,                /* "class"  */
  YYSYMBOL_TOK_DELETE = 177,               /* "delete"  */
  YYSYMBOL_TOK_DECLTYPE = 178,             /* "decltype"  */
  YYSYMBOL_TOK_EXPLICIT = 179,             /* "explicit"  */
  YYSYMBOL_TOK_FRIEND = 180,               /* "friend"  */
  YYSYMBOL_TOK_MUTABLE = 181,              /* "mutable"  */
  YYSYMBOL_TOK_NAMESPACE = 182,            /* "namespace"  */
  YYSYMBOL_TOK_NEW = 183,                  /* "new"  */
  YYSYMBOL_TOK_NODISCARD = 184,            /* "nodiscard"  */
  YYSYMBOL_TOK_NOEXCEPT = 185,             /* "noexcept"  */
  YYSYMBOL_TOK_OPERATOR = 186,             /* "operator"  */
  YYSYMBOL_TOK_PRIVATE = 187,              /* "private"  */
  YYSYMBOL_TOK_PROTECTED = 188,            /* "protected"  */
  YYSYMBOL_TOK_PUBLIC = 189,               /* "public"  */
  YYSYMBOL_TOK_TEMPLATE = 190,             /* "template"  */
  YYSYMBOL_TOK_THIS = 191,                 /* "this"  */
  YYSYMBOL_TOK_THROW = 192,                /* "throw"  */
  YYSYMBOL_TOK_TYPEID = 193,               /* "typeid"  */
  YYSYMBOL_TOK_TYPENAME = 194,             /* "typename"  */
  YYSYMBOL_TOK_TRY = 195,                  /* "try"  */
  YYSYMBOL_TOK_USING = 196,                /* "using"  */
  YYSYMBOL_TOK_VIRTUAL = 197,              /* "virtual"  */
  YYSYMBOL_TOK_SCOPE = 198,                /* "::"  */
  YYSYMBOL_TOK_DOTPM = 199,                /* ".*"  */
  YYSYMBOL_TOK_ARROWPM = 200,              /* "->*"  */
  YYSYMBOL_TOK_UNARY_TYPE_PREDICATE = 201, /* TOK_UNARY_TYPE_PREDICATE  */
  YYSYMBOL_TOK_BINARY_TYPE_PREDICATE = 202, /* TOK_BINARY_TYPE_PREDICATE  */
  YYSYMBOL_TOK_MSC_UUIDOF = 203,           /* "__uuidof"  */
  YYSYMBOL_TOK_MSC_IF_EXISTS = 204,        /* "__if_exists"  */
  YYSYMBOL_TOK_MSC_IF_NOT_EXISTS = 205,    /* "__if_not_exists"  */
  YYSYMBOL_TOK_UNDERLYING_TYPE = 206,      /* "__underlying_type"  */
  YYSYMBOL_207_ = 207,                     /* '('  */
  YYSYMBOL_208_ = 208,                     /* ')'  */
  YYSYMBOL_209_ = 209,                     /* ','  */
  YYSYMBOL_210_ = 210,                     /* ':'  */
  YYSYMBOL_211_ = 211,                     /* '.'  */
  YYSYMBOL_212_ = 212,                     /* '['  */
  YYSYMBOL_213_ = 213,                     /* ']'  */
  YYSYMBOL_214_ = 214,                     /* '{'  */
  YYSYMBOL_215_ = 215,                     /* '}'  */
  YYSYMBOL_216_ = 216,                     /* '&'  */
  YYSYMBOL_217_ = 217,                     /* '*'  */
  YYSYMBOL_218_ = 218,                     /* '+'  */
  YYSYMBOL_219_ = 219,                     /* '-'  */
  YYSYMBOL_220_ = 220,                     /* '~'  */
  YYSYMBOL_221_ = 221,                     /* '!'  */
  YYSYMBOL_222_ = 222,                     /* '/'  */
  YYSYMBOL_223_ = 223,                     /* '%'  */
  YYSYMBOL_224_ = 224,                     /* '<'  */
  YYSYMBOL_225_ = 225,                     /* '>'  */
  YYSYMBOL_226_ = 226,                     /* '^'  */
  YYSYMBOL_227_ = 227,                     /* '|'  */
  YYSYMBOL_228_ = 228,                     /* '?'  */
  YYSYMBOL_229_ = 229,                     /* '='  */
  YYSYMBOL_230_ = 230,                     /* ';'  */
  YYSYMBOL_YYACCEPT = 231,                 /* $accept  */
  YYSYMBOL_grammar = 232,                  /* grammar  */
  YYSYMBOL_identifier = 233,               /* identifier  */
  YYSYMBOL_typedef_name = 234,             /* typedef_name  */
  YYSYMBOL_integer = 235,                  /* integer  */
  YYSYMBOL_floating = 236,                 /* floating  */
  YYSYMBOL_character = 237,                /* character  */
  YYSYMBOL_string = 238,                   /* string  */
  YYSYMBOL_constant = 239,                 /* constant  */
  YYSYMBOL_predefined_constant = 240,      /* predefined_constant  */
  YYSYMBOL_primary_expression = 241,       /* primary_expression  */
  YYSYMBOL_generic_selection = 242,        /* generic_selection  */
  YYSYMBOL_generic_assoc_list = 243,       /* generic_assoc_list  */
  YYSYMBOL_generic_association = 244,      /* generic_association  */
  YYSYMBOL_gcc_builtin_expressions = 245,  /* gcc_builtin_expressions  */
  YYSYMBOL_clang_builtin_expressions = 246, /* clang_builtin_expressions  */
  YYSYMBOL_cw_builtin_expressions = 247,   /* cw_builtin_expressions  */
  YYSYMBOL_offsetof = 248,                 /* offsetof  */
  YYSYMBOL_offsetof_member_designator = 249, /* offsetof_member_designator  */
  YYSYMBOL_quantifier_expression = 250,    /* quantifier_expression  */
  YYSYMBOL_cprover_contract_loop_invariant = 251, /* cprover_contract_loop_invariant  */
  YYSYMBOL_cprover_contract_loop_invariant_list = 252, /* cprover_contract_loop_invariant_list  */
  YYSYMBOL_cprover_contract_loop_invariant_list_opt = 253, /* cprover_contract_loop_invariant_list_opt  */
  YYSYMBOL_ACSL_binding_expression_list = 254, /* ACSL_binding_expression_list  */
  YYSYMBOL_cprover_contract_decreases_opt = 255, /* cprover_contract_decreases_opt  */
  YYSYMBOL_statement_expression = 256,     /* statement_expression  */
  YYSYMBOL_postfix_expression = 257,       /* postfix_expression  */
  YYSYMBOL_member_name = 258,              /* member_name  */
  YYSYMBOL_argument_expression_list = 259, /* argument_expression_list  */
  YYSYMBOL_unary_expression = 260,         /* unary_expression  */
  YYSYMBOL_cast_expression = 261,          /* cast_expression  */
  YYSYMBOL_multiplicative_expression = 262, /* multiplicative_expression  */
  YYSYMBOL_additive_expression = 263,      /* additive_expression  */
  YYSYMBOL_shift_expression = 264,         /* shift_expression  */
  YYSYMBOL_relational_expression = 265,    /* relational_expression  */
  YYSYMBOL_equality_expression = 266,      /* equality_expression  */
  YYSYMBOL_and_expression = 267,           /* and_expression  */
  YYSYMBOL_exclusive_or_expression = 268,  /* exclusive_or_expression  */
  YYSYMBOL_inclusive_or_expression = 269,  /* inclusive_or_expression  */
  YYSYMBOL_logical_and_expression = 270,   /* logical_and_expression  */
  YYSYMBOL_logical_xor_expression = 271,   /* logical_xor_expression  */
  YYSYMBOL_logical_or_expression = 272,    /* logical_or_expression  */
  YYSYMBOL_logical_implication_expression = 273, /* logical_implication_expression  */
  YYSYMBOL_logical_equivalence_expression = 274, /* logical_equivalence_expression  */
  YYSYMBOL_ACSL_binding_expression = 275,  /* ACSL_binding_expression  */
  YYSYMBOL_conditional_expression = 276,   /* conditional_expression  */
  YYSYMBOL_assignment_expression = 277,    /* assignment_expression  */
  YYSYMBOL_comma_expression = 278,         /* comma_expression  */
  YYSYMBOL_constant_expression = 279,      /* constant_expression  */
  YYSYMBOL_comma_expression_opt = 280,     /* comma_expression_opt  */
  YYSYMBOL_declaration = 281,              /* declaration  */
  YYSYMBOL_static_assert_declaration = 282, /* static_assert_declaration  */
  YYSYMBOL_default_declaring_list = 283,   /* default_declaring_list  */
  YYSYMBOL_284_1 = 284,                    /* @1  */
  YYSYMBOL_285_2 = 285,                    /* @2  */
  YYSYMBOL_286_3 = 286,                    /* $@3  */
  YYSYMBOL_post_declarator_attribute = 287, /* post_declarator_attribute  */
  YYSYMBOL_post_declarator_attributes = 288, /* post_declarator_attributes  */
  YYSYMBOL_post_declarator_attributes_opt = 289, /* post_declarator_attributes_opt  */
  YYSYMBOL_declaring_list = 290,           /* declaring_list  */
  YYSYMBOL_291_4 = 291,                    /* @4  */
  YYSYMBOL_292_5 = 292,                    /* @5  */
  YYSYMBOL_293_6 = 293,                    /* $@6  */
  YYSYMBOL_declaration_specifier = 294,    /* declaration_specifier  */
  YYSYMBOL_type_specifier = 295,           /* type_specifier  */
  YYSYMBOL_declaration_qualifier_list = 296, /* declaration_qualifier_list  */
  YYSYMBOL_type_qualifier_list = 297,      /* type_qualifier_list  */
  YYSYMBOL_attribute_type_qualifier_list = 298, /* attribute_type_qualifier_list  */
  YYSYMBOL_declaration_qualifier = 299,    /* declaration_qualifier  */
  YYSYMBOL_type_qualifier = 300,           /* type_qualifier  */
  YYSYMBOL_alignas_specifier = 301,        /* alignas_specifier  */
  YYSYMBOL_attribute_or_type_qualifier = 302, /* attribute_or_type_qualifier  */
  YYSYMBOL_attribute_or_type_qualifier_or_storage_class = 303, /* attribute_or_type_qualifier_or_storage_class  */
  YYSYMBOL_attribute_type_qualifier_storage_class_list = 304, /* attribute_type_qualifier_storage_class_list  */
  YYSYMBOL_basic_declaration_specifier = 305, /* basic_declaration_specifier  */
  YYSYMBOL_basic_type_specifier = 306,     /* basic_type_specifier  */
  YYSYMBOL_sue_declaration_specifier = 307, /* sue_declaration_specifier  */
  YYSYMBOL_sue_type_specifier = 308,       /* sue_type_specifier  */
  YYSYMBOL_typedef_declaration_specifier = 309, /* typedef_declaration_specifier  */
  YYSYMBOL_typeof_declaration_specifier = 310, /* typeof_declaration_specifier  */
  YYSYMBOL_atomic_declaration_specifier = 311, /* atomic_declaration_specifier  */
  YYSYMBOL_typedef_type_specifier = 312,   /* typedef_type_specifier  */
  YYSYMBOL_typeof_specifier = 313,         /* typeof_specifier  */
  YYSYMBOL_typeof_type_specifier = 314,    /* typeof_type_specifier  */
  YYSYMBOL_atomic_specifier = 315,         /* atomic_specifier  */
  YYSYMBOL_atomic_type_specifier = 316,    /* atomic_type_specifier  */
  YYSYMBOL_msc_decl_identifier = 317,      /* msc_decl_identifier  */
  YYSYMBOL_msc_decl_modifier = 318,        /* msc_decl_modifier  */
  YYSYMBOL_msc_declspec_seq = 319,         /* msc_declspec_seq  */
  YYSYMBOL_msc_declspec = 320,             /* msc_declspec  */
  YYSYMBOL_msc_declspec_opt = 321,         /* msc_declspec_opt  */
  YYSYMBOL_storage_class = 322,            /* storage_class  */
  YYSYMBOL_basic_type_name = 323,          /* basic_type_name  */
  YYSYMBOL_elaborated_type_name = 324,     /* elaborated_type_name  */
  YYSYMBOL_array_of_construct = 325,       /* array_of_construct  */
  YYSYMBOL_pragma_packed = 326,            /* pragma_packed  */
  YYSYMBOL_aggregate_name = 327,           /* aggregate_name  */
  YYSYMBOL_328_7 = 328,                    /* $@7  */
  YYSYMBOL_329_8 = 329,                    /* $@8  */
  YYSYMBOL_330_9 = 330,                    /* $@9  */
  YYSYMBOL_aggregate_key = 331,            /* aggregate_key  */
  YYSYMBOL_gcc_type_attribute = 332,       /* gcc_type_attribute  */
  YYSYMBOL_gcc_attribute = 333,            /* gcc_attribute  */
  YYSYMBOL_gcc_attribute_list = 334,       /* gcc_attribute_list  */
  YYSYMBOL_gcc_attribute_specifier = 335,  /* gcc_attribute_specifier  */
  YYSYMBOL_gcc_type_attribute_opt = 336,   /* gcc_type_attribute_opt  */
  YYSYMBOL_gcc_type_attribute_list = 337,  /* gcc_type_attribute_list  */
  YYSYMBOL_member_declaration_list_opt = 338, /* member_declaration_list_opt  */
  YYSYMBOL_member_declaration_list = 339,  /* member_declaration_list  */
  YYSYMBOL_member_declaration = 340,       /* member_declaration  */
  YYSYMBOL_member_default_declaring_list = 341, /* member_default_declaring_list  */
  YYSYMBOL_member_declaring_list = 342,    /* member_declaring_list  */
  YYSYMBOL_member_declarator = 343,        /* member_declarator  */
  YYSYMBOL_member_identifier_declarator = 344, /* member_identifier_declarator  */
  YYSYMBOL_bit_field_size_opt = 345,       /* bit_field_size_opt  */
  YYSYMBOL_bit_field_size = 346,           /* bit_field_size  */
  YYSYMBOL_enum_name = 347,                /* enum_name  */
  YYSYMBOL_348_10 = 348,                   /* $@10  */
  YYSYMBOL_349_11 = 349,                   /* $@11  */
  YYSYMBOL_basic_type_name_list = 350,     /* basic_type_name_list  */
  YYSYMBOL_enum_underlying_type = 351,     /* enum_underlying_type  */
  YYSYMBOL_enum_underlying_type_opt = 352, /* enum_underlying_type_opt  */
  YYSYMBOL_braced_enumerator_list_opt = 353, /* braced_enumerator_list_opt  */
  YYSYMBOL_enum_key = 354,                 /* enum_key  */
  YYSYMBOL_enumerator_list_opt = 355,      /* enumerator_list_opt  */
  YYSYMBOL_enumerator_list = 356,          /* enumerator_list  */
  YYSYMBOL_enumerator_declaration = 357,   /* enumerator_declaration  */
  YYSYMBOL_enumerator_value_opt = 358,     /* enumerator_value_opt  */
  YYSYMBOL_parameter_type_list = 359,      /* parameter_type_list  */
  YYSYMBOL_KnR_parameter_list = 360,       /* KnR_parameter_list  */
  YYSYMBOL_KnR_parameter = 361,            /* KnR_parameter  */
  YYSYMBOL_parameter_list = 362,           /* parameter_list  */
  YYSYMBOL_parameter_declaration = 363,    /* parameter_declaration  */
  YYSYMBOL_identifier_or_typedef_name = 364, /* identifier_or_typedef_name  */
  YYSYMBOL_type_name = 365,                /* type_name  */
  YYSYMBOL_initializer_opt = 366,          /* initializer_opt  */
  YYSYMBOL_initializer = 367,              /* initializer  */
  YYSYMBOL_initializer_list = 368,         /* initializer_list  */
  YYSYMBOL_initializer_list_opt = 369,     /* initializer_list_opt  */
  YYSYMBOL_designated_initializer = 370,   /* designated_initializer  */
  YYSYMBOL_designator = 371,               /* designator  */
  YYSYMBOL_statement = 372,                /* statement  */
  YYSYMBOL_stmt_not_decl_or_attr = 373,    /* stmt_not_decl_or_attr  */
  YYSYMBOL_declaration_statement = 374,    /* declaration_statement  */
  YYSYMBOL_gcc_attribute_specifier_opt = 375, /* gcc_attribute_specifier_opt  */
  YYSYMBOL_msc_label_identifier = 376,     /* msc_label_identifier  */
  YYSYMBOL_labeled_statement = 377,        /* labeled_statement  */
  YYSYMBOL_statement_attribute = 378,      /* statement_attribute  */
  YYSYMBOL_compound_statement = 379,       /* compound_statement  */
  YYSYMBOL_compound_scope = 380,           /* compound_scope  */
  YYSYMBOL_statement_list = 381,           /* statement_list  */
  YYSYMBOL_expression_statement = 382,     /* expression_statement  */
  YYSYMBOL_selection_statement = 383,      /* selection_statement  */
  YYSYMBOL_declaration_or_expression_statement = 384, /* declaration_or_expression_statement  */
  YYSYMBOL_iteration_statement = 385,      /* iteration_statement  */
  YYSYMBOL_386_12 = 386,                   /* $@12  */
  YYSYMBOL_jump_statement = 387,           /* jump_statement  */
  YYSYMBOL_gcc_local_label_statement = 388, /* gcc_local_label_statement  */
  YYSYMBOL_gcc_local_label_list = 389,     /* gcc_local_label_list  */
  YYSYMBOL_gcc_local_label = 390,          /* gcc_local_label  */
  YYSYMBOL_gcc_asm_statement = 391,        /* gcc_asm_statement  */
  YYSYMBOL_msc_asm_statement = 392,        /* msc_asm_statement  */
  YYSYMBOL_msc_seh_statement = 393,        /* msc_seh_statement  */
  YYSYMBOL_cprover_exception_statement = 394, /* cprover_exception_statement  */
  YYSYMBOL_volatile_or_goto_opt = 395,     /* volatile_or_goto_opt  */
  YYSYMBOL_gcc_asm_commands = 396,         /* gcc_asm_commands  */
  YYSYMBOL_gcc_asm_assembler_template = 397, /* gcc_asm_assembler_template  */
  YYSYMBOL_gcc_asm_outputs = 398,          /* gcc_asm_outputs  */
  YYSYMBOL_gcc_asm_output = 399,           /* gcc_asm_output  */
  YYSYMBOL_gcc_asm_output_list = 400,      /* gcc_asm_output_list  */
  YYSYMBOL_gcc_asm_inputs = 401,           /* gcc_asm_inputs  */
  YYSYMBOL_gcc_asm_input = 402,            /* gcc_asm_input  */
  YYSYMBOL_gcc_asm_input_list = 403,       /* gcc_asm_input_list  */
  YYSYMBOL_gcc_asm_clobbered_registers = 404, /* gcc_asm_clobbered_registers  */
  YYSYMBOL_gcc_asm_clobbered_register = 405, /* gcc_asm_clobbered_register  */
  YYSYMBOL_gcc_asm_clobbered_registers_list = 406, /* gcc_asm_clobbered_registers_list  */
  YYSYMBOL_gcc_asm_labels = 407,           /* gcc_asm_labels  */
  YYSYMBOL_gcc_asm_labels_list = 408,      /* gcc_asm_labels_list  */
  YYSYMBOL_gcc_asm_label = 409,            /* gcc_asm_label  */
  YYSYMBOL_translation_unit = 410,         /* translation_unit  */
  YYSYMBOL_external_definition_list = 411, /* external_definition_list  */
  YYSYMBOL_external_definition = 412,      /* external_definition  */
  YYSYMBOL_asm_definition = 413,           /* asm_definition  */
  YYSYMBOL_function_definition = 414,      /* function_definition  */
  YYSYMBOL_function_body = 415,            /* function_body  */
  YYSYMBOL_KnR_parameter_header_opt = 416, /* KnR_parameter_header_opt  */
  YYSYMBOL_KnR_parameter_header = 417,     /* KnR_parameter_header  */
  YYSYMBOL_KnR_parameter_declaration = 418, /* KnR_parameter_declaration  */
  YYSYMBOL_KnR_declaration_qualifier_list = 419, /* KnR_declaration_qualifier_list  */
  YYSYMBOL_KnR_basic_declaration_specifier = 420, /* KnR_basic_declaration_specifier  */
  YYSYMBOL_KnR_typedef_declaration_specifier = 421, /* KnR_typedef_declaration_specifier  */
  YYSYMBOL_KnR_sue_declaration_specifier = 422, /* KnR_sue_declaration_specifier  */
  YYSYMBOL_KnR_declaration_specifier = 423, /* KnR_declaration_specifier  */
  YYSYMBOL_KnR_parameter_declaring_list = 424, /* KnR_parameter_declaring_list  */
  YYSYMBOL_function_head = 425,            /* function_head  */
  YYSYMBOL_declarator = 426,               /* declarator  */
  YYSYMBOL_paren_attribute_declarator = 427, /* paren_attribute_declarator  */
  YYSYMBOL_typedef_declarator = 428,       /* typedef_declarator  */
  YYSYMBOL_parameter_typedef_declarator = 429, /* parameter_typedef_declarator  */
  YYSYMBOL_clean_typedef_declarator = 430, /* clean_typedef_declarator  */
  YYSYMBOL_clean_postfix_typedef_declarator = 431, /* clean_postfix_typedef_declarator  */
  YYSYMBOL_paren_typedef_declarator = 432, /* paren_typedef_declarator  */
  YYSYMBOL_paren_postfix_typedef_declarator = 433, /* paren_postfix_typedef_declarator  */
  YYSYMBOL_simple_paren_typedef_declarator = 434, /* simple_paren_typedef_declarator  */
  YYSYMBOL_identifier_declarator = 435,    /* identifier_declarator  */
  YYSYMBOL_unary_identifier_declarator = 436, /* unary_identifier_declarator  */
  YYSYMBOL_postfix_identifier_declarator = 437, /* postfix_identifier_declarator  */
  YYSYMBOL_paren_identifier_declarator = 438, /* paren_identifier_declarator  */
  YYSYMBOL_abstract_declarator = 439,      /* abstract_declarator  */
  YYSYMBOL_parameter_abstract_declarator = 440, /* parameter_abstract_declarator  */
  YYSYMBOL_cprover_function_contract = 441, /* cprover_function_contract  */
  YYSYMBOL_442_13 = 442,                   /* $@13  */
  YYSYMBOL_443_14 = 443,                   /* $@14  */
  YYSYMBOL_unary_expression_list = 444,    /* unary_expression_list  */
  YYSYMBOL_conditional_target_group = 445, /* conditional_target_group  */
  YYSYMBOL_conditional_target_list = 446,  /* conditional_target_list  */
  YYSYMBOL_conditional_target_list_opt_semicol = 447, /* conditional_target_list_opt_semicol  */
  YYSYMBOL_cprover_contract_assigns = 448, /* cprover_contract_assigns  */
  YYSYMBOL_cprover_contract_assigns_opt = 449, /* cprover_contract_assigns_opt  */
  YYSYMBOL_cprover_contract_frees = 450,   /* cprover_contract_frees  */
  YYSYMBOL_cprover_function_contract_sequence = 451, /* cprover_function_contract_sequence  */
  YYSYMBOL_cprover_function_contract_sequence_opt = 452, /* cprover_function_contract_sequence_opt  */
  YYSYMBOL_postfixing_abstract_declarator = 453, /* postfixing_abstract_declarator  */
  YYSYMBOL_454_15 = 454,                   /* $@15  */
  YYSYMBOL_parameter_postfixing_abstract_declarator = 455, /* parameter_postfixing_abstract_declarator  */
  YYSYMBOL_456_16 = 456,                   /* $@16  */
  YYSYMBOL_457_17 = 457,                   /* $@17  */
  YYSYMBOL_array_abstract_declarator = 458, /* array_abstract_declarator  */
  YYSYMBOL_unary_abstract_declarator = 459, /* unary_abstract_declarator  */
  YYSYMBOL_parameter_unary_abstract_declarator = 460, /* parameter_unary_abstract_declarator  */
  YYSYMBOL_postfix_abstract_declarator = 461, /* postfix_abstract_declarator  */
  YYSYMBOL_parameter_postfix_abstract_declarator = 462 /* parameter_postfix_abstract_declarator  */
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
typedef yytype_int16 yy_state_t;

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
#define YYFINAL  154
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   8172

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  231
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  232
/* YYNRULES -- Number of rules.  */
#define YYNRULES  668
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  1204

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   461


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   221,     2,     2,     2,   223,   216,     2,
     207,   208,   217,   218,   209,   219,   211,   222,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,   210,   230,
     224,   229,   225,   228,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,   212,     2,   213,   226,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   214,   227,   215,   220,     2,     2,     2,
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
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104,
     105,   106,   107,   108,   109,   110,   111,   112,   113,   114,
     115,   116,   117,   118,   119,   120,   121,   122,   123,   124,
     125,   126,   127,   128,   129,   130,   131,   132,   133,   134,
     135,   136,   137,   138,   139,   140,   141,   142,   143,   144,
     145,   146,   147,   148,   149,   150,   151,   152,   153,   154,
     155,   156,   157,   158,   159,   160,   161,   162,   163,   164,
     165,   166,   167,   168,   169,   170,   171,   172,   173,   174,
     175,   176,   177,   178,   179,   180,   181,   182,   183,   184,
     185,   186,   187,   188,   189,   190,   191,   192,   193,   194,
     195,   196,   197,   198,   199,   200,   201,   202,   203,   204,
     205,   206
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   305,   305,   311,   312,   313,   328,   332,   336,   340,
     344,   350,   351,   352,   353,   354,   358,   364,   370,   381,
     382,   383,   385,   386,   387,   388,   389,   390,   391,   395,
     405,   409,   416,   423,   433,   440,   451,   462,   474,   484,
     493,   503,   511,   518,   525,   538,   546,   557,   562,   564,
     570,   571,   575,   577,   583,   584,   588,   598,   599,   601,
     611,   621,   627,   633,   639,   646,   656,   670,   671,   675,
     680,   688,   689,   695,   701,   706,   717,   722,   727,   732,
     737,   742,   747,   752,   758,   764,   773,   774,   781,   786,
     794,   795,   797,   799,   804,   805,   807,   812,   813,   815,
     820,   821,   823,   825,   827,   832,   833,   835,   840,   841,
     846,   847,   852,   853,   858,   859,   864,   865,   870,   871,
     879,   880,   888,   889,   895,   896,   904,   912,   923,   924,
     931,   941,   942,   944,   946,   948,   950,   952,   954,   956,
     958,   960,   962,   967,   968,   973,   978,   979,   985,   991,
     997,   998,   999,  1003,  1011,  1023,  1022,  1035,  1034,  1047,
    1046,  1062,  1069,  1073,  1077,  1082,  1085,  1091,  1089,  1107,
    1105,  1121,  1139,  1137,  1154,  1155,  1156,  1157,  1158,  1162,
    1163,  1164,  1165,  1166,  1170,  1171,  1175,  1176,  1180,  1187,
    1188,  1195,  1202,  1203,  1210,  1211,  1215,  1216,  1217,  1218,
    1219,  1220,  1221,  1222,  1223,  1227,  1232,  1240,  1241,  1245,
    1246,  1247,  1251,  1252,  1259,  1263,  1267,  1271,  1278,  1282,
    1286,  1290,  1297,  1301,  1305,  1312,  1313,  1317,  1324,  1328,
    1332,  1339,  1343,  1347,  1354,  1358,  1362,  1369,  1373,  1377,
    1384,  1389,  1394,  1399,  1407,  1408,  1412,  1416,  1423,  1432,
    1433,  1437,  1441,  1448,  1452,  1456,  1463,  1464,  1468,  1472,
    1476,  1480,  1484,  1488,  1495,  1500,  1508,  1511,  1528,  1529,
    1530,  1531,  1532,  1533,  1534,  1535,  1536,  1537,  1559,  1560,
    1561,  1562,  1563,  1564,  1565,  1566,  1567,  1568,  1569,  1570,
    1571,  1572,  1573,  1574,  1575,  1576,  1577,  1578,  1579,  1580,
    1581,  1582,  1583,  1588,  1589,  1590,  1591,  1597,  1604,  1611,
    1615,  1616,  1617,  1621,  1626,  1640,  1637,  1658,  1654,  1678,
    1674,  1691,  1693,  1698,  1700,  1702,  1704,  1706,  1708,  1710,
    1712,  1714,  1716,  1718,  1720,  1722,  1724,  1730,  1733,  1738,
    1742,  1743,  1750,  1752,  1758,  1761,  1765,  1766,  1774,  1777,
    1781,  1786,  1794,  1795,  1796,  1801,  1808,  1820,  1828,  1858,
    1866,  1877,  1880,  1891,  1900,  1912,  1915,  1919,  1932,  1929,
    1949,  1945,  1975,  1976,  1982,  1983,  1987,  1991,  1998,  2002,
    2007,  2016,  2019,  2023,  2028,  2033,  2040,  2051,  2055,  2062,
    2063,  2072,  2077,  2084,  2093,  2098,  2106,  2114,  2121,  2129,
    2138,  2146,  2153,  2161,  2169,  2176,  2184,  2192,  2200,  2207,
    2218,  2219,  2223,  2227,  2232,  2236,  2245,  2249,  2259,  2260,
    2266,  2275,  2283,  2291,  2293,  2301,  2302,  2310,  2316,  2331,
    2338,  2345,  2353,  2360,  2368,  2380,  2381,  2382,  2386,  2387,
    2388,  2389,  2390,  2391,  2392,  2393,  2394,  2395,  2396,  2400,
    2410,  2413,  2417,  2418,  2422,  2431,  2439,  2446,  2455,  2466,
    2478,  2485,  2493,  2505,  2512,  2517,  2524,  2539,  2546,  2553,
    2562,  2563,  2567,  2586,  2607,  2606,  2646,  2663,  2670,  2672,
    2674,  2680,  2685,  2707,  2712,  2719,  2723,  2729,  2740,  2746,
    2755,  2764,  2772,  2780,  2785,  2793,  2803,  2805,  2806,  2807,
    2819,  2825,  2832,  2840,  2849,  2861,  2865,  2869,  2873,  2879,
    2889,  2894,  2902,  2906,  2910,  2916,  2926,  2931,  2939,  2943,
    2947,  2955,  2960,  2968,  2972,  2976,  2981,  2989,  2997,  2999,
    3003,  3004,  3008,  3013,  3017,  3018,  3022,  3026,  3033,  3056,
    3061,  3064,  3068,  3073,  3081,  3086,  3087,  3091,  3098,  3102,
    3106,  3110,  3118,  3122,  3126,  3134,  3139,  3149,  3150,  3151,
    3155,  3161,  3167,  3175,  3183,  3191,  3199,  3206,  3216,  3217,
    3218,  3222,  3229,  3239,  3247,  3248,  3252,  3253,  3258,  3262,
    3263,  3268,  3276,  3278,  3288,  3289,  3294,  3300,  3305,  3313,
    3315,  3320,  3330,  3331,  3336,  3337,  3341,  3342,  3347,  3354,
    3369,  3375,  3377,  3387,  3394,  3399,  3400,  3401,  3405,  3406,
    3411,  3410,  3422,  3421,  3432,  3433,  3437,  3443,  3451,  3458,
    3468,  3473,  3481,  3485,  3491,  3497,  3507,  3508,  3512,  3518,
    3527,  3528,  3537,  3538,  3555,  3557,  3568,  3567,  3590,  3592,
    3591,  3620,  3619,  3660,  3667,  3677,  3685,  3692,  3701,  3710,
    3723,  3731,  3741,  3746,  3758,  3769,  3777,  3787,  3792,  3804,
    3815,  3817,  3819,  3821,  3827,  3836,  3838,  3840,  3841
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
  "\"end of file\"", "error", "\"invalid token\"", "\"auto\"", "\"bool\"",
  "\"_BitInt\"", "\"break\"", "\"complex\"", "\"case\"", "\"char\"",
  "\"const\"", "\"continue\"", "\"default\"", "\"do\"", "\"double\"",
  "\"else\"", "\"enum\"", "\"extern\"", "\"float\"", "\"for\"", "\"goto\"",
  "\"if\"", "\"inline\"", "\"int\"", "\"long\"", "\"register\"",
  "\"restrict\"", "\"return\"", "\"short\"", "\"signed\"", "\"sizeof\"",
  "\"static\"", "\"struct\"", "\"switch\"", "\"typedef\"",
  "\"typeof_unqual\"", "\"union\"", "\"unsigned\"", "\"void\"",
  "\"volatile\"", "\"wchar_t\"", "\"while\"", "\"->\"", "\"++\"", "\"--\"",
  "\"<<\"", "\">>\"", "\"<=\"", "\">=\"", "\"==\"", "\"!=\"", "\"&&\"",
  "\"||\"", "\"...\"", "\"*=\"", "\"/=\"", "\"%=\"", "\"+=\"", "\"-=\"",
  "\"<<=\"", "\">>=\"", "\"&=\"", "\"^=\"", "\"|=\"", "TOK_GCC_IDENTIFIER",
  "TOK_MSC_IDENTIFIER", "TOK_TYPEDEFNAME", "TOK_INTEGER", "TOK_FLOATING",
  "TOK_CHARACTER", "TOK_STRING", "TOK_ASM_STRING", "\"__int8\"",
  "\"__int16\"", "\"__int32\"", "\"__int64\"", "\"__ptr32\"",
  "\"__ptr64\"", "\"typeof\"", "\"__auto_type\"", "\"_Float16\"",
  "\"_Float32\"", "\"_Float32x\"", "\"__float80\"", "\"_Float64\"",
  "\"_Float64x\"", "\"_Float128\"", "\"_Float128x\"", "\"__int128\"",
  "\"_Decimal32\"", "\"_Decimal64\"", "\"_Decimal128\"", "\"__asm__\"",
  "\"__asm__ (with parentheses)\"", "\"__attribute__\"", "\"aligned\"",
  "\"transparent_union\"", "\"packed\"", "\"vector_size\"", "\"mode\"",
  "\"__gnu_inline__\"", "\"weak\"", "\"alias\"", "\"section\"",
  "\"noreturn\"", "\"constructor\"", "\"destructor\"", "\"fallthrough\"",
  "\"used\"", "\"__label__\"", "\"__asm\"", "\"__based\"",
  "\"_var_arg_typeof\"", "\"__builtin_va_arg\"",
  "\"__builtin_types_compatible_p\"", "\"__builtin_has_attribute\"",
  "\"__builtin_convertvector\"", "\"__offsetof\"", "\"__alignof__\"",
  "\"__try\"", "\"__finally\"", "\"__except\"", "\"__leave\"",
  "\"__declspec\"", "\"__forceinline\"", "\"__interface\"", "\"__cdecl\"",
  "\"__stdcall\"", "\"__fastcall\"", "\"__clrcall\"", "\"forall\"",
  "\"exists\"", "\"\\\\forall\"", "\"\\\\exists\"", "\"\\\\lambda\"",
  "\"\\\\let\"", "\"array_of\"", "\"__CPROVER_bitvector\"",
  "\"__CPROVER_floatbv\"", "\"__CPROVER_fixedbv\"", "\"__CPROVER_atomic\"",
  "\"__CPROVER_bool\"", "\"__CPROVER_throw\"", "\"__CPROVER_catch\"",
  "\"__CPROVER_try\"", "\"__CPROVER_finally\"", "\"__CPROVER_ID\"",
  "\"__CPROVER_loop_invariant\"", "\"__CPROVER_decreases\"",
  "\"__CPROVER_requires\"", "\"__CPROVER_ensures\"",
  "\"__CPROVER_assigns\"", "\"__CPROVER_frees\"", "\"==>\"", "\"<==>\"",
  "\"^^\"", "\"TRUE\"", "\"FALSE\"", "\"__real__\"", "\"__imag__\"",
  "\"_Alignas\"", "\"_Atomic\"", "\"_Atomic()\"", "\"_Generic\"",
  "\"_Imaginary\"", "\"_Noreturn\"", "\"_Static_assert\"",
  "\"_Thread_local\"", "\"nullptr\"", "\"constexpr\"",
  "\"__builtin_bit_cast\"", "TOK_SCANNER_ERROR", "TOK_SCANNER_EOF",
  "\"catch\"", "\"char16_t\"", "\"char32_t\"", "\"class\"", "\"delete\"",
  "\"decltype\"", "\"explicit\"", "\"friend\"", "\"mutable\"",
  "\"namespace\"", "\"new\"", "\"nodiscard\"", "\"noexcept\"",
  "\"operator\"", "\"private\"", "\"protected\"", "\"public\"",
  "\"template\"", "\"this\"", "\"throw\"", "\"typeid\"", "\"typename\"",
  "\"try\"", "\"using\"", "\"virtual\"", "\"::\"", "\".*\"", "\"->*\"",
  "TOK_UNARY_TYPE_PREDICATE", "TOK_BINARY_TYPE_PREDICATE", "\"__uuidof\"",
  "\"__if_exists\"", "\"__if_not_exists\"", "\"__underlying_type\"", "'('",
  "')'", "','", "':'", "'.'", "'['", "']'", "'{'", "'}'", "'&'", "'*'",
  "'+'", "'-'", "'~'", "'!'", "'/'", "'%'", "'<'", "'>'", "'^'", "'|'",
  "'?'", "'='", "';'", "$accept", "grammar", "identifier", "typedef_name",
  "integer", "floating", "character", "string", "constant",
  "predefined_constant", "primary_expression", "generic_selection",
  "generic_assoc_list", "generic_association", "gcc_builtin_expressions",
  "clang_builtin_expressions", "cw_builtin_expressions", "offsetof",
  "offsetof_member_designator", "quantifier_expression",
  "cprover_contract_loop_invariant",
  "cprover_contract_loop_invariant_list",
  "cprover_contract_loop_invariant_list_opt",
  "ACSL_binding_expression_list", "cprover_contract_decreases_opt",
  "statement_expression", "postfix_expression", "member_name",
  "argument_expression_list", "unary_expression", "cast_expression",
  "multiplicative_expression", "additive_expression", "shift_expression",
  "relational_expression", "equality_expression", "and_expression",
  "exclusive_or_expression", "inclusive_or_expression",
  "logical_and_expression", "logical_xor_expression",
  "logical_or_expression", "logical_implication_expression",
  "logical_equivalence_expression", "ACSL_binding_expression",
  "conditional_expression", "assignment_expression", "comma_expression",
  "constant_expression", "comma_expression_opt", "declaration",
  "static_assert_declaration", "default_declaring_list", "@1", "@2", "$@3",
  "post_declarator_attribute", "post_declarator_attributes",
  "post_declarator_attributes_opt", "declaring_list", "@4", "@5", "$@6",
  "declaration_specifier", "type_specifier", "declaration_qualifier_list",
  "type_qualifier_list", "attribute_type_qualifier_list",
  "declaration_qualifier", "type_qualifier", "alignas_specifier",
  "attribute_or_type_qualifier",
  "attribute_or_type_qualifier_or_storage_class",
  "attribute_type_qualifier_storage_class_list",
  "basic_declaration_specifier", "basic_type_specifier",
  "sue_declaration_specifier", "sue_type_specifier",
  "typedef_declaration_specifier", "typeof_declaration_specifier",
  "atomic_declaration_specifier", "typedef_type_specifier",
  "typeof_specifier", "typeof_type_specifier", "atomic_specifier",
  "atomic_type_specifier", "msc_decl_identifier", "msc_decl_modifier",
  "msc_declspec_seq", "msc_declspec", "msc_declspec_opt", "storage_class",
  "basic_type_name", "elaborated_type_name", "array_of_construct",
  "pragma_packed", "aggregate_name", "$@7", "$@8", "$@9", "aggregate_key",
  "gcc_type_attribute", "gcc_attribute", "gcc_attribute_list",
  "gcc_attribute_specifier", "gcc_type_attribute_opt",
  "gcc_type_attribute_list", "member_declaration_list_opt",
  "member_declaration_list", "member_declaration",
  "member_default_declaring_list", "member_declaring_list",
  "member_declarator", "member_identifier_declarator",
  "bit_field_size_opt", "bit_field_size", "enum_name", "$@10", "$@11",
  "basic_type_name_list", "enum_underlying_type",
  "enum_underlying_type_opt", "braced_enumerator_list_opt", "enum_key",
  "enumerator_list_opt", "enumerator_list", "enumerator_declaration",
  "enumerator_value_opt", "parameter_type_list", "KnR_parameter_list",
  "KnR_parameter", "parameter_list", "parameter_declaration",
  "identifier_or_typedef_name", "type_name", "initializer_opt",
  "initializer", "initializer_list", "initializer_list_opt",
  "designated_initializer", "designator", "statement",
  "stmt_not_decl_or_attr", "declaration_statement",
  "gcc_attribute_specifier_opt", "msc_label_identifier",
  "labeled_statement", "statement_attribute", "compound_statement",
  "compound_scope", "statement_list", "expression_statement",
  "selection_statement", "declaration_or_expression_statement",
  "iteration_statement", "$@12", "jump_statement",
  "gcc_local_label_statement", "gcc_local_label_list", "gcc_local_label",
  "gcc_asm_statement", "msc_asm_statement", "msc_seh_statement",
  "cprover_exception_statement", "volatile_or_goto_opt",
  "gcc_asm_commands", "gcc_asm_assembler_template", "gcc_asm_outputs",
  "gcc_asm_output", "gcc_asm_output_list", "gcc_asm_inputs",
  "gcc_asm_input", "gcc_asm_input_list", "gcc_asm_clobbered_registers",
  "gcc_asm_clobbered_register", "gcc_asm_clobbered_registers_list",
  "gcc_asm_labels", "gcc_asm_labels_list", "gcc_asm_label",
  "translation_unit", "external_definition_list", "external_definition",
  "asm_definition", "function_definition", "function_body",
  "KnR_parameter_header_opt", "KnR_parameter_header",
  "KnR_parameter_declaration", "KnR_declaration_qualifier_list",
  "KnR_basic_declaration_specifier", "KnR_typedef_declaration_specifier",
  "KnR_sue_declaration_specifier", "KnR_declaration_specifier",
  "KnR_parameter_declaring_list", "function_head", "declarator",
  "paren_attribute_declarator", "typedef_declarator",
  "parameter_typedef_declarator", "clean_typedef_declarator",
  "clean_postfix_typedef_declarator", "paren_typedef_declarator",
  "paren_postfix_typedef_declarator", "simple_paren_typedef_declarator",
  "identifier_declarator", "unary_identifier_declarator",
  "postfix_identifier_declarator", "paren_identifier_declarator",
  "abstract_declarator", "parameter_abstract_declarator",
  "cprover_function_contract", "$@13", "$@14", "unary_expression_list",
  "conditional_target_group", "conditional_target_list",
  "conditional_target_list_opt_semicol", "cprover_contract_assigns",
  "cprover_contract_assigns_opt", "cprover_contract_frees",
  "cprover_function_contract_sequence",
  "cprover_function_contract_sequence_opt",
  "postfixing_abstract_declarator", "$@15",
  "parameter_postfixing_abstract_declarator", "$@16", "$@17",
  "array_abstract_declarator", "unary_abstract_declarator",
  "parameter_unary_abstract_declarator", "postfix_abstract_declarator",
  "parameter_postfix_abstract_declarator", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-1040)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-637)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    2032, -1040, -1040,  -126, -1040, -1040, -1040, -1040, -1040, -1040,
   -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040,
   -1040,  -114, -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040,
   -1040, -1040, -1040, -1040, -1040,   -84,    41, -1040, -1040, -1040,
   -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040,
     -58,    29,    39,    59, -1040,   -93,  -100,     2,    14, -1040,
   -1040,   163,    70, -1040,    76, -1040,   110, -1040,  1084,   261,
    4045,  1084, -1040,   340, -1040,   -38, -1040,   116,  -146,   -75,
     109,   648,  2447,  2447, -1040, -1040,  7482,  7482,  1479,  1479,
    1479,  1479,  1479,  1479,  1363,  1129,  1363,  1129, -1040, -1040,
     -38, -1040, -1040, -1040,   -38, -1040, -1040,   -38, -1040,  2032,
   -1040, -1040, -1040, -1040, -1040, -1040, -1040,    -7,  5520,  4996,
    4996,  1302,  1624,    -7,   180, -1040, -1040, -1040, -1040, -1040,
   -1040, -1040, -1040,   282,   150,  5520,    26,   -38,  5520,  5520,
    5520, -1040,  4996,   -38,  5520,   155,   288,   173,  4045, -1040,
   -1040, -1040, -1040, -1040, -1040, -1040, -1040,   -38, -1040,  1084,
   -1040,   -38, -1040, -1040,   180, -1040,   180,   -38, -1040, -1040,
     -38,   -38, -1040,   -38, -1040, -1040,   159,   -38, -1040,  1363,
    1363, -1040,   -38, -1040, -1040,   164,   -38,   -38, -1040,   -38,
     -38,   -38,   -38,   -38,   -38,   -38,   -38,   -38,   -38,  1511,
     -38,  1511,   -38, -1040, -1040,   235, -1040, -1040,   187, -1040,
     133,  3748, -1040, -1040,   194,  6335,  6432,  6432,   248, -1040,
   -1040, -1040, -1040,   206,   223,   237,   241,   254,   283,  6529,
   -1040, -1040, -1040, -1040, -1040, -1040, -1040,  6238,  6238,   294,
   -1040,   296,  4886,  6238,  6238,  6238,  6238,  6238,  6238, -1040,
   -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040,
   -1040, -1040, -1040, -1040,    73, -1040,   880,   143,   -60,   274,
       7,   408,   292,   291,   286,   472,   373,     8, -1040,   -52,
   -1040, -1040, -1040,   330, -1040,   259,  7762,   334,   275,   358,
    1168,  1768, -1040,   663,   365,   370,    -7,  1302,  1826, -1040,
   -1040, -1040, -1040, -1040, -1040,   180,   319, -1040,   377,  1646,
     289, -1040, -1040, -1040, -1040, -1040,   380, -1040,    45,   374,
     -77,   121,   129,   298,   406,   409,   318,    -7, -1040, -1040,
   -1040, -1040, -1040, -1040,    41,   416,   445, -1040, -1040, -1040,
   -1040,   391, -1040,  1511,  1511, -1040,   391, -1040, -1040, -1040,
   -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040,
   -1040,   343,  7943, -1040, -1040, -1040,   444,  2930,  7181,   158,
    7016, -1040,  5714,   452, -1040, -1040,  3907, -1040, -1040,  5617,
    4886, -1040,  4886, -1040, -1040, -1040, -1040,   -38,  5520,   -38,
    5520,  5520,   -38,  4886, -1040,   457,   460,  6686,  6686,  6686,
   -1040, -1040,  5520,   -38,   336,   470,   473, -1040, -1040, -1040,
   -1040, -1040, -1040,   248, -1040, -1040,  5106,   248,  5520,  5520,
    5520,  5520,  5520,  5520,  5520,  5520,  5520,  5520,  5520,  5520,
    6238,  6238,  6238,  6238,  6238,  6238,  6238,  6238,  6238,  6238,
    6238,  6238,  6238,  6238,  6238,  6238,  6238,  6238,  6238,  6238,
    6238,  5203, -1040, -1040,  5520,   217,  2765,  7853,  1363,  1363,
   -1040, -1040, -1040, -1040, -1040,   308,  1168,   475,    -7,    -7,
     479,   328,  1168, -1040, -1040,   130, -1040,  5313,   471,   483,
   -1040, -1040,   496,   498, -1040, -1040,   500,   509, -1040, -1040,
   -1040, -1040, -1040, -1040, -1040,   388, -1040,   385, -1040, -1040,
   -1040, -1040,   511,   518, -1040, -1040, -1040, -1040,  5520, -1040,
     391,   180,   391,   391,  5313, -1040, -1040, -1040,   524,   534,
   -1040, -1040,  8031, -1040,   537, -1040,   535,  5520,   539,   563,
     581, -1040,  5423,   568,  4336,   573,   575,   592,   600,   603,
     608, -1040,   248,   -25, -1040, -1040,   585, -1040, -1040,   609,
     596, -1040,   109,   648,  2447,  2447,   618, -1040, -1040, -1040,
     620, -1040, -1040, -1040,  3149, -1040, -1040, -1040, -1040, -1040,
   -1040, -1040, -1040, -1040,    41,  7622,  1129,  7482,  1479, -1040,
    7181, -1040,  7342,  7482,  1479, -1040,    41,    19,   287, -1040,
     396, -1040,   959,   959,  2282,  2282,   631,   654, -1040, -1040,
   -1040, -1040,   656, -1040,  5824,   664,   675,   676,   680,   685,
     686,   687,   690,   691,   694,  6686,  6686,  5520,  5520,  5520,
     701,   705, -1040,  5934, -1040, -1040, -1040, -1040, -1040,   399,
   -1040, -1040,   166, -1040, -1040, -1040, -1040, -1040, -1040, -1040,
   -1040, -1040, -1040, -1040, -1040, -1040, -1040, -1040,   143,   143,
     -60,   -60,   274,   274,   274,   274,     7,     7,   408,   292,
     291,   286,   472,   373, -1040, -1040,  6238,   427, -1040,   851,
    1034, -1040, -1040, -1040, -1040, -1040, -1040, -1040,    -7, -1040,
   -1040, -1040, -1040,   454, -1040, -1040, -1040,   282,  4776, -1040,
   -1040, -1040,  5520,  5520,   158,   833,   835,   710,  1646,   713,
     714,   699,  5520,  5520,   715, -1040, -1040, -1040, -1040, -1040,
      94,   716,   -38, -1040,   248,   717, -1040,   -16, -1040,  3368,
     722, -1040,   785,   737,   720,    32,  5520, -1040,    56,  5520,
    5520,   -38, -1040,    37,    66, -1040, -1040,   875,   522, -1040,
     165, -1040,   180,   180, -1040, -1040, -1040,  3368, -1040, -1040,
   -1040, -1040,   -38,   -38, -1040,   -38, -1040,   -38,   248,   248,
     -38,   -38,   -38, -1040,    41, -1040, -1040, -1040,   740, -1040,
   -1040, -1040,   287, -1040,  7181,   158,  1032,  1468,  1084, -1040,
     -38, -1040, -1040, -1040, -1040, -1040,   -38, -1040,  1128,  4018,
     -38, -1040,   -38, -1040,  7181,  6851, -1040, -1040, -1040,   738,
     738, -1040,   -38,   -38,   248,   -38,   248,   738,  5520,  5520,
   -1040, -1040, -1040,    78,  6432,  4776, -1040, -1040,  5520, -1040,
   -1040,  6238,   743,   745,   750,  1034, -1040, -1040, -1040, -1040,
     751,   747,   248,  5520,   753,   754, -1040,   752,   757, -1040,
    4446,   440,   459,   758,   759,   765, -1040, -1040, -1040, -1040,
     120,   176,   178, -1040,   391, -1040,   730,  7762,   760,   188,
   -1040,    97,   106,    94, -1040,   762,   756, -1040,   -38,   248,
     -38,  5520,  3368, -1040,  6044,   772, -1040,   785,   836,  3587,
   -1040, -1040,   512, -1040,   517,   773, -1040,  4226,   282,   914,
     248, -1040,   771, -1040,   780, -1040, -1040, -1040, -1040, -1040,
   -1040, -1040, -1040, -1040,   -38,   -38, -1040, -1040, -1040, -1040,
     782,   783,  6141, -1040, -1040,  7181, -1040, -1040,   786,   787,
    1468, -1040, -1040, -1040,  4018, -1040, -1040,   287, -1040, -1040,
     788,   790,   533,   792,    -4, -1040,   -19,     1,   791,   536,
   -1040,   795,   794,   784,   793, -1040, -1040, -1040,    -7,    -7,
   -1040, -1040,   -31,   796, -1040,    43,  5313,  4556, -1040,   248,
    5520,  5313, -1040, -1040, -1040, -1040, -1040, -1040,   545, -1040,
   -1040, -1040, -1040,  1076,  2606,   -38, -1040,   421, -1040,  1076,
   -1040,   797,   -38,   248,   778,   798, -1040,   799, -1040, -1040,
     196,   -57,   801, -1040,   781,   806,  5520, -1040,   811,  3368,
   -1040, -1040,  5520,  3368,  3368,   581, -1040, -1040,   812,   804,
   -1040, -1040, -1040,  5520, -1040, -1040, -1040, -1040,  5520,  5520,
   -1040,   814,    85, -1040, -1040, -1040, -1040, -1040,  5520, -1040,
   -1040,   248, -1040,   248,  5520, -1040, -1040,  5520, -1040,    78,
    5520, -1040,  4666, -1040, -1040, -1040,   248,   820, -1040,   827,
     -21,   828,  5520, -1040, -1040, -1040, -1040, -1040,    48, -1040,
   -1040,   120,  5520, -1040,   -38,   842, -1040,   -38,   842, -1040,
   -1040, -1040,   -38, -1040, -1040,  5520, -1040, -1040,  3368,  6432,
    6432,  6238, -1040,   845,  5520,  1013,   825,  1041, -1040,   785,
     831, -1040,   551,   849,   854, -1040,   856, -1040,   559, -1040,
   -1040,   203, -1040, -1040, -1040, -1040,   852,  5520,   -31,   248,
     859, -1040,   858,   282,   860,   251,  5520, -1040,   840, -1040,
   -1040,   -38, -1040, -1040,   -38, -1040, -1040, -1040, -1040, -1040,
     801, -1040, -1040, -1040,   582, -1040,   864,  5520,  3368,   836,
   -1040, -1040, -1040, -1040,   866, -1040,   282,   584, -1040,   869,
    5520,   -21, -1040, -1040,   870,   248, -1040, -1040,   267,   120,
   -1040, -1040, -1040, -1040,  5520,  5520,   877, -1040,  3368, -1040,
   -1040,   876, -1040,   282,   597, -1040,   282, -1040,   879, -1040,
   -1040,   882, -1040,   629,   581, -1040,  5520,   885, -1040, -1040,
     248, -1040,   863,   785,   636,  5520, -1040, -1040,   836, -1040,
     645,  3368, -1040, -1040
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
     528,   271,   304,     0,   305,   283,   197,   299,   380,   269,
     286,   273,   278,   285,   272,   198,   284,   300,   270,   321,
     268,     0,   322,   301,   303,   199,     3,     4,     6,   279,
     280,   281,   282,   201,   202,     0,     0,   287,   288,   289,
     292,   290,   291,   293,   294,   295,   296,   297,   298,   275,
       0,     0,     0,     0,   277,     0,     0,     0,     0,   200,
     309,     0,     0,   196,     0,   343,     0,   274,     0,     0,
       0,     0,   535,     0,   603,   344,   533,     0,     0,     0,
       0,     0,     0,     0,   189,   204,   174,   179,   175,   180,
     176,   177,   178,   181,   244,   182,   249,   183,   276,   184,
     344,   225,   312,   310,   344,   186,   311,   344,     2,   529,
     530,   534,   532,   463,   563,   594,   596,   595,     0,   344,
     344,     0,     0,   576,   165,   570,   569,   575,   578,   579,
     574,   584,   568,     0,     0,     0,     0,   344,     0,     0,
       0,     5,   344,   344,     0,     0,     0,     0,     0,   207,
     192,   208,   597,   598,     1,   346,   237,   345,   150,     0,
     152,   344,   151,   148,   165,   149,   165,   344,   188,   195,
     344,   344,   194,   344,   222,   187,   155,   344,   190,   245,
     250,   185,   344,   226,   191,   157,   344,   344,   220,   344,
     344,   344,   344,   344,   344,   344,   344,   344,   344,   247,
     344,   252,   344,   218,   266,   376,   531,   539,     0,   538,
     641,     0,   600,   634,   638,     0,     0,     0,     0,     7,
       8,     9,    10,     0,     0,     0,     0,     0,     0,     0,
     463,   463,   463,   463,   463,    17,    16,     0,     0,     0,
      18,     0,   344,     0,     0,     0,     0,     0,     0,    19,
      11,    12,    13,    14,    20,    15,    57,    28,    23,    24,
      25,    26,    27,    22,    71,    86,    90,    94,    97,   100,
     105,   108,   110,   112,   114,   116,   118,   120,   122,   128,
     131,   124,   145,     0,   143,     0,     0,     0,     0,     0,
       0,     0,   592,     0,     0,     0,     0,     0,     0,   573,
     580,   587,   577,   496,   164,   166,     0,   162,     0,   337,
       0,   255,   253,   254,   265,   261,   256,   262,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   601,   604,   537,
     193,   599,   347,   159,     0,   167,   169,   229,   232,   235,
     214,   416,   238,   246,   251,   219,   416,   216,   217,   215,
     221,   224,   227,   223,   230,   233,   236,   239,   228,   231,
     234,   315,     0,   410,   411,   368,   376,   146,   639,     0,
       0,   643,     0,     0,   209,   212,     0,   211,   210,     0,
     344,    81,   344,    72,    73,   485,    75,   344,     0,   344,
       0,     0,   344,   344,    83,     0,     0,     0,     0,     0,
      88,    89,     0,   344,     0,     0,     0,    74,    76,    77,
      78,    79,    80,     0,    63,    64,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   302,   242,     0,   412,   414,   179,   180,   181,
     182,   183,   243,   240,   241,     0,     0,     0,   582,   589,
       0,     0,     0,   581,   588,     0,   163,     0,     0,   326,
     324,   323,     0,     0,   329,   330,     0,     0,   333,   334,
     335,   338,   336,   339,   340,     0,   203,     0,   264,   263,
     313,   306,     0,     0,   205,   206,   248,   154,     0,   602,
     416,   165,   416,   416,     0,   156,   158,   267,     0,   319,
     375,   372,   374,   377,     0,   370,     0,     0,     0,     0,
     626,   474,     0,     0,     0,     0,     0,     3,     4,     6,
       0,   496,     0,     0,   463,   492,     0,   463,   460,   147,
       0,   449,     0,     0,     0,     0,   186,   464,   437,   435,
       0,   438,   436,   439,   146,   440,   441,   442,   443,   445,
     444,   446,   447,   448,     0,     0,   189,   179,   181,   545,
     635,   542,     0,   557,   558,   559,     0,     0,   632,   393,
       0,   391,   396,   403,   400,   407,     0,   389,   394,   645,
     646,   644,     0,   213,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    21,     0,    56,    67,    68,    62,    59,     0,
      69,    61,     0,   133,   134,   135,   136,   137,   138,   139,
     140,   141,   142,   132,    91,    92,    93,    90,    95,    96,
      98,    99,   103,   104,   101,   102,   106,   107,   109,   111,
     113,   115,   117,   119,   121,   123,     0,     0,   144,   641,
     650,   654,   413,   607,   605,   606,   415,   593,   571,   583,
     591,   590,   585,     0,   498,   499,   497,     0,   424,   418,
     171,   536,     0,     0,     0,     0,     0,     0,   337,     0,
       0,     0,     0,     0,     0,   160,   172,   168,   170,   417,
     344,     0,   344,   373,   381,   378,   479,     0,   478,   146,
       0,   627,    50,     0,     0,     0,     0,   480,     0,     0,
     146,   450,   462,     0,     0,   483,   489,     0,     0,   493,
       0,   466,   165,   165,   155,   157,   459,   146,   461,   465,
     561,   546,   344,   344,   543,   344,   547,   344,     0,     0,
     344,   344,   344,   560,     0,   544,   612,   610,     0,   630,
     614,   615,   633,   640,   540,     0,   641,   655,   659,   399,
     344,   397,   667,   608,   609,   406,   344,   404,   641,   655,
     344,   401,   344,   408,   540,     0,   647,   649,   648,    82,
       0,    39,   344,   344,     0,   344,     0,    84,     0,     0,
     125,   126,   127,   344,     0,   424,    87,    60,     0,    58,
     130,     0,     0,     0,     0,   651,   652,   572,   586,   505,
       0,   500,     0,     0,    19,     0,   425,   423,     0,   421,
       0,     0,     0,     0,     0,     0,   342,   341,   258,   257,
       0,     0,     0,   153,   416,   354,     0,     0,     0,   344,
     350,     0,     0,   344,   320,     0,   382,   383,   344,   381,
     344,     0,   146,   458,     0,     0,    48,    51,    54,   146,
     477,   476,     0,   481,     0,     0,   451,   146,     0,     0,
       0,   482,     0,   463,     0,   463,   463,   167,   169,   455,
     549,   552,   553,   548,   344,   344,   550,   551,   554,   562,
       0,     0,     0,   631,   637,   541,   392,   639,     0,     0,
     656,   657,   398,   405,   656,   402,   409,   632,   390,   395,
       0,     0,     0,     0,     0,    41,     0,     0,     0,     0,
      30,     0,     0,   423,     0,    70,   129,   662,   660,   661,
     653,   161,   507,   501,   429,     0,     0,     0,   419,     0,
       0,     0,   427,   327,   325,   328,   331,   332,     0,   307,
     308,   173,   355,   361,     0,   344,   351,     0,   353,   361,
     352,     0,   344,   385,   387,     0,   371,     0,   456,   625,
      86,     0,   618,   620,   623,     0,     0,    49,     0,   146,
     470,   471,   146,   146,   146,   626,   453,   454,     0,     0,
     484,   488,   491,     0,   494,   495,   555,   556,     0,     0,
     629,     0,   665,   666,   658,   642,    34,    35,     0,    36,
      38,     0,    40,     0,     0,    45,    46,     0,    29,   344,
       0,    85,     0,    65,   664,   663,     0,     0,   510,   506,
     513,   502,     0,   430,   428,   420,   422,   434,     0,   426,
     259,     0,     0,   358,   344,   365,   356,   344,   365,   314,
     357,   359,   344,   369,   384,     0,   386,   379,   146,     0,
       0,   622,   624,     0,     0,     0,     0,   467,   469,    50,
       0,   487,     0,     0,     0,   628,   641,   668,     0,    44,
      42,     0,    33,    31,    32,    66,     0,     0,     0,     0,
       0,   516,   512,   519,   503,     0,     0,   432,     0,   367,
     362,   344,   366,   364,   344,   316,   314,   388,   457,   616,
     619,   617,   621,    47,     0,    52,     0,   146,   146,    54,
     486,   463,   613,   611,     0,    43,     0,     0,   511,     0,
       0,     0,   520,   521,   518,   524,   504,   431,     0,     0,
     360,   363,   318,    55,     0,     0,     0,   468,   146,   490,
      37,     0,   508,     0,     0,   517,     0,   527,   523,   525,
     433,     0,    53,     0,   626,   472,     0,     0,   514,   522,
       0,   260,     0,    50,     0,     0,   526,   473,    54,   509,
       0,   146,   515,   475
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
   -1040, -1040,    58,    -3, -1040, -1040, -1040,  -125, -1040, -1040,
   -1040, -1040, -1040,    55, -1040, -1040, -1040, -1040, -1040, -1040,
     218, -1040, -1039, -1040, -1036, -1040, -1040,  -373,    74,  -188,
     981,   423,   424,   348,   426,   658,   655,   662,   657,   661,
     678, -1040,   432,  -851,  -531,  -618,   696,   183,  -107,  -695,
      24,  -621, -1040, -1040, -1040, -1040,   822, -1040,  -121, -1040,
   -1040, -1040, -1040,    12,    47,    16,     4,   -67,   -24,  1364,
   -1040,  -116,   763, -1040, -1040,  -269, -1040,  -233, -1040, -1040,
   -1040,  -149,   -76,  -139,   -63,  -118,  -479,   815, -1040,   768,
   -1040,  1233,   -73,   -61, -1040,     9, -1040, -1040, -1040, -1040,
     548, -1040,   436, -1040,     0,   502,   -85,   281, -1040,   297,
   -1040, -1040,   168,   181,    89,  -905, -1040, -1040, -1040, -1040,
   -1040,   803, -1040,   571,   290, -1040,   179, -1040, -1040, -1040,
     386, -1040,   369,  -140,   994,  -273,  -363,   350,   355,  -872,
   -1040,    77,   285,   300, -1040, -1040, -1040, -1040,  -112,   503,
   -1040,   301, -1040, -1040, -1040, -1040, -1040, -1040, -1040,  -213,
   -1040, -1040, -1040, -1040,   634,   295, -1040, -1040,    80, -1040,
   -1040,    31, -1040, -1040,    10, -1040, -1040, -1040,    -1, -1040,
   -1040,  1075, -1040, -1040, -1040,   397,   829,  -565, -1040, -1040,
   -1040, -1040, -1040, -1040, -1040,    -6,  1068, -1040,  -120,   -70,
   -1040,    71, -1040,   -95,   749,   -26, -1040,   157,  -425,  -450,
     428, -1040, -1040,   119,   122, -1040,   293,  -563,  -971, -1040,
   -1040,   279,   101, -1040,   257, -1040, -1040, -1040,   538,  -668,
     540,  -611
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,    73,   249,    75,   250,   251,   252,   253,   254,   255,
     256,   257,   939,   940,   258,   259,   260,   261,   934,   262,
     876,   877,   878,  1134,   999,   263,   264,   835,   629,   265,
     266,   267,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,   278,   279,   280,   281,   284,   549,   689,   550,
     551,    77,    78,   341,   346,   510,   304,   305,   306,    79,
     512,   513,   854,   552,   553,   554,   555,   298,   168,    84,
      85,   150,   375,   376,    86,    87,    88,    89,    90,    91,
      92,    93,    94,    95,    96,    97,   316,   317,   318,    98,
     361,    99,   100,   101,   102,  1125,   103,   518,   711,   712,
     104,   493,   494,   495,   155,   286,   157,   858,   859,   860,
     861,   862,  1063,  1066,  1121,  1064,   106,   524,   715,   522,
     523,   365,   870,   107,   865,   866,   867,  1076,   596,   590,
     591,   597,   598,   385,   941,   515,   836,   837,   838,   839,
     840,   557,   558,   559,   887,   560,   561,   562,   563,   208,
     564,   565,   566,  1002,   567,   723,   568,   569,   734,  1177,
     570,   571,   572,   573,   475,   830,   831,   953,  1048,  1049,
    1051,  1111,  1112,  1114,  1153,  1154,  1156,  1178,  1179,   108,
     109,   110,   111,   112,   209,   914,   915,   581,   582,   583,
     584,   585,   586,   587,   113,  1065,   125,   126,   127,   128,
     129,   130,   131,   471,   132,   115,   116,   117,   672,   921,
     769,   911,   910,   992,   993,   994,   995,   721,   722,   771,
     772,   773,   470,   369,   213,   588,   370,   214,   674,   783,
     675,   784
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
     105,   207,   300,   148,    83,   386,   170,   179,   308,   173,
     182,   283,    80,   187,   190,   754,    82,   457,   701,   171,
     180,   174,   183,   991,    76,   770,   296,   381,   383,   384,
     124,   676,   330,   123,  1089,   885,   293,   871,  1031,   222,
     627,   394,   145,   335,   631,   336,   736,    81,   820,   222,
    1139,   294,   311,   458,   437,   438,    51,   684,    74,   685,
     448,   991,   186,   159,   191,   366,   194,   195,   196,  1067,
     151,   311,  1067,   516,   164,   166,   686,   123,   123,   167,
     177,   118,   175,   184,   160,  1056,   810,   811,   812,   856,
     938,   312,   313,   119,    74,   145,  1052,   450,   199,   577,
     201,  1116,   450,  1168,   373,    26,    27,    28,   918,   105,
     312,   313,   138,    83,   690,   413,   414,   415,   292,   123,
     918,    80,   151,   120,   307,    82,    74,    65,    74,    74,
     406,   137,   454,    76,   161,   458,   501,   459,    74,    74,
      74,    74,   781,   787,   791,   793,   311,   460,   151,   133,
     684,   709,   685,  1079,  1198,   162,    81,   332,   433,   434,
    1122,   449,  1201,  1122,   307,   919,   307,    74,   461,   686,
    1056,   300,    51,    26,    27,    28,   451,   919,   473,    74,
      74,  1046,   330,   343,   344,   312,   313,    61,    51,   737,
     454,  1109,   295,   301,   872,   465,  1035,  -636,  -636,   184,
     210,   184,   364,   946,  1032,   211,    74,  1033,  1034,   770,
     454,   378,   293,  1193,   139,   364,  1036,    74,   212,   578,
     294,   519,    26,    27,   302,   146,   140,   294,   764,   460,
     991,   439,   440,   141,   314,   315,   134,   705,   856,   707,
     708,   454,   856,    65,   888,   826,   135,   212,   121,   765,
     461,   889,   454,   498,   315,    61,  1053,   454,   122,    65,
      66,  1117,   881,   363,   145,   454,   136,    71,   406,   602,
     406,   145,   605,   303,    51,   890,   363,   142,   146,  -636,
     416,   406,    51,   143,   417,   418,   883,   292,   123,   521,
     456,   151,  1096,   332,   292,   123,   891,   211,   151,    26,
      27,    28,   285,   288,    61,   307,   977,  1086,   895,  -348,
     896,   577,    26,    27,    28,   979,   121,   144,   310,   435,
     436,   320,   321,   322,   855,   323,   122,   978,   511,   735,
     454,   123,   147,   455,   502,    71,   980,   687,   454,   163,
     154,   368,   503,   184,   184,    65,   158,   458,    74,    74,
     754,    74,   222,    65,    66,    74,    74,   309,   364,   520,
     430,   295,   301,   327,   770,   431,   432,   556,   295,   474,
     105,   968,   575,  -566,   595,   454,   378,   683,  -567,   819,
     179,    61,   592,   182,   190,   454,   594,   454,   329,   969,
     706,   970,    74,   180,    61,   183,   294,   105,   105,   105,
     950,   367,   294,  -349,  -616,  -616,   379,    26,    27,    28,
     626,   311,   454,   387,   626,   574,  1145,   593,   855,   363,
     717,   617,   618,   619,   669,   404,  -616,   589,   509,   211,
     388,   578,   738,   935,   670,   740,   766,   767,   720,   768,
     145,   460,  1166,   671,   389,   362,   145,   146,   390,   713,
     312,   313,   699,   177,   146,   700,   184,   441,   442,   954,
     454,   391,   461,   292,  1157,  1083,    53,   453,   454,   292,
    1024,   625,   779,   785,  1024,   625,   454,   962,   170,   179,
    1180,   173,   182,   463,   454,    26,    27,  1093,  1094,    61,
     392,   171,   180,   174,   183,   210,   328,   496,   454,   179,
     211,   402,   182,   403,   190,   577,   504,   454,   443,   757,
     761,   307,   180,   445,   183,   210,   677,   444,   170,   179,
     211,   173,   182,   446,    74,   577,   507,   508,   447,   724,
      74,   171,   180,   174,   183,   210,   682,   295,   452,   364,
     211,   458,   462,   295,   622,   454,   742,   743,   477,   123,
     123,   167,   177,  1135,   175,   184,   673,   673,   756,   760,
     762,   458,   829,   404,   556,   404,   464,    61,   750,   679,
     680,   123,   177,   468,   868,   184,   404,   156,   469,   755,
     763,   971,  1118,   123,   575,   478,  1057,   497,   457,   123,
     123,   167,   177,  1054,   175,   184,   697,   698,  1059,   500,
     363,   632,   203,   825,   774,   775,   204,   817,   818,   205,
      74,    74,    74,    74,   505,   105,   105,   506,   904,   905,
     514,   897,   898,   146,   458,   578,   942,   574,    68,   146,
    -564,  1062,    74,  1182,   667,   460,   454,   821,    70,   808,
     809,   749,   893,   894,    74,   578,   577,    71,   963,   454,
      74,    74,    74,    74,   362,   460,   461,   300,  1099,  -565,
    1100,   210,   828,   334,   932,   600,   211,   964,   454,   337,
     151,   615,   338,   339,   616,   340,   461,  1010,   623,   342,
    1181,   624,   458,   678,   345,   626,   990,   681,   347,   348,
     692,   349,   350,   351,   352,   353,   354,   355,   356,   357,
     358,   691,   359,   693,   360,   694,   294,   695,   459,   330,
     920,   364,    26,    27,    28,   725,   696,   728,   460,   556,
    1003,   454,   924,   702,   990,  1004,   454,    26,    27,   868,
     703,   886,   720,   395,   396,   397,   398,   399,   710,   461,
    1028,  1029,   307,   307,  1038,  1039,   834,   556,  -317,   114,
     145,   714,   843,  1060,  1061,   364,   364,    51,   909,  1141,
     454,   123,   145,   829,   987,   716,   578,  1144,   818,   718,
     822,   673,   363,   719,   123,   726,   460,   151,   575,   827,
     729,  1012,   730,  1014,  1015,   652,   653,   654,   655,   151,
    1163,  1164,  1172,   454,    61,   105,   873,   461,   575,   595,
     473,   364,   731,   626,   330,  1188,   454,   592,   330,    61,
    -452,   594,   626,  -453,   282,   739,   363,   363,   454,   152,
     153,   574,    74,   732,   899,   151,   741,  1047,    65,   626,
     747,   176,   185,   589,    74,    74,    74,  1192,   454,   794,
     326,   574,   593,   868,  1199,   454,    74,    74,   746,   782,
     782,   782,   782,  1202,   454,   121,   648,   649,   114,   650,
     651,   974,   363,   795,   625,   122,   364,   656,   657,   796,
      68,   152,   556,   834,    71,   841,   842,   798,   165,   105,
      70,   664,   665,   799,   800,   851,   852,   364,   801,    71,
     625,  1129,  1131,   990,   802,   803,   804,   331,   179,   805,
     806,   182,   807,   844,   973,   845,  1106,   282,   333,   882,
     813,   180,   884,   183,   814,  -636,  -636,   123,   846,   575,
     151,   848,   849,   853,   151,  1110,   673,   363,   850,   874,
     863,   869,   875,   146,   419,   420,   421,   422,   423,   424,
     425,   426,   427,   428,   879,   146,   892,   912,   363,   988,
     880,   947,   815,   948,   626,  1119,   626,   952,   949,   951,
     972,   957,   574,   -67,   956,   983,   965,   966,  1127,  1149,
     123,   177,   958,   967,   184,   975,   123,   982,    74,   996,
     364,  1005,    74,  1047,   998,  1009,  1011,  1013,  1152,  1018,
    1019,   936,   937,  1042,  1022,  1023,  1026,  -636,  1027,   556,
    1030,  1037,  1041,   556,   556,  1040,  1050,  1075,  1043,  1078,
    1080,  1081,  1072,  1077,  1082,   834,   955,   625,  1084,  1091,
    1090,  1171,  1095,    26,    27,    28,  1110,  1107,   626,  1169,
     626,    74,    74,   782,   782,    74,  1108,    74,  1113,   626,
     152,   363,   467,   364,     6,   782,   782,   331,  1187,  1044,
    1045,  1152,  1062,  1133,  1136,  1137,  1138,  1142,   669,   368,
      15,  1140,  1143,   211,   917,  1146,  1150,  1151,   670,  1159,
    1155,  1165,   282,    25,  1170,   282,  1085,   671,   556,  1176,
    1087,  1088,  1173,  1186,   609,  1184,   611,   612,  1190,   625,
    1191,   625,  1195,  1197,  1103,   997,    26,    27,   620,   659,
     834,   658,  1098,   661,   363,    61,   364,   660,   662,   429,
      33,    34,   630,   287,   289,   633,   634,   635,   636,   637,
     638,   639,   640,   641,   642,   643,   663,   476,    51,   517,
     758,   319,     1,   499,   847,  1162,   324,   325,   556,   603,
      26,    27,    28,  1058,   981,    52,     9,  1071,    26,    27,
     668,    11,   364,   759,    14,  1128,   976,  1124,  1070,   985,
      18,   916,  1074,    20,   929,   943,   776,   363,   556,   525,
     944,   211,  1007,   282,    59,   733,   777,   782,    61,  1000,
    1001,   782,  1175,  1008,   206,   778,  1189,   364,  1148,  1196,
     299,   927,    26,    27,    62,    63,  1092,   580,  1130,    65,
     913,   556,     0,  1132,   704,  1021,  1025,   823,     0,   824,
     282,     0,   857,   363,   864,  1167,     0,  1101,   400,   401,
       0,    49,    61,   282,   407,   408,   409,   410,   411,   412,
      61,     0,    26,    27,    28,  1115,   405,     0,     0,   776,
     917,   669,     0,     0,   211,  1185,   211,     0,   363,   777,
       0,   670,    53,    54,   900,   901,     0,   902,   778,   903,
     671,     0,   906,   907,   908,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    61,     0,     0,     0,  1203,  1097,
       0,     0,   922,   121,     0,     0,  1062,     0,   923,     0,
    1147,    68,   925,   122,   926,     0,    67,     0,     0,  1158,
       0,    70,    71,   744,   745,     0,     0,     0,     0,     0,
      71,     0,     0,     0,    61,   172,   181,     0,     0,   172,
     189,   172,   193,   172,   172,   172,   198,     0,   200,     0,
     202,     0,     0,  1174,     0,   788,   917,     0,     0,     0,
     211,   780,   786,   790,   792,   789,     0,     0,  1183,     0,
       0,     0,     0,   408,   778,     0,     0,     0,     0,     0,
       0,   857,     0,     0,     0,   857,    26,    27,    28,  1194,
     984,     0,   986,     6,   606,   290,   607,     0,  1200,     0,
       0,   608,     0,   610,   282,   291,   613,   614,     0,    15,
       0,     0,     0,     0,    71,     0,    51,   621,     0,     0,
       0,     0,    25,     0,     0,     0,  1016,  1017,     0,     0,
       0,   644,   645,   646,   647,   647,   647,   647,   647,   647,
     647,   647,   647,   647,   647,   647,   647,   647,   647,   647,
     647,   647,     0,     0,   149,     0,     0,     0,     0,    33,
      34,     0,     0,     0,   377,     0,   169,   178,    61,     0,
     169,   188,   169,   192,   169,   169,   169,   197,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    65,     0,     0,
       0,     0,     0,     0,    52,     0,     0,  1069,     6,     0,
       0,     0,     1,     0,  1073,     0,   149,     0,     0,     6,
       0,     0,     0,     0,    15,     0,     9,     0,     0,     0,
       0,    11,     0,    59,    14,    15,     0,    25,     0,   290,
      18,   282,   149,    20,   945,     0,     0,     0,    25,   291,
       0,     6,     0,    62,    63,     0,   152,   153,    71,     0,
       0,     0,    26,    27,    28,     0,   282,    15,   152,     0,
       0,     0,     0,     0,    33,    34,     0,     0,     0,     0,
      25,     0,     0,     0,     0,    33,    34,     0,     0,     0,
       0,     0,    51,   178,     0,   178,  1120,   282,     0,  1123,
       0,    49,     0,     0,  1126,   374,     0,     0,     0,    52,
       0,     0,     0,     0,     0,   408,     0,    33,    34,     0,
      52,     0,     0,     0,     0,     0,     0,     0,   647,   647,
     647,   579,    53,    54,   816,    51,     0,     0,    59,   377,
       0,     0,     0,     0,    61,     0,     0,     0,     0,    59,
       0,     0,    52,  1160,     0,     0,  1161,     0,    62,    63,
       0,     0,     0,    65,     6,     0,     0,     0,     0,    62,
      63,     0,     0,     0,     0,     0,    67,   647,     0,     0,
      15,    59,   282,   282,     0,   149,     0,   282,     0,     0,
       0,     0,   149,    25,     0,     0,     0,     0,     0,   331,
       0,    62,    63,   331,     0,   776,    65,     0,     0,     0,
     211,     0,     0,     0,     0,   777,     0,     0,    26,    27,
      28,     0,     0,     0,   778,     0,     0,     0,     0,     0,
      33,    34,     0,     0,     0,     0,     0,   178,   178,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    51,     0,
       0,     0,     0,  1068,   630,     0,  1068,     0,     0,     0,
       0,     0,   576,  1102,     0,    52,  1104,     0,   282,     0,
     374,   479,   480,   481,   482,   483,   484,   485,   486,   487,
     488,   489,   490,   491,   492,     0,     0,     0,   282,     0,
       0,     0,     0,     0,    59,     0,     0,     0,     0,     0,
      61,   282,     0,     0,     0,     0,     0,     0,     6,     0,
       0,     0,     0,     0,    62,    63,     0,   172,   181,    65,
       0,     0,     0,     0,    15,     0,   930,   931,     0,   933,
       0,     0,   647,     0,     0,     0,     0,    25,     0,   751,
     752,   753,     0,   579,     0,   172,   172,   172,     0,     0,
     178,   188,   192,   197,     0,     0,     0,   172,   181,     0,
       0,   297,    26,    27,    28,     0,     6,     0,     0,     0,
       0,   122,     0,     0,    33,    34,     0,     0,     0,     0,
      71,     0,    15,     0,     0,   647,     0,     0,     0,     0,
       0,     0,    51,     0,     0,    25,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    52,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      26,    27,    28,   647,     0,     0,     0,     0,     0,     0,
       0,     0,    33,    34,     0,     0,     0,     0,    59,     0,
       0,     0,     0,     0,    61,     0,     0,     0,   169,   178,
      51,     0,     0,     0,     0,     0,     0,     0,    62,    63,
       0,     0,     0,    65,     0,     0,     0,    52,     0,   178,
       0,   188,   197,     0,   576,     0,   169,   169,   169,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   169,   178,
       0,     0,     0,     0,     0,     0,    59,     0,     0,     0,
       0,     0,    61,     0,     0,   466,     0,   647,     0,     0,
       0,     0,     0,     0,     0,   291,    62,    63,     0,     0,
       0,    65,     0,     0,    71,     0,     0,     0,     0,   647,
     647,     0,     0,     0,     0,     0,     0,   579,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   579,     0,     0,
       0,     0,     0,   472,   149,     1,     2,     3,     0,     4,
       0,     5,     6,   291,     0,     0,     7,     0,     8,     9,
      10,     0,    71,     0,    11,    12,    13,    14,    15,     0,
      16,    17,   647,    18,    19,   647,    20,    21,    22,    23,
      24,    25,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    26,    27,    28,     0,
       0,     0,     0,     0,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   576,     0,
       0,   149,     0,    52,     0,   647,     0,     0,   579,     0,
       0,     0,     0,   149,     0,    53,    54,     0,   576,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    55,    56,
      57,    58,    59,    60,     0,     0,     0,     0,    61,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   149,
       0,     0,    62,    63,    64,     0,     0,    65,    66,    67,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    68,
       0,     0,     0,     0,     0,     0,    69,     0,     0,    70,
       0,     0,     0,     0,     0,     0,     0,     0,    71,     0,
       0,     0,    72,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   576,
       0,     0,     0,     0,   149,     1,     2,     3,   149,     4,
       0,     5,     6,     0,     0,     0,     7,     0,     8,     9,
      10,     0,     0,     0,    11,    12,    13,    14,    15,     0,
      16,    17,     0,    18,    19,     0,    20,    21,    22,    23,
      24,    25,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   178,     0,
       0,     0,     0,     0,     0,     0,    26,    27,    28,     0,
       0,     0,     0,     0,    29,    30,    31,    32,    33,    34,
      35,     0,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,     0,    51,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    52,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    53,    54,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    55,    56,
      57,    58,    59,    60,     0,     0,     0,     0,    61,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    62,    63,    64,     0,     0,    65,     0,    67,
       1,     2,     3,     0,     4,     0,     5,     6,     0,     0,
       0,     7,     0,     8,     9,    10,     0,     0,     0,    11,
      12,    13,    14,    15,     0,    16,    17,     0,    18,    19,
       0,    20,    21,    22,    23,    24,    25,     0,     0,   788,
       0,     0,     0,     0,   211,     0,     0,     0,     0,   789,
       0,     0,     0,     0,     0,     0,     0,     0,   778,     0,
       0,    26,    27,    28,     0,     0,     0,     0,     0,    29,
      30,    31,    32,    33,    34,    35,     0,    37,    38,    39,
      40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
       0,    51,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    52,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      53,    54,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    55,    56,    57,    58,    59,    60,     0,
       0,     0,     0,    61,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    62,    63,    64,
       2,     3,    65,     4,    67,     5,     6,     0,     0,     0,
       7,     0,     8,     0,    10,     0,     0,     0,     0,    12,
      13,     0,    15,     0,    16,    17,     0,     0,    19,     0,
       0,    21,    22,    23,    24,    25,     0,     0,     0,     0,
       0,     0,     0,     0,    68,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    70,     0,     0,     0,     0,     0,
      26,    27,    28,    71,     0,     0,     0,     0,    29,    30,
      31,    32,    33,    34,    35,     0,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,     0,     0,
      51,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    52,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    55,    56,    57,    58,    59,    60,     0,     0,
       0,     0,    61,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    62,    63,    64,     2,
       3,    65,     4,     0,     5,     6,     0,     0,     0,     7,
       0,     8,     0,    10,     0,     0,     0,     0,    12,    13,
       0,    15,     0,    16,    17,     0,     0,    19,     0,     0,
      21,    22,    23,    24,    25,     0,     0,     0,     0,     0,
       0,     0,     0,    68,     0,     0,  1062,     0,     0,     0,
       0,     0,     0,    70,     0,     0,     0,     0,     0,     0,
       0,    28,    71,     0,     0,     0,     0,    29,    30,    31,
      32,    33,    34,    35,     0,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,    47,    48,     0,     0,    51,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    52,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    55,    56,    57,    58,    59,    60,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    62,    63,    64,     0,     0,
      65,     0,     0,     1,     2,     3,   526,     4,   527,     5,
       6,   528,   529,   530,     7,     0,     8,     9,    10,   531,
     532,   533,    11,    12,    13,    14,    15,   534,    16,    17,
     215,    18,    19,   535,    20,    21,    22,    23,    24,    25,
       0,   536,   669,   216,   217,     0,     0,   211,     0,     0,
       0,   218,   670,     0,     0,     0,     0,     0,     0,     0,
       0,   671,     0,     0,   537,   538,   539,   219,   220,   221,
     222,   540,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,    45,    46,
      47,    48,    49,   541,    51,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   542,
     543,    52,   223,   224,   225,   226,   227,   228,   229,   544,
       0,     0,   545,    53,    54,     0,     0,     0,     0,     0,
     230,   231,   232,   233,   234,     0,    55,    56,    57,    58,
      59,    60,   546,     0,   547,     0,    61,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   235,   236,   237,   238,
      62,    63,    64,   239,     0,    65,    66,    67,   240,     0,
     241,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   242,     0,     0,
       0,     0,     0,     0,  -463,   548,   243,   244,   245,   246,
     247,   248,     1,     2,     3,   526,     4,   527,     5,     6,
     528,   529,   530,     7,     0,     8,     9,    10,   531,   532,
     533,    11,    12,    13,    14,    15,   534,    16,    17,   215,
      18,    19,   535,    20,    21,    22,    23,    24,    25,     0,
     536,     0,   216,   217,     0,     0,     0,     0,     0,     0,
     218,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   537,   538,   539,   219,   220,   221,   222,
       0,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,    45,    46,    47,
      48,    49,   541,    51,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   542,   543,
      52,   223,   224,   225,   226,   227,   228,   229,   544,     0,
       0,   545,    53,    54,     0,     0,     0,     0,     0,   230,
     231,   232,   233,   234,     0,    55,    56,    57,    58,    59,
      60,   546,     0,   547,     0,    61,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   235,   236,   237,   238,    62,
      63,    64,   239,     0,    65,    66,    67,   240,     0,   241,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   242,     0,     0,     0,
       0,     0,     0,  -463,   748,   243,   244,   245,   246,   247,
     248,     1,     2,     3,   526,     4,   527,     5,     6,   528,
     529,   530,     7,     0,     8,     9,    10,   531,   532,   533,
      11,    12,    13,    14,    15,   534,    16,    17,   215,    18,
      19,   535,    20,    21,    22,    23,    24,    25,     0,   536,
       0,   216,   217,     0,     0,     0,     0,     0,     0,   218,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   537,   538,   539,   219,   220,   221,   222,     0,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    42,    43,    44,    45,    46,    47,    48,
      49,   541,    51,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   542,   543,    52,
     223,   224,   225,   226,   227,   228,   229,   544,     0,     0,
     545,    53,    54,     0,     0,     0,     0,     0,   230,   231,
     232,   233,   234,     0,    55,    56,    57,    58,    59,    60,
     546,     0,   547,     0,    61,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   235,   236,   237,   238,    62,    63,
      64,   239,     0,    65,    66,    67,   240,     0,   241,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   242,     0,     0,     0,     0,
       0,     0,  -463,     0,   243,   244,   245,   246,   247,   248,
       1,     2,     3,     0,     4,     0,     5,     6,     0,     0,
       0,     7,     0,     8,     9,    10,     0,     0,     0,    11,
      12,    13,    14,    15,     0,    16,    17,   215,    18,    19,
       0,    20,    21,    22,    23,    24,    25,     0,     0,     0,
     216,   217,     0,     0,     0,     0,     0,     0,   218,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    26,    27,    28,   219,   220,   221,   222,     0,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
       0,    51,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    52,   223,
     224,   225,   226,   227,   228,   229,     0,     0,     0,     0,
      53,    54,     0,     0,     0,     0,     0,   230,   231,   232,
     233,   234,     0,    55,    56,    57,    58,    59,    60,     0,
       0,     0,     0,    61,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   235,   236,   237,   238,    62,    63,    64,
     239,     1,    65,    66,    67,   240,     0,   241,     6,     0,
       0,     0,     0,     0,     0,     9,     0,     0,     0,     0,
      11,     0,     0,    14,    15,     0,     0,     0,   215,    18,
       0,     0,    20,     0,     0,     0,     0,    25,     0,     0,
       0,   216,   217,     0,   242,     0,     0,     0,     0,   218,
       0,     0,     0,   243,   244,   245,   246,   247,   248,     0,
       0,     0,    26,    27,     0,   219,   220,   221,   222,     0,
       0,     0,     0,     0,    33,    34,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      49,     0,    51,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    52,
     223,   224,   225,   226,   227,   228,   229,     0,     0,     0,
       0,    53,    54,     0,     0,     0,     0,     0,   230,   231,
     232,   233,   234,     0,     0,     0,     0,     0,    59,     0,
       0,     0,     0,     0,    61,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   235,   236,   237,   238,    62,    63,
       1,   239,     0,    65,     0,    67,   240,     6,   241,     0,
       0,     0,     0,     0,     9,     0,     0,     0,     0,    11,
       0,     0,    14,    15,     0,     0,     0,   215,    18,     0,
       0,    20,     0,     0,     0,     0,    25,     0,     0,     0,
     216,   217,     0,     0,     0,   242,     0,     0,   218,     0,
       0,   371,     0,     0,   243,   372,   245,   246,   247,   248,
       0,    26,    27,     0,   219,   220,   221,   222,     0,     0,
       0,     0,     0,    33,    34,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    49,
       0,    51,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    52,   223,
     224,   225,   226,   227,   228,   229,     0,     0,     6,     0,
      53,    54,     0,     0,     0,     0,     0,   230,   231,   232,
     233,   234,     0,     0,    15,     0,     0,    59,     0,     0,
       0,     0,     0,    61,     0,     6,     0,    25,     0,     0,
       0,     0,     0,   235,   236,   237,   238,    62,    63,     0,
     239,    15,    65,     0,    67,   240,     0,   241,     0,     0,
       0,     0,    26,    27,    25,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    33,    34,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    26,
      27,     0,    51,     0,   242,     0,     0,     0,     0,     0,
     601,    33,    34,   243,   244,   245,   246,   247,   248,    52,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    51,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    52,     0,    59,     0,
       0,     0,     0,     0,    61,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    62,    63,
       0,     0,     0,    65,     0,    59,     0,     0,     0,     0,
       0,    61,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    62,    63,     0,     0,     0,
      65,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   788,     0,     0,     0,     0,
     211,     0,   526,     0,   527,   789,     0,   528,   529,   530,
       0,     0,     0,     0,   778,   531,   532,   533,     0,     0,
       0,     0,    68,   534,     0,     0,   215,     0,     0,   535,
       0,     0,    70,     0,     0,     0,     0,   536,     0,   216,
     217,    71,     0,     0,     0,     0,     0,   218,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     537,   538,  1006,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   541,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   542,   543,     0,   223,   224,
     225,   226,   227,   228,   229,   544,     0,     0,   545,     0,
       0,     0,     0,     0,     0,     0,   230,   231,   232,   233,
     234,     0,     0,     0,     0,     0,   215,     0,   546,     0,
     547,     0,    61,     0,     0,     0,     0,     0,     0,   216,
     217,     0,   235,   236,   237,   238,     0,   218,     0,   239,
       0,     0,     0,     0,   240,     0,   241,     0,     0,     0,
      26,    27,     0,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   242,     0,     0,     0,     0,     0,     0,
    -463,     0,   243,   244,   245,   246,   247,   248,   223,   224,
     225,   226,   227,   228,   229,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   230,   231,   232,   233,
     234,     0,     0,     0,     0,     0,   215,     0,     0,     0,
       0,     0,    61,     0,     0,     0,     0,     0,     0,   216,
     217,     0,   235,   236,   237,   238,     0,   218,     0,   239,
       0,     0,     0,     0,   240,     0,   241,     0,     0,     0,
      26,    27,     0,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   242,     0,     0,     0,     0,     0,     0,
       0,     0,   243,   244,   245,   246,   247,   248,   223,   224,
     225,   226,   227,   228,   229,     0,   727,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   230,   231,   232,   233,
     234,     0,     0,     0,     0,     0,   215,     0,     0,     0,
       0,     0,    61,     0,     0,     0,     0,     0,     0,   216,
     217,     0,   235,   236,   237,   238,     0,   218,     0,   239,
       0,     0,     0,     0,   240,     0,   241,     0,     0,     0,
      26,    27,    28,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   242,     0,     0,     0,   959,   960,     0,
     688,     0,   243,   244,   245,   246,   247,   248,   223,   224,
     225,   226,   227,   228,   229,   961,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   230,   231,   232,   233,
     234,     0,     0,     0,     0,     0,   215,     0,     0,     0,
       0,     0,    61,     0,     0,     0,     0,     0,     0,   216,
     217,     0,   235,   236,   237,   238,     0,   218,     0,   239,
       0,     0,     0,     0,   240,     0,   241,     0,     0,     0,
      26,    27,    28,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   242,     0,     0,     0,   832,   833,     0,
     688,  1055,   243,   244,   245,   246,   247,   248,   223,   224,
     225,   226,   227,   228,   229,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   230,   231,   232,   233,
     234,     0,     0,     0,     0,     0,   215,     0,     0,     0,
       0,     0,    61,     0,     0,     0,     0,     0,     0,   216,
     217,     0,   235,   236,   237,   238,     0,   218,     0,   239,
       0,     0,     0,     0,   240,     0,   241,     0,     0,     0,
      26,    27,    28,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   242,     0,     0,     0,   832,   833,     0,
     688,  1105,   243,   244,   245,   246,   247,   248,   223,   224,
     225,   226,   227,   228,   229,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   230,   231,   232,   233,
     234,     0,     0,     0,     0,     0,   215,     0,     0,     0,
       0,     0,    61,     0,     0,     0,     0,     0,     0,   216,
     217,     0,   235,   236,   237,   238,     0,   218,     0,   239,
       0,     0,     0,     0,   240,     0,   241,     0,     0,     0,
      26,    27,     0,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      51,     0,     0,   242,     0,     0,     0,   832,   833,     0,
     688,     0,   243,   244,   245,   246,   247,   248,   223,   224,
     225,   226,   227,   228,   229,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   230,   231,   232,   233,
     234,     0,     0,     0,     0,     0,   215,     0,     0,     0,
       0,     0,    61,     0,     0,     0,     0,     0,     0,   216,
     217,     0,   235,   236,   237,   238,     0,   218,     0,   239,
       0,    65,     0,     0,   240,     0,   241,     0,     0,     0,
      26,    27,     0,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      51,     0,     0,   242,     0,     0,     0,     0,     0,     0,
    -463,     0,   243,   244,   245,   246,   247,   248,   223,   224,
     225,   226,   227,   228,   229,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   230,   231,   232,   233,
     234,     0,     0,     0,     0,     0,   215,     0,     0,     0,
       0,     0,    61,     0,     0,     0,     0,     0,     0,   216,
     217,     0,   235,   236,   237,   238,     0,   218,     0,   239,
       0,    65,     0,     0,   240,     0,   241,     0,     0,     0,
      26,    27,     0,   219,   220,   221,   222,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   242,     0,     0,     0,     0,     0,     0,
       0,     0,   243,   244,   245,   246,   247,   248,   223,   224,
     225,   226,   227,   228,   229,     0,     0,     0,     0,     0,
       0,     0,     0,   215,     0,     0,   230,   231,   232,   233,
     234,     0,     0,     0,     0,     0,   216,   217,     0,     0,
       0,     0,    61,     0,   218,     0,     0,     0,     0,     0,
       0,     0,   235,   236,   237,   238,     0,    26,    27,   239,
     219,   220,   221,   222,   240,     0,   241,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   242,   628,   223,   224,   225,   226,   227,
     228,   229,   243,   244,   245,   246,   247,   248,     0,     0,
       0,     0,     0,   230,   231,   232,   233,   234,     0,     0,
       0,     0,     0,   215,     0,     0,     0,     0,     0,    61,
       0,     0,     0,     0,     0,     0,   216,   217,     0,   235,
     236,   237,   238,     0,   218,     0,   239,     0,     0,     0,
       0,   240,     0,   241,     0,     0,     0,    26,    27,     0,
     219,   220,   221,   222,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     242,     0,     0,   666,     0,     0,     0,     0,     0,   243,
     244,   245,   246,   247,   248,   223,   224,   225,   226,   227,
     228,   229,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   230,   231,   232,   233,   234,     0,     0,
       0,     0,     0,   215,     0,     0,     0,     0,     0,    61,
       0,     0,     0,     0,     0,     0,   216,   217,     0,   235,
     236,   237,   238,     0,   218,     0,   239,     0,     0,     0,
       0,   240,     0,   241,     0,     0,     0,    26,    27,    28,
     219,   220,   221,   222,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     242,     0,     0,     0,     0,     0,     0,   688,     0,   243,
     244,   245,   246,   247,   248,   223,   224,   225,   226,   227,
     228,   229,     0,     0,     0,     0,     0,     0,     0,     0,
     215,     0,     0,   230,   231,   232,   233,   234,     0,     0,
       0,     0,     0,   216,   217,     0,     0,     0,     0,    61,
       0,   218,     0,     0,     0,     0,     0,     0,     0,   235,
     236,   237,   238,     0,    26,    27,   239,   219,   220,   221,
     222,   240,     0,   241,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     242,     0,   223,   224,   225,   226,   227,   228,   229,   243,
     244,   245,   246,   247,   248,     0,     0,   215,     0,     0,
     230,   231,   232,   233,   234,     0,     0,     0,     0,     0,
     216,   217,     0,     0,     0,     0,    61,     0,   218,     0,
       0,     0,     0,     0,     0,     0,   235,   236,   237,   238,
       0,    26,    27,   239,   219,   220,   221,   222,   240,     0,
     241,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   242,     0,   223,
     224,   225,   226,   227,   228,   229,   243,   244,   245,   246,
     247,   248,     0,     0,   215,     0,     0,   230,   231,   232,
     233,   234,     0,     0,     0,     0,     0,   216,   217,     0,
       0,     0,     0,    61,     0,   218,     0,     0,     0,     0,
       0,     0,     0,   235,   236,   237,   238,     0,    26,    27,
     239,   219,   220,   221,   222,   240,     0,   241,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   242,     0,   223,   224,   225,   226,
     227,   228,   229,   243,   604,   245,   246,   247,   248,     0,
       0,     0,     0,     0,   230,   231,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,     0,
      61,     0,     0,     0,     0,     0,     0,   216,   217,     0,
     235,   236,   237,   238,     0,   218,     0,   239,     0,     0,
       0,     0,   240,     0,   241,     0,     0,     0,    26,    27,
       0,   219,   220,   221,   222,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   242,     0,     0,     0,     0,     0,   599,     0,     0,
     243,   244,   245,   246,   247,   248,   223,   224,   225,   226,
     227,   228,   229,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   230,   231,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,     0,
      61,     0,     0,     0,     0,     0,     0,   216,   217,     0,
     235,   236,   237,   238,     0,   218,     0,   239,     0,     0,
       0,     0,   240,     0,   241,     0,     0,     0,    26,    27,
       0,   219,   220,   221,   222,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   242,     0,     0,     0,     0,     0,   797,     0,     0,
     243,   244,   245,   246,   247,   248,   223,   224,   225,   226,
     227,   228,   229,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   230,   231,     0,     0,     0,     0,
       0,     0,     0,     0,   215,     0,     0,     0,     0,     0,
      61,     0,     0,     0,     0,     0,     0,   216,   217,     0,
     235,   236,   237,   238,     0,   218,     0,   239,     0,     0,
       0,     0,   240,     0,   241,     0,     0,     0,    26,    27,
       0,   219,   220,   221,   222,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   242,     0,     0,     0,     0,     0,     0,   815,     0,
     243,   244,   245,   246,   247,   248,   223,   224,   225,   226,
     227,   228,   229,     0,     0,     0,     0,     0,     0,     0,
       0,   215,     0,     0,   230,   231,     0,     0,     0,     0,
       0,     0,     0,     0,   216,   217,     0,     0,     0,     0,
      61,     0,   218,     0,     0,     0,     0,     0,     0,     0,
     235,   236,   237,   238,     0,    26,    27,   239,   219,   220,
     221,   222,   240,     0,   241,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   242,   989,   223,   224,   225,   226,   227,   228,   229,
     243,   244,   245,   246,   247,   248,     0,     0,   215,     0,
       0,   230,   231,     0,     0,     0,     0,     0,     0,     0,
       0,   216,   217,     0,     0,     0,     0,    61,     0,   218,
       0,     0,     0,     0,     0,     0,     0,   235,   236,   237,
     238,     0,    26,    27,   239,   219,   220,   221,   222,   240,
       0,   241,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   242,  1020,
     223,   224,   225,   226,   227,   228,   229,   243,   244,   245,
     246,   247,   248,     0,     0,   215,     0,     0,   230,   231,
       0,     0,     0,     0,     0,     0,     0,     0,   216,   217,
       0,     0,     0,     0,    61,     0,   218,     0,     0,     0,
       0,     0,     0,     0,   235,   236,   237,   238,     0,    26,
      27,   239,   219,   220,   221,   222,   240,     0,   241,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   242,     0,   223,   224,   225,
     226,   227,   228,   229,   243,   244,   245,   246,   247,   248,
       0,     0,   215,     0,     0,   230,   231,     0,     0,     0,
       0,     0,     0,     0,     0,   216,   217,     0,     0,     0,
       0,    61,     0,   218,     0,     0,     0,     0,     0,     0,
       0,   235,   236,     0,     0,     0,    26,    27,   239,   219,
     220,   221,   222,   240,     0,   241,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   380,     0,   223,   224,   225,   226,   227,   228,
     229,   243,   244,   245,   246,   247,   248,     0,     0,   215,
       0,     0,   230,   231,     0,     0,     0,     0,     0,     0,
       0,     0,   216,   217,     0,     0,     0,     0,    61,     0,
     218,     0,     0,     0,     0,     0,     0,     0,   235,   236,
       0,     0,     0,    26,    27,   239,   219,   220,   221,   222,
     240,     0,   241,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   382,
       0,   223,   224,   225,   226,   227,   228,   229,   243,   244,
     245,   246,   247,   248,     0,     0,     0,     0,     0,   230,
     231,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    61,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   235,   236,     0,     0,     1,
       2,     3,   239,     4,     0,     5,     6,   240,     0,   241,
       7,     0,     8,     9,    10,     0,     0,     0,    11,    12,
      13,    14,    15,     0,    16,    17,     0,    18,    19,     0,
      20,    21,    22,    23,    24,    25,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   393,     0,     0,     0,
       0,     0,     0,     0,     0,   243,   244,   245,   246,   247,
     248,     0,    28,     0,     0,     0,     0,     0,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,     0,
      51,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    52,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    53,
      54,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    55,    56,    57,    58,    59,    60,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    62,    63,    64,     0,
       0,    65,    66,    67,     1,     2,     3,     0,     4,     0,
       5,     6,     0,     0,     0,     7,     0,     8,     9,    10,
       0,     0,     0,    11,    12,    13,    14,    15,     0,    16,
      17,     0,    18,    19,     0,    20,    21,    22,    23,    24,
      25,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   928,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    28,     0,     0,
       0,     0,     0,    29,    30,    31,    32,    33,    34,    35,
       0,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,     0,    51,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    52,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    53,    54,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    55,    56,    57,
      58,    59,    60,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    62,    63,    64,     0,     0,    65,     0,    67,     1,
       2,     3,     0,     4,     0,     5,     6,     0,     0,     0,
       7,     0,     8,     9,    10,     0,     0,     0,    11,    12,
      13,    14,    15,     0,    16,    17,     0,    18,    19,     0,
      20,    21,    22,    23,    24,    25,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    28,     0,     0,     0,     0,     0,    29,    30,
      31,    32,    33,    34,    35,     0,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    46,    47,    48,    49,     0,
      51,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    52,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    53,
      54,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    55,    56,    57,    58,    59,    60,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    62,    63,    64,     0,
       0,    65,     0,    67,     1,     2,     3,     0,     4,     0,
       5,     6,     0,     0,     0,     7,     0,     8,     9,    10,
       0,     0,     0,    11,    12,    13,    14,    15,     0,    16,
      17,     0,    18,    19,     0,    20,    21,    22,    23,    24,
      25,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    28,     0,     0,
       0,     0,     0,    29,    30,    31,    32,    33,    34,    35,
       0,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    52,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    53,    54,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    55,    56,    57,
      58,    59,    60,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    62,    63,    64,     0,     1,     2,     3,    67,     4,
       0,     5,     6,     0,     0,     0,     7,     0,     8,     9,
      10,     0,     0,     0,    11,    12,    13,    14,    15,     0,
      16,    17,     0,    18,    19,     0,    20,     0,    22,    23,
      24,    25,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    28,     0,
       0,     0,     0,     0,    29,    30,    31,    32,    33,    34,
       0,     0,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    52,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    53,    54,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    56,
      57,    58,    59,    60,     0,     1,     2,     3,     0,     4,
       0,     5,     6,     0,     0,     0,     7,     0,     0,     9,
      10,     0,    62,    63,    11,    12,    13,    14,    15,    67,
      16,    17,     0,    18,     0,     0,    20,     0,     0,    23,
      24,    25,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    29,    30,    31,    32,    33,    34,
       0,     0,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    52,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    53,    54,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    56,
      57,    58,    59,    60,     0,     0,     2,     3,     0,     4,
       0,     5,     6,     0,     0,     0,     7,     0,     8,     0,
      10,     0,    62,    63,     0,    12,    13,     0,    15,    67,
      16,    17,     0,     0,    19,     0,     0,    21,    22,    23,
      24,    25,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    28,     0,
       0,     0,     0,     0,    29,    30,    31,    32,    33,    34,
      35,     0,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,     0,     0,    51,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    52,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    55,    56,
      57,    58,    59,    60,     0,     0,     2,     3,     0,     4,
       0,     5,     6,     0,     0,     0,     7,     0,     8,     0,
      10,     0,    62,    63,    64,    12,    13,    65,    15,     0,
      16,    17,     0,     0,    19,     0,     0,    21,    22,    23,
      24,    25,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    28,     0,
       0,     0,     0,     0,    29,    30,    31,    32,    33,    34,
      35,     0,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,     0,     0,     0,     2,     3,     0,
       4,     0,     5,     6,     0,     0,     0,     7,     0,     0,
       0,    10,     0,    52,     0,     0,    12,    13,     0,    15,
       0,    16,    17,     0,     0,     0,     0,     0,     0,     0,
      23,    24,    25,     0,     0,     0,     0,     0,    55,    56,
      57,    58,    59,    60,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    62,    63,    64,    29,    30,    31,    32,    33,
      34,     0,     0,    37,    38,    39,    40,    41,    42,    43,
      44,    45,    46,    47,    48,     0,     0,     2,     3,     0,
       4,     0,     5,     0,     0,     0,     0,     7,     0,     0,
       0,    10,     0,     0,    52,     0,    12,    13,     0,     0,
       0,    16,    17,     0,     0,     0,     0,     0,     0,     0,
      23,    24,     0,     0,     0,     0,     0,     0,     0,     0,
      56,    57,    58,    59,    60,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    28,
       0,     0,     0,    62,    63,    29,    30,    31,    32,     0,
       0,     0,     0,    37,    38,    39,    40,    41,    42,    43,
      44,    45,    46,    47,    48,     2,     3,     0,     4,     0,
       5,     0,     0,     0,     0,     7,     0,     0,     0,    10,
       0,     0,     0,     0,    12,    13,     0,     0,     0,    16,
      17,     0,     0,     0,     0,     0,     0,     0,    23,    24,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      56,    57,    58,     0,    60,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    29,    30,    31,    32,     0,     0,     0,
       0,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    56,    57,
      58,     0,    60
};

static const yytype_int16 yycheck[] =
{
       0,   113,   122,    70,     0,   218,    82,    83,   133,    82,
      83,   118,     0,    86,    87,   580,     0,   286,   497,    82,
      83,    82,    83,   874,     0,   588,   121,   215,   216,   217,
      36,   456,   148,    36,  1005,   730,   121,    53,    42,    70,
     413,   229,    68,   164,   417,   166,    71,     0,   666,    70,
    1089,   121,    26,   286,    47,    48,    94,    20,     0,    22,
      52,   912,    86,   209,    88,   205,    90,    91,    92,   974,
      70,    26,   977,   346,    80,    81,    39,    80,    81,    82,
      83,   207,    82,    83,   230,   957,   617,   618,   619,   710,
      12,    65,    66,   207,    36,   121,    53,   154,    94,   368,
      96,    53,   154,  1139,   211,    64,    65,    66,   776,   109,
      65,    66,   212,   109,   477,    42,    43,    44,   121,   122,
     788,   109,   122,   207,   124,   109,    68,   165,    70,    71,
     242,   224,   209,   109,   209,   368,   213,   286,    80,    81,
      82,    83,   592,   593,   594,   595,    26,   286,   148,   207,
      20,   514,    22,   210,  1193,   230,   109,   157,   218,   219,
    1065,   153,  1198,  1068,   164,   776,   166,   109,   286,    39,
    1042,   291,    94,    64,    65,    66,   228,   788,   298,   121,
     122,   212,   298,   179,   180,    65,    66,   146,    94,   214,
     209,   212,   121,   122,   210,   290,   215,    64,    65,   199,
     207,   201,   205,   821,   208,   212,   148,   211,   212,   772,
     209,   211,   297,  1184,   212,   218,   215,   159,   117,   368,
     290,   361,    64,    65,   123,    68,   212,   297,   209,   368,
    1081,   224,   225,    70,   208,   209,   207,   510,   859,   512,
     513,   209,   863,   165,   207,   670,   207,   146,   207,   230,
     368,   214,   209,   208,   209,   146,   213,   209,   217,   165,
     166,   213,   230,   205,   290,   209,   207,   226,   380,   376,
     382,   297,   379,    93,    94,   209,   218,   207,   121,   146,
     207,   393,    94,   207,   211,   212,   230,   290,   291,   362,
     286,   291,   207,   293,   297,   298,   230,   212,   298,    64,
      65,    66,   119,   120,   146,   305,   209,  1002,   143,   215,
     145,   580,    64,    65,    66,   209,   207,   207,   135,    45,
      46,   138,   139,   140,   230,   142,   217,   230,   334,   542,
     209,   334,    71,   286,   213,   226,   230,   207,   209,   230,
       0,   208,   213,   343,   344,   165,   230,   580,   290,   291,
     915,   293,    70,   165,   166,   297,   298,   207,   361,   362,
     217,   290,   291,   208,   927,   222,   223,   367,   297,   298,
     370,   850,   368,   214,   370,   209,   376,   472,   214,   213,
     456,   146,   370,   456,   457,   209,   370,   209,   215,   213,
     511,   213,   334,   456,   146,   456,   466,   397,   398,   399,
     825,   214,   472,   215,   208,   209,   212,    64,    65,    66,
     413,    26,   209,   207,   417,   368,   213,   370,   230,   361,
     527,   397,   398,   399,   207,   242,   230,   369,   327,   212,
     207,   580,   544,   806,   217,   547,   149,   150,   151,   152,
     466,   580,  1137,   226,   207,   210,   472,   290,   207,   522,
      65,    66,    67,   456,   297,    70,   456,    49,    50,   832,
     209,   207,   580,   466,   213,   996,   123,   208,   209,   472,
     920,   413,   592,   593,   924,   417,   209,   840,   554,   555,
     213,   554,   555,   208,   209,    64,    65,  1018,  1019,   146,
     207,   554,   555,   554,   555,   207,   208,   208,   209,   575,
     212,   207,   575,   207,   577,   774,   208,   209,   216,   582,
     583,   511,   575,   227,   575,   207,   208,   226,   594,   595,
     212,   594,   595,    51,   466,   794,   208,   209,   155,   532,
     472,   594,   595,   594,   595,   207,   208,   466,   208,   542,
     212,   774,   208,   472,   208,   209,   552,   553,   229,   552,
     553,   554,   555,  1084,   554,   555,   455,   456,   582,   583,
     584,   794,   687,   380,   564,   382,   208,   146,   574,   468,
     469,   574,   575,   208,   714,   575,   393,    75,   208,   582,
     586,   854,  1061,   586,   580,   208,   959,   207,   857,   592,
     593,   594,   595,   956,   594,   595,   208,   209,   961,   225,
     542,   418,   100,   670,   208,   209,   104,   208,   209,   107,
     552,   553,   554,   555,   208,   615,   616,   208,   758,   759,
     229,   742,   743,   466,   857,   774,   814,   580,   207,   472,
     214,   210,   574,  1164,   451,   774,   209,   210,   217,   615,
     616,   564,   120,   121,   586,   794,   915,   226,   208,   209,
     592,   593,   594,   595,   210,   794,   774,   777,  1031,   214,
    1033,   207,   208,   161,   804,   213,   212,   208,   209,   167,
     670,   214,   170,   171,   214,   173,   794,   890,   208,   177,
    1159,   208,   915,   208,   182,   688,   874,   208,   186,   187,
     207,   189,   190,   191,   192,   193,   194,   195,   196,   197,
     198,   230,   200,   207,   202,   207,   776,   207,   857,   825,
     777,   714,    64,    65,    66,   532,   207,   534,   857,   719,
     208,   209,   789,   212,   912,   208,   209,    64,    65,   869,
     212,   731,   151,   230,   231,   232,   233,   234,   214,   857,
     207,   208,   742,   743,   208,   209,   688,   747,   214,     0,
     776,   214,   694,   208,   209,   758,   759,    94,   764,   208,
     209,   764,   788,   888,   871,   230,   915,   208,   209,   230,
     669,   670,   714,   210,   777,   207,   915,   777,   774,   678,
     207,   893,   207,   895,   896,   437,   438,   439,   440,   789,
     208,   209,   208,   209,   146,   795,   719,   915,   794,   795,
     920,   804,   210,   806,   920,   208,   209,   795,   924,   146,
     210,   795,   815,   210,   118,   230,   758,   759,   209,    70,
      71,   774,   764,   215,   747,   825,   230,   952,   165,   832,
     210,    82,    83,   775,   776,   777,   778,   208,   209,   208,
     144,   794,   795,   983,   208,   209,   788,   789,   230,   592,
     593,   594,   595,   208,   209,   207,   433,   434,   109,   435,
     436,   857,   804,   209,   806,   217,   869,   441,   442,   213,
     207,   122,   872,   815,   226,   692,   693,   213,   230,   879,
     217,   449,   450,   208,   208,   702,   703,   890,   208,   226,
     832,  1079,  1080,  1081,   209,   209,   209,   148,   974,   209,
     209,   974,   208,    70,   857,    70,  1046,   211,   159,   726,
     209,   974,   729,   974,   209,    64,    65,   920,   208,   915,
     920,   208,   208,   208,   924,  1050,   825,   869,   229,   207,
     214,   214,   147,   776,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,   207,   788,    71,   207,   890,   872,
     230,   208,   214,   208,   957,  1062,   959,   210,   208,   208,
     230,   209,   915,   210,   210,   209,   208,   208,  1075,  1109,
     973,   974,   215,   208,   974,   215,   979,   215,   920,   207,
     983,   208,   924,  1108,   148,    71,   215,   207,  1113,   207,
     207,   808,   809,   209,   208,   208,   208,   146,   208,   999,
     208,   210,   208,  1003,  1004,   210,   210,   229,   215,   210,
     209,   230,   215,   215,   208,   957,   833,   959,   207,   215,
     208,  1146,   208,    64,    65,    66,  1151,   207,  1031,  1141,
    1033,   973,   974,   776,   777,   977,   209,   979,   210,  1042,
     291,   983,   293,  1046,    10,   788,   789,   298,  1173,   948,
     949,  1176,   210,   208,    41,   230,    15,   208,   207,   208,
      26,   230,   208,   212,   208,   213,   207,   209,   217,   229,
     210,   207,   376,    39,   208,   379,   999,   226,  1078,   209,
    1003,  1004,   213,   207,   388,   208,   390,   391,   209,  1031,
     208,  1033,   207,   230,  1039,   877,    64,    65,   402,   444,
    1042,   443,  1028,   446,  1046,   146,  1109,   445,   447,   229,
      76,    77,   416,   119,   120,   419,   420,   421,   422,   423,
     424,   425,   426,   427,   428,   429,   448,   305,    94,   361,
     582,   137,     3,   318,   698,  1126,   142,   143,  1138,   376,
      64,    65,    66,   960,   863,   111,    17,   979,    64,    65,
     454,    22,  1155,   582,    25,  1078,   859,  1068,   977,   869,
      31,   775,   983,    34,   795,   815,   207,  1109,  1168,   366,
     815,   212,   887,   477,   140,   541,   217,   920,   146,   879,
     879,   924,  1151,   888,   109,   226,  1176,  1190,  1108,  1190,
     122,   794,    64,    65,   160,   161,  1013,   368,  1079,   165,
     772,  1201,    -1,  1081,   508,   912,   927,   669,    -1,   669,
     514,    -1,   710,  1155,   712,  1138,    -1,  1034,   237,   238,
      -1,    92,   146,   527,   243,   244,   245,   246,   247,   248,
     146,    -1,    64,    65,    66,  1052,   242,    -1,    -1,   207,
     208,   207,    -1,    -1,   212,  1168,   212,    -1,  1190,   217,
      -1,   217,   123,   124,   752,   753,    -1,   755,   226,   757,
     226,    -1,   760,   761,   762,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   146,    -1,    -1,    -1,  1201,  1022,
      -1,    -1,   780,   207,    -1,    -1,   210,    -1,   786,    -1,
    1107,   207,   790,   217,   792,    -1,   167,    -1,    -1,  1116,
      -1,   217,   226,   554,   555,    -1,    -1,    -1,    -1,    -1,
     226,    -1,    -1,    -1,   146,    82,    83,    -1,    -1,    86,
      87,    88,    89,    90,    91,    92,    93,    -1,    95,    -1,
      97,    -1,    -1,  1150,    -1,   207,   208,    -1,    -1,    -1,
     212,   592,   593,   594,   595,   217,    -1,    -1,  1165,    -1,
      -1,    -1,    -1,   372,   226,    -1,    -1,    -1,    -1,    -1,
      -1,   859,    -1,    -1,    -1,   863,    64,    65,    66,  1186,
     868,    -1,   870,    10,   380,   207,   382,    -1,  1195,    -1,
      -1,   387,    -1,   389,   688,   217,   392,   393,    -1,    26,
      -1,    -1,    -1,    -1,   226,    -1,    94,   403,    -1,    -1,
      -1,    -1,    39,    -1,    -1,    -1,   904,   905,    -1,    -1,
      -1,   430,   431,   432,   433,   434,   435,   436,   437,   438,
     439,   440,   441,   442,   443,   444,   445,   446,   447,   448,
     449,   450,    -1,    -1,    70,    -1,    -1,    -1,    -1,    76,
      77,    -1,    -1,    -1,   211,    -1,    82,    83,   146,    -1,
      86,    87,    88,    89,    90,    91,    92,    93,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   165,    -1,    -1,
      -1,    -1,    -1,    -1,   111,    -1,    -1,   975,    10,    -1,
      -1,    -1,     3,    -1,   982,    -1,   122,    -1,    -1,    10,
      -1,    -1,    -1,    -1,    26,    -1,    17,    -1,    -1,    -1,
      -1,    22,    -1,   140,    25,    26,    -1,    39,    -1,   207,
      31,   815,   148,    34,   818,    -1,    -1,    -1,    39,   217,
      -1,    10,    -1,   160,   161,    -1,   777,   778,   226,    -1,
      -1,    -1,    64,    65,    66,    -1,   840,    26,   789,    -1,
      -1,    -1,    -1,    -1,    76,    77,    -1,    -1,    -1,    -1,
      39,    -1,    -1,    -1,    -1,    76,    77,    -1,    -1,    -1,
      -1,    -1,    94,   199,    -1,   201,  1064,   871,    -1,  1067,
      -1,    92,    -1,    -1,  1072,   211,    -1,    -1,    -1,   111,
      -1,    -1,    -1,    -1,    -1,   604,    -1,    76,    77,    -1,
     111,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   617,   618,
     619,   368,   123,   124,   623,    94,    -1,    -1,   140,   376,
      -1,    -1,    -1,    -1,   146,    -1,    -1,    -1,    -1,   140,
      -1,    -1,   111,  1121,    -1,    -1,  1124,    -1,   160,   161,
      -1,    -1,    -1,   165,    10,    -1,    -1,    -1,    -1,   160,
     161,    -1,    -1,    -1,    -1,    -1,   167,   666,    -1,    -1,
      26,   140,   956,   957,    -1,   291,    -1,   961,    -1,    -1,
      -1,    -1,   298,    39,    -1,    -1,    -1,    -1,    -1,   920,
      -1,   160,   161,   924,    -1,   207,   165,    -1,    -1,    -1,
     212,    -1,    -1,    -1,    -1,   217,    -1,    -1,    64,    65,
      66,    -1,    -1,    -1,   226,    -1,    -1,    -1,    -1,    -1,
      76,    77,    -1,    -1,    -1,    -1,    -1,   343,   344,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    94,    -1,
      -1,    -1,    -1,   974,  1028,    -1,   977,    -1,    -1,    -1,
      -1,    -1,   368,  1037,    -1,   111,  1040,    -1,  1042,    -1,
     376,    95,    96,    97,    98,    99,   100,   101,   102,   103,
     104,   105,   106,   107,   108,    -1,    -1,    -1,  1062,    -1,
      -1,    -1,    -1,    -1,   140,    -1,    -1,    -1,    -1,    -1,
     146,  1075,    -1,    -1,    -1,    -1,    -1,    -1,    10,    -1,
      -1,    -1,    -1,    -1,   160,   161,    -1,   554,   555,   165,
      -1,    -1,    -1,    -1,    26,    -1,   802,   803,    -1,   805,
      -1,    -1,   821,    -1,    -1,    -1,    -1,    39,    -1,   576,
     577,   578,    -1,   580,    -1,   582,   583,   584,    -1,    -1,
     456,   457,   458,   459,    -1,    -1,    -1,   594,   595,    -1,
      -1,   207,    64,    65,    66,    -1,    10,    -1,    -1,    -1,
      -1,   217,    -1,    -1,    76,    77,    -1,    -1,    -1,    -1,
     226,    -1,    26,    -1,    -1,   874,    -1,    -1,    -1,    -1,
      -1,    -1,    94,    -1,    -1,    39,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      64,    65,    66,   912,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    76,    77,    -1,    -1,    -1,    -1,   140,    -1,
      -1,    -1,    -1,    -1,   146,    -1,    -1,    -1,   554,   555,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,   161,
      -1,    -1,    -1,   165,    -1,    -1,    -1,   111,    -1,   575,
      -1,   577,   578,    -1,   580,    -1,   582,   583,   584,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   594,   595,
      -1,    -1,    -1,    -1,    -1,    -1,   140,    -1,    -1,    -1,
      -1,    -1,   146,    -1,    -1,   207,    -1,   996,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   217,   160,   161,    -1,    -1,
      -1,   165,    -1,    -1,   226,    -1,    -1,    -1,    -1,  1018,
    1019,    -1,    -1,    -1,    -1,    -1,    -1,   774,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   794,    -1,    -1,
      -1,    -1,    -1,   207,   670,     3,     4,     5,    -1,     7,
      -1,     9,    10,   217,    -1,    -1,    14,    -1,    16,    17,
      18,    -1,   226,    -1,    22,    23,    24,    25,    26,    -1,
      28,    29,  1081,    31,    32,  1084,    34,    35,    36,    37,
      38,    39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    64,    65,    66,    -1,
      -1,    -1,    -1,    -1,    72,    73,    74,    75,    76,    77,
      78,    79,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    92,    93,    94,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   774,    -1,
      -1,   777,    -1,   111,    -1,  1164,    -1,    -1,   915,    -1,
      -1,    -1,    -1,   789,    -1,   123,   124,    -1,   794,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   136,   137,
     138,   139,   140,   141,    -1,    -1,    -1,    -1,   146,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   825,
      -1,    -1,   160,   161,   162,    -1,    -1,   165,   166,   167,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   207,
      -1,    -1,    -1,    -1,    -1,    -1,   214,    -1,    -1,   217,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   226,    -1,
      -1,    -1,   230,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   915,
      -1,    -1,    -1,    -1,   920,     3,     4,     5,   924,     7,
      -1,     9,    10,    -1,    -1,    -1,    14,    -1,    16,    17,
      18,    -1,    -1,    -1,    22,    23,    24,    25,    26,    -1,
      28,    29,    -1,    31,    32,    -1,    34,    35,    36,    37,
      38,    39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   974,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    64,    65,    66,    -1,
      -1,    -1,    -1,    -1,    72,    73,    74,    75,    76,    77,
      78,    -1,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    92,    -1,    94,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   123,   124,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   136,   137,
     138,   139,   140,   141,    -1,    -1,    -1,    -1,   146,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   160,   161,   162,    -1,    -1,   165,    -1,   167,
       3,     4,     5,    -1,     7,    -1,     9,    10,    -1,    -1,
      -1,    14,    -1,    16,    17,    18,    -1,    -1,    -1,    22,
      23,    24,    25,    26,    -1,    28,    29,    -1,    31,    32,
      -1,    34,    35,    36,    37,    38,    39,    -1,    -1,   207,
      -1,    -1,    -1,    -1,   212,    -1,    -1,    -1,    -1,   217,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   226,    -1,
      -1,    64,    65,    66,    -1,    -1,    -1,    -1,    -1,    72,
      73,    74,    75,    76,    77,    78,    -1,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    91,    92,
      -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     123,   124,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   136,   137,   138,   139,   140,   141,    -1,
      -1,    -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,   161,   162,
       4,     5,   165,     7,   167,     9,    10,    -1,    -1,    -1,
      14,    -1,    16,    -1,    18,    -1,    -1,    -1,    -1,    23,
      24,    -1,    26,    -1,    28,    29,    -1,    -1,    32,    -1,
      -1,    35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   207,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   217,    -1,    -1,    -1,    -1,    -1,
      64,    65,    66,   226,    -1,    -1,    -1,    -1,    72,    73,
      74,    75,    76,    77,    78,    -1,    80,    81,    82,    83,
      84,    85,    86,    87,    88,    89,    90,    91,    -1,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   136,   137,   138,   139,   140,   141,    -1,    -1,
      -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   160,   161,   162,     4,
       5,   165,     7,    -1,     9,    10,    -1,    -1,    -1,    14,
      -1,    16,    -1,    18,    -1,    -1,    -1,    -1,    23,    24,
      -1,    26,    -1,    28,    29,    -1,    -1,    32,    -1,    -1,
      35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   207,    -1,    -1,   210,    -1,    -1,    -1,
      -1,    -1,    -1,   217,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    66,   226,    -1,    -1,    -1,    -1,    72,    73,    74,
      75,    76,    77,    78,    -1,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    -1,    -1,    94,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   136,   137,   138,   139,   140,   141,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   160,   161,   162,    -1,    -1,
     165,    -1,    -1,     3,     4,     5,     6,     7,     8,     9,
      10,    11,    12,    13,    14,    -1,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      -1,    41,   207,    43,    44,    -1,    -1,   212,    -1,    -1,
      -1,    51,   217,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   226,    -1,    -1,    64,    65,    66,    67,    68,    69,
      70,    71,    72,    73,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    86,    87,    88,    89,
      90,    91,    92,    93,    94,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   109,
     110,   111,   112,   113,   114,   115,   116,   117,   118,   119,
      -1,    -1,   122,   123,   124,    -1,    -1,    -1,    -1,    -1,
     130,   131,   132,   133,   134,    -1,   136,   137,   138,   139,
     140,   141,   142,    -1,   144,    -1,   146,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   156,   157,   158,   159,
     160,   161,   162,   163,    -1,   165,   166,   167,   168,    -1,
     170,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   207,    -1,    -1,
      -1,    -1,    -1,    -1,   214,   215,   216,   217,   218,   219,
     220,   221,     3,     4,     5,     6,     7,     8,     9,    10,
      11,    12,    13,    14,    -1,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    -1,
      41,    -1,    43,    44,    -1,    -1,    -1,    -1,    -1,    -1,
      51,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    64,    65,    66,    67,    68,    69,    70,
      -1,    72,    73,    74,    75,    76,    77,    78,    79,    80,
      81,    82,    83,    84,    85,    86,    87,    88,    89,    90,
      91,    92,    93,    94,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   109,   110,
     111,   112,   113,   114,   115,   116,   117,   118,   119,    -1,
      -1,   122,   123,   124,    -1,    -1,    -1,    -1,    -1,   130,
     131,   132,   133,   134,    -1,   136,   137,   138,   139,   140,
     141,   142,    -1,   144,    -1,   146,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   156,   157,   158,   159,   160,
     161,   162,   163,    -1,   165,   166,   167,   168,    -1,   170,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   207,    -1,    -1,    -1,
      -1,    -1,    -1,   214,   215,   216,   217,   218,   219,   220,
     221,     3,     4,     5,     6,     7,     8,     9,    10,    11,
      12,    13,    14,    -1,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    -1,    41,
      -1,    43,    44,    -1,    -1,    -1,    -1,    -1,    -1,    51,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    64,    65,    66,    67,    68,    69,    70,    -1,
      72,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    86,    87,    88,    89,    90,    91,
      92,    93,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   109,   110,   111,
     112,   113,   114,   115,   116,   117,   118,   119,    -1,    -1,
     122,   123,   124,    -1,    -1,    -1,    -1,    -1,   130,   131,
     132,   133,   134,    -1,   136,   137,   138,   139,   140,   141,
     142,    -1,   144,    -1,   146,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   156,   157,   158,   159,   160,   161,
     162,   163,    -1,   165,   166,   167,   168,    -1,   170,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   207,    -1,    -1,    -1,    -1,
      -1,    -1,   214,    -1,   216,   217,   218,   219,   220,   221,
       3,     4,     5,    -1,     7,    -1,     9,    10,    -1,    -1,
      -1,    14,    -1,    16,    17,    18,    -1,    -1,    -1,    22,
      23,    24,    25,    26,    -1,    28,    29,    30,    31,    32,
      -1,    34,    35,    36,    37,    38,    39,    -1,    -1,    -1,
      43,    44,    -1,    -1,    -1,    -1,    -1,    -1,    51,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    64,    65,    66,    67,    68,    69,    70,    -1,    72,
      73,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    91,    92,
      -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,   112,
     113,   114,   115,   116,   117,   118,    -1,    -1,    -1,    -1,
     123,   124,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,
     133,   134,    -1,   136,   137,   138,   139,   140,   141,    -1,
      -1,    -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   156,   157,   158,   159,   160,   161,   162,
     163,     3,   165,   166,   167,   168,    -1,   170,    10,    -1,
      -1,    -1,    -1,    -1,    -1,    17,    -1,    -1,    -1,    -1,
      22,    -1,    -1,    25,    26,    -1,    -1,    -1,    30,    31,
      -1,    -1,    34,    -1,    -1,    -1,    -1,    39,    -1,    -1,
      -1,    43,    44,    -1,   207,    -1,    -1,    -1,    -1,    51,
      -1,    -1,    -1,   216,   217,   218,   219,   220,   221,    -1,
      -1,    -1,    64,    65,    -1,    67,    68,    69,    70,    -1,
      -1,    -1,    -1,    -1,    76,    77,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,
     112,   113,   114,   115,   116,   117,   118,    -1,    -1,    -1,
      -1,   123,   124,    -1,    -1,    -1,    -1,    -1,   130,   131,
     132,   133,   134,    -1,    -1,    -1,    -1,    -1,   140,    -1,
      -1,    -1,    -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   156,   157,   158,   159,   160,   161,
       3,   163,    -1,   165,    -1,   167,   168,    10,   170,    -1,
      -1,    -1,    -1,    -1,    17,    -1,    -1,    -1,    -1,    22,
      -1,    -1,    25,    26,    -1,    -1,    -1,    30,    31,    -1,
      -1,    34,    -1,    -1,    -1,    -1,    39,    -1,    -1,    -1,
      43,    44,    -1,    -1,    -1,   207,    -1,    -1,    51,    -1,
      -1,   213,    -1,    -1,   216,   217,   218,   219,   220,   221,
      -1,    64,    65,    -1,    67,    68,    69,    70,    -1,    -1,
      -1,    -1,    -1,    76,    77,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    92,
      -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,   112,
     113,   114,   115,   116,   117,   118,    -1,    -1,    10,    -1,
     123,   124,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,
     133,   134,    -1,    -1,    26,    -1,    -1,   140,    -1,    -1,
      -1,    -1,    -1,   146,    -1,    10,    -1,    39,    -1,    -1,
      -1,    -1,    -1,   156,   157,   158,   159,   160,   161,    -1,
     163,    26,   165,    -1,   167,   168,    -1,   170,    -1,    -1,
      -1,    -1,    64,    65,    39,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    76,    77,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    64,
      65,    -1,    94,    -1,   207,    -1,    -1,    -1,    -1,    -1,
     213,    76,    77,   216,   217,   218,   219,   220,   221,   111,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    94,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,   140,    -1,
      -1,    -1,    -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   160,   161,
      -1,    -1,    -1,   165,    -1,   140,    -1,    -1,    -1,    -1,
      -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   160,   161,    -1,    -1,    -1,
     165,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   207,    -1,    -1,    -1,    -1,
     212,    -1,     6,    -1,     8,   217,    -1,    11,    12,    13,
      -1,    -1,    -1,    -1,   226,    19,    20,    21,    -1,    -1,
      -1,    -1,   207,    27,    -1,    -1,    30,    -1,    -1,    33,
      -1,    -1,   217,    -1,    -1,    -1,    -1,    41,    -1,    43,
      44,   226,    -1,    -1,    -1,    -1,    -1,    51,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      64,    65,    66,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    93,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   109,   110,    -1,   112,   113,
     114,   115,   116,   117,   118,   119,    -1,    -1,   122,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,   133,
     134,    -1,    -1,    -1,    -1,    -1,    30,    -1,   142,    -1,
     144,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    43,
      44,    -1,   156,   157,   158,   159,    -1,    51,    -1,   163,
      -1,    -1,    -1,    -1,   168,    -1,   170,    -1,    -1,    -1,
      64,    65,    -1,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   207,    -1,    -1,    -1,    -1,    -1,    -1,
     214,    -1,   216,   217,   218,   219,   220,   221,   112,   113,
     114,   115,   116,   117,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,   133,
     134,    -1,    -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,
      -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    43,
      44,    -1,   156,   157,   158,   159,    -1,    51,    -1,   163,
      -1,    -1,    -1,    -1,   168,    -1,   170,    -1,    -1,    -1,
      64,    65,    -1,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   207,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   216,   217,   218,   219,   220,   221,   112,   113,
     114,   115,   116,   117,   118,    -1,   230,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,   133,
     134,    -1,    -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,
      -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    43,
      44,    -1,   156,   157,   158,   159,    -1,    51,    -1,   163,
      -1,    -1,    -1,    -1,   168,    -1,   170,    -1,    -1,    -1,
      64,    65,    66,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   207,    -1,    -1,    -1,   211,   212,    -1,
     214,    -1,   216,   217,   218,   219,   220,   221,   112,   113,
     114,   115,   116,   117,   118,   229,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,   133,
     134,    -1,    -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,
      -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    43,
      44,    -1,   156,   157,   158,   159,    -1,    51,    -1,   163,
      -1,    -1,    -1,    -1,   168,    -1,   170,    -1,    -1,    -1,
      64,    65,    66,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   207,    -1,    -1,    -1,   211,   212,    -1,
     214,   215,   216,   217,   218,   219,   220,   221,   112,   113,
     114,   115,   116,   117,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,   133,
     134,    -1,    -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,
      -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    43,
      44,    -1,   156,   157,   158,   159,    -1,    51,    -1,   163,
      -1,    -1,    -1,    -1,   168,    -1,   170,    -1,    -1,    -1,
      64,    65,    66,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   207,    -1,    -1,    -1,   211,   212,    -1,
     214,   215,   216,   217,   218,   219,   220,   221,   112,   113,
     114,   115,   116,   117,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,   133,
     134,    -1,    -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,
      -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    43,
      44,    -1,   156,   157,   158,   159,    -1,    51,    -1,   163,
      -1,    -1,    -1,    -1,   168,    -1,   170,    -1,    -1,    -1,
      64,    65,    -1,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      94,    -1,    -1,   207,    -1,    -1,    -1,   211,   212,    -1,
     214,    -1,   216,   217,   218,   219,   220,   221,   112,   113,
     114,   115,   116,   117,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,   133,
     134,    -1,    -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,
      -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    43,
      44,    -1,   156,   157,   158,   159,    -1,    51,    -1,   163,
      -1,   165,    -1,    -1,   168,    -1,   170,    -1,    -1,    -1,
      64,    65,    -1,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      94,    -1,    -1,   207,    -1,    -1,    -1,    -1,    -1,    -1,
     214,    -1,   216,   217,   218,   219,   220,   221,   112,   113,
     114,   115,   116,   117,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   130,   131,   132,   133,
     134,    -1,    -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,
      -1,    -1,   146,    -1,    -1,    -1,    -1,    -1,    -1,    43,
      44,    -1,   156,   157,   158,   159,    -1,    51,    -1,   163,
      -1,   165,    -1,    -1,   168,    -1,   170,    -1,    -1,    -1,
      64,    65,    -1,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   207,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   216,   217,   218,   219,   220,   221,   112,   113,
     114,   115,   116,   117,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    30,    -1,    -1,   130,   131,   132,   133,
     134,    -1,    -1,    -1,    -1,    -1,    43,    44,    -1,    -1,
      -1,    -1,   146,    -1,    51,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   156,   157,   158,   159,    -1,    64,    65,   163,
      67,    68,    69,    70,   168,    -1,   170,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   207,   208,   112,   113,   114,   115,   116,
     117,   118,   216,   217,   218,   219,   220,   221,    -1,    -1,
      -1,    -1,    -1,   130,   131,   132,   133,   134,    -1,    -1,
      -1,    -1,    -1,    30,    -1,    -1,    -1,    -1,    -1,   146,
      -1,    -1,    -1,    -1,    -1,    -1,    43,    44,    -1,   156,
     157,   158,   159,    -1,    51,    -1,   163,    -1,    -1,    -1,
      -1,   168,    -1,   170,    -1,    -1,    -1,    64,    65,    -1,
      67,    68,    69,    70,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     207,    -1,    -1,   210,    -1,    -1,    -1,    -1,    -1,   216,
     217,   218,   219,   220,   221,   112,   113,   114,   115,   116,
     117,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   130,   131,   132,   133,   134,    -1,    -1,
      -1,    -1,    -1,    30,    -1,    -1,    -1,    -1,    -1,   146,
      -1,    -1,    -1,    -1,    -1,    -1,    43,    44,    -1,   156,
     157,   158,   159,    -1,    51,    -1,   163,    -1,    -1,    -1,
      -1,   168,    -1,   170,    -1,    -1,    -1,    64,    65,    66,
      67,    68,    69,    70,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     207,    -1,    -1,    -1,    -1,    -1,    -1,   214,    -1,   216,
     217,   218,   219,   220,   221,   112,   113,   114,   115,   116,
     117,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      30,    -1,    -1,   130,   131,   132,   133,   134,    -1,    -1,
      -1,    -1,    -1,    43,    44,    -1,    -1,    -1,    -1,   146,
      -1,    51,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   156,
     157,   158,   159,    -1,    64,    65,   163,    67,    68,    69,
      70,   168,    -1,   170,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     207,    -1,   112,   113,   114,   115,   116,   117,   118,   216,
     217,   218,   219,   220,   221,    -1,    -1,    30,    -1,    -1,
     130,   131,   132,   133,   134,    -1,    -1,    -1,    -1,    -1,
      43,    44,    -1,    -1,    -1,    -1,   146,    -1,    51,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   156,   157,   158,   159,
      -1,    64,    65,   163,    67,    68,    69,    70,   168,    -1,
     170,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   207,    -1,   112,
     113,   114,   115,   116,   117,   118,   216,   217,   218,   219,
     220,   221,    -1,    -1,    30,    -1,    -1,   130,   131,   132,
     133,   134,    -1,    -1,    -1,    -1,    -1,    43,    44,    -1,
      -1,    -1,    -1,   146,    -1,    51,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   156,   157,   158,   159,    -1,    64,    65,
     163,    67,    68,    69,    70,   168,    -1,   170,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   207,    -1,   112,   113,   114,   115,
     116,   117,   118,   216,   217,   218,   219,   220,   221,    -1,
      -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,    -1,    -1,
     146,    -1,    -1,    -1,    -1,    -1,    -1,    43,    44,    -1,
     156,   157,   158,   159,    -1,    51,    -1,   163,    -1,    -1,
      -1,    -1,   168,    -1,   170,    -1,    -1,    -1,    64,    65,
      -1,    67,    68,    69,    70,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   207,    -1,    -1,    -1,    -1,    -1,   213,    -1,    -1,
     216,   217,   218,   219,   220,   221,   112,   113,   114,   115,
     116,   117,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,    -1,    -1,
     146,    -1,    -1,    -1,    -1,    -1,    -1,    43,    44,    -1,
     156,   157,   158,   159,    -1,    51,    -1,   163,    -1,    -1,
      -1,    -1,   168,    -1,   170,    -1,    -1,    -1,    64,    65,
      -1,    67,    68,    69,    70,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   207,    -1,    -1,    -1,    -1,    -1,   213,    -1,    -1,
     216,   217,   218,   219,   220,   221,   112,   113,   114,   115,
     116,   117,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   130,   131,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,    -1,    -1,
     146,    -1,    -1,    -1,    -1,    -1,    -1,    43,    44,    -1,
     156,   157,   158,   159,    -1,    51,    -1,   163,    -1,    -1,
      -1,    -1,   168,    -1,   170,    -1,    -1,    -1,    64,    65,
      -1,    67,    68,    69,    70,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   207,    -1,    -1,    -1,    -1,    -1,    -1,   214,    -1,
     216,   217,   218,   219,   220,   221,   112,   113,   114,   115,
     116,   117,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    30,    -1,    -1,   130,   131,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    43,    44,    -1,    -1,    -1,    -1,
     146,    -1,    51,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     156,   157,   158,   159,    -1,    64,    65,   163,    67,    68,
      69,    70,   168,    -1,   170,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   207,   208,   112,   113,   114,   115,   116,   117,   118,
     216,   217,   218,   219,   220,   221,    -1,    -1,    30,    -1,
      -1,   130,   131,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    43,    44,    -1,    -1,    -1,    -1,   146,    -1,    51,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   156,   157,   158,
     159,    -1,    64,    65,   163,    67,    68,    69,    70,   168,
      -1,   170,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   207,   208,
     112,   113,   114,   115,   116,   117,   118,   216,   217,   218,
     219,   220,   221,    -1,    -1,    30,    -1,    -1,   130,   131,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    43,    44,
      -1,    -1,    -1,    -1,   146,    -1,    51,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   156,   157,   158,   159,    -1,    64,
      65,   163,    67,    68,    69,    70,   168,    -1,   170,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   207,    -1,   112,   113,   114,
     115,   116,   117,   118,   216,   217,   218,   219,   220,   221,
      -1,    -1,    30,    -1,    -1,   130,   131,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    43,    44,    -1,    -1,    -1,
      -1,   146,    -1,    51,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   156,   157,    -1,    -1,    -1,    64,    65,   163,    67,
      68,    69,    70,   168,    -1,   170,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   207,    -1,   112,   113,   114,   115,   116,   117,
     118,   216,   217,   218,   219,   220,   221,    -1,    -1,    30,
      -1,    -1,   130,   131,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    43,    44,    -1,    -1,    -1,    -1,   146,    -1,
      51,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   156,   157,
      -1,    -1,    -1,    64,    65,   163,    67,    68,    69,    70,
     168,    -1,   170,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   207,
      -1,   112,   113,   114,   115,   116,   117,   118,   216,   217,
     218,   219,   220,   221,    -1,    -1,    -1,    -1,    -1,   130,
     131,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   146,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   156,   157,    -1,    -1,     3,
       4,     5,   163,     7,    -1,     9,    10,   168,    -1,   170,
      14,    -1,    16,    17,    18,    -1,    -1,    -1,    22,    23,
      24,    25,    26,    -1,    28,    29,    -1,    31,    32,    -1,
      34,    35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   207,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   216,   217,   218,   219,   220,
     221,    -1,    66,    -1,    -1,    -1,    -1,    -1,    72,    73,
      74,    75,    76,    77,    78,    79,    80,    81,    82,    83,
      84,    85,    86,    87,    88,    89,    90,    91,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   123,
     124,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   136,   137,   138,   139,   140,   141,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   160,   161,   162,    -1,
      -1,   165,   166,   167,     3,     4,     5,    -1,     7,    -1,
       9,    10,    -1,    -1,    -1,    14,    -1,    16,    17,    18,
      -1,    -1,    -1,    22,    23,    24,    25,    26,    -1,    28,
      29,    -1,    31,    32,    -1,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    66,    -1,    -1,
      -1,    -1,    -1,    72,    73,    74,    75,    76,    77,    78,
      -1,    80,    81,    82,    83,    84,    85,    86,    87,    88,
      89,    90,    91,    92,    -1,    94,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   123,   124,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   136,   137,   138,
     139,   140,   141,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   160,   161,   162,    -1,    -1,   165,    -1,   167,     3,
       4,     5,    -1,     7,    -1,     9,    10,    -1,    -1,    -1,
      14,    -1,    16,    17,    18,    -1,    -1,    -1,    22,    23,
      24,    25,    26,    -1,    28,    29,    -1,    31,    32,    -1,
      34,    35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    66,    -1,    -1,    -1,    -1,    -1,    72,    73,
      74,    75,    76,    77,    78,    -1,    80,    81,    82,    83,
      84,    85,    86,    87,    88,    89,    90,    91,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   111,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   123,
     124,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   136,   137,   138,   139,   140,   141,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   160,   161,   162,    -1,
      -1,   165,    -1,   167,     3,     4,     5,    -1,     7,    -1,
       9,    10,    -1,    -1,    -1,    14,    -1,    16,    17,    18,
      -1,    -1,    -1,    22,    23,    24,    25,    26,    -1,    28,
      29,    -1,    31,    32,    -1,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    66,    -1,    -1,
      -1,    -1,    -1,    72,    73,    74,    75,    76,    77,    78,
      -1,    80,    81,    82,    83,    84,    85,    86,    87,    88,
      89,    90,    91,    92,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   123,   124,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   136,   137,   138,
     139,   140,   141,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   160,   161,   162,    -1,     3,     4,     5,   167,     7,
      -1,     9,    10,    -1,    -1,    -1,    14,    -1,    16,    17,
      18,    -1,    -1,    -1,    22,    23,    24,    25,    26,    -1,
      28,    29,    -1,    31,    32,    -1,    34,    -1,    36,    37,
      38,    39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    66,    -1,
      -1,    -1,    -1,    -1,    72,    73,    74,    75,    76,    77,
      -1,    -1,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    92,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   123,   124,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   137,
     138,   139,   140,   141,    -1,     3,     4,     5,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,    14,    -1,    -1,    17,
      18,    -1,   160,   161,    22,    23,    24,    25,    26,   167,
      28,    29,    -1,    31,    -1,    -1,    34,    -1,    -1,    37,
      38,    39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    72,    73,    74,    75,    76,    77,
      -1,    -1,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    92,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   123,   124,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   137,
     138,   139,   140,   141,    -1,    -1,     4,     5,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,    14,    -1,    16,    -1,
      18,    -1,   160,   161,    -1,    23,    24,    -1,    26,   167,
      28,    29,    -1,    -1,    32,    -1,    -1,    35,    36,    37,
      38,    39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    66,    -1,
      -1,    -1,    -1,    -1,    72,    73,    74,    75,    76,    77,
      78,    -1,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    -1,    -1,    94,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   136,   137,
     138,   139,   140,   141,    -1,    -1,     4,     5,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,    14,    -1,    16,    -1,
      18,    -1,   160,   161,   162,    23,    24,   165,    26,    -1,
      28,    29,    -1,    -1,    32,    -1,    -1,    35,    36,    37,
      38,    39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    66,    -1,
      -1,    -1,    -1,    -1,    72,    73,    74,    75,    76,    77,
      78,    -1,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    -1,    -1,    -1,     4,     5,    -1,
       7,    -1,     9,    10,    -1,    -1,    -1,    14,    -1,    -1,
      -1,    18,    -1,   111,    -1,    -1,    23,    24,    -1,    26,
      -1,    28,    29,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      37,    38,    39,    -1,    -1,    -1,    -1,    -1,   136,   137,
     138,   139,   140,   141,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   160,   161,   162,    72,    73,    74,    75,    76,
      77,    -1,    -1,    80,    81,    82,    83,    84,    85,    86,
      87,    88,    89,    90,    91,    -1,    -1,     4,     5,    -1,
       7,    -1,     9,    -1,    -1,    -1,    -1,    14,    -1,    -1,
      -1,    18,    -1,    -1,   111,    -1,    23,    24,    -1,    -1,
      -1,    28,    29,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      37,    38,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     137,   138,   139,   140,   141,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    66,
      -1,    -1,    -1,   160,   161,    72,    73,    74,    75,    -1,
      -1,    -1,    -1,    80,    81,    82,    83,    84,    85,    86,
      87,    88,    89,    90,    91,     4,     5,    -1,     7,    -1,
       9,    -1,    -1,    -1,    -1,    14,    -1,    -1,    -1,    18,
      -1,    -1,    -1,    -1,    23,    24,    -1,    -1,    -1,    28,
      29,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    37,    38,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     137,   138,   139,    -1,   141,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    72,    73,    74,    75,    -1,    -1,    -1,
      -1,    80,    81,    82,    83,    84,    85,    86,    87,    88,
      89,    90,    91,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   137,   138,
     139,    -1,   141
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,     3,     4,     5,     7,     9,    10,    14,    16,    17,
      18,    22,    23,    24,    25,    26,    28,    29,    31,    32,
      34,    35,    36,    37,    38,    39,    64,    65,    66,    72,
      73,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    91,    92,
      93,    94,   111,   123,   124,   136,   137,   138,   139,   140,
     141,   146,   160,   161,   162,   165,   166,   167,   207,   214,
     217,   226,   230,   232,   233,   234,   281,   282,   283,   290,
     294,   295,   296,   297,   300,   301,   305,   306,   307,   308,
     309,   310,   311,   312,   313,   314,   315,   316,   320,   322,
     323,   324,   325,   327,   331,   335,   347,   354,   410,   411,
     412,   413,   414,   425,   435,   436,   437,   438,   207,   207,
     207,   207,   217,   234,   426,   427,   428,   429,   430,   431,
     432,   433,   435,   207,   207,   207,   207,   224,   212,   212,
     212,    70,   207,   207,   207,   436,   438,    71,   298,   300,
     302,   335,   435,   435,     0,   335,   336,   337,   230,   209,
     230,   209,   230,   230,   426,   230,   426,   234,   299,   300,
     313,   315,   322,   323,   324,   335,   435,   234,   300,   313,
     315,   322,   323,   324,   335,   435,   299,   323,   300,   322,
     323,   299,   300,   322,   299,   299,   299,   300,   322,   297,
     322,   297,   322,   336,   336,   336,   412,   379,   380,   415,
     207,   212,   453,   455,   458,    30,    43,    44,    51,    67,
      68,    69,    70,   112,   113,   114,   115,   116,   117,   118,
     130,   131,   132,   133,   134,   156,   157,   158,   159,   163,
     168,   170,   207,   216,   217,   218,   219,   220,   221,   233,
     235,   236,   237,   238,   239,   240,   241,   242,   245,   246,
     247,   248,   250,   256,   257,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   279,   277,   278,   336,   365,   278,   365,
     207,   217,   234,   337,   430,   432,   434,   207,   298,   427,
     429,   432,   453,    93,   287,   288,   289,   335,   238,   207,
     278,    26,    65,    66,   208,   209,   317,   318,   319,   365,
     278,   278,   278,   278,   365,   365,   277,   208,   208,   215,
     302,   435,   335,   435,   336,   289,   289,   336,   336,   336,
     336,   284,   336,   297,   297,   336,   285,   336,   336,   336,
     336,   336,   336,   336,   336,   336,   336,   336,   336,   336,
     336,   321,   210,   233,   234,   352,   364,   214,   208,   454,
     457,   213,   217,   279,   300,   303,   304,   322,   335,   212,
     207,   260,   207,   260,   260,   364,   390,   207,   207,   207,
     207,   207,   207,   207,   260,   380,   380,   380,   380,   380,
     261,   261,   207,   207,   278,   365,   379,   261,   261,   261,
     261,   261,   261,    42,    43,    44,   207,   211,   212,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,   229,
     217,   222,   223,   218,   219,    45,    46,    47,    48,   224,
     225,    49,    50,   216,   226,   227,    51,   155,    52,   153,
     154,   228,   208,   208,   209,   295,   297,   306,   308,   312,
     314,   316,   208,   208,   208,   434,   207,   435,   208,   208,
     453,   434,   207,   429,   432,   395,   287,   229,   208,    95,
      96,    97,    98,    99,   100,   101,   102,   103,   104,   105,
     106,   107,   108,   332,   333,   334,   208,   207,   208,   318,
     225,   213,   213,   213,   208,   208,   208,   208,   209,   453,
     286,   426,   291,   292,   229,   366,   366,   320,   328,   364,
     234,   323,   350,   351,   348,   352,     6,     8,    11,    12,
      13,    19,    20,    21,    27,    33,    41,    64,    65,    66,
      71,    93,   109,   110,   119,   122,   142,   144,   215,   278,
     280,   281,   294,   295,   296,   297,   335,   372,   373,   374,
     376,   377,   378,   379,   381,   382,   383,   385,   387,   388,
     391,   392,   393,   394,   295,   297,   300,   306,   312,   322,
     417,   418,   419,   420,   421,   422,   423,   424,   456,   233,
     360,   361,   294,   295,   296,   297,   359,   362,   363,   213,
     213,   213,   279,   303,   217,   279,   365,   365,   365,   277,
     365,   277,   277,   365,   365,   214,   214,   281,   281,   281,
     277,   365,   208,   208,   208,   233,   234,   258,   208,   259,
     277,   258,   278,   277,   277,   277,   277,   277,   277,   277,
     277,   277,   277,   277,   261,   261,   261,   261,   262,   262,
     263,   263,   264,   264,   264,   264,   265,   265,   266,   267,
     268,   269,   270,   271,   273,   273,   210,   278,   277,   207,
     217,   226,   439,   453,   459,   461,   439,   208,   208,   453,
     453,   208,   208,   434,    20,    22,    39,   207,   214,   279,
     367,   230,   207,   207,   207,   207,   207,   208,   209,    67,
      70,   317,   212,   212,   277,   366,   289,   366,   366,   367,
     214,   329,   330,   323,   214,   349,   230,   279,   230,   210,
     151,   448,   449,   386,   234,   278,   207,   230,   278,   207,
     207,   210,   215,   395,   389,   390,    71,   214,   379,   230,
     379,   230,   426,   426,   435,   435,   230,   210,   215,   372,
     426,   322,   322,   322,   418,   234,   299,   323,   331,   354,
     299,   323,   299,   426,   209,   230,   149,   150,   152,   441,
     448,   450,   451,   452,   208,   209,   207,   217,   226,   429,
     435,   440,   455,   460,   462,   429,   435,   440,   207,   217,
     435,   440,   435,   440,   208,   209,   213,   213,   213,   208,
     208,   208,   209,   209,   209,   209,   209,   208,   281,   281,
     275,   275,   275,   209,   209,   214,   261,   208,   209,   213,
     276,   210,   453,   459,   461,   298,   439,   453,   208,   238,
     396,   397,   211,   212,   233,   258,   367,   368,   369,   370,
     371,   278,   278,   233,    70,    70,   208,   333,   208,   208,
     229,   278,   278,   208,   293,   230,   282,   336,   338,   339,
     340,   341,   342,   214,   336,   355,   356,   357,   364,   214,
     353,    53,   210,   372,   207,   147,   251,   252,   253,   207,
     230,   230,   278,   230,   278,   280,   335,   375,   207,   214,
     209,   230,    71,   120,   121,   143,   145,   289,   289,   372,
     336,   336,   336,   336,   364,   364,   336,   336,   336,   426,
     443,   442,   207,   441,   416,   417,   361,   208,   460,   462,
     298,   440,   336,   336,   298,   336,   336,   416,    53,   363,
     365,   365,   364,   365,   249,   258,   278,   278,    12,   243,
     244,   365,   260,   368,   369,   277,   276,   208,   208,   208,
     439,   208,   210,   398,   258,   278,   210,   209,   215,   211,
     212,   229,   367,   208,   208,   208,   208,   208,   317,   213,
     213,   366,   230,   295,   297,   215,   340,   209,   230,   209,
     230,   338,   215,   209,   336,   355,   336,   279,   372,   208,
     260,   274,   444,   445,   446,   447,   207,   251,   148,   255,
     374,   382,   384,   208,   208,   208,    66,   373,   396,    71,
     390,   215,   379,   207,   379,   379,   336,   336,   207,   207,
     208,   447,   208,   208,   440,   452,   208,   208,   207,   208,
     208,    42,   208,   211,   212,   215,   215,   210,   208,   209,
     210,   208,   209,   215,   453,   453,   212,   238,   399,   400,
     210,   401,    53,   213,   367,   215,   370,   258,   278,   367,
     208,   209,   210,   343,   346,   426,   344,   346,   435,   336,
     344,   343,   215,   336,   357,   229,   358,   215,   210,   210,
     209,   230,   208,   275,   207,   372,   280,   372,   372,   449,
     208,   215,   278,   275,   275,   208,   207,   455,   259,   258,
     258,   278,   277,   244,   277,   215,   364,   207,   209,   212,
     238,   402,   403,   210,   404,   278,    53,   213,   317,   279,
     336,   345,   346,   336,   345,   326,   336,   279,   372,   260,
     444,   260,   445,   208,   254,   275,    41,   230,    15,   253,
     230,   208,   208,   208,   208,   213,   213,   278,   399,   364,
     207,   209,   238,   405,   406,   210,   407,   213,   278,   229,
     336,   336,   326,   208,   209,   207,   280,   372,   255,   379,
     208,   238,   208,   213,   278,   402,   209,   390,   408,   409,
     213,   317,   275,   278,   208,   372,   207,   238,   208,   405,
     209,   208,   208,   449,   278,   207,   409,   230,   253,   208,
     278,   255,   208,   372
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   231,   232,   233,   233,   233,   234,   235,   236,   237,
     238,   239,   239,   239,   239,   239,   240,   240,   240,   241,
     241,   241,   241,   241,   241,   241,   241,   241,   241,   242,
     243,   243,   244,   244,   245,   245,   245,   245,   246,   247,
     248,   249,   249,   249,   249,   250,   250,   251,   252,   252,
     253,   253,   254,   254,   255,   255,   256,   257,   257,   257,
     257,   257,   257,   257,   257,   257,   257,   258,   258,   259,
     259,   260,   260,   260,   260,   260,   260,   260,   260,   260,
     260,   260,   260,   260,   260,   260,   261,   261,   261,   261,
     262,   262,   262,   262,   263,   263,   263,   264,   264,   264,
     265,   265,   265,   265,   265,   266,   266,   266,   267,   267,
     268,   268,   269,   269,   270,   270,   271,   271,   272,   272,
     273,   273,   274,   274,   275,   275,   275,   275,   276,   276,
     276,   277,   277,   277,   277,   277,   277,   277,   277,   277,
     277,   277,   277,   278,   278,   279,   280,   280,   281,   281,
     281,   281,   281,   282,   282,   284,   283,   285,   283,   286,
     283,   287,   287,   288,   288,   289,   289,   291,   290,   292,
     290,   290,   293,   290,   294,   294,   294,   294,   294,   295,
     295,   295,   295,   295,   296,   296,   296,   296,   296,   297,
     297,   297,   298,   298,   299,   299,   300,   300,   300,   300,
     300,   300,   300,   300,   300,   301,   301,   302,   302,   303,
     303,   303,   304,   304,   305,   305,   305,   305,   306,   306,
     306,   306,   307,   307,   307,   308,   308,   308,   309,   309,
     309,   310,   310,   310,   311,   311,   311,   312,   312,   312,
     313,   313,   313,   313,   314,   314,   314,   314,   315,   316,
     316,   316,   316,   317,   317,   317,   318,   318,   318,   318,
     318,   318,   319,   319,   320,   320,   321,   321,   322,   322,
     322,   322,   322,   322,   322,   322,   322,   322,   323,   323,
     323,   323,   323,   323,   323,   323,   323,   323,   323,   323,
     323,   323,   323,   323,   323,   323,   323,   323,   323,   323,
     323,   323,   323,   323,   323,   323,   323,   323,   323,   323,
     324,   324,   324,   325,   326,   328,   327,   329,   327,   330,
     327,   331,   331,   332,   332,   332,   332,   332,   332,   332,
     332,   332,   332,   332,   332,   332,   332,   333,   333,   333,
     334,   334,   335,   335,   336,   336,   337,   337,   338,   338,
     339,   339,   340,   340,   340,   340,   341,   341,   342,   342,
     343,   343,   343,   344,   344,   345,   345,   346,   348,   347,
     349,   347,   350,   350,   351,   351,   352,   352,   353,   353,
     354,   355,   355,   356,   356,   356,   357,   358,   358,   359,
     359,   360,   360,   361,   362,   362,   363,   363,   363,   363,
     363,   363,   363,   363,   363,   363,   363,   363,   363,   363,
     364,   364,   365,   365,   365,   365,   366,   366,   367,   367,
     367,   368,   368,   369,   369,   370,   370,   370,   370,   371,
     371,   371,   371,   371,   371,   372,   372,   372,   373,   373,
     373,   373,   373,   373,   373,   373,   373,   373,   373,   374,
     375,   375,   376,   376,   377,   377,   377,   377,   377,   378,
     379,   379,   379,   380,   381,   381,   382,   383,   383,   383,
     384,   384,   385,   385,   386,   385,   387,   387,   387,   387,
     387,   387,   388,   389,   389,   390,   391,   391,   392,   392,
     393,   393,   393,   394,   394,   394,   395,   395,   395,   395,
     396,   396,   396,   396,   396,   397,   398,   398,   399,   399,
     400,   400,   401,   401,   402,   402,   403,   403,   404,   404,
     405,   406,   406,   407,   407,   408,   408,   409,   410,   410,
     411,   411,   412,   412,   412,   412,   413,   413,   414,   415,
     416,   416,   417,   417,   418,   419,   419,   419,   420,   420,
     420,   420,   421,   421,   421,   422,   422,   423,   423,   423,
     424,   424,   424,   425,   425,   425,   425,   425,   426,   426,
     426,   427,   427,   427,   428,   428,   429,   429,   429,   430,
     430,   430,   431,   431,   432,   432,   432,   432,   432,   433,
     433,   433,   434,   434,   435,   435,   436,   436,   436,   436,
     437,   437,   437,   438,   438,   439,   439,   439,   440,   440,
     442,   441,   443,   441,   441,   441,   444,   444,   445,   445,
     446,   446,   447,   447,   448,   448,   449,   449,   450,   450,
     451,   451,   452,   452,   453,   453,   454,   453,   455,   456,
     455,   457,   455,   458,   458,   458,   458,   458,   458,   458,
     459,   459,   459,   459,   459,   460,   460,   460,   460,   460,
     461,   461,   461,   461,   461,   462,   462,   462,   462
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     1,     1,     2,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     3,     1,     1,     1,     1,     1,     1,     1,     6,
       1,     3,     3,     3,     6,     6,     6,     9,     6,     4,
       6,     1,     3,     4,     3,     6,     6,     4,     1,     2,
       0,     1,     1,     3,     0,     4,     3,     1,     4,     3,
       4,     3,     3,     2,     2,     6,     7,     1,     1,     1,
       3,     1,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     4,     2,     4,     6,     1,     4,     2,     2,
       1,     3,     3,     3,     1,     3,     3,     1,     3,     3,
       1,     3,     3,     3,     3,     1,     3,     3,     1,     3,
       1,     3,     1,     3,     1,     3,     1,     3,     1,     3,
       1,     3,     1,     3,     1,     4,     4,     4,     1,     5,
       4,     1,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     1,     3,     1,     0,     1,     2,     2,
       2,     2,     2,     6,     4,     0,     4,     0,     4,     0,
       5,     5,     1,     2,     1,     0,     1,     0,     5,     0,
       5,     5,     0,     7,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     2,     1,     2,     2,     1,
       2,     2,     1,     2,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     4,     1,     4,     4,     1,     1,     1,
       1,     1,     1,     2,     3,     3,     3,     3,     2,     3,
       2,     3,     2,     3,     3,     1,     2,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     2,     3,     3,
       4,     4,     4,     4,     1,     2,     3,     2,     4,     1,
       2,     3,     2,     1,     1,     1,     1,     4,     4,     6,
      10,     1,     1,     2,     4,     3,     0,     2,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     4,     1,     1,     1,     4,     7,     7,     1,
       1,     1,     1,     4,     0,     0,     9,     0,    10,     0,
       6,     1,     1,     1,     1,     4,     1,     4,     4,     1,
       1,     4,     4,     1,     1,     1,     1,     0,     1,     1,
       1,     3,     6,     1,     0,     1,     1,     2,     0,     1,
       1,     2,     2,     2,     1,     2,     3,     3,     3,     3,
       3,     0,     2,     3,     2,     0,     1,     2,     0,     8,
       0,     7,     1,     2,     1,     1,     0,     2,     0,     3,
       1,     0,     1,     1,     3,     2,     3,     0,     2,     1,
       3,     1,     3,     1,     1,     3,     1,     2,     3,     2,
       1,     2,     3,     1,     2,     3,     2,     1,     2,     3,
       1,     1,     2,     3,     2,     3,     0,     2,     1,     3,
       4,     1,     3,     1,     0,     1,     3,     2,     3,     2,
       3,     5,     4,     6,     3,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       0,     1,     1,     1,     4,     3,     4,     6,     3,     2,
       3,     4,     4,     0,     1,     2,     2,     5,     7,     5,
       1,     1,     8,    10,     0,    12,     3,     3,     2,     2,
       2,     3,     3,     1,     3,     1,     6,     5,     4,     2,
       7,     4,     1,     2,     4,     4,     0,     2,     2,     2,
       1,     2,     3,     4,     5,     1,     2,     1,     4,     7,
       1,     3,     2,     1,     4,     7,     1,     3,     2,     1,
       1,     1,     3,     2,     1,     1,     3,     1,     0,     1,
       1,     2,     1,     1,     1,     1,     5,     3,     2,     1,
       0,     1,     1,     2,     2,     1,     2,     2,     3,     3,
       3,     3,     3,     3,     3,     4,     4,     1,     1,     1,
       2,     2,     3,     1,     3,     3,     2,     2,     1,     1,
       1,     4,     5,     2,     1,     1,     1,     2,     1,     1,
       2,     3,     3,     4,     1,     4,     5,     2,     3,     3,
       4,     4,     1,     3,     1,     1,     1,     2,     2,     3,
       2,     3,     4,     1,     3,     1,     1,     1,     1,     1,
       0,     5,     0,     5,     1,     1,     1,     3,     1,     3,
       1,     3,     2,     1,     4,     3,     0,     1,     4,     3,
       1,     2,     0,     1,     1,     3,     0,     5,     1,     0,
       4,     0,     6,     2,     3,     3,     3,     4,     4,     4,
       1,     2,     2,     3,     1,     1,     2,     2,     3,     1,
       3,     3,     3,     4,     4,     3,     3,     1,     4
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
        yyerror (YY_("syntax error: cannot back up")); \
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
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
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
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
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
                 int yyrule)
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
                       &yyvsp[(yyi + 1) - (yynrhs)]);
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
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
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
yyparse (void)
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
      yychar = yylex ();
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
  case 5: /* identifier: "__CPROVER_ID" TOK_STRING  */
#line 314 "/workspace/source/src/ansi-c/parser.y"
        {
          // construct an identifier from a string that would otherwise not be a
          // valid identifier in C
          yyval=yyvsp[-1];
          parser_stack(yyval).id(ID_symbol);
          irep_idt value=parser_stack(yyvsp[0]).get(ID_value);
          parser_stack(yyval).set(ID_C_base_name, value);
          parser_stack(yyval).set(ID_identifier, value);
          parser_stack(yyval).set(
            ID_C_id_class, static_cast<int>(ansi_c_id_classt::ANSI_C_SYMBOL));
        }
#line 3988 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 16: /* predefined_constant: "FALSE"  */
#line 359 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[0];
          stack_expr(yyval).id(ID_constant);
          stack_expr(yyval).set(ID_value, ID_0);
          stack_expr(yyval).type() = c_bool_type();
        }
#line 3998 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 17: /* predefined_constant: "TRUE"  */
#line 365 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[0];
          stack_expr(yyval).id(ID_constant);
          stack_expr(yyval).set(ID_value, ID_1);
          stack_expr(yyval).type() = c_bool_type();
        }
#line 4008 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 18: /* predefined_constant: "nullptr"  */
#line 371 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[0];
          stack_expr(yyval).id(ID_constant);
          stack_expr(yyval).set(ID_value, ID_NULL);
          stack_expr(yyval).type() = pointer_type(void_type());
        }
#line 4018 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 21: /* primary_expression: '(' comma_expression ')'  */
#line 384 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-1]; }
#line 4024 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 29: /* generic_selection: "_Generic" '(' assignment_expression ',' generic_assoc_list ')'  */
#line 396 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-5];
          set(yyval, ID_generic_selection);
          mto(yyval, yyvsp[-3]);
          parser_stack(yyval).add(ID_generic_associations).get_sub().swap((irept::subt&)parser_stack(yyvsp[-1]).operands());
        }
#line 4035 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 30: /* generic_assoc_list: generic_association  */
#line 406 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval); mto(yyval, yyvsp[0]);
        }
#line 4043 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 31: /* generic_assoc_list: generic_assoc_list ',' generic_association  */
#line 410 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2]; mto(yyval, yyvsp[0]);
        }
#line 4051 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 32: /* generic_association: type_name ':' assignment_expression  */
#line 417 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          parser_stack(yyval).id(ID_generic_association);
          parser_stack(yyval).set(ID_type_arg, parser_stack(yyvsp[-2]));
          parser_stack(yyval).set(ID_value, parser_stack(yyvsp[0]));
        }
#line 4062 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 33: /* generic_association: "default" ':' assignment_expression  */
#line 424 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          parser_stack(yyval).id(ID_generic_association);
          parser_stack(yyval).set(ID_type_arg, irept(ID_default));
          parser_stack(yyval).set(ID_value, parser_stack(yyvsp[0]));
        }
#line 4073 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 34: /* gcc_builtin_expressions: "__builtin_va_arg" '(' assignment_expression ',' type_name ')'  */
#line 434 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-5];
          parser_stack(yyval).id(ID_gcc_builtin_va_arg);
          mto(yyval, yyvsp[-3]);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
        }
#line 4084 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 35: /* gcc_builtin_expressions: "__builtin_types_compatible_p" '(' type_name ',' type_name ')'  */
#line 442 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-5];
          parser_stack(yyval).id(ID_gcc_builtin_types_compatible_p);
          auto &type_arg=static_cast<type_with_subtypest &>(parser_stack(yyval).add(ID_type_arg));
          auto &subtypes=type_arg.subtypes();
          subtypes.resize(2);
          subtypes[0].swap(parser_stack(yyvsp[-3]));
          subtypes[1].swap(parser_stack(yyvsp[-1]));
        }
#line 4098 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 36: /* gcc_builtin_expressions: "__builtin_has_attribute" '(' assignment_expression ',' identifier_or_typedef_name ')'  */
#line 453 "/workspace/source/src/ansi-c/parser.y"
        {
          // __builtin_has_attribute(expr, attr): the second operand is a
          // bare attribute name (e.g. nonstring).  CBMC does not track all
          // GCC attributes, so we discard the name and yield a constant in
          // the typecheck phase (see c_typecheck_expr).
          yyval=yyvsp[-5];
          parser_stack(yyval).id(ID_gcc_builtin_has_attribute);
          mto(yyval, yyvsp[-3]);
        }
#line 4112 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 37: /* gcc_builtin_expressions: "__builtin_has_attribute" '(' assignment_expression ',' identifier_or_typedef_name '(' argument_expression_list ')' ')'  */
#line 464 "/workspace/source/src/ansi-c/parser.y"
        {
          // attribute-with-arguments form, e.g. counted_by(n); arguments
          // are discarded along with the name.
          yyval=yyvsp[-8];
          parser_stack(yyval).id(ID_gcc_builtin_has_attribute);
          mto(yyval, yyvsp[-6]);
        }
#line 4124 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 38: /* clang_builtin_expressions: "__builtin_convertvector" '(' assignment_expression ',' type_name ')'  */
#line 475 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-5];
          parser_stack(yyval).id(ID_clang_builtin_convertvector);
          mto(yyval, yyvsp[-3]);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
        }
#line 4135 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 39: /* cw_builtin_expressions: "_var_arg_typeof" '(' type_name ')'  */
#line 485 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          parser_stack(yyval).id(ID_cw_va_arg_typeof);
          parser_stack(yyval).add(ID_type_arg).swap(parser_stack(yyvsp[-1]));
        }
#line 4145 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 40: /* offsetof: "__offsetof" '(' type_name ',' offsetof_member_designator ')'  */
#line 494 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-5];
          parser_stack(yyval).id(ID_builtin_offsetof);
          parser_stack(yyval).add(ID_type_arg).swap(parser_stack(yyvsp[-3]));
          parser_stack(yyval).add(ID_designator).swap(parser_stack(yyvsp[-1]));
        }
#line 4156 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 41: /* offsetof_member_designator: member_name  */
#line 504 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          exprt op{ID_member};
          op.add_source_location()=parser_stack(yyvsp[0]).source_location();
          op.set(ID_component_name, parser_stack(yyvsp[0]).get(ID_C_base_name));
          parser_stack(yyval).add_to_operands(std::move(op));
        }
#line 4168 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 42: /* offsetof_member_designator: offsetof_member_designator '.' member_name  */
#line 512 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          set(yyvsp[-1], ID_member);
          parser_stack(yyvsp[-1]).set(ID_component_name, parser_stack(yyvsp[0]).get(ID_C_base_name));
          mto(yyval, yyvsp[-1]);
        }
#line 4179 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 43: /* offsetof_member_designator: offsetof_member_designator '[' comma_expression ']'  */
#line 519 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          set(yyvsp[-2], ID_index);
          mto(yyvsp[-2], yyvsp[-1]);
          mto(yyval, yyvsp[-2]);
        }
#line 4190 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 44: /* offsetof_member_designator: offsetof_member_designator "->" member_name  */
#line 526 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          set(yyvsp[-1], ID_index);
          parser_stack(yyvsp[-1]).add_to_operands(convert_integer_literal("0"));
          mto(yyval, yyvsp[-1]);
          set(yyvsp[-1], ID_member);
          parser_stack(yyvsp[-1]).set(ID_component_name, parser_stack(yyvsp[0]).get(ID_C_base_name));
          mto(yyval, yyvsp[-1]);
        }
#line 4204 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 45: /* quantifier_expression: "forall" compound_scope '{' declaration comma_expression '}'  */
#line 539 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-5];
          set(yyval, ID_forall);
          parser_stack(yyval).add_to_operands(tuple_exprt( { std::move(parser_stack(yyvsp[-2])) } ));
          mto(yyval, yyvsp[-1]);
          PARSER.pop_scope();
        }
#line 4216 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 46: /* quantifier_expression: "exists" compound_scope '{' declaration comma_expression '}'  */
#line 547 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-5];
          set(yyval, ID_exists);
          parser_stack(yyval).add_to_operands(tuple_exprt( { std::move(parser_stack(yyvsp[-2])) } ));
          mto(yyval, yyvsp[-1]);
          PARSER.pop_scope();
        }
#line 4228 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 47: /* cprover_contract_loop_invariant: "__CPROVER_loop_invariant" '(' ACSL_binding_expression ')'  */
#line 558 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1]; }
#line 4234 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 48: /* cprover_contract_loop_invariant_list: cprover_contract_loop_invariant  */
#line 563 "/workspace/source/src/ansi-c/parser.y"
        { init(yyval); mto(yyval, yyvsp[0]); }
#line 4240 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 49: /* cprover_contract_loop_invariant_list: cprover_contract_loop_invariant_list cprover_contract_loop_invariant  */
#line 565 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1]; mto(yyval, yyvsp[0]); }
#line 4246 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 50: /* cprover_contract_loop_invariant_list_opt: %empty  */
#line 570 "/workspace/source/src/ansi-c/parser.y"
        { init(yyval); parser_stack(yyval).make_nil(); }
#line 4252 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 52: /* ACSL_binding_expression_list: ACSL_binding_expression  */
#line 576 "/workspace/source/src/ansi-c/parser.y"
        { init(yyval); mto(yyval, yyvsp[0]); }
#line 4258 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 53: /* ACSL_binding_expression_list: ACSL_binding_expression_list ',' ACSL_binding_expression  */
#line 578 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-2]; mto(yyval, yyvsp[0]); }
#line 4264 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 54: /* cprover_contract_decreases_opt: %empty  */
#line 583 "/workspace/source/src/ansi-c/parser.y"
        { init(yyval); parser_stack(yyval).make_nil(); }
#line 4270 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 55: /* cprover_contract_decreases_opt: "__CPROVER_decreases" '(' ACSL_binding_expression_list ')'  */
#line 585 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1]; }
#line 4276 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 56: /* statement_expression: '(' compound_statement ')'  */
#line 589 "/workspace/source/src/ansi-c/parser.y"
        { 
          yyval=yyvsp[-2];
          set(yyval, ID_side_effect);
          parser_stack(yyval).set(ID_statement, ID_statement_expression);
          mto(yyval, yyvsp[-1]);
        }
#line 4287 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 58: /* postfix_expression: postfix_expression '[' comma_expression ']'  */
#line 600 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-3], yyvsp[-2], ID_index, yyvsp[-1]); }
#line 4293 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 59: /* postfix_expression: postfix_expression '(' ')'  */
#line 602 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_side_effect);
          auto &side_effect = to_side_effect_expr(parser_stack(yyval));
          side_effect.set_statement(ID_function_call);
          side_effect.operands().resize(2);
          to_binary_expr(side_effect).op0().swap(parser_stack(yyvsp[-2]));
          to_binary_expr(side_effect).op1().clear();
          to_binary_expr(side_effect).op1().id(ID_arguments);
        }
#line 4307 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 60: /* postfix_expression: postfix_expression '(' argument_expression_list ')'  */
#line 612 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-2];
          set(yyval, ID_side_effect);
          auto &side_effect = to_side_effect_expr(parser_stack(yyval));
          side_effect.set_statement(ID_function_call);
          side_effect.operands().resize(2);
          to_binary_expr(side_effect).op0().swap(parser_stack(yyvsp[-3]));
          to_binary_expr(side_effect).op1().swap(parser_stack(yyvsp[-1]));
          to_binary_expr(side_effect).op1().id(ID_arguments);
        }
#line 4321 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 61: /* postfix_expression: postfix_expression '.' member_name  */
#line 622 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_member);
          mto(yyval, yyvsp[-2]);
          parser_stack(yyval).set(ID_component_name, parser_stack(yyvsp[0]).get(ID_C_base_name));
        }
#line 4331 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 62: /* postfix_expression: postfix_expression "->" member_name  */
#line 628 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_ptrmember);
          mto(yyval, yyvsp[-2]);
          parser_stack(yyval).set(ID_component_name, parser_stack(yyvsp[0]).get(ID_C_base_name));
        }
#line 4341 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 63: /* postfix_expression: postfix_expression "++"  */
#line 634 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0];
          set(yyval, ID_side_effect);
          parser_stack(yyval).set(ID_statement, ID_postincrement);
          mto(yyval, yyvsp[-1]);
        }
#line 4351 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 64: /* postfix_expression: postfix_expression "--"  */
#line 640 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0];
          set(yyval, ID_side_effect);
          parser_stack(yyval).set(ID_statement, ID_postdecrement);
          mto(yyval, yyvsp[-1]);
        }
#line 4361 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 65: /* postfix_expression: '(' type_name ')' '{' initializer_list_opt '}'  */
#line 647 "/workspace/source/src/ansi-c/parser.y"
        {
          exprt tmp(ID_initializer_list);
          tmp.add_source_location()=parser_stack(yyvsp[-2]).source_location();
          tmp.operands().swap(parser_stack(yyvsp[-1]).operands());
          yyval=yyvsp[-5];
          set(yyval, ID_typecast);
          parser_stack(yyval).add_to_operands(std::move(tmp));
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-4]));
        }
#line 4375 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 66: /* postfix_expression: '(' type_name ')' '{' initializer_list ',' '}'  */
#line 657 "/workspace/source/src/ansi-c/parser.y"
        {
          // same as above
          exprt tmp(ID_initializer_list);
          tmp.add_source_location()=parser_stack(yyvsp[-3]).source_location();
          tmp.operands().swap(parser_stack(yyvsp[-2]).operands());
          yyval=yyvsp[-6];
          set(yyval, ID_typecast);
          parser_stack(yyval).add_to_operands(std::move(tmp));
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-5]));
        }
#line 4390 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 69: /* argument_expression_list: assignment_expression  */
#line 676 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_expression_list);
          mto(yyval, yyvsp[0]);
        }
#line 4399 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 70: /* argument_expression_list: argument_expression_list ',' assignment_expression  */
#line 681 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 4408 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 72: /* unary_expression: "++" unary_expression  */
#line 690 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_side_effect);
          parser_stack(yyval).set(ID_statement, ID_preincrement);
          mto(yyval, yyvsp[0]);
        }
#line 4418 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 73: /* unary_expression: "--" unary_expression  */
#line 696 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_side_effect);
          parser_stack(yyval).set(ID_statement, ID_predecrement);
          mto(yyval, yyvsp[0]);
        }
#line 4428 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 74: /* unary_expression: '&' cast_expression  */
#line 702 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_address_of);
          mto(yyval, yyvsp[0]);
        }
#line 4437 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 75: /* unary_expression: "&&" gcc_local_label  */
#line 707 "/workspace/source/src/ansi-c/parser.y"
        { // this takes the address of a label (a gcc extension)
          yyval=yyvsp[-1];
          irep_idt identifier=PARSER.lookup_label(parser_stack(yyvsp[0]).get(ID_C_base_name));
          set(yyval, ID_address_of);
          parser_stack(yyval).operands().resize(1);
          auto &op = to_unary_expr(parser_stack(yyval)).op();
          op=parser_stack(yyvsp[0]);
          op.id(ID_label);
          op.set(ID_identifier, identifier);
        }
#line 4452 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 76: /* unary_expression: '*' cast_expression  */
#line 718 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_dereference);
          mto(yyval, yyvsp[0]);
        }
#line 4461 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 77: /* unary_expression: '+' cast_expression  */
#line 723 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_unary_plus);
          mto(yyval, yyvsp[0]);
        }
#line 4470 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 78: /* unary_expression: '-' cast_expression  */
#line 728 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_unary_minus);
          mto(yyval, yyvsp[0]);
        }
#line 4479 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 79: /* unary_expression: '~' cast_expression  */
#line 733 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_bitnot);
          mto(yyval, yyvsp[0]);
        }
#line 4488 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 80: /* unary_expression: '!' cast_expression  */
#line 738 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_not);
          mto(yyval, yyvsp[0]);
        }
#line 4497 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 81: /* unary_expression: "sizeof" unary_expression  */
#line 743 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_sizeof);
          mto(yyval, yyvsp[0]);
        }
#line 4506 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 82: /* unary_expression: "sizeof" '(' type_name ')'  */
#line 748 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-3];
          set(yyval, ID_sizeof);
          parser_stack(yyval).add(ID_type_arg).swap(parser_stack(yyvsp[-1]));
        }
#line 4515 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 83: /* unary_expression: "__alignof__" unary_expression  */
#line 753 "/workspace/source/src/ansi-c/parser.y"
        { // note no parentheses for expressions, just like sizeof
          yyval=yyvsp[-1];
          set(yyval, ID_alignof);
          mto(yyval, yyvsp[0]);
        }
#line 4525 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 84: /* unary_expression: "__alignof__" '(' type_name ')'  */
#line 759 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          parser_stack(yyval).id(ID_alignof);
          parser_stack(yyval).add(ID_type_arg).swap(parser_stack(yyvsp[-1]));
        }
#line 4535 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 85: /* unary_expression: "__builtin_bit_cast" '(' type_name ',' unary_expression ')'  */
#line 765 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-5];
          set(yyval, ID_bit_cast);
          mto(yyval, yyvsp[-1]);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-3]));
        }
#line 4545 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 87: /* cast_expression: '(' type_name ')' cast_expression  */
#line 775 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          set(yyval, ID_typecast);
          mto(yyval, yyvsp[0]);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-2]));
        }
#line 4556 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 88: /* cast_expression: "__real__" cast_expression  */
#line 782 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_complex_real);
          mto(yyval, yyvsp[0]);
        }
#line 4565 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 89: /* cast_expression: "__imag__" cast_expression  */
#line 787 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          set(yyval, ID_complex_imag);
          mto(yyval, yyvsp[0]);
        }
#line 4574 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 91: /* multiplicative_expression: multiplicative_expression '*' cast_expression  */
#line 796 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_mult, yyvsp[0]); }
#line 4580 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 92: /* multiplicative_expression: multiplicative_expression '/' cast_expression  */
#line 798 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_div, yyvsp[0]); }
#line 4586 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 93: /* multiplicative_expression: multiplicative_expression '%' cast_expression  */
#line 800 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_mod, yyvsp[0]); }
#line 4592 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 95: /* additive_expression: additive_expression '+' multiplicative_expression  */
#line 806 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_plus, yyvsp[0]); }
#line 4598 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 96: /* additive_expression: additive_expression '-' multiplicative_expression  */
#line 808 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_minus, yyvsp[0]); }
#line 4604 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 98: /* shift_expression: shift_expression "<<" additive_expression  */
#line 814 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_shl, yyvsp[0]); }
#line 4610 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 99: /* shift_expression: shift_expression ">>" additive_expression  */
#line 816 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_shr, yyvsp[0]); }
#line 4616 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 101: /* relational_expression: relational_expression '<' shift_expression  */
#line 822 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_lt, yyvsp[0]); }
#line 4622 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 102: /* relational_expression: relational_expression '>' shift_expression  */
#line 824 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_gt, yyvsp[0]); }
#line 4628 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 103: /* relational_expression: relational_expression "<=" shift_expression  */
#line 826 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_le, yyvsp[0]); }
#line 4634 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 104: /* relational_expression: relational_expression ">=" shift_expression  */
#line 828 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_ge, yyvsp[0]); }
#line 4640 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 106: /* equality_expression: equality_expression "==" relational_expression  */
#line 834 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_equal, yyvsp[0]); }
#line 4646 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 107: /* equality_expression: equality_expression "!=" relational_expression  */
#line 836 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_notequal, yyvsp[0]); }
#line 4652 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 109: /* and_expression: and_expression '&' equality_expression  */
#line 842 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_bitand, yyvsp[0]); }
#line 4658 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 111: /* exclusive_or_expression: exclusive_or_expression '^' and_expression  */
#line 848 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_bitxor, yyvsp[0]); }
#line 4664 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 113: /* inclusive_or_expression: inclusive_or_expression '|' exclusive_or_expression  */
#line 854 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_bitor, yyvsp[0]); }
#line 4670 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 115: /* logical_and_expression: logical_and_expression "&&" inclusive_or_expression  */
#line 860 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_and, yyvsp[0]); }
#line 4676 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 117: /* logical_xor_expression: logical_xor_expression "^^" logical_and_expression  */
#line 866 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_xor, yyvsp[0]); }
#line 4682 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 119: /* logical_or_expression: logical_or_expression "||" logical_xor_expression  */
#line 872 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_or, yyvsp[0]); }
#line 4688 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 121: /* logical_implication_expression: logical_or_expression "==>" logical_implication_expression  */
#line 881 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_implies, yyvsp[0]); }
#line 4694 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 123: /* logical_equivalence_expression: logical_equivalence_expression "<==>" logical_implication_expression  */
#line 890 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_equal, yyvsp[0]); }
#line 4700 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 125: /* ACSL_binding_expression: "\\forall" compound_scope declaration ACSL_binding_expression  */
#line 897 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          set(yyval, ID_forall);
          parser_stack(yyval).add_to_operands(tuple_exprt( { std::move(parser_stack(yyvsp[-1])) } ));
          mto(yyval, yyvsp[0]);
          PARSER.pop_scope();
        }
#line 4712 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 126: /* ACSL_binding_expression: "\\exists" compound_scope declaration ACSL_binding_expression  */
#line 905 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          set(yyval, ID_exists);
          parser_stack(yyval).add_to_operands(tuple_exprt( { std::move(parser_stack(yyvsp[-1])) } ));
          mto(yyval, yyvsp[0]);
          PARSER.pop_scope();
        }
#line 4724 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 127: /* ACSL_binding_expression: "\\lambda" compound_scope declaration ACSL_binding_expression  */
#line 913 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          set(yyval, ID_lambda);
          parser_stack(yyval).add_to_operands(tuple_exprt( { std::move(parser_stack(yyvsp[-1])) } ));
          mto(yyval, yyvsp[0]);
          PARSER.pop_scope();
        }
#line 4736 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 129: /* conditional_expression: logical_equivalence_expression '?' comma_expression ':' conditional_expression  */
#line 925 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-3];
          parser_stack(yyval).id(ID_if);
          mto(yyval, yyvsp[-4]);
          mto(yyval, yyvsp[-2]);
          mto(yyval, yyvsp[0]);
        }
#line 4747 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 130: /* conditional_expression: logical_equivalence_expression '?' ':' conditional_expression  */
#line 932 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-2];
          parser_stack(yyval).id(ID_side_effect);
          parser_stack(yyval).set(ID_statement, ID_gcc_conditional_expression);
          mto(yyval, yyvsp[-3]);
          mto(yyval, yyvsp[0]);
        }
#line 4758 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 132: /* assignment_expression: cast_expression '=' assignment_expression  */
#line 943 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign); }
#line 4764 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 133: /* assignment_expression: cast_expression "*=" assignment_expression  */
#line 945 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_mult); }
#line 4770 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 134: /* assignment_expression: cast_expression "/=" assignment_expression  */
#line 947 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_div); }
#line 4776 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 135: /* assignment_expression: cast_expression "%=" assignment_expression  */
#line 949 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_mod); }
#line 4782 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 136: /* assignment_expression: cast_expression "+=" assignment_expression  */
#line 951 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_plus); }
#line 4788 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 137: /* assignment_expression: cast_expression "-=" assignment_expression  */
#line 953 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_minus); }
#line 4794 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 138: /* assignment_expression: cast_expression "<<=" assignment_expression  */
#line 955 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_shl); }
#line 4800 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 139: /* assignment_expression: cast_expression ">>=" assignment_expression  */
#line 957 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_shr); }
#line 4806 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 140: /* assignment_expression: cast_expression "&=" assignment_expression  */
#line 959 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_bitand); }
#line 4812 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 141: /* assignment_expression: cast_expression "^=" assignment_expression  */
#line 961 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_bitxor); }
#line 4818 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 142: /* assignment_expression: cast_expression "|=" assignment_expression  */
#line 963 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_side_effect, yyvsp[0]); parser_stack(yyval).set(ID_statement, ID_assign_bitor); }
#line 4824 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 144: /* comma_expression: comma_expression ',' assignment_expression  */
#line 969 "/workspace/source/src/ansi-c/parser.y"
        { binary(yyval, yyvsp[-2], yyvsp[-1], ID_comma, yyvsp[0]); }
#line 4830 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 146: /* comma_expression_opt: %empty  */
#line 978 "/workspace/source/src/ansi-c/parser.y"
        { init(yyval); parser_stack(yyval).make_nil(); }
#line 4836 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 148: /* declaration: declaration_specifier ';'  */
#line 986 "/workspace/source/src/ansi-c/parser.y"
        {
          // type only, no declarator!
          init(yyval, ID_declaration);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
        }
#line 4846 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 149: /* declaration: type_specifier ';'  */
#line 992 "/workspace/source/src/ansi-c/parser.y"
        {
          // type only, no identifier!
          init(yyval, ID_declaration);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
        }
#line 4856 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 153: /* static_assert_declaration: "_Static_assert" '(' assignment_expression ',' assignment_expression ')'  */
#line 1004 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-5];
          set(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_static_assert(true);
          mto(yyval, yyvsp[-3]);
          mto(yyval, yyvsp[-1]);
        }
#line 4868 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 154: /* static_assert_declaration: "_Static_assert" '(' assignment_expression ')'  */
#line 1012 "/workspace/source/src/ansi-c/parser.y"
        {
          // C23 adds static_assert without message
          yyval=yyvsp[-3];
          set(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_static_assert(true);
          mto(yyval, yyvsp[-1]);
        }
#line 4880 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 155: /* @1: %empty  */
#line 1023 "/workspace/source/src/ansi-c/parser.y"
          {
            init(yyval, ID_declaration);
            parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
            PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
          }
#line 4890 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 156: /* default_declaring_list: declaration_qualifier_list identifier_declarator @1 initializer_opt  */
#line 1029 "/workspace/source/src/ansi-c/parser.y"
        {
          // patch on the initializer
          yyval=yyvsp[-1];
          to_ansi_c_declaration(parser_stack(yyval)).add_initializer(parser_stack(yyvsp[0]));
        }
#line 4900 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 157: /* @2: %empty  */
#line 1035 "/workspace/source/src/ansi-c/parser.y"
          {
            init(yyval, ID_declaration);
            parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
            PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
          }
#line 4910 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 158: /* default_declaring_list: type_qualifier_list identifier_declarator @2 initializer_opt  */
#line 1041 "/workspace/source/src/ansi-c/parser.y"
        {
          // patch on the initializer
          yyval=yyvsp[-1];
          to_ansi_c_declaration(parser_stack(yyval)).add_initializer(parser_stack(yyvsp[0]));
        }
#line 4920 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 159: /* $@3: %empty  */
#line 1047 "/workspace/source/src/ansi-c/parser.y"
          {
            // just add the declarator
            PARSER.add_declarator(parser_stack(yyvsp[-2]), parser_stack(yyvsp[0]));
            // Needs to be done before initializer, as we want to see that identifier
            // already there!
          }
#line 4931 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 160: /* default_declaring_list: default_declaring_list ',' identifier_declarator $@3 initializer_opt  */
#line 1054 "/workspace/source/src/ansi-c/parser.y"
        {
          // patch on the initializer
          yyval=yyvsp[-4];
          to_ansi_c_declaration(parser_stack(yyval)).add_initializer(parser_stack(yyvsp[0]));
        }
#line 4941 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 161: /* post_declarator_attribute: "__asm__ (with parentheses)" volatile_or_goto_opt '(' gcc_asm_commands ')'  */
#line 1063 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-4];
          parser_stack(yyval).id(ID_asm);
          parser_stack(yyval).set(ID_flavor, ID_gcc);
          parser_stack(yyval).operands().swap(parser_stack(yyvsp[-1]).operands());
        }
#line 4952 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 163: /* post_declarator_attributes: post_declarator_attributes post_declarator_attribute  */
#line 1074 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 4960 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 165: /* post_declarator_attributes_opt: %empty  */
#line 1082 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
        }
#line 4968 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 167: /* @4: %empty  */
#line 1091 "/workspace/source/src/ansi-c/parser.y"
          {
            yyvsp[-1]=merge(yyvsp[0], yyvsp[-1]); // type attribute
            
            // the symbol has to be visible during initialization
            init(yyval, ID_declaration);
            parser_stack(yyval).type().swap(parser_stack(yyvsp[-2]));
            PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-1]));
          }
#line 4981 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 168: /* declaring_list: declaration_specifier declarator post_declarator_attributes_opt @4 initializer_opt  */
#line 1100 "/workspace/source/src/ansi-c/parser.y"
        {
          // add the initializer
          yyval=yyvsp[-1];
          to_ansi_c_declaration(parser_stack(yyval)).add_initializer(parser_stack(yyvsp[0]));
        }
#line 4991 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 169: /* @5: %empty  */
#line 1107 "/workspace/source/src/ansi-c/parser.y"
          {
            yyvsp[-1]=merge(yyvsp[0], yyvsp[-1]);
            
            // the symbol has to be visible during initialization
            init(yyval, ID_declaration);
            parser_stack(yyval).type().swap(parser_stack(yyvsp[-2]));
            PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-1]));
          }
#line 5004 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 170: /* declaring_list: type_specifier declarator post_declarator_attributes_opt @5 initializer_opt  */
#line 1116 "/workspace/source/src/ansi-c/parser.y"
        {
          // add the initializer
          yyval=yyvsp[-1];
          to_ansi_c_declaration(parser_stack(yyval)).add_initializer(parser_stack(yyvsp[0]));
        }
#line 5014 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 171: /* declaring_list: "__auto_type" declarator post_declarator_attributes_opt '=' initializer  */
#line 1123 "/workspace/source/src/ansi-c/parser.y"
        {
          // handled as typeof(initializer)
          parser_stack(yyvsp[-4]).id(ID_typeof);
          parser_stack(yyvsp[-4]).copy_to_operands(parser_stack(yyvsp[0]));

          yyvsp[-3]=merge(yyvsp[-2], yyvsp[-3]);

          // the symbol has to be visible during initialization
          init(yyval, ID_declaration);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-4]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-3]));
          // add the initializer
          to_ansi_c_declaration(parser_stack(yyval)).add_initializer(parser_stack(yyvsp[0]));
        }
#line 5033 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 172: /* $@6: %empty  */
#line 1139 "/workspace/source/src/ansi-c/parser.y"
          {
            // type attribute goes into declarator
            yyvsp[0]=merge(yyvsp[0], yyvsp[-2]);
            yyvsp[-1]=merge(yyvsp[0], yyvsp[-1]);
            PARSER.add_declarator(parser_stack(yyvsp[-4]), parser_stack(yyvsp[-1]));
          }
#line 5044 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 173: /* declaring_list: declaring_list ',' gcc_type_attribute_opt declarator post_declarator_attributes_opt $@6 initializer_opt  */
#line 1146 "/workspace/source/src/ansi-c/parser.y"
        {
          // add in the initializer
          yyval=yyvsp[-6];
          to_ansi_c_declaration(parser_stack(yyval)).add_initializer(parser_stack(yyvsp[0]));
        }
#line 5054 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 185: /* declaration_qualifier_list: type_qualifier_list storage_class  */
#line 1172 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5062 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 187: /* declaration_qualifier_list: declaration_qualifier_list gcc_attribute_specifier  */
#line 1177 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5070 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 188: /* declaration_qualifier_list: declaration_qualifier_list declaration_qualifier  */
#line 1181 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5078 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 190: /* type_qualifier_list: type_qualifier_list type_qualifier  */
#line 1189 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5086 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 191: /* type_qualifier_list: type_qualifier_list gcc_attribute_specifier  */
#line 1196 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5094 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 193: /* attribute_type_qualifier_list: attribute_type_qualifier_list attribute_or_type_qualifier  */
#line 1204 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5102 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 196: /* type_qualifier: "_Atomic"  */
#line 1215 "/workspace/source/src/ansi-c/parser.y"
                                    { yyval=yyvsp[0]; set(yyval, ID_atomic); }
#line 5108 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 197: /* type_qualifier: "const"  */
#line 1216 "/workspace/source/src/ansi-c/parser.y"
                                    { yyval=yyvsp[0]; set(yyval, ID_const); }
#line 5114 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 198: /* type_qualifier: "restrict"  */
#line 1217 "/workspace/source/src/ansi-c/parser.y"
                                    { yyval=yyvsp[0]; set(yyval, ID_restrict); }
#line 5120 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 199: /* type_qualifier: "volatile"  */
#line 1218 "/workspace/source/src/ansi-c/parser.y"
                                    { yyval=yyvsp[0]; set(yyval, ID_volatile); }
#line 5126 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 200: /* type_qualifier: "__CPROVER_atomic"  */
#line 1219 "/workspace/source/src/ansi-c/parser.y"
                                    { yyval=yyvsp[0]; set(yyval, ID_cprover_atomic); }
#line 5132 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 201: /* type_qualifier: "__ptr32"  */
#line 1220 "/workspace/source/src/ansi-c/parser.y"
                                    { yyval=yyvsp[0]; set(yyval, ID_ptr32); }
#line 5138 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 202: /* type_qualifier: "__ptr64"  */
#line 1221 "/workspace/source/src/ansi-c/parser.y"
                                    { yyval=yyvsp[0]; set(yyval, ID_ptr64); }
#line 5144 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 203: /* type_qualifier: "__based" '(' comma_expression ')'  */
#line 1222 "/workspace/source/src/ansi-c/parser.y"
                                                 { yyval=yyvsp[-3]; set(yyval, ID_msc_based); mto(yyval, yyvsp[-1]); }
#line 5150 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 205: /* alignas_specifier: "_Alignas" '(' comma_expression ')'  */
#line 1228 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-3];
          parser_stack(yyval).id(ID_aligned);
          parser_stack(yyval).set(ID_size, parser_stack(yyvsp[-1]));
        }
#line 5159 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 206: /* alignas_specifier: "_Alignas" '(' type_name ')'  */
#line 1233 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-3];
          parser_stack(yyval).id(ID_aligned);
          parser_stack(yyvsp[-1]).set(ID_type_arg, parser_stack(yyvsp[-1]));
        }
#line 5168 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 213: /* attribute_type_qualifier_storage_class_list: attribute_type_qualifier_storage_class_list attribute_or_type_qualifier_or_storage_class  */
#line 1253 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5176 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 214: /* basic_declaration_specifier: declaration_qualifier_list basic_type_name gcc_type_attribute_opt  */
#line 1260 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5184 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 215: /* basic_declaration_specifier: basic_type_specifier storage_class gcc_type_attribute_opt  */
#line 1264 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5192 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 216: /* basic_declaration_specifier: basic_declaration_specifier declaration_qualifier gcc_type_attribute_opt  */
#line 1268 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5200 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 217: /* basic_declaration_specifier: basic_declaration_specifier basic_type_name gcc_type_attribute_opt  */
#line 1272 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5208 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 218: /* basic_type_specifier: basic_type_name gcc_type_attribute_opt  */
#line 1279 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]); // type attribute
        }
#line 5216 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 219: /* basic_type_specifier: type_qualifier_list basic_type_name gcc_type_attribute_opt  */
#line 1283 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5224 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 220: /* basic_type_specifier: basic_type_specifier type_qualifier  */
#line 1287 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5232 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 221: /* basic_type_specifier: basic_type_specifier basic_type_name gcc_type_attribute_opt  */
#line 1291 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5240 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 222: /* sue_declaration_specifier: declaration_qualifier_list elaborated_type_name  */
#line 1298 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5248 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 223: /* sue_declaration_specifier: sue_type_specifier storage_class gcc_type_attribute_opt  */
#line 1302 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5256 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 224: /* sue_declaration_specifier: sue_declaration_specifier declaration_qualifier gcc_type_attribute_opt  */
#line 1306 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5264 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 226: /* sue_type_specifier: type_qualifier_list elaborated_type_name  */
#line 1314 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5272 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 227: /* sue_type_specifier: sue_type_specifier type_qualifier gcc_type_attribute_opt  */
#line 1318 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5280 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 228: /* typedef_declaration_specifier: typedef_type_specifier storage_class gcc_type_attribute_opt  */
#line 1325 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5288 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 229: /* typedef_declaration_specifier: declaration_qualifier_list typedef_name gcc_type_attribute_opt  */
#line 1329 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5296 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 230: /* typedef_declaration_specifier: typedef_declaration_specifier declaration_qualifier gcc_type_attribute_opt  */
#line 1333 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5304 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 231: /* typeof_declaration_specifier: typeof_type_specifier storage_class gcc_type_attribute_opt  */
#line 1340 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5312 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 232: /* typeof_declaration_specifier: declaration_qualifier_list typeof_specifier gcc_type_attribute_opt  */
#line 1344 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5320 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 233: /* typeof_declaration_specifier: typeof_declaration_specifier declaration_qualifier gcc_type_attribute_opt  */
#line 1348 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5328 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 234: /* atomic_declaration_specifier: atomic_type_specifier storage_class gcc_type_attribute_opt  */
#line 1355 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5336 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 235: /* atomic_declaration_specifier: declaration_qualifier_list atomic_specifier gcc_type_attribute_opt  */
#line 1359 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5344 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 236: /* atomic_declaration_specifier: atomic_declaration_specifier declaration_qualifier gcc_type_attribute_opt  */
#line 1363 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5352 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 237: /* typedef_type_specifier: typedef_name gcc_type_attribute_opt  */
#line 1370 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5360 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 238: /* typedef_type_specifier: type_qualifier_list typedef_name gcc_type_attribute_opt  */
#line 1374 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5368 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 239: /* typedef_type_specifier: typedef_type_specifier type_qualifier gcc_type_attribute_opt  */
#line 1378 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5376 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 240: /* typeof_specifier: "typeof" '(' comma_expression ')'  */
#line 1385 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-3];
          parser_stack(yyval).id(ID_typeof);
          mto(yyval, yyvsp[-1]);
        }
#line 5385 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 241: /* typeof_specifier: "typeof" '(' type_name ')'  */
#line 1390 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-3];
          parser_stack(yyval).id(ID_typeof);
          parser_stack(yyval).set(ID_type_arg, parser_stack(yyvsp[-1]));
        }
#line 5394 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 242: /* typeof_specifier: "typeof_unqual" '(' comma_expression ')'  */
#line 1395 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-3];
          parser_stack(yyval).id(ID_c_typeof_unqual);
          mto(yyval, yyvsp[-1]);
        }
#line 5403 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 243: /* typeof_specifier: "typeof_unqual" '(' type_name ')'  */
#line 1400 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-3];
          parser_stack(yyval).id(ID_c_typeof_unqual);
          parser_stack(yyval).set(ID_type_arg, parser_stack(yyvsp[-1]));
        }
#line 5412 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 245: /* typeof_type_specifier: type_qualifier_list typeof_specifier  */
#line 1409 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5420 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 246: /* typeof_type_specifier: type_qualifier_list typeof_specifier type_qualifier_list  */
#line 1413 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5428 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 247: /* typeof_type_specifier: typeof_specifier type_qualifier_list  */
#line 1417 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5436 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 248: /* atomic_specifier: "_Atomic()" '(' type_name ')'  */
#line 1424 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          parser_stack(yyval).id(ID_atomic_type_specifier);
          stack_type(yyval).add_subtype()=stack_type(yyvsp[-1]);
        }
#line 5446 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 250: /* atomic_type_specifier: type_qualifier_list atomic_specifier  */
#line 1434 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5454 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 251: /* atomic_type_specifier: type_qualifier_list atomic_specifier type_qualifier_list  */
#line 1438 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 5462 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 252: /* atomic_type_specifier: atomic_specifier type_qualifier_list  */
#line 1442 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 5470 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 253: /* msc_decl_identifier: TOK_MSC_IDENTIFIER  */
#line 1449 "/workspace/source/src/ansi-c/parser.y"
        {
          parser_stack(yyval).id(parser_stack(yyval).get(ID_identifier));
        }
#line 5478 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 254: /* msc_decl_identifier: TOK_TYPEDEFNAME  */
#line 1453 "/workspace/source/src/ansi-c/parser.y"
        {
          parser_stack(yyval).id(parser_stack(yyval).get(ID_identifier));
        }
#line 5486 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 255: /* msc_decl_identifier: "restrict"  */
#line 1457 "/workspace/source/src/ansi-c/parser.y"
        {
          parser_stack(yyval).id(ID_restrict);
        }
#line 5494 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 257: /* msc_decl_modifier: msc_decl_identifier '(' TOK_STRING ')'  */
#line 1465 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3]; mto(yyval, yyvsp[-1]);
        }
#line 5502 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 258: /* msc_decl_modifier: msc_decl_identifier '(' TOK_INTEGER ')'  */
#line 1469 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3]; mto(yyval, yyvsp[-1]);
        }
#line 5510 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 259: /* msc_decl_modifier: msc_decl_identifier '(' msc_decl_identifier '=' msc_decl_identifier ')'  */
#line 1473 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-5]; mto(yyval, yyvsp[-3]); mto(yyval, yyvsp[-1]);
        }
#line 5518 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 260: /* msc_decl_modifier: msc_decl_identifier '(' msc_decl_identifier '=' msc_decl_identifier ',' msc_decl_identifier '=' msc_decl_identifier ')'  */
#line 1477 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-9]; mto(yyval, yyvsp[-7]); mto(yyval, yyvsp[-5]); mto(yyval, yyvsp[-3]); mto(yyval, yyvsp[-1]);
        }
#line 5526 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 261: /* msc_decl_modifier: ','  */
#line 1480 "/workspace/source/src/ansi-c/parser.y"
              { init(yyval, ID_nil); }
#line 5532 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 262: /* msc_declspec_seq: msc_decl_modifier  */
#line 1485 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval); mto(yyval, yyvsp[0]);
        }
#line 5540 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 263: /* msc_declspec_seq: msc_declspec_seq msc_decl_modifier  */
#line 1489 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1]; mto(yyval, yyvsp[0]);
        }
#line 5548 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 264: /* msc_declspec: "__declspec" '(' msc_declspec_seq ')'  */
#line 1496 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3]; set(yyval, ID_msc_declspec);
          parser_stack(yyval).operands().swap(parser_stack(yyvsp[-1]).operands());
        }
#line 5557 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 265: /* msc_declspec: "__declspec" '(' ')'  */
#line 1501 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2]; set(yyval, ID_msc_declspec);
        }
#line 5565 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 266: /* msc_declspec_opt: %empty  */
#line 1508 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_nil);
        }
#line 5573 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 267: /* msc_declspec_opt: msc_declspec_opt msc_declspec  */
#line 1512 "/workspace/source/src/ansi-c/parser.y"
        {
          if(parser_stack(yyvsp[-1]).is_not_nil())
          {
            yyval = yyvsp[-1];
            exprt::operandst &operands = parser_stack(yyvsp[-1]).operands();
            operands.insert(
              operands.end(),
              parser_stack(yyvsp[0]).operands().begin(),
              parser_stack(yyvsp[0]).operands().end());
          }
          else
            yyval = yyvsp[0];
        }
#line 5591 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 268: /* storage_class: "typedef"  */
#line 1528 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; set(yyval, ID_typedef); }
#line 5597 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 269: /* storage_class: "extern"  */
#line 1529 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; set(yyval, ID_extern); }
#line 5603 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 270: /* storage_class: "static"  */
#line 1530 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; set(yyval, ID_static); }
#line 5609 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 271: /* storage_class: "auto"  */
#line 1531 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; set(yyval, ID_auto); }
#line 5615 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 272: /* storage_class: "register"  */
#line 1532 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; set(yyval, ID_register); }
#line 5621 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 273: /* storage_class: "inline"  */
#line 1533 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; set(yyval, ID_inline); }
#line 5627 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 274: /* storage_class: "_Thread_local"  */
#line 1534 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; set(yyval, ID_thread_local); }
#line 5633 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 275: /* storage_class: "__asm__"  */
#line 1535 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; set(yyval, ID_asm); }
#line 5639 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 276: /* storage_class: msc_declspec  */
#line 1536 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; }
#line 5645 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 277: /* storage_class: "__forceinline"  */
#line 1538 "/workspace/source/src/ansi-c/parser.y"
        {
          // equivalent to always_inline, and seemingly also has the semantics
          // of extern inline in that multiple definitions can be provided in
          // the same translation unit
          init(yyval);
          set(yyval, ID_static);
          set(yyvsp[0], ID_inline);
          #if 0
          // enable once always_inline support is reinstantiated
          yyvsp[0]=merge(yyvsp[0], yyval);

          init(yyval);
          set(yyval, ID_always_inline);
          yyval=merge(yyvsp[0], yyval);
          #else
          yyval=merge(yyvsp[0], yyval);
          #endif
        }
#line 5668 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 278: /* basic_type_name: "int"  */
#line 1559 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_int); }
#line 5674 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 279: /* basic_type_name: "__int8"  */
#line 1560 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_int8); }
#line 5680 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 280: /* basic_type_name: "__int16"  */
#line 1561 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_int16); }
#line 5686 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 281: /* basic_type_name: "__int32"  */
#line 1562 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_int32); }
#line 5692 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 282: /* basic_type_name: "__int64"  */
#line 1563 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_int64); }
#line 5698 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 283: /* basic_type_name: "char"  */
#line 1564 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_char); }
#line 5704 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 284: /* basic_type_name: "short"  */
#line 1565 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_short); }
#line 5710 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 285: /* basic_type_name: "long"  */
#line 1566 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_long); }
#line 5716 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 286: /* basic_type_name: "float"  */
#line 1567 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_float); }
#line 5722 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 287: /* basic_type_name: "_Float16"  */
#line 1568 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_float16); }
#line 5728 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 288: /* basic_type_name: "_Float32"  */
#line 1569 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_float32); }
#line 5734 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 289: /* basic_type_name: "_Float32x"  */
#line 1570 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_float32x); }
#line 5740 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 290: /* basic_type_name: "_Float64"  */
#line 1571 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_float64); }
#line 5746 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 291: /* basic_type_name: "_Float64x"  */
#line 1572 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_float64x); }
#line 5752 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 292: /* basic_type_name: "__float80"  */
#line 1573 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_float80); }
#line 5758 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 293: /* basic_type_name: "_Float128"  */
#line 1574 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_float128); }
#line 5764 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 294: /* basic_type_name: "_Float128x"  */
#line 1575 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_float128x); }
#line 5770 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 295: /* basic_type_name: "__int128"  */
#line 1576 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_int128); }
#line 5776 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 296: /* basic_type_name: "_Decimal32"  */
#line 1577 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_decimal32); }
#line 5782 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 297: /* basic_type_name: "_Decimal64"  */
#line 1578 "/workspace/source/src/ansi-c/parser.y"
                            { yyval=yyvsp[0]; set(yyval, ID_gcc_decimal64); }
#line 5788 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 298: /* basic_type_name: "_Decimal128"  */
#line 1579 "/workspace/source/src/ansi-c/parser.y"
                             { yyval=yyvsp[0]; set(yyval, ID_gcc_decimal128); }
#line 5794 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 299: /* basic_type_name: "double"  */
#line 1580 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_double); }
#line 5800 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 300: /* basic_type_name: "signed"  */
#line 1581 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_signed); }
#line 5806 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 301: /* basic_type_name: "unsigned"  */
#line 1582 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_unsigned); }
#line 5812 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 302: /* basic_type_name: "_BitInt" '(' constant_expression ')'  */
#line 1584 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_c_bitint);
          parser_stack(yyval).add(ID_size).swap(parser_stack(yyvsp[-1]));
        }
#line 5821 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 303: /* basic_type_name: "void"  */
#line 1588 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_void); }
#line 5827 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 304: /* basic_type_name: "bool"  */
#line 1589 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_c_bool); }
#line 5833 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 305: /* basic_type_name: "complex"  */
#line 1590 "/workspace/source/src/ansi-c/parser.y"
                       { yyval=yyvsp[0]; set(yyval, ID_complex); }
#line 5839 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 306: /* basic_type_name: "__CPROVER_bitvector" '[' comma_expression ']'  */
#line 1592 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          set(yyval, ID_custom_bv);
          parser_stack(yyval).add(ID_size).swap(parser_stack(yyvsp[-1]));
        }
#line 5849 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 307: /* basic_type_name: "__CPROVER_floatbv" '[' comma_expression ']' '[' comma_expression ']'  */
#line 1598 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-6];
          set(yyval, ID_custom_floatbv);
          parser_stack(yyval).add(ID_size).swap(parser_stack(yyvsp[-4]));
          parser_stack(yyval).add(ID_f).swap(parser_stack(yyvsp[-1]));
        }
#line 5860 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 308: /* basic_type_name: "__CPROVER_fixedbv" '[' comma_expression ']' '[' comma_expression ']'  */
#line 1605 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-6];
          set(yyval, ID_custom_fixedbv);
          parser_stack(yyval).add(ID_size).swap(parser_stack(yyvsp[-4]));
          parser_stack(yyval).add(ID_f).swap(parser_stack(yyvsp[-1]));
        }
#line 5871 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 309: /* basic_type_name: "__CPROVER_bool"  */
#line 1611 "/workspace/source/src/ansi-c/parser.y"
                           { yyval=yyvsp[0]; set(yyval, ID_proper_bool); }
#line 5877 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 313: /* array_of_construct: "array_of" '<' type_name '>'  */
#line 1622 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-3]; stack_type(yyval).add_subtype().swap(parser_stack(yyvsp[-2])); }
#line 5883 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 314: /* pragma_packed: %empty  */
#line 1626 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          if(!PARSER.pragma_pack.empty() &&
             PARSER.pragma_pack.back() == 1)
          {
            set(yyval, ID_packed);
          }
        }
#line 5896 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 315: /* $@7: %empty  */
#line 1640 "/workspace/source/src/ansi-c/parser.y"
          {
            // an anon struct/union with body
          }
#line 5904 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 316: /* aggregate_name: aggregate_key gcc_type_attribute_opt msc_declspec_opt $@7 '{' member_declaration_list_opt '}' gcc_type_attribute_opt pragma_packed  */
#line 1646 "/workspace/source/src/ansi-c/parser.y"
        {
          // save the members
          parser_stack(yyvsp[-8]).add(ID_components).get_sub().swap(
            (irept::subt &)parser_stack(yyvsp[-3]).operands());

          // throw in the gcc attributes
          yyval=merge(yyvsp[-8], merge(yyvsp[-7], merge(yyvsp[-1], yyvsp[0])));
        }
#line 5917 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 317: /* $@8: %empty  */
#line 1658 "/workspace/source/src/ansi-c/parser.y"
          {
            // A struct/union with tag and body.
            PARSER.add_tag_with_body(parser_stack(yyvsp[0]));
            parser_stack(yyvsp[-3]).set(ID_tag, parser_stack(yyvsp[0]));
          }
#line 5927 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 318: /* aggregate_name: aggregate_key gcc_type_attribute_opt msc_declspec_opt identifier_or_typedef_name $@8 '{' member_declaration_list_opt '}' gcc_type_attribute_opt pragma_packed  */
#line 1666 "/workspace/source/src/ansi-c/parser.y"
        {
          // save the members
          parser_stack(yyvsp[-9]).add(ID_components).get_sub().swap(
            (irept::subt &)parser_stack(yyvsp[-3]).operands());

          // throw in the gcc attributes
          yyval=merge(yyvsp[-9], merge(yyvsp[-8], merge(yyvsp[-1], yyvsp[0])));
        }
#line 5940 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 319: /* $@9: %empty  */
#line 1678 "/workspace/source/src/ansi-c/parser.y"
          {
            // a struct/union with tag but without body
            parser_stack(yyvsp[-3]).set(ID_tag, parser_stack(yyvsp[0]));
          }
#line 5949 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 320: /* aggregate_name: aggregate_key gcc_type_attribute_opt msc_declspec_opt identifier_or_typedef_name $@9 gcc_type_attribute_opt  */
#line 1683 "/workspace/source/src/ansi-c/parser.y"
        {
          parser_stack(yyvsp[-5]).set(ID_components, ID_nil);
          // type attributes
          yyval=merge(yyvsp[-5], merge(yyvsp[-4], yyvsp[0]));
        }
#line 5959 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 321: /* aggregate_key: "struct"  */
#line 1692 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_struct); }
#line 5965 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 322: /* aggregate_key: "union"  */
#line 1694 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_union); }
#line 5971 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 323: /* gcc_type_attribute: "packed"  */
#line 1699 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_packed); }
#line 5977 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 324: /* gcc_type_attribute: "transparent_union"  */
#line 1701 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_transparent_union); }
#line 5983 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 325: /* gcc_type_attribute: "vector_size" '(' comma_expression ')'  */
#line 1703 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-3]; set(yyval, ID_frontend_vector); parser_stack(yyval).add(ID_size)=parser_stack(yyvsp[-1]); }
#line 5989 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 326: /* gcc_type_attribute: "aligned"  */
#line 1705 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_aligned); }
#line 5995 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 327: /* gcc_type_attribute: "aligned" '(' comma_expression ')'  */
#line 1707 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-3]; set(yyval, ID_aligned); parser_stack(yyval).set(ID_size, parser_stack(yyvsp[-1])); }
#line 6001 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 328: /* gcc_type_attribute: "mode" '(' identifier ')'  */
#line 1709 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-3]; set(yyval, ID_gcc_attribute_mode); parser_stack(yyval).set(ID_size, parser_stack(yyvsp[-1]).get(ID_identifier)); }
#line 6007 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 329: /* gcc_type_attribute: "__gnu_inline__"  */
#line 1711 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_static); }
#line 6013 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 330: /* gcc_type_attribute: "weak"  */
#line 1713 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_weak); }
#line 6019 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 331: /* gcc_type_attribute: "alias" '(' TOK_STRING ')'  */
#line 1715 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-3]; set(yyval, ID_alias); mto(yyval, yyvsp[-1]); }
#line 6025 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 332: /* gcc_type_attribute: "section" '(' TOK_STRING ')'  */
#line 1717 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-3]; set(yyval, ID_section); mto(yyval, yyvsp[-1]); }
#line 6031 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 333: /* gcc_type_attribute: "noreturn"  */
#line 1719 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_noreturn); }
#line 6037 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 334: /* gcc_type_attribute: "constructor"  */
#line 1721 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_constructor); }
#line 6043 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 335: /* gcc_type_attribute: "destructor"  */
#line 1723 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_destructor); }
#line 6049 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 336: /* gcc_type_attribute: "used"  */
#line 1725 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_used); }
#line 6055 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 337: /* gcc_attribute: %empty  */
#line 1730 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
        }
#line 6063 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 338: /* gcc_attribute: "fallthrough"  */
#line 1734 "/workspace/source/src/ansi-c/parser.y"
        {
          // attribute ignored
          init(yyval);
        }
#line 6072 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 341: /* gcc_attribute_list: gcc_attribute_list ',' gcc_attribute  */
#line 1744 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], yyvsp[0]);
        }
#line 6080 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 342: /* gcc_attribute_specifier: "__attribute__" '(' '(' gcc_attribute_list ')' ')'  */
#line 1751 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-2]; }
#line 6086 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 343: /* gcc_attribute_specifier: "_Noreturn"  */
#line 1753 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[0]; set(yyval, ID_noreturn); }
#line 6092 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 344: /* gcc_type_attribute_opt: %empty  */
#line 1758 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
        }
#line 6100 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 347: /* gcc_type_attribute_list: gcc_type_attribute_list gcc_attribute_specifier  */
#line 1767 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
        }
#line 6108 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 348: /* member_declaration_list_opt: %empty  */
#line 1774 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration_list);
        }
#line 6116 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 350: /* member_declaration_list: member_declaration  */
#line 1782 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration_list);
          mto(yyval, yyvsp[0]);
        }
#line 6125 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 351: /* member_declaration_list: member_declaration_list member_declaration  */
#line 1787 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          mto(yyval, yyvsp[0]);
        }
#line 6134 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 354: /* member_declaration: ';'  */
#line 1797 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0]; // the ';' becomes the location of the declaration
          parser_stack(yyval).id(ID_declaration);
        }
#line 6143 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 356: /* member_default_declaring_list: gcc_type_attribute_opt type_qualifier_list member_identifier_declarator  */
#line 1811 "/workspace/source/src/ansi-c/parser.y"
        {
          yyvsp[-1]=merge(yyvsp[-1], yyvsp[-2]);

          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_member(true);
          parser_stack(yyval).add_source_location()=parser_stack(yyvsp[-1]).source_location();
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6157 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 357: /* member_default_declaring_list: member_default_declaring_list ',' member_identifier_declarator  */
#line 1821 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6166 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 358: /* member_declaring_list: gcc_type_attribute_opt type_specifier member_declarator  */
#line 1831 "/workspace/source/src/ansi-c/parser.y"
        {
          if(parser_stack(yyvsp[-1]).id() != ID_struct &&
             parser_stack(yyvsp[-1]).id() != ID_union &&
             !PARSER.pragma_pack.empty() &&
             PARSER.pragma_pack.back() != 0)
          {
            // communicate #pragma pack(n) alignment constraints by
            // by both setting packing AND alignment for individual struct/union
            // members; see padding.cpp for more details
            init(yyval);
            set(yyval, ID_packed);
            yyvsp[-1]=merge(yyvsp[-1], yyval);

            init(yyval);
            set(yyval, ID_aligned);
            parser_stack(yyval).set(ID_size, PARSER.pragma_pack.back());
            yyvsp[-1]=merge(yyvsp[-1], yyval);
          }

          yyvsp[-1]=merge(yyvsp[-1], yyvsp[-2]);

          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_member(true);
          parser_stack(yyval).add_source_location()=parser_stack(yyvsp[-1]).source_location();
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6198 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 359: /* member_declaring_list: member_declaring_list ',' member_declarator  */
#line 1859 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6207 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 360: /* member_declarator: declarator bit_field_size_opt gcc_type_attribute_opt  */
#line 1867 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];

          if(parser_stack(yyvsp[-1]).is_not_nil())
            make_subtype(yyval, yyvsp[-1]);

          if(parser_stack(yyvsp[0]).is_not_nil()) // type attribute
            yyval=merge(yyvsp[0], yyval);
        }
#line 6221 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 361: /* member_declarator: %empty  */
#line 1877 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_abstract);
        }
#line 6229 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 362: /* member_declarator: bit_field_size gcc_type_attribute_opt  */
#line 1881 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          stack_type(yyval).add_subtype()=typet(ID_abstract);

          if(parser_stack(yyvsp[0]).is_not_nil()) // type attribute
            yyval=merge(yyvsp[0], yyval);
        }
#line 6241 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 363: /* member_identifier_declarator: identifier_declarator bit_field_size_opt gcc_type_attribute_opt  */
#line 1892 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          if(parser_stack(yyvsp[-1]).is_not_nil())
            make_subtype(yyval, yyvsp[-1]);
          
          if(parser_stack(yyvsp[0]).is_not_nil()) // type attribute
            yyval=merge(yyvsp[0], yyval);
        }
#line 6254 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 364: /* member_identifier_declarator: bit_field_size gcc_type_attribute_opt  */
#line 1901 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          stack_type(yyval).add_subtype()=typet(ID_abstract);

          if(parser_stack(yyvsp[0]).is_not_nil()) // type attribute
            yyval=merge(yyvsp[0], yyval);
        }
#line 6266 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 365: /* bit_field_size_opt: %empty  */
#line 1912 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_nil);
        }
#line 6274 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 367: /* bit_field_size: ':' constant_expression  */
#line 1920 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          set(yyval, ID_c_bit_field);
          stack_type(yyval).set(ID_size, parser_stack(yyvsp[0]));
          stack_type(yyval).add_subtype().id(ID_abstract);
        }
#line 6285 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 368: /* $@10: %empty  */
#line 1932 "/workspace/source/src/ansi-c/parser.y"
        {
          // an anon enum
          if(parser_stack(yyvsp[0]).is_not_nil())
          {
            parser_stack(yyvsp[-2]).set(ID_enum_underlying_type, parser_stack(yyvsp[0]));
          }
        }
#line 6297 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 369: /* enum_name: enum_key gcc_type_attribute_opt enum_underlying_type_opt $@10 '{' enumerator_list_opt '}' gcc_type_attribute_opt  */
#line 1941 "/workspace/source/src/ansi-c/parser.y"
        {
          parser_stack(yyvsp[-7]).operands().swap(parser_stack(yyvsp[-2]).operands());
          yyval=merge(yyvsp[-7], merge(yyvsp[-6], yyvsp[0])); // throw in the gcc attributes
        }
#line 6306 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 370: /* $@11: %empty  */
#line 1949 "/workspace/source/src/ansi-c/parser.y"
        {
          // an enum with tag
          parser_stack(yyvsp[-3]).set(ID_tag, parser_stack(yyvsp[-1]));

          if(parser_stack(yyvsp[0]).is_not_nil())
          {
            parser_stack(yyvsp[-3]).set(ID_enum_underlying_type, parser_stack(yyvsp[0]));
          }
        }
#line 6320 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 371: /* enum_name: enum_key gcc_type_attribute_opt identifier_or_typedef_name enum_underlying_type_opt $@11 braced_enumerator_list_opt gcc_type_attribute_opt  */
#line 1960 "/workspace/source/src/ansi-c/parser.y"
        {
          if(parser_stack(yyvsp[-1]).is_not_nil())
          {
            parser_stack(yyvsp[-6]).operands().swap(parser_stack(yyvsp[-1]).operands());
          }
          else
          {
            parser_stack(yyvsp[-6]).id(ID_c_enum_tag);
          }

          yyval=merge(yyvsp[-6], merge(yyvsp[-5], yyvsp[0])); // throw in the gcc attributes
        }
#line 6337 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 373: /* basic_type_name_list: basic_type_name_list basic_type_name  */
#line 1977 "/workspace/source/src/ansi-c/parser.y"
  {
    yyval = merge(yyvsp[-1], yyvsp[0]);
  }
#line 6345 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 376: /* enum_underlying_type_opt: %empty  */
#line 1987 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyval).make_nil();
        }
#line 6354 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 377: /* enum_underlying_type_opt: ':' enum_underlying_type  */
#line 1992 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
        }
#line 6362 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 378: /* braced_enumerator_list_opt: %empty  */
#line 1998 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyval).make_nil();
        }
#line 6371 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 379: /* braced_enumerator_list_opt: '{' enumerator_list_opt '}'  */
#line 2003 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
        }
#line 6379 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 380: /* enum_key: "enum"  */
#line 2008 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          set(yyval, ID_c_enum);
        }
#line 6388 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 381: /* enumerator_list_opt: %empty  */
#line 2016 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration_list);
        }
#line 6396 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 383: /* enumerator_list: enumerator_declaration  */
#line 2024 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration_list);
          mto(yyval, yyvsp[0]);
        }
#line 6405 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 384: /* enumerator_list: enumerator_list ',' enumerator_declaration  */
#line 2029 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 6414 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 385: /* enumerator_list: enumerator_list ','  */
#line 2034 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
        }
#line 6422 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 386: /* enumerator_declaration: identifier_or_typedef_name gcc_type_attribute_opt enumerator_value_opt  */
#line 2041 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_enum_constant(true);
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-2]));
          to_ansi_c_declaration(parser_stack(yyval)).add_initializer(parser_stack(yyvsp[0]));
        }
#line 6433 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 387: /* enumerator_value_opt: %empty  */
#line 2051 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyval).make_nil();
        }
#line 6442 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 388: /* enumerator_value_opt: '=' constant_expression  */
#line 2056 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
        }
#line 6450 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 390: /* parameter_type_list: parameter_list ',' "..."  */
#line 2064 "/workspace/source/src/ansi-c/parser.y"
        {
          typet tmp(ID_ellipsis);
          yyval=yyvsp[-2];
          to_type_with_subtypes(stack_type(yyval)).move_to_subtypes(tmp);
        }
#line 6460 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 391: /* KnR_parameter_list: KnR_parameter  */
#line 2073 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_parameters);
          mts(yyval, yyvsp[0]);
        }
#line 6469 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 392: /* KnR_parameter_list: KnR_parameter_list ',' KnR_parameter  */
#line 2078 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mts(yyval, yyvsp[0]);
        }
#line 6478 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 393: /* KnR_parameter: identifier  */
#line 2085 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          parser_stack(yyval).type()=typet(ID_KnR);
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6488 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 394: /* parameter_list: parameter_declaration  */
#line 2094 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_parameters);
          mts(yyval, yyvsp[0]);
        }
#line 6497 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 395: /* parameter_list: parameter_list ',' parameter_declaration  */
#line 2099 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mts(yyval, yyvsp[0]);
        }
#line 6506 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 396: /* parameter_declaration: declaration_specifier  */
#line 2107 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[0]));
          exprt declarator=exprt(ID_abstract);
          PARSER.add_declarator(parser_stack(yyval), declarator);
        }
#line 6518 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 397: /* parameter_declaration: declaration_specifier parameter_abstract_declarator  */
#line 2115 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6529 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 398: /* parameter_declaration: declaration_specifier identifier_declarator gcc_type_attribute_opt  */
#line 2122 "/workspace/source/src/ansi-c/parser.y"
        {
          yyvsp[-1]=merge(yyvsp[0], yyvsp[-1]); // type attribute to go into declarator
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-2]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-1]));
        }
#line 6541 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 399: /* parameter_declaration: declaration_specifier parameter_typedef_declarator  */
#line 2130 "/workspace/source/src/ansi-c/parser.y"
        {
          // the second tree is really the declarator -- not part
          // of the type!
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6554 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 400: /* parameter_declaration: declaration_qualifier_list  */
#line 2139 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[0]));
          exprt declarator=exprt(ID_abstract);
          PARSER.add_declarator(parser_stack(yyval), declarator);
        }
#line 6566 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 401: /* parameter_declaration: declaration_qualifier_list parameter_abstract_declarator  */
#line 2147 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6577 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 402: /* parameter_declaration: declaration_qualifier_list identifier_declarator gcc_type_attribute_opt  */
#line 2154 "/workspace/source/src/ansi-c/parser.y"
        {
          yyvsp[-1]=merge(yyvsp[0], yyvsp[-1]); // type attribute to go into declarator
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-2]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-1]));
        }
#line 6589 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 403: /* parameter_declaration: type_specifier  */
#line 2162 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[0]));
          exprt declarator=exprt(ID_abstract);
          PARSER.add_declarator(parser_stack(yyval), declarator);
        }
#line 6601 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 404: /* parameter_declaration: type_specifier parameter_abstract_declarator  */
#line 2170 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6612 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 405: /* parameter_declaration: type_specifier identifier_declarator gcc_type_attribute_opt  */
#line 2177 "/workspace/source/src/ansi-c/parser.y"
        {
          yyvsp[-1]=merge(yyvsp[0], yyvsp[-1]); // type attribute to go into declarator
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-2]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-1]));
        }
#line 6624 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 406: /* parameter_declaration: type_specifier parameter_typedef_declarator  */
#line 2185 "/workspace/source/src/ansi-c/parser.y"
        {
          // the second tree is really the declarator -- not part of the type!
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6636 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 407: /* parameter_declaration: type_qualifier_list  */
#line 2193 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[0]));
          exprt declarator=exprt(ID_abstract);
          PARSER.add_declarator(parser_stack(yyval), declarator);
        }
#line 6648 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 408: /* parameter_declaration: type_qualifier_list parameter_abstract_declarator  */
#line 2201 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 6659 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 409: /* parameter_declaration: type_qualifier_list identifier_declarator gcc_type_attribute_opt  */
#line 2208 "/workspace/source/src/ansi-c/parser.y"
        {
          yyvsp[-1]=merge(yyvsp[0], yyvsp[-1]); // type attribute to go into declarator
          init(yyval, ID_declaration);
          to_ansi_c_declaration(parser_stack(yyval)).set_is_parameter(true);
          to_ansi_c_declaration(parser_stack(yyval)).type().swap(parser_stack(yyvsp[-2]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-1]));
        }
#line 6671 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 412: /* type_name: gcc_type_attribute_opt type_specifier  */
#line 2224 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[0], yyvsp[-1]);
        }
#line 6679 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 413: /* type_name: gcc_type_attribute_opt type_specifier abstract_declarator  */
#line 2228 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[-2]);
          make_subtype(yyval, yyvsp[0]);
        }
#line 6688 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 414: /* type_name: gcc_type_attribute_opt type_qualifier_list  */
#line 2233 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[0], yyvsp[-1]);
        }
#line 6696 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 415: /* type_name: gcc_type_attribute_opt type_qualifier_list abstract_declarator  */
#line 2237 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[-2]);
          make_subtype(yyval, yyvsp[0]);
        }
#line 6705 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 416: /* initializer_opt: %empty  */
#line 2245 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyval).make_nil();
        }
#line 6714 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 417: /* initializer_opt: '=' initializer  */
#line 2250 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[0]; }
#line 6720 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 419: /* initializer: '{' initializer_list_opt '}'  */
#line 2261 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          set(yyval, ID_initializer_list);
          parser_stack(yyval).operands().swap(parser_stack(yyvsp[-1]).operands());
        }
#line 6730 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 420: /* initializer: '{' initializer_list ',' '}'  */
#line 2267 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          set(yyval, ID_initializer_list);
          parser_stack(yyval).operands().swap(parser_stack(yyvsp[-2]).operands());
        }
#line 6740 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 421: /* initializer_list: designated_initializer  */
#line 2276 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          exprt tmp;
          tmp.swap(parser_stack(yyval));
          parser_stack(yyval).clear();
          parser_stack(yyval).add_to_operands(std::move(tmp));
        }
#line 6752 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 422: /* initializer_list: initializer_list ',' designated_initializer  */
#line 2284 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 6761 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 424: /* initializer_list_opt: %empty  */
#line 2293 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          set(yyval, ID_initializer_list);
          parser_stack(yyval).operands().clear();
        }
#line 6771 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 426: /* designated_initializer: designator '=' initializer  */
#line 2303 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          parser_stack(yyval).id(ID_designated_initializer);
          parser_stack(yyval).add(ID_designator).swap(parser_stack(yyvsp[-2]));
          mto(yyval, yyvsp[0]);
        }
#line 6782 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 427: /* designated_initializer: designator initializer  */
#line 2311 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_designated_initializer);
          parser_stack(yyval).add(ID_designator).swap(parser_stack(yyvsp[-1]));
          mto(yyval, yyvsp[0]);
        }
#line 6792 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 428: /* designated_initializer: member_name ':' initializer  */
#line 2317 "/workspace/source/src/ansi-c/parser.y"
        {
          // yet another GCC speciality
          yyval=yyvsp[-1];
          parser_stack(yyval).id(ID_designated_initializer);
          exprt designator;
          exprt member(ID_member);
          member.set(ID_component_name, parser_stack(yyvsp[-2]).get(ID_C_base_name));
          designator.add_to_operands(std::move(member));
          parser_stack(yyval).add(ID_designator).swap(designator);
          mto(yyval, yyvsp[0]);
        }
#line 6808 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 429: /* designator: '.' member_name  */
#line 2332 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyvsp[-1]).id(ID_member);
          parser_stack(yyvsp[-1]).set(ID_component_name, parser_stack(yyvsp[0]).get(ID_C_base_name));
          mto(yyval, yyvsp[-1]);
        }
#line 6819 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 430: /* designator: '[' comma_expression ']'  */
#line 2339 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyvsp[-2]).id(ID_index);
          mto(yyvsp[-2], yyvsp[-1]);
          mto(yyval, yyvsp[-2]);
        }
#line 6830 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 431: /* designator: '[' comma_expression "..." comma_expression ']'  */
#line 2346 "/workspace/source/src/ansi-c/parser.y"
        {
          // TODO
          init(yyval);
          parser_stack(yyvsp[-4]).id(ID_index);
          mto(yyvsp[-4], yyvsp[-3]);
          mto(yyval, yyvsp[-4]);
        }
#line 6842 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 432: /* designator: designator '[' comma_expression ']'  */
#line 2354 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          parser_stack(yyvsp[-2]).id(ID_index);
          mto(yyvsp[-2], yyvsp[-1]);
          mto(yyval, yyvsp[-2]);
        }
#line 6853 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 433: /* designator: designator '[' comma_expression "..." comma_expression ']'  */
#line 2361 "/workspace/source/src/ansi-c/parser.y"
        {
          // TODO
          yyval=yyvsp[-5];
          parser_stack(yyvsp[-4]).id(ID_index);
          mto(yyvsp[-4], yyvsp[-3]);
          mto(yyval, yyvsp[-4]);
        }
#line 6865 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 434: /* designator: designator '.' member_name  */
#line 2369 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          parser_stack(yyvsp[-1]).id(ID_member);
          parser_stack(yyvsp[-1]).set(ID_component_name, parser_stack(yyvsp[0]).get(ID_C_base_name));
          mto(yyval, yyvsp[-1]);
        }
#line 6876 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 449: /* declaration_statement: declaration  */
#line 2401 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          statement(yyval, ID_decl);
          mto(yyval, yyvsp[0]);
        }
#line 6886 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 450: /* gcc_attribute_specifier_opt: %empty  */
#line 2410 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
        }
#line 6894 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 454: /* labeled_statement: TOK_GCC_IDENTIFIER ':' gcc_attribute_specifier_opt stmt_not_decl_or_attr  */
#line 2423 "/workspace/source/src/ansi-c/parser.y"
        {
          // we ignore the GCC attribute
          yyval=yyvsp[-2];
          statement(yyval, ID_label);
          irep_idt identifier=PARSER.lookup_label(parser_stack(yyvsp[-3]).get(ID_C_base_name));
          parser_stack(yyval).set(ID_label, identifier);
          mto(yyval, yyvsp[0]);
        }
#line 6907 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 455: /* labeled_statement: msc_label_identifier ':' statement  */
#line 2432 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          statement(yyval, ID_label);
          irep_idt identifier=PARSER.lookup_label(parser_stack(yyvsp[-2]).get(ID_C_base_name));
          parser_stack(yyval).set(ID_label, identifier);
          mto(yyval, yyvsp[0]);
        }
#line 6919 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 456: /* labeled_statement: "case" constant_expression ':' statement  */
#line 2440 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          statement(yyval, ID_switch_case);
          mto(yyval, yyvsp[-2]);
          mto(yyval, yyvsp[0]);
        }
#line 6930 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 457: /* labeled_statement: "case" constant_expression "..." constant_expression ':' statement  */
#line 2447 "/workspace/source/src/ansi-c/parser.y"
        {
          // this is a GCC extension
          yyval=yyvsp[-5];
          statement(yyval, ID_gcc_switch_case_range);
          mto(yyval, yyvsp[-4]);
          mto(yyval, yyvsp[-2]);
          mto(yyval, yyvsp[0]);
        }
#line 6943 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 458: /* labeled_statement: "default" ':' statement  */
#line 2456 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          statement(yyval, ID_switch_case);
          parser_stack(yyval).operands().push_back(nil_exprt());
          mto(yyval, yyvsp[0]);
          parser_stack(yyval).set(ID_default, true);
        }
#line 6955 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 459: /* statement_attribute: gcc_attribute_specifier ';'  */
#line 2467 "/workspace/source/src/ansi-c/parser.y"
        {
          // Really should only be TOK_GCC_ATTRIBUTE_FALLTHROUGH or a label
          // attribute. Only semicolons permitted after the attribute:
          // https://gcc.gnu.org/onlinedocs/gcc/Label-Attributes.html
          // We ignore all such attributes.
          yyval=yyvsp[-1];
          statement(yyval, ID_skip);
        }
#line 6968 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 460: /* compound_statement: compound_scope '{' '}'  */
#line 2479 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          statement(yyval, ID_block);
          parser_stack(yyval).set(ID_C_end_location, parser_stack(yyvsp[0]).source_location());
          PARSER.pop_scope();
        }
#line 6979 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 461: /* compound_statement: compound_scope '{' statement_list '}'  */
#line 2486 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          statement(yyval, ID_block);
          parser_stack(yyval).set(ID_C_end_location, parser_stack(yyvsp[0]).source_location());
          parser_stack(yyval).operands().swap(parser_stack(yyvsp[-1]).operands());
          PARSER.pop_scope();
        }
#line 6991 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 462: /* compound_statement: compound_scope '{' TOK_ASM_STRING '}'  */
#line 2494 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          statement(yyval, ID_asm);
          parser_stack(yyval).set(ID_C_end_location, parser_stack(yyvsp[0]).source_location());
          mto(yyval, yyvsp[-1]);
          PARSER.pop_scope();
        }
#line 7003 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 463: /* compound_scope: %empty  */
#line 2505 "/workspace/source/src/ansi-c/parser.y"
        {
          unsigned prefix=++PARSER.current_scope().compound_counter;
          PARSER.new_scope(std::to_string(prefix)+"::");
        }
#line 7012 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 464: /* statement_list: statement  */
#line 2513 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          mto(yyval, yyvsp[0]);
        }
#line 7021 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 465: /* statement_list: statement_list statement  */
#line 2518 "/workspace/source/src/ansi-c/parser.y"
        {
          mto(yyval, yyvsp[0]);
        }
#line 7029 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 466: /* expression_statement: comma_expression_opt ';'  */
#line 2525 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];

          if(parser_stack(yyvsp[-1]).is_nil())
            statement(yyval, ID_skip);
          else
          {
            statement(yyval, ID_expression);
            mto(yyval, yyvsp[-1]);
          }
        }
#line 7045 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 467: /* selection_statement: "if" '(' comma_expression ')' statement  */
#line 2540 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-4];
          statement(yyval, ID_ifthenelse);
          parser_stack(yyval).add_to_operands(
            std::move(parser_stack(yyvsp[-2])), std::move(parser_stack(yyvsp[0])), nil_exprt());
        }
#line 7056 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 468: /* selection_statement: "if" '(' comma_expression ')' statement "else" statement  */
#line 2547 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-6];
          statement(yyval, ID_ifthenelse);
          parser_stack(yyval).add_to_operands(
            std::move(parser_stack(yyvsp[-4])), std::move(parser_stack(yyvsp[-2])), std::move(parser_stack(yyvsp[0])));
        }
#line 7067 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 469: /* selection_statement: "switch" '(' comma_expression ')' statement  */
#line 2554 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-4];
          statement(yyval, ID_switch);
          parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-2])), std::move(parser_stack(yyvsp[0])));
        }
#line 7077 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 472: /* iteration_statement: "while" '(' comma_expression_opt ')' cprover_contract_assigns_opt cprover_contract_loop_invariant_list_opt cprover_contract_decreases_opt statement  */
#line 2572 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-7];
          statement(yyval, ID_while);
          parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-5])), std::move(parser_stack(yyvsp[0])));

          if(!parser_stack(yyvsp[-3]).operands().empty())
            static_cast<exprt &>(parser_stack(yyval).add(ID_C_spec_assigns)).operands().swap(parser_stack(yyvsp[-3]).operands());

          if(!parser_stack(yyvsp[-2]).operands().empty())
            static_cast<exprt &>(parser_stack(yyval).add(ID_C_spec_loop_invariant)).operands().swap(parser_stack(yyvsp[-2]).operands());

          if(!parser_stack(yyvsp[-1]).operands().empty())
            static_cast<exprt &>(parser_stack(yyval).add(ID_C_spec_decreases)).operands().swap(parser_stack(yyvsp[-1]).operands());
        }
#line 7096 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 473: /* iteration_statement: "do" cprover_contract_assigns_opt cprover_contract_loop_invariant_list_opt cprover_contract_decreases_opt statement "while" '(' comma_expression ')' ';'  */
#line 2592 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-9];
          statement(yyval, ID_dowhile);
          parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-2])), std::move(parser_stack(yyvsp[-5])));

          if(!parser_stack(yyvsp[-8]).operands().empty())
            static_cast<exprt &>(parser_stack(yyval).add(ID_C_spec_assigns)).operands().swap(parser_stack(yyvsp[-8]).operands());

          if(!parser_stack(yyvsp[-7]).operands().empty())
            static_cast<exprt &>(parser_stack(yyval).add(ID_C_spec_loop_invariant)).operands().swap(parser_stack(yyvsp[-7]).operands());

          if(!parser_stack(yyvsp[-6]).operands().empty())
            static_cast<exprt &>(parser_stack(yyval).add(ID_C_spec_decreases)).operands().swap(parser_stack(yyvsp[-6]).operands());
        }
#line 7115 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 474: /* $@12: %empty  */
#line 2607 "/workspace/source/src/ansi-c/parser.y"
          {
            // In C99 and upwards, for(;;) has a scope
            if(PARSER.for_has_scope)
            {
              unsigned prefix=++PARSER.current_scope().compound_counter;
              PARSER.new_scope(std::to_string(prefix)+"::");
            }
          }
#line 7128 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 475: /* iteration_statement: "for" $@12 '(' declaration_or_expression_statement comma_expression_opt ';' comma_expression_opt ')' cprover_contract_assigns_opt cprover_contract_loop_invariant_list_opt cprover_contract_decreases_opt statement  */
#line 2622 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-11];
          statement(yyval, ID_for);
          parser_stack(yyval).operands().reserve(4);
          mto(yyval, yyvsp[-8]);
          mto(yyval, yyvsp[-7]);
          mto(yyval, yyvsp[-5]);
          mto(yyval, yyvsp[0]);

          if(!parser_stack(yyvsp[-3]).operands().empty())
            static_cast<exprt &>(parser_stack(yyval).add(ID_C_spec_assigns)).operands().swap(parser_stack(yyvsp[-3]).operands());

          if(!parser_stack(yyvsp[-2]).operands().empty())
            static_cast<exprt &>(parser_stack(yyval).add(ID_C_spec_loop_invariant)).operands().swap(parser_stack(yyvsp[-2]).operands());

          if(!parser_stack(yyvsp[-1]).operands().empty())
            static_cast<exprt &>(parser_stack(yyval).add(ID_C_spec_decreases)).operands().swap(parser_stack(yyvsp[-1]).operands());

          if(PARSER.for_has_scope)
            PARSER.pop_scope(); // remove the C99 for-scope
        }
#line 7154 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 476: /* jump_statement: "goto" comma_expression ';'  */
#line 2647 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          if(parser_stack(yyvsp[-1]).id()==ID_symbol)
          {
            statement(yyval, ID_goto);
            irep_idt identifier=PARSER.lookup_label(parser_stack(yyvsp[-1]).get(ID_C_base_name));
            parser_stack(yyval).set(ID_destination, identifier);
          }
          else
          {
            // this is a gcc extension.
            // the original grammar uses identifier_or_typedef_name
            statement(yyval, ID_gcc_computed_goto);
            mto(yyval, yyvsp[-1]);
          }
        }
#line 7175 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 477: /* jump_statement: "goto" typedef_name ';'  */
#line 2664 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          statement(yyval, ID_goto);
          irep_idt identifier=PARSER.lookup_label(parser_stack(yyvsp[-1]).get(ID_C_base_name));
          parser_stack(yyval).set(ID_destination, identifier);
        }
#line 7186 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 478: /* jump_statement: "continue" ';'  */
#line 2671 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1]; statement(yyval, ID_continue); }
#line 7192 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 479: /* jump_statement: "break" ';'  */
#line 2673 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1]; statement(yyval, ID_break); }
#line 7198 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 480: /* jump_statement: "return" ';'  */
#line 2675 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          statement(yyval, ID_return);
          parser_stack(yyval).operands().push_back(nil_exprt());
        }
#line 7208 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 481: /* jump_statement: "return" comma_expression ';'  */
#line 2681 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-2]; statement(yyval, ID_return); mto(yyval, yyvsp[-1]); }
#line 7214 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 482: /* gcc_local_label_statement: "__label__" gcc_local_label_list ';'  */
#line 2686 "/workspace/source/src/ansi-c/parser.y"
        { 
          yyval=yyvsp[-2];
          statement(yyval, ID_gcc_local_label);
          
          // put these into the scope
          for(const auto &op : as_const(parser_stack(yyvsp[-1])).operands())
          {
            // labels have a separate name space
            irep_idt base_name = op.get(ID_identifier);
            irep_idt id="label-"+id2string(base_name);
            ansi_c_parsert::identifiert &i=PARSER.current_scope().name_map[id];
            i.id_class=ansi_c_id_classt::ANSI_C_LOCAL_LABEL;
            i.prefixed_name=PARSER.current_scope().prefix+id2string(id);
            i.base_name=base_name;
          }

          parser_stack(yyval).add(ID_label).get_sub().swap((irept::subt&)parser_stack(yyvsp[-1]).operands());
        }
#line 7237 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 483: /* gcc_local_label_list: gcc_local_label  */
#line 2708 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          mto(yyval, yyvsp[0]);
        }
#line 7246 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 484: /* gcc_local_label_list: gcc_local_label_list ',' gcc_local_label  */
#line 2713 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 7255 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 486: /* gcc_asm_statement: "__asm__ (with parentheses)" volatile_or_goto_opt '(' gcc_asm_commands ')' ';'  */
#line 2724 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-5];
          statement(yyval, ID_asm);
          parser_stack(yyval).set(ID_flavor, ID_gcc);
          parser_stack(yyval).operands().swap(parser_stack(yyvsp[-2]).operands());
        }
#line 7265 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 487: /* gcc_asm_statement: "__asm__ (with parentheses)" volatile_or_goto_opt '{' TOK_ASM_STRING '}'  */
#line 2730 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-4];
          statement(yyval, ID_asm);
          parser_stack(yyval).set(ID_flavor, ID_gcc);
          parser_stack(yyval).operands().resize(5);
          to_multi_ary_expr(parser_stack(yyval)).op0()=parser_stack(yyvsp[-1]);
        }
#line 7277 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 488: /* msc_asm_statement: "__asm" '{' TOK_ASM_STRING '}'  */
#line 2741 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-3];
          statement(yyval, ID_asm);
          parser_stack(yyval).set(ID_flavor, ID_msc);
          mto(yyval, yyvsp[-1]);
        }
#line 7287 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 489: /* msc_asm_statement: "__asm" TOK_ASM_STRING  */
#line 2747 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1];
          statement(yyval, ID_asm);
          parser_stack(yyval).set(ID_flavor, ID_msc);
          mto(yyval, yyvsp[0]);
        }
#line 7297 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 490: /* msc_seh_statement: "__try" compound_statement "__except" '(' comma_expression ')' compound_statement  */
#line 2757 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-6];
          statement(yyval, ID_msc_try_except);
          mto(yyval, yyvsp[-5]);
          mto(yyval, yyvsp[-2]);
          mto(yyval, yyvsp[0]);
        }
#line 7309 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 491: /* msc_seh_statement: "__try" compound_statement "__finally" compound_statement  */
#line 2766 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          statement(yyval, ID_msc_try_finally);
          mto(yyval, yyvsp[-2]);
          mto(yyval, yyvsp[0]);
        }
#line 7320 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 492: /* msc_seh_statement: "__leave"  */
#line 2773 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          statement(yyval, ID_msc_leave);
        }
#line 7329 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 493: /* cprover_exception_statement: "__CPROVER_throw" ';'  */
#line 2781 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          statement(yyval, ID_CPROVER_throw);
        }
#line 7338 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 494: /* cprover_exception_statement: "__CPROVER_try" compound_statement "__CPROVER_catch" compound_statement  */
#line 2787 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          statement(yyval, ID_CPROVER_try_catch);
          mto(yyval, yyvsp[-2]);
          mto(yyval, yyvsp[0]);
        }
#line 7349 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 495: /* cprover_exception_statement: "__CPROVER_try" compound_statement "__CPROVER_finally" compound_statement  */
#line 2795 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          statement(yyval, ID_CPROVER_try_finally);
          mto(yyval, yyvsp[-2]);
          mto(yyval, yyvsp[0]);
        }
#line 7360 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 500: /* gcc_asm_commands: gcc_asm_assembler_template  */
#line 2820 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyval).operands().resize(5);
          parser_stack(yyval).operands()[0]=parser_stack(yyvsp[0]);
        }
#line 7370 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 501: /* gcc_asm_commands: gcc_asm_assembler_template gcc_asm_outputs  */
#line 2826 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyval).operands().resize(5);
          parser_stack(yyval).operands()[0]=parser_stack(yyvsp[-1]);
          parser_stack(yyval).operands()[1]=parser_stack(yyvsp[0]);
        }
#line 7381 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 502: /* gcc_asm_commands: gcc_asm_assembler_template gcc_asm_outputs gcc_asm_inputs  */
#line 2833 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyval).operands().resize(5);
          parser_stack(yyval).operands()[0]=parser_stack(yyvsp[-2]);
          parser_stack(yyval).operands()[1]=parser_stack(yyvsp[-1]);
          parser_stack(yyval).operands()[2]=parser_stack(yyvsp[0]);
        }
#line 7393 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 503: /* gcc_asm_commands: gcc_asm_assembler_template gcc_asm_outputs gcc_asm_inputs gcc_asm_clobbered_registers  */
#line 2841 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyval).operands().resize(5);
          parser_stack(yyval).operands()[0]=parser_stack(yyvsp[-3]);
          parser_stack(yyval).operands()[1]=parser_stack(yyvsp[-2]);
          parser_stack(yyval).operands()[2]=parser_stack(yyvsp[-1]);
          parser_stack(yyval).operands()[3]=parser_stack(yyvsp[0]);
        }
#line 7406 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 504: /* gcc_asm_commands: gcc_asm_assembler_template gcc_asm_outputs gcc_asm_inputs gcc_asm_clobbered_registers gcc_asm_labels  */
#line 2850 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          parser_stack(yyval).operands().resize(5);
          parser_stack(yyval).operands()[0]=parser_stack(yyvsp[-4]);
          parser_stack(yyval).operands()[1]=parser_stack(yyvsp[-3]);
          parser_stack(yyval).operands()[2]=parser_stack(yyvsp[-2]);
          parser_stack(yyval).operands()[3]=parser_stack(yyvsp[-1]);
          parser_stack(yyval).operands()[4]=parser_stack(yyvsp[0]);
        }
#line 7420 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 506: /* gcc_asm_outputs: ':' gcc_asm_output_list  */
#line 2866 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
        }
#line 7428 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 508: /* gcc_asm_output: string '(' comma_expression ')'  */
#line 2874 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          parser_stack(yyval).id(ID_gcc_asm_output);
          parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-3])), std::move(parser_stack(yyvsp[-1])));
        }
#line 7438 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 509: /* gcc_asm_output: '[' identifier_or_typedef_name ']' string '(' comma_expression ')'  */
#line 2881 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          parser_stack(yyval).id(ID_gcc_asm_output);
          parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-3])), std::move(parser_stack(yyvsp[-1])));
        }
#line 7448 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 510: /* gcc_asm_output_list: gcc_asm_output  */
#line 2890 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, irep_idt());
          mto(yyval, yyvsp[0]);
        }
#line 7457 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 511: /* gcc_asm_output_list: gcc_asm_output_list ',' gcc_asm_output  */
#line 2895 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 7466 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 512: /* gcc_asm_inputs: ':' gcc_asm_input_list  */
#line 2903 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
        }
#line 7474 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 514: /* gcc_asm_input: string '(' comma_expression ')'  */
#line 2911 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          parser_stack(yyval).id(ID_gcc_asm_input);
          parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-3])), std::move(parser_stack(yyvsp[-1])));
        }
#line 7484 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 515: /* gcc_asm_input: '[' identifier_or_typedef_name ']' string '(' comma_expression ')'  */
#line 2918 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          parser_stack(yyval).id(ID_gcc_asm_input);
          parser_stack(yyval).add_to_operands(std::move(parser_stack(yyvsp[-3])), std::move(parser_stack(yyvsp[-1])));
        }
#line 7494 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 516: /* gcc_asm_input_list: gcc_asm_input  */
#line 2927 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, irep_idt());
          mto(yyval, yyvsp[0]);
        }
#line 7503 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 517: /* gcc_asm_input_list: gcc_asm_input_list ',' gcc_asm_input  */
#line 2932 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 7512 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 518: /* gcc_asm_clobbered_registers: ':' gcc_asm_clobbered_registers_list  */
#line 2940 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
        }
#line 7520 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 520: /* gcc_asm_clobbered_register: string  */
#line 2948 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_gcc_asm_clobbered_register);
          mto(yyval, yyvsp[0]);
        }
#line 7529 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 521: /* gcc_asm_clobbered_registers_list: gcc_asm_clobbered_register  */
#line 2956 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, irep_idt());
          mto(yyval, yyvsp[0]);
        }
#line 7538 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 522: /* gcc_asm_clobbered_registers_list: gcc_asm_clobbered_registers_list ',' gcc_asm_clobbered_register  */
#line 2961 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 7547 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 523: /* gcc_asm_labels: ':' gcc_asm_labels_list  */
#line 2969 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
        }
#line 7555 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 525: /* gcc_asm_labels_list: gcc_asm_label  */
#line 2977 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
          mto(yyval, yyvsp[0]);
        }
#line 7564 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 526: /* gcc_asm_labels_list: gcc_asm_labels_list ',' gcc_asm_label  */
#line 2982 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 7573 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 527: /* gcc_asm_label: gcc_local_label  */
#line 2990 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          irep_idt identifier=PARSER.lookup_label(parser_stack(yyval).get(ID_C_base_name));
          parser_stack(yyval).id(ID_label);
          parser_stack(yyval).set(ID_identifier, identifier);
        }
#line 7584 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 532: /* external_definition: function_definition  */
#line 3009 "/workspace/source/src/ansi-c/parser.y"
        {
          // put into global list of items
          PARSER.copy_item(to_ansi_c_declaration(parser_stack(yyvsp[0])));
        }
#line 7593 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 533: /* external_definition: declaration  */
#line 3014 "/workspace/source/src/ansi-c/parser.y"
        {
          PARSER.copy_item(to_ansi_c_declaration(parser_stack(yyvsp[0])));
        }
#line 7601 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 536: /* asm_definition: "__asm__ (with parentheses)" '(' string ')' ';'  */
#line 3023 "/workspace/source/src/ansi-c/parser.y"
        {
          // Not obvious what to do with this.
        }
#line 7609 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 537: /* asm_definition: '{' TOK_ASM_STRING '}'  */
#line 3027 "/workspace/source/src/ansi-c/parser.y"
        {
          // Not obvious what to do with this.
        }
#line 7617 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 538: /* function_definition: function_head function_body  */
#line 3035 "/workspace/source/src/ansi-c/parser.y"
        {
          // The head is a declaration with one declarator,
          // and the body becomes the 'value'.
          yyval=yyvsp[-1];
          ansi_c_declarationt &ansi_c_declaration=
            to_ansi_c_declaration(parser_stack(yyval));
            
          INVARIANT(
            ansi_c_declaration.declarators().size()==1,
            "exactly one declarator");
          ansi_c_declaration.add_initializer(parser_stack(yyvsp[0]));
          
          // Kill the scope that 'function_head' creates.
          PARSER.pop_scope();
          
          // We are no longer in any function.
          PARSER.clear_function();
        }
#line 7640 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 540: /* KnR_parameter_header_opt: %empty  */
#line 3061 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval);
        }
#line 7648 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 542: /* KnR_parameter_header: KnR_parameter_declaration  */
#line 3069 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_decl_block);
          mto(yyval, yyvsp[0]);
        }
#line 7657 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 543: /* KnR_parameter_header: KnR_parameter_header KnR_parameter_declaration  */
#line 3074 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          mto(yyval, yyvsp[0]);
        }
#line 7666 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 546: /* KnR_declaration_qualifier_list: type_qualifier storage_class  */
#line 3088 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[0], yyvsp[-1]);
        }
#line 7674 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 547: /* KnR_declaration_qualifier_list: KnR_declaration_qualifier_list declaration_qualifier  */
#line 3092 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[0], yyvsp[-1]);
        }
#line 7682 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 548: /* KnR_basic_declaration_specifier: KnR_declaration_qualifier_list basic_type_name gcc_type_attribute_opt  */
#line 3099 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 7690 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 549: /* KnR_basic_declaration_specifier: basic_type_specifier storage_class gcc_type_attribute_opt  */
#line 3103 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 7698 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 550: /* KnR_basic_declaration_specifier: KnR_basic_declaration_specifier declaration_qualifier gcc_type_attribute_opt  */
#line 3107 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 7706 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 551: /* KnR_basic_declaration_specifier: KnR_basic_declaration_specifier basic_type_name gcc_type_attribute_opt  */
#line 3111 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 7714 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 552: /* KnR_typedef_declaration_specifier: typedef_type_specifier storage_class gcc_type_attribute_opt  */
#line 3119 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 7722 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 553: /* KnR_typedef_declaration_specifier: KnR_declaration_qualifier_list typedef_name gcc_type_attribute_opt  */
#line 3123 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 7730 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 554: /* KnR_typedef_declaration_specifier: KnR_typedef_declaration_specifier declaration_qualifier gcc_type_attribute_opt  */
#line 3127 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-2], merge(yyvsp[-1], yyvsp[0]));
        }
#line 7738 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 555: /* KnR_sue_declaration_specifier: KnR_declaration_qualifier_list aggregate_key identifier_or_typedef_name gcc_type_attribute_opt  */
#line 3135 "/workspace/source/src/ansi-c/parser.y"
        {
          parser_stack(yyvsp[-2]).set(ID_tag, parser_stack(yyvsp[-1]));
          yyval=merge(yyvsp[-3], merge(yyvsp[-2], yyvsp[0]));
        }
#line 7747 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 556: /* KnR_sue_declaration_specifier: KnR_declaration_qualifier_list enum_key identifier_or_typedef_name gcc_type_attribute_opt  */
#line 3140 "/workspace/source/src/ansi-c/parser.y"
        {
          parser_stack(yyvsp[-2]).id(ID_c_enum_tag);
          parser_stack(yyvsp[-2]).set(ID_tag, parser_stack(yyvsp[-1]));
          yyval=merge(yyvsp[-3], merge(yyvsp[-2], yyvsp[0]));
        }
#line 7757 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 560: /* KnR_parameter_declaring_list: KnR_declaration_specifier declarator  */
#line 3156 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 7767 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 561: /* KnR_parameter_declaring_list: type_specifier declarator  */
#line 3162 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 7777 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 562: /* KnR_parameter_declaring_list: KnR_parameter_declaring_list ',' declarator  */
#line 3168 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
        }
#line 7786 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 563: /* function_head: identifier_declarator  */
#line 3176 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          irept return_type(ID_int);
          parser_stack(yyval).type().swap(return_type);
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
          create_function_scope(yyval);
        }
#line 7798 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 564: /* function_head: declaration_specifier declarator post_declarator_attributes_opt  */
#line 3184 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-2]));
          yyvsp[-1]=merge(yyvsp[0], yyvsp[-1]);
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-1]));
          create_function_scope(yyval);
        }
#line 7810 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 565: /* function_head: type_specifier declarator post_declarator_attributes_opt  */
#line 3192 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-2]));
          yyvsp[-1]=merge(yyvsp[0], yyvsp[-1]);
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[-1]));
          create_function_scope(yyval);
        }
#line 7822 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 566: /* function_head: declaration_qualifier_list identifier_declarator  */
#line 3200 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
          create_function_scope(yyval);
        }
#line 7833 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 567: /* function_head: type_qualifier_list identifier_declarator  */
#line 3207 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_declaration);
          parser_stack(yyval).type().swap(parser_stack(yyvsp[-1]));
          PARSER.add_declarator(parser_stack(yyval), parser_stack(yyvsp[0]));
          create_function_scope(yyval);
        }
#line 7844 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 571: /* paren_attribute_declarator: '(' gcc_type_attribute_list identifier_declarator ')'  */
#line 3223 "/workspace/source/src/ansi-c/parser.y"
        {
          stack_type(yyvsp[-3])=typet(ID_abstract);
          yyvsp[-2]=merge(yyvsp[-2], yyvsp[-3]); // dest=$2
          make_subtype(yyvsp[-1], yyvsp[-2]); // dest=$3
          yyval=yyvsp[-1];
        }
#line 7855 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 572: /* paren_attribute_declarator: '(' gcc_type_attribute_list identifier_declarator ')' postfixing_abstract_declarator  */
#line 3230 "/workspace/source/src/ansi-c/parser.y"
        {
          stack_type(yyvsp[-4])=typet(ID_abstract);
          yyvsp[-3]=merge(yyvsp[-3], yyvsp[-4]); // dest=$2
          make_subtype(yyvsp[-2], yyvsp[-3]); // dest=$3
          /* note: this is (a pointer to) a function ($5) */
          /* or an array ($5) with name ($3) */
          yyval=yyvsp[-2];
          make_subtype(yyval, yyvsp[0]);
        }
#line 7869 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 573: /* paren_attribute_declarator: '*' paren_attribute_declarator  */
#line 3240 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          do_pointer(yyvsp[-1], yyvsp[0]);
        }
#line 7878 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 577: /* parameter_typedef_declarator: typedef_name postfixing_abstract_declarator  */
#line 3254 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          make_subtype(yyval, yyvsp[0]);
        }
#line 7887 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 580: /* clean_typedef_declarator: '*' parameter_typedef_declarator  */
#line 3264 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          do_pointer(yyvsp[-1], yyvsp[0]);
        }
#line 7896 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 581: /* clean_typedef_declarator: '*' attribute_type_qualifier_list parameter_typedef_declarator  */
#line 3269 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
          do_pointer(yyvsp[-2], yyvsp[-1]);
        }
#line 7905 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 582: /* clean_postfix_typedef_declarator: '(' clean_typedef_declarator ')'  */
#line 3277 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-1]; }
#line 7911 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 583: /* clean_postfix_typedef_declarator: '(' clean_typedef_declarator ')' postfixing_abstract_declarator  */
#line 3279 "/workspace/source/src/ansi-c/parser.y"
        {
          /* note: this is a pointer ($2) to a function ($4) */
          /* or an array ($4)! */
          yyval=yyvsp[-2];
          make_subtype(yyval, yyvsp[0]);
        }
#line 7922 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 585: /* paren_typedef_declarator: '*' '(' simple_paren_typedef_declarator ')'  */
#line 3290 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          do_pointer(yyvsp[-3], yyvsp[-1]);
        }
#line 7931 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 586: /* paren_typedef_declarator: '*' attribute_type_qualifier_list '(' simple_paren_typedef_declarator ')'  */
#line 3295 "/workspace/source/src/ansi-c/parser.y"
        {
          // not sure where the type qualifiers belong
          yyval=merge(yyvsp[-3], yyvsp[-1]);
          do_pointer(yyvsp[-4], yyvsp[-3]);
        }
#line 7941 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 587: /* paren_typedef_declarator: '*' paren_typedef_declarator  */
#line 3301 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          do_pointer(yyvsp[-1], yyvsp[0]);
        }
#line 7950 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 588: /* paren_typedef_declarator: '*' attribute_type_qualifier_list paren_typedef_declarator  */
#line 3306 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=merge(yyvsp[-1], yyvsp[0]);
          do_pointer(yyvsp[-2], yyvsp[-1]);
        }
#line 7959 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 589: /* paren_postfix_typedef_declarator: '(' paren_typedef_declarator ')'  */
#line 3314 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-1]; }
#line 7965 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 590: /* paren_postfix_typedef_declarator: '(' simple_paren_typedef_declarator postfixing_abstract_declarator ')'  */
#line 3316 "/workspace/source/src/ansi-c/parser.y"
        {        /* note: this is a function ($3) with a typedef name ($2) */
          yyval=yyvsp[-2];
          make_subtype(yyval, yyvsp[-1]);
        }
#line 7974 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 591: /* paren_postfix_typedef_declarator: '(' paren_typedef_declarator ')' postfixing_abstract_declarator  */
#line 3321 "/workspace/source/src/ansi-c/parser.y"
        {
          /* note: this is a pointer ($2) to a function ($4) */
          /* or an array ($4)! */
          yyval=yyvsp[-2];
          make_subtype(yyval, yyvsp[0]);
        }
#line 7985 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 593: /* simple_paren_typedef_declarator: '(' simple_paren_typedef_declarator ')'  */
#line 3332 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1]; }
#line 7991 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 597: /* unary_identifier_declarator: '*' identifier_declarator  */
#line 3343 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          do_pointer(yyvsp[-1], yyvsp[0]);
        }
#line 8000 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 598: /* unary_identifier_declarator: '^' identifier_declarator  */
#line 3348 "/workspace/source/src/ansi-c/parser.y"
        {
          // This is an Apple extension to C/C++/Objective C.
          // http://en.wikipedia.org/wiki/Blocks_(C_language_extension)
          yyval=yyvsp[0];
          do_pointer(yyvsp[-1], yyvsp[0]);
        }
#line 8011 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 599: /* unary_identifier_declarator: '*' attribute_type_qualifier_list identifier_declarator  */
#line 3355 "/workspace/source/src/ansi-c/parser.y"
        {
          // the type_qualifier_list is for the pointer,
          // and not the identifier_declarator
          // The below is deliberately not using pointer_type();
          // the width is added during conversion.
          stack_type(yyvsp[-2]).id(ID_frontend_pointer);
          stack_type(yyvsp[-2]).add_subtype()=typet(ID_abstract);
          yyvsp[-1]=merge(yyvsp[-1], yyvsp[-2]); // dest=$2
          make_subtype(yyvsp[0], yyvsp[-1]); // dest=$3
          yyval=yyvsp[0];
        }
#line 8027 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 600: /* postfix_identifier_declarator: paren_identifier_declarator postfixing_abstract_declarator  */
#line 3370 "/workspace/source/src/ansi-c/parser.y"
        {
          /* note: this is a function or array ($2) with name ($1) */
          yyval=yyvsp[-1];
          make_subtype(yyval, yyvsp[0]);
        }
#line 8037 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 601: /* postfix_identifier_declarator: '(' unary_identifier_declarator ')'  */
#line 3376 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-1]; }
#line 8043 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 602: /* postfix_identifier_declarator: '(' unary_identifier_declarator ')' postfixing_abstract_declarator  */
#line 3378 "/workspace/source/src/ansi-c/parser.y"
        {
          /* note: this is a pointer ($2) to a function ($4) */
          /* or an array ($4)! */
          yyval=yyvsp[-2];
          make_subtype(yyval, yyvsp[0]);
        }
#line 8054 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 603: /* paren_identifier_declarator: identifier  */
#line 3388 "/workspace/source/src/ansi-c/parser.y"
        {
          // We remember the last declarator for the benefit
          // of function argument scoping.
          PARSER.current_scope().last_declarator=
            parser_stack(yyvsp[0]).get(ID_identifier);
        }
#line 8065 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 604: /* paren_identifier_declarator: '(' paren_identifier_declarator ')'  */
#line 3395 "/workspace/source/src/ansi-c/parser.y"
        { yyval=yyvsp[-1]; }
#line 8071 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 610: /* $@13: %empty  */
#line 3411 "/workspace/source/src/ansi-c/parser.y"
        {
          PARSER.new_scope("ensures::");
        }
#line 8079 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 611: /* cprover_function_contract: "__CPROVER_ensures" $@13 '(' ACSL_binding_expression ')'  */
#line 3415 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-4];
          set(yyval, ID_C_spec_ensures);
          mto(yyval, yyvsp[-1]);
          PARSER.pop_scope();
        }
#line 8090 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 612: /* $@14: %empty  */
#line 3422 "/workspace/source/src/ansi-c/parser.y"
        {
          PARSER.new_scope("requires::");
        }
#line 8098 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 613: /* cprover_function_contract: "__CPROVER_requires" $@14 '(' ACSL_binding_expression ')'  */
#line 3426 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-4];
          set(yyval, ID_C_spec_requires);
          mto(yyval, yyvsp[-1]);
          PARSER.pop_scope();
        }
#line 8109 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 616: /* unary_expression_list: unary_expression  */
#line 3438 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_expression_list);
          parser_stack(yyval).add_source_location()=parser_stack(yyvsp[0]).source_location();
          mto(yyval, yyvsp[0]);
        }
#line 8119 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 617: /* unary_expression_list: unary_expression_list ',' unary_expression  */
#line 3444 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 8128 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 618: /* conditional_target_group: unary_expression_list  */
#line 3452 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_conditional_target_group);
          parser_stack(yyval).add_source_location()=parser_stack(yyvsp[0]).source_location();
          parser_stack(yyval).add_to_operands(true_exprt{});
          mto(yyval, yyvsp[0]);
        }
#line 8139 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 619: /* conditional_target_group: logical_equivalence_expression ':' unary_expression_list  */
#line 3459 "/workspace/source/src/ansi-c/parser.y"
        { 
          yyval=yyvsp[-1];
          set(yyval, ID_conditional_target_group);
          mto(yyval, yyvsp[-2]);
          mto(yyval, yyvsp[0]);
        }
#line 8150 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 620: /* conditional_target_list: conditional_target_group  */
#line 3469 "/workspace/source/src/ansi-c/parser.y"
        {
          init(yyval, ID_target_list);
          mto(yyval, yyvsp[0]);
        }
#line 8159 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 621: /* conditional_target_list: conditional_target_list ';' conditional_target_group  */
#line 3474 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          mto(yyval, yyvsp[0]);
        }
#line 8168 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 622: /* conditional_target_list_opt_semicol: conditional_target_list ';'  */
#line 3482 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval = yyvsp[-1];
        }
#line 8176 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 623: /* conditional_target_list_opt_semicol: conditional_target_list  */
#line 3486 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval = yyvsp[0];          
        }
#line 8184 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 624: /* cprover_contract_assigns: "__CPROVER_assigns" '(' conditional_target_list_opt_semicol ')'  */
#line 3492 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          set(yyval, ID_C_spec_assigns);
          mto(yyval, yyvsp[-1]);
        }
#line 8194 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 625: /* cprover_contract_assigns: "__CPROVER_assigns" '(' ')'  */
#line 3498 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          set(yyval, ID_C_spec_assigns);
          parser_stack(yyval).add_to_operands(exprt(ID_target_list));
        }
#line 8204 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 626: /* cprover_contract_assigns_opt: %empty  */
#line 3507 "/workspace/source/src/ansi-c/parser.y"
        { init(yyval); parser_stack(yyval).make_nil(); }
#line 8210 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 628: /* cprover_contract_frees: "__CPROVER_frees" '(' conditional_target_list_opt_semicol ')'  */
#line 3513 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-3];
          set(yyval, ID_C_spec_frees);
          mto(yyval, yyvsp[-1]);
        }
#line 8220 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 629: /* cprover_contract_frees: "__CPROVER_frees" '(' ')'  */
#line 3519 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          set(yyval, ID_C_spec_frees);
          parser_stack(yyval).add_to_operands(exprt(ID_target_list));
        }
#line 8230 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 631: /* cprover_function_contract_sequence: cprover_function_contract_sequence cprover_function_contract  */
#line 3529 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          merge(yyval, yyvsp[0]);
        }
#line 8239 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 632: /* cprover_function_contract_sequence_opt: %empty  */
#line 3537 "/workspace/source/src/ansi-c/parser.y"
          { init(yyval); }
#line 8245 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 633: /* cprover_function_contract_sequence_opt: cprover_function_contract_sequence  */
#line 3539 "/workspace/source/src/ansi-c/parser.y"
        {
          // Function contracts should either be attached to a
          // top-level function declaration or top-level function
          // definition.  Any embedded function pointer scopes should
          // be disallowed.
          int contract_in_global_scope = (PARSER.scopes.size() == 1);
          int contract_in_top_level_function_scope = (PARSER.scopes.size() == 2);
          if(!contract_in_global_scope && !contract_in_top_level_function_scope)
          {
            yyansi_cerror("Function contracts allowed only at top-level declarations.");
            YYABORT;
          }
        }
#line 8263 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 635: /* postfixing_abstract_declarator: '(' ')' KnR_parameter_header  */
#line 3560 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          set(yyval, ID_code);
          stack_type(yyval).add_subtype()=typet(ID_abstract);
          stack_type(yyval).add(ID_parameters);
          stack_type(yyval).set(ID_C_KnR, true);
        }
#line 8275 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 636: /* $@15: %empty  */
#line 3568 "/workspace/source/src/ansi-c/parser.y"
          {
            // Use last declarator (i.e., function name) to name
            // the scope.
            PARSER.new_scope(
              id2string(PARSER.current_scope().last_declarator)+"::");
          }
#line 8286 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 637: /* postfixing_abstract_declarator: '(' $@15 KnR_parameter_list ')' KnR_parameter_header_opt  */
#line 3577 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-4];
          set(yyval, ID_code);
          stack_type(yyval).add_subtype()=typet(ID_abstract);
          stack_type(yyval).add(ID_parameters).get_sub().
            swap((irept::subt &)(to_type_with_subtypes(stack_type(yyvsp[-2])).subtypes()));
          PARSER.pop_scope();
          adjust_KnR_parameters(parser_stack(yyval).add(ID_parameters), parser_stack(yyvsp[0]));
          parser_stack(yyval).set(ID_C_KnR, true);
        }
#line 8301 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 639: /* $@16: %empty  */
#line 3592 "/workspace/source/src/ansi-c/parser.y"
          {
            // Set function name (last declarator) in source location
            // before parsing function contracts.  Only do this if we
            // are at a global scope.
            if (PARSER.current_scope().prefix.empty()) {
              PARSER.set_function(PARSER.current_scope().last_declarator);
            }
            // Use last declarator (i.e., function name) to name
            // the scope.
            PARSER.new_scope(
              id2string(PARSER.current_scope().last_declarator)+"::");
          }
#line 8318 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 640: /* parameter_postfixing_abstract_declarator: '(' ')' $@16 cprover_function_contract_sequence_opt  */
#line 3605 "/workspace/source/src/ansi-c/parser.y"
        {
          set(yyvsp[-3], ID_code);
          stack_type(yyvsp[-3]).add(ID_parameters);
          stack_type(yyvsp[-3]).add_subtype()=typet(ID_abstract);
          PARSER.pop_scope();

          // Clear function name in source location after parsing if
          // at global scope.
          if (PARSER.current_scope().prefix.empty()) {
            PARSER.clear_function();
          }

          yyval = merge(yyvsp[0], yyvsp[-3]);
        }
#line 8337 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 641: /* $@17: %empty  */
#line 3620 "/workspace/source/src/ansi-c/parser.y"
          {
            // Set function name (last declarator) in source location
            // before parsing function contracts.  Only do this if we
            // are at a global scope.
            if (PARSER.current_scope().prefix.empty()) {
              PARSER.set_function(PARSER.current_scope().last_declarator);
            }
            // Use last declarator (i.e., function name) to name
            // the scope.
            PARSER.new_scope(
              id2string(PARSER.current_scope().last_declarator)+"::");
          }
#line 8354 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 642: /* parameter_postfixing_abstract_declarator: '(' $@17 parameter_type_list ')' KnR_parameter_header_opt cprover_function_contract_sequence_opt  */
#line 3636 "/workspace/source/src/ansi-c/parser.y"
        {
          set(yyvsp[-5], ID_code);
          stack_type(yyvsp[-5]).add_subtype()=typet(ID_abstract);
          stack_type(yyvsp[-5]).add(ID_parameters).get_sub().
            swap((irept::subt &)(to_type_with_subtypes(stack_type(yyvsp[-3])).subtypes()));
          PARSER.pop_scope();

          // Clear function name in source location after parsing if
          // at global scope.
          if (PARSER.current_scope().prefix.empty()) {
            PARSER.clear_function();
          }

          if(parser_stack(yyvsp[-1]).is_not_nil())
          {
            adjust_KnR_parameters(parser_stack(yyval).add(ID_parameters), parser_stack(yyvsp[-1]));
            parser_stack(yyval).set(ID_C_KnR, true);
          }

          yyval = merge(yyvsp[0], yyvsp[-5]);
        }
#line 8380 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 643: /* array_abstract_declarator: '[' ']'  */
#line 3661 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-1];
          set(yyval, ID_array);
          stack_type(yyval).add_subtype()=typet(ID_abstract);
          stack_type(yyval).add(ID_size).make_nil();
        }
#line 8391 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 644: /* array_abstract_declarator: '[' attribute_type_qualifier_storage_class_list ']'  */
#line 3668 "/workspace/source/src/ansi-c/parser.y"
        {
          // this is C99: e.g., restrict, const, etc
          // The type qualifier belongs to the array, not the
          // contents of the array, nor the size.
          set(yyvsp[-2], ID_array);
          stack_type(yyvsp[-2]).add_subtype()=typet(ID_abstract);
          stack_type(yyvsp[-2]).add(ID_size).make_nil();
          yyval=merge(yyvsp[-1], yyvsp[-2]);
        }
#line 8405 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 645: /* array_abstract_declarator: '[' '*' ']'  */
#line 3678 "/workspace/source/src/ansi-c/parser.y"
        {
          // these should be allowed in prototypes only
          yyval=yyvsp[-2];
          set(yyval, ID_array);
          stack_type(yyval).add_subtype()=typet(ID_abstract);
          stack_type(yyval).add(ID_size).make_nil();
        }
#line 8417 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 646: /* array_abstract_declarator: '[' constant_expression ']'  */
#line 3686 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[-2];
          set(yyval, ID_array);
          stack_type(yyval).add(ID_size).swap(parser_stack(yyvsp[-1]));
          stack_type(yyval).add_subtype()=typet(ID_abstract);
        }
#line 8428 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 647: /* array_abstract_declarator: '[' attribute_type_qualifier_storage_class_list constant_expression ']'  */
#line 3693 "/workspace/source/src/ansi-c/parser.y"
        {
          // The type qualifier belongs to the array, not the
          // contents of the array, nor the size.
          set(yyvsp[-3], ID_array);
          stack_type(yyvsp[-3]).add(ID_size).swap(parser_stack(yyvsp[-1]));
          stack_type(yyvsp[-3]).add_subtype()=typet(ID_abstract);
          yyval=merge(yyvsp[-2], yyvsp[-3]); // dest=$2
        }
#line 8441 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 648: /* array_abstract_declarator: array_abstract_declarator '[' constant_expression ']'  */
#line 3702 "/workspace/source/src/ansi-c/parser.y"
        {
          // we need to push this down
          yyval=yyvsp[-3];
          set(yyvsp[-2], ID_array);
          stack_type(yyvsp[-2]).add(ID_size).swap(parser_stack(yyvsp[-1]));
          stack_type(yyvsp[-2]).add_subtype()=typet(ID_abstract);
          make_subtype(yyvsp[-3], yyvsp[-2]);
        }
#line 8454 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 649: /* array_abstract_declarator: array_abstract_declarator '[' '*' ']'  */
#line 3711 "/workspace/source/src/ansi-c/parser.y"
        {
          // these should be allowed in prototypes only
          // we need to push this down
          yyval=yyvsp[-3];
          set(yyvsp[-2], ID_array);
          stack_type(yyvsp[-2]).add(ID_size).make_nil();
          stack_type(yyvsp[-2]).add_subtype()=typet(ID_abstract);
          make_subtype(yyvsp[-3], yyvsp[-2]);
        }
#line 8468 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 650: /* unary_abstract_declarator: '*'  */
#line 3724 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          // The below is deliberately not using pointer_type();
          // the width is added during conversion.
          stack_type(yyval).id(ID_frontend_pointer);
          stack_type(yyval).add_subtype()=typet(ID_abstract);
        }
#line 8480 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 651: /* unary_abstract_declarator: '*' attribute_type_qualifier_list  */
#line 3732 "/workspace/source/src/ansi-c/parser.y"
        {
          // The type_qualifier_list belongs to the pointer,
          // not to the (missing) abstract declarator.
          // The below is deliberately not using pointer_type();
          // the width is added during conversion.
          stack_type(yyvsp[-1]).id(ID_frontend_pointer);
          stack_type(yyvsp[-1]).add_subtype()=typet(ID_abstract);
          yyval=merge(yyvsp[0], yyvsp[-1]);
        }
#line 8494 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 652: /* unary_abstract_declarator: '*' abstract_declarator  */
#line 3742 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          do_pointer(yyvsp[-1], yyvsp[0]);
        }
#line 8503 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 653: /* unary_abstract_declarator: '*' attribute_type_qualifier_list abstract_declarator  */
#line 3747 "/workspace/source/src/ansi-c/parser.y"
        {
          // The type_qualifier_list belongs to the pointer,
          // not to the abstract declarator.
          // The below is deliberately not using pointer_type();
          // the width is added during conversion.
          stack_type(yyvsp[-2]).id(ID_frontend_pointer);
          stack_type(yyvsp[-2]).add_subtype()=typet(ID_abstract);
          yyvsp[-1]=merge(yyvsp[-1], yyvsp[-2]); // dest=$2
          make_subtype(yyvsp[0], yyvsp[-1]); // dest=$3
          yyval=yyvsp[0];
        }
#line 8519 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 654: /* unary_abstract_declarator: '^'  */
#line 3759 "/workspace/source/src/ansi-c/parser.y"
        {
          // This is an Apple extension to C/C++/Objective C.
          // http://en.wikipedia.org/wiki/Blocks_(C_language_extension)
          yyval=yyvsp[0];
          set(yyval, ID_block_pointer);
          stack_type(yyval).add_subtype()=typet(ID_abstract);
        }
#line 8531 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 655: /* parameter_unary_abstract_declarator: '*'  */
#line 3770 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          // The below is deliberately not using pointer_type();
          // the width is added during conversion.
          stack_type(yyval).id(ID_frontend_pointer);
          stack_type(yyval).add_subtype()=typet(ID_abstract);
        }
#line 8543 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 656: /* parameter_unary_abstract_declarator: '*' attribute_type_qualifier_list  */
#line 3778 "/workspace/source/src/ansi-c/parser.y"
        {
          // The type_qualifier_list belongs to the pointer,
          // not to the (missing) abstract declarator.
          // The below is deliberately not using pointer_type();
          // the width is added during conversion.
          stack_type(yyvsp[-1]).id(ID_frontend_pointer);
          stack_type(yyvsp[-1]).add_subtype()=typet(ID_abstract);
          yyval=merge(yyvsp[0], yyvsp[-1]);
        }
#line 8557 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 657: /* parameter_unary_abstract_declarator: '*' parameter_abstract_declarator  */
#line 3788 "/workspace/source/src/ansi-c/parser.y"
        {
          yyval=yyvsp[0];
          do_pointer(yyvsp[-1], yyvsp[0]);
        }
#line 8566 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 658: /* parameter_unary_abstract_declarator: '*' attribute_type_qualifier_list parameter_abstract_declarator  */
#line 3793 "/workspace/source/src/ansi-c/parser.y"
        {
          // The type_qualifier_list belongs to the pointer,
          // not to the (missing) abstract declarator.
          // The below is deliberately not using pointer_type();
          // the width is added during conversion.
          stack_type(yyvsp[-2]).id(ID_frontend_pointer);
          stack_type(yyvsp[-2]).add_subtype()=typet(ID_abstract);
          yyvsp[-1]=merge(yyvsp[-1], yyvsp[-2]); // dest=$2
          make_subtype(yyvsp[0], yyvsp[-1]); // dest=$3
          yyval=yyvsp[0];
        }
#line 8582 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 659: /* parameter_unary_abstract_declarator: '^'  */
#line 3805 "/workspace/source/src/ansi-c/parser.y"
        {
          // This is an Apple extension to C/C++/Objective C.
          // http://en.wikipedia.org/wiki/Blocks_(C_language_extension)
          yyval=yyvsp[0];
          set(yyval, ID_block_pointer);
          stack_type(yyval).add_subtype()=typet(ID_abstract);
        }
#line 8594 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 660: /* postfix_abstract_declarator: '(' unary_abstract_declarator ')'  */
#line 3816 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-1]; }
#line 8600 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 661: /* postfix_abstract_declarator: '(' postfix_abstract_declarator ')'  */
#line 3818 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-1]; }
#line 8606 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 662: /* postfix_abstract_declarator: '(' postfixing_abstract_declarator ')'  */
#line 3820 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-1]; }
#line 8612 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 663: /* postfix_abstract_declarator: '(' postfix_abstract_declarator ')' postfixing_abstract_declarator  */
#line 3822 "/workspace/source/src/ansi-c/parser.y"
        {
          /* note: this is a pointer ($2) to a function or array ($4) */
          yyval=yyvsp[-2];
          make_subtype(yyval, yyvsp[0]);
        }
#line 8622 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 664: /* postfix_abstract_declarator: '(' unary_abstract_declarator ')' postfixing_abstract_declarator  */
#line 3828 "/workspace/source/src/ansi-c/parser.y"
        {
          /* note: this is a pointer ($2) to a function or array ($4) */
          yyval=yyvsp[-2];
          make_subtype(yyval, yyvsp[0]);
        }
#line 8632 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 665: /* parameter_postfix_abstract_declarator: '(' parameter_unary_abstract_declarator ')'  */
#line 3837 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-1]; }
#line 8638 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 666: /* parameter_postfix_abstract_declarator: '(' parameter_postfix_abstract_declarator ')'  */
#line 3839 "/workspace/source/src/ansi-c/parser.y"
        { yyval = yyvsp[-1]; }
#line 8644 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;

  case 668: /* parameter_postfix_abstract_declarator: '(' parameter_unary_abstract_declarator ')' parameter_postfixing_abstract_declarator  */
#line 3842 "/workspace/source/src/ansi-c/parser.y"
        {
          /* note: this is a pointer ($2) to a function ($4) */
          yyval=yyvsp[-2];
          make_subtype(yyval, yyvsp[0]);
        }
#line 8654 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"
    break;


#line 8658 "/workspace/build/src/ansi-c/ansi_c_y.tab.cpp"

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
      yyerror (YY_("syntax error"));
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
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
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
  yyerror (YY_("memory exhausted"));
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
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

