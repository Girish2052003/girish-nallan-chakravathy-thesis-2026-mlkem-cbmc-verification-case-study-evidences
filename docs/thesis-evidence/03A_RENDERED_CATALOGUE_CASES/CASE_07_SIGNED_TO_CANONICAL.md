# Case 7 — Signed-to-Canonical Conversion

**Target:** `mlk_scalar_signed_to_unsigned_q`
**Evidence locator:** `LOC-C07-UA`
**Chapter 4 projection:** Section 4.4.4
**Ledger records:** 17
**Formally supported subset:** 17

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768 build
**Evidence completeness:** `COMPLETE`

## Verification question

Does the actual production conversion map the registered signed representative domain to the canonical residue domain with the expected fibre and algebraic behaviour, and does it compose correctly with the actual Barrett body?

## Case notation and opening equations


$$
D_s=\{-(q-1),\ldots,q-1\}=\{-3328,\ldots,3328\}
$$


$$
U=\{0,\ldots,q-1\}
$$


$$
F=\mathop{\text{SignedToCanon}}
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
F:D_s\to U,\qquad F(x)=\mathop{\text{canon}}_q(x)
$$


$$
\mathop{\text{CanonAfterBarrett}}(a)=F(\mathop{\text{Barrett}}(a))=\mathop{\text{canon}}_q(a)
$$


**Recorded principal-claim wording:** `SignedToCanon` maps $`D_s=\{-(q-1),\ldots,q-1\}`$ to $`[0,q)`$, with the recorded fibre, idempotence, fixed-point and algebraic laws; $`\mathrm{CanonAfterBarrett}(a)=\mathrm{canon}_q(a)`$ for every `int16_t` input `a`.


### Why this claim is the principal case-level synthesis

The principal claim combines the function’s representation-conversion purpose with the strongest actual-body composition exercised by the campaign. Fibre, fixed-point and algebra laws expose the structure of the map; the Barrett composition demonstrates compatibility with a production reduction path. None of these records licenses arbitrary-integer reduction.


The survival ledger assigns this synthesis to **4.4.4** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768 build`. Its primary verification focus was: Exact signed-to-canonical conversion; normalization-operator behaviour; compatibility with addition, subtraction and negation; composition with Barrett reduction. The additional or mixed evidence was: Four theorem families, 17 semantic properties, 41 coverage goals and 12 killed mutants are reported.


The retained case matrix records CBMC execution as **YES — campaign accepted**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** The selected production conversion realizes the recorded canonicalization function over its source-contract domain and satisfies the selected algebraic/compositional consequences.


**Integrity boundary:** Actual bodies were retained and production source was not modified.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md` with entry SHA-256 `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`. The case archive is `thesis_batch_3.zip` with SHA-256 `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **26** indexed records for `LOC-C07-UA`: COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=2. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics.


**Necessary overlap.** q and production conversion/reduction bodies.


**What this campaign added.** Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition.


**Why the suite is substantively distinct within the inspected corpus.** The generated suite does not depend on absence of a native harness. It adds seventeen explicit fibre, fixed-point, algebraic and actual-body Barrett-composition properties, separate coverage goals and mutation controls beyond the native one-call contract-oriented harness.


**Comparison material inspected.** Archive-verified frozen proof census; `proofs/cbmc/scalar_signed_to_unsigned_q/scalar_signed_to_unsigned_q_harness.c`; production `mlkem/src/poly.c`; CANON campaign records. A contrary summary statement claiming no eponymous directory is superseded by the frozen-source census.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESS_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/scalar_signed_to_unsigned_q/scalar_signed_to_unsigned_q_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/scalar_signed_to_unsigned_q/Makefile

- **Native proof entry SHA-256:** db059c559d2ad2c63b9ed8a5a64ba85701c5a6e5e2c2b0c4f71174df2fd2babd;bea04cbfd2eeff047d23f6bfcc9cdd64d0f3557402f7f11d204f99a1022588f5

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/poly.c

- **Production source entry SHA-256:** f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722

- **Authoritative baseline characterisation:** A dedicated native one-call scalar conversion harness exists. The retained CANON summary statement claiming its absence is factually superseded by the frozen-source census.

- **Conflict resolution:** RETAINED_CANON_SUMMARY_ABSENCE_CLAIM_SUPERSEDED_BY_FROZEN_SOURCE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT` | `PR-C07-005`, `PR-C07-008`, `PR-C07-012`, `PR-C07-016` | establishes the finite domain, range or representation in which the core relation is meaningful |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-C07-001`, `PR-C07-002`, `PR-C07-003`, `PR-C07-004`, `PR-C07-006`, `PR-C07-007`, `PR-C07-009`, `PR-C07-010`, `PR-C07-011`, `PR-C07-013`, `PR-C07-014`, `PR-C07-015`, `PR-C07-017` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `CANON-T1.P1`, `CANON-T1.P2`, `CANON-T1.P3`, `CANON-T1.P4`, `CANON-T2.P1`, `CANON-T2.P2`, `CANON-T2.P3`, `CANON-T2.P4`, `CANON-T3.P1`, `CANON-T3.P2`, `CANON-T3.P3`, `CANON-T4.P1`, `CANON-T4.P2`, `CANON-T4.P3`, `CANON-T4.P4`, `CANON-T4.P5`, `CANON-T4.P6`


**Survival-ledger contrary/unresolved IDs:** `CONFLICT-C07-NATIVE-DIR`


## Thesis-appendix projection


The compact Appendix 1 projection contains **17** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `CONFLICT-C07-NATIVE-DIR` | `EVIDENCE_SOURCE_CONFLICT` | The frozen af4c5abd source tree contains `proofs/cbmc/scalar_signed_to_unsigned_q/scalar_signed_to_unsigned_q_harness.c` and its Makefile. | Frozen source controls. The directory and native one-call harness are recorded as present; distinctness rests on the seventeen generated semantic properties and controls. |


## Assurance-layer and literature relationship

This comparison prevents repository-relative distinctness from being rewritten as global mathematical novelty. The rows below are interpretive context; implementation support still comes from the source-bound evidence for this case.

| Source/project | Relationship | Overlap | Important difference | Permitted conclusion |
|---|---|---|---|---|

| NIST FIPS 203 (2024a) | `NORMATIVE_GROUNDING` | Grounds ML-KEM operations, domains and data formats relevant to the case. | FIPS 203 is not a proof that this C implementation or generated harness is correct. | The case is specification-grounded where applicable; implementation support comes from the recorded source-bound CBMC evidence, not from the standard alone. |

| PQ Code Package / mlkem-native assurance documentation (n.d.-a; n.d.-b) | `NATIVE_ASSURANCE_CONTEXT` | Shares the exact production repository and some target contracts/harness infrastructure. | Native artefacts support different or narrower property sets and different assurance layers; the case-specific distinction is recorded in matrix 04. | Report repository-relative generated artefact/property contribution, not absence of all prior assurance. |

| Formosa Crypto and Almeida et al. (2023; 2024; 2025) | `RELATED_PROOF_ORIENTED_ASSURANCE` | Covers ML-KEM/Kyber functional and representation reasoning in proof-oriented settings. | Different implementation language/source, specifications, proof infrastructure and assurance boundary from local CBMC checks over mlkem-native C. | Use as assurance-layer comparison; do not claim the first formal proof of the underlying mathematics or operation. |


## Publication-state and traceability-field note

The record blocks below preserve the frozen RC2 public-path fields only as explicitly labelled historical provenance. Their former `PENDING`, `UNRESOLVED_UNTIL_FINALIZER`, blank public-SHA and candidate-count values describe the pre-finalization snapshot; they do **not** describe the current repository. The current authoritative ledger records all 257 substantive records as `RESOLVED_HASH_MATCH` and supplies the exact current public path and SHA-256. To avoid creating a second mutable authority, this catalogue points each record back to its current ledger row instead of copying those current path/hash strings into prose.

Scientific outcome status is independent. Supported, negative, abstraction-limited, resource-limited, diagnostic, construction and preservation classifications are reproduced unchanged.

# Complete record-by-record catalogue


## PR-C07-001 — Fibre necessity


### Formal statement

$$
F(x)=F(y)\Longrightarrow x-y\in\{-q,0,q\}
$$


### What the property/control means

The property checks the structural or multi-execution law **Fibre necessity**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: x,y in D=(-q,q). The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 1, “Fibre necessity”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-001`

- **Historical identifier:** `CANON-T1.P1`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** x,y in D=(-q,q)

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(x)=F(y)\Longrightarrow x-y\in\{-q,0,q\}`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 1, “Fibre necessity”.


</details>

---

## PR-C07-002 — Fibre sufficiency


### Formal statement

$$
x-y\in\{-q,0,q\}\Longrightarrow F(x)=F(y)
$$


### What the property/control means

The property checks the structural or multi-execution law **Fibre sufficiency**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: x,y in D. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 2, “Fibre sufficiency”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-002`

- **Historical identifier:** `CANON-T1.P2`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** x,y in D

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle x-y\in\{-q,0,q\}\Longrightarrow F(x)=F(y)`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 2, “Fibre sufficiency”.


</details>

---

## PR-C07-003 — Zero fibre


### Formal statement

$$
F(c)=0 \Longleftrightarrow c=0
$$


### What the property/control means

The property checks the structural or multi-execution law **Zero fibre**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: c in D. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 3, “Zero fibre”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-003`

- **Historical identifier:** `CANON-T1.P3`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** c in D

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(c)=0 \Longleftrightarrow c=0`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 3, “Zero fibre”.


</details>

---

## PR-C07-004 — Positive-output fibre


### Formal statement

$$
F(c)=u\Longleftrightarrow\bigl(c=u\;\lor\;c=u-q\bigr),\qquad 1\le u\lt q
$$


### What the property/control means

The property checks the structural or multi-execution law **Positive-output fibre**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: $`c\in D;\ u\in[1,q)`$. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 4, “Complete non-zero fibre characterisation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-004`

- **Historical identifier:** `CANON-T1.P4`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** $`c\in D;\ u\in[1,q)`$

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(c)=u\Longleftrightarrow\bigl(c=u\;\lor\;c=u-q\bigr),\qquad 1\le u\lt q`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 4, “Complete non-zero fibre characterisation”.


</details>

---

## PR-C07-005 — Identity on canonical domain


### Formal statement

$$
F(u)=u
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Identity on canonical domain**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: $`u\in U=[0,q)`$. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 5, “Canonical fixed points”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-005`

- **Historical identifier:** `CANON-T2.P1`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** $`u\in U=[0,q)`$

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(u)=u`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 5, “Canonical fixed points”.


</details>

---

## PR-C07-006 — Idempotence


### Formal statement

$$
F(F(c))=F(c)
$$


### What the property/control means

The property checks the structural or multi-execution law **Idempotence**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: c in D. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 6, “Idempotence”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-006`

- **Historical identifier:** `CANON-T2.P2`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** c in D

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(F(c))=F(c)`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 6, “Idempotence”.


</details>

---

## PR-C07-007 — Fixed-point characterization


### Formal statement

$$
F(c)=c \Longleftrightarrow c\ge0
$$


### What the property/control means

The property checks the structural or multi-execution law **Fixed-point characterization**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: c in D. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 7, “Exact fixed-point set”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-007`

- **Historical identifier:** `CANON-T2.P3`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** c in D

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(c)=c \Longleftrightarrow c\ge0`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 7, “Exact fixed-point set”.


</details>

---

## PR-C07-008 — Injectivity on canonical domain


### Formal statement

$$
F(u)=F(v) \Longrightarrow u=v
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Injectivity on canonical domain**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: u,v in U. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 8, “Injectivity on canonical representatives”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-008`

- **Historical identifier:** `CANON-T2.P4`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** u,v in U

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(u)=F(v) \Longrightarrow u=v`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 8, “Injectivity on canonical representatives”.


</details>

---

## PR-C07-009 — Modular addition compatibility


### Formal statement

$$
F(x+y)=\mathrm{canon}_q(F(x)+F(y))
$$


### What the property/control means

The property checks the structural or multi-execution law **Modular addition compatibility**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: x,y,x+y in D. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 9, “Addition compatibility”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-009`

- **Historical identifier:** `CANON-T3.P1`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** x,y,x+y in D

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(x+y)=\mathrm{canon}_q(F(x)+F(y))`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 9, “Addition compatibility”.


</details>

---

## PR-C07-010 — Modular subtraction compatibility


### Formal statement

$$
F(x-y)=\mathrm{canon}_q(F(x)-F(y))
$$


### What the property/control means

The property checks the structural or multi-execution law **Modular subtraction compatibility**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: x,y,x-y in D. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 10, “Subtraction compatibility”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-010`

- **Historical identifier:** `CANON-T3.P2`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** x,y,x-y in D

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(x-y)=\mathrm{canon}_q(F(x)-F(y))`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 10, “Subtraction compatibility”.


</details>

---

## PR-C07-011 — Modular negation compatibility


### Formal statement

$$
F(-x)=\mathrm{canon}_q(-F(x))
$$


### What the property/control means

The property checks the structural or multi-execution law **Modular negation compatibility**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: x,-x in D. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 11, “Negation compatibility”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-011`

- **Historical identifier:** `CANON-T3.P3`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** x,-x in D

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(-x)=\mathrm{canon}_q(-F(x))`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 11, “Negation compatibility”.


</details>

---

## PR-C07-012 — Barrett output range


### Formal statement

$$
-q \lt  B(a) \lt  q
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Barrett output range**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: a in int16_t. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 12, “Barrett-output admissibility”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-012`

- **Historical identifier:** `CANON-T4.P1`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in int16_t

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle -q \lt B(a) \lt q`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-012`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 12, “Barrett-output admissibility”.


</details>

---

## PR-C07-013 — Barrett-to-canonical composition


### Formal statement

$$
F(\mathrm{Barrett}(a))=\mathrm{canon}_q(a)
$$


### What the property/control means

The property checks the structural or multi-execution law **Barrett-to-canonical composition**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: a in int16_t. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 13, “Barrett-to-canonical composition”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-013`

- **Historical identifier:** `CANON-T4.P2`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in int16_t

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle F(\mathrm{Barrett}(a))=\mathrm{canon}_q(a)`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-013`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 13, “Barrett-to-canonical composition”.


</details>

---

## PR-C07-014 — Composition congruence


### Formal statement

$$
\mathrm{CanonAfterBarrett}(a)=F(\mathrm{Barrett}(a))
$$


### What the property/control means

The property checks the structural or multi-execution law **Composition congruence**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: a in int16_t; C=F∘B. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 14, “Composition congruence”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-014`

- **Historical identifier:** `CANON-T4.P3`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in int16_t; C=F∘B

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle \mathrm{CanonAfterBarrett}(a)=F(\mathrm{Barrett}(a))`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-014`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 14, “Composition congruence”.


</details>

---

## PR-C07-015 — One-step residue invariance


### Formal statement

$$
\mathrm{CanonAfterBarrett}(a+kq)=\mathrm{CanonAfterBarrett}(a),\qquad k\in\{-1,1\}
$$


### What the property/control means

The property checks the structural or multi-execution law **One-step residue invariance**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: a,a+kq in int16_t. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 15, “Periodicity by one modulus step”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-015`

- **Historical identifier:** `CANON-T4.P4`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a,a+kq in int16_t

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle \mathrm{CanonAfterBarrett}(a+kq)=\mathrm{CanonAfterBarrett}(a),\qquad k\in\{-1,1\}`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-015`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 15, “Periodicity by one modulus step”.


</details>

---

## PR-C07-016 — Agreement on signed conversion domain


### Formal statement

$$
\mathrm{CanonAfterBarrett}(c)=F(c)
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Agreement on signed conversion domain**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: c in D. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 16, “Agreement with direct signed-to-canonical conversion”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-016`

- **Historical identifier:** `CANON-T4.P5`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** c in D

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle \mathrm{CanonAfterBarrett}(c)=F(c)`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-016`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 16, “Agreement with direct signed-to-canonical conversion”.


</details>

---

## PR-C07-017 — Composition idempotence


### Formal statement

$$
\mathrm{CanonAfterBarrett}(\mathrm{CanonAfterBarrett}(a))=\mathrm{CanonAfterBarrett}(a)
$$


### What the property/control means

The property checks the structural or multi-execution law **Composition idempotence**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `CANON T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 12 selected mutants killed across campaign. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `CANON T1–T4 final harness assertion`. The admitted domain is: a in int16_t. The recorded assumptions/grounding are: $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named conversion/composition relation is supported in the stated finite domain.

**What this record does not establish:** Not arbitrary-integer reduction or global mathematical novelty.


### Native-baseline relationship

The frozen native baseline for this case is: A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics. The campaign addition is characterised at case level as: Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 17, “Canonical-composition idempotence”. Chapter 4 uses the case-level principal synthesis in Section 4.4.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C07-017`

- **Historical identifier:** `CANON-T4.P6`

- **Case identifier:** `7`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_scalar_signed_to_unsigned_q`

- **Property class:** `Canonicalization algebra`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in int16_t

- **Assumptions and grounding:** $`D=(-q,q),\;U=[0,q),\;q=3329`$; actual production bodies retained

- **Ledger formal relation:** $`\displaystyle \mathrm{CanonAfterBarrett}(\mathrm{CanonAfterBarrett}(a))=\mathrm{CanonAfterBarrett}(a)`$

- **Assertion / harness mapping:** CANON T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 12 selected mutants killed across campaign

- **Strongest bounded conclusion:** The named conversion/composition relation is supported in the stated finite domain.

- **Explicit exclusion:** Not arbitrary-integer reduction or global mathematical novelty.

- **Evidence locator:** `LOC-C07-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/CANON_CBMC_CAMPAIGN_COMPLETE_A_TO_Z_RECORD.md

- **Archive entry SHA-256:** `a15b9788c95a4825f41a9da3799940fc9fcfb59fe0e90c2645613136f4735572`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C07-017`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 7: Signed-to-Canonical Conversion → item 17, “Canonical-composition idempotence”.


</details>

---


# Case-level bounded conclusion

`SignedToCanon` maps $`D_s=\{-(q-1),\ldots,q-1\}`$ to $`[0,q)`$, with the recorded fibre, idempotence, fixed-point and algebraic laws; $`\mathrm{CanonAfterBarrett}(a)=\mathrm{canon}_q(a)`$ for every `int16_t` input `a`.

**Explicit exclusion.** Not arbitrary-integer reduction or global mathematical novelty.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
