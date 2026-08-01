#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H_SHA256="f24f980110953c1d361e04137e13e2f85f76db776903f85f7aef"
EXPECTED_POLY_C_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

AUTHORITATIVE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WORKTREE="$ROOT/MONT_WORKTREE_af4c5abd"

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

LATEST_A_OUT="$(
  find "$ROOT" -maxdepth 1 -type d -name 'MONT02A_FULL_T2_FUNCTIONAL_*' -printf '%T@ %p\n' 2>/dev/null |
  sort -nr |
  head -n 1 |
  cut -d' ' -f2-
)"

BINDING="$LATEST_A_OUT/MONT02A_GATE_A_BINDING.env"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT02B_T2_MUTATIONS_$STAMP"
CAPTURE="$OUT/MONT02B_T2_MUTATIONS_CAPTURE_$STAMP.txt"

mkdir -p "$OUT/MUTATIONS"

section() {
  printf '\n============================================================\n'
  printf '%s\n' "$1"
  printf '============================================================\n'
}

hash_file() {
  sha256sum "$1" | awk '{print $1}'
}

remove_worktree() {
  local path="$1"

  if git -C "$AUTHORITATIVE" worktree list --porcelain | grep -Fxq "worktree $path"; then
    git -C "$AUTHORITATIVE" worktree remove --force "$path" >/dev/null 2>&1 || true
  fi

  if [[ -e "$path" ]]; then
    rm -rf "$path"
  fi

  git -C "$AUTHORITATIVE" worktree prune >/dev/null 2>&1 || true
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

patch_mutant() {
  local id="$1"
  local file="$2"

  python3 - "$id" "$file" <<'PY'
from pathlib import Path
import sys

mid = sys.argv[1]
p = Path(sys.argv[2])
s = p.read_text()

changes = {
    "M1_QINV_PLUS_ONE": (
        "a_reduced * QINV",
        "a_reduced * (QINV + 1)",
    ),
    "M2_RECONSTRUCTION_SIGN": (
        "r = a - ((int32_t)t * MLKEM_Q);",
        "r = a + ((int32_t)t * MLKEM_Q);",
    ),
    "M3_SHIFT_BY_15": (
        "r = r >> 16;",
        "r = r >> 15;",
    ),
}

old, new = changes[mid]
count = s.count(old)

print(f"{mid}_PATCH_MATCH_COUNT={count}")

if count != 1:
    print(f"{mid}_PATCH_APPLIED=NO")
    print(f"{mid}_DIAGNOSTIC_BEGIN")
    for n, line in enumerate(s.splitlines(), 1):
        if "a_reduced *" in line or "r = a " in line or "r = r >>" in line:
            print(f"{n}:{line}")
    print(f"{mid}_DIAGNOSTIC_END")
    raise SystemExit(2)

s = s.replace(old, new, 1)

if s.count(new) != 1:
    raise SystemExit("post-patch validation failed")

p.write_text(s)

print(f"{mid}_BEFORE={old}")
print(f"{mid}_AFTER={new}")
print(f"{mid}_PATCH_APPLIED=YES")
PY
}

audit_mutant() {
  local id="$1"
  local kind="$2"
  local rc="$3"
  local log="$4"

  python3 - "$id" "$kind" "$rc" "$log" <<'PY'
from pathlib import Path
import re
import sys

mid = sys.argv[1]
kind = sys.argv[2]
rc = int(sys.argv[3])
text = Path(sys.argv[4]).read_text(errors="replace")

prefix = "MONT-T2A." if kind == "A" else "MONT-T2B."
central = {
    "A": [
        "MONT-T2A.P3.arbitrary_pair_scaled_congruence",
        "MONT-T2A.P5.same_low_word_exact_output_delta",
    ],
    "B": [
        "MONT-T2B.P2.general_fibre_translation",
        "MONT-T2B.P3.exact_output_delta_equals_k",
    ],
}[kind]

failures = [
    line.strip() for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]
theorem = [x for x in failures if prefix in x]
central_failures = [x for x in failures if any(p in x for p in central)]

print(f"{mid}_DIRECT_RC={rc}")
print(f"{mid}_FAILURE_COUNT={len(failures)}")
print(f"{mid}_T2_THEOREM_FAILURE_COUNT={len(theorem)}")
print(f"{mid}_CENTRAL_T2_FAILURE_COUNT={len(central_failures)}")

for i, x in enumerate(failures, 1):
    print(f"{mid}_FAILURE_{i}={x}")

ok = (
    rc == 10
    and "VERIFICATION FAILED" in text
    and "VERIFICATION SUCCESSFUL" not in text
    and "VERIFICATION ERROR" not in text
    and theorem
    and central_failures
)

print(f"{mid}_MUTATION_AUDIT={'PASS' if ok else 'FAIL'}")
raise SystemExit(0 if ok else 5)
PY
}

run_mutant()
(
  ID="$1"
  KIND="$2"

  if [[ "$KIND" == "A" ]]; then
    BASE_DIR="$A_DIR"
    BASE_NAME="$A_NAME"
    BASE_C="$A_C"
    BASE_MK="$A_MK"
    GOTO_REL="$A_GOTO_REL"
  else
    BASE_DIR="$B_DIR"
    BASE_NAME="$B_NAME"
    BASE_C="$B_C"
    BASE_MK="$B_MK"
    GOTO_REL="$B_GOTO_REL"
  fi

  WT="$ROOT/${ID}_T2_WORKTREE_$STAMP"
  E="$OUT/MUTATIONS/$ID"
  PDIR="$WT/proofs/cbmc/$(basename "$BASE_DIR")"
  HC="$PDIR/$BASE_NAME.c"
  MK="$PDIR/Makefile"
  GOTO="$PDIR/$GOTO_REL"
  PH="$WT/mlkem/src/poly.h"
  PC="$WT/mlkem/src/poly.c"
  RCFILE="$OUT/$ID.rc"

  mkdir -p "$E"

  cleanup() {
    remove_worktree "$WT"
  }
  trap cleanup EXIT

  fail() {
    echo "$1" > "$RCFILE"
    echo "${ID}_RESULT=FAIL_CODE_$1"
    exit 0
  }

  section "$ID — ISOLATED T2 MUTATION"

  remove_worktree "$WT"

  git -C "$AUTHORITATIVE" worktree add --detach "$WT" "$EXPECTED_COMMIT" > "$E/worktree-add.log" 2>&1
  ADDRC=$?
  echo "${ID}_WORKTREE_ADD_RC=$ADDRC"
  [[ "$ADDRC" -eq 0 ]] || fail 31

  HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null || true)"
  echo "${ID}_HEAD=$HEAD"
  [[ "$HEAD" == "$EXPECTED_COMMIT" ]] || fail 32

  mkdir -p "$PDIR"
  cp "$BASE_C" "$HC"
  cp "$BASE_MK" "$MK"

  BH="$(hash_file "$BASE_C")"
  CH="$(hash_file "$HC")"
  BM="$(hash_file "$BASE_MK")"
  CM="$(hash_file "$MK")"

  echo "${ID}_BASE_HARNESS_SHA256=$BH"
  echo "${ID}_COPIED_HARNESS_SHA256=$CH"
  echo "${ID}_BASE_MAKEFILE_SHA256=$BM"
  echo "${ID}_COPIED_MAKEFILE_SHA256=$CM"

  [[ "$BH" == "$CH" && "$BM" == "$CM" ]] || fail 33

  PREH="$(hash_file "$PH")"
  PREC="$(hash_file "$PC")"

  echo "${ID}_PRE_POLY_H_SHA256=$PREH"
  echo "${ID}_PRE_POLY_C_SHA256=$PREC"

  [[ "$PREH" == "$EXPECTED_POLY_H_SHA256" && "$PREC" == "$EXPECTED_POLY_C_SHA256" ]] || fail 34

  patch_mutant "$ID" "$PH" > "$E/patch.log" 2>&1
  PRC=$?
  cat "$E/patch.log"
  echo "${ID}_PATCH_RC=$PRC"
  [[ "$PRC" -eq 0 ]] || fail 35

  POSTH="$(hash_file "$PH")"
  POSTC="$(hash_file "$PC")"

  echo "${ID}_POST_POLY_H_SHA256=$POSTH"
  echo "${ID}_POST_POLY_C_SHA256=$POSTC"

  git -C "$WT" diff -- mlkem/src/poly.h > "$E/source-mutation.diff"
  echo "${ID}_SOURCE_DIFF_BEGIN"
  cat "$E/source-mutation.diff"
  echo "${ID}_SOURCE_DIFF_END"

  mapfile -t MODS < <(git -C "$WT" diff --name-only)
  echo "${ID}_MODIFIED_FILE_COUNT=${#MODS[@]}"

  [[ "$POSTH" != "$PREH" && "$POSTC" == "$PREC" && "${#MODS[@]}" -eq 1 && "${MODS[0]}" == "mlkem/src/poly.h" ]] || fail 36

  build_goto "$PDIR" "$GOTO_REL" "$E/build.log"
  BRC=$?
  echo "${ID}_GOTO_BUILD_RC=$BRC"

  if [[ ! -f "$GOTO" ]]; then
    echo "${ID}_GOTO_PRESENT=NO"
    tail -n 100 "$E/build.log" || true
    fail 37
  fi

  echo "${ID}_GOTO_PRESENT=YES"
  echo "${ID}_GOTO_SHA256=$(hash_file "$GOTO")"

  run_cbmc "$GOTO" "$E/direct-cbmc.log"
  DRC=$?

  echo "${ID}_DIRECT_CBMC_RC_RAW=$DRC"
  echo "${ID}_KEY_RESULTS_BEGIN"
  grep -E 'MONT-T2A\.|MONT-T2B\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$' "$E/direct-cbmc.log" || true
  echo "${ID}_KEY_RESULTS_END"

  audit_mutant "$ID" "$KIND" "$DRC" "$E/direct-cbmc.log"
  ARC=$?
  echo "${ID}_AUDIT_RC=$ARC"

  cp "$PH" "$E/poly.h.MUTATED"
  cp "$HC" "$E/"
  cp "$MK" "$E/Makefile"
  cp "$GOTO" "$E/"

  [[ "$ARC" -eq 0 ]] || fail 38

  echo "${ID}_RESULT=EXPECTEDLY_REJECTED"
  echo "0" > "$RCFILE"
  exit 0
)

{
  section "MONT-02B — FULL LOCKED T2-SPECIFIC MUTATIONS"

  echo "UTC_TIME=$STAMP"
  echo "GATE_A_OUTPUT=$LATEST_A_OUT"

  section "B0 — BIND GATE A AND SOURCE"

  if [[ -z "$LATEST_A_OUT" || ! -f "$BINDING" ]]; then
    echo "GATE_A_BINDING_FILE_PRESENT=NO"
    exit 20
  fi

  # shellcheck disable=SC1090
  source "$BINDING"

  [[ "${MONT02A_FULL_T2_FUNCTIONAL_GATE:-}" == "PASS" ]] || {
    echo "GATE_A_STATUS_BINDING=FAIL"
    exit 21
  }

  AH="$(git -C "$AUTHORITATIVE" rev-parse HEAD 2>/dev/null || true)"
  WH="$(git -C "$WORKTREE" rev-parse HEAD 2>/dev/null || true)"
  AS="$(git -C "$AUTHORITATIVE" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

  [[ "$AH" == "$EXPECTED_COMMIT" && "$WH" == "$EXPECTED_COMMIT" && -z "$AS" ]] || {
    echo "COMMIT_OR_CLEAN_GATE=FAIL"
    exit 22
  }

  [[ "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")" == "$EXPECTED_POLY_H_SHA256" ]] || exit 23
  [[ "$(hash_file "$WORKTREE/mlkem/src/poly.h")" == "$EXPECTED_POLY_H_SHA256" ]] || exit 24
  [[ "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")" == "$EXPECTED_POLY_C_SHA256" ]] || exit 25
  [[ "$(hash_file "$WORKTREE/mlkem/src/poly.c")" == "$EXPECTED_POLY_C_SHA256" ]] || exit 26

  [[ "$(hash_file "$A_C")" == "$A_HARNESS_SHA256" ]] || exit 27
  [[ "$(hash_file "$A_MK")" == "$A_MAKEFILE_SHA256" ]] || exit 28
  [[ "$(hash_file "$A_GOTO")" == "$A_GOTO_SHA256" ]] || exit 29
  [[ "$(hash_file "$B_C")" == "$B_HARNESS_SHA256" ]] || exit 30
  [[ "$(hash_file "$B_MK")" == "$B_MAKEFILE_SHA256" ]] || exit 31
  [[ "$(hash_file "$B_GOTO")" == "$B_GOTO_SHA256" ]] || exit 32

  echo "GATE_A_ARTEFACT_BINDING=PASS"
  echo "SOURCE_BINDING_GATE=PASS"

  cp "$BINDING" "$OUT/BOUND_GATE_A_BINDING.env"

  section "B1 — RUN M1 AND M2 IN PARALLEL"

  run_mutant "M1_QINV_PLUS_ONE" "A" > "$OUT/M1_SUMMARY.log" 2>&1 &
  P1=$!
  run_mutant "M2_RECONSTRUCTION_SIGN" "A" > "$OUT/M2_SUMMARY.log" 2>&1 &
  P2=$!

  wait "$P1" || true
  wait "$P2" || true

  cat "$OUT/M1_SUMMARY.log"
  cat "$OUT/M2_SUMMARY.log"

  section "B2 — RUN M3"

  run_mutant "M3_SHIFT_BY_15" "B" > "$OUT/M3_SUMMARY.log" 2>&1 &
  P3=$!
  wait "$P3" || true
  cat "$OUT/M3_SUMMARY.log"

  M1RC="$(cat "$OUT/M1_QINV_PLUS_ONE.rc" 2>/dev/null || echo 99)"
  M2RC="$(cat "$OUT/M2_RECONSTRUCTION_SIGN.rc" 2>/dev/null || echo 99)"
  M3RC="$(cat "$OUT/M3_SHIFT_BY_15.rc" 2>/dev/null || echo 99)"

  echo "M1_FINAL_RC=$M1RC"
  echo "M2_FINAL_RC=$M2RC"
  echo "M3_FINAL_RC=$M3RC"

  if [[ "$M1RC" -ne 0 || "$M2RC" -ne 0 || "$M3RC" -ne 0 ]]; then
    echo "MONT02B_T2_MUTATION_GATE=FAIL"
    exit 33
  fi

  section "B3 — FINAL INTEGRITY AND T2 ACCEPTANCE"

  FINAL_AH="$(git -C "$AUTHORITATIVE" rev-parse HEAD 2>/dev/null || true)"
  FINAL_WH="$(git -C "$WORKTREE" rev-parse HEAD 2>/dev/null || true)"
  FINAL_AS="$(git -C "$AUTHORITATIVE" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

  if [[ "$FINAL_AH" != "$EXPECTED_COMMIT" || "$FINAL_WH" != "$EXPECTED_COMMIT" || -n "$FINAL_AS" ]]; then
    echo "FINAL_COMMIT_AND_CLEAN_GATE=FAIL"
    exit 34
  fi

  if [[ "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")" != "$EXPECTED_POLY_H_SHA256" || "$(hash_file "$WORKTREE/mlkem/src/poly.h")" != "$EXPECTED_POLY_H_SHA256" || "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")" != "$EXPECTED_POLY_C_SHA256" || "$(hash_file "$WORKTREE/mlkem/src/poly.c")" != "$EXPECTED_POLY_C_SHA256" ]]; then
    echo "FINAL_SOURCE_INTEGRITY=FAIL"
    exit 35
  fi

  REMAINING="$(
    git -C "$AUTHORITATIVE" worktree list --porcelain |
    sed -n 's/^worktree //p' |
    grep -E '/M[123]_(QINV_PLUS_ONE|RECONSTRUCTION_SIGN|SHIFT_BY_15)_T2_WORKTREE_' ||
    true
  )"

  if [[ -n "$REMAINING" ]]; then
    echo "MUTANT_WORKTREE_CLEANUP=FAIL"
    printf '%s\n' "$REMAINING"
    exit 36
  fi

  echo "FINAL_COMMIT_AND_CLEAN_GATE=PASS"
  echo "FINAL_SOURCE_INTEGRITY=PASS"
  echo "MUTANT_WORKTREE_CLEANUP=PASS"

  find "$OUT" -type f -print0 | sort -z | xargs -0 sha256sum > "$OUT/FILE_MANIFEST.sha256"

  echo "MONT02B_T2_MUTATION_GATE=PASS_3_OF_3"
  echo "MONT02_FULL_POWER_T2_GATE=PASS"
  echo "MONT_T2_A_ARBITRARY_PAIR_LAWS=PASS"
  echo "MONT_T2_B_AFFINE_FIBRE_LAWS=PASS"
  echo "MONT_T2_C1_NONVACUITY=PASS"
  echo "MONT_T2_C2_NONVACUITY=PASS"
  echo "MONT_T2_MUTATION_SENSITIVITY=PASS_3_OF_3"
  echo "MONT_T2_SOURCE_BINDING=PASS"
  echo "MONT_T2_STATUS=ACCEPTED_FOR_PINNED_COMMIT"
  echo "NEXT_CAMPAIGN=MONT-T3"
  echo "MONT02B_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

RC="${PIPESTATUS[0]}"
sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"

echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$RC"

exit "$RC"
