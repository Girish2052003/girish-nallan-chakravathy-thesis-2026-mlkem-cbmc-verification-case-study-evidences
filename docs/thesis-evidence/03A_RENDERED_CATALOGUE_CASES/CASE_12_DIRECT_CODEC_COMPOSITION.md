# Case 12 — Direct Codec Composition

**Target:** `mlk_poly_tobytes ↔ mlk_poly_frombytes`
**Evidence locator:** `LOC-C12-UA`
**Chapter 4 projection:** Section 4.5.4
**Ledger records:** 2
**Formally supported subset:** 2

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

Are the two unchanged production wrappers directly compatible when composed on the domains where an exact round trip is semantically justified?

## Case notation and opening equations


$$
\operatorname{ToBytes}\text{ and }\operatorname{FromBytes}\text{ denote the two production transformations}
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
\operatorname{FromBytes}(\operatorname{ToBytes}(P))=P\quad(P\text{ canonical})
$$


$$
\operatorname{ToBytes}(\operatorname{FromBytes}(B))=B\quad(B\in\operatorname{im}(\operatorname{ToBytes}))
$$


**Recorded principal-claim wording:** frombytes(tobytes(p))=p for canonical p; tobytes(frombytes(b))=b for b in the canonical encoder image.


### Why this claim is the principal case-level synthesis

The direct two-function compositions are themselves the verification object. They were selected because separate serializer and decoder results do not automatically establish domain compatibility. The canonical-image restriction on the byte-originating direction is part of the principal claim, not an incidental caveat.


The survival ledger assigns this synthesis to **4.5.4** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768`. Its primary verification focus was: Direct cross-function composition obligations linking the production serializer and deserializer on their valid/canonical domains. The additional or mixed evidence was: Two direct composition obligations, two controls and two bridge mutants are reported; this is cross-function validation, not a new independent production function.


The retained case matrix records CBMC execution as **YES — PBCODEC-CV1 accepted**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** Within the recorded canonical/valid encoding domains, the two pinned production functions satisfy the selected direct composition relations.


**Integrity boundary:** The relation is directional/domain-qualified because noncanonical 12-bit byte segments are not one-to-one after normalization.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/PBCODEC_CV1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md` with entry SHA-256 `9472be19e41dc9fbaeffdf91dbbbafe5b4665ccf80cb077f3efdf99872190d96`. The case archive is `thesis_batch_2.zip` with SHA-256 `f8b48618fd64e068129684af69d28036b2d7af25fb99eb2c53a88b9a0f464ff9`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **40** indexed records for `LOC-C12-UA`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native serializer and deserializer are verified separately; no equivalent direct two-wrapper semantic composition was identified in the inspected tree.


**Necessary overlap.** Same two production wrappers and representation format.


**What this campaign added.** Direct canonical-polynomial and canonical-image byte composition obligations with bridge controls.


**Why the suite is substantively distinct within the inspected corpus.** Compatibility of the two real functions and domains is checked as a separate cross-function relation.


**Comparison material inspected.** Native tobytes/frombytes proof directories and PBCODEC post-freeze audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** SEPARATE_NATIVE_HARNESSES_PRESENT_NO_DIRECT_CODEC_DIRECTORY

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tobytes/poly_tobytes_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_tobytes/Makefile;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_frombytes/poly_frombytes_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_frombytes/Makefile

- **Native proof entry SHA-256:** 23f8b50d4fce28432d0cd2121697477ace3382bc43e87ddffc5f8fd0110b1174;8246ad0449b785689b32860b55b232830e42435aca8447d7b87c6c01ff4322da;e467153a7c219afa6bc9a1d3c96277ee06531464e330bcdb3b3f834c6ca84dec;3601f238829f584219de93a05fb899aa9dce088340c3c3b2ee182a3148af28e3

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.h

- **Production source entry SHA-256:** 9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad;0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

- **Authoritative baseline characterisation:** Native serializer and deserializer harnesses exist separately; no direct two-wrapper PBCODEC-CV1 directory was identified.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `COMPOSITION_AND_CALLER_SUPPORT` | `PR-C12-001`, `PR-C12-002` | connects the local relation to callers, sequential operations, cross-function composition or parameter replication |


**Survival-ledger supporting historical IDs:** `PBCODEC-CV1.P1`, `PBCODEC-CV1.P2`


## Thesis-appendix projection


The compact Appendix 1 projection contains **2** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


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


## PR-C12-001 — Canonical polynomial round trip


### Formal statement

$$
\mathrm{FromBytes}(\mathrm{ToBytes}(P))=P
$$


### What the property/control means

The property moves beyond the isolated target and checks **Canonical polynomial round trip** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBCODEC direct real-wrapper composition assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Bridge mutant rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBCODEC direct real-wrapper composition assertion`. The admitted domain is: Canonical polynomial coefficients 0..3328. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Direct production serialization then deserialization preserves canonical polynomials.

**What this record does not establish:** Not a universal relation for non-canonical polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native serializer and deserializer are verified separately; no equivalent direct two-wrapper semantic composition was identified in the inspected tree. The campaign addition is characterised at case level as: Direct canonical-polynomial and canonical-image byte composition obligations with bridge controls. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 12: Direct Codec Composition → item 1, “Canonical polynomial round trip”. Chapter 4 uses the case-level principal synthesis in Section 4.5.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C12-001`

- **Historical identifier:** `PBCODEC-CV1.P1`

- **Case identifier:** `12`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes <-> mlk_poly_frombytes (PBCODEC-CV1)`

- **Property class:** `Direct cross-function composition`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical polynomial coefficients 0..3328

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** frombytes(tobytes(p))=p

- **Assertion / harness mapping:** PBCODEC direct real-wrapper composition assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Bridge mutant rejected

- **Strongest bounded conclusion:** Direct production serialization then deserialization preserves canonical polynomials.

- **Explicit exclusion:** Not a universal relation for non-canonical polynomials.

- **Evidence locator:** `LOC-C12-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PBCODEC_CV1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PBCODEC_CV1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `9472be19e41dc9fbaeffdf91dbbbafe5b4665ccf80cb077f3efdf99872190d96`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/PBCODEC_CV1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Public evidence SHA-256:** 9472be19e41dc9fbaeffdf91dbbbafe5b4665ccf80cb077f3efdf99872190d96

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 12: Direct Codec Composition → item 1, “Canonical polynomial round trip”.


</details>

---

## PR-C12-002 — Canonical-image byte round trip


### Formal statement

$$
\mathrm{ToBytes}(\mathrm{FromBytes}(B))=B
$$


### What the property/control means

The property moves beyond the isolated target and checks **Canonical-image byte round trip** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PBCODEC direct real-wrapper composition assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Bridge mutant rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PBCODEC direct real-wrapper composition assertion`. The admitted domain is: Byte arrays in the canonical encoder image. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Direct production deserialization then serialization preserves canonical-image byte arrays.

**What this record does not establish:** Not a bijection over arbitrary 384-byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native serializer and deserializer are verified separately; no equivalent direct two-wrapper semantic composition was identified in the inspected tree. The campaign addition is characterised at case level as: Direct canonical-polynomial and canonical-image byte composition obligations with bridge controls. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 12: Direct Codec Composition → item 2, “Encoded-image byte round trip”. Chapter 4 uses the case-level principal synthesis in Section 4.5.4; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C12-002`

- **Historical identifier:** `PBCODEC-CV1.P2`

- **Case identifier:** `12`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_tobytes <-> mlk_poly_frombytes (PBCODEC-CV1)`

- **Property class:** `Direct cross-function composition`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Byte arrays in the canonical encoder image

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** tobytes(frombytes(b))=b

- **Assertion / harness mapping:** PBCODEC direct real-wrapper composition assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Bridge mutant rejected

- **Strongest bounded conclusion:** Direct production deserialization then serialization preserves canonical-image byte arrays.

- **Explicit exclusion:** Not a bijection over arbitrary 384-byte strings.

- **Evidence locator:** `LOC-C12-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PBCODEC_CV1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PBCODEC_CV1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Archive entry SHA-256:** `9472be19e41dc9fbaeffdf91dbbbafe5b4665ccf80cb077f3efdf99872190d96`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** reports/PBCODEC_CV1_COMPLETE_A_TO_Z_TECHNICAL_RECORD.md

- **Public evidence SHA-256:** 9472be19e41dc9fbaeffdf91dbbbafe5b4665ccf80cb077f3efdf99872190d96

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 12: Direct Codec Composition → item 2, “Encoded-image byte round trip”.


</details>

---


# Case-level bounded conclusion

frombytes(tobytes(p))=p for canonical p; tobytes(frombytes(b))=b for b in the canonical encoder image.

**Explicit exclusion.** Not a universal relation for non-canonical polynomials.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
