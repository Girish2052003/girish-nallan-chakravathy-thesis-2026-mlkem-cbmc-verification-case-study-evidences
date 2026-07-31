# POLYCOMP-D4 clean-room CBMC theorem family

This directory contains the browsable, lossless-normalized evidence for four portable-C D4 compression/decompression theorem campaigns bound to mlkem-native commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`, ML-KEM-768, and CBMC 6.9.0.

## Accounting

- Supplied ZIP entries: 1,700
- Supplied regular files: 1,545
- Original file occurrences retained visibly: 1,039
- Proven structural packaging occurrences omitted: 506
- Original files left unmapped: 0

An omitted occurrence is not lost evidence. It maps to a retained byte-identical canonical file in `provenance/polycomp-d4-classification/original-to-retained-map.tsv`. Immutable final archives remain preserved.

## Campaigns

- `T01-compressor-refinement`: exact portable-C D4 compressor refinement and relational nibble locality.
- `T02-decompressor-refinement`: exact D4 decompressor refinement and relational byte locality.
- `T03-compressed-domain-retraction`: `compress(decompress(B)) = B` for every 128-byte compressed input.
- `T04-quantizer-projection`: codebook membership, modular distortion bound 104, sharpness, fixed points, idempotence, and coordinate locality.

Read the original final verdicts inside each theorem's `final-review/` directory before making claims.
