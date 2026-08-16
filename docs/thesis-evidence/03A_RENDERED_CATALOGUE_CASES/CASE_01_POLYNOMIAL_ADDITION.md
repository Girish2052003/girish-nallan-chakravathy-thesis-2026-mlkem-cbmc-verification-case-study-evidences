# Case 1 — Polynomial Addition

**Target:** `mlk_poly_add`
**Evidence locator:** `LOC-C01-UA`
**Chapter 4 projection:** Section 4.3.1
**Ledger records:** 51
**Formally supported subset:** 36

**Pinned source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`
**Parameter/configuration:** ML-KEM-768 primary; PA-06 additionally 512/768/1024
**Evidence completeness:** `PARTIAL`

## Verification question

Does the unchanged production addition routine realise coefficient-wise addition on its legitimate representation domains, preserve the state that is not authorised to change, and remain compatible with the production caller bounds examined by the campaign?

## Case notation and opening equations


$$
R=\operatorname{Add}(A,B)
$$


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
0\le A_i,B_i<q\;\Longrightarrow\; R_i=A_i+B_i,\qquad 0\le R_i\le2q-2
$$


$$
\operatorname{canon}_q(R_i)=\operatorname{canon}_q(A_i+B_i)
$$


$$
A_i+B_i\in\mathrm{int16}\;\Longrightarrow\;R_i=\operatorname{int32}(A_i)+\operatorname{int32}(B_i)
$$


**Recorded principal-claim wording:** PA-01 supports exact/range/modulo/frame/algebraic relations for canonical inputs; PA-02 extends exact and modulo refinement to every signed/non-canonical pair whose sum is int16_t-representable. The retained caller, parameter and alias-diagnostic properties remain separately qualified.


### Why this claim is the principal case-level synthesis

Exact addition is the semantic centre of the target; the range and modulo relations make the representation meaning explicit, while frame, algebraic, caller and cross-parameter records establish that the same value relation is not being obtained by violating object or finite-width conditions. The unrestricted signed and aliasing negatives are therefore boundary evidence, not competing principal claims.


The survival ledger assigns this synthesis to **4.3.1** and records the compression action: “RETAIN one principal claim/domain/outcome row in Chapter 4; subordinate inventory stays in repository/appendix”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The campaign worked against the pinned source `d9613cf60de3132d32475c102d8c2781d84feb34` under `ML-KEM-768 primary; PA-06 also 512/768/1024`. Its primary verification focus was: Canonical-domain exact addition, range and modulo-q relation; full signed contract-domain exact addition; frame, commutativity and identity; call-site and parameter replication. The additional or mixed evidence was: PA-03 confirmed a counterexample to unrestricted exact addition; PA-04 separated safe disjoint use from invalid/diagnostic aliasing behaviour; mutation and non-vacuity campaigns succeeded.


The retained case matrix records CBMC execution as **YES — corrected canonical run reported 0/341 failed; later PA campaigns recorded successful or expected-negative outcomes**. Claim-to-artefact mapping is `YES`; target reachability `YES`; assertion reachability `YES`; assumption feasibility `YES`; non-vacuity `YES`; mutation/control status `YES`. These fields are used together: a successful semantic assertion is not treated as self-authenticating when the admitted states, target, assertion or loop extent are not demonstrably meaningful.


**Case-level bounded conclusion:** For the frozen portable-C build and recorded domains, the selected exact-addition, range/modulo, frame and algebraic properties are supported; unrestricted signed exact addition and invalid aliasing are not supported.


**Integrity boundary:** The original repository harness was not viewed, but repository-embedded contracts and loop annotations were visible in the permitted production-source packet. The correct wording is original-harness-blind, not completely formal-artefact-blind.


The principal retained summary is `ALL VERIFICATION COMPELETED SUMMARY/(PA1- PA2) MLK_POLY_ADD_PA02_FULL_SIGNED_DOMAIN_CBMC_A_TO_Z_RECORD.md` with entry SHA-256 `d22b07c11600bbb5836268afedd6f55ce59d6a45c66b287705aae7cd72b0b310`. The case archive is `mlk_poly_add_cleanroom.zip` with SHA-256 `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`. Evidence completeness is `PARTIAL`.
 The recorded limitation is: Principal accepted and meaningful-negative claims have direct raw support; PA-02B final raw verdict, complete PA-06/PA-07 matrices and executed PA-08 results are not fully retained.



The representative artefact map contains **40** indexed records for `LOC-C01-UA`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=8, MANIFEST_OR_HASH_RECORD=8, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations.


**Necessary overlap.** Function names, q/N constants, production call and source contract facts.


**What this campaign added.** External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work.


**Why the suite is substantively distinct within the inspected corpus.** Independent property-focused harness family and additional relational, negative, caller and control obligations; original target-specific harness withheld during discovery and inspected only after freeze.


**Comparison material inspected.** `proofs/cbmc/poly_add/`, production `poly.c`/`poly.h`, PA-09 post-freeze audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Does not establish global novelty or first-ever proof.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESS_PRESENT

- **Native proof paths:** mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/proofs/cbmc/poly_add/poly_add_harness.c;mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/proofs/cbmc/poly_add/Makefile

- **Native proof entry SHA-256:** ff4c40902b23a6a30c717f9381be5d5ba65cb027ed07489311ce4720c6bb9188;0df1004d25414b9163721a6741810f9e4f73a4bbaa033ea9c8c0519c0f364686

- **Production source paths:** mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/mlkem/src/poly.c;mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native/mlkem/src/poly.h

- **Production source entry SHA-256:** f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722;f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef

- **Authoritative baseline characterisation:** Native one-call `poly_add` harness and source contract are present.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `DIRECT_SEMANTIC_SUPPORT` | `PR-C01-012`, `PR-C01-013`, `PR-C01-014`, `PR-C01-019`, `PR-C01-020`, `PR-C01-021`, `PR-C01-022`, `PR-C01-037`, `PR-C01-048` | states the core value/representation relation |

| `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT` | `PR-C01-003`, `PR-C01-004`, `PR-C01-005`, `PR-C01-006`, `PR-C01-010`, `PR-C01-011`, `PR-C01-024`, `PR-C01-026`, `PR-C01-036`, `PR-C01-047` | establishes the finite domain, range or representation in which the core relation is meaningful |

| `STATE_AND_FRAME_SUPPORT` | `PR-C01-007`, `PR-C01-008`, `PR-C01-009`, `PR-C01-015`, `PR-C01-023`, `PR-C01-027`, `PR-C01-028`, `PR-C01-030`, `PR-C01-035`, `PR-C01-045`, `PR-C01-046` | protects inputs, guards, footprints or unrelated state |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-C01-016`, `PR-C01-017` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |

| `COMPOSITION_AND_CALLER_SUPPORT` | `PR-C01-029`, `PR-C01-033`, `PR-C01-034`, `PR-C01-041`, `PR-C01-042`, `PR-C01-043`, `PR-C01-044`, `PR-C01-049`, `PR-C01-050`, `PR-C01-051` | connects the local relation to callers, sequential operations, cross-function composition or parameter replication |

| `EVIDENCE_OR_DOMAIN_CONTROL` | `PR-C01-001`, `PR-C01-002`, `PR-C01-031`, `PR-C01-032`, `PR-C01-038`, `PR-C01-039`, `PR-C01-040` | justifies the configuration, oracle, admissibility, indexing or construction without adding a theorem count |

| `BOUNDARY_NEGATIVE` | `PR-C01-018`, `PR-C01-025` | records a stronger proposition that is false and therefore limits the accepted wording |


**Survival-ledger supporting historical IDs:** `PA-01.B1`, `PA-01.B2`, `PA-01.P1`, `PA-01.P2`, `PA-01.P3`, `PA-01.P4`, `PA-01.P5A`, `PA-01.P5B`, `PA-01.P5C`, `PA-01.P6`, `PA-01.P7`, `PA-02A.P1`, `PA-02B.P2`, `PA-02B.P3`, `PA-02C.P4`, `PA-02D.P5`, `PA-02E.P6`, `PA-04A.P1`, `PA-04A.P2`, `PA-04A.P3`, `PA-04A.P4`, `PA-04A.P5`, `PA-04A.P6`, `PA05A-B1`, `PA05A-D1`, `PA05A-D2`, `PA05A-P1`, `PA05A-P2`, `PA05B-P1`, `PA05B-P2`, `PA05B-P3`, `PA05B-P4`, `PA05B-P5`, `PA05C-P1`, `PA05C-P2`, `PA05C-P3`, `PA05C-P4`, `PA05C-P5`, `PA05C-P6`, `PA05C-P7`, `PA05C-P8`, `PA-06A`, `PA-06B`, `PA-06C`


**Survival-ledger contrary/unresolved IDs:** `PA-03.N1`, `PA-04B.N1`


## Thesis-appendix projection


The compact Appendix 1 projection contains **36** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Negative, unresolved, preservation and exclusion boundaries

| Record | Category | Observed evidence | Final treatment |
|---|---|---|---|

| `NEG-C01-PA03` | `MEANINGFUL_NEGATIVE` | Expected counterexample when mathematical sum is not int16_t-representable. | Retain as a domain-boundary result; it does not refute PA-02A. |

| `NEG-C01-PA04B` | `MEANINGFUL_NEGATIVE` | Expected finite-width/conversion counterexample. | Retain as an out-of-contract aliasing diagnostic; do not authorize production aliasing. |

| `LIM-C01-PA02B` | `PARTIAL_PRESERVATION` | Harness and reporting remain, but final raw verdict marker is not fully retained. | Report property with partial-preservation qualification. |

| `LIM-C01-PA06` | `PARTIAL_PRESERVATION` | A-to-Z report records replication; complete raw matrix not retained. | Do not claim complete raw preservation of all units. |

| `LIM-C01-PA07` | `PARTIAL_PRESERVATION` | Baseline and documentation retained; complete matrix absent. | Mutation conclusion remains qualified. |

| `LIM-C01-PA08` | `PARTIAL_PRESERVATION` | Harnesses/runner retained without complete executed raw results. | Do not claim complete executed PA-08 preservation. |

| `REP-C01-PA01V1` | `SUPERSEDED_REPAIRED_FAILURE` | The first artefact did not produce a valid verification result because a required helper body was absent. | Retain as autonomous repair history; only the repaired V2 result supports the accepted PA-01 claims. |


## Assurance-layer and literature relationship

This comparison prevents repository-relative distinctness from being rewritten as global mathematical novelty. The rows below are interpretive context; implementation support still comes from the source-bound evidence for this case.

| Source/project | Relationship | Overlap | Important difference | Permitted conclusion |
|---|---|---|---|---|

| NIST FIPS 203 (2024a) | `NORMATIVE_GROUNDING` | Grounds ML-KEM operations, domains and data formats relevant to the case. | FIPS 203 is not a proof that this C implementation or generated harness is correct. | The case is specification-grounded where applicable; implementation support comes from the recorded source-bound CBMC evidence, not from the standard alone. |

| PQ Code Package / mlkem-native assurance documentation (n.d.-a; n.d.-b) | `NATIVE_ASSURANCE_CONTEXT` | Shares the exact production repository and some target contracts/harness infrastructure. | Native artefacts support different or narrower property sets and different assurance layers; the case-specific distinction is recorded in matrix 04. | Report repository-relative generated artefact/property contribution, not absence of all prior assurance. |


## Publication-state and traceability-field note

The archive-identity fields below preserve the frozen evidence package, while the public-path fields reproduce the current authoritative ledger after live repository finalization. The earlier RC2 values `UNRESOLVED_UNTIL_FINALIZER`, blank `public_evidence_sha256`, and `PENDING` are historical pre-finalization metadata and are not presented as the installed state. Public paths and hashes are reported only when the repository finalizer resolved and hash-matched them; no path or hash is inferred.

# Complete record-by-record catalogue


## PR-C01-001 — ML-KEM polynomial-degree binding


### Formal statement

$$
\mathrm{MLKEM\_N}=256
$$


### What the property/control means

This control fixes or checks part of the verification setting needed to interpret the associated semantic assertions correctly. It closes a configuration, indexing, oracle or admissibility gap without being counted as an additional functional result.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The mapping `PA-01 V2 parameter-binding assertion` is retained as a supporting control. Its reachability/feasibility fields are `YES` / `YES` and its role is to justify the surrounding verification setup, not to establish a new target-level theorem.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 parameter-binding assertion`. The admitted domain is: Frozen ML-KEM-768 portable-C build. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The harness is bound to the intended polynomial degree.

**What this record does not establish:** Configuration binding is not a functional target claim by itself.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-001`

- **Historical identifier:** `PA-01.B1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Configuration control`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Frozen ML-KEM-768 portable-C build

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** MLKEM_N = 256

- **Assertion / harness mapping:** PA-01 V2 parameter-binding assertion

- **Result:** `SUPPORTING_CONTROL`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** N/A

- **Strongest bounded conclusion:** The harness is bound to the intended polynomial degree.

- **Explicit exclusion:** Configuration binding is not a functional target claim by itself.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-002 — ML-KEM modulus binding


### Formal statement

$$
\mathrm{MLKEM\_Q}=3329
$$


### What the property/control means

This control fixes or checks part of the verification setting needed to interpret the associated semantic assertions correctly. It closes a configuration, indexing, oracle or admissibility gap without being counted as an additional functional result.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The mapping `PA-01 V2 parameter-binding assertion` is retained as a supporting control. Its reachability/feasibility fields are `YES` / `YES` and its role is to justify the surrounding verification setup, not to establish a new target-level theorem.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 parameter-binding assertion`. The admitted domain is: Frozen ML-KEM-768 portable-C build. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The harness is bound to the intended modulus.

**What this record does not establish:** Configuration binding is not a functional target claim by itself.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-002`

- **Historical identifier:** `PA-01.B2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Configuration control`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Frozen ML-KEM-768 portable-C build

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** MLKEM_Q = 3329

- **Assertion / harness mapping:** PA-01 V2 parameter-binding assertion

- **Result:** `SUPPORTING_CONTROL`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** N/A

- **Strongest bounded conclusion:** The harness is bound to the intended modulus.

- **Explicit exclusion:** Configuration binding is not a functional target claim by itself.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-003 — Exact canonical-domain coefficient addition


### Formal statement

$$
r_{i} = \operatorname{int32}(a_{i}) + \operatorname{int32}(b_{i})
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Exact canonical-domain coefficient addition**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-01 V2 semantic assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 semantic assertion family`. The admitted domain is: Canonical coefficient arrays a,b in [0,q-1]. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The production result equals the exact canonical-input sum.

**What this record does not establish:** Not the full signed/non-canonical domain; PA-02 supplies that extension.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 1, “Exact addition over canonical coefficients”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-003`

- **Historical identifier:** `PA-01.P1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Functional refinement`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Canonical coefficient arrays a,b in [0,q-1]

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** r[i] = int32(a[i]) + int32(b[i])

- **Assertion / harness mapping:** PA-01 V2 semantic assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained

- **Strongest bounded conclusion:** The production result equals the exact canonical-input sum.

- **Explicit exclusion:** Not the full signed/non-canonical domain; PA-02 supplies that extension.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 1, “Exact addition over canonical coefficients”.


</details>

---

## PR-C01-004 — Canonical-domain output lower bound


### Formal statement

$$
0 \le r_{i}
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Canonical-domain output lower bound**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-01 V2 semantic assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 semantic assertion family`. The admitted domain is: Canonical coefficient arrays a,b in [0,q-1]. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The stored canonical-input sum is non-negative.

**What this record does not establish:** Not a canonical-output claim because values may exceed q-1.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 2, “Canonical-input result lower bound”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-004`

- **Historical identifier:** `PA-01.P2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Range`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Canonical coefficient arrays a,b in [0,q-1]

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** 0 <= r[i]

- **Assertion / harness mapping:** PA-01 V2 semantic assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained

- **Strongest bounded conclusion:** The stored canonical-input sum is non-negative.

- **Explicit exclusion:** Not a canonical-output claim because values may exceed q-1.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 2, “Canonical-input result lower bound”.


</details>

---

## PR-C01-005 — Canonical-domain output upper bound


### Formal statement

$$
r_{i} \le 2\cdot q-2 = 6656
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Canonical-domain output upper bound**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-01 V2 semantic assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 semantic assertion family`. The admitted domain is: Canonical coefficient arrays a,b in [0,q-1]. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The stored canonical-input sum lies in the tight derived interval.

**What this record does not establish:** Does not assert reduction to [0,q).


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 3, “Canonical-input result upper bound”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-005`

- **Historical identifier:** `PA-01.P3`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Range`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Canonical coefficient arrays a,b in [0,q-1]

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** r[i] <= 2*q-2 = 6656

- **Assertion / harness mapping:** PA-01 V2 semantic assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained

- **Strongest bounded conclusion:** The stored canonical-input sum lies in the tight derived interval.

- **Explicit exclusion:** Does not assert reduction to [0,q).

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 3, “Canonical-input result upper bound”.


</details>

---

## PR-C01-006 — FIPS-domain modulo-q refinement


### Formal statement

$$
\mathrm{canon}_q(R_i)=\mathrm{canon}_q(A_i+B_i)
$$


### What the property/control means

The property establishes the domain, range or representation fact named **FIPS-domain modulo-q refinement**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-01 V2 semantic assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 semantic assertion family`. The admitted domain is: Canonical coefficient arrays a,b in [0,q-1]. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The unreduced stored result represents the expected element of Z_q.

**What this record does not establish:** Not a claim that r[i] itself is canonical.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 4, “Modulo-(q) refinemen”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-006`

- **Historical identifier:** `PA-01.P4`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Modular refinement`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Canonical coefficient arrays a,b in [0,q-1]

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** canon_q(r[i]) = canon_q(a[i] + b[i])

- **Assertion / harness mapping:** PA-01 V2 semantic assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained

- **Strongest bounded conclusion:** The unreduced stored result represents the expected element of Z_q.

- **Explicit exclusion:** Not a claim that r[i] itself is canonical.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 4, “Modulo-(q) refinemen”.


</details>

---

## PR-C01-007 — Left-input frame preservation


### Formal statement

$$
a^{\mathrm{after}} = a^{\mathrm{before}}
$$


### What the property/control means

The property checks **Left-input frame preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-01 V2 semantic assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 semantic assertion family`. The admitted domain is: Canonical coefficient arrays a,b in [0,q-1]. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The left read-only input is preserved.

**What this record does not establish:** Limited to the modelled input object.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 5, “Left-input preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-007`

- **Historical identifier:** `PA-01.P5A`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Canonical coefficient arrays a,b in [0,q-1]

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** a_after = a_before

- **Assertion / harness mapping:** PA-01 V2 semantic assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained

- **Strongest bounded conclusion:** The left read-only input is preserved.

- **Explicit exclusion:** Limited to the modelled input object.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 5, “Left-input preservation”.


</details>

---

## PR-C01-008 — Right-input frame preservation


### Formal statement

$$
b^{\mathrm{after}} = b^{\mathrm{before}}
$$


### What the property/control means

The property checks **Right-input frame preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-01 V2 semantic assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 semantic assertion family`. The admitted domain is: Canonical coefficient arrays a,b in [0,q-1]. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The right read-only input is preserved.

**What this record does not establish:** Limited to the modelled input object.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 6, “Right-input preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-008`

- **Historical identifier:** `PA-01.P5B`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Canonical coefficient arrays a,b in [0,q-1]

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** b_after = b_before

- **Assertion / harness mapping:** PA-01 V2 semantic assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained

- **Strongest bounded conclusion:** The right read-only input is preserved.

- **Explicit exclusion:** Limited to the modelled input object.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 6, “Right-input preservation”.


</details>

---

## PR-C01-009 — Zero-operand frame preservation


### Formal statement

$$
zero^{\mathrm{after}} = zero^{\mathrm{before}}
$$


### What the property/control means

The property checks **Zero-operand frame preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-01 V2 semantic assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 semantic assertion family`. The admitted domain is: Canonical coefficient arrays a,b in [0,q-1]. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The modelled zero operand is preserved.

**What this record does not establish:** Limited to the modelled zero object.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 7, “Zero-object preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-009`

- **Historical identifier:** `PA-01.P5C`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Canonical coefficient arrays a,b in [0,q-1]

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** zero_after = zero_before

- **Assertion / harness mapping:** PA-01 V2 semantic assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained

- **Strongest bounded conclusion:** The modelled zero operand is preserved.

- **Explicit exclusion:** Limited to the modelled zero object.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 7, “Zero-object preservation”.


</details>

---

## PR-C01-010 — Canonical-domain commutativity


### Formal statement

$$
\mathrm{Add}(A,B)=\mathrm{Add}(B,A)
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Canonical-domain commutativity**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-01 V2 semantic assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 semantic assertion family`. The admitted domain is: Canonical coefficient arrays a,b in [0,q-1]. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Two production executions commute on canonical inputs.

**What this record does not establish:** Not evidence for calls violating the production aliasing contract.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 8, “Commutativity over the registered canonical domain”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-010`

- **Historical identifier:** `PA-01.P6`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Relational`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Canonical coefficient arrays a,b in [0,q-1]

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** add(a,b) = add(b,a)

- **Assertion / harness mapping:** PA-01 V2 semantic assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained

- **Strongest bounded conclusion:** Two production executions commute on canonical inputs.

- **Explicit exclusion:** Not evidence for calls violating the production aliasing contract.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 8, “Commutativity over the registered canonical domain”.


</details>

---

## PR-C01-011 — Canonical-domain additive identity


### Formal statement

$$
\operatorname{Add}(a,0) = a
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Canonical-domain additive identity**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-01 V2 semantic assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-01 V2 semantic assertion family`. The admitted domain is: Canonical coefficient arrays a,b in [0,q-1]. The recorded assumptions/grounding are: Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Zero is an additive identity on the canonical input domain.

**What this record does not establish:** Not an unrestricted statement over invalid objects or changed builds.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 9, “Additive identity”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-011`

- **Historical identifier:** `PA-01.P7`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Relational algebraic`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Canonical coefficient arrays a,b in [0,q-1]

- **Assumptions and grounding:** Canonical ML-KEM coefficients 0 <= a[i],b[i] < q; valid separate objects; unchanged production body; complete registered unwinding.

- **Ledger formal relation:** add(a,0) = a

- **Assertion / harness mapping:** PA-01 V2 semantic assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Selected PA-07 sensitivity evidence; complete PA-07 matrix only partially retained

- **Strongest bounded conclusion:** Zero is an additive identity on the canonical input domain.

- **Explicit exclusion:** Not an unrestricted statement over invalid objects or changed builds.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 1/V2/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Archive entry SHA-256:** `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/harnesses/cleanroom_mlk_poly_add_fips_relational_harness_v2.c

- **Public evidence SHA-256:** 307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 11

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 9, “Additive identity”.


</details>

---

## PR-C01-012 — Exact signed coefficient addition


### Formal statement

$$
R_i=\mathrm{int32}(A_i)+\mathrm{int32}(B_i)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Exact signed coefficient addition** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-02A exact-signed harness assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-02A exact-signed harness assertion family`. The admitted domain is: All int16_t coefficient pairs whose mathematical sum is int16_t-representable. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Exact coefficient-wise addition for the representable signed domain.

**What this record does not establish:** Not unrestricted arithmetic beyond int16_t representability; not whole-ML-KEM correctness.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 10, “Exact signed-domain addition under representability”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-012`

- **Historical identifier:** `PA-02A.P1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Functional refinement`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** All int16_t coefficient pairs whose mathematical sum is int16_t-representable

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** r[i] = int32(a[i]) + int32(b[i])

- **Assertion / harness mapping:** PA-02A exact-signed harness assertion family

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Exact coefficient-wise addition for the representable signed domain.

- **Explicit exclusion:** Not unrestricted arithmetic beyond int16_t representability; not whole-ML-KEM correctness.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02a_mlk_poly_add_exact_signed_contract_valid_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02a_mlk_poly_add_exact_signed_contract_valid_harness.c

- **Archive entry SHA-256:** `62c787783c2b5e75014cbe975c35f72cb58b4d6fdf4a418defc1171eaa2498ec`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/historical-harnesses/pa02a_mlk_poly_add_exact_signed_contract_valid_harness.c

- **Public evidence SHA-256:** 62c787783c2b5e75014cbe975c35f72cb58b4d6fdf4a418defc1171eaa2498ec

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 4

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 10, “Exact signed-domain addition under representability”.


</details>

---

## PR-C01-013 — Modulo-q addition refinement


### Formal statement

$$
\mathrm{canon}_q(R_i)=\mathrm{canon}_q(A_i+B_i)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Modulo-q addition refinement** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_WITH_PARTIAL_PRESERVATION** and maps the proposition to `PA-02B modulo-q harness; final raw verdict not retained`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Not fully retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. The support classification is retained, but the missing subordinate raw material is disclosed separately and no absent result is reconstructed.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-02B modulo-q harness; final raw verdict not retained`. The admitted domain is: Representable signed coefficient sums. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Production result has the expected residue modulo q under the accepted domain.

**What this record does not establish:** Not a canonical-output claim; final raw PA-02B verdict is a preservation gap.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 11, “Signed-domain modulo refinement”. The same preservation qualification is also disclosed in Appendix 2. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-013`

- **Historical identifier:** `PA-02B.P2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Modular refinement`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Representable signed coefficient sums

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** canon_q(r[i]) = canon_q(a[i] + b[i])

- **Assertion / harness mapping:** PA-02B modulo-q harness; final raw verdict not retained

- **Result:** `SUPPORTED_WITH_PARTIAL_PRESERVATION`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Not fully retained

- **Strongest bounded conclusion:** Production result has the expected residue modulo q under the accepted domain.

- **Explicit exclusion:** Not a canonical-output claim; final raw PA-02B verdict is a preservation gap.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02b_mlk_poly_add_modq_refinement_contract_valid_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02b_mlk_poly_add_modq_refinement_contract_valid_harness.c

- **Archive entry SHA-256:** `99a90ed4b0971fdaeac55cc36273fcb626a090833662e2929f2ea31fb8cea055`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/historical-harnesses/pa02b_mlk_poly_add_modq_refinement_contract_valid_harness.c

- **Public evidence SHA-256:** 99a90ed4b0971fdaeac55cc36273fcb626a090833662e2929f2ea31fb8cea055

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 4

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 11, “Signed-domain modulo refinement”. The same preservation qualification is also disclosed in Appendix 2.


</details>

---

## PR-C01-014 — Canonical-residue addition compatibility


### Formal statement

$$
\mathrm{canon}_q(R_i)=\mathrm{canon}_q\!\left(\mathrm{canon}_q(A_i)+\mathrm{canon}_q(B_i)\right)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Canonical-residue addition compatibility** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_WITH_PARTIAL_PRESERVATION** and maps the proposition to `PA-02B canonical-residue assertion family`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Not fully retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. The support classification is retained, but the missing subordinate raw material is disclosed separately and no absent result is reconstructed.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-02B canonical-residue assertion family`. The admitted domain is: Representable signed coefficient sums. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Signed/non-canonical representatives refine to the expected ring-Z_q addition.

**What this record does not establish:** Does not assert r[i] itself is canonical.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 12, “Canonical-residue compatibility”. The same preservation qualification is also disclosed in Appendix 2. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-014`

- **Historical identifier:** `PA-02B.P3`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Representation refinement`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Representable signed coefficient sums

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** canon_q(r[i]) = canon_q(canon_q(a[i]) + canon_q(b[i]))

- **Assertion / harness mapping:** PA-02B canonical-residue assertion family

- **Result:** `SUPPORTED_WITH_PARTIAL_PRESERVATION`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Not fully retained

- **Strongest bounded conclusion:** Signed/non-canonical representatives refine to the expected ring-Z_q addition.

- **Explicit exclusion:** Does not assert r[i] itself is canonical.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02b_mlk_poly_add_modq_refinement_contract_valid_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02b_mlk_poly_add_modq_refinement_contract_valid_harness.c

- **Archive entry SHA-256:** `99a90ed4b0971fdaeac55cc36273fcb626a090833662e2929f2ea31fb8cea055`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/historical-harnesses/pa02b_mlk_poly_add_modq_refinement_contract_valid_harness.c

- **Public evidence SHA-256:** 99a90ed4b0971fdaeac55cc36273fcb626a090833662e2929f2ea31fb8cea055

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 4

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 12, “Canonical-residue compatibility”. The same preservation qualification is also disclosed in Appendix 2.


</details>

---

## PR-C01-015 — Read-only input and guard preservation


### Formal statement

$$
M'|_{\mathrm{protected}}=M|_{\mathrm{protected}}
$$


### What the property/control means

The property checks **Read-only input and guard preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-02C frame harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PROPERTY-DEPENDENT. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-02C frame harness`. The admitted domain is: Representable signed coefficient sums. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The modelled read-only operands and guards are preserved.

**What this record does not establish:** Does not establish a universal footprint beyond modelled objects.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 13, “Registered read-only and guard preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-015`

- **Historical identifier:** `PA-02C.P4`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Representable signed coefficient sums

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** a_after=a_before; b_after=b_before; registered guards unchanged

- **Assertion / harness mapping:** PA-02C frame harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PROPERTY-DEPENDENT

- **Strongest bounded conclusion:** The modelled read-only operands and guards are preserved.

- **Explicit exclusion:** Does not establish a universal footprint beyond modelled objects.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02c_mlk_poly_add_readonly_frame_contract_valid_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02c_mlk_poly_add_readonly_frame_contract_valid_harness.c

- **Archive entry SHA-256:** `dd47663b305d3c0c30753940a545eb35d72137309a8182fa51fdaef4f184d319`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/historical-harnesses/pa02c_mlk_poly_add_readonly_frame_contract_valid_harness.c

- **Public evidence SHA-256:** dd47663b305d3c0c30753940a545eb35d72137309a8182fa51fdaef4f184d319

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 4

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 13, “Registered read-only and guard preservation”.


</details>

---

## PR-C01-016 — Commutativity of two production executions


### Formal statement

$$
\mathrm{Add}(A,B)_i=\mathrm{Add}(B,A)_i
$$


### What the property/control means

The property checks the structural or multi-execution law **Commutativity of two production executions**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-02D commutativity harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PROPERTY-DEPENDENT. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-02D commutativity harness`. The admitted domain is: Representable signed coefficient sums for both executions. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Production executions commute under the accepted domain.

**What this record does not establish:** Not evidence for aliasing calls outside the contract.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 14, “Commutativity over the registered signed representable domain”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-016`

- **Historical identifier:** `PA-02D.P5`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Relational`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Representable signed coefficient sums for both executions

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** add(a,b)[i] = add(b,a)[i]

- **Assertion / harness mapping:** PA-02D commutativity harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PROPERTY-DEPENDENT

- **Strongest bounded conclusion:** Production executions commute under the accepted domain.

- **Explicit exclusion:** Not evidence for aliasing calls outside the contract.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02d_mlk_poly_add_commutativity_contract_valid_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02d_mlk_poly_add_commutativity_contract_valid_harness.c

- **Archive entry SHA-256:** `08569fdde0520c27c249af5d27fb2dddfc54c7bd7220855b5fa10a7a350e8746`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/historical-harnesses/pa02d_mlk_poly_add_commutativity_contract_valid_harness.c

- **Public evidence SHA-256:** 08569fdde0520c27c249af5d27fb2dddfc54c7bd7220855b5fa10a7a350e8746

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 4

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 14, “Commutativity over the registered signed representable domain”.


</details>

---

## PR-C01-017 — Additive identity


### Formal statement

$$
\operatorname{Add}(a,0)=a
$$


### What the property/control means

The property checks the structural or multi-execution law **Additive identity**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-02E identity harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PROPERTY-DEPENDENT. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-02E identity harness`. The admitted domain is: All int16_t coefficients in a; zero polynomial as second operand. The recorded assumptions/grounding are: Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Zero is an additive identity for the production operation over the encoded signed domain.

**What this record does not establish:** Not a claim about normalization or arbitrary memory aliasing.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 15, “Additive identity over the signed machine domain”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-017`

- **Historical identifier:** `PA-02E.P6`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Algebraic relational`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** All int16_t coefficients in a; zero polynomial as second operand

- **Assumptions and grounding:** Valid, separately modelled objects unless an alias diagnostic explicitly states otherwise; unchanged production target; complete registered loop unwinding.

- **Ledger formal relation:** add(a,0)=a

- **Assertion / harness mapping:** PA-02E identity harness

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PROPERTY-DEPENDENT

- **Strongest bounded conclusion:** Zero is an additive identity for the production operation over the encoded signed domain.

- **Explicit exclusion:** Not a claim about normalization or arbitrary memory aliasing.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02e_mlk_poly_add_additive_identity_full_signed_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 2/SLICED VERIFICATION/pa02e_mlk_poly_add_additive_identity_full_signed_harness.c

- **Archive entry SHA-256:** `b87e9748158b8b0a55182119fd9e32f7daa1b7ce8e7e4ed1a6d4c2dac2c4a291`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** supplementary-evidence-reconciliation/consolidated-mlkem-cbmc-verification-harnesses-12-campaigns/poly_add_harness_set/historical-harnesses/pa02e_mlk_poly_add_additive_identity_full_signed_harness.c

- **Public evidence SHA-256:** b87e9748158b8b0a55182119fd9e32f7daa1b7ce8e7e4ed1a6d4c2dac2c4a291

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 4

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 15, “Additive identity over the signed machine domain”.


</details>

---

## PR-C01-018 — Unrestricted signed exact-addition claim


### Formal statement

$$
\forall a_i,b_i\in\mathrm{int16}:\quad R_i=\mathrm{int32}(a_i)+\mathrm{int32}(b_i)
$$


### What the property/control means

This record deliberately asks whether the stronger proposition named **Unrestricted signed exact-addition claim** holds when the registered protective restriction is removed. The retained counterexample makes the proposition false in the encoded domain; the scientific value is the boundary it establishes for the neighbouring supported claim.


### Why it matters

A preserved counterexample is positive evidence about the boundary of the accepted claim: it shows exactly why the stronger wording must not be used.


### Relationship to the principal claim

**Role:** `BOUNDARY_NEGATIVE`. This record limits the principal claim. It is not support for a stronger version; it explains why the principal wording keeps the relevant domain restriction.


### Formal-support basis and evidential status

The candidate mapped by `PA-03 negative-control harness` produced the retained contrary evidence in its registered domain. The result is intentionally classified `MEANINGFUL_NEGATIVE`; it narrows the accepted claim and is not a production defect outside the applicable contract boundary.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-03 negative-control harness`. The admitted domain is: Arbitrary int16_t a,b without representability restriction. The recorded assumptions/grounding are: Deliberately removes required representability condition. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Counterexample confirms unrestricted exact-addition claim is false in the C/int16 model.

**What this record does not establish:** Does not refute the representability-qualified PA-02A claim.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 1 meaningful-negative finding 1 (PA-03). Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-018`

- **Historical identifier:** `PA-03.N1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Meaningful negative`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Arbitrary int16_t a,b without representability restriction

- **Assumptions and grounding:** Deliberately removes required representability condition

- **Ledger formal relation:** r[i] = mathematical a[i]+b[i] for all pairs

- **Assertion / harness mapping:** PA-03 negative-control harness

- **Result:** `MEANINGFUL_NEGATIVE`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** COUNTEREXAMPLE

- **Mutation status:** N/A

- **Strongest bounded conclusion:** Counterexample confirms unrestricted exact-addition claim is false in the C/int16 model.

- **Explicit exclusion:** Does not refute the representability-qualified PA-02A claim.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA3/pa03_mlk_poly_add_unrestricted_negative_control_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA3/pa03_mlk_poly_add_unrestricted_negative_control_harness.c

- **Archive entry SHA-256:** `37f9893284959fc9406d7e4bee06848b7c4e9e1cf717fe3c0d699ac5ca0f2487`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA03-unrestricted-negative-control/curated-records/pa03_mlk_poly_add_unrestricted_negative_control_harness.c

- **Public evidence SHA-256:** 37f9893284959fc9406d7e4bee06848b7c4e9e1cf717fe3c0d699ac5ca0f2487

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** Appendix 2 candidate proposition; retained counterexample makes the universal proposition false.

- **Principal-claim role:** `BOUNDARY_NEGATIVE`

- **Appendix projection:** Appendix 2 → Case 1 meaningful-negative finding 1 (PA-03)


</details>

---

## PR-C01-019 — Safe-alias exact doubling


### Formal statement

$$
R_i=2R_i^{\mathrm{before}}
$$


### What the property/control means

This supported diagnostic examines **Safe-alias exact doubling** under the explicitly registered diagnostic domain. It is useful for understanding finite-width or aliasing behaviour, but it does not enlarge the ordinary production contract unless the contract itself permits that domain.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_DIAGNOSTIC** and maps the proposition to `PA-04A alias-safe harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PROPERTY-DEPENDENT. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. Because the domain is diagnostic, the conclusion must remain separate from the ordinary production-contract guarantee.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-04A alias-safe harness`. The admitted domain is: Out-of-contract r==b diagnostic with coefficient doubling representable. The recorded assumptions/grounding are: Diagnostic only; no change to production contract. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected safe alias diagnostic behaves as stated.

**What this record does not establish:** Does not authorize aliasing in production contracts.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-019`

- **Historical identifier:** `PA-04A.P1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Aliasing diagnostic`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Out-of-contract r==b diagnostic with coefficient doubling representable

- **Assumptions and grounding:** Diagnostic only; no change to production contract

- **Ledger formal relation:** r[i]=2*before_r[i]

- **Assertion / harness mapping:** PA-04A alias-safe harness

- **Result:** `SUPPORTED_DIAGNOSTIC`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PROPERTY-DEPENDENT

- **Strongest bounded conclusion:** The selected safe alias diagnostic behaves as stated.

- **Explicit exclusion:** Does not authorize aliasing in production contracts.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Archive entry SHA-256:** `d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA04-aliasing-diagnostic/curated-records/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Public evidence SHA-256:** d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-020 — Safe-alias modulo-q doubling


### Formal statement

$$
\operatorname{canon}_q(R_i)=\operatorname{canon}_q\!\left(2R_i^{\mathrm{before}}\right)
$$


### What the property/control means

This supported diagnostic examines **Safe-alias modulo-q doubling** under the explicitly registered diagnostic domain. It is useful for understanding finite-width or aliasing behaviour, but it does not enlarge the ordinary production contract unless the contract itself permits that domain.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_DIAGNOSTIC** and maps the proposition to `PA-04A alias-safe harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PROPERTY-DEPENDENT. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. Because the domain is diagnostic, the conclusion must remain separate from the ordinary production-contract guarantee.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-04A alias-safe harness`. The admitted domain is: Out-of-contract r==b diagnostic with coefficient doubling representable. The recorded assumptions/grounding are: Diagnostic only; no change to production contract. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected safe alias diagnostic behaves as stated.

**What this record does not establish:** Does not authorize aliasing in production contracts.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-020`

- **Historical identifier:** `PA-04A.P2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Aliasing diagnostic`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Out-of-contract r==b diagnostic with coefficient doubling representable

- **Assumptions and grounding:** Diagnostic only; no change to production contract

- **Ledger formal relation:** canon_q(r[i])=canon_q(2*before_r[i])

- **Assertion / harness mapping:** PA-04A alias-safe harness

- **Result:** `SUPPORTED_DIAGNOSTIC`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PROPERTY-DEPENDENT

- **Strongest bounded conclusion:** The selected safe alias diagnostic behaves as stated.

- **Explicit exclusion:** Does not authorize aliasing in production contracts.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Archive entry SHA-256:** `d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA04-aliasing-diagnostic/curated-records/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Public evidence SHA-256:** d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-021 — Safe-alias canonical-residue compatibility


### Formal statement

$$
\operatorname{canon}_q(R_i)=\operatorname{canon}_q\!\left(2\operatorname{canon}_q(R_i^{\mathrm{before}})\right)
$$


### What the property/control means

This supported diagnostic examines **Safe-alias canonical-residue compatibility** under the explicitly registered diagnostic domain. It is useful for understanding finite-width or aliasing behaviour, but it does not enlarge the ordinary production contract unless the contract itself permits that domain.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_DIAGNOSTIC** and maps the proposition to `PA-04A alias-safe harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PROPERTY-DEPENDENT. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. Because the domain is diagnostic, the conclusion must remain separate from the ordinary production-contract guarantee.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-04A alias-safe harness`. The admitted domain is: Out-of-contract r==b diagnostic with coefficient doubling representable. The recorded assumptions/grounding are: Diagnostic only; no change to production contract. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected safe alias diagnostic behaves as stated.

**What this record does not establish:** Does not authorize aliasing in production contracts.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-021`

- **Historical identifier:** `PA-04A.P3`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Aliasing diagnostic`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Out-of-contract r==b diagnostic with coefficient doubling representable

- **Assumptions and grounding:** Diagnostic only; no change to production contract

- **Ledger formal relation:** canon_q(r[i])=canon_q(2*canon_q(before_r[i]))

- **Assertion / harness mapping:** PA-04A alias-safe harness

- **Result:** `SUPPORTED_DIAGNOSTIC`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PROPERTY-DEPENDENT

- **Strongest bounded conclusion:** The selected safe alias diagnostic behaves as stated.

- **Explicit exclusion:** Does not authorize aliasing in production contracts.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Archive entry SHA-256:** `d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA04-aliasing-diagnostic/curated-records/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Public evidence SHA-256:** d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-022 — Alias/disjoint observational equivalence


### Formal statement

$$
R^{\mathrm{alias}}=\operatorname{Add}\!\left(R^{\mathrm{before}},R^{\mathrm{before}}\right)
$$


### What the property/control means

This supported diagnostic examines **Alias/disjoint observational equivalence** under the explicitly registered diagnostic domain. It is useful for understanding finite-width or aliasing behaviour, but it does not enlarge the ordinary production contract unless the contract itself permits that domain.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_DIAGNOSTIC** and maps the proposition to `PA-04A alias-safe harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PROPERTY-DEPENDENT. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. Because the domain is diagnostic, the conclusion must remain separate from the ordinary production-contract guarantee.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-04A alias-safe harness`. The admitted domain is: Out-of-contract r==b diagnostic with coefficient doubling representable. The recorded assumptions/grounding are: Diagnostic only; no change to production contract. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected safe alias diagnostic behaves as stated.

**What this record does not establish:** Does not authorize aliasing in production contracts.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-022`

- **Historical identifier:** `PA-04A.P4`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Aliasing diagnostic`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Out-of-contract r==b diagnostic with coefficient doubling representable

- **Assumptions and grounding:** Diagnostic only; no change to production contract

- **Ledger formal relation:** alias_result = disjoint_add(before_r,before_r)

- **Assertion / harness mapping:** PA-04A alias-safe harness

- **Result:** `SUPPORTED_DIAGNOSTIC`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PROPERTY-DEPENDENT

- **Strongest bounded conclusion:** The selected safe alias diagnostic behaves as stated.

- **Explicit exclusion:** Does not authorize aliasing in production contracts.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Archive entry SHA-256:** `d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA04-aliasing-diagnostic/curated-records/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Public evidence SHA-256:** d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-023 — Reference-input frame


### Formal statement

$$
\mathrm{reference}_{\mathrm{after}}=\mathrm{reference}_{\mathrm{before}}
$$


### What the property/control means

This supported diagnostic examines **Reference-input frame** under the explicitly registered diagnostic domain. It is useful for understanding finite-width or aliasing behaviour, but it does not enlarge the ordinary production contract unless the contract itself permits that domain.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_DIAGNOSTIC** and maps the proposition to `PA-04A alias-safe harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PROPERTY-DEPENDENT. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. Because the domain is diagnostic, the conclusion must remain separate from the ordinary production-contract guarantee.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-04A alias-safe harness`. The admitted domain is: Out-of-contract r==b diagnostic with coefficient doubling representable. The recorded assumptions/grounding are: Diagnostic only; no change to production contract. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected safe alias diagnostic behaves as stated.

**What this record does not establish:** Does not authorize aliasing in production contracts.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-023`

- **Historical identifier:** `PA-04A.P5`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Aliasing diagnostic`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Out-of-contract r==b diagnostic with coefficient doubling representable

- **Assumptions and grounding:** Diagnostic only; no change to production contract

- **Ledger formal relation:** reference input remains unchanged

- **Assertion / harness mapping:** PA-04A alias-safe harness

- **Result:** `SUPPORTED_DIAGNOSTIC`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PROPERTY-DEPENDENT

- **Strongest bounded conclusion:** The selected safe alias diagnostic behaves as stated.

- **Explicit exclusion:** Does not authorize aliasing in production contracts.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Archive entry SHA-256:** `d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA04-aliasing-diagnostic/curated-records/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Public evidence SHA-256:** d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-024 — Derived safe-alias output range


### Formal statement

$$
R_i\in I_{\mathrm{double}}\subseteq\mathrm{int16\_t}\qquad\text{for the registered representable doubling domain}
$$


### What the property/control means

This supported diagnostic examines **Derived safe-alias output range** under the explicitly registered diagnostic domain. It is useful for understanding finite-width or aliasing behaviour, but it does not enlarge the ordinary production contract unless the contract itself permits that domain.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_DIAGNOSTIC** and maps the proposition to `PA-04A alias-safe harness`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PROPERTY-DEPENDENT. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. Because the domain is diagnostic, the conclusion must remain separate from the ordinary production-contract guarantee.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-04A alias-safe harness`. The admitted domain is: Out-of-contract r==b diagnostic with coefficient doubling representable. The recorded assumptions/grounding are: Diagnostic only; no change to production contract. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The selected safe alias diagnostic behaves as stated.

**What this record does not establish:** Does not authorize aliasing in production contracts.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-024`

- **Historical identifier:** `PA-04A.P6`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Aliasing diagnostic`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Out-of-contract r==b diagnostic with coefficient doubling representable

- **Assumptions and grounding:** Diagnostic only; no change to production contract

- **Ledger formal relation:** r lies in the representable doubled-input interval

- **Assertion / harness mapping:** PA-04A alias-safe harness

- **Result:** `SUPPORTED_DIAGNOSTIC`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PROPERTY-DEPENDENT

- **Strongest bounded conclusion:** The selected safe alias diagnostic behaves as stated.

- **Explicit exclusion:** Does not authorize aliasing in production contracts.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA4/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Archive entry SHA-256:** `d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA04-aliasing-diagnostic/curated-records/pa04a_mlk_poly_add_alias_safe_doubling_harness.c

- **Public evidence SHA-256:** d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-025 — Unrestricted alias-doubling claim


### Formal statement

$$
\forall R_i^{\mathrm{before}}\in\mathrm{int16}:\quad R_i=2R_i^{\mathrm{before}}
$$


### What the property/control means

This record deliberately asks whether the stronger proposition named **Unrestricted alias-doubling claim** holds when the registered protective restriction is removed. The retained counterexample makes the proposition false in the encoded domain; the scientific value is the boundary it establishes for the neighbouring supported claim.


### Why it matters

A preserved counterexample is positive evidence about the boundary of the accepted claim: it shows exactly why the stronger wording must not be used.


### Relationship to the principal claim

**Role:** `BOUNDARY_NEGATIVE`. This record limits the principal claim. It is not support for a stronger version; it explains why the principal wording keeps the relevant domain restriction.


### Formal-support basis and evidential status

The candidate mapped by `PA-04B negative-control harness` produced the retained contrary evidence in its registered domain. The result is intentionally classified `MEANINGFUL_NEGATIVE`; it narrows the accepted claim and is not a production defect outside the applicable contract boundary.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-04B negative-control harness`. The admitted domain is: Arbitrary int16_t aliased coefficients without doubling representability. The recorded assumptions/grounding are: Deliberately unrestricted diagnostic. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Unrestricted alias-doubling claim is false due to finite-width conversion/overflow boundary.

**What this record does not establish:** Does not refute PA-04A under its restricted diagnostic domain.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 2 → Case 1 meaningful-negative finding 2 (PA-04B). Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-025`

- **Historical identifier:** `PA-04B.N1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Meaningful negative`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Arbitrary int16_t aliased coefficients without doubling representability

- **Assumptions and grounding:** Deliberately unrestricted diagnostic

- **Ledger formal relation:** r[i]=2*before_r[i] for all int16_t values

- **Assertion / harness mapping:** PA-04B negative-control harness

- **Result:** `MEANINGFUL_NEGATIVE`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** COUNTEREXAMPLE

- **Mutation status:** N/A

- **Strongest bounded conclusion:** Unrestricted alias-doubling claim is false due to finite-width conversion/overflow boundary.

- **Explicit exclusion:** Does not refute PA-04A under its restricted diagnostic domain.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA4/pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA4/pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c

- **Archive entry SHA-256:** `de2e0689d3470cf992533912e6689ac223d8408967b42e8082ac46af8545e528`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA04-aliasing-diagnostic/curated-records/pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c

- **Public evidence SHA-256:** de2e0689d3470cf992533912e6689ac223d8408967b42e8082ac46af8545e528

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** Appendix 2 unrestricted alias-doubling candidate; retained counterexample makes the universal proposition false.

- **Principal-claim role:** `BOUNDARY_NEGATIVE`

- **Appendix projection:** Appendix 2 → Case 1 meaningful-negative finding 2 (PA-04B)


</details>

---

## PR-C01-026 — ML-KEM-768 parameter binding


### Formal statement

$$
\mathrm{MLKEM\_N}=256,\qquad q=3329,\qquad K=3
$$


### What the property/control means

The property establishes the domain, range or representation fact named **ML-KEM-768 parameter binding**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: MLKEM_N=256, q=3329, K=3. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 16, “ML-KEM-768 caller-parameter binding”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-026`

- **Historical identifier:** `PA05A-B1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Structural`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** MLKEM_N=256, q=3329, K=3

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** constants match frozen build

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Archive entry SHA-256:** `ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Public evidence SHA-256:** ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 16, “ML-KEM-768 caller-parameter binding”.


</details>

---

## PR-C01-027 — Vector-object separation


### Formal statement

$$
\&r\ne\&b
$$


### What the property/control means

The property checks **Vector-object separation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: r and b are distinct vector objects. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 17, “Caller-level vector-object separation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-027`

- **Historical identifier:** `PA05A-D1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Object integrity`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** r and b are distinct vector objects

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** &r != &b

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Archive entry SHA-256:** `ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Public evidence SHA-256:** ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 17, “Caller-level vector-object separation”.


</details>

---

## PR-C01-028 — Nested component separation


### Formal statement

$$
\forall j:\quad \&r.\mathrm{vec}_j\ne\&b.\mathrm{vec}_j
$$


### What the property/control means

The property checks **Nested component separation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Each nested polynomial pair is distinct. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 18, “Nested polynomial-object separation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-028`

- **Historical identifier:** `PA05A-D2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Object integrity`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Each nested polynomial pair is distinct

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** &r.vec[j] != &b.vec[j]

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Archive entry SHA-256:** `ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Public evidence SHA-256:** ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 18, “Nested polynomial-object separation”.


</details>

---

## PR-C01-029 — Exact component-wise caller result


### Formal statement

$$
R'_{j,i}=R_{j,i}+B_{j,i}
$$


### What the property/control means

The property moves beyond the isolated target and checks **Exact component-wise caller result** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: All component sums representable. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 19, “Caller-level component-wise addition”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-029`

- **Historical identifier:** `PA05A-P1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Caller functional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** All component sums representable

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** r_after[j][i]=r_before[j][i]+b_before[j][i]

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Archive entry SHA-256:** `ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Public evidence SHA-256:** ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 19, “Caller-level component-wise addition”.


</details>

---

## PR-C01-030 — Read-only vector preservation


### Formal statement

$$
b^{\mathrm{after}}=b^{\mathrm{before}}
$$


### What the property/control means

The property checks **Read-only vector preservation** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Same as PA05A. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 20, “Caller-level source preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-030`

- **Historical identifier:** `PA05A-P2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Same as PA05A

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** b_after=b_before

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Archive entry SHA-256:** `ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05a_mlk_poly_add_polyvec_production_callsite_harness.c

- **Public evidence SHA-256:** ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 20, “Caller-level source preservation”.


</details>

---

## PR-C01-031 — Inverse-NTT producer bound


### Formal statement

$$
|v_i|<8q
$$


### What the property/control means

This record captures a producer or caller guarantee needed to make the surrounding verification problem faithful to the production context. It is a premise taken from documented behaviour, not an independently established result of the target harness.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The ledger explicitly classifies this record as a documented premise. The guarantee enters the verification condition as grounding for a caller or producer domain; it is not recoded as a proved property. Mapping: `PA-05A/B/C harness property marker`.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Documented producer guarantee. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-031`

- **Historical identifier:** `PA05B-G1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Assumption grounding`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Documented producer guarantee

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** |v[i]| < 8q

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `ASSUMED_FROM_DOCUMENTED_GUARANTEE`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Archive entry SHA-256:** `8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Public evidence SHA-256:** 8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-032 — Error-polynomial producer bound


### Formal statement

$$
|epp_i|<\eta_2+1
$$


### What the property/control means

This record captures a producer or caller guarantee needed to make the surrounding verification problem faithful to the production context. It is a premise taken from documented behaviour, not an independently established result of the target harness.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The ledger explicitly classifies this record as a documented premise. The guarantee enters the verification condition as grounding for a caller or producer domain; it is not recoded as a proved property. Mapping: `PA-05A/B/C harness property marker`.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Documented producer guarantee. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-032`

- **Historical identifier:** `PA05B-G2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Assumption grounding`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Documented producer guarantee

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** |epp[i]| < eta2+1

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `ASSUMED_FROM_DOCUMENTED_GUARANTEE`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Archive entry SHA-256:** `8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Public evidence SHA-256:** 8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-033 — v+epp representability


### Formal statement

$$
\mathrm{INT16\_MIN} \le v_{i}+epp_{i} \le \mathrm{INT16\_MAX}
$$


### What the property/control means

The property moves beyond the isolated target and checks **v+epp representability** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Producer bounds above. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 21, “Producer-bounded representability”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-033`

- **Historical identifier:** `PA05B-P1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Call-site discharge`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Producer bounds above

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** INT16_MIN <= v[i]+epp[i] <= INT16_MAX

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Archive entry SHA-256:** `8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Public evidence SHA-256:** 8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 21, “Producer-bounded representability”.


</details>

---

## PR-C01-034 — Exact v+epp result


### Formal statement

$$
v_i^{\mathrm{after}}=v_i^{\mathrm{before}}+epp_i^{\mathrm{before}}
$$


### What the property/control means

The property moves beyond the isolated target and checks **Exact v+epp result** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Producer bounds above. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 22, “Producer-bounded exact addition”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-034`

- **Historical identifier:** `PA05B-P2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Caller functional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Producer bounds above

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** v_after[i]=v_before[i]+epp_before[i]

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Archive entry SHA-256:** `8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Public evidence SHA-256:** 8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 22, “Producer-bounded exact addition”.


</details>

---

## PR-C01-035 — epp frame


### Formal statement

$$
epp^{\mathrm{after}}=epp^{\mathrm{before}}
$$


### What the property/control means

The property checks **epp frame** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Producer bounds above. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 23, “Producer-object frame preservation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-035`

- **Historical identifier:** `PA05B-P3`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Producer bounds above

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** epp_after=epp_before

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Archive entry SHA-256:** `8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Public evidence SHA-256:** 8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 23, “Producer-object frame preservation”.


</details>

---

## PR-C01-036 — Derived first-call output interval


### Formal statement

$$
\begin{aligned}
&\text{v\_after lies in the derived producer-bound interval}
\end{aligned}
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Derived first-call output interval**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Producer bounds above. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 24, “Derived producer-bound interval”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-036`

- **Historical identifier:** `PA05B-P4`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Range`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Producer bounds above

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** v_after lies in the derived producer-bound interval

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Archive entry SHA-256:** `8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Public evidence SHA-256:** 8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** verbatim structural/logical relation rendered without inventing an equation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 24, “Derived producer-bound interval”.


</details>

---

## PR-C01-037 — First-call modulo-q refinement


### Formal statement

$$
\mathrm{canon}_q(R_i)=\mathrm{canon}_q(V_i+E_i)
$$


### What the property/control means

The property gives a direct semantic characterisation of **First-call modulo-q refinement** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Producer bounds above. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 25, “Producer-bounded modulo refinement”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-037`

- **Historical identifier:** `PA05B-P5`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Modular refinement`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Producer bounds above

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** canon_q(v_after[i])=canon_q(v_before[i]+epp[i])

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Archive entry SHA-256:** `8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c

- **Public evidence SHA-256:** 8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 25, “Producer-bounded modulo refinement”.


</details>

---

## PR-C01-038 — Sequential inverse-NTT producer bound


### Formal statement

$$
|v_i^{\mathrm{initial}}|<8q
$$


### What the property/control means

This record captures a producer or caller guarantee needed to make the surrounding verification problem faithful to the production context. It is a premise taken from documented behaviour, not an independently established result of the target harness.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The ledger explicitly classifies this record as a documented premise. The guarantee enters the verification condition as grounding for a caller or producer domain; it is not recoded as a proved property. Mapping: `PA-05A/B/C harness property marker`.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Documented producer guarantee. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-038`

- **Historical identifier:** `PA05C-G1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Assumption grounding`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Documented producer guarantee

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** |v_initial[i]| < 8q

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `ASSUMED_FROM_DOCUMENTED_GUARANTEE`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-039 — Sequential epp producer bound


### Formal statement

$$
|epp_i|<\eta_2+1
$$


### What the property/control means

This record captures a producer or caller guarantee needed to make the surrounding verification problem faithful to the production context. It is a premise taken from documented behaviour, not an independently established result of the target harness.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The ledger explicitly classifies this record as a documented premise. The guarantee enters the verification condition as grounding for a caller or producer domain; it is not recoded as a proved property. Mapping: `PA-05A/B/C harness property marker`.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Documented producer guarantee. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-039`

- **Historical identifier:** `PA05C-G2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Assumption grounding`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Documented producer guarantee

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** |epp[i]| < eta2+1

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `ASSUMED_FROM_DOCUMENTED_GUARANTEE`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-040 — Message-polynomial image


### Formal statement

$$
k_i\in\{0,1665\}
$$


### What the property/control means

This relation is fixed by the registered harness construction itself. Its role is to establish the intended comparison setup and prevent an invalid comparison state; it is not evidence that the production function computes a new semantic property.


### Why it matters

This record does not add another theorem count. It supports the trustworthiness of the verification condition by fixing the build/domain/oracle/construction facts on which the substantive claim depends.


### Relationship to the principal claim

**Role:** `EVIDENCE_OR_DOMAIN_CONTROL`. This record supports the conditions under which the principal claim is interpretable, but it is not itself counted as another principal semantic property.


### Formal-support basis and evidential status

The relation follows from the registered construction represented by `PA-05A/B/C harness property marker`. It is retained so the comparison setup is auditable, while the substantive semantic conclusion remains attached to the production assertions rather than to this construction invariant.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: Message bit construction. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-040`

- **Historical identifier:** `PA05C-M1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Construction invariant`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** Message bit construction

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** k[i] in {0,1665}

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED_BY_CONSTRUCTION`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `EVIDENCE_OR_DOMAIN_CONTROL`

- **Appendix projection:** Not enumerated as a supported Appendix-1 property by design; retained only in the complete evidence layer.


</details>

---

## PR-C01-041 — First-call representability


### Formal statement

$$
v_i^{\mathrm{initial}}+epp_i\in[\mathrm{INT16\_MIN},\mathrm{INT16\_MAX}]
$$


### What the property/control means

The property moves beyond the isolated target and checks **First-call representability** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: G1,G2. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 26, “First-stage sequential representability”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-041`

- **Historical identifier:** `PA05C-P1`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Call-site discharge`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** G1,G2

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** v_initial+epp is int16_t-representable

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 26, “First-stage sequential representability”.


</details>

---

## PR-C01-042 — Second-call cumulative representability


### Formal statement

$$
v_i^{\mathrm{initial}}+epp_i+k_i\in[\mathrm{INT16\_MIN},\mathrm{INT16\_MAX}]
$$


### What the property/control means

The property moves beyond the isolated target and checks **Second-call cumulative representability** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: G1,G2,M1. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 27, “Cumulative sequential representability”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-042`

- **Historical identifier:** `PA05C-P2`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Call-site discharge`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** G1,G2,M1

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** v_initial+epp+k is int16_t-representable

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 27, “Cumulative sequential representability”.


</details>

---

## PR-C01-043 — Exact first-call result


### Formal statement

$$
V_i^{\mathrm{mid}}=V_i^{\mathrm{init}}+E_i
$$


### What the property/control means

The property moves beyond the isolated target and checks **Exact first-call result** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: G1,G2. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 28, “Sequential intermediate-state relation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-043`

- **Historical identifier:** `PA05C-P3`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Caller functional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** G1,G2

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** v_mid=v_initial+epp

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 28, “Sequential intermediate-state relation”.


</details>

---

## PR-C01-044 — Exact cumulative result


### Formal statement

$$
V_i^{\mathrm{final}}=V_i^{\mathrm{init}}+E_i+K_i
$$


### What the property/control means

The property moves beyond the isolated target and checks **Exact cumulative result** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: G1,G2,M1. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 29, “Sequential final-state relation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-044`

- **Historical identifier:** `PA05C-P4`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Sequential caller functional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** G1,G2,M1

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** v_final=v_initial+epp+k

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 29, “Sequential final-state relation”.


</details>

---

## PR-C01-045 — Sequential epp frame


### Formal statement

$$
epp^{\mathrm{after}}=epp^{\mathrm{before}}
$$


### What the property/control means

The property checks **Sequential epp frame** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: G1,G2,M1. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 30, “First sequential source-frame relation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-045`

- **Historical identifier:** `PA05C-P5`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** G1,G2,M1

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** epp_after=epp_before

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 30, “First sequential source-frame relation”.


</details>

---

## PR-C01-046 — Message polynomial frame


### Formal statement

$$
k^{\mathrm{after}}=k^{\mathrm{before}}
$$


### What the property/control means

The property checks **Message polynomial frame** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: G1,G2,M1. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 31, “Second sequential source-frame relation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-046`

- **Historical identifier:** `PA05C-P6`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Frame`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** G1,G2,M1

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** k_after=k_before

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 31, “Second sequential source-frame relation”.


</details>

---

## PR-C01-047 — Cumulative output interval


### Formal statement

$$
\begin{aligned}
&\text{v\_final lies in derived cumulative interval}
\end{aligned}
$$


### What the property/control means

The property establishes the domain, range or representation fact named **Cumulative output interval**. This is what permits later equalities to be interpreted using the intended finite-width or modular representation instead of silently relying on a mathematical-integer abstraction.


### Why it matters

This closes a domain/representation loophole. It prevents the principal equality from being read outside the machine range, canonical interval, parameter configuration or representation in which the equality was actually checked.


### Relationship to the principal claim

**Role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`. Supporting premise/result for the principal claim: it establishes the finite domain, range, parameter or representation condition that makes the central relation well-typed and correctly scoped.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: G1,G2,M1. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 32, “Cumulative range under the registered caller bounds”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-047`

- **Historical identifier:** `PA05C-P7`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Range`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** G1,G2,M1

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** v_final lies in derived cumulative interval

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** verbatim structural/logical relation rendered without inventing an equation.

- **Principal-claim role:** `DOMAIN_RANGE_AND_REPRESENTATION_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 32, “Cumulative range under the registered caller bounds”.


</details>

---

## PR-C01-048 — Cumulative modulo-q refinement


### Formal statement

$$
\mathrm{canon}_q(V_i^{\mathrm{final}})=\mathrm{canon}_q(V_i^{\mathrm{init}}+E_i+K_i)
$$


### What the property/control means

The property gives a direct semantic characterisation of **Cumulative modulo-q refinement** for the unchanged production target under the registered domain. It is part of the core evidence that the concrete C computation realises the mathematical or representation relation selected for this case.


### Why it matters

This is part of the semantic core: without it, safety, reachability or range checks alone would not establish that the production computation returns the intended value or representation.


### Relationship to the principal claim

**Role:** `DIRECT_SEMANTIC_SUPPORT`. Direct semantic support for the principal claim: it states or refines the value/representation relation at the centre of the case.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `PA-05A/B/C harness property marker`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: PA-07 selected caller/target mutants; complete matrix partially retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-05A/B/C harness property marker`. The admitted domain is: G1,G2,M1. The recorded assumptions/grounding are: PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** Caller-specific obligation recorded with the stated status.

**What this record does not establish:** Not complete functional correctness of mlk_indcpa_enc or every producer.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 33, “Cumulative modulo relation”. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-048`

- **Historical identifier:** `PA05C-P8`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Modular refinement`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** G1,G2,M1

- **Assumptions and grounding:** PA-05 caller-specific source contracts; safe-sum obligations are assertions, not assumptions

- **Ledger formal relation:** canon_q(v_final)=canon_q(v_initial+epp+k)

- **Assertion / harness mapping:** PA-05A/B/C harness property marker

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** PA-07 selected caller/target mutants; complete matrix partially retained

- **Strongest bounded conclusion:** Caller-specific obligation recorded with the stated status.

- **Explicit exclusion:** Not complete functional correctness of mlk_indcpa_enc or every producer.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA 5/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Archive entry SHA-256:** `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA05-production-callsites/curated-records/pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c

- **Public evidence SHA-256:** 8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `DIRECT_SEMANTIC_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 33, “Cumulative modulo relation”.


</details>

---

## PR-C01-049 — Cross-parameter polyvec caller replication


### Formal statement

$$
\mathrm{PA05}_{512}\land\mathrm{PA05}_{768}\land\mathrm{PA05}_{1024}\qquad\text{(replication family; partial preservation)}
$$


### What the property/control means

The property moves beyond the isolated target and checks **Cross-parameter polyvec caller replication** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_WITH_PARTIAL_PRESERVATION** and maps the proposition to `PA-06A/B/C cross-parameter harnesses`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Complete 15-unit raw matrix not retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. The support classification is retained, but the missing subordinate raw material is disclosed separately and no absent result is reconstructed.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-06A/B/C cross-parameter harnesses`. The admitted domain is: ML-KEM-512/768/1024. The recorded assumptions/grounding are: Parameter-specific constants and the corresponding accepted caller domains. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The A-to-Z record reports the registered replication; only part of the complete raw matrix remains in the recovered package.

**What this record does not establish:** Do not claim complete raw preservation of all 15 units.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 34, “Cross-parameter replication of the polynomial-vector caller”. The same preservation qualification is also disclosed in Appendix 2. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-049`

- **Historical identifier:** `PA-06A`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Parameter-set replication`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** ML-KEM-512/768/1024

- **Assumptions and grounding:** Parameter-specific constants and the corresponding accepted caller domains

- **Ledger formal relation:** The PA-05 property family is re-instantiated for each registered parameter set

- **Assertion / harness mapping:** PA-06A/B/C cross-parameter harnesses

- **Result:** `SUPPORTED_WITH_PARTIAL_PRESERVATION`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Complete 15-unit raw matrix not retained

- **Strongest bounded conclusion:** The A-to-Z record reports the registered replication; only part of the complete raw matrix remains in the recovered package.

- **Explicit exclusion:** Do not claim complete raw preservation of all 15 units.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA6/pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA6/pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c

- **Archive entry SHA-256:** `0941baf262a7a15c1f8be69a6c571c2727d4ab5de0ff16d0f3a364c8e3cb2ddd`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA06-cross-parameter-replication/curated-records/pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c

- **Public evidence SHA-256:** 0941baf262a7a15c1f8be69a6c571c2727d4ab5de0ff16d0f3a364c8e3cb2ddd

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 34, “Cross-parameter replication of the polynomial-vector caller”. The same preservation qualification is also disclosed in Appendix 2.


</details>

---

## PR-C01-050 — Cross-parameter epp-call replication


### Formal statement

$$
\mathrm{PA05B}_{512}\land\mathrm{PA05B}_{768}\land\mathrm{PA05B}_{1024}\qquad\text{(replication family; partial preservation)}
$$


### What the property/control means

The property moves beyond the isolated target and checks **Cross-parameter epp-call replication** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_WITH_PARTIAL_PRESERVATION** and maps the proposition to `PA-06A/B/C cross-parameter harnesses`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Complete 15-unit raw matrix not retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. The support classification is retained, but the missing subordinate raw material is disclosed separately and no absent result is reconstructed.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-06A/B/C cross-parameter harnesses`. The admitted domain is: ML-KEM-512/768/1024. The recorded assumptions/grounding are: Parameter-specific constants and the corresponding accepted caller domains. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The A-to-Z record reports the registered replication; only part of the complete raw matrix remains in the recovered package.

**What this record does not establish:** Do not claim complete raw preservation of all 15 units.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 35, “Cross-parameter replication of the producer-bounded addition”. The same preservation qualification is also disclosed in Appendix 2. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-050`

- **Historical identifier:** `PA-06B`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Parameter-set replication`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** ML-KEM-512/768/1024

- **Assumptions and grounding:** Parameter-specific constants and the corresponding accepted caller domains

- **Ledger formal relation:** The PA-05 property family is re-instantiated for each registered parameter set

- **Assertion / harness mapping:** PA-06A/B/C cross-parameter harnesses

- **Result:** `SUPPORTED_WITH_PARTIAL_PRESERVATION`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Complete 15-unit raw matrix not retained

- **Strongest bounded conclusion:** The A-to-Z record reports the registered replication; only part of the complete raw matrix remains in the recovered package.

- **Explicit exclusion:** Do not claim complete raw preservation of all 15 units.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA6/pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA6/pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c

- **Archive entry SHA-256:** `e639524d557a13410d47ad7e1078955332a758d23fd46c1d444a7f77ba327644`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA06-cross-parameter-replication/curated-records/pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c

- **Public evidence SHA-256:** e639524d557a13410d47ad7e1078955332a758d23fd46c1d444a7f77ba327644

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 35, “Cross-parameter replication of the producer-bounded addition”. The same preservation qualification is also disclosed in Appendix 2.


</details>

---

## PR-C01-051 — Cross-parameter sequential-call replication


### Formal statement

$$
\mathrm{PA05C}_{512}\land\mathrm{PA05C}_{768}\land\mathrm{PA05C}_{1024}\qquad\text{(replication family; partial preservation)}
$$


### What the property/control means

The property moves beyond the isolated target and checks **Cross-parameter sequential-call replication** in a caller, sequential or cross-function context. Its purpose is to show that the local value relation remains meaningful when connected to the production use that motivated the record.


### Why it matters

The result matters because local correctness does not automatically compose. This record checks the bridge to a caller, a second production function, a sequential state or a parameter-set replication that would otherwise remain an assumption.


### Relationship to the principal claim

**Role:** `COMPOSITION_AND_CALLER_SUPPORT`. Composition/caller support for the principal claim: it checks that the local relation survives the relevant production context instead of assuming compositionality.


### Formal-support basis and evidential status

The ledger records **SUPPORTED_WITH_PARTIAL_PRESERVATION** and maps the proposition to `PA-06A/B/C cross-parameter harnesses`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Complete 15-unit raw matrix not retained. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness. The support classification is retained, but the missing subordinate raw material is disclosed separately and no absent result is reconstructed.


### Exact experimental obligation and admitted domain

The relation above was associated with `PA-06A/B/C cross-parameter harnesses`. The admitted domain is: ML-KEM-512/768/1024. The recorded assumptions/grounding are: Parameter-specific constants and the corresponding accepted caller domains. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The A-to-Z record reports the registered replication; only part of the complete raw matrix remains in the recovered package.

**What this record does not establish:** Do not claim complete raw preservation of all 15 units.


### Native-baseline relationship

The frozen native baseline for this case is: Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations. The campaign addition is characterised at case level as: External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 36, “Cross-parameter replication of the sequential-addition obligation”. The same preservation qualification is also disclosed in Appendix 2. Chapter 4 uses the case-level principal synthesis in Section 4.3.1; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-C01-051`

- **Historical identifier:** `PA-06C`

- **Case identifier:** `1`

- **Condition:** `UNASSISTED`

- **Target:** `mlk_poly_add`

- **Property class:** `Parameter-set replication`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768 primary; PA-06 additionally 512/768/1024

- **Input domain:** ML-KEM-512/768/1024

- **Assumptions and grounding:** Parameter-specific constants and the corresponding accepted caller domains

- **Ledger formal relation:** The PA-05 property family is re-instantiated for each registered parameter set

- **Assertion / harness mapping:** PA-06A/B/C cross-parameter harnesses

- **Result:** `SUPPORTED_WITH_PARTIAL_PRESERVATION`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Complete 15-unit raw matrix not retained

- **Strongest bounded conclusion:** The A-to-Z record reports the registered replication; only part of the complete raw matrix remains in the recovered package.

- **Explicit exclusion:** Do not claim complete raw preservation of all 15 units.

- **Evidence locator:** `LOC-C01-UA`

- **Evidence path hint:** mlk_poly_add_cleanroom/PA6/pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c

- **Evidence completeness:** `PARTIAL`

- **Archive name:** `mlk_poly_add_cleanroom.zip`

- **Archive SHA-256:** `ac9eae921e26342de0508d08c312605fede5a339b3921b065e2d56ea59c286de`

- **Archive evidence path:** mlk_poly_add_cleanroom/PA6/pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c

- **Archive entry SHA-256:** `b008285e11c0e05286338657b4529087e605a92f95f5689a0d1e279a46821b44`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/poly-add/PA06-cross-parameter-replication/curated-records/pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c

- **Public evidence SHA-256:** b008285e11c0e05286338657b4529087e605a92f95f5689a0d1e279a46821b44

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 6

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `COMPOSITION_AND_CALLER_SUPPORT`

- **Appendix projection:** Appendix 1 → Case 1: Polynomial Addition: mlk_poly_add → item 36, “Cross-parameter replication of the sequential-addition obligation”. The same preservation qualification is also disclosed in Appendix 2.


</details>

---


# Case-level bounded conclusion

PA-01 establishes exact addition, [0,2q-2] range, modulo-q refinement, frame, commutativity and identity for canonical inputs. PA-02 extends exact/modulo refinement to signed and non-canonical operand pairs whose sums are int16_t-representable.

**Explicit exclusion.** Not unrestricted arithmetic beyond int16_t representability; not whole-ML-KEM correctness.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
