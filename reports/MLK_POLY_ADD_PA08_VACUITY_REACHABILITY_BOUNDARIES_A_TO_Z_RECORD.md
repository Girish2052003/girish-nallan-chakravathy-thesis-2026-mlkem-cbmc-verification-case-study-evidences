# PA-08: Vacuity, Reachability, Loop-Endpoint, and Boundary-Hardening Record for `mlk_poly_add`

## Complete A-to-Z Technical Documentation of the Anti-Vacuity and Exact-Boundary Campaign

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Target project:** `pq-code-package/mlkem-native`  
**Target function:** `mlk_poly_add`  
**Verification method:** CBMC bounded model checking  
**Campaign item:** PA-08  
**Campaign scope:** Vacuity, reachability, loop-endpoint, and arithmetic-boundary hardening  
**Parameter set:** ML-KEM-768  
**Final campaign status:** `PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED`  
**Document type:** Self-contained formal technical record

---

## 1. Executive Summary

PA-08 hardens the previously established `mlk_poly_add` verification argument against four
important examiner-level concerns:

1. whether the assumptions are satisfiable;
2. whether the production target is actually reached;
3. whether the target returns and the post-target state is reachable;
4. whether the exact legal and illegal arithmetic boundaries are covered.

The campaign contains four coordinated verification units.

### PA-08A — Successful legal-boundary and endpoint proof

PA-08A directly executes the production `mlk_poly_add` implementation and proves:

- canonical lower boundary `0 + 0 = 0`;
- canonical upper boundary `(q - 1) + (q - 1) = 2q - 2`;
- signed lower boundary `INT16_MIN`;
- signed upper boundary `INT16_MAX`;
- split-operand witnesses for both signed endpoints;
- exact processing of coefficient `0`;
- exact processing of coefficient `MLKEM_N - 1`;
- target-call completion;
- exact functional results;
- right-input frame preservation;
- modulo-`q` refinement;
- enabled memory, pointer, conversion, arithmetic, and unwinding properties.

PA-08A was verified successfully.

### PA-08B — Reachability sentinels

PA-08B deliberately places false assertions after two production target calls:

- one under the canonical domain;
- one under the complete signed-valid domain.

Both sentinels failed as expected.

This demonstrates that:

- the canonical assumptions admit at least one execution;
- the signed-valid assumptions admit at least one execution;
- the production target is reached;
- the production target returns;
- execution reaches the post-target program point.

Only the expected sentinel failures were observed.

### PA-08C — Positive just-outside boundary

PA-08C checks:

```text
INT16_MAX + 1 = 32768
```

The exact-result property and target conversion check failed as expected.

This confirms that `INT16_MAX` is the exact legal upper boundary.

### PA-08D — Negative just-outside boundary

PA-08D checks:

```text
INT16_MIN - 1 = -32769
```

The exact-result property and target conversion check failed as expected.

This confirms that `INT16_MIN` is the exact legal lower boundary.

The final campaign summary was:

```text
campaign=PA-08
scope=vacuity_reachability_loop_endpoint_and_boundary_hardening
parameter_set=768
production_source_modified=no
pa08a_boundary_and_endpoint_proof_verified=yes
pa08b_canonical_path_reachable=yes
pa08b_signed_valid_path_reachable=yes
pa08b_only_expected_sentinel_failures=yes
pa08c_positive_just_outside_boundary_confirmed=yes
pa08d_negative_just_outside_boundary_confirmed=yes
final_status=PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED
```

The correct scientific conclusion is:

> The principal valid-domain assumptions used for `mlk_poly_add` are satisfiable and reach the
> production target; the target returns; both loop endpoints are exercised; the exact legal
> arithmetic endpoints are verified; and the nearest out-of-range values are rejected as
> expected.

---

## 2. Research Purpose

PA-08 addresses a known weakness in formal-verification experiments: a successful proof can be
misleading if its assumptions are contradictory or if the target code is never reached.

The PA-08 research question is:

> Can the campaign demonstrate, with explicit solver evidence, that its important assumptions are
> satisfiable, the production target is reached and returns, both array endpoints are processed,
> and the exact legal and illegal arithmetic boundaries are distinguished?

The campaign therefore adds explicit anti-vacuity and boundary evidence to the earlier functional
proofs.

---

## 3. Target Function

The production target performs coefficient-wise destructive addition:

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

The important semantic boundary is:

```text
INT16_MIN <= r_before[i] + b[i] <= INT16_MAX
```

The important loop boundary is:

```text
0 <= i < MLKEM_N
```

For ML-KEM:

```text
MLKEM_N = 256
MLKEM_Q = 3329
```

---

# Part I — PA-08A Legal-Boundary and Endpoint Proof

## 4. PA-08A Purpose

PA-08A is a successful proof harness.

It combines symbolic domains with concrete boundary witnesses so that the proof demonstrates both
universal correctness within the admitted domain and exact execution of critical endpoints.

---

## 5. Canonical-Domain Construction

For most coefficients, PA-08A uses symbolic values satisfying:

```text
0 <= r[i] < MLKEM_Q
0 <= b[i] < MLKEM_Q
```

Two coefficients are fixed as concrete boundary witnesses.

### Coefficient 0

```text
r[0] = 0
b[0] = 0
```

Expected sum:

```text
0
```

### Final coefficient

```text
r[MLKEM_N - 1] = MLKEM_Q - 1
b[MLKEM_N - 1] = MLKEM_Q - 1
```

Expected sum:

```text
2 * MLKEM_Q - 2 = 6656
```

This proves that the first and last coefficient positions are both included in the target loop.

---

## 6. Signed-Valid Domain Construction

For most coefficients, PA-08A uses arbitrary signed `int16_t` operands subject to exact-sum
representability.

Four concrete witnesses are inserted.

### Direct lower endpoint

```text
INT16_MIN + 0 = INT16_MIN
```

### Split lower endpoint

```text
-16384 + -16384 = INT16_MIN
```

### Split upper endpoint

```text
16384 + 16383 = INT16_MAX
```

### Direct upper endpoint

```text
INT16_MAX + 0 = INT16_MAX
```

These witnesses show that both signed endpoints are genuinely included in the valid domain.

---

## 7. Why Both Direct and Split Witnesses Matter

A direct endpoint witness could be dismissed as trivial identity addition.

The split witnesses show that the implementation also reaches the same endpoints through
nontrivial addition:

```text
-16384 + -16384 = -32768
16384 + 16383 = 32767
```

Therefore, the legal endpoint proof is not limited to adding zero.

---

## 8. Target-Completion Markers

Before each target call, a completion variable is set to zero.

After the production target returns, it is set to one.

The harness then asserts:

```text
canonical_target_completed == 1
signed_target_completed == 1
```

These properties confirm normal return from both target calls in the successful proof model.

---

## 9. PA-08A Canonical Properties

PA-08A proves:

1. exact coefficient-wise canonical addition;
2. preservation of the canonical right operand;
3. modulo-`q` refinement;
4. exact lower canonical boundary;
5. exact upper canonical boundary;
6. target-call completion;
7. first-coefficient processing;
8. final-coefficient processing.

---

## 10. PA-08A Signed Properties

PA-08A proves:

1. exact coefficient-wise signed-valid addition;
2. preservation of the signed right operand;
3. modulo-`q` refinement;
4. direct `INT16_MIN` reachability;
5. split `INT16_MIN` reachability;
6. split `INT16_MAX` reachability;
7. direct `INT16_MAX` reachability;
8. target-call completion.

---

## 11. PA-08A Result

The campaign summary recorded:

```text
pa08a_boundary_and_endpoint_proof_verified=yes
```

This means the successful legal-boundary harness satisfied the runner's required conditions:

- GOTO build success;
- text verification success;
- JSON verification success;
- generic verification success;
- no failure lines;
- success of required boundary markers;
- success of required target-completion markers.

---

# Part II — PA-08B Reachability Sentinels

## 12. PA-08B Purpose

PA-08B is an expected-failure anti-vacuity experiment.

It verifies path reachability by placing deliberately false assertions after production target
calls.

The key principle is:

```text
if a false assertion after the target fails,
then an execution reached that assertion
```

Therefore, the preceding assumptions were satisfiable and the target call returned.

---

## 13. Canonical Reachability Sentinel

PA-08B creates symbolic canonical-domain operands and executes:

```c
mlk_poly_add(&canonical_r, &canonical_b);
```

Immediately afterward, it asserts false:

```c
__CPROVER_assert(
    0,
    "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET");
```

The expected failure proves that at least one canonical-domain execution reaches this post-target
point.

---

## 14. Signed-Valid Reachability Sentinel

PA-08B separately creates arbitrary signed operands whose exact sums fit in `int16_t`.

It executes:

```c
mlk_poly_add(&signed_r, &signed_b);
```

Immediately afterward, it asserts false:

```c
__CPROVER_assert(
    0,
    "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET");
```

The expected failure proves that at least one signed-valid execution reaches this post-target
point.

---

## 15. Why Sentinel Failure Is Useful

Suppose the assumptions were contradictory.

Then no execution would reach the target call or the false assertion.

CBMC would not report the sentinel as failing.

The observed sentinel failures therefore provide explicit satisfiability and reachability
evidence.

---

## 16. Expected-Failure Classification

PA-08B is accepted only when:

- the GOTO model builds;
- text CBMC returns the expected verification-failure status;
- JSON CBMC returns the expected verification-failure status;
- the canonical sentinel fails;
- the signed-valid sentinel fails;
- no missing-body failure appears;
- no unexpected failure appears.

The campaign summary recorded:

```text
pa08b_canonical_path_reachable=yes
pa08b_signed_valid_path_reachable=yes
pa08b_only_expected_sentinel_failures=yes
```

---

## 17. What PA-08B Proves

PA-08B proves the existence of at least one execution in each domain that:

1. satisfies all assumptions;
2. reaches production `mlk_poly_add`;
3. returns from production `mlk_poly_add`;
4. reaches the post-target sentinel.

It does not replace the universal correctness proofs.

It supplies anti-vacuity evidence for them.

---

# Part III — PA-08C Positive Just-Outside Boundary

## 18. PA-08C Purpose

PA-08C checks the nearest value above the legal signed output range:

```text
INT16_MAX + 1
```

For 16-bit signed integers:

```text
32767 + 1 = 32768
```

The exact mathematical result cannot be represented in `int16_t`.

---

## 19. PA-08C Construction

The harness sets all coefficients to zero except coefficient `0`:

```text
r[0] = INT16_MAX
b[0] = 1
```

It executes production `mlk_poly_add`.

It then asserts that the stored coefficient equals the independent `int32_t` mathematical sum.

---

## 20. PA-08C Expected Failures

The expected evidence is:

1. failure of the exact-result assertion;
2. failure of the target signed-conversion check;
3. absence of missing-body failure;
4. absence of unrelated unexpected failures.

The campaign summary recorded:

```text
pa08c_positive_just_outside_boundary_confirmed=yes
```

---

## 21. Scientific Meaning of PA-08C

PA-08C confirms:

```text
INT16_MAX is legal
INT16_MAX + 1 is not legal
```

Therefore, the upper boundary in PA-02 and PA-08A is exact rather than conservative.

---

# Part IV — PA-08D Negative Just-Outside Boundary

## 22. PA-08D Purpose

PA-08D checks the nearest value below the legal signed output range:

```text
INT16_MIN - 1
```

For 16-bit signed integers:

```text
-32768 - 1 = -32769
```

The exact mathematical result cannot be represented in `int16_t`.

---

## 23. PA-08D Construction

The harness sets all coefficients to zero except the final coefficient:

```text
r[MLKEM_N - 1] = INT16_MIN
b[MLKEM_N - 1] = -1
```

It executes production `mlk_poly_add`.

It then checks the independent exact mathematical sum.

---

## 24. PA-08D Expected Failures

The expected evidence is:

1. failure of the exact-result assertion;
2. failure of the target signed-conversion check;
3. absence of missing-body failure;
4. absence of unrelated unexpected failures.

The campaign summary recorded:

```text
pa08d_negative_just_outside_boundary_confirmed=yes
```

---

## 25. Scientific Meaning of PA-08D

PA-08D confirms:

```text
INT16_MIN is legal
INT16_MIN - 1 is not legal
```

Therefore, the lower boundary in PA-02 and PA-08A is exact.

---

# Part V — Boundary Matrix

## 26. Exact Arithmetic Boundary Matrix

| Boundary class | Witness | Expected result | PA-08 result |
|---|---|---|---|
| canonical lower | `0 + 0` | `0` | Verified |
| canonical upper | `3328 + 3328` | `6656` | Verified |
| signed lower direct | `-32768 + 0` | `-32768` | Verified |
| signed lower split | `-16384 + -16384` | `-32768` | Verified |
| signed upper split | `16384 + 16383` | `32767` | Verified |
| signed upper direct | `32767 + 0` | `32767` | Verified |
| just below lower | `-32768 + -1` | `-32769` | Rejected as expected |
| just above upper | `32767 + 1` | `32768` | Rejected as expected |

This matrix shows both inclusion and exclusion:

```text
legal endpoints included
nearest illegal endpoints excluded
```

---

## 27. Loop-Endpoint Matrix

| Coefficient position | PA-08 witness | Purpose | Result |
|---|---|---|---|
| `0` | canonical lower and signed minimum | first loop element | Verified |
| `1` | split signed minimum | early interior element | Verified |
| `MLKEM_N - 2` | split signed maximum | late interior element | Verified |
| `MLKEM_N - 1` | canonical upper and signed maximum | final loop element | Verified |

This complements PA-07's mutation detection of skipped first and last coefficients.

---

# Part VI — Anti-Vacuity Interpretation

## 28. Meaning of Vacuous Success

A verification result is vacuous when the asserted property succeeds because no execution
satisfies the assumptions or reaches the property.

Example:

```text
assume(x > 10)
assume(x < 0)
assert(target_property)
```

The assertion may appear successful because the assumptions are contradictory.

PA-08B is specifically designed to exclude this concern for the principal `mlk_poly_add` domains.

---

## 29. Why PA-08A Alone Is Not Sufficient Anti-Vacuity Evidence

PA-08A includes concrete boundary witnesses and successful completion markers, which strongly
support non-vacuity.

However, a separate expected-failure sentinel provides a more direct solver-visible reachability
test.

PA-08B therefore strengthens the argument independently.

---

## 30. Combined Anti-Vacuity Argument

The anti-vacuity case is layered:

1. PA-08A contains concrete legal witnesses;
2. PA-08A verifies target completion;
3. PA-08B fails a false assertion after the canonical target call;
4. PA-08B fails a false assertion after the signed-valid target call;
5. only those expected sentinel failures are observed;
6. PA-07 previously detected omitted-loop and wrong-operation mutants.

Together, these observations strongly reduce the risk of vacuous or unreachable proof success.

---

# Part VII — CBMC Execution and Acceptance

## 31. Shared CBMC Checks

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

The unwind value is sufficient for the 256-coefficient loop.

---

## 32. PA-08A Acceptance Conditions

PA-08A is accepted only when:

- build succeeds;
- text verification succeeds;
- JSON verification succeeds;
- `VERIFICATION SUCCESSFUL` appears;
- no failure line appears;
- all required legal-boundary markers succeed;
- both target-completion markers succeed.

---

## 33. PA-08B Acceptance Conditions

PA-08B is accepted only when:

- build succeeds;
- text CBMC returns expected failure status;
- JSON CBMC returns expected failure status;
- `VERIFICATION FAILED` appears;
- both sentinels fail;
- no missing-body failure appears;
- no unexpected failure appears.

---

## 34. PA-08C and PA-08D Acceptance Conditions

Each nearest-outside-boundary unit is accepted only when:

- build succeeds;
- text CBMC returns expected failure status;
- JSON CBMC returns expected failure status;
- `VERIFICATION FAILED` appears;
- the intended exact-result assertion fails;
- a target signed-conversion failure is observed;
- no missing-body failure appears;
- no unexpected failure appears.

---

## 35. Production-Source Integrity

The runner checks:

- the frozen repository commit;
- the hash of production `mlkem/src/poly.c`;
- absence of tracked modifications to `poly.c`.

The summary recorded:

```text
production_source_modified=no
```

No mutation or instrumentation was applied to the production source.

---

# Part VIII — What PA-08 Establishes

## 36. Positive Findings

PA-08 establishes that:

1. the canonical assumptions are satisfiable;
2. the complete signed-valid assumptions are satisfiable;
3. the production target is reached under both domains;
4. the production target returns under both domains;
5. the post-target program points are reachable;
6. coefficient `0` is processed;
7. coefficient `MLKEM_N - 1` is processed;
8. canonical lower and upper arithmetic boundaries are exact;
9. signed `INT16_MIN` and `INT16_MAX` are legal exact results;
10. both endpoints are reachable through nontrivial split operands;
11. `INT16_MAX + 1` is rejected;
12. `INT16_MIN - 1` is rejected;
13. target conversion checks identify the nearest invalid values;
14. right-input frame properties hold at the legal boundaries;
15. modulo-`q` refinement holds at the legal boundaries;
16. only expected failures occur in the negative units;
17. production source remains unchanged.

---

## 37. What PA-08 Does Not Establish

PA-08 does not prove:

1. every possible assumption set is satisfiable;
2. every possible program path in `poly.c` is reachable;
3. every function in `poly.c` is verified;
4. complete correctness of the ML-KEM implementation;
5. all possible integer representations or architectures;
6. assembly or native-backend behaviour;
7. physical constant-time behaviour;
8. every possible overflow boundary in unrelated functions;
9. correctness of future source revisions;
10. every imaginable property of `mlk_poly_add`.

The results remain target-specific and property-specific.

---

# Part IX — Threats to Validity

## 38. Sentinel Interpretation

A failing false assertion proves existence of a reaching execution.

It does not prove that every input reaches the sentinel.

Universal correctness is supplied by the successful harnesses, not by the sentinel alone.

---

## 39. Boundary Selection

PA-08 focuses on the exact `int16_t` storage boundary and canonical ML-KEM input boundary.

Other representation conventions require separate experiments.

---

## 40. Parameter Scope

PA-08 runs under ML-KEM-768.

PA-06 separately established cross-parameter replication of the principal function and caller
proofs.

The arithmetic endpoints tested in PA-08 are parameter-invariant for the supported builds.

---

## 41. Tool-Model Scope

The result applies to CBMC's model of the selected portable C configuration.

Compiler-specific, native, and assembly behaviour are outside the present scope.

---

## 42. Property-Selection Scope

The campaign verifies the encoded functional, frame, boundary, reachability, and safety
properties.

Unencoded properties are not established.

---

# Part X — Independent Design, Distinctness, and Novelty

## 43. Independent PA-08 Design

PA-08 was independently authored with the following distinctive structure:

- one successful legal-boundary proof;
- one dual-domain reachability-sentinel experiment;
- two nearest-invalid-boundary negative controls;
- direct and split signed-endpoint witnesses;
- first- and last-coefficient witnesses;
- target-completion markers;
- exact-result and frame properties;
- modulo-`q` refinement;
- strict expected-failure classification;
- production-source hash protection;
- automatic campaign closure.

This structure is not equivalent to a minimal function contract harness.

---

## 44. Distinctness from `mlkem-native`

The PA-08 harnesses and runner are new external experimental artefacts.

They do not modify production source.

Their distinguishing features include:

1. explicit post-target false reachability sentinels;
2. paired legal and just-illegal boundary witnesses;
3. direct and split endpoint construction;
4. explicit loop-endpoint coverage;
5. campaign-level classification of expected failures;
6. integration with the progressive PA-01 through PA-08 assurance architecture.

---

## 45. Honest Novelty Statement

The strongest accurate novelty statement is:

> PA-08 is an independently authored anti-vacuity and exact-boundary campaign that combines
> successful legal-endpoint verification, post-target reachability sentinels, and nearest-invalid
> boundary controls for the production `mlk_poly_add` implementation.

Absolute global uniqueness is not claimed.

---

## 46. Formal-Artefact Exposure Disclosure

The cumulative campaign was informed by:

- production C source;
- public type and parameter definitions;
- embedded contracts and loop annotations;
- earlier PA-01 through PA-07 artefacts.

The correct classification remains:

```text
original-harness-blind
source-contract-informed
independently authored
not fully formal-artefact-blind
```

---

# Part XI — Combined PA-01 Through PA-08 Assurance

## 47. Campaign Progression

### PA-01

Canonical FIPS-domain correctness.

### PA-02

Complete signed contract-valid exact-addition correctness.

### PA-03

Unrestricted exact-addition boundary confirmed by expected counterexample.

### PA-04

Safe aliasing behaviour characterised and unrestricted alias boundary confirmed.

### PA-05

Production call-site obligations verified for ML-KEM-768.

### PA-06

Principal function and production call-site proofs replicated across all three parameter sets.

### PA-07

Both frozen principal harnesses accepted production and rejected all five controlled mutants.

### PA-08

Assumption satisfiability, target reachability, target return, loop endpoints, exact legal
boundaries, and nearest illegal boundaries confirmed.

---

## 48. Combined Assurance Statement

The cumulative evidence supports the following statement:

> For the selected `mlkem-native` revision and portable C CBMC model, `mlk_poly_add` has been
> verified over its canonical and complete signed contract-valid domains; its invalid
> representability boundary has been confirmed; its current safe aliasing behaviour has been
> characterised as an out-of-contract diagnostic; its production call-site obligations have been
> verified; the principal proofs have been replicated across all supported ML-KEM parameter sets;
> the principal frozen harnesses have demonstrated mutation sensitivity; and the proof assumptions,
> target reachability, loop endpoints, and exact arithmetic boundaries have been explicitly
> hardened against vacuity concerns.

This is a strong, layered, and defensible C-level assurance argument.

---

## 49. Did PA-08 Prove `mlk_poly_add` Is Really Correct?

The accurate answer is:

> PA-08 does not independently replace the earlier correctness proofs. It strengthens them by
> confirming that their principal domains are satisfiable, their target paths are reachable, their
> legal endpoints are exact, and their nearest invalid endpoints are rejected. Together with
> PA-01 through PA-07, the campaign provides strong formal evidence that `mlk_poly_add` is correct
> within the declared source, model, assumptions, and encoded properties.

The inaccurate answer would be:

> PA-08 proves every possible property of `mlk_poly_add` without qualification.

---

# Part XII — Reproducibility

## 50. Reproduction Command

From the frozen repository root:

```bash
./run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh
```

The runner records:

- repository identity;
- production source hash;
- Git status;
- harness hashes;
- runner hash;
- tool versions;
- build commands;
- text CBMC outputs;
- JSON CBMC outputs;
- per-unit summaries;
- final campaign summary.

---

## 51. Professor-Ready Result Statement

> PA-08 hardened the `mlk_poly_add` verification argument against vacuity, reachability, and
> boundary-coverage concerns. PA-08A directly executed the production target and verified the
> canonical lower and upper boundaries, the exact signed `INT16_MIN` and `INT16_MAX` boundaries,
> split-operand endpoint witnesses, coefficient `0`, coefficient `MLKEM_N - 1`, target completion,
> exact results, frame preservation, and modulo-`q` refinement. PA-08B placed deliberate false
> assertions after canonical and signed-valid target calls; both failed as expected, demonstrating
> satisfiable assumptions and post-target reachability with no unexpected failures. PA-08C and
> PA-08D confirmed that `INT16_MAX + 1` and `INT16_MIN - 1` are rejected through exact-result and
> conversion failures. The combined campaign completed with
> `PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED`, while production source remained unchanged.

---

## 52. Correct Next Campaign Item

The next campaign item is:

```text
PA-09: strict novelty and provenance audit
```

PA-09 should freeze the independently generated artefacts, compare them against the repository's
original verification artefacts after the design freeze, document overlap and divergence, and
produce a defensible provenance statement without claiming absolute uniqueness.

---

## 53. Final Conclusion

PA-08 completed successfully.

The campaign established:

```text
canonical assumptions are satisfiable
signed-valid assumptions are satisfiable
production target is reached
production target returns
coefficient 0 is processed
coefficient 255 is processed
legal canonical endpoints are verified
INT16_MIN is verified
INT16_MAX is verified
INT16_MIN-1 is rejected
INT16_MAX+1 is rejected
only expected negative-control failures occur
production source remains unchanged
```

The final status is:

```text
PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED
```

---

# Appendix A — Complete PA-08A Harness

```c
/*
 * PA-08A: Boundary, loop-endpoint, and target-completion hardening for
 *         the production mlk_poly_add implementation.
 *
 * This successful proof harness combines:
 *
 *   1. canonical-domain lower and upper arithmetic boundaries;
 *   2. complete signed-valid INT16_MIN and INT16_MAX boundaries;
 *   3. split-operand witnesses for both signed endpoints;
 *   4. explicit coefficient 0 and coefficient MLKEM_N-1 checks;
 *   5. target-call completion markers;
 *   6. exact-result and read-only-frame verification.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa08a_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa08a_mod_q(int32_t value)
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
  mlk_poly canonical_r;
  mlk_poly canonical_b;
  mlk_poly canonical_r_before;
  mlk_poly canonical_b_before;

  mlk_poly signed_r;
  mlk_poly signed_b;
  mlk_poly signed_r_before;
  mlk_poly signed_b_before;

  unsigned i;
  int32_t mathematical_sum;

  int canonical_target_completed;
  int signed_target_completed;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA08A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA08A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA08A_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA08A_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  __CPROVER_assert(
      &canonical_r != &canonical_b,
      "PA08A_DISJOINTNESS: canonical operands are distinct");

  __CPROVER_assert(
      &signed_r != &signed_b,
      "PA08A_DISJOINTNESS: signed operands are distinct");

  /*
   * Canonical symbolic domain with concrete endpoint witnesses.
   *
   * Coefficient 0:
   *   0 + 0 = 0
   *
   * Coefficient MLKEM_N-1:
   *   (q-1) + (q-1) = 2*q-2
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    if (i == 0u)
    {
      canonical_r.coeffs[i] = 0;
      canonical_b.coeffs[i] = 0;
    }
    else if (i == MLKEM_N - 1u)
    {
      canonical_r.coeffs[i] = (int16_t)(MLKEM_Q - 1);
      canonical_b.coeffs[i] = (int16_t)(MLKEM_Q - 1);
    }
    else
    {
      canonical_r.coeffs[i] = pa08a_nondet_int16();
      canonical_b.coeffs[i] = pa08a_nondet_int16();

      __CPROVER_assume(
          (int32_t)canonical_r.coeffs[i] >= 0);
      __CPROVER_assume(
          (int32_t)canonical_r.coeffs[i] < (int32_t)MLKEM_Q);

      __CPROVER_assume(
          (int32_t)canonical_b.coeffs[i] >= 0);
      __CPROVER_assume(
          (int32_t)canonical_b.coeffs[i] < (int32_t)MLKEM_Q);
    }
  }

  /*
   * Complete signed-valid symbolic domain with four endpoint witnesses.
   *
   * index 0:           INT16_MIN + 0 = INT16_MIN
   * index 1:           -16384 + -16384 = INT16_MIN
   * index N-2:          16384 + 16383 = INT16_MAX
   * index N-1:         INT16_MAX + 0 = INT16_MAX
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    if (i == 0u)
    {
      signed_r.coeffs[i] = (int16_t)INT16_MIN;
      signed_b.coeffs[i] = 0;
    }
    else if (i == 1u)
    {
      signed_r.coeffs[i] = (int16_t)-16384;
      signed_b.coeffs[i] = (int16_t)-16384;
    }
    else if (i == MLKEM_N - 2u)
    {
      signed_r.coeffs[i] = (int16_t)16384;
      signed_b.coeffs[i] = (int16_t)16383;
    }
    else if (i == MLKEM_N - 1u)
    {
      signed_r.coeffs[i] = (int16_t)INT16_MAX;
      signed_b.coeffs[i] = 0;
    }
    else
    {
      signed_r.coeffs[i] = pa08a_nondet_int16();
      signed_b.coeffs[i] = pa08a_nondet_int16();

      mathematical_sum =
          (int32_t)signed_r.coeffs[i] +
          (int32_t)signed_b.coeffs[i];

      __CPROVER_assume(
          mathematical_sum >= (int32_t)INT16_MIN);
      __CPROVER_assume(
          mathematical_sum <= (int32_t)INT16_MAX);
    }
  }

  canonical_r_before = canonical_r;
  canonical_b_before = canonical_b;

  signed_r_before = signed_r;
  signed_b_before = signed_b;

  canonical_target_completed = 0;
  mlk_poly_add(&canonical_r, &canonical_b);
  canonical_target_completed = 1;

  signed_target_completed = 0;
  mlk_poly_add(&signed_r, &signed_b);
  signed_target_completed = 1;

  __CPROVER_assert(
      canonical_target_completed == 1,
      "PA08A_R1_CANONICAL_TARGET_COMPLETED: production call returned");

  __CPROVER_assert(
      signed_target_completed == 1,
      "PA08A_R2_SIGNED_TARGET_COMPLETED: production call returned");

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)canonical_r_before.coeffs[i] +
        (int32_t)canonical_b_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)canonical_r.coeffs[i] == mathematical_sum,
        "PA08A_P1_CANONICAL_EXACT_SUM: canonical result equals the exact sum");

    __CPROVER_assert(
        canonical_b.coeffs[i] == canonical_b_before.coeffs[i],
        "PA08A_P2_CANONICAL_FRAME: canonical right operand remains unchanged");

    __CPROVER_assert(
        pa08a_mod_q((int32_t)canonical_r.coeffs[i]) ==
            pa08a_mod_q(mathematical_sum),
        "PA08A_P3_CANONICAL_MOD_Q: canonical result has the correct residue");
  }

  __CPROVER_assert(
      canonical_r.coeffs[0] == 0,
      "PA08A_B1_CANONICAL_LOWER_BOUNDARY: coefficient 0 reaches exact sum zero");

  __CPROVER_assert(
      (int32_t)canonical_r.coeffs[MLKEM_N - 1u] ==
          (int32_t)(2 * MLKEM_Q - 2),
      "PA08A_B2_CANONICAL_UPPER_BOUNDARY: final coefficient reaches 2*q-2");

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)signed_r_before.coeffs[i] +
        (int32_t)signed_b_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)signed_r.coeffs[i] == mathematical_sum,
        "PA08A_P4_SIGNED_EXACT_SUM: signed-valid result equals the exact sum");

    __CPROVER_assert(
        signed_b.coeffs[i] == signed_b_before.coeffs[i],
        "PA08A_P5_SIGNED_FRAME: signed right operand remains unchanged");

    __CPROVER_assert(
        pa08a_mod_q((int32_t)signed_r.coeffs[i]) ==
            pa08a_mod_q(mathematical_sum),
        "PA08A_P6_SIGNED_MOD_Q: signed result has the correct residue");
  }

  __CPROVER_assert(
      signed_r.coeffs[0] == (int16_t)INT16_MIN,
      "PA08A_B3_SIGNED_MIN_DIRECT: coefficient 0 reaches INT16_MIN");

  __CPROVER_assert(
      signed_r.coeffs[1] == (int16_t)INT16_MIN,
      "PA08A_B4_SIGNED_MIN_SPLIT: split operands reach INT16_MIN");

  __CPROVER_assert(
      signed_r.coeffs[MLKEM_N - 2u] == (int16_t)INT16_MAX,
      "PA08A_B5_SIGNED_MAX_SPLIT: split operands reach INT16_MAX");

  __CPROVER_assert(
      signed_r.coeffs[MLKEM_N - 1u] == (int16_t)INT16_MAX,
      "PA08A_B6_SIGNED_MAX_DIRECT: final coefficient reaches INT16_MAX");

  return 0;
}
```

---

# Appendix B — Complete PA-08B Harness

```c
/*
 * PA-08B: Expected-failure reachability sentinel for mlk_poly_add.
 *
 * Purpose:
 *   Demonstrate that the canonical and complete signed-valid assumptions
 *   admit concrete executions that reach and return from production
 *   mlk_poly_add.
 *
 * The two deliberately false assertions occur only after their respective
 * target calls. Their expected failure is evidence that the paths are
 * reachable and the assumptions are not contradictory.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Expected campaign interpretation:
 *   BOTH_REACHABILITY_SENTINELS_CONFIRMED
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa08b_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly canonical_r;
  mlk_poly canonical_b;

  mlk_poly signed_r;
  mlk_poly signed_b;

  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA08B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA08B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  for (i = 0; i < MLKEM_N; i++)
  {
    canonical_r.coeffs[i] = pa08b_nondet_int16();
    canonical_b.coeffs[i] = pa08b_nondet_int16();

    __CPROVER_assume(
        (int32_t)canonical_r.coeffs[i] >= 0);
    __CPROVER_assume(
        (int32_t)canonical_r.coeffs[i] < (int32_t)MLKEM_Q);

    __CPROVER_assume(
        (int32_t)canonical_b.coeffs[i] >= 0);
    __CPROVER_assume(
        (int32_t)canonical_b.coeffs[i] < (int32_t)MLKEM_Q);
  }

  mlk_poly_add(&canonical_r, &canonical_b);

  /*
   * Expected FAILURE proves that at least one canonical execution reaches
   * this point after the production target returns.
   */
  __CPROVER_assert(
      0,
      "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET");

  for (i = 0; i < MLKEM_N; i++)
  {
    signed_r.coeffs[i] = pa08b_nondet_int16();
    signed_b.coeffs[i] = pa08b_nondet_int16();

    mathematical_sum =
        (int32_t)signed_r.coeffs[i] +
        (int32_t)signed_b.coeffs[i];

    __CPROVER_assume(
        mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(
        mathematical_sum <= (int32_t)INT16_MAX);
  }

  mlk_poly_add(&signed_r, &signed_b);

  /*
   * Expected FAILURE proves that at least one complete signed-valid
   * execution reaches this point after the production target returns.
   */
  __CPROVER_assert(
      0,
      "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET");

  return 0;
}
```

---

# Appendix C — Complete PA-08C Harness

```c
/*
 * PA-08C: Positive just-outside-boundary negative control.
 *
 * Boundary witness:
 *   INT16_MAX + 1 = 32768
 *
 * The exact mathematical sum is one greater than the largest representable
 * int16_t value.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Required evidence:
 *   - exact-result assertion failure;
 *   - target signed-conversion failure;
 *   - no missing-body failure.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

int main(void)
{
  mlk_poly r;
  mlk_poly b;
  mlk_poly r_before;

  unsigned i;
  int32_t mathematical_sum;

  for (i = 0; i < MLKEM_N; i++)
  {
    r.coeffs[i] = 0;
    b.coeffs[i] = 0;
  }

  r.coeffs[0] = (int16_t)INT16_MAX;
  b.coeffs[0] = 1;

  r_before = r;

  __CPROVER_assert(
      &r != &b,
      "PA08C_DISJOINTNESS: positive-boundary operands are distinct");

  mlk_poly_add(&r, &b);

  mathematical_sum =
      (int32_t)r_before.coeffs[0] +
      (int32_t)b.coeffs[0];

  __CPROVER_assert(
      mathematical_sum == (int32_t)INT16_MAX + 1,
      "PA08C_BOUNDARY_BINDING: mathematical sum is INT16_MAX+1");

  __CPROVER_assert(
      (int32_t)r.coeffs[0] == mathematical_sum,
      "PA08C_P1_POSITIVE_JUST_OUTSIDE_EXACT_SUM: INT16_MAX+1 cannot be stored exactly");

  return 0;
}
```

---

# Appendix D — Complete PA-08D Harness

```c
/*
 * PA-08D: Negative just-outside-boundary negative control.
 *
 * Boundary witness:
 *   INT16_MIN + (-1) = -32769
 *
 * The exact mathematical sum is one less than the smallest representable
 * int16_t value.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Required evidence:
 *   - exact-result assertion failure;
 *   - target signed-conversion failure;
 *   - no missing-body failure.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

int main(void)
{
  mlk_poly r;
  mlk_poly b;
  mlk_poly r_before;

  unsigned i;
  int32_t mathematical_sum;

  for (i = 0; i < MLKEM_N; i++)
  {
    r.coeffs[i] = 0;
    b.coeffs[i] = 0;
  }

  r.coeffs[MLKEM_N - 1u] = (int16_t)INT16_MIN;
  b.coeffs[MLKEM_N - 1u] = (int16_t)-1;

  r_before = r;

  __CPROVER_assert(
      &r != &b,
      "PA08D_DISJOINTNESS: negative-boundary operands are distinct");

  mlk_poly_add(&r, &b);

  mathematical_sum =
      (int32_t)r_before.coeffs[MLKEM_N - 1u] +
      (int32_t)b.coeffs[MLKEM_N - 1u];

  __CPROVER_assert(
      mathematical_sum == (int32_t)INT16_MIN - 1,
      "PA08D_BOUNDARY_BINDING: mathematical sum is INT16_MIN-1");

  __CPROVER_assert(
      (int32_t)r.coeffs[MLKEM_N - 1u] == mathematical_sum,
      "PA08D_P1_NEGATIVE_JUST_OUTSIDE_EXACT_SUM: INT16_MIN-1 cannot be stored exactly");

  return 0;
}
```

---

# Appendix E — Complete PA-08 Runner

```bash
#!/usr/bin/env bash
#
# PA-08: Vacuity, reachability, loop-endpoint, and arithmetic-boundary
#        hardening campaign for mlk_poly_add.
#
# PA-08A:
#   Successful proof of exact legal boundaries, target completion,
#   coefficient 0, and coefficient MLKEM_N-1.
#
# PA-08B:
#   Expected-failure reachability sentinels after canonical and signed-valid
#   target calls. The sentinel failures demonstrate satisfiable assumptions
#   and post-target path reachability.
#
# PA-08C:
#   Positive just-outside boundary:
#       INT16_MAX + 1
#
# PA-08D:
#   Negative just-outside boundary:
#       INT16_MIN - 1
#
# Expected final status:
#   PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED
#
# Production source is never modified.
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh
#   ./run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh
#

set -uo pipefail

CAMPAIGN_ID="PA-08"
CAMPAIGN_SCOPE="vacuity_reachability_loop_endpoint_and_boundary_hardening"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="768"

HARNESS_A="pa08a_mlk_poly_add_boundary_hardening_harness.c"
HARNESS_B="pa08b_mlk_poly_add_reachability_sentinel_harness.c"
HARNESS_C="pa08c_mlk_poly_add_upper_outside_boundary_harness.c"
HARNESS_D="pa08d_mlk_poly_add_lower_outside_boundary_harness.c"

POLY_C_EXPECTED_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa08_mlk_poly_add_hardening_${TIMESTAMP}"

for tool in git cbmc goto-cc sha256sum tee grep awk; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

for file in \
  "mlkem/src/poly.c" \
  "mlkem/src/poly.h" \
  "${HARNESS_A}" \
  "${HARNESS_B}" \
  "${HARNESS_C}" \
  "${HARNESS_D}"; do
  if [ ! -f "${file}" ]; then
    echo "ERROR: required file missing: ${file}" >&2
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

if ! git diff --quiet -- mlkem/src/poly.c; then
  echo "ERROR: production mlkem/src/poly.c has tracked modifications." >&2
  exit 4
fi

POLY_C_ACTUAL_SHA256="$(sha256sum mlkem/src/poly.c | awk '{print $1}')"

if [ "${POLY_C_ACTUAL_SHA256}" != "${POLY_C_EXPECTED_SHA256}" ]; then
  echo "ERROR: production poly.c hash mismatch." >&2
  echo "Expected: ${POLY_C_EXPECTED_SHA256}" >&2
  echo "Actual:   ${POLY_C_ACTUAL_SHA256}" >&2
  exit 5
fi

mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Production poly.c hash: ${POLY_C_ACTUAL_SHA256}"
  echo "Production source modified: no"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

for harness in "${HARNESS_A}" "${HARNESS_B}" "${HARNESS_C}" "${HARNESS_D}"; do
  sha256sum "${harness}" >> "${OUT_DIR}/harness_sha256.txt"
  cp "${harness}" "${OUT_DIR}/"
done

sha256sum mlkem/src/poly.c > "${OUT_DIR}/production_poly_c_sha256.txt"
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

build_and_run()
{
  local label="$1"
  local harness="$2"
  local result_dir="${OUT_DIR}/${label}"
  local goto_model="${result_dir}/${label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1

  mkdir -p "${result_dir}"

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

  echo
  echo "============================================================"
  echo "PA-08 UNIT: ${label}"
  echo "============================================================"

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

    echo "Running JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  echo "${build_exit} ${text_exit} ${json_exit}"
}

marker_has_status()
{
  local output_file="$1"
  local marker="$2"
  local status="$3"

  grep -F "${marker}" "${output_file}" | grep -q "${status}"
}

unexpected_failure_exists()
{
  local allow_conversion="$1"
  local output_file="$2"
  shift 2

  local line
  local allowed="no"

  while IFS= read -r line; do
    allowed="no"

    for marker in "$@"; do
      if printf '%s\n' "${line}" | grep -Fq "${marker}"; then
        allowed="yes"
      fi
    done

    if [ "${allow_conversion}" = "yes" ] &&
       printf '%s\n' "${line}" | \
         grep -Fq "arithmetic overflow on signed type conversion"; then
      allowed="yes"
    fi

    if [ "${allowed}" = "no" ]; then
      return 0
    fi
  done < <(grep "FAILURE" "${output_file}" || true)

  return 1
}

read -r A_BUILD A_TEXT A_JSON < <(
  build_and_run "pa08a_boundary_proof" "${HARNESS_A}" |
    tee /dev/stderr | tail -n 1
)

A_VERIFIED="no"

if [ "${A_BUILD}" -eq 0 ] &&
   [ "${A_TEXT}" -eq 0 ] &&
   [ "${A_JSON}" -eq 0 ] &&
   grep -q "VERIFICATION SUCCESSFUL" \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" &&
   ! grep -q "FAILURE" \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B1_CANONICAL_LOWER_BOUNDARY" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B2_CANONICAL_UPPER_BOUNDARY" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B3_SIGNED_MIN_DIRECT" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B6_SIGNED_MAX_DIRECT" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_R1_CANONICAL_TARGET_COMPLETED" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_R2_SIGNED_TARGET_COMPLETED" \
     "SUCCESS"; then
  A_VERIFIED="yes"
fi

read -r B_BUILD B_TEXT B_JSON < <(
  build_and_run "pa08b_reachability_sentinels" "${HARNESS_B}" |
    tee /dev/stderr | tail -n 1
)

B_CANONICAL_REACHABLE="no"
B_SIGNED_REACHABLE="no"
B_NO_BODY_FAILURE="no"
B_UNEXPECTED_FAILURE="yes"

if [ -f "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" ]; then
  if marker_has_status \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" \
       "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET" \
       "FAILURE"; then
    B_CANONICAL_REACHABLE="yes"
  fi

  if marker_has_status \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" \
       "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET" \
       "FAILURE"; then
    B_SIGNED_REACHABLE="yes"
  fi

  if grep -q "no body for callee" \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt"; then
    B_NO_BODY_FAILURE="yes"
  fi

  if ! unexpected_failure_exists \
       "no" \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" \
       "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET" \
       "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET"; then
    B_UNEXPECTED_FAILURE="no"
  fi
fi

B_CONFIRMED="no"

if [ "${B_BUILD}" -eq 0 ] &&
   [ "${B_TEXT}" -eq 10 ] &&
   [ "${B_JSON}" -eq 10 ] &&
   grep -q "VERIFICATION FAILED" \
     "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" &&
   [ "${B_CANONICAL_REACHABLE}" = "yes" ] &&
   [ "${B_SIGNED_REACHABLE}" = "yes" ] &&
   [ "${B_NO_BODY_FAILURE}" = "no" ] &&
   [ "${B_UNEXPECTED_FAILURE}" = "no" ]; then
  B_CONFIRMED="yes"
fi

check_outside_boundary()
{
  local label="$1"
  local harness="$2"
  local exact_marker="$3"

  local build_exit
  local text_exit
  local json_exit
  local exact_failure="no"
  local conversion_failure="no"
  local no_body_failure="no"
  local unexpected_failure="yes"
  local confirmed="no"

  read -r build_exit text_exit json_exit < <(
    build_and_run "${label}" "${harness}" |
      tee /dev/stderr | tail -n 1
  )

  local output_file="${OUT_DIR}/${label}/cbmc_output.txt"

  if [ -f "${output_file}" ]; then
    if marker_has_status "${output_file}" "${exact_marker}" "FAILURE"; then
      exact_failure="yes"
    fi

    if grep -F "arithmetic overflow on signed type conversion" \
         "${output_file}" | grep -q "FAILURE"; then
      conversion_failure="yes"
    fi

    if grep -q "no body for callee" "${output_file}"; then
      no_body_failure="yes"
    fi

    if ! unexpected_failure_exists \
         "yes" \
         "${output_file}" \
         "${exact_marker}"; then
      unexpected_failure="no"
    fi
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 10 ] &&
     [ "${json_exit}" -eq 10 ] &&
     grep -q "VERIFICATION FAILED" "${output_file}" &&
     [ "${exact_failure}" = "yes" ] &&
     [ "${conversion_failure}" = "yes" ] &&
     [ "${no_body_failure}" = "no" ] &&
     [ "${unexpected_failure}" = "no" ]; then
    confirmed="yes"
  fi

  {
    echo "label=${label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "exact_assertion_failure_observed=${exact_failure}"
    echo "conversion_failure_observed=${conversion_failure}"
    echo "no_body_failure_observed=${no_body_failure}"
    echo "unexpected_failure_observed=${unexpected_failure}"
    echo "boundary_confirmed=${confirmed}"
  } > "${OUT_DIR}/${label}/summary.txt"

  cat "${OUT_DIR}/${label}/summary.txt"

  printf '%s\n' "${confirmed}"
}

C_CONFIRMED="$(
  check_outside_boundary \
    "pa08c_positive_outside_boundary" \
    "${HARNESS_C}" \
    "PA08C_P1_POSITIVE_JUST_OUTSIDE_EXACT_SUM" |
    tee /dev/stderr | tail -n 1
)"

D_CONFIRMED="$(
  check_outside_boundary \
    "pa08d_negative_outside_boundary" \
    "${HARNESS_D}" \
    "PA08D_P1_NEGATIVE_JUST_OUTSIDE_EXACT_SUM" |
    tee /dev/stderr | tail -n 1
)"

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${A_VERIFIED}" = "yes" ] &&
   [ "${B_CONFIRMED}" = "yes" ] &&
   [ "${C_CONFIRMED}" = "yes" ] &&
   [ "${D_CONFIRMED}" = "yes" ]; then
  FINAL_STATUS="PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "production_source_modified=no"
  echo "pa08a_boundary_and_endpoint_proof_verified=${A_VERIFIED}"
  echo "pa08b_canonical_path_reachable=${B_CANONICAL_REACHABLE}"
  echo "pa08b_signed_valid_path_reachable=${B_SIGNED_REACHABLE}"
  echo "pa08b_only_expected_sentinel_failures=$([ "${B_UNEXPECTED_FAILURE}" = "no" ] && echo yes || echo no)"
  echo "pa08c_positive_just_outside_boundary_confirmed=${C_CONFIRMED}"
  echo "pa08d_negative_just_outside_boundary_confirmed=${D_CONFIRMED}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-08 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED" ]; then
  echo
  echo "PA-08 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Valid assumptions were shown reachable after target execution."
  echo "Exact legal lower and upper boundaries were verified."
  echo "Both nearest out-of-range boundaries were rejected as expected."
  echo "Production source remained unchanged."
else
  echo
  echo "PA-08 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

---

# Appendix F — PA-08 Property Ledger

| ID | Property or obligation | Outcome |
|---|---|---|
| PA08A-R1 | canonical target returned | Verified |
| PA08A-R2 | signed-valid target returned | Verified |
| PA08A-P1 | canonical exact sum | Verified |
| PA08A-P2 | canonical right-input frame | Verified |
| PA08A-P3 | canonical modulo-`q` refinement | Verified |
| PA08A-B1 | canonical lower boundary `0` | Verified |
| PA08A-B2 | canonical upper boundary `2q-2` | Verified |
| PA08A-P4 | signed-valid exact sum | Verified |
| PA08A-P5 | signed right-input frame | Verified |
| PA08A-P6 | signed modulo-`q` refinement | Verified |
| PA08A-B3 | direct `INT16_MIN` | Verified |
| PA08A-B4 | split `INT16_MIN` | Verified |
| PA08A-B5 | split `INT16_MAX` | Verified |
| PA08A-B6 | direct `INT16_MAX` | Verified |
| PA08B-R1 | canonical path reachable after target | Expected sentinel failure confirmed |
| PA08B-R2 | signed-valid path reachable after target | Expected sentinel failure confirmed |
| PA08C-P1 | `INT16_MAX + 1` exact storage | Refuted as expected |
| PA08C-C1 | upper out-of-range conversion | Failure confirmed |
| PA08D-P1 | `INT16_MIN - 1` exact storage | Refuted as expected |
| PA08D-C1 | lower out-of-range conversion | Failure confirmed |
| PA08-C1 | combined campaign status | `PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED` |

---

# Appendix G — Combined PA-01 Through PA-08 Summary

| Campaign | Main purpose | Result |
|---|---|---|
| PA-01 | canonical FIPS-domain correctness | Verified |
| PA-02 | complete signed contract-valid correctness | Verified |
| PA-03 | unrestricted exact-addition negative control | Expected counterexample confirmed |
| PA-04 | aliasing diagnostic and representability boundary | Confirmed |
| PA-05 | production call-site verification | Verified |
| PA-06 | cross-parameter replication | Verified |
| PA-07 | mutation sensitivity | All controlled mutants detected |
| PA-08 | anti-vacuity, reachability, and exact boundaries | Confirmed |

---

# Appendix H — Terminology

**Vacuous proof:** A proof that succeeds because no execution satisfies the assumptions or reaches
the property.

**Reachability sentinel:** A deliberately false assertion placed at a program point to show that an
execution reaches that point when the assertion fails.

**Legal endpoint:** The greatest or least exact result admitted by the target representation and
contract.

**Just-outside boundary:** The nearest value beyond a legal endpoint.

**Split endpoint witness:** A nontrivial operand pair whose sum reaches an exact representation
boundary.

**Loop-endpoint coverage:** Explicit evidence that both the first and final loop-controlled array
elements are processed.
