#!/usr/bin/env bash
#
# PA-02E runner:
# Verify additive identity of mlk_poly_add over the complete signed and
# non-canonical int16_t domain, with no semantic input assumptions.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa02e_mlk_poly_add_additive_identity_cbmc.sh
#   ./run_pa02e_mlk_poly_add_additive_identity_cbmc.sh 768
#
# The optional first argument is 512, 768, or 1024. Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-02E"
CAMPAIGN_SCOPE="additive_identity_complete_signed_noncanonical_domain"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="pa02e_mlk_poly_add_additive_identity_full_signed_harness.c"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa02e_mlk_poly_add_additive_identity_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/pa02e_mlk_poly_add.goto"
CBMC_OUTPUT="${OUT_DIR}/cbmc_output.txt"

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
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Harness: ${HARNESS}"
  echo "Semantic assumption count expected: 0"
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
    echo "ERROR: repository commit does not match the PA-02E target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

# Fail closed if a semantic assumption is accidentally introduced later.
if grep -Eq '__CPROVER_assume[[:space:]]*\(' "${HARNESS}"; then
  {
    echo "ERROR: PA-02E must remain assumption-free."
    echo "A __CPROVER_assume statement was found in ${HARNESS}."
  } | tee "${OUT_DIR}/unexpected_assumption.txt"
  exit 5
fi

# Directly analyse the portable production C body:
#   - do not define the repository's CBMC annotation mode;
#   - do not enable native arithmetic;
#   - do not link a repository proof harness.
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

echo "===== PA-02E: BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  {
    echo "campaign=${CAMPAIGN_ID}"
    echo "scope=${CAMPAIGN_SCOPE}"
    echo "parameter_set=${PARAM_SET}"
    echo "semantic_assumptions=0"
    echo "build_exit=${BUILD_EXIT}"
    echo "cbmc_exit=NOT_RUN"
    echo "verification_success_marker=0"
    echo "final_status=BUILD_FAILED"
  } > "${OUT_DIR}/summary.txt"

  echo "BUILD FAILED. Preserve and return goto_cc_build.log."
  exit "${BUILD_EXIT}"
fi

# One authoritative CBMC run: no duplicate text/JSON proof execution.
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
)

printf '%q ' "${CBMC_COMMAND[@]}" > "${OUT_DIR}/cbmc_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_command.txt"

echo
echo "===== PA-02E: RUNNING AUTHORITATIVE CBMC VERIFICATION ====="
"${CBMC_COMMAND[@]}" 2>&1 | tee "${CBMC_OUTPUT}"
CBMC_EXIT=${PIPESTATUS[0]}
echo "${CBMC_EXIT}" > "${OUT_DIR}/cbmc.exit"

VERIFICATION_SUCCESS_MARKER=0
if grep -Fqx "VERIFICATION SUCCESSFUL" "${CBMC_OUTPUT}"; then
  VERIFICATION_SUCCESS_MARKER=1
fi
echo "${VERIFICATION_SUCCESS_MARKER}" > \
  "${OUT_DIR}/verification_success_marker.txt"

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "semantic_assumptions=0"
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_exit=${CBMC_EXIT}"
  echo "verification_success_marker=${VERIFICATION_SUCCESS_MARKER}"

  if [ "${BUILD_EXIT}" -eq 0 ] &&
     [ "${CBMC_EXIT}" -eq 0 ] &&
     [ "${VERIFICATION_SUCCESS_MARKER}" -eq 1 ]; then
    echo "final_status=VERIFICATION_SUCCESSFUL"
  else
    echo "final_status=FAILED_OR_INCONCLUSIVE"
  fi
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-02E SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${BUILD_EXIT}" -eq 0 ] &&
   [ "${CBMC_EXIT}" -eq 0 ] &&
   [ "${VERIFICATION_SUCCESS_MARKER}" -eq 1 ]; then
  exit 0
fi

if [ "${CBMC_EXIT}" -ne 0 ]; then
  exit "${CBMC_EXIT}"
fi

# Fail closed when CBMC exits zero but the explicit success marker is absent.
exit 4
