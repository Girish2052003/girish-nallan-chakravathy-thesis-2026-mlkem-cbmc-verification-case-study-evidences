# ZERO Campaign Assumption Registry

A1. The authoritative source is commit
af4c5abdd5958bdc65a03cd5ee86708264f93304.

A2. The authoritative production source tree remains unmodified.

A3. The selected pointer refers to a live host object.

A4. The selected interval is entirely within that host object.

A5. ZERO-T1 uses a valid non-empty interval. Zero-length identity is reserved
for ZERO-T2.

A6. Independently declared host arrays are separate, non-overlapping objects.

A7. The real mlk_zeroize body executes.

A8. mlk_zeroize must not be replaced by its function contract, a stub, a
custom harness implementation, or an uninterpreted function.

A9. The default CBMC configuration uses standard memset and the repository's
GCC/Clang inline-assembly zeroization branch.

A10. No contradictory assumption, assume(false), unreachable target call,
or tautological assertion is permitted.

A11. CBMC's CPROVER memset model is used for the standard-library call reached
from the real mlk_zeroize implementation body.

A12. The result concerns source-level C abstract-machine memory state only.
