# PA-02: Comprehensive CBMC Verification Record for the Full Signed Contract-Valid Domain of `mlk_poly_add`

## Independent Harness Design, Verification Argument, Scope, Distinctness, and Combined PA-01/PA-02 Assurance Position

**Target project:** `pq-code-package/mlkem-native`  
**Target function:** `mlk_poly_add`  
**Verification method:** CBMC bounded model checking  
**Verification campaign item:** PA-02  
**Result status:** `VERIFICATION SUCCESSFUL`  
**Document type:** Self-contained technical record of the generated harness and verification argument

---

## 1. Purpose of This Record

This document records the complete design and verification argument for PA-02, the second focused CBMC experiment for `mlk_poly_add`.

PA-02 extends the earlier PA-01 canonical-domain experiment. PA-01 considered coefficients in the canonical FIPS 203 range `0..q-1`. PA-02 instead considers the full signed and non-canonical `int16_t` input space, subject only to the necessary mathematical condition that each coefficient-wise sum is representable in the `int16_t` output type.

The purpose of PA-02 is to establish the strongest practically meaningful CBMC-level functional and safety claim for the portable C implementation of `mlk_poly_add` without falsely requiring an `int16_t` output to represent mathematically impossible values.

The generated PA-02 harness was executed against the production `mlk_poly_add` implementation and CBMC returned:

```text
VERIFICATION SUCCESSFUL
```

This report deliberately omits result counters, timestamps, hashes, and raw property listings. Those values are not required for the intended professor-facing explanation of the verification argument. The report instead concentrates on what was verified, why the assumptions are necessary, how the harness exercises the production function, how PA-02 differs from PA-01, how the generated harness differs in design from a minimal repository contract wrapper, and what conclusions are scientifically justified.

---

## 2. Verification Objective

The PA-02 verification objective is:

> For every pair of signed `int16_t` coefficient arrays whose exact coefficient-wise sums are representable in `int16_t`, prove that the portable C implementation of `mlk_poly_add` computes the exact in-place sum, preserves the read-only operand, represents the correct result modulo `q`, satisfies commutativity and additive identity, and violates none of the enabled CBMC memory, pointer, arithmetic, conversion, or loop-unwinding checks.

This objective is broader than PA-01.

PA-01 established correctness for canonical representatives:

```text
0 <= a[i] < q
0 <= b[i] < q
```

PA-02 admits all signed `int16_t` values:

```text
INT16_MIN <= a[i] <= INT16_MAX
INT16_MIN <= b[i] <= INT16_MAX
```

subject to the necessary condition:

```text
INT16_MIN <= a[i] + b[i] <= INT16_MAX
```

The mathematical sum used to state this condition is evaluated in `int32_t`, so the assumption itself is free from `int16_t` overflow.

---

## 3. Target Function

The target is the production `mlk_poly_add` implementation in `mlkem-native`.

Its operational behaviour is:

```c
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }
}
```

The function receives an accumulator polynomial `r`, a read-only polynomial `b`, iterates over every coefficient, adds `b->coeffs[i]` into `r->coeffs[i]`, and stores the result back into `r`. It does not perform modular reduction inside the function.

The production representation uses:

```c
int16_t coeffs[MLKEM_N];
```

with:

```text
MLKEM_N = 256
MLKEM_Q = 3329
```

---

## 4. Why PA-02 Was Necessary

PA-01 proved the function for canonical representatives of elements of `Z_q`. That domain directly reflects the standard mathematical interpretation.

Cryptographic implementations, however, frequently use signed or non-canonical intermediate representatives. A coefficient may be negative, greater than or equal to `q`, less than or equal to `-q`, or congruent modulo `q` to a canonical representative.

Examples admitted by PA-02 include:

```text
-30000 + 1000
-3329 + 3329
-1 + 1
5000 + (-7000)
32767 + 0
-32768 + 0
```

These pairs are outside or partly outside PA-01, yet their exact sums are representable in `int16_t`. PA-02 verifies them symbolically and universally rather than as concrete test cases.

---

## 5. Why Unrestricted Exact Addition Is Impossible

A claim covering every arbitrary pair of `int16_t` values would be mathematically false.

For example:

```text
32767 + 1 = 32768
```

but `32768` is greater than `INT16_MAX`. Similarly:

```text
-32768 + (-1) = -32769
```

but `-32769` is less than `INT16_MIN`.

Therefore, the condition

```text
INT16_MIN <= a[i] + b[i] <= INT16_MAX
```

is not an artificial restriction added merely to obtain success. It is the exact representability boundary required by the output type.

A later PA-03 negative-control experiment should remove this condition and confirm that CBMC finds an overflow or conversion counterexample. Such a result would demonstrate why PA-02's precondition is necessary.

---

## 6. PA-02 Symbolic Input Model

### 6.1 Symbolic coefficient generation

The harness uses:

```c
static int16_t pa02_nondet_int16(void)
{
  int16_t value;
  return value;
}
```

CBMC treats the uninitialised local as an arbitrary symbolic `int16_t` value. Each coefficient is therefore not one test value; it ranges over every permitted signed value.

### 6.2 Full signed range

Before assumptions, every operand coefficient may take any value in:

```text
[-32768, 32767]
```

No canonical-range assumption is imposed.

### 6.3 Exact mathematical sum

The harness computes:

```c
mathematical_sum =
    (int32_t)a.coeffs[i] +
    (int32_t)b.coeffs[i];
```

The `int32_t` model can represent every sum of two `int16_t` values.

### 6.4 Contract-validity assumption

The only arithmetic-domain restriction is:

```c
__CPROVER_assume(mathematical_sum >= (int32_t)INT16_MIN);
__CPROVER_assume(mathematical_sum <= (int32_t)INT16_MAX);
```

This admits every signed or non-canonical pair for which exact storage in `int16_t` is possible.

---

## 7. Representation and Parameter Binding

The harness asserts:

```text
MLKEM_N == 256
MLKEM_Q == 3329
INT16_MIN == -32768
INT16_MAX == 32767
```

These are assertions rather than assumptions. An incompatible build therefore fails visibly instead of being silently excluded.

---

## 8. Object Construction and Disjointness

The harness creates separate polynomial objects:

```text
a
b
a_before
b_before
sum_ab
sum_ba
zero
identity_result
```

The target is called three times:

```c
mlk_poly_add(&sum_ab, &b);
mlk_poly_add(&sum_ba, &a);
mlk_poly_add(&identity_result, &zero);
```

Each accumulator and read-only operand are distinct automatic objects. No pointer-separation assumption is injected; separation follows from object construction.

The harness also asserts the distinction explicitly:

```c
__CPROVER_assert(&sum_ab != &b, ...);
__CPROVER_assert(&sum_ba != &a, ...);
__CPROVER_assert(&identity_result != &zero, ...);
```

PA-02 does not claim that `r == b` is legal according to the API. Aliasing is reserved for a separate diagnostic experiment.

---

## 9. Frozen Pre-State Values

Before target execution, the harness records:

```c
a_before = a;
b_before = b;
```

These snapshots allow postconditions to be stated against the original values and prevent expected results from being calculated from already modified state.

---

## 10. Modulo-`q` Normalisation

Signed representatives require careful modular normalisation because the C remainder operator may return a negative result.

The harness defines:

```c
static int32_t pa02_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}
```

The result lies in `0..q-1`. This helper connects signed machine representatives to abstract elements of `Z_q`.

---

## 11. Explicit PA-02 Properties

### 11.1 P1 — Exact signed addition

For every coefficient, PA-02 proves:

```text
sum_ab[i] = a_before[i] + b_before[i]
```

with the expected value evaluated independently in `int32_t`.

This is the central functional property and covers the complete contract-valid signed domain.

### 11.2 P2 — Modulo-`q` congruence

PA-02 proves:

```text
mod_q(sum_ab[i]) = mod_q(a_before[i] + b_before[i])
```

The stored signed or non-canonical result therefore represents the correct element of `Z_q`.

### 11.3 P3 — Canonical-residue refinement

PA-02 also proves:

```text
mod_q(sum_ab[i]) =
    mod_q(mod_q(a_before[i]) + mod_q(b_before[i]))
```

This connects arbitrary machine representatives, their canonical residues, and the result produced by the target.

### 11.4 P4 — Read-only frame properties

PA-02 proves that objects supplied through the read-only parameter remain unchanged:

```text
a_after[i] = a_before[i]
b_after[i] = b_before[i]
zero_after[i] = 0
```

### 11.5 P5 — Commutativity

The harness compares two real executions:

```text
a + b
b + a
```

and proves:

```text
sum_ab[i] = sum_ba[i]
```

### 11.6 P6 — Additive identity

The harness executes `a + 0` and proves:

```text
identity_result[i] = a_before[i]
```

---

## 12. CBMC-Generated Safety Properties

The runner enables checks for:

```text
array bounds
pointer validity
pointer overflow
signed overflow
unsigned overflow
type conversion
division by zero
undefined shifts
loop-unwinding completeness
```

For the reached `mlk_poly_add` execution, these checks cover valid coefficient access, valid pointer dereference, absence of target arithmetic overflow in the admitted domain, safe conversion to `int16_t`, and complete exploration of the coefficient loop.

The successful result means that no enabled explicit or tool-generated property was violated in the PA-02 model.

---

## 13. Loop Completeness

The runner uses:

```text
--unwind 257
--unwinding-assertions
```

The target processes 256 coefficients. The unwinding assertion prevents success if the configured bound truncates a required iteration.

---

## 14. Direct Execution of the Production Body

PA-02 compiles:

```text
pa02_mlk_poly_add_full_signed_contract_valid_harness.c
mlkem/src/poly.c
```

into a GOTO model.

The repository's existing proof harness is not linked. The production function body is called directly from the generated harness. Repository contract replacement and loop-contract transformation are not enabled for this experiment. The verified backend is the portable C implementation.

---

## 15. Controlled Verification Workflow

The generated runner performs the following sequence:

1. validates the requested parameter set;
2. checks that required tools are available;
3. confirms execution from the repository root;
4. confirms the generated harness is present;
5. checks the intended repository revision;
6. records the experiment identity;
7. records tool information;
8. preserves the harness and runner in the result directory;
9. compiles the harness and production source to a GOTO model;
10. runs CBMC in text mode;
11. runs CBMC in JSON mode;
12. accepts success only when build and both CBMC runs succeed.

---

## 16. PA-02 Result

The generated PA-02 harness was executed against the production implementation. The final status was:

```text
VERIFICATION SUCCESSFUL
```

The result is universal over every symbolic execution admitted by the assumptions. It is not a finite collection of hand-picked tests.

---

## 17. What PA-02 Proves

Within its declared scope, PA-02 proves that for every coefficient index and every pair of `int16_t` operands satisfying the representability condition, the portable C implementation of `mlk_poly_add`:

1. computes the exact signed mathematical sum;
2. stores that exact sum in the accumulator;
3. satisfies the enabled conversion check;
4. satisfies the enabled signed-overflow check;
5. produces a result congruent to the mathematical sum modulo `q`;
6. agrees with addition of the operands' canonical residues;
7. preserves read-only operands;
8. satisfies coefficient-wise commutativity;
9. satisfies additive identity;
10. performs reached array accesses within bounds;
11. satisfies reached pointer-validity obligations;
12. completes all coefficient iterations within the asserted unwind bound;
13. executes against the intended ML-KEM parameters; and
14. executes the production body directly.

This is the complete exact-addition domain permitted by the `int16_t` result type.

---

## 18. What PA-02 Does Not Prove

PA-02 does not establish:

1. exact addition when the mathematical result is outside the `int16_t` range;
2. that the representability precondition is unnecessary;
3. legality of `r == b` according to the API;
4. the exact bounds supplied by every production caller;
5. correctness of functions other than `mlk_poly_add`;
6. correctness of all of `poly.c`;
7. correctness of `mlk_poly_sub`;
8. correctness of Barrett or Montgomery reduction;
9. correctness of NTT or inverse NTT;
10. correctness of compression or encoding;
11. end-to-end correctness of K-PKE or ML-KEM;
12. cryptographic security;
13. physical constant-time behaviour;
14. microarchitectural side-channel resistance;
15. architecture-specific assembly correctness;
16. universal equivalence across all compilers and platforms;
17. correctness of future repository revisions;
18. absolute uniqueness relative to an unseen repository harness; or
19. perfect clean-room independence from every source-level formal annotation.

These exclusions define the proof boundary; they do not invalidate the successful result.

---

## 19. Difference Between PA-01 and PA-02

| Dimension | PA-01 | PA-02 |
|---|---|---|
| Primary purpose | FIPS-canonical functional refinement | Full signed contract-valid proof |
| Input coefficient range | `0..q-1` | entire `int16_t` range |
| Negative values | excluded | included |
| Values `>= q` | excluded | included |
| Non-canonical representatives | limited | included |
| Main restriction | canonical domain | exact sum must fit `int16_t` |
| Output range | `[0, 2q-2]` | complete representable `int16_t` range |
| Modulo connection | canonical sum to FIPS residue | signed result to canonical residue |
| Exact addition | proved | proved |
| Operand preservation | proved | proved |
| Commutativity | proved | proved |
| Identity | proved | proved |
| Direct production execution | yes | yes |
| Safety checks | enabled | enabled |

PA-01 is specification-oriented. PA-02 is implementation-contract-oriented.

---

## 20. Combined PA-01 and PA-02 Assurance Position

PA-01 established correctness for canonical FIPS-domain coefficients. PA-02 established correctness for arbitrary signed and non-canonical representatives whenever the exact result is representable in `int16_t`.

The combined conclusion is:

> The portable C implementation of `mlk_poly_add` has been successfully verified across both the canonical FIPS coefficient domain and the complete signed/non-canonical contract-valid `int16_t` domain represented by the independently generated CBMC harnesses.

The combined evidence is stronger than either result alone:

- PA-01 gives direct FIPS-domain interpretation;
- PA-02 gives the broadest exact machine-level domain;
- both execute the production body;
- both prove functional and relational properties;
- both enable relevant memory and arithmetic checks.

---

## 21. Independent Design and Distinctness

The PA-02 harness was independently authored and was not constructed by copying the repository's original harness.

It contains several design elements beyond a minimal direct contract wrapper:

- a full signed symbolic domain;
- a mathematically derived representability condition;
- an independent `int32_t` mathematical model;
- signed modulo-`q` normalisation;
- canonical-residue refinement;
- three production-function executions;
- frozen pre-state copies;
- explicit object-disjointness assertions;
- frame assertions;
- commutativity;
- additive identity;
- dual text and JSON execution;
- repository-revision checking;
- automated evidence preservation.

The strongest accurate novelty statement is:

> PA-02 is an independently authored and structurally distinct verification harness generated without viewing the repository's original `mlk_poly_add` harness.

The stronger assertion that no idea overlaps with the unseen original harness is not yet established and would require a post-freeze comparison.

---

## 22. Formal-Artefact Exposure Disclosure

During earlier source collection, source-level contracts and loop invariants embedded in the production files were visible.

The campaign is therefore accurately described as:

```text
original-harness-blind,
but not perfectly blind to every existing formal annotation
```

This limitation is disclosed rather than hidden. The PA-02 harness remains independently designed in its symbolic domain, modular normalisation, relational properties, and reproducibility workflow.

---

## 23. Why the Assumption Is Not Success-Forcing

An assumption would be suspicious if it excluded states that expose a valid implementation defect without an independent reason.

PA-02's assumption is independently justified by the result type. Exact values outside the `int16_t` range cannot be stored by any implementation with an `int16_t` output.

The condition therefore defines the valid exact-addition domain rather than manufacturing success. PA-03 will test this reasoning by removing the assumption and expecting a counterexample.

---

## 24. Vacuity Analysis

The assumptions are satisfiable. Examples include:

```text
0 + 0
1 + (-1)
32767 + 0
-32768 + 0
-30000 + 1000
```

The domain remains very large and symbolic. The target is called directly three times. The harness compares output with an independent `int32_t` model and compares multiple target executions, reducing the risk of trivial success.

---

## 25. Threats to Validity

### 25.1 Model boundary

The result is valid for CBMC's model of the compiled portable C sources.

### 25.2 Assumption correctness

The proof relies on the representability condition accurately expressing the valid exact-addition domain.

### 25.3 Call-site applicability

PA-02 proves the function for all valid inputs but does not prove that every production caller satisfies the precondition.

### 25.4 Backend scope

The experiment covers the portable C body in the selected configuration.

### 25.5 Source-annotation exposure

Existing source contracts and loop invariants were visible during earlier context collection.

### 25.6 Novelty evaluation

Structural distinction is documented, but exact comparison with the original repository harness remains future work.

### 25.7 Property-specific nature

Success applies only to the encoded properties and enabled checks.

---

## 26. Reproducibility

Place the generated harness and runner in the repository root and execute:

```bash
./run_pa02_mlk_poly_add_full_signed_cbmc.sh 768
```

The runner builds the GOTO model from the generated harness and `mlkem/src/poly.c`, runs CBMC in text and JSON modes, and reports success only if both verification runs succeed.

---

## 27. Professor-Facing Result Statement

> PA-02 independently generated and evaluated a CBMC harness for the portable C implementation of `mlk_poly_add`. Unlike the earlier canonical-domain experiment, PA-02 allowed every signed and non-canonical `int16_t` operand pair whose exact coefficient-wise sum is representable in `int16_t`. The harness directly executed the production function and checked exact signed addition, signed modulo-`q` refinement, agreement with canonical-residue addition, preservation of read-only operands, commutativity, additive identity, object disjointness, and selected CBMC memory and arithmetic safety properties. CBMC completed the verification successfully. The result establishes correctness over the complete exact-addition domain of the output representation, subject to the documented configuration and model boundary.

---

## 28. Correct Claim About `mlk_poly_add`

After PA-01 and PA-02, the following claim is justified:

> `mlk_poly_add` has been successfully verified by independently generated CBMC harnesses for both canonical FIPS representatives and the complete signed/non-canonical contract-valid `int16_t` domain.

The preferred precise wording is:

> The portable C implementation of `mlk_poly_add` is verified within the declared PA-01 and PA-02 harness contracts and CBMC configurations.

---

## 29. Next Experiment: PA-03

PA-03 should remove the representability assumptions and use completely unrestricted symbolic `int16_t` arrays.

The expected outcome is a counterexample in which the exact mathematical sum lies outside the `int16_t` range.

PA-03 will not try to suppress or repair this failure. Its purpose is to demonstrate that the PA-02 precondition is necessary and that PA-02 did not add an arbitrary success-producing assumption.

---

## 30. Final Conclusion

PA-02 successfully extends the `mlk_poly_add` campaign from canonical FIPS representatives to the full signed and non-canonical domain for which exact `int16_t` addition is mathematically representable.

The harness uses arbitrary symbolic signed coefficients, imposes only the necessary representability condition, directly executes the production function, verifies exact signed addition, connects signed machine representatives to canonical modulo-`q` values, checks preservation of read-only operands, checks commutativity and identity, maintains legal disjoint calls, enables relevant CBMC safety checks, and asserts complete loop unwinding.

The final PA-02 status is:

```text
VERIFIED WITHIN THE COMPLETE CONTRACT-VALID SIGNED INT16_T DOMAIN
```

Combined with PA-01, this provides a strong layered CBMC argument for the portable C `mlk_poly_add` implementation before proceeding to PA-03 and then to other selected functions such as `mlk_poly_sub` and Barrett reduction.

---

# Appendix A — Complete PA-02 Harness

```c
/*
 * PA-02: Full signed/non-canonical contract-valid CBMC harness
 *         for mlk_poly_add
 *
 * Target repository:
 *   pq-code-package/mlkem-native
 * Target commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 *
 * Verification objective:
 *   Verify the portable C mlk_poly_add implementation for every pair of
 *   signed int16_t coefficient arrays whose coefficient-wise mathematical
 *   sums are representable in int16_t.
 *
 * This is broader than the PA-01 canonical FIPS-domain harness:
 *   - coefficients may be negative;
 *   - coefficients may be greater than or equal to q;
 *   - coefficients may be any int16_t value;
 *   - the only arithmetic-domain restriction is that each exact sum fits
 *     in int16_t, which is the function's necessary representability
 *     precondition.
 *
 * The harness:
 *   - directly executes the production function body;
 *   - keeps target-call objects disjoint by construction;
 *   - proves exact signed addition;
 *   - proves modulo-q congruence for signed/non-canonical representatives;
 *   - proves read-only operand preservation;
 *   - checks commutativity and additive identity;
 *   - relies on CBMC safety instrumentation for bounds, pointers,
 *     overflows, conversions, shifts, and complete loop unwinding.
 *
 * Important scope:
 *   This harness does not claim that an exact mathematical sum can be
 *   represented when it is outside [INT16_MIN, INT16_MAX]. PA-03 will be
 *   the unrestricted negative-control experiment demonstrating why that
 *   precondition is necessary.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * CBMC treats the uninitialised local value as symbolic. Supplying a real
 * function body avoids a "no body for callee" verification failure.
 */
static int16_t pa02_nondet_int16(void)
{
  int16_t value;
  return value;
}

/*
 * Convert any signed integer representative to the canonical residue
 * 0..q-1. C remainder may be negative, so one q is added when needed.
 */
static int32_t pa02_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;

  mlk_poly a_before;
  mlk_poly b_before;

  mlk_poly sum_ab;
  mlk_poly sum_ba;

  mlk_poly zero;
  mlk_poly identity_result;

  unsigned i;
  int32_t mathematical_sum;
  int32_t actual_residue;
  int32_t expected_residue;
  int32_t canonical_operand_sum_residue;

  /*
   * Bind the experiment to the intended representation and FIPS ring
   * parameters. These are assertions rather than assumptions so that an
   * incompatible build fails visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PA02_PARAMETER_BINDING: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PA02_PARAMETER_BINDING: MLKEM_Q must equal 3329");
  __CPROVER_assert(INT16_MIN == -32768,
                   "PA02_REPRESENTATION_BINDING: INT16_MIN must equal -32768");
  __CPROVER_assert(INT16_MAX == 32767,
                   "PA02_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Generate arbitrary signed int16_t coefficients.
   *
   * The only semantic assumption is the necessary contract-validity
   * condition:
   *
   *   INT16_MIN <= a[i] + b[i] <= INT16_MAX.
   *
   * The addition used to state the assumption is performed in int32_t,
   * where every sum of two int16_t values is representable.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa02_nondet_int16();
    b.coeffs[i] = pa02_nondet_int16();

    mathematical_sum =
        (int32_t)a.coeffs[i] + (int32_t)b.coeffs[i];

    __CPROVER_assume(mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(mathematical_sum <= (int32_t)INT16_MAX);

    zero.coeffs[i] = 0;
  }

  a_before = a;
  b_before = b;

  sum_ab = a;
  sum_ba = b;
  identity_result = a;

  /*
   * PA-02 uses legal, disjoint target calls. The explicit pointer
   * assertions make the object-separation boundary visible in the result.
   */
  __CPROVER_assert(&sum_ab != &b,
                   "PA02_DISJOINTNESS: sum_ab and b are distinct objects");
  __CPROVER_assert(&sum_ba != &a,
                   "PA02_DISJOINTNESS: sum_ba and a are distinct objects");
  __CPROVER_assert(&identity_result != &zero,
                   "PA02_DISJOINTNESS: identity_result and zero are distinct");

  mlk_poly_add(&sum_ab, &b);
  mlk_poly_add(&sum_ba, &a);
  mlk_poly_add(&identity_result, &zero);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)b_before.coeffs[i];

    actual_residue = pa02_mod_q((int32_t)sum_ab.coeffs[i]);
    expected_residue = pa02_mod_q(mathematical_sum);

    canonical_operand_sum_residue =
        pa02_mod_q(
            pa02_mod_q((int32_t)a_before.coeffs[i]) +
            pa02_mod_q((int32_t)b_before.coeffs[i]));

    /*
     * P1: Exact implementation-level signed addition over the complete
     * contract-valid int16_t domain.
     */
    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] == mathematical_sum,
        "PA02_P1_EXACT_SIGNED_SUM: result equals the exact int32 mathematical sum");

    /*
     * P2: The concrete signed/non-canonical result represents the correct
     * abstract element of Z_q.
     */
    __CPROVER_assert(
        actual_residue == expected_residue,
        "PA02_P2_MOD_Q_CONGRUENCE: result is congruent to the exact sum modulo q");

    /*
     * P3: The same result agrees with addition of the canonical residues
     * of both potentially signed/non-canonical operands.
     */
    __CPROVER_assert(
        actual_residue == canonical_operand_sum_residue,
        "PA02_P3_CANONICAL_RESIDUE_REFINEMENT: result matches canonical operand addition");

    /*
     * P4: Read-only operands remain unchanged across the target calls.
     */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "PA02_P4_LEFT_INPUT_FRAME: a remains unchanged when used read-only");

    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "PA02_P4_RIGHT_INPUT_FRAME: b remains unchanged when used read-only");

    __CPROVER_assert(
        zero.coeffs[i] == 0,
        "PA02_P4_ZERO_FRAME: zero remains unchanged when used read-only");

    /*
     * P5: Relational commutativity over every contract-valid signed pair.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] == sum_ba.coeffs[i],
        "PA02_P5_COMMUTATIVITY: a+b equals b+a coefficient-wise");

    /*
     * P6: Additive identity over the complete int16_t domain.
     */
    __CPROVER_assert(
        identity_result.coeffs[i] == a_before.coeffs[i],
        "PA02_P6_IDENTITY: a+0 equals a coefficient-wise");
  }

  return 0;
}
```

---

# Appendix B — Complete PA-02 Runner

```bash
#!/usr/bin/env bash
#
# PA-02 runner:
# Verify mlk_poly_add over the complete signed/non-canonical
# contract-valid int16_t domain.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa02_mlk_poly_add_full_signed_cbmc.sh
#   ./run_pa02_mlk_poly_add_full_signed_cbmc.sh 768
#
# The optional first argument is 512, 768, or 1024. Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-02"
CAMPAIGN_SCOPE="full_signed_noncanonical_contract_valid_domain"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="pa02_mlk_poly_add_full_signed_contract_valid_harness.c"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa02_mlk_poly_add_signed_valid_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/pa02_mlk_poly_add.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] || [ ! -f "mlkem/src/poly.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

if [ ! -f "${HARNESS}" ]; then
  echo "ERROR: ${HARNESS} is not present in the repository root." >&2
  exit 2
fi

mkdir -p "${OUT_DIR}"

CURRENT_COMMIT="$(git rev-parse HEAD)"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Harness: ${HARNESS}"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1
sha256sum "${HARNESS}" > "${OUT_DIR}/harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
cp "${HARNESS}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-02 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

# Directly analyse the portable production C body:
#   - do not define the repository's CBMC annotation mode;
#   - do not enable native arithmetic;
#   - do not link any repository proof harness.
BUILD_COMMAND=(
  goto-cc
  -I.
  -Imlkem
  -Imlkem/src
  -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
  "${HARNESS}"
  mlkem/src/poly.c
  -o "${GOTO_MODEL}"
)

printf '%q ' "${BUILD_COMMAND[@]}" > "${OUT_DIR}/build_command.txt"
printf '\n' >> "${OUT_DIR}/build_command.txt"

echo "===== PA-02: BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  {
    echo "campaign=${CAMPAIGN_ID}"
    echo "build_exit=${BUILD_EXIT}"
    echo "final_status=BUILD_FAILED"
  } > "${OUT_DIR}/summary.txt"

  echo "BUILD FAILED. Preserve and return goto_cc_build.log."
  exit "${BUILD_EXIT}"
fi

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

CBMC_TEXT_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --trace
)

printf '%q ' "${CBMC_TEXT_COMMAND[@]}" > "${OUT_DIR}/cbmc_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_command.txt"

echo
echo "===== PA-02: RUNNING CBMC TEXT VERIFICATION ====="
"${CBMC_TEXT_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/cbmc_output.txt"
CBMC_TEXT_EXIT=${PIPESTATUS[0]}
echo "${CBMC_TEXT_EXIT}" > "${OUT_DIR}/cbmc.exit"

CBMC_JSON_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --json-ui
)

printf '%q ' "${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_json_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_json_command.txt"

echo
echo "===== PA-02: RUNNING CBMC JSON VERIFICATION ====="
"${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_output.json" 2> \
  "${OUT_DIR}/cbmc_json_stderr.txt"
CBMC_JSON_EXIT=$?
echo "${CBMC_JSON_EXIT}" > "${OUT_DIR}/cbmc_json.exit"

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_text_exit=${CBMC_TEXT_EXIT}"
  echo "cbmc_json_exit=${CBMC_JSON_EXIT}"

  if [ "${BUILD_EXIT}" -eq 0 ] &&
     [ "${CBMC_TEXT_EXIT}" -eq 0 ] &&
     [ "${CBMC_JSON_EXIT}" -eq 0 ]; then
    echo "final_status=VERIFICATION_SUCCESSFUL"
  else
    echo "final_status=FAILED_OR_INCONCLUSIVE"
  fi
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-02 SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

exit "${CBMC_TEXT_EXIT}"
```

---

# Appendix C — PA-02 Property Ledger

| ID | Property | Status |
|---|---|---|
| PA02-B1 | `MLKEM_N == 256` | Verified |
| PA02-B2 | `MLKEM_Q == 3329` | Verified |
| PA02-B3 | expected signed 16-bit range | Verified |
| PA02-D1 | legal calls use distinct objects | Verified |
| PA02-P1 | exact signed coefficient sum | Verified |
| PA02-P2 | result congruent to exact sum modulo `q` | Verified |
| PA02-P3 | result agrees with canonical-residue addition | Verified |
| PA02-P4A | left read-only operand preserved | Verified |
| PA02-P4B | right read-only operand preserved | Verified |
| PA02-P4C | zero operand preserved | Verified |
| PA02-P5 | commutativity | Verified |
| PA02-P6 | additive identity | Verified |
| PA02-S1 | reached array accesses satisfy bounds checks | Verified |
| PA02-S2 | reached pointer operations satisfy pointer checks | Verified |
| PA02-S3 | reached arithmetic satisfies overflow checks | Verified |
| PA02-S4 | narrowing conversion satisfies conversion checks | Verified |
| PA02-S5 | loop unwinding is complete | Verified |

---

# Appendix D — Combined PA-01/PA-02 Coverage Summary

| Verification question | PA-01 | PA-02 |
|---|---:|---:|
| Canonical representatives | Yes | Included where sums are representable |
| Negative representatives | No | Yes |
| Non-canonical representatives | Limited | Yes |
| Exact addition | Yes | Yes |
| Modulo-`q` meaning | Yes | Yes |
| Input preservation | Yes | Yes |
| Commutativity | Yes | Yes |
| Additive identity | Yes | Yes |
| Complete valid signed domain | No | Yes |
| Unrestricted invalid sums | No | Deferred to PA-03 |
| Production call-site bounds | No | No |
| Aliasing legality | No | No |
| Other polynomial functions | No | No |

---

# Appendix E — Terminology

**Canonical representative:** An integer in `0..q-1` representing an element of `Z_q`.

**Contract-valid domain:** Inputs satisfying the conditions required for the function's intended exact behaviour to be representable and defined.

**Frame property:** A property stating that an object not intended to be modified remains unchanged.

**Non-canonical representative:** A signed or out-of-range integer congruent modulo `q` to a canonical representative.

**Relational property:** A property comparing multiple executions, such as commutativity.

**Representability condition:** The requirement that an exact mathematical result fit in the target machine type.

**Symbolic input:** An input left arbitrary in the CBMC model and restricted only by explicit assumptions.

**Unwinding assertion:** A property ensuring that the configured loop bound is sufficient.

---

# Reference

National Institute of Standards and Technology (2024), *Module-Lattice-Based Key-Encapsulation Mechanism Standard*, FIPS 203, DOI: `10.6028/NIST.FIPS.203`.
