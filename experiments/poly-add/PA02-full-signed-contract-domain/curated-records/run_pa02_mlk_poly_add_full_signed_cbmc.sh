#!/usr/bin/env bash
#
# PA-02 runner:
# Verify mlk_poly_add over the complete signed/non-canonical
# contract-valid int16_t domain.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa02_mlk_poly_add_full_signed_cbmc.sh
#   ./run_pa02_mlk_poly_add_full_signed_cbmc.sh 768
#
# The optional first argument is 512, 768, or 1024. Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-02"
CAMPAIGN_SCOPE="full_signed_noncanonical_contract_valid_domain"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="pa02_mlk_poly_add_full_signed_contract_valid_harness.c"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa02_mlk_poly_add_signed_valid_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/pa02_mlk_poly_add.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee; do
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
    echo "ERROR: repository commit does not match the PA-02 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

# Directly analyse the portable production C body:
#   - do not define the repository's CBMC annotation mode;
#   - do not enable native arithmetic;
#   - do not link any repository proof harness.
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

echo "===== PA-02: BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  {
    echo "campaign=${CAMPAIGN_ID}"
    echo "build_exit=${BUILD_EXIT}"
    echo "final_status=BUILD_FAILED"
  } > "${OUT_DIR}/summary.txt"

  echo "BUILD FAILED. Preserve and return goto_cc_build.log."
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
echo "===== PA-02: RUNNING CBMC TEXT VERIFICATION ====="
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
echo "===== PA-02: RUNNING CBMC JSON VERIFICATION ====="
"${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_output.json" 2> \
  "${OUT_DIR}/cbmc_json_stderr.txt"
CBMC_JSON_EXIT=$?
echo "${CBMC_JSON_EXIT}" > "${OUT_DIR}/cbmc_json.exit"

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_text_exit=${CBMC_TEXT_EXIT}"
  echo "cbmc_json_exit=${CBMC_JSON_EXIT}"

  if [ "${BUILD_EXIT}" -eq 0 ] &&
     [ "${CBMC_TEXT_EXIT}" -eq 0 ] &&
     [ "${CBMC_JSON_EXIT}" -eq 0 ]; then
    echo "final_status=VERIFICATION_SUCCESSFUL"
  else
    echo "final_status=FAILED_OR_INCONCLUSIVE"
  fi
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-02 SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

exit "${CBMC_TEXT_EXIT}"
