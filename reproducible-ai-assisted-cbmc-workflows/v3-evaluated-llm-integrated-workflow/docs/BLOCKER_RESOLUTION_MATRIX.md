# Defect and Blocker Resolution Matrix

This matrix maps the twelve defects from the original pipeline verification report and the later integration blockers to the final deployment candidate.

| ID | Original defect | Final correction | Verification evidence |
|---|---|---|---|
| D1 | Six required schemas missing | Complete strict stage-specific schemas; schema-compatible mock fixtures | `tests/verify_blocker1_schemas.py` |
| D2 | Orchestrator and Agents 6–9 disagreed on CLI arguments | Shared, validated `--iteration`, `--artifact`, and `--reason` behavior | `tests/verify_blockers3_to_8.py`, test 1 |
| D3 | Orchestrator read the wrong critic fields | Canonical `review_gate_decision` handoff with `final_gate`, `tool_execution_allowed`, and blocking issues | Blockers 3–8 tests and deployment gate |
| D4 | Orchestrator read the wrong CBMC result field | Canonical `result_classification`, including `verification_successful` | `tests/verify_blockers3_to_8.py`, test 3 |
| D5 | Repaired harness was not routed into re-review/re-execution | Explicit candidate path propagation; Agent 7 enforces identity with Agent 6 reviewed artefact | Blockers 3–8 tests 4–6 |
| D6 | Deterministic advisory bundle was saved but not transmitted | Exact API input includes raw evidence, prior candidate context, trusted facts, and advisory references as separate categories | `tests/verify_deployment_gate.py`, test 1 |
| D7 | Saved prompt was not the exact API request | Redacted, hashed per-attempt request snapshots and paired raw response records; retries preserved | Deployment gate test 1 |
| D8 | CBMC command lacked realistic build inputs | Canonical formal-build plan with source units, stubs, include paths, defines, working directory, unwind, options, and hashes | Deployment gate test 3 |
| D9 | Downstream agents rewrote run-control files and invalidated hashes | Run layout created once; downstream agents use `create=False`; mutable provenance separated | Deployment gate test 5 |
| D10 | Logger/evaluator could make failed/manual runs look valid | Root orchestration state and invocation provenance are first-class integrity errors; evaluator refuses thesis-result promotion | Deployment gate test 5 |
| D11 | Agent 10 output names disagreed with orchestrator expectations | Canonical logger outputs: `experiment_log`, `artifact_inventory`, `checksum_manifest` | Blockers 3–8 test 2 |
| D12 | Delivery was not installable | Canonical project hierarchy, pinned requirements, bootstrap script, fixture configs/inputs, cumulative tests, package checksums, and live preflight | Deployment gate test 8 |

## Additional integration blockers

| Blocker | Final correction | Verification evidence |
|---|---|---|
| Strict Structured Outputs compatibility | Every nested object has `additionalProperties: false`; declared properties are required | Blocker 1 suite |
| Conflicting legacy config aliases | Shared normalizer rejects contradictory paths and resolves project-relative paths deterministically | Blocker 2 suite |
| Dual repair modes | Agent 9 supports critic-driven and counterexample-driven repair with branch-specific evidence | Blockers 3–8 test 6 |
| Iteration overwriting | Agents 6–9 preserve `iterations/iteration_XX/` evidence | Blockers 3–8 test 7 |
| Unreviewed artifact substitution | Agent 7 refuses a harness differing from Agent 6’s reviewed checksum/path | Blockers 3–8 test 5 |
| Evidence-category leakage | Raw implementation evidence cannot overlap explicit prohibited-copy proof references | Agent 5 guard and deployment gate |
| Exact API-attempt inventory | Stage manifests discover and enumerate all per-attempt requests/responses | Deployment gate test 1 |
| First-run false readiness | Live preflight now performs a tiny real model-access call and a real CBMC smoke verification | `preflight_first_api.py` and deployment gate test 7 |
