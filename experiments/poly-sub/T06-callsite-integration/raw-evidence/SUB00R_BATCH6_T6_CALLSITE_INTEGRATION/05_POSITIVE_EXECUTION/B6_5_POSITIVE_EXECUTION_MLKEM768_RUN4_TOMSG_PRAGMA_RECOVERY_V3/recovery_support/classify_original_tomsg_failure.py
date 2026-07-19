#!/usr/bin/env python3
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
expected_property = sys.argv[3]
expected_description = sys.argv[4]

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
    key = (
        str(rec.get("property", "")),
        str(rec.get("status", "")),
        str(rec.get("description", "")),
    )
    if key not in seen:
        seen.add(key)
        unique.append(rec)

failures = [
    rec for rec in unique
    if str(rec.get("status", "")) == "FAILURE"
]
unknown = [
    rec for rec in unique
    if str(rec.get("status", ""))
    not in {"SUCCESS", "FAILURE"}
]

if len(failures) != 1:
    raise SystemExit(
        f"ORIGINAL_FAILURE_COUNT={len(failures)}"
    )

failure = failures[0]
prop = str(failure.get("property", ""))
desc = str(failure.get("description", ""))

if prop != expected_property:
    raise SystemExit(
        f"UNEXPECTED_FAILED_PROPERTY={prop}"
    )

if desc != expected_description:
    raise SystemExit(
        f"UNEXPECTED_FAILED_DESCRIPTION={desc}"
    )

trace = failure.get("trace", [])
u_values = []
d0_values = []

for step in trace:
    if not isinstance(step, dict):
        continue

    lhs = str(step.get("lhs", ""))
    value = step.get("value", {})
    data_value = ""

    if isinstance(value, dict):
        data_value = str(value.get("data", ""))

    if lhs == "u":
        u_values.append(data_value)

    if lhs == "d0":
        d0_values.append(data_value)

lines = [
    f"TOTAL_RESULTS={len(unique)}",
    f"SUCCESS={sum(1 for rec in unique if rec.get('status') == 'SUCCESS')}",
    f"FAILURE={len(failures)}",
    f"UNKNOWN={len(unknown)}",
    f"FAILED_PROPERTY={prop}",
    f"FAILED_DESCRIPTION={desc}",
    f"SOURCE_FILE={failure.get('sourceLocation', {}).get('file', '')}",
    f"SOURCE_LINE={failure.get('sourceLocation', {}).get('line', '')}",
    f"TRACE_STEP_COUNT={len(trace)}",
    f"LAST_U_VALUE={u_values[-1] if u_values else ''}",
    f"LAST_D0_VALUE={d0_values[-1] if d0_values else ''}",
]

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if unknown:
    raise SystemExit(
        f"ORIGINAL_UNKNOWN_COUNT={len(unknown)}"
    )
