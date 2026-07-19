# Complete Research Verification Record

## AI-Assisted CBMC Verification of `mlk_poly_add` and `mlk_poly_sub` in `mlkem-native`

**Researcher:** Girish Nallan Chakravathy  
**Institutional context:** MSc thesis, Tampere University  
**Case study:** ML-KEM / FIPS 203 implementation in `mlkem-native`  
**Primary verification tool:** CBMC 6.9.0  
**Main frozen source commit:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Principal completed campaign:** SUB-T6 — production call-site integration for `mlk_poly_sub`  
**Record date:** 18 July 2026  
**Document status:** Consolidated technical and research record prepared from the retained conversation, terminal outputs, uploaded intermediate evidence packages, source/manifests inspected during the campaign, and a public prior-art search completed on 18 July 2026.

---

# Executive summary

I conducted a controlled formal-verification case study on selected polynomial operations in the C implementation of ML-KEM provided by `mlkem-native`. The work began with exploratory `mlk_poly_add` properties and then developed into a much more rigorous clean-room verification campaign for `mlk_poly_sub`.

The strongest completed result is **SUB-T6**, a property-specific and assumption-dependent CBMC verification of the following production slice used inside `mlk_indcpa_dec`:

```c
mlk_poly_sub(&v, &sb);
mlk_poly_reduce(&v);
mlk_poly_tomsg(m, &v);
```

The campaign did not re-execute or prove all operations that compute `v` and `sb`. Instead, it modeled the relevant upstream postconditions and proved the registered properties of the actual production `mlk_poly_sub`, `mlk_poly_reduce`, and `mlk_poly_tomsg` implementations under those assumptions.

For the frozen ML-KEM-768 configuration, the completed SUB-T6 campaign established:

1. object validity and separation for the modeled successful call path;
2. derivation of signed-16 subtraction representability from the registered caller bounds;
3. exact coefficient-wise behavior of the production `mlk_poly_sub` call;
4. preservation of the source operand and registered caller-owned state;
5. a valid handoff from exact subtraction to `mlk_poly_reduce`;
6. canonical input suitability for `mlk_poly_tomsg` and preservation of the polynomial input by `mlk_poly_tomsg`;
7. bounded safety of the complete registered slice with complete loop unwinding.

The final local campaign verdict recorded:

```text
Positive CBMC properties:             2343 SUCCESS
Positive failures:                    0
Positive unknowns:                    0

Reachability companion properties:    365 SUCCESS
Reachability covers:                  12 / 12 SATISFIED

Expected-failure controls:             3 / 3 rejected as intended
Unexpected failures in controls:       0
Unknown properties in controls:        0

Mandatory mutants:                     4 / 4 killed
Detector executions:                   5 / 5
Documented causal collateral:          1
Unrelated mutation failures:           0
Unknown mutation properties:           0

Production-source modification:        NO
Frozen positive-harness modification:  NO
All stage manifests revalidated:       PASS
SUB-T6 campaign status:                PASS
```

The final locally generated archive was reported as:

```text
SUB_T6_FINAL_EVIDENCE_2026-07-18.tar.gz
SHA-256:
af430f410e63a51d75f7196764f18d22be5af7baf93c9235e5e191eb1c6e0522

Size:
5,711,132 bytes
```

The final B6.8+B6.9 archive was not uploaded into this chat before this document was generated. Its final hash and verdict are therefore supported by the preserved terminal output. Earlier archives for B6.3+B6.4, B6.5, and B6.6+B6.7 were independently uploaded and inspected during the campaign.

The novelty conclusion is intentionally narrow:

- Basic exact addition, exact subtraction, canonical reduction, memory safety, type safety, and the existence of CBMC proofs for `poly_add`, `poly_sub`, and higher-level ML-KEM functions are **not new**.
- The independently authored **call-site property decomposition**, explicit arithmetic oracle checks, caller-frame claims, subtract–reduce–`tomsg` handoff checks, reachability controls, deliberately false controls, mutation sensitivity, clean-room provenance, source/GOTO/result binding, and failed-attempt preservation form the defensible research contribution.
- A public search found no exact public match for this complete SUB-T6 artefact-and-evidence combination. This supports a cautious claim of a distinct case-study contribution, but it does not prove universal nonexistence and does not justify a “first ever” claim.

---

# 1. Research purpose

The purpose of this work was not simply to execute CBMC on an existing repository. The research problem was whether an API-backed or conversational LLM workflow could assist a human researcher in moving through the complete verification process:

```text
specification and implementation context
        ↓
candidate properties
        ↓
candidate harnesses and verification artefacts
        ↓
deterministic source and integrity checks
        ↓
GOTO construction
        ↓
CBMC execution
        ↓
counterexample diagnosis
        ↓
repair or refinement
        ↓
negative controls and mutation testing
        ↓
reproducible evidence package
```

The work was evaluated at three levels:

1. **Verification result:** which selected properties of the frozen C implementation were actually established.
2. **Verification methodology:** how assumptions, source identity, harness identity, loop completeness, non-vacuity, negative controls, mutations, and evidence manifests were controlled.
3. **AI-assistance evaluation:** where AI assistance was useful, where it failed, and why CBMC plus deterministic validation—not the LLM—remained authoritative.

The LLM proposed properties, generated candidate scripts, interpreted results, and assisted documentation. It did not prove the program. A claim was accepted only after deterministic source checks, GOTO-model construction, CBMC execution, result parsing, controls, and evidence freezing.

---

# 2. Technical background

ML-KEM is the Module-Lattice-Based Key-Encapsulation Mechanism standardized in NIST FIPS 203. Its polynomial arithmetic uses the quotient ring:

\[
R_q = \mathbb{Z}_q[X]/(X^{256}+1)
\]

with:

```text
MLKEM_N = 256
MLKEM_Q = 3329
```

The completed campaign used:

```text
Parameter set: ML-KEM-768
MLKEM_K: 3
C dialect: C90 with repository-required fixed-width types
CBMC: 6.9.0
goto-cc: 6.9.0
goto-instrument: 6.9.0
Portable C arithmetic path: selected
Assembly backend: disabled for the CBMC campaign
```

The relevant production decryption sequence is:

```c
mlk_polyvec_basemul_acc_montgomery_cached(&sb, skpv, b, b_cache);
mlk_poly_invntt_tomont(&sb);

mlk_poly_sub(&v, &sb);
mlk_poly_reduce(&v);

mlk_poly_tomsg(m, &v);
```

SUB-T6 begins immediately before the actual `mlk_poly_sub` call. It does not prove the preceding unpacking, decompression, polynomial-vector multiplication, inverse NTT, allocation, or complete decryption procedure.

---

# 3. Frozen source and campaign identity

## 3.1 Repository and clean-room roots

The active local repository path was:

```text
/home/girish/THESIS-2026/mlkem-native
```

The frozen clean-room campaign root was:

```text
/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/
SUB00A_d9613cf60de3
```

The SUB-T6 batch root was:

```text
/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/
SUB00A_d9613cf60de3/
SUB00R_BATCH6_T6_CALLSITE_INTEGRATION
```

The source commit was:

```text
d9613cf60de3132d32475c102d8c2781d84feb34
```

## 3.2 Initial clean-room packet

The accepted SUB-00A packet had:

```text
SHA-256:
e557c98ff5d3e3735d9f9f59c67a030e87ea0f4898b92d120856321a74ba7f45
```

It contained a manifest of 341 tracked source entries. The initial property-discovery input excluded paths containing terms such as:

```text
proofs/
tests/
test/
examples/
*harness*
```

The purpose was to prevent direct reuse of the repository’s existing CBMC harnesses during initial independent property development.

This clean-room restriction does **not** mean the upstream proofs did not exist. A later overlap audit correctly established that upstream `mlkem-native` already had CBMC contracts and proof directories for relevant functions. The restriction means that those proof artefacts were excluded from the first property-discovery input.

## 3.3 Authoritative source hashes

The final campaign bound the following important files:

```text
poly.c:
f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722

poly.h:
f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef

compress.c:
9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad

compress.h:
0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

cbmc.h:
12fe62f76060aa2cdd41de6170e0c787c516ae753ed32579c9c39b1af55130fb
```

Mutations were created only in dedicated copies. The production source files were not patched.

---

# 4. Evidence hierarchy and trust boundary

The final evidence hierarchy was:

1. frozen commit and source hashes;
2. preregistered verification intent;
3. explicit assumptions and nonclaims;
4. frozen harness family and support files;
5. frozen GOTO binaries and hashes;
6. call graph, loop, undefined-function, and property inventories;
7. exact CBMC command and model-derived unwindset;
8. raw CBMC JSON/text results;
9. deterministic result parsing;
10. reachability and non-vacuity controls;
11. deliberately false expected-failure controls;
12. mutation sensitivity;
13. stage manifests;
14. final archive hash.

The LLM’s narrative was never proof evidence. This distinction became especially important because several generated runners contained errors. Those errors were discovered by deterministic execution, not by confidence in the generated text.

---

# 5. What upstream `mlkem-native` already verifies

The public `mlkem-native` project already has a substantial formal-verification framework.

Its public documentation states that the C code is checked with CBMC for memory safety, type safety, and selected classes of undefined behavior. It uses function contracts and loop invariants embedded in the C source. The repository also includes formal verification for optimized assembly through HOL Light and the `s2n-bignum` infrastructure.

The relevant upstream C source already contains functional specifications for simple polynomial operations. Conceptually, the existing contracts state:

```text
mlk_poly_add:
r[k] after the call equals old(r[k]) + b[k]

mlk_poly_sub:
r[k] after the call equals old(r[k]) - b[k]
```

subject to valid-object, non-aliasing, and no-overflow preconditions.

The public `mlk_poly_sub` body also contains a loop invariant that distinguishes processed and unprocessed coefficients. The upstream framework therefore already addresses:

- exact coefficient-wise subtraction;
- loop progression over the polynomial;
- memory/type safety under contracts;
- bounds required to avoid arithmetic overflow;
- modular function-level verification;
- higher-level CBMC proof targets, including `indcpa_dec`.

Consequently, this thesis must **not** claim any of the following as new:

- the first proof that `mlk_poly_add` adds coefficients;
- the first proof that `mlk_poly_sub` subtracts coefficients;
- the first proof that all 256 coefficients are processed;
- the first proof that `mlk_poly_reduce` returns canonical coefficients;
- the first memory-safety or type-safety proof for these functions;
- the first CBMC verification involving `mlk_indcpa_dec`;
- the first use of CBMC contracts or loop invariants in `mlkem-native`.

---

# 6. Earlier `mlk_poly_add` work

## 6.1 Why the addition campaign was started

The initial `mlk_poly_add` experiment was used to learn how to:

- extract a simple arithmetic specification from implementation context;
- formulate CBMC assumptions;
- build a harness around a small production function;
- distinguish arithmetic correctness from representability;
- interpret a CBMC counterexample;
- understand the relation between source contracts and independently authored assertions.

The function is small, but small size does not remove the need for precise assumptions. Its assignment uses signed fixed-width coefficients, so unrestricted mathematical addition cannot be equated with defined C addition.

## 6.2 Reliable retained status

The correct status of the earlier addition work is:

```text
PA-01: accepted under its registered assumptions
PA-02: accepted under its registered assumptions
PA-03: deliberately unrestricted signed-int16 negative control;
       CBMC produced the expected counterexample
PA-04: no reliable final accepted result located in the retained record
PA1–PA9 as a complete family: not completed and not accepted
```

The PA-03 counterexample did not establish a defect in `mlk_poly_add`. It established that unrestricted signed-16 addition cannot be safely claimed without a representability precondition.

## 6.3 What is true about `mlk_poly_add`

The academically defensible statement is:

> Under valid, disjoint polynomial objects and coefficient-wise assumptions ensuring that each mathematical sum is representable in `int16_t`, the production implementation computes exact in-place coefficient-wise addition.

This statement is consistent with the upstream contract. It is not a new result created by my campaign.

## 6.4 Did I prove that `mlk_poly_add` is “really correct”?

Not comprehensively.

I did **not** establish:

- correctness for every possible signed-16 input pair;
- a complete PA1–PA9 proof family;
- correctness of every caller that uses `mlk_poly_add`;
- modular reduction of the result unless a separate reduction call is included;
- end-to-end ML-KEM correctness.

The addition work should be presented as an exploratory and methodological precursor, not as the primary completed theorem.

## 6.5 Value of the addition work

The addition campaign produced lessons that directly improved the later subtraction campaign:

- assumptions must be explicit;
- negative controls must not be mislabeled as software defects;
- arithmetic oracles should use a wider type;
- function-body correctness and caller applicability are different claims;
- passing assertions do not prove non-vacuity;
- source contracts must be compared before claiming originality;
- proof results must be accompanied by source, command, loop, and result binding.

---

# 7. Development of the `mlk_poly_sub` property families

The subtraction work evolved through several property families.

| Family | Purpose | Reliable status |
|---|---|---|
| SUB-T0 | Baseline body-level safety and exact subtraction | Overlaps upstream proof; used as baseline |
| SUB-T1 | Exact subtraction followed by canonical modular reduction | Earlier accepted campaign |
| SUB-T2 | Relational properties | Designed; final evidence not revalidated for this record |
| SUB-T3 | Add/sub cancellation | Designed; final evidence not revalidated for this record |
| SUB-T4 | Canonical-domain and boundary controls | Harness/control family developed |
| SUB-T5 | Frame, locality, and determinism | Harness family developed |
| SUB-T6 | Production call-site and subtract–reduce–`tomsg` integration | Completed |

## 7.1 SUB-T1

The retained accepted SUB-T1 result recorded:

```text
CBMC properties:   361 / 361 SUCCESS
Reachability:        8 / 8
Mutants killed:      3 / 3
Mutation score:      100%
```

Its intended result was that actual `mlk_poly_sub` followed by actual `mlk_poly_reduce` yields a canonical representative of the coefficient-wise difference modulo \(q\), under the registered assumptions.

The mathematical fact is not a new theorem. Its research value lies in the independently executable property artefact and the validation controls.

## 7.2 SUB-T4

The SUB-T4 family included:

- a canonical-domain positive harness;
- invalid-lower and invalid-upper companion harnesses;
- a reachability harness;
- boundary-oriented checks.

## 7.3 SUB-T5

The SUB-T5 family registered relational and frame properties across two executions:

```text
R1 = A1
R2 = A2

mlk_poly_sub(&R1, &B1)
mlk_poly_sub(&R2, &B2)
```

It considered:

- preservation of source operands;
- coefficient locality;
- determinism.

A locality statement had the form:

```text
A1[k] == A2[k] and B1[k] == B2[k]
implies
R1[k] == R2[k]
```

The SUB-T6 campaign later reused a validated support component with provenance rather than silently copying an untracked file.

---

# 8. SUB-T6 verification intent

## 8.1 Registered theorem title

**Production Call-Site Contract Satisfaction and Subtract–Reduce Handoff Correctness of `mlk_poly_sub` in `mlk_indcpa_dec`.**

The word “correctness” is restricted to the registered properties and assumptions. It does not mean complete decryption correctness.

## 8.2 Executed production slice

The harnesses executed the actual production calls:

```c
mlk_poly_sub(&v, &sb);
mlk_poly_reduce(&v);
mlk_poly_tomsg(m, &v);
```

The positive harnesses did not replace these operations with mathematical stubs.

## 8.3 Upstream boundary

The operations before `mlk_poly_sub` were modeled through bounds rather than executed:

```c
mlk_polyvec_basemul_acc_montgomery_cached(...);
mlk_poly_invntt_tomont(&sb);
```

The central modeled input domain was:

```text
0 <= v[i] < 3329
-26632 < sb[i] < 26632
```

Equivalently:

```text
v[i] ∈ [0, 3328]
sb[i] ∈ [-26631, 26631]
```

---

# 9. SUB-T6 assumptions

## 9.1 Parameter and tool assumptions

```text
Parameter set: ML-KEM-768
MLKEM_N: 256
MLKEM_Q: 3329
Inverse-NTT-related registered bound: 26632
CBMC/goto version: 6.9.0
C backend: portable C
Assembly backend: disabled
```

## 9.2 Object assumptions

The harnesses modeled:

- a valid `mlk_poly` object for `v`;
- a valid `mlk_poly` object for `sb`;
- distinct storage for `v` and `sb`;
- valid destination storage for the message;
- a successful object-availability path.

The campaign did not prove allocation failure handling.

## 9.3 Arithmetic assumptions

For every coefficient \(i\):

\[
0 \leq v_i < 3329
\]

and:

\[
-26632 < sb_i < 26632
\]

Therefore:

\[
v_i - sb_i
\]

has minimum:

\[
0 - 26631 = -26631
\]

and maximum:

\[
3328 - (-26631) = 29959
\]

Thus:

\[
-26631 \leq v_i - sb_i \leq 29959
\]

Since:

\[
-32768 \leq -26631
\]

and:

\[
29959 \leq 32767
\]

the exact subtraction result is representable in signed 16-bit storage.

This arithmetic derivation is the basis of T6.2.

## 9.4 Loop assumptions

Reachable loops were identified from the built GOTO model. The unwindset was derived from the model rather than entered as an unexplained constant. The loops over 256 coefficients used an unwind allowance sufficient to reach the terminating condition and check the unwinding assertion.

## 9.5 Verification-adapter assumptions

The campaign required a carefully controlled relationship between:

- ordinary compilation;
- CBMC contract macros;
- `verify.h`;
- `cbmc.h`;
- `compress.h` unsigned-wrap pragmas.

A verified recovery adapter preserved the intended unsigned-wrap policy in `mlk_scalar_compress_d1` without activating unwanted contract-helper calls in the generated GOTO model.

---

# 10. SUB-T6 nonclaims

SUB-T6 does not claim:

- complete correctness of `mlk_indcpa_dec`;
- correctness of ciphertext unpacking;
- correctness of decompression;
- correctness of polynomial-vector multiplication;
- correctness of inverse NTT;
- correctness of all allocation paths;
- correctness of the full K-PKE decryption algorithm;
- correctness of ML-KEM encapsulation or decapsulation;
- correctness for ML-KEM-512 or ML-KEM-1024;
- constant-time behavior;
- absence of power, electromagnetic, fault-injection, or speculative side channels;
- end-to-end equivalence with FIPS 203;
- functional correctness of optimized assembly;
- universal correctness outside the registered input bounds.

---

# 11. The seven SUB-T6 properties

## T6.1 — Object validity and separation

The harness constructs valid polynomial objects and ensures that the mutable destination and source polynomial are distinct.

This proves the object and separation conditions inside the modeled successful path. It does not prove every real allocator behavior or every possible production caller.

## T6.2 — Representability derivation

From the modeled caller ranges, the campaign proves that every exact coefficient difference lies in:

```text
[-26631, 29959]
```

which is inside signed 16-bit range.

This is a mathematical bridge from upstream range information to the no-overflow precondition of subtraction.

## T6.3 — Exact call-site subtraction

Before calling the production function, the harness snapshots the inputs. After the call it checks:

```text
result[i] ==
(int32_t)old_v[i] - (int32_t)old_sb[i]
```

for every coefficient.

The oracle is evaluated in a wider type so the specification itself does not reproduce signed-16 overflow.

## T6.4 — Caller-frame preservation

The frame harness checks that the const source polynomial and registered caller-owned state are not modified by the subtraction call.

This is stronger in presentation than merely relying on the C `const` qualifier, because it creates an explicit executable postcondition.

## T6.5 — Subtract–reduce handoff

The harness records the exact post-subtraction coefficients, calls the real production reduction routine, and verifies the registered relationship and canonical output range.

It checks that the output from subtraction is a legitimate input to the real reduction step under the campaign assumptions.

## T6.6 — `tomsg` precondition and const-input behavior

After actual subtraction and actual reduction, the harness checks:

```text
0 <= v[i] < 3329
```

before calling the production `mlk_poly_tomsg`.

It also snapshots `v` and verifies that `mlk_poly_tomsg` does not modify its polynomial input.

## T6.7 — Complete bounded slice safety

The combined registered slice was checked with CBMC safety options including:

- bounds checks;
- pointer checks;
- pointer-overflow checks;
- pointer-primitive checks;
- signed-overflow checks;
- unsigned-overflow checks, subject to the production-intended local wrap policy;
- conversion checks;
- shift checks;
- division-by-zero checks;
- unwinding assertions.

This remains a bounded proof over the modeled finite loops and registered input domain.

---

# 12. Frozen positive harness family

The frozen B6.3 family contained five harnesses:

```text
sub_t6_callsite_precondition_harness.c
sub_t6_callsite_exactness_harness.c
sub_t6_callsite_frame_harness.c
sub_t6_sub_reduce_handoff_harness.c
sub_t6_tomsg_precondition_harness.c
```

Support files included:

```text
sub00r_b6_harness_common.h
sub00r_b6_fail_closed_zeroize.h
sub00r_b6_verify_pragma_scope.h
sub00r_b6_optblocker_zero.c
```

The frozen family path was:

```text
03_HARNESS_FREEZE/frozen_harness_family_v1
```

The positive harnesses were not modified after freezing. The later `tomsg` correction rebuilt the GOTO model with a corrected verification adapter; it did not edit the frozen T6.6 harness.

---

# 13. Why the harness family is distinct from upstream `mlkem-native`

The correct claim is not that the new harness has no relationship to `mlkem-native`. It calls the same production functions, uses the same data structures and constants, and is constrained by the same mathematics.

Its distinction is methodological and property-oriented.

## 13.1 Independent clean-room origin

The first property-development input excluded upstream proof and harness directories. The new family was authored from production source, contracts, call-chain context, and registered research goals.

## 13.2 Different verification purpose

An ordinary modular upstream harness typically exists to establish a function’s embedded contract. The SUB-T6 family was designed to evaluate a broader caller-oriented theorem decomposition:

```text
caller bounds
    ↓
subtraction representability
    ↓
exact production subtraction
    ↓
frame preservation
    ↓
production reduction
    ↓
canonical tomsg input
    ↓
bounded slice safety
```

## 13.3 Explicit mathematical oracles

The exactness harness computes a wider-type oracle and compares every production coefficient to the mathematical difference.

## 13.4 Explicit snapshots and frame assertions

The source operand and caller-owned state are copied and compared after execution. This produces named, independently visible frame evidence.

## 13.5 Multi-function integration

The strongest harnesses compose three real production functions rather than checking only one isolated function body.

## 13.6 Independent credibility controls

The campaign adds:

- 12 explicit reachability goals;
- an assertion-preserving reachability companion;
- three deliberately false expected-failure controls;
- four mandatory mutants;
- five registered mutation-detector executions;
- targeted counterexample witnesses;
- failed-attempt preservation;
- stage and final manifests.

## 13.7 Exact overlap boundary

The new family is **not mathematically independent** of upstream contracts. It uses upstream bounds and calls upstream functions. It should be called:

> an independently authored, caller-oriented validation and evaluation harness family for the frozen production implementation.

It should not be called:

> a completely unrelated proof, a replacement for the upstream verification, or the first proof of subtraction.

---

# 14. B6.3 and B6.4 — harness freeze and GOTO preflight

B6.3 froze the five-harness family and its support files.

B6.4 built and validated five GOTO binaries under ML-KEM-768. The preflight checked:

- successful GOTO construction;
- GOTO binary validity;
- required target-function reachability;
- reachable call graph;
- reachable loops;
- undefined functions;
- property inventory;
- model-derived unwindsets;
- absence of proof execution during preflight.

The combined archive was:

```text
SUB_T6_B6_3_4_HARNESS_GOTO_PREFLIGHT.tar.gz
SHA-256:
5bbba8fb1fbe490b05410479fe9c023ccd1b6c67633d8efafbda0ff89e98978e
```

The uploaded archive was independently checked for:

```text
Outer hash:                  MATCH
Path safety:                 PASS
B6.3 manifest:               13 / 13
B6.4 manifest:               93 / 93
Harness count:               5
GOTO binary count:           5
```

---

# 15. B6.5 — positive execution

Four positive cases passed directly:

| Case | Successful properties |
|---|---:|
| Call-site precondition | 370 |
| Call-site exactness | 361 |
| Call-site frame | 373 |
| Subtract–reduce handoff | 365 |

The original `tomsg` model produced:

```text
Total:    885
SUCCESS:  884
FAILURE:    1
UNKNOWN:    0
```

The failed property was:

```text
mlk_scalar_compress_d1.overflow.3
```

with description:

```text
arithmetic overflow on unsigned + in
d0 + ((uint32_t)1u << 30)
```

The counterexample included a canonical input:

```text
u = 2913
d0 = 3758239368
```

The unsigned addition wrapped. This was not a T6.6 assertion failure. It was an automatically generated unsigned-overflow check on an operation for which the production header intentionally uses modular unsigned wrap.

## 15.1 Root cause

The production `compress.h` places the relevant inline helper under a local CBMC pragma disabling unsigned-overflow checks. The original harness compilation order included `compress.h` while `CBMC` was undefined. Therefore:

- contracts were erased, which was intended;
- the guarded production pragma was also omitted, which was not intended for this model;
- the CBMC command later enabled unsigned-overflow checking globally;
- the intended local wrap exception was lost.

This was a verification-adapter mismatch, not a defect in `mlk_poly_tomsg`.

## 15.2 Failed recovery attempts

### Recovery V1

The first recovery defined `CBMC` while including `compress.h`. This activated contract references, producing undefined functions such as:

```text
array_abs_bound
array_bound
cassert
```

It failed before proof execution.

### Recovery V2

The second recovery incorrectly treated those contract helpers as acceptable but unreachable. They were actually reachable. It also failed before an accepted proof.

### Recovery V3

The successful adapter kept `CBMC` undefined, preserved contract erasure, and directly scoped unsigned-overflow checking off while the inline compression helper was defined:

```c
#pragma CPROVER check push
#pragma CPROVER check disable "unsigned-overflow"
#include "compress.h"
#pragma CPROVER check pop
```

The recovery then required:

- no reachable or undefined contract helpers;
- only `mlk_scalar_compress_d1` reachable among scalar compression helpers;
- unchanged model-derived unwindset;
- absence of the original failed property;
- presence of all four T6.6 markers;
- no production-source edit;
- no frozen-harness edit.

The corrected result was:

```text
Total:    874
SUCCESS:  874
FAILURE:    0
UNKNOWN:    0
```

The reduced property count is expected because the local production-intended unsigned-overflow checks were no longer instrumented in that scope.

## 15.3 B6.5 final result

```text
T6.1: PASS
T6.2: PASS
T6.3: PASS
T6.4: PASS
T6.5: PASS
T6.6: PASS
T6.7: PASS
```

The B6.5 archive was:

```text
SUB_T6_B6_5_POSITIVE_RECOVERY.tar.gz
SHA-256:
1175a8191497ff7f4c64c749e4e3410ffd2b24eb2c76450efb3b8fbdf2173bfe
```

Independent inspection recorded:

```text
Archive path safety:       PASS
Manifest entries:          73 / 73
Positive exits:            5 / 5 zero
Corrected tomsg:           874 / 874 SUCCESS
```

---

# 16. Interpretation of the 2,343 positive results

The total is:

```text
370 + 361 + 373 + 365 + 874 = 2343
```

These are **not 2,343 independent mathematical theorems**. They include:

- named harness assertions;
- loop-unwinding assertions;
- memory-safety properties;
- pointer properties;
- arithmetic-overflow properties;
- conversion properties;
- other CBMC-generated safety checks.

The correct statement is:

> The five accepted positive CBMC models produced 2,343 successful property results, with zero failures and zero unknowns under their registered commands and assumptions.

It would be misleading to call them 2,343 separate research contributions.

---

# 17. B6.6 — reachability and non-vacuity

A proof can pass vacuously if important states are excluded by assumptions or made unreachable by the model. B6.6 therefore registered 12 cover goals.

The goals included:

1. lower subtraction boundary \(-26631\);
2. upper subtraction boundary \(29959\);
3. neutral subtraction;
4. positive `sb`;
5. negative `sb`;
6. negative post-subtraction value;
7. zero post-subtraction value;
8. positive canonical post-subtraction value;
9. post-subtraction value greater than or equal to \(q\);
10. coefficient index 0;
11. coefficient index 127;
12. coefficient index 255.

A cover-neutral companion disabled only the cover instructions and proved the remaining assertions with the same reachable-loop unwindset.

The result was:

```text
Companion exit:        0
Companion SUCCESS:     365
Companion FAILURE:       0
Companion UNKNOWN:       0

Coverage exit:          0
Covers satisfied:      12
Covers failed:          0
Cover total:           12
```

This does not prove every possible state is exercised as a test case. It proves that all registered witness classes are reachable in the symbolic model.

---

# 18. B6.7 — deliberately false expected-failure controls

Three false claims were constructed:

## EF-T6-1

False claim:

> Some allowed subtraction exceeds the signed-16 range.

Expected result: rejection.

## EF-T6-2

False claim:

> Actual reduction leaves at least one noncanonical coefficient.

Expected result: rejection.

## EF-T6-3

False claim:

> The reduced polynomial is incompatible with `mlk_poly_tomsg`.

Expected result: rejection.

The final result was:

```text
Expected-failure cases:        3
Target failures:               3
Unrelated failures:            0
Unknown properties:            0
Targeted counterexamples:      3
```

These controls demonstrate that the verification setup can produce failures and witnesses. They reduce, but do not eliminate, the risk of a blindly passing or vacuous setup.

The combined B6.6+B6.7 archive was:

```text
SUB_T6_B6_6_7_CONTROLS.tar.gz
SHA-256:
438e196ae70fef726be95677b567c9fb59ca5c685d60446afa54a5aaec9010c9
```

Independent inspection recorded:

```text
Archive members:        191
Unsafe paths/links:       0
B6.6 manifest:           54 / 54
B6.7 manifest:          107 / 107
```

---

# 19. B6.8 — mutation sensitivity

Four mandatory mutants were preregistered.

## M6.1 — subtraction changed to addition

Mutation:

```c
r->coeffs[i] = r->coeffs[i] + b->coeffs[i];
```

Required detector:

```text
T6.3 exactness
```

Result:

```text
Killed by T6.3
```

## M6.2 — `mlk_poly_reduce` removed

Mutation:

```text
The production reduction call was removed from a dedicated mutation
copy of the T6.6 harness.
```

Required detector:

```text
T6.6 canonical-input properties
```

Result:

```text
Killed by T6.6
```

The mutant produced exactly two registered T6.6 failures:

```text
main.assertion.2
SUB_T6_T6_6_PRE_LOWER:
tomsg input must be nonnegative

main.assertion.3
SUB_T6_T6_6_PRE_UPPER:
tomsg input must be below q
```

It also produced:

```text
mlk_scalar_compress_d1.overflow.1
arithmetic overflow on signed to unsigned type conversion in (uint32_t)u
```

This third failure was classified as **documented causal collateral**. Removing reduction deliberately allowed a negative noncanonical coefficient to reach `mlk_poly_tomsg`. The downstream conversion failure is causally consistent with that mutation.

It was:

- preserved;
- identified exactly;
- not hidden;
- not counted as an unrelated failure;
- not counted as an additional mutation kill.

## M6.3 — source operand modified

Mutation:

```text
A write to sb[i] was inserted after the real subtraction.
```

Required detector:

```text
T6.4 frame preservation
```

Result:

```text
Killed by T6.4
```

## M6.4 — coefficient 255 skipped

Mutation:

```text
The mlk_poly_sub loop bound was changed so index 255 was not processed.
```

Required detectors:

```text
T6.3 exactness
T6.5 subtract–reduce handoff
```

Result:

```text
Killed independently by T6.3 and T6.5
```

## 19.1 Final mutation result

```text
Mandatory mutants:                 4
Mutants killed:                    4
Mutation score:                  4/4
Detector executions:             5/5
Documented causal collateral:      1
Unrelated failures:                0
Unknown properties:                0
```

This is a targeted mutation score over four preregistered mutants. It is not a comprehensive mutation-analysis score over all possible code mutations.

---

# 20. B6.9 — final evidence freeze

The finalization stage:

- revalidated the source hashes;
- revalidated the B6.3–B6.8 manifests;
- checked the accepted stage verdicts;
- checked exact evidence totals;
- copied stage summaries and manifests;
- created a final source-binding list;
- created a campaign-wide content manifest;
- wrote a professor-facing verdict;
- checked archive path safety;
- checked final-archive binding to the B6.8 and B6.9 manifests;
- created the final archive and SHA-256 sidecar.

The final terminal verdict recorded:

```text
MANDATORY_MUTANT_COUNT=4
DETECTOR_EXECUTION_COUNT=5
DOCUMENTED_CAUSAL_COLLATERAL_TOTAL=1
UNRELATED_FAILURE_TOTAL=0
UNKNOWN_PROPERTY_TOTAL=0

M6_1_ADDITION=KILLED_BY_T6_3
M6_2_REMOVE_REDUCE=KILLED_BY_T6_6
M6_3_MODIFY_SB=KILLED_BY_T6_4
M6_4_SKIP_255=KILLED_BY_T6_3_AND_T6_5

MUTATION_SCORE=4/4
B6_8_STATUS=PASS

POSITIVE_CBMC_SUCCESS_TOTAL=2343
REACHABILITY_COMPANION_SUCCESS_TOTAL=365
REACHABILITY_COVER_SATISFIED_TOTAL=12
EXPECTED_FAILURE_TARGET_TOTAL=3

PRODUCTION_SOURCE_MODIFICATION=NO
FROZEN_POSITIVE_HARNESS_MODIFICATION=NO
ALL_STAGE_MANIFESTS_REVALIDATED=PASS
SUB_T6_CAMPAIGN_STATUS=PASS
```

---

# 21. Failure and recovery ledger

The failed attempts are part of the research evidence because they demonstrate the limitations of candidate AI-generated verification automation.

| Failure | Root cause | Resolution | Research lesson |
|---|---|---|---|
| Original combined runner stopped on CBMC exit 10 | Shell helper restored `set -e` before the caller captured an expected nonzero exit | Later runners used direct exit capture or guarded commands | Shell control flow can corrupt experiment orchestration |
| Original T6.6 model had one unsigned-overflow failure | Production wrap pragma was omitted by include/macro ordering | Known-good narrow wrap-scope adapter | Verification adapters are part of the model and must be audited |
| Recovery V1 had undefined contract helpers | Defining `CBMC` activated contracts while including `compress.h` | Keep contracts erased | A repair can accidentally change model semantics |
| Recovery V2 expected helpers to be unreachable | Contract helpers were reachable | Strict reachable/undefined rejection | Reachability must be inspected, not assumed |
| Final V2 used wrong `cbmc.h` path | `$SRC/cbmc.h` instead of `$SRC/src/cbmc.h` | Corrected both references | Source binding must use actual include layout |
| Mutation runner rejected valid M6.1 | Brittle regex/diff validation | Whole-file semantic mutation comparison | Text regex is not a semantic mutation oracle |
| A downloaded runner appeared stale | Local filename collision or stale file execution | Unique self-identifying runner and pre-run hash check | Script identity must be bound before execution |
| M6.2 recovery rejected the mutant | Auditor required a single target failure and labeled downstream conversion as unrelated | Exact two-target plus one documented-collateral classification | Mutation effects may produce multiple causally related failures |
| Several generated runners required correction | LLM generation error | Deterministic execution, preservation, and repair | LLM output is candidate material, not authority |

The final accepted V6 recovery runner had:

```text
RUN_ONLY_SUB_T6_MUTATION_RECOVERY_V6.py
SHA-256:
0290700898a5635f4b75f0c155b594f698c3ba7185592cf7276e7a880b86c6a4
```

It reused the completed M6.1 and M6.2 full-model evidence, independently reparsed the JSON, captured the missing M6.2 witness, and continued with M6.3 and M6.4.

---

# 22. Important evidence hashes

| Artefact | SHA-256 |
|---|---|
| SUB-00A clean-room packet | `e557c98ff5d3e3735d9f9f59c67a030e87ea0f4898b92d120856321a74ba7f45` |
| B6.3+B6.4 archive | `5bbba8fb1fbe490b05410479fe9c023ccd1b6c67633d8efafbda0ff89e98978e` |
| Original T6.6 diagnostic archive | `97880f92bc422ff6769438663ba4bc799a0a370528b9542dc82615605b1b46f8` |
| B6.5 positive-recovery archive | `1175a8191497ff7f4c64c749e4e3410ffd2b24eb2c76450efb3b8fbdf2173bfe` |
| B6.6+B6.7 controls archive | `438e196ae70fef726be95677b567c9fb59ca5c685d60446afa54a5aaec9010c9` |
| Final local evidence archive | `af430f410e63a51d75f7196764f18d22be5af7baf93c9235e5e191eb1c6e0522` |
| Final mutation-recovery runner V6 | `0290700898a5635f4b75f0c155b594f698c3ba7185592cf7276e7a880b86c6a4` |

---

# 23. What the completed result means

The strongest defensible claim is:

> For the frozen ML-KEM-768 portable-C configuration at commit `d9613cf60de3132d32475c102d8c2781d84feb34`, CBMC 6.9.0 established the registered object, arithmetic-representability, exact-subtraction, frame, subtract–reduce handoff, canonical-`tomsg`-input, const-input, and bounded-safety properties of the actual production slice `mlk_poly_sub; mlk_poly_reduce; mlk_poly_tomsg`, under the explicit modeled caller bounds and object assumptions. The positive suite was supplemented by reachability, deliberately false controls, and targeted mutation sensitivity.

A shorter professor-facing statement is:

> SUB-T6 is an independently authored, caller-oriented validation of a frozen `mlkem-native` decryption slice. It does not replace the upstream modular CBMC proofs and does not prove complete decryption. Its contribution is the explicit composition of caller assumptions, exact arithmetic oracles, frame and handoff properties, non-vacuity controls, negative controls, mutation sensitivity, and reproducible evidence binding.

---

# 24. Novelty and originality assessment

## 24.1 Search scope

A public prior-art search was conducted on 18 July 2026 using combinations of:

```text
mlkem-native CBMC poly_add
mlkem-native CBMC poly_sub
mlkem-native indcpa_dec proof
mlk_poly_sub mutation testing
mlk_poly_sub reachability harness
subtract-reduce mlkem-native CBMC
mlkem-native mutation testing CBMC harness
```

The search reviewed:

- the public `mlkem-native` repository and project documentation;
- public source mirrors showing the polynomial loop invariants;
- the project’s soundness-oriented material;
- the Real World Crypto 2026 presentation description;
- Amazon’s 2026 article on verifying `mlkem-native`;
- CBMC documentation and the CBMC overview paper;
- PQCA release material.

## 24.2 Confirmed prior art

The search confirms that upstream already has:

- CBMC verification for all C code’s memory/type safety;
- contracts and loop invariants in production C;
- exact functional contracts for simple polynomial operations;
- a public proof framework covering `poly_add`, `poly_sub`, and higher-level functions;
- a public higher-level `indcpa_dec` proof target;
- explicit discussion of soundness boundaries;
- HOL Light verification for optimized assembly.

Therefore, basic operation correctness and safety are not thesis novelty.

## 24.3 What appears distinct

No exact public match was located for a campaign combining all of the following around the `mlk_poly_sub` call site:

1. clean-room property development excluding existing proof artefacts;
2. an explicit call-site representability derivation;
3. exact wider-type coefficient oracles;
4. caller-frame assertions;
5. an actual `sub → reduce → tomsg` production slice;
6. a 12-goal symbolic reachability suite;
7. deliberately false overflow, canonicalization, and `tomsg` compatibility controls;
8. four preregistered mutants with five detector executions;
9. separate classification of causal mutation collateral;
10. source/GOTO/command/result/manifests bound into one evidence package;
11. failed-run preservation;
12. evaluation of an AI-assisted artefact-generation and repair process.

This supports the claim that the **complete case-study artefact and evaluation protocol is distinct**.

## 24.4 Novelty potency matrix

| Candidate contribution | Novelty strength | Defensible wording |
|---|---|---|
| Exact `mlk_poly_add` behavior | None | Existing upstream contract |
| Exact `mlk_poly_sub` behavior | None | Existing upstream contract and invariant |
| Memory/type safety of polynomial functions | None | Existing upstream CBMC framework |
| Canonical result after reduction | Low | Existing reduction contract; independently revalidated in a composed slice |
| Call-site representability bridge | Moderate | Explicit independently authored application of caller bounds |
| Caller-frame property suite | Moderate | Distinct explicit assertions, although conceptually standard |
| `sub → reduce → tomsg` property decomposition | Moderate | Distinct caller-oriented case-study composition |
| Reachability and deliberately false controls | Moderate to strong | Adds experimental credibility beyond a pass-only harness |
| Preregistered mutation sensitivity | Strongest technical evaluation element | Demonstrates detector sensitivity to selected faults |
| Evidence-integrity firewall and failed-attempt preservation | Strong methodology contribution | Reproducibility and trust contribution |
| AI-assisted verification failure taxonomy | Strong thesis contribution | Direct empirical evidence of where LLM assistance succeeds and fails |
| New cryptographic theorem | None | No new ML-KEM mathematics claimed |
| New CBMC algorithm | None | CBMC itself was not extended |
| New production implementation | None | Production source remained unchanged |

## 24.5 Recommended novelty claim

The recommended thesis claim is:

> The contribution is not a first proof of ML-KEM polynomial addition or subtraction. It is a controlled case study of AI-assisted generation and human/tool validation of caller-oriented CBMC artefacts for a frozen high-assurance implementation. The distinctive element is the integrated evidence protocol: clean-room provenance, explicit assumption-to-call-site reasoning, composed production-function properties, non-vacuity controls, deliberately false claims, mutation sensitivity, counterexample-led repair, and cryptographically bound reproducibility evidence.

## 24.6 Claims that must be avoided

Do not write:

- “I am the first person to prove `mlk_poly_sub`.”
- “`mlk_poly_sub` had never been verified before.”
- “`mlk_indcpa_dec` had no existing proof.”
- “I proved ML-KEM decryption correct.”
- “My harness is completely unrelated to `mlkem-native`.”
- “The LLM proved the theorem.”
- “The 2,343 results are 2,343 new theorems.”
- “A web search proves that no similar work exists anywhere.”

## 24.7 Honest limitation of the novelty search

A public search cannot prove nonexistence. Relevant unpublished work, private industrial verification, unindexed repositories, student theses, or differently named artefacts may exist.

The correct language is:

> I found no public artefact matching the complete campaign combination in the sources and searches reviewed as of 18 July 2026.

---

# 25. Why the result is valuable despite upstream overlap

Formal-verification research does not require every underlying mathematical fact to be new. A defensible MSc contribution can lie in:

- a new property decomposition;
- a new evaluation protocol;
- an independently reproduced result;
- a failure taxonomy;
- a tool-integration method;
- an evidence and trust framework;
- a careful empirical study of AI assistance.

The upstream proof makes this case study harder, not worthless. It provides a high-quality baseline against which candidate AI-generated artefacts can be evaluated.

The important research questions become:

- Did the workflow recover valid properties without copying upstream harnesses?
- Did it make invalid assumptions?
- Did it produce vacuous or insensitive proofs?
- Could deterministic controls detect bad artefacts?
- How much human correction was required?
- Did the resulting evidence add caller-oriented assurance or only repeat a function contract?
- Which failures came from the production code, and which came from the verification adapter?
- Can the process be reproduced and audited?

SUB-T6 provides concrete data for all of these questions.

---

# 26. AI-assistance findings

## 26.1 Useful capabilities

AI assistance was useful for:

- decomposing broad correctness questions into smaller properties;
- deriving arithmetic ranges;
- proposing explicit frame and relational checks;
- generating initial harness and runner structure;
- interpreting counterexamples;
- suggesting mutation operators;
- consolidating evidence;
- drafting the final claim boundary.

## 26.2 Observed failure modes

AI assistance produced:

- incorrect shell exit handling;
- wrong file paths;
- macro/include-scope mistakes;
- overstrict result classifiers;
- brittle regex mutation validators;
- premature confidence in unexecuted scripts;
- repeated repair attempts that changed model semantics;
- overly broad novelty language before the upstream overlap audit.

## 26.3 Trust conclusion

The empirical conclusion is:

> LLM assistance can accelerate formal-verification artefact development, but its outputs are unsuitable as authoritative evidence. Deterministic source binding, tool execution, reachability inspection, negative controls, mutations, and human review are necessary.

This conclusion is central to the thesis and is supported by the actual campaign history.

---

# 27. Threats to validity

## 27.1 Internal validity

Possible threats include:

- harness assertions not matching the intended informal property;
- accidental assumption strength;
- verification-adapter changes;
- result-parser defects;
- incorrect mutation classification;
- stale script execution;
- incomplete preservation of early exploratory runs.

Mitigations included explicit assumptions, raw result retention, source hashes, manifests, expected-failure controls, mutation testing, and preserved failed attempts.

## 27.2 Construct validity

The campaign measures selected property satisfaction, not general “correctness.”

The labels T6.1–T6.7 must not be interpreted as a complete functional specification of decryption.

## 27.3 External validity

The strongest result applies to:

```text
ML-KEM-768
one frozen commit
portable C backend
CBMC 6.9.0
registered bounds and object assumptions
```

It does not automatically generalize to:

- other commits;
- other parameter sets;
- optimized assembly backends;
- different compiler or CBMC versions;
- different calling contexts.

## 27.4 Conclusion validity

The mutation score is 4/4 over four targeted mutants. It does not establish comprehensive detector completeness.

The 12 cover goals establish reachability only for the registered classes.

The public novelty search supports a cautious originality assessment, not a universal first claim.

## 27.5 Reproducibility validity

Intermediate packages were independently inspected in the chat. The final archive hash is supported by terminal output but should still be independently re-uploaded and checked before archival submission.

---

# 28. Reproduction prerequisites

A reproducer requires:

```text
Ubuntu-like environment
CBMC 6.9.0
goto-cc 6.9.0
goto-instrument 6.9.0
Python 3
GNU core utilities
frozen source commit
frozen support headers
stage manifests
exact runner commands
sufficient memory and execution time
```

The production code must remain unmodified. Mutants must remain in dedicated mutation copies.

The final archive should be checked by:

1. recalculating its SHA-256;
2. checking tar path safety;
3. extracting into a fresh directory;
4. checking every stage manifest;
5. checking source hashes;
6. checking final verdict totals;
7. checking that production-source and frozen-harness modification flags remain `NO`.

---

# 29. Recommended thesis positioning

## 29.1 Main case-study contribution

> A controlled API-backed LLM workflow generated and refined candidate CBMC artefacts for selected `mlkem-native` C operations. The candidates were subjected to human review, deterministic integrity checks, CBMC verification, counterexample analysis, non-vacuity checks, expected-failure controls, mutation sensitivity, and reproducible evidence packaging.

## 29.2 Relationship to upstream verification

> The study does not compete with or replace `mlkem-native`’s existing verification. It uses that mature project as a high-assurance case-study target and baseline. The evaluation examines whether an AI-assisted workflow can independently construct useful caller-oriented artefacts and whether a deterministic validation protocol can detect weak, vacuous, copied, or incorrectly modeled candidates.

## 29.3 Main negative result

> Direct AI-generated runners were not reliable without deterministic checking. Multiple failures arose from shell semantics, include/macro scope, path binding, stale script identity, and failure classification.

## 29.4 Main positive result

> After controlled correction, the workflow produced a reproducible SUB-T6 campaign with 2,343 successful positive properties, 12 reachable witness classes, three correctly rejected false controls, and a 4/4 targeted mutation score, without modifying production source or the frozen positive harnesses.

---

# 30. Suggested professor-facing abstract of the result

The following paragraph can be used in a meeting or results chapter:

> The completed SUB-T6 case study independently evaluated the production `mlk_poly_sub → mlk_poly_reduce → mlk_poly_tomsg` slice of `mlkem-native` under the ML-KEM-768 caller bounds. Five frozen harnesses established object/separation conditions, subtraction representability, exact coefficient-wise subtraction, frame preservation, reduction handoff, canonical `tomsg` input, const-input behavior, and bounded safety. The positive models produced 2,343 successful CBMC property results with no failures or unknowns. Twelve symbolic cover goals confirmed boundary and index reachability, three deliberately false claims were rejected with isolated counterexamples, and four preregistered mutants were killed through five detector executions. The result does not constitute a complete proof of `mlk_indcpa_dec` or ML-KEM. Its contribution is the caller-oriented property decomposition and the evidence protocol used to evaluate AI-generated formal artefacts against a frozen, already high-assurance implementation.

---

# 31. Final answer to the central questions

## Did I prove `mlk_poly_add` comprehensively?

No.

The upstream project already specifies and proves exact addition under no-overflow and object assumptions. My earlier addition work was partial and exploratory. It must not be presented as a completed PA1–PA9 campaign.

## Did I prove `mlk_poly_sub`?

I proved the registered SUB-T6 properties of the actual production subtraction and its immediate reduction/`tomsg` handoff under explicit modeled assumptions.

I did not prove universal subtraction correctness for arbitrary inputs, complete decryption, or end-to-end ML-KEM.

## Is the new harness distinct from the upstream harness?

Yes, in authorship, property decomposition, caller-oriented purpose, controls, and evidence protocol.

No, in the sense of being unrelated to the same production code, mathematics, and upstream contracts.

## Is the work novel?

The basic arithmetic and safety facts are not novel.

The strongest defensible novelty is the complete independently authored and experimentally evaluated workflow:

```text
clean-room candidate development
+ caller-oriented composed properties
+ non-vacuity
+ false controls
+ mutation sensitivity
+ failure-led repair
+ evidence-integrity freezing
+ evaluation of AI assistance
```

No exact public match for this complete combination was found in the reviewed sources as of 18 July 2026. This supports a cautious distinct-contribution claim, not a universal first claim.

## Is SUB-T6 a strong thesis result?

Yes.

It is strong because it has:

- a precise scope;
- explicit assumptions;
- real production calls;
- complete bounded loops;
- positive proofs;
- reachability evidence;
- deliberately false controls;
- mutation sensitivity;
- preserved failures;
- source and artefact binding;
- honest nonclaims;
- a clear comparison with upstream prior work.

---

# 32. Final archival checklist

Before presenting the final evidence to the professor:

- [ ] Upload and independently verify `SUB_T6_FINAL_EVIDENCE_2026-07-18.tar.gz`.
- [ ] Confirm SHA-256 `af430f410e63a51d75f7196764f18d22be5af7baf93c9235e5e191eb1c6e0522`.
- [ ] Preserve the `.sha256` sidecar.
- [ ] Preserve the terminal log from V6.
- [ ] Preserve the B6.3+B6.4, B6.5, and B6.6+B6.7 uploaded archives.
- [ ] Preserve failed-run directories; do not delete them.
- [ ] Include exact CBMC version and frozen commit in the thesis.
- [ ] Include assumptions and nonclaims next to the theorem result.
- [ ] Do not use “first proof” wording.
- [ ] Distinguish upstream proof coverage from the thesis contribution.
- [ ] Report the M6.2 causal collateral transparently.
- [ ] State that the mutation score is targeted, not exhaustive.
- [ ] State that 2,343 is a property-result count, not a theorem count.
- [ ] Store the final evidence archive outside the working VM as a second copy.

---

# 33. Public prior-art sources consulted

The following public sources were consulted for the overlap and novelty assessment:

1. **NIST, FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard.**  
   https://csrc.nist.gov/pubs/fips/203/final

2. **pq-code-package, `mlkem-native` public repository.**  
   https://github.com/pq-code-package/mlkem-native

3. **`mlkem-native` formal-verification and soundness documentation.**  
   https://github.com/pq-code-package/mlkem-native/blob/main/SOUNDNESS.md

4. **Amazon Science, “Verifying and optimizing post-quantum cryptography at Amazon,” 7 April 2026.**  
   https://www.amazon.science/blog/verifying-and-optimizing-post-quantum-cryptography-at-amazon

5. **Real World Crypto 2026, “mlkem-native: a unified, fast and verified ML-KEM library.”**  
   https://citation.thinkst.com/talk/102969

6. **Post-Quantum Cryptography Alliance, first stable release of `mlkem-native`.**  
   https://pqca.org/blog/2025/first-stable-release-of-mlkem-native-v1-under-pq-code-package-project/

7. **Kroening, Schrammel and Tautschnig, “CBMC: The C Bounded Model Checker.”**  
   https://arxiv.org/abs/2302.02384

8. **CBMC applications page: `mlkem-native`.**  
   https://www.cprover.org/cbmc/applications/

---

# 34. Closing research statement

I did not modify the frozen production implementation to make the proofs pass. I developed separate verification artefacts, exercised the real production functions, and preserved the failures that exposed mistakes in the verification setup.

The completed work should be understood as a rigorous case study of **AI-assisted but tool-authoritative formal verification**. The strongest result is not that an LLM generated C code or that a simple polynomial function passed CBMC. The strongest result is that candidate AI-generated artefacts were subjected to a deterministic protocol capable of rejecting incorrect adapters, exposing vacuity, producing counterexamples, detecting targeted mutations, preserving failed attempts, and freezing a reproducible evidence trail.

That is the central contribution that should be defended in the thesis.
