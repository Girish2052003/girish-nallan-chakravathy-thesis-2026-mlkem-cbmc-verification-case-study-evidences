#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# SUB-00L
#
# Combined, sequential and independently classified execution of:
#
#   1. SUB-T2 relational theorem
#   2. valid INT16_MIN / INT16_MAX boundary control
#   3. invalid lower representability control
#   4. invalid upper representability control
#
# All four models are constructed and validated before any solver execution.
# The four solver runs then execute sequentially to avoid concurrent
# memory-heavy CBMC processes.
#
# Production poly.c and all frozen harnesses remain unchanged.
###############################################################################

BASE="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
REPO="/home/girish/THESIS-2026/mlkem-native"
SRC="${BASE}/source"
FREEZE="${BASE}/sub00f_mode_a_execution_freeze_v1"

FROZEN_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

SOURCE_MANIFEST="${BASE}/SUB00A_SOURCE_MANIFEST.sha256"
SOURCE_MANIFEST_SHA256="aedd4d634379b77a7855f6d515e33a5393feaeec7cdf6294052f619fcfe031d2"

FREEZE_PACKAGE="${BASE}/SUB00F_MODE_A_EXECUTION_FREEZE_PACKAGE.tar.gz"
FREEZE_PACKAGE_SHA256="4836c959359967029a112dd12a3c380ee2e3141e2b0a1ff1a4537d3d8b7cb4e8"

FREEZE_MANIFEST="${FREEZE}/SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256"
FREEZE_MANIFEST_SHA256="51221155a2be5b0bcc4facf04233026bc7d516b525c35b6465e0d6aa2cd8cbba"

SUB00H_ARCHIVE="${BASE}/SUB00H_T1_PRAGMA_SCOPED_MODE_A_MLKEM768_RUN1.tar.gz"
SUB00H_ARCHIVE_SHA256="054ca49dc569642c4e1395b9f0027dca01da440a6b8653885a1d448ba0ca9a96"

SUB00I_ARCHIVE="${BASE}/SUB00I_COVERAGE_NONVACUITY_PRAGMA_SCOPED_MLKEM768_RUN1.tar.gz"
SUB00I_ARCHIVE_SHA256="02dc578425a8851f532667717c3c080ea756f10f0ef859662a6e736b60bcaae5"

SUB00J_ARCHIVE="${BASE}/SUB00J_MUTATION_PREFLIGHT_PRAGMA_SCOPED_MLKEM768.tar.gz"
SUB00J_ARCHIVE_SHA256="c4dc21bd092f45737470aa05bc2b4a99b475c53d8cc731f22fb389c2fc6b4ac6"

SUB00K_ARCHIVE="${BASE}/SUB00K_COMBINED_MUTATION_EXECUTION_MLKEM768_RUN1.tar.gz"
SUB00K_ARCHIVE_SHA256="0566a7295baef9db6c8259b79d849008863376ad9c5ba4e86a80caa8da7884f8"

ZEROIZE_ADAPTER="${FREEZE}/adapter/sub00e_r1_fail_closed_zeroize.h"
ZEROIZE_ADAPTER_SHA256="45d33b9ee3fe3613f23906de520bf9d5ce245a18b537c32787201912dec4e926"

T2_HARNESS="${FREEZE}/harnesses/sub_t2_relational_harness.c"
T2_HARNESS_SHA256="ca54ad2d875f104cf6daca915bcfb71e491c3f899b3d877b70439868d80d1037"

VALID_HARNESS="${FREEZE}/harnesses/sub_boundary_valid_extremes_harness.c"
VALID_HARNESS_SHA256="8f8d3a87cca7bfe5938f0db5ce0d8fe1829c03c3366d40a3aa17a084e7b48d6b"

LOWER_HARNESS="${FREEZE}/harnesses/sub_boundary_invalid_lower_harness.c"
LOWER_HARNESS_SHA256="8469f8c5a40a1da2fdd95b05eb6c5c5e8783128196989f19bf437886e4ed6a9d"

UPPER_HARNESS="${FREEZE}/harnesses/sub_boundary_invalid_upper_harness.c"
UPPER_HARNESS_SHA256="4db500d2d8c7a1d79dda38ec466aa79ed2b48f9cec46fa932ad4be7012a7e623"

PRISTINE_POLY="${SRC}/mlkem/src/poly.c"

OUT="${BASE}/SUB00L_COMBINED_T2_BOUNDARY_EXECUTION_MLKEM768_RUN1"
ADAPTERS="${OUT}/adapters"
BUILD="${OUT}/build"
CASES="${OUT}/cases"

PRAGMA_ADAPTER="${ADAPTERS}/sub00l_verify_pragma_scope.h"
OPTBLOCKER_ADAPTER="${ADAPTERS}/sub00l_optblocker_zero.c"

STATUS_FILE="${OUT}/BATCH_VERDICT.txt"
ARTIFACT_MANIFEST="${OUT}/SUB00L_ARTIFACT_MANIFEST.sha256"
PACKAGE="${BASE}/SUB00L_COMBINED_T2_BOUNDARY_EXECUTION_MLKEM768_RUN1.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

SCRIPT_PATH="$(readlink -f "$0")"
STEP="initialization"
PACKAGED=0

fail()
{
  echo "ERROR: $*" >&2
  return 1
}

hash_of()
{
  sha256sum "$1" | awk '{print $1}'
}

verify_hash()
{
  local expected="$1"
  local file="$2"
  local actual

  test -f "${file}" || {
    echo "Missing required file: ${file}" >&2
    return 1
  }

  actual="$(hash_of "${file}")"

  if test "${actual}" != "${expected}"
  then
    echo "Integrity mismatch" >&2
    echo "Expected: ${expected}" >&2
    echo "Actual:   ${actual}" >&2
    echo "File:     ${file}" >&2
    return 1
  fi
}

write_command()
{
  local file="$1"
  shift

  {
    printf 'COMMAND:'
    printf ' %q' "$@"
    printf '\n'
  } >"${file}"
}

run_capture()
{
  local output="$1"
  shift
  local rc

  set +e
  "$@" >"${output}" 2>&1
  rc="$?"
  set -e

  printf '%s\n' "${rc}" >"${output}.exit_code"
  return "${rc}"
}

package_evidence()
{
  local final_rc="$1"

  if test "${PACKAGED}" -eq 1
  then
    return
  fi
  PACKAGED=1

  if test -d "${OUT}"
  then
    {
      echo "FINAL_WRAPPER_EXIT_CODE=${final_rc}"
      echo "LAST_STEP=${STEP}"
    } >"${OUT}/wrapper_status.txt"

    (
      cd "${OUT}"

      find . -type f \
        ! -name "$(basename "${ARTIFACT_MANIFEST}")" \
        -print0 |
        LC_ALL=C sort -z |
        xargs -0 -r sha256sum
    ) >"${ARTIFACT_MANIFEST}"

    rm -f "${PACKAGE}" "${PACKAGE_HASH}"

    tar \
      --sort=name \
      --mtime='UTC 1970-01-01' \
      --owner=0 \
      --group=0 \
      --numeric-owner \
      -C "${BASE}" \
      -cf - \
      "$(basename "${OUT}")" |
      gzip -n >"${PACKAGE}"

    sha256sum "${PACKAGE}" >"${PACKAGE_HASH}"

    echo
    echo "============================================================"
    echo "SUB-00L EVIDENCE PACKAGED"
    echo "============================================================"
    echo "Last step: ${STEP}"
    echo

    if test -f "${STATUS_FILE}"
    then
      cat "${STATUS_FILE}"
      echo
    fi

    for summary in \
      "${CASES}/T2_RELATIONAL/CLASSIFICATION.txt" \
      "${CASES}/VALID_BOUNDARY/CLASSIFICATION.txt" \
      "${CASES}/INVALID_LOWER/CLASSIFICATION.txt" \
      "${CASES}/INVALID_UPPER/CLASSIFICATION.txt"
    do
      if test -f "${summary}"
      then
        echo "--- $(basename "$(dirname "${summary}")") ---"
        cat "${summary}"
        echo
      fi
    done

    echo "Upload:"
    echo "1. ${PACKAGE}"
    echo "2. ${PACKAGE_HASH}"
    cat "${PACKAGE_HASH}"
  fi
}

on_exit()
{
  local rc="$?"
  trap - EXIT
  package_evidence "${rc}"
  exit "${rc}"
}
trap on_exit EXIT

for tool in \
  git cc goto-cc goto-instrument cbmc timeout tar gzip \
  sha256sum python3 readlink strings diff grep sed
do
  command -v "${tool}" >/dev/null 2>&1 ||
    fail "required tool unavailable: ${tool}"
done

test -x /usr/bin/time || fail "/usr/bin/time is unavailable"
test -f "${SCRIPT_PATH}" || fail "unable to resolve executing script"

test -d "${BASE}" || fail "campaign directory missing: ${BASE}"
test -d "${REPO}/.git" || fail "repository missing: ${REPO}"
test -d "${SRC}/mlkem/src" || fail "clean-room source snapshot missing"
test -d "${FREEZE}" || fail "SUB-00F freeze directory missing"

test ! -e "${OUT}" || fail "versioned output already exists: ${OUT}"
test ! -e "${PACKAGE}" || fail "versioned package already exists: ${PACKAGE}"
test ! -e "${PACKAGE_HASH}" || fail "versioned package sidecar already exists"

mkdir -p "${ADAPTERS}" "${BUILD}" "${CASES}"

STEP="record environment"
{
  date -u
  uname -a
  echo
  git -C "${REPO}" rev-parse HEAD
  echo
  cc --version
  echo
  goto-cc --version
  echo
  goto-instrument --version
  echo
  cbmc --version
} >"${OUT}/environment.txt" 2>&1

STEP="verify frozen campaign identity"
HEAD="$(git -C "${REPO}" rev-parse HEAD)"
test "${HEAD}" = "${FROZEN_COMMIT}" || {
  echo "Expected commit: ${FROZEN_COMMIT}" >&2
  echo "Actual commit:   ${HEAD}" >&2
  fail "repository commit changed"
}

verify_hash "${SOURCE_MANIFEST_SHA256}" "${SOURCE_MANIFEST}"
verify_hash "${FREEZE_PACKAGE_SHA256}" "${FREEZE_PACKAGE}"
verify_hash "${FREEZE_MANIFEST_SHA256}" "${FREEZE_MANIFEST}"
verify_hash "${SUB00H_ARCHIVE_SHA256}" "${SUB00H_ARCHIVE}"
verify_hash "${SUB00I_ARCHIVE_SHA256}" "${SUB00I_ARCHIVE}"
verify_hash "${SUB00J_ARCHIVE_SHA256}" "${SUB00J_ARCHIVE}"
verify_hash "${SUB00K_ARCHIVE_SHA256}" "${SUB00K_ARCHIVE}"
verify_hash "${ZEROIZE_ADAPTER_SHA256}" "${ZEROIZE_ADAPTER}"
verify_hash "${T2_HARNESS_SHA256}" "${T2_HARNESS}"
verify_hash "${VALID_HARNESS_SHA256}" "${VALID_HARNESS}"
verify_hash "${LOWER_HARNESS_SHA256}" "${LOWER_HARNESS}"
verify_hash "${UPPER_HARNESS_SHA256}" "${UPPER_HARNESS}"

STEP="verify source snapshot and SUB-00F manifest"
sha256sum --check "${SOURCE_MANIFEST}" \
  >"${OUT}/source_manifest_check.txt" 2>&1

(
  cd "${FREEZE}"
  sha256sum --check "$(basename "${FREEZE_MANIFEST}")"
) >"${OUT}/sub00f_manifest_check.txt" 2>&1

STEP="write corrected environment adapters"
cat >"${PRAGMA_ADAPTER}" <<'EOF'
#ifndef SUB00L_VERIFY_PRAGMA_SCOPE_H
#define SUB00L_VERIFY_PRAGMA_SCOPE_H

/*
 * Activate only verify.h's CBMC-specific conversion-check pragma while
 * keeping function contracts and loop contracts disabled.
 */

#ifdef CBMC
#error "SUB-00L requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00L_VERIFY_PRAGMA_SCOPE_H */
EOF

cat >"${OPTBLOCKER_ADAPTER}" <<'EOF'
/*
 * SUB-00L environment definition.
 *
 * The portable value barrier reads a namespaced volatile uint64_t documented
 * by verify.h as being set to zero.
 */

#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
EOF

sha256sum "${PRAGMA_ADAPTER}" >"${ADAPTERS}/pragma_adapter.sha256"
sha256sum "${OPTBLOCKER_ADAPTER}" >"${ADAPTERS}/optblocker_adapter.sha256"

COMMON_INCLUDES=(
  -I"${SRC}/mlkem"
  -I"${SRC}/mlkem/src"
)

FORCED_INCLUDES=(
  -include "${ZEROIZE_ADAPTER}"
  -include "${PRAGMA_ADAPTER}"
)

build_case()
{
  local case_id="$1"
  local namespace="$2"
  local harness="$3"
  local expected_harness_sha="$4"
  local build_dir="${BUILD}/${case_id}"
  local case_dir="${CASES}/${case_id}"
  local model="${build_dir}/${case_id}.goto"
  local reachable_model="${build_dir}/${case_id}_reachable_only.goto"
  local preprocessed="${build_dir}/poly.i"
  local blocker_symbol="${namespace}_ct_opt_blocker_u64"
  local unwindset
  local require_reduce="NO"
  local expected_failure_property="NONE"
  local property_count
  local common_defines
  local expected_loops
  local required_descriptions

  mkdir -p "${build_dir}" "${case_dir}/frozen_inputs"

  verify_hash "${expected_harness_sha}" "${harness}"

  case "${case_id}" in
    T2_RELATIONAL)
      require_reduce="YES"
      expected_loops=(
        "main.0" "main.1" "main.2" "main.3"
        "main.4" "main.5" "main.6" "main.7"
        "mlk_barrett_reduce.0"
        "${namespace}_poly_sub.0"
        "mlk_poly_reduce_c.0"
        "mlk_poly_reduce_c.1"
        "mlk_scalar_signed_to_unsigned_q.0"
        "mlk_scalar_signed_to_unsigned_q.1"
      )
      unwindset="main.0:257,main.1:257,main.2:257,main.3:257,main.4:257,main.5:257,main.6:257,main.7:257,mlk_barrett_reduce.0:2,${namespace}_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2"
      required_descriptions=(
        "SUB_T2_RELATIONAL: left and right canonical results must agree"
        "SUB_T2_RELATIONAL: left result must be non-negative"
        "SUB_T2_RELATIONAL: left result must be below FIPS_Q"
        "SUB_T2_RELATIONAL: right result must be non-negative"
        "SUB_T2_RELATIONAL: right result must be below FIPS_Q"
        "SUB_T2_FRAME: final A0 must equal saved A0"
        "SUB_T2_FRAME: final B0 must equal saved B0"
      )
      ;;
    VALID_BOUNDARY)
      require_reduce="YES"
      expected_loops=(
        "main.0" "main.1" "main.2"
        "mlk_barrett_reduce.0"
        "${namespace}_poly_sub.0"
        "mlk_poly_reduce_c.0"
        "mlk_poly_reduce_c.1"
        "mlk_scalar_signed_to_unsigned_q.0"
        "mlk_scalar_signed_to_unsigned_q.1"
      )
      unwindset="main.0:257,main.1:257,main.2:257,mlk_barrett_reduce.0:2,${namespace}_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2"
      required_descriptions=(
        "SUB_BOUNDARY_VALID: INT16_MIN canonical result must be 522"
        "SUB_BOUNDARY_VALID: INT16_MAX canonical result must be 2806"
        "SUB_BOUNDARY_VALID: untouched zero coefficients must remain zero"
        "SUB_BOUNDARY_FRAME: B working copy must remain unchanged"
      )
      ;;
    INVALID_LOWER|INVALID_UPPER)
      expected_loops=(
        "main.0"
        "${namespace}_poly_sub.0"
      )
      unwindset="main.0:257,${namespace}_poly_sub.0:257"
      required_descriptions=()
      ;;
    *)
      fail "unknown case: ${case_id}"
      ;;
  esac

  common_defines=(
    -DMLK_CONFIG_PARAMETER_SET=768
    -DMLK_CONFIG_NAMESPACE_PREFIX="${namespace}"
    -DMLK_CONFIG_NO_ASM=1
    -DMLK_CONFIG_CUSTOM_ZEROIZE=1
  )

  STEP="preprocess ${case_id}"
  local preprocess_command=(
    cc
    -std=c90
    "${common_defines[@]}"
    "${FORCED_INCLUDES[@]}"
    "${COMMON_INCLUDES[@]}"
    -E
    -P
    "${PRISTINE_POLY}"
    -o "${preprocessed}"
  )

  write_command "${build_dir}/preprocess_command.txt" \
    "${preprocess_command[@]}"

  run_capture "${build_dir}/preprocess_output.txt" \
    "${preprocess_command[@]}"

  test -s "${preprocessed}" ||
    fail "${case_id}: preprocessed poly.c was not produced"

  grep -F '#pragma CPROVER check disable "conversion"' \
    "${preprocessed}" \
    >"${build_dir}/conversion_disable_pragma_match.txt" ||
    fail "${case_id}: scoped conversion pragma missing"

  grep -F '#pragma CPROVER check pop' \
    "${preprocessed}" \
    >"${build_dir}/conversion_pop_pragma_match.txt" ||
    fail "${case_id}: scoped conversion pragma pop missing"

  if grep -Eq '__CPROVER_(requires|ensures|assigns|frees|loop_invariant|decreases)' \
      "${preprocessed}"
  then
    grep -En '__CPROVER_(requires|ensures|assigns|frees|loop_invariant|decreases)' \
      "${preprocessed}" \
      >"${build_dir}/unexpected_contract_expansion.txt" || true
    fail "${case_id}: function or loop contracts unexpectedly expanded"
  else
    echo "No expanded function/loop contract primitives found." \
      >"${build_dir}/unexpected_contract_expansion.txt"
  fi

  STEP="construct ${case_id} GOTO model"
  local build_command=(
    goto-cc
    -std=c90
    "${common_defines[@]}"
    "${FORCED_INCLUDES[@]}"
    "${COMMON_INCLUDES[@]}"
    "${harness}"
    "${PRISTINE_POLY}"
    "${OPTBLOCKER_ADAPTER}"
    -o "${model}"
  )

  write_command "${build_dir}/goto_build_command.txt" \
    "${build_command[@]}"

  run_capture "${build_dir}/goto_build_output.txt" \
    "${build_command[@]}"

  test -s "${model}" || fail "${case_id}: GOTO model was not produced"
  sha256sum "${model}" >"${build_dir}/model.sha256"
  stat "${model}" >"${build_dir}/model.stat.txt"

  STEP="reject contract material in ${case_id}"
  strings "${model}" |
    LC_ALL=C sort -u |
    grep 'contract::' >"${build_dir}/contract_symbols.txt" || true

  test ! -s "${build_dir}/contract_symbols.txt" ||
    fail "${case_id}: contract symbols remain in model"

  STEP="validate and inspect ${case_id}"
  run_capture \
    "${build_dir}/validate_original_model.txt" \
    goto-instrument --validate-goto-binary "${model}"

  run_capture \
    "${build_dir}/show_symbol_table.txt" \
    goto-instrument --show-symbol-table "${model}"

  run_capture \
    "${build_dir}/show_goto_functions.txt" \
    goto-instrument --show-goto-functions "${model}"

  run_capture \
    "${build_dir}/reachable_call_graph.txt" \
    goto-instrument --reachable-call-graph "${model}"

  run_capture \
    "${build_dir}/undefined_functions.txt" \
    goto-instrument --list-undefined-functions "${model}"

  grep -q -- "${blocker_symbol}" "${build_dir}/show_symbol_table.txt" ||
    fail "${case_id}: zero blocker symbol absent"

  grep -E "ASSIGN.*${blocker_symbol}.*(=|:=).*0|${blocker_symbol}.*(=|:=).*0" \
    "${build_dir}/show_goto_functions.txt" \
    >"${build_dir}/blocker_zero_initialization_match.txt" ||
    fail "${case_id}: model-level zero blocker initialization absent"

  grep -q -- "${namespace}_poly_sub" "${build_dir}/reachable_call_graph.txt" ||
    fail "${case_id}: production poly_sub is not reachable"

  if test "${require_reduce}" = "YES"
  then
    grep -q -- "${namespace}_poly_reduce" \
      "${build_dir}/reachable_call_graph.txt" ||
      fail "${case_id}: production poly_reduce is not reachable"
  fi

  if grep -Eq '(^|[^[:alnum:]_])mlk_zeroize([^[:alnum:]_]|$)' \
      "${build_dir}/reachable_call_graph.txt"
  then
    fail "${case_id}: zeroize adapter is unexpectedly reachable"
  fi

  STEP="construct reachable-only ${case_id} model"
  run_capture \
    "${build_dir}/drop_unused_functions.txt" \
    goto-instrument --drop-unused-functions "${model}" "${reachable_model}"

  test -s "${reachable_model}" ||
    fail "${case_id}: reachable-only model was not produced"

  sha256sum "${reachable_model}" >"${build_dir}/reachable_model.sha256"

  run_capture \
    "${build_dir}/validate_reachable_model.txt" \
    goto-instrument --validate-goto-binary "${reachable_model}"

  STEP="verify exact ${case_id} loop set"
  run_capture \
    "${build_dir}/reachable_loops.txt" \
    goto-instrument --show-loops "${reachable_model}"

  grep '^Loop ' "${build_dir}/reachable_loops.txt" |
    sed -E 's/^Loop ([^:]+):$/\1/' |
    LC_ALL=C sort >"${build_dir}/actual_loop_ids.txt"

  printf '%s\n' "${expected_loops[@]}" |
    LC_ALL=C sort >"${build_dir}/expected_loop_ids.txt"

  if ! diff -u \
      "${build_dir}/expected_loop_ids.txt" \
      "${build_dir}/actual_loop_ids.txt" \
      >"${build_dir}/loop_set_diff.txt"
  then
    cat "${build_dir}/loop_set_diff.txt" >&2
    fail "${case_id}: reachable loop set differs from preregistration"
  fi

  STEP="inventory ${case_id} properties without solving"
  local property_command=(
    cbmc
    "${model}"
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
    --unwindset "${unwindset}"
    --show-properties
  )

  write_command "${build_dir}/property_inventory_command.txt" \
    "${property_command[@]}"

  run_capture \
    "${build_dir}/property_inventory.txt" \
    "${property_command[@]}"

  property_count="$(
    grep -c '^Property ' "${build_dir}/property_inventory.txt"
  )"

  test "${property_count}" -gt 0 ||
    fail "${case_id}: empty property inventory"

  for required in "${required_descriptions[@]}"
  do
    grep -Fq "${required}" "${build_dir}/property_inventory.txt" ||
      fail "${case_id}: required property missing: ${required}"
  done

  if grep -Fq "mlk_cast_uint16_to_int16.overflow.1" \
      "${build_dir}/property_inventory.txt"
  then
    fail "${case_id}: intentional helper conversion property is active"
  fi

  if grep -Eq 'contract::|shake256x4' \
      "${build_dir}/property_inventory.txt"
  then
    fail "${case_id}: unrelated contract material leaked"
  fi

  if test "${case_id}" = "INVALID_LOWER" ||
     test "${case_id}" = "INVALID_UPPER"
  then
    expected_failure_property="$(
      python3 - \
        "${build_dir}/property_inventory.txt" \
        "${namespace}" <<'PY'
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8")
namespace = sys.argv[2]

matches = []
for block in re.split(r"(?m)^Property ", text)[1:]:
    property_id = block.split(":", 1)[0].strip()
    if (
        property_id.startswith(namespace + "_poly_sub.overflow.")
        and "arithmetic overflow on signed type conversion" in block
        and "(int16_t)" in block
    ):
        matches.append(property_id)

if len(matches) != 1:
    raise SystemExit(
        f"expected exactly one signed conversion property, found {matches}"
    )

print(matches[0])
PY
    )"

    test -n "${expected_failure_property}" ||
      fail "${case_id}: expected conversion-failure property not identified"
  fi

  cat >"${build_dir}/CASE_MODEL_RECORD.txt" <<EOF
CASE_ID=${case_id}
NAMESPACE=${namespace}
MODEL_SHA256=$(hash_of "${model}")
REACHABLE_MODEL_SHA256=$(hash_of "${reachable_model}")
HARNESS_SHA256=$(hash_of "${harness}")
PRISTINE_POLY_SHA256=$(hash_of "${PRISTINE_POLY}")
PROPERTY_INVENTORY_SHA256=$(hash_of "${build_dir}/property_inventory.txt")
EXPECTED_PROPERTY_COUNT=${property_count}
EXPECTED_FAILURE_PROPERTY=${expected_failure_property}
EXACT_UNWINDSET=${unwindset}
ORIGINAL_MODEL_VALIDATION=PASS
REACHABLE_MODEL_VALIDATION=PASS
EOF

  cp -a "${model}" \
    "${case_dir}/frozen_inputs/${case_id}.goto"
  cp -a "${reachable_model}" \
    "${case_dir}/frozen_inputs/${case_id}_reachable_only.goto"
  cp -a "${harness}" \
    "${case_dir}/frozen_inputs/$(basename "${harness}")"
  cp -a "${build_dir}/property_inventory.txt" \
    "${case_dir}/frozen_inputs/property_inventory.txt"
  cp -a "${build_dir}/reachable_loops.txt" \
    "${case_dir}/frozen_inputs/reachable_loops.txt"
  cp -a "${build_dir}/CASE_MODEL_RECORD.txt" \
    "${case_dir}/frozen_inputs/CASE_MODEL_RECORD.txt"
}

STEP="preflight T2 relational model"
build_case \
  "T2_RELATIONAL" \
  "mlk_sub00l_t2" \
  "${T2_HARNESS}" \
  "${T2_HARNESS_SHA256}"

STEP="preflight valid boundary model"
build_case \
  "VALID_BOUNDARY" \
  "mlk_sub00l_valid" \
  "${VALID_HARNESS}" \
  "${VALID_HARNESS_SHA256}"

STEP="preflight invalid lower model"
build_case \
  "INVALID_LOWER" \
  "mlk_sub00l_low" \
  "${LOWER_HARNESS}" \
  "${LOWER_HARNESS_SHA256}"

STEP="preflight invalid upper model"
build_case \
  "INVALID_UPPER" \
  "mlk_sub00l_high" \
  "${UPPER_HARNESS}" \
  "${UPPER_HARNESS_SHA256}"

STEP="reverify pristine inputs after all model construction"
verify_hash "${SOURCE_MANIFEST_SHA256}" "${SOURCE_MANIFEST}"
verify_hash "${FREEZE_MANIFEST_SHA256}" "${FREEZE_MANIFEST}"
verify_hash "${T2_HARNESS_SHA256}" "${T2_HARNESS}"
verify_hash "${VALID_HARNESS_SHA256}" "${VALID_HARNESS}"
verify_hash "${LOWER_HARNESS_SHA256}" "${LOWER_HARNESS}"
verify_hash "${UPPER_HARNESS_SHA256}" "${UPPER_HARNESS}"

STEP="freeze combined preflight identity"
cp -a "${SCRIPT_PATH}" "${OUT}/executed_runner.sh"
sha256sum "${SCRIPT_PATH}" >"${OUT}/executed_runner.sha256"

{
  echo "SUB-00F package:"
  sha256sum "${FREEZE_PACKAGE}"
  echo
  echo "Accepted SUB-00H:"
  sha256sum "${SUB00H_ARCHIVE}"
  echo
  echo "Accepted SUB-00I:"
  sha256sum "${SUB00I_ARCHIVE}"
  echo
  echo "Accepted SUB-00J:"
  sha256sum "${SUB00J_ARCHIVE}"
  echo
  echo "Accepted SUB-00K:"
  sha256sum "${SUB00K_ARCHIVE}"
  echo
  echo "Executing runner:"
  sha256sum "${SCRIPT_PATH}"
} >"${OUT}/parent_and_runner_hashes.txt"

execute_case()
{
  local case_id="$1"
  local expected_mode="$2"
  local case_dir="${CASES}/${case_id}"
  local record="${case_dir}/frozen_inputs/CASE_MODEL_RECORD.txt"
  local model="${case_dir}/frozen_inputs/${case_id}.goto"
  local expected_count
  local expected_failure_property
  local expected_model_sha
  local expected_inventory_sha
  local unwindset
  local rc

  expected_count="$(
    sed -n 's/^EXPECTED_PROPERTY_COUNT=//p' "${record}"
  )"
  expected_failure_property="$(
    sed -n 's/^EXPECTED_FAILURE_PROPERTY=//p' "${record}"
  )"
  expected_model_sha="$(
    sed -n 's/^MODEL_SHA256=//p' "${record}"
  )"
  expected_inventory_sha="$(
    sed -n 's/^PROPERTY_INVENTORY_SHA256=//p' "${record}"
  )"
  unwindset="$(
    sed -n 's/^EXACT_UNWINDSET=//p' "${record}"
  )"

  test -n "${expected_count}" ||
    fail "${case_id}: expected property count absent"
  test -n "${expected_model_sha}" ||
    fail "${case_id}: model hash absent"
  test -n "${expected_inventory_sha}" ||
    fail "${case_id}: property-inventory hash absent"
  test -n "${unwindset}" ||
    fail "${case_id}: unwindset absent"

  STEP="reverify frozen preflight inputs for ${case_id}"
  verify_hash "${expected_model_sha}" "${model}"
  verify_hash     "${expected_inventory_sha}"     "${case_dir}/frozen_inputs/property_inventory.txt"

  STEP="final validation for ${case_id}"
  run_capture \
    "${case_dir}/final_validation.txt" \
    goto-instrument --validate-goto-binary "${model}"

  STEP="execute ${case_id}"
  local command=(
    cbmc
    "${model}"
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
    --unwindset "${unwindset}"
    --slice-formula
    --sat-solver minisat2
    --trace
    --json-ui
  )

  write_command "${case_dir}/cbmc_command.txt" "${command[@]}"

  set +e
  /usr/bin/time -v \
    -o "${case_dir}/resource_usage.txt" \
    timeout \
    --signal=TERM \
    --kill-after=60s \
    21600s \
    "${command[@]}" \
    >"${case_dir}/cbmc_result.json" \
    2>"${case_dir}/cbmc_stderr.txt"
  rc="$?"
  set -e

  printf '%s\n' "${rc}" >"${case_dir}/cbmc_exit_code.txt"

  STEP="classify ${case_id}"
  python3 - \
    "${case_id}" \
    "${expected_mode}" \
    "${expected_count}" \
    "${expected_failure_property}" \
    "${case_dir}/cbmc_exit_code.txt" \
    "${case_dir}/cbmc_result.json" \
    "${case_dir}/independent_summary.json" \
    "${case_dir}/CLASSIFICATION.txt" <<'PY'
import json
import re
import sys
from pathlib import Path

(
    case_id,
    expected_mode,
    expected_count_text,
    expected_failure_property,
    exit_path,
    json_path,
    summary_path,
    classification_path,
) = sys.argv[1:]

expected_count = int(expected_count_text)
raw_exit = int(Path(exit_path).read_text(encoding="utf-8").strip())

parse_error = None
statuses = []
results = []
messages = []

try:
    data = json.loads(Path(json_path).read_text(encoding="utf-8"))

    if not isinstance(data, list):
        raise TypeError("top-level JSON value is not a list")

    for item in data:
        if not isinstance(item, dict):
            continue

        if "result" in item and isinstance(item["result"], list):
            results.extend(
                value for value in item["result"]
                if isinstance(value, dict)
            )

        if "cProverStatus" in item:
            statuses.append(str(item["cProverStatus"]))

        if "messageText" in item:
            messages.append(str(item["messageText"]))
except Exception as exc:
    parse_error = f"{type(exc).__name__}: {exc}"

failures = [
    result for result in results
    if str(result.get("status", "")).upper() == "FAILURE"
]

other = [
    result for result in results
    if str(result.get("status", "")).upper()
    not in {"SUCCESS", "FAILURE"}
]

unwinding_failures = [
    result for result in failures
    if "unwind" in (
        str(result.get("property", ""))
        + " "
        + str(result.get("description", ""))
    ).lower()
]

required_descriptions = {
    "T2_RELATIONAL": [
        "SUB_T2_RELATIONAL: left and right canonical results must agree",
        "SUB_T2_RELATIONAL: left result must be non-negative",
        "SUB_T2_RELATIONAL: left result must be below FIPS_Q",
        "SUB_T2_RELATIONAL: right result must be non-negative",
        "SUB_T2_RELATIONAL: right result must be below FIPS_Q",
        "SUB_T2_FRAME: final A0 must equal saved A0",
        "SUB_T2_FRAME: final B0 must equal saved B0",
    ],
    "VALID_BOUNDARY": [
        "SUB_BOUNDARY_VALID: INT16_MIN canonical result must be 522",
        "SUB_BOUNDARY_VALID: INT16_MAX canonical result must be 2806",
        "SUB_BOUNDARY_VALID: untouched zero coefficients must remain zero",
        "SUB_BOUNDARY_FRAME: B working copy must remain unchanged",
    ],
}

required_statuses = {}
for description in required_descriptions.get(case_id, []):
    matching = [
        result for result in results
        if result.get("description") == description
    ]
    required_statuses[description] = [
        result.get("status") for result in matching
    ]

expected_failure_result = next(
    (
        result for result in results
        if result.get("property") == expected_failure_property
    ),
    None,
)

boundary_witness = None
if expected_mode == "EXPECTED_FAILURE" and expected_failure_result:
    latest_a0 = None
    latest_b0 = None

    for step in expected_failure_result.get("trace", []):
        if step.get("stepType") != "assignment":
            continue

        lhs = str(step.get("lhs", ""))
        value_object = step.get("value", {})
        value = value_object.get("data")

        if value is None:
            continue

        if re.fullmatch(r"A0\.coeffs\[0l\]", lhs):
            latest_a0 = int(value)

        if re.fullmatch(r"B0\.coeffs\[0l\]", lhs):
            latest_b0 = int(value)

    expected_pair = {
        "INVALID_LOWER": (-32768, 1, -32769),
        "INVALID_UPPER": (32767, -1, 32768),
    }.get(case_id)

    boundary_witness = {
        "a0": latest_a0,
        "b0": latest_b0,
        "mathematical_difference": (
            latest_a0 - latest_b0
            if latest_a0 is not None and latest_b0 is not None
            else None
        ),
        "expected_pair": expected_pair,
        "matches_expected_boundary": (
            expected_pair is not None
            and latest_a0 == expected_pair[0]
            and latest_b0 == expected_pair[1]
            and latest_a0 - latest_b0 == expected_pair[2]
        ),
    }

if expected_mode == "EXPECTED_SUCCESS":
    required_ok = all(
        statuses_list == ["SUCCESS"]
        for statuses_list in required_statuses.values()
    )

    eligible = (
        parse_error is None
        and raw_exit == 0
        and len(results) == expected_count
        and len(failures) == 0
        and len(other) == 0
        and all(
            str(result.get("status", "")).upper() == "SUCCESS"
            for result in results
        )
        and any(status.lower() == "success" for status in statuses)
        and required_ok
        and len(unwinding_failures) == 0
    )

    if case_id == "T2_RELATIONAL":
        classification = (
            "T2_PASS_PENDING_INDEPENDENT_REVIEW"
            if eligible
            else "T2_NOT_PASSED_OR_NOT_YET_CLASSIFIABLE"
        )
    else:
        classification = (
            "VALID_BOUNDARY_PASS_PENDING_INDEPENDENT_REVIEW"
            if eligible
            else "VALID_BOUNDARY_NOT_PASSED_OR_NOT_YET_CLASSIFIABLE"
        )
else:
    failure_ids = [result.get("property") for result in failures]

    eligible = (
        parse_error is None
        and raw_exit == 10
        and len(results) == expected_count
        and len(failures) == 1
        and len(other) == 0
        and failure_ids == [expected_failure_property]
        and expected_failure_result is not None
        and str(expected_failure_result.get("status", "")).upper()
            == "FAILURE"
        and any(status.lower() == "failure" for status in statuses)
        and len(unwinding_failures) == 0
        and boundary_witness is not None
        and boundary_witness["matches_expected_boundary"]
    )

    classification = (
        "INVALID_BOUNDARY_REJECTED_BY_EXPECTED_CONVERSION_CHECK"
        if eligible
        else "INVALID_BOUNDARY_NOT_REJECTED_AS_EXPECTED"
    )

summary = {
    "case_id": case_id,
    "expected_mode": expected_mode,
    "classification": classification,
    "raw_cbmc_exit_code": raw_exit,
    "json_parse_error": parse_error,
    "cprover_statuses": statuses,
    "expected_property_count": expected_count,
    "actual_property_count": len(results),
    "failure_count": len(failures),
    "other_status_count": len(other),
    "failing_properties": [
        {
            "property": result.get("property"),
            "description": result.get("description"),
        }
        for result in failures
    ],
    "unwinding_failure_count": len(unwinding_failures),
    "required_property_statuses": required_statuses,
    "expected_failure_property": expected_failure_property,
    "boundary_witness": boundary_witness,
    "verification_successful_message": (
        "VERIFICATION SUCCESSFUL" in messages
    ),
    "verification_failed_message": (
        "VERIFICATION FAILED" in messages
    ),
}

Path(summary_path).write_text(
    json.dumps(summary, indent=2) + "\n",
    encoding="utf-8",
)

Path(classification_path).write_text(
    "\n".join(
        [
            f"CASE_ID={case_id}",
            f"CASE_CLASSIFICATION={classification}",
            f"RAW_CBMC_EXIT_CODE={raw_exit}",
            f"EXPECTED_PROPERTY_COUNT={expected_count}",
            f"ACTUAL_PROPERTY_COUNT={len(results)}",
            f"FAILURE_COUNT={len(failures)}",
            f"UNWINDING_FAILURES={len(unwinding_failures)}",
            "INDEPENDENT_REVIEW_REQUIRED=YES",
            "NOVELTY_ESTABLISHED_BY_THIS_CASE=NO",
        ]
    )
    + "\n",
    encoding="utf-8",
)
PY
}

STEP="execute T2 relational theorem"
execute_case "T2_RELATIONAL" "EXPECTED_SUCCESS"

STEP="execute valid boundary control"
execute_case "VALID_BOUNDARY" "EXPECTED_SUCCESS"

STEP="execute invalid lower control"
execute_case "INVALID_LOWER" "EXPECTED_FAILURE"

STEP="execute invalid upper control"
execute_case "INVALID_UPPER" "EXPECTED_FAILURE"

STEP="compute combined verdict"
python3 - \
  "${CASES}/T2_RELATIONAL/CLASSIFICATION.txt" \
  "${CASES}/VALID_BOUNDARY/CLASSIFICATION.txt" \
  "${CASES}/INVALID_LOWER/CLASSIFICATION.txt" \
  "${CASES}/INVALID_UPPER/CLASSIFICATION.txt" \
  "${STATUS_FILE}" <<'PY'
import sys
from pathlib import Path

t2, valid, lower, upper, output = map(Path, sys.argv[1:])

texts = {
    "T2_RELATIONAL": t2.read_text(encoding="utf-8"),
    "VALID_BOUNDARY": valid.read_text(encoding="utf-8"),
    "INVALID_LOWER": lower.read_text(encoding="utf-8"),
    "INVALID_UPPER": upper.read_text(encoding="utf-8"),
}

expected = {
    "T2_RELATIONAL":
        "CASE_CLASSIFICATION=T2_PASS_PENDING_INDEPENDENT_REVIEW",
    "VALID_BOUNDARY":
        "CASE_CLASSIFICATION=VALID_BOUNDARY_PASS_PENDING_INDEPENDENT_REVIEW",
    "INVALID_LOWER":
        "CASE_CLASSIFICATION=INVALID_BOUNDARY_REJECTED_BY_EXPECTED_CONVERSION_CHECK",
    "INVALID_UPPER":
        "CASE_CLASSIFICATION=INVALID_BOUNDARY_REJECTED_BY_EXPECTED_CONVERSION_CHECK",
}

met = {
    case_id: marker in texts[case_id]
    for case_id, marker in expected.items()
}

passed = sum(met.values())

verdict = (
    "PASS_4_OF_4_EXPECTATIONS_MET"
    if passed == 4
    else "NOT_ALL_EXPECTATIONS_MET"
)

lines = [
    f"COMBINED_BATCH_VERDICT={verdict}",
    "CASES_PREFLIGHTED=4",
    "CASES_EXECUTED_OR_ATTEMPTED=4",
    f"CASES_MEETING_EXPECTATION={passed}",
    f"T2_EXPECTATION_MET={'YES' if met['T2_RELATIONAL'] else 'NO'}",
    f"VALID_BOUNDARY_EXPECTATION_MET={'YES' if met['VALID_BOUNDARY'] else 'NO'}",
    f"INVALID_LOWER_EXPECTATION_MET={'YES' if met['INVALID_LOWER'] else 'NO'}",
    f"INVALID_UPPER_EXPECTATION_MET={'YES' if met['INVALID_UPPER'] else 'NO'}",
    "NOVELTY_ESTABLISHED_BY_THIS_BATCH=NO",
]

output.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

if grep -Fxq \
  "COMBINED_BATCH_VERDICT=PASS_4_OF_4_EXPECTATIONS_MET" \
  "${STATUS_FILE}"
then
  FINAL_RC=0
else
  FINAL_RC=10
fi

STEP="SUB-00L combined execution complete"
exit "${FINAL_RC}"
