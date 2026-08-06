# A-to-Z compact evidence record — `mlk_barrett_reduce`

## 1. Scope

This corpus targets the real C arithmetic body of `mlk_barrett_reduce` in
`pq-code-package/mlkem-native` commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`. One campaign run is
permitted. The production repository file is never edited.

## 2. Existing evidence deliberately excluded

The supplied BR-AF4 T1–T5 record already covers exact centered range and congruence,
independent-oracle equality, closest representative, fixed point, idempotence,
residue-class invariance, quotient cells, multiplier uniqueness, and admissible
offset intervals. None of those is selected again.

The current native function contract directly states only the centered output range.
The repository's basic harness invokes one symbolic call and does not explicitly
assert either new relational theorem below.

## 3. New theorem SA-BR-T1

**Sign-conjugate reduction and quotient reversal**

```text
R(-a) = -R(a)
(a-R(a))/3329 = -((-a-R(-a))/3329)
```

Domain: every `int16_t` except `INT16_MIN`; its negation cannot be represented by the
same C type. The harness makes two real calls and also checks exact quotient
integrality and equal remainder magnitude.

## 4. New theorem SA-BR-T2

**Centered-addition closure with exact one-correction carry**

For unrestricted symbolic `a,b`, the harness calls `R(a)`, `R(b)`, then
`R(R(a)+R(b))`. Because the first two results are centered, their sum is in
`[-3328,3328]`. The third call must apply exactly one of `+3329`, `0`, or `-3329`
and equal an independent centered-modulo oracle for the full mathematical sum `a+b`.

## 5. Preconditions and assumptions

| Theorem | Preconditions | Principal assumptions |
|---|---|---|
| SA-BR-T1 | `a` is `int16_t`; representable negation | `a != INT16_MIN` |
| SA-BR-T2 | `a,b` are unrestricted `int16_t` | none |

No assumption contains a selected postcondition. `assume(false)` is forbidden.
Named covers establish feasibility, nontrivial branches, every target return, and the
assertion block.

## 6. Postconditions

SA-BR-T1 proves sign conjugacy, magnitude preservation, quotient integrality, and
quotient reversal. SA-BR-T2 proves representable centered addition, correction
coefficient bounds, exact one-correction behavior, full-sum oracle equality,
congruence, and centered final range.

## 7. Production-body binding

`runner/expose_barrett.py` locates exactly one production signature and creates a
run-local externally visible copy. Only `static MLK_INLINE` linkage is removed. The
body is byte-compared and SHA-256-bound; required literals `20159`, `1<<25`, `>>26`,
and `MLKEM_Q` must remain. The original `poly.c` is hashed and untouched.

## 8. GOTO models and CBMC execution

Each theorem produces three separate models:

1. universal proof model;
2. cover/non-vacuity model;
3. expected-failure control model.

The proof enables bounds, pointer, pointer-overflow, signed/unsigned overflow,
conversion, division-by-zero, undefined-shift, and unwinding checks. Function,
symbol, loop, and property inventories are retained. Solver JSON, stderr, commands,
exit codes, body-binding records, and hashes are preserved.

## 9. Sensitivity controls

- SA-BR-T1 deliberately asserts false even symmetry at `a=1`.
- SA-BR-T2 deliberately asserts that no correction occurs on a positive-wrap branch.

Acceptance requires CBMC exit `10` and rejection of the exact named false property;
a build failure or unrelated failure is insufficient.

## 10. Distinctness and contamination

Exact new theorem identifiers and harness filenames were absent from all 33 supplied
records. The current repository review identified no explicit sign-conjugacy/quotient-
reversal or centered-addition one-correction theorem in the native Barrett contract or
basic harness. Therefore repository distinctness is `SUPPORTED` within the audited
scope. This is not a claim that the underlying modular identities are new mathematics.
No contamination is known.

## 11. Evidence acceptance

The final summarizer refuses acceptance unless:

```text
proof exits                         0
coverage exits                      0
planned false-property exits       10
all selected tokens in inventories YES
all named covers satisfied         YES
body binding                       PASS
repository exact-token audit       SUPPORTED
all required artefacts             present
```

## 12. Requested final markings

```text
RUNS OCCURED               1
Selected-claim mapping     YES
Target reachability        YES
Assertion reachability     YES
Assumption feasibility     YES
Evidence completeness      COMPLETE
Repository distinctness    SUPPORTED
Contamination              NONE KNOWN
```

## 13. Claim boundary

The package is a complete evidence corpus and fail-closed execution mechanism. The
included local semantic audit is an independent deterministic cross-check, not a
substitute for CBMC. Authoritative solver results are created only by executing the
runner in the pinned Ubuntu/CBMC environment.
