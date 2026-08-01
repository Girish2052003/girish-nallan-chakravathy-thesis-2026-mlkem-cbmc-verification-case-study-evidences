# ZERO-T4 Final Verdict

## Target boundary

This theorem family checks the repository's `MLK_FREE` release-handoff
behaviour together with the real `mlk_zeroize` implementation.

## Source binding

Commit:

`af4c5abdd5958bdc65a03cd5ee86708264f93304`

CBMC:

`6.9.0`

Parameter configuration:

`ML-KEM-768`

## Run history

### Run1

Run1 failed before CBMC execution because the harness configuration conflicted
with the allocator macros already supplied by the native CBMC configuration.

Classification:

`HARNESS_CONFIGURATION_COMPILE_FAILURE`

The failed harnesses and compiler diagnostics are preserved in:

`RUN1_FAILED_ATTEMPT/`

### Run2

Run2 used two isolated configuration wrappers.

The default wrapper imported the native CBMC configuration and then removed
only its custom allocation/free selection, forcing the repository's unmodified
default stack-backed `MLK_ALLOC` and `MLK_FREE` branch.

The custom wrapper imported the native CBMC configuration and replaced only
the documented allocator/free hooks with observational harness hooks.

The authoritative repository was not modified.

## Accepted core properties

- ZERO-T4.P1: default MLK_FREE zeroizes the full 8-byte backing allocation.
- ZERO-T4.P2: default MLK_FREE sets the exposed pointer to NULL.
- ZERO-T4.P3: the custom free hook observes an all-zero allocation.
- ZERO-T4.P4: the custom free hook executes exactly once for non-null memory.
- ZERO-T4.P5: the custom free hook is not called for a null pointer.

## Diagnostic properties

- ZERO-T4.NV1: an initially nonzero default backing byte is wiped.
- ZERO-T4.NV2: custom allocation returns the observational backing object.
- ZERO-T4.NV3: custom free receives the complete allocation size.
- ZERO-T4.NV4: custom MLK_FREE resets the exposed pointer.
- ZERO-T4.NV5: null input remains null.

## Binding evidence

The Run2 raw and library-linked GOTO models establish:

- execution of the real `mlk_zeroize` body;
- execution of `memset(ptr, 0, len)`;
- parsing of the compiler barrier in the raw GOTO model;
- the call to `mlk_zeroize` before the custom release hook;
- absence of target contract replacement or stubbing.

Observed custom-handoff order:

- zeroization call: line 51;
- custom free call: line 53.

## Results

Default positive run:

- CBMC exit: `0`
- Failed properties: `0 of 92`
- Result: `VERIFICATION SUCCESSFUL`

Custom positive run:

- CBMC exit: `0`
- Failed properties: `0 of 124`
- Result: `VERIFICATION SUCCESSFUL`

Expected-failure controls:

- CBMC exit: `10`
- Failed controls: `4 of 112`
- Result: `VERIFICATION FAILED`

## Classification

`ZERO_T4_RUN2_CLASSIFICATION=PASS`

## Limitation

The default proof covers the repository's bounded 8-byte stack-backed branch.

The custom proof covers the documented release order using an observational
8-byte allocator model. It does not prove the behaviour of every possible
third-party allocator or physical-memory erasure after deallocation.
