# SUB00Q B5.2 — Frozen Two-Run Harness Family V1

## Scope

This family instantiates the preregistered SUB-T5 relational theorem for the
frozen ML-KEM-768 production `mlk_poly_sub` implementation.

## Harness inventory

### Positive theorem harnesses

1. `sub_t5_frame_preservation_harness.c` — T5.1 and T5.6.
2. `sub_t5_coefficient_locality_harness.c` — T5.2.
3. `sub_t5_noninterference_exact_effect_harness.c` — T5.3 and T5.4.
4. `sub_t5_determinism_harness.c` — T5.5.

### Reachability companions

5. `sub_t5_reachability_locality_harness.c` — k=0,127,255 and locally equal,
   globally different inputs.
6. `sub_t5_reachability_changed_index_harness.c` — j=0,255 and genuine local
   changes with off-target equality.
7. `sub_t5_reachability_identical_inputs_harness.c` — identical complete,
   nontrivial inputs and identical outputs.

### Isolated expected-failure controls

8. `sub_t5_expected_failure_off_target_harness.c` — EF-T5-1.
9. `sub_t5_expected_failure_nondeterminism_harness.c` — EF-T5-2.

## Structural decisions

- Every harness performs exactly two calls to the same production function.
- Destination and source polynomials are distinct complete automatic objects.
- Canonical coefficient assumptions are the only arithmetic-domain assumptions.
- No assumption constrains an output or assumes int16 subtraction
  representability.
- Positive, reachability, and expected-failure cases are isolated files and
  must be compiled and executed independently.
- Exact-output anchors are retained in relational harnesses so dependency
  mutants such as skipped coefficient 255 cannot survive merely because both
  runs are mutated identically.
- The frame harness duplicates snapshot witnesses, making preservation of the
  saved snapshots themselves an explicit assertion.

## Production boundary

This package contains no modified production source. It binds to the frozen
snapshot under `source/mlkem/src/poly.c` at commit
`d9613cf60de3132d32475c102d8c2781d84feb34`.

## Stage boundary

B5.2 creates and freezes harness artefacts only. It is not CBMC proof evidence.
GOTO construction and model inspection belong to B5.4.
