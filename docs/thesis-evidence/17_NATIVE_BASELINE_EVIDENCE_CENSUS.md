# Archive-verified native baseline evidence census

This census records the exact frozen mlkem-native proof-tree and production-source files used to control the case-specific distinctness claims. Paths and entry hashes are verified against the two frozen source archives. It resolves retained-summary conflicts by giving authority to the frozen repository tree.

| Case | Target | Native proof status | Authoritative baseline | Conflict resolution | Archive status |
|---|---|---|---|---|---|
| 1 | mlk_poly_add | DEDICATED_ONE_CALL_HARNESS_PRESENT | Native one-call `poly_add` harness and source contract are present. | NONE | RESOLVED_AND_HASHED |
| 2 | mlk_poly_sub | DEDICATED_ONE_CALL_HARNESS_PRESENT | Native one-call `poly_sub` harness and source contract are present. | NONE | RESOLVED_AND_HASHED |
| 3 | mlk_poly_sub -> mlk_poly_reduce (VC-SR1) | SEPARATE_NATIVE_HARNESSES_PRESENT_NO_DIRECT_SEQUENCE_DIRECTORY | Native one-call harnesses exist separately for `poly_sub` and `poly_reduce`; no eponymous direct VC-SR1 sequence directory was identified. | NONE | RESOLVED_AND_HASHED |
| 4 | mlk_poly_tomsg | DEDICATED_ONE_CALL_HARNESS_PRESENT | A dedicated native `poly_tomsg` one-call harness exists. Any retained summary statement claiming no dedicated directory is superseded by this frozen-source census. | RETAINED_TOMSG_SUMMARY_ABSENCE_CLAIM_SUPERSEDED_BY_FROZEN_SOURCE | RESOLVED_AND_HASHED |
| 5 | mlk_poly_frommsg | DEDICATED_ONE_CALL_HARNESS_PRESENT | A dedicated native `poly_frommsg` one-call harness exists; the exact generated T1–T4 suite remains distinct. | RETAINED_FROMMSG_NO_MATCHING_HARNESS_WORDING_QUALIFIED_NATIVE_ONE_CALL_HARNESS_EXISTS | RESOLVED_AND_HASHED |
| 6 | mlk_poly_compress_d4_c and mlk_poly_decompress_d4_c | DEDICATED_ONE_CALL_HARNESSES_PRESENT | Dedicated native one-call harnesses exist for both portable-C D4 functions. | NONE | RESOLVED_AND_HASHED |
| 7 | mlk_scalar_signed_to_unsigned_q | DEDICATED_ONE_CALL_HARNESS_PRESENT | A dedicated native one-call scalar conversion harness exists. The retained CANON summary statement claiming its absence is factually superseded by the frozen-source census. | RETAINED_CANON_SUMMARY_ABSENCE_CLAIM_SUPERSEDED_BY_FROZEN_SOURCE | RESOLVED_AND_HASHED |
| 8 | mlk_barrett_reduce | DEDICATED_ONE_CALL_HARNESS_PRESENT | A dedicated native one-call Barrett harness exists. | NONE | RESOLVED_AND_HASHED |
| 9 | mlk_zeroize | NO_DEDICATED_ZEROIZE_PROOF_DIRECTORY | Production zeroize source/contracts and release macros exist; no dedicated native `proofs/cbmc/zeroize/` directory exists. | NONE | RESOLVED_AND_HASHED |
| 10 | mlk_poly_tobytes | DEDICATED_ONE_CALL_HARNESSES_PRESENT | Native wrapper and portable-C one-call harnesses exist. | NONE | RESOLVED_AND_HASHED |
| 11 | mlk_poly_frombytes | DEDICATED_ONE_CALL_HARNESSES_PRESENT | Native wrapper and portable-C one-call harnesses exist. | NONE | RESOLVED_AND_HASHED |
| 12 | mlk_poly_tobytes <-> mlk_poly_frombytes (PBCODEC-CV1) | SEPARATE_NATIVE_HARNESSES_PRESENT_NO_DIRECT_CODEC_DIRECTORY | Native serializer and deserializer harnesses exist separately; no direct two-wrapper PBCODEC-CV1 directory was identified. | NONE | RESOLVED_AND_HASHED |
| 13 | mlk_kem_check_pk | DEDICATED_ONE_CALL_HARNESS_PRESENT | A dedicated native one-call `kem_check_pk` harness exists. | NONE | RESOLVED_AND_HASHED |
| 14 | mlk_montgomery_reduce; candidate mlk_fqmul and mlk_poly_tomont_c families | DEDICATED_ONE_CALL_HARNESSES_PRESENT | Dedicated native one-call harnesses exist for all three local targets. | NONE | RESOLVED_AND_HASHED |
| SA-ADD | mlk_poly_add | DEDICATED_ONE_CALL_HARNESS_PRESENT | Native one-call `poly_add` harness and source contract are present. | NONE | RESOLVED_AND_HASHED |
| SA-SUB | mlk_poly_sub | DEDICATED_ONE_CALL_HARNESS_PRESENT | Native one-call `poly_sub` harness and source contract are present. | NONE | RESOLVED_AND_HASHED |
| SA-BR | mlk_barrett_reduce | DEDICATED_ONE_CALL_HARNESS_PRESENT | A dedicated native one-call Barrett harness exists. | NONE | RESOLVED_AND_HASHED |
| SA-ZERO | mlk_zeroize | NO_DEDICATED_ZEROIZE_PROOF_DIRECTORY | Production zeroize source/contracts and release macros exist; no dedicated native `proofs/cbmc/zeroize/` directory exists. | NONE | RESOLVED_AND_HASHED |
