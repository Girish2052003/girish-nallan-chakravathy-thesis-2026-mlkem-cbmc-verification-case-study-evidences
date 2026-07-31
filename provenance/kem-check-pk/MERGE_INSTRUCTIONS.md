# Merge instructions

This package is rooted at the repository root. Copy its `experiments/`, `upstream/`, and `provenance/` directories into the existing repository without deleting existing files.

Before committing:

```bash
sha256sum -c provenance/kem-check-pk/SHA256SUMS
find experiments/kem-check-pk -type f | wc -l
find upstream/mlkem-native/pkcheck-af4c5abd-source-snapshot -type f | wc -l
wc -l provenance/kem-check-pk/unclassified-files.tsv
```

Expected conditions:

- checksum verification succeeds;
- `unclassified-files.tsv` contains only its header;
- `destination-collisions.tsv` contains only its header;
- the frozen original archive remains unchanged with SHA-256 `fb2b78d1a0eb415809f03e00e39c7f04c2a693b8661ce47e1ae03bb734c5ed5e`.

Do not unpack or commit the nested `.git` database from the original archive into the active repository. The inert worktree pointer is preserved separately under `special-git-metadata/`.
