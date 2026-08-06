#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(pwd)"
RUN_DIR="${PACKAGE_ROOT}/evidence/run_1"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
EXPECTED_POLY_C_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_POLY_H_SHA="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
PARAM_SET=768
NAMESPACE_PREFIX=mlk_sa_sub

if [ -e "${RUN_DIR}" ]; then
  echo "ERROR: evidence/run_1 already exists; this corpus permits exactly one run." >&2
  exit 2
fi

for tool in git cbmc goto-cc goto-instrument gcc python3 sha256sum awk grep sed find sort xargs uname date; do
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
CURRENT_POLY_C_SHA="$(sha256sum mlkem/src/poly.c | awk '{print $1}')"
CURRENT_POLY_H_SHA="$(sha256sum mlkem/src/poly.h | awk '{print $1}')"
TRACKED_STATUS="$(git status --porcelain=v1 --untracked-files=no)"

[ "${CURRENT_COMMIT}" = "${EXPECTED_COMMIT}" ] || {
  echo "ERROR: commit mismatch: ${CURRENT_COMMIT}" >&2
  exit 3
}
[ "${CURRENT_POLY_C_SHA}" = "${EXPECTED_POLY_C_SHA}" ] || {
  echo "ERROR: poly.c hash mismatch: ${CURRENT_POLY_C_SHA}" >&2
  exit 3
}
[ "${CURRENT_POLY_H_SHA}" = "${EXPECTED_POLY_H_SHA}" ] || {
  echo "ERROR: poly.h hash mismatch: ${CURRENT_POLY_H_SHA}" >&2
  exit 3
}
[ -z "${TRACKED_STATUS}" ] || {
  echo "ERROR: tracked repository state is not clean." >&2
  printf '%s\n' "${TRACKED_STATUS}" >&2
  exit 3
}

cbmc --version | grep -q '6\.9\.0' || { echo "ERROR: CBMC must be 6.9.0" >&2; exit 3; }
goto-cc --version | grep -q '6\.9\.0' || { echo "ERROR: goto-cc must be 6.9.0" >&2; exit 3; }
goto-instrument --version | grep -q '6\.9\.0' || { echo "ERROR: goto-instrument must be 6.9.0" >&2; exit 3; }
gcc --version | head -n 1 | grep -q '13\.3\.0' || { echo "ERROR: GCC must be 13.3.0" >&2; exit 3; }
python3 --version | grep -q '3\.12\.3' || { echo "ERROR: Python must be 3.12.3" >&2; exit 3; }
[ "$(uname -m)" = "x86_64" ] || { echo "ERROR: expected x86_64" >&2; exit 3; }
python3 -c 'import sys; sys.exit(0 if sys.byteorder == "little" else "ERROR: expected little-endian host")'

mkdir -p "${RUN_DIR}"
trap 'printf "%s\n" "RUN_INCOMPLETE" > "${RUN_DIR}/RUN_INCOMPLETE.txt"' ERR

{
  echo "campaign=MLK_POLY_SUB_SKILL ASSISTED"
  echo "run_index=1"
  echo "utc_started=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "repo_root=${REPO_ROOT}"
  echo "commit=${CURRENT_COMMIT}"
  echo "parameter_set=${PARAM_SET}"
  echo "namespace_prefix=${NAMESPACE_PREFIX}"
  echo "uname=$(uname -a)"
  echo "tracked_git_status=clean"
} > "${RUN_DIR}/identity.txt"

python3 -c 'import json,platform,sys; print(json.dumps({"platform":platform.platform(),"machine":platform.machine(),"byteorder":sys.byteorder,"python":platform.python_version(),"language_mode":"C90","parameter_set":768,"portable_c":True}, indent=2))' > "${RUN_DIR}/environment.json"
cbmc --version > "${RUN_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${RUN_DIR}/goto_cc_version.txt" 2>&1
goto-instrument --version > "${RUN_DIR}/goto_instrument_version.txt" 2>&1
gcc --version > "${RUN_DIR}/gcc_version.txt" 2>&1
python3 --version > "${RUN_DIR}/python_version.txt" 2>&1
sha256sum mlkem/src/poly.c > "${RUN_DIR}/production_poly_c_sha256.txt"
sha256sum mlkem/src/poly.h > "${RUN_DIR}/production_poly_h_sha256.txt"
cp "${PACKAGE_ROOT}/manifests/MANIFEST.sha256" "${RUN_DIR}/package_manifest_before_run.sha256"

python3 "${PACKAGE_ROOT}/runner/audit_repository_distinctness.py" \
  "${REPO_ROOT}" "${RUN_DIR}/repository_distinctness.json"

COMMON_BUILD=(
  goto-cc
  -std=c90
  -I.
  -Imlkem
  -Imlkem/src
  -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
  -DMLK_CONFIG_NAMESPACE_PREFIX="${NAMESPACE_PREFIX}"
  -DMLK_CONFIG_NO_ASM=1
  -DMLK_CONFIG_CUSTOM_ZEROIZE=1
)

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
  --json-ui
)

run_theorem() {
  local label="$1"
  local harness="$2"
  local out="${RUN_DIR}/${label}"
  local proof_model="${out}/proof_model.goto"
  local cover_model="${out}/cover_model.goto"
  local proof_build
  local cover_build
  local proof
  local cover
  local rc

  mkdir -p "${out}"
  cp "${harness}" "${out}/harness.c"

  proof_build=("${COMMON_BUILD[@]}" "${harness}" mlkem/src/poly.c -o "${proof_model}")
  printf '%q ' "${proof_build[@]}" > "${out}/proof_build_command.txt"; echo >> "${out}/proof_build_command.txt"
  set +e
  "${proof_build[@]}" > "${out}/proof_build.log" 2>&1
  rc=$?
  set -e
  echo "${rc}" > "${out}/proof_build_exit_code.txt"
  [ "${rc}" -eq 0 ] || return 10

  cover_build=("${COMMON_BUILD[@]}" -DSKILL_COVER_MODE=1 "${harness}" mlkem/src/poly.c -o "${cover_model}")
  printf '%q ' "${cover_build[@]}" > "${out}/cover_build_command.txt"; echo >> "${out}/cover_build_command.txt"
  set +e
  "${cover_build[@]}" > "${out}/cover_build.log" 2>&1
  rc=$?
  set -e
  echo "${rc}" > "${out}/cover_build_exit_code.txt"
  [ "${rc}" -eq 0 ] || return 10

  goto-instrument --show-goto-functions "${proof_model}" > "${out}/proof_functions.txt" 2>&1
  goto-instrument --show-goto-functions "${cover_model}" > "${out}/cover_functions.txt" 2>&1
  goto-instrument --show-loops "${proof_model}" > "${out}/proof_loops.txt" 2>&1
  goto-instrument --show-loops "${cover_model}" > "${out}/cover_loops.txt" 2>&1
  goto-instrument --show-properties "${proof_model}" > "${out}/proof_properties.txt" 2>&1
  goto-instrument --show-properties "${cover_model}" > "${out}/cover_properties.txt" 2>&1

  grep -q 'poly_sub' "${out}/proof_functions.txt" || return 13
  grep -q 'poly_sub' "${out}/cover_functions.txt" || return 13

  proof=(cbmc "${proof_model}" "${COMMON_PROOF[@]}")
  printf '%q ' "${proof[@]}" > "${out}/proof_command.txt"; echo >> "${out}/proof_command.txt"
  set +e
  "${proof[@]}" > "${out}/proof.json" 2> "${out}/proof.stderr"
  rc=$?
  set -e
  echo "${rc}" > "${out}/proof_exit_code.txt"
  if [ "${rc}" -ne 0 ]; then
    cbmc "${proof_model}" "${COMMON_PROOF[@]}" --trace \
      > "${out}/proof_failure_trace.json" 2> "${out}/proof_failure_trace.stderr" || true
    return 11
  fi

  cover=(cbmc "${cover_model}" --function main --cover cover --show-test-suite --unwind 257 --json-ui)
  printf '%q ' "${cover[@]}" > "${out}/cover_command.txt"; echo >> "${out}/cover_command.txt"
  set +e
  "${cover[@]}" > "${out}/cover.json" 2> "${out}/cover.stderr"
  rc=$?
  set -e
  echo "${rc}" > "${out}/cover_exit_code.txt"
  [ "${rc}" -eq 0 ] || return 12

  sha256sum \
    "${out}/harness.c" \
    "${proof_model}" \
    "${cover_model}" \
    "${out}/proof.json" \
    "${out}/cover.json" \
    > "${out}/sha256.txt"
}

run_theorem "SA_SUB_T1" \
  "${PACKAGE_ROOT}/harnesses/sa_sub_t1_common_minuend_difference_reversal_harness.c"
run_theorem "SA_SUB_T2" \
  "${PACKAGE_ROOT}/harnesses/sa_sub_t2_sequential_subtrahend_aggregation_harness.c"

python3 "${PACKAGE_ROOT}/runner/summarize_results.py" "${RUN_DIR}"

for required in \
  identity.txt environment.json cbmc_version.txt goto_cc_version.txt \
  goto_instrument_version.txt gcc_version.txt python_version.txt \
  production_poly_c_sha256.txt production_poly_h_sha256.txt \
  repository_distinctness.json final_status.json; do
  [ -s "${RUN_DIR}/${required}" ] || {
    echo "ERROR: missing final global artefact: ${required}" >&2
    exit 20
  }
done

(
  cd "${RUN_DIR}"
  find . -type f ! -name RUN_MANIFEST.sha256 -print0 | sort -z | xargs -0 sha256sum
) > "${RUN_DIR}/RUN_MANIFEST.sha256"
rm -f "${RUN_DIR}/RUN_INCOMPLETE.txt"
echo "utc_completed=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "${RUN_DIR}/identity.txt"
echo "RUN_1_ACCEPTED"
