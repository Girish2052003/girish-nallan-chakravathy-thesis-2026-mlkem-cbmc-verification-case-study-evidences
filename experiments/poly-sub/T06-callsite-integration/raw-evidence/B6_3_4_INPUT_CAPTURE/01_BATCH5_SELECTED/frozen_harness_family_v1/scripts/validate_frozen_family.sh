#!/usr/bin/env bash
set -euo pipefail
FAMILY="$(cd "$(dirname "$0")/.." && pwd)"
EXPECTED_HARNESS_COUNT=9

cd "$FAMILY"
sha256sum -c SUB00Q_B5_2_ARTIFACT_MANIFEST.sha256

count="$(find harnesses -maxdepth 1 -type f -name '*.c' | wc -l)"
[ "$count" -eq "$EXPECTED_HARNESS_COUNT" ]

for h in harnesses/*.c; do
  calls="$(grep -c '^[[:space:]]*mlk_poly_sub(&R[12], &B[12]);' "$h" || true)"
  [ "$calls" -eq 2 ] || {
    echo "ERROR: $h has $calls production calls, expected 2"
    exit 1
  }
done

positive=(
  harnesses/sub_t5_frame_preservation_harness.c
  harnesses/sub_t5_coefficient_locality_harness.c
  harnesses/sub_t5_noninterference_exact_effect_harness.c
  harnesses/sub_t5_determinism_harness.c
)

for h in "${positive[@]}"; do
  if grep -nE '__CPROVER_assume\([^;]*(R1|R2)\.' "$h"; then
    echo "ERROR: output-shaped assumption in $h"
    exit 1
  fi
  if grep -nE '__CPROVER_assume\([^;]*(INT16_MIN|INT16_MAX)' "$h"; then
    echo "ERROR: representability assumption in $h"
    exit 1
  fi
done

[ "$(grep -RIl 'SUB_T5_EF_T5_1_EXPECTED_FAILURE' harnesses | wc -l)" -eq 1 ]
[ "$(grep -RIl 'SUB_T5_EF_T5_2_EXPECTED_FAILURE' harnesses | wc -l)" -eq 1 ]
[ "$(grep -RIl '__CPROVER_cover' harnesses | wc -l)" -eq 3 ]

echo "MANIFEST_STATUS=OK"
echo "HARNESS_COUNT=$count"
echo "TWO_CALL_STRUCTURE=OK"
echo "POSITIVE_ASSUMPTION_AUDIT=OK"
echo "EXPECTED_FAILURE_ISOLATION=OK"
echo "REACHABILITY_FILE_COUNT=3"
echo "STATIC_VALIDATION=PASS"
