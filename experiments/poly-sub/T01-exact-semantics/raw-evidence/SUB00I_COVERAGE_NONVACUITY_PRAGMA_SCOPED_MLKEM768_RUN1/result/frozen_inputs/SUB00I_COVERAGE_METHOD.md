# SUB-00I Coverage and Non-Vacuity Method

## Frozen target

- Commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Parameter set: ML-KEM-768
- Frozen coverage harness SHA-256:
  `132c34161c8230eb14e86acc0cae3af52fbf6eb429a8e55233080337dc4415d7`
- Parent accepted SUB-T1 archive SHA-256:
  `054ca49dc569642c4e1395b9f0027dca01da440a6b8653885a1d448ba0ca9a96`

## Coverage goals

The frozen harness contains eight explicit `__CPROVER_cover` calls:

1. at least one positive coefficient difference;
2. at least one negative coefficient difference;
3. at least one zero coefficient difference;
4. at least one non-canonical positive input;
5. at least one non-canonical negative input;
6. an `INT16_MIN` coefficient difference;
7. an `INT16_MAX` coefficient difference;
8. unconditional reachability after production subtraction and reduction.

All eight cover calls occur after:

```
mlk_poly_sub(&L, &LB);
mlk_poly_reduce(&L);
```

## Model correction

The model uses the same correction pattern accepted for SUB-T1:

- function and loop contracts remain disabled;
- only verify.h's narrow conversion pragma is activated;
- the portable optimisation blocker is defined as volatile 64-bit zero;
- production poly_sub and poly_reduce bodies are retained;
- no production source file is modified.

## Unwinding policy

Exact unwindset:

`main.0:257,main.1:257,mlk_barrett_reduce.0:2,mlk_sub00i_cov_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2`

CBMC does not permit `--unwinding-assertions` together with `--cover`.
Therefore this coverage run does not claim a new unwinding proof. Its bounds
are justified by the exact validated loop inventory and the fixed 256- and
one-iteration loop structures. SUB-T1 separately passed its unwinding
assertions for the same production path.

## Interpretation boundary

A coverage goal reported `SATISFIED` supplies a witness that the goal is
reachable under the harness assumptions.

Coverage evidence supports non-vacuity and scenario reachability. It does not
replace the successful SUB-T1 theorem, establish additional functional
correctness, or establish novelty by itself.
