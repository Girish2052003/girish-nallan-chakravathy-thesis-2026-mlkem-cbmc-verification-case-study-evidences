/*
 * Zero-valued environment definition required by verify.h's portable value
 * barrier. This does not replace or modify production mlk_poly_sub.
 */
#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
