# CANON CBMC Campaign: Complete A-to-Z Verification Record

**Target implementation:** `pq-code-package/mlkem-native`  
**Pinned commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Primary target:** `mlk_scalar_signed_to_unsigned_q`  
**Composition target:** `mlk_barrett_reduce`  
**Verification tool:** CBMC 6.9.0  
**Primary executed parameter configuration:** `MLKEM_K=3` (ML-KEM-768 build configuration)  
**Campaign date:** July 2026  
**Final campaign classification:** **ACCEPTED**

---

## Document purpose

This record documents the complete CANON verification campaign conducted for the
mlkem-native implementation of signed-to-unsigned canonical coefficient conversion.
It records the target and source binding, mathematical model, theorem selection,
harness construction, assumptions, actual-body verification policy, non-vacuity
coverage, mutation analysis, evidence integrity controls, final results, novelty
assessment, claim boundary, and reproducibility identifiers.

The record is written as a technical account of the work performed. It is not a
tutorial and does not treat CBMC success alone as sufficient evidence. Acceptance was
conditioned on the combined result of:

1. immutable source and intent binding;
2. actual production-body execution;
3. explicit semantic assertions;
4. safety instrumentation;
5. separate non-vacuity coverage;
6. targeted production-source mutations;
7. deterministic worktree comparison;
8. authoritative-source revalidation; and
9. cryptographic evidence manifests and compact packages.

---

# 1. Executive conclusion

The CANON campaign verified a repository-distinct, implementation-specific
characterization of `mlk_scalar_signed_to_unsigned_q` at mlkem-native commit
`af4c5abdd5958bdc65a03cd5ee86708264f93304`.

The campaign comprised four preregistered theorem families:

| Family | Semantic focus | Properties | Coverage goals | Mutants killed | Status |
|---|---:|---:|---:|---:|---|
| CANON-T1 | Exact fibres and equivalence classes | 4 | 8 | 3 | ACCEPTED |
| CANON-T2 | Retraction, idempotence, fixed points and injectivity | 4 | 8 | 3 | ACCEPTED |
| CANON-T3 | Modular addition, subtraction and negation compatibility | 3 | 11 | 3 | ACCEPTED |
| CANON-T4 | Actual-body Barrett reduction and normalization composition | 6 | 14 | 3 | ACCEPTED |
| **Total** |  | **17** | **41** | **12** | **ACCEPTED** |

The aggregate result was:

```text
ACCEPTED_THEOREM_FAMILIES=4
REGISTERED_SEMANTIC_PROPERTIES=17
PASSED_SEMANTIC_PROPERTIES=17
NONVACUITY_COVERAGE_GOALS=41
SATISFIED_COVERAGE_GOALS=41
TARGETED_PRODUCTION_MUTANTS=12
KILLED_PRODUCTION_MUTANTS=12
ACTUAL_TARGET_BODY_VERIFIED=YES
ACTUAL_BARRETT_BODY_VERIFIED=YES
TARGET_CONTRACT_REPLACEMENT=NO
BARRETT_CONTRACT_REPLACEMENT=NO
DFCC=NO
PRODUCTION_SOURCE_MODIFIED=NO
CAMPAIGN_FINAL_CLASSIFICATION=ACCEPTED
```

The result supports the following bounded claim:

> At mlkem-native commit
> `af4c5abdd5958bdc65a03cd5ee86708264f93304`, CBMC 6.9.0
> verified the 17 preregistered CANON semantic properties for the actual-body
> implementation of `mlk_scalar_signed_to_unsigned_q` and its actual-body scalar
> composition with `mlk_barrett_reduce`, under the recorded domains, build
> configuration, C-semantics assumptions, and tool limitations. All 41
> non-vacuity goals were reachable, and all 12 targeted production-source mutants
> were rejected.

This does **not** mean that every conceivable property of the function, the whole
ML-KEM implementation, or the complete polynomial reduction routine has been proved.

---

# 2. Terminology and exact target

## 2.1 The target is not a function named `poly_canon`

The pinned mlkem-native source does not define a production function called
`poly_canon` or `mlk_canon`. The primary target was the file-local scalar helper:

```c
static MLK_INLINE int16_t mlk_scalar_signed_to_unsigned_q(int16_t c)
```

The source describes it as a constant-time conversion from signed representatives
in:

\[
[-(q-1), q-1]
\]

to unsigned representatives in:

\[
[0,q-1].
\]

The target is used in `mlk_poly_reduce_c` after `mlk_barrett_reduce` is applied to
each coefficient.

Throughout this record:

- \(q = 3329\);
- \(D = \{-3328,\ldots,3328\}\), the legal scalar input domain;
- \(U = \{0,\ldots,3328\}\), the unsigned canonical set;
- \(F(c)\) denotes the actual body of `mlk_scalar_signed_to_unsigned_q(c)`;
- \(B(a)\) denotes the actual body of `mlk_barrett_reduce(a)`;
- \(C(a) = F(B(a))\) denotes the production scalar composition used by
  `mlk_poly_reduce_c`;
- `canon_q(z)` denotes an independent mathematical modulo-\(q\) oracle returning
  the unique representative in \(U\).

## 2.2 Source-level implementation

At the pinned commit, the target implementation is:

```c
c = mlk_ct_sel_int16(
    (int16_t)(c + MLKEM_Q),
    c,
    mlk_ct_cmask_neg_i16(c));
```

Under its legal domain, this implements:

\[
F(c)=
\begin{cases}
c+q, & c<0,\\
c, & c\ge 0.
\end{cases}
\]

The source contract already states:

```c
requires(c > -MLKEM_Q && c < MLKEM_Q)
ensures(return_value >= 0 && return_value < MLKEM_Q)
ensures(return_value ==
        (int32_t)c + (((int32_t)c < 0) * MLKEM_Q))
```

This source contract is important to the novelty assessment: the elementary
conditional-add semantics were not invented by this campaign. The contribution was
the independent, actual-body characterization and evaluation of those semantics
through multiple relational theorem families, coverage, mutation, and evidence
controls.

---

# 3. Source and environment binding

## 3.1 Immutable source identity

The authoritative repository was bound to:

```text
Repository path:
  /home/girish/THESIS-2026/mlkem-native_af4c5abd

Pinned commit:
  af4c5abdd5958bdc65a03cd5ee86708264f93304

Authoritative mlkem/src/poly.c SHA-256:
  f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722

Frozen source archive SHA-256:
  bb9a092da93f9ce24f16c6fe66c641869ac06362dd0d951161bff3a041804f47
```

The source commit and `poly.c` hash were checked before and after each accepted
campaign stage.

## 3.2 Tool configuration

The authoritative theorem runs used:

```text
CBMC version: 6.9.0
Backend: CBMC default SAT backend
MLKEM_K: 3
Object bits: 8
Formula slicing: enabled
Bounds checking: enabled
Pointer checking: enabled
Pointer-overflow checking: enabled
Conversion checking: enabled
Signed-overflow checking: enabled
Unsigned-overflow checking: enabled
Division-by-zero checking: enabled
Float-overflow checking: enabled
NaN checking: enabled
Counterexample traces: enabled
```

Coverage companions were run with:

```text
cbmc --cover cover <coverage.goto>
```

The coverage warning:

```text
--cover is incompatible with --unwinding-assertions,
so unwinding-assertions will be defaulted to false
```

was recorded. The target and oracle contain no theorem-relevant loops, and coverage
was used only to establish reachability of selected input classes and witnesses.

## 3.3 Recorded CBMC 6.9.0 limitations

CANON-00C accepted the environment with recorded tool limitations. The default SAT
backend was retained as authoritative because experimental validator/SMT2 paths
encountered CBMC 6.9.0 issues unrelated to the target theorem, including a
non-target namespace/model-validation abort. These issues were not converted into
proof claims, silently ignored, or used to classify a failed theorem as successful.

The accepted status used throughout the campaign was:

```text
CANON00C_CLASSIFICATION=
ACCEPTED_WITH_RECORDED_CBMC_6_9_0_TOOL_LIMITATIONS
```

---

# 4. Campaign design and trust boundary

## 4.1 Clean-room theorem design

The theorem families were designed as new theorem-bearing harnesses rather than
translations of the native mlkem-native harness. Production source was read to
understand the implementation, its contracts, legal domains, and dependencies, but
the new assertions were selected to characterize additional semantic structure.

The core design rules were:

1. do not alter the authoritative production source;
2. do not copy the target body into the harness;
3. do not replace theorem-bearing function calls with contracts;
4. do not enforce the target contract as the theorem;
5. do not use DFCC for the theorem-bearing calls;
6. use the actual body of `mlk_scalar_signed_to_unsigned_q`;
7. use the actual body of `mlk_barrett_reduce` in T4;
8. place theorem assertions and coverage goals in separate binaries;
9. use explicit legal-domain assumptions rather than `assume(false)` or
   over-constrained witnesses;
10. use an independent `int32_t` modulo oracle where an oracle was required;
11. verify property registration in the GOTO binary before running CBMC;
12. verify the absence of contract wrappers and forbidden transformations;
13. run targeted mutation analysis against frozen harnesses; and
14. revalidate the authoritative source after every final campaign.

## 4.2 Why CBMC success was not treated as self-authenticating

A successful `VERIFICATION SUCCESSFUL` line can be misleading if:

- the harness is unreachable;
- the assumptions are contradictory;
- the target body has been removed;
- the call is replaced by a contract;
- the assertion is tautological;
- the assertion merely restates an assumed condition;
- the wrong source snapshot is compiled; or
- the theorem does not distinguish plausible implementation defects.

The campaign therefore required four independent evidence layers:

### Positive theorem layer

The actual implementation had to satisfy the registered semantic properties and
instrumented safety checks.

### Non-vacuity layer

A separate coverage binary had to exhibit reachable representatives of the semantic
regions used by the theorem.

### Mutation-sensitivity layer

The frozen theorem harness had to reject targeted, exactly validated changes to
disposable copies of the production source.

### Integrity layer

Source hashes, frozen artefact hashes, GOTO binding, worktree identity, final
manifests, and package hashes had to remain consistent.

---

# 5. Preregistration and preliminary stages

## 5.1 CANON-00A: source and native-proof reconnaissance

The preliminary reconnaissance established:

- the exact production implementation;
- the target domain and output range;
- the target's use inside `mlk_poly_reduce_c`;
- the presence of an upstream `barrett_reduce` proof;
- the absence, at the pinned commit, of an eponymous
  `scalar_signed_to_unsigned_q` proof directory;
- the native repository's contract-oriented CBMC architecture; and
- the difference between a boilerplate native harness and a theorem-bearing
  characterization harness.

## 5.2 CANON-00B: immutable verification intent and theorem registry

The theorem campaign was preregistered before the final proof batches.

Key hashes were:

```text
CANON-00B manifest:
  76b72bed8cb4c0f8e2acda8d24e71e15461991280cd90370738f3a8746e1e523

verification_intent.json:
  1bd6f2cd995a15edbd4722a23ec6854f168ce0a54a5570bc887ae2a9dc74880e

theorem_registry.md:
  435afec5bace6b0c55ffb96c522d6be793d04d909961e7339c36429ded91aa52

property_registry.tsv:
  4cab12dff6c4537bea0dd5706da223a1fc21a873478e21fb3310bae73825d862

freeze record:
  609ac7edbd049aa7404715855ed181b46893932a3371cd7c49605323f3319a0b
```

Preregistration prevented the theorem families from being rewritten after observing
counterexamples or successful results.

## 5.3 CANON-00C: tool and execution-policy acceptance

CANON-00C established the accepted CBMC 6.9.0 execution path and recorded the
limitations described in Section 3.3. The SAT-backed result, not a failing validator
or unsupported experimental path, was treated as authoritative.

---

# 6. CANON-T1: exact fibres and equivalence classes

## 6.1 Purpose

T1 establishes the complete preimage structure of \(F\) on the legal signed domain.
It answers:

- exactly when two signed representatives map to the same unsigned representative;
- exactly which inputs map to zero; and
- exactly which inputs map to each nonzero canonical value.

This is stronger and more explanatory than proving only that the output lies in
\([0,q)\).

## 6.2 Properties

For \(x,y,c\in D\) and \(1\le u<q\):

### CANON-T1.P1: collision necessity

\[
F(x)=F(y)
\Longrightarrow
x-y\in\{-q,0,q\}.
\]

### CANON-T1.P2: collision sufficiency

\[
x-y\in\{-q,0,q\}
\Longrightarrow
F(x)=F(y).
\]

### CANON-T1.P3: exact zero fibre

\[
F(c)=0
\Longleftrightarrow
c=0.
\]

### CANON-T1.P4: exact nonzero fibres

\[
F(c)=u
\Longleftrightarrow
(c=u)\lor(c=u-q).
\]

## 6.3 Why these properties are correct

Because \(F\) either leaves a nonnegative input unchanged or adds exactly one
modulus to a negative input, two legal inputs can collide only when they are equal
or differ by one modulus. The domain width is less than \(2q\), so no difference of
\(2q\) is possible.

Zero has only one legal preimage: \(0\). For every nonzero \(u\in U\), the two legal
representatives are \(u\) and \(u-q\).

Together P1-P4 give an exact description of every fibre of \(F\), not merely a
range fact.

## 6.4 Supporting controls and coverage

The theorem harness contained:

```text
Semantic assertions: 4
Supporting output-range controls: 3
```

The positive run reported:

```text
0 of 36 failed
VERIFICATION SUCCESSFUL
```

The separate coverage companion reached:

```text
8 of 8 covered (100.0%)
```

Coverage included:

- negative, zero, and positive input classes;
- all three collision differences \(-q,0,q\);
- the positive representative \(u\); and
- the negative representative \(u-q\).

## 6.5 Mutation analysis

Three exact one-statement production mutations were used:

| Mutant | Production change | T1 semantic detections observed |
|---|---|---|
| M1 identity | removed negative correction | P2 and P4 failed |
| M2 \(q-1\) correction | added the wrong modulus to negative inputs | P1, P2, P3 and P4 failed |
| M3 reversed selector | reversed selector operands | P2, P3 and P4 failed |

All three mutants produced CBMC exit code 10 and `VERIFICATION FAILED`.

```text
KILLED_MUTANT_COUNT=3
TOTAL_MUTANT_COUNT=3
MUTATION_CLASSIFICATION=PASS
T1_FINAL_CLASSIFICATION=ACCEPTED
```

## 6.6 T1 recovery event

The first mutation script searched for a production line without accounting for the
explicit `(int16_t)` cast in the pinned source. The search failed before a partial
authoritative result was accepted.

A second issue arose from using `diff -qr` across extracted repository trees. The
repository contains example-tree copies or links of `mlkem/src/poly.c`, so a raw path
count reported 11 additional `poly.c` differences even though only the intended
production content had changed.

The final R2 process replaced the fragile count with relative-path SHA-256 manifests
excluding only `mlkem/src/poly.c` and generated build directories. It verified:

```text
BASELINE_MANIFEST_ENTRY_COUNT=1223
M1 non-poly manifest identity=PASS
M2 non-poly manifest identity=PASS
M3 non-poly manifest identity=PASS
```

All four non-poly manifests had the same SHA-256:

```text
115c96a66c93b92e4594a447d49272d1774fd7624799649945be4574450a306e
```

This recovery is evidence of a stricter process, not a theorem failure. The
authoritative source was never modified.

## 6.7 T1 final evidence

```text
Frozen harness manifest:
  068a1e7fa62f3203202b7ec63238fc61706c2832dfa4addcd95097468b427867

Final evidence manifest:
  9aed04738c9093f4d7bccb784b770bde0fa7bf84e9b4c9eae5790d1b5d075b10

Final package:
  CANON_T1_FINAL_EVIDENCE_af4c5abd.tar.gz

Package SHA-256:
  47b4adb28bcac7265ca4fdc8be407136bc5450ae49f5cc49ce5b750c3624f47f
```

---

# 7. CANON-T2: retraction and normalization dynamics

## 7.1 Purpose

T2 changes perspective from preimages to normalization behavior. It establishes that
\(F\) is a retraction from \(D\) onto \(U\), identifies its fixed points, proves
stability under repeated normalization, and proves that no two distinct canonical
values are merged.

## 7.2 Properties

For \(u,v\in U\) and \(c\in D\):

### CANON-T2.P1: canonical retraction

\[
F(u)=u.
\]

### CANON-T2.P2: normalization idempotence

\[
F(F(c))=F(c).
\]

### CANON-T2.P3: exact fixed-point characterization

\[
F(c)=c
\Longleftrightarrow
c\ge 0.
\]

### CANON-T2.P4: canonical-set injectivity

\[
F(u)=F(v)
\Longrightarrow
u=v.
\]

## 7.3 Why these properties are correct

Every value in \(U\) is nonnegative, so the implementation's conditional addition
selects the original value. Therefore \(F\) is the identity on \(U\).

Because the first application always returns an element of \(U\), a second
application cannot change it. This proves idempotence.

A legal negative input is changed by adding \(q\), while a legal nonnegative input is
unchanged. Hence the exact fixed points are the nonnegative inputs.

The identity action on \(U\) immediately yields injectivity on the canonical set.

## 7.4 Why T2 was not redundant with T1

T1 and T2 are logically related, but they answer different verification questions.

- T1 characterizes equivalence classes and preimages.
- T2 characterizes the function as a normalization operator.

T2 provides the concepts needed to reason about repeated use, stable storage,
canonical-state preservation, and downstream operations that may normalize already
canonical data.

## 7.5 Positive result and coverage

The positive theorem run reported:

```text
SEMANTIC_SUCCESS_COUNT=4
CONTROL_SUCCESS_COUNT=4
0 of 35 failed
VERIFICATION SUCCESSFUL
```

The coverage companion reached:

```text
8 of 8 covered (100.0%)
```

Coverage included:

- canonical endpoints \(0\) and \(q-1\);
- negative, zero, and positive domain inputs;
- an idempotence witness;
- equal canonical inputs; and
- distinct canonical inputs.

## 7.6 Mutation analysis

T2 used theorem-specific mutations rather than mechanically reusing every T1 mutant.

| Mutant | Purpose | Required T2 detection |
|---|---|---|
| M1 identity normalization | makes negative inputs false fixed points | P3 |
| M2 swap canonical 0 and 1 | destroys retraction and repeat stability | P1 and P2 |
| M3 collapse to zero | destroys canonical-set injectivity | P4 |

All three were killed under the frozen T2 harness.

```text
TOTAL_MUTANT_COUNT=3
KILLED_MUTANT_COUNT=3
MUTATION_CLASSIFICATION=PASS
T2_FINAL_CLASSIFICATION=ACCEPTED
```

## 7.7 T2 final evidence

```text
Positive evidence manifest:
  5e9fa0926d30e7ed6bddfff459da89b1a14b44f0c1173894cdc7c353256b9cf9

Frozen harness manifest:
  af6c194ff671b2e87bb958333bf29c058e8c67a84faa04eba4479d25564e8fdc

Final evidence manifest:
  e1e12900f1c218e4aab65b8abf28c0489d381e34a11c74295cfa16db593b2e19

Final package:
  CANON_T2_FINAL_EVIDENCE_af4c5abd.tar.gz

Package SHA-256:
  dccfffb368458b6b96f378f2d1dfcf38b2b0c3c7e5169928134de49346c1ff51
```

---

# 8. CANON-T3: modular-operation compatibility

## 8.1 Purpose

T1 and T2 establish what the normalization map is and how it stabilizes. They do not
yet establish that it behaves consistently with modular arithmetic operations.

T3 proves compatibility with addition, subtraction, and negation when the direct
result remains inside the legal input domain of \(F\).

## 8.2 Independent oracle

T3 introduced:

```c
static int16_t canon_q_i32(int32_t value)
{
    int32_t remainder = value % (int32_t)MLKEM_Q;

    if (remainder < 0)
    {
        remainder += (int32_t)MLKEM_Q;
    }

    return (int16_t)remainder;
}
```

This oracle:

- uses `int32_t` arithmetic;
- uses `% MLKEM_Q`;
- does not use `mlk_ct_sel_int16`;
- does not use `mlk_ct_cmask_neg_i16`;
- does not reproduce the target's conditional-selection code; and
- provides an implementation-independent comparison within the harness.

## 8.3 Properties

For \(x,y\in D\):

### CANON-T3.P1: modular addition compatibility

When \(x+y\in D\):

\[
F(x+y)=\operatorname{canon}_q(F(x)+F(y)).
\]

### CANON-T3.P2: modular subtraction compatibility

When \(x-y\in D\):

\[
F(x-y)=\operatorname{canon}_q(F(x)-F(y)).
\]

### CANON-T3.P3: modular negation compatibility

\[
F(-x)=\operatorname{canon}_q(-F(x)).
\]

Negation remains inside \(D\) because \(D\) is symmetric.

## 8.4 Why these properties are correct

The target returns the unique member of \(U\) congruent to its input modulo \(q\).
Addition, subtraction, and negation preserve congruence classes. Therefore the
canonical representative obtained after the operation is the same as the canonical
representative obtained after operating on the already canonical inputs.

The direct-call side of P1 and P2 is restricted to results in \(D\) because the
production function's precondition is \(-q<c<q\). The oracle side can use wider
`int32_t` arithmetic.

## 8.5 Why T3 was necessary after T2

T2 proves only unary normalization behavior. It does not prove that the implementation
can be soundly used around modular addition, subtraction, or negation.

T3 closes that gap by establishing algebraic compatibility. This is useful for
reasoning about code transformations, coefficient arithmetic, and the replacement of
signed representatives by unsigned canonical representatives.

## 8.6 Positive result and coverage

The theorem run reported:

```text
SEMANTIC_SUCCESS_COUNT=3
CONTROL_SUCCESS_COUNT=8
NO_BODY_FAILURE_COUNT=0
THEOREM_EXIT=0
VERIFICATION SUCCESSFUL
```

The coverage companion reached:

```text
11 of 11 covered (100.0%)
```

Coverage included:

- negative, zero, and positive addition results;
- addition wrapping exactly at \(q\);
- negative, zero, and positive subtraction results;
- a subtraction case with \(F(x)<F(y)\);
- negative, zero, and positive negation classes.

## 8.7 Mutation analysis

T3 used:

| Mutant | Defect |
|---|---|
| M1 identity normalization | omits negative correction |
| M2 \(q-1\) correction | uses the wrong modulus |
| M3 swap canonical 0 and 1 | corrupts canonical representatives |

The final mutation gate required each mutant to be detected by all three T3
properties. All three were killed.

```text
TOTAL_MUTANT_COUNT=3
KILLED_MUTANT_COUNT=3
MUTATION_CLASSIFICATION=PASS
T3_FINAL_CLASSIFICATION=ACCEPTED
```

## 8.8 T3 final evidence

```text
Positive evidence manifest:
  a863251e9326c35236e6e07f329a5eccff17168259627807a4a9df93ae86c691

Frozen harness manifest:
  0ec763179f9333b5debda80fdaaa0fa76ca4b7fed59704e3a76e4ac0541d1c3e

Final evidence manifest:
  26c5222cf511b93c1dddd17f0b254314f0c37aacbd1e32301bd639b94060375a

Final package:
  CANON_T3_FINAL_EVIDENCE_af4c5abd.tar.gz

Package SHA-256:
  71a1267dc4bcf00e660f44984e105ca0befb557cbff7f1538962c77792343488
```

---

# 9. CANON-T4: actual-body Barrett composition

## 9.1 Purpose

T4 was essential because T1-T3 begin with inputs already inside \(D\). Production
coefficient values are not always already in that narrow range. In
`mlk_poly_reduce_c`, the code first calls `mlk_barrett_reduce` and then calls
`mlk_scalar_signed_to_unsigned_q`.

T4 verifies the actual scalar production composition:

\[
C(a)=F(B(a))
\]

for unrestricted `int16_t` inputs.

This is the integration bridge between:

- the upstream reduction body;
- the normalizer's legal-domain precondition;
- the unsigned canonical result; and
- the per-coefficient operation used by `mlk_poly_reduce_c`.

## 9.2 Properties

### CANON-T4.P1: Barrett-to-normalizer domain bridge

For every `int16_t` \(a\):

\[
-q < B(a) < q.
\]

The production source specifies an even tighter centered interval, but T4.P1 proves
the exact bridge needed to call \(F\).

### CANON-T4.P2: full-int16 canonicalization

For every `int16_t` \(a\):

\[
C(a)=\operatorname{canon}_q(a).
\]

### CANON-T4.P3: composition modular congruence

For every `int16_t` \(a\):

\[
C(a)\equiv a\pmod q.
\]

The harness asserted:

```c
((int32_t)ca - (int32_t)a) % (int32_t)MLKEM_Q == 0
```

### CANON-T4.P4: representable \(q\)-periodicity

For \(k\in\{-1,+1\}\), when \(a+kq\) is representable as `int16_t`:

\[
C(a+kq)=C(a).
\]

### CANON-T4.P5: agreement with direct normalization on \(D\)

For \(c\in D\):

\[
C(c)=F(c).
\]

### CANON-T4.P6: composition idempotence

For every `int16_t` \(a\):

\[
C(C(a))=C(a).
\]

## 9.3 Why T4 was necessary after T3

Stopping after T3 would have left four important gaps.

### Gap 1: legal-domain establishment

T1-T3 assume inputs satisfy \(-q<c<q\). They do not prove that the production
Barrett reducer establishes this condition.

### Gap 2: full `int16_t` behavior

T1-T3 characterize the normalizer only on \(D\). T4 proves the complete
Barrett-normalizer composition for all 65,536 `int16_t` values symbolically.

### Gap 3: actual integration

T3 proves algebraic compatibility of \(F\), but not the behavior of the real
production sequence \(F(B(a))\).

### Gap 4: native contract-composition dependence

The native `mlk_poly_reduce_c` proof architecture can reason compositionally through
function contracts. T4 deliberately requires both actual bodies and independently
checks the composition.

Without T4, the campaign would have characterized a helper but not closed the
production-use integration boundary.

## 9.4 Positive result and coverage

The body-binding audit reported:

```text
TARGET_HITS=205
BARRETT_HITS=33
MASK_HITS=29
SELECTOR_HITS=48
WRAPPER_HITS=0
TARGET_CONTRACT_HITS=0
BARRETT_CONTRACT_HITS=0
T4_PROPERTY_HITS=6
ORACLE_BODY_HITS=20
COMPOSITION_BODY_HITS=39
```

The theorem run reported:

```text
SEMANTIC_SUCCESS_COUNT=6
CONTROL_SUCCESS_COUNT=5
0 of 60 failed
VERIFICATION SUCCESSFUL
```

The coverage companion reached:

```text
14 of 14 covered (100.0%)
```

Coverage included:

- `INT16_MIN`;
- `INT16_MAX`;
- negative, zero, and positive Barrett outputs;
- canonical outputs \(0\) and \(q-1\);
- a nontrivial congruence witness;
- both periodicity directions \(k=-1\) and \(k=+1\);
- negative, zero, and positive direct-domain agreement; and
- composition idempotence.

## 9.5 Mutation analysis

T4 used component-specific mutations:

| Mutant | Mutated component | Required T4 detection |
|---|---|---|
| M1 Barrett identity | `mlk_barrett_reduce` | P1 |
| M2 Barrett constant zero | `mlk_barrett_reduce` | P2 and P3 |
| M3 normalizer identity | `mlk_scalar_signed_to_unsigned_q` | P2 and P5 |

All three were killed.

```text
TOTAL_MUTANT_COUNT=3
KILLED_MUTANT_COUNT=3
MUTATION_CLASSIFICATION=PASS
T4_FINAL_CLASSIFICATION=ACCEPTED
```

## 9.6 T4 final evidence

```text
Positive evidence manifest:
  4cc2c39bacf8d3f211c92b31991e447ca88f39fe50382d9ad7bb00dd282dea8b

Frozen harness manifest:
  42d5abf07b818b0e0b5d111dda847d759ad105e67747f83093c2a342aac0a41b

Final evidence manifest:
  50560a7ac638773875b66f35418cd0aa9d9ba0c9afcc0b0aa58d1d7eb069cafe

Final package:
  CANON_T4_FINAL_EVIDENCE_af4c5abd.tar.gz

Package SHA-256:
  20e9394f1af995219fdd38b083c7a6c8480bed5489874de5d6c7276f17c40f4d
```

---

# 10. Why exactly four theorem families were selected

The theorem count was deliberately nominal. The target is small, and the wider thesis
must cover additional functions. A large number of narrowly fragmented assertions
would inflate the experiment without adding proportionate explanatory value.

Four families were selected because they form a natural assurance ladder.

## 10.1 T1: extensional characterization

T1 answers:

> Which inputs produce which outputs?

It gives the exact fibres and equivalence classes.

## 10.2 T2: normalization-operator behavior

T2 answers:

> How does the function behave as a canonicalization operator?

It establishes retraction, fixed points, idempotence, and injectivity on the canonical
set.

## 10.3 T3: algebraic compatibility

T3 answers:

> Does the canonicalization behave consistently around modular operations?

It covers addition, subtraction, and negation.

## 10.4 T4: production integration

T4 answers:

> Does the actual upstream Barrett body establish the normalizer domain, and does the
> actual composition canonicalize the full machine input range correctly?

It closes the integration gap.

## 10.5 Why the campaign did not stop at T2

T1 and T2 establish a strong unary characterization, but no compatibility with
arithmetic operations. A defect could preserve range, fixed points, and idempotence
while still corrupting residue-class behavior. T3 was therefore necessary.

## 10.6 Why the campaign did not stop at T3

T3 still assumes that direct calls to \(F\) stay inside \(D\). It does not prove the
actual production preprocessor, `mlk_barrett_reduce`, establishes that domain. It
also does not prove canonicalization for arbitrary `int16_t` inputs. T4 was therefore
necessary.

## 10.7 Why no T5 was added

The preregistered T1-T4 structure already covers:

- exact mapping structure;
- normalization dynamics;
- modular compatibility; and
- actual production composition.

Additional families would likely repeat consequences of these properties or drift
into a full-array `mlk_poly_reduce_c` campaign, which is a different target with
loop, memory, and frame obligations. Ending at T4 preserved a defensible,
non-inflated experiment and left capacity for other thesis functions.

---

# 11. Assumptions

The accepted proof is conditional on the following assumptions and scope decisions.

## 11.1 Source assumption

The theorem applies to the exact source at:

```text
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

No claim is automatically transferred to earlier or later commits.

## 11.2 ML-KEM modulus

The campaign uses:

\[
q=3329,
\]

as defined by ML-KEM and the pinned implementation.

## 11.3 Target precondition

Direct calls to \(F\) assume:

\[
-q<c<q.
\]

This is the production contract and corresponds exactly to:

\[
c\in\{-3328,\ldots,3328\}.
\]

## 11.4 C integer model

The proof uses the integer widths and C semantics represented by the recorded CBMC
build. Oracles use `int32_t` arithmetic to avoid accidentally reproducing
`int16_t` overflow behavior.

## 11.5 Signed right-shift portability assumption

The production `mlk_barrett_reduce` source explicitly notes that right shift of a
negative signed integer is implementation-defined in C and assumes a sign-preserving
arithmetic right shift. T4 therefore proves the implementation under the source's
recorded portability assumption and CBMC's modeled semantics; it is not a proof for
every hypothetical C implementation with a different signed-shift behavior.

## 11.6 Parameter configuration

The campaign was executed with `MLKEM_K=3`. The target functions depend on the shared
modulus rather than the vector dimension \(k\), and \(q=3329\) is common to all three
ML-KEM parameter sets. Nevertheless, this campaign did not independently rerun the
full evidence stack with `MLKEM_K=2` and `MLKEM_K=4`; cross-configuration transfer is
an implementation-based inference, not an additional executed result.

## 11.7 Periodicity representability

T4.P4 assumes \(a\pm q\) is representable as `int16_t`. The theorem does not treat
integer wraparound as modular-\(q\) periodicity.

## 11.8 Tool soundness and bounded-model assumptions

The conclusion relies on CBMC 6.9.0's translation and SAT solving for the generated
GOTO model. The theorem-relevant target and oracle paths contain no unbounded loops.
The result remains a machine-checked software-verification claim, not an independent
proof of CBMC's own soundness.

---

# 12. Actual-body verification evidence

For every final family, the build policy was inspected before execution.

The following transformations were forbidden:

```text
--enforce-contract
--replace-call-with-contract
--dfcc
--apply-loop-contracts
```

The GOTO model was inspected for:

- the target function name;
- `mlk_ct_cmask_neg_i16`;
- `mlk_ct_sel_int16`;
- the absence of `wrapped_for_contract_checking`;
- the absence of target contract symbols; and
- the exact number of registered theorem properties.

T4 additionally required:

- `mlk_barrett_reduce`;
- the absence of a Barrett contract replacement;
- the independent oracle body; and
- the composition helper body.

This does not mean contracts were deleted from the production source. It means the
theorem-bearing calls were not discharged merely by replacing the actual
implementation with their contracts.

---

# 13. Non-vacuity design

Each theorem family had a separate coverage-only companion.

The theorem harness contained assertions and no coverage goals.

The coverage harness contained coverage goals and no theorem assertions.

This separation avoided treating a coverage witness as a theorem and made the
following questions explicit:

- Can a negative input reach the target?
- Can zero and positive inputs reach the target?
- Can both members of a nonzero fibre be realized?
- Can both periodicity directions be realized?
- Can boundary machine inputs reach the actual composition?
- Can equal and distinct canonical inputs occur?
- Can all relevant output sign classes occur?

All 41 registered coverage goals were satisfied.

Coverage does not prove the theorem; it rejects a major class of vacuity and
over-constraint errors.

---

# 14. Mutation methodology

## 14.1 Why mutations were required

A property suite that passes the correct program but also passes obvious incorrect
programs may be too weak, incorrectly bound, or vacuous.

Mutation analysis therefore asked:

> Does the frozen theorem suite reject plausible defects in the exact production
> statement or component under examination?

## 14.2 Mutation isolation

Each mutant was created in a disposable extracted source worktree.

For every mutant:

- the authoritative repository remained unchanged;
- the source started from the same source-tar hash;
- the frozen theorem harness was copied unchanged;
- exactly one production statement was replaced;
- the exact removed and added line counts were checked;
- all non-`mlkem/src/poly.c` content was compared by relative-path SHA-256
  manifests;
- the mutant GOTO binary was rebuilt;
- actual-body and property binding were rechecked; and
- CBMC had to fail a registered semantic property.

## 14.3 Interpretation

Mutation killing does not prove completeness against every possible defect. It
provides empirical evidence that:

- the target body was materially connected to the theorem;
- the assertions were not tautologies;
- the assumptions did not eliminate all defect-revealing inputs; and
- each family had sensitivity to defects aligned with its stated purpose.

---

# 15. Did the campaign prove `mlk_scalar_signed_to_unsigned_q`?

## 15.1 What was proved

Yes, within the exact campaign boundary, the actual implementation was proved to
satisfy the 17 registered T1-T4 semantic properties.

The evidence supports all of the following:

1. exact collision structure on \(D\);
2. exact zero and nonzero fibres;
3. identity on \(U\);
4. idempotent normalization;
5. exact fixed points;
6. injectivity on \(U\);
7. modular addition compatibility under the direct-call domain;
8. modular subtraction compatibility under the direct-call domain;
9. modular negation compatibility;
10. actual Barrett output establishing the normalizer domain;
11. full-`int16_t` canonicalization through \(F(B(a))\);
12. modular congruence of the composition;
13. representable \(q\)-periodicity;
14. agreement between composition and direct normalization on \(D\); and
15. idempotence of the complete composition.

The count is 17 because several numbered items above group related formal
properties.

## 15.2 What “correct” means here

The function is correct **with respect to the registered specification**, not
absolutely correct in every imaginable sense.

The campaign did not prove:

- generated-machine-code constant-time behavior;
- compiler preservation of constant-time behavior;
- side-channel resistance;
- correctness for inputs outside the production precondition when calling \(F\)
  directly;
- correctness of every caller;
- correctness of the complete ML-KEM algorithm; or
- every possible mathematical property of canonicalization.

---

# 16. Did the campaign prove polynomial canonicalization?

This question requires a strict distinction.

## 16.1 If “poly canon” means the scalar mathematical kernel

If “poly canon” refers informally to the per-coefficient operation used by
`mlk_poly_reduce_c`, then **yes**: T4 proved the actual scalar composition

\[
C(a)=F(B(a))
\]

for every `int16_t` coefficient and proved that it equals the independent canonical
modulo-\(q\) oracle.

This is a strong result because `mlk_poly_reduce_c` applies exactly this composition
to each polynomial coefficient.

## 16.2 If “poly canon” means the entire `mlk_poly_reduce_c` function

Then **no, not as a new end-to-end actual-body array theorem in this campaign**.

The CANON harnesses did not directly prove all of the following for the complete
256-coefficient routine:

- loop progress;
- all array accesses;
- frame conditions for untouched memory;
- per-index update locality;
- whole-polynomial postcondition;
- pointer validity and non-aliasing; and
- all coefficients simultaneously through the actual loop body.

The native mlkem-native source and CBMC framework already contain loop and contract
annotations for `mlk_poly_reduce_c`, including a whole-array output-range
postcondition. That native evidence is separate from the new CANON theorem
campaign.

The precise statement is therefore:

> The campaign proved the actual scalar canonicalization kernel used at every
> iteration of `mlk_poly_reduce_c`, including the actual Barrett-normalizer
> composition for all `int16_t` coefficient values. It did not independently replace
> the repository's whole-array `mlk_poly_reduce_c` proof with a new full-loop
> actual-body functional-correctness harness.

This distinction must be preserved in the thesis and in discussion with the
supervisor.

---

# 17. Difference from the native mlkem-native CBMC harnesses

## 17.1 Native proof architecture

The pinned repository's CBMC README states that:

- the proof infrastructure targets absence of certain classes of undefined
  behavior;
- specifications are embedded in production C as contracts and loop annotations;
- the per-function harnesses are boilerplate and do not add specification content;
  and
- each proved function normally has an eponymous proof directory.

The upstream `barrett_reduce_harness.c` contains only an unconstrained input, a call
to `mlk_barrett_reduce`, and a returned value. It has no theorem-specific assertions.

The upstream `barrett_reduce/Makefile` sets:

```make
CHECK_FUNCTION_CONTRACTS=mlk_barrett_reduce
APPLY_LOOP_CONTRACTS=on
USE_DYNAMIC_FRAMES=1
CBMCFLAGS=--smt2
```

At the pinned commit, the proof-directory list includes `barrett_reduce`, but no
eponymous directory named `scalar_signed_to_unsigned_q`.

## 17.2 CANON architecture

The CANON harnesses differ materially:

| Dimension | Native style at pinned commit | CANON campaign |
|---|---|---|
| Specification location | embedded production contracts | new theorem assertions in clean-room harnesses |
| Target harness | boilerplate call | relational, multi-call semantic harness |
| Scalar target directory | no eponymous directory observed | four complete theorem families |
| Barrett proof | checks its embedded contract | T4 composes actual Barrett and normalizer bodies |
| Contract replacement | central to compositional workflow | forbidden for theorem-bearing calls |
| Independent oracle | not present in boilerplate harness | `int32_t` modulo oracle in T3/T4 |
| Non-vacuity | not the defining native harness role | separate coverage binaries |
| Mutation analysis | not part of the inspected native harness | 12 exact production mutants |
| Source integrity | ordinary repository workflow | commit, file, tree, manifest, and package hashes |
| Claim | memory/type-safety and contracts | implementation-specific semantic characterization |

## 17.3 No copied production algorithm

Static audits checked that the harnesses did not copy:

- `mlk_ct_sel_int16`;
- `mlk_ct_cmask_neg_i16`;
- the target conditional-add expression;
- Barrett's magic constant and shift implementation; or
- the production target body.

The oracle used ordinary `int32_t` remainder arithmetic. Calling a production
function is not copying its implementation.

## 17.4 No production-body modification for the positive theorem

The authoritative source hash before and after every final campaign was:

```text
f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722
```

Mutations existed only in disposable evidence worktrees and were explicitly marked
as non-authoritative.

---

# 18. Novelty verification

## 18.1 Verification method

The novelty assessment used the following evidence as of 28 July 2026:

1. inspection of `mlkem/src/poly.c` at the exact pinned commit;
2. inspection of the `proofs/cbmc` directory at that commit;
3. inspection of the native CBMC README;
4. inspection of the native `barrett_reduce_harness.c`;
5. inspection of the native `barrett_reduce/Makefile`;
6. exact public searches for `mlk_scalar_signed_to_unsigned_q`;
7. searches combining the target name with “CBMC”, “theorem”, and
   “verification”;
8. searches for the exact CANON theorem phrases and property labels;
9. review of public descriptions of mlkem-native's CBMC methodology; and
10. review of general CBMC and ML-KEM primary sources.

## 18.2 Findings supporting distinctness

The public evidence supports the following findings.

### Finding A: the target implementation is mlkem-native-specific

The source itself states that `mlk_scalar_signed_to_unsigned_q` is not present as a
separate helper in the Kyber reference implementation and is used to implement
mlkem-native's different unsigned `poly_reduce` semantics.

### Finding B: no eponymous scalar proof directory was observed

The pinned `proofs/cbmc` directory contains a `barrett_reduce` proof directory and
many other per-function directories, but no directory named
`scalar_signed_to_unsigned_q`.

This is strong repository-level evidence that the exact standalone scalar campaign
was not already present in that proof tree.

### Finding C: the inspected native Barrett harness is boilerplate

The native harness simply calls `mlk_barrett_reduce` and contains no custom
properties corresponding to T1-T4.

### Finding D: native CBMC documentation describes contract-based proof structure

The repository documentation says the harnesses are boilerplate and that
specifications are embedded in source contracts and loop annotations.

### Finding E: public mlkem-native methodology describes contract composition

A 2026 Amazon Science account explicitly explains that, for polynomial reduction,
CBMC replaces `mlk_barrett_reduce` and `mlk_scalar_signed_to_unsigned_q` with their
contracts when checking the higher-level composition.

T4 is therefore distinct in a technically important way: it opens and verifies both
actual bodies in the scalar composition.

### Finding F: no public exact match for the CANON theorem suite was located

The searches did not locate a public harness or paper using the same target-specific
combination of:

- exact fibre necessity and sufficiency;
- exact zero and nonzero fibres;
- retraction and exact fixed points;
- canonical-set injectivity;
- modular addition, subtraction and negation compatibility;
- full-`int16_t` actual-body Barrett composition;
- separate non-vacuity coverage; and
- targeted mutation analysis.

This is search-supported evidence, not a proof of universal nonexistence.

## 18.3 Findings limiting the novelty claim

### Limitation A: the basic function formula is already specified

The source contract already states the exact conditional-add result. Many T1-T3
properties are mathematical consequences of that formula.

Therefore, it would be false to claim that the campaign discovered a new
mathematical law of modular canonicalization.

### Limitation B: Barrett reduction already has a native proof

The repository already contains a direct CBMC proof directory for
`mlk_barrett_reduce`. T4 must not be described as the first verification of Barrett
reduction.

### Limitation C: the higher-level composition is already understood contractually

The source, native contracts, and public documentation already describe
`mlk_poly_reduce_c` as composing Barrett reduction with unsigned normalization.

The new contribution is the actual-body semantic composition proof and evaluation
stack, not the first recognition that the two functions are composed.

### Limitation D: negative search is not absolute proof

Public search cannot exclude:

- private work;
- unpublished theses;
- unindexed repositories;
- differently named equivalent theorems;
- later repository changes; or
- work published after the search date.

A world-first claim would therefore be unsupported.

---

# 19. Novelty potency assessment

## 19.1 Overall assessment

The novelty is best classified as:

> **Moderate-to-strong artefact-level and methodology-level novelty for an MSc
> implementation-verification case study; low novelty as pure mathematics or new
> cryptographic theory.**

## 19.2 Novelty dimensions

| Dimension | Assessment | Reason |
|---|---|---|
| New cryptographic algorithm | None | no algorithm was changed or invented |
| New mathematical theorem | Low | properties follow from canonical modulo mapping |
| New target-specific theorem organization | Moderate to strong | four coherent, preregistered semantic families were not found in the pinned native proof tree |
| New repository artefact | Strong at pinned commit | no matching scalar theorem harness/family was observed |
| Actual-body integration evidence | Strong | T4 opens both bodies instead of relying on contract replacement |
| Evaluation methodology | Strong | positive proof + coverage + targeted mutation + source integrity |
| Global/world-first certainty | Not established | public search cannot prove universal nonexistence |
| Thesis contribution potency | Strong if claimed precisely | demonstrates useful, distinct, reproducible assurance beyond native boilerplate harnesses |

## 19.3 Defensible novelty claim

The safest principal novelty claim is:

> This work contributes a repository-distinct, implementation-specific CBMC
> characterization of `mlk_scalar_signed_to_unsigned_q` at mlkem-native commit
> `af4c5abd`, comprising exact fibre structure, normalization dynamics,
> modular-operation compatibility, and actual-body composition with
> `mlk_barrett_reduce`. The characterization is evaluated through separate
> non-vacuity coverage, targeted production-source mutation analysis, immutable
> source binding, and reproducible evidence packaging.

A slightly stronger but still careful version is:

> A search of the pinned mlkem-native proof tree and the public record did not locate
> an existing theorem suite with the same target, actual-body policy, T1-T4 semantic
> decomposition, non-vacuity coverage, and mutation-evaluation structure. The
> contribution is therefore claimed as repository-distinct and search-supported
> artefact-level novelty, not as a proven world-first mathematical result.

## 19.4 Claims that must not be made

The following claims are not supported:

- “This is the first proof in the world.”
- “mlkem-native had no proof of the function.”
- “The source contract did not specify the target semantics.”
- “We proved all properties of canonicalization.”
- “We proved the whole ML-KEM implementation functionally correct.”
- “We proved the complete `mlk_poly_reduce_c` loop with our new harness.”
- “We proved constant-time behavior.”
- “T4 is the first proof of Barrett reduction.”
- “Mutation analysis proves complete correctness.”
- “A successful CBMC run is an unconditional mathematical proof.”

---

# 20. Campaign-level evidence closure

The final closure verified all four final packages and their internal manifests.

Campaign closure result:

```text
THEOREM_FAMILIES=4
ACCEPTED_THEOREM_FAMILIES=4
REGISTERED_SEMANTIC_PROPERTIES=17
PASSED_SEMANTIC_PROPERTIES=17
NONVACUITY_COVERAGE_GOALS=41
SATISFIED_COVERAGE_GOALS=41
TARGETED_PRODUCTION_MUTANTS=12
KILLED_PRODUCTION_MUTANTS=12
AUTHORITATIVE_SOURCE_REVALIDATION=PASS
PRODUCTION_SOURCE_MODIFIED=NO
CAMPAIGN_FINAL_CLASSIFICATION=ACCEPTED
```

Closure identifiers:

```text
Campaign master manifest:
  f5202ae384bdb657cf3c245b89a7c11adb3136d6289c316a0ae72f315fcce778

Closure package:
  CANON_CAMPAIGN_CLOSURE_INDEX_af4c5abd.tar.gz

Closure package SHA-256:
  20d53aaa8bc5d4f50b8194529662d0e6ca65e7ec9358412a89ba32a8532f4db1
```

---

# 21. Complete property registry

| ID | Formal statement | Domain |
|---|---|---|
| T1.P1 | \(F(x)=F(y)\Rightarrow x-y\in\{-q,0,q\}\) | \(x,y\in D\) |
| T1.P2 | \(x-y\in\{-q,0,q\}\Rightarrow F(x)=F(y)\) | \(x,y\in D\) |
| T1.P3 | \(F(c)=0\Leftrightarrow c=0\) | \(c\in D\) |
| T1.P4 | \(F(c)=u\Leftrightarrow(c=u\lor c=u-q)\) | \(c\in D,\ 1\le u<q\) |
| T2.P1 | \(F(u)=u\) | \(u\in U\) |
| T2.P2 | \(F(F(c))=F(c)\) | \(c\in D\) |
| T2.P3 | \(F(c)=c\Leftrightarrow c\ge0\) | \(c\in D\) |
| T2.P4 | \(F(u)=F(v)\Rightarrow u=v\) | \(u,v\in U\) |
| T3.P1 | \(F(x+y)=canon_q(F(x)+F(y))\) | \(x,y,x+y\in D\) |
| T3.P2 | \(F(x-y)=canon_q(F(x)-F(y))\) | \(x,y,x-y\in D\) |
| T3.P3 | \(F(-x)=canon_q(-F(x))\) | \(x\in D\) |
| T4.P1 | \(-q<B(a)<q\) | all `int16_t` \(a\) |
| T4.P2 | \(F(B(a))=canon_q(a)\) | all `int16_t` \(a\) |
| T4.P3 | \(F(B(a))\equiv a\pmod q\) | all `int16_t` \(a\) |
| T4.P4 | \(C(a+kq)=C(a)\) | \(k=\pm1\), translated value representable |
| T4.P5 | \(C(c)=F(c)\) | \(c\in D\) |
| T4.P6 | \(C(C(a))=C(a)\) | all `int16_t` \(a\) |

---

# 22. Threats to validity

## 22.1 Internal validity

### Harness-construction error

Mitigated by:

- static assertion counts;
- copied-body scans;
- `assume(false)` scans;
- GOTO property registration;
- body-binding inspection;
- coverage companions; and
- mutation analysis.

### Wrong-source execution

Mitigated by:

- commit binding;
- source-tar hash;
- `poly.c` hash;
- pre- and post-run source checks;
- deterministic worktree manifests; and
- final package manifests.

### Contract substitution

Mitigated by:

- dry-run command inspection;
- wrapper and contract-symbol scans;
- empty contract-transformation variables; and
- actual helper-body presence.

### Oracle correlation

The oracle is still executable C written by the same experimenter. Independence was
improved by using ordinary `int32_t` remainder arithmetic rather than the production
mask/selector structure, but it is not an independently mechanized theorem in a
second proof assistant.

## 22.2 Construct validity

The selected properties measure semantic canonicalization behavior. They do not
measure:

- timing leakage;
- generated assembly behavior;
- fault resistance;
- cryptographic security of ML-KEM;
- whole-program correctness; or
- array-level frame behavior of the entire polynomial routine.

## 22.3 External validity

The proof is pinned to one commit and one primary build configuration. Generalization
to other versions, compilers, architectures, and parameter configurations requires
separate evidence or a justified source-equivalence argument.

## 22.4 Novelty validity

The novelty claim is based on inspected public sources and exact searches. It is
strong for repository distinctness at the pinned commit but cannot establish
universal absence of equivalent unpublished or differently named work.

---

# 23. Reproducibility checklist

A reproduction must preserve:

1. pinned commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`;
2. authoritative `poly.c` hash;
3. frozen source archive hash;
4. CBMC 6.9.0;
5. default SAT authority;
6. `MLKEM_K=3`;
7. exact frozen theorem and coverage harnesses;
8. no target/Barrett contract replacement;
9. no DFCC;
10. the registered property counts;
11. separate coverage binaries;
12. exact mutation diffs;
13. deterministic non-poly worktree identity;
14. positive and mutant GOTO hashes;
15. internal evidence manifests; and
16. final package SHA-256 files.

A changed source commit, changed harness, changed backend, or changed assumption set is
a new experiment and must receive a new run identifier and evidence package.

---

# 24. Professor-ready result statement

The result can be presented as follows:

> The case study developed and evaluated four clean-room CBMC theorem families for
> the file-local mlkem-native helper `mlk_scalar_signed_to_unsigned_q` at pinned
> commit `af4c5abd`. T1 characterized its exact fibres and collision classes; T2
> established retraction, idempotence, fixed points and injectivity on canonical
> representatives; T3 established compatibility with modular addition, subtraction
> and negation; and T4 verified the actual-body composition with
> `mlk_barrett_reduce` for the full `int16_t` input space. The 17 semantic
> properties all passed under CBMC 6.9.0, all 41 separate non-vacuity goals were
> reachable, and 12 targeted mutations to disposable production-source copies were
> rejected. The authoritative production source remained unchanged. The
> contribution is claimed as a repository-distinct, implementation-specific
> verification artefact and evaluation campaign, rather than as a new
> cryptographic algorithm, a new mathematical fact about modular reduction, or a
> world-first proof.

---

# 25. Final claim boundary

## Accepted claim

At mlkem-native commit
`af4c5abdd5958bdc65a03cd5ee86708264f93304`, CBMC 6.9.0 verified a
repository-distinct, implementation-specific characterization of
`mlk_scalar_signed_to_unsigned_q`. The campaign comprises exact fibre structure,
normalization dynamics, modular-operation compatibility, and actual-body composition
with `mlk_barrett_reduce`.

All 17 preregistered semantic properties passed. All 41 non-vacuity coverage goals
were reachable. Twelve targeted production-source mutants were rejected. The
authoritative production source was not modified.

## Claim limit

This evidence does not establish that every conceivable property of
`mlk_scalar_signed_to_unsigned_q` has been proved. It establishes the accepted
CANON-T1 through CANON-T4 theorem families at the pinned commit and under the
recorded CBMC configuration, assumptions, and limitations.

It does not independently establish a new whole-array actual-body proof of
`mlk_poly_reduce_c`, generated-code constant-time behavior, or complete ML-KEM
functional correctness.

The evidence must not be described as a world-first result.

---

# 26. Primary external sources used for the novelty and scope audit

1. **National Institute of Standards and Technology (2024).** *FIPS 203:
   Module-Lattice-Based Key-Encapsulation Mechanism Standard.* Available at:
   https://doi.org/10.6028/NIST.FIPS.203  
   Relevant basis: ML-KEM and the fixed constants \(n=256\) and \(q=3329\).

2. **mlkem-native project authors (n.d.).** `mlkem/src/poly.c` at commit
   `af4c5abdd5958bdc65a03cd5ee86708264f93304`. Available at:
   https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/mlkem/src/poly.c  
   Relevant basis: target body, contracts, Barrett body, portability note, and
   `mlk_poly_reduce_c` composition.

3. **mlkem-native project authors (n.d.).** *CBMC proofs README* at commit
   `af4c5abd`. Available at:
   https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc/README.md  
   Relevant basis: native proof scope, embedded specifications, and boilerplate
   harness architecture.

4. **mlkem-native project authors (n.d.).** `proofs/cbmc` tree at commit
   `af4c5abd`. Available at:
   https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc  
   Relevant basis: native proof-directory census.

5. **mlkem-native project authors (n.d.).**
   `proofs/cbmc/barrett_reduce/barrett_reduce_harness.c` at commit `af4c5abd`.
   Available at:
   https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc/barrett_reduce/barrett_reduce_harness.c  
   Relevant basis: native boilerplate Barrett harness.

6. **mlkem-native project authors (n.d.).**
   `proofs/cbmc/barrett_reduce/Makefile` at commit `af4c5abd`. Available at:
   https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc/barrett_reduce/Makefile  
   Relevant basis: native contract-checking configuration.

7. **Becker, H., Chapman, R. and Kostic, D. (2026).** ‘Verifying and optimizing
   post-quantum cryptography at Amazon’, *Amazon Science*, 7 April. Available at:
   https://www.amazon.science/blog/verifying-and-optimizing-post-quantum-cryptography-at-amazon  
   Relevant basis: public description of mlkem-native's memory/type-safety scope
   and contract replacement in the polynomial-reduction composition.

8. **Kroening, D., Schrammel, P. and Tautschnig, M. (2023).** ‘CBMC: The C
   Bounded Model Checker’. Available at:
   https://arxiv.org/abs/2302.02384  
   Relevant basis: CBMC assertion checking, bit-precise translation, and bounded
   model-checking semantics.

---

# 27. Final evidence ledger

| Evidence item | SHA-256 |
|---|---|
| Authoritative `mlkem/src/poly.c` | `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722` |
| Source archive | `bb9a092da93f9ce24f16c6fe66c641869ac06362dd0d951161bff3a041804f47` |
| CANON-00B manifest | `76b72bed8cb4c0f8e2acda8d24e71e15461991280cd90370738f3a8746e1e523` |
| T1 final package | `47b4adb28bcac7265ca4fdc8be407136bc5450ae49f5cc49ce5b750c3624f47f` |
| T2 final package | `dccfffb368458b6b96f378f2d1dfcf38b2b0c3c7e5169928134de49346c1ff51` |
| T3 final package | `71a1267dc4bcf00e660f44984e105ca0befb557cbff7f1538962c77792343488` |
| T4 final package | `20e9394f1af995219fdd38b083c7a6c8480bed5489874de5d6c7276f17c40f4d` |
| Campaign master manifest | `f5202ae384bdb657cf3c245b89a7c11adb3136d6289c316a0ae72f315fcce778` |
| Campaign closure package | `20d53aaa8bc5d4f50b8194529662d0e6ca65e7ec9358412a89ba32a8532f4db1` |

---

# 28. Final classification

```text
CAMPAIGN=CANON
PRIMARY_TARGET=mlk_scalar_signed_to_unsigned_q
COMPOSITION_TARGET=mlk_barrett_reduce
PINNED_COMMIT=af4c5abdd5958bdc65a03cd5ee86708264f93304
THEOREM_FAMILIES=4
SEMANTIC_PROPERTIES=17
PASSED_SEMANTIC_PROPERTIES=17
COVERAGE_GOALS=41
SATISFIED_COVERAGE_GOALS=41
TARGETED_MUTANTS=12
KILLED_MUTANTS=12
ACTUAL_TARGET_BODY_VERIFIED=YES
ACTUAL_BARRETT_BODY_VERIFIED=YES
AUTHORITATIVE_SOURCE_MODIFIED=NO
NOVELTY_CLASSIFICATION=REPOSITORY_DISTINCT_AND_SEARCH_SUPPORTED_ARTEFACT_LEVEL_NOVELTY
WORLD_FIRST_CLAIM=NOT_MADE
CAMPAIGN_FINAL_CLASSIFICATION=ACCEPTED
```
