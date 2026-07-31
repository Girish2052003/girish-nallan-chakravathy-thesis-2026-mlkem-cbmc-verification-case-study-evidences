#!/usr/bin/env python3

import csv
import json
import re
import sys
from pathlib import Path

if len(sys.argv) != 5:
    raise SystemExit(
        "usage: parser RESULT.json ALL.tsv FAILURES.tsv SUMMARY.txt"
    )

json_path = Path(sys.argv[1])
all_path = Path(sys.argv[2])
failure_path = Path(sys.argv[3])
summary_path = Path(sys.argv[4])

try:
    data = json.loads(
        json_path.read_text(
            encoding="utf-8",
            errors="strict",
        )
    )
except Exception as error:
    summary_path.write_text(
        "JSON_PARSE=FAIL\n"
        f"JSON_ERROR={error}\n",
        encoding="utf-8",
    )
    raise SystemExit(2)

records = {}
conflicts = []
all_strings = []


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

            record = {
                "property": property_id,
                "status": status.upper(),
                "description": description,
                "file": str(location.get("file", "")),
                "line": str(location.get("line", "")),
                "function": str(location.get("function", "")),
            }

            previous = records.get(property_id)

            if previous is not None and previous["status"] != record["status"]:
                conflicts.append(
                    (
                        property_id,
                        previous["status"],
                        record["status"],
                    )
                )

            records[property_id] = record

        for key, item in value.items():
            all_strings.append(str(key))
            walk(item)

    elif isinstance(value, list):
        for item in value:
            walk(item)

    elif isinstance(value, str):
        all_strings.append(value)


walk(data)

if not records:
    summary_path.write_text(
        "JSON_PARSE=PASS\n"
        "PROPERTY_RECORD_COUNT=0\n"
        "RESULT_AUDIT=FAIL\n",
        encoding="utf-8",
    )
    raise SystemExit(3)

if conflicts:
    summary_path.write_text(
        "JSON_PARSE=PASS\n"
        f"CONFLICTING_PROPERTY_STATUS_COUNT={len(conflicts)}\n"
        "RESULT_AUDIT=FAIL\n",
        encoding="utf-8",
    )
    raise SystemExit(4)

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

non_success = [
    record
    for record in ordered
    if record["status"] != "SUCCESS"
]

with failure_path.open(
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
        ]
    )

    for record in non_success:
        writer.writerow(
            [
                record["property"],
                record["status"],
                record["description"].replace("\n", " "),
            ]
        )

success_count = sum(
    record["status"] == "SUCCESS"
    for record in ordered
)

failure_count = sum(
    record["status"] == "FAILURE"
    for record in ordered
)

unknown_count = len(ordered) - success_count - failure_count

markers = [
    "MSG_T1_MODEL: polynomial degree must be 256",
    "MSG_T1_MODEL: message size must be 32 bytes",
    "MSG_T1_ORACLE: lower-zero boundary",
    "MSG_T1_ORACLE: lower-one boundary",
    "MSG_T1_ORACLE: upper-one boundary",
    "MSG_T1_ORACLE: upper-zero boundary",
    "MSG_T1_EXACT: every output bit must equal the independent Compress1 oracle",
]

marker_results = {}

for marker in markers:
    matches = [
        record
        for record in ordered
        if marker in record["description"]
    ]

    marker_results[marker] = matches

missing_markers = [
    marker
    for marker, matches in marker_results.items()
    if not matches
]

non_success_markers = [
    marker
    for marker, matches in marker_results.items()
    if matches
    and any(
        record["status"] != "SUCCESS"
        for record in matches
    )
]

exact_matches = marker_results[
    "MSG_T1_EXACT: every output bit must equal the independent Compress1 oracle"
]

d1_properties = {
    record["property"]: record
    for record in ordered
    if re.fullmatch(
        r"mlk_scalar_compress_d1\.overflow\.[0-9]+",
        record["property"],
    )
}

d1_required = [
    "mlk_scalar_compress_d1.overflow.1",
    "mlk_scalar_compress_d1.overflow.2",
]

d1_missing = [
    property_id
    for property_id in d1_required
    if property_id not in d1_properties
]

d1_non_success = [
    property_id
    for property_id in d1_required
    if property_id in d1_properties
    and d1_properties[property_id]["status"] != "SUCCESS"
]

d1_wrap_present = (
    "mlk_scalar_compress_d1.overflow.3"
    in d1_properties
)

verification_success_message = any(
    "VERIFICATION SUCCESSFUL" in value
    for value in all_strings
)

audit_pass = (
    success_count == len(ordered)
    and failure_count == 0
    and unknown_count == 0
    and not missing_markers
    and not non_success_markers
    and len(exact_matches) >= 1
    and not d1_missing
    and not d1_non_success
    and not d1_wrap_present
)

summary_lines = [
    "JSON_PARSE=PASS",
    f"PROPERTY_RECORD_COUNT={len(ordered)}",
    f"SUCCESS_COUNT={success_count}",
    f"FAILURE_COUNT={failure_count}",
    f"UNKNOWN_COUNT={unknown_count}",
    f"NON_SUCCESS_COUNT={len(non_success)}",
    f"EXPECTED_MARKER_COUNT={len(markers)}",
    f"FOUND_MARKER_COUNT={len(markers) - len(missing_markers)}",
    f"NON_SUCCESS_MARKER_COUNT={len(non_success_markers)}",
    f"MSG_T1_EXACT_MATCH_COUNT={len(exact_matches)}",
    (
        "MSG_T1_EXACT_STATUS=SUCCESS"
        if exact_matches
        and all(
            record["status"] == "SUCCESS"
            for record in exact_matches
        )
        else "MSG_T1_EXACT_STATUS=NOT_SUCCESS"
    ),
    f"D1_OVERFLOW_PROPERTY_COUNT={len(d1_properties)}",
    (
        "D1_CONVERSION_PROPERTY_1_STATUS="
        + d1_properties.get(
            "mlk_scalar_compress_d1.overflow.1",
            {"status": "MISSING"},
        )["status"]
    ),
    (
        "D1_CONVERSION_PROPERTY_2_STATUS="
        + d1_properties.get(
            "mlk_scalar_compress_d1.overflow.2",
            {"status": "MISSING"},
        )["status"]
    ),
    (
        "D1_INTENDED_ADDITION_WRAP_PROPERTY_PRESENT="
        + ("YES" if d1_wrap_present else "NO")
    ),
    (
        "VERIFICATION_SUCCESS_MESSAGE_PRESENT="
        + ("YES" if verification_success_message else "NO")
    ),
    (
        "RESULT_AUDIT=PASS"
        if audit_pass
        else "RESULT_AUDIT=FAIL"
    ),
]

summary_path.write_text(
    "\n".join(summary_lines) + "\n",
    encoding="utf-8",
)

print("\n".join(summary_lines))

raise SystemExit(0 if audit_pass else 20)
