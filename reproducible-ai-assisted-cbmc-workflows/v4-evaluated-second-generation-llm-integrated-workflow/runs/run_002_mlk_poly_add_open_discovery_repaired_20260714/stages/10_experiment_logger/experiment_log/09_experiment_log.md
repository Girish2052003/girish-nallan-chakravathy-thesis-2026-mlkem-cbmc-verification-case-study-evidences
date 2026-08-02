# Agent 10 Experiment Log Summary

- Target function: `mlk_poly_add`
- Run directory: `/home/girish/THESIS-2026/thesis-pipeline/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714`
- Expected workflow stages: `11`
- Indexed stage records: `11`
- Existing stage manifests: `6`
- Missing stage manifests: `5`
- Handoff outputs indexed: `34`
- LLM calls executed: `5`
- Mock/mock-like LLM stages: `0`
- CBMC result classification: `None`
- CBMC tool executed: `None`
- Integrity status: `valid_with_warnings`
- Integrity warnings: `6`
- Integrity errors: `0`

## Claim boundary

Agent 10 is a deterministic evidence logger. It indexes artefacts, manifests, checksums, LLM-call records, and tool evidence. It does not claim proof, full correctness, FIPS 203 compliance, cryptographic security, or verification success.

## Integrity warnings

- `missing_stage_manifest`: Stage manifest missing: 07_tool_execution
- `missing_stage_manifest`: Stage manifest missing: 08_counterexample_analysis
- `missing_stage_manifest`: Stage manifest missing: 09_repair_refinement
- `missing_llm_validation`: LLM validation missing for 08_counterexample_analysis
- `missing_llm_validation`: LLM validation missing for 09_repair_refinement
- `missing_cbmc_status`: CBMC status file missing.
