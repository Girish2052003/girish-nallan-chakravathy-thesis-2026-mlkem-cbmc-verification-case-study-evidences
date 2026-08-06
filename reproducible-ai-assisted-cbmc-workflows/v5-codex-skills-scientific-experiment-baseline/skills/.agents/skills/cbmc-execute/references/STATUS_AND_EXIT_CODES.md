# Status and exit-code contract

## Report status

- `COMPLETE` — requested execution evidence was captured without wrapper warnings.
- `COMPLETE_WITH_WARNINGS` — analysis evidence exists, but an auxiliary item such as inventory or a declared artifact is incomplete, or CBMC status remained mechanically inconclusive.
- `INCOMPLETE` — timeout, malformed JSON, tool error, or source mutation prevented complete execution evidence.

## Tool outcome

- `PASS_REPORTED_BY_CBMC`
- `FAIL_REPORTED_BY_CBMC`
- `COMPLETED_STATUS_UNKNOWN`
- `TOOL_ERROR`
- `TIMEOUT`
- `UNPARSEABLE_JSON`
- `SOURCE_MUTATION_DETECTED`

These are evidence labels, not scientific verdicts.

## Wrapper exit codes

| Code | Meaning |
|---:|---|
| 0 | Complete evidence captured, including a CBMC-reported property failure |
| 2 | Incomplete tool evidence |
| 3 | Request/path/option/executable contract error |
| 4 | Declared input SHA-256 mismatch |
| 5 | Tracked input changed during execution |
| 6 | Unexpected internal wrapper error |
