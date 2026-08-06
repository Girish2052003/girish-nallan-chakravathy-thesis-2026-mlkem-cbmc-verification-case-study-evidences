# Status and Exit Codes

## Process exit codes

```text
0  COMPLETE or COMPLETE_WITH_WARNINGS
2  INCOMPLETE due to contract, patch, required-tool, timeout, parse, integrity, or cleanup problem
3  unexpected internal failure
```

## Manifest status

- `COMPLETE` — exact patch applied to a disposable copy, required runs completed, authoritative inputs unchanged, cleanup confirmed, no warnings.
- `COMPLETE_WITH_WARNINGS` — core evidence captured but optional checks or declared transition observations produced warnings.
- `INCOMPLETE` — exact controlled experiment could not be completed safely or required evidence is incomplete.

## CBMC observation values

```text
PASS_REPORTED_BY_CBMC
FAIL_REPORTED_BY_CBMC
COMPLETED_STATUS_UNKNOWN
TOOL_ERROR
TIMEOUT
UNPARSEABLE_JSON
```

These are bounded tool-output observations, not scientific conclusions.
