# `mlk_poly_tomsg` CBMC Clean-Room Campaign

This directory classifies the standalone `mlk_poly_tomsg` verification campaign by experimental stage and theorem family.

- `00-campaign-context`: starting state, source/oracle binding, native-body binding, and baseline runs.
- `MSG-T1-exact-fips-semantics`: candidate evolution, authoritative execution, reachability/non-vacuity controls, mutation sensitivity, and final consolidation.
- `MSG-T2-relational-properties`: XOR, locality, cross-bit preservation, invariance, determinism, reachability, mutation controls, acceptance, and documentation repair.
- `MSG-T5-exact-offset-interval`: novelty analysis, exact offset derivation, model binding, sufficiency/necessity, boundary mutations, and acceptance.
- `MSG06-combined-campaign-closure`: theorem registry, claim matrix, evidence indices, frozen campaign archives, and final closure.
- `90-archive-companions`: top-level archive listings, checksums, and terminal captures.
- `99-audit`: incoming-path classification and exact-duplicate records.

Failed attempts and repairs are retained because they document the experimental history. Deduplication is limited to identical SHA-256 content with the same filename; source-tree paths are preserved structurally.
