# Agent 11 Evaluation Report

## Claim boundary

This report is evidence-bounded. It does not claim full ML-KEM correctness, FIPS 203 compliance, cryptographic security, or whole-program verification.

## Thesis-safe wording

In the mlk_poly_add case study, the workflow produced a traceable candidate CBMC harness for a narrow local property: under explicit contract-aligned assumptions that each coefficient-wise sum fits within int16_t, the function should update each destination coefficient to the sum of its pre-state value and the corresponding source coefficient. However, this run did not yield formal-tool evidence, because the review stage stopped progression before Agent 7 and identified an execution-readiness issue in the harness/build configuration. Accordingly, the run supports discussion of artefact generation, review discipline, and pre-execution failure detection, but it does not support claims of verified correctness, full ML-KEM correctness, FIPS 203 compliance, or cryptographic security.

## Evaluation interpretation

{
  "status": "evidence_bounded_case_study_interpretation",
  "summary": "Within this single run, the workflow was useful for producing and reviewing a narrow candidate verification artefact for mlk_poly_add, but it did not deliver formal-tool evidence because the review gate stopped progress before Agent 7. The strongest substantive finding is therefore about workflow behaviour and artefact quality control, not about verified correctness of mlk_poly_add."
}

## Usefulness assessment

{
  "status": "partially_useful_with_pre_execution_stop",
  "bounded_statement": "For this mlk_poly_add case only, the workflow was useful for narrowing the claim boundary, extracting traceable evidence, generating a non-trivial candidate harness, and catching an execution-readiness defect before CBMC was run.",
  "supporting_observations": [
    "The repository contract and source code support a narrow local property: coefficient-wise in-place addition under explicit int16_t-safe-sum assumptions.",
    "The generated harness snapshots pre-state, calls the target function, and asserts a post-state relation tied to the source contract.",
    "The critic detected a concrete mismatch between the configured CBMC entry function name and the rendered harness symbol, which likely prevented a valid tool attempt if not corrected.",
    "The run retained bounded wording and explicitly excluded claims about canonical modulo-q output, full ML-KEM correctness, FIPS compliance, and cryptographic security."
  ]
}

## Failure-mode assessment

{
  "result_classification": "no_formal_result_recorded",
  "tool_outcome_category": "unknown_or_incomplete_tool_outcome",
  "rows": [
    {
      "taxonomy_id": "FM_TOOL_001",
      "label": "No formal-tool result because execution was skipped, dry-run, or unavailable",
      "observed_in_run": false,
      "evidence_basis": "The taxonomy row is marked false in the deterministic failure-mode log, but primary run evidence still shows that no CBMC result artifact was recorded.",
      "evaluation_implication": "Treat the run as lacking formal verification evidence; do not infer success or failure of the candidate property."
    },
    {
      "taxonomy_id": "FM_TOOL_002",
      "label": "CBMC/tool execution error or timeout",
      "observed_in_run": false,
      "evidence_basis": "No CBMC status or stderr/output files were logged, and there is no direct evidence of timeout or runtime tool failure.",
      "evaluation_implication": "Do not classify this run as a CBMC runtime failure; the stronger supported claim is that execution did not proceed to a logged result."
    },
    {
      "taxonomy_id": "FM_PROP_001",
      "label": "Verification failure/counterexample available",
      "observed_in_run": false,
      "evidence_basis": "No 07_tool_execution result and no 08_counterexample_analysis outputs are present.",
      "evaluation_implication": "No property counterexample can be discussed from this run."
    },
    {
      "taxonomy_id": "FM_SCOPE_001",
      "label": "Verification success is property-specific and scope-limited",
      "observed_in_run": false,
      "evidence_basis": "No success result exists to scope.",
      "evaluation_implication": "This taxonomy item remains conceptually relevant but was not observed because there was no successful CBMC result."
    },
    {
      "taxonomy_id": "FM_REVIEW_001",
      "label": "Review gate prevented tool execution",
      "observed_in_run": true,
      "evidence_basis": "Stage 06 review gate set final_gate to needs_revision_before_tool_execution and tool_execution_allowed to false; the critic cited the CBMC entry-point mismatch as a blocking issue.",
      "evaluation_implication": "The main observed failure mode in this run is pre-execution artefact/configuration gating rather than semantic verification failure."
    }
  ],
  "limitations": [
    "The run contains no raw CBMC output, so failure-mode analysis is limited to pre-execution workflow evidence.",
    "The deterministic taxonomy understates the practical consequence of missing CBMC evidence for FM_TOOL_001; primary evidence was used to keep wording conservative.",
    "No repair/refinement outputs exist, so downstream recovery behaviour cannot be evaluated."
  ]
}

## Human review and correction needs

{
  "required": true,
  "status": "required",
  "items": [
    "Revise the harness/build configuration so that the configured CBMC entry symbol matches the rendered function name, or rename the harness function to the expected entry point.",
    "Review whether the strong memory_no_alias/__CPROVER_is_fresh assumptions are acceptable for the intended proof scope, since they may over-constrain concrete aliasing behaviours.",
    "Review whether the selected conditional property is the desired thesis example, given that it assumes rather than derives the per-coefficient INT16 bounds from real callers.",
    "Check whether a second assertion in the harness is worth retaining, since the critic flagged it as partly redundant."
  ]
}

## Threats to validity

{
  "threats": [
    {
      "threat_id": "TV_SCOPE_001",
      "category": "scope",
      "threat": "This is a single-function, single-run case study focused on mlk_poly_add rather than whole-implementation verification.",
      "mitigation": "Limit claims to the local property family P16 and explicitly avoid whole-program or full-ML-KEM correctness language."
    },
    {
      "threat_id": "TV_TOOL_001",
      "category": "tool evidence",
      "threat": "No CBMC execution result was produced, so the study cannot evaluate semantic verification outcomes for this candidate harness.",
      "mitigation": "Report the run as a pre-execution workflow result and separate artefact-generation evidence from formal-tool evidence."
    },
    {
      "threat_id": "TV_LLM_001",
      "category": "LLM usage",
      "threat": "Although five LLM stages were logged as real, later LLM stages 08-09 are missing, so the workflow was not observed end-to-end through analysis/repair.",
      "mitigation": "State the exact number of real LLM calls observed and avoid extrapolating to stages that did not run."
    },
    {
      "threat_id": "TV_REPRO_001",
      "category": "reproducibility",
      "threat": "Integrity validation is valid_with_warnings, including missing stage manifests and missing CBMC status.",
      "mitigation": "Use the checksum manifest, handoff index, and reproducibility record for the produced artefacts, while reporting all missing outputs explicitly."
    },
    {
      "threat_id": "TV_ASSUMP_001",
      "category": "formalisation",
      "threat": "The selected harness scope depends on strong freshness and arithmetic assumptions that may not characterize all concrete executions of mlk_poly_add in context.",
      "mitigation": "Treat the candidate property as conditional and contract-aligned rather than universally representative of all callers."
    },
    {
      "threat_id": "TV_GENERAL_001",
      "category": "generalisation",
      "threat": "A pre-execution stop on one target function cannot justify broader claims about workflow effectiveness across PQC codebases.",
      "mitigation": "Frame findings as qualitative case-study evidence and motivate future repeated runs on additional functions and property families."
    }
  ]
}

## Limitations

- This report is evidence-bounded to one logged run for mlk_poly_add and should not be generalized to all ML-KEM functions.
- No CBMC execution result exists in the run evidence, so all discussion of the candidate property remains pre-verification.
- The selected property is conditional on source-contract assumptions, especially per-coefficient int16_t bounds and freshness-style pointer predicates.
- Traceability between mlk_poly_add and the FIPS 203 addition semantics is supported by comments and surrounding call structure, but not formally proven here.
- Integrity warnings and missing downstream stage outputs reduce completeness of the experimental record, even though the logger judged the record valid_with_warnings.

## Deterministic fallback facts

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
- Checksums indexed: `170`
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
