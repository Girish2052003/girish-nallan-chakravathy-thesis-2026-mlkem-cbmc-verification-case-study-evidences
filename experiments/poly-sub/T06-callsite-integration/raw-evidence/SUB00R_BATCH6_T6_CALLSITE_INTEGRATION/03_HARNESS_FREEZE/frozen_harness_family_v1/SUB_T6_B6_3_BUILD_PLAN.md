# SUB-T6 B6.3 — Frozen Build Plan

Toolchain: goto-cc 6.9.0
Language mode: C90
Parameter set: ML-KEM-768
Namespace prefix: mlk_sub00r_b6
Assembly: disabled
Zeroization model: fail closed

Cases 1–4 compile the selected harness, poly.c and the validated zero
opt-blocker support source. The tomsg case additionally compiles compress.c.

Each case is linked into a separate GOTO binary. B6.4 derives loop IDs from
the constructed model and inventories properties without running proof solving.
