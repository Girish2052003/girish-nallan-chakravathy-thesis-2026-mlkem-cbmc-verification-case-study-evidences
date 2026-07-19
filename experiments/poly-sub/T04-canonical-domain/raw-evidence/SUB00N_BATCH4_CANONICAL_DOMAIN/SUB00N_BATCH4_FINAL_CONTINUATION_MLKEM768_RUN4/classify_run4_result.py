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
