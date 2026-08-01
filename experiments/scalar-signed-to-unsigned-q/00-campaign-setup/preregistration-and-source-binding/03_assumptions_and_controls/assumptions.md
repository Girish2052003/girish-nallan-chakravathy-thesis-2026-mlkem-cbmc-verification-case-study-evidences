# CANON Frozen Assumptions

## A1 — Source identity

The authoritative source is commit:

`af4c5abdd5958bdc65a03cd5ee86708264f93304`.

Relevant files are bound using SHA-256.

## A2 — Target legal domain

Calls directly made to `mlk_scalar_signed_to_unsigned_q` assume:

`-3329 < c < 3329`.

This is equivalent to:

`-3328 <= c <= 3328`.

## A3 — Integer model

The proof uses CBMC's bit-precise C integer model.

Mathematical differences, translations and oracle arithmetic are explicitly
promoted to `int32_t` before evaluation.

## A4 — Signed right-shift portability assumption

The target dependency `mlk_ct_cmask_neg_i16` assumes a sign-preserving
arithmetic right shift for negative signed values, as documented by the
production source.

This is an explicit platform/model assumption and not a theorem proved by the
CANON campaign.

## A5 — Value-barrier model

Any use of the native value-barrier contract or implementation must be recorded
in the command manifest and dependency-binding evidence.

## A6 — Actual-body requirements

The authoritative target proofs must execute the real production target body.

CANON-T4 must execute the real production bodies of both:

- `mlk_barrett_reduce`;
- `mlk_scalar_signed_to_unsigned_q`.

## A7 — Oracle independence

The canonical modulo oracle must not call or copy the target, Barrett reducer,
selector helpers, negative-mask helper, or production conditional-selection
expression.

## A8 — Functional scope only

The campaign proves registered functional and C-safety properties only.

It does not prove:

- compiled constant-time behaviour;
- absence of microarchitectural leakage;
- compiler preservation of constant-time structure;
- complete cryptographic security of ML-KEM.
