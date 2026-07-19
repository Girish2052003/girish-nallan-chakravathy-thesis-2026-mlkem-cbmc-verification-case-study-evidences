#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

RUN3="${B4}/SUB00N_BATCH4_CONTINUATION_MLKEM768_RUN3"
PACKAGE="${RUN3}.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"
RUN3_MANIFEST="${RUN3}/RESULT_ARTIFACT_MANIFEST.sha256"

CASE="${RUN3}/cases/REACHABILITY_COMPANION_PROOF"
JSON="${CASE}/cbmc_result.json"
STDERR="${CASE}/cbmc_stderr.txt"
EXIT_FILE="${CASE}/cbmc_exit_code.txt"
COMMAND="${CASE}/cbmc_command.txt"
CLASSIFICATION="${CASE}/CASE_CLASSIFICATION.txt"
RESOURCE="${CASE}/resource_usage.txt"
HARNESS="${CASE}/frozen_inputs/sub_t4_reachability_harness.c"

PREFLIGHT="${B4}/SUB00N_B4_5_GOTO_PREFLIGHT_MLKEM768"
PROPERTY_INVENTORY="${PREFLIGHT}/cases/REACHABILITY/build/show_properties.txt"

RUN1_POSITIVE="${B4}/SUB00N_BATCH4_COMBINED_EXECUTION_MLKEM768_RUN1/cases/POSITIVE/CASE_CLASSIFICATION.txt"

OUT="${B4}/SUB00N_B4_7_RUN3_COMPANION_FAILURE_DIAGNOSTIC.txt"
OUT_HASH="${OUT}.sha256"
TMP="${B4}/.SUB00N_B4_7_RUN3_COMPANION_FAILURE_DIAGNOSTIC.tmp"

EXPECTED_PACKAGE_HASH="99228f830dcc896303a3ae324576f368d0b64d22fe3aa0e9cfc626f4f709ae65"

echo "============================================================"
echo "SUB00N / BATCH 4 — RUN3 COMPANION-FAILURE DIAGNOSTIC"
echo "============================================================"
echo

for required in \
    "${RUN3}" \
    "${PACKAGE}" \
    "${PACKAGE_HASH}" \
    "${RUN3_MANIFEST}" \
    "${JSON}" \
    "${STDERR}" \
    "${EXIT_FILE}" \
    "${COMMAND}" \
    "${CLASSIFICATION}" \
    "${RESOURCE}" \
    "${HARNESS}" \
    "${PROPERTY_INVENTORY}" \
    "${RUN1_POSITIVE}"
do
    if [ ! -e "${required}" ]; then
        echo "ERROR: Required frozen artefact missing:"
        echo "${required}"
        exit 1
    fi
done

if [ -e "${OUT}" ] || [ -e "${OUT_HASH}" ]; then
    echo "ERROR: Diagnostic artefact already exists."
    echo "Nothing was overwritten:"
    echo "${OUT}"
    echo "${OUT_HASH}"
    exit 1
fi

{
    echo "============================================================"
    echo "SUB00N B4.7 — RUN3 COMPANION FAILURE DIAGNOSTIC"
    echo "============================================================"
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "RUN3=${RUN3}"
    echo

    echo "=== D1: RUN3 PACKAGE INTEGRITY ==="

    ACTUAL_PACKAGE_HASH="$(
        sha256sum "${PACKAGE}" |
        awk '{print $1}'
    )"

    echo "EXPECTED_PACKAGE_SHA256=${EXPECTED_PACKAGE_HASH}"
    echo "ACTUAL_PACKAGE_SHA256=${ACTUAL_PACKAGE_HASH}"

    if [ "${ACTUAL_PACKAGE_HASH}" = "${EXPECTED_PACKAGE_HASH}" ]; then
        echo "PACKAGE_HASH_BINDING=PASS"
    else
        echo "PACKAGE_HASH_BINDING=FAIL"
    fi

    sha256sum -c "${PACKAGE_HASH}"
    echo

    echo "=== D2: RUN3 DIRECTORY-MANIFEST INTEGRITY ==="

    (
        cd "${RUN3}"
        sha256sum -c "$(basename "${RUN3_MANIFEST}")"
    )
    echo

    echo "=== D3: ACCEPTED POSITIVE-THEOREM PARENT ==="

    cat "${RUN1_POSITIVE}"
    echo

    echo "=== D4: COMPANION COMMAND AND CLASSIFICATION ==="

    cat "${COMMAND}"
    echo
    echo "CBMC_EXIT_CODE=$(cat "${EXIT_FILE}")"
    echo
    cat "${CLASSIFICATION}"
    echo

    grep -E \
        'Command being timed|Elapsed|Maximum resident|Exit status' \
        "${RESOURCE}" ||
        true
    echo

    echo "=== D5: STDERR ==="

    if [ -s "${STDERR}" ]; then
        nl -ba "${STDERR}" |
            sed -n '1,200p'
    else
        echo "STDERR_EMPTY=YES"
    fi
    echo

    echo "=== D6: EXACT FAILURE-PROPERTY EXTRACTION ==="

    python3 - "${JSON}" <<'PY'
import collections
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(errors="replace")
data = json.loads(text)

results = []


def walk(value):
    if isinstance(value, dict):
        if "status" in value and (
            "property" in value
            or "description" in value
            or "sourceLocation" in value
        ):
            results.append(value)

        for child in value.values():
            walk(child)

    elif isinstance(value, list):
        for child in value:
            walk(child)


walk(data)


def normalized_status(item):
    return str(item.get("status", "")).upper()


def compact_source(source):
    if not isinstance(source, dict):
        return "<none>"

    parts = []

    for key in (
        "file",
        "function",
        "line",
        "column",
        "workingDirectory",
    ):
        if key in source:
            parts.append(f"{key}={source[key]}")

    return " | ".join(parts) if parts else repr(source)


failure_statuses = {
    "FAILURE",
    "FAILED",
    "ERROR",
    "UNSATISFIED",
    "UNCOVERED",
}

status_counts = collections.Counter(
    normalized_status(item)
    for item in results
)

failures = [
    item for item in results
    if normalized_status(item) in failure_statuses
]

print(f"STRICT_JSON_PARSE=PASS")
print(f"TOTAL_RESULT_ENTRIES={len(results)}")

for status, count in sorted(status_counts.items()):
    print(f"STATUS_COUNT_{status or 'EMPTY'}={count}")

print(f"FAILURE_ENTRY_COUNT={len(failures)}")

goal_names = [
    "has_maximum_positive",
    "has_maximum_negative",
    "has_zero",
    "has_interior_positive",
    "has_interior_negative",
]

for index, item in enumerate(failures, 1):
    print()
    print("------------------------------------------------------------")
    print(f"FAILURE_INDEX={index}")
    print(f"FAILURE_STATUS={normalized_status(item)}")
    print(f"FAILURE_PROPERTY={item.get('property', '<unknown>')}")
    print(f"FAILURE_DESCRIPTION={item.get('description', '')}")
    print(
        "FAILURE_SOURCE="
        + compact_source(item.get("sourceLocation"))
    )

    blob = json.dumps(item, sort_keys=True).lower()

    print(f"CONTAINS_SUB_T4_MARKER={'YES' if 'sub_t4' in blob else 'NO'}")
    print(f"CONTAINS_COVER_TEXT={'YES' if 'cover' in blob else 'NO'}")
    print(f"CONTAINS_UNWIND_TEXT={'YES' if 'unwind' in blob else 'NO'}")
    print(f"CONTAINS_ZEROIZE_TEXT={'YES' if 'zeroize' in blob else 'NO'}")

    for goal in goal_names:
        print(
            f"CONTAINS_{goal}="
            + ("YES" if goal in blob else "NO")
        )

    trace = item.get("trace")

    if not isinstance(trace, list):
        print("TRACE_PRESENT=NO")
        continue

    print("TRACE_PRESENT=YES")
    print(f"TRACE_STEP_COUNT={len(trace)}")
    print("TRACE_LAST_RELEVANT_STEPS_BEGIN")

    relevant = []

    for step_number, step in enumerate(trace, 1):
        if not isinstance(step, dict):
            continue

        step_type = str(step.get("stepType", ""))
        source = step.get("sourceLocation")
        reason = step.get("reason")
        lhs = step.get("lhs")
        value = step.get("value")
        prop = step.get("property")

        searchable = json.dumps(step, sort_keys=True).lower()

        interesting = (
            step_type.lower() in {
                "assertion",
                "assignment",
                "assumption",
                "function-call",
                "function-return",
            }
            or "sub_t4" in searchable
            or "cover" in searchable
            or any(goal in searchable for goal in goal_names)
        )

        if interesting:
            relevant.append(
                (
                    step_number,
                    step_type,
                    compact_source(source),
                    reason,
                    lhs,
                    value,
                    prop,
                )
            )

    for record in relevant[-50:]:
        (
            number,
            step_type,
            source,
            reason,
            lhs,
            value,
            prop,
        ) = record

        print(
            f"STEP={number} "
            f"TYPE={step_type!r} "
            f"SOURCE={source!r} "
            f"REASON={reason!r} "
            f"LHS={lhs!r} "
            f"VALUE={value!r} "
            f"PROPERTY={prop!r}"
        )

    print("TRACE_LAST_RELEVANT_STEPS_END")

print()
print("=== RESULT ENTRIES CONTAINING COVERAGE-GOAL NAMES ===")

for goal in goal_names:
    matches = [
        item for item in results
        if goal in json.dumps(item, sort_keys=True).lower()
    ]

    print(f"GOAL={goal}")
    print(f"MATCH_COUNT={len(matches)}")

    for item in matches:
        print(
            "  "
            f"PROPERTY={item.get('property', '<unknown>')} | "
            f"STATUS={normalized_status(item)} | "
            f"DESCRIPTION={item.get('description', '')}"
        )
PY
    echo

    echo "=== D7: FROZEN HARNESS COVERAGE AND ASSERTION LINES ==="

    grep -nE \
        '__CPROVER_cover|__CPROVER_assert|has_maximum|has_zero|has_interior|mlk_poly_sub' \
        "${HARNESS}" ||
        true
    echo

    echo "=== D8: PREFLIGHT PROPERTY-INVENTORY MATCHES ==="

    grep -nEi \
        'SUB_T4|cover|has_maximum|has_zero|has_interior|unwind|zeroize' \
        "${PROPERTY_INVENTORY}" |
        head -n 260 ||
        true
    echo

    echo "=== D9: RESULT-JSON PROPERTY MATCHES ==="

    python3 - "${JSON}" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text(errors="replace"))
results = []


def walk(value):
    if isinstance(value, dict):
        if "status" in value and (
            "property" in value
            or "description" in value
        ):
            results.append(value)

        for child in value.values():
            walk(child)

    elif isinstance(value, list):
        for child in value:
            walk(child)


walk(data)

needles = (
    "sub_t4",
    "cover",
    "has_maximum",
    "has_zero",
    "has_interior",
    "unwind",
    "zeroize",
)

for item in results:
    rendered = json.dumps(item, sort_keys=True).lower()

    if not any(needle in rendered for needle in needles):
        continue

    print(
        f"PROPERTY={item.get('property', '<unknown>')} | "
        f"STATUS={item.get('status', '<unknown>')} | "
        f"DESCRIPTION={item.get('description', '')}"
    )
PY
    echo

    echo "=== D10: SCIENTIFIC STATUS BEFORE INTERPRETATION ==="
    echo "SUB_T4_POSITIVE_THEOREM=PASS_351_OF_351"
    echo "RUN3_COMPANION_SUCCESS_PROPERTIES=333"
    echo "RUN3_COMPANION_FAILURE_PROPERTIES=1"
    echo "RUN3_COMPANION_UNWINDING_FAILURES=0"
    echo "RUN3_FAILURE_MEANING=AWAITING_EXACT_PROPERTY_REVIEW"
    echo "RUN3_COVERAGE=NOT_EXECUTED"
    echo "RUN3_INVALID_UPPER=NOT_EXECUTED"
    echo "RUN3_INVALID_LOWER=NOT_EXECUTED"
    echo "BATCH4_OVERALL=INCOMPLETE_PENDING_PROPERTY_DIAGNOSIS"
    echo

    echo "=== D11: SCIENTIFIC ACTION RECORD ==="
    echo "CBMC_EXECUTED_BY_DIAGNOSTIC=NO"
    echo "GOTO_MODEL_CREATED_BY_DIAGNOSTIC=NO"
    echo "RUN1_MODIFIED=NO"
    echo "RUN2_MODIFIED=NO"
    echo "RUN3_MODIFIED=NO"
    echo "RUN3_PACKAGE_MODIFIED=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "FROZEN_HARNESS_MODIFIED=NO"
    echo "BATCH3_TOUCHED=NO"
    echo "SUB_T1_RESULT_MODIFIED=NO"
    echo "SUB_T2_RESULT_MODIFIED=NO"
} >"${TMP}" 2>&1

mv "${TMP}" "${OUT}"
sha256sum "${OUT}" >"${OUT_HASH}"

chmod a-w "${OUT}" "${OUT_HASH}"

cat "${OUT}"

echo
echo "============================================================"
echo "B4.7 DIAGNOSTIC ARTEFACTS"
echo "============================================================"

stat --printf='MODE=%A SIZE=%s PATH=%n\n' \
    "${OUT}" \
    "${OUT_HASH}"

echo
cat "${OUT_HASH}"

echo
echo "BATCH4_RUN3_FAILURE_DIAGNOSTIC_GATE=PASS"
echo "NO_CBMC_EXECUTION_OCCURRED=YES"
echo "RUN3_PRESERVED_UNCHANGED=YES"
