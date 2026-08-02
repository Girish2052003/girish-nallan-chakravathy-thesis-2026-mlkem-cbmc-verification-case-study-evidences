# Native CBMC Loop and Function Contract Extension

## Scope

This extension adds an auditable native-contract path without changing repository source files. The original direct-CBMC harness path remains available and is the compatibility default for configs created before this extension.

## Function contracts

Agent 5 can produce a strict structured contract plan containing:

- `requires_clauses`
- `ensures_clauses`
- `assigns_clauses`
- `frees_clauses`
- `target_symbol`
- the exact function declaration
- enforcement/replacement and optional DFCC settings

Python renders the clauses into a candidate forced-include declaration. Agent 6 reviews the contract and formal-build plan. Agent 7 then executes:

```text
goto-cc ... -o 01_compiled_model.gb
goto-instrument [--dfcc harness] --enforce-contract symbol \
  [--replace-call-with-contract symbol] 01_compiled_model.gb 02_function_contracts_applied.gb
cbmc 02_function_contracts_applied.gb --function <entry> ...
```

Every command, stdout/stderr file, input/output model, model hash, exit code and result classification is preserved.

## Loop contracts

Agent 5 must provide:

- non-trivial `loop_invariant_clauses`
- optional `decreases_clauses`
- optional `loop_assigns_clauses`
- an exact loop-header anchor occurring exactly once
- written arguments for initialization, preservation and postcondition use

Python never patches the repository. It copies the approved source into the run folder, inserts annotations only at the exact anchor, records a unified diff and verifies the original source hash did not change. Agent 7 executes:

```text
goto-cc ... -o 01_compiled_model.gb
goto-instrument --apply-loop-contracts 01_compiled_model.gb 02_loop_contracts_applied.gb
cbmc 02_loop_contracts_applied.gb --function <entry> ...
```

## Fail-closed controls

The workflow rejects:

- `true`/`1` as production loop invariants;
- side-effecting invariant/precondition/postcondition expressions;
- `__CPROVER_old` inside loop invariants;
- `__CPROVER_loop_entry` inside function postconditions;
- decreases clauses without an invariant;
- ambiguous or missing source anchors;
- loop-body rewrites disguised as annotations;
- production source modification;
- contract strategies without a valid rendered contract bundle;
- transformation failure being reported as property failure or verification success.

## Scientific boundary

A generated clause is a candidate. Agent 6 approval means only that it is suitable for tool execution. GOTO transformation success means only that the model was constructed. CBMC success remains scoped to the transformed model, harness, clauses, source revision, options and assumptions. Human review remains mandatory.
