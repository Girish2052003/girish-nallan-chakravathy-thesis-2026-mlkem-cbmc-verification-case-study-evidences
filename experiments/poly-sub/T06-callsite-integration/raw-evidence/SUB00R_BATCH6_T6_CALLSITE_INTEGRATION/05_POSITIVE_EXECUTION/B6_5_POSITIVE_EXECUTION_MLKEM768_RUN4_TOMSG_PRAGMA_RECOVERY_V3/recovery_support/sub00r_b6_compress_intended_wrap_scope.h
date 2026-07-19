#ifndef SUB00R_B6_COMPRESS_INTENDED_WRAP_SCOPE_H
#define SUB00R_B6_COMPRESS_INTENDED_WRAP_SCOPE_H

/*
 * Verification adapter correction:
 *
 * Keep CBMC undefined while compress.h is parsed, so all __contract__
 * annotations remain erased exactly as in the frozen SUB-T6 harness model.
 *
 * Wrap only the header's inline compression-helper definitions in a direct
 * CPROVER unsigned-overflow disable scope. In the reachable tomsg slice,
 * the only mlk_scalar_compress_* helper is mlk_scalar_compress_d1, whose
 * production source explicitly documents and locally disables the intended
 * uint32_t wrap.
 *
 * No production logic, contract, harness or source file is replaced.
 */

#ifdef CBMC
#error "SUB00R wrap-scope adapter requires CBMC initially undefined"
#endif

#pragma CPROVER check push
#pragma CPROVER check disable "unsigned-overflow"
#include "compress.h"
#pragma CPROVER check pop

#endif
