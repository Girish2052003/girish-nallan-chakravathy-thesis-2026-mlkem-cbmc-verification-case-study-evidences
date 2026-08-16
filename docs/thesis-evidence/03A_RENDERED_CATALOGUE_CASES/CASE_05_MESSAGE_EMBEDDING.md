# Case 5 — Message Embedding

**Target:** `mlk_poly_frommsg`
**Evidence locator:** `LOC-C05-UA`
**Chapter 4 projection:** Section 4.4.2
**Ledger records:** 13
**Formally supported subset:** 13

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

Does the unchanged production routine embed every message bit into the intended two-value polynomial codebook, and does that codebook support the correct message-originating reverse composition and metric relations?

## Case notation and opening equations


$$
h=\frac{q+1}{2}=1665
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
\mathop{\text{FromMsg}}(m)_k=1665\,\mathop{\text{bit}}(m,k)
$$


$$
\mathop{\text{ToMsg}}(\mathop{\text{FromMsg}}(m))=m
$$


**Recorded principal-claim wording:** $`\mathrm{frommsg}(m)_k=1665\,\mathrm{bit}_k(m)`$, and $`\mathrm{tomsg}(\mathrm{frommsg}(m))=m`$ for every 32-byte message m.


### Why this claim is the principal case-level synthesis

The exact bit-to-codeword map and message-originating round trip are the central semantic statements. Toggle, support, popcount and distance relations explain the structure induced by that map and provide relational strengthening; they do not expand the domain to arbitrary polynomial-originating inputs.


The survival ledger assigns this synthesis to **4.4.2** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `af4c5abdd5958bdc65a03cd5ee86708264f93304` under `ML-KEM-768`. Its primary verification focus was: Exact 32-byte-message-to-polynomial embedding; coefficient locality and relational behaviour; tomsg(frommsg(m)) identity; support/weight and distance correspondence. The additional or mixed evidence was: The proof concerns message-originating coefficients 0 or 1665 and does not establish a polynomial-originating identity for arbitrary coefficients.


The retained case matrix records CBMC execution as **YES — T1–T4 closed as authoritative pass**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** For every symbolic 32-byte message, the pinned production function writes the exact 0/1665 coefficient embedding and satisfies the selected relational and message-originating round-trip properties.


**Integrity boundary:** The raw archive contains extensive tool/build material; entry count is not a run count.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md` with entry SHA-256 `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`. The case archive is `thesis_batch_2.zip` with SHA-256 `f8b48618fd64e068129684af69d28036b2d7af25fb99eb2c53a88b9a0f464ff9`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **40** indexed records for `LOC-C05-UA`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native `poly_frommsg` source contract/loop annotations and call harness.


**Necessary overlap.** Target call, 0/1665 codebook and fixed message/polynomial sizes.


**What this campaign added.** Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws.


**Why the suite is substantively distinct within the inspected corpus.** The generated suite adds exact full-output, relational, composition and metric claims.


**Comparison material inspected.** `proofs/cbmc/poly_frommsg/`, production source/contracts, FROMMSG audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESS_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_frommsg/poly_frommsg_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/poly_frommsg/Makefile

- **Native proof entry SHA-256:** 60c5e7a0ce1320dacc016a369f924f7de5caf5bcd071d9eed1aadffaa4ee7923;64dae10011cfde69469954bf21a5c42f80b012e393d93ddde7a4ea27168126fd

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/compress.h

- **Production source entry SHA-256:** 9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad;0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

- **Authoritative baseline characterisation:** A dedicated native `poly_frommsg` one-call harness exists; the exact generated T1–T4 suite remains distinct.

- **Conflict resolution:** RETAINED_FROMMSG_NO_MATCHING_HARNESS_WORDING_QUALIFIED_NATIVE_ONE_CALL_HARNESS_EXISTS

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DIRECT_SEMANTIC_SUPPORT` | `PR-C05-001`, `PR-C05-006`, `PR-C05-007`, `PR-C05-009` | states the core value/representation relation |

| `STATE_AND_FRAME_SUPPORT` | `PR-C05-005`, `PR-C05-010` | protects inputs, guards, footprints or unrelated state |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-C05-002`, `PR-C05-003`, `PR-C05-004`, `PR-C05-008`, `PR-C05-011`, `PR-C05-012`, `PR-C05-013` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `FROMMSG-T1.P1`, `FROMMSG-T2.P1`, `FROMMSG-T2.P2`, `FROMMSG-T2.P3`, `FROMMSG-T2.P4`, `FROMMSG-T3.P1`, `FROMMSG-T3.P2`, `FROMMSG-T3.P3`, `FROMMSG-T3.P4`, `FROMMSG-T4.P1`, `FROMMSG-T4.P2`, `FROMMSG-T4.P3`, `FROMMSG-T4.P4`


**Survival-ledger contrary/unresolved IDs:** `CONFLICT-C05-NATIVE-HARNESS`


## Thesis-appendix projection


The compact Appendix 1 projection contains **13** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `CONFLICT-C05-NATIVE-HARNESS` | `EVIDENCE_SOURCE_CONFLICT` | The frozen af4c5abd source tree contains `proofs/cbmc/poly_frommsg/poly_frommsg_harness.c`; no identical generated T1–T4 suite is asserted by the census. | Wording qualified. Native one-call harness presence is acknowledged; only the exact multi-property suite remains repository-distinct within the inspected corpus. |


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


## PR-C05-001 — Exact bit-to-coefficient embedding


### Formal statement

$$
\mathrm{FromMsg}(m)_k=1665\cdot \mathrm{bit}(m,k)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact bit-to-coefficient embedding** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T1 harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected T1 mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T1 harness`. The admitted domain is: Arbitrary 32-byte message; k=$`\{0,\ldots,255\}`$. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The production function exactly embeds every message bit in the registered two-value codebook.

**What this record does not establish:** Not arbitrary polynomial decoding.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 1, “Exact message-bit embedding”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-001`

- **Historical identifier:** `FROMMSG-T1.P1`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Functional refinement`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 32-byte message; k=$`\{0,\ldots,255\}`$

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathrm{FromMsg}(m)_k=1665\cdot \mathrm{bit}(m,k)`$

- **Assertion / harness mapping:** FROMMSG T1 harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected T1 mutants rejected

- **Strongest bounded conclusion:** The production function exactly embeds every message bit in the registered two-value codebook.

- **Explicit exclusion:** Not arbitrary polynomial decoding.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 1, “Exact message-bit embedding”.


</details>

---

## PR-C05-002 — Exact selected-bit toggle pair


### Formal statement

$$
\left\lbrace R_k^{(1)},R_k^{(2)}\right\rbrace=\{0,1665\}
$$


### What the property/control means

The property checks the structural or multi-execution law **Exact selected-bit toggle pair**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T2 harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected relational mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T2 harness`. The admitted domain is: Two messages related by one selected bit toggle. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected one-bit relational behaviour is supported.

**What this record does not establish:** Not a statement about arbitrary unrelated message pairs.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 2, “Single-bit toggle produces complementary codewords”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-002`

- **Historical identifier:** `FROMMSG-T2.P1`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Two messages related by one selected bit toggle

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \left\lbrace R_k^{(1)},R_k^{(2)}\right\rbrace=\{0,1665\}`$

- **Assertion / harness mapping:** FROMMSG T2 harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected relational mutants rejected

- **Strongest bounded conclusion:** The selected one-bit relational behaviour is supported.

- **Explicit exclusion:** Not a statement about arbitrary unrelated message pairs.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 2, “Single-bit toggle produces complementary codewords”.


</details>

---

## PR-C05-003 — Complementary coefficient sum


### Formal statement

$$
R_k^{(1)}+R_k^{(2)}=1665
$$


### What the property/control means

The property checks the structural or multi-execution law **Complementary coefficient sum**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T2 harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected relational mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T2 harness`. The admitted domain is: Two messages related by one selected bit toggle. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected one-bit relational behaviour is supported.

**What this record does not establish:** Not a statement about arbitrary unrelated message pairs.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 3, “Toggle-sum relation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-003`

- **Historical identifier:** `FROMMSG-T2.P2`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Two messages related by one selected bit toggle

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle R_k^{(1)}+R_k^{(2)}=1665`$

- **Assertion / harness mapping:** FROMMSG T2 harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected relational mutants rejected

- **Strongest bounded conclusion:** The selected one-bit relational behaviour is supported.

- **Explicit exclusion:** Not a statement about arbitrary unrelated message pairs.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 3, “Toggle-sum relation”.


</details>

---

## PR-C05-004 — Coordinate-difference iff selected index


### Formal statement

$$
R_j^{(1)}\ne R_j^{(2)}\Longleftrightarrow j=k\qquad\text{for the one-bit-toggle construction}
$$


### What the property/control means

The property checks the structural or multi-execution law **Coordinate-difference iff selected index**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T2 harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected relational mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T2 harness`. The admitted domain is: Two messages related by one selected bit toggle. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected one-bit relational behaviour is supported.

**What this record does not establish:** Not a statement about arbitrary unrelated message pairs.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 4, “Exact support of a one-bit difference”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-004`

- **Historical identifier:** `FROMMSG-T2.P3`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Two messages related by one selected bit toggle

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle R_j^{(1)}\ne R_j^{(2)}\Longleftrightarrow j=k\qquad\text{for the one-bit-toggle construction}`$

- **Assertion / harness mapping:** FROMMSG T2 harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected relational mutants rejected

- **Strongest bounded conclusion:** The selected one-bit relational behaviour is supported.

- **Explicit exclusion:** Not a statement about arbitrary unrelated message pairs.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 4, “Exact support of a one-bit difference”.


</details>

---

## PR-C05-005 — Boolean complement preservation


### Formal statement

$$
\mathop{\text{FromMsg}}(m\oplus 2^k)_k=1665-\mathop{\text{FromMsg}}(m)_k
$$


### What the property/control means

The property checks **Boolean complement preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T2 harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected relational mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T2 harness`. The admitted domain is: Two messages related by one selected bit toggle. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected one-bit relational behaviour is supported.

**What this record does not establish:** Not a statement about arbitrary unrelated message pairs.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 5, “Complementary selected-codeword relation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-005`

- **Historical identifier:** `FROMMSG-T2.P4`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Relational/locality`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Two messages related by one selected bit toggle

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathop{\text{FromMsg}}(m\oplus 2^k)_k=1665-\mathop{\text{FromMsg}}(m)_k`$

- **Assertion / harness mapping:** FROMMSG T2 harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected relational mutants rejected

- **Strongest bounded conclusion:** The selected one-bit relational behaviour is supported.

- **Explicit exclusion:** Not a statement about arbitrary unrelated message pairs.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 5, “Complementary selected-codeword relation”.


</details>

---

## PR-C05-006 — Selected byte round trip


### Formal statement

$$
\mathrm{ToMsg}(\mathrm{FromMsg}(m))_{\mathrm{byte}}=m_{\mathrm{byte}}
$$


### What the property/control means

The property gives a direct semantic characterisation of **Selected byte round trip** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T3 composition harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Non-vacuity/mutation preflight retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T3 composition harness`. The admitted domain is: Message-originating data or exact two-value codebook image. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered message-originating round-trip or codebook relation is supported.

**What this record does not establish:** No reverse identity for arbitrary polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 6, “Selected-byte directional round trip”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-006`

- **Historical identifier:** `FROMMSG-T3.P1`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Directional round trip`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Message-originating data or exact two-value codebook image

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathrm{ToMsg}(\mathrm{FromMsg}(m))_{\mathrm{byte}}=m_{\mathrm{byte}}`$

- **Assertion / harness mapping:** FROMMSG T3 composition harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Non-vacuity/mutation preflight retained

- **Strongest bounded conclusion:** The registered message-originating round-trip or codebook relation is supported.

- **Explicit exclusion:** No reverse identity for arbitrary polynomials.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 6, “Selected-byte directional round trip”.


</details>

---

## PR-C05-007 — Selected bit round trip


### Formal statement

$$
\mathrm{bit}(\mathrm{ToMsg}(\mathrm{FromMsg}(m)),k)=\mathrm{bit}(m,k)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Selected bit round trip** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T3 composition harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Non-vacuity/mutation preflight retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T3 composition harness`. The admitted domain is: Message-originating data or exact two-value codebook image. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered message-originating round-trip or codebook relation is supported.

**What this record does not establish:** No reverse identity for arbitrary polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 7, “Selected-bit directional round trip”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-007`

- **Historical identifier:** `FROMMSG-T3.P2`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Directional round trip`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Message-originating data or exact two-value codebook image

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathrm{bit}(\mathrm{ToMsg}(\mathrm{FromMsg}(m)),k)=\mathrm{bit}(m,k)`$

- **Assertion / harness mapping:** FROMMSG T3 composition harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Non-vacuity/mutation preflight retained

- **Strongest bounded conclusion:** The registered message-originating round-trip or codebook relation is supported.

- **Explicit exclusion:** No reverse identity for arbitrary polynomials.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 7, “Selected-bit directional round trip”.


</details>

---

## PR-C05-008 — Codebook fixed point


### Formal statement

$$
\mathrm{FromMsg}(\mathrm{ToMsg}(R))=R
$$


### What the property/control means

The property checks the structural or multi-execution law **Codebook fixed point**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T3 composition harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Non-vacuity/mutation preflight retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T3 composition harness`. The admitted domain is: Message-originating data or exact two-value codebook image. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered message-originating round-trip or codebook relation is supported.

**What this record does not establish:** No reverse identity for arbitrary polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 8, “Codebook fixed point”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-008`

- **Historical identifier:** `FROMMSG-T3.P3`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Directional round trip`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Message-originating data or exact two-value codebook image

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathrm{FromMsg}(\mathrm{ToMsg}(R))=R`$

- **Assertion / harness mapping:** FROMMSG T3 composition harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Non-vacuity/mutation preflight retained

- **Strongest bounded conclusion:** The registered message-originating round-trip or codebook relation is supported.

- **Explicit exclusion:** No reverse identity for arbitrary polynomials.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 8, “Codebook fixed point”.


</details>

---

## PR-C05-009 — Exact codebook decoding relation


### Formal statement

$$
\mathop{\text{ToMsg}}(0)_k=0,\qquad \mathop{\text{ToMsg}}(1665)_k=1
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact codebook decoding relation** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T3 composition harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Non-vacuity/mutation preflight retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T3 composition harness`. The admitted domain is: Message-originating data or exact two-value codebook image. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered message-originating round-trip or codebook relation is supported.

**What this record does not establish:** No reverse identity for arbitrary polynomials.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 9, “Message decision on the two embedding codewords”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-009`

- **Historical identifier:** `FROMMSG-T3.P4`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Directional round trip`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Message-originating data or exact two-value codebook image

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathop{\text{ToMsg}}(0)_k=0,\qquad \mathop{\text{ToMsg}}(1665)_k=1`$

- **Assertion / harness mapping:** FROMMSG T3 composition harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Non-vacuity/mutation preflight retained

- **Strongest bounded conclusion:** The registered message-originating round-trip or codebook relation is supported.

- **Explicit exclusion:** No reverse identity for arbitrary polynomials.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 9, “Message decision on the two embedding codewords”.


</details>

---

## PR-C05-010 — Coordinate support preservation


### Formal statement

$$
\mathrm{supp}(\mathrm{FromMsg}(m))=\left\lbrace k:\mathrm{bit}(m,k)=1\right\rbrace
$$


### What the property/control means

The property checks **Coordinate support preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T4 harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected T4 mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T4 harness`. The admitted domain is: Arbitrary 32-byte message pair. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered support/weight/distance relation holds for message-originating codewords.

**What this record does not establish:** Not a metric claim for arbitrary polynomial coefficients.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 10, “Support preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-010`

- **Historical identifier:** `FROMMSG-T4.P1`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Codebook metric relation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 32-byte message pair

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \mathrm{supp}(\mathrm{FromMsg}(m))=\left\lbrace k:\mathrm{bit}(m,k)=1\right\rbrace`$

- **Assertion / harness mapping:** FROMMSG T4 harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected T4 mutants rejected

- **Strongest bounded conclusion:** The registered support/weight/distance relation holds for message-originating codewords.

- **Explicit exclusion:** Not a metric claim for arbitrary polynomial coefficients.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 10, “Support preservation”.


</details>

---

## PR-C05-011 — Weight-popcount equality


### Formal statement

$$
\left|\mathrm{supp}(\mathrm{FromMsg}(m))\right|=\mathrm{popcount}(m)
$$


### What the property/control means

The property checks the structural or multi-execution law **Weight-popcount equality**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T4 harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected T4 mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T4 harness`. The admitted domain is: Arbitrary 32-byte message pair. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered support/weight/distance relation holds for message-originating codewords.

**What this record does not establish:** Not a metric claim for arbitrary polynomial coefficients.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 11, “Weight--popcount relation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-011`

- **Historical identifier:** `FROMMSG-T4.P2`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Codebook metric relation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 32-byte message pair

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \left|\mathrm{supp}(\mathrm{FromMsg}(m))\right|=\mathrm{popcount}(m)`$

- **Assertion / harness mapping:** FROMMSG T4 harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected T4 mutants rejected

- **Strongest bounded conclusion:** The registered support/weight/distance relation holds for message-originating codewords.

- **Explicit exclusion:** Not a metric claim for arbitrary polynomial coefficients.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 11, “Weight--popcount relation”.


</details>

---

## PR-C05-012 — Support-distance/Hamming equality


### Formal statement

$$
\left|\mathrm{supp}(\mathrm{FromMsg}(m))\triangle \mathrm{supp}(\mathrm{FromMsg}(n))\right|=d_H(m,n)
$$


### What the property/control means

The property checks the structural or multi-execution law **Support-distance/Hamming equality**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T4 harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected T4 mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T4 harness`. The admitted domain is: Arbitrary 32-byte message pair. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered support/weight/distance relation holds for message-originating codewords.

**What this record does not establish:** Not a metric claim for arbitrary polynomial coefficients.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 12, “Support-distance relation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-012`

- **Historical identifier:** `FROMMSG-T4.P3`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Codebook metric relation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 32-byte message pair

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \left|\mathrm{supp}(\mathrm{FromMsg}(m))\triangle \mathrm{supp}(\mathrm{FromMsg}(n))\right|=d_H(m,n)`$

- **Assertion / harness mapping:** FROMMSG T4 harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected T4 mutants rejected

- **Strongest bounded conclusion:** The registered support/weight/distance relation holds for message-originating codewords.

- **Explicit exclusion:** Not a metric claim for arbitrary polynomial coefficients.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-012`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 12, “Support-distance relation”.


</details>

---

## PR-C05-013 — L1-distance/Hamming scaling


### Formal statement

$$
\left\|\mathrm{FromMsg}(m)-\mathrm{FromMsg}(n)\right\|_1=1665\,d_H(m,n)
$$


### What the property/control means

The property checks the structural or multi-execution law **L1-distance/Hamming scaling**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `FROMMSG T4 harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected T4 mutants rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `FROMMSG T4 harness`. The admitted domain is: Arbitrary 32-byte message pair. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered support/weight/distance relation holds for message-originating codewords.

**What this record does not establish:** Not a metric claim for arbitrary polynomial coefficients.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_frommsg` source contract/loop annotations and call harness. The campaign addition is characterised at case level as: Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 13, “$`\left( L_{1} \right)`$-distance relation”. Chapter 4 uses the case-level principal synthesis in Section 4.4.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C05-013`

- **Historical identifier:** `FROMMSG-T4.P4`

- **Case identifier:** `5`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_frommsg`

- **Property class:** `Codebook metric relation`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768

- **Input domain:** Arbitrary 32-byte message pair

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** $`\displaystyle \left\|\mathrm{FromMsg}(m)-\mathrm{FromMsg}(n)\right\|_1=1665\,d_H(m,n)`$

- **Assertion / harness mapping:** FROMMSG T4 harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected T4 mutants rejected

- **Strongest bounded conclusion:** The registered support/weight/distance relation holds for message-originating codewords.

- **Explicit exclusion:** Not a metric claim for arbitrary polynomial coefficients.

- **Evidence locator:** `LOC-C05-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_FROMMSG_T1_T4_COMPLETE_CBMC_VERIFICATION_RECORD.md

- **Archive entry SHA-256:** `aa2c0d5ee0cdce1a4b912dd0461c1174d6f5c05c858b01372cf7d69d3b20f10b`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C05-013`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 5: Message Embedding: mlk_poly_frommsg → item 13, “$`\left( L_{1} \right)`$-distance relation”.


</details>

---


# Case-level bounded conclusion

$`\mathrm{frommsg}(m)_k=1665\,\mathrm{bit}_k(m)`$, and $`\mathrm{tomsg}(\mathrm{frommsg}(m))=m`$ for every 32-byte message m.

**Explicit exclusion.** Not arbitrary polynomial decoding.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
