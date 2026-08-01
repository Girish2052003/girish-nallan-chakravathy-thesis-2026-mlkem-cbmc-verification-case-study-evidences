#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H_SHA256="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_T1_CAPTURE_SHA256="866ba00a16a8d46595c4abe04456f7f3360600ac0c34ad826a34741c035b8813"
EXPECTED_A_HARNESS_SHA256="b63d2c34e4395de62e71484d6e46462c028962750afbbd2cd1f2dd12420e7144"
EXPECTED_A_GOTO_SHA256="422d8bda32008a1d99732999147f75230e7efab61e1716986ef5259ee02dd412"
EXPECTED_B_HARNESS_SHA256="219a9a8e41d0066b2068f8bef0f149aa76aabb8d48dda8f365f2bc08f65df503"
EXPECTED_B_GOTO_SHA256="148d35e8a0fa9b09a58a674b7a403917a278ed9846f04a1cc75779e6f03eb8aa"
EXPECTED_PRIOR_GATE_A_CAPTURE_SHA256="357e891022deb9377ca03caa695dcbacb6fb389824c771719715fd967598d2ce"
EXPECTED_PRIOR_R1_CAPTURE_SHA256="8e417faf0e756b2cc01c4cd165662bc06742813639fa2b07eca5137d1eb16786"

AUTHORITATIVE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WORKTREE="$ROOT/MONT_WORKTREE_af4c5abd"

T1_CAPTURE="$ROOT/MONT01B_R1_M2_M3_20260726T151104Z/MONT01B_R1_TERMINAL_CAPTURE_20260726T151104Z.txt"
PRIOR_GATE_A_CAPTURE="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_20260726T170048Z/MONT02A_FULL_T2_CAPTURE_20260726T170048Z.txt"
PRIOR_R1_CAPTURE="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_20260726T175148Z/MONT02A_R1_SHARDED_CAPTURE_20260726T175148Z.txt"

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
CAPTURE="$OUT/MONT02A_R3_SOLVER_RACE_CAPTURE_$STAMP.txt"
BACKEND_TIMEOUT=300
PROBE_TIMEOUT=30

mkdir -p "$OUT/BACKENDS"

section() {
  printf '\n============================================================\n'
  printf '%s\n' "$1"
  printf '============================================================\n'
}

hash_file() {
  sha256sum "$1" | awk '{print $1}'
}

show_properties() {
  cbmc --show-properties "$1" > "$2" 2>&1
}

find_property_id() {
  python3 - "$1" "$2" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(errors="replace")
target = sys.argv[2]
current = None
matches = []
for line in text.splitlines():
    m = re.match(r"^Property\s+([^:]+):\s*$", line)
    if m:
        current = m.group(1)
        continue
    if current is not None and target in line:
        matches.append(current)
if len(matches) != 1:
    print(f"PROPERTY_LOOKUP_COUNT={len(matches)}", file=sys.stderr)
    raise SystemExit(2)
print(matches[0])
PY
}

run_solver() {
  local backend_name="$1"
  local property_id="$2"
  local timeout_seconds="$3"
  local log_file="$4"
  shift 4
  local -a backend_flags=("$@")

  timeout "$timeout_seconds" cbmc \
    --flush \
    --object-bits 8 \
    --slice-formula \
    --property "$property_id" \
    "${backend_flags[@]}" \
    "$A_GOTO" > "$log_file" 2>&1
  return $?
}

backend_passed() {
  local rc="$1"
  local log_file="$2"
  local required_description="$3"

  [[ "$rc" -eq 0 ]] || return 1
  grep -Fq "$required_description: SUCCESS" "$log_file" || return 1
  grep -Fq "VERIFICATION SUCCESSFUL" "$log_file" || return 1
  ! grep -Fq "VERIFICATION FAILED" "$log_file" || return 1
  ! grep -Fq "VERIFICATION ERROR" "$log_file" || return 1
  return 0
}

probe_backend() {
  local name="$1"
  local easy_property="$2"
  shift 2
  local -a flags=("$@")
  local log="$OUT/BACKENDS/PROBE_${name}.log"

  run_solver "$name" "$easy_property" "$PROBE_TIMEOUT" "$log" "${flags[@]}"
  local rc=$?
  printf '%s' "$rc" > "$OUT/BACKENDS/PROBE_${name}.rc"

  if backend_passed "$rc" "$log" "MONT-T2A.P1.first_low_word_normalized"; then
    echo "BACKEND_PROBE=$name|AVAILABLE=YES|RC=$rc"
    return 0
  fi

  echo "BACKEND_PROBE=$name|AVAILABLE=NO|RC=$rc"
  return 1
}

run_backend_candidate() {
  local name="$1"
  local p3_property="$2"
  shift 2
  local -a flags=("$@")
  local log="$OUT/BACKENDS/P3_${name}.log"

  run_solver "$name" "$p3_property" "$BACKEND_TIMEOUT" "$log" "${flags[@]}"
  local rc=$?
  printf '%s' "$rc" > "$OUT/BACKENDS/P3_${name}.rc"

  if backend_passed "$rc" "$log" "MONT-T2A.P3.arbitrary_pair_scaled_congruence"; then
    echo "P3_BACKEND_RESULT=$name|RC=$rc|PASS=YES" > "$OUT/BACKENDS/P3_${name}.summary"
  else
    local failure_count
    failure_count="$(grep -Ec ': FAILURE$' "$log" || true)"
    echo "P3_BACKEND_RESULT=$name|RC=$rc|PASS=NO|FAILURE_COUNT=$failure_count" > "$OUT/BACKENDS/P3_${name}.summary"
  fi
}

create_control_makefile() {
  local base_makefile="$1"
  local output_makefile="$2"
  local old_name="$3"
  local new_name="$4"
  local old_uid="$5"
  local new_uid="$6"

  cp "$base_makefile" "$output_makefile"
  python3 - "$output_makefile" "$old_name" "$new_name" "$old_uid" "$new_uid" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
old_name, new_name, old_uid, new_uid = sys.argv[2:]
s = p.read_text()
if old_name not in s:
    raise SystemExit("old harness token missing")
s = s.replace(old_name, new_name)
s = s.replace(old_uid, new_uid)
s = s.replace("CBMCFLAGS = --smt2", "CBMCFLAGS =")
if old_name in s or new_name not in s:
    raise SystemExit("control Makefile validation failed")
p.write_text(s)
PY
}

build_goto() {
  local dir="$1"
  local log="$2"
  make -C "$dir" MLKEM_K=3 clean > "$log.clean" 2>&1 || true
  timeout 300 make -C "$dir" MLKEM_K=3 goto > "$log" 2>&1
  return $?
}

run_control() {
  local goto_file="$1"
  local property_id="$2"
  local log_file="$3"
  timeout 300 cbmc \
    --flush \
    --object-bits 8 \
    --slice-formula \
    --property "$property_id" \
    --trace \
    "$goto_file" > "$log_file" 2>&1
  return $?
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
failures = [x.strip() for x in text.splitlines() if re.search(r": FAILURE\s*$", x)]
expected_failures = [x for x in failures if expected in x]
unexpected = [x for x in failures if expected not in x]
ok = (
    rc == 10
    and "VERIFICATION FAILED" in text
    and "VERIFICATION SUCCESSFUL" not in text
    and "VERIFICATION ERROR" not in text
    and len(expected_failures) == 1
    and not unexpected
)
print(f"CONTROL_EXPECTED={expected}")
print(f"CONTROL_RC={rc}")
print(f"CONTROL_FAILURE_COUNT={len(failures)}")
print(f"CONTROL_EXPECTED_FAILURE_COUNT={len(expected_failures)}")
print(f"CONTROL_UNEXPECTED_FAILURE_COUNT={len(unexpected)}")
print(f"CONTROL_AUDIT={'PASS' if ok else 'FAIL'}")
raise SystemExit(0 if ok else 5)
PY
}

{
  section "MONT-02A-R3 — EXACT ORIGINAL P3 SOLVER RACE + BOTH CONTROLS"
  echo "UTC_TIME=$STAMP"
  echo "OUTPUT_DIRECTORY=$OUT"
  echo "THEOREM_ENCODING=ORIGINAL_FROZEN_T2A_P3"
  echo "THEOREM_DOMAIN=FULL_ARBITRARY_PAIR"
  echo "BACKEND_TIMEOUT=$BACKEND_TIMEOUT"

  section "R0 — BIND SOURCE, T1, PRIOR 19/20, T2-B, AND ORIGINAL GOTO"

  AH="$(git -C "$AUTHORITATIVE" rev-parse HEAD 2>/dev/null || true)"
  WH="$(git -C "$WORKTREE" rev-parse HEAD 2>/dev/null || true)"
  AS="$(git -C "$AUTHORITATIVE" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

  [[ "$AH" == "$EXPECTED_COMMIT" && "$WH" == "$EXPECTED_COMMIT" && -z "$AS" ]] || { echo "COMMIT_AND_CLEAN_GATE=FAIL"; exit 20; }

  [[ "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")" == "$EXPECTED_POLY_H_SHA256" ]] || exit 21
  [[ "$(hash_file "$WORKTREE/mlkem/src/poly.h")" == "$EXPECTED_POLY_H_SHA256" ]] || exit 22
  [[ "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")" == "$EXPECTED_POLY_C_SHA256" ]] || exit 23
  [[ "$(hash_file "$WORKTREE/mlkem/src/poly.c")" == "$EXPECTED_POLY_C_SHA256" ]] || exit 24

  [[ "$(hash_file "$T1_CAPTURE")" == "$EXPECTED_T1_CAPTURE_SHA256" ]] || exit 25
  grep -Fxq "MONT_T1_STATUS=ACCEPTED_FOR_PINNED_COMMIT" "$T1_CAPTURE" || exit 26

  [[ "$(hash_file "$PRIOR_GATE_A_CAPTURE")" == "$EXPECTED_PRIOR_GATE_A_CAPTURE_SHA256" ]] || exit 27
  grep -Fxq "T2_B_FUNCTIONAL_AUDIT=PASS" "$PRIOR_GATE_A_CAPTURE" || exit 28

  [[ "$(hash_file "$PRIOR_R1_CAPTURE")" == "$EXPECTED_PRIOR_R1_CAPTURE_SHA256" ]] || exit 29
  grep -Fxq "T2_A_PROPERTY_PASS_COUNT=19" "$PRIOR_R1_CAPTURE" || exit 30
  grep -Fxq "T2_A_PROPERTY_FAILURE_COUNT=0" "$PRIOR_R1_CAPTURE" || exit 31
  grep -Fxq "PROPERTY_RESULT=harness.assertion.3|RC=124|PASS=NO" "$PRIOR_R1_CAPTURE" || exit 32

  [[ "$(hash_file "$A_C")" == "$EXPECTED_A_HARNESS_SHA256" ]] || exit 33
  [[ "$(hash_file "$A_GOTO")" == "$EXPECTED_A_GOTO_SHA256" ]] || exit 34
  [[ "$(hash_file "$B_C")" == "$EXPECTED_B_HARNESS_SHA256" ]] || exit 35
  [[ "$(hash_file "$B_GOTO")" == "$EXPECTED_B_GOTO_SHA256" ]] || exit 36

  echo "COMMIT_AND_CLEAN_GATE=PASS"
  echo "SOURCE_BINDING_GATE=PASS"
  echo "ACCEPTED_T1_BINDING_GATE=PASS"
  echo "T2_A_PRIOR_19_OF_20_BINDING=PASS"
  echo "T2_B_FUNCTIONAL_AUDIT=PASS"
  echo "ORIGINAL_T2_A_HARNESS_AND_GOTO_BINDING=PASS"

  section "R1 — LOCATE ORIGINAL P3 PROPERTY"

  show_properties "$A_GOTO" "$OUT/A_PROPERTIES.txt"
  SHOW_RC=$?
  echo "SHOW_PROPERTIES_RC=$SHOW_RC"
  [[ "$SHOW_RC" -eq 0 ]] || exit 37

  EASY_PROPERTY="$(find_property_id "$OUT/A_PROPERTIES.txt" "MONT-T2A.P1.first_low_word_normalized")"
  P3_PROPERTY="$(find_property_id "$OUT/A_PROPERTIES.txt" "MONT-T2A.P3.arbitrary_pair_scaled_congruence")"

  echo "EASY_PROPERTY_ID=$EASY_PROPERTY"
  echo "P3_PROPERTY_ID=$P3_PROPERTY"
  [[ -n "$EASY_PROPERTY" && -n "$P3_PROPERTY" ]] || exit 38

  section "R2 — PROBE ALTERNATIVE EXACT SOLVER BACKENDS"

  AVAILABLE_NAMES=()
  AVAILABLE_FLAGS=()

  if probe_backend "BOOLECTOR" "$EASY_PROPERTY" --boolector; then AVAILABLE_NAMES+=("BOOLECTOR"); AVAILABLE_FLAGS+=("--boolector"); fi
  if probe_backend "BITWUZLA" "$EASY_PROPERTY" --bitwuzla; then AVAILABLE_NAMES+=("BITWUZLA"); AVAILABLE_FLAGS+=("--bitwuzla"); fi
  if probe_backend "Z3" "$EASY_PROPERTY" --z3; then AVAILABLE_NAMES+=("Z3"); AVAILABLE_FLAGS+=("--z3"); fi
  if probe_backend "CVC5" "$EASY_PROPERTY" --cvc5; then AVAILABLE_NAMES+=("CVC5"); AVAILABLE_FLAGS+=("--cvc5"); fi
  if probe_backend "CPROVER_SMT2" "$EASY_PROPERTY" --cprover-smt2; then AVAILABLE_NAMES+=("CPROVER_SMT2"); AVAILABLE_FLAGS+=("--cprover-smt2"); fi
  if probe_backend "REFINE_ARITH" "$EASY_PROPERTY" --refine --refine-arithmetic; then AVAILABLE_NAMES+=("REFINE_ARITH"); AVAILABLE_FLAGS+=("--refine --refine-arithmetic"); fi

  echo "AVAILABLE_BACKEND_COUNT=${#AVAILABLE_NAMES[@]}"
  [[ "${#AVAILABLE_NAMES[@]}" -gt 0 ]] || { echo "P3_SOLVER_BACKEND_GATE=NO_AVAILABLE_ALTERNATIVE"; exit 39; }

  section "R3 — RACE ORIGINAL P3 ON AVAILABLE BACKENDS"

  start_index=0
  P3_WINNER=""

  while [[ "$start_index" -lt "${#AVAILABLE_NAMES[@]}" && -z "$P3_WINNER" ]]; do
    PIDS=()
    GROUP_NAMES=()

    for offset in 0 1; do
      idx=$((start_index + offset))
      if [[ "$idx" -ge "${#AVAILABLE_NAMES[@]}" ]]; then
        continue
      fi

      name="${AVAILABLE_NAMES[$idx]}"
      flags_string="${AVAILABLE_FLAGS[$idx]}"
      read -r -a flags_array <<< "$flags_string"

      (run_backend_candidate "$name" "$P3_PROPERTY" "${flags_array[@]}") &
      PIDS+=("$!")
      GROUP_NAMES+=("$name")
    done

    for pid in "${PIDS[@]}"; do
      wait "$pid" || true
    done

    for name in "${GROUP_NAMES[@]}"; do
      cat "$OUT/BACKENDS/P3_${name}.summary"
      if grep -Fq "PASS=YES" "$OUT/BACKENDS/P3_${name}.summary"; then
        P3_WINNER="$name"
        break
      fi
    done

    start_index=$((start_index + 2))
  done

  if [[ -z "$P3_WINNER" ]]; then
    echo "T2_A_P3_ORIGINAL_THEOREM_GATE=INCONCLUSIVE_NO_BACKEND_FINISHED"
    exit 40
  fi

  echo "P3_WINNING_BACKEND=$P3_WINNER"
  echo "T2_A_P3_ORIGINAL_THEOREM_GATE=PASS"
  echo "T2_A_P3_ORIGINAL_CONGRUENCE=DIRECTLY_VERIFIED_ON_ORIGINAL_GOTO"

  section "R4 — CREATE TWO ORIGINAL DISTINCT NON-VACUITY CONTROLS"

  rm -rf "$C1_DIR" "$C2_DIR"
  mkdir -p "$C1_DIR" "$C2_DIR"
  cp "$A_C" "$C1_C"
  cp "$B_C" "$C2_C"

  create_control_makefile "$A_MK" "$C1_MK" "$A_NAME" "$C1_NAME" "MONT-T2A arbitrary-pair relational laws" "MONT-T2 C1 same-fibre control"
  create_control_makefile "$B_MK" "$C2_MK" "$B_NAME" "$C2_NAME" "MONT-T2B affine fibre laws" "MONT-T2 C2 translation control"

  python3 - "$C1_C" "$C2_C" <<'PY'
from pathlib import Path
import sys

c1 = Path(sys.argv[1])
c2 = Path(sys.argv[2])
s1 = c1.read_text()
s2 = c2.read_text()
m1 = "    /* C1_CONTROL */"
m2 = "  /* C2_CONTROL */"
if s1.count(m1) != 1:
    raise SystemExit("C1 marker invalid")
if s2.count(m2) != 1:
    raise SystemExit("C2 marker invalid")
s1 = s1.replace(m1, '''    __CPROVER_assert(
        0,
        "MONT-T2.CONTROL.C1.same_fibre_branch_reachable");''')
s2 = s2.replace(m2, '''  __CPROVER_assert(
      0,
      "MONT-T2.CONTROL.C2.translation_path_reachable");''')
c1.write_text(s1)
c2.write_text(s2)
PY

  (build_goto "$C1_DIR" "$OUT/C1_BUILD.log"; echo "$?" > "$OUT/C1_BUILD.rc") & P1=$!
  (build_goto "$C2_DIR" "$OUT/C2_BUILD.log"; echo "$?" > "$OUT/C2_BUILD.rc") & P2=$!
  wait "$P1" || true
  wait "$P2" || true

  [[ -f "$C1_GOTO" && -f "$C2_GOTO" ]] || { echo "CONTROL_GOTO_GATE=FAIL"; exit 41; }

  show_properties "$C1_GOTO" "$OUT/C1_PROPERTIES.txt"
  show_properties "$C2_GOTO" "$OUT/C2_PROPERTIES.txt"
  C1_PROPERTY="$(find_property_id "$OUT/C1_PROPERTIES.txt" "MONT-T2.CONTROL.C1.same_fibre_branch_reachable")"
  C2_PROPERTY="$(find_property_id "$OUT/C2_PROPERTIES.txt" "MONT-T2.CONTROL.C2.translation_path_reachable")"

  (run_control "$C1_GOTO" "$C1_PROPERTY" "$OUT/C1_CBMC.log"; echo "$?" > "$OUT/C1_CBMC.rc") & P1=$!
  (run_control "$C2_GOTO" "$C2_PROPERTY" "$OUT/C2_CBMC.log"; echo "$?" > "$OUT/C2_CBMC.rc") & P2=$!
  wait "$P1" || true
  wait "$P2" || true

  C1_RC="$(cat "$OUT/C1_CBMC.rc")"
  C2_RC="$(cat "$OUT/C2_CBMC.rc")"

  audit_control "MONT-T2.CONTROL.C1.same_fibre_branch_reachable" "$C1_RC" "$OUT/C1_CBMC.log"
  C1_AUDIT=$?
  audit_control "MONT-T2.CONTROL.C2.translation_path_reachable" "$C2_RC" "$OUT/C2_CBMC.log"
  C2_AUDIT=$?

  [[ "$C1_AUDIT" -eq 0 && "$C2_AUDIT" -eq 0 ]] || { echo "T2_NONVACUITY_GATE=FAIL"; exit 42; }
  echo "C1_NONVACUITY_AUDIT=PASS"
  echo "C2_NONVACUITY_AUDIT=PASS"

  section "R5 — FINAL FULL GATE-A ACCEPTANCE"

  [[ "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")" == "$EXPECTED_POLY_H_SHA256" ]] || exit 43
  [[ "$(hash_file "$WORKTREE/mlkem/src/poly.h")" == "$EXPECTED_POLY_H_SHA256" ]] || exit 44
  [[ "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")" == "$EXPECTED_POLY_C_SHA256" ]] || exit 45
  [[ "$(hash_file "$WORKTREE/mlkem/src/poly.c")" == "$EXPECTED_POLY_C_SHA256" ]] || exit 46

  echo "FINAL_SOURCE_INTEGRITY=PASS"

  cat > "$OUT/MONT02A_GATE_A_BINDING.env" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H_SHA256=$EXPECTED_POLY_H_SHA256
EXPECTED_POLY_C_SHA256=$EXPECTED_POLY_C_SHA256
T1_CAPTURE_SHA256=$(hash_file "$T1_CAPTURE")
A_HARNESS_SHA256=$(hash_file "$A_C")
A_MAKEFILE_SHA256=$(hash_file "$A_MK")
A_GOTO_SHA256=$(hash_file "$A_GOTO")
B_HARNESS_SHA256=$(hash_file "$B_C")
B_MAKEFILE_SHA256=$(hash_file "$B_MK")
B_GOTO_SHA256=$(hash_file "$B_GOTO")
MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS
EOF

  cp "$PRIOR_R1_CAPTURE" "$OUT/BOUND_PRIOR_T2A_19_OF_20_CAPTURE.txt"
  cp "$PRIOR_GATE_A_CAPTURE" "$OUT/BOUND_PRIOR_T2B_PASS_CAPTURE.txt"
  find "$OUT" -type f -print0 | sort -z | xargs -0 sha256sum > "$OUT/FILE_MANIFEST.sha256"

  echo "T2_A_ALL_ORIGINAL_PROPERTIES_CHECKED=YES"
  echo "T2_A_FUNCTIONAL_AUDIT=PASS"
  echo "T2_B_FUNCTIONAL_AUDIT=PASS"
  echo "MONT_T2_C1_NONVACUITY=PASS"
  echo "MONT_T2_C2_NONVACUITY=PASS"
  echo "MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS"
  echo "MONT_T2_STATUS=FUNCTIONAL_AND_NONVACUITY_ACCEPTED_PENDING_T2_MUTATIONS"
  echo "NEXT_GATE=MONT-02B_T2_SPECIFIC_MUTATIONS"
  echo "MONT02A_R3_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

RC="${PIPESTATUS[0]}"
sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$RC"
exit "$RC"
