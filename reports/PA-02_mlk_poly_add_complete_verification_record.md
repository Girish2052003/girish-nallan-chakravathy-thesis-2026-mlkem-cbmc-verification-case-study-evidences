# PA-02 Verification Record

## Property-Focused CBMC Verification of `mlk_poly_add`

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Record date:** 16 July 2026  
**Target repository:** `pq-code-package/mlkem-native`  
**Pinned repository commit:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Executed parameter configuration:** ML-KEM-768  
**Target implementation path:** portable C implementation in `mlkem/src/poly.c`  
**Formal-verification tool:** CBMC 6.9.0, 64-bit x86-64 Linux build  
**Execution environment:** Ubuntu virtual machine under VirtualBox; VM memory increased from approximately 5 GiB to 8 GiB on a 16 GiB host  
**Campaign status:** **COMPLETE FOR THE PLANNED PA-02 PROPERTY SUITE**

---

## 1. Purpose of this record

This document records the complete PA-02 case-study work performed for `mlk_poly_add`. It covers:

- the verification objective;
- the original combined harness and its resource failure;
- the decomposition into PA-02A through PA-02E;
- the exact symbolic domains, assumptions, assertions, and safety checks;
- the relationship between the five focused proofs and the original combined proof obligation;
- the observed CBMC outcomes;
- the distinctness of the custom harness suite from the repository's existing proof infrastructure;
- the precise claims supported by the evidence;
- the claims that remain outside the evidence;
- reproducibility and archival requirements;
- lessons relevant to later experiments.

The record is intentionally property-specific. It does not use the phrase “completely correct” without an explicit scope boundary.

---

## 2. Executive result

The PA-02 campaign verified the planned functional, algebraic, modular, and frame properties of the portable C `mlk_poly_add` implementation at the pinned commit under ML-KEM-768.

The original combined harness was too large for the initial VM memory allocation. It combined three production calls, modular calculations, relational properties, safety instrumentation, full loop unwinding, and two complete CBMC executions in one runner. The first text verification reached the propositional-reduction stage, consumed almost all available VM memory, and was manually interrupted when available memory fell to approximately 9.3 MiB. That interrupted run produced no valid verification verdict and is not counted as proof evidence.

The same planned property suite was then decomposed into five focused, self-contained harnesses:

| Campaign | Main theorem | Final status |
|---|---|---|
| PA-02A | Exact signed coefficient-wise addition | `VERIFICATION SUCCESSFUL` |
| PA-02B | Modulo-`q` congruence and canonical-residue refinement | `VERIFICATION SUCCESSFUL` |
| PA-02C | Read-only operand preservation and local write footprint | `VERIFICATION SUCCESSFUL` |
| PA-02D | Relational commutativity | `VERIFICATION SUCCESSFUL` |
| PA-02E | Additive identity over the complete `int16_t` domain | `VERIFICATION SUCCESSFUL` |

The decomposition did **not** reduce the polynomial length, replace symbolic inputs with samples, restrict the inputs to canonical residues, stub the target function, omit complete unwinding, or disable the selected safety checks. It removed only unrelated proof branches from each individual solver query.

Accordingly, the defensible conclusion is:

> The complete planned PA-02 property suite was successfully verified for the portable C `mlk_poly_add` implementation at commit `d9613cf60de3132d32475c102d8c2781d84feb34` under the ML-KEM-768 configuration and the stated harness assumptions.

This conclusion does not mean that every conceivable property, calling context, implementation path, or ML-KEM component has been proved.

---

## 3. Target function and intended semantic model

`mlk_poly_add` performs in-place polynomial addition. The writable first polynomial is initialized with a left operand and the read-only second polynomial supplies the right operand.

For coefficient index `i`, the intended implementation-level relation is:

```text
result[i] = a[i] + b[i]
```

The polynomial dimension and modulus are bound in every harness by assertions:

```text
MLKEM_N = 256
MLKEM_Q = 3329
INT16_MIN = -32768
INT16_MAX = 32767
```

The assertions are not assumptions. A mismatched build must therefore fail visibly rather than silently changing the experiment.

### 3.1 Contract-valid signed domain

For PA-02A through PA-02D, the symbolic domain is:

```text
D = { (a,b) in int16^256 × int16^256 |
      for every i,
      INT16_MIN <= int32(a[i]) + int32(b[i]) <= INT16_MAX }
```

Each `a[i]` and `b[i]` may independently be any signed 16-bit value, including:

- negative values;
- values in the canonical range `[0,q-1]`;
- values greater than or equal to `q`;
- values less than zero;
- any other non-canonical `int16_t` representative.

The only semantic restriction is that the exact mathematical coefficient sum remains representable by the target `int16_t` coefficient type.

The precondition is expressed in `int32_t`:

```c
mathematical_sum = (int32_t)a.coeffs[i] + (int32_t)b.coeffs[i];
__CPROVER_assume(mathematical_sum >= (int32_t)INT16_MIN);
__CPROVER_assume(mathematical_sum <= (int32_t)INT16_MAX);
```

The wider type is essential. The assumption expression itself cannot overflow when adding two `int16_t` values.

### 3.2 PA-02E domain

PA-02E proves `a + 0 = a`. Adding zero is representable for every `int16_t` value. PA-02E therefore quantifies over the entire `int16_t^256` domain and contains **zero semantic assumptions**.

### 3.3 Non-aliasing boundary

The focused harnesses use distinct writable target and read-only operand objects. Explicit address-inequality assertions make this legal calling boundary visible.

PA-02 does not prove behavior for overlapping objects or for a call in which the writable first argument aliases the second argument. Such a claim would require a separate aliasing experiment based on the API contract.

---

## 4. Original combined PA-02 harness

### 4.1 Objective

The original parent harness was:

```text
pa02_mlk_poly_add_full_signed_contract_valid_harness.c
```

It encoded the following property families in a single model:

1. exact signed addition;
2. modulo-`q` congruence;
3. canonical-residue refinement;
4. read-only operand preservation;
5. commutativity;
6. additive identity;
7. parameter and representation bindings;
8. explicit object separation;
9. CBMC-instrumented memory and arithmetic safety;
10. complete loop unwinding.

It executed the production target three times:

```text
sum_ab         := a + b
sum_ba         := b + a
identity_result := a + 0
```

### 4.2 Resource outcome

The original run reached:

```text
Passing problem to propositional reduction
converting SSA
Running propositional reduction
```

Process monitoring showed active execution rather than a deadlock:

```text
STAT = R+
CPU  ≈ 99.9%
```

Memory continued to rise. The run was manually stopped after available memory fell to approximately 9.3 MiB. The interruption was a resource-management decision, not a failed property verdict.

The interrupted result must be classified as:

```text
INCONCLUSIVE — MANUALLY INTERRUPTED DURING PROPOSITIONAL REDUCTION
```

It must not be cited as either success or property failure.

### 4.3 Causes of the formula growth

The high cost was attributable to the conjunction of:

- 256 symbolic coefficient pairs;
- full signed 16-bit domains;
- per-coefficient representability assumptions;
- three separate executions of the production loop;
- exact, modular, frame, identity, and relational assertions;
- safety instrumentation;
- full unwinding;
- an original runner that performed a complete text verification and then repeated the complete proof in JSON mode.

The number `768` was not an unwind value. It selected the ML-KEM parameter set. The actual unwind setting was `257`.

---

## 5. Verification strategy: property-focused decomposition

The combined obligation was decomposed because independent universal proofs can be conjoined logically when they:

- target the same production function;
- use the same pinned source commit;
- use compatible domains and calling boundaries;
- retain the necessary safety instrumentation;
- prove each property directly rather than assume another campaign's conclusion.

Conceptually, if the focused runs establish:

```text
for all x in D: P_A(x)
for all x in D: P_B(x)
for all x in D: P_C(x)
for all x in D: P_D(x)
```

then they establish:

```text
for all x in D: P_A(x) and P_B(x) and P_C(x) and P_D(x)
```

PA-02E proves its theorem over a stronger domain because it uses no representability assumptions.

The decomposition is therefore a solver-engineering change, not a reduction of the stated PA-02 suite.

### 5.1 Anti-weakening rules applied

The following were retained in every relevant focused harness:

- `MLKEM_N == 256`;
- symbolic values for every coefficient;
- complete signed `int16_t` range;
- negative and non-canonical values;
- direct compilation of the production `mlkem/src/poly.c`;
- no target-function stub;
- no concrete input list;
- no reduced polynomial dimension;
- no assumption of the expected result;
- complete loop unwinding;
- enabled safety checks;
- repository commit binding;
- deterministic artefact hashing and result-directory creation.

The only elements removed from a given harness were properties and production calls assigned to other focused campaigns.

---

## 6. Common build and CBMC configuration

Each runner builds a GOTO model directly from the custom harness and the production source:

```bash
goto-cc \
  -I. \
  -Imlkem \
  -Imlkem/src \
  -DMLK_CONFIG_PARAMETER_SET=768 \
  <PA-02 harness>.c \
  mlkem/src/poly.c \
  -o <result-directory>/pa02x_mlk_poly_add.goto
```

The runners deliberately:

- do not define the repository's CBMC annotation mode;
- do not enable native arithmetic;
- do not link a repository proof harness;
- execute the portable production C body directly.

The common verification options are:

```text
--function main
--bounds-check
--pointer-check
--pointer-overflow-check
--signed-overflow-check
--unsigned-overflow-check
--conversion-check
--div-by-zero-check
--undefined-shift-check
--unwind 257
--unwinding-assertions
```

### 6.1 Meaning of the unwind bound

The target loops operate over 256 coefficients. The unwind value `257` is used to cover all 256 loop-body executions and the exit condition. `--unwinding-assertions` makes insufficient unwinding a visible failed property rather than silently truncating the proof.

A successful run therefore includes evidence that the fixed-size loops were completely unwound under this model.

### 6.2 Solver path

No external solver option such as `--z3` or `--cvc5` is supplied. The installed CBMC 6.9.0 build's default decision-procedure path is used. Litani is not involved.

### 6.3 Single authoritative execution

The focused runners perform one authoritative CBMC execution. This avoids the original runner's duplicate full text and JSON proof runs.

PA-02D and PA-02E additionally require both:

- CBMC exit code `0`; and
- an exact `VERIFICATION SUCCESSFUL` marker.

PA-02A through PA-02C gate their summary on build and CBMC exit codes. Their observed terminal outputs also contained the explicit success marker. Standardising PA-02A through PA-02C to the later marker-gated pattern is recommended for final release hardening, but it does not change the successful results already observed.

---

## 7. PA-02A — exact signed addition

### 7.1 Artefacts

```text
Harness: pa02a_mlk_poly_add_exact_signed_contract_valid_harness.c
Runner:  run_pa02a_mlk_poly_add_exact_signed_cbmc.sh
Bundle:  pa02a_mlk_poly_add_exact_signed_bundle.zip
```

### 7.2 Primary theorem

For every `(a,b)` in the contract-valid signed domain and every coefficient `i`:

```text
production_result[i] = int32(a[i]) + int32(b[i])
```

Because the mathematical sum is assumed representable in `int16_t`, the concrete coefficient must equal the exact mathematical value, not merely a wrapped value.

### 7.3 Direct properties

- `PA02A_P1_EXACT_SIGNED_SUM`
- `PA02A_P2_LEFT_SOURCE_FRAME`
- `PA02A_P3_RIGHT_OPERAND_FRAME`

The target is initialized as a copy of `a` and the production function is invoked once:

```c
result = a;
mlk_poly_add(&result, &b);
```

The exact-sum assertion is the central PA-02 functional theorem.

### 7.4 Auxiliary obligations

- `MLKEM_N`, `MLKEM_Q`, and signed representation bindings;
- non-empty-domain witness;
- explicit separation of `result`, `a`, and `b`;
- complete source preservation checks.

### 7.5 Observed result

```text
0 of 338 failed
VERIFICATION SUCCESSFUL
build_exit=0
cbmc_exit=0
final_status=VERIFICATION_SUCCESSFUL
```

Result directory reported:

```text
cleanroom_results/pa02a_mlk_poly_add_exact_signed_768_20260716T041805Z
```

### 7.6 Interpretation

PA-02A establishes the strongest core implementation-level statement in the campaign: the portable production function computes the exact signed coefficient sum for all symbolic contract-valid operands, not merely for canonical ML-KEM residues or selected examples.

---

## 8. PA-02B — modulo-`q` refinement

### 8.1 Artefacts

```text
Harness: pa02b_mlk_poly_add_modq_refinement_contract_valid_harness.c
Runner:  run_pa02b_mlk_poly_add_modq_refinement_cbmc.sh
Bundle:  pa02b_mlk_poly_add_modq_refinement_bundle.zip
```

### 8.2 Canonicalisation function

The harness defines a specification-side helper:

```text
rho(x) = x mod q, adjusted into [0,q-1]
```

The helper is not a replacement for the target function. It is a mathematical abstraction used to state the modular postconditions.

### 8.3 Direct properties

- `PA02B_P1_EXACT_SIGNED_BRIDGE`
- `PA02B_P2_MOD_Q_CONGRUENCE`
- `PA02B_P3_CANONICAL_RESIDUE_REFINEMENT`
- `PA02B_P4_HELPER_RANGE`
- `PA02B_P4_HELPER_CONGRUENCE`
- `PA02B_P5_LEFT_SOURCE_FRAME`
- `PA02B_P5_RIGHT_OPERAND_FRAME`

For every contract-valid coefficient pair, PA-02B directly proves:

```text
rho(result[i]) = rho(a[i] + b[i])
```

and:

```text
rho(result[i]) = rho(rho(a[i]) + rho(b[i]))
```

The exact-addition bridge is retained inside PA-02B. The modular result therefore does not assume that PA-02A succeeded.

### 8.4 Helper lemma

For every signed `int16_t` representative `x`, the harness proves:

```text
0 <= rho(x) < q
```

and:

```text
(x - rho(x)) mod q = 0
```

The canonical operand sum is in `[0,2q-2]`, which fits within `int16_t`, so the verified helper domain covers all helper arguments used by the harness.

### 8.5 Domain witnesses

The harness includes explicit witnesses showing that the contract-valid set contains:

- canonical values;
- negative representatives;
- non-canonical representatives such as `q` and `-q`.

These witnesses document non-emptiness and intended scope. They do not replace symbolic quantification.

### 8.6 Observed result

The supplied execution reported:

```text
VERIFICATION SUCCESSFUL
```

The exact generated-property count, elapsed time, peak memory, and result-directory timestamp were not transcribed into the retained record. They remain available in the PA-02B `cbmc_output.txt`, `summary.txt`, and timing log and should be attached to the final experiment archive.

### 8.7 Interpretation

PA-02B establishes that signed and non-canonical concrete representatives produced by `mlk_poly_add` refine the intended addition operation in the ring `Z_q`, provided the concrete signed result is representable.

---

## 9. PA-02C — read-only frame and local write footprint

### 9.1 Artefacts

```text
Harness: pa02c_mlk_poly_add_readonly_frame_contract_valid_harness.c
Runner:  run_pa02c_mlk_poly_add_readonly_frame_cbmc.sh
Bundle:  pa02c_mlk_poly_add_readonly_frame_bundle.zip
```

### 9.2 Primary theorem

The second operand is read-only and must remain unchanged. The writable first operand must receive the exact sum.

### 9.3 Guarded-object design

The harness wraps each polynomial with symbolic 32-bit guard words:

```c
typedef struct
{
  uint32_t guard_before;
  mlk_poly value;
  uint32_t guard_after;
} pa02c_guarded_poly;
```

The guards are symbolic rather than fixed canary constants. Their preservation is therefore universally checked within the harness model.

### 9.4 Direct properties

- `PA02C_P1_EXACT_SIGNED_EFFECT`
- `PA02C_P2_READONLY_OPERAND_FRAME`
- `PA02C_P3_TARGET_PREFIX_GUARD_FRAME`
- `PA02C_P4_TARGET_SUFFIX_GUARD_FRAME`
- `PA02C_P5_OPERAND_PREFIX_GUARD_FRAME`
- `PA02C_P6_OPERAND_SUFFIX_GUARD_FRAME`

The exact target-effect bridge prevents a vacuous frame result in which the function simply performs no writes.

The symbolic guards supplement, but do not replace, CBMC's pointer and bounds checks. They provide explicit local evidence that surrounding fields remain unchanged.

### 9.5 Observed result

```text
0 of 338 failed
VERIFICATION SUCCESSFUL
build_exit=0
cbmc_exit=0
final_status=VERIFICATION_SUCCESSFUL
exit status=0
```

Result directory:

```text
cleanroom_results/pa02c_mlk_poly_add_readonly_frame_768_20260716T053352Z
```

Performance:

```text
Elapsed wall-clock time:       34.31 seconds
User CPU time:                 34.04 seconds
System CPU time:                0.27 seconds
CPU utilisation:                 100%
Maximum resident set size:   195,524 KiB (approximately 191 MiB)
Swaps:                              0
```

### 9.6 Interpretation

PA-02C establishes the intended read-only behavior for the second operand and provides direct local write-footprint evidence while also proving that the writable target receives the correct exact sum.

The guard result is local to the modelled object layout. It must not be described as a whole-program heap-separation theorem.

---

## 10. PA-02D — relational commutativity

### 10.1 Artefacts

```text
Harness: pa02d_mlk_poly_add_commutativity_contract_valid_harness.c
Runner:  run_pa02d_mlk_poly_add_commutativity_cbmc.sh
Bundle:  pa02d_mlk_poly_add_commutativity_bundle.zip
```

### 10.2 Primary theorem

For every contract-valid signed polynomial pair:

```text
production_add(a,b) = production_add(b,a)
```

coefficient-wise.

### 10.3 Two-call relational design

The harness executes the real production function in both legal operand orders:

```c
mlk_poly_add(&sum_ab, &b);
mlk_poly_add(&sum_ba, &a);
```

### 10.4 Direct properties

- `PA02D_P1_FORWARD_EXACT_SIGNED_SUM`
- `PA02D_P2_REVERSE_EXACT_SIGNED_SUM`
- `PA02D_P3_COMMUTATIVITY`
- `PA02D_P4_LEFT_SOURCE_FRAME`
- `PA02D_P5_RIGHT_SOURCE_FRAME`

Both call orders have independent exact-sum bridges. This is important: equality of the two outputs cannot pass merely because both calls return the same incorrect value.

### 10.5 Observed result

The supplied execution reported:

```text
VERIFICATION SUCCESSFUL
```

The exact generated-property count, elapsed time, peak memory, and result-directory timestamp were not transcribed into the retained record. They should be recovered from the preserved PA-02D result directory before the final thesis evidence package is frozen.

### 10.6 Interpretation

PA-02D establishes relational commutativity for the concrete production implementation over the complete contract-valid signed domain and the stated non-aliasing boundary.

---

## 11. PA-02E — additive identity

### 11.1 Artefacts

```text
Harness: pa02e_mlk_poly_add_additive_identity_full_signed_harness.c
Runner:  run_pa02e_mlk_poly_add_additive_identity_cbmc.sh
Bundle:  pa02e_mlk_poly_add_additive_identity_bundle.zip
```

### 11.2 Primary theorem

For every signed and non-canonical polynomial `a`:

```text
a + 0 = a
```

### 11.3 Stronger domain

PA-02E uses zero semantic assumptions. Every coefficient of `a` is an arbitrary symbolic `int16_t` value, and the zero polynomial is initialized concretely.

### 11.4 Direct properties

- `PA02E_P1_EXACT_ZERO_SUM_BRIDGE`
- `PA02E_P2_ADDITIVE_IDENTITY`
- `PA02E_P3_SOURCE_FRAME`
- `PA02E_P4_ZERO_OPERAND_FRAME`

The exact bridge ties the algebraic identity to a correct production execution.

The runner fails closed if a future edit introduces any `__CPROVER_assume` into the harness.

### 11.5 Observed result

```text
0 of 335 failed
VERIFICATION SUCCESSFUL
semantic_assumptions=0
build_exit=0
cbmc_exit=0
verification_success_marker=1
final_status=VERIFICATION_SUCCESSFUL
exit status=0
```

Result directory:

```text
cleanroom_results/pa02e_mlk_poly_add_additive_identity_768_20260716T054818Z
```

Performance:

```text
Elapsed wall-clock time:        0.78 seconds
User CPU time:                  0.66 seconds
System CPU time:                0.11 seconds
CPU utilisation:                 100%
Maximum resident set size:    76,172 KiB (approximately 74.4 MiB)
Swaps:                              0
```

### 11.6 Interpretation

PA-02E proves additive identity across the entire signed 16-bit polynomial domain. This is stronger than proving identity only on the PA-02 contract-valid pair domain.

---

## 12. What the CBMC property counts mean

The terminal summaries such as:

```text
0 of 338 failed
```

and:

```text
0 of 335 failed
```

refer to all CBMC properties generated for that model, not only the manually named functional assertions. The set includes applicable instances of:

- user-written assertions;
- array-bounds checks;
- pointer checks;
- pointer-overflow checks;
- signed-overflow checks;
- unsigned-overflow checks;
- conversion checks;
- division-by-zero checks;
- undefined-shift checks;
- unwinding assertions.

The phrase `(1 iterations)` in the CBMC summary must not be confused with the 256 polynomial loop iterations. The fixed polynomial loops were unrolled according to the `257` unwind setting.

---

## 13. Why the focused suite covers the original PA-02 objective

The parent combined harness's substantive properties are mapped as follows:

| Parent obligation | Focused proof coverage |
|---|---|
| Exact signed sum | PA-02A; repeated as a bridge in B, C, D, and E where relevant |
| Modulo-`q` congruence | PA-02B |
| Canonical-residue refinement | PA-02B |
| Read-only operand preservation | PA-02A, B, C, D, and E in property-appropriate forms |
| Local write footprint | PA-02C |
| Commutativity | PA-02D |
| Additive identity | PA-02E |
| Parameter and representation binding | Every focused harness |
| Non-aliasing boundary | Every focused harness |
| Memory and arithmetic safety | Every runner through common instrumentation |
| Complete loop unwinding | Every runner through `--unwind 257 --unwinding-assertions` |

Each theorem is verified directly in its own harness. PA-02B does not assume PA-02A. PA-02C does not prove frame preservation without also proving the correct target effect. PA-02D proves both directions exactly before comparing them. PA-02E proves identity with no semantic assumptions.

Therefore, success of the five focused universal proofs supports the conjunction of the planned PA-02 properties without requiring one monolithic solver query.

---

## 14. Distinctness from mlkem-native's existing proof infrastructure

The PA-02 suite is distinct in several concrete senses.

### 14.1 Separate source artefacts

The five harnesses and five runners are standalone files with PA-02-specific names, assertions, property identifiers, comments, result directories, and cryptographic hashes.

They are not modifications to `mlkem/src/poly.c`.

### 14.2 Direct production-code linkage

Each GOTO model links:

```text
custom PA-02 harness + mlkem/src/poly.c
```

No repository proof harness is linked.

### 14.3 Repository annotation and native paths disabled

The runners explicitly document that they do not:

- enable the repository CBMC annotation mode;
- enable native arithmetic;
- link repository proof-harness code.

The proof therefore evaluates the portable production body under the custom external harness.

### 14.4 Custom property scope

The PA-02 suite is organised around a full signed/non-canonical contract-valid domain and a five-part decomposition:

- exact signed semantics;
- modular refinement;
- frame/write footprint;
- commutativity;
- additive identity.

The property IDs beginning with `PA02A_` through `PA02E_` are specific to this campaign.

### 14.5 Independent provenance evidence

Each runner records:

- expected and actual repository commits;
- Git status;
- CBMC and GOTO compiler versions;
- the exact build command;
- the exact CBMC command;
- SHA-256 hashes of the harness and runner;
- copied source artefacts inside the timestamped result directory;
- build and CBMC exit codes;
- a final summary.

### 14.6 Precise limit of the distinctness claim

The supported statement is:

> PA-02 is an externally supplied, separately hashed harness suite that directly compiles the pinned portable production source without linking mlkem-native's repository proof harness infrastructure.

The evidence does **not** establish that no upstream proof artefact expresses a conceptually similar mathematical property. A formal textual-similarity or complete upstream-harness comparison was not part of PA-02 and should not be claimed.

The suite is intentionally dependent on the target production code and public type/parameter definitions; otherwise it could not verify `mlk_poly_add`.

---

## 15. Did PA-02 prove that `mlk_poly_add` is “really true”?

### 15.1 What was genuinely proved

Under the stated models and assumptions, CBMC exhaustively considered symbolic values rather than executing selected test vectors.

For the portable C target at the pinned commit and ML-KEM-768 configuration, the evidence establishes:

1. **Exact functional behavior:** for every contract-valid signed coefficient pair, the output coefficient equals the exact mathematical sum.
2. **Ring refinement:** the concrete signed/non-canonical result represents the correct addition result in `Z_q`.
3. **Frame behavior:** the read-only operand remains unchanged, and the local symbolic guards remain unchanged.
4. **Commutativity:** production execution in either operand order gives the same result.
5. **Additive identity:** adding zero returns the original polynomial for every signed `int16_t` polynomial, without input assumptions.
6. **Selected safety properties:** all enabled bounds, pointer, arithmetic, conversion, division, shift, and unwinding properties passed in each successful model.

This is stronger than ordinary testing because the coefficients are symbolic and the loops are completely unwound for the fixed dimension.

### 15.2 What “proved” means here

The proof statement is always conditional on:

- the harness model;
- the assumptions;
- the chosen implementation path;
- the pinned repository commit;
- the CBMC architecture and semantics;
- the enabled checks;
- the parameter configuration;
- the non-aliasing calling boundary.

The correct conclusion is property-specific, not metaphysical. CBMC has not established an unrestricted statement about every possible compilation, platform, caller, or future source revision.

### 15.3 Safe wording

Use:

> CBMC verified the complete planned PA-02 property suite for the portable C `mlk_poly_add` implementation at the pinned commit under ML-KEM-768 and the stated harness assumptions.

Avoid:

> `mlk_poly_add` is completely proved correct in every possible context.

---

## 16. Explicit non-claims and remaining boundaries

PA-02 does not establish the following:

1. **Overflow-invalid pairs.** PA-02A through D exclude coefficient pairs whose exact mathematical sum is outside `int16_t`. PA-03 is intended as the negative-control experiment for this domain.
2. **Aliasing behavior.** Writable target and read-only operand are distinct.
3. **Native or assembly implementations.** The portable C body was selected deliberately.
4. **Other repository commits.** Any source change requires rerunning the campaign.
5. **Executed ML-KEM-512 or ML-KEM-1024 results.** The runners accept those values, but the recorded campaign result is ML-KEM-768.
6. **The entire ML-KEM implementation.** Only `mlk_poly_add` and the PA-02 properties were verified.
7. **Cryptographic security.** The proof does not establish IND-CCA security, FIPS compliance of the whole scheme, side-channel resistance, or algorithm-level security.
8. **Constant-time behavior.** No timing or leakage property is part of PA-02.
9. **Whole-program memory separation.** PA-02C provides target-local guards plus CBMC safety instrumentation, not a global heap theorem.
10. **Compiler equivalence or generated-machine-code correctness.** The proof is at CBMC's C/GOTO model level.
11. **Absence of every category of undefined behavior.** The selected checks cover the listed categories; claims must remain tied to those options and CBMC's model.
12. **Textual uniqueness against every upstream artefact.** No full similarity scan was performed.

---

## 17. Artefact integrity manifest

### 17.1 PA-02A

| Artefact | SHA-256 |
|---|---|
| `pa02a_mlk_poly_add_exact_signed_contract_valid_harness.c` | `62c787783c2b5e75014cbe975c35f72cb58b4d6fdf4a418defc1171eaa2498ec` |
| `run_pa02a_mlk_poly_add_exact_signed_cbmc.sh` | `f21e45e9cfd6b5c65d6d74f6dc7ab9d8fc01571694ad2431a785fdc0efab9f42` |
| `pa02a_mlk_poly_add_exact_signed_bundle.zip` | `4b0f35fad4d339863308c05b8da90d79793c0a9e95720d5c31ba98ae430549e7` |

### 17.2 PA-02B

| Artefact | SHA-256 |
|---|---|
| `pa02b_mlk_poly_add_modq_refinement_contract_valid_harness.c` | `99a90ed4b0971fdaeac55cc36273fcb626a090833662e2929f2ea31fb8cea055` |
| `run_pa02b_mlk_poly_add_modq_refinement_cbmc.sh` | `3305aced76737884c02c8d90468cbeb77b6b7e87793579c6de78a888ad8f24d5` |
| `pa02b_mlk_poly_add_modq_refinement_bundle.zip` | `442bce173f26ea4cd08325428a3c9cd46b37a000a6530770de8dacbf36c886a7` |

### 17.3 PA-02C

| Artefact | SHA-256 |
|---|---|
| `pa02c_mlk_poly_add_readonly_frame_contract_valid_harness.c` | `dd47663b305d3c0c30753940a545eb35d72137309a8182fa51fdaef4f184d319` |
| `run_pa02c_mlk_poly_add_readonly_frame_cbmc.sh` | `b65ce502ba1635933c3e6d2d2e75cf6135642c953e4794f3d756c3dd70bede1c` |
| `pa02c_mlk_poly_add_readonly_frame_bundle.zip` | `33c46a39b03e6bf53122574657581b9242faa8f7a56d2599a72ed152c6dfe269` |

### 17.4 PA-02D

| Artefact | SHA-256 |
|---|---|
| `pa02d_mlk_poly_add_commutativity_contract_valid_harness.c` | `08569fdde0520c27c249af5d27fb2dddfc54c7bd7220855b5fa10a7a350e8746` |
| `run_pa02d_mlk_poly_add_commutativity_cbmc.sh` | `67c74ef9e2a912bf34c97a17ded153458658c449a81a6fdfe9810976f7b3679c` |
| `pa02d_mlk_poly_add_commutativity_bundle.zip` | `e868bd1771f08f1e96f4a77b63f97bc1843710230b5220af551a22e6c6dd80d8` |

### 17.5 PA-02E

| Artefact | SHA-256 |
|---|---|
| `pa02e_mlk_poly_add_additive_identity_full_signed_harness.c` | `b87e9748158b8b0a55182119fd9e32f7daa1b7ce8e7e4ed1a6d4c2dac2c4a291` |
| `run_pa02e_mlk_poly_add_additive_identity_cbmc.sh` | `d9825448e5f99ef3873f131874de6dd82effac14aa2c0c56234d9e3d3668bad8` |
| `pa02e_mlk_poly_add_additive_identity_bundle.zip` | `5d0f8c8beb211be7c58895143230d3d9e26c06ad7c63e040abd0cc2584095a20` |

The parent combined harness and runner should also receive final SHA-256 entries before the complete professor-facing archive is frozen.

---

## 18. Evidence status and trust classification

### 18.1 Artefact-level evidence available

The PA-02A through PA-02E harnesses and runners were structurally inspected and hashed. They contain the properties and commands described in this record.

### 18.2 Execution evidence available in this record

Complete recorded terminal summaries were available for:

- PA-02A;
- PA-02C;
- PA-02E.

Explicit successful verdicts were reported for:

- PA-02B;
- PA-02D.

The B and D raw output files were not included in the retained evidence set. Their final archive should include the complete result directories, not only terminal statements.

### 18.3 Independent reproduction status

An independent rerun in a restricted auxiliary execution container was not completed because that container did not have CBMC/GOTO-CC installed, had no swap, and could not retrieve the required package over its disabled network.

Accordingly, the formal execution verdicts in this record derive from the CBMC 6.9.0 runs performed in the recorded Ubuntu VM. This limitation must not be misrepresented as an independent second-machine reproduction.

---

## 19. Recommended final PA-02 archive

The final immutable archive should use a structure similar to:

```text
PA-02_FINAL_RECORD/
├── PA-02_mlk_poly_add_complete_verification_record.md
├── parent_combined/
│   ├── pa02_mlk_poly_add_full_signed_contract_valid_harness.c
│   ├── run_pa02_mlk_poly_add_full_signed_cbmc.sh
│   └── interrupted_run_note.md
├── PA-02A/
│   ├── harness.c
│   ├── runner.sh
│   ├── complete_result_directory/
│   └── terminal_timing.log
├── PA-02B/
│   ├── harness.c
│   ├── runner.sh
│   ├── complete_result_directory/
│   └── terminal_timing.log
├── PA-02C/
│   ├── harness.c
│   ├── runner.sh
│   ├── complete_result_directory/
│   └── terminal_timing.log
├── PA-02D/
│   ├── harness.c
│   ├── runner.sh
│   ├── complete_result_directory/
│   └── terminal_timing.log
├── PA-02E/
│   ├── harness.c
│   ├── runner.sh
│   ├── complete_result_directory/
│   └── terminal_timing.log
├── environment/
│   ├── git_commit.txt
│   ├── git_status.txt
│   ├── cbmc_version.txt
│   ├── goto_cc_version.txt
│   ├── uname.txt
│   └── memory_configuration.txt
└── SHA256SUMS.txt
```

### 19.1 Suggested archive commands

From the repository root, after collecting all result directories:

```bash
find PA-02_FINAL_RECORD -type f -print0 \
  | sort -z \
  | xargs -0 sha256sum \
  > PA-02_FINAL_RECORD/SHA256SUMS.txt

tar -czf PA-02_FINAL_RECORD_2026-07-16.tar.gz PA-02_FINAL_RECORD
sha256sum PA-02_FINAL_RECORD_2026-07-16.tar.gz
```

The archive hash should be copied into the experiment log and thesis evidence table.

---

## 20. Recommended professor-facing summary

> PA-02 evaluated the portable C `mlk_poly_add` implementation from mlkem-native commit `d9613cf60de3132d32475c102d8c2781d84feb34` under ML-KEM-768. An initial monolithic harness combined exact signed addition, modular refinement, frame properties, commutativity, and additive identity, but its propositional reduction exhausted the original VM memory budget before a verdict was produced. The proof obligation was therefore decomposed into five property-focused harnesses without reducing the polynomial dimension, symbolic coefficient domains, production-code execution, safety instrumentation, or complete loop unwinding. CBMC reported `VERIFICATION SUCCESSFUL` for PA-02A through PA-02E. The suite verified exact signed addition over all coefficient pairs whose sums are representable in `int16_t`, modulo-`q` refinement for signed and non-canonical representatives, read-only operand preservation and local write-footprint guards, commutativity, and assumption-free additive identity. The conclusion is restricted to the specified properties, assumptions, non-aliasing boundary, portable C path, pinned commit, and ML-KEM-768 configuration.

---

## 21. Thesis-ready result paragraph

The PA-02 verification campaign was completed successfully for the portable C implementation of `mlk_poly_add` at repository commit `d9613cf60de3132d32475c102d8c2781d84feb34` under the ML-KEM-768 configuration. The initial combined harness was decomposed into five property-focused CBMC harnesses after its monolithic propositional reduction approached VM memory exhaustion. The decomposition retained the complete 256-coefficient symbolic domains, the production function body, the necessary signed-representability precondition where applicable, the selected safety instrumentation, and complete loop-unwinding assertions. PA-02A verified exact coefficient-wise signed addition over the full contract-valid `int16_t` domain; PA-02B verified modulo-`q` congruence and canonical-residue refinement for signed and non-canonical representatives; PA-02C verified read-only operand preservation and local write-footprint guards; PA-02D verified relational commutativity using independent production executions in both operand orders; and PA-02E verified additive identity over the complete signed and non-canonical `int16_t` domain without semantic assumptions. All five focused experiments reported `VERIFICATION SUCCESSFUL`. These results establish the planned PA-02 property suite under the encoded assumptions and configuration, but do not constitute a proof of every property of `mlk_poly_add`, native implementations, aliasing contexts, overflow-invalid inputs, or the complete ML-KEM implementation.

---

## 22. Methodological lessons

1. **A solver resource failure is not a property failure.** The combined run remained active at high CPU and was interrupted because memory approached exhaustion.
2. **Proof decomposition can preserve theorem strength.** Universal properties may be verified separately and conjoined when domains and implementation bindings are compatible.
3. **Exact semantic bridges prevent weak relational proofs.** PA-02B, C, D, and E each tie their specialised theorem to correct target behavior.
4. **Full symbolic domains are different from test vectors.** No coefficient samples were enumerated; CBMC reasoned over symbolic bit-vector values.
5. **Assumptions must express a necessary contract, not force the answer.** PA-02A through D assume only signed-result representability. PA-02E requires no semantic assumptions.
6. **Complete unwinding must be checked, not presumed.** `--unwinding-assertions` prevents silent truncation.
7. **One authoritative run reduces cost and ambiguity.** Repeating a complete proof merely to obtain a second output format is unnecessary.
8. **Frame properties should be tied to a correct effect.** Proving that an operand is unchanged is insufficient if the target computation itself is not checked.
9. **Result wording must remain property-specific.** “The PA-02 suite was verified” is defensible; “the whole implementation is completely correct” is not.
10. **Raw evidence must accompany summaries.** Final thesis preservation requires the complete result directories, commands, versions, hashes, and logs.

---

## 23. Final campaign verdict

```text
PA-02 CAMPAIGN: COMPLETE

Target:          portable C mlk_poly_add
Repository:      pq-code-package/mlkem-native
Commit:          d9613cf60de3132d32475c102d8c2781d84feb34
Configuration:   ML-KEM-768
Tool:            CBMC 6.9.0
Sub-campaigns:   PA-02A, PA-02B, PA-02C, PA-02D, PA-02E
Successful:      5 of 5
Failed:          0
Inconclusive:    original combined monolithic run only
Final claim:     planned PA-02 property suite verified under stated scope
```

**End of record.**
