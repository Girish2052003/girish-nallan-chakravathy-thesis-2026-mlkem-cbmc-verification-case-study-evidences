# MSG-01K-R1 — MSG-T1 Mutation-Family Freeze

Status: **FROZEN BEFORE MUTANT PROPERTY SOLVING**

## Authoritative baseline

- source commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- positive GOTO SHA-256: `51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d`
- positive JSON SHA-256: `3b32112c5537a95d470b0b866c1edf6cb1f8c3be408188c9fc2cdbf91fab40ee`
- positive result: 521/521 successful;
- reachability/non-vacuity result: PASS.

## Frozen mutation family

- four implementation mutants;
- four oracle/assertion mutants;
- eight independent semantic witnesses;
- one intentionally changed file per mutant;
- actual target and helper bodies retained;
- same four-function reachable path;
- same five-loop structure;
- full derived unwindset for each model;
- all seven MSG-T1 markers retained.

## Execution acceptance rule

Every mutant must:

1. return CBMC exit 10;
2. fail the exact MSG-T1 assertion;
3. produce no unknown property status;
4. produce no unwinding failure at the frozen full bounds;
5. produce no failure outside the exact assertion and any explicitly
   registered boundary assertion.

The authoritative source, positive proof and non-vacuity evidence remain
unchanged.
