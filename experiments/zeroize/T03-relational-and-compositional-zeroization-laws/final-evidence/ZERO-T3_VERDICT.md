# ZERO-T3 Final Verdict

## Target

`mlk_zeroize`

## Source binding

Commit:

`af4c5abdd5958bdc65a03cd5ee86708264f93304`

CBMC:

`6.9.0`

Parameter configuration:

`ML-KEM-768`

## Verified bounded domain

All relational executions use equally initialized 16-byte host objects.
Offsets and lengths are symbolic and constrained to valid non-empty intervals.

## Accepted core properties

- ZERO-T3.P1: repeated zeroization is idempotent.
- ZERO-T3.P2: adjacent partitions equal their combined interval.
- ZERO-T3.P3: disjoint zeroizations commute.
- ZERO-T3.P4: overlapping zeroizations equal zeroization of their union.

## Non-vacuity diagnostics

Each relational property includes selected nonzero witness bytes and proves
that the relevant executions actually wipe those witnesses.

## Body binding

The raw GOTO model contains the real zero-valued memset operation and compiler
barrier. The library-linked model retains the harness calls, target body and
zero-valued memset operation, without target-contract replacement.

## Results

Positive theorem:

- CBMC exit: `0`
- Failed properties: `0 of 181`
- Result: `VERIFICATION SUCCESSFUL`

Expected-failure control:

- CBMC exit: `10`
- False idempotence-difference assertion: `FAILURE`
- Result: `VERIFICATION FAILED`

## Classification

`ZERO_T3_RUN1_CLASSIFICATION=PASS`

## Detector-coverage qualification

The present expected-failure control directly exercises idempotence. Dedicated
partition, disjoint-order and overlap-union mutants remain required during the
campaign mutation-sensitivity stage.

## Limitation

These properties concern source-level C memory state over the specified
16-byte bounded host domain.
