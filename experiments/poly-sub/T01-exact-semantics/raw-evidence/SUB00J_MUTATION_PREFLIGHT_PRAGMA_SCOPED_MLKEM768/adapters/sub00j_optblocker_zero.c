/*
 * SUB-00J environment definition.
 *
 * The portable value barrier reads a namespaced volatile uint64_t documented
 * as zero. This definition preserves that production environment fact.
 */

#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
