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
    "main",
    "mlk_sub00r_b6_poly_sub",
    "mlk_sub00r_b6_poly_reduce",
    "mlk_sub00r_b6_poly_tomsg",
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
    match_loop = re.fullmatch(
        r"Loop\s+(\S+):",
        line.strip(),
    )

    if match_loop:
        current_id = match_loop.group(1)
        continue

    if current_id is not None:
        match_function = re.search(
            r"\bfunction\s+(\S+)\s*$",
            line,
        )

        if match_function:
            loop_records.append(
                (current_id, match_function.group(1))
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

verification_only_helpers = {
    "array_abs_bound",
    "array_bound",
    "cassert",
}

reachable_verification_helpers = sorted(
    verification_only_helpers & reachable
)

if reachable_verification_helpers:
    raise SystemExit(
        "VERIFICATION_HELPERS_REACHABLE_FROM_MAIN="
        + ",".join(reachable_verification_helpers)
    )

allowed_undefined = {
    "nondet_int16_t",
} | verification_only_helpers

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
print(
    "VERIFICATION_ONLY_UNDEFINED_HELPER_COUNT="
    + str(len(verification_only_helpers & set(undefined)))
)
print(
    "VERIFICATION_ONLY_HELPERS_REACHABLE_FROM_MAIN="
    + str(len(reachable_verification_helpers))
)
print(f"UNWINDSET={unwindset}")
