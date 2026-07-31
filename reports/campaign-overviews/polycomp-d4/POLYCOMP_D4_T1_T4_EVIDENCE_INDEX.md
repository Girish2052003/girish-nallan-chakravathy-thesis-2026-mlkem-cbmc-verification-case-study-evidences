# POLYCOMP-D4 T1–T4 evidence index

This navigation summary is derived only from the four supplied final verdicts.

| Campaign | Bound portable-C target(s) | Accepted theorem scope | Key hardening evidence |
|---|---|---|---|
| T1 compressor refinement | `mlk_poly_compress_d4_c` | Exact 128-byte scalar refinement over canonical coefficients; nibble correspondence and relational nibble locality | 24/24 location coverage, positive/relational reachability, bit-flip, nibble-swap, and rounding-minus-one mutations |
| T2 decompressor refinement | `mlk_poly_decompress_d4_c` | Exact 256-coefficient refinement for every 128-byte input; codebook membership and relational byte locality | 20/20 location coverage, positive/relational reachability, nibble-swap and rounding-constant mutations |
| T3 compressed-domain retraction | `mlk_poly_decompress_d4_c`, `mlk_poly_compress_d4_c` | Exact byte identity after real decompression/compression for every 128-byte compressed input; nibble preservation and cycle stability | 25/25 location coverage, reachability, decompression-side and compression-side swap mutations |
| T4 quantizer projection | `mlk_poly_compress_d4_c`, `mlk_poly_decompress_d4_c` | Codebook membership, modular distortion at most 104, a sharp witness, fixed-point characterization, idempotence, and coordinate locality on canonical coefficients | 36/36 location coverage, reachability, isolated codebook and distortion mutations |

All four verdicts bind ML-KEM-768, mlkem-native commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`, unmodified production source, and CBMC 6.9.0. This index does not expand their stated claim boundaries.
