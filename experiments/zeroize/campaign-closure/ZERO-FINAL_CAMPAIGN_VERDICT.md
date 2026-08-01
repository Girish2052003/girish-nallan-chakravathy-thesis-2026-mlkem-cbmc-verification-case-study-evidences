# ZERO Final Campaign Verdict

## Campaign

Source-Level Zeroization and Release-Handoff Verification

## Target

`mlk_zeroize` and its `MLK_FREE` release-handoff boundary

## Authoritative source

Commit:

`af4c5abdd5958bdc65a03cd5ee86708264f93304`

Tree:

`54805daff6a91a010c05467ea678117c42a71559`

Parameter configuration:

`ML-KEM-768`

Verification tool:

`CBMC 6.9.0`

## Core theorem result

Four theorem families were accepted:

- ZERO-T1: exact selected-slice erasure and pre-state independence;
- ZERO-T2: frame confinement and zero-length identity;
- ZERO-T3: relational and compositional zeroization laws;
- ZERO-T4: default and custom release-handoff behaviour.

Core property result:

`16 of 16 accepted`

## Positive CBMC results

- ZERO-T1: 0 of 101 properties failed.
- ZERO-T2: 0 of 109 properties failed.
- ZERO-T3: 0 of 181 properties failed.
- ZERO-T4 default branch: 0 of 92 properties failed.
- ZERO-T4 custom branch: 0 of 124 properties failed.

## Mutation sensitivity

Eight locked local mutation models and faulty release sequences were evaluated:

- Total mutants: 8
- Killed mutants: 8
- Survived mutants: 0
- Error mutants: 0
- Mutation score: 100.00%

The score applies only to the eight selected mutation models.

## Preserved unsuccessful attempts

ZERO-T4 Run1 failed before CBMC execution because of harness allocator
configuration errors.

ZERO-FINAL Run1 stopped because of a non-portable awk verifier expression.

Both failures are preserved and classified. Neither was an implementation
counterexample.

## Supported claim

For the pinned source commit and documented bounded harness domains, CBMC
verified the real source-level `mlk_zeroize` implementation across exact
erasure, frame confinement, compositional behaviour, and release-handoff
properties. The selected property suite also rejected all eight locked local
mutation models.

## Limitations

This campaign does not establish:

- universal correctness for every object size or calling context;
- physical-memory erasure;
- register, cache, swap, allocator-metadata or microarchitectural erasure;
- preservation of wiping in every optimized machine-code binary;
- correctness of every possible third-party allocator;
- detection of every possible implementation fault;
- literature-wide novelty without a separate literature review.

The results concern C abstract-machine behaviour within the documented bounded
models and configurations.
