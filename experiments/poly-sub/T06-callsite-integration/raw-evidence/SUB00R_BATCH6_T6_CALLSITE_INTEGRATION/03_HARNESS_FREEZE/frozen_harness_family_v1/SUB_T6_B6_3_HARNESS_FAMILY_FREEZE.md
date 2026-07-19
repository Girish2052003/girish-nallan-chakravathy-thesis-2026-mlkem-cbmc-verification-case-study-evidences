# SUB-T6 B6.3 — Frozen Call-Site Integration Harness Family

## Status

FROZEN after static validation.

## Positive harnesses

1. sub_t6_callsite_precondition_harness.c — T6.1 and T6.2.
2. sub_t6_callsite_exactness_harness.c — T6.3.
3. sub_t6_callsite_frame_harness.c — T6.4.
4. sub_t6_sub_reduce_handoff_harness.c — T6.5.
5. sub_t6_tomsg_precondition_harness.c — T6.6 and the T6.7 slice boundary.

## Exact production functions

- mlk_poly_sub from frozen source/mlkem/src/poly.c.
- mlk_poly_reduce from frozen source/mlkem/src/poly.c.
- mlk_poly_tomsg from frozen source/mlkem/src/compress.c.

## Domain model

- 0 <= v[i] < 3329.
- -26632 < sb[i] < 26632.
- Signed-16 representability is asserted after widened subtraction; it is not assumed.
- Complete distinct automatic objects instantiate the successful allocation path.
- Allocator correctness and out-of-memory behavior are not proved.

## Support provenance

The zero opt-blocker support translation unit is copied byte-for-byte from the
validated frozen Batch-5 family. Its source and copied hashes are recorded.
The Batch-6 common, pragma and fail-closed zeroize support files are new
Batch-6 artefacts.

## Boundary

This family contains no modified production source and is not CBMC proof
evidence. GOTO construction and model inspection occur in B6.4.
