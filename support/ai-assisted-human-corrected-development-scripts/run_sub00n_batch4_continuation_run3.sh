#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

FAMILY="${B4}/frozen_harness_family_v1"
FAMILY_MANIFEST="${FAMILY}/SUB00N_B4_4_ARTIFACT_MANIFEST.sha256"

PREFLIGHT="${B4}/SUB00N_B4_5_GOTO_PREFLIGHT_MLKEM768"
PREFLIGHT_MANIFEST="${PREFLIGHT}/SUB00N_B4_5_PREFLIGHT_ARTIFACT_MANIFEST.sha256"

RUN1="${B4}/SUB00N_BATCH4_COMBINED_EXECUTION_MLKEM768_RUN1"
RUN1_PACKAGE="${RUN1}.tar.gz"
RUN1_PACKAGE_HASH="${RUN1_PACKAGE}.sha256"
RUN1_POSITIVE="${RUN1}/cases/POSITIVE/CASE_CLASSIFICATION.txt"

DIAGNOSTIC="${B4}/SUB00N_B4_6_RUN1_REACHABILITY_JSON_DIAGNOSTIC.txt"
DIAGNOSTIC_HASH="${DIAGNOSTIC}.sha256"

RUN2="${B4}/SUB00N_BATCH4_CONTINUATION_MLKEM768_RUN2"
RUN2_PACKAGE="${RUN2}.tar.gz"
RUN2_PACKAGE_HASH="${RUN2_PACKAGE}.sha256"
RUN2_WRAPPER="${RUN2}/wrapper_status.txt"

RESULT="${B4}/SUB00N_BATCH4_CONTINUATION_MLKEM768_RUN3"
PACKAGE="${RESULT}.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

SCRIPT_PATH="$(readlink -f "$0")"
CURRENT_STEP="initialization"
FINALIZED=0

EXPECTED_RUN1_PACKAGE_HASH="37063a635c00d56058b93221200cb444db332926752c4b2700e452848cc122b7"
EXPECTED_DIAGNOSTIC_HASH="f79938b31a3497d104492616ad90208ff22e4dab6541c620698748c5ff2aec56"
EXPECTED_RUN2_PACKAGE_HASH="82dc9b3574ee9dcf85d029f88682694873ae180250ed03713e5afedaf178912f"

REACHABILITY_MODEL="${PREFLIGHT}/cases/REACHABILITY/build/sub_t4_reachability_mlkem768.goto"
INVALID_UPPER_MODEL="${PREFLIGHT}/cases/INVALID_UPPER/build/sub_t4_invalid_upper_mlkem768.goto"
INVALID_LOWER_MODEL="${PREFLIGHT}/cases/INVALID_LOWER/build/sub_t4_invalid_lower_mlkem768.goto"

REACHABILITY_HARNESS="${FAMILY}/harnesses/sub_t4_reachability_harness.c"
INVALID_UPPER_HARNESS="${FAMILY}/harnesses/sub_t4_invalid_upper_harness.c"
INVALID_LOWER_HARNESS="${FAMILY}/harnesses/sub_t4_invalid_lower_harness.c"

REACHABILITY_UNWIND="${PREFLIGHT}/cases/REACHABILITY/build/frozen_unwindset.txt"
INVALID_UPPER_UNWIND="${PREFLIGHT}/cases/INVALID_UPPER/build/frozen_unwindset.txt"
INVALID_LOWER_UNWIND="${PREFLIGHT}/cases/INVALID_LOWER/build/frozen_unwindset.txt"

EXPECTED_REACHABILITY_MODEL_HASH="75edd882c1a5fb564ae95df2605aff65c38e5c6accbbd30741ce41e56ed8004a"
EXPECTED_INVALID_UPPER_MODEL_HASH="adc0a976bd7988e28e57ee8ac7b422a3dedf1cb76771473ab3177684d0135acf"
EXPECTED_INVALID_LOWER_MODEL_HASH="56c565ab02533cba48b181693c9309503142665236276d8687629d05b09e2455"

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

package_result()
{
    final_rc="$1"

    if [ "${FINALIZED}" -eq 1 ] || [ ! -d "${RESULT}" ]; then
        return
    fi

    FINALIZED=1

    {
        echo "FINAL_WRAPPER_EXIT_CODE=${final_rc}"
        echo "FINAL_STEP=${CURRENT_STEP}"
        echo "FINALIZED_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    } >"${RESULT}/wrapper_status.txt"

    (
        cd "${RESULT}"

        find . \
            -type f \
            ! -name 'RESULT_ARTIFACT_MANIFEST.sha256' \
            -print0 |
        sort -z |
        xargs -0 sha256sum
    ) >"${RESULT}/RESULT_ARTIFACT_MANIFEST.sha256"

    tar \
        -C "${B4}" \
        -czf "${PACKAGE}" \
        "$(basename "${RESULT}")"

    sha256sum "${PACKAGE}" >"${PACKAGE_HASH}"

    find "${RESULT}" -type f -exec chmod a-w {} +
    find "${RESULT}" -type d -exec chmod 0555 {} +

    echo
    echo "============================================================"
    echo "SUB00N / BATCH 4 — RUN3 PACKAGED RESULT"
    echo "============================================================"
    echo "RESULT=${RESULT}"
    echo "PACKAGE=${PACKAGE}"
    cat "${PACKAGE_HASH}"

    if [ -f "${RESULT}/BATCH4_FINAL_COMBINED_SUMMARY.txt" ]; then
        echo
        cat "${RESULT}/BATCH4_FINAL_COMBINED_SUMMARY.txt"
    fi

    echo
    echo "=== AVAILABLE CASE CLASSIFICATIONS ==="

    find "${RESULT}/cases" \
        -type f \
        -name 'CASE_CLASSIFICATION.txt' \
        -print |
    sort |
    while IFS= read -r file
    do
        echo
        echo "--- ${file}"
        cat "${file}"
    done
}

on_exit()
{
    rc=$?
    trap - EXIT
    package_result "${rc}"
    exit "${rc}"
}
trap on_exit EXIT

echo "============================================================"
echo "SUB00N / BATCH 4 — CONTINUATION RUN3"
echo "============================================================"
echo "ROOT=${ROOT}"
echo "RESULT=${RESULT}"
echo

# ------------------------------------------------------------------
# Pre-execution checks
# ------------------------------------------------------------------

CURRENT_STEP="pre-execution checks"

test ! -e "${RESULT}" ||
    fail "RUN3 result directory already exists: ${RESULT}"

test ! -e "${PACKAGE}" ||
    fail "RUN3 package already exists: ${PACKAGE}"

test ! -e "${PACKAGE_HASH}" ||
    fail "RUN3 package hash already exists: ${PACKAGE_HASH}"

for required in \
    "${FAMILY_MANIFEST}" \
    "${PREFLIGHT_MANIFEST}" \
    "${RUN1_PACKAGE}" \
    "${RUN1_PACKAGE_HASH}" \
    "${RUN1_POSITIVE}" \
    "${DIAGNOSTIC}" \
    "${DIAGNOSTIC_HASH}" \
    "${RUN2_PACKAGE}" \
    "${RUN2_PACKAGE_HASH}" \
    "${RUN2_WRAPPER}" \
    "${REACHABILITY_MODEL}" \
    "${INVALID_UPPER_MODEL}" \
    "${INVALID_LOWER_MODEL}" \
    "${REACHABILITY_HARNESS}" \
    "${INVALID_UPPER_HARNESS}" \
    "${INVALID_LOWER_HARNESS}" \
    "${REACHABILITY_UNWIND}" \
    "${INVALID_UPPER_UNWIND}" \
    "${INVALID_LOWER_UNWIND}"
do
    test -f "${required}" ||
        fail "required frozen artefact missing: ${required}"
done

for tool in \
    cbmc \
    goto-instrument \
    timeout \
    sha256sum \
    python3 \
    tar \
    gzip \
    grep \
    awk \
    sort \
    readlink
do
    command -v "${tool}" >/dev/null 2>&1 ||
        fail "required tool unavailable: ${tool}"
done

test -x /usr/bin/time ||
    fail "GNU time unavailable"

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

mkdir -p "${RESULT}/cases" "${RESULT}/frozen_inputs"
cp "${SCRIPT_PATH}" "${RESULT}/executed_runner.sh"

# ------------------------------------------------------------------
# Parent integrity and scientific bindings
# ------------------------------------------------------------------

CURRENT_STEP="parent integrity"

{
    echo "=== B4.4 FROZEN HARNESS FAMILY ==="

    (
        cd "${FAMILY}"
        sha256sum -c "$(basename "${FAMILY_MANIFEST}")"
    )

    echo
    echo "=== B4.5 GOTO PREFLIGHT ==="

    (
        cd "${PREFLIGHT}"
        sha256sum -c "$(basename "${PREFLIGHT_MANIFEST}")"
    )

    echo
    echo "=== RUN1 PACKAGE ==="
    sha256sum -c "${RUN1_PACKAGE_HASH}"

    echo
    echo "=== RUN1 DIAGNOSTIC ==="
    sha256sum -c "${DIAGNOSTIC_HASH}"

    echo
    echo "=== RUN2 PACKAGE ==="
    sha256sum -c "${RUN2_PACKAGE_HASH}"
} >"${RESULT}/parent_integrity_verification.txt" 2>&1

echo "PARENT_INTEGRITY=PASS"

CURRENT_STEP="scientific parent binding"

{
    check_hash \
        "${RUN1_PACKAGE}" \
        "${EXPECTED_RUN1_PACKAGE_HASH}" \
        "RUN1_PACKAGE"

    check_hash \
        "${DIAGNOSTIC}" \
        "${EXPECTED_DIAGNOSTIC_HASH}" \
        "RUN1_DIAGNOSTIC"

    check_hash \
        "${RUN2_PACKAGE}" \
        "${EXPECTED_RUN2_PACKAGE_HASH}" \
        "RUN2_PACKAGE"

    check_hash \
        "${REACHABILITY_MODEL}" \
        "${EXPECTED_REACHABILITY_MODEL_HASH}" \
        "REACHABILITY_MODEL"

    check_hash \
        "${INVALID_UPPER_MODEL}" \
        "${EXPECTED_INVALID_UPPER_MODEL_HASH}" \
        "INVALID_UPPER_MODEL"

    check_hash \
        "${INVALID_LOWER_MODEL}" \
        "${EXPECTED_INVALID_LOWER_MODEL_HASH}" \
        "INVALID_LOWER_MODEL"

    grep -Fxq \
        'CLASSIFICATION=PASS_351_OF_351' \
        "${RUN1_POSITIVE}" ||
        fail "RUN1 positive theorem binding failed"

    grep -Fxq \
        'SUB_T4_REACHABILITY=UNCLASSIFIED_CAPTURE_FORMAT_FAILURE' \
        "${DIAGNOSTIC}" ||
        fail "RUN1 diagnostic binding failed"

    grep -Fxq \
        'FINAL_STEP=coverage compatibility policy' \
        "${RUN2_WRAPPER}" ||
        fail "RUN2 failure-step binding failed"

    echo "RUN1_POSITIVE_THEOREM=PASS_351_OF_351"
    echo "RUN1_REACHABILITY_ATTEMPT=USAGE_ERROR_NO_RESULT"
    echo "RUN2_FAILURE=PRE_EXECUTION_HELP_TEXT_GATE"
    echo "RUN2_CBMC_CASES_EXECUTED=0"
    echo "RUN1_AND_RUN2_PRESERVED_UNCHANGED=YES"
} >"${RESULT}/scientific_parent_binding.txt"

echo "SCIENTIFIC_PARENT_BINDING=PASS"

# ------------------------------------------------------------------
# Environment and correction disclosure
# ------------------------------------------------------------------

CURRENT_STEP="environment recording"

{
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "HOST=$(uname -a)"
    echo "CBMC=$(cbmc --version 2>&1 | head -n 1)"
    echo "GOTO_INSTRUMENT=$(goto-instrument --version 2>&1 | head -n 1)"
    echo "SCRIPT=${SCRIPT_PATH}"
    echo "SCRIPT_SHA256=$(sha256sum "${SCRIPT_PATH}" | awk '{print $1}')"
} >"${RESULT}/environment.txt"

cbmc --help >"${RESULT}/cbmc_help.txt" 2>&1

cat >"${RESULT}/RUN3_CORRECTION_RECORD.md" <<'EOF'
# SUB00N Batch 4 — RUN3 Correction Record

## RUN1

The positive SUB-T4 theorem passed 351 of 351 properties.

The reachability command was rejected during option processing because
coverage mode was combined with explicit unwinding assertions.

No reachability property result was generated.

## RUN2

RUN2 passed its parent-integrity and scientific-parent-binding gates.

It stopped before executing any CBMC case because its runner required an
exact sentence to appear in local `cbmc --help` output.

That wording check was unnecessarily brittle and is removed in RUN3.

## RUN3 policy

RUN3 establishes actual compatibility by executing:

    --cover cover --show-properties

against the frozen reachability model without invoking a solver.

Coverage execution omits an explicit unwinding-assertion option.

Loop completeness and safety are separately established first through a
333-property companion verification with explicit unwinding assertions.

No frozen parent, production source, harness, RUN1 result, RUN2 result or
Batch-3 artefact is modified.
EOF

# ------------------------------------------------------------------
# Classifier
# ------------------------------------------------------------------

CLASSIFIER="${RESULT}/classify_run3_result.py"

cat >"${CLASSIFIER}" <<'PY'
import json
import sys
from pathlib import Path

if len(sys.argv) != 7:
    raise SystemExit(
        "usage: classifier JSON EXIT SUMMARY MODE EXPECTED_TOTAL MARKER"
    )

json_path = Path(sys.argv[1])
exit_path = Path(sys.argv[2])
summary_path = Path(sys.argv[3])
mode = sys.argv[4]
expected_total = int(sys.argv[5])
marker = sys.argv[6]

raw_exit = int(exit_path.read_text().strip())
text = json_path.read_text(errors="replace")

try:
    data = json.loads(text)
except json.JSONDecodeError as exc:
    summary_path.write_text(
        "CLASSIFICATION=FAIL_INVALID_JSON\n"
        f"RAW_CBMC_EXIT_CODE={raw_exit}\n"
        f"JSON_SIZE_BYTES={json_path.stat().st_size}\n"
        f"JSON_ERROR={exc}\n"
    )
    raise SystemExit(1)

results = []


def walk(value):
    if isinstance(value, dict):
        if "status" in value and (
            "property" in value
            or "description" in value
            or "goal" in value
        ):
            results.append(value)

        for child in value.values():
            walk(child)

    elif isinstance(value, list):
        for child in value:
            walk(child)


walk(data)


def item_status(item):
    return str(item.get("status", "")).upper()


def item_blob(item):
    return json.dumps(item, sort_keys=True).lower()


failure_statuses = {
    "FAILURE",
    "FAILED",
    "ERROR",
    "UNSATISFIED",
    "UNCOVERED",
}

successes = [
    item for item in results
    if item_status(item) == "SUCCESS"
]

failures = [
    item for item in results
    if item_status(item) in failure_statuses
]

unwinding_failures = [
    item for item in failures
    if "unwind" in item_blob(item)
]

lines = [
    f"MODE={mode}",
    f"RAW_CBMC_EXIT_CODE={raw_exit}",
    f"TOTAL_RESULT_ENTRIES={len(results)}",
    f"SUCCESS_STATUS_COUNT={len(successes)}",
    f"FAILURE_LIKE_STATUS_COUNT={len(failures)}",
    f"UNWINDING_FAILURE_COUNT={len(unwinding_failures)}",
]

passed = False

if mode == "ALL_SUCCESS":
    passed = (
        raw_exit == 0
        and len(results) == expected_total
        and len(successes) == expected_total
        and len(failures) == 0
        and len(unwinding_failures) == 0
    )

    lines.append(f"EXPECTED_TOTAL_PROPERTIES={expected_total}")
    lines.append(
        "CLASSIFICATION="
        + (
            f"PASS_{expected_total}_OF_{expected_total}"
            if passed
            else "FAIL_ALL_SUCCESS_CASE"
        )
    )

elif mode == "COVERAGE":
    goals = [
        "has_maximum_positive",
        "has_maximum_negative",
        "has_zero",
        "has_interior_positive",
        "has_interior_negative",
    ]

    accepted_statuses = {
        "SATISFIED",
        "SUCCESS",
        "COVERED",
        "REACHED",
    }

    reached = 0

    for goal in goals:
        matching = [
            item for item in results
            if goal in item_blob(item)
        ]

        statuses = sorted({
            item_status(item)
            for item in matching
        })

        goal_reached = any(
            status in accepted_statuses
            for status in statuses
        )

        reached += int(goal_reached)

        lines.append(
            f"COVER_GOAL_{goal}="
            + ("REACHED" if goal_reached else "NOT_REACHED")
        )

        lines.append(
            f"COVER_GOAL_{goal}_STATUSES="
            + ",".join(statuses)
        )

    passed = (
        raw_exit == 0
        and reached == 5
        and len(failures) == 0
    )

    lines.append("COVER_GOALS_EXPECTED=5")
    lines.append(f"COVER_GOALS_REACHED={reached}")
    lines.append(
        "CLASSIFICATION="
        + (
            "PASS_5_OF_5_REACHED"
            if passed
            else "FAIL_COVERAGE"
        )
    )

elif mode == "EXPECTED_SINGLE_FAILURE":
    marker_failures = [
        item for item in failures
        if marker.lower() in item_blob(item)
    ]

    passed = (
        raw_exit != 0
        and len(results) == expected_total
        and len(successes) == expected_total - 1
        and len(failures) == 1
        and len(marker_failures) == 1
        and len(unwinding_failures) == 0
    )

    lines.append(f"EXPECTED_TOTAL_PROPERTIES={expected_total}")
    lines.append(f"EXPECTED_FAILURE_MARKER={marker}")
    lines.append(
        f"EXPECTED_MARKER_FAILURE_COUNT={len(marker_failures)}"
    )

    for index, item in enumerate(failures, 1):
        lines.append(
            f"FAILURE_{index}_PROPERTY="
            f"{item.get('property', '<unknown>')}"
        )
        lines.append(
            f"FAILURE_{index}_DESCRIPTION="
            f"{item.get('description', '')}"
        )
        lines.append(
            f"FAILURE_{index}_STATUS={item_status(item)}"
        )

    lines.append(
        "CLASSIFICATION="
        + (
            "KILLED_BY_INTENDED_WITNESS"
            if passed
            else "FAIL_NEGATIVE_CONTROL"
        )
    )

else:
    lines.append("CLASSIFICATION=FAIL_UNKNOWN_MODE")

summary_path.write_text("\n".join(lines) + "\n")
raise SystemExit(0 if passed else 1)
PY

# ------------------------------------------------------------------
# Generic preparation and verification
# ------------------------------------------------------------------

prepare_case()
{
    case_name="$1"
    model="$2"
    harness="$3"
    unwind_file="$4"

    case_dir="${RESULT}/cases/${case_name}"
    frozen="${case_dir}/frozen_inputs"

    mkdir -p "${frozen}"

    cp "${model}" "${frozen}/"
    cp "${harness}" "${frozen}/"
    cp "${unwind_file}" "${frozen}/"

    set +e
    goto-instrument \
        --validate-goto-binary \
        "${model}" \
        >"${case_dir}/final_model_validation.txt" \
        2>&1
    validation_rc=$?
    set -e

    printf '%s\n' "${validation_rc}" \
        >"${case_dir}/final_model_validation_exit_code.txt"

    if [ "${validation_rc}" -ne 0 ]; then
        fail "${case_name}: final GOTO validation failed"
    fi

    find "${frozen}" -type f -exec chmod a-w {} +
}

run_normal_case()
{
    case_name="$1"
    model="$2"
    harness="$3"
    unwind_file="$4"
    expected_total="$5"
    mode="$6"
    marker="$7"

    case_dir="${RESULT}/cases/${case_name}"
    unwindset="$(cat "${unwind_file}")"

    prepare_case \
        "${case_name}" \
        "${model}" \
        "${harness}" \
        "${unwind_file}"

    command=(
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
        "${case_dir}/cbmc_command.txt" \
        "${command[@]}"

    echo
    echo "============================================================"
    echo "RUNNING ${case_name}"
    echo "============================================================"
    echo "MODEL=${model}"
    echo "UNWINDSET=${unwindset}"
    echo "UNWINDING_ASSERTIONS=ENABLED"
    echo

    set +e
    /usr/bin/time \
        -v \
        -o "${case_dir}/resource_usage.txt" \
        timeout \
        --signal=TERM \
        --kill-after=60s \
        21600s \
        "${command[@]}" \
        >"${case_dir}/cbmc_result.json" \
        2>"${case_dir}/cbmc_stderr.txt"
    cbmc_rc=$?
    set -e

    printf '%s\n' "${cbmc_rc}" \
        >"${case_dir}/cbmc_exit_code.txt"

    if ! python3 \
        "${CLASSIFIER}" \
        "${case_dir}/cbmc_result.json" \
        "${case_dir}/cbmc_exit_code.txt" \
        "${case_dir}/CASE_CLASSIFICATION.txt" \
        "${mode}" \
        "${expected_total}" \
        "${marker}"
    then
        cat "${case_dir}/CASE_CLASSIFICATION.txt" >&2 || true
        fail "${case_name}: result classification failed"
    fi

    cat "${case_dir}/CASE_CLASSIFICATION.txt"
}

# ------------------------------------------------------------------
# 1. Reachability companion proof
# ------------------------------------------------------------------

CURRENT_STEP="reachability companion proof"

run_normal_case \
    "REACHABILITY_COMPANION_PROOF" \
    "${REACHABILITY_MODEL}" \
    "${REACHABILITY_HARNESS}" \
    "${REACHABILITY_UNWIND}" \
    "333" \
    "ALL_SUCCESS" \
    "NONE"

# ------------------------------------------------------------------
# 2. Actual coverage-option compatibility preflight
# ------------------------------------------------------------------

CURRENT_STEP="coverage command compatibility preflight"

COVERAGE_DIR="${RESULT}/cases/REACHABILITY_COVERAGE"

prepare_case \
    "REACHABILITY_COVERAGE" \
    "${REACHABILITY_MODEL}" \
    "${REACHABILITY_HARNESS}" \
    "${REACHABILITY_UNWIND}"

REACHABILITY_UNWINDSET="$(cat "${REACHABILITY_UNWIND}")"

INVENTORY_COMMAND=(
    cbmc
    "${REACHABILITY_MODEL}"
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
    --unwindset "${REACHABILITY_UNWINDSET}"
    --cover cover
    --show-properties
)

write_command \
    "${COVERAGE_DIR}/coverage_compatibility_command.txt" \
    "${INVENTORY_COMMAND[@]}"

set +e
"${INVENTORY_COMMAND[@]}" \
    >"${COVERAGE_DIR}/coverage_property_inventory.txt" \
    2>"${COVERAGE_DIR}/coverage_property_inventory_stderr.txt"
inventory_rc=$?
set -e

printf '%s\n' "${inventory_rc}" \
    >"${COVERAGE_DIR}/coverage_property_inventory_exit_code.txt"

if [ "${inventory_rc}" -ne 0 ]; then
    echo "=== COVERAGE PREFLIGHT STDERR ===" >&2
    cat "${COVERAGE_DIR}/coverage_property_inventory_stderr.txt" >&2 || true
    fail "coverage command compatibility preflight failed"
fi

for goal in \
    has_maximum_positive \
    has_maximum_negative \
    has_zero \
    has_interior_positive \
    has_interior_negative
do
    grep -Fq \
        "${goal}" \
        "${COVERAGE_DIR}/coverage_property_inventory.txt" ||
        fail "coverage inventory is missing goal: ${goal}"
done

{
    echo "COMMAND_EXIT_CODE=${inventory_rc}"
    echo "SOLVER_EXECUTED=NO"
    echo "EXPLICIT_UNWINDING_ASSERTIONS_PRESENT=NO"
    echo "UNWINDSET_PRESENT=YES"
    echo "GOAL_has_maximum_positive=PRESENT"
    echo "GOAL_has_maximum_negative=PRESENT"
    echo "GOAL_has_zero=PRESENT"
    echo "GOAL_has_interior_positive=PRESENT"
    echo "GOAL_has_interior_negative=PRESENT"
    echo "COVERAGE_COMMAND_COMPATIBILITY=PASS"
} >"${COVERAGE_DIR}/COVERAGE_COMPATIBILITY_CLASSIFICATION.txt"

echo "COVERAGE_COMMAND_COMPATIBILITY=PASS"

# ------------------------------------------------------------------
# 3. Reachability coverage
# ------------------------------------------------------------------

CURRENT_STEP="reachability coverage"

COVERAGE_COMMAND=(
    cbmc
    "${REACHABILITY_MODEL}"
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
    --unwindset "${REACHABILITY_UNWINDSET}"
    --slice-formula
    --sat-solver minisat2
    --trace
    --json-ui
    --cover cover
)

write_command \
    "${COVERAGE_DIR}/cbmc_command.txt" \
    "${COVERAGE_COMMAND[@]}"

echo
echo "============================================================"
echo "RUNNING REACHABILITY_COVERAGE"
echo "============================================================"
echo "MODEL=${REACHABILITY_MODEL}"
echo "UNWINDSET=${REACHABILITY_UNWINDSET}"
echo "EXPLICIT_UNWINDING_ASSERTIONS=OMITTED_FOR_COVERAGE_MODE"
echo "COMPANION_PROOF=PASS_333_OF_333"
echo

set +e
/usr/bin/time \
    -v \
    -o "${COVERAGE_DIR}/resource_usage.txt" \
    timeout \
    --signal=TERM \
    --kill-after=60s \
    21600s \
    "${COVERAGE_COMMAND[@]}" \
    >"${COVERAGE_DIR}/cbmc_result.json" \
    2>"${COVERAGE_DIR}/cbmc_stderr.txt"
coverage_rc=$?
set -e

printf '%s\n' "${coverage_rc}" \
    >"${COVERAGE_DIR}/cbmc_exit_code.txt"

if ! python3 \
    "${CLASSIFIER}" \
    "${COVERAGE_DIR}/cbmc_result.json" \
    "${COVERAGE_DIR}/cbmc_exit_code.txt" \
    "${COVERAGE_DIR}/CASE_CLASSIFICATION.txt" \
    "COVERAGE" \
    "5" \
    "NONE"
then
    cat "${COVERAGE_DIR}/CASE_CLASSIFICATION.txt" >&2 || true
    fail "reachability coverage classification failed"
fi

cat "${COVERAGE_DIR}/CASE_CLASSIFICATION.txt"

# ------------------------------------------------------------------
# 4. Upper negative control
# ------------------------------------------------------------------

CURRENT_STEP="upper negative control"

run_normal_case \
    "INVALID_UPPER" \
    "${INVALID_UPPER_MODEL}" \
    "${INVALID_UPPER_HARNESS}" \
    "${INVALID_UPPER_UNWIND}" \
    "328" \
    "EXPECTED_SINGLE_FAILURE" \
    "SUB_T4_NC1_INTENDED_FAILURE"

# ------------------------------------------------------------------
# 5. Lower negative control
# ------------------------------------------------------------------

CURRENT_STEP="lower negative control"

run_normal_case \
    "INVALID_LOWER" \
    "${INVALID_LOWER_MODEL}" \
    "${INVALID_LOWER_HARNESS}" \
    "${INVALID_LOWER_UNWIND}" \
    "328" \
    "EXPECTED_SINGLE_FAILURE" \
    "SUB_T4_NC2_INTENDED_FAILURE"

# ------------------------------------------------------------------
# Final combined Batch-4 result
# ------------------------------------------------------------------

CURRENT_STEP="final combined Batch-4 result"

cat >"${RESULT}/BATCH4_FINAL_COMBINED_SUMMARY.txt" <<'EOF'
============================================================
SUB00N / BATCH 4 — FINAL COMBINED RESULT
============================================================

RUN1_POSITIVE_THEOREM=PASS_351_OF_351

RUN1_REACHABILITY_ATTEMPT=USAGE_ERROR_NO_SCIENTIFIC_RESULT
RUN2_ATTEMPT=PRE_EXECUTION_HELP_TEXT_GATE_NO_CASE_EXECUTION

RUN3_REACHABILITY_COMPANION_PROOF=PASS_333_OF_333
RUN3_REACHABILITY_COVERAGE=PASS_5_OF_5_REACHED
RUN3_INVALID_UPPER=KILLED_BY_INTENDED_WITNESS
RUN3_INVALID_LOWER=KILLED_BY_INTENDED_WITNESS

SUB_T4_CANONICAL_INPUT_DOMAIN=[0,3329)
SUB_T4_PROVED_RAW_OUTPUT_RANGE=[-3328,3328]
SUB_T4_REPRESENTABILITY_ASSUMED=NO
SUB_T4_REPRESENTABILITY_PROVED=YES
SUB_T4_PRODUCTION_EXACTNESS_PROVED=YES
SUB_T4_INPUT_B_UNCHANGED_PROVED=YES

AUTHORITATIVE_MODE=MODE_A
PRODUCTION_BODY_EXECUTION=YES
FUNCTION_CONTRACT_ABSTRACTION=NO
LOOP_CONTRACT_ABSTRACTION=NO

POSITIVE_THEOREM_UNWINDING_ASSERTIONS=ENABLED
REACHABILITY_COMPANION_UNWINDING_ASSERTIONS=ENABLED
COVERAGE_EXPLICIT_UNWINDING_ASSERTIONS=OMITTED
COVERAGE_IDENTICAL_UNWINDSET_RETAINED=YES
COVERAGE_LOOP_COMPLETENESS_SUPPORTED_BY_COMPANION_PROOF=YES
NEGATIVE_CONTROL_UNWINDING_ASSERTIONS=ENABLED

PRODUCTION_SOURCE_MODIFIED=NO
FROZEN_HARNESS_MODIFIED=NO
RUN1_MODIFIED=NO
RUN2_MODIFIED=NO
BATCH3_TOUCHED=NO
SUB_T1_RESULT_MODIFIED=NO
SUB_T2_RESULT_MODIFIED=NO

NOVELTY_CLAIM=WORLD_FIRST_NOT_CLAIMED
SAFE_DESCRIPTION=INDEPENDENTLY_AUTHORED_CANONICAL_DOMAIN_BRIDGE_THEOREM_AND_CBMC_ARTEFACT

BATCH4_COMBINED_VERDICT=PASS
EOF

echo
cat "${RESULT}/BATCH4_FINAL_COMBINED_SUMMARY.txt"

exit 0
