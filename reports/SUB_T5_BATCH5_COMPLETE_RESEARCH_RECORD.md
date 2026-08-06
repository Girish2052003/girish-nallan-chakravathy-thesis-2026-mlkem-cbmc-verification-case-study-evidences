# SUB-T5 Batch 5 Complete Research Record

## Coefficient Locality, Frame Preservation, Cross-Coefficient Non-Interference, Exact Local-Change Propagation, and Determinism of `mlk_poly_sub`

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

---

## 1. Document purpose and scope

This document records the complete Batch 5 / SUB-T5 verification work represented by the retained campaign record for the frozen `mlk_poly_sub` implementation from `mlkem-native`.

It is written as a machine-oriented formal research record of the work performed. It consolidates:

- the exact theorem family;
- the frozen source and toolchain binding;
- the assumptions and non-claims;
- the two-run harness architecture;
- the structural distinction from the repository’s existing contract and from Batch 4;
- GOTO-model construction and loop preflight;
- positive CBMC execution;
- reachability and non-vacuity controls;
- expected-failure controls;
- semantic mutation controls;
- workflow corrections and fail-closed recovery actions;
- the qualified answer to whether `mlk_poly_sub` was proved correct;
- the research and thesis value of the resulting evidence.

This record covers the work completed through **B5.8**. A B5.9 final-packaging runner was proposed later, but the present document was authored directly from the complete retained campaign record. Therefore, this Markdown file is the authoritative narrative summary of the represented work; it is not itself a replacement for the underlying CBMC results, manifests, GOTO binaries, counterexample traces, or mutation logs stored in the campaign workspace.

---

## 2. Campaign identity

| Field | Recorded value |
|---|---|
| Verification campaign | `mlk_poly_sub` clean-room campaign |
| Batch | Batch 5 / SUB-T5 |
| Official theorem name | **Coefficient-Locality, Frame Preservation, Cross-Coefficient Non-Interference, and Determinism of `mlk_poly_sub`** |
| Repository | `/home/girish/THESIS-2026/mlkem-native` |
| Clean-room campaign root | `/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3` |
| Batch-5 root | `/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00Q_BATCH5_T5_RELATIONAL` |
| Frozen repository commit | `d9613cf60de3132d32475c102d8c2781d84feb34` |
| Short commit | `d9613cf60de3` |
| Branch | `main` |
| Parameter set | ML-KEM-768 |
| Polynomial length | `MLKEM_N = 256` |
| Modulus | `MLKEM_Q = 3329` |
| CBMC version | `6.9.0 (cbmc-6.9.0)` |
| goto-cc version | `6.9.0 (cbmc-6.9.0)` |
| Host compiler reported by goto-cc | GCC 13.3.0 |
| Host environment | Ubuntu Linux, x86-64 |
| Production definition | `mlkem/src/poly.c` |
| Public declaration and contract | `mlkem/src/poly.h` |
| Batch status covered here | B5.0 through B5.8 complete and accepted |

---

## 3. Production-source binding

### 3.1 Repository state

The authoritative repository was identified as:

```text
/home/girish/THESIS-2026/mlkem-native
```

The bound commit was:

```text
d9613cf60de3132d32475c102d8c2781d84feb34
```

The tracked worktree was recorded as clean during B5.1.

### 3.2 Authoritative production definition

The single production definition of `mlk_poly_sub` was located in:

```text
mlkem/src/poly.c
```

Its recorded bindings were:

```text
SHA-256:
f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722

Git blob:
3a25fdfe9d17c5a074dc4f7d8f926625f37fa2ff
```

The declaration and existing contract were located in:

```text
mlkem/src/poly.h
```

Its recorded bindings were:

```text
SHA-256:
f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef

Git blob:
4d9e0f82443ce185a167979c585c01de03d63ee8
```

Other repository occurrences were correctly classified as:

```text
mlkem/src/indcpa.c
    production call site

test/bench/bench_components_mlkem.c
    benchmark call site
```

Neither was an alternative definition.

### 3.3 Verified implementation form

The frozen implementation is the destructive accumulator form:

```c
MLK_INTERNAL_API
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

The polynomial representation is:

```c
typedef struct
{
  int16_t coeffs[MLKEM_N];
} MLK_ALIGN mlk_poly;
```

The mathematical operation for an initial destination polynomial `A` and source polynomial `B` is:

```text
R[i] = A[i] - B[i]
```

for every coefficient index:

```text
0 <= i < 256
```

---

## 4. Existing repository contract

The repository already contains a contract for the accumulator form of `mlk_poly_sub`. The relevant meaning is:

```text
Preconditions:
- r is a valid separately modelled polynomial object;
- b is a valid separately modelled polynomial object;
- each subtraction is representable in int16_t.

Postcondition:
- every destination coefficient equals the old destination coefficient
  minus the matching source coefficient.

Frame:
- the destination object is the assigned memory slice.
```

The contract includes the single-execution functional statement:

```text
r[k] == old(r)[k] - b[k]
```

for every coefficient.

This fact was not hidden, denied, or presented as absent. Batch 5 was deliberately designed to investigate a different proof structure: **relational behaviour across two executions** and **explicit frame preservation of named harness-owned objects**.

---

## 5. Relationship to Batch 4

Batch 4 established a single-execution arithmetic theorem over canonical coefficients:

```text
R[i] = A[i] - B[i]
```

and the range:

```text
-3328 <= R[i] <= 3328
```

under:

```text
0 <= A[i] < 3329
0 <= B[i] < 3329
```

Batch 5 did not repeat that range theorem as its primary contribution.

Batch 5 instead constructed two executions:

```c
R1 = A1;
R2 = A2;

mlk_poly_sub(&R1, &B1);
mlk_poly_sub(&R2, &B2);
```

and proved relational consequences such as:

```text
same matching inputs at k
    =>
same output at k
```

and:

```text
change only coefficient j
    =>
all outputs i != j remain unchanged
```

The core distinction is therefore:

```text
Batch 4:
single-run arithmetic correctness and result range

Batch 5:
two-run dependency structure, frame preservation,
non-interference, exact local-change propagation,
and determinism
```

---

## 6. B5.0 theorem and assumption preregistration

The theorem family was preregistered before GOTO construction or CBMC proof execution.

### 6.1 Official theorem

```text
SUB-T5:
Coefficient-Locality, Frame Preservation,
Cross-Coefficient Non-Interference,
and Determinism of mlk_poly_sub
```

### 6.2 Registered theorem components

The following sub-properties were frozen.

#### T5.1 — Input-frame preservation

After both production calls:

```text
A1_after == A1_before
A2_after == A2_before
B1_after == B1_before
B2_after == B2_before
```

Saved snapshots, duplicate snapshot witnesses, and unrelated guard polynomials were also required to remain unchanged.

#### T5.2 — Coefficient locality

For an arbitrary symbolic index `k`:

```text
A1[k] == A2[k]
B1[k] == B2[k]
```

must imply:

```text
R1[k] == R2[k]
```

No equality was required at coefficients other than `k`.

#### T5.3 — Cross-coefficient non-interference

When two input pairs differ only at symbolic coefficient `j`:

```text
A1[i] == A2[i]  for every i != j
B1[i] == B2[i]  for every i != j
```

the required conclusion is:

```text
R1[i] == R2[i]  for every i != j
```

#### T5.4 — Exact changed-coordinate effect

At the changed coordinate `j`:

```text
R1[j] == A1[j] - B1[j]
R2[j] == A2[j] - B2[j]
```

and, using widened signed arithmetic:

```text
(int32_t)R1[j] - (int32_t)R2[j]
==
((int32_t)A1[j] - (int32_t)B1[j])
-
((int32_t)A2[j] - (int32_t)B2[j])
```

#### T5.5 — Determinism

Complete equality of inputs:

```text
A1 == A2
B1 == B2
```

must imply complete equality of outputs:

```text
R1 == R2
```

#### T5.6 — Harness-observed destination-only modification boundary

Among the explicitly modelled harness-owned polynomial objects:

```text
R1 and R2 may change.

A1, A2, B1, B2,
saved snapshots,
duplicate snapshot witnesses,
and unrelated guard objects
may not change.
```

This was deliberately registered as a **harness-observed frame theorem**, not an unrestricted whole-address-space theorem.

---

## 7. Frozen assumptions

### 7.1 Canonical coefficient domain

For every coefficient index `i`:

```text
0 <= A1[i] < 3329
0 <= A2[i] < 3329
0 <= B1[i] < 3329
0 <= B2[i] < 3329
```

Therefore:

```text
-3328 <= A[i] - B[i] <= 3328
```

Signed 16-bit representability follows from this domain.

### 7.2 No conclusion-shaped arithmetic assumptions

The harness family was prohibited from independently assuming the desired result range, for example:

```c
__CPROVER_assume(d >= INT16_MIN);
__CPROVER_assume(d <= INT16_MAX);
```

Such assumptions would have hidden the arithmetic obligation instead of deriving it from the canonical domain.

### 7.3 Object assumptions

The model assumed:

- every polynomial object is a valid complete object;
- `R1`, `R2`, `A1`, `A2`, `B1`, and `B2` are separately allocated;
- saved snapshots are separately allocated;
- duplicate snapshot witnesses are separately allocated;
- unrelated guard polynomials are separately allocated;
- unsupported aliasing arrangements are outside the theorem scope.

### 7.4 Index assumptions

When used:

```text
0 <= k < 256
0 <= j < 256
```

### 7.5 Execution assumptions

The model assumed:

- sequential execution;
- single-threaded execution;
- the same frozen production implementation for both calls;
- the same frozen ML-KEM-768 configuration for both calls;
- the same frozen compiler and CBMC model.

---

## 8. Registered reachability obligations

The theorem preregistration required evidence that the relational antecedents were satisfiable.

The reachability package was required to demonstrate:

```text
k = 0
k = 127
k = 255

j = 0
j = 255

at least one non-target coefficient genuinely differs

A1[k] == A2[k]
B1[k] == B2[k]
while the complete input pairs are not identical

A1 == A2
B1 == B2
```

The positive proofs were not allowed to be accepted merely because an antecedent was unreachable.

---

## 9. Registered expected-failure controls

Two deliberately false statements were isolated.

### EF-T5-1 — False off-target influence

Under input pairs that differ only at coefficient `j`, the control asserted that some output coefficient `i != j` differs.

This claim should be rejected.

### EF-T5-2 — False nondeterminism

Under identical complete inputs, the control asserted that the complete outputs differ.

This claim should also be rejected.

Acceptance required targeted failure of the registered false assertion, not an unrelated safety error, timeout, parser failure, or random nonzero exit.

---

## 10. Registered mutation controls

The planned mutation family was:

```text
M1:
use B[i + 1] instead of B[i],
with safe boundary handling

M2:
write into B

M3:
use a preceding coefficient

M4:
skip coefficient 255
```

Compilation failure alone was explicitly rejected as sufficient evidence for killing a semantic mutant.

Each mutant had to:

- compile successfully;
- produce a valid GOTO model;
- reach the mutated production function;
- fail a relevant registered T5 assertion;
- avoid unrelated failed properties;
- avoid unknown properties;
- produce a targeted counterexample witness.

---

## 11. B5.0 recovery and integrity history

The first preregistration attempt used a long terminal heredoc. The terminal paste became corrupted and entered a continuation prompt.

The interrupted attempt created only the empty directory:

```text
SUB00Q_BATCH5_T5_RELATIONAL
```

A forensic inspection established:

```text
regular-file count: 0
preregistration file: absent
checksum file: absent
manifest: absent
```

An empty-directory recovery record was then preserved:

```text
SUB00Q_B5_0_EMPTY_DIRECTORY_RECOVERY_RECORD.txt
```

The final preregistration and recovery record were frozen with checksums.

The accepted B5.0 artefact count was:

```text
4
```

comprising:

```text
SUB00Q_B5_0_EMPTY_DIRECTORY_RECOVERY_RECORD.txt
SUB00Q_B5_0_EMPTY_DIRECTORY_RECOVERY_RECORD.txt.sha256
SUB00Q_B5_0_THEOREM_PREREGISTRATION.md
SUB00Q_B5_0_THEOREM_PREREGISTRATION.md.sha256
```

This recovery history is important because it shows that the workflow preserved failed-attempt context rather than silently deleting or overwriting it.

---

## 12. B5.1 production and parent-build binding

B5.1 established:

```text
Repository HEAD:
d9613cf60de3132d32475c102d8c2781d84feb34

Tracked worktree:
CLEAN

Production definition:
mlkem/src/poly.c

Declaration:
mlkem/src/poly.h

CBMC:
6.9.0

goto-cc:
6.9.0
```

The accepted Batch-4 evidence chain was used as the parent build reference.

The parent files included:

```text
SUB00N_B4_3_AUTHORITATIVE_PARENT_BINDING.md

SUB00N_B4_3_SUCCESSFUL_COMMAND_EXTRACTION.txt

SUB00N_BATCH4_FINAL_CONTINUATION_MLKEM768_RUN4/
BATCH4_EVIDENCE_CHAIN.txt

SUB00N_BATCH4_FINAL_CONTINUATION_MLKEM768_RUN4/
BATCH4_FINAL_COMBINED_SUMMARY.txt
```

B5.1 performed no CBMC proof execution and no GOTO construction.

---

## 13. B5.2 frozen two-run harness family

### 13.1 Input packet

The Batch-5 harness design was based on the exact retained packet:

```text
SUB00Q_B5_2_HARNESS_INPUT_PACKET_20260717T141758Z.tar.gz
```

The packet checksum matched its supplied checksum file, gzip integrity passed, and all 170 archive paths were found safe.

The packet’s `poly.c` and `poly.h` snapshots matched the B5.1 source bindings byte-for-byte.

### 13.2 Frozen harness package

The completed package was:

```text
SUB00Q_B5_2_FROZEN_HARNESS_FAMILY_V1.tar.gz
```

with SHA-256:

```text
fc277d8e72e33be20f6f4ab077f989d7b47b566e44cc9c39812b80301c99ecaa
```

It was installed at:

```text
/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/
SUB00A_d9613cf60de3/
SUB00Q_BATCH5_T5_RELATIONAL/
frozen_harness_family_v1
```

### 13.3 Harness inventory

The frozen family contained nine harnesses.

#### Positive harnesses

```text
sub_t5_frame_preservation_harness.c

sub_t5_coefficient_locality_harness.c

sub_t5_noninterference_exact_effect_harness.c

sub_t5_determinism_harness.c
```

#### Reachability harnesses

```text
sub_t5_reachability_locality_harness.c

sub_t5_reachability_changed_index_harness.c

sub_t5_reachability_identical_inputs_harness.c
```

#### Expected-failure harnesses

```text
sub_t5_expected_failure_off_target_harness.c

sub_t5_expected_failure_nondeterminism_harness.c
```

### 13.4 Support inventory

The frozen family included:

```text
sub00q_b5_fail_closed_zeroize.h

sub00q_b5_harness_common.h

sub00q_b5_optblocker_zero.c

sub00q_b5_verify_pragma_scope.h
```

### 13.5 Static validation result

The installed package produced:

```text
MANIFEST_STATUS=OK
HARNESS_COUNT=9
TWO_CALL_STRUCTURE=OK
POSITIVE_ASSUMPTION_AUDIT=OK
EXPECTED_FAILURE_ISOLATION=OK
REACHABILITY_FILE_COUNT=3
STATIC_VALIDATION=PASS
```

Every harness contained exactly two production calls.

The frozen files were made read-only.

---

## 14. B5.3 structural and distinctness audit

The B5.3 audit established:

```text
HARNESS_COUNT=9
POSITIVE_COUNT=4
REACHABILITY_COUNT=3
EXPECTED_FAILURE_COUNT=2
WRITABLE_FILE_COUNT=0
BATCH4_CANONICAL_CALL_COUNT=1
```

It further established:

```text
TWO_INDEPENDENT_PRODUCTION_CALLS_PER_HARNESS=PASS

RELATIONAL_OUTPUT_ASSERTIONS_PRESENT=PASS

REACHABILITY_CONTROLS_ISOLATED=PASS

EXPECTED_FAILURE_CONTROLS_ISOLATED=PASS

BATCH5_NOT_A_DUPLICATED_BATCH4_RANGE_HARNESS=PASS

B5_3_STATUS=PASS
```

### 14.1 Why the harness is structurally distinct from Batch 4

The Batch-4 canonical harness had one production call.

Every Batch-5 harness had two production calls.

Batch 5 contained explicit relational expressions comparing `R1` and `R2`.

The positive relational antecedents permitted globally different input states.

The frame harness explicitly referred to snapshots and unrelated guards.

Therefore, Batch 5 was not a renamed copy of a one-run range harness.

---

## 15. Why the harness is genuinely distinct from the existing `mlkem-native` contract

The repository contract is fundamentally a single-run contract:

```text
new_r[k] = old_r[k] - b[k]
```

with an assignment boundary for `r`.

The Batch-5 harness family added a different verification architecture:

1. **Two independent calls** were constructed.
2. **Two destination states** were compared.
3. **Two source states** were related through symbolic conditions.
4. **Globally different but locally equal inputs** were permitted.
5. **Cross-coordinate non-interference** was stated directly.
6. **Complete determinism** was stated as a two-run theorem.
7. **Saved snapshots and unrelated guards** were checked explicitly.
8. **Reachability companions** showed that relational antecedents were satisfiable.
9. **Expected-failure controls** rejected the opposite relational claims.
10. **Semantic mutants** tested whether the relational and frame assertions detected realistic defects.

The new harness is therefore genuinely distinct as a verification artefact and experiment.

However, the correct novelty statement is limited:

- the repository contract already provides the underlying single-run functional equation;
- some relational results can be mathematically derived from that equation;
- Batch 5’s contribution is the explicit two-run CBMC encoding, control architecture, frame instrumentation, non-vacuity checks, expected-failure tests, mutation evaluation, and frozen evidence chain;
- no universal claim is made that locality, non-interference, determinism, or relational verification have never appeared in prior literature.

---

## 16. B5.4 GOTO-model construction and loop preflight

B5.4 built and inspected one GOTO binary per harness.

The accepted summary was:

```text
CASE_COUNT=9
GOTO_BINARY_COUNT=9
GOTO_CHECKSUM_COUNT=9
BUILD_EXIT_ZERO_COUNT=9
CASE_SPECIFIC_UNWINDSET_COUNT=9
POSITIVE_CASE_COUNT=4
REACHABILITY_CASE_COUNT=3
EXPECTED_FAILURE_CASE_COUNT=2

ALL_GOTO_BUILDS=PASS

ALL_GOTO_BINARY_VALIDATIONS=PASS

ALL_PRODUCTION_CALL_GRAPHS=REACHABLE

ALL_LOOP_IDS_DERIVED_FROM_GOTO_MODELS=PASS

ALL_PROPERTY_INVENTORIES_PRESENT=PASS

B5_4_STATUS=PASS
```

### 16.1 Build model

The build configuration used the established C90/ML-KEM-768 environment, including:

```text
-std=c90

-DMLK_CONFIG_PARAMETER_SET=768

-DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00q_b5

-DMLK_CONFIG_NO_ASM=1

-DMLK_CONFIG_CUSTOM_ZEROIZE=1
```

The frozen support headers and clean-room `poly.c` were used.

### 16.2 Loop handling

Loop identifiers were extracted from the actual constructed GOTO models.

Case-specific unwindsets were then frozen using the discovered `main.*` and:

```text
mlk_sub00q_b5_poly_sub.*
```

loop identifiers.

This avoided guessing loop names or blindly copying an unwindset from another harness.

### 16.3 Preflight boundary

B5.4 performed:

```text
GOTO model construction: YES
property inventory: YES
proof execution: NO
```

---

## 17. B5.5 positive relational execution

The four positive cases were:

```text
positive_frame

positive_locality

positive_noninterference_exact

positive_determinism
```

The accepted result was:

```text
POSITIVE_CASE_COUNT=4
ZERO_EXIT_CASE_COUNT=4
FAILED_PROPERTY_TOTAL=0
UNKNOWN_PROPERTY_TOTAL=0

ALL_POSITIVE_CBMC_EXITS_ZERO=PASS

ALL_POSITIVE_PROPERTIES_SUCCESS=PASS

ALL_EXPECTED_T5_MARKERS_PRESENT=PASS

B5_5_STATUS=PASS
```

### 17.1 Positive assertion markers

The runner required registered assertion markers rather than accepting only a generic successful exit.

The marker families covered:

- frame anchors for both executions;
- preservation of `A1`, `A2`, `B1`, and `B2`;
- preservation of snapshots;
- preservation of guard objects;
- exact local arithmetic for `R1[k]` and `R2[k]`;
- coefficient locality;
- exact arithmetic for the changed coordinate;
- off-target non-interference;
- relational changed-coordinate effect;
- exact arithmetic in determinism;
- complete output determinism;
- preservation of complete input equality.

### 17.2 B5.5 runner correction

The first B5.5 runner searched for the wrong B5.4 manifest filename:

```text
SUB00Q_B5_4_ARTIFACT_MANIFEST.sha256
```

The actual file was:

```text
SUB00Q_B5_4_PREFLIGHT_ARTIFACT_MANIFEST.sha256
```

The runner failed before proof execution.

A corrected V2 runner was issued with SHA-256:

```text
2c19e99b687b0dd034ffdf95ae1fa01a11f55e794f12510a638003f50c60703e
```

The correction changed only the manifest reference. No evidence was overwritten or contaminated.

---

## 18. B5.6 reachability and non-vacuity execution

The reachability gate used two isolated mechanisms per case.

### 18.1 Cover-neutral companion proof

A companion header neutralised:

```c
__CPROVER_cover(condition)
```

only in separately built companion GOTO binaries.

These companions retained:

```text
--unwinding-assertions
```

and proved loop completion, safety properties, and a reachability anchor.

### 18.2 Original-model coverage execution

The untouched original B5.4 reachability GOTO models were executed with:

```text
--cover cover
```

The same model-derived unwindset was retained.

Coverage mode omitted explicit unwinding assertions because CBMC does not permit the selected coverage instrumentation and `--unwinding-assertions` to be combined in that form.

### 18.3 Accepted reachability result

```text
REACHABILITY_CASE_COUNT=3
COMPANION_GOTO_COUNT=3
COMPANION_PROOF_ZERO_EXIT_COUNT=3
COMPANION_PROOF_FAILURE_TOTAL=0
COMPANION_PROOF_UNKNOWN_TOTAL=0
COMPANION_ANCHOR_AUDIT_COUNT=3

COVERAGE_ZERO_EXIT_COUNT=3
COVERAGE_RESULT_COUNT=3

COVER_GOAL_EXPECTED_TOTAL=11
COVER_GOAL_SATISFIED_TOTAL=11
COVER_GOAL_FAILED_TOTAL=0

LOCALITY_COVERAGE=4_OF_4
CHANGED_INDEX_COVERAGE=5_OF_5
IDENTICAL_INPUTS_COVERAGE=2_OF_2

SAME_UNWINDSET_RETAINED=PASS

LOOP_COMPLETENESS_COMPANION_PROVED=PASS

ORIGINAL_REACHABILITY_MODELS_USED=YES

B5_6_STATUS=PASS
```

### 18.4 Eleven satisfied goals

#### Locality goals

```text
k = 0
k = 127
k = 255
locally equal but globally different inputs
```

#### Changed-coordinate goals

```text
j = 0
j = 255
only A changes
only B changes
both A and B change
```

#### Determinism goals

```text
nontrivial identical complete inputs
identical complete outputs
```

### 18.5 B5.6 patch correction

The initial B5.6 runner hard-coded the B5.5 manifest path.

A patch was issued to auto-discover the accepted B5.5 directory and manifest:

```text
patch_b5_6_manifest_autodiscovery.patch
```

Patch SHA-256:

```text
866e90892d5216fe3bb5deb23d9dd39c379dd7532305be507969bb0b2addc22f
```

The patch changed only manifest discovery and did not modify production source, frozen harnesses, or accepted evidence.

---

## 19. B5.7 expected-failure controls

The expected-failure runner required:

```text
CBMC full-model exit code = 10

exactly one target failure

zero unrelated failures

zero unknown results

targeted counterexample exit code = 10

registered expected-failure marker present
```

The accepted result was:

```text
EXPECTED_FAILURE_CASE_COUNT=2
FULL_MODEL_EXPECTED_EXIT_COUNT=2
TARGET_FAILURE_TOTAL=2
UNEXPECTED_FAILURE_TOTAL=0
UNKNOWN_PROPERTY_TOTAL=0
TARGET_PROPERTY_COUNT=2
TARGETED_WITNESS_EXPECTED_EXIT_COUNT=2
TARGETED_WITNESS_MARKER_COUNT=2

EF_T5_1_OFF_TARGET_CONTROL=REJECTED_AS_EXPECTED

EF_T5_2_NONDETERMINISM_CONTROL=REJECTED_AS_EXPECTED

ALL_NON_TARGET_PROPERTIES_SUCCESS=PASS

EXPECTED_FAILURE_ISOLATION=PASS

COUNTEREXAMPLE_WITNESSES_CAPTURED=PASS

B5_7_STATUS=PASS
```

This result demonstrated that the harness family could reject the logical opposites of locality/non-interference and determinism for the intended reasons.

---

## 20. B5.8 semantic mutation controls

Four mutant sources were generated outside the frozen production repository.

### M1 — Next source coefficient

Mutation:

```text
use B[i + 1] instead of B[i]
with safe boundary handling
```

Detector:

```text
T5.2 coefficient locality
```

Result:

```text
M1_NEXT_B_SAFE=KILLED_BY_T5_2_LOCALITY
```

### M2 — Illegal source modification

Mutation:

```text
compute the destination result,
then write into B
```

Detector:

```text
T5.1 frame preservation
```

Result:

```text
M2_WRITE_B=KILLED_BY_T5_1_FRAME
```

### M3 — Previous source coefficient

Mutation:

```text
use B[i - 1] instead of B[i]
with safe boundary handling
```

Detector:

```text
T5.2 coefficient locality
```

Result:

```text
M3_PREVIOUS_B_SAFE=KILLED_BY_T5_2_LOCALITY
```

### M4 — Skip final coefficient

Mutation:

```text
process only coefficients 0 through 254
```

Detector:

```text
T5.4 exact changed-coordinate effect
```

Result:

```text
M4_SKIP_COEFFICIENT_255=KILLED_BY_T5_4_EXACT_EFFECT
```

### 20.1 Accepted mutation summary

```text
MUTANT_COUNT=4
MUTANT_SOURCE_COUNT=4
MUTATION_DIFF_COUNT=4
GOTO_BUILD_ZERO_EXIT_COUNT=4
VALIDATED_GOTO_COUNT=4
REACHABLE_MUTATED_PRODUCTION_COUNT=4
FULL_MODEL_EXPECTED_EXIT_COUNT=4
UNEXPECTED_FAILURE_TOTAL=0
UNKNOWN_PROPERTY_TOTAL=0
PRIMARY_DETECTOR_FAILURE_COUNT=4
TARGETED_WITNESS_EXPECTED_EXIT_COUNT=4
TARGETED_WITNESS_MARKER_COUNT=4
MUTANTS_KILLED=4
MUTATION_SCORE=4_OF_4

ALL_MUTANTS_COMPILED=PASS

ALL_MUTANTS_SEMANTICALLY_KILLED=PASS

ALL_MUTATION_FAILURES_RELEVANT=PASS

ALL_COUNTEREXAMPLE_WITNESSES_CAPTURED=PASS

CLEANROOM_SOURCE_HASH_UNCHANGED=PASS

FROZEN_HARNESS_MANIFEST_UNCHANGED=PASS

B5_8_STATUS=PASS
```

The mutation evidence is stronger than merely demonstrating that faulty code fails to build. Every mutant compiled, produced a valid model, reached the mutated implementation, and was rejected by a relevant T5 property.

---

## 21. Complete gate status

| Gate | Purpose | Final status |
|---|---|---|
| B5.0 | Theorem and assumption preregistration | PASS |
| B5.1 | Production-source and parent-build binding | PASS |
| B5.2 | Two-run harness-family freeze | PASS |
| B5.3 | Structural and distinctness audit | PASS |
| B5.4 | GOTO construction and loop preflight | PASS |
| B5.5 | Positive relational execution | PASS |
| B5.6 | Reachability and non-vacuity execution | PASS |
| B5.7 | Expected-failure controls | PASS |
| B5.8 | Semantic mutation controls | PASS |

---

## 22. What was actually proved

Under the frozen assumptions and model, the evidence supports the following results.

### 22.1 T5.1 holds

The explicitly registered source polynomials, saved snapshots, duplicate snapshot witnesses, and unrelated guard polynomials were preserved.

### 22.2 T5.2 holds

For arbitrary symbolic `k`, equality of the two matching `A` coefficients and the two matching `B` coefficients implies equality of the two output coefficients at `k`, even when other coefficients differ.

### 22.3 T5.3 holds

A change confined to input coordinate `j` does not influence output coordinates `i != j`.

### 22.4 T5.4 holds

The local output at `j` equals the matching subtraction, and the difference between the two local outputs equals the widened difference between the two matching input subtractions.

### 22.5 T5.5 holds

Identical complete inputs produce identical complete outputs.

### 22.6 T5.6 holds

Among the explicitly modelled harness-owned objects, only the destination objects are modified.

### 22.7 Non-vacuity holds

The registered relational antecedents were reachable in boundary, interior, globally different, locally equal, and identical-input configurations.

### 22.8 Negative controls behaved correctly

The false off-target-influence and false nondeterminism statements were rejected with isolated counterexamples.

### 22.9 Mutation sensitivity holds for the selected mutant set

All four selected semantic dependency/frame mutants were detected by their intended theorem families.

---

## 23. Did this prove that `mlk_poly_sub` is really correct?

### 23.1 Qualified answer

Yes.

The exact frozen ML-KEM-768 production implementation was proved correct for the registered Batch-5 relational and frame properties under the frozen canonical coefficient domain, object-separation assumptions, sequential execution model, source/build binding, toolchain, and unwind configuration.

Combined with the accepted Batch-4 arithmetic theorem:

```text
R[i] = A[i] - B[i]
```

and the canonical-domain result bound:

```text
-3328 <= R[i] <= 3328
```

the accumulated evidence supports both:

1. the coefficient-wise subtraction result; and
2. the frame, dependency, locality, non-interference, exact local-change, and determinism structure investigated in Batch 5.

### 23.2 What should not be claimed

The correct statement is not:

```text
mlk_poly_sub is universally correct in every possible context.
```

The supported statement is:

```text
The frozen mlk_poly_sub implementation satisfies the registered
single-run arithmetic and Batch-5 relational/frame properties under
the explicitly frozen assumptions and CBMC model.
```

This is a genuine formal-verification result. It is property-specific and assumption-dependent, as formal evidence should be.

---

## 24. Non-claims and limitations

Batch 5 does not establish:

1. unrestricted whole-memory preservation;
2. correctness under arbitrary pointer aliasing;
3. thread safety;
4. concurrent non-interference;
5. constant-time execution;
6. absence of cache, branch-predictor, speculative-execution, or other microarchitectural leakage;
7. correctness for coefficients outside the canonical domain;
8. correctness for an unbound ML-KEM parameter set;
9. modular reduction or output canonicalisation;
10. complete correctness of every `mlkem-native` function;
11. complete correctness of the whole ML-KEM implementation;
12. complete correctness of every external caller;
13. universal novelty across all public literature;
14. absence of related relational properties in other verification systems;
15. correctness for unsupported build configurations;
16. correctness if the frozen assumptions are violated.

---

## 25. Why the result is scientifically useful

### 25.1 It separates arithmetic from dependency structure

A range proof alone does not directly demonstrate that a coefficient is independent of all unrelated coefficients.

Batch 5 explicitly checked that dependency relation.

### 25.2 It uses relational verification

Two executions were represented in one verification model and compared through symbolic relations.

This is structurally richer than a single-run postcondition check.

### 25.3 It includes non-vacuity

The proof did not rely only on assumptions that might accidentally eliminate all interesting states.

Boundary, interior, globally different, locally equal, and identical-input states were demonstrated reachable.

### 25.4 It includes negative controls

The verification environment showed that it could reject false versions of the desired theorems.

### 25.5 It includes semantic mutation testing

The properties detected realistic dependency and frame defects in compiling, reachable mutants.

### 25.6 It preserves trust boundaries

The LLM-assisted workflow proposed and constructed candidate artefacts.

The authoritative results came from:

- source hashes;
- Git bindings;
- GOTO validation;
- CBMC property results;
- cover results;
- expected-failure traces;
- mutation counterexamples;
- manifests;
- terminal exit codes;
- documented acceptance review.

The LLM output was not treated as proof by itself.

---

## 26. Thesis positioning

This campaign can be positioned as evidence for an AI-assisted formal-artifact workflow with documented acceptance review.

The defensible contribution is not that an LLM independently proved cryptographic software correct.

The defensible contribution is:

1. an LLM-assisted workflow proposed a distinct relational property family;
2. it generated candidate harnesses and controls;
3. the harness family was frozen and structurally audited;
4. production source and build context were bound deterministically;
5. CBMC generated the authoritative proof and counterexample evidence;
6. reachability, negative controls, and semantic mutations tested whether the artefacts were meaningful;
7. documented acceptance review preserved the claims, assumptions, and limitations.

A suitable thesis statement is:

> The Batch-5 case study demonstrates that an LLM-assisted workflow can construct candidate two-run CBMC verification artefacts for locality, non-interference, determinism, and frame preservation, while deterministic source binding, CBMC execution, reachability controls, expected failures, mutation testing, and documented acceptance review remain the basis of assurance.

---

## 27. Professor-facing concise verdict

The following wording accurately summarises the result:

> Batch 5 verified the frozen ML-KEM-768 `mlk_poly_sub` implementation using a separate two-execution relational harness family. Under canonical coefficients and explicitly separated polynomial objects, CBMC proved input-frame preservation, coefficient locality, cross-coefficient non-interference, exact changed-coordinate propagation, complete determinism, and a harness-observed destination-only modification boundary. All four positive cases passed; all eleven registered reachability goals were satisfied; both deliberately false relational controls were rejected with isolated counterexamples; and four independently compiling semantic mutants were killed by the intended properties. The result is distinct from the repository’s existing single-execution contract and from the earlier Batch-4 range proof, although it does not claim unrestricted aliasing, concurrency, side-channel security, whole-library correctness, or universal literature novelty.

---

## 28. Main artefact inventory

### B5.0

```text
SUB00Q_B5_0_EMPTY_DIRECTORY_RECOVERY_RECORD.txt
SUB00Q_B5_0_EMPTY_DIRECTORY_RECOVERY_RECORD.txt.sha256
SUB00Q_B5_0_THEOREM_PREREGISTRATION.md
SUB00Q_B5_0_THEOREM_PREREGISTRATION.md.sha256
```

### B5.1

```text
B5_1_PRODUCTION_AND_PARENT_BINDING/
SUB00Q_B5_1_BINDING_EXTRACTION.txt
SUB00Q_B5_1_BINDING_EXTRACTION.txt.sha256
SUB00Q_B5_1_AUTHORITATIVE_BINDING.md
SUB00Q_B5_1_AUTHORITATIVE_BINDING.md.sha256

SUB00Q_B5_2_HARNESS_INPUT_DISCOVERY.txt
SUB00Q_B5_2_HARNESS_INPUT_DISCOVERY.txt.sha256
```

### B5.2

```text
frozen_harness_family_v1/
SUB00Q_B5_2_ARTIFACT_MANIFEST.sha256
SUB00Q_B5_2_BUILD_PLAN.md
SUB00Q_B5_2_HARNESS_FAMILY_FREEZE.md
SUB00Q_B5_2_INPUT_PACKET_BINDING.txt
SUB00Q_B5_2_SOURCE_BINDING.txt
harnesses/
support/
scripts/
```

### B5.3

```text
B5_3_STRUCTURAL_DISTINCTNESS_AUDIT/
SUB00Q_B5_3_STRUCTURAL_DISTINCTNESS_AUDIT.txt
SUB00Q_B5_3_STRUCTURAL_DISTINCTNESS_AUDIT.txt.sha256
```

### B5.4

```text
B5_4_GOTO_PREFLIGHT_MLKEM768/
build/
commands/
logs/
inspection/
exit_codes/
SUB00Q_B5_4_PREFLIGHT_SUMMARY.txt
SUB00Q_B5_4_EXECUTION_INPUT_FREEZE.md
SUB00Q_B5_4_PREFLIGHT_ARTIFACT_MANIFEST.sha256
executed_runner.sh
```

### B5.5

```text
B5_5_POSITIVE_RELATIONAL_EXECUTION_MLKEM768_RUN1/
results/
commands/
logs/
exit_codes/
resource_usage/
frozen_inputs/
SUB00Q_B5_5_POSITIVE_EXECUTION_SUMMARY.txt
SUB00Q_B5_5_EXECUTION_INPUT_BINDING.txt
SUB00Q_B5_5_ARTIFACT_MANIFEST.sha256
executed_runner.sh
```

### B5.6

```text
B5_6_REACHABILITY_EXECUTION_MLKEM768_RUN1/
companion_build/
companion_proof_results/
coverage_results/
inspection/
commands/
logs/
exit_codes/
resource_usage/
frozen_inputs/
support/
SUB00Q_B5_6_REACHABILITY_SUMMARY.txt
SUB00Q_B5_6_EXECUTION_INPUT_BINDING.txt
SUB00Q_B5_6_ARTIFACT_MANIFEST.sha256
executed_runner.sh
```

### B5.7

```text
B5_7_EXPECTED_FAILURE_CONTROLS_MLKEM768_RUN1/
full_model_results/
targeted_witnesses/
commands/
logs/
exit_codes/
resource_usage/
frozen_inputs/
SUB00Q_B5_7_EXPECTED_FAILURE_SUMMARY.txt
SUB00Q_B5_7_EXECUTION_INPUT_BINDING.txt
SUB00Q_B5_7_ARTIFACT_MANIFEST.sha256
executed_runner.sh
```

### B5.8

```text
B5_8_MUTATION_CONTROLS_MLKEM768_RUN1/
mutant_sources/
mutation_diffs/
goto_build/
full_model_results/
targeted_witnesses/
commands/
logs/
exit_codes/
resource_usage/
frozen_inputs/
SUB00Q_B5_8_MUTATION_SUMMARY.txt
SUB00Q_B5_8_EXECUTION_INPUT_BINDING.txt
SUB00Q_B5_8_ARTIFACT_MANIFEST.sha256
executed_runner.sh
```

---

## 29. Runner and package checksums recorded in the retained record

```text
Frozen B5.2 harness package:
fc277d8e72e33be20f6f4ab077f989d7b47b566e44cc9c39812b80301c99ecaa

B5.4 preflight runner:
81fc1e65b2dbd154f95854928be66865470935f038ffa6785c79ca52f6a561a1

B5.5 positive runner V2:
2c19e99b687b0dd034ffdf95ae1fa01a11f55e794f12510a638003f50c60703e

B5.6 manifest auto-discovery patch:
866e90892d5216fe3bb5deb23d9dd39c379dd7532305be507969bb0b2addc22f

B5.7 expected-failure runner:
710c13934faf49aeefb2d2c067abadb14d55927a33e888704b2fca17189d2074

B5.8 mutation-control runner:
32523d7e251d76394f3c1b22af194c7333f9d3c63759b479b78965e1fa37234b
```

---

## 30. Integrity and honesty statement

The following distinctions must remain explicit in future thesis writing and presentations.

### Proven by CBMC

- registered positive assertions under the frozen model;
- safety checks included in the executed models;
- reachability of the registered cover goals;
- rejection of the two expected-failure assertions;
- detection of the four compiling semantic mutants.

### Established by deterministic binding and manifests

- exact source revision;
- exact source-file hashes;
- exact harness files;
- exact GOTO models;
- exact runner inputs;
- immutability and stage-to-stage evidence continuity.

### Supplied by candidate-generation and analytical reasoning

- theorem selection;
- harness architecture;
- property decomposition;
- expected-failure design;
- mutation design;
- interpretation of what the evidence does and does not establish.

The reasoning and generated artefacts are not themselves the proof. The proof authority comes from the deterministic tool results under the frozen model.

---

## 31. Final conclusion

Batch 5 was successfully completed through B5.8.

The resulting evidence demonstrates that the frozen ML-KEM-768 `mlk_poly_sub` implementation satisfies the registered relational and frame properties under the frozen assumptions.

The campaign established:

```text
T5.1 input-frame preservation
T5.2 coefficient locality
T5.3 cross-coefficient non-interference
T5.4 exact changed-coordinate effect
T5.5 determinism
T5.6 harness-observed destination-only modification
```

with:

```text
4/4 positive relational cases passed

11/11 reachability goals satisfied

2/2 false relational controls rejected

4/4 compiling semantic mutants killed

0 positive failed properties

0 positive unknown properties

0 unexpected expected-failure properties

0 unexpected mutation failures
```

The new harness family is genuinely distinct from the repository’s existing single-run contract and from Batch 4’s arithmetic/range proof because it uses two executions, explicit relational antecedents, cross-run output comparisons, frame snapshots, unrelated guard objects, non-vacuity checks, false-claim controls, and semantic mutation evaluation.

The correct final correctness claim is:

> The exact frozen `mlk_poly_sub` implementation is proved correct for the registered Batch-4 arithmetic property and Batch-5 relational/frame properties under the explicit canonical-domain, object-separation, sequential-execution, source-binding, build, and CBMC-model assumptions.

No broader claim should be made without additional verification.

---
