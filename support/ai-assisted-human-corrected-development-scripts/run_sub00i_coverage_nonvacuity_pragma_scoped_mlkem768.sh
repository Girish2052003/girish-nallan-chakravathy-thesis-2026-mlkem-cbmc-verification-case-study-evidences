#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# SUB-00I
#
# Corrected-environment reachability/non-vacuity coverage for the frozen
# ML-KEM-768 poly_sub -> poly_reduce composition.
#
# This script:
#   - verifies the frozen campaign and accepted SUB-T1 evidence;
#   - rebuilds the frozen coverage harness with the already validated
#     pragma-scoping mechanism and zero-valued opt-blocker environment object;
#   - validates and inspects the GOTO model;
#   - executes exactly eight user-authored __CPROVER_cover goals;
#   - packages all evidence whether the run passes or fails.
#
# It does not modify the frozen theorem harness, the frozen coverage harness,
# or production poly.c.
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

FROZEN_HARNESS="${FREEZE}/harnesses/sub_cov_reachability_harness.c"
FROZEN_HARNESS_SHA256="132c34161c8230eb14e86acc0cae3af52fbf6eb429a8e55233080337dc4415d7"

ZEROIZE_ADAPTER="${FREEZE}/adapter/sub00e_r1_fail_closed_zeroize.h"
ZEROIZE_ADAPTER_SHA256="45d33b9ee3fe3613f23906de520bf9d5ce245a18b537c32787201912dec4e926"

OUT="${BASE}/SUB00I_COVERAGE_NONVACUITY_PRAGMA_SCOPED_MLKEM768_RUN1"
BUILD="${OUT}/build"
RESULT="${OUT}/result"

MODEL="${BUILD}/sub_cov_pragma_scoped_mlkem768.goto"
REACHABLE_MODEL="${BUILD}/sub_cov_pragma_scoped_mlkem768_reachable_only.goto"
PRAGMA_ADAPTER="${BUILD}/sub00i_verify_pragma_scope.h"
OPTBLOCKER_ADAPTER="${BUILD}/sub00i_optblocker_zero.c"
PREPROCESSED_POLY="${BUILD}/poly_pragma_scoped.i"

JSON_RESULT="${RESULT}/cbmc_coverage_result.json"
STDERR_LOG="${RESULT}/cbmc_coverage_stderr.txt"
RESOURCE_LOG="${RESULT}/resource_usage.txt"
EXIT_FILE="${RESULT}/cbmc_coverage_exit_code.txt"
COMMAND_FILE="${RESULT}/cbmc_coverage_command.txt"
SUMMARY_FILE="${RESULT}/coverage_summary.txt"
CLASSIFICATION_FILE="${RESULT}/COVERAGE_CLASSIFICATION.txt"

ARTIFACT_MANIFEST="${OUT}/SUB00I_ARTIFACT_MANIFEST.sha256"
PACKAGE="${BASE}/SUB00I_COVERAGE_NONVACUITY_PRAGMA_SCOPED_MLKEM768_RUN1.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

SCRIPT_PATH="$(readlink -f "$0")"
NAMESPACE="mlk_sub00i_cov"
BLOCKER_SYMBOL="${NAMESPACE}_ct_opt_blocker_u64"

STEP="initialization"
COVERAGE_STARTED="NO"
PACKAGED=0

EXPECTED_LOOPS=(
  "main.0"
  "main.1"
  "mlk_barrett_reduce.0"
  "${NAMESPACE}_poly_sub.0"
  "mlk_poly_reduce_c.0"
  "mlk_poly_reduce_c.1"
  "mlk_scalar_signed_to_unsigned_q.0"
  "mlk_scalar_signed_to_unsigned_q.1"
)

UNWINDSET="main.0:257,main.1:257,mlk_barrett_reduce.0:2,${NAMESPACE}_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2"

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
      echo "COVERAGE_STARTED=${COVERAGE_STARTED}"
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
    echo "SUB-00I COVERAGE EVIDENCE PACKAGED"
    echo "============================================================"
    echo "Last step: ${STEP}"
    echo "Coverage started: ${COVERAGE_STARTED}"
    echo

    if test -f "${SUMMARY_FILE}"
    then
      cat "${SUMMARY_FILE}"
      echo
    fi

    if test -f "${CLASSIFICATION_FILE}"
    then
      cat "${CLASSIFICATION_FILE}"
      echo
    fi

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
  sha256sum python3 readlink strings
do
  command -v "${tool}" >/dev/null 2>&1 ||
    fail "required tool unavailable: ${tool}"
done

test -x /usr/bin/time || fail "/usr/bin/time is unavailable"
test -f "${SCRIPT_PATH}" || fail "unable to resolve the executing script"

test -d "${BASE}" || fail "campaign directory missing: ${BASE}"
test -d "${REPO}/.git" || fail "repository missing: ${REPO}"
test -d "${SRC}/mlkem/src" || fail "clean-room source snapshot missing: ${SRC}"
test -d "${FREEZE}" || fail "SUB-00F freeze directory missing: ${FREEZE}"

test ! -e "${OUT}" || fail "versioned output already exists: ${OUT}"
test ! -e "${PACKAGE}" || fail "versioned package already exists: ${PACKAGE}"
test ! -e "${PACKAGE_HASH}" || fail "versioned package sidecar already exists"

mkdir -p "${BUILD}" "${RESULT}/frozen_inputs"

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

STEP="verify frozen commit"
HEAD="$(git -C "${REPO}" rev-parse HEAD)"
test "${HEAD}" = "${FROZEN_COMMIT}" || {
  echo "Expected commit: ${FROZEN_COMMIT}" >&2
  echo "Actual commit:   ${HEAD}" >&2
  fail "repository commit changed"
}

STEP="verify parent evidence identities"
verify_hash "${SOURCE_MANIFEST_SHA256}" "${SOURCE_MANIFEST}"
verify_hash "${FREEZE_PACKAGE_SHA256}" "${FREEZE_PACKAGE}"
verify_hash "${FREEZE_MANIFEST_SHA256}" "${FREEZE_MANIFEST}"
verify_hash "${SUB00H_ARCHIVE_SHA256}" "${SUB00H_ARCHIVE}"
verify_hash "${FROZEN_HARNESS_SHA256}" "${FROZEN_HARNESS}"
verify_hash "${ZEROIZE_ADAPTER_SHA256}" "${ZEROIZE_ADAPTER}"

STEP="verify source snapshot"
sha256sum --check "${SOURCE_MANIFEST}" \
  >"${OUT}/source_manifest_check.txt" 2>&1

STEP="verify SUB-00F frozen artefacts"
(
  cd "${FREEZE}"
  sha256sum --check "$(basename "${FREEZE_MANIFEST}")"
) >"${OUT}/sub00f_manifest_check.txt" 2>&1

STEP="verify eight frozen coverage calls"
HARNESS_COVER_COUNT="$(
  grep -Ec '^[[:space:]]*__CPROVER_cover[[:space:]]*\(' \
    "${FROZEN_HARNESS}"
)"
test "${HARNESS_COVER_COUNT}" -eq 8 ||
  fail "frozen harness does not contain exactly eight coverage calls"

cat >"${BUILD}/frozen_cover_call_count.txt" <<EOF
HARNESS_COVER_CALLS=${HARNESS_COVER_COUNT}
EXPECTED_COVER_CALLS=8
EOF

STEP="write scoped pragma adapter"
cat >"${PRAGMA_ADAPTER}" <<'EOF'
#ifndef SUB00I_VERIFY_PRAGMA_SCOPE_H
#define SUB00I_VERIFY_PRAGMA_SCOPE_H

/*
 * Activate only verify.h's CBMC-specific conversion-check pragma while
 * keeping function contracts and loop contracts disabled.
 *
 * cbmc.h is first included while CBMC is undefined, fixing its normal
 * no-contract macro definitions behind the include guard. CBMC is then
 * defined only while verify.h is parsed and is immediately undefined again.
 */

#ifdef CBMC
#error "SUB-00I requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00I_VERIFY_PRAGMA_SCOPE_H */
EOF

STEP="write zero-valued blocker environment definition"
cat >"${OPTBLOCKER_ADAPTER}" <<'EOF'
/*
 * SUB-00I environment definition.
 *
 * The portable value barrier reads a namespaced volatile uint64_t documented
 * by verify.h as being set to zero. This translation unit supplies that
 * zero-valued environment object without modifying production poly.c.
 */

#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
EOF

sha256sum "${PRAGMA_ADAPTER}" >"${BUILD}/pragma_adapter.sha256"
sha256sum "${OPTBLOCKER_ADAPTER}" >"${BUILD}/optblocker_adapter.sha256"
sha256sum "${FROZEN_HARNESS}" >"${BUILD}/frozen_harness.sha256"
sha256sum "${ZEROIZE_ADAPTER}" >"${BUILD}/zeroize_adapter.sha256"

COMMON_DEFINES=(
  -DMLK_CONFIG_PARAMETER_SET=768
  -DMLK_CONFIG_NAMESPACE_PREFIX="${NAMESPACE}"
  -DMLK_CONFIG_NO_ASM=1
  -DMLK_CONFIG_CUSTOM_ZEROIZE=1
)

COMMON_INCLUDES=(
  -I"${SRC}/mlkem"
  -I"${SRC}/mlkem/src"
)

FORCED_INCLUDES=(
  -include "${ZEROIZE_ADAPTER}"
  -include "${PRAGMA_ADAPTER}"
)

STEP="preprocess production source for adapter audit"
PREPROCESS_COMMAND=(
  cc
  -std=c90
  "${COMMON_DEFINES[@]}"
  "${FORCED_INCLUDES[@]}"
  "${COMMON_INCLUDES[@]}"
  -E
  -P
  "${SRC}/mlkem/src/poly.c"
  -o "${PREPROCESSED_POLY}"
)

write_command "${BUILD}/preprocess_command.txt" "${PREPROCESS_COMMAND[@]}"
run_capture "${BUILD}/preprocess_output.txt" "${PREPROCESS_COMMAND[@]}"

test -s "${PREPROCESSED_POLY}" ||
  fail "preprocessed poly.c was not produced"

grep -F '#pragma CPROVER check disable "conversion"' \
  "${PREPROCESSED_POLY}" \
  >"${BUILD}/conversion_disable_pragma_match.txt" ||
  fail "conversion-disable pragma was not activated"

grep -F '#pragma CPROVER check pop' \
  "${PREPROCESSED_POLY}" \
  >"${BUILD}/conversion_pop_pragma_match.txt" ||
  fail "conversion pragma pop was not activated"

if grep -Eq '__CPROVER_(requires|ensures|assigns|frees|loop_invariant|decreases)' \
    "${PREPROCESSED_POLY}"
then
  grep -En '__CPROVER_(requires|ensures|assigns|frees|loop_invariant|decreases)' \
    "${PREPROCESSED_POLY}" \
    >"${BUILD}/unexpected_contract_expansion.txt" || true
  fail "function or loop contracts unexpectedly expanded"
else
  echo "No expanded function/loop contract primitives found." \
    >"${BUILD}/unexpected_contract_expansion.txt"
fi

STEP="construct corrected coverage GOTO model"
BUILD_COMMAND=(
  goto-cc
  -std=c90
  "${COMMON_DEFINES[@]}"
  "${FORCED_INCLUDES[@]}"
  "${COMMON_INCLUDES[@]}"
  "${FROZEN_HARNESS}"
  "${SRC}/mlkem/src/poly.c"
  "${OPTBLOCKER_ADAPTER}"
  -o "${MODEL}"
)

write_command "${BUILD}/goto_build_command.txt" "${BUILD_COMMAND[@]}"
run_capture "${BUILD}/goto_build_output.txt" "${BUILD_COMMAND[@]}"

test -s "${MODEL}" || fail "coverage GOTO model was not produced"
sha256sum "${MODEL}" >"${BUILD}/model.sha256"
stat "${MODEL}" >"${BUILD}/model.stat.txt"

STEP="reject globally expanded contract symbols"
strings "${MODEL}" |
  LC_ALL=C sort -u |
  grep 'contract::' >"${BUILD}/contract_symbols.txt" || true

test ! -s "${BUILD}/contract_symbols.txt" ||
  fail "contract symbols remain in the body-level coverage model"

STEP="validate corrected coverage model"
run_capture \
  "${BUILD}/validate_original_model.txt" \
  goto-instrument --validate-goto-binary "${MODEL}"

STEP="inspect corrected coverage model"
run_capture \
  "${BUILD}/show_symbol_table.txt" \
  goto-instrument --show-symbol-table "${MODEL}"

run_capture \
  "${BUILD}/show_goto_functions.txt" \
  goto-instrument --show-goto-functions "${MODEL}"

run_capture \
  "${BUILD}/reachable_call_graph.txt" \
  goto-instrument --reachable-call-graph "${MODEL}"

run_capture \
  "${BUILD}/undefined_functions.txt" \
  goto-instrument --list-undefined-functions "${MODEL}"

grep -q -- "${BLOCKER_SYMBOL}" "${BUILD}/show_symbol_table.txt" ||
  fail "zero blocker symbol is absent from the model"

grep -Eq "ASSIGN.*${BLOCKER_SYMBOL}.*(=|:=).*0|${BLOCKER_SYMBOL}.*(=|:=).*0" \
  "${BUILD}/show_goto_functions.txt" \
  >"${BUILD}/blocker_zero_initialization_match.txt" ||
  fail "model-level zero initialization for the blocker was not found"

grep -q -- "${NAMESPACE}_poly_sub" "${BUILD}/reachable_call_graph.txt" ||
  fail "production poly_sub is not reachable"

grep -q -- "${NAMESPACE}_poly_reduce" "${BUILD}/reachable_call_graph.txt" ||
  fail "production poly_reduce is not reachable"

if grep -Eq '(^|[^[:alnum:]_])mlk_zeroize([^[:alnum:]_]|$)' \
    "${BUILD}/reachable_call_graph.txt"
then
  fail "fail-closed zeroize adapter is unexpectedly reachable"
fi

MODEL_COVER_COUNT="$(
  grep -c 'CALL __CPROVER_cover' "${BUILD}/show_goto_functions.txt"
)"
test "${MODEL_COVER_COUNT}" -eq 8 ||
  fail "GOTO model does not contain exactly eight explicit coverage calls"

REDUCE_CALL_LINE="$(
  grep -n "CALL ${NAMESPACE}_poly_reduce" \
    "${BUILD}/show_goto_functions.txt" |
  head -n 1 |
  cut -d: -f1
)"

FIRST_COVER_LINE="$(
  grep -n 'CALL __CPROVER_cover' \
    "${BUILD}/show_goto_functions.txt" |
  head -n 1 |
  cut -d: -f1
)"

test -n "${REDUCE_CALL_LINE}" || fail "poly_reduce call line was not found"
test -n "${FIRST_COVER_LINE}" || fail "first coverage-call line was not found"
test "${FIRST_COVER_LINE}" -gt "${REDUCE_CALL_LINE}" ||
  fail "coverage goals do not occur after the production composition"

{
  echo "MODEL_COVER_CALLS=${MODEL_COVER_COUNT}"
  echo "POLY_REDUCE_CALL_TEXT_LINE=${REDUCE_CALL_LINE}"
  echo "FIRST_COVER_CALL_TEXT_LINE=${FIRST_COVER_LINE}"
  echo "ALL_COVER_GOALS_AFTER_POLY_REDUCE=YES"
} >"${BUILD}/coverage_call_order_audit.txt"

STEP="construct reachable-only inspection model"
run_capture \
  "${BUILD}/drop_unused_functions.txt" \
  goto-instrument --drop-unused-functions "${MODEL}" "${REACHABLE_MODEL}"

test -s "${REACHABLE_MODEL}" ||
  fail "reachable-only coverage model was not produced"

sha256sum "${REACHABLE_MODEL}" >"${BUILD}/reachable_model.sha256"

STEP="validate reachable-only coverage model"
run_capture \
  "${BUILD}/validate_reachable_model.txt" \
  goto-instrument --validate-goto-binary "${REACHABLE_MODEL}"

STEP="verify exact reachable loop set"
run_capture \
  "${BUILD}/reachable_loops.txt" \
  goto-instrument --show-loops "${REACHABLE_MODEL}"

grep '^Loop ' "${BUILD}/reachable_loops.txt" |
  sed -E 's/^Loop ([^:]+):$/\1/' |
  LC_ALL=C sort >"${BUILD}/actual_loop_ids.txt"

printf '%s\n' "${EXPECTED_LOOPS[@]}" |
  LC_ALL=C sort >"${BUILD}/expected_loop_ids.txt"

if ! diff -u \
    "${BUILD}/expected_loop_ids.txt" \
    "${BUILD}/actual_loop_ids.txt" \
    >"${BUILD}/loop_set_diff.txt"
then
  cat "${BUILD}/loop_set_diff.txt" >&2
  fail "reachable loop set differs from the preregistered coverage structure"
fi

STEP="record coverage property inventory without solving"
PROPERTY_COMMAND=(
  cbmc
  "${MODEL}"
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
  --unwindset "${UNWINDSET}"
  --cover cover
  --show-properties
)

write_command "${BUILD}/coverage_property_inventory_command.txt" \
  "${PROPERTY_COMMAND[@]}"

run_capture \
  "${BUILD}/coverage_property_inventory.txt" \
  "${PROPERTY_COMMAND[@]}"

STEP="write coverage method record"
cat >"${OUT}/SUB00I_COVERAGE_METHOD.md" <<EOF
# SUB-00I Coverage and Non-Vacuity Method

## Frozen target

- Commit: \`${FROZEN_COMMIT}\`
- Parameter set: ML-KEM-768
- Frozen coverage harness SHA-256:
  \`${FROZEN_HARNESS_SHA256}\`
- Parent accepted SUB-T1 archive SHA-256:
  \`${SUB00H_ARCHIVE_SHA256}\`

## Coverage goals

The frozen harness contains eight explicit \`__CPROVER_cover\` calls:

1. at least one positive coefficient difference;
2. at least one negative coefficient difference;
3. at least one zero coefficient difference;
4. at least one non-canonical positive input;
5. at least one non-canonical negative input;
6. an \`INT16_MIN\` coefficient difference;
7. an \`INT16_MAX\` coefficient difference;
8. unconditional reachability after production subtraction and reduction.

All eight cover calls occur after:

\`\`\`
mlk_poly_sub(&L, &LB);
mlk_poly_reduce(&L);
\`\`\`

## Model correction

The model uses the same correction pattern accepted for SUB-T1:

- function and loop contracts remain disabled;
- only verify.h's narrow conversion pragma is activated;
- the portable optimisation blocker is defined as volatile 64-bit zero;
- production poly_sub and poly_reduce bodies are retained;
- no production source file is modified.

## Unwinding policy

Exact unwindset:

\`${UNWINDSET}\`

CBMC does not permit \`--unwinding-assertions\` together with \`--cover\`.
Therefore this coverage run does not claim a new unwinding proof. Its bounds
are justified by the exact validated loop inventory and the fixed 256- and
one-iteration loop structures. SUB-T1 separately passed its unwinding
assertions for the same production path.

## Interpretation boundary

A coverage goal reported \`SATISFIED\` supplies a witness that the goal is
reachable under the harness assumptions.

Coverage evidence supports non-vacuity and scenario reachability. It does not
replace the successful SUB-T1 theorem, establish additional functional
correctness, or establish novelty by itself.
EOF

STEP="freeze execution inputs"
cp -a "${MODEL}" \
  "${RESULT}/frozen_inputs/sub_cov_pragma_scoped_mlkem768.goto"
cp -a "${REACHABLE_MODEL}" \
  "${RESULT}/frozen_inputs/sub_cov_pragma_scoped_mlkem768_reachable_only.goto"
cp -a "${FROZEN_HARNESS}" \
  "${RESULT}/frozen_inputs/sub_cov_reachability_harness.c"
cp -a "${PRAGMA_ADAPTER}" \
  "${RESULT}/frozen_inputs/sub00i_verify_pragma_scope.h"
cp -a "${OPTBLOCKER_ADAPTER}" \
  "${RESULT}/frozen_inputs/sub00i_optblocker_zero.c"
cp -a "${BUILD}/reachable_loops.txt" \
  "${RESULT}/frozen_inputs/reachable_loops.txt"
cp -a "${BUILD}/coverage_call_order_audit.txt" \
  "${RESULT}/frozen_inputs/coverage_call_order_audit.txt"
cp -a "${BUILD}/coverage_property_inventory.txt" \
  "${RESULT}/frozen_inputs/coverage_property_inventory.txt"
cp -a "${OUT}/SUB00I_COVERAGE_METHOD.md" \
  "${RESULT}/frozen_inputs/SUB00I_COVERAGE_METHOD.md"
cp -a "${SCRIPT_PATH}" \
  "${RESULT}/executed_runner.sh"

{
  echo "Parent accepted SUB-T1 archive:"
  sha256sum "${SUB00H_ARCHIVE}"
  echo
  echo "Coverage GOTO model:"
  sha256sum "${MODEL}"
  echo
  echo "Frozen coverage harness:"
  sha256sum "${FROZEN_HARNESS}"
  echo
  echo "Executing script:"
  sha256sum "${SCRIPT_PATH}"
} >"${RESULT}/parent_and_runner_hashes.txt"

STEP="final GOTO validation gate"
run_capture \
  "${RESULT}/final_validation.txt" \
  goto-instrument --validate-goto-binary "${MODEL}"

STEP="execute eight coverage goals"
COVERAGE_COMMAND=(
  cbmc
  "${MODEL}"
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
  --unwindset "${UNWINDSET}"
  --slice-formula
  --sat-solver minisat2
  --trace
  --show-test-suite
  --cover cover
  --json-ui
)

# Deliberately absent:
#   --unwinding-assertions
# CBMC documents that it cannot be combined with --cover.

write_command "${COMMAND_FILE}" "${COVERAGE_COMMAND[@]}"

COVERAGE_STARTED="YES"

set +e
/usr/bin/time -v \
  -o "${RESOURCE_LOG}" \
  timeout \
  --signal=TERM \
  --kill-after=60s \
  21600s \
  "${COVERAGE_COMMAND[@]}" \
  >"${JSON_RESULT}" \
  2>"${STDERR_LOG}"
CBMC_RC="$?"
set -e

printf '%s\n' "${CBMC_RC}" >"${EXIT_FILE}"

STEP="summarize coverage JSON"
python3 - \
  "${JSON_RESULT}" \
  "${SUMMARY_FILE}" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])

parse_error = ""
cprover_statuses = []
all_results = []

try:
    with json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    if not isinstance(data, list):
        raise TypeError("top-level JSON value is not a list")

    def walk(value):
        if isinstance(value, dict):
            if "cProverStatus" in value:
                cprover_statuses.append(str(value["cProverStatus"]))

            if "result" in value and isinstance(value["result"], list):
                for item in value["result"]:
                    if isinstance(item, dict):
                        all_results.append(item)

            for child in value.values():
                walk(child)
        elif isinstance(value, list):
            for child in value:
                walk(child)

    walk(data)
except Exception as exc:
    parse_error = f"{type(exc).__name__}: {exc}"

# De-duplicate result objects that may have been reached both directly and
# recursively through a containing object.
unique_results = []
seen = set()

for item in all_results:
    key = (
        str(item.get("property", "")),
        str(item.get("status", "")),
        str(item.get("description", "")),
    )
    if key not in seen:
        seen.add(key)
        unique_results.append(item)

satisfied_names = {"SATISFIED", "COVERED"}
failed_names = {"FAILED", "UNSATISFIED", "UNCOVERED"}

coverage_results = [
    item
    for item in unique_results
    if str(item.get("status", "")).upper()
    in satisfied_names | failed_names | {"UNKNOWN", "ERROR"}
]

satisfied = [
    item
    for item in coverage_results
    if str(item.get("status", "")).upper() in satisfied_names
]

failed = [
    item
    for item in coverage_results
    if str(item.get("status", "")).upper() in failed_names
]

other = [
    item
    for item in coverage_results
    if str(item.get("status", "")).upper()
    not in satisfied_names | failed_names
]

lines = [
    f"JSON_PARSE_ERROR={parse_error or 'NONE'}",
    (
        "CPROVER_STATUSES="
        + (",".join(cprover_statuses) if cprover_statuses else "NONE")
    ),
    f"ALL_RESULT_OBJECTS={len(unique_results)}",
    f"COVERAGE_GOALS={len(coverage_results)}",
    f"SATISFIED_GOALS={len(satisfied)}",
    f"FAILED_GOALS={len(failed)}",
    f"OTHER_GOALS={len(other)}",
    "",
    "COVERAGE_GOAL_RESULTS:",
]

if coverage_results:
    for item in coverage_results:
        lines.append(
            f"{item.get('property', '<unknown>')} | "
            f"{item.get('status', '<unknown>')} | "
            f"{item.get('description', '')}"
        )
else:
    lines.append("NONE")

summary_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

STEP="classify coverage outcome"
python3 - \
  "${EXIT_FILE}" \
  "${SUMMARY_FILE}" \
  "${CLASSIFICATION_FILE}" <<'PY'
import re
import sys
from pathlib import Path

raw_exit = int(Path(sys.argv[1]).read_text().strip())
summary = Path(sys.argv[2]).read_text()
out = Path(sys.argv[3])

def field(name: str) -> str:
    match = re.search(rf"^{re.escape(name)}=(.*)$", summary, re.M)
    return match.group(1).strip() if match else ""

eligible = (
    raw_exit == 0
    and field("JSON_PARSE_ERROR") == "NONE"
    and field("COVERAGE_GOALS") == "8"
    and field("SATISFIED_GOALS") == "8"
    and field("FAILED_GOALS") == "0"
    and field("OTHER_GOALS") == "0"
)

classification = (
    "COVERAGE_PASS_PENDING_INDEPENDENT_REVIEW"
    if eligible
    else "COVERAGE_NOT_PASSED_OR_NOT_YET_CLASSIFIABLE"
)

out.write_text(
    "\n".join(
        [
            f"WRAPPER_CLASSIFICATION={classification}",
            f"RAW_CBMC_EXIT_CODE={raw_exit}",
            "EXPECTED_COVERAGE_GOALS=8",
            "THIS_EVIDENCE_ESTABLISHES_NONVACUITY_ONLY=YES",
            "THIS_EVIDENCE_DOES_NOT_ESTABLISH_NOVELTY=YES",
            "INDEPENDENT_RESULT_REVIEW_REQUIRED=YES",
        ]
    )
    + "\n",
    encoding="utf-8",
)
PY

if grep -Fxq \
  "WRAPPER_CLASSIFICATION=COVERAGE_PASS_PENDING_INDEPENDENT_REVIEW" \
  "${CLASSIFICATION_FILE}"
then
  FINAL_RC=0
elif test "${CBMC_RC}" -ne 0
then
  FINAL_RC="${CBMC_RC}"
else
  FINAL_RC=10
fi

STEP="SUB-00I coverage execution complete"
exit "${FINAL_RC}"
