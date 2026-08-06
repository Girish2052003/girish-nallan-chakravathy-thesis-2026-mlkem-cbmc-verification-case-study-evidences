# CBMC Counterexample View

- Request ID: `mlk-poly-sub-counterexample-001`
- Report status: `COMPLETE`
- View outcome: `COUNTEREXAMPLE_VIEW_CREATED`
- Failed property: `main.assertion.1`
- Property status as recorded: `FAILURE`
- Raw trace steps: `12`
- Visible normalized steps: `11`
- Selected compact steps: `9`
- Semantic authority: `NONE`

## Mandatory interpretation boundary

This output is a mechanical, bounded presentation of trace data recorded in the supplied CBMC JSON. It does not diagnose the mathematical or software cause, recommend a repair, determine whether the harness is wrong, or determine whether the implementation contains a defect.

## Failed property record

- Description: coefficient lower bound
- Source location: `{"file": "harness.c", "function": "main", "line": "29"}`

## Compact trace

| Selected | Raw | Type | Function | LHS | Value | Source | Reasons |
|---:|---:|---|---|---|---|---|---|
| 0 | 0 | function-call | main |  |  | harness.c:25 | FUNCTION_STEP, TARGET_FUNCTION_EXACT_MATCH |
| 1 | 1 | assignment | mlk_poly_sub | mlk_poly_sub::r | &r | poly.c:101 | TARGET_FUNCTION_EXACT_MATCH |
| 2 | 2 | assignment | mlk_poly_sub | mlk_poly_sub::i | 0 | poly.c:104 | TARGET_FUNCTION_EXACT_MATCH |
| 3 | 4 | assumption | main |  |  | harness.c:21 | ASSUMPTION_STEP |
| 4 | 5 | assignment | mlk_poly_sub | r.coeffs[0] | -3329 | poly.c:106 | TARGET_FUNCTION_EXACT_MATCH, TARGET_VARIABLE_LITERAL_MATCH |
| 5 | 8 | function-return | mlk_poly_sub |  |  | poly.c:108 | FUNCTION_STEP, TARGET_FUNCTION_EXACT_MATCH |
| 6 | 9 | assignment | main | observed | -3329 | harness.c:28 | TARGET_VARIABLE_LITERAL_MATCH |
| 7 | 10 | assertion | main |  |  | harness.c:29 | FAILURE_STEP, TARGET_VARIABLE_LITERAL_MATCH |
| 8 | 11 | function-return | main |  |  | harness.c:31 | FUNCTION_STEP, TRACE_ENDPOINT |

## Latest observed assignments

These are only the latest assignments observed in the selected trace steps; they are not a complete program state.

```json
[
  {
    "lhs": "observed",
    "original_index": 9,
    "source_location": {
      "file": "harness.c",
      "function": "main",
      "line": "28"
    },
    "value": "-3329"
  },
  {
    "lhs": "r.coeffs[0]",
    "original_index": 5,
    "source_location": {
      "file": "poly.c",
      "function": "mlk_poly_sub",
      "line": "106"
    },
    "value": "-3329"
  }
]
```

## Warnings

- None

## Raw evidence

The complete input trace is not rewritten or interpreted. Its exact path and SHA-256 are recorded in `input_manifest.json`.
