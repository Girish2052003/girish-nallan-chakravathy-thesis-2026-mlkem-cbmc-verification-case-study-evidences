Codex CLI 0.144.4 — GPT-5.6 sol — reasoning high

# Final Experimental Record: Skill-Assisted Relational Verification of `mlk_poly_add`

**Experiment date:** 17 July 2026  
**Principal experimental agent:** Codex CLI  
**Formal verification authority:** CBMC 6.9.0  
**Target:** `mlk_poly_add` in `pq-code-package/mlkem-native`  
**Frozen source commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Parameter configuration:** ML-KEM-768, `MLKEM_N = 256`, `MLKEM_Q = 3329`  
**Final evidential classification:** `FINAL_ACCEPTANCE=PASS`

---

## 1. Purpose and authorship

I acted as the principal Codex agent for this experiment. I analysed the frozen `mlkem-native` source, selected the relational theorem candidates, constructed the CBMC harness design, generated and repaired the execution workflow, interpreted the formal-tool output, and organised the evidence corpus. The human operator executed the supplied terminal commands and returned the terminal evidence. CBMC—not Codex—remained the authority for every proof verdict.

This record documents the precise theorems, assumptions, generated proof obligations, accepted property counts, reachability evidence, and repository-relative novelty of the `mlk_poly_add` skill-assisted experiment.

The report does not treat an AI-generated statement as proof. A claim is accepted only where the frozen executable model and CBMC result records support it.

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

The worktree was checked against the frozen commit. The production `mlkem/src/poly.c` and `mlkem/src/poly.h` files were not modified to obtain a passing result. The verification harnesses were additional artefacts compiled with the real production translation unit.

The target implementation was the destructive accumulator form:

```c
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }
}
```

---

## 3. Upstream `mlkem-native` baseline

At the frozen commit, the repository already contains a single-call contract whose essential meaning is:

```text
requires:
    r and b are valid disjoint polynomial objects
    each exact coefficient sum fits in int16_t

ensures:
    r_after[i] = r_before[i] + b[i]

assigns:
    only r may be modified
```

The native CBMC harness is a minimal one-call artefact:

```c
void harness(void)
{
  mlk_poly *r, *b;
  mlk_poly_add(r, b);
}
```

The native contract, loop invariant, non-aliasing requirement, non-overflow condition, and coefficient-wise addition semantics are authoritative prior work. They are not claimed as contributions of this experiment.

The selected contribution is the executable verification of multi-execution relational consequences that were not packaged in the frozen repository as the selected theorem titles, named assertions, multi-call harnesses, coverage goals, or accepted evidence corpus used here.

---

## 4. Trust and acceptance model

The authority order was:

```text
frozen source and source hashes
        >
GOTO model generated from source and harness
        >
CBMC property records and exit codes
        >
deterministic summaries
        >
Codex interpretation
```

Acceptance required:

- successful model construction;
- zero proof exit code;
- universal success of every recorded proof property;
- zero failed or unknown proof statuses;
- satisfied named cover goals;
- target-call reachability;
- final-assertion reachability;
- assumption feasibility;
- complete evidence files; and
- unchanged frozen production source.

---

# Part I — SA-ADD-T1

## 5. SA-ADD-T1: common-addend translation invariance

### 5.1 Mathematical statement

For arbitrary polynomials `x`, `y`, and `b`, whenever the required additions are representable in signed 16-bit storage:

```text
(x + b) - (y + b) = x - y
```

The theorem is coefficient-wise over all 256 positions.

The harness also checks equality preservation and reflection:

```text
x + b = y + b    if and only if    x = y
```

This is an injectivity/cancellation property across two production executions.

### 5.2 Production calls

```text
left  := x
mlk_poly_add(&left, &b)

right := y
mlk_poly_add(&right, &b)
```

The target implementation is executed twice. No copied implementation or target stub computes either result.

### 5.3 Assumptions

For every coefficient `i`:

```text
INT16_MIN <= int32(x[i]) + int32(b[i]) <= INT16_MAX
INT16_MIN <= int32(y[i]) + int32(b[i]) <= INT16_MAX
```

The objects are valid and separately allocated. These are target-call admissibility conditions derived from the production contract. The relational theorem is not assumed.

Inputs are not restricted to canonical ML-KEM representatives. Negative and non-canonical signed values remain in scope whenever the exact sums are representable.

### 5.4 Semantic assertions

For each coefficient, the harness checks:

1. both production calls return;
2. the left result equals widened `x[i] + b[i]`;
3. the right result equals widened `y[i] + b[i]`;
4. the post-state difference equals the pre-state difference;
5. pre-state equality implies post-state equality; and
6. post-state equality implies pre-state equality.

Widened `int32_t` expressions are used for the oracle and difference comparisons so that the theorem does not rely on wrapped signed arithmetic.

### 5.5 Safety and implementation obligations

The proof also includes CBMC-generated records for:

- array bounds;
- pointer validity;
- pointer overflow;
- signed overflow;
- unsigned overflow;
- integer conversion;
- division by zero;
- undefined shifts;
- loop completeness; and
- unwinding assertions.

These records support the implementation-level validity of the selected proof model. They are not 42 separate mathematical theorem claims.

### 5.6 Reachability and non-vacuity

Four named coverage goals were satisfied:

1. assumptions feasible;
2. first target call reached;
3. second target call reached; and
4. final assertion block reached.

Coverage is supporting non-vacuity evidence and is not used as a replacement for universal proof.

### 5.7 Accepted result

```text
SA_ADD_T1_BUILD_EXIT                 0
SA_ADD_T1_PROOF_EXIT                 0
SA_ADD_T1_COVER_EXIT                 0
SA_ADD_T1_PROOF_PROPERTIES_SUCCESS   42
SA_ADD_T1_PROOF_PROPERTIES_FAILED    0
SA_ADD_T1_COVER_GOALS_SATISFIED      4
SA_ADD_T1_FINAL_STATUS               PASS
```

---

# Part II — SA-ADD-T2

## 6. SA-ADD-T2: arbitrary disjoint-support decomposition

### 6.1 Mathematical statement

For arbitrary valid `a` and `b`, the harness constructs two coefficient-wise disjoint parts `p` and `q` satisfying:

```text
p + q = b
```

Each coefficient of `b` is nondeterministically assigned to one part. The theorem compares:

```text
direct schedule: a + b
split schedule:  (a + p) + q
```

The selected claim is:

```text
a + b = (a + p) + q
```

for every support partition generated by the symbolic harness.

### 6.2 Partition construction

The harness constructs the partition rather than assuming it. It asserts:

```text
p[i] + q[i] = b[i]
```

and that at least one of `p[i]` or `q[i]` is zero at every coefficient. This prevents a circular proof based on assuming the desired decomposition.

### 6.3 Production calls

```text
direct := a
mlk_poly_add(&direct, &b)

split := a
mlk_poly_add(&split, &p)
mlk_poly_add(&split, &q)
```

Three real production calls are therefore checked.

### 6.4 Assumptions

For every coefficient, the exact final sum must fit in `int16_t`:

```text
INT16_MIN <= int32(a[i]) + int32(b[i]) <= INT16_MAX
```

The constructed split schedule is also kept within the legal target-call domain. All target operands are separate valid polynomial objects.

### 6.5 Semantic assertions

For every coefficient, the proof checks:

1. `p + q = b`;
2. the partition has disjoint support;
3. the direct schedule equals the widened exact sum;
4. the split schedule equals the widened exact sum;
5. the direct and split schedules are equal; and
6. all three production calls return.

The symbolic partition is stronger than checking one predetermined even/odd partition because each coefficient assignment is nondeterministic within the harness construction.

### 6.6 Safety obligations

The proof retains the same safety classes as T1:

- bounds;
- pointer and pointer-overflow checks;
- signed and unsigned overflow checks;
- conversion checks;
- division-by-zero checks;
- undefined-shift checks; and
- complete loop unwinding.

### 6.7 Reachability and non-vacuity

Five named cover goals were satisfied:

1. assumptions feasible;
2. direct call reached;
3. first split call reached;
4. second split call reached; and
5. final assertion block reached.

### 6.8 Accepted result

```text
SA_ADD_T2_BUILD_EXIT                 0
SA_ADD_T2_PROOF_EXIT                 0
SA_ADD_T2_COVER_EXIT                 0
SA_ADD_T2_PROOF_PROPERTIES_SUCCESS   48
SA_ADD_T2_PROOF_PROPERTIES_FAILED    0
SA_ADD_T2_COVER_GOALS_SATISFIED      5
SA_ADD_T2_FINAL_STATUS               PASS
```

---

## 7. Aggregate result

| Evidence item | SA-ADD-T1 | SA-ADD-T2 | Total |
|---|---:|---:|---:|
| Real production target calls | 2 | 3 | 5 |
| Successful proof-property records | 42 | 48 | 90 |
| Failed proof-property records | 0 | 0 | 0 |
| Satisfied named cover goals | 4 | 5 | 9 |
| Final status | PASS | PASS | PASS |

```text
RUNS OCCURED              1
Selected-claim mapping    YES
Target reachability       YES
Assertion reachability    YES
Assumption feasibility    YES
Evidence completeness     COMPLETE
Repository distinctness   SUPPORTED
Contamination             NONE KNOWN
```

---

## 8. JSON-framing repair

The fast execution wrapper emitted diagnostic text before the CBMC JSON array. CBMC itself returned zero, and the embedded property records were successful, but the stored file was not initially valid standalone JSON.

The accepted repair:

- isolated the original CBMC JSON document;
- verified every preserved property status;
- did not change any result status;
- did not change source, harness, assumptions, or assertions;
- did not rerun the solver; and
- recorded the operation as JSON-framing-only post-processing.

This was an evidence-serialization defect, not a mathematical counterexample or theorem failure.

---

## 9. Repository-relative novelty

### 9.1 Distinct artefacts

The experiment adds executable multi-execution verification artefacts for:

```text
SA-ADD-T1:
    (x + b) - (y + b) = x - y
    x + b = y + b  iff  x = y

SA-ADD-T2:
    a + b = (a + p) + q
    for arbitrary symbolic disjoint-support p + q = b
```

The repository-distinct components are:

- theorem selection and naming;
- two-call and three-call relational schedules;
- widened oracle bridges;
- symbolic partition construction;
- named feasibility and reachability goals;
- final assertion reachability;
- fail-closed execution logic;
- result summarisation;
- hashes and manifests; and
- the distinctness and contamination audit.

### 9.2 Novelty limit

The algebraic identities are not claimed as newly discovered mathematics. They follow from the native single-call contract plus ordinary integer algebra under the representability assumptions.

The correct contribution claim is therefore:

> The experiment produced repository-distinct executable relational CBMC artefacts and accepted evidence for selected multi-execution consequences that were not present as named selected claims or harnesses in the frozen `mlkem-native` repository.

This does not establish worldwide novelty or the absence of differently named or unpublished equivalent work.

### 9.3 Defensible comparison

At the frozen commit:

- upstream `poly_add_harness.c` contains one target call;
- the native contract establishes local exact addition under non-overflow;
- SA-ADD-T1 contains two related target executions and a relational difference/equality theorem;
- SA-ADD-T2 contains three related target executions and a symbolic decomposition theorem; and
- the skill-assisted package adds explicit non-vacuity, reachability, evidence-integrity, and repository-distinctness records.

---

## 10. What was proved

Within the frozen portable-C source and stated domain, the experiment proved:

- common-addend translation invariance;
- equality preservation and reflection under a common addend;
- equivalence of direct and arbitrary disjoint-support split addition;
- agreement of the selected schedules with widened integer arithmetic;
- target-call reachability;
- final-assertion reachability;
- assumption feasibility; and
- the recorded CBMC safety and unwinding obligations.

---

## 11. What was not proved

The experiment did not prove:

- defined behaviour when exact sums exceed `int16_t`;
- unsupported aliasing;
- native assembly backends;
- compiler-generated machine-code equivalence;
- side-channel or fault resistance;
- complete ML-KEM correctness;
- complete FIPS 203 compliance;
- every algebraic property of addition;
- all parameter sets or commits; or
- worldwide novelty.

---

## 12. Reproducibility boundary

A reproduction must preserve:

1. the frozen commit;
2. the source hashes;
3. ML-KEM-768 and `MLKEM_N = 256`;
4. the exact T1 and T2 harnesses;
5. the assumption and assertion sets;
6. the real production calls;
7. the widened arithmetic bridges;
8. the complete safety-check configuration;
9. complete loop unwinding;
10. separate proof and coverage evidence; and
11. the final manifests.

A changed source, harness, assumption, assertion, target schedule, parameter set, or backend is a new experiment.

---

## 13. Professor-ready conclusion

> On 17 July 2026, I completed a skill-assisted CBMC case study for the unchanged portable-C `mlk_poly_add` implementation at `mlkem-native` commit `d9613cf60de3132d32475c102d8c2781d84feb34`. SA-ADD-T1 verified common-addend translation invariance and equality preservation/reflection across two production executions. SA-ADD-T2 verified equivalence between direct addition and every harness-generated disjoint-support decomposition across three production executions. CBMC accepted all 90 generated proof-property records, and all nine named feasibility and reachability goals were satisfied. The contribution is a repository-distinct relational verification corpus, not new algebra, complete ML-KEM correctness, or worldwide novelty.

---

## 14. Source comparison references

- `https://github.com/pq-code-package/mlkem-native/blob/d9613cf60de3132d32475c102d8c2781d84feb34/mlkem/src/poly.c`
- `https://github.com/pq-code-package/mlkem-native/blob/d9613cf60de3132d32475c102d8c2781d84feb34/mlkem/src/poly.h`
- `https://github.com/pq-code-package/mlkem-native/blob/d9613cf60de3132d32475c102d8c2781d84feb34/proofs/cbmc/poly_add/poly_add_harness.c`

---

## 15. Date-integrity note

The experiment date is recorded as **17 July 2026**. Original evidence files, manifests, terminal logs, and filesystem metadata should retain their authentic provenance timestamps and must not be rewritten merely to force timestamp uniformity.
