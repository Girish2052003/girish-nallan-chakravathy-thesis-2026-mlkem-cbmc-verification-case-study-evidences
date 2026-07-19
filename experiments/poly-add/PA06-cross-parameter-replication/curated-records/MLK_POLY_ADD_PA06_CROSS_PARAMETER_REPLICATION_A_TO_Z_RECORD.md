# PA-06: Cross-Parameter Replication Record for `mlk_poly_add`

## Complete A-to-Z Technical Documentation of the ML-KEM-512, ML-KEM-768, and ML-KEM-1024 Replication Campaign

**Target project:** `pq-code-package/mlkem-native`  
**Target function:** `mlk_poly_add`  
**Verification method:** CBMC bounded model checking  
**Campaign item:** PA-06  
**Campaign scope:** Cross-parameter replication of core function and production call-site obligations  
**Parameter sets:** ML-KEM-512, ML-KEM-768, and ML-KEM-1024  
**Verification units:** 15  
**Final campaign status:** `PA06_ALL_PARAMETER_SETS_VERIFIED`  
**Document type:** Self-contained formal technical record

---

## 1. Executive Summary

PA-06 replicated the principal successful `mlk_poly_add` verification obligations across all
three standardized ML-KEM parameter sets supported by the selected `mlkem-native` revision:

```text
ML-KEM-512
ML-KEM-768
ML-KEM-1024
```

The campaign performed five successful verification units for each parameter set:

1. the frozen PA-01 canonical FIPS-domain harness;
2. the frozen PA-02 complete signed contract-valid harness;
3. the PA-06A production `mlk_polyvec_add` caller harness;
4. the PA-06B `indcpa` `v + epp` call-site harness;
5. the PA-06C sequential `indcpa` `v + epp + k` call-site harness.

The resulting campaign consisted of:

```text
5 verification units × 3 parameter sets = 15 verification units
```

Each unit was executed in both text and JSON modes, giving:

```text
15 text-mode CBMC invocations
15 JSON-mode CBMC invocations
30 CBMC invocations in total
```

The final summary was:

```text
campaign=PA-06
scope=cross_parameter_core_and_production_callsite_replication
verification_units=15
parameter_set_512_verified=yes
parameter_set_768_verified=yes
parameter_set_1024_verified=yes
final_status=PA06_ALL_PARAMETER_SETS_VERIFIED
```

The scientific outcome was:

```text
PA-06 SCIENTIFIC OUTCOME: SUCCESS
Core function and production call-site obligations were verified
for ML-KEM-512, ML-KEM-768, and ML-KEM-1024.
```

The correct interpretation is:

> The principal valid-domain and production call-site verification obligations for the portable C
> implementation of `mlk_poly_add` were successfully replicated across all three ML-KEM parameter
> sets supported by the selected repository revision.

This is stronger than a single-configuration result. It does not, however, establish that every
possible property of `mlk_poly_add`, every backend, or the entire ML-KEM implementation has been
proved.

---

## 2. Research Purpose

The purpose of PA-06 was to answer the following question:

> Are the successful PA-01, PA-02, and PA-05 results specific to ML-KEM-768, or do the same
> verification obligations hold across ML-KEM-512, ML-KEM-768, and ML-KEM-1024?

This question matters because the three parameter sets use different vector dimensions:

```text
ML-KEM-512  → MLKEM_K = 2
ML-KEM-768  → MLKEM_K = 3
ML-KEM-1024 → MLKEM_K = 4
```

Although `MLKEM_N` and `MLKEM_Q` remain fixed, the production `mlk_polyvec_add` caller executes a
different number of nested `mlk_poly_add` calls depending on `MLKEM_K`.

PA-06 therefore verifies both parameter-invariant and parameter-sensitive aspects of the
implementation.

---

## 3. Campaign Boundary

PA-06 covers:

- the canonical FIPS coefficient domain;
- the complete signed contract-valid `int16_t` addition domain;
- production vector-caller behaviour;
- the first `indcpa` polynomial-addition call;
- the second sequential `indcpa` polynomial-addition call;
- all three ML-KEM parameter sets;
- the portable C implementation;
- the selected repository revision;
- the selected CBMC safety checks.

PA-06 does not repeat:

- PA-03 unrestricted negative control;
- PA-04B unrestricted alias negative control;
- PA-04A out-of-contract safe-aliasing diagnostic.

Those exclusions are deliberate and documented later.

---

## 4. Parameter-Set Matrix

| Parameter set | `MLKEM_K` | `MLKEM_N` | `MLKEM_Q` | Vector caller target invocations |
|---|---:|---:|---:|---:|
| ML-KEM-512 | 2 | 256 | 3329 | 2 |
| ML-KEM-768 | 3 | 256 | 3329 | 3 |
| ML-KEM-1024 | 4 | 256 | 3329 | 4 |

The arithmetic core of `mlk_poly_add` remains coefficient-wise over 256 coefficients.

The parameter-sensitive difference is primarily the number of vector components processed by
`mlk_polyvec_add`.

---

## 5. Verification-Unit Matrix

| Unit | ML-KEM-512 | ML-KEM-768 | ML-KEM-1024 |
|---|---|---|---|
| PA-01 canonical FIPS-domain proof | Verified | Verified | Verified |
| PA-02 complete signed valid-domain proof | Verified | Verified | Verified |
| PA-06A production vector caller | Verified | Verified | Verified |
| PA-06B `indcpa` `v + epp` call site | Verified | Verified | Verified |
| PA-06C sequential `v + epp + k` calls | Verified | Verified | Verified |

Total successful verification units:

```text
15 of 15
```

No property count is reported in this document because the campaign summary supplied the
verification-unit outcomes rather than the raw CBMC property listings.

---

# Part I — Frozen PA-01 Replication

## 6. PA-01 Replication Purpose

The frozen PA-01 harness verifies canonical FIPS-domain coefficient-wise addition.

The input domain is:

```text
0 <= a[i] < MLKEM_Q
0 <= b[i] < MLKEM_Q
```

For `MLKEM_Q = 3329`, the exact sum satisfies:

```text
0 <= a[i] + b[i] <= 6656
```

This lies safely within `int16_t`.

---

## 7. PA-01 Replicated Properties

Across all three parameter sets, the frozen PA-01 harness verifies:

1. exact coefficient-wise addition;
2. canonical-domain output bounds;
3. modulo-`q` refinement;
4. frame preservation;
5. commutativity;
6. additive identity;
7. object separation;
8. reached bounds, pointer, conversion, arithmetic, and unwinding checks.

Although the parameter set changes, the polynomial length and modulus remain the same.

The successful replication demonstrates that the canonical function-level result is not tied to a
single build configuration.

---

## 8. Frozen-Harness Integrity

PA-06 verifies the SHA-256 identity of the PA-01 harness before running the replication.

The runner rejects the campaign if the harness does not match the frozen expected hash.

This prevents a modified harness from being silently presented as a replication of the original
PA-01 experiment.

---

# Part II — Frozen PA-02 Replication

## 9. PA-02 Replication Purpose

The frozen PA-02 harness verifies the complete signed and non-canonical domain in which the exact
mathematical sum is representable in `int16_t`.

For every coefficient:

```text
INT16_MIN <= a[i] + b[i] <= INT16_MAX
```

The operands themselves may be arbitrary signed `int16_t` values.

---

## 10. PA-02 Replicated Properties

Across all three parameter sets, the frozen PA-02 harness verifies:

1. exact signed addition;
2. modulo-`q` congruence;
3. canonical-residue refinement;
4. input frame preservation;
5. commutativity;
6. additive identity;
7. explicit object separation;
8. reached safety and unwinding checks.

This is the strongest direct function-level exact-addition theorem in the campaign.

---

## 11. PA-02 Frozen-Harness Integrity

The runner also verifies the SHA-256 identity of the PA-02 harness.

A hash mismatch terminates the campaign.

This makes the cross-parameter result a true frozen-harness replication rather than a re-authored
or weakened experiment.

---

# Part III — PA-06A Production Vector Caller

## 12. PA-06A Purpose

PA-06A verifies the production call to `mlk_poly_add` inside:

```c
mlk_polyvec_add(&r, &b);
```

The production caller invokes:

```c
mlk_poly_add(&r->vec[j], &b->vec[j]);
```

once for each vector component.

Because `MLKEM_K` changes across parameter sets, this unit tests a genuine configuration-dependent
control-flow difference.

---

## 13. PA-06A Input Contract

Each coefficient is arbitrary signed `int16_t`, subject only to the documented
`mlk_polyvec_add` representability requirement:

```text
INT16_MIN <= r[j][i] + b[j][i] <= INT16_MAX
```

The harness constructs distinct vector objects and explicitly asserts that each nested pair of
polynomial components is distinct.

---

## 14. PA-06A Direct Production Execution

PA-06A directly compiles:

```text
production poly_k.c
production poly.c
PA-06A harness
```

The execution chain is:

```text
PA-06A harness
        ↓
production mlk_polyvec_add
        ↓
production mlk_poly_add for each vector component
```

Therefore, the vector loop and every nested polynomial-addition loop are analysed by CBMC.

---

## 15. PA-06A Properties

For every parameter set, vector component, and coefficient, PA-06A verifies:

```text
r_after[j][i] =
r_before[j][i] + b_before[j][i]
```

It also verifies:

```text
b_after[j][i] = b_before[j][i]
```

Additional structural properties include:

- correct parameter-to-`MLKEM_K` binding;
- vector-object separation;
- component-object separation;
- complete vector-loop execution;
- complete target-loop execution;
- enabled memory and arithmetic checks.

---

## 16. PA-06A Cross-Parameter Significance

The successful results mean:

- two nested target calls are correct for ML-KEM-512;
- three nested target calls are correct for ML-KEM-768;
- four nested target calls are correct for ML-KEM-1024.

The production caller proof therefore scales with the parameter-dependent vector dimension.

---

# Part IV — PA-06B `indcpa` `v + epp` Call Site

## 17. PA-06B Purpose

PA-06B replicates the compositional verification of:

```c
mlk_poly_add(v, epp);
```

for each parameter set.

The harness assumes only the documented producer guarantees:

```text
abs(v[i]) < MLK_INVNTT_BOUND
abs(epp[i]) < MLKEM_ETA2 + 1
```

The safe-sum requirement is asserted rather than assumed.

---

## 18. Parameter-Invariant Producer Bounds

For all three parameter sets:

```text
MLKEM_Q = 3329
MLK_INVNTT_BOUND = 8 * MLKEM_Q = 26632
MLKEM_ETA2 = 2
```

Therefore:

```text
-26632 < v[i] < 26632
-3 < epp[i] < 3
```

The exact sum remains safely representable in `int16_t`.

---

## 19. PA-06B Properties

For each parameter set, PA-06B verifies:

1. lower representability of `v + epp`;
2. upper representability of `v + epp`;
3. exact target result;
4. preservation of `epp`;
5. modulo-`q` refinement;
6. correct parameter binding;
7. object separation;
8. enabled target safety checks.

---

## 20. PA-06B Interpretation

The successful results demonstrate that the first direct `indcpa` call-site argument is valid
under the documented producer guarantees in all three parameter-set builds.

The proof is parameter-replicated even though its numerical bounds are shared.

---

# Part V — PA-06C Sequential `v + epp + k`

## 21. PA-06C Purpose

PA-06C verifies the actual sequential production pattern:

```c
mlk_poly_add(v, epp);
mlk_poly_add(v, k);
```

for each parameter set.

The second call is checked against the cumulative accumulator state.

---

## 22. Message-Polynomial Model

The harness derives each `k` coefficient from one symbolic message bit.

Therefore:

```text
k[i] = 0
or
k[i] = MLKEM_Q_HALF
```

with:

```text
MLKEM_Q_HALF = 1665
```

This image is shared across all three parameter sets.

---

## 23. PA-06C First-Call Obligation

The harness proves:

```text
INT16_MIN <= v_initial[i] + epp[i] <= INT16_MAX
```

from the inverse-NTT and error-polynomial producer bounds.

---

## 24. PA-06C Second-Call Obligation

The harness proves:

```text
INT16_MIN <= v_initial[i] + epp[i] + k[i] <= INT16_MAX
```

for every symbolic message bit.

The safe-sum condition is not assumed.

---

## 25. PA-06C Properties

For each parameter set, PA-06C verifies:

1. first-call representability;
2. second-call representability;
3. exact intermediate result;
4. exact cumulative result;
5. `epp` frame preservation;
6. `k` frame preservation;
7. modulo-`q` refinement;
8. object separation;
9. correct parameter binding;
10. enabled target safety checks.

---

## 26. PA-06C Cross-Parameter Interpretation

The sequential arithmetic obligations are shared across the parameter sets, but the harness is
compiled independently under each build configuration.

The successful results confirm that no parameter-set-specific preprocessing or namespacing change
breaks the two target calls.

---

# Part VI — Campaign Engineering

## 27. Repository Revision Binding

The runner checks that the repository revision equals the frozen target commit.

A mismatch causes immediate termination.

This protects the experiment from silently analysing a different implementation revision.

---

## 28. Harness Integrity Protection

The runner validates the hashes of the frozen PA-01 and PA-02 harnesses.

It also records the hashes of all PA-06 harnesses and the runner itself in the result directory.

This provides:

- frozen baseline protection;
- experiment identity;
- later reproducibility support;
- mutation detection.

---

## 29. Dual-Mode Verification

Every verification unit is run twice:

### Text mode

Used for readable property status and required-marker inspection.

### JSON mode

Used as a second machine-readable verification execution.

A unit is accepted only when both modes succeed.

---

## 30. Required-Marker Validation

The runner does not accept only a generic `VERIFICATION SUCCESSFUL` line.

For each unit, it also checks that a designated explicit campaign property is reported as
successful.

This reduces the risk that an unrelated build or wrong harness is mistakenly accepted.

---

## 31. Failure-Line Rejection

The runner rejects a unit if any `FAILURE` line appears in its text output.

The final campaign succeeds only when all 15 units meet:

```text
build success
text verification success
JSON verification success
required property marker success
no failure line
```

---

## 32. CBMC Safety Configuration

The campaign enables:

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

The coefficient-loop unwind setting is sufficient for `MLKEM_N = 256`.

---

## 33. Why PA-03 Was Not Repeated

PA-03 proves that unrestricted exact addition is false when a mathematical sum falls outside the
`int16_t` range.

That representability boundary depends on the C integer type, not on `MLKEM_K`.

Repeating the same negative-control theorem in each parameter build would add little new
information.

PA-03 remains part of the cumulative assurance case.

---

## 34. Why PA-04B Was Not Repeated

PA-04B proves that unrestricted exact doubling is false under aliasing when the doubled result
does not fit in `int16_t`.

This boundary is also parameter-invariant.

The negative-control result remains valid as a separate campaign item.

---

## 35. Why PA-04A Was Not Required

PA-04A is explicitly an out-of-contract implementation diagnostic.

PA-06 focuses on production-valid arithmetic and production call sites.

Omitting PA-04A from the production cross-parameter closure campaign avoids mixing an
out-of-contract diagnostic with the principal legal-use replication claim.

---

# Part VII — Results and Claims

## 36. Final PA-06 Result

The campaign recorded:

```text
parameter_set_512_verified=yes
parameter_set_768_verified=yes
parameter_set_1024_verified=yes
final_status=PA06_ALL_PARAMETER_SETS_VERIFIED
```

This means every one of the 15 verification units satisfied the runner's acceptance criteria.

---

## 37. What PA-06 Proves

Within the selected repository revision and portable C CBMC model, PA-06 proves that:

1. canonical FIPS-domain addition is correct in all three parameter builds;
2. complete signed contract-valid addition is correct in all three parameter builds;
3. the production `mlk_polyvec_add` caller is correct for `MLKEM_K = 2`, `3`, and `4`;
4. all nested production `mlk_poly_add` calls in the vector caller are exact;
5. the production vector caller preserves its read-only operand;
6. the `v + epp` call-site representability argument holds in all three builds;
7. the production `v + epp` target call is exact in all three builds;
8. the sequential `v + epp + k` call-site argument holds in all three builds;
9. both sequential target calls are exact in all three builds;
10. read-only operands are preserved;
11. the concrete results retain the correct modulo-`q` meaning;
12. all reached enabled CBMC safety checks succeed;
13. the result is not restricted to ML-KEM-768.

---

## 38. What PA-06 Does Not Prove

PA-06 does not prove:

1. complete correctness of all ML-KEM functions;
2. complete correctness of `mlk_indcpa_enc`;
3. correctness of all producer implementations;
4. all possible C compiler and architecture behaviours;
5. assembly or native-backend correctness;
6. physical constant-time behaviour;
7. side-channel resistance;
8. correctness of future repository revisions;
9. absence of every possible defect class;
10. every imaginable property of `mlk_poly_add`.

The evidence remains property-specific and assumption-dependent.

---

## 39. Cross-Parameter Closure Claim

The following claim is justified:

> The principal function-level and production call-site verification obligations for the portable
> C implementation of `mlk_poly_add` were successfully replicated across ML-KEM-512,
> ML-KEM-768, and ML-KEM-1024.

The following claim is not justified:

> Every aspect of `mlk_poly_add` is absolutely proved for all environments.

---

## 40. Combined PA-01 Through PA-06 Assurance Position

### PA-01

Canonical FIPS-domain correctness.

### PA-02

Complete signed contract-valid exact-addition correctness.

### PA-03

Unrestricted exact-addition boundary confirmed by expected counterexample.

### PA-04

Safe aliasing behaviour characterised and unrestricted alias boundary confirmed.

### PA-05

All production call-site obligations verified for ML-KEM-768.

### PA-06

Principal function and production call-site obligations replicated across all three parameter
sets.

The cumulative conclusion is:

> The portable C implementation of `mlk_poly_add` has been verified over its principal valid
> arithmetic domains, its invalid representability boundary has been confirmed, its current
> out-of-contract aliasing behaviour has been characterised, all production call-site obligations
> have been verified for ML-KEM-768, and the principal function-level and production call-site
> proofs have been replicated across ML-KEM-512, ML-KEM-768, and ML-KEM-1024.

This is a strong and defensible assurance statement.

---

## 41. Did PA-06 Prove `mlk_poly_add` Is Really Correct?

The accurate answer is:

> Yes, within the declared source revision, portable C backend, CBMC model, assumptions,
> parameter-set builds, and encoded properties, PA-01 through PA-06 provide strong evidence that
> `mlk_poly_add` implements exact coefficient-wise addition correctly and is used safely by the
> analysed production callers.

The qualification is essential.

Formal verification does not produce an unbounded claim about properties that were never encoded.

---

# Part VIII — Novelty, Distinctness, and Trust Boundary

## 42. Independent Harness Design

The PA-06 harnesses were independently authored for this campaign.

Their design includes:

- explicit parameter-set binding;
- direct production vector-caller execution;
- cross-parameter nested target execution;
- compositional producer-bound modelling;
- safe-sum assertions rather than safe-sum assumptions at `indcpa` call sites;
- sequential cumulative-state verification;
- symbolic message-bit modelling;
- frame properties;
- modulo-`q` refinement;
- frozen earlier-harness integrity checks;
- dual-mode verification;
- automatic 15-unit campaign classification.

This structure is substantially broader than a minimal isolated target harness.

---

## 43. Distinctness from `mlkem-native` Artefacts

The repository's original `mlk_poly_add` harness was not copied to construct the PA-06 suite.

The new campaign is distinguished by:

1. a six-stage progressive assurance structure;
2. explicit cross-parameter replication;
3. frozen-harness identity enforcement;
4. combined function-level and caller-level verification;
5. sequential call-site modelling;
6. parameter-set matrix reporting;
7. automatic whole-campaign acceptance logic.

However, repository contracts and source annotations were previously inspected.

Therefore, the honest classification is:

```text
original-harness-blind
source-contract-informed
independently authored
not guaranteed globally unique
```

---

## 44. Contamination Disclosure

The PA-06 campaign was informed by:

- production C code;
- public type and parameter definitions;
- embedded function contracts;
- embedded loop annotations;
- previously generated PA-01 through PA-05 harnesses.

It was not created in complete formal-artefact blindness.

An absolute claim that no property resembles any unseen repository proof artefact would be
unsupported.

---

## 45. Why the Suite Is Still Meaningfully Distinct

The value of the suite does not depend on claiming that every individual arithmetic assertion is
unprecedented.

Its distinct contribution is the integrated experimental architecture:

```text
valid-domain proof
+
full signed-domain proof
+
negative control
+
alias diagnostic
+
production call-site discharge
+
cross-parameter replication
```

The campaign-level structure and evidence organization are independently developed.

---

# Part IX — Validity and Reproducibility

## 46. Vacuity Analysis

The campaign reduces vacuity risk through:

- satisfiable canonical input domains;
- broad signed valid domains;
- explicit production-call reachability;
- safe-sum obligations asserted at call sites;
- symbolic message bits;
- direct production caller execution;
- required-marker checking;
- negative controls retained from PA-03 and PA-04.

---

## 47. Threats to Validity

### 47.1 Producer-contract dependence

PA-06B and PA-06C rely on documented producer postconditions.

### 47.2 Partial `indcpa` modelling

The complete `mlk_indcpa_enc` function is not executed.

### 47.3 Tool-model dependence

The result applies to CBMC's model of the selected portable C build.

### 47.4 Backend limitation

Architecture-specific native or assembly implementations are outside the campaign.

### 47.5 Property-selection limitation

Only encoded properties and enabled checks are established.

### 47.6 Revision limitation

The evidence is bound to the selected repository revision.

---

## 48. Reproducibility Command

The complete campaign is reproduced from the repository root with:

```bash
./run_pa06_mlk_poly_add_cross_parameter_campaign.sh
```

The runner creates a timestamped result directory containing:

- experiment identity;
- tool versions;
- harness copies;
- harness hashes;
- build commands;
- CBMC commands;
- text outputs;
- JSON outputs;
- per-unit summaries;
- per-parameter summaries;
- final campaign summary.

---

## 49. Professor-Ready Result Statement

> PA-06 replicated the principal `mlk_poly_add` verification obligations across all three
> supported ML-KEM parameter sets. For each of ML-KEM-512, ML-KEM-768, and ML-KEM-1024, the
> campaign re-ran the frozen PA-01 canonical-domain harness, the frozen PA-02 complete signed
> contract-valid harness, a direct production `mlk_polyvec_add` caller harness, the `indcpa`
> `v + epp` call-site harness, and the sequential `v + epp + k` call-site harness. The vector
> caller was analysed with parameter-dependent dimensions `MLKEM_K = 2`, `3`, and `4`. All
> 15 verification units completed successfully in both text and JSON modes, producing the final
> status `PA06_ALL_PARAMETER_SETS_VERIFIED`. The result demonstrates that the principal
> function-level and production call-site arguments are not specific to ML-KEM-768.

---

## 50. Correct Next Campaign Item

The next recommended campaign item is:

```text
PA-07: mutation sensitivity
```

PA-07 should introduce controlled defective variants outside the frozen production source and
demonstrate that the harness suite detects them.

The production source must remain unchanged.

---

## 51. Final Conclusion

PA-06 successfully completed the cross-parameter replication stage.

The principal function-level and production call-site verification obligations for
`mlk_poly_add` hold across:

```text
ML-KEM-512
ML-KEM-768
ML-KEM-1024
```

The final status is:

```text
PA06_ALL_PARAMETER_SETS_VERIFIED
```

---

# Appendix A — Complete PA-06A Harness

```c
/*
 * PA-06A: Cross-parameter production-caller verification for the
 *         mlk_poly_add calls inside mlk_polyvec_add.
 *
 * This harness is parameter-set neutral. It is compiled separately for:
 *   ML-KEM-512  (MLKEM_K = 2)
 *   ML-KEM-768  (MLKEM_K = 3)
 *   ML-KEM-1024 (MLKEM_K = 4)
 *
 * It directly executes production mlk_polyvec_add from poly_k.c, which
 * directly invokes production mlk_poly_add for each vector component.
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly_k.h"

static int16_t pa06a_nondet_int16(void)
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
      "PA06A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA06A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

#if MLK_CONFIG_PARAMETER_SET == 512
  __CPROVER_assert(
      MLKEM_K == 2,
      "PA06A_PARAMETER_BINDING: ML-KEM-512 must use MLKEM_K equal to 2");
#elif MLK_CONFIG_PARAMETER_SET == 768
  __CPROVER_assert(
      MLKEM_K == 3,
      "PA06A_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");
#elif MLK_CONFIG_PARAMETER_SET == 1024
  __CPROVER_assert(
      MLKEM_K == 4,
      "PA06A_PARAMETER_BINDING: ML-KEM-1024 must use MLKEM_K equal to 4");
#else
#error PA-06A requires ML-KEM-512, ML-KEM-768, or ML-KEM-1024
#endif

  __CPROVER_assert(
      &r != &b,
      "PA06A_OBJECT_SEPARATION: caller vector objects are distinct");

  /*
   * Exact documented mlk_polyvec_add input contract:
   * every nested coefficient sum must be representable in int16_t.
   */
  for (j = 0; j < MLKEM_K; j++)
  {
    __CPROVER_assert(
        &r.vec[j] != &b.vec[j],
        "PA06A_COMPONENT_SEPARATION: nested target operands are distinct");

    for (i = 0; i < MLKEM_N; i++)
    {
      r.vec[j].coeffs[i] = pa06a_nondet_int16();
      b.vec[j].coeffs[i] = pa06a_nondet_int16();

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
   * Direct production caller execution.
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
          "PA06A_P1_CROSS_PARAMETER_EXACT_SUM: every production component call computes the exact sum");

      __CPROVER_assert(
          b.vec[j].coeffs[i] == b_before.vec[j].coeffs[i],
          "PA06A_P2_CROSS_PARAMETER_FRAME: production caller preserves the read-only vector");
    }
  }

  return 0;
}
```

---

# Appendix B — Complete PA-06B Harness

```c
/*
 * PA-06B: Cross-parameter call-site verification for
 *         mlk_poly_add(v, epp) in mlk_indcpa_enc.
 *
 * Compiled separately for ML-KEM-512, ML-KEM-768, and ML-KEM-1024.
 *
 * The harness assumes only the documented producer guarantees:
 *   abs(v[i])   < MLK_INVNTT_BOUND
 *   abs(epp[i]) < MLKEM_ETA2 + 1
 *
 * The target representability condition is asserted, not assumed.
 * The production mlk_poly_add body is executed directly.
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa06b_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa06b_mod_q(int32_t value)
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
      "PA06B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA06B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA06B_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA06B_BOUND_BINDING: inverse NTT bound must equal 8*q");

#if MLK_CONFIG_PARAMETER_SET == 512
  __CPROVER_assert(
      MLKEM_K == 2,
      "PA06B_PARAMETER_BINDING: ML-KEM-512 must use MLKEM_K equal to 2");
#elif MLK_CONFIG_PARAMETER_SET == 768
  __CPROVER_assert(
      MLKEM_K == 3,
      "PA06B_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");
#elif MLK_CONFIG_PARAMETER_SET == 1024
  __CPROVER_assert(
      MLKEM_K == 4,
      "PA06B_PARAMETER_BINDING: ML-KEM-1024 must use MLKEM_K equal to 4");
#else
#error PA-06B requires ML-KEM-512, ML-KEM-768, or ML-KEM-1024
#endif

  __CPROVER_assert(
      &v != &epp,
      "PA06B_OBJECT_SEPARATION: v and epp are distinct objects");

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa06b_nondet_int16();
    epp.coeffs[i] = pa06b_nondet_int16();

    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    mathematical_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    __CPROVER_assert(
        mathematical_sum >= (int32_t)INT16_MIN,
        "PA06B_P1_CROSS_PARAMETER_CALL_LOWER: v+epp is representable");

    __CPROVER_assert(
        mathematical_sum <= (int32_t)INT16_MAX,
        "PA06B_P1_CROSS_PARAMETER_CALL_UPPER: v+epp is representable");
  }

  v_before = v;
  epp_before = epp;

  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)v_before.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == mathematical_sum,
        "PA06B_P2_CROSS_PARAMETER_EXACT_RESULT: production v+epp call is exact");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA06B_P3_CROSS_PARAMETER_FRAME: epp remains unchanged");

    __CPROVER_assert(
        pa06b_mod_q((int32_t)v.coeffs[i]) ==
            pa06b_mod_q(mathematical_sum),
        "PA06B_P4_CROSS_PARAMETER_MOD_Q: result has the correct residue");
  }

  return 0;
}
```

---

# Appendix C — Complete PA-06C Harness

```c
/*
 * PA-06C: Cross-parameter sequential call-site verification for
 *
 *         mlk_poly_add(v, epp);
 *         mlk_poly_add(v, k);
 *
 * in mlk_indcpa_enc.
 *
 * Compiled separately for ML-KEM-512, ML-KEM-768, and ML-KEM-1024.
 *
 * The safe-sum conditions for both calls are assertions derived from:
 *   abs(v_initial[i]) < MLK_INVNTT_BOUND
 *   abs(epp[i])       < MLKEM_ETA2 + 1
 *   k[i]              in {0, MLKEM_Q_HALF}
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa06c_nondet_int16(void)
{
  int16_t value;
  return value;
}

static uint8_t pa06c_nondet_uint8(void)
{
  uint8_t value;
  return value;
}

static int32_t pa06c_mod_q(int32_t value)
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
      "PA06C_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA06C_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_Q_HALF == 1665,
      "PA06C_PARAMETER_BINDING: MLKEM_Q_HALF must equal 1665");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA06C_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA06C_BOUND_BINDING: inverse NTT bound must equal 8*q");

#if MLK_CONFIG_PARAMETER_SET == 512
  __CPROVER_assert(
      MLKEM_K == 2,
      "PA06C_PARAMETER_BINDING: ML-KEM-512 must use MLKEM_K equal to 2");
#elif MLK_CONFIG_PARAMETER_SET == 768
  __CPROVER_assert(
      MLKEM_K == 3,
      "PA06C_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");
#elif MLK_CONFIG_PARAMETER_SET == 1024
  __CPROVER_assert(
      MLKEM_K == 4,
      "PA06C_PARAMETER_BINDING: ML-KEM-1024 must use MLKEM_K equal to 4");
#else
#error PA-06C requires ML-KEM-512, ML-KEM-768, or ML-KEM-1024
#endif

  __CPROVER_assert(
      &v != &epp,
      "PA06C_OBJECT_SEPARATION: v and epp are distinct");

  __CPROVER_assert(
      &v != &k,
      "PA06C_OBJECT_SEPARATION: v and k are distinct");

  __CPROVER_assert(
      &epp != &k,
      "PA06C_OBJECT_SEPARATION: epp and k are distinct");

  for (i = 0; i < (MLKEM_N / 8); i++)
  {
    message[i] = pa06c_nondet_uint8();
  }

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa06c_nondet_int16();
    epp.coeffs[i] = pa06c_nondet_int16();

    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

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
        "PA06C_MESSAGE_IMAGE: k coefficient is 0 or MLKEM_Q_HALF");

    first_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    __CPROVER_assert(
        first_sum >= (int32_t)INT16_MIN,
        "PA06C_P1_FIRST_CALL_LOWER: v+epp is representable");

    __CPROVER_assert(
        first_sum <= (int32_t)INT16_MAX,
        "PA06C_P1_FIRST_CALL_UPPER: v+epp is representable");

    cumulative_sum =
        first_sum +
        (int32_t)k.coeffs[i];

    __CPROVER_assert(
        cumulative_sum >= (int32_t)INT16_MIN,
        "PA06C_P2_SECOND_CALL_LOWER: (v+epp)+k is representable");

    __CPROVER_assert(
        cumulative_sum <= (int32_t)INT16_MAX,
        "PA06C_P2_SECOND_CALL_UPPER: (v+epp)+k is representable");
  }

  v_initial = v;
  epp_before = epp;
  k_before = k;

  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    first_sum =
        (int32_t)v_initial.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == first_sum,
        "PA06C_P3_FIRST_CALL_EXACT: first production call is exact");
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
        "PA06C_P4_CUMULATIVE_EXACT: sequential production calls compute the cumulative sum");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA06C_P5_EPP_FRAME: epp remains unchanged");

    __CPROVER_assert(
        k.coeffs[i] == k_before.coeffs[i],
        "PA06C_P6_K_FRAME: k remains unchanged");

    __CPROVER_assert(
        pa06c_mod_q((int32_t)v.coeffs[i]) ==
            pa06c_mod_q(cumulative_sum),
        "PA06C_P7_CROSS_PARAMETER_MOD_Q: cumulative result has the correct residue");
  }

  return 0;
}
```

---

# Appendix D — Complete PA-06 Runner

```bash
#!/usr/bin/env bash
#
# PA-06: Cross-parameter replication campaign for mlk_poly_add.
#
# Parameter sets:
#   ML-KEM-512
#   ML-KEM-768
#   ML-KEM-1024
#
# Five successful verification units are executed per parameter set:
#
#   1. Frozen PA-01 canonical FIPS-domain harness
#   2. Frozen PA-02 complete signed contract-valid harness
#   3. PA-06A production mlk_polyvec_add caller harness
#   4. PA-06B indcpa v+epp call-site harness
#   5. PA-06C sequential indcpa v+epp+k call-site harness
#
# Total:
#   15 verification units
#   each checked in text and JSON modes
#
# PA-03 and PA-04B negative controls are not repeated here because their
# int16_t representability counterexamples are parameter-invariant.
# PA-04A is an out-of-contract diagnostic and is not required for the
# production cross-parameter closure claim.
#
# Expected final status:
#   PA06_ALL_PARAMETER_SETS_VERIFIED
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa06_mlk_poly_add_cross_parameter_campaign.sh
#   ./run_pa06_mlk_poly_add_cross_parameter_campaign.sh
#

set -uo pipefail

CAMPAIGN_ID="PA-06"
CAMPAIGN_SCOPE="cross_parameter_core_and_production_callsite_replication"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

PA01_HARNESS="cleanroom_mlk_poly_add_fips_relational_harness_v2.c"
PA02_HARNESS="pa02_mlk_poly_add_full_signed_contract_valid_harness.c"
PA06A_HARNESS="pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c"
PA06B_HARNESS="pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c"
PA06C_HARNESS="pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c"

PA01_EXPECTED_SHA256="307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e"
PA02_EXPECTED_SHA256="e83d521e23f93c2435058598be5ef245bb02c554a4b7992dd8844418720c2ce2"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa06_mlk_poly_add_cross_parameter_${TIMESTAMP}"

for tool in git cbmc goto-cc sha256sum tee grep awk; do
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

for harness in \
  "${PA01_HARNESS}" \
  "${PA02_HARNESS}" \
  "${PA06A_HARNESS}" \
  "${PA06B_HARNESS}" \
  "${PA06C_HARNESS}"; do
  if [ ! -f "${harness}" ]; then
    echo "ERROR: required harness missing: ${harness}" >&2
    exit 2
  fi
done

CURRENT_COMMIT="$(git rev-parse HEAD)"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  echo "ERROR: repository commit mismatch." >&2
  echo "Expected: ${EXPECTED_COMMIT}" >&2
  echo "Actual:   ${CURRENT_COMMIT}" >&2
  exit 3
fi

PA01_ACTUAL_SHA256="$(sha256sum "${PA01_HARNESS}" | awk '{print $1}')"
PA02_ACTUAL_SHA256="$(sha256sum "${PA02_HARNESS}" | awk '{print $1}')"

if [ "${PA01_ACTUAL_SHA256}" != "${PA01_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-01 harness hash mismatch." >&2
  echo "Expected: ${PA01_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA01_ACTUAL_SHA256}" >&2
  exit 4
fi

if [ "${PA02_ACTUAL_SHA256}" != "${PA02_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-02 harness hash mismatch." >&2
  echo "Expected: ${PA02_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA02_ACTUAL_SHA256}" >&2
  exit 4
fi

mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA06_ALL_PARAMETER_SETS_VERIFIED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Frozen PA-01 hash: ${PA01_ACTUAL_SHA256}"
  echo "Frozen PA-02 hash: ${PA02_ACTUAL_SHA256}"
  echo "Verification units: 15"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

for harness in \
  "${PA01_HARNESS}" \
  "${PA02_HARNESS}" \
  "${PA06A_HARNESS}" \
  "${PA06B_HARNESS}" \
  "${PA06C_HARNESS}"; do
  sha256sum "${harness}" >> "${OUT_DIR}/harness_sha256.txt"
  cp "${harness}" "${OUT_DIR}/"
done

sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
cp "$0" "${OUT_DIR}/"

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

run_success_unit()
{
  local parameter_set="$1"
  local label="$2"
  local harness="$3"
  local source_mode="$4"
  local required_marker="$5"

  local result_dir="${OUT_DIR}/${parameter_set}/${label}"
  local goto_model="${result_dir}/${label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1
  local verification_successful="no"
  local marker_success="no"
  local failure_lines="yes"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${parameter_set}"
    "${harness}"
    mlkem/src/poly.c
  )

  if [ "${source_mode}" = "poly_k_caller" ]; then
    build_command+=(mlkem/src/poly_k.c)
  fi

  build_command+=(-o "${goto_model}")

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-06 ${parameter_set}: ${label}"
  echo "============================================================"
  echo "Building GOTO model..."

  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  if [ "${build_exit}" -eq 0 ]; then
    local text_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --trace
    )

    printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
    printf '\n' >> "${result_dir}/cbmc_command.txt"

    echo "Running CBMC text verification..."
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

    echo "Running CBMC JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 0 ] &&
     [ "${json_exit}" -eq 0 ] &&
     grep -q "VERIFICATION SUCCESSFUL" "${result_dir}/cbmc_output.txt"; then
    verification_successful="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${required_marker}" "${result_dir}/cbmc_output.txt" | \
       grep -q "SUCCESS"; then
    marker_success="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     ! grep -q "FAILURE" "${result_dir}/cbmc_output.txt"; then
    failure_lines="no"
  fi

  {
    echo "parameter_set=${parameter_set}"
    echo "label=${label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_successful=${verification_successful}"
    echo "required_marker_success=${marker_success}"
    echo "failure_lines_observed=${failure_lines}"
  } > "${result_dir}/summary.txt"

  cat "${result_dir}/summary.txt"

  if [ "${verification_successful}" = "yes" ] &&
     [ "${marker_success}" = "yes" ] &&
     [ "${failure_lines}" = "no" ]; then
    return 0
  fi

  return 1
}

ALL_OK="yes"

for PARAM in 512 768 1024; do
  PARAM_OK="yes"

  if ! run_success_unit \
    "${PARAM}" \
    "pa01_canonical_fips" \
    "${PA01_HARNESS}" \
    "poly_only" \
    "P1_EXACT_SUM"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa02_full_signed_valid" \
    "${PA02_HARNESS}" \
    "poly_only" \
    "PA02_P1_EXACT_SIGNED_SUM"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa06a_polyvec_production_caller" \
    "${PA06A_HARNESS}" \
    "poly_k_caller" \
    "PA06A_P1_CROSS_PARAMETER_EXACT_SUM"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa06b_indcpa_epp_callsite" \
    "${PA06B_HARNESS}" \
    "poly_only" \
    "PA06B_P1_CROSS_PARAMETER_CALL_UPPER"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa06c_indcpa_sequential_callsite" \
    "${PA06C_HARNESS}" \
    "poly_only" \
    "PA06C_P2_SECOND_CALL_UPPER"; then
    PARAM_OK="no"
  fi

  echo "parameter_set_${PARAM}_verified=${PARAM_OK}" \
    >> "${OUT_DIR}/parameter_status.txt"

  if [ "${PARAM_OK}" != "yes" ]; then
    ALL_OK="no"
  fi
done

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${ALL_OK}" = "yes" ]; then
  FINAL_STATUS="PA06_ALL_PARAMETER_SETS_VERIFIED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "verification_units=15"
  cat "${OUT_DIR}/parameter_status.txt"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-06 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA06_ALL_PARAMETER_SETS_VERIFIED" ]; then
  echo
  echo "PA-06 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Core function and production call-site obligations were verified"
  echo "for ML-KEM-512, ML-KEM-768, and ML-KEM-1024."
else
  echo
  echo "PA-06 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

---

# Appendix E — PA-06 Property Ledger

| ID | Property or obligation | 512 | 768 | 1024 |
|---|---|---|---|---|
| PA01 | canonical FIPS-domain proof | Verified | Verified | Verified |
| PA02 | complete signed contract-valid proof | Verified | Verified | Verified |
| PA06A-B1 | correct parameter binding | Verified | Verified | Verified |
| PA06A-D1 | vector-object separation | Verified | Verified | Verified |
| PA06A-D2 | nested component separation | Verified | Verified | Verified |
| PA06A-P1 | exact vector-caller result | Verified | Verified | Verified |
| PA06A-P2 | vector read-only frame | Verified | Verified | Verified |
| PA06B-G1 | inverse-NTT producer bound | Modelled | Modelled | Modelled |
| PA06B-G2 | `epp` producer bound | Modelled | Modelled | Modelled |
| PA06B-P1 | `v + epp` representability | Verified | Verified | Verified |
| PA06B-P2 | exact `v + epp` result | Verified | Verified | Verified |
| PA06B-P3 | `epp` frame | Verified | Verified | Verified |
| PA06B-P4 | modulo-`q` refinement | Verified | Verified | Verified |
| PA06C-M1 | message image `{0, MLKEM_Q_HALF}` | Verified | Verified | Verified |
| PA06C-P1 | first-call representability | Verified | Verified | Verified |
| PA06C-P2 | second-call representability | Verified | Verified | Verified |
| PA06C-P3 | exact first-call result | Verified | Verified | Verified |
| PA06C-P4 | exact cumulative result | Verified | Verified | Verified |
| PA06C-P5 | `epp` frame | Verified | Verified | Verified |
| PA06C-P6 | `k` frame | Verified | Verified | Verified |
| PA06C-P7 | cumulative modulo-`q` refinement | Verified | Verified | Verified |
| PA06-C1 | final parameter status | Yes | Yes | Yes |

---

# Appendix F — Combined PA-01 Through PA-06 Summary

| Campaign | Main purpose | Result |
|---|---|---|
| PA-01 | canonical FIPS-domain correctness | Verified |
| PA-02 | complete signed contract-valid correctness | Verified |
| PA-03 | unrestricted exact-addition negative control | Expected counterexample confirmed |
| PA-04 | aliasing diagnostic and boundary | Confirmed |
| PA-05 | ML-KEM-768 production call-site verification | Verified |
| PA-06 | all-parameter replication | Verified |

---

# Appendix G — Terminology

**Cross-parameter replication:** Re-execution of equivalent verification obligations under each
supported parameter-set build.

**Frozen harness:** A harness whose identity is protected by a recorded cryptographic hash.

**Parameter-sensitive caller:** A production caller whose loop count or object shape changes with
the selected parameter set.

**Verification unit:** One harness, one parameter build, and its complete CBMC acceptance checks.

**Campaign closure:** Successful completion of every planned verification unit in a campaign
stage.
