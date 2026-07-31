# PFB mlk_poly_frombytes Final Campaign Report

## Final status

The clean-room PFB campaign is accepted for the portable public
`mlk_poly_frombytes` path at commit `af4c5abd`.

The campaign contains four frozen theorem families and eleven frozen semantic
obligations:

1. PFB-T1 — exact raw-decoding semantics;
2. PFB-T2 — exact bit routing and arbitrary one-block locality;
3. PFB-T3 — arbitrary differential conservation;
4. PFB-T4 — two-sided inversion over the complete raw 12-bit domain.

Production source was not modified. The target body was not replaced by a
function contract. Loop contracts were not applied. Native-backend correctness
was excluded.

## Allowed claim

At commit `af4c5abd`, the portable public `mlk_poly_frombytes` path was verified
by CBMC for the eleven frozen PFB semantic obligations covering exact raw
decoding, exact bit routing and one-block locality, arbitrary differential
conservation, and two-sided inversion over the complete raw 12-bit domain,
under the recorded machine model and proof configurations.

## Explicit exclusions

The campaign does not claim:

- native-backend semantic verification;
- full FIPS 203 ByteDecode12 modular normalization;
- correctness of production `mlk_poly_tobytes`;
- correctness of production reduction functions;
- correctness outside the eleven frozen obligations;
- automatic validity for another source commit;
- a mathematical or worldwide first.
