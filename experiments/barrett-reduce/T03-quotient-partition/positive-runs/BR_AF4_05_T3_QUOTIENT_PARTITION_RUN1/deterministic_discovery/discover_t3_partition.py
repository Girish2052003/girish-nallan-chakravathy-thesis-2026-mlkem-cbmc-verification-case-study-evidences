#!/usr/bin/env python3

from collections import defaultdict
from pathlib import Path
import sys

output_dir = Path(sys.argv[1])

Q = 3329
MAGIC = 20159
OFFSET = 1 << 25
SHIFT = 26

INT16_MIN = -(1 << 15)
INT16_MAX = (1 << 15) - 1


def centered_oracle(a: int) -> int:
    u = a % Q
    if u > 1664:
        u -= Q
    return u


def formula_quotient(a: int) -> int:
    # Python's right shift on negative integers is arithmetic.
    return (MAGIC * a + OFFSET) >> SHIFT


cells: dict[int, list[int]] = defaultdict(list)

for a in range(INT16_MIN, INT16_MAX + 1):
    centered = centered_oracle(a)
    quotient_formula = formula_quotient(a)
    quotient_oracle = (a - centered) // Q
    reconstructed = a - quotient_formula * Q

    if quotient_formula != quotient_oracle:
        raise SystemExit(
            f"Formula/oracle quotient mismatch at a={a}: "
            f"{quotient_formula} != {quotient_oracle}"
        )

    if reconstructed != centered:
        raise SystemExit(
            f"Remainder reconstruction mismatch at a={a}: "
            f"{reconstructed} != {centered}"
        )

    cells[quotient_formula].append(a)

expected_keys = list(range(-10, 11))

if sorted(cells) != expected_keys:
    raise SystemExit(
        f"Unexpected quotient keys: {sorted(cells)}"
    )

cell_table = output_dir / "quotient_cells.tsv"

with cell_table.open("w", encoding="utf-8") as f:
    f.write("quotient\tlower_input\tupper_input\tcount\n")

    for quotient in expected_keys:
        values = cells[quotient]
        lower = values[0]
        upper = values[-1]
        count = len(values)

        expected_lower = max(
            INT16_MIN,
            Q * quotient - 1664,
        )
        expected_upper = min(
            INT16_MAX,
            Q * quotient + 1664,
        )

        if lower != expected_lower:
            raise SystemExit(
                f"Lower boundary mismatch for q={quotient}: "
                f"{lower} != {expected_lower}"
            )

        if upper != expected_upper:
            raise SystemExit(
                f"Upper boundary mismatch for q={quotient}: "
                f"{upper} != {expected_upper}"
            )

        if count != upper - lower + 1:
            raise SystemExit(
                f"Non-contiguous cell for q={quotient}"
            )

        f.write(
            f"{quotient}\t{lower}\t{upper}\t{count}\n"
        )

if len(cells[-10]) != 1143:
    raise SystemExit("Unexpected left endpoint-cell size")

if len(cells[10]) != 1142:
    raise SystemExit("Unexpected right endpoint-cell size")

for quotient in range(-9, 10):
    if len(cells[quotient]) != Q:
        raise SystemExit(
            f"Unexpected interior-cell size for q={quotient}"
        )

transition_table = output_dir / "quotient_transitions.tsv"

with transition_table.open("w", encoding="utf-8") as f:
    f.write(
        "left_quotient\tleft_last_input\t"
        "right_first_input\tright_quotient\n"
    )

    for quotient in range(-10, 10):
        left_last = Q * quotient + 1664
        right_first = left_last + 1

        if formula_quotient(left_last) != quotient:
            raise SystemExit(
                f"Left transition mismatch for q={quotient}"
            )

        if formula_quotient(right_first) != quotient + 1:
            raise SystemExit(
                f"Right transition mismatch for q={quotient + 1}"
            )

        f.write(
            f"{quotient}\t{left_last}\t"
            f"{right_first}\t{quotient + 1}\n"
        )

summary = output_dir / "discovery_summary.txt"

summary.write_text(
    "\n".join(
        [
            "DISCOVERY_METHOD=DETERMINISTIC_EXHAUSTIVE_ENUMERATION",
            "AUTHORITATIVE_FORMAL_RESULT=CBMC_PENDING",
            "INPUT_DOMAIN_CARDINALITY=65536",
            "QUOTIENT_MIN=-10",
            "QUOTIENT_MAX=10",
            "QUOTIENT_CELL_COUNT=21",
            "LEFT_ENDPOINT_CELL=-32768..-31626",
            "LEFT_ENDPOINT_CELL_SIZE=1143",
            "INTERIOR_CELL_COUNT=19",
            "INTERIOR_CELL_SIZE=3329",
            "RIGHT_ENDPOINT_CELL=31626..32767",
            "RIGHT_ENDPOINT_CELL_SIZE=1142",
            "TRANSITION_COUNT=20",
            "FORMULA_ORACLE_EQUIVALENCE_ALL_INPUTS=PASS",
            "AFFINE_RECONSTRUCTION_ALL_INPUTS=PASS",
            "ENUMERATION_IS_CROSS_CHECK_NOT_FORMAL_PROOF=YES",
            "",
        ]
    ),
    encoding="utf-8",
)
