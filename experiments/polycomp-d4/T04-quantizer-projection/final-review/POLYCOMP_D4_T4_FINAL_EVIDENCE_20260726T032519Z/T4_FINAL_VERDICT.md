# POLYCOMP-D4-T4 Final Verification Verdict

## Status

**Accepted within the registered bounded portable-C verification scope.**

## Bound implementation

- Repository: `mlkem-native`
- Commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Configuration: ML-KEM-768 (`MLKEM_K=3`)
- Production functions:
  - `mlk_poly_compress_d4_c`
  - `mlk_poly_decompress_d4_c`
- Production source modification: none
- Verification tool: CBMC 6.9.0

## Input domain

Every 256-coefficient polynomial satisfying:

```text
0 <= coefficient < 3329
```

The assumptions in the positive, fixed-point, idempotence and locality
harnesses define only this frozen canonical domain and the registered
relational coordinate premise.

## Projection

```text
Q(A) = decompress_d4(compress_d4(A))
```

using the real pinned portable-C implementation.

## Verified obligations

1. Every projected coefficient belongs to the exact D4 codebook:
   `0, 208, 416, 624, 832, 1040, 1248, 1456, 1665, 1873, 2081,
   2289, 2497, 2705, 2913, 3121`.
2. Every canonical coefficient has modular projection distortion at most 104.
3. The bound is sharp: canonical coefficient 104 is projected to zero and
   attains modular distance exactly 104.
4. A canonical coefficient is fixed by the projection exactly when it is a
   D4 codebook value.
5. The projection is idempotent: `Q(Q(A)) = Q(A)`.
6. Coordinate locality: equal canonical coefficients at coordinate `k`
   yield equal projected coefficients at `k`.
7. The finite canonical domain 0 through 3328 was exhaustively checked.
8. There are 17 finite witnesses attaining the sharp distance 104.
9. Positive strict checks: 194 of 194 successful.
10. Sharp-witness strict checks: 190 of 190 successful.
11. Fixed-point strict checks: 190 of 190 successful.
12. Idempotence strict checks: 189 of 189 successful.
13. Locality strict checks: 192 of 192 successful.
14. Location coverage: 36 of 36 goals satisfied.
15. Positive end-of-harness reachability.
16. Isolated non-codebook mutation detected while the distortion assertion
    remained successful.
17. Isolated excessive-distortion mutation detected while codebook
    membership remained successful.

## Novelty boundary

This package establishes a clean-room CBMC theorem family for the pinned
portable-C D4 projection. It does not claim that quantization, compression,
decompression, error bounds, or related properties were absent from every
other test, proof, implementation backend, or formal development.

## Excluded claims

This package does not establish:

- equivalence with AVX2 or other native/assembly backends;
- correctness of assembly implementations;
- constant-time or side-channel security;
- behavior outside the canonical coefficient domain;
- end-to-end ML-KEM correctness;
- correctness of unrelated functions or other parameter configurations.
