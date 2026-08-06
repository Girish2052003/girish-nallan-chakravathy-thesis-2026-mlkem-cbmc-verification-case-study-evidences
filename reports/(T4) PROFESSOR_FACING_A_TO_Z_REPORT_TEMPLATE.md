# Professor-Facing Verification Record: `mlk_poly_sub` Canonical-Domain Theorem

## 1. Document status

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

This document records the design, execution, correction history, results, assurance boundary, and reproducibility evidence of the SUB00N Batch-4 verification campaign for `mlk_poly_sub`.

It is written as an engineering and research artefact. It does not claim universal correctness or world-first novelty.

**Repository commit:** `@@COMMIT@@`  
**Primary tool:** CBMC 6.9.0  
**Configuration:** ML-KEM-768, portable C, assembly disabled  
**Final campaign verdict:** `PASS`  
**Final accepted RUN4 package SHA-256:** `@@RUN4_HASH@@`

---

## 2. Package scope

This professor-facing package contains:

1. the four frozen Batch-4 harnesses;
2. the support headers and deterministic support source used to build the models;
3. the original production `poly.c` source binding;
4. the authoritative positive, coverage, companion, and negative-control GOTO models;
5. all Batch-4 preflight records;
6. all execution attempts, including failed runner designs;
7. both read-only diagnostics;
8. the accepted final execution;
9. the earlier successful SUB-T1 Mode-A parent harness, GOTO model, and result used to freeze the build methodology;
10. command records, JSON results, resource reports, manifests, and SHA-256 bindings;
11. the scripts used to generate, diagnose, and execute the campaign.

The package deliberately excludes the separately active Batch-3 campaign. No Batch-3 file is read, modified, copied, or represented as Batch-4 evidence.

The principal scientific scope is SUB-T4. The included SUB-T1 artefacts are parent-method evidence, not a replacement for every earlier campaign package.

---

## 3. Production function under verification

The target is the retained production implementation of `mlk_poly_sub` in the frozen `mlkem-native` source snapshot.

At coefficient level, the intended operation is:

\[
R_i = A_i - B_i.
\]

The verification did not substitute a handwritten implementation for the production body. The GOTO models retained the namespaced production function `mlk_sub00n_b4_poly_sub`.

The verification also did not use:

- function-contract abstraction for `mlk_poly_sub`;
- source-loop-contract abstraction;
- an alternative arithmetic model in place of the C body;
- production-source patches.

---

## 4. Research objective

The objective was to establish a precise bridge from the canonical ML-KEM coefficient domain to the low-level C arithmetic contract.

For every coefficient index \(i\), the precondition is:

\[
0 \leq A_i < 3329,
\qquad
0 \leq B_i < 3329.
\]

The required postconditions are:

\[
R_i = A_i - B_i,
\]

and:

\[
-3328 \leq R_i \leq 3328.
\]

A central design requirement was that signed 16-bit representability must be **derived from the canonical domain**, rather than assumed as a separate precondition.

---

## 5. Final theorem

For two separate valid polynomial objects containing canonical coefficients, after copying \(A\) into the destination and calling the retained production body:

```c
R = A;
mlk_poly_sub(&R, &B);
```

the following hold for all 256 coefficients:

1. `R.coeffs[i]` equals the mathematical integer difference `A.coeffs[i] - B.coeffs[i]`;
2. `R.coeffs[i]` lies in the tight interval `[-3328, 3328]`;
3. the mathematical difference is representable by `int16_t`;
4. the second input polynomial remains unchanged;
5. all selected safety properties pass under the frozen machine and build model.

The output interval is tight because both endpoints were independently shown reachable.

---

## 6. Assumptions and modelling commitments

### 6.1 Canonical coefficient domain

The positive theorem assumes only:

```text
0 <= A[i] < 3329
0 <= B[i] < 3329
```

The harness contains four direct domain assumptions per loop iteration: lower and upper bounds for the two input snapshots.

There is no direct assumption that the result already fits in `int16_t`.

### 6.2 Polynomial size and modulus

The model asserts:

```text
MLKEM_N == 256
MLKEM_Q == 3329
```

### 6.3 Machine model

The harness asserts:

```text
CHAR_BIT == 8
sizeof(int16_t) * CHAR_BIT == 16
sizeof(int32_t) * CHAR_BIT == 32
sizeof(void *) * CHAR_BIT == 64
```

The pointer-width assertion binds the result to the selected CBMC machine model.

### 6.4 Object separation

The destination and second input are separate local polynomial objects. Non-aliasing is therefore established by harness construction rather than by a symbolic aliasing assumption.

The theorem does not establish behaviour for every overlapping or invalid pointer topology.

### 6.5 Build configuration

The frozen production-body build uses:

```text
MLK_CONFIG_PARAMETER_SET=768
MLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00n_b4
MLK_CONFIG_NO_ASM=1
MLK_CONFIG_CUSTOM_ZEROIZE=1
```

The proof is a portable-C ML-KEM-768 result. It is not an assembly-equivalence result.

### 6.6 Loop completeness

Every reachable loop with a maximum of 256 iterations is explicitly unwound to 257, including the terminating condition.

Positive, companion, and negative-control verification enable unwinding assertions.

Coverage retains the identical explicit unwindset but omits explicit unwinding assertions because the installed CBMC coverage mode rejects their simultaneous use. Coverage loop completeness is supported by the separately passing companion proof.

---

## 7. Harness family

### 7.1 Positive canonical-domain harness

`sub_t4_canonical_domain_harness.c` proves:

- parameter binding;
- mathematical subtraction representability;
- exact equality between production output and mathematical difference;
- tight output range;
- unchanged second input;
- unchanged saved input snapshots;
- selected machine and runtime safety checks.

### 7.2 Reachability harness

`sub_t4_reachability_harness.c` records whether any coefficient produces:

1. maximum positive output `3328`;
2. maximum negative output `-3328`;
3. zero;
4. an interior positive value;
5. an interior negative value.

Five `__CPROVER_cover` goals are used only for coverage execution.

### 7.3 Upper negative-control harness

`sub_t4_invalid_upper_harness.c` fixes:

```text
A[0] = 3328
B[0] = 0
R[0] = 3328
```

It asserts the false stronger claim:

```text
R[0] <= 3327
```

The intended assertion fails and every other property succeeds.

### 7.4 Lower negative-control harness

`sub_t4_invalid_lower_harness.c` fixes:

```text
A[0] = 0
B[0] = 3328
R[0] = -3328
```

It asserts the false stronger claim:

```text
R[0] >= -3327
```

The intended assertion fails and every other property succeeds.

### 7.5 Cover-neutral companion model

The reachability harness cannot be checked as a normal proof model while unresolved `__CPROVER_cover` calls remain.

A separate derived companion model neutralizes only those five observational calls:

```c
#define __CPROVER_cover(condition) ((void)0)
```

This companion model is used only for safety, exactness, frame, and unwinding proof. It is not used as coverage evidence.

The original frozen reachability model remains the sole coverage model.

---

## 8. Distinctness from repository material

The Batch-4 harness family is distinct in two controlled senses.

### 8.1 Byte distinctness

The package audit compares each Batch-4 harness byte-for-byte against every source-repository file containing `mlk_poly_sub`.

No Batch-4 harness is byte-identical to any such repository file.

### 8.2 Theorem and marker distinctness

The source repository is searched for exact Batch-4 theorem, coverage, and negative-control markers.

The campaign-specific elements include:

- `SUB_T4_CANONICAL`;
- `SUB_T4_COV_EXACTNESS`;
- `SUB_T4_COV_FRAME`;
- `SUB_T4_NC1_INTENDED_FAILURE`;
- `SUB_T4_NC2_INTENDED_FAILURE`;
- the five named boundary-observation variables;
- dedicated false strengthened-bound controls.

The harness family is therefore independently authored and structurally distinct from repository material included in the frozen snapshot.

This does **not** establish that no similar theorem has ever appeared in any publication, repository, or private artefact. The safe claim is:

> Independently authored and repository-distinct CBMC artefacts for a canonical-domain bridge theorem.

No world-first claim is made.

---

## 9. Verification mode

The authoritative mode is Mode A:

- exact retained production bodies;
- no production-function abstraction;
- no source-loop-contract abstraction;
- complete explicit unwinding;
- unwinding assertions where compatible with analysis mode;
- selected runtime-safety checks;
- frozen GOTO binaries and commands;
- SHA-256-bound inputs and outputs.

Mode B is not the authoritative evidence for this theorem.

---

## 10. Selected CBMC checks

The proof commands enable:

```text
--object-bits 8
--bounds-check
--pointer-check
--pointer-overflow-check
--pointer-primitive-check
--signed-overflow-check
--unsigned-overflow-check
--conversion-check
--undefined-shift-check
--div-by-zero-check
--unwinding-assertions
--slice-formula
--sat-solver minisat2
--trace
--json-ui
```

Coverage uses the same model and explicit unwindset, together with:

```text
--cover cover
```

and omits explicit `--unwinding-assertions` because of the local CBMC coverage-mode compatibility rule.

---

## 11. Campaign chronology

### B4.0 — theorem preregistration

The theorem, assumptions, endpoint witnesses, expected-failure controls, and non-goals were frozen before execution. No CBMC run occurred.

### B4.1 — build-binding extraction

The relevant production source, reference harnesses, Mode-A manifests, and build references were identified. No CBMC run occurred.

### B4.2 — authoritative-parent comparison

Candidate parent evidence was compared and the authoritative Mode-A parent was selected. No CBMC run occurred.

### B4.3 — authoritative-parent freeze

The successful SUB-T1 parent harness, GOTO model, command structure, tool version, loop policy, and result were hash-bound. The selected SUB-T1 result contained 361 successful statuses and no failure statuses.

### B4.4 — harness-family freeze

Four harnesses and three support artefacts were generated, structurally validated, hashed, made read-only, and frozen. No GOTO model or theorem result was created.

### B4.5-v1 — failed loop-discovery preflight

The first preflight inspected loops in the full linked model and used an unanchored parser. Unreachable loops and a staging-path suffix were misclassified as reachable loop IDs.

This was a preflight-script defect, not a theorem failure. No solver result was produced.

### B4.5-v2 — corrected GOTO preflight

Unused functions were dropped in separate inspection models. Loop IDs were parsed only from explicit loop-declaration lines. Four authoritative models and four reachable-only inspection models were validated. Exact unwindsets were frozen. No solver result was produced.

### RUN1

The positive theorem passed:

```text
351 successful properties
0 failures
0 unwinding failures
```

The attempted coverage command combined `--cover cover` with explicit unwinding assertions. CBMC rejected the option combination before solving and emitted only a truncated JSON preamble.

RUN1 therefore contains one accepted positive result and one non-scientific usage error.

### B4.6 diagnostic

A read-only diagnostic established:

- coverage elapsed time `0.00` seconds;
- CBMC exit code `1`;
- only 50 bytes of incomplete JSON;
- zero property or coverage entries.

RUN1 remained unchanged.

### RUN2

RUN2 passed parent integrity and scientific binding, then stopped before any CBMC case because its script required a particular sentence in `cbmc --help`.

This was a brittle help-text gate, not a verification result.

### RUN3

The normal reachability companion attempt produced:

```text
333 successes
1 failure
0 unwinding failures
```

The single failure was:

```text
main.no-body.__CPROVER_cover
no body for callee __CPROVER_cover
```

No arithmetic, exactness, frame, bounds, overflow, or unwinding property failed.

### B4.7 diagnostic

The sole RUN3 failure was traced to the first unresolved `__CPROVER_cover` call. The diagnostic confirmed that substantive exactness, frame, model, bounds, and overflow properties succeeded.

### B4.8 — cover-neutral companion preflight

A separate companion model was created with the five cover observations neutralized.

The model retained:

- the production `mlk_poly_sub` body;
- three exact reachable loops;
- the explicit 257 unwindset;
- exactly 333 substantive properties;
- the exactness property;
- the unchanged-input frame property.

No solver result was created during B4.8.

### RUN4 — final accepted continuation

RUN4 completed all remaining obligations successfully.

---

## 12. Final results

| Evidence unit | Result |
|---|---:|
| Positive canonical-domain theorem | 351/351 PASS |
| Cover-neutral companion proof | 333/333 PASS |
| Coverage goals | 5/5 SATISFIED |
| Upper negative control | intended failure only |
| Lower negative control | intended failure only |
| Unwinding failures in proof/control runs | 0 |
| Unexpected failures | 0 |

The numbers 351 and 333 are CBMC property instances, including generated safety checks and harness assertions. They must not be described as 351 or 333 independently designed mathematical theorems.

---

## 13. Boundary reachability

The coverage model showed all five preregistered classes reachable:

```text
3328
-3328
0
an interior positive value
an interior negative value
```

The endpoint witnesses establish that the proved interval cannot be tightened to `[-3327,3327]`.

---

## 14. Expected-failure controls

Both false stronger claims were rejected exactly as preregistered.

Upper control:

```text
SUB_T4_NC1_INTENDED_FAILURE:
false stricter upper bound 3327
```

Lower control:

```text
SUB_T4_NC2_INTENDED_FAILURE:
false stricter lower bound -3327
```

Each produced:

```text
327 successes
1 intended failure
0 other failures
0 unwinding failures
```

These controls demonstrate that the verification configuration can detect deliberately false boundary claims.

---

## 15. Did this campaign prove `mlk_poly_sub` correct?

### 15.1 What is proved

Yes, `mlk_poly_sub` is proved correct **for the formal statement and assumptions in this package**.

The retained portable-C production body implements exact coefficientwise subtraction for all canonical ML-KEM input coefficients in the selected ML-KEM-768 configuration.

The result additionally proves:

- the tight raw range `[-3328,3328]`;
- signed 16-bit representability derived from the input domain;
- preservation of the separate second input object;
- selected memory, pointer, arithmetic, conversion, shift, division, and unwinding checks.

### 15.2 What is not proved

This package does not prove:

- correctness for arbitrary non-canonical `int16_t` inputs;
- behaviour for invalid pointers or every aliasing topology;
- assembly equivalence;
- constant-time behaviour;
- post-reduction canonicalization;
- serialization behaviour;
- correctness of the whole ML-KEM implementation;
- correctness under every compiler, architecture, or configuration;
- a theorem about cryptographic security in the reductionist sense.

The correct property-specific statement is:

> The selected production `mlk_poly_sub` implementation is correct with respect to canonical-domain coefficientwise subtraction, range, representability, frame, and selected safety properties under the frozen Mode-A model.

---

## 16. Why representability is a meaningful bridge result

The implementation stores coefficients in signed 16-bit objects, but the theorem does not assume that the subtraction result fits that type.

Instead:

\[
A_i \in [0,3328],
\qquad
B_i \in [0,3328]
\]

implies:

\[
A_i-B_i \in [-3328,3328].
\]

Since this interval is strictly inside:

\[
[-32768,32767],
\]

representability follows as a mathematical consequence.

This links the high-level ML-KEM coefficient domain to the low-level C storage model.

---

## 17. Integrity and reproducibility

The package preserves:

- frozen source and harness hashes;
- GOTO-model hashes;
- exact build and CBMC commands;
- exact loop identifiers;
- explicit unwindsets;
- CBMC JSON results;
- stderr and exit codes;
- resource usage;
- failed-attempt records;
- read-only diagnostics;
- final classifications;
- complete package manifests.

The final accepted execution package hash is:

```text
@@RUN4_HASH@@
```

The professor-facing ZIP receives its own SHA-256 sidecar after creation.

---

## 18. Failure transparency

The campaign does not hide failed scripts or reinterpret them as successful proofs.

Three non-final attempts are preserved:

1. a coverage option-usage error;
2. a brittle pre-execution help-text gate;
3. a companion-model mode mismatch caused by unresolved coverage observations.

Each was diagnosed without modifying the prior result directory.

The final accepted proof does not depend on deleting or overwriting those records.

---

## 19. Source and result immutability

The accepted campaign records:

```text
PRODUCTION_SOURCE_MODIFIED=NO
FROZEN_HARNESS_MODIFIED=NO
ORIGINAL_COVERAGE_MODEL_MODIFIED=NO
PRIOR_RUNS_MODIFIED=NO
BATCH3_TOUCHED=NO
SUB_T1_RESULT_MODIFIED=NO
SUB_T2_RESULT_MODIFIED=NO
```

The professor-facing package is a copied evidence bundle. It does not mutate frozen campaign artefacts.

---

## 20. Safe contribution statement

The defensible contribution description is:

> An independently authored, repository-distinct CBMC harness family and evidence chain proving a canonical-domain bridge theorem for the retained portable-C `mlk_poly_sub` production body.

The package does not claim that this is the first such theorem in global literature.

---

## 21. Thesis-ready result statement

For canonical ML-KEM coefficient inputs in \([0,3329)\), bounded model checking of the retained production `mlk_poly_sub` body established that every raw output coefficient equals the corresponding mathematical subtraction and lies in the tight interval \([-3328,3328]\). Signed 16-bit representability therefore follows from the input domain and was not introduced as a separate assumption. Dedicated coverage controls demonstrated both interval endpoints and representative zero, positive, and negative interior values. Expected-failure controls rejected the incorrectly strengthened bounds \([-3327,3327]\). The authoritative proof used complete explicit unwinding, retained production bodies, selected runtime-safety checks, and no production-function or source-loop-contract abstraction.

---

## 22. Evidence directory guide

- `00_PACKAGE_METADATA/` — package identity, scope, environment, and build record.
- `01_FROZEN_HARNESSES/` — all Batch-4 harnesses and support artefacts.
- `02_PRODUCTION_SOURCE_BINDING/` — copied production source and relevant headers.
- `03_PREFLIGHT_AND_MODELS/` — frozen harness family, original-model preflight, and companion preflight.
- `04_EXECUTION_RESULTS/` — complete RUN1–RUN4 execution history.
- `05_DIAGNOSTICS_AND_REPAIR_RECORDS/` — preregistration, comparisons, repair records, and diagnostics.
- `06_PARENT_MODE_A_REFERENCE/` — successful SUB-T1 parent harness, model, result, and binding records.
- `07_GENERATOR_AND_RUNNER_SCRIPTS/` — available scripts used to generate and execute the campaign.
- `08_AUDIT/` — evidence matrix, distinctness analysis, inventories, tree, and SHA-256 manifests.

---

## 23. Scope boundary of this professor package

This package is deliberately scoped to the Batch-4 canonical-domain campaign and the specific SUB-T1 parent evidence used by it.

It does not silently absorb the separately completed SUB-T2 package or the active Batch-3 campaign without a dedicated, separately reviewed binding step.

This prevents accidental mixing of independent evidence campaigns.

---

## 24. Recommended next proof work

The next planned property family is Batch 5:

- only the destination may change;
- the second input remains unchanged;
- coefficient \(i\) depends only on \(A_i\) and \(B_i\);
- changing coefficient \(j\) does not affect coefficient \(i\) for \(i \neq j\);
- no cross-coefficient interference;
- determinism.

A later Batch 6 will connect subtraction, reduction, and message serialization under a separately scoped theorem.

---

## 25. Final verdict

```text
SUB_T4_CANONICAL_DOMAIN_THEOREM=PROVED
SUB_T4_OUTPUT_RANGE=[-3328,3328]
SUB_T4_REPRESENTABILITY=DERIVED_NOT_ASSUMED
SUB_T4_SECOND_INPUT_FRAME=PROVED
SUB_T4_BOUNDARY_COVERAGE=5_OF_5
SUB_T4_FALSE_STRONGER_BOUNDS=REJECTED
BATCH4_COMBINED_VERDICT=PASS
```
