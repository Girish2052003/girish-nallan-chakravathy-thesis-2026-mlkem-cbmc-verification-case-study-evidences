# Case 10 — Polynomial Serialisation

**Target:** `mlk_poly_tobytes`
**Evidence locator:** `LOC-C10-UA`
**Chapter 4 projection:** Section 4.5.2
**Ledger records:** 19
**Formally supported subset:** 19

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

Does the unchanged serializer place each canonical 12-bit coefficient pair into the exact three-byte layout, cover the whole 384-byte result, and preserve injectivity over canonical polynomials?

## Case notation and opening equations


$$
c_0=P_{2i},\quad c_1=P_{2i+1},\quad0\le c_0,c_1\lt q
$$


$$
b_0=B_{3i},\quad b_1=B_{3i+1},\quad b_2=B_{3i+2}
$$


$$
W=b_0+2^8b_1+2^{16}b_2
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
W=c_0+2^{12}c_1
$$


$$
\mathop{\text{ToBytes}}(P)=\mathop{\text{ToBytes}}(Q)\Longleftrightarrow P=Q\quad\text{for canonical }P,Q
$$


**Recorded principal-claim wording:** Each canonical coefficient pair (c0,c1) is encoded as the 24-bit word c0+4096*c1 in the specified 3-byte layout; the complete 384-byte encoding is injective on canonical polynomials.


### Why this claim is the principal case-level synthesis

The pair-level packed-word equation is the compact semantic description of the byte layout, while whole-polynomial injectivity establishes that the complete canonical encoding loses no information. Carry-boundary, locality, overwrite and inversion records ensure that this summary is not inferred from only a few byte positions.


The survival ledger assigns this synthesis to **4.5.2** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768`. Its primary verification focus was: Exact 12-bit coefficient encoding and byte layout; complete buffer write and selected structural/relational obligations. The additional or mixed evidence was: Nineteen obligations, 1,046 successful positive property records, 36 witnesses, 14 intentionally insufficient-unwind controls rejected, and 17 targeted mutants are reported.


The retained case matrix records CBMC execution as **YES — campaign accepted**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** For canonical coefficient arrays in the pinned build, the production serializer writes the exact specified 384-byte 12-bit representation and satisfies the selected safety and structural properties.


**Integrity boundary:** Claims are bound to canonical input coefficients and the public wrapper/portable-C build.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md` with entry SHA-256 `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`. The case archive is `thesis_batch_3.zip` with SHA-256 `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **40** indexed records for `LOC-C10-UA`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite.


**Necessary overlap.** Same wrapper, dimensions and 12-bit format.


**What this campaign added.** Nineteen exact layout, carry-boundary, image and injectivity obligations.


**Why the suite is substantively distinct within the inspected corpus.** Independent byte-level oracle and image/injectivity claims are distinct from native contract-only evidence.


**Comparison material inspected.** Native tobytes proof directory/source contract and PBYTES audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESSES_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tobytes/poly_tobytes_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tobytes/Makefile;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tobytes_c/poly_tobytes_c_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tobytes_c/Makefile

- **Native proof entry SHA-256:** 23f8b50d4fce28432d0cd2121697477ace3382bc43e87ddffc5f8fd0110b1174;8246ad0449b785689b32860b55b232830e42435aca8447d7b87c6c01ff4322da;f3237d410a9ac62a6d01915d0c136b490303a4eb77ed36e6cd1aff23b7507b05;a5b54c2340e07d861ee2defc713a23d61d97d92aba268edb9a5c507ae5988a6e

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.h

- **Production source entry SHA-256:** 9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad;0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

- **Authoritative baseline characterisation:** Native wrapper and portable-C one-call harnesses exist.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DIRECT_SEMANTIC_SUPPORT` | `PR-C10-001`, `PR-C10-002`, `PR-C10-003`, `PR-C10-004`, `PR-C10-005`, `PR-C10-006`, `PR-C10-011`, `PR-C10-012`, `PR-C10-013`, `PR-C10-014`, `PR-C10-015`, `PR-C10-016`, `PR-C10-017`, `PR-C10-018` | states the core value/representation relation |

| `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT` | `PR-C10-007`, `PR-C10-008`, `PR-C10-009`, `PR-C10-010` | establishes the finite domain, range or representation in which the core relation is meaningful |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-C10-019` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `PBYTES-T1.P1`, `PBYTES-T1.P2`, `PBYTES-T1.P3`, `PBYTES-T1.P4`, `PBYTES-T1.P5`, `PBYTES-T1.P6`, `PBYTES-T2.P1`, `PBYTES-T2.P2`, `PBYTES-T2.P3`, `PBYTES-T2.P4`, `PBYTES-T3.P1`, `PBYTES-T3.P2`, `PBYTES-T3.P3`, `PBYTES-T3.P4`, `PBYTES-T3.P5`, `PBYTES-T4.P1`, `PBYTES-T4.P2`, `PBYTES-T4.P3`, `PBYTES-T4.P4`


## Thesis-appendix projection


The compact Appendix 1 projection contains **19** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `LIM-C10-COUNT` | `COUNTING_BOUNDARY` | Includes indexed obligations and tool-generated safety checks. | Do not report as 1,046 independent theorems or scientific claims. |


## Assurance-layer and literature relationship

This comparison prevents repository-relative distinctness from being rewritten as global mathematical novelty. The rows below are interpretive context; implementation support still comes from the source-bound evidence for this case.

| Source/project | Relationship | Overlap | Important difference | Permitted conclusion |
|---|---|---|---|---|

| NIST FIPS 203 (2024a) | `NORMATIVE_GROUNDING` | Grounds ML-KEM operations, domains and data formats relevant to the case. | FIPS 203 is not a proof that this C implementation or generated harness is correct. | The case is specification-grounded where applicable; implementation support comes from the recorded source-bound CBMC evidence, not from the standard alone. |

| PQ Code Package / mlkem-native assurance documentation (n.d.-a; n.d.-b) | `NATIVE_ASSURANCE_CONTEXT` | Shares the exact production repository and some target contracts/harness infrastructure. | Native artefacts support different or narrower property sets and different assurance layers; the case-specific distinction is recorded in matrix 04. | Report repository-relative generated artefact/property contribution, not absence of all prior assurance. |

| Formosa Crypto and Almeida et al. (2023; 2024; 2025) | `RELATED_PROOF_ORIENTED_ASSURANCE` | Covers ML-KEM/Kyber functional and representation reasoning in proof-oriented settings. | Different implementation language/source, specifications, proof infrastructure and assurance boundary from local CBMC checks over mlkem-native C. | Use as assurance-layer comparison; do not claim the first formal proof of the underlying mathematics or operation. |

| HACL* and EverCrypt (Zinzindohoué et al., 2017; Protzenko et al., 2020) | `RELATED_VERIFIED_CRYPTOGRAPHIC_IMPLEMENTATION_CONTEXT` | Demonstrates verified functional/memory/representation artefacts in other cryptographic codebases. | Different implementations, languages, specifications and trusted toolchains. | Use only as broader high-assurance context, not an exact prior-art match. |


## Publication-state and traceability-field note

The record blocks below preserve the frozen RC2 public-path fields only as explicitly labelled historical provenance. Their former `PENDING`, `UNRESOLVED_UNTIL_FINALIZER`, blank public-SHA and candidate-count values describe the pre-finalization snapshot; they do **not** describe the current repository. The current authoritative ledger records all 257 substantive records as `RESOLVED_HASH_MATCH` and supplies the exact current public path and SHA-256. To avoid creating a second mutable authority, this catalogue points each record back to its current ledger row instead of copying those current path/hash strings into prose.

Scientific outcome status is independent. Supported, negative, abstraction-limited, resource-limited, diagnostic, construction and preservation classifications are reproduced unchanged.

# Complete record-by-record catalogue


## PR-C10-001 — First output byte


### Formal statement

$$
b_0=c_0\bmod 2^8
$$


### What the property/control means

The property gives a direct semantic characterisation of **First output byte** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 1, “First-byte relation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-001`

- **Historical identifier:** `PBYTES-T1.P1`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle b_0=c_0\bmod 2^8`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Thesis-and-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 1, “First-byte relation”.


</details>

---

## PR-C10-002 — Middle-byte low nibble


### Formal statement

$$
b_1\bmod 16=\left\lfloor\frac{c_0}{2^8}\right\rfloor
$$


### What the property/control means

The property gives a direct semantic characterisation of **Middle-byte low nibble** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 2, “Low nibble of the second byte”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-002`

- **Historical identifier:** `PBYTES-T1.P2`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle b_1\bmod 16=\left\lfloor\frac{c_0}{2^8}\right\rfloor`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 2, “Low nibble of the second byte”.


</details>

---

## PR-C10-003 — Middle-byte high nibble


### Formal statement

$$
b_1\gg4=c_1\bmod16
$$


### What the property/control means

The property gives a direct semantic characterisation of **Middle-byte high nibble** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 3, “High nibble of the second byte”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-003`

- **Historical identifier:** `PBYTES-T1.P3`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle b_1\gg4=c_1\bmod16`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 3, “High nibble of the second byte”.


</details>

---

## PR-C10-004 — Third output byte


### Formal statement

$$
b_2=\left\lfloor\frac{c_1}{16}\right\rfloor
$$


### What the property/control means

The property gives a direct semantic characterisation of **Third output byte** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 4, “Third-byte relation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-004`

- **Historical identifier:** `PBYTES-T1.P4`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle b_2=\left\lfloor\frac{c_1}{16}\right\rfloor`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 4, “Third-byte relation”.


</details>

---

## PR-C10-005 — 24-bit packed-word equality


### Formal statement

$$
W=c_0+2^{12}c_1
$$


### What the property/control means

The property gives a direct semantic characterisation of **24-bit packed-word equality** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 5, “Exact 24-bit packed-word relation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-005`

- **Historical identifier:** `PBYTES-T1.P5`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle W=c_0+2^{12}c_1`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 5, “Exact 24-bit packed-word relation”.


</details>

---

## PR-C10-006 — Full 384-byte oracle equality


### Formal statement

$$
\mathop{\text{ToBytes}}(P)=E_{\mathrm{arith}}(P)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Full 384-byte oracle equality** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 6, “Complete 384-byte encoder refinement”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-006`

- **Historical identifier:** `PBYTES-T1.P6`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathop{\text{ToBytes}}(P)=E_{\mathrm{arith}}(P)`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 6, “Complete 384-byte encoder refinement”.


</details>

---

## PR-C10-007 — Even-field no-carry boundary


### Formal statement

$$
\begin{array}{rl}c_0+1&\lt q,\quad c_0\bmod256\ne255\\&\Longrightarrow\quad b_0\prime=b_0+1,\quad b_1\prime=b_1,\quad b_2\prime=b_2.\end{array}
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Even-field no-carry boundary**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 7, “Even-coefficient non-carry increment relation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-007`

- **Historical identifier:** `PBYTES-T2.P1`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \begin{array}{rl}c_0+1&\lt q,\quad c_0\bmod256\ne255\\&\Longrightarrow\quad b_0\prime=b_0+1,\quad b_1\prime=b_1,\quad b_2\prime=b_2.\end{array}`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Source-evidence audited equation from the retained PBYTES-T2 carry-regime record.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 7, “Even-coefficient non-carry increment relation”.


</details>

---

## PR-C10-008 — Even 255-to-256 carry boundary


### Formal statement

$$
c_0+1\lt q\land c_0\bmod256=255\Longrightarrow b_0\prime=0\land(b_1\prime\bmod16)=(b_1\bmod16)+1\land\left\lfloor\frac{b_1\prime}{16}\right\rfloor=\left\lfloor\frac{b_1}{16}\right\rfloor\land b_2\prime=b_2
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Even 255-to-256 carry boundary**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 8, “Even-coefficient byte-carry relation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-008`

- **Historical identifier:** `PBYTES-T2.P2`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle c_0+1\lt q\land c_0\bmod256=255\Longrightarrow b_0\prime=0\land(b_1\prime\bmod16)=(b_1\bmod16)+1\land\left\lfloor\frac{b_1\prime}{16}\right\rfloor=\left\lfloor\frac{b_1}{16}\right\rfloor\land b_2\prime=b_2`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Source-evidence audited equation from the retained PBYTES-T2 carry-regime record.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 8, “Even-coefficient byte-carry relation”.


</details>

---

## PR-C10-009 — Odd-field no-nibble-carry boundary


### Formal statement

$$
\begin{array}{rl}c_1+1&\lt q,\quad c_1\bmod16\ne15\\&\Longrightarrow\quad b_0\prime=b_0,\quad b_1\prime=b_1+16,\quad b_2\prime=b_2.\end{array}
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Odd-field no-nibble-carry boundary**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 9, “Odd-coefficient non-nibble-carry relation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-009`

- **Historical identifier:** `PBYTES-T2.P3`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \begin{array}{rl}c_1+1&\lt q,\quad c_1\bmod16\ne15\\&\Longrightarrow\quad b_0\prime=b_0,\quad b_1\prime=b_1+16,\quad b_2\prime=b_2.\end{array}`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Source-evidence audited equation from the retained PBYTES-T2 carry-regime record.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 9, “Odd-coefficient non-nibble-carry relation”.


</details>

---

## PR-C10-010 — Odd 15-to-16 nibble carry boundary


### Formal statement

$$
c_1+1\lt q\land c_1\bmod16=15\Longrightarrow b_0\prime=b_0\land(b_1\prime\bmod16)=(b_1\bmod16)\land\left\lfloor\frac{b_1\prime}{16}\right\rfloor=0\land b_2\prime=b_2+1
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Odd 15-to-16 nibble carry boundary**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 10, “Odd-coefficient $`15 \rightarrow 16`$ carry relation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-010`

- **Historical identifier:** `PBYTES-T2.P4`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle c_1+1\lt q\land c_1\bmod16=15\Longrightarrow b_0\prime=b_0\land(b_1\prime\bmod16)=(b_1\bmod16)\land\left\lfloor\frac{b_1\prime}{16}\right\rfloor=0\land b_2\prime=b_2+1`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Source-evidence audited equation from the retained PBYTES-T2 carry-regime record.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 10, “Odd-coefficient $`15 \rightarrow 16`$ carry relation”.


</details>

---

## PR-C10-011 — Produced even field canonical


### Formal statement

$$
0\le d_0\lt q
$$


### What the property/control means

The property gives a direct semantic characterisation of **Produced even field canonical** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 11, “Canonicality of the produced even field”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-011`

- **Historical identifier:** `PBYTES-T3.P1`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle 0\le d_0\lt q`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Thesis-and-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 11, “Canonicality of the produced even field”.


</details>

---

## PR-C10-012 — Produced odd field canonical


### Formal statement

$$
0\le d_1\lt q
$$


### What the property/control means

The property gives a direct semantic characterisation of **Produced odd field canonical** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 12, “Canonicality of the produced odd field”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-012`

- **Historical identifier:** `PBYTES-T3.P2`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle 0\le d_1\lt q`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-012`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Thesis-and-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 12, “Canonicality of the produced odd field”.


</details>

---

## PR-C10-013 — Every canonical block realizable


### Formal statement

$$
\forall(c_0,c_1)\in[0,q)^2\;\exists B_i\in\{0,\ldots,255\}^3:\quad \mathop{\text{Decode}}_{12}(B_i)=(c_0,c_1)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Every canonical block realizable** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 13, “Realisability of every canonical coefficient pair”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-013`

- **Historical identifier:** `PBYTES-T3.P3`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \forall(c_0,c_1)\in[0,q)^2\;\exists B_i\in\{0,\ldots,255\}^3:\quad \mathop{\text{Decode}}_{12}(B_i)=(c_0,c_1)`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-013`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Thesis-and-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 13, “Realisability of every canonical coefficient pair”.


</details>

---

## PR-C10-014 — Invalid-field block not realizable


### Formal statement

$$
\left(d_0\ge q\;\lor\;d_1\ge q\right)\Longrightarrow B_i\notin\mathop{\text{Im}}(\mathop{\text{Encode}}_{12})
$$


### What the property/control means

The property gives a direct semantic characterisation of **Invalid-field block not realizable** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 14, “Exclusion of non-canonical decoded blocks”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-014`

- **Historical identifier:** `PBYTES-T3.P4`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \left(d_0\ge q\;\lor\;d_1\ge q\right)\Longrightarrow B_i\notin\mathop{\text{Im}}(\mathop{\text{Encode}}_{12})`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-014`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Thesis-and-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 14, “Exclusion of non-canonical decoded blocks”.


</details>

---

## PR-C10-015 — Full-array image characterization


### Formal statement

$$
B\in\mathop{\text{Im}}(\mathop{\text{ToBytes}})\Longleftrightarrow\forall i:\;\mathop{\text{decoded}}_{12}(B,i)\lt q
$$


### What the property/control means

The property gives a direct semantic characterisation of **Full-array image characterization** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 15, “Complete image characterisation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-015`

- **Historical identifier:** `PBYTES-T3.P5`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle B\in\mathop{\text{Im}}(\mathop{\text{ToBytes}})\Longleftrightarrow\forall i:\;\mathop{\text{decoded}}_{12}(B,i)\lt q`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-015`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 15, “Complete image characterisation”.


</details>

---

## PR-C10-016 — Even coefficient recovery


### Formal statement

$$
\mathrm{Decode}(\mathrm{Encode}(P))_{2i}=P_{2i}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Even coefficient recovery** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 16, “Even-coordinate decoder inversion”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-016`

- **Historical identifier:** `PBYTES-T4.P1`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathrm{Decode}(\mathrm{Encode}(P))_{2i}=P_{2i}`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-016`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 16, “Even-coordinate decoder inversion”.


</details>

---

## PR-C10-017 — Odd coefficient recovery


### Formal statement

$$
\mathrm{Decode}(\mathrm{Encode}(P))_{2i+1}=P_{2i+1}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Odd coefficient recovery** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 17, “Odd-coordinate decoder inversion”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-017`

- **Historical identifier:** `PBYTES-T4.P2`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathrm{Decode}(\mathrm{Encode}(P))_{2i+1}=P_{2i+1}`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-017`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 17, “Odd-coordinate decoder inversion”.


</details>

---

## PR-C10-018 — Block equality iff coefficient-pair equality


### Formal statement

$$
E(c_0,c_1)=E(d_0,d_1)\Longleftrightarrow(c_0,c_1)=(d_0,d_1)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Block equality iff coefficient-pair equality** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 18, “Pair-level injectivity”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-018`

- **Historical identifier:** `PBYTES-T4.P3`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle E(c_0,c_1)=E(d_0,d_1)\Longleftrightarrow(c_0,c_1)=(d_0,d_1)`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-018`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Thesis-and-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 18, “Pair-level injectivity”.


</details>

---

## PR-C10-019 — Full canonical-polynomial injectivity


### Formal statement

$$
\mathrm{ToBytes}(P)=\mathrm{ToBytes}(Q)\Longleftrightarrow P=Q
$$


### What the property/control means

The property checks the structural or multi-execution law **Full canonical-polynomial injectivity**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBYTES T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 17 selected mutants killed; 14 insufficient-unwind controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBYTES T1–T4 final harness assertion`. The admitted domain is: Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named exact encoding, boundary, image or injectivity relation is supported.

**What this record does not establish:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite. The campaign addition is characterised at case level as: Nineteen exact layout, carry-boundary, image and injectivity obligations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 19, “Whole-polynomial injectivity”. Chapter 4 uses the case-level principal synthesis in Section 4.5.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C10-019`

- **Historical identifier:** `PBYTES-T4.P4`

- **Case identifier:** `10`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes`

- **Property class:** `Serialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficients $`\{0,\ldots,3328\}`$; 256 coefficients; 384-byte output

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathrm{ToBytes}(P)=\mathrm{ToBytes}(Q)\Longleftrightarrow P=Q`$

- **Assertion / harness mapping:** PBYTES T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 17 selected mutants killed; 14 insufficient-unwind controls rejected

- **Strongest bounded conclusion:** The named exact encoding, boundary, image or injectivity relation is supported.

- **Explicit exclusion:** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.

- **Evidence locator:** `LOC-C10-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOBYTES_CBMC_CAMPAIGN_A_TO_Z.md

- **Archive entry SHA-256:** `327f7c2c4bf2b4ee343ffbe6c14ce6d29ada1f09cb1c58d6527f2123553b48d8`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C10-019`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 10: Polynomial Serialisation: mlk_poly_tobytes → item 19, “Whole-polynomial injectivity”.


</details>

---


# Case-level bounded conclusion

Each canonical coefficient pair (c0,c1) is encoded as the 24-bit word c0+4096*c1 in the specified 3-byte layout; the complete 384-byte encoding is injective on canonical polynomials.

**Explicit exclusion.** 1046 emitted CBMC records are not 1046 independent scientific claims; no non-canonical-input claim.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
