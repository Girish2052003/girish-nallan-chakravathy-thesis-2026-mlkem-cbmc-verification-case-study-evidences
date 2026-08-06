# Source binding

- Repository: `pq-code-package/mlkem-native`
- Pinned current snapshot: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Production file: `mlkem/src/poly.c`
- Target: `mlk_barrett_reduce`
- Formula literals required in the bound body: `20159`, `1 << 25`, `>> 26`, and `MLKEM_Q`

The runner refuses another commit or a dirty tracked tree. It records the production
`poly.c` SHA-256, extracts exactly one target function, and creates a run-local
translation unit by removing only `static MLK_INLINE` linkage. The function body is
byte-compared and SHA-256-bound before any proof is accepted. The repository source
is never changed.
