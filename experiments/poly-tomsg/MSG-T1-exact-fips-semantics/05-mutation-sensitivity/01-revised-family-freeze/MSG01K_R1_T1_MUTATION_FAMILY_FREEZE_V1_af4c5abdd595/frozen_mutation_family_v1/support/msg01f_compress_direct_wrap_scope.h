#ifndef MSG01F_COMPRESS_DIRECT_WRAP_SCOPE_H
#define MSG01F_COMPRESS_DIRECT_WRAP_SCOPE_H

#ifdef CBMC
#error "MSG-01F direct-wrap adapter requires CBMC initially undefined"
#endif

/*
 * Exact inherited successful adapter pattern:
 *
 * - compress.h is parsed while CBMC is undefined;
 * - __contract__ and __loop__ material remain erased;
 * - the inline compression definitions are parsed inside a direct
 *   unsigned-overflow disable scope;
 * - no production helper or production function is replaced.
 *
 * The structural audit requires mlk_scalar_compress_d1 to be the only
 * reachable scalar-compression helper.
 */
#pragma CPROVER check push
#pragma CPROVER check disable "unsigned-overflow"
#include "compress.h"
#pragma CPROVER check pop

#endif
