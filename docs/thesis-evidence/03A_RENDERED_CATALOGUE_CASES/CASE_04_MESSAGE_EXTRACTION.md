# Case 4 — Message Extraction

**Target:** `mlk_poly_tomsg`
**Evidence locator:** `LOC-C04-UA`
**Chapter 4 projection:** Section 4.4.1
**Ledger records:** 13
**Formally supported subset:** 13

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

Which canonical coefficients produce message bit 1, how are the 256 decisions packed into 32 bytes, and how tightly is the frozen machine-level decision expression characterised?

## Case notation and opening equations


$$
O(u)=\begin{cases}1,&833\le u\le2496,\\0,&\text{otherwise},\end{cases}
$$


$$
\operatorname{bit}(m,k)\text{ denotes bit }k\text{ in the production LSB-first message layout}
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
\operatorname{bit}(\operatorname{ToMsg}(A),k)=O(A_k)
$$


$$
\mathcal C_{\mathrm{adm}}=[1073417800,1074063871],\qquad c_{\mathrm{prod}}=1073741824=2^{30}\in\mathcal C_{\mathrm{adm}}
$$


**Recorded principal-claim wording:** bit_k(tomsg(A))=1 iff 833<=A_k<=2496 for canonical A_k; the 256 bits are packed LSB-first into 32 bytes. The exact accepted arithmetic-offset interval is [1073417800,1074063871].


### Why this claim is the principal case-level synthesis

The coefficient decision and complete packing relation are the externally meaningful semantics of message extraction. Locality and XOR relations strengthen that semantics across executions; the offset-interval family explains the exact frozen arithmetic implementation. The implementation-parameter characterisation is important evidence, but it is subordinate to the message-bit semantics and must remain tied to the pinned multiplier and shift.


The survival ledger assigns this synthesis to **4.4.1** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768`. Its primary verification focus was: Exact coefficient-to-bit decision and 32-byte packing; relational/locality properties; exact offset-interval characterization. The additional or mixed evidence was: Coverage and loop-sensitivity checks were retained; selected mutations were killed; claims are directional and do not turn arbitrary polynomials into an exact round trip.


The retained case matrix records CBMC execution as **YES — MSG-T1 and integrated T1/T2/T5 records report successful proof, coverage and consolidation**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** The pinned portable-C implementation applies the recorded coefficient decision rule and packs the resulting 256 bits into the correct 32-byte layout under the selected domain.


**Integrity boundary:** Actual production body and fixed 256-coefficient/32-byte structure were retained.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md` with entry SHA-256 `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`. The case archive is `thesis_batch_3.zip` with SHA-256 `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **36** indexed records for `LOC-C04-UA`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=4. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native `poly_tomsg` one-call contract/harness and helper implementation.


**Necessary overlap.** Target call, coefficient count, byte count and compression helper constants.


**What this campaign added.** Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization.


**Why the suite is substantively distinct within the inspected corpus.** The generated suite states full semantic/relational and parameter-characterization claims not exposed by the native boilerplate call harness.


**Comparison material inspected.** `proofs/cbmc/poly_tomsg/`, production helper/contracts, MSG novelty audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESS_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tomsg/poly_tomsg_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tomsg/Makefile

- **Native proof entry SHA-256:** 3e656fedeaf8534dc9cd19250b559cd7ca4def24a976ed70b88f7b5013305398;9f2c928bc763aaaecd77520042aac8db78a0bfcefd3c4f579d41220592159fc4

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.h

- **Production source entry SHA-256:** 9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad;0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

- **Authoritative baseline characterisation:** A dedicated native `poly_tomsg` one-call harness exists. Any retained summary statement claiming no dedicated directory is superseded by this frozen-source census.

- **Conflict resolution:** RETAINED_TOMSG_SUMMARY_ABSENCE_CLAIM_SUPERSEDED_BY_FROZEN_SOURCE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DIRECT_SEMANTIC_SUPPORT` | `PR-C04-001`, `PR-C04-002`, `PR-C04-009`, `PR-C04-010`, `PR-C04-011`, `PR-C04-012`, `PR-C04-013` | states the core value/representation relation |

| `STATE_AND_FRAME_SUPPORT` | `PR-C04-005`, `PR-C04-007` | protects inputs, guards, footprints or unrelated state |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-C04-003`, `PR-C04-004`, `PR-C04-006`, `PR-C04-008` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `MSG-T1.P1`, `MSG-T1.P2`, `MSG-T2.R1`, `MSG-T2.R2A`, `MSG-T2.R2B`, `MSG-T2.R3A`, `MSG-T2.R3B.1`, `MSG-T2.R3B.2`, `MSG-T5.P1`, `MSG-T5.P2`, `MSG-T5.P3`, `MSG-T5.P4`, `MSG-T5.P5`


**Survival-ledger contrary/unresolved IDs:** `CONFLICT-C04-NATIVE-DIR`


## Thesis-appendix projection


The compact Appendix 1 projection contains **13** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `CONFLICT-C04-NATIVE-DIR` | `EVIDENCE_SOURCE_CONFLICT` | The frozen af4c5abd source tree contains `proofs/cbmc/poly_tomsg/poly_tomsg_harness.c` and its Makefile. | Frozen source controls. The native one-call harness is recorded as present; distinctness rests on the generated semantic/relational suite, not harness absence. |


## Assurance-layer and literature relationship

This comparison prevents repository-relative distinctness from being rewritten as global mathematical novelty. The rows below are interpretive context; implementation support still comes from the source-bound evidence for this case.

| Source/project | Relationship | Overlap | Important difference | Permitted conclusion |
|---|---|---|---|---|

| NIST FIPS 203 (2024a) | `NORMATIVE_GROUNDING` | Grounds ML-KEM operations, domains and data formats relevant to the case. | FIPS 203 is not a proof that this C implementation or generated harness is correct. | The case is specification-grounded where applicable; implementation support comes from the recorded source-bound CBMC evidence, not from the standard alone. |

| PQ Code Package / mlkem-native assurance documentation (n.d.-a; n.d.-b) | `NATIVE_ASSURANCE_CONTEXT` | Shares the exact production repository and some target contracts/harness infrastructure. | Native artefacts support different or narrower property sets and different assurance layers; the case-specific distinction is recorded in matrix 04. | Report repository-relative generated artefact/property contribution, not absence of all prior assurance. |

| Formosa Crypto and Almeida et al. (2023; 2024; 2025) | `RELATED_PROOF_ORIENTED_ASSURANCE` | Covers ML-KEM/Kyber functional and representation reasoning in proof-oriented settings. | Different implementation language/source, specifications, proof infrastructure and assurance boundary from local CBMC checks over mlkem-native C. | Use as assurance-layer comparison; do not claim the first formal proof of the underlying mathematics or operation. |

| HACL* and EverCrypt (Zinzindohoué et al., 2017; Protzenko et al., 2020) | `RELATED_VERIFIED_CRYPTOGRAPHIC_IMPLEMENTATION_CONTEXT` | Demonstrates verified functional/memory/representation artefacts in other cryptographic codebases. | Different implementations, languages, specifications and trusted toolchains. | Use only as broader high-assurance context, not an exact prior-art match. |


## Publication-state and traceability-field note

The archive-identity fields below preserve the frozen evidence package, while the public-path fields reproduce the current authoritative ledger after live repository finalization. The earlier RC2 values `UNRESOLVED_UNTIL_FINALIZER`, blank `public_evidence_sha256`, and `PENDING` are historical pre-finalization metadata and are not presented as the installed state. Public paths and hashes are reported only when the repository finalizer resolved and hash-matched them; no path or hash is inferred.

# Complete record-by-record catalogue


## PR-C04-001 — Exact coefficient-to-bit decision


### Formal statement

$$
\mathrm{bit}=1\Longleftrightarrow 833\le u\le2496,\qquad\text{otherwise }\mathrm{bit}=0
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact coefficient-to-bit decision** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG-T1 exact FIPS candidate harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: 8/8 selected T1 semantic mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG-T1 exact FIPS candidate harness`. The admitted domain is: Canonical coefficient u in [0,3328]. The recorded assumptions/grounding are: Production scalar helper and polynomial traversal. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Every canonical coefficient is mapped to the registered decision bit.

**What this record does not establish:** Not a reverse identity for arbitrary polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 1, “Exact coefficient-to-bit decision”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-001`

- **Historical identifier:** `MSG-T1.P1`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Functional refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical coefficient u in [0,3328]

- **Assumptions and grounding:** Production scalar helper and polynomial traversal

- **Ledger formal relation:** bit=1 iff 833<=u<=2496; otherwise bit=0

- **Assertion / harness mapping:** MSG-T1 exact FIPS candidate harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** 8/8 selected T1 semantic mutants rejected

- **Strongest bounded conclusion:** Every canonical coefficient is mapped to the registered decision bit.

- **Explicit exclusion:** Not a reverse identity for arbitrary polynomials.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 1, “Exact coefficient-to-bit decision”.


</details>

---

## PR-C04-002 — Exact 32-byte LSB-first packing


### Formal statement

$$
\mathrm{bit}(\mathrm{ToMsg}(A),k)=O(A_k)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact 32-byte LSB-first packing** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG-T1 packing assertions`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: T1 loop and packing mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG-T1 packing assertions`. The admitted domain is: 256 canonical coefficients. The recorded assumptions/grounding are: Complete 256-coefficient traversal. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The 256 decisions are packed into the required 32-byte layout.

**What this record does not establish:** No claim outside the pinned representation/build.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 2, “Complete LSB-first message packing”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-002`

- **Historical identifier:** `MSG-T1.P2`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Encoding`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** 256 canonical coefficients

- **Assumptions and grounding:** Complete 256-coefficient traversal

- **Ledger formal relation:** message[k>>3] bit (k&7) equals decision(coeff[k])

- **Assertion / harness mapping:** MSG-T1 packing assertions

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T1 loop and packing mutants rejected

- **Strongest bounded conclusion:** The 256 decisions are packed into the required 32-byte layout.

- **Explicit exclusion:** No claim outside the pinned representation/build.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 2, “Complete LSB-first message packing”.


</details>

---

## PR-C04-003 — Relational XOR law


### Formal statement

$$
\operatorname{bit}_k\!\left(\operatorname{ToMsg}(A)\oplus\operatorname{ToMsg}(B)\right)=O(A_k)\oplus O(B_k)
$$


### What the property/control means

The property checks the structural or multi-execution law **Relational XOR law**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Corresponding T2 antecedent/corruption mutant rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. The admitted domain is: Canonical A,B; symbolic coefficient k. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered relational or locality property is supported.

**What this record does not establish:** Does not establish constant-time behaviour.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 3, “XOR differential relation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-003`

- **Historical identifier:** `MSG-T2.R1`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical A,B; symbolic coefficient k

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** bit_k(tomsg(A) XOR tomsg(B)) = oracle(A[k]) XOR oracle(B[k])

- **Assertion / harness mapping:** MSG-T2 R1/R2A/R2B/R3A/R3B harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Corresponding T2 antecedent/corruption mutant rejected

- **Strongest bounded conclusion:** The registered relational or locality property is supported.

- **Explicit exclusion:** Does not establish constant-time behaviour.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 3, “XOR differential relation”.


</details>

---

## PR-C04-004 — Selected coefficient locality


### Formal statement

$$
A_k=B_k\Longrightarrow \mathrm{bit}(\mathrm{ToMsg}(A),k)=\mathrm{bit}(\mathrm{ToMsg}(B),k)
$$


### What the property/control means

The property checks the structural or multi-execution law **Selected coefficient locality**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Corresponding T2 antecedent/corruption mutant rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. The admitted domain is: Canonical A,B; symbolic coefficient k. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered relational or locality property is supported.

**What this record does not establish:** Does not establish constant-time behaviour.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 4, “Equal-coefficient locality”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-004`

- **Historical identifier:** `MSG-T2.R2A`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical A,B; symbolic coefficient k

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** A[k]=B[k] => bit_k(tomsg(A))=bit_k(tomsg(B))

- **Assertion / harness mapping:** MSG-T2 R1/R2A/R2B/R3A/R3B harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Corresponding T2 antecedent/corruption mutant rejected

- **Strongest bounded conclusion:** The registered relational or locality property is supported.

- **Explicit exclusion:** Does not establish constant-time behaviour.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 4, “Equal-coefficient locality”.


</details>

---

## PR-C04-005 — Cross-bit preservation and byte confinement


### Formal statement

$$
\left(A_j=B_j\;\forall j\ne k\right)\Longrightarrow\left(\operatorname{bit}_j(\operatorname{ToMsg}(A))=\operatorname{bit}_j(\operatorname{ToMsg}(B))\;\forall j\ne k\right),\quad\mathrm{ChangedBytes}\subseteq\{\lfloor k/8\rfloor\}
$$


### What the property/control means

The property checks **Cross-bit preservation and byte confinement** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Corresponding T2 antecedent/corruption mutant rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. The admitted domain is: Canonical A,B; symbolic coefficient k. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered relational or locality property is supported.

**What this record does not establish:** Does not establish constant-time behaviour.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 5, “Single-coordinate output locality”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-005`

- **Historical identifier:** `MSG-T2.R2B`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical A,B; symbolic coefficient k

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** if only coefficient k may change, all output bits other than k are preserved; change is confined to byte k>>3

- **Assertion / harness mapping:** MSG-T2 R1/R2A/R2B/R3A/R3B harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Corresponding T2 antecedent/corruption mutant rejected

- **Strongest bounded conclusion:** The registered relational or locality property is supported.

- **Explicit exclusion:** Does not establish constant-time behaviour.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 5, “Single-coordinate output locality”.


</details>

---

## PR-C04-006 — Same-decision invariance


### Formal statement

$$
O(A_k)=O(B_k)\Longrightarrow \mathrm{bit}(\mathrm{ToMsg}(A),k)=\mathrm{bit}(\mathrm{ToMsg}(B),k)
$$


### What the property/control means

The property checks the structural or multi-execution law **Same-decision invariance**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Corresponding T2 antecedent/corruption mutant rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. The admitted domain is: Canonical A,B; symbolic coefficient k. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered relational or locality property is supported.

**What this record does not establish:** Does not establish constant-time behaviour.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 6, “Decision-equivalence locality”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-006`

- **Historical identifier:** `MSG-T2.R3A`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical A,B; symbolic coefficient k

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** oracle(A[k])=oracle(B[k]) => selected output bits equal

- **Assertion / harness mapping:** MSG-T2 R1/R2A/R2B/R3A/R3B harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Corresponding T2 antecedent/corruption mutant rejected

- **Strongest bounded conclusion:** The registered relational or locality property is supported.

- **Explicit exclusion:** Does not establish constant-time behaviour.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 6, “Decision-equivalence locality”.


</details>

---

## PR-C04-007 — Input-frame preservation


### Formal statement

$$
A_{\mathrm{after}}=A_{\mathrm{before}}\quad\land\quad B_{\mathrm{after}}=B_{\mathrm{before}}
$$


### What the property/control means

The property checks **Input-frame preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Corresponding T2 antecedent/corruption mutant rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. The admitted domain is: Canonical A,B; symbolic coefficient k. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered relational or locality property is supported.

**What this record does not establish:** Does not establish constant-time behaviour.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 7, “Polynomial-input frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-007`

- **Historical identifier:** `MSG-T2.R3B.1`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical A,B; symbolic coefficient k

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** A and B are unchanged by their production calls

- **Assertion / harness mapping:** MSG-T2 R1/R2A/R2B/R3A/R3B harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Corresponding T2 antecedent/corruption mutant rejected

- **Strongest bounded conclusion:** The registered relational or locality property is supported.

- **Explicit exclusion:** Does not establish constant-time behaviour.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 7, “Polynomial-input frame preservation”.


</details>

---

## PR-C04-008 — Complete-message determinism


### Formal statement

$$
A=B\Longrightarrow \mathrm{ToMsg}(A)=\mathrm{ToMsg}(B)
$$


### What the property/control means

The property checks the structural or multi-execution law **Complete-message determinism**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Corresponding T2 antecedent/corruption mutant rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG-T2 R1/R2A/R2B/R3A/R3B harness`. The admitted domain is: Canonical A,B; symbolic coefficient k. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered relational or locality property is supported.

**What this record does not establish:** Does not establish constant-time behaviour.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 8, “Determinism”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-008`

- **Historical identifier:** `MSG-T2.R3B.2`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical A,B; symbolic coefficient k

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** A=B => tomsg(A)=tomsg(B)

- **Assertion / harness mapping:** MSG-T2 R1/R2A/R2B/R3A/R3B harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Corresponding T2 antecedent/corruption mutant rejected

- **Strongest bounded conclusion:** The registered relational or locality property is supported.

- **Explicit exclusion:** Does not establish constant-time behaviour.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 8, “Determinism”.


</details>

---

## PR-C04-009 — Production-offset model binding


### Formal statement

$$
\begin{aligned}F_{c_{\mathrm{prod}}}(u)&=O(u),\qquad 0\le u<q,\\c_{\mathrm{prod}}&=1073741824=2^{30}.\end{aligned}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Production-offset model binding** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG05C-G evidence chain`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Lower/upper expansion mutations rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG05C-G evidence chain`. The admitted domain is: u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31. The recorded assumptions/grounding are: uint32 modular arithmetic and pinned helper expression. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

**What this record does not establish:** Not a general mathematical novelty or a proof for changed multiplier/shift.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 9, “Production decision expression agrees with the oracle”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-009`

- **Historical identifier:** `MSG-T5.P1`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Finite-domain parameter characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31

- **Assumptions and grounding:** uint32 modular arithmetic and pinned helper expression

- **Ledger formal relation:** F_c(u)=real helper and tomsg bit at production c

- **Assertion / harness mapping:** MSG05C-G evidence chain

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Lower/upper expansion mutations rejected

- **Strongest bounded conclusion:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

- **Explicit exclusion:** Not a general mathematical novelty or a proof for changed multiplier/shift.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** Source-evidence audited formalization of the retained technical record.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 9, “Production decision expression agrees with the oracle”.


</details>

---

## PR-C04-010 — Universal inside-interval sufficiency


### Formal statement

$$
\forall c\in[1073417800,1074063871]\;\forall u\in[0,q):\quad F_c(u)=O(u)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Universal inside-interval sufficiency** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG05C-G evidence chain`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Lower/upper expansion mutations rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG05C-G evidence chain`. The admitted domain is: u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31. The recorded assumptions/grounding are: uint32 modular arithmetic and pinned helper expression. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

**What this record does not establish:** Not a general mathematical novelty or a proof for changed multiplier/shift.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 10, “Complete valid-offset interval”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-010`

- **Historical identifier:** `MSG-T5.P2`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Finite-domain parameter characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31

- **Assumptions and grounding:** uint32 modular arithmetic and pinned helper expression

- **Ledger formal relation:** For all canonical u, F_c(u)=O(u) for every c in [1073417800,1074063871]

- **Assertion / harness mapping:** MSG05C-G evidence chain

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Lower/upper expansion mutations rejected

- **Strongest bounded conclusion:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

- **Explicit exclusion:** Not a general mathematical novelty or a proof for changed multiplier/shift.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 10, “Complete valid-offset interval”.


</details>

---

## PR-C04-011 — Universal outside-interval necessity


### Formal statement

$$
\forall c\notin[1073417800,1074063871]\;\exists u\in[0,q):\quad F_c(u)\ne O(u)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Universal outside-interval necessity** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG05C-G evidence chain`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Lower/upper expansion mutations rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG05C-G evidence chain`. The admitted domain is: u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31. The recorded assumptions/grounding are: uint32 modular arithmetic and pinned helper expression. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

**What this record does not establish:** Not a general mathematical novelty or a proof for changed multiplier/shift.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 11, “Offsets outside the interval are insufficient”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-011`

- **Historical identifier:** `MSG-T5.P3`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Finite-domain parameter characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31

- **Assumptions and grounding:** uint32 modular arithmetic and pinned helper expression

- **Ledger formal relation:** Every uint32 c outside [1073417800,1074063871] has a canonical u with F_c(u)!=O(u)

- **Assertion / harness mapping:** MSG05C-G evidence chain

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Lower/upper expansion mutations rejected

- **Strongest bounded conclusion:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

- **Explicit exclusion:** Not a general mathematical novelty or a proof for changed multiplier/shift.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 11, “Offsets outside the interval are insufficient”.


</details>

---

## PR-C04-012 — Exact admissible offset interval


### Formal statement

$$
\left\{c:\forall u\in[0,q),\,F_c(u)=O(u)\right\}=[1073417800,1074063871]
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact admissible offset interval** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG05C-G evidence chain`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Lower/upper expansion mutations rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG05C-G evidence chain`. The admitted domain is: u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31. The recorded assumptions/grounding are: uint32 modular arithmetic and pinned helper expression. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

**What this record does not establish:** Not a general mathematical novelty or a proof for changed multiplier/shift.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 12, “Exactness of the admissible-offset set”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-012`

- **Historical identifier:** `MSG-T5.P4`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Finite-domain parameter characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31

- **Assumptions and grounding:** uint32 modular arithmetic and pinned helper expression

- **Ledger formal relation:** {c : forall u in [0,3328], F_c(u)=O(u)}=[1073417800,1074063871]

- **Assertion / harness mapping:** MSG05C-G evidence chain

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Lower/upper expansion mutations rejected

- **Strongest bounded conclusion:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

- **Explicit exclusion:** Not a general mathematical novelty or a proof for changed multiplier/shift.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 12, “Exactness of the admissible-offset set”.


</details>

---

## PR-C04-013 — Endpoint tightness and production membership


### Formal statement

$$
\begin{aligned}
c_{\mathrm{prod}}&=1073741824=2^{30},\\
1073417800&\le c_{\mathrm{prod}}\le1074063871,\\
1073417799&\notin\mathcal C_{\mathrm{adm}}\quad (u=2497),\\
1074063872&\notin\mathcal C_{\mathrm{adm}}\quad (u=832).
\end{aligned}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Endpoint tightness and production membership** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `MSG05C-G evidence chain`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Lower/upper expansion mutations rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `MSG05C-G evidence chain`. The admitted domain is: u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31. The recorded assumptions/grounding are: uint32 modular arithmetic and pinned helper expression. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

**What this record does not establish:** Not a general mathematical novelty or a proof for changed multiplier/shift.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_tomsg` one-call contract/harness and helper implementation. The campaign addition is characterised at case level as: Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 13, “Tight interval endpoints”. Chapter 4 uses the case-level principal synthesis in Section 4.4.1; this record remains available here so that the compression does not erase its evidential role.


### Evidence-verified transcription correction

The pre-correction ledger wording says `2^25`; the retained MSG-T5 record states `PRODUCTION_OFFSET=1073741824`, i.e. $2^{30}$, and records the production offset as admissible. The rendered equation follows the retained primary evidence. The supplied ledger patch changes only this exponent wording in the two ledger twins.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C04-013`

- **Historical identifier:** `MSG-T5.P5`

- **Case identifier:** `4`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tomsg`

- **Property class:** `Finite-domain parameter characterization`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** u in [0,3328], c in uint32; fixed multiplier 1290168 and shift 31

- **Assumptions and grounding:** uint32 modular arithmetic and pinned helper expression

- **Ledger formal relation:** Both endpoints are one-step tight and production offset 1073741824 (=2^30) lies in the interval

- **Assertion / harness mapping:** MSG05C-G evidence chain

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Lower/upper expansion mutations rejected

- **Strongest bounded conclusion:** The exact accepted offset interval is characterized for the frozen arithmetic expression.

- **Explicit exclusion:** Not a general mathematical novelty or a proof for changed multiplier/shift.

- **Evidence locator:** `LOC-C04-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Archive entry SHA-256:** `f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/MLK_POLY_TOMSG_MSG_T1_T2_T5_COMPLETE_A_TO_Z_AND_NOVELTY_RECORD_2026-07-23(2).md

- **Public evidence SHA-256:** f0006a8594703df250c9f1c6978dd5c03d323650774daee9d4fdb3d48e141f7b

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** Evidence-verified correction of a ledger transcription error; the original ledger wording remains visible below for auditability.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 4: Message Extraction: mlk_poly_tomsg → item 13, “Tight interval endpoints”.


</details>

---


# Case-level bounded conclusion

bit_k(tomsg(A))=1 iff 833<=A_k<=2496 for canonical A_k; the 256 bits are packed LSB-first into 32 bytes. The exact accepted arithmetic-offset interval is [1073417800,1074063871].

**Explicit exclusion.** Not a reverse identity for arbitrary polynomials.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
