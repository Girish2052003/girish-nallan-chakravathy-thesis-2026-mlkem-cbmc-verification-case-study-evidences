# Verification Evidence for the Final Deployment Release

The release is verified by two cumulative suites.

## Integration regression suite

`tests/verify_blockers3_to_8.py` verifies:

1. Agent 6–9 CLI contracts.
2. Conservative mock orchestration and Agent 10 handoff names.
3. CBMC `result_classification` parsing.
4. Repaired-harness propagation.
5. Review-to-execution checksum binding and substitution rejection.
6. Critic-review and counterexample-analysis repair modes.
7. Immutable iteration evidence.
8. Regression of strict schemas and canonical configuration.

Expected ending:

```text
BLOCKERS 3-8 PASSED
```

## Final deployment gate

`tests/verify_deployment_gate.py` verifies:

1. Current OpenAI SDK request path, strict structured output, retry, exact redacted request/response snapshots and evidence transmission.
2. Correct LLM/deterministic agent roles, prompt trust boundaries, and Agent 8 analysis of every completed formal-tool result.
3. Formal-build plan construction, review binding and old-state semantics.
4. Anti-copy similarity auditing and critic blocking.
5. Canonical layout, stable control hashes and failed/manual-run provenance.
6. Manifest-aware logger resolution for iteration evidence.
7. Operational first-API preflight with controlled Git and CBMC fixtures.
8. Installable package and pinned dependency contract.

Expected ending:

```text
FINAL DEPLOYMENT GATE PASSED
```

`verify_release.sh` also validates every packaged file against `PACKAGE_MANIFEST.sha256`, compiles all Python files and checks each production CLI.

## Eight-session document conformance suite

`tests/verify_eight_session_conformance.py` verifies:

1. Exact frozen agent roles, including mixed Agents 5, 9 and 11.
2. Exact Agent 11 structure and structured disagreement fields for all reasoning schemas.
3. Session 8 one-physical-file iteration manifest pointers.
4. Agent 11 direct raw-evidence grounding and fail-closed semantic handoff on LLM failure.
5. Agent 9 production-code and silent-overwrite protections.

Expected ending:

```text
EIGHT-SESSION ARCHITECTURE CONFORMANCE PASSED
```

## Independent persistent mock-run inspection

A separate conservative mock run was executed after the final patches. It returned exit code `2`, which is the correct outcome because mock review cannot authorize a real CBMC result. It produced all eleven stage directories, preserved only the five control files at the run root, used manifest pointers for iteration stages, clearly marked every mock output with `llm_call_executed: false`, and did not claim verification success.

`verify_release.sh` runs the integration suite, the eight-session conformance suite, and the final deployment gate after checksum, compilation and CLI checks.
