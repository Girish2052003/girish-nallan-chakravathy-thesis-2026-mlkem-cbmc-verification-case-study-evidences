#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"

HARNESS_ROOT="$ROOT/SUB00N_BATCH3_T3_HARNESS_FREEZE_V1"
HARNESS_MANIFEST="$HARNESS_ROOT/SUB00N_ARTIFACT_MANIFEST.sha256"

PREFLIGHT="$ROOT/SUB00O_R5_BATCH3_T3_GOTO_PREFLIGHT_MLKEM768_V1"
PREFLIGHT_MANIFEST="$PREFLIGHT/SUB00O_R5_ARTIFACT_MANIFEST.sha256"

RUN1="$ROOT/SUB00P_AUTHORITATIVE_T3_EXECUTION_MLKEM768_RUN1"

VALIDATOR="$ROOT/SUB00P_R3_FINAL_VALIDATOR_ONLY_REPAIR_FROM_RUN1"
VALIDATOR_SUMMARY="$VALIDATOR/SUB00P_R3_CORRECTED_FINAL_VERDICT.txt"
VALIDATOR_JSON="$VALIDATOR/SUB00P_R3_CORRECTED_SUMMARY.json"
VALIDATOR_MANIFEST="$VALIDATOR/SUB00P_R3_REVALIDATION_MANIFEST.sha256"
VALIDATOR_EXIT="$VALIDATOR/final_validation_exit_code.txt"

OUT="$ROOT/SUB00Q_T3_COMPLETE_PROOF_SUITE_MLKEM768_V1"
ARCHIVE="$ROOT/SUB00Q_T3_COMPLETE_PROOF_SUITE_MLKEM768_V1.tar.gz"
ARCHIVE_SHA="$ARCHIVE.sha256"

fail() {
  echo "SUB00Q_FREEZE_STATUS=FAIL" >&2
  echo "REASON=$*" >&2
  exit 1
}

require_file() {
  test -f "$1" || fail "required file missing: $1"
}

require_dir() {
  test -d "$1" || fail "required directory missing: $1"
}

copy_if_present() {
  local src="$1"
  local dst="$2"
  if test -f "$src"; then
    mkdir -p "$(dirname "$dst")"
    cp -p "$src" "$dst"
  fi
}

require_dir "$HARNESS_ROOT"
require_file "$HARNESS_MANIFEST"
require_dir "$PREFLIGHT"
require_file "$PREFLIGHT_MANIFEST"
require_dir "$RUN1"
require_dir "$VALIDATOR"
require_file "$VALIDATOR_SUMMARY"
require_file "$VALIDATOR_JSON"
require_file "$VALIDATOR_MANIFEST"
require_file "$VALIDATOR_EXIT"

test ! -e "$OUT" || fail "output directory already exists; nothing overwritten"
test ! -e "$ARCHIVE" || fail "archive already exists; nothing overwritten"
test ! -e "$ARCHIVE_SHA" || fail "archive hash file already exists"

ACTIVE="$(
  pgrep -af 'cbmc|goto-cc|goto-gcc|goto-clang|goto-instrument' 2>/dev/null |
  awk -v self="$$" -v parent="$PPID" '$1 != self && $1 != parent' || true
)"
if test -n "$ACTIVE"; then
  printf '%s\n' "$ACTIVE" >&2
  fail "formal-tool process is active"
fi

echo "=== VERIFY SUB00N HARNESS FREEZE ==="
(
  cd "$HARNESS_ROOT"
  sha256sum -c "$(basename "$HARNESS_MANIFEST")"
)

echo
echo "=== VERIFY SUB00O R5 PREFLIGHT ==="
(
  cd "$PREFLIGHT"
  sha256sum -c "$(basename "$PREFLIGHT_MANIFEST")"
)

echo
echo "=== VERIFY SUB00P R3 VALIDATOR PACKAGE ==="
(
  cd "$VALIDATOR"
  sha256sum -c "$(basename "$VALIDATOR_MANIFEST")"
)

test "$(tr -d '[:space:]' < "$VALIDATOR_EXIT")" = "0" ||
  fail "corrected final validation exit is not zero"

grep -qxF "OVERALL_VERDICT=PASS_COMPLETE_T3_CAMPAIGN" \
  "$VALIDATOR_SUMMARY" ||
  fail "complete T3 campaign verdict missing"

grep -qxF "COMPLETED_CASES=13/13" "$VALIDATOR_SUMMARY" ||
  fail "13/13 completion marker missing"

grep -qxF "POSITIVE_CASES_PASSED=8/8" "$VALIDATOR_SUMMARY" ||
  fail "8/8 positive marker missing"

grep -qxF "NEGATIVE_CONTROLS_PASSED=4/4" "$VALIDATOR_SUMMARY" ||
  fail "4/4 negative-control marker missing"

grep -qxF "COVERAGE_GOALS_REACHED=23/23" "$VALIDATOR_SUMMARY" ||
  fail "23/23 coverage marker missing"

grep -qxF "T3A_EXACT=PASS_ALL_PROPERTIES_SUCCESS" \
  "$VALIDATOR_SUMMARY" ||
  fail "T3A final pass marker missing"

grep -qxF "T3B_EXACT=PASS_ALL_PROPERTIES_SUCCESS" \
  "$VALIDATOR_SUMMARY" ||
  fail "T3B final pass marker missing"

grep -qxF "T3C_MODULAR=PASS_ALL_PROPERTIES_SUCCESS" \
  "$VALIDATOR_SUMMARY" ||
  fail "T3C final pass marker missing"

grep -qxF "CBMC_REEXECUTED=NO" "$VALIDATOR_SUMMARY" ||
  fail "validator-only provenance marker missing"

mkdir -p \
  "$OUT/00_readme" \
  "$OUT/01_frozen_harnesses" \
  "$OUT/02_preregistration_and_design" \
  "$OUT/03_preflight_frozen_models" \
  "$OUT/04_authoritative_execution_results" \
  "$OUT/05_corrected_independent_validation" \
  "$OUT/06_provenance"

cat > "$OUT/00_readme/T3_SUITE_README.md" <<'EOF'
# T3 complete CBMC proof suite — ML-KEM-768

## Scope

This suite contains the frozen T3 harness family for the selected
`mlk_poly_sub` composition properties in the portable ML-KEM-768 C build.

It records:

- eight positive theorem or valid-boundary cases;
- four invalid-domain negative controls;
- one coverage harness with 23/23 goals reached;
- exact GOTO models, property inventories, loop identifiers and unwind sets;
- authoritative CBMC JSON results;
- corrected independent result validation.

## Central claims checked

### T3A — exact right cancellation

For each coefficient, under representability of the initial subtraction:

`(A - B) + B = A`

### T3B — exact left cancellation

For each coefficient, under representability of the initial addition:

`(A + B) - B = A`

### T3C — modular cancellation

For each coefficient, under representability of the initial subtraction:

`N(N(A - B) + N(B)) = N(A)`

where `N` is the frozen coefficient-normalisation operation used by the
harness and production reduction path.

## Important interpretation boundary

This package supports only the frozen, property-specific claims under their
recorded assumptions, machine model, parameter set, build configuration,
loop bounds and verification commands.

It does not by itself establish:

- total correctness of all ML-KEM;
- correctness of every `mlk_poly_sub` use context;
- side-channel security;
- correctness for every compiler or architecture;
- universal literature novelty.

The four negative-control harnesses are not positive proofs. Their expected
failures demonstrate that invalid representability boundaries are detected.

The coverage harness is interpreted only through its dedicated coverage run.
Its ordinary safety invocation reports the non-applicable intrinsic
`main.no-body.__CPROVER_cover`; this is not a production-code safety defect.
EOF

cat > "$OUT/00_readme/T3_CASE_MATRIX.tsv" <<'EOF'
case_id	classification	harness	expected_outcome	validated_outcome
T3A_EXACT	POSITIVE_THEOREM	sub_t3a_exact_sub_add_harness.c	exit 0; all properties success	PASS_ALL_PROPERTIES_SUCCESS
T3B_EXACT	POSITIVE_THEOREM	sub_t3b_exact_add_sub_harness.c	exit 0; all properties success	PASS_ALL_PROPERTIES_SUCCESS
T3C_MODULAR	POSITIVE_THEOREM	sub_t3c_modular_cancellation_harness.c	exit 0; all properties success	PASS_ALL_PROPERTIES_SUCCESS
T3A_VALID_LOWER	POSITIVE_BOUNDARY	sub_t3a_valid_lower_harness.c	exit 0; all properties success	PASS_ALL_PROPERTIES_SUCCESS
T3A_VALID_UPPER	POSITIVE_BOUNDARY	sub_t3a_valid_upper_harness.c	exit 0; all properties success	PASS_ALL_PROPERTIES_SUCCESS
T3B_VALID_LOWER	POSITIVE_BOUNDARY	sub_t3b_valid_lower_harness.c	exit 0; all properties success	PASS_ALL_PROPERTIES_SUCCESS
T3B_VALID_UPPER	POSITIVE_BOUNDARY	sub_t3b_valid_upper_harness.c	exit 0; all properties success	PASS_ALL_PROPERTIES_SUCCESS
T3C_SUM_BOUNDARIES	POSITIVE_BOUNDARY	sub_t3c_recovery_sum_boundaries_harness.c	exit 0; all properties success	PASS_ALL_PROPERTIES_SUCCESS
T3A_INVALID_LOWER	NEGATIVE_CONTROL	sub_t3a_invalid_lower_harness.c	exit 10; intended domain rejection	PASS_EXPECTED_DOMAIN_REJECTION
T3A_INVALID_UPPER	NEGATIVE_CONTROL	sub_t3a_invalid_upper_harness.c	exit 10; intended domain rejection	PASS_EXPECTED_DOMAIN_REJECTION
T3B_INVALID_LOWER	NEGATIVE_CONTROL	sub_t3b_invalid_lower_harness.c	exit 10; intended domain rejection	PASS_EXPECTED_DOMAIN_REJECTION
T3B_INVALID_UPPER	NEGATIVE_CONTROL	sub_t3b_invalid_upper_harness.c	exit 10; intended domain rejection	PASS_EXPECTED_DOMAIN_REJECTION
T3_COVERAGE	COVERAGE	sub_t3_coverage_harness.c	23/23 dedicated coverage goals reached	PASS_COVERAGE_23_OF_23_DIRECTIVE_SAFETY_NA
EOF

cat > "$OUT/00_readme/T3_FINAL_STATUS.txt" <<'EOF'
T3_SUITE_STATUS=PASS_COMPLETE
TOTAL_CASES=13
POSITIVE_THEOREM_OR_BOUNDARY_CASES=8
NEGATIVE_CONTROLS=4
COVERAGE_CASES=1
COVERAGE_GOALS_REACHED=23/23
T3A_EXACT=PASS_ALL_PROPERTIES_SUCCESS
T3B_EXACT=PASS_ALL_PROPERTIES_SUCCESS
T3C_MODULAR=PASS_ALL_PROPERTIES_SUCCESS
CBMC_RESULTS_REUSED_FROM_SUB00P_RUN1=YES
VALIDATOR_ONLY_REPAIR_APPLIED=YES
CBMC_REEXECUTED_DURING_VALIDATOR_REPAIR=NO
PRODUCTION_SOURCE_MODIFIED=NO
FROZEN_HARNESS_MODIFIED=NO
EOF

# Frozen harness family: exactly 13 C harnesses plus their common header.
cp -p "$HARNESS_ROOT"/harnesses/*.c \
  "$OUT/01_frozen_harnesses/"
cp -p "$HARNESS_ROOT"/harnesses/sub_t3_common.h \
  "$OUT/01_frozen_harnesses/"

HARNESS_C_COUNT="$(
  find "$OUT/01_frozen_harnesses" -maxdepth 1 -type f -name '*.c' |
  wc -l | tr -d '[:space:]'
)"
test "$HARNESS_C_COUNT" = "13" ||
  fail "expected 13 C harnesses, copied $HARNESS_C_COUNT"

# Design and preregistration records.
for name in \
  BOUNDARY_CONTROL_MATRIX.md \
  BUILD_CONTEXT_REFERENCE_PACKET.txt \
  ENVIRONMENT.txt \
  FREEZE_VALIDATION.txt \
  HARNESS_ARCHITECTURE.md \
  HARNESS_INVENTORY.json \
  MUTATION_PREFLIGHT_MATRIX.md \
  STATIC_PROPERTY_AUDIT.txt
do
  copy_if_present \
    "$HARNESS_ROOT/$name" \
    "$OUT/02_preregistration_and_design/$name"
done

if test -d "$HARNESS_ROOT/provenance"; then
  cp -a "$HARNESS_ROOT/provenance" \
    "$OUT/02_preregistration_and_design/"
fi

# Preflight frozen models and exact commands.
CASE_IDS=(
  T3A_EXACT
  T3B_EXACT
  T3C_MODULAR
  T3A_VALID_LOWER
  T3A_VALID_UPPER
  T3B_VALID_LOWER
  T3B_VALID_UPPER
  T3C_SUM_BOUNDARIES
  T3A_INVALID_LOWER
  T3A_INVALID_UPPER
  T3B_INVALID_LOWER
  T3B_INVALID_UPPER
  T3_COVERAGE
)

for case_id in "${CASE_IDS[@]}"; do
  src="$PREFLIGHT/build/$case_id/frozen_inputs"
  dst="$OUT/03_preflight_frozen_models/$case_id"
  require_dir "$src"
  mkdir -p "$dst"
  cp -a "$src"/. "$dst"/
done

cp -p "$PREFLIGHT/SUB00O_R5_PREFLIGHT_SUMMARY.txt" \
  "$OUT/03_preflight_frozen_models/"
cp -p "$PREFLIGHT/CASE_MATRIX.tsv" \
  "$OUT/03_preflight_frozen_models/PREFLIGHT_CASE_MATRIX.tsv"
cp -p "$PREFLIGHT/PREFLIGHT_AUDIT.json" \
  "$OUT/03_preflight_frozen_models/"
cp -p "$PREFLIGHT_MANIFEST" \
  "$OUT/03_preflight_frozen_models/"

# Essential authoritative execution results only.
for case_id in "${CASE_IDS[@]}"; do
  src="$RUN1/cases/$case_id"
  dst="$OUT/04_authoritative_execution_results/$case_id"
  require_dir "$src"
  mkdir -p "$dst"

  copy_if_present "$src/cbmc_result.json" "$dst/cbmc_result.json"
  copy_if_present "$src/cbmc_exit_code.txt" "$dst/cbmc_exit_code.txt"
  copy_if_present "$src/cbmc_command.txt" "$dst/cbmc_command.txt"

  copy_if_present "$src/safety_result.json" "$dst/safety_result.json"
  copy_if_present "$src/safety_exit_code.txt" "$dst/safety_exit_code.txt"
  copy_if_present "$src/safety_command.txt" "$dst/safety_command.txt"

  copy_if_present "$src/coverage_result.json" "$dst/coverage_result.json"
  copy_if_present "$src/coverage_exit_code.txt" "$dst/coverage_exit_code.txt"
  copy_if_present "$src/coverage_command.txt" "$dst/coverage_command.txt"

  copy_if_present "$src/CASE_SUMMARY.txt" "$dst/CASE_SUMMARY.txt"
  copy_if_present "$src/case_summary.txt" "$dst/case_summary.txt"
done

copy_if_present \
  "$RUN1/SUB00P_T3_FINAL_VERDICT.txt" \
  "$OUT/04_authoritative_execution_results/ORIGINAL_BROKEN_VALIDATOR_VERDICT.txt"
copy_if_present \
  "$RUN1/SUB00P_T3_INDEPENDENT_SUMMARY.json" \
  "$OUT/04_authoritative_execution_results/ORIGINAL_BROKEN_VALIDATOR_SUMMARY.json"
copy_if_present \
  "$RUN1/SUB00P_ARTIFACT_MANIFEST.sha256" \
  "$OUT/04_authoritative_execution_results/"
copy_if_present \
  "$RUN1/post_execution_parent_manifest_verification.txt" \
  "$OUT/04_authoritative_execution_results/"
copy_if_present \
  "$RUN1/final_validation_exit_code.txt" \
  "$OUT/04_authoritative_execution_results/ORIGINAL_VALIDATOR_EXIT.txt"

# Corrected independent validation.
cp -p "$VALIDATOR_SUMMARY" \
  "$OUT/05_corrected_independent_validation/"
cp -p "$VALIDATOR_JSON" \
  "$OUT/05_corrected_independent_validation/"
cp -p "$VALIDATOR_EXIT" \
  "$OUT/05_corrected_independent_validation/"
cp -p "$VALIDATOR_MANIFEST" \
  "$OUT/05_corrected_independent_validation/"

if test -d "$VALIDATOR/cases"; then
  cp -a "$VALIDATOR/cases" \
    "$OUT/05_corrected_independent_validation/"
fi

copy_if_present \
  "$VALIDATOR/original_result_file_index.txt" \
  "$OUT/05_corrected_independent_validation/"

# Provenance and parent identities.
cp -p "$HARNESS_MANIFEST" \
  "$OUT/06_provenance/SUB00N_PARENT_MANIFEST.sha256"
cp -p "$PREFLIGHT_MANIFEST" \
  "$OUT/06_provenance/SUB00O_R5_PARENT_MANIFEST.sha256"
cp -p "$VALIDATOR_MANIFEST" \
  "$OUT/06_provenance/SUB00P_R3_PARENT_MANIFEST.sha256"

{
  echo "ROOT=$ROOT"
  echo "HARNESS_ROOT=$HARNESS_ROOT"
  echo "PREFLIGHT=$PREFLIGHT"
  echo "ORIGINAL_EXECUTION=$RUN1"
  echo "CORRECTED_VALIDATOR=$VALIDATOR"
  echo "PARAMETER_SET=768"
  echo "CASE_COUNT=13"
  echo "HARNESS_C_COUNT=$HARNESS_C_COUNT"
  echo "CREATED_AT=$(date --iso-8601=seconds)"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "FROZEN_HARNESS_MODIFIED=NO"
} > "$OUT/06_provenance/SUB00Q_PROVENANCE.txt"

# Independent structural validation of the package.
python3 - "$OUT" <<'PY'
import csv
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])

harnesses = sorted(
    p.name for p in (root / "01_frozen_harnesses").glob("*.c")
)
expected_harnesses = sorted([
    "sub_t3a_exact_sub_add_harness.c",
    "sub_t3a_invalid_lower_harness.c",
    "sub_t3a_invalid_upper_harness.c",
    "sub_t3a_valid_lower_harness.c",
    "sub_t3a_valid_upper_harness.c",
    "sub_t3b_exact_add_sub_harness.c",
    "sub_t3b_invalid_lower_harness.c",
    "sub_t3b_invalid_upper_harness.c",
    "sub_t3b_valid_lower_harness.c",
    "sub_t3b_valid_upper_harness.c",
    "sub_t3c_modular_cancellation_harness.c",
    "sub_t3_coverage_harness.c",
    "sub_t3c_recovery_sum_boundaries_harness.c",
])

if harnesses != expected_harnesses:
    raise SystemExit(
        "ERROR: frozen harness set differs from expected 13 files"
    )

summary_json = (
    root
    / "05_corrected_independent_validation"
    / "SUB00P_R3_CORRECTED_SUMMARY.json"
)
data = json.loads(summary_json.read_text(encoding="utf-8"))

if data.get("overall_verdict") != "PASS_COMPLETE_T3_CAMPAIGN":
    raise SystemExit("ERROR: corrected overall verdict is not PASS")

if data.get("case_count") != 13:
    raise SystemExit("ERROR: corrected validator case count is not 13")

if data.get("positive_pass_count") != 8:
    raise SystemExit("ERROR: positive pass count is not 8")

if data.get("negative_control_pass_count") != 4:
    raise SystemExit("ERROR: negative-control pass count is not 4")

if data.get("coverage_pass_count") != 1:
    raise SystemExit("ERROR: coverage pass count is not 1")

case_matrix = root / "00_readme" / "T3_CASE_MATRIX.tsv"
with case_matrix.open("r", encoding="utf-8", newline="") as handle:
    rows = list(csv.DictReader(handle, delimiter="\t"))

if len(rows) != 13:
    raise SystemExit("ERROR: suite case matrix does not contain 13 rows")

preflight_dirs = [
    p.name
    for p in (root / "03_preflight_frozen_models").iterdir()
    if p.is_dir()
]
if len(preflight_dirs) != 13:
    raise SystemExit("ERROR: package does not contain 13 preflight cases")

print("STRUCTURAL_VALIDATION=PASS")
print("HARNESS_C_COUNT=13")
print("CASE_MATRIX_ROWS=13")
print("PREFLIGHT_CASE_DIRECTORIES=13")
print("CORRECTED_FINAL_VERDICT=PASS_COMPLETE_T3_CAMPAIGN")
PY

cat > "$OUT/SUB00Q_STRUCTURAL_VALIDATION.txt" <<EOF
STRUCTURAL_VALIDATION=PASS
HARNESS_C_COUNT=13
CASE_COUNT=13
POSITIVE_CASE_COUNT=8
NEGATIVE_CONTROL_COUNT=4
COVERAGE_CASE_COUNT=1
COVERAGE_GOALS=23/23
CORRECTED_FINAL_VERDICT=PASS_COMPLETE_T3_CAMPAIGN
EOF

MANIFEST="$OUT/SUB00Q_T3_SUITE_MANIFEST.sha256"
(
  cd "$OUT"
  find . -type f \
    ! -name "$(basename "$MANIFEST")" \
    -print0 |
  sort -z |
  xargs -0 sha256sum > "$(basename "$MANIFEST")"
)

echo
echo "=== VERIFY SUB00Q SUITE MANIFEST ==="
(
  cd "$OUT"
  sha256sum -c "$(basename "$MANIFEST")"
)

chmod -R a-w "$OUT"

(
  cd "$ROOT"
  tar \
    --sort=name \
    --mtime='UTC 2026-07-17' \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    -cf - "$(basename "$OUT")" |
  gzip -n > "$ARCHIVE"
)

sha256sum "$ARCHIVE" > "$ARCHIVE_SHA"

echo
echo "============================================================"
echo "SUB00Q T3 COMPLETE PROOF SUITE FREEZE"
echo "============================================================"
echo "SUB00Q_FREEZE_STATUS=PASS"
echo "SUITE_DIRECTORY=$OUT"
echo "ARCHIVE=$ARCHIVE"
echo "ARCHIVE_SHA256=$(sha256sum "$ARCHIVE" | awk '{print $1}')"
echo "HARNESS_C_COUNT=13"
echo "TOTAL_CASES=13"
echo "POSITIVE_CASES_PASSED=8/8"
echo "NEGATIVE_CONTROLS_PASSED=4/4"
echo "COVERAGE_GOALS_REACHED=23/23"
echo "T3A_EXACT=PASS_ALL_PROPERTIES_SUCCESS"
echo "T3B_EXACT=PASS_ALL_PROPERTIES_SUCCESS"
echo "T3C_MODULAR=PASS_ALL_PROPERTIES_SUCCESS"
echo "SUITE_MANIFEST_VERIFIED=YES"
echo "PRODUCTION_SOURCE_MODIFIED=NO"
echo "FROZEN_HARNESS_MODIFIED=NO"
echo "NEXT_STAGE=SUB00R_T3_MUTATION_CAMPAIGN"
echo "SUB00Q_FREEZE_EXIT=0"
echo "============================================================"
