# Skill-Available Addition

**Target:** `mlk_poly_add`
**Evidence locator:** `LOC-SA-ADD`
**Chapter 4 projection:** Section 4.6
**Ledger records:** 3
**Formally supported subset:** 3

**Pinned source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

Which additional multi-execution addition relations were supported in the secondary skill-available investigation?

## Case notation and opening equations


No additional case-opening equation is required beyond the common notation.


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
(x+b)-(y+b)=x-y
$$


$$
\mathop{\text{Add}}(a,b)=\mathop{\text{Add}}(\mathop{\text{Add}}(a,p),q)\quad(p+q=b)
$$


**Recorded principal-claim wording:** All nine skills invoked/outputs produced in 4/4; configuration-level inspection; Skills 2–5 positive bounded mechanical usefulness; individual incorporation/causation not demonstrable.


### Why this claim is the principal case-level synthesis

These are secondary relational additions, not replacements for the unassisted Case 1 principal claim. Their value is that they exercise different multi-execution invariants under the recorded finite-width conditions.


The survival ledger assigns this synthesis to **4.6** and records the compression action: “RETAIN staged attribution; remove repetitive skill descriptions only after table preserves them”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The principal retained summary is `MLK_POLY_ADD_SKILL ASSISTED/01_A_TO_Z_MLK_POLY_ADD_SKILL_ASSISTED.md` with entry SHA-256 `b0f1d8ef05e48196450f03baba85265f433e8c17abe09e3accd8f87af025a0cb`. The case archive is `MLK_POLY_ADD_SKILL_ASSISTED_FINAL_RUN1_CLEAN.zip` with SHA-256 `76f49c93ed02e66d9d64618d365da5e3b026b49aa0bf5cc0c01d6885cca6de59`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **22** indexed records for `LOC-SA-ADD`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=6, HARNESS=4, MANIFEST_OR_HASH_RECORD=4. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Same native addition baseline as Case 1.


**Necessary overlap.** Same function/constants/call.


**What this campaign added.** Translation/equality and disjoint-support multi-execution relations.


**Why the suite is substantively distinct within the inspected corpus.** Different relational candidate focus from both native harness and unassisted suite.


**Comparison material inspected.** Skilled distinctness JSON and native audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. No causal attribution to any individual skill.


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

| `STATE_AND_FRAME_SUPPORT` | `PR-SA-ADD-002` | protects inputs, guards, footprints or unrelated state |

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-SA-ADD-001`, `PR-SA-ADD-003` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `SA-ADD-T1.P1`, `SA-ADD-T1.P2`, `SA-ADD-T2.P1`, `SA-SUB-T1.P1`, `SA-SUB-T2.P1`, `SA-BR-T1.P1`, `SA-BR-T1.P2`, `SA-BR-T2.P1`, `SA-ZERO-T1.P1`, `SA-ZERO-T2.P1`


**Survival-ledger contrary/unresolved IDs:** `LIM-RQ2-ATTR`, `LIM-RQ2-EFF`


## Thesis-appendix projection


The compact Appendix 1 projection contains **3** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Publication-state and traceability-field note

The record blocks below preserve the frozen RC2 public-path fields only as explicitly labelled historical provenance. Their former `PENDING`, `UNRESOLVED_UNTIL_FINALIZER`, blank public-SHA and candidate-count values describe the pre-finalization snapshot; they do **not** describe the current repository. The current authoritative ledger records all 257 substantive records as `RESOLVED_HASH_MATCH` and supplies the exact current public path and SHA-256. To avoid creating a second mutable authority, this catalogue points each record back to its current ledger row instead of copying those current path/hash strings into prose.

Scientific outcome status is independent. Supported, negative, abstraction-limited, resource-limited, diagnostic, construction and preservation classifications are reproduced unchanged.

# Complete record-by-record catalogue


## PR-SA-ADD-001 — Common-addend difference invariance


### Formal statement

$$
(x+b)-(y+b)=x-y
$$


### What the property/control means

The property checks the structural or multi-execution law **Common-addend difference invariance**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: Representable signed sums for both production executions. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same native addition baseline as Case 1. The campaign addition is characterised at case level as: Translation/equality and disjoint-support multi-execution relations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Addition → item 1, “Common-addend difference invariance”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-ADD-001`

- **Historical identifier:** `SA-ADD-T1.P1`

- **Case identifier:** `SA-ADD`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_poly_add`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Representable signed sums for both production executions

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** (x+b)-(y+b)=x-y

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-ADD`

- **Evidence path hint:** MLK_POLY_ADD_SKILL ASSISTED/01_A_TO_Z_MLK_POLY_ADD_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_POLY_ADD_SKILL_ASSISTED_FINAL_RUN1_CLEAN.zip`

- **Archive SHA-256:** `76f49c93ed02e66d9d64618d365da5e3b026b49aa0bf5cc0c01d6885cca6de59`

- **Archive evidence path:** MLK_POLY_ADD_SKILL ASSISTED/01_A_TO_Z_MLK_POLY_ADD_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `b0f1d8ef05e48196450f03baba85265f433e8c17abe09e3accd8f87af025a0cb`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-SA-ADD-001`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Skill-Available Addition → item 1, “Common-addend difference invariance”.


</details>

---

## PR-SA-ADD-002 — Equality preservation and reflection


### Formal statement

$$
x=y \Longleftrightarrow \mathop{\text{Add}}(x,b)=\mathop{\text{Add}}(y,b)
$$


### What the property/control means

The property checks **Equality preservation and reflection** as a state relation, not merely as a value calculation. It establishes that the part of memory or the input object named by the record remains unchanged, or that the observed access footprint stays inside the registered region.


### Why it matters

Output correctness is not enough if the call can corrupt an input, guard or unrelated region. This record therefore protects the state boundary required for a meaningful function-level claim.


### Relationship to the principal claim

**Role:** `STATE_AND_FRAME_SUPPORT`. State-boundary support for the principal claim: it shows that the accepted value relation is not accompanied by an unauthorised state change or footprint expansion.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: Same domain as T1.P1. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same native addition baseline as Case 1. The campaign addition is characterised at case level as: Translation/equality and disjoint-support multi-execution relations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Addition → item 2, “Equality preservation and reflection under common addition”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-ADD-002`

- **Historical identifier:** `SA-ADD-T1.P2`

- **Case identifier:** `SA-ADD`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_poly_add`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Same domain as T1.P1

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** x=y iff add(x,b)=add(y,b)

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-ADD`

- **Evidence path hint:** MLK_POLY_ADD_SKILL ASSISTED/01_A_TO_Z_MLK_POLY_ADD_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_POLY_ADD_SKILL_ASSISTED_FINAL_RUN1_CLEAN.zip`

- **Archive SHA-256:** `76f49c93ed02e66d9d64618d365da5e3b026b49aa0bf5cc0c01d6885cca6de59`

- **Archive evidence path:** MLK_POLY_ADD_SKILL ASSISTED/01_A_TO_Z_MLK_POLY_ADD_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `b0f1d8ef05e48196450f03baba85265f433e8c17abe09e3accd8f87af025a0cb`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-SA-ADD-002`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `STATE_AND_FRAME_SUPPORT`

- **Appendix projection:** Appendix 1 → Skill-Available Addition → item 2, “Equality preservation and reflection under common addition”.


</details>

---

## PR-SA-ADD-003 — Disjoint-support sequential decomposition


### Formal statement

$$
\mathrm{Add}(a,b)=\mathrm{Add}(\mathrm{Add}(a,p),q)
$$


### What the property/control means

The property checks the structural or multi-execution law **Disjoint-support sequential decomposition**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: All intermediate sums representable. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same native addition baseline as Case 1. The campaign addition is characterised at case level as: Translation/equality and disjoint-support multi-execution relations. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Addition → item 3, “Disjoint-support decomposition”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-ADD-003`

- **Historical identifier:** `SA-ADD-T2.P1`

- **Case identifier:** `SA-ADD`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_poly_add`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** All intermediate sums representable

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** add(a,b)=add(add(a,p),q) where p+q=b and supports are disjoint

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-ADD`

- **Evidence path hint:** MLK_POLY_ADD_SKILL ASSISTED/01_A_TO_Z_MLK_POLY_ADD_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_POLY_ADD_SKILL_ASSISTED_FINAL_RUN1_CLEAN.zip`

- **Archive SHA-256:** `76f49c93ed02e66d9d64618d365da5e3b026b49aa0bf5cc0c01d6885cca6de59`

- **Archive evidence path:** MLK_POLY_ADD_SKILL ASSISTED/01_A_TO_Z_MLK_POLY_ADD_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `b0f1d8ef05e48196450f03baba85265f433e8c17abe09e3accd8f87af025a0cb`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Historical RC2 resolved public evidence path:** UNRESOLVED_UNTIL_FINALIZER

- **Historical RC2 public evidence SHA-256:** [not populated in the frozen RC2 source ledger]

- **Historical RC2 public path resolution status:** `PENDING`

- **Historical RC2 public path candidate count:** 0

- **Current public path resolution status:** `RESOLVED_HASH_MATCH`

- **Current public path/hash authority:** `02_COMPLETE_PROPERTY_LEDGER.csv` row `PR-SA-ADD-003`; the installed validator checks the current resolved path/SHA state against the live repository rather than duplicating mutable path/hash strings here.

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Skill-Available Addition → item 3, “Disjoint-support decomposition”.


</details>

---


# Case-level bounded conclusion

Common-addend translation/equality relations and disjoint-support decomposition are supported under the recorded ML-KEM-768 finite-width domains.

**Explicit exclusion.** This exploratory skill-available investigation is not a causal or efficiency claim and does not replace the unassisted Case-1 result.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
