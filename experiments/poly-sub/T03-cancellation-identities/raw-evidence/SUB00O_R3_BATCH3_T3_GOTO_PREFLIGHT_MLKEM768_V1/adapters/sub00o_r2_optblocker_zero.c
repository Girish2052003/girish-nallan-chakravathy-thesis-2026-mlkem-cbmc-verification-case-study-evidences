/*
 * SUB-00L environment definition.
 *
 * The portable value barrier reads a namespaced volatile uint64_t documented
 * by verify.h as being set to zero.
 */

#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
