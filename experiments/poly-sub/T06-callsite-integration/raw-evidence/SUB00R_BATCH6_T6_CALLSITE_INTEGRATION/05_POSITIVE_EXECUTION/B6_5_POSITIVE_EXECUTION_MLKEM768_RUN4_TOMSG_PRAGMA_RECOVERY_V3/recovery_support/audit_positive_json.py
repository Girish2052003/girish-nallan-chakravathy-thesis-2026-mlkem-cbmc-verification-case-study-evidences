#!/usr/bin/env python3
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])

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

success = sum(1 for _, status, _ in unique if status == "SUCCESS")
failure = sum(1 for _, status, _ in unique if status == "FAILURE")
unknown = sum(
    1 for _, status, _ in unique
    if status not in {"SUCCESS", "FAILURE"}
)

lines = [
    f"SUCCESS={success}",
    f"FAILURE={failure}",
    f"UNKNOWN={unknown}",
    f"TOTAL_RESULTS={len(unique)}",
]

for prop, status, desc in unique:
    lines.append(
        f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}"
    )

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if not unique:
    raise SystemExit("NO_PROPERTY_RESULTS")
if failure != 0:
    raise SystemExit(f"FAILURE_RESULTS={failure}")
if unknown != 0:
    raise SystemExit(f"UNKNOWN_RESULTS={unknown}")
if success != len(unique):
    raise SystemExit(
        f"SUCCESS_TOTAL_MISMATCH={success}/{len(unique)}"
    )
