#!/usr/bin/env python3

from pathlib import Path
import sys

output_dir = Path(sys.argv[1])

Q = 3329
MULTIPLIER = 20159
SHIFT = 26
DIVISOR = 1 << SHIFT

OFFSET_DOMAIN_LOWER = 0
OFFSET_DOMAIN_UPPER = DIVISOR - 1

PRODUCTION_OFFSET = 1 << 25

INT16_MIN = -(1 << 15)
INT16_MAX = (1 << 15) - 1


def centered(a: int) -> int:
    value = a % Q

    if value > 1664:
        value -= Q

    return value


def candidate_quotient(offset: int, a: int) -> int:
    return (
        MULTIPLIER * a + offset
    ) >> SHIFT


def candidate_result(offset: int, a: int) -> int:
    return (
        a -
        candidate_quotient(offset, a) * Q
    )


global_lower = OFFSET_DOMAIN_LOWER
global_upper = OFFSET_DOMAIN_UPPER
binding_rows = []

for a in range(INT16_MIN, INT16_MAX + 1):
    target = centered(a)
    target_quotient = (a - target) // Q

    input_lower = (
        target_quotient * DIVISOR -
        MULTIPLIER * a
    )

    input_upper = (
        (target_quotient + 1) * DIVISOR -
        1 -
        MULTIPLIER * a
    )

    previous_lower = global_lower
    previous_upper = global_upper

    global_lower = max(
        global_lower,
        input_lower,
    )

    global_upper = min(
        global_upper,
        input_upper,
    )

    if (
        global_lower != previous_lower or
        global_upper != previous_upper
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

EXPECTED_LOWER = 33548599
EXPECTED_UPPER = 33560264

if global_lower != EXPECTED_LOWER:
    raise SystemExit(
        f"Unexpected interval lower bound: {global_lower}"
    )

if global_upper != EXPECTED_UPPER:
    raise SystemExit(
        f"Unexpected interval upper bound: {global_upper}"
    )

if global_upper - global_lower + 1 != 11666:
    raise SystemExit(
        "Unexpected admissible interval size"
    )

for offset in (
    EXPECTED_LOWER,
    EXPECTED_UPPER,
    PRODUCTION_OFFSET,
):
    for a in range(INT16_MIN, INT16_MAX + 1):
        if candidate_result(offset, a) != centered(a):
            raise SystemExit(
                f"Valid offset {offset} failed at a={a}"
            )

LOWER_WITNESS = -31625
UPPER_WITNESS = 31625

if (
    candidate_result(
        EXPECTED_LOWER - 1,
        LOWER_WITNESS,
    ) != 1665
):
    raise SystemExit(
        "Lower outside witness calculation failed"
    )

if (
    candidate_result(
        EXPECTED_LOWER,
        LOWER_WITNESS,
    ) != -1664
):
    raise SystemExit(
        "Lower endpoint witness calculation failed"
    )

if (
    candidate_result(
        EXPECTED_UPPER,
        UPPER_WITNESS,
    ) != 1664
):
    raise SystemExit(
        "Upper endpoint witness calculation failed"
    )

if (
    candidate_result(
        EXPECTED_UPPER + 1,
        UPPER_WITNESS,
    ) != -1665
):
    raise SystemExit(
        "Upper outside witness calculation failed"
    )

lower_margin = (
    PRODUCTION_OFFSET -
    EXPECTED_LOWER
)

upper_margin = (
    EXPECTED_UPPER -
    PRODUCTION_OFFSET
)

if lower_margin != 5833:
    raise SystemExit(
        f"Unexpected lower margin: {lower_margin}"
    )

if upper_margin != 5832:
    raise SystemExit(
        f"Unexpected upper margin: {upper_margin}"
    )

binding_table = (
    output_dir /
    "offset_binding_constraints.tsv"
)

with binding_table.open(
    "w",
    encoding="utf-8",
) as f:
    f.write(
        "input_a\ttarget_quotient\t"
        "input_offset_lower\tinput_offset_upper\t"
        "global_lower\tglobal_upper\n"
    )

    for row in binding_rows:
        f.write(
            "\t".join(
                str(value)
                for value in row
            ) +
            "\n"
        )

control_values = [
    (EXPECTED_LOWER - 1, LOWER_WITNESS),
    (EXPECTED_LOWER, LOWER_WITNESS),
    (PRODUCTION_OFFSET, LOWER_WITNESS),
    (PRODUCTION_OFFSET, UPPER_WITNESS),
    (EXPECTED_UPPER, UPPER_WITNESS),
    (EXPECTED_UPPER + 1, UPPER_WITNESS),
    (OFFSET_DOMAIN_LOWER, INT16_MIN),
    (OFFSET_DOMAIN_UPPER, INT16_MAX),
]

control_table = (
    output_dir /
    "offset_control_values.tsv"
)

with control_table.open(
    "w",
    encoding="utf-8",
) as f:
    f.write(
        "offset\tinput_a\tnumerator\tquotient\t"
        "candidate_result\tcentered_result\n"
    )

    for offset, a in control_values:
        numerator = (
            MULTIPLIER * a +
            offset
        )

        quotient = (
            numerator >> SHIFT
        )

        result = (
            a -
            quotient * Q
        )

        f.write(
            f"{offset}\t{a}\t{numerator}\t"
            f"{quotient}\t{result}\t"
            f"{centered(a)}\n"
        )

summary = (
    output_dir /
    "discovery_summary.txt"
)

summary.write_text(
    "\n".join(
        [
            "DISCOVERY_METHOD=DETERMINISTIC_FULL_INPUT_INTERVAL_INTERSECTION",
            "AUTHORITATIVE_FORMAL_RESULT=CBMC_PENDING",
            "OFFSET_DESIGN_DOMAIN_LOWER=0",
            "OFFSET_DESIGN_DOMAIN_UPPER=67108863",
            "OFFSET_DESIGN_DOMAIN_COUNT=67108864",
            "EXACT_ADMISSIBLE_OFFSET_LOWER=33548599",
            "EXACT_ADMISSIBLE_OFFSET_UPPER=33560264",
            "EXACT_ADMISSIBLE_OFFSET_COUNT=11666",
            "PRODUCTION_OFFSET=33554432",
            "PRODUCTION_LOWER_MARGIN=5833",
            "PRODUCTION_UPPER_MARGIN=5832",
            "LOWER_EXCLUSION_WITNESS_A=-31625",
            "LOWER_OUTSIDE_RESULT=1665",
            "LOWER_ENDPOINT_RESULT=-1664",
            "UPPER_EXCLUSION_WITNESS_A=31625",
            "UPPER_ENDPOINT_RESULT=1664",
            "UPPER_OUTSIDE_RESULT=-1665",
            "LOWER_ENDPOINT_FULL_INT16_DOMAIN=PASS",
            "UPPER_ENDPOINT_FULL_INT16_DOMAIN=PASS",
            "PRODUCTION_OFFSET_FULL_INT16_DOMAIN=PASS",
            "ENUMERATION_AND_INTERVAL_INTERSECTION_ARE_CROSS_CHECKS_NOT_FORMAL_PROOF=YES",
            "",
        ]
    ),
    encoding="utf-8",
)
