#!/usr/bin/env bash
set -euo pipefail

DIR="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
SRC="${DIR}/source"
POLY_C="${SRC}/mlkem/src/poly.c"
HARNESS_DIR="${DIR}/harness_drafts_v1"

ARCH="${DIR}/SUB00C_INDEPENDENT_HARNESS_ARCHITECTURE.md"
BUILD_CONTEXT="${DIR}/SUB00D_BUILD_CONTEXT_DISCOVERY.txt"
HARNESS_MANIFEST="${DIR}/SUB00C_HARNESS_DRAFT_MANIFEST.sha256"
FAILED_PACKET="${DIR}/SUB00E_DRAFT_GOTO_MODEL_INSPECTION_PACKET.txt"

EXPECTED_ARCH_SHA256="a1d11264cf27038fed35ccddced2c6f79c5e28f42382e5000ce7fe7a44689d84"
EXPECTED_BUILD_CONTEXT_SHA256="9714f50795c722290060868e6b786b30ad7b1b13b267ee82f6c2dd1e3dd109c2"
EXPECTED_FAILED_PACKET_SHA256="c76bb21871335f1ddb0bfe33c4ba8b309062346d8d5c50bd27f817d4628dbf22"

ADAPTER_DIR="${DIR}/build_adapters_v2"
ADAPTER_H="${ADAPTER_DIR}/sub00e_r1_fail_closed_zeroize.h"
ADAPTER_NOTE="${ADAPTER_DIR}/SUB00E_R1_BUILD_ADAPTER_NOTE.md"
ADAPTER_MANIFEST="${DIR}/SUB00E_R1_BUILD_ADAPTER_MANIFEST.sha256"

STAGE_DIR="${DIR}/sub00e_r1_goto_model_inspection_v2"
PACKET="${DIR}/SUB00E_R1_GOTO_MODEL_INSPECTION_PACKET.txt"
PACKET_HASH="${PACKET}.sha256"
ARTIFACT_MANIFEST="${DIR}/SUB00E_R1_GOTO_ARTIFACT_MANIFEST.sha256"

PARAM_SET="768"
NAMESPACE_PREFIX="mlk_sub00e_r1"

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
test -d "${HARNESS_DIR}" || fail "harness directory is missing: ${HARNESS_DIR}"
test -f "${ARCH}" || fail "SUB-00C architecture is missing"
test -f "${BUILD_CONTEXT}" || fail "SUB-00D build-context file is missing"
test -f "${HARNESS_MANIFEST}" || fail "draft harness manifest is missing"
test -f "${FAILED_PACKET}" || fail "original SUB-00E failure packet is missing"

test ! -e "${ADAPTER_DIR}" || fail "adapter directory already exists: ${ADAPTER_DIR}"
test ! -e "${ADAPTER_MANIFEST}" || fail "adapter manifest already exists: ${ADAPTER_MANIFEST}"
test ! -e "${STAGE_DIR}" || fail "remediation stage directory already exists: ${STAGE_DIR}"
test ! -e "${PACKET}" || fail "remediation inspection packet already exists: ${PACKET}"
test ! -e "${PACKET_HASH}" || fail "remediation packet hash already exists: ${PACKET_HASH}"
test ! -e "${ARTIFACT_MANIFEST}" || fail "remediation artifact manifest already exists: ${ARTIFACT_MANIFEST}"

ACTUAL_ARCH_SHA256="$(sha256sum "${ARCH}" | awk '{print $1}')"
ACTUAL_BUILD_CONTEXT_SHA256="$(sha256sum "${BUILD_CONTEXT}" | awk '{print $1}')"
ACTUAL_FAILED_PACKET_SHA256="$(sha256sum "${FAILED_PACKET}" | awk '{print $1}')"

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

test "${ACTUAL_FAILED_PACKET_SHA256}" = "${EXPECTED_FAILED_PACKET_SHA256}" || {
  echo "Expected failed SUB-00E packet: ${EXPECTED_FAILED_PACKET_SHA256}" >&2
  echo "Actual failed SUB-00E packet:   ${ACTUAL_FAILED_PACKET_SHA256}" >&2
  fail "original SUB-00E failure evidence integrity verification failed"
}

for harness in "${HARNESSES[@]}"
do
  test -f "${HARNESS_DIR}/${harness}" ||
    fail "draft harness is missing: ${HARNESS_DIR}/${harness}"
done

echo "Verifying all six independently authored harnesses..."
(
  cd "${HARNESS_DIR}"
  sha256sum --check "${HARNESS_MANIFEST}"
)

mkdir -p "${ADAPTER_DIR}" "${STAGE_DIR}"

cat >"${ADAPTER_H}" <<'EOF'
#ifndef SUB00E_R1_FAIL_CLOSED_ZEROIZE_H
#define SUB00E_R1_FAIL_CLOSED_ZEROIZE_H

/*
 * Model-construction adapter only.
 *
 * mlkem-native requires an application-supplied zeroization hook when
 * MLK_CONFIG_NO_ASM disables its inline-assembly implementation.
 *
 * The selected poly_sub/poly_reduce call paths must never call zeroization.
 * This deliberately fail-closed body ensures that any unexpected reachable
 * call is reported as a verification failure instead of being hidden by a
 * permissive no-op model.
 */

#include <stddef.h>

static void mlk_zeroize(void *ptr, size_t len)
{
  (void)ptr;
  (void)len;

  __CPROVER_assert(
      0,
      "SUB00E_R1_ADAPTER: mlk_zeroize must be unreachable from the selected harness");
}

#endif /* SUB00E_R1_FAIL_CLOSED_ZEROIZE_H */
EOF

cat >"${ADAPTER_NOTE}" <<'EOF'
# SUB-00E-R1 Fail-Closed Zeroization Build Adapter

## Reason

The original SUB-00E direct builds selected `MLK_CONFIG_NO_ASM`.
Under that configuration, `verify.h` requires the embedding
application to supply `MLK_CONFIG_CUSTOM_ZEROIZE`.

The target `mlk_poly_sub` and `mlk_poly_reduce` paths do not require
zeroization, but the complete production translation unit still
includes declarations and other functions that refer to the hook.

## Adapter design

The rerun defines:

    MLK_CONFIG_CUSTOM_ZEROIZE=1

and force-includes:

    sub00e_r1_fail_closed_zeroize.h

The adapter provides a translation-unit-local `mlk_zeroize` body
containing a deliberately false CBMC assertion.

Consequences:

- no production source file is modified;
- no independently authored theorem harness is modified;
- the adapter cannot be used to claim zeroization correctness;
- an unexpected reachable call to `mlk_zeroize` fails closed;
- successful target proofs therefore require the adapter call to
  remain unreachable from the selected harness entry point.

## Scope

This adapter exists only to construct and inspect the GOTO models and,
after final manifest freeze, to support the selected poly_sub/poly_reduce
verification campaign. It is not a production zeroization implementation.
EOF

(
  cd "${DIR}"
  sha256sum \
    "build_adapters_v2/$(basename "${ADAPTER_H}")" \
    "build_adapters_v2/$(basename "${ADAPTER_NOTE}")"
) >"${ADAPTER_MANIFEST}"

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
      -DMLK_CONFIG_NO_ASM=1 \
      -DMLK_CONFIG_CUSTOM_ZEROIZE=1 \
      -include "${ADAPTER_H}" \
      -I"${SRC}/mlkem" \
      -I"${SRC}/mlkem/src" \
      - >"${STAGE_DIR}/effective_preprocessor_macros_all.txt" \
      2>"${STAGE_DIR}/effective_preprocessor_macros.stderr.txt" || true

grep -E \
  'MLK_CONFIG_PARAMETER_SET|MLK_CONFIG_NAMESPACE_PREFIX|MLK_CONFIG_NO_ASM|MLK_CONFIG_CUSTOM_ZEROIZE|MLK_CONFIG_USE_NATIVE_BACKEND_ARITH|MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202|MLK_USE_NATIVE_POLY_REDUCE|MLKEM_N|MLKEM_Q|MLKEM_K|MLK_NAMESPACE' \
  "${STAGE_DIR}/effective_preprocessor_macros_all.txt" \
  | LC_ALL=C sort >"${STAGE_DIR}/effective_preprocessor_macros_selected.txt" || true

SUCCESS_COUNT=0
FAIL_COUNT=0

for harness in "${HARNESSES[@]}"
do
  base="${harness%.c}"
  one="${STAGE_DIR}/${base}"
  model="${one}/${base}_mlkem768.goto"
  mkdir -p "${one}"

  BUILD_CMD=(
    goto-cc
    -std=c90
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    -DMLK_CONFIG_NAMESPACE_PREFIX="${NAMESPACE_PREFIX}"
    -DMLK_CONFIG_NO_ASM=1
    -DMLK_CONFIG_CUSTOM_ZEROIZE=1
    -include "${ADAPTER_H}"
    -I"${SRC}/mlkem"
    -I"${SRC}/mlkem/src"
    "${HARNESS_DIR}/${harness}"
    "${POLY_C}"
    -o "${model}"
  )

  write_command "${one}/build.command.txt" "${BUILD_CMD[@]}"
  run_capture "${one}/build.log" "${BUILD_CMD[@]}"
  build_rc="$(cat "${one}/build.log.exit_code")"
  printf '%s\n' "${build_rc}" >"${one}/selected_build.exit_code"

  if test "${build_rc}" -ne 0 || test ! -s "${model}"
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

  if grep -q -- '--show-reachable-functions' "${STAGE_DIR}/goto-instrument_help.txt"
  then
    write_command "${one}/show_reachable_functions.command.txt" \
      goto-instrument --show-reachable-functions "${model}"
    run_capture "${one}/show_reachable_functions.txt" \
      goto-instrument --show-reachable-functions "${model}"
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
  echo "SUB-00E-R1 GOTO-MODEL REMEDIATION AND STRUCTURAL INSPECTION"
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
  echo "Original failed SUB-00E packet SHA-256:"
  echo "${ACTUAL_FAILED_PACKET_SHA256}"
  echo
  echo "Collection time UTC:"
  date -u +%Y-%m-%dT%H:%M:%SZ
  echo
  echo "STATUS:"
  echo "Remediated GOTO-model construction and structural inspection only."
  echo "No CBMC theorem proof command was executed."
  echo "No --cover command was executed."
  echo "No loop contract was applied."
  echo "No target function contract was used as an abstraction."
  echo "No production source file was modified."
  echo "No theorem harness was modified."
  echo "The existing repository poly_sub harness remained unopened."
  echo
  echo "Successful models: ${SUCCESS_COUNT}"
  echo "Failed models:     ${FAIL_COUNT}"

  echo
  echo "============================================================"
  echo "FAILURE CLASSIFICATION"
  echo "============================================================"
  echo
  echo "The original SUB-00E failure was a preprocessing integration failure:"
  echo
  echo "    MLK_CONFIG_NO_ASM disabled the inline-assembly zeroizer."
  echo "    verify.h then required MLK_CONFIG_CUSTOM_ZEROIZE."
  echo
  echo "It was not a SUB-T1 counterexample."
  echo "It was not a SUB-T2 counterexample."
  echo "It was not a harness semantic failure."
  echo "It was not a production poly_sub/poly_reduce failure."

  echo
  echo "============================================================"
  echo "BUILD CONFIGURATION"
  echo "============================================================"
  echo "Parameter set: ${PARAM_SET}"
  echo "Namespace prefix: ${NAMESPACE_PREFIX}"
  echo "Portable-C selection: -DMLK_CONFIG_NO_ASM=1"
  echo "Custom-zeroize integration: -DMLK_CONFIG_CUSTOM_ZEROIZE=1"
  echo "Forced adapter header: ${ADAPTER_H}"
  echo "Multilevel macros: none"
  echo "Production source: ${POLY_C}"
  echo "Include path 1: ${SRC}/mlkem"
  echo "Include path 2: ${SRC}/mlkem/src"

  echo
  echo "============================================================"
  echo "FAIL-CLOSED ADAPTER NOTE"
  echo "============================================================"
  cat "${ADAPTER_NOTE}"
  echo
  echo "Adapter SHA-256 manifest:"
  cat "${ADAPTER_MANIFEST}"

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
    echo "Build command:"
    cat "${one}/build.command.txt"
    echo
    echo "Build exit code:"
    cat "${one}/selected_build.exit_code"
    echo
    echo "Build log, first 400 lines:"
    sed -n '1,400p' "${one}/build.log"

    if test ! -s "${model}"
    then
      echo
      echo "MODEL STATUS: NOT CONSTRUCTED"
      continue
    fi

    echo
    echo "MODEL STATUS: CONSTRUCTED"
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
    echo "Relevant function/body markers:"
    grep -n -E \
      '(^|[^[:alnum:]_])(main|nondet_int16_t|mlk_zeroize|mlk_sub00e_r1_poly_sub|mlk_sub00e_r1_poly_reduce)([^[:alnum:]_]|$)|no body|No body|body not available|Body not available' \
      "${one}/show_goto_functions.txt" | head -n 800 || true

    if test -f "${one}/list_goto_functions.txt"
    then
      echo
      echo "Relevant listed functions:"
      grep -n -E \
        'main|nondet_int16_t|mlk_zeroize|mlk_sub00e_r1_poly_sub|mlk_sub00e_r1_poly_reduce' \
        "${one}/list_goto_functions.txt" | head -n 500 || true
    fi

    if test -f "${one}/show_call_sequences.txt"
    then
      echo
      echo "Relevant call-sequence markers:"
      grep -n -E \
        'main|mlk_zeroize|mlk_sub00e_r1_poly_sub|mlk_sub00e_r1_poly_reduce' \
        "${one}/show_call_sequences.txt" | head -n 800 || true
    fi

    if test -f "${one}/show_reachable_functions.txt"
    then
      echo
      echo "Relevant reachable-function markers:"
      grep -n -E \
        'main|mlk_zeroize|mlk_sub00e_r1_poly_sub|mlk_sub00e_r1_poly_reduce' \
        "${one}/show_reachable_functions.txt" | head -n 800 || true
    fi

    echo
    echo "All discovered loop identifiers:"
    sed -n '1,1600p' "${one}/show_loops.txt"

    echo
    echo "Relevant property identifiers:"
    grep -n -E \
      'SUB_T1|SUB_T2|SUB_COV|SUB_BOUNDARY|SUB_INVALID|SUB00E_R1_ADAPTER|mlk_sub00e_r1_poly_sub|mlk_sub00e_r1_poly_reduce|unwind' \
      "${one}/show_properties.txt" | head -n 1800 || true

    echo
    echo "Unresolved/no-body audit markers:"
    grep -n -E \
      'nondet_int16_t|no body|No body|body not available|Body not available|incomplete function|unresolved' \
      "${one}/show_goto_functions.txt" | head -n 800 || true
  done

  echo
  echo "============================================================"
  echo "DISCOVERY VERDICT BOUNDARY"
  echo "============================================================"
  echo
  echo "A constructed GOTO model is not a theorem proof."
  echo "The fail-closed zeroize adapter is not zeroization evidence."
  echo "Do not report SUB-T1 or SUB-T2 as proved from this stage."
  echo "Do not open proofs/cbmc/poly_sub/poly_sub_harness.c."
} >"${PACKET}"

(
  cd "${DIR}"

  find "$(basename "${STAGE_DIR}")" -type f -print0 |
    LC_ALL=C sort -z |
    xargs -0 sha256sum

  find "$(basename "${ADAPTER_DIR}")" -type f -print0 |
    LC_ALL=C sort -z |
    xargs -0 sha256sum

  for harness in "${HARNESSES[@]}"
  do
    sha256sum "harness_drafts_v1/${harness}"
  done
) >"${ARTIFACT_MANIFEST}"

sha256sum "${PACKET}" >"${PACKET_HASH}"

echo
echo "============================================================"
echo "SUB-00E-R1 REMEDIATION INSPECTION COMPLETED"
echo "============================================================"
echo
echo "Successful models: ${SUCCESS_COUNT}"
echo "Failed models:     ${FAIL_COUNT}"
echo
cat "${PACKET_HASH}"
echo
echo "Upload these four files:"
echo "1. ${PACKET}"
echo "2. ${PACKET_HASH}"
echo "3. ${ARTIFACT_MANIFEST}"
echo "4. ${ADAPTER_MANIFEST}"
echo
echo "Do not run CBMC theorem proofs yet."
echo "Do not open proofs/cbmc/poly_sub/poly_sub_harness.c."

if test "${FAIL_COUNT}" -ne 0
then
  echo
  echo "One or more remediated draft models still failed to construct."
  echo "The packet preserves the exact next integration error."
  exit 2
fi
