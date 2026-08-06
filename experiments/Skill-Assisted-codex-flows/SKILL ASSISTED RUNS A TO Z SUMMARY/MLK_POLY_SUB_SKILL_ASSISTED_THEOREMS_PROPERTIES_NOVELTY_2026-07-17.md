Codex CLI 0.144.4 — GPT-5.6 sol — reasoning high

# Final Experimental Record: Skill-Assisted Relational Verification of `mlk_poly_sub`

**Principal experimental agent:** Codex CLI  
**Formal verification authority:** CBMC 6.9.0  
**Target:** `mlk_poly_sub` in `pq-code-package/mlkem-native`  
**Frozen source commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Parameter configuration:** ML-KEM-768, `MLKEM_N = 256`, `MLKEM_Q = 3329`  
**Final evidential classification:** `PASS_COMPLETE_SKILL_ASSISTED_POLY_SUB_CORPUS`

---

## 1. Purpose and authorship

I acted as the principal Codex agent for this experiment. I analysed the frozen `mlkem-native` implementation and contracts, selected the relational theorem candidates, produced the harness and execution design, repaired fail-closed preflight defects, interpreted the CBMC evidence, and organised the final corpus. The human operator executed the supplied terminal commands and returned the terminal evidence. CBMC—not Codex—was the formal authority for the final verdicts.

This report records the exact theorem statements, assumptions, safety obligations, final property counts, coverage evidence, execution repairs, and repository-relative novelty of the `mlk_poly_sub` skill-assisted experiment.

---

## 2. Frozen source and integrity boundary

```text
repository       pq-code-package/mlkem-native
commit           d9613cf60de3132d32475c102d8c2781d84feb34
parameter set    ML-KEM-768
MLKEM_N          256
MLKEM_Q          3329
poly.c SHA-256   f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722
poly.h SHA-256   f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef
```

The accepted worktree matched the frozen Git commit and remained clean. The production `poly.c` and `poly.h` files were not edited to satisfy the selected claims. The real portable-C production translation unit was compiled with each harness.

The target body was:

```c
void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] - b->coeffs[i]);
  }
}
```

The accepted environment recorded CBMC, `goto-cc`, and `goto-instrument` 6.9.0, GCC 13.3.0, Python 3.12.3, C90, x86-64, and a little-endian host.

---

## 3. Upstream `mlkem-native` baseline

At the frozen commit, the repository already contains the single-call contract:

```text
requires:
    r and b are valid disjoint polynomial objects
    each exact r[i] - b[i] fits in int16_t

ensures:
    r_after[i] = r_before[i] - b[i]

assigns:
    only r may be modified
```

The source loop invariant records the processed-prefix form of the same coefficient-wise subtraction. The native CBMC harness is minimal:

```c
void harness(void)
{
  mlk_poly *r, *b;
  mlk_poly_sub(r, b);
}
```

These upstream artefacts are authoritative prior work. The experiment did not claim to invent subtraction, its local functional contract, its non-overflow condition, or its loop invariant.

The experiment selected two multi-execution relational consequences that were not present as the selected theorem titles, multi-call harnesses, named assertion sets, coverage goals, or accepted evidence corpus in the frozen repository.

---

## 4. Trust and acceptance model

The authority order was:

```text
frozen source and source hashes
        >
generated GOTO model
        >
CBMC property records and exit codes
        >
deterministic summaries
        >
Codex interpretation
```

Acceptance required:

- successful proof and coverage model construction;
- zero proof and coverage exit codes;
- universal success of all proof-property records;
- no failed or unknown proof status;
- satisfied named cover goals;
- target-call reachability;
- final-assertion reachability;
- assumption feasibility;
- commit and source-hash agreement;
- a clean tracked worktree; and
- complete evidence and manifests.

---

# Part I — SA-SUB-T1

## 5. SA-SUB-T1: common-minuend difference reversal

### 5.1 Mathematical statement

For arbitrary polynomial coefficient arrays `a`, `b`, and `c`, under the signed-16-bit representability conditions required by every production call:

```text
(a - b) - (a - c) = c - b
```

The equality is checked coefficient-wise across all 256 positions.

### 5.2 Production schedules

Four real calls compare two schedules:

```text
left_1 := a
mlk_poly_sub(&left_1, &b)       // a - b

left_2 := a
mlk_poly_sub(&left_2, &c)       // a - c

nested := left_1
mlk_poly_sub(&nested, &left_2)  // (a - b) - (a - c)

direct := c
mlk_poly_sub(&direct, &b)       // c - b
```

No copied target body or target stub computes these results.

### 5.3 Assumptions

For every coefficient, the call-level expressions must be representable in `int16_t`:

```text
a[i] - b[i]
a[i] - c[i]
c[i] - b[i]
```

The intermediate nested call is constrained to the target's contract-valid domain. Objects are separately allocated valid `mlk_poly` values. The theorem identity is not assumed.

### 5.4 Semantic assertions

For every coefficient:

```text
nested == direct
nested == widened(c - b)
direct == widened(c - b)
```

The widened arithmetic bridges prevent the proof from succeeding merely because both target schedules undergo the same unintended truncation.

This theorem is a common-minuend elimination identity. It is distinct from previously investigated cancellation forms such as:

```text
(a - b) + b = a
(a + b) - b = a
```

### 5.5 Safety and implementation obligations

The proof model checks:

- array bounds;
- pointer validity;
- pointer overflow;
- signed overflow;
- unsigned overflow;
- integer conversion;
- division by zero;
- undefined shifts; and
- complete loop unwinding with unwinding assertions.

The global unwind bound was `257`, covering the 256 loop iterations and the exit test.

### 5.6 Reachability and non-vacuity

Seven named coverage goals were satisfied:

1. assumptions feasible;
2. nontrivial symbolic witness available;
3. target call 1 reached;
4. target call 2 reached;
5. target call 3 reached;
6. target call 4 reached; and
7. final assertion block reached.

### 5.7 Accepted result

```text
SA_SUB_T1_PROOF_BUILD_EXIT            0
SA_SUB_T1_PROOF_EXIT                  0
SA_SUB_T1_COVER_BUILD_EXIT            0
SA_SUB_T1_COVER_EXIT                  0
SA_SUB_T1_PROOF_PROPERTIES_SUCCESS    345
SA_SUB_T1_PROOF_PROPERTIES_FAILED     0
SA_SUB_T1_COVER_GOALS_SATISFIED       7
SA_SUB_T1_FINAL_STATUS                PASS
```

The 345 records include theorem assertions, harness checks, generated safety properties, and expanded loop-related obligations. They are not 345 distinct mathematical theorems.

---

# Part II — SA-SUB-T2

## 6. SA-SUB-T2: sequential-subtrahend aggregation equivalence

### 6.1 Mathematical statement

For arbitrary polynomial coefficient arrays `a`, `b`, and `c`, the harness constructs:

```text
aggregate = b + c
```

and compares:

```text
sequential = (a - b) - c
direct     = a - aggregate
```

The selected theorem is:

```text
(a - b) - c = a - (b + c)
```

coefficient-wise across all 256 positions.

### 6.2 Aggregate construction

The aggregate is formed using widened arithmetic and stored only when representable in `int16_t`.

The harness then asserts:

```text
aggregate[i] = widened(b[i] + c[i])
```

The aggregate equation is not assumed. This avoids a circular proof in which the aggregate is unconstrained or defined by the desired conclusion.

### 6.3 Production schedules

Three real calls are executed:

```text
sequential := a
mlk_poly_sub(&sequential, &b)
mlk_poly_sub(&sequential, &c)

direct := a
mlk_poly_sub(&direct, &aggregate)
```

### 6.4 Assumptions

For every coefficient:

```text
a[i] - b[i]          fits in int16_t
b[i] + c[i]          fits in int16_t
a[i] - (b[i] + c[i]) fits in int16_t
```

The objects are separately allocated and valid. Neither the theorem equality nor the aggregate equation is assumed.

### 6.5 Semantic assertions

For every coefficient:

```text
aggregate == widened(b + c)
sequential == direct
sequential == widened((a - b) - c)
direct == widened(a - (b + c))
```

Each schedule is independently linked to ordinary widened arithmetic before the relational equality is accepted.

### 6.6 Proof configuration

The accepted T2 proof retained:

- the complete 256-coefficient symbolic domain;
- all theorem assertions;
- all configured standard safety checks;
- unwind bound `257`;
- unwinding assertions; and
- the real production body.

The proof added sound model-reduction options:

```text
--drop-unused-functions
--reachability-slice
--slice-formula
```

These options remove irrelevant functions and assignments. They do not disable assertions, permit partial loops, or remove unwinding assertions.

### 6.7 Reachability and non-vacuity

Six named coverage goals were satisfied:

1. assumptions feasible;
2. nontrivial symbolic witness available;
3. target call 1 reached;
4. target call 2 reached;
5. target call 3 reached; and
6. final assertion block reached.

Coverage was executed separately as non-vacuity evidence. The theorem verdict came from the universal proof model.

### 6.8 Accepted result

```text
SA_SUB_T2_PROOF_BUILD_EXIT            0
SA_SUB_T2_PROOF_EXIT                  0
SA_SUB_T2_COVER_BUILD_EXIT            0
SA_SUB_T2_COVER_EXIT                  0
SA_SUB_T2_PROOF_PROPERTIES_SUCCESS    52
SA_SUB_T2_PROOF_PROPERTIES_FAILED     0
SA_SUB_T2_COVER_GOALS_SATISFIED       6
SA_SUB_T2_FINAL_STATUS                PASS
```

The lower property-record count relative to T1 reflects the generated-model structure and sound slicing configuration. It is not a measure of lower mathematical strength.

---

## 7. Aggregate result

| Evidence item | SA-SUB-T1 | SA-SUB-T2 | Total |
|---|---:|---:|---:|
| Real production target calls | 4 | 3 | 7 |
| Successful proof-property records | 345 | 52 | 397 |
| Failed proof-property records | 0 | 0 | 0 |
| Satisfied named cover goals | 7 | 6 | 13 |
| Final status | PASS | PASS | PASS |

```text
RUNS OCCURED                         1
Selected-claim mapping               YES
Target reachability                  YES
Assertion reachability               YES
Assumption feasibility               YES
Evidence completeness                COMPLETE
Repository distinctness              SUPPORTED
Contamination                        NONE KNOWN
successful_property_records_total    397
satisfied_named_cover_goals_total    13
overall_verdict                      PASS_COMPLETE_SKILL_ASSISTED_POLY_SUB_CORPUS
```

---

## 8. Preflight repairs and interrupted coverage

Before final acceptance, the execution workflow exposed:

- incorrect or truncated source-hash binding values;
- a malformed Python endian preflight expression;
- an intentionally interrupted T1 coverage process after the T1 universal proof had succeeded; and
- the need to execute T2 independently without rerunning the accepted T1 proof.

These were classified as follows:

- the source-binding and endian failures occurred before theorem execution;
- they were runner/preflight defects, not mathematical counterexamples;
- the production source remained unchanged;
- T1 universal proof remained accepted with 345 successful records;
- the interrupted T1 coverage file was rejected;
- a clean T1 reachability-only coverage execution later satisfied all seven named goals; and
- T2 completed with all four stage exit codes equal to zero.

Only the final clean successful evidence contributes to the accepted verdict.

---

## 9. Repository-relative novelty

### 9.1 What upstream already contains

The frozen repository contains:

- the portable `mlk_poly_sub` implementation;
- a loop invariant for processed-prefix subtraction;
- a single-call exact subtraction contract;
- non-overflow and non-aliasing preconditions; and
- a minimal one-call CBMC harness.

### 9.2 What this experiment adds

The experiment adds executable relational artefacts for:

```text
SA-SUB-T1:
    (a - b) - (a - c) = c - b

SA-SUB-T2:
    (a - b) - c = a - (b + c)
```

The repository-distinct elements are:

- theorem selection and naming;
- four-call and three-call relational schedules;
- widened independent arithmetic bridges;
- aggregate construction and validation;
- named assumption-feasibility goals;
- named nontrivial-witness goals;
- per-call reachability goals;
- final assertion-block reachability;
- fail-closed source binding;
- structured result summarisation;
- evidence manifests; and
- explicit distinctness and contamination audits.

### 9.3 Novelty limit

Both identities follow from repeated application of the native single-call contract and ordinary integer algebra, provided every call remains in the explicit representable domain.

The experiment therefore does not claim to have discovered new subtraction mathematics.

The correct claim is:

> Repository-distinct multi-execution CBMC harnesses and accepted evidence were created for relational consequences that were not packaged as named selected claims in the frozen `mlkem-native` repository.

This does not establish worldwide novelty or exclude unpublished or differently named equivalent work.

### 9.4 Defensible comparison

At the frozen commit:

- upstream `poly_sub_harness.c` contains one target call;
- the native contract proves local exact subtraction under non-overflow;
- SA-SUB-T1 relates four target executions;
- SA-SUB-T2 relates three target executions and a constructed aggregate; and
- the skill-assisted package adds explicit non-vacuity, reachability, source binding, property accounting, and manifest evidence.

---

## 10. What was proved

Within the frozen portable-C source and explicit representability assumptions, the experiment proved:

- common-minuend difference reversal across four real target calls;
- agreement of the T1 nested and direct schedules;
- agreement of both T1 schedules with widened `c - b`;
- sequential-subtrahend aggregation equivalence across three real calls;
- correctness of the constructed `b + c` aggregate;
- agreement of both T2 schedules with widened arithmetic;
- the recorded standard CBMC safety obligations;
- complete bounded loop execution;
- assumption feasibility;
- nontrivial witness availability;
- reachability of every production call; and
- reachability of both final assertion blocks.

---

## 11. What was not proved

The experiment did not prove:

- defined behaviour for calls that overflow `int16_t`;
- unsupported aliasing;
- assembly or architecture-specific backends;
- compiler-generated machine-code equivalence;
- modular reduction or canonicalisation;
- the complete K-PKE.Decrypt path;
- complete ML-KEM correctness;
- complete FIPS 203 compliance;
- cryptographic security;
- timing or side-channel resistance;
- fault resistance;
- every subtraction identity;
- all commits or parameter configurations; or
- worldwide novelty.

---

## 12. Reproducibility boundary

A faithful reproduction must preserve:

1. the frozen commit;
2. the recorded source hashes;
3. ML-KEM-768 and `MLKEM_N = 256`;
4. the exact T1 and T2 harnesses;
5. the representability assumptions;
6. the widened arithmetic bridges;
7. the real production target calls;
8. all recorded proof checks;
9. unwind bound `257`;
10. unwinding assertions;
11. separate proof and coverage models;
12. the accepted T2 slicing configuration; and
13. the final evidence manifests.

Changing source, assumptions, assertions, target schedules, unwind policy, parameter configuration, or backend creates a new experiment.

---

## 13. Professor-ready conclusion

> On 17 July 2026, I completed a skill-assisted CBMC case study for the unchanged portable-C `mlk_poly_sub` implementation at `mlkem-native` commit `d9613cf60de3132d32475c102d8c2781d84feb34`. SA-SUB-T1 verified `(a-b)-(a-c)=c-b` across four production executions. SA-SUB-T2 verified `(a-b)-c=a-(b+c)` across three production executions, with the aggregate constructed and independently checked in widened arithmetic. The accepted evidence contained 397 successful proof-property records, zero failed proof-property records, and 13 satisfied named feasibility and reachability goals. The contribution is a repository-distinct multi-execution relational verification corpus, not new integer algebra, complete ML-KEM correctness, or worldwide novelty.

---

## 14. Source comparison references

- `https://github.com/pq-code-package/mlkem-native/blob/d9613cf60de3132d32475c102d8c2781d84feb34/mlkem/src/poly.c`
- `https://github.com/pq-code-package/mlkem-native/blob/d9613cf60de3132d32475c102d8c2781d84feb34/mlkem/src/poly.h`
- `https://github.com/pq-code-package/mlkem-native/blob/d9613cf60de3132d32475c102d8c2781d84feb34/proofs/cbmc/poly_sub/poly_sub_harness.c`

---

## 15. Date-integrity note

The experiment date is recorded as **17 July 2026**. Original evidence files, manifests, terminal logs, and filesystem metadata should retain their authentic provenance timestamps and must not be rewritten merely to force timestamp uniformity.
