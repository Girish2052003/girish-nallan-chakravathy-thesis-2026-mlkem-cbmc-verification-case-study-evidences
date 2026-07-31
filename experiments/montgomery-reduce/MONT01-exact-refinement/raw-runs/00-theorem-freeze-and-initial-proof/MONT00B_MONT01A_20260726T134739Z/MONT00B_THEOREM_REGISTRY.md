# Montgomery-domain theorem registry

## Frozen source

- Commit: af4c5abdd5958bdc65a03cd5ee86708264f93304
- Target: mlk_montgomery_reduce
- Scalar companion: mlk_fqmul
- Portable-C representation companion: mlk_poly_tomont_c

## MONT-T1 — Full-contract-domain exact refinement

1. Independent oracle equality.
2. Exact decomposition: a = R*r + q*t.
3. Unique signed-16 witness decomposition.
4. Universal sharp output range [-32767,32767].
5. Concrete reachability of both sharp endpoints.

## MONT-T2 — Relational residue and low-word-fibre laws

1. Residue-equivalence preservation.
2. Residue-equivalence reflection.
3. Exact affine law for equal low-16-bit inputs.
4. Injectivity inside a fixed low-word fibre.
5. Modular-negation compatibility.

## MONT-T3 — Normalized Montgomery multiplication algebra

1. Independent semantic refinement.
2. Commutativity for canonical operands.
3. Zero annihilation and zero-product reflection.
4. Montgomery-one identity after normalization.
5. Distributivity after normalization.
6. Associativity after normalization.

## MONT-T4 — Portable-C conversion round trip and locality

1. De-Montgomery round trip.
2. Residue-vector equivalence preservation.
3. Residue-vector equivalence reflection.
4. Zero-support preservation.
5. Coefficient locality and no cross-talk.

## Existing-overlap boundary

The native CBMC harnesses prove embedded contracts and are boilerplate.
The basic AArch64 poly_tomont congruence and bound are already covered by
HOL Light and are not claimed as new mathematics.

## Status

Only MONT-T1 is authorized for implementation in the present run.
T2–T4 remain registered candidates until their own harness-freeze gates.
