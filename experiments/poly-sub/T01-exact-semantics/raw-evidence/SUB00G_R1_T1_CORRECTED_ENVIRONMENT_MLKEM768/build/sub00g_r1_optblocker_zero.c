/*
 * SUB-00G-R1 environment adapter.
 *
 * The portable value-barrier implementation in verify.h reads a namespaced
 * volatile uint64_t that the production design specifies as being set to zero.
 * Run-1 linked poly.c without a definition of that environment object, so CBMC
 * treated it as unconstrained.
 *
 * This file provides the missing zero-valued environment object. It does not
 * modify mlkem-native production source and it is not a theorem assumption
 * about polynomial inputs.
 */

#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
