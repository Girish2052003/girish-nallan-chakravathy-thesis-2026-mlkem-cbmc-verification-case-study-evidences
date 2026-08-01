#!/usr/bin/env bash
#
# PA-06: Cross-parameter replication campaign for mlk_poly_add.
#
# Parameter sets:
#   ML-KEM-512
#   ML-KEM-768
#   ML-KEM-1024
#
# Five successful verification units are executed per parameter set:
#
#   1. Frozen PA-01 canonical FIPS-domain harness
#   2. Frozen PA-02 complete signed contract-valid harness
#   3. PA-06A production mlk_polyvec_add caller harness
#   4. PA-06B indcpa v+epp call-site harness
#   5. PA-06C sequential indcpa v+epp+k call-site harness
#
# Total:
#   15 verification units
#   each checked in text and JSON modes
#
# PA-03 and PA-04B negative controls are not repeated here because their
# int16_t representability counterexamples are parameter-invariant.
# PA-04A is an out-of-contract diagnostic and is not required for the
# production cross-parameter closure claim.
#
# Expected final status:
#   PA06_ALL_PARAMETER_SETS_VERIFIED
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa06_mlk_poly_add_cross_parameter_campaign.sh
#   ./run_pa06_mlk_poly_add_cross_parameter_campaign.sh
#

set -uo pipefail

CAMPAIGN_ID="PA-06"
CAMPAIGN_SCOPE="cross_parameter_core_and_production_callsite_replication"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

PA01_HARNESS="cleanroom_mlk_poly_add_fips_relational_harness_v2.c"
PA02_HARNESS="pa02_mlk_poly_add_full_signed_contract_valid_harness.c"
PA06A_HARNESS="pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c"
PA06B_HARNESS="pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c"
PA06C_HARNESS="pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c"

PA01_EXPECTED_SHA256="307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e"
PA02_EXPECTED_SHA256="e83d521e23f93c2435058598be5ef245bb02c554a4b7992dd8844418720c2ce2"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa06_mlk_poly_add_cross_parameter_${TIMESTAMP}"

for tool in git cbmc goto-cc sha256sum tee grep awk; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] ||
   [ ! -f "mlkem/src/poly_k.c" ] ||
   [ ! -f "mlkem/src/poly.h" ] ||
   [ ! -f "mlkem/src/poly_k.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

for harness in \
  "${PA01_HARNESS}" \
  "${PA02_HARNESS}" \
  "${PA06A_HARNESS}" \
  "${PA06B_HARNESS}" \
  "${PA06C_HARNESS}"; do
  if [ ! -f "${harness}" ]; then
    echo "ERROR: required harness missing: ${harness}" >&2
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

PA01_ACTUAL_SHA256="$(sha256sum "${PA01_HARNESS}" | awk '{print $1}')"
PA02_ACTUAL_SHA256="$(sha256sum "${PA02_HARNESS}" | awk '{print $1}')"

if [ "${PA01_ACTUAL_SHA256}" != "${PA01_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-01 harness hash mismatch." >&2
  echo "Expected: ${PA01_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA01_ACTUAL_SHA256}" >&2
  exit 4
fi

if [ "${PA02_ACTUAL_SHA256}" != "${PA02_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-02 harness hash mismatch." >&2
  echo "Expected: ${PA02_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA02_ACTUAL_SHA256}" >&2
  exit 4
fi

mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA06_ALL_PARAMETER_SETS_VERIFIED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Frozen PA-01 hash: ${PA01_ACTUAL_SHA256}"
  echo "Frozen PA-02 hash: ${PA02_ACTUAL_SHA256}"
  echo "Verification units: 15"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

for harness in \
  "${PA01_HARNESS}" \
  "${PA02_HARNESS}" \
  "${PA06A_HARNESS}" \
  "${PA06B_HARNESS}" \
  "${PA06C_HARNESS}"; do
  sha256sum "${harness}" >> "${OUT_DIR}/harness_sha256.txt"
  cp "${harness}" "${OUT_DIR}/"
done

sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
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

run_success_unit()
{
  local parameter_set="$1"
  local label="$2"
  local harness="$3"
  local source_mode="$4"
  local required_marker="$5"

  local result_dir="${OUT_DIR}/${parameter_set}/${label}"
  local goto_model="${result_dir}/${label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1
  local verification_successful="no"
  local marker_success="no"
  local failure_lines="yes"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${parameter_set}"
    "${harness}"
    mlkem/src/poly.c
  )

  if [ "${source_mode}" = "poly_k_caller" ]; then
    build_command+=(mlkem/src/poly_k.c)
  fi

  build_command+=(-o "${goto_model}")

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-06 ${parameter_set}: ${label}"
  echo "============================================================"
  echo "Building GOTO model..."

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

    echo "Running CBMC text verification..."
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

    echo "Running CBMC JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 0 ] &&
     [ "${json_exit}" -eq 0 ] &&
     grep -q "VERIFICATION SUCCESSFUL" "${result_dir}/cbmc_output.txt"; then
    verification_successful="yes"
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
    echo "parameter_set=${parameter_set}"
    echo "label=${label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_successful=${verification_successful}"
    echo "required_marker_success=${marker_success}"
    echo "failure_lines_observed=${failure_lines}"
  } > "${result_dir}/summary.txt"

  cat "${result_dir}/summary.txt"

  if [ "${verification_successful}" = "yes" ] &&
     [ "${marker_success}" = "yes" ] &&
     [ "${failure_lines}" = "no" ]; then
    return 0
  fi

  return 1
}

ALL_OK="yes"

for PARAM in 512 768 1024; do
  PARAM_OK="yes"

  if ! run_success_unit \
    "${PARAM}" \
    "pa01_canonical_fips" \
    "${PA01_HARNESS}" \
    "poly_only" \
    "P1_EXACT_SUM"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa02_full_signed_valid" \
    "${PA02_HARNESS}" \
    "poly_only" \
    "PA02_P1_EXACT_SIGNED_SUM"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa06a_polyvec_production_caller" \
    "${PA06A_HARNESS}" \
    "poly_k_caller" \
    "PA06A_P1_CROSS_PARAMETER_EXACT_SUM"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa06b_indcpa_epp_callsite" \
    "${PA06B_HARNESS}" \
    "poly_only" \
    "PA06B_P1_CROSS_PARAMETER_CALL_UPPER"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa06c_indcpa_sequential_callsite" \
    "${PA06C_HARNESS}" \
    "poly_only" \
    "PA06C_P2_SECOND_CALL_UPPER"; then
    PARAM_OK="no"
  fi

  echo "parameter_set_${PARAM}_verified=${PARAM_OK}" \
    >> "${OUT_DIR}/parameter_status.txt"

  if [ "${PARAM_OK}" != "yes" ]; then
    ALL_OK="no"
  fi
done

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${ALL_OK}" = "yes" ]; then
  FINAL_STATUS="PA06_ALL_PARAMETER_SETS_VERIFIED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "verification_units=15"
  cat "${OUT_DIR}/parameter_status.txt"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-06 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA06_ALL_PARAMETER_SETS_VERIFIED" ]; then
  echo
  echo "PA-06 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Core function and production call-site obligations were verified"
  echo "for ML-KEM-512, ML-KEM-768, and ML-KEM-1024."
else
  echo
  echo "PA-06 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
