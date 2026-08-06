# PA-07: Mutation-Sensitivity Record for `mlk_poly_add`

## Complete A-to-Z Technical Documentation of the Controlled-Mutant Detection Campaign

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Target project:** `pq-code-package/mlkem-native`  
**Target function:** `mlk_poly_add`  
**Verification method:** CBMC bounded model checking  
**Campaign item:** PA-07  
**Campaign scope:** Mutation sensitivity of the frozen PA-01 and PA-02 harnesses  
**Parameter set:** ML-KEM-768  
**Controlled mutants:** 5  
**Frozen harnesses:** 2  
**Mutant–harness verification pairs:** 10  
**Final campaign status:** `PA07_ALL_MUTANTS_DETECTED`  
**Document type:** Self-contained formal technical record

---

## 1. Executive Summary

PA-07 evaluated whether the previously successful `mlk_poly_add` harnesses were capable of
detecting meaningful implementation defects.

The campaign used two frozen verification harnesses:

```text
PA-01 — canonical FIPS-domain relational harness
PA-02 — complete signed contract-valid harness
```

Before testing mutants, both harnesses were re-run against the unmodified production
`mlkem/src/poly.c` implementation as positive baseline controls.

Five controlled defective implementations were then compiled outside the production source tree:

1. addition replaced by subtraction;
2. loop starts at coefficient 1;
3. final coefficient skipped;
4. only the first half of the polynomial processed;
5. result written to the read-only operand instead of the accumulator.

Each mutant was checked against both frozen harnesses:

```text
5 mutants × 2 harnesses = 10 mutant–harness pairs
```

The final campaign status was:

```text
PA07_ALL_MUTANTS_DETECTED
```

Under the frozen PA-07 runner, this status is emitted only when:

- the PA-01 production baseline succeeds;
- the PA-02 production baseline succeeds;
- all ten mutant–harness pairs build successfully;
- every mutant run produces the expected CBMC failure status;
- the designated semantic or frame property fails;
- no missing-function-body defect is involved;
- production `mlkem/src/poly.c` remains unchanged;
- the frozen harness hashes match the expected values;
- the production `poly.c` hash matches the expected revision.

The scientifically correct interpretation is:

> The two frozen harnesses accept the correct production implementation and reject every
> controlled defective implementation in the PA-07 mutation set.

This result strengthens confidence that the successful PA-01 and PA-02 proofs are sensitive to
important semantic, control-flow, coverage, and write-destination defects.

It does not prove that the harnesses detect every possible defect.

---

## 2. Research Purpose

The PA-07 research question is:

> Are the successful `mlk_poly_add` harnesses discriminating verification artefacts that reject
> incorrect implementations, or are they too weak to distinguish the production body from
> plausible defective variants?

A proof harness that only succeeds against the correct implementation has limited empirical
validation.

Mutation analysis adds an adversarial test:

```text
correct production implementation → harness should succeed
controlled defective implementation → harness should fail
```

This provides evidence of property sensitivity.

---

## 3. Verification Objects

### 3.1 Frozen PA-01 harness

PA-01 verifies the canonical FIPS-domain behaviour of `mlk_poly_add`, including:

- exact coefficient-wise addition;
- canonical-domain output bounds;
- modulo-`q` refinement;
- frame properties;
- commutativity;
- additive identity;
- object separation;
- selected CBMC safety properties.

### 3.2 Frozen PA-02 harness

PA-02 verifies the complete signed and non-canonical domain in which every exact mathematical sum
is representable in `int16_t`, including:

- exact signed addition;
- modulo-`q` congruence;
- canonical-residue refinement;
- frame preservation;
- commutativity;
- additive identity;
- object separation;
- selected CBMC safety properties.

### 3.3 Production target

The positive baseline uses the actual production implementation from:

```text
mlkem/src/poly.c
```

### 3.4 Controlled mutant source

The negative experiments use:

```text
pa07_mlk_poly_add_mutant_implementation.c
```

This file is compiled into temporary GOTO models and is never copied over the production source.

---

## 4. Production-Source Integrity Boundary

PA-07 explicitly protects the production implementation.

The runner verifies:

1. the repository commit;
2. that `mlkem/src/poly.c` has no tracked modifications;
3. the SHA-256 identity of `mlkem/src/poly.c`;
4. the SHA-256 identity of the PA-01 harness;
5. the SHA-256 identity of the PA-02 harness.

The campaign refuses to run if any of these checks fail.

Therefore:

```text
production_source_modified=no
```

is part of the scientific result.

The mutants are external experimental models, not edits to the verified repository.

---

## 5. Why Positive Baseline Controls Are Necessary

A mutant failure is useful only if the same harness still accepts the correct production
implementation.

Without a positive baseline, a mutant failure could be caused by:

- a broken harness;
- a build problem;
- an invalid nondeterministic helper;
- an incorrect repository configuration;
- a missing target body;
- a stale source file;
- a globally failing CBMC option.

PA-07 therefore begins with:

```text
PA-01 + production poly.c → expected VERIFICATION SUCCESSFUL
PA-02 + production poly.c → expected VERIFICATION SUCCESSFUL
```

Only after both baseline controls succeed are mutant detections considered meaningful.

---

## 6. Mutation Campaign Architecture

For every mutant, PA-07 performs:

1. GOTO model construction;
2. text-mode CBMC execution;
3. JSON-mode CBMC execution;
4. expected process-exit validation;
5. generic `VERIFICATION FAILED` validation;
6. designated property-marker failure validation;
7. missing-body failure rejection;
8. campaign-level mutant classification.

A mutant is accepted as detected only when all required conditions are satisfied.

---

## 7. Low-Level Failure Versus Scientific Success

For a mutant run, the expected CBMC result is:

```text
VERIFICATION FAILED
```

This is not a failed experiment.

It is the intended scientific result.

The campaign-level success condition is:

```text
mutant_detected=yes
```

The distinction is:

```text
low-level verifier result: property refuted
campaign result: mutant successfully detected
```

---

# Part I — M1: Addition Replaced by Subtraction

## 8. Mutation Definition

The production expression:

```c
r->coeffs[i] =
    (int16_t)(r->coeffs[i] + b->coeffs[i]);
```

is replaced by:

```c
r->coeffs[i] =
    (int16_t)(r->coeffs[i] - b->coeffs[i]);
```

This changes the mathematical operation from addition to subtraction.

---

## 9. Expected Detection Mechanism

The principal detector is exact-result mismatch.

PA-01 expects:

```text
result[i] = a[i] + b[i]
```

PA-02 expects:

```text
result[i] = a[i] + b[i]
```

The mutant instead computes:

```text
result[i] = a[i] - b[i]
```

For any reachable nonzero `b[i]`, the exact-addition assertion is refutable.

---

## 10. Scientific Meaning of M1 Detection

Detection of M1 demonstrates sensitivity to an operator-level semantic defect.

The harnesses are not merely checking:

- loop completion;
- type safety;
- memory safety;
- output representability.

They check the intended arithmetic relation.

---

# Part II — M2: Loop Starts at Coefficient 1

## 11. Mutation Definition

The production loop:

```c
for (i = 0; i < MLKEM_N; i++)
```

is replaced by:

```c
for (i = 1; i < MLKEM_N; i++)
```

Coefficient `0` remains unchanged.

---

## 12. Expected Detection Mechanism

The exact-result property is checked for every coefficient.

For coefficient `0`, the mutant produces:

```text
result_after[0] = result_before[0]
```

instead of:

```text
result_after[0] =
result_before[0] + b_before[0]
```

A symbolic nonzero right operand gives a counterexample.

---

## 13. Scientific Meaning of M2 Detection

Detection of M2 demonstrates sensitivity to:

- loop lower-bound defects;
- omitted first-element processing;
- incomplete array coverage.

This is stronger than checking only a representative coefficient.

---

# Part III — M3: Final Coefficient Skipped

## 14. Mutation Definition

The mutant loop stops before processing the last coefficient.

The intended range is:

```text
0 .. MLKEM_N - 1
```

The mutant processes only:

```text
0 .. MLKEM_N - 2
```

For `MLKEM_N = 256`, coefficient `255` is omitted.

---

## 15. Expected Detection Mechanism

The exact-result assertions quantify across the full coefficient array.

At the final coefficient, the stored result remains the pre-state value.

The exact-addition property therefore fails for a reachable nonzero right operand.

---

## 16. Scientific Meaning of M3 Detection

Detection of M3 demonstrates sensitivity to:

- loop upper-bound defects;
- off-by-one errors;
- omission of the final array element.

M2 and M3 jointly test both ends of the loop domain.

---

# Part IV — M4: Only the First Half Processed

## 17. Mutation Definition

The mutant loop executes only:

```c
for (i = 0; i < MLKEM_N / 2u; i++)
```

For `MLKEM_N = 256`, only coefficients `0` through `127` are processed.

Coefficients `128` through `255` remain unchanged.

---

## 18. Expected Detection Mechanism

The exact-result properties cover all 256 coefficients.

Any omitted coefficient with a nonzero right operand refutes the expected sum.

---

## 19. Scientific Meaning of M4 Detection

Detection of M4 demonstrates sensitivity to a large truncation defect.

It shows that success is not based only on:

- checking the beginning of the array;
- checking a small prefix;
- trusting the loop bound without post-state coverage.

---

# Part V — M5: Result Written to the Wrong Operand

## 20. Mutation Definition

The production body writes to:

```text
r
```

The mutant writes the sum into:

```text
b
```

The accumulator remains unchanged, while the supposedly read-only operand is modified.

---

## 21. Expected Detection Mechanism

For M5, the designated detector is the read-only input frame property.

PA-01 checks that the right operand remains unchanged.

PA-02 checks the same frame condition.

The mutant directly violates this requirement.

The exact-result property may also fail because `r` is not updated, but PA-07 deliberately
classifies M5 using the frame-property marker to demonstrate that the suite detects a
write-destination defect through an independent property family.

---

## 22. Scientific Meaning of M5 Detection

Detection of M5 demonstrates sensitivity to:

- wrong-destination writes;
- unintended modification of a read-only input;
- frame-condition violations;
- object-role confusion.

This is important because a harness containing only an arithmetic assertion might not clearly
identify the read-only-object corruption dimension.

---

# Part VI — Detection Matrix

## 23. Controlled-Mutant Matrix

| Mutant | Defect class | PA-01 detector | PA-02 detector | Campaign result |
|---|---|---|---|---|
| M1 | wrong arithmetic operator | exact sum | exact signed sum | Detected |
| M2 | omitted first coefficient | exact sum | exact signed sum | Detected |
| M3 | omitted final coefficient | exact sum | exact signed sum | Detected |
| M4 | half-loop truncation | exact sum | exact signed sum | Detected |
| M5 | wrong destination / frame violation | right-input frame | right-input frame | Detected |

Because the final status was:

```text
PA07_ALL_MUTANTS_DETECTED
```

the frozen runner's acceptance logic establishes:

```text
10 of 10 mutant–harness pairs detected
```

provided the executed runner was the frozen PA-07 runner documented in this record.

---

## 24. Mutation Score

For the selected mutation set:

```text
detected mutant–harness pairs = 10
total mutant–harness pairs = 10
```

Pair-level mutation score:

```text
10 / 10 = 100%
```

At the mutant level:

```text
detected mutants = 5
total mutants = 5
```

Mutant-level mutation score:

```text
5 / 5 = 100%
```

This score applies only to the five controlled mutants defined in PA-07.

It is not a universal mutation score over all possible C defects.

---

# Part VII — CBMC Execution and Classification

## 25. Baseline Acceptance Rules

A production baseline is accepted only when:

- the GOTO model builds;
- text CBMC exits successfully;
- JSON CBMC exits successfully;
- `VERIFICATION SUCCESSFUL` appears;
- the required explicit property marker succeeds;
- no `FAILURE` line appears.

---

## 26. Mutant Acceptance Rules

A mutant detection is accepted only when:

- the GOTO model builds;
- text CBMC returns the expected verification-failure exit status;
- JSON CBMC returns the expected verification-failure exit status;
- `VERIFICATION FAILED` appears;
- the designated semantic or frame property is reported as `FAILURE`;
- no `no body for callee` failure appears.

This rejects infrastructure failures as invalid mutation evidence.

---

## 27. Safety-Check Configuration

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

The mutation campaign therefore remains under the same broad CBMC safety configuration used in
the earlier successful proofs.

---

## 28. Directness of the Mutant Model

Each controlled mutant provides a concrete implementation of `mlk_poly_add`.

The frozen harness invokes that implementation directly.

The mutant is not represented by:

- a contract stub;
- an assumed summary;
- a nondeterministic output;
- a mocked success value.

CBMC analyses the actual mutant loop and assignments.

---

# Part VIII — What PA-07 Establishes

## 29. Positive Findings

PA-07 establishes that, for the selected controlled mutation set:

1. PA-01 accepts the unmodified production implementation;
2. PA-02 accepts the unmodified production implementation;
3. both harnesses reject addition-to-subtraction mutation;
4. both harnesses reject omission of coefficient `0`;
5. both harnesses reject omission of coefficient `MLKEM_N - 1`;
6. both harnesses reject half-loop truncation;
7. both harnesses reject writing the result to the wrong operand;
8. exact-result properties detect arithmetic and coverage defects;
9. frame properties detect read-only-object corruption;
10. the mutation evidence is not caused by a missing target body;
11. production source remains unchanged;
12. the successful baseline and failed mutants form a discriminating test.

---

## 30. What PA-07 Does Not Establish

PA-07 does not prove:

1. detection of every possible implementation defect;
2. detection of every possible loop mutation;
3. detection of every pointer-aliasing defect;
4. detection of every constant-time defect;
5. detection of dead-code mutations outside reached paths;
6. detection of defects in unrelated functions;
7. end-to-end ML-KEM correctness;
8. assembly or native-backend mutation sensitivity;
9. compiler-independent mutation behaviour;
10. perfect completeness of the harness suite.

A surviving mutant outside the selected mutation set remains possible.

---

## 31. Why Mutation Detection Strengthens—but Does Not Replace—Proof

The successful PA-01 and PA-02 results are formal proofs under their encoded assumptions and
properties.

PA-07 does not create those proofs.

Instead, it provides complementary empirical validation that the properties are strong enough to
reject several realistic defective implementations.

The relationship is:

```text
formal proof:
production implementation satisfies encoded properties

mutation sensitivity:
encoded properties reject selected incorrect implementations
```

Both forms of evidence are useful, but they answer different questions.

---

# Part IX — Vacuity, Validity, and Threats

## 32. Anti-Vacuity Features

PA-07 reduces vacuity concerns through:

- positive production baselines;
- symbolic input domains;
- concrete mutant bodies;
- explicit target reachability;
- required property-marker failures;
- rejection of missing-body failures;
- multiple independent mutation classes;
- frame-property mutation detection;
- full-array coverage mutations.

---

## 33. Threats to Validity

### 33.1 Mutation-set selection

The five mutants are representative but not exhaustive.

### 33.2 Equivalent mutants

PA-07 deliberately avoids mutants expected to be semantically equivalent under the harness
domain.

### 33.3 Single parameter-set mutation execution

PA-07 runs at ML-KEM-768. The targeted defects affect parameter-invariant polynomial semantics.

Cross-parameter successful behaviour was established separately in PA-06.

### 33.4 Harness-pair selection

The campaign uses PA-01 and PA-02 as the principal frozen function-level harnesses.

Caller-context harnesses are not part of the PA-07 mutant matrix.

### 33.5 Tool-model dependence

The result applies to the selected CBMC model and C configuration.

### 33.6 Mutation location

All mutants replace the target implementation itself.

Mutations in producer functions or callers require separate campaigns.

---

# Part X — Independence, Distinctness, and Novelty

## 34. Independent Campaign Design

PA-07 was independently designed around:

- frozen positive baselines;
- external controlled mutants;
- production-source hash protection;
- harness hash protection;
- paired detection by two independent domain harnesses;
- property-specific failure classification;
- automatic rejection of infrastructure failures;
- pair-level and mutant-level mutation scoring.

This is not a standard success-only harness execution.

---

## 35. Distinctness from Repository Verification Artefacts

The PA-07 mutant source and runner are newly authored experimental artefacts.

They are distinct from the repository's production implementation because:

- they are stored outside `mlkem/src`;
- they are compiled only for the mutation experiment;
- they intentionally contain incorrect bodies;
- they are never installed as production code;
- the runner verifies that production `poly.c` remains unchanged.

The repository's original `mlk_poly_add` harness was not used as the construction source for this
mutation campaign.

---

## 36. Honest Novelty Position

The strongest accurate novelty statement is:

> PA-07 is an independently authored mutation-sensitivity campaign that validates two frozen
> `mlk_poly_add` proof harnesses against five controlled semantic, coverage, and frame-condition
> defects while cryptographically protecting the production source and baseline harnesses.

Absolute uniqueness relative to every existing mutation-testing experiment is not claimed.

---

## 37. Formal-Artefact Exposure Disclosure

The cumulative campaign was informed by:

- production C source;
- public parameter definitions;
- embedded source contracts and loop annotations;
- previously generated PA-01 through PA-06 artefacts.

The correct classification remains:

```text
original-harness-blind
source-contract-informed
independently authored
not fully formal-artefact-blind
```

---

# Part XI — Combined PA-01 Through PA-07 Assurance

## 38. Campaign Progression

### PA-01 — Canonical domain

Verified exact addition for canonical FIPS representatives.

### PA-02 — Complete valid signed domain

Verified exact addition for every signed pair whose mathematical sum is representable in
`int16_t`.

### PA-03 — Invalid-domain negative control

Confirmed that unrestricted exact addition is impossible beyond the representability boundary.

### PA-04 — Aliasing diagnostic

Verified safe doubling under explicit aliasing as an out-of-contract diagnostic and refuted
unrestricted exact doubling.

### PA-05 — Production call sites

Verified the three production call-site obligations for ML-KEM-768.

### PA-06 — Cross-parameter replication

Replicated principal function-level and production call-site obligations across
ML-KEM-512, ML-KEM-768, and ML-KEM-1024.

### PA-07 — Mutation sensitivity

Confirmed that the frozen PA-01 and PA-02 harnesses accept the production baseline and reject all
five controlled defective implementations.

---

## 39. Combined Assurance Statement

The cumulative evidence supports the following statement:

> For the selected `mlkem-native` revision and portable C CBMC model, `mlk_poly_add` has been
> verified over its canonical and complete signed contract-valid domains; its out-of-domain
> representability boundary has been confirmed by negative control; its current safe aliasing
> behaviour has been characterised as an out-of-contract diagnostic; its production call-site
> obligations have been verified; the principal proofs have been replicated across all three
> ML-KEM parameter sets; and the two frozen principal harnesses have demonstrated sensitivity to
> five controlled implementation defects.

This is a strong, layered assurance argument.

It is not an unlimited proof of the entire repository or every possible property.

---

## 40. Scope of the `mlk_poly_add` correctness result

The accurate answer is:

> Yes, within the frozen source revision, portable C backend, CBMC semantics, declared input
> assumptions, parameter configurations, production caller models, and encoded properties, the
> campaign provides strong formal evidence that `mlk_poly_add` correctly implements exact
> coefficient-wise addition in its valid domain.

PA-07 adds evidence that the principal harnesses are not trivially permissive.

The inaccurate answer would be:

> `mlk_poly_add` is absolutely correct under every conceivable environment, backend, compiler,
> alias relation, and property.

Formal verification remains scoped.

---

# Part XII — Reproducibility

## 41. Reproduction Command

From the frozen repository root:

```bash
./run_pa07_mlk_poly_add_mutation_sensitivity.sh
```

The runner records:

- repository identity;
- Git status;
- production source hash;
- frozen harness hashes;
- mutant source hash;
- runner hash;
- CBMC version;
- `goto-cc` version;
- build commands;
- CBMC commands;
- text outputs;
- JSON outputs;
- baseline summaries;
- mutant-pair summaries;
- final campaign summary.

---

## 42. Expected Final Classification

The successful final classification is:

```text
final_status=PA07_ALL_MUTANTS_DETECTED
```

This status is stronger than a generic statement that “some mutants failed.”

It encodes:

```text
both baselines successful
all five mutants detected by PA-01
all five mutants detected by PA-02
ten detected mutant–harness pairs
production source unchanged
```

under the documented runner logic.

---

## 43. Professor-Ready Result Statement

> PA-07 evaluated the mutation sensitivity of the frozen PA-01 and PA-02
> `mlk_poly_add` harnesses. Both harnesses first re-verified the unmodified production
> implementation. Five external controlled mutants were then analysed: addition replaced by
> subtraction, omission of the first coefficient, omission of the final coefficient, half-loop
> truncation, and writing the result into the read-only operand. Each mutant was checked against
> both frozen harnesses. The runner accepted a detection only when the GOTO model built, text and
> JSON CBMC runs returned the expected verification-failure status, the designated exact-result or
> frame property failed, and no missing-body defect occurred. All ten mutant–harness pairs were
> detected while production `poly.c` remained unchanged, producing
> `PA07_ALL_MUTANTS_DETECTED`. The result demonstrates sensitivity to the selected arithmetic,
> coverage, off-by-one, truncation, and write-destination defects.

---

## 44. Correct Next Campaign Item

The next recommended campaign stage is:

```text
PA-08: vacuity, reachability, and boundary-coverage hardening
```

PA-08 should consolidate explicit evidence that:

- assumptions are satisfiable;
- target calls are reached;
- all critical lower and upper arithmetic boundaries are reachable;
- loop endpoints are covered;
- proof success is not produced by contradictory assumptions;
- target-specific properties are separated from unreachable whole-file properties.

---

## 45. Final Conclusion

PA-07 completed successfully.

The campaign established that:

```text
the correct production body is accepted
the wrong arithmetic operator is rejected
the omitted first coefficient is rejected
the omitted final coefficient is rejected
the half-loop implementation is rejected
the wrong-destination implementation is rejected
both frozen principal harnesses detect every selected mutant
production source remains unchanged
```

The final status is:

```text
PA07_ALL_MUTANTS_DETECTED
```

---

# Appendix A — Complete Controlled-Mutant Source

```c
/*
 * PA-07 controlled mutant implementations for mlk_poly_add.
 *
 * IMPORTANT:
 *   This file is not production source and must never replace or modify
 *   mlkem/src/poly.c. The PA-07 runner compiles it only into temporary
 *   CBMC GOTO models.
 *
 * Compile with exactly one mutation identifier:
 *
 *   PA07_MUTATION_ID=1  addition replaced by subtraction
 *   PA07_MUTATION_ID=2  loop starts at coefficient 1
 *   PA07_MUTATION_ID=3  final coefficient is skipped
 *   PA07_MUTATION_ID=4  only the first half is processed
 *   PA07_MUTATION_ID=5  result is written into b instead of r
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

#ifndef PA07_MUTATION_ID
#error PA07_MUTATION_ID must be defined
#endif

#if PA07_MUTATION_ID < 1 || PA07_MUTATION_ID > 5
#error PA07_MUTATION_ID must be between 1 and 5
#endif

void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;

#if PA07_MUTATION_ID == 1

  /*
   * M1 — arithmetic operator mutation:
   *      + is replaced by -.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] - b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 2

  /*
   * M2 — lower-bound mutation:
   *      processing begins at coefficient 1, leaving coefficient 0
   *      unchanged.
   */
  for (i = 1; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 3

  /*
   * M3 — upper-bound mutation:
   *      coefficient MLKEM_N-1 is never processed.
   */
  for (i = 0; i + 1u < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 4

  /*
   * M4 — truncation mutation:
   *      only the first half of the polynomial is processed.
   */
  for (i = 0; i < MLKEM_N / 2u; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 5

  /*
   * M5 — destination mutation:
   *      the computed result is written into the read-only operand b
   *      rather than into the accumulator r.
   *
   * The harness objects themselves are not declared const. The cast is
   * used only to model this deliberate wrong-destination implementation.
   */
  {
    mlk_poly *mutable_b;

    mutable_b = (mlk_poly *)b;

    for (i = 0; i < MLKEM_N; i++)
    {
      mutable_b->coeffs[i] =
          (int16_t)(r->coeffs[i] + b->coeffs[i]);
    }
  }

#endif
}
```

---

# Appendix B — Complete PA-07 Runner

```bash
#!/usr/bin/env bash
#
# PA-07: Mutation-sensitivity campaign for the frozen mlk_poly_add harnesses.
#
# Purpose:
#   Demonstrate that the successful PA-01 and PA-02 harnesses are capable of
#   rejecting meaningful defective implementations rather than merely
#   succeeding against the production body.
#
# Production source is never modified.
#
# Baseline controls:
#   - frozen PA-01 against production mlkem/src/poly.c: expected success
#   - frozen PA-02 against production mlkem/src/poly.c: expected success
#
# Controlled mutants:
#   M1: addition replaced by subtraction
#   M2: loop starts at coefficient 1
#   M3: final coefficient skipped
#   M4: only first half processed
#   M5: result written to b instead of r
#
# Each mutant is checked against both frozen harnesses:
#
#   5 mutants × 2 frozen harnesses = 10 expected-failure pairs
#
# Expected final status:
#   PA07_ALL_MUTANTS_DETECTED
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa07_mlk_poly_add_mutation_sensitivity.sh
#   ./run_pa07_mlk_poly_add_mutation_sensitivity.sh
#

set -uo pipefail

CAMPAIGN_ID="PA-07"
CAMPAIGN_SCOPE="mutation_sensitivity_of_frozen_harnesses"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="768"

PA01_HARNESS="cleanroom_mlk_poly_add_fips_relational_harness_v2.c"
PA02_HARNESS="pa02_mlk_poly_add_full_signed_contract_valid_harness.c"
MUTANT_SOURCE="pa07_mlk_poly_add_mutant_implementation.c"

PA01_EXPECTED_SHA256="307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e"
PA02_EXPECTED_SHA256="e83d521e23f93c2435058598be5ef245bb02c554a4b7992dd8844418720c2ce2"
POLY_C_EXPECTED_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa07_mlk_poly_add_mutation_${TIMESTAMP}"

for tool in git cbmc goto-cc sha256sum tee grep awk; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

for file in \
  "mlkem/src/poly.c" \
  "mlkem/src/poly.h" \
  "${PA01_HARNESS}" \
  "${PA02_HARNESS}" \
  "${MUTANT_SOURCE}"; do
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
  echo "PA-07 refuses to run because mutants must remain external." >&2
  exit 4
fi

PA01_ACTUAL_SHA256="$(sha256sum "${PA01_HARNESS}" | awk '{print $1}')"
PA02_ACTUAL_SHA256="$(sha256sum "${PA02_HARNESS}" | awk '{print $1}')"
POLY_C_ACTUAL_SHA256="$(sha256sum mlkem/src/poly.c | awk '{print $1}')"

if [ "${PA01_ACTUAL_SHA256}" != "${PA01_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-01 harness hash mismatch." >&2
  echo "Expected: ${PA01_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA01_ACTUAL_SHA256}" >&2
  exit 5
fi

if [ "${PA02_ACTUAL_SHA256}" != "${PA02_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-02 harness hash mismatch." >&2
  echo "Expected: ${PA02_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA02_ACTUAL_SHA256}" >&2
  exit 5
fi

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
  echo "Expected final status: PA07_ALL_MUTANTS_DETECTED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Frozen PA-01 hash: ${PA01_ACTUAL_SHA256}"
  echo "Frozen PA-02 hash: ${PA02_ACTUAL_SHA256}"
  echo "Production poly.c hash: ${POLY_C_ACTUAL_SHA256}"
  echo "Production poly.c modified: no"
  echo "Mutants: 5"
  echo "Mutant-harness pairs: 10"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

sha256sum "${PA01_HARNESS}" > "${OUT_DIR}/pa01_harness_sha256.txt"
sha256sum "${PA02_HARNESS}" > "${OUT_DIR}/pa02_harness_sha256.txt"
sha256sum "${MUTANT_SOURCE}" > "${OUT_DIR}/mutant_source_sha256.txt"
sha256sum mlkem/src/poly.c > "${OUT_DIR}/production_poly_c_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"

cp "${PA01_HARNESS}" "${OUT_DIR}/"
cp "${PA02_HARNESS}" "${OUT_DIR}/"
cp "${MUTANT_SOURCE}" "${OUT_DIR}/"
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

run_baseline()
{
  local harness_label="$1"
  local harness="$2"
  local required_marker="$3"

  local result_dir="${OUT_DIR}/baseline/${harness_label}"
  local goto_model="${result_dir}/${harness_label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1
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
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-07 BASELINE: ${harness_label}"
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

    echo "Running baseline JSON verification silently..."
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
     grep -F "${required_marker}" "${result_dir}/cbmc_output.txt" | \
       grep -q "SUCCESS"; then
    marker_success="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     ! grep -q "FAILURE" "${result_dir}/cbmc_output.txt"; then
    failure_lines="no"
  fi

  {
    echo "harness=${harness_label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_successful=${successful}"
    echo "required_marker_success=${marker_success}"
    echo "failure_lines_observed=${failure_lines}"
  } > "${result_dir}/summary.txt"

  cat "${result_dir}/summary.txt"

  if [ "${successful}" = "yes" ] &&
     [ "${marker_success}" = "yes" ] &&
     [ "${failure_lines}" = "no" ]; then
    return 0
  fi

  return 1
}

run_mutant()
{
  local mutation_id="$1"
  local mutation_name="$2"
  local harness_label="$3"
  local harness="$4"
  local expected_failure_marker="$5"

  local result_dir="${OUT_DIR}/mutants/M${mutation_id}_${mutation_name}/${harness_label}"
  local goto_model="${result_dir}/M${mutation_id}_${harness_label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1
  local verification_failed="no"
  local expected_marker_failure="no"
  local no_body_failure="no"
  local detected="no"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    -DPA07_MUTATION_ID="${mutation_id}"
    "${harness}"
    "${MUTANT_SOURCE}"
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-07 MUTANT M${mutation_id}: ${mutation_name}"
  echo "Harness: ${harness_label}"
  echo "Expected low-level result: VERIFICATION FAILED"
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

    echo "Running expected-failure JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -q "VERIFICATION FAILED" "${result_dir}/cbmc_output.txt"; then
    verification_failed="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${expected_failure_marker}" "${result_dir}/cbmc_output.txt" | \
       grep -q "FAILURE"; then
    expected_marker_failure="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -q "no body for callee" "${result_dir}/cbmc_output.txt"; then
    no_body_failure="yes"
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 10 ] &&
     [ "${json_exit}" -eq 10 ] &&
     [ "${verification_failed}" = "yes" ] &&
     [ "${expected_marker_failure}" = "yes" ] &&
     [ "${no_body_failure}" = "no" ]; then
    detected="yes"
  fi

  {
    echo "mutation_id=${mutation_id}"
    echo "mutation_name=${mutation_name}"
    echo "harness=${harness_label}"
    echo "expected_failure_marker=${expected_failure_marker}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_failed=${verification_failed}"
    echo "expected_marker_failure_observed=${expected_marker_failure}"
    echo "no_body_failure_observed=${no_body_failure}"
    echo "mutant_detected=${detected}"
  } > "${result_dir}/summary.txt"

  cat "${result_dir}/summary.txt"

  if [ "${detected}" = "yes" ]; then
    return 0
  fi

  return 1
}

BASELINE_PA01="no"
BASELINE_PA02="no"

if run_baseline \
  "pa01_canonical_fips" \
  "${PA01_HARNESS}" \
  "P1_EXACT_SUM"; then
  BASELINE_PA01="yes"
fi

if run_baseline \
  "pa02_full_signed_valid" \
  "${PA02_HARNESS}" \
  "PA02_P1_EXACT_SIGNED_SUM"; then
  BASELINE_PA02="yes"
fi

DETECTED_PAIRS=0
ALL_MUTATIONS_OK="yes"
: > "${OUT_DIR}/mutation_status.txt"

for MUTATION_ID in 1 2 3 4 5; do
  case "${MUTATION_ID}" in
    1)
      MUTATION_NAME="subtract_instead_of_add"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    2)
      MUTATION_NAME="loop_starts_at_one"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    3)
      MUTATION_NAME="skip_final_coefficient"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    4)
      MUTATION_NAME="process_only_first_half"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    5)
      MUTATION_NAME="write_result_to_b"
      PA01_MARKER="P4_RIGHT_INPUT_FRAME"
      PA02_MARKER="PA02_P4_RIGHT_INPUT_FRAME"
      ;;
  esac

  PA01_DETECTED="no"
  PA02_DETECTED="no"

  if run_mutant \
    "${MUTATION_ID}" \
    "${MUTATION_NAME}" \
    "pa01_canonical_fips" \
    "${PA01_HARNESS}" \
    "${PA01_MARKER}"; then
    PA01_DETECTED="yes"
    DETECTED_PAIRS=$((DETECTED_PAIRS + 1))
  fi

  if run_mutant \
    "${MUTATION_ID}" \
    "${MUTATION_NAME}" \
    "pa02_full_signed_valid" \
    "${PA02_HARNESS}" \
    "${PA02_MARKER}"; then
    PA02_DETECTED="yes"
    DETECTED_PAIRS=$((DETECTED_PAIRS + 1))
  fi

  MUTATION_DETECTED="no"
  if [ "${PA01_DETECTED}" = "yes" ] &&
     [ "${PA02_DETECTED}" = "yes" ]; then
    MUTATION_DETECTED="yes"
  else
    ALL_MUTATIONS_OK="no"
  fi

  {
    echo "mutation_${MUTATION_ID}_name=${MUTATION_NAME}"
    echo "mutation_${MUTATION_ID}_pa01_detected=${PA01_DETECTED}"
    echo "mutation_${MUTATION_ID}_pa02_detected=${PA02_DETECTED}"
    echo "mutation_${MUTATION_ID}_detected_by_both=${MUTATION_DETECTED}"
  } >> "${OUT_DIR}/mutation_status.txt"
done

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${BASELINE_PA01}" = "yes" ] &&
   [ "${BASELINE_PA02}" = "yes" ] &&
   [ "${ALL_MUTATIONS_OK}" = "yes" ] &&
   [ "${DETECTED_PAIRS}" -eq 10 ]; then
  FINAL_STATUS="PA07_ALL_MUTANTS_DETECTED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "production_source_modified=no"
  echo "baseline_pa01_verified=${BASELINE_PA01}"
  echo "baseline_pa02_verified=${BASELINE_PA02}"
  echo "mutants_total=5"
  echo "mutant_harness_pairs=10"
  echo "detected_pairs=${DETECTED_PAIRS}"
  cat "${OUT_DIR}/mutation_status.txt"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-07 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA07_ALL_MUTANTS_DETECTED" ]; then
  echo
  echo "PA-07 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Both frozen harnesses accepted the production baseline."
  echo "Both frozen harnesses rejected every controlled mutant."
  echo "Production source remained unchanged."
else
  echo
  echo "PA-07 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

---

# Appendix C — Mutation Property Ledger

| Mutation | Defect | PA-01 designated property | PA-02 designated property | Result |
|---|---|---|---|---|
| M1 | subtraction instead of addition | exact sum | exact signed sum | Detected by both |
| M2 | loop starts at 1 | exact sum | exact signed sum | Detected by both |
| M3 | final coefficient skipped | exact sum | exact signed sum | Detected by both |
| M4 | only first half processed | exact sum | exact signed sum | Detected by both |
| M5 | write result to `b` | right-input frame | right-input frame | Detected by both |

---

# Appendix D — Campaign Acceptance Ledger

| Item | Expected outcome | PA-07 final-status implication |
|---|---|---|
| PA-01 production baseline | verification success | Satisfied |
| PA-02 production baseline | verification success | Satisfied |
| Mutant M1 with PA-01 | expected failure | Detected |
| Mutant M1 with PA-02 | expected failure | Detected |
| Mutant M2 with PA-01 | expected failure | Detected |
| Mutant M2 with PA-02 | expected failure | Detected |
| Mutant M3 with PA-01 | expected failure | Detected |
| Mutant M3 with PA-02 | expected failure | Detected |
| Mutant M4 with PA-01 | expected failure | Detected |
| Mutant M4 with PA-02 | expected failure | Detected |
| Mutant M5 with PA-01 | expected frame failure | Detected |
| Mutant M5 with PA-02 | expected frame failure | Detected |
| Production source modified | no | Satisfied |
| Final status | `PA07_ALL_MUTANTS_DETECTED` | Satisfied |

---

# Appendix E — Combined PA-01 Through PA-07 Summary

| Campaign | Main purpose | Result |
|---|---|---|
| PA-01 | canonical FIPS-domain correctness | Verified |
| PA-02 | complete signed contract-valid correctness | Verified |
| PA-03 | unrestricted exact-addition negative control | Expected counterexample confirmed |
| PA-04 | aliasing diagnostic and representability boundary | Confirmed |
| PA-05 | production call-site verification | Verified |
| PA-06 | cross-parameter replication | Verified |
| PA-07 | mutation sensitivity | All controlled mutants detected |

---

# Appendix F — Terminology

**Mutation testing:** Evaluation of a test or verification artefact by checking whether it rejects
deliberately defective program variants.

**Mutant:** A controlled defective implementation produced by a specified code change.

**Mutation score:** The proportion of selected mutants or mutant–harness pairs detected.

**Positive baseline:** The correct implementation used to confirm that the harness still succeeds.

**Killed mutant:** A mutant for which the verification harness produces a property failure.

**Surviving mutant:** A mutant that incorrectly satisfies the harness properties.

**Frame property:** A property specifying which objects must remain unchanged.

**Equivalent mutant:** A syntactically changed implementation that is semantically indistinguishable
under the analysed domain.
