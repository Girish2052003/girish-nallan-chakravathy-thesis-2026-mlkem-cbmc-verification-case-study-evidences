# Final Approval — Complete P01–P26 + Native CBMC Contracts Release

## Release identity

- Release: `PIPELINE_COMPLETE_26_PROPERTY_NATIVE_CONTRACTS_FINAL_2026-07-10`
- Type: superseding extension
- Frozen predecessor: `PIPELINE_EIGHT_QA_DOCUMENT_VERIFIED_FINAL_2026-07-10.zip`
- Frozen predecessor SHA-256: `17cbc5bb9d30c960513bde4688ae18146a731b9aa43b5bb7c6df308302bffdf6`
- Predecessor mutated: **no**

## Meaning of support

The release contains explicit workflow support for every P01–P26 family in the thesis property document. Support means that the system can select and preserve the family identity, construct the correct prompt/evidence contract, require the appropriate candidate artefact, validate and review the candidate, route to the appropriate deterministic tool profile when applicable, preserve failures and intermediate models, support controlled repair, and report the claim boundary.

Support does not guarantee that an LLM candidate is correct, that generated C or contracts compile, that CBMC terminates, or that a selected property is proved. It does not establish full ML-KEM correctness, FIPS compliance, cryptographic security, physical zeroization, probabilistic correctness, or constant-time security.

## Six supported strategies

1. `standard_cbmc_harness`
2. `native_function_contract`
3. `native_loop_contract`
4. `relational_cbmc_harness`
5. `hybrid_contract_and_harness`
6. `analysis_only_no_formal_claim`

P19 is deliberately restricted to analysis-only support and cannot be represented as a CBMC constant-time proof.

## Native contract implementation

### Loop contracts

- LLM proposes explicit invariant/decreases/frame clauses and an exact loop-header anchor.
- Python validates the plan and inserts only annotation text.
- Instrumentation occurs only in a copied source under the run directory.
- The original source hash is checked before and after rendering.
- Ambiguous or missing anchors fail closed.
- Trivial invariants and invalid history-variable placements fail closed.
- Agent 6 must approve the exact copied artefact before transformation.
- Agent 7 runs `goto-cc`, `goto-instrument --apply-loop-contracts`, and CBMC as a recorded multi-step pipeline.

### Function contracts

- Explicit `requires`, `ensures`, `assigns`, and `frees` clauses are represented.
- Optional DFCC harness metadata and call replacement are represented.
- Agent 7 can run `goto-cc`, `goto-instrument --dfcc`, `--enforce-contract`, `--replace-call-with-contract`, and CBMC as configured.
- Every intermediate GOTO model is existence-checked and SHA-256 hashed.

## Preserved frozen guarantees

- Strict structured schemas and fail-closed validation.
- Canonical configuration and project-root path resolution.
- Real LLM outputs remain candidate semantic handoffs; deterministic analysis remains labelled advisory material.
- Exact redacted request/response records for API attempts.
- Agent 6 fail-closed review gate.
- Reviewed-artifact checksum binding and substitution rejection.
- Immutable repair iterations and dual repair modes.
- Anti-copy controls and similarity audit.
- Canonical stage-local outputs and pointer-only handoffs.
- Provenance-aware Agent 10 and bounded Agent 11 reporting.
- No silent production-code mutation or deterministic fallback promotion.

## Verification results before packaging

- Blocker 1 strict schemas: PASS
- Blocker 2 configuration contract: PASS
- Blockers 3–8 integration: PASS, exit code 0
- Eight-session architecture conformance: PASS
- Deployment/API/build safety gate: PASS
- P01–P26/native-contract unit suite: PASS
- Deep repair/claim-boundary suite: PASS
- Full P12 native-loop-contract orchestration campaign: PASS
- Full P19 analysis-only orchestration campaign: PASS

The final ZIP must additionally pass `verify_release.sh` from a clean extraction before its checksum is approved.

## Approval boundary

Approved for clean installation after the clean-extraction verification succeeds. A real experiment remains conditional on the local preflight succeeding with the user's actual API project, selected model, CBMC/GOTO tools, exact mlkem-native revision, configured sources/includes/defines/stubs, and unique run ID.

No live university API request and no genuine repository-level mlkem-native CBMC contract campaign were performed in the sandbox. Those facts must remain visible in experiment reporting.
