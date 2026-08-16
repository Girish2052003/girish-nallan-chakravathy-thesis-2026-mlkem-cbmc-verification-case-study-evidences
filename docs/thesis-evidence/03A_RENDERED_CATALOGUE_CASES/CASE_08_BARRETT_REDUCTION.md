# Case 8 — Barrett Reduction

**Target:** `mlk_barrett_reduce`
**Evidence locator:** `LOC-C08-UA`
**Chapter 4 projection:** Section 4.4.5
**Ledger records:** 23
**Formally supported subset:** 23

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768 build; full int16_t domain
**Evidence completeness:** `COMPLETE`

## Verification question

Does the unchanged Barrett implementation equal an independent centred-remainder oracle for every machine input, and how tightly can its quotient cells, multiplier and offset parameters be characterised?

## Case notation and opening equations


$$
R(a)=\mathop{\text{Barrett}}(a)
$$


$$
C(a)=\mathop{\text{Centered}}_q(a)
$$


$$
t(a)=\frac{a-C(a)}{q}
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
\forall a\in\mathrm{int16}:\quad R(a)=C(a)
$$


$$
-1664\le R(a)\le1664,\qquad R(a)\equiv a\pmod q
$$


$$
B_{\mathrm{prod}}=33554432=2^{25}\in[33548599,33560264]
$$


**Recorded principal-claim wording:** For every `int16_t` input `a`, $`\mathrm{Barrett}(a)=\mathrm{Centered}_q(a)`$, $`-1664\le\mathrm{Barrett}(a)\le1664`$, and $`\mathrm{Barrett}(a)\equiv a\pmod q`$, with the registered fixed-point, quotient-cell, multiplier and offset-characterisation properties.


### Why this claim is the principal case-level synthesis

Independent-oracle equality over the complete machine domain is the semantic anchor. Range and congruence state what representative is returned; fixed-point, quotient-cell, multiplier and offset families then explain why the frozen implementation realises that anchor. Parameter uniqueness is implementation characterisation, not a worldwide novelty claim.


The survival ledger assigns this synthesis to **4.4.5** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768 build; full int16_t input domain`. Its primary verification focus was: Independent exact centered-remainder oracle; range and congruence; closest/unique representative; fixed point and idempotence; residue-class invariance; quotient-cell partition; multiplier uniqueness and offset interval. The additional or mixed evidence was: Five theorem families, 23 named research properties, supporting controls and 12 killed mutants are reported; no input assumption was needed beyond the machine type.


The retained case matrix records CBMC execution as **YES — T1–T5 accepted**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** For every int16_t input in the pinned portable-C build, the target agrees with the selected independent centered-reduction oracle and satisfies the recorded range, congruence, partition and stability properties.


**Integrity boundary:** Repository-relative artefact distinctness is supported; mathematical/worldwide first-ever novelty is not established.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt` with entry SHA-256 `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`. The case archive is `thesis_batch_1.zip` with SHA-256 `b7d4a0c238997f323abb93974243f93bcc0afe65f48cecd94d3b6af93f89c0d0`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **32** indexed records for `LOC-C08-UA`: COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary.


**Necessary overlap.** Same production function, q and fixed arithmetic constants.


**What this campaign added.** Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties.


**Why the suite is substantively distinct within the inspected corpus.** Independent oracle and parameter-characterization suites materially exceed the native one-call harness while remaining repository-relative.


**Comparison material inspected.** `proofs/cbmc/barrett_reduce/`, production source/contracts, BR audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESS_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/barrett_reduce/barrett_reduce_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/barrett_reduce/Makefile

- **Native proof entry SHA-256:** 2257c68f1412b9b4a4a66b7bd5c178d87dd0d571ad1a487df4392ce1c84b20dc;60b43149f1fa523659a5d5fc55b1ecdf6d2f44f0c2988f8903b699bbf3e23672

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/poly.c

- **Production source entry SHA-256:** f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722

- **Authoritative baseline characterisation:** A dedicated native one-call Barrett harness exists.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DIRECT_SEMANTIC_SUPPORT` | `PR-C08-002`, `PR-C08-003`, `PR-C08-004`, `PR-C08-007`, `PR-C08-008`, `PR-C08-009`, `PR-C08-011`, `PR-C08-012`, `PR-C08-014`, `PR-C08-015`, `PR-C08-016`, `PR-C08-017`, `PR-C08-019`, `PR-C08-020`, `PR-C08-021`, `PR-C08-022`, `PR-C08-023` | states the core value/representation relation |

| `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT` | `PR-C08-001`, `PR-C08-005`, `PR-C08-010`, `PR-C08-013`, `PR-C08-018` | establishes the finite domain, range or representation in which the core relation is meaningful |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-C08-006` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `BR-T1.P2`, `BR-T1.P3`, `BR-T1.P4`, `BR-T1.P5`, `BR-T2.P6`, `BR-T2.P7`, `BR-T2.P8`, `BR-T3.P9`, `BR-T3.P10`, `BR-T3.P11`, `BR-T3.P12`, `BR-T3.P13`, `BR-T4.P14`, `BR-T4.P15`, `BR-T4.P16`, `BR-T4.P17`, `BR-T4.P18`, `BR-T5.P19`, `BR-T5.P20`, `BR-T5.P21`, `BR-T5.P22`, `BR-T5.P23`, `BR-T5.P24`


## Thesis-appendix projection


The compact Appendix 1 projection contains **23** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `LIM-C08-NOVELTY` | `NOT_ESTABLISHED` | Repository-relative distinctness supported; wider prior assurance exists. | No first-ever mathematical or formal-proof claim. |


## Assurance-layer and literature relationship

This comparison prevents repository-relative distinctness from being rewritten as global mathematical novelty. The rows below are interpretive context; implementation support still comes from the source-bound evidence for this case.

| Source/project | Relationship | Overlap | Important difference | Permitted conclusion |
|---|---|---|---|---|

| NIST FIPS 203 (2024a) | `NORMATIVE_GROUNDING` | Grounds ML-KEM operations, domains and data formats relevant to the case. | FIPS 203 is not a proof that this C implementation or generated harness is correct. | The case is specification-grounded where applicable; implementation support comes from the recorded source-bound CBMC evidence, not from the standard alone. |

| PQ Code Package / mlkem-native assurance documentation (n.d.-a; n.d.-b) | `NATIVE_ASSURANCE_CONTEXT` | Shares the exact production repository and some target contracts/harness infrastructure. | Native artefacts support different or narrower property sets and different assurance layers; the case-specific distinction is recorded in matrix 04. | Report repository-relative generated artefact/property contribution, not absence of all prior assurance. |

| Formosa Crypto and Almeida et al. (2023; 2024; 2025) | `RELATED_PROOF_ORIENTED_ASSURANCE` | Covers ML-KEM/Kyber functional and representation reasoning in proof-oriented settings. | Different implementation language/source, specifications, proof infrastructure and assurance boundary from local CBMC checks over mlkem-native C. | Use as assurance-layer comparison; do not claim the first formal proof of the underlying mathematics or operation. |

| HOL Light / s2n-bignum and documented mlkem-native low-level proofs | `RELATED_LOW_LEVEL_ASSURANCE` | May cover arithmetic or conversion behaviour for optimized low-level implementations. | The thesis analyses pinned portable-C functions and locally selected CBMC properties; backend equivalence was not generally established. | The results are complementary, not a replacement for or superiority claim over low-level proofs. |


## Publication-state and traceability-field note

The record blocks below preserve the frozen RC2 public-path fields only as explicitly labelled historical provenance. Their former `PENDING`, `UNRESOLVED_UNTIL_FINALIZER`, blank public-SHA and candidate-count values describe the pre-finalization snapshot; they do **not** describe the current repository. The current authoritative ledger records all 257 substantive records as `RESOLVED_HASH_MATCH` and supplies the exact current public path and SHA-256. To avoid creating a second mutable authority, this catalogue points each record back to its current ledger row instead of copying those current path/hash strings into prose.

Scientific outcome status is independent. Supported, negative, abstraction-limited, resource-limited, diagnostic, construction and preservation classifications are reproduced unchanged.

# Complete record-by-record catalogue


## PR-C08-001 — Centered output range


### Formal statement

$$
-1664 \le R(a) \le 1664
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Centered output range**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 1, “Exact output range”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-001`

- **Historical identifier:** `BR-T1.P2`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle -1664 \le R(a) \le 1664`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 1, “Exact output range”.


</details>

---

## PR-C08-002 — Modulo-q congruence


### Formal statement

$$
R(a) \equiv a\pmod q
$$


### What the property/control means

The property gives a direct semantic characterisation of **Modulo-q congruence** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 2, “Congruence”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-002`

- **Historical identifier:** `BR-T1.P3`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle R(a) \equiv a\pmod q`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 2, “Congruence”.


</details>

---

## PR-C08-003 — Independent centered-oracle equality


### Formal statement

$$
R(a)=C(a)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Independent centered-oracle equality** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 3, “Exact centred-remainder refinement”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-003`

- **Historical identifier:** `BR-T1.P4`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle R(a)=C(a)`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 3, “Exact centred-remainder refinement”.


</details>

---

## PR-C08-004 — Unique closest signed-16 representative


### Formal statement

$$
\begin{array}{rl}
&\text{R(a) is the unique closest representative in the registered centered}\\
&\text{interval}
\end{array}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Unique closest signed-16 representative** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 4, “Uniqueness of the centred representative”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-004`

- **Historical identifier:** `BR-T1.P5`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle \begin{array}{rl} &\text{R(a) is the unique closest representative in the registered centered}\\ &\text{interval} \end{array}`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** verbatim structural/logical relation rendered without inventing an equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 4, “Uniqueness of the centred representative”.


</details>

---

## PR-C08-005 — Centered-domain fixed point


### Formal statement

$$
\forall r\in[-1664,1664]:\quad R(r)=r
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Centered-domain fixed point**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 5, “Centred fixed points”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-005`

- **Historical identifier:** `BR-T2.P6`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle \forall r\in[-1664,1664]:\quad R(r)=r`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 5, “Centred fixed points”.


</details>

---

## PR-C08-006 — Idempotence


### Formal statement

$$
R(R(a))=R(a)
$$


### What the property/control means

The property checks the structural or multi-execution law **Idempotence**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 6, “Idempotence”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-006`

- **Historical identifier:** `BR-T2.P7`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle R(R(a))=R(a)`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 6, “Idempotence”.


</details>

---

## PR-C08-007 — Residue-class invariance


### Formal statement

$$
a\equiv b\pmod q\Longrightarrow R(a)=R(b)\qquad\text{within the registered int16 domain}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Residue-class invariance** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 7, “Residue-class invariance”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-007`

- **Historical identifier:** `BR-T2.P8`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle a\equiv b\pmod q\Longrightarrow R(a)=R(b)\qquad\text{within the registered int16 domain}`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 7, “Residue-class invariance”.


</details>

---

## PR-C08-008 — Exact quotient equivalence


### Formal statement

$$
t(a)=\frac{a-C(a)}{q}\in\mathbb{Z}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact quotient equivalence** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 8, “Exact quotient definition”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-008`

- **Historical identifier:** `BR-T3.P9`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle t(a)=\frac{a-C(a)}{q}\in\mathbb{Z}`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 8, “Exact quotient definition”.


</details>

---

## PR-C08-009 — Production affine decomposition


### Formal statement

$$
R(a)=a-q\,t(a)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Production affine decomposition** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 9, “Exact quotient reconstruction”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-009`

- **Historical identifier:** `BR-T3.P10`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle R(a)=a-q\,t(a)`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 9, “Exact quotient reconstruction”.


</details>

---

## PR-C08-010 — Tight quotient range


### Formal statement

$$
-10 \le t(a) \le 10
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Tight quotient range**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 10, “Quotient bound over the int16_t domain”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-010`

- **Historical identifier:** `BR-T3.P11`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle -10 \le t(a) \le 10`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 10, “Quotient bound over the int16_t domain”.


</details>

---

## PR-C08-011 — Exact unique quotient-cell membership


### Formal statement

$$
I_k=[kq-1664,\,kq+1664]\cap \mathrm{int16}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact unique quotient-cell membership** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 11, “Quotient-cell partition”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-011`

- **Historical identifier:** `BR-T3.P12`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle I_k=[kq-1664,\,kq+1664]\cap \mathrm{int16}`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 11, “Quotient-cell partition”.


</details>

---

## PR-C08-012 — Clipped endpoint-cell characterization


### Formal statement

$$
I_k=[kq-1664,\,kq+1664]\cap\mathrm{int16\_t}\qquad\text{with endpoint cells clipped by the int16 bounds}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Clipped endpoint-cell characterization** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 12, “Clipped endpoint cells”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-012`

- **Historical identifier:** `BR-T3.P13`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle I_k=[kq-1664,\,kq+1664]\cap\mathrm{int16\_t}\qquad\text{with endpoint cells clipped by the int16 bounds}`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-012`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 12, “Clipped endpoint cells”.


</details>

---

## PR-C08-013 — Safe multiplier domain


### Formal statement

$$
0\le m\le64513
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Safe multiplier domain**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 13, “Registered safe multiplier domain”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-013`

- **Historical identifier:** `BR-T4.P14`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle 0\le m\le64513`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-013`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** verbatim structural/logical relation rendered without inventing an equation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 13, “Registered safe multiplier domain”.


</details>

---

## PR-C08-014 — Production multiplier sufficiency


### Formal statement

$$
\forall a\in\mathrm{int16\_t}:\quad R_{20159}(a)=C(a)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Production multiplier sufficiency** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 14, “Correctness of the production multiplier”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-014`

- **Historical identifier:** `BR-T4.P15`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle \forall a\in\mathrm{int16\_t}:\quad R_{20159}(a)=C(a)`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-014`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 14, “Correctness of the production multiplier”.


</details>

---

## PR-C08-015 — Every smaller safe multiplier rejected


### Formal statement

$$
\forall m\in\mathcal M_{\mathrm{safe}}:\;m\lt 20159\Longrightarrow R_m(-31626)\ne C(-31626)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Every smaller safe multiplier rejected** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 15, “Failure below the production multiplier”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-015`

- **Historical identifier:** `BR-T4.P16`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle \forall m\in\mathcal M_{\mathrm{safe}}:\;m\lt 20159\Longrightarrow R_m(-31626)\ne C(-31626)`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-015`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 15, “Failure below the production multiplier”.


</details>

---

## PR-C08-016 — Every larger safe multiplier rejected


### Formal statement

$$
\forall m\in\mathcal M_{\mathrm{safe}}:\;m\gt 20159\Longrightarrow R_m(-31625)\ne C(-31625)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Every larger safe multiplier rejected** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 16, “Failure above the production multiplier”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-016`

- **Historical identifier:** `BR-T4.P17`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle \forall m\in\mathcal M_{\mathrm{safe}}:\;m\gt 20159\Longrightarrow R_m(-31625)\ne C(-31625)`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-016`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 16, “Failure above the production multiplier”.


</details>

---

## PR-C08-017 — Two-witness multiplier characterization


### Formal statement

$$
R_B(a_1)=C(a_1)\land R_B(a_2)=C(a_2)\Longrightarrow B=20159\qquad\text{for the two registered uniqueness witnesses }a_1,a_2
$$


### What the property/control means

The property gives a direct semantic characterisation of **Two-witness multiplier characterization** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 17, “Multiplier uniqueness under the registered formulation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-017`

- **Historical identifier:** `BR-T4.P18`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle R_B(a_1)=C(a_1)\land R_B(a_2)=C(a_2)\Longrightarrow B=20159\qquad\text{for the two registered uniqueness witnesses }a_1,a_2`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-017`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 17, “Multiplier uniqueness under the registered formulation”.


</details>

---

## PR-C08-018 — Offset-domain safety


### Formal statement

$$
0\le B\le67108863
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Offset-domain safety**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 18, “Registered offset search domain”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-018`

- **Historical identifier:** `BR-T5.P19`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle 0\le B\le67108863`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-018`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** verbatim structural/logical relation rendered without inventing an equation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 18, “Registered offset search domain”.


</details>

---

## PR-C08-019 — Exact offset interval sufficiency


### Formal statement

$$
\forall B\in[33548599,33560264]\;\forall a\in\mathrm{int16\_t}:\quad R_B(a)=C(a)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact offset interval sufficiency** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 19, “Complete valid-offset interval”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-019`

- **Historical identifier:** `BR-T5.P20`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle \forall B\in[33548599,33560264]\;\forall a\in\mathrm{int16\_t}:\quad R_B(a)=C(a)`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-019`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 19, “Complete valid-offset interval”.


</details>

---

## PR-C08-020 — Lower offsets rejected


### Formal statement

$$
\forall B\lt 33548599\;\exists a\in\mathrm{int16\_t}:\quad R_B(a)\ne C(a)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Lower offsets rejected** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 20, “Offsets below the interval are invalid”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-020`

- **Historical identifier:** `BR-T5.P21`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle \forall B\lt 33548599\;\exists a\in\mathrm{int16\_t}:\quad R_B(a)\ne C(a)`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-020`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 20, “Offsets below the interval are invalid”.


</details>

---

## PR-C08-021 — Upper offsets rejected


### Formal statement

$$
\forall B\gt 33560264\;\exists a\in\mathrm{int16\_t}:\quad R_B(a)\ne C(a)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Upper offsets rejected** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 21, “Offsets above the interval are invalid”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-021`

- **Historical identifier:** `BR-T5.P22`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle \forall B\gt 33560264\;\exists a\in\mathrm{int16\_t}:\quad R_B(a)\ne C(a)`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-021`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 21, “Offsets above the interval are invalid”.


</details>

---

## PR-C08-022 — Two-witness offset characterization


### Formal statement

$$
\left\lbrace B:\forall a\in\mathrm{int16},\,R_B(a)=C(a)\right\rbrace=[33548599,33560264]
$$


### What the property/control means

The property gives a direct semantic characterisation of **Two-witness offset characterization** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 22, “Exactness of the valid-offset interval”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-022`

- **Historical identifier:** `BR-T5.P23`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle \left\lbrace B:\forall a\in\mathrm{int16},\,R_B(a)=C(a)\right\rbrace=[33548599,33560264]`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-022`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 22, “Exactness of the valid-offset interval”.


</details>

---

## PR-C08-023 — Production offset binding


### Formal statement

$$
B_{\mathrm{prod}}=33554432=2^{25}\in[33548599,33560264]
$$


### What the property/control means

The property gives a direct semantic characterisation of **Production offset binding** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `BR_AF4 T1–T5 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across the five families. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `BR_AF4 T1–T5 final harness assertion`. The admitted domain is: All int16_t inputs unless the parameter-characterization row states a candidate parameter domain. The recorded assumptions/grounding are: No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named machine-level centered-reduction or parameter-characterization relation is supported.

**What this record does not establish:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


### Native-baseline relationship

The frozen native baseline for this case is: Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary. The campaign addition is characterised at case level as: Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 23, “Production offset lies in the complete valid interval”. Chapter 4 uses the case-level principal synthesis in Section 4.4.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C08-023`

- **Historical identifier:** `BR-T5.P24`

- **Case identifier:** `8`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Centered reduction characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; full int16_t domain

- **Input domain:** All int16_t inputs unless the parameter-characterization row states a candidate parameter domain

- **Assumptions and grounding:** No substantive input restriction beyond machine type; independent centered oracle and arithmetic-right-shift model

- **Ledger formal relation:** $`\displaystyle B_{\mathrm{prod}}=33554432=2^{25}\in[33548599,33560264]`$

- **Assertion / harness mapping:** BR_AF4 T1–T5 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across the five families

- **Strongest bounded conclusion:** The named machine-level centered-reduction or parameter-characterization relation is supported.

- **Explicit exclusion:** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.

- **Evidence locator:** `LOC-C08-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/BR_AF4_T1_T5_A_TO_Z_TECHNICAL_AND_NOVELTY_REPORT.md.txt

- **Archive entry SHA-256:** `21d570df8135b9f05ff8492882acfcd58cffd04955b59b4c7281d3816427b522`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C08-023`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Ledger-faithful rendered membership equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 8: Barrett Reduction: mlk_barrett_reduce → item 23, “Production offset lies in the complete valid interval”.


</details>

---


# Case-level bounded conclusion

For every `int16_t` input `a`, $`\mathrm{Barrett}(a)=\mathrm{Centered}_q(a)`$, $`-1664\le\mathrm{Barrett}(a)\le1664`$, and $`\mathrm{Barrett}(a)\equiv a\pmod q`$, with the registered fixed-point, quotient-cell, multiplier and offset-characterisation properties.

**Explicit exclusion.** No first-ever/worldwide novelty claim; bound to pinned expression and machine model.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
