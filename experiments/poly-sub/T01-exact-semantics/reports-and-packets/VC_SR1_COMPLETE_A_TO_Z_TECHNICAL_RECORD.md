# Complete Technical Record of the `mlk_poly_sub` → `mlk_poly_reduce` CBMC Verification Campaign

## Campaign identifier

`PROFESSOR_HARDEN_VC_SR1_2026-07-18`

## Frozen implementation

- Repository: `mlkem-native`
- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Parameter set: `ML-KEM-768`
- Polynomial degree: `MLKEM_N = 256`
- Modulus: `MLKEM_Q = 3329`
- Verification tool: `CBMC 6.9.0`
- Compiler environment recorded during the campaign: GCC 13.3.0 on x86-64 Ubuntu
- Implementation path checked: portable C
- Assembly/native optimized path checked: no
- Final frozen-source status: clean, with `STATUS_LINES=0`

## Final campaign result

| Case | Purpose | Final result |
|---|---|---|
| AC-SR1 | Establish that the production decryption callsite satisfies signed-16-bit representability | `PASS` |
| OR-SR1 | Validate the independent canonical modular oracle | `PASS` |
| VC-SR1 | Verify the executable portable C bodies of `mlk_poly_sub` followed by `mlk_poly_reduce` | `PASS_EXPECTED` |
| M4 | Test sensitivity to an implementation mutation that omits reduction of coefficient 255 | `FAIL_EXPECTED_MUTANT_KILLED` |
| M5 | Test sensitivity and reachability by replacing the correct oracle assertion with a false `+1 mod 3329` assertion | `FAIL_EXPECTED_MUTANT_KILLED` |

The combined campaign status is:

```text
VC_SR1_CAMPAIGN=COMPLETE
POSITIVE_CONTROL=PASS_EXPECTED
IMPLEMENTATION_MUTANT=KILLED
ASSERTION_MUTANT=KILLED
FINAL_PACKAGE=HASH_VERIFIED
```

The final verified archive is:

```text
/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/99_final_package/PROFESSOR_HARDEN_VC_SR1_2026-07-18.tar.gz
```

Its SHA-256 is:

```text
c3d65fcfa86ab80879e65648ef6b9018bd157516336f1de528768d253e032c6e
```

---

# 1. Purpose of this record

This document records the complete technical work carried out to harden and validate the functional-correctness claim for the sequence:

```c
mlk_poly_sub(&L, &LB);
mlk_poly_reduce(&L);
```

The work began from the earlier T1 canonical-domain harness and was expanded into a professor-facing evidence campaign with:

- frozen-source provenance;
- an explicit production-callsite admissibility proof;
- an independent oracle-equivalence proof;
- a fresh executable-body CBMC proof;
- loop-completeness evidence;
- structural GOTO-model inspection;
- solver-command freezing;
- result classification;
- mutation-based non-vacuity controls;
- case-level manifests;
- cross-case consistency checks;
- independent archive extraction and verification.

The purpose of the additional work was not to manufacture a new result after the fact. Its purpose was to transform the earlier T1 result into a transparent, assumption-aware, reproducible, and falsification-resistant assurance argument.

---

# 2. Authoritative scoped claim

The final claim established by the combined campaign is:

> For every modelled polynomial input pair satisfying the recorded signed-`int16_t` representability condition, execution of the frozen portable C bodies of `mlk_poly_sub` followed by `mlk_poly_reduce` produces, coefficient by coefficient, the unsigned-canonical representative in `[0,3329)` congruent to the mathematical difference modulo 3329, while preserving the recorded frame conditions.

This is a property-specific and assumption-dependent result.

It is not described as an unrestricted theorem about all mathematical integers, every ML-KEM configuration, every implementation backend, or all of ML-KEM.

The strongest valid completeness statement is:

> CBMC returned an UNSAT verification result after all relevant fixed-bound loops were completely unwound and unwinding assertions were enabled. The result is complete for the frozen finite CBMC model under the recorded assumptions, selected C semantics, platform model, source binding, build configuration, and verification options.

---

# 3. Mathematical statement checked

For each coefficient index `i`, let:

```text
a = A[i]
b = B[i]
d = a - b
q = 3329
```

Under the precondition that `d` is representable as a signed 16-bit C value, the implementation sequence is expected to produce:

```text
R[i] ∈ [0, q)
```

and:

```text
R[i] ≡ d (mod q)
```

The concrete independent oracle used in the central semantic harness was equivalent to:

```c
(uint32_t)(d + 10 * 3329) % 3329
```

The use of `10 * 3329` ensures a non-negative dividend throughout the signed-16-bit difference domain used by the proof. OR-SR1 separately established that this expression equals the conventional canonical mathematical expression:

```c
((d % 3329) + 3329) % 3329
```

for every signed 16-bit `d`.

Therefore, the semantic equality checked by VC-SR1 was not accepted merely because it appeared plausible in the harness. The oracle itself received an independent proof obligation.

---

# 4. Relationship to the earlier T1 campaign

## 4.1 What T1 originally established

The earlier T1 canonical-domain campaign introduced a harness that:

1. created nondeterministic full polynomial inputs;
2. stored copies of those inputs;
3. assumed signed representability of each coefficientwise subtraction;
4. called the real subtraction function;
5. called the real reduction function;
6. checked frame preservation;
7. checked that every result coefficient was non-negative;
8. checked that every result coefficient was below 3329;
9. checked equality against an independent canonical modular oracle.

The historical T1 canonical harness had SHA-256:

```text
42c09c2f004d567d8b886058bd2304d960a219d36f0f6605b015966db3bc5682
```

The professor-hardening campaign preserved the T1 semantic architecture in:

```text
03_vc_sr1_reachable_only/source/vc_sr1_semantic_harness.c
```

The T1 harness was therefore not discarded and replaced by an unrelated proof. It was promoted into a frozen, independently audited evidence campaign.

## 4.2 Why T1 alone was not sufficient for the strongest professor-facing presentation

T1 contained an explicit signed-representability assumption. A harness assumption cannot prove itself. T1 also used an independent canonical oracle, but the correctness of the oracle was not yet isolated as its own proof obligation.

The additional campaign therefore separated the complete reasoning into three positive cases:

```text
AC-SR1  →  discharges the production-callsite assumption
OR-SR1  →  validates the mathematical oracle
VC-SR1  →  checks the executable implementation bodies
```

This changed the evidence from:

```text
one harness succeeds under an assumption
```

into:

```text
the production callsite satisfies the assumption
AND
the oracle is valid
AND
the executable C implementation satisfies the asserted relation
```

## 4.3 What the professor-recommended additions contributed

The new work added the following assurance layers beyond the ordinary T1 run:

- exact frozen commit and clean detached worktree;
- tracked-entry manifest for the frozen source;
- separation of source provenance from proof output;
- independent proof of the representability precondition;
- independent proof of oracle equivalence;
- fresh GOTO model built from the frozen production body;
- validation of initial and reachable-only GOTO models;
- explicit call-chain inspection;
- confirmation that the portable reduction body was present;
- confirmation that native/assembly reduction was absent;
- confirmation that contracts did not replace executable function bodies;
- exact ten-loop inventory;
- explicit per-loop unwind bounds;
- enabled unwinding assertions;
- frozen property inventory;
- immutable solver command;
- machine-readable JSON result parsing;
- correction and preservation of a classifier false negative;
- implementation-level mutation control;
- assertion-level mutation control;
- case-wide manifests;
- cross-case consistency audit;
- independently extracted archive verification.

These additions did not change the mathematical claim. They strengthened the evidence that the successful result really corresponded to the intended frozen source, intended execution path, intended property, and intended assumptions.

---

# 5. Frozen-source provenance

The campaign used a detached frozen worktree:

```text
/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/PROFESSOR_HARDEN_VC_SR1_2026-07-18/00_frozen_source/mlkem-native
```

The frozen commit was:

```text
d9613cf60de3132d32475c102d8c2781d84feb34
```

The worktree remained clean throughout:

```text
STATUS_LINES=0
```

The original development repository was not cleaned, reset, or altered. This was important because unrelated experiments were active in that repository.

The source-freeze metadata included:

```text
00_campaign_metadata/frozen_tracked_entries.sha256.tsv
00_campaign_metadata/frozen_tracked_entries_summary.json
00_campaign_metadata/frozen_source_manifest.sha256
00_campaign_metadata/frozen_worktree_status.txt
00_campaign_metadata/gate0_source_freeze.txt
```

The source manifest was generated in a symlink-aware manner and covered the tracked entries of the frozen source snapshot.

---

# 6. Production-callsite analysis

The relevant frozen decryption sequence in `mlkem/src/indcpa.c` was:

```c
mlk_unpack_ciphertext(b, v, c);
...
mlk_poly_invntt_tomont(sb);
mlk_poly_sub(v, sb);
mlk_poly_reduce(v);
mlk_poly_tomsg(m, v);
```

The important coefficient bounds were:

```text
0 ≤ v[i] < 3329
|sb[i]| < 26632
```

The inverse-NTT absolute bound was exclusive:

```text
MLK_INVNTT_BOUND = 8 * MLKEM_Q = 26632
```

Therefore:

```text
-26631 ≤ v[i] - sb[i] ≤ 29959
```

This interval is contained in:

```text
-32768 ≤ int16_t ≤ 32767
```

Thus, the subtraction used at the frozen production decryption callsite is signed-16-bit representable.

This result is essential. Without it, the central T1/VC-SR1 assumption would remain only a user-selected input restriction. AC-SR1 connects that restriction to the actual frozen decryption context.

---

# 7. Harness inventory

Only four unique campaign harnesses were used:

```text
01_callsite_representability/source/ac_sr1_callsite_representability.c
02_oracle_equivalence/source/or_sr1_oracle_equivalence.c
03_vc_sr1_reachable_only/source/vc_sr1_semantic_harness.c
05_mutation_assertion/source/m5_false_oracle_assertion_harness.c
```

M4 did not use a new harness. It reused the unchanged VC-SR1 semantic harness and changed only an isolated implementation copy.

The M5 baseline harness:

```text
05_mutation_assertion/source/vc_sr1_harness_frozen_baseline.c
```

was a byte-identical copy of the accepted VC-SR1 harness. It was retained only to prove the exact one-site assertion mutation.

## 7.1 AC-SR1 harness

Path:

```text
01_callsite_representability/source/ac_sr1_callsite_representability.c
```

Purpose:

- model the production-callsite coefficient bounds;
- prove the minimum and maximum possible subtraction values;
- prove that the result lies in the signed 16-bit domain;
- discharge the representability precondition used by VC-SR1.

The proof is coefficientwise and uniform. A scalar arbitrary-position model is sufficient because the same bounds apply independently to every polynomial coefficient.

## 7.2 OR-SR1 harness

Path:

```text
02_oracle_equivalence/source/or_sr1_oracle_equivalence.c
```

Purpose:

- quantify over all signed 16-bit values `d`;
- prove equivalence between the shifted unsigned modulo oracle and the conventional canonical modulo expression;
- prevent the semantic proof from depending on an unverified arithmetic shortcut.

## 7.3 VC-SR1 central semantic harness

Path:

```text
03_vc_sr1_reachable_only/source/vc_sr1_semantic_harness.c
```

Purpose:

- generate full symbolic polynomial inputs;
- save frame copies;
- impose only the explicit representability condition needed for exact C subtraction;
- execute the real frozen portable C subtraction body;
- execute the real frozen portable C reduction body;
- check canonical range;
- check modular equality to the independent oracle;
- check frame preservation.

The harness called the production sequence:

```c
mlk_poly_sub(&L, &LB);
mlk_poly_reduce(&L);
```

The namespace prefix used in the fresh build was:

```text
mlk_vc_sr1
```

The namespace is only a compile-time symbol-isolation mechanism. It does not replace or rewrite the arithmetic body.

## 7.4 M5 false-assertion harness

Path:

```text
05_mutation_assertion/source/m5_false_oracle_assertion_harness.c
```

Purpose:

- leave production code unchanged;
- leave input assumptions unchanged;
- leave the assertion description unchanged;
- change only the expected canonical value by `+1 modulo 3329`;
- require CBMC to reject the deliberately false statement.

This was a negative control, not an accepted proof harness.

---

# 8. Why the campaign harness is distinct from the native ML-KEM harness

The frozen repository contains its own native CBMC proof harness:

```text
00_frozen_source/mlkem-native/proofs/cbmc/poly_sub/poly_sub_harness.c
```

The professor-hardening campaign did not merely rename that native repository harness.

The campaign harness is distinct in the following ways.

## 8.1 Different proof composition

The campaign central harness checks the composed sequence:

```text
mlk_poly_sub → mlk_poly_reduce
```

rather than checking only a single function contract in isolation.

## 8.2 Independent mathematical oracle

The campaign checks coefficientwise equality against an independently validated canonical modulo oracle.

## 8.3 Explicit canonical-domain result

The campaign asserts both:

```text
0 ≤ output[i]
output[i] < 3329
```

for every coefficient.

## 8.4 Explicit input-frame preservation

The campaign records and checks that the second input polynomial is unchanged.

## 8.5 Explicit representability boundary

The campaign does not silently rely on C signed conversion behaviour. It states the representability condition and separately proves that the production decryption callsite satisfies it.

## 8.6 Executable-body inspection

The fresh GOTO model was inspected to confirm the presence of the actual portable C bodies and helper calls. Function contracts were left disabled as body-replacement mechanisms.

## 8.7 Mutation controls

The campaign includes an implementation mutant and an assertion mutant. The native proof harness alone does not constitute these campaign-level falsification controls.

## 8.8 Separate evidence identity

The campaign harnesses live outside the frozen repository proof tree and have their own source paths, models, commands, results, hashes, and manifests.

Therefore, the campaign is not a duplicate of the repository-native `poly_sub` proof. It is a separate, scoped, composition-level semantic verification campaign built against the frozen production implementation.

---

# 9. Build and support-file boundaries

The VC-SR1 build used:

```text
ML-KEM parameter set: 768
portable C only
custom zeroize adapter
contracts disabled as body replacement
```

The support files were:

```text
03_vc_sr1_reachable_only/source/support/vc_sr1_fail_closed_zeroize.h
03_vc_sr1_reachable_only/source/support/vc_sr1_verify_pragma_scope.h
03_vc_sr1_reachable_only/source/support/vc_sr1_optblocker_zero.c
```

Their roles were limited.

## 9.1 Verification pragma scope

The pragma support enabled conversion checking while leaving function and loop contracts disabled. It did not replace production functions with assumed postconditions.

SHA-256 recorded for the historical pragma header:

```text
5c39e68460e2660da0d76d21797893cb6ec47988ee9a1cc863cf709838e8568c
```

## 9.2 Optimizer blocker

The optimizer-blocker source used only a volatile-zero barrier.

SHA-256:

```text
300d4d8bc2b8d467356ba2548920ccef509d9e03d748d3151f42ec3608a9aa19
```

It did not redirect the target call or insert a theorem assumption.

## 9.3 Zeroize adapter

The custom zeroize adapter contained an additional `__CPROVER_assert`. It was classified as an additional proof obligation, not as path pruning.

SHA-256:

```text
45d33b9ee3fe3613f23906de520bf9d5ce245a18b537c32787201912dec4e926
```

---

# 10. Structural GOTO-model evidence

The fresh reachable model showed the call chain:

```text
main
  → mlk_vc_sr1_poly_sub
  → mlk_vc_sr1_poly_reduce
  → mlk_poly_reduce_c
  → mlk_barrett_reduce
  → mlk_scalar_signed_to_unsigned_q
```

The structural audit confirmed:

- `main` called the namespaced production subtraction function;
- the subtraction loop body from frozen `poly.c` was present;
- the portable reduction body was present;
- the Barrett-reduction helper was present;
- the signed-to-unsigned helper was present;
- the native reduction path was absent;
- contract expansion/body replacement was absent;
- the frozen `poly.c` source path appeared in the model;
- the subtraction call preceded the reduction call.

The fresh reachable model SHA-256 was:

```text
8d4394d8531469327af40d83b33edcab29e4ed30b17579b26f6c224ccefc891a
```

The validated reachable model SHA-256 was:

```text
d401764c6f0b404a0decaa6a3434d6239513c91f53ea6737d1ab05f6afb6df24
```

---

# 11. Loop-completeness evidence

The reachable model contained ten loops:

```text
main.0
main.1
main.2
main.3
mlk_vc_sr1_poly_sub.0
mlk_barrett_reduce.0
mlk_poly_reduce_c.0
mlk_poly_reduce_c.1
mlk_scalar_signed_to_unsigned_q.0
mlk_scalar_signed_to_unsigned_q.1
```

The exact unwind set was:

```text
main.0:257,
main.1:257,
main.2:257,
main.3:257,
mlk_vc_sr1_poly_sub.0:257,
mlk_barrett_reduce.0:2,
mlk_poly_reduce_c.0:257,
mlk_poly_reduce_c.1:257,
mlk_scalar_signed_to_unsigned_q.0:2,
mlk_scalar_signed_to_unsigned_q.1:2
```

The four harness loops and the polynomial loops use 257 as the unwind count for 256 iterations. The small helper loops use 2.

The solver command enabled:

```text
--unwinding-assertions
```

and did not enable:

```text
--partial-loops
```

The solver returned no failed property.

A subtle but important classification point was preserved: CBMC did not return ten separately named unwind properties in the JSON result. Completeness is justified by the enabled unwinding assertions, exact loop inventory, exact unwind set, successful solver result, and absence of any failed property. It is not justified by claiming that ten visible unwind-property rows were returned.

---

# 12. Verification checks enabled

The positive solver command enabled:

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
--sat-solver minisat2
--trace
--json-ui
```

The command also used:

```text
--function main
--object-bits 8
```

The exact solver-command SHA-256 was:

```text
8fd7542cf90f36457bb01a4228aa7b8afe0b64e2c8fa15231028f5957f7ee519
```

The frozen command is stored at:

```text
03_vc_sr1_reachable_only/build/vc_sr1_solver_command.txt
```

---

# 13. Properties established by VC-SR1

The positive reachable model contained 89 frozen properties, and all 89 returned `SUCCESS`.

The most important claim-level properties were:

## 13.1 Machine-model conditions

Examples included:

```text
CHAR_BIT must be 8
```

and assertions binding the intended integer and parameter model.

## 13.2 Parameter conditions

The harness asserted:

```text
MLKEM_N = 256
MLKEM_Q = 3329
```

through equality with frozen FIPS constants used by the campaign.

## 13.3 Subtraction input-frame preservation

After `mlk_poly_sub`, the second polynomial remained equal to its saved copy.

## 13.4 Final input-frame preservation

After the full subtraction-and-reduction sequence, the second polynomial still equalled its saved copy.

## 13.5 Canonical lower bound

For every coefficient:

```text
output[i] ≥ 0
```

## 13.6 Canonical upper bound

For every coefficient:

```text
output[i] < 3329
```

## 13.7 Independent canonical-oracle equality

For every coefficient, the output equalled the independently validated canonical representative of the mathematical difference modulo 3329.

## 13.8 Safety obligations

The full 89-property set also covered the enabled bounds, pointer, conversion, overflow, shift, division, and support-code safety obligations generated for the frozen model.

---

# 14. AC-SR1: callsite admissibility proof

## 14.1 Purpose

AC-SR1 answers:

> Does the frozen production decryption callsite satisfy the signed-representability condition assumed by the central semantic proof?

## 14.2 Result

AC-SR1 passed.

The accepted evidence established:

```text
v[i] ∈ [0,3328]
sb[i] ∈ [-26631,26631]
v[i] - sb[i] ∈ [-26631,29959]
```

The final interval lies inside signed 16-bit range.

## 14.3 Evidence hashes

Harness SHA-256:

```text
e6ae8dd061401ee1e0720760df27e78cf3a516165b80766df20aedfa5c3f13c9
```

Validated model SHA-256:

```text
6a6828029b967fcd6be0140c185b37122f6b8e0f334602e235ce771191bc6292
```

Property inventory SHA-256:

```text
066cd121a933b225ee61392d2a270b5c44dce2bc16cdfec6b89a634a88c0a76b
```

Manifest sidecar SHA-256:

```text
bc53a546898ed22b636ae5a27fe505b9e5af9dd914199ac389f84e209d1d00d0
```

Final status:

```text
AC_SR1_CASE=FROZEN
```

---

# 15. OR-SR1: independent oracle proof

## 15.1 Purpose

OR-SR1 answers:

> Is the shifted unsigned modulo expression used by the central harness equal to the standard canonical mathematical modulo result for every signed 16-bit difference?

## 15.2 Result

OR-SR1 passed for every `int16_t d`.

The relation checked was:

```text
(uint32_t)(d + 10q) % q
=
((d % q) + q) % q
```

with:

```text
q = 3329
```

## 15.3 Evidence hashes

Harness SHA-256:

```text
0e38668cca2a7e7fa71398e80e28cfa0e759bf2db74c7799c721ab928fbe6910
```

Validated model SHA-256:

```text
aa6b8b330cd3767cab00af7855d40c23abcafd534b9da1a37ac84a461def97cc
```

Property inventory SHA-256:

```text
1cc714bffd1f4f6751eec2ddf4843f974a694934840f3f4b8b191a30d6fea506
```

Manifest sidecar SHA-256:

```text
de6480a1a884ec6a1bfc7093426277a6a1a4762ab5ee31821a781e3103eda289
```

Final status:

```text
OR_SR1_CASE=FROZEN
```

---

# 16. VC-SR1: positive executable-body proof

## 16.1 Fresh build

The professor-hardening case rebuilt the proof model from:

- the frozen production `poly.c`;
- the accepted semantic harness;
- the limited support files;
- the ML-KEM-768 configuration;
- a dedicated namespace.

The initial model and reachable-only model were both validated.

## 16.2 Positive result

The returned JSON contained:

```text
result blocks: 1
frozen properties: 89
returned properties: 89
successful properties: 89
missing properties: 0
extra properties: 0
non-success properties: 0
CBMC exit: 0
resource exit: 0
stderr bytes: 0
```

CBMC reported:

```text
VERIFICATION SUCCESSFUL
```

Final classification:

```text
VC_SR1_CLASSIFICATION_V2=PASS_EXPECTED
VC_SR1_CLAIM_STATUS_V2=PROVED_WITHIN_FROZEN_FINITE_CBMC_MODEL
```

## 16.3 Resource record

The positive execution recorded approximately:

```text
user time: 1659.58 seconds
system time: 4.00 seconds
elapsed time: 27:43.97
maximum resident set size: 1,781,288 KB
```

## 16.4 Classifier-v1 correction

The first classifier incorrectly required one separately returned visible unwind-property result for each loop.

It classified the successful proof as:

```text
MISSING_UNWINDING_ASSERTION_RESULTS
```

This was a classifier false negative, not a proof failure.

The corrected classifier used the actual evidence:

- `--unwinding-assertions` was enabled;
- the exact ten-loop unwind set was supplied;
- partial loops were disabled;
- all 89 frozen properties were returned;
- all 89 succeeded;
- CBMC exited zero;
- stderr was empty;
- verification was successful.

The rejected v1 evidence was preserved instead of deleted. This is important because it documents the correction transparently.

---

# 17. M4: implementation mutation control

## 17.1 Mutation

An isolated copy of the frozen implementation was created:

```text
04_mutation_reduce/source/poly_m4_skip_final_reduce.c
```

Only the Barrett-reduction loop bound in `mlk_poly_reduce_c` was changed from:

```c
i < MLKEM_N
```

to:

```c
i < (MLKEM_N - 1)
```

For `MLKEM_N = 256`, coefficient 255 was omitted from Barrett reduction.

The accepted positive harness, oracle, assumptions, solver checks, and frozen repository remained unchanged.

## 17.2 Why this mutation mattered

The mutation represented a realistic locality defect: one array element was skipped while the rest of the loop executed normally.

A weak, unreachable, tautological, or over-assumed semantic harness might allow such a mutant to survive.

## 17.3 Result

CBMC rejected the mutant.

Final classification:

```text
M4_CLASSIFICATION=FAIL_EXPECTED_MUTANT_KILLED
M4_MUTANT_KILLED=YES
```

The failure included the intended semantic/oracle consequence, with:

```text
unwinding failures: 0
missing properties: 0
extra properties: 0
```

This demonstrates that the unchanged semantic property was sensitive to an implementation defect.

## 17.4 Interpretation

M4 does not prove the original implementation by itself. It strengthens confidence that the original passing result was not produced by:

- an unreachable target call;
- a trivially true oracle;
- a missing final coefficient;
- an assertion unrelated to the implementation result;
- excessive assumptions that made the defect impossible to observe.

---

# 18. M5: false-assertion control

## 18.1 Mutation

Production `poly.c` remained unchanged.

Only the canonical expected value in an isolated harness copy was shifted by:

```text
+1 modulo 3329
```

The assertion description was preserved:

```text
SUB_T1_SEMANTIC: output must equal independent canonical oracle
```

## 18.2 Property-count change

The positive control contained 89 properties.

M5 contained 90 properties because the new `+1U` expression generated one additional harness safety obligation in `main`.

This delta was separately audited:

```text
POSITIVE_PROPERTY_COUNT=89
M5_PROPERTY_COUNT=90
M5_PROPERTY_DELTA=1
ADDED_PROPERTY_GROUPS={'main': 1}
REMOVED_PROPERTY_GROUPS={}
```

The additional property was accepted as an expected consequence of the changed assertion expression, not as an unexplained model difference.

## 18.3 Result

Exactly the deliberately false target assertion failed.

The accepted classification required:

```text
returned properties: 90
failed properties: 1
target assertion failures: 1
non-target failures: 0
unwinding failures: 0
missing properties: 0
extra properties: 0
```

Final result:

```text
M5_CLASSIFICATION=FAIL_EXPECTED_MUTANT_KILLED
M5_MUTANT_KILLED=YES
```

## 18.4 Interpretation

M5 shows that:

- the semantic assertion is reachable;
- the semantic assertion is not a tautology;
- the positive result is not caused by the assertion being ignored;
- CBMC can distinguish the correct expected value from a deliberately false one;
- unrelated properties remain successful.

---

# 19. Combined logical assurance argument

The complete reasoning is:

## Premise 1: callsite admissibility

AC-SR1 establishes that the frozen production decryption callsite satisfies the signed-16-bit representability condition.

## Premise 2: oracle validity

OR-SR1 establishes that the independent oracle expression equals the conventional canonical modulo result over the modelled signed-16-bit difference domain.

## Premise 3: implementation correctness under the precondition

VC-SR1 establishes that the real frozen portable C bodies of `mlk_poly_sub` followed by `mlk_poly_reduce` satisfy canonical range, modular equality, frame, and safety obligations under the recorded assumption.

## Falsification control 1

M4 establishes that an isolated implementation defect is detected by the unchanged semantic property.

## Falsification control 2

M5 establishes that a deliberately false semantic expectation is rejected while non-target properties remain successful.

Therefore, the final claim is supported by:

```text
AC-SR1 ∧ OR-SR1 ∧ VC-SR1
```

with M4 and M5 providing non-vacuity and sensitivity evidence.

No individual companion harness alone is presented as the complete proof.

---

# 20. Assumptions and boundaries

The proof depends on the following explicit assumptions and modelling choices.

## 20.1 Signed representability

For each coefficient:

```text
A[i] - B[i]
```

must be representable as `int16_t`.

This was not left unsupported for the intended decryption callsite; AC-SR1 discharged it for that frozen context.

## 20.2 Frozen source

The result applies to commit:

```text
d9613cf60de3132d32475c102d8c2781d84feb34
```

## 20.3 Parameter set

The campaign used:

```text
ML-KEM-768
```

## 20.4 Portable C implementation

The proof checked the portable C path. It did not verify architecture-specific assembly or native optimized reduction implementations.

## 20.5 CBMC machine model

The result depends on the selected CBMC C semantics and command-line model, including the recorded object-bit setting and enabled checks.

## 20.6 Complete finite loop bounds

The result is complete for the fixed-size loops under the recorded unwind set.

## 20.7 Property-specific scope

The proof establishes the listed functional, frame, canonical-domain, and safety properties. It does not automatically establish unrelated security properties.

---

# 21. What was not proved

The campaign does not prove:

- all of ML-KEM;
- end-to-end KEM correctness;
- IND-CCA security;
- ciphertext validity as a cryptographic theorem;
- constant-time execution;
- cache, power, timing, or electromagnetic side-channel resistance;
- fault resistance;
- assembly implementation correctness;
- every build configuration;
- every compiler and platform;
- unrestricted correctness over arbitrary mathematical integers;
- all contracts in the repository;
- every possible property of `mlk_poly_sub`;
- that mutation testing itself proves correctness.

The campaign also does not claim that the original repository-native harness is incorrect. The repository-native proof and this campaign serve different evidence purposes.

---

# 22. Status of `mlk_poly_sub`

The strongest accurate conclusion is:

> The frozen portable C implementation of `mlk_poly_sub`, when followed by `mlk_poly_reduce`, is functionally correct for the scoped coefficientwise canonical modular-difference property under the recorded signed-representability condition, ML-KEM-768 configuration, finite CBMC model, source binding, and verification options.

For the intended frozen decryption callsite, AC-SR1 establishes that the representability condition holds.

Therefore, for that scoped production sequence, the campaign supports the intended correctness statement.

It remains incorrect to say simply:

```text
mlk_poly_sub is universally proved correct
```

without qualifications.

---

# 23. Status of `mlk_poly_add`

This professor-hardening campaign is a `poly_sub` campaign. It does not independently prove `mlk_poly_add`.

Earlier work discussed a `poly_add` campaign with properties labelled PA1 through PA9. The correct interpretation of such a campaign is:

> If every PA1–PA9 property was independently bound to the intended frozen source and build, completely checked under its recorded assumptions, and supported by preserved CBMC evidence, then the campaign can establish comprehensive correctness for those selected properties and that model.

It still would not establish unrestricted universal correctness of `mlk_poly_add` for every context, platform, configuration, and mathematical input domain.

The present VC-SR1 package does not contain the complete professor-hardened `poly_add` evidence chain. Therefore, this document does not claim that `mlk_poly_add` has been proved to the same final standard as `mlk_poly_sub → mlk_poly_reduce`.

The honest distinction is:

```text
mlk_poly_sub → mlk_poly_reduce:
    final professor-hardened campaign completed and hash-verified

mlk_poly_add:
    earlier selected-property work exists, but it is a separate campaign
    and is not established by the VC-SR1 archive
```

A future `poly_add` finalization should apply the same gates used here:

- frozen source;
- explicit claim;
- assumption-discharge case;
- independent oracle where applicable;
- executable-body model audit;
- exact unwind completeness;
- frozen property inventory;
- positive proof;
- implementation mutant;
- assertion mutant;
- case manifests;
- final archive verification.

---

# 24. Why this evidence is stronger than a normal successful CBMC run

A normal successful run may establish that no listed property failed in one model. This campaign additionally answers:

- Which exact source commit was checked?
- Was the source clean?
- Was the real function body present?
- Was the intended call sequence present?
- Was assembly excluded?
- Were contracts replacing code?
- Which loops were reachable?
- Were all loops completely unwound?
- Which properties existed before execution?
- Did the returned result preserve the frozen property set?
- Was the oracle valid?
- Did the production callsite satisfy the input assumption?
- Would a one-coefficient implementation defect be detected?
- Would a false assertion be detected?
- Were all outputs hash-bound?
- Could the final archive be independently extracted and verified?

The final campaign therefore provides not only solver success but also provenance, model integrity, assumption justification, oracle validation, non-vacuity, reproducibility, and tamper-evident packaging.

---

# 25. Evidence hierarchy

The campaign uses the following authority order:

1. Frozen production source and commit binding.
2. Frozen build recipe and generated GOTO model.
3. Structural model audit.
4. Frozen property inventory and loop inventory.
5. Immutable solver command.
6. Raw CBMC JSON and exit/resource records.
7. Machine-readable classification.
8. Mutation controls.
9. Case-wide manifests.
10. Combined campaign manifest and independently verified archive.
11. Human-readable professor and thesis summaries.

The human-readable explanation is not treated as stronger than the raw evidence.

---

# 26. Reproducibility paths

## AC-SR1

```text
01_callsite_representability/
```

Important files:

```text
source/ac_sr1_callsite_representability.c
build/cbmc_command.txt
model/ac_sr1_validated.goto
properties/show_properties.txt
results/cbmc_raw.json
classification/ac_sr1_final_acceptance.json
hashes/ac_sr1_case_manifest.sha256
```

## OR-SR1

```text
02_oracle_equivalence/
```

Important files:

```text
source/or_sr1_oracle_equivalence.c
build/cbmc_command.txt
model/or_sr1_validated.goto
properties/show_properties.txt
results/cbmc_raw.json
classification/or_sr1_final_acceptance.json
hashes/or_sr1_case_manifest.sha256
```

## VC-SR1

```text
03_vc_sr1_reachable_only/
```

Important files:

```text
source/vc_sr1_semantic_harness.c
build/vc_sr1_goto_build_command.txt
build/vc_sr1_solver_command.txt
model/vc_sr1_reachable_only_validated.goto
model/vc_sr1_structural_audit.json
properties/vc_sr1_solver_property_inventory.txt
properties/vc_sr1_unwind_plan.tsv
results/vc_sr1_cbmc_result.json
classification/vc_sr1_final_status.txt
classification/vc_sr1_final_summary.md
hashes/vc_sr1_case_manifest.sha256
```

## M4

```text
04_mutation_reduce/
```

Important files:

```text
source/poly_frozen_baseline.c
source/poly_m4_skip_final_reduce.c
source/m4_single_site_mutation.diff
source/m4_mutation_audit.json
model/m4_reachable_only_validated.goto
properties/m4_property_inventory.txt
results/m4_cbmc_result.json
classification/m4_final_status.txt
hashes/m4_case_manifest.sha256
```

## M5

```text
05_mutation_assertion/
```

Important files:

```text
source/vc_sr1_harness_frozen_baseline.c
source/m5_false_oracle_assertion_harness.c
source/m5_assertion_mutation.diff
source/m5_assertion_mutation_audit.json
model/m5_reachable_only_validated.goto
properties/m5_property_count_adjustment.json
properties/m5_property_inventory.txt
results/m5_cbmc_result.json
classification/m5_final_status.txt
hashes/m5_case_manifest.sha256
```

## Combined summary

```text
90_combined_summary/
```

Important files:

```text
vc_sr1_campaign_verdict.json
vc_sr1_campaign_verdict.md
vc_sr1_result_matrix.tsv
vc_sr1_cross_case_integrity.json
campaign_case_entries.sha256
combined_summary_manifest.sha256
```

## Professor package

```text
99_final_package/
```

Important files:

```text
00_README.md
01_claim_and_scope.md
02_assumptions.md
03_source_and_build_binding.md
04_evidence_matrix.md
05_mutation_results.md
06_reproducibility.md
07_limitations_and_non_claims.md
package_files.sha256
PROFESSOR_HARDEN_VC_SR1_2026-07-18.tar.gz
PROFESSOR_HARDEN_VC_SR1_2026-07-18.tar.gz.sha256
archive_contents.txt
archive_extraction_verification.txt
```

---

# 27. Final archive verification

The final package creation performed:

1. verification of VC-SR1, M4, and M5 case manifests;
2. cross-case classification audit;
3. confirmation of four AC-SR1 expected hashes;
4. confirmation of four OR-SR1 expected hashes;
5. confirmation of AC-SR1 and OR-SR1 acceptance records;
6. creation of a 235-entry relative case-evidence inventory;
7. verification of every listed evidence entry;
8. creation of a combined summary manifest;
9. creation of a professor-package file manifest;
10. creation of the complete campaign archive;
11. extraction into an independent temporary directory;
12. verification of the extracted campaign evidence;
13. verification of the extracted combined summary;
14. verification of the extracted professor-package documents;
15. final re-verification of all predecessor manifests;
16. final frozen-source cleanliness check.

The archive contained:

```text
1760 entries
```

and had size:

```text
4,736,828 bytes
```

The independent extraction concluded:

```text
EXTRACTED_CAMPAIGN_EVIDENCE=PASS
EXTRACTED_COMBINED_SUMMARY=PASS
EXTRACTED_PACKAGE_DOCUMENTS=PASS
ARCHIVE_EXTRACTION_VERIFICATION=PASS
```

---

# 28. Thesis-ready interpretation

The campaign can be reported in the thesis as a modular, human-reviewed, tool-checked verification study.

A concise thesis statement is:

> The case study verified a scoped functional property of the frozen ML-KEM-768 portable C implementation. A separate admissibility harness established that the production decryption callsite satisfied the signed-representability precondition. A second harness validated the independent canonical-modulo oracle. The main harness then checked the executable `mlk_poly_sub` and `mlk_poly_reduce` bodies, canonical output bounds, modular equality, frame preservation, and enabled C safety obligations. CBMC returned success for all 89 frozen properties with complete recorded loop unwinding. Two negative controls were subsequently rejected: an implementation mutant omitting reduction of coefficient 255 and an assertion mutant shifting the expected result by one modulo 3329. All source, model, command, result, classification, and packaging artefacts were hash-bound and independently reverified after archive extraction.

The claim should always be followed by its limitations.

---

# 29. Professor-facing defence points

## Why not rely only on the repository-native proof?

The campaign asks a separate composition-level semantic question and supplies an independently validated oracle, explicit callsite assumption discharge, executable-body inspection, and mutation controls.

## Why use multiple harnesses?

The proof obligations are logically distinct:

- callsite admissibility;
- oracle correctness;
- implementation semantics;
- implementation mutation;
- assertion mutation.

Combining all obligations into one large harness would reduce diagnostic clarity and make assumption boundaries harder to inspect.

## Did the harness modify the production implementation?

No. The accepted positive proof used the frozen `poly.c` body. M4 changed only an isolated copy used as a deliberate negative control. M5 left production code unchanged and changed only an isolated assertion.

## Did contracts prove the body without executing it?

No. Function and loop contracts were not enabled as body replacements. The GOTO model was inspected for the executable subtraction and reduction bodies.

## Could the proof be vacuous?

The campaign includes multiple anti-vacuity controls:

- the target call chain was found in the reachable model;
- the positive property set was frozen;
- an implementation mutation was killed;
- a false assertion was killed;
- the production-callsite assumption was separately discharged;
- the oracle was separately validated.

## Is the proof universal?

No. It is complete only for the frozen finite CBMC model and the recorded assumptions and configuration.

---

# 30. Final conclusion

The professor-hardening work successfully converted the earlier T1 canonical-domain proof into a complete modular assurance campaign.

The final accepted result is:

```text
AC-SR1   PASS
OR-SR1   PASS
VC-SR1   PASS_EXPECTED
M4       FAIL_EXPECTED_MUTANT_KILLED
M5       FAIL_EXPECTED_MUTANT_KILLED
```

The work establishes that, under the explicit signed-representability condition, the frozen ML-KEM-768 portable C execution of:

```text
mlk_poly_sub → mlk_poly_reduce
```

produces the correct canonical coefficientwise modular difference and preserves the recorded frame properties.

For the frozen production decryption callsite, the representability condition was separately established.

The proof is connected to the original T1 harness, but the professor-hardening campaign adds the evidence required to make that result defensible:

- source integrity;
- assumption discharge;
- independent oracle validation;
- executable-body verification;
- complete unwinding;
- frozen property and command sets;
- mutation sensitivity;
- manifest verification;
- independent archive re-verification.

The campaign does not prove all of ML-KEM and does not independently finalize `mlk_poly_add`. It provides a rigorous, transparent, reproducible, and appropriately scoped formal-verification result for the selected `mlk_poly_sub` followed by `mlk_poly_reduce` case study.
