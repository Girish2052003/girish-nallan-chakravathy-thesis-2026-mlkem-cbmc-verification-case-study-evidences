#!/usr/bin/env python3
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])

try:
    data = json.loads(src.read_text(encoding="utf-8"))
except Exception as exc:
    raise SystemExit(f"JSON_PARSE_ERROR={exc}")

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
total = len(unique)

lines = [
    f"SUCCESS={success}",
    f"FAILURE={failure}",
    f"UNKNOWN={unknown}",
    f"TOTAL_RESULTS={total}",
]

for prop, status, desc in unique:
    lines.append(
        f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}"
    )

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if total < 1:
    raise SystemExit("NO_PROPERTY_RESULTS")
if failure != 0:
    raise SystemExit(f"FAILURE_RESULTS={failure}")
if unknown != 0:
    raise SystemExit(f"UNKNOWN_RESULTS={unknown}")
if success != total:
    raise SystemExit(
        f"SUCCESS_TOTAL_MISMATCH={success}/{total}"
    )
