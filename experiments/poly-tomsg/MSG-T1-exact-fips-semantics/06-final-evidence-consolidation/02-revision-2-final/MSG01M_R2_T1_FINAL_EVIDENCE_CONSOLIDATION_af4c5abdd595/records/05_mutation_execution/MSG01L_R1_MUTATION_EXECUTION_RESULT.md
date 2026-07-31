# MSG-01L-R1 — Authoritative MSG-T1 Mutation-Sensitivity Result

## Frozen baseline

- source commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`;
- positive GOTO SHA-256: `51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d`;
- positive JSON SHA-256: `3b32112c5537a95d470b0b866c1edf6cb1f8c3be408188c9fc2cdbf91fab40ee`;
- authoritative positive result: PASS;
- authoritative reachability/non-vacuity result: PASS.

## Mutation family

```text
TOTAL_MUTANTS=8
IMPLEMENTATION_MUTANTS=4
ORACLE_ASSERTION_MUTANTS=4
SEMANTIC_WITNESSES=8
```

Every mutant changed exactly one registered file and was frozen before solving.

## Execution result

```text
EXECUTED_MUTANTS=8
KILLED_MUTANTS=8
SURVIVING_MUTANTS=0
```

Each mutant returned CBMC exit 10 and failed the registered exact MSG-T1
functional assertion. No mutant failed an unwinding assertion at the frozen
full bounds, and no unexpected property failure was accepted.

## Supported conclusion

The accepted positive result is sensitive to the registered implementation,
oracle and coefficient/bit-mapping semantics. The evidence therefore rejects
the possibility that the exact assertion passes merely because it is
disconnected from those selected semantic details.

This is mutation sensitivity for the eight frozen mutants. It is not a claim
of completeness over every possible source, oracle or harness mutation.
