# Eight-Session Document-to-Code Verification Report

## Verification decision

**Code and architecture verdict:** APPROVED as conforming to the final, override-aware architecture defined by the eight Q&A sessions.

**Installation verdict:** APPROVED for installation into a new Ubuntu test workspace and execution of the packaged local verification suite.

**First live experiment verdict:** CONDITIONALLY APPROVED only after the user's Ubuntu machine completes both `./bootstrap_ubuntu.sh` and `python preflight_first_api.py --config <real-config>` successfully.

This report distinguishes implementation conformance from scientific outcome. It does not assert that a future LLM artefact will be correct or that CBMC will pass the selected ML-KEM property.

## Source-document audit

The complete DOCX was read from beginning to end. It contains exactly eight numbered question-and-answer sessions and no ninth session. Later explicit decisions override earlier temporary proposals.

| Session | Final controlling decision extracted from the document |
|---:|---|
| 1 | Use a controlled LLM-assisted, role-specialised workflow. Python is experimental infrastructure; the LLM proposes candidate reasoning; CBMC checks; humans retain final scientific judgement. |
| 2 | The old deterministic-heavy implementation is only a baseline/control-plane prototype. Reasoning-stage semantic handoffs must come from actual API responses in real mode. |
| 3 | Python reads/packages raw FIPS and implementation evidence and may provide advisory local analysis. The LLM must receive real primary evidence, verify advisory claims independently, and produce the downstream candidate output. |
| 4 | Freeze the evidence hierarchy, agent roles, strict schemas, evidence references, uncertainty/disagreement reporting, careful claim boundaries, and agent-specific responsibilities. |
| 5 | Prevent verbatim or near-verbatim copying of repository proof harnesses, deterministic templates, prior generated candidates, and human-corrected examples. Do not claim “100% novel.” |
| 6 | Use the official candidate-output and handoff chain from Agents 2–11, with Agents 5, 9, and 11 explicitly mixed rather than purely LLM or purely deterministic. |
| 7 | Separate each stage into deterministic references, prompt package, LLM-authoritative candidate output, validation, rendered/tool evidence where applicable, and manifest handoff. |
| 8 | Final override: one canonical physical location per output. No root-level compatibility dump and no copied handoff artefacts. Manifests/pointers resolve canonical files. |

## Session-by-session conformance verdict

### Session 1 — Division of responsibility

**Status: Working as planned.**

- Agent 1 is deterministic orchestration.
- Agents 2, 3, 4, 6, and 8 are LLM-backed candidate-reasoning stages.
- Agents 5 and 9 are mixed: LLM plans candidate artefacts/repairs; Python controls rendering/application and validation.
- Agent 7 is deterministic formal-tool execution.
- Agent 10 is deterministic evidence logging.
- Agent 11 is mixed: deterministic measured facts plus clearly separated LLM interpretation.
- Prompts and reports prohibit claims of full ML-KEM correctness, FIPS compliance, cryptographic security, or proof beyond the exact recorded model.

### Session 2 — Actual API-backed reasoning stages

**Status: Implemented and integration-tested; live university access remains environment-dependent.**

Every required reasoning stage constructs `LLMStageRequest` and invokes `LLMClient.run_stage` in real mode. A prompt file alone is not treated as execution. Missing credentials, missing SDK support, malformed JSON, and failed schema validation fail closed. Deterministic output is not silently promoted as a real LLM result.

The actual OpenAI SDK request path was exercised with a controlled local HTTP transport, including malformed first output, retry, strict schema request, response validation, and exact request/response evidence. No university API credit was spent.

### Session 3 — Raw evidence plus advisory deterministic analysis

**Status: Working as planned.**

The API request builder separates:

1. raw primary specification/source/build/tool evidence;
2. prior authoritative candidate-stage outputs;
3. trusted deterministic measured/control facts;
4. fallible deterministic advisory references.

The exact categories are included in the request and recorded in the request snapshot. Advisory findings are not treated as truth. Every reasoning schema now requires a structured deterministic-reference assessment and disagreement list.

### Session 4 — Frozen prompts, schemas, trust boundaries, and agent policies

**Status: Working as planned after final hardening.**

- All eight reasoning-stage schemas are strict.
- Every object disallows undeclared properties.
- Every declared field is required under strict Structured Outputs rules.
- Major outputs include evidence references and uncertainty/limitation structures.
- Agent 3 explicitly represents input/output mutation and old-state/new-state concerns.
- Agent 4 properties contain evidence, assumptions, feasibility, risk, and bounded-checking scope.
- Agent 5 returns an artefact plan and candidate C; Python rendering is separately labelled.
- Agent 6 checks circular/trivial assertions, old/new state, unsupported build symbols, overclaiming, and copying risk.
- Agent 7 records the exact formal-build command, sources, includes, definitions, stubs, working directory, tool version, timeout/unwind options, exit status, stdout, and stderr.
- Agent 8 analyses successful as well as unsuccessful tool results and receives raw tool evidence as primary evidence.
- Agent 9 records evidence-strength impact and blocks production-source changes unless explicitly enabled.
- Agent 11 uses the exact frozen top-level separation: `measured_facts`, `llm_interpretation`, `limitations`, `threats_to_validity`, and `human_review_required`.

### Session 5 — Independent generation and anti-copy protection

**Status: Working as a fail-closed heuristic guardrail.**

- Implementation source/header files remain primary evidence and are not incorrectly classified as prohibited-copy material.
- Existing proof harnesses, deterministic templates, prior generated artefacts, and configured human-corrected references are comparison-only sources.
- Agent 5 records an independence statement and Python similarity audit.
- Variable renaming and statement reordering are not treated as proof of independence.
- Required identifiers, types, constants, macros, includes, and CBMC primitives are allowed to match.
- Agent 6 blocks high-similarity risk before Agent 7.
- The audit explicitly states that it is not legal or originality proof and never claims “100% novel.”

### Session 6 — Official output/handoff chain

**Status: Working as planned, with backward-safe manifest aliases and no physical copies.**

The canonical chain contains:

- Agent 2: specification summary;
- Agent 3: code summary;
- Agent 4: candidate properties;
- Agent 5: artefact plan, rendered harness, artefact manifest, independence audit;
- Agent 6: critic review and gate decision;
- Agent 7: raw/tool status and property evidence;
- Agent 8: tool-result/counterexample analysis and repair guidance;
- Agent 9: repair plan and optional repaired harness;
- Agent 10: experiment log, file/artifact index, and checksum manifest;
- Agent 11: evaluation JSON, evaluation Markdown/final report, measured facts, limitations, and human-review requirements.

Agent 10 exposes both descriptive keys (`artifact_inventory`, `checksum_manifest`) and the planning-document aliases (`file_index`, `checksums`) pointing to the same canonical files. Agent 11 exposes `final_report` as an alias to the canonical evaluation Markdown. These are manifest aliases, not duplicate files.

### Session 7 — Per-stage directory separation

**Status: Working as planned.**

LLM-backed stages use the expected separation among deterministic reference, prompt package, LLM-authoritative candidate, validation, and handoff manifest. Mixed stages add rendered/prohibited-copy material where relevant. Deterministic stages use control, tool input/output, diagnostics, logs, and evidence indexes.

A persistent clean mock run produced all 11 stage directories. The run root contained only the five control/index files: `events.jsonl`, `run_config.resolved.json`, `run_manifest.json`, `status.json`, and `workflow_plan.json`.

### Session 8 — No duplicate compatibility dump

**Status: Working as planned after literal pointer hardening.**

- Stage artefacts are not copied to the run root.
- Handoff directories contain only a manifest pointer/index.
- Normal downstream resolution uses `RunLayout` and handoff manifests.
- Iteration-stage canonical manifests live inside `iterations/iteration_XX/`.
- Stage-level “latest” manifests are symbolic links on supported systems, or small `manifest_pointer.v1` records on fallback systems; they are not second full JSON copies.
- Multiple manifest keys may point to one canonical file without creating another physical artefact.

The workflow still intentionally creates many traceability files. The promise solved by Session 8 is duplicate-location elimination, not elimination of audit evidence.

## Agent-by-agent final verdict

| Agent | Final type | Verdict | Approval boundary |
|---:|---|---|---|
| 1 | Deterministic | Working as planned | Control-plane behavior tested |
| 2 | LLM-backed | Working as planned in implementation | Live model quality/access checked on user VM |
| 3 | LLM-backed | Working as planned in implementation | Live model quality/access checked on user VM |
| 4 | LLM-backed | Working as planned in implementation | Live model quality/access checked on user VM |
| 5 | Mixed | Working as planned | Candidate usefulness remains human/tool evaluated |
| 6 | LLM-backed plus deterministic gate | Working as planned | Approval means only safe to attempt CBMC |
| 7 | Deterministic tool execution | Working at integration/build-contract level | Real selected mlkem-native CBMC run remains local |
| 8 | LLM-backed | Working as planned in implementation | Diagnosis quality remains experimental evidence |
| 9 | Mixed | Working as planned | Repairs remain candidates; original/production files protected |
| 10 | Deterministic | Working as planned | Failure/manual provenance cannot look normally valid |
| 11 | Mixed | Working as planned after final field/fallback correction | Invalid/mock results cannot become unqualified thesis claims |

## Original defect closure

All twelve defects from the earlier `NOT READY` report are closed in the final candidate:

1. missing schemas;
2. orchestrator/agent CLI mismatch;
3. critic decision mismatch;
4. tool-result field mismatch;
5. disconnected repair loop;
6. deterministic advisory evidence not transmitted;
7. exact API attempts not preserved;
8. incomplete formal-build model;
9. stale control hashes;
10. logger/evaluator masking failure/manual continuation;
11. Agent 10 handoff mismatch;
12. non-installable flat delivery.

## Additional defects found during this eight-session reread

The previously approved ZIP was not accepted blindly. The document-first audit found and corrected these literal mismatches:

1. Agent 5 and Agent 9 were labelled `llm_backed` in one shared registry instead of `mixed`.
2. Agent 11 used approximate field names instead of the frozen `llm_interpretation` and `human_review_required` fields.
3. Reasoning-stage schemas did not require a structured deterministic-hint disagreement record.
4. Some Agent 8 parsed diagnostics were classified too highly instead of remaining advisory to raw CBMC evidence.
5. Implementation sources could be accidentally included in the prohibited-copy comparison set.
6. Stage manifests did not enumerate every per-attempt API snapshot.
7. Iteration root manifests were full duplicate JSON copies rather than true pointers.
8. Agent 11 could expose deterministic facts under the semantic `evaluation_report` handoff when a real LLM call failed.
9. Agent 11 did not directly receive all curated raw prompts/responses, generated artefacts, source/spec evidence, and raw CBMC evidence required by the planning document.
10. The planning-document Agent 10/11 handoff names lacked same-file manifest aliases.
11. Agent 10 counted planned stage-index rows as if every row were an existing stage manifest.
12. Agent 11 could mark a mock placeholder narrative as a promoted LLM narrative even though no API call executed.
13. Agent 11 could mark a mock/no-API run as eligible for scientific-result reporting solely because file integrity was acceptable.

All thirteen are corrected and regression-tested. Existing manifests, missing manifests, and planned stage records are now counted separately. Mock/non-API narratives are explicitly wiring-only, and scientific-result reporting eligibility requires real API-backed evidence; unqualified success wording is always disabled.

## Verification evidence

The final candidate passed:

- strict schema regression;
- canonical configuration regression;
- orchestrator/CLI and repair-loop regression;
- exact repaired-artifact review-to-tool binding;
- substitution rejection;
- dual repair modes;
- immutable iteration evidence;
- actual SDK request construction with retry and exact snapshots;
- formal-build plan and binding checks;
- anti-copy critic blocking;
- failed/manual-run provenance checks;
- Agent 11 fail-closed evaluation handoff;
- the dedicated eight-session conformance suite;
- a fresh persistent conservative mock run producing the expected stage tree and exit code 2 rather than a false verification success;
- literal reporting-precision checks proving missing manifests are not counted as present, mock narratives are not promoted, and mock/no-API runs are not labelled eligible for scientific-result reporting.

## Honest remaining external boundaries

The following are not defects in the packaged architecture but cannot be certified in this sandbox:

1. the Tampere University API key can access the configured model;
2. the model produces semantically useful outputs for the real FIPS/mlkem-native evidence;
3. the user's installed CBMC binary and exact mlkem-native build paths work;
4. a generated candidate harness passes the selected property;
5. human review judges the assumptions, property, and resulting evidence scientifically acceptable.

## Final authorization

The package is approved for safe Ubuntu installation and local release verification.

One controlled first API experiment is approved only after:

```text
BOOTSTRAP AND LOCAL RELEASE VERIFICATION PASSED
OPERATIONAL PREFLIGHT PASSED
approved_for_one_controlled_first_experiment: true
```

Use a unique run ID, `max_iterations = 0`, `force_run = false`, review-gate approval enabled, exact repository revision, real source/include/build paths, and an environment-variable API key.
