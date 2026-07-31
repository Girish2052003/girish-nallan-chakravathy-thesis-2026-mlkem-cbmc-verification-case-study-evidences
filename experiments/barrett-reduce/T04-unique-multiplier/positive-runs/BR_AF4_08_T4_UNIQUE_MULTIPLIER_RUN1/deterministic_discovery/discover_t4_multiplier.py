#!/usr/bin/env python3

from pathlib import Path
import sys

output_dir = Path(sys.argv[1])

Q = 3329
OFFSET = 1 << 25
DIVISOR = 1 << 26

INT16_MIN = -(1 << 15)
INT16_MAX = (1 << 15) - 1

INT32_MIN = -(1 << 31)
INT32_MAX = (1 << 31) - 1


def centered(a: int) -> int:
    value = a % Q

    if value > 1664:
        value -= Q

    return value


def quotient_for_multiplier(multiplier: int, a: int) -> int:
    return (multiplier * a + OFFSET) >> 26


def result_for_multiplier(multiplier: int, a: int) -> int:
    return a - quotient_for_multiplier(multiplier, a) * Q


def ceil_div(numerator: int, denominator: int) -> int:
    if denominator == 0:
        raise ZeroDivisionError

    return -((-numerator) // denominator)


# Complete nonnegative numerator-safe multiplier range.
safe_multipliers = []

for multiplier in range(0, 70001):
    minimum_numerator = multiplier * INT16_MIN + OFFSET
    maximum_numerator = multiplier * INT16_MAX + OFFSET

    if (
        INT32_MIN <= minimum_numerator <= INT32_MAX
        and INT32_MIN <= maximum_numerator <= INT32_MAX
    ):
        safe_multipliers.append(multiplier)

if not safe_multipliers:
    raise SystemExit("No safe multipliers discovered")

safe_lower = min(safe_multipliers)
safe_upper = max(safe_multipliers)

if safe_lower != 0:
    raise SystemExit(f"Unexpected safe lower bound: {safe_lower}")

if safe_upper != 64513:
    raise SystemExit(f"Unexpected safe upper bound: {safe_upper}")

# Intersect exact per-input multiplier constraints.
global_lower = safe_lower
global_upper = safe_upper
binding_rows = []

for a in range(INT16_MIN, INT16_MAX + 1):
    target = centered(a)
    target_quotient = (a - target) // Q

    numerator_lower = target_quotient * DIVISOR - OFFSET
    numerator_upper = (
        (target_quotient + 1) * DIVISOR - 1 - OFFSET
    )

    if a > 0:
        input_lower = ceil_div(numerator_lower, a)
        input_upper = numerator_upper // a

    elif a < 0:
        input_lower = ceil_div(numerator_upper, a)
        input_upper = numerator_lower // a

    else:
        input_lower = -(1 << 63)
        input_upper = (1 << 63) - 1

    previous_lower = global_lower
    previous_upper = global_upper

    global_lower = max(global_lower, input_lower)
    global_upper = min(global_upper, input_upper)

    if (
        global_lower != previous_lower
        or global_upper != previous_upper
    ):
        binding_rows.append(
            (
                a,
                target_quotient,
                input_lower,
                input_upper,
                global_lower,
                global_upper,
            )
        )

if (global_lower, global_upper) != (20159, 20159):
    raise SystemExit(
        "Unexpected exact multiplier intersection: "
        f"{global_lower}..{global_upper}"
    )

# Full-domain sufficiency.
for a in range(INT16_MIN, INT16_MAX + 1):
    if result_for_multiplier(20159, a) != centered(a):
        raise SystemExit(
            f"20159 failed at a={a}"
        )

# Complete lower and upper exclusions using adjacent witnesses.
lower_witness = -31626
upper_witness = -31625

for multiplier in range(0, 20159):
    if (
        result_for_multiplier(multiplier, lower_witness)
        == centered(lower_witness)
    ):
        raise SystemExit(
            f"Lower multiplier unexpectedly survived: {multiplier}"
        )

for multiplier in range(20160, safe_upper + 1):
    if (
        result_for_multiplier(multiplier, upper_witness)
        == centered(upper_witness)
    ):
        raise SystemExit(
            f"Upper multiplier unexpectedly survived: {multiplier}"
        )

binding_table = output_dir / "binding_constraints.tsv"

with binding_table.open("w", encoding="utf-8") as f:
    f.write(
        "input_a\ttarget_quotient\tinput_multiplier_lower\t"
        "input_multiplier_upper\tglobal_lower\tglobal_upper\n"
    )

    for row in binding_rows:
        f.write("\t".join(str(value) for value in row) + "\n")

controls = [
    (0, -31626),
    (20158, -31626),
    (20159, -31626),
    (20159, -31625),
    (20160, -31625),
    (64513, -31625),
    (64513, 32767),
    (64514, 32767),
]

control_table = output_dir / "control_values.tsv"

with control_table.open("w", encoding="utf-8") as f:
    f.write(
        "multiplier\tinput_a\tnumerator\tquotient\t"
        "candidate_result\tcentered_result\n"
    )

    for multiplier, a in controls:
        numerator = multiplier * a + OFFSET
        quotient = quotient_for_multiplier(multiplier, a)
        result = result_for_multiplier(multiplier, a)

        f.write(
            f"{multiplier}\t{a}\t{numerator}\t{quotient}\t"
            f"{result}\t{centered(a)}\n"
        )

summary = output_dir / "discovery_summary.txt"

summary.write_text(
    "\n".join(
        [
            "DISCOVERY_METHOD=DETERMINISTIC_EXHAUSTIVE_AND_INTERVAL_INTERSECTION",
            "AUTHORITATIVE_FORMAL_RESULT=CBMC_PENDING",
            "SAFE_MULTIPLIER_LOWER=0",
            "SAFE_MULTIPLIER_UPPER=64513",
            "SAFE_MULTIPLIER_COUNT=64514",
            "FIRST_UNSAFE_MULTIPLIER=64514",
            "FIRST_UNSAFE_WITNESS_A=32767",
            "FIRST_UNSAFE_NUMERATOR=2147484670",
            "EXACT_CORRECT_MULTIPLIER_LOWER=20159",
            "EXACT_CORRECT_MULTIPLIER_UPPER=20159",
            "EXACT_CORRECT_MULTIPLIER_COUNT=1",
            "LOWER_EXCLUSION_WITNESS_A=-31626",
            "UPPER_EXCLUSION_WITNESS_A=-31625",
            "M_20158_LOWER_WITNESS_RESULT=-1665",
            "M_20159_LOWER_WITNESS_RESULT=1664",
            "M_20159_UPPER_WITNESS_RESULT=-1664",
            "M_20160_UPPER_WITNESS_RESULT=1665",
            "M_20159_FULL_INT16_DOMAIN=PASS",
            "ALL_LOWER_MULTIPLIERS_REJECTED=PASS",
            "ALL_UPPER_MULTIPLIERS_REJECTED=PASS",
            "ENUMERATION_IS_CROSS_CHECK_NOT_FORMAL_PROOF=YES",
            "",
        ]
    ),
    encoding="utf-8",
)
