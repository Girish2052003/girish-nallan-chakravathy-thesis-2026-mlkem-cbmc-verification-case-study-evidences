#!/usr/bin/env bash
#
# PA-05 combined production call-site campaign for mlk_poly_add.
#
# PA-05A:
#   Production mlk_polyvec_add caller in poly_k.c.
#
# PA-05B:
#   First indcpa encryption call: mlk_poly_add(v, epp).
#
# PA-05C:
#   Sequential indcpa encryption calls:
#       mlk_poly_add(v, epp);
#       mlk_poly_add(v, k);
#
# Expected final status:
#   PA05_PRODUCTION_CALLSITES_VERIFIED
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa05_mlk_poly_add_production_callsites.sh
#   ./run_pa05_mlk_poly_add_production_callsites.sh 768
#

set -uo pipefail

CAMPAIGN_ID="PA-05"
CAMPAIGN_SCOPE="production_callsite_precondition_and_semantic_verification"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"

HARNESS_A="pa05a_mlk_poly_add_polyvec_production_callsite_harness.c"
HARNESS_B="pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c"
HARNESS_C="pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa05_mlk_poly_add_callsites_${PARAM_SET}_${TIMESTAMP}"

case "${PARAM_SET}" in
  768) ;;
  *)
    echo "ERROR: PA-05 is currently frozen for ML-KEM-768." >&2
    echo "Cross-parameter replication belongs to PA-06." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee grep; do
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

for harness in "${HARNESS_A}" "${HARNESS_B}" "${HARNESS_C}"; do
  if [ ! -f "${harness}" ]; then
    echo "ERROR: required harness missing: ${harness}" >&2
    exit 2
  fi
done

CURRENT_COMMIT="$(git rev-parse HEAD)"
mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA05_PRODUCTION_CALLSITES_VERIFIED"
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

sha256sum "${HARNESS_A}" > "${OUT_DIR}/pa05a_harness_sha256.txt"
sha256sum "${HARNESS_B}" > "${OUT_DIR}/pa05b_harness_sha256.txt"
sha256sum "${HARNESS_C}" > "${OUT_DIR}/pa05c_harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"

cp "${HARNESS_A}" "${OUT_DIR}/"
cp "${HARNESS_B}" "${OUT_DIR}/"
cp "${HARNESS_C}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-05 target."
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

run_experiment()
{
  local label="$1"
  local harness="$2"
  local source_mode="$3"
  local marker="$4"
  local result_dir="${OUT_DIR}/${label}"
  local goto_model="${result_dir}/${label}.goto"

  local build_exit
  local text_exit
  local json_exit
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
  )

  if [ "${source_mode}" = "poly_k_caller" ]; then
    build_command+=(mlkem/src/poly_k.c)
  fi

  build_command+=(-o "${goto_model}")

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo "===== ${label}: BUILDING GOTO MODEL ====="
  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  text_exit=-1
  json_exit=-1

  if [ "${build_exit}" -eq 0 ]; then
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
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 0 ] &&
     [ "${json_exit}" -eq 0 ] &&
     grep -q "VERIFICATION SUCCESSFUL" "${result_dir}/cbmc_output.txt"; then
    successful="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${marker}" "${result_dir}/cbmc_output.txt" | grep -q "SUCCESS"; then
    marker_success="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     ! grep -q "FAILURE" "${result_dir}/cbmc_output.txt"; then
    failure_lines="no"
  fi

  {
    echo "label=${label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_successful=${successful}"
    echo "required_marker_success=${marker_success}"
    echo "failure_lines_observed=${failure_lines}"
  } > "${result_dir}/summary.txt"

  echo
  cat "${result_dir}/summary.txt"

  if [ "${successful}" = "yes" ] &&
     [ "${marker_success}" = "yes" ] &&
     [ "${failure_lines}" = "no" ]; then
    return 0
  fi

  return 1
}

PA05A_OK="no"
PA05B_OK="no"
PA05C_OK="no"

if run_experiment \
  "pa05a_polyvec_callsite" \
  "${HARNESS_A}" \
  "poly_k_caller" \
  "PA05A_P1_CALLER_EXACT_SUM"; then
  PA05A_OK="yes"
fi

if run_experiment \
  "pa05b_indcpa_epp_callsite" \
  "${HARNESS_B}" \
  "poly_only" \
  "PA05B_P1_CALL_PRECONDITION_UPPER"; then
  PA05B_OK="yes"
fi

if run_experiment \
  "pa05c_indcpa_k_sequential_callsite" \
  "${HARNESS_C}" \
  "poly_only" \
  "PA05C_P2_SECOND_CALL_UPPER"; then
  PA05C_OK="yes"
fi

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${PA05A_OK}" = "yes" ] &&
   [ "${PA05B_OK}" = "yes" ] &&
   [ "${PA05C_OK}" = "yes" ]; then
  FINAL_STATUS="PA05_PRODUCTION_CALLSITES_VERIFIED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "pa05a_polyvec_callsite_verified=${PA05A_OK}"
  echo "pa05b_indcpa_epp_callsite_verified=${PA05B_OK}"
  echo "pa05c_indcpa_k_sequential_callsite_verified=${PA05C_OK}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-05 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA05_PRODUCTION_CALLSITES_VERIFIED" ]; then
  echo
  echo "PA-05 SCIENTIFIC OUTCOME: SUCCESS"
  echo "All three production mlk_poly_add call-site obligations were verified."
else
  echo
  echo "PA-05 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
