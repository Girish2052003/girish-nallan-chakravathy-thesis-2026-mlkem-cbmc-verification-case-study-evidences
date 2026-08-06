# Agent 7 Tool Execution Summary

- Tool: `cbmc_contract_pipeline`
- Tool executed: `True`
- Result classification: `contract_build_or_instrumentation_failed`
- Exit code: `1`
- Review gate: `approved_for_tool_execution`
- Force run: `False`

## Formal claim boundary

This stage records property-specific CBMC tool evidence under the exact generated harness, command, assumptions, tool version, and environment. It does not claim full ML-KEM correctness, FIPS 203 compliance, cryptographic security, or whole-program correctness.

## Property summary

- Parsed property results: `0`
- Parsed failures: `0`
- Parsed successes: `0`

## Diagnostic recommendation

Inspect goto-cc/goto-instrument output, contract syntax and transformation options before any property conclusion.
