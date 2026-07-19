# SUB-T6 / Batch 6 Preregistration

## 1. Record identity

- Campaign: `mlk_poly_sub clean-room verification`
- Batch: `SUB-T6 / Batch 6`
- Gate: `B6.0`
- Schema: `sub-t6-b6.0-preregistration-v1`
- Status: `FROZEN`

This record was created before any Batch-6 harness construction,
GOTO construction, CBMC execution, reachability result, expected-failure
result or mutation result was observed.

## 2. Official theorem

```text
SUB-T6:

Production Call-Site Contract Satisfaction and Subtract–Reduce Handoff Correctness of mlk_poly_sub in mlk_indcpa_dec
```

## 3. Production boundary

The upstream-to-downstream production boundary is:

```c
mlk_poly_invntt_tomont(sb);
mlk_poly_sub(v, sb);
mlk_poly_reduce(v);
mlk_poly_tomsg(m, v);
```

The actual bounded slice intended for execution is:

```c
mlk_poly_sub(v, sb);
mlk_poly_reduce(v);
mlk_poly_tomsg(m, v);
```

Immediately preceding operations are represented through their frozen
contract or postcondition interfaces. Batch 6 does not reprove those
upstream cryptographic operations.

## 4. Frozen parameters and arithmetic domain

- `MLKEM_N = 256`
- `MLKEM_Q = 3329`
- `MLK_INVNTT_BOUND = 26632`
- `v` interval: `[0, 3328]`
- `sb` interval: `[-26631, 26631]`
- Derived subtraction interval: `[-26631, 29959]`
- Signed `int16_t` interval: `[-32768, 32767]`

The subtraction interval must be derived from the upstream bounds; it
must not be introduced as an independent harness assumption.

## 5. Permitted assumptions

1. 0 <= v_before[i] < 3329 for every coefficient.
2. abs(sb_before[i]) < 26632 for every coefficient.
3. successful allocation path.
4. v and sb are valid complete distinct non-overlapping mlk_poly objects.
5. each polynomial has exactly 256 coefficients.
6. upstream coefficient bounds are compositional interfaces.
7. exact source configuration contracts and tool model are frozen later.

## 6. Prohibited assumptions and transformations

1. `assume(false)`.
2. `unreachable target calls`.
3. `assume subtraction fits int16_t`.
4. `assume derived range [-26631,29959]`.
5. `assume exact mlk_poly_sub output`.
6. `assume canonical mlk_poly_reduce output`.
7. `assume mlk_poly_tomsg precondition`.
8. `exclude coefficient indices 0 or 255`.
9. `replace target functions with conclusion-establishing stubs`.
10. `modify frozen production implementation for positive proof`.
11. `silently disable safety checks or unwinding assertions`.

Mathematical subtraction checks must use a widened integer type before
comparison with the signed 16-bit limits.

## 7. Derived arithmetic obligation

```text
minimum = 0 - 26631 = -26631
maximum = 3328 - (-26631) = 29959

-26631 <= v[i] - sb[i] <= 29959
[-26631, 29959] is contained in [-32768, 32767]
```

This representability statement is a proof obligation, not an assumption.

## 8. Registered positive properties

### T6.1 - Production call-site object validity and separation

Prove valid, complete, distinct and non-aliasing call operands
under the successful allocation-path model.

### T6.2 - Derived subtraction representability

Derive signed 16-bit subtraction representability from only the
registered upstream coefficient bounds.

### T6.3 - Exact call-site subtraction result

Execute the actual production `mlk_poly_sub` and prove exact
coefficient-wise subtraction over the caller-derived domain.

### T6.4 - Source and named caller-frame preservation

Prove preservation of `sb` and each explicitly registered
harness-observed caller-owned guard object.

### T6.5 - Subtraction-to-reduction handoff correctness

Execute the actual subtraction and reduction functions and prove
that the reduction output is canonical.

### T6.6 - Downstream mlk_poly_tomsg precondition satisfaction

Prove the canonical-input requirement of `mlk_poly_tomsg` before
executing the actual downstream consumer.

### T6.7 - Safety of the complete bounded integration slice

Prove safety and complete unwinding of the bounded production
slice under the registered CBMC checks.

## 9. Planned positive harness family

- `sub_t6_callsite_precondition_harness.c`
- `sub_t6_callsite_exactness_harness.c`
- `sub_t6_callsite_frame_harness.c`
- `sub_t6_sub_reduce_handoff_harness.c`
- `sub_t6_tomsg_precondition_harness.c`

## 10. Required reachability controls

### R6.1 - Lower subtraction boundary

```text
v = 0
sb = 26631
result = -26631
```

### R6.2 - Upper subtraction boundary

```text
v = 3328
sb = -26631
result = 29959
```

### R6.3 - Neutral subtraction

```text
v = 0
sb = 0
result = 0
```

### R6.4 - Source-sign reachability

- `positive` source coefficient
- `negative` source coefficient

### R6.5 - Reduction-input classes

- `negative`
- `zero`
- `canonical`
- `at_least_q`

### R6.6 - Index boundaries

- index `0`
- index `127`
- index `255`

## 11. Expected-failure controls

### EF-T6-1 - False overflow-existence claim

The intended false property must fail. Compilation, unwinding or
unrelated safety failures do not satisfy this control.

### EF-T6-2 - False canonicalisation-failure claim

The intended false property must fail. Compilation, unwinding or
unrelated safety failures do not satisfy this control.

### EF-T6-3 - False downstream-incompatibility claim

The intended false property must fail. Compilation, unwinding or
unrelated safety failures do not satisfy this control.

## 12. Mandatory mutation controls

### M6.1 - replace subtraction with addition

- Expected detector: `T6.3`
- The mutant must compile and produce a valid GOTO model.
- The mutated behaviour must be reachable.
- The intended property must fail without unrelated failures.
- An interpretable counterexample must be retained.

### M6.2 - remove mlk_poly_reduce

- Expected detector: `T6.6`
- The mutant must compile and produce a valid GOTO model.
- The mutated behaviour must be reachable.
- The intended property must fail without unrelated failures.
- An interpretable counterexample must be retained.

### M6.3 - modify source operand sb

- Expected detector: `T6.4`
- The mutant must compile and produce a valid GOTO model.
- The mutated behaviour must be reachable.
- The intended property must fail without unrelated failures.
- An interpretable counterexample must be retained.

### M6.4 - skip coefficient 255

- Expected detector: `T6.3, T6.5`
- The mutant must compile and produce a valid GOTO model.
- The mutated behaviour must be reachable.
- The intended property must fail without unrelated failures.
- An interpretable counterexample must be retained.

## 13. Stretch mutation control

### M6.5 - call mlk_poly_tomsg before reduction

- Expected detector: `T6.6`

## 14. Required CBMC checks

- `array-bounds`
- `pointer`
- `pointer-primitive`
- `pointer-overflow`
- `signed-overflow`
- `unsigned-overflow`
- `conversion`
- `undefined-shift`
- `division-by-zero`
- `unwinding-assertions`

Any unavailable or inapplicable option must be explicitly documented and
justified rather than silently omitted.

## 15. Permitted final claim

> Under the frozen ML-KEM configuration, successful allocation-separation
> model and registered upstream coefficient bounds, CBMC verified that the
> actual bounded `mlk_poly_sub` to `mlk_poly_reduce` to `mlk_poly_tomsg`
> production slice satisfies the registered representability, exactness,
> frame, reduction-handoff, downstream-precondition and safety properties,
> subject to the recorded assumptions, loop bounds, tool model and
> source/build bindings.

## 16. Frozen non-claims

- complete K-PKE.Decrypt correctness.
- correct plaintext for every ciphertext.
- NTT or inverse-NTT correctness.
- base multiplication correctness.
- ciphertext decompression correctness.
- secret-key unpacking correctness.
- every allocator implementation.
- out-of-memory paths unless separately modelled.
- constant-time execution or side-channel freedom.
- whole-library whole-program or end-to-end ML-KEM correctness.
- unbounded correctness or unregistered configurations.

## 17. Frozen gate order

1. `B6.0 preregistration`
2. `B6.1 call-site and contract binding`
3. `B6.2 arithmetic and assumption audit`
4. `B6.3 harness construction and freeze`
5. `B6.4 structural and GOTO preflight`
6. `B6.5 positive execution`
7. `B6.6 reachability`
8. `B6.7 expected failures`
9. `B6.8 mutations`
10. `B6.9 final evidence`

Later gates may strengthen evidence but may not silently weaken the
registered theorem, remove a property or introduce a prohibited assumption.

## 18. Execution state at preregistration

- `batch5_modified`: `FALSE`
- `cbmc_executed`: `FALSE`
- `goto_constructed`: `FALSE`
- `harness_constructed`: `FALSE`
- `production_modified`: `FALSE`
- `results_observed`: `FALSE`

## 19. Evidence-handling rules

- Terminal-first operation remains active.
- Files are requested only at important freeze or inspection gates.
- Production source remains unmodified.
- Batch 5 remains untouched.
- Raw evidence is retained alongside summaries.
- Hashes bind frozen evidence.
- No inconvenient or failing evidence may be silently removed.

