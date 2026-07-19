# PA-04: Aliasing Diagnostic Record for `mlk_poly_add`

## Complete A-to-Z Technical Documentation of the Safe-Aliasing Proof and Unrestricted-Aliasing Negative Control

**Target project:** `pq-code-package/mlkem-native`  
**Target function:** `mlk_poly_add`  
**Verification method:** CBMC bounded model checking  
**Campaign item:** PA-04  
**Campaign scope:** Out-of-contract aliasing diagnostic  
**Final campaign status:** `PA04_ALIASING_DIAGNOSTIC_CONFIRMED`  
**Document type:** Self-contained formal technical record

---

## 1. Executive Summary

PA-04 investigated the behaviour of the production `mlk_poly_add` implementation when its two
pointer parameters designate the same `mlk_poly` object.

The normal API contract requires the accumulator and read-only operand to be disjoint. PA-04
therefore does not attempt to alter the public contract. Instead, it performs an explicit
out-of-contract implementation diagnostic.

The campaign contains two sub-experiments.

### PA-04A — Safe-domain aliasing proof

PA-04A calls:

```c
mlk_poly_add(&a, &a);
```

with every coefficient restricted to the exact safe-doubling domain:

```text
-16384 <= a[i] <= 16383
```

Within this domain, doubling is representable in `int16_t`.

CBMC verified that the current portable C body:

- performs exact coefficient-wise doubling;
- produces the correct result modulo `q`;
- agrees with canonical-residue doubling;
- produces the same result as a legal disjoint call with equal-valued operands;
- preserves the read-only operand in the legal comparison execution;
- remains inside the derived output range;
- satisfies the enabled memory, pointer, arithmetic, conversion, and loop-unwinding checks.

The PA-04A result was:

```text
VERIFICATION SUCCESSFUL
```

### PA-04B — Unrestricted aliasing negative control

PA-04B uses the same aliasing call but removes the safe-doubling restriction.

Every coefficient may be any signed `int16_t` value.

The harness asks CBMC to prove exact doubling for all such values. That property is mathematically
false because some doubled values do not fit in `int16_t`.

CBMC produced the expected assertion failure and conversion failure.

The campaign classifier confirmed:

```text
pa04b_expected_assertion_failure_observed=yes
pa04b_conversion_failure_observed=yes
pa04b_no_body_failure_observed=no
```

The combined campaign status was:

```text
PA04_ALIASING_DIAGNOSTIC_CONFIRMED
```

PA-04 therefore establishes the actual behaviour of the current portable C body under aliasing
without falsely claiming that aliasing is permitted by the production API.

---

## 2. Research Purpose

The PA-04 research question is:

> What does the current portable C implementation of `mlk_poly_add` do when the accumulator and
> read-only operand are the same object, and where is the exact arithmetic boundary of that
> behaviour?

This question is separate from API legality.

Two distinct claims must be kept apart:

1. **Contract claim:** whether callers are permitted to pass aliased arguments.
2. **Implementation claim:** what the current body does if such a call is made.

PA-04 addresses only the second claim.

---

## 3. Target Function

The target implementation is:

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

When `r` and `b` designate the same object, the expression becomes:

```text
a[i] + a[i]
```

for each coefficient.

Therefore, the expected implementation-level behaviour is coefficient-wise doubling.

---

## 4. Why PA-04 Required Two Sub-Experiments

Aliasing does not remove the output-type limitation.

Even when the same object is read twice, exact doubling is only possible when:

```text
INT16_MIN <= 2*a[i] <= INT16_MAX
```

This creates two scientifically distinct questions.

### Safe-domain question

Does the implementation perform exact doubling when the doubled value is representable?

### Unrestricted-domain question

Can exact doubling hold for every possible `int16_t` value?

The first should succeed.

The second should fail.

A combined campaign gives a complete and honest answer.

---

## 5. Contract Status

PA-04 is explicitly classified as:

```text
OUT_OF_CONTRACT_DIAGNOSTIC
```

This classification is central to the interpretation.

A successful aliasing result does not prove that:

- the public API permits aliasing;
- production callers may ignore disjointness requirements;
- compiler optimisations must preserve out-of-contract behaviour under every future configuration;
- repository contracts should be changed.

The correct statement is:

> The current portable C body behaves as verified under the tested aliasing conditions.

---

## 6. PA-04A Symbolic Input Domain

PA-04A uses arbitrary signed symbolic coefficients subject to:

```text
-16384 <= a[i] <= 16383
```

This is the exact safe-doubling domain.

At the lower boundary:

```text
2 * (-16384) = -32768
```

At the upper boundary:

```text
2 * 16383 = 32766
```

Both results are representable in `int16_t`.

The next positive value would fail:

```text
2 * 16384 = 32768
```

The next negative value would fail:

```text
2 * (-16385) = -32770
```

Therefore, the PA-04A bounds are mathematically exact rather than arbitrary.

---

## 7. PA-04A Symbolic Input Generation

The harness uses:

```c
static int16_t pa04a_nondet_int16(void)
{
  int16_t value;
  return value;
}
```

CBMC treats the uninitialised local as symbolic.

Each coefficient may therefore represent any value satisfying the safe-doubling assumptions.

The experiment is universal over the admitted domain and is not a finite concrete test suite.

---

## 8. PA-04A Aliasing Construction

The harness creates:

```c
mlk_poly *r_alias;
const mlk_poly *b_alias;
```

and assigns:

```c
r_alias = &aliased;
b_alias = &aliased;
```

It then asserts:

```c
__CPROVER_assert(
    r_alias == b_alias,
    "PA04A_ALIAS_BINDING: r and b designate the same object");
```

The target is called as:

```c
mlk_poly_add(r_alias, b_alias);
```

This makes aliasing an explicit verified property rather than an informal expectation.

---

## 9. PA-04A Independent Disjoint Reference Execution

PA-04A also constructs:

```text
disjoint_accumulator
disjoint_operand
```

with equal pre-state values but distinct object identities.

It then performs:

```c
mlk_poly_add(&disjoint_accumulator, &disjoint_operand);
```

This legal comparison execution serves as an independent relational reference.

The harness compares:

```text
aliased a+a result
```

against:

```text
legal disjoint equal-valued a+a result
```

This strengthens the experiment beyond merely checking one formula.

---

## 10. PA-04A Mathematical Oracle

For each coefficient, the harness computes:

```c
exact_double =
    (int32_t)aliased_before.coeffs[i] * (int32_t)2;
```

The mathematical model uses `int32_t`.

This ensures that the expected doubled value is calculated independently and without `int16_t`
overflow.

---

## 11. PA-04A Modulo-`q` Normalisation

The harness uses a signed modular-normalisation helper:

```c
static int32_t pa04a_mod_q(int32_t value)
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

This converts arbitrary signed representatives to the canonical range:

```text
0 .. q-1
```

It allows the aliasing result to be connected to abstract polynomial arithmetic modulo `q`.

---

## 12. PA-04A Explicit Properties

### PA04A-P1 — Exact alias doubling

The harness proves:

```text
aliased_after[i] = 2 * aliased_before[i]
```

This is the primary implementation-level property.

---

### PA04A-P2 — Modulo-`q` correctness

The harness proves:

```text
mod_q(aliased_after[i]) =
mod_q(2 * aliased_before[i])
```

This shows that the concrete result represents the correct abstract residue.

---

### PA04A-P3 — Canonical-residue doubling

The harness proves:

```text
mod_q(aliased_after[i]) =
mod_q(2 * mod_q(aliased_before[i]))
```

This connects signed and non-canonical values to canonical ring representatives.

---

### PA04A-P4 — Alias/disjoint equivalence

The harness proves:

```text
aliased_result[i] =
disjoint_equal_operand_result[i]
```

This shows that the current aliasing execution is observationally equivalent to the legal
disjoint execution when both operands initially contain equal values.

---

### PA04A-P5 — Reference input frame

The harness proves that the read-only operand in the legal comparison execution remains unchanged:

```text
disjoint_operand_after[i] =
disjoint_operand_before[i]
```

No equivalent frame condition is asserted for `b_alias` because `b_alias` intentionally points to
the modified accumulator.

---

### PA04A-P6 — Derived output range

The harness proves:

```text
INT16_MIN <= aliased_after[i] <= 32766
```

This is the exact range derived from the safe input bounds.

---

## 13. PA-04A Tool-Generated Safety Properties

The runner enables:

```text
bounds checking
pointer checking
pointer-overflow checking
signed-overflow checking
unsigned-overflow checking
conversion checking
division-by-zero checking
undefined-shift checking
loop-unwinding assertions
```

For the target execution, this includes checks concerning:

- coefficient-array bounds;
- null pointers;
- invalid pointers;
- dead objects;
- deallocated objects;
- object-bound violations;
- loop-counter arithmetic;
- promoted signed addition;
- narrowing conversion to `int16_t`;
- complete iteration over all coefficients.

The successful result means that the safe aliasing execution violated none of the enabled
properties in the CBMC model.

---

## 14. PA-04A Result

The safe-aliasing verification completed successfully.

The campaign summary confirmed:

```text
pa04a_build_exit=0
pa04a_cbmc_text_exit=0
pa04a_cbmc_json_exit=0
pa04a_verification_successful=yes
pa04a_failure_lines_observed=no
```

The correct interpretation is:

> Under the exact safe-doubling coefficient bounds, the current portable C body performs exact
> coefficient-wise doubling when `r` and `b` alias.

---

## 15. PA-04B Unrestricted Domain

PA-04B removes the safe-doubling assumptions.

Every coefficient may be any signed `int16_t` value:

```text
-32768 .. 32767
```

No assumption restricts:

- sign;
- canonical range;
- doubling representability;
- output range.

---

## 16. PA-04B Intentionally Refutable Property

PA-04B computes:

```c
exact_double =
    (int32_t)aliased_before.coeffs[i] * (int32_t)2;
```

and asks CBMC to prove:

```c
__CPROVER_assert(
    (int32_t)aliased.coeffs[i] == exact_double,
    "PA04B_P1_UNRESTRICTED_ALIAS_EXACT_DOUBLING");
```

This property is false over the unrestricted domain.

A counterexample class includes:

```text
a[i] = 16384
exact_double = 32768
```

The exact value cannot be stored in `int16_t`.

---

## 17. PA-04B Expected Conversion Failure

The production body stores:

```c
(int16_t)(a[i] + a[i])
```

For unrestricted coefficients, the conversion may be outside the target range.

The campaign summary confirmed:

```text
pa04b_conversion_failure_observed=yes
```

This verifies that the expected representability boundary was reached in the target operation.

---

## 18. PA-04B Failure Classification

A low-level CBMC failure is accepted as scientific success only when the runner confirms:

- the GOTO model built;
- the text and JSON checks returned the expected failure status;
- the intended unrestricted exact-doubling assertion failed;
- the target conversion failure was observed;
- no missing-body failure occurred.

The summary confirmed:

```text
pa04b_build_exit=0
pa04b_cbmc_text_exit=10
pa04b_cbmc_json_exit=10
pa04b_expected_assertion_failure_observed=yes
pa04b_conversion_failure_observed=yes
pa04b_no_body_failure_observed=no
```

Therefore, the failure was correctly classified.

---

## 19. Final PA-04 Campaign Result

The combined campaign returned:

```text
final_status=PA04_ALIASING_DIAGNOSTIC_CONFIRMED
```

The campaign succeeded because:

1. safe alias doubling was verified;
2. unrestricted alias doubling was refuted;
3. the representability boundary was observed;
4. the failure was not caused by harness infrastructure.

---

## 20. What PA-04 Establishes

PA-04 establishes the following implementation-level facts.

### Within the safe aliasing domain

For every coefficient satisfying:

```text
-16384 <= a[i] <= 16383
```

the current portable C body:

1. computes exact doubling under `r == b`;
2. stores the exact doubled result;
3. produces the correct residue modulo `q`;
4. agrees with canonical-residue doubling;
5. produces the same result as a legal equal-valued disjoint call;
6. satisfies the derived output range;
7. satisfies the enabled target memory and arithmetic checks;
8. completes the full coefficient loop.

### Outside the safe aliasing domain

PA-04B establishes that:

1. unrestricted exact doubling is false;
2. some doubled values are not representable in `int16_t`;
3. the target conversion failure is observable;
4. the safe-doubling condition is necessary.

---

## 21. What PA-04 Does Not Establish

PA-04 does not establish:

1. that aliasing is permitted by the production API;
2. that production callers use aliased arguments;
3. that the repository contract should be weakened;
4. that every future implementation revision will preserve this behaviour;
5. that native or assembly backends behave identically;
6. that aliasing is valid under every compiler optimisation;
7. that unrestricted alias doubling is correct;
8. that every out-of-range input fails in the same way;
9. correctness of any function other than `mlk_poly_add`;
10. complete correctness of `poly.c`;
11. end-to-end ML-KEM correctness;
12. cryptographic security;
13. physical constant-time behaviour;
14. microarchitectural side-channel resistance.

---

## 22. Combined PA-01 to PA-04 Assurance Position

### PA-01

Verified canonical FIPS-domain addition.

### PA-02

Verified the complete signed and non-canonical contract-valid exact-addition domain.

### PA-03

Confirmed that unrestricted exact addition is false outside the `int16_t` representability
boundary.

### PA-04

Characterised out-of-contract aliasing behaviour:

- exact safe doubling succeeds;
- unrestricted exact doubling fails as expected.

The combined position is:

> The portable C implementation of `mlk_poly_add` is verified for canonical FIPS inputs, for the
> complete legal signed exact-addition domain, and for safe aliasing as an explicitly labelled
> out-of-contract diagnostic. Separate negative controls confirm the arithmetic boundaries of
> both disjoint and aliased executions.

---

## 23. Independent Design and Distinctness

PA-04 is independently designed as a paired relational campaign.

Its distinctive elements include:

- explicit construction of `r == b`;
- exact safe-doubling assumptions;
- an independent `int32_t` doubling model;
- signed modulo-`q` refinement;
- comparison with a legal equal-valued disjoint execution;
- frame checking on the legal reference operand;
- explicit output-range assertions;
- a second unrestricted aliasing negative control;
- automatic expected-failure classification;
- rejection of missing-body failures as evidence;
- direct production-body execution.

This is structurally different from a minimal legal-call function harness.

The campaign does not merely ask whether the function satisfies its ordinary contract. It studies
a deliberately excluded pointer relationship and formally separates:

- behaviour within a mathematically safe region;
- behaviour outside that region;
- implementation behaviour;
- API legality.

---

## 24. Novelty Position

The original repository harness was not used as the design source for PA-04.

The strongest accurate novelty claim is:

> PA-04 is an independently authored aliasing diagnostic campaign combining a safe-domain proof,
> a legal disjoint relational reference, and an unrestricted expected-counterexample experiment.

Absolute uniqueness relative to every unseen repository artefact is not claimed.

Existing source-level formal annotations were visible during earlier context collection, so the
campaign remains:

```text
original-harness-blind
but not perfectly blind to every existing formal annotation
```

---

## 25. Vacuity Analysis

### 25.1 Safe domain is satisfiable

The PA-04A domain includes many values:

```text
0
1
-1
16383
-16384
5000
-7000
```

### 25.2 Aliasing is explicit

The harness asserts:

```text
r_alias == b_alias
```

The proof is not accidentally using distinct objects.

### 25.3 Target is reached

The production body is called directly.

### 25.4 Independent comparison exists

The alias result is compared against a separate legal target execution.

### 25.5 Negative control is non-vacuous

Values such as `16384` witness the falsity of unrestricted exact doubling.

---

## 26. Threats to Validity

### 26.1 Out-of-contract status

The result concerns implementation behaviour outside the declared legal-call boundary.

### 26.2 Compiler and model scope

The result applies to the selected CBMC portable C model.

### 26.3 API non-transferability

A successful implementation diagnostic does not automatically become an API guarantee.

### 26.4 Future revisions

A future implementation may legitimately change out-of-contract behaviour.

### 26.5 Backend scope

The result does not cover architecture-specific assembly or unverified native implementations.

### 26.6 Property-specific result

Only the encoded properties and enabled checks are established.

---

## 27. Reproducibility

The campaign is reproduced with:

```bash
./run_pa04_mlk_poly_add_aliasing_campaign.sh 768
```

The runner:

- validates the repository and tools;
- preserves both harnesses;
- builds the PA-04A GOTO model;
- runs PA-04A in text and JSON modes;
- builds the PA-04B GOTO model;
- runs PA-04B in text and JSON modes;
- classifies the expected success and expected failure;
- rejects infrastructure failures;
- writes the combined summary.

---

## 28. Professor-Facing Result Statement

> PA-04 investigated the current portable C behaviour of `mlk_poly_add` when its accumulator and
> read-only operand alias. The experiment was explicitly classified as an out-of-contract
> diagnostic. PA-04A restricted each symbolic coefficient to the exact safe-doubling range and
> verified exact coefficient-wise doubling, modulo-`q` refinement, agreement with canonical
> residue doubling, equality with a legal equal-valued disjoint execution, frame preservation in
> the reference call, and selected CBMC safety properties. PA-04B removed the safe-doubling
> restriction and produced the expected exact-doubling and conversion counterexamples. The
> combined campaign confirmed the current implementation behaviour and its arithmetic boundary
> without claiming that the public API permits aliasing.

---

## 29. Correct Claim After PA-04

The following claim is justified:

> Under the exact safe-doubling domain, the current portable C body of `mlk_poly_add` behaves as
> coefficient-wise doubling when both arguments designate the same polynomial. Outside that
> domain, unrestricted exact doubling is formally refuted.

The following claim is not justified:

> `mlk_poly_add` officially supports aliased arguments.

---

## 30. Next Campaign Item

The next recommended campaign item is:

```text
PA-05: production call-site verification
```

PA-05 should determine whether the actual production callers satisfy:

- required coefficient bounds;
- exact-sum representability;
- pointer validity;
- object disjointness;
- representation expectations.

This closes the gap between proving a function under a precondition and proving that real callers
meet that precondition.

---

## 31. Final Conclusion

PA-04 successfully characterised the aliasing behaviour of the current portable C implementation
of `mlk_poly_add`.

PA-04A verified exact safe doubling under explicit aliasing.

PA-04B confirmed that unrestricted exact doubling is impossible because of the `int16_t`
representability boundary.

The campaign result was:

```text
PA04_ALIASING_DIAGNOSTIC_CONFIRMED
```

The result strengthens the overall `mlk_poly_add` assurance case while preserving the essential
distinction between:

```text
verified implementation behaviour
```

and:

```text
permitted API usage
```

---

# Appendix A — Complete PA-04A Harness

```c
/*
 * PA-04A: Safe-domain aliasing diagnostic for mlk_poly_add
 *
 * This is an out-of-contract implementation diagnostic. A successful
 * result does not amend the API contract or establish that production
 * callers may alias r and b.
 *
 * Expected CBMC result: VERIFICATION SUCCESSFUL
 *
 * Target repository commit:
 * d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa04a_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa04a_mod_q(int32_t value)
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
  mlk_poly aliased;
  mlk_poly aliased_before;

  mlk_poly disjoint_accumulator;
  mlk_poly disjoint_operand;
  mlk_poly disjoint_operand_before;

  mlk_poly *r_alias;
  const mlk_poly *b_alias;

  unsigned i;
  int32_t exact_double;
  int32_t actual_residue;
  int32_t expected_residue;
  int32_t canonical_double_residue;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA04A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA04A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA04A_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA04A_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Exact safe-doubling domain:
   *
   *   -16384 <= x <= 16383
   *
   * Therefore:
   *
   *   -32768 <= 2*x <= 32766
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    aliased.coeffs[i] = pa04a_nondet_int16();

    __CPROVER_assume(
        (int32_t)aliased.coeffs[i] >= -16384);

    __CPROVER_assume(
        (int32_t)aliased.coeffs[i] <= 16383);
  }

  aliased_before = aliased;

  /*
   * Construct a legal disjoint execution from the same pre-state.
   * This allows comparison between:
   *
   *   mlk_poly_add(&a, &a)
   *
   * and a legal equal-valued disjoint call.
   */
  disjoint_accumulator = aliased_before;
  disjoint_operand = aliased_before;
  disjoint_operand_before = disjoint_operand;

  r_alias = &aliased;
  b_alias = &aliased;

  __CPROVER_assert(
      r_alias == b_alias,
      "PA04A_ALIAS_BINDING: r and b designate the same object");

  mlk_poly_add(r_alias, b_alias);

  __CPROVER_assert(
      &disjoint_accumulator != &disjoint_operand,
      "PA04A_DISJOINT_REFERENCE: comparison operands are distinct");

  mlk_poly_add(&disjoint_accumulator, &disjoint_operand);

  for (i = 0; i < MLKEM_N; i++)
  {
    exact_double =
        (int32_t)aliased_before.coeffs[i] * (int32_t)2;

    actual_residue =
        pa04a_mod_q((int32_t)aliased.coeffs[i]);

    expected_residue =
        pa04a_mod_q(exact_double);

    canonical_double_residue =
        pa04a_mod_q(
            pa04a_mod_q((int32_t)aliased_before.coeffs[i]) *
            (int32_t)2);

    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] == exact_double,
        "PA04A_P1_ALIAS_EXACT_DOUBLING: aliased a+a equals exact 2*a");

    __CPROVER_assert(
        actual_residue == expected_residue,
        "PA04A_P2_ALIAS_MOD_Q: alias result is congruent to exact doubling");

    __CPROVER_assert(
        actual_residue == canonical_double_residue,
        "PA04A_P3_CANONICAL_RESIDUE_DOUBLING: alias result matches canonical doubling");

    __CPROVER_assert(
        aliased.coeffs[i] == disjoint_accumulator.coeffs[i],
        "PA04A_P4_ALIAS_DISJOINT_EQUIVALENCE: alias result matches legal equal-operand call");

    __CPROVER_assert(
        disjoint_operand.coeffs[i] ==
            disjoint_operand_before.coeffs[i],
        "PA04A_P5_REFERENCE_INPUT_FRAME: disjoint read-only operand remains unchanged");

    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] >= (int32_t)INT16_MIN,
        "PA04A_P6_OUTPUT_LOWER_BOUND: result is at least INT16_MIN");

    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] <= 32766,
        "PA04A_P6_OUTPUT_UPPER_BOUND: result is at most 32766");
  }

  return 0;
}
```

---

# Appendix B — Complete PA-04B Harness

```c
/*
 * PA-04B: Unrestricted aliasing negative control for mlk_poly_add
 *
 * Scientific purpose:
 *   Show that aliasing does not remove the int16_t representability
 *   boundary. Exact doubling cannot hold for every arbitrary int16_t
 *   coefficient.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Expected campaign interpretation:
 *   EXPECTED_ALIAS_COUNTEREXAMPLE_CONFIRMED
 *
 * This remains an out-of-contract implementation diagnostic.
 *
 * Target repository commit:
 * d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa04b_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly aliased;
  mlk_poly aliased_before;

  mlk_poly *r_alias;
  const mlk_poly *b_alias;

  unsigned i;
  int32_t exact_double;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA04B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA04B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA04B_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA04B_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Completely unrestricted signed int16_t coefficients.
   * No safe-doubling or representability assumption is present.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    aliased.coeffs[i] = pa04b_nondet_int16();
  }

  aliased_before = aliased;

  r_alias = &aliased;
  b_alias = &aliased;

  __CPROVER_assert(
      r_alias == b_alias,
      "PA04B_ALIAS_BINDING: r and b designate the same object");

  mlk_poly_add(r_alias, b_alias);

  for (i = 0; i < MLKEM_N; i++)
  {
    exact_double =
        (int32_t)aliased_before.coeffs[i] * (int32_t)2;

    /*
     * Intentionally false over the unrestricted domain.
     * For example, 16384 doubled is 32768, which is not representable
     * in int16_t.
     */
    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] == exact_double,
        "PA04B_P1_UNRESTRICTED_ALIAS_EXACT_DOUBLING: exact a+a for every int16_t value");
  }

  return 0;
}
```

---

# Appendix C — Complete PA-04 Runner

```bash
#!/usr/bin/env bash
#
# PA-04 combined aliasing campaign for mlk_poly_add.
#
# PA-04A:
#   Safe representable aliasing domain.
#   Expected CBMC result: VERIFICATION SUCCESSFUL.
#
# PA-04B:
#   Unrestricted aliasing negative control.
#   Expected CBMC result: VERIFICATION FAILED.
#
# Final campaign success:
#   PA04_ALIASING_DIAGNOSTIC_CONFIRMED
#
# This campaign is an out-of-contract implementation diagnostic. It does
# not alter the production API contract or permit production aliasing.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa04_mlk_poly_add_aliasing_campaign.sh
#   ./run_pa04_mlk_poly_add_aliasing_campaign.sh 768
#
# Optional parameter set: 512, 768, or 1024.
# Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-04"
CAMPAIGN_SCOPE="out_of_contract_aliasing_diagnostic"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"

SAFE_HARNESS="pa04a_mlk_poly_add_alias_safe_doubling_harness.c"
NEGATIVE_HARNESS="pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c"
NEGATIVE_MARKER="PA04B_P1_UNRESTRICTED_ALIAS_EXACT_DOUBLING"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa04_mlk_poly_add_aliasing_${PARAM_SET}_${TIMESTAMP}"
SAFE_DIR="${OUT_DIR}/pa04a_safe_alias"
NEGATIVE_DIR="${OUT_DIR}/pa04b_unrestricted_alias_negative_control"

SAFE_GOTO="${SAFE_DIR}/pa04a_safe_alias.goto"
NEGATIVE_GOTO="${NEGATIVE_DIR}/pa04b_unrestricted_alias.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee grep; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] || [ ! -f "mlkem/src/poly.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

for harness in "${SAFE_HARNESS}" "${NEGATIVE_HARNESS}"; do
  if [ ! -f "${harness}" ]; then
    echo "ERROR: required harness missing: ${harness}" >&2
    exit 2
  fi
done

mkdir -p "${SAFE_DIR}" "${NEGATIVE_DIR}"

CURRENT_COMMIT="$(git rev-parse HEAD)"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Contract status: out-of-contract implementation diagnostic"
  echo "PA-04A expected result: VERIFICATION SUCCESSFUL"
  echo "PA-04B expected result: VERIFICATION FAILED"
  echo "Final expected interpretation: PA04_ALIASING_DIAGNOSTIC_CONFIRMED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

sha256sum "${SAFE_HARNESS}" > "${OUT_DIR}/pa04a_harness_sha256.txt"
sha256sum "${NEGATIVE_HARNESS}" > "${OUT_DIR}/pa04b_harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"

cp "${SAFE_HARNESS}" "${OUT_DIR}/"
cp "${NEGATIVE_HARNESS}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-04 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
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

build_model()
{
  local harness="$1"
  local goto_model="$2"
  local result_dir="$3"
  local label="$4"
  local build_exit
  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    "${harness}"
    mlkem/src/poly.c
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo "===== ${label}: BUILDING GOTO MODEL ====="
  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  return "${build_exit}"
}

run_text_cbmc()
{
  local goto_model="$1"
  local result_dir="$2"
  local label="$3"
  local text_exit
  local text_command=(
    cbmc
    "${goto_model}"
    "${COMMON_CBMC_OPTIONS[@]}"
    --trace
  )

  printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
  printf '\n' >> "${result_dir}/cbmc_command.txt"

  echo
  echo "===== ${label}: RUNNING CBMC TEXT CHECK ====="
  "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
  text_exit=${PIPESTATUS[0]}
  echo "${text_exit}" > "${result_dir}/cbmc.exit"

  return "${text_exit}"
}

run_json_cbmc()
{
  local goto_model="$1"
  local result_dir="$2"
  local json_exit
  local json_command=(
    cbmc
    "${goto_model}"
    "${COMMON_CBMC_OPTIONS[@]}"
    --json-ui
  )

  printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
  printf '\n' >> "${result_dir}/cbmc_json_command.txt"

  "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
    "${result_dir}/cbmc_json_stderr.txt"
  json_exit=$?
  echo "${json_exit}" > "${result_dir}/cbmc_json.exit"

  return "${json_exit}"
}

SAFE_BUILD_EXIT=0
SAFE_TEXT_EXIT=-1
SAFE_JSON_EXIT=-1

build_model \
  "${SAFE_HARNESS}" \
  "${SAFE_GOTO}" \
  "${SAFE_DIR}" \
  "PA-04A SAFE ALIAS"
SAFE_BUILD_EXIT=$?

if [ "${SAFE_BUILD_EXIT}" -eq 0 ]; then
  run_text_cbmc \
    "${SAFE_GOTO}" \
    "${SAFE_DIR}" \
    "PA-04A SAFE ALIAS"
  SAFE_TEXT_EXIT=$?

  run_json_cbmc \
    "${SAFE_GOTO}" \
    "${SAFE_DIR}"
  SAFE_JSON_EXIT=$?
fi

NEG_BUILD_EXIT=0
NEG_TEXT_EXIT=-1
NEG_JSON_EXIT=-1

build_model \
  "${NEGATIVE_HARNESS}" \
  "${NEGATIVE_GOTO}" \
  "${NEGATIVE_DIR}" \
  "PA-04B UNRESTRICTED ALIAS"
NEG_BUILD_EXIT=$?

if [ "${NEG_BUILD_EXIT}" -eq 0 ]; then
  run_text_cbmc \
    "${NEGATIVE_GOTO}" \
    "${NEGATIVE_DIR}" \
    "PA-04B EXPECTED-FAILURE ALIAS"
  NEG_TEXT_EXIT=$?

  run_json_cbmc \
    "${NEGATIVE_GOTO}" \
    "${NEGATIVE_DIR}"
  NEG_JSON_EXIT=$?
fi

SAFE_VERIFICATION_SUCCESSFUL="no"
SAFE_FAILURE_LINES="yes"

if [ "${SAFE_BUILD_EXIT}" -eq 0 ] &&
   [ "${SAFE_TEXT_EXIT}" -eq 0 ] &&
   [ "${SAFE_JSON_EXIT}" -eq 0 ] &&
   grep -q "VERIFICATION SUCCESSFUL" "${SAFE_DIR}/cbmc_output.txt"; then
  SAFE_VERIFICATION_SUCCESSFUL="yes"
fi

if [ -f "${SAFE_DIR}/cbmc_output.txt" ] &&
   ! grep -q "FAILURE" "${SAFE_DIR}/cbmc_output.txt"; then
  SAFE_FAILURE_LINES="no"
fi

NEG_EXPECTED_ASSERTION_FAILURE="no"
NEG_CONVERSION_FAILURE="no"
NEG_NO_BODY_FAILURE="no"
NEG_VERIFICATION_FAILED="no"

if [ -f "${NEGATIVE_DIR}/cbmc_output.txt" ]; then
  if grep -F "${NEGATIVE_MARKER}" "${NEGATIVE_DIR}/cbmc_output.txt" | \
     grep -q "FAILURE"; then
    NEG_EXPECTED_ASSERTION_FAILURE="yes"
  fi

  if grep "arithmetic overflow on signed type conversion" \
     "${NEGATIVE_DIR}/cbmc_output.txt" | grep -q "FAILURE"; then
    NEG_CONVERSION_FAILURE="yes"
  fi

  if grep -q "no body for callee" "${NEGATIVE_DIR}/cbmc_output.txt"; then
    NEG_NO_BODY_FAILURE="yes"
  fi

  if grep -q "VERIFICATION FAILED" "${NEGATIVE_DIR}/cbmc_output.txt"; then
    NEG_VERIFICATION_FAILED="yes"
  fi
fi

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${SAFE_VERIFICATION_SUCCESSFUL}" = "yes" ] &&
   [ "${SAFE_FAILURE_LINES}" = "no" ] &&
   [ "${NEG_BUILD_EXIT}" -eq 0 ] &&
   [ "${NEG_TEXT_EXIT}" -eq 10 ] &&
   [ "${NEG_JSON_EXIT}" -eq 10 ] &&
   [ "${NEG_EXPECTED_ASSERTION_FAILURE}" = "yes" ] &&
   [ "${NEG_CONVERSION_FAILURE}" = "yes" ] &&
   [ "${NEG_NO_BODY_FAILURE}" = "no" ] &&
   [ "${NEG_VERIFICATION_FAILED}" = "yes" ]; then
  FINAL_STATUS="PA04_ALIASING_DIAGNOSTIC_CONFIRMED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "contract_status=OUT_OF_CONTRACT_DIAGNOSTIC"
  echo "pa04a_build_exit=${SAFE_BUILD_EXIT}"
  echo "pa04a_cbmc_text_exit=${SAFE_TEXT_EXIT}"
  echo "pa04a_cbmc_json_exit=${SAFE_JSON_EXIT}"
  echo "pa04a_verification_successful=${SAFE_VERIFICATION_SUCCESSFUL}"
  echo "pa04a_failure_lines_observed=${SAFE_FAILURE_LINES}"
  echo "pa04b_build_exit=${NEG_BUILD_EXIT}"
  echo "pa04b_cbmc_text_exit=${NEG_TEXT_EXIT}"
  echo "pa04b_cbmc_json_exit=${NEG_JSON_EXIT}"
  echo "pa04b_expected_assertion_failure_observed=${NEG_EXPECTED_ASSERTION_FAILURE}"
  echo "pa04b_conversion_failure_observed=${NEG_CONVERSION_FAILURE}"
  echo "pa04b_no_body_failure_observed=${NEG_NO_BODY_FAILURE}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-04 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA04_ALIASING_DIAGNOSTIC_CONFIRMED" ]; then
  echo
  echo "PA-04 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Safe alias doubling was verified."
  echo "The unrestricted alias boundary was refuted as expected."
  echo "This remains an out-of-contract implementation diagnostic."
else
  echo
  echo "PA-04 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

---

# Appendix D — PA-04 Property Ledger

| ID | Property or check | Outcome |
|---|---|---|
| PA04A-B1 | ML-KEM parameter binding | Verified |
| PA04A-B2 | signed `int16_t` representation binding | Verified |
| PA04A-A1 | `r` and `b` designate the same object | Verified |
| PA04A-P1 | exact safe alias doubling | Verified |
| PA04A-P2 | modulo-`q` doubling correctness | Verified |
| PA04A-P3 | canonical-residue doubling | Verified |
| PA04A-P4 | alias/disjoint equal-value equivalence | Verified |
| PA04A-P5 | legal reference operand preserved | Verified |
| PA04A-P6 | derived doubled-output range | Verified |
| PA04A-S1 | target bounds and pointer checks | Verified |
| PA04A-S2 | target overflow and conversion checks | Verified |
| PA04A-S3 | complete loop unwinding | Verified |
| PA04B-P1 | unrestricted exact alias doubling | Refuted as expected |
| PA04B-S1 | target conversion boundary | Failure observed as expected |
| PA04B-I1 | missing-body failure absent | Confirmed |
| PA04-C1 | combined campaign classification | `PA04_ALIASING_DIAGNOSTIC_CONFIRMED` |

---

# Appendix E — Combined PA Campaign Summary

| Campaign | Main question | Result |
|---|---|---|
| PA-01 | Is canonical FIPS-domain addition correct? | Yes |
| PA-02 | Is complete signed contract-valid addition correct? | Yes |
| PA-03 | Is unrestricted exact addition possible? | No, as expected |
| PA-04 | What happens under explicit aliasing? | Safe doubling verified; unrestricted doubling refuted |

---

# Appendix F — Terminology

**Aliasing:** Two pointer expressions designate the same object or overlapping storage.

**Disjoint call:** Function arguments designate separate non-overlapping objects.

**Out-of-contract diagnostic:** An experiment studying implementation behaviour for an input
relationship excluded by the normal API contract.

**Safe-doubling domain:** Values whose exact doubled result is representable in `int16_t`.

**Relational reference execution:** A second target execution used to compare behaviour across two
different object arrangements.

**Expected counterexample:** A solver-produced witness refuting an intentionally over-broad
property.
