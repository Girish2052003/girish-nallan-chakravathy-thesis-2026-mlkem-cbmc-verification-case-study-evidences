#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

FAMILY="${B4}/frozen_harness_family_v1"
FAMILY_MANIFEST="${FAMILY}/SUB00N_B4_4_ARTIFACT_MANIFEST.sha256"

SOURCE_ROOT="${ROOT}/source/mlkem"
SOURCE_SRC="${SOURCE_ROOT}/src"
SOURCE_POLY="${SOURCE_SRC}/poly.c"

ADAPTER="${FAMILY}/support/sub00n_b4_fail_closed_zeroize.h"
PRAGMA="${FAMILY}/support/sub00n_b4_verify_pragma_scope.h"
OPTBLOCKER="${FAMILY}/support/sub00n_b4_optblocker_zero.c"

FINAL="${B4}/SUB00N_B4_5_GOTO_PREFLIGHT_MLKEM768"
STAGE="${B4}/.SUB00N_B4_5_GOTO_PREFLIGHT_MLKEM768.tmp.$$"

SUMMARY="${STAGE}/SUB00N_B4_5_PREFLIGHT_SUMMARY.txt"
FREEZE="${STAGE}/SUB00N_B4_5_EXECUTION_INPUT_FREEZE.md"
CORRECTION="${STAGE}/SUB00N_B4_5_V1_FAILURE_AND_V2_CORRECTION.md"
MANIFEST="${STAGE}/SUB00N_B4_5_PREFLIGHT_ARTIFACT_MANIFEST.sha256"

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
    } > "${destination}"
}

run_and_record()
{
    output="$1"
    error="$2"
    exit_file="$3"
    shift 3

    set +e
    "$@" >"${output}" 2>"${error}"
    rc=$?
    set -e

    printf '%s\n' "${rc}" >"${exit_file}"
    return "${rc}"
}

echo "============================================================"
echo "SUB00N / BATCH 4 — B4.5 GOTO PREFLIGHT"
echo "============================================================"
echo "ROOT=${ROOT}"
echo "B4=${B4}"
echo

test ! -e "${FINAL}" ||
    fail "B4.5 final directory already exists: ${FINAL}"

test ! -e "${STAGE}" ||
    fail "B4.5 staging directory already exists: ${STAGE}"

for required in \
    "${FAMILY_MANIFEST}" \
    "${SOURCE_POLY}" \
    "${ADAPTER}" \
    "${PRAGMA}" \
    "${OPTBLOCKER}"
do
    test -f "${required}" ||
        fail "required frozen input missing: ${required}"
done

for tool in \
    goto-cc \
    goto-instrument \
    cbmc \
    sha256sum \
    grep \
    sed \
    awk \
    sort \
    diff \
    paste \
    stat \
    readlink
do
    command -v "${tool}" >/dev/null 2>&1 ||
        fail "required tool unavailable: ${tool}"
done

echo "=== B4.5-A: FROZEN FAMILY INTEGRITY ==="

(
    cd "${FAMILY}"
    sha256sum -c "$(basename "${FAMILY_MANIFEST}")"
)

echo "FROZEN_FAMILY_INTEGRITY=PASS"
echo

ACTIVE_B4="$(
    pgrep -af \
      '(^|/)(cbmc|goto-cc|goto-clang|goto-instrument)([[:space:]]|.*)(SUB00N|sub_t4|batch4_canonical)' \
      || true
)"

if [ -n "${ACTIVE_B4}" ]; then
    echo "Possible Batch-4 process:"
    printf '%s\n' "${ACTIVE_B4}"
    fail "Batch-4 process-cleanliness gate failed"
fi

mkdir -p "${STAGE}"

cat > "${CORRECTION}" <<'EOF'
# SUB00N B4.5 — V1 Failure and V2 Correction Record

## V1 outcome

The first B4.5 preflight attempt stopped during the POSITIVE case's
loop-identifier comparison.

This was not a theorem, coverage, or negative-control failure.

No verification solver was executed.

The temporary POSITIVE GOTO model and inspection outputs were held only
inside the fail-closed staging directory and were removed by the cleanup
trap after the preflight script exited unsuccessfully.

## V1 script defects

The original script incorrectly applied loop discovery to the complete
linked GOTO model. That model intentionally retained unrelated production
functions, so loops from NTT, reduction, multiplication, poly_add and other
functions appeared even though they were unreachable from main.

The original parser also searched every output line with an unanchored
regular expression. It therefore misclassified the staging-path suffix
".tmp.<pid>" as a loop identifier.

## V2 correction

V2 keeps two models per case:

1. The authoritative original GOTO model.
   This remains the later verification input.

2. A reachable-only inspection model produced with:
       goto-instrument --drop-unused-functions

Loop discovery is applied only to the reachable-only inspection model.

The parser accepts only explicit loop-declaration lines beginning with:
       Loop

Paths, diagnostics and unrelated numeric suffixes cannot become loop IDs.

## Integrity boundary

The B4.4 frozen harnesses are unchanged.

The production poly.c source is unchanged.

Batch 3 is untouched.

The failed V1 attempt produced no theorem result and may not be reported
as scientific evidence.
EOF

CASE_IDS="
POSITIVE
REACHABILITY
INVALID_UPPER
INVALID_LOWER
"

case_harness()
{
    case "$1" in
        POSITIVE)
            printf '%s\n' \
                "${FAMILY}/harnesses/sub_t4_canonical_domain_harness.c"
            ;;
        REACHABILITY)
            printf '%s\n' \
                "${FAMILY}/harnesses/sub_t4_reachability_harness.c"
            ;;
        INVALID_UPPER)
            printf '%s\n' \
                "${FAMILY}/harnesses/sub_t4_invalid_upper_harness.c"
            ;;
        INVALID_LOWER)
            printf '%s\n' \
                "${FAMILY}/harnesses/sub_t4_invalid_lower_harness.c"
            ;;
        *)
            return 1
            ;;
    esac
}

case_expected_loops()
{
    case "$1" in
        POSITIVE)
            cat <<'EOF'
main.0
main.1
main.2
mlk_sub00n_b4_poly_sub.0
EOF
            ;;
        REACHABILITY)
            cat <<'EOF'
main.0
main.1
mlk_sub00n_b4_poly_sub.0
EOF
            ;;
        INVALID_UPPER|INVALID_LOWER)
            cat <<'EOF'
main.0
mlk_sub00n_b4_poly_sub.0
EOF
            ;;
        *)
            return 1
            ;;
    esac
}

case_model_name()
{
    case "$1" in
        POSITIVE)
            printf '%s\n' 'sub_t4_positive_mlkem768.goto'
            ;;
        REACHABILITY)
            printf '%s\n' 'sub_t4_reachability_mlkem768.goto'
            ;;
        INVALID_UPPER)
            printf '%s\n' 'sub_t4_invalid_upper_mlkem768.goto'
            ;;
        INVALID_LOWER)
            printf '%s\n' 'sub_t4_invalid_lower_mlkem768.goto'
            ;;
        *)
            return 1
            ;;
    esac
}

{
    echo "============================================================"
    echo "SUB00N / BATCH 4 — B4.5 GOTO PREFLIGHT SUMMARY"
    echo "============================================================"
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "ROOT=${ROOT}"
    echo "FAMILY=${FAMILY}"
    echo "SOURCE_POLY=${SOURCE_POLY}"
    echo
    echo "CBMC_VERSION=$(cbmc --version 2>&1 | head -n 1)"
    echo "GOTO_CC_VERSION=$(goto-cc --version 2>&1 | head -n 1)"
    echo "GOTO_INSTRUMENT_VERSION=$(goto-instrument --version 2>&1 | head -n 1)"
    echo
} > "${SUMMARY}"

for CASE_ID in ${CASE_IDS}; do
    CASE_DIR="${STAGE}/cases/${CASE_ID}"
    BUILD_DIR="${CASE_DIR}/build"

    HARNESS="$(case_harness "${CASE_ID}")"
    MODEL_NAME="$(case_model_name "${CASE_ID}")"
    MODEL="${BUILD_DIR}/${MODEL_NAME}"
    REACHABLE_MODEL="${BUILD_DIR}/${MODEL_NAME%.goto}_reachable_only.goto"

    BUILD_COMMAND="${BUILD_DIR}/goto_build_command.txt"
    BUILD_STDOUT="${BUILD_DIR}/goto_build_stdout.txt"
    BUILD_STDERR="${BUILD_DIR}/goto_build_stderr.txt"
    BUILD_EXIT="${BUILD_DIR}/goto_build_exit_code.txt"

    VALIDATE_COMMAND="${BUILD_DIR}/validate_command.txt"
    VALIDATE_STDOUT="${BUILD_DIR}/validate_stdout.txt"
    VALIDATE_STDERR="${BUILD_DIR}/validate_stderr.txt"
    VALIDATE_EXIT="${BUILD_DIR}/validate_exit_code.txt"

    DROP_UNUSED_COMMAND="${BUILD_DIR}/drop_unused_functions_command.txt"
    DROP_UNUSED_STDOUT="${BUILD_DIR}/drop_unused_functions_stdout.txt"
    DROP_UNUSED_STDERR="${BUILD_DIR}/drop_unused_functions_stderr.txt"
    DROP_UNUSED_EXIT="${BUILD_DIR}/drop_unused_functions_exit_code.txt"

    REACHABLE_VALIDATE_COMMAND="${BUILD_DIR}/validate_reachable_model_command.txt"
    REACHABLE_VALIDATE_STDOUT="${BUILD_DIR}/validate_reachable_model_stdout.txt"
    REACHABLE_VALIDATE_STDERR="${BUILD_DIR}/validate_reachable_model_stderr.txt"
    REACHABLE_VALIDATE_EXIT="${BUILD_DIR}/validate_reachable_model_exit_code.txt"

    SYMBOL_COMMAND="${BUILD_DIR}/show_symbol_table_command.txt"
    SYMBOL_STDOUT="${BUILD_DIR}/show_symbol_table.txt"
    SYMBOL_STDERR="${BUILD_DIR}/show_symbol_table_stderr.txt"
    SYMBOL_EXIT="${BUILD_DIR}/show_symbol_table_exit_code.txt"

    FUNCTIONS_COMMAND="${BUILD_DIR}/show_goto_functions_command.txt"
    FUNCTIONS_STDOUT="${BUILD_DIR}/show_goto_functions.txt"
    FUNCTIONS_STDERR="${BUILD_DIR}/show_goto_functions_stderr.txt"
    FUNCTIONS_EXIT="${BUILD_DIR}/show_goto_functions_exit_code.txt"

    LOOPS_COMMAND="${BUILD_DIR}/show_loops_command.txt"
    LOOPS_STDOUT="${BUILD_DIR}/show_loops.txt"
    LOOPS_STDERR="${BUILD_DIR}/show_loops_stderr.txt"
    LOOPS_EXIT="${BUILD_DIR}/show_loops_exit_code.txt"

    EXPECTED_LOOPS="${BUILD_DIR}/expected_reachable_loop_ids.txt"
    ACTUAL_LOOPS="${BUILD_DIR}/actual_reachable_loop_ids.txt"
    LOOP_DIFF="${BUILD_DIR}/reachable_loop_diff.txt"
    UNWINDSET_FILE="${BUILD_DIR}/frozen_unwindset.txt"

    PROPERTIES_COMMAND="${BUILD_DIR}/show_properties_command.txt"
    PROPERTIES_STDOUT="${BUILD_DIR}/show_properties.txt"
    PROPERTIES_STDERR="${BUILD_DIR}/show_properties_stderr.txt"
    PROPERTIES_EXIT="${BUILD_DIR}/show_properties_exit_code.txt"

    CASE_SUMMARY="${CASE_DIR}/CASE_PREFLIGHT_SUMMARY.txt"

    mkdir -p "${BUILD_DIR}"

    test -f "${HARNESS}" ||
        fail "${CASE_ID}: harness missing: ${HARNESS}"

    BUILD_CMD=(
        goto-cc
        -std=c90
        -DMLK_CONFIG_PARAMETER_SET=768
        -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00n_b4
        -DMLK_CONFIG_NO_ASM=1
        -DMLK_CONFIG_CUSTOM_ZEROIZE=1
        -include "${ADAPTER}"
        -include "${PRAGMA}"
        -I"${SOURCE_ROOT}"
        -I"${SOURCE_SRC}"
        "${HARNESS}"
        "${SOURCE_POLY}"
        "${OPTBLOCKER}"
        -o "${MODEL}"
    )

    write_command "${BUILD_COMMAND}" "${BUILD_CMD[@]}"

    if ! run_and_record \
        "${BUILD_STDOUT}" \
        "${BUILD_STDERR}" \
        "${BUILD_EXIT}" \
        "${BUILD_CMD[@]}"
    then
        cat "${BUILD_STDERR}" >&2 || true
        fail "${CASE_ID}: goto-cc build failed"
    fi

    test -s "${MODEL}" ||
        fail "${CASE_ID}: GOTO model was not created"

    VALIDATE_CMD=(
        goto-instrument
        --validate-goto-binary
        "${MODEL}"
    )

    write_command "${VALIDATE_COMMAND}" "${VALIDATE_CMD[@]}"

    if ! run_and_record \
        "${VALIDATE_STDOUT}" \
        "${VALIDATE_STDERR}" \
        "${VALIDATE_EXIT}" \
        "${VALIDATE_CMD[@]}"
    then
        cat "${VALIDATE_STDERR}" >&2 || true
        fail "${CASE_ID}: GOTO validation failed"
    fi

    DROP_UNUSED_CMD=(
        goto-instrument
        --drop-unused-functions
        "${MODEL}"
        "${REACHABLE_MODEL}"
    )

    write_command "${DROP_UNUSED_COMMAND}" "${DROP_UNUSED_CMD[@]}"

    if ! run_and_record \
        "${DROP_UNUSED_STDOUT}" \
        "${DROP_UNUSED_STDERR}" \
        "${DROP_UNUSED_EXIT}" \
        "${DROP_UNUSED_CMD[@]}"
    then
        cat "${DROP_UNUSED_STDERR}" >&2 || true
        fail "${CASE_ID}: dropping unused functions failed"
    fi

    test -s "${REACHABLE_MODEL}" ||
        fail "${CASE_ID}: reachable-only inspection model was not created"

    REACHABLE_VALIDATE_CMD=(
        goto-instrument
        --validate-goto-binary
        "${REACHABLE_MODEL}"
    )

    write_command \
        "${REACHABLE_VALIDATE_COMMAND}" \
        "${REACHABLE_VALIDATE_CMD[@]}"

    if ! run_and_record \
        "${REACHABLE_VALIDATE_STDOUT}" \
        "${REACHABLE_VALIDATE_STDERR}" \
        "${REACHABLE_VALIDATE_EXIT}" \
        "${REACHABLE_VALIDATE_CMD[@]}"
    then
        cat "${REACHABLE_VALIDATE_STDERR}" >&2 || true
        fail "${CASE_ID}: reachable-only GOTO validation failed"
    fi

    SYMBOL_CMD=(
        goto-instrument
        --show-symbol-table
        "${MODEL}"
    )

    write_command "${SYMBOL_COMMAND}" "${SYMBOL_CMD[@]}"

    if ! run_and_record \
        "${SYMBOL_STDOUT}" \
        "${SYMBOL_STDERR}" \
        "${SYMBOL_EXIT}" \
        "${SYMBOL_CMD[@]}"
    then
        fail "${CASE_ID}: symbol-table extraction failed"
    fi

    FUNCTIONS_CMD=(
        goto-instrument
        --show-goto-functions
        "${MODEL}"
    )

    write_command "${FUNCTIONS_COMMAND}" "${FUNCTIONS_CMD[@]}"

    if ! run_and_record \
        "${FUNCTIONS_STDOUT}" \
        "${FUNCTIONS_STDERR}" \
        "${FUNCTIONS_EXIT}" \
        "${FUNCTIONS_CMD[@]}"
    then
        fail "${CASE_ID}: GOTO-function extraction failed"
    fi

    if ! grep -q 'mlk_sub00n_b4_poly_sub' "${FUNCTIONS_STDOUT}"; then
        fail "${CASE_ID}: retained production poly_sub body not found"
    fi

    LOOPS_CMD=(
        goto-instrument
        --show-loops
        "${REACHABLE_MODEL}"
    )

    write_command "${LOOPS_COMMAND}" "${LOOPS_CMD[@]}"

    if ! run_and_record \
        "${LOOPS_STDOUT}" \
        "${LOOPS_STDERR}" \
        "${LOOPS_EXIT}" \
        "${LOOPS_CMD[@]}"
    then
        cat "${LOOPS_STDERR}" >&2 || true
        fail "${CASE_ID}: loop extraction failed"
    fi

    case_expected_loops "${CASE_ID}" |
        sort -u > "${EXPECTED_LOOPS}"

    {
        sed -nE \
            's/^[[:space:]]*Loop[[:space:]]+([A-Za-z_][A-Za-z0-9_]*\.[0-9]+):?.*$/\1/p' \
            "${LOOPS_STDOUT}" ||
            true
    } |
        sort -u > "${ACTUAL_LOOPS}"

    if [ ! -s "${ACTUAL_LOOPS}" ]; then
        echo "${CASE_ID}: no anchored loop declarations were parsed"
        echo "--- raw show-loops output"
        cat "${LOOPS_STDOUT}"
        fail "${CASE_ID}: reachable-loop parser produced an empty set"
    fi

    if diff -u \
        "${EXPECTED_LOOPS}" \
        "${ACTUAL_LOOPS}" \
        >"${LOOP_DIFF}"
    then
        LOOP_BINDING="PASS"
    else
        echo
        echo "${CASE_ID}: unexpected loop identifiers"
        cat "${LOOP_DIFF}"
        fail "${CASE_ID}: reachable-loop binding mismatch"
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

    printf '%s\n' "${UNWINDSET}" > "${UNWINDSET_FILE}"

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

    if ! run_and_record \
        "${PROPERTIES_STDOUT}" \
        "${PROPERTIES_STDERR}" \
        "${PROPERTIES_EXIT}" \
        "${PROPERTIES_CMD[@]}"
    then
        cat "${PROPERTIES_STDERR}" >&2 || true
        fail "${CASE_ID}: property extraction failed"
    fi

    PROPERTY_COUNT="$(
        grep -Ec \
            '^\[[^]]+\]|^Property[[:space:]]+' \
            "${PROPERTIES_STDOUT}" ||
            true
    )"

    {
        echo "CASE_ID=${CASE_ID}"
        echo "HARNESS=$(readlink -f "${HARNESS}")"
        echo "HARNESS_SHA256=$(sha256sum "${HARNESS}" | awk '{print $1}')"
        echo "AUTHORITATIVE_MODEL=$(readlink -f "${MODEL}")"
        echo "AUTHORITATIVE_MODEL_SHA256=$(sha256sum "${MODEL}" | awk '{print $1}')"
        echo "AUTHORITATIVE_MODEL_SIZE=$(stat -c '%s' "${MODEL}")"
        echo "REACHABLE_ONLY_MODEL=$(readlink -f "${REACHABLE_MODEL}")"
        echo "REACHABLE_ONLY_MODEL_SHA256=$(sha256sum "${REACHABLE_MODEL}" | awk '{print $1}')"
        echo "REACHABLE_ONLY_MODEL_SIZE=$(stat -c '%s' "${REACHABLE_MODEL}")"
        echo "BUILD_EXIT_CODE=$(cat "${BUILD_EXIT}")"
        echo "AUTHORITATIVE_VALIDATION_EXIT_CODE=$(cat "${VALIDATE_EXIT}")"
        echo "DROP_UNUSED_FUNCTIONS_EXIT_CODE=$(cat "${DROP_UNUSED_EXIT}")"
        echo "REACHABLE_VALIDATION_EXIT_CODE=$(cat "${REACHABLE_VALIDATE_EXIT}")"
        echo "LOOP_EXTRACTION_EXIT_CODE=$(cat "${LOOPS_EXIT}")"
        echo "LOOP_DISCOVERY_MODEL=REACHABLE_ONLY"
        echo "LATER_VERIFICATION_MODEL=AUTHORITATIVE_ORIGINAL"
        echo "PROPERTY_EXTRACTION_EXIT_CODE=$(cat "${PROPERTIES_EXIT}")"
        echo "PRODUCTION_POLY_SUB_BODY_PRESENT=YES"
        echo "LOOP_BINDING=${LOOP_BINDING}"
        echo "REACHABLE_LOOP_COUNT=$(wc -l < "${ACTUAL_LOOPS}")"
        echo "REACHABLE_LOOP_IDS_BEGIN"
        cat "${ACTUAL_LOOPS}"
        echo "REACHABLE_LOOP_IDS_END"
        echo "FROZEN_UNWINDSET=${UNWINDSET}"
        echo "DISPLAYED_PROPERTY_COUNT=${PROPERTY_COUNT}"
        echo "THEOREM_OR_COVERAGE_SOLVER_EXECUTED=NO"
    } > "${CASE_SUMMARY}"

    {
        echo "------------------------------------------------------------"
        cat "${CASE_SUMMARY}"
        echo
    } >> "${SUMMARY}"
done

cat > "${FREEZE}" <<EOF
# SUB00N B4.5 — GOTO Preflight and Execution-Input Freeze

## Frozen identity

Repository commit:

\`d9613cf60de3132d32475c102d8c2781d84feb34\`

Parameter configuration:

\`\`\`text
MLK_CONFIG_PARAMETER_SET=768
MLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00n_b4
MLK_CONFIG_NO_ASM=1
MLK_CONFIG_CUSTOM_ZEROIZE=1
\`\`\`

## Authoritative source

\`${SOURCE_POLY}\`

SHA-256:

\`$(sha256sum "${SOURCE_POLY}" | awk '{print $1}')\`

## Cases built and inspected

1. Positive SUB-T4 theorem.
2. SUB-T4 reachability controls.
3. Stricter-upper expected-failure control.
4. Stricter-lower expected-failure control.

## Frozen inspection policy

Every GOTO model was:

- produced with \`goto-cc 6.9.0\`;
- validated with \`goto-instrument --validate-goto-binary\`;
- inspected for its symbol table;
- inspected for retained GOTO functions;
- checked for the production
  \`mlk_sub00n_b4_poly_sub\` body;
- inspected for exact loop identifiers;
- assigned a case-specific explicit unwindset;
- inspected for its property inventory.

No theorem, coverage or negative-control solver execution occurred.

## Unwinding rule

Every 256-coefficient loop is frozen at 257 unwindings, including the
terminating loop condition.

All cases retain unwinding assertions.

## Execution boundary

The next stage may execute only the four GOTO models frozen inside this
B4.5 package.

A later rebuild must receive a new version and may not silently replace
these models.
EOF

{
    echo
    echo "=== B4.5 SCIENTIFIC ACTION RECORD ==="
    echo "AUTHORITATIVE_GOTO_MODELS_CREATED=4"
    echo "REACHABLE_ONLY_INSPECTION_MODELS_CREATED=4"
    echo "TOTAL_GOTO_MODELS_VALIDATED=8"
    echo "PRODUCTION_POLY_SUB_BODY_CONFIRMED=4_OF_4"
    echo "V1_PREFLIGHT_FAILURE_CLASSIFICATION=SCRIPT_LOOP_DISCOVERY_DEFECT"
    echo "V1_THEOREM_OR_COVERAGE_SOLVER_EXECUTED=NO"
    echo "V2_REPAIR_RECORD_INCLUDED=YES"
    echo "EXACT_UNWINDSETS_FROZEN=4"
    echo "PROPERTY_INVENTORIES_EXTRACTED=4"
    echo "CBMC_THEOREM_SOLVER_EXECUTED=NO"
    echo "COVERAGE_SOLVER_EXECUTED=NO"
    echo "NEGATIVE_CONTROL_SOLVER_EXECUTED=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "FROZEN_HARNESS_MODIFIED=NO"
    echo "BATCH3_TOUCHED=NO"
    echo "BATCH3_PROCESS_ACTION=NONE"
    echo "SUB_T1_RESULT_MODIFIED=NO"
    echo "SUB_T2_RESULT_MODIFIED=NO"
    echo
    echo "SUB00N_B4_5_PREFLIGHT_VERDICT=PASS"
} >> "${SUMMARY}"

(
    cd "${STAGE}"

    find . -type f \
        ! -name "$(basename "${MANIFEST}")" \
        -print0 |
        sort -z |
        xargs -0 sha256sum
) > "${MANIFEST}"

find "${STAGE}" -type f -exec chmod a-w {} +
find "${STAGE}" -type d -exec chmod 0555 {} +

mv "${STAGE}" "${FINAL}"
trap - EXIT

echo
echo "============================================================"
echo "SUB00N / BATCH 4 — B4.5 PREFLIGHT COMPLETE"
echo "============================================================"
echo "FINAL=${FINAL}"
echo

cat "${FINAL}/SUB00N_B4_5_PREFLIGHT_SUMMARY.txt"

echo
echo "=== AUTHORITATIVE AND REACHABLE-ONLY MODEL HASHES ==="

find "${FINAL}/cases" -type f -name '*.goto' -print0 |
    sort -z |
    xargs -0 sha256sum

echo
echo "=== FROZEN UNWINDSETS ==="

for CASE_ID in ${CASE_IDS}; do
    echo "--- ${CASE_ID}"
    cat "${FINAL}/cases/${CASE_ID}/build/frozen_unwindset.txt"
done

echo
echo "=== FULL PREFLIGHT MANIFEST VERIFICATION ==="

(
    cd "${FINAL}"
    sha256sum -c "$(basename "${MANIFEST}")"
)

echo
echo "BATCH4_GOTO_PREFLIGHT_GATE=PASS"
echo "NO_THEOREM_OR_COVERAGE_SOLVER_EXECUTION_OCCURRED=YES"
echo "BATCH3_TOUCHED=NO"
