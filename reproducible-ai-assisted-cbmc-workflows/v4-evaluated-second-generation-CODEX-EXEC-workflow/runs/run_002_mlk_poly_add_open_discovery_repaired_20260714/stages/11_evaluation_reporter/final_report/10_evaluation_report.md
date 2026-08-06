# Agent 11 Evaluation Report

## Claim boundary

This report is evidence-bounded. It does not claim full ML-KEM correctness, FIPS 203 compliance, cryptographic security, or whole-program verification.

## Thesis-safe wording

This case study supports a bounded statement that the repaired-engine workflow can move from open property discovery to a concrete, traceable candidate harness for mlk_poly_add while also surfacing a hard readiness defect before CBMC execution. The strongest defensible conclusion is that the pipeline generated and preserved a local, uncatalogued frame claim and its candidate contract artefacts under mostly real LLM activity, but the run did not produce a formal-tool result. Therefore, this evidence is suitable for results/discussion about workflow usefulness, traceability, and failure modes, not for claims of verification, correctness, compliance, or cryptographic security.

## Evaluation interpretation

{
  "status": "supported_with_caveats",
  "summary": "The workflow successfully moved from open discovery to a concrete candidate harness plan for mlk_poly_add, which is useful evidence that the repaired-engine pipeline can generate and preserve traceable verification artefacts. The run did not produce a formal-tool result, so the interpretation must stay at the level of workflow utility and failure diagnosis. One gate diagnostic about the target-call marker conflicts with the rendered harness and formal build plan, which both show the marker present; that looks like a frontend/modeling defect rather than a literal missing-marker finding."
}

## Usefulness assessment

{
  "status": "bounded_useful",
  "bounded_statement": "Within this case-study scope, the workflow is useful for discovering a narrow candidate property, generating a corresponding harness plan, and surfacing readiness defects early. It is not useful here as evidence of verified correctness, because the formal-tool path did not run.",
  "supporting_observations": [
    "Five raw candidates were generated and all five were classified, showing the discovery pipeline can organize open search results.",
    "OPEN_CAND_002 is a narrow local frame claim, which matches the style of a local candidate harness.",
    "The rendered harness includes the selected target-call marker and a witness sentinel, which improves traceability.",
    "The review gate exposed a hard frontend parse/build readiness defect before tool execution, which is diagnostically useful.",
    "Integrity validation is valid_with_warnings rather than clean, which helps frame the result as bounded and not overclaimed."
  ]
}

## Failure-mode assessment

{
  "result_classification": "missing_result_classification",
  "tool_outcome_category": "unknown_or_incomplete_tool_outcome",
  "rows": [
    {
      "taxonomy_id": "FM_CONTRACT_001",
      "label": "Unrecognized Agent 7 result label",
      "observed_in_run": true,
      "evidence_basis": "The measured bundle records cbmc_result_classification=missing_result_classification and semantic_outcome=unrecognized_result_classification, so no formal-tool result was logged for this run.",
      "evaluation_implication": "Cross-agent result handling should be repaired before treating the run as a verification outcome."
    },
    {
      "taxonomy_id": "FM_REVIEW_001",
      "label": "Review gate prevented tool execution",
      "observed_in_run": true,
      "evidence_basis": "The review gate logs final_gate=blocked_hard_tool_readiness_defect and tool_execution_allowed=false; the rendered harness and formal build plan still show the target-call marker present, so the issue is best read as a frontend/readiness defect.",
      "evaluation_implication": "Human review or artifact revision is required before any real tool execution attempt."
    }
  ],
  "limitations": [
    "This taxonomy is derived from logged run evidence and does not infer implementation bugs without CBMC/tool evidence.",
    "Because the formal-tool path was blocked, the run cannot support a CBMC verification conclusion.",
    "The marker complaint in the gate should be read cautiously because the rendered harness and build plan both show the marker present."
  ]
}

## Human review and correction needs

{
  "required": true,
  "status": "required",
  "items": [
    "Revise the artefact bundle so the hard frontend parse/build readiness defect is cleared before another tool attempt.",
    "Reconcile the gate diagnostic with the rendered harness and formal build plan, which both show TRACE_TARGET_CALL:OPEN_CAND_002 present beside the target call.",
    "Obtain or explicitly record a formal-tool result; current reporting is limited to a missing_result_classification / incomplete outcome.",
    "Account for the six missing expected outputs flagged in the integrity record."
  ]
}

## Threats to validity

{
  "threats": [
    {
      "threat_id": "TV_SCOPE_001",
      "category": "scope",
      "threat": "This is a selected-function case study, not whole-implementation verification.",
      "mitigation": "Report the exact target function, selected property, harness, assumptions, and tool readiness state."
    },
    {
      "threat_id": "TV_TOOL_001",
      "category": "tool_evidence",
      "threat": "CBMC did not execute, so there is no formal-tool result to interpret.",
      "mitigation": "Separate blocked execution from proof or failure and do not use it as verification evidence."
    },
    {
      "threat_id": "TV_LLM_001",
      "category": "provenance",
      "threat": "Not all LLM stages are definitively real API-backed runs; 2 stages are logged as unknown mode.",
      "mitigation": "Separate real API-backed stages from unknown-mode stages when describing evidence provenance."
    },
    {
      "threat_id": "TV_REPRO_001",
      "category": "reproducibility",
      "threat": "Integrity validation is valid_with_warnings and six expected outputs are missing.",
      "mitigation": "Use the checksum and handoff records, and state the missing outputs explicitly."
    },
    {
      "threat_id": "TV_SELECTION_001",
      "category": "selection_bias",
      "threat": "The selected property is chosen after discovery and classification as an experiment-control decision, not as a truth judgment.",
      "mitigation": "Treat the selected property as a bounded candidate claim and not as proven correctness."
    }
  ]
}

## Limitations

- This report is a single-function case study and does not generalize to the whole ML-KEM implementation.
- No CBMC result exists for this run, so no verification success or failure can be claimed from tool output.
- The selected property is a local frame/footprint claim; it does not establish modular arithmetic correctness, alias safety, or full functional equivalence.
- The reporting depends on logged stage records and rendered artefacts, not on hidden repository files that were not included in the evidence bundle.
- Two LLM stages are logged as unknown mode, which limits certainty about the provenance of every intermediate artefact.

## Deterministic fallback facts

# Agent 11 Evaluation Report

## Evaluation boundary

This report summarises the evidence recorded by the workflow. It does not claim full implementation correctness, FIPS 203 compliance, cryptographic security, or whole-program verification.

## Measured run facts

- Target function: `mlk_poly_add`
- Target topic: `Independent repaired-engine replication of open property discovery and candidate CBMC harness generation for ML-KEM polynomial addition`
- Property-discovery mode: `open_discovery`
- Catalogue visible during LLM discovery: `False`
- Raw candidate count: `5`
- Classified candidate count: `5`
- Selected property ID: `OPEN_CAND_002`
- Selection method: `open_discovery_feasibility_then_risk_then_rank`
- Expected workflow stages: `11`
- Indexed stage records: `11`
- Existing stage manifests: `6`
- Missing stage manifests: `5`
- Handoff outputs indexed: `34`
- Checksums indexed: `128`
- LLM stages indexed: `7`
- LLM calls executed: `5`
- LLM mode counts: `{'real': 5, 'unknown': 2}`
- Property-discovery mode: `None`
- Catalogue visible during LLM discovery: `False`
- Raw discovered candidates: `5`
- Post-classified candidates: `5`
- Selected property: `OPEN_CAND_002`
- Selected mapping status: `None`
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

- `FM_TOOL_001` — No formal-tool execution result: observed = `False`.
- `FM_TOOL_002` — Tool, build, instrumentation, or timeout failure: observed = `False`.
- `FM_PROP_001` — One or more emitted properties failed: observed = `False`.
- `FM_PROP_002` — One or more emitted properties were unknown: observed = `False`.
- `FM_PROP_003` — Failed and unknown properties coexist: observed = `False`.
- `FM_SCOPE_001` — Bounded selected-property success: observed = `False`.
- `FM_SCOPE_002` — Selected-property traceability incomplete: observed = `False`.
- `FM_EVIDENCE_001` — CBMC output was not structured JSON: observed = `False`.
- `FM_EVIDENCE_002` — No emitted property evidence: observed = `False`.
- `FM_EVIDENCE_003` — Tool execution and evidence are inconsistent: observed = `False`.
- `FM_ANALYSIS_001` — Analysis-only run: observed = `False`.
- `FM_CONTRACT_001` — Unrecognized Agent 7 result label: observed = `True`.
- `FM_REVIEW_001` — Review gate prevented tool execution: observed = `True`.

## Threats to validity

- `TV_SCOPE_001` (scope): The run is a selected-function case study, not whole-implementation verification. Mitigation: Report the exact target function, property, harness, assumptions, and CBMC command.
- `TV_TOOL_001` (tool evidence): CBMC output is property-specific and harness-specific. Mitigation: Use Agent 7 command/status/output and avoid full-correctness claims.
- `TV_LLM_001` (LLM usage): Some or all LLM stages may be mock/disabled rather than real API mode: {'real': 5, 'unknown': 2}. Mitigation: Separate mock wiring tests from real API-backed experimental runs.
- `TV_REPRO_001` (reproducibility): Integrity validation status is valid_with_warnings. Mitigation: Use Agent 10 checksums, handoff index, and replay manifest.
- `TV_GENERAL_001` (generalisation): A single target function/run cannot justify broad claims about all ML-KEM or PQC code. Mitigation: Frame findings as case-study evidence and discuss need for more functions/runs.

## Thesis-safe conclusion

The run should be described as a bounded case-study execution of a controlled LLM-assisted formal-methods workflow. The evidence supports statements about artefact generation, review gates, tool-execution status, reproducibility logging, and observed failure modes within the recorded run. It does not support claims of full ML-KEM correctness, FIPS 203 compliance, cryptographic security, or general performance across all PQC implementations.
