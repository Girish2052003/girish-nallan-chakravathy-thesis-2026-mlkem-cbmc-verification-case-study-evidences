# Barrett-reduction deduplication policy

The normalization is deliberately conservative.

A file was omitted only when its content and structural role proved that it was a repeated packaging-layer copy of evidence retained elsewhere. Whole raw runs were not hash-deduplicated internally. Identical `cbmc.exit`, version, command, harness, source, and result files remain in distinct genuine run contexts whenever those contexts are scientifically different.

The frozen upstream source tree was also not content-deduplicated internally, because repeated files in examples or build variants are part of the upstream repository layout. The only separated item is the machine-local `.git` worktree pointer; it is preserved byte-for-byte under `provenance/special-git-metadata/`.

Immutable candidate and final theorem tarballs are retained as original provenance artefacts. Extracted run copies repeated inside those package layers are represented once in the browsable experiment tree.

Every supplied regular file is accounted for in `provenance/barrett-reduce-classification/original-to-retained-map.tsv`.
