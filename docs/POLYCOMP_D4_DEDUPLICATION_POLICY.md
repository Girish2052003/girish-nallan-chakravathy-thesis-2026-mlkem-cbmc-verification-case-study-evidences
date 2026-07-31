# POLYCOMP-D4 deduplication policy

This normalization is deliberately conservative and follows the repository's established lossless-evidence policy.

A file occurrence is omitted only when its bytes and structural role prove that it is a repeated packaging-layer copy of evidence retained elsewhere. Identical files remain separately retained when they belong to genuinely different proof, mutation, diagnostic, or run contexts. In particular, equal empty stderr files, tool outputs, GOTO objects, command records, and metadata are not globally collapsed merely because their SHA-256 values match.

The following structural mirrors are normalized:

1. `campaign_stages/` copies inside final evidence packages map to the original live-stage directories.
2. Five identical six-file `source_binding/` copies map to one family-level source binding.
3. The T2 original and repaired R2 expanded packages share 194 byte-identical same-path files; one R2 canonical copy is retained, while the four changed original documents and all R2 repair additions remain visible.
4. Freeze-wrapper validation copies that exactly match expanded-package validation files map to the expanded-package copy.

All five immutable final `.tar.gz` packages and their original sidecars are retained. Every supplied regular file is accounted for in `provenance/polycomp-d4-classification/original-to-retained-map.tsv`.
