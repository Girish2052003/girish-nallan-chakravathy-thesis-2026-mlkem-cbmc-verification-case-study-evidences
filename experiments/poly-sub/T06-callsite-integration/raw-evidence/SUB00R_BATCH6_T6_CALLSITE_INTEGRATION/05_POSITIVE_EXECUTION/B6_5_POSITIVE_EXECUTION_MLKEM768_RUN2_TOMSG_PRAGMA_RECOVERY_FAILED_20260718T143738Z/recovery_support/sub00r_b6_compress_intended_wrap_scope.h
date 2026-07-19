#ifndef SUB00R_B6_COMPRESS_INTENDED_WRAP_SCOPE_H
#define SUB00R_B6_COMPRESS_INTENDED_WRAP_SCOPE_H

/*
 * Verification adapter correction:
 *
 * The frozen production compress.h contains function-local CBMC pragmas
 * guarded by #ifdef CBMC. They disable unsigned-overflow only around
 * compression helpers whose modulo-2^32 or modulo-2^64 wrap is explicitly
 * intended by the production source.
 *
 * The general SUB-T6 preinclude deliberately leaves CBMC undefined after
 * loading verify.h. Therefore compress.h must be loaded once under CBMC
 * before the harness and compress.c include it through the normal guard.
 *
 * This header does not replace, copy or modify production logic.
 */

#ifdef CBMC
#error "SUB00R compress pragma adapter requires CBMC initially undefined"
#endif

#define CBMC 1
#include "compress.h"
#undef CBMC

#endif
