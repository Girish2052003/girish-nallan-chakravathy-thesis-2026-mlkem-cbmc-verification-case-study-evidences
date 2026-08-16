# Skill-Available Subtraction

**Target:** `mlk_poly_sub`
**Evidence locator:** `LOC-SA-SUB`
**Chapter 4 projection:** Section 4.6
**Ledger records:** 2
**Formally supported subset:** 2

**Pinned source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`
**Parameter/configuration:** ML-KEM-768
**Evidence completeness:** `COMPLETE`

## Verification question

Which additional relational subtraction laws were supported in the secondary skill-available investigation?

## Case notation and opening equations


No additional case-opening equation is required beyond the common notation.


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
\operatorname{Sub}(a,b)-\operatorname{Sub}(a,c)=c-b
$$


$$
\operatorname{Sub}(\operatorname{Sub}(a,b),c)=\operatorname{Sub}(a,b+c)
$$


**Recorded principal-claim wording:** All nine skills invoked/outputs produced in 4/4; configuration-level inspection; Skills 2–5 positive bounded mechanical usefulness; individual incorporation/causation not demonstrable.


### Why this claim is the principal case-level synthesis

These relations are complementary multi-call laws. They are kept separate from the unassisted subtraction case because the secondary investigation had a different experimental condition and did not redefine the principal Case 2 result.


The survival ledger assigns this synthesis to **4.6** and records the compression action: “RETAIN staged attribution; remove repetitive skill descriptions only after table preserves them”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The principal retained summary is `MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1/01_A_TO_Z_MLK_POLY_SUB_SKILL_ASSISTED.md` with entry SHA-256 `3476ddea5244bae9c13d93da155316a64b7a68e9ca827f83fbc61ce0cd3b6264`. The case archive is `MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1.zip` with SHA-256 `c3fa7e243a7a55515834cdda2336d3f1013d50a35c4bba7c6ddcb21658c8570b`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **23** indexed records for `LOC-SA-SUB`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=4, MANIFEST_OR_HASH_RECORD=3. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Same native subtraction baseline as Case 2.


**Necessary overlap.** Same function/constants/call.


**What this campaign added.** Common-minuend reversal and sequential subtrahend aggregation.


**Why the suite is substantively distinct within the inspected corpus.** Different multi-call relations from native and unassisted families.


**Comparison material inspected.** Skilled distinctness JSON and native audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. No causal attribution to any individual skill.


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

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-SA-SUB-001`, `PR-SA-SUB-002` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `SA-ADD-T1.P1`, `SA-ADD-T1.P2`, `SA-ADD-T2.P1`, `SA-SUB-T1.P1`, `SA-SUB-T2.P1`, `SA-BR-T1.P1`, `SA-BR-T1.P2`, `SA-BR-T2.P1`, `SA-ZERO-T1.P1`, `SA-ZERO-T2.P1`


**Survival-ledger contrary/unresolved IDs:** `LIM-RQ2-ATTR`, `LIM-RQ2-EFF`


## Thesis-appendix projection


The compact Appendix 1 projection contains **2** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Publication-state and traceability-field note

The archive-identity fields below preserve the frozen evidence package, while the public-path fields reproduce the current authoritative ledger after live repository finalization. The earlier RC2 values `UNRESOLVED_UNTIL_FINALIZER`, blank `public_evidence_sha256`, and `PENDING` are historical pre-finalization metadata and are not presented as the installed state. Public paths and hashes are reported only when the repository finalizer resolved and hash-matched them; no path or hash is inferred.

# Complete record-by-record catalogue


## PR-SA-SUB-001 — Common-minuend difference reversal


### Formal statement

$$
\mathrm{Sub}(a,b)-\mathrm{Sub}(a,c)=c-b
$$


### What the property/control means

The property checks the structural or multi-execution law **Common-minuend difference reversal**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: Registered representability for four calls. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same native subtraction baseline as Case 2. The campaign addition is characterised at case level as: Common-minuend reversal and sequential subtrahend aggregation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Subtraction → item 1, “Difference reversal”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-SUB-001`

- **Historical identifier:** `SA-SUB-T1.P1`

- **Case identifier:** `SA-SUB`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_poly_sub`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Registered representability for four calls

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** sub(a,b)-sub(a,c)=c-b

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-SUB`

- **Evidence path hint:** MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1/01_A_TO_Z_MLK_POLY_SUB_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1.zip`

- **Archive SHA-256:** `c3fa7e243a7a55515834cdda2336d3f1013d50a35c4bba7c6ddcb21658c8570b`

- **Archive evidence path:** MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1/01_A_TO_Z_MLK_POLY_SUB_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `3476ddea5244bae9c13d93da155316a64b7a68e9ca827f83fbc61ce0cd3b6264`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/Skill-Assisted-codex-flows/MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1/01_A_TO_Z_MLK_POLY_SUB_SKILL_ASSISTED.md

- **Public evidence SHA-256:** 3476ddea5244bae9c13d93da155316a64b7a68e9ca827f83fbc61ce0cd3b6264

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Skill-Available Subtraction → item 1, “Difference reversal”.


</details>

---

## PR-SA-SUB-002 — Sequential subtrahend aggregation


### Formal statement

$$
\mathrm{Sub}(\mathrm{Sub}(a,b),c)=\mathrm{Sub}(a,b+c)
$$


### What the property/control means

The property checks the structural or multi-execution law **Sequential subtrahend aggregation**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: Registered representability; harness aggregate b+c. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same native subtraction baseline as Case 2. The campaign addition is characterised at case level as: Common-minuend reversal and sequential subtrahend aggregation. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Subtraction → item 2, “Sequential subtraction aggregation”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-SUB-002`

- **Historical identifier:** `SA-SUB-T2.P1`

- **Case identifier:** `SA-SUB`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_poly_sub`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `d9613cf60de3132d32475c102d8c2781d84feb34`

- **Parameter set:** ML-KEM-768

- **Input domain:** Registered representability; harness aggregate b+c

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** sub(sub(a,b),c)=sub(a,b+c)

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-SUB`

- **Evidence path hint:** MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1/01_A_TO_Z_MLK_POLY_SUB_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1.zip`

- **Archive SHA-256:** `c3fa7e243a7a55515834cdda2336d3f1013d50a35c4bba7c6ddcb21658c8570b`

- **Archive evidence path:** MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1/01_A_TO_Z_MLK_POLY_SUB_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `3476ddea5244bae9c13d93da155316a64b7a68e9ca827f83fbc61ce0cd3b6264`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/Skill-Assisted-codex-flows/MLK_POLY_SUB_SKILL_ASSISTED_RECOVERED_VALIDATED_RUN1/01_A_TO_Z_MLK_POLY_SUB_SKILL_ASSISTED.md

- **Public evidence SHA-256:** 3476ddea5244bae9c13d93da155316a64b7a68e9ca827f83fbc61ce0cd3b6264

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Skill-Available Subtraction → item 2, “Sequential subtraction aggregation”.


</details>

---


# Case-level bounded conclusion

The difference-reversal and sequential-subtraction aggregation relations are supported under their recorded representability domains.

**Explicit exclusion.** The result is bounded to the registered finite-width domains and does not establish unrestricted subtraction algebra.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
