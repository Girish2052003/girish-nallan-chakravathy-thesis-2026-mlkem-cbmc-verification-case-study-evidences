# CBMC Execution Evidence

- Request: `synthetic-sample-pass-001`
- Report status: **COMPLETE**
- Tool outcome: **PASS_REPORTED_BY_CBMC**
- Semantic authority: **NONE**
- CBMC exit code: `0`
- Termination: `COMPLETED`

## Exact analysis command

```text
/mnt/data/v5_skill_03_build/cbmc-execute/tests/fixtures/bin/cbmc -I include --trace --symex-coverage-report /mnt/data/v5_skill_03_build/cbmc-execute/examples/sample-output/artifacts/coverage.xml --json-ui /mnt/data/v5_skill_03_build/cbmc-execute/tests/fixtures/workspace/src/demo.c /mnt/data/v5_skill_03_build/cbmc-execute/tests/fixtures/workspace/src/harness.c
```

## Normalized property counts

- total: `1`
- success: `1`
- failure: `0`
- unknown: `0`

## Warnings and limitations

- The wrapper reports CBMC evidence for the exact captured bounded command; it does not establish unbounded or complete program correctness.
- The wrapper does not judge whether assumptions, assertions, properties, loop bounds, or source selection are scientifically justified.
- Only explicitly declared tracked inputs are protected by before/after SHA-256 comparison.
- A normalized status is a mechanical rendering of CBMC JSON fields, not an independent proof judgement.

## Interpretation boundary

A PASS_REPORTED_BY_CBMC outcome records only what CBMC reported for the exact bounded command, inputs, options, tool version, and environment captured here. It is not a declaration of complete functional correctness, theorem usefulness, assumption validity, source authenticity beyond the tracked hashes, or proof completeness.
