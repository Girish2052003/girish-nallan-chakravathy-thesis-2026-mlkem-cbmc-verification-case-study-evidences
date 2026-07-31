# MSG-00E — Theorem and Property Freeze

## Frozen campaign identity

- Campaign: Functional and Relational Verification of `mlk_poly_tomsg`
- Source commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Modulus: `q = 3329`
- Polynomial degree: `n = 256`
- Message size: `32 bytes = 256 bits`
- Positive theorem families: `4`
- Registered atomic obligations: `25`
- Planned core validation runs: `16 minimum`

The run count may increase when sound model decomposition is necessary.
Additional runs do not create additional theorem families.

---

## MSG-T1 — Exact FIPS Message-Decoding Refinement

For every canonical polynomial coefficient:

```text
0 <= a[k] < 3329
```

the output must satisfy:

```text
msg[i] =
    sum(Compress1(a[8*i+j]) * 2^j, j=0..7)
```

### Obligations

1. complete symbolic canonical domain;
2. independent scalar oracle;
3. exact coefficient index;
4. exact byte selection;
5. exact bit selection;
6. little-endian bit packing;
7. complete 32-byte equality;
8. exact threshold partition and transition boundaries.

The production helper must not be called by the independent oracle.

---

## MSG-T2 — Functional Separability and Bit Locality

For two canonical inputs `A` and `B` producing `MA` and `MB`:

```text
bit_k(MA XOR MB)
=
Compress1(A[k]) XOR Compress1(B[k])
```

### Obligations

1. exact relational XOR law;
2. coefficient locality;
3. cross-bit functional separation;
4. same-decision-region invariance;
5. byte-block confinement;
6. deterministic equality for identical inputs.

### Explicit nonclaims

This theorem does not establish constant-time execution, timing
non-interference, leakage freedom or compiler-level side-channel security.

---

## MSG-T3 — Output-Initialization Independence and Exact State Footprint

For arbitrary initial output arrays `M1_before` and `M2_before`, the same
canonical polynomial input must produce:

```text
M1_after = M2_after
```

### Obligations

1. initial-output independence;
2. complete overwrite of all 32 output bytes;
3. polynomial-input preservation at the new commit;
4. output pre/post guard preservation;
5. unrelated harness-owned-object preservation.

Polynomial-input preservation is a commit-specific revalidation of a property
already present in the older SUB-T6 evidence. It is not claimed as newly
invented.

---

## MSG-T4 — Canonical-Difference-to-Message Functional Composition

For canonical `A` and `B`:

```c
R = A;
mlk_poly_sub(&R, &B);
mlk_poly_reduce(&R);
mlk_poly_tomsg(msg, &R);
```

the final bit must equal:

```text
Compress1(canonical_mod_q(A[k] - B[k]))
```

### Obligations

1. subtraction representability over canonical operands;
2. independent mathematical canonical-difference oracle;
3. exact post-reduction canonical residue equality;
4. exact final per-coefficient FIPS decision;
5. complete 256-bit to 32-byte correspondence;
6. preservation of `B` and registered unrelated state across the slice.

The central new result is exact final-message refinement—not merely
satisfaction of the `mlk_poly_tomsg` input precondition.

---

## Soundness gates applying to all families

1. source commit and file hashes frozen;
2. production C source unmodified;
3. target production calls reachable;
4. relevant production bodies present in the GOTO model;
5. `mlk_scalar_compress_d1` must not be replaced by a
   conclusion-establishing assumption in MSG-T1 or MSG-T4;
6. all reachable loops completely unwound;
7. unwinding assertions enabled;
8. no `assume(false)` or excluded boundary indices;
9. independent oracle does not call production helper functions;
10. positive assertions accompanied by reachability/non-vacuity evidence;
11. implementation and oracle/assertion mutations retained;
12. failed proof/model attempts preserved and classified.

## Validation structure

```text
4 positive theorem executions
4 reachability/non-vacuity companions
4 implementation-mutant executions
4 oracle/assertion-mutant executions
-------------------------------------
16 minimum core runs
```

## Freeze rule

No authoritative harness may silently weaken these obligations. Any necessary
change must be recorded as an explicit theorem-freeze amendment before the
affected positive result is accepted.
