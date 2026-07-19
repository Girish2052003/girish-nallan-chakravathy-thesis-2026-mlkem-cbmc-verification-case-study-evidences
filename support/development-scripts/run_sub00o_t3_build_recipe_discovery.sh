#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
T3FREEZE="$ROOT/SUB00N_BATCH3_T3_HARNESS_FREEZE_V1"
T3MANIFEST="$T3FREEZE/SUB00N_ARTIFACT_MANIFEST.sha256"
START_GATE="/home/girish/SUB00N_T3_FINAL_START_GATE_VALID.txt"

OUT="$ROOT/SUB00O_BATCH3_T3_GOTO_PREFLIGHT_DISCOVERY"
REPORT="$OUT/SUB00O_BUILD_RECIPE_DISCOVERY.txt"
RUNNER_INDEX="$OUT/KNOWN_GOOD_RUNNER_INDEX.txt"
HARNESS_INDEX="$OUT/T3_HARNESS_INDEX.txt"
MANIFEST="$OUT/SUB00O_DISCOVERY_MANIFEST.sha256"

fail() {
  echo "SUB00O_DISCOVERY_STATUS=FAIL" >&2
  echo "REASON=$*" >&2
  exit 1
}

test -d "$ROOT" || fail "campaign root missing"
test -d "$T3FREEZE" || fail "SUB00N freeze directory missing"
test -f "$T3MANIFEST" || fail "SUB00N manifest missing"
test -f "$START_GATE" || fail "valid T3 start-gate record missing"
test ! -e "$OUT" || fail "output already exists; nothing overwritten: $OUT"

grep -qx 'T3_START_GATE=PASS' "$START_GATE" ||
  fail "start-gate record does not contain exact PASS"

ACTIVE="$(
  pgrep -af 'cbmc|goto-cc|goto-gcc|goto-clang' 2>/dev/null || true
)"
if [ -n "$ACTIVE" ]; then
  printf '%s\n' "$ACTIVE" >&2
  fail "formal-tool process is active"
fi

echo "=== VERIFY SUB00N PARENT MANIFEST ==="
(
  cd "$T3FREEZE"
  sha256sum -c "$(basename "$T3MANIFEST")"
)

mkdir -p "$OUT"

{
  echo "SUB00O KNOWN-GOOD RUNNER INDEX"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"
  echo

  find "$ROOT" -maxdepth 8 -type f \
    \( -name 'executed_runner.sh' \
       -o -name 'executed_preflight_runner.sh' \
       -o -name '*runner*.sh' \
       -o -name '*command*.txt' \
       -o -name 'MODEL_RECORD.txt' \
       -o -name '*PREFLIGHT_MANIFEST*.md' \) \
    -print 2>/dev/null |
  sort |
  while IFS= read -r f; do
    if grep -qiE \
      'goto-cc|goto-gcc|goto-clang|cbmc|MLKEM_K|MLKEM768|MLK_NAMESPACE|poly_sub|poly_reduce' \
      "$f" 2>/dev/null; then
      echo "============================================================"
      echo "FILE=$f"
      echo "SHA256=$(sha256sum "$f" | awk '{print $1}')"
      echo
      grep -nEi \
        'goto-cc|goto-gcc|goto-clang|cbmc|MLKEM_K|MLKEM768|MLK_NAMESPACE|MLK_CONFIG|object-bits|unwindset|poly_sub|poly_add|poly_reduce|(^|[[:space:]])-I|(^|[[:space:]])-D' \
        "$f" 2>/dev/null |
      head -400 || true
      echo
    fi
  done
} > "$RUNNER_INDEX"

{
  echo "SUB00O T3 HARNESS INDEX"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"
  echo

  find "$T3FREEZE/harnesses" -maxdepth 1 -type f \
    -printf '%f\n' |
  sort |
  while IFS= read -r name; do
    path="$T3FREEZE/harnesses/$name"
    echo "============================================================"
    echo "FILE=$name"
    echo "SIZE=$(stat -c '%s' "$path")"
    echo "MODE=$(stat -c '%A' "$path")"
    echo "SHA256=$(sha256sum "$path" | awk '{print $1}')"
    echo
    grep -nE \
      '__CPROVER_(assume|assert|cover)|mlk_poly_(add|sub|reduce)|int main|SUB_T3_' \
      "$path" 2>/dev/null || true
    echo
  done
} > "$HARNESS_INDEX"

{
  echo "============================================================"
  echo "SUB00O / BATCH 3 — T3 GOTO PREFLIGHT DISCOVERY"
  echo "============================================================"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"
  echo "ROOT=$ROOT"
  echo "T3FREEZE=$T3FREEZE"
  echo "START_GATE=$START_GATE"
  echo

  echo "=== GATE O.0-A: PROCESS CLEANLINESS ==="
  echo "PASS NO_FORMAL_TOOL_PROCESS_RUNNING"
  echo

  echo "=== GATE O.0-B: START-GATE IDENTITY ==="
  sha256sum "$START_GATE"
  grep -E \
    'PROCESS_CLEANLINESS|STATIC_FREEZE_VALIDATION|CBMC_EXECUTION_PERFORMED|PRODUCTION_SOURCE_MODIFIED|T3_START_GATE|SUB00O_GOTO_PREFLIGHT' \
    "$START_GATE" || true
  echo

  echo "=== GATE O.0-C: SUB00N FREEZE IDENTITY ==="
  sha256sum "$T3MANIFEST"
  cat "$T3FREEZE/FREEZE_VALIDATION.txt"
  echo

  echo "=== GATE O.0-D: TOOL IDENTITY ==="
  printf 'CBMC_PATH='
  command -v cbmc
  printf 'CBMC_VERSION='
  cbmc --version 2>&1 | head -1
  printf 'GOTO_CC_PATH='
  command -v goto-cc
  printf 'GCC_VERSION='
  gcc --version 2>&1 | head -1
  printf 'PYTHON_VERSION='
  python3 --version 2>&1
  printf 'ARCH='
  uname -m
  echo

  echo "=== GATE O.0-E: PRODUCTION SOURCE IDENTITY ==="
  for f in \
    "$ROOT/source/mlkem/src/poly.c" \
    "$ROOT/source/mlkem/src/poly.h"
  do
    test -f "$f" || fail "production file missing: $f"
    sha256sum "$f"
  done
  echo

  echo "=== GATE O.0-F: T3 HARNESS COUNTS ==="
  C_COUNT="$(find "$T3FREEZE/harnesses" -maxdepth 1 -type f -name '*.c' | wc -l)"
  H_COUNT="$(find "$T3FREEZE/harnesses" -maxdepth 1 -type f -name '*.h' | wc -l)"
  echo "C_HARNESS_COUNT=$C_COUNT"
  echo "HEADER_COUNT=$H_COUNT"
  test "$C_COUNT" -eq 13 || fail "unexpected C harness count"
  test "$H_COUNT" -eq 1 || fail "unexpected header count"
  echo

  echo "=== GATE O.0-G: PRIOR MLKEM768 MODEL DIRECTORIES ==="
  find "$ROOT" -maxdepth 8 -type f -name '*.goto' \
    -printf '%TY-%Tm-%Td %TH:%TM:%TS %s %p\n' 2>/dev/null |
  sort |
  tail -100
  echo

  echo "=== GATE O.0-H: EXACT PRIOR T2 RUNNER CANDIDATES ==="
  find "$ROOT/SUB00L_COMBINED_T2_BOUNDARY_EXECUTION_MLKEM768_RUN1" \
    -maxdepth 5 -type f \
    \( -name 'executed_runner.sh' \
       -o -name '*command*.txt' \
       -o -name 'MODEL_RECORD.txt' \
       -o -name '*manifest*' \) \
    -print 2>/dev/null |
  sort |
  while IFS= read -r f; do
    echo "------------------------------------------------------------"
    echo "FILE=$f"
    sha256sum "$f"
    grep -nEi \
      'goto-cc|cbmc|MLKEM_K|MLKEM768|MLK_NAMESPACE|object-bits|unwindset|(^|[[:space:]])-I|(^|[[:space:]])-D|poly_sub|poly_reduce' \
      "$f" 2>/dev/null |
    head -300 || true
  done
  echo

  echo "=== GATE O.0-I: BUILD-RECIPE AMBIGUITY TEST ==="
  GOTO_CC_REFERENCE_COUNT="$(
    grep -RIlE 'goto-cc|goto-gcc|goto-clang' \
      "$ROOT/SUB00L_COMBINED_T2_BOUNDARY_EXECUTION_MLKEM768_RUN1" \
      "$ROOT/SUB00J_MUTATION_PREFLIGHT_PRAGMA_SCOPED_MLKEM768" \
      "$ROOT/SUB00G_R2_T1_PRAGMA_SCOPED_PREFLIGHT_MLKEM768" \
      2>/dev/null |
    wc -l
  )"
  echo "FILES_WITH_GOTO_COMPILER_REFERENCE=$GOTO_CC_REFERENCE_COUNT"

  if [ "$GOTO_CC_REFERENCE_COUNT" -eq 0 ]; then
    echo "BUILD_RECIPE_DISCOVERY=FAIL_NO_REFERENCE"
    exit 1
  else
    echo "BUILD_RECIPE_DISCOVERY=PASS_REFERENCE_FOUND"
  fi
  echo

  echo "=== GATE O.0-J: OUTPUT REFERENCES ==="
  echo "RUNNER_INDEX=$RUNNER_INDEX"
  echo "HARNESS_INDEX=$HARNESS_INDEX"
  echo

  echo "============================================================"
  echo "SUB00O_DISCOVERY_STATUS=PASS"
  echo "GOTO_MODEL_GENERATED=NO"
  echo "CBMC_THEOREM_EXECUTED=NO"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "FROZEN_HARNESS_MODIFIED=NO"
  echo "NEXT_STAGE=FREEZE_EXACT_T3_BUILD_COMMANDS_AND_GENERATE_GOTO_MODELS"
  echo "============================================================"
} | tee "$REPORT"

(
  cd "$OUT"
  find . -maxdepth 1 -type f \
    ! -name "$(basename "$MANIFEST")" \
    -print0 |
  sort -z |
  xargs -0 sha256sum > "$(basename "$MANIFEST")"
)

chmod -R a-w "$OUT"

echo
echo "=== SUB00O DISCOVERY MANIFEST VERIFICATION ==="
(
  cd "$OUT"
  sha256sum -c "$(basename "$MANIFEST")"
)

echo
echo "SUB00O_DISCOVERY_EXIT=0"
echo "OUT=$OUT"
echo
echo "Upload:"
echo "$REPORT"
echo "$RUNNER_INDEX"
echo "$HARNESS_INDEX"
echo "$MANIFEST"
