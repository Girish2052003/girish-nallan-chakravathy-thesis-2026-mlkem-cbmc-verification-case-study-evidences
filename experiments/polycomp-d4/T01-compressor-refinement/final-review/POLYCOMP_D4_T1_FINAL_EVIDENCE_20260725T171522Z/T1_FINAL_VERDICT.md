# POLYCOMP-D4-T1 Final Verification Verdict

## Status

**ACCEPTED for the registered, bounded portable-C verification scope.**

## Bound implementation

- Repository: mlkem-native
- Commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Parameter configuration: ML-KEM-768 (`MLKEM_K=3`)
- Target body: `mlk_poly_compress_d4_c`
- Production source modification: none
- Verification tool: CBMC 6.9.0

## Domain

For every polynomial `a` with 256 coefficients satisfying:

```text
0 <= a[j] < 3329
```

for every `j` in `0..255`.

## Verified primary refinement

For every byte index `i` in `0..127`, the portable implementation produces:

```text
output[i] =
    Compress4(a[2*i])
    |
    (Compress4(a[2*i + 1]) << 4)
```

where the independent scalar specification is:

```text
Compress4(u) =
    floor((16*u + 1664) / 3329) mod 16.
```

## Verified obligations

1. Full 128-byte refinement.
2. Coefficient-to-nibble correspondence.
3. Low/high nibble packing order.
4. Complete output overwrite independence.
5. Relational nibble locality:

   * equal even coefficient implies equal low nibble;
   * equal odd coefficient implies equal high nibble.
6. Complete explicit loop-bound plan for the bounded executions.
7. Strict safety-plus-semantic checks:

   * positive harness: 108 of 108 reported properties successful;
   * relational harness: 107 of 107 reported properties successful.
8. Location coverage: 24 of 24 goals satisfied.
9. End-of-harness reachability for positive and relational harnesses.
10. Mutation sensitivity:

    * expected-byte bit flip detected;
    * low/high nibble swap detected;
    * rounding constant minus one detected.
11. Exact rounding-boundary counterexample included coefficient 3225.

## Important interpretation

This is a new repository-level CBMC semantic and relational verification
campaign. It is not a claim of new ML-KEM mathematics and not a universal
proof covering all implementations or parameter configurations.

## Excluded claims

This evidence does not establish:

* native assembly or optimized-backend equivalence;
* constant-time or side-channel security;
* decompressor correctness;
* end-to-end ML-KEM correctness;
* behaviour outside the canonical coefficient precondition;
* correctness of unrelated repository functions;
* a proof for ML-KEM-1024's different compression configuration.
