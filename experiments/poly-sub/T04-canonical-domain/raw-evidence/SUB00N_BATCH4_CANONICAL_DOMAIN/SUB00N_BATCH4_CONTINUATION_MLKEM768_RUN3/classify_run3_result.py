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
