# SUB-00C Independent Harness Architecture

## 1. Parent evidence

Repository:

    mlkem-native

Frozen commit:

    d9613cf60de3132d32475c102d8c2781d84feb34

SUB-00A production-input packet SHA-256:

    e557c98ff5d3e3735d9f9f59c67a030e87ea0f4898b92d120856321a74ba7f45

SUB-00B corrected preregistration SHA-256:

    0a5c9f8faccd2b28b1ed3c85ca7a9fe1a66044518df2e05c35a86a28d4ed4e79

Target production functions:

    mlk_poly_sub
    mlk_poly_reduce

Existing repository poly_sub harness status:

    Not inspected.

Existing repository poly_sub Makefile status:

    Previously exposed and transparently disclosed in SUB-00B.

## 2. Purpose of this architecture freeze

This document freezes the structure of the independently authored
harness family before any harness source file is generated.

It does not freeze:

    exact CBMC loop identifiers
    exact unwindset values
    final preprocessing command
    final solver selection
    final object-bits value
    final resource limits

Those items require inspection of the independently generated GOTO
model and will be frozen later in the SUB-00D execution manifest,
before theorem execution.

No CBMC proof is executed during SUB-00C.

## 3. Separation principle

SUB-T1 and SUB-T2 must use separate harnesses.

Reasons:

    SUB-T1 is the independent semantic oracle.
    SUB-T2 is the relational normalization theorem.
    SUB-T2 may miss common-mode implementation defects.
    Failure or resource exhaustion in SUB-T2 must not suppress SUB-T1.
    The smaller SUB-T1 proof should remain independently reviewable.
    Different counterexamples must be attributable to the correct theorem.

A successful SUB-T2 result is not reportable as functional subtraction
correctness unless the corresponding SUB-T1 result also succeeds for:

    the same frozen repository commit
    the same parameter-set build
    the same machine model
    the same relevant safety configuration
    the same production-C selection

## 4. Harness source-file plan

The initial positive and control campaign will contain:

    sub_t1_semantic_harness.c
    sub_t2_relational_harness.c
    sub_cov_reachability_harness.c
    sub_boundary_valid_extremes_harness.c
    sub_boundary_invalid_lower_harness.c
    sub_boundary_invalid_upper_harness.c

Mutation harnesses will be generated in a later versioned stage after
the positive harnesses and execution configuration are frozen.

No existing repository harness file will be copied, included, patched,
renamed, transformed, or used as a template.

No existing proof Makefile will be copied or used as the new runner.

## 5. Custom-code independence rule

Each co-primary harness must be self-contained apart from:

    standard C headers
    production mlkem-native headers
    separately compiled production mlkem-native C source

SUB-T1 and SUB-T2 must not share a custom theorem-logic helper that
could introduce a common-mode specification error.

In particular, they must not share custom code implementing:

    the semantic modular oracle
    relational equality
    theorem assumptions
    theorem postconditions

Small duplicated model-binding assertions are preferable to a shared
custom theorem header.

The production source itself remains common because the purpose is to
verify that production implementation.

## 6. Frozen independent constants

Every theorem and applicable control harness must define independent
constants equivalent to:

    FIPS_N = 256
    FIPS_Q = 3329

The harness must assert:

    MLKEM_N == FIPS_N
    MLKEM_Q == FIPS_Q

The semantic oracle must use FIPS_Q rather than deriving its modulus
only from MLKEM_Q.

The assertion labels must clearly distinguish:

    parameter binding
    machine-model binding
    semantic theorem
    relational theorem
    frame property
    boundary control
    reachability evidence

## 7. Input construction

SUB-T1 and SUB-T2 will each create independent nondeterministic
source polynomials:

    A0
    B0

Immediately after nondeterministic initialization, each harness will
create immutable logical snapshots:

    saved_A0
    saved_B0

Working objects must be created only after those snapshots:

    L
    LB
    RA
    RB

The concrete assignments are conceptually:

    saved_A0 = A0
    saved_B0 = B0

    L  = A0
    LB = B0
    RA = A0
    RB = B0

SUB-T1 needs only:

    A0
    B0
    saved_A0
    saved_B0
    L
    LB

SUB-T2 needs the complete object set.

All source and working objects must be separate C objects.

No pointer aliasing between working paths may be deliberately
introduced in the positive theorem harnesses.

## 8. Frozen representability assumption

For every coefficient i, both co-primary harnesses may assume only:

    INT16_MIN <=
        (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i]

and:

        (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i]
        <= INT16_MAX

The subtraction must be evaluated in int32_t when constructing this
assumption.

The harnesses must not assume that either input is:

    canonical
    non-negative
    bounded by q
    already normalized
    equal modulo q
    generated by a particular ML-KEM sampler

No output property may appear inside an assumption.

## 9. SUB-T1 semantic harness architecture

File:

    sub_t1_semantic_harness.c

Production-call count:

    one mlk_poly_sub call
    one mlk_poly_reduce call

Conceptual execution:

    initialize A0 and B0 nondeterministically
    save A0 and B0
    apply only the direct-difference representability assumptions
    copy A0 to L
    copy B0 to LB

    mlk_poly_sub(&L, &LB)
    mlk_poly_reduce(&L)

For every coefficient i, independently calculate:

    d =
        (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i]

    shifted =
        (uint32_t)(d + 10 * FIPS_Q)

    expected =
        shifted % (uint32_t)FIPS_Q

Required semantic assertions:

    0 <= L.coeffs[i]
    L.coeffs[i] < FIPS_Q
    (uint32_t)L.coeffs[i] == expected

The oracle must not call:

    mlk_poly_sub
    mlk_poly_reduce
    mlk_barrett_reduce
    mlk_scalar_signed_to_unsigned_q
    any repository modular-reduction helper

The oracle must not use negative signed division or remainder.

## 10. SUB-T1 frame architecture

Before the subtraction call, save:

    LB_before_sub

After subtraction, prove:

    LB == LB_before_sub
    A0 == saved_A0
    B0 == saved_B0

Before reduction, save:

    LB_before_reduce

After reduction, prove:

    LB == LB_before_reduce
    A0 == saved_A0
    B0 == saved_B0

At final exit, prove:

    LB == saved_B0
    A0 == saved_A0
    B0 == saved_B0

Frame comparisons must be coefficient-wise.

Raw memcmp over the full structure must not be the sole frame oracle,
because structure padding should not enter the theorem.

## 11. SUB-T2 relational harness architecture

File:

    sub_t2_relational_harness.c

Production-call count:

    two mlk_poly_sub calls
    four mlk_poly_reduce calls

Left path:

    L  = A0
    LB = B0

    mlk_poly_sub(&L, &LB)
    mlk_poly_reduce(&L)

Right path:

    RA = A0
    RB = B0

    mlk_poly_reduce(&RA)
    mlk_poly_reduce(&RB)
    mlk_poly_sub(&RA, &RB)
    mlk_poly_reduce(&RA)

For every coefficient i, prove:

    L.coeffs[i] == RA.coeffs[i]

    0 <= L.coeffs[i]
    L.coeffs[i] < FIPS_Q

    0 <= RA.coeffs[i]
    RA.coeffs[i] < FIPS_Q

SUB-T2 must not replace its production operations with a custom
normalization implementation.

SUB-T2 does not replace SUB-T1 and does not independently establish
the meaning of subtraction.

## 12. SUB-T2 phase-boundary frame architecture

Before executing the left path, save:

    RA_before_left
    RB_before_left

After each left-path production call, prove:

    RA == RA_before_left
    RB == RB_before_left

After completing the left path, save:

    completed_L
    completed_LB

During every right-path phase, prove:

    L == completed_L
    LB == completed_LB

Before reducing RA, save RB and prove after the call:

    RB is unchanged

Before reducing RB, save RA and prove after the call:

    RA is unchanged

Before subtracting RB from RA, save RB and prove after the call:

    RB is unchanged

Before the final reduction of RA, save RB and prove after the call:

    RB is unchanged

At final exit, prove:

    A0 == saved_A0
    B0 == saved_B0
    LB == saved_B0
    L == completed_L
    RB is unchanged by operations whose mutable argument is RA

All comparisons must be coefficient-wise.

## 13. Machine-model binding architecture

Each co-primary harness must contain assertion equivalents for:

    CHAR_BIT == 8
    sizeof(short) * CHAR_BIT == 16
    sizeof(int) * CHAR_BIT == 32
    sizeof(int16_t) * CHAR_BIT == 16
    sizeof(int32_t) * CHAR_BIT == 32
    sizeof(void *) * CHAR_BIT == 64

Each must also assert arithmetic signed-right-shift semantics
equivalent to:

    ((int32_t)-1 >> 1) == (int32_t)-1
    ((int32_t)-3 >> 1) == (int32_t)-2

These are checked model bindings, not assumptions about theorem
outputs.

If a model-binding assertion fails, the functional theorem result is
invalid for that machine configuration.

Endianness will be recorded in the execution manifest but will not be
used as a theorem assumption.

## 14. Harness-loop architecture

Harness loops may be used for:

    nondeterministic coefficient initialization
    representability assumptions
    semantic oracle assertions
    relational equality assertions
    frame comparisons
    reachability-predicate construction

Harness loops must be separately identifiable from production loops
in the GOTO model.

The execution manifest must record unwind bounds for both:

    production loops
    harness loops

Successful unwinding assertions are mandatory in MODE-A.

No conclusion may be based on an incompletely unwound assertion loop.

## 15. MODE-A architecture

MODE-A is the primary execution mode.

It must:

    retain the real mlk_poly_sub body
    retain the real mlk_poly_reduce body
    retain the scalar reduction implementation reached by poly_reduce
    disable native arithmetic paths
    avoid function-contract replacement for the target functions
    avoid source loop-contract application
    explicitly unwind all reached loops
    enable unwinding assertions
    enable the frozen safety-property classes
    preserve the independently authored harness body

Before MODE-A proof execution, the GOTO model will be inspected only
for:

    function presence
    call graph
    loop identifiers
    architecture
    symbols and configuration

That inspection must not use the existing repository poly_sub harness.

## 16. MODE-B architecture

MODE-B is complementary annotation-assisted evidence.

It may apply existing source loop contracts, provided the execution
manifest records every such choice.

MODE-B must use the same theorem assertions as the corresponding
MODE-A harness.

MODE-B output must be labelled:

    source-annotation-assisted verification

MODE-B may not be presented as explicit complete loop unwinding.

## 17. Reachability harness architecture

File:

    sub_cov_reachability_harness.c

Purpose:

    demonstrate satisfiable theorem assumptions
    demonstrate reachable input categories
    avoid vacuous interpretation of universal success

The harness will:

    generate arbitrary A0 and B0
    apply the valid direct-difference representability assumptions
    calculate category predicates
    call the production sub-then-reduce path
    place independent __CPROVER_cover goals after the production calls

Required independently evaluated cover goals:

    a positive direct difference exists
    a negative direct difference exists
    a zero direct difference exists
    a non-canonical positive source coefficient exists
    a non-canonical negative source coefficient exists
    an INT16_MIN direct difference exists
    an INT16_MAX direct difference exists
    the valid production path reaches its post-call location

Each coverage goal is evaluated independently.

The coverage campaign is evidence of reachability, not a substitute
for theorem assertions.

## 18. Valid-extremes harness architecture

File:

    sub_boundary_valid_extremes_harness.c

All coefficients begin as zero.

At coefficient 0:

    A = INT16_MIN
    B = 0
    direct difference = INT16_MIN
    expected canonical result = 522

At coefficient 255:

    A = INT16_MAX
    B = 0
    direct difference = INT16_MAX
    expected canonical result = 2806

Execute production:

    mlk_poly_sub
    mlk_poly_reduce

Prove the exact expected values at coefficients 0 and 255.

Also prove that all originally zero coefficients remain canonical zero.

This harness simultaneously demonstrates:

    valid lower representability boundary
    valid upper representability boundary
    execution sensitivity at coefficient 0
    execution sensitivity at coefficient 255

## 19. Invalid-boundary control architecture

File:

    sub_boundary_invalid_lower_harness.c

Concrete critical coefficient:

    A = INT16_MIN
    B = 1

Mathematical difference:

    INT16_MIN - 1

No representability assumption will hide the invalid input.

Expected evidence:

    conversion or related designated safety-property failure
    or explicit failure of a checked target precondition

File:

    sub_boundary_invalid_upper_harness.c

Concrete critical coefficient:

    A = INT16_MAX
    B = -1

Mathematical difference:

    INT16_MAX + 1

No representability assumption will hide the invalid input.

Expected evidence:

    conversion or related designated safety-property failure
    or explicit failure of a checked target precondition

The exact expected CBMC property identifiers will be recorded only
after independent model construction.

These negative controls are expected-failure runs and must never be
included in the positive-success total.

## 20. Initial mutation mapping

After positive harness freeze, mutation testing will map at least:

    subtraction-to-addition mutant
        semantic detector: SUB-T1
        relational detector: may pass SUB-T2

    shared coefficient-255 skip mutant
        semantic detector: SUB-T1
        relational detector: may pass SUB-T2

    left-path-only corruption
        semantic detector: SUB-T1
        relational detector: SUB-T2

    right-path normalization omission
        primary detector: SUB-T2

    semantic-oracle plus-one mutant
        detector: SUB-T1 self-test

A mutant may not modify the frozen production repository in place.

Mutants must be created as separate versioned experiment artefacts.

## 21. Compilation and namespace boundary

Harnesses will be compiled against the source-only clean-room export.

The later execution manifest must explicitly freeze:

    MLK_CONFIG_PARAMETER_SET
    MLK_CONFIG_NAMESPACE_PREFIX
    MLK_CONFIG_NO_ASM or equivalent portable-C selection
    multilevel/shared configuration
    include paths
    production source files
    harness source file
    entry function

No compile definition will be guessed silently.

The parameter-set configurations will be generated independently for:

    512
    768
    1024

## 22. Review gates before execution

Before running CBMC, the generated harnesses must pass:

    source review against this architecture
    assumption audit
    assertion audit
    oracle-independence audit
    frame-check audit
    object-separation audit
    production-body call audit
    no-existing-harness-content audit
    C syntax/type review
    source-file SHA-256 freeze
    execution-manifest freeze

A compile or model-construction command may be used to discover syntax,
symbols and loop identifiers.

A theorem proof must not be executed before the harnesses and
execution manifest are frozen.

## 23. Material remaining prohibited

Until the independently authored harnesses and execution manifest are
frozen, do not inspect:

    proofs/cbmc/poly_sub/poly_sub_harness.c
    dedicated existing poly_sub proof results
    dedicated existing poly_sub JSON output
    dedicated existing counterexamples
    copied harnesses in public forks

## 24. Amendment rule

This architecture document must not be silently modified after hashing.

Any correction requires:

    a versioned replacement document
    a reason-for-change record
    retention of this original document
    a new SHA-256 hash

## 25. Next stage

After SUB-00C integrity verification, the next permitted stage is:

    independently author the six planned harness source files

The harnesses will then be reviewed and hashed before proof execution.

The existing repository poly_sub harness must remain unopened.

Architecture freeze time UTC:

    2026-07-17T01:52:15Z
