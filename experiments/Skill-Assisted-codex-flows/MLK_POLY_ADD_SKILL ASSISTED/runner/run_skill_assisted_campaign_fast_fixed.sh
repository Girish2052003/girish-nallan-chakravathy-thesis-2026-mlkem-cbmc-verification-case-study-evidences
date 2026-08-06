#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(pwd)"
RUN_DIR="${PACKAGE_ROOT}/evidence/run_1"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
EXPECTED_POLY_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
PARAM_SET=768

if [ -e "${RUN_DIR}" ]; then
  echo "ERROR: evidence/run_1 already exists; this corpus permits one campaign run." >&2
  exit 2
fi

for tool in git cbmc goto-cc goto-instrument sha256sum python3 tee grep awk; do
  command -v "${tool}" >/dev/null 2>&1 || {
    echo "ERROR: missing required tool: ${tool}" >&2
    exit 2
  }
done

[ -f mlkem/src/poly.c ] && [ -f mlkem/src/poly.h ] || {
  echo "ERROR: run from the frozen mlkem-native repository root." >&2
  exit 2
}

CURRENT_COMMIT="$(git rev-parse HEAD)"
CURRENT_POLY_SHA="$(sha256sum mlkem/src/poly.c | awk '{print $1}')"
[ "${CURRENT_COMMIT}" = "${EXPECTED_COMMIT}" ] || {
  echo "ERROR: commit mismatch: ${CURRENT_COMMIT}" >&2
  exit 3
}
[ "${CURRENT_POLY_SHA}" = "${EXPECTED_POLY_SHA}" ] || {
  echo "ERROR: mlkem/src/poly.c hash mismatch: ${CURRENT_POLY_SHA}" >&2
  exit 3
}

cbmc --version | grep -q '6\.9\.0' || { echo "ERROR: CBMC must be 6.9.0" >&2; exit 3; }
goto-cc --version | grep -q '6\.9\.0' || { echo "ERROR: goto-cc must be 6.9.0" >&2; exit 3; }
goto-instrument --version | grep -q '6\.9\.0' || { echo "ERROR: goto-instrument must be 6.9.0" >&2; exit 3; }

mkdir -p "${RUN_DIR}"
trap 'echo "RUN_INCOMPLETE" > "${RUN_DIR}/RUN_INCOMPLETE.txt"' ERR

{
  echo "campaign=MLK_POLY_ADD_SKILL ASSISTED"
  echo "run_index=1"
  echo "utc_started=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "repo_root=${REPO_ROOT}"
  echo "commit=${CURRENT_COMMIT}"
  echo "parameter_set=${PARAM_SET}"
  echo "uname=$(uname -a)"
  echo "git_status_begin"
  git status --short
  echo "git_status_end"
} > "${RUN_DIR}/identity.txt"
cbmc --version > "${RUN_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${RUN_DIR}/goto_cc_version.txt" 2>&1
goto-instrument --version > "${RUN_DIR}/goto_instrument_version.txt" 2>&1
sha256sum mlkem/src/poly.c > "${RUN_DIR}/production_poly_c_sha256.txt"
cp "${PACKAGE_ROOT}/manifests/MANIFEST.sha256" "${RUN_DIR}/package_manifest_before_run.sha256"

COMMON_PROOF=(
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
  --object-bits 8
  --json-ui
)

run_theorem() {
  local label="$1"
  local harness="$2"
  local out="${RUN_DIR}/${label}"
  local model="${out}/model.goto"
  mkdir -p "${out}"
  cp "${harness}" "${out}/harness.c"

  local build=(goto-cc -I. -Imlkem -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    "${harness}" mlkem/src/poly.c -o "${model}")
  printf '%q ' "${build[@]}" > "${out}/build_command.txt"; echo >> "${out}/build_command.txt"
  set +e
  "${build[@]}" > "${out}/build.log" 2>&1
  local build_rc=$?
  set -e
  echo "${build_rc}" > "${out}/build_exit_code.txt"
  [ "${build_rc}" -eq 0 ] || return 10

  goto-instrument --show-properties "${model}" > "${out}/properties.txt" 2>&1

  local proof=(cbmc "${model}" "${COMMON_PROOF[@]}")
  printf '%q ' "${proof[@]}" > "${out}/proof_command.txt"; echo >> "${out}/proof_command.txt"
  set +e
  "${proof[@]}" > "${out}/proof.json" 2> "${out}/proof.stderr"
  local proof_rc=$?
  set -e
  echo "${proof_rc}" > "${out}/proof_exit_code.txt"
  [ "${proof_rc}" -eq 0 ] || return 11

  local cover=(cbmc "${model}" --function main --cover cover --show-test-suite
    --unwind 257 --object-bits 8 --json-ui)
  printf '%q ' "${cover[@]}" > "${out}/cover_command.txt"; echo >> "${out}/cover_command.txt"
  set +e
  "${cover[@]}" > "${out}/cover.json" 2> "${out}/cover.stderr"
  local cover_rc=$?
  set -e
  echo "${cover_rc}" > "${out}/cover_exit_code.txt"
  [ "${cover_rc}" -eq 0 ] || return 12

  sha256sum "${out}/harness.c" "${model}" "${out}/proof.json" \
    "${out}/cover.json" > "${out}/sha256.txt"
}

run_theorem "SA_ADD_T1" \
  "${PACKAGE_ROOT}/harnesses/sa_add_t1_translation_invariance_harness.c"
run_theorem "SA_ADD_T2" \
  "${PACKAGE_ROOT}/harnesses/sa_add_t2_disjoint_support_decomposition_harness.c"

python3 "${PACKAGE_ROOT}/runner/summarize_results.py" "${RUN_DIR}"
(
  cd "${RUN_DIR}"
  find . -type f ! -name RUN_MANIFEST.sha256 -print0 | sort -z | xargs -0 sha256sum
) > "${RUN_DIR}/RUN_MANIFEST.sha256"
rm -f "${RUN_DIR}/RUN_INCOMPLETE.txt"
echo "utc_completed=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "${RUN_DIR}/identity.txt"
echo "RUN_1_ACCEPTED"
