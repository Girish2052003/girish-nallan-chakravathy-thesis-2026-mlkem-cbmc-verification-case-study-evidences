# Status and Exit Codes

## Successful evidence construction

Exit `0`:

- `report_status = COMPLETE`; or
- `report_status = COMPLETE_WITH_WARNINGS`.

The only successful view outcome is:

- `COUNTEREXAMPLE_VIEW_CREATED`.

Warnings can report mechanical limitations such as selection truncation, unknown step-type fields, or no literal match for an optional focus term.

## Contract refusal

Exit `3` is used before evidence construction when, for example:

- request JSON is malformed or violates the closed contract;
- paths are absolute, traversing, symlinked, missing, or unsafe;
- the raw trace hash does not match;
- the input is not supported JSON;
- the selected property does not exist;
- the selected property is not recorded as failed/violated;
- no trace array exists;
- multiple trace-bearing records make the exact property ambiguous;
- the trace exceeds a declared safety limit;
- the output already exists or is inside the input root.

## Internal failure

Exit `5` indicates an unexpected implementation failure.

No status or exit code means that a theorem, diagnosis, repair, or defect classification is scientifically valid.
