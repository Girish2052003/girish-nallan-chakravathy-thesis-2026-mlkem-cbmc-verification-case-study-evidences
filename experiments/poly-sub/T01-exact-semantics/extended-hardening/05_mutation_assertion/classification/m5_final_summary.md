# M5 final assertion-mutant result

## Classification

- Result: `FAIL_EXPECTED_MUTANT_KILLED`
- Production source modified: `no`
- Input assumptions modified: `no`
- Deliberate mutation: canonical expected value shifted by `+1 modulo 3329`.

## Property inventory

- Positive-control inventory: `89`
- M5 inventory: `90`
- Expected delta: one additional safety property in harness `main` caused by the new `+1U` expression.

## Result

- Target assertion failures: `1`
- Non-target failures: `0`
- Unwinding failures: `0`

CBMC rejected the deliberately false semantic assertion while every non-target property remained successful. This demonstrates that the canonical assertion is reachable and non-vacuous.
