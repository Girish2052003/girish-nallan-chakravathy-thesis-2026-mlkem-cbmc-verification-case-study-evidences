# Preliminary repository-native overlap boundary

This finding is limited to the frozen mlkem-native commit and does not claim
universal literature novelty.

## Native proof already present

The frozen repository contains:

- a CBMC harness that invokes `mlk_poly_tomsg`;
- a function-contract proof configuration for `mlk_poly_tomsg`;
- canonical-domain and separation preconditions in the production contract;
- an assigns clause for the 32-byte output;
- a scalar `mlk_scalar_compress_d1` arithmetic contract;
- loop-contract instrumentation and ordinary CBMC safety checks.

## Candidate research properties not directly stated by that native contract

The inspected `mlk_poly_tomsg` contract does not directly state:

- whole-message equality with an independently implemented FIPS oracle;
- exact coefficient-to-byte and coefficient-to-bit mapping;
- relational coefficient locality;
- cross-bit non-interference;
- independence from the initial output-buffer contents;
- complete overwrite demonstrated by a two-run relational property;
- full subtract-reduce-decode composition.

These candidate properties require separate harnesses and CBMC proof obligations.
