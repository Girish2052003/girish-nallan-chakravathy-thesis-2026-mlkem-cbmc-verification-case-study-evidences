# ZERO-T2 Final Verdict

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

The host object contains 16 bytes.

For every symbolic interval satisfying:

- `0 <= offset < 16`
- `0 <= length <= 16 - offset`

the real `mlk_zeroize` body was checked for frame confinement.

## Accepted core properties

- ZERO-T2.P1: every prefix byte remains unchanged.
- ZERO-T2.P2: every suffix byte remains unchanged.
- ZERO-T2.P3: a separate unrelated object remains unchanged.
- ZERO-T2.P4: a zero-length invocation preserves the complete host object.

## Diagnostic properties

- ZERO-T2.NV1: a concrete prefix guard remains unchanged.
- ZERO-T2.NV2: a concrete suffix guard remains unchanged.
- ZERO-T2.NV3: the selected concrete middle interval is actually wiped.

## Body binding

The raw GOTO model contains the real zero-valued memset operation and
compiler-barrier representation.

The library-linked GOTO model contains the harness-to-target calls, the real
target function, and the zero-valued memset operation. No target contract
replacement was used.

## Results

Positive theorem:

- CBMC exit: `0`
- Result: `VERIFICATION SUCCESSFUL`
- Failed properties: `0 of 109`

Expected-failure control:

- CBMC exit: `10`
- Untouched-prefix false claim: `FAILURE`
- Result: `VERIFICATION FAILED`

## Classification

`ZERO_T2_RUN1_CLASSIFICATION=PASS`

## Limitation

This proof concerns source-level C abstract-machine memory state over the
specified 16-byte bounded host domain.
