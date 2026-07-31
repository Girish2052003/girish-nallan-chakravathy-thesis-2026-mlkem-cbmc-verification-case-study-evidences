#!/usr/bin/env python3

import json
import sys
from pathlib import Path

if len(sys.argv) != 4:
    raise SystemExit(
        "usage: parser RESULT.json LABEL SUMMARY.txt"
    )

json_path = Path(sys.argv[1])
label = sys.argv[2]
summary_path = Path(sys.argv[3])

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
                "status": status.upper(),
                "description": description,
                "function": str(location.get("function", "")),
                "file": str(location.get("file", "")),
                "line": str(location.get("line", "")),
            }

        for item in value.values():
            walk(item)

    elif isinstance(value, list):
        for item in value:
            walk(item)


walk(data)

failures = {
    property_id: record
    for property_id, record in records.items()
    if record["status"] == "FAILURE"
}

unwind_failures = {
    property_id: record
    for property_id, record in failures.items()
    if "unwind" in (
        property_id
        + " "
        + record["description"]
    ).lower()
}

non_unwind_failures = {
    property_id: record
    for property_id, record in failures.items()
    if property_id not in unwind_failures
}

lines = [
    f"CONTROL_LABEL={label}",
    f"PROPERTY_RECORD_COUNT={len(records)}",
    f"FAILURE_COUNT={len(failures)}",
    f"UNWIND_FAILURE_COUNT={len(unwind_failures)}",
    f"NON_UNWIND_FAILURE_COUNT={len(non_unwind_failures)}",
]

for index, (property_id, record) in enumerate(
    sorted(unwind_failures.items()),
    start=1,
):
    lines.extend(
        [
            f"UNWIND_FAILURE_{index}_PROPERTY={property_id}",
            f"UNWIND_FAILURE_{index}_DESCRIPTION={record['description']}",
            f"UNWIND_FAILURE_{index}_FUNCTION={record['function']}",
            f"UNWIND_FAILURE_{index}_FILE={record['file']}",
            f"UNWIND_FAILURE_{index}_LINE={record['line']}",
        ]
    )

audit_pass = (
    len(records) > 0
    and len(failures) >= 1
    and len(unwind_failures) >= 1
    and len(non_unwind_failures) == 0
)

lines.append(
    "EXPECTED_FAILURE_AUDIT=PASS"
    if audit_pass
    else "EXPECTED_FAILURE_AUDIT=FAIL"
)

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print("\n".join(lines))

raise SystemExit(0 if audit_pass else 20)
