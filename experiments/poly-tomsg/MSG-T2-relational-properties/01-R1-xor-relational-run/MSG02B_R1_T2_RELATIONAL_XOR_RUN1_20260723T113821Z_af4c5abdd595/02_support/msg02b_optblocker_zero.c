#include <stdint.h>
#include "common.h"

/*
 * Environment definition required by the portable value-barrier machinery.
 * It does not replace mlk_poly_tomsg or its scalar compression helper.
 */
volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
