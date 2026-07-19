# M4 final mutation result

## Authoritative classification

- Classification: `FAIL_EXPECTED_MUTANT_KILLED`
- Mutant killed: `yes`
- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Frozen source modified: `no`
- Positive control modified: `no`

## Mutation

The isolated mutant changed the Barrett-reduction loop in `mlk_poly_reduce_c` so that coefficient 255 was omitted.

## Result

- Returned properties: `89`
- Failed properties: `4`
- Semantic failures: `3`
- Independent-oracle failures: `1`
- Unwinding failures: `0`
- Missing properties: `0`
- Extra properties: `0`
- CBMC exit: `10`

The unchanged semantic harness and independent canonical oracle detected the isolated implementation defect. This provides mutation-sensitivity and non-vacuity evidence for VC-SR1.
