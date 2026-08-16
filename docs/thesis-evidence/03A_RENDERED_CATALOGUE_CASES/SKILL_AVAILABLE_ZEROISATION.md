# Skill-Available Zeroisation

**Target:** `mlk_zeroize`
**Evidence locator:** `LOC-SA-ZERO`
**Chapter 4 projection:** Section 4.6
**Ledger records:** 2
**Formally supported subset:** 2

**Pinned source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`
**Parameter/configuration:** ML-KEM-768 build; bounded objects
**Evidence completeness:** `COMPLETE`

## Verification question

Which additional relational zeroisation histories were supported in the secondary skill-available investigation?

## Case notation and opening equations


No additional case-opening equation is required beyond the common notation.


These definitions are the expanded repository counterpart of the concise notation used before the supported-property list in the thesis appendix. They define symbols; they are not additional theorem counts.


## Principal bounded claim used in Chapter 4


$$
Z_I(M_1)|_I=Z_I(M_2)|_I=0
$$


$$
\varnothing\ne J\subseteq I\;\Longrightarrow\;M_{\mathrm{final}}|_I=0
$$


**Recorded principal-claim wording:** All nine skills invoked/outputs produced in 4/4; configuration-level inspection; Skills 2–5 positive bounded mechanical usefulness; individual incorporation/causation not demonstrable.


### Why this claim is the principal case-level synthesis

The secondary relations ask history-sensitive questions that are not needed to state the core Case 9 wipe/frame result. They are retained as complementary relational evidence under the skill-available condition.


The survival ledger assigns this synthesis to **4.6** and records the compression action: “RETAIN staged attribution; remove repetitive skill descriptions only after table preserves them”. That rule is why subordinate records remain fully visible here even though Chapter 4 uses a single compact case statement.


## How the experiment was conducted and why the result is admissible


The principal retained summary is `MLK_POLY_Zerorize_SKILL ASSISTED/01_A_TO_Z_MLK_ZEROIZE_SKILL_ASSISTED.md` with entry SHA-256 `7305653d80e9d545330e19e14212bef6cb56cf742c0e0b43a392e75a19b58c68`. The case archive is `MLK_POLY_Zerorize_SKILL_ASSISTED_EXECUTED_AF4C5ABD_RUN1_CLEAN.zip` with SHA-256 `c3cccffc859c3975acaf3e4d87f995ebf6257a5019c5d80f71ea80a662f33fe6`. Evidence completeness is `COMPLETE`.



The representative artefact map contains **24** indexed records for `LOC-SA-ZERO`: COMMAND_OR_RUNNER=8, COVERAGE_MUTATION_OR_CONTROL=8, HARNESS=4, MANIFEST_OR_HASH_RECORD=4. The full path-and-hash inventory remains authoritative in `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`; it is referenced rather than duplicated here so that raw evidence identity remains single-sourced.


## Frozen native baseline, overlap and added assurance


**What the frozen native repository already contained.** Same corrected native baseline as Case 9: production zeroize source/contracts exist, but no dedicated eponymous native `proofs/cbmc/zeroize/` directory exists.


**Necessary overlap.** Same target and memory model.


**What this campaign added.** Secret-history convergence and recontamination recovery.


**Why the suite is substantively distinct within the inspected corpus.** Additional relational/compositional memory histories.


**Comparison material inspected.** Skilled repository-distinctness JSON and native audit.


**Permitted distinctness conclusion:** `SUPPORTED_WITHIN_INSPECTED_CORPUS`. No causal attribution to any individual skill.


<details>
<summary><strong>Archive-verified native baseline census</strong></summary>


- **Native proof-directory status:** NO_DEDICATED_ZEROIZE_PROOF_DIRECTORY

- **Production source paths:** mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/verify.h;mlk_barrett_reduce_cleanroom/BR_AF4_00A_af4c5abd/mlkem/src/common.h

- **Production source entry SHA-256:** 13f44749f65099bee5bc55be260932d5e832bbd091335f1e47c31df464c1881f;cc48998e9595ec4e59a3aa53d6be9e55ecccb3cdc047e661ccd94fa99955d675

- **Authoritative baseline characterisation:** Production zeroize source/contracts and release macros exist; no dedicated native `proofs/cbmc/zeroize/` directory exists.

- **Conflict resolution:** NONE

- **Archive validation:** RESOLVED_AND_HASHED


</details>


## How the record families support or limit the principal claim


| Role in the case argument | Records | Why it exists |
|---|---|---|

| `RELATIONAL_OR_STRUCTURAL_STRENGTHENING` | `PR-SA-ZERO-001`, `PR-SA-ZERO-002` | adds locality, algebraic, idempotence, fibre, metric or multi-execution structure |


**Survival-ledger supporting historical IDs:** `SA-ADD-T1.P1`, `SA-ADD-T1.P2`, `SA-ADD-T2.P1`, `SA-SUB-T1.P1`, `SA-SUB-T2.P1`, `SA-BR-T1.P1`, `SA-BR-T1.P2`, `SA-BR-T2.P1`, `SA-ZERO-T1.P1`, `SA-ZERO-T2.P1`


**Survival-ledger contrary/unresolved IDs:** `LIM-RQ2-ATTR`, `LIM-RQ2-EFF`


## Thesis-appendix projection


The compact Appendix 1 projection contains **2** supported records from this investigation. The detailed records below state the exact Appendix-1 item for every supported property. Controls, guarantees, construction invariants and diagnostics remain repository-only unless the appendix needs them to explain a limitation. Negative/inconclusive records are mapped to Appendix 2 where applicable.


## Publication-state and traceability-field note

The archive-identity fields below preserve the frozen evidence package, while the public-path fields reproduce the current authoritative ledger after live repository finalization. The earlier RC2 values `UNRESOLVED_UNTIL_FINALIZER`, blank `public_evidence_sha256`, and `PENDING` are historical pre-finalization metadata and are not presented as the installed state. Public paths and hashes are reported only when the repository finalizer resolved and hash-matched them; no path or hash is inferred.

# Complete record-by-record catalogue


## PR-SA-ZERO-001 — Secret-history convergence after whole-object wipe


### Formal statement

$$
Z_I(M_1)|_I=Z_I(M_2)|_I=0
$$


### What the property/control means

The property checks the structural or multi-execution law **Secret-history convergence after whole-object wipe**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: Valid bounded objects. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same corrected native baseline as Case 9: production zeroize source/contracts exist, but no dedicated eponymous native `proofs/cbmc/zeroize/` directory exists. The campaign addition is characterised at case level as: Secret-history convergence and recontamination recovery. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Zeroisation → item 1, “Whole-object secret-history convergence”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-ZERO-001`

- **Historical identifier:** `SA-ZERO-T1.P1`

- **Case identifier:** `SA-ZERO`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_zeroize`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded objects

- **Input domain:** Valid bounded objects

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** two objects differing in the wiped region become identical all-zero poststates with outer frame

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-ZERO`

- **Evidence path hint:** MLK_POLY_Zerorize_SKILL ASSISTED/01_A_TO_Z_MLK_ZEROIZE_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_POLY_Zerorize_SKILL_ASSISTED_EXECUTED_AF4C5ABD_RUN1_CLEAN.zip`

- **Archive SHA-256:** `c3cccffc859c3975acaf3e4d87f995ebf6257a5019c5d80f71ea80a662f33fe6`

- **Archive evidence path:** MLK_POLY_Zerorize_SKILL ASSISTED/01_A_TO_Z_MLK_ZEROIZE_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `7305653d80e9d545330e19e14212bef6cb56cf742c0e0b43a392e75a19b58c68`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/Skill-Assisted-codex-flows/MLK_POLY_Zerorize_SKILL ASSISTED/01_A_TO_Z_MLK_ZEROIZE_SKILL_ASSISTED.md

- **Public evidence SHA-256:** 7305653d80e9d545330e19e14212bef6cb56cf742c0e0b43a392e75a19b58c68

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** appendix-ledger audited equation.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Skill-Available Zeroisation → item 1, “Whole-object secret-history convergence”.


</details>

---

## PR-SA-ZERO-002 — Recovery after recontamination and re-wipe


### Formal statement

$$
Z_J\!\left(\operatorname{Recontaminate}_J(Z_I(M))\right)\big|_I=0\quad\land\quad\text{registered outer frame preserved}
$$


### What the property/control means

The property checks the structural or multi-execution law **Recovery after recontamination and re-wipe**. It strengthens the case by asking whether the production behaviour is stable under the stated relation between inputs, coordinates, repeated calls or representations, rather than only checking one output in isolation.


### Why it matters

A single-run functional equation can hide unwanted coupling or fail to describe repeated/composed behaviour. This record tests an additional invariant that makes the principal claim more informative without changing its domain.


### Relationship to the principal claim

**Role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`. Relational/structural strengthening of the principal claim: it tests an additional invariant implied by or compatible with the same production semantics.


### Formal-support basis and evidential status

The ledger records **SUPPORTED** and maps the proposition to `Skill-available final harness and selected-claim mapping`. Target reachability is `YES`, assumption feasibility is `YES`, and the non-vacuity field is `SUPPORTED`. The retained mutation/control field records: Expected-failure/coverage controls retained in package. Under the repository evidence policy, the formal conclusion is bounded to the pinned source, harness, assumptions and analysis configuration; the success status is not treated as unrestricted program correctness.


### Exact experimental obligation and admitted domain

The relation above was associated with `Skill-available final harness and selected-claim mapping`. The admitted domain is: Valid bounded object and nonempty subrange. The recorded assumptions/grounding are: All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex. This states the actual verification obligation rather than inferring a broader mathematical domain from the C storage type.


### Permitted conclusion and explicit boundary

**Strongest conclusion supported by this record:** The named bounded property is technically supported in the retained skilled package.

**What this record does not establish:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.


### Native-baseline relationship

The frozen native baseline for this case is: Same corrected native baseline as Case 9: production zeroize source/contracts exist, but no dedicated eponymous native `proofs/cbmc/zeroize/` directory exists. The campaign addition is characterised at case level as: Secret-history convergence and recontamination recovery. The distinctness matrix does not claim that every individual equation in this catalogue is absent from every upstream artefact; it supports repository-relative distinction for the generated suite and explicitly preserves necessary overlap with the production source, constants and contracts.


### Thesis projection

Appendix 1 → Skill-Available Zeroisation → item 2, “Recovery after recontamination and re-wipe”. Chapter 4 uses the case-level principal synthesis in Section 4.6; this record remains available here so that the compression does not erase its evidential role.


<details>
<summary><strong>Complete traceability metadata</strong></summary>


- **Property record:** `PR-SA-ZERO-002`

- **Historical identifier:** `SA-ZERO-T2.P1`

- **Case identifier:** `SA-ZERO`

- **Condition:** `SKILL_AVAILABLE`

- **Target:** `mlk_zeroize`

- **Property class:** `Skill-available relational/compositional`

- **Source revision:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`

- **Parameter set:** ML-KEM-768 build; bounded objects

- **Input domain:** Valid bounded object and nonempty subrange

- **Assumptions and grounding:** All nine skills invoked; outputs produced and configuration-level inspection recorded; semantic authority remained with Codex

- **Ledger formal relation:** wipe outer region; recontaminate nonempty subrange; rewipe subrange => outer region all zero and frame preserved

- **Assertion / harness mapping:** Skill-available final harness and selected-claim mapping

- **Result:** `SUPPORTED`

- **Target reachability:** YES

- **Assumption feasibility:** YES

- **Non-vacuity evidence:** SUPPORTED

- **Mutation status:** Expected-failure/coverage controls retained in package

- **Strongest bounded conclusion:** The named bounded property is technically supported in the retained skilled package.

- **Explicit exclusion:** Does not establish that one skill caused selection/success, individual-skill effectiveness, general superiority or efficiency improvement.

- **Evidence locator:** `LOC-SA-ZERO`

- **Evidence path hint:** MLK_POLY_Zerorize_SKILL ASSISTED/01_A_TO_Z_MLK_ZEROIZE_SKILL_ASSISTED.md

- **Evidence completeness:** `COMPLETE`

- **Archive name:** `MLK_POLY_Zerorize_SKILL_ASSISTED_EXECUTED_AF4C5ABD_RUN1_CLEAN.zip`

- **Archive SHA-256:** `c3cccffc859c3975acaf3e4d87f995ebf6257a5019c5d80f71ea80a662f33fe6`

- **Archive evidence path:** MLK_POLY_Zerorize_SKILL ASSISTED/01_A_TO_Z_MLK_ZEROIZE_SKILL_ASSISTED.md

- **Archive entry SHA-256:** `7305653d80e9d545330e19e14212bef6cb56cf742c0e0b43a392e75a19b58c68`

- **Archive resolution status:** `RESOLVED`

- **Archive candidate count:** 1

- **Resolved public evidence path:** experiments/Skill-Assisted-codex-flows/MLK_POLY_Zerorize_SKILL ASSISTED/01_A_TO_Z_MLK_ZEROIZE_SKILL_ASSISTED.md

- **Public evidence SHA-256:** 7305653d80e9d545330e19e14212bef6cb56cf742c0e0b43a392e75a19b58c68

- **Public path resolution status:** `RESOLVED_HASH_MATCH`

- **Public path candidate count:** 1

- **Rendering basis:** conservative rendered formalization.

- **Principal-claim role:** `RELATIONAL_OR_STRUCTURAL_STRENGTHENING`

- **Appendix projection:** Appendix 1 → Skill-Available Zeroisation → item 2, “Recovery after recontamination and re-wipe”.


</details>

---


# Case-level bounded conclusion

Whole-object secret-history convergence and recovery after recontamination/re-wipe are supported for the registered bounded objects and wipe regions.

**Explicit exclusion.** The result concerns the modelled C abstract-machine memory state; it does not establish physical-remanence erasure or a causal skill benefit.


# Cross-file authority

Record identity/status/domain: `02_COMPLETE_PROPERTY_LEDGER.csv`. Principal claim: `03_FORMAL_CLAIM_CATALOGUE.md` and `09_MASTER_PROVENANCE_MATRIX.csv`. Native baseline: `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`. Repository-relative distinctness: `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv`. Exceptional outcomes: `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`. Principal-claim survival/compression: `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`. Evidence paths/hashes: `16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`.
