/*
 * SUB-00G-R2 environment definition.
 *
 * verify.h documents the portable value barrier as XOR with a volatile
 * global set to zero. Run-1 omitted the definition and therefore left the
 * global unconstrained in the GOTO model.
 *
 * This translation unit supplies the missing zero-valued environment object.
 * It does not modify production poly.c or the frozen theorem harness.
 */

#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
