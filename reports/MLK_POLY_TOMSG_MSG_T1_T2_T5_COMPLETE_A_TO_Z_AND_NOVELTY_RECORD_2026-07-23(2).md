# Complete A-to-Z Technical, Assurance, and Novelty Record for the `mlk_poly_tomsg` MSG-T1, MSG-T2, and MSG-T5 CBMC Campaign

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Institutional context:** MSc thesis, Tampere University  
**Case-study theme:** AI-assisted generation and deterministic verification of candidate formal-verification artefacts for selected ML-KEM C code  
**Target repository:** `mlkem-native`  
**Target implementation:** frozen portable-C `mlk_poly_tomsg` and its reachable `mlk_scalar_compress_d1` helper  
**Completed theorem families:** MSG-T1, MSG-T2, and MSG-T5  
**Primary formal tool:** CBMC 6.9.0  
**Record date:** 23 July 2026  
**Authoritative source commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Document form:** machine-oriented technical record. Raw source, commands, GOTO binaries, solver results, manifests, and frozen archives remain authoritative over the narrative.

---

# Executive verdict

Three differentiated verification families were completed for the frozen ML-KEM-768 portable-C implementation of:

```c
mlk_poly_tomsg(msg, &a);
```

The families answer different questions:

| Family | Research question answered | Final technical status |
|---|---|---|
| **MSG-T1** | Does the real fixed production implementation map every canonical coefficient to the exact intended message bit and pack all 256 bits into the correct 32-byte message? | **FINAL ACCEPTED** |
| **MSG-T2** | How do two real production executions relate when selected coefficients, compression decisions, or complete inputs are equal or different? | **THEOREM FAMILY ACCEPTED** |
| **MSG-T5** | Keeping the production multiplier and shift fixed, what is the complete set of `uint32_t` offsets preserving the exact canonical `Compress1` threshold semantics? | **FINAL ACCEPTED** |

The strongest correct integrated claim is:

> For `mlkem-native` commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`, in the frozen ML-KEM-768 portable-C CBMC model and under the registered canonical-domain, object-validity, non-aliasing, build, machine-model, safety-check, support-adapter, and finite-loop assumptions, the actual `mlk_poly_tomsg` body satisfies the accepted MSG-T1 exact coefficient-to-message-bit refinement theorem and the accepted MSG-T2 relational XOR, locality, cross-bit preservation, same-decision invariance, input-frame, and complete-message determinism theorems. In addition, the evidence-local MSG-T5 offset model is formally connected to the real scalar helper and the real `mlk_poly_tomsg` output at the production offset, and the complete `uint32_t` offset set preserving the canonical threshold semantics is exactly the closed interval `[1073417800, 1074063871]`.

The work is stronger than:

- compilation success;
- conventional unit tests;
- checking selected example values;
- a memory-safety-only result;
- a native one-call contract harness without the new theorem assertions;
- a parameter sweep without proof;
- an LLM-generated claim without solver evidence.

The work does **not** establish every conceivable property of `mlk_poly_tomsg`, all parameter sets, all source revisions, assembly implementations, compiled object-code equivalence, full ML-KEM correctness, cryptographic security, constant-time behavior, or side-channel resistance.

---

# 1. Purpose, method, and authorship boundary

## 1.1 Purpose

The case study evaluates whether an LLM-assisted workflow can formulate useful formal properties and produce candidate CBMC artefacts for production cryptographic C while preserving deterministic, falsifiable, and reproducible tool authority.

The workflow was intentionally not:

```text
LLM statement → accepted theorem
```

It was:

```text
frozen source and hashes
        ↓
candidate theorem and assumptions
        ↓
candidate oracle/relational model
        ↓
candidate harness and support adapters
        ↓
static harness audit
        ↓
GOTO construction
        ↓
GOTO validation and body inspection
        ↓
loop/property registration inspection
        ↓
frozen CBMC command
        ↓
authoritative solver result
        ↓
deterministic parsing
        ↓
reachability/non-vacuity companions
        ↓
expected-failure controls and mutations
        ↓
source/result/hash re-binding
        ↓
evidence freeze and deterministic archive
```

## 1.2 Recorded campaign operations

The recorded campaign operations were:

- analysis of the frozen implementation and existing proof structure;
- decomposition of candidate theorem families;
- generation of independent oracles and relational assertions;
- construction of clean-room harnesses;
- generation of build commands, support adapters, inspection scripts, parsers, reachability companions, mutations, manifests, and freeze scripts;
- inspection of retained terminal results;
- separate classification of positive theorem results, reachability evidence, expected-failure mutations, audit failures, and tool/script failures;
- diagnosis of failed generated artefacts without presenting them as production counterexamples;
- maintenance of narrow theorem scopes and explicit non-claims;
- preparation of the professor-facing research record;
- execution in the frozen repository and clean-room evidence workspace;
- preservation of generated artefacts and evidence directories;
- final archive inspection at designated gates.

## 1.4 Formal authority

The LLM did not become the trusted proof engine. The accepted authority is:

1. the exact frozen source;
2. the exact harness;
3. the exact GOTO model;
4. the exact command and loop bounds;
5. CBMC’s bit-precise result;
6. deterministic result parsing;
7. reachability and mutation evidence;
8. source, result, and archive hashes.

The correct academic description is:

> AI-assisted candidate artefact generation with recorded execution, deterministic inspection, CBMC adjudication, negative controls, and reproducible evidence binding.

---

# 2. Frozen implementation, build, and toolchain

## 2.1 Repository identity

```text
Repository:
/home/girish/THESIS-2026/mlkem-native_af4c5abd

Commit:
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

## 2.2 Authoritative source hashes

```text
mlkem/src/compress.c
9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad

mlkem/src/compress.h
0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd
```

The accepted stages repeatedly reported:

```text
COMMIT_BINDING=PASS
PRODUCTION_SOURCE_HASH_BINDING=PASS
SOURCE_TREE_CLEAN_BEFORE=YES
SOURCE_TREE_CLEAN_AFTER=YES
SOURCE_REPOSITORY_MODIFIED=NO
```

No accepted theorem was obtained by editing `compress.c` or `compress.h`.

## 2.3 Configuration

```text
Parameter set:             ML-KEM-768
MLKEM_N:                   256
MLKEM_Q:                   3329
Message size:              32 bytes
Implementation:            portable C
Assembly:                  disabled
Language mode:             C90
CBMC:                      6.9.0
goto-cc:                   6.9.0
goto-instrument:           6.9.0
SAT solver:                minisat2
CBMC object bits:          8
```

## 2.4 Main safety and semantic checks

Depending on the theorem stage, the positive commands included:

```text
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
--slice-formula
--all-properties
--trace
--json-ui
```

Loop-free scalar parameter theorems did not add artificial unwind settings. Production-loop theorems used explicit unwind sets and unwinding assertions.

## 2.5 Support adapters

The clean-room builds reused the accepted evidence-local support files:

```text
msg02b_fail_closed_zeroize.h
msg02b_verify_pragma_scope.h
msg02b_compress_direct_wrap_scope.h
msg02b_optblocker_zero.c
```

Their role was to model or configure the build environment and verification pragma scope. They did not replace the target compression algorithm. The accepted GOTO inspections confirmed the real production `mlk_poly_tomsg` body and, where relevant, the real scalar helper body were present.

---

# 3. Production behavior under examination

The portable `mlk_poly_tomsg` implementation consumes a 256-coefficient polynomial and writes a 32-byte message.

Its essential structure is:

```c
for (i = 0; i < MLKEM_N / 8; i++)
{
    msg[i] = 0;

    for (j = 0; j < 8; j++)
    {
        uint32_t t =
            mlk_scalar_compress_d1(a->coeffs[8 * i + j]);

        msg[i] |= (uint8_t)(t << j);
    }
}
```

The reachable scalar helper uses:

```c
uint32_t d0 = (uint32_t)u * 1290168;
return (uint8_t)((d0 + ((uint32_t)1u << 30)) >> 31);
```

The source contract for the helper requires canonical input and expresses the fixed `Compress1` result. The source contract for `mlk_poly_tomsg` primarily establishes object validity, non-aliasing, canonical input coefficients, and the write frame. It does not express the complete new MSG-T1 all-bit refinement theorem, the MSG-T2 two-execution relational family, or the MSG-T5 complete parameter-space characterization.

---

# 4. What upstream `mlkem-native` already proved or contained

The upstream repository was never treated as proof-free.

At the frozen commit, it contained:

- a source contract for `mlk_scalar_compress_d1`;
- a source contract for `mlk_poly_tomsg`;
- a native CBMC harness for `mlk_scalar_compress_d1`;
- a native CBMC harness for `mlk_poly_tomsg`;
- a `poly_tomsg` proof Makefile checking the function contract;
- canonical-bound assertions and loop annotations;
- broader CBMC safety and type-safety infrastructure;
- higher-level contract use in decryption proof configurations.

The native `poly_tomsg` harness is structurally minimal:

```c
void harness(void)
{
    mlk_poly *a;
    uint8_t *msg;

    /* Contracts for this function are in compress.h */
    mlk_poly_tomsg(msg, a);
}
```

This is a legitimate upstream harness for checking the registered function contract and generated properties.

The record therefore does **not** claim:

- that upstream had no proof;
- that upstream had no `poly_tomsg` harness;
- that upstream had no functional assurance;
- that this is the first formal verification of ML-KEM;
- that this is the first CBMC use in `mlkem-native`;
- that `Compress1` or byte packing was newly invented here.

---

# 5. Why the new harnesses are genuinely distinct

The new artefacts are distinct because their proof obligations differ, not because their filenames differ.

## 5.1 Distinction from the native contract harness

The native one-call harness delegates its primary functional scope to the source contract.

The new families introduce:

- independent semantic oracles;
- explicit all-bit equality;
- two-execution relational antecedents and consequents;
- deliberately unrestricted unrelated coefficients;
- full-message equality over distinct objects;
- symbolic parameter domains not exposed by production;
- exact necessity and sufficiency claims;
- explicit reachability goals;
- expected-failure endpoint and antecedent mutations;
- deterministic evidence freezes.

## 5.2 Clean-room authorship

The new harnesses were independently authored from the frozen source/specification context. They were not copied from the native harness and then relabelled. Native proof artefacts were analysed to establish the assurance baseline and detect overlap, but the theorem structures and harness assertions were newly formulated.

## 5.3 Real production binding

For T1 and T2, the GOTO models included direct calls to the real frozen `mlk_poly_tomsg` body.

For T5, the universal parameter theorem cannot call a runtime-selectable production offset because production has no such parameter. Therefore, T5 used an evidence-local model but formally proved, at the production offset, equality with:

1. the real `mlk_scalar_compress_d1` helper; and
2. the selected bit returned through the real `mlk_poly_tomsg` body.

The model-to-production bridge prevents the T5 parameter theorem from being presented as a detached arithmetic exercise.

---

# 6. MSG-T1 — exact fixed-production semantics

## 6.1 The theorem

For every index:

```text
k ∈ {0, ..., 255}
```

and every canonical coefficient:

```text
0 <= a.coeffs[k] < 3329
```

after executing:

```c
mlk_poly_tomsg(msg, &a);
```

the accepted theorem requires:

```text
((msg[k >> 3] >> (k & 7)) & 1)
    ==
((a.coeffs[k] >= 833) && (a.coeffs[k] <= 2496))
```

The exact canonical classes are:

```text
0..832      -> output bit 0
833..2496   -> output bit 1
2497..3328  -> output bit 0
```

The packing relation is:

```text
output byte = k >> 3
output bit  = k & 7
```

## 6.2 Meaning of the theorem

The assertion jointly checks:

- selection of the correct input coefficient;
- correct scalar one-bit compression;
- correct output-byte selection;
- correct bit-position selection;
- least-significant-bit-first packing;
- all 256 output positions;
- complete construction of the 32-byte message.

## 6.3 Independent oracle

The oracle was derived from the integer `Compress1` relation:

```text
(((2*u + floor(3329/2)) / 3329) mod 2)
```

and compared with the threshold shortcut over all canonical values:

```text
canonical values checked: 3329
mismatches:               0
```

The threshold theorem was therefore not accepted merely because the threshold looked plausible.

## 6.4 Frozen T1 identities

```text
Frozen harness:
MSG01G_R1_T1_FROZEN_EXECUTION_INPUT_V1_af4c5abdd595/
frozen_candidate_v1/harness/msg_t1_exact_fips_candidate_v4.c

Harness SHA-256:
5ce480427d7792b3dca091ac198b43562c4d4dfd6c9d96dae5a73e7ef1e72b55

Frozen GOTO SHA-256:
51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d
```

The inspected call graph included:

```text
main
  -> independent threshold oracle
  -> real frozen mlk_poly_tomsg
       -> real frozen mlk_scalar_compress_d1
```

## 6.5 Positive result

```text
CBMC_EXIT=0
PROPERTY_RECORD_COUNT=521
SUCCESS_COUNT=521
FAILURE_COUNT=0
UNKNOWN_COUNT=0
```

Authoritative positive JSON SHA-256:

```text
3b32112c5537a95d470b0b866c1edf6cb1f8c3be408188c9fc2cdbf91fab40ee
```

The 521 successful records include the named theorem and generated C-safety properties. They are not 521 independent mathematical discoveries.

## 6.6 Cover-neutral companion

The assertion-preserving companion returned:

```text
PROPERTY_RECORD_COUNT=522
SUCCESS_COUNT=522
FAILURE_COUNT=0
UNKNOWN_COUNT=0
```

This established that the positive result did not depend on cover instructions.

## 6.7 Reachability and non-vacuity

All 12 registered coverage goals were satisfied:

1. coefficient `0`;
2. threshold boundary `832`;
3. threshold boundary `833`;
4. threshold boundary `2496`;
5. threshold boundary `2497`;
6. canonical maximum `3328`;
7. interior lower-zero region;
8. interior one region;
9. interior upper-zero region;
10. flat index `0`;
11. flat index `127`;
12. flat index `255`.

```text
COVERAGE_SATISFIED=12
COVERAGE_TOTAL=12
COVERAGE_FAILED=0
```

## 6.8 Loop treatment

Five relevant loops were registered:

```text
main.0
main.1
mlk_msg01f_poly_tomsg.0
mlk_msg01f_poly_tomsg.1
mlk_msg01f_poly_tomsg.2
```

Four genuinely multi-iteration loops were assigned intentionally insufficient bounds and correctly rejected. A macro-origin loop that was complete at bound one was reclassified instead of being forced into a false failure narrative.

```text
PASSED_MULTI_ITERATION_CONTROL_COUNT=4
ALL_ALGORITHMIC_LOOP_SENSITIVITY_CONTROLS=PASS
```

## 6.9 T1 mutation family

### Production/implementation mutants

The registered defects included:

- incorrect output-byte initialization;
- reversed coefficient order within a byte;
- rotated output-bit position;
- inverted scalar decision behavior.

### Oracle/assertion mutants

The registered defects included:

- shifted lower threshold;
- shifted upper threshold;
- incorrect bit extraction/packing relation;
- corrupted equality relation.

The campaign screened for equivalent mutants before authoritative execution.

Final result:

```text
non-equivalent mutants executed: 8
mutants killed:                  8
surviving registered mutants:    0
```

Mutation killing is evidence that the exact assertion is sensitive to these defects. It does not prove completeness against every possible defect.

## 6.10 T1 final status

```text
MSG_T1_EXACT_CANONICAL_FUNCTIONAL_REFINEMENT=FINAL_ACCEPTED
```

The final T1 archive SHA-256 recorded in the earlier T1 A-to-Z evidence record was:

```text
1477c76ca5208a40d813c16a077d9f5534f0a256380ca0c9056ebf08f05d58bc
```

---

# 7. MSG-T2 — relational, locality, confinement, frame, and determinism properties

MSG-T2 did not repeat the single-execution T1 theorem. It analysed relations between two executions of the real production implementation.

The accepted T2 family contains five positive proof stages:

```text
R1   relational XOR
R2A  coefficient locality
R2B  cross-bit preservation / byte confinement
R3A  same-decision invariance
R3B  input-frame preservation and complete-message determinism
```

## 7.1 R1 — relational XOR law

For arbitrary canonical polynomials `A` and `B` and symbolic index `k`:

```text
bit_k(tomsg(A) XOR tomsg(B))
    ==
oracle(A[k]) XOR oracle(B[k])
```

This theorem binds two real production executions to an independent decision relation.

Positive result:

```text
SUCCESS=525
FAILURE=0
UNKNOWN=0
```

Hardening:

```text
coverage goals: 11/11
decision pairs reachable: 00, 01, 10, 11
XOR outputs reachable:    0 and 1
drop-B mutation:          rejected exactly once
```

## 7.2 R2A — coefficient locality

For arbitrary canonical `A`, `B`, and symbolic `k`:

```text
A[k] == B[k]
    implies
bit_k(tomsg(A)) == bit_k(tomsg(B))
```

Every coefficient pair outside `k` remained unrestricted.

This is stronger than a test where the complete polynomials are equal, because it isolates the local dependency.

Positive result:

```text
SUCCESS=522
FAILURE=0
UNKNOWN=0
```

Hardening:

```text
reachability goals:                 6/6
selected-equality antecedent mutant: rejected exactly once
```

## 7.3 R2B — cross-bit preservation and byte confinement

Assume all coefficient pairs outside selected index `k` are equal:

```text
for every i != k:
    A[i] == B[i]
```

The selected coefficient may differ.

The accepted theorem proves:

```text
for every output bit j != k:
    bit_j(tomsg(A)) == bit_j(tomsg(B))
```

Consequences:

- all output bytes other than byte `k >> 3` are preserved;
- all seven non-selected bits in byte `k >> 3` are preserved;
- a change at one coefficient cannot leak functionally into another message bit.

Positive result:

```text
SUCCESS=533
FAILURE=0
UNKNOWN=0
```

Hardening:

```text
reachability goals:             6/6
second-coefficient mutation:    rejected exactly once
failed property:                main.assertion.1
unknown results:                0
```

R2B is the accepted byte-confinement evidence. A weaker separate byte-confinement theorem was unnecessary.

## 7.4 R3A — same-decision invariance

For arbitrary canonical `A`, `B`, and symbolic `k`:

```text
oracle(A[k]) == oracle(B[k])
    implies
bit_k(tomsg(A)) == bit_k(tomsg(B))
```

The selected coefficient values need not be numerically equal. All other coefficient pairs remained unrestricted.

This theorem distinguishes numeric equality from semantic compression-class equality.

Positive result:

```text
SUCCESS=522
FAILURE=0
UNKNOWN=0
```

Reachability:

```text
9/9 goals satisfied
```

The goals included:

- unequal selected values with equal decisions;
- both production calls returning;
- first and last indices;
- decision classes `00` and `11`;
- unrelated coefficients differing;
- output bit pairs `00` and `11`.

Mutation:

```text
A[k] = 0
B[k] = 1665
```

These values force opposite decision classes. The deliberately corrupted equal-output assertion failed exactly once:

```text
CBMC exit:       10
success:         0
failure:         1
unknown:         0
failed property: main.assertion.1
```

## 7.5 R3B — input-frame preservation and complete-message determinism

Two distinct polynomial objects were initialized from the same arbitrary canonical value:

```text
run_a = source
run_b = source
```

Two distinct output arrays were used without assuming initial output equality.

After two real production calls, the theorem proves:

```text
run_a == source
run_b == source
msg_a == msg_b over all 32 bytes
```

Positive result:

```text
SUCCESS=520
FAILURE=0
UNKNOWN=0
```

Reachability:

```text
11/11 goals satisfied
```

The goals included:

- distinct objects with equal values;
- both calls returning;
- first and final bit indices;
- output bit 0 and 1;
- first and final bytes reaching `0x00` and `0xFF`.

Mutation hardening removed complete input equality at one selected coefficient:

```text
run_a[k] = 0
run_b[k] = 1665
```

while retaining complete-output equality as a corrupted claim.

Result:

```text
CBMC exit:       10
success:         0
failure:         1
unknown:         0
failed property: main.assertion.1
```

This mutation shows that equal complete input values are necessary for the universal complete-message determinism statement. It does **not** claim that every unequal polynomial produces a different message.

## 7.6 T2 aggregate evidence

Positive results:

```text
R1:  525
R2A: 522
R2B: 533
R3A: 522
R3B: 520
----------------
Total: 2622 successful property records
```

Reachability:

```text
R1:  11
R2A: 6
R2B: 6
R3A: 9
R3B: 11
----------------
Total: 43/43 goals satisfied
```

Mutation sensitivity:

```text
R1 drop-B mutation:                    rejected
R2A selected-equality mutation:         rejected
R2B second-coefficient mutation:        rejected
R3A opposite-decision mutation:         rejected
R3B unequal-input mutation:             rejected
-------------------------------------------------
Total: 5/5 expected-failure mutations
Unknown results: 0
```

GOTO validation:

```text
15/15 T2 proof, coverage, and mutation GOTO binaries revalidated
```

## 7.7 T2 final acceptance

```text
MSG_T2_1_RELATIONAL_XOR_LAW=ACCEPTED
MSG_T2_2A_COEFFICIENT_LOCALITY=ACCEPTED
MSG_T2_2B_CROSS_BIT_PRESERVATION=ACCEPTED
MSG_T2_2_BYTE_CONFINEMENT=ACCEPTED_VIA_R2B
MSG_T2_3A_SAME_DECISION_INVARIANCE=ACCEPTED
MSG_T2_3B_INPUT_FRAME_PRESERVATION=ACCEPTED
MSG_T2_3B_FULL_MESSAGE_DETERMINISM=ACCEPTED
MSG_T2_RELATIONAL_PROPERTY_FAMILY=ACCEPTED
```

## 7.8 T2 evidence-freeze caveat

The MSG02M freeze passed all substantive proof gates and created a valid archive:

```text
MLK_POLY_TOMSG_T2_RELATIONAL_ACCEPTED_20260723T134156Z_af4c5abdd595.tar.gz
```

Recorded archive SHA-256:

```text
79f166d190d7e786fa86e82930f7b2b89eb25554de658bfe81a7464be5f00318
```

However, the documentation generator used an unquoted shell heredoc containing Markdown backticks. The shell attempted to execute:

```text
mlk_poly_tomsg
```

and printed:

```text
mlk_poly_tomsg: command not found
```

This occurred while writing the summary Markdown, after all theorem, hash, coverage, mutation, and GOTO gates had passed.

Classification:

```text
T2 theorem evidence:       accepted
T2 archive structure:      valid
T2 archive checksum:       valid
T2 summary documentation:  needs one repair/re-freeze
T2 theorem rerun required: no
```

The technical theorem acceptance must not be downgraded because of this documentation bug, but the archive should not be called publication-final until the Markdown is repaired and the package is re-frozen.

---

# 8. MSG-T5 — exact admissible `uint32_t` offset interval

## 8.1 Motivation

T1 proves the correctness of the one fixed production offset:

```text
2^30 = 1073741824
```

T5 asks a different question:

> Keeping the production multiplier `1290168`, shift `31`, and modulo-\(2^32\) arithmetic fixed, which `uint32_t` offset values preserve the correct canonical threshold function for every coefficient?

This is a parameter-robustness and exact parameter-space characterization theorem.

## 8.2 Parameterized expression

Define:

\[
F_c(u)=
\operatorname{MSB}_{32}
\left(
(u\cdot1290168+c)\bmod2^{32}
\right).
\]

The desired oracle is:

\[
O(u)=
\begin{cases}
1,&833\leq u\leq2496,\\
0,&\text{otherwise}.
\end{cases}
\]

T5 characterizes:

\[
\mathcal C=
\{c\in\texttt{uint32\_t}\mid
\forall u\in[0,3328],F_c(u)=O(u)\}.
\]

## 8.3 MSG05A — source and overlap gate

MSG05A:

- rebound the frozen source;
- located the production helper and `mlk_poly_tomsg`;
- captured the exact multiplier, offset, and shift expression;
- searched native proofs, contracts, harnesses, tests, and examples for an equivalent parameterized-offset theorem;
- found native fixed-function proofs but no equivalent native parameterized-offset theorem.

The pre-proof classification did not assume that the admissible set was contiguous.

## 8.4 MSG05B — deterministic exact-set derivation

The source-bound deterministic derivation produced:

```text
EXACT_ADMISSIBLE_LOWER=1073417800
EXACT_ADMISSIBLE_UPPER=1074063871
ADMISSIBLE_OFFSET_COUNT=646072
PRODUCTION_OFFSET=1073741824
PRODUCTION_OFFSET_ADMISSIBLE=YES
ADMISSIBLE_SET_SHAPE=SINGLE_CLOSED_INTERVAL
```

Distances of the production offset:

```text
above lower endpoint: 324024
below upper endpoint: 322047
```

Nearest rejected values:

```text
lower - 1 = 1073417799
witness u = 2497

upper + 1 = 1074063872
witness u = 832
```

The native exact-search result was:

```text
PARAMETERIZED_OFFSET_MATCH_COUNT=0
EQUIVALENT_NATIVE_PARAMETERIZED_OFFSET_THEOREM_FOUND=NO
```

This is repository-level evidence, not a proof of universal nonexistence.

## 8.5 MSG05C — model-to-production binding

The evidence-local parameterized model used explicit `uint64_t` intermediates and low-32-bit masks to express modulo-\(2^{32}\) arithmetic.

At:

```text
c = 1073741824
```

CBMC proved:

```text
model_bit == real mlk_scalar_compress_d1 result
model_bit == selected real mlk_poly_tomsg output bit
```

The GOTO model contained:

- one parameterized-model body;
- the real scalar helper body;
- the real production target body;
- one production execution;
- the expected production loops.

Result:

```text
SUCCESS=527
FAILURE=0
UNKNOWN=0
```

Therefore:

```text
T5_PARAMETERIZED_MODEL_BINDING=ACCEPTED
```

## 8.6 MSG05D — universal interval sufficiency

For symbolic canonical coefficient `u` and symbolic offset `c`:

```text
0 <= u < 3329
1073417800 <= c <= 1074063871
```

CBMC proved:

```text
F_c(u) == O(u)
```

Result:

```text
SUCCESS=13
FAILURE=0
UNKNOWN=0
core sufficiency property=SUCCESS
```

The proof symbolically covers:

```text
3329 canonical coefficients
× 646072 admissible offsets
= 2150773688 coefficient-offset combinations
```

No production call was required in this scalar universal stage because MSG05C had already proved the production-offset bridge.

## 8.7 MSG05E — universal outside-interval necessity

For every `uint32_t` offset outside the interval, the proof selects a canonical counterexample from a complete three-part partition:

### Region 1

```text
0 <= c < 1073417800
witness u = 2497
```

### Region 2

```text
1074063871 < c < 2^31
witness u = 832
```

### Region 3

```text
2^31 <= c <= UINT32_MAX
witness u = 0
```

CBMC proved for every outside offset:

```text
F_c(witness_u) != O(witness_u)
```

Result:

```text
SUCCESS=13
FAILURE=0
UNKNOWN=0
outside partitions proved=3/3
```

This supplies the necessity direction.

## 8.8 MSG05F — reachability and endpoint tightness

MSG05F established:

```text
reachability goals:             10/10
outside partitions reachable:   3/3
lower adjacent value reachable: yes
upper adjacent value reachable: yes
high-half start reachable:      yes
UINT32_MAX reachable:           yes
```

Two isolated expected-failure mutations widened the accepted interval by one value.

### Lower expansion mutation

```text
c = 1073417799
predicted witness u = 2497
```

The corrupted universal-correctness assertion was rejected.

### Upper expansion mutation

```text
c = 1074063872
predicted witness u = 832
```

The corrupted universal-correctness assertion was rejected.

Final hardening:

```text
LOWER_ENDPOINT_ONE_STEP_TIGHT=YES
UPPER_ENDPOINT_ONE_STEP_TIGHT=YES
ENDPOINT_MUTATIONS=2_OF_2_PASS
```

## 8.9 MSG05G — final T5 freeze

MSG05G rebound:

- frozen source and hashes;
- exact interval and cardinality;
- repository-novelty classification;
- positive model-binding, sufficiency, and necessity results;
- 10 reachability goals;
- two endpoint mutations;
- six GOTO binaries;
- complete evidence manifests;
- deterministic archive.

Final status:

```text
MSG05G_SOURCE_BINDING=PASS
MSG05G_EXACT_INTERVAL_BINDING=PASS
MSG05G_REPOSITORY_NOVELTY_BINDING=PASS
MSG05G_MODEL_BINDING_PROOF=PASS
MSG05G_INTERVAL_SUFFICIENCY_PROOF=PASS
MSG05G_OUTSIDE_NECESSITY_PROOF=PASS
MSG05G_REACHABILITY=10_OF_10_PASS
MSG05G_ENDPOINT_MUTATIONS=2_OF_2_PASS
MSG05G_GOTO_REVALIDATION=6_OF_6_PASS
MSG05G_COMPLETE_EVIDENCE_MANIFEST=PASS
MSG05G_DETERMINISTIC_ARCHIVE=PASS
T5_EXACT_ADMISSIBLE_INTERVAL_THEOREM=FINAL_ACCEPTED
```

Archive:

```text
MLK_POLY_TOMSG_T5_EXACT_OFFSET_INTERVAL_ACCEPTED_20260723T165407Z_af4c5abdd595.tar.gz
```

The archive SHA-256 value is stored in the companion `.sha256` file. Its literal value was not present in the retained evidence record and is therefore not invented here.

Terminal-capture SHA-256:

```text
6fcdcab6bbefe509ca2c80cc9d509410e33cc57511b1d259984fa70ddf378e37
```

## 8.10 Exact accepted T5 theorem

With:

```text
multiplier = 1290168
shift      = 31
offset     = uint32_t
arithmetic = modulo 2^32
domain     = 0 <= u < 3329
```

the accepted theorem is:

\[
\left[
\forall u\in[0,3328],\,
F_c(u)=O(u)
\right]
\iff
1073417800\leq c\leq1074063871.
\]

The exact admissible interval contains:

```text
646072 offsets
```

and production:

```text
c = 2^30 = 1073741824
```

is an interior member.

---

# 9. Scope of the `mlk_poly_tomsg` proof

## 9.1 Yes, for the accepted property families and frozen scope

The answer is **yes**, when stated property-specifically.

### T1

The actual frozen production body was executed symbolically and proved to implement the exact canonical coefficient-to-message-bit mapping and packing relation for all 256 coefficients.

### T2

The actual frozen production body was executed in two-run relational harnesses and proved to satisfy the accepted XOR, locality, cross-bit preservation, same-decision invariance, input-frame, and complete-message determinism properties.

### T5

The complete offset interval theorem is a theorem about an evidence-local parameterized expression because production exposes only a fixed offset. However, CBMC proved that the model instantiated with the real production offset equals both the real scalar helper and the real `mlk_poly_tomsg` bit. T5 therefore proves a source-connected robustness property, not that production accepts arbitrary offsets at runtime.

## 9.2 Meaning of “proved”

For the positive assertions, CBMC constructed a bit-precise verification condition and found no satisfying counterexample under the frozen assumptions and finite-loop model.

Operationally:

> No execution represented by the frozen model and satisfying the registered assumptions violates the accepted assertions.

This is universal symbolic reasoning over the represented finite domain, not sampling.

## 9.3 What was not proved

The work does not prove:

- every possible functional property of `mlk_poly_tomsg`;
- noncanonical coefficient behavior;
- every future repository revision;
- ML-KEM-512 and ML-KEM-1024 independently;
- assembly or intrinsics variants;
- compiler-to-object-code refinement;
- whole-program decryption correctness;
- all of ML-KEM;
- IND-CPA or IND-CCA security;
- constant-time execution;
- cache, power, electromagnetic, speculative, or fault resistance;
- memory safety outside the exact model and assumptions;
- universal mutation completeness;
- universal novelty.

The safe phrase is:

```text
MSG-T1, MSG-T2, and MSG-T5 were proved within the frozen registered scope.
```

The unsafe phrase is:

```text
`mlk_poly_tomsg` was proved correct in every sense.
```

---

# 10. Assumptions and trusted boundaries

## 10.1 Input assumptions

The principal semantic domain was:

```text
0 <= coefficient < 3329
```

For T1 and T2, the harnesses assumed complete canonical polynomials.

For T5, `u` ranged over all 3,329 canonical scalar coefficients and `c` ranged over the specified `uint32_t` region.

## 10.2 Object assumptions

Where required by the production interface and theorem:

- input polynomial objects were valid;
- output buffers were valid;
- input and output objects obeyed the required non-aliasing relationship;
- two-run relational objects were distinct where distinctness was part of the theorem construction;
- output arrays were separate in determinism harnesses.

## 10.3 Build assumptions

The theorem applies to:

- the frozen commit;
- ML-KEM-768;
- portable C;
- no assembly path;
- the recorded namespace/build macros;
- C90 compilation through `goto-cc`;
- the accepted support-adapter scope.

## 10.4 Machine-model assumptions

The results rely on CBMC’s model of:

- fixed-width integers;
- signed and unsigned conversions;
- pointer and object semantics;
- array bounds;
- shifts;
- explicit or expected unsigned wrap behavior;
- finite loop unrolling.

T5 explicitly modelled low-32-bit wrapping to avoid ambiguity in the evidence-local parameter expression.

## 10.5 Loop assumptions

Production-loop theorems used explicit complete unwind bounds and unwinding assertions. T1 also included expected-failure insufficient-bound controls.

Loop-free scalar T5 stages correctly used no unnecessary unwind set.

## 10.6 Tool trust

The trusted computing base includes:

- CBMC 6.9.0;
- goto-cc and goto-instrument;
- the SAT solver;
- compiler/front-end modelling;
- support adapters;
- shell/Python evidence scripts;
- the correctness of the independent property formulation.

Reachability, mutation testing, body inspection, and hash binding reduce risk but do not eliminate the trusted computing base.

---

# 11. Why the active arithmetic T3 and T4 proposals were deferred

## 11.1 Numbering history must be clarified

An older MSG-T1 preregistration used:

```text
MSG-T3 = output initialization independence / state footprint
MSG-T4 = subtract–reduce–tomsg composition
```

Later campaign notes reused the labels “T3” and “T4” informally for different arithmetic refinements:

```text
later T3 = exact quotient-cell partition
later T4 = unique/safe multiplier characterization
```

These two numbering systems must not be silently merged.

For the final thesis record, the accepted identifiers are:

```text
MSG-T1 = exact fixed-production semantics
MSG-T2 = relational/locality/confinement/determinism
MSG-T5 = exact admissible offset interval
```

The deferred arithmetic ideas should be renamed in future planning to avoid examiner confusion, for example:

```text
ARITH-QCELL
ARITH-MULTIPLIER
```

The older initialization-independence and composition proposals remain separate possible future work.

## 11.2 Deferred quotient-cell partition

The quotient-cell proposal would decompose the internal fixed arithmetic into the cells leading to output zero or one.

T1 already proved the externally relevant exact canonical partition:

```text
0..832      -> 0
833..2496   -> 1
2497..3328  -> 0
```

A quotient-cell proof could explain the internal arithmetic in more detail, but it would mostly refine the same fixed decision already anchored by T1.

Classification:

```text
mathematically interesting:          yes
false:                               not shown
impossible:                          no
independent implementation assurance: limited after T1
reason deferred:                     overlap and scope economy
```

## 11.3 Deferred multiplier characterization

The multiplier proposal would vary or characterize the fixed multiplier `1290168`.

It would reuse:

- the same scalar expression;
- the same canonical domain;
- the same threshold oracle;
- much of the same modular-arithmetic partitioning.

It could become a valid new parameter theorem, but after T1 and T5 it would add a second parameter-space campaign around the same helper. The incremental thesis value was judged lower than moving to another production function or composition layer.

Classification:

```text
potentially distinct parameter theorem: yes
required for T1/T2/T5 acceptance:       no
reason deferred:                        limited marginal value, proof/evidence bloat,
                                        and MSc scope control
```

## 11.4 Why T5 was retained

T5 was retained because it passed a stronger distinctness gate:

- T1 checks one fixed production offset;
- T2 checks relations between executions;
- T5 characterizes every `uint32_t` offset while fixing multiplier and shift;
- native fixed contracts did not express that parameter-space theorem;
- no equivalent native parameterized-offset theorem was found;
- T5 has exact sufficiency, exact necessity, complete outside partitioning, reachability, and endpoint mutations.

The decision was therefore not:

```text
T3/T4 were too hard, so they were abandoned.
```

It was:

```text
T3/T4 offered insufficient independent thesis value relative to their cost;
T5 offered a genuinely different and exact robustness result.
```

---

# 12. Consolidated proved/support/not-proved matrix

| Claim | Evidence | Status |
|---|---|---|
| Exact canonical coefficient-to-bit threshold for real production | T1 positive theorem | **Proved within scope** |
| Correct mapping of all 256 coefficients to corresponding output bits | T1 positive theorem | **Proved within scope** |
| Correct LSB-first packing into 32 bytes | T1 positive theorem | **Proved within scope** |
| Threshold and index classes are reachable | T1 12/12 coverage | **Supported by reachability** |
| Positive result remains after cover removal | T1 companion | **Proved within companion model** |
| Multi-iteration loops are sensitive to insufficient bounds | T1 four controls | **Supported by expected failures** |
| Registered T1 semantic defects are detected | T1 8/8 mutations | **Proved for registered mutant family** |
| Relational XOR law | T2 R1 | **Proved within scope** |
| Selected coefficient locality | T2 R2A | **Proved within scope** |
| Other output bits are preserved when only selected coefficient may change | T2 R2B | **Proved within scope** |
| Byte confinement | T2 R2B consequence | **Proved within scope** |
| Same compression decision implies same selected output bit | T2 R3A | **Proved within scope** |
| Input polynomials remain unchanged | T2 R3B | **Proved within scope** |
| Equal complete input values produce equal complete messages | T2 R3B | **Proved within scope** |
| All 43 T2 semantic regions/goals are reachable | T2 companions | **Supported by reachability** |
| Five T2 antecedent/corruption defects are rejected | T2 mutations | **Proved for registered mutants** |
| Parameterized offset model equals real helper at production offset | T5 MSG05C | **Proved within scope** |
| Parameterized offset model equals real `tomsg` bit at production offset | T5 MSG05C | **Proved within scope** |
| Every offset inside exact interval works for every canonical coefficient | T5 MSG05D | **Proved within scope** |
| Every `uint32_t` offset outside interval has a canonical counterexample | T5 MSG05E | **Proved within scope** |
| Exact admissible interval is `[1073417800,1074063871]` | T5 D+E | **Proved within scope** |
| Production offset is an interior interval member | T5 B+C+D | **Proved within scope** |
| All three outside partitions are reachable | T5 MSG05F | **Supported by reachability** |
| Both interval endpoints are one-step tight | T5 mutations | **Proved for adjacent mutations** |
| Every possible `mlk_poly_tomsg` property | none | **Not proved** |
| Noncanonical behavior | none | **Not proved** |
| All ML-KEM parameter sets | none | **Not proved** |
| Assembly/object-code equivalence | none | **Not proved** |
| Constant-time/side-channel security | none | **Not proved** |
| Entire ML-KEM correctness or security | none | **Not proved** |
| Absolute first-ever novelty | public search cannot establish | **Not claimed** |

---

# 13. Novelty review methodology

## 13.1 Novelty levels

Novelty is separated into three levels.

### Repository-level novelty

Does the frozen `mlkem-native` revision already contain the same theorem or an equivalent harness obligation?

### Campaign-level originality

Is the combined theorem, non-vacuity, mutation, correction, provenance, and freeze architecture independently authored and different from the native proof workflow?

### Global research novelty

Has any public or private work anywhere previously proved an equivalent theorem, possibly under different terminology or in another formal system?

Only the first two levels can be supported strongly from the current evidence. The third cannot be guaranteed by web search.

## 13.2 Sources and searches reviewed

The review used:

- the frozen local `mlkem-native` source;
- local `proofs/cbmc` harnesses and Makefiles;
- source contracts for `mlk_scalar_compress_d1` and `mlk_poly_tomsg`;
- the official/public `mlkem-native` repository and public descriptions;
- NIST FIPS 203;
- public reporting on `mlkem-native` verification;
- public ML-KEM/Kyber formal-verification projects;
- searches for:
  - `mlk_poly_tomsg`;
  - `poly_tomsg`;
  - `mlk_scalar_compress_d1`;
  - `1290168`;
  - exact admissible offset;
  - parameterized offset;
  - offset interval;
  - `Compress1`;
  - CBMC functional refinement;
  - relational locality;
  - exact threshold verification;
  - mutation and non-vacuity controls.

Fresh public verification was performed on 23 July 2026.

## 13.3 What the search established

The review confirmed that:

- FIPS 203 standardizes ML-KEM and its three parameter sets;
- broad formal verification of ML-KEM/Kyber already exists;
- `mlkem-native` publicly describes substantial CBMC, HOL Light, and implementation assurance;
- the frozen repository has native fixed-function `scalar_compress_d1` and `poly_tomsg` CBMC harnesses;
- no equivalent frozen native theorem was found for the complete T1/T2 assertions;
- no frozen native theorem was found that parameterizes the offset and derives the complete exact interval;
- exact public searches did not locate another source stating the T5 interval or its endpoint witnesses.

## 13.4 What the search cannot establish

A public search cannot prove that no equivalent work exists in:

- unpublished research;
- private industrial proof repositories;
- unindexed theses;
- differently named lemmas;
- future work;
- proof developments whose low-level consequences imply the theorem without naming it.

Therefore, the phrase:

```text
no exact public match was located in the review
```

is defensible.

The phrase:

```text
nobody has ever proved this
```

is not defensible.

---

# 14. Novelty findings and potency

## 14.1 What is not novel

### Standard mathematics

The following are not new discoveries:

- ML-KEM;
- `Compress1`;
- modulus `3329`;
- 256 coefficients;
- 32 output bytes;
- LSB-first message packing;
- the production multiplier, offset, shift, and loops;
- deterministic functions producing equal outputs for equal inputs;
- locality and frame properties as general verification concepts.

### Broad ML-KEM verification

Formal proofs of ML-KEM/Kyber security, correctness, implementations, and assembly routines already exist. The contribution cannot be “first formal proof of ML-KEM.”

### Broad AI-assisted formal verification

Using an LLM to propose specifications, assertions, harnesses, or proofs is an active research area. “Use AI and then run a verifier” is not novel by itself.

## 14.2 MSG-T1 novelty potency

The T1 threshold mathematics is standard.

The stronger originality lies in the exact case-study artefact:

- all-256-bit production postcondition;
- independent oracle validation;
- explicit packing equality;
- boundary and index covers;
- cover-neutral companion;
- operational loop controls;
- two-sided semantic mutations;
- equivalent-mutant screening;
- freeze-before-solving;
- deterministic evidence architecture;
- preservation and classification of generated-script failures.

Assessment:

```text
mathematical novelty:                    low
new cryptographic algorithm:             none
new implementation:                      none
new dedicated function-specific theorem: moderate
new harness/evidence package:            strong within MSc scope
```

## 14.3 MSG-T2 novelty potency

The abstract ideas of locality, determinism, and frame preservation are standard.

The case-study originality lies in their exact formulation for the real frozen `mlk_poly_tomsg` body:

- weak local antecedents;
- unrestricted unrelated coefficients;
- two real production calls;
- cross-bit preservation stronger than byte-only confinement;
- semantic-decision equality without coefficient equality;
- complete-message determinism over distinct objects and outputs;
- targeted antecedent mutations.

Assessment:

```text
general mathematical concepts:           not novel
function-specific relational theorem set: moderate to strong
integrated falsification/evidence package: strong within case study
```

## 14.4 MSG-T5 novelty potency

T5 has the strongest mathematical-novelty potential of the three families.

The exact result:

```text
[1073417800, 1074063871]
```

is not merely the known production offset and is not stated in the native fixed contract.

The campaign contributes:

- an exact complete `uint32_t` parameter characterization;
- a proof that all 646,072 inside values work;
- a proof that every outside value fails for some canonical input;
- a complete three-region counterexample map;
- exact nearest rejected values and witnesses;
- formal model-to-production binding;
- endpoint mutation tightness.

No exact public match for this interval theorem was located in the searches performed.

Assessment:

```text
mathematical novelty potential:           moderate to strong
repository-level novelty:                 strong
campaign-level distinctness:              strong
absolute first-ever status:               unsupported
peer-reviewed novelty confirmation:       not yet obtained
```

The safest formulation is:

> T5 appears to be an original implementation-specific arithmetic robustness theorem and is demonstrably absent from the equivalent frozen native proof obligations inspected. No exact public match was located in the 23 July 2026 search. It is therefore claimed as a distinct and apparently original MSc contribution, not as an unconditional world-first result.

## 14.5 Overall novelty potency

| Dimension | Assessment | Basis |
|---|---|---|
| New cryptographic primitive | None | no new algorithm |
| New production implementation | None | verifies upstream source |
| New standard mathematics | Low | FIPS behavior already defined |
| New T1 function-specific refinement artefact | Moderate | exact all-bit theorem not matched in frozen native contract |
| New T2 relational theorem family | Moderate to strong | exact two-run obligations and weak antecedents |
| New T5 exact parameter theorem | Moderate to strong, strongest potential | complete interval and necessity/sufficiency characterization |
| New harness engineering | Strong within case study | independent theorem artefacts |
| New falsification controls | Strong as integrated package | covers, loop controls, targeted mutations |
| New reproducibility architecture | Strong within MSc scope | hashes, manifests, frozen GOTO/commands/results |
| New evidence about AI usefulness/failures | Moderate to strong | successful artefacts plus preserved deterministic corrections |
| Universal first-ever claim | Unsupported | search cannot prove nonexistence |
| MSc thesis contribution | Strong if narrowly framed | substantial theorem, evidence, failures, limits, reproducibility |

---

# 15. Defensible novelty claims

## 15.1 Full professor-facing claim

> This thesis presents an independently authored and reproducibly packaged CBMC functional-verification campaign for the frozen ML-KEM-768 portable-C `mlk_poly_tomsg` implementation. MSG-T1 verifies the exact canonical coefficient-to-message-bit and least-significant-bit-first packing relation against an independently validated `Compress1` oracle. MSG-T2 verifies two-execution relational XOR, coefficient locality, cross-bit preservation, same-decision invariance, input-frame preservation, and complete-message determinism. MSG-T5 characterizes the complete `uint32_t` offset set preserving the canonical one-bit compression semantics while fixing the production multiplier and shift, proving the exact interval `[1073417800,1074063871]` through model-to-production binding, universal sufficiency, universal outside necessity, reachability, and endpoint mutations. The frozen native repository already contained fixed contracts and CBMC harnesses, so the contribution is not claimed as the first verification of ML-KEM or of `mlk_poly_tomsg`. Its originality lies in the new property obligations, independently authored harnesses, parameter-space theorem, falsification controls, and evidence architecture. A public review completed on 23 July 2026 located no exact match for the combined theorem-and-evidence package or the T5 interval result. The work is therefore presented as a distinct and apparently original MSc case-study contribution, not as an absolute first-ever claim.

## 15.2 Short claim

> The originality lies not in rediscovering `Compress1`, but in constructing, formally checking, falsifying, and reproducibly packaging new fixed-function, relational, and exact parameter-robustness theorem families for the frozen production `mlk_poly_tomsg` implementation.

## 15.3 T5-specific claim

> For the frozen production arithmetic with multiplier `1290168`, shift `31`, and modulo-\(2^{32}\) behavior, the complete `uint32_t` offset set preserving the canonical one-bit ML-KEM decision for all 3,329 coefficients is exactly `[1073417800,1074063871]`. The production offset `2^30` is an interior member. No equivalent parameterized-offset theorem was found in the frozen native proof tree, and no exact public match was located in the review completed on 23 July 2026.

---

# 16. Claims that must not be used

The following statements overclaim:

```text
The first formal proof of ML-KEM was produced.
```

```text
All of `mlkem-native` was proved correct.
```

```text
Nobody has ever proved mlk_poly_tomsg.
```

```text
The upstream repository had no proof or harness for mlk_poly_tomsg.
```

```text
T1, T2, and T5 prove every possible property of mlk_poly_tomsg.
```

```text
T5 proves the production function accepts arbitrary offsets.
```

```text
The interval is definitely a world-first discovery.
```

```text
Successful CBMC results are independent of assumptions and modelling.
```

```text
Property-record counts equal the number of new mathematical theorems.
```

```text
Mutation killing proves detection of every possible bug.
```

```text
The results prove constant-time or side-channel security.
```

---

# 17. Important failures and corrections

Preserving failed generated artefacts is part of the research result.

## 17.1 Pragma-scope and build integration

Generated builds initially required careful control of verification pragmas and helper visibility. Evidence-local scope headers were introduced rather than editing production.

## 17.2 Brittle property-ID assumptions

Some scripts guessed unwind or assertion identifiers and falsely rejected otherwise successful results. Corrections inspected registered properties instead of assuming names.

## 17.3 Loop classification mistakes

A macro-origin loop was initially expected to fail at bound one. Inspection showed bound one was complete. The campaign corrected the classification and tested the actual multi-iteration loops.

## 17.4 Permission-preserving copy mistake

A mutation generator preserved read-only modes with `shutil.copy2()` and then could not edit isolated mutant copies. The correction used byte copying and explicitly writable isolated files without altering frozen evidence.

## 17.5 Lock-boundary mistake

A consolidation stage checked the outer container instead of the actual frozen candidate root. The correction verified the true frozen boundary.

## 17.6 Post-`tee` capture-location mistake

A script searched for status text inside a file even though that status was printed after the `tee` pipeline closed. The corrected audit validated only content actually present.

## 17.7 T2 Markdown backtick expansion

An unquoted heredoc interpreted Markdown backticks as shell command substitution. The proof and archive gates passed, but the summary Markdown requires repair and re-freeze.

## 17.8 Scientific classification

None of these script, parser, permission, or packaging problems was presented as an implementation counterexample. None was repaired by weakening a theorem or modifying production source.

This failure record supports the thesis evaluation of LLM usefulness and failure modes.

---

# 18. Contribution to the thesis research questions

## RQ1 — From specification and source context to candidate CBMC artefacts

The campaign demonstrates generation of:

- property decompositions;
- independent oracles;
- one-run and two-run harnesses;
- parameterized robustness models;
- assumptions and assertions;
- build adapters;
- structural audits;
- reachability companions;
- loop controls;
- implementation and theorem mutations;
- evidence parsers;
- manifests and theorem records.

It also shows that generated artefacts require deterministic correction and documented acceptance checks.

## RQ2 — Lessons from high-assurance PQC workflows

The work adopts:

- frozen source identities;
- explicit theorem scope;
- independent specification checks;
- source/body binding;
- exact machine-model assumptions;
- complete finite-loop treatment;
- non-vacuity controls;
- mutation testing;
- provenance and reproducibility;
- transparent trusted boundaries;
- narrow non-claims.

## RQ3 — Usefulness, failures, and documented correction

Usefulness evidence includes:

- rapid candidate property formulation;
- detailed terminal scripts;
- relational and parameter theorem design;
- automatic result parsing;
- mutation generation;
- evidence documentation.

Failure evidence includes:

- pragma mistakes;
- property-ID assumptions;
- loop misunderstandings;
- permission errors;
- lock-boundary errors;
- capture-location errors;
- Markdown heredoc expansion;
- novelty-overclaim risk.

This mixed evidence is more scientifically useful than reporting only successful generations.

---

# 19. Evidence index

## 19.1 T1 authoritative sequence

```text
MSG-00CDE    source and path binding
MSG-01F      accepted candidate recovery
MSG-01G-R1   frozen positive execution input
MSG-01H      authoritative positive execution
MSG-01I-R1   frozen reachability-control family
MSG-01J-R3   final reachability/non-vacuity result
MSG-01K-R1   frozen mutation family
MSG-01L-R1   authoritative mutation execution
MSG-01M-R2   final evidence consolidation
```

## 19.2 T2 authoritative sequence

```text
MSG02B   R1 relational XOR positive proof
MSG02C   R1 reachability and drop-B mutation
MSG02D   R2A coefficient-locality proof
MSG02E   R2B cross-bit-preservation proof
MSG02F   R2A/R2B reachability
MSG02G   R2A and R2B mutations
MSG02H   R3A same-decision-invariance proof
MSG02I   R3B frame/determinism proof
MSG02J   R3A/R3B reachability
MSG02K   R3A opposite-decision mutation
MSG02L   R3B unequal-input mutation
MSG02M   final T2 acceptance/freeze with summary-document defect
```

## 19.3 T5 authoritative sequence

```text
MSG05A   source/novelty gate
MSG05B   exact deterministic interval derivation
MSG05C   parameterized-model to production binding
MSG05D   universal inside-interval sufficiency
MSG05E   universal outside-interval necessity
MSG05F   partition reachability and endpoint mutations
MSG05G   final acceptance and deterministic freeze
```

---

# 20. Recommended next work

Before publishing a single final `mlk_poly_tomsg` closure package:

1. repair the T2 summary Markdown;
2. re-freeze T2 without rerunning its CBMC theorems;
3. create one combined T1/T2/T5 campaign index;
4. preserve the numbering clarification for T3/T4;
5. keep the three theorem families separate in results tables;
6. move the practical case study to another production target, preferably `mlk_poly_frommsg`, rather than repeatedly refining the same scalar arithmetic.

Potential future theorem families include:

- `mlk_poly_frommsg` exact encoding semantics;
- `frommsg → tomsg` round trip;
- bit locality and determinism for `frommsg`;
- separately named output-initialization/footprint theorem;
- subtract–reduce–tomsg composition;
- later-source-revision replay;
- ML-KEM-512 and ML-KEM-1024 replay;
- comparison with a second formal tool;
- compiler/object-code refinement;
- side-channel analysis with appropriate dedicated tools.

---

# 21. Final integrated conclusion

Three property-specific theorem families were proved for the frozen ML-KEM-768 portable-C `mlk_poly_tomsg` implementation and its scalar decision path.

MSG-T1 establishes the exact fixed-production semantic mapping and packing relation for every canonical coefficient and output position.

MSG-T2 establishes meaningful two-execution relational behavior: XOR correspondence, coefficient locality, cross-bit preservation, byte confinement, same-decision invariance, input-frame preservation, and complete-message determinism.

MSG-T5 establishes an exact implementation-connected parameter theorem: with the production multiplier and shift fixed, the admissible `uint32_t` offset values are exactly:

\[
[1073417800,1074063871].
\]

The production offset `2^30` lies strictly inside that interval.

The accepted evidence includes positive solver results, complete finite-loop treatment where relevant, explicit reachability, expected-failure controls, targeted mutations, source/body/result binding, clean worktree checks, GOTO validation, manifests, and deterministic archive creation.

The work does not prove all of ML-KEM or every property of `mlk_poly_tomsg`. Its strongest novelty is not a new cryptographic primitive. It is the independently authored, implementation-specific theorem set—especially the exact T5 parameter characterization—and the integrated falsification-resistant evidence workflow.

The correct final originality position is:

> The campaign is demonstrably distinct from the equivalent frozen native proof obligations inspected and no exact public match for the combined T1/T2/T5 package or the T5 interval theorem was located in the public review completed on 23 July 2026. This supports a strong repository-level novelty claim and a carefully qualified claim of an apparently original MSc case-study contribution. It does not support an unconditional first-ever claim.

---

# References

Amazon Science (2026) ‘Verifying and optimizing post-quantum cryptography at Amazon’, 7 April. Available at: https://www.amazon.science/blog/verifying-and-optimizing-post-quantum-cryptography-at-amazon (Accessed: 23 July 2026).

Almeida, J.B. et al. (2024) ‘Formally Verifying Kyber: Episode V: Machine-checked IND-CCA security and correctness of ML-KEM in EasyCrypt’, *CRYPTO 2024 Artifact Archive*. Available at: https://artifacts.iacr.org/crypto/2024/a3/ (Accessed: 23 July 2026).

Barbosa, M. et al. (2025/2026) ‘Formally Verified Correctness Bounds for Lattice-Based Cryptography’. Public research record available through Institut Polytechnique de Paris (Accessed: 23 July 2026).

Kroening, D., Schrammel, P. and Tautschnig, M. (2023) ‘CBMC: The C Bounded Model Checker’, arXiv:2302.02384. Available at: https://arxiv.org/abs/2302.02384 (Accessed: 23 July 2026).

National Institute of Standards and Technology (2024) *Module-Lattice-Based Key-Encapsulation Mechanism Standard*. FIPS 203. Gaithersburg, MD: NIST. DOI: 10.6028/NIST.FIPS.203.

pq-code-package (2026) *mlkem-native: Secure, fast, and portable C90 implementation of ML-KEM / FIPS 203*. Available at: https://github.com/pq-code-package/mlkem-native (Accessed: 23 July 2026).

pq-code-package (2026) *rust-libcrux*. Formal verification status for portable and optimized ML-KEM code. Available at: https://github.com/pq-code-package/rust-libcrux (Accessed: 23 July 2026).

---

# End-of-record declaration

This document records the completed and reviewed MSG-T1, MSG-T2, and MSG-T5 work as an evidence-bound research result.

It does not replace:

- frozen source files;
- harnesses;
- support adapters;
- GOTO binaries;
- commands;
- raw CBMC JSON;
- coverage outputs;
- mutation outputs;
- manifests;
- terminal captures;
- deterministic archives.

Where this narrative and the frozen machine-readable evidence disagree, the frozen source, exact commands, GOTO models, raw solver outputs, and verified manifests are authoritative.
