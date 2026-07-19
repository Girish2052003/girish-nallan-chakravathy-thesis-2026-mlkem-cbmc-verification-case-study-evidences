#!/usr/bin/env bash
set -euo pipefail

FAMILY="$(cd "$(dirname "$0")/.." && pwd)"
H="$FAMILY/harnesses"
S="$FAMILY/support"

EXPECTED_HARNESS_COUNT=5

count="$(find "$H" -maxdepth 1 -type f -name '*.c' | wc -l)"
[ "$count" -eq "$EXPECTED_HARNESS_COUNT" ]

[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_callsite_precondition_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_callsite_exactness_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_callsite_frame_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_sub_reduce_handoff_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_tomsg_precondition_harness.c")" -eq 1 ]

[ "$(grep -c 'mlk_poly_reduce(&v);' "$H/sub_t6_sub_reduce_handoff_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_reduce(&v);' "$H/sub_t6_tomsg_precondition_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_tomsg(message, &v);' "$H/sub_t6_tomsg_precondition_harness.c")" -eq 1 ]

if grep -RInE '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)' "$FAMILY"; then
    echo "ERROR: false assumption detected"
    exit 1
fi

if grep -RInE '__CPROVER_assume\([^;]*(INT16_MIN|INT16_MAX)' "$FAMILY"; then
    echo "ERROR: representability assumption detected"
    exit 1
fi

if grep -RInE 'void[[:space:]]+mlk_poly_(sub|reduce|tomsg)[[:space:]]*\(' "$H"; then
    echo "ERROR: local production-function replacement detected"
    exit 1
fi

if grep -RInF 'r->coeffs[i] = (int16_t)(r->coeffs[i] - b->coeffs[i])' "$H"; then
    echo "ERROR: copied production subtraction body detected"
    exit 1
fi

grep -q 'SUB_T6_T6_1' "$H/sub_t6_callsite_precondition_harness.c"
grep -q 'SUB_T6_T6_2' "$H/sub_t6_callsite_precondition_harness.c"
grep -q 'SUB_T6_T6_3' "$H/sub_t6_callsite_exactness_harness.c"
grep -q 'SUB_T6_T6_4' "$H/sub_t6_callsite_frame_harness.c"
grep -q 'SUB_T6_T6_5' "$H/sub_t6_sub_reduce_handoff_harness.c"
grep -q 'SUB_T6_T6_6' "$H/sub_t6_tomsg_precondition_harness.c"

test -f "$S/sub00r_b6_fail_closed_zeroize.h"
test -f "$S/sub00r_b6_verify_pragma_scope.h"
test -f "$S/sub00r_b6_optblocker_zero.c"
test -f "$S/sub00r_b6_harness_common.h"

echo "HARNESS_COUNT=$count"
echo "TARGET_CALL_STRUCTURE=PASS"
echo "POSITIVE_ASSUMPTION_AUDIT=PASS"
echo "NO_LOCAL_PRODUCTION_REPLACEMENT=PASS"
echo "NO_COPIED_PRODUCTION_BODY=PASS"
echo "PROPERTY_LABEL_COVERAGE=PASS"
echo "STATIC_VALIDATION=PASS"
