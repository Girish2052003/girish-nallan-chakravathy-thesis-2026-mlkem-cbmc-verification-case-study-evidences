#!/usr/bin/env python3

import csv
import json
import re
import sys
from pathlib import Path

if len(sys.argv) != 6:
    raise SystemExit(
        "usage: parser RESULT.json EXPECTED_UNWIND.txt "
        "ALL.tsv FAILURES.tsv SUMMARY.txt"
    )

json_path = Path(sys.argv[1])
expected_path = Path(sys.argv[2])
all_path = Path(sys.argv[3])
failure_path = Path(sys.argv[4])
summary_path = Path(sys.argv[5])

expected_unwind = {
    line.strip()
    for line in expected_path.read_text(
        encoding="utf-8",
        errors="strict",
    ).splitlines()
    if line.strip()
}

if len(expected_unwind) != 5:
    raise SystemExit(
        "EXPECTED_UNWIND_PROPERTY_COUNT_NOT_5"
    )

data = json.loads(
    json_path.read_text(
        encoding="utf-8",
        errors="strict",
    )
)

records = {}
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

            records[property_id] = {
                "property": property_id,
                "status": status.upper(),
                "description": description,
                "file": str(location.get("file", "")),
                "line": str(location.get("line", "")),
                "function": str(location.get("function", "")),
            }

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

unknown_count = (
    len(ordered)
    - success_count
    - failure_count
)

markers = [
    "MSG_T1_REACH_MODEL: polynomial degree must be 256",
    "MSG_T1_REACH_MODEL: message size must be 32 bytes",
    "MSG_T1_REACH_ANCHOR_EXACT: every output bit must match independent oracle",
]

marker_matches = {
    marker: [
        record
        for record in ordered
        if marker in record["description"]
    ]
    for marker in markers
}

missing_markers = [
    marker
    for marker, matches in marker_matches.items()
    if not matches
]

non_success_markers = [
    marker
    for marker, matches in marker_matches.items()
    if matches
    and any(
        record["status"] != "SUCCESS"
        for record in matches
    )
]

anchor_marker = markers[2]
anchor_matches = marker_matches[anchor_marker]

actual_unwind = {
    property_id
    for property_id in records
    if re.fullmatch(
        r"(main|mlk_msg01i_poly_tomsg)\.unwind\.[0-9]+",
        property_id,
    )
}

missing_unwind = expected_unwind - actual_unwind
unexpected_unwind = actual_unwind - expected_unwind

non_success_unwind = {
    property_id
    for property_id in expected_unwind
    if property_id in records
    and records[property_id]["status"] != "SUCCESS"
}

d1_required = {
    "mlk_scalar_compress_d1.overflow.1",
    "mlk_scalar_compress_d1.overflow.2",
}

d1_missing = d1_required - set(records)

d1_non_success = {
    property_id
    for property_id in d1_required
    if property_id in records
    and records[property_id]["status"] != "SUCCESS"
}

d1_wrap_present = (
    "mlk_scalar_compress_d1.overflow.3"
    in records
)

verification_success = any(
    "VERIFICATION SUCCESSFUL" in value
    for value in all_strings
)

audit_pass = (
    success_count == len(ordered)
    and failure_count == 0
    and unknown_count == 0
    and not missing_markers
    and not non_success_markers
    and anchor_matches
    and all(
        record["status"] == "SUCCESS"
        for record in anchor_matches
    )
    and not missing_unwind
    and not unexpected_unwind
    and not non_success_unwind
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
    f"ANCHOR_MATCH_COUNT={len(anchor_matches)}",
    (
        "ANCHOR_STATUS=SUCCESS"
        if anchor_matches
        and all(
            record["status"] == "SUCCESS"
            for record in anchor_matches
        )
        else "ANCHOR_STATUS=NOT_SUCCESS"
    ),
    f"EXPECTED_UNWIND_PROPERTY_COUNT={len(expected_unwind)}",
    f"FOUND_UNWIND_PROPERTY_COUNT={len(actual_unwind)}",
    f"MISSING_UNWIND_PROPERTY_COUNT={len(missing_unwind)}",
    f"UNEXPECTED_UNWIND_PROPERTY_COUNT={len(unexpected_unwind)}",
    f"NON_SUCCESS_UNWIND_PROPERTY_COUNT={len(non_success_unwind)}",
    (
        "UNWIND_PROPERTY_SET_MATCH=PASS"
        if actual_unwind == expected_unwind
        else "UNWIND_PROPERTY_SET_MATCH=FAIL"
    ),
    (
        "D1_CONVERSION_PROPERTY_1_STATUS="
        + records.get(
            "mlk_scalar_compress_d1.overflow.1",
            {"status": "MISSING"},
        )["status"]
    ),
    (
        "D1_CONVERSION_PROPERTY_2_STATUS="
        + records.get(
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
        + ("YES" if verification_success else "NO")
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
