# Case 11 — Polynomial Deserialisation

**Target:** `mlk_poly_frombytes`
**Evidence locator:** `LOC-C11-UA`
**Chapter 4 projection:** Section 4.5.3
**Ledger records:** 11
**Formally supported subset:** 11

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

What does the production decoder actually compute from each three-byte block, including non-canonical 12-bit values, and which routing, locality and inversion relations follow from that raw representation?

## Case notation and opening equations


$$
(b_0,b_1,b_2)\text{ is one input block}
$$


$$
W=b_0+2^8b_1+2^{16}b_2
$$


$$
D=\mathop{\text{FromBytes}}
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
D(B)_{2i}=W\bmod2^{12},\qquad D(B)_{2i+1}=\left\lfloor\frac{W}{2^{12}}\right\rfloor
$$


$$
0\le D(B)_j\le4095
$$


**Recorded principal-claim wording:** Each 3-byte word W_i is decoded to (W_i mod 4096, floor(W_i/4096)); the relation is raw 12-bit unpacking, not modulo-q canonicalization.


### Why this claim is the principal case-level synthesis

The raw 12-bit decoding equation is selected precisely because the production routine does not canonicalise arbitrary segments modulo q. Routing, locality, XOR and inversion properties characterise that raw decoder more completely; they are subordinate to, and constrained by, the same representation boundary.


The survival ledger assigns this synthesis to **4.5.3** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768`. Its primary verification focus was: Exact raw 12-bit decode; bit-routing, byte/coefficient locality and differential relations; inversion on the encoded domain. The additional or mixed evidence was: Four families and 11 accepted obligations are reported; the campaign explicitly does not prove FIPS ByteDecode12 modulo-q normalization for arbitrary noncanonical segments.


The retained case matrix records CBMC execution as **YES — campaign sealed**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** The pinned production deserializer performs the recorded raw 12-bit unpacking and selected routing/locality/inversion relations; canonical modulo-q normalization of arbitrary byte strings is outside this result.


**Integrity boundary:** The exact theorem is raw 12-bit unpacking; it must not be rewritten as general canonical modulo-q decoding.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md` with entry SHA-256 `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`. The case archive is `thesis_batch_2.zip` with SHA-256 `f8b48618fd64e068129684af69d28036b2d7af25fb99eb2c53a88b9a0f464ff9`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **32** indexed records for `LOC-C11-UA`: COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native frombytes contract/range/safety artefacts.


**Necessary overlap.** Same 3-byte/2-coefficient routing and production call.


**What this campaign added.** Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties.


**Why the suite is substantively distinct within the inspected corpus.** The generated suite precisely characterizes raw 12-bit semantics and relational routing, while refusing an unimplemented canonicalization claim.


**Comparison material inspected.** Native frombytes proof directory/source contract and PFB audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESSES_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_frombytes/poly_frombytes_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_frombytes/Makefile;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_frombytes_c/poly_frombytes_c_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_frombytes_c/Makefile

- **Native proof entry SHA-256:** e467153a7c219afa6bc9a1d3c96277ee06531464e330bcdb3b3f834c6ca84dec;3601f238829f584219de93a05fb899aa9dce088340c3c3b2ee182a3148af28e3;b340a67f20c4b12770dfbf0d440dac30401c54b92e4a7718c2bf557afe76f154;65f98fe017981b612b3cc5b9d2e4b811da1032f7cec10218816a34fc380c650a

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.h

- **Production source entry SHA-256:** 9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad;0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

- **Authoritative baseline characterisation:** Native wrapper and portable-C one-call harnesses exist.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DIRECT_SEMANTIC_SUPPORT` | `PR-C11-001`, `PR-C11-002`, `PR-C11-003`, `PR-C11-004`, `PR-C11-005`, `PR-C11-006`, `PR-C11-008`, `PR-C11-009`, `PR-C11-010`, `PR-C11-011` | states the core value/representation relation |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-C11-007` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `PFB-T1.P1`, `PFB-T1.P2`, `PFB-T2.P1`, `PFB-T2.P2`, `PFB-T2.P3`, `PFB-T2.P4`, `PFB-T2.P5`, `PFB-T3.P1`, `PFB-T3.P2`, `PFB-T4.P1`, `PFB-T4.P2`


## Thesis-appendix projection


The compact Appendix 1 projection contains **11** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `LIM-C11-CANON` | `NOT_CLAIMED` | Production relation is raw 12-bit unpacking. | Explicitly exclude general canonical decoding claim. |


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


## PR-C11-001 — Raw even 12-bit extraction


### Formal statement

$$
D(B)_{2i}=W\bmod 2^{12}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Raw even 12-bit extraction** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 1, “Even decoded coefficient”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-001`

- **Historical identifier:** `PFB-T1.P1`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** out[2i]=W_i mod 4096

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 1, “Even decoded coefficient”.


</details>

---

## PR-C11-002 — Raw odd 12-bit extraction


### Formal statement

$$
D(B)_{2i+1}=\left\lfloor\frac{W}{2^{12}}\right\rfloor
$$


### What the property/control means

The property gives a direct semantic characterisation of **Raw odd 12-bit extraction** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 2, “Odd decoded coefficient”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-002`

- **Historical identifier:** `PFB-T1.P2`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** out[2i+1]=floor(W_i/4096)

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 2, “Odd decoded coefficient”.


</details>

---

## PR-C11-003 — First-byte routing


### Formal statement

$$
b_{3i}\longrightarrow \text{low eight bits of }D(B)_{2i}\quad\text{only}
$$


### What the property/control means

The property gives a direct semantic characterisation of **First-byte routing** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 3, “First-byte routing”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-003`

- **Historical identifier:** `PFB-T2.P1`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** first byte affects only registered low bits of even coefficient

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 3, “First-byte routing”.


</details>

---

## PR-C11-004 — Second-byte low-nibble routing


### Formal statement

$$
(b_{3i+1}\mathbin{\&}15)\longrightarrow \text{high four bits of }D(B)_{2i}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Second-byte low-nibble routing** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 4, “Second-byte low-nibble routing”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-004`

- **Historical identifier:** `PFB-T2.P2`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** second-byte low nibble routes to high bits of even coefficient

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 4, “Second-byte low-nibble routing”.


</details>

---

## PR-C11-005 — Second-byte high-nibble routing


### Formal statement

$$
(b_{3i+1}\gg4)\longrightarrow \text{low four bits of }D(B)_{2i+1}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Second-byte high-nibble routing** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 5, “Second-byte high-nibble routing”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-005`

- **Historical identifier:** `PFB-T2.P3`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** second-byte high nibble routes to low bits of odd coefficient

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 5, “Second-byte high-nibble routing”.


</details>

---

## PR-C11-006 — Third-byte routing


### Formal statement

$$
D(B)_{2i+1}=(b_1\gg4)+16b_2
$$


### What the property/control means

The property gives a direct semantic characterisation of **Third-byte routing** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 6, “Third-byte routing”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-006`

- **Historical identifier:** `PFB-T2.P4`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** third byte routes to high bits of odd coefficient

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 6, “Third-byte routing”.


</details>

---

## PR-C11-007 — Arbitrary one-block locality


### Formal statement

$$
B\equiv B^{\prime}\text{ outside block }i\Longrightarrow D(B)\equiv D(B^{\prime})\text{ outside coefficient pair }(2i,2i+1)
$$


### What the property/control means

The property checks the structural or multi-execution law **Arbitrary one-block locality**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 7, “Three-byte-block locality”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-007`

- **Historical identifier:** `PFB-T2.P5`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** changing one 3-byte block affects only its decoded coefficient pair

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 7, “Three-byte-block locality”.


</details>

---

## PR-C11-008 — Packed-output XOR conservation


### Formal statement

$$
\bigoplus_i\mathop{\text{Pack}}_{24}(D(B)_{2i},D(B)_{2i+1})=\bigoplus_i W_i
$$


### What the property/control means

The property gives a direct semantic characterisation of **Packed-output XOR conservation** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 8, “Packed-word XOR conservation”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-008`

- **Historical identifier:** `PFB-T3.P1`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** packed XOR of decoded pairs equals XOR of corresponding 24-bit input blocks

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 8, “Packed-word XOR conservation”.


</details>

---

## PR-C11-009 — Block/pair difference equivalence


### Formal statement

$$
B_{3i:3i+3}\ne B^{\prime}_{3i:3i+3}\Longleftrightarrow\bigl(D(B)_{2i},D(B)_{2i+1}\bigr)\ne\bigl(D(B^{\prime})_{2i},D(B^{\prime})_{2i+1}\bigr)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Block/pair difference equivalence** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 9, “Block-difference equivalence”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-009`

- **Historical identifier:** `PFB-T3.P2`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** input 3-byte blocks differ iff decoded coefficient pairs differ

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 9, “Block-difference equivalence”.


</details>

---

## PR-C11-010 — Arbitrary-byte raw re-encoding identity


### Formal statement

$$
\forall B\in\{0,\ldots,255\}^{384}:\quad E_{\mathrm{raw}}(D(B))=B
$$


### What the property/control means

The property gives a direct semantic characterisation of **Arbitrary-byte raw re-encoding identity** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 10, “Raw-byte left inverse”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-010`

- **Historical identifier:** `PFB-T4.P1`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** E_raw(D(b))=b for every 384-byte b

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 10, “Raw-byte left inverse”.


</details>

---

## PR-C11-011 — Raw-polynomial decoding identity


### Formal statement

$$
\forall P\in[0,4095]^{256}:\quad D(E_{\mathrm{raw}}(P))=P
$$


### What the property/control means

The property gives a direct semantic characterisation of **Raw-polynomial decoding identity** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PFB T1–T4 final harness assertion`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected routing/inversion mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PFB T1–T4 final harness assertion`. The admitted domain is: Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named raw 12-bit unpacking or inversion relation is supported.

**What this record does not establish:** Not general modulo-q canonicalization of arbitrary byte strings.


### Native-baseline relationship

The frozen native baseline for this case is: Native frombytes contract/range/safety artefacts. The campaign addition is characterised at case level as: Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 11, “Raw $12$-bit right inverse”. Chapter 4 uses the case-level principal synthesis in Section 4.5.3; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C11-011`

- **Historical identifier:** `PFB-T4.P2`

- **Case identifier:** `11`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frombytes`

- **Property class:** `Raw deserialization/representation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 384-byte input, or raw 12-bit coefficient domain 0..4095 for reverse direction

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** D(E_raw(p))=p for every coefficient array with values 0..4095

- **Assertion / harness mapping:** PFB T1–T4 final harness assertion

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected routing/inversion mutants killed

- **Strongest bounded conclusion:** The named raw 12-bit unpacking or inversion relation is supported.

- **Explicit exclusion:** Not general modulo-q canonicalization of arbitrary byte strings.

- **Evidence locator:** `LOC-C11-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/PFB_MLK_POLY_FROMBYTES_COMPLETE_A_TO_Z_REPORT.md

- **Archive entry SHA-256:** `b9da14869c7b7ad44a4e252d505adc5303b55e047c6d6e16989cddd083292619`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C11-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 11: Polynomial Deserialisation: mlk_poly_frombytes → item 11, “Raw $12$-bit right inverse”.


</details>

---


# Case-level bounded conclusion

Each 3-byte word W_i is decoded to (W_i mod 4096, floor(W_i/4096)); the relation is raw 12-bit unpacking, not modulo-q canonicalization.

**Explicit exclusion.** Not general modulo-q canonicalization of arbitrary byte strings.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
