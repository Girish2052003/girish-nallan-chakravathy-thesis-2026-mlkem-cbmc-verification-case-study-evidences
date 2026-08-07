# Formal claim catalogue

These are readable principal statements. The complete property-by-property qualification is authoritative in `02_COMPLETE_PROPERTY_LEDGER.csv`. Mathematical notation is intentionally selective: it makes the principal semantic relation visible without treating each tool-generated safety check as a separate theorem.

## Notation

- `q=3329`.
- `canon_q(x)` is the unique representative in `[0,q)` congruent to `x` modulo `q`.
- `Norm` denotes the registered production normalization composition in Case 2.
- `Comp4` and `Decomp4` denote the registered D4 compressor and decompressor; `Proj4 = Decomp4 ∘ Comp4`.
- `SignedToCanon` denotes the actual body of `mlk_scalar_signed_to_unsigned_q` on `D_s = {-(q-1),...,q-1}`.
- `Barrett` denotes the actual body of `mlk_barrett_reduce`; `Centered_q` denotes the independent centered-remainder oracle used in Case 8.
- `CanonAfterBarrett(a) = SignedToCanon(Barrett(a))` in Case 7.
- `MontRed` denotes the actual body of `mlk_montgomery_reduce` in Case 14.
- Every symbol is case-specific; no symbol is reused for an unrelated function.


## 1: Canonical and representable signed addition

**Target:** `mlk_poly_add`  
**Source:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Configuration/domain:** ML-KEM-768 primary; PA-06 additionally 512/768/1024  
**Principal statements:**

- PA-01 canonical domain: for every coefficient index `i`, if `0 <= a_i,b_i < q`, then `r_i=a_i+b_i`, `0 <= r_i <= 2q-2`, and `canon_q(r_i)=canon_q(a_i+b_i)`; the registered inputs are preserved and commutativity/identity hold.
- PA-02 signed domain: if the exact mathematical sum `a_i+b_i` is `int16_t`-representable, then `r_i=a_i+b_i` and `canon_q(r_i)=canon_q(a_i+b_i)`.

**Evidence locator:** `LOC-C01-UA`  
**Preservation:** `PARTIAL`


## 2: Subtraction, normalization and dependency properties

**Target:** `mlk_poly_sub`  
**Source:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Configuration/domain:** ML-KEM-768  
**Principal statements:**

- `Norm(A-B)=canon_q(A-B)` and `Norm(A-B)=Norm(Norm(A)-Norm(B))` under the registered signed domains.
- The registered right, left and modular cancellation relations hold.
- For canonical inputs `0 <= A_i,B_i < q`, the raw production result satisfies `r_i=A_i-B_i` and `-3328 <= r_i <= 3328`; representability is derived rather than assumed.
- The registered frame, coefficient-locality, cross-coordinate non-interference, exact changed-coordinate and determinism properties hold.

**Evidence locator:** `LOC-C02-UA`  
**Preservation:** `COMPLETE`

## 3: Sequential subtraction–reduction

**Target:** `mlk_poly_sub -> mlk_poly_reduce (VC-SR1)`  
**Source:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Configuration/domain:** ML-KEM-768; supporting later-revision replay  
**Principal statement:** For each i, reduce(sub(A,B))_i=canon_q(int32(A_i)-int32(B_i)) within the signed-representable difference domain.

**Evidence locator:** `LOC-C03-UA`  
**Preservation:** `COMPLETE`

## 4: Message extraction

**Target:** `mlk_poly_tomsg`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768  
**Principal statement:** bit_k(tomsg(A))=1 iff 833<=A_k<=2496 for canonical A_k; the 256 bits are packed LSB-first into 32 bytes. The exact accepted arithmetic-offset interval is [1073417800,1074063871].

**Evidence locator:** `LOC-C04-UA`  
**Preservation:** `COMPLETE`

## 5: Message embedding and directional round trip

**Target:** `mlk_poly_frommsg`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768  
**Principal statement:** frommsg(m)_k=1665*bit_k(m), and tomsg(frommsg(m))=m for every 32-byte message m.

**Evidence locator:** `LOC-C05-UA`  
**Preservation:** `COMPLETE`

## 6: D4 exact and lossy codec relations

**Target:** `mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768  
**Principal statement:** `Comp4(Decomp4(B))=B` for every compressed byte array `B`; `Proj4(A)=Decomp4(Comp4(A))` is a coordinatewise projection onto the 16-value codebook with `dist_q(A_i,Proj4(A)_i)<=104`, and 104 is attainable.

**Evidence locator:** `LOC-C06-UA`  
**Preservation:** `COMPLETE`

## 7: Signed-to-canonical conversion

**Target:** `mlk_scalar_signed_to_unsigned_q`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768 build  
**Principal statement:** `SignedToCanon` maps `D_s={-(q-1),...,q-1}` to `[0,q)`, with the recorded fibre, idempotence, fixed-point and algebraic laws; `CanonAfterBarrett(a)=canon_q(a)` for every `int16_t` input `a`.

**Evidence locator:** `LOC-C07-UA`  
**Preservation:** `COMPLETE`

## 8: Centered Barrett reduction

**Target:** `mlk_barrett_reduce`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768 build; full int16_t domain  
**Principal statement:** For every `int16_t` input `a`, `Barrett(a)=Centered_q(a)`, `-1664<=Barrett(a)<=1664`, and `Barrett(a)≡a (mod q)`, with the registered fixed-point, quotient-cell, multiplier and offset-characterisation properties.

**Evidence locator:** `LOC-C08-UA`  
**Preservation:** `COMPLETE`

## 9: Source-level zeroization

**Target:** `mlk_zeroize`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768 build; bounded memory objects  
**Principal statement:** For a valid selected interval I, Z_I(M) sets exactly the selected bytes to zero while preserving the registered frame; the recorded idempotence, partition, commutativity and release-handoff relations also hold.

**Evidence locator:** `LOC-C09-UA`  
**Preservation:** `COMPLETE`

## 10: Canonical polynomial serialization

**Target:** `mlk_poly_tobytes`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768  
**Principal statement:** Each canonical coefficient pair (c0,c1) is encoded as the 24-bit word c0+4096*c1 in the specified 3-byte layout; the complete 384-byte encoding is injective on canonical polynomials.

**Evidence locator:** `LOC-C10-UA`  
**Preservation:** `COMPLETE`

## 11: Raw polynomial deserialization

**Target:** `mlk_poly_frombytes`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768  
**Principal statement:** Each 3-byte word W_i is decoded to (W_i mod 4096, floor(W_i/4096)); the relation is raw 12-bit unpacking, not modulo-q canonicalization.

**Evidence locator:** `LOC-C11-UA`  
**Preservation:** `COMPLETE`

## 12: Direct production codec composition

**Target:** `mlk_poly_tobytes <-> mlk_poly_frombytes (PBCODEC-CV1)`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768  
**Principal statement:** frombytes(tobytes(p))=p for canonical p; tobytes(frombytes(b))=b for b in the canonical encoder image.

**Evidence locator:** `LOC-C12-UA`  
**Preservation:** `COMPLETE`

## 13: Public-key validation boundary

**Target:** `mlk_kem_check_pk`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768  
**Principal statement:** The registered malformed/canonical field decisions, input/frame obligations, prefix-only footprint and caller guard are supported; the two-call seed-noninterference relation remains abstraction-limited and inconclusive.

**Evidence locator:** `LOC-C13-UA`  
**Preservation:** `COMPLETE`

## 14: Montgomery reduction and unresolved extensions

**Target:** `mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768 build  
**Principal statement:** MONT-T1: reduce(a)=independent_oracle(a) over the complete legal source domain, with exact reconstruction, unique signed-16 decomposition and sharp image [-32767,32767]. MONT-T2–T4 remain resource-limited and inconclusive.

**Evidence locator:** `LOC-C14-UA`  
**Preservation:** `COMPLETE`

## SA-ADD: Skill-available addition relations

**Target:** `mlk_poly_add`  
**Source:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Configuration/domain:** ML-KEM-768  
**Principal statement:** Common-addend translation/equality relations and disjoint-support decomposition are supported.

**Evidence locator:** `LOC-SA-ADD`  
**Preservation:** `COMPLETE`

## SA-SUB: Skill-available subtraction relations

**Target:** `mlk_poly_sub`  
**Source:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Configuration/domain:** ML-KEM-768  
**Principal statement:** (a-b)-(a-c)=c-b and (a-b)-c=a-(b+c) under the registered finite-width domains.

**Evidence locator:** `LOC-SA-SUB`  
**Preservation:** `COMPLETE`

## SA-BR: Skill-available Barrett relations

**Target:** `mlk_barrett_reduce`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768 build  
**Principal statement:** `Barrett(-a)=-Barrett(a)` with the registered quotient-reversal relation for `a != INT16_MIN`; the centred-addition closure property with one correction is supported for arbitrary `int16_t` pairs under the recorded harness semantics.

**Evidence locator:** `LOC-SA-BR`  
**Preservation:** `COMPLETE`

## SA-ZERO: Skill-available zeroization relations

**Target:** `mlk_zeroize`  
**Source:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Configuration/domain:** ML-KEM-768 build; bounded objects  
**Principal statement:** Whole-object wipe erases secret-history differences; re-wiping a recontaminated subrange restores the selected outer region to zero.

**Evidence locator:** `LOC-SA-ZERO`  
**Preservation:** `COMPLETE`
