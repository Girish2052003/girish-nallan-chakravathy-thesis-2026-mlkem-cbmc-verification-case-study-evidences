# PBCODEC-CV1 Round-Trip Harnesses

This folder contains copies of the five harnesses used in the direct
cross-function composition-validation campaign for:

- mlk_poly_tobytes
- mlk_poly_frombytes

The authoritative originals remain inside the frozen PBCODEC-CV1
campaign directory. Nothing was moved or modified.

## Positive harnesses

1. pbcodec_cv1_p1_left_inverse_harness.c

   Validates the canonical polynomial round trip:

   canonical polynomial
   -> real mlk_poly_tobytes
   -> real mlk_poly_frombytes
   -> original polynomial

2. pbcodec_cv1_p2_right_inverse_harness.c

   Validates the canonical byte-image round trip:

   canonical encoded bytes
   -> real mlk_poly_frombytes
   -> real mlk_poly_tobytes
   -> original bytes

## Non-vacuity harness

3. pbcodec_cv1_nonvacuity_harness.c

   Uses deliberately failing assertions to confirm that both
   composition endpoints are reachable.

## Mutation-control harnesses

4. pbcodec_cv1_m1_corrupt_encoded_bridge_harness.c

   Corrupts the encoded byte bridge between the real encoder and
   decoder. The composition property must fail.

5. pbcodec_cv1_m2_corrupt_decoded_bridge_harness.c

   Changes a decoded coefficient before re-encoding while preserving
   the canonical encoder-input domain. The composition property must
   fail.

## Research classification

- Direct composition-validation families: 1
- Positive composition obligations: 2
- Non-vacuity control harnesses: 1
- Targeted bridge-mutation harnesses: 2
- New independently investigated production functions: 0
- New mathematical theorem families: 0
