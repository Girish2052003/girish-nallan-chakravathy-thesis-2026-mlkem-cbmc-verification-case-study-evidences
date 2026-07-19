#!/usr/bin/env python3
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
marker = sys.argv[3]

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

target = [
    item for item in unique
    if marker in item[0] or marker in item[2]
]

target_failures = sum(
    1 for _, status, _ in target
    if status == "FAILURE"
)

other_failures = sum(
    1 for prop, status, desc in unique
    if status == "FAILURE"
    and marker not in prop
    and marker not in desc
)

unknown = sum(
    1 for _, status, _ in unique
    if status not in {"SUCCESS", "FAILURE"}
)

success = sum(
    1 for _, status, _ in unique
    if status == "SUCCESS"
)

target_property = ""

for prop, status, _ in target:
    if status == "FAILURE":
        target_property = prop
        break

lines = [
    f"SUCCESS={success}",
    f"TARGET_FAILURE={target_failures}",
    f"OTHER_FAILURE={other_failures}",
    f"UNKNOWN={unknown}",
    f"TOTAL_RESULTS={len(unique)}",
    f"TARGET_PROPERTY={target_property}",
]

for prop, status, desc in unique:
    lines.append(
        f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}"
    )

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if not unique:
    raise SystemExit("NO_PROPERTY_RESULTS")
if len(target) != 1:
    raise SystemExit(f"TARGET_RECORD_COUNT={len(target)}")
if target_failures != 1:
    raise SystemExit(
        f"TARGET_FAILURE_COUNT={target_failures}"
    )
if other_failures != 0:
    raise SystemExit(
        f"OTHER_FAILURE_COUNT={other_failures}"
    )
if unknown != 0:
    raise SystemExit(f"UNKNOWN_COUNT={unknown}")
if not target_property:
    raise SystemExit("TARGET_PROPERTY_MISSING")
