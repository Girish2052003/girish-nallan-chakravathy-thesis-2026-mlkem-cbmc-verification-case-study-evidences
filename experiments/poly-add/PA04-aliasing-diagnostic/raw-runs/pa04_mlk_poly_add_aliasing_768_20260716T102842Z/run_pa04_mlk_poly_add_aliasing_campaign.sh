#!/usr/bin/env bash
#
# PA-04 combined aliasing campaign for mlk_poly_add.
#
# PA-04A:
#   Safe representable aliasing domain.
#   Expected CBMC result: VERIFICATION SUCCESSFUL.
#
# PA-04B:
#   Unrestricted aliasing negative control.
#   Expected CBMC result: VERIFICATION FAILED.
#
# Final campaign success:
#   PA04_ALIASING_DIAGNOSTIC_CONFIRMED
#
# This campaign is an out-of-contract implementation diagnostic. It does
# not alter the production API contract or permit production aliasing.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa04_mlk_poly_add_aliasing_campaign.sh
#   ./run_pa04_mlk_poly_add_aliasing_campaign.sh 768
#
# Optional parameter set: 512, 768, or 1024.
# Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-04"
CAMPAIGN_SCOPE="out_of_contract_aliasing_diagnostic"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"

SAFE_HARNESS="pa04a_mlk_poly_add_alias_safe_doubling_harness.c"
NEGATIVE_HARNESS="pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c"
NEGATIVE_MARKER="PA04B_P1_UNRESTRICTED_ALIAS_EXACT_DOUBLING"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa04_mlk_poly_add_aliasing_${PARAM_SET}_${TIMESTAMP}"
SAFE_DIR="${OUT_DIR}/pa04a_safe_alias"
NEGATIVE_DIR="${OUT_DIR}/pa04b_unrestricted_alias_negative_control"

SAFE_GOTO="${SAFE_DIR}/pa04a_safe_alias.goto"
NEGATIVE_GOTO="${NEGATIVE_DIR}/pa04b_unrestricted_alias.goto"

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

for harness in "${SAFE_HARNESS}" "${NEGATIVE_HARNESS}"; do
  if [ ! -f "${harness}" ]; then
    echo "ERROR: required harness missing: ${harness}" >&2
    exit 2
  fi
done

mkdir -p "${SAFE_DIR}" "${NEGATIVE_DIR}"

CURRENT_COMMIT="$(git rev-parse HEAD)"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Contract status: out-of-contract implementation diagnostic"
  echo "PA-04A expected result: VERIFICATION SUCCESSFUL"
  echo "PA-04B expected result: VERIFICATION FAILED"
  echo "Final expected interpretation: PA04_ALIASING_DIAGNOSTIC_CONFIRMED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

sha256sum "${SAFE_HARNESS}" > "${OUT_DIR}/pa04a_harness_sha256.txt"
sha256sum "${NEGATIVE_HARNESS}" > "${OUT_DIR}/pa04b_harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"

cp "${SAFE_HARNESS}" "${OUT_DIR}/"
cp "${NEGATIVE_HARNESS}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-04 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
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

build_model()
{
  local harness="$1"
  local goto_model="$2"
  local result_dir="$3"
  local label="$4"
  local build_exit
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

  echo "===== ${label}: BUILDING GOTO MODEL ====="
  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  return "${build_exit}"
}

run_text_cbmc()
{
  local goto_model="$1"
  local result_dir="$2"
  local label="$3"
  local text_exit
  local text_command=(
    cbmc
    "${goto_model}"
    "${COMMON_CBMC_OPTIONS[@]}"
    --trace
  )

  printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
  printf '\n' >> "${result_dir}/cbmc_command.txt"

  echo
  echo "===== ${label}: RUNNING CBMC TEXT CHECK ====="
  "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
  text_exit=${PIPESTATUS[0]}
  echo "${text_exit}" > "${result_dir}/cbmc.exit"

  return "${text_exit}"
}

run_json_cbmc()
{
  local goto_model="$1"
  local result_dir="$2"
  local json_exit
  local json_command=(
    cbmc
    "${goto_model}"
    "${COMMON_CBMC_OPTIONS[@]}"
    --json-ui
  )

  printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
  printf '\n' >> "${result_dir}/cbmc_json_command.txt"

  "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
    "${result_dir}/cbmc_json_stderr.txt"
  json_exit=$?
  echo "${json_exit}" > "${result_dir}/cbmc_json.exit"

  return "${json_exit}"
}

SAFE_BUILD_EXIT=0
SAFE_TEXT_EXIT=-1
SAFE_JSON_EXIT=-1

build_model \
  "${SAFE_HARNESS}" \
  "${SAFE_GOTO}" \
  "${SAFE_DIR}" \
  "PA-04A SAFE ALIAS"
SAFE_BUILD_EXIT=$?

if [ "${SAFE_BUILD_EXIT}" -eq 0 ]; then
  run_text_cbmc \
    "${SAFE_GOTO}" \
    "${SAFE_DIR}" \
    "PA-04A SAFE ALIAS"
  SAFE_TEXT_EXIT=$?

  run_json_cbmc \
    "${SAFE_GOTO}" \
    "${SAFE_DIR}"
  SAFE_JSON_EXIT=$?
fi

NEG_BUILD_EXIT=0
NEG_TEXT_EXIT=-1
NEG_JSON_EXIT=-1

build_model \
  "${NEGATIVE_HARNESS}" \
  "${NEGATIVE_GOTO}" \
  "${NEGATIVE_DIR}" \
  "PA-04B UNRESTRICTED ALIAS"
NEG_BUILD_EXIT=$?

if [ "${NEG_BUILD_EXIT}" -eq 0 ]; then
  run_text_cbmc \
    "${NEGATIVE_GOTO}" \
    "${NEGATIVE_DIR}" \
    "PA-04B EXPECTED-FAILURE ALIAS"
  NEG_TEXT_EXIT=$?

  run_json_cbmc \
    "${NEGATIVE_GOTO}" \
    "${NEGATIVE_DIR}"
  NEG_JSON_EXIT=$?
fi

SAFE_VERIFICATION_SUCCESSFUL="no"
SAFE_FAILURE_LINES="yes"

if [ "${SAFE_BUILD_EXIT}" -eq 0 ] &&
   [ "${SAFE_TEXT_EXIT}" -eq 0 ] &&
   [ "${SAFE_JSON_EXIT}" -eq 0 ] &&
   grep -q "VERIFICATION SUCCESSFUL" "${SAFE_DIR}/cbmc_output.txt"; then
  SAFE_VERIFICATION_SUCCESSFUL="yes"
fi

if [ -f "${SAFE_DIR}/cbmc_output.txt" ] &&
   ! grep -q "FAILURE" "${SAFE_DIR}/cbmc_output.txt"; then
  SAFE_FAILURE_LINES="no"
fi

NEG_EXPECTED_ASSERTION_FAILURE="no"
NEG_CONVERSION_FAILURE="no"
NEG_NO_BODY_FAILURE="no"
NEG_VERIFICATION_FAILED="no"

if [ -f "${NEGATIVE_DIR}/cbmc_output.txt" ]; then
  if grep -F "${NEGATIVE_MARKER}" "${NEGATIVE_DIR}/cbmc_output.txt" | \
     grep -q "FAILURE"; then
    NEG_EXPECTED_ASSERTION_FAILURE="yes"
  fi

  if grep "arithmetic overflow on signed type conversion" \
     "${NEGATIVE_DIR}/cbmc_output.txt" | grep -q "FAILURE"; then
    NEG_CONVERSION_FAILURE="yes"
  fi

  if grep -q "no body for callee" "${NEGATIVE_DIR}/cbmc_output.txt"; then
    NEG_NO_BODY_FAILURE="yes"
  fi

  if grep -q "VERIFICATION FAILED" "${NEGATIVE_DIR}/cbmc_output.txt"; then
    NEG_VERIFICATION_FAILED="yes"
  fi
fi

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${SAFE_VERIFICATION_SUCCESSFUL}" = "yes" ] &&
   [ "${SAFE_FAILURE_LINES}" = "no" ] &&
   [ "${NEG_BUILD_EXIT}" -eq 0 ] &&
   [ "${NEG_TEXT_EXIT}" -eq 10 ] &&
   [ "${NEG_JSON_EXIT}" -eq 10 ] &&
   [ "${NEG_EXPECTED_ASSERTION_FAILURE}" = "yes" ] &&
   [ "${NEG_CONVERSION_FAILURE}" = "yes" ] &&
   [ "${NEG_NO_BODY_FAILURE}" = "no" ] &&
   [ "${NEG_VERIFICATION_FAILED}" = "yes" ]; then
  FINAL_STATUS="PA04_ALIASING_DIAGNOSTIC_CONFIRMED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "contract_status=OUT_OF_CONTRACT_DIAGNOSTIC"
  echo "pa04a_build_exit=${SAFE_BUILD_EXIT}"
  echo "pa04a_cbmc_text_exit=${SAFE_TEXT_EXIT}"
  echo "pa04a_cbmc_json_exit=${SAFE_JSON_EXIT}"
  echo "pa04a_verification_successful=${SAFE_VERIFICATION_SUCCESSFUL}"
  echo "pa04a_failure_lines_observed=${SAFE_FAILURE_LINES}"
  echo "pa04b_build_exit=${NEG_BUILD_EXIT}"
  echo "pa04b_cbmc_text_exit=${NEG_TEXT_EXIT}"
  echo "pa04b_cbmc_json_exit=${NEG_JSON_EXIT}"
  echo "pa04b_expected_assertion_failure_observed=${NEG_EXPECTED_ASSERTION_FAILURE}"
  echo "pa04b_conversion_failure_observed=${NEG_CONVERSION_FAILURE}"
  echo "pa04b_no_body_failure_observed=${NEG_NO_BODY_FAILURE}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-04 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA04_ALIASING_DIAGNOSTIC_CONFIRMED" ]; then
  echo
  echo "PA-04 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Safe alias doubling was verified."
  echo "The unrestricted alias boundary was refuted as expected."
  echo "This remains an out-of-contract implementation diagnostic."
else
  echo
  echo "PA-04 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
