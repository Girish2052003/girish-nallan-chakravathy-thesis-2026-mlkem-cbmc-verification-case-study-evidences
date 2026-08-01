#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H_SHA256="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_T1_CAPTURE_SHA256="866ba00a16a8d46595c4abe04456f7f3360600ac0c34ad826a34741c035b8813"
EXPECTED_PRIOR_19_OF_20_SHA256="8e417faf0e756b2cc01c4cd165662bc06742813639fa2b07eca5137d1eb16786"
EXPECTED_PRIOR_T2B_SHA256="357e891022deb9377ca03caa695dcbacb6fb389824c771719715fd967598d2ce"
EXPECTED_ORIGINAL_A_HARNESS_SHA256="b63d2c34e4395de62e71484d6e46462c028962750afbbd2cd1f2dd12420e7144"
EXPECTED_ORIGINAL_A_GOTO_SHA256="422d8bda32008a1d99732999147f75230e7efab61e1716986ef5259ee02dd412"
EXPECTED_ORIGINAL_B_HARNESS_SHA256="219a9a8e41d0066b2068f8bef0f149aa76aabb8d48dda8f365f2bc08f65df503"
EXPECTED_ORIGINAL_B_GOTO_SHA256="148d35e8a0fa9b09a58a674b7a403917a278ed9846f04a1cc75779e6f03eb8aa"

AUTHORITATIVE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WORKTREE="$ROOT/MONT_WORKTREE_af4c5abd"

T1_CAPTURE="$ROOT/MONT01B_R1_M2_M3_20260726T151104Z/MONT01B_R1_TERMINAL_CAPTURE_20260726T151104Z.txt"
PRIOR_19_OF_20_CAPTURE="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_20260726T175148Z/MONT02A_R1_SHARDED_CAPTURE_20260726T175148Z.txt"
PRIOR_T2B_CAPTURE="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_20260726T170048Z/MONT02A_FULL_T2_CAPTURE_20260726T170048Z.txt"
T1_MAKEFILE="$WORKTREE/proofs/cbmc/mont_t1_exact_refinement/Makefile"

A_DIR="$WORKTREE/proofs/cbmc/mont_t2a_arbitrary_pair"
A_NAME="mont_t2a_arbitrary_pair_harness"
A_C="$A_DIR/$A_NAME.c"
A_MK="$A_DIR/Makefile"
A_GOTO="$A_DIR/gotos/$A_NAME.goto"

B_DIR="$WORKTREE/proofs/cbmc/mont_t2b_fibre_translation"
B_NAME="mont_t2b_fibre_translation_harness"
B_C="$B_DIR/$B_NAME.c"
B_MK="$B_DIR/Makefile"
B_GOTO="$B_DIR/gotos/$B_NAME.goto"

L1_DIR="$WORKTREE/proofs/cbmc/mont_t2a_p3_single_call_decomposition"
L1_NAME="mont_t2a_p3_single_call_decomposition_harness"
L1_C="$L1_DIR/$L1_NAME.c"
L1_MK="$L1_DIR/Makefile"
L1_GOTO="$L1_DIR/gotos/$L1_NAME.goto"

L2_DIR="$WORKTREE/proofs/cbmc/mont_t2a_p3_arbitrary_pair_algebra"
L2_NAME="mont_t2a_p3_arbitrary_pair_algebra_harness"
L2_C="$L2_DIR/$L2_NAME.c"
L2_MK="$L2_DIR/Makefile"
L2_GOTO="$L2_DIR/gotos/$L2_NAME.goto"

C1_DIR="$WORKTREE/proofs/cbmc/mont_t2c1_same_fibre_control"
C1_NAME="mont_t2c1_same_fibre_control_harness"
C1_C="$C1_DIR/$C1_NAME.c"
C1_MK="$C1_DIR/Makefile"
C1_GOTO="$C1_DIR/gotos/$C1_NAME.goto"

C2_DIR="$WORKTREE/proofs/cbmc/mont_t2c2_translation_control"
C2_NAME="mont_t2c2_translation_control_harness"
C2_C="$C2_DIR/$C2_NAME.c"
C2_MK="$C2_DIR/Makefile"
C2_GOTO="$C2_DIR/gotos/$C2_NAME.goto"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_$STAMP"
CAPTURE="$OUT/MONT02A_R4_COMPOSITIONAL_P3_CAPTURE_$STAMP.txt"

BUILD_TIMEOUT=300
L1_TIMEOUT=600
L2_TIMEOUT=180
CONTROL_TIMEOUT=300

mkdir -p "$OUT"

section() {
  printf '\n============================================================\n'
  printf '%s\n' "$1"
  printf '============================================================\n'
}

hash_file() {
  sha256sum "$1" | awk '{print $1}'
}

create_makefile() {
  local output_file="$1"
  local harness_name="$2"
  local proof_uid="$3"

  cp "$T1_MAKEFILE" "$output_file"

  python3 - "$output_file" "$harness_name" "$proof_uid" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
new_name = sys.argv[2]
new_uid = sys.argv[3]
text = path.read_text()

old_name = "mont_t1_exact_refinement_harness"
old_uid = "MONT-T1 full-domain exact refinement"

if old_name not in text:
    raise SystemExit("old harness token missing")

text = text.replace(old_name, new_name)
text = text.replace(old_uid, new_uid)
text = text.replace("CBMCFLAGS = --smt2", "CBMCFLAGS =")

if old_name in text or new_name not in text:
    raise SystemExit("Makefile patch validation failed")

path.write_text(text)
PY
}

build_goto() {
  local proof_dir="$1"
  local log_file="$2"

  make -C "$proof_dir" MLKEM_K=3 clean > "$log_file.clean" 2>&1 || true
  timeout "$BUILD_TIMEOUT" make -C "$proof_dir" MLKEM_K=3 goto > "$log_file" 2>&1
  return $?
}

find_property_id() {
  local goto_file="$1"
  local description="$2"
  local output_file="$3"

  cbmc --show-properties "$goto_file" > "$output_file" 2>&1
  local show_rc=$?

  if [[ "$show_rc" -ne 0 ]]; then
    return 2
  fi

  python3 - "$output_file" "$description" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(errors="replace")
description = sys.argv[2]

matches = []
for line in text.splitlines():
    if description not in line:
        continue
    match = re.search(r"\[([^\]]+)\]", line)
    if match:
        matches.append(match.group(1))

if len(matches) != 1:
    raise SystemExit(3)

print(matches[0])
PY
}

run_target_property() {
  local goto_file="$1"
  local property_id="$2"
  local timeout_seconds="$3"
  local log_file="$4"

  timeout "$timeout_seconds" cbmc \
    --flush \
    --object-bits 8 \
    --slice-formula \
    --property "$property_id" \
    "$goto_file" > "$log_file" 2>&1

  return $?
}

audit_success_property() {
  local label="$1"
  local description="$2"
  local rc="$3"
  local log_file="$4"

  python3 - "$label" "$description" "$rc" "$log_file" <<'PY'
from pathlib import Path
import re
import sys

label = sys.argv[1]
description = sys.argv[2]
rc = int(sys.argv[3])
text = Path(sys.argv[4]).read_text(errors="replace")

failures = [
    line.strip()
    for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]

success = f"{description}: SUCCESS" in text
verified = "VERIFICATION SUCCESSFUL" in text
error = "VERIFICATION ERROR" in text
failed_marker = "VERIFICATION FAILED" in text

print(f"{label}_DIRECT_RC={rc}")
print(f"{label}_PROPERTY_SUCCESS={'YES' if success else 'NO'}")
print(f"{label}_VERIFICATION_SUCCESSFUL={'YES' if verified else 'NO'}")
print(f"{label}_FAILURE_COUNT={len(failures)}")

ok = (
    rc == 0
    and success
    and verified
    and not error
    and not failed_marker
    and not failures
)

print(f"{label}_AUDIT={'PASS' if ok else 'FAIL'}")
raise SystemExit(0 if ok else 4)
PY
}

audit_control() {
  local label="$1"
  local description="$2"
  local rc="$3"
  local log_file="$4"

  python3 - "$label" "$description" "$rc" "$log_file" <<'PY'
from pathlib import Path
import re
import sys

label = sys.argv[1]
description = sys.argv[2]
rc = int(sys.argv[3])
text = Path(sys.argv[4]).read_text(errors="replace")

failures = [
    line.strip()
    for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]

expected = [line for line in failures if description in line]
unexpected = [line for line in failures if description not in line]

print(f"{label}_DIRECT_RC={rc}")
print(f"{label}_FAILURE_COUNT={len(failures)}")
print(f"{label}_EXPECTED_FAILURE_COUNT={len(expected)}")
print(f"{label}_UNEXPECTED_FAILURE_COUNT={len(unexpected)}")

ok = (
    rc == 10
    and "VERIFICATION FAILED" in text
    and "VERIFICATION ERROR" not in text
    and len(expected) == 1
    and not unexpected
)

print(f"{label}_NONVACUITY_AUDIT={'PASS' if ok else 'FAIL'}")
raise SystemExit(0 if ok else 5)
PY
}

{
  section "MONT-02A-R4 — COMPOSITIONAL COMPLETION OF ORIGINAL T2-A.P3"

  echo "UTC_TIME=$STAMP"
  echo "OUTPUT_DIRECTORY=$OUT"
  echo "P3_PROOF_ARCHITECTURE=UNIVERSAL_IMPLEMENTATION_LEMMA_PLUS_FULL_ARBITRARY_PAIR_ALGEBRA"
  echo "P3_THEOREM=ORIGINAL_ARBITRARY_PAIR_SCALED_CONGRUENCE"
  echo "P3_DOMAIN=FULL_SOURCE_CONTRACT_FOR_BOTH_INPUTS"
  echo "P3_ENCODING=EXACT_INTEGER_Q_MULTIPLE_WITNESS"

  section "R0 — BIND SOURCE, T1, PRIOR 19/20, T2-B, AND ORIGINAL ARTEFACTS"

  AUTH_HEAD="$(git -C "$AUTHORITATIVE" rev-parse HEAD 2>/dev/null || true)"
  WT_HEAD="$(git -C "$WORKTREE" rev-parse HEAD 2>/dev/null || true)"
  AUTH_STATUS="$(git -C "$AUTHORITATIVE" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

  if [[ "$AUTH_HEAD" != "$EXPECTED_COMMIT" || "$WT_HEAD" != "$EXPECTED_COMMIT" || -n "$AUTH_STATUS" ]]; then
    echo "COMMIT_AND_CLEAN_GATE=FAIL"
    exit 20
  fi

  if [[ "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")" != "$EXPECTED_POLY_H_SHA256" || \
        "$(hash_file "$WORKTREE/mlkem/src/poly.h")" != "$EXPECTED_POLY_H_SHA256" || \
        "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")" != "$EXPECTED_POLY_C_SHA256" || \
        "$(hash_file "$WORKTREE/mlkem/src/poly.c")" != "$EXPECTED_POLY_C_SHA256" ]]; then
    echo "SOURCE_BINDING_GATE=FAIL"
    exit 21
  fi

  [[ -f "$T1_CAPTURE" ]] || { echo "T1_CAPTURE_PRESENT=NO"; exit 22; }
  [[ "$(hash_file "$T1_CAPTURE")" == "$EXPECTED_T1_CAPTURE_SHA256" ]] || { echo "T1_CAPTURE_BINDING=FAIL"; exit 23; }
  grep -Fxq "MONT_T1_STATUS=ACCEPTED_FOR_PINNED_COMMIT" "$T1_CAPTURE" || { echo "T1_STATUS_MARKER=FAIL"; exit 24; }

  [[ -f "$PRIOR_19_OF_20_CAPTURE" ]] || { echo "PRIOR_19_OF_20_PRESENT=NO"; exit 25; }
  [[ "$(hash_file "$PRIOR_19_OF_20_CAPTURE")" == "$EXPECTED_PRIOR_19_OF_20_SHA256" ]] || { echo "PRIOR_19_OF_20_BINDING=FAIL"; exit 26; }

  for marker in \
    "T2_A_PROPERTY_TOTAL=20" \
    "T2_A_PROPERTY_PASS_COUNT=19" \
    "T2_A_PROPERTY_TIMEOUT_COUNT=1" \
    "T2_A_PROPERTY_FAILURE_COUNT=0" \
    "PROPERTY_RESULT=harness.assertion.3|RC=124|PASS=NO"
  do
    grep -Fxq "$marker" "$PRIOR_19_OF_20_CAPTURE" || { echo "PRIOR_19_OF_20_MARKER_MISSING=$marker"; exit 27; }
  done

  [[ -f "$PRIOR_T2B_CAPTURE" ]] || { echo "PRIOR_T2B_PRESENT=NO"; exit 28; }
  [[ "$(hash_file "$PRIOR_T2B_CAPTURE")" == "$EXPECTED_PRIOR_T2B_SHA256" ]] || { echo "PRIOR_T2B_BINDING=FAIL"; exit 29; }
  grep -Fxq "T2_B_FUNCTIONAL_AUDIT=PASS" "$PRIOR_T2B_CAPTURE" || { echo "PRIOR_T2B_MARKER=FAIL"; exit 30; }

  for item in "$A_C" "$A_MK" "$A_GOTO" "$B_C" "$B_MK" "$B_GOTO" "$T1_MAKEFILE"; do
    [[ -f "$item" ]] || { echo "REQUIRED_ARTEFACT_MISSING=$item"; exit 31; }
  done

  [[ "$(hash_file "$A_C")" == "$EXPECTED_ORIGINAL_A_HARNESS_SHA256" ]] || { echo "ORIGINAL_A_HARNESS_BINDING=FAIL"; exit 32; }
  [[ "$(hash_file "$A_GOTO")" == "$EXPECTED_ORIGINAL_A_GOTO_SHA256" ]] || { echo "ORIGINAL_A_GOTO_BINDING=FAIL"; exit 33; }
  [[ "$(hash_file "$B_C")" == "$EXPECTED_ORIGINAL_B_HARNESS_SHA256" ]] || { echo "ORIGINAL_B_HARNESS_BINDING=FAIL"; exit 34; }
  [[ "$(hash_file "$B_GOTO")" == "$EXPECTED_ORIGINAL_B_GOTO_SHA256" ]] || { echo "ORIGINAL_B_GOTO_BINDING=FAIL"; exit 35; }

  echo "COMMIT_AND_CLEAN_GATE=PASS"
  echo "SOURCE_BINDING_GATE=PASS"
  echo "ACCEPTED_T1_BINDING_GATE=PASS"
  echo "T2_A_PRIOR_19_OF_20_BINDING=PASS"
  echo "T2_B_FUNCTIONAL_AUDIT=PASS"
  echo "ORIGINAL_T2_A_AND_T2_B_ARTEFACT_BINDING=PASS"

  cp "$PRIOR_19_OF_20_CAPTURE" "$OUT/BOUND_PRIOR_19_OF_20_CAPTURE.txt"
  cp "$PRIOR_T2B_CAPTURE" "$OUT/BOUND_PRIOR_T2B_CAPTURE.txt"

  section "R1 — FREEZE COMPOSITIONAL P3 PROOF REGISTRY"

  cat > "$OUT/MONT02A_R4_P3_PROOF_REGISTRY.md" <<EOF
# MONT-T2A.P3 Compositional Completion

## Original locked theorem

For arbitrary independent inputs a and b in the full source-contract domain:

    (R * (reduce(b) - reduce(a)) - (b - a)) is divisible by q.

Equivalently:

    R * (reduce(b) - reduce(a)) ≡ b - a (mod q).

## Proof architecture

1. Prove universally for one arbitrary full-domain input x that the production
   implementation satisfies the exact decomposition

       R * reduce(x) + q * t(x) = x,

   where t(x) is reconstructed independently from the frozen Montgomery
   inverse constant and the canonical low 16-bit word.

2. Instantiate that universally proved implementation lemma for independent
   arbitrary full-domain a and b.

3. Prove the exact relational identity

       R * (reduce(b) - reduce(a)) - (b - a)
           = q * (t(a) - t(b)).

The right-hand side is an explicit integer multiple of q, so this proves the
original locked arbitrary-pair congruence. No input-domain restriction, sign
partition, strengthened assumption, T1 substitution, or theorem deletion is
used.
EOF

  echo "P3_PROOF_REGISTRY_SHA256=$(hash_file "$OUT/MONT02A_R4_P3_PROOF_REGISTRY.md")"

  section "R2 — CREATE UNIVERSAL SINGLE-CALL IMPLEMENTATION LEMMA"

  rm -rf "$L1_DIR" "$L2_DIR" "$C1_DIR" "$C2_DIR"
  mkdir -p "$L1_DIR" "$L2_DIR" "$C1_DIR" "$C2_DIR"

  cat > "$L1_C" <<'C'
#include <stdint.h>
#include <limits.h>
#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_Q ((int64_t)MLKEM_Q)
#define FROZEN_QINV ((uint32_t)62209)
#define DOMAIN_LIMIT \
  ((int64_t)INT32_MAX - (((int64_t)1 << 15) * (int64_t)MLKEM_Q))

extern int32_t nondet_int32_t(void);

static int16_t independent_signed_witness(int32_t x)
{
  uint16_t low;
  uint16_t inverted;

  low = mlk_cast_int32_to_uint16(x);
  inverted = (uint16_t)(((uint32_t)low * FROZEN_QINV) & UINT16_MAX);
  return mlk_cast_uint16_to_int16(inverted);
}

void harness(void)
{
  int32_t x;
  int16_t result;
  int16_t witness;

  x = nondet_int32_t();

  __CPROVER_assume((int64_t)x < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)x > -DOMAIN_LIMIT);

  result = mlk_montgomery_reduce(x);
  witness = independent_signed_witness(x);

  __CPROVER_assert(
      ((int64_t)result * MONT_R) +
              ((int64_t)witness * MONT_Q) ==
          (int64_t)x,
      "MONT-T2A.P3L1.universal_single_call_exact_decomposition");
}
C

  create_makefile "$L1_MK" "$L1_NAME" "MONT-T2A P3 universal implementation decomposition lemma"

  echo "P3_L1_HARNESS_SHA256=$(hash_file "$L1_C")"
  echo "P3_L1_MAKEFILE_SHA256=$(hash_file "$L1_MK")"

  build_goto "$L1_DIR" "$OUT/L1_BUILD.log"
  L1_BUILD_RC=$?
  echo "P3_L1_BUILD_RC=$L1_BUILD_RC"

  [[ -f "$L1_GOTO" ]] || { echo "P3_L1_GOTO_PRESENT=NO"; tail -n 100 "$OUT/L1_BUILD.log" || true; exit 36; }

  echo "P3_L1_GOTO_SHA256=$(hash_file "$L1_GOTO")"

  L1_DESCRIPTION="MONT-T2A.P3L1.universal_single_call_exact_decomposition"
  L1_PROPERTY_ID="$(find_property_id "$L1_GOTO" "$L1_DESCRIPTION" "$OUT/L1_PROPERTIES.txt")"
  L1_FIND_RC=$?

  echo "P3_L1_PROPERTY_ID=$L1_PROPERTY_ID"
  echo "P3_L1_PROPERTY_LOOKUP_RC=$L1_FIND_RC"

  [[ "$L1_FIND_RC" -eq 0 && -n "$L1_PROPERTY_ID" ]] || exit 37

  run_target_property "$L1_GOTO" "$L1_PROPERTY_ID" "$L1_TIMEOUT" "$OUT/L1_CBMC.log"
  L1_RC=$?

  grep -E 'MONT-T2A.P3L1|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$' "$OUT/L1_CBMC.log" || true

  audit_success_property "P3_L1" "$L1_DESCRIPTION" "$L1_RC" "$OUT/L1_CBMC.log"
  L1_AUDIT=$?

  [[ "$L1_AUDIT" -eq 0 ]] || { echo "P3_UNIVERSAL_IMPLEMENTATION_LEMMA_GATE=FAIL"; exit 38; }

  echo "P3_UNIVERSAL_IMPLEMENTATION_LEMMA_GATE=PASS"

  section "R3 — PROVE FULL ARBITRARY-PAIR EXACT Q-MULTIPLE ALGEBRA"

  cat > "$L2_C" <<'C'
#include <stdint.h>
#include <limits.h>
#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_Q ((int64_t)MLKEM_Q)
#define DOMAIN_LIMIT \
  ((int64_t)INT32_MAX - (((int64_t)1 << 15) * (int64_t)MLKEM_Q))

extern int32_t nondet_int32_t(void);
extern int16_t nondet_int16_t(void);

void harness(void)
{
  int32_t a;
  int32_t b;
  int16_t ra;
  int16_t rb;
  int16_t ta;
  int16_t tb;
  int64_t input_delta;
  int64_t output_delta;
  int64_t scaled_difference;
  int64_t exact_integer_quotient;

  a = nondet_int32_t();
  b = nondet_int32_t();
  ra = nondet_int16_t();
  rb = nondet_int16_t();
  ta = nondet_int16_t();
  tb = nondet_int16_t();

  __CPROVER_assume((int64_t)a < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)a > -DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b > -DOMAIN_LIMIT);

  /* Two universal instantiations of the independently proved P3L1 lemma. */
  __CPROVER_assume(
      ((int64_t)ra * MONT_R) + ((int64_t)ta * MONT_Q) == (int64_t)a);
  __CPROVER_assume(
      ((int64_t)rb * MONT_R) + ((int64_t)tb * MONT_Q) == (int64_t)b);

  input_delta = (int64_t)b - (int64_t)a;
  output_delta = (int64_t)rb - (int64_t)ra;
  scaled_difference = (output_delta * MONT_R) - input_delta;
  exact_integer_quotient = (int64_t)ta - (int64_t)tb;

  /*
   * Exact divisibility witness for the original locked congruence:
   *
   *   scaled_difference = q * exact_integer_quotient.
   *
   * This is the integer-definition form of scaled_difference ≡ 0 (mod q).
   */
  __CPROVER_assert(
      scaled_difference == MONT_Q * exact_integer_quotient,
      "MONT-T2A.P3.arbitrary_pair_scaled_congruence");
}
C

  create_makefile "$L2_MK" "$L2_NAME" "MONT-T2A P3 full arbitrary-pair exact q-multiple algebra"

  echo "P3_L2_HARNESS_SHA256=$(hash_file "$L2_C")"
  echo "P3_L2_MAKEFILE_SHA256=$(hash_file "$L2_MK")"

  build_goto "$L2_DIR" "$OUT/L2_BUILD.log"
  L2_BUILD_RC=$?
  echo "P3_L2_BUILD_RC=$L2_BUILD_RC"

  [[ -f "$L2_GOTO" ]] || { echo "P3_L2_GOTO_PRESENT=NO"; tail -n 100 "$OUT/L2_BUILD.log" || true; exit 39; }

  echo "P3_L2_GOTO_SHA256=$(hash_file "$L2_GOTO")"

  L2_DESCRIPTION="MONT-T2A.P3.arbitrary_pair_scaled_congruence"
  L2_PROPERTY_ID="$(find_property_id "$L2_GOTO" "$L2_DESCRIPTION" "$OUT/L2_PROPERTIES.txt")"
  L2_FIND_RC=$?

  echo "P3_L2_PROPERTY_ID=$L2_PROPERTY_ID"
  echo "P3_L2_PROPERTY_LOOKUP_RC=$L2_FIND_RC"

  [[ "$L2_FIND_RC" -eq 0 && -n "$L2_PROPERTY_ID" ]] || exit 40

  run_target_property "$L2_GOTO" "$L2_PROPERTY_ID" "$L2_TIMEOUT" "$OUT/L2_CBMC.log"
  L2_RC=$?

  grep -E 'MONT-T2A.P3|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$' "$OUT/L2_CBMC.log" || true

  audit_success_property "P3_L2" "$L2_DESCRIPTION" "$L2_RC" "$OUT/L2_CBMC.log"
  L2_AUDIT=$?

  [[ "$L2_AUDIT" -eq 0 ]] || { echo "T2_A_P3_ORIGINAL_THEOREM_GATE=FAIL"; exit 41; }

  echo "T2_A_P3_EXACT_INTEGER_WITNESS_GATE=PASS"
  echo "T2_A_P3_ORIGINAL_THEOREM_GATE=PASS"
  echo "T2_A_P3_ORIGINAL_CONGRUENCE=PROVED_FOR_FULL_ARBITRARY_PAIR_DOMAIN"
  echo "T2_A_P3_THEOREM_WEAKENED=NO"

  section "R4 — BUILD AND RUN BOTH ORIGINAL DISTINCT NON-VACUITY CONTROLS"

  cp "$A_C" "$C1_C"
  cp "$B_C" "$C2_C"
  create_makefile "$C1_MK" "$C1_NAME" "MONT-T2 C1 same-fibre branch control"
  create_makefile "$C2_MK" "$C2_NAME" "MONT-T2 C2 translation path control"

  python3 - "$C1_C" "$C2_C" <<'PY'
from pathlib import Path
import sys

c1 = Path(sys.argv[1])
c2 = Path(sys.argv[2])

s1 = c1.read_text()
marker1 = "    /* C1_CONTROL */"
if s1.count(marker1) != 1:
    raise SystemExit("C1 marker invalid")
s1 = s1.replace(
    marker1,
    '''    __CPROVER_assert(
        0,
        "MONT-T2.CONTROL.C1.same_fibre_branch_reachable");''',
)
c1.write_text(s1)

s2 = c2.read_text()
marker2 = "  /* C2_CONTROL */"
if s2.count(marker2) != 1:
    raise SystemExit("C2 marker invalid")
s2 = s2.replace(
    marker2,
    '''  __CPROVER_assert(
      0,
      "MONT-T2.CONTROL.C2.translation_path_reachable");''',
)
c2.write_text(s2)
PY

  build_goto "$C1_DIR" "$OUT/C1_BUILD.log" &
  P1=$!
  build_goto "$C2_DIR" "$OUT/C2_BUILD.log" &
  P2=$!
  wait "$P1" || true
  wait "$P2" || true

  [[ -f "$C1_GOTO" ]] || { echo "C1_GOTO_PRESENT=NO"; exit 42; }
  [[ -f "$C2_GOTO" ]] || { echo "C2_GOTO_PRESENT=NO"; exit 43; }

  C1_DESCRIPTION="MONT-T2.CONTROL.C1.same_fibre_branch_reachable"
  C2_DESCRIPTION="MONT-T2.CONTROL.C2.translation_path_reachable"

  C1_PROPERTY_ID="$(find_property_id "$C1_GOTO" "$C1_DESCRIPTION" "$OUT/C1_PROPERTIES.txt")"
  C1_FIND_RC=$?
  C2_PROPERTY_ID="$(find_property_id "$C2_GOTO" "$C2_DESCRIPTION" "$OUT/C2_PROPERTIES.txt")"
  C2_FIND_RC=$?

  echo "C1_PROPERTY_ID=$C1_PROPERTY_ID"
  echo "C2_PROPERTY_ID=$C2_PROPERTY_ID"

  [[ "$C1_FIND_RC" -eq 0 && -n "$C1_PROPERTY_ID" ]] || exit 44
  [[ "$C2_FIND_RC" -eq 0 && -n "$C2_PROPERTY_ID" ]] || exit 45

  (run_target_property "$C1_GOTO" "$C1_PROPERTY_ID" "$CONTROL_TIMEOUT" "$OUT/C1_CBMC.log"; echo "$?" > "$OUT/C1_CBMC.rc") &
  PC1=$!
  (run_target_property "$C2_GOTO" "$C2_PROPERTY_ID" "$CONTROL_TIMEOUT" "$OUT/C2_CBMC.log"; echo "$?" > "$OUT/C2_CBMC.rc") &
  PC2=$!
  wait "$PC1" || true
  wait "$PC2" || true

  C1_RC="$(cat "$OUT/C1_CBMC.rc")"
  C2_RC="$(cat "$OUT/C2_CBMC.rc")"

  grep -E 'MONT-T2.CONTROL.C1|VERIFICATION FAILED|: FAILURE$' "$OUT/C1_CBMC.log" || true
  grep -E 'MONT-T2.CONTROL.C2|VERIFICATION FAILED|: FAILURE$' "$OUT/C2_CBMC.log" || true

  audit_control "C1" "$C1_DESCRIPTION" "$C1_RC" "$OUT/C1_CBMC.log"
  C1_AUDIT=$?
  audit_control "C2" "$C2_DESCRIPTION" "$C2_RC" "$OUT/C2_CBMC.log"
  C2_AUDIT=$?

  [[ "$C1_AUDIT" -eq 0 ]] || exit 46
  [[ "$C2_AUDIT" -eq 0 ]] || exit 47

  echo "C1_NONVACUITY_AUDIT=PASS"
  echo "C2_NONVACUITY_AUDIT=PASS"

  section "R5 — FINAL FULL GATE-A ACCEPTANCE AND MUTATION BINDING"

  FINAL_AUTH_H="$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")"
  FINAL_WT_H="$(hash_file "$WORKTREE/mlkem/src/poly.h")"
  FINAL_AUTH_C="$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")"
  FINAL_WT_C="$(hash_file "$WORKTREE/mlkem/src/poly.c")"

  if [[ "$FINAL_AUTH_H" != "$EXPECTED_POLY_H_SHA256" || \
        "$FINAL_WT_H" != "$EXPECTED_POLY_H_SHA256" || \
        "$FINAL_AUTH_C" != "$EXPECTED_POLY_C_SHA256" || \
        "$FINAL_WT_C" != "$EXPECTED_POLY_C_SHA256" ]]; then
    echo "FINAL_SOURCE_INTEGRITY=FAIL"
    exit 48
  fi

  echo "FINAL_SOURCE_INTEGRITY=PASS"

  cat > "$OUT/MONT02A_GATE_A_BINDING.env" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H_SHA256=$EXPECTED_POLY_H_SHA256
EXPECTED_POLY_C_SHA256=$EXPECTED_POLY_C_SHA256
T1_CAPTURE_SHA256=$EXPECTED_T1_CAPTURE_SHA256
A_HARNESS_SHA256=$(hash_file "$A_C")
A_MAKEFILE_SHA256=$(hash_file "$A_MK")
A_GOTO_SHA256=$(hash_file "$A_GOTO")
B_HARNESS_SHA256=$(hash_file "$B_C")
B_MAKEFILE_SHA256=$(hash_file "$B_MK")
B_GOTO_SHA256=$(hash_file "$B_GOTO")
P3_L1_HARNESS_SHA256=$(hash_file "$L1_C")
P3_L1_GOTO_SHA256=$(hash_file "$L1_GOTO")
P3_L2_HARNESS_SHA256=$(hash_file "$L2_C")
P3_L2_GOTO_SHA256=$(hash_file "$L2_GOTO")
MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS
EOF

  find "$OUT" -type f -print0 | sort -z | xargs -0 sha256sum > "$OUT/FILE_MANIFEST.sha256"

  echo "T2_A_PRIOR_NON_P3_PROPERTIES=PASS_19_OF_19"
  echo "T2_A_P3_UNIVERSAL_IMPLEMENTATION_LEMMA=PASS"
  echo "T2_A_P3_FULL_ARBITRARY_PAIR_ALGEBRA=PASS"
  echo "T2_A_ALL_ORIGINAL_PROPERTIES_CHECKED=YES"
  echo "T2_A_FUNCTIONAL_AUDIT=PASS"
  echo "T2_B_FUNCTIONAL_AUDIT=PASS"
  echo "MONT_T2_C1_NONVACUITY=PASS"
  echo "MONT_T2_C2_NONVACUITY=PASS"
  echo "MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS"
  echo "MONT_T2_STATUS=FUNCTIONAL_AND_NONVACUITY_ACCEPTED_PENDING_T2_MUTATIONS"
  echo "NEXT_GATE=MONT-02B_T2_SPECIFIC_MUTATIONS"
  echo "MONT02A_R4_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

RC="${PIPESTATUS[0]}"
sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"

echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$RC"

exit "$RC"
