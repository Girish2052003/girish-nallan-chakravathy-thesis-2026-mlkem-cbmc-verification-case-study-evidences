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
RUN1_MANIFEST="${RUN1}/RESULT_ARTIFACT_MANIFEST.sha256"
RUN1_PACKAGE="${RUN1}.tar.gz"
RUN1_PACKAGE_HASH="${RUN1_PACKAGE}.sha256"
RUN1_POSITIVE="${RUN1}/cases/POSITIVE/CASE_CLASSIFICATION.txt"

DIAGNOSTIC="${B4}/SUB00N_B4_6_RUN1_REACHABILITY_JSON_DIAGNOSTIC.txt"
DIAGNOSTIC_HASH="${DIAGNOSTIC}.sha256"

REPAIR_RECORD="${B4}/SUB00N_B4_5_V1_FAILURE_AND_V2_REPAIR_RECORD.txt"
REPAIR_RECORD_HASH="${REPAIR_RECORD}.sha256"

RESULT="${B4}/SUB00N_BATCH4_CONTINUATION_MLKEM768_RUN2"
PACKAGE="${RESULT}.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

SCRIPT_PATH="$(readlink -f "$0")"
CURRENT_STEP="initialization"
FINALIZED=0

EXPECTED_RUN1_PACKAGE_HASH="37063a635c00d56058b93221200cb444db332926752c4b2700e452848cc122b7"
EXPECTED_DIAGNOSTIC_HASH="f79938b31a3497d104492616ad90208ff22e4dab6541c620698748c5ff2aec56"

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

    echo "${label}_PATH=${file}"
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
    echo "SUB00N / BATCH 4 — RUN2 PACKAGED RESULT"
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
    while IFS= read -r classification
    do
        echo
        echo "--- ${classification}"
        cat "${classification}"
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
echo "SUB00N / BATCH 4 — CONTINUATION RUN2"
echo "============================================================"
echo "ROOT=${ROOT}"
echo "RESULT=${RESULT}"
echo

# ------------------------------------------------------------------
# Pre-execution gates
# ------------------------------------------------------------------

CURRENT_STEP="pre-execution existence checks"

test ! -e "${RESULT}" ||
    fail "RUN2 result directory already exists: ${RESULT}"

test ! -e "${PACKAGE}" ||
    fail "RUN2 package already exists: ${PACKAGE}"

test ! -e "${PACKAGE_HASH}" ||
    fail "RUN2 package hash already exists: ${PACKAGE_HASH}"

for required in \
    "${FAMILY_MANIFEST}" \
    "${PREFLIGHT_MANIFEST}" \
    "${RUN1_MANIFEST}" \
    "${RUN1_PACKAGE}" \
    "${RUN1_PACKAGE_HASH}" \
    "${RUN1_POSITIVE}" \
    "${DIAGNOSTIC}" \
    "${DIAGNOSTIC_HASH}" \
    "${REPAIR_RECORD}" \
    "${REPAIR_RECORD_HASH}" \
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
    sed \
    awk \
    sort \
    readlink
do
    command -v "${tool}" >/dev/null 2>&1 ||
        fail "required tool unavailable: ${tool}"
done

test -x /usr/bin/time ||
    fail "GNU time unavailable at /usr/bin/time"

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
# Parent integrity
# ------------------------------------------------------------------

CURRENT_STEP="parent integrity verification"

{
    echo "=== B4.4 HARNESS FAMILY ==="

    (
        cd "${FAMILY}"
        sha256sum -c "$(basename "${FAMILY_MANIFEST}")"
    )

    echo
    echo "=== B4.5 PREFLIGHT ==="

    (
        cd "${PREFLIGHT}"
        sha256sum -c "$(basename "${PREFLIGHT_MANIFEST}")"
    )

    echo
    echo "=== RUN1 RESULT DIRECTORY ==="

    (
        cd "${RUN1}"
        sha256sum -c "$(basename "${RUN1_MANIFEST}")"
    )

    echo
    echo "=== RUN1 PACKAGE ==="

    sha256sum -c "${RUN1_PACKAGE_HASH}"

    echo
    echo "=== B4.6 DIAGNOSTIC ==="

    sha256sum -c "${DIAGNOSTIC_HASH}"

    echo
    echo "=== B4.5 REPAIR RECORD ==="

    sha256sum -c "${REPAIR_RECORD_HASH}"
} >"${RESULT}/parent_integrity_verification.txt" 2>&1

echo "PARENT_MANIFEST_INTEGRITY=PASS"

CURRENT_STEP="scientific parent binding"

{
    echo "============================================================"
    echo "RUN2 SCIENTIFIC PARENT BINDING"
    echo "============================================================"
    echo

    check_hash \
        "${RUN1_PACKAGE}" \
        "${EXPECTED_RUN1_PACKAGE_HASH}" \
        "RUN1_PACKAGE"

    echo

    check_hash \
        "${DIAGNOSTIC}" \
        "${EXPECTED_DIAGNOSTIC_HASH}" \
        "RUN1_DIAGNOSTIC"

    echo

    check_hash \
        "${REACHABILITY_MODEL}" \
        "${EXPECTED_REACHABILITY_MODEL_HASH}" \
        "REACHABILITY_MODEL"

    echo

    check_hash \
        "${INVALID_UPPER_MODEL}" \
        "${EXPECTED_INVALID_UPPER_MODEL_HASH}" \
        "INVALID_UPPER_MODEL"

    echo

    check_hash \
        "${INVALID_LOWER_MODEL}" \
        "${EXPECTED_INVALID_LOWER_MODEL_HASH}" \
        "INVALID_LOWER_MODEL"

    echo

    grep -Fxq \
        'CLASSIFICATION=PASS_351_OF_351' \
        "${RUN1_POSITIVE}" ||
        fail "RUN1 positive theorem is not classified 351/351"

    echo "RUN1_POSITIVE_THEOREM_BINDING=PASS_351_OF_351"

    grep -Fxq \
        'SUB_T4_REACHABILITY=UNCLASSIFIED_CAPTURE_FORMAT_FAILURE' \
        "${DIAGNOSTIC}" ||
        fail "RUN1 diagnostic classification is unexpected"

    grep -Fxq \
        'BATCH4_OVERALL=INCOMPLETE_NOT_FAILED' \
        "${DIAGNOSTIC}" ||
        fail "RUN1 overall diagnostic classification is unexpected"

    echo "RUN1_REACHABILITY_FAILURE_CLASSIFICATION=USAGE_ERROR_NOT_SCIENTIFIC_RESULT"
    echo "RUN1_PRESERVED_UNCHANGED=YES"
} >"${RESULT}/scientific_parent_binding.txt"

echo "SCIENTIFIC_PARENT_BINDING=PASS"

# ------------------------------------------------------------------
# Environment and explicit CBMC coverage policy
# ------------------------------------------------------------------

CURRENT_STEP="coverage compatibility policy"

{
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "HOST=$(uname -a)"
    echo "CBMC=$(cbmc --version 2>&1 | head -n 1)"
    echo "GOTO_INSTRUMENT=$(goto-instrument --version 2>&1 | head -n 1)"
    echo "SCRIPT=${SCRIPT_PATH}"
    echo "SCRIPT_SHA256=$(sha256sum "${SCRIPT_PATH}" | awk '{print $1}')"
} >"${RESULT}/environment.txt"

cbmc --help >"${RESULT}/cbmc_help.txt" 2>&1

{
    echo "============================================================"
    echo "CBMC COVERAGE / UNWINDING POLICY"
    echo "============================================================"
    echo

    grep -n -A3 -B2 \
        -- '--unwinding-assertions' \
        "${RESULT}/cbmc_help.txt" ||
        true

    echo

    grep -n -A3 -B2 \
        -- '--cover CC' \
        "${RESULT}/cbmc_help.txt" ||
        true
} >"${RESULT}/coverage_option_policy.txt"

grep -q \
    'cannot be used with --cover' \
    "${RESULT}/cbmc_help.txt" ||
    fail "local CBMC help did not disclose coverage/unwinding incompatibility"

grep -q \
    'cover.*create test-suite\|coverage criterion' \
    "${RESULT}/cbmc_help.txt" ||
    fail "local CBMC help did not disclose the coverage option"

cat >"${RESULT}/RUN2_EXECUTION_BOUNDARY.md" <<'EOF'
# SUB00N Batch 4 — RUN2 Execution Boundary

## Preserved evidence

RUN1 is not modified.

Its positive SUB-T4 theorem remains accepted at 351/351.

Its attempted coverage command produced no coverage result because CBMC
rejected the explicit combination of --cover and
--unwinding-assertions during command-line processing.

## RUN2 correction

RUN2 separates two obligations:

1. Reachability companion verification

   The unchanged reachability harness and authoritative GOTO model are
   checked normally with explicit unwinding assertions.

   This establishes:

   - adequate loop unwinding;
   - safety-property success;
   - production subtraction exactness;
   - frame assertions.

2. Coverage satisfiability

   The same unchanged authoritative model and identical unwindset are
   checked using:

       --no-unwinding-assertions --cover cover

   This is required by CBMC's coverage mode.

Coverage success is accepted only when the companion verification has
already passed.

## Negative controls

The stricter upper and lower bounds are executed normally with explicit
unwinding assertions.

Each control must produce exactly one intended property failure and no
unwinding failure.

## Isolation

No production source, frozen harness, RUN1 artefact or Batch-3 artefact
may be modified.
EOF

echo "COVERAGE_COMPATIBILITY_POLICY=PASS"

# ------------------------------------------------------------------
# Result classifier
# ------------------------------------------------------------------

CLASSIFIER="${RESULT}/classify_run2_result.py"

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
raw_text = json_path.read_text(errors="replace")

try:
    data = json.loads(raw_text)
except json.JSONDecodeError as exc:
    summary_path.write_text(
        "CLASSIFICATION=FAIL_INVALID_JSON\n"
        f"RAW_CBMC_EXIT_CODE={raw_exit}\n"
        f"JSON_ERROR={exc}\n"
        f"JSON_SIZE_BYTES={json_path.stat().st_size}\n"
    )
    raise SystemExit(1)

results = []


def walk(value):
    if isinstance(value, dict):
        if "status" in value and (
            "property" in value or "description" in value
        ):
            results.append(value)

        for child in value.values():
            walk(child)

    elif isinstance(value, list):
        for child in value:
            walk(child)


walk(data)


def status(item):
    return str(item.get("status", "")).upper()


def blob(item):
    return json.dumps(item, sort_keys=True).lower()


successes = [
    item for item in results
    if status(item) == "SUCCESS"
]

failure_like_statuses = {
    "FAILURE",
    "FAILED",
    "ERROR",
    "UNSATISFIED",
    "UNCOVERED",
}

failures = [
    item for item in results
    if status(item) in failure_like_statuses
]

unwinding_failures = [
    item for item in failures
    if "unwind" in blob(item)
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
    accepted_coverage_statuses = {
        "SATISFIED",
        "SUCCESS",
        "COVERED",
        "REACHED",
    }

    covered = [
        item for item in results
        if status(item) in accepted_coverage_statuses
    ]

    lines.append(f"EXPECTED_COVERAGE_GOALS={expected_total}")
    lines.append(f"COVERED_GOAL_COUNT={len(covered)}")

    for index, item in enumerate(results, 1):
        lines.append(
            f"COVERAGE_RESULT_{index}_PROPERTY="
            f"{item.get('property', '<unknown>')}"
        )
        lines.append(
            f"COVERAGE_RESULT_{index}_DESCRIPTION="
            f"{item.get('description', '')}"
        )
        lines.append(
            f"COVERAGE_RESULT_{index}_STATUS={status(item)}"
        )

    passed = (
        raw_exit == 0
        and len(results) == expected_total
        and len(covered) == expected_total
        and len(failures) == 0
        and len(unwinding_failures) == 0
    )

    lines.append(
        "CLASSIFICATION="
        + (
            f"PASS_{expected_total}_OF_{expected_total}_REACHED"
            if passed
            else "FAIL_COVERAGE"
        )
    )

elif mode == "EXPECTED_SINGLE_FAILURE":
    marker_failures = [
        item for item in failures
        if marker.lower() in blob(item)
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
            f"FAILURE_{index}_STATUS={status(item)}"
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
# Common model validation and input freezing
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

run_normal_verification()
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
# 1. Reachability companion verification
# ------------------------------------------------------------------

CURRENT_STEP="reachability companion verification"

run_normal_verification \
    "REACHABILITY_COMPANION_PROOF" \
    "${REACHABILITY_MODEL}" \
    "${REACHABILITY_HARNESS}" \
    "${REACHABILITY_UNWIND}" \
    "333" \
    "ALL_SUCCESS" \
    "NONE"

# ------------------------------------------------------------------
# 2. Coverage property-inventory gate
# ------------------------------------------------------------------

CURRENT_STEP="coverage property inventory"

COVERAGE_DIR="${RESULT}/cases/REACHABILITY_COVERAGE"
mkdir -p "${COVERAGE_DIR}"

prepare_case \
    "REACHABILITY_COVERAGE" \
    "${REACHABILITY_MODEL}" \
    "${REACHABILITY_HARNESS}" \
    "${REACHABILITY_UNWIND}"

REACHABILITY_UNWINDSET="$(cat "${REACHABILITY_UNWIND}")"

COVERAGE_INVENTORY_COMMAND=(
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
    --no-unwinding-assertions
    --unwindset "${REACHABILITY_UNWINDSET}"
    --cover cover
    --show-properties
)

write_command \
    "${COVERAGE_DIR}/coverage_property_inventory_command.txt" \
    "${COVERAGE_INVENTORY_COMMAND[@]}"

set +e
"${COVERAGE_INVENTORY_COMMAND[@]}" \
    >"${COVERAGE_DIR}/coverage_property_inventory.txt" \
    2>"${COVERAGE_DIR}/coverage_property_inventory_stderr.txt"
inventory_rc=$?
set -e

printf '%s\n' "${inventory_rc}" \
    >"${COVERAGE_DIR}/coverage_property_inventory_exit_code.txt"

if [ "${inventory_rc}" -ne 0 ]; then
    cat "${COVERAGE_DIR}/coverage_property_inventory_stderr.txt" >&2 || true
    fail "coverage property-inventory extraction failed"
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

COVERAGE_PROPERTY_COUNT="$(
    grep -Ec \
        '^Property[[:space:]]+|^\[[^]]+\]' \
        "${COVERAGE_DIR}/coverage_property_inventory.txt" ||
        true
)"

{
    echo "COVERAGE_PROPERTY_INVENTORY_EXIT_CODE=${inventory_rc}"
    echo "DISPLAYED_COVERAGE_PROPERTY_COUNT=${COVERAGE_PROPERTY_COUNT}"
    echo "GOAL_has_maximum_positive=PRESENT"
    echo "GOAL_has_maximum_negative=PRESENT"
    echo "GOAL_has_zero=PRESENT"
    echo "GOAL_has_interior_positive=PRESENT"
    echo "GOAL_has_interior_negative=PRESENT"
    echo "COVERAGE_INVENTORY_BINDING=PASS"
} >"${COVERAGE_DIR}/COVERAGE_INVENTORY_BINDING.txt"

echo "COVERAGE_PROPERTY_INVENTORY=PASS"

# ------------------------------------------------------------------
# 3. Coverage execution
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
    --no-unwinding-assertions
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
echo "UNWINDING_ASSERTIONS=DISABLED_AS_REQUIRED_BY_COVERAGE_MODE"
echo "COMPANION_UNWINDING_PROOF=PASS_333_OF_333"
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

run_normal_verification \
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

run_normal_verification \
    "INVALID_LOWER" \
    "${INVALID_LOWER_MODEL}" \
    "${INVALID_LOWER_HARNESS}" \
    "${INVALID_LOWER_UNWIND}" \
    "328" \
    "EXPECTED_SINGLE_FAILURE" \
    "SUB_T4_NC2_INTENDED_FAILURE"

# ------------------------------------------------------------------
# Final combined classification
# ------------------------------------------------------------------

CURRENT_STEP="final combined Batch-4 classification"

cat >"${RESULT}/BATCH4_FINAL_COMBINED_SUMMARY.txt" <<'EOF'
============================================================
SUB00N / BATCH 4 — FINAL COMBINED RESULT
============================================================

RUN1_POSITIVE_THEOREM=PASS_351_OF_351

RUN1_REACHABILITY_ATTEMPT=USAGE_ERROR_NO_SCIENTIFIC_RESULT
RUN1_REACHABILITY_ROOT_CAUSE=CBMC_COVER_AND_UNWINDING_ASSERTIONS_INCOMPATIBLE

RUN2_REACHABILITY_COMPANION_PROOF=PASS_333_OF_333
RUN2_REACHABILITY_COVERAGE=PASS_5_OF_5_REACHED
RUN2_INVALID_UPPER=KILLED_BY_INTENDED_WITNESS
RUN2_INVALID_LOWER=KILLED_BY_INTENDED_WITNESS

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
COVERAGE_UNWINDING_ASSERTIONS=DISABLED_AS_REQUIRED_BY_CBMC
COVERAGE_LOOP_COMPLETENESS_SUPPORTED_BY_COMPANION_PROOF=YES
NEGATIVE_CONTROL_UNWINDING_ASSERTIONS=ENABLED

PRODUCTION_SOURCE_MODIFIED=NO
FROZEN_HARNESS_MODIFIED=NO
RUN1_MODIFIED=NO
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
