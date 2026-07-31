# BR-AF4 `mlk_barrett_reduce` clean-room CBMC campaign

This directory contains the browsable, lossless-normalized BR-AF4 experiment evidence.

## Accounting

- Supplied ZIP entries: 4,384
- Supplied regular files: 3,626
- Original file occurrences retained visibly: 2,604
- Proven structural packaging duplicates omitted: 1,022
- Original files left unmapped: 0
- Conservative residual files: 0

"Omitted" does not mean evidence was discarded. Each omitted occurrence is an exact repeated packaging copy and maps to a retained byte-identical canonical file in `provenance/barrett-reduce-classification/original-to-retained-map.tsv`.

## Campaign organization

- `00-campaign-setup`: start states, retries, and source binding.
- `T01-exact-centered-refinement`: exact refinement runs and hardening controls.
- `T02-normalizer-laws`: normalizer-law theorem run and final review.
- `T03-quotient-partition`: positive theorem, mutation hardening, and review.
- `T04-unique-multiplier`: positive theorem, mutation hardening, and review.
- `T05-offset-interval`: positive theorem, mutation hardening, and review.
- `90-family-level-synthesis`: partial and complete family package metadata.
