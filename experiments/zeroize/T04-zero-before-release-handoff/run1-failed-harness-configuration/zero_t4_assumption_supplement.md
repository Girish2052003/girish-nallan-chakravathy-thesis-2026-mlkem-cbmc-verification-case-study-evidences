# ZERO-T4 Assumption Supplement

T4.A1. The default-branch harness uses the repository's unmodified MLK_ALLOC
and MLK_FREE default stack-allocation macros.

T4.A2. The custom-branch harness enables MLK_CONFIG_CUSTOM_ALLOC_FREE and
supplies observational allocator/free hooks solely at the documented
configuration boundary.

T4.A3. The custom free hook observes the pointed-to bytes at hook entry. It
does not invoke, replace or simulate mlk_zeroize.

T4.A4. The custom allocation model returns one live, sufficiently sized
8-byte backing object for the non-null branch.

T4.A5. The null-branch test supplies a null pointer directly and checks that
the custom free hook is not called.

T4.A6. The theorem proves the MLK_FREE handoff order and state for these
bounded harness models. It does not prove properties of every possible
third-party allocator implementation.
