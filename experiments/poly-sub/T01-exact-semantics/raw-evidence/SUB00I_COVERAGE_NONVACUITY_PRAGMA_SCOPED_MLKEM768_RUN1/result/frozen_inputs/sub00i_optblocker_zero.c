/*
 * SUB-00I environment definition.
 *
 * The portable value barrier reads a namespaced volatile uint64_t documented
 * by verify.h as being set to zero. This translation unit supplies that
 * zero-valued environment object without modifying production poly.c.
 */

#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
