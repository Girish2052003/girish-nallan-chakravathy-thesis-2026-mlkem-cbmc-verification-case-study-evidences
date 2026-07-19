# SUB00N / BATCH 4 — SUB-T4 Theorem Pre-Registration

## 1. Campaign identity

Repository: mlkem-native

Frozen commit:

    d9613cf60de3132d32475c102d8c2781d84feb34

Target production function:

    mlk_poly_sub

Target implementation family:

    Portable production C

Polynomial parameters independently bound for this experiment:

    FIPS_N = 256
    FIPS_Q = 3329
    coefficient type = int16_t

This batch is isolated from Batch 3. No Batch-3 artefact, process,
result, directory, theorem statement, or execution package may be
modified by Batch 4.

## 2. Scientific role

SUB-T4 is a canonical-domain representability and range theorem.

It is not claimed as a newly discovered mathematical identity.

Its purpose is to connect the canonical ML-KEM coefficient domain to
the lower-level production mlk_poly_sub representability condition.

The theorem is supplementary evidence and must not replace the
co-primary SUB-T1 or SUB-T2 results.

## 3. Frozen input domain

Let A and B be independent valid polynomial objects.

For every coefficient index i:

    0 <= A[i] < FIPS_Q
    0 <= B[i] < FIPS_Q

Because FIPS_Q = 3329, this means:

    0 <= A[i] <= 3328
    0 <= B[i] <= 3328

No separate assumption that A[i] - B[i] fits in int16_t is permitted.

Representability must follow from the canonical-domain assumptions.

## 4. Production execution

Create independent production and snapshot objects:

    R = A
    SAVED_A = A
    SAVED_B = B

Execute the genuine production operation:

    mlk_poly_sub(&R, &B)

No replacement subtraction model may be used for the positive theorem.

No mlk_poly_sub function contract may be used as an abstraction in
the mandatory MODE-A execution.

## 5. Primary SUB-T4 claims

For every coefficient index i, prove:

    R[i] = (int32_t)SAVED_A[i] - (int32_t)SAVED_B[i]

and:

    -(FIPS_Q - 1) <= R[i]
    R[i] <= FIPS_Q - 1

which binds concretely to:

    -3328 <= R[i] <= 3328

Also prove that the mathematical difference is representable in
int16_t:

    INT16_MIN
        <= (int32_t)SAVED_A[i] - (int32_t)SAVED_B[i]
        <= INT16_MAX

The representability result must be a proved consequence rather than
a harness assumption.

## 6. Supporting integrity claims

The Batch-4 positive harness must additionally check:

1. FIPS_N == 256.
2. FIPS_Q == 3329.
3. int16_t has exactly 16 value bits plus sign representation
   consistent with the frozen CBMC model.
4. int32_t has width 32.
5. The source polynomial B is unchanged.
6. The saved snapshots of A and B are unchanged.
7. All relevant loops are fully unwound.
8. Unwinding assertions are enabled.
9. Standard bounds, pointer, arithmetic, shift and conversion checks
   are enabled.
10. No production source file is changed.

These supporting claims are not separate novelty claims.

## 7. Required satisfiability controls

The Batch-4 execution package must show reachable admissible inputs
for at least:

    maximum positive difference:
        A[i] = 3328
        B[i] = 0
        difference = 3328

    maximum negative difference:
        A[i] = 0
        B[i] = 3328
        difference = -3328

    zero difference:
        A[i] = B[i]

    an interior positive difference

    an interior negative difference

Coverage results must be labelled as reachability evidence, not as
additional mathematical theorem proofs.

## 8. Frozen expected-failure controls

### B4-NC1 — Stricter upper bound must fail

The deliberately false universal claim:

    R[i] <= 3327

must be falsifiable by an admissible canonical witness with:

    A[i] = 3328
    B[i] = 0

Expected classification:

    KILLED_BY_UPPER_BOUND_WITNESS

### B4-NC2 — Stricter lower bound must fail

The deliberately false universal claim:

    R[i] >= -3327

must be falsifiable by an admissible canonical witness with:

    A[i] = 0
    B[i] = 3328

Expected classification:

    KILLED_BY_LOWER_BOUND_WITNESS

These negative controls must be isolated from the positive theorem
model and must not modify the successful positive result.

## 9. Prohibited experiment shortcuts

The positive theorem must not:

1. Assume the final range directly.
2. Assume subtraction representability directly.
3. Replace mlk_poly_sub with harness-side arithmetic.
4. use the existing mlk_poly_sub contract as the proof body.
5. disable unwinding assertions.
6. silently use loop-contract abstraction in MODE-A.
7. restrict all coefficients to a few concrete examples.
8. describe SUB-T4 as a world-first mathematical theorem.
9. modify Batch 3.
10. modify the frozen SUB-T1 or SUB-T2 evidence.

## 10. Evidence mode

Mandatory primary evidence:

    MODE-A
    genuine production bodies
    no function-contract abstraction
    no silent loop-contract abstraction
    complete explicit loop execution
    unwinding assertions enabled

Any later MODE-B loop-contract-assisted replication must be labelled
complementary and must not replace MODE-A.

## 11. Novelty wording restriction

Permitted wording:

    canonical-domain representability theorem
    FIPS-domain-to-production-contract bridge
    independently authored CBMC verification artefact
    derived boundary property checked against production C

Prohibited wording:

    newly discovered arithmetic law
    first proof in the world
    completely novel theorem
    no one has ever proved this

## 12. Freeze rule

This preregistered theorem, domain, range, controls and expected
classifications must not be silently changed after hashing.

Any correction requires:

    a new version identifier
    a reason-for-change record
    a new SHA-256 hash
