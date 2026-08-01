# CANON Native-Overlap Boundary

## Native target proof already present

The pinned repository contains a CBMC proof directory for:

`mlk_scalar_signed_to_unsigned_q`.

Its native harness makes one target call and relies on the production function
contract.

Its Makefile:

- checks the contract of `mlk_scalar_signed_to_unsigned_q`;
- uses contracts for `mlk_ct_sel_int16`;
- uses contracts for `mlk_ct_cmask_neg_i16`.

## Native claims not counted as CANON novelty

The CANON campaign does not claim novelty for:

- the legal input domain;
- the output range `[0,q)`;
- the exact conditional-addition formula;
- ordinary compliance of the target with its embedded contract;
- the existence of signed-to-unsigned modular conversion.

## Native higher-level composition

The native `mlk_poly_reduce_c` proof uses contracts for:

- `mlk_barrett_reduce`;
- `mlk_scalar_signed_to_unsigned_q`.

CANON-T4 is distinguished by requiring actual-body execution of both scalar
functions against an independent canonical-modulo oracle.

## Proposed repository-distinct contribution

The proposed CANON contribution is limited to the registered package of:

- exact collision and fibre structure;
- retraction and normalization dynamics;
- modular-operation compatibility;
- actual-body Barrett composition;
- anti-vacuity controls;
- mutation sensitivity;
- source and build binding.

No worldwide-first claim is preregistered.
