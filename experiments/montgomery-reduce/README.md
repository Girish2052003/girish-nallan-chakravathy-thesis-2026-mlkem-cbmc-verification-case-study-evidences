# Montgomery Reduction CBMC Clean-Room Campaign

This directory classifies the incoming Montgomery-domain evidence by theorem family while preserving every unique file and a complete path-level audit trail.

- `00-campaign-context`: frozen source and native implementation analysis.
- `MONT01-exact-refinement`: exact refinement, false control, and mutation sensitivity for `mlk_montgomery_reduce`.
- `MONT02-relational-low-word-laws`: relational residue and low-word-fibre laws.
- `MONT03-normalized-fqmul-algebra`: normalized algebraic properties for `mlk_fqmul`.
- `MONT04-poly-tomont-roundtrip-locality`: portable-C conversion, round trip, equivalence, zero support, and locality for `mlk_poly_tomont_c`.
- `99-audit`: classification and deduplication records installed by the safe importer.

The original ZIP is never modified. Duplicate removal is limited to exact SHA-256 matches with the same evidence filename, plus same-relative-path files repeated across full worktree snapshots. Distinct scientific roles and structurally required source paths are not silently collapsed.
