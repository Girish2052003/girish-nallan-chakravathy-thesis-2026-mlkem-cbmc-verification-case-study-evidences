#!/usr/bin/env bash
#
# PA-07: Mutation-sensitivity campaign for the frozen mlk_poly_add harnesses.
#
# Purpose:
#   Demonstrate that the successful PA-01 and PA-02 harnesses are capable of
#   rejecting meaningful defective implementations rather than merely
#   succeeding against the production body.
#
# Production source is never modified.
#
# Baseline controls:
#   - frozen PA-01 against production mlkem/src/poly.c: expected success
#   - frozen PA-02 against production mlkem/src/poly.c: expected success
#
# Controlled mutants:
#   M1: addition replaced by subtraction
#   M2: loop starts at coefficient 1
#   M3: final coefficient skipped
#   M4: only first half processed
#   M5: result written to b instead of r
#
# Each mutant is checked against both frozen harnesses:
#
#   5 mutants × 2 frozen harnesses = 10 expected-failure pairs
#
# Expected final status:
#   PA07_ALL_MUTANTS_DETECTED
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa07_mlk_poly_add_mutation_sensitivity.sh
#   ./run_pa07_mlk_poly_add_mutation_sensitivity.sh
#

set -uo pipefail

CAMPAIGN_ID="PA-07"
CAMPAIGN_SCOPE="mutation_sensitivity_of_frozen_harnesses"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="768"

PA01_HARNESS="cleanroom_mlk_poly_add_fips_relational_harness_v2.c"
PA02_HARNESS="pa02_mlk_poly_add_full_signed_contract_valid_harness.c"
MUTANT_SOURCE="pa07_mlk_poly_add_mutant_implementation.c"

PA01_EXPECTED_SHA256="307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e"
PA02_EXPECTED_SHA256="e83d521e23f93c2435058598be5ef245bb02c554a4b7992dd8844418720c2ce2"
POLY_C_EXPECTED_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa07_mlk_poly_add_mutation_${TIMESTAMP}"

for tool in git cbmc goto-cc sha256sum tee grep awk; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

for file in \
  "mlkem/src/poly.c" \
  "mlkem/src/poly.h" \
  "${PA01_HARNESS}" \
  "${PA02_HARNESS}" \
  "${MUTANT_SOURCE}"; do
  if [ ! -f "${file}" ]; then
    echo "ERROR: required file missing: ${file}" >&2
    exit 2
  fi
done

CURRENT_COMMIT="$(git rev-parse HEAD)"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  echo "ERROR: repository commit mismatch." >&2
  echo "Expected: ${EXPECTED_COMMIT}" >&2
  echo "Actual:   ${CURRENT_COMMIT}" >&2
  exit 3
fi

if ! git diff --quiet -- mlkem/src/poly.c; then
  echo "ERROR: production mlkem/src/poly.c has tracked modifications." >&2
  echo "PA-07 refuses to run because mutants must remain external." >&2
  exit 4
fi

PA01_ACTUAL_SHA256="$(sha256sum "${PA01_HARNESS}" | awk '{print $1}')"
PA02_ACTUAL_SHA256="$(sha256sum "${PA02_HARNESS}" | awk '{print $1}')"
POLY_C_ACTUAL_SHA256="$(sha256sum mlkem/src/poly.c | awk '{print $1}')"

if [ "${PA01_ACTUAL_SHA256}" != "${PA01_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-01 harness hash mismatch." >&2
  echo "Expected: ${PA01_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA01_ACTUAL_SHA256}" >&2
  exit 5
fi

if [ "${PA02_ACTUAL_SHA256}" != "${PA02_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-02 harness hash mismatch." >&2
  echo "Expected: ${PA02_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA02_ACTUAL_SHA256}" >&2
  exit 5
fi

if [ "${POLY_C_ACTUAL_SHA256}" != "${POLY_C_EXPECTED_SHA256}" ]; then
  echo "ERROR: production poly.c hash mismatch." >&2
  echo "Expected: ${POLY_C_EXPECTED_SHA256}" >&2
  echo "Actual:   ${POLY_C_ACTUAL_SHA256}" >&2
  exit 5
fi

mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA07_ALL_MUTANTS_DETECTED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Frozen PA-01 hash: ${PA01_ACTUAL_SHA256}"
  echo "Frozen PA-02 hash: ${PA02_ACTUAL_SHA256}"
  echo "Production poly.c hash: ${POLY_C_ACTUAL_SHA256}"
  echo "Production poly.c modified: no"
  echo "Mutants: 5"
  echo "Mutant-harness pairs: 10"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

sha256sum "${PA01_HARNESS}" > "${OUT_DIR}/pa01_harness_sha256.txt"
sha256sum "${PA02_HARNESS}" > "${OUT_DIR}/pa02_harness_sha256.txt"
sha256sum "${MUTANT_SOURCE}" > "${OUT_DIR}/mutant_source_sha256.txt"
sha256sum mlkem/src/poly.c > "${OUT_DIR}/production_poly_c_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"

cp "${PA01_HARNESS}" "${OUT_DIR}/"
cp "${PA02_HARNESS}" "${OUT_DIR}/"
cp "${MUTANT_SOURCE}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

run_baseline()
{
  local harness_label="$1"
  local harness="$2"
  local required_marker="$3"

  local result_dir="${OUT_DIR}/baseline/${harness_label}"
  local goto_model="${result_dir}/${harness_label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1
  local successful="no"
  local marker_success="no"
  local failure_lines="yes"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    "${harness}"
    mlkem/src/poly.c
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-07 BASELINE: ${harness_label}"
  echo "============================================================"

  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  if [ "${build_exit}" -eq 0 ]; then
    local text_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --trace
    )

    printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
    printf '\n' >> "${result_dir}/cbmc_command.txt"

    "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
    text_exit=${PIPESTATUS[0]}
    echo "${text_exit}" > "${result_dir}/cbmc.exit"

    local json_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --json-ui
    )

    printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
    printf '\n' >> "${result_dir}/cbmc_json_command.txt"

    echo "Running baseline JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 0 ] &&
     [ "${json_exit}" -eq 0 ] &&
     grep -q "VERIFICATION SUCCESSFUL" "${result_dir}/cbmc_output.txt"; then
    successful="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${required_marker}" "${result_dir}/cbmc_output.txt" | \
       grep -q "SUCCESS"; then
    marker_success="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     ! grep -q "FAILURE" "${result_dir}/cbmc_output.txt"; then
    failure_lines="no"
  fi

  {
    echo "harness=${harness_label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_successful=${successful}"
    echo "required_marker_success=${marker_success}"
    echo "failure_lines_observed=${failure_lines}"
  } > "${result_dir}/summary.txt"

  cat "${result_dir}/summary.txt"

  if [ "${successful}" = "yes" ] &&
     [ "${marker_success}" = "yes" ] &&
     [ "${failure_lines}" = "no" ]; then
    return 0
  fi

  return 1
}

run_mutant()
{
  local mutation_id="$1"
  local mutation_name="$2"
  local harness_label="$3"
  local harness="$4"
  local expected_failure_marker="$5"

  local result_dir="${OUT_DIR}/mutants/M${mutation_id}_${mutation_name}/${harness_label}"
  local goto_model="${result_dir}/M${mutation_id}_${harness_label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1
  local verification_failed="no"
  local expected_marker_failure="no"
  local no_body_failure="no"
  local detected="no"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    -DPA07_MUTATION_ID="${mutation_id}"
    "${harness}"
    "${MUTANT_SOURCE}"
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-07 MUTANT M${mutation_id}: ${mutation_name}"
  echo "Harness: ${harness_label}"
  echo "Expected low-level result: VERIFICATION FAILED"
  echo "============================================================"

  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  if [ "${build_exit}" -eq 0 ]; then
    local text_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --trace
    )

    printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
    printf '\n' >> "${result_dir}/cbmc_command.txt"

    "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
    text_exit=${PIPESTATUS[0]}
    echo "${text_exit}" > "${result_dir}/cbmc.exit"

    local json_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --json-ui
    )

    printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
    printf '\n' >> "${result_dir}/cbmc_json_command.txt"

    echo "Running expected-failure JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -q "VERIFICATION FAILED" "${result_dir}/cbmc_output.txt"; then
    verification_failed="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${expected_failure_marker}" "${result_dir}/cbmc_output.txt" | \
       grep -q "FAILURE"; then
    expected_marker_failure="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -q "no body for callee" "${result_dir}/cbmc_output.txt"; then
    no_body_failure="yes"
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 10 ] &&
     [ "${json_exit}" -eq 10 ] &&
     [ "${verification_failed}" = "yes" ] &&
     [ "${expected_marker_failure}" = "yes" ] &&
     [ "${no_body_failure}" = "no" ]; then
    detected="yes"
  fi

  {
    echo "mutation_id=${mutation_id}"
    echo "mutation_name=${mutation_name}"
    echo "harness=${harness_label}"
    echo "expected_failure_marker=${expected_failure_marker}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_failed=${verification_failed}"
    echo "expected_marker_failure_observed=${expected_marker_failure}"
    echo "no_body_failure_observed=${no_body_failure}"
    echo "mutant_detected=${detected}"
  } > "${result_dir}/summary.txt"

  cat "${result_dir}/summary.txt"

  if [ "${detected}" = "yes" ]; then
    return 0
  fi

  return 1
}

BASELINE_PA01="no"
BASELINE_PA02="no"

if run_baseline \
  "pa01_canonical_fips" \
  "${PA01_HARNESS}" \
  "P1_EXACT_SUM"; then
  BASELINE_PA01="yes"
fi

if run_baseline \
  "pa02_full_signed_valid" \
  "${PA02_HARNESS}" \
  "PA02_P1_EXACT_SIGNED_SUM"; then
  BASELINE_PA02="yes"
fi

DETECTED_PAIRS=0
ALL_MUTATIONS_OK="yes"
: > "${OUT_DIR}/mutation_status.txt"

for MUTATION_ID in 1 2 3 4 5; do
  case "${MUTATION_ID}" in
    1)
      MUTATION_NAME="subtract_instead_of_add"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    2)
      MUTATION_NAME="loop_starts_at_one"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    3)
      MUTATION_NAME="skip_final_coefficient"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    4)
      MUTATION_NAME="process_only_first_half"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    5)
      MUTATION_NAME="write_result_to_b"
      PA01_MARKER="P4_RIGHT_INPUT_FRAME"
      PA02_MARKER="PA02_P4_RIGHT_INPUT_FRAME"
      ;;
  esac

  PA01_DETECTED="no"
  PA02_DETECTED="no"

  if run_mutant \
    "${MUTATION_ID}" \
    "${MUTATION_NAME}" \
    "pa01_canonical_fips" \
    "${PA01_HARNESS}" \
    "${PA01_MARKER}"; then
    PA01_DETECTED="yes"
    DETECTED_PAIRS=$((DETECTED_PAIRS + 1))
  fi

  if run_mutant \
    "${MUTATION_ID}" \
    "${MUTATION_NAME}" \
    "pa02_full_signed_valid" \
    "${PA02_HARNESS}" \
    "${PA02_MARKER}"; then
    PA02_DETECTED="yes"
    DETECTED_PAIRS=$((DETECTED_PAIRS + 1))
  fi

  MUTATION_DETECTED="no"
  if [ "${PA01_DETECTED}" = "yes" ] &&
     [ "${PA02_DETECTED}" = "yes" ]; then
    MUTATION_DETECTED="yes"
  else
    ALL_MUTATIONS_OK="no"
  fi

  {
    echo "mutation_${MUTATION_ID}_name=${MUTATION_NAME}"
    echo "mutation_${MUTATION_ID}_pa01_detected=${PA01_DETECTED}"
    echo "mutation_${MUTATION_ID}_pa02_detected=${PA02_DETECTED}"
    echo "mutation_${MUTATION_ID}_detected_by_both=${MUTATION_DETECTED}"
  } >> "${OUT_DIR}/mutation_status.txt"
done

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${BASELINE_PA01}" = "yes" ] &&
   [ "${BASELINE_PA02}" = "yes" ] &&
   [ "${ALL_MUTATIONS_OK}" = "yes" ] &&
   [ "${DETECTED_PAIRS}" -eq 10 ]; then
  FINAL_STATUS="PA07_ALL_MUTANTS_DETECTED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "production_source_modified=no"
  echo "baseline_pa01_verified=${BASELINE_PA01}"
  echo "baseline_pa02_verified=${BASELINE_PA02}"
  echo "mutants_total=5"
  echo "mutant_harness_pairs=10"
  echo "detected_pairs=${DETECTED_PAIRS}"
  cat "${OUT_DIR}/mutation_status.txt"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-07 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA07_ALL_MUTANTS_DETECTED" ]; then
  echo
  echo "PA-07 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Both frozen harnesses accepted the production baseline."
  echo "Both frozen harnesses rejected every controlled mutant."
  echo "Production source remained unchanged."
else
  echo
  echo "PA-07 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
