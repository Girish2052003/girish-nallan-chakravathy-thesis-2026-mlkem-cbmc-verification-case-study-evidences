# SUB-T6 final verification verdict

The SUB-T6 campaign passed for the frozen ML-KEM-768 configuration.

The positive proof suite established T6.1–T6.7 for the registered bounded
production slice. The campaign recorded 2343 successful positive
CBMC properties, 365 successful reachability-companion
properties, 12/12 non-vacuity covers, three isolated
expected-failure controls, and a mandatory mutation score of 4/4.

Removing `mlk_poly_reduce` was detected by both registered T6.6 canonical-input
bounds. The same mutant also produced the documented downstream conversion
failure `mlk_scalar_compress_d1.overflow.1`, because the deliberately
noncanonical negative value was passed to `mlk_poly_tomsg`. This collateral
failure is preserved and classified separately; it is not counted as an
unrelated failure.

This remains a property-specific bounded proof, not a proof of complete K-PKE
decryption, all upstream cryptographic operations, allocator failure paths,
constant-time behaviour, side-channel freedom, or end-to-end ML-KEM.
