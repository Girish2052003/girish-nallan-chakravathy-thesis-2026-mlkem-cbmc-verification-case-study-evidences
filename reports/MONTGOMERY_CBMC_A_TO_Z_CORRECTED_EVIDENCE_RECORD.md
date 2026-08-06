# Montgomery-Domain CBMC Campaign for `mlkem-native`
## Corrected A-to-Z Technical, Evidentiary, and Novelty Record

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Document status:** Evidence-reconciled research record  
**Prepared for:** MSc thesis supervision and case-study documentation  
**Repository:** `pq-code-package/mlkem-native`  
**Pinned commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Primary source file:** `mlkem/src/poly.c`  
**Primary verified target:** `mlk_montgomery_reduce`  
**Candidate companion targets:** `mlk_fqmul`, `mlk_poly_tomont_c`  
**Verification tool:** CBMC 6.9.0  
**Record date:** 27 July 2026  

---

# 1. Executive truth statement

This record documents the Montgomery-domain verification work performed against the pinned `mlkem-native` commit. It supersedes every earlier informal summary that described all four theorem campaigns as completed CBMC proofs.

The final evidence-based status is:

| Campaign | Target | Purpose | Final defensible status |
|---|---|---|---|
| **MONT-T1** | `mlk_montgomery_reduce` | Single-call exact functional refinement over the complete source-contract domain | **Verified by CBMC** |
| **MONT-T2** | `mlk_montgomery_reduce` | Relational and low-word-fibre laws across multiple calls | **Computationally inconclusive** |
| **MONT-T3** | `mlk_fqmul` | Normalized Montgomery-multiplication algebra | **Computationally inconclusive** |
| **MONT-T4** | `mlk_poly_tomont_c` | Polynomial-level round trip, residue equivalence, zero support, and coefficient locality | **Computationally inconclusive** |

The corrected campaign status is therefore:

```text
MONT-T1 = VERIFIED
MONT-T2 = COMPUTATIONALLY INCONCLUSIVE
MONT-T3 = COMPUTATIONALLY INCONCLUSIVE
MONT-T4 = COMPUTATIONALLY INCONCLUSIVE

OVERALL STATUS =
PARTIALLY VERIFIED WITH STRONG UNRESOLVED CANDIDATE THEOREMS
```

Only MONT-T1 produced authentic CBMC evidence containing:

```text
VERIFICATION SUCCESSFUL
```

together with:

```text
CBMC return code 0
all 12 required named assertions reported SUCCESS
no missing required assertion
no failed baseline assertion
a genuine expected-failure non-vacuity control
three targeted source mutations rejected
source and commit integrity preserved
a SHA-256-bound terminal capture
```

MONT-T2, MONT-T3, and MONT-T4 did not return either a completed proof marker or a counterexample before the available executions were terminated or exceeded the practical execution period. They are therefore neither proved nor disproved.

The correct interpretation is:

> No counterexample was returned before termination, but CBMC did not complete the proof. The result is computationally inconclusive and provides no conclusive evidence that the theorem is true or false.

The approximately eight-hour duration recorded for each of T2–T4 is a runtime observation without independent timestamp support. It should be presented as an exact measured duration only where authentic process timestamps or logs support the value.

---

# 2. Mandatory evidence-integrity correction

During the development sequence, terminal-style success summaries for MONT-T2, MONT-T3, and MONT-T4 were manually supplied rather than emitted by completed CBMC executions.

Those summaries have no status as formal-verification evidence.

Consequently:

1. All manually supplied or synthetic `PASS`, `ACCEPTED`, `VERIFIED`, mutation-pass, non-vacuity-pass, safety-pass, and unwinding-pass markers for T2–T4 are excluded.
2. A later script that searches for one of those markers does not transform it into authentic tool evidence.
3. A SHA-256 digest proves the integrity of a byte sequence, not the truth or origin of the statements inside that byte sequence.
4. Only raw evidence containing the actual command, tool output, exit status, named property results, verifier footer, and surrounding diagnostic context may support a verification claim.
5. For T2–T4, the retained research value consists of the theorem definitions, harness designs, source-overlap analysis, proof attempts, and scalability observations.
6. No final archive may place the synthetic summaries in an `accepted-proof` category.
7. Any retained synthetic summary must be explicitly classified as invalid or excluded evidence.

This correction is central to the thesis. It distinguishes:

```text
property discovery
harness construction
proof attempt
completed machine proof
counterexample
computationally inconclusive execution
invalid success summary without verifier provenance
```

The case study is strengthened, not weakened, by making this distinction explicit.

---

# 3. Frozen technical baseline

## 3.1 Repository and source binding

The campaign was bound to:

```text
Repository path:
/home/girish/THESIS-2026/mlkem-native_af4c5abd

Commit:
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

The principal source files were frozen as:

```text
mlkem/src/poly.h
f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef

mlkem/src/poly.c
f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722
```

The authoritative repository remained clean. Experimental harnesses and mutations were placed in proof directories or detached worktrees. The baseline production body was not altered to obtain the T1 result.

## 3.2 Toolchain snapshot

The captured environment included:

```text
CBMC:        6.9.0
goto-cc:     6.9.0
GCC:         13.3.0
GNU Make:    4.3
Architecture: x86_64
Operating system: Linux
```

These versions form part of the result boundary. A proof obtained for this exact source and machine model is not automatically transferable to another source revision, architecture, compiler interpretation, or CBMC release.

## 3.3 Arithmetic constants

```text
q = 3329
R = 2^16 = 65536
QINV unsigned modulo R = 62209
QINV as signed int16 = -3327
R mod q = 2285
R^2 mod q = 1353
MLKEM_N = 256
```

The implementation uses Montgomery arithmetic to represent modular products efficiently while controlling C integer ranges.

---

# 4. Implementation semantics

## 4.1 `mlk_montgomery_reduce`

At the mathematical level, `mlk_montgomery_reduce(a)` returns a signed 16-bit representative congruent to:

```text
a · R^-1 mod q
```

with `R = 65536`.

Its implementation:

1. obtains the low 16-bit representation of `a`;
2. multiplies that low word by `QINV`;
3. converts the result to a signed 16-bit witness `t`;
4. forms:

   ```text
   a - t·q
   ```

5. divides the exactly divisible numerator by `R`, implemented through a right shift by 16.

The exact decomposition is:

```text
a = R·r + q·t
```

where:

```text
r = mlk_montgomery_reduce(a)
t = signed Montgomery witness
```

## 4.2 Complete source-contract domain

The pinned source contract requires:

```c
a <  INT32_MAX - 2^15·q
a > -(INT32_MAX - 2^15·q)
```

For `q = 3329`:

```text
INT32_MAX - 2^15·q = 2,038,398,975
```

Because both inequalities are strict, the exact legal integer interval is:

```text
-2,038,398,974 ≤ a ≤ 2,038,398,974
```

The domain contains:

```text
4,076,797,949
```

integer inputs.

An earlier narrow-domain expectation based on approximately `q·2^15` was rejected. T1 deliberately used the much larger complete source-contract domain.

## 4.3 Sharp output image

The independently constructed arithmetic census found:

```text
exact output minimum = -32767
exact output maximum =  32767
```

Concrete legal witnesses are:

```text
mlk_montgomery_reduce(-2,038,363,401) = -32767
mlk_montgomery_reduce( 2,038,366,730) =  32767
```

The interval:

```text
[-3328, 3328]
```

would therefore be false over the complete source-contract domain.

## 4.4 Portability assumption

The implementation relies on a sign-preserving arithmetic right shift for negative signed values.

The proof result is conditional on the captured C/CBMC machine interpretation of that operation. T1 does not establish the same statement for every conceivable C implementation with a different signed-right-shift behaviour.

---

# 5. Verification methodology

## 5.1 Clean-room construction

The campaign applied the following controls:

```text
commit freezing
source hashing
detached experimental worktrees
production-source non-modification
actual target-body execution
independent mathematical oracle
explicit assumptions and assertions
false controls for non-vacuity
targeted source mutations
raw terminal capture
SHA-256 manifests
```

The aim was not to produce a green screen at any cost. The aim was to differentiate:

```text
proof
counterexample
timeout
build failure
tool failure
vacuous success
mutation survival
mutation rejection
source modification
```

## 5.2 Independent oracle

T1 did not compare the implementation against a duplicated copy of the implementation.

The independent oracle was conceptually:

```c
low = ((uint32_t)a) & 0xffff;
raw_t = (low * 62209) % 65536;
t = signed_representative(raw_t);
oracle = (a - t * 3329) / 65536;
```

The calculation used wider arithmetic and explicitly asserted exact divisibility.

The real function body was then compared with the independently calculated oracle value.

## 5.3 Why this is not tautological

A tautological harness would use the same implementation expression on both sides of an assertion. T1 instead used:

- a separately written low-word model;
- a separately written signed conversion;
- 64-bit intermediate arithmetic;
- an independently calculated witness;
- explicit divisibility;
- exact result comparison.

The oracle and the C implementation could therefore disagree if the source used the wrong inverse, sign, shift, or reconstruction operation.

## 5.4 Relational property design

T2–T4 intentionally moved beyond a single target call:

```text
T2: multiple scalar reduction calls
T3: multiple normalized multiplication calls
T4: multiple complete polynomial conversion executions
```

This increases the solver burden because symbolic state and arithmetic are duplicated and related by modular or conditional predicates.

## 5.5 Interpretation of CBMC outcomes

| Observation | Classification |
|---|---|
| Return code `0`, required assertions `SUCCESS`, `VERIFICATION SUCCESSFUL` | Verified selected obligations |
| Return code `10`, named assertion `FAILURE`, `VERIFICATION FAILED` | Counterexample or expected mutation/control rejection |
| Return code `124` | Timeout; inconclusive |
| Process still running without final footer | Pending/inconclusive |
| Compile or GOTO error | Tool/build failure |
| Success marker without verifier provenance | Not evidence |

“No counterexample was observed” is not equivalent to “the theorem was proved” or “the theorem is likely true.”

---

# 6. Why four theorem families were chosen

The four campaigns represent four semantic layers:

| Layer | Campaign | Question |
|---|---|---|
| 1 | T1 | Does one call exactly implement an independent reduction model? |
| 2 | T2 | How do several reduction results relate across residues and low-word fibres? |
| 3 | T3 | Does reduction compose correctly inside Montgomery multiplication algebra? |
| 4 | T4 | Does scalar arithmetic lift correctly into the real 256-coefficient polynomial conversion loop? |

The progression was:

```text
single-call exact refinement
→ relational scalar behaviour
→ compositional scalar algebra
→ vector-level implementation behaviour
```

Four is not a mathematically mandatory number. It was a deliberate case-study boundary.

Stopping at T1 would cover only isolated scalar reduction.

Stopping at T2 would omit multiplication composition.

Stopping at T3 would omit the real polynomial loop, in-place data transformation, coefficient indexing, and cross-talk risks.

Extending beyond T4 would move toward NTT-level or complete ML-KEM correctness and exceed the intended bounded MSc case-study scope.

The registry contained:

```text
T1: 5 core claims
T2: 5 core claims
T3: 6 core claims
T4: 5 core claims
Total: 21 candidate core claims
```

Only the five T1 core claims are established by completed CBMC evidence.

---

# 7. MONT-T1: verified exact scalar refinement

## 7.1 Purpose

T1 examined whether the actual pinned `mlk_montgomery_reduce` body exactly implements an independently constructed mathematical model over the complete legal input domain.

It was stronger than a memory-safety or output-bound-only check.

## 7.2 T1-P1: independent oracle equality

For every legal `a`:

```text
mlk_montgomery_reduce(a) = oracle(a)
```

## 7.3 T1-P2: exact reconstruction and modular congruence

For implementation result `r` and independent witness `t`:

```text
a = R·r + q·t
```

Therefore:

```text
R·r ≡ a (mod q)
r ≡ a·R^-1 (mod q)
```

## 7.4 T1-P3: uniqueness of signed-16 decomposition

For any alternative signed-16 pair `(r', t')` satisfying:

```text
a = R·r' + q·t'
```

the harness establishes:

```text
r' = r
t' = t
```

within the modeled signed-16 domain.

## 7.5 T1-P4: universal sharp bound

For all legal inputs:

```text
-32767 ≤ r ≤ 32767
```

## 7.6 T1-P5: endpoint attainability

The proof contains concrete legal inputs reaching both endpoints. The interval is therefore sharp rather than merely conservative.

## 7.7 Audited assertions

The authentic baseline contained all 12 required assertions:

```text
MONT-T1.ORACLE.low_word_normalized
MONT-T1.P2.oracle_numerator_exactly_divisible_by_R
MONT-T1.P2.oracle_witness_is_signed16
MONT-T1.P1.oracle_result_fits_int16
MONT-T1.P1.full_domain_exact_oracle_equality
MONT-T1.P2.exact_signed_witness_reconstruction
MONT-T1.P2.scaled_modular_congruence_divisibility
MONT-T1.P3.unique_result_in_signed16_decomposition
MONT-T1.P3.unique_witness_in_signed16_decomposition
MONT-T1.P4.full_contract_domain_sharp_output_bound
MONT-T1.P5.minimum_output_is_attainable
MONT-T1.P5.maximum_output_is_attainable
```

The raw audit recorded:

```text
BASELINE_DIRECT_RC=0
BASELINE_SUCCESS_MARKER=YES
BASELINE_FAILURE_MARKER=NO
BASELINE_ERROR_MARKER=NO
BASELINE_FAILURE_LINE_COUNT=0
BASELINE_REQUIRED_ASSERTION_COUNT=12
BASELINE_MISSING_REQUIRED_COUNT=0
BASELINE_REVALIDATION=PASS
VERIFICATION SUCCESSFUL
```

## 7.8 Non-vacuity

A false-control execution established reachability:

```text
FALSE_CONTROL_DIRECT_CBMC_RC=10
FALSE_CONTROL_AUDIT=PASS
MONT_T1_NONVACUITY=PASS
```

The expected false assertion failed, demonstrating that the assumptions did not silently eliminate the path.

## 7.9 Mutation sensitivity

Three isolated source mutations were rejected:

### M1: Montgomery inverse mutation

```text
QINV → QINV + 1
```

### M2: reconstruction-sign mutation

```text
a - t·q
```

was changed to:

```text
a + t·q
```

### M3: shift mutation

```text
>> 16
```

was changed to:

```text
>> 15
```

The final authentic result was:

```text
MUTANT_TOTAL_COUNT=3
MUTANT_EXPECTED_REJECTION_COUNT=3
MONT_T1_MUTATION_SENSITIVITY=PASS_3_OF_3
```

Mutation rejection is supporting evidence that the assertions detect meaningful source defects. It is not a substitute for the completed baseline proof.

## 7.10 Authentic T1 evidence

```text
Capture:
/home/girish/THESIS-2026/mlk_montgomery_cleanroom/
MONT01B_R1_M2_M3_20260726T151104Z/
MONT01B_R1_TERMINAL_CAPTURE_20260726T151104Z.txt

SHA-256:
866ba00a16a8d46595c4abe04456f7f3360600ac0c34ad826a34741c035b8813
```

Final authentic markers:

```text
MONT01B_R1_MUTATION_GATE=PASS
MONT_T1_BASELINE_RESULT=VERIFICATION_SUCCESSFUL
MONT_T1_NONVACUITY=PASS
MONT_T1_MUTATION_SENSITIVITY=PASS_3_OF_3
MONT_T1_SOURCE_BINDING=PASS
MONT_T1_STATUS=ACCEPTED_FOR_PINNED_COMMIT
FINAL_PRODUCTION_SOURCE_INTEGRITY=PASS
SCRIPT_EXIT=0
```

## 7.11 Exact T1 conclusion

The supported conclusion is:

> At the pinned `mlkem-native` commit, under the captured CBMC machine model, complete source-contract assumptions, and arithmetic-right-shift assumption, CBMC verified that the actual `mlk_montgomery_reduce` body equals an independent exact oracle over its full legal input domain, satisfies the exact reconstruction and modular relations, admits a unique signed-16 decomposition, and has the sharp output image `[-32767,32767]`.

This proves the stated T1 properties. It does not prove every property of Montgomery arithmetic or ML-KEM.

---

# 8. MONT-T2: relational reduction candidates

## 8.1 Purpose

T1 examines one call. T2 was designed to examine relationships across several calls to `mlk_montgomery_reduce`.

## 8.2 Final T2 candidate properties

### T2-P1: canonical low-word normalization

The independently normalized low words lie in:

```text
[0, 65535]
```

### T2-P2: relational scaled-residue law

For arbitrary legal `a` and `b`:

```text
(reduce(b) - reduce(a))·R ≡ b - a (mod q)
```

### T2-P3: exact equal-low-word affine law

If `a` and `b` have the same canonical low 16 bits:

```text
b - a is divisible by R
```

and:

```text
reduce(b) - reduce(a) = (b - a)/R
```

### T2-P4: injectivity inside a low-word fibre

Under the equal-low-word premise:

```text
reduce(a) = reduce(b)  iff  a = b
```

### T2-P5: general fibre translation

For every integer `k` for which both inputs remain legal:

```text
reduce(a + k·R) = reduce(a) + k
```

## 8.3 Why T2 is stronger than T1 computationally

T2 introduces:

```text
multiple independent 32-bit values
multiple real target calls
difference arithmetic
modular relational assertions
conditional fibre paths
a symbolic translation value
complete source-contract constraints
```

## 8.4 Actual T2 outcome

T2 did not produce an authentic completed proof marker and did not produce a counterexample before termination.

```text
MONT-T2 = COMPUTATIONALLY INCONCLUSIVE
```

The T2 theorem family is retained as a technically strong candidate design.

It must not be described as:

```text
passed
verified
accepted
mutation-validated
proved because no counterexample appeared
```

The thesis-safe statement is:

> A full-domain relational CBMC harness was designed for low-word-fibre and affine-translation laws of `mlk_montgomery_reduce`. The execution did not complete and returned neither a proof marker nor a counterexample; the candidate therefore remains unresolved.

---

# 9. MONT-T3: normalized Montgomery multiplication candidates

## 9.1 Target

```c
mlk_fqmul(a, b)
```

The implementation calculates:

```c
mlk_montgomery_reduce((int32_t)a * (int32_t)b)
```

The relevant source boundary permits:

```text
first operand: arbitrary int16_t
second operand: signed canonical, approximately -1664..1664
result bound: absolute value below q
```

## 9.2 T3 candidate properties

### T3-P1: independent multiplication refinement

The implementation should agree modulo `q` with an independent Montgomery-product model.

### T3-P2: normalized commutativity

```text
fqmul(a,b) = fqmul(b,a)
```

under the frozen canonical conditions or after canonical residue normalization.

### T3-P3: zero annihilation and reflection

```text
fqmul(a,0) = 0
fqmul(0,b) = 0
```

plus a normalized zero-product reflection condition.

### T3-P4: Montgomery-one identity

Because:

```text
R mod q = 2285
```

the Montgomery representation of one should behave as an identity after normalization.

### T3-P5: normalized distributivity

Montgomery multiplication should distribute over normalized modular addition.

### T3-P6: normalized associativity

Repeated normalized products should agree under reassociation.

## 9.3 Canonicalization assumption

C may produce negative remainders for negative operands. The harness design used:

```c
r = x % q;
if (r < 0) r += q;
```

to compare canonical residue representatives.

## 9.4 Actual T3 outcome

T3 did not produce an authentic completed proof result and did not produce a counterexample before termination.

```text
MONT-T3 = COMPUTATIONALLY INCONCLUSIVE
```

The six properties are candidate theorem families, not established results.

T3 provides no additional completed proof of `mlk_montgomery_reduce`. It invokes that reduction through `mlk_fqmul`, but the T3 execution itself did not complete.

---

# 10. MONT-T4: polynomial Montgomery-conversion candidates

## 10.1 Correct target name

T4 targets:

```c
mlk_poly_tomont_c(mlk_poly *r)
```

It does not target a function named:

```text
poly_montgomery_reduce
```

The thesis must not state:

> `poly_montgomery_reduce` was proved.

The correct description is:

> A polynomial-level theorem suite was designed for the portable-C `mlk_poly_tomont_c` conversion, but its CBMC execution remained computationally inconclusive.

## 10.2 Source operation

The function uses:

```text
f = 1353 = R^2 mod q
```

and, for each coefficient:

```c
r->coeffs[i] = mlk_fqmul(r->coeffs[i], f);
```

for:

```text
i = 0..255
```

## 10.3 T4 candidate properties

### T4-P1: de-Montgomery round trip

After conversion, reducing a converted coefficient out of Montgomery form should recover the original residue modulo `q`.

### T4-P2: residue-vector equivalence preservation

Coefficientwise residue-equivalent input polynomials should produce coefficientwise residue-equivalent converted polynomials.

### T4-P3: residue-vector equivalence reflection

Coefficientwise residue-equivalent converted outputs should imply coefficientwise residue-equivalent original inputs.

### T4-P4: zero-support preservation

For each coefficient:

```text
converted coefficient = 0 mod q
iff
input coefficient = 0 mod q
```

### T4-P5: coefficient locality and no cross-talk

If two inputs agree at coefficient `k`, their converted outputs at `k` should agree regardless of every unrelated coefficient.

This property detects indexing errors such as using coefficient `k+1` instead of `k`.

## 10.4 Supporting forward conversion law

```text
T(A)[i] ≡ A[i]·R (mod q)
```

was treated only as a supporting lemma.

It cannot be the headline novelty because the repository’s HOL Light work already covers coefficientwise Montgomery conversion congruence and a bound for optimized assembly implementations.

## 10.5 Actual T4 outcome

T4 did not produce an authentic completed proof marker and did not produce a counterexample before termination.

```text
MONT-T4 = COMPUTATIONALLY INCONCLUSIVE
```

The manually supplied T4 functional, shard, safety, non-vacuity, and mutation success markers are excluded.

No claim that the portable-C polynomial conversion was proved is supportable from those markers.

---

# 11. Why T4 was necessary after T3

T3 is scalar. Even a successful T3 proof would not automatically prove the real polynomial loop.

T3 cannot establish:

1. that all 256 coefficients are visited;
2. that each coefficient is updated exactly once;
3. that coefficient `i` is used rather than `i+1`;
4. that in-place updates do not interfere with subsequent iterations;
5. that unrelated coefficients cannot affect the selected output coefficient;
6. polynomial-level residue preservation;
7. residue-vector injectivity;
8. zero-support preservation at the data-structure level.

T4 was therefore designed to bridge:

```text
scalar arithmetic correctness
```

to:

```text
correct use of scalar arithmetic in the actual portable-C
polynomial representation conversion
```

Its inconclusive outcome does not make the design unnecessary. It identifies a solver-scaling boundary between scalar functional refinement and relational vector verification.

---

# 12. Direct answers to the main proof questions

## 12.1 Did the campaign prove `mlk_montgomery_reduce`?

**Yes, for the five T1 core properties under the exact recorded assumptions and pinned commit.**

## 12.2 Did T2 prove additional properties of `mlk_montgomery_reduce`?

**No completed proof.**

T2 is unresolved because the relational execution did not complete.

## 12.3 Did T3 prove `mlk_fqmul` algebra?

**No.**

The T3 properties remain computationally inconclusive candidates.

## 12.4 Did T4 prove polynomial Montgomery conversion?

**No.**

The T4 properties remain computationally inconclusive candidates.

## 12.5 Did the campaign prove “polynomial Montgomery reduction”?

**No.**

The actual target was `mlk_poly_tomont_c`, which converts a polynomial into Montgomery representation.

## 12.6 Did the campaign prove all Montgomery arithmetic in ML-KEM?

**No.**

The completed result is function-specific, property-specific, source-specific, assumption-specific, and tool-model-specific.

## 12.7 Did the campaign prove complete ML-KEM correctness?

**No.**

It does not establish complete key generation, encapsulation, decapsulation, decryption-failure probability, IND-CCA security, constant-time behaviour, all assembly backends, or complete NTT correctness.

---

# 13. Distinction from the native `mlkem-native` proofs

## 13.1 Existing repository verification

The repository already contains CBMC proof directories for functions including:

```text
mlk_montgomery_reduce
mlk_fqmul
mlk_poly_tomont_c
mlk_poly_tomont
```

It is therefore false to claim:

> No CBMC verification existed.

The repository states that its C proofs target absence of selected undefined behaviour, memory safety, type safety, contracts, and loop invariants.

It also states that the CBMC harnesses are boilerplate and that specifications are embedded in the C source.

Optimized assembly functional correctness is handled separately with HOL Light.

## 13.2 Native reduction harness

The native harness is essentially:

```c
int32_t a;
int16_t r;

r = mlk_montgomery_reduce(a);
```

It does not independently add:

```text
full-domain mathematical oracle equality
exact reconstruction
uniqueness
sharp complete output image
endpoint witnesses
relational calls
false controls
targeted mutations
```

## 13.3 Native `fqmul` harness

The native `fqmul` harness calls the function and relies on the source contract. It does not encode the six normalized algebraic T3 candidates.

## 13.4 Native portable-C `poly_tomont` harness

The captured native harness performs the target call but does not add the T4 relational round-trip and locality assertions.

## 13.5 Supported repository-distinctness statement

The strongest supported statement is:

> The custom T1 package is repository-distinct from the pinned native CBMC harness because it executes the actual production body while adding an independent full-domain functional oracle, exact decomposition and uniqueness properties, a sharp output-image theorem, endpoint witnesses, a non-vacuity control, and targeted mutation sensitivity.

For T2–T4:

> The candidate harness designs are structurally and semantically broader than the inspected native boilerplate harnesses, but the candidate properties were not established by completed CBMC runs.

---

# 14. Assumptions and trusted boundary

## 14.1 Explicit assumptions

T1 depends on:

- the exact pinned source commit;
- the source hashes;
- the captured CBMC 6.9.0 model;
- 16-bit `int16_t`;
- 32-bit `int32_t`;
- the exact source-contract domain;
- arithmetic signed right shift;
- the independent oracle being correctly encoded;
- target-body inclusion;
- satisfiable assumptions;
- correct CBMC translation and solving;
- trustworthy evidence capture and hashing.

## 14.2 Trusted computing base

```text
CBMC
goto-cc
preprocessor/compiler model
host OS and filesystem
proof scripts
independent oracle code
SHA-256 implementation
documented evidence review
```

## 14.3 Properties not covered

T1 does not establish:

```text
constant-time execution
power leakage resistance
electromagnetic leakage resistance
fault-injection resistance
microarchitectural security
compiler preservation of constant-time behaviour
correctness of every assembly backend
complete NTT correctness
complete ML-KEM correctness
cryptographic IND-CCA security
```

## 14.4 Bounded-model-checking boundary

A completed CBMC result is only as strong as:

```text
the selected properties
assumptions
machine model
function-body inclusion
loop bounds
enabled checks
environment model
```

For T2–T4, non-completion is a scalability result, not a theorem result.

---

# 15. Novelty and distinctness assessment

## 15.1 Review scope

A targeted novelty review covered:

1. the pinned `mlkem-native` source and proof tree;
2. its CBMC README and native harness structure;
3. its HOL Light verification boundary;
4. NIST FIPS 203;
5. formally verified Kyber implementations in EasyCrypt/Jasmin;
6. machine-checked ML-KEM correctness and security in EasyCrypt;
7. later hybrid deductive/circuit verification of optimized ML-KEM;
8. hax/F* verification of Rust ML-KEM arithmetic and higher-level code.

This was a targeted review, not a complete systematic review of every paper, thesis, unpublished artifact, repository branch, or private result.

## 15.2 Prior work that prevents an unqualified novelty claim

Prior work already includes:

- formally verified Kyber implementations in Jasmin;
- machine-checked functional correctness against EasyCrypt specifications;
- formally verified ML-KEM correctness and IND-CCA security;
- verified high-performance ML-KEM implementations;
- `mlkem-native` CBMC verification of C memory/type safety;
- `mlkem-native` HOL Light functional verification of optimized assembly;
- hax/F* verification of ML-KEM arithmetic and higher-level Rust code.

Therefore, none of the following may be claimed:

```text
first formal verification of Montgomery reduction
first formal verification of Kyber arithmetic
first verified ML-KEM implementation
first proof of conversion to Montgomery form
new Montgomery mathematics
first proof of ML-KEM correctness
```

## 15.3 Repository-level novelty

The exact T1 property package was not identified in the pinned native CBMC harness.

The distinct combination is:

```text
complete source-contract-domain oracle equality
exact signed decomposition
uniqueness over signed-16 pairs
sharp complete output image
concrete endpoint witnesses
non-vacuity
three targeted implementation mutations
source/commit evidence binding
```

This supports **repository-level harness and property distinctness**.

## 15.4 Mathematical novelty

The identities:

```text
a = R·r + q·t
r ≡ a·R^-1 mod q
```

are established consequences of Montgomery arithmetic and are not new mathematical inventions.

The exact sharp interval and endpoint witnesses are implementation- and contract-specific results for the pinned source body. They should not be presented as new number theory.

## 15.5 Research-contribution novelty

A targeted search did not identify an exact prior match for the complete T1 CBMC package over this pinned portable-C body.

This supports:

> an implementation-specific, repository-distinct CBMC verification contribution.

It does not prove:

> a world-first result.

Failure to find an exact match is not proof that no match exists anywhere.

## 15.6 T2–T4 novelty potential

T2–T4 appear repository-distinct and technically nontrivial as **candidate theorem and harness designs**.

However:

```text
unproved candidate ≠ novel verified result
```

Their defensible novelty description is:

> strong candidate property suites with repository-level distinctness and research novelty potential, whose verification remained computationally inconclusive.

## 15.7 Novelty ladder

| Novelty level | T1 | T2–T4 |
|---|---|---|
| Structurally different harness from native CBMC harness | **Supported** | **Supported by design census** |
| Different semantic property package | **Supported** | **Supported as candidate design** |
| Verified implementation-specific contribution | **Supported** | **Not established** |
| New mathematical identity | **Not claimed** | **Not claimed** |
| First result in all literature | **Not established** | **Not established** |
| Peer-reviewed novelty | **Not yet established** | **Not established** |

## 15.8 Thesis-safe novelty wording

> The verified contribution is an implementation-specific, repository-distinct CBMC functional harness for `mlk_montgomery_reduce` at the pinned `mlkem-native` commit. It strengthens the repository’s native contract-oriented CBMC harness by independently establishing exact full-domain refinement, decomposition uniqueness, a sharp output image, endpoint attainability, non-vacuity, and mutation sensitivity. A targeted review did not identify the same complete CBMC property package in the examined sources; however, this does not establish world-first mathematical novelty. T2–T4 are reported as strong candidate theorem families whose verification remained computationally inconclusive.

---

# 16. Supported and unsupported thesis claims

## 16.1 Supported

- T1 was verified by CBMC for the pinned commit.
- The actual `mlk_montgomery_reduce` body executed.
- The complete source-contract domain was used.
- T1 established independent-oracle equality.
- T1 established exact reconstruction and modular congruence.
- T1 established uniqueness of the signed-16 decomposition.
- T1 established the sharp output interval and endpoint attainability.
- T1 passed a genuine non-vacuity control.
- T1 rejected three targeted implementation mutations.
- The T1 property package is distinct from the native boilerplate harness.
- T2–T4 are strong candidate theorem families.
- T2–T4 were attempted and remained computationally inconclusive.
- T4 addresses vector-level implementation questions absent from scalar T3.
- The campaign reveals a scalability boundary for stronger relational CBMC obligations.
- The evidence-integrity incident motivates a deterministic evidence firewall.

## 16.2 Unsupported

- T2, T3, or T4 passed.
- All 21 claims were proved.
- No counterexample implies likely correctness.
- T2–T4 mutation sensitivity was established.
- T2–T4 non-vacuity was established.
- T2–T4 safety/unwinding was established from synthetic summaries.
- `poly_montgomery_reduce` was proved.
- All Montgomery arithmetic was proved.
- Complete ML-KEM was proved.
- The result is the first formal proof of Montgomery reduction.
- The four theorem families are globally novel mathematics.
- A hash-bound marker without verifier provenance is CBMC evidence.

---

# 17. Research value of the inconclusive campaigns

T2–T4 remain valuable because they document:

## 17.1 Property-strength progression

```text
tractable single-call theorem
→ difficult relational scalar theorem
→ difficult algebraic composition theorem
→ difficult relational vector theorem
```

## 17.2 Solver-scaling boundary

The likely complexity drivers include:

```text
duplicated symbolic executions
full-width integer domains
modular arithmetic
canonicalization
conditional relational premises
complete 256-coefficient loops
in-place vector state
```

## 17.3 Documented review controls and integrity firewall

The evidence incident demonstrates that an automated verification pipeline cannot trust text merely because it resembles terminal output.

A deterministic evidence firewall should require:

```text
raw tool command
real exit status
verifier footer
named property lines
tool-error scan
process timestamps
source hash
GOTO hash
capture hash
provenance classification
```

## 17.4 Future proof strategies

The unresolved candidates may be revisited using:

- compositional verified lemmas;
- stronger verified contracts;
- proof reuse from T1;
- theorem-preserving property decomposition;
- solver-specific encodings;
- deductive verification;
- EasyCrypt, F*, HOL Light, Coq, or another proof assistant;
- additional computational resources;
- carefully justified abstraction;
- equivalence proofs between smaller models and the C implementation.

Any reduced domain, deleted premise, or simplified assertion must be reported as a different theorem.

---

# 18. Evidence classification

## 18.1 Authoritative T1 evidence

```text
Class A: authentic machine-proof evidence
```

Includes:

```text
raw CBMC baseline output
VERIFICATION SUCCESSFUL
12/12 required assertions
return code 0
non-vacuity control
three authentic mutation rejections
source/commit integrity
capture SHA-256
```

## 18.2 T2–T4 authentic attempt evidence

```text
Class C: authentic timeout/resource evidence
Class D: theorem and harness design artefacts
```

May include:

```text
theorem registries
harness source
Makefiles
GOTO binaries
real process-status output
real timeout logs
resource snapshots
source-overlap captures
source and commit hashes
```

## 18.3 Excluded evidence

```text
Class E: invalid or synthetic summary
```

Includes:

```text
manually supplied T2–T4 PASS markers
manually supplied acceptance markers
derived acceptance files that rely only on those markers
```

No Class E file may support a thesis result claim.

---

# 19. Final conclusion

The Montgomery-domain campaign produced one completed formal-verification result and three unresolved candidate campaigns.

The completed result is MONT-T1:

> The actual portable-C `mlk_montgomery_reduce` body at commit `af4c5abd...` was verified by CBMC against an independent exact oracle over the complete source-contract domain. The proof established exact reconstruction, modular congruence, uniqueness of the signed-16 decomposition, the sharp output interval `[-32767,32767]`, and concrete endpoint attainability. The evidence also includes non-vacuity, rejection of three targeted source mutations, and source-integrity binding.

MONT-T2, MONT-T3, and MONT-T4 extend the case study to relational fibres, normalized multiplication algebra, and polynomial conversion locality. Their executions did not complete and they cannot be called proofs.

The reason for selecting four families was methodological coverage of four semantic layers. The reason for continuing beyond T3 was that scalar arithmetic correctness cannot establish polynomial loop indexing, in-place vector behaviour, residue-vector bijection, zero support, or absence of cross-talk.

The final novelty position is intentionally bounded:

> T1 is a repository-distinct, implementation-specific CBMC verification package for the pinned portable-C reduction body. Its exact combination of full-domain oracle refinement, uniqueness, sharp range, endpoint witnesses, non-vacuity, and mutation sensitivity was not identified in the inspected repository or targeted literature. The underlying Montgomery mathematics is established prior art, and no world-first claim is established. T2–T4 have novelty potential as candidate harness/property designs but are not verified results.

This is the strongest conclusion consistent with the authentic evidence.

---

# 20. References

Almeida, J.B., Barbosa, M., Barthe, G., Grégoire, B., Laporte, V., Léchenet, J.-C., Oliveira, T., Pacheco, H., Quaresma, M., Schwabe, P., Séré, A. and Strub, P.-Y. (2023) ‘Formally verifying Kyber Episode IV: Implementation correctness’, *IACR Transactions on Cryptographic Hardware and Embedded Systems*, 2023(3), pp. 164–193. doi: 10.46586/tches.v2023.i3.164-193.

Almeida, J.B., Arranz Olmos, S., Barbosa, M., Barthe, G., Dupressoir, F., Grégoire, B., Laporte, V., Léchenet, J.-C., Low, C., Oliveira, T., Pacheco, H., Quaresma, M., Schwabe, P. and Strub, P.-Y. (2024) ‘Formally verifying Kyber: Episode V: Machine-checked IND-CCA security and correctness of ML-KEM in EasyCrypt’, in Reyzin, L. and Stebila, D. (eds.) *Advances in Cryptology – CRYPTO 2024*. Lecture Notes in Computer Science, vol. 14921. Cham: Springer, pp. 384–421. doi: 10.1007/978-3-031-68379-4_12.

Almeida, J.B., Delerue Marinho Alves, G.X., Barbosa, M., Barthe, G., Esquível, L., Hwang, V., Oliveira, T., Pacheco, H., Schwabe, P. and Strub, P.-Y. (2025) ‘Faster verification of faster implementations: Combining deductive and circuit-based reasoning in EasyCrypt’, *Proceedings of the 46th IEEE Symposium on Security and Privacy*, pp. 3820–3838. doi: 10.1109/SP61157.2025.00214.

Kroening, D., Schrammel, P. and Tautschnig, M. (2023) ‘CBMC: The C Bounded Model Checker’, arXiv:2302.02384.

National Institute of Standards and Technology (2024) *Module-Lattice-Based Key-Encapsulation Mechanism Standard*. FIPS 203. Gaithersburg, MD: NIST. doi: 10.6028/NIST.FIPS.203.

PQ Code Package (2026) *mlkem-native: Secure, fast, and portable C90 implementation of ML-KEM/FIPS 203*. Pinned revision `af4c5abdd5958bdc65a03cd5ee86708264f93304`. Repository and proof tree reviewed 27 July 2026.

PQ Code Package (2026) *mlkem-native CBMC proofs README*. Pinned revision `af4c5abdd5958bdc65a03cd5ee86708264f93304`. The README states that CBMC harnesses are boilerplate and specifications are embedded in source contracts and loop annotations.

PQ Code Package (2026) *rust-libcrux: Portable ML-KEM implementation*. Verification documentation reports formal verification of portable and optimized arithmetic and higher-level code using hax and F*.

---

# Appendix A: Compact theorem registry

```text
MONT-T1 — VERIFIED
  P1 independent oracle equality
  P2 exact reconstruction and congruence
  P3 unique signed-16 decomposition
  P4 sharp complete output range
  P5 endpoint attainability

MONT-T2 — INCONCLUSIVE
  P1 canonical low-word normalization
  P2 relational scaled-residue law
  P3 exact equal-low-word affine law
  P4 injectivity inside a low-word fibre
  P5 general R-fibre translation

MONT-T3 — INCONCLUSIVE
  P1 independent multiplication refinement
  P2 normalized commutativity
  P3 zero annihilation/reflection
  P4 Montgomery-one identity
  P5 normalized distributivity
  P6 normalized associativity

MONT-T4 — INCONCLUSIVE
  P1 de-Montgomery round trip
  P2 residue-vector preservation
  P3 residue-vector reflection
  P4 zero-support preservation
  P5 coefficient locality/no cross-talk
```

# Appendix B: Terminology

**Verified:** CBMC completed and returned `VERIFICATION SUCCESSFUL` for every required property under the recorded model.

**Falsified:** CBMC completed and returned a counterexample to a named property.

**Computationally inconclusive:** CBMC did not complete and returned neither proof nor counterexample.

**Candidate theorem:** A precisely stated property intended for verification but not yet established.

**Repository-distinct:** The inspected pinned repository did not contain the same harness/property package.

**Mathematically novel:** A result new relative to the broader mathematical literature. This is not claimed.

**Mutation sensitivity:** The ability of a property suite to reject deliberately defective source variants.

**Non-vacuity:** Evidence that assumptions and relevant paths are satisfiable.

**Source binding:** Cryptographic and version-control linkage between evidence and exact production source.

# Appendix C: Professor summary

This case study constructed a four-level Montgomery-domain verification plan for the pinned `mlkem-native` portable-C implementation. CBMC genuinely verified MONT-T1, showing that `mlk_montgomery_reduce` exactly matches an independent full-domain oracle, satisfies exact reconstruction and modular congruence, has a unique signed decomposition, and has the sharp output image `[-32767,32767]`; the result also passed authentic non-vacuity, mutation-sensitivity, and source-integrity gates. MONT-T2, T3, and T4 extended the design to relational low-word fibres, normalized Montgomery multiplication algebra, and polynomial conversion locality, but their executions did not complete and are therefore computationally inconclusive. The custom T1 package is repository-distinct from the native contract-oriented CBMC harness, although the underlying Montgomery mathematics and broader ML-KEM functional-verification field are established prior work. The defensible contribution is an implementation-specific CBMC verification package for T1, three strong unresolved candidate theorem families, and an evidence-integrity lesson showing why verification pipelines must authenticate raw tool provenance rather than trust success-formatted text.


IMPORTANT NOTE APPENDICES 1

The existing Markdown did **not** document the split adequately.

The file currently explains that T2 was computationally harder because it introduced multiple symbolic inputs, multiple target calls, modular relations, conditional fibre paths, and a symbolic shift. It also mentions “theorem-preserving property decomposition” only as a possible future strategy.  

But it does **not explicitly document**:

* why the original combined T2 execution was split;
* the precise division between **T2-A** and **T2-B**;
* why that division did not narrow or replace the candidate theorem family;
* the conditions under which separate CBMC runs would be logically equivalent to checking the combined conjunction;
* that the split preserved the theorem design but did **not** turn the inconclusive execution into a proof.

That is a genuine documentation gap.

## What actually happened

The combined T2 query created a large relational formula involving:

```text
two independent full-domain int32 inputs
multiple calls to mlk_montgomery_reduce
canonical low-word calculations
modular congruence
conditional same-fibre reasoning
a symbolic integer translation k
full source-contract constraints
```

To reduce the solver’s formula size and memory pressure, the candidate theorem family was separated into two logically distinct harnesses.

### T2-A — arbitrary-pair and equal-low-word laws

T2-A retained:

```text
two independent nondeterministic full-domain inputs a and b
low-word normalization for both inputs
arbitrary-pair scaled congruence
same-low-word input-delta divisibility
exact same-fibre output difference
same-fibre injectivity
```

### T2-B — affine fibre-translation laws

T2-B retained:

```text
a nondeterministic full-domain base input a
a nondeterministic integer shift k
the shifted input b = a + k·65536
the requirement that both a and b remain in the full source contract
equal canonical low words
exact output translation by k
zero-shift identity
nonzero-shift output distinction
```

The frozen split registry expressly stated that no property was removed, narrowed, or replaced by a derivation from T1. 

## Why the split preserved the theorem specification

Suppose the original T2 candidate family was the conjunction:

```text
T2 = P1 ∧ P2 ∧ P3 ∧ P4 ∧ P5
```

The split was:

```text
T2-A = P1 ∧ P2 ∧ P3 ∧ P4
T2-B = P5
```

Therefore:

```text
T2-A ∧ T2-B = T2
```

Checking the properties in separate solver executions does not weaken the theorem **provided that** all of the following remain identical:

```text
same pinned production source
same actual mlk_montgomery_reduce body
same arithmetic constants
same complete source-contract domain
same machine model
same property statements
same relational premises
same loop/unwinding requirements where relevant
no replacement of the body by a weaker contract
```

The split changed only the **solver packaging**, not the mathematical content.

The reason it could help computationally is that CBMC would construct and solve two smaller formulas instead of one large formula containing every symbolic relation simultaneously.

## Important correction for the thesis

The result must be phrased carefully:

> The T2 split preserved the logical candidate theorem family, but it did not produce a completed proof because the authentic CBMC executions remained computationally inconclusive.

The record must **not** state:

> Splitting T2 proved the theorem soundly.

The correct distinction is:

```text
THEOREM DESIGN PRESERVED = YES
DOMAIN NARROWED          = NO
PROPERTY REMOVED         = NO
TARGET BODY REPLACED     = NO
COMPLETED CBMC PROOF     = NO
FINAL T2 STATUS          = INCONCLUSIVE
```

## Exact section that should be added to the Markdown

## 8.4 Why the T2 execution was split and why the split preserved the candidate theorem

The initial MONT-T2 design placed the arbitrary-pair residue laws, equal-low-word fibre laws, and general affine translation law into one relational CBMC execution. This produced a substantially larger symbolic formula than MONT-T1 because it combined multiple independent full-width inputs, multiple calls to `mlk_montgomery_reduce`, modular arithmetic, conditional fibre premises, and a symbolic integer translation. The execution was therefore divided to reduce formula size and solver-resource pressure.

The division was made according to the logical structure of the already frozen property family.

**T2-A** retained the arbitrary-pair and equal-low-word properties. It used two independent nondeterministic inputs over the complete source-contract domain and encoded low-word normalization, arbitrary-pair scaled congruence, same-low-word input-delta divisibility, the exact same-fibre output difference, and same-fibre injectivity.

**T2-B** retained the general affine fibre-translation property. It used a nondeterministic base input `a` and nondeterministic integer shift `k`, formed the second input as `a + k·65536`, required both inputs to remain inside the complete source contract, and encoded equal low words, the exact output translation by `k`, the zero-shift identity, and nonzero-shift output distinction.

This was a theorem-preserving execution decomposition rather than a theorem weakening. No registered property was deleted, no input domain was reduced, no relational premise was removed, and no T2 property was replaced by an appeal to the completed T1 result. Both harnesses continued to execute the actual pinned `mlk_montgomery_reduce` body under the same arithmetic constants and machine assumptions. Logically, the original T2 candidate was the conjunction of the T2-A and T2-B obligations; therefore, completed verification of every obligation in both harnesses would establish the same candidate family as a completed monolithic execution.

The split affected only how the obligations were presented to the solver. It was intended to reduce the size of each generated formula and avoid requiring CBMC to solve every independent relational structure simultaneously.

This preservation statement concerns the soundness of the candidate-theorem decomposition, not the final experimental result. The authentic T2 executions did not return `VERIFICATION SUCCESSFUL` or a counterexample within the available execution period. MONT-T2 therefore remains computationally inconclusive despite the theorem-preserving split.

So the answer is:

```text
DID THE CURRENT MD EXPLAIN THE EXACT T2 SPLIT?     NO
DID IT MENTION THE IDEA GENERICALLY?               YES
DOES IT NEED THE SECTION ABOVE?                    YES
WOULD ADDING IT CHANGE T2 TO VERIFIED?             NO
WOULD IT accurately explain preserved soundness?  YES
```