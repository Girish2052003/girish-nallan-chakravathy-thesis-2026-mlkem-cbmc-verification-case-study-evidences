# SUB00M / BATCH 3 — SUB-T3 Complete Cancellation-Family Pre-Registration

## 1. Frozen target

Repository: mlkem-native

Frozen commit:

    d9613cf60de3132d32475c102d8c2781d84feb34

Portable production source family:

    mlkem/src/poly.c
    mlkem/src/poly.h

Production functions:

    mlk_poly_add
    mlk_poly_sub
    mlk_poly_reduce

Parameters:

    FIPS_N = 256
    FIPS_Q = 3329
    coefficient type = int16_t

Primary execution mode:

    MODE-A — production-body bounded execution

MODE-A restrictions:

1. Retain the actual portable production-C bodies.
2. Do not abstract mlk_poly_add with its function contract.
3. Do not abstract mlk_poly_sub with its function contract.
4. Do not abstract mlk_poly_reduce with its function contract.
5. Do not apply source loop contracts as proof replacements.
6. Inspect the generated GOTO model before freezing unwind identifiers.
7. Explicitly unwind every retained production and harness loop.
8. Enable unwinding assertions.
9. Enable the complete frozen safety-check family.
10. Record all command lines, flags, models, properties and results.

MODE-B, if later performed, must be separately labelled as
annotation-assisted complementary evidence.

## 2. Campaign continuity

Previously completed evidence is not modified by SUB00M:

    SUB-T1 semantic result: unchanged
    SUB00I coverage result: unchanged
    SUB00K mutation result: unchanged
    SUB-T2 status: separate campaign item

SUB-T3 is a new cross-function cancellation family.

The SUB-T3 freeze does not replace, amend or reinterpret SUB-T1 or SUB-T2.

## 3. Existing-source boundary

The production source contracts already state exact local semantics for:

    mlk_poly_add
    mlk_poly_sub

Therefore, isolated statements such as:

    output = input + b
    output = input - b

are not new theorems.

SUB-T3 instead concerns compositions of multiple production calls.

No claim is made that elementary algebraic cancellation is newly discovered.

The intended contribution is the design, execution and evaluation of
cross-function CBMC verification artefacts against the real production
implementation.

Prior dedicated CBMC proof status remains unknown until the final
post-freeze repository and literature audit.

## 4. Common object and frame conditions

For every SUB-T3 theorem:

1. All polynomial objects are valid.
2. Mutable and read-only objects are disjoint.
3. Original A and B snapshots are retained.
4. Every read-only B object remains unchanged.
5. Left-path calls must not alter right-path objects.
6. Right-path calls must not alter left-path objects.
7. All 256 coefficients are checked.
8. Coefficient 0 and coefficient 255 are explicitly covered.
9. No conclusion is introduced as an assumption.

## 5. SUB-T3A — Exact subtract-then-add cancellation

Let A and B be arbitrary int16_t polynomials.

Required domain condition, for every coefficient i:

    INT16_MIN <= (int32_t)A[i] - (int32_t)B[i]
    (int32_t)A[i] - (int32_t)B[i] <= INT16_MAX

Execution:

    R = A
    RB = B

    mlk_poly_sub(&R, &RB)

    D = R

    mlk_poly_add(&R, &RB)

Prove for every coefficient i:

    D[i] = (int32_t)A[i] - (int32_t)B[i]
    R[i] = A[i]
    RB[i] = B[i]

The addition after subtraction must not receive a separate
representability assumption.

Its mathematical result is A[i], which is already int16_t.

The harness and CBMC arithmetic checks must establish this fact.

Mathematical statement:

    (A - B) + B = A

over the complete domain where the initial direct subtraction is
representable in int16_t.

Classification:

    Cross-function exact-cancellation composition theorem.
    Apparently absent as an explicit source-level composition contract.
    Elementary algebra; not a novelty headline.
    Prior dedicated CBMC-proof status unknown.

## 6. SUB-T3B — Exact add-then-subtract cancellation

Let A and B be arbitrary int16_t polynomials.

Required domain condition, for every coefficient i:

    INT16_MIN <= (int32_t)A[i] + (int32_t)B[i]
    (int32_t)A[i] + (int32_t)B[i] <= INT16_MAX

Execution:

    R = A
    RB = B

    mlk_poly_add(&R, &RB)

    S = R

    mlk_poly_sub(&R, &RB)

Prove for every coefficient i:

    S[i] = (int32_t)A[i] + (int32_t)B[i]
    R[i] = A[i]
    RB[i] = B[i]

The subtraction after addition must not receive a separate
representability assumption.

Its mathematical result is A[i], which is already int16_t.

Mathematical statement:

    (A + B) - B = A

over the complete domain where the initial direct addition is
representable in int16_t.

Classification:

    Cross-function exact-cancellation composition theorem.
    Apparently absent as an explicit source-level composition contract.
    Elementary algebra; not a novelty headline.
    Prior dedicated CBMC-proof status unknown.

## 7. SUB-T3C — Central canonical modular cancellation theorem

Let A and B be arbitrary int16_t polynomials satisfying the direct
subtraction representability condition:

    INT16_MIN <= (int32_t)A[i] - (int32_t)B[i]
    (int32_t)A[i] - (int32_t)B[i] <= INT16_MAX

Production execution:

    X = A
    XB = B

    mlk_poly_sub(&X, &XB)
    mlk_poly_reduce(&X)

    NB = B
    mlk_poly_reduce(&NB)

    mlk_poly_add(&X, &NB)
    mlk_poly_reduce(&X)

Independent comparison path:

    NA = A
    mlk_poly_reduce(&NA)

Prove for every coefficient i:

    X[i] = NA[i]

    0 <= X[i] < FIPS_Q
    0 <= NA[i] < FIPS_Q
    0 <= NB[i] < FIPS_Q

Also prove before the recovery addition:

    0 <= X[i] <= FIPS_Q - 1
    0 <= NB[i] <= FIPS_Q - 1

and therefore:

    0 <= (int32_t)X[i] + (int32_t)NB[i]
    (int32_t)X[i] + (int32_t)NB[i] <= 2 * (FIPS_Q - 1)
    (int32_t)X[i] + (int32_t)NB[i] <= 6656
    6656 <= INT16_MAX

No assumption may be added for this normalized addition.

Mathematical statement:

    N(N(A - B) + N(B)) = N(A)

where N is the production unsigned-canonical normalization operation.

## 8. Independent FIPS-bound semantic anchor for SUB-T3C

For each original A coefficient, compute:

    int32_t a32 = (int32_t)saved_A.coeffs[i];

    uint32_t shifted =
        (uint32_t)(a32 + 10 * FIPS_Q);

    uint32_t expected_A =
        shifted % (uint32_t)FIPS_Q;

Since A[i] is int16_t:

    -32768 <= A[i] <= 32767

and:

    522 <= A[i] + 10 * 3329 <= 66057

Therefore the oracle does not use negative signed remainder.

Prove:

    X[i] == expected_A
    NA[i] == expected_A

The production constant and independent constant must be separately
bound:

    MLKEM_N == FIPS_N
    MLKEM_Q == FIPS_Q

Classification:

    Cross-function modular-cancellation refinement theorem.
    Stronger than local add/sub contracts.
    Apparently absent as an explicit source composition contract.
    Prior dedicated CBMC-proof status unknown.
    Final novelty wording deferred until post-freeze audit.

## 9. Machine-model assertions

Each harness must assert:

    CHAR_BIT == 8
    sizeof(short) * CHAR_BIT == 16
    sizeof(int) * CHAR_BIT == 32
    sizeof(int16_t) * CHAR_BIT == 16
    sizeof(int32_t) * CHAR_BIT == 32
    sizeof(void *) * CHAR_BIT == 64

    ((int32_t)-1 >> 1) == (int32_t)-1
    ((int32_t)-3 >> 1) == (int32_t)-2

These bind the verified result to the recorded CBMC machine model.

Endianness is administrative metadata, not a theorem precondition for
coefficient-wise arithmetic without byte reinterpretation.

## 10. Prohibited assumptions

The harnesses must not assume:

1. A is canonical.
2. B is canonical.
3. A is non-negative.
4. B is non-negative.
5. A or B is small.
6. A equals the final result.
7. Cancellation already holds.
8. Production reduction is semantically correct.
9. Production and oracle values already agree.
10. The recovery addition is representable in SUB-T3C.
11. Loop completion without unwinding assertions.
12. Existing function contracts as MODE-A abstractions.
13. Aliasing between mutable and read-only polynomial objects.

## 11. Boundary-control family

### SUB-T3A valid difference boundaries

Construct cases with:

    A - B = INT16_MIN
    A - B = INT16_MAX

Expected result:

    SUB-T3A cancellation succeeds.

### SUB-T3A invalid difference boundaries

Construct cases with mathematical values:

    A - B = INT16_MIN - 1
    A - B = INT16_MAX + 1

Expected result:

    outside the SUB-T3A theorem domain

These are negative controls, not valid theorem instances.

### SUB-T3B valid addition boundaries

Construct cases with:

    A + B = INT16_MIN
    A + B = INT16_MAX

Expected result:

    SUB-T3B cancellation succeeds.

### SUB-T3B invalid addition boundaries

Construct cases with mathematical values:

    A + B = INT16_MIN - 1
    A + B = INT16_MAX + 1

Expected result:

    outside the SUB-T3B theorem domain

### SUB-T3C internal normalized-addition boundary

Demonstrate reachable recovery-addition values including:

    0
    FIPS_Q - 1
    FIPS_Q
    2 * (FIPS_Q - 1) = 6656

and prove that the internal addition remains int16_t-representable.

## 12. Required reachability evidence

The T3 campaign must demonstrate reachability for:

1. Positive B coefficients.
2. Negative B coefficients.
3. Zero B coefficients.
4. Positive initial differences.
5. Negative initial differences.
6. Zero initial differences.
7. Noncanonical positive A.
8. Noncanonical negative A.
9. Noncanonical positive B.
10. Noncanonical negative B.
11. INT16_MIN valid initial arithmetic boundary.
12. INT16_MAX valid initial arithmetic boundary.
13. Coefficient 0.
14. Coefficient 255.
15. Normalized recovery addition without modular wrap.
16. Normalized recovery addition requiring modular wrap.

Reachability evidence must be produced separately from universal proof
results.

## 13. Frame assertions

The harnesses must include phase-boundary snapshots proving:

1. Original saved A is unchanged.
2. Original saved B is unchanged.
3. Read-only B copies remain unchanged after add and sub.
4. SUB-T3A intermediate D remains unchanged after it is snapshotted.
5. SUB-T3B intermediate S remains unchanged after it is snapshotted.
6. SUB-T3C independent NA path does not alter X or NB.
7. SUB-T3C X/NB path does not alter NA.
8. Completed-path objects remain stable while the other path executes.

## 14. Mutation and negative-control matrix

At minimum, the frozen T3 campaign must prepare these mutants:

### T3-M1 — Wrong recovery operation

Replace the recovery add in SUB-T3A or SUB-T3C with subtraction.

Expected:

    killed by the intended cancellation assertion

### T3-M2 — Missing recovery operation

Omit the recovery addition.

Expected:

    killed by the intended cancellation assertion

### T3-M3 — Wrong operand

Use A instead of B as the recovery operand.

Expected:

    killed by the intended cancellation assertion

### T3-M4 — Skip coefficient 255

Do not perform one operation on coefficient 255.

Expected:

    killed with an admissible mismatch at coefficient 255

### T3-M5 — Missing final normalization

Omit the final reduction in SUB-T3C.

Expected:

    killed by canonical-range or semantic equality evidence for a
    reachable modular-wrap input

### T3-M6 — Independent expected value plus one

Compare against:

    expected_A + 1 modulo FIPS_Q

Expected:

    killed by the independent semantic assertion

Mutation testing may establish sensitivity to the selected mutants.
It does not establish theorem novelty or completeness against all
possible defects.

## 15. Required CBMC result classification

Universal positive theorem runs require:

    raw CBMC exit code = 0
    all expected properties present
    all intended assertions SUCCESS
    zero unwinding failures
    no parser failure
    no timeout
    final independent validation exit code = 0

Expected-failure controls and mutants require:

    raw CBMC exit code = 10
    intended property FAILURE
    admissible witness
    zero unwinding failures
    expected property count present
    no parser failure
    no timeout
    final independent validation exit code = 0

Any other result must be classified as:

    INCONCLUSIVE_OR_INVALID

It must not be silently reported as PASS.

## 16. Safety checks to preserve

The final command must preserve at least:

    --bounds-check
    --pointer-check
    --pointer-overflow-check
    --pointer-primitive-check
    --signed-overflow-check
    --unsigned-overflow-check
    --conversion-check
    --undefined-shift-check
    --div-by-zero-check
    --unwinding-assertions

Object bits, solver, slicing, trace format, architecture, function
retention and exact unwind sets must be frozen after GOTO inspection
and before theorem execution.

## 17. Cross-parameter replication

After the ML-KEM-768 primary execution, the same frozen theorem family
may be rebuilt for:

    ML-KEM-512
    ML-KEM-1024

These are configuration and build replications.

They are not three mathematically distinct cancellation theorems,
because MLKEM_N and MLKEM_Q are shared.

## 18. Novelty wording restriction

Prohibited before final audit:

    first proof in the world
    completely novel theorem
    never proved before
    no one has proved this

Permitted:

    independently derived cancellation-family theorem
    apparently absent as an explicit source composition contract
    clean-room-authored CBMC artefact candidate
    prior dedicated CBMC-proof status unknown

Only after the recorded post-freeze audit may the thesis state:

    To the best of the documented repository and literature search
    conducted on the recorded date, no equivalent prior CBMC proof
    was identified.

## 19. Freeze rule

This theorem family must not be silently altered after hashing.

Any correction must receive:

1. a new version identifier;
2. a reason-for-change record;
3. a new SHA-256 hash;
4. a statement identifying which prior results are superseded;
5. preservation of the original frozen packet.
