#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

FAMILY="${B4}/frozen_harness_family_v1"
FAMILY_MANIFEST="${FAMILY}/SUB00N_B4_4_ARTIFACT_MANIFEST.sha256"

PREFLIGHT="${B4}/SUB00N_B4_5_GOTO_PREFLIGHT_MLKEM768"
PREFLIGHT_MANIFEST="${PREFLIGHT}/SUB00N_B4_5_PREFLIGHT_ARTIFACT_MANIFEST.sha256"

RUN3="${B4}/SUB00N_BATCH4_CONTINUATION_MLKEM768_RUN3"
RUN3_PACKAGE="${RUN3}.tar.gz"
RUN3_PACKAGE_HASH="${RUN3_PACKAGE}.sha256"

DIAGNOSTIC="${B4}/SUB00N_B4_7_RUN3_COMPANION_FAILURE_DIAGNOSTIC.txt"
DIAGNOSTIC_HASH="${DIAGNOSTIC}.sha256"

EXPECTED_RUN3_PACKAGE_HASH="99228f830dcc896303a3ae324576f368d0b64d22fe3aa0e9cfc626f4f709ae65"
EXPECTED_DIAGNOSTIC_HASH="54f01061af4bd52bd8c9fa8d839406d054141445177ba8bd4ca4c8389cdc8cd6"

HARNESS="${FAMILY}/harnesses/sub_t4_reachability_harness.c"
SOURCE_ROOT="${ROOT}/source/mlkem"
SOURCE_SRC="${SOURCE_ROOT}/src"
SOURCE_POLY="${SOURCE_SRC}/poly.c"

ADAPTER="${FAMILY}/support/sub00n_b4_fail_closed_zeroize.h"
PRAGMA="${FAMILY}/support/sub00n_b4_verify_pragma_scope.h"
OPTBLOCKER="${FAMILY}/support/sub00n_b4_optblocker_zero.c"

FINAL="${B4}/SUB00N_B4_8_COVER_NEUTRAL_COMPANION_PREFLIGHT_MLKEM768"
STAGE="${B4}/.SUB00N_B4_8_COVER_NEUTRAL_COMPANION_PREFLIGHT_MLKEM768.tmp.$$"

HEADER="${STAGE}/support/sub00n_b4_cover_neutral_companion.h"

MODEL="${STAGE}/build/sub_t4_reachability_companion_mlkem768.goto"
REACHABLE_MODEL="${STAGE}/build/sub_t4_reachability_companion_mlkem768_reachable_only.goto"

BUILD_COMMAND="${STAGE}/build/goto_build_command.txt"
BUILD_STDOUT="${STAGE}/build/goto_build_stdout.txt"
BUILD_STDERR="${STAGE}/build/goto_build_stderr.txt"
BUILD_EXIT="${STAGE}/build/goto_build_exit_code.txt"

VALIDATE_COMMAND="${STAGE}/build/validate_authoritative_command.txt"
VALIDATE_STDOUT="${STAGE}/build/validate_authoritative_stdout.txt"
VALIDATE_STDERR="${STAGE}/build/validate_authoritative_stderr.txt"
VALIDATE_EXIT="${STAGE}/build/validate_authoritative_exit_code.txt"

DROP_COMMAND="${STAGE}/build/drop_unused_functions_command.txt"
DROP_STDOUT="${STAGE}/build/drop_unused_functions_stdout.txt"
DROP_STDERR="${STAGE}/build/drop_unused_functions_stderr.txt"
DROP_EXIT="${STAGE}/build/drop_unused_functions_exit_code.txt"

REACHABLE_VALIDATE_COMMAND="${STAGE}/build/validate_reachable_command.txt"
REACHABLE_VALIDATE_STDOUT="${STAGE}/build/validate_reachable_stdout.txt"
REACHABLE_VALIDATE_STDERR="${STAGE}/build/validate_reachable_stderr.txt"
REACHABLE_VALIDATE_EXIT="${STAGE}/build/validate_reachable_exit_code.txt"

FUNCTIONS_COMMAND="${STAGE}/build/show_goto_functions_command.txt"
FUNCTIONS_STDOUT="${STAGE}/build/show_goto_functions.txt"
FUNCTIONS_STDERR="${STAGE}/build/show_goto_functions_stderr.txt"
FUNCTIONS_EXIT="${STAGE}/build/show_goto_functions_exit_code.txt"

LOOPS_COMMAND="${STAGE}/build/show_loops_command.txt"
LOOPS_STDOUT="${STAGE}/build/show_loops.txt"
LOOPS_STDERR="${STAGE}/build/show_loops_stderr.txt"
LOOPS_EXIT="${STAGE}/build/show_loops_exit_code.txt"

EXPECTED_LOOPS="${STAGE}/build/expected_reachable_loop_ids.txt"
ACTUAL_LOOPS="${STAGE}/build/actual_reachable_loop_ids.txt"
LOOP_DIFF="${STAGE}/build/reachable_loop_diff.txt"
UNWINDSET_FILE="${STAGE}/build/frozen_unwindset.txt"

PROPERTIES_COMMAND="${STAGE}/build/show_properties_command.txt"
PROPERTIES_STDOUT="${STAGE}/build/show_properties.txt"
PROPERTIES_STDERR="${STAGE}/build/show_properties_stderr.txt"
PROPERTIES_EXIT="${STAGE}/build/show_properties_exit_code.txt"

CORRECTION="${STAGE}/SUB00N_B4_8_COMPANION_CORRECTION_RECORD.md"
SUMMARY="${STAGE}/SUB00N_B4_8_PREFLIGHT_SUMMARY.txt"
MANIFEST="${STAGE}/SUB00N_B4_8_PREFLIGHT_ARTIFACT_MANIFEST.sha256"

cleanup()
{
    rc=$?

    if [ "${rc}" -ne 0 ] && [ -d "${STAGE}" ]; then
        rm -rf "${STAGE}"
    fi

    exit "${rc}"
}
trap cleanup EXIT

fail()
{
    echo "ERROR: $*" >&2
    exit 1
}

write_command()
{
    destination="$1"
    shift

    {
        printf 'COMMAND:'
        printf ' %q' "$@"
        printf '\n'
    } >"${destination}"
}

run_recorded()
{
    stdout="$1"
    stderr="$2"
    exit_file="$3"
    shift 3

    set +e
    "$@" >"${stdout}" 2>"${stderr}"
    rc=$?
    set -e

    printf '%s\n' "${rc}" >"${exit_file}"
    return "${rc}"
}

check_hash()
{
    file="$1"
    expected="$2"
    label="$3"

    actual="$(sha256sum "${file}" | awk '{print $1}')"

    echo "${label}_EXPECTED_SHA256=${expected}"
    echo "${label}_ACTUAL_SHA256=${actual}"

    if [ "${actual}" != "${expected}" ]; then
        fail "${label}: SHA-256 mismatch"
    fi

    echo "${label}_HASH_CHECK=PASS"
}

echo "============================================================"
echo "SUB00N / BATCH 4 — B4.8 COVER-NEUTRAL COMPANION PREFLIGHT"
echo "============================================================"
echo

test ! -e "${FINAL}" ||
    fail "B4.8 final directory already exists: ${FINAL}"

test ! -e "${STAGE}" ||
    fail "B4.8 staging directory already exists: ${STAGE}"

for required in \
    "${FAMILY_MANIFEST}" \
    "${PREFLIGHT_MANIFEST}" \
    "${RUN3_PACKAGE}" \
    "${RUN3_PACKAGE_HASH}" \
    "${DIAGNOSTIC}" \
    "${DIAGNOSTIC_HASH}" \
    "${HARNESS}" \
    "${SOURCE_POLY}" \
    "${ADAPTER}" \
    "${PRAGMA}" \
    "${OPTBLOCKER}"
do
    test -f "${required}" ||
        fail "required frozen artefact missing: ${required}"
done

for tool in \
    goto-cc \
    goto-instrument \
    cbmc \
    sha256sum \
    python3 \
    grep \
    sed \
    awk \
    sort \
    diff
do
    command -v "${tool}" >/dev/null 2>&1 ||
        fail "required tool unavailable: ${tool}"
done

ACTIVE_B4="$(
    pgrep -af \
      '(^|/)(cbmc|goto-cc|goto-clang|goto-instrument)([[:space:]]|.*)(SUB00N|sub_t4|batch4_canonical)' \
      || true
)"

if [ -n "${ACTIVE_B4}" ]; then
    echo "Possible active Batch-4 process:"
    printf '%s\n' "${ACTIVE_B4}"
    fail "Batch-4 process-cleanliness gate failed"
fi

mkdir -p "${STAGE}/build" "${STAGE}/support"

echo "=== B4.8-A: PARENT INTEGRITY ==="

(
    cd "${FAMILY}"
    sha256sum -c "$(basename "${FAMILY_MANIFEST}")"
)

(
    cd "${PREFLIGHT}"
    sha256sum -c "$(basename "${PREFLIGHT_MANIFEST}")"
)

sha256sum -c "${RUN3_PACKAGE_HASH}"
sha256sum -c "${DIAGNOSTIC_HASH}"

check_hash \
    "${RUN3_PACKAGE}" \
    "${EXPECTED_RUN3_PACKAGE_HASH}" \
    "RUN3_PACKAGE"

check_hash \
    "${DIAGNOSTIC}" \
    "${EXPECTED_DIAGNOSTIC_HASH}" \
    "RUN3_DIAGNOSTIC"

grep -Fq \
    'FAILURE_PROPERTY=main.no-body.__CPROVER_cover' \
    "${DIAGNOSTIC}" ||
    fail "diagnostic does not bind the expected no-body cover failure"

grep -Fq \
    'FAILURE_DESCRIPTION=no body for callee __CPROVER_cover' \
    "${DIAGNOSTIC}" ||
    fail "diagnostic failure description is unexpected"

grep -Fq \
    'STATUS_COUNT_SUCCESS=333' \
    "${DIAGNOSTIC}" ||
    fail "diagnostic does not record 333 successful properties"

echo "PARENT_INTEGRITY_AND_DIAGNOSIS_BINDING=PASS"
echo

# ------------------------------------------------------------------
# Companion-only preprocessing header
# ------------------------------------------------------------------

cat >"${HEADER}" <<'EOF'
#ifndef SUB00N_B4_COVER_NEUTRAL_COMPANION_H
#define SUB00N_B4_COVER_NEUTRAL_COMPANION_H

/*
 * Companion-verification adapter only.
 *
 * The original frozen reachability harness contains five
 * __CPROVER_cover calls. Outside CBMC coverage mode those calls remain
 * unresolved and produce main.no-body.__CPROVER_cover.
 *
 * This header neutralizes only those coverage observations while
 * constructing a separate companion-verification GOTO model.
 *
 * The original frozen harness and original coverage model are unchanged.
 */

#ifdef __CPROVER_cover
#undef __CPROVER_cover
#endif

#define __CPROVER_cover(condition) ((void)0)

#endif
EOF

cat >"${CORRECTION}" <<EOF
# SUB00N B4.8 — Cover-Neutral Companion Correction

## Observed RUN3 result

RUN3 produced:

\`\`\`text
SUCCESS=333
FAILURE=1
FAILURE_PROPERTY=main.no-body.__CPROVER_cover
FAILURE_DESCRIPTION=no body for callee __CPROVER_cover
UNWINDING_FAILURES=0
\`\`\`

The sole failure was caused by executing a model containing
\`__CPROVER_cover\` calls outside coverage mode.

It was not an arithmetic, frame, bounds, overflow, production-exactness
or unwinding failure.

## Correction

A separate companion-verification model is built from:

- the same frozen reachability harness;
- the same production \`poly.c\`;
- the same ML-KEM-768 configuration;
- the same portable-C Mode-A support artefacts.

The additional forced-include header defines:

\`\`\`c
#define __CPROVER_cover(condition) ((void)0)
\`\`\`

This neutralizes only the five coverage observations.

## Evidence boundary

This derived model may be used only for:

- safety-property verification;
- production exactness verification;
- frame verification;
- explicit unwinding verification.

It may not be used as coverage evidence.

Actual coverage must use the original authoritative reachability model
with \`--cover cover\`.

## Integrity

- Frozen reachability harness modified: no.
- Original coverage GOTO model modified: no.
- Production source modified: no.
- RUN1 modified: no.
- RUN2 modified: no.
- RUN3 modified: no.
- Batch 3 touched: no.
EOF

# ------------------------------------------------------------------
# Build companion model
# ------------------------------------------------------------------

BUILD_CMD=(
    goto-cc
    -std=c90
    -DMLK_CONFIG_PARAMETER_SET=768
    -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00n_b4
    -DMLK_CONFIG_NO_ASM=1
    -DMLK_CONFIG_CUSTOM_ZEROIZE=1
    -include "${ADAPTER}"
    -include "${PRAGMA}"
    -include "${HEADER}"
    -I"${SOURCE_ROOT}"
    -I"${SOURCE_SRC}"
    "${HARNESS}"
    "${SOURCE_POLY}"
    "${OPTBLOCKER}"
    -o "${MODEL}"
)

write_command "${BUILD_COMMAND}" "${BUILD_CMD[@]}"

if ! run_recorded \
    "${BUILD_STDOUT}" \
    "${BUILD_STDERR}" \
    "${BUILD_EXIT}" \
    "${BUILD_CMD[@]}"
then
    cat "${BUILD_STDERR}" >&2 || true
    fail "cover-neutral companion GOTO build failed"
fi

test -s "${MODEL}" ||
    fail "cover-neutral companion model was not created"

echo "COMPANION_GOTO_BUILD=PASS"

# ------------------------------------------------------------------
# Validate authoritative derived model
# ------------------------------------------------------------------

VALIDATE_CMD=(
    goto-instrument
    --validate-goto-binary
    "${MODEL}"
)

write_command "${VALIDATE_COMMAND}" "${VALIDATE_CMD[@]}"

if ! run_recorded \
    "${VALIDATE_STDOUT}" \
    "${VALIDATE_STDERR}" \
    "${VALIDATE_EXIT}" \
    "${VALIDATE_CMD[@]}"
then
    cat "${VALIDATE_STDERR}" >&2 || true
    fail "cover-neutral authoritative model validation failed"
fi

echo "AUTHORITATIVE_COMPANION_VALIDATION=PASS"

# ------------------------------------------------------------------
# Reachable-only inspection model
# ------------------------------------------------------------------

DROP_CMD=(
    goto-instrument
    --drop-unused-functions
    "${MODEL}"
    "${REACHABLE_MODEL}"
)

write_command "${DROP_COMMAND}" "${DROP_CMD[@]}"

if ! run_recorded \
    "${DROP_STDOUT}" \
    "${DROP_STDERR}" \
    "${DROP_EXIT}" \
    "${DROP_CMD[@]}"
then
    cat "${DROP_STDERR}" >&2 || true
    fail "dropping unused functions failed"
fi

test -s "${REACHABLE_MODEL}" ||
    fail "reachable-only companion model was not created"

REACHABLE_VALIDATE_CMD=(
    goto-instrument
    --validate-goto-binary
    "${REACHABLE_MODEL}"
)

write_command \
    "${REACHABLE_VALIDATE_COMMAND}" \
    "${REACHABLE_VALIDATE_CMD[@]}"

if ! run_recorded \
    "${REACHABLE_VALIDATE_STDOUT}" \
    "${REACHABLE_VALIDATE_STDERR}" \
    "${REACHABLE_VALIDATE_EXIT}" \
    "${REACHABLE_VALIDATE_CMD[@]}"
then
    cat "${REACHABLE_VALIDATE_STDERR}" >&2 || true
    fail "reachable-only companion model validation failed"
fi

echo "REACHABLE_ONLY_COMPANION_VALIDATION=PASS"

# ------------------------------------------------------------------
# Function and loop binding
# ------------------------------------------------------------------

FUNCTIONS_CMD=(
    goto-instrument
    --show-goto-functions
    "${MODEL}"
)

write_command "${FUNCTIONS_COMMAND}" "${FUNCTIONS_CMD[@]}"

if ! run_recorded \
    "${FUNCTIONS_STDOUT}" \
    "${FUNCTIONS_STDERR}" \
    "${FUNCTIONS_EXIT}" \
    "${FUNCTIONS_CMD[@]}"
then
    fail "GOTO-function inspection failed"
fi

grep -q 'mlk_sub00n_b4_poly_sub' "${FUNCTIONS_STDOUT}" ||
    fail "production poly_sub body is missing"

if grep -q '__CPROVER_cover' "${FUNCTIONS_STDOUT}"; then
    fail "__CPROVER_cover remains in the cover-neutral companion model"
fi

LOOPS_CMD=(
    goto-instrument
    --show-loops
    "${REACHABLE_MODEL}"
)

write_command "${LOOPS_COMMAND}" "${LOOPS_CMD[@]}"

if ! run_recorded \
    "${LOOPS_STDOUT}" \
    "${LOOPS_STDERR}" \
    "${LOOPS_EXIT}" \
    "${LOOPS_CMD[@]}"
then
    fail "reachable-loop inspection failed"
fi

cat >"${EXPECTED_LOOPS}" <<'EOF'
main.0
main.1
mlk_sub00n_b4_poly_sub.0
EOF

sed -nE \
    's/^[[:space:]]*Loop[[:space:]]+([A-Za-z_][A-Za-z0-9_]*\.[0-9]+):?.*$/\1/p' \
    "${LOOPS_STDOUT}" |
sort -u >"${ACTUAL_LOOPS}"

if ! diff -u \
    "${EXPECTED_LOOPS}" \
    "${ACTUAL_LOOPS}" \
    >"${LOOP_DIFF}"
then
    cat "${LOOP_DIFF}" >&2
    fail "companion reachable-loop binding mismatch"
fi

UNWINDSET="$(
    awk '
    BEGIN { first = 1 }
    {
        if (!first) {
            printf ","
        }

        printf "%s:257", $0
        first = 0
    }
    END {
        printf "\n"
    }
    ' "${ACTUAL_LOOPS}"
)"

printf '%s\n' "${UNWINDSET}" >"${UNWINDSET_FILE}"

echo "COMPANION_LOOP_BINDING=PASS"
echo "FROZEN_UNWINDSET=${UNWINDSET}"

# ------------------------------------------------------------------
# Property inventory
# ------------------------------------------------------------------

PROPERTIES_CMD=(
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

write_command "${PROPERTIES_COMMAND}" "${PROPERTIES_CMD[@]}"

if ! run_recorded \
    "${PROPERTIES_STDOUT}" \
    "${PROPERTIES_STDERR}" \
    "${PROPERTIES_EXIT}" \
    "${PROPERTIES_CMD[@]}"
then
    cat "${PROPERTIES_STDERR}" >&2 || true
    fail "companion property-inventory extraction failed"
fi

PROPERTY_COUNT="$(
    grep -Ec '^Property[[:space:]]+' "${PROPERTIES_STDOUT}" ||
    true
)"

echo "DISPLAYED_PROPERTY_COUNT=${PROPERTY_COUNT}"

if [ "${PROPERTY_COUNT}" -ne 333 ]; then
    fail "expected 333 companion properties, found ${PROPERTY_COUNT}"
fi

if grep -q \
    'main.no-body.__CPROVER_cover\|no body for callee __CPROVER_cover' \
    "${PROPERTIES_STDOUT}"
then
    fail "no-body cover property remains in companion inventory"
fi

grep -q \
    'SUB_T4_COV_EXACTNESS: production output must equal mathematical difference' \
    "${PROPERTIES_STDOUT}" ||
    fail "production-exactness property is missing"

grep -q \
    'SUB_T4_COV_FRAME: RB must remain unchanged' \
    "${PROPERTIES_STDOUT}" ||
    fail "frame property is missing"

echo "COMPANION_PROPERTY_INVENTORY=PASS_333_PROPERTIES"

# ------------------------------------------------------------------
# Freeze summary
# ------------------------------------------------------------------

{
    echo "============================================================"
    echo "SUB00N B4.8 — COVER-NEUTRAL COMPANION PREFLIGHT SUMMARY"
    echo "============================================================"
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo
    echo "FROZEN_HARNESS=${HARNESS}"
    echo "FROZEN_HARNESS_SHA256=$(sha256sum "${HARNESS}" | awk '{print $1}')"
    echo
    echo "COVER_NEUTRAL_HEADER=${HEADER}"
    echo "COVER_NEUTRAL_HEADER_SHA256=$(sha256sum "${HEADER}" | awk '{print $1}')"
    echo
    echo "AUTHORITATIVE_COMPANION_MODEL=${MODEL}"
    echo "AUTHORITATIVE_COMPANION_MODEL_SHA256=$(sha256sum "${MODEL}" | awk '{print $1}')"
    echo "AUTHORITATIVE_COMPANION_MODEL_SIZE=$(stat -c '%s' "${MODEL}")"
    echo
    echo "REACHABLE_ONLY_COMPANION_MODEL=${REACHABLE_MODEL}"
    echo "REACHABLE_ONLY_COMPANION_MODEL_SHA256=$(sha256sum "${REACHABLE_MODEL}" | awk '{print $1}')"
    echo "REACHABLE_ONLY_COMPANION_MODEL_SIZE=$(stat -c '%s' "${REACHABLE_MODEL}")"
    echo
    echo "PRODUCTION_POLY_SUB_BODY_PRESENT=YES"
    echo "CPROVER_COVER_CALL_PRESENT_IN_COMPANION_MODEL=NO"
    echo "REACHABLE_LOOP_COUNT=$(wc -l < "${ACTUAL_LOOPS}")"
    echo "REACHABLE_LOOP_IDS_BEGIN"
    cat "${ACTUAL_LOOPS}"
    echo "REACHABLE_LOOP_IDS_END"
    echo "FROZEN_UNWINDSET=${UNWINDSET}"
    echo "DISPLAYED_PROPERTY_COUNT=${PROPERTY_COUNT}"
    echo "PRODUCTION_EXACTNESS_PROPERTY_PRESENT=YES"
    echo "FRAME_PROPERTY_PRESENT=YES"
    echo "NO_BODY_COVER_PROPERTY_PRESENT=NO"
    echo
    echo "=== SCIENTIFIC ACTION RECORD ==="
    echo "AUTHORITATIVE_COMPANION_GOTO_CREATED=YES"
    echo "REACHABLE_ONLY_INSPECTION_GOTO_CREATED=YES"
    echo "GOTO_MODELS_VALIDATED=2_OF_2"
    echo "CBMC_SOLVER_EXECUTED=NO"
    echo "THEOREM_RESULT_CREATED=NO"
    echo "COVERAGE_RESULT_CREATED=NO"
    echo "FROZEN_HARNESS_MODIFIED=NO"
    echo "ORIGINAL_COVERAGE_MODEL_MODIFIED=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "RUN1_MODIFIED=NO"
    echo "RUN2_MODIFIED=NO"
    echo "RUN3_MODIFIED=NO"
    echo "BATCH3_TOUCHED=NO"
    echo "SUB_T1_RESULT_MODIFIED=NO"
    echo "SUB_T2_RESULT_MODIFIED=NO"
    echo
    echo "SUB00N_B4_8_COMPANION_PREFLIGHT_VERDICT=PASS"
} >"${SUMMARY}"

(
    cd "${STAGE}"

    find . \
        -type f \
        ! -name "$(basename "${MANIFEST}")" \
        -print0 |
    sort -z |
    xargs -0 sha256sum
) >"${MANIFEST}"

find "${STAGE}" -type f -exec chmod a-w {} +
find "${STAGE}" -type d -exec chmod 0555 {} +

mv "${STAGE}" "${FINAL}"
trap - EXIT

echo
echo "============================================================"
echo "SUB00N / BATCH 4 — B4.8 PREFLIGHT COMPLETE"
echo "============================================================"
echo "FINAL=${FINAL}"
echo

cat "${FINAL}/SUB00N_B4_8_PREFLIGHT_SUMMARY.txt"

echo
echo "=== MODEL HASHES ==="

sha256sum \
    "${FINAL}/build/sub_t4_reachability_companion_mlkem768.goto" \
    "${FINAL}/build/sub_t4_reachability_companion_mlkem768_reachable_only.goto"

echo
echo "=== FULL MANIFEST VERIFICATION ==="

(
    cd "${FINAL}"
    sha256sum -c "$(basename "${MANIFEST}")"
)

echo
echo "BATCH4_COVER_NEUTRAL_COMPANION_PREFLIGHT_GATE=PASS"
echo "NO_CBMC_SOLVER_EXECUTION_OCCURRED=YES"
echo "BATCH3_TOUCHED=NO"
