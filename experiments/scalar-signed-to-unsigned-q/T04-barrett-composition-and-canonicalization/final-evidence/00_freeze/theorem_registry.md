# CANON Theorem Registry

## Frozen definitions

- `q = 3329`
- `D = { c in Z | -q < c < q } = {-3328, ..., 3328}`
- `U = { u in Z | 0 <= u < q } = {0, ..., 3328}`
- `F(c)` denotes execution of the production body of
  `mlk_scalar_signed_to_unsigned_q(c)`.
- `B(a)` denotes execution of the production body of
  `mlk_barrett_reduce(a)`.
- `C(a) = F(B(a))`.
- `canon_q(z)` denotes an independent mathematical oracle returning the
  unique value in `U` congruent to `z` modulo `q`.

No theorem result is preregistered as true. Each status begins as `UNTESTED`.

---

## CANON-T1 — Exact equivalence-class and fibre theorem

### CANON-T1.P1 — Collision necessity

For all `x,y in D`:

`F(x) = F(y) => x-y is one of {-q, 0, q}`.

Initial status: `UNTESTED`.

### CANON-T1.P2 — Collision sufficiency

For all `x,y in D`:

`x-y is one of {-q, 0, q} => F(x) = F(y)`.

Initial status: `UNTESTED`.

### CANON-T1.P3 — Exact zero fibre

For all `c in D`:

`F(c) = 0 iff c = 0`.

Initial status: `UNTESTED`.

### CANON-T1.P4 — Exact nonzero fibres

For all `c in D` and `u` satisfying `1 <= u < q`:

`F(c) = u iff c = u or c = u-q`.

Initial status: `UNTESTED`.

---

## CANON-T2 — Retraction and normalization-stability theorem

### CANON-T2.P1 — Identity on canonical inputs

For all `u in U`:

`F(u) = u`.

Initial status: `UNTESTED`.

### CANON-T2.P2 — Idempotence

For all `c in D`:

`F(F(c)) = F(c)`.

Initial status: `UNTESTED`.

### CANON-T2.P3 — Exact fixed-point characterization

For all `c in D`:

`F(c) = c iff c >= 0`.

Initial status: `UNTESTED`.

### CANON-T2.P4 — Injectivity on the canonical subdomain

For all `u,v in U`:

`F(u) = F(v) => u = v`.

Initial status: `UNTESTED`.

---

## CANON-T3 — Modular-arithmetic compatibility theorem

### CANON-T3.P1 — Addition compatibility

For all `x,y in D` satisfying `x+y in D`:

`F(x+y) = canon_q(F(x)+F(y))`.

All additions used in the oracle and comparison are evaluated in `int32_t`.

Initial status: `UNTESTED`.

### CANON-T3.P2 — Subtraction compatibility

For all `x,y in D` satisfying `x-y in D`:

`F(x-y) = canon_q(F(x)-F(y))`.

All subtractions used in the oracle and comparison are evaluated in `int32_t`.

Initial status: `UNTESTED`.

### CANON-T3.P3 — Negation compatibility

For all `x in D`:

`F(-x) = canon_q(-F(x))`.

The negation and oracle arithmetic are evaluated in `int32_t`.

Initial status: `UNTESTED`.

---

## CANON-T4 — Actual-body Barrett composition theorem

### CANON-T4.P1 — Barrett-to-converter domain closure

For every `int16_t a`:

`-q < B(a) < q`.

Initial status: `UNTESTED`.

### CANON-T4.P2 — Complete canonical-modulo refinement

For every `int16_t a`:

`C(a) = canon_q(a)`.

Initial status: `UNTESTED`.

### CANON-T4.P3 — Composition residue preservation

For every `int16_t a`:

`C(a)` is congruent to `a` modulo `q`.

Initial status: `UNTESTED`.

### CANON-T4.P4 — Representable q-translation invariance

For every `int16_t a` and `k in {-1,+1}`, whenever `a+kq` is representable as
`int16_t`:

`C(a+kq) = C(a)`.

The translated value is computed and range-checked in `int32_t` before conversion.

Initial status: `UNTESTED`.

### CANON-T4.P5 — Signed-domain commutation

For every `c in D`:

`C(c) = F(c)`.

Initial status: `UNTESTED`.

### CANON-T4.P6 — Composition normal-form stability

For every `int16_t a`:

`C(C(a)) = C(a)`.

Initial status: `UNTESTED`.
