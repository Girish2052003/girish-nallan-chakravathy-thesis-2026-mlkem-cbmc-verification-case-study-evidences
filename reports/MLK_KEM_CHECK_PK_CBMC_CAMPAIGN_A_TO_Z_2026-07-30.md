# ML-KEM `mlk_kem_check_pk` CBMC Verification Campaign

## A-to-Z Technical Record, Proof Boundary, Harness Originality, Results, Failure Analysis, and Novelty Assessment

**Author:** Girish Nallan Chakravathy  
**Case-study repository:** `pq-code-package/mlkem-native`  
**Frozen production commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Parameter set:** ML-KEM-768 (`MLKEM_K = 3`)  
**Primary verification tool:** CBMC 6.9.0  
**Campaign date:** 30 July 2026  
**Campaign status:** Closed  

---

## 1. Purpose of this record

This record documents the complete `mlk_kem_check_pk` verification campaign conducted against the frozen `mlkem-native` production source. It records the function selected, the reason for its selection, the proof strategy, the custom harnesses, the theorem families T1–T4, all important assumptions, the exact trust boundary of each result, the failures and repairs encountered during execution, the difference between the new harnesses and the repository-native CBMC harness, the final supported claims, the unsupported claims, and the basis on which originality and novelty may be discussed.

The purpose is not to present CBMC output as an unexplained collection of successful status markers. The purpose is to preserve a reviewable argument connecting:

1. the FIPS 203 encapsulation-key modulus-check requirement;
2. the exact production implementation in `mlkem-native`;
3. independently authored CBMC verification artefacts;
4. the assumptions and abstractions used in each theorem;
5. solver results and coverage evidence;
6. the human correction process that distinguished real implementation results from modelling, tooling, and orchestration failures; and
7. a conservative novelty position suitable for an MSc thesis and professor review.

This report uses the term **proved** only within an explicitly stated model and trust boundary. It does not treat formal verification as absolute, and it does not extend a property-specific CBMC result into a claim of whole-library or cryptographic security.

---

## 2. Executive verdict

### 2.1 What was proved

For the frozen ML-KEM-768 portable-C implementation, the campaign established the following.

1. **Arbitrary-context malformed-key rejection:** if any one of the 768 encoded polynomial-vector coefficients is a noncanonical 12-bit value in `3329..4095`, while every other public-key byte remains arbitrary, `mlk_kem_check_pk` cannot return success. It returns `MLK_ERR_FAIL`, except that `MLK_ERR_OUT_OF_MEMORY` remains permitted when allocation fails.
2. **Canonical-key acceptance:** if all 768 encoded polynomial-vector coefficients are canonical values in `0..3328`, while the 32-byte public-seed suffix remains arbitrary, `mlk_kem_check_pk` returns success, except that allocation failure may produce `MLK_ERR_OUT_OF_MEMORY`.
3. **Input-frame preservation:** calls to the checker preserve every byte of the public-key input.
4. **Red-zone preservation:** bytes immediately before and after the public-key object are preserved in the checked model.
5. **Prefix-only read footprint:** the concrete checker body can be called using an object of exactly `MLKEM_POLYVECBYTES` bytes without any detected read beyond that prefix in the contract-backed model. This establishes that the public-seed suffix is outside the verified read footprint.
6. **Caller-side validation guard:** subject to successful temporary allocation, when a proof stub makes the lower checker return `MLK_ERR_FAIL`, the concrete `mlk_kem_enc_derand` caller invokes validation once, propagates the failure, and preserves ciphertext, shared-secret, public-key, and coins buffers.
7. **Exact loop closure:** all loops relevant to the accepted models were eliminated with exact construction-time unwind bounds or proved loop-contract instrumentation, with the accepted final models containing no remaining target loops.
8. **Non-vacuity:** rejection, acceptance, non-OOM execution, and validation-reached paths were separately shown reachable using CBMC coverage goals.
9. **Source integrity:** the authoritative production source remained unchanged throughout the accepted campaign.

### 2.2 The strongest correct function-level claim

Taken together, T1-R2 and T1-R3 support the following non-OOM functional characterization for ML-KEM-768:

> For every 1184-byte candidate encapsulation key, `mlk_kem_check_pk` returns success exactly when all 768 coefficients encoded in the first `MLKEM_POLYVECBYTES = 1152` bytes decode to values in `0..3328`; if at least one encoded coefficient is in `3329..4095`, the checker returns `MLK_ERR_FAIL`. Allocation failure remains an explicitly permitted alternative result.

T3 adds that the remaining 32-byte public-seed suffix is outside the verified read footprint of the checker in the accepted contract-backed model. T2 adds non-modification and red-zone properties. T4 adds caller-side enforcement in `mlk_kem_enc_derand`.

Therefore, it is correct to say that **the production checker was proved correct for the selected modulus-check theorem family under ML-KEM-768 and the documented dependency model**. It is not correct to say that the whole function, whole repository, or whole ML-KEM algorithm was proved correct without qualification.

### 2.3 What was not proved

The campaign did not prove:

- whole-library functional correctness;
- IND-CCA security, cryptographic security, or decryption-failure bounds;
- constant-time behaviour of this C-level path;
- power, electromagnetic, fault-injection, speculative-execution, or other side-channel resistance;
- all build configurations, allocators, compilers, architectures, backends, or parameter sets;
- a two-call relational seed-noninterference theorem with all lower implementation bodies concrete;
- the internal semantics of `mlk_kem_check_pk` from the T4 stub-backed theorem;
- absence of all possible C undefined behaviour outside the selected properties and model;
- correctness after the frozen commit if the production source changes.

No production defect was established.

---

## 3. Why `mlk_kem_check_pk` was selected

The campaign deliberately moved away from another small polynomial arithmetic operation. The selected function is a security-boundary function used before encapsulation. It checks whether the polynomial-vector portion of an ML-KEM encapsulation key is canonically encoded modulo `q = 3329`.

The frozen header describes the function as implementing the FIPS 203 modulus check and says that the check ensures coefficients are in `[0, q-1]`. Its public contract requires a valid, non-aliased public-key object and restricts the result domain to success, `MLK_ERR_FAIL`, or `MLK_ERR_OUT_OF_MEMORY`. The source body allocates a polynomial vector and a re-encoding buffer, decodes the polynomial-vector prefix, reduces it, re-encodes it, and compares the re-encoding with the original prefix using `MLKEM_POLYVECBYTES` bytes.

This function was a useful case-study target because it combines:

- a directly stated FIPS 203 conformance requirement;
- byte-level encoding and polynomial semantics;
- memory allocation and cleanup;
- a security-sensitive accept/reject decision;
- a public-key input containing two conceptually different regions—the encoded vector and the public seed;
- a direct caller in the encapsulation path; and
- an existing repository-native CBMC proof that provided a meaningful baseline but not the custom theorem family developed here.

The target is also distinct from earlier arithmetic campaigns. Its central question is not merely whether an arithmetic operation computes a formula, but whether an external candidate key is accepted or rejected correctly and whether that decision is safely enforced by its caller.

---

## 4. Frozen source and implementation behaviour

### 4.1 Source binding

The authoritative source was frozen at:

```text
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

The campaign source directory was:

```text
/home/girish/THESIS-2026/mlkem-native_af4c5abd
```

A separate proof worktree was used for campaign artefacts. Repeated Git status and production-source diff gates confirmed that no production source modifications were introduced.

Important frozen source hashes recorded during the campaign included:

```text
kem.c  b3de1f7602b10c6033eee8b235138190ed09df917ec9326c2b38ce1083c541ce
kem.h  e239f5d705fca7729e7838e836aa2fab814ddc4ffbaf7eeb73a32242b15d960d
```

### 4.2 Public and internal names

The external source name is:

```c
mlk_kem_check_pk
```

After parameter-set namespacing and preprocessing in the ML-KEM-768 build, CBMC commonly exposes the internal symbol:

```c
mlk_check_pk
```

Likewise, the external caller `mlk_kem_enc_derand` appears internally as `mlk_enc_derand`. The campaign explicitly checked the actual target body in final GOTO models rather than assuming that the external spelling guaranteed body retention.

### 4.3 Production decision procedure

Conceptually, the production function performs:

```c
p = allocate polynomial vector
p_reencoded = allocate MLKEM_POLYVECBYTES bytes

if allocation fails:
    return MLK_ERR_OUT_OF_MEMORY

p = ByteDecode12(pk prefix)
p = coefficient-wise reduction modulo q
p_reencoded = ByteEncode12(p)

if pk prefix differs from p_reencoded:
    return MLK_ERR_FAIL
else:
    return 0
```

The actual source compares only `MLKEM_POLYVECBYTES` bytes. It does not pass the 32-byte public-seed suffix to the decode/reduce/re-encode chain or to the final comparison.

### 4.4 Mathematical meaning

For ML-KEM-768:

- `MLKEM_K = 3`;
- each polynomial contains `MLKEM_N = 256` coefficients;
- the encoded polynomial vector contains `3 × 256 = 768` coefficients;
- each coefficient is encoded in 12 bits;
- two coefficients occupy three bytes;
- the vector prefix therefore occupies `768 × 12 / 8 = 1152` bytes;
- the public key additionally contains a 32-byte public seed;
- the total public-key length is 1184 bytes.

A 12-bit field can represent `0..4095`. Canonical ML-KEM coefficients are `0..3328`. Values `3329..4095` are noncanonical.

---

## 5. The repository-native proof baseline

### 5.1 Native harness

At the frozen commit, `proofs/cbmc/kem_check_pk/kem_check_pk_harness.c` is an eleven-line boilerplate harness whose substantive body is:

```c
void harness(void)
{
  uint8_t *a;
  mlk_kem_check_pk(a, NULL);
}
```

The native Makefile checks the function contract for `mlk_check_pk`, replaces five lower calls with contracts, applies loop contracts, and enables dynamic frames. Its source contract states:

- the public-key object is valid and non-aliased;
- the return value is one of success, `MLK_ERR_FAIL`, or `MLK_ERR_OUT_OF_MEMORY`.

The repository documentation characterizes its CBMC harnesses as boilerplate and says that specifications are embedded in source contracts and loop annotations. The repository’s formal-verification statement focuses the C proofs on memory safety and type safety.

### 5.2 What the native baseline did not explicitly state

The frozen native harness and source contract did not explicitly assert the custom properties introduced by this campaign:

- every noncanonical coefficient is rejected;
- every canonical polynomial-vector encoding is accepted;
- the decision is correct under arbitrary surrounding bytes;
- input bytes are preserved;
- red-zone bytes are preserved;
- changing only the public-seed suffix cannot affect the decision;
- the public-seed suffix is outside the read footprint;
- the caller propagates validation failure before producing outputs;
- the accept and reject branches are reachable under the intended domains.

This distinction is central to the originality claim. The campaign did not merely rerun the repository-native proof. It authored additional, property-specific specifications and harnesses.

---

## 6. Why four theorem families were used

The four theorem families were not selected to inflate the number of proofs. They form a minimal layered argument.

| Layer | Theorem family | Question answered |
|---|---|---|
| Local functional semantics | T1 | Does the checker accept exactly canonical encodings and reject malformed encodings? |
| Side effects and relational behaviour | T2 | Does the checker preserve its inputs and surrounding memory, and can a public-seed relational claim be established with available contracts? |
| Dependency/read footprint | T3 | Does the checker read beyond the polynomial-vector prefix into the public-seed suffix? |
| Caller composition | T4 | Does encapsulation actually enforce validation failure before changing outputs? |

### 6.1 Why T1 alone was insufficient

T1 established the checker’s accept/reject semantics. It did not independently establish that the checker leaves the input and adjacent memory unchanged, nor did it prove that the encapsulation caller uses the result correctly.

### 6.2 Why the campaign did not stop after T2

T2 proved frame properties, but the two-call seed-noninterference assertion failed in a contract-backed model because lower contracts admitted independent abstract results. Stopping at T2 would have left an unresolved ambiguity: was the seed relevant to the production body, or was the counterexample an artefact of weak relational contracts?

### 6.3 Why T3 was required

T3 changed the proof question from output equality across two abstract executions to a single-execution footprint theorem. It supplied the checker with an object ending exactly at `MLKEM_POLYVECBYTES`. A suffix read would become an out-of-bounds violation. This was both more resource-efficient and better aligned with the actual dependency question.

### 6.4 Why the campaign did not stop after T3

T1–T3 concern the checker itself. They do not establish that the encapsulation path invokes the checker before hashing, encryption, or output generation, or that failure is propagated correctly. T4 therefore moved one level upward and verified the caller’s early-failure behaviour.

### 6.5 Why four are enough for this campaign

The four layers cover local semantics, frame safety, dependency footprint, and caller composition. Additional theorem families could examine all parameter sets, constant-time behaviour, custom allocator implementations, or concrete two-call self-composition, but those would enlarge the research scope rather than close a necessary gap in the selected campaign.

---

## 7. Common campaign methodology

### 7.1 Terminal-first evidence

The campaign used terminal output as the primary review channel. Files were requested only at critical gates where exact artefact inspection was necessary, including source/build binding and final harness redesign.

### 7.2 Frozen artefact binding

Each accepted batch bound as many of the following as applicable:

- source commit;
- authoritative source cleanliness;
- proof-worktree production-source diff;
- harness SHA-256;
- Makefile SHA-256;
- GOTO SHA-256;
- property manifest SHA-256;
- result XML SHA-256;
- coverage XML SHA-256;
- verdict SHA-256.

### 7.3 Target-body retention

GOTO structural inspection was used to confirm that the target body remained present. A build exit code alone was never treated as proof that the intended body had been analysed.

### 7.4 Property-level authority

The authoritative outcome for a theorem was the selected property result, not merely:

- successful compilation;
- successful GOTO construction;
- overall pipeline completion;
- global `CPROVER_STATUS` when unrelated cover properties contaminated the run;
- a timeout-free process exit without a matching result property.

### 7.5 Exact loop closure

The campaign diagnosed construction-time loop identities and supplied exact bounds. For the actual decode/reduce/re-encode path, the final bounds were:

```text
mlk_polyvec_frombytes.0:3
mlk_poly_frombytes_c.0:128
mlk_polyvec_reduce.0:3
mlk_poly_reduce_c.0:256
mlk_polyvec_tobytes.0:3
mlk_poly_tobytes_c.0:128
mlk_check_pk.0:1
mlk_check_pk.1:1
```

The final accepted models were structurally checked for remaining loops.

### 7.6 Non-vacuity

Coverage goals were used to demonstrate that relevant paths existed:

- malformed rejection path;
- canonical acceptance path;
- non-OOM checker completion;
- validation-reached caller path.

### 7.7 Source-integrity policy

The following were prohibited:

- production-source modification;
- replacement of the theorem target body;
- assumptions about the target result;
- `assume(false)` or equivalent vacuity;
- a fixed malformed coefficient index where an exhaustive symbolic index was required;
- a reduced malformed-value range;
- disabling unwind assertions while relying on bounded actual loops;
- silently treating an abstraction counterexample as a production defect.

T4 intentionally replaced a **lower** checker function with a proof stub while retaining the caller target body. This exception was explicit and defines the T4 trust boundary.

---

# Part I — T1: Functional modulus-check semantics

## 8. T1 purpose

T1 asked whether the production checker actually implements the FIPS 203 modulus-check decision, rather than merely returning one of the permitted result codes without memory errors.

The final T1 argument consists of two complementary theorems:

- **T1-R2:** malformed rejection under arbitrary context;
- **T1-R3:** canonical acceptance.

Together they establish the non-OOM accept/reject equivalence.

---

## 9. Original T1 development path

### 9.1 Initial source and native-proof admission

The campaign first established source binding, repository cleanliness, tool versions, and the existence of the repository-native proof. The native SAT replay succeeded for the repository contract baseline.

### 9.2 Actual-body harness

The first custom actual-body harness selected:

- one symbolic coefficient index from all 768 positions;
- one symbolic malformed value in `3329..4095`;
- an independently implemented 12-bit insertion operation;
- an independent 12-bit decode oracle;
- actual decode, reduction, and re-encoding implementation bodies;
- an allocation-aware rejection assertion.

The original harness initialized every other public-key byte to zero. This was sufficient for a strong exhaustive malformed-position/value theorem, but it left a context limitation.

### 9.3 Initial property set

The original custom properties were:

1. `INDEX_PAIR_BOUND`;
2. `INDEX_BYTE_BOUND`;
3. `ORACLE_PACKING`;
4. `REJECTION`.

The first three succeeded quickly. The rejection property initially timed out in a 300-second shard and later succeeded in the lean 600-second run.

### 9.4 Unwind diagnosis

The initial actual-body run had 545 properties, of which 544 succeeded. The only failure was the decode-loop unwinding assertion. Investigation showed that construction-time unwind instrumentation had defaulted to one rather than the required exact bound. The campaign then froze the exact bounds listed in Section 7.5.

### 9.5 Resource diagnosis

A monolithic run reached approximately 7.05 GB and was killed. Critical properties were therefore sharded. The final lean rejection proof completed in approximately 338 seconds with maximum resident memory around 7,021,132 KiB.

### 9.6 Original T1 result

The original theorem proved:

> Every symbolic coefficient position and every symbolic noncanonical 12-bit value is rejected, or allocation fails, when all other encoded coefficients and the seed suffix are zero.

This result was valid but not the final strongest campaign claim.

---

## 10. T1-R2 — Arbitrary-context malformed rejection

### 10.1 Why R2 was required

The original T1 fixed surrounding bytes to zero. R2 removed that limitation by making the entire public key symbolic before inserting one selected malformed coefficient. The unrelated nibble in the shared three-byte pair was preserved, as were all other vector bytes and the complete public-seed suffix.

### 10.2 R2 symbolic domain

The harness used:

```c
__CPROVER_havoc_object(&pk);
__CPROVER_havoc_object(&coefficient_index);
__CPROVER_havoc_object(&malformed_value);
```

with assumptions:

```text
0 <= coefficient_index < 768
3329 <= malformed_value < 4096
```

This represents all coefficient positions and all noncanonical 12-bit values across CBMC executions. It is not sampling or finite test-vector selection.

### 10.3 Independent packing oracle

The harness independently inserted the selected 12-bit value into the byte array and independently decoded it back. This prevented the theorem from simply assuming that its own malformed-key construction was correct.

### 10.4 R2 result assertion

The final assertion was:

```text
result == MLK_ERR_FAIL || result == MLK_ERR_OUT_OF_MEMORY
```

No assumption constrained `result`.

### 10.5 Actual and abstracted bodies

Retained actual bodies included:

- `mlk_check_pk`;
- polynomial-vector decode;
- polynomial decode;
- polynomial-vector reduction;
- polynomial reduction;
- polynomial-vector re-encoding;
- polynomial re-encoding.

Native contracts were used for:

- `mlk_ct_memcmp`;
- `mlk_zeroize`.

The comparison contract was accepted because it specified the equality relation required by the theorem. The zeroization contract affected cleanup framing rather than modulus-check semantics.

### 10.6 R2 results

```text
Selected property shards:       12
Successful:                     12
Failures:                        0
Inconclusive:                    0
Rejection coverage:              SATISFIED
Final classification:            SUCCESSFUL
```

The core arbitrary-context rejection assertion completed successfully in approximately nine seconds with maximum resident memory around 831,068 KiB.

### 10.7 R2 hashes

```text
Harness SHA-256:
43dd0282fa57f976920185908806ba3a6c9494f0b601e87c2a504c221ab78d8c

Makefile SHA-256:
c75ce8f02d2f40f8a08401e96f78d585fd9dec4522facd4db552e8b18e1739ab

GOTO SHA-256:
5cf49e4012d41919e95a8a512c38b893b8674beb0ac4b7459cbbe9e7d83730a3
```

### 10.8 R2 supported theorem

> For ML-KEM-768, for every coefficient position, every noncanonical 12-bit value in `3329..4095`, every assignment of all surrounding polynomial-vector bytes, and every assignment of the public-seed suffix, the concrete checker cannot return success. It returns `MLK_ERR_FAIL`, unless allocation fails and returns `MLK_ERR_OUT_OF_MEMORY`, under the documented lower-contract boundary.

---

## 11. T1-R3 — Canonical acceptance

### 11.1 Why R3 was required

Rejection alone does not establish that valid inputs are accepted. A degenerate function that rejects every key would satisfy a malformed-rejection theorem. R3 therefore proved the complementary direction.

### 11.2 R3 symbolic domain

The complete 1184-byte public key was symbolic. The harness generated independent `ByteDecode12` constraints for all 768 coefficients, requiring every decoded value to be less than `MLKEM_Q`.

The constraints were emitted as straight-line statements rather than a harness loop. This avoided introducing a new harness-loop unwind assumption.

The 32-byte public-seed suffix remained unrestricted.

### 11.3 R3 result assertion

The final assertion was:

```text
result == 0 || result == MLK_ERR_OUT_OF_MEMORY
```

The dedicated coverage goal required `result == 0` to be reachable.

### 11.4 R3 results

```text
Selected property shards:       9
Successful:                     9
Failures:                        0
Inconclusive:                    0
Acceptance coverage:             SATISFIED
Final classification:            SUCCESSFUL
```

The canonical-acceptance property completed in approximately 77 seconds with maximum resident memory around 792,496 KiB.

### 11.5 R3 hashes

```text
Harness SHA-256:
61362cd4e63f06b30952d94def19201dc5198caf224b0aa09a3441502297271e

Makefile SHA-256:
af966afec366566d88c2096b48095d3d5a7aeb2a7c9a9241b47a320794ea37d9

GOTO SHA-256:
63d071dea1ee122637b83d06dcb743fb2a8c8e33c6adaa48d7ed85b8d96e7efa
```

### 11.6 R3 supported theorem

> For ML-KEM-768, for every public key whose 768 encoded polynomial-vector coefficients are in `0..3328`, and for every public-seed suffix, the concrete checker returns success unless allocation fails, under the documented lower-contract boundary.

---

## 12. T1 combined conclusion

T1-R2 and T1-R3 are complementary universal results. On non-OOM executions they establish:

```text
return == 0
    iff
all 768 encoded polynomial-vector coefficients are canonical
```

and:

```text
return == MLK_ERR_FAIL
    if
at least one encoded coefficient is noncanonical
```

The T1 final closure recorded:

```text
T1R2_OK=1
T1R3_OK=1
PKCHECK_T1_FINAL_CLOSURE_CLASSIFICATION=
T1_ACTUAL_BODY_ARBITRARY_CONTEXT_REJECTION_AND_CANONICAL_ACCEPTANCE_SUCCESSFUL
```

Final T1 closure verdict SHA-256:

```text
0689e8cfd2b18d746621965ccc9e9f970922778dc211b0f0967a567543f80592
```

This is the campaign’s strongest proof that `mlk_kem_check_pk` is functionally correct for its modulus-check decision under the selected parameter set and trust boundary.

---

# Part II — T2: Frame and relational properties

## 13. T2 purpose

T2 extended the investigation beyond return-value correctness. It asked whether:

1. the first input object remained unchanged;
2. the second input object remained unchanged;
3. bytes around the object remained unchanged; and
4. changing only the public-seed suffix could affect the non-OOM decision.

The first three are frame and memory-isolation properties. The fourth is a relational noninterference property.

---

## 14. T2 harness design

### 14.1 Frame structure

The harness created:

```text
left redzone | encoded vector + public seed | right redzone
```

with 16-byte redzones.

Static assertions froze the expected layout and public-key size.

### 14.2 Symbolic witnesses

Instead of iterating over all bytes in the harness, nondeterministic indices represented arbitrary positions:

- one payload-byte index;
- one red-zone index;
- one seed-difference index.

The range assumptions made each assertion universal over the corresponding array positions across CBMC executions.

### 14.3 Two executions

The two calls shared the same encoded polynomial-vector prefix. The public-seed block was changed between calls. Each call recorded selected input and red-zone bytes before and after execution.

### 14.4 T2 properties

The final four properties were:

1. `PKCHECK-T2.FIRST_INPUT_FRAME`;
2. `PKCHECK-T2.SECOND_INPUT_FRAME`;
3. `PKCHECK-T2.REDZONE_PRESERVATION`;
4. `PKCHECK-T2.SEED_NONINTERFERENCE`.

The seed assertion was allocation-aware:

```text
first is OOM OR second is OOM OR first_result == second_result
```

---

## 15. T2 proof architecture and resource problem

The initial design retained the concrete target body but replaced five lower calls with native contracts:

- `mlk_polyvec_frombytes`;
- `mlk_polyvec_reduce`;
- `mlk_polyvec_tobytes`;
- `mlk_ct_memcmp`;
- `mlk_zeroize`.

The first architecture enabled dynamic frames. DFCC added ghost write-set machinery and dramatically increased memory consumption. The two-call model repeatedly approached the virtual-machine memory limit and was killed.

The campaign then removed dynamic frames while retaining non-DFCC function-contract replacement and exact target cleanup-loop bounds. The final GOTO size dropped substantially, and property memory fell from gigabytes to tens or hundreds of megabytes.

---

## 16. T2 execution and correction history

This history is retained because it is useful evidence for the thesis evaluation of failure modes and human correction.

### 16.1 T2-00A checker defect

The first admission script used `grep` on a pattern beginning with `--` without the required separator. The script stopped even though the underlying artefact had not failed.

**Classification:** orchestration/checker defect, not CBMC or production failure.

### 16.2 T2-00B Litani initialization defect

A continuation deleted the Litani cache and invoked an internal target that assumed an initialized workflow.

**Classification:** orchestration defect; no theorem was tested.

### 16.3 T2-00C unsupported DFCC statement and OOM

The harness used `__CPROVER_array_equal`. DFCC emitted a warning that this statement type was unsupported and analysis might be unsound. All four property shards were also killed by memory exhaustion.

**Classification:** model invalid for acceptance and resource-inconclusive; no production defect.

### 16.4 T2-00D comment-sensitive policy checker

The actual unsupported call had been removed, but a text-count checker matched the function name inside a comment and stopped the run.

**Classification:** checker defect.

### 16.5 T2-00E partial proof and OOM

The repaired model produced one valid first-input-frame success, while the remaining properties were killed near the memory limit.

**Classification:** one accepted property, three resource-inconclusive properties.

### 16.6 T2-00F non-DFCC conversion

Dynamic frames were removed. A structural preflight correctly discovered two remaining target cleanup loops.

A predicted loop-free state had been wrong, but the preflight prevented solver execution on the incomplete model.

### 16.7 T2-00G dry-run checker defect

The first closure script incorrectly required `--unwinding-assertions` to appear in the GOTO-construction command. The repository pipeline instead only emits a negative flag when assertions are disabled.

**Classification:** checker defect. The exact unwind patch itself was correct.

### 16.8 Final non-DFCC model

The final model used:

```text
mlk_check_pk.0:1
mlk_check_pk.1:1
```

and contained zero remaining loops.

Final GOTO SHA-256:

```text
6782995e8d61f04e292acc70eae2968b802185f0cd6c2668f85b35770b762b41
```

---

## 17. T2 final results

```text
FIRST_INPUT_FRAME       SUCCESS
SECOND_INPUT_FRAME      SUCCESS
REDZONE_PRESERVATION    SUCCESS
SEED_NONINTERFERENCE    FAILURE in contract-backed model
```

The three successes were fast and low-memory after removal of dynamic frames.

The failing relational trace contained:

```text
first_result  = -1
second_result = 0
```

while the encoded polynomial-vector prefix was shared.

### 17.1 Why this was not classified as a production defect

The concrete target body was retained, but the lower decode/reduce/re-encode/comparison functions were replaced with contracts. Those contracts were adequate for single-call safety and frame reasoning but did not impose a relational guarantee requiring two separate abstract calls to make identical semantic choices for identical prefixes.

The counterexample therefore demonstrated that the **contract abstraction was too weak for the two-call equality theorem**. It did not demonstrate that the production implementation reads the seed or returns different decisions for the same vector prefix.

### 17.2 Final T2 classification

```text
T2_FRAME_VERIFICATION_SUCCESSFUL
T2_SEED_RELATIONAL_ATTEMPT_ABSTRACTION_LIMITED
PRODUCTION_DEFECT_FOUND=NO
```

### 17.3 T2 hashes

```text
Harness SHA-256:
1db5496f9992730fc965d34de669f0f771e1b8d82a694e0cd54c869bd1bfef62

Makefile SHA-256:
738492c2948610afbd43e6272f0406801089fd5207df521aa48f366e8af09d46

GOTO SHA-256:
6782995e8d61f04e292acc70eae2968b802185f0cd6c2668f85b35770b762b41
```

---

# Part III — T3: Prefix-only read footprint

## 18. T3 purpose

T3 was designed to answer the actual dependency question left open by T2 without requiring a two-call relational abstraction.

The theorem supplied an input object containing exactly:

```text
MLKEM_POLYVECBYTES
```

rather than the full public-key length. If the target or any accepted lower abstraction required access to the 32-byte public-seed suffix, CBMC pointer and bounds checks would fail.

---

## 19. T3 harness and trust boundary

The T3 harness contained:

```c
uint8_t public_key_prefix[MLKEM_POLYVECBYTES];
int result = mlk_kem_check_pk(public_key_prefix, NULL);
```

and asserted the result domain:

```text
0, MLK_ERR_FAIL, or MLK_ERR_OUT_OF_MEMORY
```

It also included a coverage goal requiring a non-OOM result.

The concrete `mlk_check_pk` target body remained present. The same five lower functions used in T2 were contract-backed. This is therefore a **contract-backed target-body footprint theorem**, not a fully concrete lower-body theorem.

---

## 20. T3 execution corrections

### 20.1 Harness-entry Makefile error

The first generated Makefile used `HARNESS = harness` rather than the repository-required `HARNESS_ENTRY = harness`. The link command therefore had a blank `--function` argument.

**Classification:** generated Makefile defect; no theorem was tested.

### 20.2 Corrected build

After the single-variable correction, the build succeeded and produced a loop-free GOTO model.

### 20.3 Cover contamination

The ordinary safety run reported 111 properties, with 110 successes and one failure named `harness.no-body.__CPROVER_cover`. This was not a memory-safety or theorem failure. It was the explicit cover goal being treated as an ordinary property in that run mode.

The dedicated coverage run using `--cover cover` reported the goal satisfied.

The final interpretation therefore excluded the cover artefact from the 110 genuine safety properties.

---

## 21. T3 results

```text
Final loop count:                    0
Total genuine non-cover properties: 110
Successful genuine properties:      110
Out-of-prefix access detected:       NO
Non-OOM path coverage:               SATISFIED
New OOM event:                       NO
Production source clean:             YES
```

The property manifest included pointer arithmetic, pointer dereference, array bounds, lower-contract preconditions, target unwind assertions, and the custom result-domain assertion.

### 21.1 T3 hashes

```text
Harness SHA-256:
a1d9a60e50ced4a4be207a93dd5de650079242058229594bf2f04a1cc6719ed2

Makefile SHA-256:
c69deeefe8c207a3ffd197b4b4ff74cf82068f152c20b4cdc1c25a3243725cc4

GOTO SHA-256:
5e668297f43ea3b352d5e6d3a408d388a92960e2570917f5816453f1de87b3e0

Safety XML SHA-256:
cab7452254394bd0dea20cfab56b899563deb4890d0387400de89bdd870659da

Coverage XML SHA-256:
ba0f3d3c2699534e28e0c9b6dad737927c23ae5b2b9524e6e7d6eb23669d78e8
```

### 21.2 Final T3 classification

```text
T3_CONTRACT_BACKED_PREFIX_ACCESS_VERIFICATION_SUCCESSFUL
```

### 21.3 Exact supported theorem

> For ML-KEM-768, the concrete `mlk_check_pk` target body can complete using an input object ending exactly at the polynomial-vector prefix without any detected access beyond that object, under the five native lower-function contracts. A non-OOM execution is reachable.

This resolves the production-dependency question that motivated the failed T2 relational property: the public-seed suffix lies outside the verified checker read footprint in this model.

---

# Part IV — T4: Encapsulation caller guard

## 22. T4 purpose

T1–T3 proved properties of the checker. T4 asked whether the caller, `mlk_kem_enc_derand`, enforces validation before proceeding to encapsulation output generation.

The frozen caller allocates temporary buffers, calls the checker, branches immediately to cleanup on a nonzero result, and only afterwards performs copies, hashing, IND-CPA encryption, and shared-secret output.

---

## 23. T4 compositional design

### 23.1 Concrete target

The internal `mlk_enc_derand` body remained concrete.

### 23.2 Deliberate lower stub

The lower internal `mlk_check_pk` body was removed and replaced with a deterministic proof stub that:

- counted calls;
- returned `MLK_ERR_FAIL`.

This was deliberate. T4 was not intended to re-prove checker semantics. T1 already supplied that evidence. T4 isolated the caller’s response to a validation failure.

### 23.3 Allocation-aware assertions

Because allocation occurs before validation, the checker may not be reached on an OOM path. The final assertions therefore proved:

- the checker executes at most once;
- either allocation fails before validation and the result is OOM, or validation executes once and its `MLK_ERR_FAIL` result is propagated;
- selected bytes of ciphertext, shared secret, public key, and coins remain unchanged;
- the validation-reached branch is satisfiable.

### 23.4 T4 properties

1. `CHECK_AT_MOST_ONCE`;
2. `GUARD_RESULT_SPLIT`;
3. `CIPHERTEXT_FRAME`;
4. `SHARED_SECRET_FRAME`;
5. `PUBLIC_KEY_FRAME`;
6. `COINS_FRAME`;
7. first target unwind assertion;
8. second target unwind assertion.

---

## 24. T4 execution corrections

### 24.1 Initial stub-signature failure

The first generated stub referenced a `context` parameter that did not exist in the frozen preprocessed configuration and used the wrong symbol layer.

**Classification:** generated harness defect; the proof binary did not build.

### 24.2 Corrected internal stub

The corrected harness used the one-argument internal symbol `mlk_check_pk` and removed exactly that lower body. The target `mlk_enc_derand` body remained present.

### 24.3 Unwind-classifier contamination

All six custom properties succeeded. The two selected unwind results also showed `status="SUCCESS"`, but the script classified them as failures because it relied on global `CPROVER_STATUS=FAILURE`, contaminated by the explicit cover statement.

The two unwind properties were rerun cleanly with standard checks disabled. Each returned:

```text
EXIT_CODE=0
status="SUCCESS"
CPROVER_STATUS=SUCCESS
```

**Classification:** result-parser/classifier defect, not property failure.

---

## 25. T4 results

```text
Six custom properties:            SUCCESS
Two target unwind properties:     SUCCESS
Validation-reached coverage:       SATISFIED
Actual caller body present:        YES
Checker proof stub present:        YES
Final model loop-free:             YES
Production source unchanged:       YES
```

### 25.1 T4 hashes

```text
Harness SHA-256:
d46d6c1a2934fe1f0e1ce8981b4839dec6128ee8615bf8a0a4f8bf2ebbdc96a0

Makefile SHA-256:
92d06786013810b6f836b5dd6b5d344de932352841c69b60bb93e028f5df765d

GOTO SHA-256:
3ea66fe0c6fbd6352eec1c922a5f9ab74338cfba6630681934dd27452d75a65e

T4 verdict SHA-256:
86d2678b93ca3d59b666a6306bb584f3faa613c0d895a97367092b57c5c86e0e
```

### 25.2 Final T4 classification

```text
T4_STUB_BACKED_EARLY_FAILURE_PROPAGATION_AND_FRAME_VERIFICATION_SUCCESSFUL
```

### 25.3 Exact supported theorem

> Under ML-KEM-768 and successful temporary allocation, if the lower checker returns `MLK_ERR_FAIL`, the concrete `mlk_enc_derand` caller invokes validation once, returns the failure, and preserves the ciphertext, shared-secret, public-key, and coins buffers. Allocation failure before validation remains a permitted separate branch.

T4 does not prove the checker’s internal semantics; T1 supplies that evidence.

---

# Part V — Combined interpretation

## 26. Theorem matrix

| ID | Target body | Lower dependency treatment | Main property | Result |
|---|---|---|---|---|
| T1-R2 | Concrete `mlk_check_pk` | Concrete polynomial pipeline; contracts for compare/zeroize | Any malformed coefficient in arbitrary context is rejected or OOM | Proved |
| T1-R3 | Concrete `mlk_check_pk` | Concrete polynomial pipeline; contracts for compare/zeroize | Every canonical encoded vector is accepted or OOM | Proved |
| T2.1 | Concrete `mlk_check_pk` | Five native lower contracts | First input preserved | Proved |
| T2.2 | Concrete `mlk_check_pk` | Five native lower contracts | Second input preserved | Proved |
| T2.3 | Concrete `mlk_check_pk` | Five native lower contracts | Redzones preserved | Proved |
| T2.4 | Concrete `mlk_check_pk` | Five native lower contracts | Two-call seed noninterference | Abstraction-limited; not a production failure |
| T3 | Concrete `mlk_check_pk` | Five native lower contracts | No read beyond vector prefix | Proved |
| T4 | Concrete `mlk_enc_derand` | Deterministic failure stub for lower checker; zeroize contract | Failure propagation and four-buffer frame | Proved |

---

## 27. How T1–T4 fit together logically

### 27.1 T1 establishes the decision relation

T1 says what the checker returns for canonical and noncanonical polynomial-vector encodings.

### 27.2 T2 establishes purity and exposes abstraction weakness

T2 says that the checker does not modify the input or adjacent memory. The failed relational property is retained as evidence that single-call contracts are not automatically sufficient for relational self-composition.

### 27.3 T3 establishes the relevant dependency boundary

T3 shows that the seed suffix is outside the verified read footprint, avoiding the weak two-call abstraction.

### 27.4 T4 establishes caller enforcement

T4 shows that the encapsulation caller acts on checker failure before modifying public outputs or inputs.

### 27.5 Combined security-assurance story

The combined evidence is stronger than any one theorem:

```text
Malformed vector prefix
    -> checker rejects (T1)
    -> checker preserves input/surroundings (T2)
    -> checker does not require public-seed suffix (T3)
    -> encapsulation caller propagates failure before output generation (T4)
```

For canonical vector prefixes:

```text
Canonical vector prefix
    -> checker accepts unless allocation fails (T1-R3)
```

---

## 28. Did we truly prove `mlk_kem_check_pk`?

### 28.1 Correct answer

Yes, for a precisely bounded and documented theorem:

> The ML-KEM-768 portable-C `mlk_kem_check_pk` implementation at commit `af4c5abd…` was proved to implement the canonical-encoding modulus-check decision for all 768 encoded coefficients, under the stated allocation model, exact loop bounds, and dependency contracts. It was additionally proved to preserve its input and adjacent redzones and, in a contract-backed footprint model, not to require bytes beyond the polynomial-vector prefix.

### 28.2 Why this is a real proof rather than testing

The key inputs were symbolic rather than enumerated concrete test vectors:

- malformed coefficient index symbolic over all 768 positions;
- malformed value symbolic over all 767 noncanonical 12-bit values;
- surrounding bytes symbolic;
- seed suffix symbolic;
- canonical key bytes symbolic subject to 768 independently generated canonicality constraints;
- frame indices symbolic over every byte position.

CBMC success means it found no assignment in the model violating the assertion; equivalently, the negation was unsatisfiable under the assumptions. Dedicated coverage runs established satisfiable intended paths.

### 28.3 Why the answer still requires qualification

A proof is only as broad as its model. The result is parameter-set-specific, commit-specific, configuration-specific, property-specific, and partially contract-backed. It does not imply every property of the function or library.

---

## 29. Assumptions and trust boundaries

### 29.1 Global assumptions

- frozen commit `af4c5abd…` accurately identifies the production source;
- ML-KEM-768 compile-time configuration;
- CBMC 6.9.0 and its C semantics are trusted within the toolchain boundary;
- the GOTO construction accurately represents the selected preprocessed C build;
- the default SAT backend correctly decides the generated formulas;
- SHA-256 is used as an integrity identifier, not as proof of semantic correctness;
- custom allocation may fail and return `NULL`;
- arrays supplied by harnesses satisfy the stated object-size and non-alias conditions;
- exact unwind bounds correspond to the concrete loops in the final GOTO model.

### 29.2 T1-specific assumptions

- the independent 12-bit pack/decode oracle is correct;
- `mlk_ct_memcmp`’s native contract faithfully captures equality of compared bytes;
- `mlk_zeroize`’s contract is sufficient for cleanup framing;
- the actual decode/reduce/re-encode bodies retained in the GOTO model match the frozen production source;
- R3’s 768 straight-line assumptions exactly characterize canonical 12-bit coefficients.

### 29.3 T2-specific assumptions

- five lower native contracts are sound for single-call frame reasoning;
- symbolic byte indices plus range assumptions represent universal positions;
- the failed seed equality assertion is not accepted because the contracts lack a relational coupling guarantee.

### 29.4 T3-specific assumptions

- lower contracts requiring the prefix-sized input accurately represent their permitted read footprint;
- a successful set of pointer/bounds/precondition properties on the exact-prefix object establishes no modelled suffix access;
- the explicit cover goal is evaluated separately from ordinary safety properties.

### 29.5 T4-specific assumptions

- the deterministic lower stub intentionally represents the event “checker returns `MLK_ERR_FAIL`”;
- the stub is not evidence for checker semantics;
- the actual caller body and pre-validation allocation behaviour are retained;
- the zeroization contract is sufficient for cleanup modelling;
- validation-reached coverage prevents the theorem from holding solely because allocation always fails.

---

## 30. How the new harnesses are truly distinct from mlkem-native

### 30.1 Distinct specification content

The native harness only calls the function through a symbolic pointer and relies on source contracts. The campaign harnesses add new property specifications:

- independent byte-level malformed-key construction;
- independent decode oracle;
- arbitrary-context quantification;
- canonical-domain constraints for every coefficient;
- exact accept/reject assertions;
- symbolic frame witnesses;
- red-zone objects;
- two-call relational structure;
- exact-prefix object sizing;
- caller call-count observation;
- output/input frame assertions;
- coverage goals.

### 30.2 Distinct proof goals

The native proof primarily establishes the source contract and absence of selected undefined behaviour. The campaign proves functional and compositional properties not explicitly present in that contract.

### 30.3 Distinct artefacts

The campaign created new proof directories, harnesses, Makefiles, property descriptions, manifests, result shards, coverage runs, verdict records, and hash-bound evidence. These were not copied from the repository-native `kem_check_pk` harness.

### 30.4 Production source remained unchanged

The distinction was achieved in the verification layer. The production C source was not edited to make the theorem pass.

### 30.5 T4’s explicit exception

T4 intentionally substitutes a lower proof stub, but the theorem target is the caller. This is a standard compositional proof technique when its trust boundary is stated. It must not be represented as an actual-body proof of the lower checker.

---

# Part VI — Failure-mode analysis

## 31. Why failed attempts are part of the contribution

The campaign did not treat every failed command as evidence against the implementation. It classified failures into:

1. production-property counterexamples;
2. abstraction counterexamples;
3. resource exhaustion;
4. unsupported tool constructs;
5. loop-bound/configuration errors;
6. orchestration/checker bugs;
7. result-parser contamination;
8. build-variable/signature defects.

This classification prevented false defect claims and is directly relevant to AI-assisted formal-artefact generation research.

---

## 32. Failure table

| Event | Immediate symptom | Actual cause | Final classification |
|---|---|---|---|
| T1 decode unwind failure | one unwind property failed | construction-time bound defaulted to one | proof configuration defect |
| T1 monolithic kill | exit 137 / high RSS | VM memory exhaustion | resource limit |
| T2 grep stop | policy script exited | pattern parsed as option | checker defect |
| T2 Litani stop | cache pointer missing | continuation deleted workflow cache | orchestration defect |
| T2 `array_equal` warning | DFCC unsoundness warning | unsupported statement in DFCC | model invalid for acceptance |
| T2 repeated exit 137 | no XML results | dynamic-frame model exceeded memory | resource limit |
| T2 comment count | unsupported-call count one | function name occurred only in comment | checker defect |
| T2 seed failure | `-1` vs `0` | independent contract nondeterminism | abstraction counterexample |
| T3 initial link failure | blank `--function` | wrong Makefile variable | generated artefact defect |
| T3 safety “failure” | only cover pseudo-property failed | cover goal evaluated in wrong mode | run/classification contamination |
| T4 initial compile failure | missing `context` symbol | wrong stub signature/symbol layer | generated harness defect |
| T4 unwind “failures” | selected property success, global failure | cover contaminated global status | classifier defect |

No event in this table established a production-code defect.

---

## 33. Resource engineering lessons

The campaign demonstrated that proof architecture can dominate memory use.

- Dynamic frames made the T2 two-call model consume roughly 7.2–7.4 GB and fail.
- Removing DFCC while retaining supported non-DFCC contract replacement reduced final T2 property runs to roughly 73–115 MB and subsecond execution.
- T1’s original fully expanded rejection proof required approximately 6.7 GB and several minutes, but the final carefully structured R2/R3 models completed within about 0.8 GB.
- T3’s complete all-property safety run still approached 7.0 GB, showing that a single-call model may remain expensive when many pointer and contract properties are solved monolithically.
- T4’s isolated caller theorem completed with only tens of megabytes.

The lesson is not to weaken properties, but to choose a model architecture aligned with the theorem and to shard properties where appropriate.

---

# Part VII — Novelty and originality assessment

## 34. What is not novel

The following should not be presented as novel:

- the FIPS 203 modulus-check requirement;
- the concept of canonical 12-bit coefficient encoding;
- the `mlk_kem_check_pk` production function;
- the existence of CBMC proofs in `mlkem-native`;
- formal verification of ML-KEM or Kyber in general;
- the general use of frame properties, redzones, self-composition, contracts, or stubs;
- the general observation that weak contracts can be insufficient for relational proofs.

ML-KEM has already been formally analysed at specification and implementation levels using other proof systems, including EasyCrypt and Jasmin. Other implementations also validate encapsulation-key canonicality.

---

## 35. Public baseline against which originality was checked

### 35.1 Frozen mlkem-native repository

The frozen repository already contained:

- a `kem_check_pk` CBMC proof directory;
- an eleven-line boilerplate native harness;
- a source contract requiring non-aliasing and restricting the return domain;
- lower function contracts and loop annotations;
- a general repository claim of C memory and type safety.

It did not expose, in the frozen native harness or function contract, the exact T1–T4 custom theorem family documented here.

### 35.2 Public literature and implementation search

A targeted public search was conducted on 30 July 2026 using combinations of:

- `mlk_kem_check_pk` with canonical acceptance;
- arbitrary-context rejection;
- red-zone preservation;
- seed noninterference;
- prefix-only access;
- ML-KEM modulus-check CBMC;
- public-key validation formal verification.

The search identified:

- formal ML-KEM security and correctness work in EasyCrypt/Jasmin;
- other implementations and validation code for FIPS 203 modulus checking;
- the mlkem-native native contract/CBMC baseline;
- conformance and mutation-testing work concerning ML-KEM public-key validation.

No exact publicly indexed match was identified for the combined artefact family proving the production `mlkem-native` C checker at the frozen commit using the specific T1-R2, T1-R3, T2 frame/redzone, T3 prefix-footprint, and T4 caller-guard theorems.

This is evidence of originality, not a proof of worldwide nonexistence. Search engines may miss repositories, branches, private work, unpublished work, theses, or differently named properties.

---

## 36. Novelty potency by level

| Novelty level | Assessment | Reason |
|---|---|---|
| Mathematical theorem novelty | Low | Canonical encoding and modulus-check semantics come from FIPS 203. |
| Function novelty | None | `mlk_kem_check_pk` already exists in mlkem-native. |
| Repository-level artefact novelty | Strong | The custom functional, frame, footprint, and caller harnesses are materially different from the native boilerplate harness and source contract. |
| Case-study campaign originality | Strong | The four-layer proof chain, failure taxonomy, resource redesign, coverage evidence, and trust-boundary matrix form a new reproducible case study. |
| Global/world-first novelty | Qualified, unconfirmed | No exact public match was found, but exhaustive proof of global absence is impossible. |
| Thesis contribution potency | Strong when correctly framed | The contribution is a new, auditable property-specific verification artefact family and evaluation record, not invention of the underlying cryptographic requirement. |

---

## 37. Defensible novelty claim

The recommended thesis wording is:

> This study contributes a newly authored, reproducible CBMC verification campaign for the production `mlkem-native` `mlk_kem_check_pk` path at a frozen commit. The campaign extends the repository-native contract and boilerplate harness with property-specific actual-body proofs of arbitrary-context malformed-key rejection and canonical-key acceptance, contract-backed frame and read-footprint proofs, and a stub-backed caller guard theorem. A targeted public search conducted on 30 July 2026 did not identify an equivalent publicly available proof artefact combining these properties for the same function and implementation version. The contribution is therefore claimed as repository-level artefact novelty and case-study originality, not as an unconditional world-first formal proof of ML-KEM public-key validation.

A shorter version is:

> To the best of our knowledge, no equivalent public CBMC artefact was identified that establishes this exact T1–T4 property family for the frozen production `mlkem-native` checker and its encapsulation caller. This is a qualified originality claim rather than a categorical world-first claim.

---

## 38. Claims that should be avoided

Do not write:

- “This is the first proof of ML-KEM public-key validation.”
- “No one has ever proved this function.”
- “The whole ML-KEM implementation is correct.”
- “T2 proved seed noninterference directly.”
- “T4 proved the internal checker.”
- “The harness is entirely independent of mlkem-native.”

The last statement would be inaccurate because the harness targets mlkem-native types, constants, function signatures, production bodies, and some native contracts. The correct distinction is that the **verification specification and harness logic are newly authored and materially distinct**, while remaining bound to the production implementation.

---

## 39. Why the contribution remains meaningful despite existing native proofs

The native proof is not invalid or weak; it serves a different assurance purpose. The new contribution is meaningful because:

1. return-domain correctness is not the same as exact accept/reject semantics;
2. memory safety is not the same as canonicality correctness;
3. a boilerplate call harness does not express arbitrary-context malformed rejection;
4. acceptance must be proved separately to rule out reject-all behaviour;
5. frame and red-zone properties make side effects explicit;
6. relational proof failure exposes contract limitations rather than being hidden;
7. a footprint theorem answers the seed-dependency question more directly;
8. caller-side composition shows the check is enforced at the security boundary;
9. coverage and hash-bound evidence improve reproducibility and auditability.

---

# Part VIII — Reproducibility and evidence inventory

## 40. Main campaign hashes

### Frozen source

```text
Commit:
af4c5abdd5958bdc65a03cd5ee86708264f93304

kem.c:
b3de1f7602b10c6033eee8b235138190ed09df917ec9326c2b38ce1083c541ce

kem.h:
e239f5d705fca7729e7838e836aa2fab814ddc4ffbaf7eeb73a32242b15d960d
```

### T1-R2

```text
Harness:  43dd0282fa57f976920185908806ba3a6c9494f0b601e87c2a504c221ab78d8c
Makefile: c75ce8f02d2f40f8a08401e96f78d585fd9dec4522facd4db552e8b18e1739ab
GOTO:     5cf49e4012d41919e95a8a512c38b893b8674beb0ac4b7459cbbe9e7d83730a3
```

### T1-R3

```text
Harness:  61362cd4e63f06b30952d94def19201dc5198caf224b0aa09a3441502297271e
Makefile: af966afec366566d88c2096b48095d3d5a7aeb2a7c9a9241b47a320794ea37d9
GOTO:     63d071dea1ee122637b83d06dcb743fb2a8c8e33c6adaa48d7ed85b8d96e7efa
Verdict:  0689e8cfd2b18d746621965ccc9e9f970922778dc211b0f0967a567543f80592
```

### T2

```text
Harness:  1db5496f9992730fc965d34de669f0f771e1b8d82a694e0cd54c869bd1bfef62
Makefile: 738492c2948610afbd43e6272f0406801089fd5207df521aa48f366e8af09d46
GOTO:     6782995e8d61f04e292acc70eae2968b802185f0cd6c2668f85b35770b762b41
```

### T3

```text
Harness:      a1d9a60e50ced4a4be207a93dd5de650079242058229594bf2f04a1cc6719ed2
Makefile:     c69deeefe8c207a3ffd197b4b4ff74cf82068f152c20b4cdc1c25a3243725cc4
GOTO:         5e668297f43ea3b352d5e6d3a408d388a92960e2570917f5816453f1de87b3e0
Safety XML:   cab7452254394bd0dea20cfab56b899563deb4890d0387400de89bdd870659da
Coverage XML: ba0f3d3c2699534e28e0c9b6dad737927c23ae5b2b9524e6e7d6eb23669d78e8
```

### T4

```text
Harness:  d46d6c1a2934fe1f0e1ce8981b4839dec6128ee8615bf8a0a4f8bf2ebbdc96a0
Makefile: 92d06786013810b6f836b5dd6b5d344de932352841c69b60bb93e028f5df765d
GOTO:     3ea66fe0c6fbd6352eec1c922a5f9ab74338cfba6630681934dd27452d75a65e
Verdict:  86d2678b93ca3d59b666a6306bb584f3faa613c0d895a97367092b57c5c86e0e
```

Some intermediate verdict-file hashes were clipped in terminal pastes and are therefore not reconstructed or invented in this report.

---

## 41. Final supported campaign classification

```text
PKCHECK_MLKEM768_CBMC_CAMPAIGN_SUCCESSFULLY_CLOSED
```

This classification means:

- T1 functional semantics closed successfully;
- T2 frame properties closed successfully;
- T2 seed relational attempt retained as an abstraction limitation;
- T3 prefix-footprint theorem closed successfully;
- T4 caller guard theorem closed successfully;
- no production defect was established;
- production source integrity was preserved.

---

# Part IX — Professor-facing interpretation

## 42. What is the main scientific contribution?

The main contribution is not the discovery that ML-KEM coefficients must be less than `q`. That requirement is normative. The contribution is the construction and evaluation of a property-specific CBMC evidence stack showing that a production C implementation satisfies the requirement under explicit assumptions, together with frame, footprint, and caller-composition evidence.

The work also demonstrates a disciplined human-review boundary for AI-assisted formal artefacts. Several generated scripts and models contained mistakes. Those mistakes were not accepted as production findings. They were diagnosed, corrected, and classified, while successful properties were bound to exact artefacts and model scopes.

---

## 43. Why is this stronger than a test suite?

A conventional test suite can exercise selected valid and invalid keys. This campaign symbolically quantified over:

- every coefficient index;
- every noncanonical 12-bit value;
- arbitrary surrounding bytes;
- all canonical coefficient assignments;
- arbitrary seed suffixes;
- every selected frame/red-zone byte position.

The result is not dependent on a finite handpicked corpus, although it remains bounded by the C model, parameter set, assumptions, and dependency abstractions.

---

## 44. Why is T2’s failed property valuable?

The failed property shows that successful single-call contracts do not automatically provide relational determinism across two abstract calls. This is a formal-modelling lesson, not an implementation bug. The campaign did not hide the failure or weaken the assertion. It changed to a better theorem in T3 that directly tested the relevant read footprint.

This supports a thesis argument that AI-generated formal artefacts require human semantic review, tool-aware correction, and careful counterexample classification.

---

## 45. Why is T4 still needed after T1 proves the checker?

A correct validator is insufficient if the caller ignores its result or writes outputs before checking it. T4 verifies the enforcement point. It proves the caller’s response to a failure event, while T1 proves that the real checker produces the correct event for malformed keys.

This is compositional assurance:

```text
T1: the checker detects malformed encoding
T4: the caller respects checker failure
```

---

## 46. Is the harness fake because it was not shipped by mlkem-native?

No. Verification harnesses are external proof artefacts by design. Their validity depends on whether they:

- call the real target body;
- preserve the production source;
- define a meaningful symbolic domain;
- avoid vacuous assumptions;
- state independent assertions;
- correctly model dependencies;
- close loops soundly;
- produce reviewable solver evidence.

The campaign satisfies these conditions within the documented boundaries. T4 is explicitly marked stub-backed because it deliberately replaces a lower function.

---

## 47. Is this a proof of production code or a modified candidate?

T1–T3 retained the production checker target body from the frozen source. T1 retained the main decode/reduce/re-encode implementation bodies and used only documented lower contracts for comparison and cleanup. T2 and T3 used a concrete target with lower native contracts. T4 retained the production caller and used a deliberate lower failure stub.

The production C source itself was not modified. The harnesses and Makefiles changed only the verification environment.

---

# Part X — Final concise statement

## 48. Final campaign statement

At frozen commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`, under the ML-KEM-768 portable-C configuration and CBMC 6.9.0, the campaign established that the production `mlk_kem_check_pk` modulus-check decision accepts every canonical 768-coefficient polynomial-vector encoding and rejects every encoding containing a noncanonical 12-bit coefficient, except for explicitly permitted allocation failure. It additionally established input and red-zone preservation, a contract-backed prefix-only read footprint excluding the public-seed suffix, and stub-backed early failure propagation and frame preservation in the concrete encapsulation caller. The production source remained unchanged. A failed T2 relational property was correctly classified as an abstraction counterexample and was not represented as a production defect.

The contribution is best described as a **new property-specific CBMC verification artefact family and reproducible case-study evidence stack for the exact production function and frozen version**. Repository-level originality and campaign-level novelty are strong. Global novelty is stated conservatively: no exact public match was identified in the targeted search, but no unconditional world-first claim is made.

---

# References and public novelty-check sources

1. National Institute of Standards and Technology (2024) *FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard*. DOI: 10.6028/NIST.FIPS.203. Available at: https://csrc.nist.gov/pubs/fips/203/final (Accessed: 30 July 2026).
2. pq-code-package (2026) *mlkem-native: Secure, fast, and portable C90 implementation of ML-KEM/FIPS 203*. Available at: https://github.com/pq-code-package/mlkem-native (Accessed: 30 July 2026).
3. pq-code-package (2026) *mlkem-native CBMC proofs at commit af4c5abd…*. Available at: https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc (Accessed: 30 July 2026).
4. pq-code-package (2026) *Native `kem_check_pk` harness at commit af4c5abd…*. Available at: https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc/kem_check_pk/kem_check_pk_harness.c (Accessed: 30 July 2026).
5. pq-code-package (2026) *Native `kem_check_pk` proof Makefile at commit af4c5abd…*. Available at: https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc/kem_check_pk/Makefile (Accessed: 30 July 2026).
6. pq-code-package (2026) *`kem.h` contract at commit af4c5abd…*. Available at: https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/mlkem/src/kem.h (Accessed: 30 July 2026).
7. pq-code-package (2026) *`kem.c` implementation at commit af4c5abd…*. Available at: https://github.com/pq-code-package/mlkem-native/blob/af4c5abdd5958bdc65a03cd5ee86708264f93304/mlkem/src/kem.c (Accessed: 30 July 2026).
8. Almeida, J.B. et al. (2024) ‘Formally Verifying Kyber: Episode V: Machine-checked IND-CCA security and correctness of ML-KEM in EasyCrypt’, *CRYPTO 2024*. Artifact available at: https://artifacts.iacr.org/crypto/2024/a3/ (Accessed: 30 July 2026).
9. AWS Labs (2026) *LibMLKEM: A formal reference implementation of FIPS 203 ML-KEM*. Available at: https://github.com/awslabs/LibMLKEM (Accessed: 30 July 2026).
10. NIST ACVP (2026) *ACVP ML-KEM JSON Specification*. Available at: https://pages.nist.gov/ACVP/draft-celi-acvp-ml-kem.html (Accessed: 30 July 2026).
11. RustCrypto (2026) *ML-KEM encapsulation-key validation source*. Available at: https://docs.rs/ml-kem/latest/src/ml_kem/pke.rs.html (Accessed: 30 July 2026).

---

## Appendix A — Property inventory

### T1-R2

```text
PKCHECK-T1R2.INDEX_PAIR_BOUND
PKCHECK-T1R2.INDEX_BYTE_BOUND
PKCHECK-T1R2.ORACLE_PACKING
PKCHECK-T1R2.ARBITRARY_CONTEXT_REJECTION
mlk_check_pk.unwind.1
mlk_check_pk.unwind.2
mlk_poly_frombytes_c.unwind.1
mlk_poly_reduce_c.unwind.1
mlk_poly_tobytes_c.unwind.1
mlk_polyvec_frombytes.unwind.1
mlk_polyvec_reduce.unwind.1
mlk_polyvec_tobytes.unwind.1
```

### T1-R3

```text
PKCHECK-T1R3.CANONICAL_ACCEPTANCE
mlk_check_pk.unwind.1
mlk_check_pk.unwind.2
mlk_poly_frombytes_c.unwind.1
mlk_poly_reduce_c.unwind.1
mlk_poly_tobytes_c.unwind.1
mlk_polyvec_frombytes.unwind.1
mlk_polyvec_reduce.unwind.1
mlk_polyvec_tobytes.unwind.1
```

### T2

```text
PKCHECK-T2.FIRST_INPUT_FRAME
PKCHECK-T2.SECOND_INPUT_FRAME
PKCHECK-T2.REDZONE_PRESERVATION
PKCHECK-T2.SEED_NONINTERFERENCE
```

### T3

```text
PKCHECK-T3.RESULT_DOMAIN
plus 109 lower precondition, pointer, bounds, assigns, assertion, and unwind properties
```

### T4

```text
PKCHECK-T4.CHECK_AT_MOST_ONCE
PKCHECK-T4.GUARD_RESULT_SPLIT
PKCHECK-T4.CIPHERTEXT_FRAME
PKCHECK-T4.SHARED_SECRET_FRAME
PKCHECK-T4.PUBLIC_KEY_FRAME
PKCHECK-T4.COINS_FRAME
mlk_enc_derand.unwind.1
mlk_enc_derand.unwind.2
```

---

## Appendix B — Accepted coverage goals

```text
T1-R2: result == MLK_ERR_FAIL                 SATISFIED
T1-R3: result == 0                            SATISFIED
T3:    result != MLK_ERR_OUT_OF_MEMORY        SATISFIED
T4:    t4_check_pk_calls == 1                 SATISFIED
```

---

## Appendix C — Campaign result vocabulary

- **Actual-body theorem:** the theorem target’s production body is present in the GOTO model.
- **Contract-backed theorem:** the target is concrete, while named lower functions are replaced by contracts.
- **Stub-backed theorem:** a named lower function is intentionally replaced by a purpose-built stub.
- **Abstraction counterexample:** a counterexample permitted by the abstraction but not established as a concrete execution of production bodies.
- **Non-vacuity coverage:** a satisfiable witness that the intended branch or state can be reached.
- **Property success:** the selected CBMC property is reported `SUCCESS` in the bound model.
- **Campaign closure:** all intended theorem families are either proved or explicitly classified with accepted limitations and evidence.
