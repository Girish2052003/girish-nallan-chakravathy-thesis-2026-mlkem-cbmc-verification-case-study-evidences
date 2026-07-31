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

#ifndef YY_YYANSI_C_WORKSPACE_BUILD_SRC_ANSI_C_ANSI_C_Y_TAB_HPP_INCLUDED
# define YY_YYANSI_C_WORKSPACE_BUILD_SRC_ANSI_C_ANSI_C_Y_TAB_HPP_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yyansi_cdebug;
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
    TOK_AUTO = 258,                /* "auto"  */
    TOK_BOOL = 259,                /* "bool"  */
    TOK_BITINT = 260,              /* "_BitInt"  */
    TOK_BREAK = 261,               /* "break"  */
    TOK_COMPLEX = 262,             /* "complex"  */
    TOK_CASE = 263,                /* "case"  */
    TOK_CHAR = 264,                /* "char"  */
    TOK_CONST = 265,               /* "const"  */
    TOK_CONTINUE = 266,            /* "continue"  */
    TOK_DEFAULT = 267,             /* "default"  */
    TOK_DO = 268,                  /* "do"  */
    TOK_DOUBLE = 269,              /* "double"  */
    TOK_ELSE = 270,                /* "else"  */
    TOK_ENUM = 271,                /* "enum"  */
    TOK_EXTERN = 272,              /* "extern"  */
    TOK_FLOAT = 273,               /* "float"  */
    TOK_FOR = 274,                 /* "for"  */
    TOK_GOTO = 275,                /* "goto"  */
    TOK_IF = 276,                  /* "if"  */
    TOK_INLINE = 277,              /* "inline"  */
    TOK_INT = 278,                 /* "int"  */
    TOK_LONG = 279,                /* "long"  */
    TOK_REGISTER = 280,            /* "register"  */
    TOK_RESTRICT = 281,            /* "restrict"  */
    TOK_RETURN = 282,              /* "return"  */
    TOK_SHORT = 283,               /* "short"  */
    TOK_SIGNED = 284,              /* "signed"  */
    TOK_SIZEOF = 285,              /* "sizeof"  */
    TOK_STATIC = 286,              /* "static"  */
    TOK_STRUCT = 287,              /* "struct"  */
    TOK_SWITCH = 288,              /* "switch"  */
    TOK_TYPEDEF = 289,             /* "typedef"  */
    TOK_TYPEOF_UNQUAL = 290,       /* "typeof_unqual"  */
    TOK_UNION = 291,               /* "union"  */
    TOK_UNSIGNED = 292,            /* "unsigned"  */
    TOK_VOID = 293,                /* "void"  */
    TOK_VOLATILE = 294,            /* "volatile"  */
    TOK_WCHAR_T = 295,             /* "wchar_t"  */
    TOK_WHILE = 296,               /* "while"  */
    TOK_ARROW = 297,               /* "->"  */
    TOK_INCR = 298,                /* "++"  */
    TOK_DECR = 299,                /* "--"  */
    TOK_SHIFTLEFT = 300,           /* "<<"  */
    TOK_SHIFTRIGHT = 301,          /* ">>"  */
    TOK_LE = 302,                  /* "<="  */
    TOK_GE = 303,                  /* ">="  */
    TOK_EQ = 304,                  /* "=="  */
    TOK_NE = 305,                  /* "!="  */
    TOK_ANDAND = 306,              /* "&&"  */
    TOK_OROR = 307,                /* "||"  */
    TOK_ELLIPSIS = 308,            /* "..."  */
    TOK_MULTASSIGN = 309,          /* "*="  */
    TOK_DIVASSIGN = 310,           /* "/="  */
    TOK_MODASSIGN = 311,           /* "%="  */
    TOK_PLUSASSIGN = 312,          /* "+="  */
    TOK_MINUSASSIGN = 313,         /* "-="  */
    TOK_SHLASSIGN = 314,           /* "<<="  */
    TOK_SHRASSIGN = 315,           /* ">>="  */
    TOK_ANDASSIGN = 316,           /* "&="  */
    TOK_XORASSIGN = 317,           /* "^="  */
    TOK_ORASSIGN = 318,            /* "|="  */
    TOK_GCC_IDENTIFIER = 319,      /* TOK_GCC_IDENTIFIER  */
    TOK_MSC_IDENTIFIER = 320,      /* TOK_MSC_IDENTIFIER  */
    TOK_TYPEDEFNAME = 321,         /* TOK_TYPEDEFNAME  */
    TOK_INTEGER = 322,             /* TOK_INTEGER  */
    TOK_FLOATING = 323,            /* TOK_FLOATING  */
    TOK_CHARACTER = 324,           /* TOK_CHARACTER  */
    TOK_STRING = 325,              /* TOK_STRING  */
    TOK_ASM_STRING = 326,          /* TOK_ASM_STRING  */
    TOK_INT8 = 327,                /* "__int8"  */
    TOK_INT16 = 328,               /* "__int16"  */
    TOK_INT32 = 329,               /* "__int32"  */
    TOK_INT64 = 330,               /* "__int64"  */
    TOK_PTR32 = 331,               /* "__ptr32"  */
    TOK_PTR64 = 332,               /* "__ptr64"  */
    TOK_TYPEOF = 333,              /* "typeof"  */
    TOK_GCC_AUTO_TYPE = 334,       /* "__auto_type"  */
    TOK_GCC_FLOAT16 = 335,         /* "_Float16"  */
    TOK_GCC_FLOAT32 = 336,         /* "_Float32"  */
    TOK_GCC_FLOAT32X = 337,        /* "_Float32x"  */
    TOK_GCC_FLOAT80 = 338,         /* "__float80"  */
    TOK_GCC_FLOAT64 = 339,         /* "_Float64"  */
    TOK_GCC_FLOAT64X = 340,        /* "_Float64x"  */
    TOK_GCC_FLOAT128 = 341,        /* "_Float128"  */
    TOK_GCC_FLOAT128X = 342,       /* "_Float128x"  */
    TOK_GCC_INT128 = 343,          /* "__int128"  */
    TOK_GCC_DECIMAL32 = 344,       /* "_Decimal32"  */
    TOK_GCC_DECIMAL64 = 345,       /* "_Decimal64"  */
    TOK_GCC_DECIMAL128 = 346,      /* "_Decimal128"  */
    TOK_GCC_ASM = 347,             /* "__asm__"  */
    TOK_GCC_ASM_PAREN = 348,       /* "__asm__ (with parentheses)"  */
    TOK_GCC_ATTRIBUTE = 349,       /* "__attribute__"  */
    TOK_GCC_ATTRIBUTE_ALIGNED = 350, /* "aligned"  */
    TOK_GCC_ATTRIBUTE_TRANSPARENT_UNION = 351, /* "transparent_union"  */
    TOK_GCC_ATTRIBUTE_PACKED = 352, /* "packed"  */
    TOK_GCC_ATTRIBUTE_VECTOR_SIZE = 353, /* "vector_size"  */
    TOK_GCC_ATTRIBUTE_MODE = 354,  /* "mode"  */
    TOK_GCC_ATTRIBUTE_GNU_INLINE = 355, /* "__gnu_inline__"  */
    TOK_GCC_ATTRIBUTE_WEAK = 356,  /* "weak"  */
    TOK_GCC_ATTRIBUTE_ALIAS = 357, /* "alias"  */
    TOK_GCC_ATTRIBUTE_SECTION = 358, /* "section"  */
    TOK_GCC_ATTRIBUTE_NORETURN = 359, /* "noreturn"  */
    TOK_GCC_ATTRIBUTE_CONSTRUCTOR = 360, /* "constructor"  */
    TOK_GCC_ATTRIBUTE_DESTRUCTOR = 361, /* "destructor"  */
    TOK_GCC_ATTRIBUTE_FALLTHROUGH = 362, /* "fallthrough"  */
    TOK_GCC_ATTRIBUTE_USED = 363,  /* "used"  */
    TOK_GCC_LABEL = 364,           /* "__label__"  */
    TOK_MSC_ASM = 365,             /* "__asm"  */
    TOK_MSC_BASED = 366,           /* "__based"  */
    TOK_CW_VAR_ARG_TYPEOF = 367,   /* "_var_arg_typeof"  */
    TOK_BUILTIN_VA_ARG = 368,      /* "__builtin_va_arg"  */
    TOK_GCC_BUILTIN_TYPES_COMPATIBLE_P = 369, /* "__builtin_types_compatible_p"  */
    TOK_GCC_BUILTIN_HAS_ATTRIBUTE = 370, /* "__builtin_has_attribute"  */
    TOK_CLANG_BUILTIN_CONVERTVECTOR = 371, /* "__builtin_convertvector"  */
    TOK_OFFSETOF = 372,            /* "__offsetof"  */
    TOK_ALIGNOF = 373,             /* "__alignof__"  */
    TOK_MSC_TRY = 374,             /* "__try"  */
    TOK_MSC_FINALLY = 375,         /* "__finally"  */
    TOK_MSC_EXCEPT = 376,          /* "__except"  */
    TOK_MSC_LEAVE = 377,           /* "__leave"  */
    TOK_MSC_DECLSPEC = 378,        /* "__declspec"  */
    TOK_MSC_FORCEINLINE = 379,     /* "__forceinline"  */
    TOK_INTERFACE = 380,           /* "__interface"  */
    TOK_CDECL = 381,               /* "__cdecl"  */
    TOK_STDCALL = 382,             /* "__stdcall"  */
    TOK_FASTCALL = 383,            /* "__fastcall"  */
    TOK_CLRCALL = 384,             /* "__clrcall"  */
    TOK_FORALL = 385,              /* "forall"  */
    TOK_EXISTS = 386,              /* "exists"  */
    TOK_ACSL_FORALL = 387,         /* "\\forall"  */
    TOK_ACSL_EXISTS = 388,         /* "\\exists"  */
    TOK_ACSL_LAMBDA = 389,         /* "\\lambda"  */
    TOK_ACSL_LET = 390,            /* "\\let"  */
    TOK_ARRAY_OF = 391,            /* "array_of"  */
    TOK_CPROVER_BITVECTOR = 392,   /* "__CPROVER_bitvector"  */
    TOK_CPROVER_FLOATBV = 393,     /* "__CPROVER_floatbv"  */
    TOK_CPROVER_FIXEDBV = 394,     /* "__CPROVER_fixedbv"  */
    TOK_CPROVER_ATOMIC = 395,      /* "__CPROVER_atomic"  */
    TOK_CPROVER_BOOL = 396,        /* "__CPROVER_bool"  */
    TOK_CPROVER_THROW = 397,       /* "__CPROVER_throw"  */
    TOK_CPROVER_CATCH = 398,       /* "__CPROVER_catch"  */
    TOK_CPROVER_TRY = 399,         /* "__CPROVER_try"  */
    TOK_CPROVER_FINALLY = 400,     /* "__CPROVER_finally"  */
    TOK_CPROVER_ID = 401,          /* "__CPROVER_ID"  */
    TOK_CPROVER_LOOP_INVARIANT = 402, /* "__CPROVER_loop_invariant"  */
    TOK_CPROVER_DECREASES = 403,   /* "__CPROVER_decreases"  */
    TOK_CPROVER_REQUIRES = 404,    /* "__CPROVER_requires"  */
    TOK_CPROVER_ENSURES = 405,     /* "__CPROVER_ensures"  */
    TOK_CPROVER_ASSIGNS = 406,     /* "__CPROVER_assigns"  */
    TOK_CPROVER_FREES = 407,       /* "__CPROVER_frees"  */
    TOK_IMPLIES = 408,             /* "==>"  */
    TOK_EQUIVALENT = 409,          /* "<==>"  */
    TOK_XORXOR = 410,              /* "^^"  */
    TOK_TRUE = 411,                /* "TRUE"  */
    TOK_FALSE = 412,               /* "FALSE"  */
    TOK_REAL = 413,                /* "__real__"  */
    TOK_IMAG = 414,                /* "__imag__"  */
    TOK_ALIGNAS = 415,             /* "_Alignas"  */
    TOK_ATOMIC_TYPE_QUALIFIER = 416, /* "_Atomic"  */
    TOK_ATOMIC_TYPE_SPECIFIER = 417, /* "_Atomic()"  */
    TOK_GENERIC = 418,             /* "_Generic"  */
    TOK_IMAGINARY = 419,           /* "_Imaginary"  */
    TOK_NORETURN = 420,            /* "_Noreturn"  */
    TOK_STATIC_ASSERT = 421,       /* "_Static_assert"  */
    TOK_THREAD_LOCAL = 422,        /* "_Thread_local"  */
    TOK_NULLPTR = 423,             /* "nullptr"  */
    TOK_CONSTEXPR = 424,           /* "constexpr"  */
    TOK_BIT_CAST = 425,            /* "__builtin_bit_cast"  */
    TOK_SCANNER_ERROR = 426,       /* TOK_SCANNER_ERROR  */
    TOK_SCANNER_EOF = 427,         /* TOK_SCANNER_EOF  */
    TOK_CATCH = 428,               /* "catch"  */
    TOK_CHAR16_T = 429,            /* "char16_t"  */
    TOK_CHAR32_T = 430,            /* "char32_t"  */
    TOK_CLASS = 431,               /* "class"  */
    TOK_DELETE = 432,              /* "delete"  */
    TOK_DECLTYPE = 433,            /* "decltype"  */
    TOK_EXPLICIT = 434,            /* "explicit"  */
    TOK_FRIEND = 435,              /* "friend"  */
    TOK_MUTABLE = 436,             /* "mutable"  */
    TOK_NAMESPACE = 437,           /* "namespace"  */
    TOK_NEW = 438,                 /* "new"  */
    TOK_NODISCARD = 439,           /* "nodiscard"  */
    TOK_NOEXCEPT = 440,            /* "noexcept"  */
    TOK_OPERATOR = 441,            /* "operator"  */
    TOK_PRIVATE = 442,             /* "private"  */
    TOK_PROTECTED = 443,           /* "protected"  */
    TOK_PUBLIC = 444,              /* "public"  */
    TOK_TEMPLATE = 445,            /* "template"  */
    TOK_THIS = 446,                /* "this"  */
    TOK_THROW = 447,               /* "throw"  */
    TOK_TYPEID = 448,              /* "typeid"  */
    TOK_TYPENAME = 449,            /* "typename"  */
    TOK_TRY = 450,                 /* "try"  */
    TOK_USING = 451,               /* "using"  */
    TOK_VIRTUAL = 452,             /* "virtual"  */
    TOK_SCOPE = 453,               /* "::"  */
    TOK_DOTPM = 454,               /* ".*"  */
    TOK_ARROWPM = 455,             /* "->*"  */
    TOK_UNARY_TYPE_PREDICATE = 456, /* TOK_UNARY_TYPE_PREDICATE  */
    TOK_BINARY_TYPE_PREDICATE = 457, /* TOK_BINARY_TYPE_PREDICATE  */
    TOK_MSC_UUIDOF = 458,          /* "__uuidof"  */
    TOK_MSC_IF_EXISTS = 459,       /* "__if_exists"  */
    TOK_MSC_IF_NOT_EXISTS = 460,   /* "__if_not_exists"  */
    TOK_UNDERLYING_TYPE = 461      /* "__underlying_type"  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yyansi_clval;


int yyansi_cparse (void);


#endif /* !YY_YYANSI_C_WORKSPACE_BUILD_SRC_ANSI_C_ANSI_C_Y_TAB_HPP_INCLUDED  */
