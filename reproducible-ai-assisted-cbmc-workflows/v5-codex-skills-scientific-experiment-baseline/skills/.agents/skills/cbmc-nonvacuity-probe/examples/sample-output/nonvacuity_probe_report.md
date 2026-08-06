# CBMC Non-Vacuity Probe Report

- Report status: `COMPLETE`
- Target symbol: `vector_subtract`
- Semantic authority: `NONE`
- Authoritative inputs unchanged: `true`

## Probe results

| Probe | Kind | Result | Required |
|---|---|---|---|
| `target-call` | `TARGET_CALL_REACHABILITY` | `REACHED_REPORTED_BY_CBMC` | `true` |
| `assertion-location` | `ASSERTION_LOCATION_REACHABILITY` | `REACHED_REPORTED_BY_CBMC` | `true` |

## Mandatory interpretation limits

- A reached probe means only that CBMC reported the inserted cover goal reachable in the exact captured bounded run.
- A reached target-call probe does not prove that the target result is used meaningfully or that the candidate theorem is non-vacuous.
- An unreached probe does not identify whether assumptions, bounds, build context, probe placement, the implementation, or tool configuration caused the result.
- Coverage mode and disposable instrumentation are diagnostic evidence, not the authoritative proof run.
- The authoritative harness and source files remain the scientific artefacts; companion trees are disposable diagnostics.
