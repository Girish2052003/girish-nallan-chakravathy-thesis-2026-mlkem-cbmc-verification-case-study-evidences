# SUB-T6 B6.4 — Reachability-Aware Execution Input Freeze

Captured UTC: 2026-07-18T13:38:01Z

Frozen B6.3 family: /home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION/03_HARNESS_FREEZE/frozen_harness_family_v1

Source root: /home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/source/mlkem
poly.c SHA-256: f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722
poly.h SHA-256: f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef
compress.c SHA-256: 9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad
compress.h SHA-256: 0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

CBMC: 6.9.0 (cbmc-6.9.0)
goto-cc: gcc (goto-cc 6.9.0 (cbmc-6.9.0)) 13.3.0
goto-instrument: 6.9.0 (cbmc-6.9.0)

Correction from the preserved failed preflight:
global --show-loops output is not treated as reachability evidence.
For each case, the transitive closure rooted at main is derived from
--reachable-call-graph. Only loops whose owning functions occur in that
reachable closure are included in the frozen unwindset.

This stage constructs and inspects GOTO binaries and inventories properties.
It does not execute proof solving.
