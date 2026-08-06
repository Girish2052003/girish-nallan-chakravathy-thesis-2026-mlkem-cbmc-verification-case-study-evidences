# PA-05: Production Call-Site Verification Record for `mlk_poly_add`

## Complete A-to-Z Technical Documentation of the Three Production Call-Site Obligations

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Target project:** `pq-code-package/mlkem-native`  
**Target function:** `mlk_poly_add`  
**Verification method:** CBMC bounded model checking  
**Campaign item:** PA-05  
**Campaign scope:** Production call-site precondition and semantic verification  
**Parameter set:** ML-KEM-768  
**Final campaign status:** `PA05_PRODUCTION_CALLSITES_VERIFIED`  
**Document type:** Self-contained formal technical record

---

## 1. Executive Summary

PA-05 addresses the gap between proving a function under a precondition and proving that its
production callers satisfy that precondition.

The earlier PA-01 to PA-04 experiments established the behaviour and arithmetic boundaries of the
portable C implementation of `mlk_poly_add`. PA-05 examines all three production calls to
`mlk_poly_add` in the frozen repository revision:

```c
mlk_poly_add(&r->vec[i], &b->vec[i]);
mlk_poly_add(v, epp);
mlk_poly_add(v, k);
```

The campaign consists of:

- **PA-05A:** direct verification of the production `mlk_polyvec_add` caller;
- **PA-05B:** compositional verification of `mlk_poly_add(v, epp)`;
- **PA-05C:** compositional verification of the actual sequential calls
  `mlk_poly_add(v, epp)` and `mlk_poly_add(v, k)`.

The final campaign summary was:

```text
campaign=PA-05
scope=production_callsite_precondition_and_semantic_verification
parameter_set=768
pa05a_polyvec_callsite_verified=yes
pa05b_indcpa_epp_callsite_verified=yes
pa05c_indcpa_k_sequential_callsite_verified=yes
final_status=PA05_PRODUCTION_CALLSITES_VERIFIED
```

The correct interpretation is:

> Every production use of `mlk_poly_add` in the selected ML-KEM-768 revision has a successful
> call-site verification argument. The vector caller was executed directly. The two `indcpa`
> calls were verified compositionally from the documented producer guarantees and then executed
> against the production `mlk_poly_add` body.

PA-05B and PA-05C do not execute the complete `mlk_indcpa_enc` function. They verify the exact
call-site obligations using an assume-guarantee model of the relevant producer postconditions.

---

## 2. Verification Objective

PA-05 verifies that every production call context satisfies the requirements needed by
`mlk_poly_add`:

1. the accumulator and read-only operand are distinct;
2. each coefficient-wise exact sum is representable in `int16_t`;
3. the production function stores the exact sum;
4. the read-only operand remains unchanged;
5. the reached CBMC memory, pointer, arithmetic, conversion, and unwinding checks hold.

This composes the PA-02 function theorem with real production calling contexts.

---

## 3. Production Call Inventory

### Call site 1 — `poly_k.c`

```c
mlk_poly_add(&r->vec[i], &b->vec[i]);
```

This call occurs inside `mlk_polyvec_add`.

### Call site 2 — `indcpa.c`

```c
mlk_poly_add(v, epp);
```

This call occurs after inverse NTT processing of `v` and generation of `epp`.

### Call site 3 — `indcpa.c`

```c
mlk_poly_add(v, k);
```

This call immediately follows call site 2. The accumulator therefore contains `v + epp` before
the second addition.

---

## 4. Function-Level Precondition

The production implementation stores:

```c
r->coeffs[i] =
    (int16_t)(r->coeffs[i] + b->coeffs[i]);
```

Exact addition requires:

```text
INT16_MIN <= r_before[i] + b[i] <= INT16_MAX
```

PA-05 does not merely repeat this requirement. It verifies that the production call contexts
satisfy it.

---

# Part I — PA-05A: Production `mlk_polyvec_add` Caller

## 5. PA-05A Architecture

PA-05A directly calls:

```c
mlk_polyvec_add(&r, &b);
```

The production `mlk_polyvec_add` loop then directly calls production `mlk_poly_add` for every
vector component.

CBMC therefore analyses:

- the PA-05A harness;
- the real `mlk_polyvec_add` caller loop;
- every reached nested `mlk_poly_add` call;
- every reached target coefficient loop.

---

## 6. PA-05A Input Domain and Assumptions

Each coefficient of `r` and `b` is an arbitrary symbolic `int16_t`.

For every component and coefficient, the harness assumes exactly the documented caller contract:

```text
INT16_MIN <= r[j][i] + b[j][i] <= INT16_MAX
```

This is the necessary representability condition inherited from `mlk_poly_add`.

The harness also constructs `r` and `b` as separate automatic objects and asserts that the nested
component objects are distinct.

---

## 7. PA-05A Properties

### PA05A-P1 — Exact component-wise result

```text
r_after[j][i] =
r_before[j][i] + b_before[j][i]
```

for all vector components and coefficients.

### PA05A-P2 — Read-only frame

```text
b_after[j][i] = b_before[j][i]
```

### Structural obligations

PA-05A also verifies:

- ML-KEM-768 parameter binding;
- `MLKEM_K == 3`;
- vector-object separation;
- nested polynomial-object separation;
- complete vector-loop and coefficient-loop execution;
- enabled memory and arithmetic checks.

---

## 8. PA-05A Result

The campaign summary recorded:

```text
pa05a_polyvec_callsite_verified=yes
```

This establishes that the production vector caller correctly composes `mlk_poly_add` across all
three ML-KEM-768 vector components under its documented contract.

---

# Part II — PA-05B: `mlk_poly_add(v, epp)`

## 9. PA-05B Architecture

PA-05B models the relevant state immediately before:

```c
mlk_poly_add(v, epp);
```

It does not execute the complete encryption function. Instead, it assumes the documented
postconditions of the operations that produced `v` and `epp`, proves the target call precondition,
and directly executes production `mlk_poly_add`.

---

## 10. PA-05B Producer Guarantees

### Inverse NTT guarantee

```text
abs(v[i]) < MLK_INVNTT_BOUND
```

with:

```text
MLK_INVNTT_BOUND = 8 * MLKEM_Q = 26632
```

### Error-polynomial guarantee

```text
abs(epp[i]) < MLKEM_ETA2 + 1
```

For ML-KEM-768:

```text
MLKEM_ETA2 = 2
```

Therefore:

```text
epp[i] ∈ {-2, -1, 0, 1, 2}
```

---

## 11. PA-05B Call-Precondition Derivation

From the producer guarantees:

```text
-26632 < v[i] < 26632
-3 < epp[i] < 3
```

the sum is strictly inside:

```text
-26635 < v[i] + epp[i] < 26635
```

which lies safely within the signed `int16_t` range.

The harness does not assume the final safe-sum requirement. It asserts both the lower and upper
representability conditions and requires CBMC to prove them.

---

## 12. PA-05B Properties

PA-05B verifies:

1. the lower safe-sum call precondition;
2. the upper safe-sum call precondition;
3. exact production result:
   ```text
   v_after[i] = v_before[i] + epp_before[i]
   ```
4. preservation of `epp`;
5. the derived output interval;
6. modulo-`q` refinement;
7. enabled target safety checks.

---

## 13. PA-05B Result

The campaign summary recorded:

```text
pa05b_indcpa_epp_callsite_verified=yes
```

This establishes that the documented producer guarantees are sufficient for the first `indcpa`
addition call.

---

# Part III — PA-05C: Sequential `v + epp + k`

## 14. PA-05C Architecture

The source performs:

```c
mlk_poly_add(v, epp);
mlk_poly_add(v, k);
```

PA-05C executes both production target calls in this order.

The second call is checked against the cumulative state after the first call.

---

## 15. PA-05C Message-Polynomial Model

Each `k` coefficient is generated from one symbolic message bit and is therefore exactly:

```text
0
or
MLKEM_Q_HALF
```

For ML-KEM:

```text
MLKEM_Q_HALF = 1665
```

The harness verifies this image by construction rather than assuming a broad arbitrary bound.

---

## 16. PA-05C First-Call Obligation

PA-05C proves:

```text
INT16_MIN <= v_initial[i] + epp[i] <= INT16_MAX
```

from the same producer guarantees used in PA-05B.

---

## 17. PA-05C Second-Call Obligation

The cumulative sum is:

```text
v_initial[i] + epp[i] + k[i]
```

The maximum message contribution is `1665`, and the lower contribution is zero.

The harness proves:

```text
INT16_MIN <= v_initial[i] + epp[i] + k[i] <= INT16_MAX
```

without adding a safe-sum assumption for the second call.

---

## 18. PA-05C Properties

PA-05C verifies:

1. first-call representability;
2. second-call cumulative representability;
3. exact first-call result;
4. exact cumulative result:
   ```text
   v_final[i] =
   v_initial[i] + epp_before[i] + k_before[i]
   ```
5. preservation of `epp`;
6. preservation of `k`;
7. cumulative output bounds;
8. cumulative modulo-`q` refinement;
9. enabled target safety checks.

---

## 19. PA-05C Result

The campaign summary recorded:

```text
pa05c_indcpa_k_sequential_callsite_verified=yes
```

This establishes that the actual two-call sequence is safe and exact under the documented
producer guarantees and message-polynomial image.

---

## 20. CBMC Safety Configuration

All three verification units enable:

```text
bounds checking
pointer checking
pointer-overflow checking
signed-overflow checking
unsigned-overflow checking
conversion checking
division-by-zero checking
undefined-shift checking
unwinding assertions
```

Each unit is accepted only when:

- the GOTO model builds;
- text verification succeeds;
- JSON verification succeeds;
- a required explicit property marker succeeds;
- no failure line is observed.

---

## 21. What PA-05 Proves

Within ML-KEM-768, PA-05 proves:

1. the production `mlk_polyvec_add` caller correctly invokes `mlk_poly_add` for all components;
2. all nested caller sums satisfy the documented representability contract;
3. the vector caller preserves its read-only operand;
4. the producer bounds before `mlk_poly_add(v, epp)` imply safe exact addition;
5. the first `indcpa` target call computes the exact result;
6. the cumulative state before `mlk_poly_add(v, k)` remains representable;
7. every message-polynomial coefficient is modelled as `0` or `MLKEM_Q_HALF`;
8. the second target call computes the exact cumulative result;
9. both read-only polynomial operands are preserved;
10. the concrete results have the expected modulo-`q` interpretation;
11. all reached enabled safety checks succeed.

---

## 22. What PA-05 Does Not Prove

PA-05 does not prove:

1. complete functional correctness of `mlk_indcpa_enc`;
2. correctness of every producer implementation;
3. correctness of the documented producer contracts themselves;
4. end-to-end K-PKE correctness;
5. end-to-end ML-KEM correctness;
6. all allocation paths in the full encryption function;
7. ML-KEM-512 or ML-KEM-1024;
8. assembly or native-backend correctness;
9. physical constant-time behaviour;
10. future repository revisions.

PA-05B and PA-05C are compositional call-site proofs, not whole-function proofs of
`mlk_indcpa_enc`.

---

## 23. Assume-Guarantee Proof Structure

PA-05B and PA-05C use:

```text
documented producer postconditions
              ↓
asserted call-site precondition
              ↓
direct production mlk_poly_add execution
              ↓
asserted exact call-site postcondition
```

The crucial safe-sum conditions are assertions, not assumptions.

This makes the caller obligation visible and independently checked.

---

## 24. Vacuity Analysis

- The symbolic domains contain many positive, negative, canonical, and non-canonical values.
- Both message-bit values remain reachable.
- Every harness directly reaches production `mlk_poly_add`.
- PA-05A additionally reaches it through the actual production caller.
- The critical safe-sum conditions in PA-05B and PA-05C are proved assertions.
- The result is not produced by a contradictory safe-sum assumption.

---

## 25. Threats to Validity

### Producer-contract dependence

PA-05B and PA-05C depend on the documented inverse-NTT and noise-generation postconditions.

### Partial caller modelling

The complete encryption function is not executed in PA-05B or PA-05C.

### Parameter scope

The current campaign covers ML-KEM-768 only.

### Backend scope

The campaign covers the selected portable C implementation and CBMC model.

### Formal-annotation exposure

The source contracts and invariants were inspected to derive caller and producer guarantees.

---

## 26. Independent Design and Distinctness

The PA-05 suite was independently authored and contains:

- one direct production-caller harness;
- two compositional call-site harnesses;
- explicit proof of safe-sum obligations as assertions;
- sequential modelling of the two `indcpa` calls;
- independent message-bit modelling;
- intermediate and cumulative exact-result checks;
- frame properties;
- modulo-`q` refinement;
- combined campaign classification.

This is structurally different from a minimal isolated function harness.

---

## 27. Novelty and Contamination Disclosure

The repository's original `mlk_poly_add` proof harness was not used as the construction source.

The production source contracts were inspected.

The strongest accurate statement is:

> PA-05 is an independently authored production call-site verification suite generated without
> copying the repository's original `mlk_poly_add` harness, but informed by caller and producer
> contracts embedded in the production source.

The correct classification is:

```text
original-harness-blind
but source-contract-informed
```

Absolute uniqueness from every unseen repository artefact is not claimed.

---

## 28. Combined PA-01 Through PA-05 Assurance Position

| Campaign | Purpose | Result |
|---|---|---|
| PA-01 | canonical FIPS-domain correctness | Verified |
| PA-02 | complete signed contract-valid correctness | Verified |
| PA-03 | unrestricted exact-addition negative control | Expected counterexample confirmed |
| PA-04 | aliasing behaviour and boundary diagnostic | Confirmed |
| PA-05 | all production call-site obligations in ML-KEM-768 | Verified |

The combined conclusion is:

> The portable C implementation of `mlk_poly_add` has been verified over its main valid
> arithmetic domains, its invalid-domain boundary has been confirmed, its present aliasing
> behaviour has been characterised, and every production call in the selected ML-KEM-768
> revision has a successful call-site verification argument.

---

## 29. Did This Prove `mlk_poly_add` Is Really Correct?

The accurate answer is:

> Yes, within the declared CBMC properties, assumptions, source revision, portable C backend,
> ML-KEM-768 configuration, and caller models, PA-01 through PA-05 provide a strong verification
> argument that `mlk_poly_add` computes exact coefficient-wise addition correctly and that its
> production uses satisfy the required arithmetic obligations.

The inaccurate answer would be:

> `mlk_poly_add` is absolutely proved for every possible environment and every imaginable
> property.

Formal evidence remains property-specific and assumption-dependent.

---

## 30. Professor-Ready Result Statement

> PA-05 examined all three production uses of `mlk_poly_add` in the selected ML-KEM-768
> revision. PA-05A directly executed the production `mlk_polyvec_add` caller and verified exact
> component-wise addition, nested object separation, read-only-vector preservation, and enabled
> CBMC safety checks under the caller contract. PA-05B and PA-05C used compositional
> assume-guarantee harnesses derived from the documented inverse-NTT, error-polynomial, and
> message-polynomial guarantees. Their safe-sum requirements were asserted rather than assumed.
> CBMC verified the first `v + epp` call and the sequential `v + epp + k` context, including
> exact intermediate and cumulative results, frame properties, representability, and modulo-`q`
> refinement. The combined campaign completed with
> `PA05_PRODUCTION_CALLSITES_VERIFIED`.

---

## 31. Correct Next Stage

The next campaign item is:

```text
PA-06: cross-parameter replication
```

The applicable frozen experiments should be repeated for:

```text
ML-KEM-512
ML-KEM-768
ML-KEM-1024
```

---

## 32. Final Conclusion

PA-05 closes the immediate caller-obligation gap for `mlk_poly_add` in ML-KEM-768.

The final campaign status is:

```text
PA05_PRODUCTION_CALLSITES_VERIFIED
```

---

# Appendix A — Complete PA-05A Harness

```c
/*
 * PA-05A: Production caller verification for the mlk_poly_add call inside
 *         mlk_polyvec_add (mlkem/src/poly_k.c).
 *
 * Purpose:
 *   Verify that the production mlk_polyvec_add caller discharges the
 *   mlk_poly_add arithmetic and object-separation obligations for every
 *   component call, assuming exactly the documented mlk_polyvec_add input
 *   contract.
 *
 * This harness directly calls the production mlk_polyvec_add implementation,
 * which in turn directly calls the production mlk_poly_add implementation.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly_k.h"

static int16_t pa05a_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_polyvec r;
  mlk_polyvec b;
  mlk_polyvec r_before;
  mlk_polyvec b_before;

  unsigned j;
  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA05A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA05A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_K == 3,
      "PA05A_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");

  __CPROVER_assert(
      &r != &b,
      "PA05A_OBJECT_SEPARATION: caller vector objects are distinct");

  /*
   * Model exactly the documented mlk_polyvec_add input contract:
   * every component-wise mathematical sum must fit in int16_t.
   */
  for (j = 0; j < MLKEM_K; j++)
  {
    __CPROVER_assert(
        &r.vec[j] != &b.vec[j],
        "PA05A_COMPONENT_SEPARATION: each nested mlk_poly_add call uses distinct polynomials");

    for (i = 0; i < MLKEM_N; i++)
    {
      r.vec[j].coeffs[i] = pa05a_nondet_int16();
      b.vec[j].coeffs[i] = pa05a_nondet_int16();

      mathematical_sum =
          (int32_t)r.vec[j].coeffs[i] +
          (int32_t)b.vec[j].coeffs[i];

      __CPROVER_assume(
          mathematical_sum >= (int32_t)INT16_MIN);

      __CPROVER_assume(
          mathematical_sum <= (int32_t)INT16_MAX);
    }
  }

  r_before = r;
  b_before = b;

  /*
   * Execute the production caller. Its loop invokes production
   * mlk_poly_add once for every vector component.
   */
  mlk_polyvec_add(&r, &b);

  for (j = 0; j < MLKEM_K; j++)
  {
    for (i = 0; i < MLKEM_N; i++)
    {
      mathematical_sum =
          (int32_t)r_before.vec[j].coeffs[i] +
          (int32_t)b_before.vec[j].coeffs[i];

      __CPROVER_assert(
          (int32_t)r.vec[j].coeffs[i] == mathematical_sum,
          "PA05A_P1_CALLER_EXACT_SUM: every production component call computes the exact sum");

      __CPROVER_assert(
          b.vec[j].coeffs[i] == b_before.vec[j].coeffs[i],
          "PA05A_P2_CALLER_FRAME: the production caller preserves its read-only vector");
    }
  }

  return 0;
}
```

---

# Appendix B — Complete PA-05B Harness

```c
/*
 * PA-05B: Production call-site obligation for
 *         mlk_poly_add(v, epp) in mlkem/src/indcpa.c.
 *
 * Purpose:
 *   Starting only from the documented postconditions of the two producer
 *   operations immediately relevant to the call site, prove that the exact
 *   sum is representable in int16_t and that production mlk_poly_add is safe
 *   and functionally correct at this call.
 *
 * Producer guarantees modelled:
 *   mlk_poly_invntt_tomont(v):
 *       abs(v[i]) < MLK_INVNTT_BOUND = 8 * MLKEM_Q
 *
 *   mlk_enc_getnoise_eta1_eta2(..., epp, ...):
 *       abs(epp[i]) < MLKEM_ETA2 + 1
 *
 * No safe-sum assumption is made. The call-site representability condition
 * is asserted and must be derived by CBMC from the producer guarantees.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa05b_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa05b_mod_q(int32_t value)
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
  mlk_poly v;
  mlk_poly epp;
  mlk_poly v_before;
  mlk_poly epp_before;

  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA05B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA05B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA05B_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA05B_BOUND_BINDING: inverse NTT bound must equal 8*q");

  __CPROVER_assert(
      &v != &epp,
      "PA05B_OBJECT_SEPARATION: v and epp are distinct allocated objects");

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa05b_nondet_int16();
    epp.coeffs[i] = pa05b_nondet_int16();

    /*
     * Producer postcondition from mlk_poly_invntt_tomont(v).
     */
    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    /*
     * Producer postcondition from mlk_enc_getnoise_eta1_eta2(..., epp, ...).
     */
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    mathematical_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    /*
     * These are call-site proof obligations, not assumptions.
     */
    __CPROVER_assert(
        mathematical_sum >= (int32_t)INT16_MIN,
        "PA05B_P1_CALL_PRECONDITION_LOWER: v+epp is representable in int16_t");

    __CPROVER_assert(
        mathematical_sum <= (int32_t)INT16_MAX,
        "PA05B_P1_CALL_PRECONDITION_UPPER: v+epp is representable in int16_t");
  }

  v_before = v;
  epp_before = epp;

  /*
   * Execute the exact production target used at indcpa.c:571.
   */
  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)v_before.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == mathematical_sum,
        "PA05B_P2_EXACT_CALL_RESULT: indcpa v+epp call computes the exact sum");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA05B_P3_RIGHT_INPUT_FRAME: epp remains unchanged");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] >
            -(int32_t)(MLK_INVNTT_BOUND + MLKEM_ETA2),
        "PA05B_P4_DERIVED_OUTPUT_LOWER: result satisfies the derived strict lower bound");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] <
            (int32_t)(MLK_INVNTT_BOUND + MLKEM_ETA2),
        "PA05B_P4_DERIVED_OUTPUT_UPPER: result satisfies the derived strict upper bound");

    __CPROVER_assert(
        pa05b_mod_q((int32_t)v.coeffs[i]) ==
            pa05b_mod_q(mathematical_sum),
        "PA05B_P5_MOD_Q_REFINEMENT: concrete call result represents the correct residue");
  }

  return 0;
}
```

---

# Appendix C — Complete PA-05C Harness

```c
/*
 * PA-05C: Sequential production call-site obligation for
 *
 *         mlk_poly_add(v, epp);
 *         mlk_poly_add(v, k);
 *
 * in mlkem/src/indcpa.c.
 *
 * Purpose:
 *   Prove that the second call is safe in the actual sequential context,
 *   after the first call has already modified v.
 *
 * Producer guarantees modelled:
 *   abs(v_initial[i]) < MLK_INVNTT_BOUND
 *   abs(epp[i])      < MLKEM_ETA2 + 1
 *
 * Message polynomial model:
 *   each k[i] is generated from one message bit and equals either
 *   0 or MLKEM_Q_HALF.
 *
 * No safe-sum assumption is made for either production call. Both
 * representability obligations are assertions derived by CBMC.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa05c_nondet_int16(void)
{
  int16_t value;
  return value;
}

static uint8_t pa05c_nondet_uint8(void)
{
  uint8_t value;
  return value;
}

static int32_t pa05c_mod_q(int32_t value)
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
  mlk_poly v;
  mlk_poly epp;
  mlk_poly k;

  mlk_poly v_initial;
  mlk_poly epp_before;
  mlk_poly k_before;

  uint8_t message[MLKEM_N / 8];

  unsigned i;
  unsigned byte_index;
  unsigned bit_index;
  uint8_t message_bit;

  int32_t first_sum;
  int32_t cumulative_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA05C_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA05C_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_Q_HALF == 1665,
      "PA05C_PARAMETER_BINDING: MLKEM_Q_HALF must equal 1665");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA05C_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA05C_BOUND_BINDING: inverse NTT bound must equal 8*q");

  __CPROVER_assert(
      &v != &epp,
      "PA05C_OBJECT_SEPARATION: v and epp are distinct");

  __CPROVER_assert(
      &v != &k,
      "PA05C_OBJECT_SEPARATION: v and k are distinct");

  __CPROVER_assert(
      &epp != &k,
      "PA05C_OBJECT_SEPARATION: epp and k are distinct");

  for (i = 0; i < (MLKEM_N / 8); i++)
  {
    message[i] = pa05c_nondet_uint8();
  }

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa05c_nondet_int16();
    epp.coeffs[i] = pa05c_nondet_int16();

    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    /*
     * Independent model of the message-polynomial image used by the
     * production caller: one message bit maps to 0 or ceil(q/2).
     */
    byte_index = i >> 3;
    bit_index = i & 7u;
    message_bit =
        (uint8_t)((message[byte_index] >> bit_index) & (uint8_t)1);

    k.coeffs[i] =
        (message_bit == (uint8_t)0) ?
        (int16_t)0 :
        (int16_t)MLKEM_Q_HALF;

    __CPROVER_assert(
        k.coeffs[i] == 0 ||
            k.coeffs[i] == (int16_t)MLKEM_Q_HALF,
        "PA05C_MESSAGE_IMAGE: each k coefficient is 0 or MLKEM_Q_HALF");

    first_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    /*
     * First production call obligation. This is proved from producer
     * guarantees and is not assumed.
     */
    __CPROVER_assert(
        first_sum >= (int32_t)INT16_MIN,
        "PA05C_P1_FIRST_CALL_LOWER: v+epp is representable");

    __CPROVER_assert(
        first_sum <= (int32_t)INT16_MAX,
        "PA05C_P1_FIRST_CALL_UPPER: v+epp is representable");

    cumulative_sum =
        first_sum +
        (int32_t)k.coeffs[i];

    /*
     * Second production call obligation in the actual cumulative state.
     */
    __CPROVER_assert(
        cumulative_sum >= (int32_t)INT16_MIN,
        "PA05C_P2_SECOND_CALL_LOWER: (v+epp)+k is representable");

    __CPROVER_assert(
        cumulative_sum <= (int32_t)INT16_MAX,
        "PA05C_P2_SECOND_CALL_UPPER: (v+epp)+k is representable");
  }

  v_initial = v;
  epp_before = epp;
  k_before = k;

  /*
   * Execute the two production calls in their actual order.
   */
  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    first_sum =
        (int32_t)v_initial.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == first_sum,
        "PA05C_P3_FIRST_CALL_EXACT: first sequential production call is exact");
  }

  mlk_poly_add(&v, &k);

  for (i = 0; i < MLKEM_N; i++)
  {
    cumulative_sum =
        (int32_t)v_initial.coeffs[i] +
        (int32_t)epp_before.coeffs[i] +
        (int32_t)k_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == cumulative_sum,
        "PA05C_P4_CUMULATIVE_EXACT: both sequential production calls compute the cumulative sum");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA05C_P5_EPP_FRAME: epp remains unchanged");

    __CPROVER_assert(
        k.coeffs[i] == k_before.coeffs[i],
        "PA05C_P6_K_FRAME: k remains unchanged");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] >
            -(int32_t)(MLK_INVNTT_BOUND + MLKEM_ETA2),
        "PA05C_P7_CUMULATIVE_LOWER: cumulative result satisfies the strict lower bound");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] <
            (int32_t)(MLK_INVNTT_BOUND +
                      MLKEM_ETA2 +
                      MLKEM_Q_HALF),
        "PA05C_P7_CUMULATIVE_UPPER: cumulative result satisfies the strict upper bound");

    __CPROVER_assert(
        pa05c_mod_q((int32_t)v.coeffs[i]) ==
            pa05c_mod_q(cumulative_sum),
        "PA05C_P8_MOD_Q_REFINEMENT: cumulative concrete result has the correct residue");
  }

  return 0;
}
```

---

# Appendix D — Complete PA-05 Runner

```bash
#!/usr/bin/env bash
#
# PA-05 combined production call-site campaign for mlk_poly_add.
#
# PA-05A:
#   Production mlk_polyvec_add caller in poly_k.c.
#
# PA-05B:
#   First indcpa encryption call: mlk_poly_add(v, epp).
#
# PA-05C:
#   Sequential indcpa encryption calls:
#       mlk_poly_add(v, epp);
#       mlk_poly_add(v, k);
#
# Expected final status:
#   PA05_PRODUCTION_CALLSITES_VERIFIED
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa05_mlk_poly_add_production_callsites.sh
#   ./run_pa05_mlk_poly_add_production_callsites.sh 768
#

set -uo pipefail

CAMPAIGN_ID="PA-05"
CAMPAIGN_SCOPE="production_callsite_precondition_and_semantic_verification"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"

HARNESS_A="pa05a_mlk_poly_add_polyvec_production_callsite_harness.c"
HARNESS_B="pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c"
HARNESS_C="pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa05_mlk_poly_add_callsites_${PARAM_SET}_${TIMESTAMP}"

case "${PARAM_SET}" in
  768) ;;
  *)
    echo "ERROR: PA-05 is currently frozen for ML-KEM-768." >&2
    echo "Cross-parameter replication belongs to PA-06." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee grep; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] ||
   [ ! -f "mlkem/src/poly_k.c" ] ||
   [ ! -f "mlkem/src/poly.h" ] ||
   [ ! -f "mlkem/src/poly_k.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

for harness in "${HARNESS_A}" "${HARNESS_B}" "${HARNESS_C}"; do
  if [ ! -f "${harness}" ]; then
    echo "ERROR: required harness missing: ${harness}" >&2
    exit 2
  fi
done

CURRENT_COMMIT="$(git rev-parse HEAD)"
mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA05_PRODUCTION_CALLSITES_VERIFIED"
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

sha256sum "${HARNESS_A}" > "${OUT_DIR}/pa05a_harness_sha256.txt"
sha256sum "${HARNESS_B}" > "${OUT_DIR}/pa05b_harness_sha256.txt"
sha256sum "${HARNESS_C}" > "${OUT_DIR}/pa05c_harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"

cp "${HARNESS_A}" "${OUT_DIR}/"
cp "${HARNESS_B}" "${OUT_DIR}/"
cp "${HARNESS_C}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-05 target."
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

run_experiment()
{
  local label="$1"
  local harness="$2"
  local source_mode="$3"
  local marker="$4"
  local result_dir="${OUT_DIR}/${label}"
  local goto_model="${result_dir}/${label}.goto"

  local build_exit
  local text_exit
  local json_exit
  local successful="no"
  local marker_success="no"
  local failure_lines="yes"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    "${harness}"
    mlkem/src/poly.c
  )

  if [ "${source_mode}" = "poly_k_caller" ]; then
    build_command+=(mlkem/src/poly_k.c)
  fi

  build_command+=(-o "${goto_model}")

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo "===== ${label}: BUILDING GOTO MODEL ====="
  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  text_exit=-1
  json_exit=-1

  if [ "${build_exit}" -eq 0 ]; then
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
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 0 ] &&
     [ "${json_exit}" -eq 0 ] &&
     grep -q "VERIFICATION SUCCESSFUL" "${result_dir}/cbmc_output.txt"; then
    successful="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${marker}" "${result_dir}/cbmc_output.txt" | grep -q "SUCCESS"; then
    marker_success="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     ! grep -q "FAILURE" "${result_dir}/cbmc_output.txt"; then
    failure_lines="no"
  fi

  {
    echo "label=${label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_successful=${successful}"
    echo "required_marker_success=${marker_success}"
    echo "failure_lines_observed=${failure_lines}"
  } > "${result_dir}/summary.txt"

  echo
  cat "${result_dir}/summary.txt"

  if [ "${successful}" = "yes" ] &&
     [ "${marker_success}" = "yes" ] &&
     [ "${failure_lines}" = "no" ]; then
    return 0
  fi

  return 1
}

PA05A_OK="no"
PA05B_OK="no"
PA05C_OK="no"

if run_experiment \
  "pa05a_polyvec_callsite" \
  "${HARNESS_A}" \
  "poly_k_caller" \
  "PA05A_P1_CALLER_EXACT_SUM"; then
  PA05A_OK="yes"
fi

if run_experiment \
  "pa05b_indcpa_epp_callsite" \
  "${HARNESS_B}" \
  "poly_only" \
  "PA05B_P1_CALL_PRECONDITION_UPPER"; then
  PA05B_OK="yes"
fi

if run_experiment \
  "pa05c_indcpa_k_sequential_callsite" \
  "${HARNESS_C}" \
  "poly_only" \
  "PA05C_P2_SECOND_CALL_UPPER"; then
  PA05C_OK="yes"
fi

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${PA05A_OK}" = "yes" ] &&
   [ "${PA05B_OK}" = "yes" ] &&
   [ "${PA05C_OK}" = "yes" ]; then
  FINAL_STATUS="PA05_PRODUCTION_CALLSITES_VERIFIED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "pa05a_polyvec_callsite_verified=${PA05A_OK}"
  echo "pa05b_indcpa_epp_callsite_verified=${PA05B_OK}"
  echo "pa05c_indcpa_k_sequential_callsite_verified=${PA05C_OK}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-05 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA05_PRODUCTION_CALLSITES_VERIFIED" ]; then
  echo
  echo "PA-05 SCIENTIFIC OUTCOME: SUCCESS"
  echo "All three production mlk_poly_add call-site obligations were verified."
else
  echo
  echo "PA-05 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

---

# Appendix E — PA-05 Property Ledger

| ID | Property or obligation | Outcome |
|---|---|---|
| PA05A-B1 | ML-KEM-768 parameter binding | Verified |
| PA05A-D1 | vector-object separation | Verified |
| PA05A-D2 | nested component separation | Verified |
| PA05A-P1 | exact component-wise caller result | Verified |
| PA05A-P2 | read-only vector preservation | Verified |
| PA05B-G1 | inverse-NTT producer bound | Assumed from documented guarantee |
| PA05B-G2 | `epp` producer bound | Assumed from documented guarantee |
| PA05B-P1 | `v + epp` representability | Verified |
| PA05B-P2 | exact `v + epp` result | Verified |
| PA05B-P3 | `epp` frame | Verified |
| PA05B-P4 | derived output interval | Verified |
| PA05B-P5 | modulo-`q` refinement | Verified |
| PA05C-G1 | inverse-NTT producer bound | Assumed from documented guarantee |
| PA05C-G2 | `epp` producer bound | Assumed from documented guarantee |
| PA05C-M1 | message-polynomial image `{0, MLKEM_Q_HALF}` | Verified by construction |
| PA05C-P1 | first-call representability | Verified |
| PA05C-P2 | second-call cumulative representability | Verified |
| PA05C-P3 | exact first-call result | Verified |
| PA05C-P4 | exact cumulative result | Verified |
| PA05C-P5 | `epp` frame | Verified |
| PA05C-P6 | `k` frame | Verified |
| PA05C-P7 | cumulative output interval | Verified |
| PA05C-P8 | modulo-`q` refinement | Verified |
| PA05-C1 | combined campaign status | `PA05_PRODUCTION_CALLSITES_VERIFIED` |

---

# Appendix F — Terminology

**Assume-guarantee verification:** Compositional verification in which documented producer
postconditions are used as assumptions for proving a later consumer obligation.

**Call-site discharge:** Proof that a production caller satisfies a callee precondition.

**Cumulative state:** The accumulator value after preceding operations in a sequence.

**Direct caller execution:** Compiling and analysing the real production caller body.

**Modelled caller context:** Reconstructing the exact relevant state from producer guarantees
without executing the complete enclosing function.
