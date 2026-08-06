Codex CLI 0.144.4 — GPT-5.6 sol — reasoning high

# Novelty and Distinctness Assessment Against mlkem-native

**Target:** `mlk_barrett_reduce`  
**Pinned comparison commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Assessment scope:** Public contents of the pinned upstream repository and the accepted experiment corpus  
**Overall classification:** **IN-CONCLUSIVE**

## 1. Assessment question

This assessment answers three separate questions:

1. Are the experiment’s theorem harnesses and formal obligations distinct from the pinned upstream Barrett proof?
2. Are the mathematical relationships themselves new discoveries?
3. Can a worldwide first-ever novelty claim be made?

These questions must not be collapsed into one.

## 2. What upstream already had

The pinned upstream repository already contained:

- the production `mlk_barrett_reduce` implementation;
- source documentation describing a centered representative congruent to the input modulo `MLKEM_Q`;
- an embedded function contract requiring the output to lie strictly between `-MLKEM_Q_HALF` and `MLKEM_Q_HALF`;
- a dedicated `proofs/cbmc/barrett_reduce` directory;
- a minimal nondeterministic harness making one target call; and
- a Makefile configured to check the production function contract and safety obligations.

Consequently, the following claim would be false:

> “The upstream repository had no formal proof for `mlk_barrett_reduce`.”

## 3. What the pinned upstream formal harness did not encode

The upstream Barrett harness at the pinned commit contains one symbolic input and one target call. It does not explicitly compare:

- `R(a)` with `R(-a)`;
- the quotient associated with `a` against the quotient associated with `-a`;
- `R(a)`, `R(b)`, and `R(R(a)+R(b))`;
- a reduced-operand sum against the full mathematical sum `a+b`;
- positive, negative, and zero correction branches;
- 41 exhaustive centered-residue intervals;
- named reachability goals; or
- exact expected-failure controls.

The embedded formal postcondition visible in `poly.c` checks the centered range. The source-level prose also states congruence, but the pinned contract shown in the source does not encode the campaign’s cross-call relational claims.

## 4. Repository-level distinctness finding

### SA-BR-T1

SA-BR-T1 is structurally distinct from the upstream Barrett harness because it uses two related target inputs and proves cross-execution equations:

```text
R(-a) = -R(a)
abs(R(-a)) = abs(R(a))
Q(-a) = -Q(a)
```

### SA-BR-T2

SA-BR-T2 is structurally distinct because it uses three production calls and proves a compositional law:

```text
R(R(a)+R(b)) = R(a)+R(b)-c×3329
c ∈ {-1,0,1}
```

It then links the result to the centered representative of the full mathematical sum through an exhaustive 41-case partition.

### Finding

```text
harness_distinctness_from_pinned_upstream=SUPPORTED
selected_claim_distinctness_from_pinned_upstream=SUPPORTED
production_source_novelty=NONE
```

The experiment did not create or modify the production Barrett implementation. Its contribution lies in the verification artefacts and selected relational obligations.

## 5. Mathematical novelty finding

The identities proved by SA-BR-T1 and SA-BR-T2 are natural consequences of centered modular reduction:

- oddness under sign conjugation;
- exact quotient sign reversal;
- preservation of congruence under addition;
- restoration of centered range by at most one correction after adding two centered representatives.

These relationships may be useful and nontrivial as implementation-level verification obligations. Their mathematical form, however, resembles standard modular-arithmetic consequences. The accepted campaign did not include an exhaustive mathematical-literature review establishing that these identities had never previously been stated or proved.

Finding:

```text
mathematical_first_ever_novelty=NOT_ESTABLISHED
classification=IN-CONCLUSIVE
```

## 6. Formal-verification novelty finding

The public pinned repository comparison supports a narrower claim:

> The exact SA-BR-T1 and SA-BR-T2 relational harness families, selected assertion names, reachability controls, negative controls, and division-free 41-case oracle were not present in the pinned upstream `proofs/cbmc/barrett_reduce` directory.

However, the assessment did not exhaustively inspect:

- every historical branch and deleted commit;
- every public or private fork;
- every issue and pull-request attachment;
- unpublished research artefacts;
- all CBMC projects derived from Kyber or ML-KEM;
- all formal-methods publications and supplementary repositories; or
- independently developed equivalent harnesses under different names.

Finding:

```text
new_to_pinned_repository=SUPPORTED
worldwide_formal_verification_first=NOT_ESTABLISHED
classification=IN-CONCLUSIVE
```

## 7. Methodological distinctness finding

The experiment added controls beyond the minimal upstream harness:

| Methodological element | Pinned upstream Barrett harness | Experiment |
|---|---:|---:|
| Multiple related target executions | No | Yes |
| Relational theorem assertions | No | Yes |
| Named assumption-feasibility witness | No | Yes |
| Named target-call witnesses | No | Yes |
| Named correction-branch witnesses | No | Yes |
| Exact expected-failure control | No | Yes |
| Independent full-sum oracle | No | Yes |
| Division-free exhaustive finite partition | No | Yes |
| Target-body binding record | Not expressed in the 17-line harness | Yes |
| Corpus-level SHA-256 manifest | Not part of the harness itself | Yes |

This supports methodological distinctness within the pinned-repository comparison. It does not establish that no other researcher has ever used similar controls.

## 8. Recommended thesis wording

### Strongest defensible wording

> Against mlkem-native commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`, the experiment introduced and discharged relational CBMC obligations for sign-conjugate Barrett reduction and centered addition after operand-wise reduction. These obligations were absent from the pinned upstream Barrett harness, which made a single unconstrained target call and relied on the embedded function contract. The result establishes repository-level verification distinctness, while broader claims of mathematical or worldwide methodological novelty remain inconclusive.

### Short wording

> The theorem harnesses are new to the pinned upstream Barrett proof corpus, but first-ever scientific novelty is not established.

### Classification sentence

> The formal verification outcome is PASS; the overall novelty classification is IN-CONCLUSIVE.

## 9. Wording that must be avoided

Do not write:

- “I discovered a new law of Barrett reduction.”
- “This is the first formal proof of Barrett reduction symmetry.”
- “No previous researcher has proved this.”
- “mlkem-native did not verify `mlk_barrett_reduce`.”
- “The experiment replaces or supersedes the upstream proof.”
- “The result is conclusively novel.”
- “The complete correctness of ML-KEM has been established.”

## 10. Final novelty matrix

| Novelty dimension | Result | Confidence basis |
|---|---|---|
| Different from pinned upstream one-call harness | **SUPPORTED** | Direct file comparison |
| Stronger relational obligations than pinned formal range contract | **SUPPORTED** | Direct contract and harness comparison |
| New production implementation | **NO** | Production source unchanged |
| New-to-pinned-repository proof artefacts | **SUPPORTED** | Repository-tree comparison |
| New mathematical identity | **NOT ESTABLISHED** | No exhaustive mathematical prior-art review |
| First-ever CBMC verification of equivalent claims | **NOT ESTABLISHED** | No exhaustive global corpus review |
| Independently replicated result | **NOT ESTABLISHED** | No independent replication recorded |
| Overall classification | **IN-CONCLUSIVE** | Required conservative synthesis |

# Final assessment

The accepted corpus establishes a technically meaningful extension of the pinned repository’s Barrett verification surface. It does not establish a new implementation or a worldwide first. The correct classification is:

# **IN-CONCLUSIVE**

## Sources compared

- Production source at the pinned commit:  
  https://github.com/pq-code-package/mlkem-native/blob/af4c5abdd5958bdc65a03cd5ee86708264f93304/mlkem/src/poly.c

- Pinned upstream Barrett harness:  
  https://github.com/pq-code-package/mlkem-native/blob/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc/barrett_reduce/barrett_reduce_harness.c

- Pinned upstream Barrett Makefile:  
  https://github.com/pq-code-package/mlkem-native/blob/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc/barrett_reduce/Makefile

- Pinned upstream CBMC proof overview:  
  https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc

- Authoritative commit:  
  https://github.com/pq-code-package/mlkem-native/commit/af4c5abdd5958bdc65a03cd5ee86708264f93304
