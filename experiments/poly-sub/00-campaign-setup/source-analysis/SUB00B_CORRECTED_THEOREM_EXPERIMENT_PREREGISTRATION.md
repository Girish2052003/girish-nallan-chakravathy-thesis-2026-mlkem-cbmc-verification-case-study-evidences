# SUB-00B Corrected Theorem and Experiment Pre-Registration

## 1. Frozen target

Repository: mlkem-native

Frozen commit:

    d9613cf60de3132d32475c102d8c2781d84feb34

Branch at source collection:

    main

Production implementation:

    mlkem/src/poly.c

Production declarations and contracts:

    mlkem/src/poly.h

Target function:

    mlk_poly_sub

Composition function:

    mlk_poly_reduce

Production caller:

    mlk_indcpa_dec

Source collection date:

    17 July 2026

Production packet SHA-256:

    e557c98ff5d3e3735d9f9f59c67a030e87ea0f4898b92d120856321a74ba7f45

Recorded tool environment:

    CBMC 6.9.0
    goto-cc 6.9.0
    GCC/cc 13.3.0
    architecture x86_64

## 2. Clean-room provenance and disclosure

The SUB-T1 and SUB-T2 theorem statements were independently derived
from FIPS 203 and the source-only production packet before inspection
of the repository's dedicated poly_sub proof harness.

During pre-freeze quality review on 17 July 2026, the reviewing
assistant opened the public repository file:

    proofs/cbmc/poly_sub/Makefile

at the frozen commit.

The reviewing assistant did not inspect:

    proofs/cbmc/poly_sub/poly_sub_harness.c
    dedicated poly_sub proof reports
    dedicated poly_sub JSON results
    dedicated poly_sub execution logs
    counterexample traces from the existing proof

The exposed Makefile constitutes prior-proof metadata exposure and is
recorded transparently.

No SUB-T1 or SUB-T2 theorem statement was copied from or derived from
that Makefile.

The initial discovery command also exposed generic CBMC safety-result
lines from older poly_add-era logs. Therefore, basic pointer safety,
array bounds, and ordinary overflow checks are not eligible for novelty
claims in this campaign.

Final novelty classification remains deferred until after:

    theorem freeze
    harness freeze
    CBMC execution
    repository-proof comparison
    public-code search
    literature search

## 3. Frozen mathematical and implementation parameters

FIPS polynomial length:

    FIPS_N = 256

FIPS modulus:

    FIPS_Q = 3329

Production bindings that must be asserted by the harness:

    MLKEM_N == FIPS_N
    MLKEM_Q == FIPS_Q

Production coefficient type:

    int16_t

The harness must use separately defined FIPS_N and FIPS_Q constants.
It must not derive its semantic oracle solely from mutable repository
constants.

## 4. Existing baseline theorem: SUB-T0

### Statement

For every coefficient i, under valid object, non-aliasing, and
representability conditions:

    result[i] = initial_r[i] - b[i]

### Classification

    Existing source-contract theorem.
    Existing loop-invariant theorem.
    Baseline replication only.
    Not claimed as novel.

### Purpose

SUB-T0 is retained as a ground-truth control showing whether the
workflow reconstructs the authoritative local function semantics.

## 5. Co-primary semantic theorem: SUB-T1

### Name

Full signed-domain modular refinement of production subtraction
followed by production normalization.

### Inputs

Let A0 and B0 be independently stored nondeterministic mlk_poly
objects.

For every coefficient i, require:

    INT16_MIN <= (int32_t)A0[i] - (int32_t)B0[i]
    (int32_t)A0[i] - (int32_t)B0[i] <= INT16_MAX

No assumption may require A0 or B0 to be:

    canonical
    non-negative
    small
    already reduced modulo q

### Production execution

Create independent working copies:

    L  = A0
    LB = B0

Execute real production functions:

    mlk_poly_sub(&L, &LB)
    mlk_poly_reduce(&L)

### Independent semantic oracle

For every coefficient i:

    d = (int32_t)saved_A0[i] - (int32_t)saved_B0[i]

Because d is restricted to the int16_t range:

    -32768 <= d <= 32767

Define:

    shifted = (uint32_t)(d + 10 * FIPS_Q)
    expected = shifted % (uint32_t)FIPS_Q

Since 10 * FIPS_Q is a multiple of FIPS_Q and d + 10 * FIPS_Q is
non-negative, expected is the canonical representative of d modulo
FIPS_Q without relying on negative signed remainder semantics.

### Required conclusions

For every coefficient i:

    0 <= L[i]
    L[i] < FIPS_Q
    L[i] == expected

### Role

SUB-T1 is a co-primary theorem and the independent semantic anchor.

It prevents the campaign from accepting two production paths that
agree with each other while sharing the same defect.

### Initial origin classification

    Source-documented and implementation-implied semantic property.

    Apparently absent as an explicit public mlk_poly_reduce
    input/output congruence postcondition.

    Apparently absent as a dedicated public sub-then-reduce
    composition theorem in the supplied source contracts.

    Dedicated prior CBMC-proof status presently unknown.

## 6. Co-primary relational theorem: SUB-T2

### Name

Normalization commutes with production subtraction.

### Inputs

Use the same arbitrary int16_t source objects A0 and B0 and the same
direct-subtraction representability condition as SUB-T1.

### Left production path

    L  = A0
    LB = B0

    mlk_poly_sub(&L, &LB)
    mlk_poly_reduce(&L)

### Right production path

    RA = A0
    RB = B0

    mlk_poly_reduce(&RA)
    mlk_poly_reduce(&RB)
    mlk_poly_sub(&RA, &RB)
    mlk_poly_reduce(&RA)

### Required conclusions

For every coefficient i:

    L[i] == RA[i]

    0 <= L[i]
    L[i] < FIPS_Q

    0 <= RA[i]
    RA[i] < FIPS_Q

### Mathematical statement

    N(A - B) = N(N(A) - N(B))

where N denotes production unsigned-canonical normalization.

### Role

SUB-T2 is a co-primary relational theorem and the central relational
novelty candidate.

It checks representative-independence and compatibility of two
different production compositions.

### Common-mode limitation

SUB-T2 alone is not a complete subtraction-correctness oracle.

If both paths contain the same defect, they may remain equal.

Examples include:

    replacing all subtraction calls with addition
    skipping coefficient 255 in every subtraction call
    identically corrupting both output paths

SUB-T1 is therefore mandatory whenever SUB-T2 is evaluated.

### Initial origin classification

    Independently derived relational composition theorem.

    Apparently absent as an explicit supplied source contract.

    Mathematically implied by canonical modular normalization.

    Dedicated prior CBMC-proof status presently unknown.

## 7. Frame and input-preservation obligations

The harness must create source inputs and saved snapshots:

    A0
    B0
    saved_A0
    saved_B0

Working objects:

    L
    LB
    RA
    RB

The harness must prove:

    A0 remains equal to saved_A0
    B0 remains equal to saved_B0
    LB remains equal to saved_B0

It must also use phase-boundary snapshots to prove:

    left-path execution does not modify right-path objects
    right-path execution does not modify completed left-path objects
    reduction of RA does not modify RB
    reduction of RB does not modify RA
    only the intended mutable production argument changes per call

These are additional relational frame checks and do not replace the
production contracts.

## 8. Verification modes

### MODE-A: exact production-body bounded execution

MODE-A is mandatory primary evidence.

Requirements:

    real mlk_poly_sub body retained
    real mlk_poly_reduce body retained
    real scalar reduction bodies retained
    portable production C selected
    native arithmetic backends disabled
    no replacement of mlk_poly_sub by its function contract
    no replacement of mlk_poly_reduce by its function contract
    no application of source loop contracts
    every relevant loop explicitly unwound
    unwinding assertions enabled
    exact entry function recorded
    exact loop identifiers recorded
    exact unwindset recorded

Only MODE-A may support the statement:

    complete production loops were explicitly unwound and checked

### MODE-B: source-annotation-assisted verification

MODE-B is complementary evidence.

Requirements:

    production function bodies retained unless explicitly documented
    source loop contracts or invariants may be applied
    every applied annotation must be recorded
    every function contract used as an assumption must be recorded
    every checked contract must be recorded
    results labelled annotation-assisted

MODE-B must never silently replace MODE-A.

### Fallback rule

If MODE-A cannot complete because of resource limits:

    preserve the incomplete output
    record the exact failure mode
    record time and memory limits
    do not report MODE-B as MODE-A
    create a new versioned fallback record
    do not silently weaken the theorem or execution mode

## 9. Machine-model and C-semantics binding

Before theorem assertions, the harness must verify or record:

    CHAR_BIT
    width of short
    width of int
    width of int16_t
    width of int32_t
    width of pointers
    CBMC architecture
    object-bits setting
    endianness administratively, where available

Required width checks include equivalents of:

    sizeof(int16_t) * CHAR_BIT == 16
    sizeof(int32_t) * CHAR_BIT == 32
    sizeof(int) * CHAR_BIT == 32
    sizeof(void *) * CHAR_BIT == 64

The model must also verify that signed right shift of negative int32_t
values is sign-preserving, matching the documented implementation
assumption used by mlk_barrett_reduce.

Equivalent assertions must include:

    ((int32_t)-1 >> 1) == (int32_t)-1
    ((int32_t)-3 >> 1) == (int32_t)-2

If these model-binding assertions fail, the functional theorem is not
established under that machine model.

Endianness is not a mathematical precondition of SUB-T1 or SUB-T2
because the theorem does not reinterpret coefficient objects as byte
arrays. It is retained as environmental metadata only.

## 10. Reachability and satisfiability campaign

Universal proof success is insufficient by itself.

A separate coverage or satisfiability harness must demonstrate
reachable executions containing:

    at least one positive difference
    at least one negative difference
    at least one zero difference
    at least one non-canonical positive input coefficient
    at least one non-canonical negative input coefficient
    an INT16_MIN valid difference
    an INT16_MAX valid difference
    coefficient index 0 execution
    coefficient index 255 execution

Coverage goals must use explicit CBMC coverage predicates or separate
SAT witness checks.

The assumptions must also be shown satisfiable independently of the
main postconditions.

## 11. Exact boundary controls

### Valid lower boundary

    A = INT16_MIN
    B = 0
    mathematical difference = INT16_MIN

Expected:

    accepted valid-domain execution

### Valid upper boundary

    A = INT16_MAX
    B = 0
    mathematical difference = INT16_MAX

Expected:

    accepted valid-domain execution

### Invalid lower boundary

    A = INT16_MIN
    B = 1
    mathematical difference = INT16_MIN - 1

Expected:

    rejected by representability condition
    or exposed by the designated negative-control harness

### Invalid upper boundary

    A = INT16_MAX
    B = -1
    mathematical difference = INT16_MAX + 1

Expected:

    rejected by representability condition
    or exposed by the designated negative-control harness

Invalid-boundary controls are not normal theorem executions.

## 12. Required CBMC execution configuration

Before proof execution, a separate execution manifest must freeze the
complete effective command lines.

It must explicitly record whether each of the following is enabled:

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

The manifest must also record:

    CBMC version
    selected solver or internal decision procedure
    solver version where applicable
    SAT or SMT backend
    architecture
    object-bits
    entry function
    unwind value
    unwindset values
    loop identifiers
    preprocessing compiler
    include paths
    preprocessor definitions
    selected parameter set
    native-backend macros
    function bodies retained
    function bodies removed
    contracts used as assumptions
    contracts checked
    loop contracts enabled or disabled
    simplification or slicing options
    wall-clock limit
    memory limit

No safety property may be silently disabled.

--conversion-check is mandatory because the subtraction expression is
evaluated after integer promotion and converted back to int16_t.

## 13. Frozen mutant expectation matrix

| Mutant | SUB-T1 expected | SUB-T2 expected |
|---|---|---|
| Replace subtraction with addition everywhere | Fail | May pass |
| Skip coefficient 255 everywhere | Fail | May pass |
| Compare semantic oracle against canonical result plus one | Fail | Not applicable |
| Remove final canonical reduction | Fail or range failure | Usually fail; input-dependent |
| Normalize only one right-path operand | Not necessarily applicable | Fail |
| Corrupt only the left-path output | Fail | Fail |
| Corrupt both production paths identically | Fail | May pass |
| Wrong operation at only one subtraction call | Fail | Fail |
| Wrong loop bound at only one path | Fail | Fail |
| Remove direct-difference representability assumption | Counterexample or precondition violation | Counterexample or precondition violation |

A mutant that is marked "May pass" is not evidence that the mutant is
correct. It demonstrates the known common-mode limitation of SUB-T2.

Mutation results must be compared with this matrix after execution.
Unexpected mutant behaviour requires investigation.

## 14. Cross-parameter replication

The campaign must compile and execute for:

    ML-KEM-512
    ML-KEM-768
    ML-KEM-1024

These runs are interpreted as:

    configuration reproducibility evidence
    namespace and build integration evidence
    compile-time parameter regression evidence

They are not interpreted as three distinct mathematical theorems,
because this property uses the same polynomial length and modulus in
all three parameter sets.

## 15. Novelty and contribution wording

### Prohibited before final provenance audit

    first proof in the world
    no person has ever proved this
    completely novel mathematical theorem
    globally unique proof
    no equivalent proof exists

### Permitted before final provenance audit

    independently derived relational theorem candidate
    independently authored CBMC artefact candidate
    apparently absent from the supplied source contracts
    stronger than the explicit local poly_sub contract
    dedicated prior CBMC-proof status unknown

### Permitted only after documented post-freeze audit

    To the best of the documented repository, public-code, and
    literature search conducted on the recorded date, no equivalent
    prior CBMC proof was identified.

### Intended contribution framing

    A newly authored and experimentally evaluated CBMC relational
    verification artefact for production ML-KEM polynomial arithmetic.

The contribution is not the discovery of a new algebraic identity.
The contribution may lie in the independently authored verification
artefact, broader functional property, production-body evidence,
experimental controls, failure analysis, and documented provenance.

## 16. Material that must remain unopened until harness freeze

Do not inspect:

    proofs/cbmc/poly_sub/poly_sub_harness.c
    dedicated poly_sub proof output files
    dedicated poly_sub proof JSON files
    dedicated poly_sub counterexamples
    forks containing copied versions of that harness

The already exposed Makefile must not be reopened merely to copy its
configuration into the new campaign.

## 17. Freeze and amendment rule

This document must not be silently modified after its SHA-256 hash is
generated.

Any later correction must create:

    a new versioned preregistration file
    a reason-for-change record
    a new timestamp
    a new SHA-256 hash

The original frozen version must be retained.

The next permissible stage after this freeze is:

    independent SUB-T1 and SUB-T2 harness design

The next impermissible stage is:

    inspection of the existing poly_sub harness before our harness
    and execution configuration have been frozen.
