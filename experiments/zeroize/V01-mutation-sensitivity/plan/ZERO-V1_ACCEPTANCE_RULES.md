# ZERO-V1 Acceptance Rules

For each mutant, record:

- mutant identifier;
- authoritative-source hash;
- local-mutant source hash;
- exact textual diff;
- compile exit code;
- library-link exit code;
- target-reachability witness;
- CBMC exit code;
- failed property identifier;
- semantic counterexample classification;
- final killed/survived/error result.

Permitted classifications:

- `KILLED`
- `SURVIVED`
- `COMPILE_ERROR`
- `TOOL_ERROR`
- `TIMEOUT`
- `INVALID_MUTANT`

Only `KILLED` counts as mutation sensitivity.

A compile failure, timeout or tool failure must never be reported as a killed
mutant.
