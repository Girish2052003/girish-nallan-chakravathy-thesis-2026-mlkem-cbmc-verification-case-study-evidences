#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H_SHA256="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_T1_CAPTURE_SHA256="866ba00a16a8d46595c4abe04456f7f3360600ac0c34ad826a34741c035b8813"

AUTHORITATIVE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WORKTREE="$ROOT/MONT_WORKTREE_af4c5abd"

T1_CAPTURE="$ROOT/MONT01B_R1_M2_M3_20260726T151104Z/MONT01B_R1_TERMINAL_CAPTURE_20260726T151104Z.txt"
T1_MAKEFILE="$WORKTREE/proofs/cbmc/mont_t1_exact_refinement/Makefile"

A_DIR="$WORKTREE/proofs/cbmc/mont_t2a_arbitrary_pair"
A_NAME="mont_t2a_arbitrary_pair_harness"
A_C="$A_DIR/$A_NAME.c"
A_MK="$A_DIR/Makefile"
A_GOTO_REL="gotos/$A_NAME.goto"
A_GOTO="$A_DIR/$A_GOTO_REL"

B_DIR="$WORKTREE/proofs/cbmc/mont_t2b_fibre_translation"
B_NAME="mont_t2b_fibre_translation_harness"
B_C="$B_DIR/$B_NAME.c"
B_MK="$B_DIR/Makefile"
B_GOTO_REL="gotos/$B_NAME.goto"
B_GOTO="$B_DIR/$B_GOTO_REL"

C1_DIR="$WORKTREE/proofs/cbmc/mont_t2c1_same_fibre_control"
C1_NAME="mont_t2c1_same_fibre_control_harness"
C1_C="$C1_DIR/$C1_NAME.c"
C1_MK="$C1_DIR/Makefile"
C1_GOTO_REL="gotos/$C1_NAME.goto"
C1_GOTO="$C1_DIR/$C1_GOTO_REL"

C2_DIR="$WORKTREE/proofs/cbmc/mont_t2c2_translation_control"
C2_NAME="mont_t2c2_translation_control_harness"
C2_C="$C2_DIR/$C2_NAME.c"
C2_MK="$C2_DIR/Makefile"
C2_GOTO_REL="gotos/$C2_NAME.goto"
C2_GOTO="$C2_DIR/$C2_GOTO_REL"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_$STAMP"
CAPTURE="$OUT/MONT02A_FULL_T2_CAPTURE_$STAMP.txt"

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
  local out="$1"
  local new_name="$2"
  local new_uid="$3"

  cp "$T1_MAKEFILE" "$out"

  python3 - "$out" "$new_name" "$new_uid" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
new_name = sys.argv[2]
new_uid = sys.argv[3]
s = p.read_text()

old_name = "mont_t1_exact_refinement_harness"
old_uid = "MONT-T1 full-domain exact refinement"

if old_name not in s:
    raise SystemExit("old harness token missing")

s = s.replace(old_name, new_name)
s = s.replace(old_uid, new_uid)
s = s.replace("CBMCFLAGS = --smt2", "CBMCFLAGS =")

if old_name in s or new_name not in s:
    raise SystemExit("makefile patch validation failed")

p.write_text(s)
PY
}

build_goto() {
  local dir="$1"
  local target="$2"
  local log="$3"

  make -C "$dir" MLKEM_K=3 clean > "$log.clean" 2>&1 || true
  timeout 300 make -C "$dir" MLKEM_K=3 "$target" > "$log" 2>&1
  return $?
}

run_cbmc() {
  local goto_file="$1"
  local log="$2"

  timeout 1200 cbmc \
    --flush \
    --object-bits 8 \
    --slice-formula \
    --conversion-check \
    --float-overflow-check \
    --nan-check \
    --pointer-overflow-check \
    --unsigned-overflow-check \
    --trace \
    "$goto_file" > "$log" 2>&1

  return $?
}

audit_success() {
  local kind="$1"
  local rc="$2"
  local log="$3"

  python3 - "$kind" "$rc" "$log" <<'PY'
from pathlib import Path
import re
import sys

kind = sys.argv[1]
rc = int(sys.argv[2])
text = Path(sys.argv[3]).read_text(errors="replace")

required = {
    "A": [
        "MONT-T2A.P1.first_low_word_normalized",
        "MONT-T2A.P2.second_low_word_normalized",
        "MONT-T2A.P3.arbitrary_pair_scaled_congruence",
        "MONT-T2A.P4.same_low_word_input_delta_divisible_by_R",
        "MONT-T2A.P5.same_low_word_exact_output_delta",
        "MONT-T2A.P6.same_fibre_injectivity",
    ],
    "B": [
        "MONT-T2B.P1.shifted_input_same_low_word",
        "MONT-T2B.P2.general_fibre_translation",
        "MONT-T2B.P3.exact_output_delta_equals_k",
        "MONT-T2B.P4.zero_shift_identity",
        "MONT-T2B.P5.nonzero_shift_changes_output",
    ],
}[kind]

failures = [
    line.strip() for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]
missing = [x for x in required if f"{x}: SUCCESS" not in text]

print(f"T2_{kind}_DIRECT_RC={rc}")
print(f"T2_{kind}_FAILURE_COUNT={len(failures)}")
print(f"T2_{kind}_MISSING_REQUIRED_COUNT={len(missing)}")

for i, x in enumerate(failures, 1):
    print(f"T2_{kind}_FAILURE_{i}={x}")
for i, x in enumerate(missing, 1):
    print(f"T2_{kind}_MISSING_{i}={x}")

ok = (
    rc == 0
    and "VERIFICATION SUCCESSFUL" in text
    and "VERIFICATION FAILED" not in text
    and "VERIFICATION ERROR" not in text
    and not failures
    and not missing
)

print(f"T2_{kind}_FUNCTIONAL_AUDIT={'PASS' if ok else 'FAIL'}")
raise SystemExit(0 if ok else 4)
PY
}

audit_control() {
  local expected="$1"
  local rc="$2"
  local log="$3"

  python3 - "$expected" "$rc" "$log" <<'PY'
from pathlib import Path
import re
import sys

expected = sys.argv[1]
rc = int(sys.argv[2])
text = Path(sys.argv[3]).read_text(errors="replace")

failures = [
    line.strip() for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]
expected_failures = [x for x in failures if expected in x]
unexpected = [x for x in failures if expected not in x]

print(f"CONTROL_NAME={expected}")
print(f"CONTROL_DIRECT_RC={rc}")
print(f"CONTROL_FAILURE_COUNT={len(failures)}")
print(f"CONTROL_EXPECTED_FAILURE_COUNT={len(expected_failures)}")
print(f"CONTROL_UNEXPECTED_FAILURE_COUNT={len(unexpected)}")

ok = (
    rc == 10
    and "VERIFICATION FAILED" in text
    and "VERIFICATION ERROR" not in text
    and len(expected_failures) == 1
    and not unexpected
)

print(f"CONTROL_AUDIT={'PASS' if ok else 'FAIL'}")
raise SystemExit(0 if ok else 5)
PY
}

{
  section "MONT-02A — FULL LOCKED T2 FUNCTIONAL + NON-VACUITY"

  echo "UTC_TIME=$STAMP"
  echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
  echo "OUTPUT_DIRECTORY=$OUT"

  section "A0 — SOURCE AND ACCEPTED T1 BINDING"

  AH="$(git -C "$AUTHORITATIVE" rev-parse HEAD 2>/dev/null || true)"
  WH="$(git -C "$WORKTREE" rev-parse HEAD 2>/dev/null || true)"
  AS="$(git -C "$AUTHORITATIVE" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

  if [[ "$AH" != "$EXPECTED_COMMIT" || "$WH" != "$EXPECTED_COMMIT" || -n "$AS" ]]; then
    echo "COMMIT_OR_CLEAN_GATE=FAIL"
    exit 20
  fi

  AUTH_H="$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")"
  WORK_H="$(hash_file "$WORKTREE/mlkem/src/poly.h")"
  AUTH_C="$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")"
  WORK_C="$(hash_file "$WORKTREE/mlkem/src/poly.c")"

  if [[ "$AUTH_H" != "$EXPECTED_POLY_H_SHA256" || "$WORK_H" != "$EXPECTED_POLY_H_SHA256" || "$AUTH_C" != "$EXPECTED_POLY_C_SHA256" || "$WORK_C" != "$EXPECTED_POLY_C_SHA256" ]]; then
    echo "SOURCE_BINDING_GATE=FAIL"
    exit 21
  fi

  T1_HASH="$(hash_file "$T1_CAPTURE")"

  if [[ "$T1_HASH" != "$EXPECTED_T1_CAPTURE_SHA256" ]] || ! grep -Fxq "MONT_T1_STATUS=ACCEPTED_FOR_PINNED_COMMIT" "$T1_CAPTURE"; then
    echo "T1_BINDING_GATE=FAIL"
    exit 22
  fi

  echo "COMMIT_AND_CLEAN_GATE=PASS"
  echo "SOURCE_BINDING_GATE=PASS"
  echo "ACCEPTED_T1_BINDING_GATE=PASS"

  section "A1 — FREEZE FULL T2 REGISTRY"

  cat > "$OUT/MONT02_FULL_T2_REGISTRY.md" <<EOF
# Full locked MONT-T2

## T2-A arbitrary-pair direct laws

- two independent full-domain nondeterministic inputs;
- low-word normalization for each input;
- direct arbitrary-pair scaled congruence;
- same-low-word input delta divisibility;
- exact same-fibre output delta;
- same-fibre injectivity.

## T2-B affine fibre direct laws

- nondeterministic base and nondeterministic integer shift;
- both inputs remain in the full source contract;
- equal canonical low word;
- general translation by k*65536;
- exact output delta equals k;
- zero-shift identity;
- nonzero-shift output distinction.

## Non-vacuity

- C1 reaches the same-low-word arbitrary-pair branch.
- C2 reaches the affine translation path.

No property is removed, narrowed, or replaced by derivation from T1.
EOF

  echo "T2_REGISTRY_SHA256=$(hash_file "$OUT/MONT02_FULL_T2_REGISTRY.md")"

  section "A2 — CREATE FUNCTIONAL HARNESSES"

  rm -rf "$A_DIR" "$B_DIR" "$C1_DIR" "$C2_DIR"
  mkdir -p "$A_DIR" "$B_DIR" "$C1_DIR" "$C2_DIR"

  cat > "$A_C" <<'C'
#include <stdint.h>
#include <limits.h>
#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_Q ((int64_t)MLKEM_Q)
#define DOMAIN_LIMIT ((int64_t)INT32_MAX - (((int64_t)1 << 15) * (int64_t)MLKEM_Q))

extern int32_t nondet_int32_t(void);

static int64_t low_word(int32_t x)
{
  int64_t r = (int64_t)x % MONT_R;
  if (r < 0)
  {
    r += MONT_R;
  }
  return r;
}

void harness(void)
{
  int32_t a = nondet_int32_t();
  int32_t b = nondet_int32_t();
  int16_t ra;
  int16_t rb;
  int64_t la;
  int64_t lb;
  int64_t in_delta;
  int64_t out_delta;

  __CPROVER_assume((int64_t)a < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)a > -DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b > -DOMAIN_LIMIT);

  ra = mlk_montgomery_reduce(a);
  rb = mlk_montgomery_reduce(b);

  la = low_word(a);
  lb = low_word(b);
  in_delta = (int64_t)b - (int64_t)a;
  out_delta = (int64_t)rb - (int64_t)ra;

  __CPROVER_assert(
      la >= 0 && la < MONT_R,
      "MONT-T2A.P1.first_low_word_normalized");

  __CPROVER_assert(
      lb >= 0 && lb < MONT_R,
      "MONT-T2A.P2.second_low_word_normalized");

  __CPROVER_assert(
      ((out_delta * MONT_R - in_delta) % MONT_Q) == 0,
      "MONT-T2A.P3.arbitrary_pair_scaled_congruence");

  if (la == lb)
  {
    __CPROVER_assert(
        in_delta % MONT_R == 0,
        "MONT-T2A.P4.same_low_word_input_delta_divisible_by_R");

    __CPROVER_assert(
        out_delta == in_delta / MONT_R,
        "MONT-T2A.P5.same_low_word_exact_output_delta");

    __CPROVER_assert(
        (((int64_t)ra == (int64_t)rb) == (a == b)),
        "MONT-T2A.P6.same_fibre_injectivity");

    /* C1_CONTROL */
  }
}
C

  cat > "$B_C" <<'C'
#include <stdint.h>
#include <limits.h>
#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define DOMAIN_LIMIT ((int64_t)INT32_MAX - (((int64_t)1 << 15) * (int64_t)MLKEM_Q))

extern int32_t nondet_int32_t(void);

static int64_t low_word(int32_t x)
{
  int64_t r = (int64_t)x % MONT_R;
  if (r < 0)
  {
    r += MONT_R;
  }
  return r;
}

void harness(void)
{
  int32_t a = nondet_int32_t();
  int32_t k = nondet_int32_t();
  int64_t b_wide;
  int32_t b;
  int16_t ra;
  int16_t rb;
  int64_t out_delta;

  __CPROVER_assume((int64_t)a < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)a > -DOMAIN_LIMIT);

  b_wide = (int64_t)a + ((int64_t)k * MONT_R);

  __CPROVER_assume(b_wide < DOMAIN_LIMIT);
  __CPROVER_assume(b_wide > -DOMAIN_LIMIT);

  b = (int32_t)b_wide;

  ra = mlk_montgomery_reduce(a);
  rb = mlk_montgomery_reduce(b);
  out_delta = (int64_t)rb - (int64_t)ra;

  __CPROVER_assert(
      low_word(a) == low_word(b),
      "MONT-T2B.P1.shifted_input_same_low_word");

  __CPROVER_assert(
      (int64_t)rb == (int64_t)ra + (int64_t)k,
      "MONT-T2B.P2.general_fibre_translation");

  __CPROVER_assert(
      out_delta == (int64_t)k,
      "MONT-T2B.P3.exact_output_delta_equals_k");

  if (k == 0)
  {
    __CPROVER_assert(
        rb == ra,
        "MONT-T2B.P4.zero_shift_identity");
  }

  if (k != 0)
  {
    __CPROVER_assert(
        rb != ra,
        "MONT-T2B.P5.nonzero_shift_changes_output");
  }

  /* C2_CONTROL */
}
C

  create_makefile "$A_MK" "$A_NAME" "MONT-T2A arbitrary-pair relational laws"
  create_makefile "$B_MK" "$B_NAME" "MONT-T2B affine fibre laws"

  echo "T2_A_HARNESS_SHA256=$(hash_file "$A_C")"
  echo "T2_B_HARNESS_SHA256=$(hash_file "$B_C")"

  section "A3 — PARALLEL GOTO-ONLY BUILDS"

  (build_goto "$A_DIR" "$A_GOTO_REL" "$OUT/A_BUILD.log"; echo "$?" > "$OUT/A_BUILD.rc") &
  PA=$!
  (build_goto "$B_DIR" "$B_GOTO_REL" "$OUT/B_BUILD.log"; echo "$?" > "$OUT/B_BUILD.rc") &
  PB=$!
  wait "$PA" || true
  wait "$PB" || true

  if [[ ! -f "$A_GOTO" ]]; then
    echo "T2_A_GOTO_PRESENT=NO"
    tail -n 100 "$OUT/A_BUILD.log" || true
    exit 23
  fi

  if [[ ! -f "$B_GOTO" ]]; then
    echo "T2_B_GOTO_PRESENT=NO"
    tail -n 100 "$OUT/B_BUILD.log" || true
    exit 24
  fi

  echo "T2_A_GOTO_SHA256=$(hash_file "$A_GOTO")"
  echo "T2_B_GOTO_SHA256=$(hash_file "$B_GOTO")"

  section "A4 — PARALLEL DIRECT FUNCTIONAL CBMC"

  (run_cbmc "$A_GOTO" "$OUT/A_CBMC.log"; echo "$?" > "$OUT/A_CBMC.rc") &
  PA=$!
  (run_cbmc "$B_GOTO" "$OUT/B_CBMC.log"; echo "$?" > "$OUT/B_CBMC.rc") &
  PB=$!
  wait "$PA" || true
  wait "$PB" || true

  ARC="$(cat "$OUT/A_CBMC.rc")"
  BRC="$(cat "$OUT/B_CBMC.rc")"

  echo "T2_A_KEY_RESULTS_BEGIN"
  grep -E 'MONT-T2A\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$' "$OUT/A_CBMC.log" || true
  echo "T2_A_KEY_RESULTS_END"

  echo "T2_B_KEY_RESULTS_BEGIN"
  grep -E 'MONT-T2B\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$' "$OUT/B_CBMC.log" || true
  echo "T2_B_KEY_RESULTS_END"

  audit_success A "$ARC" "$OUT/A_CBMC.log"
  A_AUDIT=$?
  audit_success B "$BRC" "$OUT/B_CBMC.log"
  B_AUDIT=$?

  if [[ "$A_AUDIT" -ne 0 || "$B_AUDIT" -ne 0 ]]; then
    echo "T2_FUNCTIONAL_GATE=FAIL"
    exit 25
  fi

  echo "T2_FUNCTIONAL_GATE=PASS"

  section "A5 — CREATE TWO DISTINCT CONTROLS"

  cp "$A_C" "$C1_C"
  cp "$B_C" "$C2_C"
  create_makefile "$C1_MK" "$C1_NAME" "MONT-T2 C1 same-fibre control"
  create_makefile "$C2_MK" "$C2_NAME" "MONT-T2 C2 translation control"

  python3 - "$C1_C" "$C2_C" <<'PY'
from pathlib import Path
import sys

c1 = Path(sys.argv[1])
c2 = Path(sys.argv[2])

s1 = c1.read_text()
m1 = "    /* C1_CONTROL */"
if s1.count(m1) != 1:
    raise SystemExit("C1 marker invalid")
s1 = s1.replace(
    m1,
    '''    __CPROVER_assert(
        0,
        "MONT-T2.CONTROL.C1.same_fibre_branch_reachable");'''
)
c1.write_text(s1)

s2 = c2.read_text()
m2 = "  /* C2_CONTROL */"
if s2.count(m2) != 1:
    raise SystemExit("C2 marker invalid")
s2 = s2.replace(
    m2,
    '''  __CPROVER_assert(
      0,
      "MONT-T2.CONTROL.C2.translation_path_reachable");'''
)
c2.write_text(s2)
PY

  section "A6 — PARALLEL CONTROL BUILDS AND CBMC"

  (build_goto "$C1_DIR" "$C1_GOTO_REL" "$OUT/C1_BUILD.log"; echo "$?" > "$OUT/C1_BUILD.rc") &
  P1=$!
  (build_goto "$C2_DIR" "$C2_GOTO_REL" "$OUT/C2_BUILD.log"; echo "$?" > "$OUT/C2_BUILD.rc") &
  P2=$!
  wait "$P1" || true
  wait "$P2" || true

  if [[ ! -f "$C1_GOTO" || ! -f "$C2_GOTO" ]]; then
    echo "CONTROL_GOTO_GATE=FAIL"
    exit 26
  fi

  (run_cbmc "$C1_GOTO" "$OUT/C1_CBMC.log"; echo "$?" > "$OUT/C1_CBMC.rc") &
  P1=$!
  (run_cbmc "$C2_GOTO" "$OUT/C2_CBMC.log"; echo "$?" > "$OUT/C2_CBMC.rc") &
  P2=$!
  wait "$P1" || true
  wait "$P2" || true

  C1RC="$(cat "$OUT/C1_CBMC.rc")"
  C2RC="$(cat "$OUT/C2_CBMC.rc")"

  audit_control "MONT-T2.CONTROL.C1.same_fibre_branch_reachable" "$C1RC" "$OUT/C1_CBMC.log"
  C1A=$?
  audit_control "MONT-T2.CONTROL.C2.translation_path_reachable" "$C2RC" "$OUT/C2_CBMC.log"
  C2A=$?

  if [[ "$C1A" -ne 0 || "$C2A" -ne 0 ]]; then
    echo "T2_NONVACUITY_GATE=FAIL"
    exit 27
  fi

  echo "T2_NONVACUITY_GATE=PASS"

  section "A7 — FINAL INTEGRITY AND GATE-A VERDICT"

  FINAL_AUTH_H="$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")"
  FINAL_WORK_H="$(hash_file "$WORKTREE/mlkem/src/poly.h")"
  FINAL_AUTH_C="$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")"
  FINAL_WORK_C="$(hash_file "$WORKTREE/mlkem/src/poly.c")"

  if [[ "$FINAL_AUTH_H" != "$EXPECTED_POLY_H_SHA256" || "$FINAL_WORK_H" != "$EXPECTED_POLY_H_SHA256" || "$FINAL_AUTH_C" != "$EXPECTED_POLY_C_SHA256" || "$FINAL_WORK_C" != "$EXPECTED_POLY_C_SHA256" ]]; then
    echo "FINAL_SOURCE_INTEGRITY=FAIL"
    exit 28
  fi

  echo "FINAL_SOURCE_INTEGRITY=PASS"

  cat > "$OUT/MONT02A_GATE_A_BINDING.env" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H_SHA256=$EXPECTED_POLY_H_SHA256
EXPECTED_POLY_C_SHA256=$EXPECTED_POLY_C_SHA256
T1_CAPTURE_SHA256=$T1_HASH
A_HARNESS_SHA256=$(hash_file "$A_C")
A_MAKEFILE_SHA256=$(hash_file "$A_MK")
A_GOTO_SHA256=$(hash_file "$A_GOTO")
B_HARNESS_SHA256=$(hash_file "$B_C")
B_MAKEFILE_SHA256=$(hash_file "$B_MK")
B_GOTO_SHA256=$(hash_file "$B_GOTO")
MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS
EOF

  find "$OUT" -type f -print0 | sort -z | xargs -0 sha256sum > "$OUT/FILE_MANIFEST.sha256"

  echo "MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS"
  echo "MONT_T2_A_ARBITRARY_PAIR_LAWS=PASS"
  echo "MONT_T2_B_AFFINE_FIBRE_LAWS=PASS"
  echo "MONT_T2_C1_NONVACUITY=PASS"
  echo "MONT_T2_C2_NONVACUITY=PASS"
  echo "MONT_T2_STATUS=FUNCTIONAL_AND_NONVACUITY_ACCEPTED_PENDING_T2_MUTATIONS"
  echo "NEXT_GATE=MONT-02B_T2_SPECIFIC_MUTATIONS"
  echo "MONT02A_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

RC="${PIPESTATUS[0]}"
sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"

echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$RC"

exit "$RC"
