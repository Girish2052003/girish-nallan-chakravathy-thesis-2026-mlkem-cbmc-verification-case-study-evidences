#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

FAMILY="${B4}/frozen_harness_family_v1"
FAMILY_MANIFEST="${FAMILY}/SUB00N_B4_4_ARTIFACT_MANIFEST.sha256"

PREFLIGHT="${B4}/SUB00N_B4_5_GOTO_PREFLIGHT_MLKEM768"
PREFLIGHT_MANIFEST="${PREFLIGHT}/SUB00N_B4_5_PREFLIGHT_ARTIFACT_MANIFEST.sha256"

COMPANION_PREFLIGHT="${B4}/SUB00N_B4_8_COVER_NEUTRAL_COMPANION_PREFLIGHT_MLKEM768"
COMPANION_MANIFEST="${COMPANION_PREFLIGHT}/SUB00N_B4_8_PREFLIGHT_ARTIFACT_MANIFEST.sha256"

RUN1="${B4}/SUB00N_BATCH4_COMBINED_EXECUTION_MLKEM768_RUN1"
RUN1_PACKAGE="${RUN1}.tar.gz"
RUN1_PACKAGE_HASH="${RUN1_PACKAGE}.sha256"
RUN1_POSITIVE="${RUN1}/cases/POSITIVE/CASE_CLASSIFICATION.txt"

RUN2="${B4}/SUB00N_BATCH4_CONTINUATION_MLKEM768_RUN2"
RUN2_PACKAGE="${RUN2}.tar.gz"
RUN2_PACKAGE_HASH="${RUN2_PACKAGE}.sha256"
RUN2_WRAPPER="${RUN2}/wrapper_status.txt"

RUN3="${B4}/SUB00N_BATCH4_CONTINUATION_MLKEM768_RUN3"
RUN3_PACKAGE="${RUN3}.tar.gz"
RUN3_PACKAGE_HASH="${RUN3_PACKAGE}.sha256"
RUN3_CLASSIFICATION="${RUN3}/cases/REACHABILITY_COMPANION_PROOF/CASE_CLASSIFICATION.txt"

DIAGNOSTIC_RUN1="${B4}/SUB00N_B4_6_RUN1_REACHABILITY_JSON_DIAGNOSTIC.txt"
DIAGNOSTIC_RUN1_HASH="${DIAGNOSTIC_RUN1}.sha256"

DIAGNOSTIC_RUN3="${B4}/SUB00N_B4_7_RUN3_COMPANION_FAILURE_DIAGNOSTIC.txt"
DIAGNOSTIC_RUN3_HASH="${DIAGNOSTIC_RUN3}.sha256"

RESULT="${B4}/SUB00N_BATCH4_FINAL_CONTINUATION_MLKEM768_RUN4"
PACKAGE="${RESULT}.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

SCRIPT_PATH="$(readlink -f "$0")"
CURRENT_STEP="initialization"
FINALIZED=0

EXPECTED_RUN1_PACKAGE_HASH="37063a635c00d56058b93221200cb444db332926752c4b2700e452848cc122b7"
EXPECTED_RUN2_PACKAGE_HASH="82dc9b3574ee9dcf85d029f88682694873ae180250ed03713e5afedaf178912f"
EXPECTED_RUN3_PACKAGE_HASH="99228f830dcc896303a3ae324576f368d0b64d22fe3aa0e9cfc626f4f709ae65"

EXPECTED_RUN1_DIAGNOSTIC_HASH="f79938b31a3497d104492616ad90208ff22e4dab6541c620698748c5ff2aec56"
EXPECTED_RUN3_DIAGNOSTIC_HASH="54f01061af4bd52bd8c9fa8d839406d054141445177ba8bd4ca4c8389cdc8cd6"

COMPANION_MODEL="${COMPANION_PREFLIGHT}/build/sub_t4_reachability_companion_mlkem768.goto"
COMPANION_UNWIND="${COMPANION_PREFLIGHT}/build/frozen_unwindset.txt"
COMPANION_HEADER="${COMPANION_PREFLIGHT}/support/sub00n_b4_cover_neutral_companion.h"
COMPANION_CORRECTION="${COMPANION_PREFLIGHT}/SUB00N_B4_8_COMPANION_CORRECTION_RECORD.md"

COVERAGE_MODEL="${PREFLIGHT}/cases/REACHABILITY/build/sub_t4_reachability_mlkem768.goto"
COVERAGE_UNWIND="${PREFLIGHT}/cases/REACHABILITY/build/frozen_unwindset.txt"

INVALID_UPPER_MODEL="${PREFLIGHT}/cases/INVALID_UPPER/build/sub_t4_invalid_upper_mlkem768.goto"
INVALID_UPPER_UNWIND="${PREFLIGHT}/cases/INVALID_UPPER/build/frozen_unwindset.txt"

INVALID_LOWER_MODEL="${PREFLIGHT}/cases/INVALID_LOWER/build/sub_t4_invalid_lower_mlkem768.goto"
INVALID_LOWER_UNWIND="${PREFLIGHT}/cases/INVALID_LOWER/build/frozen_unwindset.txt"

REACHABILITY_HARNESS="${FAMILY}/harnesses/sub_t4_reachability_harness.c"
INVALID_UPPER_HARNESS="${FAMILY}/harnesses/sub_t4_invalid_upper_harness.c"
INVALID_LOWER_HARNESS="${FAMILY}/harnesses/sub_t4_invalid_lower_harness.c"

EXPECTED_COMPANION_MODEL_HASH="ac465eee83cc47cf4d4a91120318fcdefdaf0dc095b1078648387a63178a3af2"
EXPECTED_COVERAGE_MODEL_HASH="75edd882c1a5fb564ae95df2605aff65c38e5c6accbbd30741ce41e56ed8004a"
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

    find "${RESULT}" -type f -exec chmod a-w {} +
    find "${RESULT}" -type d -exec chmod 0555 {} +

    tar \
        -C "${B4}" \
        -czf "${PACKAGE}" \
        "$(basename "${RESULT}")"

    sha256sum "${PACKAGE}" >"${PACKAGE_HASH}"

    echo
    echo "============================================================"
    echo "SUB00N / BATCH 4 — RUN4 PACKAGED RESULT"
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
echo "SUB00N / BATCH 4 — FINAL CONTINUATION RUN4"
echo "============================================================"
echo "ROOT=${ROOT}"
echo "RESULT=${RESULT}"
echo

# ------------------------------------------------------------------
# Pre-execution gates
# ------------------------------------------------------------------

CURRENT_STEP="pre-execution gates"

test ! -e "${RESULT}" ||
    fail "RUN4 result directory already exists: ${RESULT}"

test ! -e "${PACKAGE}" ||
    fail "RUN4 package already exists: ${PACKAGE}"

test ! -e "${PACKAGE_HASH}" ||
    fail "RUN4 package hash already exists: ${PACKAGE_HASH}"

for required in \
    "${FAMILY_MANIFEST}" \
    "${PREFLIGHT_MANIFEST}" \
    "${COMPANION_MANIFEST}" \
    "${RUN1_PACKAGE}" \
    "${RUN1_PACKAGE_HASH}" \
    "${RUN1_POSITIVE}" \
    "${RUN2_PACKAGE}" \
    "${RUN2_PACKAGE_HASH}" \
    "${RUN2_WRAPPER}" \
    "${RUN3_PACKAGE}" \
    "${RUN3_PACKAGE_HASH}" \
    "${RUN3_CLASSIFICATION}" \
    "${DIAGNOSTIC_RUN1}" \
    "${DIAGNOSTIC_RUN1_HASH}" \
    "${DIAGNOSTIC_RUN3}" \
    "${DIAGNOSTIC_RUN3_HASH}" \
    "${COMPANION_MODEL}" \
    "${COMPANION_UNWIND}" \
    "${COMPANION_HEADER}" \
    "${COMPANION_CORRECTION}" \
    "${COVERAGE_MODEL}" \
    "${COVERAGE_UNWIND}" \
    "${INVALID_UPPER_MODEL}" \
    "${INVALID_UPPER_UNWIND}" \
    "${INVALID_LOWER_MODEL}" \
    "${INVALID_LOWER_UNWIND}" \
    "${REACHABILITY_HARNESS}" \
    "${INVALID_UPPER_HARNESS}" \
    "${INVALID_LOWER_HARNESS}"
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
    sed \
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
    echo "=== B4.5 ORIGINAL MODEL PREFLIGHT ==="

    (
        cd "${PREFLIGHT}"
        sha256sum -c "$(basename "${PREFLIGHT_MANIFEST}")"
    )

    echo
    echo "=== B4.8 COMPANION PREFLIGHT ==="

    (
        cd "${COMPANION_PREFLIGHT}"
        sha256sum -c "$(basename "${COMPANION_MANIFEST}")"
    )

    echo
    echo "=== PRIOR EXECUTION PACKAGES ==="

    sha256sum -c "${RUN1_PACKAGE_HASH}"
    sha256sum -c "${RUN2_PACKAGE_HASH}"
    sha256sum -c "${RUN3_PACKAGE_HASH}"

    echo
    echo "=== PRIOR DIAGNOSTICS ==="

    sha256sum -c "${DIAGNOSTIC_RUN1_HASH}"
    sha256sum -c "${DIAGNOSTIC_RUN3_HASH}"
} >"${RESULT}/parent_integrity_verification.txt" 2>&1

if grep -q ': FAILED' "${RESULT}/parent_integrity_verification.txt"; then
    fail "frozen parent integrity verification failed"
fi

echo "PARENT_INTEGRITY=PASS"

# ------------------------------------------------------------------
# Scientific parent and final-path bindings
# ------------------------------------------------------------------

CURRENT_STEP="scientific parent binding"

{
    echo "============================================================"
    echo "RUN4 SCIENTIFIC PARENT BINDING"
    echo "============================================================"
    echo

    check_hash \
        "${RUN1_PACKAGE}" \
        "${EXPECTED_RUN1_PACKAGE_HASH}" \
        "RUN1_PACKAGE"

    echo

    check_hash \
        "${RUN2_PACKAGE}" \
        "${EXPECTED_RUN2_PACKAGE_HASH}" \
        "RUN2_PACKAGE"

    echo

    check_hash \
        "${RUN3_PACKAGE}" \
        "${EXPECTED_RUN3_PACKAGE_HASH}" \
        "RUN3_PACKAGE"

    echo

    check_hash \
        "${DIAGNOSTIC_RUN1}" \
        "${EXPECTED_RUN1_DIAGNOSTIC_HASH}" \
        "RUN1_DIAGNOSTIC"

    echo

    check_hash \
        "${DIAGNOSTIC_RUN3}" \
        "${EXPECTED_RUN3_DIAGNOSTIC_HASH}" \
        "RUN3_DIAGNOSTIC"

    echo

    check_hash \
        "${COMPANION_MODEL}" \
        "${EXPECTED_COMPANION_MODEL_HASH}" \
        "COMPANION_MODEL"

    echo

    check_hash \
        "${COVERAGE_MODEL}" \
        "${EXPECTED_COVERAGE_MODEL_HASH}" \
        "ORIGINAL_COVERAGE_MODEL"

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
        fail "accepted RUN1 positive theorem binding failed"

    grep -Fxq \
        'FINAL_STEP=coverage compatibility policy' \
        "${RUN2_WRAPPER}" ||
        fail "RUN2 pre-execution failure binding failed"

    grep -Fxq \
        'CLASSIFICATION=FAIL_ALL_SUCCESS_CASE' \
        "${RUN3_CLASSIFICATION}" ||
        fail "RUN3 companion-run classification binding failed"

    grep -Fq \
        'FAILURE_PROPERTY=main.no-body.__CPROVER_cover' \
        "${DIAGNOSTIC_RUN3}" ||
        fail "RUN3 cover-call diagnosis binding failed"

    grep -Fq \
        'STATUS_COUNT_SUCCESS=333' \
        "${DIAGNOSTIC_RUN3}" ||
        fail "RUN3 333-property success binding failed"

    echo "RUN1_POSITIVE_THEOREM=PASS_351_OF_351"
    echo "RUN1_REACHABILITY_ATTEMPT=OPTION_USAGE_ERROR"
    echo "RUN2_ATTEMPT=PRE_EXECUTION_HELP_TEXT_GATE"
    echo "RUN3_COMPANION_SUBSTANTIVE_PROPERTIES=333_SUCCESS"
    echo "RUN3_SOLE_FAILURE=NO_BODY_CPROVER_COVER"
    echo "B4_8_COMPANION_MODEL_BINDING=PASS"
    echo "PRIOR_RUNS_PRESERVED_UNCHANGED=YES"
} >"${RESULT}/scientific_parent_binding.txt"

echo "SCIENTIFIC_PARENT_BINDING=PASS"

# ------------------------------------------------------------------
# Environment and execution boundary
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

cat >"${RESULT}/RUN4_EXECUTION_BOUNDARY.md" <<'EOF'
# SUB00N Batch 4 — RUN4 Execution Boundary

## Accepted parent result

The RUN1 positive SUB-T4 theorem passed all 351 properties with explicit
unwinding assertions.

It is not rerun or replaced by RUN4.

## Companion verification

RUN4 uses the B4.8 cover-neutral companion GOTO model.

That model:

- retains the production mlk_poly_sub body;
- retains the original reachability harness logic;
- neutralizes only the five __CPROVER_cover observations;
- exposes exactly 333 substantive verification properties.

The companion proof uses explicit unwinding assertions.

## Actual coverage

Coverage uses the original B4.5 reachability model, not the cover-neutral
companion model.

The coverage command uses the same explicit unwindset but omits
--unwinding-assertions because CBMC coverage mode rejected that explicit
combination in RUN1.

Before solver execution, RUN4 extracts and freezes the exact five coverage
property identifiers using --cover cover --show-properties.

## Negative controls

The original upper and lower negative-control models are executed with
explicit unwinding assertions.

Each must produce exactly one failure at its preregistered intended
property and no other failure.

## Integrity

No production source, frozen harness, prior run, prior diagnostic or
Batch-3 artefact is modified.
EOF

# ------------------------------------------------------------------
# Generic JSON classifier
# ------------------------------------------------------------------

CLASSIFIER="${RESULT}/classify_run4_result.py"

cat >"${CLASSIFIER}" <<'PY'
import json
import sys
from pathlib import Path

if len(sys.argv) != 8:
    raise SystemExit(
        "usage: classifier JSON EXIT SUMMARY MODE EXPECTED_TOTAL "
        "MARKER EXPECTED_IDS"
    )

json_path = Path(sys.argv[1])
exit_path = Path(sys.argv[2])
summary_path = Path(sys.argv[3])
mode = sys.argv[4]
expected_total = int(sys.argv[5])
marker = sys.argv[6]
expected_ids_path = Path(sys.argv[7])

raw_exit = int(exit_path.read_text().strip())
raw_text = json_path.read_text(errors="replace")

try:
    data = json.loads(raw_text)
except json.JSONDecodeError as exc:
    summary_path.write_text(
        "CLASSIFICATION=FAIL_INVALID_JSON\n"
        f"RAW_CBMC_EXIT_CODE={raw_exit}\n"
        f"JSON_SIZE_BYTES={json_path.stat().st_size}\n"
        f"JSON_ERROR={exc}\n"
    )
    raise SystemExit(1)

entries = []


def walk(value):
    if isinstance(value, dict):
        if "status" in value and (
            "property" in value
            or "goal" in value
            or "description" in value
        ):
            entries.append(value)

        for child in value.values():
            walk(child)

    elif isinstance(value, list):
        for child in value:
            walk(child)


walk(data)


def status(item):
    return str(item.get("status", "")).upper()


def identifier(item):
    value = item.get("property")

    if value is None:
        value = item.get("goal")

    if value is None:
        return "<unknown>"

    return str(value)


def blob(item):
    return json.dumps(item, sort_keys=True).lower()


successes = [
    item for item in entries
    if status(item) == "SUCCESS"
]

failures = [
    item for item in entries
    if status(item) == "FAILURE"
]

other_statuses = [
    item for item in entries
    if status(item) not in {
        "SUCCESS",
        "FAILURE",
        "SATISFIED",
        "COVERED",
        "REACHED",
    }
]

unwinding_failures = [
    item for item in failures
    if "unwind" in blob(item)
]

lines = [
    f"MODE={mode}",
    f"RAW_CBMC_EXIT_CODE={raw_exit}",
    f"TOTAL_RESULT_ENTRIES={len(entries)}",
    f"SUCCESS_STATUS_COUNT={len(successes)}",
    f"FAILURE_STATUS_COUNT={len(failures)}",
    f"OTHER_STATUS_COUNT={len(other_statuses)}",
    f"UNWINDING_FAILURE_COUNT={len(unwinding_failures)}",
]

passed = False

if mode == "ALL_SUCCESS":
    passed = (
        raw_exit == 0
        and len(entries) == expected_total
        and len(successes) == expected_total
        and len(failures) == 0
        and len(other_statuses) == 0
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
    expected_ids = [
        line.strip()
        for line in expected_ids_path.read_text().splitlines()
        if line.strip()
    ]

    expected_set = set(expected_ids)

    accepted_statuses = {
        "SUCCESS",
        "SATISFIED",
        "COVERED",
        "REACHED",
    }

    result_by_id = {}

    for item in entries:
        item_id = identifier(item)
        result_by_id.setdefault(item_id, []).append(item)

    actual_ids = set(result_by_id)

    reached_ids = []

    for item_id in expected_ids:
        matching = result_by_id.get(item_id, [])
        statuses = sorted({
            status(item)
            for item in matching
        })

        reached = (
            len(matching) == 1
            and any(value in accepted_statuses for value in statuses)
        )

        if reached:
            reached_ids.append(item_id)

        lines.append(
            f"COVER_PROPERTY_{item_id}_STATUS="
            + ",".join(statuses)
        )

        lines.append(
            f"COVER_PROPERTY_{item_id}_RESULT="
            + ("REACHED" if reached else "NOT_REACHED")
        )

        for item in matching:
            lines.append(
                f"COVER_PROPERTY_{item_id}_DESCRIPTION="
                f"{item.get('description', '')}"
            )

    unexpected_ids = sorted(actual_ids - expected_set)
    missing_ids = sorted(expected_set - actual_ids)

    lines.append(f"EXPECTED_COVERAGE_PROPERTIES={len(expected_ids)}")
    lines.append(f"ACTUAL_COVERAGE_PROPERTIES={len(actual_ids)}")
    lines.append(f"REACHED_COVERAGE_PROPERTIES={len(reached_ids)}")
    lines.append(
        "MISSING_COVERAGE_IDS="
        + ",".join(missing_ids)
    )
    lines.append(
        "UNEXPECTED_COVERAGE_IDS="
        + ",".join(unexpected_ids)
    )

    passed = (
        raw_exit == 0
        and len(expected_ids) == expected_total
        and len(entries) == expected_total
        and actual_ids == expected_set
        and len(reached_ids) == expected_total
        and len(failures) == 0
        and len(other_statuses) == 0
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
        raw_exit == 10
        and len(entries) == expected_total
        and len(successes) == expected_total - 1
        and len(failures) == 1
        and len(other_statuses) == 0
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
            f"FAILURE_{index}_PROPERTY={identifier(item)}"
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

# Empty file used for non-coverage classifier calls.
EMPTY_IDS="${RESULT}/empty_expected_ids.txt"
: >"${EMPTY_IDS}"

# ------------------------------------------------------------------
# Model validation and frozen-input preparation
# ------------------------------------------------------------------

prepare_case()
{
    case_name="$1"
    model="$2"
    harness="$3"
    unwind_file="$4"

    case_dir="${RESULT}/cases/${case_name}"
    frozen_dir="${case_dir}/frozen_inputs"

    mkdir -p "${frozen_dir}"

    cp "${model}" "${frozen_dir}/"
    cp "${harness}" "${frozen_dir}/"
    cp "${unwind_file}" "${frozen_dir}/"

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

    find "${frozen_dir}" -type f -exec chmod a-w {} +
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
        "${marker}" \
        "${EMPTY_IDS}"
    then
        cat "${case_dir}/CASE_CLASSIFICATION.txt" >&2 || true
        fail "${case_name}: result classification failed"
    fi

    cat "${case_dir}/CASE_CLASSIFICATION.txt"
}

# ------------------------------------------------------------------
# 1. Cover-neutral companion proof
# ------------------------------------------------------------------

CURRENT_STEP="cover-neutral companion proof"

run_normal_case \
    "COVER_NEUTRAL_COMPANION_PROOF" \
    "${COMPANION_MODEL}" \
    "${REACHABILITY_HARNESS}" \
    "${COMPANION_UNWIND}" \
    "333" \
    "ALL_SUCCESS" \
    "NONE"

cp \
    "${COMPANION_HEADER}" \
    "${RESULT}/cases/COVER_NEUTRAL_COMPANION_PROOF/frozen_inputs/"

cp \
    "${COMPANION_CORRECTION}" \
    "${RESULT}/cases/COVER_NEUTRAL_COMPANION_PROOF/frozen_inputs/"

chmod a-w \
    "${RESULT}/cases/COVER_NEUTRAL_COMPANION_PROOF/frozen_inputs/"*

# ------------------------------------------------------------------
# 2. Original-model coverage property inventory
# ------------------------------------------------------------------

CURRENT_STEP="coverage property inventory"

COVERAGE_CASE="${RESULT}/cases/ORIGINAL_MODEL_REACHABILITY_COVERAGE"
COVERAGE_IDS="${COVERAGE_CASE}/expected_coverage_property_ids.txt"
COVERAGE_INVENTORY="${COVERAGE_CASE}/coverage_property_inventory.txt"

prepare_case \
    "ORIGINAL_MODEL_REACHABILITY_COVERAGE" \
    "${COVERAGE_MODEL}" \
    "${REACHABILITY_HARNESS}" \
    "${COVERAGE_UNWIND}"

COVERAGE_UNWINDSET="$(cat "${COVERAGE_UNWIND}")"

INVENTORY_COMMAND=(
    cbmc
    "${COVERAGE_MODEL}"
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
    --unwindset "${COVERAGE_UNWINDSET}"
    --cover cover
    --show-properties
)

write_command \
    "${COVERAGE_CASE}/coverage_property_inventory_command.txt" \
    "${INVENTORY_COMMAND[@]}"

set +e
"${INVENTORY_COMMAND[@]}" \
    >"${COVERAGE_INVENTORY}" \
    2>"${COVERAGE_CASE}/coverage_property_inventory_stderr.txt"
inventory_rc=$?
set -e

printf '%s\n' "${inventory_rc}" \
    >"${COVERAGE_CASE}/coverage_property_inventory_exit_code.txt"

if [ "${inventory_rc}" -ne 0 ]; then
    cat "${COVERAGE_CASE}/coverage_property_inventory_stderr.txt" >&2 || true
    fail "coverage property-inventory extraction failed"
fi

python3 - \
    "${COVERAGE_INVENTORY}" \
    "${COVERAGE_IDS}" <<'PY'
import re
import sys
from pathlib import Path

inventory_path = Path(sys.argv[1])
ids_path = Path(sys.argv[2])

text = inventory_path.read_text(errors="replace")

property_ids = re.findall(
    r"^Property[ \t]+([^:\r\n]+):",
    text,
    flags=re.MULTILINE,
)

property_ids = list(dict.fromkeys(property_ids))

required_goal_names = [
    "has_maximum_positive",
    "has_maximum_negative",
    "has_zero",
    "has_interior_positive",
    "has_interior_negative",
]

if len(property_ids) != 5:
    raise SystemExit(
        f"expected exactly five coverage property IDs, found "
        f"{len(property_ids)}: {property_ids}"
    )

for goal in required_goal_names:
    if goal not in text:
        raise SystemExit(
            f"coverage property inventory is missing goal name: {goal}"
        )

ids_path.write_text("\n".join(property_ids) + "\n")

print("COVERAGE_PROPERTY_IDS_BEGIN")

for property_id in property_ids:
    print(property_id)

print("COVERAGE_PROPERTY_IDS_END")
PY

COVERAGE_ID_COUNT="$(wc -l <"${COVERAGE_IDS}")"

if [ "${COVERAGE_ID_COUNT}" -ne 5 ]; then
    fail "frozen coverage-property ID count is not five"
fi

if grep -q -- '--unwinding-assertions' \
    "${COVERAGE_CASE}/coverage_property_inventory_command.txt"
then
    fail "coverage inventory command contains explicit unwinding assertions"
fi

{
    echo "INVENTORY_EXIT_CODE=${inventory_rc}"
    echo "COVERAGE_PROPERTY_ID_COUNT=${COVERAGE_ID_COUNT}"
    echo "EXPLICIT_UNWINDING_ASSERTIONS_PRESENT=NO"
    echo "UNWINDSET_RETAINED=YES"
    echo "SOLVER_EXECUTED=NO"
    echo "COVERAGE_INVENTORY_BINDING=PASS"
    echo "COVERAGE_PROPERTY_IDS_BEGIN"
    cat "${COVERAGE_IDS}"
    echo "COVERAGE_PROPERTY_IDS_END"
} >"${COVERAGE_CASE}/COVERAGE_INVENTORY_BINDING.txt"

echo "COVERAGE_PROPERTY_INVENTORY=PASS_5_PROPERTIES"

# ------------------------------------------------------------------
# 3. Original-model coverage execution
# ------------------------------------------------------------------

CURRENT_STEP="original-model reachability coverage"

COVERAGE_COMMAND=(
    cbmc
    "${COVERAGE_MODEL}"
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
    --unwindset "${COVERAGE_UNWINDSET}"
    --slice-formula
    --sat-solver minisat2
    --trace
    --json-ui
    --cover cover
)

write_command \
    "${COVERAGE_CASE}/cbmc_command.txt" \
    "${COVERAGE_COMMAND[@]}"

if grep -q -- '--unwinding-assertions' \
    "${COVERAGE_CASE}/cbmc_command.txt"
then
    fail "coverage command contains explicit unwinding assertions"
fi

echo
echo "============================================================"
echo "RUNNING ORIGINAL_MODEL_REACHABILITY_COVERAGE"
echo "============================================================"
echo "MODEL=${COVERAGE_MODEL}"
echo "UNWINDSET=${COVERAGE_UNWINDSET}"
echo "EXPLICIT_UNWINDING_ASSERTIONS=OMITTED_FOR_COVERAGE_MODE"
echo "COMPANION_PROOF=PASS_333_OF_333"
echo "EXPECTED_COVERAGE_PROPERTIES=5"
echo

set +e
/usr/bin/time \
    -v \
    -o "${COVERAGE_CASE}/resource_usage.txt" \
    timeout \
    --signal=TERM \
    --kill-after=60s \
    21600s \
    "${COVERAGE_COMMAND[@]}" \
    >"${COVERAGE_CASE}/cbmc_result.json" \
    2>"${COVERAGE_CASE}/cbmc_stderr.txt"
coverage_rc=$?
set -e

printf '%s\n' "${coverage_rc}" \
    >"${COVERAGE_CASE}/cbmc_exit_code.txt"

if ! python3 \
    "${CLASSIFIER}" \
    "${COVERAGE_CASE}/cbmc_result.json" \
    "${COVERAGE_CASE}/cbmc_exit_code.txt" \
    "${COVERAGE_CASE}/CASE_CLASSIFICATION.txt" \
    "COVERAGE" \
    "5" \
    "NONE" \
    "${COVERAGE_IDS}"
then
    cat "${COVERAGE_CASE}/CASE_CLASSIFICATION.txt" >&2 || true
    fail "original-model reachability coverage classification failed"
fi

cat "${COVERAGE_CASE}/CASE_CLASSIFICATION.txt"

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
# Final Batch-4 classification
# ------------------------------------------------------------------

CURRENT_STEP="final Batch-4 classification"

cat >"${RESULT}/BATCH4_FINAL_COMBINED_SUMMARY.txt" <<'EOF'
============================================================
SUB00N / BATCH 4 — FINAL COMBINED RESULT
============================================================

RUN1_POSITIVE_THEOREM=PASS_351_OF_351

RUN1_REACHABILITY_ATTEMPT=OPTION_USAGE_ERROR_NO_SCIENTIFIC_RESULT
RUN2_ATTEMPT=PRE_EXECUTION_HELP_TEXT_GATE_NO_CASE_EXECUTION
RUN3_COMPANION_ATTEMPT=333_SUBSTANTIVE_SUCCESSES_PLUS_NO_BODY_COVER_FAILURE

RUN4_COVER_NEUTRAL_COMPANION_PROOF=PASS_333_OF_333
RUN4_ORIGINAL_MODEL_REACHABILITY_COVERAGE=PASS_5_OF_5_REACHED
RUN4_INVALID_UPPER=KILLED_BY_INTENDED_WITNESS
RUN4_INVALID_LOWER=KILLED_BY_INTENDED_WITNESS

SUB_T4_CANONICAL_INPUT_DOMAIN=[0,3329)
SUB_T4_PROVED_RAW_OUTPUT_RANGE=[-3328,3328]

SUB_T4_REPRESENTABILITY_ASSUMED=NO
SUB_T4_REPRESENTABILITY_PROVED=YES
SUB_T4_PRODUCTION_EXACTNESS_PROVED=YES
SUB_T4_INPUT_B_UNCHANGED_PROVED=YES

MAXIMUM_POSITIVE_OUTPUT_3328=REACHABLE
MAXIMUM_NEGATIVE_OUTPUT_MINUS_3328=REACHABLE
ZERO_OUTPUT=REACHABLE
INTERIOR_POSITIVE_OUTPUT=REACHABLE
INTERIOR_NEGATIVE_OUTPUT=REACHABLE

FALSE_STRICTER_UPPER_BOUND_3327=REJECTED
FALSE_STRICTER_LOWER_BOUND_MINUS_3327=REJECTED

AUTHORITATIVE_MODE=MODE_A
PRODUCTION_BODY_EXECUTION=YES
FUNCTION_CONTRACT_ABSTRACTION=NO
LOOP_CONTRACT_ABSTRACTION=NO

POSITIVE_THEOREM_UNWINDING_ASSERTIONS=ENABLED
COMPANION_PROOF_UNWINDING_ASSERTIONS=ENABLED

COVERAGE_USES_ORIGINAL_MODEL=YES
COVERAGE_EXPLICIT_UNWINDING_ASSERTIONS=OMITTED
COVERAGE_IDENTICAL_UNWINDSET_RETAINED=YES
COVERAGE_LOOP_COMPLETENESS_SUPPORTED_BY_COMPANION_PROOF=YES

NEGATIVE_CONTROL_UNWINDING_ASSERTIONS=ENABLED

PRODUCTION_SOURCE_MODIFIED=NO
FROZEN_HARNESS_MODIFIED=NO
ORIGINAL_COVERAGE_MODEL_MODIFIED=NO
PRIOR_RUNS_MODIFIED=NO
BATCH3_TOUCHED=NO
SUB_T1_RESULT_MODIFIED=NO
SUB_T2_RESULT_MODIFIED=NO

NOVELTY_CLAIM=WORLD_FIRST_NOT_CLAIMED
SAFE_DESCRIPTION=INDEPENDENTLY_AUTHORED_CANONICAL_DOMAIN_BRIDGE_THEOREM_AND_CBMC_ARTEFACT

BATCH4_COMBINED_VERDICT=PASS
EOF

cat >"${RESULT}/BATCH4_EVIDENCE_CHAIN.txt" <<EOF
RUN1_PACKAGE_SHA256=${EXPECTED_RUN1_PACKAGE_HASH}
RUN2_PACKAGE_SHA256=${EXPECTED_RUN2_PACKAGE_HASH}
RUN3_PACKAGE_SHA256=${EXPECTED_RUN3_PACKAGE_HASH}

RUN1_DIAGNOSTIC_SHA256=${EXPECTED_RUN1_DIAGNOSTIC_HASH}
RUN3_DIAGNOSTIC_SHA256=${EXPECTED_RUN3_DIAGNOSTIC_HASH}

POSITIVE_MODEL_PARENT=RUN1
POSITIVE_RESULT=PASS_351_OF_351

COMPANION_MODEL_SHA256=${EXPECTED_COMPANION_MODEL_HASH}
COMPANION_RESULT=PASS_333_OF_333

COVERAGE_MODEL_SHA256=${EXPECTED_COVERAGE_MODEL_HASH}
COVERAGE_RESULT=PASS_5_OF_5_REACHED

INVALID_UPPER_MODEL_SHA256=${EXPECTED_INVALID_UPPER_MODEL_HASH}
INVALID_UPPER_RESULT=KILLED_BY_INTENDED_WITNESS

INVALID_LOWER_MODEL_SHA256=${EXPECTED_INVALID_LOWER_MODEL_HASH}
INVALID_LOWER_RESULT=KILLED_BY_INTENDED_WITNESS

BATCH4_COMBINED_VERDICT=PASS
EOF

echo
cat "${RESULT}/BATCH4_FINAL_COMBINED_SUMMARY.txt"

exit 0
