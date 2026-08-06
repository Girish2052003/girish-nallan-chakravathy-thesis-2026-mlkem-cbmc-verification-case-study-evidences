# Source binding

- Repository: `pq-code-package/mlkem-native`
- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Production file: `mlkem/src/poly.c`
- Expected `poly.c` SHA-256: `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722`
- Header/contract file: `mlkem/src/poly.h`
- Expected `poly.h` SHA-256: `f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef`
- Parameter set: `-DMLK_CONFIG_PARAMETER_SET=768`
- Namespace prefix: `-DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sa_sub`
- Portable backend: `-DMLK_CONFIG_NO_ASM=1`
- Language mode: `-std=c90`
- Toolchain: CBMC/goto 6.9.0, GCC 13.3.0, Python 3.12.3

The runner checks the exact commit, both source hashes, tracked-worktree cleanliness, platform, byte order, and tool versions before constructing any GOTO model. It directly links `mlkem/src/poly.c`; the corpus contains no implementation copy or replacement body.
