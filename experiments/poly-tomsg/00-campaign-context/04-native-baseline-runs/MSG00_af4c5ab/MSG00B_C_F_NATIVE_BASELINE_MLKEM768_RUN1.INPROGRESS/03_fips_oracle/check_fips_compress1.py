#!/usr/bin/env python3

from pathlib import Path

Q = 3329


def exact_rational_round(x: int) -> int:
    """Round 2*x/Q to nearest integer; Q is odd, so no tie is possible."""
    if not 0 <= x < Q:
        raise ValueError(f"non-canonical coefficient: {x}")

    quotient, remainder = divmod(2 * x, Q)
    rounded = quotient + (1 if 2 * remainder > Q else 0)
    return rounded % 2


def integer_formula(x: int) -> int:
    """Equivalent integer realization for canonical x."""
    if not 0 <= x < Q:
        raise ValueError(f"non-canonical coefficient: {x}")
    return ((2 * x + Q // 2) // Q) % 2


def threshold_oracle(x: int) -> int:
    """Independent threshold partition for q=3329 and d=1."""
    if not 0 <= x < Q:
        raise ValueError(f"non-canonical coefficient: {x}")
    return 1 if 833 <= x <= 2496 else 0


def main() -> None:
    rows = []
    mismatches = []

    for x in range(Q):
        rational = exact_rational_round(x)
        formula = integer_formula(x)
        threshold = threshold_oracle(x)
        rows.append((x, rational, formula, threshold))

        if not (rational == formula == threshold):
            mismatches.append((x, rational, formula, threshold))

    output = Path(__file__).with_name("compress1_exhaustive.tsv")
    with output.open("w", encoding="utf-8") as handle:
        handle.write(
            "coefficient\texact_rational_round\tinteger_formula\tthreshold_oracle\n"
        )
        for row in rows:
            handle.write(f"{row[0]}\t{row[1]}\t{row[2]}\t{row[3]}\n")

    boundaries = {
        0: 0,
        832: 0,
        833: 1,
        2496: 1,
        2497: 0,
        3328: 0,
    }

    for x, expected in boundaries.items():
        actual = exact_rational_round(x)
        if actual != expected:
            raise AssertionError(
                f"boundary failure: x={x}, expected={expected}, actual={actual}"
            )

    if mismatches:
        raise AssertionError(
            f"oracle mismatch count={len(mismatches)}; first={mismatches[0]}"
        )

    ones = sum(exact_rational_round(x) for x in range(Q))
    zeros = Q - ones

    print("FIPS_Q=3329")
    print("CANONICAL_DOMAIN_SIZE=3329")
    print("INTEGER_FORMULA=((2*x + 1664) // 3329) mod 2")
    print("ZERO_INTERVAL_1=0..832")
    print("ONE_INTERVAL=833..2496")
    print("ZERO_INTERVAL_2=2497..3328")
    print("CRITICAL_BOUNDARIES=832,833,2496,2497")
    print(f"ZERO_COUNT={zeros}")
    print(f"ONE_COUNT={ones}")
    print("RATIONAL_INTEGER_THRESHOLD_EQUIVALENCE=PASS")
    print("BOUNDARY_CHECK=PASS")
    print("FIPS_ORACLE_EXHAUSTIVE=PASS")


if __name__ == "__main__":
    main()
