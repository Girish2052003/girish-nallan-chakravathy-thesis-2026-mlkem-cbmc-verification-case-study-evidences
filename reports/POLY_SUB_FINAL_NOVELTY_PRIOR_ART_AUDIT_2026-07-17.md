# Final Novelty and Prior-Art Audit:
# mlkem-native `mlk_poly_sub` CBMC Case Study

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Audit date:** 17 July 2026  
**Frozen repository:** `pq-code-package/mlkem-native`  
**Frozen commit:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Primary tool:** CBMC 6.9.0  
**Parameter set evaluated:** ML-KEM-768

## 1. Audit question

This audit asks whether a prior artefact equivalent to the thesis campaign was
identified in the frozen repository, indexed public code, or relevant
formal-verification literature.

The campaign contains two principal functional properties:

### SUB-T1 — semantic composition

For every coefficient whose direct signed difference is representable as
`int16_t`, production

```c
mlk_poly_sub(&L, &LB);
mlk_poly_reduce(&L);
```

returns the unsigned-canonical representative in `[0, 3329)` equal to an
independent modular oracle.

### SUB-T2 — relational normalization compatibility

For the same admissible inputs:

```text
N(A - B) = N(N(A) - N(B))
```

where every `N`, subtraction, and reduction on both paths is implemented by
the retained production C bodies.

The campaign additionally includes explicit unwinding assertions, frame
properties, non-vacuity witnesses, signed-boundary controls, and three
preregistered mutation tests.

## 2. Equivalence criterion

A prior artefact was treated as **equivalent** only if it matched the
substantive verification contribution rather than merely sharing individual
mathematical facts.

An equivalent artefact would need to establish, in CBMC or an effectively
identical bounded C-verification setting, at least one of the following
against the relevant production C:

1. body-level `poly_sub -> poly_reduce` semantic agreement with an independent
   canonical modular oracle over the stated input domain; or
2. the two-path relational normalization theorem
   `N(A-B) = N(N(A)-N(B))`.

A source contract proving exact subtraction alone, a range contract for
reduction alone, ordinary tests, a production call sequence, or a proof of a
different implementation in another language was classified as related but
not equivalent.

## 3. Frozen-repository audit

The frozen repository's dedicated `poly_sub` CBMC harness is:

```c
#include "poly.h"

void harness(void)
{
  mlk_poly *r, *b;
  mlk_poly_sub(r, b);
}
```

Its SHA-256 is:

```text
12d6a569b8a0bc6a4fc9340f1378f28e11c94beb43730b291161d6a24f8f67d1
```

The accompanying Makefile has SHA-256:

```text
d576e9ca8f1c952e79ae0b21d93b768a9d0d14b38584e76e953a800253afece8
```

and configures:

```text
CHECK_FUNCTION_CONTRACTS=mlk_poly_sub
APPLY_LOOP_CONTRACTS=on
```

It does not call `mlk_poly_reduce`, construct an independent modular oracle,
compare two normalization paths, check the thesis frame relations, or execute
the thesis mutation and coverage controls.

The repository source contract for `mlk_poly_sub` requires non-aliasing and
representable signed differences, and ensures exact coefficient-wise
subtraction. That contract is a genuine pre-existing theorem and is treated
as the SUB-T0 baseline rather than as a thesis novelty claim.

The repository contains the production decryption sequence
`mlk_poly_sub` followed by `mlk_poly_reduce`; the existence of that call
sequence is implementation context, not an existing proof of SUB-T1 or
SUB-T2.

**Frozen-repository classification:** no equivalent artefact identified.

## 4. Current mlkem-native verification scope

The public mlkem-native project description states that its C source is
verified with CBMC for memory safety and type safety, using function contracts
and loop invariants. It separately describes functional-correctness proofs for
optimized assembly using HOL Light.

This public scope is consistent with the frozen-repository inspection: it
does not document the exact body-level C semantic-composition or relational
normalization artefacts developed in this campaign.

**Current-upstream classification:** related verification infrastructure, but
no equivalent publicly documented artefact identified.

## 5. Indexed public-code search

Searches were performed for exact function names, the subtraction/reduction
composition, CBMC harnesses, the semantic oracle shape, and the relational
identity. Searches covered indexed GitHub results, general web code indexes,
mlkem-native derivatives visible through OSS-Fuzz/liboqs, CBMC application
pages, and ML-KEM/Kyber repositories returned by the search engine.

The searches found:

- copies and integrations of the production `poly_sub` and `poly_reduce`
  bodies;
- the production decryption call sequence;
- mlkem-native's ordinary contract-based CBMC proof structure;
- unrelated CBMC uses and verification challenge repositories;
- testing, fuzzing, or KAT-based ML-KEM implementations.

They did not reveal an indexed public CBMC harness proving the exact SUB-T1
composition or SUB-T2 relation.

**Public-code classification:** no equivalent indexed artefact identified by
the documented search.

## 6. Related formal-verification literature

### 6.1 Jasmin and EasyCrypt implementation correctness

Almeida et al. presented high-assurance Jasmin implementations of Kyber with
machine-checked functional-correctness proofs against an EasyCrypt
specification. This is stronger and broader at the algorithm/implementation
level than the local thesis properties, but it concerns different
implementations and a different proof stack.

Classification: **highly relevant prior functional-correctness work, not an
equivalent CBMC artefact for the frozen mlkem-native C bodies**.

### 6.2 Machine-checked ML-KEM correctness and security

The Crypto 2024 EasyCrypt work proves correctness and IND-CCA security of
ML-KEM and includes Jasmin implementations functionally equivalent to the
formal specification and proved constant-time.

Classification: **major prior ML-KEM verification; not equivalent in target
code, theorem granularity, or verification framework**.

### 6.3 Other verified implementations

The public rust-libcrux project reports formal verification of portable and
optimized ML-KEM components using hax and F*, including field and polynomial
arithmetic. This demonstrates that polynomial arithmetic correctness is not a
new mathematical or general verification topic.

Classification: **related verified implementation, not the same C code or
CBMC artefact**.

The LibMLKEM project presents an independent formal reference implementation.
Its documented SPARK work targets static safety properties and uses dynamic
known-answer tests for functional correctness; CBMC for C is described as a
possible future direction.

Classification: **related verification challenge/reference project, not an
equivalent completed artefact**.

### 6.4 mlkem-native assembly proofs

mlkem-native's optimized assembly is subject to functional-correctness proofs
using HOL Light. These results are significant prior work but target assembly
routines and their specifications, not the portable C
`mlk_poly_sub -> mlk_poly_reduce` body-level CBMC composition or SUB-T2
relation.

Classification: **related project-level formal verification, not equivalent**.

## 7. Novelty classification

### Not novel

The following must not be claimed as novel:

- coefficient-wise modular subtraction;
- canonical reduction modulo 3329;
- the algebraic identity `N(A-B) = N(N(A)-N(B))`;
- formal verification of Kyber or ML-KEM generally;
- functional verification of polynomial arithmetic generally;
- the use of CBMC for mlkem-native safety and type-safety proofs.

### Supported contribution

The supported contribution is the independently authored and experimentally
evaluated verification artefact and campaign design:

- frozen production-body CBMC execution rather than abstraction by the target
  function contracts;
- semantic composition of subtraction and unsigned-canonical reduction
  against an independent oracle;
- a separate relational normalization theorem;
- explicit frame and machine-model assertions;
- complete loop unwinding with unwinding assertions;
- non-vacuity coverage witnesses;
- signed-boundary acceptance and rejection controls;
- mutation sensitivity with three of three preregistered mutants killed;
- preservation of failures, corrected environment modelling, and provenance.

## 8. Final audit verdict

**No equivalent body-level CBMC semantic-composition or relational
normalization artefact was identified in:**

1. the dedicated `mlk_poly_sub` proof at frozen commit
   `d9613cf60de3132d32475c102d8c2781d84feb34`;
2. the documented current mlkem-native verification scope;
3. the indexed public-code searches recorded on 17 July 2026; or
4. the reviewed Kyber/ML-KEM formal-verification literature.

This is a negative search result, not proof that no equivalent artefact exists
anywhere.

## 9. Permitted wording

> To the best of the documented repository, indexed public-code, and
> literature search conducted on 17 July 2026, no equivalent prior
> body-level CBMC proof was identified for either (i) agreement between
> production mlkem-native polynomial subtraction followed by unsigned
> canonical reduction and an independent modular oracle, or (ii) the
> relational normalization property
> `N(A-B) = N(N(A)-N(B))`. Related and broader functional-correctness proofs
> of Kyber and ML-KEM exist in Jasmin/EasyCrypt, F*/hax, HOL Light, and other
> verification settings. The contribution claimed here is therefore a newly
> authored and experimentally evaluated CBMC verification artefact and
> evidence campaign for the frozen mlkem-native C implementation, not a new
> mathematical theorem or a world-first proof of ML-KEM arithmetic.

## 10. Prohibited wording

Do not write:

- “the first proof in the world”;
- “no one has proved this before”;
- “a completely new mathematical theorem”;
- “the first formal verification of Kyber/ML-KEM subtraction”;
- “no equivalent proof exists”;
- “the complete mlkem-native implementation is functionally correct.”

## 11. Search limitations

The audit cannot establish exhaustive global absence. Limitations include:

- private and unindexed repositories;
- search-engine indexing gaps;
- inaccessible or unpublished theses and reports;
- renamed functions or mathematically equivalent properties expressed using
  different terminology;
- future publications and repository changes after 17 July 2026;
- public code that is present only in forks not indexed by the search engine.

The audit verdict must therefore remain date-stamped and qualified.

## 12. Reviewed sources

1. `pq-code-package/mlkem-native`, frozen commit
   `d9613cf60de3132d32475c102d8c2781d84feb34`, including
   `proofs/cbmc/poly_sub/`.
2. `pq-code-package/mlkem-native`, current public project description,
   accessed 17 July 2026.
3. Almeida, J.B. et al. (2023), “Formally verifying Kyber Episode IV:
   Implementation correctness”, *IACR Transactions on Cryptographic Hardware
   and Embedded Systems*, 2023(3), pp. 164–193.
   DOI: `10.46586/tches.v2023.i3.164-193`.
4. Almeida, J.B. et al. (2024), “Formally Verifying Kyber: Episode V:
   Machine-checked IND-CCA security and correctness of ML-KEM in EasyCrypt”,
   Crypto 2024 artifact and associated paper.
5. `pq-code-package/rust-libcrux`, verification-status documentation,
   accessed 17 July 2026.
6. `awslabs/LibMLKEM`, project documentation, accessed 17 July 2026.
7. Kroening, D., Schrammel, P. and Tautschnig, M. (2023), “CBMC: The C
   Bounded Model Checker”, arXiv:2302.02384.
