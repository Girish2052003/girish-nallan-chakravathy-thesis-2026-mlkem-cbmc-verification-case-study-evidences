# PBYTES-T4 closure evidence

This directory records the closure evidence for PBYTES-T4:
arithmetic recoverability and collision freedom for the portable
`mlk_poly_tobytes` implementation.

The evidence contains:

- four frozen T4 obligations;
- three successful positive CBMC models;
- 306 successful positive properties;
- independent arithmetic coefficient recovery;
- block equality iff coefficient-pair equality;
- full canonical-polynomial injectivity;
- twelve concrete relational witnesses;
- six insufficient-unwind controls;
- four targeted production-code semantic mutants;
- source, commit, command, result and SHA-256 bindings.

The theorem is restricted to canonical polynomial inputs and the
portable implementation selected by the frozen CBMC build.

It does not establish native-backend correctness, timing or
side-channel behaviour, decoder correctness or complete ML-KEM
correctness.
