# Final MSG-T1 Theorem Record — `mlk_poly_tomsg`

## Authoritative implementation

- repository: `/home/girish/THESIS-2026/mlkem-native_af4c5abd`;
- commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`;
- production source:
  - `mlkem/src/compress.c`, SHA-256 `9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad`;
  - `mlkem/src/compress.h`, SHA-256 `0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd`;
- frozen harness SHA-256: `5ce480427d7792b3dca091ac198b43562c4d4dfd6c9d96dae5a73e7ef1e72b55`;
- frozen positive GOTO SHA-256: `51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d`;
- parameter-set build used by the campaign: ML-KEM-768;
- C model: C90, no assembly path, recorded custom zeroisation support.

## Proved functional property

Let `a` be a valid ML-KEM polynomial object with 256 coefficients satisfying

```text
0 <= a.coeffs[k] < 3329
```

for every index `k` in `0..255`.

After execution of the frozen production `mlk_poly_tomsg(msg, &a)` body, every
output bit satisfies

```text
((msg[k >> 3] >> (k & 7)) & 1)
    ==
((a.coeffs[k] >= 833) && (a.coeffs[k] <= 2496))
```

for every `k` in `0..255`.

Equivalently, the output bit is zero for coefficients `0..832`, one for
coefficients `833..2496`, and zero for coefficients `2497..3328`. The
coefficient-to-message mapping is the frozen least-significant-bit-first
packing relation used by the harness.

## Authoritative evidence

### Frozen model

MSG-01G-R1 froze and validated the candidate before positive solving.

### Positive proof

MSG-01H returned:

```text
CBMC_EXIT=0
PROPERTY_RECORD_COUNT=521
SUCCESS_COUNT=521
FAILURE_COUNT=0
UNKNOWN_COUNT=0
```

The exact every-bit assertion succeeded together with the recorded safety
checks.

### Reachability and non-vacuity

MSG-01J-R3 established:

```text
COMPANION_PROPERTY_RECORD_COUNT=522
COMPANION_SUCCESS_COUNT=522
COVERAGE_SATISFIED=12
COVERAGE_TOTAL=12
COVERAGE_FAILED_LINE_COUNT=0
```

The registered witnesses include both threshold transitions, the minimum and
maximum canonical coefficients, interior witnesses for all three output
regions, and flat output indices 0, 127 and 255.

Insufficient bounds were detected for all four multi-iteration reachable
loops. The macro-origin loop was separately classified as complete with bound
one.

### Mutation sensitivity

MSG-01K-R1 froze eight non-equivalent mutants before solving. MSG-01L-R1
executed and killed all eight:

```text
TOTAL_MUTANTS=8
KILLED_MUTANTS=8
SURVIVING_MUTANTS=0
```

Every mutant failed the registered exact functional assertion. No mutant was
accepted because of an unwinding failure or unrelated property failure.

## Final verdict

Within the frozen build, harness, canonical coefficient domain, assumptions,
safety checks and complete-loop model recorded by this campaign, CBMC found no
counterexample to the exact `mlk_poly_tomsg` refinement property.

The positive result is supported by explicit reachability/non-vacuity evidence
and sensitivity to the eight frozen implementation and oracle/assertion
mutants.

```text
MSG_T1_CORE_PROOF_CAMPAIGN=PASS
```
