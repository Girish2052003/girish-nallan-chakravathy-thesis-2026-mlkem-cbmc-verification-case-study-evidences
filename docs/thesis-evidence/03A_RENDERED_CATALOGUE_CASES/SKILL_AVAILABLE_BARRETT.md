# Skill-Available Barrett Reduction

**Target:** `mlk_barrett_reduce`
**Evidence locator:** `LOC-SA-BR`
**Chapter 4 projection:** Section 4.6
**Ledger records:** 3
**Formally supported subset:** 3

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768 build
**Evidence completeness:** `COMPLETE`

## Verification question

Which additional relational and compositional Barrett laws were supported in the secondary skill-available investigation?

## Case notation and opening equations


No additional case-opening equation is required beyond the common notation.


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
R(-a)=-R(a)
$$


$$
R(R(a)+R(b))=\operatorname{Centered}_q(a+b)
$$


**Recorded principal-claim wording:** All nine skills invoked/outputs produced in 4/4; configuration-level inspection; Skills 2–5 positive bounded mechanical usefulness; individual incorporation/causation not demonstrable.


### Why this claim is the principal case-level synthesis

The secondary properties strengthen algebraic behaviour around the already established Barrett function. They do not alter the unassisted full-domain oracle claim and cannot be used as a causal efficiency comparison.


The survival ledger assigns this synthesis to **4.6** and records the compression action: “RETAIN staged attribution; remove repetitive skill descriptions only after table preserves them”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The principal retained summary is `MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md` with entry SHA-256 `062a5c6f757242843af148b9131561fde9696489183758d08fe5931117662128`. The case archive is `MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06.zip` with SHA-256 `836b7c5379eae8cf2fd1238aa3092d87c1baf2ea489b90109b30fb1ca76be233`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **31** indexed records for `LOC-SA-BR`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=4, MANIFEST_OR_HASH_RECORD=3, RAW_RESULT=8. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Same native Barrett baseline as Case 8.


**Necessary overlap.** Same function/q/centered semantics.


**What this campaign added.** Sign conjugacy/quotient reversal and centered-addition closure.


**Why the suite is substantively distinct within the inspected corpus.** Relational properties are not the native range-only harness, although the unassisted campaign is deeper overall.


**Comparison material inspected.** Skilled repository-distinctness JSON and native audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. Incremental benefit and skill causation remain inconclusive.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** DEDICATED_ONE_CALL_HARNESS_PRESENT

- **Native proof paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/barrett_reduce/barrett_reduce_harness.c;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/proofs/cbmc/barrett_reduce/Makefile

- **Native proof entry SHA-256:** 2257c68f1412b9b4a4a66b7bd5c178d87dd0d571ad1a487df4392ce1c84b20dc;60b43149f1fa523659a5d5fc55b1ecdf6d2f44f0c2988f8903b699bbf3e23672

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/poly.c

- **Production source entry SHA-256:** f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722

- **Authoritative baseline characterisation:** A dedicated native one-call Barrett harness exists.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-SA-BR-001`, `PR-SA-BR-002`, `PR-SA-BR-003` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `SA-ADD-T1.P1`, `SA-ADD-T1.P2`, `SA-ADD-T2.P1`, `SA-SUB-T1.P1`, `SA-SUB-T2.P1`, `SA-BR-T1.P1`, `SA-BR-T1.P2`, `SA-BR-T2.P1`, `SA-ZERO-T1.P1`, `SA-ZERO-T2.P1`


**Survival-ledger contrary/unresolved IDs:** `LIM-RQ2-ATTR`, `LIM-RQ2-EFF`


## Thesis-appendix projection


The compact Appendix 1 projection contains **3** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Publication-state and traceability-field note

The archive-identity fields below preserve the frozen evidence package, while the public-path fields reproduce the current authoritative ledger after live repository finalization. The earlier RC2 values `UNRESOLVED_UNTIL_FINALIZER`, blank `public_evidence_sha256`, and `PENDING` are historical pre-finalization metadata and are not presented as the installed state. Public paths and hashes are reported only when the repository finalizer resolved and hash-matched them; no path or hash is inferred.

# Complete record-by-record catalogue


## PR-SA-BR-001 — Sign conjugacy


### Formal statement

$$
R(-a)=-R(a)
$$


### What the property/control means

The property checks the structural or multi-execution law **Sign conjugacy**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: a in int16_t except INT16_MIN. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same native Barrett baseline as Case 8. The campaign addition is characterised at case level as: Sign conjugacy/quotient reversal and centered-addition closure. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Barrett Reduction → item 1, “Sign conjugacy”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-BR-001`

- **Historical identifier:** `SA-BR-T1.P1`

- **Case identifier:** `SA-BR`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in int16_t except INT16_MIN

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** R(-a)=-R(a)

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-BR`

- **Evidence path hint:** MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06.zip`

- **Archive SHA-256:** `836b7c5379eae8cf2fd1238aa3092d87c1baf2ea489b90109b30fb1ca76be233`

- **Archive evidence path:** MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `062a5c6f757242843af148b9131561fde9696489183758d08fe5931117662128`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/Skill-Assisted-codex-flows/MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md

- **Public evidence SHA-256:** 062a5c6f757242843af148b9131561fde9696489183758d08fe5931117662128

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** direct rendering of ledger relation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Skill-Available Barrett Reduction → item 1, “Sign conjugacy”.


</details>

---

## PR-SA-BR-002 — Quotient reversal


### Formal statement

$$
t(-a)=-t(a)
$$


### What the property/control means

The property checks the structural or multi-execution law **Quotient reversal**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: a in int16_t except INT16_MIN. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same native Barrett baseline as Case 8. The campaign addition is characterised at case level as: Sign conjugacy/quotient reversal and centered-addition closure. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Barrett Reduction → item 2, “Quotient reversal”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-BR-002`

- **Historical identifier:** `SA-BR-T1.P2`

- **Case identifier:** `SA-BR`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** a in int16_t except INT16_MIN

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** registered quotient witness changes sign under a -> -a

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-BR`

- **Evidence path hint:** MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06.zip`

- **Archive SHA-256:** `836b7c5379eae8cf2fd1238aa3092d87c1baf2ea489b90109b30fb1ca76be233`

- **Archive evidence path:** MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `062a5c6f757242843af148b9131561fde9696489183758d08fe5931117662128`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/Skill-Assisted-codex-flows/MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md

- **Public evidence SHA-256:** 062a5c6f757242843af148b9131561fde9696489183758d08fe5931117662128

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Skill-Available Barrett Reduction → item 2, “Quotient reversal”.


</details>

---

## PR-SA-BR-003 — Centered-addition closure with one correction


### Formal statement

$$
\mathrm{R}(\mathrm{R}(a)+\mathrm{R}(b))=\mathrm{Centered}_q(a+b),\qquad \mathrm{R}(a)+\mathrm{R}(b)-\mathrm{R}(\mathrm{R}(a)+\mathrm{R}(b))\in\{-q,0,q\}
$$


### What the property/control means

The property checks the structural or multi-execution law **Centered-addition closure with one correction**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: Arbitrary int16_t a,b; no substantive assumptions. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same native Barrett baseline as Case 8. The campaign addition is characterised at case level as: Sign conjugacy/quotient reversal and centered-addition closure. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Barrett Reduction → item 3, “Centred-addition closure with one correction”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-BR-003`

- **Historical identifier:** `SA-BR-T2.P1`

- **Case identifier:** `SA-BR`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_barrett_reduce`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build

- **Input domain:** Arbitrary int16_t a,b; no substantive assumptions

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** R(R(a)+R(b)) equals centered oracle of a+b and uses one correction in {-q,0,q}

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-BR`

- **Evidence path hint:** MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06.zip`

- **Archive SHA-256:** `836b7c5379eae8cf2fd1238aa3092d87c1baf2ea489b90109b30fb1ca76be233`

- **Archive evidence path:** MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `062a5c6f757242843af148b9131561fde9696489183758d08fe5931117662128`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/Skill-Assisted-codex-flows/MLK_BARRET_REDUCE_SKILL_ASSISTED_CLEAN_SUCCESS_2026-08-06/01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md

- **Public evidence SHA-256:** 062a5c6f757242843af148b9131561fde9696489183758d08fe5931117662128

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Skill-Available Barrett Reduction → item 3, “Centred-addition closure with one correction”.


</details>

---


# Case-level bounded conclusion

Sign conjugacy, quotient reversal and centred-addition closure with one correction are supported under the recorded harness domains.

**Explicit exclusion.** The result does not establish unrestricted algebra beyond the admitted int16_t / widened-sum semantics and does not measure skill effectiveness.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
