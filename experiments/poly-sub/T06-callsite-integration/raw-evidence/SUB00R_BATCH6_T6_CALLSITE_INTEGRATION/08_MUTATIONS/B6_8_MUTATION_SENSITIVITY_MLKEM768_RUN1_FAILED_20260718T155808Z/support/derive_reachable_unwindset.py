#!/usr/bin/env python3
import re
import sys
from collections import defaultdict, deque
from pathlib import Path

(
    graph_path,
    loops_path,
    undefined_path,
    reachable_out,
    loops_out,
    unwind_out,
    required_csv,
    allowed_undefined_csv,
) = sys.argv[1:]

graph_text = Path(graph_path).read_text(
    encoding="utf-8", errors="replace"
)
loops_text = Path(loops_path).read_text(
    encoding="utf-8", errors="replace"
)
undefined_text = Path(undefined_path).read_text(
    encoding="utf-8", errors="replace"
)

edges = defaultdict(set)

for line in graph_text.splitlines():
    match = re.fullmatch(
        r"(\S+)\s+->\s+(\S+)",
        line.strip(),
    )
    if match:
        edges[match.group(1)].add(match.group(2))

reachable = set()
queue = deque(["main"])

while queue:
    function = queue.popleft()

    if function in reachable:
        continue

    reachable.add(function)

    for target in sorted(edges.get(function, set())):
        if target not in reachable:
            queue.append(target)

required = {
    item for item in required_csv.split(",")
    if item
}

missing = sorted(required - reachable)

if missing:
    raise SystemExit(
        "REQUIRED_REACHABLE_FUNCTIONS_MISSING="
        + ",".join(missing)
    )

loop_records = []
current_id = None

for line in loops_text.splitlines():
    loop_match = re.fullmatch(
        r"Loop\s+(\S+):",
        line.strip(),
    )

    if loop_match:
        current_id = loop_match.group(1)
        continue

    if current_id is not None:
        function_match = re.search(
            r"\bfunction\s+(\S+)\s*$",
            line,
        )

        if function_match:
            loop_records.append(
                (current_id, function_match.group(1))
            )
            current_id = None

reachable_loops = sorted(
    (loop_id, owner)
    for loop_id, owner in loop_records
    if owner in reachable
)

if not reachable_loops:
    raise SystemExit("NO_REACHABLE_LOOPS")

undefined = []

for raw_line in undefined_text.splitlines():
    line = raw_line.strip()

    if not line:
        continue
    if line.startswith("Reading GOTO program"):
        continue

    undefined.append(line)

allowed_undefined = {
    item for item in allowed_undefined_csv.split(",")
    if item
}

unexpected = sorted(
    name for name in undefined
    if name not in allowed_undefined
    and not name.startswith("__CPROVER_")
)

if unexpected:
    raise SystemExit(
        "UNEXPECTED_UNDEFINED_FUNCTIONS="
        + ",".join(unexpected)
    )

contract_helpers = {
    "array_abs_bound",
    "array_bound",
    "cassert",
}

bad_reachable_helpers = sorted(
    contract_helpers & reachable
)
bad_undefined_helpers = sorted(
    contract_helpers & set(undefined)
)

if bad_reachable_helpers:
    raise SystemExit(
        "CONTRACT_HELPERS_REACHABLE="
        + ",".join(bad_reachable_helpers)
    )

if bad_undefined_helpers:
    raise SystemExit(
        "CONTRACT_HELPERS_UNDEFINED="
        + ",".join(bad_undefined_helpers)
    )

Path(reachable_out).write_text(
    "\n".join(sorted(reachable)) + "\n",
    encoding="utf-8",
)

Path(loops_out).write_text(
    "LOOP_ID\tOWNER_FUNCTION\n"
    + "".join(
        f"{loop_id}\t{owner}\n"
        for loop_id, owner in reachable_loops
    ),
    encoding="utf-8",
)

unwindset = ",".join(
    f"{loop_id}:257"
    for loop_id, _ in reachable_loops
)

Path(unwind_out).write_text(
    unwindset + "\n",
    encoding="utf-8",
)

print(f"REACHABLE_FUNCTION_COUNT={len(reachable)}")
print(f"GLOBAL_LOOP_COUNT={len(loop_records)}")
print(f"REACHABLE_LOOP_COUNT={len(reachable_loops)}")
print(
    "UNEXPECTED_UNDEFINED_FUNCTION_COUNT="
    + str(len(unexpected))
)
print("CONTRACT_HELPERS_REACHABLE=0")
print("CONTRACT_HELPERS_UNDEFINED=0")
print(f"UNWINDSET={unwindset}")
