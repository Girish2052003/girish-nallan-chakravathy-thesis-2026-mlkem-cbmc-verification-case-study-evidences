# POLYCOMP-D4-T3 Final Verification Verdict

## Status

**Accepted within the registered bounded portable-C verification scope.**

## Bound implementation

- Repository: `mlkem-native`
- Commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Configuration: ML-KEM-768 (`MLKEM_K=3`)
- Production functions:
  - `mlk_poly_decompress_d4_c`
  - `mlk_poly_compress_d4_c`
- Production source modification: none
- Verification tool: CBMC 6.9.0

## Input domain

Every possible 128-byte compressed input array is admitted. The positive,
nibble-preservation and cycle-stability harnesses contain no assumptions.

## Primary theorem

For every 128-byte input array `B`:

```text
mlk_poly_compress_d4_c(
    mlk_poly_decompress_d4_c(B)
) = B
```

byte-for-byte.

## Verified obligations

1. Exact 128-byte identity after the real decompression/compression cycle.
2. Low-nibble preservation for every byte.
3. High-nibble preservation for every byte.
4. Cycle stability under a second real decompression/compression cycle.
5. Exact four-loop inventory and complete unwind bounds:
   - harness comparison loop: 129;
   - compressor inner loop: 129;
   - compressor outer loop: 257;
   - decompressor loop: 129.
6. Positive strict checks: 186 of 186 successful.
7. Location coverage: 25 of 25 goals satisfied.
8. Positive end-of-harness reachability.
9. Nibble strict checks: 187 of 187 successful.
10. Cycle strict checks: 186 of 186 successful.
11. Decompression-side coefficient-swap fault detected.
12. Compression-side output-nibble-swap fault detected.

## Finite-domain support

The independent finite derivation confirms:

- all 16 D4 nibbles satisfy scalar retraction;
- all 256 possible packed bytes reconstruct exactly.

## Novelty boundary

This package establishes a clean-room CBMC composition theorem for the pinned
portable-C implementation. It does not claim that compression, decompression,
round-trip properties, or implementation correctness were absent from all
other repository tests, proofs, backends, or formal developments.

## Excluded claims

This package does not establish:

- equivalence with AVX2 or other native/assembly backends;
- correctness of assembly implementations;
- constant-time or side-channel security;
- arbitrary-polynomial compressor correctness outside the separate T1 scope;
- arbitrary-polynomial decompressor refinement outside the separate T2 scope;
- end-to-end ML-KEM correctness;
- correctness of unrelated functions or other parameter configurations.
