# POLYCOMP-D4-T2 Final Verification Verdict

## Status

**Accepted within the registered bounded portable-C verification scope.**

## Bound implementation

- Repository: `mlkem-native`
- Commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Configuration: ML-KEM-768 (`MLKEM_K=3`)
- Production target: `mlk_poly_decompress_d4_c`
- Production source modification: none
- Verification tool: CBMC 6.9.0

## Input domain

Every possible 128-byte input array is admitted. The positive harness contains
no input assumptions.

## Primary refinement theorem

For every byte index `i` in `0..127`, let:

```text
low  = input[i] & 0x0F
high = input[i] >> 4
```

and define:

```text
Decompress4(v) = floor((3329*v + 8) / 16).
```

The verified implementation satisfies:

```text
output.coeffs[2*i]     = Decompress4(low)
output.coeffs[2*i + 1] = Decompress4(high)
```

for every output coefficient.

## Verified obligations

1. Full 256-coefficient refinement.
2. Exact low-nibble extraction.
3. Exact high-nibble extraction.
4. Exact scalar decompression.
5. Canonical image membership.
6. Complete output overwrite independence.
7. Complete bounded loop plan:
   - harness loop: 257;
   - production decompressor loop: 129.
8. Positive strict checks: 86 of 86 successful.
9. Location coverage: 20 of 20 goals satisfied.
10. Positive end-of-harness reachability.
11. Nibble-extraction swap mutation detected.
12. Rounding constant `8` changed to `7` detected.
13. Relational byte locality:
    - equal input byte implies equal decoded low coefficient;
    - equal input byte implies equal decoded high coefficient.
14. Relational strict checks: 84 of 84 successful.
15. Relational end-of-harness reachability.

## Codebook

The exact decompressor image is:

```text
0, 208, 416, 624, 832, 1040, 1248, 1456,
1665, 1873, 2081, 2289, 2497, 2705, 2913, 3121
```

## Novelty boundary

The repository already contains HOL Light verification relating to the AVX2
assembly implementation. This package makes no claim that decompression
correctness was previously absent.

The contribution represented here is a separate clean-room CBMC campaign for
the pinned portable-C implementation, including full-polynomial refinement,
strict C-level checks, non-vacuity evidence, targeted mutation evidence and
relational byte locality.

## Excluded claims

This package does not establish:

- portable-C equivalence with the AVX2 or other native backend;
- correctness of assembly implementations;
- constant-time or side-channel security;
- compressor correctness except through separately frozen T1 evidence;
- end-to-end ML-KEM correctness;
- correctness of unrelated repository functions;
- ML-KEM-1024's different compression configuration.
