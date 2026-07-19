# ML-KEM-Native `mlk_poly_sub`: Clean-Room CBMC Verification Campaign

## Professor-Facing A-to-Z Technical Record

**Prepared by:** Girish Nallan Chakravathy  
**Case-study repository:** `mlkem-native`  
**Selected function:** `mlk_poly_sub`  
**Frozen repository commit:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Primary parameter set:** ML-KEM-768  
**Formal verification tool:** CBMC 6.9.0  
**Campaign date:** 17 July 2026  
**Document status:** Professor-facing evidence record after completion of SUB-T1, SUB-T2 and SUB-T3  
**Mutation status:** T1 mutation completed; T3 mutation intentionally deferred following supervisor direction

---

## 1. Purpose of this record

This report documents the complete clean-room CBMC campaign performed for the selected `mlk_poly_sub` implementation in `mlkem-native`. It records the source boundary, theorem families, assumptions, harnesses, model-building method, CBMC configuration, proof outcomes, coverage evidence, negative controls, mutation evidence already completed, execution anomalies, corrections, reproducibility information, novelty boundaries, and the exact strength of the final correctness claim.

The report is written as the technical record of the work itself. It is not a tutorial and does not treat a successful CBMC run as a universal correctness certificate. Every conclusion is restricted to the frozen source revision, build configuration, machine model, assumptions, parameter set, harness semantics and CBMC options recorded in the evidence package.

---

## 2. Executive conclusion

The campaign established property-specific correctness evidence for `mlk_poly_sub` and its selected composition with production reduction and addition operations.

The accepted results are:

1. **SUB-T1 semantic refinement:** the production `mlk_poly_sub` followed by production normalization agrees coefficient-wise with an independent mathematical subtraction-and-normalization oracle, under the frozen representability and object-validity assumptions.
2. **SUB-T2 normalization compatibility:** normalizing after subtraction agrees with subtracting already-normalized operands and normalizing again:

   \[
   N(A-B)=N(N(A)-N(B)).
   \]
3. **SUB-T3A exact right cancellation:** under representability of the initial subtraction,

   \[
   (A-B)+B=A.
   \]
4. **SUB-T3B exact left cancellation:** under representability of the initial addition,

   \[
   (A+B)-B=A.
   \]
5. **SUB-T3C modular cancellation:** under representability of the initial subtraction,

   \[
   N(N(A-B)+N(B))=N(A).
   \]
6. **Boundary evidence:** valid lower and upper representability boundaries succeeded; deliberately invalid lower and upper controls failed as preregistered.
7. **Non-vacuity:** T1 coverage reached 8/8 preregistered goals; T3 coverage reached 23/23 preregistered goals.
8. **Mutation sensitivity already completed for T1:** three selected mutants were killed, including an addition-instead-of-subtraction change, a skipped final coefficient and an altered oracle.
9. **No production-source accommodation:** the accepted proofs did not modify production `poly.c` to make the properties pass.
10. **Production-body execution:** the primary proof mode retained and executed the relevant production bodies rather than replacing them with function-contract summaries.

The correct overall claim is therefore:

> The frozen ML-KEM-768 portable-C implementation of `mlk_poly_sub` satisfies the proved semantic, normalization-compatibility, cancellation, boundary, safety and non-vacuity properties under the recorded assumptions and bounded machine model.

The incorrect overclaim would be:

> `mlk_poly_sub`, every caller, every architecture, every parameter set and all of ML-KEM are universally proved correct.

The campaign does not support that universal statement.

---

## 3. Frozen source and clean-room boundary

### 3.1 Repository identity

The production source was frozen at:

```text
d9613cf60de3132d32475c102d8c2781d84feb34
```

The principal source files used by the selected verification models were the repository’s production polynomial implementation and declarations, including `poly.c` and `poly.h`, with the portable C configuration enabled.

The recorded production hashes included:

```text
poly.c:
f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722

poly.h:
f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef
```

### 3.2 Clean-room source packet

The initial clean-room packet had SHA-256:

```text
e557c98ff5d3e3735d9f9f59c67a030e87ea0f4898b92d120856321a74ba7f45
```

Its source manifest recorded 341 tracked source entries. The clean-room path audit excluded proof, test, example and harness directories from the theorem-derivation input. The purpose was to derive candidate properties and harness structures from the production code and mathematical behavior rather than copying an existing repository proof harness.

### 3.3 Existing repository contract as baseline

The production repository already contained a local contract-level baseline for pointwise polynomial subtraction. That baseline was treated as an existing theorem boundary, not as the campaign’s new contribution. The relevant contract constrained valid polynomial objects, object separation where required, and representability of the pointwise result.

The campaign did not claim novelty for the elementary statement that the implementation performs coefficient-wise subtraction. Instead, the work extended the evidence into independently constructed semantic refinement, normalization compatibility, cancellation compositions, boundary classification, coverage and mutation-sensitive harnesses.

### 3.4 Clean-room integrity qualification

The harnesses were independently derived before the later inspection of repository proof-build metadata. Existing build metadata was used only to bind the independently derived theorem family to a known-good production compilation environment. The original repository proof harness was not used as the source of the new T3 theorem family.

This establishes a defensible **independent-derivation and artifact-distinctness claim**. It does not by itself establish worldwide literature novelty, patent novelty or priority. A final publication-grade novelty statement still requires a dedicated prior-art audit.

---

## 4. Verification environment

The accepted campaign environment was:

```text
Operating environment: Linux virtual machine
Architecture: x86_64
Byte order: little endian
CBMC: 6.9.0
goto-cc: 6.9.0, GCC-backed
GCC: 13.3.0
Python: 3.12.3
Language mode: C90
Parameter set: ML-KEM-768
Polynomial length N: 256
Modulus q: 3329
Assembly: disabled
Production configuration: portable C
```

The build used a unique namespace prefix for each proof case. This prevented symbol collisions and made the generated loop identifiers and production-function reachability case-specific.

---

## 5. Primary proof mode

The primary proof mode was production-body bounded execution.

It had the following characteristics:

- no theorem was accepted merely from a function-contract application;
- the relevant production `mlk_poly_sub`, `mlk_poly_add` and reduction bodies were retained when required by the harness;
- all relevant generated loops were identified from the GOTO model;
- exact unwind sets were frozen before authoritative theorem execution;
- `--unwinding-assertions` was enabled for ordinary theorem and safety runs;
- bounds, pointer, pointer-overflow, pointer-primitive, signed-overflow, unsigned-overflow, conversion, undefined-shift and division-by-zero checks were enabled;
- the SAT solver was `minisat2`;
- JSON results were retained for independent validation;
- source, harness, GOTO model, command and result identities were hashed.

This design prevents a proof from succeeding only because the implementation body was abstracted away.

---

## 6. Machine model and mathematical notation

For each coefficient index \(i\), the input polynomials are denoted \(A_i\) and \(B_i\).

The modulus is:

\[
q=3329.
\]

The normalization function \(N(x)\) denotes the canonical representative of \(x\) modulo \(q\) in:

\[
0 \leq N(x) < q.
\]

The independent T1-style oracle used a widened signed calculation:

```c
d = (int32_t)A[i] - (int32_t)B[i];
rem = d % 3329;
canonical = rem < 0 ? rem + 3329 : rem;
```

The result was compared against the production subtraction-and-reduction path rather than against a duplicated copy of the production algorithm.

---

## 7. Assumptions

The proofs are valid only under their frozen assumptions.

### 7.1 Object validity

All polynomial objects passed to the production functions were valid objects of the expected type and extent. The harnesses used the repository polynomial dimension of 256 coefficients.

### 7.2 Aliasing and separation

The exact aliasing and separation rules are those encoded in the frozen harnesses and the production contract. In particular, no broader aliasing guarantee should be inferred beyond the combinations actually admitted by the relevant harness.

### 7.3 Representability

The exact-cancellation and boundary families distinguish valid and invalid signed-result domains.

- T3A requires representability of the initial coefficient subtraction.
- T3B requires representability of the initial coefficient addition.
- T3C requires representability of the initial subtraction.
- T3C deliberately does **not** assume separate representability of the recovery addition after normalization.

For T3C, the normalized operands lie in:

\[
[0,q-1],
\]

so their sum lies in:

\[
[0,2q-2]=[0,6656],
\]

which is safely representable in the selected signed machine type.

### 7.4 Bounded loop completion

The polynomial loops were unwound with bounds sufficient to execute all 256 coefficients and then check termination. The principal polynomial-loop bounds were frozen at 257. Scalar helper loops were frozen at 2 where generated by the model.

### 7.5 Parameter and implementation scope

The accepted results apply to the frozen ML-KEM-768 portable-C configuration. They do not automatically transfer to assembly implementations, different source revisions, different compiler semantics, different parameter configurations or different machine models.

---

## 8. Harness inventory

The professor-facing package contains **19 unique C harness files** plus the shared T3 support header.

### 8.1 Original T1/T2 campaign harness family

```text
sub_t1_semantic_harness.c
sub_t2_relational_harness.c
sub_cov_reachability_harness.c
sub_boundary_valid_extremes_harness.c
sub_boundary_invalid_lower_harness.c
sub_boundary_invalid_upper_harness.c
```

### 8.2 T3 cancellation campaign harness family

```text
sub_t3a_exact_sub_add_harness.c
sub_t3a_valid_lower_harness.c
sub_t3a_valid_upper_harness.c
sub_t3a_invalid_lower_harness.c
sub_t3a_invalid_upper_harness.c

sub_t3b_exact_add_sub_harness.c
sub_t3b_valid_lower_harness.c
sub_t3b_valid_upper_harness.c
sub_t3b_invalid_lower_harness.c
sub_t3b_invalid_upper_harness.c

sub_t3c_modular_cancellation_harness.c
sub_t3c_recovery_sum_boundaries_harness.c
sub_t3_coverage_harness.c
sub_t3_common.h
```

The harness names are preserved exactly in the package.

---

## 9. SUB-T1: semantic refinement

### 9.1 Property

SUB-T1 checks that the production sequence:

```text
mlk_poly_sub
mlk_poly_reduce
```

agrees coefficient-wise with the independent widened subtraction-and-canonicalization oracle.

For each coefficient:

\[
R_i=N(A_i-B_i)
\]

and:

\[
0\leq R_i<3329.
\]

The domain is the full signed input domain admitted by the frozen production representability precondition, not merely canonical inputs.

### 9.2 Why this is stronger than a direct code restatement

The oracle was expressed using widened arithmetic and the mathematical remainder-to-canonical conversion. It was not implemented by calling the same production subtraction and reduction helpers on both sides of the comparison.

This reduces the risk of proving two identical copies of the same implementation error.

### 9.3 Safety and frame obligations

The T1 run included the enabled CBMC safety classes and complete loop unwinding. The harness also retained the source objects needed for checking the expected input/output relationship and associated frame conditions encoded in the frozen artifact.

### 9.4 Outcome

The accepted T1 execution reported:

```text
361/361 properties passed
unwinding failures: 0
```

The exact property inventory is retained in the T1 evidence directory.

---

## 10. T1 non-vacuity coverage

The T1 coverage campaign was executed separately from the ordinary safety proof.

The accepted result was:

```text
8/8 coverage goals reached
```

The coverage goals were designed to establish that the model admitted nontrivial positive, negative, zero, boundary and representative coefficient behavior rather than satisfying the theorem only because assumptions eliminated meaningful executions.

Coverage is not a proof of the theorem. It is evidence that the successful theorem was not trivially vacuous under the selected goals.

---

## 11. T1 mutation evidence

Three selected mutations were executed against the accepted T1 harness family:

1. the production subtraction operation was changed to addition;
2. the final coefficient was skipped;
3. the independent oracle was shifted by one.

The accepted outcome was:

```text
3/3 selected mutants killed
```

The mutation evidence strengthens the conclusion that the T1 harness can distinguish the intended implementation and oracle from representative incorrect variants.

This mutation result belongs to the completed T1 campaign. The separate T3 mutation campaign was later deferred following supervisor direction and is not represented as completed.

---

## 12. SUB-T2: normalization compatibility

### 12.1 Property

SUB-T2 checks the relational identity:

\[
N(A-B)=N(N(A)-N(B)).
\]

The left path uses the original operands, production subtraction and production normalization.

The right path first normalizes both operands, then performs production subtraction and normalizes the result.

The two canonical outputs must agree coefficient-wise and remain in:

\[
[0,3329).
\]

### 12.2 Significance

This property is not a duplicate of the local pointwise subtraction contract. It checks compatibility between subtraction and canonical modular representation across two distinct production-composition paths.

It therefore addresses a caller-relevant algebraic relationship: subtraction is consistent with changing operands to equivalent canonical representatives.

### 12.3 Outcome

The T2 relational case was accepted with complete safety and unwinding checks under its frozen assumptions.

The associated boundary campaign included:

```text
VALID_BOUNDARY
INVALID_LOWER
INVALID_UPPER
```

The valid extreme case succeeded. The lower and upper invalid-domain controls produced the preregistered rejection behavior.

---

## 13. Boundary interpretation

Boundary harnesses were divided into positive and negative controls.

### 13.1 Positive boundaries

A positive boundary harness supplies the lowest or highest still-valid representable case and requires the theorem and all safety obligations to succeed.

A passing positive boundary establishes that the theorem includes the edge of its stated valid domain.

### 13.2 Negative controls

A negative control intentionally violates a representability boundary and is expected to fail with the preregistered domain-rejection property.

A negative control is not a failed proof. It is a sensitivity check confirming that the harness does not silently accept inputs outside its theorem domain.

### 13.3 Interpretation rule

The final reports count positive theorem and valid-boundary cases separately from invalid controls. An expected exit code of 10 for a negative control is accepted only after checking that the intended central rejection is present and no unintended unwinding failure occurred.

---

## 14. SUB-T3 theorem family

The T3 family was preregistered before authoritative execution.

### 14.1 T3A: exact right cancellation

Under representability of the initial subtraction:

\[
(A-B)+B=A.
\]

This theorem checks a composition of production subtraction and production addition.

### 14.2 T3B: exact left cancellation

Under representability of the initial addition:

\[
(A+B)-B=A.
\]

This theorem checks the reverse production composition.

### 14.3 T3C: modular cancellation

Under representability of the initial subtraction:

\[
N(N(A-B)+N(B))=N(A).
\]

This theorem uses production subtraction, production reduction, production addition and a final production reduction, together with an independent modular semantic anchor.

### 14.4 T3C independent oracle

The independent FIPS-oriented oracle was expressed as an equivalent widened modular calculation using a positive shift:

\[
(A+10q)\bmod q.
\]

The shift keeps the oracle’s intermediate domain positive while remaining mathematically equivalent modulo \(q\). It is structurally separate from the production reduction implementation.

### 14.5 No recovery-add representability assumption

The T3C theorem intentionally omitted a separate assumption that the normalized recovery addition is representable. Instead, that fact was derived from:

\[
0\leq N(A-B)\leq q-1
\]

and:

\[
0\leq N(B)\leq q-1.
\]

Therefore:

\[
0\leq N(A-B)+N(B)\leq 2q-2=6656.
\]

This is a useful proof result in its own right: the recovery addition is safe because of the established normalized ranges.

---

## 15. T3 case matrix and outcome

The frozen T3 suite contains 13 cases:

### 15.1 Positive theorem cases

```text
T3A_EXACT
T3B_EXACT
T3C_MODULAR
```

### 15.2 Positive boundary cases

```text
T3A_VALID_LOWER
T3A_VALID_UPPER
T3B_VALID_LOWER
T3B_VALID_UPPER
T3C_SUM_BOUNDARIES
```

### 15.3 Negative controls

```text
T3A_INVALID_LOWER
T3A_INVALID_UPPER
T3B_INVALID_LOWER
T3B_INVALID_UPPER
```

### 15.4 Coverage case

```text
T3_COVERAGE
```

### 15.5 Final result

```text
OVERALL_VERDICT=PASS_COMPLETE_T3_CAMPAIGN
COMPLETED_CASES=13/13
POSITIVE_CASES_PASSED=8/8
NEGATIVE_CONTROLS_PASSED=4/4
COVERAGE_GOALS_REACHED=23/23
T3A_EXACT=PASS_ALL_PROPERTIES_SUCCESS
T3B_EXACT=PASS_ALL_PROPERTIES_SUCCESS
T3C_MODULAR=PASS_ALL_PROPERTIES_SUCCESS
ALL_FINAL_VALIDATIONS_PASS=YES
```

---

## 16. T3 production reachability and unwind sets

Each T3 preflight model was validated before execution.

The central cases retained the required production bodies:

- T3A: production subtraction and addition;
- T3B: production addition and subtraction;
- T3C: production subtraction, addition and reduction helpers.

The exact generated loop identifiers were obtained from the GOTO model and frozen into the final commands. No unknown loop category was silently assigned an unwind bound.

The central T3C unwind set included:

```text
main.0:257
main.1:257
main.2:257
main.3:257
main.4:257
mlk_barrett_reduce.0:2
mlk_sub00o_t3c_poly_add.0:257
mlk_sub00o_t3c_poly_sub.0:257
mlk_poly_reduce_c.0:257
mlk_poly_reduce_c.1:257
mlk_scalar_signed_to_unsigned_q.0:2
mlk_scalar_signed_to_unsigned_q.1:2
```

The package retains the exact case-specific commands and model records for all 13 T3 cases.

---

## 17. T3 coverage

The T3 coverage harness generated exactly:

```text
main.coverage.1
...
main.coverage.23
```

All 23 preregistered conditions were confirmed in the property inventory and reached in the dedicated coverage execution.

The goals included signs of operands and differences, zero behavior, noncanonical representatives, valid subtraction and addition boundaries, first and last coefficient activity, recovery-sum boundaries, and both wrapped and nonwrapped recovery paths.

The accepted result was:

```text
23/23 coverage goals reached
```

---

## 18. Coverage intrinsic classification

During the initial T3 result workflow, the coverage harness was also invoked in ordinary safety mode. CBMC 6.9.0 reported:

```text
PROPERTY=main.no-body.__CPROVER_cover
DESCRIPTION=no body for callee __CPROVER_cover
```

This was not a production-code safety counterexample. It occurred because `__CPROVER_cover` is a coverage intrinsic interpreted by the dedicated `--cover cover` mode, not an ordinary production function.

The final validator therefore classified that exact coverage-intrinsic result as non-applicable to the production safety claim and relied on the separate authoritative coverage execution for reachability.

No pointer, bounds, arithmetic, conversion or unwinding failure was hidden by this correction.

---

## 19. Validation defects discovered and corrected

The campaign preserves its execution mistakes rather than erasing them.

### 19.1 GOTO validation command defect

An early preflight used `goto-instrument --validate-goto-model` with only an input argument. The installed version required an input and an output. The run stopped before theorem execution and was superseded by a new immutable preflight directory.

### 19.2 Coverage-marker defect

An early preflight searched the generated property inventory for the source spelling `__CPROVER_cover`. CBMC generated property identifiers named `main.coverage.N`. The gate was corrected to require exactly 23 consecutive identifiers and the exact 23 conditions.

### 19.3 Property-count validator defect

The first authoritative result validator incorrectly compared:

- the preflight assertion inventory; and
- the larger execution property inventory that included automatically generated safety properties.

For example, a central case could legitimately contain 351 execution properties while its preflight assertion inventory contained 63.

The expensive CBMC runs had:

```text
RAW_EXIT=0
FAILURE_COUNT=0
UNWINDING_FAILURE_COUNT=0
```

but were initially mislabelled because the validator required the two different counts to be equal.

### 19.4 Validator-only correction

The corrected validation reused the original JSON results and invoked no CBMC theorem again:

```text
VALIDATOR_ONLY_REPAIR=YES
ORIGINAL_CBMC_RESULTS_REUSED=YES
CBMC_REEXECUTED=NO
```

The original erroneous summaries remain in the evidence history. The corrected validator and its manifest are included in the professor-facing package.

---

## 20. Distinctness from the repository’s existing proof material

The new harness family is distinct in the following defensible senses.

### 20.1 Theorem-level distinctness

The repository’s elementary local subtraction contract is not the same theorem as:

- full subtraction-and-normalization semantic refinement;
- normalization compatibility;
- exact right cancellation;
- exact left cancellation;
- modular cancellation;
- recovery-add range derivation;
- dedicated valid and invalid boundary classifications;
- multipath non-vacuity coverage.

### 20.2 Artifact-level distinctness

The campaign introduced new clean-room harness files, new independent oracles, new case matrices, new coverage goals, new negative controls, new exact model-binding records and a new professor-facing evidence structure.

### 20.3 Composition-level distinctness

T2 and T3 reason across sequences of production functions. A local function contract alone does not establish these caller-relevant composition identities.

### 20.4 Independent-oracle distinctness

The T1 and T3C semantic anchors use widened mathematical calculations rather than simply reusing the same production path as the expected result.

### 20.5 What is not claimed

The package does not claim that no equivalent theorem has ever appeared anywhere in the literature. It claims independent derivation, repository-artifact distinctness and explicit theorem-composition distinctness. A stronger novelty claim requires a separate systematic prior-art review.

---

## 21. Did the campaign prove that `mlk_poly_sub` is correct?

### 21.1 Answer

Yes, for the frozen property families and assumptions.

The campaign proved that the selected production function behaves correctly with respect to:

- the independent modular subtraction oracle after normalization;
- canonical output range;
- normalization compatibility;
- exact cancellation where the initial operation is representable;
- modular cancellation;
- selected valid domain boundaries;
- detection of selected invalid boundaries;
- the enabled memory and arithmetic safety checks;
- complete execution of the bounded polynomial loops;
- representative non-vacuity goals.

### 21.2 What remains outside the proof

The following are not established by this package:

- all of ML-KEM;
- all callers of `mlk_poly_sub`;
- all future source revisions;
- all parameter sets;
- assembly implementations;
- every compiler and architecture;
- side-channel resistance or constant-time behavior;
- concurrency properties;
- fault resistance;
- correctness under aliasing patterns not admitted by the harnesses;
- liveness or termination outside the bounded loops already checked;
- universal scientific novelty.

The accurate thesis wording is therefore **comprehensive property-specific evidence for the selected function**, not universal total correctness.

---

## 22. Relationship between T1, T2 and T3

The three families form a progression.

### T1: implementation-to-mathematics

T1 asks whether the production subtraction-and-reduction result equals an independent mathematical oracle.

### T2: representation independence

T2 asks whether changing operands to canonical representatives preserves the canonical subtraction result.

### T3: algebraic composition

T3 asks whether production subtraction, addition and reduction compose according to exact and modular cancellation laws.

Together they provide stronger evidence than any single harness:

- T1 anchors the implementation to the intended mathematics.
- T2 checks consistency across equivalent operand representations.
- T3 checks caller-relevant algebraic compositions.
- coverage checks that meaningful paths are admitted.
- boundaries check the exact theorem domain.
- mutation evidence checks sensitivity to representative defects.

---

## 23. Harness trustworthiness controls

The campaign used the following controls against weak or vacuous verification:

1. source and harness hashes;
2. clean-room theorem derivation;
3. production-body reachability checks;
4. exact loop extraction;
5. unwinding assertions;
6. safety instrumentation;
7. independent mathematical oracles;
8. positive boundaries;
9. negative controls;
10. dedicated coverage goals;
11. T1 mutation testing;
12. immutable superseding directories after failed preflights;
13. JSON result retention;
14. independent post-execution validation;
15. final package manifests.

No single control is sufficient alone. The strength comes from their combination.

---

## 24. Production source modification policy

The accepted proof campaign did not alter the production implementation to force the candidate theorems to pass.

Adapters were used only to establish the selected portable verification environment, including namespace binding, fail-closed zeroization binding and verification pragma scope. These adapters did not replace the polynomial arithmetic bodies under proof.

Where mutants were used, they were isolated copies in mutation-specific directories and were never substituted for the accepted production source in the positive proof result.

---

## 25. T1/T2/T3 evidence directory map

The professor-facing ZIP is assembled into a dedicated directory with the following structure:

```text
00_REPORT/
01_SOURCE_AND_CLEAN_ROOM/
02_HARNESSES/
    T1_T2_BASELINE/
    T3_CANCELLATION/
03_T1_SEMANTIC_PROOF/
04_T1_COVERAGE_AND_MUTATION/
05_T2_RELATIONAL_AND_BOUNDARIES/
06_T3_CANCELLATION_PROOF/
07_REPRODUCIBILITY/
08_MANIFESTS/
```

The package includes accepted proof directories rather than only copying the final summary lines. Raw commands, GOTO models, property inventories, JSON outputs, model records and manifests are retained where available.

---

## 26. Chronology of the campaign

### SUB00A — clean-room acceptance

- frozen repository commit recorded;
- source manifest frozen;
- clean-room exclusions checked;
- environment recorded.

### SUB00F — primary execution freeze

- production-body proof mode frozen;
- base harness family frozen;
- build adapters frozen.

### SUB00G — T1 preflight

- corrected pragma-scoped production build;
- exact production reachability and loop configuration frozen.

### SUB00H — T1 authoritative execution

- 361/361 properties passed;
- no unwinding failure.

### SUB00I — T1 non-vacuity

- 8/8 goals reached.

### SUB00J and SUB00K — T1 mutation campaign

- three mutation models frozen;
- 3/3 selected mutants killed.

### SUB00L — T2 and boundaries

- relational normalization-compatibility theorem executed;
- valid boundary accepted;
- lower and upper invalid controls accepted as expected rejections.

### SUB00M — T3 preregistration

- T3A, T3B and T3C fixed before execution;
- assumptions and mutation plan recorded;
- no theorem execution.

### SUB00N — T3 harness freeze

- 13 C harnesses and one common header frozen;
- static design validation passed.

### SUB00O-R5 — T3 model preflight

- all 13 GOTO models built and validated;
- production bodies reachable;
- exact loop IDs and unwind sets frozen;
- 23 coverage conditions identified exactly;
- no theorem execution.

### SUB00P — T3 authoritative execution

- original JSON theorem and coverage results generated;
- original post-validator defect identified.

### SUB00P-R3 — validator-only correction

- original CBMC results reused;
- no theorem reexecution;
- complete T3 campaign accepted.

### SUB00Q — complete T3 suite freeze

- 13-case T3 suite packaged;
- suite manifest verified;
- production source and frozen harnesses unchanged.

### SUB00S — professor-facing package

- all accepted T1, T2 and T3 harnesses and evidence assembled;
- this A-to-Z report included;
- dedicated ZIP and SHA-256 generated.

---

## 27. Deferred work

The following work is intentionally not represented as completed:

- T3 mutation execution, deferred after supervisor guidance;
- cross-parameter replication for ML-KEM-512 and ML-KEM-1024;
- assembly-path verification;
- caller-level decryption applicability;
- side-channel analysis;
- final publication-grade literature novelty audit;
- universal proof of every `mlk_poly_sub` caller.

These are possible extensions, not prerequisites for reporting the completed T1–T3 campaign accurately.

---

## 28. Thesis contribution interpretation

The technical contribution is not merely “CBMC returned success.”

The contribution is the controlled workflow that:

1. derived candidate theorem families from a frozen production implementation;
2. separated existing repository guarantees from new composition claims;
3. encoded independent oracles and caller-relevant relations;
4. froze assumptions before execution;
5. retained production bodies;
6. established exact bounded completeness for the relevant loops;
7. added non-vacuity, boundary and mutation controls;
8. preserved failed attempts and corrected validators transparently;
9. produced a reproducible evidence package suitable for human review.

This aligns with a human-in-the-loop AI-assisted formal-artifact workflow: the LLM assists in proposing and constructing candidate artifacts, while CBMC supplies the formal result and the human-controlled evidence process determines what may be claimed.

---

## 29. AI-use transparency

AI assistance was used to support property discovery, harness drafting, proof-plan construction, script generation, result parsing and documentation.

AI output was not treated as the proof authority.

The authoritative evidence came from:

- frozen production source;
- frozen assumptions and harnesses;
- generated GOTO models;
- CBMC execution;
- coverage results;
- negative controls;
- mutation results already completed;
- independent result validation;
- SHA-256 manifests.

Errors in generated validation scripts were identified from the raw evidence and corrected without concealing the failed attempts. This is an important observed failure mode for the thesis: an LLM-generated validator can misclassify a correct formal-tool result even when the underlying theorem run is sound.

---

## 30. Threats to validity

### 30.1 Internal validity

The principal internal threats are harness mistakes, shared-oracle mistakes, vacuity, wrong loop bounds, function-body abstraction and result-parser defects. The campaign mitigated these through independent oracles, production reachability, coverage, negative controls, mutation evidence, unwinding assertions and raw JSON retention.

### 30.2 Construct validity

The properties are meaningful but do not exhaust every notion of correctness. They were chosen to cover implementation semantics, canonical representation and algebraic composition.

### 30.3 External validity

The result is tied to the frozen ML-KEM-768 portable-C configuration. Generalization to other configurations requires replication.

### 30.4 Novelty validity

Repository-artifact distinctness and clean-room derivation are evidenced. Worldwide literature novelty remains a separate research question.

### 30.5 Tool validity

CBMC 6.9.0 and its selected machine model are part of the theorem statement. A different tool version or architecture may generate different models or loop identifiers.

---

## 31. Reproduction principle

A reviewer should be able to reconstruct the accepted result by using:

1. the frozen commit;
2. the retained production source hashes;
3. the exact harness;
4. the exact adapters;
5. the exact namespace and compiler definitions;
6. the frozen GOTO model or build command;
7. the exact unwind set;
8. the exact CBMC flags;
9. the raw JSON result;
10. the independent summary and manifest.

The professor-facing ZIP retains these materials in dedicated evidence directories.

---

## 32. Final status ledger

```text
SOURCE_COMMIT=d9613cf60de3132d32475c102d8c2781d84feb34
PARAMETER_SET=768
N=256
Q=3329
CBMC=6.9.0

SUB_T1_SEMANTIC=PASS
SUB_T1_PROPERTIES=361/361
SUB_T1_COVERAGE=8/8
SUB_T1_MUTANTS_KILLED=3/3

SUB_T2_NORMALIZATION_COMPATIBILITY=PASS
SUB_T2_VALID_BOUNDARY=PASS
SUB_T2_INVALID_LOWER=PASS_EXPECTED_REJECTION
SUB_T2_INVALID_UPPER=PASS_EXPECTED_REJECTION

SUB_T3_TOTAL_CASES=13/13
SUB_T3_POSITIVE_CASES=8/8
SUB_T3_NEGATIVE_CONTROLS=4/4
SUB_T3_COVERAGE=23/23
SUB_T3A=PASS
SUB_T3B=PASS
SUB_T3C=PASS

PRODUCTION_SOURCE_MODIFIED=NO
FROZEN_HARNESS_MODIFIED=NO
T3_MUTATION_EXECUTED=NO
T3_MUTATION_STATUS=DEFERRED_BY_SUPERVISOR_DIRECTION
```

---

## 33. Final claim for supervisor review

The completed work provides reproducible, assumption-explicit and non-vacuity-supported CBMC evidence that the frozen ML-KEM-768 portable-C `mlk_poly_sub` implementation satisfies the selected semantic refinement, normalization compatibility and cancellation properties, including valid-domain boundaries and selected invalid-domain rejection controls.

The new harness family is independently derived and distinct from the repository’s elementary local subtraction contract in theorem structure, composition scope, oracle design, boundary design and coverage architecture. The strongest defensible originality wording is **clean-room independently derived, repository-distinct composition verification artifacts**. A worldwide “never previously existed” claim is not made without a dedicated prior-art audit.

The result supports describing `mlk_poly_sub` as correct for the proved comprehensive property set under the recorded assumptions. It does not support claiming universal correctness of all ML-KEM code or every possible use context.

---

## 34. Package integrity

The professor-facing builder generates:

```text
SUB00S_PROFESSOR_FACING_MLK_POLY_SUB_EVIDENCE_V1/
SUB00S_PROFESSOR_FACING_MLK_POLY_SUB_EVIDENCE_V1.zip
SUB00S_PROFESSOR_FACING_MLK_POLY_SUB_EVIDENCE_V1.zip.sha256
```

The package directory contains a complete SHA-256 inventory. The ZIP hash is intended to be recorded in the thesis experiment log and shared together with the archive.

---

**End of professor-facing A-to-Z technical record.**
