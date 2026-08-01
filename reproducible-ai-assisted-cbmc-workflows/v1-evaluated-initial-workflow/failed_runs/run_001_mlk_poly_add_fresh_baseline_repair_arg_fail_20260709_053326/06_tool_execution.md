# Agent 7 v2 — Formal Tool Execution Report

- **Created at:** 2026-07-09T02:29:06+00:00
- **Tool:** CBMC
- **Target function:** `mlk_poly_add`
- **Harness function:** `harness_mlk_poly_add`
- **Artifact:** `/home/girish/thesis-agent-workflow/runs/run_001_mlk_poly_add_fresh_baseline/04_generated_harness.c`
- **Iteration:** 0
- **Status:** `dry_run`
- **Execution status:** `dry_run_not_executed`
- **Runtime seconds:** 0.0
- **Counterexample available:** False

## Critic Gate

- Decision: `allowed_to_prepare_or_run_tool`
- Blocked: `False`
- Force used: `False`
- Critic review status: conditional_accept_for_tool

## Command

```bash
cbmc /home/girish/thesis-agent-workflow/runs/run_001_mlk_poly_add_fresh_baseline/04_generated_harness.c /home/girish/thesis-agent-workflow/inputs/code/poly.c -I /home/girish/thesis-agent-workflow/inputs/code --function harness_mlk_poly_add --bounds-check --pointer-check --signed-overflow-check --unsigned-overflow-check --unwind 256 --unwinding-assertions --trace
```

## Tool Result Summary

Dry run only. CBMC command was generated but not executed.

## Diagnostics

- Category guess: `['pointer_failure', 'integer_overflow_failure', 'unwinding_issue', 'assertion_failure']`
- Failed property types: `[]`
- Property results: `0`

## Property Mapping

- CBMC property result count: `0`
- Known candidate property count: `63`
- Matched mappings: `0`

## Scientific Guardrail

This result applies only to the selected candidate harness/properties under recorded assumptions. It is not a proof of the full ML-KEM implementation. Human review remains required.

## Output Files

- `06_cbmc_output.txt`
- `06_cbmc_status.json`
- `06_cbmc_command.txt`
- `06_tool_execution.md`
- `06_cbmc_property_results.json`
- `06_tool_command_manifest.json`
- `06_tool_environment_snapshot.json`
- `06_critic_gate_decision.json`
- `06_cbmc_diagnostics.json`
- `06_cbmc_trace_summary.json`
- `06_failed_property_mapping.json`
- `06_property_mapping.csv`
- `06_tool_execution_traceability.json`
