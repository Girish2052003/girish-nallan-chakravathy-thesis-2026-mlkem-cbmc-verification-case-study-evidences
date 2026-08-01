#!/usr/bin/env bash
#
# PA-03 runner:
# Unrestricted signed-domain negative control for mlk_poly_add.
#
# IMPORTANT:
#   CBMC VERIFICATION FAILED is the expected low-level result.
#   EXPECTED_COUNTEREXAMPLE_CONFIRMED is the successful campaign result.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa03_mlk_poly_add_unrestricted_negative_control.sh
#   ./run_pa03_mlk_poly_add_unrestricted_negative_control.sh 768
#
# Optional parameter-set argument: 512, 768, or 1024.
# Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-03"
CAMPAIGN_SCOPE="unrestricted_signed_int16_negative_control"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="pa03_mlk_poly_add_unrestricted_negative_control_harness.c"
EXPECTED_MARKER="PA03_P1_UNRESTRICTED_EXACT_SUM"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa03_mlk_poly_add_unrestricted_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/pa03_mlk_poly_add.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee grep; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] || [ ! -f "mlkem/src/poly.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

if [ ! -f "${HARNESS}" ]; then
  echo "ERROR: ${HARNESS} is not present in the repository root." >&2
  exit 2
fi

mkdir -p "${OUT_DIR}"

CURRENT_COMMIT="$(git rev-parse HEAD)"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected low-level CBMC result: VERIFICATION FAILED"
  echo "Expected campaign interpretation: EXPECTED_COUNTEREXAMPLE_CONFIRMED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Harness: ${HARNESS}"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1
sha256sum "${HARNESS}" > "${OUT_DIR}/harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
cp "${HARNESS}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-03 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

BUILD_COMMAND=(
  goto-cc
  -I.
  -Imlkem
  -Imlkem/src
  -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
  "${HARNESS}"
  mlkem/src/poly.c
  -o "${GOTO_MODEL}"
)

printf '%q ' "${BUILD_COMMAND[@]}" > "${OUT_DIR}/build_command.txt"
printf '\n' >> "${OUT_DIR}/build_command.txt"

echo "===== PA-03: BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  {
    echo "campaign=${CAMPAIGN_ID}"
    echo "expected_cbmc_result=VERIFICATION_FAILED"
    echo "build_exit=${BUILD_EXIT}"
    echo "final_status=BUILD_FAILED"
  } > "${OUT_DIR}/summary.txt"

  echo "PA-03 BUILD FAILED. This is not the expected scientific outcome."
  exit "${BUILD_EXIT}"
fi

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

CBMC_TEXT_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --trace
)

printf '%q ' "${CBMC_TEXT_COMMAND[@]}" > "${OUT_DIR}/cbmc_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_command.txt"

echo
echo "===== PA-03: RUNNING EXPECTED-FAILURE CBMC TEXT CHECK ====="
"${CBMC_TEXT_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/cbmc_output.txt"
CBMC_TEXT_EXIT=${PIPESTATUS[0]}
echo "${CBMC_TEXT_EXIT}" > "${OUT_DIR}/cbmc.exit"

CBMC_JSON_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --json-ui
)

printf '%q ' "${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_json_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_json_command.txt"

echo
echo "===== PA-03: RUNNING EXPECTED-FAILURE CBMC JSON CHECK ====="
"${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_output.json" 2> \
  "${OUT_DIR}/cbmc_json_stderr.txt"
CBMC_JSON_EXIT=$?
echo "${CBMC_JSON_EXIT}" > "${OUT_DIR}/cbmc_json.exit"

EXPECTED_ASSERTION_FAILURE="no"
NO_BODY_FAILURE="no"
VERIFICATION_FAILED_TEXT="no"
CONVERSION_FAILURE_OBSERVED="no"

if grep "${EXPECTED_MARKER}" "${OUT_DIR}/cbmc_output.txt" | \
   grep -q "FAILURE"; then
  EXPECTED_ASSERTION_FAILURE="yes"
fi

if grep -q "no body for callee" "${OUT_DIR}/cbmc_output.txt"; then
  NO_BODY_FAILURE="yes"
fi

if grep -q "VERIFICATION FAILED" "${OUT_DIR}/cbmc_output.txt"; then
  VERIFICATION_FAILED_TEXT="yes"
fi

if grep "arithmetic overflow on signed type conversion" \
   "${OUT_DIR}/cbmc_output.txt" | grep -q "FAILURE"; then
  CONVERSION_FAILURE_OBSERVED="yes"
fi

FINAL_STATUS="UNEXPECTED_RESULT"
SCRIPT_EXIT=1

if [ "${BUILD_EXIT}" -eq 0 ] &&
   [ "${CBMC_TEXT_EXIT}" -eq 10 ] &&
   [ "${CBMC_JSON_EXIT}" -eq 10 ] &&
   [ "${EXPECTED_ASSERTION_FAILURE}" = "yes" ] &&
   [ "${NO_BODY_FAILURE}" = "no" ] &&
   [ "${VERIFICATION_FAILED_TEXT}" = "yes" ]; then
  FINAL_STATUS="EXPECTED_COUNTEREXAMPLE_CONFIRMED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "expected_cbmc_result=VERIFICATION_FAILED"
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_text_exit=${CBMC_TEXT_EXIT}"
  echo "cbmc_json_exit=${CBMC_JSON_EXIT}"
  echo "expected_assertion_failure_observed=${EXPECTED_ASSERTION_FAILURE}"
  echo "target_conversion_failure_observed=${CONVERSION_FAILURE_OBSERVED}"
  echo "no_body_failure_observed=${NO_BODY_FAILURE}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-03 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "EXPECTED_COUNTEREXAMPLE_CONFIRMED" ]; then
  echo
  echo "PA-03 SCIENTIFIC OUTCOME: SUCCESS"
  echo "CBMC refuted unrestricted exact int16_t addition as expected."
else
  echo
  echo "PA-03 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
