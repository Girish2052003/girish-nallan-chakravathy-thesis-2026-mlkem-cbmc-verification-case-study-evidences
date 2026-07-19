# Clean-room `mlk_poly_add` assumption and property ledger

## Target binding

- Repository: `pq-code-package/mlkem-native`
- Commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Function: `void mlk_poly_add(mlk_poly *r, const mlk_poly *b)`
- Representation: `mlk_poly` contains `int16_t coeffs[MLKEM_N]`
- Target constants supplied by the experiment input: `MLKEM_N = 256`, `MLKEM_Q = 3329`

## Permitted evidence used

1. FIPS 203 mathematical parameters and polynomial representation.
2. FIPS 203 coordinate-wise polynomial addition modulo `q`.
3. The production function body and ordinary API comments.
4. The production type and constant definitions.
5. The fact that the target is a destructive two-argument accumulator.

## Assumptions in this harness

### A1 — Canonical FIPS representative domain

For every coefficient:

```text
0 <= a[i] < q
0 <= b[i] < q
```

This selects unsigned canonical representatives of elements of `Z_q`.

**Scope consequence:** This is a legitimate FIPS-domain experiment, but it is narrower than the complete implementation-valid domain because production internals may also use signed or non-canonical representatives.

### A2 — Distinct target-call objects

The harness allocates separate local objects for every output and read-only operand. Therefore, each call satisfies the target's disjointness requirement by construction. No pointer-disjointness assumption is injected.

### A3 — Integer-sum safety is derived, not assumed

From A1:

```text
0 <= a[i] + b[i] <= 2q - 2
```

With `q = 3329`:

```text
0 <= a[i] + b[i] <= 6656
```

This fits in `int16_t`, so the harness does not need to assume an arbitrary overflow-prevention predicate.

### A4 — Parameter binding is asserted

The harness asserts, rather than assumes:

```text
MLKEM_N == 256
MLKEM_Q == 3329
```

A changed or incorrectly selected configuration must fail visibly.

## Checked properties

- **P1 Exact implementation result:** each output coefficient equals the unreduced integer sum.
- **P2 Derived result interval:** each output coefficient lies in `[0, 2q-2]`.
- **P3 FIPS refinement:** reducing the stored result modulo `q` gives FIPS coefficient addition in `Z_q`.
- **P4 Frame conditions:** the read-only operands remain unchanged.
- **P5 Metamorphic commutativity:** running the accumulator in both operand orders gives equal results.
- **P6 Metamorphic identity:** adding a zero polynomial leaves the accumulator unchanged.
- **P7 Tool-level safety:** CBMC should additionally check bounds, pointers, signed overflow, narrowing conversions, and loop unwinding.

## Recommended CBMC checks

Use the repository's already working configuration and include flags, together with checks equivalent to:

```text
--function main
--bounds-check
--pointer-check
--pointer-overflow-check
--signed-overflow-check
--conversion-check
--div-by-zero-check
--unwind 257
--unwinding-assertions
```

Do not enable contract replacement, function-contract enforcement, or loop-contract transformation for the clean-room BMC run. The target body should be explored directly.

## Research-integrity warning

The supplied extraction unintentionally exposed the existing declaration contract and loop invariants for `mlk_poly_add`. Therefore, this run is **not perfectly blind to all existing formal artefacts**, although the original harness was not supplied.

The generated harness is independently structured around:

- a canonical FIPS input profile;
- modulo-`q` refinement;
- input-frame checks;
- commutativity;
- additive identity.

For a defensible strict clean-room replication, repeat generation in a fresh conversation using a sanitized source extraction that removes:

```text
__contract__(...)
__loop__(...)
requires(...)
ensures(...)
assigns(...)
invariant(...)
decreases(...)
```

while preserving the ordinary comments, types, constants, call sites, and executable C statements.

## Still needed before claiming full production-context coverage

1. Surrounding code for the three production call sites in `poly_k.c` and `indcpa.c`.
2. The exact successful CBMC compile command and active `-D` configuration.
3. CBMC version.
4. Confirmation that native `poly_add` substitution is disabled or irrelevant.
5. A record proving that no existing harness or proof result entered the generation prompt.
