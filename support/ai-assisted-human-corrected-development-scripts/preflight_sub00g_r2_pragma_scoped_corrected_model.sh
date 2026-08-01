#!/usr/bin/env bash
set -euo pipefail

BASE="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
REPO="/home/girish/THESIS-2026/mlkem-native"
SRC="${BASE}/source"
FREEZE="${BASE}/sub00f_mode_a_execution_freeze_v1"

FROZEN_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

FROZEN_HARNESS="${FREEZE}/harnesses/sub_t1_semantic_harness.c"
FROZEN_HARNESS_SHA256="42c09c2f004d567d8b886058bd2304d960a219d36f0f6605b015966db3bc5682"

ZEROIZE_ADAPTER="${FREEZE}/adapter/sub00e_r1_fail_closed_zeroize.h"
ZEROIZE_ADAPTER_SHA256="45d33b9ee3fe3613f23906de520bf9d5ce245a18b537c32787201912dec4e926"

FREEZE_MANIFEST="${FREEZE}/SUB00F_MODE_A_FINAL_ARTIFACT_MANIFEST.sha256"
FREEZE_MANIFEST_SHA256="51221155a2be5b0bcc4facf04233026bc7d516b525c35b6465e0d6aa2cd8cbba"

RUN1_ARCHIVE="${BASE}/SUB00G_T1_MODE_A_MLKEM768_RUN1.tar.gz"
RUN1_ARCHIVE_SHA256="b2967bdac006e81f0e2b7064fa4e60ee164c27d88d6e7443c801710c699e723d"

CRASH_ARCHIVE="${BASE}/SUB00G_R1_PREPROOF_VALIDATOR_CRASH_EVIDENCE.tar.gz"
CRASH_ARCHIVE_SHA256="39af6a2a697be87b3b1d203092774d55d657b0290893c4e4cba17ccfa1367021"

REPO_POLY_SUB_HARNESS_SHA256="12d6a569b8a0bc6a4fc9340f1378f28e11c94beb43730b291161d6a24f8f67d1"
REPO_POLY_SUB_MAKEFILE_SHA256="d576e9ca8f1c952e79ae0b21d93b768a9d0d14b38584e76e953a800253afece8"

OUT="${BASE}/SUB00G_R2_T1_PRAGMA_SCOPED_PREFLIGHT_MLKEM768"
BUILD="${OUT}/build"
AUDIT="${OUT}/audit"

MODEL="${BUILD}/sub_t1_pragma_scoped_mlkem768.goto"
REACHABLE_MODEL="${BUILD}/sub_t1_pragma_scoped_mlkem768_reachable_only.goto"
PRAGMA_ADAPTER="${BUILD}/sub00g_r2_verify_pragma_scope.h"
OPTBLOCKER_ADAPTER="${BUILD}/sub00g_r2_optblocker_zero.c"
PREPROCESSED_POLY="${BUILD}/poly_pragma_scoped.i"

PACKAGE="${BASE}/SUB00G_R2_T1_PRAGMA_SCOPED_PREFLIGHT_MLKEM768.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

STATUS_FILE="${OUT}/PREFLIGHT_STATUS.txt"
MANIFEST="${OUT}/PREFLIGHT_ARTIFACT_MANIFEST.sha256"
STEP="initialization"
FINALIZED=0

NAMESPACE="mlk_sub00g_r2"
BLOCKER_SYMBOL="${NAMESPACE}_ct_opt_blocker_u64"

EXPECTED_LOOPS=(
  "main.0"
  "main.1"
  "main.2"
  "main.3"
  "mlk_barrett_reduce.0"
  "${NAMESPACE}_poly_sub.0"
  "mlk_poly_reduce_c.0"
  "mlk_poly_reduce_c.1"
  "mlk_scalar_signed_to_unsigned_q.0"
  "mlk_scalar_signed_to_unsigned_q.1"
)

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

finalize()
{
  local rc="$1"

  if test "${FINALIZED}" -eq 1
  then
    return
  fi
  FINALIZED=1

  if test -d "${OUT}"
  then
    {
      echo "PREFLIGHT_FINAL_EXIT_CODE=${rc}"
      echo "LAST_STEP=${STEP}"
      if test "${rc}" -eq 0
      then
        echo "PREFLIGHT_VERDICT=PASS"
        echo "THEOREM_EXECUTED=NO"
      else
        echo "PREFLIGHT_VERDICT=FAIL"
        echo "THEOREM_EXECUTED=NO"
      fi
    } >"${STATUS_FILE}"

    (
      cd "${OUT}"

      find . -type f \
        ! -name "$(basename "${MANIFEST}")" \
        -print0 |
        LC_ALL=C sort -z |
        xargs -0 -r sha256sum
    ) >"${MANIFEST}"

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
    if test "${rc}" -eq 0
    then
      echo "SUB-00G-R2 PREFLIGHT PASSED"
    else
      echo "SUB-00G-R2 PREFLIGHT FAILED SAFELY"
    fi
    echo "============================================================"
    echo "Last step: ${STEP}"
    echo "No CBMC theorem command was executed."
    echo
    echo "Upload:"
    echo "1. ${PACKAGE}"
    echo "2. ${PACKAGE_HASH}"
    echo
    cat "${PACKAGE_HASH}"
  fi
}

on_exit()
{
  local rc="$?"
  trap - EXIT
  finalize "${rc}"
  exit "${rc}"
}
trap on_exit EXIT

for tool in git cc goto-cc goto-instrument cbmc sha256sum tar gzip strings
do
  command -v "${tool}" >/dev/null 2>&1 ||
    fail "required tool unavailable: ${tool}"
done

test -d "${BASE}" || fail "campaign directory missing: ${BASE}"
test -d "${REPO}/.git" || fail "repository missing: ${REPO}"
test -d "${SRC}/mlkem/src" || fail "clean-room source snapshot missing: ${SRC}"
test -d "${FREEZE}" || fail "SUB-00F freeze directory missing: ${FREEZE}"

test ! -e "${OUT}" || fail "versioned output already exists: ${OUT}"
test ! -e "${PACKAGE}" || fail "versioned package already exists: ${PACKAGE}"
test ! -e "${PACKAGE_HASH}" || fail "versioned package sidecar already exists"

mkdir -p "${BUILD}" "${AUDIT}"

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

STEP="verify parent evidence hashes"
verify_hash "${FROZEN_HARNESS_SHA256}" "${FROZEN_HARNESS}"
verify_hash "${ZEROIZE_ADAPTER_SHA256}" "${ZEROIZE_ADAPTER}"
verify_hash "${FREEZE_MANIFEST_SHA256}" "${FREEZE_MANIFEST}"
verify_hash "${RUN1_ARCHIVE_SHA256}" "${RUN1_ARCHIVE}"
verify_hash "${CRASH_ARCHIVE_SHA256}" "${CRASH_ARCHIVE}"

(
  cd "${FREEZE}"
  sha256sum --check "$(basename "${FREEZE_MANIFEST}")"
) >"${AUDIT}/sub00f_manifest_check.txt" 2>&1

STEP="freeze repository poly_sub comparison"
git -C "${REPO}" show \
  "${FROZEN_COMMIT}:proofs/cbmc/poly_sub/poly_sub_harness.c" \
  >"${AUDIT}/repository_poly_sub_harness.c"

git -C "${REPO}" show \
  "${FROZEN_COMMIT}:proofs/cbmc/poly_sub/Makefile" \
  >"${AUDIT}/repository_poly_sub_Makefile"

verify_hash \
  "${REPO_POLY_SUB_HARNESS_SHA256}" \
  "${AUDIT}/repository_poly_sub_harness.c"

verify_hash \
  "${REPO_POLY_SUB_MAKEFILE_SHA256}" \
  "${AUDIT}/repository_poly_sub_Makefile"

cat >"${AUDIT}/REPOSITORY_COMPARISON_NOTE.md" <<'EOF'
# Repository-level comparison note

The tracked dedicated repository harness at the frozen commit contains one
call to `mlk_poly_sub(r, b)`. Its Makefile checks the existing
`mlk_poly_sub` function contract and applies loop contracts.

It does not call `mlk_poly_reduce`, does not compute an independent modular
oracle, and does not state the relational equation
`N(A-B) = N(N(A)-N(B))`.

This supports only a repository-level distinction. It is not, by itself, a
worldwide novelty finding. Public-code and literature equivalence review
remain separate.
EOF

STEP="write pragma-scoping adapter"
cat >"${PRAGMA_ADAPTER}" <<'EOF'
#ifndef SUB00G_R2_VERIFY_PRAGMA_SCOPE_H
#define SUB00G_R2_VERIFY_PRAGMA_SCOPE_H

/*
 * Purpose:
 *   Activate only verify.h's CBMC-specific conversion-check pragma while
 *   keeping mlkem-native function contracts and loop contracts disabled.
 *
 * Mechanism:
 *   1. Include common.h and cbmc.h while CBMC is undefined. This selects the
 *      normal no-contract macro definitions and fixes them behind cbmc.h's
 *      include guard.
 *   2. Define CBMC only while verify.h is parsed. At the frozen source commit,
 *      verify.h uses this macro for the push/disable/pop conversion pragma
 *      around mlk_cast_uint16_to_int16.
 *   3. Undefine CBMC before the production translation unit is parsed.
 *
 * This adapter does not replace a function body and does not add a theorem
 * assumption.
 */

#ifdef CBMC
#error "SUB-00G-R2 requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00G_R2_VERIFY_PRAGMA_SCOPE_H */
EOF

STEP="write zero blocker definition"
cat >"${OPTBLOCKER_ADAPTER}" <<'EOF'
/*
 * SUB-00G-R2 environment definition.
 *
 * verify.h documents the portable value barrier as XOR with a volatile
 * global set to zero. Run-1 omitted the definition and therefore left the
 * global unconstrained in the GOTO model.
 *
 * This translation unit supplies the missing zero-valued environment object.
 * It does not modify production poly.c or the frozen theorem harness.
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

STEP="preprocess poly.c for adapter audit"
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

STEP="construct pragma-scoped GOTO model"
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

test -s "${MODEL}" || fail "GOTO model was not produced"
sha256sum "${MODEL}" >"${BUILD}/model.sha256"
stat "${MODEL}" >"${BUILD}/model.stat.txt"

STEP="reject globally expanded contract symbols"
strings "${MODEL}" |
  LC_ALL=C sort -u |
  grep 'contract::' >"${BUILD}/contract_symbols.txt" || true

if test -s "${BUILD}/contract_symbols.txt"
then
  fail "contract symbols remain in the supposedly body-level model"
fi

STEP="validate original corrected GOTO model"
run_capture \
  "${BUILD}/validate_original_model.txt" \
  goto-instrument --validate-goto-binary "${MODEL}"

STEP="inspect original model"
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

STEP="construct reachable-only inspection model"
run_capture \
  "${BUILD}/drop_unused_functions.txt" \
  goto-instrument --drop-unused-functions "${MODEL}" "${REACHABLE_MODEL}"

test -s "${REACHABLE_MODEL}" ||
  fail "reachable-only model was not produced"

sha256sum "${REACHABLE_MODEL}" >"${BUILD}/reachable_model.sha256"

STEP="validate reachable-only model"
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
  fail "reachable loop set differs from the preregistered structure"
fi

UNWINDSET="main.0:257,main.1:257,main.2:257,main.3:257,mlk_barrett_reduce.0:2,${NAMESPACE}_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2"

STEP="generate proof-property inventory without proving"
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
  --unwinding-assertions
  --unwindset "${UNWINDSET}"
  --show-properties
)

write_command "${BUILD}/show_cbmc_properties_command.txt" "${PROPERTY_COMMAND[@]}"
run_capture "${BUILD}/show_cbmc_properties.txt" "${PROPERTY_COMMAND[@]}"

for required in \
  "SUB_T1_SEMANTIC: output must be non-negative" \
  "SUB_T1_SEMANTIC: output must be below FIPS_Q" \
  "SUB_T1_SEMANTIC: output must equal independent canonical oracle" \
  "SUB_T1_FRAME: subtraction must not modify LB" \
  "SUB_T1_FRAME: reduction must not modify LB"
do
  grep -Fq "${required}" "${BUILD}/show_cbmc_properties.txt" ||
    fail "required frozen property missing from inventory: ${required}"
done

if grep -Fq "mlk_cast_uint16_to_int16.overflow.1" \
    "${BUILD}/show_cbmc_properties.txt"
then
  fail "the intentionally suppressed implementation-defined conversion property is still active"
fi

if grep -Fq "mlk_sub00g_r2_shake256x4::out0" \
    "${BUILD}/show_cbmc_properties.txt"
then
  fail "unrelated SHAKE contract symbol leaked into the property inventory"
fi

STEP="write preflight manifest"
cat >"${OUT}/SUB00G_R2_PREFLIGHT_MANIFEST.md" <<EOF
# SUB-00G-R2 Pragma-Scoped Corrected-Model Preflight

## Scope

This stage performs model construction and inspection only.

- CBMC theorem execution: **not performed**
- Coverage execution: **not performed**
- Frozen SUB-T1 harness modified: **no**
- Production poly.c modified: **no**
- Function-contract abstraction used: **no**
- Loop contracts applied: **no**

## Corrections tested

1. The namespaced portable value-barrier blocker is defined as volatile
   64-bit zero in a separate environment translation unit.
2. CBMC remains globally undefined.
3. cbmc.h is first included with CBMC undefined, keeping contracts disabled.
4. CBMC is then defined only while verify.h is parsed, activating the
   repository's narrowly scoped conversion-check pragma.
5. CBMC is undefined before production poly.c and the theorem harness are
   parsed.

## Identity

- Frozen commit:
  \`${FROZEN_COMMIT}\`
- Namespace:
  \`${NAMESPACE}\`
- Frozen harness SHA-256:
  \`${FROZEN_HARNESS_SHA256}\`
- Corrected model SHA-256:
  \`$(hash_of "${MODEL}")\`
- Reachable-only inspection model SHA-256:
  \`$(hash_of "${REACHABLE_MODEL}")\`
- Pragma adapter SHA-256:
  \`$(hash_of "${PRAGMA_ADAPTER}")\`
- Zero-blocker adapter SHA-256:
  \`$(hash_of "${OPTBLOCKER_ADAPTER}")\`
- Exact future unwindset:
  \`${UNWINDSET}\`

## Repository comparison already frozen

The dedicated repository poly_sub harness at the frozen commit calls only
\`mlk_poly_sub(r, b)\` and relies on the existing function contract. It does
not call \`mlk_poly_reduce\`, compute an independent modular oracle, or state
the SUB-T2 relational equation.

This is a repository-level distinction only. It is not a worldwide novelty
claim.

## Next gate

No theorem runner is authorized until this preflight package is independently
reviewed.
EOF

STEP="preflight complete"
exit 0
