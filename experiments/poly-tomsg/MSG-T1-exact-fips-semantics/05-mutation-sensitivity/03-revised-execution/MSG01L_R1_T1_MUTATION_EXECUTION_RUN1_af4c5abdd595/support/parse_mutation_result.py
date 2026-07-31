#!/usr/bin/env python3

import csv
import json
import sys
from pathlib import Path

if len(sys.argv) != 6:
    raise SystemExit(
        "usage: parser RESULT.json MUTANT_ID "
        "EXPECTED_SECONDARY ALL.tsv SUMMARY.txt"
    )

json_path = Path(sys.argv[1])
mutant_id = sys.argv[2]
expected_secondary = sys.argv[3]
all_path = Path(sys.argv[4])
summary_path = Path(sys.argv[5])

data = json.loads(
    json_path.read_text(
        encoding="utf-8",
        errors="strict",
    )
)

records = {}


def walk(value):
    if isinstance(value, dict):
        property_id = value.get("property")
        status = value.get("status")

        if isinstance(property_id, str) and isinstance(status, str):
            description = value.get("description", "")
            location = value.get("sourceLocation", {})

            if not isinstance(description, str):
                description = str(description)

            if not isinstance(location, dict):
                location = {}

            records[property_id] = {
                "property": property_id,
                "status": status.upper(),
                "description": description,
                "file": str(location.get("file", "")),
                "line": str(location.get("line", "")),
                "function": str(location.get("function", "")),
            }

        for item in value.values():
            walk(item)

    elif isinstance(value, list):
        for item in value:
            walk(item)


walk(data)

if not records:
    raise SystemExit("NO_PROPERTY_RECORDS")

ordered = [
    records[property_id]
    for property_id in sorted(records)
]

with all_path.open(
    "w",
    encoding="utf-8",
    newline="",
) as handle:
    writer = csv.writer(
        handle,
        delimiter="\t",
        lineterminator="\n",
    )

    writer.writerow(
        [
            "PROPERTY",
            "STATUS",
            "DESCRIPTION",
            "FILE",
            "LINE",
            "FUNCTION",
        ]
    )

    for record in ordered:
        writer.writerow(
            [
                record["property"],
                record["status"],
                record["description"].replace("\n", " "),
                record["file"],
                record["line"],
                record["function"],
            ]
        )

success = [
    record
    for record in ordered
    if record["status"] == "SUCCESS"
]

failures = [
    record
    for record in ordered
    if record["status"] == "FAILURE"
]

unknown = [
    record
    for record in ordered
    if record["status"] not in {
        "SUCCESS",
        "FAILURE",
    }
]

exact_marker = (
    "MSG_T1_EXACT: every output bit must equal "
    "the independent Compress1 oracle"
)

exact_failures = [
    record
    for record in failures
    if exact_marker in record["description"]
]

secondary_failures = []

if expected_secondary != "NONE":
    secondary_failures = [
        record
        for record in failures
        if expected_secondary in record["description"]
    ]

unwind_failures = [
    record
    for record in failures
    if "unwind" in (
        record["property"]
        + " "
        + record["description"]
    ).lower()
]

allowed_failures = []

for record in failures:
    allowed = exact_marker in record["description"]

    if expected_secondary != "NONE":
        allowed = (
            allowed
            or expected_secondary in record["description"]
        )

    if allowed:
        allowed_failures.append(record)

unexpected_failures = [
    record
    for record in failures
    if record not in allowed_failures
]

audit_pass = (
    len(ordered) > 0
    and len(failures) >= 1
    and len(exact_failures) >= 1
    and len(unknown) == 0
    and len(unwind_failures) == 0
    and len(unexpected_failures) == 0
    and (
        expected_secondary == "NONE"
        or len(secondary_failures) >= 1
    )
)

lines = [
    f"MUTANT_ID={mutant_id}",
    "JSON_PARSE=PASS",
    f"PROPERTY_RECORD_COUNT={len(ordered)}",
    f"SUCCESS_COUNT={len(success)}",
    f"FAILURE_COUNT={len(failures)}",
    f"UNKNOWN_COUNT={len(unknown)}",
    f"EXACT_ASSERTION_FAILURE_COUNT={len(exact_failures)}",
    f"EXPECTED_SECONDARY_MARKER={expected_secondary}",
    f"EXPECTED_SECONDARY_FAILURE_COUNT={len(secondary_failures)}",
    f"UNWIND_FAILURE_COUNT={len(unwind_failures)}",
    f"UNEXPECTED_FAILURE_COUNT={len(unexpected_failures)}",
]

for index, record in enumerate(
    failures,
    start=1,
):
    lines.extend(
        [
            f"FAILURE_{index}_PROPERTY={record['property']}",
            f"FAILURE_{index}_DESCRIPTION={record['description']}",
            f"FAILURE_{index}_FUNCTION={record['function']}",
            f"FAILURE_{index}_FILE={record['file']}",
            f"FAILURE_{index}_LINE={record['line']}",
        ]
    )

lines.append(
    "MUTATION_EXPECTED_FAILURE_AUDIT=PASS"
    if audit_pass
    else "MUTATION_EXPECTED_FAILURE_AUDIT=FAIL"
)

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print("\n".join(lines))

raise SystemExit(0 if audit_pass else 20)
