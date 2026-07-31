# MONT-T3 — Normalized Montgomery multiplication algebra

Pinned commit:

`af4c5abdd5958bdc65a03cd5ee86708264f93304`

Target implementation:

`mlk_fqmul`

## Frozen properties

1. T3-P1 — Independent multiplication semantic refinement.
2. T3-P2 — Exact commutativity for canonical operands.
3. T3-P3 — Zero annihilation and zero-product reflection.
4. T3-P4 — Montgomery-one identity after normalization.
5. T3-P5 — Distributivity after normalization.
6. T3-P6 — Associativity after normalization.

## Domain split

- P1: first operand is any int16_t; second operand is signed canonical.
- P2–P6: x, y and z are signed canonical because each may occur as the
  second operand of mlk_fqmul.

## Isolation

This campaign runs in a detached T3-only worktree. It does not read, replace,
delete or modify the running MONT-T2 proof directories.

## Status

Candidate until baseline success, false-control non-vacuity and three
fqmul-specific mutations have all been audited.
