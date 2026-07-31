# ML-KEM `mlk_poly_tomsg` T5 Exact Admissible Offset Interval — Final Acceptance

## Accepted theorem

Fix the scalar compression multiplier to `1290168`, the right shift to `31`,
and interpret multiplication and addition through explicit `uint32_t`
modulo-\(2^32\) arithmetic.

For every canonical ML-KEM coefficient:

\[
0 \leq u < 3329,
\]

define:

\[
F_c(u)=
\operatorname{MSB}_{32}
\left(
(u\cdot1290168+c)\bmod 2^{32}
\right).
\]

Then:

\[
\left[
\forall u\in[0,3328],\
F_c(u)=1\iff833\leq u\leq2496
\right]
\]

holds exactly when:

\[
1073417800\leq c\leq1074063871.
\]

The exact admissible set is therefore the single closed interval:

\[
[1073417800,1074063871].
\]

It contains 646072 offsets.

The production offset:

\[
2^{30}=1073741824
\]

is an interior member of the interval.

## Evidence chain

1. **MSG05A:** captured the frozen source expression and searched the native
   repository for an equivalent parameterized-offset theorem.
2. **MSG05B:** deterministically derived the candidate exact interval, its
   cardinality, production membership, and the nearest rejected offsets.
3. **MSG05C:** proved that the parameterized model at the production offset
   equals both the real frozen scalar helper and the selected bit produced by
   the real frozen `mlk_poly_tomsg` execution.
4. **MSG05D:** proved interval sufficiency for every canonical coefficient and
   every offset inside the interval.
5. **MSG05E:** proved that every `uint32_t` offset outside the interval has a
   canonical counterexample, using a complete three-part outside-domain
   partition.
6. **MSG05F:** established reachability for the three partitions and rejected
   both one-step endpoint expansions through isolated expected-failure
   mutations.

## Quantitative evidence

- Positive CBMC proof stages: 3
- Successful positive properties: 553
- Positive proof failures: 0
- Positive proof UNKNOWN results: 0
- Reachability goals: 10 of 10
- Outside-domain partitions reachable: 3 of 3
- Endpoint mutations rejected: 2 of 2
- Revalidated GOTO binaries: 6
- Interval cardinality: 646072
- Canonical coefficient values: 3329
- Symbolically covered inside coefficient-offset combinations: 2150773688

## Repository-level novelty and distinctness

The frozen mlkem-native repository contains fixed-function proofs for
`mlk_scalar_compress_d1` and `mlk_poly_tomsg`. The captured repository search
found no equivalent proof that parameterizes the `uint32_t` rounding offset
and characterizes every admissible offset.

T5 is logically distinct from:

- **T1**, which proves correctness of the single fixed production offset; and
- **T2**, which proves relational properties between multiple executions.

T5 characterizes the complete parameter space of offsets while keeping the
production multiplier and shift fixed.

Repository-level novelty and campaign-level distinctness are accepted.
Global or world-first research novelty is not claimed without a separate
literature review.

## Scope and assumptions

The accepted claim is limited to:

- frozen commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`;
- ML-KEM-768 configuration;
- canonical coefficients `0 <= u < 3329`;
- multiplier `1290168`;
- shift `31`;
- `uint32_t` offset domain;
- explicit modulo-\(2^{32}\) arithmetic;
- CBMC 6.9.0 and the recorded C model;
- the evidence-local parameterized model formally bound to production at the
  actual production offset.

## Explicit non-claims

This campaign does not prove:

- correctness for a changed multiplier or changed shift;
- correctness for non-canonical coefficients;
- correctness for every ML-KEM parameter set independently;
- correctness of the entire ML-KEM implementation;
- assembly-level equivalence;
- timing or constant-time behavior;
- cache, power, electromagnetic, speculative-execution, or other leakage
  resistance;
- global research novelty;
- that the production function itself accepts a runtime-selectable offset.

The production implementation retains a fixed offset. The parameterized model
is an evidence-local robustness model whose production-offset instance was
formally bound to the frozen implementation.
