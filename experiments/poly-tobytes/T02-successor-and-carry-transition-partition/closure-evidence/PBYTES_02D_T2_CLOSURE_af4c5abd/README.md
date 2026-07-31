# PBYTES-T2 closure evidence

This directory records the closure evidence for PBYTES-T2, the exact
successor and carry-transition partition for `mlk_poly_tobytes`.

The evidence contains:

- four successful relational theorem obligations;
- two real public-wrapper executions;
- complete safety-property results;
- an insufficient-unwind negative control;
- four concrete scenario-reachability witnesses;
- four targeted production-code semantic mutants;
- clean source and commit identity records.

The theorem is limited to canonical coefficients and the portable
implementation selected by the frozen CBMC build. It does not establish
native-backend correctness, timing behaviour, side-channel properties,
decoder correctness or complete ML-KEM correctness.
