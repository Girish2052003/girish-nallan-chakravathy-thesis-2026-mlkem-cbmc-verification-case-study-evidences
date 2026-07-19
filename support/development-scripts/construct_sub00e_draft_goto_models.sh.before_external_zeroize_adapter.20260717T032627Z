#!/usr/bin/env bash
set -euo pipefail

DIR="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
HARNESS_DIR="${DIR}/harness_drafts_v1"
SRC="${DIR}/source"
POLY_C="${SRC}/mlkem/src/poly.c"

ARCH="${DIR}/SUB00C_INDEPENDENT_HARNESS_ARCHITECTURE.md"
BUILD_CONTEXT="${DIR}/SUB00D_BUILD_CONTEXT_DISCOVERY.txt"
HARNESS_MANIFEST="${DIR}/SUB00C_HARNESS_DRAFT_MANIFEST.sha256"

EXPECTED_ARCH_SHA256="a1d11264cf27038fed35ccddced2c6f79c5e28f42382e5000ce7fe7a44689d84"
EXPECTED_BUILD_CONTEXT_SHA256="9714f50795c722290060868e6b786b30ad7b1b13b267ee82f6c2dd1e3dd109c2"

STAGE_DIR="${DIR}/sub00e_draft_goto_model_inspection_v1"
NUMBERING_NOTE="${STAGE_DIR}/SUB00E_STAGE_NUMBERING_NOTE.md"
PACKET="${DIR}/SUB00E_DRAFT_GOTO_MODEL_INSPECTION_PACKET.txt"
PACKET_HASH="${PACKET}.sha256"
ARTIFACT_MANIFEST="${DIR}/SUB00E_DRAFT_GOTO_ARTIFACT_MANIFEST.sha256"

PARAM_SET="768"
NAMESPACE_PREFIX="mlk_sub00e"

HARNESSES=(
  "sub_t1_semantic_harness.c"
  "sub_t2_relational_harness.c"
  "sub_cov_reachability_harness.c"
  "sub_boundary_valid_extremes_harness.c"
  "sub_boundary_invalid_lower_harness.c"
  "sub_boundary_invalid_upper_harness.c"
)

fail()
{
  echo "ERROR: $*" >&2
  exit 1
}

run_capture()
{
  local output="$1"
  shift

  set +e
  "$@" >"${output}" 2>&1
  local rc=$?
  set -e

  printf '%s\n' "${rc}" >"${output}.exit_code"
  return 0
}

write_command()
{
  local output="$1"
  shift

  {
    printf 'COMMAND:'
    printf ' %q' "$@"
    printf '\n'
  } >"${output}"
}

command -v sha256sum >/dev/null 2>&1 || fail "sha256sum is unavailable"
command -v goto-cc >/dev/null 2>&1 || fail "goto-cc is unavailable"
command -v goto-instrument >/dev/null 2>&1 || fail "goto-instrument is unavailable"
command -v cbmc >/dev/null 2>&1 || fail "cbmc is unavailable"
command -v cc >/dev/null 2>&1 || fail "cc is unavailable"

test -d "${DIR}" || fail "campaign directory is missing: ${DIR}"
test -d "${SRC}" || fail "source-only export is missing: ${SRC}"
test -f "${POLY_C}" || fail "production poly.c is missing: ${POLY_C}"
test -f "${ARCH}" || fail "SUB-00C architecture is missing"
test -f "${BUILD_CONTEXT}" || fail "SUB-00D build-context file is missing"
test -f "${HARNESS_MANIFEST}" || fail "draft harness manifest is missing"

test ! -e "${STAGE_DIR}" || fail "stage directory already exists: ${STAGE_DIR}"
test ! -e "${PACKET}" || fail "inspection packet already exists: ${PACKET}"
test ! -e "${PACKET_HASH}" || fail "inspection packet hash already exists: ${PACKET_HASH}"
test ! -e "${ARTIFACT_MANIFEST}" || fail "artifact manifest already exists: ${ARTIFACT_MANIFEST}"

ACTUAL_ARCH_SHA256="$(sha256sum "${ARCH}" | awk '{print $1}')"
ACTUAL_BUILD_CONTEXT_SHA256="$(sha256sum "${BUILD_CONTEXT}" | awk '{print $1}')"

test "${ACTUAL_ARCH_SHA256}" = "${EXPECTED_ARCH_SHA256}" || {
  echo "Expected SUB-00C: ${EXPECTED_ARCH_SHA256}" >&2
  echo "Actual SUB-00C:   ${ACTUAL_ARCH_SHA256}" >&2
  fail "SUB-00C architecture integrity verification failed"
}

test "${ACTUAL_BUILD_CONTEXT_SHA256}" = "${EXPECTED_BUILD_CONTEXT_SHA256}" || {
  echo "Expected SUB-00D: ${EXPECTED_BUILD_CONTEXT_SHA256}" >&2
  echo "Actual SUB-00D:   ${ACTUAL_BUILD_CONTEXT_SHA256}" >&2
  fail "SUB-00D build-context integrity verification failed"
}

for harness in "${HARNESSES[@]}"
do
  test -f "${HARNESS_DIR}/${harness}" || fail "draft harness is missing: ${HARNESS_DIR}/${harness}"
done

(
  cd "${HARNESS_DIR}"
  sha256sum --check "${HARNESS_MANIFEST}"
)

mkdir -p "${STAGE_DIR}"

cat >"${NUMBERING_NOTE}" <<'EOF'
# SUB-00E Stage-Numbering Note

The frozen SUB-00C architecture referred prospectively to a later
"SUB-00D execution manifest". Before that naming collision was noticed,
the source-only build-context discovery was assigned the name SUB-00D.

No frozen file is renamed, overwritten, or silently changed.

The corrected administrative sequence is:

    SUB-00D — source-only build-context discovery
    SUB-00E — draft GOTO-model construction and structural inspection
    SUB-00F — final harness and execution-manifest freeze

This is an administrative numbering correction only. It does not alter
SUB-T1, SUB-T2, their assumptions, their assertions, or their planned
verification modes.
EOF

{
  echo "CBMC:"; cbmc --version 2>&1 || true
  echo
  echo "GOTO-CC:"; goto-cc --version 2>&1 || true
  echo
  echo "GOTO-INSTRUMENT:"; goto-instrument --version 2>&1 || true
  echo
  echo "HOST CC:"; cc --version 2>&1 | head -n 10 || true
  echo
  echo "UNAME:"; uname -a || true
} >"${STAGE_DIR}/tool_versions.txt"

goto-cc --help >"${STAGE_DIR}/goto-cc_help.txt" 2>&1 || true
goto-instrument --help >"${STAGE_DIR}/goto-instrument_help.txt" 2>&1 || true
cbmc --help >"${STAGE_DIR}/cbmc_help.txt" 2>&1 || true

{
  printf '#include "common.h"\n'
} | cc -dM -E -x c \
      -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}" \
      -DMLK_CONFIG_NAMESPACE_PREFIX="${NAMESPACE_PREFIX}" \
      -DMLK_CONFIG_NO_ASM \
      -I"${SRC}/mlkem" \
      -I"${SRC}/mlkem/src" \
      - >"${STAGE_DIR}/effective_preprocessor_macros_all.txt" 2>"${STAGE_DIR}/effective_preprocessor_macros.stderr.txt" || true

grep -E \
  'MLK_CONFIG_PARAMETER_SET|MLK_CONFIG_NAMESPACE_PREFIX|MLK_CONFIG_NO_ASM|MLK_CONFIG_USE_NATIVE_BACKEND_ARITH|MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202|MLK_USE_NATIVE_POLY_REDUCE|MLKEM_N|MLKEM_Q|MLKEM_K|MLK_NAMESPACE' \
  "${STAGE_DIR}/effective_preprocessor_macros_all.txt" \
  | LC_ALL=C sort >"${STAGE_DIR}/effective_preprocessor_macros_selected.txt" || true

SUCCESS_COUNT=0
FAIL_COUNT=0
FALLBACK_COUNT=0

for harness in "${HARNESSES[@]}"
do
  base="${harness%.c}"
  one="${STAGE_DIR}/${base}"
  model="${one}/${base}_mlkem768.goto"
  mkdir -p "${one}"

  DIRECT_CMD=(
    goto-cc
    -std=c90
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    -DMLK_CONFIG_NAMESPACE_PREFIX="${NAMESPACE_PREFIX}"
    -DMLK_CONFIG_NO_ASM
    -I"${SRC}/mlkem"
    -I"${SRC}/mlkem/src"
    "${HARNESS_DIR}/${harness}"
    "${POLY_C}"
    -o "${model}"
  )

  write_command "${one}/build_direct.command.txt" "${DIRECT_CMD[@]}"
  run_capture "${one}/build_direct.log" "${DIRECT_CMD[@]}"
  direct_rc="$(cat "${one}/build_direct.log.exit_code")"
  printf '%s\n' "direct" >"${one}/selected_build_mode.txt"
  selected_rc="${direct_rc}"

  if test "${direct_rc}" -ne 0
  then
    if grep -q -- '--allow-unresolved' "${STAGE_DIR}/goto-cc_help.txt"
    then
      FALLBACK_CMD=(
        goto-cc
        --allow-unresolved
        -std=c90
        -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
        -DMLK_CONFIG_NAMESPACE_PREFIX="${NAMESPACE_PREFIX}"
        -DMLK_CONFIG_NO_ASM
        -I"${SRC}/mlkem"
        -I"${SRC}/mlkem/src"
        "${HARNESS_DIR}/${harness}"
        "${POLY_C}"
        -o "${model}"
      )

      write_command "${one}/build_allow_unresolved.command.txt" "${FALLBACK_CMD[@]}"
      run_capture "${one}/build_allow_unresolved.log" "${FALLBACK_CMD[@]}"
      selected_rc="$(cat "${one}/build_allow_unresolved.log.exit_code")"
      printf '%s\n' "allow-unresolved-fallback" >"${one}/selected_build_mode.txt"

      if test "${selected_rc}" -eq 0
      then
        FALLBACK_COUNT=$((FALLBACK_COUNT + 1))
      fi
    fi
  fi

  printf '%s\n' "${selected_rc}" >"${one}/selected_build.exit_code"

  if test "${selected_rc}" -ne 0 || test ! -s "${model}"
  then
    FAIL_COUNT=$((FAIL_COUNT + 1))
    continue
  fi

  SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  sha256sum "${model}" >"${one}/model.sha256"
  stat "${model}" >"${one}/model.stat.txt"

  write_command "${one}/show_goto_functions.command.txt" \
    goto-instrument --show-goto-functions "${model}"
  run_capture "${one}/show_goto_functions.txt" \
    goto-instrument --show-goto-functions "${model}"

  write_command "${one}/show_loops.command.txt" \
    goto-instrument --show-loops "${model}"
  run_capture "${one}/show_loops.txt" \
    goto-instrument --show-loops "${model}"

  write_command "${one}/show_properties.command.txt" \
    cbmc "${model}" --show-properties
  run_capture "${one}/show_properties.txt" \
    cbmc "${model}" --show-properties

  write_command "${one}/show_symbol_table.command.txt" \
    cbmc "${model}" --show-symbol-table
  run_capture "${one}/show_symbol_table.txt" \
    cbmc "${model}" --show-symbol-table

  if grep -q -- '--list-goto-functions' "${STAGE_DIR}/goto-instrument_help.txt"
  then
    write_command "${one}/list_goto_functions.command.txt" \
      goto-instrument --list-goto-functions "${model}"
    run_capture "${one}/list_goto_functions.txt" \
      goto-instrument --list-goto-functions "${model}"
  fi

  if grep -q -- '--show-call-sequences' "${STAGE_DIR}/goto-instrument_help.txt"
  then
    write_command "${one}/show_call_sequences.command.txt" \
      goto-instrument --show-call-sequences "${model}"
    run_capture "${one}/show_call_sequences.txt" \
      goto-instrument --show-call-sequences "${model}"
  fi

  if grep -q -- '--validate-goto-model' "${STAGE_DIR}/goto-instrument_help.txt"
  then
    write_command "${one}/validate_goto_model.command.txt" \
      goto-instrument --validate-goto-model "${model}"
    run_capture "${one}/validate_goto_model.txt" \
      goto-instrument --validate-goto-model "${model}"
  fi

done

{
  echo "============================================================"
  echo "SUB-00E DRAFT GOTO-MODEL CONSTRUCTION AND INSPECTION"
  echo "============================================================"
  echo
  echo "Frozen commit:"
  echo "d9613cf60de3132d32475c102d8c2781d84feb34"
  echo
  echo "SUB-00C architecture SHA-256:"
  echo "${ACTUAL_ARCH_SHA256}"
  echo
  echo "SUB-00D build-context SHA-256:"
  echo "${ACTUAL_BUILD_CONTEXT_SHA256}"
  echo
  echo "Collection time UTC:"
  date -u +%Y-%m-%dT%H:%M:%SZ
  echo
  echo "STATUS:"
  echo "Draft GOTO-model construction and structural inspection only."
  echo "No CBMC theorem proof command was executed."
  echo "No --cover command was executed."
  echo "No loop contract was applied."
  echo "No target function contract was used as an abstraction."
  echo "The existing repository poly_sub harness remained unopened."
  echo
  echo "Successful models: ${SUCCESS_COUNT}"
  echo "Failed models:     ${FAIL_COUNT}"
  echo "Fallback builds using --allow-unresolved: ${FALLBACK_COUNT}"

  echo
  echo "============================================================"
  echo "STAGE-NUMBERING NOTE"
  echo "============================================================"
  cat "${NUMBERING_NOTE}"

  echo
  echo "============================================================"
  echo "FROZEN DRAFT BUILD CONFIGURATION"
  echo "============================================================"
  echo "Parameter set: ${PARAM_SET}"
  echo "Namespace prefix: ${NAMESPACE_PREFIX}"
  echo "Portable-C selection: -DMLK_CONFIG_NO_ASM"
  echo "Multilevel macros: none"
  echo "Production source: ${POLY_C}"
  echo "Include path 1: ${SRC}/mlkem"
  echo "Include path 2: ${SRC}/mlkem/src"

  echo
  echo "============================================================"
  echo "TOOL VERSIONS"
  echo "============================================================"
  cat "${STAGE_DIR}/tool_versions.txt"

  echo
  echo "============================================================"
  echo "SELECTED EFFECTIVE PREPROCESSOR MACROS"
  echo "============================================================"
  cat "${STAGE_DIR}/effective_preprocessor_macros_selected.txt"

  for harness in "${HARNESSES[@]}"
  do
    base="${harness%.c}"
    one="${STAGE_DIR}/${base}"
    model="${one}/${base}_mlkem768.goto"

    echo
    echo "============================================================"
    echo "HARNESS: ${harness}"
    echo "============================================================"
    echo
    echo "Harness SHA-256:"
    sha256sum "${HARNESS_DIR}/${harness}"
    echo
    echo "Selected build mode:"
    cat "${one}/selected_build_mode.txt"
    echo
    echo "Selected build exit code:"
    cat "${one}/selected_build.exit_code"
    echo
    echo "Direct build command:"
    cat "${one}/build_direct.command.txt"
    echo
    echo "Direct build log, first 300 lines:"
    sed -n '1,300p' "${one}/build_direct.log"

    if test -f "${one}/build_allow_unresolved.command.txt"
    then
      echo
      echo "Fallback build command:"
      cat "${one}/build_allow_unresolved.command.txt"
      echo
      echo "Fallback build log, first 300 lines:"
      sed -n '1,300p' "${one}/build_allow_unresolved.log"
    fi

    if test ! -s "${model}"
    then
      echo
      echo "MODEL STATUS: NOT CONSTRUCTED"
      continue
    fi

    echo
    echo "Model SHA-256:"
    cat "${one}/model.sha256"
    echo
    echo "Model stat:"
    cat "${one}/model.stat.txt"

    echo
    echo "Inspection command exit codes:"
    for rcfile in "${one}"/*.exit_code
    do
      printf '%s: ' "$(basename "${rcfile}")"
      cat "${rcfile}"
    done

    echo
    echo "Relevant function and body markers:"
    grep -n -E \
      '(^|[^[:alnum:]_])(main|nondet_int16_t|mlk_sub00e_poly_sub|mlk_sub00e_poly_reduce)([^[:alnum:]_]|$)|no body|No body|body not available|Body not available' \
      "${one}/show_goto_functions.txt" | head -n 500 || true

    if test -f "${one}/list_goto_functions.txt"
    then
      echo
      echo "Relevant listed functions:"
      grep -n -E \
        'main|nondet_int16_t|mlk_sub00e_poly_sub|mlk_sub00e_poly_reduce' \
        "${one}/list_goto_functions.txt" | head -n 300 || true
    fi

    echo
    echo "All discovered loop identifiers:"
    sed -n '1,1200p' "${one}/show_loops.txt"

    echo
    echo "Relevant property identifiers:"
    grep -n -E \
      'SUB_T1|SUB_T2|SUB_COV|SUB_BOUNDARY|SUB_INVALID|mlk_sub00e_poly_sub|mlk_sub00e_poly_reduce|unwind' \
      "${one}/show_properties.txt" | head -n 1200 || true

    echo
    echo "Unresolved/no-body audit markers:"
    grep -n -E \
      'nondet_int16_t|no body|No body|body not available|Body not available|incomplete function|unresolved' \
      "${one}/show_goto_functions.txt" | head -n 500 || true
  done

  echo
  echo "============================================================"
  echo "DISCOVERY VERDICT BOUNDARY"
  echo "============================================================"
  echo
  echo "A successfully constructed GOTO model is not a theorem proof."
  echo "This packet records only parsing, linking/model construction,"
  echo "function/body presence, symbols, properties and loop identifiers."
  echo
  echo "Do not report SUB-T1 or SUB-T2 as proved from this stage."
  echo "Do not open proofs/cbmc/poly_sub/poly_sub_harness.c."

} >"${PACKET}"

(
  cd "${DIR}"
  find "$(basename "${STAGE_DIR}")" -type f -print0 \
    | LC_ALL=C sort -z \
    | xargs -0 sha256sum
  for harness in "${HARNESSES[@]}"
  do
    sha256sum "harness_drafts_v1/${harness}"
  done
) >"${ARTIFACT_MANIFEST}"

sha256sum "${PACKET}" >"${PACKET_HASH}"

echo
echo "============================================================"
echo "SUB-00E DRAFT GOTO-MODEL INSPECTION COMPLETED"
echo "============================================================"
echo
echo "Successful models: ${SUCCESS_COUNT}"
echo "Failed models:     ${FAIL_COUNT}"
echo "Fallback builds:   ${FALLBACK_COUNT}"
echo
cat "${PACKET_HASH}"
echo
echo "Upload these three files:"
echo "1. ${PACKET}"
echo "2. ${PACKET_HASH}"
echo "3. ${ARTIFACT_MANIFEST}"
echo
echo "Do not run CBMC theorem proofs yet."
echo "Do not open proofs/cbmc/poly_sub/poly_sub_harness.c."

if test "${FAIL_COUNT}" -ne 0
then
  echo
  echo "One or more draft models failed to construct."
  echo "The packet preserves the failure evidence for review."
  exit 2
fi
