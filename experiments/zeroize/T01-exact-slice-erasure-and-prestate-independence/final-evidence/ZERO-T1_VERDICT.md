# ZERO-T1 Final Verdict

## Target

`mlk_zeroize`

## Source binding

Commit:

`af4c5abdd5958bdc65a03cd5ee86708264f93304`

Parameter configuration:

`ML-KEM-768`

CBMC:

`6.9.0`

## Verified bounded domain

The host object contains 16 bytes.

For all symbolic values satisfying:

- `0 <= offset < 16`
- `1 <= length <= 16 - offset`

and for arbitrary initial byte values, the real `mlk_zeroize` implementation
overwrites every selected byte with zero.

## Accepted properties

- ZERO-T1.P1: selected bytes in arbitrary buffer A become zero.
- ZERO-T1.P2: selected bytes in independently initialized buffer B become zero.
- ZERO-T1.P3: selected post-state is independent of selected pre-state.
- ZERO-T1.NV1: an initially nonzero selected witness becomes zero.
- ZERO-T1.NV2: the witness changes from its nonzero pre-state.

## Body binding

The raw GOTO model contains:

- the real `mlk_zeroize` symbol;
- `memset(mlk_zeroize::ptr, 0, mlk_zeroize::len)`;
- the GCC inline-assembly compiler barrier and memory clobber.

The library-linked GOTO model submitted to CBMC contains:

- the harness;
- reachable calls to `mlk_zeroize`;
- the real target symbol;
- the zero-valued `memset` call;
- no target contract replacement.

## Results

Positive theorem:

- CBMC exit: `0`
- Result: `VERIFICATION SUCCESSFUL`
- Failed properties: `0 of 101`

Expected-failure control:

- CBMC exit: `10`
- Intended retained-byte assertion: `FAILURE`
- Result: `VERIFICATION FAILED`

## Classification

`ZERO_T1_RUN1_CLASSIFICATION=PASS`

## Limitation

This theorem proves source-level C memory-state behaviour within the stated
16-byte bounded host domain. It does not prove physical erasure, register or
cache clearing, or preservation of the wipe in every optimized binary.
