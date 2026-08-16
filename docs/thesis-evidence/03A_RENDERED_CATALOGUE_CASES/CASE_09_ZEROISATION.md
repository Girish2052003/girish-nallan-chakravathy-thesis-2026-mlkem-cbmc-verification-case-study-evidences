# Case 9 — Zeroisation

**Target:** `mlk_zeroize`
**Evidence locator:** `LOC-C09-UA`
**Chapter 4 projection:** Section 4.5.1
**Ledger records:** 16
**Formally supported subset:** 16

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768 build; bounded memory objects
**Evidence completeness:** `COMPLETE`

## Verification question

Does the production operation erase exactly the authorised byte interval in the encoded C memory state, preserve everything outside that interval, and compose predictably under repeated, partitioned and release-handoff use?

## Case notation and opening equations


$$
Z_I(M)\text{ is the post-state after zeroising interval }I
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
Z_I(M)[j]=\left\lbrace\begin{array}{ll}0,&j\in I,\\ M[j],&j\notin I,\end{array}\right.
$$


$$
Z_I(Z_I(M))=Z_I(M)
$$


**Recorded principal-claim wording:** For a valid selected interval I, Z_I(M) sets exactly the selected bytes to zero while preserving the registered frame; the recorded idempotence, partition, commutativity and release-handoff relations also hold.


### Why this claim is the principal case-level synthesis

Exact erasure and frame preservation must be read together: either alone would leave a material gap. Idempotence, partition, overlap, commutativity and release-handoff records strengthen the operational meaning of the post-state. The principal claim remains explicitly source-level and does not assert physical-remanence elimination.


The survival ledger assigns this synthesis to **4.5.1** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768 build`. Its primary verification focus was: Exact selected-slice erasure; frame preservation and zero-length behaviour; relational/compositional memory-state properties; MLK_FREE release handoff. The additional or mixed evidence was: Sixteen core obligations and 8/8 killed mutants are reported; the conclusion is source-level C memory semantics, not physical remanence elimination.


The retained case matrix records CBMC execution as **YES — four theorem families accepted**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** The pinned source-level implementation overwrites exactly the selected valid region and satisfies the recorded frame, relational and release-handoff properties in the encoded C model.


**Integrity boundary:** Production source remained unchanged; source-level proof cannot establish compiler/hardware erasure on every platform.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md` with entry SHA-256 `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`. The case archive is `thesis_batch_3.zip` with SHA-256 `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **32** indexed records for `LOC-C09-UA`: COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree.


**Necessary overlap.** Same target, pointer/size requirements and zero value.


**What this campaign added.** Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties.


**Why the suite is substantively distinct within the inspected corpus.** The generated suite supplies a dedicated functional and relational zeroisation campaign—exact selected-region erasure, frame confinement, zero-length identity, composition and release handoff—where the frozen native proof tree has no dedicated zeroize harness.


**Comparison material inspected.** Archive-verified frozen proof census; production `mlkem/src/verify.h` and `mlkem/src/common.h`; ZERO campaign audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** NO_DEDICATED_ZEROIZE_PROOF_DIRECTORY

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/verify.h;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/common.h

- **Production source entry SHA-256:** 13f44749f65099bee5bc55be260932d5e832bbd091335f1e47c31df464c1881f;cc48998e9595ec4e59a3aa53d6be9e55ecccb3cdc047e661ccd94fa99955d675

- **Authoritative baseline characterisation:** Production zeroize source/contracts and release macros exist; no dedicated native `proofs/cbmc/zeroize/` directory exists.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `STATE_AND_FRAME_SUPPORT` | `PR-C09-001`, `PR-C09-002`, `PR-C09-003`, `PR-C09-004`, `PR-C09-005`, `PR-C09-006`, `PR-C09-007`, `PR-C09-008`, `PR-C09-009`, `PR-C09-010`, `PR-C09-011`, `PR-C09-012`, `PR-C09-013`, `PR-C09-014`, `PR-C09-015`, `PR-C09-016` | protects inputs, guards, footprints or unrelated state |


**Survival-ledger supporting historical IDs:** `ZERO-T1.P1`, `ZERO-T1.P2`, `ZERO-T1.P3`, `ZERO-T2.P1`, `ZERO-T2.P2`, `ZERO-T2.P3`, `ZERO-T2.P4`, `ZERO-T3.P1`, `ZERO-T3.P2`, `ZERO-T3.P3`, `ZERO-T3.P4`, `ZERO-T4.P1`, `ZERO-T4.P2`, `ZERO-T4.P3`, `ZERO-T4.P4`, `ZERO-T4.P5`


## Thesis-appendix projection


The compact Appendix 1 projection contains **16** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `LIM-C09-PHYSICAL` | `OUT_OF_SCOPE` | CBMC supports the C abstract-machine poststate only. | No compiler/hardware/physical-erasure conclusion. |


## Assurance-layer and literature relationship

This comparison prevents repository-relative distinctness from being rewritten as global mathematical novelty. The rows below are interpretive context; implementation support still comes from the source-bound evidence for this case.

| Source/project | Relationship | Overlap | Important difference | Permitted conclusion |
|---|---|---|---|---|

| NIST FIPS 203 (2024a) | `NORMATIVE_GROUNDING` | Grounds ML-KEM operations, domains and data formats relevant to the case. | FIPS 203 is not a proof that this C implementation or generated harness is correct. | The case is specification-grounded where applicable; implementation support comes from the recorded source-bound CBMC evidence, not from the standard alone. |

| PQ Code Package / mlkem-native assurance documentation (n.d.-a; n.d.-b) | `NATIVE_ASSURANCE_CONTEXT` | Shares the exact production repository and some target contracts/harness infrastructure. | Native artefacts support different or narrower property sets and different assurance layers; the case-specific distinction is recorded in matrix 04. | Report repository-relative generated artefact/property contribution, not absence of all prior assurance. |

| HACL* and EverCrypt (Zinzindohoué et al., 2017; Protzenko et al., 2020) | `RELATED_VERIFIED_CRYPTOGRAPHIC_IMPLEMENTATION_CONTEXT` | Demonstrates verified functional/memory/representation artefacts in other cryptographic codebases. | Different implementations, languages, specifications and trusted toolchains. | Use only as broader high-assurance context, not an exact prior-art match. |


## Publication-state and traceability-field note

The record blocks below preserve the frozen RC2 public-path fields only as explicitly labelled historical provenance. Their former `PENDING`, `UNRESOLVED_UNTIL_FINALIZER`, blank public-SHA and candidate-count values describe the pre-finalization snapshot; they do **not** describe the current repository. The current authoritative ledger records all 257 substantive records as `RESOLVED_HASH_MATCH` and supplies the exact current public path and SHA-256. To avoid creating a second mutable authority, this catalogue points each record back to its current ledger row instead of copying those current path/hash strings into prose.

Scientific outcome status is independent. Supported, negative, abstraction-limited, resource-limited, diagnostic, construction and preservation classifications are reproduced unchanged.

# Complete record-by-record catalogue


## PR-C09-001 — First selected region is zero


### Formal statement

$$
\forall i\in I_A:\quad M_i^{\mathrm{post}}=0
$$


### What the property/control means

The property checks **First selected region is zero** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 1, “Exact overwrite of registered region $A$”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-001`

- **Historical identifier:** `ZERO-T1.P1`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** forall i in selected region A: post[i]=0

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 1, “Exact overwrite of registered region $A$”.


</details>

---

## PR-C09-002 — Second selected region is zero


### Formal statement

$$
\forall i\in I_B:\quad M_i^{\mathrm{post}}=0
$$


### What the property/control means

The property checks **Second selected region is zero** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 2, “Exact overwrite of registered region $B$”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-002`

- **Historical identifier:** `ZERO-T1.P2`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** forall i in selected region B: post[i]=0

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 2, “Exact overwrite of registered region $B$”.


</details>

---

## PR-C09-003 — Selected poststate independence


### Formal statement

$$
Z_I(M_1)|_I=Z_I(M_2)|_I
$$


### What the property/control means

The property checks **Selected poststate independence** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 3, “Secret-history convergence”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-003`

- **Historical identifier:** `ZERO-T1.P3`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** different prestate bytes in wiped region converge to identical zero poststate

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 3, “Secret-history convergence”.


</details>

---

## PR-C09-004 — Prefix frame


### Formal statement

$$
Z_I(M)|_{\mathrm{prefix}(I)}=M|_{\mathrm{prefix}(I)}
$$


### What the property/control means

The property checks **Prefix frame** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 4, “Prefix-frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-004`

- **Historical identifier:** `ZERO-T2.P1`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** bytes before selected interval unchanged

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 4, “Prefix-frame preservation”.


</details>

---

## PR-C09-005 — Suffix frame


### Formal statement

$$
Z_I(M)|_{\mathrm{suffix}(I)}=M|_{\mathrm{suffix}(I)}
$$


### What the property/control means

The property checks **Suffix frame** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 5, “Suffix-frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-005`

- **Historical identifier:** `ZERO-T2.P2`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** bytes after selected interval unchanged

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 5, “Suffix-frame preservation”.


</details>

---

## PR-C09-006 — Unrelated-object frame


### Formal statement

$$
Z_I(M)|_{\mathrm{guard}}=M|_{\mathrm{guard}}
$$


### What the property/control means

The property checks **Unrelated-object frame** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 6, “Unrelated-guard preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-006`

- **Historical identifier:** `ZERO-T2.P3`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** separate guard object unchanged

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 6, “Unrelated-guard preservation”.


</details>

---

## PR-C09-007 — Zero-length identity


### Formal statement

$$
Z_{\varnothing}(M)=M
$$


### What the property/control means

The property checks **Zero-length identity** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 7, “Zero-length identity”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-007`

- **Historical identifier:** `ZERO-T2.P4`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** zeroize(ptr,0) leaves modelled state unchanged

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 7, “Zero-length identity”.


</details>

---

## PR-C09-008 — Idempotence


### Formal statement

$$
Z_I(Z_I(M))=Z_I(M)
$$


### What the property/control means

The property checks **Idempotence** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 8, “Idempotence”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-008`

- **Historical identifier:** `ZERO-T3.P1`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** Z_I(Z_I(M))=Z_I(M)

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 8, “Idempotence”.


</details>

---

## PR-C09-009 — Adjacent partition equivalence


### Formal statement

$$
Z_{[a,b)}(Z_{[b,c)}(M))=Z_{[a,c)}(M)
$$


### What the property/control means

The property checks **Adjacent partition equivalence** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 9, “Adjacent-partition equivalence”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-009`

- **Historical identifier:** `ZERO-T3.P2`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** Z_[a,b)(Z_[b,c)(M))=Z_[a,c)(M)

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 9, “Adjacent-partition equivalence”.


</details>

---

## PR-C09-010 — Disjoint wipe commutativity


### Formal statement

$$
Z_I(Z_J(M))=Z_J(Z_I(M))
$$


### What the property/control means

The property checks **Disjoint wipe commutativity** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 10, “Disjoint-wipe commutativity”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-010`

- **Historical identifier:** `ZERO-T3.P3`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** Z_I(Z_J(M))=Z_J(Z_I(M)) for disjoint I,J

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 10, “Disjoint-wipe commutativity”.


</details>

---

## PR-C09-011 — Overlapping-union equivalence


### Formal statement

$$
Z_I(Z_J(M))=Z_{I\cup J}(M)
$$


### What the property/control means

The property checks **Overlapping-union equivalence** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 11, “Overlapping-wipe union equivalence”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-011`

- **Historical identifier:** `ZERO-T3.P4`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** sequential overlapping wipes equal wipe of interval union

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 11, “Overlapping-wipe union equivalence”.


</details>

---

## PR-C09-012 — Default MLK_FREE full-allocation wipe


### Formal statement

$$
\forall x\in I_{\mathrm{alloc}}:\quad M_{\mathrm{observed}}[x]=0
$$


### What the property/control means

The property checks **Default MLK_FREE full-allocation wipe** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 12, “Default release-path whole-object wipe”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-012`

- **Historical identifier:** `ZERO-T4.P1`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** default release path observes all bytes of selected backing allocation zero

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-012`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 12, “Default release-path whole-object wipe”.


</details>

---

## PR-C09-013 — Pointer reset


### Formal statement

$$
p_{\mathrm{after\ release}}=\mathrm{NULL}
$$


### What the property/control means

The property checks **Pointer reset** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 13, “Pointer reset after release hand-off”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-013`

- **Historical identifier:** `ZERO-T4.P2`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** released pointer is set to NULL

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-013`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 13, “Pointer reset after release hand-off”.


</details>

---

## PR-C09-014 — Custom-free zero observation


### Formal statement

$$
\forall x\in I_{\mathrm{object}}:\quad M_{\mathrm{custom\ free}}[x]=0
$$


### What the property/control means

The property checks **Custom-free zero observation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 14, “Custom-free observer sees the zeroised state”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-014`

- **Historical identifier:** `ZERO-T4.P3`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** custom free observer sees all-zero selected object

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-014`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 14, “Custom-free observer sees the zeroised state”.


</details>

---

## PR-C09-015 — Custom free called once for non-null


### Formal statement

$$
p\ne\mathrm{NULL}\Longrightarrow N_{\mathrm{custom\ free}}=1
$$


### What the property/control means

The property checks **Custom free called once for non-null** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 15, “Non-null custom release is invoked exactly once”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-015`

- **Historical identifier:** `ZERO-T4.P4`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** non-null release invokes custom free exactly once

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-015`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 15, “Non-null custom release is invoked exactly once”.


</details>

---

## PR-C09-016 — Custom free not called for null


### Formal statement

$$
p=\mathrm{NULL}\Longrightarrow N_{\mathrm{custom\ free}}=0
$$


### What the property/control means

The property checks **Custom free not called for null** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `ZERO T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `ZERO T1–T4 final harness assertion`. The admitted domain is: Registered valid bounded objects and selected byte intervals. The recorded assumptions/grounding are: C abstract-machine memory model; valid pointer/size conditions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named source-level memory-state relation is supported.

**What this record does not establish:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


### Native-baseline relationship

The frozen native baseline for this case is: The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree. The campaign addition is characterised at case level as: Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 16, “Null input does not invoke the custom release”. Chapter 4 uses the case-level principal synthesis in Section 4.5.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C09-016`

- **Historical identifier:** `ZERO-T4.P5`

- **Case identifier:** `9`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_zeroize`

- **Property class:** `Memory-state/frame`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded memory objects

- **Input domain:** Registered valid bounded objects and selected byte intervals

- **Assumptions and grounding:** C abstract-machine memory model; valid pointer/size conditions

- **Ledger formal relation:** null release does not invoke custom free

- **Assertion / harness mapping:** ZERO T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected mutants killed

- **Strongest bounded conclusion:** The named source-level memory-state relation is supported.

- **Explicit exclusion:** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.

- **Evidence locator:** `LOC-C09-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_ZEROIZE_CBMC_CAMPAIGN_COMPLETE_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `b229b806d289a72fe56a4a9dc8c523aabd1c4064bcf95738d43dd47a009235ef`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C09-016`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 9: Zeroisation: mlk_zeroize → item 16, “Null input does not invoke the custom release”.


</details>

---


# Case-level bounded conclusion

For a valid selected interval I, Z_I(M) sets exactly the selected bytes to zero while preserving the registered frame; the recorded idempotence, partition, commutativity and release-handoff relations also hold.

**Explicit exclusion.** No universal physical-remanence, compiler-optimization or hardware-erasure conclusion.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
