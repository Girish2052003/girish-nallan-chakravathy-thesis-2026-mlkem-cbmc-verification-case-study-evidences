# Selected theorem list

## SA-BR-T1 — Sign-conjugate reduction and quotient reversal

For every `int16_t a` except `INT16_MIN`, let `R` be the real production
`mlk_barrett_reduce` and `Q(a)=(a-R(a))/3329`:

```text
R(-a) = -R(a)
Q(-a) = -Q(a)
|R(-a)| = |R(a)|
```

Precondition: `a != INT16_MIN`. Target calls: 2. The excluded point exists only
because its mathematical negation is not representable by `int16_t`.

## SA-BR-T2 — Centered-addition closure with exact one-correction carry

For unrestricted `int16_t a,b`, define:

```text
ra = R(a)
rb = R(b)
s  = ra + rb                    where -3328 <= s <= 3328
c  = 1 if s > 1664, -1 if s < -1664, otherwise 0
```

The real third call must satisfy:

```text
R(s) = s - c*3329
R(s) = centered_mod_3329(a+b)
c in {-1,0,1}
```

Preconditions: none beyond the input types. Target calls: 3. The oracle uses `%`
and conditional canonicalization, not the production magic multiplier or shift.
