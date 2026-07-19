# SUB-T5 / B5.1 — Authoritative Production and Parent Binding

Repository: /home/girish/THESIS-2026/mlkem-native
Frozen commit: d9613cf60de3132d32475c102d8c2781d84feb34
Frozen short commit: d9613cf60de3
Parameterisation: ML-KEM-768
CBMC version: 6.9.0
goto-cc version: 6.9.0

## Authoritative production implementation

Implementation path: `mlkem/src/poly.c`
Implementation SHA-256: `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722`
Implementation Git blob: `3a25fdfe9d17c5a074dc4f7d8f926625f37fa2ff`

Declaration path: `mlkem/src/poly.h`
Declaration SHA-256: `f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef`
Declaration Git blob: `4d9e0f82443ce185a167979c585c01de03d63ee8`

The occurrence in `mlkem/src/indcpa.c` is a production call site.
The occurrence in `test/bench/bench_components_mlkem.c` is a benchmark call site.
Neither is an alternative definition of `mlk_poly_sub`.

## Parent evidence binding

The authoritative execution parent is the accepted Batch-4 ML-KEM-768 evidence chain under:
`/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN`

Batch 5 may reuse the established production compilation environment and support strategy,
but must use a separately frozen Batch-5 relational harness family.

## Operation boundary

CBMC execution during B5.1: NO
GOTO-model construction during B5.1: NO
Production-source modification during B5.1: NO
Batch-4 modification during B5.1: NO
