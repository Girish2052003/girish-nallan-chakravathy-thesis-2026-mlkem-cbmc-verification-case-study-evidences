# Historical Review of V1–V4 AI-Assisted CBMC Workflows

**Review date:** 2026-08-03  
**Source directory:** `reproducible-ai-assisted-cbmc-workflows`  
**Review boundary:** This document records what the preserved V1–V4 snapshots contain and demonstrate. It intentionally does **not** formulate the V5 research hypothesis.

## 1. Archive integrity and publication chronology

All publication checksum manifests were verified successfully:

| Version | Published role | Original regular files in publication metadata | Added preserved empty-directory markers / other publication entries | Checksum entries verified |
|---|---|---:|---:|---:|
| V1 | Evaluated initial workflow, before Agent 2 V2 upgrade | 10 | 0 | 10/10 |
| V2 | Evaluated initial workflow | 494 | 9 empty-directory markers | 494/494 |
| V3 | Evaluated LLM-integrated workflow | 1,088 | 193 empty-directory markers and 6 preserved symlink entries | 1,088/1,088 |
| V4 | Evaluated second-generation LLM-integrated workflow | 1,369 | 100 empty-directory markers | 1,369/1,369 |

Publication metadata dates V1 and V2 to 2026-08-01 and V3/V4 to 2026-08-02. These are publication dates of historical snapshots, not necessarily their original development dates.

## 2. V1 — early deterministic agent prototype snapshot

### What V1 contains

V1 contains only ten Python scripts under:

```text
v1-evaluated-initial-workflow/
└── agents_v1_before_agents_v2_upgrade/
```

The scripts represent:

- master orchestration;
- specification extraction;
- property discovery;
- artefact generation;
- review/critic;
- tool execution;
- counterexample analysis;
- repair;
- experiment logging;
- evaluation reporting.

The ten scripts total approximately 12,126 Python source lines.

### What V1’s architecture claims

The master orchestrator describes an eleven-agent concept: Agent 1 controls ten downstream stages. It explicitly treats generated artefacts as candidates and leaves CBMC and human review as authority.

The semantic stages are primarily deterministic heuristics/templates. Specification extraction contains an optional external-command LLM hook, but the snapshot contains no OpenAI client, model configuration, API profile, or recorded API-backed run.

### Important incompleteness

The master orchestrator expects a Code Understanding Agent at:

```text
agents/code_understanding_agent.py
```

No `code_understanding_agent.py` exists in V1. The published directory is also a historical inner snapshot rather than the `agents/` layout expected by the orchestrator.

V1 contains no:

- run configuration;
- input corpus;
- run evidence;
- test suite;
- installation/bootstrap procedure.

### Evidence-safe V1 interpretation

V1 is best understood as a **preserved early agent-program prototype**, not a standalone reproducible experiment package. It establishes the first stage decomposition and trust-boundary language, but it does not demonstrate a complete replayable workflow or actual LLM-integrated experiment.

## 3. V2 — completed deterministic case-study workflow

### What V2 adds

V2 supplies the missing Code Understanding Agent and expands the repository to:

- eleven agent scripts;
- approximately 19,065 agent-code lines;
- input specification and C/header material;
- run configurations;
- dry-run, failed-run, and completed-run evidence;
- CBMC commands, outputs, statuses, traces, critic records, event logs, hashes, and summaries.

The architecture remains a fixed Agent 1–11 sequence.

### Semantic authority in V2

V2 is still fundamentally deterministic. Configurations set `use_external_llm` to false for the evaluated baseline, and the package contains no direct OpenAI API integration. Some agents contain optional external-command hooks or future-LLM comments, but the actual workflow’s property discovery and harness generation are driven by deterministic rules and templates.

### V2 case-study sequence

#### Run 001 — fresh deterministic baseline

- Full pipeline generated structured artefacts and reports.
- CBMC execution status was `dry_run_not_executed`.
- Critic review identified problems with functional grounding, arithmetic assumptions, and aliasing choices.
- The generated update assertion did not correctly preserve the pre-state required for an in-place operation.

This run is workflow/failure-mode evidence, not verification evidence.

#### Run 002 — human-corrected CBMC harness

The human-corrected harness introduced:

- old-value snapshots;
- explicit no-overflow assumptions;
- corrected repository/build headers;
- an unwind increase from 256 to 257.

CBMC 6.9.0 reported `VERIFICATION SUCCESSFUL` for the selected local coefficient-wise property, with 228 reported properties and zero failures.

The result is explicitly scoped to the harness, assumptions, reconstructed build context, and bounded command.

#### Run 003 — agent improved using the Run 002 pattern

The Run 003 config enables:

```text
use_human_learned_mlk_poly_add_template
```

The artefact generator explicitly states that it applies the successful Run 002 pattern: old-state snapshot, no-overflow assumptions, and a post-call coefficient-wise assertion.

CBMC again reported success for the selected local property.

### Evidence-safe V2 interpretation

V2 demonstrates a genuine **engineering refinement cycle**:

```text
initial deterministic candidate
→ human correction
→ correction encoded into deterministic generator
→ later CBMC-checkable candidate
```

It does **not** demonstrate independent LLM theorem discovery or independent LLM harness generation. Run 003 is deliberately informed by the successful human correction and should not be used as uncontaminated evidence of autonomous discovery.

V2 is therefore strongest as:

- a deterministic baseline;
- a record of failure modes;
- evidence that human corrections can be operationalised;
- an origin for later trust-boundary and build-context requirements.

## 4. V3 — first genuine LLM-integrated controlled workflow

### Architectural shift

V3 changes the workflow from deterministic agents with optional hooks into a genuine mixed LLM/deterministic system:

| Agent | V3 role |
|---:|---|
| 1 | deterministic orchestration and provenance |
| 2 | LLM-backed specification candidate |
| 3 | LLM-backed code-understanding candidate |
| 4 | LLM-backed property discovery |
| 5 | mixed LLM plan/code plus deterministic rendering/validation |
| 6 | LLM critic plus deterministic fail-closed gate |
| 7 | deterministic CBMC/GOTO execution |
| 8 | LLM tool-result/counterexample analysis |
| 9 | mixed LLM repair plus controlled application |
| 10 | deterministic logger |
| 11 | deterministic facts plus separated LLM interpretation |

V3 introduces a real OpenAI SDK path, LLM profiles, strict schemas, redacted request/response snapshots, retry evidence, source/build provenance, formal-build plans, canonical stage directories, handoff manifests, immutable iteration evidence, anti-copy similarity screening, and explicit human-review boundaries.

### Property-campaign expansion

V3 adds a fixed P01–P26 property catalogue and multiple execution strategies, including:

- standard bounded CBMC harnesses;
- relational/two-call harnesses;
- native loop contracts;
- native function contracts and optional DFCC;
- hybrid profiles;
- analysis-only constant-time support.

“Support” is correctly defined as workflow capability, not guaranteed automatic proof success.

### V3’s methodological position

V3 treats LLM output as the authoritative **candidate semantic output** of reasoning stages, while deterministic semantic material is separately labelled advisory. CBMC remains the formal tool authority for the exact model; human review remains the scientific authority.

### Preserved V3 run evidence

All four archived V3 run directories end in either:

- `completed_with_failures_or_unresolved_items`; or
- `orchestrator_failed`.

The clearest real run generated candidate properties and a traceable harness, but the critic stopped progression before Agent 7 because of execution-readiness/build-entry mismatch. Another run reached a `human_review_required` critic state. The archive does not contain a clean V3 run that ends with selected-property verification under the recorded model.

### Evidence-safe V3 interpretation

V3 demonstrates that the project successfully built a **real API-integrated, highly instrumented eleven-stage workflow** with serious provenance and trust controls. Its strongest evidence concerns:

- implementation of the LLM/deterministic trust boundary;
- structured handoffs;
- reproducibility;
- candidate generation and critic behaviour;
- failure detection before formal execution.

The archived V3 runs do not demonstrate a clean end-to-end selected-property verification success.

## 5. V4 — second-generation LLM-first and open-discovery workflow

### Main methodological upgrades

V4 retains the fixed eleven-agent architecture but adds an explicit experiment protocol:

```text
protocol_version = llm-first-v1
semantic_advisory_mode = off
repair_policy = none_initial_run
max_iterations = 0
structured_cbmc_json_required = true
selected_property_claims_required = true
mutation_non_vacuity_required = true
```

In the primary `off` mode, deterministic semantic summaries, candidate properties, assertion suggestions, contract suggestions, and harness sketches are not transmitted to the LLM. Raw source/specification evidence and measured deterministic facts remain permitted.

V4 also supports separated comparison modes:

- `off` — primary LLM-first experiment;
- `reference_only` — deterministic advice is visible but explicitly non-authoritative;
- `baseline_only` — deterministic baseline, not represented as LLM semantic generation.

A mode change requires a new run identifier and protocol hash.

### Open discovery versus targeted campaigns

V4 distinguishes:

- **targeted campaign:** a P01–P26 family is deliberately selected before property discovery;
- **open discovery:** the P01–P26 catalogue is hidden from the LLM, raw candidates are preserved, candidates are classified afterward, unmapped candidates remain `UNMAPPED`, and one concrete candidate is selected before artefact generation.

This is a major improvement in attribution because it separates open property discovery from testing a preselected property family.

### Formal-evidence and routing hardening

V4 separates:

1. successful tool execution;
2. success of all emitted CBMC properties;
3. non-empty and complete selected-property coverage;
4. selected property verified under the recorded bounded model.

It also defines stable fail-closed transition identifiers for missing assumptions, missing selected claims, tautological loops, scope drift, irrelevant target calls, vacuous assumptions, unreachable claims, and missing claim-to-CBMC mappings.

### Engineering/release evidence

The final release documentation records:

- 38/38 implementation promises complete;
- 53/53 clean local regressions passed;
- frozen Run 001 and Run 002 evidence preserved byte-for-byte;
- mandatory real-CBMC 6.9.0 host acceptance before new experiments.

### Preserved V4 run evidence

#### Run 001 — open discovery

- The LLM produced six candidate properties and rejected/downgraded alternatives.
- The selected candidate was `OPEN_CAND_003`, classified as an uncatalogued/unmapped candidate.
- The critic approved tool execution.
- The formal path failed before a CBMC semantic result because a contract build/instrumentation step failed.
- Result classification: `contract_build_or_instrumentation_failed`.

#### Run 002 — repaired/open-discovery replication

- Five candidates were produced.
- The selected candidate was `OPEN_CAND_002`, also unmapped/new.
- The LLM critic recommended revision before tool execution.
- No clean formal-tool verification result was produced.

#### Run 003 — repair-enabled follow-up

- Open discovery again selected `OPEN_CAND_002`.
- The run ended in `orchestrator_failed` before a complete end-to-end result.

### Evidence-safe V4 interpretation

V4 is the strongest pre-V5 methodology for:

- LLM-first attribution;
- open property discovery;
- protocol separation;
- deterministic-advice controls;
- selected-claim traceability;
- non-vacuity requirements;
- formal result taxonomy;
- fail-closed state transitions.

However, the archived V4 experimental runs still do not show a clean selected-property verification success. They expose the operational cost and brittleness of the large staged architecture: formal-strategy reconciliation, contract grammar/build readiness, critic routing, and orchestrator state all become potential failure surfaces before or around CBMC.

## 6. The factual V1→V4 evolution

| Dimension | V1 | V2 | V3 | V4 |
|---|---|---|---|---|
| Principal semantic mechanism | deterministic heuristics/templates | deterministic heuristics/templates | API-backed LLM stages plus deterministic controls | LLM-first stages plus stricter protocol controls |
| Published completeness | partial agent snapshot | complete evaluated deterministic case-study package | installable controlled LLM-integrated release | second-generation mutable LLM-first release |
| Property discovery | deterministic candidate generation | deterministic candidate generation | LLM inside preselected P01–P26 campaign | LLM open discovery or targeted campaign |
| Harness generation | deterministic template | deterministic template, later human-learned template | LLM plan/code plus deterministic renderer | LLM-first candidate plus deterministic safety/traceability controls |
| Orchestration | fixed 11-agent concept | fixed 11-agent pipeline | fixed 11-stage pipeline | fixed 11-stage pipeline |
| Formal execution | CBMC wrapper concept | dry runs and successful manually corrected/templated runs | structured deterministic CBMC/GOTO stage | structured CBMC/GOTO with selected-claim and non-vacuity rules |
| Human role | final authority stated | correction and final interpretation | final scientific authority | final scientific authority |
| Strongest demonstrated result | architecture prototype | local CBMC success after human correction and template transfer | genuine API integration and controlled candidate workflow | LLM-first/open-discovery methodology and hardened trust chain |
| Main evidence limitation | incomplete/non-replayable snapshot | no genuine independent LLM generation | no clean selected-property-success run in archive | no clean selected-property-success run in archive |

## 7. Historical tensions to carry into the later V5 discussion

These are not yet V5 conclusions; they are the questions created by the V1–V4 record:

1. **Attribution:** How can the experiment measure Codex’s reasoning without deterministic semantic templates, preselected property content, or another LLM critic doing part of the intellectual work?
2. **Orchestration:** Does a fixed eleven-stage state machine measure agent autonomy, or mostly measure whether the pipeline wiring survives?
3. **Complexity:** Are hundreds of schemas, manifests, gates, aliases, retries, and transitions protecting science, or also creating failure surfaces unrelated to the research question?
4. **Tool assistance:** Which deterministic capabilities genuinely help formal verification without becoming hidden reasoning agents?
5. **Fair comparison:** How should assisted and unassisted conditions share identical instrumentation while differing only in optional helper capability?
6. **Anti-copy placement:** Should similarity/contamination checking run inside the agent’s loop or only after artefacts are frozen?
7. **Success criterion:** Should the primary result concern full pipeline completion, candidate usefulness, selected-property CBMC evidence, correction effort, or a combination kept as separate measurements?
8. **Baseline identity:** Which historical version is the correct comparator for V5—V2 deterministic generation, V3 controlled LLM integration, V4 LLM-first open discovery, or more than one comparator?

## 8. Review conclusion before V5 hypothesis design

The archive supports a coherent four-stage historical story:

```text
V1: stage-decomposed deterministic prototype
V2: completed deterministic workflow and human-correction learning cycle
V3: genuine API-backed LLM integration with heavy reproducibility controls
V4: LLM-first/open-discovery refinement with stricter experimental protocol
```

The directory does not support describing the sequence as four increasingly successful proof systems. The more accurate story is that each version solved a different methodological problem while exposing the next one:

```text
stage definition
→ reproducible deterministic execution
→ genuine LLM integration and trust separation
→ cleaner LLM attribution and open discovery
→ unresolved autonomy-versus-orchestration problem for V5
```

The V5 hypothesis should be formulated only after explicitly deciding what is being compared, what Codex must own intellectually, what optional tools may assist mechanically, and what evidence is external to the run.
