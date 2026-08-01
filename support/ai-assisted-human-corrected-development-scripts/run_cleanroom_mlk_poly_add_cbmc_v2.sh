#!/usr/bin/env bash
#
# Build and verify the independently authored mlk_poly_add harness.
#
# Run this script from the root of the mlkem-native repository:
#
#   chmod +x run_cleanroom_mlk_poly_add_cbmc_v2.sh
#   ./run_cleanroom_mlk_poly_add_cbmc_v2.sh 768
#
# The optional first argument is 512, 768, or 1024. The default is 768.
#

set -uo pipefail

EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="cleanroom_mlk_poly_add_fips_relational_harness_v2.c"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/mlk_poly_add_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/cleanroom_poly_add.goto"

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
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1
sha256sum "${HARNESS}" > "${OUT_DIR}/harness_sha256.txt"
cp "${HARNESS}" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  echo "ERROR: repository commit does not match the clean-room target." | tee \
    "${OUT_DIR}/commit_mismatch.txt"
  echo "Expected: ${EXPECTED_COMMIT}" | tee -a "${OUT_DIR}/commit_mismatch.txt"
  echo "Actual:   ${CURRENT_COMMIT}" | tee -a "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

# Deliberately do NOT define the preprocessor macro CBMC here.
# This keeps the repository's embedded __contract__ and __loop__ annotations
# disabled while the target C body is directly bounded-model-checked.
#
# common.h already defines MLK_BUILD_INTERNAL for this source build.
# Do not redefine it on the command line, which only creates a warning.
# Native arithmetic remains disabled because
# MLK_CONFIG_USE_NATIVE_BACKEND_ARITH is not defined.
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

echo "===== BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  echo "BUILD FAILED. Send goto_cc_build.log back for diagnosis."
  exit "${BUILD_EXIT}"
fi

CBMC_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
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
  --trace
)

printf '%q ' "${CBMC_COMMAND[@]}" > "${OUT_DIR}/cbmc_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_command.txt"

echo
echo "===== RUNNING CBMC ====="
"${CBMC_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/cbmc_output.txt"
CBMC_EXIT=${PIPESTATUS[0]}
echo "${CBMC_EXIT}" > "${OUT_DIR}/cbmc.exit"

# Create a machine-readable second result. Its exit code should agree with
# the text run. This second invocation omits --trace to keep JSON smaller.
CBMC_JSON_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
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
  --json-ui
)

"${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_output.json" 2> \
  "${OUT_DIR}/cbmc_json_stderr.txt"
CBMC_JSON_EXIT=$?
echo "${CBMC_JSON_EXIT}" > "${OUT_DIR}/cbmc_json.exit"

{
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_text_exit=${CBMC_EXIT}"
  echo "cbmc_json_exit=${CBMC_JSON_EXIT}"
  if [ "${BUILD_EXIT}" -eq 0 ] &&
     [ "${CBMC_EXIT}" -eq 0 ] &&
     [ "${CBMC_JSON_EXIT}" -eq 0 ]; then
    echo "final_status=VERIFICATION_SUCCESSFUL"
  else
    echo "final_status=FAILED_OR_INCONCLUSIVE"
  fi
} > "${OUT_DIR}/summary.txt"

echo
echo "===== SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

exit "${CBMC_EXIT}"
