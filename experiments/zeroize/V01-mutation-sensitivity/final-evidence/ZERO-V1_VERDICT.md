# ZERO-V1 Final Verdict

## Purpose

ZERO-V1 evaluates the sensitivity of the accepted property suite against eight
locked, deliberately faulty local mutation models and release sequences.

## Source boundary

The authoritative mlkem-native repository was not modified.

The mutation sources are isolated local models designed to exercise the
intended property detectors.

## Mutants

- M1: remove the wipe;
- M2: fill using byte value one;
- M3: wipe one byte fewer than requested;
- M4: begin wiping one byte after the requested start;
- M5: wipe one byte beyond the requested interval;
- M6: expose memory to the release observer before wiping;
- M7: invoke the release observer twice;
- M8: omit the second adjacent partition.

## Result

Every mutant:

- differed from its paired reference;
- compiled successfully;
- passed CPROVER library instrumentation;
- retained a reachable mutant function;
- returned CBMC exit code 10;
- failed its planned detector;
- produced exactly one failed property;
- was classified as KILLED.

Final result:

- Total mutants: 8
- Killed mutants: 8
- Survived mutants: 0
- Error mutants: 0
- Mutation score: 100.00%

Classification:

`ZERO_V1_RUN1_CLASSIFICATION=PASS`

## Qualification

The mutation score applies only to the eight locked mutation models. It does
not establish completeness against every possible implementation fault.
