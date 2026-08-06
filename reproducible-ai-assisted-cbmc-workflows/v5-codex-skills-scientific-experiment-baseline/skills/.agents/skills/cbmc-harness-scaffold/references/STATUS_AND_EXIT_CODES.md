# Status and exit codes

| Exit | Report status | Meaning |
|---:|---|---|
| 0 | `COMPLETE` | Source bindings passed; the neutral scaffold was generated; any required syntax check passed. |
| 0 | `COMPLETE_WITH_WARNINGS` | The scaffold was generated, but a non-required syntax check failed, timed out, or was unavailable. |
| 2 | `INCOMPLETE` | The scaffold could not be accepted as bound evidence, such as a source-hash mismatch or required syntax-check failure. |
| 3 | none required | Request/path/security contract error; the request was refused. |
| 5 | none required | Unexpected internal error. |

These are helper-execution statuses, not theorem or proof statuses.
