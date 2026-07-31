# MONT-T2A.P3 Solver Encoding Recovery

Original locked theorem:

`R * (reduce(b) - reduce(a)) - (b - a) ≡ 0 (mod q)`.

Recovery encoding checked directly by CBMC:

`R * (reduce(b) - reduce(a)) - (b - a) = -q * (t_b - t_a)`,

where `t_a` and `t_b` are independently computed signed Montgomery
witnesses from the canonical low words of `a` and `b`.

The recovery equality is strictly stronger as an encoding because equality
to an explicit multiple of `q` directly implies the original congruence.
It does not assume MONT-T1 and does not narrow the source-contract domain.

The full domain is partitioned exhaustively into:

1. `a >= 0, b >= 0`
2. `a >= 0, b < 0`
3. `a < 0, b >= 0`
4. `a < 0, b < 0`

The four quadrants are disjoint and their union is the complete signed input
pair domain. Every quadrant retains the original full contract bounds.
