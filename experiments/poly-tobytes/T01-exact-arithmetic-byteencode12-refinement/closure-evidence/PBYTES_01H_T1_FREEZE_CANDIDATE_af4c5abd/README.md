# PBYTES-T1 closure candidate

This package contains the candidate closure evidence for PBYTES-T1,
the exact arithmetic ByteEncode12 refinement theorem family for
`mlk_poly_tobytes`.

The candidate includes:

- frozen theorem intent and scope;
- authoritative source and commit identity;
- the unchanged positive harness;
- the successful 156-property CBMC execution;
- explicit P1–P6 and C1–C3 status records;
- an insufficient-unwind negative control;
- four non-vacuity witnesses;
- four deterministic semantic production mutants;
- exact mutation diffs and CBMC rejection records;
- the CBMC 6.9.0 internal-validation limitation record.

The candidate does not claim native backend correctness, timing or
side-channel correctness, `mlk_poly_frombytes` correctness, or complete
ML-KEM correctness.

Final theorem closure remains pending until the archive is externally
reviewed against its SHA-256 manifest.
