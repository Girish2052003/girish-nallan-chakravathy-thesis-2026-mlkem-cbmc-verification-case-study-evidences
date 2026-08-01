# Clean-room generated `mlk_poly_sub` harness collection

This directory groups the harnesses generated during the independent
clean-room SUB-T1 through SUB-T6 verification campaigns.

## Important boundary

These files were copied from the clean-room experiment tree.

They are not copied from:

- the upstream `mlkem-native` proof directories;
- the frozen `source/mlkem` tree;
- an upstream repository snapshot;
- failed experiment-attempt directories.

The original experiment files remain unchanged in their original locations.

## Layout

- `T1/` — SUB-T1 harnesses and controls
- `T2/` — SUB-T2 harnesses and controls
- `T3/` — SUB-T3 harnesses and controls
- `T4/` — SUB-T4 harnesses and controls
- `T5/` — SUB-T5 harnesses and controls
- `T6/` — SUB-T6 positive, reachability, expected-failure and mutation harnesses
- `REVIEW_UNCLASSIFIED/` — generated harness-shaped files that could not be
  classified deterministically as T1–T6
- `HARNESS_INDEX.tsv` — grouped-to-original provenance mapping
- `ALL_GROUPED_HARNESSES.sha256` — integrity manifest

Only C files containing a harness `main()` entry point were collected.
Support translation units, production C files, headers and upstream harnesses
were not included.
