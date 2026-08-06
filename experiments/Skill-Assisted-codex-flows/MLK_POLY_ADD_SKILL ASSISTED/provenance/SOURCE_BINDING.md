# Source binding

- Repository: `pq-code-package/mlkem-native`
- Commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Production file: `mlkem/src/poly.c`
- Expected SHA-256: `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722`
- Public header: `mlkem/src/poly.h`
- Parameter selection: `-DMLK_CONFIG_PARAMETER_SET=768`
- Expected tools: CBMC 6.9.0, `goto-cc` 6.9.0, `goto-instrument` 6.9.0

The runner checks the commit, production-file hash, tool versions, and clean production-source status before building. It directly compiles `mlkem/src/poly.c`; no replacement body is included in the corpus.
