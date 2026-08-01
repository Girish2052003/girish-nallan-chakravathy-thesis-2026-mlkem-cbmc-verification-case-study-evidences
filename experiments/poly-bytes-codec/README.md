# ML-KEM Polynomial Byte-Codec Composition Validation

This directory contains the classified evidence for the supplied
PBCODEC-CV1 campaign at mlkem-native commit
`af4c5abdd5958bdc65a03cd5ee86708264f93304`.

## Research classification

The supplied verification intent classifies this work as one direct
production-to-production, cross-function composition-validation family.
It contains two composition obligations:

1. `T01-canonical-polynomial-encode-decode`: a canonical polynomial is
   encoded with the real public `mlk_poly_tobytes` wrapper and decoded
   with the real public `mlk_poly_frombytes` wrapper, recovering the
   original coefficients.
2. `T02-canonical-bytes-decode-encode`: canonical encoded bytes are
   decoded with the real public `mlk_poly_frombytes` wrapper and encoded
   with the real public `mlk_poly_tobytes` wrapper, reproducing the input
   bytes.

`NV01-composition-endpoint-reachability` contains the supplied
non-vacuity evidence. `V01-bridge-mutation-sensitivity` contains the two
supplied harness-side bridge-mutation campaigns.

## Boundary

The supplied records explicitly state that this is not a new
mathematical encoding theorem, not a new implementation function, not a
native-backend correctness claim, and not complete ML-KEM correctness.

The first build attempt is preserved under `00-campaign-setup` together
with the repaired build and binding evidence. The closure records show
that the Review-2 package remained a candidate pending independent
acceptance; this classified repository package does not upgrade that
status.

Exact mirror copies from expanded freeze and closure packages are not
repeated in the active tree. Every original path is accounted for in
`provenance/poly-bytes-codec/classification/original-to-retained-map.tsv`,
and the complete uploaded ZIP is preserved byte-for-byte under the
frozen baseline.
