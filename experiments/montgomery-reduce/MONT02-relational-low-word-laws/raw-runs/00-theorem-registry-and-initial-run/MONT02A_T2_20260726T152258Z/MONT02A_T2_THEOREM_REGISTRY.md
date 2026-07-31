# MONT-T2 Relational Residue and Low-Word Fibre Laws

Pinned commit:

`af4c5abdd5958bdc65a03cd5ee86708264f93304`

Target function:

`mlk_montgomery_reduce`

## Properties

1. **T2.P1 — canonical low-word range**

   The canonical low words of both inputs lie in `[0, 65535]`.

2. **T2.P2 — relational scaled residue law**

   For arbitrary contract-valid inputs `a` and `b`:

   `(reduce(b)-reduce(a))*65536 ≡ b-a (mod 3329)`.

3. **T2.P3 — exact low-word fibre law**

   If `a` and `b` have identical canonical low 16 bits:

   `reduce(b)-reduce(a) = (b-a)/65536`.

4. **T2.P4 — injectivity inside a fibre**

   On one low-word fibre, equal outputs imply equal inputs.

5. **T2.P5 — general affine translation**

   For every integer `k` for which both inputs remain inside
   the source contract:

   `reduce(a + k*65536) = reduce(a) + k`.

This is a relational theorem over multiple calls and is distinct from
the single-call exact-refinement theorem MONT-T1.
