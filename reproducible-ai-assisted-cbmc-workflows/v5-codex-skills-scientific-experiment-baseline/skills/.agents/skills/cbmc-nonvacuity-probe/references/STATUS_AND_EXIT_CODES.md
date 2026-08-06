# Status and exit codes

## Process exit codes

- `0`: all required probes completed with an unambiguous reached/not-reached classification and authoritative inputs remained unchanged.
- `2`: invalid request, path, hash, source anchor, or safety constraint.
- `3`: at least one required probe timed out, failed to execute, or remained indeterminate.
- `5`: an authoritative tracked input changed during execution.

A process exit code is an execution/evidence status, never a proof-validity verdict.

## Probe statuses

- `REACHED_REPORTED_BY_CBMC`
- `NOT_REACHED_REPORTED_BY_CBMC`
- `INDETERMINATE`
- `TOOL_ERROR`
- `TIMEOUT`

## Report statuses

- `COMPLETE`
- `INCOMPLETE`
- `SOURCE_MUTATION_DETECTED`
