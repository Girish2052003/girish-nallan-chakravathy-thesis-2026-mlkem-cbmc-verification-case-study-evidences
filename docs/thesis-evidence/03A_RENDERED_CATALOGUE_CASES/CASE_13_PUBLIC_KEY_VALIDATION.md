# Case 13 — Public-Key Validation

**Target:** `mlk_kem_check_pk`
**Evidence locator:** `LOC-C13-UA`
**Chapter 4 projection:** Section 4.5.5
**Ledger records:** 16
**Formally supported subset:** 12

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

Does the production checker make the expected canonicality decision, respect its memory footprint and frames, and integrate with the caller guard, while keeping stronger relational claims separate when the encoded abstraction is insufficient?

## Case notation and opening equations


$$
\mathop{\text{CheckPK}}(P)\text{ denotes the production validation result}
$$


$$
\mathrm{ACCEPT},\mathrm{REJECT},\mathrm{OOM}\text{ denote the registered semantic result classes}
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
\mathop{\text{decoded}}_{12}(P,i)\ge q\;\Longrightarrow\;\mathop{\text{CheckPK}}(P)\in\{\mathrm{REJECT},\mathrm{OOM}\}
$$


$$
\bigl(\forall i:\mathop{\text{decoded}}_{12}(P,i)\lt q\bigr)\;\Longrightarrow\;\mathop{\text{CheckPK}}(P)\in\{\mathrm{ACCEPT},\mathrm{OOM}\}
$$


**Recorded principal-claim wording:** The registered malformed/canonical field decisions, input/frame obligations, prefix-only footprint and caller guard are supported; the two-call seed-noninterference relation remains abstraction-limited and inconclusive.


### Why this claim is the principal case-level synthesis

No single arithmetic equality captures validation. The principal claim is therefore a deliberately composite boundary: decision semantics, frame/footprint obligations and caller use are all needed to describe the checked behaviour. The two-call seed-noninterference candidate is excluded from the supported principal claim because the retained abstraction cannot justify a production-level verdict.


The survival ledger assigns this synthesis to **4.5.5** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768`. Its primary verification focus was: Expected length and canonical-key decision; frame/red-zone preservation; prefix-only read footprint; caller-side validation guard. The additional or mixed evidence was: The two-call seed-noninterference assertion failed in a contract-backed model because the lower abstraction lacked a relational guarantee. This was classified as abstraction-limited, not a production defect..


The retained case matrix records CBMC execution as **YES — T1/T2 frame/T3/T4 supported; one T2 relational property failed in the abstraction**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES for supported claims; relational attempt reached and failed`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** The pinned checker supports the recorded length/canonicality, frame, prefix-footprint and caller-guard claims; the concrete relational seed-noninterference theorem remains unproved.


**Integrity boundary:** The supported prefix-footprint and frame claims must be separated from the unresolved concrete two-call seed-noninterference theorem.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md` with entry SHA-256 `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`. The case archive is `thesis_batch_1.zip` with SHA-256 `b7d4a0c238997f323abb93974243f93bcc0afe65f48cecd94d3b6af93f89c0d0`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **22** indexed records for `LOC-C13-UA`: COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=2, RAW_RESULT=4. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native short check_pk harness and contracts, with lower-level replacement structure.


**Necessary overlap.** Same checker, encoded key format and lower contracts where declared.


**What this campaign added.** Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation.


**Why the suite is substantively distinct within the inspected corpus.** The generated suite separates local return semantics, memory footprint and caller integration and exposes the abstraction limit.


**Comparison material inspected.** Native check_pk harness/contracts and PKCHECK campaign audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESS_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/kem_check_pk/kem_check_pk_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/kem_check_pk/Makefile

- **Native proof entry SHA-256:** 73326d4adc74568fc1976582f23ed5fd83ab66085ae9384eaf04f41f5373fcce;5879f4fa29081163f73d0d01675ae0169fcc82b2119a0a7b2c7731b774fef7d6

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/kem.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/kem.h

- **Production source entry SHA-256:** b3de1f7602b10c6033eee8b235138190ed09df917ec9326c2b38ce1083c541ce;e239f5d705fca7729e7838e836aa2fab814ddc4ffbaf7eeb73a32242b15d960d

- **Authoritative baseline characterisation:** A dedicated native one-call `kem_check_pk` harness exists.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `STATE_AND_FRAME_SUPPORT` | `PR-C13-001`, `PR-C13-005`, `PR-C13-006`, `PR-C13-007`, `PR-C13-008`, `PR-C13-010`, `PR-C13-011`, `PR-C13-012`, `PR-C13-013`, `PR-C13-014`, `PR-C13-015`, `PR-C13-016` | protects inputs, guards, footprints or unrelated state |

| `EVIDENCE_OR_DOMAIN_CONTROL` | `PR-C13-002`, `PR-C13-003`, `PR-C13-004` | justifies the configuration, oracle, admissibility, indexing or construction without adding a theorem count |

| `UNRESOLVED_BOUNDARY` | `PR-C13-009` | records a stronger proposition that remains unresolved and therefore stays outside the supported claim |


**Survival-ledger supporting historical IDs:** `PKCHECK-T1.R2`, `PKCHECK-T1.R3`, `PKCHECK-T2.P1`, `PKCHECK-T2.P2`, `PKCHECK-T2.P3`, `PKCHECK-T3.P1`, `PKCHECK-T4.P1`, `PKCHECK-T4.P2`, `PKCHECK-T4.P3`, `PKCHECK-T4.P4`, `PKCHECK-T4.P5`, `PKCHECK-T4.P6`


**Survival-ledger contrary/unresolved IDs:** `PKCHECK-T2.P4`


## Thesis-appendix projection


The compact Appendix 1 projection contains **12** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `INC-C13-SEED` | `ABSTRACTION_LIMITED_INCONCLUSIVE` | Counterexample arose in a lower abstraction lacking the required relational guarantee. | No production-defect conclusion; local accepted claims remain. |


## Assurance-layer and literature relationship

This comparison prevents repository-relative distinctness from being rewritten as global mathematical novelty. The rows below are interpretive context; implementation support still comes from the source-bound evidence for this case.

| Source/project | Relationship | Overlap | Important difference | Permitted conclusion |
|---|---|---|---|---|

| NIST FIPS 203 (2024a) | `NORMATIVE_GROUNDING` | Grounds ML-KEM operations, domains and data formats relevant to the case. | FIPS 203 is not a proof that this C implementation or generated harness is correct. | The case is specification-grounded where applicable; implementation support comes from the recorded source-bound CBMC evidence, not from the standard alone. |

| PQ Code Package / mlkem-native assurance documentation (n.d.-a; n.d.-b) | `NATIVE_ASSURANCE_CONTEXT` | Shares the exact production repository and some target contracts/harness infrastructure. | Native artefacts support different or narrower property sets and different assurance layers; the case-specific distinction is recorded in matrix 04. | Report repository-relative generated artefact/property contribution, not absence of all prior assurance. |


## Publication-state and traceability-field note

The record blocks below preserve the frozen RC2 public-path fields only as explicitly labelled historical provenance. Their former `PENDING`, `UNRESOLVED_UNTIL_FINALIZER`, blank public-SHA and candidate-count values describe the pre-finalization snapshot; they do **not** describe the current repository. The current authoritative ledger records all 257 substantive records as `RESOLVED_HASH_MATCH` and supplies the exact current public path and SHA-256. To avoid creating a second mutable authority, this catalogue points each record back to its current ledger row instead of copying those current path/hash strings into prose.

Scientific outcome status is independent. Supported, negative, abstraction-limited, resource-limited, diagnostic, construction and preservation classifications are reproduced unchanged.

# Complete record-by-record catalogue


## PR-C13-001 — Arbitrary-context malformed-field rejection


### Formal statement

$$
\left(\exists j:\ q\le\mathop{\text{decoded}}_{12}(PK,j)\le4095\right)\Longrightarrow\mathop{\text{check\_pk}}(PK)\in\{\mathrm{REJECT},\mathrm{OOM}\}
$$


### What the property/control means

The property checks **Arbitrary-context malformed-field rejection** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 1, “Malformed-field decision”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-001`

- **Historical identifier:** `PKCHECK-T1.R2`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** If a selected encoded field is in [3329,4095], check_pk returns rejection or OOM; every other byte and seed byte arbitrary

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Ledger-faithful rendered formalization, cross-checked against the retained public-key validation record.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 1, “Malformed-field decision”.


</details>

---

## PR-C13-002 — Malformed-field byte-index bound


### Formal statement

$$
\mathrm{AccessedBytes}_{\mathrm{inject}}\subseteq[0,\mathrm{MLKEM\_POLYVECBYTES})
$$


### What the property/control means

This control fixes or checks part of the verification setting needed to interpret the associated semantic assertions correctly. It closes a configuration, indexing, oracle or admissibility gap without being counted as an additional functional result.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The mapping `T1-R2 named support assertion` is retained as a supporting control. Its reachability/feasibility fields are `YES` / `YES` and its role is to justify the surrounding verification setup, not to establish a new target-level theorem.


### Exact experimental obligation and admitted domain

The relation above was associated with `T1-R2 named support assertion`. The admitted domain is: ML-KEM-768 public-key layout and registered selected coefficient index. The recorded assumptions/grounding are: Frozen layout assertions; arbitrary surrounding public-key context; non-OOM result interpretation. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The malformed-rejection construction is well-formed and bound to the intended field.

**What this record does not establish:** Supporting construction control; not the final accept/reject relation by itself.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-002`

- **Historical identifier:** `PKCHECK-T1R2.INDEX_BYTE_BOUND`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Supporting functional control`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 public-key layout and registered selected coefficient index

- **Assumptions and grounding:** Frozen layout assertions; arbitrary surrounding public-key context; non-OOM result interpretation

- **Ledger formal relation:** Every byte accessed to inject the selected malformed field lies within the polynomial-vector prefix.

- **Assertion / harness mapping:** T1-R2 named support assertion

- **Result:** `SUPPORTING_CONTROL`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T1-R2 control-specific; see case package

- **Strongest bounded conclusion:** The malformed-rejection construction is well-formed and bound to the intended field.

- **Explicit exclusion:** Supporting construction control; not the final accept/reject relation by itself.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C13-003 — Malformed-field pair-index bound


### Formal statement

$$
0\le \mathrm{pairIndex}(k)\lt \frac{\mathrm{MLKEM\_POLYVECBYTES}}{3}
$$


### What the property/control means

This control fixes or checks part of the verification setting needed to interpret the associated semantic assertions correctly. It closes a configuration, indexing, oracle or admissibility gap without being counted as an additional functional result.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The mapping `T1-R2 named support assertion` is retained as a supporting control. Its reachability/feasibility fields are `YES` / `YES` and its role is to justify the surrounding verification setup, not to establish a new target-level theorem.


### Exact experimental obligation and admitted domain

The relation above was associated with `T1-R2 named support assertion`. The admitted domain is: ML-KEM-768 public-key layout and registered selected coefficient index. The recorded assumptions/grounding are: Frozen layout assertions; arbitrary surrounding public-key context; non-OOM result interpretation. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The malformed-rejection construction is well-formed and bound to the intended field.

**What this record does not establish:** Supporting construction control; not the final accept/reject relation by itself.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-003`

- **Historical identifier:** `PKCHECK-T1R2.INDEX_PAIR_BOUND`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Supporting functional control`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 public-key layout and registered selected coefficient index

- **Assumptions and grounding:** Frozen layout assertions; arbitrary surrounding public-key context; non-OOM result interpretation

- **Ledger formal relation:** The selected malformed coefficient maps to a valid packed pair within the polynomial-vector field.

- **Assertion / harness mapping:** T1-R2 named support assertion

- **Result:** `SUPPORTING_CONTROL`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T1-R2 control-specific; see case package

- **Strongest bounded conclusion:** The malformed-rejection construction is well-formed and bound to the intended field.

- **Explicit exclusion:** Supporting construction control; not the final accept/reject relation by itself.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C13-004 — Malformed-field oracle packing


### Formal statement

$$
\mathop{\text{DecodeField}}(\mathop{\text{PackMalformed}}(u))=u,\qquad 3329\le u\le4095
$$


### What the property/control means

This control fixes or checks part of the verification setting needed to interpret the associated semantic assertions correctly. It closes a configuration, indexing, oracle or admissibility gap without being counted as an additional functional result.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The mapping `T1-R2 named support assertion` is retained as a supporting control. Its reachability/feasibility fields are `YES` / `YES` and its role is to justify the surrounding verification setup, not to establish a new target-level theorem.


### Exact experimental obligation and admitted domain

The relation above was associated with `T1-R2 named support assertion`. The admitted domain is: ML-KEM-768 public-key layout and registered selected coefficient index. The recorded assumptions/grounding are: Frozen layout assertions; arbitrary surrounding public-key context; non-OOM result interpretation. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The malformed-rejection construction is well-formed and bound to the intended field.

**What this record does not establish:** Supporting construction control; not the final accept/reject relation by itself.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-004`

- **Historical identifier:** `PKCHECK-T1R2.ORACLE_PACKING`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Supporting functional control`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 public-key layout and registered selected coefficient index

- **Assumptions and grounding:** Frozen layout assertions; arbitrary surrounding public-key context; non-OOM result interpretation

- **Ledger formal relation:** The constructed packed field decodes to the selected noncanonical value while preserving the unrelated nibble and arbitrary surrounding context.

- **Assertion / harness mapping:** T1-R2 named support assertion

- **Result:** `SUPPORTING_CONTROL`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T1-R2 control-specific; see case package

- **Strongest bounded conclusion:** The malformed-rejection construction is well-formed and bound to the intended field.

- **Explicit exclusion:** Supporting construction control; not the final accept/reject relation by itself.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C13-005 — Canonical-field acceptance


### Formal statement

$$
\left(\forall j:\;0\le\mathop{\text{decoded}}_{12}(PK,j)\lt q\right)\Longrightarrow\mathop{\text{check\_pk}}(PK)\in\{\mathrm{ACCEPT},\mathrm{OOM}\}
$$


### What the property/control means

The property checks **Canonical-field acceptance** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 2, “Canonical-field decision”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-005`

- **Historical identifier:** `PKCHECK-T1.R3`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** If all 768 encoded fields are in [0,3328], check_pk returns acceptance or OOM; seed arbitrary

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 2, “Canonical-field decision”.


</details>

---

## PR-C13-006 — First-input frame


### Formal statement

$$
PK_1^{\mathrm{after}}=PK_1^{\mathrm{before}}
$$


### What the property/control means

The property checks **First-input frame** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 3, “First input-frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-006`

- **Historical identifier:** `PKCHECK-T2.P1`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** first public-key input object unchanged

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 3, “First input-frame preservation”.


</details>

---

## PR-C13-007 — Second-input frame


### Formal statement

$$
PK_2^{\mathrm{after}}=PK_2^{\mathrm{before}}
$$


### What the property/control means

The property checks **Second-input frame** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 4, “Second input-frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-007`

- **Historical identifier:** `PKCHECK-T2.P2`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** second compared input object unchanged

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 4, “Second input-frame preservation”.


</details>

---

## PR-C13-008 — Red-zone preservation


### Formal statement

$$
\mathrm{redzone}_{\mathrm{after}}=\mathrm{redzone}_{\mathrm{before}}
$$


### What the property/control means

The property checks **Red-zone preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 5, “Red-zone preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-008`

- **Historical identifier:** `PKCHECK-T2.P3`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** registered red-zone bytes unchanged

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 5, “Red-zone preservation”.


</details>

---

## PR-C13-009 — Two-call seed noninterference


### Formal statement

$$
P^{(1)}_{\mathrm{vec}}=P^{(2)}_{\mathrm{vec}}
\Longrightarrow
\bigl(r_1=\mathrm{OOM}\;\lor\;r_2=\mathrm{OOM}\;\lor\;r_1=r_2\bigr)
$$


### What the property/control means

This record states the stronger candidate **Two-call seed noninterference**. The compared public-key objects share the registered encoded polynomial-vector prefix while the public-seed suffix may differ; the assertion requires equal decisions whenever both calls avoid the independently nondeterministic OOM outcome. The retained abstraction does not provide enough relational information to justify either a production-level acceptance or a production-level refutation. The candidate is therefore preserved as an unresolved question rather than converted into a success or defect claim.


### Why it matters

Preserving the unresolved candidate prevents absence of a completed verdict from being mistaken for either correctness or a defect, and keeps the principal claim within the evidence actually obtained.


### Relationship to the principal claim

**Role:** `UNRESOLVED_BOUNDARY`. This record is an explicit boundary on the principal claim. It is kept outside the supported set and prevents unresolved follow-up work from being absorbed into the accepted case result.


### Formal-support basis and evidential status

The mapped candidate `PKCHECK T1–T4 selected assertion marker` was reached, but the encoded lower-level abstraction did not provide the relational guarantee needed for a production-level conclusion. The counterexample is therefore not promoted to a production defect and the candidate remains inconclusive.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The relation remained unresolved because the lower abstraction did not supply the required two-run relational guarantee.

**What this record does not establish:** The counterexample is not evidence of a production-code defect.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 13 abstraction-limited inconclusive finding. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-009`

- **Historical identifier:** `PKCHECK-T2.P4`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** changing only seed bytes does not change the two-call result relation

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `ABSTRACTION_LIMITED_INCONCLUSIVE`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The relation remained unresolved because the lower abstraction did not supply the required two-run relational guarantee.

- **Explicit exclusion:** The counterexample is not evidence of a production-code defect.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Retained T2 two-call seed-noninterference assertion, rendered from the A-to-Z allocation-aware relation. The contract-backed counterexample is abstraction-limited, not a production refutation.

- **Principal-claim role:** `UNRESOLVED_BOUNDARY`

- **Appendix projection:** Appendix 2 → Case 13 abstraction-limited inconclusive finding


</details>

---

## PR-C13-010 — Prefix-only read footprint


### Formal statement

$$
\mathrm{ReadFootprint}(\mathop{\text{check\_pk}})\subseteq[0,\mathrm{MLKEM\_POLYVECBYTES})
$$


### What the property/control means

The property checks **Prefix-only read footprint** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 6, “Prefix-only read footprint”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-010`

- **Historical identifier:** `PKCHECK-T3.P1`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** concrete target reads only the registered MLKEM_POLYVECBYTES prefix under the contract-backed lower model

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 6, “Prefix-only read footprint”.


</details>

---

## PR-C13-011 — Caller guard call-count


### Formal statement

$$
N_{\mathop{\text{check\_pk}}}\le1
$$


### What the property/control means

The property checks **Caller guard call-count** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 7, “Caller invocation bound”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-011`

- **Historical identifier:** `PKCHECK-T4.P1`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** mlk_enc_derand caller invokes check_pk at most once in the registered stubbed context

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Source-evidence audited formalization of the retained technical record.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 7, “Caller invocation bound”.


</details>

---

## PR-C13-012 — Caller result split


### Formal statement

$$
\begin{array}{rl}&\bigl(\mathrm{allocation\ failure}\land N_{\mathop{\text{check\_pk}}}=0\land R_{\mathrm{caller}}=\mathrm{OOM}\bigr)\\&\quad\lor\bigl(N_{\mathop{\text{check\_pk}}}=1\land R_{\mathop{\text{check\_pk}}}=\mathrm{MLK\_ERR\_FAIL}\land R_{\mathrm{caller}}=\mathrm{MLK\_ERR\_FAIL}\bigr).\end{array}
$$


### What the property/control means

The property checks **Caller result split** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 8, “Caller validation-guard consistency”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-012`

- **Historical identifier:** `PKCHECK-T4.P2`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** caller follows registered return split for accepted/rejected/OOM check result

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-012`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** Source-evidence audited formalization of the retained technical record.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 8, “Caller validation-guard consistency”.


</details>

---

## PR-C13-013 — Ciphertext frame on rejected guard path


### Formal statement

$$
C^{\mathrm{after}}=C^{\mathrm{before}}\qquad\text{on the registered rejected-guard path}
$$


### What the property/control means

The property checks **Ciphertext frame on rejected guard path** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 9, “Ciphertext frame on rejected validation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-013`

- **Historical identifier:** `PKCHECK-T4.P3`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** ciphertext obeys registered frame condition

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-013`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 9, “Ciphertext frame on rejected validation”.


</details>

---

## PR-C13-014 — Shared-secret frame on rejected guard path


### Formal statement

$$
SS^{\mathrm{after}}=SS^{\mathrm{before}}\qquad\text{on the registered rejected-guard path}
$$


### What the property/control means

The property checks **Shared-secret frame on rejected guard path** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 10, “Shared-secret frame on rejected validation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-014`

- **Historical identifier:** `PKCHECK-T4.P4`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** shared-secret obeys registered frame condition

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-014`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 10, “Shared-secret frame on rejected validation”.


</details>

---

## PR-C13-015 — Public-key frame in caller guard


### Formal statement

$$
PK^{\mathrm{after}}=PK^{\mathrm{before}}
$$


### What the property/control means

The property checks **Public-key frame in caller guard** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 11, “Public-key frame preservation in the caller”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-015`

- **Historical identifier:** `PKCHECK-T4.P5`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** public key unchanged

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-015`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 11, “Public-key frame preservation in the caller”.


</details>

---

## PR-C13-016 — Coins frame in caller guard


### Formal statement

$$
\mathrm{coins}^{\mathrm{after}}=\mathrm{coins}^{\mathrm{before}}
$$


### What the property/control means

The property checks **Coins frame in caller guard** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PKCHECK T1–T4 selected assertion marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED; counterexample retained for T2.P4`. The retained mutation/control field records: Property-specific selected mutants. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PKCHECK T1–T4 selected assertion marker`. The admitted domain is: ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model. The recorded assumptions/grounding are: Model boundary is stated per property; production checker unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The local validation/frame/footprint/caller relation is supported.

**What this record does not establish:** Not honest key generation, key-pair consistency or complete cryptographic validity.


### Native-baseline relationship

The frozen native baseline for this case is: Native short check_pk harness and contracts, with lower-level replacement structure. The campaign addition is characterised at case level as: Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 12, “Randomness/coins frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.5; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C13-016`

- **Historical identifier:** `PKCHECK-T4.P6`

- **Case identifier:** `13`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_kem_check_pk`

- **Property class:** `Validation/frame/footprint`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 encoded public-key objects under the property-specific actual-body, contract-backed or stub-backed model

- **Assumptions and grounding:** Model boundary is stated per property; production checker unchanged

- **Ledger formal relation:** coins input unchanged

- **Assertion / harness mapping:** PKCHECK T1–T4 selected assertion marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED; counterexample retained for T2.P4

- **Mutation status:** Property-specific selected mutants

- **Strongest bounded conclusion:** The local validation/frame/footprint/caller relation is supported.

- **Explicit exclusion:** Not honest key generation, key-pair consistency or complete cryptographic validity.

- **Evidence locator:** `LOC-C13-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_KEM_CHECK_PK_CBMC_CAMPAIGN_A_TO_Z_2026-07-30.md

- **Archive entry SHA-256:** `29e473750b6f5d66fbd650bd4c48bb8cd6333a2fd07d54bbd5e558aab92b3cf6`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C13-016`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 13: Public-Key Validation: mlk_kem_check_pk → item 12, “Randomness/coins frame preservation”.


</details>

---


# Case-level bounded conclusion

The registered malformed/canonical field decisions, input/frame obligations, prefix-only footprint and caller guard are supported; the two-call seed-noninterference relation remains abstraction-limited and inconclusive.

**Explicit exclusion.** Not honest key generation, key-pair consistency or complete cryptographic validity.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
