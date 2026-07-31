# Complete `mlk_poly_tobytes` closure index

This directory binds the four frozen theorem-family closures for the
portable `mlk_poly_tobytes` implementation.

The frozen campaign contains 19 obligations:

- T1: six exact arithmetic-refinement obligations;
- T2: four successor and carry-transition obligations;
- T3: five canonical-image and invalid-codeword obligations;
- T4: four recoverability and collision-freedom obligations.

Each family closure is bound through its closure record and the SHA-256
hash of its own evidence manifest. The complete evidence archive contains
the four original closure directories together with this index.

The result is property-specific and assumption-dependent. It applies to
canonical inputs and the portable implementation selected by the frozen
CBMC build. It does not establish native-backend correctness, timing or
side-channel properties, decoder correctness or complete ML-KEM
correctness.
