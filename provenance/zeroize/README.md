# Zeroize campaign provenance

This directory records the classification and preservation boundary for the uploaded `mlk_zeroize_cleanroom.zip` archive.

- `classification/original-to-retained-map.tsv` accounts for every original file.
- `classification/omitted-high-confidence-mirror-copies.tsv` lists only byte-identical mirror copies omitted from the active tree.
- `classification/same-content-distinct-context-files.tsv` records identical bytes retained where run-specific context remains scientifically relevant.
- `frozen-baseline/` preserves the original uploaded ZIP byte-for-byte.
- `frozen-family-packages/` retains one canonical copy of each family freeze package and checksum.

No original file was silently discarded: omitted active-tree copies remain recoverable from the frozen original ZIP.
