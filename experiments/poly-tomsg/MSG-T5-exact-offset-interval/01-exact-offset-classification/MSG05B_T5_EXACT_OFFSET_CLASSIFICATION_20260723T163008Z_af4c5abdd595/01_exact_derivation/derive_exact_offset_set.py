#!/usr/bin/env python3

import json
from pathlib import Path

MODULUS_32 = 1 << 32
HALF_32 = 1 << 31
MASK_32 = MODULUS_32 - 1

MLKEM_Q = 3329
MULTIPLIER = 1290168
PRODUCTION_OFFSET = 1 << 30

EXPECTED_LOWER = 1073417800
EXPECTED_UPPER = 1074063871


def oracle(u: int) -> int:
    return int(833 <= u <= 2496)


def implementation(u: int, offset: int) -> int:
    d0 = (u * MULTIPLIER) & MASK_32
    total = (d0 + offset) & MASK_32
    return total >> 31


def allowed_intervals(u: int) -> list[tuple[int, int]]:
    """
    Return all uint32 offsets for which the top bit of
    ((u * MULTIPLIER) + offset) modulo 2^32 equals oracle(u).
    """
    d0 = (u * MULTIPLIER) & MASK_32
    desired = oracle(u)

    start = (desired * HALF_32 - d0) % MODULUS_32
    end = ((desired + 1) * HALF_32 - 1 - d0) % MODULUS_32

    if start <= end:
        return [(start, end)]

    return [(0, end), (start, MASK_32)]


def intersect(
    left: list[tuple[int, int]],
    right: list[tuple[int, int]],
) -> list[tuple[int, int]]:
    intersections: list[tuple[int, int]] = []

    for left_lower, left_upper in left:
        for right_lower, right_upper in right:
            lower = max(left_lower, right_lower)
            upper = min(left_upper, right_upper)

            if lower <= upper:
                intersections.append((lower, upper))

    intersections.sort()

    merged: list[tuple[int, int]] = []

    for lower, upper in intersections:
        if merged and lower <= merged[-1][1] + 1:
            old_lower, old_upper = merged[-1]
            merged[-1] = (old_lower, max(old_upper, upper))
        else:
            merged.append((lower, upper))

    return merged


admissible: list[tuple[int, int]] = [(0, MASK_32)]
tightening_steps: list[dict[str, object]] = []

for u in range(MLKEM_Q):
    previous = admissible
    admissible = intersect(admissible, allowed_intervals(u))

    if admissible != previous:
        tightening_steps.append(
            {
                "u": u,
                "oracle": oracle(u),
                "previous": previous,
                "new": admissible,
            }
        )

    if not admissible:
        raise RuntimeError("No admissible offset exists")


assert admissible == [(EXPECTED_LOWER, EXPECTED_UPPER)], admissible

lower, upper = admissible[0]

for offset in (lower, upper, PRODUCTION_OFFSET):
    failures = [
        u
        for u in range(MLKEM_Q)
        if implementation(u, offset) != oracle(u)
    ]

    assert failures == [], (offset, failures)


lower_outside = lower - 1
upper_outside = upper + 1

lower_outside_failures = [
    u
    for u in range(MLKEM_Q)
    if implementation(u, lower_outside) != oracle(u)
]

upper_outside_failures = [
    u
    for u in range(MLKEM_Q)
    if implementation(u, upper_outside) != oracle(u)
]

assert lower_outside_failures == [2497], lower_outside_failures
assert upper_outside_failures == [832], upper_outside_failures

critical_inputs = {}

for u in (832, 833, 2496, 2497):
    d0 = (u * MULTIPLIER) & MASK_32

    critical_inputs[str(u)] = {
        "d0": d0,
        "oracle": oracle(u),
        "allowed_intervals": allowed_intervals(u),
    }

result = {
    "domain": {
        "u_lower": 0,
        "u_upper": MLKEM_Q - 1,
        "offset_lower": 0,
        "offset_upper": MASK_32,
    },
    "expression": {
        "multiplier": MULTIPLIER,
        "offset_type": "uint32_t",
        "shift": 31,
        "wrap_modulus": MODULUS_32,
    },
    "reference_decision": {
        "one_lower": 833,
        "one_upper": 2496,
    },
    "exact_admissible_set": {
        "shape": "single_closed_interval",
        "lower": lower,
        "upper": upper,
        "cardinality": upper - lower + 1,
    },
    "production_offset": {
        "value": PRODUCTION_OFFSET,
        "is_admissible": lower <= PRODUCTION_OFFSET <= upper,
        "distance_above_lower": PRODUCTION_OFFSET - lower,
        "distance_below_upper": upper - PRODUCTION_OFFSET,
    },
    "nearest_rejected_offsets": {
        "below": {
            "offset": lower_outside,
            "failing_inputs": lower_outside_failures,
        },
        "above": {
            "offset": upper_outside,
            "failing_inputs": upper_outside_failures,
        },
    },
    "critical_inputs": critical_inputs,
    "tightening_step_count": len(tightening_steps),
}

output_directory = Path(__file__).resolve().parent

(output_directory / "exact_offset_set.json").write_text(
    json.dumps(result, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

with (output_directory / "exact_offset_set.txt").open(
    "w",
    encoding="utf-8",
) as output:
    output.write(f"FIXED_MULTIPLIER={MULTIPLIER}\n")
    output.write(f"SHIFT=31\n")
    output.write("OFFSET_DOMAIN=UINT32\n")
    output.write("UINT32_WRAP_SEMANTICS=YES\n")
    output.write(f"EXACT_ADMISSIBLE_LOWER={lower}\n")
    output.write(f"EXACT_ADMISSIBLE_UPPER={upper}\n")
    output.write(f"ADMISSIBLE_OFFSET_COUNT={upper - lower + 1}\n")
    output.write(f"PRODUCTION_OFFSET={PRODUCTION_OFFSET}\n")
    output.write("PRODUCTION_OFFSET_ADMISSIBLE=YES\n")
    output.write(
        f"PRODUCTION_DISTANCE_ABOVE_LOWER={PRODUCTION_OFFSET - lower}\n"
    )
    output.write(
        f"PRODUCTION_DISTANCE_BELOW_UPPER={upper - PRODUCTION_OFFSET}\n"
    )
    output.write(f"LOWER_NEAREST_REJECTED={lower_outside}\n")
    output.write("LOWER_NEAREST_REJECTED_WITNESS_U=2497\n")
    output.write(f"UPPER_NEAREST_REJECTED={upper_outside}\n")
    output.write("UPPER_NEAREST_REJECTED_WITNESS_U=832\n")
    output.write("ADMISSIBLE_SET_SHAPE=SINGLE_CLOSED_INTERVAL\n")
    output.write("DETERMINISTIC_DERIVATION=PASS\n")

with (output_directory / "critical_constraints.tsv").open(
    "w",
    encoding="utf-8",
) as output:
    output.write("u\td0\toracle\tallowed_intervals\n")

    for u in (832, 833, 2496, 2497):
        information = critical_inputs[str(u)]
        output.write(
            f"{u}\t"
            f"{information['d0']}\t"
            f"{information['oracle']}\t"
            f"{information['allowed_intervals']}\n"
        )

with (output_directory / "tightening_steps.json").open(
    "w",
    encoding="utf-8",
) as output:
    json.dump(tightening_steps, output, indent=2, sort_keys=True)
    output.write("\n")

print("DETERMINISTIC_INTERVAL_DERIVATION=PASS")
print(f"EXACT_ADMISSIBLE_LOWER={lower}")
print(f"EXACT_ADMISSIBLE_UPPER={upper}")
print(f"ADMISSIBLE_OFFSET_COUNT={upper - lower + 1}")
print(f"PRODUCTION_OFFSET={PRODUCTION_OFFSET}")
print("PRODUCTION_OFFSET_ADMISSIBLE=YES")
print(f"LOWER_NEAREST_REJECTED={lower_outside}")
print("LOWER_NEAREST_REJECTED_WITNESS_U=2497")
print(f"UPPER_NEAREST_REJECTED={upper_outside}")
print("UPPER_NEAREST_REJECTED_WITNESS_U=832")
print("ADMISSIBLE_SET_SHAPE=SINGLE_CLOSED_INTERVAL")
