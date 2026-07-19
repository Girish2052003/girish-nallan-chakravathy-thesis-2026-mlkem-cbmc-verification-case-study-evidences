#!/usr/bin/env bash
set -euo pipefail

FREEZE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAMPAIGN_DIR="$(cd "${FREEZE_DIR}/.." && pwd)"

CASE_ID="INVALID UPPER CONTROL / MODE-A / ML-KEM-768 / RUN-1"
MODEL="${FREEZE_DIR}/models/sub_boundary_invalid_upper_harness_mlkem768.goto"
HARNESS="${FREEZE_DIR}/harnesses/sub_boundary_invalid_upper_harness.c"
ADAPTER="${FREEZE_DIR}/adapter/sub00e_r1_fail_closed_zeroize.h"
ARTIFACT_MANIFEST="${FREEZE_DIR}/SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256"

EXPECTED_MODEL_SHA256="fbb21d3cfbd94baeff1bdf9b3484659e5cf6062d4f935c7d895527118caadc8b"
EXPECTED_HARNESS_SHA256="4db500d2d8c7a1d79dda38ec466aa79ed2b48f9cec46fa932ad4be7012a7e623"
EXPECTED_ADAPTER_SHA256="45d33b9ee3fe3613f23906de520bf9d5ce245a18b537c32787201912dec4e926"
EXPECTED_OUTCOME="Negative control: verification failure is expected, but acceptance requires the failure to be traced to the intended out-of-range subtraction conversion or an equivalent frozen safety obligation."

UNWINDSET="main.0:257,mlk_sub00e_r1_poly_sub.0:257"

RESULT_DIR="${CAMPAIGN_DIR}/SUB00L_INVALID_UPPER_MODE_A_MLKEM768_RUN1"
JSON_RESULT="${RESULT_DIR}/cbmc_result.json"
STDERR_LOG="${RESULT_DIR}/cbmc_stderr.txt"
RESOURCE_LOG="${RESULT_DIR}/resource_usage.txt"
EXIT_FILE="${RESULT_DIR}/cbmc_exit_code.txt"
COMMAND_FILE="${RESULT_DIR}/cbmc_command.txt"
ENV_FILE="${RESULT_DIR}/environment.txt"
RESULT_MANIFEST="${RESULT_DIR}/RESULT_ARTIFACT_MANIFEST.sha256"

fail()
{
  echo "ERROR: $*" >&2
  exit 1
}

verify_hash()
{
  local expected="$1"
  local file="$2"
  local actual

  test -f "${file}" || fail "missing frozen file: ${file}"
  actual="$(sha256sum "${file}" | awk '{print $1}')"

  test "${actual}" = "${expected}" || {
    echo "Expected: ${expected}" >&2
    echo "Actual:   ${actual}" >&2
    echo "File:     ${file}" >&2
    fail "frozen-artifact integrity failure"
  }
}

command -v cbmc >/dev/null 2>&1 || fail "cbmc is unavailable"
command -v goto-instrument >/dev/null 2>&1 || fail "goto-instrument is unavailable"
command -v timeout >/dev/null 2>&1 || fail "timeout is unavailable"
test -x /usr/bin/time || fail "/usr/bin/time is unavailable"

test ! -e "${RESULT_DIR}" || fail "result directory already exists: ${RESULT_DIR}"

verify_hash "${EXPECTED_MODEL_SHA256}" "${MODEL}"
verify_hash "${EXPECTED_HARNESS_SHA256}" "${HARNESS}"
verify_hash "${EXPECTED_ADAPTER_SHA256}" "${ADAPTER}"

(
  cd "${FREEZE_DIR}"
  sha256sum --check "$(basename "${ARTIFACT_MANIFEST}")"
)

goto-instrument --validate-goto-binary "${MODEL}" >/dev/null

mkdir -p "${RESULT_DIR}"

COMMON_FLAGS=(
  --function main
  --object-bits 8
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --pointer-primitive-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --undefined-shift-check
  --div-by-zero-check
  --unwinding-assertions
  --unwindset "${UNWINDSET}"
  --slice-formula
  --sat-solver minisat2
  --trace
  --json-ui
)

CMD=(
  cbmc
  "${MODEL}"
  "${COMMON_FLAGS[@]}"
)

{
  printf 'COMMAND:'
  printf ' %q' "${CMD[@]}"
  printf '\n'
} >"${COMMAND_FILE}"

{
  echo "Case ID: ${CASE_ID}"
  echo "Expected experimental outcome: ${EXPECTED_OUTCOME}"
  echo "Frozen artifact-manifest SHA-256:"
  sha256sum "${ARTIFACT_MANIFEST}"
  echo
  echo "Model SHA-256:"
  sha256sum "${MODEL}"
  echo
  echo "Harness SHA-256:"
  sha256sum "${HARNESS}"
  echo
  echo "Adapter SHA-256:"
  sha256sum "${ADAPTER}"
  echo
  echo "UTC start:"
  date -u +%Y-%m-%dT%H:%M:%SZ
  echo
  echo "CBMC:"
  cbmc --version
  echo
  echo "GOTO-INSTRUMENT:"
  goto-instrument --version
  echo
  echo "UNAME:"
  uname -a
} >"${ENV_FILE}"

set +e
/usr/bin/time -v \
  -o "${RESOURCE_LOG}" \
  timeout \
  --signal=TERM \
  --kill-after=60s \
  21600s \
  "${CMD[@]}" \
  >"${JSON_RESULT}" \
  2>"${STDERR_LOG}"
RC="$?"
set -e

printf '%s\n' "${RC}" >"${EXIT_FILE}"

(
  cd "${RESULT_DIR}"

  find . -maxdepth 1 -type f \
    ! -name "$(basename "${RESULT_MANIFEST}")" \
    -printf '%P\0' |
    LC_ALL=C sort -z |
    xargs -0 -r sha256sum
) >"${RESULT_MANIFEST}"

echo
echo "============================================================"
echo "CBMC EXECUTION FINISHED"
echo "============================================================"
echo "Case: ${CASE_ID}"
echo "Raw exit code: ${RC}"
echo "Expected experimental outcome: ${EXPECTED_OUTCOME}"
echo "Evidence directory: ${RESULT_DIR}"
echo
echo "No semantic conclusion is made by this wrapper."
echo "The JSON result and failing property identifiers must be reviewed."

exit "${RC}"
