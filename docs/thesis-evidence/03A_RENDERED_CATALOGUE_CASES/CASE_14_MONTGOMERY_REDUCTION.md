# Case 14 — Montgomery Reduction

**Target:** `mlk_montgomery_reduce; candidate mlk_fqmul / mlk_poly_tomont_c extensions`
**Evidence locator:** `LOC-C14-UA`
**Chapter 4 projection:** Section 4.5.6
**Ledger records:** 21
**Formally supported subset:** 5

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768 build
**Evidence completeness:** `COMPLETE`

## Verification question

What exact bounded relation is supported for the production Montgomery reduction over its legal source domain, and which stronger relational, multiplication and polynomial-conversion propositions remained unresolved?

## Case notation and opening equations


$$
M(a)=\mathop{\text{MontRed}}(a),\qquad R_M=2^{16}
$$


$$
-2038398974\le a\le2038398974
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
M(a)=\mathop{\text{MontOracle}}(a)
$$


$$
a=R_M M(a)+qt
$$


$$
-32767\le M(a)\le32767
$$


**Recorded principal-claim wording:** MONT-T1: reduce(a)=independent_oracle(a) over the complete legal source domain, with exact reconstruction, unique signed-16 decomposition and sharp image [-32767,32767]. MONT-T2–T4 remain resource-limited and inconclusive.


### Why this claim is the principal case-level synthesis

Only MONT-T1 obtained completed supporting evidence, so only its exact oracle equality, reconstruction and sharp image can anchor the principal accepted claim. MONT-T2–T4 are retained because they define scientifically meaningful extensions, but their resource-limited status is itself part of the case conclusion and prevents them from being folded into the supported claim.


The survival ledger assigns this synthesis to **4.5.6** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768 build`. Its primary verification focus was: MONT-T1 full-domain exact functional refinement of mlk_montgomery_reduce against an independent oracle. The additional or mixed evidence was: MONT-T2 relational fibre laws, MONT-T3 normalized multiplication algebra and MONT-T4 polynomial conversion/round-trip/locality were attempted but did not complete. Manually supplied terminal-style success summaries for T2–T4 were explicitly excluded as invalid evidence..


The retained case matrix records CBMC execution as **YES — MONT-T1 completed with 12 required assertions; T2–T4 executions were computationally inconclusive**. Claim-to-artefact mapping is `YES for T1; YES candidate mapping but no completed verdict for T2–T4`; target reachability `YES for T1; not sufficient for a proof of T2–T4`; assertion reachability `YES for T1; unresolved for T2–T4`; assumption feasibility `YES for T1; partial/attempt-specific for T2–T4`; non-vacuity `YES for T1`; mutation/control status `YES for T1; synthetic T2–T4 mutation claims excluded`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** Only the exact T1 reduction theorem is verified. T2–T4 remain candidate designs and computationally inconclusive; no supplied or synthetic PASS marker may be treated as CBMC evidence.


**Integrity boundary:** The corrected record supersedes earlier overclaims. Approximate eight-hour durations lack independent timestamp support and must not be reported as exact measurements.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md` with entry SHA-256 `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`. The case archive is `thesis_batch_1.zip` with SHA-256 `b7d4a0c238997f323abb93974243f93bcc0afe65f48cecd94d3b6af93f89c0d0`. Evidence completeness is `COMPLETE`.
 The recorded limitation is: MONT-T2–T4 resource-limited and inconclusive; synthetic success summaries excluded.



The representative artefact map contains **32** indexed records for `LOC-C14-UA`: COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance.


**Necessary overlap.** Same production functions, Montgomery constants and contract domain.


**What this campaign added.** T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs.


**Why the suite is substantively distinct within the inspected corpus.** T1 adds independent functional/refinement and sharp-image obligations; T2–T4 are distinct candidate designs but remain unresolved.


**Comparison material inspected.** Native proof directories, production contracts, HOL Light/backend documentation and corrected MONT audit.


**Permitted distinctness conclusion:** `SUPPORTED_FOR_T1; CANDIDATE_LEVEL_ONLY_FOR_T2_T4`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESSES_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/montgomery_reduce/montgomery_reduce_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/montgomery_reduce/Makefile;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/fqmul/fqmul_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/fqmul/Makefile;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tomont_c/poly_tomont_c_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tomont_c/Makefile

- **Native proof entry SHA-256:** 9b12179135d0cf6b7e1d79e5ab5883bd376228f9672b8dbf4ad7039125df944d;beadf31620e8118e45153d7f65e69667fde5da8c8b26aa18d6a46aa1253da46f;b03b722e44d3b6bf18cb4dd82c5166c074a29ed0f54c9c90eacb8e80f376093a;318daff8367947f35adf20e005cc2702d21b25f2a86560627b1cfba579fcf67d;bd44942ac9f5b7e1dd00577c3a4f66466004d84186bfeb12e8ac03eb7bc8e45b;64fd6c18f4df960ad8ae21e0cb92b5e1d8d246f7cca041be5afca8f8841df725

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/poly.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/poly.h

- **Production source entry SHA-256:** f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722;f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef

- **Authoritative baseline characterisation:** Dedicated native one-call harnesses exist for all three local targets.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DIRECT_SEMANTIC_SUPPORT` | `PR-C14-001`, `PR-C14-002`, `PR-C14-003`, `PR-C14-005` | states the core value/representation relation |

| `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT` | `PR-C14-004` | establishes the finite domain, range or representation in which the core relation is meaningful |

| `UNRESOLVED_BOUNDARY` | `PR-C14-006`, `PR-C14-007`, `PR-C14-008`, `PR-C14-009`, `PR-C14-010`, `PR-C14-011`, `PR-C14-012`, `PR-C14-013`, `PR-C14-014`, `PR-C14-015`, `PR-C14-016`, `PR-C14-017`, `PR-C14-018`, `PR-C14-019`, `PR-C14-020`, `PR-C14-021` | records a stronger proposition that remains unresolved and therefore stays outside the supported claim |


**Survival-ledger supporting historical IDs:** `MONT-T1.P1`, `MONT-T1.P2`, `MONT-T1.P3`, `MONT-T1.P4`, `MONT-T1.P5`


**Survival-ledger contrary/unresolved IDs:** `MONT-T2.P1`, `MONT-T2.P2`, `MONT-T2.P3`, `MONT-T2.P4`, `MONT-T2.P5`, `MONT-T3.P1`, `MONT-T3.P2`, `MONT-T3.P3`, `MONT-T3.P4`, `MONT-T3.P5`, `MONT-T3.P6`, `MONT-T4.P1`, `MONT-T4.P2`, `MONT-T4.P3`, `MONT-T4.P4`, `MONT-T4.P5`


## Thesis-appendix projection


The compact Appendix 1 projection contains **5** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `INC-C14-T2` | `RESOURCE_LIMITED_INCONCLUSIVE` | No completed verdict or counterexample after researcher-reported >~6.5h continuous execution. | Candidate retained unresolved. |

| `INC-C14-T3` | `RESOURCE_LIMITED_INCONCLUSIVE` | No completed verdict or counterexample after researcher-reported >~6.5h continuous execution. | Candidate retained unresolved. |

| `INC-C14-T4` | `RESOURCE_LIMITED_INCONCLUSIVE` | No completed verdict or counterexample after researcher-reported >~6.5h continuous execution. | Candidate retained unresolved. |

| `EXC-C14-SYN` | `EXCLUDED_INVALID` | Not backed by authentic completed CBMC records. | Excluded from accepted evidence. |


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


## PR-C14-001 — Independent exact oracle equality


### Formal statement

$$
M(a)=\mathrm{MontOracle}(a)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Independent exact oracle equality** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MONT-T1 audited assertion family (12 required assertions)`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 3/3 selected T1 mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T1 audited assertion family (12 required assertions)`. The admitted domain is: a in complete source-contract domain [-2038398974,2038398974]. The recorded assumptions/grounding are: Arithmetic-right-shift model; complete target source contract; independent oracle. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact T1 reduction/refinement relation is supported over the full legal domain.

**What this record does not establish:** Does not establish every Montgomery arithmetic property.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 1, “Independent-oracle refinement”. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-001`

- **Historical identifier:** `MONT-T1.P1`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery reduction refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in complete source-contract domain [-2038398974,2038398974]

- **Assumptions and grounding:** Arithmetic-right-shift model; complete target source contract; independent oracle

- **Ledger formal relation:** reduce(a)=independent_oracle(a)

- **Assertion / harness mapping:** MONT-T1 audited assertion family (12 required assertions)

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 3/3 selected T1 mutants killed

- **Strongest bounded conclusion:** The exact T1 reduction/refinement relation is supported over the full legal domain.

- **Explicit exclusion:** Does not establish every Montgomery arithmetic property.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 1, “Independent-oracle refinement”.


</details>

---

## PR-C14-002 — Exact reconstruction and scaled congruence


### Formal statement

$$
a=R_M\,M(a)+q\,t
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact reconstruction and scaled congruence** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MONT-T1 audited assertion family (12 required assertions)`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 3/3 selected T1 mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T1 audited assertion family (12 required assertions)`. The admitted domain is: a in complete source-contract domain [-2038398974,2038398974]. The recorded assumptions/grounding are: Arithmetic-right-shift model; complete target source contract; independent oracle. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact T1 reduction/refinement relation is supported over the full legal domain.

**What this record does not establish:** Does not establish every Montgomery arithmetic property.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 2, “Exact Montgomery reconstruction”. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-002`

- **Historical identifier:** `MONT-T1.P2`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery reduction refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in complete source-contract domain [-2038398974,2038398974]

- **Assumptions and grounding:** Arithmetic-right-shift model; complete target source contract; independent oracle

- **Ledger formal relation:** a=R*reduce(a)+q*t for a signed witness t, with the registered modular relation

- **Assertion / harness mapping:** MONT-T1 audited assertion family (12 required assertions)

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 3/3 selected T1 mutants killed

- **Strongest bounded conclusion:** The exact T1 reduction/refinement relation is supported over the full legal domain.

- **Explicit exclusion:** Does not establish every Montgomery arithmetic property.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 2, “Exact Montgomery reconstruction”.


</details>

---

## PR-C14-003 — Unique signed-16 decomposition


### Formal statement

$$
\begin{array}{rl}a&=R_M\,r+q\,t=R_M\,r\prime+q\,t\prime,\\(r,t),(r\prime,t\prime)&\in D_{\mathrm{signed16}}\Longrightarrow r=r\prime\land t=t\prime.\end{array}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Unique signed-16 decomposition** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MONT-T1 audited assertion family (12 required assertions)`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 3/3 selected T1 mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T1 audited assertion family (12 required assertions)`. The admitted domain is: a in complete source-contract domain [-2038398974,2038398974]. The recorded assumptions/grounding are: Arithmetic-right-shift model; complete target source contract; independent oracle. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact T1 reduction/refinement relation is supported over the full legal domain.

**What this record does not establish:** Does not establish every Montgomery arithmetic property.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 3, “Unique signed decomposition”. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-003`

- **Historical identifier:** `MONT-T1.P3`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery reduction refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in complete source-contract domain [-2038398974,2038398974]

- **Assumptions and grounding:** Arithmetic-right-shift model; complete target source contract; independent oracle

- **Ledger formal relation:** the result/witness decomposition is unique in the registered signed-16 ranges

- **Assertion / harness mapping:** MONT-T1 audited assertion family (12 required assertions)

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 3/3 selected T1 mutants killed

- **Strongest bounded conclusion:** The exact T1 reduction/refinement relation is supported over the full legal domain.

- **Explicit exclusion:** Does not establish every Montgomery arithmetic property.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Ledger-faithful rendered uniqueness relation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 3, “Unique signed decomposition”.


</details>

---

## PR-C14-004 — Sharp full-domain output bound


### Formal statement

$$
\forall a\in D_{\mathrm{legal}}:\quad -32767\le M(a)\le32767
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Sharp full-domain output bound**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MONT-T1 audited assertion family (12 required assertions)`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 3/3 selected T1 mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T1 audited assertion family (12 required assertions)`. The admitted domain is: a in complete source-contract domain [-2038398974,2038398974]. The recorded assumptions/grounding are: Arithmetic-right-shift model; complete target source contract; independent oracle. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact T1 reduction/refinement relation is supported over the full legal domain.

**What this record does not establish:** Does not establish every Montgomery arithmetic property.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 4, “Sharp signed output range”. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-004`

- **Historical identifier:** `MONT-T1.P4`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery reduction refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in complete source-contract domain [-2038398974,2038398974]

- **Assumptions and grounding:** Arithmetic-right-shift model; complete target source contract; independent oracle

- **Ledger formal relation:** -32767 <= reduce(a) <= 32767 for the complete source-contract domain

- **Assertion / harness mapping:** MONT-T1 audited assertion family (12 required assertions)

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 3/3 selected T1 mutants killed

- **Strongest bounded conclusion:** The exact T1 reduction/refinement relation is supported over the full legal domain.

- **Explicit exclusion:** Does not establish every Montgomery arithmetic property.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 4, “Sharp signed output range”.


</details>

---

## PR-C14-005 — Endpoint attainability


### Formal statement

$$
\exists a_{-},a_{+}\in D_{\mathrm{legal}}:\quad M(a_{-})=-32767,\qquad M(a_{+})=32767
$$


### What the property/control means

The property gives a direct semantic characterisation of **Endpoint attainability** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MONT-T1 audited assertion family (12 required assertions)`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 3/3 selected T1 mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T1 audited assertion family (12 required assertions)`. The admitted domain is: a in complete source-contract domain [-2038398974,2038398974]. The recorded assumptions/grounding are: Arithmetic-right-shift model; complete target source contract; independent oracle. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact T1 reduction/refinement relation is supported over the full legal domain.

**What this record does not establish:** Does not establish every Montgomery arithmetic property.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 5, “Attainability of both output endpoints”. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-005`

- **Historical identifier:** `MONT-T1.P5`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery reduction refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in complete source-contract domain [-2038398974,2038398974]

- **Assumptions and grounding:** Arithmetic-right-shift model; complete target source contract; independent oracle

- **Ledger formal relation:** both -32767 and 32767 occur at registered legal inputs

- **Assertion / harness mapping:** MONT-T1 audited assertion family (12 required assertions)

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 3/3 selected T1 mutants killed

- **Strongest bounded conclusion:** The exact T1 reduction/refinement relation is supported over the full legal domain.

- **Explicit exclusion:** Does not establish every Montgomery arithmetic property.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 14: Montgomery Reduction: mlk_montgomery_reduce → item 5, “Attainability of both output endpoints”.


</details>

---

## PR-C14-006 — Canonical low-word normalization


### Formal statement

$$
0\le \mathop{\text{low}}_{16}(a)\le65535
$$


### What the property/control means

This record formalises **Canonical low-word normalization** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T2 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T2 candidate harness`. The admitted domain is: Complete legal input constraints plus property-specific fibre/translation premise. The recorded assumptions/grounding are: Candidate harness designed and executed; no completed solver verdict. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate.

**What this record does not establish:** Must not be described as passed, verified or refuted.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T2.P1 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-006`

- **Historical identifier:** `MONT-T2.P1`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Relational Montgomery candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Complete legal input constraints plus property-specific fibre/translation premise

- **Assumptions and grounding:** Candidate harness designed and executed; no completed solver verdict

- **Ledger formal relation:** normalized low words lie in [0,65535]

- **Assertion / harness mapping:** MONT-T2 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate.

- **Explicit exclusion:** Must not be described as passed, verified or refuted.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Appendix 2 / MONT-T2.P1 candidate relation.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T2.P1 resource-limited candidate


</details>

---

## PR-C14-007 — Relational scaled-residue law


### Formal statement

$$
\bigl(M(b)-M(a)\bigr)R\equiv b-a\pmod q
$$


### What the property/control means

This record formalises **Relational scaled-residue law** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T2 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T2 candidate harness`. The admitted domain is: Complete legal input constraints plus property-specific fibre/translation premise. The recorded assumptions/grounding are: Candidate harness designed and executed; no completed solver verdict. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate.

**What this record does not establish:** Must not be described as passed, verified or refuted.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T2.P2 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-007`

- **Historical identifier:** `MONT-T2.P2`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Relational Montgomery candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Complete legal input constraints plus property-specific fibre/translation premise

- **Assumptions and grounding:** Candidate harness designed and executed; no completed solver verdict

- **Ledger formal relation:** (reduce(b)-reduce(a))*R ≡ b-a (mod q)

- **Assertion / harness mapping:** MONT-T2 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate.

- **Explicit exclusion:** Must not be described as passed, verified or refuted.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Appendix 2 / MONT-T2.P2 candidate relation.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T2.P2 resource-limited candidate


</details>

---

## PR-C14-008 — Equal-low-word affine law


### Formal statement

$$
\mathop{\text{low}}_{16}(a)=\mathop{\text{low}}_{16}(b)
\Longrightarrow
\left(
b-a\in R\mathbb{Z}
\;\land\;
M(b)-M(a)=\frac{b-a}{R}
\right)
$$


### What the property/control means

This record formalises **Equal-low-word affine law** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T2 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T2 candidate harness`. The admitted domain is: Complete legal input constraints plus property-specific fibre/translation premise. The recorded assumptions/grounding are: Candidate harness designed and executed; no completed solver verdict. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate.

**What this record does not establish:** Must not be described as passed, verified or refuted.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T2.P3 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-008`

- **Historical identifier:** `MONT-T2.P3`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Relational Montgomery candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Complete legal input constraints plus property-specific fibre/translation premise

- **Assumptions and grounding:** Candidate harness designed and executed; no completed solver verdict

- **Ledger formal relation:** same canonical low 16 bits => reduce(b)-reduce(a)=(b-a)/R

- **Assertion / harness mapping:** MONT-T2 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate.

- **Explicit exclusion:** Must not be described as passed, verified or refuted.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Appendix 2 / retained MONT-T2.P3 candidate relation; equal-low-word premise made explicit.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T2.P3 resource-limited candidate


</details>

---

## PR-C14-009 — Injectivity inside low-word fibre


### Formal statement

$$
\mathop{\text{low}}_{16}(a)=\mathop{\text{low}}_{16}(b)\Longrightarrow\bigl(M(a)=M(b)\Longleftrightarrow a=b\bigr)
$$


### What the property/control means

This record formalises **Injectivity inside low-word fibre** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T2 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T2 candidate harness`. The admitted domain is: Complete legal input constraints plus property-specific fibre/translation premise. The recorded assumptions/grounding are: Candidate harness designed and executed; no completed solver verdict. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate.

**What this record does not establish:** Must not be described as passed, verified or refuted.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T2.P4 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-009`

- **Historical identifier:** `MONT-T2.P4`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Relational Montgomery candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Complete legal input constraints plus property-specific fibre/translation premise

- **Assumptions and grounding:** Candidate harness designed and executed; no completed solver verdict

- **Ledger formal relation:** under equal-low-word premise, reduce(a)=reduce(b) iff a=b

- **Assertion / harness mapping:** MONT-T2 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate.

- **Explicit exclusion:** Must not be described as passed, verified or refuted.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Appendix 2 / retained MONT-T2.P4 candidate relation; fibre premise made explicit.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T2.P4 resource-limited candidate


</details>

---

## PR-C14-010 — General fibre translation


### Formal statement

$$
a,a+kR\in D_M\Longrightarrow M(a+kR)=M(a)+k
$$


### What the property/control means

This record formalises **General fibre translation** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T2 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T2 candidate harness`. The admitted domain is: Complete legal input constraints plus property-specific fibre/translation premise. The recorded assumptions/grounding are: Candidate harness designed and executed; no completed solver verdict. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate.

**What this record does not establish:** Must not be described as passed, verified or refuted.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T2.P5 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-010`

- **Historical identifier:** `MONT-T2.P5`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Relational Montgomery candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Complete legal input constraints plus property-specific fibre/translation premise

- **Assumptions and grounding:** Candidate harness designed and executed; no completed solver verdict

- **Ledger formal relation:** reduce(a+kR)=reduce(a)+k whenever both inputs remain legal

- **Assertion / harness mapping:** MONT-T2 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate.

- **Explicit exclusion:** Must not be described as passed, verified or refuted.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Appendix 2 / retained MONT-T2.P5 candidate relation; legal-domain premise made explicit.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T2.P5 resource-limited candidate


</details>

---

## PR-C14-011 — Independent multiplication refinement


### Formal statement

$$
\mathop{\text{Norm}}_q(F(a,b))=\mathop{\text{Norm}}_q\!\left(a b R^{-1}\right)
$$


### What the property/control means

This record formalises **Independent multiplication refinement** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T3 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T3 candidate harness`. The admitted domain is: int16 first operand; signed-canonical second operand and property-specific normalized domains. The recorded assumptions/grounding are: Candidate model canonicalizes residues before comparison. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No completed proof of mlk_fqmul algebra or additional reduction claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T3.P1 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-011`

- **Historical identifier:** `MONT-T3.P1`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery multiplication candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** int16 first operand; signed-canonical second operand and property-specific normalized domains

- **Assumptions and grounding:** Candidate model canonicalizes residues before comparison

- **Ledger formal relation:** fqmul agrees modulo q with an independent Montgomery-product model

- **Assertion / harness mapping:** MONT-T3 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No completed proof of mlk_fqmul algebra or additional reduction claim.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Conservative formalisation of the retained MONT-T3.P1 independent Montgomery-product candidate; equality is between canonical residue representatives.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T3.P1 resource-limited candidate


</details>

---

## PR-C14-012 — Normalized commutativity


### Formal statement

$$
\mathop{\text{Norm}}_q(F(a,b))=\mathop{\text{Norm}}_q(F(b,a))
$$


### What the property/control means

This record formalises **Normalized commutativity** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T3 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T3 candidate harness`. The admitted domain is: int16 first operand; signed-canonical second operand and property-specific normalized domains. The recorded assumptions/grounding are: Candidate model canonicalizes residues before comparison. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No completed proof of mlk_fqmul algebra or additional reduction claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T3.P2 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-012`

- **Historical identifier:** `MONT-T3.P2`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery multiplication candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** int16 first operand; signed-canonical second operand and property-specific normalized domains

- **Assumptions and grounding:** Candidate model canonicalizes residues before comparison

- **Ledger formal relation:** normalized fqmul(a,b)=normalized fqmul(b,a)

- **Assertion / harness mapping:** MONT-T3 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No completed proof of mlk_fqmul algebra or additional reduction claim.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-012`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Appendix 2 / retained MONT-T3.P2 normalised commutativity candidate.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T3.P2 resource-limited candidate


</details>

---

## PR-C14-013 — Zero annihilation and reflection


### Formal statement

$$
F(a,0)=0,\qquad F(0,b)=0,\qquad \mathcal{R}_0(a,b)
$$

Here $\mathcal{R}_0(a,b)$ denotes the separately registered **normalised zero-product reflection candidate**. The surviving summary and ledger name that relation but do not reproduce its internal algebraic formula. This catalogue therefore preserves the named sub-obligation without reconstructing an equation that is not present in the retained source.


### What the property/control means

This record preserves the two explicitly retained zero-annihilation equations together with the separately named normalised zero-product reflection sub-obligation. Because the retained summary does not expose the reflection sub-obligation as an algebraic formula, the catalogue labels it symbolically as $\mathcal{R}_0$ rather than inventing a stronger relation. The registered execution did not produce a completed solver verdict within the retained resource boundary, so these are candidate obligations, not supported theorems.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T3 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T3 candidate harness`. The admitted domain is: int16 first operand; signed-canonical second operand and property-specific normalized domains. The recorded assumptions/grounding are: Candidate model canonicalizes residues before comparison. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No completed proof of mlk_fqmul algebra or additional reduction claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T3.P3 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-013`

- **Historical identifier:** `MONT-T3.P3`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery multiplication candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** int16 first operand; signed-canonical second operand and property-specific normalized domains

- **Assumptions and grounding:** Candidate model canonicalizes residues before comparison

- **Ledger formal relation:** fqmul(a,0)=fqmul(0,b)=0 plus registered normalized reflection

- **Assertion / harness mapping:** MONT-T3 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No completed proof of mlk_fqmul algebra or additional reduction claim.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-013`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Appendix 2 / retained MONT-T3.P3 zero-annihilation part of the candidate; the associated normalised reflection condition remains described in the record prose/ledger.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T3.P3 resource-limited candidate


</details>

---

## PR-C14-014 — Montgomery-one identity


### Formal statement

$$
R_q=R\bmod q=2285,\qquad \mathop{\text{Norm}}_q(F(a,R_q))=\mathop{\text{Norm}}_q(a)
$$


### What the property/control means

This record formalises **Montgomery-one identity** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T3 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T3 candidate harness`. The admitted domain is: int16 first operand; signed-canonical second operand and property-specific normalized domains. The recorded assumptions/grounding are: Candidate model canonicalizes residues before comparison. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No completed proof of mlk_fqmul algebra or additional reduction claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T3.P4 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-014`

- **Historical identifier:** `MONT-T3.P4`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery multiplication candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** int16 first operand; signed-canonical second operand and property-specific normalized domains

- **Assumptions and grounding:** Candidate model canonicalizes residues before comparison

- **Ledger formal relation:** normalized multiplication by R mod q=2285 is identity

- **Assertion / harness mapping:** MONT-T3 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No completed proof of mlk_fqmul algebra or additional reduction claim.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-014`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Conservative formalisation of Appendix 2 / retained MONT-T3.P4 Montgomery-one candidate.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T3.P4 resource-limited candidate


</details>

---

## PR-C14-015 — Normalized distributivity


### Formal statement

$$
\widehat F\!\left(a,\mathop{\text{Norm}}_q(b+c)\right)=\mathop{\text{Norm}}_q\!\left(\widehat F(a,b)+\widehat F(a,c)\right),\qquad \widehat F(x,y)=\mathop{\text{Norm}}_q(F(x,y))
$$


### What the property/control means

This record formalises **Normalized distributivity** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T3 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T3 candidate harness`. The admitted domain is: int16 first operand; signed-canonical second operand and property-specific normalized domains. The recorded assumptions/grounding are: Candidate model canonicalizes residues before comparison. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No completed proof of mlk_fqmul algebra or additional reduction claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T3.P5 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-015`

- **Historical identifier:** `MONT-T3.P5`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery multiplication candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** int16 first operand; signed-canonical second operand and property-specific normalized domains

- **Assumptions and grounding:** Candidate model canonicalizes residues before comparison

- **Ledger formal relation:** normalized Montgomery multiplication distributes over normalized modular addition

- **Assertion / harness mapping:** MONT-T3 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No completed proof of mlk_fqmul algebra or additional reduction claim.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-015`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Conservative formalisation of the retained MONT-T3.P5 normalised distributivity candidate.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T3.P5 resource-limited candidate


</details>

---

## PR-C14-016 — Normalized associativity


### Formal statement

$$
\widehat F\!\left(\widehat F(a,b),c\right)=\widehat F\!\left(a,\widehat F(b,c)\right),\qquad \widehat F(x,y)=\mathop{\text{Norm}}_q(F(x,y))
$$


### What the property/control means

This record formalises **Normalized associativity** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T3 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T3 candidate harness`. The admitted domain is: int16 first operand; signed-canonical second operand and property-specific normalized domains. The recorded assumptions/grounding are: Candidate model canonicalizes residues before comparison. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No completed proof of mlk_fqmul algebra or additional reduction claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T3.P6 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-016`

- **Historical identifier:** `MONT-T3.P6`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Montgomery multiplication candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** int16 first operand; signed-canonical second operand and property-specific normalized domains

- **Assumptions and grounding:** Candidate model canonicalizes residues before comparison

- **Ledger formal relation:** reassociated normalized products agree

- **Assertion / harness mapping:** MONT-T3 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** No authentic accepted mutation result

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No completed proof of mlk_fqmul algebra or additional reduction claim.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-016`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Conservative formalisation of the retained MONT-T3.P6 normalised associativity candidate.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T3.P6 resource-limited candidate


</details>

---

## PR-C14-017 — De-Montgomery round trip


### Formal statement

$$
M\!\left(T(A)_i\right)\equiv A_i\pmod q
$$


### What the property/control means

This record formalises **De-Montgomery round trip** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T4 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T4 candidate harness`. The admitted domain is: Registered ML-KEM-768 polynomial coefficient domain. The recorded assumptions/grounding are: Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T4.P1 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-017`

- **Historical identifier:** `MONT-T4.P1`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Polynomial Montgomery-conversion candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Registered ML-KEM-768 polynomial coefficient domain

- **Assumptions and grounding:** Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q

- **Ledger formal relation:** reducing a converted coefficient recovers the original residue modulo q

- **Assertion / harness mapping:** MONT-T4 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** Synthetic success/mutation markers excluded

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-017`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Conservative formalisation of Appendix 2 / retained MONT-T4.P1 de-Montgomery round-trip candidate.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T4.P1 resource-limited candidate


</details>

---

## PR-C14-018 — Residue-vector equivalence preservation


### Formal statement

$$
\left(\forall i,\ A_i\equiv B_i\pmod q\right)\Longrightarrow\left(\forall i,\ T(A)_i\equiv T(B)_i\pmod q\right)
$$


### What the property/control means

This record formalises **Residue-vector equivalence preservation** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T4 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T4 candidate harness`. The admitted domain is: Registered ML-KEM-768 polynomial coefficient domain. The recorded assumptions/grounding are: Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T4.P2 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-018`

- **Historical identifier:** `MONT-T4.P2`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Polynomial Montgomery-conversion candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Registered ML-KEM-768 polynomial coefficient domain

- **Assumptions and grounding:** Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q

- **Ledger formal relation:** coefficientwise residue-equivalent inputs produce equivalent converted outputs

- **Assertion / harness mapping:** MONT-T4 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** Synthetic success/mutation markers excluded

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-018`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Conservative formalisation of Appendix 2 / retained MONT-T4.P2 residue-vector preservation candidate.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T4.P2 resource-limited candidate


</details>

---

## PR-C14-019 — Residue-vector equivalence reflection


### Formal statement

$$
\left(\forall i,\ T(A)_i\equiv T(B)_i\pmod q\right)\Longrightarrow\left(\forall i,\ A_i\equiv B_i\pmod q\right)
$$


### What the property/control means

This record formalises **Residue-vector equivalence reflection** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T4 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T4 candidate harness`. The admitted domain is: Registered ML-KEM-768 polynomial coefficient domain. The recorded assumptions/grounding are: Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T4.P3 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-019`

- **Historical identifier:** `MONT-T4.P3`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Polynomial Montgomery-conversion candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Registered ML-KEM-768 polynomial coefficient domain

- **Assumptions and grounding:** Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q

- **Ledger formal relation:** equivalent converted outputs imply equivalent original inputs

- **Assertion / harness mapping:** MONT-T4 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** Synthetic success/mutation markers excluded

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-019`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Conservative formalisation of Appendix 2 / retained MONT-T4.P3 residue-vector reflection candidate.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T4.P3 resource-limited candidate


</details>

---

## PR-C14-020 — Zero-support preservation


### Formal statement

$$
T(A)_i\equiv0\pmod q\Longleftrightarrow A_i\equiv0\pmod q
$$


### What the property/control means

This record formalises **Zero-support preservation** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T4 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T4 candidate harness`. The admitted domain is: Registered ML-KEM-768 polynomial coefficient domain. The recorded assumptions/grounding are: Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T4.P4 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-020`

- **Historical identifier:** `MONT-T4.P4`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Polynomial Montgomery-conversion candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Registered ML-KEM-768 polynomial coefficient domain

- **Assumptions and grounding:** Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q

- **Ledger formal relation:** converted coefficient=0 mod q iff input coefficient=0 mod q

- **Assertion / harness mapping:** MONT-T4 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** Synthetic success/mutation markers excluded

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-020`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Appendix 2 / retained MONT-T4.P4 candidate relation.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T4.P4 resource-limited candidate


</details>

---

## PR-C14-021 — Coefficient locality and no cross-talk


### Formal statement

$$
A_k=B_k\Longrightarrow T(A)_k=T(B)_k
$$


### What the property/control means

This record formalises **Coefficient locality and no cross-talk** as a stronger follow-up proposition. The registered execution did not produce a completed solver verdict within the retained resource boundary, so the equation above is the candidate that was investigated, not a supported theorem.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The candidate is mapped to `MONT-T4 candidate harness`, but no authentic completed solver verdict supports acceptance or refutation within the retained resource boundary. Its mathematical display is preserved as the investigated proposition only.


### Exact experimental obligation and admitted domain

The relation above was associated with `MONT-T4 candidate harness`. The admitted domain is: Registered ML-KEM-768 polynomial coefficient domain. The recorded assumptions/grounding are: Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Retained as a technically specified unresolved candidate family.

**What this record does not establish:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.


### Native-baseline relationship

The frozen native baseline for this case is: Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance. The campaign addition is characterised at case level as: T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 14 → MONT-T4.P5 resource-limited candidate. Chapter 4 uses the case-level principal synthesis in Section 4.5.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C14-021`

- **Historical identifier:** `MONT-T4.P5`

- **Case identifier:** `14`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`

- **Property class:** `Polynomial Montgomery-conversion candidate`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Registered ML-KEM-768 polynomial coefficient domain

- **Assumptions and grounding:** Target is mlk_poly_tomont_c; supporting forward law T(A)[i]≡A[i]R mod q

- **Ledger formal relation:** agreement at k implies converted outputs agree at k independently of other coefficients

- **Assertion / harness mapping:** MONT-T4 candidate harness

- **Result:** `RESOURCE_LIMITED_INCONCLUSIVE`

- **Target reachability:** ATTEMPTED

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** ATTEMPT-SPECIFIC

- **Mutation status:** Synthetic success/mutation markers excluded

- **Strongest bounded conclusion:** Retained as a technically specified unresolved candidate family.

- **Explicit exclusion:** No claim that a function named poly_montgomery_reduce was proved; no accepted portable-C conversion result.

- **Evidence locator:** `LOC-C14-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MONTGOMERY_CBMC_A_TO_Z_CORRECTED_EVIDENCE_RECORD.md

- **Archive entry SHA-256:** `69d165308a6f39f0227deaf9b1ed86a21af04e853397ebb6ed7ebcab35809813`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C14-021`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Appendix 2 / retained MONT-T4.P5 coefficient-locality candidate relation.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 14 → MONT-T4.P5 resource-limited candidate


</details>

---


# Case-level bounded conclusion

MONT-T1: reduce(a)=independent_oracle(a) over the complete legal source domain, with exact reconstruction, unique signed-16 decomposition and sharp image [-32767,32767]. MONT-T2–T4 remain resource-limited and inconclusive.

**Explicit exclusion.** Does not establish every Montgomery arithmetic property.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
