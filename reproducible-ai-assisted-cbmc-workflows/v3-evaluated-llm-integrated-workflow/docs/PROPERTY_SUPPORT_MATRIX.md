# Complete 26-Property Support Matrix

**Support means the workflow can prepare, review, execute, classify, and preserve evidence for the property family. It does not guarantee that an LLM candidate will compile or that CBMC will prove the property.**

| ID | Property family | Default strategy | Support class | Example targets | Claim boundary |
|---|---|---|---|---|---|
| P01 | Array bounds property | `standard_cbmc_harness` | `production_supported` | poly_add, poly_sub, poly_tobytes, poly_frombytes, polyvec_tobytes, polyvec_frombytes | Local memory-access safety under the exact harness, source and options. |
| P02 | Barrett reduction bounds | `native_function_contract` | `production_supported` | barrett_reduce | Implementation-specific output bounds for stated input bounds; not abstract modular correctness. |
| P03 | Compression output range and write extent | `hybrid_contract_and_harness` | `production_supported` | poly_compress, polyvec_compress | Byte/range/write-footprint properties for configured parameter set only. |
| P04 | Decompression coefficient range | `native_function_contract` | `production_supported` | poly_decompress, polyvec_decompress | Implementation-representation bounds, not perfect inverse or cryptographic correctness. |
| P05 | Encoding length and frame property | `hybrid_contract_and_harness` | `production_supported` | poly_tobytes, polyvec_tobytes, pack_pk, pack_sk, pack_ciphertext | Writes remain inside the configured official-length buffer; exact-write claims require frame evidence. |
| P06 | FromBytes/ToBytes round-trip | `relational_cbmc_harness` | `production_supported_scoped` | poly_tobytes, poly_frombytes | Scoped relational equivalence under explicit normalization assumptions. |
| P07 | Global API buffer safety | `native_function_contract` | `stretch_supported` | crypto_kem_keypair, crypto_kem_enc, crypto_kem_dec | Memory safety for selected API path and configured stubs; not whole implementation correctness. |
| P08 | Hash/XOF buffer safety | `standard_cbmc_harness` | `production_supported` | shake128, shake256, sha3_256, sha3_512 | Memory safety and declared buffer extents only. |
| P09 | Integer overflow absence | `standard_cbmc_harness` | `production_supported` | montgomery_reduce, barrett_reduce, fqmul, poly_add, poly_sub, poly_reduce | C integer overflow checks under recorded ranges and compiler model. |
| P10 | Join/split packing consistency | `relational_cbmc_harness` | `production_supported_scoped` | pack_pk, unpack_pk, pack_sk, unpack_sk, pack_ciphertext, unpack_ciphertext | One selected pack/unpack relation under stated canonicality assumptions. |
| P11 | Keypair output size/frame | `native_function_contract` | `stretch_supported` | crypto_kem_keypair | Write-footprint and buffer safety, not key-generation security or distribution. |
| P12 | Loop invariant generation | `native_loop_contract` | `production_supported` | poly_add, poly_sub, poly_reduce, poly_tobytes | Candidate invariant initiation/preservation/use under exact transformed program; no guarantee of automatic discovery success. |
| P13 | Montgomery reduction bounds | `native_function_contract` | `production_supported` | montgomery_reduce | Implementation-specific Montgomery-domain bounds and overflow conditions. |
| P14 | NTT input/output bounds | `native_function_contract` | `stretch_supported` | poly_ntt, poly_invntt_tomont, ntt, invntt | C-level coefficient bounds only; not full NTT mathematical correctness or assembly proof. |
| P15 | Output-buffer separation/non-aliasing | `native_function_contract` | `production_supported` | poly_tobytes, poly_frombytes, pack_pk, unpack_pk, crypto_kem_enc, crypto_kem_dec | Explicit aliasing preconditions and their effect; over-constraint must be reviewed. |
| P16 | Polynomial addition/subtraction bounds | `hybrid_contract_and_harness` | `production_supported` | poly_add, poly_sub, poly_reduce | Local coefficient bounds for the exact representation and input assumptions. |
| P17 | q-modulus-related range | `native_function_contract` | `production_supported` | barrett_reduce, poly_reduce, poly_decompress, poly_frommsg, poly_tomsg | Code-derived q-related representation range; exact interval must not be guessed. |
| P18 | Rejection sampling safety | `native_loop_contract` | `stretch_supported` | rej_uniform, poly_uniform, poly_getnoise_eta1, poly_getnoise_eta2 | Buffer/termination obligations under bounded input/model assumptions; not probabilistic distribution correctness. |
| P19 | Secret-independent branch/access analysis support | `analysis_only_no_formal_claim` | `analysis_only` | selected_C_functions | AI-assisted classification and external-test support only; no CBMC constant-time proof claim. |
| P20 | Top-level decapsulation memory safety | `native_function_contract` | `stretch_supported` | crypto_kem_dec | Selected-path memory safety under official sizes and configured environment. |
| P21 | Unpack validation | `hybrid_contract_and_harness` | `production_supported` | unpack_pk, unpack_sk, unpack_ciphertext | Input-read bounds and output-field ranges for selected format. |
| P22 | Vector operation bounds | `hybrid_contract_and_harness` | `production_supported_scoped` | polyvec_add, polyvec_reduce, polyvec_ntt, polyvec_invntt_tomont | Selected vector operation bounds; NTT variants remain stretch scope. |
| P23 | Wipe/zeroization | `native_function_contract` | `production_supported_scoped` | selected_cleanup_or_wipe | Post-call memory bytes in the model; compiler-elimination and physical erasure require separate evidence. |
| P24 | XOF deterministic expansion | `relational_cbmc_harness` | `test_or_relational_supported` | shake128_absorb, shake128_squeezeblocks, shake256 | Same modeled input/state yields same modeled output; not cryptographic security or deep Keccak correctness. |
| P25 | Expected API return-code range | `native_function_contract` | `production_supported` | crypto_kem_keypair, crypto_kem_enc, crypto_kem_dec | Return-value set on modeled paths only. |
| P26 | Zero-length/invalid-size exclusion and pointer preconditions | `native_function_contract` | `production_supported` | selected_function | Inferred candidate preconditions must be justified; assumptions are not proved by assuming them. |

## Strategy meanings

- `standard_cbmc_harness`: ordinary bounded-CBMC harness and safety/property assertions.
- `native_function_contract`: CBMC requires/ensures/assigns/frees plus GOTO contract enforcement/replacement.
- `native_loop_contract`: controlled annotations on copied source plus `--apply-loop-contracts`.
- `relational_cbmc_harness`: two-call or pack/unpack/determinism harnesses.
- `hybrid_contract_and_harness`: reviewed native contract plus a scoped harness.
- `analysis_only_no_formal_claim`: evidence collection and cautious classification only; no CBMC proof claim.

Property P19 is deliberately analysis-only. P14, P18 and P20 remain stretch-supported because model size and dependencies can make them expensive or inconclusive.
