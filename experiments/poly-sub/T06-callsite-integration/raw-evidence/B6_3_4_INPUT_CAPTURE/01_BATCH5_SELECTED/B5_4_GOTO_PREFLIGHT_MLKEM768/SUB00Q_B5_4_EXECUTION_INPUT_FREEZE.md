# SUB-T5 / B5.4 — Execution Input Freeze

Captured UTC: 2026-07-17T14:59:28Z

## Frozen source inputs

Clean-room source root: `/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/source/mlkem`
poly.c SHA-256: `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722`
poly.h SHA-256: `f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef`

## Frozen harness family

Harness root: `/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00Q_BATCH5_T5_RELATIONAL/frozen_harness_family_v1`
Harness count: 9
Each harness is compiled into a separate linked GOTO binary.

## Frozen toolchain

CBMC: `6.9.0 (cbmc-6.9.0)`
goto-cc: `gcc (goto-cc 6.9.0 (cbmc-6.9.0)) 13.3.0`
goto-instrument: `6.9.0 (cbmc-6.9.0)`

## Preflight boundary

This stage constructs and inspects GOTO binaries.
It does not run positive, reachability, expected-failure, or mutation proofs.
Case-specific unwindsets are derived from each constructed model using --show-loops.

CBMC proof execution: NO
Production-source modification: NO
Earlier-batch modification: NO
