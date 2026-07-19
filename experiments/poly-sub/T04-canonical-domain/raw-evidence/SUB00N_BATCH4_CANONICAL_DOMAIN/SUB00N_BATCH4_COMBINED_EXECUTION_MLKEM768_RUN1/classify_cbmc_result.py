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
