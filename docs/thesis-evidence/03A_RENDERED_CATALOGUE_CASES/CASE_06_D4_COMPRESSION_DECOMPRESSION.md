# Case 6 — D4 Compression and Decompression

**Target:** `D4 portable-C compressor/decompressor`
**Evidence locator:** `LOC-C06-UA`
**Chapter 4 projection:** Section 4.4.3
**Ledger records:** 18
**Formally supported subset:** 18

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

Do the production D4 encoder and decoder implement the intended scalar transformations and packing, and what exact relation remains when the intentionally lossy canonical-domain composition is analysed?

## Case notation and opening equations


$$
C_4(u)=\mathop{\text{Round}}\!\left(\frac{16u}{q}\right)\bmod16
$$


$$
D_4(t)=\mathop{\text{Round}}\!\left(\frac{qt}{16}\right),\qquad0\le t<16
$$


$$
\mathop{\text{Proj}}_4=\mathop{\text{Decomp}}_4\circ\mathop{\text{Comp}}_4
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
\mathop{\text{Comp}}_4(\mathop{\text{Decomp}}_4(B))=B
$$


$$
\mathop{\text{Proj}}_4(A)=\mathop{\text{Decomp}}_4(\mathop{\text{Comp}}_4(A))
$$


$$
\mathop{\text{dist}}_q(A_i,\mathop{\text{Proj}}_4(A)_i)\le104
$$


**Recorded principal-claim wording:** `Comp4(Decomp4(B))=B` for every compressed byte array `B`; `Proj4(A)=Decomp4(Comp4(A))` is a coordinatewise projection onto the 16-value codebook with `dist_q(A_i,Proj4(A)_i)<=104`, and 104 is attainable.


### Why this claim is the principal case-level synthesis

Compression is deliberately lossy, so an unrestricted identity would be the wrong principal statement. The selected claim therefore pairs exact compressed-domain retraction with the canonical-domain projection and its sharp error bound. Per-direction refinements, packing, image, fixed-point, idempotence and locality records are the evidence that makes those compositions interpretable.


The survival ledger assigns this synthesis to **4.4.3** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768`. Its primary verification focus was: Exact D4 compressor refinement; exact D4 decompressor refinement; compress(decompress(B)) byte retraction; decompress(compress(A)) 16-level quantizer projection. The additional or mixed evidence was: The projection proof includes exact image, sharp modular error bound 104, fixed points, idempotence and coordinate locality; it is intentionally lossy on arbitrary canonical coefficients.


The retained case matrix records CBMC execution as **YES — T1–T4 accepted**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** The pinned D4 pair implements the recorded exact scalar/packing specifications, exact compressed-domain retraction and lossy canonical-domain projection with the sharp recorded error bound.


**Integrity boundary:** Only portable-C D4 at the pinned build was checked; no assembly/native equivalence claim.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md` with entry SHA-256 `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`. The case archive is `thesis_batch_2.zip` with SHA-256 `f8b48618fd64e068129684af69d28036b2d7af25fb99eb2c53a88b9a0f464ff9`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **32** indexed records for `LOC-C06-UA`: COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native D4 proof directories/contracts and wider repository/backend assurance.


**Necessary overlap.** Production calls, q/d=4 constants and byte layout.


**What this campaign added.** Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104.


**Why the suite is substantively distinct within the inspected corpus.** Independent full-output specifications and the combined retraction/projection/fixed-point/idempotence/locality evidence architecture are distinct from native call/safety harnesses.


**Comparison material inspected.** Native D4 CBMC directories, source/contracts, backend documentation and campaign audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESSES_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_compress_d4_c/poly_compress_d4_c_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_compress_d4_c/Makefile;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_decompress_d4_c/poly_decompress_d4_c_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_decompress_d4_c/Makefile

- **Native proof entry SHA-256:** 1c05299a02f0e160792fb3b07b992aefac92d31910e5fc128c6b8223cafe143b;4e871e99079704c94b01baad132cc2bb680f35333980d2a7cdb1f25a188cfc67;c7edc717d7e7d7411b13f6776f386fffa52b4b9252da9f9f9b48df6a29cb4602;59af1e11e7ef2e8b5ce4567d879917170fc3784e32a2e72471c7be7630479d1e

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.h

- **Production source entry SHA-256:** 9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad;0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

- **Authoritative baseline characterisation:** Dedicated native one-call harnesses exist for both portable-C D4 functions.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DIRECT_SEMANTIC_SUPPORT` | `PR-C06-001`, `PR-C06-002`, `PR-C06-003`, `PR-C06-005`, `PR-C06-006`, `PR-C06-007`, `PR-C06-008`, `PR-C06-009` | states the core value/representation relation |

| `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT` | `PR-C06-014`, `PR-C06-015` | establishes the finite domain, range or representation in which the core relation is meaningful |

| `STATE_AND_FRAME_SUPPORT` | `PR-C06-012` | protects inputs, guards, footprints or unrelated state |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-C06-004`, `PR-C06-010`, `PR-C06-016`, `PR-C06-017`, `PR-C06-018` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |

| `COMPOSITION_AND_CALLER_SUPPORT` | `PR-C06-011`, `PR-C06-013` | connects the local relation to callers, sequential operations, cross-function composition or parameter replication |


**Survival-ledger supporting historical IDs:** `D4-T1.P1`, `D4-T1.P2`, `D4-T1.P3`, `D4-T1.P4`, `D4-T2.P1`, `D4-T2.P2`, `D4-T2.P3`, `D4-T2.P4`, `D4-T2.P5`, `D4-T2.P6`, `D4-T3.P1`, `D4-T3.P2`, `D4-T3.P3`, `D4-T4.P1`, `D4-T4.P2`, `D4-T4.P3`, `D4-T4.P4`, `D4-T4.P5`


## Thesis-appendix projection


The compact Appendix 1 projection contains **18** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `LIM-C06-BACKEND` | `OUT_OF_SCOPE` | Only pinned portable-C implementation checked. | No assembly/native-backend equivalence claim. |


## Assurance-layer and literature relationship

This comparison prevents repository-relative distinctness from being rewritten as global mathematical novelty. The rows below are interpretive context; implementation support still comes from the source-bound evidence for this case.

| Source/project | Relationship | Overlap | Important difference | Permitted conclusion |
|---|---|---|---|---|

| NIST FIPS 203 (2024a) | `NORMATIVE_GROUNDING` | Grounds ML-KEM operations, domains and data formats relevant to the case. | FIPS 203 is not a proof that this C implementation or generated harness is correct. | The case is specification-grounded where applicable; implementation support comes from the recorded source-bound CBMC evidence, not from the standard alone. |

| PQ Code Package / mlkem-native assurance documentation (n.d.-a; n.d.-b) | `NATIVE_ASSURANCE_CONTEXT` | Shares the exact production repository and some target contracts/harness infrastructure. | Native artefacts support different or narrower property sets and different assurance layers; the case-specific distinction is recorded in matrix 04. | Report repository-relative generated artefact/property contribution, not absence of all prior assurance. |

| Formosa Crypto and Almeida et al. (2023; 2024; 2025) | `RELATED_PROOF_ORIENTED_ASSURANCE` | Covers ML-KEM/Kyber functional and representation reasoning in proof-oriented settings. | Different implementation language/source, specifications, proof infrastructure and assurance boundary from local CBMC checks over mlkem-native C. | Use as assurance-layer comparison; do not claim the first formal proof of the underlying mathematics or operation. |

| HOL Light / s2n-bignum and documented mlkem-native low-level proofs | `RELATED_LOW_LEVEL_ASSURANCE` | May cover arithmetic or conversion behaviour for optimized low-level implementations. | The thesis analyses pinned portable-C functions and locally selected CBMC properties; backend equivalence was not generally established. | The results are complementary, not a replacement for or superiority claim over low-level proofs. |

| HACL* and EverCrypt (Zinzindohoué et al., 2017; Protzenko et al., 2020) | `RELATED_VERIFIED_CRYPTOGRAPHIC_IMPLEMENTATION_CONTEXT` | Demonstrates verified functional/memory/representation artefacts in other cryptographic codebases. | Different implementations, languages, specifications and trusted toolchains. | Use only as broader high-assurance context, not an exact prior-art match. |


## Publication-state and traceability-field note

The record blocks below preserve the frozen RC2 public-path fields only as explicitly labelled historical provenance. Their former `PENDING`, `UNRESOLVED_UNTIL_FINALIZER`, blank public-SHA and candidate-count values describe the pre-finalization snapshot; they do **not** describe the current repository. The current authoritative ledger records all 257 substantive records as `RESOLVED_HASH_MATCH` and supplies the exact current public path and SHA-256. To avoid creating a second mutable authority, this catalogue points each record back to its current ledger row instead of copying those current path/hash strings into prose.

Scientific outcome status is independent. Supported, negative, abstraction-limited, resource-limited, diagnostic, construction and preservation classifications are reproduced unchanged.

# Complete record-by-record catalogue


## PR-C06-001 — Exact scalar D4 compression refinement


### Formal statement

$$
\mathrm{Comp}_4(A)_k=C_4(A_k)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact scalar D4 compression refinement** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T1 final compressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected compressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T1 final compressor harness`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 compression matches the independent scalar/packing specification.

**What this record does not establish:** No assembly/native-backend equivalence.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 1, “Per-coordinate compressor refinement”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-001`

- **Historical identifier:** `D4-T1.P1`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Compression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** compressed nibble equals independent D4 compressor oracle for each canonical coefficient

- **Assertion / harness mapping:** D4 T1 final compressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected compressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 compression matches the independent scalar/packing specification.

- **Explicit exclusion:** No assembly/native-backend equivalence.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 1, “Per-coordinate compressor refinement”.


</details>

---

## PR-C06-002 — Exact two-nibble byte packing


### Formal statement

$$
B_i=C_4(A_{2i})\,|\,\left(C_4(A_{2i+1})\ll4\right)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact two-nibble byte packing** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T1 final compressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected compressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T1 final compressor harness`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 compression matches the independent scalar/packing specification.

**What this record does not establish:** No assembly/native-backend equivalence.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 2, “Exact packed-byte compressor layout”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-002`

- **Historical identifier:** `D4-T1.P2`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Compression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** byte[i] = low_nibble(c[2i]) | (high_nibble(c[2i+1]) << 4)

- **Assertion / harness mapping:** D4 T1 final compressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected compressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 compression matches the independent scalar/packing specification.

- **Explicit exclusion:** No assembly/native-backend equivalence.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 2, “Exact packed-byte compressor layout”.


</details>

---

## PR-C06-003 — Complete output overwrite


### Formal statement

$$
\mathrm{Comp}_4(A)=F(A)\qquad\text{for a function }F\text{ independent of the destination pre-state}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Complete output overwrite** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T1 final compressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected compressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T1 final compressor harness`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 compression matches the independent scalar/packing specification.

**What this record does not establish:** No assembly/native-backend equivalence.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 3, “Complete compressor overwrite”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-003`

- **Historical identifier:** `D4-T1.P3`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Compression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** all 128 output bytes are determined by the 256 canonical inputs

- **Assertion / harness mapping:** D4 T1 final compressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected compressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 compression matches the independent scalar/packing specification.

- **Explicit exclusion:** No assembly/native-backend equivalence.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 3, “Complete compressor overwrite”.


</details>

---

## PR-C06-004 — Compressor coordinate locality


### Formal statement

$$
A_k=B_k\Longrightarrow \mathrm{Comp}_4(A)_k=\mathrm{Comp}_4(B)_k
$$


### What the property/control means

The property checks the structural or multi-execution law **Compressor coordinate locality**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T1 final compressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected compressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T1 final compressor harness`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 compression matches the independent scalar/packing specification.

**What this record does not establish:** No assembly/native-backend equivalence.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 4, “Compressor coordinate locality”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-004`

- **Historical identifier:** `D4-T1.P4`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Compression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** each output nibble depends only on its corresponding coefficient

- **Assertion / harness mapping:** D4 T1 final compressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected compressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 compression matches the independent scalar/packing specification.

- **Explicit exclusion:** No assembly/native-backend equivalence.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 4, “Compressor coordinate locality”.


</details>

---

## PR-C06-005 — Exact D4 decompression refinement


### Formal statement

$$
\mathrm{Decomp}_4(B)_k=D_4(t_k)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact D4 decompression refinement** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T2 final decompressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected decompressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T2 final decompressor harness`. The admitted domain is: Arbitrary 128-byte compressed input. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

**What this record does not establish:** No claim for other d values or backends.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 5, “Per-coordinate decompressor refinement”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-005`

- **Historical identifier:** `D4-T2.P1`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Decompression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 128-byte compressed input

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** each output coefficient equals independent D4 decompressor oracle of its 4-bit symbol

- **Assertion / harness mapping:** D4 T2 final decompressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected decompressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

- **Explicit exclusion:** No claim for other d values or backends.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 5, “Per-coordinate decompressor refinement”.


</details>

---

## PR-C06-006 — Low-nibble extraction


### Formal statement

$$
\mathrm{Decomp}_4(B)_{2i}=D_4(B_i\mathbin{\&}15)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Low-nibble extraction** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T2 final decompressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected decompressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T2 final decompressor harness`. The admitted domain is: Arbitrary 128-byte compressed input. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

**What this record does not establish:** No claim for other d values or backends.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 6, “Low-nibble routing”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-006`

- **Historical identifier:** `D4-T2.P2`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Decompression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 128-byte compressed input

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** even output coefficient is decoded from byte low nibble

- **Assertion / harness mapping:** D4 T2 final decompressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected decompressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

- **Explicit exclusion:** No claim for other d values or backends.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 6, “Low-nibble routing”.


</details>

---

## PR-C06-007 — High-nibble extraction


### Formal statement

$$
\mathrm{Decomp}_4(B)_{2i+1}=D_4(B_i\gg4)
$$


### What the property/control means

The property gives a direct semantic characterisation of **High-nibble extraction** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T2 final decompressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected decompressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T2 final decompressor harness`. The admitted domain is: Arbitrary 128-byte compressed input. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

**What this record does not establish:** No claim for other d values or backends.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 7, “High-nibble routing”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-007`

- **Historical identifier:** `D4-T2.P3`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Decompression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 128-byte compressed input

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** odd output coefficient is decoded from byte high nibble

- **Assertion / harness mapping:** D4 T2 final decompressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected decompressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

- **Explicit exclusion:** No claim for other d values or backends.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 7, “High-nibble routing”.


</details>

---

## PR-C06-008 — Exact 16-value output image


### Formal statement

$$
\begin{aligned}
&\text{every decompressed coefficient lies in the D4 codebook}
\end{aligned}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact 16-value output image** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T2 final decompressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected decompressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T2 final decompressor harness`. The admitted domain is: Arbitrary 128-byte compressed input. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

**What this record does not establish:** No claim for other d values or backends.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 8, “Decompressor image restriction”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-008`

- **Historical identifier:** `D4-T2.P4`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Decompression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 128-byte compressed input

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** every decompressed coefficient lies in the D4 codebook

- **Assertion / harness mapping:** D4 T2 final decompressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected decompressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

- **Explicit exclusion:** No claim for other d values or backends.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** verbatim structural/logical relation rendered without inventing an equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 8, “Decompressor image restriction”.


</details>

---

## PR-C06-009 — Decompressor overwrite independence


### Formal statement

$$
\mathrm{Decomp}_4(B)=G(B)\qquad\text{independent of the destination pre-state}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Decompressor overwrite independence** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T2 final decompressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected decompressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T2 final decompressor harness`. The admitted domain is: Arbitrary 128-byte compressed input. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

**What this record does not establish:** No claim for other d values or backends.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 9, “Complete decompressor overwrite”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-009`

- **Historical identifier:** `D4-T2.P5`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Decompression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 128-byte compressed input

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** output is fully determined by input bytes, independent of prior destination contents

- **Assertion / harness mapping:** D4 T2 final decompressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected decompressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

- **Explicit exclusion:** No claim for other d values or backends.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 9, “Complete decompressor overwrite”.


</details>

---

## PR-C06-010 — Decompressor byte locality


### Formal statement

$$
B_i=B_i\!{}^{\prime}\Longrightarrow (\mathrm{Decomp}_4(B)_{2i},\mathrm{Decomp}_4(B)_{2i+1})=(\mathrm{Decomp}_4(B^{\prime})_{2i},\mathrm{Decomp}_4(B^{\prime})_{2i+1})
$$


### What the property/control means

The property checks the structural or multi-execution law **Decompressor byte locality**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T2 final decompressor harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected decompressor mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T2 final decompressor harness`. The admitted domain is: Arbitrary 128-byte compressed input. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

**What this record does not establish:** No claim for other d values or backends.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 10, “Decompressor byte locality”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-010`

- **Historical identifier:** `D4-T2.P6`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Decompression refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 128-byte compressed input

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** each output pair depends only on the corresponding input byte

- **Assertion / harness mapping:** D4 T2 final decompressor harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected decompressor mutants rejected

- **Strongest bounded conclusion:** Pinned portable-C D4 decompression matches the independent scalar/packing specification.

- **Explicit exclusion:** No claim for other d values or backends.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 10, “Decompressor byte locality”.


</details>

---

## PR-C06-011 — Compressed-domain retraction


### Formal statement

$$
\mathrm{Comp}_4(\mathrm{Decomp}_4(B))=B
$$


### What the property/control means

The property moves beyond the isolated target and checks **Compressed-domain retraction** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T3 composition harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected bridge mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T3 composition harness`. The admitted domain is: Arbitrary valid 128-byte compressed representation. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The compressed representation is an exact retraction domain.

**What this record does not establish:** Does not imply lossless polynomial-domain round trip.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 11, “Exact compressed-domain retraction”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-011`

- **Historical identifier:** `D4-T3.P1`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Exact codec composition`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary valid 128-byte compressed representation

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** compress(decompress(B))=B for every 128-byte B

- **Assertion / harness mapping:** D4 T3 composition harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected bridge mutants rejected

- **Strongest bounded conclusion:** The compressed representation is an exact retraction domain.

- **Explicit exclusion:** Does not imply lossless polynomial-domain round trip.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 11, “Exact compressed-domain retraction”.


</details>

---

## PR-C06-012 — Nibble preservation


### Formal statement

$$
\mathrm{nibble}_{\ell}(\mathrm{Comp}_4(\mathrm{Decomp}_4(B)))=\mathrm{nibble}_{\ell}(B),\qquad 0\le\ell<256
$$


### What the property/control means

The property checks **Nibble preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T3 composition harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected bridge mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T3 composition harness`. The admitted domain is: Arbitrary valid 128-byte compressed representation. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The compressed representation is an exact retraction domain.

**What this record does not establish:** Does not imply lossless polynomial-domain round trip.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 12, “Nibble preservation through decompression--compression”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-012`

- **Historical identifier:** `D4-T3.P2`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Exact codec composition`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary valid 128-byte compressed representation

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** both low and high 4-bit symbols are preserved by decode/re-encode

- **Assertion / harness mapping:** D4 T3 composition harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected bridge mutants rejected

- **Strongest bounded conclusion:** The compressed representation is an exact retraction domain.

- **Explicit exclusion:** Does not imply lossless polynomial-domain round trip.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-012`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 12, “Nibble preservation through decompression--compression”.


</details>

---

## PR-C06-013 — Cycle stability


### Formal statement

$$
\mathrm{Comp}_4(\mathrm{Decomp}_4(\mathrm{Comp}_4(\mathrm{Decomp}_4(B))))=\mathrm{Comp}_4(\mathrm{Decomp}_4(B))
$$


### What the property/control means

The property moves beyond the isolated target and checks **Cycle stability** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T3 composition harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected bridge mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T3 composition harness`. The admitted domain is: Arbitrary valid 128-byte compressed representation. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The compressed representation is an exact retraction domain.

**What this record does not establish:** Does not imply lossless polynomial-domain round trip.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 13, “Compressed-domain composition stability”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-013`

- **Historical identifier:** `D4-T3.P3`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Exact codec composition`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary valid 128-byte compressed representation

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** C(D(C(D(B))))=C(D(B))

- **Assertion / harness mapping:** D4 T3 composition harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected bridge mutants rejected

- **Strongest bounded conclusion:** The compressed representation is an exact retraction domain.

- **Explicit exclusion:** Does not imply lossless polynomial-domain round trip.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-013`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 13, “Compressed-domain composition stability”.


</details>

---

## PR-C06-014 — Canonical-domain quantizer projection


### Formal statement

$$
Q(A)=\mathrm{Decomp}_4(\mathrm{Comp}_4(A))\in\mathcal C_4^{256}
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Canonical-domain quantizer projection**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T4 final projection harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected error/fixed-point/locality mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T4 final projection harness`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The pinned codec realizes the registered lossy projection with sharp error 104.

**What this record does not establish:** Not lossless recovery of arbitrary canonical polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 14, “Projection-image property”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-014`

- **Historical identifier:** `D4-T4.P1`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Lossy projection`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** Q(A)=decompress(compress(A)) lies in the exact 16-value codebook coordinatewise

- **Assertion / harness mapping:** D4 T4 final projection harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected error/fixed-point/locality mutants rejected

- **Strongest bounded conclusion:** The pinned codec realizes the registered lossy projection with sharp error 104.

- **Explicit exclusion:** Not lossless recovery of arbitrary canonical polynomials.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-014`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 14, “Projection-image property”.


</details>

---

## PR-C06-015 — Sharp modular error bound


### Formal statement

$$
\forall A,i:\quad\mathop{\text{dist}}_q(A_i,Q(A)_i)\le104,\qquad\exists A,i:\quad\mathop{\text{dist}}_q(A_i,Q(A)_i)=104
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Sharp modular error bound**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T4 final projection harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected error/fixed-point/locality mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T4 final projection harness`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The pinned codec realizes the registered lossy projection with sharp error 104.

**What this record does not establish:** Not lossless recovery of arbitrary canonical polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 15, “Sharp approximation bound”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-015`

- **Historical identifier:** `D4-T4.P2`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Lossy projection`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** dist_q(A[i],Q(A)[i]) <= 104 for every canonical coefficient; 104 is attainable

- **Assertion / harness mapping:** D4 T4 final projection harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected error/fixed-point/locality mutants rejected

- **Strongest bounded conclusion:** The pinned codec realizes the registered lossy projection with sharp error 104.

- **Explicit exclusion:** Not lossless recovery of arbitrary canonical polynomials.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-015`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 15, “Sharp approximation bound”.


</details>

---

## PR-C06-016 — Fixed-point characterization


### Formal statement

$$
Q(A)=A\Longleftrightarrow\forall i:\;A_i\in\mathcal C_4
$$


### What the property/control means

The property checks the structural or multi-execution law **Fixed-point characterization**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T4 final projection harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected error/fixed-point/locality mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T4 final projection harness`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The pinned codec realizes the registered lossy projection with sharp error 104.

**What this record does not establish:** Not lossless recovery of arbitrary canonical polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 16, “Projection fixed-point characterisation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-016`

- **Historical identifier:** `D4-T4.P3`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Lossy projection`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** Q(A)=A iff every coefficient is in the D4 codebook

- **Assertion / harness mapping:** D4 T4 final projection harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected error/fixed-point/locality mutants rejected

- **Strongest bounded conclusion:** The pinned codec realizes the registered lossy projection with sharp error 104.

- **Explicit exclusion:** Not lossless recovery of arbitrary canonical polynomials.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-016`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 16, “Projection fixed-point characterisation”.


</details>

---

## PR-C06-017 — Projection idempotence


### Formal statement

$$
\mathrm{Proj}_4(\mathrm{Proj}_4(A))=\mathrm{Proj}_4(A)
$$


### What the property/control means

The property checks the structural or multi-execution law **Projection idempotence**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T4 final projection harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected error/fixed-point/locality mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T4 final projection harness`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The pinned codec realizes the registered lossy projection with sharp error 104.

**What this record does not establish:** Not lossless recovery of arbitrary canonical polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 17, “Projection idempotence”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-017`

- **Historical identifier:** `D4-T4.P4`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Lossy projection`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** Q(Q(A))=Q(A)

- **Assertion / harness mapping:** D4 T4 final projection harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected error/fixed-point/locality mutants rejected

- **Strongest bounded conclusion:** The pinned codec realizes the registered lossy projection with sharp error 104.

- **Explicit exclusion:** Not lossless recovery of arbitrary canonical polynomials.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-017`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 17, “Projection idempotence”.


</details>

---

## PR-C06-018 — Projection coordinate locality


### Formal statement

$$
A_k=B_k\Longrightarrow \mathrm{Proj}_4(A)_k=\mathrm{Proj}_4(B)_k
$$


### What the property/control means

The property checks the structural or multi-execution law **Projection coordinate locality**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `D4 T4 final projection harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected error/fixed-point/locality mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `D4 T4 final projection harness`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The pinned codec realizes the registered lossy projection with sharp error 104.

**What this record does not establish:** Not lossless recovery of arbitrary canonical polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native D4 proof directories/contracts and wider repository/backend assurance. The campaign addition is characterised at case level as: Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 6: D4 Compression and Decompression → item 18, “Projection coordinate locality”. Chapter 4 uses the case-level principal synthesis in Section 4.4.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C06-018`

- **Historical identifier:** `D4-T4.P5`

- **Case identifier:** `6`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`

- **Property class:** `Lossy projection`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** agreement at coefficient k implies agreement of projected outputs at k

- **Assertion / harness mapping:** D4 T4 final projection harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected error/fixed-point/locality mutants rejected

- **Strongest bounded conclusion:** The pinned codec realizes the registered lossy projection with sharp error 104.

- **Explicit exclusion:** Not lossless recovery of arbitrary canonical polynomials.

- **Evidence locator:** `LOC-C06-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLKEM_D4_CBMC_T1_T4_COMPLETE_RESEARCH_RECORD.md

- **Archive entry SHA-256:** `6f7cad3735fe50a68b848b55b632c40d3450b9daa1526f6b044224c6a3d74ec5`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C06-018`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 6: D4 Compression and Decompression → item 18, “Projection coordinate locality”.


</details>

---


# Case-level bounded conclusion

`Comp4(Decomp4(B))=B` for every compressed byte array `B`; `Proj4(A)=Decomp4(Comp4(A))` is a coordinatewise projection onto the 16-value codebook with `dist_q(A_i,Proj4(A)_i)<=104`, and 104 is attainable.

**Explicit exclusion.** No assembly/native-backend equivalence.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
