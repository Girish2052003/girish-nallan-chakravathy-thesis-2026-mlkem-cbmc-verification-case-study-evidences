# Agent 7 v2 — Formal Tool Execution Report

- **Created at:** 2026-07-09T04:01:34+00:00
- **Tool:** CBMC
- **Target function:** `mlk_poly_add`
- **Harness function:** `harness_mlk_poly_add`
- **Artifact:** `/home/girish/thesis-agent-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/04_generated_harness.c`
- **Iteration:** 0
- **Status:** `passed`
- **Execution status:** `executed`
- **Runtime seconds:** 8.839
- **Counterexample available:** False

## Critic Gate

- Decision: `allowed_to_prepare_or_run_tool`
- Blocked: `False`
- Force used: `False`
- Critic review status: conditional_accept_for_tool

## Command

```bash
cbmc /home/girish/thesis-agent-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/04_generated_harness.c /home/girish/thesis-agent-workflow/inputs/code/poly.c -I /home/girish/thesis-agent-workflow/inputs/code --function harness_mlk_poly_add --bounds-check --pointer-check --signed-overflow-check --unsigned-overflow-check --unwind 257 --unwinding-assertions --trace --object-bits 8
```

## Tool Result Summary

CBMC reported VERIFICATION SUCCESSFUL for the selected harness/properties.

## Diagnostics

- Category guess: `['pointer_failure', 'bounds_failure', 'integer_overflow_failure', 'assertion_failure']`
- Failed property types: `[]`
- Property results: `228`

## Property Mapping

- CBMC property result count: `228`
- Known candidate property count: `63`
- Matched mappings: `155`

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
