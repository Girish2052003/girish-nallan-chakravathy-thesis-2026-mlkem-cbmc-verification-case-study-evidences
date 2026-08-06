# PA-09: Strict Novelty, Distinctness, and Provenance Audit for `mlk_poly_add`

## Complete A-to-Z Technical Record of the Post-Freeze Comparison with the Original `mlkem-native` CBMC Artefacts

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Target project:** `pq-code-package/mlkem-native`  
**Target function:** `mlk_poly_add`  
**Frozen repository commit:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Production `poly.c` SHA-256:** `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722`  
**Campaign item:** PA-09  
**Audit type:** Post-freeze textual, structural, semantic, and provenance audit  
**Authored source artefacts audited:** 24  
**Mechanical comparisons:** 192  
**Exact binary duplicates:** 0  
**Exact normalized-text duplicates:** 0  
**High mechanical-similarity pairs:** 0  
**Final semantic status:** `PA09_QUALIFIED_PROVENANCE_CONCLUSION_ESTABLISHED`  
**Document type:** Self-contained professor-facing technical record

---

## 1. Executive Summary

PA-09 compared the independently authored PA-01 through PA-08 `mlk_poly_add` artefacts against
the original target-related CBMC, contract, implementation, caller, documentation, and proof
artefacts in the frozen `mlkem-native` repository revision.

The audit was deliberately performed after the PA-01 through PA-08 source artefacts had been
frozen by SHA-256. The provenance collector verified 24 authored artefacts before opening and
collecting the original repository proof directory and related source material.

The deterministic evidence bundle established:

```text
required authored artefacts hash-verified = 24
files in original proofs/cbmc/poly_add    = 2
frozen repository artefacts collected    = 15
mechanical comparisons                    = 192
exact binary duplicates                   = 0
exact normalized-text duplicates          = 0
high mechanical-similarity pairs          = 0
production source modified                = no
```

The original repository's `poly_add` proof consists of:

```text
proofs/cbmc/poly_add/Makefile
proofs/cbmc/poly_add/poly_add_harness.c
```

The original harness is intentionally minimal:

```c
#include "poly.h"

void harness(void)
{
  mlk_poly *r, *b;
  mlk_poly_add(r, b);
}
```

It contains no explicit harness-level assumptions, assertions, snapshots, relational calls,
negative controls, boundary witnesses, mutation checks, or caller decomposition.

The proof meaning is instead supplied by the production source contract and loop invariants. The
repository Makefile configures CBMC to check the `mlk_poly_add` contract, apply loop contracts, and
use dynamic frames.

The production source contract already specifies the core theorem:

```text
r and b are valid non-overlapping polynomial objects
every coefficient-wise sum fits in int16_t
the output coefficient equals the old r coefficient plus b
only r may be modified
```

Therefore, the central exact-addition theorem and its representability and disjointness
preconditions are **not new semantic discoveries** of this campaign.

The PA artefacts are nevertheless demonstrably not copies of the original boilerplate harness.
No exact or normalized-text duplicate was found, no comparison reached the audit's high-similarity
category, and every reported authored/repository pair was classified as low mechanical overlap.

The final semantic conclusion is qualified:

> PA-01 through PA-08 are independently authored experimental artefacts rather than textual
> copies of the original `mlkem-native` `poly_add` harness. Their core exact-addition,
> representability, and disjointness obligations overlap intentionally with the existing
> production contract. Several caller and cross-parameter objectives also overlap with the
> repository's existing modular proof infrastructure. The campaign makes substantial independent
> extensions through explicit canonical-domain relational properties, negative controls,
> out-of-contract alias diagnostics, standalone caller decompositions, direct-body checks,
> hash-frozen experiment matrices, mutation sensitivity, and anti-vacuity and exact-boundary
> controls.

The defensible provenance classification is:

```text
independently authored
not textually copied
original-harness-blind during the initial clean-room construction
source-contract-informed
semantically overlapping where dictated by the target contract
substantially extended through independent properties and campaign architecture
not absolutely unique
not fully formal-artefact-blind
```

---

## 2. Purpose of PA-09

The purpose of PA-09 was not to prove `mlk_poly_add` again.

PA-01 through PA-08 supplied the functional, negative-control, caller, replication, mutation, and
anti-vacuity evidence.

PA-09 answers a different question:

> What parts of the campaign reproduce an existing repository theorem, what parts independently
> extend it, and what claim about authorship, novelty, and distinctness can be defended to a
> professor or examiner?

This question requires four separate analyses:

1. artefact provenance;
2. textual similarity;
3. semantic overlap;
4. experimental-architecture distinctness.

A single similarity percentage cannot answer all four.

---

## 3. Audit Method

The PA-09 audit used the following sequence.

### 3.1 Freeze the authored artefacts

All required PA-01 through PA-08 harnesses and runners were verified against expected SHA-256
values.

The audit was terminated if any required artefact was missing or changed.

### 3.2 Freeze the production source

The audit checked:

- the exact repository commit;
- absence of tracked changes to `mlkem/src/poly.c`;
- the working-tree `poly.c` SHA-256;
- the frozen Git-commit `poly.c` SHA-256.

### 3.3 Read repository artefacts from Git

Original repository artefacts were read with:

```text
git show <frozen-commit>:<path>
```

This prevents untracked files or later working-tree edits from altering the comparison baseline.

### 3.4 Collect the target proof directory

Every file in:

```text
proofs/cbmc/poly_add
```

was collected.

### 3.5 Collect direct target references

Every tracked text file directly referencing `mlk_poly_add`, `poly_add`, or the corresponding
namespace macro was collected or catalogued.

### 3.6 Compare authored C artefacts mechanically

For each authored C artefact and repository candidate, PA-09 calculated:

- exact SHA-256 identity;
- normalized-text identity after comment and whitespace removal;
- token-sequence similarity;
- token-set Jaccard similarity;
- significant-line Jaccard similarity;
- a mechanical overlap category.

### 3.7 Perform semantic review

The final audit separately examined:

- contracts;
- assumptions;
- postconditions;
- loop invariants;
- caller proof configuration;
- parameter-set proof configuration;
- campaign-only properties;
- negative and mutation controls;
- provenance limitations.

---

## 4. Evidence Identity

The evidence bundle was generated from:

```text
repository root:
/home/girish/THESIS-2026/mlkem-native

frozen commit:
d9613cf60de3132d32475c102d8c2781d84feb34

production poly.c:
f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722
```

Production source modification status:

```text
No
```

The retained PA-09 evidence bundle identity is:

```text
SHA-256:
93eb68277d8784cd764cfa8686111e1690ee7dd338a88b210c06937a9e101de8

size:
421197 bytes
```

---

# Part I — Original Repository Proof

## 5. Original `poly_add` Proof Directory

The frozen repository contains exactly two files in the dedicated target proof directory:

```text
proofs/cbmc/poly_add/Makefile
proofs/cbmc/poly_add/poly_add_harness.c
```

This is important because the dedicated harness itself is not a large hand-written specification.

---

## 6. Original Harness

The complete original target harness is:

```c
#include "poly.h"

void harness(void)
{
  mlk_poly *r, *b;
  mlk_poly_add(r, b);
}
```

The harness contains:

```text
explicit __CPROVER assumptions  = none
explicit __CPROVER assertions   = none
pre-state snapshots             = none
relational duplicate calls      = none
negative controls               = none
boundary witnesses              = none
caller-context reconstruction   = none
mutation analysis               = none
reachability sentinels          = none
```

The pointers are intentionally left symbolic.

CBMC obtains the proof obligations from the checked function contract.

---

## 7. Original Makefile Semantics

The original Makefile configures:

```text
HARNESS_ENTRY              = harness
HARNESS_FILE               = poly_add_harness
PROOF_UID                  = mlk_poly_add
PROJECT_SOURCES            includes mlkem/src/poly.c
CHECK_FUNCTION_CONTRACTS   = mlk_poly_add
USE_FUNCTION_CONTRACTS     = empty
APPLY_LOOP_CONTRACTS       = on
USE_DYNAMIC_FRAMES         = 1
FUNCTION_NAME              = mlk_poly_add
CBMCFLAGS                   = --smt2
```

This means the repository proof checks the production function's contract directly and uses the
production loop contract.

The original proof is contract-centred and modular.

---

## 8. Repository Proof Philosophy

The repository documentation states that:

- proofs are organized by function;
- specifications are embedded in the C source as contracts and loop annotations;
- function harnesses are boilerplate and do not add to the specification.

Therefore, comparing only the original five-line harness with the PA harnesses would be
insufficient and misleading.

The correct semantic baseline is:

```text
original harness
+
source function contract
+
source loop invariant
+
proof Makefile configuration
```

---

## 9. Original Function Contract

The original declaration requires:

```text
memory_no_alias(r, sizeof(mlk_poly))
memory_no_alias(b, sizeof(mlk_poly))
```

and, for every coefficient:

```text
r[i] + b[i] <= INT16_MAX
r[i] + b[i] >= INT16_MIN
```

It ensures:

```text
r_after[i] = r_before[i] + b[i]
```

and assigns:

```text
only the memory slice of r
```

### Semantic meaning

The contract already establishes:

1. valid storage for `r`;
2. valid storage for `b`;
3. non-overlap according to the repository's dynamic-frame model;
4. exact-sum representability;
5. exact coefficient-wise addition;
6. the write footprint is restricted to `r`.

The restriction to `r` implies that the read-only object `b` is outside the permitted write
footprint.

---

## 10. Original Loop Invariant

The production loop invariant establishes:

```text
i <= MLKEM_N
```

For the unprocessed suffix:

```text
r[k] remains equal to its loop-entry value
```

For the processed prefix:

```text
r[k] equals loop-entry r[k] plus b[k]
```

The loop variant decreases with:

```text
MLKEM_N - i
```

This supplies the induction needed for the contract proof.

---

## 11. Original Proof Strength

The original proof is not merely a unit test.

Under its contracts, it provides a modular, loop-contract-based CBMC proof of the function's
specified behaviour and configured safety conditions.

This matters for the thesis interpretation:

> The repository already had a strong formal theorem for the exact valid-domain behaviour of
> `mlk_poly_add`.

The campaign cannot honestly claim to be the first proof of exact `mlk_poly_add` addition.

---

# Part II — Mechanical Distinctness

## 12. Mechanical Audit Results

The PA-09 collector performed:

```text
192 authored/repository comparisons
```

It found:

```text
exact binary duplicates          = 0
exact normalized-text duplicates = 0
high similarity pairs            = 0
```

The highest token-sequence ratio was approximately:

```text
0.207
```

The highest listed authored/original-harness sequence ratio was lower, and all listed
comparisons were classified as:

```text
low-mechanical-overlap
```

---

## 13. Meaning of Zero Exact Duplicates

The absence of exact binary and normalized-text duplicates supports the conclusion that the PA C
artefacts were not copied verbatim from the collected repository target artefacts.

It does not independently prove:

- absence of conceptual influence;
- absence of paraphrasing;
- absolute originality;
- absence of exposure to source contracts.

Those issues require semantic and process analysis.

---

## 14. Meaning of Low Similarity

Low mechanical similarity is expected because:

- the original harness is only a symbolic call;
- the PA harnesses create concrete objects;
- the PA harnesses encode explicit assumptions;
- they take pre-state snapshots;
- they execute multiple calls;
- they assert relational and boundary properties;
- they implement negative and mutation controls;
- they contain campaign-specific marker strings.

The low scores are consistent with independent implementation.

They are not the sole basis of the provenance conclusion.

---

## 15. Inevitable Shared Tokens

Some shared tokens are unavoidable:

```text
mlk_poly
mlk_poly_add
MLKEM_N
MLKEM_Q
INT16_MIN
INT16_MAX
coeffs
```

Shared arithmetic expressions are also expected because both artefact sets describe the same
small function.

This inevitable overlap must not be misclassified as copying.

---

# Part III — Semantic Overlap

## 16. Core Contract Overlap

The following PA concepts overlap directly with the original repository contract:

| Concept | Repository status | PA status | Audit classification |
|---|---|---|---|
| valid `r` object | explicit precondition | explicit object construction/checking | existing theorem re-expressed |
| valid `b` object | explicit precondition | explicit object construction/checking | existing theorem re-expressed |
| disjoint `r` and `b` | `memory_no_alias` preconditions | explicit disjointness assertions | existing precondition re-expressed |
| upper representability | explicit quantified precondition | explicit assumptions/assertions | existing precondition re-expressed |
| lower representability | explicit quantified precondition | explicit assumptions/assertions | existing precondition re-expressed |
| exact coefficient sum | explicit postcondition | explicit assertions | existing theorem independently rechecked |
| only `r` modified | explicit assigns footprint | explicit frame assertions | existing footprint made explicit |
| complete coefficient loop | source loop contract | direct full unwinding | existing behaviour checked differently |

The core mathematical theorem is therefore shared.

---

## 17. PA-01 Semantic Position

PA-01 uses the canonical domain:

```text
0 <= a[i] < q
0 <= b[i] < q
```

This is a strict subset of the original full valid signed domain.

### Overlapping PA-01 property

```text
exact coefficient-wise sum
```

This is an instance of the original exact-sum postcondition.

### PA-01 independent extensions

The collected original target proof does not explicitly specify:

- canonical output interval `0 .. 2q-2`;
- explicit modulo-`q` refinement;
- commutativity through two independent target calls;
- additive identity through a zero polynomial;
- explicit snapshots and read-only frame assertions;
- parameter-binding assertions;
- a self-contained direct-BMC evidence runner.

### PA-01 classification

```text
core theorem overlap:
yes

textual copying:
not detected

independent extension:
yes

absolute semantic novelty:
no
```

---

## 18. PA-02 Semantic Position

PA-02 uses arbitrary signed `int16_t` operands subject only to exact-sum representability.

This domain closely matches the original function contract.

### Direct overlap

PA-02's central assumptions and exact-result property are semantically equivalent to the
repository contract.

The following are not novel target theorems:

```text
sum >= INT16_MIN
sum <= INT16_MAX
result = old r + b
disjoint target operands
```

### PA-02 independent extensions

PA-02 adds:

- explicit independent input and output objects;
- an independent `int32_t` mathematical oracle;
- modulo-`q` congruence;
- canonical-residue refinement;
- commutativity;
- additive identity;
- explicit frames for multiple read-only operands;
- direct safety and conversion checking without enabling source contract mode;
- dual text and JSON evidence classification.

### PA-02 classification

```text
core contract theorem:
re-verification of existing repository specification

additional relational properties:
independent extensions

textual copying:
not detected
```

---

## 19. PA-03 Semantic Position

PA-03 removes the representability assumption and expects a counterexample.

The original repository proof assumes representability and proves only the valid domain.

PA-03 therefore answers a different question:

> Is the representability precondition necessary?

The collected original target artefacts contain no equivalent unrestricted negative-control
campaign.

### PA-03 classification

```text
source of boundary:
existing contract

negative-control experiment:
independent extension

scientific contribution:
demonstrates necessity and non-arbitrariness of the contract boundary
```

---

## 20. PA-04 Semantic Position

The repository contract explicitly requires `r` and `b` to be non-overlapping.

Repository documentation states that the destructive two-argument design was chosen to avoid
aliasing reasoning.

PA-04 intentionally sets:

```text
r == b
```

and is therefore outside the production contract.

### PA-04A

PA-04A verifies safe exact doubling only where `2*x` fits in `int16_t`.

### PA-04B

PA-04B confirms the expected unrestricted doubling counterexample.

### PA-04 classification

```text
production-contract theorem:
no

out-of-contract implementation diagnostic:
yes

equivalent original target artefact found:
no

independent extension:
strong
```

PA-04 must never be presented as permission for production callers to violate the repository
contract.

---

## 21. PA-05A and the Original `polyvec_add` Proof

The repository contains a dedicated `polyvec_add` proof configuration.

It checks:

```text
mlk_polyvec_add
```

and uses:

```text
mlk_poly_add
```

through its function contract.

Therefore, the general fact that the vector caller satisfies the target contract is already within
the repository proof infrastructure.

### Difference in PA-05A

PA-05A:

- directly executes the production `mlk_polyvec_add` body;
- directly reaches the production `mlk_poly_add` body;
- supplies explicit signed symbolic vectors;
- snapshots both vectors;
- asserts every nested exact result;
- asserts the read-only vector frame;
- records an independently controlled direct-BMC result.

### PA-05A classification

```text
caller-verification concept:
overlaps with repository proof

direct nested-body execution and explicit evidence form:
independent implementation

claim of first caller proof:
not justified
```

---

## 22. PA-05B/PA-05C and the Original `indcpa_enc` Proof

The repository contains an `indcpa_enc` proof configuration that:

- checks the `mlk_indcpa_enc` contract;
- uses contracts for producer operations;
- uses the `mlk_poly_add` contract;
- applies loop contracts.

This modular proof necessarily checks call-site contract compatibility at the actual calls.

Therefore, PA-05 must not claim that the repository lacked caller-level proof coverage.

### Independent PA-05B/PA-05C structure

The PA call-site harnesses independently:

- isolate each target call;
- expose producer bounds as readable assumptions;
- assert target representability rather than hiding it inside contract application;
- directly execute the production target body;
- calculate explicit derived bounds;
- build the message-polynomial image from symbolic message bits;
- verify the intermediate `v + epp` state;
- verify the cumulative `v + epp + k` state;
- add frame and modulo-`q` assertions;
- produce targeted, reviewable evidence.

### PA-05B/PA-05C classification

```text
call-site applicability:
semantic overlap with original modular indcpa proof

standalone decomposition and direct target execution:
independent extension

producer bounds:
source-contract-informed

cumulative readable proof artefact:
independent experimental contribution
```

---

## 23. PA-06 and Original Cross-Parameter Infrastructure

The repository documentation instructs users to run proofs with:

```text
MLKEM_K={2,3,4}
```

Thus, cross-parameter execution is already an original repository objective.

PA-06 cannot claim to invent multi-parameter CBMC replication.

### PA-06 independent structure

PA-06 adds a separately managed matrix:

```text
5 verification units × 3 parameter sets = 15 units
```

It also adds:

- frozen PA-01 and PA-02 hash checks;
- direct vector-caller body verification;
- standalone call-site decompositions;
- text and JSON repetition;
- required-marker validation;
- campaign-level acceptance rules.

### PA-06 classification

```text
cross-parameter concept:
existing

replication of independently authored artefacts:
new campaign implementation

15-unit evidence matrix:
independent experimental architecture
```

---

## 24. PA-07 Semantic Position

The collected target-related repository evidence contains no mutation-sensitivity campaign for
`mlk_poly_add`.

PA-07 adds:

- a correct production baseline;
- five controlled external mutant implementations;
- two frozen detector harnesses;
- ten expected-failure mutant/harness pairs;
- property-specific failure classification;
- production-source hash protection;
- missing-body failure rejection.

### PA-07 classification

```text
equivalent original target artefact found:
no

semantic and experimental extension:
strong

textual duplication:
not detected
```

---

## 25. PA-08 Semantic Position

The original loop contract proves the complete loop and the function contract proves the legal
signed domain.

However, the collected original target artefacts do not contain the PA-08 style of:

- post-target deliberately false reachability sentinels;
- explicit satisfiability demonstrations;
- direct and split `INT16_MIN` witnesses;
- direct and split `INT16_MAX` witnesses;
- nearest-outside controls `INT16_MIN-1` and `INT16_MAX+1`;
- campaign classification that accepts only intended failures.

### PA-08 classification

```text
underlying legal boundary:
derived from existing contract

explicit anti-vacuity and nearest-boundary campaign:
independent extension

equivalent original target artefact found:
no
```

---

# Part IV — Property-Origin Ledger

## 26. Consolidated Property Classification

| Property or experiment | Existing repository specification/proof | Independently added or extended |
|---|---|---|
| valid polynomial pointers | yes | explicitly constructed and asserted |
| disjoint target operands | yes | explicitly asserted; later intentionally violated diagnostically |
| exact sum representability | yes | independently encoded and boundary-tested |
| exact coefficient-wise result | yes | independently rechecked in multiple domains |
| write footprint restricted to `r` | yes | explicit read-only frame assertions |
| processed-prefix loop relation | yes | direct unrolling and endpoint checks |
| canonical-domain output `0..2q-2` | not found as target contract property | yes |
| modulo-`q` refinement | not found in collected target contract | yes |
| commutativity relational call | not found | yes |
| additive identity relational call | not found | yes |
| unrestricted signed negative control | not found | yes |
| out-of-contract alias doubling | excluded by original contract | yes, diagnostic only |
| alias negative control | not found | yes |
| `polyvec_add` caller verification | yes, modular contract proof | direct nested-body and explicit assertions |
| `indcpa_enc` call-site checking | yes, modular whole-caller proof | standalone decomposition and direct target execution |
| three-parameter execution | yes | frozen 15-unit campaign matrix |
| mutation sensitivity | not found | yes |
| reachability sentinels | not found | yes |
| exact legal endpoint witnesses | implicit in theorem | explicitly witnessed |
| nearest illegal endpoint controls | not found | yes |
| post-freeze provenance audit | not found | yes |

---

## 27. Three Forms of Overlap

PA-09 distinguishes three different kinds of overlap.

### 27.1 Inevitable target overlap

Examples:

```text
function name
types
coefficient array
addition expression
modulus constants
```

This overlap is unavoidable.

### 27.2 Contract-derived overlap

Examples:

```text
disjointness
representable sum
exact output
write footprint
```

These are pre-existing repository specifications and were later explicitly encoded in the PA
artefacts.

### 27.3 Experimental extension

Examples:

```text
negative controls
alias diagnostics
relational algebraic checks
caller decomposition
mutation analysis
anti-vacuity sentinels
boundary pairs
hash-frozen campaign orchestration
```

These constitute the main distinct campaign contribution.

---

# Part V — Provenance Assessment

## 28. Evidence Supporting Independent Authorship

The following evidence supports independently authored implementation:

1. 24 authored source artefacts were hash-frozen before semantic comparison.
2. No exact binary duplicate was found.
3. No normalized-text duplicate was found.
4. No high mechanical-similarity pair was found.
5. The original target harness is only a symbolic function call.
6. The PA artefacts use materially different object construction and control flow.
7. The PA artefacts contain independent property labels and experiment logic.
8. The PA suite contains multiple campaign types absent from the original target proof directory.
9. PA-07 and PA-08 contain structures not required by the original contract proof.
10. The audit uses the frozen Git commit rather than an uncontrolled later checkout.

---

## 29. Evidence Preventing an Absolute Novelty Claim

The following facts prevent an absolute uniqueness or complete-blindness claim:

1. The production source was necessarily inspected.
2. The production source contains the full exact-addition contract.
3. The source loop contains the exact processed-prefix invariant.
4. PA-02 closely mirrors the original valid-domain theorem.
5. PA-05 uses producer postconditions from source contracts.
6. The repository already has `polyvec_add` and `indcpa_enc` modular proofs.
7. The repository already supports proof execution across all three parameter sets.
8. The same small function naturally produces similar mathematical obligations.
9. Mechanical comparison cannot prove a person's complete exposure history.
10. The campaign cannot establish global uniqueness relative to all external work.

---

## 30. Original-Harness-Blind Versus Formal-Artefact-Blind

The appropriate distinction is:

### Original-harness-blind

The initial clean-room harness was not constructed by copying or adapting:

```text
proofs/cbmc/poly_add/poly_add_harness.c
```

The post-freeze audit found no textual duplication.

### Not fully formal-artefact-blind

The production source itself exposed:

- the exact preconditions;
- the exact postcondition;
- the loop invariant;
- caller and producer contracts.

Therefore, the overall work was source-contract-informed.

The phrase:

```text
completely clean-room from all formal artefacts
```

would be inaccurate.

---

## 31. Final Defensible Provenance Statement

The recommended formal statement is:

> The PA-01 through PA-08 artefacts were independently authored and were not copied from the
> repository's original `mlk_poly_add` harness. A post-freeze comparison found no exact binary or
> normalized-text duplicate and no high-similarity pair among 192 authored/repository
> comparisons. The central representability, disjointness, exact-result, and write-footprint
> obligations overlap semantically with the production source contract and are acknowledged as
> re-verification rather than new theorems. The campaign independently extends the repository
> evidence through explicit canonical and relational properties, negative controls,
> out-of-contract alias diagnostics, standalone caller decompositions, mutation sensitivity,
> anti-vacuity sentinels, exact boundary controls, and a reproducible multi-stage evidence
> architecture.

---

## 32. Statements That Must Not Be Used

The following claims are not supported:

```text
The exact-addition theorem is completely new.
mlkem-native had no proof of mlk_poly_add.
The repository had no production caller verification.
The repository had no cross-parameter proof execution.
The harnesses are completely unrelated to the source contracts.
PA-04 proves production aliasing is allowed.
Zero textual similarity proves absolute intellectual independence.
The entire ML-KEM implementation is now proved.
```

---

# Part VI — Scientific Meaning of PA-01 Through PA-09

## 33. What Was Actually Proved

Within the declared CBMC model and assumptions, the campaign established:

### Valid-domain correctness

For disjoint valid polynomial objects whose exact coefficient sums fit in `int16_t`:

```text
r_after[i] = r_before[i] + b[i]
```

for every coefficient.

### Canonical specialization

For canonical input coefficients:

```text
0 <= r[i], b[i] < q
```

the exact result lies within:

```text
0 .. 2q-2
```

and has the expected modulo-`q` meaning.

### Signed-domain completeness

The exact-result theorem covers the complete signed domain admitted by the `int16_t` result
representation.

### Invalid-domain boundary

Unrestricted exact addition fails when the mathematical result is outside `int16_t`.

### Alias diagnostic

The current body computes exact doubling under same-object aliasing only where the doubled result
is representable, but this is outside the production contract.

### Caller applicability

The production caller obligations were independently decomposed and directly checked, while the
audit acknowledges existing repository modular caller proofs.

### Cross-parameter replication

The independent artefacts were repeated under all three ML-KEM parameter builds, while the audit
acknowledges existing repository multi-level proof infrastructure.

### Mutation sensitivity

The two principal frozen harnesses rejected every selected controlled mutant.

### Anti-vacuity and boundaries

The principal assumptions were shown satisfiable and target-reaching; exact legal and nearest
illegal boundaries were distinguished.

### Provenance

The artefacts are independently authored extensions, not textual copies, with acknowledged
semantic overlap.

---

## 34. Scope of the `mlk_poly_add` correctness result

The accurate answer is:

> Yes. For the selected portable C implementation and frozen repository revision, CBMC evidence
> establishes exact coefficient-wise addition for valid non-overlapping operands whose sums are
> representable in `int16_t`. The campaign independently corroborates the repository's existing
> contract proof, adds multiple relational and experimental checks, verifies caller obligations in
> explicit decomposed models, replicates the evidence across parameter sets, detects controlled
> mutants, and excludes important vacuity and boundary concerns.

This answer must remain qualified.

---

## 35. What Remains Outside the Proof

The campaign does not prove:

- the entire ML-KEM algorithm;
- all functions in `poly.c`;
- native or assembly implementations;
- every compiler or architecture;
- physical timing or microarchitectural constant time;
- permissibility of contract-violating aliasing;
- every possible defect mutation;
- correctness of future revisions;
- every possible caller or external misuse;
- semantic properties that were never encoded.

---

## 36. Complementarity with the Original Proof

The original repository proof and the PA campaign should not be presented as competitors.

They are complementary:

| Repository proof | PA campaign |
|---|---|
| source-contract-centred | explicit experiment-centred |
| modular loop-contract proof | direct full-unwind symbolic checks |
| minimal boilerplate harness | rich standalone harnesses |
| existing exact function theorem | independent corroboration and extensions |
| existing modular caller proofs | readable decomposed caller obligations |
| existing multi-level infrastructure | frozen replication matrix |
| no collected target mutation campaign | mutation sensitivity |
| no collected target sentinels | anti-vacuity sentinels |
| production-valid contract | out-of-contract diagnostic exploration |

---

# Part VII — Thesis Contribution Position

## 37. Correct Contribution Claim

The principal thesis contribution is not:

```text
discovering for the first time that polynomial addition is correct
```

The stronger and more defensible contribution is:

> A reproducible, layered methodology for independently generating, checking, negatively testing,
> applying, replicating, mutation-validating, anti-vacuity-hardening, and provenance-auditing
> candidate CBMC verification artefacts for production post-quantum cryptographic C code.

The `mlk_poly_add` campaign is the worked case study.

---

## 38. Why the Campaign Still Has Research Value

The original repository proof does not eliminate the research value of the campaign.

The research questions concern:

- whether an AI-assisted workflow can generate useful candidate artefacts;
- what overlaps with authoritative source contracts;
- what additional properties are generated;
- what documented correction is needed;
- whether CBMC accepts the results;
- whether negative controls and mutants expose weaknesses;
- how provenance and trust boundaries should be reported.

PA-09 strengthens the thesis because it prevents the work from falsely presenting existing
contract content as new research.

---

## 39. Academic-Integrity Position

The campaign should disclose:

1. the authoritative source function and contracts;
2. the repository's original CBMC proof;
3. the initial original-harness-blind construction claim;
4. later source-contract exposure;
5. exact semantic overlaps;
6. independently added properties;
7. post-freeze mechanical comparison;
8. all qualifications on novelty.

This is a stronger academic position than claiming complete isolation.

---

# Part VIII — Final Semantic Audit Matrix

## 40. Per-Campaign Verdict

| Campaign | Core relation to original repository proof | Distinct contribution | Verdict |
|---|---|---|---|
| PA-01 | exact sum is existing contract instance | canonical bounds, modulo `q`, commutativity, identity | qualified independent extension |
| PA-02 | core theorem closely matches original contract | relational checks, explicit frames, independent oracle | independent re-verification plus extensions |
| PA-03 | uses boundary implied by original precondition | unrestricted negative control | distinct extension |
| PA-04 | deliberately outside original disjoint contract | safe/unsafe alias diagnostic | distinct out-of-contract extension |
| PA-05A | original `polyvec_add` proof already exists | direct nested-body execution and explicit frames | overlapping objective, distinct harness |
| PA-05B/C | original `indcpa_enc` modular proof already exists | isolated readable derivation and direct target calls | overlapping objective, distinct decomposition |
| PA-06 | original proofs already run at K=2,3,4 | frozen 15-unit independent matrix | overlapping concept, distinct campaign |
| PA-07 | no equivalent target artefact found | mutation-sensitivity campaign | strong distinct extension |
| PA-08 | legal theorem implicit in original contract | sentinels and nearest-boundary controls | strong distinct extension |
| PA-09 | no equivalent target provenance audit found | post-freeze comparison and honest classification | strong distinct extension |

---

## 41. Final PA-09 Status

The semantic audit outcome is:

```text
campaign=PA-09
scope=strict_novelty_distinctness_and_provenance_audit
production_source_modified=no
authored_artifacts_hash_verified=24
mechanical_comparisons=192
exact_binary_duplicates=0
exact_normalized_text_duplicates=0
high_mechanical_similarity_pairs=0
core_contract_overlap_acknowledged=yes
existing_caller_proof_overlap_acknowledged=yes
existing_cross_parameter_overlap_acknowledged=yes
independent_campaign_extensions_confirmed=yes
absolute_uniqueness_claimed=no
final_status=PA09_QUALIFIED_PROVENANCE_CONCLUSION_ESTABLISHED
```

---

## 42. Professor-Ready Result Statement

> PA-09 performed a post-freeze provenance audit of 24 independently authored PA-01 through
> PA-08 source artefacts against 15 frozen target-related repository artefacts. The original
> `proofs/cbmc/poly_add/poly_add_harness.c` is a minimal symbolic call; its specification is
> supplied by the production `mlk_poly_add` contract and loop invariant. That source contract
> already contains the central disjointness, signed representability, exact-result, and
> write-footprint theorem. Accordingly, PA-01 and PA-02 are reported as independent
> re-verifications and extensions rather than first proofs of polynomial addition. The audit also
> identified existing repository modular proofs for `polyvec_add` and `indcpa_enc`, and existing
> three-parameter proof execution, so PA-05 and PA-06 are not presented as first caller or
> multi-level proofs. Nevertheless, no exact binary or normalized-text duplicate and no
> high-similarity pair was found among 192 comparisons. The campaign's explicit relational
> properties, negative controls, alias diagnostics, standalone caller decompositions, mutation
> analysis, reachability sentinels, exact boundary controls, and staged evidence architecture are
> independently authored extensions. The resulting provenance classification is independently
> authored, not textually copied, original-harness-blind during initial construction,
> source-contract-informed, semantically overlapping where required by the target contract, and
> substantially extended without claiming absolute uniqueness.

---

## 43. Final Conclusion

PA-09 did not establish an absolute novelty claim.

It established a stronger and more academically defensible conclusion:

```text
The artefacts are independently authored and mechanically distinct.
The core exact-addition theorem already existed in the source contract.
The campaign openly acknowledges that overlap.
Several caller and cross-parameter goals also overlap with repository proof infrastructure.
The campaign independently adds substantial experimental properties and validation layers.
The work is a reproducible assurance and evaluation contribution, not a claim of first discovery.
```

Final status:

```text
PA09_QUALIFIED_PROVENANCE_CONCLUSION_ESTABLISHED
```

---

# Appendix A — Original Repository `poly_add` Harness

```c
#include "poly.h"

void harness(void)
{
  mlk_poly *r, *b;
  mlk_poly_add(r, b);
}
```

---

# Appendix B — Original Repository Contract

```c
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(b, sizeof(mlk_poly)))
  requires(forall(k0, 0, MLKEM_N,
    (int32_t)r->coeffs[k0] + b->coeffs[k0] <= INT16_MAX))
  requires(forall(k1, 0, MLKEM_N,
    (int32_t)r->coeffs[k1] + b->coeffs[k1] >= INT16_MIN))
  ensures(forall(k, 0, MLKEM_N,
    r->coeffs[k] == old(*r).coeffs[k] + b->coeffs[k]))
  assigns(memory_slice(r, sizeof(mlk_poly)))
);
```

---

# Appendix C — Original Repository Loop Invariant

```c
for (i = 0; i < MLKEM_N; i++)
__loop__(
  invariant(i <= MLKEM_N)
  invariant(forall(k0, i, MLKEM_N,
    r->coeffs[k0] == loop_entry(*r).coeffs[k0]))
  invariant(forall(k1, 0, i,
    r->coeffs[k1] ==
      loop_entry(*r).coeffs[k1] + b->coeffs[k1]))
  decreases(MLKEM_N - i))
{
  r->coeffs[i] =
      (int16_t)(r->coeffs[i] + b->coeffs[i]);
}
```

---

# Appendix D — Original Repository Proof Configuration

```text
HARNESS_ENTRY = harness
HARNESS_FILE = poly_add_harness
PROOF_UID = mlk_poly_add

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly.c

CHECK_FUNCTION_CONTRACTS=mlk_poly_add
USE_FUNCTION_CONTRACTS=
APPLY_LOOP_CONTRACTS=on
USE_DYNAMIC_FRAMES=1

CBMCFLAGS=--smt2
FUNCTION_NAME = mlk_poly_add
CBMC_OBJECT_BITS = 8
```

---

# Appendix E — Mechanical Comparison Summary

```text
authored source artefacts compared: 16 C artefacts
repository artefacts collected:    15
mechanical comparisons:            192
exact binary duplicates:           0
normalized-text duplicates:        0
high-similarity pairs:             0
highest sequence ratio:            approximately 0.207
classification of listed pairs:    low mechanical overlap
```

---

# Appendix F — Provenance Vocabulary

**Independent authorship:** The artefact was written separately rather than copied or adapted
line-for-line from the compared original artefact.

**Original-harness-blind:** The original dedicated harness was not used as the construction
template during initial artefact generation.

**Source-contract-informed:** The production source contract or annotations were available and
influenced assumptions or properties.

**Semantic overlap:** Two artefacts express the same or related mathematical or safety obligation.

**Mechanical overlap:** Textual or token-level similarity measurable without understanding the
meaning.

**Independent extension:** A property, experiment, or evidence structure not found in the
collected original target artefacts.

**Absolute novelty:** A claim that no equivalent idea or artefact exists anywhere; this claim is
not made.

---

# Appendix G — Complete PA-09 Evidence Collector

```python
#!/usr/bin/env python3
"""
PA-09 Stage 1: strict novelty and provenance evidence collection for the
independently authored mlk_poly_add verification campaign.

Run from the frozen mlkem-native repository root:

    python3 run_pa09_mlk_poly_add_provenance_evidence.py

This script does not make the final semantic novelty judgement by itself.
It creates a deterministic evidence bundle for that judgement.

The script:

  * verifies the frozen repository revision and production poly.c identity;
  * verifies the exact hashes of all required PA-01 through PA-08 authored
    source artefacts;
  * reads original repository artefacts directly from the frozen Git commit;
  * collects the original proofs/cbmc/poly_add directory and every tracked
    file that directly references mlk_poly_add or poly_add;
  * records contracts, assertions, assumptions, loop annotations, and target
    references;
  * computes exact and mechanical text-similarity comparisons;
  * embeds all relevant repository and authored artefacts in one Markdown
    evidence bundle;
  * emits a summary whose successful status is:

        PA09_EVIDENCE_BUNDLE_READY_FOR_SEMANTIC_AUDIT

The final PA-09 conclusion must be issued only after semantic review of the
generated evidence bundle. Textual difference is not automatically proof of
intellectual independence, and textual similarity is not automatically proof
of copying.
"""

from __future__ import annotations

import csv
import datetime as dt
import difflib
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
from typing import Any

EXPECTED_COMMIT = "d9613cf60de3132d32475c102d8c2781d84feb34"
EXPECTED_POLY_C_SHA256 = (
    "f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
)

REQUIRED_AUTHORED: dict[str, str] = {
    "cleanroom_mlk_poly_add_fips_relational_harness_v2.c":
        "307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e",
    "run_cleanroom_mlk_poly_add_cbmc_v2.sh":
        "eeb5b1c1a88689e9219d704ec56fcc97b44ec8676ac1c391106adcd4243980f6",
    "pa02_mlk_poly_add_full_signed_contract_valid_harness.c":
        "e83d521e23f93c2435058598be5ef245bb02c554a4b7992dd8844418720c2ce2",
    "run_pa02_mlk_poly_add_full_signed_cbmc.sh":
        "7068aa8be8e763e7622b7a5767031eb1fa6f4a557f4b9a0507befbb0c346ffee",
    "pa03_mlk_poly_add_unrestricted_negative_control_harness.c":
        "37f9893284959fc9406d7e4bee06848b7c4e9e1cf717fe3c0d699ac5ca0f2487",
    "run_pa03_mlk_poly_add_unrestricted_negative_control.sh":
        "d2a628b547ceae17713b995a99244c9bfef761b8993be060eb71518627317f5d",
    "pa04a_mlk_poly_add_alias_safe_doubling_harness.c":
        "d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4",
    "pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c":
        "de2e0689d3470cf992533912e6689ac223d8408967b42e8082ac46af8545e528",
    "run_pa04_mlk_poly_add_aliasing_campaign.sh":
        "df15493e874057bc7e35516af8043be86399c131bc7f4a8ab99bd3744666a82c",
    "pa05a_mlk_poly_add_polyvec_production_callsite_harness.c":
        "ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e",
    "pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c":
        "8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc",
    "pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c":
        "8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0",
    "run_pa05_mlk_poly_add_production_callsites.sh":
        "3547108f805d9a89e5c5121249de1c6e7d7db48a20636ecc5dd702f22b78a34d",
    "pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c":
        "0941baf262a7a15c1f8be69a6c571c2727d4ab5de0ff16d0f3a364c8e3cb2ddd",
    "pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c":
        "e639524d557a13410d47ad7e1078955332a758d23fd46c1d444a7f77ba327644",
    "pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c":
        "b008285e11c0e05286338657b4529087e605a92f95f5689a0d1e279a46821b44",
    "run_pa06_mlk_poly_add_cross_parameter_campaign.sh":
        "7e88e942c81893a25f23c54ad3f4ee9115f5e4df1a849d924df7bbe8df967014",
    "pa07_mlk_poly_add_mutant_implementation.c":
        "4a0a231c050013cd73fbb7b5a07237218decb1a58ae3f9007a465adaa35b01ff",
    "run_pa07_mlk_poly_add_mutation_sensitivity.sh":
        "905f081214b6f64e192b5d7744368e4b09957b511acfce8cea805002320701ce",
    "pa08a_mlk_poly_add_boundary_hardening_harness.c":
        "1f7967136b275110519ba247f182d7f11ab4d36288493bd5e571d7a2dc584dee",
    "pa08b_mlk_poly_add_reachability_sentinel_harness.c":
        "38fbbd821e2ac13c4a85fca813425b4cbafe15ec9f72ca54b85fce5599fc6428",
    "pa08c_mlk_poly_add_upper_outside_boundary_harness.c":
        "36f2a6c423e1303570d25019db0d538e13a1f50135ae0f11e798636537fb891d",
    "pa08d_mlk_poly_add_lower_outside_boundary_harness.c":
        "6e484118e522d54c67d043e2a9d209df8a64e3af290666bc3d74cbb8b5c425ed",
    "run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh":
        "ff76bd70e3c876712a978127d10fc1f17788b1dda5818a8bbbc56c24e2f77859",
}

OPTIONAL_REPORTS = [
    "MLK_POLY_ADD_CLEANROOM_CBMC_A_TO_Z_EXPERIMENT_RECORD.md",
    "MLK_POLY_ADD_PA02_FULL_SIGNED_DOMAIN_CBMC_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA03_UNRESTRICTED_NEGATIVE_CONTROL_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA04_ALIASING_DIAGNOSTIC_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA05_PRODUCTION_CALLSITE_VERIFICATION_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA06_CROSS_PARAMETER_REPLICATION_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA07_MUTATION_SENSITIVITY_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA08_VACUITY_REACHABILITY_BOUNDARIES_A_TO_Z_RECORD.md",
]

MANDATORY_REPOSITORY_PATHS = {
    "mlkem/src/poly.c",
    "mlkem/src/poly.h",
    "mlkem/src/poly_k.c",
    "mlkem/src/poly_k.h",
    "mlkem/src/indcpa.c",
    "proofs/cbmc/README.md",
    "SOUNDNESS.md",
}

TARGET_RE = re.compile(
    r"\bmlk_poly_add\b|\bpoly_add\b|MLK_NAMESPACE\s*\(\s*poly_add\s*\)",
    re.IGNORECASE,
)

TEXT_SUFFIXES = {
    ".c", ".h", ".cc", ".cpp", ".hpp", ".i",
    ".md", ".txt", ".rst", ".json", ".yaml", ".yml",
    ".toml", ".sh", ".py", ".cmake",
}

ANNOTATION_PATTERNS = (
    "__CPROVER_assert",
    "__CPROVER_assume",
    "__contract__",
    "__loop__",
    "requires(",
    "ensures(",
    "assigns(",
    "invariant(",
    "decreases(",
)

REPO_ROOT = Path.cwd()


def run(command: list[str], *, check: bool = True) -> str:
    result = subprocess.run(
        command,
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if check and result.returncode != 0:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {' '.join(command)}\n"
            f"{result.stdout}"
        )
    return result.stdout.rstrip("\n")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def git_file_bytes(path: str) -> bytes:
    result = subprocess.run(
        ["git", "show", f"{EXPECTED_COMMIT}:{path}"],
        cwd=REPO_ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"Unable to read frozen repository path {path}:\n"
            f"{result.stderr.decode('utf-8', errors='replace')}"
        )
    return result.stdout


def git_file_text(path: str) -> str:
    return git_file_bytes(path).decode("utf-8", errors="replace")


def git_tree_paths(prefix: str | None = None) -> list[str]:
    command = ["git", "ls-tree", "-r", "--name-only", EXPECTED_COMMIT]
    if prefix:
        command.extend(["--", prefix])
    output = run(command)
    return sorted(line for line in output.splitlines() if line)


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", " ", text)
    return text


def normalized_text(text: str) -> str:
    return re.sub(r"\s+", "", strip_comments(text).lower())


def token_stream(text: str) -> list[str]:
    return re.findall(
        r"[A-Za-z_][A-Za-z0-9_]*|"
        r"0[xX][0-9A-Fa-f]+|\d+|"
        r"==|!=|<=|>=|\+\+|--|&&|\|\||<<|>>|->|"
        r"[{}()\[\];,+\-*/%<>=!&|^~?:.]",
        strip_comments(text),
    )


def significant_lines(text: str) -> set[str]:
    lines: set[str] = set()
    for raw in strip_comments(text).splitlines():
        line = re.sub(r"\s+", " ", raw.strip())
        if len(line) < 8:
            continue
        if line.startswith("#include"):
            continue
        if line in {"return 0;", "return;", "{", "}"}:
            continue
        lines.add(line)
    return lines


def jaccard(first: set[str], second: set[str]) -> float:
    union = first | second
    if not union:
        return 1.0
    return len(first & second) / len(union)


def mechanical_classification(
    exact_binary: bool,
    exact_normalized: bool,
    sequence_ratio: float,
    token_jaccard: float,
    line_jaccard: float,
) -> str:
    if exact_binary:
        return "exact-binary-duplicate"
    if exact_normalized:
        return "normalized-text-duplicate"
    if sequence_ratio >= 0.85 or token_jaccard >= 0.80:
        return "high-mechanical-similarity-review-required"
    if sequence_ratio >= 0.55 or token_jaccard >= 0.55 or line_jaccard >= 0.45:
        return "moderate-structural-overlap"
    return "low-mechanical-overlap"


def fenced(path: str, text: str) -> str:
    suffix = Path(path).suffix.lower()
    language = {
        ".c": "c",
        ".h": "c",
        ".cc": "cpp",
        ".cpp": "cpp",
        ".sh": "bash",
        ".py": "python",
        ".json": "json",
        ".md": "markdown",
        ".yaml": "yaml",
        ".yml": "yaml",
        ".toml": "toml",
    }.get(suffix, "text")

    fence = "```"
    while fence in text:
        fence += "`"
    return f"{fence}{language}\n{text.rstrip()}\n{fence}"


def write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    if not rows:
        path.write_text("", encoding="utf-8")
        return

    fields = list(rows[0].keys())
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def collect_annotation_lines(
    origin: str,
    path: str,
    text: str,
) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        if TARGET_RE.search(line) or any(pattern in line for pattern in ANNOTATION_PATTERNS):
            rows.append({
                "origin": origin,
                "path": path,
                "line": line_number,
                "text": line.rstrip(),
            })
    return rows


def main() -> int:
    if not (REPO_ROOT / ".git").is_dir():
        print(
            "ERROR: run this script from the mlkem-native repository root.",
            file=sys.stderr,
        )
        return 2

    actual_commit = run(["git", "rev-parse", "HEAD"])
    if actual_commit != EXPECTED_COMMIT:
        print("ERROR: repository commit mismatch.", file=sys.stderr)
        print(f"Expected: {EXPECTED_COMMIT}", file=sys.stderr)
        print(f"Actual:   {actual_commit}", file=sys.stderr)
        return 3

    current_poly = REPO_ROOT / "mlkem" / "src" / "poly.c"
    if not current_poly.is_file():
        print("ERROR: production mlkem/src/poly.c is missing.", file=sys.stderr)
        return 4

    tracked_poly_diff = subprocess.run(
        ["git", "diff", "--quiet", "--", "mlkem/src/poly.c"],
        cwd=REPO_ROOT,
        check=False,
    ).returncode
    if tracked_poly_diff != 0:
        print(
            "ERROR: production mlkem/src/poly.c has tracked modifications.",
            file=sys.stderr,
        )
        return 4

    current_poly_hash = sha256_file(current_poly)
    frozen_poly_hash = sha256_bytes(git_file_bytes("mlkem/src/poly.c"))

    if current_poly_hash != EXPECTED_POLY_C_SHA256:
        print("ERROR: working-tree poly.c hash mismatch.", file=sys.stderr)
        print(f"Expected: {EXPECTED_POLY_C_SHA256}", file=sys.stderr)
        print(f"Actual:   {current_poly_hash}", file=sys.stderr)
        return 5

    if frozen_poly_hash != EXPECTED_POLY_C_SHA256:
        print("ERROR: frozen-commit poly.c hash mismatch.", file=sys.stderr)
        print(f"Expected: {EXPECTED_POLY_C_SHA256}", file=sys.stderr)
        print(f"Actual:   {frozen_poly_hash}", file=sys.stderr)
        return 5

    authored_manifest: list[dict[str, Any]] = []
    missing: list[str] = []
    mismatched: list[str] = []

    for filename, expected_hash in REQUIRED_AUTHORED.items():
        path = REPO_ROOT / filename
        if not path.is_file():
            missing.append(filename)
            authored_manifest.append({
                "file": filename,
                "present": "no",
                "expected_sha256": expected_hash,
                "actual_sha256": "",
                "hash_verified": "no",
                "size_bytes": 0,
            })
            continue

        actual_hash = sha256_file(path)
        verified = actual_hash == expected_hash
        if not verified:
            mismatched.append(filename)

        authored_manifest.append({
            "file": filename,
            "present": "yes",
            "expected_sha256": expected_hash,
            "actual_sha256": actual_hash,
            "hash_verified": "yes" if verified else "no",
            "size_bytes": path.stat().st_size,
        })

    if missing or mismatched:
        print("ERROR: PA-01 through PA-08 artefact freeze failed.", file=sys.stderr)
        if missing:
            print("Missing files:", file=sys.stderr)
            for filename in missing:
                print(f"  {filename}", file=sys.stderr)
        if mismatched:
            print("Hash mismatches:", file=sys.stderr)
            for filename in mismatched:
                print(f"  {filename}", file=sys.stderr)
        return 6

    proof_directory_paths = git_tree_paths("proofs/cbmc/poly_add")
    if not proof_directory_paths:
        print(
            "ERROR: frozen repository contains no proofs/cbmc/poly_add directory.",
            file=sys.stderr,
        )
        return 7

    all_repo_paths = git_tree_paths()
    direct_reference_rows: list[dict[str, Any]] = []
    direct_reference_paths: set[str] = set()

    for path in all_repo_paths:
        suffix = Path(path).suffix.lower()
        if suffix not in TEXT_SUFFIXES and Path(path).name not in {
            "Makefile",
            "CMakeLists.txt",
        }:
            continue

        try:
            text = git_file_text(path)
        except RuntimeError:
            continue

        for line_number, line in enumerate(text.splitlines(), start=1):
            if TARGET_RE.search(line):
                direct_reference_paths.add(path)
                direct_reference_rows.append({
                    "path": path,
                    "line": line_number,
                    "text": line.rstrip(),
                })

    repository_paths = (
        set(proof_directory_paths)
        | direct_reference_paths
        | MANDATORY_REPOSITORY_PATHS
    )
    repository_paths = {
        path for path in repository_paths
        if path in set(all_repo_paths)
    }

    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out_dir = (
        REPO_ROOT
        / "cleanroom_results"
        / f"pa09_mlk_poly_add_provenance_{timestamp}"
    )
    authored_dir = out_dir / "authored_artifacts"
    repository_dir = out_dir / "repository_artifacts"
    optional_dir = out_dir / "optional_reports"

    authored_dir.mkdir(parents=True, exist_ok=False)
    repository_dir.mkdir(parents=True)
    optional_dir.mkdir(parents=True)

    for filename in REQUIRED_AUTHORED:
        shutil.copy2(REPO_ROOT / filename, authored_dir / filename)

    optional_manifest: list[dict[str, Any]] = []
    optional_search_roots = [
        REPO_ROOT,
        REPO_ROOT.parent,
        Path.home() / "Downloads",
    ]

    for filename in OPTIONAL_REPORTS:
        found: Path | None = None
        for root in optional_search_roots:
            candidate = root / filename
            if candidate.is_file():
                found = candidate
                break

        if found is None:
            optional_manifest.append({
                "file": filename,
                "present": "no",
                "sha256": "",
                "size_bytes": 0,
                "source_path": "",
            })
            continue

        shutil.copy2(found, optional_dir / filename)
        optional_manifest.append({
            "file": filename,
            "present": "yes",
            "sha256": sha256_file(found),
            "size_bytes": found.stat().st_size,
            "source_path": str(found),
        })

    repository_manifest: list[dict[str, Any]] = []
    repository_texts: dict[str, str] = {}

    for path in sorted(repository_paths):
        data = git_file_bytes(path)
        destination = repository_dir / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)

        text = data.decode("utf-8", errors="replace")
        repository_texts[path] = text
        repository_manifest.append({
            "path": path,
            "sha256": sha256_bytes(data),
            "size_bytes": len(data),
            "line_count": len(text.splitlines()),
            "in_original_poly_add_proof_directory":
                "yes" if path in proof_directory_paths else "no",
            "contains_direct_target_reference":
                "yes" if path in direct_reference_paths else "no",
        })

    authored_c_paths = [
        REPO_ROOT / filename
        for filename in REQUIRED_AUTHORED
        if filename.endswith(".c")
    ]

    comparisons: list[dict[str, Any]] = []
    exact_binary_duplicates = 0
    normalized_duplicates = 0

    for authored_path in authored_c_paths:
        authored_bytes = authored_path.read_bytes()
        authored_text = authored_bytes.decode("utf-8", errors="replace")
        authored_hash = sha256_bytes(authored_bytes)
        authored_normalized = normalized_text(authored_text)
        authored_tokens = token_stream(authored_text)
        authored_token_set = set(authored_tokens)
        authored_lines = significant_lines(authored_text)

        for repository_path, repository_text in repository_texts.items():
            if Path(repository_path).suffix.lower() not in TEXT_SUFFIXES:
                continue

            repository_bytes = git_file_bytes(repository_path)
            repository_hash = sha256_bytes(repository_bytes)
            repository_normalized = normalized_text(repository_text)
            repository_tokens = token_stream(repository_text)
            repository_token_set = set(repository_tokens)
            repository_lines = significant_lines(repository_text)

            exact_binary = authored_hash == repository_hash
            exact_normalized = (
                bool(authored_normalized)
                and authored_normalized == repository_normalized
            )
            sequence_ratio = difflib.SequenceMatcher(
                None,
                " ".join(authored_tokens),
                " ".join(repository_tokens),
                autojunk=False,
            ).ratio()
            token_j = jaccard(authored_token_set, repository_token_set)
            line_j = jaccard(authored_lines, repository_lines)

            if exact_binary:
                exact_binary_duplicates += 1
            if exact_normalized:
                normalized_duplicates += 1

            comparisons.append({
                "authored_file": authored_path.name,
                "repository_file": repository_path,
                "authored_sha256": authored_hash,
                "repository_sha256": repository_hash,
                "exact_binary_duplicate": "yes" if exact_binary else "no",
                "exact_normalized_text_duplicate":
                    "yes" if exact_normalized else "no",
                "token_sequence_ratio": round(sequence_ratio, 6),
                "token_jaccard": round(token_j, 6),
                "significant_line_jaccard": round(line_j, 6),
                "mechanical_classification": mechanical_classification(
                    exact_binary,
                    exact_normalized,
                    sequence_ratio,
                    token_j,
                    line_j,
                ),
            })

    comparisons.sort(
        key=lambda row: (
            float(row["token_sequence_ratio"]),
            float(row["token_jaccard"]),
            float(row["significant_line_jaccard"]),
        ),
        reverse=True,
    )

    annotation_rows: list[dict[str, Any]] = []

    for path, text in repository_texts.items():
        annotation_rows.extend(
            collect_annotation_lines("repository", path, text)
        )

    for filename in REQUIRED_AUTHORED:
        authored_path = REPO_ROOT / filename
        if authored_path.suffix.lower() not in {".c", ".h", ".sh"}:
            continue
        annotation_rows.extend(
            collect_annotation_lines(
                "authored",
                filename,
                authored_path.read_text(encoding="utf-8", errors="replace"),
            )
        )

    run_summary_manifest: list[dict[str, Any]] = []
    cleanroom_results = REPO_ROOT / "cleanroom_results"
    if cleanroom_results.is_dir():
        for summary_path in sorted(cleanroom_results.rglob("summary.txt")):
            if out_dir in summary_path.parents:
                continue
            relative = summary_path.relative_to(REPO_ROOT).as_posix()
            lower = relative.lower()
            if not any(f"pa0{number}" in lower for number in range(1, 9)):
                continue
            data = summary_path.read_bytes()
            run_summary_manifest.append({
                "path": relative,
                "sha256": sha256_bytes(data),
                "size_bytes": len(data),
            })

    write_csv(out_dir / "authored_manifest.csv", authored_manifest)
    write_csv(out_dir / "optional_report_manifest.csv", optional_manifest)
    write_csv(out_dir / "repository_manifest.csv", repository_manifest)
    write_csv(out_dir / "direct_target_references.csv", direct_reference_rows)
    write_csv(out_dir / "mechanical_comparison_matrix.csv", comparisons)
    write_csv(out_dir / "annotation_catalog.csv", annotation_rows)
    write_csv(out_dir / "prior_run_summary_manifest.csv", run_summary_manifest)

    for filename, value in [
        ("authored_manifest.json", authored_manifest),
        ("optional_report_manifest.json", optional_manifest),
        ("repository_manifest.json", repository_manifest),
        ("direct_target_references.json", direct_reference_rows),
        ("mechanical_comparison_matrix.json", comparisons),
        ("annotation_catalog.json", annotation_rows),
        ("prior_run_summary_manifest.json", run_summary_manifest),
    ]:
        (out_dir / filename).write_text(
            json.dumps(value, indent=2),
            encoding="utf-8",
        )

    history = run([
        "git",
        "log",
        "--date=iso-strict",
        "--format=%H%x09%ad%x09%an%x09%s",
        "--",
        "proofs/cbmc/poly_add",
        "mlkem/src/poly.c",
        "mlkem/src/poly.h",
    ], check=False)
    (out_dir / "repository_target_history.txt").write_text(
        history + "\n",
        encoding="utf-8",
    )

    git_status = run(["git", "status", "--short"], check=False)
    (out_dir / "git_status.txt").write_text(
        git_status + "\n",
        encoding="utf-8",
    )

    high_similarity = [
        row for row in comparisons
        if row["mechanical_classification"]
        == "high-mechanical-similarity-review-required"
    ]

    bundle: list[str] = []
    bundle.append("# PA-09 `mlk_poly_add` Provenance Evidence Bundle")
    bundle.append("")
    bundle.append("## 1. Audit Identity")
    bundle.append("")
    bundle.append(f"- Repository root: `{REPO_ROOT}`")
    bundle.append(f"- Frozen commit: `{actual_commit}`")
    bundle.append(f"- Production `poly.c` SHA-256: `{current_poly_hash}`")
    bundle.append("- Production source modified: `No`")
    bundle.append(
        f"- Required authored artefacts hash-verified: "
        f"`{len(authored_manifest)}`"
    )
    bundle.append(
        f"- Files in original `proofs/cbmc/poly_add`: "
        f"`{len(proof_directory_paths)}`"
    )
    bundle.append(
        f"- Frozen repository artefacts collected: "
        f"`{len(repository_manifest)}`"
    )
    bundle.append(
        f"- Mechanical authored/repository comparisons: "
        f"`{len(comparisons)}`"
    )
    bundle.append(
        f"- Exact binary duplicates found: `{exact_binary_duplicates}`"
    )
    bundle.append(
        f"- Exact normalized-text duplicates found: "
        f"`{normalized_duplicates}`"
    )
    bundle.append(
        f"- High mechanical similarity pairs requiring semantic review: "
        f"`{len(high_similarity)}`"
    )
    bundle.append("")
    bundle.append("## 2. Interpretation Boundary")
    bundle.append("")
    bundle.append(
        "This bundle establishes artefact identity, frozen repository "
        "content, and mechanical overlap. It does not treat a similarity "
        "score as a final semantic provenance judgement. The final PA-09 "
        "conclusion must separately distinguish inevitable overlap, "
        "contract-derived overlap, architectural overlap, and evidence of "
        "copying or independent extension."
    )
    bundle.append("")
    bundle.append("## 3. Authored Artefact Freeze")
    bundle.append("")
    bundle.append("| File | Hash verified | SHA-256 | Size |")
    bundle.append("|---|---|---|---:|")
    for row in authored_manifest:
        bundle.append(
            f"| `{row['file']}` | {row['hash_verified']} | "
            f"`{row['actual_sha256']}` | {row['size_bytes']} |"
        )
    bundle.append("")
    bundle.append("## 4. Original Repository `poly_add` Proof Directory")
    bundle.append("")
    for path in proof_directory_paths:
        bundle.append(f"- `{path}`")
    bundle.append("")
    bundle.append("## 5. Repository Candidate Manifest")
    bundle.append("")
    bundle.append(
        "| Path | Original proof directory | Direct target reference | SHA-256 |"
    )
    bundle.append("|---|---|---|---|")
    for row in repository_manifest:
        bundle.append(
            f"| `{row['path']}` | "
            f"{row['in_original_poly_add_proof_directory']} | "
            f"{row['contains_direct_target_reference']} | "
            f"`{row['sha256']}` |"
        )
    bundle.append("")
    bundle.append("## 6. Direct Target References")
    bundle.append("")
    bundle.append("```text")
    for row in direct_reference_rows:
        bundle.append(f"{row['path']}:{row['line']}: {row['text']}")
    bundle.append("```")
    bundle.append("")
    bundle.append("## 7. Highest Mechanical Similarities")
    bundle.append("")
    bundle.append(
        "These values are discovery aids. They are not the final novelty "
        "classification."
    )
    bundle.append("")
    bundle.append(
        "| Authored file | Repository file | Sequence | Token Jaccard | "
        "Line Jaccard | Classification |"
    )
    bundle.append("|---|---|---:|---:|---:|---|")
    for row in comparisons[:100]:
        bundle.append(
            f"| `{row['authored_file']}` | "
            f"`{row['repository_file']}` | "
            f"{row['token_sequence_ratio']:.3f} | "
            f"{row['token_jaccard']:.3f} | "
            f"{row['significant_line_jaccard']:.3f} | "
            f"{row['mechanical_classification']} |"
        )
    bundle.append("")
    bundle.append("## 8. Annotation and Property Catalogue")
    bundle.append("")
    bundle.append("```text")
    for row in annotation_rows:
        bundle.append(
            f"{row['origin']}:{row['path']}:{row['line']}: {row['text']}"
        )
    bundle.append("```")
    bundle.append("")
    bundle.append("## 9. Required Semantic Audit Questions")
    bundle.append("")
    bundle.append(
        "1. What does the original repository harness contain, and what "
        "does it delegate to source contracts?"
    )
    bundle.append(
        "2. Which assumptions and postconditions are shared because both "
        "artefacts target the same function contract?"
    )
    bundle.append(
        "3. Which PA properties are direct restatements or refinements of "
        "the repository contract?"
    )
    bundle.append(
        "4. Which PA properties are absent from the original harness and "
        "source contract?"
    )
    bundle.append(
        "5. Are the negative controls, alias diagnostics, caller proofs, "
        "cross-parameter runs, mutation campaign, and anti-vacuity sentinels "
        "structurally original additions?"
    )
    bundle.append(
        "6. Is any assertion wording, helper implementation, control-flow "
        "layout, or harness scaffolding copied verbatim?"
    )
    bundle.append(
        "7. Which overlap is inevitable or source-contract-derived rather "
        "than evidence of copying?"
    )
    bundle.append(
        "8. What claim is supportable: exact uniqueness, independent "
        "authorship, original-harness blindness, or source-contract-informed "
        "extension?"
    )
    bundle.append("")
    bundle.append("## 10. Frozen Repository Artefact Contents")
    bundle.append("")
    for path in sorted(repository_texts):
        bundle.append(f"### `{path}`")
        bundle.append("")
        bundle.append(fenced(path, repository_texts[path]))
        bundle.append("")
    bundle.append("## 11. Authored PA-01 Through PA-08 Artefact Contents")
    bundle.append("")
    for filename in REQUIRED_AUTHORED:
        path = REPO_ROOT / filename
        text = path.read_text(encoding="utf-8", errors="replace")
        bundle.append(f"### `{filename}`")
        bundle.append("")
        bundle.append(fenced(filename, text))
        bundle.append("")
    bundle.append("## 12. Deterministic Stage-1 Status")
    bundle.append("")
    bundle.append("```text")
    bundle.append("PA09_EVIDENCE_BUNDLE_READY_FOR_SEMANTIC_AUDIT")
    bundle.append("```")
    bundle.append("")

    bundle_path = out_dir / "PA09_PROVENANCE_EVIDENCE_BUNDLE.md"
    bundle_path.write_text("\n".join(bundle), encoding="utf-8")

    summary: dict[str, Any] = {
        "campaign": "PA-09",
        "scope": "strict_novelty_and_provenance_evidence_collection",
        "production_source_modified": "no",
        "authored_artifacts_required": len(REQUIRED_AUTHORED),
        "authored_artifacts_hash_verified": len(authored_manifest),
        "original_poly_add_proof_files": len(proof_directory_paths),
        "repository_artifacts_collected": len(repository_manifest),
        "mechanical_comparisons": len(comparisons),
        "exact_binary_duplicates": exact_binary_duplicates,
        "exact_normalized_text_duplicates": normalized_duplicates,
        "high_similarity_pairs_for_semantic_review": len(high_similarity),
        "annotation_catalog_generated": "yes",
        "semantic_audit_required": "yes",
        "bundle_file": bundle_path.name,
        "final_status": "PA09_EVIDENCE_BUNDLE_READY_FOR_SEMANTIC_AUDIT",
    }

    with (out_dir / "summary.txt").open("w", encoding="utf-8") as handle:
        for key, value in summary.items():
            handle.write(f"{key}={value}\n")

    (out_dir / "summary.json").write_text(
        json.dumps(summary, indent=2),
        encoding="utf-8",
    )

    print("PA-09 deterministic provenance evidence collection completed.")
    print("")
    for key, value in summary.items():
        print(f"{key}={value}")
    print(f"results_directory={out_dir}")
    print("")
    print("Upload PA09_PROVENANCE_EVIDENCE_BUNDLE.md for semantic audit.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

---

# Appendix H — Evidence-Bundle Manifest

```text
bundle:
PA09_PROVENANCE_EVIDENCE_BUNDLE.md

SHA-256:
93eb68277d8784cd764cfa8686111e1690ee7dd338a88b210c06937a9e101de8

bytes:
421197

lines:
11303

deterministic Stage-1 status:
PA09_EVIDENCE_BUNDLE_READY_FOR_SEMANTIC_AUDIT

semantic Stage-2 status:
PA09_QUALIFIED_PROVENANCE_CONCLUSION_ESTABLISHED
```

---

# Appendix I — Combined PA-01 Through PA-09 Summary

| Campaign | Main purpose | Outcome |
|---|---|---|
| PA-01 | canonical FIPS-domain correctness | verified |
| PA-02 | complete signed contract-valid correctness | verified |
| PA-03 | unrestricted exact-addition negative control | expected counterexample confirmed |
| PA-04 | aliasing diagnostic and boundary | confirmed |
| PA-05 | explicit production call-site verification | verified with existing-proof overlap acknowledged |
| PA-06 | cross-parameter replication | verified with existing multi-level overlap acknowledged |
| PA-07 | mutation sensitivity | all controlled mutants detected |
| PA-08 | vacuity, reachability, loop endpoints, and boundaries | confirmed |
| PA-09 | strict novelty and provenance audit | qualified independent authorship and extension established |

---

# Appendix J — Final Assurance Statement

> At frozen commit `d9613cf60de3132d32475c102d8c2781d84feb34`, the portable C
> implementation of `mlk_poly_add` satisfies its exact coefficient-wise addition contract for
> valid non-overlapping operands whose mathematical sums fit in `int16_t`. This core theorem was
> already specified and proved in the repository's contract-centred CBMC infrastructure. The
> independently authored PA campaign corroborates that theorem and substantially extends its
> experimental evidence through canonical and relational properties, negative controls,
> out-of-contract alias diagnostics, explicit caller decompositions, cross-parameter repetition,
> mutation sensitivity, anti-vacuity sentinels, exact boundary controls, and a post-freeze
> provenance audit. The resulting evidence is strong but remains scoped to the declared source
> revision, implementation backend, assumptions, and encoded properties.
