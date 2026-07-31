# MSG-T1 Assurance Boundaries

The campaign proves one property-specific theorem. It does not prove every
property of ML-KEM or every property of `mlk_poly_tomsg`.

## Included

- the frozen production `mlk_poly_tomsg` implementation path;
- the production `mlk_scalar_compress_d1` helper reached by that path;
- all 256 canonical coefficients;
- all 32 output bytes and all 256 output bits;
- exact canonical Compress1 threshold semantics;
- least-significant-bit-first packing;
- recorded memory, pointer, arithmetic, conversion, shift and division checks;
- complete treatment of all reachable multi-iteration loops;
- twelve registered non-vacuity witnesses;
- eight frozen mutation-sensitivity controls.

## Excluded

- coefficients outside `0..3328`;
- mathematical claims for non-canonical polynomial representations;
- complete ML-KEM encapsulation, decapsulation or decryption correctness;
- correctness of functions not in the frozen reachable call path;
- every ML-KEM parameter-set build;
- assembly implementations or alternative configuration paths;
- constant-time, timing, cache, power, electromagnetic or other side-channel
  properties;
- compiler-machine-code equivalence;
- universal completeness over every possible implementation, oracle, harness
  or assertion mutation;
- a claim that the entire mlkem-native repository is formally verified;
- a claim of universal novelty or “first proof”.

The theorem is conditional on the frozen source, build configuration, harness,
assumptions, CBMC semantics and recorded verification options.
