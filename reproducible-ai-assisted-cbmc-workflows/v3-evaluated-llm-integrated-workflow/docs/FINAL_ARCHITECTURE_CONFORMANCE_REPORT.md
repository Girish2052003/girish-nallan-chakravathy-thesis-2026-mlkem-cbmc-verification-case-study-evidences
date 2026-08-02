# Final Architecture Conformance Report

## Decision

**Deployment package verdict: APPROVED FOR SAFE INSTALLATION AND LOCAL VERIFICATION.**

**First real API experiment verdict: CONDITIONALLY APPROVED only after the user's Ubuntu machine passes both `./verify_release.sh` and `python preflight_first_api.py --config <real-config>`.**

This distinction is mandatory. The package and its internal contracts have been verified without spending API credits. Actual model availability, the user's API project permissions, the installed CBMC binary, the exact mlkem-native checkout, and the real semantic quality of generated artefacts can only be observed in the user's environment.

## Frozen architecture alignment

| Requirement | Final status | Evidence |
|---|---|---|
| Agent 1 deterministic control plane | Working as planned | No LLM client invocation; deterministic order, state, failure, and provenance handling |
| Agents 2, 3, 4, 5, 6, 8, 9 and Agent 11 narrative are API-backed | Working as planned when reached in `llm.mode=real` | Each uses `LLMStageRequest` and `LLMClient.run_stage`; local OpenAI SDK transport test exercises the real SDK code path |
| Agent 7 deterministic CBMC execution | Working as planned at integration level | Structured formal-build plan, exact command, working directory, sources, includes, defines, stubs, options, stdout/stderr, version and status preservation |
| Agent 10 deterministic logger | Working as planned at integration level | No LLM invocation; manifest-aware indexing, checksums, chronology, failure/manual-continuation provenance |
| LLM output is candidate stage authority, not proof | Working as planned | Global prompt guardrails, strict schemas, canonical `llm_authoritative` output, trust-boundary metadata |
| Raw primary evidence outranks deterministic hints | Working as planned | Explicit evidence categories in request payload; deterministic references marked advisory and transmitted separately |
| Previous authoritative LLM outputs reach later agents | Working as planned | Prior authoritative files and bundles included in API input and handoff manifests |
| Exact API request/response reproducibility | Working as planned | Per-attempt redacted request and response snapshots, retry payloads, SHA-256 request hashes |
| Strict structured output | Working as planned | Strict JSON schemas for all LLM stages and regression validation |
| Python does not secretly replace LLM semantic reasoning | Working as planned within stated design | Deterministic analysis is advisory; Agent 5/9 Python rendering is driven by LLM-authored plans and is separately labelled/validated |
| Anti-copy and independent-generation controls | Working as planned as a heuristic guardrail | Prohibited-copy index, Python similarity audit, independence statement, Agent 6 high-similarity blocking |
| No unsupported “100% novel” claim | Working as planned | Similarity audit explicitly states it is not originality/legal proof |
| One canonical physical output location | Working as planned | Handoff directories contain only `handoff_manifest.json`; manifests point to canonical files; no root-level stage copies |
| Repair loop uses exact repaired artefact | Working as planned | Iteration-specific repaired artefact passed to Agent 6, then exact reviewed checksum bound to Agent 7 |
| Critic-triggered and counterexample-triggered repairs | Working as planned | Branch-specific evidence requirements and tests |
| Every formal-tool result receives Agent 8 analysis | Working as planned | Agent 8 runs after every completed tool execution, including successful results, before success/failure branching |
| Iteration evidence is preserved | Working as planned | Immutable `iterations/iteration_XX` directories plus latest-pointer manifests |
| CBMC success parsing is scoped and correct | Working as planned at integration level | Canonical `result_classification`; orchestrator recognizes `verification_successful` without broad correctness claims |
| Failed/partial/manual runs cannot appear normally valid | Working as planned | Logger marks invalid provenance; evaluator refuses to promote thesis-result wording or LLM narrative for invalid runs |
| Mutable control hashes remain coherent | Working as planned | Run layout created once; downstream agents use `create=False`; control handoff refresh is explicit and provenance-labelled |
| Human review remains final scientific judgement | Working as planned as policy | Outputs flag human review; no model/tool result is promoted to full ML-KEM/FIPS/security correctness |
| Canonical installable project | Working as planned | Production hierarchy, pinned requirements, bootstrap script, templates, preflight, automated tests and checksum manifest |

## Corrections beyond the original eight blockers

The earlier Blockers 1–8 package was not approved unchanged. The final deployment candidate additionally corrects:

1. Deterministic hints and prior authoritative outputs are actually transmitted to the API request.
2. Exact redacted API payloads and responses are saved per attempt, including retries.
3. Agent 7 executes a structured formal-build plan containing implementation sources, stubs, include paths, defines, working directory and CBMC options.
4. Agent 6 reviews the formal-build plan before Agent 7 can execute it.
5. Run-control manifests are no longer silently rewritten by downstream agents.
6. Agent 10 elevates orchestrator failure, manual continuation and diagnostic provenance.
7. Agent 11 blocks normal thesis-result wording when integrity is invalid.
8. Logger resolution follows iteration handoff manifests rather than obsolete fixed paths.
9. Agent 8 analyses both successful and unsuccessful formal-tool results.
10. The package includes pinned dependencies, bootstrap and fail-closed operational preflight.

## Final document-first hardening after rereading all eight sessions

The approved candidate was re-audited against the complete eight-session source document rather than accepted from the prior deployment report. The reread produced additional literal corrections:

1. Agent 5 and Agent 9 are registered as `mixed`, not purely `llm_backed`.
2. Agent 11 uses the frozen fields `llm_interpretation` and `human_review_required`.
3. Every reasoning schema requires structured deterministic-reference disagreements.
4. Agent 8 raw CBMC files remain primary evidence while parsed diagnostics remain advisory.
5. Implementation source/header files are excluded from prohibited-copy references.
6. All per-attempt API request/response snapshots are indexed by stage manifests.
7. Iteration latest manifests are pointers to one canonical physical JSON.
8. Agent 11 does not expose a semantic `evaluation_report` handoff when a real LLM call fails.
9. Agent 11 receives curated raw source/spec, artefact, prompt/response and CBMC evidence directly.
10. Agent 10/11 expose planning-document handoff aliases without copying files.

The dedicated `tests/verify_eight_session_conformance.py` suite enforces these final rules.

## What has been genuinely tested

- All production Python files compile.
- Every agent CLI opens successfully.
- All strict schemas validate.
- Canonical and legacy config normalization works and contradictory aliases fail closed.
- A complete mock workflow runs with conservative gating.
- Repair routing, re-review and review-to-execution checksum binding work.
- Iteration files remain byte-identical after later iterations.
- Simulated CBMC success and failure classifications are handled correctly.
- The current OpenAI Python SDK code path is exercised with a local mock HTTP transport, including one malformed response, retry, strict schema request and validated authoritative output.
- All evidence categories are present in the actual SDK request payload.
- API credentials are redacted from saved records.
- A realistic formal-build plan creates a command with source units, includes, defines, function, unwind settings and extra arguments.
- A high-similarity generated candidate is blocked by the critic gate.
- A failed/manually continued run is marked invalid by Agent 10 and cannot be presented as a normal result by Agent 11.
- The operational preflight accepts a controlled valid Git/CBMC fixture and fails closed on placeholders or missing prerequisites.

## What has not been claimed

- No genuine university OpenAI API request has been made.
- No claim is made that the configured model is available to the user's API project until checked in the user's environment.
- No genuine mlkem-native CBMC proof run has been performed in this sandbox.
- No generated harness is claimed correct before review and actual CBMC execution.
- No CBMC success is treated as full ML-KEM correctness, FIPS 203 compliance, cryptographic security, constant-time security, or proof beyond the exact model and configuration.
- Similarity screening is not proof of novelty or non-infringement.

## Deployment authorization rule

The user may install the package in a new test workspace now. The user may start one cost-controlled real API experiment only when:

1. `./bootstrap_ubuntu.sh` ends with `BOOTSTRAP AND LOCAL RELEASE VERIFICATION PASSED`.
2. The real config contains no placeholders.
3. `python preflight_first_api.py --config <real-config>` ends with `OPERATIONAL PREFLIGHT PASSED`.
4. The run uses a unique run ID, `max_iterations = 0`, `force_run = false`, and gate approval enabled.
5. The exact mlkem-native Git revision and real source/include/build paths are recorded.
6. The API key is supplied only through the configured environment variable.

Passing those gates authorizes the experiment; it does not predetermine its scientific outcome.
