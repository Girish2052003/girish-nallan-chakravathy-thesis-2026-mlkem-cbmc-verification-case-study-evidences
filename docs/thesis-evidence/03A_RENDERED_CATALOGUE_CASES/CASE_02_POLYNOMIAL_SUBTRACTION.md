# Case 2 — Polynomial Subtraction

**Target:** `mlk_poly_sub`
**Evidence locator:** `LOC-C02-UA`
**Chapter 4 projection:** Section 4.3.2
**Ledger records:** 24
**Formally supported subset:** 24

**Pinned source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

How does the unchanged subtraction routine behave as an exact finite-width operation, as a modular operation after normalisation, and under relational dependency, frame and caller-oriented observations?

## Case notation and opening equations


$$
R=\mathop{\text{Sub}}(A,B)
$$


$$
\mathop{\text{Norm}}(X)\text{ denotes the registered production normalisation composition}
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
\mathop{\text{Norm}}(A-B)=\mathop{\text{canon}}_q(A-B)
$$


$$
\mathop{\text{Norm}}(A-B)=\mathop{\text{Norm}}(\mathop{\text{Norm}}(A)-\mathop{\text{Norm}}(B))
$$


$$
0\le A_i,B_i<q\;\Longrightarrow\;R_i=A_i-B_i\in[-3328,3328]
$$


**Recorded principal-claim wording:** The subtraction campaign supports independent-oracle normalization, normalization compatibility, exact/modular cancellation, the SUB-T4 canonical exact-difference bridge with tight range [-3328,3328], frame/locality/determinism and the registered production-slice obligations.


### Why this claim is the principal case-level synthesis

The principal claim is intentionally broader than a single raw equality because the case was designed around the connection between exact subtraction, modular normalisation and dependency behaviour. Cancellation, locality, determinism and production-slice records are subordinate strengthening evidence; the tight canonical-domain bridge is what prevents representability from being silently assumed.


The survival ledger assigns this synthesis to **4.3.2** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `d9613cf60de3132d32475c102d8c2781d84feb34` under `ML-KEM-768`. Its primary verification focus was: Subtraction followed by normalization against an independent oracle; normalization compatibility; exact right and left cancellation; modular cancellation; later frame, locality and determinism families. The additional or mixed evidence was: Valid boundary cases passed; deliberately invalid lower/upper controls failed as expected; T1 mutation killed 3/3 mutants; T3 mutation was explicitly deferred.


The retained case matrix records CBMC execution as **YES — T1/T2/T3 and later retained families report accepted proof and coverage results**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES (T1); T3 deferred`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** The pinned portable-C subtraction implementation satisfies the recorded semantic, normalization, cancellation, boundary, frame/locality and non-vacuity properties under the stated representability and object-validity assumptions.


**Integrity boundary:** Production bodies were retained; no production-source accommodation was accepted.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md` with entry SHA-256 `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`. The case archive is `thesis_batch_3.zip` with SHA-256 `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`. Evidence completeness is `COMPLETE`.
 The recorded limitation is: T3 mutation analysis deferred; one T4 template with unresolved placeholder excluded from final hash evidence.



The representative artefact map contains **40** indexed records for `LOC-C02-UA`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary.


**Necessary overlap.** Target identifiers, constants, required calls and contract-domain facts.


**What this campaign added.** Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties.


**Why the suite is substantively distinct within the inspected corpus.** Multi-execution/compositional relations, independent oracle, negative boundaries, call-site slice and dedicated non-vacuity/mutation controls are not the native one-call harness.


**Comparison material inspected.** `proofs/cbmc/poly_sub/`, production source/contracts, clean-room post-freeze audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESS_PRESENT

- **Native proof paths:** mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/proofs/cbmc/poly_sub/poly_sub_harness.c;mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/proofs/cbmc/poly_sub/Makefile

- **Native proof entry SHA-256:** 12d6a569b8a0bc6a4fc9340f1378f28e11c94beb43730b291161d6a24f8f67d1;d576e9ca8f1c952e79ae0b21d93b768a9d0d14b38584e76e953a800253afece8

- **Production source paths:** mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/mlkem/src/poly.c;mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/mlkem/src/poly.h

- **Production source entry SHA-256:** f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722;f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef

- **Authoritative baseline characterisation:** Native one-call `poly_sub` harness and source contract are present.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT` | `PR-C02-002`, `PR-C02-008`, `PR-C02-009`, `PR-C02-010` | establishes the finite domain, range or representation in which the core relation is meaningful |

| `STATE_AND_FRAME_SUPPORT` | `PR-C02-003`, `PR-C02-011`, `PR-C02-012`, `PR-C02-013`, `PR-C02-014`, `PR-C02-015`, `PR-C02-016`, `PR-C02-017`, `PR-C02-021` | protects inputs, guards, footprints or unrelated state |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-C02-005`, `PR-C02-006`, `PR-C02-007` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |

| `COMPOSITION_AND_CALLER_SUPPORT` | `PR-C02-001`, `PR-C02-004`, `PR-C02-018`, `PR-C02-019`, `PR-C02-020`, `PR-C02-022`, `PR-C02-023`, `PR-C02-024` | connects the local relation to callers, sequential operations, cross-function composition or parameter replication |


**Survival-ledger supporting historical IDs:** `SUB-T1.P1`, `SUB-T1.P2`, `SUB-T1.P3`, `SUB-T2.P1`, `SUB-T3A`, `SUB-T3B`, `SUB-T3C`, `SUB-T5.1`, `SUB-T5.2`, `SUB-T5.3`, `SUB-T5.4`, `SUB-T5.5`, `SUB-T5.6`, `SUB-T6.1`, `SUB-T6.2`, `SUB-T6.3`, `SUB-T6.4`, `SUB-T6.5`, `SUB-T6.6`, `SUB-T6.7`, `SUB-T4.P1`, `SUB-T4.P2`, `SUB-T4.P3`, `SUB-T4.P4`


## Thesis-appendix projection


The compact Appendix 1 projection contains **24** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `LIM-C02-T3M` | `NOT_TESTED` | Deferred rather than executed. | Do not recode as success or failure. |

| `EXC-C02-T4TPL` | `EXCLUDED_TEMPLATE` | Unresolved placeholder. | Excluded from final hash evidence; does not replace valid raw campaign records. |

| `CTRL-C02-T4LOW` | `EXPECTED_FAILURE_CONTROL` | The deliberately strengthened lower bound excluded the attainable -3328 endpoint and failed as intended. | Retain as boundary-tightness/non-vacuity control; not a defect in the production function. |

| `CTRL-C02-T4UP` | `EXPECTED_FAILURE_CONTROL` | The deliberately strengthened upper bound excluded the attainable 3328 endpoint and failed as intended. | Retain as boundary-tightness/non-vacuity control; not a defect in the production function. |


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


## PR-C02-001 — Canonical subtraction-after-reduction refinement


### Formal statement

$$
\mathrm{Norm}(R_i)=\mathrm{canon}_q(A_i-B_i)
$$


### What the property/control means

The property moves beyond the isolated target and checks **Canonical subtraction-after-reduction refinement** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T1 semantic composition harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: T1 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T1 semantic composition harness`. The admitted domain is: int16_t A,B with direct difference representable. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Production subtraction followed by reduction equals an independent canonical oracle.

**What this record does not establish:** Not unrestricted subtraction outside representable difference domain.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 1, “Canonical normalisation of subtraction”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-001`

- **Historical identifier:** `SUB-T1.P1`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Sequential functional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** int16_t A,B with direct difference representable

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** reduce(sub(A,B))[i] = canon_q(int32(A[i])-int32(B[i]))

- **Assertion / harness mapping:** SUB-T1 semantic composition harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T1 selected mutants killed

- **Strongest bounded conclusion:** Production subtraction followed by reduction equals an independent canonical oracle.

- **Explicit exclusion:** Not unrestricted subtraction outside representable difference domain.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 1, “Canonical normalisation of subtraction”.


</details>

---

## PR-C02-002 — Canonical output range


### Formal statement

$$
0 \le output_{i} < q
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Canonical output range**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T1 range assertions`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: T1 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T1 range assertions`. The admitted domain is: SUB-T1 domain. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Sequential output is canonical under the accepted domain.

**What this record does not establish:** Not a standalone claim for arbitrary calls to mlk_poly_sub.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 2, “Normalised output range”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-002`

- **Historical identifier:** `SUB-T1.P2`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Range`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** SUB-T1 domain

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** 0 <= output[i] < q

- **Assertion / harness mapping:** SUB-T1 range assertions

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T1 selected mutants killed

- **Strongest bounded conclusion:** Sequential output is canonical under the accepted domain.

- **Explicit exclusion:** Not a standalone claim for arbitrary calls to mlk_poly_sub.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 2, “Normalised output range”.


</details>

---

## PR-C02-003 — SUB-T1 frame preservation


### Formal statement

$$
\mathrm{RO}_{\mathrm{after}}=\mathrm{RO}_{\mathrm{before}}\quad\land\quad\mathrm{saved}_{\mathrm{after}}=\mathrm{saved}_{\mathrm{before}}
$$


### What the property/control means

The property checks **SUB-T1 frame preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T1 frame assertions`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: T1 selected mutants killed. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T1 frame assertions`. The admitted domain is: SUB-T1 domain. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The modelled read-only and snapshot objects are preserved.

**What this record does not establish:** Not a universal whole-program footprint claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 3, “Input-frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-003`

- **Historical identifier:** `SUB-T1.P3`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** SUB-T1 domain

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** read-only operand and saved source objects unchanged

- **Assertion / harness mapping:** SUB-T1 frame assertions

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T1 selected mutants killed

- **Strongest bounded conclusion:** The modelled read-only and snapshot objects are preserved.

- **Explicit exclusion:** Not a universal whole-program footprint claim.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 3, “Input-frame preservation”.


</details>

---

## PR-C02-004 — Normalization compatibility


### Formal statement

$$
\mathrm{Norm}(A-B)=\mathrm{Norm}\!\left(\mathrm{Norm}(A)-\mathrm{Norm}(B)\right)
$$


### What the property/control means

The property moves beyond the isolated target and checks **Normalization compatibility** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T2 relational harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Property-specific boundary controls; no complete T3 mutation claim. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T2 relational harness`. The admitted domain is: int16_t A,B with applicable representability. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Two production normalization routes agree.

**What this record does not establish:** Equality of two paths is interpreted together with SUB-T1 independent oracle evidence.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 4, “Normalisation invariance”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-004`

- **Historical identifier:** `SUB-T2.P1`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Relational sequential`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** int16_t A,B with applicable representability

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** N(A-B)=N(N(A)-N(B))

- **Assertion / harness mapping:** SUB-T2 relational harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Property-specific boundary controls; no complete T3 mutation claim

- **Strongest bounded conclusion:** Two production normalization routes agree.

- **Explicit exclusion:** Equality of two paths is interpreted together with SUB-T1 independent oracle evidence.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-004`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 4, “Normalisation invariance”.


</details>

---

## PR-C02-005 — Exact right cancellation


### Formal statement

$$
\mathrm{Add}(\mathrm{Sub}(A,B),B)=A
$$


### What the property/control means

The property checks the structural or multi-execution law **Exact right cancellation**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T3 cancellation harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: T3 mutation analysis NOT TESTED/deferred. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T3 cancellation harness family`. The admitted domain is: Initial A-B representable and recomposition calls valid. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered exact or modular cancellation relation is supported.

**What this record does not establish:** Does not imply unrestricted finite-width group laws outside the registered domains.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 5, “Right-cancellation after subtraction”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-005`

- **Historical identifier:** `SUB-T3A`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Cancellation composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Initial A-B representable and recomposition calls valid

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** add(sub(A,B),B)=A

- **Assertion / harness mapping:** SUB-T3 cancellation harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T3 mutation analysis NOT TESTED/deferred

- **Strongest bounded conclusion:** The registered exact or modular cancellation relation is supported.

- **Explicit exclusion:** Does not imply unrestricted finite-width group laws outside the registered domains.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-005`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 5, “Right-cancellation after subtraction”.


</details>

---

## PR-C02-006 — Exact left cancellation


### Formal statement

$$
\mathrm{Sub}(\mathrm{Add}(A,B),B)=A
$$


### What the property/control means

The property checks the structural or multi-execution law **Exact left cancellation**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T3 cancellation harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: T3 mutation analysis NOT TESTED/deferred. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T3 cancellation harness family`. The admitted domain is: Initial A+B representable and recomposition calls valid. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered exact or modular cancellation relation is supported.

**What this record does not establish:** Does not imply unrestricted finite-width group laws outside the registered domains.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 6, “Right-cancellation after addition”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-006`

- **Historical identifier:** `SUB-T3B`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Cancellation composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Initial A+B representable and recomposition calls valid

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** sub(add(A,B),B)=A

- **Assertion / harness mapping:** SUB-T3 cancellation harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T3 mutation analysis NOT TESTED/deferred

- **Strongest bounded conclusion:** The registered exact or modular cancellation relation is supported.

- **Explicit exclusion:** Does not imply unrestricted finite-width group laws outside the registered domains.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-006`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 6, “Right-cancellation after addition”.


</details>

---

## PR-C02-007 — Modular cancellation


### Formal statement

$$
\mathrm{Norm}(\mathrm{Add}(\mathrm{Sub}(A,B),B))=\mathrm{Norm}(A),\qquad \mathrm{Norm}(\mathrm{Sub}(\mathrm{Add}(A,B),B))=\mathrm{Norm}(A)
$$


### What the property/control means

The property checks the structural or multi-execution law **Modular cancellation**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T3 cancellation harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: T3 mutation analysis NOT TESTED/deferred. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T3 cancellation harness family`. The admitted domain is: Registered representable initial operation; canonical reduction at comparison. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered exact or modular cancellation relation is supported.

**What this record does not establish:** Does not imply unrestricted finite-width group laws outside the registered domains.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 7, “Normalised cancellation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-007`

- **Historical identifier:** `SUB-T3C`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Cancellation composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Registered representable initial operation; canonical reduction at comparison

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** N(add(sub(A,B),B))=N(A) and registered counterpart

- **Assertion / harness mapping:** SUB-T3 cancellation harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** T3 mutation analysis NOT TESTED/deferred

- **Strongest bounded conclusion:** The registered exact or modular cancellation relation is supported.

- **Explicit exclusion:** Does not imply unrestricted finite-width group laws outside the registered domains.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-007`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 7, “Normalised cancellation”.


</details>

---

## PR-C02-008 — Canonical-domain exact subtraction


### Formal statement

$$
r_{i} = \mathop{\text{int32}}(A_{i}) - \mathop{\text{int32}}(B_{i})
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Canonical-domain exact subtraction**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T4 canonical-domain harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Five boundary covers retained; false stronger lower/upper bounds rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T4 canonical-domain harness`. The admitted domain is: Canonical ML-KEM coefficient arrays. The recorded assumptions/grounding are: Separate valid polynomial objects; all input coefficients canonical in [0,3328]; unchanged retained portable-C target; signed representability derived from the domain.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The raw production output equals exact coefficient-wise subtraction on canonical inputs.

**What this record does not establish:** Not arbitrary non-canonical input behaviour.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 8, “Exact canonical-domain difference”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-008`

- **Historical identifier:** `SUB-T4.P1`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Functional refinement`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical ML-KEM coefficient arrays

- **Assumptions and grounding:** Separate valid polynomial objects; all input coefficients canonical in [0,3328]; unchanged retained portable-C target; signed representability derived from the domain.

- **Ledger formal relation:** r[i] = int32(A[i]) - int32(B[i])

- **Assertion / harness mapping:** SUB-T4 canonical-domain harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Five boundary covers retained; false stronger lower/upper bounds rejected

- **Strongest bounded conclusion:** The raw production output equals exact coefficient-wise subtraction on canonical inputs.

- **Explicit exclusion:** Not arbitrary non-canonical input behaviour.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/frozen_harness_family_v1/harnesses/sub_t4_canonical_domain_harness.c

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `thesis_batch_3.zip`

- **Archive SHA-256:** `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`

- **Archive evidence path:** mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/frozen_harness_family_v1/harnesses/sub_t4_canonical_domain_harness.c

- **Archive entry SHA-256:** `9828c24ee004f3f2821179e2c7b39ff07f17a4514c6f96bf9abeee3635edbdcc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-008`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 8, “Exact canonical-domain difference”.


</details>

---

## PR-C02-009 — Tight canonical-domain output interval


### Formal statement

$$
-3328 \le r_{i} \le 3328
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Tight canonical-domain output interval**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T4 canonical-domain harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Five boundary covers retained; false stronger lower/upper bounds rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T4 canonical-domain harness`. The admitted domain is: Canonical ML-KEM coefficient arrays. The recorded assumptions/grounding are: Separate valid polynomial objects; all input coefficients canonical in [0,3328]; unchanged retained portable-C target; signed representability derived from the domain.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The exact raw output lies in the tight derived interval.

**What this record does not establish:** The output is not claimed to be canonical before reduction.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 9, “Exact-difference range”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-009`

- **Historical identifier:** `SUB-T4.P2`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Range`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical ML-KEM coefficient arrays

- **Assumptions and grounding:** Separate valid polynomial objects; all input coefficients canonical in [0,3328]; unchanged retained portable-C target; signed representability derived from the domain.

- **Ledger formal relation:** -3328 <= r[i] <= 3328

- **Assertion / harness mapping:** SUB-T4 canonical-domain harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Five boundary covers retained; false stronger lower/upper bounds rejected

- **Strongest bounded conclusion:** The exact raw output lies in the tight derived interval.

- **Explicit exclusion:** The output is not claimed to be canonical before reduction.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/frozen_harness_family_v1/harnesses/sub_t4_canonical_domain_harness.c

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `thesis_batch_3.zip`

- **Archive SHA-256:** `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`

- **Archive evidence path:** mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/frozen_harness_family_v1/harnesses/sub_t4_canonical_domain_harness.c

- **Archive entry SHA-256:** `9828c24ee004f3f2821179e2c7b39ff07f17a4514c6f96bf9abeee3635edbdcc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-009`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 9, “Exact-difference range”.


</details>

---

## PR-C02-010 — Representability derived from canonical inputs


### Formal statement

$$
0\le A_i,B_i\le3328\Longrightarrow -3328\le A_i-B_i\le3328\subset\mathrm{int16\_t}
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Representability derived from canonical inputs**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T4 canonical-domain harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Five boundary covers retained; false stronger lower/upper bounds rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T4 canonical-domain harness`. The admitted domain is: Canonical ML-KEM coefficient arrays. The recorded assumptions/grounding are: Separate valid polynomial objects; all input coefficients canonical in [0,3328]; unchanged retained portable-C target; signed representability derived from the domain.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** No separate conclusion-forcing representability assumption is needed.

**What this record does not establish:** Does not remove representability requirements for wider non-canonical domains.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 10, “Canonical-domain representability”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-010`

- **Historical identifier:** `SUB-T4.P3`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Arithmetic safety/domain bridge`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical ML-KEM coefficient arrays

- **Assumptions and grounding:** Separate valid polynomial objects; all input coefficients canonical in [0,3328]; unchanged retained portable-C target; signed representability derived from the domain.

- **Ledger formal relation:** A[i],B[i] in [0,3328] => A[i]-B[i] in [-3328,3328] subset int16_t

- **Assertion / harness mapping:** SUB-T4 canonical-domain harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Five boundary covers retained; false stronger lower/upper bounds rejected

- **Strongest bounded conclusion:** No separate conclusion-forcing representability assumption is needed.

- **Explicit exclusion:** Does not remove representability requirements for wider non-canonical domains.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/frozen_harness_family_v1/harnesses/sub_t4_canonical_domain_harness.c

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `thesis_batch_3.zip`

- **Archive SHA-256:** `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`

- **Archive evidence path:** mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/frozen_harness_family_v1/harnesses/sub_t4_canonical_domain_harness.c

- **Archive entry SHA-256:** `9828c24ee004f3f2821179e2c7b39ff07f17a4514c6f96bf9abeee3635edbdcc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-010`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 10, “Canonical-domain representability”.


</details>

---

## PR-C02-011 — Second-input frame preservation


### Formal statement

$$
B^{\mathrm{after}} = B^{\mathrm{before}}
$$


### What the property/control means

The property checks **Second-input frame preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T4 canonical-domain harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Five boundary covers retained; false stronger lower/upper bounds rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T4 canonical-domain harness`. The admitted domain is: Canonical ML-KEM coefficient arrays. The recorded assumptions/grounding are: Separate valid polynomial objects; all input coefficients canonical in [0,3328]; unchanged retained portable-C target; signed representability derived from the domain.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The read-only subtrahend is preserved in the modelled call.

**What this record does not establish:** Not a universal whole-program footprint claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 11, “Subtrahend-frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-011`

- **Historical identifier:** `SUB-T4.P4`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Canonical ML-KEM coefficient arrays

- **Assumptions and grounding:** Separate valid polynomial objects; all input coefficients canonical in [0,3328]; unchanged retained portable-C target; signed representability derived from the domain.

- **Ledger formal relation:** B_after = B_before

- **Assertion / harness mapping:** SUB-T4 canonical-domain harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Five boundary covers retained; false stronger lower/upper bounds rejected

- **Strongest bounded conclusion:** The read-only subtrahend is preserved in the modelled call.

- **Explicit exclusion:** Not a universal whole-program footprint claim.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/frozen_harness_family_v1/harnesses/sub_t4_canonical_domain_harness.c

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `thesis_batch_3.zip`

- **Archive SHA-256:** `67eae3ada1cd8cd5aa9d8a3336a1113e3cc73f4f4f6660f511a8dd3ac32da278`

- **Archive evidence path:** mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/frozen_harness_family_v1/harnesses/sub_t4_canonical_domain_harness.c

- **Archive entry SHA-256:** `9828c24ee004f3f2821179e2c7b39ff07f17a4514c6f96bf9abeee3635edbdcc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-011`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 11, “Subtrahend-frame preservation”.


</details>

---

## PR-C02-012 — Input-frame preservation


### Formal statement

$$
(A_1,A_2,B_1,B_2,\mathrm{snapshots},\mathrm{guards})_{\mathrm{after}}=(A_1,A_2,B_1,B_2,\mathrm{snapshots},\mathrm{guards})_{\mathrm{before}}
$$


### What the property/control means

The property checks **Input-frame preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T5 frozen two-run harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T5 mutants killed; two expected-failure controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T5 frozen two-run harness family`. The admitted domain is: All coefficients canonical 0..3328; symbolic selected indices; valid separate objects. The recorded assumptions/grounding are: No conclusion-shaped arithmetic assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered dependency, frame or determinism relation is supported.

**What this record does not establish:** T5.6 is limited to explicitly modelled harness-owned objects.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 12, “Two-run snapshot and guard preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-012`

- **Historical identifier:** `SUB-T5.1`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Relational/frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** All coefficients canonical 0..3328; symbolic selected indices; valid separate objects

- **Assumptions and grounding:** No conclusion-shaped arithmetic assumptions

- **Ledger formal relation:** A1,A2,B1,B2 and registered snapshots/guards unchanged

- **Assertion / harness mapping:** SUB-T5 frozen two-run harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T5 mutants killed; two expected-failure controls rejected

- **Strongest bounded conclusion:** The registered dependency, frame or determinism relation is supported.

- **Explicit exclusion:** T5.6 is limited to explicitly modelled harness-owned objects.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-012`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 12, “Two-run snapshot and guard preservation”.


</details>

---

## PR-C02-013 — Coefficient locality


### Formal statement

$$
A_k^{(1)}=A_k^{(2)}\land B_k^{(1)}=B_k^{(2)}\Longrightarrow R_k^{(1)}=R_k^{(2)}
$$


### What the property/control means

The property checks **Coefficient locality** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T5 frozen two-run harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T5 mutants killed; two expected-failure controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T5 frozen two-run harness family`. The admitted domain is: All coefficients canonical 0..3328; symbolic selected indices; valid separate objects. The recorded assumptions/grounding are: No conclusion-shaped arithmetic assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered dependency, frame or determinism relation is supported.

**What this record does not establish:** T5.6 is limited to explicitly modelled harness-owned objects.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 13, “Coefficient locality”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-013`

- **Historical identifier:** `SUB-T5.2`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Relational/frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** All coefficients canonical 0..3328; symbolic selected indices; valid separate objects

- **Assumptions and grounding:** No conclusion-shaped arithmetic assumptions

- **Ledger formal relation:** A1[k]=A2[k] and B1[k]=B2[k] => R1[k]=R2[k]

- **Assertion / harness mapping:** SUB-T5 frozen two-run harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T5 mutants killed; two expected-failure controls rejected

- **Strongest bounded conclusion:** The registered dependency, frame or determinism relation is supported.

- **Explicit exclusion:** T5.6 is limited to explicitly modelled harness-owned objects.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-013`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 13, “Coefficient locality”.


</details>

---

## PR-C02-014 — Cross-coefficient non-interference


### Formal statement

$$
\begin{array}{rl}
&\text{inputs differ only at j => outputs agree for all i != j}
\end{array}
$$


### What the property/control means

The property checks **Cross-coefficient non-interference** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T5 frozen two-run harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T5 mutants killed; two expected-failure controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T5 frozen two-run harness family`. The admitted domain is: All coefficients canonical 0..3328; symbolic selected indices; valid separate objects. The recorded assumptions/grounding are: No conclusion-shaped arithmetic assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered dependency, frame or determinism relation is supported.

**What this record does not establish:** T5.6 is limited to explicitly modelled harness-owned objects.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 14, “Single-coordinate non-interference”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-014`

- **Historical identifier:** `SUB-T5.3`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Relational/frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** All coefficients canonical 0..3328; symbolic selected indices; valid separate objects

- **Assumptions and grounding:** No conclusion-shaped arithmetic assumptions

- **Ledger formal relation:** inputs differ only at j => outputs agree for all i != j

- **Assertion / harness mapping:** SUB-T5 frozen two-run harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T5 mutants killed; two expected-failure controls rejected

- **Strongest bounded conclusion:** The registered dependency, frame or determinism relation is supported.

- **Explicit exclusion:** T5.6 is limited to explicitly modelled harness-owned objects.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-014`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** verbatim structural/logical relation rendered without inventing an equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 14, “Single-coordinate non-interference”.


</details>

---

## PR-C02-015 — Exact changed-coordinate effect


### Formal statement

$$
R_j^{(1)}-R_j^{(2)}=(A_j^{(1)}-B_j^{(1)})-(A_j^{(2)}-B_j^{(2)})
$$


### What the property/control means

The property checks **Exact changed-coordinate effect** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T5 frozen two-run harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T5 mutants killed; two expected-failure controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T5 frozen two-run harness family`. The admitted domain is: All coefficients canonical 0..3328; symbolic selected indices; valid separate objects. The recorded assumptions/grounding are: No conclusion-shaped arithmetic assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered dependency, frame or determinism relation is supported.

**What this record does not establish:** T5.6 is limited to explicitly modelled harness-owned objects.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 15, “Exact differential locality at the changed coordinate”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-015`

- **Historical identifier:** `SUB-T5.4`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Relational/frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** All coefficients canonical 0..3328; symbolic selected indices; valid separate objects

- **Assumptions and grounding:** No conclusion-shaped arithmetic assumptions

- **Ledger formal relation:** R1[j]-R2[j]=(A1[j]-B1[j])-(A2[j]-B2[j]) in widened arithmetic

- **Assertion / harness mapping:** SUB-T5 frozen two-run harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T5 mutants killed; two expected-failure controls rejected

- **Strongest bounded conclusion:** The registered dependency, frame or determinism relation is supported.

- **Explicit exclusion:** T5.6 is limited to explicitly modelled harness-owned objects.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-015`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 15, “Exact differential locality at the changed coordinate”.


</details>

---

## PR-C02-016 — Determinism


### Formal statement

$$
A^{(1)}=A^{(2)}\land B^{(1)}=B^{(2)}\Longrightarrow R^{(1)}=R^{(2)}
$$


### What the property/control means

The property checks **Determinism** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T5 frozen two-run harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T5 mutants killed; two expected-failure controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T5 frozen two-run harness family`. The admitted domain is: All coefficients canonical 0..3328; symbolic selected indices; valid separate objects. The recorded assumptions/grounding are: No conclusion-shaped arithmetic assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered dependency, frame or determinism relation is supported.

**What this record does not establish:** T5.6 is limited to explicitly modelled harness-owned objects.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 16, “Determinism”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-016`

- **Historical identifier:** `SUB-T5.5`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Relational/frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** All coefficients canonical 0..3328; symbolic selected indices; valid separate objects

- **Assumptions and grounding:** No conclusion-shaped arithmetic assumptions

- **Ledger formal relation:** A1=A2 and B1=B2 => R1=R2

- **Assertion / harness mapping:** SUB-T5 frozen two-run harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T5 mutants killed; two expected-failure controls rejected

- **Strongest bounded conclusion:** The registered dependency, frame or determinism relation is supported.

- **Explicit exclusion:** T5.6 is limited to explicitly modelled harness-owned objects.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-016`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 16, “Determinism”.


</details>

---

## PR-C02-017 — Harness-observed destination-only boundary


### Formal statement

$$
\mathrm{ModifiedObjects}\subseteq\{R_1,R_2\}\qquad\text{within the explicitly modelled harness objects}
$$


### What the property/control means

The property checks **Harness-observed destination-only boundary** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T5 frozen two-run harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T5 mutants killed; two expected-failure controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T5 frozen two-run harness family`. The admitted domain is: All coefficients canonical 0..3328; symbolic selected indices; valid separate objects. The recorded assumptions/grounding are: No conclusion-shaped arithmetic assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered dependency, frame or determinism relation is supported.

**What this record does not establish:** T5.6 is limited to explicitly modelled harness-owned objects.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 17, “Destination-frame restriction”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-017`

- **Historical identifier:** `SUB-T5.6`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Relational/frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** All coefficients canonical 0..3328; symbolic selected indices; valid separate objects

- **Assumptions and grounding:** No conclusion-shaped arithmetic assumptions

- **Ledger formal relation:** Only R1,R2 among explicitly modelled harness objects may change

- **Assertion / harness mapping:** SUB-T5 frozen two-run harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T5 mutants killed; two expected-failure controls rejected

- **Strongest bounded conclusion:** The registered dependency, frame or determinism relation is supported.

- **Explicit exclusion:** T5.6 is limited to explicitly modelled harness-owned objects.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-017`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 17, “Destination-frame restriction”.


</details>

---

## PR-C02-018 — Object validity and separation


### Formal statement

$$
\bigwedge_{O\in\mathcal O_{\mathrm{slice}}}\mathrm{Valid}(O)\quad\land\quad\mathrm{SeparatedAsRegistered}(\mathcal O_{\mathrm{slice}})
$$


### What the property/control means

The property moves beyond the isolated target and checks **Object validity and separation** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T6 positive harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T6 mutants killed; three false controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T6 positive harness family`. The admitted domain is: ML-KEM-768 registered caller slice and producer-bound domain. The recorded assumptions/grounding are: Frozen producer bounds and scoped verification adapter; production functions unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered production slice obligation is supported.

**What this record does not establish:** Not complete decryption correctness or a proof of every caller.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 18, “Caller-object validity and separation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-018`

- **Historical identifier:** `SUB-T6.1`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Production-slice composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 registered caller slice and producer-bound domain

- **Assumptions and grounding:** Frozen producer bounds and scoped verification adapter; production functions unchanged

- **Ledger formal relation:** All registered slice objects are valid and separated as required

- **Assertion / harness mapping:** SUB-T6 positive harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T6 mutants killed; three false controls rejected

- **Strongest bounded conclusion:** The registered production slice obligation is supported.

- **Explicit exclusion:** Not complete decryption correctness or a proof of every caller.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-018`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 18, “Caller-object validity and separation”.


</details>

---

## PR-C02-019 — Representability derivation


### Formal statement

$$
0\le v_i\le3328\land -26631\le sb_i\le26631\Longrightarrow -26631\le v_i-sb_i\le29959\subset\mathrm{int16\_t}
$$


### What the property/control means

The property moves beyond the isolated target and checks **Representability derivation** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T6 positive harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T6 mutants killed; three false controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T6 positive harness family`. The admitted domain is: ML-KEM-768 registered caller slice and producer-bound domain. The recorded assumptions/grounding are: Frozen producer bounds and scoped verification adapter; production functions unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered production slice obligation is supported.

**What this record does not establish:** Not complete decryption correctness or a proof of every caller.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 19, “Caller-domain subtraction representability”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-019`

- **Historical identifier:** `SUB-T6.2`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Production-slice composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 registered caller slice and producer-bound domain

- **Assumptions and grounding:** Frozen producer bounds and scoped verification adapter; production functions unchanged

- **Ledger formal relation:** v in [0,3328], sb in [-26631,26631] => v-sb in [-26631,29959] subset int16

- **Assertion / harness mapping:** SUB-T6 positive harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T6 mutants killed; three false controls rejected

- **Strongest bounded conclusion:** The registered production slice obligation is supported.

- **Explicit exclusion:** Not complete decryption correctness or a proof of every caller.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-019`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 19, “Caller-domain subtraction representability”.


</details>

---

## PR-C02-020 — Exact call-site subtraction


### Formal statement

$$
v_i^{\mathrm{sub}}=v_i^{\mathrm{before}}-sb_i^{\mathrm{before}}
$$


### What the property/control means

The property moves beyond the isolated target and checks **Exact call-site subtraction** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T6 positive harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T6 mutants killed; three false controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T6 positive harness family`. The admitted domain is: ML-KEM-768 registered caller slice and producer-bound domain. The recorded assumptions/grounding are: Frozen producer bounds and scoped verification adapter; production functions unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered production slice obligation is supported.

**What this record does not establish:** Not complete decryption correctness or a proof of every caller.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 20, “Caller-level exact subtraction”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-020`

- **Historical identifier:** `SUB-T6.3`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Production-slice composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 registered caller slice and producer-bound domain

- **Assumptions and grounding:** Frozen producer bounds and scoped verification adapter; production functions unchanged

- **Ledger formal relation:** after sub: v_sub[i]=v_before[i]-sb_before[i]

- **Assertion / harness mapping:** SUB-T6 positive harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T6 mutants killed; three false controls rejected

- **Strongest bounded conclusion:** The registered production slice obligation is supported.

- **Explicit exclusion:** Not complete decryption correctness or a proof of every caller.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-020`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 20, “Caller-level exact subtraction”.


</details>

---

## PR-C02-021 — Caller-frame preservation


### Formal statement

$$
(sb,\mathrm{RO},\mathrm{snapshots})_{\mathrm{after}}=(sb,\mathrm{RO},\mathrm{snapshots})_{\mathrm{before}}
$$


### What the property/control means

The property checks **Caller-frame preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T6 positive harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T6 mutants killed; three false controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T6 positive harness family`. The admitted domain is: ML-KEM-768 registered caller slice and producer-bound domain. The recorded assumptions/grounding are: Frozen producer bounds and scoped verification adapter; production functions unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered production slice obligation is supported.

**What this record does not establish:** Not complete decryption correctness or a proof of every caller.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 21, “Caller-frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-021`

- **Historical identifier:** `SUB-T6.4`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Production-slice composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 registered caller slice and producer-bound domain

- **Assumptions and grounding:** Frozen producer bounds and scoped verification adapter; production functions unchanged

- **Ledger formal relation:** sb and registered read-only/snapshot objects unchanged

- **Assertion / harness mapping:** SUB-T6 positive harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T6 mutants killed; three false controls rejected

- **Strongest bounded conclusion:** The registered production slice obligation is supported.

- **Explicit exclusion:** Not complete decryption correctness or a proof of every caller.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-021`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 21, “Caller-frame preservation”.


</details>

---

## PR-C02-022 — Subtract-reduce handoff


### Formal statement

$$
V_i^{\mathrm{red}}=\mathrm{canon}_q(V_i^{\mathrm{before}}-S_i^{\mathrm{before}})
$$


### What the property/control means

The property moves beyond the isolated target and checks **Subtract-reduce handoff** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T6 positive harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T6 mutants killed; three false controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T6 positive harness family`. The admitted domain is: ML-KEM-768 registered caller slice and producer-bound domain. The recorded assumptions/grounding are: Frozen producer bounds and scoped verification adapter; production functions unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered production slice obligation is supported.

**What this record does not establish:** Not complete decryption correctness or a proof of every caller.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 22, “Subtraction followed by reduction”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-022`

- **Historical identifier:** `SUB-T6.5`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Production-slice composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 registered caller slice and producer-bound domain

- **Assumptions and grounding:** Frozen producer bounds and scoped verification adapter; production functions unchanged

- **Ledger formal relation:** after reduce: v[i]=canon_q(v_before[i]-sb_before[i])

- **Assertion / harness mapping:** SUB-T6 positive harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T6 mutants killed; three false controls rejected

- **Strongest bounded conclusion:** The registered production slice obligation is supported.

- **Explicit exclusion:** Not complete decryption correctness or a proof of every caller.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-022`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 22, “Subtraction followed by reduction”.


</details>

---

## PR-C02-023 — tomsg precondition and const-input behaviour


### Formal statement

$$
0\le v_i^{\mathrm{reduced}}<q\quad\land\quad v^{\mathrm{after\ ToMsg}}=v^{\mathrm{before\ ToMsg}}
$$


### What the property/control means

The property moves beyond the isolated target and checks **tomsg precondition and const-input behaviour** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T6 positive harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T6 mutants killed; three false controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T6 positive harness family`. The admitted domain is: ML-KEM-768 registered caller slice and producer-bound domain. The recorded assumptions/grounding are: Frozen producer bounds and scoped verification adapter; production functions unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered production slice obligation is supported.

**What this record does not establish:** Not complete decryption correctness or a proof of every caller.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 23, “Compatibility with subsequent tomsg domain”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-023`

- **Historical identifier:** `SUB-T6.6`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Production-slice composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 registered caller slice and producer-bound domain

- **Assumptions and grounding:** Frozen producer bounds and scoped verification adapter; production functions unchanged

- **Ledger formal relation:** reduced coefficients satisfy tomsg domain; tomsg preserves polynomial input

- **Assertion / harness mapping:** SUB-T6 positive harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T6 mutants killed; three false controls rejected

- **Strongest bounded conclusion:** The registered production slice obligation is supported.

- **Explicit exclusion:** Not complete decryption correctness or a proof of every caller.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-023`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 23, “Compatibility with subsequent tomsg domain”.


</details>

---

## PR-C02-024 — Complete bounded slice safety


### Formal statement

$$
\begin{array}{rl}&\text{The registered Sub}\to\text{Reduce}\to\text{ToMsg slice satisfies}\\&\text{the enabled safety and unwinding checks.}\end{array}
$$


### What the property/control means

The property moves beyond the isolated target and checks **Complete bounded slice safety** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `SUB-T6 positive harness family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Four selected T6 mutants killed; three false controls rejected. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `SUB-T6 positive harness family`. The admitted domain is: ML-KEM-768 registered caller slice and producer-bound domain. The recorded assumptions/grounding are: Frozen producer bounds and scoped verification adapter; production functions unchanged. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The registered production slice obligation is supported.

**What this record does not establish:** Not complete decryption correctness or a proof of every caller.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary. The campaign addition is characterised at case level as: Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 24, “Bounded subtraction--reduction--message pipeline safety”. Chapter 4 uses the case-level principal synthesis in Section 4.3.2; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C02-024`

- **Historical identifier:** `SUB-T6.7`

- **Case identifier:** `2`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_sub`

- **Property class:** `Production-slice composition`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** ML-KEM-768 registered caller slice and producer-bound domain

- **Assumptions and grounding:** Frozen producer bounds and scoped verification adapter; production functions unchanged

- **Ledger formal relation:** registered sub -> reduce -> tomsg slice satisfies enabled safety/unwinding checks

- **Assertion / harness mapping:** SUB-T6 positive harness family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Four selected T6 mutants killed; three false controls rejected

- **Strongest bounded conclusion:** The registered production slice obligation is supported.

- **Explicit exclusion:** Not complete decryption correctness or a proof of every caller.

- **Evidence locator:** `LOC-C02-UA`

- **Evidence path hint:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `ALL_VERIFICATION_COMPELETED_SUMMARY_PROFESSOR_CLEANED_CODEX_RECORDED(1).zip`

- **Archive SHA-256:** `744a348bda13e3f6a8adafcca9411bd2ffb717b7fe016c2341a159a574a85389`

- **Archive evidence path:** ALL VERIFICATION COMPELETED SUMMARY/MLK_POLY_SUB_A_TO_Z_PROFESSOR_REPORT.md

- **Archive entry SHA-256:** `2a82ed51792ef4106f7e128aa876187f730ca1890963b3739a614b72b736820e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-C02-024`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 2: Polynomial Subtraction: mlk_poly_sub → item 24, “Bounded subtraction--reduction--message pipeline safety”.


</details>

---


# Case-level bounded conclusion

The campaign supports independent-oracle sub→reduce refinement, normalization compatibility, exact/modular cancellation, exact canonical-domain subtraction with tight range [-3328,3328], frame/locality/determinism and the registered production-slice obligations.

**Explicit exclusion.** Not unrestricted subtraction outside representable difference domain.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
