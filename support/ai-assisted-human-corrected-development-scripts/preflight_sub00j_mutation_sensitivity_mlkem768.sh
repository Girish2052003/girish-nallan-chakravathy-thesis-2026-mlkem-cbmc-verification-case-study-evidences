#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# SUB-00J: mutation-sensitivity preflight
#
# This stage creates and validates three isolated mutant models:
#
#   M1_ADD_INSTEAD_OF_SUB
#       Production poly_sub assignment changes '-' to '+'.
#
#   M2_SKIP_COEFFICIENT_255
#       Production poly_sub loop executes only for coefficients 0..254.
#
#   M3_ORACLE_PLUS_ONE
#       Production source is unchanged; the independent harness oracle is
#       deliberately shifted by one modulo q.
#
# This is PRE-FLIGHT ONLY:
#   - no SAT/SMT solving;
#   - no theorem result;
#   - no mutation is applied to the repository or frozen artefacts.
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

FROZEN_HARNESS="${FREEZE}/harnesses/sub_t1_semantic_harness.c"
FROZEN_HARNESS_SHA256="42c09c2f004d567d8b886058bd2304d960a219d36f0f6605b015966db3bc5682"

ZEROIZE_ADAPTER="${FREEZE}/adapter/sub00e_r1_fail_closed_zeroize.h"
ZEROIZE_ADAPTER_SHA256="45d33b9ee3fe3613f23906de520bf9d5ce245a18b537c32787201912dec4e926"

PRISTINE_POLY="${SRC}/mlkem/src/poly.c"

OUT="${BASE}/SUB00J_MUTATION_PREFLIGHT_PRAGMA_SCOPED_MLKEM768"
MUTANTS="${OUT}/mutants"
BUILD="${OUT}/build"
FUTURE="${OUT}/future_expected_failure_commands"

PRAGMA_ADAPTER="${OUT}/adapters/sub00j_verify_pragma_scope.h"
OPTBLOCKER_ADAPTER="${OUT}/adapters/sub00j_optblocker_zero.c"

M1_SOURCE="${MUTANTS}/M1_ADD_INSTEAD_OF_SUB/poly.c"
M1_HARNESS="${MUTANTS}/M1_ADD_INSTEAD_OF_SUB/sub_t1_semantic_harness.c"

M2_SOURCE="${MUTANTS}/M2_SKIP_COEFFICIENT_255/poly.c"
M2_HARNESS="${MUTANTS}/M2_SKIP_COEFFICIENT_255/sub_t1_semantic_harness.c"

M3_SOURCE="${MUTANTS}/M3_ORACLE_PLUS_ONE/poly.c"
M3_HARNESS="${MUTANTS}/M3_ORACLE_PLUS_ONE/sub_t1_semantic_harness.c"

PACKAGE="${BASE}/SUB00J_MUTATION_PREFLIGHT_PRAGMA_SCOPED_MLKEM768.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"
ARTIFACT_MANIFEST="${OUT}/SUB00J_ARTIFACT_MANIFEST.sha256"
STATUS_FILE="${OUT}/PREFLIGHT_STATUS.txt"

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
      echo "PREFLIGHT_FINAL_EXIT_CODE=${final_rc}"
      echo "LAST_STEP=${STEP}"
      if test "${final_rc}" -eq 0
      then
        echo "PREFLIGHT_VERDICT=PASS"
      else
        echo "PREFLIGHT_VERDICT=FAIL"
      fi
      echo "THEOREM_OR_MUTANT_SOLVER_EXECUTED=NO"
      echo "MUTANT_MODELS_EXPECTED=3"
    } >"${STATUS_FILE}"

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
    if test "${final_rc}" -eq 0
    then
      echo "SUB-00J MUTATION PREFLIGHT PASSED"
    else
      echo "SUB-00J MUTATION PREFLIGHT FAILED SAFELY"
    fi
    echo "============================================================"
    echo "Last step: ${STEP}"
    echo "No mutant solver run was executed."
    echo
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
  git cc goto-cc goto-instrument cbmc tar gzip sha256sum \
  python3 readlink strings diff
do
  command -v "${tool}" >/dev/null 2>&1 ||
    fail "required tool unavailable: ${tool}"
done

test -f "${SCRIPT_PATH}" || fail "unable to resolve executing script"
test -d "${BASE}" || fail "campaign directory missing: ${BASE}"
test -d "${REPO}/.git" || fail "repository missing: ${REPO}"
test -d "${SRC}/mlkem/src" || fail "clean-room source snapshot missing"
test -d "${FREEZE}" || fail "SUB-00F freeze directory missing"

test ! -e "${OUT}" || fail "versioned output already exists: ${OUT}"
test ! -e "${PACKAGE}" || fail "versioned package already exists: ${PACKAGE}"
test ! -e "${PACKAGE_HASH}" || fail "versioned package sidecar already exists"

mkdir -p \
  "${MUTANTS}/M1_ADD_INSTEAD_OF_SUB" \
  "${MUTANTS}/M2_SKIP_COEFFICIENT_255" \
  "${MUTANTS}/M3_ORACLE_PLUS_ONE" \
  "${OUT}/adapters" \
  "${BUILD}" \
  "${FUTURE}"

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

STEP="verify frozen identity"
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
verify_hash "${FROZEN_HARNESS_SHA256}" "${FROZEN_HARNESS}"
verify_hash "${ZEROIZE_ADAPTER_SHA256}" "${ZEROIZE_ADAPTER}"

STEP="verify source and freeze manifests"
sha256sum --check "${SOURCE_MANIFEST}" \
  >"${OUT}/source_manifest_check.txt" 2>&1

(
  cd "${FREEZE}"
  sha256sum --check "$(basename "${FREEZE_MANIFEST}")"
) >"${OUT}/sub00f_manifest_check.txt" 2>&1

STEP="write corrected environment adapters"
cat >"${PRAGMA_ADAPTER}" <<'EOF'
#ifndef SUB00J_VERIFY_PRAGMA_SCOPE_H
#define SUB00J_VERIFY_PRAGMA_SCOPE_H

/*
 * Activate only verify.h's CBMC-specific conversion-check pragma while
 * keeping mlkem-native function contracts and loop contracts disabled.
 */

#ifdef CBMC
#error "SUB-00J requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00J_VERIFY_PRAGMA_SCOPE_H */
EOF

cat >"${OPTBLOCKER_ADAPTER}" <<'EOF'
/*
 * SUB-00J environment definition.
 *
 * The portable value barrier reads a namespaced volatile uint64_t documented
 * as zero. This definition preserves that production environment fact.
 */

#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
EOF

STEP="create isolated mutants with exact single edits"
python3 - \
  "${PRISTINE_POLY}" \
  "${FROZEN_HARNESS}" \
  "${M1_SOURCE}" \
  "${M1_HARNESS}" \
  "${M2_SOURCE}" \
  "${M2_HARNESS}" \
  "${M3_SOURCE}" \
  "${M3_HARNESS}" \
  "${OUT}/MUTATION_AUDIT.json" <<'PY'
import difflib
import json
import sys
from pathlib import Path

(
    pristine_poly_path,
    pristine_harness_path,
    m1_source_path,
    m1_harness_path,
    m2_source_path,
    m2_harness_path,
    m3_source_path,
    m3_harness_path,
    audit_path,
) = map(Path, sys.argv[1:])

poly = pristine_poly_path.read_text(encoding="utf-8")
harness = pristine_harness_path.read_text(encoding="utf-8")

signature = "void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)"

def function_region(text: str, signature_text: str) -> tuple[int, int]:
    start = text.find(signature_text)
    if start < 0:
        raise RuntimeError("mlk_poly_sub signature not found")

    opening = text.find("{", start)
    if opening < 0:
        raise RuntimeError("mlk_poly_sub opening brace not found")

    depth = 0
    for index in range(opening, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return start, index + 1

    raise RuntimeError("mlk_poly_sub closing brace not found")

region_start, region_end = function_region(poly, signature)
region = poly[region_start:region_end]

m1_old = "r->coeffs[i] = (int16_t)(r->coeffs[i] - b->coeffs[i]);"
m1_new = "r->coeffs[i] = (int16_t)(r->coeffs[i] + b->coeffs[i]);"

if region.count(m1_old) != 1:
    raise RuntimeError(
        f"M1 mutation point count is {region.count(m1_old)}, expected 1"
    )

m1_region = region.replace(m1_old, m1_new, 1)
m1_poly = poly[:region_start] + m1_region + poly[region_end:]

m2_old = "for (i = 0; i < MLKEM_N; i++)"
m2_new = "for (i = 0; i + 1u < MLKEM_N; i++)"

if region.count(m2_old) != 1:
    raise RuntimeError(
        f"M2 mutation point count is {region.count(m2_old)}, expected 1"
    )

m2_region = region.replace(m2_old, m2_new, 1)
m2_poly = poly[:region_start] + m2_region + poly[region_end:]

m3_old = "expected = shifted % (uint32_t)FIPS_Q;"
m3_new = "expected = (shifted + 1u) % (uint32_t)FIPS_Q;"

if harness.count(m3_old) != 1:
    raise RuntimeError(
        f"M3 mutation point count is {harness.count(m3_old)}, expected 1"
    )

m3_harness = harness.replace(m3_old, m3_new, 1)

Path(m1_source_path).write_text(m1_poly, encoding="utf-8")
Path(m1_harness_path).write_text(harness, encoding="utf-8")

Path(m2_source_path).write_text(m2_poly, encoding="utf-8")
Path(m2_harness_path).write_text(harness, encoding="utf-8")

Path(m3_source_path).write_text(poly, encoding="utf-8")
Path(m3_harness_path).write_text(m3_harness, encoding="utf-8")

def changed_lines(before: str, after: str):
    return list(
        difflib.unified_diff(
            before.splitlines(),
            after.splitlines(),
            fromfile="before",
            tofile="after",
            lineterm="",
        )
    )

audit = {
    "M1_ADD_INSTEAD_OF_SUB": {
        "mutated_file": "poly.c",
        "old": m1_old,
        "new": m1_new,
        "old_occurrences_in_target_function": region.count(m1_old),
        "new_occurrences_in_mutant_function": m1_region.count(m1_new),
        "harness_changed": False,
        "diff": changed_lines(poly, m1_poly),
    },
    "M2_SKIP_COEFFICIENT_255": {
        "mutated_file": "poly.c",
        "old": m2_old,
        "new": m2_new,
        "old_occurrences_in_target_function": region.count(m2_old),
        "new_occurrences_in_mutant_function": m2_region.count(m2_new),
        "harness_changed": False,
        "diff": changed_lines(poly, m2_poly),
    },
    "M3_ORACLE_PLUS_ONE": {
        "mutated_file": "sub_t1_semantic_harness.c",
        "old": m3_old,
        "new": m3_new,
        "old_occurrences_in_frozen_harness": harness.count(m3_old),
        "new_occurrences_in_mutant_harness": m3_harness.count(m3_new),
        "production_source_changed": False,
        "diff": changed_lines(harness, m3_harness),
    },
}

Path(audit_path).write_text(
    json.dumps(audit, indent=2) + "\n",
    encoding="utf-8",
)
PY

STEP="verify mutation isolation and diffs"
verify_hash "${FROZEN_HARNESS_SHA256}" "${M1_HARNESS}"
verify_hash "${FROZEN_HARNESS_SHA256}" "${M2_HARNESS}"

PRISTINE_POLY_SHA256="$(hash_of "${PRISTINE_POLY}")"
verify_hash "${PRISTINE_POLY_SHA256}" "${M3_SOURCE}"

set +e
diff -u "${PRISTINE_POLY}" "${M1_SOURCE}" \
  >"${MUTANTS}/M1_ADD_INSTEAD_OF_SUB/source.diff"
M1_DIFF_RC="$?"

diff -u "${PRISTINE_POLY}" "${M2_SOURCE}" \
  >"${MUTANTS}/M2_SKIP_COEFFICIENT_255/source.diff"
M2_DIFF_RC="$?"

diff -u "${FROZEN_HARNESS}" "${M3_HARNESS}" \
  >"${MUTANTS}/M3_ORACLE_PLUS_ONE/harness.diff"
M3_DIFF_RC="$?"
set -e

test "${M1_DIFF_RC}" -eq 1 || fail "M1 diff did not report one changed file"
test "${M2_DIFF_RC}" -eq 1 || fail "M2 diff did not report one changed file"
test "${M3_DIFF_RC}" -eq 1 || fail "M3 diff did not report one changed file"

test "$(grep -Ec '^[+-][^+-]' "${MUTANTS}/M1_ADD_INSTEAD_OF_SUB/source.diff")" -eq 2 ||
  fail "M1 is not an exact one-line replacement"

test "$(grep -Ec '^[+-][^+-]' "${MUTANTS}/M2_SKIP_COEFFICIENT_255/source.diff")" -eq 2 ||
  fail "M2 is not an exact one-line replacement"

test "$(grep -Ec '^[+-][^+-]' "${MUTANTS}/M3_ORACLE_PLUS_ONE/harness.diff")" -eq 2 ||
  fail "M3 is not an exact one-line replacement"

sha256sum \
  "${PRISTINE_POLY}" \
  "${FROZEN_HARNESS}" \
  "${M1_SOURCE}" \
  "${M1_HARNESS}" \
  "${M2_SOURCE}" \
  "${M2_HARNESS}" \
  "${M3_SOURCE}" \
  "${M3_HARNESS}" \
  "${PRAGMA_ADAPTER}" \
  "${OPTBLOCKER_ADAPTER}" \
  >"${OUT}/mutation_input_hashes.sha256"

COMMON_INCLUDES=(
  -I"${SRC}/mlkem"
  -I"${SRC}/mlkem/src"
)

FORCED_INCLUDES=(
  -include "${ZEROIZE_ADAPTER}"
  -include "${PRAGMA_ADAPTER}"
)

build_and_inspect_mutant()
{
  local mutant_id="$1"
  local namespace="$2"
  local harness="$3"
  local source_file="$4"
  local mutant_dir="${BUILD}/${mutant_id}"
  local model="${mutant_dir}/${mutant_id}.goto"
  local reachable_model="${mutant_dir}/${mutant_id}_reachable_only.goto"
  local blocker_symbol="${namespace}_ct_opt_blocker_u64"
  local unwindset
  local property_command
  local future_command

  mkdir -p "${mutant_dir}"

  local common_defines=(
    -DMLK_CONFIG_PARAMETER_SET=768
    -DMLK_CONFIG_NAMESPACE_PREFIX="${namespace}"
    -DMLK_CONFIG_NO_ASM=1
    -DMLK_CONFIG_CUSTOM_ZEROIZE=1
  )

  STEP="preprocess ${mutant_id}"
  local preprocessed="${mutant_dir}/poly.i"
  local preprocess_command=(
    cc
    -std=c90
    "${common_defines[@]}"
    "${FORCED_INCLUDES[@]}"
    "${COMMON_INCLUDES[@]}"
    -E
    -P
    "${source_file}"
    -o "${preprocessed}"
  )

  write_command "${mutant_dir}/preprocess_command.txt" \
    "${preprocess_command[@]}"

  run_capture "${mutant_dir}/preprocess_output.txt" \
    "${preprocess_command[@]}"

  test -s "${preprocessed}" ||
    fail "${mutant_id}: preprocessing did not produce output"

  grep -F '#pragma CPROVER check disable "conversion"' \
    "${preprocessed}" \
    >"${mutant_dir}/conversion_disable_pragma_match.txt" ||
    fail "${mutant_id}: scoped conversion pragma missing"

  grep -F '#pragma CPROVER check pop' \
    "${preprocessed}" \
    >"${mutant_dir}/conversion_pop_pragma_match.txt" ||
    fail "${mutant_id}: scoped conversion pragma pop missing"

  if grep -Eq '__CPROVER_(requires|ensures|assigns|frees|loop_invariant|decreases)' \
      "${preprocessed}"
  then
    grep -En '__CPROVER_(requires|ensures|assigns|frees|loop_invariant|decreases)' \
      "${preprocessed}" \
      >"${mutant_dir}/unexpected_contract_expansion.txt" || true
    fail "${mutant_id}: function or loop contracts unexpectedly expanded"
  else
    echo "No expanded function/loop contract primitives found." \
      >"${mutant_dir}/unexpected_contract_expansion.txt"
  fi

  STEP="construct ${mutant_id} model"
  local build_command=(
    goto-cc
    -std=c90
    "${common_defines[@]}"
    "${FORCED_INCLUDES[@]}"
    "${COMMON_INCLUDES[@]}"
    "${harness}"
    "${source_file}"
    "${OPTBLOCKER_ADAPTER}"
    -o "${model}"
  )

  write_command "${mutant_dir}/goto_build_command.txt" \
    "${build_command[@]}"

  run_capture "${mutant_dir}/goto_build_output.txt" \
    "${build_command[@]}"

  test -s "${model}" || fail "${mutant_id}: GOTO model was not produced"
  sha256sum "${model}" >"${mutant_dir}/model.sha256"
  stat "${model}" >"${mutant_dir}/model.stat.txt"

  STEP="reject contract symbols in ${mutant_id}"
  strings "${model}" |
    LC_ALL=C sort -u |
    grep 'contract::' >"${mutant_dir}/contract_symbols.txt" || true

  test ! -s "${mutant_dir}/contract_symbols.txt" ||
    fail "${mutant_id}: contract symbols remain in model"

  STEP="validate and inspect ${mutant_id}"
  run_capture \
    "${mutant_dir}/validate_original_model.txt" \
    goto-instrument --validate-goto-binary "${model}"

  run_capture \
    "${mutant_dir}/show_symbol_table.txt" \
    goto-instrument --show-symbol-table "${model}"

  run_capture \
    "${mutant_dir}/show_goto_functions.txt" \
    goto-instrument --show-goto-functions "${model}"

  run_capture \
    "${mutant_dir}/reachable_call_graph.txt" \
    goto-instrument --reachable-call-graph "${model}"

  run_capture \
    "${mutant_dir}/undefined_functions.txt" \
    goto-instrument --list-undefined-functions "${model}"

  grep -q -- "${blocker_symbol}" "${mutant_dir}/show_symbol_table.txt" ||
    fail "${mutant_id}: blocker symbol missing"

  grep -Eq "ASSIGN.*${blocker_symbol}.*(=|:=).*0|${blocker_symbol}.*(=|:=).*0" \
    "${mutant_dir}/show_goto_functions.txt" \
    >"${mutant_dir}/blocker_zero_initialization_match.txt" ||
    fail "${mutant_id}: zero blocker initialization missing"

  grep -q -- "${namespace}_poly_sub" "${mutant_dir}/reachable_call_graph.txt" ||
    fail "${mutant_id}: poly_sub is not reachable"

  grep -q -- "${namespace}_poly_reduce" "${mutant_dir}/reachable_call_graph.txt" ||
    fail "${mutant_id}: poly_reduce is not reachable"

  if grep -Eq '(^|[^[:alnum:]_])mlk_zeroize([^[:alnum:]_]|$)' \
      "${mutant_dir}/reachable_call_graph.txt"
  then
    fail "${mutant_id}: zeroize adapter is unexpectedly reachable"
  fi

  STEP="construct reachable-only ${mutant_id} model"
  run_capture \
    "${mutant_dir}/drop_unused_functions.txt" \
    goto-instrument --drop-unused-functions "${model}" "${reachable_model}"

  test -s "${reachable_model}" ||
    fail "${mutant_id}: reachable-only model was not produced"

  sha256sum "${reachable_model}" \
    >"${mutant_dir}/reachable_model.sha256"

  run_capture \
    "${mutant_dir}/validate_reachable_model.txt" \
    goto-instrument --validate-goto-binary "${reachable_model}"

  STEP="verify ${mutant_id} reachable loops"
  run_capture \
    "${mutant_dir}/reachable_loops.txt" \
    goto-instrument --show-loops "${reachable_model}"

  grep '^Loop ' "${mutant_dir}/reachable_loops.txt" |
    sed -E 's/^Loop ([^:]+):$/\1/' |
    LC_ALL=C sort >"${mutant_dir}/actual_loop_ids.txt"

  {
    printf '%s\n' \
      "main.0" \
      "main.1" \
      "main.2" \
      "main.3" \
      "mlk_barrett_reduce.0" \
      "${namespace}_poly_sub.0" \
      "mlk_poly_reduce_c.0" \
      "mlk_poly_reduce_c.1" \
      "mlk_scalar_signed_to_unsigned_q.0" \
      "mlk_scalar_signed_to_unsigned_q.1"
  } | LC_ALL=C sort >"${mutant_dir}/expected_loop_ids.txt"

  if ! diff -u \
      "${mutant_dir}/expected_loop_ids.txt" \
      "${mutant_dir}/actual_loop_ids.txt" \
      >"${mutant_dir}/loop_set_diff.txt"
  then
    cat "${mutant_dir}/loop_set_diff.txt" >&2
    fail "${mutant_id}: reachable loop set differs from preregistration"
  fi

  unwindset="main.0:257,main.1:257,main.2:257,main.3:257,mlk_barrett_reduce.0:2,${namespace}_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2"

  STEP="inventory ${mutant_id} properties without solving"
  property_command=(
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

  write_command "${mutant_dir}/property_inventory_command.txt" \
    "${property_command[@]}"

  run_capture \
    "${mutant_dir}/property_inventory.txt" \
    "${property_command[@]}"

  for required in \
    "SUB_T1_SEMANTIC: output must be non-negative" \
    "SUB_T1_SEMANTIC: output must be below FIPS_Q" \
    "SUB_T1_SEMANTIC: output must equal independent canonical oracle" \
    "SUB_T1_FRAME: subtraction must not modify LB" \
    "SUB_T1_FRAME: reduction must not modify LB"
  do
    grep -Fq "${required}" "${mutant_dir}/property_inventory.txt" ||
      fail "${mutant_id}: frozen property missing: ${required}"
  done

  if grep -Fq "mlk_cast_uint16_to_int16.overflow.1" \
      "${mutant_dir}/property_inventory.txt"
  then
    fail "${mutant_id}: intentional conversion property is active"
  fi

  if grep -Eq 'contract::|shake256x4' \
      "${mutant_dir}/property_inventory.txt"
  then
    fail "${mutant_id}: unrelated contract material leaked"
  fi

  future_command=(
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

  write_command \
    "${FUTURE}/${mutant_id}_EXPECTED_FAILURE_COMMAND.txt" \
    "${future_command[@]}"

  cat >"${mutant_dir}/MODEL_RECORD.txt" <<EOF
MUTANT_ID=${mutant_id}
NAMESPACE=${namespace}
MODEL_SHA256=$(hash_of "${model}")
REACHABLE_MODEL_SHA256=$(hash_of "${reachable_model}")
HARNESS_SHA256=$(hash_of "${harness}")
SOURCE_SHA256=$(hash_of "${source_file}")
EXACT_UNWINDSET=${unwindset}
ORIGINAL_MODEL_VALIDATION=PASS
REACHABLE_MODEL_VALIDATION=PASS
PROPERTY_INVENTORY=GENERATED_WITHOUT_SOLVING
EOF
}

STEP="build and inspect M1"
build_and_inspect_mutant \
  "M1_ADD_INSTEAD_OF_SUB" \
  "mlk_sub00j_add" \
  "${M1_HARNESS}" \
  "${M1_SOURCE}"

STEP="build and inspect M2"
build_and_inspect_mutant \
  "M2_SKIP_COEFFICIENT_255" \
  "mlk_sub00j_skip" \
  "${M2_HARNESS}" \
  "${M2_SOURCE}"

STEP="build and inspect M3"
build_and_inspect_mutant \
  "M3_ORACLE_PLUS_ONE" \
  "mlk_sub00j_oracle" \
  "${M3_HARNESS}" \
  "${M3_SOURCE}"

STEP="write scientific mutation protocol"
cat >"${OUT}/SUB00J_MUTATION_PROTOCOL.md" <<'EOF'
# SUB-00J Mutation-Sensitivity Protocol

## Purpose

The successful SUB-T1 result is subjected to mutation testing to determine
whether the frozen assertions and independent oracle are capable of rejecting
plausible faults.

Mutation testing does not prove correctness and does not establish novelty.
It supplies sensitivity evidence complementary to SUB-T1 and SUB-00I.

## Frozen controls

The following remain unchanged:

- frozen repository commit;
- production source snapshot outside isolated mutant copies;
- SUB-T1 assumptions;
- machine-model assertions;
- frame assertions;
- safety flags;
- loop bounds;
- solver configuration planned for the later execution stage.

## Mutants

### M1 — addition instead of subtraction

One production statement is changed:

```c
r->coeffs[i] = (int16_t)(r->coeffs[i] - b->coeffs[i]);
```

to:

```c
r->coeffs[i] = (int16_t)(r->coeffs[i] + b->coeffs[i]);
```

Expected kill criterion: the independent canonical-oracle assertion must be
reported as failing. Additional safety failures may also occur, but they do
not replace the semantic kill criterion.

### M2 — coefficient 255 skipped

The production subtraction loop condition is changed:

```c
i < MLKEM_N
```

to:

```c
i + 1u < MLKEM_N
```

Expected kill criterion: the independent canonical-oracle assertion must be
reported as failing for coefficient 255 on at least one admissible input.

### M3 — oracle shifted by one

Production source remains unchanged. The independent oracle is changed:

```c
expected = shifted % FIPS_Q;
```

to:

```c
expected = (shifted + 1) % FIPS_Q;
```

Expected kill criterion: the equality-to-oracle assertion must be reported as
failing. This checks that the assertion is active and not trivially satisfied.

## Preflight boundary

This package contains only:

- isolated mutated source/harness copies;
- exact diffs and hashes;
- validated GOTO binaries;
- reachable-call and loop inventories;
- property inventories generated with `--show-properties`;
- frozen future expected-failure commands.

No mutant solver command has been executed.

## Acceptance rule for the later execution stage

A mutant is killed only when:

1. the exact preflight model hash is reverified;
2. GOTO validation passes immediately before execution;
3. CBMC returns a failing verification result;
4. the independent canonical-oracle property is specifically listed as
   `FAILURE`;
5. the trace demonstrates an admissible input satisfying the frozen
   representability assumptions.

A crash, timeout, malformed JSON, missing property, or unrelated-only failure
does not count as a killed mutant.
EOF

STEP="reverify pristine campaign inputs after mutant generation"
verify_hash "${PRISTINE_POLY_SHA256}" "${PRISTINE_POLY}"
verify_hash "${FROZEN_HARNESS_SHA256}" "${FROZEN_HARNESS}"
verify_hash "${SOURCE_MANIFEST_SHA256}" "${SOURCE_MANIFEST}"
verify_hash "${FREEZE_MANIFEST_SHA256}" "${FREEZE_MANIFEST}"

STEP="copy executed preflight runner"
cp -a "${SCRIPT_PATH}" "${OUT}/executed_preflight_runner.sh"
sha256sum "${SCRIPT_PATH}" >"${OUT}/executed_preflight_runner.sha256"

STEP="SUB-00J preflight complete"
exit 0
