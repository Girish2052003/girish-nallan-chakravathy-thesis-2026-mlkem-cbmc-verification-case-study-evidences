# PFB `mlk_poly_frombytes` Clean-Room CBMC Verification Campaign

## Final technical record, proof rationale, evidence index, and bounded novelty assessment

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Project:** MSc thesis case study — AI-Assisted Formal Methods for Post-Quantum Cryptography Implementation  
**Target repository:** `pq-code-package/mlkem-native`  
**Pinned source commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Pinned source tree:** `54805daff6a91a010c05467ea678117c42a71559`  
**Target public function:** `mlk_poly_frombytes`  
**Portable implementation body:** `mlk_poly_frombytes_c`  
**Executed configuration:** portable ML-KEM-768 (`MLKEM_K=3`)  
**Verification tool:** CBMC, with the exact tool and operating-system versions captured in the final campaign seal  
**Campaign status:** **ACCEPTED AND SEALED**  
**Final-seal timestamp:** `20260729T054222Z`  
**Report date:** 29 July 2026

---

## 1. Purpose and status of this report

This report documents the complete clean-room PFB verification campaign developed and executed for the portable public `mlk_poly_frombytes` path in `mlkem-native`.

It records:

- the exact source and verification boundary;
- the mathematical meaning of the target routine;
- the four frozen theorem families and eleven semantic obligations;
- why four theorem families were deliberately selected;
- the assumptions under which the results hold;
- the harness architecture and its distinction from upstream `mlkem-native` CBMC work;
- the CBMC execution strategy;
- non-vacuity, boundary, reachability, mutation, and integrity controls;
- every final acceptance result and evidence hash;
- execution problems encountered and the fail-closed repairs applied;
- the exact strength and limitations of the final correctness claim;
- a bounded novelty assessment based on the pinned repository and a public-source review completed on 29 July 2026.

The campaign is complete. All four frozen theorem families were accepted, all eleven semantic obligations were proved in the recorded configuration, the authoritative source tree remained clean, and a campaign-level master seal was generated.

This document is intentionally written as a technical record of the work rather than as an informal explanation.

---

## 2. Final result at a glance

| Item | Final result |
|---|---:|
| Frozen theorem families | 4 |
| Frozen semantic obligations | 11 |
| PFB-T1 final acceptance | YES |
| PFB-T2 final acceptance | YES |
| PFB-T3 final acceptance | YES |
| PFB-T4 final acceptance | YES |
| Production source modified | NO |
| Target body replaced by a function contract | NO |
| Loop contracts applied to replace loop execution | NO |
| Native backend included in the claim | NO |
| Production `mlk_poly_tobytes` correctness claimed | NO |
| Full FIPS 203 `ByteDecode12` modular-normalisation correctness claimed | NO |
| Mathematical or worldwide-first claim made | NO |
| Authoritative repository clean at final seal | YES |
| Campaign final status | ACCEPTED |

### 2.1 Final campaign-level claim

> At commit `af4c5abd`, the portable public `mlk_poly_frombytes` path was verified by CBMC for the eleven frozen PFB semantic obligations covering exact raw decoding, exact bit routing and one-block locality, arbitrary differential conservation, and two-sided inversion over the complete raw 12-bit domain, under the recorded machine model and proof configurations.

### 2.2 What this claim means

The result is an exhaustive, bit-precise verification of the stated properties over the finite C machine model and the frozen input domains. It is not random testing and it is not based on selected test vectors.

The result establishes that the real portable C decoder behaves as the frozen raw 12-bit unpacking specification requires, for every input represented by the relevant nondeterministic arrays and every valid symbolic index used by the harnesses.

### 2.3 What this claim does not mean

The campaign does not establish unrestricted correctness of every possible interpretation of the function. In particular, it does not prove:

- the native assembly or intrinsics backend;
- full FIPS 203 `ByteDecode12` reduction modulo `q=3329`;
- canonical public-key validation;
- correctness of production `mlk_poly_tobytes`;
- correctness of unrelated compression, decompression, NTT, reduction, KEM, or PKE functions;
- correctness at a source commit other than the pinned commit;
- parameter-set-wide verification beyond the executed portable ML-KEM-768 configuration;
- side-channel resistance;
- a worldwide first.

---

## 3. Source identity and immutable implementation boundary

### 3.1 Pinned source

The campaign was permanently bound to:

```text
Commit:
af4c5abdd5958bdc65a03cd5ee86708264f93304

Tree:
54805daff6a91a010c05467ea678117c42a71559
```

The source was not treated as an interchangeable “latest version.” Every accepted result is specific to this commit and tree.

### 3.2 Source-file hashes

| File | SHA-256 |
|---|---|
| `mlkem/src/compress.c` | `9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad` |
| `mlkem/src/compress.h` | `0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd` |
| `mlkem/src/params.h` | `450fe3e0e50496921920473ae4321660f178c23d51f1453f3c537ee63c4158cb` |
| `mlkem/src/poly.c` | `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722` |
| `mlkem/src/poly.h` | `f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef` |

The central implementation evidence is `compress.c`, which contains:

```c
r->coeffs[2 * i + 0] =
    (int16_t)(t0 | (((uint16_t)t1 << 8) & 0xFFF));

r->coeffs[2 * i + 1] =
    (int16_t)((t1 >> 4) | (t2 << 4));
```

The source itself states that the resulting coefficients are not canonical. The portable body’s upstream contract requires valid non-aliasing objects, assigns the output polynomial, and ensures only that the coefficients lie in the raw 12-bit interval. It does not state the eleven semantic properties proved in this campaign.

### 3.3 Public wrapper and portable body

The campaign targeted the public function:

```c
void mlk_poly_frombytes(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYBYTES]);
```

Under the frozen portable configuration, the public wrapper calls:

```c
mlk_poly_frombytes_c(r, a);
```

The GOTO call graph was inspected in every relevant theorem family. The proof did not bypass the public wrapper by calling the portable body directly from the semantic harness.

This matters because the verified claim is about the real configured public path, not merely a copied expression or a detached helper function.

---

## 4. What `mlk_poly_frombytes` computes

### 4.1 Raw 12-bit block model

The input is a byte array of length:

```text
MLKEM_POLYBYTES = 384
```

The output is a polynomial with:

```text
MLKEM_N = 256
```

coefficients.

Each consecutive 3-byte input block encodes two 12-bit raw values. For block index \(i\), define:

\[
W_i =
a_{3i}
+ 256a_{3i+1}
+ 65536a_{3i+2}.
\]

The intended raw values are:

\[
x_i = W_i \bmod 4096,
\]

\[
y_i = \left\lfloor\frac{W_i}{4096}\right\rfloor.
\]

The corresponding output coefficients are:

\[
r_{2i}=x_i,
\qquad
r_{2i+1}=y_i.
\]

The inverse raw encoder is:

\[
c_0=x\bmod 256,
\]

\[
c_1=\left\lfloor\frac{x}{256}\right\rfloor
     +16(y\bmod 16),
\]

\[
c_2=\left\lfloor\frac{y}{16}\right\rfloor.
\]

### 4.2 Raw decoding versus FIPS modular decoding

The verified function produces raw 12-bit values in:

\[
[0,4096).
\]

ML-KEM’s field modulus is:

\[
q=3329.
\]

Therefore values from 3329 through 4095 are valid raw 12-bit outputs of this routine but are not canonical field representatives.

This distinction is essential. The campaign proves exact raw unpacking. It does not claim that `mlk_poly_frombytes` alone performs the complete FIPS 203 `ByteDecode12` interpretation modulo \(q\), nor does it claim that it performs canonical public-key validation.

The two-sided bijection in PFB-T4 is possible precisely because the campaign uses the complete \(2^{12}\) raw domain. A modulo-\(q\) decoder could not be bijective over all \(2^{3072}\) input byte strings because reduction modulo 3329 would collapse multiple raw 12-bit representations.

---

## 5. Research and verification question

The campaign answered the following implementation-level question:

> Does the real portable public `mlk_poly_frombytes` path at the pinned commit implement the frozen raw 12-bit decoding relation for every possible 384-byte input, and does it preserve the expected bit routing, locality, differential structure, and two-sided raw-domain inverse properties?

This is narrower than proving ML-KEM as a whole, but stronger than proving only memory safety, integer safety, or output bounds for this routine.

---

## 6. Clean-room campaign architecture

### 6.1 Principle

The production implementation was treated as immutable evidence. Verification artifacts were developed outside the production source and were not allowed to repair, rewrite, stub, or replace the target.

### 6.2 High-level stages

The completed sequence was:

1. source and commit binding;
2. repository-overlap and prior-work audit;
3. theorem-family selection;
4. theorem and assumption freeze;
5. harness generation only after the freeze;
6. GOTO-program construction;
7. public-wrapper and portable-body call-chain confirmation;
8. theorem-only CBMC execution;
9. unfiltered complete-property CBMC execution;
10. non-vacuity and concrete-boundary controls;
11. targeted mutation sensitivity;
12. post-mutation source and artifact rebinding;
13. theorem-family freeze and archive;
14. campaign-level rebinding and final seal.

### 6.3 Frozen theorem registry

The theorem registry was frozen before the semantic harnesses were accepted.

The PFB-00C theorem freeze recorded:

```text
Freeze directory:
PFB_00C_THEOREM_FREEZE_af4c5abd

Freeze manifest SHA-256:
0ad77b89aa6260e4021e897c7ace73e3588f2afd2c6d9cdc9a2f39a2debac8f4

Frozen theorem families:
4

Frozen semantic obligations:
11
```

Freezing the registry before proof execution prevented later movement of the goalposts and prevented a successful CBMC result from being retroactively re-described as a stronger theorem.

---

## 7. Why exactly four theorem families were selected

The number four was deliberate. It was neither arbitrary nor chosen to inflate the result count.

The campaign needed a compact set of property families that covered four different assurance views:

1. **direct functional semantics** — what values are computed;
2. **causal bit structure and locality** — where each input bit can propagate;
3. **relational or differential behaviour** — how arbitrary pairs of inputs relate;
4. **global inverse structure** — whether the decoder is a bijection over its complete raw domain.

A fifth family was rejected because the next plausible additions would either:

- duplicate an already frozen consequence;
- move into a different function, such as production `mlk_poly_tobytes`;
- move into FIPS canonicalisation or key validation;
- move into native-backend verification;
- become a generic frame, determinism, or safety family rather than a new semantic family.

Those topics are legitimate future campaigns, but adding them to PFB would have weakened the scope boundary.

### 7.1 The four families are assurance-orthogonal, not completely logically independent

The families were selected for independent proof shapes, diagnostics, and evidence value. They are not claimed to be four unrelated mathematical discoveries.

For example:

- exact T1 semantics mathematically entails many T2 bit-routing facts;
- T3.P1 entails T3.P2;
- exact T1 semantics together with the independent encoder equations entails the T4 inverse laws.

The value of T2, T3, and T4 is therefore not that T1 becomes false without them. Their value is that they express important consequences through independent harness structures, different relational executions, different oracles, and different mutation tests.

This is a strength rather than a weakness: the campaign cross-checks the same implementation through multiple mathematically linked but operationally distinct proof obligations.

---

## 8. PFB-T1 — Exact raw-decoding semantics

### 8.1 Purpose

PFB-T1 is the direct functional specification. It answers:

> What exact mathematical values does the decoder place in the even and odd output coefficients?

Without T1, the campaign would have only structural or round-trip evidence and no direct coefficient-level theorem.

### 8.2 Frozen obligations

For an arbitrary valid block index \(i\) and arbitrary input bytes:

#### PFB-T1.P1 — exact even coefficient

\[
r_{2i}=W_i\bmod 4096.
\]

#### PFB-T1.P2 — exact odd coefficient

\[
r_{2i+1}=
\left\lfloor\frac{W_i}{4096}\right\rfloor.
\]

### 8.3 Oracle independence

The expected values were calculated with widened arithmetic, multiplication, division, and remainder.

The oracle was not permitted to:

- call `mlk_poly_frombytes`;
- call `mlk_poly_frombytes_c`;
- call production `mlk_poly_tobytes`;
- copy the target’s mask-and-shift expression;
- assume the expected output;
- constrain the input to canonical coefficients.

### 8.4 Results

| Evidence run | Result |
|---|---:|
| Theorem-only obligations | 2/2 SUCCESS |
| Complete theorem run | 113/113 SUCCESS |
| Control complete run | 104/104 SUCCESS |
| Raw boundary complete run | 114/114 SUCCESS |
| Raw lower endpoint | 0 proved |
| Raw upper endpoint | 4095 proved |

### 8.5 Mutation evidence

Two detached source mutants were used.

#### Even-route mutant

A shift error was introduced into the even coefficient construction.

Expected and observed:

```text
PFB-T1.P1 = FAILURE
PFB-T1.P2 = SUCCESS
```

#### Odd-route mutant

A shift error was introduced into the odd coefficient construction.

Expected and observed:

```text
PFB-T1.P1 = SUCCESS
PFB-T1.P2 = FAILURE
```

This selectivity demonstrated that the two assertions observed their intended semantic channels rather than merely failing whenever the function changed.

### 8.6 T1 final evidence

```text
Final acceptance:
YES

Final manifest SHA-256:
53904a93bbe2b862a53539d9875932f8ba1f219a558562f936e0621998382137

Final archive:
PFB_T1_FINAL_FREEZE_af4c5abd_20260729T043912Z.tar.gz

Final archive SHA-256:
5866529dfd01315886e0066646638efc70d9ede920ecd7df9c0a97c10e047114
```

### 8.7 Exact T1 claim

> At commit `af4c5abd`, the portable public `mlk_poly_frombytes` path was verified by CBMC for the two frozen PFB-T1 exact raw-decoding obligations over arbitrary input bytes and an arbitrary valid block index, under the recorded machine model and proof configuration.

---

## 9. PFB-T2 — Exact bit routing and block locality

### 9.1 Purpose

T1 proves the final arithmetic values. T2 exposes the internal dependency structure at the bit and block levels.

T2 answers:

- Which output bit receives each input bit?
- Can a change in one 3-byte block affect another output pair?

This family provides precise diagnostics and a stronger defence against accidental index mixing, nibble reversal, incorrect shifts, and cross-block contamination.

### 9.2 Frozen obligations

#### PFB-T2.P1 — first-byte routing

Toggling bit \(j\) of byte \(a_{3i}\) toggles only bit \(j\) of the even coefficient for block \(i\).

#### PFB-T2.P2 — second-byte low-nibble routing

Toggling low-nibble bit \(j\) of byte \(a_{3i+1}\) toggles only bit \(8+j\) of the even coefficient.

#### PFB-T2.P3 — second-byte high-nibble routing

Toggling high-nibble bit \(j\) of byte \(a_{3i+1}\) toggles only bit \(j\) of the odd coefficient.

#### PFB-T2.P4 — third-byte routing

Toggling bit \(j\) of byte \(a_{3i+2}\) toggles only bit \(4+j\) of the odd coefficient.

#### PFB-T2.P5 — arbitrary one-block locality

If two arbitrary inputs differ only inside one selected 3-byte block, every output coefficient pair outside that selected block is equal.

### 9.3 Why T2 was not replaced by T1

T2 is a mathematical consequence of exact decoding, but it was retained because:

- it distinguishes four different bit routes;
- it detects nibble and shift mistakes directly;
- it proves cross-block isolation as an explicit relational property;
- it provides selective mutation evidence;
- it makes failure diagnosis much clearer than a single arithmetic mismatch.

### 9.4 Results

| Proof unit | Theorem result | Complete result |
|---|---:|---:|
| Four bit-routing obligations | 4/4 SUCCESS | 170/170 SUCCESS |
| Arbitrary block locality | 1/1 SUCCESS | 102/102 SUCCESS |
| Concrete non-vacuity/boundary control | 7/7 harness assertions | 105/105 complete properties |

### 9.5 Concrete control witnesses

The control campaign exercised:

- block 0 and bit 0;
- block 127 and a low-nibble boundary bit;
- block 0 and a high-nibble boundary bit;
- block 127 and a third-byte boundary bit;
- a middle block with all three bytes changed;
- coefficients immediately before and after the selected pair;
- a witness that the selected pair was genuinely nonconstant.

No assumptions were used in the concrete control harness.

### 9.6 Mutation evidence

Five detached source mutants were created.

| Mutant | Expected failing obligation | Observed |
|---|---|---|
| first-byte route altered | P1 only | P1 FAILURE; P2–P4 SUCCESS |
| low-nibble shift altered | P2 only | P2 FAILURE; P1, P3, P4 SUCCESS |
| high-nibble shift altered | P3 only | P3 FAILURE; P1, P2, P4 SUCCESS |
| third-byte shift altered | P4 only | P4 FAILURE; P1–P3 SUCCESS |
| cross-block dependency introduced | P5 | locality assertion FAILURE |

Every mutant produced the intended theorem failure without CBMC errors or unknown results.

### 9.7 T2 parser repair

The first T2 runner stopped after successful CBMC runs because its XML evidence parser created status fields only for explicitly supplied property identifiers. The unfiltered complete runs had no identifier list, so the parser omitted the individual status keys even though the XML reported complete success.

The repair:

- did not rebuild;
- did not rerun CBMC;
- rebound all artifacts;
- reparsed the existing XML directly;
- confirmed 170/170 and 102/102 success;
- classified the original stop as evidence-parser-only.

This incident was preserved rather than hidden.

### 9.8 T2 final evidence

```text
Final acceptance:
YES

Final manifest SHA-256:
492fee156a81c7c0a42fea46babdc1edc355ce9cbbc31096ac3c674e5f0af095

Final archive:
PFB_T2_FINAL_FREEZE_af4c5abd_20260729T050106Z.tar.gz

Final archive SHA-256:
9b282ca57ea6f43e0ffa88ad6a6cd6694d7a09d52a9d1373e6e4b9dfe68c1488
```

### 9.9 Exact T2 claim

> At commit `af4c5abd`, the portable public `mlk_poly_frombytes` path was verified by CBMC for the five frozen PFB-T2 exact bit-routing and arbitrary one-block locality obligations, under the recorded machine model and proof configuration.

---

## 10. PFB-T3 — Arbitrary differential conservation

### 10.1 Purpose

T2 uses constrained single-bit or one-block differences. T3 lifts the analysis to two arbitrary byte arrays.

It answers:

- Is the complete 24-bit difference in a selected input block preserved by the packed output pair?
- Can two distinct 3-byte blocks ever decode to the same coefficient pair?

### 10.2 Packed pair

For a decoded pair \((x,y)\), define:

\[
\operatorname{pack12}(x,y)=x+4096y.
\]

This places the even coefficient in bits 0–11 and the odd coefficient in bits 12–23.

### 10.3 Frozen obligations

#### PFB-T3.P1 — arbitrary XOR conservation

For two arbitrary input arrays \(A\) and \(B\), and an arbitrary valid block index \(i\):

\[
\operatorname{pack12}(D(A)_i)
\oplus
\operatorname{pack12}(D(B)_i)
=
W_i(A)\oplus W_i(B).
\]

#### PFB-T3.P2 — block difference iff pair difference

For every valid selected block:

\[
A_i \neq B_i
\iff
D(A)_i \neq D(B)_i.
\]

Here \(A_i\) and \(B_i\) denote the selected 3-byte blocks, and \(D(A)_i\) and \(D(B)_i\) denote their decoded coefficient pairs.

### 10.4 Logical dependency

PFB-T3.P1 implies PFB-T3.P2.

If the input blocks differ, their 24-bit XOR is nonzero. P1 then requires the packed-output XOR to be nonzero, so the output pairs differ. Conversely, equal input blocks have zero input XOR and therefore zero packed-output XOR.

P2 was nevertheless retained as an explicit theorem because it is the clearest direct statement of blockwise injectivity and provides a useful diagnostic result.

### 10.5 Results

| Evidence run | Result |
|---|---:|
| Theorem-only run | 2/2 SUCCESS |
| Complete property run | 151/151 SUCCESS |
| Concrete non-vacuity and boundary control | 8/8 assertions; 112/112 complete properties |

### 10.6 Mutation evidence

#### Bijective low-byte permutation mutant

The first byte was transformed by a bijective bit rotation before decoding.

Expected and observed:

```text
PFB-T3.P1 = FAILURE
PFB-T3.P2 = SUCCESS
```

The mapping remained injective, so P2 correctly remained true, but exact XOR conservation failed.

#### Information-loss mutant

One bit of the third input byte was discarded.

Expected and observed:

```text
PFB-T3.P1 = FAILURE
PFB-T3.P2 = FAILURE
```

This mutant created collisions, so both the exact differential relation and injectivity failed.

### 10.7 T3 final evidence

```text
Final acceptance:
YES

Final manifest SHA-256:
dfc3927245486af7a9bf32e875a6ddee490141807cfc33c57433b2d9518a8324

Final archive:
PFB_T3_FINAL_FREEZE_af4c5abd_20260729T051133Z.tar.gz

Final archive SHA-256:
f5d11b702eedfc2651cd860815b916c063f39efc764a98e7d06d1295df3772c4
```

### 10.8 Exact T3 claim

> At commit `af4c5abd`, the portable public `mlk_poly_frombytes` path was verified by CBMC for the two frozen PFB-T3 arbitrary differential-conservation obligations over two arbitrary input byte arrays and an arbitrary valid block index, under the recorded machine model and proof configuration.

---

## 11. PFB-T4 — Two-sided inverse over the complete raw domain

### 11.1 Purpose

T4 closes the campaign with a global algebraic statement.

T1 proves direct per-block semantics. T2 proves bit routing and locality. T3 proves differential conservation and injectivity. T4 explicitly proves that the real decoder and an independently written arithmetic encoder are mutual inverses over their complete raw domains.

### 11.2 Independent raw encoder

The encoder was defined with widened division and remainder:

\[
c_0=x\bmod 256,
\]

\[
c_1=
\left\lfloor\frac{x}{256}\right\rfloor
+
16(y\bmod 16),
\]

\[
c_2=
\left\lfloor\frac{y}{16}\right\rfloor.
\]

It was forbidden from:

- calling `mlk_poly_tobytes`;
- calling the target inside the oracle;
- copying the target decoder’s mask-and-shift expression;
- assuming the expected output.

### 11.3 Frozen obligations

Let \(D\) denote the real portable public decoder and \(E\) denote the independent raw encoder.

#### PFB-T4.P1 — arbitrary bytes round trip

For every 384-byte array \(b\):

\[
E(D(b))=b.
\]

#### PFB-T4.P2 — arbitrary raw polynomial round trip

For every 256-coefficient polynomial \(p\) satisfying:

\[
0\le p_j<4096
\quad
\text{for every }j,
\]

the following holds:

\[
D(E(p))=p.
\]

### 11.4 Mathematical consequence

P1 proves that \(D\) has a left inverse and is injective.

P2 proves that \(D\) has a right inverse and is surjective onto the complete raw-polynomial domain.

Together they prove that:

\[
D:
\{0,\ldots,255\}^{384}
\longrightarrow
\{0,\ldots,4095\}^{256}
\]

is a bijection, with \(E\) as its inverse.

The domain cardinalities agree:

\[
256^{384}
=
2^{3072},
\]

\[
4096^{256}
=
2^{12\cdot256}
=
2^{3072}.
\]

### 11.5 Why the campaign did not stop after T2 or T3

#### Why T2 was insufficient

T2 proves local routing and isolation, but it does not explicitly establish:

- a complete full-array inverse;
- surjectivity onto every raw polynomial;
- an independent encoder relation;
- global round-trip recovery.

#### Why T3 was insufficient

T3 establishes exact differential conservation and injectivity for arbitrary selected blocks, but injectivity alone does not explicitly establish surjectivity.

PFB-T3.P2 says distinct blocks decode to distinct pairs. It does not, by itself, state that every possible 12-bit pair has a corresponding input block.

T4.P2 closes that direction.

#### Why T4 remained useful even though it follows from T1 mathematically

T4 was not added to manufacture an unrelated theorem. It was added because it uses:

- a different harness shape;
- a separate independent arithmetic encoder;
- whole-array and whole-polynomial domains;
- two converse compositions;
- different mutation channels;
- global bijection wording that is directly understandable in a thesis.

Therefore T4 materially strengthens the assurance case even though its algebraic truth is compatible with, and derivable from, exact T1 semantics.

### 11.6 Results

| Proof unit | Theorem result | Complete result |
|---|---:|---:|
| PFB-T4.P1 arbitrary bytes | 1/1 SUCCESS | 112/112 SUCCESS |
| PFB-T4.P2 arbitrary raw polynomial | 1/1 SUCCESS | 115/115 SUCCESS |
| Concrete raw-domain controls | 8/8 assertions | 147/147 complete properties |

### 11.7 T4 control repair

The first control harness contained a 384-iteration initialisation loop while the global unwind bound was 257. All eight intended control assertions succeeded, but the unfiltered run correctly failed an unwinding assertion.

The response was fail-closed:

1. the failed property was identified as `harness.unwind.0`;
2. the successful T4 theorem results were not reclassified as a final acceptance;
3. a direct attempt with a larger global bound was rejected after CBMC exited without a result;
4. the unnecessary control-only initialisation loops were removed;
5. equivalent concrete first/last and zero/4095 witnesses were retained;
6. the corrected control completed 147/147 properties successfully.

No theorem was weakened, and the production function was not changed.

### 11.8 T4 mutation evidence

#### P1 even-decoder shift mutant

The even coefficient shift was altered.

Observed:

```text
PFB-T4.P1 = FAILURE
```

#### P2 odd-decoder shift mutant

The odd coefficient shift was altered.

Observed:

```text
PFB-T4.P2 = FAILURE
```

Both mutants produced one intended theorem failure with no CBMC errors or unknown results.

### 11.9 T4 final evidence

```text
Final acceptance:
YES

Final manifest SHA-256:
8fb1fe00f9b8bdefa99dcee6d24d9058387c15115bbe421932d7a9573b9a9706

Final archive:
PFB_T4_FINAL_FREEZE_af4c5abd_20260729T053316Z.tar.gz

Final archive SHA-256:
6f647a06f5e50206f5da21d14ba27f16f8d55d806d92bc1922e394d83a78d3c8
```

### 11.10 Exact T4 claim

> At commit `af4c5abd`, the portable public `mlk_poly_frombytes` path was verified by CBMC for the two frozen PFB-T4 two-sided raw-domain inverse obligations: arbitrary 384-byte inputs round-trip through the real decoder and an independent arithmetic raw encoder, and arbitrary raw polynomials with coefficients in \([0,4096)\) round-trip through that encoder and the real decoder, under the recorded machine model and proof configuration.

---

## 12. Complete theorem registry

| Family | Property | Meaning | Final status |
|---|---|---|---|
| T1 | P1 | exact even coefficient \(W_i\bmod4096\) | PROVED |
| T1 | P2 | exact odd coefficient \(\lfloor W_i/4096\rfloor\) | PROVED |
| T2 | P1 | first-byte bit route | PROVED |
| T2 | P2 | second-byte low-nibble route | PROVED |
| T2 | P3 | second-byte high-nibble route | PROVED |
| T2 | P4 | third-byte bit route | PROVED |
| T2 | P5 | arbitrary one-block locality | PROVED |
| T3 | P1 | arbitrary packed-output XOR conservation | PROVED |
| T3 | P2 | input block differs iff output pair differs | PROVED |
| T4 | P1 | arbitrary bytes decode/independent-encode round trip | PROVED |
| T4 | P2 | arbitrary raw polynomial independent-encode/decode round trip | PROVED |

Total:

```text
4 theorem families
11 frozen semantic obligations
11 proved obligations
```

---

## 13. Assumptions

Formal results are meaningful only when their assumptions are explicit.

### 13.1 Common object assumptions

The semantic harnesses assumed:

- the input byte array is a valid object of `MLKEM_POLYBYTES` bytes;
- the output is a valid `mlk_poly` object;
- input and output do not alias;
- the selected symbolic block, bit, byte, or coefficient index is within its frozen range.

These are normal calling-context assumptions and correspond to the function’s valid C interface.

### 13.2 T2 assumptions

T2 harnesses assumed only the differential relation necessary for the selected property, for example:

- two arrays are identical except for the selected toggled bit; or
- two arrays may differ only inside one selected block.

The result itself was not assumed.

### 13.3 T4.P2 domain assumption

Each nondeterministic source coefficient satisfied:

\[
0\le p_i<4096.
\]

This is the complete raw 12-bit domain.

No assumption restricted the coefficients to:

\[
[0,q)
=
[0,3329).
\]

### 13.4 No canonical-input assumption for T1, T2, T3, or T4.P1

Arbitrary input bytes were permitted. Inputs representing raw coefficients from 3329 through 4095 were not excluded.

### 13.5 Machine and verification assumptions

The conclusions depend on:

- CBMC’s modelling and solver soundness;
- the recorded compiler/GOTO construction;
- the recorded machine model;
- the C integer-width and signedness interpretation used by the GOTO program;
- the configured portable implementation path;
- complete loop unwinding as checked by unwinding assertions;
- the integrity of the pinned source and generated GOTO binaries.

The final seal records the exact CBMC, `goto-cc`, operating-system, and Python version outputs.

### 13.6 Parameter-set boundary

The executed initial configuration was portable ML-KEM-768 (`MLKEM_K=3`).

The raw polynomial constants used by this function are shared across ML-KEM parameter sets, but the campaign did not execute separate final freezes for `MLKEM_K=2` or `MLKEM_K=4`. The report therefore does not silently promote the result to those configurations.

---

## 14. Forbidden assumptions and transformations

The following were prohibited:

- `__CPROVER_assume(false)`;
- contradictory assumptions;
- assumptions that directly encode the expected result;
- tautological assertions;
- target-function stubbing;
- replacement of the target call with a contract;
- application of loop contracts instead of executing the loops;
- production-source modification;
- calling the target from its own oracle;
- using production `mlk_poly_tobytes` as the independent encoder;
- copying the target’s mask-and-shift code into the oracle;
- claiming native-backend verification;
- claiming FIPS canonicalisation;
- treating generic memory safety as a new semantic theorem family.

---

## 15. CBMC execution model

### 15.1 Bit-precise exhaustive checking

CBMC translates the C program, assumptions, assertions, and unwound loops into a bit-precise decision problem.

For these fixed-size loops and arrays, a successful complete run with unwinding assertions means the checked property is exhaustive over the represented finite domain, rather than based on sampled inputs.

### 15.2 Common checks

The semantic campaigns used the relevant combination of:

```text
--object-bits 8
--slice-formula
--unwinding-assertions
--bounds-check
--pointer-check
--pointer-overflow-check
--signed-overflow-check
--unsigned-overflow-check
--conversion-check
--undefined-shift-check
--div-by-zero-check
--float-overflow-check
--nan-check
```

The accepted direct runs used the default SAT backend. Bitwuzla-specific execution was not used as the authority after initial configuration problems.

### 15.3 Loop bounds

The main decoder loop executes 128 iterations.

The campaign used:

- unwind 129 for theorem families whose largest relevant loop required 128 iterations;
- unwind 257 for T4 harnesses containing 256-iteration coefficient loops;
- explicit unwinding assertions.

The T4 control issue demonstrated why unfiltered unwinding assertions were retained: an intended assertion can pass while an auxiliary loop is insufficiently unwound.

### 15.4 Theorem-only and unfiltered runs

Each family used two views:

1. theorem-only runs, selecting the frozen semantic assertions;
2. complete unfiltered runs, checking semantic, memory, pointer, conversion, overflow, shift, and unwind properties together.

Final acceptance required both views.

---

## 16. Non-vacuity, reachability, and boundary evidence

A successful assertion can be meaningless if its assumptions are contradictory or its relevant state is unreachable.

The campaign therefore included concrete controls that:

- used no assumptions where practical;
- exercised first, last, and middle blocks;
- exercised low and high bit positions;
- demonstrated zero and maximum raw values;
- demonstrated equal-input and changed-input cases;
- showed selected outputs were nonconstant;
- checked coefficients around a selected pair;
- checked input frame preservation and output canaries where used;
- confirmed the public call and portable body remained reachable.

The controls were not counted as additional theorem families.

---

## 17. Mutation sensitivity

### 17.1 Purpose

Mutation testing answered:

> Would the frozen assertions reject plausible implementation faults, or would they remain successful because the harness was weak, vacuous, or coupled to the implementation?

### 17.2 Isolation

Every source mutant was created in a detached Git worktree.

After each mutant run:

- the mutant worktree was removed;
- the original worktree’s production hashes were checked;
- T1–T4 baseline artifact hashes were checked;
- the authoritative repository was checked for cleanliness.

### 17.3 Summary

| Family | Mutants | Result |
|---|---:|---|
| T1 | 2 | both killed with selective failures |
| T2 | 5 | all killed; each route mutant failed its intended property |
| T3 | 2 | both killed with logic-aware outcomes |
| T4 | 2 | both killed |
| **Total** | **11** | **11 killed** |

The number of source mutants happens to equal the number of semantic obligations, but the campaign did not force a one-to-one structure where logic made that inappropriate. T3 correctly recorded that a collision-causing mutation must break both P1 and P2.

---

## 18. Why the harnesses are genuinely distinct from upstream `mlkem-native`

### 18.1 Upstream verification baseline

The pinned `mlkem-native` repository states that its C code is verified with CBMC for memory safety and type safety and that its CBMC infrastructure builds on source-level function contracts and loop invariants.

The upstream CBMC README explains that:

- proofs are organised by function;
- specifications are embedded in production C contracts and loop annotations;
- harnesses are intended to be boilerplate and do not add the specification;
- the primary documented purpose is absence of specified classes of undefined behaviour.

For `mlk_poly_frombytes_c`, the visible upstream source contract at the pinned commit states:

- valid non-aliasing objects;
- assignment of the output polynomial;
- an output range of raw 12-bit coefficients.

It does not state:

- exact even and odd decoding equations;
- bit-route identities;
- arbitrary block locality;
- differential XOR conservation;
- blockwise injectivity;
- two-sided inverse laws using an independent encoder.

### 18.2 Distinct verification intent

The new PFB harness family does not merely invoke the same function with the same contract.

It adds explicit semantic assertions against a frozen mathematical intent.

### 18.3 Distinct oracle design

The PFB oracle:

- uses widened arithmetic;
- uses multiplication, division, and remainder;
- is not copied from the target expression;
- does not call the target;
- does not call production `mlk_poly_tobytes`.

### 18.4 Distinct relational structure

Upstream boilerplate function harnesses typically execute a function once under its contract.

PFB includes harnesses that execute:

- two related inputs for bit influence;
- two arbitrary inputs for differential conservation;
- paired executions for locality;
- decode/encode and encode/decode compositions.

### 18.5 Distinct evidence controls

PFB additionally requires:

- theorem freeze before harness acceptance;
- source hash binding;
- GOTO call-chain inspection;
- theorem-only and complete runs;
- non-vacuity controls;
- boundary witnesses;
- obligation-sensitive source mutations;
- post-mutation rebinding;
- deterministic manifests;
- family archives;
- a campaign-level final seal.

### 18.6 No production-code adaptation

The production C implementation was not rewritten to make CBMC succeed.

The PFB proof artifacts are distinct because they surround the unchanged target with new semantic verification contexts. They do not create a new version of `mlk_poly_frombytes`.

---

## 19. Did the campaign really prove `mlk_poly_frombytes`?

### 19.1 Direct answer

**Yes, for the frozen raw-decoding specification and the eleven stated obligations, under the recorded assumptions and portable ML-KEM-768 configuration.**

### 19.2 Why this is a real proof rather than testing

The harness inputs are nondeterministic. CBMC reasons over all represented values.

Examples include:

- arbitrary 384-byte arrays;
- arbitrary pairs of 384-byte arrays;
- arbitrary valid block indices;
- arbitrary valid bit positions;
- arbitrary 256-coefficient raw polynomials with every coefficient in `[0,4096)`.

The successful results therefore do not mean “the test cases passed.” They mean CBMC found no counterexample in the complete finite domain represented by the theorem, after complete loop unwinding was checked.

### 19.3 Strength of T1 and T4 together

T1 directly proves the coefficient equations.

T4 proves that the actual decoder and an independent arithmetic encoder are mutual inverses over both complete raw domains.

Together they provide a particularly strong case that the portable C body is the intended raw unpacker.

### 19.4 Why the statement must remain property-specific

Formal verification is never absolute.

The campaign did not formalise every possible property of the function or its environment. Consequently, the academically correct wording is:

```text
verified for the eleven frozen PFB obligations
```

rather than:

```text
proved completely correct in every possible sense.
```

### 19.5 Recommended verbal answer to a professor

> Functional correctness of the pinned portable `mlk_poly_frombytes` path as a raw 12-bit unpacker was proved. The proof is exhaustive for the eleven frozen properties and the recorded C machine model. It includes direct arithmetic semantics and a two-sided inverse with an independent encoder. The record does not claim that the function alone performs FIPS canonicalisation, that the native backend was proved, or that every possible property of the function was formalised.

---

## 20. Rationale for continuing beyond earlier stages

### 20.1 Stopping after T1

T1 alone is mathematically strong, but a single direct oracle can contain a transcription mistake or hide weak diagnostics.

T2–T4 provide differently shaped checks and mutation evidence.

### 20.2 Stopping after T2

T1 plus T2 establishes exact values, routing, and locality, but no explicit whole-domain inverse with an independent encoder.

### 20.3 Stopping after T3

T3 provides arbitrary differential conservation and injectivity, but no explicit right-inverse theorem showing that every raw polynomial is produced by some encoding.

### 20.4 Why T4 was the correct closure

T4 makes the global structure explicit:

```text
bytes ↔ raw 12-bit polynomial
```

It proves both directions over complete domains and gives the campaign a clean algebraic endpoint.

### 20.5 Completion criterion after T4

After T4, additional raw-decoder semantic families would mainly be restatements.

Further work would require a new scope, such as:

- FIPS modulo-\(q\) refinement;
- public-key canonicality checking;
- production `mlk_poly_tobytes`;
- native backend equivalence;
- all three parameter-set builds;
- constant-time or side-channel claims.

Those are separate campaigns and should not be appended merely to increase the theorem count.

---

## 21. Fail-closed execution history

The campaign did not treat every script completion as authoritative.

### 21.1 T1 solver/configuration issue

An early Bitwuzla-configured execution produced solver/configuration errors.

The response was:

- no theorem acceptance;
- direct default-SAT execution;
- theorem and complete-property rechecking;
- default SAT recorded as the authority.

### 21.2 T2 XML parser defect

The T2 semantic runs succeeded, but the evidence parser failed to emit assertion status fields for unfiltered runs.

The response was:

- classify as parser-only;
- no CBMC rerun;
- direct XML reparse;
- artifact rebinding;
- corrected evidence seal.

### 21.3 T4 comment-audit false positive

A broad text search interpreted the words `mlk_poly_tobytes` in a harness comment as a function call.

The response was:

- no theorem execution was accepted from that stopped run;
- the audit was narrowed to function-call syntax;
- the comment was no longer treated as executable code.

### 21.4 T4 control unwinding failure

All eight control assertions succeeded, but the unfiltered run reported `harness.unwind.0`.

The response was:

- no final T4 acceptance;
- direct failed-property diagnosis;
- preservation of successful P1/P2 theorem evidence;
- removal of unnecessary control-only loops;
- complete corrected control run.

### 21.5 Final-seal archive-hash field issue

The first master-seal command expected each acceptance report to contain a field written only after the report itself had been generated.

The response was:

- no campaign seal;
- use of the exact already accepted archive hashes;
- full revalidation of all family manifests and archives;
- successful corrected final seal.

These incidents are useful evidence of a genuine fail-closed workflow. The verification process rejected its own bookkeeping and control problems instead of converting them into successful proof claims.

---

## 22. Evidence hierarchy

The campaign distinguishes different kinds of authority.

### 22.1 Primary authority

- pinned production source;
- CBMC theorem XML;
- unfiltered complete-property XML;
- GOTO programs;
- source and artifact hashes.

### 22.2 Supporting evidence

- parsed summaries;
- control results;
- mutation diffs;
- mutation XML;
- call-graph dumps;
- terminal transcripts;
- acceptance reports.

### 22.3 Integrity evidence

- family `SHA256SUMS.txt` manifests;
- family archive hashes;
- authoritative Git status;
- final campaign archive index;
- final campaign seal.

### 22.4 Reporting limitation

This report is grounded in the terminal outputs, retained execution records, acceptance reports, manifests, and final seal produced during the campaign.

The reporting environment did not independently re-extract every final tar archive byte-for-byte. The campaign’s own final-seal process recalculated and matched each archive hash and every internal family manifest. This report should therefore be described as a detailed evidence-backed campaign record, not as an independent third-party certification.

---

## 23. Final evidence index

### 23.1 PFB-00C theorem freeze

```text
Directory:
PFB_00C_THEOREM_FREEZE_af4c5abd

Manifest SHA-256:
0ad77b89aa6260e4021e897c7ace73e3588f2afd2c6d9cdc9a2f39a2debac8f4
```

### 23.2 PFB-T1

```text
Directory:
PFB_T1_FINAL_FREEZE_af4c5abd_20260729T043912Z

Manifest SHA-256:
53904a93bbe2b862a53539d9875932f8ba1f219a558562f936e0621998382137

Archive SHA-256:
5866529dfd01315886e0066646638efc70d9ede920ecd7df9c0a97c10e047114
```

### 23.3 PFB-T2

```text
Directory:
PFB_T2_FINAL_FREEZE_af4c5abd_20260729T050106Z

Manifest SHA-256:
492fee156a81c7c0a42fea46babdc1edc355ce9cbbc31096ac3c674e5f0af095

Archive SHA-256:
9b282ca57ea6f43e0ffa88ad6a6cd6694d7a09d52a9d1373e6e4b9dfe68c1488
```

### 23.4 PFB-T3

```text
Directory:
PFB_T3_FINAL_FREEZE_af4c5abd_20260729T051133Z

Manifest SHA-256:
dfc3927245486af7a9bf32e875a6ddee490141807cfc33c57433b2d9518a8324

Archive SHA-256:
f5d11b702eedfc2651cd860815b916c063f39efc764a98e7d06d1295df3772c4
```

### 23.5 PFB-T4

```text
Directory:
PFB_T4_FINAL_FREEZE_af4c5abd_20260729T053316Z

Manifest SHA-256:
8fb1fe00f9b8bdefa99dcee6d24d9058387c15115bbe421932d7a9573b9a9706

Archive SHA-256:
6f647a06f5e50206f5da21d14ba27f16f8d55d806d92bc1922e394d83a78d3c8
```

### 23.6 Final campaign seal

```text
Directory:
PFB_CAMPAIGN_FINAL_SEAL_af4c5abd_20260729T054222Z

Manifest SHA-256:
7a379152d41c459282da946855615ad9e480afadb5a348a3f5fc794fe6d05913

Archive SHA-256:
6d013b5e2e878a1eaf7aad166a6fff146c6e64d1eb73cd97894926488e858b72
```

---

## 24. Novelty assessment

### 24.1 Assessment method

A bounded novelty review was completed on 29 July 2026.

The review considered:

1. the pinned `mlkem-native` repository and source at commit `af4c5abd`;
2. the repository’s published CBMC scope and proof guide;
3. the exact source contract of `mlk_poly_frombytes_c`;
4. public searches for `mlk_poly_frombytes`, CBMC, raw decoding, bit routing, differential conservation, and bijection;
5. broader verified ML-KEM implementations and security proofs, including EasyCrypt/Jasmin and Hax/F* work;
6. public formal-reference projects such as LibMLKEM.

The search cannot prove the non-existence of private, unpublished, unindexed, or differently named work.

### 24.2 What is not novel

The following are not claimed as novel:

- the mathematics of packing two 12-bit integers into three bytes;
- the existence of `poly_frombytes`-style routines;
- formal verification of ML-KEM in general;
- functional verification of ML-KEM implementations in general;
- verified serialization in every implementation;
- CBMC verification of C safety;
- mutation testing as a general method;
- hash-based evidence packaging as a general method.

Broader prior work includes:

- machine-checked ML-KEM security and functional equivalence of Jasmin implementations in EasyCrypt;
- formally verified serialization and other ML-KEM components in Hax/F* implementations;
- `mlkem-native` CBMC verification of C memory and type safety;
- formally verified ML-KEM reference work in other languages and toolchains.

Consequently, the campaign must not be described as:

```text
the first formal verification of ML-KEM serialization
```

or:

```text
the first proof that ML-KEM byte decoding works.
```

### 24.3 What appears novel and defensible

The strongest novelty is the exact combination of:

- the pinned `mlkem-native` C implementation;
- the real portable public `mlk_poly_frombytes` path;
- CBMC semantic verification rather than only C safety;
- a pre-frozen four-family, eleven-obligation theorem registry;
- exact arithmetic raw-decoding assertions;
- bit-route and block-locality relations;
- arbitrary differential XOR conservation;
- explicit blockwise injectivity;
- two-sided full-domain inversion;
- an independent division-and-remainder encoder;
- no production `tobytes` oracle;
- no target call inside the oracle;
- no function-contract replacement;
- no loop-contract substitution;
- concrete non-vacuity and boundary witnesses;
- logic-aware mutation sensitivity;
- immutable source binding;
- family-level deterministic evidence freezes;
- a master campaign seal.

The bounded review did not identify a public artifact matching this exact target, commit, tool, theorem suite, oracle discipline, mutation campaign, and sealed evidence structure.

### 24.4 Novelty potency by category

| Category | Assessment | Reason |
|---|---|---|
| Mathematical novelty | Low | The raw 12-bit packing identities are established arithmetic. |
| New cryptographic algorithm | None | No algorithm was invented or modified. |
| Target-specific functional-verification artifact | High | The campaign adds an explicit semantic proof suite for the pinned real C path. |
| Property formulation | Medium to high | The combined T1–T4 architecture, especially bit routing, differential conservation, and two-sided raw inverse, was not found in the pinned upstream CBMC specification. |
| Evidence and integrity methodology | High within the case study | Freeze-before-harness, mutation sensitivity, rebinding, and master sealing form a strong reproducible campaign. |
| General worldwide-first potential | Unestablished | Public search cannot justify a global first, and related verified serialization exists elsewhere. |
| MSc thesis contribution potential | Strong | The contribution is bounded, reproducible, technically substantive, and clearly differentiated from upstream safety proofs. |

### 24.5 Exact novelty conclusion

The campaign has **strong repository-relative and artifact-level novelty**, but not established mathematical or worldwide-first novelty.

Its novelty lies in *what was explicitly specified and proved about this exact implementation path, and how that evidence was made fail-closed and reproducible*, not in inventing the underlying bit-packing mathematics.

### 24.6 Thesis-safe novelty wording

Recommended wording:

> Relative to the CBMC verification scope and source contracts available in the pinned `mlkem-native` revision, the PFB campaign contributes a distinct semantic verification layer for the portable public `mlk_poly_frombytes` path. The contribution consists of eleven explicit obligations covering exact raw decoding, bit-level influence and block locality, arbitrary differential conservation, and two-sided inversion over the complete raw 12-bit domain, together with independent arithmetic oracles, mutation-sensitivity controls, source binding, and deterministic evidence sealing. A bounded public-source review found related ML-KEM functional-verification and verified-serialization work in other implementations and toolchains, but did not identify a public artifact matching this exact target, commit, CBMC theorem suite, and evidence methodology. The novelty claim is therefore repository-relative and artifact-level rather than a claim of mathematical or worldwide priority.

### 24.7 Short novelty wording for a results chapter

> The novelty of PFB is not the 12-bit packing formula itself. It is the commit-bound CBMC semantic campaign for the unchanged `mlkem-native` public decoder path, including four complementary theorem families, eleven frozen obligations, independent arithmetic oracles, selective mutation evidence, and a fail-closed evidence seal.

### 24.8 Wording that must not be used

Do not write:

- “This is the first proof of `poly_frombytes`.”
- “No one has ever verified this function.”
- “This is the first formal verification of ML-KEM serialization.”
- “All of FIPS 203 was proved.”
- “Every `mlk_poly_frombytes` backend was proved.”
- “The function is unconditionally correct.”
- “T1–T4 are four logically independent mathematical discoveries.”

---

## 25. Comparison with relevant prior verification

| Work | Implementation/tool | Main public claim | Relationship to PFB |
|---|---|---|---|
| `mlkem-native` CBMC | production C / CBMC | memory safety and type safety using contracts and invariants | Same codebase; PFB adds explicit target-specific semantic relations. |
| `mlkem-native` HOL Light | native assembly / HOL Light | functional correctness, memory safety, constant-time properties for assembly routines | Different backend and proof infrastructure. |
| Formally Verifying Kyber | ML-KEM specification and Jasmin / EasyCrypt | security, correctness and functional equivalence for two Jasmin implementations | Broader and deeper cryptographic proof, but not the pinned `mlkem-native` C function or PFB CBMC suite. |
| Hax/F* ML-KEM work | Rust/libcrux / Hax and F* | verified field arithmetic, polynomial arithmetic, serialization, and high-level code | Demonstrates that verified serialization is not globally new; different implementation and proof language. |
| LibMLKEM | independent reference implementations | hybrid static safety verification and dynamic functional tests, with language-specific proof goals | Different implementation and assurance strategy. |
| PFB campaign | pinned `mlkem-native` portable public C path / CBMC | eleven explicit raw-decoder semantic obligations plus mutation and sealed evidence | Exact contribution documented here. |

---

## 26. Contributions of the campaign

### 26.1 Technical contribution

A semantic verification layer for an unchanged production-quality C routine.

### 26.2 Specification contribution

A compact theorem registry that turns an informal bit-unpacking routine into explicit functional, structural, relational, and inverse properties.

### 26.3 Assurance contribution

Multiple independently shaped proof obligations and targeted mutations reduce the risk that one oracle or harness mistake silently invalidates the result.

### 26.4 Reproducibility contribution

The campaign records:

- pinned commit and tree;
- source hashes;
- harness and GOTO hashes;
- solver mode;
- commands and XML;
- complete-property counts;
- control evidence;
- mutation diffs and results;
- manifests and archives;
- final seal.

### 26.5 Methodological contribution

The campaign demonstrates a deterministic integrity-firewall model in which candidate formal artifacts are not trusted merely because CBMC reports success.

The artifact must also pass:

- source binding;
- call reachability;
- assumption review;
- non-vacuity;
- complete checks;
- mutation sensitivity;
- post-run integrity;
- deterministic packaging.

---

## 27. Threats to validity

### 27.1 Tool soundness

The proof depends on CBMC, its front end, its GOTO transformation, the SAT backend, and the host toolchain.

### 27.2 Specification correctness

A formal proof can verify the wrong property perfectly.

This risk was reduced through:

- theorem freeze;
- multiple property families;
- independent arithmetic encoders;
- mutation sensitivity;
- exact exclusions.

It cannot be eliminated absolutely.

### 27.3 Configuration dependence

The accepted evidence is for the recorded portable ML-KEM-768 configuration.

### 27.4 Source-version dependence

Any source change invalidates the direct applicability of the hashes and requires rebinding and rerunning.

### 27.5 Environment dependence

Different CBMC, compiler, solver, or library versions may affect reproducibility and performance.

### 27.6 Novelty-search limitation

The novelty review is bounded to public, discoverable material available on the review date. It is not a proof that no equivalent unpublished or differently indexed artifact exists.

### 27.7 Reporting independence

The campaign was internally verified and sealed. It has not yet been independently reproduced by a third party.

---

## 28. Recommended professor-facing interpretation

The campaign should be presented as a **function-level semantic verification case study**.

The strongest academically supportable interpretation is:

1. upstream `mlkem-native` already provides a high-assurance baseline;
2. the PFB work does not claim to replace or surpass the project’s complete verification strategy;
3. the campaign identifies a narrower semantic layer not expressed by the visible raw-output-bound contract;
4. it constructs explicit candidate artifacts for that layer;
5. CBMC proves them over complete finite domains;
6. controls and mutations test whether the proof artifacts are meaningful;
7. deterministic packaging preserves the evidence and boundaries.

This positioning directly supports a thesis about AI-assisted or tool-assisted formal-artifact generation with deterministic verification authority and documented acceptance controls.

---

## 29. Anticipated examiner questions

### Q1. Did the campaign alter the actual `mlkem-native` C implementation?

No. Production source hashes were checked before and after every accepted stage. Mutations were isolated to detached worktrees.

### Q2. Did CBMC prove only the harness?

CBMC always proves assertions in a verification program, but the assertions called the real public function and the GOTO call graph confirmed the portable implementation body was present. The harness did not replace the body.

### Q3. Could the assumptions force success?

The permitted assumptions were limited to valid objects, non-aliasing, valid symbolic indices, frozen differential relations, and the T4 raw coefficient domain. Contradictory and expected-result assumptions were forbidden. Concrete no-assumption controls and mutations further tested non-vacuity.

### Q4. Why not call production `mlk_poly_tobytes` for T4?

That would make the result a mutual-consistency proof between two production routines. Both routines could share the same mistake. The independent encoder avoided that circularity.

### Q5. Does T4 prove FIPS `ByteDecode12`?

No. It proves a bijection over the raw 12-bit domain. FIPS modular interpretation and canonicality are explicitly excluded.

### Q6. Is T3.P2 redundant?

It is logically implied by T3.P1, but it is retained as a direct injectivity statement and diagnostic obligation. The dependency is disclosed.

### Q7. Are T2–T4 redundant with T1?

They are mathematical consequences or reformulations of exact semantics, but they provide independent harness structures, relational executions, oracles, controls, and mutations. Their value is assurance diversity and diagnosability.

### Q8. Is the work novel?

The exact repository-relative artifact and methodology appear novel under a bounded public review. The underlying arithmetic and the general idea of verified serialization are not novel. No world-first claim is justified.

### Q9. Can the result be applied automatically to a later commit?

No. The source must be rebound and the campaign rerun.

### Q10. Can the result be applied automatically to ML-KEM-512 and ML-KEM-1024?

The function structure is largely parameter-set invariant, but only the recorded ML-KEM-768 build was finally accepted. Separate builds are required before making a three-parameter-set execution claim.

---

## 30. Reproduction and publication checklist

Before publication:

- [ ] preserve the four final family archives;
- [ ] preserve the final campaign seal archive;
- [ ] preserve the exact archive hashes;
- [ ] preserve the pinned source commit;
- [ ] preserve the tool environment file;
- [ ] include the theorem registry;
- [ ] include the scope-and-nonclaims file;
- [ ] include the verification-intent JSON;
- [ ] include theorem and complete XML;
- [ ] include mutation diffs and XML;
- [ ] include control XML;
- [ ] include source and GOTO hashes;
- [ ] state the ML-KEM-768 portable configuration;
- [ ] avoid all prohibited novelty wording;
- [ ] distinguish raw 12-bit decoding from FIPS modulo-\(q\) decoding;
- [ ] invite independent reproduction.

---

## 31. Final conclusion

The PFB campaign successfully verified the pinned portable public `mlk_poly_frombytes` path as an exact raw 12-bit decoder for the eleven frozen semantic obligations.

The evidence establishes:

- exact per-block arithmetic decoding;
- exact bit routing;
- arbitrary one-block locality;
- arbitrary differential conservation;
- blockwise injectivity;
- two-sided inversion between all 384-byte strings and all 256-coefficient raw 12-bit polynomials.

The proof is exhaustive within the recorded CBMC machine model and assumptions.

The result is substantially stronger than a range-only, memory-safety-only, type-safety-only, or test-vector-only claim. It remains deliberately narrower than complete FIPS 203 decoding, native-backend correctness, or whole-ML-KEM correctness.

The campaign’s most defensible novelty is repository-relative and artifact-level: a commit-bound semantic CBMC verification suite for the unchanged real decoder path, combined with independent oracles, non-vacuity controls, targeted mutation sensitivity, immutable evidence binding, and deterministic sealing.

The campaign is complete and accepted.

---

## 32. External references used for context and novelty assessment

1. National Institute of Standards and Technology (2024), **FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard**. [NIST publication page](https://csrc.nist.gov/pubs/fips/203/final).

2. PQ Code Package (2026), **mlkem-native at commit `af4c5abd`**. [Pinned repository tree](https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304).

3. PQ Code Package (2026), **`compress.c` at commit `af4c5abd`**. [Pinned source file](https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/mlkem/src/compress.c).

4. PQ Code Package (2026), **CBMC proof infrastructure at commit `af4c5abd`**. [Pinned CBMC proof directory](https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc).

5. Kroening, D., Schrammel, P. and Tautschnig, M. (2023), **CBMC: The C Bounded Model Checker**. [arXiv record](https://arxiv.org/abs/2302.02384).

6. Almeida, J.B. et al. (2024), **Formally Verifying Kyber: Episode V — Machine-checked IND-CCA security and correctness of ML-KEM in EasyCrypt**. [IACR artifact](https://artifacts.iacr.org/crypto/2024/a3/).

7. PQ Code Package (2026), **rust-libcrux ML-KEM verification status**. [Repository](https://github.com/pq-code-package/rust-libcrux).

8. AWS Labs (2026), **LibMLKEM — formal reference implementation project**. [Repository](https://github.com/awslabs/LibMLKEM).

---

## Appendix A. Canonical evidence hashes

```text
SOURCE COMMIT
af4c5abdd5958bdc65a03cd5ee86708264f93304

SOURCE TREE
54805daff6a91a010c05467ea678117c42a71559

PFB-00C MANIFEST
0ad77b89aa6260e4021e897c7ace73e3588f2afd2c6d9cdc9a2f39a2debac8f4

PFB-T1 MANIFEST
53904a93bbe2b862a53539d9875932f8ba1f219a558562f936e0621998382137

PFB-T1 ARCHIVE
5866529dfd01315886e0066646638efc70d9ede920ecd7df9c0a97c10e047114

PFB-T2 MANIFEST
492fee156a81c7c0a42fea46babdc1edc355ce9cbbc31096ac3c674e5f0af095

PFB-T2 ARCHIVE
9b282ca57ea6f43e0ffa88ad6a6cd6694d7a09d52a9d1373e6e4b9dfe68c1488

PFB-T3 MANIFEST
dfc3927245486af7a9bf32e875a6ddee490141807cfc33c57433b2d9518a8324

PFB-T3 ARCHIVE
f5d11b702eedfc2651cd860815b916c063f39efc764a98e7d06d1295df3772c4

PFB-T4 MANIFEST
8fb1fe00f9b8bdefa99dcee6d24d9058387c15115bbe421932d7a9573b9a9706

PFB-T4 ARCHIVE
6f647a06f5e50206f5da21d14ba27f16f8d55d806d92bc1922e394d83a78d3c8

FINAL CAMPAIGN SEAL MANIFEST
7a379152d41c459282da946855615ad9e480afadb5a348a3f5fc794fe6d05913

FINAL CAMPAIGN SEAL ARCHIVE
6d013b5e2e878a1eaf7aad166a6fff146c6e64d1eb73cd97894926488e858b72
```

---

## Appendix B. One-paragraph professor summary

At the pinned `mlkem-native` commit `af4c5abd`, a clean-room CBMC semantic-verification campaign was developed and executed for the unchanged portable public `mlk_poly_frombytes` path. Four frozen theorem families containing eleven obligations proved exact raw 12-bit coefficient decoding, exact bit influence and block locality, arbitrary differential conservation and blockwise injectivity, and two-sided inversion between all 384-byte inputs and all raw 256-coefficient polynomials in `[0,4096)`. The proofs used the real public call path, independent widened-arithmetic or division-and-remainder oracles, complete loop unwinding with unwinding assertions, full memory and integer checks, concrete non-vacuity and boundary witnesses, eleven targeted detached-worktree source mutants, immutable source and artifact hashes, family-level evidence archives, and a campaign-level final seal. The result is a strong repository-relative semantic-verification contribution, distinct from upstream range and C-safety contracts, but it is not presented as new bit-packing mathematics, a worldwide first, native-backend verification, full FIPS `ByteDecode12` canonicalisation, or proof of production `mlk_poly_tobytes`.
