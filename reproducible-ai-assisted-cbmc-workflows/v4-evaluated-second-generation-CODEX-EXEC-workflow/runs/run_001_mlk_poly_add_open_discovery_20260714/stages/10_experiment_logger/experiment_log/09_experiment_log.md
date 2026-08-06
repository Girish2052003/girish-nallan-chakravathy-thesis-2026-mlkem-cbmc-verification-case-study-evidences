# Agent 10 Experiment Log Summary

- Target function: `mlk_poly_add`
- Run directory: `/home/girish/THESIS-2026/thesis-pipeline/runs/run_001_mlk_poly_add_open_discovery_20260714`
- Expected workflow stages: `11`
- Indexed stage records: `11`
- Existing stage manifests: `8`
- Missing stage manifests: `3`
- Handoff outputs indexed: `55`
- LLM calls executed: `6`
- Mock/mock-like LLM stages: `0`
- CBMC result classification: `contract_build_or_instrumentation_failed`
- CBMC tool executed: `True`
- Integrity status: `valid_with_warnings`
- Integrity warnings: `2`
- Integrity errors: `0`

## Claim boundary

Agent 10 is a deterministic evidence logger. It indexes artefacts, manifests, checksums, LLM-call records, and tool evidence. It does not claim proof, full correctness, FIPS 203 compliance, cryptographic security, or verification success.

## Integrity warnings

- `missing_stage_manifest`: Stage manifest missing: 09_repair_refinement
- `missing_llm_validation`: LLM validation missing for 09_repair_refinement
