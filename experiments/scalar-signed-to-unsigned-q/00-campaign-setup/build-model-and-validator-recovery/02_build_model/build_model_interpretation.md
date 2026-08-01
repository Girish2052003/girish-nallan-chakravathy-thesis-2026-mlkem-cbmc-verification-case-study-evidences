# CANON-00C Build-Model Interpretation

CANON-00B prohibits modifying the static or inline qualifiers in the
authoritative production source.

The native mlkem-native CBMC infrastructure exposes file-local symbols in the
verification translation through compiler and linker configuration, including:

- `-Dstatic=`;
- `-DMLK_INLINE=`;
- `-DMLK_ALWAYS_INLINE=`;
- `--export-file-local-symbols`.

This is treated as a verification-build transformation, not a production-source
modification, provided that:

1. the authoritative source files remain byte-identical to the pinned commit;
2. the transformation is recorded in the evidence;
3. the resulting GOTO model contains the production target body;
4. the target is not undefined, stubbed or replaced by its contract in the
   authoritative CANON theorem run;
5. theorem assertions remain outside the production implementation.

The existing native harness is used in CANON-00C only as an environmental and
build control. It is not a CANON theorem harness and is not counted as a novel
artifact.
