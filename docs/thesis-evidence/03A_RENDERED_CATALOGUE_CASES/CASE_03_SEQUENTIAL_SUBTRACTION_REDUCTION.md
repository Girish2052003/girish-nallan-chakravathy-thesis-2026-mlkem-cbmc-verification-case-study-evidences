# Case 3 — Sequential Subtraction and Reduction

**Target:** `mlk_poly_sub → mlk_poly_reduce`
**Evidence locator:** `LOC-C03-UA`
**Chapter 4 projection:** Section 4.3.3
**Ledger records:** 3
**Formally supported subset:** 1

**Pinned source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`
**Parameter/configuration:** ML-KEM-768; supporting later-revision replay
**Evidence completeness:** `COMPLETE`

## Verification question

Do the two unchanged production functions compose correctly across their intermediate representation, rather than merely being acceptable when considered one at a time?

## Case notation and opening equations


$$
R=\mathop{\text{Reduce}}(\mathop{\text{Sub}}(A,B))
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
R_i=\mathop{\text{canon}}_q\!\left(\mathop{\text{int32}}(A_i)-\mathop{\text{int32}}(B_i)\right)
$$


**Recorded principal-claim wording:** For each i, $`\mathrm{reduce}(\mathrm{sub}(A,B))_i=\mathrm{canon}_q\!\left(\mathrm{int32}(A_i)-\mathrm{int32}(B_i)\right)`$ within the signed-representable difference domain.


### Why this claim is the principal case-level synthesis

The sequential equality is the only substantive semantic claim in this case and is therefore the principal claim by construction. The admissibility and oracle records exist to justify the domain and reference relation; they are controls and are not counted as additional mathematical properties.


The survival ledger assigns this synthesis to **4.3.3** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `d9613cf60de3132d32475c102d8c2781d84feb34; selected replay/cross-check at af4c5abd…` under `ML-KEM-768`. Its primary verification focus was: Sequential canonical modular difference: production subtraction followed by production reduction agrees with an independent canonical modulo-q oracle. The additional or mixed evidence was: Call-site admissibility and oracle controls passed; implementation and assertion mutants were killed; later replay confirmed the positive property at the later revision but did not repeat every original control.


The retained case matrix records CBMC execution as **YES — AC-SR1, OR-SR1 and VC-SR1 passed; M4/M5 failed as expected**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** Within the signed-representable input domain, the pinned portable-C sequence mlk_poly_sub then mlk_poly_reduce produces the canonical representative of the coefficient-wise difference.


**Integrity boundary:** The replay is supporting revision evidence, not a second matched skill attempt and not a full replication of all original controls.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/VC_SR1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md` with entry SHA-256 `f06bde16f80b90a8960976e46a72d57fd54ea4bc282bbd9e59bb98bf6a54fc58`. The case archive is `thesis_batch_3.zip` with SHA-256 `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`. Evidence completeness is `COMPLETE`.
 The recorded limitation is: Later-revision replay is supporting evidence, not a complete replication.



The representative artefact map contains **29** indexed records for `LOC-C03-UA`: COMMAND_OR_RUNNER=2, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=3. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native separate `poly_sub` and `poly_reduce` artefacts/contracts.


**Necessary overlap.** Use of the same two production functions and q.


**What this campaign added.** Direct sequential composition against independent canonical oracle with admissibility/oracle controls and implementation/assertion mutants.


**Why the suite is substantively distinct within the inspected corpus.** Explicit compatibility of intermediate representations and two-function sequence is the verification object.


**Comparison material inspected.** Native `poly_sub`/`poly_reduce` proof directories and VC-SR1 post-freeze comparison.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** SEPARATE_NATIVE_HARNESSES_PRESENT_NO_DIRECT_SEQUENCE_DIRECTORY

- **Native proof paths:** mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/proofs/cbmc/poly_sub/poly_sub_harness.c;mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/proofs/cbmc/poly_sub/Makefile;mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/proofs/cbmc/poly_reduce/poly_reduce_harness.c;mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/proofs/cbmc/poly_reduce/Makefile

- **Native proof entry SHA-256:** 12d6a569b8a0bc6a4fc9340f1378f28e11c94beb43730b291161d6a24f8f67d1;d576e9ca8f1c952e79ae0b21d93b768a9d0d14b38584e76e953a800253afece8;dc5ff23e7af7579f6a6baeea3a4a1bb38e030a5a4fd7e2d0d6da053bc9cd5f51;83316cbd1e83d8397b61ef0f1829c0dc42d8c527bc6aeb86268620ae895dcc1c

- **Production source paths:** mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/mlkem/src/poly.c;mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/mlkem/src/poly.h

- **Production source entry SHA-256:** f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722;f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef

- **Authoritative baseline characterisation:** Native one-call harnesses exist separately for `poly_sub` and `poly_reduce`; no eponymous direct VC-SR1 sequence directory was identified.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `COMPOSITION_AND_CALLER_SUPPORT` | `PR-C03-003` | connects the local relation to callers, sequential operations, cross-function composition or parameter replication |

| `EVIDENCE_OR_DOMAIN_CONTROL` | `PR-C03-001`, `PR-C03-002` | justifies the configuration, oracle, admissibility, indexing or construction without adding a theorem count |


**Survival-ledger supporting historical IDs:** `VC-SR1`


## Thesis-appendix projection


The compact Appendix 1 projection contains **1** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `LIM-C03-REPLAY` | `SUPPORTING_ONLY` | Positive relation repeated without every original control. | Supporting cross-revision evidence, not complete replication or another matched run. |


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


## PR-C03-001 — Sequential call-site admissibility


### Formal statement

$$
\mathrm{Admissible}(\mathop{\text{Sub}})\land\mathrm{Admissible}(\mathop{\text{Reduce}})\qquad\text{in the registered sequential composition}
$$


### What the property/control means

This control fixes or checks part of the verification setting needed to interpret the associated semantic assertions correctly. It closes a configuration, indexing, oracle or admissibility gap without being counted as an additional functional result.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The mapping `AC-SR1 control` is retained as a supporting control. Its reachability/feasibility fields are `YES` / `YES` and its role is to justify the surrounding verification setup, not to establish a new target-level theorem.


### Exact experimental obligation and admitted domain

The relation above was associated with `AC-SR1 control`. The admitted domain is: Signed-representable difference domain. The recorded assumptions/grounding are: Registered object and call preconditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Call-site conditions for VC-SR1 are supported.

**What this record does not establish:** Not itself the semantic equality claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native separate `poly_sub` and `poly_reduce` artefacts/contracts. The campaign addition is characterised at case level as: Direct sequential composition against independent canonical oracle with admissibility/oracle controls and implementation/assertion mutants. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C03-001`

- **Historical identifier:** `AC-SR1`

- **Case identifier:** `3`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub -> mlk_poly_reduce (VC-SR1)`

- **Property class:** `Supporting control`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768; supporting later-revision replay

- **Input domain:** Signed-representable difference domain

- **Assumptions and grounding:** Registered object and call preconditions

- **Ledger formal relation:** $`\displaystyle \mathrm{Admissible}(\mathop{\text{Sub}})\land\mathrm{Admissible}(\mathop{\text{Reduce}})\qquad\text{in the registered sequential composition}`$

- **Assertion / harness mapping:** AC-SR1 control

- **Result:** `SUPPORTING_CONTROL`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** N/A

- **Strongest bounded conclusion:** Call-site conditions for VC-SR1 are supported.

- **Explicit exclusion:** Not itself the semantic equality claim.

- **Evidence locator:** `LOC-C03-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/VC_SR1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/VC_SR1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `f06bde16f80b90a8960976e46a72d57fd54ea4bc282bbd9e59bb98bf6a54fc58`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C03-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C03-002 — Independent canonical oracle validation


### Formal statement

$$
\mathop{\text{Oracle}}(d)\in[0,q)\quad\land\quad\mathop{\text{Oracle}}(d)\equiv d\pmod q
$$


### What the property/control means

This control fixes or checks part of the verification setting needed to interpret the associated semantic assertions correctly. It closes a configuration, indexing, oracle or admissibility gap without being counted as an additional functional result.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The mapping `OR-SR1 control` is retained as a supporting control. Its reachability/feasibility fields are `YES` / `YES` and its role is to justify the surrounding verification setup, not to establish a new target-level theorem.


### Exact experimental obligation and admitted domain

The relation above was associated with `OR-SR1 control`. The admitted domain is: Registered difference interval. The recorded assumptions/grounding are: Oracle uses separate int32 arithmetic and canonical modulo. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The comparison oracle is separately validated.

**What this record does not establish:** Does not prove the production sequence by itself.


### Native-baseline relationship

The frozen native baseline for this case is: Native separate `poly_sub` and `poly_reduce` artefacts/contracts. The campaign addition is characterised at case level as: Direct sequential composition against independent canonical oracle with admissibility/oracle controls and implementation/assertion mutants. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C03-002`

- **Historical identifier:** `OR-SR1`

- **Case identifier:** `3`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub -> mlk_poly_reduce (VC-SR1)`

- **Property class:** `Supporting control`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768; supporting later-revision replay

- **Input domain:** Registered difference interval

- **Assumptions and grounding:** Oracle uses separate int32 arithmetic and canonical modulo

- **Ledger formal relation:** $`\displaystyle \mathop{\text{Oracle}}(d)\in[0,q)\quad\land\quad\mathop{\text{Oracle}}(d)\equiv d\pmod q`$

- **Assertion / harness mapping:** OR-SR1 control

- **Result:** `SUPPORTING_CONTROL`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** False-oracle M5 rejected

- **Strongest bounded conclusion:** The comparison oracle is separately validated.

- **Explicit exclusion:** Does not prove the production sequence by itself.

- **Evidence locator:** `LOC-C03-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/VC_SR1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/VC_SR1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `f06bde16f80b90a8960976e46a72d57fd54ea4bc282bbd9e59bb98bf6a54fc58`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C03-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C03-003 — Sequential canonical modular difference


### Formal statement

$$
R_i=\mathrm{canon}_q\!\left(\mathrm{int32}(A_i)-\mathrm{int32}(B_i)\right)
$$


### What the property/control means

The property moves beyond the isolated target and checks **Sequential canonical modular difference** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `VC-SR1 direct production sequence assertions`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: M4 omitted-reduction and M5 false-oracle mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `VC-SR1 direct production sequence assertions`. The admitted domain is: Every coefficient difference representable in int16_t. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The pinned production sequence returns the independent canonical difference.

**What this record does not establish:** Later-revision replay is supporting, not complete replication.


### Native-baseline relationship

The frozen native baseline for this case is: Native separate `poly_sub` and `poly_reduce` artefacts/contracts. The campaign addition is characterised at case level as: Direct sequential composition against independent canonical oracle with admissibility/oracle controls and implementation/assertion mutants. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 3: Sequential Subtraction and Reduction → item 1, “Sequential subtraction--reduction refinement”. Chapter 4 uses the case-level principal synthesis in Section 4.3.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C03-003`

- **Historical identifier:** `VC-SR1`

- **Case identifier:** `3`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub -> mlk_poly_reduce (VC-SR1)`

- **Property class:** `Sequential functional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768; supporting later-revision replay

- **Input domain:** Every coefficient difference representable in int16_t

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle R_i=\mathrm{canon}_q\!\left(\mathrm{int32}(A_i)-\mathrm{int32}(B_i)\right)`$

- **Assertion / harness mapping:** VC-SR1 direct production sequence assertions

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** M4 omitted-reduction and M5 false-oracle mutants rejected

- **Strongest bounded conclusion:** The pinned production sequence returns the independent canonical difference.

- **Explicit exclusion:** Later-revision replay is supporting, not complete replication.

- **Evidence locator:** `LOC-C03-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/VC_SR1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/VC_SR1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `f06bde16f80b90a8960976e46a72d57fd54ea4bc282bbd9e59bb98bf6a54fc58`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C03-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 3: Sequential Subtraction and Reduction → item 1, “Sequential subtraction--reduction refinement”.


</details>

---


# Case-level bounded conclusion

For each i, $`\mathrm{reduce}(\mathrm{sub}(A,B))_i=\mathrm{canon}_q\!\left(\mathrm{int32}(A_i)-\mathrm{int32}(B_i)\right)`$ within the signed-representable difference domain.

**Explicit exclusion.** Does not establish complete correctness of either function independently, every caller, the surrounding decryption operation or ML-KEM as a whole.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
