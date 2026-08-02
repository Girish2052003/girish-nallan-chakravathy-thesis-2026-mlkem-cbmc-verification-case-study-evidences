# Frozen Architecture Compliance Matrix

| Frozen requirement | Status | Implementation evidence |
|---|---|---|
| Controlled API-backed LLM-assisted workflow, not autonomous proof engine | Implemented | Role separation in agents and global prompt rules |
| Agents 2, 3, 4, 5, 6, 8, 9, and LLM part of 11 make actual API calls in real mode | Implemented locally; live access environment-dependent | `LLMStageRequest` + `LLMClient.run_stage`; SDK-path deployment test |
| Validated LLM output is downstream semantic handoff | Implemented | LLM-authoritative output paths and handoff manifests |
| Deterministic outputs remain advisory, not semantic replacements | Implemented | Separate deterministic bundles and trust labels; fail-closed LLM failure handoffs |
| Raw primary evidence outranks prior candidate context and deterministic hints | Implemented | Categorized request builder and prompt hierarchy |
| Exact API attempt, retry, response, schema, model parameters, and hash preserved | Implemented | `api_requests/attempt_XX_request.json`, paired response records, stage-manifest discovery |
| Python reads/packages evidence, validates, renders, runs tools, logs, and manages state | Implemented | Shared config/layout/evidence/formal-build modules |
| Agent 5 strategy originates in LLM artefact plan; Python renders validated C | Implemented | Agent 5 plan schema, renderer, manifest, audit |
| Agent 6 checks circularity, trivial assumptions, old/new state, unsupported symbols, overclaiming, and copying risk | Implemented | LLM prompt plus deterministic fail-closed gate |
| Agent 7 is deterministic and preserves exact tool/build evidence | Implemented | Formal-build plan, command/environment/status/stdout/stderr records |
| Agent 8 grounds diagnosis in raw CBMC evidence | Implemented | Raw tool files as primary evidence; parsed diagnostics advisory only |
| Agent 9 does not silently weaken/remove properties or modify production code | Implemented as policy and controlled candidate rendering | Repair schema/prompt, branch controls, source-repair guard |
| Agent 10 preserves failure/provenance/integrity | Implemented | Failed/manual run invalidation and manifest resolution |
| Agent 11 separates measured facts from LLM interpretation and blocks invalid-run promotion | Implemented | Exact frozen fields `measured_facts`, `llm_interpretation`, `limitations`, `threats_to_validity`, `human_review_required`; fail-closed semantic handoff |
| Independent generation and anti-copy screening | Implemented | Prohibited-copy index, similarity audit, Agent 6 blocking |
| No unsupported “100% novel” claim | Implemented | Global prompt and audit wording |
| One canonical physical output location | Implemented | Pointer-only handoff folders, canonical iteration manifests, symlink/`manifest_pointer.v1` latest pointers, and root-file restrictions |
| Repair iterations preserve immutable evidence | Implemented | `iterations/iteration_XX/` layout |
| Partial/failed/skipped/unresolved states preserved | Implemented | Orchestrator status, stage manifests, logger integrity rules |
| Missing evidence is not invented | Implemented | Fail-closed loaders, missing-context markers, mock/disabled distinctions |
| CBMC success remains scoped | Implemented | Result wording and claim boundaries |
| Human review remains final scientific trust boundary | Implemented as workflow policy | Gate records, report limitations, preflight/experiment approval boundary |

## Environment-dependent items

The following cannot be certified solely inside the packaging sandbox:

1. the user’s Tampere University API key can access the configured model;
2. the user’s installed CBMC binary executes successfully;
3. the real selected ML-KEM repository, commit, include paths, and build settings are correct;
4. the first real LLM outputs are semantically useful;
5. the generated candidate harness passes CBMC for the selected property.

The live operational preflight verifies items 1 and 2 before the full experiment. The first experiment and human review provide evidence for items 3–5.
