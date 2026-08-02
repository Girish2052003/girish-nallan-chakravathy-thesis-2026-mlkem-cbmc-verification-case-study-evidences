# Agent 11 Evaluation Report

## Evaluation boundary

This report summarises the evidence recorded by the workflow. It does not claim full implementation correctness, FIPS 203 compliance, cryptographic security, or whole-program verification.

## Measured run facts

- Target function: `mlk_poly_add`
- Target topic: `ML-KEM polynomial addition`
- Expected workflow stages: `11`
- Indexed stage records: `11`
- Existing stage manifests: `6`
- Missing stage manifests: `5`
- Handoff outputs indexed: `35`
- Checksums indexed: `158`
- LLM stages indexed: `7`
- LLM calls executed: `5`
- LLM mode counts: `{'real': 5, 'unknown': 2}`
- CBMC result classification: `None`
- CBMC tool executed: `None`
- Integrity status: `valid_with_warnings`
- Integrity warnings: `6`
- Integrity errors: `0`

## Tool-evidence interpretation boundary

The recorded tool outcome category is `unknown_or_incomplete_tool_outcome`. This category is derived from logged Agent 7 status and is not a broader correctness claim.

## RQ mapping

### RQ1

Transform selected PQC specification/code context into candidate CBMC-style artefacts using an API-backed LLM workflow.

**Supported by this run:** The run can support a bounded statement about whether the workflow produced candidate intermediate artefacts, subject to whether stages were real API mode or mock mode.

**Not supported by this run:** The run does not establish that the artefacts are correct, complete, verified, or generally reusable.

### RQ2

Use high-assurance PQC/formal-methods workflow ideas to structure the ML-KEM/CBMC case study.

**Supported by this run:** The run can support evaluation of the workflow structure and trust boundaries.

**Not supported by this run:** The run does not compare against all high-assurance PQC verification frameworks or prove equivalence to them.

### RQ3

Evaluate usefulness, failure modes, and human-correction needs after review, correction, and CBMC checking.

**Supported by this run:** The run can support a case-study evaluation of observed workflow usefulness and failure modes.

**Not supported by this run:** The run does not support broad statistical claims unless repeated over multiple functions/runs.

## Failure-mode taxonomy

- `FM_TOOL_001` — No formal-tool result because execution was skipped, dry-run, or unavailable: observed = `False`.
- `FM_TOOL_002` — CBMC/tool execution error or timeout: observed = `False`.
- `FM_PROP_001` — Verification failure/counterexample available: observed = `False`.
- `FM_SCOPE_001` — Verification success is property-specific and scope-limited: observed = `False`.
- `FM_REVIEW_001` — Review gate prevented tool execution: observed = `True`.

## Threats to validity

- `TV_SCOPE_001` (scope): The run is a selected-function case study, not whole-implementation verification. Mitigation: Report the exact target function, property, harness, assumptions, and CBMC command.
- `TV_TOOL_001` (tool evidence): CBMC output is property-specific and harness-specific. Mitigation: Use Agent 7 command/status/output and avoid full-correctness claims.
- `TV_LLM_001` (LLM usage): Some or all LLM stages may be mock/disabled rather than real API mode: {'real': 5, 'unknown': 2}. Mitigation: Separate mock wiring tests from real API-backed experimental runs.
- `TV_REPRO_001` (reproducibility): Integrity validation status is valid_with_warnings. Mitigation: Use Agent 10 checksums, handoff index, and replay manifest.
- `TV_GENERAL_001` (generalisation): A single target function/run cannot justify broad claims about all ML-KEM or PQC code. Mitigation: Frame findings as case-study evidence and discuss need for more functions/runs.

## Thesis-safe conclusion

The run should be described as a bounded case-study execution of a controlled LLM-assisted formal-methods workflow. The evidence supports statements about artefact generation, review gates, tool-execution status, reproducibility logging, and observed failure modes within the recorded run. It does not support claims of full ML-KEM correctness, FIPS 203 compliance, cryptographic security, or general performance across all PQC implementations.
