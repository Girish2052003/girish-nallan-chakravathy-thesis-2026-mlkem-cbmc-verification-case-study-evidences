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

OUT="${BASE}/SUB00G_R1_T1_CORRECTED_ENVIRONMENT_MLKEM768"
AUDIT="${OUT}/post_freeze_novelty_audit"
BUILD="${OUT}/build"
RESULT="${OUT}/result"

MODEL="${BUILD}/sub_t1_corrected_environment_mlkem768.goto"
OPTBLOCKER_ADAPTER="${BUILD}/sub00g_r1_optblocker_zero.c"
REMEDIATION_MANIFEST="${OUT}/SUB00G_R1_REMEDIATION_AND_EXECUTION_MANIFEST.md"
PREPROOF_MANIFEST="${OUT}/SUB00G_R1_PREPROOF_ARTIFACT_MANIFEST.sha256"

RESULT_JSON="${RESULT}/cbmc_result.json"
RESULT_STDERR="${RESULT}/cbmc_stderr.txt"
RESULT_COMMAND="${RESULT}/cbmc_command.txt"
RESULT_EXIT="${RESULT}/cbmc_exit_code.txt"
RESULT_RESOURCE="${RESULT}/resource_usage.txt"
RESULT_SUMMARY="${RESULT}/cbmc_result_summary.txt"
RESULT_MANIFEST="${RESULT}/RESULT_ARTIFACT_MANIFEST.sha256"

PACKAGE="${BASE}/SUB00G_R1_T1_CORRECTED_ENVIRONMENT_MLKEM768.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

NAMESPACE="mlk_sub00g_r1"
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
  exit 1
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

  test -f "${file}" || fail "required file missing: ${file}"
  actual="$(hash_of "${file}")"

  test "${actual}" = "${expected}" || {
    echo "Expected: ${expected}" >&2
    echo "Actual:   ${actual}" >&2
    echo "File:     ${file}" >&2
    fail "integrity verification failed"
  }
}

command -v git >/dev/null 2>&1 || fail "git is unavailable"
command -v goto-cc >/dev/null 2>&1 || fail "goto-cc is unavailable"
command -v goto-instrument >/dev/null 2>&1 || fail "goto-instrument is unavailable"
command -v cbmc >/dev/null 2>&1 || fail "cbmc is unavailable"
command -v python3 >/dev/null 2>&1 || fail "python3 is unavailable"
command -v timeout >/dev/null 2>&1 || fail "timeout is unavailable"
command -v tar >/dev/null 2>&1 || fail "tar is unavailable"
command -v gzip >/dev/null 2>&1 || fail "gzip is unavailable"
test -x /usr/bin/time || fail "/usr/bin/time is unavailable"

test -d "${BASE}" || fail "campaign directory missing: ${BASE}"
test -d "${REPO}/.git" || fail "repository missing: ${REPO}"
test -d "${SRC}/mlkem/src" || fail "source snapshot missing: ${SRC}"
test -d "${FREEZE}" || fail "SUB-00F freeze directory missing"

test ! -e "${OUT}" || fail "versioned output already exists: ${OUT}"
test ! -e "${PACKAGE}" || fail "versioned package already exists: ${PACKAGE}"
test ! -e "${PACKAGE_HASH}" || fail "versioned package sidecar already exists"

HEAD="$(git -C "${REPO}" rev-parse HEAD)"
test "${HEAD}" = "${FROZEN_COMMIT}" || {
  echo "Expected commit: ${FROZEN_COMMIT}" >&2
  echo "Actual commit:   ${HEAD}" >&2
  fail "repository commit changed"
}

verify_hash "${FROZEN_HARNESS_SHA256}" "${FROZEN_HARNESS}"
verify_hash "${ZEROIZE_ADAPTER_SHA256}" "${ZEROIZE_ADAPTER}"
verify_hash "${FREEZE_MANIFEST_SHA256}" "${FREEZE_MANIFEST}"
verify_hash "${RUN1_ARCHIVE_SHA256}" "${RUN1_ARCHIVE}"

(
  cd "${FREEZE}"
  sha256sum --check "$(basename "${FREEZE_MANIFEST}")"
)

mkdir -p "${AUDIT}/repository_poly_sub_proof" "${BUILD}" "${RESULT}"

###############################################################################
# 1. POST-FREEZE REPOSITORY PRIOR-ART COLLECTION
#
# The independent theorem and execution manifest were frozen before this stage.
# Opening the dedicated repository proof material is now permitted and is
# recorded as post-freeze novelty auditing. Nothing collected here is used to
# edit the frozen theorem harness.
###############################################################################

PROOF_REL="proofs/cbmc/poly_sub"
PROOF_DIR="${REPO}/${PROOF_REL}"
test -d "${PROOF_DIR}" || fail "dedicated repository proof directory missing"

git -C "${REPO}" status --short >"${AUDIT}/repository_status.txt"
git -C "${REPO}" rev-parse HEAD >"${AUDIT}/repository_commit.txt"
git -C "${REPO}" ls-files "${PROOF_REL}" >"${AUDIT}/tracked_poly_sub_proof_files.txt"

while IFS= read -r rel
do
  test -n "${rel}" || continue
  test -f "${REPO}/${rel}" || continue

  destination="${AUDIT}/repository_poly_sub_proof/${rel#${PROOF_REL}/}"
  mkdir -p "$(dirname "${destination}")"
  cp -a "${REPO}/${rel}" "${destination}"
done <"${AUDIT}/tracked_poly_sub_proof_files.txt"

(
  cd "${REPO}"

  {
    echo "=== Exact composition-oriented repository searches ==="
    echo
    git grep -n -E \
      'mlk_poly_sub[[:space:]]*\(|mlk_poly_reduce[[:space:]]*\(|canonical|congruent|modulo|poly_sub.*poly_reduce|poly_reduce.*poly_sub' \
      -- proofs/cbmc mlkem/src 2>/dev/null || true

    echo
    echo "=== Exact relational-expression searches ==="
    echo
    git grep -n -E \
      'N\(A-B\)|N\(N\(A\)-N\(B\)\)|normalization|commutation|translation invariance|antisymmetry' \
      -- . 2>/dev/null || true
  } >"${AUDIT}/repository_targeted_searches.txt"
)

(
  cd "${AUDIT}"

  find . -type f \
    ! -name "REPOSITORY_NOVELTY_AUDIT_MANIFEST.sha256" \
    -print0 |
    LC_ALL=C sort -z |
    xargs -0 sha256sum
) >"${AUDIT}/REPOSITORY_NOVELTY_AUDIT_MANIFEST.sha256"

###############################################################################
# 2. VERSIONED ENVIRONMENT CORRECTION
#
# Run-1 left the portable value-barrier global unconstrained. The production
# design requires this blocker to be zero. This separate translation unit
# supplies that environment definition without changing production poly.c or
# the frozen theorem harness.
###############################################################################

cat >"${OPTBLOCKER_ADAPTER}" <<'EOF'
/*
 * SUB-00G-R1 environment adapter.
 *
 * The portable value-barrier implementation in verify.h reads a namespaced
 * volatile uint64_t that the production design specifies as being set to zero.
 * Run-1 linked poly.c without a definition of that environment object, so CBMC
 * treated it as unconstrained.
 *
 * This file provides the missing zero-valued environment object. It does not
 * modify mlkem-native production source and it is not a theorem assumption
 * about polynomial inputs.
 */

#include <stdint.h>
#include "common.h"

volatile uint64_t MLK_NAMESPACE(ct_opt_blocker_u64) = (uint64_t)0;
EOF

BUILD_COMMAND=(
  goto-cc
  -std=c90
  -DCBMC=1
  -DMLK_CONFIG_PARAMETER_SET=768
  -DMLK_CONFIG_NAMESPACE_PREFIX="${NAMESPACE}"
  -DMLK_CONFIG_NO_ASM=1
  -DMLK_CONFIG_CUSTOM_ZEROIZE=1
  -include "${ZEROIZE_ADAPTER}"
  -I"${SRC}/mlkem"
  -I"${SRC}/mlkem/src"
  "${FROZEN_HARNESS}"
  "${SRC}/mlkem/src/poly.c"
  "${OPTBLOCKER_ADAPTER}"
  -o "${MODEL}"
)

{
  printf 'COMMAND:'
  printf ' %q' "${BUILD_COMMAND[@]}"
  printf '\n'
} >"${BUILD}/goto_build_command.txt"

set +e
"${BUILD_COMMAND[@]}" >"${BUILD}/goto_build_stdout.txt" 2>"${BUILD}/goto_build_stderr.txt"
BUILD_RC="$?"
set -e
printf '%s\n' "${BUILD_RC}" >"${BUILD}/goto_build_exit_code.txt"

test "${BUILD_RC}" -eq 0 || {
  echo "Corrected GOTO construction failed. Evidence is preserved in ${BUILD}." >&2
  exit 2
}

test -s "${MODEL}" || fail "corrected GOTO model was not produced"

goto-instrument --validate-goto-binary "${MODEL}" \
  >"${BUILD}/validate_goto_binary.txt" 2>&1

goto-instrument --show-loops "${MODEL}" \
  >"${BUILD}/show_loops.txt" 2>&1

goto-instrument --show-properties "${MODEL}" \
  >"${BUILD}/show_properties.txt" 2>&1

goto-instrument --reachable-call-graph "${MODEL}" \
  >"${BUILD}/reachable_call_graph.txt" 2>&1

goto-instrument --list-undefined-functions "${MODEL}" \
  >"${BUILD}/undefined_functions.txt" 2>&1

goto-instrument --show-goto-functions "${MODEL}" \
  >"${BUILD}/show_goto_functions.txt" 2>&1

goto-instrument --show-symbol-table "${MODEL}" \
  >"${BUILD}/show_symbol_table.txt" 2>&1

sha256sum "${MODEL}" >"${BUILD}/model.sha256"
sha256sum "${OPTBLOCKER_ADAPTER}" >"${BUILD}/optblocker_adapter.sha256"
sha256sum "${FROZEN_HARNESS}" >"${BUILD}/frozen_harness.sha256"
sha256sum "${ZEROIZE_ADAPTER}" >"${BUILD}/zeroize_adapter.sha256"

grep -q -- "${NAMESPACE}_poly_sub" "${BUILD}/reachable_call_graph.txt" ||
  fail "corrected model does not reach production poly_sub"

grep -q -- "${NAMESPACE}_poly_reduce" "${BUILD}/reachable_call_graph.txt" ||
  fail "corrected model does not reach production poly_reduce"

if grep -Eq '(^|[^[:alnum:]_])mlk_zeroize([^[:alnum:]_]|$)' \
    "${BUILD}/reachable_call_graph.txt"
then
  fail "fail-closed zeroize adapter became reachable"
fi

grep -q -- "${BLOCKER_SYMBOL}" "${BUILD}/show_symbol_table.txt" ||
  fail "zero-valued blocker symbol is missing from corrected model"

if grep -q -- "${BLOCKER_SYMBOL}" "${BUILD}/undefined_functions.txt"
then
  fail "blocker symbol remains unresolved"
fi

grep '^Loop ' "${BUILD}/show_loops.txt" |
  sed -E 's/^Loop ([^:]+):$/\1/' |
  LC_ALL=C sort >"${BUILD}/actual_loop_ids.txt"

printf '%s\n' "${EXPECTED_LOOPS[@]}" |
  LC_ALL=C sort >"${BUILD}/expected_loop_ids.txt"

diff -u "${BUILD}/expected_loop_ids.txt" "${BUILD}/actual_loop_ids.txt" \
  >"${BUILD}/loop_set_diff.txt" || {
    cat "${BUILD}/loop_set_diff.txt" >&2
    fail "reachable loop set changed; proof was not executed"
  }

UNWINDSET="main.0:257,main.1:257,main.2:257,main.3:257,mlk_barrett_reduce.0:2,${NAMESPACE}_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2"

cat >"${REMEDIATION_MANIFEST}" <<EOF
# SUB-00G-R1 Corrected-Environment SUB-T1 Execution Manifest

## Frozen identity

- Repository commit: \`${FROZEN_COMMIT}\`
- Parameter set: ML-KEM-768
- Corrected namespace: \`${NAMESPACE}\`
- Frozen theorem harness SHA-256:
  \`${FROZEN_HARNESS_SHA256}\`
- Parent failed Run-1 archive SHA-256:
  \`${RUN1_ARCHIVE_SHA256}\`

## Run-1 classification

Run-1 is preserved as an invalidated environment-model experiment. Its
counterexample selected a non-zero value for the portable value-barrier
global because the model linked no definition of that production
environment object. Run-1 also omitted \`-DCBMC\`, so the repository's
narrow conversion-check pragma was inactive.

Run-1 did not falsify SUB-T1 and did not establish novelty.

## Exact versioned corrections

1. The frozen SUB-T1 theorem, assumptions, oracle, frame assertions and
   harness source are unchanged.
2. Production \`poly.c\` is unchanged.
3. The build now defines \`CBMC=1\`, activating the repository's own
   narrowly scoped conversion-check pragma.
4. A separate environment translation unit defines the namespaced
   portable value-barrier blocker as a volatile 64-bit zero.
5. The fail-closed zeroize adapter remains unchanged and unreachable.
6. Production \`poly_sub\` and \`poly_reduce\` bodies remain retained.
7. No function contract is used as an abstraction.
8. No loop contract is applied.

## Corrected model

- Model SHA-256:
  \`$(hash_of "${MODEL}")\`
- Environment-adapter SHA-256:
  \`$(hash_of "${OPTBLOCKER_ADAPTER}")\`
- Zeroize-adapter SHA-256:
  \`${ZEROIZE_ADAPTER_SHA256}\`
- Exact unwindset:
  \`${UNWINDSET}\`

## Safety flags

\`\`\`
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
\`\`\`

## Novelty audit boundary

The independently authored theorem and execution manifest were frozen
before the dedicated repository proof material was opened. This version
collects that material only for post-freeze comparison. The collected
repository proof is not used to edit the theorem or force a CBMC pass.

CBMC success and novelty remain separate gates:

- CBMC success establishes the frozen property under the recorded model.
- A novelty claim requires an equivalence review of the collected
  repository artefacts and a documented public-code/literature search.

The safe wording before that review is:

> independently authored CBMC semantic-composition artefact candidate

No world-first claim is made.
EOF

(
  cd "${OUT}"

  find . -type f \
    ! -path './result/*' \
    ! -name "$(basename "${PREPROOF_MANIFEST}")" \
    -print0 |
    LC_ALL=C sort -z |
    xargs -0 sha256sum
) >"${PREPROOF_MANIFEST}"

###############################################################################
# 3. CORRECTED SUB-T1 EXECUTION
###############################################################################

CBMC_COMMAND=(
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
  --slice-formula
  --sat-solver minisat2
  --trace
  --json-ui
)

{
  printf 'COMMAND:'
  printf ' %q' "${CBMC_COMMAND[@]}"
  printf '\n'
} >"${RESULT_COMMAND}"

set +e
/usr/bin/time -v \
  -o "${RESULT_RESOURCE}" \
  timeout \
  --signal=TERM \
  --kill-after=60s \
  21600s \
  "${CBMC_COMMAND[@]}" \
  >"${RESULT_JSON}" \
  2>"${RESULT_STDERR}"
CBMC_RC="$?"
set -e

printf '%s\n' "${CBMC_RC}" >"${RESULT_EXIT}"

python3 - "${RESULT_JSON}" "${RESULT_SUMMARY}" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])

results = []
overall = "UNREADABLE_OR_INCOMPLETE_JSON"
parse_error = ""

try:
    with json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    overall = "UNKNOWN"

    for item in data:
        if isinstance(item, dict) and "result" in item:
            results = item["result"]
        if isinstance(item, dict) and "cProverStatus" in item:
            overall = str(item["cProverStatus"])
except Exception as exc:
    parse_error = f"{type(exc).__name__}: {exc}"

successes = [r for r in results if r.get("status") == "SUCCESS"]
failures = [r for r in results if r.get("status") == "FAILURE"]
unknown = [r for r in results if r.get("status") not in {"SUCCESS", "FAILURE"}]

lines = [
    f"CBMC_STATUS={overall}",
    f"TOTAL_PROPERTIES={len(results)}",
    f"SUCCESS_PROPERTIES={len(successes)}",
    f"FAILURE_PROPERTIES={len(failures)}",
    f"OTHER_PROPERTIES={len(unknown)}",
    f"JSON_PARSE_ERROR={parse_error or 'NONE'}",
    "",
    "FAILING_PROPERTIES:",
]

if failures:
    for r in failures:
        lines.append(
            f"{r.get('property', '<unknown>')} | "
            f"{r.get('status', '<unknown>')} | "
            f"{r.get('description', '')}"
        )
else:
    lines.append("NONE")

summary_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

(
  cd "${RESULT}"

  find . -maxdepth 1 -type f \
    ! -name "$(basename "${RESULT_MANIFEST}")" \
    -printf '%P\0' |
    LC_ALL=C sort -z |
    xargs -0 -r sha256sum
) >"${RESULT_MANIFEST}"

COMPLETE_MANIFEST="${OUT}/SUB00G_R1_COMPLETE_ARTIFACT_MANIFEST.sha256"

(
  cd "${OUT}"

  find . -type f \
    ! -name "$(basename "${COMPLETE_MANIFEST}")" \
    -print0 |
    LC_ALL=C sort -z |
    xargs -0 sha256sum
) >"${COMPLETE_MANIFEST}"

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
echo "SUB-00G-R1 CORRECTED EXECUTION COMPLETED"
echo "============================================================"
echo
cat "${RESULT_SUMMARY}"
echo
echo "Raw CBMC exit code: ${CBMC_RC}"
echo "Evidence package:"
cat "${PACKAGE_HASH}"
echo
echo "Upload these two files:"
echo "1. ${PACKAGE}"
echo "2. ${PACKAGE_HASH}"
echo
echo "Do not edit or delete Run-1."
echo "Do not claim novelty or proof success until this package is reviewed."

exit "${CBMC_RC}"
