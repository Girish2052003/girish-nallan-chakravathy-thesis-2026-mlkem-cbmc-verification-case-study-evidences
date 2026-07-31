# MSG-01G-R1 — Frozen Positive-Execution Plan

The next stage may execute only:

- frozen GOTO SHA-256: `51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d`;
- entry function: `main`;
- object bits: 8;
- frozen unwindset: `main.0:257,main.1:257,mlk_msg01f_poly_tomsg.0:257,mlk_msg01f_poly_tomsg.1:257,mlk_msg01f_poly_tomsg.2:257`;
- bounds and pointer checks;
- signed and unsigned overflow checks;
- conversion and undefined-shift checks;
- division-by-zero checks;
- unwinding assertions;
- formula slicing;
- MiniSat2;
- JSON result capture.

No source, harness, adapter, GOTO or unwindset modification is permitted after
this freeze.
