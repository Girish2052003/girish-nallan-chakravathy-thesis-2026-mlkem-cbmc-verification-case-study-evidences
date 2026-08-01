# ZERO Campaign Theorem Registry

## Campaign boundary

Target implementation:

`mlk_zeroize`

Pinned commit:

`af4c5abdd5958bdc65a03cd5ee86708264f93304`

The campaign verifies source-level C memory-state properties. It does not
claim physical data destruction, register clearing, cache clearing, or
retention of the wipe in every optimized machine-code build.

## ZERO-T1 — Exact slice erasure and pre-state independence

T1.P1:
For every valid non-empty selected interval, every selected byte in the first
arbitrary input buffer equals zero after the real mlk_zeroize body executes.

T1.P2:
For every valid non-empty selected interval, every selected byte in the second
independently initialized arbitrary buffer equals zero after execution.

T1.P3:
The selected final bytes are independent of their initial values: independently
initialized selected slices have identical all-zero final states.

Diagnostic control:
At least one concretely selected symbolic witness byte is constrained to be
nonzero before zeroization and must equal zero afterward.

## ZERO-T2 — Frame confinement and zero-length identity

T2.P1: Prefix bytes before the selected interval remain unchanged.

T2.P2: Suffix bytes after the selected interval remain unchanged.

T2.P3: A separate unrelated live object remains unchanged.

T2.P4: A zero-length invocation leaves the complete host object unchanged.

## ZERO-T3 — Relational and compositional zeroization laws

T3.P1: Repeated zeroization of the same interval is idempotent.

T3.P2: Adjacent partitioned zeroizations equal one combined zeroization.

T3.P3: Zeroizations of disjoint intervals commute.

T3.P4: Zeroizations of overlapping intervals equal zeroization of their union.

## ZERO-T4 — Zero-before-release handoff

T4.P1:
The default stack-backed MLK_FREE branch zeroizes its complete backing
allocation.

T4.P2:
The default branch sets the exposed pointer variable to NULL after zeroization.

T4.P3:
The custom deallocation hook observes an all-zero allocation.

T4.P4:
For a non-null custom allocation, the custom deallocation hook executes once.

T4.P5:
For a null custom allocation, the custom deallocation hook is not invoked.

## Count

Theorem families: 4

Core semantic properties: 16

This registry freezes the internal campaign design. Broader literature-level
novelty remains subject to a documented literature-overlap census.
