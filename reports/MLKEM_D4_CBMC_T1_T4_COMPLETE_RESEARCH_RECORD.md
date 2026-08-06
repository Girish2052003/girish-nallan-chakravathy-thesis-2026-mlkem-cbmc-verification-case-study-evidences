# ML-KEM D4 Portable-C Compression/Decompression Verification Campaign

## Complete Research Record for POLYCOMP-D4-T1, T2, T3 and T4

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Repository:** `pq-code-package/mlkem-native`  
**Pinned commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration:** ML-KEM-768 (`MLKEM_K=3`)  
**Verification engine:** CBMC 6.9.0  
**Campaign dates:** 25–26 July 2026  
**Campaign root:** `/home/girish/THESIS-2026/mlk_polycomp_d4_cleanroom`  
**Document status:** Consolidated technical record based on the completed T1–T4 evidence campaigns and the independently inspected T3 and T4 final archives.

---

## 1. Purpose of this document

This document records the complete clean-room verification campaign performed for the portable-C D4 polynomial compression and decompression functions in `mlkem-native`. It documents:

- the exact implementation and source revision that were verified;
- the mathematical specification used for the D4 codec;
- why the work was divided into four theorems;
- what each theorem proves and does not prove;
- all material assumptions and bounded-model-checking conditions;
- non-vacuity, reachability, mutation and relational checks;
- the distinction between the new harnesses and the native `mlkem-native` proof infrastructure;
- the evidence packages, hashes and known packaging issues;
- the status of the separate `mlk_poly_frommsg` question;
- a careful novelty assessment;
- the exact claims that can be presented to a supervisor or examiner.

The central conclusion is that the campaign established a strong, commit-pinned functional characterization of the **portable-C D4 codec pair** for ML-KEM-768. The result is not a proof of all of ML-KEM, all compression modes, all parameter sets, all backends, or all security properties.

---

## 2. Executive conclusion

The campaign established the following four-layer theorem suite:

| Theorem | Target | Domain | Main result |
|---|---|---|---|
| **T1** | `mlk_poly_compress_d4_c` | All canonical 256-coefficient polynomials | Every one of the 128 output bytes equals an independently written D4 compression-and-packing specification. |
| **T2** | `mlk_poly_decompress_d4_c` | All 128-byte arrays | Every one of the 256 output coefficients equals an independently written nibble-decoding and D4 decompression specification. |
| **T3** | `compress_d4(decompress_d4(B))` | All 128-byte arrays | Exact byte-for-byte retraction: every compressed representation survives decompression followed by recompression. |
| **T4** | `decompress_d4(compress_d4(A))` | All canonical 256-coefficient polynomials | The composition is a 16-level quantizer projection with exact image, a sharp modular error bound of 104, fixed-point characterization, idempotence and coordinate locality. |

Accordingly, the answer to “did this campaign prove the D4 compressor and decompressor?” is:

> **Yes, within the exact registered scope:** the campaign proved functional refinement of the pinned portable-C D4 compressor and decompressor, exact retraction on the compressed-byte domain, and the lossy projection semantics on the canonical-polynomial domain.

The answer must always retain these qualifications:

- only the functions `mlk_poly_compress_d4_c` and `mlk_poly_decompress_d4_c`;
- only the pinned commit;
- only the ML-KEM-768 build configuration used in the campaign;
- only canonical compressor inputs where required;
- no claim of native/assembly equivalence;
- no claim of constant-time verification;
- no claim of complete ML-KEM correctness or cryptographic security.

---

## 3. Why D4 was selected

### 3.1 Parameter-set relevance

In the pinned source, ML-KEM-768 is compiled with:

```text
MLKEM_K = 3
MLKEM_N = 256
MLKEM_Q = 3329
MLKEM_DU = 10
MLKEM_DV = 4
MLKEM_POLYCOMPRESSEDBYTES_D4 = 128
```

Thus, the ciphertext polynomial using `d_v` is compressed with four bits per coefficient. Two compressed coefficients are packed into each byte, so 256 polynomial coefficients become 128 bytes.

D4 is not an arbitrary toy format. It is the actual four-bit quantization mode used by the selected ML-KEM-768 configuration. The same D4 mode is also relevant to ML-KEM-512, while ML-KEM-1024 uses `d_v=5`; however, this campaign compiled and verified `MLKEM_K=3`, so it does not automatically prove the ML-KEM-512 or ML-KEM-1024 configurations.

### 3.2 Verification value

D4 was particularly suitable for a rigorous case study because it combines several verification dimensions in a small but non-trivial implementation:

- arithmetic quantization over the field modulus `q=3329`;
- rounding;
- four-bit value constraints;
- coefficient-to-nibble mapping;
- pairwise nibble packing;
- byte-to-coefficient decoding;
- total output overwrite;
- exact and lossy compositions;
- relational locality;
- finite-domain boundary analysis;
- an attainable worst-case error bound.

This made it possible to construct a coherent theorem family rather than proving only a single assertion.

---

## 4. Mathematical model

Let:

```text
q = 3329
d = 4
```

For a canonical coefficient:

```text
0 <= u < q
```

the independent scalar D4 compressor used by the campaign was:

```text
Compress4(u) = floor((16*u + 1664) / 3329) mod 16
```

where `1664 = floor(q/2)`.

For a four-bit value:

```text
0 <= v < 16
```

the independent D4 decompressor was:

```text
Decompress4(v) = floor((3329*v + 8) / 16)
```

The exact D4 decompressor image, or codebook, is:

```text
0, 208, 416, 624, 832, 1040, 1248, 1456,
1665, 1873, 2081, 2289, 2497, 2705, 2913, 3121
```

The polynomial-domain projection is:

```text
Q(A) = DecompressD4(CompressD4(A))
```

applied coordinate-wise through the real production implementation.

The modular distance used in T4 was:

```text
dist_q(a,b) = min(abs(a-b), q-abs(a-b))
```

for canonical values modulo `q`.

---

## 5. Why the campaign contains exactly four theorems

The four theorems form a minimal, logically separated assurance ladder for a lossy codec pair.

### 5.1 T1 answers the encoder question

T1 establishes that the compressor calculates the intended quantized nibble for every coefficient and packs each adjacent pair into the intended byte. Without T1, later composition results could pass because two incorrect functions compensate for one another.

### 5.2 T2 answers the decoder question

T2 establishes that every input nibble is extracted correctly and mapped to the intended decompressed coefficient. Without T2, T3 could again pass through compensating compressor/decompressor errors.

### 5.3 T3 answers the representation-retraction question

T3 proves:

```text
CompressD4(DecompressD4(B)) = B
```

for every 128-byte array.

This is an exact property because every four-bit code is valid and the decompressor chooses a representative that recompresses to the same code.

### 5.4 T4 answers the lossy-projection question

T3 is not sufficient to characterize what happens to an arbitrary canonical polynomial. Compression is lossy, so in general:

```text
DecompressD4(CompressD4(A)) != A
```

T4 therefore proves what the opposite composition actually means:

- the output lies in the exact D4 codebook;
- the modular error is never greater than 104;
- 104 is attainable and is therefore a sharp bound;
- exactly the codebook values are unchanged;
- projecting twice is the same as projecting once;
- each output coordinate depends only on its corresponding input coordinate.

T4 was necessary because stopping after T3 would have characterized only the already-compressed representation domain. It would not have established the approximation semantics of the codec on the polynomial domain, which is the main mathematical meaning of lossy compression.

---

## 6. Clean-room and trust-boundary protocol

The campaign followed a terminal-first, fail-closed workflow.

### 6.1 Source binding

Every theorem was tied to:

```text
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

Both the authoritative source tree and the isolated work repository were checked for the expected commit and production-source cleanliness.

Important production files were hash-compared between the authoritative and work trees, including:

```text
mlkem/src/compress.c
mlkem/src/compress.h
mlkem/src/params.h
mlkem/src/poly.h
mlkem/src/cbmc.h
mlkem/src/verify.h
```

### 6.2 No production modification

The theorem harnesses, companion harnesses, local mutations and build files were added under proof/work directories. The production implementation was not patched to make any theorem pass.

### 6.3 No copying of a native harness as the new result

The native repository was inspected to identify existing proof directories, contracts, tests and assembly proofs. The new theorem harnesses were written as clean-room artefacts around:

- the production source;
- the FIPS 203 compression/decompression semantics;
- independent formulas;
- independently chosen relational and mutation properties.

The existence of native proof directories was not concealed. The distinction is property-level and evidence-level, not merely the creation of another file called a harness.

### 6.4 Independent oracles

T1 and T2 compared production outputs against independent calculations rather than asserting only source-contract postconditions.

T3 and T4 called the real production functions directly, with separate finite derivations used to check scalar and byte-level mathematics.

### 6.5 Loop completeness

Loops were enumerated from the generated GOTO program. Explicit unwindsets and `--unwinding-assertions` were used for decisive semantic and strict runs.

This is important because a bounded proof with incomplete unwinding could pass only because relevant loop iterations were not explored.

### 6.6 Strict checks

In addition to semantic assertions, strict runs enabled applicable checks such as:

- bounds checks;
- pointer checks;
- signed and unsigned overflow checks;
- conversion checks;
- undefined-shift checks;
- pointer-overflow checks;
- division-by-zero checks.

### 6.7 Non-vacuity

The campaign did not accept a successful assertion alone. It also used:

- location coverage;
- inserted final `assert(false)` reachability checks;
- mutation detection;
- relational companion harnesses;
- concrete witnesses.

### 6.8 Evidence freezing

Final stages produced:

- source and artefact hashes;
- result JSON;
- loop maps;
- coverage and reachability evidence;
- harness and GOTO binaries;
- exact scripts where packaging succeeded;
- SHA-256 manifests;
- deterministic archives;
- extraction-and-reverification checks;
- read-only final package trees.

---

# Part I — T1: Portable-C Packed Compressor Refinement

## 7. T1 registered theorem

```text
T1_ID=POLYCOMP-D4-T1
T1_NAME=Portable-C packed compressor refinement
T1_DOMAIN=All canonical 256-coefficient polynomials
T1_PRIMARY_CLAIM=All 128 produced bytes equal an independent ByteEncode_4(Compress_4(A)) specification
T1_OBLIGATIONS=full-byte-refinement;coordinate-to-nibble;pair-packing;complete-overwrite-independence;relational-nibble-locality
```

## 8. T1 input assumptions

For every coefficient:

```text
0 <= A[i] < 3329
```

This is not an arbitrary strengthening. The production function contract itself requires unsigned canonical coefficients.

The input polynomial and 128-byte destination were separate valid objects. The harness did not assume the theorem conclusion.

## 9. T1 independent specification

For byte index `j`:

```text
low  = Compress4(A[2*j])
high = Compress4(A[2*j+1])

SpecByte[j] = low | (high << 4)
```

The theorem asserted:

```text
ProductionByte[j] == SpecByte[j]
```

for all 128 bytes.

## 10. T1 verified properties

T1 established:

1. all 128 produced bytes match the independent specification;
2. each even coefficient maps to the low nibble of its byte;
3. each odd coefficient maps to the high nibble;
4. pair packing is correct;
5. the output is completely overwritten and does not depend on prior destination contents;
6. relational nibble locality:
   - equal relevant input coefficients produce equal corresponding packed nibbles;
7. the positive assertion is reachable;
8. the verification is sensitive to several implementation faults.

## 11. T1 evidence

Final machine validation recorded:

```text
POSITIVE_SEMANTIC_PROPERTY=SUCCESS
POSITIVE_STRICT_PROPERTIES=108/108 SUCCESS
LOCATION_COVERAGE=24/24 SATISFIED
POSITIVE_END_REACHABILITY=PASS
BITFLIP_MUTATION_DETECTED=PASS
RELATIONAL_SEMANTIC_PROPERTIES=2/2 SUCCESS
RELATIONAL_STRICT_PROPERTIES=107/107 SUCCESS
RELATIONAL_END_REACHABILITY=PASS
NIBBLE_SWAP_MUTATION_DETECTED=PASS
ROUNDING_MINUS_ONE_MUTATION_DETECTED=PASS
ROUNDING_BOUNDARY_WITNESS_3225=PRESENT
ALL_REGISTERED_T1_OBLIGATIONS=CHECKED
```

The three mutation families served different purposes:

- **bit-flip mutation:** established that the byte equality oracle notices output corruption;
- **nibble-swap mutation:** established that low/high ordering is semantically checked;
- **rounding-minus-one mutation:** established sensitivity to the exact quantization boundary, with a concrete witness at coefficient `3225`.

## 12. T1 result

The accepted statement is:

> For the pinned ML-KEM-768 portable-C implementation and every canonical 256-coefficient polynomial, `mlk_poly_compress_d4_c` writes exactly the 128 bytes prescribed by the independent D4 scalar-compression and nibble-packing specification.

## 13. T1 evidence archive

```text
/home/girish/THESIS-2026/mlk_polycomp_d4_cleanroom/
POLYCOMP_D4_00H_T1_FINAL_FREEZE/
POLYCOMP_D4_T1_FINAL_EVIDENCE_20260725T171522Z.tar.gz
```

SHA-256:

```text
b9bc8d1c9a8732b10aaa4ad3c628e60e095c4f580f4be12b2e53b38f978eb1de
```

### T1 packaging note

The archive and manifest verification passed. The final run later emitted permission errors while attempting to remove an extracted read-only verification directory. This was a cleanup defect caused by read-only freezing after verification, not a semantic or CBMC theorem failure. It should still be recorded because operational cleanliness is part of reproducibility.

---

# Part II — T2: Portable-C Unpacked Decompressor Refinement

## 14. T2 registered theorem

```text
T2_ID=POLYCOMP-D4-T2
T2_NAME=Portable-C unpacked decompressor refinement
T2_DOMAIN=All 128-byte arrays
T2_PRIMARY_CLAIM=All 256 coefficients equal an independent Decompress_4(ByteDecode_4(B)) specification
T2_OBLIGATIONS=full-polynomial-refinement;exact-nibble-extraction;exact-scalar-decompression;image-membership;relational-byte-locality
```

## 15. T2 assumptions

The positive T2 harness admits every possible 128-byte array.

```text
Input domain size = 256^128 byte arrays
```

There were no input-value assumptions. The destination polynomial and input byte array were separate valid objects.

## 16. T2 independent specification

For byte index `i`:

```text
low  = B[i] & 0x0F
high = B[i] >> 4
```

Then:

```text
Expected[2*i]     = Decompress4(low)
Expected[2*i + 1] = Decompress4(high)
```

The theorem checked all 256 coefficients.

## 17. T2 verified properties

T2 established:

1. full 256-coefficient refinement;
2. exact low-nibble extraction;
3. exact high-nibble extraction;
4. exact scalar D4 decompression;
5. output membership in the 16-value D4 codebook;
6. complete output overwrite independence;
7. relational byte locality:
   - equal input bytes imply equal decoded low coefficients;
   - equal input bytes imply equal decoded high coefficients;
8. complete loop unwinding;
9. non-vacuity and mutation sensitivity.

## 18. T2 evidence

Final validation recorded:

```text
T2_DOMAIN=ALL_128_BYTE_ARRAYS
POSITIVE_SEMANTIC_PROPERTIES=3/3 SUCCESS
POSITIVE_STRICT_PROPERTIES=86/86 SUCCESS
POSITIVE_LOOP_INVENTORY=2 EXPECTED LOOPS
POSITIVE_UNWINDSET=harness.0:257,mlk_poly_decompress_d4_c.0:129
LOCATION_COVERAGE=20/20 SATISFIED
POSITIVE_END_REACHABILITY=PASS
NIBBLE_SWAP_MUTATION_DETECTED=PASS
ROUNDING_MINUS_ONE_MUTATION_DETECTED=PASS
ROUNDING_WITNESS_NIBBLE_8=PRESENT
RELATIONAL_SEMANTIC_PROPERTIES=3/3 SUCCESS
RELATIONAL_STRICT_PROPERTIES=84/84 SUCCESS
RELATIONAL_BYTE_LOCALITY=PASS
RELATIONAL_END_REACHABILITY=PASS
ALL_REGISTERED_T2_OBLIGATIONS=CHECKED
```

The mutation evidence included:

- swapped nibble extraction;
- changing the decompression rounding constant from `8` to `7`, detected with nibble `8` as a witness.

## 19. T2 result

The accepted statement is:

> For every 128-byte array, `mlk_poly_decompress_d4_c` writes the exact 256 coefficients prescribed by independent low/high nibble extraction and the D4 decompression formula.

## 20. T2 evidence archive

```text
/home/girish/THESIS-2026/mlk_polycomp_d4_cleanroom/
POLYCOMP_D4_T2_00D_FINAL_FREEZE/
POLYCOMP_D4_T2_FINAL_EVIDENCE_20260726T004328Z.tar.gz
```

SHA-256:

```text
41dfd5d6d0548f6a0d975fcdfa8592b222031192fe2e243ba3a19bc7d6af980d
```

### T2 packaging qualification

The original archive contains the proof evidence and final validation, but its `scripts/` directory is empty. This is an evidence-packaging defect, not a theorem failure.

An honest R2 repair script was produced to rebuild script provenance, but the currently recorded original archive must not be described as containing complete executed-script provenance. Before public release, the T2 package should be repaired and refrozen, or the qualification should remain visible.

This is the most important packaging caveat in the T1–T4 campaign.

---

# Part III — T3: Exact Compressed-Domain Retraction

## 21. T3 registered theorem

```text
T3_ID=POLYCOMP-D4-T3
T3_NAME=Exact compressed-domain retraction
T3_DOMAIN=All 128-byte arrays
T3_PRIMARY_CLAIM=compress_d4(decompress_d4(B)) equals B byte-for-byte
T3_OBLIGATIONS=byte-identity;nibble-preservation;cycle-stability
```

## 22. T3 assumptions

The positive, nibble-preservation and cycle-stability harnesses contain no input assumptions.

Every possible byte and every possible 128-byte input array are included.

## 23. T3 primary theorem

For every 128-byte array `B`:

```text
mlk_poly_compress_d4_c(
    mlk_poly_decompress_d4_c(B)
) = B
```

byte-for-byte.

This is a **retraction** theorem. It says that every valid D4 compressed code is preserved by the decode/re-encode cycle.

## 24. Why T3 was proved directly

T3 did not merely cite T1 and T2 as lemmas. The harness directly executed the real production decompressor and compressor in sequence.

This matters because the direct composition checks:

- actual call compatibility;
- intermediate representation compatibility;
- real memory layout;
- real packing and unpacking interaction;
- absence of unexpected composition-level failures.

T1 and T2 provide independent primitive assurance, while T3 provides direct executable composition assurance.

## 25. T3 registered companion obligations

### 25.1 Byte identity

All 128 bytes are exactly reconstructed.

### 25.2 Nibble preservation

For every byte:

```text
low(reconstructed[i])  = low(input[i])
high(reconstructed[i]) = high(input[i])
```

This is logically implied by byte identity, but it was proved explicitly because the theorem registry separately named nibble preservation.

### 25.3 Cycle stability

A second real decompression/compression cycle is stable:

```text
C(D(C(D(B)))) = C(D(B))
```

## 26. T3 finite support

The independent finite derivation established:

```text
16/16 nibble values satisfy scalar retraction
256/256 packed byte values reconstruct exactly
```

## 27. T3 evidence

Final validation recorded:

```text
T3_DOMAIN=ALL_128_BYTE_ARRAYS
FINITE_NIBBLE_RETRACTION=16/16 PASS
FINITE_BYTE_RETRACTION=256/256 PASS
POSITIVE_SEMANTIC_MAIN_PROPERTY=SUCCESS
POSITIVE_STRICT_PROPERTIES=186/186 SUCCESS
LOOP_INVENTORY=4/4 EXPECTED
LOCATION_COVERAGE=25/25 SATISFIED
POSITIVE_END_REACHABILITY=PASS
NIBBLE_SEMANTIC_PROPERTIES=2/2 SUCCESS
NIBBLE_STRICT_PROPERTIES=187/187 SUCCESS
CYCLE_SEMANTIC_PROPERTY=SUCCESS
CYCLE_STRICT_PROPERTIES=186/186 SUCCESS
DECOMPRESSION_SIDE_MUTATION_DETECTED=PASS
COMPRESSION_SIDE_MUTATION_DETECTED=PASS
ALL_REGISTERED_T3_OBLIGATIONS=CHECKED
```

### 27.1 Decompression-side mutation

After the real decompressor, the first two decoded coefficients were swapped before invoking the real compressor. The byte-retraction theorem failed as expected.

### 27.2 Compression-side mutation

After the real compressor, the nibbles of the first output byte were swapped. The byte-retraction theorem failed as expected.

These were one-sided mutations intended to prevent a false sense of security caused by coordinated or compensating errors.

## 28. T3 diagnostic correction

The initial T3 bootstrap expected three loops. Source inspection and `goto-instrument --show-loops` showed four:

- one harness loop;
- two compressor loops;
- one decompressor loop.

The firewall rejected the stage. A corrected continuation bound the four-loop inventory without changing:

- the production source;
- the positive theorem;
- the frozen harness;
- the positive GOTO artefact.

This correction is positive evidence for the fail-closed process: the campaign did not reinterpret a script error as a theorem failure or silently weaken the checks.

## 29. T3 result

The accepted statement is:

> Every possible 128-byte D4 representation is an exact fixed representation under real portable-C decompression followed by real portable-C recompression.

## 30. T3 evidence archive

```text
/home/girish/THESIS-2026/mlk_polycomp_d4_cleanroom/
POLYCOMP_D4_T3_00D_FINAL_FREEZE/
POLYCOMP_D4_T3_FINAL_EVIDENCE_20260726T023051Z.tar.gz
```

SHA-256:

```text
a7632b53d7e80bebec1fd6f908e2ebdbdaba17d25408db3f740c263c4a03c7f7
```

The retained archive was independently inspected:

- archive safety passed;
- 239/239 internal manifest entries passed;
- four exact scripts were present and syntax-valid;
- final harnesses, GOTO binaries and source bindings matched;
- archived CBMC JSON was independently reclassified;
- the theorem was closed.

---

# Part IV — T4: Quantizer Projection and Sharp Modular Distortion

## 31. T4 registered theorem

```text
T4_ID=POLYCOMP-D4-T4
T4_NAME=Quantizer projection and sharp modular distortion
T4_DOMAIN=All canonical 256-coefficient polynomials
T4_PRIMARY_CLAIM=decompress_d4(compress_d4(A)) is the D4 projection with sharp modular error at most 104
T4_OBLIGATIONS=exact-composition;image-characterization;sharp-error-bound;error-witness;fixed-point-characterization;projection-idempotence;coordinate-locality
```

## 32. T4 assumptions

For the main positive, fixed-point and idempotence harnesses:

```text
0 <= A[i] < 3329
```

For coordinate locality:

```text
0 <= A[i], B[i] < 3329
0 <= k < 256
A[k] = B[k]
```

The locality premise is the property antecedent, not an assumption of the conclusion.

The concrete sharp-witness harness and the two mutation harnesses used fixed inputs and contained no input assumptions.

## 33. T4 projection-image theorem

For every canonical input coefficient, the real composition output belongs to exactly the 16-value codebook.

The independent finite enumeration confirmed that the image over all `3329` canonical inputs is neither smaller nor larger than the codebook.

## 34. T4 sharp modular error theorem

For every canonical coefficient:

```text
dist_q(a, Q(a)) <= 104
```

The finite enumeration found:

```text
maximum modular distortion = 104
number of inputs attaining it = 17
```

The witnesses were:

```text
104, 312, 520, 728, 936, 1144, 1352, 1560,
1561, 1769, 1977, 2185, 2393, 2601, 2809, 3017, 3225
```

A separate real-function witness harness used coefficient `104` and proved that it is projected to `0`, attaining distance exactly `104`.

Therefore the bound is not merely safe; it is **sharp**.

## 35. T4 fixed-point characterization

For every canonical coefficient:

```text
Q(a) = a
```

if and only if `a` is one of the 16 D4 codebook values.

This proves both directions:

- every codebook value is stable;
- no other canonical value is stable.

## 36. T4 projection idempotence

The campaign directly executed two complete real projections and proved:

```text
Q(Q(A)) = Q(A)
```

for every canonical polynomial.

This is a defining property of a projection and explains why the codebook values are the stable image of the codec.

## 37. T4 coordinate locality

For two canonical polynomials and a valid coordinate `k`:

```text
A[k] = B[k]  =>  Q(A)[k] = Q(B)[k]
```

Both complete real projections were executed. The property establishes that unrelated coefficients do not influence the projected value at coordinate `k`.

## 38. T4 evidence

Final machine validation recorded:

```text
T4_DOMAIN=ALL_CANONICAL_256_COEFFICIENT_POLYNOMIALS
FINITE_CANONICAL_DOMAIN=3329/3329 CHECKED
PROJECTION_IMAGE=EXACT_16_VALUE_D4_CODEBOOK
SHARP_MODULAR_DISTORTION_BOUND=104
FINITE_MAXIMUM_WITNESSES=17

POSITIVE_SEMANTIC_PROPERTIES=2/2 SUCCESS
POSITIVE_STRICT_PROPERTIES=194/194 SUCCESS

SHARP_WITNESS_SEMANTIC=SUCCESS
SHARP_WITNESS_STRICT_PROPERTIES=190/190 SUCCESS

FIXED_POINT_CHARACTERIZATION_SEMANTIC=SUCCESS
FIXED_POINT_STRICT_PROPERTIES=190/190 SUCCESS

PROJECTION_IDEMPOTENCE_SEMANTIC=SUCCESS
IDEMPOTENCE_STRICT_PROPERTIES=189/189 SUCCESS

COORDINATE_LOCALITY_SEMANTIC=SUCCESS
LOCALITY_STRICT_PROPERTIES=192/192 SUCCESS

LOCATION_COVERAGE=36/36 SATISFIED
POSITIVE_END_REACHABILITY=PASS

CODEBOOK_MEMBERSHIP_MUTATION_DETECTED=PASS
DISTORTION_BOUND_MUTATION_DETECTED=PASS

ALL_REGISTERED_T4_OBLIGATIONS=CHECKED
```

## 39. T4 isolated mutation design

### 39.1 Codebook-membership mutation

For an all-zero polynomial, the real projection was calculated and one projected coefficient was changed:

```text
0 -> 1
```

Expected result:

- codebook assertion: failure;
- distortion assertion: success, because distance `1 <= 104`.

This exact separation occurred.

### 39.2 Distortion-bound mutation

For an all-zero polynomial, one projected coefficient was changed:

```text
0 -> 208
```

Expected result:

- codebook assertion: success, because `208` is a codebook value;
- distortion assertion: failure, because distance `208 > 104`.

This exact separation occurred.

These isolated mutations demonstrate that the two principal T4 assertions are not redundant copies of one another.

## 40. T4 result

The accepted statement is:

> For every canonical ML-KEM-768 polynomial, the pinned portable-C D4 compression/decompression composition is a coordinate-wise projection onto the exact 16-value D4 codebook, has a sharp modular error bound of 104, fixes exactly the codebook, is idempotent and is coordinate-local.

## 41. T4 evidence archive

```text
/home/girish/THESIS-2026/mlk_polycomp_d4_cleanroom/
POLYCOMP_D4_T4_00D_FINAL_FREEZE/
POLYCOMP_D4_T4_FINAL_EVIDENCE_20260726T032519Z.tar.gz
```

SHA-256:

```text
dcdd027f46d6a33daad9b9740a6a1649d8f08a45bdd6beea56003afdfa1e1819
```

The retained archive was independently inspected:

- the archive hash matched;
- there were 324 regular files and no unsafe members;
- 322/322 manifest entries verified;
- all four exact scripts were present and syntax-valid;
- all seven final harness hashes matched;
- all seven named GOTO hashes matched;
- all six frozen source hashes matched;
- the finite enumeration was independently reproduced;
- every semantic, strict, coverage, reachability and mutation JSON classification matched.

T4 was therefore completely closed.

---

# Part V — Combined meaning of T1–T4

## 42. What the complete theorem suite establishes

T1 and T2 separately establish the functional meaning of the two primitives.

T3 and T4 then characterize both possible compositions:

```text
Compressed bytes --decompress--> polynomial --compress--> same bytes
```

and:

```text
Canonical polynomial --compress--> bytes --decompress--> nearest D4 codebook projection
```

The resulting combined picture is:

1. the encoder is correct against an independent formula;
2. the decoder is correct against an independent formula;
3. every compressed code is stable under decoding/re-encoding;
4. every canonical polynomial is mapped to the exact quantization codebook;
5. the approximation error is tightly bounded;
6. the stable points and repeated-application behavior are characterized;
7. coordinate independence is demonstrated;
8. the assertions are reachable and mutation-sensitive.

## 43. What the suite does not establish

The suite does **not** establish:

- correctness of every compression width (`d=5`, `d=10`, `d=11`, or generic wrappers);
- correctness of ML-KEM-512 or ML-KEM-1024 builds;
- equivalence between portable C and AVX2, AArch64, RVV or VSX backends;
- correctness of assembly;
- constant-time behavior;
- absence of power, electromagnetic, speculative-execution or fault-injection leakage;
- correctness of all ML-KEM polynomial arithmetic;
- correctness of key generation, encapsulation or decapsulation;
- IND-CPA or IND-CCA security;
- the decryption-failure probability;
- correctness of `mlk_poly_frommsg`;
- correctness outside the registered canonical domain where a canonical-domain assumption was used.

---

# Part VI — Assumptions and trusted computing base

## 44. Explicit theorem assumptions

| Theorem | Assumptions |
|---|---|
| T1 | Every input coefficient is in `[0,3328]`; valid separate input/output objects; ML-KEM-768 build. |
| T2 | No byte-value assumptions; valid separate input/output objects; ML-KEM-768 build. |
| T3 | No input-value assumptions for the positive, nibble and cycle harnesses; valid separate objects; ML-KEM-768 build. |
| T4 | Canonical coefficient domain for positive/fixed/idempotence/locality; valid `k` and equal-coordinate premise for locality; ML-KEM-768 build. |

## 45. Tool and model assumptions

The proofs trust:

- the CBMC 6.9.0 implementation;
- the C front end and GOTO translation;
- solver correctness;
- the correctness of the explicit unwind plans;
- the fidelity of the independent specification encoded in the harnesses;
- the interpretation of FIPS 203 compression and decompression;
- the pinned source files and their hashes;
- the build configuration;
- the host/toolchain evidence captured in the packages.

Formal verification is not absolute. A successful CBMC result means the encoded properties hold in the analyzed finite C model under the encoded assumptions and complete bounds.

## 46. Common-mode specification risk

An independent harness is not automatically independent in the mathematical sense. The T1/T2 formulas were written separately from the production loops, but both were ultimately based on the same intended FIPS semantics.

This risk was reduced by:

- finite exhaustive scalar/byte derivations;
- explicit boundary witnesses;
- mutation detection;
- separate primitive and composition theorems;
- relational properties;
- direct inspection of the production source;
- frozen source and harness hashes.

It was not eliminated entirely.

---

# Part VII — Distinction from native mlkem-native proofs

## 47. What already existed

The pinned repository already contained eponymous CBMC proof directories including:

```text
proofs/cbmc/poly_compress_d4_c
proofs/cbmc/poly_decompress_d4_c
proofs/cbmc/poly_frommsg
```

It also contained native-backend and HOL Light proof material for optimized implementations.

Therefore, the following statements would be false or misleading:

- “there was no compressor proof”;
- “there was no decompressor proof”;
- “this was the first verification of ML-KEM compression”;
- “mlkem-native had no formal verification for these functions.”

The official `mlkem-native` documentation states that its C-level CBMC work establishes memory safety and type safety, while its assembly-level HOL Light work establishes functional correctness, memory safety and secret-independent timing for native assembly. The CBMC proof guide further describes native function harnesses as boilerplate around source-embedded contracts and as infrastructure for absence of specified undefined-behavior classes.

## 48. How the new harnesses are distinct

The new campaign is distinct in the following concrete ways.

### 48.1 Independent functional oracles

The new T1 and T2 harnesses calculate expected outputs independently and compare the complete production result against them.

### 48.2 Composition theorems

T3 and T4 directly call both real portable-C functions and prove properties of their compositions. These are not ordinary single-function safety harnesses.

### 48.3 Stronger semantic properties

The campaign includes:

- complete byte/coefficient functional refinement;
- exact compressed-domain retraction;
- explicit nibble preservation;
- cycle stability;
- exact projection image;
- sharp modular distortion;
- concrete worst-case witnesses;
- fixed-point iff characterization;
- idempotence;
- relational locality.

### 48.4 Non-vacuity evidence

The campaign pairs positive proofs with:

- location coverage;
- final reachability;
- selected fault injections;
- mutation-specific expected failures;
- preservation of unrelated assertions.

### 48.5 Pre-registered theorem structure

T1–T4 were frozen in a theorem registry before final acceptance. This reduced post-hoc theorem reshaping.

### 48.6 Evidence packaging

The campaigns use commit binding, SHA-256 hashes, manifests, deterministic archive creation, extraction verification and independent archive inspection.

### 48.7 No production-code patching

The production C implementation remained unchanged. Mutations were introduced in local companion harnesses, not in the authoritative source.

## 49. Anti-copy claim

The defensible anti-copy statement is:

> The new harnesses were authored as clean-room verification artefacts from the production source and independent mathematical specifications. Native proof directories were inspected to classify overlap, but the new theorem statements, assertions, relational constructions, mutation companions and evidence packaging were not copied from the native harnesses.

A stronger statement such as “nothing was influenced by reading the repository” would be inaccurate, because the production source, contracts and repository proof inventory were deliberately inspected.

---

# Part VIII — Novelty assessment

## 50. Novelty search method

The novelty assessment used three levels of evidence:

1. a commit-pinned repository census of source, CBMC proof directories, tests and native proof material;
2. direct comparison of the native repository’s documented CBMC scope with the new T1–T4 semantic properties;
3. targeted public-source searches, current to 26 July 2026, for ML-KEM/Kyber compression, decompression, CBMC functional correctness, projection, error bounds, idempotence and related formal-verification work.

Primary public sources considered included:

- NIST FIPS 203;
- the official `mlkem-native` repository and pinned CBMC proof tree;
- the IACR artifact for *Formally Verifying Kyber*;
- the libcrux ML-KEM verification report and repository;
- the PQ Code Package and mlkem-native verification descriptions.

## 51. What the search supports strongly

### 51.1 Strong repository-relative novelty

At the pinned commit, the repository already had native CBMC proof directories for the functions, but the new campaign’s exact T1–T4 theorem family and evidence architecture were not found as native repository artefacts.

The strongest defensible claim is therefore:

> The campaign contributes a distinct clean-room CBMC functional-theorem and evidence suite for the pinned portable-C D4 codec in `mlkem-native`.

This claim is strong because it is tied to an exact commit and a recorded repository audit.

### 51.2 Strong artefact-level novelty

The specific combination of:

- T1 primitive compressor refinement;
- T2 primitive decompressor refinement;
- T3 exact compressed-domain retraction;
- T4 canonical-domain projection with sharp error;
- relational locality;
- coverage and end reachability;
- isolated mutation discrimination;
- deterministic evidence freezing;

is a meaningful original research artefact even though individual mathematical ideas such as compression bounds or round-trip behavior are known.

### 51.3 Methodological contribution

The fail-closed workflow, theorem registry, independent oracle, non-vacuity companions and package-level provenance create a useful case-study methodology for evaluating generated formal-verification artefacts.

This methodological contribution is particularly relevant to an MSc thesis studying AI-assisted candidate harness generation under deterministic validation and documented acceptance controls.

## 52. What the search does not support

The search does **not** support claiming:

- the first formal proof of ML-KEM compression/decompression;
- the first functional-correctness proof of an ML-KEM implementation;
- the first proof of quantization error bounds for Kyber/ML-KEM;
- the first proof of compression/decompression round trips;
- the first verification of `mlkem-native`;
- the first proof of its assembly backends.

Broader projects already provide formal ML-KEM/Kyber specifications and functionally verified implementations in other languages and toolchains. For example:

- the EasyCrypt/Jasmin work formally connects verified implementations to an ML-KEM/Kyber specification;
- libcrux uses F*/hax to verify portable and optimized ML-KEM code;
- mlkem-native itself has functional HOL Light proofs for native assembly and CBMC safety/type-safety for C.

These works do not erase the repository-relative contribution, but they prevent an absolute global-first claim.

## 53. Novelty potency rating

| Novelty dimension | Assessment | Confidence |
|---|---|---|
| New exact harness/property suite at the pinned `mlkem-native` commit | **Strong and defensible** | High |
| New clean-room portable-C CBMC composition evidence for this repository revision | **Strong and defensible** | High |
| New combination of functional, relational, non-vacuity, mutation and package-integrity evidence | **Plausibly novel and research-worthy** | Medium to high |
| First use of CBMC for ML-KEM compression/decompression anywhere | **Not defensible** | High confidence that this should not be claimed |
| First formal proof of ML-KEM compression/decompression globally | **Not defensible** | High |
| First mathematical proof of the D4 error bound | **Not defensible** | High |
| Publication-level novelty beyond an MSc case study | **Possible but requires a formal literature review and external peer assessment** | Medium |

## 54. Recommended novelty statement

The following wording is suitable:

> Based on a commit-pinned audit of `mlkem-native` and a targeted search of public ML-KEM verification artefacts current to 26 July 2026, this work provides a distinct clean-room CBMC evidence suite for the pinned portable-C D4 codec. The suite combines independent full-output refinement for compression and decompression, exact compressed-domain retraction, canonical-domain projection with a sharp modular error bound, fixed-point and idempotence properties, relational locality, non-vacuity checks, isolated mutation detection and cryptographically hashed evidence packaging. The claim is repository-relative and artefact-level; it is not a claim to the first formal verification of ML-KEM compression/decompression in the wider literature.

## 55. Claims that must not be used

Do not write:

```text
This is the first proof of ML-KEM compression and decompression.
```

Do not write:

```text
mlkem-native had no proof for these functions.
```

Do not write:

```text
T1-T4 prove ML-KEM correct.
```

Do not write:

```text
CBMC proved cryptographic security.
```

Do not write:

```text
The proofs cover all parameter sets and native backends.
```

---

# Part IX — The truth about mlk_poly_frommsg

## 56. `mlk_poly_frommsg` is a different operation

`mlk_poly_frommsg` converts a 32-byte message to a 256-coefficient polynomial. In the pinned source it implements the `d=1` message mapping:

```text
Decompress_1(ByteDecode_1(msg))
```

Each message bit is mapped to one of two coefficient values, effectively:

```text
0 or 1665
```

The D4 codec instead uses four-bit quantization and a 16-value codebook.

Therefore:

```text
T1–T4 D4 proofs do not imply correctness of mlk_poly_frommsg.
```

## 57. Did this campaign prove `mlk_poly_frommsg`?

**No.**

The completed and frozen evidence packages in this record are:

```text
POLYCOMP-D4-T1
POLYCOMP-D4-T2
POLYCOMP-D4-T3
POLYCOMP-D4-T4
```

No completed clean-room `mlk_poly_frommsg` final evidence archive, final theorem verdict and final package hash are present in the current record.

Earlier exploratory work and work-repository paths relating to `frommsg` are not sufficient to claim a proof. Source analysis, theorem planning, a successful compile, or an intermediate CBMC run are not equivalent to a completed non-vacuous theorem package.

## 58. What already exists for `poly_frommsg`

The pinned `mlkem-native` repository contains:

```text
proofs/cbmc/poly_frommsg/Makefile
```

and source contracts for `mlk_poly_frommsg`.

This means that even a future `frommsg` campaign must not claim that the function had no native CBMC proof. A defensible new campaign would need to identify a distinct functional theorem, such as complete bit-to-coefficient refinement, output overwrite independence, relational bit locality, exact image characterization, and a `tomsg(frommsg(m))=m` composition theorem, while carefully separating it from the repository’s existing proof scope.

## 59. Required wording for the current thesis record

Use:

> A separate `mlk_poly_frommsg` campaign was considered and partially explored, but the current completed proof record covers only the D4 compression/decompression theorem suite T1–T4. Consequently, no new clean-room `mlk_poly_frommsg` theorem is claimed here.

---

# Part X — Evidence package register

## 60. Final archive table

| Campaign | Final archive | SHA-256 | Status |
|---|---|---|---|
| T1 | `POLYCOMP_D4_T1_FINAL_EVIDENCE_20260725T171522Z.tar.gz` | `b9bc8d1c9a8732b10aaa4ad3c628e60e095c4f580f4be12b2e53b38f978eb1de` | Accepted and frozen; cleanup permission warning recorded. |
| T2 | `POLYCOMP_D4_T2_FINAL_EVIDENCE_20260726T004328Z.tar.gz` | `41dfd5d6d0548f6a0d975fcdfa8592b222031192fe2e243ba3a19bc7d6af980d` | Theorem accepted; original archive has empty `scripts/` packaging defect. |
| T3 | `POLYCOMP_D4_T3_FINAL_EVIDENCE_20260726T023051Z.tar.gz` | `a7632b53d7e80bebec1fd6f908e2ebdbdaba17d25408db3f740c263c4a03c7f7` | Accepted, frozen and independently inspected. |
| T4 | `POLYCOMP_D4_T4_FINAL_EVIDENCE_20260726T032519Z.tar.gz` | `dcdd027f46d6a33daad9b9740a6a1649d8f08a45bdd6beea56003afdfa1e1819` | Accepted, frozen and independently inspected. |

## 61. Campaign chronology

```text
25 July 2026  T1 source audit, theorem registration, proof, non-vacuity,
              relational locality, mutation testing and final freeze.

25–26 July   T2 decompressor refinement, non-vacuity, mutation testing,
2026          relational byte locality and final freeze.

26 July 2026 T3 direct compressed-domain composition, corrected loop
              firewall, nibble/cycle companions, mutations and final freeze.

26 July 2026 T4 finite projection analysis, sharp error proof,
              fixed points, idempotence, locality, isolated mutations
              and final freeze.
```

---

# Part XI — Known defects, corrections and lessons

## 62. T1 early runner and packaging issues

Early T1 stages exposed runner/unwind and execution issues that were diagnosed rather than hidden. The final direct semantic and strict runs succeeded.

The final read-only extraction cleanup emitted permission errors. This did not invalidate the already verified archive, but future packaging should change permissions before removal.

## 63. T2 original archive missing scripts

This remains a real reproducibility defect. The theorem evidence is present and consistent, but the original package does not contain the exact script inventory. The public package should be repaired or clearly qualified.

## 64. T3 incorrect three-loop expectation

The initial firewall model was wrong. It expected three loops, while the generated program contained four. The correction was made transparently and without changing the theorem or production source.

This is an important lesson:

> Verification infrastructure is itself fallible and must be checked against generated artefacts.

## 65. Mutation scope

The mutation sets demonstrate meaningful sensitivity, but they are not exhaustive mutation analysis. Passing selected mutations does not prove that every possible wrong implementation would be detected by the theorem suite.

## 66. Coverage interpretation

Location coverage demonstrates reachability of instrumented locations. It does not by itself prove semantic correctness. It was used only as a companion to the actual assertions, strict checks, reachability and mutations.

---

# Part XII — Professor-ready claim set

## 67. Main contribution statement

> This work developed and evaluated a clean-room CBMC theorem suite for the pinned portable-C D4 polynomial codec of `mlkem-native` under ML-KEM-768. The suite separately establishes full-output functional refinement of compression and decompression, exact retraction on the compressed-byte domain, and the lossy projection semantics on the canonical-polynomial domain. The projection is shown to have the exact 16-value image, a sharp modular error bound of 104, precisely characterized fixed points, idempotence and coordinate locality. The evidence is strengthened by complete loop unwinding, strict C checks, coverage, end reachability, relational harnesses, isolated fault detection and cryptographically hashed evidence packages.

## 68. One-sentence answer to whether the functions were proved

> The pinned portable-C D4 compressor and decompressor were proved correct with respect to the registered independent specifications and composition properties, under the stated ML-KEM-768, canonical-domain and bounded-C-model assumptions.

## 69. One-sentence answer to why four theorems were necessary

> Four theorems were used because primitive encoder correctness, primitive decoder correctness, exact behavior on the compressed representation domain, and lossy projection behavior on the polynomial domain are logically different obligations and cannot safely be collapsed into one round-trip test.

## 70. One-sentence answer to why T4 was necessary after T3

> T3 proves that valid compressed codes survive decode/re-encode, whereas T4 is required to explain and bound what lossy encode/decode does to arbitrary canonical polynomial inputs.

## 71. One-sentence answer to `poly_frommsg`

> The current completed evidence does not prove a new `mlk_poly_frommsg` theorem; `poly_frommsg` is a separate `d=1` message-mapping function and requires its own independently frozen campaign.

## 72. One-sentence novelty claim

> The defensible novelty is a distinct commit-pinned portable-C CBMC theorem-and-evidence suite for `mlkem-native`, not the first formal verification of ML-KEM compression/decompression in the global literature.

---

# Part XIII — Final truth table

| Question | Answer |
|---|---|
| Was production source modified to make the proofs pass? | **No.** |
| Was the exact source revision frozen? | **Yes.** |
| Was the D4 compressor functionally refined? | **Yes, T1, for canonical ML-KEM-768 polynomial inputs.** |
| Was the D4 decompressor functionally refined? | **Yes, T2, for all 128-byte inputs.** |
| Was `compress(decompress(B))=B` proved? | **Yes, T3, for all 128-byte arrays.** |
| Was `decompress(compress(A))=A` proved? | **No, because compression is lossy.** |
| Was the correct replacement property proved? | **Yes, T4 proves projection, image, sharp error, fixed points, idempotence and locality.** |
| Were assertions checked for reachability? | **Yes.** |
| Were mutations detected? | **Yes, selected targeted mutations in every theorem family.** |
| Were all parameter sets proved? | **No.** |
| Were native/assembly backends proved by this campaign? | **No.** |
| Was constant-time behavior proved? | **No.** |
| Was full ML-KEM correctness proved? | **No.** |
| Was cryptographic security proved? | **No.** |
| Was a new `mlk_poly_frommsg` theorem proved? | **No.** |
| Is the work novel? | **Repository-relative and artefact-level novelty is strong; an absolute global-first claim is not justified.** |

---

# 73. Final campaign verdict

The D4 campaign is a genuine formal-verification result, not merely a test campaign and not merely a successful compilation.

Within the frozen scope, the evidence establishes:

```text
T1: compressor refinement
T2: decompressor refinement
T3: exact compressed-domain retraction
T4: canonical-domain quantizer projection with sharp error
```

The work is technically meaningful because the four theorems close different logical gaps and because the positive assertions were supplemented by non-vacuity, relational, mutation and evidence-integrity controls.

The work should be presented as:

```text
a clean-room, commit-pinned, portable-C CBMC functional theorem suite
for the ML-KEM-768 D4 codec in mlkem-native
```

It should not be presented as:

```text
a proof of all ML-KEM, all backends, all parameter sets,
or the first formal compression/decompression proof in existence.
```

---

# References and novelty-check sources

1. National Institute of Standards and Technology, **FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard**, 13 August 2024.  
   https://doi.org/10.6028/NIST.FIPS.203

2. PQ Code Package, **mlkem-native official repository**.  
   https://github.com/pq-code-package/mlkem-native

3. PQ Code Package, **mlkem-native pinned CBMC proof tree at commit `af4c5abd…`**.  
   https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc

4. Almeida et al., **Formally Verifying Kyber**, IACR Crypto 2024 artifact.  
   https://artifacts.iacr.org/crypto/2024/a3/

5. Cryspen/libcrux, **Formal Verification of ML-KEM: Portable and AVX2**, verification report and code artefacts.  
   https://github.com/cryspen/libcrux

6. Post-Quantum Cryptography Alliance, **First stable release of mlkem-native v1 under PQ Code Package Project**, 7 August 2025.  
   https://pqca.org/blog/2025/first-stable-release-of-mlkem-native-v1-under-pq-code-package-project/

7. Becker, Chapman and Kostic, **Verifying and optimizing post-quantum cryptography at Amazon**, Amazon Science, 7 April 2026.  
   https://www.amazon.science/blog/verifying-and-optimizing-post-quantum-cryptography-at-amazon

---

## Document-integrity note

This record intentionally preserves qualifications and defects that would be easy to omit:

- T1 cleanup permissions;
- T2 missing script provenance in the original archive;
- T3 loop-firewall correction;
- the distinction between repository-relative novelty and global novelty;
- the fact that `mlk_poly_frommsg` is not proved by T1–T4.

These qualifications strengthen rather than weaken the research record because they keep the claims aligned with the actual evidence.
