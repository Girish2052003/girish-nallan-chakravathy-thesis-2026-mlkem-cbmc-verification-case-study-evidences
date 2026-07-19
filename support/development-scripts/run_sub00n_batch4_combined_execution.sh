#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

FAMILY="${B4}/frozen_harness_family_v1"
FAMILY_MANIFEST="${FAMILY}/SUB00N_B4_4_ARTIFACT_MANIFEST.sha256"

PREFLIGHT="${B4}/SUB00N_B4_5_GOTO_PREFLIGHT_MLKEM768"
PREFLIGHT_MANIFEST="${PREFLIGHT}/SUB00N_B4_5_PREFLIGHT_ARTIFACT_MANIFEST.sha256"

REPAIR_RECORD="${B4}/SUB00N_B4_5_V1_FAILURE_AND_V2_REPAIR_RECORD.txt"
REPAIR_RECORD_HASH="${REPAIR_RECORD}.sha256"

RESULT="${B4}/SUB00N_BATCH4_COMBINED_EXECUTION_MLKEM768_RUN1"
PACKAGE="${RESULT}.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

SCRIPT_PATH="$(readlink -f "$0")"
CURRENT_STEP="initialization"
FINALIZED=0

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

case_model()
{
    case "$1" in
        POSITIVE)
            echo "${PREFLIGHT}/cases/POSITIVE/build/sub_t4_positive_mlkem768.goto"
            ;;
        REACHABILITY)
            echo "${PREFLIGHT}/cases/REACHABILITY/build/sub_t4_reachability_mlkem768.goto"
            ;;
        INVALID_UPPER)
            echo "${PREFLIGHT}/cases/INVALID_UPPER/build/sub_t4_invalid_upper_mlkem768.goto"
            ;;
        INVALID_LOWER)
            echo "${PREFLIGHT}/cases/INVALID_LOWER/build/sub_t4_invalid_lower_mlkem768.goto"
            ;;
    esac
}

case_reachable_model()
{
    case "$1" in
        POSITIVE)
            echo "${PREFLIGHT}/cases/POSITIVE/build/sub_t4_positive_mlkem768_reachable_only.goto"
            ;;
        REACHABILITY)
            echo "${PREFLIGHT}/cases/REACHABILITY/build/sub_t4_reachability_mlkem768_reachable_only.goto"
            ;;
        INVALID_UPPER)
            echo "${PREFLIGHT}/cases/INVALID_UPPER/build/sub_t4_invalid_upper_mlkem768_reachable_only.goto"
            ;;
        INVALID_LOWER)
            echo "${PREFLIGHT}/cases/INVALID_LOWER/build/sub_t4_invalid_lower_mlkem768_reachable_only.goto"
            ;;
    esac
}

case_harness()
{
    case "$1" in
        POSITIVE)
            echo "${FAMILY}/harnesses/sub_t4_canonical_domain_harness.c"
            ;;
        REACHABILITY)
            echo "${FAMILY}/harnesses/sub_t4_reachability_harness.c"
            ;;
        INVALID_UPPER)
            echo "${FAMILY}/harnesses/sub_t4_invalid_upper_harness.c"
            ;;
        INVALID_LOWER)
            echo "${FAMILY}/harnesses/sub_t4_invalid_lower_harness.c"
            ;;
    esac
}

expected_model_hash()
{
    case "$1" in
        POSITIVE)
            echo "00e79a1c349e47094830259361b5d5b3c32184ebeecf53732a47d4333fe31ed8"
            ;;
        REACHABILITY)
            echo "75edd882c1a5fb564ae95df2605aff65c38e5c6accbbd30741ce41e56ed8004a"
            ;;
        INVALID_UPPER)
            echo "adc0a976bd7988e28e57ee8ac7b422a3dedf1cb76771473ab3177684d0135acf"
            ;;
        INVALID_LOWER)
            echo "56c565ab02533cba48b181693c9309503142665236276d8687629d05b09e2455"
            ;;
    esac
}

expected_reachable_hash()
{
    case "$1" in
        POSITIVE)
            echo "005552da7cd7f6c5118ed309df98f256ebdf7a7035bdc700ffc1b408e9dd264d"
            ;;
        REACHABILITY)
            echo "c8727a952a5b81a68de1f7bedf5d2917ffee90192a5dd583a0e7d144e378ae5e"
            ;;
        INVALID_UPPER)
            echo "5c1e6e9217375af7aba1b3d1146ef8d9481a42c562b5e055e24cc31890c71193"
            ;;
        INVALID_LOWER)
            echo "5b192527c8270dec522affc7545a9e9bcb2b8003e0d22138412e672d7923b3f0"
            ;;
    esac
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

        find . -type f \
            ! -name 'RESULT_ARTIFACT_MANIFEST.sha256' \
            -print0 |
        sort -z |
        xargs -0 sha256sum
    ) >"${RESULT}/RESULT_ARTIFACT_MANIFEST.sha256"

    tar -C "${B4}" -czf "${PACKAGE}" "$(basename "${RESULT}")"
    sha256sum "${PACKAGE}" >"${PACKAGE_HASH}"

    find "${RESULT}" -type f -exec chmod a-w {} +
    find "${RESULT}" -type d -exec chmod 0555 {} +

    echo
    echo "============================================================"
    echo "SUB00N / BATCH 4 — PACKAGED RESULT"
    echo "============================================================"
    echo "RESULT=${RESULT}"
    echo "PACKAGE=${PACKAGE}"
    cat "${PACKAGE_HASH}"

    if [ -f "${RESULT}/BATCH4_FINAL_SUMMARY.txt" ]; then
        echo
        cat "${RESULT}/BATCH4_FINAL_SUMMARY.txt"
    fi
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
echo "SUB00N / BATCH 4 — COMBINED EXECUTION"
echo "============================================================"
echo "ROOT=${ROOT}"
echo "RESULT=${RESULT}"
echo

test ! -e "${RESULT}" || fail "result directory already exists"
test ! -e "${PACKAGE}" || fail "result package already exists"
test ! -e "${PACKAGE_HASH}" || fail "result package hash already exists"

for tool in cbmc goto-instrument timeout sha256sum python3 tar gzip
do
    command -v "${tool}" >/dev/null 2>&1 ||
        fail "required tool unavailable: ${tool}"
done

test -x /usr/bin/time || fail "GNU time unavailable"

mkdir -p "${RESULT}/cases" "${RESULT}/frozen_inputs"
cp "${SCRIPT_PATH}" "${RESULT}/executed_runner.sh"

CURRENT_STEP="parent integrity"

{
    (
        cd "${FAMILY}"
        sha256sum -c "$(basename "${FAMILY_MANIFEST}")"
    )

    (
        cd "${PREFLIGHT}"
        sha256sum -c "$(basename "${PREFLIGHT_MANIFEST}")"
    )

    sha256sum -c "${REPAIR_RECORD_HASH}"
} >"${RESULT}/parent_manifest_verification.txt" 2>&1

grep -q ': FAILED' "${RESULT}/parent_manifest_verification.txt" &&
    fail "parent integrity failure"

echo "PARENT_INTEGRITY=PASS"

CURRENT_STEP="model relocation binding"

RELOCATION="${RESULT}/B4_5_FINAL_PATH_RELOCATION_BINDING.txt"

for CASE_ID in POSITIVE REACHABILITY INVALID_UPPER INVALID_LOWER
do
    MODEL="$(case_model "${CASE_ID}")"
    REACHABLE="$(case_reachable_model "${CASE_ID}")"
    EXPECTED="$(expected_model_hash "${CASE_ID}")"
    EXPECTED_REACHABLE="$(expected_reachable_hash "${CASE_ID}")"

    ACTUAL="$(sha256sum "${MODEL}" | awk '{print $1}')"
    ACTUAL_REACHABLE="$(sha256sum "${REACHABLE}" | awk '{print $1}')"

    {
        echo "CASE_ID=${CASE_ID}"
        echo "FINAL_MODEL=${MODEL}"
        echo "EXPECTED_MODEL_SHA256=${EXPECTED}"
        echo "ACTUAL_MODEL_SHA256=${ACTUAL}"
        echo "FINAL_REACHABLE_MODEL=${REACHABLE}"
        echo "EXPECTED_REACHABLE_SHA256=${EXPECTED_REACHABLE}"
        echo "ACTUAL_REACHABLE_SHA256=${ACTUAL_REACHABLE}"
    } >>"${RELOCATION}"

    [ "${ACTUAL}" = "${EXPECTED}" ] ||
        fail "${CASE_ID}: authoritative model hash mismatch"

    [ "${ACTUAL_REACHABLE}" = "${EXPECTED_REACHABLE}" ] ||
        fail "${CASE_ID}: reachable model hash mismatch"

    echo "PATH_RELOCATION_BINDING=PASS" >>"${RELOCATION}"
    echo >>"${RELOCATION}"
done

echo "MODEL_RELOCATION_BINDING=PASS"

CLASSIFIER="${RESULT}/classify_cbmc_result.py"

cat >"${CLASSIFIER}" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
exit_path = Path(sys.argv[2])
summary_path = Path(sys.argv[3])
mode = sys.argv[4]
expected_total = int(sys.argv[5])
marker = sys.argv[6]

raw_exit = int(exit_path.read_text().strip())
data = json.loads(json_path.read_text(errors="replace"))

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

bad_statuses = {
    "FAILURE",
    "FAILED",
    "UNSATISFIED",
    "UNCOVERED",
    "ERROR",
}

successes = [
    item for item in results
    if str(item.get("status", "")).upper() == "SUCCESS"
]

failures = [
    item for item in results
    if str(item.get("status", "")).upper() in bad_statuses
]


def blob(item):
    return json.dumps(item, sort_keys=True).lower()


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

if mode == "POSITIVE":
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
            else "FAIL_POSITIVE_THEOREM"
        )
    )

elif mode == "REACHABILITY":
    goals = [
        "has_maximum_positive",
        "has_maximum_negative",
        "has_zero",
        "has_interior_positive",
        "has_interior_negative",
    ]

    good_statuses = {
        "SUCCESS",
        "SATISFIED",
        "COVERED",
        "REACHED",
    }

    reached = 0

    for goal in goals:
        matches = [
            item for item in results
            if goal.lower() in blob(item)
        ]

        statuses = sorted({
            str(item.get("status", "")).upper()
            for item in matches
        })

        goal_ok = any(
            status in good_statuses
            for status in statuses
        )

        reached += int(goal_ok)

        lines.append(
            f"COVER_GOAL_{goal}="
            + ("REACHED" if goal_ok else "NOT_REACHED")
        )
        lines.append(
            f"COVER_GOAL_{goal}_STATUSES="
            + ",".join(statuses)
        )

    passed = (
        raw_exit == 0
        and reached == 5
        and len(failures) == 0
        and len(unwinding_failures) == 0
    )

    lines.append(f"COVER_GOALS_REACHED={reached}")
    lines.append("COVER_GOALS_EXPECTED=5")
    lines.append(
        "CLASSIFICATION="
        + (
            "PASS_5_OF_5_REACHED"
            if passed
            else "FAIL_REACHABILITY"
        )
    )

else:
    marker_failures = [
        item for item in failures
        if marker.lower() in blob(item)
    ]

    passed = (
        raw_exit != 0
        and len(results) == expected_total
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

    if mode == "INVALID_UPPER":
        success_class = "KILLED_BY_UPPER_BOUND_WITNESS"
    else:
        success_class = "KILLED_BY_LOWER_BOUND_WITNESS"

    lines.append(
        "CLASSIFICATION="
        + (
            success_class
            if passed
            else "FAIL_NEGATIVE_CONTROL"
        )
    )

summary_path.write_text("\n".join(lines) + "\n")
raise SystemExit(0 if passed else 1)
PY

run_case()
{
    CASE_ID="$1"
    MODE="$2"
    EXPECTED_TOTAL="$3"
    MARKER="$4"

    CASE_RESULT="${RESULT}/cases/${CASE_ID}"
    mkdir -p "${CASE_RESULT}/frozen_inputs"

    MODEL="$(case_model "${CASE_ID}")"
    HARNESS="$(case_harness "${CASE_ID}")"
    UNWIND_FILE="${PREFLIGHT}/cases/${CASE_ID}/build/frozen_unwindset.txt"
    UNWINDSET="$(cat "${UNWIND_FILE}")"

    cp "${MODEL}" "${CASE_RESULT}/frozen_inputs/"
    cp "${HARNESS}" "${CASE_RESULT}/frozen_inputs/"
    cp "${UNWIND_FILE}" "${CASE_RESULT}/frozen_inputs/"

    VALIDATION="${CASE_RESULT}/final_validation.txt"
    VALIDATION_EXIT="${CASE_RESULT}/final_validation_exit_code.txt"

    set +e
    goto-instrument \
        --validate-goto-binary \
        "${MODEL}" \
        >"${VALIDATION}" 2>&1
    VALIDATION_RC=$?
    set -e

    echo "${VALIDATION_RC}" >"${VALIDATION_EXIT}"

    [ "${VALIDATION_RC}" -eq 0 ] ||
        fail "${CASE_ID}: final model validation failed"

    CMD=(
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

    if [ "${MODE}" = "REACHABILITY" ]; then
        CMD+=(--cover cover)
    fi

    write_command "${CASE_RESULT}/cbmc_command.txt" "${CMD[@]}"

    echo
    echo "============================================================"
    echo "RUNNING ${CASE_ID}"
    echo "============================================================"

    set +e
    /usr/bin/time \
        -v \
        -o "${CASE_RESULT}/resource_usage.txt" \
        timeout \
        --signal=TERM \
        --kill-after=60s \
        21600s \
        "${CMD[@]}" \
        >"${CASE_RESULT}/cbmc_result.json" \
        2>"${CASE_RESULT}/cbmc_stderr.txt"
    CBMC_RC=$?
    set -e

    echo "${CBMC_RC}" >"${CASE_RESULT}/cbmc_exit_code.txt"

    if ! python3 \
        "${CLASSIFIER}" \
        "${CASE_RESULT}/cbmc_result.json" \
        "${CASE_RESULT}/cbmc_exit_code.txt" \
        "${CASE_RESULT}/CASE_CLASSIFICATION.txt" \
        "${MODE}" \
        "${EXPECTED_TOTAL}" \
        "${MARKER}"
    then
        cat "${CASE_RESULT}/CASE_CLASSIFICATION.txt" >&2 || true
        fail "${CASE_ID}: classification failed"
    fi

    cat "${CASE_RESULT}/CASE_CLASSIFICATION.txt"
}

CURRENT_STEP="positive theorem"
run_case POSITIVE POSITIVE 351 NONE

CURRENT_STEP="reachability"
run_case REACHABILITY REACHABILITY 0 NONE

CURRENT_STEP="upper negative control"
run_case \
    INVALID_UPPER \
    INVALID_UPPER \
    328 \
    SUB_T4_NC1_INTENDED_FAILURE

CURRENT_STEP="lower negative control"
run_case \
    INVALID_LOWER \
    INVALID_LOWER \
    328 \
    SUB_T4_NC2_INTENDED_FAILURE

CURRENT_STEP="final Batch-4 classification"

cat >"${RESULT}/BATCH4_FINAL_SUMMARY.txt" <<EOF
============================================================
SUB00N / BATCH 4 — FINAL RESULT
============================================================

SUB_T4_POSITIVE_THEOREM=PASS_351_OF_351
SUB_T4_REACHABILITY=PASS_5_OF_5_REACHED
SUB_T4_INVALID_UPPER=KILLED_BY_UPPER_BOUND_WITNESS
SUB_T4_INVALID_LOWER=KILLED_BY_LOWER_BOUND_WITNESS

AUTHORITATIVE_MODE=MODE_A
PRODUCTION_BODY_EXECUTION=YES
FUNCTION_CONTRACT_ABSTRACTION=NO
LOOP_CONTRACT_ABSTRACTION=NO
UNWINDING_ASSERTIONS=ENABLED
PRODUCTION_SOURCE_MODIFIED=NO
FROZEN_HARNESS_MODIFIED=NO
BATCH3_TOUCHED=NO
SUB_T1_RESULT_MODIFIED=NO
SUB_T2_RESULT_MODIFIED=NO

BATCH4_COMBINED_VERDICT=PASS
EOF

echo
cat "${RESULT}/BATCH4_FINAL_SUMMARY.txt"

exit 0
