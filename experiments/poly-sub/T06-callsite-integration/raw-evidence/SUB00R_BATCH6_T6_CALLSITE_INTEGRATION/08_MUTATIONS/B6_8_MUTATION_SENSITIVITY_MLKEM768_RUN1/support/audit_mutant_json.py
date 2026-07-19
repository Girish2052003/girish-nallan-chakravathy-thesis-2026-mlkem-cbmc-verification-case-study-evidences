#!/usr/bin/env python3
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
markers = [m for m in sys.argv[3].split(",") if m]

data = json.loads(src.read_text(encoding="utf-8"))
records = []

def walk(obj):
    if isinstance(obj, dict):
        if "property" in obj and "status" in obj:
            records.append(obj)
        for value in obj.values():
            walk(value)
    elif isinstance(obj, list):
        for value in obj:
            walk(value)

walk(data)

seen = set()
unique = []

for rec in records:
    item = (
        str(rec.get("property", "")),
        str(rec.get("status", "")),
        str(rec.get("description", "")),
    )
    if item not in seen:
        seen.add(item)
        unique.append(item)

def matches_marker(item):
    prop, _, desc = item
    return any(marker in prop or marker in desc for marker in markers)

target_records = [item for item in unique if matches_marker(item)]
target_failures = [
    item for item in target_records
    if item[1] == "FAILURE"
]
other_failures = [
    item for item in unique
    if item[1] == "FAILURE" and not matches_marker(item)
]
unknown = [
    item for item in unique
    if item[1] not in {"SUCCESS", "FAILURE"}
]
success = [
    item for item in unique
    if item[1] == "SUCCESS"
]

marker_presence = {
    marker: any(
        marker in prop or marker in desc
        for prop, _, desc in unique
    )
    for marker in markers
}

target_property = (
    target_failures[0][0]
    if target_failures
    else ""
)

target_marker = ""

if target_failures:
    prop, _, desc = target_failures[0]
    for marker in markers:
        if marker in prop or marker in desc:
            target_marker = marker
            break

lines = [
    f"SUCCESS={len(success)}",
    f"TARGET_FAILURE={len(target_failures)}",
    f"OTHER_FAILURE={len(other_failures)}",
    f"UNKNOWN={len(unknown)}",
    f"TOTAL_RESULTS={len(unique)}",
    f"TARGET_PROPERTY={target_property}",
    f"TARGET_MARKER={target_marker}",
    f"EXPECTED_MARKER_COUNT={len(markers)}",
    f"PRESENT_MARKER_COUNT={sum(marker_presence.values())}",
]

for marker in markers:
    lines.append(
        f"MARKER_{marker}="
        + ("PRESENT" if marker_presence[marker] else "MISSING")
    )

for prop, status, desc in unique:
    lines.append(
        f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}"
    )

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if not unique:
    raise SystemExit("NO_PROPERTY_RESULTS")
if not markers:
    raise SystemExit("NO_EXPECTED_MARKERS")
if not all(marker_presence.values()):
    missing = [
        marker for marker, present in marker_presence.items()
        if not present
    ]
    raise SystemExit(
        "EXPECTED_MARKERS_MISSING=" + ",".join(missing)
    )
if len(target_failures) < 1:
    raise SystemExit("TARGET_FAILURE_COUNT=0")
if other_failures:
    raise SystemExit(
        f"OTHER_FAILURE_COUNT={len(other_failures)}"
    )
if unknown:
    raise SystemExit(
        f"UNKNOWN_COUNT={len(unknown)}"
    )
if not target_property:
    raise SystemExit("TARGET_PROPERTY_MISSING")
if not target_marker:
    raise SystemExit("TARGET_MARKER_MISSING")
