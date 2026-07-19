# Claim and scope

## Scoped claim

For all modelled polynomial inputs satisfying the recorded signed-int16
representability assumptions, execution of the frozen portable C bodies of
`mlk_poly_sub` followed by `mlk_poly_reduce` produces coefficients in
`[0,3329)` equal to the independent canonical modular-difference oracle,
while preserving the recorded frame conditions.

## Binding

- Commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Parameter set: `ML-KEM-768`
- Polynomial degree: `256`
- Modulus: `3329`
- Implementation path: portable C
- Solver: CBMC 6.9.0
