# PBCODEC-CV1 Allowed Claim

At mlkem-native commit:

    af4c5abdd5958bdc65a03cd5ee86708264f93304

the portable public polynomial byte-codec wrappers were directly
composition-validated with CBMC in both legitimate directions:

1. every canonical polynomial round-trips through the real public
   mlk_poly_tobytes wrapper followed by the real public
   mlk_poly_frombytes wrapper; and

2. every byte array in the canonical encoder image round-trips through
   the real public mlk_poly_frombytes wrapper followed by the real
   mlk_poly_tobytes wrapper.

Both public wrappers and both portable C bodies were present and
reachable in the GOTO models. All relevant loops were completely
unwound. The positive obligations succeeded, both composition endpoints
were independently shown reachable, and two harness-side bridge
mutations were detected.

Production source was not modified. Function-contract replacement,
loop-contract application and replacement by an independent codec
oracle were not used.

## Research classification

This is:

- one direct cross-function composition-validation family;
- two composition obligations;
- integration-level CBMC evidence for the exact C implementation;
- a distinct verification artefact relative to the separate upstream
  per-function harnesses and the prior independent PBYTES/PFB campaigns.

This is not claimed as:

- a newly discovered mathematical encoding identity;
- a fifth PBYTES theorem family;
- a fifth PFB theorem family;
- a twelfth independently investigated function;
- native-backend correctness;
- complete ML-KEM correctness;
- constant-time or side-channel correctness;
- a mathematical or worldwide first.
