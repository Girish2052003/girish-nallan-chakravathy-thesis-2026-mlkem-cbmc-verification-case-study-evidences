# Boundary and probe catalogue

## Probe kinds

### `FEASIBLE_EXECUTION`
Places the caller-selected cover goal at an exact end-of-path or other feasibility marker. The tool does not choose the marker.

### `TARGET_CALL_REACHABILITY`
Requires the supplied exact anchor line to contain a lexical call to the caller-supplied target symbol. It does not prove dynamic dispatch, meaningful use of outputs, or theorem relevance.

### `ASSERTION_LOCATION_REACHABILITY`
Requires the exact anchor line to contain `__CPROVER_assert(...)` or C `assert(...)`. Insert `before` when asking whether control can reach the assertion location without relying on coverage-mode treatment after the assertion.

### `CUSTOM_ANCHOR_REACHABILITY`
Places a probe at any exact caller-selected C source line. The caller owns the scientific justification.

## Coverage-mode caution

CBMC coverage mode is diagnostic. User assertions may affect or be transformed during coverage processing. The command, companion source, and raw output must therefore be inspected before interpreting a reachability result. The companion run never replaces the authoritative proof run.
