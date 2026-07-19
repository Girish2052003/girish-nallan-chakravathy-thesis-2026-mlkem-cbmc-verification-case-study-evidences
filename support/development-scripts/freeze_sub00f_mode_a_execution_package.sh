#!/usr/bin/env bash
set -euo pipefail

DIR="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"

ARCH="${DIR}/SUB00C_INDEPENDENT_HARNESS_ARCHITECTURE.md"
BUILD_CONTEXT="${DIR}/SUB00D_BUILD_CONTEXT_DISCOVERY.txt"
HARNESS_MANIFEST="${DIR}/SUB00C_HARNESS_DRAFT_MANIFEST.sha256"

R1_PACKET="${DIR}/SUB00E_R1_GOTO_MODEL_INSPECTION_PACKET.txt"
R1_PACKET_SIDECAR="${R1_PACKET}.sha256"
R1_ARTIFACT_MANIFEST="${DIR}/SUB00E_R1_GOTO_ARTIFACT_MANIFEST.sha256"
R1_ADAPTER_MANIFEST="${DIR}/SUB00E_R1_BUILD_ADAPTER_MANIFEST.sha256"

R2_PACKET="${DIR}/SUB00E_R2_VALIDATION_REACHABILITY_AUDIT_PACKET.txt"
R2_PACKET_SIDECAR="${R2_PACKET}.sha256"
R2_AUDIT_MANIFEST="${DIR}/SUB00E_R2_VALIDATION_REACHABILITY_AUDIT_MANIFEST.sha256"

SOURCE_MODELS="${DIR}/sub00e_r1_goto_model_inspection_v2"
HARNESS_DIR="${DIR}/harness_drafts_v1"
ADAPTER_DIR="${DIR}/build_adapters_v2"

FINAL_DIR="${DIR}/sub00f_mode_a_execution_freeze_v1"
ROOT_EXEC_MANIFEST="${DIR}/SUB00F_MODE_A_EXECUTION_MANIFEST.md"
ROOT_ARTIFACT_MANIFEST="${DIR}/SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256"
PACKAGE="${DIR}/SUB00F_MODE_A_EXECUTION_FREEZE_PACKAGE.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

EXPECTED_ARCH_SHA256="a1d11264cf27038fed35ccddced2c6f79c5e28f42382e5000ce7fe7a44689d84"
EXPECTED_BUILD_CONTEXT_SHA256="9714f50795c722290060868e6b786b30ad7b1b13b267ee82f6c2dd1e3dd109c2"
EXPECTED_R1_PACKET_SHA256="becc00cb6280f405548cc535f38875bb3e476901cbb11392fc2ed38b8b3262d5"
EXPECTED_R1_ARTIFACT_MANIFEST_SHA256="cf0baf1e79da927fd055019eecd0d2d7cd6d084a5f8d7c957ac8b5691b66e5e9"
EXPECTED_R1_ADAPTER_MANIFEST_SHA256="d7b574ab6ad03d7cbddf162158d81f3b3a4e63bccb0be24a6dedee86a4dddf34"
EXPECTED_R2_PACKET_SHA256="8ed69dc32ab3d1d29a39fd3d38b21c135b1598f111895d93e3eaae9b11a99585"
EXPECTED_R2_AUDIT_MANIFEST_SHA256="569f73b5456de37ec101f9bd21cccea44be4767577a68a20c7477cc8f6d0b599"

T1_HARNESS_SHA256="42c09c2f004d567d8b886058bd2304d960a219d36f0f6605b015966db3bc5682"
T2_HARNESS_SHA256="ca54ad2d875f104cf6daca915bcfb71e491c3f899b3d877b70439868d80d1037"
COV_HARNESS_SHA256="132c34161c8230eb14e86acc0cae3af52fbf6eb429a8e55233080337dc4415d7"
VALID_HARNESS_SHA256="8f8d3a87cca7bfe5938f0db5ce0d8fe1829c03c3366d40a3aa17a084e7b48d6b"
INVALID_LOWER_HARNESS_SHA256="8469f8c5a40a1da2fdd95b05eb6c5c5e8783128196989f19bf437886e4ed6a9d"
INVALID_UPPER_HARNESS_SHA256="4db500d2d8c7a1d79dda38ec466aa79ed2b48f9cec46fa932ad4be7012a7e623"

T1_MODEL_SHA256="6a33187f74b4aa7a5286bfe7333ab657d83efa95896ac0ef476787140c9dcde6"
T2_MODEL_SHA256="936a257116991062d6d1790ac295b89213176038ecc0c4a232118136040bd8cb"
COV_MODEL_SHA256="b86afb6d526a1709b6523ce2fd8d7d3b05403e2e09f554082ab7c8dc0e527a59"
VALID_MODEL_SHA256="178b8e1753d2a5c609bb400f08c2d6cf3691cb82917e73054a8c7f86bdd86bcc"
INVALID_LOWER_MODEL_SHA256="6b73cf29b12ba355c3ec1917a8232c4624cb7311b29a44bc410ea924d8bfdd72"
INVALID_UPPER_MODEL_SHA256="fbb21d3cfbd94baeff1bdf9b3484659e5cf6062d4f935c7d895527118caadc8b"

ADAPTER_SHA256="45d33b9ee3fe3613f23906de520bf9d5ce245a18b537c32787201912dec4e926"
ADAPTER_NOTE_SHA256="0c5d40fc70fe3f51ad35bf35b37983c3ec763c59493e451efd389f9524822b23"

fail()
{
  echo "ERROR: $*" >&2
  exit 1
}

verify_exact_hash()
{
  local expected="$1"
  local file="$2"
  local actual

  test -f "${file}" || fail "required file is missing: ${file}"
  actual="$(sha256sum "${file}" | awk '{print $1}')"

  test "${actual}" = "${expected}" || {
    echo "Expected: ${expected}" >&2
    echo "Actual:   ${actual}" >&2
    echo "File:     ${file}" >&2
    fail "integrity verification failed"
  }
}

copy_and_verify()
{
  local expected="$1"
  local source="$2"
  local destination="$3"

  verify_exact_hash "${expected}" "${source}"
  cp -a "${source}" "${destination}"
  verify_exact_hash "${expected}" "${destination}"
}

verify_reachable_loop_set()
{
  local model="$1"
  local expected_csv="$2"
  local work
  local actual
  local expected

  work="$(mktemp)"
  actual="$(mktemp)"
  expected="$(mktemp)"

  goto-instrument --drop-unused-functions "${model}" "${work}" >/dev/null 2>&1
  goto-instrument --validate-goto-binary "${work}" >/dev/null

  goto-instrument --show-loops "${work}" 2>/dev/null |
    sed -n 's/^Loop \(.*\):$/\1/p' |
    LC_ALL=C sort >"${actual}"

  printf '%s\n' "${expected_csv}" |
    tr ',' '\n' |
    LC_ALL=C sort >"${expected}"

  if ! diff -u "${expected}" "${actual}"
  then
    rm -f "${work}" "${actual}" "${expected}"
    fail "reachable loop-set mismatch for ${model}"
  fi

  if goto-instrument --reachable-call-graph "${model}" 2>/dev/null |
       grep -Eq '(^|[^[:alnum:]_])mlk_zeroize([^[:alnum:]_]|$)'
  then
    rm -f "${work}" "${actual}" "${expected}"
    fail "mlk_zeroize unexpectedly reachable in ${model}"
  fi

  rm -f "${work}" "${actual}" "${expected}"
}

make_runner()
{
  local script_name="$1"
  local case_id="$2"
  local model_name="$3"
  local model_sha="$4"
  local harness_name="$5"
  local harness_sha="$6"
  local unwindset="$7"
  local operation="$8"
  local expected_outcome="$9"
  local result_dir_name="${10}"

  local script_path="${FINAL_DIR}/execution/${script_name}"

  cat >"${script_path}" <<EOF
#!/usr/bin/env bash
set -euo pipefail

FREEZE_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
CAMPAIGN_DIR="\$(cd "\${FREEZE_DIR}/.." && pwd)"

CASE_ID="${case_id}"
MODEL="\${FREEZE_DIR}/models/${model_name}"
HARNESS="\${FREEZE_DIR}/harnesses/${harness_name}"
ADAPTER="\${FREEZE_DIR}/adapter/sub00e_r1_fail_closed_zeroize.h"
ARTIFACT_MANIFEST="\${FREEZE_DIR}/SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256"

EXPECTED_MODEL_SHA256="${model_sha}"
EXPECTED_HARNESS_SHA256="${harness_sha}"
EXPECTED_ADAPTER_SHA256="${ADAPTER_SHA256}"
EXPECTED_OUTCOME="${expected_outcome}"

UNWINDSET="${unwindset}"

RESULT_DIR="\${CAMPAIGN_DIR}/${result_dir_name}"
JSON_RESULT="\${RESULT_DIR}/cbmc_result.json"
STDERR_LOG="\${RESULT_DIR}/cbmc_stderr.txt"
RESOURCE_LOG="\${RESULT_DIR}/resource_usage.txt"
EXIT_FILE="\${RESULT_DIR}/cbmc_exit_code.txt"
COMMAND_FILE="\${RESULT_DIR}/cbmc_command.txt"
ENV_FILE="\${RESULT_DIR}/environment.txt"
RESULT_MANIFEST="\${RESULT_DIR}/RESULT_ARTIFACT_MANIFEST.sha256"

fail()
{
  echo "ERROR: \$*" >&2
  exit 1
}

verify_hash()
{
  local expected="\$1"
  local file="\$2"
  local actual

  test -f "\${file}" || fail "missing frozen file: \${file}"
  actual="\$(sha256sum "\${file}" | awk '{print \$1}')"

  test "\${actual}" = "\${expected}" || {
    echo "Expected: \${expected}" >&2
    echo "Actual:   \${actual}" >&2
    echo "File:     \${file}" >&2
    fail "frozen-artifact integrity failure"
  }
}

command -v cbmc >/dev/null 2>&1 || fail "cbmc is unavailable"
command -v goto-instrument >/dev/null 2>&1 || fail "goto-instrument is unavailable"
command -v timeout >/dev/null 2>&1 || fail "timeout is unavailable"
test -x /usr/bin/time || fail "/usr/bin/time is unavailable"

test ! -e "\${RESULT_DIR}" || fail "result directory already exists: \${RESULT_DIR}"

verify_hash "\${EXPECTED_MODEL_SHA256}" "\${MODEL}"
verify_hash "\${EXPECTED_HARNESS_SHA256}" "\${HARNESS}"
verify_hash "\${EXPECTED_ADAPTER_SHA256}" "\${ADAPTER}"

(
  cd "\${FREEZE_DIR}"
  sha256sum --check "\$(basename "\${ARTIFACT_MANIFEST}")"
)

goto-instrument --validate-goto-binary "\${MODEL}" >/dev/null

mkdir -p "\${RESULT_DIR}"

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
  --unwindset "\${UNWINDSET}"
  --slice-formula
  --sat-solver minisat2
  --trace
  --json-ui
)

CMD=(
  cbmc
  "\${MODEL}"
  "\${COMMON_FLAGS[@]}"
)
EOF

  if test "${operation}" = "coverage"
  then
    cat >>"${script_path}" <<'EOF'
CMD+=(--cover cover)
EOF
  fi

  cat >>"${script_path}" <<'EOF'

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
EOF

  chmod 0555 "${script_path}"
  bash -n "${script_path}"
}

command -v sha256sum >/dev/null 2>&1 || fail "sha256sum is unavailable"
command -v tar >/dev/null 2>&1 || fail "tar is unavailable"
command -v gzip >/dev/null 2>&1 || fail "gzip is unavailable"
command -v cbmc >/dev/null 2>&1 || fail "cbmc is unavailable"
command -v goto-instrument >/dev/null 2>&1 || fail "goto-instrument is unavailable"
command -v timeout >/dev/null 2>&1 || fail "timeout is unavailable"
test -x /usr/bin/time || fail "/usr/bin/time is unavailable"

test ! -e "${FINAL_DIR}" || fail "final freeze directory already exists: ${FINAL_DIR}"
test ! -e "${ROOT_EXEC_MANIFEST}" || fail "root execution manifest already exists"
test ! -e "${ROOT_ARTIFACT_MANIFEST}" || fail "root artifact manifest already exists"
test ! -e "${PACKAGE}" || fail "final package already exists"
test ! -e "${PACKAGE_HASH}" || fail "final package sidecar already exists"

verify_exact_hash "${EXPECTED_ARCH_SHA256}" "${ARCH}"
verify_exact_hash "${EXPECTED_BUILD_CONTEXT_SHA256}" "${BUILD_CONTEXT}"
verify_exact_hash "${EXPECTED_R1_PACKET_SHA256}" "${R1_PACKET}"
verify_exact_hash "${EXPECTED_R1_ARTIFACT_MANIFEST_SHA256}" "${R1_ARTIFACT_MANIFEST}"
verify_exact_hash "${EXPECTED_R1_ADAPTER_MANIFEST_SHA256}" "${R1_ADAPTER_MANIFEST}"
verify_exact_hash "${EXPECTED_R2_PACKET_SHA256}" "${R2_PACKET}"
verify_exact_hash "${EXPECTED_R2_AUDIT_MANIFEST_SHA256}" "${R2_AUDIT_MANIFEST}"

(
  cd "${DIR}"
  sha256sum --check "$(basename "${R1_PACKET_SIDECAR}")"
  sha256sum --check "$(basename "${R2_PACKET_SIDECAR}")"
  sha256sum --check "$(basename "${R1_ARTIFACT_MANIFEST}")"
  sha256sum --check "$(basename "${R1_ADAPTER_MANIFEST}")"
  sha256sum --check "$(basename "${R2_AUDIT_MANIFEST}")"
)

CBMC_HELP="$(mktemp)"
trap 'rm -f "${CBMC_HELP}"' EXIT
cbmc --help >"${CBMC_HELP}" 2>&1 || true

for option in \
  "--function" \
  "--object-bits" \
  "--bounds-check" \
  "--pointer-check" \
  "--pointer-overflow-check" \
  "--pointer-primitive-check" \
  "--signed-overflow-check" \
  "--unsigned-overflow-check" \
  "--conversion-check" \
  "--undefined-shift-check" \
  "--div-by-zero-check" \
  "--unwinding-assertions" \
  "--unwindset" \
  "--slice-formula" \
  "--sat-solver" \
  "--trace" \
  "--json-ui" \
  "--cover"
do
  grep -q -- "${option}" "${CBMC_HELP}" ||
    fail "CBMC 6.9.0 help does not advertise required option: ${option}"
done

cbmc --sat-solver minisat2 --version >/dev/null 2>&1 ||
  fail "CBMC rejected the frozen minisat2 solver selection"

mkdir -p \
  "${FINAL_DIR}/harnesses" \
  "${FINAL_DIR}/adapter" \
  "${FINAL_DIR}/models" \
  "${FINAL_DIR}/execution" \
  "${FINAL_DIR}/provenance"

copy_and_verify \
  "${T1_HARNESS_SHA256}" \
  "${HARNESS_DIR}/sub_t1_semantic_harness.c" \
  "${FINAL_DIR}/harnesses/sub_t1_semantic_harness.c"

copy_and_verify \
  "${T2_HARNESS_SHA256}" \
  "${HARNESS_DIR}/sub_t2_relational_harness.c" \
  "${FINAL_DIR}/harnesses/sub_t2_relational_harness.c"

copy_and_verify \
  "${COV_HARNESS_SHA256}" \
  "${HARNESS_DIR}/sub_cov_reachability_harness.c" \
  "${FINAL_DIR}/harnesses/sub_cov_reachability_harness.c"

copy_and_verify \
  "${VALID_HARNESS_SHA256}" \
  "${HARNESS_DIR}/sub_boundary_valid_extremes_harness.c" \
  "${FINAL_DIR}/harnesses/sub_boundary_valid_extremes_harness.c"

copy_and_verify \
  "${INVALID_LOWER_HARNESS_SHA256}" \
  "${HARNESS_DIR}/sub_boundary_invalid_lower_harness.c" \
  "${FINAL_DIR}/harnesses/sub_boundary_invalid_lower_harness.c"

copy_and_verify \
  "${INVALID_UPPER_HARNESS_SHA256}" \
  "${HARNESS_DIR}/sub_boundary_invalid_upper_harness.c" \
  "${FINAL_DIR}/harnesses/sub_boundary_invalid_upper_harness.c"

copy_and_verify \
  "${ADAPTER_SHA256}" \
  "${ADAPTER_DIR}/sub00e_r1_fail_closed_zeroize.h" \
  "${FINAL_DIR}/adapter/sub00e_r1_fail_closed_zeroize.h"

copy_and_verify \
  "${ADAPTER_NOTE_SHA256}" \
  "${ADAPTER_DIR}/SUB00E_R1_BUILD_ADAPTER_NOTE.md" \
  "${FINAL_DIR}/adapter/SUB00E_R1_BUILD_ADAPTER_NOTE.md"

copy_and_verify \
  "${T1_MODEL_SHA256}" \
  "${SOURCE_MODELS}/sub_t1_semantic_harness/sub_t1_semantic_harness_mlkem768.goto" \
  "${FINAL_DIR}/models/sub_t1_semantic_harness_mlkem768.goto"

copy_and_verify \
  "${T2_MODEL_SHA256}" \
  "${SOURCE_MODELS}/sub_t2_relational_harness/sub_t2_relational_harness_mlkem768.goto" \
  "${FINAL_DIR}/models/sub_t2_relational_harness_mlkem768.goto"

copy_and_verify \
  "${COV_MODEL_SHA256}" \
  "${SOURCE_MODELS}/sub_cov_reachability_harness/sub_cov_reachability_harness_mlkem768.goto" \
  "${FINAL_DIR}/models/sub_cov_reachability_harness_mlkem768.goto"

copy_and_verify \
  "${VALID_MODEL_SHA256}" \
  "${SOURCE_MODELS}/sub_boundary_valid_extremes_harness/sub_boundary_valid_extremes_harness_mlkem768.goto" \
  "${FINAL_DIR}/models/sub_boundary_valid_extremes_harness_mlkem768.goto"

copy_and_verify \
  "${INVALID_LOWER_MODEL_SHA256}" \
  "${SOURCE_MODELS}/sub_boundary_invalid_lower_harness/sub_boundary_invalid_lower_harness_mlkem768.goto" \
  "${FINAL_DIR}/models/sub_boundary_invalid_lower_harness_mlkem768.goto"

copy_and_verify \
  "${INVALID_UPPER_MODEL_SHA256}" \
  "${SOURCE_MODELS}/sub_boundary_invalid_upper_harness/sub_boundary_invalid_upper_harness_mlkem768.goto" \
  "${FINAL_DIR}/models/sub_boundary_invalid_upper_harness_mlkem768.goto"

cp -a "${ARCH}" "${FINAL_DIR}/provenance/"
cp -a "${BUILD_CONTEXT}" "${FINAL_DIR}/provenance/"
cp -a "${R1_PACKET}" "${FINAL_DIR}/provenance/"
cp -a "${R1_ARTIFACT_MANIFEST}" "${FINAL_DIR}/provenance/"
cp -a "${R1_ADAPTER_MANIFEST}" "${FINAL_DIR}/provenance/"
cp -a "${R2_PACKET}" "${FINAL_DIR}/provenance/"
cp -a "${R2_AUDIT_MANIFEST}" "${FINAL_DIR}/provenance/"

T1_UNWINDSET="main.0:257,main.1:257,main.2:257,main.3:257,mlk_barrett_reduce.0:2,mlk_sub00e_r1_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2"

T2_UNWINDSET="main.0:257,main.1:257,main.2:257,main.3:257,main.4:257,main.5:257,main.6:257,main.7:257,mlk_barrett_reduce.0:2,mlk_sub00e_r1_poly_sub.0:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257"

COV_UNWINDSET="main.0:257,main.1:257,mlk_sub00e_r1_poly_sub.0:257,mlk_barrett_reduce.0:2,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2"

VALID_UNWINDSET="main.0:257,main.1:257,main.2:257,mlk_barrett_reduce.0:2,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2,mlk_sub00e_r1_poly_sub.0:257"

INVALID_UNWINDSET="main.0:257,mlk_sub00e_r1_poly_sub.0:257"

T1_LOOP_IDS="main.0,main.1,main.2,main.3,mlk_barrett_reduce.0,mlk_sub00e_r1_poly_sub.0,mlk_poly_reduce_c.0,mlk_poly_reduce_c.1,mlk_scalar_signed_to_unsigned_q.0,mlk_scalar_signed_to_unsigned_q.1"
T2_LOOP_IDS="main.0,main.1,main.2,main.3,main.4,main.5,main.6,main.7,mlk_barrett_reduce.0,mlk_sub00e_r1_poly_sub.0,mlk_scalar_signed_to_unsigned_q.0,mlk_scalar_signed_to_unsigned_q.1,mlk_poly_reduce_c.0,mlk_poly_reduce_c.1"
COV_LOOP_IDS="main.0,main.1,mlk_sub00e_r1_poly_sub.0,mlk_barrett_reduce.0,mlk_poly_reduce_c.0,mlk_poly_reduce_c.1,mlk_scalar_signed_to_unsigned_q.0,mlk_scalar_signed_to_unsigned_q.1"
VALID_LOOP_IDS="main.0,main.1,main.2,mlk_barrett_reduce.0,mlk_poly_reduce_c.0,mlk_poly_reduce_c.1,mlk_scalar_signed_to_unsigned_q.0,mlk_scalar_signed_to_unsigned_q.1,mlk_sub00e_r1_poly_sub.0"
INVALID_LOOP_IDS="main.0,mlk_sub00e_r1_poly_sub.0"

verify_reachable_loop_set \
  "${FINAL_DIR}/models/sub_t1_semantic_harness_mlkem768.goto" \
  "${T1_LOOP_IDS}"

verify_reachable_loop_set \
  "${FINAL_DIR}/models/sub_t2_relational_harness_mlkem768.goto" \
  "${T2_LOOP_IDS}"

verify_reachable_loop_set \
  "${FINAL_DIR}/models/sub_cov_reachability_harness_mlkem768.goto" \
  "${COV_LOOP_IDS}"

verify_reachable_loop_set \
  "${FINAL_DIR}/models/sub_boundary_valid_extremes_harness_mlkem768.goto" \
  "${VALID_LOOP_IDS}"

verify_reachable_loop_set \
  "${FINAL_DIR}/models/sub_boundary_invalid_lower_harness_mlkem768.goto" \
  "${INVALID_LOOP_IDS}"

verify_reachable_loop_set \
  "${FINAL_DIR}/models/sub_boundary_invalid_upper_harness_mlkem768.goto" \
  "${INVALID_LOOP_IDS}"

make_runner \
  "run_01_sub_t1_mode_a_mlkem768.sh" \
  "SUB-T1 / MODE-A / ML-KEM-768 / RUN-1" \
  "sub_t1_semantic_harness_mlkem768.goto" \
  "${T1_MODEL_SHA256}" \
  "sub_t1_semantic_harness.c" \
  "${T1_HARNESS_SHA256}" \
  "${T1_UNWINDSET}" \
  "verify" \
  "Positive theorem candidate: success is expected only if all semantic, frame, machine-model, safety and unwinding obligations pass." \
  "SUB00G_T1_MODE_A_MLKEM768_RUN1"

make_runner \
  "run_02_sub_t2_mode_a_mlkem768.sh" \
  "SUB-T2 / MODE-A / ML-KEM-768 / RUN-1" \
  "sub_t2_relational_harness_mlkem768.goto" \
  "${T2_MODEL_SHA256}" \
  "sub_t2_relational_harness.c" \
  "${T2_HARNESS_SHA256}" \
  "${T2_UNWINDSET}" \
  "verify" \
  "Positive relational theorem candidate: success is expected only if all relational, frame, machine-model, safety and unwinding obligations pass." \
  "SUB00H_T2_MODE_A_MLKEM768_RUN1"

make_runner \
  "run_03_sub_boundary_valid_mode_a_mlkem768.sh" \
  "VALID BOUNDARY / MODE-A / ML-KEM-768 / RUN-1" \
  "sub_boundary_valid_extremes_harness_mlkem768.goto" \
  "${VALID_MODEL_SHA256}" \
  "sub_boundary_valid_extremes_harness.c" \
  "${VALID_HARNESS_SHA256}" \
  "${VALID_UNWINDSET}" \
  "verify" \
  "Positive deterministic boundary control: verification success is expected." \
  "SUB00I_VALID_BOUNDARY_MODE_A_MLKEM768_RUN1"

make_runner \
  "run_04_sub_coverage_mode_a_mlkem768.sh" \
  "REACHABILITY COVERAGE / MODE-A / ML-KEM-768 / RUN-1" \
  "sub_cov_reachability_harness_mlkem768.goto" \
  "${COV_MODEL_SHA256}" \
  "sub_cov_reachability_harness.c" \
  "${COV_HARNESS_SHA256}" \
  "${COV_UNWINDSET}" \
  "coverage" \
  "Coverage experiment: each frozen cover goal is expected to be reachable; coverage output must be inspected goal by goal." \
  "SUB00J_COVERAGE_MODE_A_MLKEM768_RUN1"

make_runner \
  "run_05_sub_invalid_lower_mode_a_mlkem768.sh" \
  "INVALID LOWER CONTROL / MODE-A / ML-KEM-768 / RUN-1" \
  "sub_boundary_invalid_lower_harness_mlkem768.goto" \
  "${INVALID_LOWER_MODEL_SHA256}" \
  "sub_boundary_invalid_lower_harness.c" \
  "${INVALID_LOWER_HARNESS_SHA256}" \
  "${INVALID_UNWINDSET}" \
  "verify" \
  "Negative control: verification failure is expected, but acceptance requires the failure to be traced to the intended out-of-range subtraction conversion or an equivalent frozen safety obligation." \
  "SUB00K_INVALID_LOWER_MODE_A_MLKEM768_RUN1"

make_runner \
  "run_06_sub_invalid_upper_mode_a_mlkem768.sh" \
  "INVALID UPPER CONTROL / MODE-A / ML-KEM-768 / RUN-1" \
  "sub_boundary_invalid_upper_harness_mlkem768.goto" \
  "${INVALID_UPPER_MODEL_SHA256}" \
  "sub_boundary_invalid_upper_harness.c" \
  "${INVALID_UPPER_HARNESS_SHA256}" \
  "${INVALID_UNWINDSET}" \
  "verify" \
  "Negative control: verification failure is expected, but acceptance requires the failure to be traced to the intended out-of-range subtraction conversion or an equivalent frozen safety obligation." \
  "SUB00L_INVALID_UPPER_MODE_A_MLKEM768_RUN1"

cat >"${FINAL_DIR}/execution/DO_NOT_RUN_ALL_AT_ONCE.txt" <<'EOF'
Run only one frozen execution script at a time.

The first authorized theorem execution after this package is accepted is:

    execution/run_01_sub_t1_mode_a_mlkem768.sh

Do not start SUB-T2, coverage, or boundary controls until the SUB-T1
result packet has been reviewed and classified.

A non-zero wrapper exit code is evidence to inspect, not permission to
edit the theorem or silently weaken the safety flags.
EOF

cat >"${FINAL_DIR}/SUB00F_MODE_A_EXECUTION_MANIFEST.md" <<EOF
# SUB-00F Mode-A Harness and Execution-Manifest Freeze

## 1. Frozen identity

- Repository commit:
  \`d9613cf60de3132d32475c102d8c2781d84feb34\`
- Parameter set:
  \`MLK_CONFIG_PARAMETER_SET=768\`
- Namespace embedded in the validated GOTO models:
  \`mlk_sub00e_r1\`
- Portable-C configuration:
  \`MLK_CONFIG_NO_ASM=1\`
- Integration hook:
  \`MLK_CONFIG_CUSTOM_ZEROIZE=1\`
- CBMC/goto-cc/goto-instrument:
  \`6.9.0\`
- Machine:
  x86_64 Linux, 8-bit byte, 16-bit short/int16_t, 32-bit int/int32_t,
  64-bit pointer, arithmetic signed right shift as asserted by each
  positive theorem harness.

## 2. Freeze status

This package freezes the independently authored Mode-A ML-KEM-768
artefacts and exact execution commands.

At package creation time:

- no CBMC theorem command has been executed;
- no coverage command has been executed;
- no production source has been modified;
- no theorem harness has been modified;
- no target function contract is used as an abstraction;
- no source loop contract is applied;
- production \`mlk_poly_sub\` and \`mlk_poly_reduce\` bodies remain present;
- the repository's existing dedicated \`poly_sub_harness.c\` remains unopened.

The validated original GOTO binaries are the authoritative execution
inputs. The reachable-only binaries created in SUB-00E-R2 were used only
to determine reachable loop identifiers and are not used as proof inputs.

## 3. Frozen theorem candidates

### SUB-T1 semantic theorem candidate

For arbitrary int16 coefficient arrays A and B satisfying only direct
subtraction representability, production \`poly_sub\` followed by
production \`poly_reduce\` must produce the canonical coefficient in
\`[0,3329)\` equal to the independently computed shifted unsigned
modular oracle.

### SUB-T2 relational theorem candidate

The frozen relational claim is:

\`N(A-B) = N(N(A)-N(B))\`

where all operations on both paths use retained production bodies and
the initial direct subtraction is representable in int16_t.

These descriptions remain theorem candidates until their exact frozen
CBMC commands complete successfully and their outputs are reviewed.

## 4. Fixed safety and model-checking options

Every verification runner freezes:

\`\`\`
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
--slice-formula
--sat-solver minisat2
--trace
--json-ui
\`\`\`

Coverage additionally freezes:

\`\`\`
--cover cover
\`\`\`

Each command is limited by the external wrapper to 21,600 seconds,
with a 60-second termination grace period. GNU \`time -v\` records
resource use. The raw CBMC exit code, JSON output, stderr, command,
environment and hashes are retained.

## 5. Unwinding policy

Loops over all 256 coefficients are frozen at 257 unwindings, including
the terminating condition. Debug-bound loops over a one-element scalar
are frozen at 2 unwindings.

Every reachable loop identifier found in SUB-00E-R2 is explicitly
listed in the corresponding runner's \`--unwindset\`. Unwinding
assertions remain enabled; therefore, an insufficient bound is a
verification failure rather than a silent truncation.

Exact frozen unwindsets:

- SUB-T1:
  \`${T1_UNWINDSET}\`
- SUB-T2:
  \`${T2_UNWINDSET}\`
- Coverage:
  \`${COV_UNWINDSET}\`
- Valid boundary:
  \`${VALID_UNWINDSET}\`
- Invalid lower and upper controls:
  \`${INVALID_UNWINDSET}\`

## 6. Frozen run order and expected classification

1. \`run_01_sub_t1_mode_a_mlkem768.sh\`
   - Positive theorem candidate.
   - Success is not assumed.
2. \`run_02_sub_t2_mode_a_mlkem768.sh\`
   - Positive relational theorem candidate.
   - Must not compensate for a failed SUB-T1.
3. \`run_03_sub_boundary_valid_mode_a_mlkem768.sh\`
   - Positive deterministic boundary control.
4. \`run_04_sub_coverage_mode_a_mlkem768.sh\`
   - Every frozen cover goal must be reviewed individually.
5. \`run_05_sub_invalid_lower_mode_a_mlkem768.sh\`
   - Negative control; intended failure must be confirmed from the
     actual property identifier and trace.
6. \`run_06_sub_invalid_upper_mode_a_mlkem768.sh\`
   - Negative control; intended failure must be confirmed from the
     actual property identifier and trace.

Only the first script is authorized immediately after acceptance of this
freeze. Later scripts require review of the preceding evidence.

## 7. Fail-closed zeroization adapter

The adapter is not a zeroization proof or a production implementation.
It contains a deliberately false assertion. SUB-00E-R2 established that
\`mlk_zeroize\` is not reachable from any selected harness. Any later
unexpected reachable call therefore fails closed.

## 8. Novelty and provenance boundary

The safe current language is:

> independently derived relational theorem candidate and independently
> authored CBMC artefact candidate.

No world-first claim is made. CBMC success cannot establish novelty.
Equivalent repository, public-code and literature artefacts must be
audited after this execution-manifest freeze. The prior accidental
Makefile exposure remains disclosed. The existing repository harness was
not used to author or repair these frozen artefacts.

## 9. Deferred work

The following are deliberately outside this freeze:

- Mode-B loop-contract-assisted evidence;
- ML-KEM-512 and ML-KEM-1024 configuration replications;
- mutation experiments;
- repository/public-code/literature novelty audit;
- any theorem repair prompted by actual counterexamples.

Any later correction must receive a new version, preserve this package,
and state exactly why it was introduced.

## 10. Parent evidence hashes

- SUB-00C architecture:
  \`${EXPECTED_ARCH_SHA256}\`
- SUB-00D build context:
  \`${EXPECTED_BUILD_CONTEXT_SHA256}\`
- SUB-00E-R1 inspection packet:
  \`${EXPECTED_R1_PACKET_SHA256}\`
- SUB-00E-R1 artifact manifest:
  \`${EXPECTED_R1_ARTIFACT_MANIFEST_SHA256}\`
- SUB-00E-R1 adapter manifest:
  \`${EXPECTED_R1_ADAPTER_MANIFEST_SHA256}\`
- SUB-00E-R2 audit packet:
  \`${EXPECTED_R2_PACKET_SHA256}\`
- SUB-00E-R2 audit manifest:
  \`${EXPECTED_R2_AUDIT_MANIFEST_SHA256}\`

## 11. Final instruction

Do not edit a frozen harness, model, adapter or runner in place.

The first authorized next action after independent hash review is:

\`\`\`
execution/run_01_sub_t1_mode_a_mlkem768.sh
\`\`\`
EOF

chmod 0444 "${FINAL_DIR}/SUB00F_MODE_A_EXECUTION_MANIFEST.md"
chmod 0444 "${FINAL_DIR}/harnesses/"*
chmod 0444 "${FINAL_DIR}/adapter/"*
chmod 0444 "${FINAL_DIR}/models/"*
chmod 0444 "${FINAL_DIR}/provenance/"*
chmod 0444 "${FINAL_DIR}/execution/DO_NOT_RUN_ALL_AT_ONCE.txt"

(
  cd "${FINAL_DIR}"

  find . -type f \
    ! -name "SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256" \
    -print0 |
    LC_ALL=C sort -z |
    xargs -0 sha256sum
) >"${FINAL_DIR}/SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256"

chmod 0444 "${FINAL_DIR}/SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256"

(
  cd "${FINAL_DIR}"
  sha256sum --check "SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256"
)

cp -a "${FINAL_DIR}/SUB00F_MODE_A_EXECUTION_MANIFEST.md" "${ROOT_EXEC_MANIFEST}"
cp -a "${FINAL_DIR}/SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256" "${ROOT_ARTIFACT_MANIFEST}"

tar \
  --sort=name \
  --mtime='UTC 1970-01-01' \
  --owner=0 \
  --group=0 \
  --numeric-owner \
  -C "${DIR}" \
  -cf - \
  "$(basename "${FINAL_DIR}")" |
  gzip -n >"${PACKAGE}"

sha256sum "${PACKAGE}" >"${PACKAGE_HASH}"

{
  echo "============================================================"
  echo "SUB-00F MODE-A EXECUTION FREEZE COMPLETED"
  echo "============================================================"
  echo
  echo "Final directory:"
  echo "${FINAL_DIR}"
  echo
  echo "Execution manifest SHA-256:"
  sha256sum "${ROOT_EXEC_MANIFEST}"
  echo
  echo "Artifact manifest SHA-256:"
  sha256sum "${ROOT_ARTIFACT_MANIFEST}"
  echo
  echo "Deterministic package SHA-256:"
  cat "${PACKAGE_HASH}"
  echo
  echo "No CBMC theorem proof was executed."
  echo "No coverage command was executed."
  echo
  echo "Upload these four files:"
  echo "1. ${ROOT_EXEC_MANIFEST}"
  echo "2. ${ROOT_ARTIFACT_MANIFEST}"
  echo "3. ${PACKAGE}"
  echo "4. ${PACKAGE_HASH}"
  echo
  echo "Do not run the first theorem script until the freeze is reviewed."
} | tee "${DIR}/SUB00F_MODE_A_FREEZE_COMPLETION.txt"

sha256sum "${DIR}/SUB00F_MODE_A_FREEZE_COMPLETION.txt" \
  >"${DIR}/SUB00F_MODE_A_FREEZE_COMPLETION.txt.sha256"
