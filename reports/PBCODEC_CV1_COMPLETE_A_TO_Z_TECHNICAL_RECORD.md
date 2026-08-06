# PBCODEC-CV1: Direct Cross-Function Composition Validation of `mlk_poly_tobytes` and `mlk_poly_frombytes`

## Complete A–Z technical record, proof interpretation, evidence boundary, distinctness analysis, and bounded novelty assessment

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Project:** MSc thesis case study — *AI-Assisted Formal Methods for Post-Quantum Cryptography Implementation*  
**Target repository:** `pq-code-package/mlkem-native`  
**Pinned source commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Pinned source tree:** `54805daff6a91a010c05467ea678117c42a71559`  
**Executed configuration:** portable ML-KEM-768 (`MLKEM_K=3`)  
**Verification tool:** CBMC 6.9.0  
**Campaign identifier:** `PBCODEC-CV1`  
**Campaign classification:** direct cross-function composition validation  
**Technical status:** **ACCEPTED**  
**Novelty-review date:** 30 July 2026  

---

## 1. Purpose and status of this record

This document records the complete development, execution, interpretation, integrity checking, and novelty assessment of the `PBCODEC-CV1` campaign. The campaign directly composed the real public `mlkem-native` polynomial byte encoder and decoder in the same CBMC models:

```text
mlk_poly_tobytes  →  mlk_poly_frombytes
mlk_poly_frombytes  →  mlk_poly_tobytes
```

The record is written as a machine-oriented technical account of the work itself. It is not a claim that the elementary 12-bit encoding mathematics was newly discovered.

The campaign was deliberately performed only after two separate per-function semantic-verification campaigns had been completed:

1. **PBYTES** — verification of `mlk_poly_tobytes` through four theorem families and nineteen semantic obligations; and
2. **PFB** — verification of `mlk_poly_frombytes` through four theorem families and eleven semantic obligations.

Those two campaigns independently established the encoder and decoder semantics. `PBCODEC-CV1` then addressed a different evidentiary question:

> Do the two real public production wrappers, with their real portable C bodies, compose correctly in one shared GOTO program under the legitimate domains of both functions?

The final answer is **yes**, subject to the pinned source, machine model, configuration, assumptions, and exclusions recorded below.

---

## 2. Executive verdict

### 2.1 Accepted technical result

At commit `af4c5abd…`, CBMC directly validated both legitimate polynomial byte-codec compositions:

```text
CV1.P1
canonical polynomial
→ real public mlk_poly_tobytes
→ real public mlk_poly_frombytes
→ identical polynomial
```

and

```text
CV1.P2
byte array in the canonical encoder image
→ real public mlk_poly_frombytes
→ real public mlk_poly_tobytes
→ identical byte array
```

Both positive GOTO models:

- called both real public wrappers;
- reached both real portable C bodies;
- preserved the required call order;
- completely unwound every relevant loop;
- enabled unwinding assertions;
- enabled memory, pointer, shift, division, conversion, and integer checks;
- used no function-contract replacement;
- used no loop-contract replacement;
- used no independent encoder or decoder as a substitute for either production call;
- left the production source unchanged; and
- returned `CPROVER_STATUS=SUCCESS` for the intended composition assertion.

### 2.2 Final count

```text
New independently investigated production functions: 0
New mathematical theorem families:                 0
Direct composition-validation families:            1
Direct composition obligations:                    2
Non-vacuity endpoint controls:                      2
Targeted integration bridge mutations:             2
```

`PBCODEC-CV1` is therefore **not** counted as:

- a twelfth independently investigated function;
- a fifth PBYTES theorem family;
- a fifth PFB theorem family;
- a newly discovered encoding theorem; or
- a worldwide-first mathematical result.

### 2.3 Final professor-safe statement

> At the frozen `mlkem-native` commit `af4c5abd…`, CBMC directly validated the composition of the real portable `mlk_poly_tobytes` and `mlk_poly_frombytes` public wrappers over their legitimate canonical domains. Canonical polynomials were preserved by serialization followed by deserialization, and byte strings in the canonical encoder image were preserved by deserialization followed by serialization. Both public wrappers and their portable C bodies were reachable, the relevant loops were completely unwound, production source was unchanged, and two targeted bridge mutations were detected. The result provides cross-function implementation-integration evidence that corroborates the independently established per-function semantic-verification campaigns.

---

## 3. Source identity and immutable verification boundary

### 3.1 Pinned repository state

The accepted result is permanently bound to:

```text
Repository: pq-code-package/mlkem-native
Commit:     af4c5abdd5958bdc65a03cd5ee86708264f93304
Tree:       54805daff6a91a010c05467ea678117c42a71559
Backend:    portable C
Parameter:  ML-KEM-768
CBMC:       6.9.0
```

The authoritative repository was checked before work began. The commit matched the expected commit and the authoritative tree was clean. A detached worktree was then created at exactly the same commit for proof-artifact construction and execution.

### 3.2 Production implementation under proof

The public functions were:

```c
mlk_poly_tobytes(...)
mlk_poly_frombytes(...)
```

The portable bodies reached by those wrappers were:

```c
mlk_poly_tobytes_c(...)
mlk_poly_frombytes_c(...)
```

The proof models included `mlkem/src/compress.c`, where the portable implementations reside.

### 3.3 Immutable production-code rule

The verification intent prohibited modification of production source. New files were added only under isolated proof directories in the detached worktree. Source diffs before and after positive execution, non-vacuity execution, and mutation execution were empty.

The accepted boundary is therefore:

```text
unchanged pinned production C
+ new external CBMC harnesses
+ new proof Makefiles
+ generated GOTO programs and evidence
```

It is not:

```text
modified C implementation
+ proof-friendly rewrite
+ stubbed target
+ replacement implementation
```

### 3.4 Why source pinning matters

Formal evidence is implementation-specific. A later commit may alter source, macros, contracts, wrappers, build flags, or generated GOTO structure. The accepted claim cannot silently migrate to another revision merely because the function names remain the same.

---

## 4. Mathematical and representation background

### 4.1 Fixed parameters

For the verified ML-KEM polynomial representation:

```text
MLKEM_N         = 256 coefficients
MLKEM_Q         = 3329
MLKEM_POLYBYTES = 384 bytes
```

Two 12-bit coefficient fields are stored in each three-byte block. For block index `i`, define:

```text
W[i] = b[3i] + 256·b[3i+1] + 65536·b[3i+2]

even(i) = W[i] mod 4096
odd(i)  = floor(W[i] / 4096)
```

The corresponding 24-bit packing equation is:

```text
W[i] = c[2i] + 4096·c[2i+1]
```

for coefficient fields in the raw 12-bit range `[0,4096)`.

### 4.2 Canonical polynomial domain

The production encoder `mlk_poly_tobytes` is called on canonical coefficients:

```text
0 ≤ p[i] < MLKEM_Q = 3329
```

This is smaller than the complete 12-bit range `[0,4096)`.

### 4.3 Raw decoder range

The decoder extracts raw 12-bit fields. Arbitrary 384-byte input can therefore produce coefficients in:

```text
0 ≤ decoded[i] < 4096
```

Some raw values lie in:

```text
3329 ≤ decoded[i] ≤ 4095
```

and are not valid inputs to the canonical production encoder contract.

### 4.4 Consequence for round-trip statements

Two different inverse statements must be distinguished.

#### Valid left inverse

For every canonical polynomial `p`:

```text
frombytes(tobytes(p)) = p
```

This is valid because `tobytes` accepts `p`, and its output is a canonical byte encoding that `frombytes` can decode.

#### Valid right inverse only on the canonical image

For every byte array `b` whose 256 decoded 12-bit fields are all below `q`:

```text
tobytes(frombytes(b)) = b
```

This is valid because the decoded polynomial satisfies the encoder precondition.

#### Invalid unrestricted statement

The following unrestricted claim is not valid:

```text
for every arbitrary 384-byte b:
    tobytes(frombytes(b)) = b
```

An arbitrary byte array may decode to a field in `[3329,4095]`. Passing that raw polynomial to the canonical encoder is outside the permitted domain. Restricting CV1.P2 to the canonical encoder image was therefore not a convenient weakening; it was necessary for a mathematically and contractually correct theorem.

---

## 5. Prior campaign I — PBYTES (`mlk_poly_tobytes`)

### 5.1 Purpose

PBYTES established property-specific functional correctness of the real portable encoder. It contained four theorem families and nineteen frozen semantic obligations.

### 5.2 PBYTES-T1 — exact arithmetic `ByteEncode12` refinement

T1 answered:

> What exact bytes does the implementation produce?

An independent arithmetic oracle used division and remainder rather than copying the implementation's shift-and-mask expressions.

| Obligation | Meaning |
|---|---|
| T1.P1 | exact low byte of the even coefficient |
| T1.P2 | exact high nibble of the even coefficient |
| T1.P3 | exact low nibble of the odd coefficient |
| T1.P4 | exact high byte of the odd coefficient |
| T1.P5 | exact 24-bit packed-word equality |
| T1.P6 | complete 384-byte arithmetic-oracle equality |

T1 was the primary specification-refinement theorem family.

### 5.3 PBYTES-T2 — successor and carry-transition partition

T2 answered:

> Does a one-step coefficient change propagate through the precise byte boundary expected by the representation?

| Obligation | Meaning |
|---|---|
| T2.P1 | even coefficient increment without low-byte carry |
| T2.P2 | even coefficient `255 → 256` carry transition |
| T2.P3 | odd coefficient increment without nibble carry |
| T2.P4 | odd coefficient `15 → 16` nibble-to-byte carry |

These are relational properties between two executions. They exercise different proof structure from a direct oracle equality.

### 5.4 PBYTES-T3 — exact canonical image and invalid-codeword exclusion

T3 answered:

> Which 384-byte strings can the canonical production encoder produce?

| Obligation | Meaning |
|---|---|
| T3.P1 | every produced even 12-bit field is below `q` |
| T3.P2 | every produced odd 12-bit field is below `q` |
| T3.P3 | every canonical 24-bit block is realizable |
| T3.P4 | a block with either invalid field is not realizable |
| T3.P5 | a full byte array is in the image iff all 256 fields are canonical |

This family supplied the exact domain later used by CV1.P2.

### 5.5 PBYTES-T4 — arithmetic recoverability and collision freedom

T4 answered:

> Is the encoding information-preserving on canonical polynomials?

| Obligation | Meaning |
|---|---|
| T4.P1 | arithmetic recovery of the even coefficient |
| T4.P2 | arithmetic recovery of the odd coefficient |
| T4.P3 | block equality iff coefficient-pair equality |
| T4.P4 | full canonical-polynomial injectivity |

### 5.6 Why PBYTES did not stop after T1

T1 was already strong enough to imply many later facts, but stopping there would have concentrated assurance in one direct oracle and one proof shape. A transcription error in the oracle, a weak diagnostic, or an accidentally shared expression pattern could reduce confidence.

T2 added execution-to-execution dependency and boundary-transition evidence. T3 made the output language and invalid-codeword exclusion explicit. T4 made information preservation and collision freedom explicit.

The four families were therefore not selected to inflate the theorem count. They represented four different correctness dimensions:

```text
T1 — exact mapping
T2 — local transition behaviour
T3 — exact output image
T4 — information preservation and injectivity
```

### 5.7 What PBYTES did not prove

PBYTES did not directly execute production `mlk_poly_frombytes` as its semantic oracle. In particular, its T3 and T4 arithmetic decoder was independent and did not call the production decoder. This was necessary to avoid circular verification of the encoder by assuming the correctness of the decoder.

---

## 6. Prior campaign II — PFB (`mlk_poly_frombytes`)

### 6.1 Purpose

PFB established property-specific functional correctness of the real portable decoder as a raw 12-bit unpacker. It contained four theorem families and eleven frozen semantic obligations.

### 6.2 PFB-T1 — exact raw-decoding semantics

T1 answered:

> What exact coefficient values does the decoder produce from an arbitrary block?

| Obligation | Meaning |
|---|---|
| T1.P1 | `r[2i] = W[i] mod 4096` |
| T1.P2 | `r[2i+1] = floor(W[i]/4096)` |

The supporting conservation identity was:

```text
r[2i] + 4096·r[2i+1] = W[i]
```

### 6.3 PFB-T2 — exact bit routing and block locality

T2 answered:

> Does every input bit influence exactly the intended output field, while unrelated blocks remain unchanged?

| Obligation | Meaning |
|---|---|
| T2.P1 | first-byte bit route |
| T2.P2 | second-byte low-nibble route |
| T2.P3 | second-byte high-nibble route |
| T2.P4 | third-byte bit route |
| T2.P5 | arbitrary one-block locality |

### 6.4 PFB-T3 — arbitrary differential conservation

T3 answered:

> Are arbitrary differences conserved without collision inside the raw block mapping?

| Obligation | Meaning |
|---|---|
| T3.P1 | packed-output XOR conservation |
| T3.P2 | input block differs iff output coefficient pair differs |

### 6.5 PFB-T4 — two-sided inverse over the complete raw 12-bit domain

T4 used an **independent arithmetic raw encoder**, not production `mlk_poly_tobytes`.

| Obligation | Meaning |
|---|---|
| T4.P1 | arbitrary 384 bytes → real decoder → independent raw encoder → identical bytes |
| T4.P2 | arbitrary raw polynomial in `[0,4096)` → independent raw encoder → real decoder → identical polynomial |

This established a full bijection between:

```text
all 384-byte strings
↔
all 256-coefficient raw polynomials in [0,4096)
```

### 6.6 Why PFB did not stop after T1

T1 gave direct exact equations, but the campaign did not rely only on one oracle shape. T2 exposed routing and locality. T3 exposed global differential conservation and injectivity. T4 made both inverse directions executable over complete raw domains with an independent arithmetic encoder.

The assurance progression was:

```text
T1 — exact values
T2 — exact dependency structure
T3 — arbitrary differential preservation
T4 — complete raw-domain bijection
```

### 6.7 What PFB did not prove

PFB did not establish that production `mlk_poly_tobytes` was correct. It also did not claim that `mlk_poly_frombytes` by itself performs complete FIPS modular normalization into `[0,q)`. It proved the raw 12-bit unpacking semantics under the eleven stated obligations.

---

## 7. The remaining gap after both T1–T4 campaigns

After PBYTES and PFB were accepted, the mathematical round-trip results were already logical consequences of stronger independent refinement evidence:

- PBYTES established that the real encoder equals the intended arithmetic encoding on canonical polynomials.
- PFB established that the real decoder equals the intended raw arithmetic decoding.
- The arithmetic encoder and decoder are inverse on the relevant domains.

Therefore, `PBCODEC-CV1` was **not needed to invent or rescue the mathematics**.

However, a separate implementation-integration gap remained. The prior positive harnesses did not place both real public wrappers into the same composition model:

- PBYTES deliberately avoided production `mlk_poly_frombytes` as the oracle.
- PFB deliberately avoided production `mlk_poly_tobytes` as the oracle.
- The audited upstream CBMC harnesses were function-oriented and did not provide the same direct two-wrapper semantic composition.

A logical consequence on paper is not identical to directly executing the two concrete wrappers together. Direct composition can detect or rule out problems such as:

- incorrect wrapper-to-body wiring;
- a mismatch between the assumptions used by the separate campaigns;
- build-configuration disagreement;
- source-selection or preprocessing mismatch;
- data-layout disagreement at the interface;
- accidental oracle substitution;
- model construction that includes the correct function names but not the expected bodies; or
- a harness that proves each function against a model but never verifies the production-to-production bridge.

This was the precise motivation for `PBCODEC-CV1`.

---

## 8. Why this direct composition campaign was specifically chosen

### 8.1 High-value integration boundary

Serialization and deserialization are a natural interface boundary. They convert between two representations of the same mathematical information:

```text
canonical polynomial representation
↔
384-byte canonical representation
```

An error at this boundary can invalidate public-key, secret-key, or ciphertext processing even when surrounding arithmetic is correct.

### 8.2 Both sides were independently mature

The encoder and decoder were selected for direct composition only after their separate campaigns had reached a strong state:

```text
PBYTES: 4 families / 19 obligations
PFB:    4 families / 11 obligations
```

This sequencing prevented a passing round trip from hiding two mutually compensating errors. A round trip alone can be weak: two wrong functions may invert each other. The separate independent arithmetic refinements were therefore completed first.

### 8.3 The composition is understandable and examiner-auditable

The theorem has a clean representation-level meaning and explicit domains. A professor can inspect:

- the encoder precondition;
- the decoder raw range;
- the canonical image predicate;
- the two calls;
- the final equality; and
- the mutation controls.

### 8.4 The campaign closes an assurance layer rather than inflating function count

The result is a cross-function integration artifact. It increases evidence depth, not the number of independently studied functions. This is methodologically stronger than relabelling the same two functions as a new function case study.

### 8.5 Purpose in the thesis

`PBCODEC-CV1` demonstrates how an AI-assisted candidate-artifact workflow can be placed behind a deterministic integrity boundary:

1. freeze verification intent;
2. bind the exact source;
3. generate candidate harnesses;
4. inspect the GOTO call graph and loops;
5. run CBMC as authority;
6. prove non-vacuity;
7. kill targeted mutants;
8. hash and freeze evidence; and
9. restrict the final claim to what the evidence actually supports.

The campaign is therefore valuable both as a verification result and as a case study in trustworthy formal-artifact evaluation.

---

## 9. Frozen verification intent

The verification intent was frozen before acceptance.

### 9.1 Classification

```text
Classification: direct production-to-production composition validation
New function: no
New mathematical encoding theorem: no
Fifth PBYTES family: no
Fifth PFB family: no
Worldwide-first result: no
```

### 9.2 Required target binding

```text
Public encoder:        mlk_poly_tobytes
Portable encoder body: mlk_poly_tobytes_c
Public decoder:        mlk_poly_frombytes
Portable decoder body: mlk_poly_frombytes_c
```

### 9.3 Prohibited proof shortcuts

The intent prohibited:

- production source modification;
- function-contract replacement;
- loop-contract application as a substitute for loop execution;
- stubbing either target;
- replacing either production call with an independent oracle;
- assuming the final equality;
- assuming unreachable paths;
- weakening CV1.P2 to an arbitrary-byte statement that violates the encoder domain; and
- accepting a success without complete loop unwinding.

---

## 10. CV1.P1 — canonical polynomial encode/decode round trip

### 10.1 Theorem statement

For every polynomial `p` satisfying:

```text
∀i ∈ [0,255]: 0 ≤ p[i] < MLKEM_Q
```

execution of:

```text
mlk_poly_tobytes(encoded, &p)
mlk_poly_frombytes(&recovered, encoded)
```

must satisfy:

```text
∀i ∈ [0,255]: recovered[i] = p[i]
```

### 10.2 Harness structure

The accepted positive harness:

1. declared a nondeterministic input polynomial;
2. assumed every coefficient was canonical;
3. selected an arbitrary symbolic coefficient index;
4. called the real public encoder;
5. called the real public decoder on the produced bytes; and
6. asserted equality at the arbitrary index.

The key code was:

```c
__CPROVER_assume(coefficient_index < MLKEM_N);

for (i = 0u; i < MLKEM_N; i++)
{
  __CPROVER_assume(input.coeffs[i] >= 0);
  __CPROVER_assume(input.coeffs[i] < MLKEM_Q);
}

mlk_poly_tobytes(encoded, &input);
mlk_poly_frombytes(&recovered, encoded);

__CPROVER_assert(
    recovered.coeffs[coefficient_index] ==
        input.coeffs[coefficient_index],
    "PBCODEC-CV1.P1 canonical polynomial survives real encode-decode");
```

### 10.3 Why one symbolic index proves all coefficients

`coefficient_index` was nondeterministic and constrained only by:

```text
coefficient_index < MLKEM_N
```

CBMC had to prove the assertion for every represented value of that index. A counterexample at any coefficient would have been available to the solver. Consequently, the arbitrary-index assertion represents coefficient-wise universal equality across all 256 positions.

### 10.4 Model binding

The GOTO inspection showed:

```text
PUBLIC_TOBYTES_CALL_COUNT=1
PUBLIC_FROMBYTES_CALL_COUNT=1
PORTABLE_TOBYTES_BODY_CALL_COUNT=1
PORTABLE_FROMBYTES_BODY_CALL_COUNT=1
```

The public call order was:

```text
CALL mlk_poly_tobytes(...)
CALL mlk_poly_frombytes(...)
```

The relevant loops were:

```text
harness.0
mlk_poly_tobytes_c.0
mlk_poly_frombytes_c.0
```

### 10.5 Unwinding

The exact unwind set was:

```text
harness.0:257,
mlk_poly_tobytes_c.0:129,
mlk_poly_frombytes_c.0:129
```

This covers:

- the 256-coefficient canonicality loop; and
- the 128 two-coefficient production loops in the encoder and decoder.

Unwinding assertions were enabled.

### 10.6 Result

```text
Property ID:      harness.assertion.1
Target label:     PBCODEC-CV1.P1
Target status:    SUCCESS
CBMC exit code:   0
CPROVER status:   SUCCESS
Complete XML:     182 SUCCESS / 0 FAILURE
```

**CV1.P1 was proved in the recorded model.**

---

## 11. CV1.P2 — canonical byte-image decode/encode round trip

### 11.1 Theorem statement

For every 384-byte array `b` such that every decoded 12-bit field is below `q`, execution of:

```text
mlk_poly_frombytes(&decoded, b)
mlk_poly_tobytes(reencoded, &decoded)
```

must satisfy:

```text
∀j ∈ [0,383]: reencoded[j] = b[j]
```

### 11.2 Canonical-image predicate

For each three-byte block:

```text
W = b0 + 256·b1 + 65536·b2
x = W mod 4096
y = floor(W/4096)
```

the harness assumed only:

```text
x < MLKEM_Q
y < MLKEM_Q
```

This predicate characterizes the valid image of the canonical encoder. It does not compute the expected final bytes.

### 11.3 Harness structure

The accepted harness:

1. declared a completely nondeterministic 384-byte input;
2. imposed the canonical-image predicate for all 128 blocks;
3. selected an arbitrary symbolic byte index;
4. called the real public decoder;
5. called the real public encoder on the decoded polynomial; and
6. asserted equality at the arbitrary byte index.

The key code was:

```c
__CPROVER_assume(byte_index < MLKEM_POLYBYTES);

for (block_index = 0u;
     block_index < (MLKEM_N / 2u);
     block_index++)
{
  packed_word =
      (uint32_t)input[3u * block_index] +
      UINT32_C(256) *
          (uint32_t)input[3u * block_index + 1u] +
      UINT32_C(65536) *
          (uint32_t)input[3u * block_index + 2u];

  even_field = packed_word % UINT32_C(4096);
  odd_field = packed_word / UINT32_C(4096);

  __CPROVER_assume(even_field < MLKEM_Q);
  __CPROVER_assume(odd_field < MLKEM_Q);
}

mlk_poly_frombytes(&decoded, input);
mlk_poly_tobytes(reencoded, &decoded);

__CPROVER_assert(
    reencoded[byte_index] == input[byte_index],
    "PBCODEC-CV1.P2 canonical bytes survive real decode-encode");
```

### 11.4 Why this is not circular

The arithmetic expressions determine only whether a symbolic input belongs to the canonical image. They do not generate `reencoded`, calculate the asserted expected byte, or replace either real function.

The equality being proved remains:

```text
production tobytes(production frombytes(input)) = input
```

### 11.5 Why one symbolic index proves all bytes

`byte_index` was nondeterministic and constrained only to the valid output range. CBMC therefore had to prove equality for every byte position. Any mismatching byte at any symbolic input would provide a counterexample.

### 11.6 Model binding

The GOTO model showed:

```text
PUBLIC_TOBYTES_CALL_COUNT=1
PUBLIC_FROMBYTES_CALL_COUNT=1
PORTABLE_TOBYTES_BODY_CALL_COUNT=1
PORTABLE_FROMBYTES_BODY_CALL_COUNT=1
```

The public call order was:

```text
CALL mlk_poly_frombytes(...)
CALL mlk_poly_tobytes(...)
```

The relevant loops were:

```text
harness.0
mlk_poly_frombytes_c.0
mlk_poly_tobytes_c.0
```

### 11.7 Unwinding

The exact unwind set was:

```text
harness.0:129,
mlk_poly_frombytes_c.0:129,
mlk_poly_tobytes_c.0:129
```

The harness loop covers 128 blocks, and each production loop covers 128 coefficient pairs.

### 11.8 Result

```text
Property ID:      harness.assertion.1
Target label:     PBCODEC-CV1.P2
Target status:    SUCCESS
CBMC exit code:   0
CPROVER status:   SUCCESS
Complete XML:     191 SUCCESS / 0 FAILURE
```

**CV1.P2 was proved on the canonical byte-image domain in the recorded model.**

---

## 12. How the new harness is truly distinct from upstream `mlkem-native`

### 12.1 Upstream proof orientation

The public `mlkem-native` CBMC documentation describes its C verification as proving absence of certain undefined-behaviour classes. It states that proofs are organized by function, specifications are embedded as contracts and loop annotations in production source, and harnesses are boilerplate rather than additional specifications.

The upstream effort is important and high assurance. The distinction is not that upstream verification is weak. The distinction is that the new campaign asks and encodes a different semantic and cross-function question.

### 12.2 Distinct verification intent

The new harnesses explicitly assert two representation identities:

```text
frombytes(tobytes(p)) = p
```

and

```text
tobytes(frombytes(b)) = b
```

on their correct domains.

The assertions are new harness-level semantic obligations, not merely calls made to exercise a function contract.

### 12.3 Distinct cross-function structure

Each positive CV1 harness calls **two** production wrappers in a prescribed order. The campaign is not function-local:

```text
P1: encoder wrapper → decoder wrapper
P2: decoder wrapper → encoder wrapper
```

This makes the data bridge itself part of the verified program.

### 12.4 Distinct source of specification

CV1 uses the independently frozen PBYTES and PFB semantics to define legitimate domains and interpret the result. It does not simply restate an existing upstream postcondition.

### 12.5 No production-code adaptation

The distinctness comes from the verification context surrounding unchanged production code. The C implementation was not rewritten, simplified, or specialized for the proof.

### 12.6 No oracle substitution

Unlike the independent per-function campaigns, CV1 intentionally uses no independent codec oracle in the final composition. Both legs are the real production functions.

### 12.7 Distinct evidence controls

The campaign adds an evidence architecture not supplied by a boilerplate call harness alone:

- frozen intent;
- commit and tree binding;
- authoritative-tree cleanliness checks;
- detached-worktree isolation;
- GOTO public-call counting;
- portable-body call counting;
- explicit call-order inspection;
- exact loop inventory;
- exact property-label-to-ID mapping;
- complete XML result preservation;
- deliberate endpoint non-vacuity failures;
- two targeted bridge mutations;
- zero-unrelated-failure acceptance conditions;
- deterministic manifests;
- archive hashing; and
- claim/non-claim closure documentation.

### 12.8 Repository-relative distinctness conclusion

The new harness is genuinely distinct because it adds a direct semantic composition specification and a cross-function execution pattern that were not found in the audited upstream artifacts at the pinned revision. It does not claim that the function implementations themselves are new.

---

## 13. Assumptions under which the results hold

Formal claims are meaningful only with explicit assumptions.

### 13.1 Common configuration assumptions

- the pinned commit and tree are the implementation under consideration;
- the portable C backend is selected;
- the executed parameter setting is ML-KEM-768;
- CBMC's recorded C machine model and object model are used;
- `CBMC_OBJECT_BITS=9` is sufficient for the represented objects;
- the included source and preprocessing configuration match the recorded GOTO programs; and
- the solver and CBMC execution complete without `ERROR` or `UNKNOWN` results.

### 13.2 Object-validity assumptions

- each polynomial object is a valid `mlk_poly` object;
- each byte array has exactly `MLKEM_POLYBYTES` valid bytes;
- local objects are live for the duration of each call;
- the interfaces are used with the pointer and non-aliasing conditions required by the production functions; and
- symbolic indices are constrained to their valid ranges.

### 13.3 CV1.P1 assumptions

```text
∀i: 0 ≤ input.coeffs[i] < MLKEM_Q
coefficient_index < MLKEM_N
```

These assumptions establish the legitimate encoder input domain and select an arbitrary valid observation point.

### 13.4 CV1.P2 assumptions

```text
byte_index < MLKEM_POLYBYTES
```

and, for every three-byte block:

```text
W mod 4096 < MLKEM_Q
floor(W/4096) < MLKEM_Q
```

These assumptions establish membership in the canonical encoder image.

### 13.5 Assumptions that were not made

The harnesses did not assume:

- the round-trip result;
- equality of input and output;
- that either production function is correct;
- that the target assertion is unreachable;
- `assume(false)`;
- a fixed test vector for the positive proof;
- a particular coefficient value in P1;
- a particular canonical byte array in P2;
- replacement-function correctness;
- contract postconditions in place of the target bodies; or
- native-backend equivalence.

---

## 14. CBMC proof method

### 14.1 Why this is model checking rather than ordinary testing

The positive inputs were nondeterministic. CBMC encoded the finite C execution space and assertion conditions as bit-vector formulas. It did not execute a short list of selected polynomials or byte arrays.

For P1, the model represented arbitrary canonical values for all 256 coefficients and an arbitrary valid coefficient index.

For P2, the model represented arbitrary 384-byte arrays satisfying the canonical-image predicate and an arbitrary valid byte index.

### 14.2 Complete fixed loop bounds

All relevant loops have fixed finite bounds:

```text
256 coefficients
128 coefficient pairs / three-byte blocks
```

The exact loop IDs were inspected from the generated GOTO models, and sufficient unwind bounds were applied. Unwinding assertions were enabled, preventing an insufficient bound from being silently treated as a proof.

### 14.3 Safety checks

The direct executions enabled:

- bounds checks;
- pointer checks;
- pointer-overflow checks;
- signed-overflow checks;
- unsigned-overflow checks;
- conversion checks;
- division-by-zero checks;
- undefined-shift checks;
- floating-point overflow and NaN checks where applicable; and
- all user assertions.

### 14.4 Authority hierarchy

The evidence hierarchy was:

1. pinned production source and hashes;
2. generated GOTO programs;
3. CBMC XML result files;
4. exact property inventories and label mappings;
5. call and loop dumps;
6. parsed summaries;
7. terminal transcripts; and
8. narrative reports.

CBMC results, not an LLM statement, were authoritative.

---

## 15. Non-vacuity and endpoint reachability

### 15.1 Why a successful assertion can still be vacuous

A proof can return success if assumptions are contradictory or if the intended post-call location is unreachable. Positive success alone therefore does not demonstrate that the composition endpoint was exercised.

### 15.2 Non-vacuity harness

A concrete canonical polynomial was created with representative boundary-sensitive values:

```text
0, 1, 15, 16, 255, 256, MLKEM_Q-1
```

The harness executed:

```text
mlk_poly_tobytes
mlk_poly_frombytes
assert(false)  // NV1
mlk_poly_tobytes
assert(false)  // NV2
```

### 15.3 Expected and observed outcome

The correct control outcome was top-level `FAILURE`, because both labelled false assertions had to be reachable.

```text
NV1 → harness.assertion.1 → FAILURE
NV2 → harness.assertion.2 → FAILURE
CBMC exit code              → 10
CPROVER status              → FAILURE
```

The complete non-vacuity XML contained:

```text
178 SUCCESS
2 intended FAILURE
0 unexpected FAILURE
```

The two failures were therefore successful integrity evidence.

---

## 16. Mutation hardening

### 16.1 Purpose

Mutation hardening tested whether the composition assertion was sensitive to meaningful corruption of the bridge between the real functions. A proof that still succeeds after the bridge is deliberately corrupted may be tautological, disconnected from the dataflow, or too weak.

The production C implementation was not mutated. The mutations were isolated in harness-side bridge values.

### 16.2 M1 — corrupt encoded bridge

Execution shape:

```text
real mlk_poly_tobytes
→ encoded[0] ^= 1
→ real mlk_poly_frombytes
→ original P1 equality assertion
```

The mutation changed the serialized data after the real encoder and before the real decoder.

Observed result:

```text
Target:              PBCODEC-CV1.M1
Property:            harness.assertion.1
Target status:       FAILURE
Total properties:    183
Successes:           182
Failures:            1
Unrelated failures:  0
CBMC exit code:      10
CPROVER status:      FAILURE
Mutant killed:       YES
```

### 16.3 M2 — corrupt decoded bridge

Execution shape:

```text
real mlk_poly_frombytes
→ deliberately change decoded.coeffs[0]
→ retain value in canonical range
→ real mlk_poly_tobytes
→ original P2 byte-equality assertion
```

The mutation was designed so the encoder precondition remained valid. The changed coefficient was guaranteed to differ from the original:

```c
if (decoded.coeffs[0] == 0)
  decoded.coeffs[0] = 1;
else
  decoded.coeffs[0] = decoded.coeffs[0] - 1;
```

Observed result:

```text
Target:              PBCODEC-CV1.M2
Property:            harness.assertion.1
Target status:       FAILURE
Total properties:    193
Successes:           192
Failures:            1
Unrelated failures:  0
CBMC exit code:      10
CPROVER status:      FAILURE
Mutant killed:       YES
```

### 16.4 Interpretation

The mutation evidence establishes that:

- P1 depends on the bytes actually passed from encoder to decoder;
- P2 depends on the polynomial actually passed from decoder to encoder;
- the assertions are not disconnected from the bridge;
- the expected public wrappers and portable bodies are present in the mutant models; and
- a targeted semantic fault is detected without triggering unrelated safety failures.

Mutation killing does not independently prove the positive theorem, but it materially strengthens confidence in the relevance and sensitivity of the proof harness.

---

## 17. Scope of the round-trip proof

### 17.1 Direct answer

**Yes.** Two real production-wrapper round-trip properties were proved by CBMC, exhaustively for the finite domains represented by the harnesses and under the recorded assumptions and configuration.

### 17.2 Exact strength of “proved”

The accepted statement is:

```text
For every canonical 256-coefficient polynomial represented by the
ML-KEM-768 portable C model, the real public encoder followed by the
real public decoder returns the same polynomial.
```

and:

```text
For every 384-byte string in the canonical encoder image, the real
public decoder followed by the real public encoder returns the same
byte string.
```

### 17.3 Why this is not merely a set of passing tests

The inputs and selected indices were symbolic. CBMC searched for a counterexample over all represented canonical polynomials or canonical-image byte arrays. Complete fixed-loop unwinding was checked. The positive results therefore mean that no counterexample exists in the recorded finite model, not merely that selected examples passed.

### 17.4 Why the result is not circular

The direct composition uses both real functions, but it was not the only evidence of their semantics. It was performed after independent per-function arithmetic refinements. This ordering prevents the main correctness argument from being only:

```text
two functions invert each other, therefore each is individually correct
```

That inference would be invalid because two wrong functions can be mutual inverses. The full assurance chain is instead:

```text
real encoder = independent arithmetic encoder
real decoder = independent arithmetic decoder
arithmetic encoder/decoder have the expected inverse structure
real encoder and real decoder also compose directly
```

### 17.5 Why CV1.P2 is not proved for arbitrary bytes

An arbitrary byte array can decode to noncanonical raw coefficients. Such a polynomial is outside the production encoder's stated domain. Claiming arbitrary-byte `tobytes(frombytes(b)) = b` would therefore be false or contract-invalid.

The canonical-image restriction is part of the theorem's truth conditions.

### 17.6 What “proved” does not mean

The result does not mean:

- every possible property of both functions was formalized;
- the native or assembly backends were proved by this campaign;
- every parameter-set preprocessing configuration was directly executed;
- compiler-generated machine code was proved equivalent to the GOTO model;
- constant-time behaviour was proved;
- the complete ML-KEM algorithm was proved correct; or
- the result automatically holds for another commit.

---

## 18. Rationale for continuing beyond PBYTES/PFB T1, T2, T3, and T4

This question has two layers.

### 18.1 Why each per-function campaign did not stop at T1

T1 supplied exact arithmetic semantics, but a single oracle shape creates assurance concentration. Later families supplied differently structured relational, image, injectivity, and inverse evidence.

### 18.2 Rationale for continuing beyond T2

T2 demonstrated precise local dependencies, carry transitions, bit routes, and locality. Those properties do not by themselves characterize the complete global mapping or its image.

### 18.3 Rationale for continuing beyond T3

T3 supplied global image or differential information. For the encoder, an image theorem alone cannot guarantee that each polynomial maps to the correct canonical byte string; a wrong permutation could share the same image. For the decoder, injectivity or differential conservation alone does not establish surjectivity or a right inverse over the complete raw domain.

### 18.4 Why T4 was needed

T4 made information preservation explicit:

- PBYTES-T4 established arithmetic recoverability and injectivity on canonical polynomials.
- PFB-T4 established a two-sided inverse between all byte strings and all raw 12-bit polynomials using an independent arithmetic encoder.

T4 was the correct per-function algebraic closure.

### 18.5 Rationale for continuing after both T4 campaigns

After T4, the individual semantic claims were strong, but the exact real-to-real production bridge had not been directly executed in a shared model. `PBCODEC-CV1` was chosen to close that implementation-integration evidence gap.

The new campaign did not add new mathematics. It added direct evidence that:

```text
real wrapper A
→ real shared representation
→ real wrapper B
```

works with the exact build, source, bodies, assumptions, and model configuration.

### 18.6 Completion criterion after CV1

Once both directions had passed, both endpoints were shown reachable, and both bridge mutants were killed with no unrelated failures, further codec composition theorem families would mostly restate the same inverse relationship.

Meaningful further work would require a genuinely new scope, such as:

- all parameter-set preprocessing variants;
- native-backend equivalence for these wrappers;
- compiler-to-binary equivalence;
- public-key or ciphertext validation paths;
- malformed-input rejection at higher protocol layers;
- constant-time analysis; or
- an end-to-end K-PKE/ML-KEM functional theorem.

Those should be separate campaigns rather than theorem-count inflation.

---

## 19. Fail-closed execution history

The campaign did not convert every script completion into a proof success. Infrastructure and evidence defects were classified and repaired before acceptance.

### 19.1 Initial Makefile-generation failure

The first build script attempted to assign to Bash's readonly `UID` variable. The three Makefiles were not created, `make` returned exit code 2, and no GOTO binary existed.

Classification:

```text
INFRASTRUCTURE_SETUP_FAILURE
NOT_A_CBMC_COUNTEREXAMPLE
NOT_A_THEOREM_FAILURE
```

The existing run and worktree were repaired in place. Production source was unchanged.

### 19.2 Initial target-status parser failure

The first freeze parser expected human-readable descriptions directly inside each XML `<result>` element. CBMC's XML keyed the results by property IDs, while the labels were available in `show_properties.txt`.

The response was:

- no change to theorem results;
- no CBMC rerun;
- map each label from `show_properties.txt` to its property ID; and
- retrieve the exact status from XML.

This produced:

```text
P1  harness.assertion.1  SUCCESS
P2  harness.assertion.1  SUCCESS
NV1 harness.assertion.1  FAILURE
NV2 harness.assertion.2  FAILURE
```

### 19.3 Mutation Bash comment failure

A C-style `/* ... */` comment remained inside a Bash function. Shell glob expansion interpreted `/*` and attempted to execute `/bin`, producing exit status 126.

Classification:

```text
SCRIPT_COMMENT_FAILURE
MUTATION_PROOF_NOT_ATTEMPTED
MUTANT_NOT_CLASSIFIED_AS_SURVIVING
```

The script was corrected to use `#` comments and rerun.

### 19.4 First closure-package completeness defect

The first closure candidate included mutation XML results, exact statuses, acceptance files, hashes, and mutation-site excerpts, but omitted the full M1/M2 harnesses, Makefiles, and GOTO binding records.

The proof results themselves remained valid, but the archive was not fully self-contained for independent mutation review. A Review-2 repack was therefore required to include:

- both mutation harnesses;
- both Makefiles;
- public-call-order evidence;
- loop inventories;
- property inventories;
- GOTO hashes;
- CBMC commands;
- complete XML files;
- exact status files;
- portable relative manifests;
- source-binding snapshot; and
- tool identity.

This incident is important evidence that the process was fail-closed: packaging incompleteness was not silently promoted to authoritative closure.

---

## 20. Final evidence ledger

### 20.1 Source identity

```text
Commit:
af4c5abdd5958bdc65a03cd5ee86708264f93304

Tree:
54805daff6a91a010c05467ea678117c42a71559
```

### 20.2 Frozen positive harness hashes

```text
P1 harness:
04b6a7b4287d75f2badb9612b1738a4c7ac5d5d2ce316464145ccada183c25a6

P2 harness:
5d1d3146ab061fdfdbbd55dd9f967acaa211a109d578b11fe59ffb9e7bcb896e

NV harness:
0ba7b2763cd3a0d7c30746f026cf22b27f1e7130f238409245ce8763f90c33f8
```

### 20.3 Frozen Makefile hashes

```text
P1 Makefile:
f0b87f4ea58487fa8828169d90a2ea16aa03852dfbd492bbe4eb6f8736ffbb96

P2 Makefile:
4647f2300984bfcb84ae26197b0b5ca2547b6edf4131238d1e5501f48ad6ce82

NV Makefile:
bf06cd69768410d23d9daccd84e313fd15083772bbc6cc9d61bdd35ecb5e9ab3
```

### 20.4 Complete XML hashes

```text
P1 XML:
4db167df872e139471c6e25a51e054f9e89f6198335fae48627beb59a5d119e0

P2 XML:
4ff977fd8098c587862f6a33cba40f58cd644d5cecdd69625c7e840003fa2aec

NV XML:
bd14d093ba03dbdce675e523974140712e66819bf1c532edfa895628c59b4467
```

### 20.5 Harness-freeze archive

```text
PBCODEC_CV1_HARNESS_FREEZE_CANDIDATE.tar.gz
SHA-256:
41a1a7c652245cf6a0771cf8b2a31adb59f533b6bb5f31b6483f95117257f697
```

### 20.6 First closure-candidate archive

```text
PBCODEC_CV1_AUTHORITATIVE_CLOSURE_CANDIDATE.tar.gz
SHA-256:
6c4cd4101e94cec050a0af8d172359666cfb5b3b20b31235bf9b0144cc2557e3
```

This hash was independently recalculated and matched. The archive was later superseded for publication by the Review-2 repack because of the mutation-source packaging omission described in Section 19.4.

### 20.7 Review-2 publication package

The final evidence submission should record the exact Review-2 archive name and SHA-256 from the generated `.sha256` file:

```text
PBCODEC_CV1_AUTHORITATIVE_CLOSURE_REVIEW2_CANDIDATE.tar.gz
SHA-256: [COPY THE FINAL REVIEW-2 HASH HERE]
```

The campaign's semantic acceptance does not depend on inventing this missing value. The actual final hash must be copied from the generated file before repository publication.

---

## 21. Novelty assessment methodology

### 21.1 Novelty questions were separated

The novelty assessment distinguishes:

1. **mathematical novelty** — whether the 12-bit packing or inverse identities are new mathematics;
2. **general formal-verification novelty** — whether ML-KEM/Kyber implementations or serialization have been formally verified before;
3. **repository-level artifact novelty** — whether this exact `mlkem-native` CBMC semantic and direct-composition campaign was found upstream;
4. **methodological novelty** — whether the combined intent-freeze, source-binding, non-vacuity, mutation, and deterministic-closure workflow is a distinct case-study contribution; and
5. **global priority** — whether the work can truthfully be called the first such result anywhere.

These questions must not be conflated.

### 21.2 Sources reviewed

The review conducted through 30 July 2026 examined:

- NIST FIPS 203 and its `ByteEncode`/`ByteDecode` framework;
- the public `mlkem-native` repository and its CBMC proof documentation;
- the pinned repository artifacts audited during PBYTES, PFB, and PBCODEC-00B/00C;
- the public function-oriented CBMC proof directory;
- *Formally Verifying Kyber: Episode IV — Implementation Correctness*;
- *Formally Verifying Kyber: Episode V*;
- the formally verified `rust-libcrux` ML-KEM work, including serialization verification using hax/F*;
- LibMLKEM's published assurance boundary; and
- public searches for combinations of `mlkem-native`, CBMC, `poly_tobytes`, `poly_frombytes`, codec composition, and round trip.

### 21.3 Search limitation

A literature and repository search cannot prove universal non-existence. Private work, unpublished artifacts, unindexed repositories, renamed functions, or differently worded theorems may exist.

A scoped-search qualifier is therefore mandatory for any broader novelty statement.

---

## 22. What is not novel

### 22.1 The mathematics is not novel

The elementary 12-bit packing equations, decoding equations, recoverability, and inverse relationships follow from the standardized representation. They are not new cryptographic mathematics.

### 22.2 ML-KEM formal verification is not new

Prior work has formally verified Kyber/ML-KEM implementations and connected implementations to specifications using tools such as EasyCrypt, Jasmin, hax, F*, and proof-assistant workflows. The `rust-libcrux` project explicitly reports formal verification of serialization, among other components.

### 22.3 This is not the first verified ML-KEM implementation

A first-ever claim would conflict with established high-assurance Kyber/ML-KEM work.

### 22.4 Round-trip reasoning is not globally new

Encoding/decoding round trips are standard correctness properties. The contribution is not the idea that an encoder and decoder should invert each other.

---

## 23. What is defensibly novel

### 23.1 Repository-level semantic artifact novelty

At the pinned `mlkem-native` revision, the audited upstream CBMC artifacts were function-oriented and contract/undefined-behaviour focused. The audit did not find the same explicit semantic theorem decomposition for PBYTES/PFB or a combined production-wrapper codec composition harness.

The new work contributes a distinct set of CBMC artifacts for this exact C target and commit.

### 23.2 Direct cross-function composition artifact

The specific CV1 artifact directly calls both real wrappers and binds both portable bodies in one model, in both legitimate directions, with explicit domain-sensitive assertions.

### 23.3 Theorem sequencing

The methodology deliberately avoids treating round-trip success as individual correctness. It first verifies each function against independent arithmetic intent, then performs real-to-real composition. This sequencing is a strong assurance design choice.

### 23.4 Integrity methodology

The contribution includes:

- immutable intent;
- source and tree binding;
- clean-room worktree separation;
- no production-code modification;
- explicit GOTO-level call/body binding;
- exact loop/unwind binding;
- non-vacuity endpoints;
- obligation-sensitive bridge mutations;
- zero-unrelated-failure requirements;
- deterministic hash manifests;
- fail-closed handling of script and packaging defects; and
- academically bounded claim wording.

### 23.5 Evidence-package novelty for an MSc case study

The resulting evidence is unusually detailed for a function-level MSc verification case study. Its value lies in reproducibility, auditability, and the clear separation between candidate generation and deterministic authority.

---

## 24. Novelty potency

| Novelty dimension | Assessment | Basis |
|---|---|---|
| New cryptographic primitive | None | No algorithm was changed or introduced |
| New 12-bit encoding mathematics | None to low | The representation and inverse arithmetic are established |
| First formal verification of Kyber/ML-KEM | None | Prior EasyCrypt/Jasmin and hax/F* work exists |
| First serialization proof anywhere | Not supportable | Prior verified serialization work exists |
| New per-function theorem decomposition for this pinned C target | Strong repository-relative potential | The 19-obligation PBYTES and 11-obligation PFB structures were not found upstream in the audited artifacts |
| New direct two-wrapper CBMC composition artifact for this pinned target | Moderate to strong repository-relative potential | No equivalent combined harness was found in the audited pinned repository or public searches |
| New non-vacuous, mutation-hardened closure workflow | Moderate to strong | Positive proofs, endpoint failures, bridge mutants, binding checks, and deterministic freezing are combined systematically |
| New reproducible thesis evidence package | Strong for an MSc case study | Exact source/model/property/result/hash relationships are preserved |
| Worldwide-first claim | Not justified | Public searching cannot establish universal absence |
| Publishable potential | Plausible when correctly framed | Strong case-study design and evidence, but novelty must remain repository/methodology specific |

---

## 25. Recommended novelty wording

### 25.1 Strongest defensible wording

> Relative to the publicly available CBMC artifacts in the pinned `mlkem-native` revision and the public sources reviewed through 30 July 2026, this work contributes a distinct repository-level CBMC semantic-verification and direct-composition campaign for the real portable `mlk_poly_tobytes` and `mlk_poly_frombytes` wrappers. Its novelty lies in the commit-bound theorem decomposition, legitimate-domain production-to-production composition obligations, GOTO-level wrapper/body/unwind binding, non-vacuity controls, targeted bridge mutations, fail-closed execution history, and deterministic evidence freezing. The contribution is not the underlying `ByteEncode12`/`ByteDecode12` mathematics, not the first formal verification of ML-KEM, and not asserted as a worldwide first.

### 25.2 Concise thesis wording

> The novelty is repository- and artifact-level rather than mathematical: a new commit-bound CBMC campaign for the unchanged `mlkem-native` portable codec path, integrating independent per-function semantic refinements with direct real-wrapper composition, non-vacuity, mutation hardening, and deterministic evidence closure.

### 25.3 Wording that must not be used

The thesis should not state:

```text
A new round-trip theorem was invented.
This is the first proof of ByteEncode12/ByteDecode12.
No one has verified ML-KEM serialization before.
This is the first correct ML-KEM encoder and decoder.
The whole ML-KEM implementation was proved.
Every backend and parameter set was proved.
The search proves that no equivalent artifact exists anywhere.
```

---

## 26. Correct contribution classification

### 26.1 Contribution C1 — per-function semantic verification

PBYTES and PFB add explicit semantic CBMC obligations around unchanged real public functions.

### 26.2 Contribution C2 — direct implementation integration

CV1 directly composes both real wrappers and bodies under legitimate domains.

### 26.3 Contribution C3 — deterministic integrity firewall

The workflow treats generated harnesses as candidates and applies deterministic checks before accepting results.

### 26.4 Contribution C4 — evidence engineering

The work records exact source, GOTO, property, XML, call, loop, mutation, manifest, and archive identities.

### 26.5 Contribution C5 — bounded novelty discipline

The work explicitly rejects theorem-count inflation and world-first language where the evidence does not support it.

---

## 27. Threats to validity and limitations

### 27.1 Configuration validity

The direct semantic executions were frozen to portable ML-KEM-768. Although these codec routines are structurally parameter-independent in important respects, extending the formal claim to ML-KEM-512 and ML-KEM-1024 requires separate preprocessing/source-equivalence evidence or direct reruns.

### 27.2 Backend validity

Native assembly, intrinsics, and optimized wrapper paths were excluded.

### 27.3 Tool-model validity

CBMC reasons about its GOTO model and C semantics. Compiler bugs, linker behaviour outside the model, hardware faults, and generated machine-code equivalence were not proved.

### 27.4 Specification validity

A formal proof is only as meaningful as its theorem and assumptions. The campaign reduces specification risk through independent arithmetic refinements, complementary theorem shapes, direct composition, and mutations, but it does not eliminate all possibility of a mistaken high-level intent.

### 27.5 Search completeness

The novelty search is necessarily incomplete. Repository-relative distinction is well supported; universal priority is not.

### 27.6 Packaging validity

The first closure archive was not fully self-contained for mutation-source review. The Review-2 repack addressed this. The final published repository must retain the Review-2 archive and exact hash rather than only the superseded first candidate.

### 27.7 Property completeness

The campaign proves the frozen properties, not every possible security or functional property of the codec routines.

---

## 28. Examiner-safe answers

### Round-trip proof status

Yes. CBMC proved both real-wrapper compositions for all inputs in their legitimate symbolic domains, with complete unwinding and no counterexample. The polynomial direction covers all canonical polynomials; the byte direction covers exactly the canonical encoder image.

### Rationale for the byte-round-trip restriction

Because arbitrary bytes may decode to raw 12-bit values from 3329 through 4095, which are outside the production encoder's canonical precondition. An unrestricted theorem would be invalid.

### “Could two wrong functions simply invert each other?”

Yes, which is why the composition campaign was not used alone. The encoder and decoder were first verified separately against independent arithmetic specifications. Direct composition was then added as integration corroboration.

### “Why is this different from the upstream harness?”

The audited upstream CBMC framework is function-oriented and contract/undefined-behaviour focused, with boilerplate harnesses. The new harnesses add explicit cross-function semantic assertions, direct two-wrapper call sequences, legitimate-domain predicates, GOTO binding, non-vacuity, bridge mutations, and deterministic closure.

### C-implementation modification status

No. Production-source diffs remained empty. Only isolated proof artifacts and harness-side mutants were added in a detached worktree.

### “Is this globally novel?”

A global first-ever claim is not justified. The defensible novelty is the repository-level CBMC theorem/artifact structure and mutation-hardened evidence methodology for this pinned unmodified C target.

### “Why not call CV1 a new theorem family?”

The composition identities are logical consequences of the previously established independent encoder and decoder refinements. CV1 is therefore classified as one direct composition-validation family rather than new mathematical theorem content.

### “Why was CV1 still useful?”

It directly verifies wrapper wiring, shared data layout, source/build consistency, compatible domains, actual body reachability, and production-to-production integration—issues not identical to separate function-versus-oracle proofs.

### “What makes the evidence non-vacuous?”

Two deliberately false assertions were placed after the composition endpoints and both were reached. In addition, targeted bridge corruptions caused exactly the intended theorem failures.

### “What is the strongest honest claim?”

The pinned portable C codec path is correct for the two stated composition obligations, corroborated by thirty independent per-function semantic obligations, complete unwinding, non-vacuity, and targeted mutation evidence.

---

## 29. Reproduction and publication checklist

Before showing or publishing the evidence, retain:

- [ ] pinned commit and tree identifiers;
- [ ] authoritative source hash manifest;
- [ ] PBYTES final report and evidence seal;
- [ ] PFB final report and evidence seal;
- [ ] CV1 verification intent;
- [ ] exact P1, P2, and NV harnesses;
- [ ] exact proof Makefiles;
- [ ] GOTO binary hashes;
- [ ] `show-goto-functions` call-order evidence;
- [ ] loop inventories and unwind sets;
- [ ] complete P1/P2/NV XML files;
- [ ] exact target-property mapping table;
- [ ] M1/M2 harnesses and Makefiles;
- [ ] M1/M2 binding evidence and XML results;
- [ ] mutation acceptance records;
- [ ] source-diff evidence;
- [ ] portable relative manifests;
- [ ] CBMC/tool identity;
- [ ] allowed-claim and non-claim files;
- [ ] Review-2 archive;
- [ ] Review-2 SHA-256 copied into Section 20.7; and
- [ ] repository citation metadata.

---

## 30. Final allowed claim

> At `mlkem-native` commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`, in the portable ML-KEM-768 CBMC 6.9.0 configuration, the real public `mlk_poly_tobytes` and `mlk_poly_frombytes` wrappers were directly composition-validated in both legitimate directions. Every canonical polynomial was preserved by encode/decode, and every byte array in the canonical encoder image was preserved by decode/encode. Both wrappers and both portable C bodies were present and reachable, all relevant loops were completely unwound, the positive properties succeeded, both endpoints were shown reachable, and two targeted harness-side bridge mutations were killed with no unrelated property failures. Production source was unchanged, and no function-contract replacement, loop-contract substitution, or independent codec oracle was used in the direct composition proof.

---

## 31. Explicit non-claims

This work does not claim:

- a newly discovered encoding algorithm;
- new cryptographic mathematics;
- the first formal verification of Kyber or ML-KEM;
- the first serialization proof in any language or tool;
- a mathematical or worldwide first;
- correctness of arbitrary-byte decode/encode outside the canonical image;
- correctness of native or assembly backends;
- compiler-to-binary equivalence;
- all-parameter-set direct execution;
- constant-time or side-channel correctness;
- fault-attack resistance;
- correctness of the complete K-PKE or ML-KEM construction;
- unrestricted correctness beyond the frozen obligations; or
- automatic validity for a different source revision.

---

## 32. Final conclusion

The completed work forms a layered verification argument.

First, PBYTES established the exact semantic behaviour of the real canonical encoder through nineteen obligations covering arithmetic refinement, carry transitions, exact image characterization, invalid-codeword exclusion, recoverability, and injectivity.

Second, PFB established the exact semantic behaviour of the real raw decoder through eleven obligations covering coefficient equations, bit routing, locality, arbitrary differential conservation, injectivity, and a complete raw-domain inverse with an independent arithmetic encoder.

Third, PBCODEC-CV1 directly composed the two real public production wrappers in both legitimate directions. It proved canonical polynomial encode/decode and canonical byte-image decode/encode round trips in shared GOTO models, with both portable bodies present, complete unwinding, explicit non-vacuity, and two killed bridge mutants.

The answer to the central correctness question is therefore:

> **Yes, the round trip was genuinely proved for the two frozen legitimate-domain composition obligations under the recorded portable ML-KEM-768 CBMC model.**

The answer to the novelty question is:

> **The representation mathematics and the general idea of formal ML-KEM verification are not novel. The defensible novelty lies in the exact repository-level, commit-bound CBMC semantic and direct-composition artifacts, their theorem sequencing, and their non-vacuous, mutation-hardened, fail-closed, deterministic evidence architecture.**

This is a strong and potentially publishable MSc case-study contribution when presented with these boundaries and without a first-ever claim.

---

# Appendix A — Full accepted CV1.P1 harness

```c
#include <stddef.h>
#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly input;
  mlk_poly recovered;
  uint8_t encoded[MLKEM_POLYBYTES];
  size_t coefficient_index;
  unsigned i;

  __CPROVER_assume(coefficient_index < MLKEM_N);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);
  }

  mlk_poly_tobytes(encoded, &input);
  mlk_poly_frombytes(&recovered, encoded);

  __CPROVER_assert(
      recovered.coeffs[coefficient_index] ==
          input.coeffs[coefficient_index],
      "PBCODEC-CV1.P1 canonical polynomial survives real encode-decode");
}
```

# Appendix B — Full accepted CV1.P2 harness

```c
#include <stddef.h>
#include <stdint.h>

#include "compress.h"

void harness(void)
{
  uint8_t input[MLKEM_POLYBYTES];
  uint8_t reencoded[MLKEM_POLYBYTES];
  mlk_poly decoded;
  size_t byte_index;
  unsigned block_index;
  uint32_t packed_word;
  uint32_t even_field;
  uint32_t odd_field;

  __CPROVER_assume(byte_index < MLKEM_POLYBYTES);

  for (block_index = 0u;
       block_index < (MLKEM_N / 2u);
       block_index++)
  {
    packed_word =
        (uint32_t)input[3u * block_index] +
        UINT32_C(256) *
            (uint32_t)input[3u * block_index + 1u] +
        UINT32_C(65536) *
            (uint32_t)input[3u * block_index + 2u];

    even_field = packed_word % UINT32_C(4096);
    odd_field = packed_word / UINT32_C(4096);

    __CPROVER_assume(even_field < MLKEM_Q);
    __CPROVER_assume(odd_field < MLKEM_Q);
  }

  mlk_poly_frombytes(&decoded, input);
  mlk_poly_tobytes(reencoded, &decoded);

  __CPROVER_assert(
      reencoded[byte_index] == input[byte_index],
      "PBCODEC-CV1.P2 canonical bytes survive real decode-encode");
}
```

# Appendix C — Full non-vacuity harness

```c
#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly input;
  mlk_poly decoded;
  uint8_t encoded[MLKEM_POLYBYTES];
  uint8_t reencoded[MLKEM_POLYBYTES];
  unsigned i;

  for (i = 0u; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 0;
  }

  input.coeffs[0] = 0;
  input.coeffs[1] = 1;
  input.coeffs[2] = 15;
  input.coeffs[3] = 16;
  input.coeffs[4] = 255;
  input.coeffs[5] = 256;
  input.coeffs[6] = MLKEM_Q - 1;

  mlk_poly_tobytes(encoded, &input);
  mlk_poly_frombytes(&decoded, encoded);

  __CPROVER_assert(
      0,
      "PBCODEC-CV1.NV1 encode-decode endpoint is reachable");

  mlk_poly_tobytes(reencoded, &decoded);

  __CPROVER_assert(
      0,
      "PBCODEC-CV1.NV2 decode-encode endpoint is reachable");
}
```

# Appendix D — Compact theorem registry across all three campaigns

| Campaign | Family | Obligations | Core meaning |
|---|---|---:|---|
| PBYTES | T1 | 6 | exact arithmetic encoder refinement |
| PBYTES | T2 | 4 | successor and carry transitions |
| PBYTES | T3 | 5 | canonical image and invalid exclusion |
| PBYTES | T4 | 4 | recoverability and injectivity |
| PFB | T1 | 2 | exact raw decoder equations |
| PFB | T2 | 5 | exact bit routes and locality |
| PFB | T3 | 2 | differential conservation and injectivity |
| PFB | T4 | 2 | complete raw-domain two-sided inverse |
| PBCODEC-CV1 | CV1 | 2 | direct real-wrapper composition on legitimate domains |

```text
PBYTES semantic obligations: 19
PFB semantic obligations:     11
Direct CV1 obligations:        2
---------------------------------
Total executed semantic obligations represented in the layered codec record: 32
```

The total of 32 must not be described as 32 mathematically independent discoveries. Many are complementary decompositions or executable consequences selected for assurance diversity.

# Appendix E — External references and novelty context

1. National Institute of Standards and Technology (2024) *FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard*. Available at: https://csrc.nist.gov/pubs/fips/203/final (Accessed: 30 July 2026).
2. PQ Code Package (2026) *mlkem-native: Secure, fast, and portable C90 implementation of ML-KEM / FIPS 203*. Available at: https://github.com/pq-code-package/mlkem-native (Accessed: 30 July 2026).
3. PQ Code Package (2026) *mlkem-native CBMC proofs*. Available at: https://github.com/pq-code-package/mlkem-native/tree/main/proofs/cbmc (Accessed: 30 July 2026).
4. Almeida, J.B. et al. (2023) ‘Formally Verifying Kyber Episode IV: Implementation Correctness’, *IACR Transactions on Cryptographic Hardware and Embedded Systems*, 2023(3), pp. 164–193. DOI: https://doi.org/10.46586/tches.v2023.i3.164-193.
5. Almeida, J.B. et al. (2024) *Formally Verifying Kyber: Episode V*. IACR ePrint 2024/843. Available at: https://eprint.iacr.org/2024/843 (Accessed: 30 July 2026).
6. PQ Code Package (2026) *rust-libcrux ML-KEM*. Available at: https://github.com/pq-code-package/rust-libcrux (Accessed: 30 July 2026).
7. CPROVER Project (2026) *CBMC: Bounded Model Checking for Software*. Available at: https://www.cprover.org/cbmc/ (Accessed: 30 July 2026).
8. Amazon Web Services (2026) *LibMLKEM*. Available at: https://github.com/awslabs/LibMLKEM (Accessed: 30 July 2026).

# Appendix F — One-paragraph professor summary

At the pinned `mlkem-native` commit `af4c5abd…`, a layered clean-room CBMC campaign verified the portable polynomial byte codec without modifying production C. The separate PBYTES campaign proved nineteen encoder obligations covering exact arithmetic encoding, carry transitions, canonical-image characterization, invalid-codeword exclusion, recoverability, and injectivity. The separate PFB campaign proved eleven decoder obligations covering exact raw decoding, bit routing, locality, differential conservation, injectivity, and a complete raw-domain inverse with an independent arithmetic encoder. A final PBCODEC-CV1 campaign then directly composed the real public encoder and decoder wrappers in both legitimate directions: every canonical polynomial survived real encode/decode, and every byte string in the canonical encoder image survived real decode/encode. Both wrappers and both portable bodies were bound in the GOTO models, all relevant loops were completely unwound, two deliberate endpoint failures established non-vacuity, and two targeted bridge mutants were killed with no unrelated property failures. The work is not claimed as new encoding mathematics, the first formal verification of ML-KEM, or a worldwide first. Its defensible novelty is the repository-level, commit-bound CBMC theorem and direct-composition artifact suite together with its mutation-hardened, fail-closed, deterministic evidence methodology.
