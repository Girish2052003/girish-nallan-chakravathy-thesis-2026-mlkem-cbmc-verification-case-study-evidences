#!/usr/bin/env python3

import re
import sys
from collections import defaultdict, deque
from pathlib import Path

if len(sys.argv) != 7:
    raise SystemExit(
        "usage: derive CALL_GRAPH LOOPS UNDEFINED "
        "FUNCTIONS_OUT LOOPS_OUT UNWIND_OUT"
    )

call_path = Path(sys.argv[1])
loops_path = Path(sys.argv[2])
undefined_path = Path(sys.argv[3])
functions_out = Path(sys.argv[4])
loops_out = Path(sys.argv[5])
unwind_out = Path(sys.argv[6])

call_text = call_path.read_text(
    encoding="utf-8",
    errors="replace",
)

loops_text = loops_path.read_text(
    encoding="utf-8",
    errors="replace",
)

undefined_text = undefined_path.read_text(
    encoding="utf-8",
    errors="replace",
)

edges = defaultdict(set)

for line in call_text.splitlines():
    match = re.fullmatch(
        r"(\S+)\s*->\s*(\S+)",
        line.strip(),
    )

    if match:
        caller, callee = match.groups()
        edges[caller].add(callee)

reachable = set()
queue = deque(["main"])

while queue:
    function = queue.popleft()

    if function in reachable:
        continue

    reachable.add(function)

    for callee in sorted(edges.get(function, set())):
        if callee not in reachable:
            queue.append(callee)

expected_functions = {
    "main",
    "msg_t1_threshold_oracle",
    "mlk_msg01k_poly_tomsg",
    "mlk_scalar_compress_d1",
}

if reachable != expected_functions:
    raise SystemExit(
        "REACHABLE_FUNCTION_SET_MISMATCH="
        + ",".join(sorted(reachable))
    )

unexpected_undefined = []

for raw_line in undefined_text.splitlines():
    name = raw_line.strip()

    if not name:
        continue

    if name.startswith("Reading GOTO program"):
        continue

    if not name.startswith("__CPROVER_"):
        unexpected_undefined.append(name)

if unexpected_undefined:
    raise SystemExit(
        "UNEXPECTED_UNDEFINED_FUNCTIONS="
        + ",".join(sorted(unexpected_undefined))
    )

records = []
lines = loops_text.splitlines()

for index, line in enumerate(lines):
    match = re.match(
        r"^Loop ([^:]+):\s*$",
        line.strip(),
    )

    if not match:
        continue

    loop_id = match.group(1)
    owner = None

    for following in lines[index + 1:index + 6]:
        owner_match = re.search(
            r"\bfunction\s+(\S+)",
            following,
        )

        if owner_match:
            owner = owner_match.group(1)
            break

    if owner is None:
        raise SystemExit(
            "LOOP_OWNER_NOT_FOUND="
            + loop_id
        )

    records.append((loop_id, owner))

reachable_loops = sorted(
    (loop_id, owner)
    for loop_id, owner in records
    if owner in reachable
)

expected_loop_ids = {
    "main.0",
    "main.1",
    "mlk_msg01k_poly_tomsg.0",
    "mlk_msg01k_poly_tomsg.1",
    "mlk_msg01k_poly_tomsg.2",
}

actual_loop_ids = {
    loop_id
    for loop_id, _ in reachable_loops
}

if actual_loop_ids != expected_loop_ids:
    raise SystemExit(
        "REACHABLE_LOOP_SET_MISMATCH="
        + ",".join(sorted(actual_loop_ids))
    )

functions_out.write_text(
    "\n".join(sorted(reachable)) + "\n",
    encoding="utf-8",
)

loops_out.write_text(
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

unwind_out.write_text(
    unwindset + "\n",
    encoding="utf-8",
)

print("REACHABLE_FUNCTION_COUNT=4")
print("REACHABLE_LOOP_COUNT=5")
print("UNEXPECTED_UNDEFINED_FUNCTION_COUNT=0")
print(f"UNWINDSET={unwindset}")
print("MUTANT_MODEL_DERIVATION=PASS")
