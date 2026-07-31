# PBYTES Theorem Registry V1

## Frozen target

- Campaign: PBYTES
- Public function: `mlk_poly_tobytes`
- Portable body: `mlk_poly_tobytes_c`
- Source commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Core theorem families: 4
- Core semantic obligations: 19
- Native-backend semantic claim: excluded

## PBYTES-T1 — Exact arithmetic ByteEncode12 refinement

Independent oracle uses arithmetic division and remainder, not the
production shift-and-mask expressions.

1. PBYTES-T1.P1 — exact low byte of the even coefficient.
2. PBYTES-T1.P2 — exact high nibble of the even coefficient.
3. PBYTES-T1.P3 — exact low nibble of the odd coefficient.
4. PBYTES-T1.P4 — exact high byte of the odd coefficient.
5. PBYTES-T1.P5 — exact 24-bit packed-word equality.
6. PBYTES-T1.P6 — complete 384-byte arithmetic-oracle equality.

## PBYTES-T2 — Exact successor and carry-transition partition

Inputs differ by an increment of one at one selected canonical coefficient.
The incremented value must remain below MLKEM_Q.

1. PBYTES-T2.P1 — even coefficient without low-byte carry.
2. PBYTES-T2.P2 — even coefficient with 255-to-256 carry.
3. PBYTES-T2.P3 — odd coefficient without high-nibble carry.
4. PBYTES-T2.P4 — odd coefficient with 15-to-16 nibble-to-byte carry.

## PBYTES-T3 — Exact canonical image and invalid-codeword exclusion

The independent decoder interprets each three-byte block arithmetically as
W = b0 + 256*b1 + 65536*b2, with fields W mod 4096 and W / 4096.
It must not call mlk_poly_frombytes.

1. PBYTES-T3.P1 — every produced even field is below MLKEM_Q.
2. PBYTES-T3.P2 — every produced odd field is below MLKEM_Q.
3. PBYTES-T3.P3 — every canonical 24-bit block is realizable.
4. PBYTES-T3.P4 — a block with either invalid field is not realizable.
5. PBYTES-T3.P5 — full-array image iff all 256 fields are canonical.

## PBYTES-T4 — Arithmetic recoverability and collision freedom

1. PBYTES-T4.P1 — arithmetic recovery of the even coefficient.
2. PBYTES-T4.P2 — arithmetic recovery of the odd coefficient.
3. PBYTES-T4.P3 — block equality iff coefficient-pair equality.
4. PBYTES-T4.P4 — full canonical-polynomial injectivity.

## Count

- T1: 6
- T2: 4
- T3: 5
- T4: 4
- Total: 19
