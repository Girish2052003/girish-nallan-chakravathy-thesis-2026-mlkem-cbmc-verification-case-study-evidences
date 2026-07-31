# MSG-01J-R3 — Authoritative Reachability and Non-Vacuity Result

## Accepted full-bound companion

```text
CBMC_EXIT=0
PROPERTY_RECORD_COUNT=522
SUCCESS_COUNT=522
FAILURE_COUNT=0
UNKNOWN_COUNT=0
ANCHOR_STATUS=SUCCESS
```

## Loop-bound sensitivity

```text
MULTI_ITERATION_CONTROL_COUNT=4
PASSED_MULTI_ITERATION_CONTROL_COUNT=4
TARGET_LOOP_0_BOUND1_SUFFICIENT=PASS
```

Insufficient bounds were detected for:

- both harness loops;
- the production inner loop;
- the production outer loop.

The macro-origin target loop at source line 720 was shown to be complete with
bound one.

## Untouched original-model coverage

```text
COVERAGE_EXIT=0
COVERED=12
TOTAL=12
SATISFIED_LINES=12
FAILED_LINES=0
```

All twelve boundary, region and output-position goals were satisfied after the
actual production `mlk_poly_tomsg` execution.

## Supported conclusion

The authoritative positive MSG-T1 result is non-vacuous for the registered
canonical input classes and selected output positions. The full-bound
companion succeeded, insufficient bounds were detected for every
multi-iteration reachable loop, and all twelve original-model coverage goals
were satisfiable.

Mutation-sensitivity controls remain the final MSG-T1 campaign gate.
