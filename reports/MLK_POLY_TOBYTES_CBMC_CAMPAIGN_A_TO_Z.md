# `mlk_poly_tobytes` CBMC Verification Campaign  
## Complete A–Z Technical Record, Proof Interpretation, Evidence Boundary and Novelty Assessment

**Author:** Girish Nallan Chakravathy  
**Case-study target:** `mlk_poly_tobytes` / `mlk_poly_tobytes_c` in `mlkem-native`  
**Repository commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Primary configuration proved:** ML-KEM-768, portable C backend  
**Verification tool:** CBMC 6.9.0  
**Document date:** 29 July 2026  
**Document status:** Professor-facing technical record

---

## Document purpose

This document records the complete verification campaign that we conducted for the `mlk_poly_tobytes` serialization function in `mlkem-native`. It is written as a record of our own work rather than as a tutorial. It explains:

- what source and build were frozen;
- what the upstream repository already proved;
- why we created new clean-room harnesses;
- the 19 frozen semantic obligations in theorem families T1–T4;
- the assumptions under which the results hold;
- the positive, non-vacuity, unwinding and mutation evidence;
- why the four theorem families are complementary;
- whether we can truthfully state that `mlk_poly_tobytes` was proved correct;
- what was not proved;
- the strength and limitations of the novelty claim;
- the hashes and evidence identities needed for reproducibility.

The central conclusion is:

> We established property-specific functional correctness of the real portable `mlk_poly_tobytes` implementation, reached through its public wrapper, for canonical polynomial inputs in the frozen ML-KEM-768 CBMC configuration. The result covers exact ByteEncode12 arithmetic, successor/carry behaviour, exact canonical image, invalid-codeword exclusion, arithmetic recoverability and injectivity. It does not establish native-backend correctness, constant-time behaviour, compiler-binary correctness, `mlk_poly_frombytes` correctness, out-of-domain behaviour or complete ML-KEM correctness.

---

# 1. Executive verdict

## 1.1 What was proved

We proved 19 frozen semantic obligations arranged into four theorem families:

| Family | Purpose | Core obligations | Final status |
|---|---|---:|---|
| T1 | Exact arithmetic refinement of ByteEncode12 | 6 | PASS |
| T2 | Exact successor and carry-transition behaviour | 4 | PASS |
| T3 | Exact canonical image and invalid-codeword exclusion | 5 | PASS |
| T4 | Arithmetic recoverability and collision freedom | 4 | PASS |
| **Total** |  | **19** | **PASS** |

Across the positive proof runs, CBMC reported:

| Family | Positive models | Positive result count | Successful results | Failure / error / unknown |
|---|---:|---:|---:|---:|
| T1 | 1 | 156 | 156 | 0 / 0 / 0 |
| T2 | 1 | 154 | 154 | 0 / 0 / 0 |
| T3 | 4 | 430 | 430 | 0 / 0 / 0 |
| T4 | 3 | 306 | 306 | 0 / 0 / 0 |
| **Total** | **9** | **1,046** | **1,046** | **0 / 0 / 0** |

The campaign additionally executed:

- **36 concrete non-vacuity witnesses**;
- **14 deliberately insufficient-unwind controls**;
- **17 targeted production-code semantic mutants**;
- source, commit, harness, model, command and result hashing;
- repeated authoritative-tree and detached-worktree cleanliness checks.

## 1.2 What “PASS” means

A positive `SUCCESS` was never accepted by itself. A theorem family was closed only after the following evidence layers were satisfied:

1. exact source and commit binding;
2. a clean detached worktree;
3. real public-wrapper invocation;
4. call-graph reachability to the real portable body;
5. no contract replacement;
6. no native backend;
7. complete loop unwinding with unwinding assertions;
8. memory and arithmetic safety checks;
9. explicit semantic assertions;
10. non-vacuity witnesses;
11. deliberately insufficient-unwind rejection;
12. targeted production mutation rejection;
13. deterministic evidence hashing and closure packaging.

This is why the result is materially stronger than “CBMC printed SUCCESS once.”

---

# 2. Frozen campaign identity

## 2.1 Repository and source identity

```text
Repository:
  /home/girish/THESIS-2026/mlkem-native_af4c5abd

Commit:
  af4c5abdd5958bdc65a03cd5ee86708264f93304

Source worktree:
  /home/girish/THESIS-2026/mlk_poly_tobytes_cleanroom/
  PBYTES_01A_WORKTREE_RUN1_af4c5abd

Production source:
  mlkem/src/compress.c

Production source SHA-256:
  9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad

Extracted mlk_poly_tobytes_c function SHA-256:
  38e880b642ef083ec504175a60bc52e1269ce817749996cc60cf933cef2aca3a
```

The authoritative source tree and detached worktree were repeatedly checked as clean before and after proof execution. The positive campaigns did not modify production C source.

## 2.2 Fixed constants

The proof configuration used:

```text
MLKEM_N         = 256
MLKEM_Q         = 3329
MLKEM_POLYBYTES = 384
Parameter set   = ML-KEM-768
Backend         = portable C
```

Each polynomial contains 256 coefficients. Two 12-bit coefficients are serialized into three bytes, so:

```text
256 coefficients × 12 bits = 3072 bits = 384 bytes
```

## 2.3 Tool identity

```text
CBMC:            6.9.0
goto-cc:         6.9.0, native GCC 13.3.0
goto-instrument: 6.9.0
GCC:             13.3.0
Primary solver:  CBMC default SAT backend
```

---

# 3. The implementation under proof

The portable body processes pairs of canonical coefficients:

```c
const uint16_t t0 = (uint16_t)a->coeffs[2 * i];
const uint16_t t1 = (uint16_t)a->coeffs[2 * i + 1];

r[3 * i + 0] = (uint8_t)(t0 & 0xFF);
r[3 * i + 1] = (uint8_t)((t0 >> 8) | ((t1 << 4) & 0xF0));
r[3 * i + 2] = (uint8_t)(t1 >> 4);
```

The public wrapper calls the portable body when the native backend is not selected:

```c
void mlk_poly_tobytes(uint8_t r[MLKEM_POLYBYTES], const mlk_poly *a)
{
    ...
    mlk_poly_tobytes_c(r, a);
}
```

The source documentation states that the function implements `ByteEncode_12` from FIPS 203 and requires coefficients in `[0, MLKEM_Q)` [R1, R2, R3].

---

# 4. Mathematical reference used by the proof

For one coefficient pair:

```text
c0 = even coefficient
c1 = odd coefficient

0 ≤ c0 < 3329
0 ≤ c1 < 3329
```

The independent arithmetic encoding was defined as:

```text
b0 = c0 mod 256
b1 = floor(c0 / 256) + 16 × (c1 mod 16)
b2 = floor(c1 / 16)
```

The corresponding 24-bit little-endian word is:

```text
W = b0 + 256b1 + 65536b2
```

Substitution gives:

```text
W = c0 + 4096c1
```

The independent arithmetic decoder was:

```text
decoded_even = W mod 4096
decoded_odd  = floor(W / 4096)
```

Because canonical coefficients satisfy `0 ≤ c0,c1 < 3329 < 4096`, decoding the correctly packed word returns exactly the original coefficient pair.

This arithmetic formulation was deliberately chosen because it is structurally different from the production shift-and-mask expressions. It reduces the risk that a copied implementation bug would also be copied into the oracle.

---

# 5. Upstream baseline and the gap we addressed

## 5.1 What upstream `mlkem-native` already contained

At the frozen commit, the repository contained dedicated CBMC proof directories for:

- `poly_tobytes_c`;
- the public `poly_tobytes` wrapper;
- generic native;
- AArch64 native;
- x86-64 native.

The upstream `poly_tobytes_c` harness was essentially a call-only harness:

```c
void harness(void)
{
    mlk_poly *a;
    uint8_t *r;

    /* Contracts for this function are in compress.h */
    mlk_poly_tobytes_c(r, a);
}
```

The upstream harness audit found:

```text
__CPROVER_assume count = 0
__CPROVER_assert count = 0
plain assert count      = 0
explicit functional byte assertions = 0
```

The upstream function contract established:

- valid non-aliasing input and output memory;
- canonical input coefficient bounds;
- the output memory slice that may be assigned.

It did **not** contain a functional postcondition specifying the exact 384 output bytes.

## 5.2 What the upstream proof was suitable for

The upstream proof infrastructure is valuable and should not be misrepresented. It supports high-assurance checking of matters such as:

- memory safety;
- type and arithmetic safety;
- loop-contract compliance;
- validity of the function contract;
- frame/assignment restrictions;
- correct use of the function in the repository’s proof framework.

The broader `mlkem-native` project publicly describes extensive C-level CBMC verification, while architecture-specific AArch64 assembly receives separate HOL Light verification [R4, R5].

## 5.3 The exact gap

The repository-level gap was not “there was no proof at all.” The gap was:

> The audited upstream `poly_tobytes` harnesses and contracts did not state explicit byte-level semantic assertions proving that the unmodified portable C body implements the complete arithmetic ByteEncode12 mapping, its exact image and its injectivity.

Our campaign was created to address that narrower and more defensible gap.

---

# 6. Clean-room verification design

## 6.1 Public-wrapper rule

The semantic harnesses were required to call:

```c
mlk_poly_tobytes(...)
```

They were not permitted to call only:

```c
mlk_poly_tobytes_c(...)
```

and then claim public-wrapper correctness.

For each model, the reduced GOTO call graph was audited for the path:

```text
__CPROVER__start
    → harness
    → mlk_poly_tobytes
    → mlk_poly_tobytes_c
```

## 6.2 No contract substitution

The positive proof commands did not request:

```text
--replace-call-with-contract
--enforce-contract
```

for the target wrapper or portable body.

Both actual function bodies remained in the reachable model.

## 6.3 No native backend

The configuration and model forensics required:

```text
native occurrence count = 0
mlk_poly_tobytes_native = absent
```

The resulting claim is therefore about the portable C implementation only.

## 6.4 No circular decoder oracle

T3 and T4 did not call:

```c
mlk_poly_frombytes(...)
```

Using the repository’s decoder to validate the repository’s encoder would create a circular or coupled argument. Instead, the harnesses decoded each block through independent arithmetic:

```text
W = b0 + 256b1 + 65536b2
even = W mod 4096
odd  = W / 4096
```

## 6.5 No result-shaped assumptions

The harnesses could assume only the declared input domain, valid object ranges, selected-index bounds and theorem-specific antecedents. They could not assume:

- expected output bytes;
- output equality;
- decoded equality;
- a contradictory condition;
- `assume(false)`;
- the theorem conclusion.

## 6.6 Positive source immutability

Positive proof runs linked the exact unmodified source. Production mutations were created only as detached copies inside mutation-control directories. They were negative controls and did not alter the authoritative repository or positive harness.

---

# 7. Why exactly four theorem families were selected

The campaign intentionally froze four families rather than accumulating many loosely related assertions.

## 7.1 T1 answers: “What exact bytes are produced?”

T1 is the absolute functional baseline. It proves byte-for-byte equality with an independently expressed arithmetic ByteEncode12 oracle.

Without T1, a function could be injective or internally consistent but still serialize in the wrong byte order or with the wrong bit allocation.

## 7.2 T2 answers: “How does the encoding change across critical boundaries?”

T2 is a relational successor theorem. It compares two real executions whose selected coefficient differs by exactly one.

This isolates the four carry regimes created by:

- the 8-bit boundary at `255 → 256`;
- the nibble boundary at `15 → 16`.

A broad equality theorem can establish correctness, but the relational partition makes carry behaviour explicit, diagnosable and mutation-sensitive.

## 7.3 T3 answers: “Which byte strings are exactly in the encoder’s image?”

T3 characterizes produced and producible codewords:

- every produced 12-bit field is canonical;
- every canonical block is realizable;
- any block with an invalid field is excluded;
- the complete 384-byte image is exactly the set of arrays whose 256 decoded fields are canonical.

T1 proves the mapping for an input. T3 proves the shape of the complete output language.

## 7.4 T4 answers: “Can information be recovered, and can distinct inputs collide?”

T4 proves:

- arithmetic recovery of both coefficients;
- block equality iff coefficient-pair equality;
- full canonical-polynomial injectivity.

This closes the losslessness question explicitly.

## 7.5 Why we did not stop at T1

T1 is mathematically strong and, together with elementary arithmetic reasoning, implies many consequences later made explicit in T2–T4. We nevertheless did not stop because a single oracle-centered theorem creates concentration risk:

- one oracle design error could affect all conclusions;
- the proof would not separately exercise carry cases;
- image characterization would remain implicit;
- collision freedom would remain a derived verbal claim rather than an executed relational theorem;
- mutation failures would be less precisely diagnosable.

Independent theorem shapes provide cross-checking evidence.

## 7.6 Why we did not stop at T2

T2 proves local changes under an increment of one. It does not by itself prove the absolute output for every input. A consistently wrong encoding could still have plausible local successor behaviour.

T2 therefore cannot replace T1.

## 7.7 Why we did not stop at T3

T3 establishes canonical image membership and realizability. It does not by itself prove that each particular input is mapped to its specified codeword. A wrong permutation of canonical codewords could preserve the image while encoding individual polynomials incorrectly.

T3 therefore cannot replace T1.

## 7.8 Why T4 was still necessary after T3

T3 says which outputs are possible. T4 says whether different inputs can share the same output.

Image characterization and injectivity are different properties:

```text
T3: range / image question
T4: one-to-one mapping question
```

A surjective mapping onto the canonical image can still contain collisions if the domain and proof conditions are not used correctly. T4 makes no-collision and recovery properties explicit.

## 7.9 Why T4 cannot replace T1

An injective but incorrectly permuted encoder would pass an injectivity theorem. For example, a systematic reversible reordering of coefficients could be collision-free while failing the FIPS ByteEncode12 specification.

Therefore:

```text
T1 gives specification accuracy.
T2 gives boundary-transition accuracy.
T3 gives exact output-language accuracy.
T4 gives information-preservation accuracy.
```

All four are complementary.

---

# 8. The frozen theorem registry

## PBYTES-T1 — Exact arithmetic ByteEncode12 refinement

1. `PBYTES-T1.P1` — exact low byte of the even coefficient.
2. `PBYTES-T1.P2` — exact high nibble of the even coefficient.
3. `PBYTES-T1.P3` — exact low nibble of the odd coefficient.
4. `PBYTES-T1.P4` — exact high byte of the odd coefficient.
5. `PBYTES-T1.P5` — exact 24-bit packed-word equality.
6. `PBYTES-T1.P6` — complete 384-byte arithmetic-oracle equality.

## PBYTES-T2 — Exact successor and carry-transition partition

1. `PBYTES-T2.P1` — even coefficient without low-byte carry.
2. `PBYTES-T2.P2` — even coefficient with `255 → 256` carry.
3. `PBYTES-T2.P3` — odd coefficient without high-nibble carry.
4. `PBYTES-T2.P4` — odd coefficient with `15 → 16` nibble-to-byte carry.

## PBYTES-T3 — Exact canonical image and invalid-codeword exclusion

1. `PBYTES-T3.P1` — every produced even field is below `MLKEM_Q`.
2. `PBYTES-T3.P2` — every produced odd field is below `MLKEM_Q`.
3. `PBYTES-T3.P3` — every canonical 24-bit block is realizable.
4. `PBYTES-T3.P4` — a block with either invalid field is not realizable.
5. `PBYTES-T3.P5` — full-array image iff all 256 fields are canonical.

## PBYTES-T4 — Arithmetic recoverability and collision freedom

1. `PBYTES-T4.P1` — arithmetic recovery of the even coefficient.
2. `PBYTES-T4.P2` — arithmetic recovery of the odd coefficient.
3. `PBYTES-T4.P3` — block equality iff coefficient-pair equality.
4. `PBYTES-T4.P4` — full canonical-polynomial injectivity.

---

# 9. T1 — Exact arithmetic ByteEncode12 refinement

## 9.1 Purpose

T1 was the primary specification-refinement theorem. It compared the actual output of the real public wrapper against an independent oracle using division and remainder rather than the implementation’s shifts and masks.

## 9.2 T1 harness architecture

The T1 harness:

- declared a complete symbolic canonical input polynomial;
- copied the input before the target call;
- placed the output inside a guarded structure;
- preserved symbolic left and right canary bytes;
- constructed a complete 384-byte arithmetic oracle;
- selected an arbitrary coefficient pair;
- called the real public `mlk_poly_tobytes` wrapper;
- asserted P1–P5 for the selected block;
- asserted P6 over all 384 bytes;
- asserted three supporting controls.

The six semantic assertions were:

```text
P1: output[3i] = c0 mod 256

P2: output[3i+1] mod 16 = floor(c0 / 256)

P3: floor(output[3i+1] / 16) = c1 mod 16

P4: output[3i+2] = floor(c1 / 16)

P5:
  output[3i] + 256 output[3i+1] + 65536 output[3i+2]
  =
  c0 + 4096 c1

P6:
  all 384 output bytes equal the independently constructed oracle
```

## 9.3 T1 supporting controls

The supporting controls were not counted as extra theorem families:

- `T1.C1`: input-frame preservation;
- `T1.C2`: left output canary preservation;
- `T1.C3`: right output canary preservation.

P6 also provided complete-overwrite sensitivity because the output buffer was unconstrained before the call. An untouched output byte could not accidentally satisfy equality for every symbolic input.

## 9.4 Positive result

```text
Positive CPROVER status: SUCCESS
Total properties:          156
SUCCESS:                   156
FAILURE:                   0
ERROR:                     0
UNKNOWN:                   0
Explicit assertions:       9 / 9 SUCCESS
```

## 9.5 T1 non-vacuity

Four deliberately false post-call witnesses were used to demonstrate concrete reachability of representative scenarios. The expected top-level result was `FAILURE`, because each witness asserted false after a real execution.

```text
Total results:       97
SUCCESS:             93
Intended failures:   4
Unexpected failures: 0
Unwind failures:     0
Non-vacuity status:  PASS
```

## 9.6 T1 unwind control

The full proof used the complete loop bounds. A deliberately insufficient harness unwind produced exactly:

```text
harness.unwind.0 = FAILURE
```

with no unrelated failure, error or unknown. This demonstrated that unwinding assertions were active and that an insufficient bound would not be silently accepted.

## 9.7 T1 semantic mutants

Four detached production mutants were executed:

| Mutant | Corruption | Expected semantic failures |
|---|---|---|
| M1 | Clear bit zero of first packed byte | P1, P5, P6 |
| M2 | Shift `t0` by nine rather than eight | P2, P5, P6 |
| M3 | Shift `t1` by three rather than four in middle byte | P3, P5, P6 |
| M4 | Shift `t1` by five rather than four in third byte | P4, P5, P6 |

All four mutants were rejected with exactly the expected explicit failures and no non-explicit non-success or unwind failure.

## 9.8 T1 external artifact review

The T1 candidate package was separately uploaded and reviewed.

```text
External review archive SHA-256:
15f68231bc634bc02a97cd8adbd13d6ff6e6d493061619e563d6793ea9e50a3d

Internal evidence manifest:
62 / 62 OK

External review record SHA-256:
0f17164f535846885780dd3f607dd891847fe07d0e60f0d08ff2bf3fe2c84b23

Final T1 closure record SHA-256:
9d3dbf059431dc1967348533e854821ffe0b1702bad987f8fab4b53897b57ef1
```

The external review disclosed two non-blocking packaging details:

1. the raw positive GOTO binary was not present in the review archive, so its recorded model hash could not be independently recalculated from that uploaded package;
2. `FILE_INVENTORY.txt` omitted a manifest-check file created after inventory generation.

The original campaign retained the model hash and evidence. Harness source, build command, call structure and raw XML consistently established actual portable-body execution. These packaging details did not alter the theorem results.

## 9.9 T1 conclusion

T1 established that, for every canonical input polynomial in the frozen model, the complete 384-byte output of the real public wrapper equals the independent arithmetic ByteEncode12 oracle.

---

# 10. T2 — Exact successor and carry-transition partition

## 10.1 Purpose

T2 compared two real serializations. Input `B` was equal to input `A` except that one selected canonical coefficient was incremented by exactly one, with the increment constrained to remain below `MLKEM_Q`.

This was not another absolute oracle. It was a relational theorem about how the actual output changes.

## 10.2 Four carry regimes

### T2.P1 — even coefficient, no low-byte carry

Condition:

```text
c0 mod 256 ≠ 255
```

Expected selected-block change:

```text
byte 0 increments by 1
byte 1 unchanged
byte 2 unchanged
```

### T2.P2 — even coefficient, `255 → 256` carry

Condition:

```text
c0 mod 256 = 255
```

Expected selected-block change:

```text
byte 0: 255 → 0
low nibble of byte 1 increments by 1
high nibble of byte 1 unchanged
byte 2 unchanged
```

### T2.P3 — odd coefficient, no nibble carry

Condition:

```text
c1 mod 16 ≠ 15
```

Expected selected-block change:

```text
byte 0 unchanged
low nibble of byte 1 unchanged
high nibble of byte 1 increases by 0x10
byte 2 unchanged
```

### T2.P4 — odd coefficient, `15 → 16` carry

Condition:

```text
c1 mod 16 = 15
```

Expected selected-block change:

```text
byte 0 unchanged
low nibble of byte 1 unchanged
high nibble of byte 1: 0xF0 → 0
byte 2 increments by 1
```

## 10.3 Positive result

```text
Positive result count:      154
SUCCESS:                    154
FAILURE / ERROR / UNKNOWN:  0 / 0 / 0
Core T2 obligations:        4 / 4 SUCCESS
T2 positive status:         PASS
```

The model retained two public-wrapper call sites and the real portable body.

## 10.4 T2 non-vacuity

Four deliberately false witnesses—one for each transition regime—failed as intended:

```text
Witnesses seen:             4
Witness failures:           4
Unexpected non-success:     0
Unwind failures:            0
T2 non-vacuity status:      PASS
```

## 10.5 T2 unwind control

A deliberately low harness unwind caused exactly the expected unwind failure and no theorem, safety, error or unknown outcome.

## 10.6 T2 semantic mutants

| Mutant | Corruption | Target |
|---|---|---|
| M1 | `t0 & 0xFF` changed to `t0 & 0xFE` | T2.P1 |
| M2 | `t0 >> 8` changed to `t0 >> 9` | T2.P2 |
| M3 | `t1 << 4` changed to `t1 << 5` | T2.P3 |
| M4 | `t1 >> 4` changed to `t1 >> 5` | T2.P4 |

All four targeted properties failed. M1 also caused P2 to fail, and M3 also caused P4 to fail. These overlaps were expected consequences of shared byte fields and were accepted because:

- the target property failed;
- all explicit properties were present;
- no safety or non-explicit property failed;
- there was no unwind failure, error or unknown.

## 10.7 T2 conclusion

T2 established that the real serialization has the exact local successor behaviour required by the 8-bit and 4-bit packing boundaries.

---

# 11. T3 — Exact canonical image and invalid-codeword exclusion

## 11.1 Purpose

T3 changed the question from “what does this input encode to?” to:

> What is the exact set of byte blocks and full arrays that the encoder can produce?

The independent decoder treated each three-byte block as:

```text
W = b0 + 256b1 + 65536b2

even field = W mod 4096
odd field  = W / 4096
```

`mlk_poly_frombytes` was not called.

## 11.2 T3.P1 and T3.P2 — produced fields are canonical

For every actual output block:

```text
decoded even field < 3329
decoded odd field  < 3329
```

These properties exclude values `3329..4095` from both 12-bit lanes of any produced block.

## 11.3 T3.P3 — every canonical block is realizable

For arbitrary canonical fields `x,y < 3329`, the harness constructed the corresponding polynomial pair, called the real serializer and established that the selected three-byte block equals the canonical 24-bit block.

This proved surjectivity onto the canonical block set.

## 11.4 T3.P4 — invalid blocks are not realizable

The harness considered a candidate block with at least one decoded field in:

```text
[3329, 4095]
```

and established that no canonical polynomial serialization can produce that block.

## 11.5 T3.P5 — full-array image iff all fields are canonical

The full-array theorem combined both directions:

```text
Forward:
  every real serialization decodes to 256 canonical fields.

Reverse:
  every 384-byte array whose 256 arithmetic fields are canonical
  can be produced by serializing the corresponding canonical polynomial.
```

## 11.6 Positive results

Four separate model shapes were used:

| Model | Obligations | Results |
|---|---|---:|
| P12 | T3.P1, T3.P2 | 106 / 106 SUCCESS |
| P3 | T3.P3 | 106 / 106 SUCCESS |
| P4 | T3.P4 | 105 / 105 SUCCESS |
| P5 | T3.P5 | 113 / 113 SUCCESS |
| **Total** | **5 obligations** | **430 / 430 SUCCESS** |

## 11.7 T3 non-vacuity

Sixteen concrete witnesses covered:

- first and last pair positions;
- canonical `0`;
- canonical `MLKEM_Q − 1`;
- packing boundaries `15`, `16`, `255`, `256`;
- invalid field `MLKEM_Q`;
- invalid field `4095`;
- complete canonical arrays.

All 16 deliberately false witnesses failed after actual wrapper execution. No non-witness property failed.

## 11.8 T3 unwind controls

Six deliberately insufficient bounds separately targeted:

- a P1/P2 harness loop;
- a P3 production loop;
- a P4 harness loop;
- the P5 decode loop;
- the P5 comparison loop;
- the P5 production loop.

Each control failed only on an unwind assertion.

## 11.9 T3 semantic mutants

| Mutant | Corruption | Target |
|---|---|---|
| M1 | Force decoded even high nibble to 15 | T3.P1 |
| M2 | Force third byte to 255 | T3.P2 |
| M3 | Clear bit zero of canonical block | T3.P3 |
| M4 | Replace middle byte with 255 | T3.P4 |
| M5 | Shift odd high bits by five | T3.P5 |

All five target properties failed with:

```text
non-mapped non-success = 0
unwind failure         = 0
error                   = 0
unknown                 = 0
```

## 11.10 T3 conclusion

T3 established the exact canonical image of the serializer and excluded all 12-bit codewords containing a non-canonical ML-KEM coefficient.

---

# 12. T4 — Arithmetic recoverability and collision freedom

## 12.1 Purpose

T4 explicitly established losslessness. It used arithmetic decoding and relational comparisons rather than calling the production decoder.

## 12.2 T4.P1 and T4.P2 — coefficient recovery

For an arbitrary selected output block:

```text
W = b0 + 256b1 + 65536b2

W mod 4096 = original even coefficient
W / 4096   = original odd coefficient
```

## 12.3 T4.P3 — block equality iff pair equality

For two arbitrary canonical polynomials and an arbitrary pair index:

```text
three output bytes are equal
if and only if
the two corresponding input coefficients are equal
```

This proves both directions:

- equal pair implies equal block;
- equal block implies equal pair.

## 12.4 T4.P4 — full canonical-polynomial injectivity

For two arbitrary complete canonical polynomials:

```text
serialize(A) = serialize(B)  ⇒  A = B
```

This is the full no-collision theorem.

## 12.5 Positive results

| Model | Obligation(s) | Results |
|---|---|---:|
| P12 | T4.P1, T4.P2 | 108 / 108 SUCCESS |
| P3 | T4.P3 | 105 / 105 SUCCESS |
| P4 | T4.P4 | 93 / 93 SUCCESS |
| **Total** | **4 obligations** | **306 / 306 SUCCESS** |

The three harnesses contained five public-wrapper call sites in total.

## 12.6 T4 non-vacuity

Twelve witnesses covered:

- zero recovery;
- `q−1` recovery;
- `15`, `16`, `255`, `256` boundaries;
- equal pair/equal block;
- different pair/different block;
- even-only pair difference;
- odd-only pair difference;
- equal complete polynomials/equal outputs;
- unequal complete polynomials/unequal outputs;
- first-coefficient difference;
- last-coefficient difference.

All 12 deliberate witness assertions failed as intended, with no unexpected failure.

## 12.7 T4 unwind controls

Six low-unwind controls targeted:

- P1/P2 harness loop;
- P1/P2 production loop;
- P3 harness loop;
- P4 input-comparison loop;
- P4 output-comparison loop;
- P4 production loop.

All controls failed only on the targeted unwind assertion.

## 12.8 T4 semantic mutants

| Mutant | Corruption | Target |
|---|---|---|
| M1 | Clear even coefficient bit zero | T4.P1 |
| M2 | Shift odd high bits by five | T4.P2 |
| M3 | Create block-level collision by wrong nibble shift | T4.P3 |
| M4 | Remove odd high-byte contribution and create full collision | T4.P4 |

All four target properties failed and all unrelated safety/tool properties remained clean.

## 12.9 T4 conclusion

T4 established that the canonical ByteEncode12 mapping is recoverable and injective at both block and full-polynomial levels.

---

# 13. Cross-family synthesis

The four families create the following proof chain:

```text
T1:
  The actual bytes equal the FIPS-style arithmetic encoding.

T2:
  The actual bytes react correctly at all packing carry boundaries.

T3:
  The exact output image is the canonical 12-bit coefficient language.

T4:
  The mapping preserves all canonical input information and has no collisions.
```

Together they rule out different classes of implementation defect:

| Defect class | Primary detector |
|---|---|
| Wrong low byte | T1.P1 |
| Wrong even high nibble | T1.P2 |
| Wrong odd low nibble | T1.P3 |
| Wrong odd high byte | T1.P4 |
| Wrong packed relation | T1.P5 |
| Partial output or wrong byte anywhere | T1.P6 |
| Incorrect `255 → 256` propagation | T2.P2 |
| Incorrect `15 → 16` propagation | T2.P4 |
| Emission of non-canonical 12-bit code | T3.P1/P2/P4 |
| Missing canonical codeword | T3.P3/P5 |
| Block-level collision | T4.P3 |
| Full-polynomial collision | T4.P4 |
| Out-of-bounds output write | canaries and CBMC safety |
| Input modification | frame control |
| Incomplete loop analysis | unwinding assertions and low-unwind controls |
| Vacuous assumptions | concrete witness failures |
| Insensitive theorem | targeted mutation rejection |

---

# 14. Assumptions under which the proof holds

The proof is not assumption-free. Its exact permitted assumptions were frozen before execution.

## 14.1 Object validity

- the input polynomial is a valid local object;
- the output is a valid 384-byte local object;
- selected indices are in their recorded range.

## 14.2 Non-aliasing

Input and output memory do not alias.

This matches the function contract and prevents unsupported self-overlap behaviour from being included in the theorem.

## 14.3 Canonical input domain

Every coefficient satisfies:

```text
0 ≤ coefficient < MLKEM_Q
```

For the frozen configuration:

```text
0 ≤ coefficient < 3329
```

This is the documented precondition of `mlk_poly_tobytes`.

## 14.4 T2 increment domain

The selected incremented coefficient was additionally constrained so that:

```text
coefficient + 1 < MLKEM_Q
```

T2 therefore does not claim behaviour for an increment from `q−1` to `q`.

## 14.5 Backend and configuration

- ML-KEM-768 preprocessing/configuration;
- portable C backend;
- CBMC model generated under the recorded macro set;
- no native serialization backend.

## 14.6 Finite-loop completeness

The loops are statically bounded:

```text
input coefficient loop: 256
serialization pair loop: 128
output-byte loop:        384
```

The proof commands used full unwind sets plus unwinding assertions. Within the frozen model and assumptions, this converts the bounded analysis into exhaustive coverage of all iterations of these finite loops.

## 14.7 What was not assumed

The harnesses did not assume:

- the expected output relation;
- a round-trip result;
- output equality;
- coefficient recovery;
- injectivity;
- canonicality of actual decoded output;
- false or contradictory conditions.

---

# 15. How our harnesses are truly distinct from the upstream harnesses

## 15.1 Comparison table

| Feature | Upstream `poly_tobytes` CBMC harness | Our clean-room semantic harnesses |
|---|---|---|
| Calls target function | Yes | Yes |
| Calls public wrapper | Some upstream harnesses | Mandatory for semantic claims |
| Explicit semantic assumptions | No harness-level assumptions | Canonical domain and theorem antecedents |
| Explicit byte-level assertions | None | 19 frozen semantic obligations |
| Full 384-byte oracle | No | T1.P6 |
| Independent arithmetic oracle | No | Yes |
| Two-execution relational proofs | No | T2, T4 |
| Independent arithmetic decoder | No | T3, T4 |
| `mlk_poly_frombytes` avoided | Not an oracle issue upstream | Explicitly prohibited in T3/T4 |
| Input-frame assertion | Not explicit in harness | T1.C1 |
| Output canaries | Not explicit | T1.C2/C3 |
| Non-vacuity witnesses | Not present | 36 total |
| Low-unwind negative controls | Not campaign-style evidence | 14 total |
| Targeted production mutants | Not present in audited harnesses | 17 total |
| Closure manifests and evidence freezing | Repository proof infrastructure differs | Family-level deterministic packages |
| Exact image and injectivity theorems | Not explicit | T3 and T4 |

## 15.2 Distinctness is semantic, not cosmetic

Our harnesses were not made distinct merely by changing variable names or file layout. They introduced new proof obligations and proof shapes:

- arithmetic specification refinement;
- relational successor analysis;
- range/image equivalence;
- invalid-codeword exclusion;
- block equivalence;
- full injectivity;
- independent-oracle restrictions;
- mutation-sensitive theorem closure.

## 15.3 We did not change the implementation to make the proof pass

The positive model used the source bound by:

```text
compress.c SHA-256:
9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad
```

Production mutants were separate copied files and were expected to fail. The authoritative source remained clean.

---

# 16. Non-vacuity and why deliberate failures were successes

A negative-control run commonly ended with:

```text
CBMC exit = 10
CPROVER status = FAILURE
```

This was accepted only when the failures were deliberately inserted witness assertions.

For example:

```c
mlk_poly_tobytes(output, &input);

/* Reaching this exact scenario should make this deliberately false. */
__CPROVER_assert(0, "named non-vacuity witness");
```

The intended interpretation was:

```text
witness assertion FAILURE
=
CBMC found a real execution reaching the intended state
```

The analyser required:

- every named witness present;
- every named witness `FAILURE`;
- no missing witness;
- no safety failure;
- no unwind failure;
- no error;
- no unknown;
- no unrelated non-success.

This prevented a proof from being accepted when assumptions accidentally made the target call or theorem scenario unreachable.

---

# 17. Mutation hardening and what it adds

A positive proof can be too weak even when all assertions succeed. Mutation hardening tests whether the theorem rejects plausible implementation defects.

For each mutant, the campaign required:

- the mutated copy compiled;
- the positive harness remained unchanged;
- the public wrapper and portable body remained reachable;
- all expected loops remained present;
- the target explicit property failed;
- no non-semantic safety property failed;
- no unwind failure occurred;
- no error or unknown occurred.

The 17 rejected mutants demonstrate that the theorem families are sensitive to:

- individual packed-bit corruption;
- wrong shifts;
- wrong masks;
- carry propagation errors;
- invalid codeword emission;
- missing canonical image elements;
- block collisions;
- full-array collisions.

Mutation rejection does not by itself prove correctness, but it substantially strengthens confidence that the assertions are meaningful and coupled to the production semantics.

---

# 18. Tool behaviour and limitations

## 18.1 CBMC 6.9.0 validation limitation

A T1 attempt using `--validate-goto-model` aborted on unreachable malformed symbols in the reduced graph. This was recorded as a CBMC 6.9.0 internal validation limitation, not as a theorem counterexample.

The accepted proof used:

- the exact reduced reachable model;
- model forensics;
- default SAT;
- complete unwinding;
- raw XML results.

## 18.2 Bitwuzla attempt

A Bitwuzla attempt returned 54 `ERROR/UNKNOWN` outcomes and was classified as incomplete tool execution. It was not presented as a theorem failure or success.

The authoritative successful backend for T1 was CBMC’s default SAT backend.

## 18.3 Bounded model checking boundary

CBMC proves assertions relative to:

- the C model;
- preprocessing choices;
- environmental assumptions;
- loop bounds;
- selected checks.

Because every target loop was finite and fully unwound with active unwinding assertions, the result is exhaustive for those loops in the frozen model. It is not a proof about every compiler, every CPU backend or every undefined external environment.

---

# 19. Did we really prove `mlk_poly_tobytes`?

## 19.1 The answer

**Yes—under the recorded scope and assumptions, we proved the portable `mlk_poly_tobytes` serialization semantics for the 19 frozen properties.**

The strongest precise statement is:

> For the unmodified `mlkem-native` source at commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`, in the frozen ML-KEM-768 portable-C CBMC configuration, for valid non-aliasing objects and every polynomial whose 256 coefficients are in `[0,3329)`, the public `mlk_poly_tobytes` wrapper reaches the actual `mlk_poly_tobytes_c` body and produces exactly the 384-byte arithmetic ByteEncode12 representation. Its successor/carry transitions are correct, its image is exactly the arrays with canonical decoded fields, and the mapping is arithmetically recoverable and injective.

## 19.2 Why this is a real functional proof

The proof is functional rather than merely memory-safety evidence because it establishes the relationship between every admissible input and the complete output.

In particular, T1.P6 is a universal byte-for-byte equality over:

```text
all 256 symbolic canonical coefficients
all 384 output bytes
```

T4.P4 separately establishes full injectivity over two symbolic canonical polynomials.

## 19.3 Why the statement must remain scoped

We did not prove:

- native AArch64 serialization;
- native x86-64 serialization;
- assembly/C equivalence;
- constant-time execution;
- microarchitectural side-channel absence;
- compiler preservation of source-level properties;
- out-of-domain coefficient behaviour;
- aliased input/output behaviour;
- `mlk_poly_frombytes`;
- all ML-KEM parameter-set builds by direct execution;
- complete ML-KEM correctness or security.

The frozen verification intent explicitly required separate preprocessing/source-equivalence evidence before extending the claim beyond the initial ML-KEM-768 configuration.

---

# 20. Novelty assessment

## 20.1 Novelty question

The novelty question must be divided into three different levels:

1. **mathematical novelty** — are the packing equations or injectivity facts new mathematics?
2. **formal-verification novelty** — has ML-KEM/Kyber implementation correctness or encoding correctness been formally proved before?
3. **repository-level artifact and methodology novelty** — does this exact CBMC campaign exist upstream or in the public artifacts we located?

These levels must not be conflated.

## 20.2 What is not novel

The following should **not** be claimed as novel:

- 12-bit coefficient packing itself;
- the ByteEncode12 definition;
- the fact that two 12-bit values fit into 24 bits;
- the elementary inverse arithmetic;
- the abstract mathematical fact that canonical 12-bit encoding is injective;
- the first formally verified Kyber implementation;
- the first formally verified ML-KEM implementation;
- the first formal treatment of encoding and decoding.

FIPS 203 defines ByteEncode and ByteDecode [R1]. Almeida et al. presented functionally verified Kyber implementations in EasyCrypt/Jasmin in 2023, including encoding/decoding modules [R6]. Their 2024 work provides machine-checked ML-KEM correctness/security and functionally equivalent Jasmin implementations [R7].

Therefore, a worldwide “first proof of polynomial serialization” claim would be false or at least unsupported.

## 20.3 What the upstream repository did not contain

At the audited commit, the official C source and headers documented that `mlk_poly_tobytes` implements ByteEncode12 and imposed memory/canonical-domain contracts, but the audited upstream CBMC harnesses did not contain explicit byte-level semantic assertions.

The upstream contract had:

```text
requires valid non-aliasing memory
requires canonical coefficients
assigns output memory
```

It did not have:

```text
ensures every output byte equals ByteEncode12
ensures exact canonical image
ensures no invalid codeword is emitted
ensures block/full injectivity
```

This establishes a concrete repository-level distinction.

## 20.4 Public novelty search performed

As of 29 July 2026, the review examined:

- the official FIPS 203 publication;
- the frozen `mlkem-native` C source and header;
- the audited upstream `poly_tobytes` CBMC harness set;
- official/public descriptions of `mlkem-native` verification;
- the peer-reviewed Kyber Episode IV work;
- the Crypto 2024 Kyber/ML-KEM Episode V work;
- searches for the exact theorem-family titles and combinations;
- the local cross-campaign audit covering eight prior clean-room roots.

No relevant public match was located for the exact combination:

```text
unmodified mlkem-native public C wrapper
+ CBMC
+ independent arithmetic ByteEncode12 oracle
+ successor/carry partition
+ exact canonical image iff theorem
+ invalid-codeword exclusion
+ arithmetic recoverability
+ block equality iff pair equality
+ full-polynomial injectivity
+ non-vacuity witnesses
+ deliberately insufficient unwinding
+ targeted production mutations
+ deterministic hash-frozen family closures
```

A search cannot prove non-existence. Unpublished work, unindexed repositories and differently worded artifacts may exist.

## 20.5 Defensible novelty classification

The strongest defensible classification is:

> **Repository-level semantic and structural CBMC novelty, with a mutation-hardened evidence methodology.**

The contribution is not a new cryptographic primitive or new encoding algorithm. It is a new verification artifact and case-study design applied to the unmodified `mlkem-native` portable C implementation.

## 20.6 Novelty potency

| Novelty dimension | Assessment | Reason |
|---|---|---|
| New cryptographic mathematics | Low | ByteEncode12 and its elementary inverse are established |
| New ML-KEM algorithm | None | No algorithm change was proposed |
| First verified Kyber/ML-KEM implementation | None | Prior EasyCrypt/Jasmin work exists |
| New theorem decomposition for this C target | Strong | T1–T4/19-obligation structure was not found upstream or in searched artifacts |
| New CBMC semantic harnesses for this repository target | Strong | Upstream audited harnesses were call/contract-oriented without these assertions |
| New mutation-hardened closure method | Moderate to strong | Positive, non-vacuity, unwind and semantic-mutation evidence were combined systematically |
| New reproducible case-study evidence package | Strong for an MSc artifact | Commit/source/model/result/hash binding is unusually detailed |
| Worldwide-first claim | Not justified | Search cannot establish universal absence |

## 20.7 Recommended novelty wording

The following wording is appropriate for the thesis:

> To the best of our knowledge, this case study provides a novel repository-level CBMC verification campaign for the portable `mlk_poly_tobytes` implementation in `mlkem-native`. The contribution is not the ByteEncode12 mathematics itself, nor the first formal verification of Kyber or ML-KEM. Its novelty lies in the commit-bound execution of the unmodified public C wrapper against 19 explicit semantic obligations spanning exact arithmetic refinement, carry transitions, canonical-image characterization, invalid-codeword exclusion, recoverability and injectivity, strengthened through non-vacuity witnesses, insufficient-unwind controls, targeted production mutations and deterministic evidence freezing.

## 20.8 Wording that must not be used

We should not write:

```text
This is the first proof that ML-KEM serialization is correct.
This is the first formally verified ML-KEM implementation.
No one has ever proved ByteEncode12.
We proved all of ML-KEM.
We proved the native assembly backends.
We proved constant-time behaviour.
```

---

# 21. Contribution to the thesis

The campaign contributes at least four thesis-relevant outcomes.

## 21.1 A concrete semantic-verification case study

The work moves beyond candidate harness generation and records a complete verification lifecycle against production cryptographic C code.

## 21.2 A deterministic integrity firewall

The proof process does not trust a harness merely because CBMC returns `SUCCESS`. It checks:

- target-call presence;
- source binding;
- model call graph;
- assertion inventory;
- unwinding;
- non-vacuity;
- mutation sensitivity;
- clean source status;
- evidence hashes.

This directly supports the thesis position that generated formal artifacts require deterministic review and tool-grounded validation.

## 21.3 Evidence of useful theorem decomposition

The T1–T4 structure demonstrates how one small serialization function can support multiple meaningful formal property classes without modifying the implementation.

## 21.4 Evidence about human correction and assurance effort

The campaign records important failure modes:

- a validator/tool limitation;
- an incomplete alternate-solver run;
- the need to distinguish expected witness failure from theorem failure;
- the need to distinguish a candidate closure from final closure;
- the need for external artifact inspection before publication promotion.

These are useful findings for an AI-assisted formal-methods thesis because they show where human judgment remains necessary.

---

# 22. Evidence ledger

## 22.1 Frozen identities

```text
Source commit:
af4c5abdd5958bdc65a03cd5ee86708264f93304

compress.c:
9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad

mlk_poly_tobytes_c exact function:
38e880b642ef083ec504175a60bc52e1269ce817749996cc60cf933cef2aca3a

Theorem-freeze manifest:
9179b28b0d81d8cbe9704c335d8e8a54d6618c959ff0715e6b745b5de3a1f726

Theorem registry:
42ed51ac4724311b1a04b7a08387eee5129dcbfb781b2b224be1da04f5476368

Overlap decision:
53a9fbece724cd3ee51dc1c8971f46f1a6e64d28476cfc5b6096240d3b7a1a1f

Scope and nonclaims:
a861211798b7740f7242393891f5d73708526a2115a530ea26c5a54147cd1fdf

Verification intent:
c38cccac9a595acf93801b5b30c6722378d24e92035aef77922ccf5252b65c7d
```

## 22.2 T1 evidence

```text
Positive harness:
e1a9c107f74cfc65a454027ff4a599bc40085745d581c2abf0fc4295820fb112

Positive reachable model:
494bd1a517fc45e1a8061edbb2598c3ae019cb822778421cbb9861fd9c34c57c

Positive XML:
4c1ce8608bb6e9b2b5680b780116eeee8287ceb3db02aa865bef72788678cf81

T1 candidate closure manifest:
31dd2064a295b1c45848f65a87e132eba1297307a27d9e61df1602350b56db80

External review archive:
15f68231bc634bc02a97cd8adbd13d6ff6e6d493061619e563d6793ea9e50a3d

External review record:
0f17164f535846885780dd3f607dd891847fe07d0e60f0d08ff2bf3fe2c84b23

Final T1 closure record:
9d3dbf059431dc1967348533e854821ffe0b1702bad987f8fab4b53897b57ef1
```

## 22.3 T2 evidence

```text
Positive harness:
f65576e37724ece6f4a2262c75cc2c0ca68ff6ecf39d21ffca1f9fa321b1c84a

Positive run manifest:
5bc815fc8b09867055f0428e0c0e29f0c1c6783d39ae05a964e76c5cb5622848

Non-vacuity harness:
d893fd500a8f7d939394929723d77f9baae797ad57e63dfa189aab2759264276

Non-vacuity run manifest:
b0e3d194dbaae44808ffb452d89b7070b7a3627979d4d1ca8c50529d4f19e8bd

Mutation manifest:
562f55f7d7f85b4d326eff052c07356c233c1065c739e82a93082da45ee36929

T2 closure manifest:
d48e942317dc2c81b352723fe5f6a0d8e570646f8363542d4009ce9a4a232c4c
```

## 22.4 T3 evidence

```text
T3 freeze extraction:
2f7656eee2f4bda2248de7b447262e47f8ec15624fb475592c8b761c7dd12d8f

Positive run:
07f5e26e761c433923827f53fedcb5f6aac7dfb8b68b40a21c8cdbf298b16f16

Integrity run:
72c14a6ab7ed7954c9e1b73aa43bac12a6046dcf603f03d152f4bd4ccce6f3ea

Mutation run:
07804645a4ca68cbc724d79aee562228827e84fe7330cd1c21ae0a5dcbc4e8de

T3 closure:
c2ab9467ca0c5b99085e43bbc22035a712e2a1bd0c91bc460a4fe00bf5491ec7
```

## 22.5 T4 evidence

```text
T4 freeze extraction:
09896745e52be39187e4ee89f3eba8d2ba7a8e73d893be2436d33d0a96f732cd

Positive run:
682a777c68432256b544c1404acd6bae2eac024391e7eae153bce748f66070a8

Integrity run:
660ad308edd7f7d6eefed9370fb8bf7474b7f4b857e389fc870cf9a025099aa5

Mutation run:
f72baf0e8a3622a24495db1e61ec3b1e899c229418d07047fb17c944e3239542

T4 closure:
009871c8d3e264fe1011eff2c36f46c7f05d7f2ee9784c76d156b729c90dbdaf
```

## 22.6 Combined package status

A combined 19-obligation package was created before the external T1 candidate was promoted:

```text
Combined candidate manifest:
f3e10fc1cb44e3459c71b1ebcbfa2e1d913e9b2d0fe19cec46a542dde400fe19

Combined candidate archive:
9b53e11701eb81f6c582173aee46f3ce9f00770a001f2d0769c1b79635f29906
```

That archive contains the older T1 **candidate** closure record. The theorem campaign is technically closed after the external review, but a final professor/publication archive should be regenerated once with:

```text
PBYTES_T1_EXTERNAL_ARTIFACT_REVIEW.txt
PBYTES_T1_CLOSURE_FINAL.txt
```

The old archive must therefore be labelled:

```text
Complete 19-obligation closure candidate archive
```

until that deterministic repackaging is completed.

---

# 23. Reproducibility checklist

A future reviewer should confirm:

- [ ] repository commit equals the frozen commit;
- [ ] `compress.c` hash equals the frozen source hash;
- [ ] theorem registry contains 19 labels;
- [ ] positive harness hashes match;
- [ ] positive model call graphs contain wrapper → portable body;
- [ ] no native backend occurs;
- [ ] no target contract replacement occurs;
- [ ] full unwind sets are recorded;
- [ ] unwinding assertions are enabled;
- [ ] every positive XML has only `SUCCESS`;
- [ ] every non-vacuity XML fails only named witnesses;
- [ ] every low-unwind control fails only unwind properties;
- [ ] every mutant fails its target semantic property;
- [ ] closure manifests verify;
- [ ] authoritative and detached source trees remain clean;
- [ ] the final combined archive contains the final—not candidate—T1 record.

---

# 24. Examiner-safe answers

## “Did you merely prove memory safety?”

No. The upstream repository already had strong contract and safety infrastructure. Our campaign added explicit universal relationships between symbolic inputs and all output bytes, as well as image and injectivity theorems.

## “Did you modify the function to make CBMC pass?”

No. Positive runs used the exact source hash. Mutations were isolated copied sources used only as negative controls.

## “Did you call the internal C body directly?”

No. The semantic harnesses called the public wrapper. GOTO model forensics confirmed reachability to the portable body.

## “Could the proof be vacuous?”

The non-vacuity campaigns deliberately placed false assertions after representative calls. All 36 witnesses failed exactly as intended, with no unexpected non-success.

## “Could an insufficient unwind still pass?”

The 14 low-unwind controls demonstrate the opposite. Reducing each relevant bound caused an unwind assertion failure.

## “Did you use `poly_frombytes` to prove `poly_tobytes`?”

No. T3 and T4 used an independent arithmetic decoder.

## “Does T1 make T2–T4 redundant?”

T1 is the primary exact refinement theorem, but T2–T4 provide independent relational, image and injectivity proof shapes. They reduce dependence on one oracle and make important consequences separately executable and mutation-sensitive.

## “Is the work globally novel?”

A global first-ever claim is not justified. Prior work formally verifies Kyber and ML-KEM implementations. The defensible novelty is the exact repository-level CBMC theorem decomposition and mutation-hardened evidence workflow for the unmodified `mlkem-native` C target.

## “Did you prove all parameter sets?”

The directly executed semantic campaign was frozen to ML-KEM-768. A broader claim requires separate preprocessing/source-equivalence evidence.

## “Did you prove native assembly?”

No. Native backend correctness is an explicit nonclaim.

---

# 25. Final conclusion

We did not treat `mlk_poly_tobytes` as correct merely because it was short, because it looked like standard Kyber code, or because an existing CBMC harness returned success.

We froze an exact source and theorem registry, audited the upstream proof boundary, created independent semantic harnesses, retained the real public wrapper and portable implementation, fully unwound every finite loop, proved 19 complementary obligations, demonstrated 36 reachable theorem scenarios, rejected 14 insufficient unwind configurations and rejected 17 targeted production mutants. The evidence was hash-bound and family closures were created.

The final technical conclusion is:

> The frozen portable `mlk_poly_tobytes` implementation is functionally correct for the T1–T4 theorem set under the canonical-input, non-aliasing, valid-object and ML-KEM-768 configuration assumptions. The implementation produces the exact ByteEncode12 bytes, has the exact canonical image, excludes invalid 12-bit codewords, permits arithmetic coefficient recovery and is injective on canonical polynomials.

The novelty conclusion is:

> The encoding mathematics and the general idea of formally verifying ML-KEM are not new. The strong contribution is the repository-level, public-wrapper CBMC campaign and its four-family, 19-obligation, non-vacuous, unwind-checked, mutation-hardened and hash-frozen evidence architecture. This is a defensible and potentially publishable MSc case-study contribution when presented with the stated scope and without a worldwide-first claim.

---

# References

**[R1]** National Institute of Standards and Technology (2024) *FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard*. Available at: https://doi.org/10.6028/NIST.FIPS.203 (Accessed: 29 July 2026).

**[R2]** pq-code-package (2026) *mlkem-native, `compress.h`, commit `af4c5abd…`*. The header identifies `mlk_poly_tobytes` as an implementation of FIPS 203 `ByteEncode_12` and records the canonical input contract. Available at: https://github.com/pq-code-package/mlkem-native/blob/af4c5abdd5958bdc65a03cd5ee86708264f93304/mlkem/src/compress.h (Accessed: 29 July 2026).

**[R3]** pq-code-package (2026) *mlkem-native, `compress.c`, commit `af4c5abd…`*. Available at: https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/mlkem/src/compress.c (Accessed: 29 July 2026).

**[R4]** Post-Quantum Cryptography Alliance (2025) ‘First stable release of mlkem-native v1 under PQ Code Package Project’. Available at: https://pqca.org/blog/2025/first-stable-release-of-mlkem-native-v1-under-pq-code-package-project/ (Accessed: 29 July 2026).

**[R5]** Becker, H., Chapman, R. and Kostic, D. (2026) ‘Verifying and optimizing post-quantum cryptography at Amazon’, *Amazon Science*, 7 April. Available at: https://www.amazon.science/blog/verifying-and-optimizing-post-quantum-cryptography-at-amazon (Accessed: 29 July 2026).

**[R6]** Almeida, J.B. et al. (2023) ‘Formally verifying Kyber Episode IV: Implementation correctness’, *IACR Transactions on Cryptographic Hardware and Embedded Systems*, 2023(3), pp. 164–193. https://doi.org/10.46586/tches.v2023.i3.164-193.

**[R7]** Bacelar Almeida, J. et al. (2024) ‘Formally Verifying Kyber: Episode V: Machine-checked IND-CCA security and correctness of ML-KEM in EasyCrypt’, in *Advances in Cryptology – CRYPTO 2024*, LNCS 14921, pp. 384–421. https://doi.org/10.1007/978-3-031-68379-4_12. Artifact: https://artifacts.iacr.org/crypto/2024/a3.

**[R8]** Kroening, D., Schrammel, P. and Tautschnig, M. (2023) ‘CBMC: The C Bounded Model Checker’. Available at: https://arxiv.org/abs/2302.02384 (Accessed: 29 July 2026).

---

## End of record
