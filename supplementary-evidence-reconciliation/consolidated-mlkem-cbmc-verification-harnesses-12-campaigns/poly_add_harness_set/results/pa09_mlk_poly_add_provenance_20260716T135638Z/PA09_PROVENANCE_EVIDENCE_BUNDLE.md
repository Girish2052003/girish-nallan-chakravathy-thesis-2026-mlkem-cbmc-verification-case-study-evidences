# PA-09 `mlk_poly_add` Provenance Evidence Bundle

## 1. Audit Identity

- Repository root: `/home/girish/THESIS-2026/mlkem-native`
- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Production `poly.c` SHA-256: `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722`
- Production source modified: `No`
- Required authored artefacts hash-verified: `24`
- Files in original `proofs/cbmc/poly_add`: `2`
- Frozen repository artefacts collected: `15`
- Mechanical authored/repository comparisons: `192`
- Exact binary duplicates found: `0`
- Exact normalized-text duplicates found: `0`
- High mechanical similarity pairs requiring semantic review: `0`

## 2. Interpretation Boundary

This bundle establishes artefact identity, frozen repository content, and mechanical overlap. It does not treat a similarity score as a final semantic provenance judgement. The final PA-09 conclusion must separately distinguish inevitable overlap, contract-derived overlap, architectural overlap, and evidence of copying or independent extension.

## 3. Authored Artefact Freeze

| File | Hash verified | SHA-256 | Size |
|---|---|---|---:|
| `cleanroom_mlk_poly_add_fips_relational_harness_v2.c` | yes | `307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e` | 5328 |
| `run_cleanroom_mlk_poly_add_cbmc_v2.sh` | yes | `eeb5b1c1a88689e9219d704ec56fcc97b44ec8676ac1c391106adcd4243980f6` | 4819 |
| `pa02_mlk_poly_add_full_signed_contract_valid_harness.c` | yes | `e83d521e23f93c2435058598be5ef245bb02c554a4b7992dd8844418720c2ce2` | 6763 |
| `run_pa02_mlk_poly_add_full_signed_cbmc.sh` | yes | `7068aa8be8e763e7622b7a5767031eb1fa6f4a557f4b9a0507befbb0c346ffee` | 5015 |
| `pa03_mlk_poly_add_unrestricted_negative_control_harness.c` | yes | `37f9893284959fc9406d7e4bee06848b7c4e9e1cf717fe3c0d699ac5ca0f2487` | 3702 |
| `run_pa03_mlk_poly_add_unrestricted_negative_control.sh` | yes | `d2a628b547ceae17713b995a99244c9bfef761b8993be060eb71518627317f5d` | 6607 |
| `pa04a_mlk_poly_add_alias_safe_doubling_harness.c` | yes | `d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4` | 4085 |
| `pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c` | yes | `de2e0689d3470cf992533912e6689ac223d8408967b42e8082ac46af8545e528` | 2161 |
| `run_pa04_mlk_poly_add_aliasing_campaign.sh` | yes | `df15493e874057bc7e35516af8043be86399c131bc7f4a8ab99bd3744666a82c` | 9362 |
| `pa05a_mlk_poly_add_polyvec_production_callsite_harness.c` | yes | `ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e` | 2858 |
| `pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c` | yes | `8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc` | 4147 |
| `pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c` | yes | `8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0` | 6027 |
| `run_pa05_mlk_poly_add_production_callsites.sh` | yes | `3547108f805d9a89e5c5121249de1c6e7d7db48a20636ecc5dd702f22b78a34d` | 7887 |
| `pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c` | yes | `0941baf262a7a15c1f8be69a6c571c2727d4ab5de0ff16d0f3a364c8e3cb2ddd` | 3057 |
| `pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c` | yes | `e639524d557a13410d47ad7e1078955332a758d23fd46c1d444a7f77ba327644` | 3576 |
| `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c` | yes | `b008285e11c0e05286338657b4529087e605a92f95f5689a0d1e279a46821b44` | 5370 |
| `run_pa06_mlk_poly_add_cross_parameter_campaign.sh` | yes | `7e88e942c81893a25f23c54ad3f4ee9115f5e4df1a849d924df7bbe8df967014` | 9980 |
| `pa07_mlk_poly_add_mutant_implementation.c` | yes | `4a0a231c050013cd73fbb7b5a07237218decb1a58ae3f9007a465adaa35b01ff` | 2487 |
| `run_pa07_mlk_poly_add_mutation_sensitivity.sh` | yes | `905f081214b6f64e192b5d7744368e4b09957b511acfce8cea805002320701ce` | 15201 |
| `pa08a_mlk_poly_add_boundary_hardening_harness.c` | yes | `1f7967136b275110519ba247f182d7f11ab4d36288493bd5e571d7a2dc584dee` | 6934 |
| `pa08b_mlk_poly_add_reachability_sentinel_harness.c` | yes | `38fbbd821e2ac13c4a85fca813425b4cbafe15ec9f72ca54b85fce5599fc6428` | 2581 |
| `pa08c_mlk_poly_add_upper_outside_boundary_harness.c` | yes | `36f2a6c423e1303570d25019db0d538e13a1f50135ae0f11e798636537fb891d` | 1373 |
| `pa08d_mlk_poly_add_lower_outside_boundary_harness.c` | yes | `6e484118e522d54c67d043e2a9d209df8a64e3af290666bc3d74cbb8b5c425ed` | 1440 |
| `run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh` | yes | `ff76bd70e3c876712a978127d10fc1f17788b1dda5818a8bbbc56c24e2f77859` | 13260 |

## 4. Original Repository `poly_add` Proof Directory

- `proofs/cbmc/poly_add/Makefile`
- `proofs/cbmc/poly_add/poly_add_harness.c`

## 5. Repository Candidate Manifest

| Path | Original proof directory | Direct target reference | SHA-256 |
|---|---|---|---|
| `REFERENCE.md` | no | yes | `cdf533585d2adb81ec30cb1ae312a11a6319d10fbd449a1c961108af7a98f19e` |
| `SOUNDNESS.md` | no | no | `f7088ae5b250c15f9c324a02329b66f2a9d64d6e69063eeb490a880fe92677a6` |
| `mlkem/mlkem_native.c` | no | yes | `c09e20cd67f4d95ffab70da39d054c569b82572cc0e7d7784437d83420ed77a6` |
| `mlkem/src/indcpa.c` | no | yes | `ffc9cd09fb9a5926c8540b52181b064e7ae46b3d117e10ca51ac0d0ca940f6bd` |
| `mlkem/src/poly.c` | no | yes | `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722` |
| `mlkem/src/poly.h` | no | yes | `f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef` |
| `mlkem/src/poly_k.c` | no | yes | `7dea24a0591b0fb033f7a8be214d687fbde11541c274a114ac3067af12b87c32` |
| `mlkem/src/poly_k.h` | no | no | `09bdfd4a19a9cb495832a78d0f099a6c949c40014472b33fb54d66bb56e660e0` |
| `proofs/cbmc/README.md` | no | yes | `2bfcf066dd68d747f3b283504be3e6aa9abb28d6d68a3cffcf4980706bdd349f` |
| `proofs/cbmc/indcpa_enc/Makefile` | no | yes | `b167b9a5bcbe3274df4e9da8c20f7dc773f39a6a05ae6dd908a873b576af8392` |
| `proofs/cbmc/poly_add/Makefile` | yes | yes | `0df1004d25414b9163721a6741810f9e4f73a4bbaa033ea9c8c0519c0f364686` |
| `proofs/cbmc/poly_add/poly_add_harness.c` | yes | yes | `ff4c40902b23a6a30c717f9381be5d5ba65cb027ed07489311ce4720c6bb9188` |
| `proofs/cbmc/polyvec_add/Makefile` | no | yes | `41f6583e92dc7ad78a76c397ecc014dddbaeaa465ae08fcdf009aaafc32bd21a` |
| `proofs/cbmc/proof_guide.md` | no | yes | `79ce7c38279195008678419a6dc80dad8ae10f448cfd18eb181001f217d32835` |
| `test/bench/bench_components_mlkem.c` | no | yes | `8555edd9fa4f8c273c4d5267d24a6c773efe0937e138d2dbe7768123a39d3746` |

## 6. Direct Target References

```text
REFERENCE.md:10: - CBMC and debug annotations, and minor code restructurings or signature changes to facilitate the CBMC proofs. For example, `poly_add(x,a)` only comes in a destructive variant to avoid specifying aliasing constraints; `poly_rej_uniform` has an additional `offset` parameter indicating the position in the sampling buffer, to avoid passing shifted pointers).
mlkem/mlkem_native.c:327: #undef mlk_poly_add
mlkem/src/indcpa.c:571:   mlk_poly_add(v, epp);
mlkem/src/indcpa.c:572:   mlk_poly_add(v, k);
mlkem/src/poly.c:225: /* Reference: `poly_add()` in the reference implementation @[REF].
mlkem/src/poly.c:229: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
mlkem/src/poly.h:181: #define mlk_poly_add MLK_NAMESPACE(poly_add)
mlkem/src/poly.h:196:  * NOTE: The reference implementation uses a 3-argument mlk_poly_add.
mlkem/src/poly.h:200: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
mlkem/src/poly_k.c:278:     mlk_poly_add(&r->vec[i], &b->vec[i]);
proofs/cbmc/README.md:15: For example, these are the specification and proof of the `poly_add` function:
proofs/cbmc/README.md:17: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
proofs/cbmc/README.md:29: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
proofs/cbmc/indcpa_enc/Makefile:33: USE_FUNCTION_CONTRACTS += mlk_poly_add
proofs/cbmc/poly_add/Makefile:11: PROOF_UID = mlk_poly_add
proofs/cbmc/poly_add/Makefile:22: CHECK_FUNCTION_CONTRACTS=mlk_poly_add
proofs/cbmc/poly_add/Makefile:31: FUNCTION_NAME = mlk_poly_add
proofs/cbmc/poly_add/poly_add_harness.c:10:   mlk_poly_add(r, b);
proofs/cbmc/polyvec_add/Makefile:22: USE_FUNCTION_CONTRACTS=mlk_poly_add
proofs/cbmc/proof_guide.md:65: reduce it as much as possible in mlkem-native. For example, rather than having `mlk_poly_add(dst, src0, src1)` where `dst`
proofs/cbmc/proof_guide.md:66: may overlap with `src0` or `src1`, we only have a destructive `mlk_poly_add(dst, src)` implementing `dst += src`, thereby
test/bench/bench_components_mlkem.c:166:   /* mlk_poly_add */
test/bench/bench_components_mlkem.c:167:   BENCH("mlk_poly_add", mlk_poly_add((mlk_poly *)data0, (mlk_poly *)data1))
```

## 7. Highest Mechanical Similarities

These values are discovery aids. They are not the final novelty classification.

| Authored file | Repository file | Sequence | Token Jaccard | Line Jaccard | Classification |
|---|---|---:|---:|---:|---|
| `pa02_mlk_poly_add_full_signed_contract_valid_harness.c` | `mlkem/src/poly.h` | 0.207 | 0.194 | 0.000 | low-mechanical-overlap |
| `pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c` | `mlkem/src/poly.h` | 0.183 | 0.199 | 0.000 | low-mechanical-overlap |
| `pa08b_mlk_poly_add_reachability_sentinel_harness.c` | `mlkem/src/poly.h` | 0.178 | 0.242 | 0.000 | low-mechanical-overlap |
| `pa07_mlk_poly_add_mutant_implementation.c` | `proofs/cbmc/README.md` | 0.173 | 0.152 | 0.050 | low-mechanical-overlap |
| `pa07_mlk_poly_add_mutant_implementation.c` | `mlkem/src/poly.h` | 0.170 | 0.248 | 0.013 | low-mechanical-overlap |
| `pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c` | `proofs/cbmc/README.md` | 0.166 | 0.133 | 0.020 | low-mechanical-overlap |
| `pa08c_mlk_poly_add_upper_outside_boundary_harness.c` | `proofs/cbmc/poly_add/poly_add_harness.c` | 0.162 | 0.234 | 0.000 | low-mechanical-overlap |
| `pa04a_mlk_poly_add_alias_safe_doubling_harness.c` | `mlkem/src/poly.h` | 0.161 | 0.203 | 0.000 | low-mechanical-overlap |
| `pa05a_mlk_poly_add_polyvec_production_callsite_harness.c` | `mlkem/src/poly.h` | 0.160 | 0.206 | 0.000 | low-mechanical-overlap |
| `cleanroom_mlk_poly_add_fips_relational_harness_v2.c` | `mlkem/src/poly.c` | 0.156 | 0.198 | 0.009 | low-mechanical-overlap |
| `cleanroom_mlk_poly_add_fips_relational_harness_v2.c` | `proofs/cbmc/README.md` | 0.153 | 0.140 | 0.020 | low-mechanical-overlap |
| `pa02_mlk_poly_add_full_signed_contract_valid_harness.c` | `proofs/cbmc/README.md` | 0.152 | 0.140 | 0.017 | low-mechanical-overlap |
| `pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c` | `proofs/cbmc/README.md` | 0.152 | 0.160 | 0.019 | low-mechanical-overlap |
| `pa08d_mlk_poly_add_lower_outside_boundary_harness.c` | `proofs/cbmc/poly_add/poly_add_harness.c` | 0.150 | 0.231 | 0.000 | low-mechanical-overlap |
| `pa08c_mlk_poly_add_upper_outside_boundary_harness.c` | `proofs/cbmc/README.md` | 0.149 | 0.135 | 0.032 | low-mechanical-overlap |
| `pa08c_mlk_poly_add_upper_outside_boundary_harness.c` | `mlkem/src/poly.h` | 0.147 | 0.230 | 0.000 | low-mechanical-overlap |
| `pa08a_mlk_poly_add_boundary_hardening_harness.c` | `mlkem/src/poly_k.c` | 0.147 | 0.190 | 0.004 | low-mechanical-overlap |
| `cleanroom_mlk_poly_add_fips_relational_harness_v2.c` | `mlkem/src/poly_k.c` | 0.145 | 0.185 | 0.005 | low-mechanical-overlap |
| `pa03_mlk_poly_add_unrestricted_negative_control_harness.c` | `proofs/cbmc/README.md` | 0.145 | 0.129 | 0.026 | low-mechanical-overlap |
| `pa02_mlk_poly_add_full_signed_contract_valid_harness.c` | `mlkem/src/poly.c` | 0.143 | 0.191 | 0.008 | low-mechanical-overlap |
| `pa08d_mlk_poly_add_lower_outside_boundary_harness.c` | `proofs/cbmc/README.md` | 0.140 | 0.135 | 0.032 | low-mechanical-overlap |
| `pa02_mlk_poly_add_full_signed_contract_valid_harness.c` | `mlkem/src/poly_k.c` | 0.140 | 0.189 | 0.004 | low-mechanical-overlap |
| `pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c` | `proofs/cbmc/README.md` | 0.140 | 0.154 | 0.022 | low-mechanical-overlap |
| `cleanroom_mlk_poly_add_fips_relational_harness_v2.c` | `mlkem/src/poly.h` | 0.140 | 0.197 | 0.000 | low-mechanical-overlap |
| `pa03_mlk_poly_add_unrestricted_negative_control_harness.c` | `mlkem/src/poly.h` | 0.139 | 0.226 | 0.000 | low-mechanical-overlap |
| `pa08a_mlk_poly_add_boundary_hardening_harness.c` | `proofs/cbmc/README.md` | 0.139 | 0.120 | 0.013 | low-mechanical-overlap |
| `pa08a_mlk_poly_add_boundary_hardening_harness.c` | `mlkem/src/poly.c` | 0.138 | 0.197 | 0.007 | low-mechanical-overlap |
| `pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c` | `mlkem/src/poly_k.c` | 0.134 | 0.201 | 0.004 | low-mechanical-overlap |
| `pa08b_mlk_poly_add_reachability_sentinel_harness.c` | `proofs/cbmc/README.md` | 0.132 | 0.123 | 0.027 | low-mechanical-overlap |
| `pa04a_mlk_poly_add_alias_safe_doubling_harness.c` | `proofs/cbmc/README.md` | 0.130 | 0.151 | 0.018 | low-mechanical-overlap |
| `pa05a_mlk_poly_add_polyvec_production_callsite_harness.c` | `proofs/cbmc/README.md` | 0.127 | 0.152 | 0.025 | low-mechanical-overlap |
| `pa08d_mlk_poly_add_lower_outside_boundary_harness.c` | `mlkem/src/poly.h` | 0.126 | 0.228 | 0.000 | low-mechanical-overlap |
| `pa04a_mlk_poly_add_alias_safe_doubling_harness.c` | `REFERENCE.md` | 0.126 | 0.079 | 0.000 | low-mechanical-overlap |
| `pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c` | `proofs/cbmc/poly_add/poly_add_harness.c` | 0.126 | 0.213 | 0.000 | low-mechanical-overlap |
| `pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c` | `mlkem/src/poly.c` | 0.125 | 0.215 | 0.009 | low-mechanical-overlap |
| `cleanroom_mlk_poly_add_fips_relational_harness_v2.c` | `REFERENCE.md` | 0.123 | 0.080 | 0.000 | low-mechanical-overlap |
| `pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c` | `REFERENCE.md` | 0.121 | 0.093 | 0.000 | low-mechanical-overlap |
| `pa04a_mlk_poly_add_alias_safe_doubling_harness.c` | `mlkem/src/poly.c` | 0.121 | 0.204 | 0.008 | low-mechanical-overlap |
| `pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c` | `mlkem/src/poly.c` | 0.120 | 0.222 | 0.007 | low-mechanical-overlap |
| `pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c` | `mlkem/src/poly_k.c` | 0.120 | 0.235 | 0.004 | low-mechanical-overlap |
| `pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c` | `mlkem/src/poly_k.c` | 0.119 | 0.199 | 0.004 | low-mechanical-overlap |
| `pa08c_mlk_poly_add_upper_outside_boundary_harness.c` | `REFERENCE.md` | 0.118 | 0.060 | 0.000 | low-mechanical-overlap |
| `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c` | `REFERENCE.md` | 0.118 | 0.092 | 0.000 | low-mechanical-overlap |
| `pa08d_mlk_poly_add_lower_outside_boundary_harness.c` | `REFERENCE.md` | 0.117 | 0.060 | 0.000 | low-mechanical-overlap |
| `pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c` | `proofs/cbmc/README.md` | 0.115 | 0.147 | 0.028 | low-mechanical-overlap |
| `pa03_mlk_poly_add_unrestricted_negative_control_harness.c` | `proofs/cbmc/poly_add/poly_add_harness.c` | 0.113 | 0.179 | 0.000 | low-mechanical-overlap |
| `pa08b_mlk_poly_add_reachability_sentinel_harness.c` | `mlkem/src/poly.c` | 0.113 | 0.220 | 0.010 | low-mechanical-overlap |
| `pa08a_mlk_poly_add_boundary_hardening_harness.c` | `REFERENCE.md` | 0.112 | 0.068 | 0.000 | low-mechanical-overlap |
| `pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c` | `mlkem/src/poly_k.h` | 0.112 | 0.196 | 0.000 | low-mechanical-overlap |
| `pa05a_mlk_poly_add_polyvec_production_callsite_harness.c` | `mlkem/src/poly_k.c` | 0.109 | 0.219 | 0.005 | low-mechanical-overlap |
| `pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c` | `mlkem/src/poly_k.c` | 0.109 | 0.246 | 0.005 | low-mechanical-overlap |
| `cleanroom_mlk_poly_add_fips_relational_harness_v2.c` | `mlkem/src/poly_k.h` | 0.109 | 0.142 | 0.000 | low-mechanical-overlap |
| `pa02_mlk_poly_add_full_signed_contract_valid_harness.c` | `REFERENCE.md` | 0.106 | 0.078 | 0.000 | low-mechanical-overlap |
| `pa05a_mlk_poly_add_polyvec_production_callsite_harness.c` | `mlkem/src/poly.c` | 0.106 | 0.200 | 0.014 | low-mechanical-overlap |
| `pa04a_mlk_poly_add_alias_safe_doubling_harness.c` | `mlkem/src/poly_k.c` | 0.106 | 0.201 | 0.004 | low-mechanical-overlap |
| `pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c` | `mlkem/src/poly.h` | 0.104 | 0.254 | 0.000 | low-mechanical-overlap |
| `pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c` | `mlkem/src/poly.c` | 0.104 | 0.217 | 0.014 | low-mechanical-overlap |
| `pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c` | `REFERENCE.md` | 0.103 | 0.085 | 0.000 | low-mechanical-overlap |
| `pa08b_mlk_poly_add_reachability_sentinel_harness.c` | `proofs/cbmc/poly_add/poly_add_harness.c` | 0.101 | 0.203 | 0.000 | low-mechanical-overlap |
| `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c` | `mlkem/src/poly_k.c` | 0.099 | 0.225 | 0.004 | low-mechanical-overlap |
| `pa05a_mlk_poly_add_polyvec_production_callsite_harness.c` | `REFERENCE.md` | 0.098 | 0.075 | 0.000 | low-mechanical-overlap |
| `pa07_mlk_poly_add_mutant_implementation.c` | `proofs/cbmc/poly_add/poly_add_harness.c` | 0.095 | 0.276 | 0.000 | low-mechanical-overlap |
| `pa08b_mlk_poly_add_reachability_sentinel_harness.c` | `mlkem/src/poly_k.c` | 0.094 | 0.202 | 0.005 | low-mechanical-overlap |
| `pa08d_mlk_poly_add_lower_outside_boundary_harness.c` | `mlkem/src/poly.c` | 0.094 | 0.216 | 0.010 | low-mechanical-overlap |
| `pa05a_mlk_poly_add_polyvec_production_callsite_harness.c` | `mlkem/src/poly_k.h` | 0.094 | 0.163 | 0.000 | low-mechanical-overlap |
| `pa08a_mlk_poly_add_boundary_hardening_harness.c` | `mlkem/src/indcpa.c` | 0.093 | 0.147 | 0.003 | low-mechanical-overlap |
| `pa03_mlk_poly_add_unrestricted_negative_control_harness.c` | `REFERENCE.md` | 0.093 | 0.061 | 0.000 | low-mechanical-overlap |
| `pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c` | `REFERENCE.md` | 0.092 | 0.065 | 0.000 | low-mechanical-overlap |
| `pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c` | `REFERENCE.md` | 0.090 | 0.075 | 0.000 | low-mechanical-overlap |
| `pa03_mlk_poly_add_unrestricted_negative_control_harness.c` | `mlkem/src/poly_k.c` | 0.090 | 0.205 | 0.005 | low-mechanical-overlap |
| `pa08a_mlk_poly_add_boundary_hardening_harness.c` | `mlkem/src/poly_k.h` | 0.090 | 0.144 | 0.000 | low-mechanical-overlap |
| `pa08b_mlk_poly_add_reachability_sentinel_harness.c` | `REFERENCE.md` | 0.089 | 0.050 | 0.000 | low-mechanical-overlap |
| `pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c` | `mlkem/src/poly.c` | 0.088 | 0.235 | 0.009 | low-mechanical-overlap |
| `pa07_mlk_poly_add_mutant_implementation.c` | `mlkem/src/poly.c` | 0.087 | 0.261 | 0.016 | low-mechanical-overlap |
| `pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c` | `REFERENCE.md` | 0.086 | 0.071 | 0.000 | low-mechanical-overlap |
| `pa08d_mlk_poly_add_lower_outside_boundary_harness.c` | `test/bench/bench_components_mlkem.c` | 0.085 | 0.155 | 0.005 | low-mechanical-overlap |
| `pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c` | `mlkem/src/poly_k.h` | 0.085 | 0.151 | 0.000 | low-mechanical-overlap |
| `pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c` | `proofs/cbmc/README.md` | 0.085 | 0.140 | 0.014 | low-mechanical-overlap |
| `pa03_mlk_poly_add_unrestricted_negative_control_harness.c` | `mlkem/src/poly.c` | 0.085 | 0.209 | 0.010 | low-mechanical-overlap |
| `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c` | `mlkem/src/indcpa.c` | 0.085 | 0.193 | 0.003 | low-mechanical-overlap |
| `pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c` | `mlkem/src/indcpa.c` | 0.085 | 0.173 | 0.003 | low-mechanical-overlap |
| `pa04a_mlk_poly_add_alias_safe_doubling_harness.c` | `mlkem/src/indcpa.c` | 0.084 | 0.160 | 0.003 | low-mechanical-overlap |
| `pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c` | `mlkem/src/poly_k.c` | 0.084 | 0.224 | 0.005 | low-mechanical-overlap |
| `pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c` | `mlkem/mlkem_native.c` | 0.084 | 0.025 | 0.000 | low-mechanical-overlap |
| `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c` | `proofs/cbmc/README.md` | 0.084 | 0.158 | 0.014 | low-mechanical-overlap |
| `pa03_mlk_poly_add_unrestricted_negative_control_harness.c` | `mlkem/src/poly_k.h` | 0.083 | 0.150 | 0.000 | low-mechanical-overlap |
| `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c` | `mlkem/src/poly.c` | 0.083 | 0.234 | 0.007 | low-mechanical-overlap |
| `pa08c_mlk_poly_add_upper_outside_boundary_harness.c` | `mlkem/src/poly_k.c` | 0.081 | 0.194 | 0.005 | low-mechanical-overlap |
| `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c` | `proofs/cbmc/proof_guide.md` | 0.081 | 0.071 | 0.002 | low-mechanical-overlap |
| `pa04a_mlk_poly_add_alias_safe_doubling_harness.c` | `mlkem/src/poly_k.h` | 0.080 | 0.155 | 0.000 | low-mechanical-overlap |
| `pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c` | `mlkem/src/indcpa.c` | 0.080 | 0.173 | 0.003 | low-mechanical-overlap |
| `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c` | `mlkem/mlkem_native.c` | 0.080 | 0.028 | 0.000 | low-mechanical-overlap |
| `pa05a_mlk_poly_add_polyvec_production_callsite_harness.c` | `proofs/cbmc/poly_add/poly_add_harness.c` | 0.079 | 0.131 | 0.000 | low-mechanical-overlap |
| `pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c` | `mlkem/src/poly_k.h` | 0.079 | 0.168 | 0.000 | low-mechanical-overlap |
| `pa08d_mlk_poly_add_lower_outside_boundary_harness.c` | `mlkem/src/poly_k.c` | 0.079 | 0.193 | 0.005 | low-mechanical-overlap |
| `pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c` | `mlkem/src/poly_k.h` | 0.079 | 0.188 | 0.000 | low-mechanical-overlap |
| `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c` | `mlkem/src/poly_k.h` | 0.079 | 0.177 | 0.000 | low-mechanical-overlap |
| `pa08c_mlk_poly_add_upper_outside_boundary_harness.c` | `mlkem/src/poly.c` | 0.079 | 0.217 | 0.010 | low-mechanical-overlap |
| `pa08c_mlk_poly_add_upper_outside_boundary_harness.c` | `test/bench/bench_components_mlkem.c` | 0.078 | 0.156 | 0.005 | low-mechanical-overlap |
| `pa08b_mlk_poly_add_reachability_sentinel_harness.c` | `mlkem/src/poly_k.h` | 0.078 | 0.156 | 0.000 | low-mechanical-overlap |

## 8. Annotation and Property Catalogue

```text
repository:REFERENCE.md:10: - CBMC and debug annotations, and minor code restructurings or signature changes to facilitate the CBMC proofs. For example, `poly_add(x,a)` only comes in a destructive variant to avoid specifying aliasing constraints; `poly_rej_uniform` has an additional `offset` parameter indicating the position in the sampling buffer, to avoid passing shifted pointers).
repository:SOUNDNESS.md:314:   `requires(array_abs_bound(p, 0, MLKEM_N, 8192))`
repository:SOUNDNESS.md:315:   and `ensures(array_abs_bound(p, 0, MLKEM_N, 23595))`, omitting the description of the
repository:SOUNDNESS.md:319:   assumes `requires(twiddles12345 == mlk_aarch64_ntt_zetas_layer12345)` and `requires(twiddles56 ==
repository:mlkem/mlkem_native.c:327: #undef mlk_poly_add
repository:mlkem/mlkem_native.c:399: #undef __contract__
repository:mlkem/mlkem_native.c:400: #undef __loop__
repository:mlkem/src/indcpa.c:161: __contract__(
repository:mlkem/src/indcpa.c:164:   requires(memory_no_alias(v, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:165:   requires(forall(x, 0, MLKEM_K,
repository:mlkem/src/indcpa.c:167:   assigns(memory_slice(v, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:168:   ensures(forall(x, 0, MLKEM_K,
repository:mlkem/src/indcpa.c:174:   __loop__(
repository:mlkem/src/indcpa.c:175:      assigns(i, memory_slice(v, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:176:      invariant(i <= MLKEM_K)
repository:mlkem/src/indcpa.c:177:      invariant(forall(x, 0, MLKEM_K,
repository:mlkem/src/indcpa.c:179:      decreases(MLKEM_K - i))
repository:mlkem/src/indcpa.c:190: __contract__(
repository:mlkem/src/indcpa.c:193:   requires(memory_no_alias(a, sizeof(mlk_polymat)))
repository:mlkem/src/indcpa.c:194:   requires(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
repository:mlkem/src/indcpa.c:196:   assigns(memory_slice(a, sizeof(mlk_polymat)))
repository:mlkem/src/indcpa.c:197:   ensures(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
repository:mlkem/src/indcpa.c:202:   __loop__(
repository:mlkem/src/indcpa.c:203:      assigns(i, memory_slice(a, sizeof(mlk_polymat)))
repository:mlkem/src/indcpa.c:204:      invariant(i <= MLKEM_K)
repository:mlkem/src/indcpa.c:205:      invariant(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
repository:mlkem/src/indcpa.c:207:      decreases(MLKEM_K - i))
repository:mlkem/src/indcpa.c:316: __contract__(
repository:mlkem/src/indcpa.c:317:   requires(memory_no_alias(out, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:318:   requires(memory_no_alias(a, sizeof(mlk_polymat)))
repository:mlkem/src/indcpa.c:319:   requires(memory_no_alias(v, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:320:   requires(memory_no_alias(vc, sizeof(mlk_polyvec_mulcache)))
repository:mlkem/src/indcpa.c:321:   requires(forall(k0, 0, MLKEM_K,
repository:mlkem/src/indcpa.c:324:   assigns(memory_slice(out, sizeof(mlk_polyvec))))
repository:mlkem/src/indcpa.c:328:   __loop__(
repository:mlkem/src/indcpa.c:329:     assigns(i, memory_slice(out, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:330:     invariant(i <= MLKEM_K)
repository:mlkem/src/indcpa.c:331:     decreases(MLKEM_K - i))
repository:mlkem/src/indcpa.c:350: __contract__(
repository:mlkem/src/indcpa.c:351:   requires(memory_no_alias(pv, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:352:   requires(memory_no_alias(e, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:353:   requires(memory_no_alias(seed, MLKEM_SYMBYTES))
repository:mlkem/src/indcpa.c:354:   assigns(memory_slice(pv, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:355:   assigns(memory_slice(e, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:356:   ensures(forall(k0, 0, MLKEM_K, array_abs_bound(pv->vec[k0].coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1)))
repository:mlkem/src/indcpa.c:357:   ensures(forall(k1, 0, MLKEM_K, array_abs_bound(e->vec[k1].coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1)))
repository:mlkem/src/indcpa.c:397: __contract__(
repository:mlkem/src/indcpa.c:398:   requires(memory_no_alias(sp, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:399:   requires(memory_no_alias(ep, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:400:   requires(memory_no_alias(epp, sizeof(mlk_poly)))
repository:mlkem/src/indcpa.c:401:   requires(memory_no_alias(coins, MLKEM_SYMBYTES))
repository:mlkem/src/indcpa.c:402:   assigns(memory_slice(sp, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:403:   assigns(memory_slice(ep, sizeof(mlk_polyvec)))
repository:mlkem/src/indcpa.c:404:   assigns(memory_slice(epp, sizeof(mlk_poly)))
repository:mlkem/src/indcpa.c:405:   ensures(forall(k0, 0, MLKEM_K, array_abs_bound(sp->vec[k0].coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1)))
repository:mlkem/src/indcpa.c:406:   ensures(forall(k1, 0, MLKEM_K, array_abs_bound(ep->vec[k1].coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1)))
repository:mlkem/src/indcpa.c:407:   ensures(array_abs_bound(epp->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1))
repository:mlkem/src/indcpa.c:571:   mlk_poly_add(v, epp);
repository:mlkem/src/indcpa.c:572:   mlk_poly_add(v, k);
repository:mlkem/src/poly.c:44: __contract__(
repository:mlkem/src/poly.c:45:   requires(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF)
repository:mlkem/src/poly.c:46:   ensures(return_value > -MLKEM_Q && return_value < MLKEM_Q)
repository:mlkem/src/poly.c:76: __contract__(
repository:mlkem/src/poly.c:77:   ensures(return_value > -MLKEM_Q_HALF && return_value < MLKEM_Q_HALF)
repository:mlkem/src/poly.c:110: __contract__(
repository:mlkem/src/poly.c:111:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.c:112:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.c:113:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
repository:mlkem/src/poly.c:119:   __loop__(
repository:mlkem/src/poly.c:120:     invariant(i <= MLKEM_N)
repository:mlkem/src/poly.c:121:     invariant(array_abs_bound(r->coeffs, 0, i, MLKEM_Q))
repository:mlkem/src/poly.c:122:     decreases(MLKEM_N - i))
repository:mlkem/src/poly.c:161: __contract__(
repository:mlkem/src/poly.c:162:   requires(c > -MLKEM_Q && c < MLKEM_Q)
repository:mlkem/src/poly.c:163:   ensures(return_value >= 0 && return_value < MLKEM_Q)
repository:mlkem/src/poly.c:164:   ensures(return_value == (int32_t)c + (((int32_t)c < 0) * MLKEM_Q)))
repository:mlkem/src/poly.c:186: __contract__(
repository:mlkem/src/poly.c:187:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.c:188:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.c:189:   ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
repository:mlkem/src/poly.c:195:   __loop__(
repository:mlkem/src/poly.c:196:     invariant(i <= MLKEM_N)
repository:mlkem/src/poly.c:197:     invariant(array_bound(r->coeffs, 0, i, 0, MLKEM_Q))
repository:mlkem/src/poly.c:198:     decreases(MLKEM_N - i))
repository:mlkem/src/poly.c:225: /* Reference: `poly_add()` in the reference implementation @[REF].
repository:mlkem/src/poly.c:229: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
repository:mlkem/src/poly.c:233:   __loop__(
repository:mlkem/src/poly.c:234:     invariant(i <= MLKEM_N)
repository:mlkem/src/poly.c:235:     invariant(forall(k0, i, MLKEM_N, r->coeffs[k0] == loop_entry(*r).coeffs[k0]))
repository:mlkem/src/poly.c:236:     invariant(forall(k1, 0, i, r->coeffs[k1] == loop_entry(*r).coeffs[k1] + b->coeffs[k1]))
repository:mlkem/src/poly.c:237:     decreases(MLKEM_N - i))
repository:mlkem/src/poly.c:252:   __loop__(
repository:mlkem/src/poly.c:253:     invariant(i <= MLKEM_N)
repository:mlkem/src/poly.c:254:     invariant(forall(k0, i, MLKEM_N, r->coeffs[k0] == loop_entry(*r).coeffs[k0]))
repository:mlkem/src/poly.c:255:     invariant(forall(k1, 0, i, r->coeffs[k1] == loop_entry(*r).coeffs[k1] - b->coeffs[k1]))
repository:mlkem/src/poly.c:256:     decreases(MLKEM_N - i))
repository:mlkem/src/poly.c:271: __contract__(
repository:mlkem/src/poly.c:272:   requires(memory_no_alias(x, sizeof(mlk_poly_mulcache)))
repository:mlkem/src/poly.c:273:   requires(memory_no_alias(a, sizeof(mlk_poly)))
repository:mlkem/src/poly.c:274:   assigns(memory_slice(x, sizeof(mlk_poly_mulcache)))
repository:mlkem/src/poly.c:279:   __loop__(
repository:mlkem/src/poly.c:280:     invariant(i <= MLKEM_N / 4)
repository:mlkem/src/poly.c:281:     invariant(array_abs_bound(x->coeffs, 0, 2 * i, MLKEM_Q))
repository:mlkem/src/poly.c:282:     decreases(MLKEM_N / 4 - i))
repository:mlkem/src/poly.c:346: __contract__(
repository:mlkem/src/poly.c:347:   requires(start < MLKEM_N)
repository:mlkem/src/poly.c:348:   requires(1 <= len && len <= MLKEM_N / 2 && start + 2 * len <= MLKEM_N)
repository:mlkem/src/poly.c:349:   requires(0 <= bound && bound < INT16_MAX - MLKEM_Q)
repository:mlkem/src/poly.c:350:   requires(-MLKEM_Q_HALF < zeta && zeta < MLKEM_Q_HALF)
repository:mlkem/src/poly.c:351:   requires(memory_no_alias(r, sizeof(int16_t) * MLKEM_N))
repository:mlkem/src/poly.c:352:   requires(array_abs_bound(r, 0, start, bound + MLKEM_Q))
repository:mlkem/src/poly.c:353:   requires(array_abs_bound(r, start, MLKEM_N, bound))
repository:mlkem/src/poly.c:354:   assigns(memory_slice(r, sizeof(int16_t) * MLKEM_N))
repository:mlkem/src/poly.c:355:   ensures(array_abs_bound(r, 0, start + 2*len, bound + MLKEM_Q))
repository:mlkem/src/poly.c:356:   ensures(array_abs_bound(r, start + 2 * len, MLKEM_N, bound)))
repository:mlkem/src/poly.c:362:   __loop__(
repository:mlkem/src/poly.c:363:     invariant(start <= j && j <= start + len)
repository:mlkem/src/poly.c:368:     invariant(array_abs_bound(r, 0,           j,           bound + MLKEM_Q))
repository:mlkem/src/poly.c:369:     invariant(array_abs_bound(r, j,           start + len, bound))
repository:mlkem/src/poly.c:370:     invariant(array_abs_bound(r, start + len, j + len,     bound + MLKEM_Q))
repository:mlkem/src/poly.c:371:     invariant(array_abs_bound(r, j + len,     MLKEM_N,     bound))
repository:mlkem/src/poly.c:372:     decreases(start + len - j))
repository:mlkem/src/poly.c:391: __contract__(
repository:mlkem/src/poly.c:392:   requires(memory_no_alias(r, sizeof(int16_t) * MLKEM_N))
repository:mlkem/src/poly.c:393:   requires(1 <= layer && layer <= 7)
repository:mlkem/src/poly.c:394:   requires(array_abs_bound(r, 0, MLKEM_N, layer * MLKEM_Q))
repository:mlkem/src/poly.c:395:   assigns(memory_slice(r, sizeof(int16_t) * MLKEM_N))
repository:mlkem/src/poly.c:396:   ensures(array_abs_bound(r, 0, MLKEM_N, (layer + 1) * MLKEM_Q)))
repository:mlkem/src/poly.c:403:   __loop__(
repository:mlkem/src/poly.c:404:     invariant(start < MLKEM_N + 2 * len)
repository:mlkem/src/poly.c:405:     invariant(k <= MLKEM_N / 2 && 2 * len * k == start + MLKEM_N)
repository:mlkem/src/poly.c:406:     invariant(array_abs_bound(r, 0, start, layer * MLKEM_Q + MLKEM_Q))
repository:mlkem/src/poly.c:407:     invariant(array_abs_bound(r, start, MLKEM_N, layer * MLKEM_Q))
repository:mlkem/src/poly.c:408:     decreases(MLKEM_N - start))
repository:mlkem/src/poly.c:428: __contract__(
repository:mlkem/src/poly.c:429:   requires(memory_no_alias(p, sizeof(mlk_poly)))
repository:mlkem/src/poly.c:430:   requires(array_abs_bound(p->coeffs, 0, MLKEM_N, MLKEM_Q))
repository:mlkem/src/poly.c:431:   assigns(memory_slice(p, sizeof(mlk_poly)))
repository:mlkem/src/poly.c:432:   ensures(array_abs_bound(p->coeffs, 0, MLKEM_N, MLK_NTT_BOUND))
repository:mlkem/src/poly.c:443:   __loop__(
repository:mlkem/src/poly.c:444:     invariant(1 <= layer && layer <= 8)
repository:mlkem/src/poly.c:445:     invariant(array_abs_bound(r, 0, MLKEM_N, layer * MLKEM_Q))
repository:mlkem/src/poly.c:446:     decreases(8 - layer))
repository:mlkem/src/poly.c:477: __contract__(
repository:mlkem/src/poly.c:478:   requires(memory_no_alias(r, sizeof(int16_t) * MLKEM_N))
repository:mlkem/src/poly.c:479:   requires(1 <= layer && layer <= 7)
repository:mlkem/src/poly.c:480:   requires(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
repository:mlkem/src/poly.c:481:   assigns(memory_slice(r, sizeof(int16_t) * MLKEM_N))
repository:mlkem/src/poly.c:482:   ensures(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q)))
repository:mlkem/src/poly.c:488:   __loop__(
repository:mlkem/src/poly.c:489:     invariant(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
repository:mlkem/src/poly.c:490:     invariant(start <= MLKEM_N && k <= 127)
repository:mlkem/src/poly.c:492:     invariant(2 * len * k + start == 2 * MLKEM_N - 2 * len)
repository:mlkem/src/poly.c:493:     decreases(MLKEM_N - start))
repository:mlkem/src/poly.c:498:     __loop__(
repository:mlkem/src/poly.c:499:       invariant(start <= j && j <= start + len)
repository:mlkem/src/poly.c:500:       invariant(start <= MLKEM_N && k <= 127)
repository:mlkem/src/poly.c:501:       invariant(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
repository:mlkem/src/poly.c:502:       decreases(start + len - j))
repository:mlkem/src/poly.c:519: __contract__(
repository:mlkem/src/poly.c:520:   requires(memory_no_alias(p, sizeof(mlk_poly)))
repository:mlkem/src/poly.c:521:   assigns(memory_slice(p, sizeof(mlk_poly)))
repository:mlkem/src/poly.c:522:   ensures(array_abs_bound(p->coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND))
repository:mlkem/src/poly.c:535:   __loop__(
repository:mlkem/src/poly.c:536:     invariant(j <= MLKEM_N)
repository:mlkem/src/poly.c:537:     invariant(array_abs_bound(r, 0, j, MLKEM_Q))
repository:mlkem/src/poly.c:538:     decreases(MLKEM_N - j))
repository:mlkem/src/poly.c:545:   __loop__(
repository:mlkem/src/poly.c:546:     invariant(0 <= layer && layer < 8)
repository:mlkem/src/poly.c:547:     invariant(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
repository:mlkem/src/poly.c:548:     decreases(layer))
repository:mlkem/src/poly.h:59: __contract__(
repository:mlkem/src/poly.h:60:     requires(a < +(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)) &&
repository:mlkem/src/poly.h:117: __contract__(
repository:mlkem/src/poly.h:118:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:119:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:120:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
repository:mlkem/src/poly.h:148: __contract__(
repository:mlkem/src/poly.h:149:   requires(memory_no_alias(x, sizeof(mlk_poly_mulcache)))
repository:mlkem/src/poly.h:150:   requires(memory_no_alias(a, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:151:   assigns(memory_slice(x, sizeof(mlk_poly_mulcache)))
repository:mlkem/src/poly.h:175: __contract__(
repository:mlkem/src/poly.h:176:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:177:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:178:   ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
repository:mlkem/src/poly.h:181: #define mlk_poly_add MLK_NAMESPACE(poly_add)
repository:mlkem/src/poly.h:196:  * NOTE: The reference implementation uses a 3-argument mlk_poly_add.
repository:mlkem/src/poly.h:200: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
repository:mlkem/src/poly.h:201: __contract__(
repository:mlkem/src/poly.h:202:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:203:   requires(memory_no_alias(b, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:204:   requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] + b->coeffs[k0] <= INT16_MAX))
repository:mlkem/src/poly.h:205:   requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] + b->coeffs[k1] >= INT16_MIN))
repository:mlkem/src/poly.h:206:   ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] + b->coeffs[k]))
repository:mlkem/src/poly.h:207:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:226: __contract__(
repository:mlkem/src/poly.h:227:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:228:   requires(memory_no_alias(b, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:229:   requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] - b->coeffs[k0] <= INT16_MAX))
repository:mlkem/src/poly.h:230:   requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] - b->coeffs[k1] >= INT16_MIN))
repository:mlkem/src/poly.h:231:   ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] - b->coeffs[k]))
repository:mlkem/src/poly.h:232:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:256: __contract__(
repository:mlkem/src/poly.h:257:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:258:   requires(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
repository:mlkem/src/poly.h:259:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:260:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLK_NTT_BOUND))
repository:mlkem/src/poly.h:284: __contract__(
repository:mlkem/src/poly.h:285:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:286:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly.h:287:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND))
repository:mlkem/src/poly_k.c:86:   __loop__(
repository:mlkem/src/poly_k.c:87:     assigns(i, memory_slice(r, MLKEM_POLYVECBYTES))
repository:mlkem/src/poly_k.c:88:     invariant(i <= MLKEM_K)
repository:mlkem/src/poly_k.c:89:     decreases(MLKEM_K - i)
repository:mlkem/src/poly_k.c:153: __contract__(
repository:mlkem/src/poly_k.c:154:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.c:155:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.c:156:   requires(memory_no_alias(b, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.c:157:   requires(memory_no_alias(b_cache, sizeof(mlk_polyvec_mulcache)))
repository:mlkem/src/poly_k.c:158:   requires(forall(k1, 0, MLKEM_K,
repository:mlkem/src/poly_k.c:160:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.c:167:   __loop__(invariant(i <= MLKEM_N / 2)
repository:mlkem/src/poly_k.c:168:            decreases(MLKEM_N / 2 - i))
repository:mlkem/src/poly_k.c:173:     __loop__(
repository:mlkem/src/poly_k.c:174:       invariant(k <= MLKEM_K &&
repository:mlkem/src/poly_k.c:179:       decreases(MLKEM_K - k))
repository:mlkem/src/poly_k.c:264:   __loop__(
repository:mlkem/src/poly_k.c:265:     assigns(i, memory_slice(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.c:266:     invariant(i <= MLKEM_K)
repository:mlkem/src/poly_k.c:267:     invariant(forall(j0, i, MLKEM_K,
repository:mlkem/src/poly_k.c:271:     invariant(forall(j2, 0, i,
repository:mlkem/src/poly_k.c:275:     decreases(MLKEM_K - i)
repository:mlkem/src/poly_k.c:278:     mlk_poly_add(&r->vec[i], &b->vec[i]);
repository:mlkem/src/poly_k.c:312: __contract__(
repository:mlkem/src/poly_k.c:313:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.c:314:   requires(memory_no_alias(buf, MLKEM_ETA1 * MLKEM_N / 4))
repository:mlkem/src/poly_k.c:315:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.c:316:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1))
repository:mlkem/src/poly_k.c:399: __contract__(
repository:mlkem/src/poly_k.c:400:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.c:401:   requires(memory_no_alias(buf, MLKEM_ETA2 * MLKEM_N / 4))
repository:mlkem/src/poly_k.c:402:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.c:403:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1)))
repository:mlkem/src/poly_k.h:64: __contract__(
repository:mlkem/src/poly_k.h:65:   requires(memory_no_alias(r, MLKEM_POLYCOMPRESSEDBYTES_DU))
repository:mlkem/src/poly_k.h:66:   requires(memory_no_alias(a, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:67:   requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
repository:mlkem/src/poly_k.h:68:   assigns(memory_slice(r, MLKEM_POLYCOMPRESSEDBYTES_DU)))
repository:mlkem/src/poly_k.h:97: __contract__(
repository:mlkem/src/poly_k.h:98:   requires(memory_no_alias(a, MLKEM_POLYCOMPRESSEDBYTES_DU))
repository:mlkem/src/poly_k.h:99:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:100:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:101:   ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
repository:mlkem/src/poly_k.h:127: __contract__(
repository:mlkem/src/poly_k.h:128:   requires(memory_no_alias(r, MLKEM_POLYCOMPRESSEDBYTES_DV))
repository:mlkem/src/poly_k.h:129:   requires(memory_no_alias(a, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:130:   requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
repository:mlkem/src/poly_k.h:131:   assigns(memory_slice(r, MLKEM_POLYCOMPRESSEDBYTES_DV)))
repository:mlkem/src/poly_k.h:161: __contract__(
repository:mlkem/src/poly_k.h:162:   requires(memory_no_alias(a, MLKEM_POLYCOMPRESSEDBYTES_DV))
repository:mlkem/src/poly_k.h:163:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:164:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:165:   ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
repository:mlkem/src/poly_k.h:192: __contract__(
repository:mlkem/src/poly_k.h:193:   requires(memory_no_alias(r, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
repository:mlkem/src/poly_k.h:194:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:195:   requires(forall(k0, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:197:   assigns(memory_slice(r, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
repository:mlkem/src/poly_k.h:217: __contract__(
repository:mlkem/src/poly_k.h:218:   requires(memory_no_alias(a, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
repository:mlkem/src/poly_k.h:219:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:220:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:221:   ensures(forall(k0, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:239: __contract__(
repository:mlkem/src/poly_k.h:240:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:241:   requires(memory_no_alias(r, MLKEM_POLYVECBYTES))
repository:mlkem/src/poly_k.h:242:   requires(forall(k0, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:244:   assigns(memory_slice(r, MLKEM_POLYVECBYTES))
repository:mlkem/src/poly_k.h:261: __contract__(
repository:mlkem/src/poly_k.h:262:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:263:   requires(memory_no_alias(a, MLKEM_POLYVECBYTES))
repository:mlkem/src/poly_k.h:264:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:265:   ensures(forall(k0, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:286: __contract__(
repository:mlkem/src/poly_k.h:287:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:288:   requires(forall(j, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:290:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:291:   ensures(forall(j, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:313: __contract__(
repository:mlkem/src/poly_k.h:314:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:315:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:316:   ensures(forall(j, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:343: __contract__(
repository:mlkem/src/poly_k.h:344:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:345:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:346:   requires(memory_no_alias(b, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:347:   requires(memory_no_alias(b_cache, sizeof(mlk_polyvec_mulcache)))
repository:mlkem/src/poly_k.h:348:   requires(forall(k1, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:350:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:381: __contract__(
repository:mlkem/src/poly_k.h:382:   requires(memory_no_alias(x, sizeof(mlk_polyvec_mulcache)))
repository:mlkem/src/poly_k.h:383:   requires(memory_no_alias(a, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:384:   assigns(memory_slice(x, sizeof(mlk_polyvec_mulcache)))
repository:mlkem/src/poly_k.h:407: __contract__(
repository:mlkem/src/poly_k.h:408:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:409:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:410:   ensures(forall(k0, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:433: __contract__(
repository:mlkem/src/poly_k.h:434:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:435:   requires(memory_no_alias(b, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:436:   requires(forall(j0, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:439:   requires(forall(j1, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:442:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:460: __contract__(
repository:mlkem/src/poly_k.h:461:   requires(memory_no_alias(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:462:   assigns(memory_slice(r, sizeof(mlk_polyvec)))
repository:mlkem/src/poly_k.h:463:   ensures(forall(j, 0, MLKEM_K,
repository:mlkem/src/poly_k.h:494: __contract__(
repository:mlkem/src/poly_k.h:495:   requires(memory_no_alias(seed, MLKEM_SYMBYTES))
repository:mlkem/src/poly_k.h:496:   requires(memory_no_alias(r0, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:497:   requires(memory_no_alias(r1, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:498:   requires(memory_no_alias(r2, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:499:   requires(r3 == NULL || memory_no_alias(r3, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:500:   assigns(memory_slice(r0, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:501:   assigns(memory_slice(r1, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:502:   assigns(memory_slice(r2, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:503:   assigns(r3 != NULL: memory_slice(r3, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:504:   ensures(array_abs_bound(r0->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
repository:mlkem/src/poly_k.h:505:   ensures(array_abs_bound(r1->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
repository:mlkem/src/poly_k.h:506:   ensures(array_abs_bound(r2->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
repository:mlkem/src/poly_k.h:507:   ensures(r3 != NULL ==> array_abs_bound(r3->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
repository:mlkem/src/poly_k.h:538: __contract__(
repository:mlkem/src/poly_k.h:539:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:540:   requires(memory_no_alias(seed, MLKEM_SYMBYTES))
repository:mlkem/src/poly_k.h:541:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:542:   ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1))
repository:mlkem/src/poly_k.h:576: __contract__(
repository:mlkem/src/poly_k.h:577:   requires(memory_no_alias(r0, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:578:   requires(memory_no_alias(r1, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:579:   requires(memory_no_alias(r2, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:580:   requires(memory_no_alias(r3, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:581:   requires(memory_no_alias(seed, MLKEM_SYMBYTES))
repository:mlkem/src/poly_k.h:582:   assigns(memory_slice(r0, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:583:   assigns(memory_slice(r1, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:584:   assigns(memory_slice(r2, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:585:   assigns(memory_slice(r3, sizeof(mlk_poly)))
repository:mlkem/src/poly_k.h:586:   ensures(array_abs_bound(r0->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1)
repository:proofs/cbmc/README.md:15: For example, these are the specification and proof of the `poly_add` function:
repository:proofs/cbmc/README.md:17: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
repository:proofs/cbmc/README.md:18: __contract__(
repository:proofs/cbmc/README.md:19:   requires(memory_no_alias(r, sizeof(mlk_poly)))
repository:proofs/cbmc/README.md:20:   requires(memory_no_alias(b, sizeof(mlk_poly)))
repository:proofs/cbmc/README.md:21:   requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] + b->coeffs[k0] <= INT16_MAX))
repository:proofs/cbmc/README.md:22:   requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] + b->coeffs[k1] >= INT16_MIN))
repository:proofs/cbmc/README.md:23:   ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] + b->coeffs[k]))
repository:proofs/cbmc/README.md:24:   assigns(memory_slice(r, sizeof(mlk_poly)))
repository:proofs/cbmc/README.md:29: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
repository:proofs/cbmc/README.md:33:   __loop__(
repository:proofs/cbmc/README.md:34:     invariant(i <= MLKEM_N)
repository:proofs/cbmc/README.md:35:     invariant(forall(k0, i, MLKEM_N, r->coeffs[k0] == loop_entry(*r).coeffs[k0]))
repository:proofs/cbmc/README.md:36:     invariant(forall(k1, 0, i, r->coeffs[k1] == loop_entry(*r).coeffs[k1] + b->coeffs[k1])))
repository:proofs/cbmc/indcpa_enc/Makefile:33: USE_FUNCTION_CONTRACTS += mlk_poly_add
repository:proofs/cbmc/poly_add/Makefile:11: PROOF_UID = mlk_poly_add
repository:proofs/cbmc/poly_add/Makefile:22: CHECK_FUNCTION_CONTRACTS=mlk_poly_add
repository:proofs/cbmc/poly_add/Makefile:31: FUNCTION_NAME = mlk_poly_add
repository:proofs/cbmc/poly_add/poly_add_harness.c:10:   mlk_poly_add(r, b);
repository:proofs/cbmc/polyvec_add/Makefile:22: USE_FUNCTION_CONTRACTS=mlk_poly_add
repository:proofs/cbmc/proof_guide.md:43:   requires(...)
repository:proofs/cbmc/proof_guide.md:45:   requires(...)
repository:proofs/cbmc/proof_guide.md:46:   assigns(...)
repository:proofs/cbmc/proof_guide.md:47:   ensures(...)
repository:proofs/cbmc/proof_guide.md:49:   ensures(...)
repository:proofs/cbmc/proof_guide.md:54: arbitrary number of `ensures(...)` clauses specifies the post-condition. One also needs an `assigns(...)` clause
repository:proofs/cbmc/proof_guide.md:65: reduce it as much as possible in mlkem-native. For example, rather than having `mlk_poly_add(dst, src0, src1)` where `dst`
repository:proofs/cbmc/proof_guide.md:66: may overlap with `src0` or `src1`, we only have a destructive `mlk_poly_add(dst, src)` implementing `dst += src`, thereby
repository:proofs/cbmc/proof_guide.md:105: __contract__(
repository:proofs/cbmc/proof_guide.md:106:   requires(len * sizeof(t) <= MLK_MAX_BUFFER_SIZE)
repository:proofs/cbmc/proof_guide.md:107:   requires(memory_no_alias(p, len * sizeof(t)))
repository:proofs/cbmc/proof_guide.md:113: The most common way to specify memory footprint in `assigns(...)` clauses is via `memory_slice(ptr, len)`. This asserts
repository:proofs/cbmc/proof_guide.md:117: with care: If a function precondition specifies `requires(memory_no_alias(ptr, 42))` and `assigns(object_whole(ptr))`
repository:proofs/cbmc/proof_guide.md:124: If you need to specify a quantified condition for use in `ensures(...)` or `requires(...)`, you can use the
repository:proofs/cbmc/proof_guide.md:136: Loop invariants are specified using `__loop__(...)` as follows:
repository:proofs/cbmc/proof_guide.md:140: __loop__(
repository:proofs/cbmc/proof_guide.md:141:   assigns(...)
repository:proofs/cbmc/proof_guide.md:142:   invariant(...)
repository:proofs/cbmc/proof_guide.md:144:   invariant(...))
repository:proofs/cbmc/proof_guide.md:150: Here, one or more `invariant(...)` clauses describe the invariant maintained by the loop body. As for function
repository:proofs/cbmc/proof_guide.md:151: contracts, `assigns(...)` captures the footprint of the loop body.
repository:proofs/cbmc/proof_guide.md:172: __loop__(
repository:proofs/cbmc/proof_guide.md:173:   assigns(i, ...)   /* plus whatever else S does */
repository:proofs/cbmc/proof_guide.md:174:   invariant(i <= C) /* Counter invariant */
repository:proofs/cbmc/proof_guide.md:175:   invariant(...)    /* Further invariants */
repository:proofs/cbmc/proof_guide.md:176:   decreases(C - i))
repository:proofs/cbmc/proof_guide.md:194: __contract__(
repository:proofs/cbmc/proof_guide.md:195:   requires(memory_no_alias(dst, len))
repository:proofs/cbmc/proof_guide.md:196:   assigns(object_whole(dst)));
repository:proofs/cbmc/proof_guide.md:210:     __loop__(
repository:proofs/cbmc/proof_guide.md:211:       assigns(i, object_whole(dst))
repository:proofs/cbmc/proof_guide.md:212:       invariant(i <= len)
repository:proofs/cbmc/proof_guide.md:213:       decreases(len - i))
repository:proofs/cbmc/proof_guide.md:231: __contract__(
repository:proofs/cbmc/proof_guide.md:232:   requires(memory_no_alias(dst, len))
repository:proofs/cbmc/proof_guide.md:233:   assigns(object_whole(dst))
repository:proofs/cbmc/proof_guide.md:234:   ensures(forall(k, 0, len, dst[k] == 0)));
repository:proofs/cbmc/proof_guide.md:245:     __loop__(
repository:proofs/cbmc/proof_guide.md:246:       assigns(i, object_whole(dst))
repository:proofs/cbmc/proof_guide.md:247:       invariant(i <= len)
repository:proofs/cbmc/proof_guide.md:248:       invariant(forall(j, 0, i, dst[j] == 0))
repository:proofs/cbmc/proof_guide.md:249:       decreases(len - i))
repository:proofs/cbmc/proof_guide.md:261: Note that the invariant `invariant(forall(j, 0, i, dst[j] == 0))` is vacuous at loop entry, where `i == 0` and the
repository:proofs/cbmc/proof_guide.md:404: requires(memory_no_alias(x, sizeof(s));
repository:proofs/cbmc/proof_guide.md:422: `__contract__(...)` in the `.c` file at point of definition. As mentioned before, the pattern is as follows:
repository:proofs/cbmc/proof_guide.md:426: __contract__(
repository:proofs/cbmc/proof_guide.md:427:   requires()
repository:proofs/cbmc/proof_guide.md:428:   assigns()
repository:proofs/cbmc/proof_guide.md:429:   ensures());
repository:proofs/cbmc/proof_guide.md:436: __contract__(
repository:proofs/cbmc/proof_guide.md:437:   requires()
repository:proofs/cbmc/proof_guide.md:438:   assigns()
repository:proofs/cbmc/proof_guide.md:439:   ensures())
repository:proofs/cbmc/proof_guide.md:449: If XXX contains no loop statements, then you might be able to just skip this step. Otherwise, add `__loop__(...)`
repository:proofs/cbmc/proof_guide.md:560: __contract__(
repository:proofs/cbmc/proof_guide.md:561:   requires(memory_no_alias(a, sizeof(mlk_poly)))
repository:proofs/cbmc/proof_guide.md:562:   requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
repository:proofs/cbmc/proof_guide.md:563:   assigns(object_whole(r)));
repository:proofs/cbmc/proof_guide.md:589:   __loop__(
repository:proofs/cbmc/proof_guide.md:590:     assigns(i, object_whole(r))
repository:proofs/cbmc/proof_guide.md:591:     invariant(i <= MLKEM_N / 2)
repository:proofs/cbmc/proof_guide.md:592:     decreases(MLKEM_N / 2 - i))
repository:test/bench/bench_components_mlkem.c:166:   /* mlk_poly_add */
repository:test/bench/bench_components_mlkem.c:167:   BENCH("mlk_poly_add", mlk_poly_add((mlk_poly *)data0, (mlk_poly *)data1))
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:2:  * Clean-room, FIPS-domain, relational CBMC harness for mlk_poly_add
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:11:  *   - does not require or invoke an existing mlk_poly_add harness;
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:68:   __CPROVER_assert(MLKEM_N == 256,
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:70:   __CPROVER_assert(MLKEM_Q == 3329,
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:86:     __CPROVER_assume(a.coeffs[i] >= 0);
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:87:     __CPROVER_assume(a.coeffs[i] < MLKEM_Q);
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:89:     __CPROVER_assume(b.coeffs[i] >= 0);
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:90:     __CPROVER_assume(b.coeffs[i] < MLKEM_Q);
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:114:   mlk_poly_add(&sum_ab, &b);
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:115:   mlk_poly_add(&sum_ba, &a);
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:116:   mlk_poly_add(&identity_result, &zero);
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:128:     __CPROVER_assert(
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:135:     __CPROVER_assert(
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:139:     __CPROVER_assert(
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:147:      * mlk_poly_add intentionally need not reduce its stored coefficient.
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:150:     __CPROVER_assert(
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:158:     __CPROVER_assert(
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:162:     __CPROVER_assert(
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:166:     __CPROVER_assert(
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:173:     __CPROVER_assert(
authored:cleanroom_mlk_poly_add_fips_relational_harness_v2.c:180:     __CPROVER_assert(
authored:run_cleanroom_mlk_poly_add_cbmc_v2.sh:3: # Build and verify the independently authored mlk_poly_add harness.
authored:run_cleanroom_mlk_poly_add_cbmc_v2.sh:74: # This keeps the repository's embedded __contract__ and __loop__ annotations
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:3:  *         for mlk_poly_add
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:11:  *   Verify the portable C mlk_poly_add implementation for every pair of
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:96:   __CPROVER_assert(MLKEM_N == 256,
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:98:   __CPROVER_assert(MLKEM_Q == 3329,
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:100:   __CPROVER_assert(INT16_MIN == -32768,
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:102:   __CPROVER_assert(INT16_MAX == 32767,
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:124:     __CPROVER_assume(mathematical_sum >= (int32_t)INT16_MIN);
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:125:     __CPROVER_assume(mathematical_sum <= (int32_t)INT16_MAX);
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:141:   __CPROVER_assert(&sum_ab != &b,
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:143:   __CPROVER_assert(&sum_ba != &a,
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:145:   __CPROVER_assert(&identity_result != &zero,
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:148:   mlk_poly_add(&sum_ab, &b);
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:149:   mlk_poly_add(&sum_ba, &a);
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:150:   mlk_poly_add(&identity_result, &zero);
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:169:     __CPROVER_assert(
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:177:     __CPROVER_assert(
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:185:     __CPROVER_assert(
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:192:     __CPROVER_assert(
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:196:     __CPROVER_assert(
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:200:     __CPROVER_assert(
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:207:     __CPROVER_assert(
authored:pa02_mlk_poly_add_full_signed_contract_valid_harness.c:214:     __CPROVER_assert(
authored:run_pa02_mlk_poly_add_full_signed_cbmc.sh:4: # Verify mlk_poly_add over the complete signed/non-canonical
authored:pa03_mlk_poly_add_unrestricted_negative_control_harness.c:3:  *         for mlk_poly_add
authored:pa03_mlk_poly_add_unrestricted_negative_control_harness.c:54:   __CPROVER_assert(
authored:pa03_mlk_poly_add_unrestricted_negative_control_harness.c:58:   __CPROVER_assert(
authored:pa03_mlk_poly_add_unrestricted_negative_control_harness.c:62:   __CPROVER_assert(
authored:pa03_mlk_poly_add_unrestricted_negative_control_harness.c:66:   __CPROVER_assert(
authored:pa03_mlk_poly_add_unrestricted_negative_control_harness.c:95:   __CPROVER_assert(
authored:pa03_mlk_poly_add_unrestricted_negative_control_harness.c:102:   mlk_poly_add(&result, &b);
authored:pa03_mlk_poly_add_unrestricted_negative_control_harness.c:120:     __CPROVER_assert(
authored:pa03_mlk_poly_add_unrestricted_negative_control_harness.c:129:     __CPROVER_assert(
authored:run_pa03_mlk_poly_add_unrestricted_negative_control.sh:4: # Unrestricted signed-domain negative control for mlk_poly_add.
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:2:  * PA-04A: Safe-domain aliasing diagnostic for mlk_poly_add
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:55:   __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:59:   __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:63:   __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:67:   __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:84:     __CPROVER_assume(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:87:     __CPROVER_assume(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:97:    *   mlk_poly_add(&a, &a)
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:108:   __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:112:   mlk_poly_add(r_alias, b_alias);
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:114:   __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:118:   mlk_poly_add(&disjoint_accumulator, &disjoint_operand);
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:136:     __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:140:     __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:144:     __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:148:     __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:152:     __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:157:     __CPROVER_assert(
authored:pa04a_mlk_poly_add_alias_safe_doubling_harness.c:161:     __CPROVER_assert(
authored:pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c:2:  * PA-04B: Unrestricted aliasing negative control for mlk_poly_add
authored:pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c:42:   __CPROVER_assert(
authored:pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c:46:   __CPROVER_assert(
authored:pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c:50:   __CPROVER_assert(
authored:pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c:54:   __CPROVER_assert(
authored:pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c:72:   __CPROVER_assert(
authored:pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c:76:   mlk_poly_add(r_alias, b_alias);
authored:pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c:88:     __CPROVER_assert(
authored:run_pa04_mlk_poly_add_aliasing_campaign.sh:3: # PA-04 combined aliasing campaign for mlk_poly_add.
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:2:  * PA-05A: Production caller verification for the mlk_poly_add call inside
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:7:  *   mlk_poly_add arithmetic and object-separation obligations for every
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:12:  * which in turn directly calls the production mlk_poly_add implementation.
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:40:   __CPROVER_assert(
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:44:   __CPROVER_assert(
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:48:   __CPROVER_assert(
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:52:   __CPROVER_assert(
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:62:     __CPROVER_assert(
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:64:         "PA05A_COMPONENT_SEPARATION: each nested mlk_poly_add call uses distinct polynomials");
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:75:       __CPROVER_assume(
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:78:       __CPROVER_assume(
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:88:    * mlk_poly_add once for every vector component.
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:100:       __CPROVER_assert(
authored:pa05a_mlk_poly_add_polyvec_production_callsite_harness.c:104:       __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:3:  *         mlk_poly_add(v, epp) in mlkem/src/indcpa.c.
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:8:  *   sum is representable in int16_t and that production mlk_poly_add is safe
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:59:   __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:63:   __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:67:   __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:71:   __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:75:   __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:87:     __CPROVER_assume(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:89:     __CPROVER_assume(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:95:     __CPROVER_assume(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:97:     __CPROVER_assume(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:107:     __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:111:     __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:122:   mlk_poly_add(&v, &epp);
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:130:     __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:134:     __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:138:     __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:143:     __CPROVER_assert(
authored:pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c:148:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:4:  *         mlk_poly_add(v, epp);
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:5:  *         mlk_poly_add(v, k);
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:78:   __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:82:   __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:86:   __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:90:   __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:94:   __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:98:   __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:102:   __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:106:   __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:120:     __CPROVER_assume(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:122:     __CPROVER_assume(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:125:     __CPROVER_assume(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:127:     __CPROVER_assume(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:144:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:157:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:161:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:172:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:176:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:188:   mlk_poly_add(&v, &epp);
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:196:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:201:   mlk_poly_add(&v, &k);
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:210:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:214:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:218:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:222:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:227:     __CPROVER_assert(
authored:pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c:234:     __CPROVER_assert(
authored:run_pa05_mlk_poly_add_production_callsites.sh:3: # PA-05 combined production call-site campaign for mlk_poly_add.
authored:run_pa05_mlk_poly_add_production_callsites.sh:9: #   First indcpa encryption call: mlk_poly_add(v, epp).
authored:run_pa05_mlk_poly_add_production_callsites.sh:13: #       mlk_poly_add(v, epp);
authored:run_pa05_mlk_poly_add_production_callsites.sh:14: #       mlk_poly_add(v, k);
authored:run_pa05_mlk_poly_add_production_callsites.sh:296:   echo "All three production mlk_poly_add call-site obligations were verified."
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:3:  *         mlk_poly_add calls inside mlk_polyvec_add.
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:11:  * directly invokes production mlk_poly_add for each vector component.
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:38:   __CPROVER_assert(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:42:   __CPROVER_assert(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:47:   __CPROVER_assert(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:51:   __CPROVER_assert(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:55:   __CPROVER_assert(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:62:   __CPROVER_assert(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:72:     __CPROVER_assert(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:85:       __CPROVER_assume(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:88:       __CPROVER_assume(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:109:       __CPROVER_assert(
authored:pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c:113:       __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:3:  *         mlk_poly_add(v, epp) in mlk_indcpa_enc.
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:12:  * The production mlk_poly_add body is executed directly.
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:51:   __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:55:   __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:59:   __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:63:   __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:68:   __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:72:   __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:76:   __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:83:   __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:92:     __CPROVER_assume(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:94:     __CPROVER_assume(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:97:     __CPROVER_assume(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:99:     __CPROVER_assume(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:106:     __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:110:     __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:118:   mlk_poly_add(&v, &epp);
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:126:     __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:130:     __CPROVER_assert(
authored:pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c:134:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:4:  *         mlk_poly_add(v, epp);
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:5:  *         mlk_poly_add(v, k);
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:69:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:73:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:77:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:81:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:85:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:90:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:94:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:98:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:105:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:109:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:113:   __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:127:     __CPROVER_assume(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:129:     __CPROVER_assume(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:132:     __CPROVER_assume(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:134:     __CPROVER_assume(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:147:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:156:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:160:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:168:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:172:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:181:   mlk_poly_add(&v, &epp);
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:189:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:194:   mlk_poly_add(&v, &k);
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:203:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:207:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:211:     __CPROVER_assert(
authored:pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c:215:     __CPROVER_assert(
authored:run_pa06_mlk_poly_add_cross_parameter_campaign.sh:3: # PA-06: Cross-parameter replication campaign for mlk_poly_add.
authored:pa07_mlk_poly_add_mutant_implementation.c:2:  * PA-07 controlled mutant implementations for mlk_poly_add.
authored:pa07_mlk_poly_add_mutant_implementation.c:33: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
authored:run_pa07_mlk_poly_add_mutation_sensitivity.sh:3: # PA-07: Mutation-sensitivity campaign for the frozen mlk_poly_add harnesses.
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:3:  *         the production mlk_poly_add implementation.
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:60:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:64:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:68:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:72:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:76:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:80:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:110:       __CPROVER_assume(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:112:       __CPROVER_assume(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:115:       __CPROVER_assume(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:117:       __CPROVER_assume(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:161:       __CPROVER_assume(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:163:       __CPROVER_assume(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:175:   mlk_poly_add(&canonical_r, &canonical_b);
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:179:   mlk_poly_add(&signed_r, &signed_b);
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:182:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:186:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:196:     __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:200:     __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:204:     __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:210:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:214:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:225:     __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:229:     __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:233:     __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:239:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:243:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:247:   __CPROVER_assert(
authored:pa08a_mlk_poly_add_boundary_hardening_harness.c:251:   __CPROVER_assert(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:2:  * PA-08B: Expected-failure reachability sentinel for mlk_poly_add.
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:7:  *   mlk_poly_add.
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:45:   __CPROVER_assert(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:49:   __CPROVER_assert(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:58:     __CPROVER_assume(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:60:     __CPROVER_assume(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:63:     __CPROVER_assume(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:65:     __CPROVER_assume(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:69:   mlk_poly_add(&canonical_r, &canonical_b);
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:75:   __CPROVER_assert(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:88:     __CPROVER_assume(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:90:     __CPROVER_assume(
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:94:   mlk_poly_add(&signed_r, &signed_b);
authored:pa08b_mlk_poly_add_reachability_sentinel_harness.c:100:   __CPROVER_assert(
authored:pa08c_mlk_poly_add_upper_outside_boundary_harness.c:47:   __CPROVER_assert(
authored:pa08c_mlk_poly_add_upper_outside_boundary_harness.c:51:   mlk_poly_add(&r, &b);
authored:pa08c_mlk_poly_add_upper_outside_boundary_harness.c:57:   __CPROVER_assert(
authored:pa08c_mlk_poly_add_upper_outside_boundary_harness.c:61:   __CPROVER_assert(
authored:pa08d_mlk_poly_add_lower_outside_boundary_harness.c:47:   __CPROVER_assert(
authored:pa08d_mlk_poly_add_lower_outside_boundary_harness.c:51:   mlk_poly_add(&r, &b);
authored:pa08d_mlk_poly_add_lower_outside_boundary_harness.c:57:   __CPROVER_assert(
authored:pa08d_mlk_poly_add_lower_outside_boundary_harness.c:61:   __CPROVER_assert(
authored:run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh:4: #        hardening campaign for mlk_poly_add.
```

## 9. Required Semantic Audit Questions

1. What does the original repository harness contain, and what does it delegate to source contracts?
2. Which assumptions and postconditions are shared because both artefacts target the same function contract?
3. Which PA properties are direct restatements or refinements of the repository contract?
4. Which PA properties are absent from the original harness and source contract?
5. Are the negative controls, alias diagnostics, caller proofs, cross-parameter runs, mutation campaign, and anti-vacuity sentinels structurally original additions?
6. Is any assertion wording, helper implementation, control-flow layout, or harness scaffolding copied verbatim?
7. Which overlap is inevitable or source-contract-derived rather than evidence of copying?
8. What claim is supportable: exact uniqueness, independent authorship, original-harness blindness, or source-contract-informed extension?

## 10. Frozen Repository Artefact Contents

### `REFERENCE.md`

```markdown
[//]: # (SPDX-License-Identifier: CC-BY-4.0)

Relation to reference implementation
====================================

mlkem-native is a fork of the ML-KEM reference implementation[^REF].

The following gives an overview of the major changes:

- CBMC and debug annotations, and minor code restructurings or signature changes to facilitate the CBMC proofs. For example, `poly_add(x,a)` only comes in a destructive variant to avoid specifying aliasing constraints; `poly_rej_uniform` has an additional `offset` parameter indicating the position in the sampling buffer, to avoid passing shifted pointers).
- Introduction of 4x-batched versions of some functions from the reference implementation. This is to leverage 4x-batched Keccak-f1600 implementations if present. The batching happens at the C level even if no native backend for FIPS 202 is present.
- FIPS 203 compliance: Introduced PK (FIPS 203, Section 7.2, 'modulus check') and SK (FIPS 203, Section 7.3, 'hash check') check, as well as optional PCT (FIPS 203, Section 7.1, Pairwise Consistency). Also, introduced zeroization of stack buffers as required by (FIPS 203, Section 3.3, Destruction of intermediate values).
- Introduction of native backend implementations. With the exception of the native backend for `poly_rej_uniform()`, which may fail and fall back to the C implementation, those are drop-in replacements for the corresponding C functions and dispatched at compile-time.
- Restructuring of files to separate level-specific from level-generic functionality. This is needed to enable a multi-level build of mlkem-native where level-generic code is shared between levels.
- More pervasive use of value barriers to harden constant-time primitives, even when Link-Time-Optimization (LTO) is enabled. The use of LTO can lead to insecure compilation in case of the reference implementation.
- Use of a multiplication cache ('mulcache') structure to simplify and speedup the base multiplication.
- Different placement of modular reductions: We reduce to _unsigned_ canonical representatives in `poly_reduce()`, and _assume_ such in all polynomial compression functions. The reference implementation works with a _signed_ `poly_reduce()`, and embeds various signed->unsigned conversions in the compression functions.
- More inlining: Modular multiplication and primitives are in a header rather than a separate compilation unit.

For details, please see the source code: Functions in the mlkem-native source tree are annotated with `/* Reference: ... */` comments to outline how they relate to the reference implementation.

<!--- bibliography --->
[^REF]: Bos, Ducas, Kiltz, Lepoint, Lyubashevsky, Schanck, Schwabe, Seiler, Stehlé: CRYSTALS-Kyber C reference implementation, [https://github.com/pq-crystals/kyber/tree/main/ref](https://github.com/pq-crystals/kyber/tree/main/ref)
```

### `SOUNDNESS.md`

````markdown
[//]: # (SPDX-License-Identifier: CC-BY-4.0)

# Formal Verification in mlkem-native: Scope, Assumptions, Risks

This document describes the scope, assumptions and risks of the formal verification
efforts around mlkem-native.

The parts of the analysis pertaining to HOL Light and s2n-bignum are largely shared with
the corresponding s2n-bignum soundness document[^s2n-bignum-soundness].

We see this as a living document. If you have suggestions for improvements, such as soundness risks
missing from or insufficiently covered in this document, please reach out to us or open an issue.
However, if you find a potential security vulnerability in mlkem-native, do **not** open
a public GitHub issue, but instead use [private vulnerability reporting](https://github.com/pq-code-package/mlkem-native/security).

## Overview

Formal verification is never absolute. Every verification effort links formal objects --
specifications and models -- to informal, real-world requirements and systems. This document
maps out what is proved about mlkem-native, what is assumed, and where the gaps and risks lie.

Our goal is to provide evidence rooted in formal reasoning for the statement that
"mlkem-native implements the FIPS203 standard[^FIPS203] and does not leak secrets through timing variations".

The narrative for the argument is the following, which is common in formal verification:
- [Informal] Here is the real physical system, in all its complexity.
- [Formal] Here is a formal model of the real system which we believe approximates its behavior.
- [Formal] Here is how we can formally specify the behavior of this formal model.
- [Formal] Here is how we formally prove the formal specification.
- [Informal] Here is why we think this approximates the desired properties of the real system.

Diagrammatically, this can be depicted as follows:

```

                                                  "Here is how we can formally specify
                                                   the behavior of mlkem-native w.r.t.
                                                   the machine's formal model."

         Informal                                              Formal
  ┌─────────────────────┐                             ┌─────────────────────────┐
  │                     │            Gap A            │                         │
  │  Desired behavior   │<· · · · · · · · · · · · · ·>│   Formal specification  │
  │  of actual system   │   Is this what we wanted?   │                         │
  │                     │                             │                         │
  └─────────────────────┘                             └────────────▲────────────┘
           ^                                                       │
           :                                    Is the argument    │
           :                                    sound?             │  "Here is how we formally
           : GOAL                                                  │   prove mlkem-native's
           :                                         Gap C: prover │   formal specification."
           :                                         trust (TCB)   │
           v                                                       │
  ┌─────────────────────┐                             ┌────────────┴────────────┐
  │                     │            Gap B            │                         │
  │  Actual system      │<· · · · · · · · · · · · · ·>│     Formal model of     │
  │                     │   Is this how the system    │     system and code     │
  │  Code running on    │   behaves?                  │  Code representation +  │
  │  real hardware      │                             │  execution semantics    │
  └─────────────────────┘                             └─────────────────────────┘

  "Here's the real system."                           "Here's how we think it can
                                                       be formally approximated."

```

This methodology introduces three fundamental soundness gaps:
- Gap A: Does the formal specification capture what we want to say about the real system?
- Gap B: Is the formal model a faithful reflection of the real system?
- Gap C: Is the formal argument trustworthy for why the formal model satisfies its specification?

For mlkem-native, this structure is instantiated twice -- once for each verification
stack.

- **CBMC[^CBMC]** for the C code: memory safety, type safety, and absence of undefined behavior.
- **HOL-Light[^HOL-Light] + s2n-bignum[^s2n-bignum]** for the assembly backends: functional correctness, memory safety, and secret-independent
  execution.

```
         Informal                            Formal
  ┌─────────────────────┐          ┌──────────────────────────┐
  │                     │          │                          │
  │  ML-KEM spec        │          │  CBMC          HOL Light │
  │  (FIPS 203),        │          │  contracts     specs     │
  │  constant-time      │   Gap A  │  (C funcs)      (ASM)    │
  │  requirements,      │<· · · · >│     :             :      │
  │  ABI, ...           │          │     :             :      │
  │                     │          │     :             :      │
  │                     │          │     :             :      │
  └─────────────────────┘          └─────▲─────────────▲──────┘
                                         │             │
                                   Gap C │        Gap C│
                                         │             │
                                   CBMC +│      HOL Light kernel
                             SMT solvers │             │
                                         │             │
  ┌─────────────────────┐          ┌─────┴─────────────┴─────┐
  │                     │          │                         │
  │  Compiled binary    │          │                         │
  │  on real hardware   │   Gap B  │  CBMC's C      ISA      │
  │                     │<· · · · >│  semantics    model     │
  │  (+ CPU errata,     │          │  model      (arm.ml/    │
  │   physical faults,  │          │             x86.ml)     │
  │   reassembly risk)  │          │                         │
  └─────────────────────┘          └─────────────────────────┘
```

---

## Gap A: Do the formal specifications match actual requirements?

This is the gap between what we *specify* and what users and applications actually *need*.
It has multiple facets, including: Whether all system components are covered by specification (breadth),
whether the specifications are strong enough (depth), whether they faithfully capture the informal requirements
(faithfulness), and whether they compose to a claim about the whole system (consistency).

### A1. Coverage: Breadth

Which components of the system are captured by formal specification? The primary risk is
that our coverage claims are wrong -- that a C or assembly function slips through without
a specification, or that an unspecified component is incorrect.

**What is covered.**

- All C code in the core library has CBMC contracts.
- All AArch64 assembly routines have HOL Light specifications.
- All x86_64 assembly routines have HOL Light specifications.

**What is NOT covered.**

- **Backends for platforms other than AArch64 and x86_64** (e.g. RISC-V RVV, Armv8.1-M MVE, PowerPC):
  Where present, these are not yet covered by specification.

The full test suite (functional tests, KAT, ACVP, Wycheproof[^wycheproof], unit tests) validates functional
correctness empirically across all platforms and configurations, but there is currently
no automatic coverage check for CBMC or HOL Light. A function or configuration could slip
through without being covered by specification.

**Potential improvements.**
- Add automatic proof coverage check to CI. ([#1423](https://github.com/pq-code-package/mlkem-native/issues/1423), [#1594](https://github.com/pq-code-package/mlkem-native/issues/1594))
- Add verification coverage for all backends, using existing or new methodologies ([#1595](https://github.com/pq-code-package/mlkem-native/issues/1595)).

### A2. Coverage: Depth

Do the specifications have the desired depth? The risk is that undesired behavior occurs
which is outside the scope of specification.

We aim for mlkem-native to be **functionally correct** (the code computes the
right answer as per FIPS 203), **memory-safe** (it only accesses memory within
the bounds of what is provided or allocated) and **constant-time** (no
secret-dependent timing variation).

**Assembly (HOL Light).** All ASM specification capture functional correctness, memory safety,
and secret-independent execution. A special case is rejection sampling: Its assembly implementations
are safely variable-time as they operate on public data only, so they only require correctness
and safety specifications.

**C code (CBMC).** Our use of CBMC focuses on **memory safety and type safety** -- absence
of undefined behavior including out-of-bounds access, integer overflow, null pointer
dereference, division by zero, undefined shifts, and lossy type conversions. The proofs
also capture limited aspects of functional behavior in simple cases -- for example,
coefficient bounds after arithmetic operations, or the functional specification of
`mlk_ct_memcmp`. See [`proofs/cbmc/Makefile.common`](proofs/cbmc/Makefile.common) for the
full list of checked classes of undefined behavior.

The CBMC proofs do **not** currently cover:

- **Functional correctness.** There is no machine-checked proof that the C code computes
  the right answer per FIPS 203.
- **Constant-time execution.** Side-channel resistance at the C level is not formally
  proved.

These gaps are mitigated in complementary ways. The full test suite (functional tests, KAT,
ACVP, Wycheproof, unit tests) validates functional correctness empirically across all platforms and
configurations. For arithmetic correctness specifically, the most subtle bugs in ML-KEM
implementations are rare overflows in the optimized polynomial arithmetic -- precisely the
kind of bug that the type-safety and integer-overflow proofs are designed to catch: the CBMC
contracts track coefficient bounds through the arithmetic pipeline, and overflow in
intermediate computations would be flagged as undefined behavior. Constant-time properties
are tested empirically using valgrind across many compilers and optimization levels (see
the corresponding [CI job](.github/workflows/ct-tests.yml) for
the full list), and the C code uses value barriers to prevent harmful compiler optimizations.

**Potential improvements.**
- Add automatic extraction of compiler coverage documentation from CI. ([#1608](https://github.com/pq-code-package/mlkem-native/issues/1608))
- Introduce additional verification tooling that allows us to express functional correctness
  and constant-time properties for the C code. ([#1597](https://github.com/pq-code-package/mlkem-native/issues/1597), [#1598](https://github.com/pq-code-package/mlkem-native/issues/1598))

### A3. Specification faithfulness

For the specifications that do exist, does their formal meaning capture their intent? The
risk is that a specification does not express what we informally intend it to express.

**Correctness.** The informal intent is to express that the top-level
API behaves as specified by NIST's ML-KEM standard FIPS 203. As we do not yet address
functional correctness at the C level, there is no formal specification of ML-KEM as a
whole in mlkem-native. In our current setting -- capturing functional behavior only at the
assembly level -- faithfulness requires that the HOL Light correctness specification style
faithfully captures program behavior, and that the abstract HOL functions used in the
specifications (e.g., the Number Theoretic Transform) are faithful representations of the
mathematical functions in the standard.

**Constant-time.** The informal intent is that mlkem-native does not
leak secrets through timing side channels. Since we only capture constant-time properties
at the assembly level, faithfulness requires that the HOL Light constant-time specification
style faithfully captures constant-time execution.

The s2n-bignum formal model approximates constant-time'ness as follows: It introduces the
notion of *microarchitectural events* that flags selected instructions that are known to exhibit variable timing or
influence timing otherwise (e.g., through caches): Examples are branches, load/store instructions, or variable-time
instructions such as divisions. The constant-time specifications then posit that the trace of microarchitectural events
emitted by a program can be expressed as a function of public variables such as input/output pointers or pointers
to constant tables. Conversely, and somewhat implicitly, the absence of the (typically secret)
_data_ behind those pointers as a parameter to the event-generating function implies that there
is are no secret-dependent branches, load/stores, etc. It is the responsibility of the proof-writer
to identify what is meant to be public vs. secret, and parametrize the event-generating function
accordingly.

The formal notion of constant-time'ness used in s2n-bignum does not and cannot guarantee
that the hardware executes those instructions in constant time: Unmodeled microarchitectural
effects such as speculative execution or Hertzbleed-style frequency scaling can still leak information.
Moreover, some hardware provides opt-in guarantees for a listed set of instructions -- Arm's DIT (Data Independent
Timing, Armv8.4-A onwards) and Intel's DOIT (Data Operand Independent Timing, Ice Lake onwards). We do not yet claim
full alignment between the set of instructions marked as event-generating in s2n-bignum and the set of instructions
outside of the scope of DIT/DOIT. Finally, our notion of microarchitectural event is grounded in timing as the
observable -- power and frequency-based side channels are out of scope.

**Safety.** For the bulk of the CBMC specifications which do not capture
functional correctness, memory- and type-safety are implicit in the CBMC configuration
and not explicitly stated in the CBMC contracts. Additional clauses in the CBMC contracts
(such as memory assumptions and footprint) need not be human-validated except for the top-level
API, since their adequacy is judged by the machine-checked compositionality against their
call-sites. The fidelity of CBMC specifications therefore reduces to whether the top-level
CBMC specifications capture the footprint and assumptions of the top-level FIPS 203 API,
and whether CBMC is correctly configured to include memory- and type-safety implicitly in
each function contract.

All specifications are written in a high-level mathematical style (HOL Light) or a simple
declarative style using auditable macros (CBMC), both far simpler than the implementations.
The approach to Hoare-style correctness specifications in HOL Light has been carefully audited
and is extensively used for numerous other assembly kernels in s2n-bignum, without infidelities
being detected. For CBMC, modular proof means that an insufficient specification on a callee will
cause the caller's proof to fail. Top-level CBMC specifications are straightforward as their inputs
and outputs are merely byte buffers of standardized lengths; all these buffer length values are
defined in [params.h](mlkem/src/params.h) and easily auditable to align with FIPS 203.

Residual risks remain: The constant-time specification style in HOL Light/s2n-bignum could
fail to detect a practically relevant class of variable-time execution. A supposedly constant-time
specification could erroneously include secret data as a parameter to the event-generating function.
A misconfiguration of CBMC could cause the implicit expectation of memory- and type-safety being
included in the CBMC specifications not to hold. Or, a CBMC proof could incorrectly disable a safety
check.

**Potential improvements.**
- Derive the CBMC configuration from a machine- and human-readable source documenting
  the desired configuration options and their
  meaning. ([#1599](https://github.com/pq-code-package/mlkem-native/issues/1599))
- Align the notion of event-generating instruction in s2n-bignum with the set of instructions
  outside of the scope of DIT/DOIT ([s2n-bignum/#361](https://github.com/awslabs/s2n-bignum/issues/361)).
- Highlight the notion of public vs. secret data more explicitly in the s2n-bignum constant-time
  specifications, rather than implicitly in the list of parameters to the event-generating function ([s2n-bignum/#362](https://github.com/awslabs/s2n-bignum/issues/362)).
- Provide a document which explains the specification style for correctness and constant-time
  properties in HOL Light. ([#1600](https://github.com/pq-code-package/mlkem-native/issues/1600))

### A4. Specification consistency

Do the individual specifications compose to a coherent claim about the whole system? The
risks are that a contract assumed during proof differs from the contract that is proved,
that a contract assumed during proof is never proved, or that the bridge between the
CBMC and HOL Light verification stacks introduces an inconsistency.

#### CBMC compositionality

When CBMC proves a function F using the contract of a callee G (via `USE_FUNCTION_CONTRACTS`),
it assumes G's contract as an axiom. The contract it assumes must be the same contract that
is proved for G in G's own proof. In mlkem-native, this is enforced structurally: each
function has a single contract written at its declaration site, and CBMC uses that same
contract both when proving the function and when assuming it as a callee. There is no
mechanism by which the "assumed" and "proved" versions can diverge.

This structural guarantee is reinforced by the
[check-contracts](scripts/check-contracts) script, which looks for CBMC functions with a
contract but no proof. Additionally, bounds assertions in CBMC specifications are mirrored
by runtime debug assertions at the beginning and end of the respective function, so that if a
function is not covered by CBMC -- erroneously or deliberately -- tests in debug mode can
still catch gross mismatches between what the caller provides/assumes and what the callee
assumes/provides.

Residual risks remain: a function's proof could be present but not run in CI (e.g., due to
a CI configuration error), or a function's proof could be absent but
[check-contracts](scripts/check-contracts) could fail to detect it due to a bug or
misconfiguration.

#### The bridge between CBMC and HOL Light

Where C code calls into assembly, the assembly function has both a HOL Light specification
(proved against the object code) and a CBMC contract (assumed by CBMC when proving the C
caller). These two specifications are written in different languages and are currently
kept in sync by hand. Failure to do so may invalidate the safety and correctness claims
for mlkem-native.

For each assembly function, the CBMC specification is typically a subset of the HOL Light
specification obtained by removing aspects of functional correctness -- which, as discussed
above, are not yet covered in CBMC. What remains are statements about memory footprint,
arithmetic bounds, and constant tables.

**Example.** For the AArch64 NTT:

- HOL Light proves: If the input coefficients satisfy `abs(ival(x i)) <= &8191`, then the output
  satisfies `abs(ival zi) <= &23594` and `(ival zi == forward_ntt (ival o x) i) (mod &3329)`.
  In other words, we provide a description of the underlying modular arithmetic function (here, the NTT),
  plus a bound on the concrete being computed.
- The CBMC contract on `mlk_ntt_aarch64_asm` simplifies this to the mere bounds assertions
  `requires(array_abs_bound(p, 0, MLKEM_N, 8192))`
  and `ensures(array_abs_bound(p, 0, MLKEM_N, 23595))`, omitting the description of the
  functional behavior.
- HOL Light assumes that auxiliary arguments point to pre-computed constant tables for
  the NTT: `C_ARGUMENTS [a; z_12345; z_67] s /\ ntt_constants z_12345 z_67 s`. CBMC similarly
  assumes `requires(twiddles12345 == mlk_aarch64_ntt_zetas_layer12345)` and `requires(twiddles56 ==
  mlk_aarch64_ntt_zetas_layer67)` for the C arguments used for the constant tables.

**Mitigations.**
Both the HOL Light proofs and the CBMC contracts contain comments of the form
`/* This must be kept in sync with the HOL Light specification in ... */`
(or vice versa) to flag the manual dependency and provide a review checkpoint.
Moreover, constant tables used in the HOL Light and C code are auto-generated from the same code
in [`scripts/autogen`](scripts/autogen). This code is run as part of CI and thereby establishes that
constant tables remain in sync.
The full test suite exercises the native backend code paths, catching
gross mismatches. Furthermore, CBMC proves the C wrapper correct *assuming* the assembly
contract, so an inconsistency between the wrapper's precondition and the assembly's
precondition would typically cause the wrapper proof to fail.

Despite these safeguards, residual risks remain. A transcription error could cause the CBMC
contract on the assembly function to fail to faithfully reflect the HOL Light specification
-- e.g., an off-by-one in a bound, a missing aliasing constraint, or a wrong constant. An
ABI mismatch could cause the C calling convention assumed by the CBMC contract to differ
from the actual register/stack layout used by the assembly. And a semantic gap between the
CBMC contract language and HOL Light's logic -- for example, differing signed vs. unsigned
interpretation of bounds -- could cause the bridge to be unsound.

**Potential improvements.**
- Establish a machine-checked link between the HOL Light specifications and the CBMC
  contracts. ([#1601](https://github.com/pq-code-package/mlkem-native/issues/1601))

---

## Gap B: Do the formal models match the actual systems?

### B1. ISA model fidelity (assembly)

The HOL Light ISA models (`arm.ml`, `x86.ml`) and their decoders (`decode.ml`) are
hand-written from the ARM and Intel architecture reference manuals. Errors in those
references, misunderstandings, or transcription mistakes could silently invalidate proofs.

**Mitigation: co-simulation testing.** s2n-bignum's CI includes a co-simulation test
(`simulator.ml` + `simulator.c`) that repeatedly picks random instruction encodings and
random register/flag states, decodes them, executes them both symbolically through the
formal model and natively on real hardware, and compares results. This exercises both the
ISA semantics and the decoder. It covers all register-to-register instruction forms with
randomized operands, as well as memory-accessing instructions via dedicated
harnesses for various addressing modes.

Where instructions have genuinely underspecified behavior -- for example, `IMUL` sets flags
differently on different x86 microarchitectures -- the s2n-bignum model reflects this
nondeterminism, and proofs are valid regardless of which behavior the hardware exhibits.

mlkem-native does not run co-simulation testing itself; it relies on s2n-bignum's CI to
validate the ISA models. Since mlkem-native uses the same ISA models and decoder as
s2n-bignum (via the shared HOL Light infrastructure), this is appropriate -- but it means
that mlkem-native's assurance for ISA model fidelity is inherited, not independently
established.

See the s2n-bignum soundness doc [^s2n-bignum-soundness] for full details.

### B2. Object code verification and reassembly (assembly)

The HOL Light proofs work at the level of object-code byte sequences, not the assembly source.
This takes the assembler out of the TCB of the proof. However, two risks remain.

**ELF loader.** An OCaml ELF loader extracts the `.text` section (and, where applicable,
the `.rodata` section) from each object file for verification. If it extracts the wrong
bytes, the proof applies to different code than what runs in production. This risk is
mitigated by the fact that the proof engineer must provide the exact byte sequence to write
the proof, so loader errors would typically cause proof failure rather than a silently
wrong proof. Additionally, function-level random testing compares assembly outputs against
C reference implementations, catching gross mismatches.

See the s2n-bignum soundness doc[^s2n-bignum-soundness] for further details on the ELF loader.

**Reassembly risk.** When mlkem-native's `.S` files are assembled on a different system --
whether by mlkem-native's own build, by a downstream consumer such as AWS-LC, or by a
cross-compilation toolchain -- there is currently no systematic check that the resulting
object code matches the bytes the proofs were verified against.
Assembler bugs, version differences, or different assembler dialects can and
do produce different object code (for example, it has been observed that some x86
assemblers swap operands of AVX2 `VPADD` instruction to reduce code size).

**Potential improvements.**
- Provide a tool to consumers for checking that assembly/compilation results contain
  the expected byte code for all native functions covered by HOL Light proofs.  ([#1602](https://github.com/pq-code-package/mlkem-native/issues/1602))

### B3. Model omissions (assembly)

The formal HOL Light ISA model is a sequential, user-mode, single-core model. It does not model:

- **Caches, TLBs, or memory ordering.** Irrelevant for single-threaded sequential code,
  but means the model says nothing about concurrent use.
- **Interrupts and exceptions.** The proof assumes uninterrupted execution. In practice,
  interrupts are transparent to user-mode code on both x86 and ARM.
- **Virtual memory and page faults.** The model uses a flat address space. Page faults
  are transparent provided the OS has mapped the relevant pages.
- **Speculative execution.** The model is non-speculative. Side-channel risks from
  speculative execution (Spectre-class) are not addressed by the current proofs.
- **System registers and privilege levels.** The model covers user-mode general-purpose
  and SIMD registers only.

These omissions are standard for this class of verification and are not expected to affect
functional correctness of sequential user-mode code.

See the s2n-bignum soundness doc [^s2n-bignum-soundness] for further discussion.

### B4. Hardware not implementing the ISA

The formal proofs assume that the physical hardware faithfully implements the ISA as
specified in the architecture reference manuals. In reality, this assumption can fail in
multiple ways:

- **CPU errata (systematic bugs).** CPUs can have bugs. Vendors published errata lists documenting
  cases where specific instructions behave incorrectly under specific conditions. If an mlkem-native
  assembly routine triggers such an erratum, the proof's guarantee does not hold on affected hardware.

- **Transient physical faults.** Cosmic rays, voltage fluctuations, thermal effects, or
  aging can cause transient bit flips in registers, memory, or logic. Such faults can
  silently corrupt computation. ECC memory mitigates memory-level faults but does not
  protect registers or execution logic.

- **Fault injection (deliberate attacks).** An adversary with physical access can
  deliberately induce faults (voltage glitching, EM injection, laser fault injection) to
  corrupt cryptographic computations. This is a well-studied attack vector against
  cryptographic implementations, particularly in embedded and smartcard contexts.

**Mitigations.**
- Co-simulation testing (see above) exercises the actual hardware and would detect systematic
  errata for the specific instructions and operand patterns tested. However, coverage is
  inherently limited by the limited scope of the CI.
- Transient faults and fault injection are entirely outside the scope of the formal model
  and the current proofs. No countermeasures (e.g., redundant computation, fault detection
  checks) are implemented.

**Residual risks.** This is a fundamental limitation shared by all software-level formal
verification: the proofs reason about an idealized machine, not the physical device. For
high-assurance deployments in physically hostile environments, additional countermeasures
at the hardware or protocol level would be needed.

### B5. C semantics model fidelity

CBMC gives meaning to C by translating C source into an internal representation and then into SMT formulas. Bugs in
CBMC's C-to-SMT translation could cause it to miss undefined behavior and to accept incorrect code; this has happened in
the past. However, CBMC is a mature, widely-used tool with an active community and extensive test suite, and
mlkem-native uses the latest CBMC version.

Also, the C language has many conformant implementations. For example, the width of pointer types could be
8/16/32/64-bit (or even larger on capability based architectures). CBMC models types and other implementation-defined
behavior (such as struct padding) following the host system's C compiler. At present, mlkem-native's CBMC proofs are
only run on 64-bit systems, and hence do not transfer to 16-bit or 32-bit systems. To mitigate this, the full functional
test suite (functional tests, KAT, ACVP, Wycheproof, unit tests) is run on a large variety of platforms and C compilers, covering 16-bit, 32-bit, and
64-bit C implementations. Moreover, mlkem-native uses fixed-width integer types (e.g. uint16_t) to reduce the risk of
semantic differences across compilers, and targets the initial C90 revision of C, which is expected to have more mature
compiler support and be less prone to modeling errors than newer language features.

Also, CBMC's memory model uses a flat, object-based representation with practically infinite space for local variables,
that is strictly more abstract than the target platform's memory layout. Concretely, for example, C imposes no limit on
the stack size (there is not even a notion of stack in C), but real systems do -- stack overflows are out of scope of
mlkem-native's CBMC proofs. To address this, mlkem-native's header provides constants for its memory usage that are
tested in CI to be accurate, reducing the risk of out-of-memory conditions such as stack overflows.

Finally, a compiler bug could lead to wrong object code being generated from correct C code, and proofs on outdated C
code could undermine the formal model. To guard against this, mlkem-native's CBMC proofs are run on every CI commit,
providing continuous regression testing and preventing proofs from getting out of date.

**Potential improvements.**
- Run CBMC proofs against 16-bit and 32-bit C compilers. ([#1192](https://github.com/pq-code-package/mlkem-native/issues/1192))

---

## Gap C: Is the proof infrastructure sound?

There is risk that the formal statements made about the formal model are proved,
yet not true, because of an unsoundness in the underlying proof infrastructure.

### C1. HOL Light kernel and OCaml runtime

HOL Light has a small trusted kernel (~400 lines of OCaml) implementing 10 primitive inference rules and 3 axioms. All
proofs are ultimately constructed through this kernel. Higher level infrastructure such as proof automation cannot
compromise soundness as it is built atop the kernel. This is a fundamental design property of the LCF architecture.
No soundness bugs in the kernel have been found since 2003.

HOL Light runs on OCaml, so the OCaml compiler and runtime are also part of the trusted computing base. A compiler or
runtime bug could in principle allow construction of a spurious theorem. This is mitigated by OCaml's maturity and
widespread use.

Independent reassurance can be provided by Candle[^Candle] and HOLTrace [^HOLTrace]. See the s2n-bignum soundness doc[^s2n-bignum-soundness] for full details.

### C2. CBMC & SMT solver trusted computing base

The CBMC trusted computing base is substantially larger than HOL Light's:

- **CBMC itself**: The C frontend, GOTO program transformation, and SMT encoding are all
  part of the TCB. Unlike HOL Light's LCF architecture, there is no small kernel through
  which all results must pass. A bug anywhere in the CBMC pipeline could produce a false
  "verified" result.
- **SMT solvers** (Z3, Bitwuzla): These are complex software systems. A solver bug
  directly compromises soundness. Unlike HOL Light's LCF architecture, where bugs in
  proof automation cannot compromise soundness, a solver bug in CBMC's backend directly
  invalidates the proof.
- **The C compiler used by CBMC**: CBMC uses a C preprocessor and parser; bugs in these
  components could affect the analysis.

**Mitigations.**

- CBMC has been in development for more than 20 years and is widely used in industry (including
  at Amazon for AWS-LC and other projects).
- The SMT solvers are independently developed and extensively tested.
- mlkem-native's proofs are run continuously in CI, providing regression testing.

**Residual risks.** The CBMC TCB is orders of magnitude larger than HOL Light's. There is
no independent proof-checking mechanism analogous to Candle or HOLTrace. The soundness
guarantee for the C proofs is therefore fundamentally weaker than for the assembly proofs.

**Potential improvements**:
- Systematically introduce redundancy by employing more than one SMT solver backend
  for CBMC functions, or use solvers with independently checkable results ([#1603](https://github.com/pq-code-package/mlkem-native/issues/1603)).

<!--- bibliography --->
[^CBMC]: Diffblue, Amazon Web Services: C Bounded Model Checker, [https://github.com/diffblue/cbmc](https://github.com/diffblue/cbmc)
[^Candle]: Oskar Abrahamsson, Magnus O. Myreen, Ramana Kumar, Thomas Sewell: Candle: Formally Verified clone of HOL-Light, [https://cakeml.org/candle/](https://cakeml.org/candle/)
[^FIPS203]: National Institute of Standards and Technology: FIPS 203 Module-Lattice-Based Key-Encapsulation Mechanism Standard, [https://csrc.nist.gov/pubs/fips/203/final](https://csrc.nist.gov/pubs/fips/203/final)
[^HOL-Light]: John Harrison: HOL-Light Theorem Prover, [https://hol-light.github.io/](https://hol-light.github.io/)
[^HOLTrace]: Daniel J. Bernstein: HOLTrace: A collection of tools for processing traces of a HOL Light session, [https://holtrace.cr.yp.to/](https://holtrace.cr.yp.to/)
[^s2n-bignum]: Amazon Web Services: s2n-bignum: Library of formally assembly kernels verified in HOL-Light, [https://github.com/awslabs/s2n-bignum/](https://github.com/awslabs/s2n-bignum/)
[^s2n-bignum-soundness]: Amazon Web Services: s2n-bignum soundness documentation, [https://github.com/awslabs/s2n-bignum/blob/main/SOUNDNESS.md](https://github.com/awslabs/s2n-bignum/blob/main/SOUNDNESS.md)
[^wycheproof]: Community Cryptography Specification Project: Project Wycheproof, [https://github.com/C2SP/wycheproof](https://github.com/C2SP/wycheproof)
````

### `mlkem/mlkem_native.c`

````c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/*
 * WARNING: This file is auto-generated from scripts/autogen
 *          in the mlkem-native repository.
 *          Do not modify it directly.
 */

/******************************************************************************
 *
 * Single compilation unit (SCU) for fixed-level build of mlkem-native
 *
 * This compilation unit bundles together all source files for a build
 * of mlkem-native for a fixed security level (MLKEM-512/768/1024).
 *
 * # API
 *
 * The API exposed by this file is described in mlkem_native.h.
 *
 * # Multi-level build
 *
 * If you want an SCU build of mlkem-native with support for multiple security
 * levels, you need to include this file multiple times, and set
 * MLK_CONFIG_MULTILEVEL_WITH_SHARED and MLK_CONFIG_MULTILEVEL_NO_SHARED
 * appropriately. This is exemplified in examples/monolithic_build_multilevel
 * and examples/monolithic_build_multilevel_native.
 *
 * # Configuration
 *
 * The following options from the mlkem-native configuration are relevant:
 *
 * - MLK_CONFIG_FIPS202_CUSTOM_HEADER
 *   Set this option if you use a custom FIPS202 implementation.
 *
 * - MLK_CONFIG_USE_NATIVE_BACKEND_ARITH
 *   Set this option if you want to include the native arithmetic backends
 *   in your build.
 *
 * - MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202
 *   Set this option if you want to include the native FIPS202 backends
 *   in your build.
 *
 * - MLK_CONFIG_MONOBUILD_KEEP_SHARED_HEADERS
 *   Set this option if you want to keep the directives defined in
 *   level-independent headers. This is needed for a multi-level build.
 */

/* If parts of the mlkem-native source tree are not used,
 * consider reducing this header via `unifdef`.
 *
 * Example:
 * ```bash
 * unifdef -UMLK_CONFIG_USE_NATIVE_BACKEND_ARITH mlkem_native.c
 * ```
 */

#include "src/common.h"

#include "src/compress.c"
#include "src/debug.c"
#include "src/indcpa.c"
#include "src/kem.c"
#include "src/poly.c"
#include "src/poly_k.c"
#include "src/sampling.c"
#include "src/verify.c"

#if !defined(MLK_CONFIG_FIPS202_CUSTOM_HEADER)
#include "src/fips202/fips202.c"
#include "src/fips202/fips202x4.c"
#include "src/fips202/keccakf1600.c"
#endif

#if defined(MLK_CONFIG_USE_NATIVE_BACKEND_ARITH)
#if defined(MLK_SYS_AARCH64)
#include "src/native/aarch64/src/aarch64_zetas.c"
#include "src/native/aarch64/src/rej_uniform_table.c"
#endif
#if defined(MLK_SYS_X86_64)
#include "src/native/x86_64/src/compress_consts.c"
#include "src/native/x86_64/src/consts.c"
#include "src/native/x86_64/src/rej_uniform_table.c"
#endif
#if defined(MLK_SYS_RISCV64)
#include "src/native/riscv64/src/rv64v_debug.c"
#include "src/native/riscv64/src/rv64v_poly.c"
#endif
#if defined(MLK_SYS_PPC64LE)
#include "src/native/ppc64le/src/consts.c"
#endif
#endif /* MLK_CONFIG_USE_NATIVE_BACKEND_ARITH */

#if defined(MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202)
#if defined(MLK_SYS_AARCH64)
#include "src/fips202/native/aarch64/src/keccakf1600_round_constants.c"
#endif
#if defined(MLK_SYS_X86_64)
#include "src/fips202/native/x86_64/src/keccakf1600_constants.c"
#endif
#if defined(MLK_SYS_ARMV81M_MVE)
#include "src/fips202/native/armv81m/src/keccak_f1600_x4_mve.c"
#include "src/fips202/native/armv81m/src/keccakf1600_round_constants.c"
#endif
#endif /* MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202 */

/* Macro #undef's
 *
 * The following undefines macros from headers
 * included by the source files imported above.
 *
 * This is to allow building and linking multiple builds
 * of mlkem-native for varying parameter sets through concatenation
 * of this file, as if the files had been compiled separately.
 * If this is not relevant to you, you may remove the following.
 */

/*
 * Undefine macros from MLK_CONFIG_PARAMETER_SET-specific files
 */
/* mlkem/mlkem_native.h */
#undef CRYPTO_BYTES
#undef CRYPTO_CIPHERTEXTBYTES
#undef CRYPTO_PUBLICKEYBYTES
#undef CRYPTO_SECRETKEYBYTES
#undef CRYPTO_SYMBYTES
#undef MLKEM1024_BYTES
#undef MLKEM1024_CIPHERTEXTBYTES
#undef MLKEM1024_PUBLICKEYBYTES
#undef MLKEM1024_SECRETKEYBYTES
#undef MLKEM1024_SYMBYTES
#undef MLKEM512_BYTES
#undef MLKEM512_CIPHERTEXTBYTES
#undef MLKEM512_PUBLICKEYBYTES
#undef MLKEM512_SECRETKEYBYTES
#undef MLKEM512_SYMBYTES
#undef MLKEM768_BYTES
#undef MLKEM768_CIPHERTEXTBYTES
#undef MLKEM768_PUBLICKEYBYTES
#undef MLKEM768_SECRETKEYBYTES
#undef MLKEM768_SYMBYTES
#undef MLKEM_BYTES
#undef MLKEM_CIPHERTEXTBYTES
#undef MLKEM_CIPHERTEXTBYTES_
#undef MLKEM_PUBLICKEYBYTES
#undef MLKEM_PUBLICKEYBYTES_
#undef MLKEM_SECRETKEYBYTES
#undef MLKEM_SECRETKEYBYTES_
#undef MLKEM_SYMBYTES
#undef MLK_API_CONCAT
#undef MLK_API_CONCAT_
#undef MLK_API_CONCAT_UNDERSCORE
#undef MLK_API_LEGACY_CONFIG
#undef MLK_API_MUST_CHECK_RETURN_VALUE
#undef MLK_API_NAMESPACE
#undef MLK_API_QUALIFIER
#undef MLK_CONFIG_API_CONSTANTS_ONLY
#undef MLK_CONFIG_API_NAMESPACE_PREFIX
#undef MLK_CONFIG_API_NO_SUPERCOP
#undef MLK_CONFIG_API_PARAMETER_SET
#undef MLK_CONFIG_API_QUALIFIER
#undef MLK_ERR_FAIL
#undef MLK_ERR_OUT_OF_MEMORY
#undef MLK_ERR_RNG_FAIL
#undef MLK_H
#undef MLK_MAX3_
#undef MLK_TOTAL_ALLOC_1024
#undef MLK_TOTAL_ALLOC_1024_DECAPS
#undef MLK_TOTAL_ALLOC_1024_ENCAPS
#undef MLK_TOTAL_ALLOC_1024_KEYPAIR
#undef MLK_TOTAL_ALLOC_1024_KEYPAIR_NO_PCT
#undef MLK_TOTAL_ALLOC_1024_KEYPAIR_PCT
#undef MLK_TOTAL_ALLOC_512
#undef MLK_TOTAL_ALLOC_512_DECAPS
#undef MLK_TOTAL_ALLOC_512_ENCAPS
#undef MLK_TOTAL_ALLOC_512_KEYPAIR
#undef MLK_TOTAL_ALLOC_512_KEYPAIR_NO_PCT
#undef MLK_TOTAL_ALLOC_512_KEYPAIR_PCT
#undef MLK_TOTAL_ALLOC_768
#undef MLK_TOTAL_ALLOC_768_DECAPS
#undef MLK_TOTAL_ALLOC_768_ENCAPS
#undef MLK_TOTAL_ALLOC_768_KEYPAIR
#undef MLK_TOTAL_ALLOC_768_KEYPAIR_NO_PCT
#undef MLK_TOTAL_ALLOC_768_KEYPAIR_PCT
#undef crypto_kem_check_pk
#undef crypto_kem_check_sk
#undef crypto_kem_dec
#undef crypto_kem_enc
#undef crypto_kem_enc_derand
#undef crypto_kem_keypair
#undef crypto_kem_keypair_derand
/* mlkem/src/common.h */
#undef MLK_ADD_PARAM_SET
#undef MLK_ALLOC
#undef MLK_APPLY
#undef MLK_ASM_FN_SIZE
#undef MLK_ASM_FN_SYMBOL
#undef MLK_ASM_NAMESPACE
#undef MLK_BUILD_INTERNAL
#undef MLK_COMMON_H
#undef MLK_CONCAT
#undef MLK_CONCAT_
#undef MLK_CONTEXT_PARAMETERS_0
#undef MLK_CONTEXT_PARAMETERS_1
#undef MLK_CONTEXT_PARAMETERS_2
#undef MLK_CONTEXT_PARAMETERS_3
#undef MLK_CONTEXT_PARAMETERS_4
#undef MLK_EMPTY_CU
#undef MLK_ERR_FAIL
#undef MLK_ERR_OUT_OF_MEMORY
#undef MLK_ERR_RNG_FAIL
#undef MLK_EXTERNAL_API
#undef MLK_FIPS202X4_HEADER_FILE
#undef MLK_FIPS202_HEADER_FILE
#undef MLK_FREE
#undef MLK_INTERNAL_API
#undef MLK_INTERNAL_DATA_DECLARATION
#undef MLK_INTERNAL_DATA_DEFINITION
#undef MLK_NAMESPACE
#undef MLK_NAMESPACE_K
#undef MLK_NAMESPACE_PREFIX
#undef MLK_NAMESPACE_PREFIX_K
#undef mlk_memcpy
#undef mlk_memset
/* mlkem/src/indcpa.h */
#undef MLK_INDCPA_H
#undef mlk_gen_matrix
#undef mlk_indcpa_dec
#undef mlk_indcpa_enc
#undef mlk_indcpa_keypair_derand
/* mlkem/src/kem.h */
#undef MLK_KEM_H
#undef mlk_kem_check_pk
#undef mlk_kem_check_sk
#undef mlk_kem_dec
#undef mlk_kem_enc
#undef mlk_kem_enc_derand
#undef mlk_kem_keypair
#undef mlk_kem_keypair_derand
/* mlkem/src/params.h */
#undef MLKEM_DU
#undef MLKEM_DV
#undef MLKEM_ETA1
#undef MLKEM_ETA2
#undef MLKEM_INDCCA_CIPHERTEXTBYTES
#undef MLKEM_INDCCA_PUBLICKEYBYTES
#undef MLKEM_INDCCA_SECRETKEYBYTES
#undef MLKEM_INDCPA_BYTES
#undef MLKEM_INDCPA_MSGBYTES
#undef MLKEM_INDCPA_PUBLICKEYBYTES
#undef MLKEM_INDCPA_SECRETKEYBYTES
#undef MLKEM_K
#undef MLKEM_N
#undef MLKEM_POLYBYTES
#undef MLKEM_POLYCOMPRESSEDBYTES_D10
#undef MLKEM_POLYCOMPRESSEDBYTES_D11
#undef MLKEM_POLYCOMPRESSEDBYTES_D4
#undef MLKEM_POLYCOMPRESSEDBYTES_D5
#undef MLKEM_POLYCOMPRESSEDBYTES_DU
#undef MLKEM_POLYCOMPRESSEDBYTES_DV
#undef MLKEM_POLYVECBYTES
#undef MLKEM_POLYVECCOMPRESSEDBYTES_DU
#undef MLKEM_Q
#undef MLKEM_Q_HALF
#undef MLKEM_SSBYTES
#undef MLKEM_SYMBYTES
#undef MLKEM_UINT12_LIMIT
#undef MLK_PARAMS_H
/* mlkem/src/poly_k.h */
#undef MLK_POLY_K_H
#undef mlk_poly_compress_du
#undef mlk_poly_compress_dv
#undef mlk_poly_decompress_du
#undef mlk_poly_decompress_dv
#undef mlk_poly_getnoise_eta1122_4x
#undef mlk_poly_getnoise_eta1_4x
#undef mlk_poly_getnoise_eta2
#undef mlk_poly_getnoise_eta2_4x
#undef mlk_polymat
#undef mlk_polyvec
#undef mlk_polyvec_add
#undef mlk_polyvec_basemul_acc_montgomery_cached
#undef mlk_polyvec_compress_du
#undef mlk_polyvec_decompress_du
#undef mlk_polyvec_frombytes
#undef mlk_polyvec_invntt_tomont
#undef mlk_polyvec_mulcache
#undef mlk_polyvec_mulcache_compute
#undef mlk_polyvec_ntt
#undef mlk_polyvec_reduce
#undef mlk_polyvec_tobytes
#undef mlk_polyvec_tomont

#if !defined(MLK_CONFIG_MONOBUILD_KEEP_SHARED_HEADERS)
/*
 * Undefine macros from MLK_CONFIG_PARAMETER_SET-generic files
 */
/* mlkem/src/compress.h */
#undef MLK_COMPRESS_H
#undef mlk_poly_compress_d10
#undef mlk_poly_compress_d11
#undef mlk_poly_compress_d4
#undef mlk_poly_compress_d5
#undef mlk_poly_decompress_d10
#undef mlk_poly_decompress_d11
#undef mlk_poly_decompress_d4
#undef mlk_poly_decompress_d5
#undef mlk_poly_frombytes
#undef mlk_poly_frommsg
#undef mlk_poly_tobytes
#undef mlk_poly_tomsg
/* mlkem/src/debug.h */
#undef MLK_DEBUG_H
#undef mlk_assert
#undef mlk_assert_abs_bound
#undef mlk_assert_abs_bound_2d
#undef mlk_assert_bound
#undef mlk_assert_bound_2d
#undef mlk_debug_check_assert
#undef mlk_debug_check_bounds
/* mlkem/src/poly.h */
#undef MLK_INVNTT_BOUND
#undef MLK_NTT_BOUND
#undef MLK_POLY_H
#undef mlk_poly_add
#undef mlk_poly_invntt_tomont
#undef mlk_poly_mulcache_compute
#undef mlk_poly_ntt
#undef mlk_poly_reduce
#undef mlk_poly_sub
#undef mlk_poly_tomont
/* mlkem/src/randombytes.h */
#undef MLK_RANDOMBYTES_H
/* mlkem/src/sampling.h */
#undef MLK_SAMPLING_H
#undef mlk_poly_cbd2
#undef mlk_poly_cbd3
#undef mlk_poly_rej_uniform
#undef mlk_poly_rej_uniform_x4
/* mlkem/src/symmetric.h */
#undef MLK_SYMMETRIC_H
#undef MLK_XOF_RATE
#undef mlk_hash_g
#undef mlk_hash_h
#undef mlk_hash_j
#undef mlk_prf_eta
#undef mlk_prf_eta1
#undef mlk_prf_eta1_x4
#undef mlk_prf_eta2
#undef mlk_xof_absorb
#undef mlk_xof_ctx
#undef mlk_xof_init
#undef mlk_xof_release
#undef mlk_xof_squeezeblocks
#undef mlk_xof_x4_absorb
#undef mlk_xof_x4_ctx
#undef mlk_xof_x4_init
#undef mlk_xof_x4_release
#undef mlk_xof_x4_squeezeblocks
/* mlkem/src/sys.h */
#undef MLK_ALIGN
#undef MLK_ALIGN_UP
#undef MLK_ALWAYS_INLINE
#undef MLK_CET_ENDBR
#undef MLK_CT_TESTING_DECLASSIFY
#undef MLK_CT_TESTING_SECRET
#undef MLK_DEFAULT_ALIGN
#undef MLK_HAVE_INLINE_ASM
#undef MLK_INLINE
#undef MLK_MUST_CHECK_RETURN_VALUE
#undef MLK_NOINLINE
#undef MLK_RESTRICT
#undef MLK_STATIC_TESTABLE
#undef MLK_SYSV_ABI
#undef MLK_SYSV_ABI_SUPPORTED
#undef MLK_SYS_AARCH64
#undef MLK_SYS_AARCH64_EB
#undef MLK_SYS_APPLE
#undef MLK_SYS_ARMV81M_MVE
#undef MLK_SYS_BIG_ENDIAN
#undef MLK_SYS_H
#undef MLK_SYS_LINUX
#undef MLK_SYS_LITTLE_ENDIAN
#undef MLK_SYS_PPC64LE
#undef MLK_SYS_RISCV32
#undef MLK_SYS_RISCV64
#undef MLK_SYS_RISCV64_RVV
#undef MLK_SYS_WINDOWS
#undef MLK_SYS_X86_64
#undef MLK_SYS_X86_64_AVX2
/* mlkem/src/verify.h */
#undef MLK_USE_ASM_VALUE_BARRIER
#undef MLK_VERIFY_H
#undef mlk_ct_opt_blocker_u64
/* mlkem/src/cbmc.h */
#undef MLK_CBMC_H
#undef __contract__
#undef __loop__

#if !defined(MLK_CONFIG_FIPS202_CUSTOM_HEADER)
/*
 * Undefine macros from FIPS-202 files
 */
/* mlkem/src/fips202/fips202.h */
#undef FIPS202_X4_DEFAULT_IMPLEMENTATION
#undef MLK_FIPS202_FIPS202_H
#undef SHA3_256_HASHBYTES
#undef SHA3_256_RATE
#undef SHA3_384_RATE
#undef SHA3_512_HASHBYTES
#undef SHA3_512_RATE
#undef SHAKE128_RATE
#undef SHAKE256_RATE
#undef mlk_sha3_256
#undef mlk_sha3_512
#undef mlk_shake128_absorb_once
#undef mlk_shake128_init
#undef mlk_shake128_release
#undef mlk_shake128_squeezeblocks
#undef mlk_shake256
/* mlkem/src/fips202/fips202x4.h */
#undef MLK_FIPS202_FIPS202X4_H
#undef mlk_shake128x4_absorb_once
#undef mlk_shake128x4_init
#undef mlk_shake128x4_release
#undef mlk_shake128x4_squeezeblocks
#undef mlk_shake256x4
/* mlkem/src/fips202/keccakf1600.h */
#undef MLK_FIPS202_KECCAKF1600_H
#undef MLK_KECCAK_LANES
#undef MLK_KECCAK_WAY
#undef mlk_keccakf1600_extract_bytes
#undef mlk_keccakf1600_permute
#undef mlk_keccakf1600_xor_bytes
#undef mlk_keccakf1600x4_extract_bytes
#undef mlk_keccakf1600x4_permute
#undef mlk_keccakf1600x4_xor_bytes
#endif /* !MLK_CONFIG_FIPS202_CUSTOM_HEADER */

#if defined(MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202)
/* mlkem/src/fips202/native/api.h */
#undef MLK_FIPS202_NATIVE_API_H
#undef MLK_NATIVE_FUNC_FALLBACK
#undef MLK_NATIVE_FUNC_SUCCESS
/* mlkem/src/fips202/native/auto.h */
#undef MLK_FIPS202_NATIVE_AUTO_H
#if defined(MLK_SYS_AARCH64)
/*
 * Undefine macros from native code (FIPS202, AArch64)
 */
/* mlkem/src/fips202/native/aarch64/auto.h */
#undef MLK_FIPS202_NATIVE_AARCH64_AUTO_H
/* mlkem/src/fips202/native/aarch64/src/fips202_native_aarch64.h */
#undef MLK_FIPS202_NATIVE_AARCH64_SRC_FIPS202_NATIVE_AARCH64_H
#undef mlk_keccak_f1600_x1_scalar_aarch64_asm
#undef mlk_keccak_f1600_x1_v84a_aarch64_asm
#undef mlk_keccak_f1600_x2_v84a_aarch64_asm
#undef mlk_keccak_f1600_x4_v8a_scalar_hybrid_aarch64_asm
#undef mlk_keccak_f1600_x4_v8a_v84a_scalar_hybrid_aarch64_asm
#undef mlk_keccakf1600_round_constants
/* mlkem/src/fips202/native/aarch64/x1_scalar.h */
#undef MLK_FIPS202_AARCH64_NEED_X1_SCALAR
#undef MLK_FIPS202_NATIVE_AARCH64_X1_SCALAR_H
#undef MLK_USE_FIPS202_X1_NATIVE
/* mlkem/src/fips202/native/aarch64/x1_v84a.h */
#undef MLK_FIPS202_AARCH64_NEED_X1_V84A
#undef MLK_FIPS202_NATIVE_AARCH64_X1_V84A_H
#undef MLK_USE_FIPS202_X1_NATIVE
/* mlkem/src/fips202/native/aarch64/x2_v84a.h */
#undef MLK_FIPS202_AARCH64_NEED_X2_V84A
#undef MLK_FIPS202_NATIVE_AARCH64_X2_V84A_H
#undef MLK_USE_FIPS202_X4_NATIVE
/* mlkem/src/fips202/native/aarch64/x4_v8a_scalar.h */
#undef MLK_FIPS202_AARCH64_NEED_X4_V8A_SCALAR_HYBRID
#undef MLK_FIPS202_NATIVE_AARCH64_X4_V8A_SCALAR_H
#undef MLK_USE_FIPS202_X4_NATIVE
/* mlkem/src/fips202/native/aarch64/x4_v8a_v84a_scalar.h */
#undef MLK_FIPS202_AARCH64_NEED_X4_V8A_V84A_SCALAR_HYBRID
#undef MLK_FIPS202_NATIVE_AARCH64_X4_V8A_V84A_SCALAR_H
#undef MLK_USE_FIPS202_X4_NATIVE
#endif /* MLK_SYS_AARCH64 */
#if defined(MLK_SYS_X86_64)
/*
 * Undefine macros from native code (FIPS202, x86_64)
 */
/* mlkem/src/fips202/native/x86_64/keccak_f1600_x4_avx2.h */
#undef MLK_FIPS202_NATIVE_X86_64_KECCAK_F1600_X4_AVX2_H
#undef MLK_FIPS202_X86_64_NEED_X4_AVX2
#undef MLK_USE_FIPS202_X4_NATIVE
/* mlkem/src/fips202/native/x86_64/src/fips202_native_x86_64.h */
#undef MLK_FIPS202_NATIVE_X86_64_SRC_FIPS202_NATIVE_X86_64_H
#undef mlk_keccak_f1600_x4_avx2_asm
#undef mlk_keccak_rho56
#undef mlk_keccak_rho8
#undef mlk_keccakf1600_round_constants
#endif /* MLK_SYS_X86_64 */
#if defined(MLK_SYS_ARMV81M_MVE)
/*
 * Undefine macros from native code (FIPS202, Armv8.1-M)
 */
/* mlkem/src/fips202/native/armv81m/mve.h */
#undef MLK_FIPS202_ARMV81M_NEED_X4
#undef MLK_FIPS202_NATIVE_ARMV81M
#undef MLK_FIPS202_NATIVE_ARMV81M_MVE_H
#undef MLK_USE_FIPS202_X4_EXTRACT_BYTES_NATIVE
#undef MLK_USE_FIPS202_X4_NATIVE
#undef MLK_USE_FIPS202_X4_XOR_BYTES_NATIVE
#undef mlk_keccak_f1600_x4_native_impl
#undef mlk_keccak_f1600_x4_state_extract_bytes
#undef mlk_keccak_f1600_x4_state_xor_bytes
/* mlkem/src/fips202/native/armv81m/src/fips202_native_armv81m.h */
#undef MLK_FIPS202_NATIVE_ARMV81M_SRC_FIPS202_NATIVE_ARMV81M_H
#undef mlk_keccak_f1600_x4_mve_asm
#undef mlk_keccak_f1600_x4_state_extract_bytes_asm
#undef mlk_keccak_f1600_x4_state_xor_bytes_asm
#undef mlk_keccakf1600_round_constants
#endif /* MLK_SYS_ARMV81M_MVE */
#endif /* MLK_CONFIG_USE_NATIVE_BACKEND_FIPS202 */
#if defined(MLK_CONFIG_USE_NATIVE_BACKEND_ARITH)
/* mlkem/src/native/api.h */
#undef MLK_INVNTT_BOUND
#undef MLK_NATIVE_API_H
#undef MLK_NATIVE_FUNC_FALLBACK
#undef MLK_NATIVE_FUNC_SUCCESS
#undef MLK_NTT_BOUND
/* mlkem/src/native/meta.h */
#undef MLK_NATIVE_META_H
#if defined(MLK_SYS_AARCH64)
/*
 * Undefine macros from native code (Arith, AArch64)
 */
/* mlkem/src/native/aarch64/meta.h */
#undef MLK_ARITH_BACKEND_AARCH64
#undef MLK_NATIVE_AARCH64_META_H
#undef MLK_USE_NATIVE_INTT
#undef MLK_USE_NATIVE_NTT
#undef MLK_USE_NATIVE_POLYVEC_BASEMUL_ACC_MONTGOMERY_CACHED
#undef MLK_USE_NATIVE_POLY_MULCACHE_COMPUTE
#undef MLK_USE_NATIVE_POLY_REDUCE
#undef MLK_USE_NATIVE_POLY_TOBYTES
#undef MLK_USE_NATIVE_POLY_TOMONT
#undef MLK_USE_NATIVE_REJ_UNIFORM
/* mlkem/src/native/aarch64/src/arith_native_aarch64.h */
#undef MLK_NATIVE_AARCH64_SRC_ARITH_NATIVE_AARCH64_H
#undef mlk_aarch64_invntt_zetas_layer12345
#undef mlk_aarch64_invntt_zetas_layer67
#undef mlk_aarch64_ntt_zetas_layer12345
#undef mlk_aarch64_ntt_zetas_layer67
#undef mlk_aarch64_zetas_mulcache_native
#undef mlk_aarch64_zetas_mulcache_twisted_native
#undef mlk_intt_aarch64_asm
#undef mlk_ntt_aarch64_asm
#undef mlk_poly_mulcache_compute_aarch64_asm
#undef mlk_poly_reduce_aarch64_asm
#undef mlk_poly_tobytes_aarch64_asm
#undef mlk_poly_tomont_aarch64_asm
#undef mlk_polyvec_basemul_acc_montgomery_cached_k2_aarch64_asm
#undef mlk_polyvec_basemul_acc_montgomery_cached_k3_aarch64_asm
#undef mlk_polyvec_basemul_acc_montgomery_cached_k4_aarch64_asm
#undef mlk_rej_uniform_aarch64_asm
#undef mlk_rej_uniform_table
#endif /* MLK_SYS_AARCH64 */
#if defined(MLK_SYS_X86_64)
/*
 * Undefine macros from native code (Arith, X86_64)
 */
/* mlkem/src/native/x86_64/meta.h */
#undef MLK_ARITH_BACKEND_X86_64_DEFAULT
#undef MLK_NATIVE_X86_64_META_H
#undef MLK_USE_NATIVE_INTT
#undef MLK_USE_NATIVE_NTT
#undef MLK_USE_NATIVE_NTT_CUSTOM_ORDER
#undef MLK_USE_NATIVE_POLYVEC_BASEMUL_ACC_MONTGOMERY_CACHED
#undef MLK_USE_NATIVE_POLY_COMPRESS_D10
#undef MLK_USE_NATIVE_POLY_COMPRESS_D11
#undef MLK_USE_NATIVE_POLY_COMPRESS_D4
#undef MLK_USE_NATIVE_POLY_COMPRESS_D5
#undef MLK_USE_NATIVE_POLY_DECOMPRESS_D10
#undef MLK_USE_NATIVE_POLY_DECOMPRESS_D11
#undef MLK_USE_NATIVE_POLY_DECOMPRESS_D4
#undef MLK_USE_NATIVE_POLY_DECOMPRESS_D5
#undef MLK_USE_NATIVE_POLY_FROMBYTES
#undef MLK_USE_NATIVE_POLY_MULCACHE_COMPUTE
#undef MLK_USE_NATIVE_POLY_REDUCE
#undef MLK_USE_NATIVE_POLY_TOBYTES
#undef MLK_USE_NATIVE_POLY_TOMONT
#undef MLK_USE_NATIVE_REJ_UNIFORM
/* mlkem/src/native/x86_64/src/arith_native_x86_64.h */
#undef MLK_AVX2_REJ_UNIFORM_BUFLEN
#undef MLK_NATIVE_X86_64_SRC_ARITH_NATIVE_X86_64_H
#undef mlk_invntt_avx2_asm
#undef mlk_ntt_avx2_asm
#undef mlk_nttfrombytes_avx2_asm
#undef mlk_ntttobytes_avx2_asm
#undef mlk_nttunpack_avx2_asm
#undef mlk_poly_compress_d10_avx2_asm
#undef mlk_poly_compress_d11_avx2_asm
#undef mlk_poly_compress_d4_avx2_asm
#undef mlk_poly_compress_d5_avx2_asm
#undef mlk_poly_decompress_d10_avx2_asm
#undef mlk_poly_decompress_d11_avx2_asm
#undef mlk_poly_decompress_d4_avx2_asm
#undef mlk_poly_decompress_d5_avx2_asm
#undef mlk_poly_mulcache_compute_avx2_asm
#undef mlk_polyvec_basemul_acc_montgomery_cached_k2_avx2_asm
#undef mlk_polyvec_basemul_acc_montgomery_cached_k3_avx2_asm
#undef mlk_polyvec_basemul_acc_montgomery_cached_k4_avx2_asm
#undef mlk_reduce_avx2_asm
#undef mlk_rej_uniform_avx2_asm
#undef mlk_rej_uniform_table
#undef mlk_tomont_avx2_asm
/* mlkem/src/native/x86_64/src/compress_consts.h */
#undef MLK_NATIVE_X86_64_SRC_COMPRESS_CONSTS_H
#undef mlk_compress_d10_data
#undef mlk_compress_d11_data
#undef mlk_compress_d4_data
#undef mlk_compress_d5_data
#undef mlk_decompress_d10_data
#undef mlk_decompress_d11_data
#undef mlk_decompress_d4_data
#undef mlk_decompress_d5_data
/* mlkem/src/native/x86_64/src/consts.h */
#undef MLK_AVX2_BACKEND_DATA_OFFSET_MULCACHE_TWIDDLES
#undef MLK_AVX2_BACKEND_DATA_OFFSET_REVIDXB
#undef MLK_AVX2_BACKEND_DATA_OFFSET_REVIDXD
#undef MLK_AVX2_BACKEND_DATA_OFFSET_ZETAS_EXP
#undef MLK_NATIVE_X86_64_SRC_CONSTS_H
#undef mlk_qdata
#endif /* MLK_SYS_X86_64 */
#if defined(MLK_SYS_RISCV64)
/*
 * Undefine macros from native code (Arith, RISC-V 64)
 */
/* mlkem/src/native/riscv64/meta.h */
#undef MLK_ARITH_BACKEND_RISCV64
#undef MLK_NATIVE_RISCV64_META_H
#undef MLK_USE_NATIVE_INTT
#undef MLK_USE_NATIVE_NTT
#undef MLK_USE_NATIVE_POLYVEC_BASEMUL_ACC_MONTGOMERY_CACHED
#undef MLK_USE_NATIVE_POLY_MULCACHE_COMPUTE
#undef MLK_USE_NATIVE_POLY_REDUCE
#undef MLK_USE_NATIVE_POLY_TOMONT
#undef MLK_USE_NATIVE_REJ_UNIFORM
/* mlkem/src/native/riscv64/src/arith_native_riscv64.h */
#undef MLK_NATIVE_RISCV64_SRC_ARITH_NATIVE_RISCV64_H
#undef mlk_rv64v_poly_add
#undef mlk_rv64v_poly_basemul_mont_add_k2
#undef mlk_rv64v_poly_basemul_mont_add_k3
#undef mlk_rv64v_poly_basemul_mont_add_k4
#undef mlk_rv64v_poly_invntt_tomont
#undef mlk_rv64v_poly_ntt
#undef mlk_rv64v_poly_reduce
#undef mlk_rv64v_poly_sub
#undef mlk_rv64v_poly_tomont
#undef mlk_rv64v_rej_uniform
/* mlkem/src/native/riscv64/src/rv64v_debug.h */
#undef MLK_NATIVE_RISCV64_SRC_RV64V_DEBUG_H
#undef mlk_assert_abs_bound_int16m1
#undef mlk_assert_abs_bound_int16m2
#undef mlk_assert_bound_int16m1
#undef mlk_assert_bound_int16m2
#undef mlk_debug_check_bounds_int16m1
#undef mlk_debug_check_bounds_int16m2
#endif /* MLK_SYS_RISCV64 */
#if defined(MLK_SYS_PPC64LE)
/*
 * Undefine macros from native code (Arith, PPC64LE)
 */
/* mlkem/src/native/ppc64le/meta.h */
#undef MLK_ARITH_BACKEND_NAME
#undef MLK_ARITH_BACKEND_PPC64LE_DEFAULT
#undef MLK_NATIVE_PPC64LE_META_H
#undef MLK_USE_NATIVE_INTT
#undef MLK_USE_NATIVE_NTT
#undef MLK_USE_NATIVE_POLY_REDUCE
#undef MLK_USE_NATIVE_POLY_TOMONT
/* mlkem/src/native/ppc64le/src/arith_native_ppc64le.h */
#undef MLK_NATIVE_PPC64LE_SRC_ARITH_NATIVE_PPC64LE_H
#undef mlk_intt_ppc_asm
#undef mlk_ntt_ppc_asm
#undef mlk_poly_tomont_ppc_asm
#undef mlk_reduce_ppc_asm
/* mlkem/src/native/ppc64le/src/consts.h */
#undef MLK_NATIVE_PPC64LE_SRC_CONSTS_H
#undef MLK_PPC_C20159_OFFSET
#undef MLK_PPC_NQ_OFFSET
#undef MLK_PPC_N_INV_OFFSET
#undef MLK_PPC_N_INV_TW_OFFSET
#undef MLK_PPC_Q_OFFSET
#undef MLK_PPC_TOMONT_OFFSET
#undef MLK_PPC_TOMONT_TW_OFFSET
#undef MLK_PPC_ZETA_INTT_OFFSET
#undef MLK_PPC_ZETA_INTT_TW_OFFSET
#undef MLK_PPC_ZETA_NTT_OFFSET
#undef MLK_PPC_ZETA_NTT_TW_OFFSET
#undef mlk_ppc_qdata
#endif /* MLK_SYS_PPC64LE */
#endif /* MLK_CONFIG_USE_NATIVE_BACKEND_ARITH */
#endif /* !MLK_CONFIG_MONOBUILD_KEEP_SHARED_HEADERS */
````

### `mlkem/src/indcpa.c`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [FIPS203]
 *   FIPS 203 Module-Lattice-Based Key-Encapsulation Mechanism Standard
 *   National Institute of Standards and Technology
 *   https://csrc.nist.gov/pubs/fips/203/final
 *
 * - [REF]
 *   CRYSTALS-Kyber C reference implementation
 *   Bos, Ducas, Kiltz, Lepoint, Lyubashevsky, Schanck, Schwabe, Seiler, Stehlé
 *   https://github.com/pq-crystals/kyber/tree/main/ref
 */

#include "indcpa.h"

#include "debug.h"
#include "randombytes.h"
#include "sampling.h"
#include "symmetric.h"
#include "verify.h"

/* Parameter set namespacing
 * This is to facilitate building multiple instances
 * of mlkem-native (e.g. with varying parameter sets)
 * within a single compilation unit. */
#define mlk_pack_pk MLK_ADD_PARAM_SET(mlk_pack_pk)
#define mlk_unpack_pk MLK_ADD_PARAM_SET(mlk_unpack_pk)
#define mlk_pack_sk MLK_ADD_PARAM_SET(mlk_pack_sk)
#define mlk_unpack_sk MLK_ADD_PARAM_SET(mlk_unpack_sk)
#define mlk_pack_ciphertext MLK_ADD_PARAM_SET(mlk_pack_ciphertext)
#define mlk_unpack_ciphertext MLK_ADD_PARAM_SET(mlk_unpack_ciphertext)
#define mlk_matvec_mul MLK_ADD_PARAM_SET(mlk_matvec_mul)
#define mlk_polyvec_permute_bitrev_to_custom \
  MLK_ADD_PARAM_SET(mlk_polyvec_permute_bitrev_to_custom)
#define mlk_polymat_permute_bitrev_to_custom \
  MLK_ADD_PARAM_SET(mlk_polymat_permute_bitrev_to_custom)
#define mlk_keypair_getnoise_eta1 MLK_ADD_PARAM_SET(mlk_keypair_getnoise_eta1)
#define mlk_enc_getnoise_eta1_eta2 MLK_ADD_PARAM_SET(mlk_enc_getnoise_eta1_eta2)
/* End of parameter set namespacing */

/**
 * Serialize the public key as the concatenation of the serialized vector of
 * polynomials pk and the public seed used to generate the matrix A.
 *
 * @spec{Implements @[FIPS203, Algorithm 13 (K-PKE.KeyGen), L19].}
 *
 * @param[out] r    Output serialized public key.
 * @param[in]  pk   Input public-key polyvec. Must have coefficients within
 *                  [0,..,MLKEM_Q-1].
 * @param[in]  seed Input public seed.
 */
static void mlk_pack_pk(uint8_t r[MLKEM_INDCPA_PUBLICKEYBYTES],
                        const mlk_polyvec *pk,
                        const uint8_t seed[MLKEM_SYMBYTES])
{
  mlk_assert_bound_2d(pk->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
  mlk_polyvec_tobytes(r, pk);
  mlk_memcpy(r + MLKEM_POLYVECBYTES, seed, MLKEM_SYMBYTES);
}

/**
 * De-serialize public key from a byte array; approximate inverse of
 * mlk_pack_pk.
 *
 * @spec{Implements @[FIPS203, Algorithm 14 (K-PKE.Encrypt), L2-3].}
 *
 * @param[out] pk       Output public-key polynomial vector. Coefficients
 *                      will be normalized to [0,1,..,MLKEM_Q-1].
 * @param[out] seed     Output seed to generate matrix A.
 * @param[in]  packedpk Input serialized public key.
 */
static void mlk_unpack_pk(mlk_polyvec *pk, uint8_t seed[MLKEM_SYMBYTES],
                          const uint8_t packedpk[MLKEM_INDCPA_PUBLICKEYBYTES])
{
  mlk_polyvec_frombytes(pk, packedpk);
  mlk_memcpy(seed, packedpk + MLKEM_POLYVECBYTES, MLKEM_SYMBYTES);

  /* NOTE: If a modulus check was conducted on the PK, we know at this
   * point that the coefficients of `pk` are unsigned canonical. The
   * specifications and proofs, however, do _not_ assume this, and instead
   * work with the easily provable bound by MLKEM_UINT12_LIMIT. */
}

/**
 * Serialize the secret key.
 *
 * @spec{Implements @[FIPS203, Algorithm 13 (K-PKE.KeyGen), L20].}
 *
 * @param[out] r  Output serialized secret key.
 * @param[in]  sk Input vector of polynomials (secret key).
 */
static void mlk_pack_sk(uint8_t r[MLKEM_INDCPA_SECRETKEYBYTES],
                        const mlk_polyvec *sk)
{
  mlk_assert_bound_2d(sk->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
  mlk_polyvec_tobytes(r, sk);
}

/**
 * De-serialize the secret key; inverse of mlk_pack_sk.
 *
 * @spec{Implements @[FIPS203, Algorithm 15 (K-PKE.Decrypt), L5].}
 *
 * @param[out] sk       Output vector of polynomials (secret key).
 * @param[in]  packedsk Input serialized secret key.
 */
static void mlk_unpack_sk(mlk_polyvec *sk,
                          const uint8_t packedsk[MLKEM_INDCPA_SECRETKEYBYTES])
{
  mlk_polyvec_frombytes(sk, packedsk);
}

/**
 * Serialize the ciphertext as the concatenation of the compressed and
 * serialized vector of polynomials b and the compressed and serialized
 * polynomial v.
 *
 * @spec{Implements @[FIPS203, Algorithm 14 (K-PKE.Encrypt), L22-23].}
 *
 * @param[out] r Output serialized ciphertext.
 * @param[in]  b Input vector of polynomials b.
 * @param[in]  v Input polynomial v.
 */
static void mlk_pack_ciphertext(uint8_t r[MLKEM_INDCPA_BYTES],
                                const mlk_polyvec *b, mlk_poly *v)
{
  mlk_polyvec_compress_du(r, b);
  mlk_poly_compress_dv(r + MLKEM_POLYVECCOMPRESSEDBYTES_DU, v);
}

/**
 * De-serialize and decompress ciphertext from a byte array; approximate
 * inverse of mlk_pack_ciphertext.
 *
 * @spec{Implements @[FIPS203, Algorithm 15 (K-PKE.Decrypt), L1-4].}
 *
 * @param[out] b Output vector of polynomials b.
 * @param[out] v Output polynomial v.
 * @param[in]  c Input serialized ciphertext.
 */
static void mlk_unpack_ciphertext(mlk_polyvec *b, mlk_poly *v,
                                  const uint8_t c[MLKEM_INDCPA_BYTES])
{
  mlk_polyvec_decompress_du(b, c);
  mlk_poly_decompress_dv(v, c + MLKEM_POLYVECCOMPRESSEDBYTES_DU);
}

/* Helper function to ensure that the polynomial entries in the output
 * of gen_matrix use the standard (bitreversed) ordering of coefficients.
 * No-op unless a native backend with a custom ordering is used.
 *
 * We don't inline this into gen_matrix to avoid having to split the CBMC
 * proof for gen_matrix based on MLK_USE_NATIVE_NTT_CUSTOM_ORDER. */
static void mlk_polyvec_permute_bitrev_to_custom(mlk_polyvec *v)
__contract__(
  /* We don't specify that this should be a permutation, but only
   * that it does not change the bound established at the end of mlk_gen_matrix. */
  requires(memory_no_alias(v, sizeof(mlk_polyvec)))
  requires(forall(x, 0, MLKEM_K,
    array_bound(v->vec[x].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
  assigns(memory_slice(v, sizeof(mlk_polyvec)))
  ensures(forall(x, 0, MLKEM_K,
    array_bound(v->vec[x].coeffs, 0, MLKEM_N, 0, MLKEM_Q))))
{
#if defined(MLK_USE_NATIVE_NTT_CUSTOM_ORDER)
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  __loop__(
     assigns(i, memory_slice(v, sizeof(mlk_polyvec)))
     invariant(i <= MLKEM_K)
     invariant(forall(x, 0, MLKEM_K,
       array_bound(v->vec[x].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
     decreases(MLKEM_K - i))
  {
    mlk_poly_permute_bitrev_to_custom(v->vec[i].coeffs);
  }
#else  /* MLK_USE_NATIVE_NTT_CUSTOM_ORDER */
  /* Nothing to do */
  (void)v;
#endif /* !MLK_USE_NATIVE_NTT_CUSTOM_ORDER */
}

static void mlk_polymat_permute_bitrev_to_custom(mlk_polymat *a)
__contract__(
  /* We don't specify that this should be a permutation, but only
   * that it does not change the bound established at the end of mlk_gen_matrix. */
  requires(memory_no_alias(a, sizeof(mlk_polymat)))
  requires(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
    array_bound(a->vec[x].vec[y].coeffs, 0, MLKEM_N, 0, MLKEM_Q))))
  assigns(memory_slice(a, sizeof(mlk_polymat)))
  ensures(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
    array_bound(a->vec[x].vec[y].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))))
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  __loop__(
     assigns(i, memory_slice(a, sizeof(mlk_polymat)))
     invariant(i <= MLKEM_K)
     invariant(forall(x, 0, MLKEM_K, forall(y, 0, MLKEM_K,
       array_bound(a->vec[x].vec[y].coeffs, 0, MLKEM_N, 0, MLKEM_Q))))
     decreases(MLKEM_K - i))
  {
    mlk_polyvec_permute_bitrev_to_custom(&a->vec[i]);
  }
}

/* Reference: `gen_matrix()` in the reference implementation @[REF].
 *            - We use a special subroutine to generate 4 polynomials
 *              at a time, to be able to leverage batched Keccak-f1600
 *              implementations. The reference implementation generates
 *              one matrix entry a time.
 *
 * Not static for benchmarking */
MLK_INTERNAL_API
void mlk_gen_matrix(mlk_polymat *a, const uint8_t seed[MLKEM_SYMBYTES],
                    int transposed)
{
  unsigned i, j;
  MLK_ALIGN uint8_t seed_ext[4][MLK_ALIGN_UP(MLKEM_SYMBYTES + 2)];

  for (j = 0; j < 4; j++)
  {
    mlk_memcpy(seed_ext[j], seed, MLKEM_SYMBYTES);
  }

#if !defined(MLK_CONFIG_SERIAL_FIPS202_ONLY)
  /* Sample 4 matrix entries a time. */
  for (i = 0; i < (MLKEM_K * MLKEM_K / 4) * 4; i += 4)
  {
    for (j = 0; j < 4; j++)
    {
      uint8_t x, y;
      /* MLKEM_K <= 4, so the values fit in uint8_t. */
      x = (uint8_t)((i + j) / MLKEM_K);
      y = (uint8_t)((i + j) % MLKEM_K);
      if (transposed)
      {
        seed_ext[j][MLKEM_SYMBYTES + 0] = x;
        seed_ext[j][MLKEM_SYMBYTES + 1] = y;
      }
      else
      {
        seed_ext[j][MLKEM_SYMBYTES + 0] = y;
        seed_ext[j][MLKEM_SYMBYTES + 1] = x;
      }
    }

    mlk_poly_rej_uniform_x4(&a->vec[i / MLKEM_K].vec[i % MLKEM_K],
                            &a->vec[(i + 1) / MLKEM_K].vec[(i + 1) % MLKEM_K],
                            &a->vec[(i + 2) / MLKEM_K].vec[(i + 2) % MLKEM_K],
                            &a->vec[(i + 3) / MLKEM_K].vec[(i + 3) % MLKEM_K],
                            seed_ext);
  }
#else  /* !MLK_CONFIG_SERIAL_FIPS202_ONLY */
  /* When using serial FIPS202, sample all entries individually. */
  i = 0;
#endif /* MLK_CONFIG_SERIAL_FIPS202_ONLY */

  /* For MLKEM_K == 3, sample the last entry individually.
   * When MLK_CONFIG_SERIAL_FIPS202_ONLY is set, sample all entries
   * individually. */
  for (; i < MLKEM_K * MLKEM_K; i++)
  {
    uint8_t x, y;
    /* MLKEM_K <= 4, so the values fit in uint8_t. */
    x = (uint8_t)(i / MLKEM_K);
    y = (uint8_t)(i % MLKEM_K);

    if (transposed)
    {
      seed_ext[0][MLKEM_SYMBYTES + 0] = x;
      seed_ext[0][MLKEM_SYMBYTES + 1] = y;
    }
    else
    {
      seed_ext[0][MLKEM_SYMBYTES + 0] = y;
      seed_ext[0][MLKEM_SYMBYTES + 1] = x;
    }

    mlk_poly_rej_uniform(&a->vec[i / MLKEM_K].vec[i % MLKEM_K], seed_ext[0]);
  }

  mlk_assert(i == MLKEM_K * MLKEM_K);

  /*
   * The public matrix is generated in NTT domain. If the native backend
   * uses a custom order in NTT domain, permute A accordingly.
   */
  mlk_polymat_permute_bitrev_to_custom(a);

  /* Specification: Partially implements
   * @[FIPS203, Section 3.3, Destruction of intermediate values] */
  mlk_zeroize(seed_ext, sizeof(seed_ext));
}

/**
 * Compute matrix-vector product in NTT domain, via Montgomery multiplication.
 *
 * @spec{Implements @[FIPS203, Section 2.4.7, Eq (2.12), (2.13)].}
 *
 * @param[out] out Output polynomial vector.
 * @param[in]  a   Input matrix. Must be in NTT domain and have coefficients
 *                 of absolute value < 4096.
 * @param[in]  v   Input polynomial vector. Must be in NTT domain.
 * @param[in]  vc  Mulcache for @p v, computed via
 *                 mlk_polyvec_mulcache_compute().
 */
static void mlk_matvec_mul(mlk_polyvec *out, const mlk_polymat *a,
                           const mlk_polyvec *v, const mlk_polyvec_mulcache *vc)
__contract__(
  requires(memory_no_alias(out, sizeof(mlk_polyvec)))
  requires(memory_no_alias(a, sizeof(mlk_polymat)))
  requires(memory_no_alias(v, sizeof(mlk_polyvec)))
  requires(memory_no_alias(vc, sizeof(mlk_polyvec_mulcache)))
  requires(forall(k0, 0, MLKEM_K,
    forall(k1, 0, MLKEM_K,
      array_bound(a->vec[k0].vec[k1].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT))))
  assigns(memory_slice(out, sizeof(mlk_polyvec))))
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  __loop__(
    assigns(i, memory_slice(out, sizeof(mlk_polyvec)))
    invariant(i <= MLKEM_K)
    decreases(MLKEM_K - i))
  {
    mlk_polyvec_basemul_acc_montgomery_cached(&out->vec[i], &a->vec[i], v, vc);
  }
}

/**
 * Compute and fill the pv and e polyvec structures needed by
 * mlk_keypair_derand(). Uses x4-batched versions of `poly_getnoise` to
 * leverage batched Keccak-f1600.
 *
 * @spec{Implements @[FIPS203, Algorithm 13 (K-PKE.KeyGen)] steps 8-15.}
 *
 * @param[out] pv   Output polynomial vector.
 * @param[out] e    Output polynomial vector.
 * @param[in]  seed Seed bytes for sampling.
 */
static void mlk_keypair_getnoise_eta1(mlk_polyvec *pv, mlk_polyvec *e,
                                      const uint8_t seed[MLKEM_SYMBYTES])
__contract__(
  requires(memory_no_alias(pv, sizeof(mlk_polyvec)))
  requires(memory_no_alias(e, sizeof(mlk_polyvec)))
  requires(memory_no_alias(seed, MLKEM_SYMBYTES))
  assigns(memory_slice(pv, sizeof(mlk_polyvec)))
  assigns(memory_slice(e, sizeof(mlk_polyvec)))
  ensures(forall(k0, 0, MLKEM_K, array_abs_bound(pv->vec[k0].coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1)))
  ensures(forall(k1, 0, MLKEM_K, array_abs_bound(e->vec[k1].coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1)))
)
{
#if MLKEM_K == 2
  mlk_poly_getnoise_eta1_4x(&pv->vec[0], &pv->vec[1], /* Fill elements of pv */
                            &e->vec[0], &e->vec[1], /* and two elements of e */
                            seed, 0, 1, 2, 3);
#elif MLKEM_K == 3
  /*
   * Only the first three output buffers are needed, so we pass NULL as
   * the fourth parameter, and 0xFF as its dummy nonce.
   */
  mlk_poly_getnoise_eta1_4x(&pv->vec[0], &pv->vec[1], &pv->vec[2], NULL, seed,
                            0, 1, 2, 0xFF);
  /* Same here */
  mlk_poly_getnoise_eta1_4x(&e->vec[0], &e->vec[1], &e->vec[2], NULL, seed, 3,
                            4, 5, 0xFF);
#elif MLKEM_K == 4
  mlk_poly_getnoise_eta1_4x(&pv->vec[0], &pv->vec[1], &pv->vec[2], &pv->vec[3],
                            seed, 0, 1, 2, 3);
  mlk_poly_getnoise_eta1_4x(&e->vec[0], &e->vec[1], &e->vec[2], &e->vec[3],
                            seed, 4, 5, 6, 7);
#endif /* MLKEM_K == 4 */
}

/**
 * Compute and fill the sp, ep, and epp polynomial structures needed by
 * mlk_indcpa_enc(). Uses x4-batched versions of `poly_getnoise` to leverage
 * batched Keccak-f1600.
 *
 * @spec{Implements @[FIPS203, Algorithm 14 (K-PKE.Encrypt)] steps 9-16.}
 *
 * @param[out] sp    Output polynomial vector.
 * @param[out] ep    Output polynomial vector.
 * @param[out] epp   Output polynomial.
 * @param[in]  coins Seed bytes for sampling.
 */
static void mlk_enc_getnoise_eta1_eta2(mlk_polyvec *sp, mlk_polyvec *ep,
                                       mlk_poly *epp,
                                       const uint8_t coins[MLKEM_SYMBYTES])
__contract__(
  requires(memory_no_alias(sp, sizeof(mlk_polyvec)))
  requires(memory_no_alias(ep, sizeof(mlk_polyvec)))
  requires(memory_no_alias(epp, sizeof(mlk_poly)))
  requires(memory_no_alias(coins, MLKEM_SYMBYTES))
  assigns(memory_slice(sp, sizeof(mlk_polyvec)))
  assigns(memory_slice(ep, sizeof(mlk_polyvec)))
  assigns(memory_slice(epp, sizeof(mlk_poly)))
  ensures(forall(k0, 0, MLKEM_K, array_abs_bound(sp->vec[k0].coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1)))
  ensures(forall(k1, 0, MLKEM_K, array_abs_bound(ep->vec[k1].coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1)))
  ensures(array_abs_bound(epp->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1))
)
{
#if MLKEM_K == 2
  mlk_poly_getnoise_eta1122_4x(&sp->vec[0], &sp->vec[1], &ep->vec[0],
                               &ep->vec[1], coins, 0, 1, 2, 3);
  mlk_poly_getnoise_eta2(epp, coins, 4);
#elif MLKEM_K == 3
  /*
   * In this call, only the first three output buffers are needed,
   * so we pass NULL as the fourth parameter, and 0xFF as its dummy nonce.
   */
  mlk_poly_getnoise_eta1_4x(&sp->vec[0], &sp->vec[1], &sp->vec[2], NULL, coins,
                            0, 1, 2, 0xFF /* irrelevant */);
  /* The fourth output buffer in this call _is_ used. */
  mlk_poly_getnoise_eta2_4x(&ep->vec[0], &ep->vec[1], &ep->vec[2], epp, coins,
                            3, 4, 5, 6);
#elif MLKEM_K == 4
  mlk_poly_getnoise_eta1_4x(&sp->vec[0], &sp->vec[1], &sp->vec[2], &sp->vec[3],
                            coins, 0, 1, 2, 3);
  mlk_poly_getnoise_eta2_4x(&ep->vec[0], &ep->vec[1], &ep->vec[2], &ep->vec[3],
                            coins, 4, 5, 6, 7);
  mlk_poly_getnoise_eta2(epp, coins, 8);
#endif /* MLKEM_K == 4 */
}


/* Reference: `indcpa_keypair_derand()` in the reference implementation @[REF].
 *            - We use a different implementation of `gen_matrix()` which
 *              uses x4-batched Keccak-f1600 (see `mlk_gen_matrix()` above).
 *            - We use a mulcache to speed up matrix-vector multiplication.
 *            - We include buffer zeroization.
 */
MLK_INTERNAL_API
int mlk_indcpa_keypair_derand(uint8_t pk[MLKEM_INDCPA_PUBLICKEYBYTES],
                              uint8_t sk[MLKEM_INDCPA_SECRETKEYBYTES],
                              const uint8_t coins[MLKEM_SYMBYTES],
                              MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
{
  int ret = 0;
  const uint8_t *publicseed;
  const uint8_t *noiseseed;
  MLK_ALLOC(buf, uint8_t, 2 * MLKEM_SYMBYTES, context);
  MLK_ALLOC(coins_with_domain_separator, uint8_t, MLKEM_SYMBYTES + 1, context);
  MLK_ALLOC(a, mlk_polymat, 1, context);
  MLK_ALLOC(e, mlk_polyvec, 1, context);
  MLK_ALLOC(pkpv, mlk_polyvec, 1, context);
  MLK_ALLOC(skpv, mlk_polyvec, 1, context);
  MLK_ALLOC(skpv_cache, mlk_polyvec_mulcache, 1, context);

  if (buf == NULL || coins_with_domain_separator == NULL || a == NULL ||
      e == NULL || pkpv == NULL || skpv == NULL || skpv_cache == NULL)
  {
    ret = MLK_ERR_OUT_OF_MEMORY;
    goto cleanup;
  }

  publicseed = buf;
  noiseseed = buf + MLKEM_SYMBYTES;

  /* Concatenate coins with MLKEM_K for domain separation of security levels */
  mlk_memcpy(coins_with_domain_separator, coins, MLKEM_SYMBYTES);
  coins_with_domain_separator[MLKEM_SYMBYTES] = MLKEM_K;

  mlk_hash_g(buf, coins_with_domain_separator, MLKEM_SYMBYTES + 1);

  /*
   * Declassify the public seed.
   * Required to use it in conditional-branches in rejection sampling.
   * This is needed because all output of randombytes is marked as secret
   * (=undefined)
   */
  MLK_CT_TESTING_DECLASSIFY(publicseed, MLKEM_SYMBYTES);

  mlk_gen_matrix(a, publicseed, 0 /* no transpose */);

  mlk_keypair_getnoise_eta1(skpv, e, noiseseed);

  mlk_polyvec_ntt(skpv);
  mlk_polyvec_ntt(e);

  mlk_polyvec_mulcache_compute(skpv_cache, skpv);
  mlk_matvec_mul(pkpv, a, skpv, skpv_cache);
  mlk_polyvec_tomont(pkpv);

  mlk_polyvec_add(pkpv, e);
  mlk_polyvec_reduce(pkpv);
  mlk_polyvec_reduce(skpv);

  mlk_pack_sk(sk, skpv);
  mlk_pack_pk(pk, pkpv, publicseed);

cleanup:
  /* Specification: Partially implements
   * @[FIPS203, Section 3.3, Destruction of intermediate values] */
  MLK_FREE(skpv_cache, mlk_polyvec_mulcache, 1, context);
  MLK_FREE(skpv, mlk_polyvec, 1, context);
  MLK_FREE(pkpv, mlk_polyvec, 1, context);
  MLK_FREE(e, mlk_polyvec, 1, context);
  MLK_FREE(a, mlk_polymat, 1, context);
  MLK_FREE(coins_with_domain_separator, uint8_t, MLKEM_SYMBYTES + 1, context);
  MLK_FREE(buf, uint8_t, 2 * MLKEM_SYMBYTES, context);
  return ret;
}

/* Reference: `indcpa_enc()` in the reference implementation @[REF].
 *            - We use x4-batched versions of `poly_getnoise` to leverage
 *              batched x4-batched Keccak-f1600.
 *            - We use a different implementation of `gen_matrix()` which
 *              uses x4-batched Keccak-f1600 (see `mlk_gen_matrix()` above).
 *            - We use a mulcache to speed up matrix-vector multiplication.
 *            - We include buffer zeroization.
 */
MLK_INTERNAL_API
int mlk_indcpa_enc(uint8_t c[MLKEM_INDCPA_BYTES],
                   const uint8_t m[MLKEM_INDCPA_MSGBYTES],
                   const uint8_t pk[MLKEM_INDCPA_PUBLICKEYBYTES],
                   const uint8_t coins[MLKEM_SYMBYTES],
                   MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
{
  int ret = 0;
  MLK_ALLOC(seed, uint8_t, MLKEM_SYMBYTES, context);
  MLK_ALLOC(at, mlk_polymat, 1, context);
  MLK_ALLOC(sp, mlk_polyvec, 1, context);
  MLK_ALLOC(pkpv, mlk_polyvec, 1, context);
  MLK_ALLOC(ep, mlk_polyvec, 1, context);
  MLK_ALLOC(b, mlk_polyvec, 1, context);
  MLK_ALLOC(v, mlk_poly, 1, context);
  MLK_ALLOC(k, mlk_poly, 1, context);
  MLK_ALLOC(epp, mlk_poly, 1, context);
  MLK_ALLOC(sp_cache, mlk_polyvec_mulcache, 1, context);

  if (seed == NULL || at == NULL || sp == NULL || pkpv == NULL || ep == NULL ||
      b == NULL || v == NULL || k == NULL || epp == NULL || sp_cache == NULL)
  {
    ret = MLK_ERR_OUT_OF_MEMORY;
    goto cleanup;
  }

  mlk_unpack_pk(pkpv, seed, pk);
  mlk_poly_frommsg(k, m);

  /*
   * Declassify the public seed.
   * Required to use it in conditional-branches in rejection sampling.
   * This is needed because in re-encryption the publicseed originated from sk
   * which is marked undefined.
   */
  MLK_CT_TESTING_DECLASSIFY(seed, MLKEM_SYMBYTES);

  mlk_gen_matrix(at, seed, 1 /* transpose */);

  mlk_enc_getnoise_eta1_eta2(sp, ep, epp, coins);

  mlk_polyvec_ntt(sp);

  mlk_polyvec_mulcache_compute(sp_cache, sp);
  mlk_matvec_mul(b, at, sp, sp_cache);
  mlk_polyvec_basemul_acc_montgomery_cached(v, pkpv, sp, sp_cache);

  mlk_polyvec_invntt_tomont(b);
  mlk_poly_invntt_tomont(v);

  mlk_polyvec_add(b, ep);
  mlk_poly_add(v, epp);
  mlk_poly_add(v, k);

  mlk_polyvec_reduce(b);
  mlk_poly_reduce(v);

  mlk_pack_ciphertext(c, b, v);

cleanup:
  /* Specification: Partially implements
   * @[FIPS203, Section 3.3, Destruction of intermediate values] */
  MLK_FREE(sp_cache, mlk_polyvec_mulcache, 1, context);
  MLK_FREE(epp, mlk_poly, 1, context);
  MLK_FREE(k, mlk_poly, 1, context);
  MLK_FREE(v, mlk_poly, 1, context);
  MLK_FREE(b, mlk_polyvec, 1, context);
  MLK_FREE(ep, mlk_polyvec, 1, context);
  MLK_FREE(pkpv, mlk_polyvec, 1, context);
  MLK_FREE(sp, mlk_polyvec, 1, context);
  MLK_FREE(at, mlk_polymat, 1, context);
  MLK_FREE(seed, uint8_t, MLKEM_SYMBYTES, context);
  return ret;
}

/* Reference: `indcpa_dec()` in the reference implementation @[REF].
 *            - We use a mulcache for the scalar product.
 *            - We include buffer zeroization. */
MLK_INTERNAL_API
int mlk_indcpa_dec(uint8_t m[MLKEM_INDCPA_MSGBYTES],
                   const uint8_t c[MLKEM_INDCPA_BYTES],
                   const uint8_t sk[MLKEM_INDCPA_SECRETKEYBYTES],
                   MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
{
  int ret = 0;
  MLK_ALLOC(b, mlk_polyvec, 1, context);
  MLK_ALLOC(skpv, mlk_polyvec, 1, context);
  MLK_ALLOC(v, mlk_poly, 1, context);
  MLK_ALLOC(sb, mlk_poly, 1, context);
  MLK_ALLOC(b_cache, mlk_polyvec_mulcache, 1, context);

  if (b == NULL || skpv == NULL || v == NULL || sb == NULL || b_cache == NULL)
  {
    ret = MLK_ERR_OUT_OF_MEMORY;
    goto cleanup;
  }

  mlk_unpack_ciphertext(b, v, c);
  mlk_unpack_sk(skpv, sk);

  mlk_polyvec_ntt(b);
  mlk_polyvec_mulcache_compute(b_cache, b);
  mlk_polyvec_basemul_acc_montgomery_cached(sb, skpv, b, b_cache);
  mlk_poly_invntt_tomont(sb);

  mlk_poly_sub(v, sb);
  mlk_poly_reduce(v);

  mlk_poly_tomsg(m, v);

cleanup:
  /* Specification: Partially implements
   * @[FIPS203, Section 3.3, Destruction of intermediate values] */
  MLK_FREE(b_cache, mlk_polyvec_mulcache, 1, context);
  MLK_FREE(sb, mlk_poly, 1, context);
  MLK_FREE(v, mlk_poly, 1, context);
  MLK_FREE(skpv, mlk_polyvec, 1, context);
  MLK_FREE(b, mlk_polyvec, 1, context);
  return ret;
}

/* To facilitate single-compilation-unit (SCU) builds, undefine all macros.
 * Don't modify by hand -- this is auto-generated by scripts/autogen. */
#undef mlk_pack_pk
#undef mlk_unpack_pk
#undef mlk_pack_sk
#undef mlk_unpack_sk
#undef mlk_pack_ciphertext
#undef mlk_unpack_ciphertext
#undef mlk_matvec_mul
#undef mlk_polyvec_permute_bitrev_to_custom
#undef mlk_polymat_permute_bitrev_to_custom
#undef mlk_keypair_getnoise_eta1
#undef mlk_enc_getnoise_eta1_eta2
```

### `mlkem/src/poly.c`

````c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [NeonNTT]
 *   Neon NTT: Faster Dilithium, Kyber, and Saber on Cortex-A72 and Apple M1
 *   Becker, Hwang, Kannwischer, Yang, Yang
 *   https://eprint.iacr.org/2021/986
 *
 * - [REF]
 *   CRYSTALS-Kyber C reference implementation
 *   Bos, Ducas, Kiltz, Lepoint, Lyubashevsky, Schanck, Schwabe, Seiler, Stehlé
 *   https://github.com/pq-crystals/kyber/tree/main/ref
 */

#include "common.h"
#if !defined(MLK_CONFIG_MULTILEVEL_NO_SHARED)


#include "cbmc.h"
#include "debug.h"
#include "poly.h"
#include "sampling.h"
#include "symmetric.h"
#include "verify.h"

/**
 * Montgomery multiplication modulo MLKEM_Q.
 *
 * @reference{`fqmul()` in the reference implementation @[REF].}
 *
 * @param a First factor. Can be any int16_t.
 * @param b Second factor. Must be signed canonical
 *          (abs value < (MLKEM_Q+1)/2).
 *
 * @return 16-bit integer congruent to a*b*R^{-1} mod MLKEM_Q, and
 *         smaller than MLKEM_Q in absolute value.
 */
static MLK_INLINE int16_t mlk_fqmul(int16_t a, int16_t b)
__contract__(
  requires(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF)
  ensures(return_value > -MLKEM_Q && return_value < MLKEM_Q)
)
{
  int16_t res;
  mlk_assert_abs_bound(&b, 1, MLKEM_Q_HALF);

  res = mlk_montgomery_reduce((int32_t)a * (int32_t)b);
  /* Bounds:
   * |res| <= ceil(|a| * |b| / 2^16) + (MLKEM_Q + 1) / 2
   *       <= ceil(2^15 * ((MLKEM_Q - 1)/2) / 2^16) + (MLKEM_Q + 1) / 2
   *       <= ceil((MLKEM_Q - 1) / 4) + (MLKEM_Q + 1) / 2
   *        < MLKEM_Q
   */

  mlk_assert_abs_bound(&res, 1, MLKEM_Q);
  return res;
}

/**
 * Barrett reduction; given a 16-bit integer a, computes the centered
 * representative congruent to a mod MLKEM_Q in [-(MLKEM_Q-1)/2, (MLKEM_Q-1)/2].
 *
 * @reference{`barrett_reduce()` in the reference implementation @[REF].}
 *
 * @param a Input integer to be reduced.
 *
 * @return Integer in [-(MLKEM_Q-1)/2, (MLKEM_Q-1)/2] congruent to @p a modulo
 *         MLKEM_Q.
 */
static MLK_INLINE int16_t mlk_barrett_reduce(int16_t a)
__contract__(
  ensures(return_value > -MLKEM_Q_HALF && return_value < MLKEM_Q_HALF)
)
{
  /* Barrett reduction approximates
   * ```
   *     round(a/MLKEM_Q)
   *   = round(a*(2^N/MLKEM_Q))/2^N)
   *  ~= round(a*round(2^N/MLKEM_Q)/2^N)
   * ```
   * Here, we pick N=26.
   */
  const int32_t magic = 20159; /* check-magic: 20159 == round(2^26 / MLKEM_Q) */

  /*
   * PORTABILITY: Right-shift on a signed integer is
   * implementation-defined for negative left argument.
   * Here, we assume it's sign-preserving "arithmetic" shift right.
   * See (C99 6.5.7 (5))
   */
  const int32_t t = (magic * a + ((int32_t)1 << 25)) >> 26;

  /*
   * t is in -10 .. +10, so we need 32-bit math to
   * evaluate t * MLKEM_Q and the subsequent subtraction
   */
  int16_t res = (int16_t)(a - t * MLKEM_Q);

  mlk_assert_abs_bound(&res, 1, MLKEM_Q_HALF);
  return res;
}

/* Reference: `poly_tomont()` in the reference implementation @[REF]. */
MLK_STATIC_TESTABLE void mlk_poly_tomont_c(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
)
{
  unsigned i;
  const int16_t f = 1353; /* check-magic: 1353 == signed_mod(2^32, MLKEM_Q) */
  for (i = 0; i < MLKEM_N; i++)
  __loop__(
    invariant(i <= MLKEM_N)
    invariant(array_abs_bound(r->coeffs, 0, i, MLKEM_Q))
    decreases(MLKEM_N - i))
  {
    r->coeffs[i] = mlk_fqmul(r->coeffs[i], f);
  }

  mlk_assert_abs_bound(r, MLKEM_N, MLKEM_Q);
}

MLK_INTERNAL_API
void mlk_poly_tomont(mlk_poly *r)
{
#if defined(MLK_USE_NATIVE_POLY_TOMONT)
  int ret;
  ret = mlk_poly_tomont_native(r->coeffs);
  if (ret == MLK_NATIVE_FUNC_SUCCESS)
  {
    mlk_assert_abs_bound(r, MLKEM_N, MLKEM_Q);
    return;
  }
#endif /* MLK_USE_NATIVE_POLY_TOMONT */

  mlk_poly_tomont_c(r);
}

/**
 * Constant-time conversion of signed representatives modulo MLKEM_Q within
 * range [-(MLKEM_Q-1), MLKEM_Q-1] into unsigned representatives within
 * range [0, MLKEM_Q-1].
 *
 * @reference{Not present in the reference implementation @[REF]. Used here
 * to implement different semantics of `poly_reduce()`; see below. In the
 * reference implementation @[REF] this logic is part of all compression
 * functions (see `compress.c`).}
 *
 * @param c Signed coefficient to be converted.
 *
 * @return Unsigned representative in [0, MLKEM_Q).
 */
static MLK_INLINE int16_t mlk_scalar_signed_to_unsigned_q(int16_t c)
__contract__(
  requires(c > -MLKEM_Q && c < MLKEM_Q)
  ensures(return_value >= 0 && return_value < MLKEM_Q)
  ensures(return_value == (int32_t)c + (((int32_t)c < 0) * MLKEM_Q)))
{
  mlk_assert_abs_bound(&c, 1, MLKEM_Q);

  /* Add MLKEM_Q if c is negative, but in constant time.
   *
   * Note that c + MLKEM_Q does not overflow in int16_t,
   * so the cast to uint16_t is safe. */
  c = mlk_ct_sel_int16((int16_t)(c + MLKEM_Q), c, mlk_ct_cmask_neg_i16(c));

  mlk_assert_bound(&c, 1, 0, MLKEM_Q);
  return c;
}

/* Reference: `poly_reduce()` in the reference implementation @[REF]
 *            - We use _unsigned_ canonical outputs, while the reference
 *              implementation uses _signed_ canonical outputs.
 *              Accordingly, we need a conditional addition of MLKEM_Q
 *              here to go from signed to unsigned representatives.
 *              This conditional addition is then dropped from all
 *              polynomial compression functions instead (see `compress.c`). */
MLK_STATIC_TESTABLE void mlk_poly_reduce_c(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
)
{
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  __loop__(
    invariant(i <= MLKEM_N)
    invariant(array_bound(r->coeffs, 0, i, 0, MLKEM_Q))
    decreases(MLKEM_N - i))
  {
    /* Barrett reduction, giving signed canonical representative */
    int16_t t = mlk_barrett_reduce(r->coeffs[i]);
    /* Conditional addition to get unsigned canonical representative */
    r->coeffs[i] = mlk_scalar_signed_to_unsigned_q(t);
  }

  mlk_assert_bound(r, MLKEM_N, 0, MLKEM_Q);
}

MLK_INTERNAL_API
void mlk_poly_reduce(mlk_poly *r)
{
#if defined(MLK_USE_NATIVE_POLY_REDUCE)
  int ret;
  ret = mlk_poly_reduce_native(r->coeffs);
  if (ret == MLK_NATIVE_FUNC_SUCCESS)
  {
    mlk_assert_bound(r, MLKEM_N, 0, MLKEM_Q);
    return;
  }
#endif /* MLK_USE_NATIVE_POLY_REDUCE */

  mlk_poly_reduce_c(r);
}

/* Reference: `poly_add()` in the reference implementation @[REF].
 *            - We use destructive version (output=first input) to avoid
 *              reasoning about aliasing in the CBMC specification */
MLK_INTERNAL_API
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;
  for (i = 0; i < MLKEM_N; i++)
  __loop__(
    invariant(i <= MLKEM_N)
    invariant(forall(k0, i, MLKEM_N, r->coeffs[k0] == loop_entry(*r).coeffs[k0]))
    invariant(forall(k1, 0, i, r->coeffs[k1] == loop_entry(*r).coeffs[k1] + b->coeffs[k1]))
    decreases(MLKEM_N - i))
  {
    /* The preconditions imply that the addition stays within int16_t. */
    r->coeffs[i] = (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }
}

/* Reference: `poly_sub()` in the reference implementation @[REF].
 *            - We use destructive version (output=first input) to avoid
 *              reasoning about aliasing in the CBMC specification */
MLK_INTERNAL_API
void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;
  for (i = 0; i < MLKEM_N; i++)
  __loop__(
    invariant(i <= MLKEM_N)
    invariant(forall(k0, i, MLKEM_N, r->coeffs[k0] == loop_entry(*r).coeffs[k0]))
    invariant(forall(k1, 0, i, r->coeffs[k1] == loop_entry(*r).coeffs[k1] - b->coeffs[k1]))
    decreases(MLKEM_N - i))
  {
    /* The preconditions imply that the subtraction stays within int16_t. */
    r->coeffs[i] = (int16_t)(r->coeffs[i] - b->coeffs[i]);
  }
}

#include "zetas.inc"

/* Reference: Does not exist in the reference implementation @[REF].
 *            - The reference implementation does not use a
 *              multiplication cache ('mulcache'). This idea originates
 *              from @[NeonNTT] and is used at the C level here. */
MLK_STATIC_TESTABLE void mlk_poly_mulcache_compute_c(mlk_poly_mulcache *x,
                                                     const mlk_poly *a)
__contract__(
  requires(memory_no_alias(x, sizeof(mlk_poly_mulcache)))
  requires(memory_no_alias(a, sizeof(mlk_poly)))
  assigns(memory_slice(x, sizeof(mlk_poly_mulcache)))
)
{
  unsigned i;
  for (i = 0; i < MLKEM_N / 4; i++)
  __loop__(
    invariant(i <= MLKEM_N / 4)
    invariant(array_abs_bound(x->coeffs, 0, 2 * i, MLKEM_Q))
    decreases(MLKEM_N / 4 - i))
  {
    x->coeffs[2 * i + 0] = mlk_fqmul(a->coeffs[4 * i + 1], mlk_zetas[64 + i]);
    /* The values in zeta table are <= MLKEM_Q in absolute value,
     * so the negation in int16_t is safe. */
    x->coeffs[2 * i + 1] =
        mlk_fqmul(a->coeffs[4 * i + 3], (int16_t)(-mlk_zetas[64 + i]));
  }

  /*
   * This bound is true for the C implementation, but not needed
   * in the higher level bounds reasoning. It is thus omitted
   * from the spec to not unnecessarily constrain native
   * implementations, but checked here nonetheless.
   */
  mlk_assert_abs_bound(x, MLKEM_N / 2, MLKEM_Q);
}

MLK_INTERNAL_API
void mlk_poly_mulcache_compute(mlk_poly_mulcache *x, const mlk_poly *a)
{
#if defined(MLK_USE_NATIVE_POLY_MULCACHE_COMPUTE)
  int ret;
  ret = mlk_poly_mulcache_compute_native(x->coeffs, a->coeffs);
  if (ret == MLK_NATIVE_FUNC_SUCCESS)
  {
    return;
  }
#endif /* MLK_USE_NATIVE_POLY_MULCACHE_COMPUTE */

  mlk_poly_mulcache_compute_c(x, a);
}

/*
 * Computes a block CT butterflies with a fixed twiddle factor,
 * using Montgomery multiplication.
 * Parameters:
 * - r: Pointer to base of polynomial (_not_ the base of butterfly block)
 * - root: Twiddle factor to use for the butterfly. This must be in
 *         Montgomery form and signed canonical.
 * - start: Offset to the beginning of the butterfly block
 * - len: Index difference between coefficients subject to a butterfly
 * - bound: Ghost variable describing coefficient bound: Prior to `start`,
 *          coefficients must be bound by `bound + MLKEM_Q`. Post `start`,
 *          they must be bound by `bound`.
 * When this function returns, output coefficients in the index range
 * [start, start+2*len) have bound bumped to `bound + MLKEM_Q`.
 * Example:
 * - start=8, len=4
 *   This would compute the following four butterflies
 *          8     --    12
 *             9    --     13
 *                10   --     14
 *                   11   --     15
 * - start=4, len=2
 *   This would compute the following two butterflies
 *          4 -- 6
 *             5 -- 7
 */

/* Reference: Embedded in `ntt()` in the reference implementation @[REF]. */
static void mlk_ntt_butterfly_block(int16_t r[MLKEM_N], int16_t zeta,
                                    unsigned start, unsigned len,
                                    unsigned bound)
__contract__(
  requires(start < MLKEM_N)
  requires(1 <= len && len <= MLKEM_N / 2 && start + 2 * len <= MLKEM_N)
  requires(0 <= bound && bound < INT16_MAX - MLKEM_Q)
  requires(-MLKEM_Q_HALF < zeta && zeta < MLKEM_Q_HALF)
  requires(memory_no_alias(r, sizeof(int16_t) * MLKEM_N))
  requires(array_abs_bound(r, 0, start, bound + MLKEM_Q))
  requires(array_abs_bound(r, start, MLKEM_N, bound))
  assigns(memory_slice(r, sizeof(int16_t) * MLKEM_N))
  ensures(array_abs_bound(r, 0, start + 2*len, bound + MLKEM_Q))
  ensures(array_abs_bound(r, start + 2 * len, MLKEM_N, bound)))
{
  /* `bound` is a ghost variable only needed in the CBMC specification */
  unsigned j;
  ((void)bound);
  for (j = start; j < start + len; j++)
  __loop__(
    invariant(start <= j && j <= start + len)
    /*
     * Coefficients are updated in strided pairs, so the bounds for the
     * intermediate states alternate twice between the old and new bound
     */
    invariant(array_abs_bound(r, 0,           j,           bound + MLKEM_Q))
    invariant(array_abs_bound(r, j,           start + len, bound))
    invariant(array_abs_bound(r, start + len, j + len,     bound + MLKEM_Q))
    invariant(array_abs_bound(r, j + len,     MLKEM_N,     bound))
    decreases(start + len - j))
  {
    int16_t t;
    t = mlk_fqmul(r[j + len], zeta);
    /* The precondition implies that the arithmetic does not overflow. */
    r[j + len] = (int16_t)(r[j] - t);
    r[j] = (int16_t)(r[j] + t);
  }
}

/*
 * Compute one layer of forward NTT
 * Parameters:
 * - r: Pointer to base of polynomial
 * - layer: Variable indicating which layer is being applied.
 */

/* Reference: Embedded in `ntt()` in the reference implementation @[REF]. */
static void mlk_ntt_layer(int16_t r[MLKEM_N], unsigned layer)
__contract__(
  requires(memory_no_alias(r, sizeof(int16_t) * MLKEM_N))
  requires(1 <= layer && layer <= 7)
  requires(array_abs_bound(r, 0, MLKEM_N, layer * MLKEM_Q))
  assigns(memory_slice(r, sizeof(int16_t) * MLKEM_N))
  ensures(array_abs_bound(r, 0, MLKEM_N, (layer + 1) * MLKEM_Q)))
{
  unsigned start, k, len;
  /* Twiddle factors for layer n are at indices 2^(n-1)..2^n-1. */
  k = 1u << (layer - 1);
  len = (unsigned)MLKEM_N >> layer;
  for (start = 0; start < MLKEM_N; start += 2 * len)
  __loop__(
    invariant(start < MLKEM_N + 2 * len)
    invariant(k <= MLKEM_N / 2 && 2 * len * k == start + MLKEM_N)
    invariant(array_abs_bound(r, 0, start, layer * MLKEM_Q + MLKEM_Q))
    invariant(array_abs_bound(r, start, MLKEM_N, layer * MLKEM_Q))
    decreases(MLKEM_N - start))
  {
    int16_t zeta = mlk_zetas[k++];
    mlk_ntt_butterfly_block(r, zeta, start, len, layer * MLKEM_Q);
  }
}

/*
 * Compute full forward NTT
 * NOTE: This particular implementation satisfies a much tighter
 * bound on the output coefficients (5*q) than the contractual one (8*q),
 * but this is not needed in the calling code. Should we change the
 * base multiplication strategy to require smaller NTT output bounds,
 * the proof may need strengthening.
 */

/* Reference: `ntt()` in the reference implementation @[REF].
 * - Iterate over `layer` instead of `len` in the outer loop
 *   to simplify computation of zeta index. */
MLK_STATIC_TESTABLE void mlk_poly_ntt_c(mlk_poly *p)
__contract__(
  requires(memory_no_alias(p, sizeof(mlk_poly)))
  requires(array_abs_bound(p->coeffs, 0, MLKEM_N, MLKEM_Q))
  assigns(memory_slice(p, sizeof(mlk_poly)))
  ensures(array_abs_bound(p->coeffs, 0, MLKEM_N, MLK_NTT_BOUND))
)
{
  unsigned layer;
  int16_t *r;

  mlk_assert_abs_bound(p, MLKEM_N, MLKEM_Q);

  r = p->coeffs;

  for (layer = 1; layer <= 7; layer++)
  __loop__(
    invariant(1 <= layer && layer <= 8)
    invariant(array_abs_bound(r, 0, MLKEM_N, layer * MLKEM_Q))
    decreases(8 - layer))
  {
    mlk_ntt_layer(r, layer);
  }

  /* Check the stronger bound */
  mlk_assert_abs_bound(p, MLKEM_N, MLK_NTT_BOUND);
}

MLK_INTERNAL_API
void mlk_poly_ntt(mlk_poly *r)
{
#if defined(MLK_USE_NATIVE_NTT)
  int ret;
  mlk_assert_abs_bound(r, MLKEM_N, MLKEM_Q);
  ret = mlk_ntt_native(r->coeffs);
  if (ret == MLK_NATIVE_FUNC_SUCCESS)
  {
    mlk_assert_abs_bound(r, MLKEM_N, MLK_NTT_BOUND);
    return;
  }
#endif /* MLK_USE_NATIVE_NTT */

  mlk_poly_ntt_c(r);
}


/* Compute one layer of inverse NTT */

/* Reference: Embedded into `invntt()` in the reference implementation @[REF] */
static void mlk_invntt_layer(int16_t *r, unsigned layer)
__contract__(
  requires(memory_no_alias(r, sizeof(int16_t) * MLKEM_N))
  requires(1 <= layer && layer <= 7)
  requires(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
  assigns(memory_slice(r, sizeof(int16_t) * MLKEM_N))
  ensures(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q)))
{
  unsigned start, k, len;
  len = (unsigned)MLKEM_N >> layer;
  k = (1u << layer) - 1;
  for (start = 0; start < MLKEM_N; start += 2 * len)
  __loop__(
    invariant(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
    invariant(start <= MLKEM_N && k <= 127)
    /* Normalised form of k == MLKEM_N / len - 1 - start / (2 * len) */
    invariant(2 * len * k + start == 2 * MLKEM_N - 2 * len)
    decreases(MLKEM_N - start))
  {
    unsigned j;
    int16_t zeta = mlk_zetas[k--];
    for (j = start; j < start + len; j++)
    __loop__(
      invariant(start <= j && j <= start + len)
      invariant(start <= MLKEM_N && k <= 127)
      invariant(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
      decreases(start + len - j))
    {
      int16_t t = r[j];
      /* The preconditions imply that the arithmetic does not overflow. */
      r[j] = mlk_barrett_reduce((int16_t)(t + r[j + len]));
      r[j + len] = (int16_t)(r[j + len] - t);
      r[j + len] = mlk_fqmul(r[j + len], zeta);
    }
  }
}

/* Reference: `invntt()` in the reference implementation @[REF]
 *            - We normalize at the beginning of the inverse NTT,
 *              while the reference implementation normalizes at
 *              the end. This allows us to drop a call to `poly_reduce()`
 *              from the base multiplication. */
MLK_STATIC_TESTABLE void mlk_poly_invntt_tomont_c(mlk_poly *p)
__contract__(
  requires(memory_no_alias(p, sizeof(mlk_poly)))
  assigns(memory_slice(p, sizeof(mlk_poly)))
  ensures(array_abs_bound(p->coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND))
)
{
  unsigned j, layer;
  const int16_t f = 1441; /* check-magic: 1441 == pow(2,32 - 7,MLKEM_Q) */
  int16_t *r = p->coeffs;

  /*
   * Scale input polynomial to account for Montgomery factor
   * and NTT twist. This also brings coefficients down to
   * absolute value < MLKEM_Q.
   */
  for (j = 0; j < MLKEM_N; j++)
  __loop__(
    invariant(j <= MLKEM_N)
    invariant(array_abs_bound(r, 0, j, MLKEM_Q))
    decreases(MLKEM_N - j))
  {
    r[j] = mlk_fqmul(r[j], f);
  }

  /* Run the invNTT layers */
  for (layer = 7; layer > 0; layer--)
  __loop__(
    invariant(0 <= layer && layer < 8)
    invariant(array_abs_bound(r, 0, MLKEM_N, MLKEM_Q))
    decreases(layer))
  {
    mlk_invntt_layer(r, layer);
  }

  mlk_assert_abs_bound(p, MLKEM_N, MLK_INVNTT_BOUND);
}

MLK_INTERNAL_API
void mlk_poly_invntt_tomont(mlk_poly *r)
{
#if defined(MLK_USE_NATIVE_INTT)
  int ret;
  ret = mlk_intt_native(r->coeffs);
  if (ret == MLK_NATIVE_FUNC_SUCCESS)
  {
    mlk_assert_abs_bound(r, MLKEM_N, MLK_INVNTT_BOUND);
    return;
  }
#endif /* MLK_USE_NATIVE_INTT */

  mlk_poly_invntt_tomont_c(r);
}

#else /* !MLK_CONFIG_MULTILEVEL_NO_SHARED */

MLK_EMPTY_CU(mlk_poly)

#endif /* MLK_CONFIG_MULTILEVEL_NO_SHARED */
````

### `mlkem/src/poly.h`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [FIPS203]
 *   FIPS 203 Module-Lattice-Based Key-Encapsulation Mechanism Standard
 *   National Institute of Standards and Technology
 *   https://csrc.nist.gov/pubs/fips/203/final
 */

#ifndef MLK_POLY_H
#define MLK_POLY_H


#include "cbmc.h"
#include "common.h"
#include "debug.h"
#include "verify.h"

/* Absolute exclusive upper bound for the output of the inverse NTT */
#define MLK_INVNTT_BOUND (8 * MLKEM_Q)

/* Absolute exclusive upper bound for the output of the forward NTT */
#define MLK_NTT_BOUND (8 * MLKEM_Q)

/**
 * Element of R_q = Z_q[X]/(X^n + 1). Represents polynomial
 * coeffs[0] + X*coeffs[1] + X^2*coeffs[2] + ... + X^{n-1}*coeffs[n-1].
 */
typedef struct
{
  int16_t coeffs[MLKEM_N]; /**< Polynomial coefficients. */
} MLK_ALIGN mlk_poly;

/**
 * INTERNAL representation of precomputed data speeding up
 * the base multiplication of two polynomials in NTT domain.
 */
typedef struct
{
  int16_t coeffs[MLKEM_N >> 1]; /**< Cached coefficients. */
} MLK_ALIGN mlk_poly_mulcache;

/**
 * Generic Montgomery reduction; given a 32-bit integer a, computes a 16-bit
 * integer congruent to a * R^-1 mod MLKEM_Q, where R=2^16.
 *
 * @param a Input integer to be reduced, of absolute value smaller or equal
 *          to INT32_MAX - 2^15 * MLKEM_Q.
 *
 * @return Integer congruent to a * R^-1 modulo MLKEM_Q, with absolute value
 *         <= ceil(|a| / 2^16) + (MLKEM_Q + 1)/2.
 */
static MLK_ALWAYS_INLINE int16_t mlk_montgomery_reduce(int32_t a)
__contract__(
    requires(a < +(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)) &&
             a > -(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)))
    /* We don't attempt to express an input-dependent output bound
     * as the post-condition here. There are two call-sites for this
     * function:
     * - The base multiplication: Here, we need no output bound.
     * - mlk_fqmul: Here, we inline this function and prove another spec
     *          for mlk_fqmul which does have a post-condition bound. */
)
{
  /* check-magic: 62209 == unsigned_mod(pow(MLKEM_Q, -1, 2^16), 2^16) */
  const uint32_t QINV = 62209;

  /* Compute a*q^{-1} mod 2^16 in unsigned representatives. */
  const uint16_t a_reduced = mlk_cast_int32_to_uint16(a);
  const uint16_t a_inverted = (a_reduced * QINV) & UINT16_MAX;

  /* Lift to signed canonical representative mod 2^16. */
  const int16_t t = mlk_cast_uint16_to_int16(a_inverted);

  int32_t r;

  mlk_assert(a < +(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)) &&
             a > -(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)));

  r = a - ((int32_t)t * MLKEM_Q);

  /*
   * PORTABILITY: Right-shift on a signed integer is, strictly-speaking,
   * implementation-defined for negative left argument. Here,
   * we assume it's sign-preserving "arithmetic" shift right. (C99 6.5.7 (5))
   */
  r = r >> 16;
  /* Bounds: |r >> 16| <= ceil(|r| / 2^16)
   *                   <= ceil(|a| / 2^16 + MLKEM_Q / 2)
   *                   <= ceil(|a| / 2^16) + (MLKEM_Q + 1) / 2
   *
   * (Note that |a >> n| = ceil(|a| / 2^16) for negative a)
   */
  return (int16_t)r;
}

#define mlk_poly_tomont MLK_NAMESPACE(poly_tomont)
/**
 * In-place conversion of all coefficients of a polynomial from the normal
 * domain to the Montgomery domain.
 *
 * Bounds: output < MLKEM_Q in absolute value.
 *
 * @spec{Internal normalization required in `mlk_indcpa_keypair_derand` as
 * part of matrix-vector multiplication @[FIPS203, Algorithm 13, K-PKE.KeyGen,
 * L18].}
 *
 * @param[in,out] r Input/output polynomial.
 */
MLK_INTERNAL_API
void mlk_poly_tomont(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
);

#define mlk_poly_mulcache_compute MLK_NAMESPACE(poly_mulcache_compute)
/**
 * Compute the mulcache for a polynomial in NTT domain.
 *
 * The mulcache of a degree-2 polynomial b := b0 + b1*X in Fq[X]/(X^2-zeta)
 * is the value b1*zeta, needed when computing products of b in
 * Fq[X]/(X^2-zeta).
 *
 * The mulcache of a polynomial in NTT domain -- which is a 128-tuple of
 * degree-2 polynomials in Fq[X]/(X^2-zeta), for varying zeta, is the
 * 128-tuple of mulcaches of those polynomials.
 *
 * @spec{Caches `b_1 * \gamma` in @[FIPS203, Algorithm 12, BaseCaseMultiply,
 * L1].}
 *
 * @param[out] x Mulcache to be populated.
 * @param[in]  a Input polynomial.
 */
/*
 * NOTE: The default C implementation of this function populates
 * the mulcache with values in (-q,q), but this is not needed for the
 * higher level safety proofs, and thus not part of the spec.
 */
MLK_INTERNAL_API
void mlk_poly_mulcache_compute(mlk_poly_mulcache *x, const mlk_poly *a)
__contract__(
  requires(memory_no_alias(x, sizeof(mlk_poly_mulcache)))
  requires(memory_no_alias(a, sizeof(mlk_poly)))
  assigns(memory_slice(x, sizeof(mlk_poly_mulcache)))
);

#define mlk_poly_reduce MLK_NAMESPACE(poly_reduce)
/**
 * Convert a polynomial to unsigned canonical representatives.
 *
 * The input coefficients can be arbitrary integers in int16_t. The output
 * coefficients are in [0,1,..,MLKEM_Q-1].
 *
 * @spec{Normalizes on unsigned canonical representatives ahead of calling
 * @[FIPS203, Compress_d, Eq (4.7)]. This is not made explicit in FIPS 203.}
 *
 * @param[in,out] r Input/output polynomial.
 */
/*
 * NOTE: The semantics of mlk_poly_reduce() is different in
 * the reference implementation, which requires
 * signed canonical output data. Unsigned canonical
 * outputs are better suited to the only remaining
 * use of mlk_poly_reduce() in the context of (de)serialization.
 */
MLK_INTERNAL_API
void mlk_poly_reduce(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
);

#define mlk_poly_add MLK_NAMESPACE(poly_add)
/**
 * Add two polynomials in place.
 *
 * The coefficients of @p r and @p b must be such that the addition does not
 * overflow. Otherwise, the behaviour of this function is undefined.
 *
 * @spec{@[FIPS203, 2.4.5, Arithmetic With Polynomials and NTT
 * Representations]. Used in @[FIPS203, Algorithm 14 (K-PKE.Encrypt), L21].}
 *
 * @param[in,out] r Input-output polynomial to be added to.
 * @param[in]     b Input polynomial that should be added to @p r. Must be
 *                  disjoint from @p r.
 */
/*
 * NOTE: The reference implementation uses a 3-argument mlk_poly_add.
 * We specialize to the accumulator form to avoid reasoning about aliasing.
 */
MLK_INTERNAL_API
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(b, sizeof(mlk_poly)))
  requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] + b->coeffs[k0] <= INT16_MAX))
  requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] + b->coeffs[k1] >= INT16_MIN))
  ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] + b->coeffs[k]))
  assigns(memory_slice(r, sizeof(mlk_poly)))
);

#define mlk_poly_sub MLK_NAMESPACE(poly_sub)
/**
 * Subtract two polynomials; no modular reduction is performed.
 *
 * @spec{@[FIPS203, 2.4.5, Arithmetic With Polynomials and NTT
 * Representations]. Used in @[FIPS203, Algorithm 15, K-PKE.Decrypt, L6].}
 *
 * @param[in,out] r Input-output polynomial to be subtracted from.
 * @param[in]     b Second input polynomial.
 */
/*
 * NOTE: The reference implementation uses a 3-argument mlk_poly_sub.
 * We specialize to the accumulator form to avoid reasoning about aliasing.
 */
MLK_INTERNAL_API
void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(b, sizeof(mlk_poly)))
  requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] - b->coeffs[k0] <= INT16_MAX))
  requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] - b->coeffs[k1] >= INT16_MIN))
  ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] - b->coeffs[k]))
  assigns(memory_slice(r, sizeof(mlk_poly)))
);

#define mlk_poly_ntt MLK_NAMESPACE(poly_ntt)
/**
 * Compute the negacyclic number-theoretic transform (NTT) of a polynomial
 * in place.
 *
 * The input is assumed to be in normal order and coefficient-wise bound by
 * MLKEM_Q in absolute value.
 *
 * The output polynomial is in bitreversed order, or of a custom order if
 * MLK_USE_NATIVE_NTT_CUSTOM_ORDER is set, and coefficient-wise bound
 * by MLK_NTT_BOUND in absolute value.
 *
 * (NOTE: Sometimes the input to the NTT is actually smaller, which gives
 * better bounds.)
 *
 * @spec{Implements @[FIPS203, Algorithm 9, NTT].}
 *
 * @param[in,out] r Input/output polynomial.
 */
MLK_INTERNAL_API
void mlk_poly_ntt(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_Q))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLK_NTT_BOUND))
);

#define mlk_poly_invntt_tomont MLK_NAMESPACE(poly_invntt_tomont)
/**
 * Compute the inverse negacyclic number-theoretic transform (NTT) of a
 * polynomial in place; input assumed to be in bitreversed order, output in
 * normal order.
 *
 * The input is assumed to be in bitreversed order, or of a custom order if
 * MLK_USE_NATIVE_NTT_CUSTOM_ORDER is set, and can have arbitrary
 * coefficients in int16_t.
 *
 * The output polynomial is in normal order, and coefficient-wise bound by
 * MLK_INVNTT_BOUND in absolute value.
 *
 * @spec{Implements composition of @[FIPS203, Algorithm 10, NTT^{-1}] and
 * elementwise modular multiplication with a suitable Montgomery factor
 * introduced during the base multiplication.}
 *
 * @param[in,out] r Input/output polynomial.
 */
MLK_INTERNAL_API
void mlk_poly_invntt_tomont(mlk_poly *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND))
);

#endif /* !MLK_POLY_H */
```

### `mlkem/src/poly_k.c`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [FIPS203]
 *   FIPS 203 Module-Lattice-Based Key-Encapsulation Mechanism Standard
 *   National Institute of Standards and Technology
 *   https://csrc.nist.gov/pubs/fips/203/final
 *
 * - [NeonNTT]
 *   Neon NTT: Faster Dilithium, Kyber, and Saber on Cortex-A72 and Apple M1
 *   Becker, Hwang, Kannwischer, Yang, Yang
 *   https://eprint.iacr.org/2021/986
 *
 * - [REF]
 *   CRYSTALS-Kyber C reference implementation
 *   Bos, Ducas, Kiltz, Lepoint, Lyubashevsky, Schanck, Schwabe, Seiler, Stehlé
 *   https://github.com/pq-crystals/kyber/tree/main/ref
 */

#include "poly_k.h"

#include "debug.h"
#include "sampling.h"
#include "symmetric.h"
#include "verify.h"

/* Parameter set namespacing
 * This is to facilitate building multiple instances
 * of mlkem-native (e.g. with varying parameter sets)
 * within a single compilation unit. */
#define mlk_poly_cbd_eta1 MLK_ADD_PARAM_SET(mlk_poly_cbd_eta1)
#define mlk_poly_cbd_eta2 MLK_ADD_PARAM_SET(mlk_poly_cbd_eta2)
#define mlk_polyvec_basemul_acc_montgomery_cached_c \
  MLK_ADD_PARAM_SET(mlk_polyvec_basemul_acc_montgomery_cached_c)
/* End of parameter set namespacing */

/* Reference: `polyvec_compress()` in the reference implementation @[REF]
 *            - In contrast to the reference implementation, we assume
 *              unsigned canonical coefficients here.
 *              The reference implementation works with coefficients
 *              in the range [-(MLKEM_Q-1), MLKEM_Q-1]. */
MLK_INTERNAL_API
void mlk_polyvec_compress_du(uint8_t r[MLKEM_POLYVECCOMPRESSEDBYTES_DU],
                             const mlk_polyvec *a)
{
  unsigned i;
  mlk_assert_bound_2d(a->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);

  for (i = 0; i < MLKEM_K; i++)
  {
    mlk_poly_compress_du(r + i * MLKEM_POLYCOMPRESSEDBYTES_DU, &a->vec[i]);
  }
}

/* Reference: `polyvec_decompress()` in the reference implementation @[REF]. */
MLK_INTERNAL_API
void mlk_polyvec_decompress_du(mlk_polyvec *r,
                               const uint8_t a[MLKEM_POLYVECCOMPRESSEDBYTES_DU])
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  {
    mlk_poly_decompress_du(&r->vec[i], a + i * MLKEM_POLYCOMPRESSEDBYTES_DU);
  }

  mlk_assert_bound_2d(r->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
}

/* Reference: `polyvec_tobytes()` in the reference implementation @[REF].
 *            - In contrast to the reference implementation, we assume
 *              unsigned canonical coefficients here.
 *              The reference implementation works with coefficients
 *              in the range [-(MLKEM_Q-1), MLKEM_Q-1]. */
MLK_INTERNAL_API
void mlk_polyvec_tobytes(uint8_t r[MLKEM_POLYVECBYTES], const mlk_polyvec *a)
{
  unsigned i;
  mlk_assert_bound_2d(a->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);

  for (i = 0; i < MLKEM_K; i++)
  __loop__(
    assigns(i, memory_slice(r, MLKEM_POLYVECBYTES))
    invariant(i <= MLKEM_K)
    decreases(MLKEM_K - i)
  )
  {
    mlk_poly_tobytes(&r[i * MLKEM_POLYBYTES], &a->vec[i]);
  }
}

/* Reference: `polyvec_frombytes()` in the reference implementation @[REF]. */
MLK_INTERNAL_API
void mlk_polyvec_frombytes(mlk_polyvec *r, const uint8_t a[MLKEM_POLYVECBYTES])
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  {
    mlk_poly_frombytes(&r->vec[i], a + i * MLKEM_POLYBYTES);
  }

  mlk_assert_bound_2d(r->vec, MLKEM_K, MLKEM_N, 0, MLKEM_UINT12_LIMIT);
}

/* Reference: `polyvec_ntt()` in the reference implementation @[REF]. */
MLK_INTERNAL_API
void mlk_polyvec_ntt(mlk_polyvec *r)
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  {
    mlk_poly_ntt(&r->vec[i]);
  }

  mlk_assert_abs_bound_2d(r->vec, MLKEM_K, MLKEM_N, MLK_NTT_BOUND);
}

/* Reference: `polyvec_invntt_tomont()` in the reference implementation @[REF].
 *            - We normalize at the beginning of the inverse NTT,
 *              while the reference implementation normalizes at
 *              the end. This allows us to drop a call to `poly_reduce()`
 *              from the base multiplication. */
MLK_INTERNAL_API
void mlk_polyvec_invntt_tomont(mlk_polyvec *r)
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  {
    mlk_poly_invntt_tomont(&r->vec[i]);
  }

  mlk_assert_abs_bound_2d(r->vec, MLKEM_K, MLKEM_N, MLK_INVNTT_BOUND);
}

/* Reference: `polyvec_basemul_acc_montgomery()` in the
 *            reference implementation @[REF].
 *            - We use a multiplication cache ('mulcache') here
 *              which is not present in the reference implementation @[REF].
 *              This idea originates from @[NeonNTT] and is used
 *              at the C level here.
 *            - We compute the coefficients of the scalar product in 32-bit
 *              coefficients and perform only a single modular reduction
 *              at the end. The reference implementation uses 2 * MLKEM_K
 *              more modular reductions since it reduces after every modular
 *              multiplication. */
MLK_STATIC_TESTABLE void mlk_polyvec_basemul_acc_montgomery_cached_c(
    mlk_poly *r, const mlk_polyvec *a, const mlk_polyvec *b,
    const mlk_polyvec_mulcache *b_cache)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(a, sizeof(mlk_polyvec)))
  requires(memory_no_alias(b, sizeof(mlk_polyvec)))
  requires(memory_no_alias(b_cache, sizeof(mlk_polyvec_mulcache)))
  requires(forall(k1, 0, MLKEM_K,
     array_bound(a->vec[k1].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
)
{
  unsigned i;
  mlk_assert_bound_2d(a->vec, MLKEM_K, MLKEM_N, 0, MLKEM_UINT12_LIMIT);

  for (i = 0; i < MLKEM_N / 2; i++)
  __loop__(invariant(i <= MLKEM_N / 2)
           decreases(MLKEM_N / 2 - i))
  {
    unsigned k;
    int32_t t[2] = {0};
    for (k = 0; k < MLKEM_K; k++)
    __loop__(
      invariant(k <= MLKEM_K &&
         t[0] <=    (int32_t) k * 2 * MLKEM_UINT12_LIMIT * 32768  &&
         t[0] >= - ((int32_t) k * 2 * MLKEM_UINT12_LIMIT * 32768) &&
         t[1] <=   ((int32_t) k * 2 * MLKEM_UINT12_LIMIT * 32768) &&
         t[1] >= - ((int32_t) k * 2 * MLKEM_UINT12_LIMIT * 32768))
      decreases(MLKEM_K - k))
    {
      t[0] += (int32_t)a->vec[k].coeffs[2 * i + 1] * b_cache->vec[k].coeffs[i];
      t[0] += (int32_t)a->vec[k].coeffs[2 * i] * b->vec[k].coeffs[2 * i];
      t[1] += (int32_t)a->vec[k].coeffs[2 * i] * b->vec[k].coeffs[2 * i + 1];
      t[1] += (int32_t)a->vec[k].coeffs[2 * i + 1] * b->vec[k].coeffs[2 * i];
    }
    r->coeffs[2 * i + 0] = mlk_montgomery_reduce(t[0]);
    r->coeffs[2 * i + 1] = mlk_montgomery_reduce(t[1]);
  }
}

MLK_INTERNAL_API
void mlk_polyvec_basemul_acc_montgomery_cached(
    mlk_poly *r, const mlk_polyvec *a, const mlk_polyvec *b,
    const mlk_polyvec_mulcache *b_cache)
{
#if defined(MLK_USE_NATIVE_POLYVEC_BASEMUL_ACC_MONTGOMERY_CACHED)
  {
    int ret;
    mlk_assert_bound_2d(a->vec, MLKEM_K, MLKEM_N, 0, MLKEM_UINT12_LIMIT);
#if MLKEM_K == 2
    ret = mlk_polyvec_basemul_acc_montgomery_cached_k2_native(
        r->coeffs, (const int16_t *)a, (const int16_t *)b,
        (const int16_t *)b_cache);
#elif MLKEM_K == 3
    ret = mlk_polyvec_basemul_acc_montgomery_cached_k3_native(
        r->coeffs, (const int16_t *)a, (const int16_t *)b,
        (const int16_t *)b_cache);
#elif MLKEM_K == 4
    ret = mlk_polyvec_basemul_acc_montgomery_cached_k4_native(
        r->coeffs, (const int16_t *)a, (const int16_t *)b,
        (const int16_t *)b_cache);
#endif
    if (ret == MLK_NATIVE_FUNC_SUCCESS)
    {
      return;
    }
  }
#endif /* MLK_USE_NATIVE_POLYVEC_BASEMUL_ACC_MONTGOMERY_CACHED */

  mlk_polyvec_basemul_acc_montgomery_cached_c(r, a, b, b_cache);
}

/* Reference: Does not exist in the reference implementation @[REF].
 *            - The reference implementation does not use a
 *              multiplication cache ('mulcache'). This idea originates
 *              from @[NeonNTT] and is used at the C level here. */
MLK_INTERNAL_API
void mlk_polyvec_mulcache_compute(mlk_polyvec_mulcache *x, const mlk_polyvec *a)
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  {
    mlk_poly_mulcache_compute(&x->vec[i], &a->vec[i]);
  }
}

/* Reference: `polyvec_reduce()` in the reference implementation @[REF].
 *            - We use _unsigned_ canonical outputs, while the reference
 *              implementation uses _signed_ canonical outputs.
 *              Accordingly, we need a conditional addition of MLKEM_Q
 *              here to go from signed to unsigned representatives.
 *              This conditional addition is then dropped from all
 *              polynomial compression functions instead (see `compress.c`). */
MLK_INTERNAL_API
void mlk_polyvec_reduce(mlk_polyvec *r)
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  {
    mlk_poly_reduce(&r->vec[i]);
  }

  mlk_assert_bound_2d(r->vec, MLKEM_K, MLKEM_N, 0, MLKEM_Q);
}

/* Reference: `polyvec_add()` in the reference implementation @[REF].
 *            - We use destructive version (output=first input) to avoid
 *              reasoning about aliasing in the CBMC specification */
MLK_INTERNAL_API
void mlk_polyvec_add(mlk_polyvec *r, const mlk_polyvec *b)
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  __loop__(
    assigns(i, memory_slice(r, sizeof(mlk_polyvec)))
    invariant(i <= MLKEM_K)
    invariant(forall(j0, i, MLKEM_K,
                forall(k0, 0, MLKEM_N,
                       ((int32_t)r->vec[j0].coeffs[k0] + b->vec[j0].coeffs[k0] <= INT16_MAX) &&
                       ((int32_t)r->vec[j0].coeffs[k0] + b->vec[j0].coeffs[k0] >= INT16_MIN))))
    invariant(forall(j2, 0, i,
                forall(k2, 0, MLKEM_N,
                       (r->vec[j2].coeffs[k2] <= INT16_MAX) &&
                       (r->vec[j2].coeffs[k2] >= INT16_MIN))))
    decreases(MLKEM_K - i)
  )
  {
    mlk_poly_add(&r->vec[i], &b->vec[i]);
  }
}

/* Reference: `polyvec_tomont()` in the reference implementation @[REF]. */
MLK_INTERNAL_API
void mlk_polyvec_tomont(mlk_polyvec *r)
{
  unsigned i;
  for (i = 0; i < MLKEM_K; i++)
  {
    mlk_poly_tomont(&r->vec[i]);
  }

  mlk_assert_abs_bound_2d(r->vec, MLKEM_K, MLKEM_N, MLKEM_Q);
}


/**
 * Given an array of uniformly random bytes, compute a polynomial with
 * coefficients distributed according to a centered binomial distribution
 * with parameter MLKEM_ETA1.
 *
 * @spec{Implements @[FIPS203, Algorithm 8, SamplePolyCBD_eta1], where eta1
 * is specified per parameter set in @[FIPS203, Table 2] and represented as
 * MLKEM_ETA1 here.}
 *
 * @reference{`poly_cbd_eta1` in the reference implementation @[REF].}
 *
 * @param[out] r   Output polynomial.
 * @param[in]  buf Input byte array.
 */
static MLK_INLINE void mlk_poly_cbd_eta1(
    mlk_poly *r, const uint8_t buf[MLKEM_ETA1 * MLKEM_N / 4])
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(buf, MLKEM_ETA1 * MLKEM_N / 4))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA1 + 1))
)
{
#if MLKEM_ETA1 == 2
  mlk_poly_cbd2(r, buf);
#elif MLKEM_ETA1 == 3
  mlk_poly_cbd3(r, buf);
#else
#error "Invalid value of MLKEM_ETA1"
#endif
}

/* Reference: Does not exist in the reference implementation @[REF].
 *            - This implements a x4-batched version of `poly_getnoise_eta1()`
 *              from the reference implementation, to leverage
 *              batched Keccak-f1600.*/
MLK_INTERNAL_API
void mlk_poly_getnoise_eta1_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
                               mlk_poly *r3, const uint8_t seed[MLKEM_SYMBYTES],
                               uint8_t nonce0, uint8_t nonce1, uint8_t nonce2,
                               uint8_t nonce3)
{
  MLK_ALIGN uint8_t buf[4][MLK_ALIGN_UP(MLKEM_ETA1 * MLKEM_N / 4)];
  MLK_ALIGN uint8_t extkey[4][MLK_ALIGN_UP(MLKEM_SYMBYTES + 1)];
  mlk_memcpy(extkey[0], seed, MLKEM_SYMBYTES);
  mlk_memcpy(extkey[1], seed, MLKEM_SYMBYTES);
  mlk_memcpy(extkey[2], seed, MLKEM_SYMBYTES);
  mlk_memcpy(extkey[3], seed, MLKEM_SYMBYTES);
  extkey[0][MLKEM_SYMBYTES] = nonce0;
  extkey[1][MLKEM_SYMBYTES] = nonce1;
  extkey[2][MLKEM_SYMBYTES] = nonce2;
  extkey[3][MLKEM_SYMBYTES] = nonce3;

#if !defined(FIPS202_X4_DEFAULT_IMPLEMENTATION) && \
    !defined(MLK_CONFIG_SERIAL_FIPS202_ONLY)
  mlk_prf_eta1_x4(buf, extkey);
#else
  mlk_prf_eta1(buf[0], extkey[0]);
  mlk_prf_eta1(buf[1], extkey[1]);
  mlk_prf_eta1(buf[2], extkey[2]);
  if (r3 != NULL)
  {
    mlk_prf_eta1(buf[3], extkey[3]);
  }
#endif /* !(!FIPS202_X4_DEFAULT_IMPLEMENTATION && \
          !MLK_CONFIG_SERIAL_FIPS202_ONLY) */

  mlk_poly_cbd_eta1(r0, buf[0]);
  mlk_poly_cbd_eta1(r1, buf[1]);
  mlk_poly_cbd_eta1(r2, buf[2]);
  if (r3 != NULL)
  {
    mlk_poly_cbd_eta1(r3, buf[3]);
    mlk_assert_abs_bound(r3, MLKEM_N, MLKEM_ETA1 + 1);
  }

  mlk_assert_abs_bound(r0, MLKEM_N, MLKEM_ETA1 + 1);
  mlk_assert_abs_bound(r1, MLKEM_N, MLKEM_ETA1 + 1);
  mlk_assert_abs_bound(r2, MLKEM_N, MLKEM_ETA1 + 1);

  /* Specification: Partially implements
   * @[FIPS203, Section 3.3, Destruction of intermediate values] */
  mlk_zeroize(buf, sizeof(buf));
  mlk_zeroize(extkey, sizeof(extkey));
}

#if MLKEM_K == 2 || MLKEM_K == 4
/**
 * Given an array of uniformly random bytes, compute a polynomial with
 * coefficients distributed according to a centered binomial distribution
 * with parameter MLKEM_ETA2.
 *
 * @spec{Implements @[FIPS203, Algorithm 8, SamplePolyCBD_eta2], where eta2
 * is specified per parameter set in @[FIPS203, Table 2] and represented as
 * MLKEM_ETA2 here.}
 *
 * @reference{`poly_cbd_eta2` in the reference implementation @[REF].}
 *
 * @param[out] r   Output polynomial.
 * @param[in]  buf Input byte array.
 */
static MLK_INLINE void mlk_poly_cbd_eta2(
    mlk_poly *r, const uint8_t buf[MLKEM_ETA2 * MLKEM_N / 4])
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(buf, MLKEM_ETA2 * MLKEM_N / 4))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1)))
{
#if MLKEM_ETA2 == 2
  mlk_poly_cbd2(r, buf);
#else
#error "Invalid value of MLKEM_ETA2"
#endif
}

/* Reference: `poly_getnoise_eta2()` in the reference implementation @[REF].
 *            - We include buffer zeroization. */
MLK_INTERNAL_API
void mlk_poly_getnoise_eta2(mlk_poly *r, const uint8_t seed[MLKEM_SYMBYTES],
                            uint8_t nonce)
{
  MLK_ALIGN uint8_t buf[MLKEM_ETA2 * MLKEM_N / 4];
  MLK_ALIGN uint8_t extkey[MLKEM_SYMBYTES + 1];

  mlk_memcpy(extkey, seed, MLKEM_SYMBYTES);
  extkey[MLKEM_SYMBYTES] = nonce;
  mlk_prf_eta2(buf, extkey);

  mlk_poly_cbd_eta2(r, buf);

  mlk_assert_abs_bound(r, MLKEM_N, MLKEM_ETA2 + 1);

  /* Specification: Partially implements
   * @[FIPS203, Section 3.3, Destruction of intermediate values] */
  mlk_zeroize(buf, sizeof(buf));
  mlk_zeroize(extkey, sizeof(extkey));
}
#endif /* MLKEM_K == 2 || MLKEM_K == 4 */

#if MLKEM_K == 2
/* Reference: Does not exist in the reference implementation @[REF].
 *            - This implements a x4-batched version of `poly_getnoise_eta1()`
 *              and `poly_getnoise_eta2()` from the reference implementation,
 *              leveraging batched Keccak-f1600.
 *            - If a x4-batched Keccak-f1600 is available, we squeeze
 *              more random data than needed for the eta2 calls, to be
 *              be able to use a x4-batched Keccak-f1600. */
MLK_INTERNAL_API
void mlk_poly_getnoise_eta1122_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
                                  mlk_poly *r3,
                                  const uint8_t seed[MLKEM_SYMBYTES],
                                  uint8_t nonce0, uint8_t nonce1,
                                  uint8_t nonce2, uint8_t nonce3)
{
#if MLKEM_ETA2 >= MLKEM_ETA1
#error mlk_poly_getnoise_eta1122_4x assumes MLKEM_ETA1 > MLKEM_ETA2
#endif
  MLK_ALIGN uint8_t buf[4][MLK_ALIGN_UP(MLKEM_ETA1 * MLKEM_N / 4)];
  MLK_ALIGN uint8_t extkey[4][MLK_ALIGN_UP(MLKEM_SYMBYTES + 1)];

  mlk_memcpy(extkey[0], seed, MLKEM_SYMBYTES);
  mlk_memcpy(extkey[1], seed, MLKEM_SYMBYTES);
  mlk_memcpy(extkey[2], seed, MLKEM_SYMBYTES);
  mlk_memcpy(extkey[3], seed, MLKEM_SYMBYTES);
  extkey[0][MLKEM_SYMBYTES] = nonce0;
  extkey[1][MLKEM_SYMBYTES] = nonce1;
  extkey[2][MLKEM_SYMBYTES] = nonce2;
  extkey[3][MLKEM_SYMBYTES] = nonce3;

  /* On systems with fast batched Keccak, we use 4-fold batched PRF,
   * even though that means generating more random data in buf[2] and buf[3]
   * than necessary. */
#if !defined(FIPS202_X4_DEFAULT_IMPLEMENTATION) && \
    !defined(MLK_CONFIG_SERIAL_FIPS202_ONLY)
  mlk_prf_eta1_x4(buf, extkey);
#else
  mlk_prf_eta1(buf[0], extkey[0]);
  mlk_prf_eta1(buf[1], extkey[1]);
  mlk_prf_eta2(buf[2], extkey[2]);
  mlk_prf_eta2(buf[3], extkey[3]);
#endif /* !(!FIPS202_X4_DEFAULT_IMPLEMENTATION && \
          !MLK_CONFIG_SERIAL_FIPS202_ONLY) */

  mlk_poly_cbd_eta1(r0, buf[0]);
  mlk_poly_cbd_eta1(r1, buf[1]);
  mlk_poly_cbd_eta2(r2, buf[2]);
  mlk_poly_cbd_eta2(r3, buf[3]);

  mlk_assert_abs_bound(r0, MLKEM_N, MLKEM_ETA1 + 1);
  mlk_assert_abs_bound(r1, MLKEM_N, MLKEM_ETA1 + 1);
  mlk_assert_abs_bound(r2, MLKEM_N, MLKEM_ETA2 + 1);
  mlk_assert_abs_bound(r3, MLKEM_N, MLKEM_ETA2 + 1);

  /* Specification: Partially implements
   * @[FIPS203, Section 3.3, Destruction of intermediate values] */
  mlk_zeroize(buf, sizeof(buf));
  mlk_zeroize(extkey, sizeof(extkey));
}
#endif /* MLKEM_K == 2 */

/* To facilitate single-compilation-unit (SCU) builds, undefine all macros.
 * Don't modify by hand -- this is auto-generated by scripts/autogen. */
#undef mlk_poly_cbd_eta1
#undef mlk_poly_cbd_eta2
#undef mlk_polyvec_basemul_acc_montgomery_cached_c
```

### `mlkem/src/poly_k.h`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [FIPS203]
 *   FIPS 203 Module-Lattice-Based Key-Encapsulation Mechanism Standard
 *   National Institute of Standards and Technology
 *   https://csrc.nist.gov/pubs/fips/203/final
 */

#ifndef MLK_POLY_K_H
#define MLK_POLY_K_H

#include "common.h"
#include "compress.h"
#include "poly.h"

/* Parameter set namespacing
 * This is to facilitate building multiple instances
 * of mlkem-native (e.g. with varying parameter sets)
 * within a single compilation unit. */
#define mlk_polyvec MLK_ADD_PARAM_SET(mlk_polyvec)
#define mlk_polymat MLK_ADD_PARAM_SET(mlk_polymat)
#define mlk_polyvec_mulcache MLK_ADD_PARAM_SET(mlk_polyvec_mulcache)
/* End of parameter set namespacing */

/** Vector of MLKEM_K polynomials. */
typedef struct
{
  mlk_poly vec[MLKEM_K]; /**< Component polynomials. */
} MLK_ALIGN mlk_polyvec;

/** MLKEM_K x MLKEM_K matrix of polynomials. */
typedef struct
{
  mlk_polyvec vec[MLKEM_K]; /**< Rows of the matrix. */
} MLK_ALIGN mlk_polymat;

/** Vector of MLKEM_K mlk_poly_mulcache entries. */
typedef struct
{
  mlk_poly_mulcache vec[MLKEM_K]; /**< Per-component caches. */
} MLK_ALIGN mlk_polyvec_mulcache;

#define mlk_poly_compress_du MLK_NAMESPACE_K(poly_compress_du)
/**
 * Compression (du bits) and subsequent serialization of a polynomial.
 *
 * @spec{Implements `ByteEncode_{d_u} (Compress_{d_u} (u))` in @[FIPS203,
 * Algorithm 14 (K-PKE.Encrypt), L22], with level-specific d_u defined in
 * @[FIPS203, Table 2], and given by MLKEM_DU here.}
 *
 * @param[out] r Output byte array (of length MLKEM_POLYCOMPRESSEDBYTES_DU
 *               bytes).
 * @param[in]  a Input polynomial. Coefficients must be unsigned canonical,
 *               i.e. in [0,1,..,MLKEM_Q-1].
 */
static MLK_INLINE void mlk_poly_compress_du(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_DU], const mlk_poly *a)
__contract__(
  requires(memory_no_alias(r, MLKEM_POLYCOMPRESSEDBYTES_DU))
  requires(memory_no_alias(a, sizeof(mlk_poly)))
  requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
  assigns(memory_slice(r, MLKEM_POLYCOMPRESSEDBYTES_DU)))
{
#if MLKEM_DU == 10
  mlk_poly_compress_d10(r, a);
#elif MLKEM_DU == 11
  mlk_poly_compress_d11(r, a);
#else
#error "Invalid value of MLKEM_DU"
#endif
}

#define mlk_poly_decompress_du MLK_NAMESPACE_K(poly_decompress_du)
/**
 * De-serialization and subsequent decompression (du bits) of a polynomial;
 * approximate inverse of mlk_poly_compress_du.
 *
 * Upon return, the coefficients of the output polynomial are
 * unsigned-canonical (non-negative and smaller than MLKEM_Q).
 *
 * @spec{Implements `Decompress_{d_u} (ByteDecode_{d_u} (u))` in @[FIPS203,
 * Algorithm 15 (K-PKE.Decrypt), L3], with level-specific d_u defined in
 * @[FIPS203, Table 2], and given by MLKEM_DU here.}
 *
 * @param[out] r Output polynomial.
 * @param[in]  a Input byte array (of length MLKEM_POLYCOMPRESSEDBYTES_DU
 *               bytes).
 */
static MLK_INLINE void mlk_poly_decompress_du(
    mlk_poly *r, const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_DU])
__contract__(
  requires(memory_no_alias(a, MLKEM_POLYCOMPRESSEDBYTES_DU))
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
{
#if MLKEM_DU == 10
  mlk_poly_decompress_d10(r, a);
#elif MLKEM_DU == 11
  mlk_poly_decompress_d11(r, a);
#else
#error "Invalid value of MLKEM_DU"
#endif
}

#define mlk_poly_compress_dv MLK_NAMESPACE_K(poly_compress_dv)
/**
 * Compression (dv bits) and subsequent serialization of a polynomial.
 *
 * @spec{Implements `ByteEncode_{d_v} (Compress_{d_v} (v))` in @[FIPS203,
 * Algorithm 14 (K-PKE.Encrypt), L23], with level-specific d_v defined in
 * @[FIPS203, Table 2], and given by MLKEM_DV here.}
 *
 * @param[out] r Output byte array (of length MLKEM_POLYCOMPRESSEDBYTES_DV
 *               bytes).
 * @param[in]  a Input polynomial. Coefficients must be unsigned canonical,
 *               i.e. in [0,1,..,MLKEM_Q-1].
 */
static MLK_INLINE void mlk_poly_compress_dv(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_DV], const mlk_poly *a)
__contract__(
  requires(memory_no_alias(r, MLKEM_POLYCOMPRESSEDBYTES_DV))
  requires(memory_no_alias(a, sizeof(mlk_poly)))
  requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
  assigns(memory_slice(r, MLKEM_POLYCOMPRESSEDBYTES_DV)))
{
#if MLKEM_DV == 4
  mlk_poly_compress_d4(r, a);
#elif MLKEM_DV == 5
  mlk_poly_compress_d5(r, a);
#else
#error "Invalid value of MLKEM_DV"
#endif
}


#define mlk_poly_decompress_dv MLK_NAMESPACE_K(poly_decompress_dv)
/**
 * De-serialization and subsequent decompression (dv bits) of a polynomial;
 * approximate inverse of mlk_poly_compress_dv.
 *
 * Upon return, the coefficients of the output polynomial are
 * unsigned-canonical (non-negative and smaller than MLKEM_Q).
 *
 * @spec{Implements `Decompress_{d_v} (ByteDecode_{d_v} (v))` in @[FIPS203,
 * Algorithm 15 (K-PKE.Decrypt), L4], with level-specific d_v defined in
 * @[FIPS203, Table 2], and given by MLKEM_DV here.}
 *
 * @param[out] r Output polynomial.
 * @param[in]  a Input byte array (of length MLKEM_POLYCOMPRESSEDBYTES_DV
 *               bytes).
 */
static MLK_INLINE void mlk_poly_decompress_dv(
    mlk_poly *r, const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_DV])
__contract__(
  requires(memory_no_alias(a, MLKEM_POLYCOMPRESSEDBYTES_DV))
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
{
#if MLKEM_DV == 4
  mlk_poly_decompress_d4(r, a);
#elif MLKEM_DV == 5
  mlk_poly_decompress_d5(r, a);
#else
#error "Invalid value of MLKEM_DV"
#endif
}

#define mlk_polyvec_compress_du MLK_NAMESPACE_K(polyvec_compress_du)
/**
 * Compress and serialize a vector of polynomials.
 *
 * @spec{Implements `ByteEncode_{d_u} (Compress_{d_u} (u))` in @[FIPS203,
 * Algorithm 14 (K-PKE.Encrypt), L22], with level-specific d_u defined in
 * @[FIPS203, Table 2], and given by MLKEM_DU here.}
 *
 * @param[out] r Output byte array (needs space for
 *               MLKEM_POLYVECCOMPRESSEDBYTES_DU bytes).
 * @param[in]  a Input vector of polynomials. Coefficients must be unsigned
 *               canonical, i.e. in [0,1,..,MLKEM_Q-1].
 */
MLK_INTERNAL_API
void mlk_polyvec_compress_du(uint8_t r[MLKEM_POLYVECCOMPRESSEDBYTES_DU],
                             const mlk_polyvec *a)
__contract__(
  requires(memory_no_alias(r, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
  requires(memory_no_alias(a, sizeof(mlk_polyvec)))
  requires(forall(k0, 0, MLKEM_K,
         array_bound(a->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
  assigns(memory_slice(r, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
);

#define mlk_polyvec_decompress_du MLK_NAMESPACE_K(polyvec_decompress_du)
/**
 * De-serialize and decompress a vector of polynomials; approximate inverse
 * of mlk_polyvec_compress_du.
 *
 * @spec{Implements `Decompress_{d_u} (ByteDecode_{d_u} (u))` in @[FIPS203,
 * Algorithm 15 (K-PKE.Decrypt), L3], with level-specific d_u defined in
 * @[FIPS203, Table 2], and given by MLKEM_DU here.}
 *
 * @param[out] r Output vector of polynomials. Coefficients are normalized
 *               to [0,1,..,MLKEM_Q-1].
 * @param[in]  a Input byte array (of length MLKEM_POLYVECCOMPRESSEDBYTES_DU
 *               bytes).
 */
MLK_INTERNAL_API
void mlk_polyvec_decompress_du(mlk_polyvec *r,
                               const uint8_t a[MLKEM_POLYVECCOMPRESSEDBYTES_DU])
__contract__(
  requires(memory_no_alias(a, MLKEM_POLYVECCOMPRESSEDBYTES_DU))
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(k0, 0, MLKEM_K,
         array_bound(r->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
);

#define mlk_polyvec_tobytes MLK_NAMESPACE_K(polyvec_tobytes)
/**
 * Serialize a vector of polynomials.
 *
 * @spec{Implements ByteEncode_12 @[FIPS203, Algorithm 5]. Extended to
 * vectors as per @[FIPS203, 2.4.8 Applying Algorithms to Arrays] and
 * @[FIPS203, 2.4.6, Matrices and Vectors].}
 *
 * @param[out] r Output byte array (needs space for MLKEM_POLYVECBYTES bytes).
 * @param[in]  a Input vector of polynomials. Each polynomial must have
 *               coefficients in [0,1,..,MLKEM_Q-1].
 */
MLK_INTERNAL_API
void mlk_polyvec_tobytes(uint8_t r[MLKEM_POLYVECBYTES], const mlk_polyvec *a)
__contract__(
  requires(memory_no_alias(a, sizeof(mlk_polyvec)))
  requires(memory_no_alias(r, MLKEM_POLYVECBYTES))
  requires(forall(k0, 0, MLKEM_K,
         array_bound(a->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
  assigns(memory_slice(r, MLKEM_POLYVECBYTES))
);

#define mlk_polyvec_frombytes MLK_NAMESPACE_K(polyvec_frombytes)
/**
 * De-serialize a vector of polynomials; inverse of mlk_polyvec_tobytes.
 *
 * @spec{Implements ByteDecode_12 @[FIPS203, Algorithm 6]. Extended to
 * vectors as per @[FIPS203, 2.4.8 Applying Algorithms to Arrays] and
 * @[FIPS203, 2.4.6, Matrices and Vectors].}
 *
 * @param[out] r Output vector of polynomials. Coefficients will be
 *               normalized in [0,1,..,4095].
 * @param[in]  a Input byte array (of length MLKEM_POLYVECBYTES bytes).
 */
MLK_INTERNAL_API
void mlk_polyvec_frombytes(mlk_polyvec *r, const uint8_t a[MLKEM_POLYVECBYTES])
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  requires(memory_no_alias(a, MLKEM_POLYVECBYTES))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(k0, 0, MLKEM_K,
        array_bound(r->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT)))
);

#define mlk_polyvec_ntt MLK_NAMESPACE_K(polyvec_ntt)
/**
 * Apply forward NTT to all elements of a vector of polynomials.
 *
 * The input is assumed to be in normal order and coefficient-wise bound by
 * MLKEM_Q in absolute value.
 *
 * The output polynomial is in bitreversed order, and coefficient-wise bound
 * by MLK_NTT_BOUND in absolute value.
 *
 * @spec{Implements @[FIPS203, Algorithm 9, NTT]. Extended to vectors as per
 * @[FIPS203, 2.4.6, Matrices and Vectors].}
 *
 * @param[in,out] r Input/output vector of polynomials.
 */
MLK_INTERNAL_API
void mlk_polyvec_ntt(mlk_polyvec *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  requires(forall(j, 0, MLKEM_K,
  array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLKEM_Q)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(j, 0, MLKEM_K,
  array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLK_NTT_BOUND)))
);

#define mlk_polyvec_invntt_tomont MLK_NAMESPACE_K(polyvec_invntt_tomont)
/**
 * Apply inverse NTT to all elements of a vector of polynomials and multiply
 * by Montgomery factor 2^16.
 *
 * The input is assumed to be in bitreversed order, and can have arbitrary
 * coefficients in int16_t.
 *
 * The output polynomial is in normal order, and coefficient-wise bound by
 * MLK_INVNTT_BOUND in absolute value.
 *
 * @spec{Implements @[FIPS203, Algorithm 10, NTT^{-1}]. Extended to vectors
 * as per @[FIPS203, 2.4.6, Matrices and Vectors].}
 *
 * @param[in,out] r Input/output vector of polynomials.
 */
MLK_INTERNAL_API
void mlk_polyvec_invntt_tomont(mlk_polyvec *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(j, 0, MLKEM_K,
  array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLK_INVNTT_BOUND)))
);

#define mlk_polyvec_basemul_acc_montgomery_cached \
  MLK_NAMESPACE_K(polyvec_basemul_acc_montgomery_cached)
/**
 * Scalar product of two vectors of polynomials in NTT domain, using
 * mulcache for the second operand.
 *
 * Bounds: every coefficient of @p a is assumed to be in [0,1,..,4095]. No
 * bounds guarantees for the coefficients in the result.
 *
 * @spec{Implements @[FIPS203, Section 2.4.7, Eq (2.14)], @[FIPS203,
 * Algorithm 11, MultiplyNTTs], and @[FIPS203, Algorithm 12,
 * BaseCaseMultiply].}
 *
 * @param[out] r       Output polynomial.
 * @param[in]  a       First input polynomial vector.
 * @param[in]  b       Second input polynomial vector.
 * @param[in]  b_cache Mulcache for the second input polynomial vector. Can
 *                     be computed via mlk_polyvec_mulcache_compute().
 */
MLK_INTERNAL_API
void mlk_polyvec_basemul_acc_montgomery_cached(
    mlk_poly *r, const mlk_polyvec *a, const mlk_polyvec *b,
    const mlk_polyvec_mulcache *b_cache)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(a, sizeof(mlk_polyvec)))
  requires(memory_no_alias(b, sizeof(mlk_polyvec)))
  requires(memory_no_alias(b_cache, sizeof(mlk_polyvec_mulcache)))
  requires(forall(k1, 0, MLKEM_K,
     array_bound(a->vec[k1].coeffs, 0, MLKEM_N, 0, MLKEM_UINT12_LIMIT)))
  assigns(memory_slice(r, sizeof(mlk_poly)))
);

#define mlk_polyvec_mulcache_compute MLK_NAMESPACE_K(polyvec_mulcache_compute)
/**
 * Compute the mulcache for a vector of polynomials in NTT domain.
 *
 * The mulcache of a degree-2 polynomial b := b0 + b1*X in Fq[X]/(X^2-zeta)
 * is the value b1*zeta, needed when computing products of b in
 * Fq[X]/(X^2-zeta).
 *
 * The mulcache of a polynomial in NTT domain -- which is a 128-tuple of
 * degree-2 polynomials in Fq[X]/(X^2-zeta), for varying zeta, is the
 * 128-tuple of mulcaches of those polynomials.
 *
 * The mulcache of a vector of polynomials is the vector of mulcaches of
 * its entries.
 *
 * @spec{Caches `b_1 * \gamma` in @[FIPS203, Algorithm 12, BaseCaseMultiply,
 * L1].}
 *
 * @param[out] x Mulcache to be populated.
 * @param[in]  a Input polynomial vector.
 */
/*
 * NOTE: The default C implementation of this function populates
 * the mulcache with values in (-q,q), but this is not needed for the
 * higher level safety proofs, and thus not part of the spec.
 */
MLK_INTERNAL_API
void mlk_polyvec_mulcache_compute(mlk_polyvec_mulcache *x, const mlk_polyvec *a)
__contract__(
  requires(memory_no_alias(x, sizeof(mlk_polyvec_mulcache)))
  requires(memory_no_alias(a, sizeof(mlk_polyvec)))
  assigns(memory_slice(x, sizeof(mlk_polyvec_mulcache)))
);

#define mlk_polyvec_reduce MLK_NAMESPACE_K(polyvec_reduce)
/**
 * Apply Barrett reduction to each coefficient of each element of a vector
 * of polynomials. For details of the Barrett reduction see comments in
 * poly.c.
 *
 * @spec{Normalizes on unsigned canonical representatives ahead of calling
 * @[FIPS203, Compress_d, Eq (4.7)]. This is not made explicit in FIPS 203.}
 *
 * @param[in,out] r Input/output polynomial vector.
 */
/*
 * NOTE: The semantics of mlk_polyvec_reduce() is different in
 *       the reference implementation, which requires
 *       signed canonical output data. Unsigned canonical
 *       outputs are better suited to the only remaining
 *       use of mlk_poly_reduce() in the context of (de)serialization.
 */
MLK_INTERNAL_API
void mlk_polyvec_reduce(mlk_polyvec *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(k0, 0, MLKEM_K,
    array_bound(r->vec[k0].coeffs, 0, MLKEM_N, 0, MLKEM_Q)))
);

#define mlk_polyvec_add MLK_NAMESPACE_K(polyvec_add)
/**
 * Add vectors of polynomials.
 *
 * The coefficients of @p r and @p b must be such that the addition does
 * not overflow. Otherwise, the behaviour of this function is undefined.
 *
 * The coefficients returned in @p *r are in int16_t which is sufficient to
 * prove type-safety of calling units. Therefore, no stronger ensures clause
 * is required on this function.
 *
 * @spec{@[FIPS203, 2.4.5, Arithmetic With Polynomials and NTT
 * Representations]. Used in @[FIPS203, Algorithm 14 (K-PKE.Encrypt), L19].}
 *
 * @param[in,out] r Input-output vector of polynomials to be added to.
 * @param[in]     b Second input vector of polynomials.
 */
MLK_INTERNAL_API
void mlk_polyvec_add(mlk_polyvec *r, const mlk_polyvec *b)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  requires(memory_no_alias(b, sizeof(mlk_polyvec)))
  requires(forall(j0, 0, MLKEM_K,
          forall(k0, 0, MLKEM_N,
            (int32_t)r->vec[j0].coeffs[k0] + b->vec[j0].coeffs[k0] <= INT16_MAX)))
  requires(forall(j1, 0, MLKEM_K,
          forall(k1, 0, MLKEM_N,
            (int32_t)r->vec[j1].coeffs[k1] + b->vec[j1].coeffs[k1] >= INT16_MIN)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
);

#define mlk_polyvec_tomont MLK_NAMESPACE_K(polyvec_tomont)
/**
 * In-place conversion of all coefficients of a polynomial vector from the
 * normal domain to the Montgomery domain.
 *
 * Bounds: output < MLKEM_Q in absolute value.
 *
 * @spec{Internal normalization required in `mlk_indcpa_keypair_derand` as
 * part of matrix-vector multiplication @[FIPS203, Algorithm 13, K-PKE.KeyGen,
 * L18].}
 *
 * @param[in,out] r Input/output polynomial vector.
 */
MLK_INTERNAL_API
void mlk_polyvec_tomont(mlk_polyvec *r)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_polyvec)))
  assigns(memory_slice(r, sizeof(mlk_polyvec)))
  ensures(forall(j, 0, MLKEM_K,
    array_abs_bound(r->vec[j].coeffs, 0, MLKEM_N, MLKEM_Q)))
);

#define mlk_poly_getnoise_eta1_4x MLK_NAMESPACE_K(poly_getnoise_eta1_4x)
/**
 * Batch sample four polynomials deterministically from a seed and nonces,
 * with output polynomials close to centered binomial distribution with
 * parameter MLKEM_ETA1.
 *
 * @spec{Implements 4x `SamplePolyCBD_{eta1} (PRF_{eta1} (sigma, N))`:
 * @[FIPS203, Algorithm 8, SamplePolyCBD_eta] and @[FIPS203, Eq (4.3),
 * PRF_eta]. `SamplePolyCBD_{eta1} (PRF_{eta1} (sigma, N))` appears in
 * @[FIPS203, Algorithm 13, K-PKE.KeyGen, L{9, 13}] and @[FIPS203,
 * Algorithm 14, K-PKE.Encrypt, L10].}
 *
 * @param[out] r0     Output polynomial.
 * @param[out] r1     Output polynomial.
 * @param[out] r2     Output polynomial.
 * @param[out] r3     Output polynomial. May be NULL.
 * @param[in]  seed   Input seed (of length MLKEM_SYMBYTES bytes).
 * @param      nonce0 One-byte input nonce.
 * @param      nonce1 One-byte input nonce.
 * @param      nonce2 One-byte input nonce.
 * @param      nonce3 One-byte input nonce.
 */
MLK_INTERNAL_API
void mlk_poly_getnoise_eta1_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
                               mlk_poly *r3, const uint8_t seed[MLKEM_SYMBYTES],
                               uint8_t nonce0, uint8_t nonce1, uint8_t nonce2,
                               uint8_t nonce3)
__contract__(
  requires(memory_no_alias(seed, MLKEM_SYMBYTES))
  requires(memory_no_alias(r0, sizeof(mlk_poly)))
  requires(memory_no_alias(r1, sizeof(mlk_poly)))
  requires(memory_no_alias(r2, sizeof(mlk_poly)))
  requires(r3 == NULL || memory_no_alias(r3, sizeof(mlk_poly)))
  assigns(memory_slice(r0, sizeof(mlk_poly)))
  assigns(memory_slice(r1, sizeof(mlk_poly)))
  assigns(memory_slice(r2, sizeof(mlk_poly)))
  assigns(r3 != NULL: memory_slice(r3, sizeof(mlk_poly)))
  ensures(array_abs_bound(r0->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
  ensures(array_abs_bound(r1->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
  ensures(array_abs_bound(r2->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
  ensures(r3 != NULL ==> array_abs_bound(r3->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1))
);

#if MLKEM_ETA1 == MLKEM_ETA2
/*
 * We only require mlk_poly_getnoise_eta2_4x for ml-kem-768 and ml-kem-1024
 * where MLKEM_ETA2 = MLKEM_ETA1 = 2.
 * For ml-kem-512, mlk_poly_getnoise_eta1122_4x is used instead.
 */
#define mlk_poly_getnoise_eta2_4x mlk_poly_getnoise_eta1_4x
#endif /* MLKEM_ETA1 == MLKEM_ETA2 */

#if MLKEM_K == 2 || MLKEM_K == 4
#define mlk_poly_getnoise_eta2 MLK_NAMESPACE_K(poly_getnoise_eta2)
/**
 * Sample a polynomial deterministically from a seed and a nonce, with
 * output polynomial close to centered binomial distribution with parameter
 * MLKEM_ETA2.
 *
 * @spec{Implements `SamplePolyCBD_{eta2} (PRF_{eta2} (sigma, N))`:
 * @[FIPS203, Algorithm 8, SamplePolyCBD_eta] and @[FIPS203, Eq (4.3),
 * PRF_eta]. `SamplePolyCBD_{eta2} (PRF_{eta2} (sigma, N))` appears in
 * @[FIPS203, Algorithm 14, K-PKE.Encrypt, L14].}
 *
 * @param[out] r     Output polynomial.
 * @param[in]  seed  Input seed (of length MLKEM_SYMBYTES bytes).
 * @param      nonce One-byte input nonce.
 */
MLK_INTERNAL_API
void mlk_poly_getnoise_eta2(mlk_poly *r, const uint8_t seed[MLKEM_SYMBYTES],
                            uint8_t nonce)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(seed, MLKEM_SYMBYTES))
  assigns(memory_slice(r, sizeof(mlk_poly)))
  ensures(array_abs_bound(r->coeffs, 0, MLKEM_N, MLKEM_ETA2 + 1))
);
#endif /* MLKEM_K == 2 || MLKEM_K == 4 */

#if MLKEM_K == 2
#define mlk_poly_getnoise_eta1122_4x MLK_NAMESPACE_K(poly_getnoise_eta1122_4x)
/**
 * Batch sample four polynomials deterministically from a seed and nonces,
 * with output polynomials close to centered binomial distribution with
 * parameter MLKEM_ETA1 and MLKEM_ETA2.
 *
 * @spec{Implements two instances each of
 * `SamplePolyCBD_{eta1} (PRF_{eta1} (sigma, N))` and
 * `SamplePolyCBD_{eta2} (PRF_{eta2} (sigma, N))`:
 * @[FIPS203, Algorithm 8, SamplePolyCBD_eta] and @[FIPS203, Eq (4.3),
 * PRF_eta]. `SamplePolyCBD_{eta2} (PRF_{eta2} (sigma, N))` appears in
 * @[FIPS203, Algorithm 14, K-PKE.Encrypt, L14].}
 *
 * @param[out] r0     Output polynomial.
 * @param[out] r1     Output polynomial.
 * @param[out] r2     Output polynomial.
 * @param[out] r3     Output polynomial.
 * @param[in]  seed   Input seed (of length MLKEM_SYMBYTES bytes).
 * @param      nonce0 One-byte input nonce.
 * @param      nonce1 One-byte input nonce.
 * @param      nonce2 One-byte input nonce.
 * @param      nonce3 One-byte input nonce.
 */
MLK_INTERNAL_API
void mlk_poly_getnoise_eta1122_4x(mlk_poly *r0, mlk_poly *r1, mlk_poly *r2,
                                  mlk_poly *r3,
                                  const uint8_t seed[MLKEM_SYMBYTES],
                                  uint8_t nonce0, uint8_t nonce1,
                                  uint8_t nonce2, uint8_t nonce3)
__contract__(
  requires(memory_no_alias(r0, sizeof(mlk_poly)))
  requires(memory_no_alias(r1, sizeof(mlk_poly)))
  requires(memory_no_alias(r2, sizeof(mlk_poly)))
  requires(memory_no_alias(r3, sizeof(mlk_poly)))
  requires(memory_no_alias(seed, MLKEM_SYMBYTES))
  assigns(memory_slice(r0, sizeof(mlk_poly)))
  assigns(memory_slice(r1, sizeof(mlk_poly)))
  assigns(memory_slice(r2, sizeof(mlk_poly)))
  assigns(memory_slice(r3, sizeof(mlk_poly)))
  ensures(array_abs_bound(r0->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1)
       && array_abs_bound(r1->coeffs,0, MLKEM_N, MLKEM_ETA1 + 1)
       && array_abs_bound(r2->coeffs,0, MLKEM_N, MLKEM_ETA2 + 1)
       && array_abs_bound(r3->coeffs,0, MLKEM_N, MLKEM_ETA2 + 1))
);
#endif /* MLKEM_K == 2 */

#endif /* !MLK_POLY_K_H */
```

### `proofs/cbmc/README.md`

````markdown
[//]: # (SPDX-License-Identifier: CC-BY-4.0)

CBMC proofs
===========

This directory contains the infrastructure for running [CBMC](https://github.com/diffblue/cbmc) proofs
for the absence of certain classes of undefined behaviour for parts of the C-code in mlkem-native.

## Primer

Proofs are organized by functions, with the harnesses for each function in a separate directory.
Specifications are directly embedded inside the mlkem-native C-source as contract and loop annotations;
the CBMC harnesses are boilerplate only and don't add to the specification.

For example, these are the specification and proof of the `poly_add` function:
```c
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
__contract__(
  requires(memory_no_alias(r, sizeof(mlk_poly)))
  requires(memory_no_alias(b, sizeof(mlk_poly)))
  requires(forall(k0, 0, MLKEM_N, (int32_t) r->coeffs[k0] + b->coeffs[k0] <= INT16_MAX))
  requires(forall(k1, 0, MLKEM_N, (int32_t) r->coeffs[k1] + b->coeffs[k1] >= INT16_MIN))
  ensures(forall(k, 0, MLKEM_N, r->coeffs[k] == old(*r).coeffs[k] + b->coeffs[k]))
  assigns(memory_slice(r, sizeof(mlk_poly)))
);

...

void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;
  for (i = 0; i < MLKEM_N; i++)
  __loop__(
    invariant(i <= MLKEM_N)
    invariant(forall(k0, i, MLKEM_N, r->coeffs[k0] == loop_entry(*r).coeffs[k0]))
    invariant(forall(k1, 0, i, r->coeffs[k1] == loop_entry(*r).coeffs[k1] + b->coeffs[k1])))
  {
    r->coeffs[i] = r->coeffs[i] + b->coeffs[i];
  }
}
```

See the [Proof Guide](proof_guide.md) for a walkthrough of how to use CBMC and develop new proofs.

## Installation

To reproduce the CBMC proofs, you will require several tools ([CBMC](https://github.com/diffblue/cbmc), [z3](https://github.com/Z3Prover/z3), [bitwuzla](https://github.com/bitwuzla/bitwuzla), [litani](https://github.com/awslabs/aws-build-accumulator), [cbmc-viewer](https://github.com/model-checking/cbmc-viewer)) installed.
It is not uncommon for proofs to fail or have significantly worse performance when switching to different tool versions.
Therefore, **we highly recommend using our Nix development environment** to install all the necessary tools. See [CONTRIBUTING.md](../../CONTRIBUTING.md).

Note that nix installation is straightforward and only requires running a single command: See https://nixos.org/download/.
Once Nix is installed, it takes a single command to install all the required tools at the version that have been tested to work well with the mlkem-native proofs:
```sh
nix develop --experimental-features 'nix-command flakes'
```

## Reproducing the proofs

To run all proofs, print a summary at the end and reflect overall
success/failure in the error code, use

```
MLKEM_K={2,3,4} run-cbmc-proofs.py --summarize
```

If `GITHUB_STEP_SUMMARY` is set, the proof summary will be appended to it.

Alternatively, you can use the [tests](../../scripts/tests) script, see

```
tests cbmc --help
```

## What is covered?

Each proved function has an eponymous sub-directory of its own. Use [list_proofs.sh](list_proofs.sh) to see the list of functions covered.

The classes of undefined behavior covered by CBMC are documented [here](https://github.com/diffblue/cbmc/blob/develop/doc/C/c11-undefined-behavior.html).
````

### `proofs/cbmc/indcpa_enc/Makefile`

```text
# Copyright (c) The mlkem-native project authors
# SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = indcpa_enc_harness

# This should be a unique identifier for this proof, and will appear on the
# Litani dashboard. It can be human-readable and contain spaces if you wish.
PROOF_UID = mlk_indcpa_enc

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=
UNWINDSET +=

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/indcpa.c

CHECK_FUNCTION_CONTRACTS=mlk_indcpa_enc
USE_FUNCTION_CONTRACTS = mlk_poly_frommsg
USE_FUNCTION_CONTRACTS += mlk_gen_matrix
USE_FUNCTION_CONTRACTS += mlk_enc_getnoise_eta1_eta2

USE_FUNCTION_CONTRACTS += mlk_polyvec_ntt
USE_FUNCTION_CONTRACTS += mlk_polyvec_mulcache_compute
USE_FUNCTION_CONTRACTS += mlk_polyvec_basemul_acc_montgomery_cached
USE_FUNCTION_CONTRACTS += mlk_polyvec_invntt_tomont
USE_FUNCTION_CONTRACTS += mlk_poly_invntt_tomont
USE_FUNCTION_CONTRACTS += mlk_polyvec_add
USE_FUNCTION_CONTRACTS += mlk_poly_add
USE_FUNCTION_CONTRACTS += mlk_polyvec_reduce
USE_FUNCTION_CONTRACTS += mlk_poly_reduce
USE_FUNCTION_CONTRACTS += mlk_polyvec_compress_du
USE_FUNCTION_CONTRACTS += mlk_poly_compress_dv
USE_FUNCTION_CONTRACTS += mlk_polyvec_frombytes
USE_FUNCTION_CONTRACTS += mlk_matvec_mul
USE_FUNCTION_CONTRACTS += mlk_zeroize
APPLY_LOOP_CONTRACTS=on
USE_DYNAMIC_FRAMES=1

# Disable any setting of EXTERNAL_SAT_SOLVER, and choose SMT backend instead
EXTERNAL_SAT_SOLVER=
CBMCFLAGS=--external-smt2-solver $(PROOF_ROOT)/lib/z3_smt_only --z3

FUNCTION_NAME = mlk_indcpa_enc

# If this proof is found to consume huge amounts of RAM, you can set the
# EXPENSIVE variable. With new enough versions of the proof tools, this will
# restrict the number of EXPENSIVE CBMC jobs running at once. See the
# documentation in Makefile.common under the "Job Pools" heading for details.
# EXPENSIVE = true

# This function is large enough to need...
CBMC_OBJECT_BITS = 10

# If you require access to a file-local ("static") function or object to conduct
# your proof, set the following (and do not include the original source file
# ("mlkem/src/poly.c") in PROJECT_SOURCES).
# REWRITTEN_SOURCES = $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i
# include ../Makefile.common
# $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i_SOURCE = $(SRCDIR)/mlkem/src/poly.c
# $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i_FUNCTIONS = foo bar
# $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i_OBJECTS = baz
# Care is required with variables on the left-hand side: REWRITTEN_SOURCES must
# be set before including Makefile.common, but any use of variables on the
# left-hand side requires those variables to be defined. Hence, _SOURCE,
# _FUNCTIONS, _OBJECTS is set after including Makefile.common.

include ../Makefile.common
```

### `proofs/cbmc/poly_add/Makefile`

```text
# Copyright (c) The mlkem-native project authors
# SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = poly_add_harness

# This should be a unique identifier for this proof, and will appear on the
# Litani dashboard. It can be human-readable and contain spaces if you wish.
PROOF_UID = mlk_poly_add

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=
UNWINDSET +=

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly.c

CHECK_FUNCTION_CONTRACTS=mlk_poly_add
USE_FUNCTION_CONTRACTS=
APPLY_LOOP_CONTRACTS=on
USE_DYNAMIC_FRAMES=1

# Disable any setting of EXTERNAL_SAT_SOLVER, and choose SMT backend instead
EXTERNAL_SAT_SOLVER=
CBMCFLAGS=--smt2

FUNCTION_NAME = mlk_poly_add

# If this proof is found to consume huge amounts of RAM, you can set the
# EXPENSIVE variable. With new enough versions of the proof tools, this will
# restrict the number of EXPENSIVE CBMC jobs running at once. See the
# documentation in Makefile.common under the "Job Pools" heading for details.
# EXPENSIVE = true

# This function is large enough to need...
CBMC_OBJECT_BITS = 8

# If you require access to a file-local ("static") function or object to conduct
# your proof, set the following (and do not include the original source file
# ("mlkem/src/poly.c") in PROJECT_SOURCES).
# REWRITTEN_SOURCES = $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i
# include ../Makefile.common
# $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i_SOURCE = $(SRCDIR)/mlkem/src/poly.c
# $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i_FUNCTIONS = foo bar
# $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i_OBJECTS = baz
# Care is required with variables on the left-hand side: REWRITTEN_SOURCES must
# be set before including Makefile.common, but any use of variables on the
# left-hand side requires those variables to be defined. Hence, _SOURCE,
# _FUNCTIONS, _OBJECTS is set after including Makefile.common.

include ../Makefile.common
```

### `proofs/cbmc/poly_add/poly_add_harness.c`

```c
// Copyright (c) The mlkem-native project authors
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0 AND Apache-2.0

#include "poly.h"

void harness(void)
{
  mlk_poly *r, *b;
  mlk_poly_add(r, b);
}
```

### `proofs/cbmc/polyvec_add/Makefile`

```text
# Copyright (c) The mlkem-native project authors
# SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = polyvec_add_harness

# This should be a unique identifier for this proof, and will appear on the
# Litani dashboard. It can be human-readable and contain spaces if you wish.
PROOF_UID = mlk_polyvec_add

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly_k.c

CHECK_FUNCTION_CONTRACTS=mlk_polyvec_add
USE_FUNCTION_CONTRACTS=mlk_poly_add
APPLY_LOOP_CONTRACTS=on
USE_DYNAMIC_FRAMES=1

# Disable any setting of EXTERNAL_SAT_SOLVER, and choose SMT backend instead
EXTERNAL_SAT_SOLVER=
CBMCFLAGS=--smt2

FUNCTION_NAME = mlk_polyvec_add

# If this proof is found to consume huge amounts of RAM, you can set the
# EXPENSIVE variable. With new enough versions of the proof tools, this will
# restrict the number of EXPENSIVE CBMC jobs running at once. See the
# documentation in Makefile.common under the "Job Pools" heading for details.
# EXPENSIVE = true

# This function is large enough to need...
CBMC_OBJECT_BITS = 10

# If you require access to a file-local ("static") function or object to conduct
# your proof, set the following (and do not include the original source file
# ("mlkem/src/poly.c") in PROJECT_SOURCES).
# REWRITTEN_SOURCES = $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i
# include ../Makefile.common
# $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i_SOURCE = $(SRCDIR)/mlkem/src/poly.c
# $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i_FUNCTIONS = foo bar
# $(PROOFDIR)/<__SOURCE_FILE_BASENAME__>.i_OBJECTS = baz
# Care is required with variables on the left-hand side: REWRITTEN_SOURCES must
# be set before including Makefile.common, but any use of variables on the
# left-hand side requires those variables to be defined. Hence, _SOURCE,
# _FUNCTIONS, _OBJECTS is set after including Makefile.common.

include ../Makefile.common
```

### `proofs/cbmc/proof_guide.md`

````markdown
[//]: # (SPDX-License-Identifier: CC-BY-4.0)

# CBMC Proof Guide and Cookbook for mlkem-native

This document acts as a guide to how we develop proofs of mlkem-native's C code using
[CBMC](https://model-checking.github.io/cbmc-training/). It concentrates on the use of _contracts_ to achieve
_unbounded_ and _modular_ proofs of type-safety and correctness properties.

## Installation

Before you start, follow the installation instructions [here](README.md) to ensure you have all the
required tools installed at the right version.
It is not uncommon for proofs to fail or have significantly worse performance when switching to different tool versions.

## Scope

Our CBMC proofs confirm the absence of certain classes of undefined behaviour, such as integer overflow or out of bounds
memory accesses -- for the precise list of conditions checked, see the CBMC configuration in
[Makefile.common](Makefile.common). For many arithmetic functions, we additionally specify how they affect coefficient
bounds: For example, we show that the result of `mlk_poly_invntt_tomont()` has coefficients bound by
`MLK_INVNTT_BOUND`. Finally, some simple functions have their full functional behaviour specified: For example, the
specification of the constant-time `mlk_ct_memcmp()` shows that, functionally, it is just an ordinary `memcmp()`.

## CBMC annotations

CBMC proofs are largely automatic; there are no proof scripts as in interactive theorem proving. Instead, CBMC consumes
_annotated_ C code and checks that it does not exhibit the configured classes of undefined behaviour within the
context described by the annotations; if the annotations add further constraints, those are checked, too. For example, a
function contract annotation provides contextual assumptions about a function as _preconditions_ to CBMC, and adds
further _constraints_ for the program state at function return.

In mlkem-native, we use abbreviated forms of the CBMC annotations defined by macros in the [cbmc.h](../../mlkem/src/cbmc.h). We
now list the most prominent.

### Function contracts

A _function contract_ can be added where a function is declared. For `static` functions where the sites of
declaration and definition coincide, it is part of the definition. mlkem-native's syntax for function contracts is

```c
int foo(args...)
__contract(
  requires(...)
  ...
  requires(...)
  assigns(...)
  ensures(...)
  ...
  ensures(...)
);
```

Here, an arbitrary number of `requires` clauses can be used to specify assumptions made by the function, and an
arbitrary number of `ensures(...)` clauses specifies the post-condition. One also needs an `assigns(...)` clause
indicating the 'footprint' of the function, that is, the objects it changes.

### Pointer validity

When dealing with pointers, a very common precondition to encounter is `memory_no_alias(ptr, len)`. This asserts that
`ptr` is a valid pointer to a block of memory of length `len` bytes, that does not overlap with other memory regions
also described via `memory_no_alias(...)`. Hence, a function operating on `n` memory buffers will typically have `n`
instances of `memory_no_alias(...)` in its precondition.

Care has to be taken for functions where aliasing is needed. Aliasing constraints can be difficult to specify, and we
reduce it as much as possible in mlkem-native. For example, rather than having `mlk_poly_add(dst, src0, src1)` where `dst`
may overlap with `src0` or `src1`, we only have a destructive `mlk_poly_add(dst, src)` implementing `dst += src`, thereby
avoiding the need to specify an aliasing constraint.

Care also has to be taken when _invoking_ a function that has a contract with multiple `memory_no_alias(...)` clauses;
Here, CBMC will assert that the pointer arguments point to different C objects, rather than conducting a fine-grained
check of disjointness. This simplifies the constraints, but can be impeding for the user: For example, given `foo x[2]`
for some struct `foo`, you cannot pass `&foo[0]`, `&foo[1]` as arguments to a function specified using
`memory_no_alias(...)` for both, because `&foo[0]`, `&foo[1]` point to the same object. In mlkem-native, we sometimes
work around this by manually splitting statically-sized arrays into multiple separate objects.


### Maximum buffer sizes

CBMC assumes that allocated objects are less than `__CPROVER_max_malloc_size`
which is an an internal constant defined to be `SIZE_MAX >> (OBJECT_BITS + 1)`
for that particular run of CBMC, where `SIZE_MAX` is an implementation-defined
constant (declared in `stdint.h`) and `OBJECT_BITS` is a command-line parameter
with value typically in the range 8 .. 12

See the [memory bounds checking](https://diffblue.github.io/cbmc/memory-bounds-checking.html)
section of the CBMC manual for more details.

Pragmatically, `SIZE_MAX` will either be `2**64-1` or `2**32-1` depending on the
host platform, and we choose the largest value of `OBJECT_BITS` that is used
for all proofs in this repository.

This matters where a function takes a formal parameter `p` of some pointer type
`t` and a `len` parameter of type `size_t` that denotes the number of elements
pointed to by `p`, and those parameters are subject to a
`memory_no_alias(p, len * sizeof(t))` contract.

In such cases, len must be explicitly bounded to be less that or equal to
MLK_MAX_BUFFER_SIZE which might be defined in `cbmc.h` as:
```c
#define MLK_MAX_BUFFER_SIZE (SIZE_MAX >> 12)
```
and used, for example, as follows:
```c
void f(t *p, size_t len)
__contract__(
  requires(len * sizeof(t) <= MLK_MAX_BUFFER_SIZE)
  requires(memory_no_alias(p, len * sizeof(t)))
);
```

### Memory footprint

The most common way to specify memory footprint in `assigns(...)` clauses is via `memory_slice(ptr, len)`. This asserts
that the code in question may change the first `len` bytes starting from `ptr`.

There is also `object_whole(ptr)`, which more coarsely asserts that the entire object can change. This has to be used
with care: If a function precondition specifies `requires(memory_no_alias(ptr, 42))` and `assigns(object_whole(ptr))`
and is called in a context where `ptr` is, say, a slice of some larger structure, then the entire structure will be
marked as tainted by the function call. This is often not desired, hence the more fine-grained `memory_slice(...)` is
desirable.

### Quantifiers and bounds

If you need to specify a quantified condition for use in `ensures(...)` or `requires(...)`, you can use the
`forall(...)` wrapper. It has the shape `forall(k, low_bound, high_bound, condition)`, where `k` is a name for the
quantified variable `[low_bound, ..., high_bound-1]` the quantification range, and `condition` is the quantified
condition (usually depending on `k`).

A prominent condition built from `forall` are `array_bound`:
`array_bound(arr, idx_low, idx_high, value_low, value_high)` asserts that the values of the array `arr` within
`[idx_low, ..., idx_high - 1]` are within the range `[value_low, ..., value_high - 1]`. There is also `array_abs_bound(...)`
for absolute value constraints.

### Loop invariants

Loop invariants are specified using `__loop__(...)` as follows:

```c
for (...)
__loop__(
  assigns(...)
  invariant(...)
  ...
  invariant(...))
{
   ...
}
```

Here, one or more `invariant(...)` clauses describe the invariant maintained by the loop body. As for function
contracts, `assigns(...)` captures the footprint of the loop body.

## Common Patterns

### `for` loops

The most common, and easiest, pattern is a "for" loop that has a counter starting at 0, and counting up to some upper bound, like this:

```
unsigned i;
for (i = 0; i < C; i++) {
    S;
}
```

CBMC requires basic assigns, loop-invariant, and optionally a decreases contracts _in exactly that order_. The most
common pattern is:

```
unsigned i;
for (i = 0; i < C; i++)
__loop__(
  assigns(i, ...)   /* plus whatever else S does */
  invariant(i <= C) /* Counter invariant */
  invariant(...)    /* Further invariants */
  decreases(C - i))
{
    S;
}
```

Importantly, the `i <= C` in the invariant is _not_ a typo: CBMC places the invariant just _after_ the loop counter has
been incremented, but just _before_ the loop exit test, so it is possible for `i == C` at the invariant on the final
iteration of the loop.

### Iterating over an array for a `for` loop

A common pattern is doing something to every element of an array. An example would be setting every element of a
byte-array to 0x00 given a pointer to the first element and a length. Initially, we want to prove type safety of this
function, so we won't even bother with a post-condition. The function specification might look like this:

```
void zero_array_ts (uint8_t *dst, int len)
__contract__(
  requires(memory_no_alias(dst, len))
  assigns(object_whole(dst)));
```

As mentioned before, the `memory_no_alias(dst,len)` in the precondition means that the pointer value `dst` is not `NULL`
and is pointing to at least `len` bytes of data. The `assigns` contract (in this case) means that when the function
returns, it promises to have updated the whole object pointed to by dst - in this case `len` bytes of data.

The body:

```
void zero_array_ts (uint8_t *dst, int len)
{
    unsigned i;
    for (i = 0; i < len; i++)
    __loop__(
      assigns(i, object_whole(dst))
      invariant(i <= len)
      decreases(len - i))
    {
        dst[i] = 0;
    }
}
```

For memory safety, the only interesting proof obligation for CBMC here is that the assignment `dst[i]` is valid. This
requires a proof that `i < len` which is trivially discharged given the loop invariant `i <= len`, plus the fact that
the loop has not terminated, and hence `i < len`.

### Correctness proof of zero_array

We can go further, and prove the correctness of that function by adding a post-condition, and extending the loop
invariant, as follows:

```
void zero_array_correct (uint8_t *dst, int len)
__contract__(
  requires(memory_no_alias(dst, len))
  assigns(object_whole(dst))
  ensures(forall(k, 0, len, dst[k] == 0)));
```

The body is the same, but now with a stronger loop invariant. The invariant says that "after j loop iterations, we've
zeroed the first j elements of the array", so:

```
void zero_array_correct (uint8_t *dst, int len)
{
    unsigned i;
    for (i = 0; i < len; i++)
    __loop__(
      assigns(i, object_whole(dst))
      invariant(i <= len)
      invariant(forall(j, 0, i, dst[j] == 0))
      decreases(len - i))
    {
        dst[i] = 0;
    }
}
```

Things to note:
1. The type of the quantified variable is `unsigned`.
2. Don't overload your program variables with quantified variables inside your forall contracts. It get confusing if you
   do.

Note that the invariant `invariant(forall(j, 0, i, dst[j] == 0))` is vacuous at loop entry, where `i == 0` and the
premise `j < i` of the bounded quantification in `forall(...)` is therefore unsatisfiable (remember that `i,j` are
`unsigned`). This pattern comes up frequently when one reasons about slices of arrays, and one or more of the slices has
a "null range" at either the loop entry or exit, and therefore that particular quantified constraint is vacuously
true.

## Invariant && loop-exit ==> post-condition

When the loop completes, CBMC reasons about the following code (if any) based on the combination of (a) loop invariant,
and (b) loop exit condition. In the simplest case where there is no code following the loop, this means that the loop
invariant and exit condition together should imply the function's post-condition.

For the example above, we need to prove:

```
// Loop invariant
(i <= len && forall(j, 0, j < i, dst[j] == 0))
&&
// Loop exit condition must be TRUE, so
i == len)

===>

// Post-condition
forall(k, 0, len, dst[k] == 0)
```

which holds by rewriting `i` by `len` in the loop invariant.

## Recipe to prove a new function

If you want to develop a proof of a function, here are the basic steps.
1. Populate a proof directory
2. Update Makefile
3. Update harness function
4. Supply top-level contracts for the function
5. Supply loop-invariants (if required) and other interior contracts
6. Prove it!

These steps are expanded on in the following sub-sections.

### Populate a proof directory

For mlkem-native, proof directories lie below `cbmc`.

Create a new sub-directory in there, where the name of the directory is the name of the function. You don't need a
namespacing prefix.

That directory needs to contain 2 files.

* Makefile
* XXX_harness.c

where "XXX" is the name of the function being proved - same as the directory name.

We suggest that you copy these files from an existing proof directory and modify the it according to your needs.

### Update Makefile

The `Makefile` sets options and targets for this proof. Let's imagine that the function we want to prove is called `XXX`
(without namespacing prefix).

Edit the Makefile and update the definition of the following variables:

* HARNESS_FILE - should be `XXX_harness`
* PROOF_UID - should be `XXX`
* PROJECT_SOURCES - should the files containing the source code of XXX
* CHECK_FUNCTION_CONTRACTS - set to the `XXX`, but including the `mlk_` prefix if required
* USE_FUNCTION_CONTRACTS - a list of functions that `XXX` calls where you want CBMC to use the contracts of the called
  function for proof, rather than 'inlining' the called function for proof. Include the `mlk_` prefix if
  required
* EXTERNAL_SAT_SOLVER - should _always_ be "nothing" to prevent CBMC selecting a SAT backend over the selected SMT backend.
* CBMCFLAGS - additional flags to pass to the final run of CBMC. This is normally set to `--smt2` which tells CBMC to
  run Z3 as its underlying solver. Can also be set to `--bitwuzla` which is sometimes faster than Z3 for some functions.
* FUNCTION_NAME - set to `XXX` with the `mlk_` prefix if required
* CBMC_OBJECT_BITS. Normally set to 8, but might need to be increased if CBMC runs out of memory for this proof.

For documentation of these (and the other) options, see the [cbmc/Makefile.common](Makefile.common) file.

The `USE_FUNCTION_CONTRACTS` option should be used where possible, since contracts enable modular proof, which is far more efficient
 than inlining, which tends to explode in complexity for higher-level functions.

#### Z3 or Bitwuzla?

We have found that it's better to use Bitwuzla in the initial stages of developing and debugging a new proof.

When Z3 finds that a proof is "sat" (i.e. not true), it tries to produce a counter-example to show you what's
wrong. Unfortunately, recent versions of Z3 can produce quantified expressions as output that cannot be currently
understood by CBMC. This leads CBMC to fail with an error such as

```
SMT2 solver returned non-constant value for variable Bxxx
```

This is not helpful when trying to understand a failed proof. Bitwuzla works better and produces reliable counter-examples.

Once a proof is working OK, you may revert to Z3 to check if it _also_ passes with Z3, and perhaps faster. If it does,
then keep Z3 as the selected prover. If not, then stick with Bitwuzla.

#### Selecting custom options for Z3 or Bitwuzla

By default, CBMC invokes provers with no special command-line options. If you want to pass additional flags to the prover,
e.g. to improve proof performance, you can create a small wrapper script and pass it to CBMC via `--external-smt2-solver XXX` (introduced in 6.8.0).

An example of such a script is [lib/z3_smt_only](lib/z3_smt_only) which looks like this:

```
#!/usr/bin/env bash
z3 tactic.default_tactic=smt "$@"
```

There is also a script [lib/z3_bv_sort](lib/z3_bv_sort) which looks like this:

```
#!/usr/bin/env bash
z3 rewriter.bv_sort_ac "$@"
```

Both these extra options have been found to be effective in improving Z3's performance in some cases.

To select the special prover, we update the proof `Makefile` for a particular function, replacing the
`--smt2` or `--bitwuzla` option with `--external-smt2-solver`.  For example, the proof of
`polyvec_add()` is much faster using the `z3_bv_sort` wrapper, so we change the `Makefile`, replacing

```
CBMCFLAGS=--smt2
```
with
```
CBMCFLAGS=--external-smt2-solver $(PROOF_ROOT)/lib/z3_bv_sort --z3
```
Note that we still need the ``--z3`` option now to inform CBMC to generate SMTLib specifically for Z3.

### Update harness function

The file `XXX_harness.c` should declare a single function called `XXX_harness()` that calls `XXX` exactly once, with
appropriately typed actual parameters. The actual parameters should be variables of the simplest type possible, and
should be _uninitialized_. Where a pointer value is required, create an uninitialized variable of that pointer type. Do
_not_ pass the address of a stack-allocated object.

For example, if a function f() expects a single parameter which is a pointer to some struct s:
```
void f(s *x)
requires(memory_no_alias(x, sizeof(s));
```
then the harness should contain
```
  s *a; // uninitialized raw pointer
  f(a);
```
The harness should _not_ contain
```
  s a;
  f(&a);
```

Using contracts, this harness function should not need to contain any CBMC `assume` or `assert` statements at all.

### Supply top-level contracts

Add a `__contract(...)__` contract in the header defining the function-under-proof. If the function is `static`, add the
`__contract__(...)` in the `.c` file at point of definition. As mentioned before, the pattern is as follows:

```c
return_type function_name(arg0, arg1, ...)
__contract__(
  requires()
  assigns()
  ensures());
```

or

```c
return_type function_name(arg0, arg1, ...)
__contract__(
  requires()
  assigns()
  ensures())
{
   ...
}
```

Note that when added to a declaration, the contract has to come before the final semicolon concluding the declaration.

### Interior contracts and loop invariants

If XXX contains no loop statements, then you might be able to just skip this step. Otherwise, add `__loop__(...)`
annotations to every loop in the function under proof.

### Prove it!

Proof of a single function can be run from the proof directory for that function with `make result`.

This produces `logs/result.txt` in plaintext format.

Before pushing a new proof for a new function, make sure that _all_ proofs run OK from the [proofs/cbmc](./) directory with

```
MLKEM_K=3 ./run-cbmc-proofs.py --summarize -j$(nproc)
```

That will use `$(nproc)` processor cores to run the proofs.

### Debugging a proof

If a proof fails, you can run

```
make result VERBOSE=1 >log.txt
```

and then inspect `log.txt` to see the exact sequence of commands that has been run. With that, you should be able to reproduce a failure on the command-line directly.

### Debugging a proof - additional proof targets to get GOTO and SMT files

The `Makefile.common` also contains make targets that can be used to generate the intermediate files
for inspection, but without actually running the (time consuming) provers at all.

`make goto` generates all the GOTO files (in `gotos/*.goto`) and then stops. For a function
x(), the final GOTO file ends up in `gotos/x_harness.goto`.

There are also targets that generate the SMT proof files, but without actually running the selected prover.

For a function x(), (so you're in sub-directory `proofs/cbmc/x`), you can do:

`make smt` generates `gotos/x_harness.smt2` for the prover selected in the `Makefile` (which must be one
of Z3, Bitwuzla, or CVC5)

`make smtz` generates `gotos/x_harness.smtz` but forces generation for the Z3 prover, ignoring the prover
selected in the `Makefile`. Similarly

`make smtb` generates `gotos/x_harness.smtb` but forces generation for Bitwuzla.

`make smtc` generates `gotos/x_harness.smtb` but forces generation for cvc5.

Finally,

`make smtall` generates SMT files for all three provers as above.

The final target is useful to generate SMT files for all three provers to see which one is
most successful and/or fastest on a particular problem.

## Worked Example - proving mlk_poly_tobytes()

This section follows the recipe above, and adds actual settings, contracts and command to prove the `mlk_poly_tobytes()` function.

### Populate a proof directory

The proof directory is [proofs/cbmc/poly_tobytes](poly_tobytes).

### Update Makefile

The significant changes are:
```
HARNESS_FILE = poly_tobytes_harness
PROOF_UID = mlk_poly_tobytes
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly.c
CHECK_FUNCTION_CONTRACTS=mlk_poly_tobytes
USE_FUNCTION_CONTRACTS=
FUNCTION_NAME = mlk_poly_tobytes
```
Note that `USE_FUNCTION_CONTRACTS` is left empty since `mlk_poly_tobytes()` is a leaf function that does not call any other functions at all.

### Update harness function

`mlk_poly_tobytes()` has a simple API, requiring two parameters, so the harness function is:

```
void harness(void) {
  mlk_poly *a;
  uint8_t *r;

  /* Contracts for this function are in compress.h */
  mlk_poly_tobytes(r, a);
}
```

### Top-level contracts

The comments on `mlk_poly_tobytes()` give us a clear hint:

```
 * Arguments:   INPUT:
 *              - a: const pointer to input polynomial,
 *                with each coefficient in the range [0,1,..,Q-1]
 *              OUTPUT
 *              - r: pointer to output byte array
 *                   (of MLKEM_POLYBYTES bytes)
```
So we need to write a requires contract to constrain the ranges of the coefficients denoted by the parameter `a`. There
is no constraint on the output byte array, other than it must be the right length, which is given by the function
prototype.

We can use the macros in [mlkem/src/cbmc.h](../../mlkem/src/cbmc.h) to help, thus:

```
void mlk_poly_tobytes(uint8_t r[MLKEM_POLYBYTES], const mlk_poly *a)
__contract__(
  requires(memory_no_alias(a, sizeof(mlk_poly)))
  requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
  assigns(object_whole(r)));
```

`array_bound` is a macro that expands to a quantified expression that expresses that the elements of `a->coeffs` between
index values `0` (inclusive) and `MLKEM_N` (exclusive) are in the range `0` (inclusive) through `MLKEM_Q` (exclusive). See the macro definition in [mlkem/src/cbmc.h](../../mlkem/src/cbmc.h) for details.

### Interior contracts and loop invariants

`mlk_poly_tobytes` has a single loop statement:

```
  unsigned i;
  for (i = 0; i < MLKEM_N / 2; i++)
  { ... }
```

A candidate loop contract needs to state that:
1. The loop body assigns to variable `i` and the whole object pointed to by `r`.
2. Loop counter variable `i` is in range `0 .. MLKEM_N / 2` at the point of the loop invariant (remember the pattern above).
3. The loop terminates because the expression `MLKEM_N / 2 - i` decreases on every iteration.

Therefore, we add:

```
  unsigned i;
  for (i = 0; i < MLKEM_N / 2; i++)
  __loop__(
    assigns(i, object_whole(r))
    invariant(i <= MLKEM_N / 2)
    decreases(MLKEM_N / 2 - i))
  { ... }
```

Another small set of changes is required to make CBMC happy with the loop body. By default, CBMC is pedantic and warns
about conversions that truncate values or lose information via an implicit type conversion.

In the original version of the function, we have 3 lines, the first of which is:
```
r[3 * i + 0] = (t0 >> 0);
```
which has an implicit conversion from `uint16_t` to `uint8_t`. This is well-defined in C, but CBMC issues a warning just
in case. To make CBMC happy, we have to explicitly reduce the range of t0 with a bitwise mask, and use an explicit
conversion, thus:
```
r[3 * i + 0] = (uint8_t)(t0 & 0xFF);
```
and so on for the other two statements in the loop body.

### Prove it!

With those changes, CBMC completes the proof in about 10 seconds:

```
cd proofs/cbmc/poly_tobytes
make result
cat logs/result.txt
```
concludes
```
** 0 of 228 failed (1 iterations)
VERIFICATION SUCCESSFUL
```

We can also use the higher-level Python script to prove just that one function:

```
cd proofs/cbmc
MLKEM_K=3 ./run-cbmc-proofs.py --summarize -j$(nproc) -p poly_tobytes
```
yields
```
| Proof            | Status  |
|------------------|---------|
| mlk_poly_tobytes | Success |

```
````

### `test/bench/bench_components_mlkem.c`

```c
/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */
#include <inttypes.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../mlkem/src/kem.h"
#include "../../mlkem/src/randombytes.h"
#include "../../mlkem/src/sampling.h"
#include "hal.h"

#include "../../mlkem/src/fips202/fips202.h"
#include "../../mlkem/src/fips202/keccakf1600.h"
#include "../../mlkem/src/indcpa.h"
#include "../../mlkem/src/poly.h"
#include "../../mlkem/src/poly_k.h"

#ifndef MLK_BENCHMARK_NWARMUP
#define MLK_BENCHMARK_NWARMUP 50
#endif

#ifndef MLK_BENCHMARK_NITERATIONS
#define MLK_BENCHMARK_NITERATIONS 300
#endif

#ifndef MLK_BENCHMARK_NTESTS
#define MLK_BENCHMARK_NTESTS 20
#endif

static int cmp_uint64_t(const void *a, const void *b)
{
  return (int)((*((const uint64_t *)a)) - (*((const uint64_t *)b)));
}

#define CHECK(x)                                              \
  do                                                          \
  {                                                           \
    int rc;                                                   \
    rc = (x);                                                 \
    if (!rc)                                                  \
    {                                                         \
      fprintf(stderr, "ERROR (%s,%d)\n", __FILE__, __LINE__); \
      return 1;                                               \
    }                                                         \
  } while (0)


#define BENCH(txt, code)                                              \
  for (i = 0; i < MLK_BENCHMARK_NTESTS; i++)                          \
  {                                                                   \
    CHECK(randombytes((uint8_t *)data0, sizeof(data0)) == 0);         \
    CHECK(randombytes((uint8_t *)data1, sizeof(data1)) == 0);         \
    CHECK(randombytes((uint8_t *)data2, sizeof(data2)) == 0);         \
    CHECK(randombytes((uint8_t *)data3, sizeof(data3)) == 0);         \
    CHECK(randombytes((uint8_t *)data4, sizeof(data4)) == 0);         \
    for (j = 0; j < MLK_BENCHMARK_NWARMUP; j++)                       \
    {                                                                 \
      code;                                                           \
    }                                                                 \
                                                                      \
    t0 = get_cyclecounter();                                          \
    for (j = 0; j < MLK_BENCHMARK_NITERATIONS; j++)                   \
    {                                                                 \
      code;                                                           \
    }                                                                 \
    t1 = get_cyclecounter();                                          \
    (cyc)[i] = t1 - t0;                                               \
  }                                                                   \
  qsort((cyc), MLK_BENCHMARK_NTESTS, sizeof(uint64_t), cmp_uint64_t); \
  printf(txt " cycles=%" PRIu64 "\n",                                 \
         (cyc)[MLK_BENCHMARK_NTESTS >> 1] / MLK_BENCHMARK_NITERATIONS);

#define BENCH_NATIVE_OK(txt, call) \
  BENCH(txt, CHECK((call) != MLK_NATIVE_FUNC_FALLBACK))

static int bench(void)
{
  MLK_ALIGN uint64_t data0[1024];
  MLK_ALIGN uint64_t data1[1024];
  MLK_ALIGN uint64_t data2[1024];
  MLK_ALIGN uint64_t data3[1024];
  MLK_ALIGN uint64_t data4[1024];
  uint8_t nonce0 = 0, nonce1 = 1, nonce2 = 2, nonce3 = 3;
  uint64_t cyc[MLK_BENCHMARK_NTESTS];

  unsigned i, j;
  uint64_t t0, t1;

  BENCH("keccak-f1600-x1", mlk_keccakf1600_permute(data0))
  BENCH("keccak-f1600-x4", mlk_keccakf1600x4_permute(data0))
  BENCH("mlk_poly_rej_uniform",
        mlk_poly_rej_uniform((mlk_poly *)data0, (uint8_t *)data1))
  BENCH("mlk_poly_rej_uniform_x4",
        mlk_poly_rej_uniform_x4((mlk_poly *)data0, (mlk_poly *)data1,
                                (mlk_poly *)data2, (mlk_poly *)data3,
                                (uint8_t (*)[64])data4))

  /* mlk_poly */
  /* mlk_poly_compress_du */
  BENCH("mlk_poly_compress_du",
        mlk_poly_compress_du((uint8_t *)data0, (mlk_poly *)data1))

  /* mlk_poly_decompress_du */
  BENCH("mlk_poly_decompress_du",
        mlk_poly_decompress_du((mlk_poly *)data0, (uint8_t *)data1))

  /* mlk_poly_compress_dv */
  BENCH("mlk_poly_compress_dv",
        mlk_poly_compress_dv((uint8_t *)data0, (mlk_poly *)data1))

  /* mlk_poly_decompress_dv */
  BENCH("mlk_poly_decompress_dv",
        mlk_poly_decompress_dv((mlk_poly *)data0, (uint8_t *)data1))

  /* mlk_poly_tobytes */
  BENCH("mlk_poly_tobytes",
        mlk_poly_tobytes((uint8_t *)data0, (mlk_poly *)data1))

  /* mlk_poly_frombytes */
  BENCH("mlk_poly_frombytes",
        mlk_poly_frombytes((mlk_poly *)data0, (uint8_t *)data1))

  /* mlk_poly_frommsg */
  BENCH("mlk_poly_frommsg",
        mlk_poly_frommsg((mlk_poly *)data0, (uint8_t *)data1))

  /* mlk_poly_tomsg */
  BENCH("mlk_poly_tomsg", mlk_poly_tomsg((uint8_t *)data0, (mlk_poly *)data1))

  /* mlk_poly_getnoise_eta1_4x */
  BENCH("mlk_poly_getnoise_eta1_4x",
        mlk_poly_getnoise_eta1_4x((mlk_poly *)data0, (mlk_poly *)data1,
                                  (mlk_poly *)data2, (mlk_poly *)data3,
                                  (uint8_t *)data4, nonce0, nonce1, nonce2,
                                  nonce3))

#if MLKEM_K == 2 || MLKEM_K == 4
  /* mlk_poly_getnoise_eta2 */
  BENCH("mlk_poly_getnoise_eta2",
        mlk_poly_getnoise_eta2((mlk_poly *)data0, (uint8_t *)data1, nonce0))
#endif

#if MLKEM_K == 2
  /* mlk_poly_getnoise_eta1122_4x */
  BENCH("mlk_poly_getnoise_eta1122_4x",
        mlk_poly_getnoise_eta1122_4x((mlk_poly *)data0, (mlk_poly *)data1,
                                     (mlk_poly *)data2, (mlk_poly *)data3,
                                     (uint8_t *)data4, nonce0, nonce1, nonce2,
                                     nonce3))
#endif /* MLKEM_K == 2 */

  /* mlk_poly_tomont */
  BENCH("mlk_poly_tomont", mlk_poly_tomont((mlk_poly *)data0))

  /* mlk_poly_mulcache_compute */
  BENCH(
      "mlk_poly_mulcache_compute",
      mlk_poly_mulcache_compute((mlk_poly_mulcache *)data0, (mlk_poly *)data1))

  /* mlk_poly_reduce */
  BENCH("mlk_poly_reduce", mlk_poly_reduce((mlk_poly *)data0))

  /* mlk_poly_add */
  BENCH("mlk_poly_add", mlk_poly_add((mlk_poly *)data0, (mlk_poly *)data1))

  /* mlk_poly_sub */
  BENCH("mlk_poly_sub", mlk_poly_sub((mlk_poly *)data0, (mlk_poly *)data1))

  /* mlk_polyvec */
  /* mlk_polyvec_compress_du */
  BENCH("mlk_polyvec_compress_du",
        mlk_polyvec_compress_du((uint8_t *)data0, (const mlk_polyvec *)data1))

  /* mlk_polyvec_decompress_du */
  BENCH("mlk_polyvec_decompress_du",
        mlk_polyvec_decompress_du((mlk_polyvec *)data0, (uint8_t *)data1))

  /* mlk_polyvec_tobytes */
  BENCH("mlk_polyvec_tobytes",
        mlk_polyvec_tobytes((uint8_t *)data0, (const mlk_polyvec *)data1))

  /* mlk_polyvec_frombytes */
  BENCH("mlk_polyvec_frombytes",
        mlk_polyvec_frombytes((mlk_polyvec *)data0, (uint8_t *)data1))

  /* mlk_polyvec_ntt */
  BENCH("mlk_polyvec_ntt", mlk_polyvec_ntt((mlk_polyvec *)data0))

  /* mlk_polyvec_invntt_tomont */
  BENCH("mlk_polyvec_invntt_tomont",
        mlk_polyvec_invntt_tomont((mlk_polyvec *)data0))

  /* mlk_polyvec_basemul_acc_montgomery_cached */
  BENCH("mlk_polyvec_basemul_acc_montgomery_cached",
        mlk_polyvec_basemul_acc_montgomery_cached(
            (mlk_poly *)data0, (const mlk_polyvec *)data1,
            (const mlk_polyvec *)data2, (const mlk_polyvec_mulcache *)data3))

  /* mlk_polyvec_mulcache_compute */
  BENCH("mlk_polyvec_mulcache_compute",
        mlk_polyvec_mulcache_compute((mlk_polyvec_mulcache *)data0,
                                     (const mlk_polyvec *)data1))

  /* mlk_polyvec_reduce */
  BENCH("mlk_polyvec_reduce", mlk_polyvec_reduce((mlk_polyvec *)data0))

  /* mlk_polyvec_add */
  BENCH("mlk_polyvec_add",
        mlk_polyvec_add((mlk_polyvec *)data0, (const mlk_polyvec *)data1))

  /* mlk_polyvec_tomont */
  BENCH("mlk_polyvec_tomont", mlk_polyvec_tomont((mlk_polyvec *)data0))

  /* indcpa */
  /* mlk_gen_matrix */
  BENCH("mlk_gen_matrix",
        mlk_gen_matrix((mlk_polymat *)data0, (uint8_t *)data1, 0))

  /* Native backend components */

#if defined(MLK_USE_NATIVE_NTT)
  BENCH_NATIVE_OK("mlk_ntt_native", mlk_ntt_native((int16_t *)data0));
#endif

#if defined(MLK_USE_NATIVE_INTT)
  BENCH_NATIVE_OK("mlk_intt_native", mlk_intt_native((int16_t *)data0));
#endif

#if defined(MLK_USE_NATIVE_POLY_REDUCE)
  BENCH_NATIVE_OK("mlk_poly_reduce_native",
                  mlk_poly_reduce_native((int16_t *)data0));
#endif

#if defined(MLK_USE_NATIVE_POLY_TOMONT)
  BENCH_NATIVE_OK("mlk_poly_tomont_native",
                  mlk_poly_tomont_native((int16_t *)data0));
#endif

#if defined(MLK_USE_NATIVE_POLY_MULCACHE_COMPUTE)
  BENCH_NATIVE_OK(
      "mlk_poly_mulcache_compute_native",
      mlk_poly_mulcache_compute_native((int16_t *)data0, (int16_t *)data1));
#endif

#if defined(MLK_USE_NATIVE_POLYVEC_BASEMUL_ACC_MONTGOMERY_CACHED)
#if MLKEM_K == 2
  BENCH_NATIVE_OK("mlk_polyvec_basemul_acc_montgomery_cached_k2_native",
                  mlk_polyvec_basemul_acc_montgomery_cached_k2_native(
                      (int16_t *)data0, (int16_t *)data1, (int16_t *)data2,
                      (int16_t *)data3));
#elif MLKEM_K == 3
  BENCH_NATIVE_OK("mlk_polyvec_basemul_acc_montgomery_cached_k3_native",
                  mlk_polyvec_basemul_acc_montgomery_cached_k3_native(
                      (int16_t *)data0, (int16_t *)data1, (int16_t *)data2,
                      (int16_t *)data3));
#elif MLKEM_K == 4
  BENCH_NATIVE_OK("mlk_polyvec_basemul_acc_montgomery_cached_k4_native",
                  mlk_polyvec_basemul_acc_montgomery_cached_k4_native(
                      (int16_t *)data0, (int16_t *)data1, (int16_t *)data2,
                      (int16_t *)data3));
#endif /* MLKEM_K == 4 */
#endif /* MLK_USE_NATIVE_POLYVEC_BASEMUL_ACC_MONTGOMERY_CACHED */

#if defined(MLK_USE_NATIVE_POLY_TOBYTES)
  BENCH_NATIVE_OK("mlk_poly_tobytes_native",
                  mlk_poly_tobytes_native((uint8_t *)data0, (int16_t *)data1));
#endif

#if defined(MLK_USE_NATIVE_POLY_FROMBYTES)
  BENCH_NATIVE_OK(
      "mlk_poly_frombytes_native",
      mlk_poly_frombytes_native((int16_t *)data0, (uint8_t *)data1));
#endif

#if defined(MLK_USE_NATIVE_REJ_UNIFORM)
  BENCH_NATIVE_OK(
      "mlk_rej_uniform_native",
      mlk_rej_uniform_native((int16_t *)data0, MLKEM_N, (uint8_t *)data1, 768));
#endif

#if MLKEM_K == 2 || MLKEM_K == 3
#if defined(MLK_USE_NATIVE_POLY_COMPRESS_D4)
  BENCH_NATIVE_OK(
      "mlk_poly_compress_d4_native",
      mlk_poly_compress_d4_native((uint8_t *)data0, (int16_t *)data1));
#endif

#if defined(MLK_USE_NATIVE_POLY_COMPRESS_D10)
  BENCH_NATIVE_OK(
      "mlk_poly_compress_d10_native",
      mlk_poly_compress_d10_native((uint8_t *)data0, (int16_t *)data1));
#endif

#if defined(MLK_USE_NATIVE_POLY_DECOMPRESS_D4)
  BENCH_NATIVE_OK(
      "mlk_poly_decompress_d4_native",
      mlk_poly_decompress_d4_native((int16_t *)data0, (uint8_t *)data1));
#endif

#if defined(MLK_USE_NATIVE_POLY_DECOMPRESS_D10)
  BENCH_NATIVE_OK(
      "mlk_poly_decompress_d10_native",
      mlk_poly_decompress_d10_native((int16_t *)data0, (uint8_t *)data1));
#endif
#endif /* MLKEM_K == 2 || MLKEM_K == 3 */

#if MLKEM_K == 4
#if defined(MLK_USE_NATIVE_POLY_COMPRESS_D5)
  BENCH_NATIVE_OK(
      "mlk_poly_compress_d5_native",
      mlk_poly_compress_d5_native((uint8_t *)data0, (int16_t *)data1));
#endif

#if defined(MLK_USE_NATIVE_POLY_COMPRESS_D11)
  BENCH_NATIVE_OK(
      "mlk_poly_compress_d11_native",
      mlk_poly_compress_d11_native((uint8_t *)data0, (int16_t *)data1));
#endif

#if defined(MLK_USE_NATIVE_POLY_DECOMPRESS_D5)
  BENCH_NATIVE_OK(
      "mlk_poly_decompress_d5_native",
      mlk_poly_decompress_d5_native((int16_t *)data0, (uint8_t *)data1));
#endif

#if defined(MLK_USE_NATIVE_POLY_DECOMPRESS_D11)
  BENCH_NATIVE_OK(
      "mlk_poly_decompress_d11_native",
      mlk_poly_decompress_d11_native((int16_t *)data0, (uint8_t *)data1));
#endif
#endif /* MLKEM_K == 4 */

#if defined(MLK_USE_FIPS202_X1_NATIVE)
  BENCH_NATIVE_OK("mlk_keccak_f1600_x1_native",
                  mlk_keccak_f1600_x1_native(data0));
#endif

#if defined(MLK_USE_FIPS202_X4_NATIVE)
  BENCH_NATIVE_OK("mlk_keccak_f1600_x4_native",
                  mlk_keccak_f1600_x4_native(data0));
#endif

#if defined(MLK_USE_FIPS202_X4_XOR_BYTES_NATIVE)
  BENCH_NATIVE_OK(
      "mlk_keccakf1600_xor_bytes_x4_native",
      mlk_keccakf1600_xor_bytes_x4_native(
          data0, (uint8_t *)data1, (uint8_t *)data2, (uint8_t *)data3,
          (uint8_t *)data4, 0, 25 * sizeof(uint64_t)));
#endif /* MLK_USE_FIPS202_X4_XOR_BYTES_NATIVE */

#if defined(MLK_USE_FIPS202_X4_EXTRACT_BYTES_NATIVE)
  BENCH_NATIVE_OK(
      "mlk_keccakf1600_extract_bytes_x4_native",
      mlk_keccakf1600_extract_bytes_x4_native(
          data0, (uint8_t *)data1, (uint8_t *)data2, (uint8_t *)data3,
          (uint8_t *)data4, 0, 25 * sizeof(uint64_t)));
#endif /* MLK_USE_FIPS202_X4_EXTRACT_BYTES_NATIVE */

  return 0;
}

int main(void)
{
  enable_cyclecounter();
  bench();
  disable_cyclecounter();

  return 0;
}
```

## 11. Authored PA-01 Through PA-08 Artefact Contents

### `cleanroom_mlk_poly_add_fips_relational_harness_v2.c`

```c
/*
 * Clean-room, FIPS-domain, relational CBMC harness for mlk_poly_add
 *
 * Target repository:
 *   pq-code-package/mlkem-native
 * Target commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 *
 * Research scope:
 *   - independently authored harness;
 *   - does not require or invoke an existing mlk_poly_add harness;
 *   - exercises the real two-argument in-place implementation;
 *   - uses canonical FIPS 203 representatives: 0 <= coefficient < q;
 *   - checks implementation-level addition and its modulo-q meaning;
 *   - adds relational/metamorphic checks (commutativity and identity);
 *   - keeps all target-call objects disjoint by construction.
 *
 * Important limitation:
 *   This is a FIPS-canonical input-domain harness. It does not yet cover
 *   every non-canonical signed int16_t representation that production
 *   call sites may use internally.
 *
 * Integration:
 *   Compile this harness with the repository's production poly.c and the
 *   same configuration/include flags used by the selected ML-KEM build.
 *   Do not enable function-contract replacement or loop-contract
 *   transformation for the clean-room BMC run.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * A local automatic object without an initializer is nondeterministic in CBMC.
 * Providing a function body avoids CBMC's "no body for callee" property while
 * preserving symbolic input generation.
 */
static int16_t cleanroom_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;

  mlk_poly a_before;
  mlk_poly b_before;

  mlk_poly sum_ab;
  mlk_poly sum_ba;

  mlk_poly zero;
  mlk_poly identity_result;

  unsigned i;
  int32_t expected_integer_sum;
  int32_t expected_fips_residue;

  /*
   * Bind the experiment to the FIPS 203 ring parameters used by this
   * target. These are assertions, not assumptions: a configuration drift
   * must make the experiment fail visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PARAMETER_BINDING: MLKEM_N must equal FIPS n=256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PARAMETER_BINDING: MLKEM_Q must equal FIPS q=3329");

  /*
   * Generate two arbitrary polynomials using unsigned canonical
   * representatives of Z_q. The bounds imply:
   *
   *   0 <= a[i] + b[i] <= 2*q - 2 = 6656,
   *
   * so the implementation's in-place int16_t result cannot overflow.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = cleanroom_nondet_int16();
    b.coeffs[i] = cleanroom_nondet_int16();

    __CPROVER_assume(a.coeffs[i] >= 0);
    __CPROVER_assume(a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[i] >= 0);
    __CPROVER_assume(b.coeffs[i] < MLKEM_Q);

    zero.coeffs[i] = 0;
  }

  /*
   * Freeze the mathematical inputs before any target call.
   */
  a_before = a;
  b_before = b;

  /*
   * Three distinct-object experiments:
   *
   *   sum_ab          := a + b
   *   sum_ba          := b + a
   *   identity_result := a + 0
   *
   * Every output object is disjoint from its read-only operand.
   */
  sum_ab = a;
  sum_ba = b;
  identity_result = a;

  mlk_poly_add(&sum_ab, &b);
  mlk_poly_add(&sum_ba, &a);
  mlk_poly_add(&identity_result, &zero);

  for (i = 0; i < MLKEM_N; i++)
  {
    expected_integer_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)b_before.coeffs[i];

    expected_fips_residue = expected_integer_sum % (int32_t)MLKEM_Q;

    /*
     * P1: Exact accumulator semantics before modular normalization.
     */
    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] == expected_integer_sum,
        "P1_EXACT_SUM: output coefficient equals the mathematical integer sum");

    /*
     * P2: Derived implementation bound for canonical FIPS inputs.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] >= 0,
        "P2_LOWER_BOUND: canonical-input sum is nonnegative");

    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] <=
            (2 * (int32_t)MLKEM_Q) - 2,
        "P2_UPPER_BOUND: canonical-input sum is at most 2*q-2");

    /*
     * P3: Refinement to FIPS polynomial addition.
     *
     * mlk_poly_add intentionally need not reduce its stored coefficient.
     * Its residue modulo q must nevertheless equal FIPS addition in Z_q.
     */
    __CPROVER_assert(
        ((int32_t)sum_ab.coeffs[i] % (int32_t)MLKEM_Q) ==
            expected_fips_residue,
        "P3_FIPS_RESIDUE: stored sum represents coefficient addition modulo q");

    /*
     * P4: Read-only operands and frozen inputs are not modified.
     */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "P4_LEFT_INPUT_FRAME: read-only use of a leaves a unchanged");

    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "P4_RIGHT_INPUT_FRAME: read-only use of b leaves b unchanged");

    __CPROVER_assert(
        zero.coeffs[i] == 0,
        "P4_ZERO_FRAME: zero operand remains unchanged");

    /*
     * P5: Relational/metamorphic commutativity.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] == sum_ba.coeffs[i],
        "P5_COMMUTATIVITY: a+b equals b+a coefficient-wise");

    /*
     * P6: Relational/metamorphic additive identity.
     */
    __CPROVER_assert(
        identity_result.coeffs[i] == a_before.coeffs[i],
        "P6_IDENTITY: a+0 equals a coefficient-wise");
  }

  return 0;
}
```

### `run_cleanroom_mlk_poly_add_cbmc_v2.sh`

```bash
#!/usr/bin/env bash
#
# Build and verify the independently authored mlk_poly_add harness.
#
# Run this script from the root of the mlkem-native repository:
#
#   chmod +x run_cleanroom_mlk_poly_add_cbmc_v2.sh
#   ./run_cleanroom_mlk_poly_add_cbmc_v2.sh 768
#
# The optional first argument is 512, 768, or 1024. The default is 768.
#

set -uo pipefail

EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="cleanroom_mlk_poly_add_fips_relational_harness_v2.c"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/mlk_poly_add_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/cleanroom_poly_add.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] || [ ! -f "mlkem/src/poly.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

if [ ! -f "${HARNESS}" ]; then
  echo "ERROR: ${HARNESS} is not present in the repository root." >&2
  exit 2
fi

mkdir -p "${OUT_DIR}"

CURRENT_COMMIT="$(git rev-parse HEAD)"
{
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1
sha256sum "${HARNESS}" > "${OUT_DIR}/harness_sha256.txt"
cp "${HARNESS}" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  echo "ERROR: repository commit does not match the clean-room target." | tee \
    "${OUT_DIR}/commit_mismatch.txt"
  echo "Expected: ${EXPECTED_COMMIT}" | tee -a "${OUT_DIR}/commit_mismatch.txt"
  echo "Actual:   ${CURRENT_COMMIT}" | tee -a "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

# Deliberately do NOT define the preprocessor macro CBMC here.
# This keeps the repository's embedded __contract__ and __loop__ annotations
# disabled while the target C body is directly bounded-model-checked.
#
# common.h already defines MLK_BUILD_INTERNAL for this source build.
# Do not redefine it on the command line, which only creates a warning.
# Native arithmetic remains disabled because
# MLK_CONFIG_USE_NATIVE_BACKEND_ARITH is not defined.
BUILD_COMMAND=(
  goto-cc
  -I.
  -Imlkem
  -Imlkem/src
  -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
  "${HARNESS}"
  mlkem/src/poly.c
  -o "${GOTO_MODEL}"
)

printf '%q ' "${BUILD_COMMAND[@]}" > "${OUT_DIR}/build_command.txt"
printf '\n' >> "${OUT_DIR}/build_command.txt"

echo "===== BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  echo "BUILD FAILED. Send goto_cc_build.log back for diagnosis."
  exit "${BUILD_EXIT}"
fi

CBMC_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
  --trace
)

printf '%q ' "${CBMC_COMMAND[@]}" > "${OUT_DIR}/cbmc_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_command.txt"

echo
echo "===== RUNNING CBMC ====="
"${CBMC_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/cbmc_output.txt"
CBMC_EXIT=${PIPESTATUS[0]}
echo "${CBMC_EXIT}" > "${OUT_DIR}/cbmc.exit"

# Create a machine-readable second result. Its exit code should agree with
# the text run. This second invocation omits --trace to keep JSON smaller.
CBMC_JSON_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
  --json-ui
)

"${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_output.json" 2> \
  "${OUT_DIR}/cbmc_json_stderr.txt"
CBMC_JSON_EXIT=$?
echo "${CBMC_JSON_EXIT}" > "${OUT_DIR}/cbmc_json.exit"

{
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_text_exit=${CBMC_EXIT}"
  echo "cbmc_json_exit=${CBMC_JSON_EXIT}"
  if [ "${BUILD_EXIT}" -eq 0 ] &&
     [ "${CBMC_EXIT}" -eq 0 ] &&
     [ "${CBMC_JSON_EXIT}" -eq 0 ]; then
    echo "final_status=VERIFICATION_SUCCESSFUL"
  else
    echo "final_status=FAILED_OR_INCONCLUSIVE"
  fi
} > "${OUT_DIR}/summary.txt"

echo
echo "===== SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

exit "${CBMC_EXIT}"
```

### `pa02_mlk_poly_add_full_signed_contract_valid_harness.c`

```c
/*
 * PA-02: Full signed/non-canonical contract-valid CBMC harness
 *         for mlk_poly_add
 *
 * Target repository:
 *   pq-code-package/mlkem-native
 * Target commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 *
 * Verification objective:
 *   Verify the portable C mlk_poly_add implementation for every pair of
 *   signed int16_t coefficient arrays whose coefficient-wise mathematical
 *   sums are representable in int16_t.
 *
 * This is broader than the PA-01 canonical FIPS-domain harness:
 *   - coefficients may be negative;
 *   - coefficients may be greater than or equal to q;
 *   - coefficients may be any int16_t value;
 *   - the only arithmetic-domain restriction is that each exact sum fits
 *     in int16_t, which is the function's necessary representability
 *     precondition.
 *
 * The harness:
 *   - directly executes the production function body;
 *   - keeps target-call objects disjoint by construction;
 *   - proves exact signed addition;
 *   - proves modulo-q congruence for signed/non-canonical representatives;
 *   - proves read-only operand preservation;
 *   - checks commutativity and additive identity;
 *   - relies on CBMC safety instrumentation for bounds, pointers,
 *     overflows, conversions, shifts, and complete loop unwinding.
 *
 * Important scope:
 *   This harness does not claim that an exact mathematical sum can be
 *   represented when it is outside [INT16_MIN, INT16_MAX]. PA-03 will be
 *   the unrestricted negative-control experiment demonstrating why that
 *   precondition is necessary.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * CBMC treats the uninitialised local value as symbolic. Supplying a real
 * function body avoids a "no body for callee" verification failure.
 */
static int16_t pa02_nondet_int16(void)
{
  int16_t value;
  return value;
}

/*
 * Convert any signed integer representative to the canonical residue
 * 0..q-1. C remainder may be negative, so one q is added when needed.
 */
static int32_t pa02_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;

  mlk_poly a_before;
  mlk_poly b_before;

  mlk_poly sum_ab;
  mlk_poly sum_ba;

  mlk_poly zero;
  mlk_poly identity_result;

  unsigned i;
  int32_t mathematical_sum;
  int32_t actual_residue;
  int32_t expected_residue;
  int32_t canonical_operand_sum_residue;

  /*
   * Bind the experiment to the intended representation and FIPS ring
   * parameters. These are assertions rather than assumptions so that an
   * incompatible build fails visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PA02_PARAMETER_BINDING: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PA02_PARAMETER_BINDING: MLKEM_Q must equal 3329");
  __CPROVER_assert(INT16_MIN == -32768,
                   "PA02_REPRESENTATION_BINDING: INT16_MIN must equal -32768");
  __CPROVER_assert(INT16_MAX == 32767,
                   "PA02_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Generate arbitrary signed int16_t coefficients.
   *
   * The only semantic assumption is the necessary contract-validity
   * condition:
   *
   *   INT16_MIN <= a[i] + b[i] <= INT16_MAX.
   *
   * The addition used to state the assumption is performed in int32_t,
   * where every sum of two int16_t values is representable.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa02_nondet_int16();
    b.coeffs[i] = pa02_nondet_int16();

    mathematical_sum =
        (int32_t)a.coeffs[i] + (int32_t)b.coeffs[i];

    __CPROVER_assume(mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(mathematical_sum <= (int32_t)INT16_MAX);

    zero.coeffs[i] = 0;
  }

  a_before = a;
  b_before = b;

  sum_ab = a;
  sum_ba = b;
  identity_result = a;

  /*
   * PA-02 uses legal, disjoint target calls. The explicit pointer
   * assertions make the object-separation boundary visible in the result.
   */
  __CPROVER_assert(&sum_ab != &b,
                   "PA02_DISJOINTNESS: sum_ab and b are distinct objects");
  __CPROVER_assert(&sum_ba != &a,
                   "PA02_DISJOINTNESS: sum_ba and a are distinct objects");
  __CPROVER_assert(&identity_result != &zero,
                   "PA02_DISJOINTNESS: identity_result and zero are distinct");

  mlk_poly_add(&sum_ab, &b);
  mlk_poly_add(&sum_ba, &a);
  mlk_poly_add(&identity_result, &zero);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)b_before.coeffs[i];

    actual_residue = pa02_mod_q((int32_t)sum_ab.coeffs[i]);
    expected_residue = pa02_mod_q(mathematical_sum);

    canonical_operand_sum_residue =
        pa02_mod_q(
            pa02_mod_q((int32_t)a_before.coeffs[i]) +
            pa02_mod_q((int32_t)b_before.coeffs[i]));

    /*
     * P1: Exact implementation-level signed addition over the complete
     * contract-valid int16_t domain.
     */
    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] == mathematical_sum,
        "PA02_P1_EXACT_SIGNED_SUM: result equals the exact int32 mathematical sum");

    /*
     * P2: The concrete signed/non-canonical result represents the correct
     * abstract element of Z_q.
     */
    __CPROVER_assert(
        actual_residue == expected_residue,
        "PA02_P2_MOD_Q_CONGRUENCE: result is congruent to the exact sum modulo q");

    /*
     * P3: The same result agrees with addition of the canonical residues
     * of both potentially signed/non-canonical operands.
     */
    __CPROVER_assert(
        actual_residue == canonical_operand_sum_residue,
        "PA02_P3_CANONICAL_RESIDUE_REFINEMENT: result matches canonical operand addition");

    /*
     * P4: Read-only operands remain unchanged across the target calls.
     */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "PA02_P4_LEFT_INPUT_FRAME: a remains unchanged when used read-only");

    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "PA02_P4_RIGHT_INPUT_FRAME: b remains unchanged when used read-only");

    __CPROVER_assert(
        zero.coeffs[i] == 0,
        "PA02_P4_ZERO_FRAME: zero remains unchanged when used read-only");

    /*
     * P5: Relational commutativity over every contract-valid signed pair.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] == sum_ba.coeffs[i],
        "PA02_P5_COMMUTATIVITY: a+b equals b+a coefficient-wise");

    /*
     * P6: Additive identity over the complete int16_t domain.
     */
    __CPROVER_assert(
        identity_result.coeffs[i] == a_before.coeffs[i],
        "PA02_P6_IDENTITY: a+0 equals a coefficient-wise");
  }

  return 0;
}
```

### `run_pa02_mlk_poly_add_full_signed_cbmc.sh`

```bash
#!/usr/bin/env bash
#
# PA-02 runner:
# Verify mlk_poly_add over the complete signed/non-canonical
# contract-valid int16_t domain.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa02_mlk_poly_add_full_signed_cbmc.sh
#   ./run_pa02_mlk_poly_add_full_signed_cbmc.sh 768
#
# The optional first argument is 512, 768, or 1024. Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-02"
CAMPAIGN_SCOPE="full_signed_noncanonical_contract_valid_domain"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="pa02_mlk_poly_add_full_signed_contract_valid_harness.c"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa02_mlk_poly_add_signed_valid_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/pa02_mlk_poly_add.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] || [ ! -f "mlkem/src/poly.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

if [ ! -f "${HARNESS}" ]; then
  echo "ERROR: ${HARNESS} is not present in the repository root." >&2
  exit 2
fi

mkdir -p "${OUT_DIR}"

CURRENT_COMMIT="$(git rev-parse HEAD)"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Harness: ${HARNESS}"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1
sha256sum "${HARNESS}" > "${OUT_DIR}/harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
cp "${HARNESS}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-02 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

# Directly analyse the portable production C body:
#   - do not define the repository's CBMC annotation mode;
#   - do not enable native arithmetic;
#   - do not link any repository proof harness.
BUILD_COMMAND=(
  goto-cc
  -I.
  -Imlkem
  -Imlkem/src
  -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
  "${HARNESS}"
  mlkem/src/poly.c
  -o "${GOTO_MODEL}"
)

printf '%q ' "${BUILD_COMMAND[@]}" > "${OUT_DIR}/build_command.txt"
printf '\n' >> "${OUT_DIR}/build_command.txt"

echo "===== PA-02: BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  {
    echo "campaign=${CAMPAIGN_ID}"
    echo "build_exit=${BUILD_EXIT}"
    echo "final_status=BUILD_FAILED"
  } > "${OUT_DIR}/summary.txt"

  echo "BUILD FAILED. Preserve and return goto_cc_build.log."
  exit "${BUILD_EXIT}"
fi

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

CBMC_TEXT_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --trace
)

printf '%q ' "${CBMC_TEXT_COMMAND[@]}" > "${OUT_DIR}/cbmc_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_command.txt"

echo
echo "===== PA-02: RUNNING CBMC TEXT VERIFICATION ====="
"${CBMC_TEXT_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/cbmc_output.txt"
CBMC_TEXT_EXIT=${PIPESTATUS[0]}
echo "${CBMC_TEXT_EXIT}" > "${OUT_DIR}/cbmc.exit"

CBMC_JSON_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --json-ui
)

printf '%q ' "${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_json_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_json_command.txt"

echo
echo "===== PA-02: RUNNING CBMC JSON VERIFICATION ====="
"${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_output.json" 2> \
  "${OUT_DIR}/cbmc_json_stderr.txt"
CBMC_JSON_EXIT=$?
echo "${CBMC_JSON_EXIT}" > "${OUT_DIR}/cbmc_json.exit"

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_text_exit=${CBMC_TEXT_EXIT}"
  echo "cbmc_json_exit=${CBMC_JSON_EXIT}"

  if [ "${BUILD_EXIT}" -eq 0 ] &&
     [ "${CBMC_TEXT_EXIT}" -eq 0 ] &&
     [ "${CBMC_JSON_EXIT}" -eq 0 ]; then
    echo "final_status=VERIFICATION_SUCCESSFUL"
  else
    echo "final_status=FAILED_OR_INCONCLUSIVE"
  fi
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-02 SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

exit "${CBMC_TEXT_EXIT}"
```

### `pa03_mlk_poly_add_unrestricted_negative_control_harness.c`

```c
/*
 * PA-03: Unrestricted signed-domain negative-control harness
 *         for mlk_poly_add
 *
 * Scientific purpose:
 *   Demonstrate that exact mathematical addition cannot hold for every
 *   arbitrary pair of int16_t coefficient arrays because some sums are
 *   outside the representable int16_t range.
 *
 * Expected CBMC outcome:
 *   VERIFICATION FAILED
 *
 * Expected campaign interpretation:
 *   EXPECTED_COUNTEREXAMPLE_CONFIRMED
 *
 * This expected failure is the successful scientific result of PA-03.
 * It validates that the representability precondition used by PA-02 is
 * necessary rather than an arbitrary assumption added to force success.
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * CBMC treats the uninitialised local value as symbolic.
 * A concrete function body avoids a no-body verification failure.
 */
static int16_t pa03_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;

  mlk_poly a_before;
  mlk_poly b_before;
  mlk_poly result;

  unsigned i;
  int32_t mathematical_sum;

  /*
   * Bind the experiment to the intended ML-KEM and integer
   * representation parameters. These are assertions, not assumptions.
   */
  __CPROVER_assert(
      MLKEM_N == 256,
      "PA03_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA03_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA03_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA03_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Generate completely unrestricted signed int16_t arrays.
   *
   * Deliberately absent:
   *   - no canonical FIPS-domain assumptions;
   *   - no non-negative assumptions;
   *   - no safe-sum or representability assumptions;
   *   - no restriction preventing a mathematical sum from lying
   *     outside [INT16_MIN, INT16_MAX].
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa03_nondet_int16();
    b.coeffs[i] = pa03_nondet_int16();
  }

  a_before = a;
  b_before = b;
  result = a;

  /*
   * Keep the target call legal with respect to object separation.
   * PA-03 changes only the arithmetic input domain; it does not mix the
   * later aliasing diagnostic into this negative-control experiment.
   */
  __CPROVER_assert(
      &result != &b,
      "PA03_DISJOINTNESS: result and b are distinct objects");

  /*
   * Directly execute the production portable-C implementation.
   */
  mlk_poly_add(&result, &b);

  for (i = 0; i < MLKEM_N; i++)
  {
    /*
     * int32_t can represent every exact sum of two int16_t values.
     */
    mathematical_sum =
        (int32_t)a_before.coeffs[i] +
        (int32_t)b_before.coeffs[i];

    /*
     * PA03-P1 is intentionally too strong over the unrestricted domain.
     *
     * CBMC is expected to refute it using a pair whose exact sum is
     * outside the int16_t range. For example, a value equivalent to
     * INT16_MAX + 1 or INT16_MIN - 1 is sufficient.
     */
    __CPROVER_assert(
        (int32_t)result.coeffs[i] == mathematical_sum,
        "PA03_P1_UNRESTRICTED_EXACT_SUM: exact addition for every arbitrary int16_t pair");

    /*
     * This frame property should remain valid even though PA03-P1 fails.
     * It helps distinguish the intended arithmetic-domain failure from
     * unintended mutation of the read-only operand.
     */
    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "PA03_P2_RIGHT_INPUT_FRAME: b remains unchanged");
  }

  return 0;
}
```

### `run_pa03_mlk_poly_add_unrestricted_negative_control.sh`

```bash
#!/usr/bin/env bash
#
# PA-03 runner:
# Unrestricted signed-domain negative control for mlk_poly_add.
#
# IMPORTANT:
#   CBMC VERIFICATION FAILED is the expected low-level result.
#   EXPECTED_COUNTEREXAMPLE_CONFIRMED is the successful campaign result.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa03_mlk_poly_add_unrestricted_negative_control.sh
#   ./run_pa03_mlk_poly_add_unrestricted_negative_control.sh 768
#
# Optional parameter-set argument: 512, 768, or 1024.
# Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-03"
CAMPAIGN_SCOPE="unrestricted_signed_int16_negative_control"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="pa03_mlk_poly_add_unrestricted_negative_control_harness.c"
EXPECTED_MARKER="PA03_P1_UNRESTRICTED_EXACT_SUM"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa03_mlk_poly_add_unrestricted_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/pa03_mlk_poly_add.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee grep; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] || [ ! -f "mlkem/src/poly.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

if [ ! -f "${HARNESS}" ]; then
  echo "ERROR: ${HARNESS} is not present in the repository root." >&2
  exit 2
fi

mkdir -p "${OUT_DIR}"

CURRENT_COMMIT="$(git rev-parse HEAD)"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected low-level CBMC result: VERIFICATION FAILED"
  echo "Expected campaign interpretation: EXPECTED_COUNTEREXAMPLE_CONFIRMED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Harness: ${HARNESS}"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1
sha256sum "${HARNESS}" > "${OUT_DIR}/harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
cp "${HARNESS}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-03 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

BUILD_COMMAND=(
  goto-cc
  -I.
  -Imlkem
  -Imlkem/src
  -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
  "${HARNESS}"
  mlkem/src/poly.c
  -o "${GOTO_MODEL}"
)

printf '%q ' "${BUILD_COMMAND[@]}" > "${OUT_DIR}/build_command.txt"
printf '\n' >> "${OUT_DIR}/build_command.txt"

echo "===== PA-03: BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  {
    echo "campaign=${CAMPAIGN_ID}"
    echo "expected_cbmc_result=VERIFICATION_FAILED"
    echo "build_exit=${BUILD_EXIT}"
    echo "final_status=BUILD_FAILED"
  } > "${OUT_DIR}/summary.txt"

  echo "PA-03 BUILD FAILED. This is not the expected scientific outcome."
  exit "${BUILD_EXIT}"
fi

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

CBMC_TEXT_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --trace
)

printf '%q ' "${CBMC_TEXT_COMMAND[@]}" > "${OUT_DIR}/cbmc_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_command.txt"

echo
echo "===== PA-03: RUNNING EXPECTED-FAILURE CBMC TEXT CHECK ====="
"${CBMC_TEXT_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/cbmc_output.txt"
CBMC_TEXT_EXIT=${PIPESTATUS[0]}
echo "${CBMC_TEXT_EXIT}" > "${OUT_DIR}/cbmc.exit"

CBMC_JSON_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --json-ui
)

printf '%q ' "${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_json_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_json_command.txt"

echo
echo "===== PA-03: RUNNING EXPECTED-FAILURE CBMC JSON CHECK ====="
"${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_output.json" 2> \
  "${OUT_DIR}/cbmc_json_stderr.txt"
CBMC_JSON_EXIT=$?
echo "${CBMC_JSON_EXIT}" > "${OUT_DIR}/cbmc_json.exit"

EXPECTED_ASSERTION_FAILURE="no"
NO_BODY_FAILURE="no"
VERIFICATION_FAILED_TEXT="no"
CONVERSION_FAILURE_OBSERVED="no"

if grep "${EXPECTED_MARKER}" "${OUT_DIR}/cbmc_output.txt" | \
   grep -q "FAILURE"; then
  EXPECTED_ASSERTION_FAILURE="yes"
fi

if grep -q "no body for callee" "${OUT_DIR}/cbmc_output.txt"; then
  NO_BODY_FAILURE="yes"
fi

if grep -q "VERIFICATION FAILED" "${OUT_DIR}/cbmc_output.txt"; then
  VERIFICATION_FAILED_TEXT="yes"
fi

if grep "arithmetic overflow on signed type conversion" \
   "${OUT_DIR}/cbmc_output.txt" | grep -q "FAILURE"; then
  CONVERSION_FAILURE_OBSERVED="yes"
fi

FINAL_STATUS="UNEXPECTED_RESULT"
SCRIPT_EXIT=1

if [ "${BUILD_EXIT}" -eq 0 ] &&
   [ "${CBMC_TEXT_EXIT}" -eq 10 ] &&
   [ "${CBMC_JSON_EXIT}" -eq 10 ] &&
   [ "${EXPECTED_ASSERTION_FAILURE}" = "yes" ] &&
   [ "${NO_BODY_FAILURE}" = "no" ] &&
   [ "${VERIFICATION_FAILED_TEXT}" = "yes" ]; then
  FINAL_STATUS="EXPECTED_COUNTEREXAMPLE_CONFIRMED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "expected_cbmc_result=VERIFICATION_FAILED"
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_text_exit=${CBMC_TEXT_EXIT}"
  echo "cbmc_json_exit=${CBMC_JSON_EXIT}"
  echo "expected_assertion_failure_observed=${EXPECTED_ASSERTION_FAILURE}"
  echo "target_conversion_failure_observed=${CONVERSION_FAILURE_OBSERVED}"
  echo "no_body_failure_observed=${NO_BODY_FAILURE}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-03 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "EXPECTED_COUNTEREXAMPLE_CONFIRMED" ]; then
  echo
  echo "PA-03 SCIENTIFIC OUTCOME: SUCCESS"
  echo "CBMC refuted unrestricted exact int16_t addition as expected."
else
  echo
  echo "PA-03 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

### `pa04a_mlk_poly_add_alias_safe_doubling_harness.c`

```c
/*
 * PA-04A: Safe-domain aliasing diagnostic for mlk_poly_add
 *
 * This is an out-of-contract implementation diagnostic. A successful
 * result does not amend the API contract or establish that production
 * callers may alias r and b.
 *
 * Expected CBMC result: VERIFICATION SUCCESSFUL
 *
 * Target repository commit:
 * d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa04a_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa04a_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly aliased;
  mlk_poly aliased_before;

  mlk_poly disjoint_accumulator;
  mlk_poly disjoint_operand;
  mlk_poly disjoint_operand_before;

  mlk_poly *r_alias;
  const mlk_poly *b_alias;

  unsigned i;
  int32_t exact_double;
  int32_t actual_residue;
  int32_t expected_residue;
  int32_t canonical_double_residue;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA04A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA04A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA04A_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA04A_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Exact safe-doubling domain:
   *
   *   -16384 <= x <= 16383
   *
   * Therefore:
   *
   *   -32768 <= 2*x <= 32766
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    aliased.coeffs[i] = pa04a_nondet_int16();

    __CPROVER_assume(
        (int32_t)aliased.coeffs[i] >= -16384);

    __CPROVER_assume(
        (int32_t)aliased.coeffs[i] <= 16383);
  }

  aliased_before = aliased;

  /*
   * Construct a legal disjoint execution from the same pre-state.
   * This allows comparison between:
   *
   *   mlk_poly_add(&a, &a)
   *
   * and a legal equal-valued disjoint call.
   */
  disjoint_accumulator = aliased_before;
  disjoint_operand = aliased_before;
  disjoint_operand_before = disjoint_operand;

  r_alias = &aliased;
  b_alias = &aliased;

  __CPROVER_assert(
      r_alias == b_alias,
      "PA04A_ALIAS_BINDING: r and b designate the same object");

  mlk_poly_add(r_alias, b_alias);

  __CPROVER_assert(
      &disjoint_accumulator != &disjoint_operand,
      "PA04A_DISJOINT_REFERENCE: comparison operands are distinct");

  mlk_poly_add(&disjoint_accumulator, &disjoint_operand);

  for (i = 0; i < MLKEM_N; i++)
  {
    exact_double =
        (int32_t)aliased_before.coeffs[i] * (int32_t)2;

    actual_residue =
        pa04a_mod_q((int32_t)aliased.coeffs[i]);

    expected_residue =
        pa04a_mod_q(exact_double);

    canonical_double_residue =
        pa04a_mod_q(
            pa04a_mod_q((int32_t)aliased_before.coeffs[i]) *
            (int32_t)2);

    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] == exact_double,
        "PA04A_P1_ALIAS_EXACT_DOUBLING: aliased a+a equals exact 2*a");

    __CPROVER_assert(
        actual_residue == expected_residue,
        "PA04A_P2_ALIAS_MOD_Q: alias result is congruent to exact doubling");

    __CPROVER_assert(
        actual_residue == canonical_double_residue,
        "PA04A_P3_CANONICAL_RESIDUE_DOUBLING: alias result matches canonical doubling");

    __CPROVER_assert(
        aliased.coeffs[i] == disjoint_accumulator.coeffs[i],
        "PA04A_P4_ALIAS_DISJOINT_EQUIVALENCE: alias result matches legal equal-operand call");

    __CPROVER_assert(
        disjoint_operand.coeffs[i] ==
            disjoint_operand_before.coeffs[i],
        "PA04A_P5_REFERENCE_INPUT_FRAME: disjoint read-only operand remains unchanged");

    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] >= (int32_t)INT16_MIN,
        "PA04A_P6_OUTPUT_LOWER_BOUND: result is at least INT16_MIN");

    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] <= 32766,
        "PA04A_P6_OUTPUT_UPPER_BOUND: result is at most 32766");
  }

  return 0;
}
```

### `pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c`

```c
/*
 * PA-04B: Unrestricted aliasing negative control for mlk_poly_add
 *
 * Scientific purpose:
 *   Show that aliasing does not remove the int16_t representability
 *   boundary. Exact doubling cannot hold for every arbitrary int16_t
 *   coefficient.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Expected campaign interpretation:
 *   EXPECTED_ALIAS_COUNTEREXAMPLE_CONFIRMED
 *
 * This remains an out-of-contract implementation diagnostic.
 *
 * Target repository commit:
 * d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa04b_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly aliased;
  mlk_poly aliased_before;

  mlk_poly *r_alias;
  const mlk_poly *b_alias;

  unsigned i;
  int32_t exact_double;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA04B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA04B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA04B_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA04B_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Completely unrestricted signed int16_t coefficients.
   * No safe-doubling or representability assumption is present.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    aliased.coeffs[i] = pa04b_nondet_int16();
  }

  aliased_before = aliased;

  r_alias = &aliased;
  b_alias = &aliased;

  __CPROVER_assert(
      r_alias == b_alias,
      "PA04B_ALIAS_BINDING: r and b designate the same object");

  mlk_poly_add(r_alias, b_alias);

  for (i = 0; i < MLKEM_N; i++)
  {
    exact_double =
        (int32_t)aliased_before.coeffs[i] * (int32_t)2;

    /*
     * Intentionally false over the unrestricted domain.
     * For example, 16384 doubled is 32768, which is not representable
     * in int16_t.
     */
    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] == exact_double,
        "PA04B_P1_UNRESTRICTED_ALIAS_EXACT_DOUBLING: exact a+a for every int16_t value");
  }

  return 0;
}
```

### `run_pa04_mlk_poly_add_aliasing_campaign.sh`

```bash
#!/usr/bin/env bash
#
# PA-04 combined aliasing campaign for mlk_poly_add.
#
# PA-04A:
#   Safe representable aliasing domain.
#   Expected CBMC result: VERIFICATION SUCCESSFUL.
#
# PA-04B:
#   Unrestricted aliasing negative control.
#   Expected CBMC result: VERIFICATION FAILED.
#
# Final campaign success:
#   PA04_ALIASING_DIAGNOSTIC_CONFIRMED
#
# This campaign is an out-of-contract implementation diagnostic. It does
# not alter the production API contract or permit production aliasing.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa04_mlk_poly_add_aliasing_campaign.sh
#   ./run_pa04_mlk_poly_add_aliasing_campaign.sh 768
#
# Optional parameter set: 512, 768, or 1024.
# Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-04"
CAMPAIGN_SCOPE="out_of_contract_aliasing_diagnostic"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"

SAFE_HARNESS="pa04a_mlk_poly_add_alias_safe_doubling_harness.c"
NEGATIVE_HARNESS="pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c"
NEGATIVE_MARKER="PA04B_P1_UNRESTRICTED_ALIAS_EXACT_DOUBLING"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa04_mlk_poly_add_aliasing_${PARAM_SET}_${TIMESTAMP}"
SAFE_DIR="${OUT_DIR}/pa04a_safe_alias"
NEGATIVE_DIR="${OUT_DIR}/pa04b_unrestricted_alias_negative_control"

SAFE_GOTO="${SAFE_DIR}/pa04a_safe_alias.goto"
NEGATIVE_GOTO="${NEGATIVE_DIR}/pa04b_unrestricted_alias.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee grep; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] || [ ! -f "mlkem/src/poly.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

for harness in "${SAFE_HARNESS}" "${NEGATIVE_HARNESS}"; do
  if [ ! -f "${harness}" ]; then
    echo "ERROR: required harness missing: ${harness}" >&2
    exit 2
  fi
done

mkdir -p "${SAFE_DIR}" "${NEGATIVE_DIR}"

CURRENT_COMMIT="$(git rev-parse HEAD)"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Contract status: out-of-contract implementation diagnostic"
  echo "PA-04A expected result: VERIFICATION SUCCESSFUL"
  echo "PA-04B expected result: VERIFICATION FAILED"
  echo "Final expected interpretation: PA04_ALIASING_DIAGNOSTIC_CONFIRMED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

sha256sum "${SAFE_HARNESS}" > "${OUT_DIR}/pa04a_harness_sha256.txt"
sha256sum "${NEGATIVE_HARNESS}" > "${OUT_DIR}/pa04b_harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"

cp "${SAFE_HARNESS}" "${OUT_DIR}/"
cp "${NEGATIVE_HARNESS}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-04 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

build_model()
{
  local harness="$1"
  local goto_model="$2"
  local result_dir="$3"
  local label="$4"
  local build_exit
  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    "${harness}"
    mlkem/src/poly.c
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo "===== ${label}: BUILDING GOTO MODEL ====="
  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  return "${build_exit}"
}

run_text_cbmc()
{
  local goto_model="$1"
  local result_dir="$2"
  local label="$3"
  local text_exit
  local text_command=(
    cbmc
    "${goto_model}"
    "${COMMON_CBMC_OPTIONS[@]}"
    --trace
  )

  printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
  printf '\n' >> "${result_dir}/cbmc_command.txt"

  echo
  echo "===== ${label}: RUNNING CBMC TEXT CHECK ====="
  "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
  text_exit=${PIPESTATUS[0]}
  echo "${text_exit}" > "${result_dir}/cbmc.exit"

  return "${text_exit}"
}

run_json_cbmc()
{
  local goto_model="$1"
  local result_dir="$2"
  local json_exit
  local json_command=(
    cbmc
    "${goto_model}"
    "${COMMON_CBMC_OPTIONS[@]}"
    --json-ui
  )

  printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
  printf '\n' >> "${result_dir}/cbmc_json_command.txt"

  "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
    "${result_dir}/cbmc_json_stderr.txt"
  json_exit=$?
  echo "${json_exit}" > "${result_dir}/cbmc_json.exit"

  return "${json_exit}"
}

SAFE_BUILD_EXIT=0
SAFE_TEXT_EXIT=-1
SAFE_JSON_EXIT=-1

build_model \
  "${SAFE_HARNESS}" \
  "${SAFE_GOTO}" \
  "${SAFE_DIR}" \
  "PA-04A SAFE ALIAS"
SAFE_BUILD_EXIT=$?

if [ "${SAFE_BUILD_EXIT}" -eq 0 ]; then
  run_text_cbmc \
    "${SAFE_GOTO}" \
    "${SAFE_DIR}" \
    "PA-04A SAFE ALIAS"
  SAFE_TEXT_EXIT=$?

  run_json_cbmc \
    "${SAFE_GOTO}" \
    "${SAFE_DIR}"
  SAFE_JSON_EXIT=$?
fi

NEG_BUILD_EXIT=0
NEG_TEXT_EXIT=-1
NEG_JSON_EXIT=-1

build_model \
  "${NEGATIVE_HARNESS}" \
  "${NEGATIVE_GOTO}" \
  "${NEGATIVE_DIR}" \
  "PA-04B UNRESTRICTED ALIAS"
NEG_BUILD_EXIT=$?

if [ "${NEG_BUILD_EXIT}" -eq 0 ]; then
  run_text_cbmc \
    "${NEGATIVE_GOTO}" \
    "${NEGATIVE_DIR}" \
    "PA-04B EXPECTED-FAILURE ALIAS"
  NEG_TEXT_EXIT=$?

  run_json_cbmc \
    "${NEGATIVE_GOTO}" \
    "${NEGATIVE_DIR}"
  NEG_JSON_EXIT=$?
fi

SAFE_VERIFICATION_SUCCESSFUL="no"
SAFE_FAILURE_LINES="yes"

if [ "${SAFE_BUILD_EXIT}" -eq 0 ] &&
   [ "${SAFE_TEXT_EXIT}" -eq 0 ] &&
   [ "${SAFE_JSON_EXIT}" -eq 0 ] &&
   grep -q "VERIFICATION SUCCESSFUL" "${SAFE_DIR}/cbmc_output.txt"; then
  SAFE_VERIFICATION_SUCCESSFUL="yes"
fi

if [ -f "${SAFE_DIR}/cbmc_output.txt" ] &&
   ! grep -q "FAILURE" "${SAFE_DIR}/cbmc_output.txt"; then
  SAFE_FAILURE_LINES="no"
fi

NEG_EXPECTED_ASSERTION_FAILURE="no"
NEG_CONVERSION_FAILURE="no"
NEG_NO_BODY_FAILURE="no"
NEG_VERIFICATION_FAILED="no"

if [ -f "${NEGATIVE_DIR}/cbmc_output.txt" ]; then
  if grep -F "${NEGATIVE_MARKER}" "${NEGATIVE_DIR}/cbmc_output.txt" | \
     grep -q "FAILURE"; then
    NEG_EXPECTED_ASSERTION_FAILURE="yes"
  fi

  if grep "arithmetic overflow on signed type conversion" \
     "${NEGATIVE_DIR}/cbmc_output.txt" | grep -q "FAILURE"; then
    NEG_CONVERSION_FAILURE="yes"
  fi

  if grep -q "no body for callee" "${NEGATIVE_DIR}/cbmc_output.txt"; then
    NEG_NO_BODY_FAILURE="yes"
  fi

  if grep -q "VERIFICATION FAILED" "${NEGATIVE_DIR}/cbmc_output.txt"; then
    NEG_VERIFICATION_FAILED="yes"
  fi
fi

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${SAFE_VERIFICATION_SUCCESSFUL}" = "yes" ] &&
   [ "${SAFE_FAILURE_LINES}" = "no" ] &&
   [ "${NEG_BUILD_EXIT}" -eq 0 ] &&
   [ "${NEG_TEXT_EXIT}" -eq 10 ] &&
   [ "${NEG_JSON_EXIT}" -eq 10 ] &&
   [ "${NEG_EXPECTED_ASSERTION_FAILURE}" = "yes" ] &&
   [ "${NEG_CONVERSION_FAILURE}" = "yes" ] &&
   [ "${NEG_NO_BODY_FAILURE}" = "no" ] &&
   [ "${NEG_VERIFICATION_FAILED}" = "yes" ]; then
  FINAL_STATUS="PA04_ALIASING_DIAGNOSTIC_CONFIRMED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "contract_status=OUT_OF_CONTRACT_DIAGNOSTIC"
  echo "pa04a_build_exit=${SAFE_BUILD_EXIT}"
  echo "pa04a_cbmc_text_exit=${SAFE_TEXT_EXIT}"
  echo "pa04a_cbmc_json_exit=${SAFE_JSON_EXIT}"
  echo "pa04a_verification_successful=${SAFE_VERIFICATION_SUCCESSFUL}"
  echo "pa04a_failure_lines_observed=${SAFE_FAILURE_LINES}"
  echo "pa04b_build_exit=${NEG_BUILD_EXIT}"
  echo "pa04b_cbmc_text_exit=${NEG_TEXT_EXIT}"
  echo "pa04b_cbmc_json_exit=${NEG_JSON_EXIT}"
  echo "pa04b_expected_assertion_failure_observed=${NEG_EXPECTED_ASSERTION_FAILURE}"
  echo "pa04b_conversion_failure_observed=${NEG_CONVERSION_FAILURE}"
  echo "pa04b_no_body_failure_observed=${NEG_NO_BODY_FAILURE}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-04 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA04_ALIASING_DIAGNOSTIC_CONFIRMED" ]; then
  echo
  echo "PA-04 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Safe alias doubling was verified."
  echo "The unrestricted alias boundary was refuted as expected."
  echo "This remains an out-of-contract implementation diagnostic."
else
  echo
  echo "PA-04 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

### `pa05a_mlk_poly_add_polyvec_production_callsite_harness.c`

```c
/*
 * PA-05A: Production caller verification for the mlk_poly_add call inside
 *         mlk_polyvec_add (mlkem/src/poly_k.c).
 *
 * Purpose:
 *   Verify that the production mlk_polyvec_add caller discharges the
 *   mlk_poly_add arithmetic and object-separation obligations for every
 *   component call, assuming exactly the documented mlk_polyvec_add input
 *   contract.
 *
 * This harness directly calls the production mlk_polyvec_add implementation,
 * which in turn directly calls the production mlk_poly_add implementation.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly_k.h"

static int16_t pa05a_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_polyvec r;
  mlk_polyvec b;
  mlk_polyvec r_before;
  mlk_polyvec b_before;

  unsigned j;
  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA05A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA05A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_K == 3,
      "PA05A_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");

  __CPROVER_assert(
      &r != &b,
      "PA05A_OBJECT_SEPARATION: caller vector objects are distinct");

  /*
   * Model exactly the documented mlk_polyvec_add input contract:
   * every component-wise mathematical sum must fit in int16_t.
   */
  for (j = 0; j < MLKEM_K; j++)
  {
    __CPROVER_assert(
        &r.vec[j] != &b.vec[j],
        "PA05A_COMPONENT_SEPARATION: each nested mlk_poly_add call uses distinct polynomials");

    for (i = 0; i < MLKEM_N; i++)
    {
      r.vec[j].coeffs[i] = pa05a_nondet_int16();
      b.vec[j].coeffs[i] = pa05a_nondet_int16();

      mathematical_sum =
          (int32_t)r.vec[j].coeffs[i] +
          (int32_t)b.vec[j].coeffs[i];

      __CPROVER_assume(
          mathematical_sum >= (int32_t)INT16_MIN);

      __CPROVER_assume(
          mathematical_sum <= (int32_t)INT16_MAX);
    }
  }

  r_before = r;
  b_before = b;

  /*
   * Execute the production caller. Its loop invokes production
   * mlk_poly_add once for every vector component.
   */
  mlk_polyvec_add(&r, &b);

  for (j = 0; j < MLKEM_K; j++)
  {
    for (i = 0; i < MLKEM_N; i++)
    {
      mathematical_sum =
          (int32_t)r_before.vec[j].coeffs[i] +
          (int32_t)b_before.vec[j].coeffs[i];

      __CPROVER_assert(
          (int32_t)r.vec[j].coeffs[i] == mathematical_sum,
          "PA05A_P1_CALLER_EXACT_SUM: every production component call computes the exact sum");

      __CPROVER_assert(
          b.vec[j].coeffs[i] == b_before.vec[j].coeffs[i],
          "PA05A_P2_CALLER_FRAME: the production caller preserves its read-only vector");
    }
  }

  return 0;
}
```

### `pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c`

```c
/*
 * PA-05B: Production call-site obligation for
 *         mlk_poly_add(v, epp) in mlkem/src/indcpa.c.
 *
 * Purpose:
 *   Starting only from the documented postconditions of the two producer
 *   operations immediately relevant to the call site, prove that the exact
 *   sum is representable in int16_t and that production mlk_poly_add is safe
 *   and functionally correct at this call.
 *
 * Producer guarantees modelled:
 *   mlk_poly_invntt_tomont(v):
 *       abs(v[i]) < MLK_INVNTT_BOUND = 8 * MLKEM_Q
 *
 *   mlk_enc_getnoise_eta1_eta2(..., epp, ...):
 *       abs(epp[i]) < MLKEM_ETA2 + 1
 *
 * No safe-sum assumption is made. The call-site representability condition
 * is asserted and must be derived by CBMC from the producer guarantees.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa05b_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa05b_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly v;
  mlk_poly epp;
  mlk_poly v_before;
  mlk_poly epp_before;

  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA05B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA05B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA05B_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA05B_BOUND_BINDING: inverse NTT bound must equal 8*q");

  __CPROVER_assert(
      &v != &epp,
      "PA05B_OBJECT_SEPARATION: v and epp are distinct allocated objects");

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa05b_nondet_int16();
    epp.coeffs[i] = pa05b_nondet_int16();

    /*
     * Producer postcondition from mlk_poly_invntt_tomont(v).
     */
    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    /*
     * Producer postcondition from mlk_enc_getnoise_eta1_eta2(..., epp, ...).
     */
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    mathematical_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    /*
     * These are call-site proof obligations, not assumptions.
     */
    __CPROVER_assert(
        mathematical_sum >= (int32_t)INT16_MIN,
        "PA05B_P1_CALL_PRECONDITION_LOWER: v+epp is representable in int16_t");

    __CPROVER_assert(
        mathematical_sum <= (int32_t)INT16_MAX,
        "PA05B_P1_CALL_PRECONDITION_UPPER: v+epp is representable in int16_t");
  }

  v_before = v;
  epp_before = epp;

  /*
   * Execute the exact production target used at indcpa.c:571.
   */
  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)v_before.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == mathematical_sum,
        "PA05B_P2_EXACT_CALL_RESULT: indcpa v+epp call computes the exact sum");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA05B_P3_RIGHT_INPUT_FRAME: epp remains unchanged");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] >
            -(int32_t)(MLK_INVNTT_BOUND + MLKEM_ETA2),
        "PA05B_P4_DERIVED_OUTPUT_LOWER: result satisfies the derived strict lower bound");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] <
            (int32_t)(MLK_INVNTT_BOUND + MLKEM_ETA2),
        "PA05B_P4_DERIVED_OUTPUT_UPPER: result satisfies the derived strict upper bound");

    __CPROVER_assert(
        pa05b_mod_q((int32_t)v.coeffs[i]) ==
            pa05b_mod_q(mathematical_sum),
        "PA05B_P5_MOD_Q_REFINEMENT: concrete call result represents the correct residue");
  }

  return 0;
}
```

### `pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c`

```c
/*
 * PA-05C: Sequential production call-site obligation for
 *
 *         mlk_poly_add(v, epp);
 *         mlk_poly_add(v, k);
 *
 * in mlkem/src/indcpa.c.
 *
 * Purpose:
 *   Prove that the second call is safe in the actual sequential context,
 *   after the first call has already modified v.
 *
 * Producer guarantees modelled:
 *   abs(v_initial[i]) < MLK_INVNTT_BOUND
 *   abs(epp[i])      < MLKEM_ETA2 + 1
 *
 * Message polynomial model:
 *   each k[i] is generated from one message bit and equals either
 *   0 or MLKEM_Q_HALF.
 *
 * No safe-sum assumption is made for either production call. Both
 * representability obligations are assertions derived by CBMC.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa05c_nondet_int16(void)
{
  int16_t value;
  return value;
}

static uint8_t pa05c_nondet_uint8(void)
{
  uint8_t value;
  return value;
}

static int32_t pa05c_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly v;
  mlk_poly epp;
  mlk_poly k;

  mlk_poly v_initial;
  mlk_poly epp_before;
  mlk_poly k_before;

  uint8_t message[MLKEM_N / 8];

  unsigned i;
  unsigned byte_index;
  unsigned bit_index;
  uint8_t message_bit;

  int32_t first_sum;
  int32_t cumulative_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA05C_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA05C_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_Q_HALF == 1665,
      "PA05C_PARAMETER_BINDING: MLKEM_Q_HALF must equal 1665");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA05C_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA05C_BOUND_BINDING: inverse NTT bound must equal 8*q");

  __CPROVER_assert(
      &v != &epp,
      "PA05C_OBJECT_SEPARATION: v and epp are distinct");

  __CPROVER_assert(
      &v != &k,
      "PA05C_OBJECT_SEPARATION: v and k are distinct");

  __CPROVER_assert(
      &epp != &k,
      "PA05C_OBJECT_SEPARATION: epp and k are distinct");

  for (i = 0; i < (MLKEM_N / 8); i++)
  {
    message[i] = pa05c_nondet_uint8();
  }

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa05c_nondet_int16();
    epp.coeffs[i] = pa05c_nondet_int16();

    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    /*
     * Independent model of the message-polynomial image used by the
     * production caller: one message bit maps to 0 or ceil(q/2).
     */
    byte_index = i >> 3;
    bit_index = i & 7u;
    message_bit =
        (uint8_t)((message[byte_index] >> bit_index) & (uint8_t)1);

    k.coeffs[i] =
        (message_bit == (uint8_t)0) ?
        (int16_t)0 :
        (int16_t)MLKEM_Q_HALF;

    __CPROVER_assert(
        k.coeffs[i] == 0 ||
            k.coeffs[i] == (int16_t)MLKEM_Q_HALF,
        "PA05C_MESSAGE_IMAGE: each k coefficient is 0 or MLKEM_Q_HALF");

    first_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    /*
     * First production call obligation. This is proved from producer
     * guarantees and is not assumed.
     */
    __CPROVER_assert(
        first_sum >= (int32_t)INT16_MIN,
        "PA05C_P1_FIRST_CALL_LOWER: v+epp is representable");

    __CPROVER_assert(
        first_sum <= (int32_t)INT16_MAX,
        "PA05C_P1_FIRST_CALL_UPPER: v+epp is representable");

    cumulative_sum =
        first_sum +
        (int32_t)k.coeffs[i];

    /*
     * Second production call obligation in the actual cumulative state.
     */
    __CPROVER_assert(
        cumulative_sum >= (int32_t)INT16_MIN,
        "PA05C_P2_SECOND_CALL_LOWER: (v+epp)+k is representable");

    __CPROVER_assert(
        cumulative_sum <= (int32_t)INT16_MAX,
        "PA05C_P2_SECOND_CALL_UPPER: (v+epp)+k is representable");
  }

  v_initial = v;
  epp_before = epp;
  k_before = k;

  /*
   * Execute the two production calls in their actual order.
   */
  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    first_sum =
        (int32_t)v_initial.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == first_sum,
        "PA05C_P3_FIRST_CALL_EXACT: first sequential production call is exact");
  }

  mlk_poly_add(&v, &k);

  for (i = 0; i < MLKEM_N; i++)
  {
    cumulative_sum =
        (int32_t)v_initial.coeffs[i] +
        (int32_t)epp_before.coeffs[i] +
        (int32_t)k_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == cumulative_sum,
        "PA05C_P4_CUMULATIVE_EXACT: both sequential production calls compute the cumulative sum");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA05C_P5_EPP_FRAME: epp remains unchanged");

    __CPROVER_assert(
        k.coeffs[i] == k_before.coeffs[i],
        "PA05C_P6_K_FRAME: k remains unchanged");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] >
            -(int32_t)(MLK_INVNTT_BOUND + MLKEM_ETA2),
        "PA05C_P7_CUMULATIVE_LOWER: cumulative result satisfies the strict lower bound");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] <
            (int32_t)(MLK_INVNTT_BOUND +
                      MLKEM_ETA2 +
                      MLKEM_Q_HALF),
        "PA05C_P7_CUMULATIVE_UPPER: cumulative result satisfies the strict upper bound");

    __CPROVER_assert(
        pa05c_mod_q((int32_t)v.coeffs[i]) ==
            pa05c_mod_q(cumulative_sum),
        "PA05C_P8_MOD_Q_REFINEMENT: cumulative concrete result has the correct residue");
  }

  return 0;
}
```

### `run_pa05_mlk_poly_add_production_callsites.sh`

```bash
#!/usr/bin/env bash
#
# PA-05 combined production call-site campaign for mlk_poly_add.
#
# PA-05A:
#   Production mlk_polyvec_add caller in poly_k.c.
#
# PA-05B:
#   First indcpa encryption call: mlk_poly_add(v, epp).
#
# PA-05C:
#   Sequential indcpa encryption calls:
#       mlk_poly_add(v, epp);
#       mlk_poly_add(v, k);
#
# Expected final status:
#   PA05_PRODUCTION_CALLSITES_VERIFIED
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa05_mlk_poly_add_production_callsites.sh
#   ./run_pa05_mlk_poly_add_production_callsites.sh 768
#

set -uo pipefail

CAMPAIGN_ID="PA-05"
CAMPAIGN_SCOPE="production_callsite_precondition_and_semantic_verification"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"

HARNESS_A="pa05a_mlk_poly_add_polyvec_production_callsite_harness.c"
HARNESS_B="pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c"
HARNESS_C="pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa05_mlk_poly_add_callsites_${PARAM_SET}_${TIMESTAMP}"

case "${PARAM_SET}" in
  768) ;;
  *)
    echo "ERROR: PA-05 is currently frozen for ML-KEM-768." >&2
    echo "Cross-parameter replication belongs to PA-06." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee grep; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] ||
   [ ! -f "mlkem/src/poly_k.c" ] ||
   [ ! -f "mlkem/src/poly.h" ] ||
   [ ! -f "mlkem/src/poly_k.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

for harness in "${HARNESS_A}" "${HARNESS_B}" "${HARNESS_C}"; do
  if [ ! -f "${harness}" ]; then
    echo "ERROR: required harness missing: ${harness}" >&2
    exit 2
  fi
done

CURRENT_COMMIT="$(git rev-parse HEAD)"
mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA05_PRODUCTION_CALLSITES_VERIFIED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

sha256sum "${HARNESS_A}" > "${OUT_DIR}/pa05a_harness_sha256.txt"
sha256sum "${HARNESS_B}" > "${OUT_DIR}/pa05b_harness_sha256.txt"
sha256sum "${HARNESS_C}" > "${OUT_DIR}/pa05c_harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"

cp "${HARNESS_A}" "${OUT_DIR}/"
cp "${HARNESS_B}" "${OUT_DIR}/"
cp "${HARNESS_C}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-05 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

run_experiment()
{
  local label="$1"
  local harness="$2"
  local source_mode="$3"
  local marker="$4"
  local result_dir="${OUT_DIR}/${label}"
  local goto_model="${result_dir}/${label}.goto"

  local build_exit
  local text_exit
  local json_exit
  local successful="no"
  local marker_success="no"
  local failure_lines="yes"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    "${harness}"
    mlkem/src/poly.c
  )

  if [ "${source_mode}" = "poly_k_caller" ]; then
    build_command+=(mlkem/src/poly_k.c)
  fi

  build_command+=(-o "${goto_model}")

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo "===== ${label}: BUILDING GOTO MODEL ====="
  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  text_exit=-1
  json_exit=-1

  if [ "${build_exit}" -eq 0 ]; then
    local text_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --trace
    )

    printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
    printf '\n' >> "${result_dir}/cbmc_command.txt"

    echo
    echo "===== ${label}: RUNNING CBMC TEXT CHECK ====="
    "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
    text_exit=${PIPESTATUS[0]}
    echo "${text_exit}" > "${result_dir}/cbmc.exit"

    local json_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --json-ui
    )

    printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
    printf '\n' >> "${result_dir}/cbmc_json_command.txt"

    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 0 ] &&
     [ "${json_exit}" -eq 0 ] &&
     grep -q "VERIFICATION SUCCESSFUL" "${result_dir}/cbmc_output.txt"; then
    successful="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${marker}" "${result_dir}/cbmc_output.txt" | grep -q "SUCCESS"; then
    marker_success="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     ! grep -q "FAILURE" "${result_dir}/cbmc_output.txt"; then
    failure_lines="no"
  fi

  {
    echo "label=${label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_successful=${successful}"
    echo "required_marker_success=${marker_success}"
    echo "failure_lines_observed=${failure_lines}"
  } > "${result_dir}/summary.txt"

  echo
  cat "${result_dir}/summary.txt"

  if [ "${successful}" = "yes" ] &&
     [ "${marker_success}" = "yes" ] &&
     [ "${failure_lines}" = "no" ]; then
    return 0
  fi

  return 1
}

PA05A_OK="no"
PA05B_OK="no"
PA05C_OK="no"

if run_experiment \
  "pa05a_polyvec_callsite" \
  "${HARNESS_A}" \
  "poly_k_caller" \
  "PA05A_P1_CALLER_EXACT_SUM"; then
  PA05A_OK="yes"
fi

if run_experiment \
  "pa05b_indcpa_epp_callsite" \
  "${HARNESS_B}" \
  "poly_only" \
  "PA05B_P1_CALL_PRECONDITION_UPPER"; then
  PA05B_OK="yes"
fi

if run_experiment \
  "pa05c_indcpa_k_sequential_callsite" \
  "${HARNESS_C}" \
  "poly_only" \
  "PA05C_P2_SECOND_CALL_UPPER"; then
  PA05C_OK="yes"
fi

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${PA05A_OK}" = "yes" ] &&
   [ "${PA05B_OK}" = "yes" ] &&
   [ "${PA05C_OK}" = "yes" ]; then
  FINAL_STATUS="PA05_PRODUCTION_CALLSITES_VERIFIED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "pa05a_polyvec_callsite_verified=${PA05A_OK}"
  echo "pa05b_indcpa_epp_callsite_verified=${PA05B_OK}"
  echo "pa05c_indcpa_k_sequential_callsite_verified=${PA05C_OK}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-05 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA05_PRODUCTION_CALLSITES_VERIFIED" ]; then
  echo
  echo "PA-05 SCIENTIFIC OUTCOME: SUCCESS"
  echo "All three production mlk_poly_add call-site obligations were verified."
else
  echo
  echo "PA-05 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

### `pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c`

```c
/*
 * PA-06A: Cross-parameter production-caller verification for the
 *         mlk_poly_add calls inside mlk_polyvec_add.
 *
 * This harness is parameter-set neutral. It is compiled separately for:
 *   ML-KEM-512  (MLKEM_K = 2)
 *   ML-KEM-768  (MLKEM_K = 3)
 *   ML-KEM-1024 (MLKEM_K = 4)
 *
 * It directly executes production mlk_polyvec_add from poly_k.c, which
 * directly invokes production mlk_poly_add for each vector component.
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly_k.h"

static int16_t pa06a_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_polyvec r;
  mlk_polyvec b;
  mlk_polyvec r_before;
  mlk_polyvec b_before;

  unsigned j;
  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA06A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA06A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

#if MLK_CONFIG_PARAMETER_SET == 512
  __CPROVER_assert(
      MLKEM_K == 2,
      "PA06A_PARAMETER_BINDING: ML-KEM-512 must use MLKEM_K equal to 2");
#elif MLK_CONFIG_PARAMETER_SET == 768
  __CPROVER_assert(
      MLKEM_K == 3,
      "PA06A_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");
#elif MLK_CONFIG_PARAMETER_SET == 1024
  __CPROVER_assert(
      MLKEM_K == 4,
      "PA06A_PARAMETER_BINDING: ML-KEM-1024 must use MLKEM_K equal to 4");
#else
#error PA-06A requires ML-KEM-512, ML-KEM-768, or ML-KEM-1024
#endif

  __CPROVER_assert(
      &r != &b,
      "PA06A_OBJECT_SEPARATION: caller vector objects are distinct");

  /*
   * Exact documented mlk_polyvec_add input contract:
   * every nested coefficient sum must be representable in int16_t.
   */
  for (j = 0; j < MLKEM_K; j++)
  {
    __CPROVER_assert(
        &r.vec[j] != &b.vec[j],
        "PA06A_COMPONENT_SEPARATION: nested target operands are distinct");

    for (i = 0; i < MLKEM_N; i++)
    {
      r.vec[j].coeffs[i] = pa06a_nondet_int16();
      b.vec[j].coeffs[i] = pa06a_nondet_int16();

      mathematical_sum =
          (int32_t)r.vec[j].coeffs[i] +
          (int32_t)b.vec[j].coeffs[i];

      __CPROVER_assume(
          mathematical_sum >= (int32_t)INT16_MIN);

      __CPROVER_assume(
          mathematical_sum <= (int32_t)INT16_MAX);
    }
  }

  r_before = r;
  b_before = b;

  /*
   * Direct production caller execution.
   */
  mlk_polyvec_add(&r, &b);

  for (j = 0; j < MLKEM_K; j++)
  {
    for (i = 0; i < MLKEM_N; i++)
    {
      mathematical_sum =
          (int32_t)r_before.vec[j].coeffs[i] +
          (int32_t)b_before.vec[j].coeffs[i];

      __CPROVER_assert(
          (int32_t)r.vec[j].coeffs[i] == mathematical_sum,
          "PA06A_P1_CROSS_PARAMETER_EXACT_SUM: every production component call computes the exact sum");

      __CPROVER_assert(
          b.vec[j].coeffs[i] == b_before.vec[j].coeffs[i],
          "PA06A_P2_CROSS_PARAMETER_FRAME: production caller preserves the read-only vector");
    }
  }

  return 0;
}
```

### `pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c`

```c
/*
 * PA-06B: Cross-parameter call-site verification for
 *         mlk_poly_add(v, epp) in mlk_indcpa_enc.
 *
 * Compiled separately for ML-KEM-512, ML-KEM-768, and ML-KEM-1024.
 *
 * The harness assumes only the documented producer guarantees:
 *   abs(v[i])   < MLK_INVNTT_BOUND
 *   abs(epp[i]) < MLKEM_ETA2 + 1
 *
 * The target representability condition is asserted, not assumed.
 * The production mlk_poly_add body is executed directly.
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa06b_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa06b_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly v;
  mlk_poly epp;
  mlk_poly v_before;
  mlk_poly epp_before;

  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA06B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA06B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA06B_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA06B_BOUND_BINDING: inverse NTT bound must equal 8*q");

#if MLK_CONFIG_PARAMETER_SET == 512
  __CPROVER_assert(
      MLKEM_K == 2,
      "PA06B_PARAMETER_BINDING: ML-KEM-512 must use MLKEM_K equal to 2");
#elif MLK_CONFIG_PARAMETER_SET == 768
  __CPROVER_assert(
      MLKEM_K == 3,
      "PA06B_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");
#elif MLK_CONFIG_PARAMETER_SET == 1024
  __CPROVER_assert(
      MLKEM_K == 4,
      "PA06B_PARAMETER_BINDING: ML-KEM-1024 must use MLKEM_K equal to 4");
#else
#error PA-06B requires ML-KEM-512, ML-KEM-768, or ML-KEM-1024
#endif

  __CPROVER_assert(
      &v != &epp,
      "PA06B_OBJECT_SEPARATION: v and epp are distinct objects");

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa06b_nondet_int16();
    epp.coeffs[i] = pa06b_nondet_int16();

    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    mathematical_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    __CPROVER_assert(
        mathematical_sum >= (int32_t)INT16_MIN,
        "PA06B_P1_CROSS_PARAMETER_CALL_LOWER: v+epp is representable");

    __CPROVER_assert(
        mathematical_sum <= (int32_t)INT16_MAX,
        "PA06B_P1_CROSS_PARAMETER_CALL_UPPER: v+epp is representable");
  }

  v_before = v;
  epp_before = epp;

  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)v_before.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == mathematical_sum,
        "PA06B_P2_CROSS_PARAMETER_EXACT_RESULT: production v+epp call is exact");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA06B_P3_CROSS_PARAMETER_FRAME: epp remains unchanged");

    __CPROVER_assert(
        pa06b_mod_q((int32_t)v.coeffs[i]) ==
            pa06b_mod_q(mathematical_sum),
        "PA06B_P4_CROSS_PARAMETER_MOD_Q: result has the correct residue");
  }

  return 0;
}
```

### `pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c`

```c
/*
 * PA-06C: Cross-parameter sequential call-site verification for
 *
 *         mlk_poly_add(v, epp);
 *         mlk_poly_add(v, k);
 *
 * in mlk_indcpa_enc.
 *
 * Compiled separately for ML-KEM-512, ML-KEM-768, and ML-KEM-1024.
 *
 * The safe-sum conditions for both calls are assertions derived from:
 *   abs(v_initial[i]) < MLK_INVNTT_BOUND
 *   abs(epp[i])       < MLKEM_ETA2 + 1
 *   k[i]              in {0, MLKEM_Q_HALF}
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa06c_nondet_int16(void)
{
  int16_t value;
  return value;
}

static uint8_t pa06c_nondet_uint8(void)
{
  uint8_t value;
  return value;
}

static int32_t pa06c_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly v;
  mlk_poly epp;
  mlk_poly k;

  mlk_poly v_initial;
  mlk_poly epp_before;
  mlk_poly k_before;

  uint8_t message[MLKEM_N / 8];

  unsigned i;
  unsigned byte_index;
  unsigned bit_index;
  uint8_t message_bit;

  int32_t first_sum;
  int32_t cumulative_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA06C_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA06C_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_Q_HALF == 1665,
      "PA06C_PARAMETER_BINDING: MLKEM_Q_HALF must equal 1665");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA06C_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA06C_BOUND_BINDING: inverse NTT bound must equal 8*q");

#if MLK_CONFIG_PARAMETER_SET == 512
  __CPROVER_assert(
      MLKEM_K == 2,
      "PA06C_PARAMETER_BINDING: ML-KEM-512 must use MLKEM_K equal to 2");
#elif MLK_CONFIG_PARAMETER_SET == 768
  __CPROVER_assert(
      MLKEM_K == 3,
      "PA06C_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");
#elif MLK_CONFIG_PARAMETER_SET == 1024
  __CPROVER_assert(
      MLKEM_K == 4,
      "PA06C_PARAMETER_BINDING: ML-KEM-1024 must use MLKEM_K equal to 4");
#else
#error PA-06C requires ML-KEM-512, ML-KEM-768, or ML-KEM-1024
#endif

  __CPROVER_assert(
      &v != &epp,
      "PA06C_OBJECT_SEPARATION: v and epp are distinct");

  __CPROVER_assert(
      &v != &k,
      "PA06C_OBJECT_SEPARATION: v and k are distinct");

  __CPROVER_assert(
      &epp != &k,
      "PA06C_OBJECT_SEPARATION: epp and k are distinct");

  for (i = 0; i < (MLKEM_N / 8); i++)
  {
    message[i] = pa06c_nondet_uint8();
  }

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa06c_nondet_int16();
    epp.coeffs[i] = pa06c_nondet_int16();

    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    byte_index = i >> 3;
    bit_index = i & 7u;
    message_bit =
        (uint8_t)((message[byte_index] >> bit_index) & (uint8_t)1);

    k.coeffs[i] =
        (message_bit == (uint8_t)0) ?
        (int16_t)0 :
        (int16_t)MLKEM_Q_HALF;

    __CPROVER_assert(
        k.coeffs[i] == 0 ||
            k.coeffs[i] == (int16_t)MLKEM_Q_HALF,
        "PA06C_MESSAGE_IMAGE: k coefficient is 0 or MLKEM_Q_HALF");

    first_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    __CPROVER_assert(
        first_sum >= (int32_t)INT16_MIN,
        "PA06C_P1_FIRST_CALL_LOWER: v+epp is representable");

    __CPROVER_assert(
        first_sum <= (int32_t)INT16_MAX,
        "PA06C_P1_FIRST_CALL_UPPER: v+epp is representable");

    cumulative_sum =
        first_sum +
        (int32_t)k.coeffs[i];

    __CPROVER_assert(
        cumulative_sum >= (int32_t)INT16_MIN,
        "PA06C_P2_SECOND_CALL_LOWER: (v+epp)+k is representable");

    __CPROVER_assert(
        cumulative_sum <= (int32_t)INT16_MAX,
        "PA06C_P2_SECOND_CALL_UPPER: (v+epp)+k is representable");
  }

  v_initial = v;
  epp_before = epp;
  k_before = k;

  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    first_sum =
        (int32_t)v_initial.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == first_sum,
        "PA06C_P3_FIRST_CALL_EXACT: first production call is exact");
  }

  mlk_poly_add(&v, &k);

  for (i = 0; i < MLKEM_N; i++)
  {
    cumulative_sum =
        (int32_t)v_initial.coeffs[i] +
        (int32_t)epp_before.coeffs[i] +
        (int32_t)k_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == cumulative_sum,
        "PA06C_P4_CUMULATIVE_EXACT: sequential production calls compute the cumulative sum");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA06C_P5_EPP_FRAME: epp remains unchanged");

    __CPROVER_assert(
        k.coeffs[i] == k_before.coeffs[i],
        "PA06C_P6_K_FRAME: k remains unchanged");

    __CPROVER_assert(
        pa06c_mod_q((int32_t)v.coeffs[i]) ==
            pa06c_mod_q(cumulative_sum),
        "PA06C_P7_CROSS_PARAMETER_MOD_Q: cumulative result has the correct residue");
  }

  return 0;
}
```

### `run_pa06_mlk_poly_add_cross_parameter_campaign.sh`

```bash
#!/usr/bin/env bash
#
# PA-06: Cross-parameter replication campaign for mlk_poly_add.
#
# Parameter sets:
#   ML-KEM-512
#   ML-KEM-768
#   ML-KEM-1024
#
# Five successful verification units are executed per parameter set:
#
#   1. Frozen PA-01 canonical FIPS-domain harness
#   2. Frozen PA-02 complete signed contract-valid harness
#   3. PA-06A production mlk_polyvec_add caller harness
#   4. PA-06B indcpa v+epp call-site harness
#   5. PA-06C sequential indcpa v+epp+k call-site harness
#
# Total:
#   15 verification units
#   each checked in text and JSON modes
#
# PA-03 and PA-04B negative controls are not repeated here because their
# int16_t representability counterexamples are parameter-invariant.
# PA-04A is an out-of-contract diagnostic and is not required for the
# production cross-parameter closure claim.
#
# Expected final status:
#   PA06_ALL_PARAMETER_SETS_VERIFIED
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa06_mlk_poly_add_cross_parameter_campaign.sh
#   ./run_pa06_mlk_poly_add_cross_parameter_campaign.sh
#

set -uo pipefail

CAMPAIGN_ID="PA-06"
CAMPAIGN_SCOPE="cross_parameter_core_and_production_callsite_replication"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

PA01_HARNESS="cleanroom_mlk_poly_add_fips_relational_harness_v2.c"
PA02_HARNESS="pa02_mlk_poly_add_full_signed_contract_valid_harness.c"
PA06A_HARNESS="pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c"
PA06B_HARNESS="pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c"
PA06C_HARNESS="pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c"

PA01_EXPECTED_SHA256="307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e"
PA02_EXPECTED_SHA256="e83d521e23f93c2435058598be5ef245bb02c554a4b7992dd8844418720c2ce2"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa06_mlk_poly_add_cross_parameter_${TIMESTAMP}"

for tool in git cbmc goto-cc sha256sum tee grep awk; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] ||
   [ ! -f "mlkem/src/poly_k.c" ] ||
   [ ! -f "mlkem/src/poly.h" ] ||
   [ ! -f "mlkem/src/poly_k.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

for harness in \
  "${PA01_HARNESS}" \
  "${PA02_HARNESS}" \
  "${PA06A_HARNESS}" \
  "${PA06B_HARNESS}" \
  "${PA06C_HARNESS}"; do
  if [ ! -f "${harness}" ]; then
    echo "ERROR: required harness missing: ${harness}" >&2
    exit 2
  fi
done

CURRENT_COMMIT="$(git rev-parse HEAD)"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  echo "ERROR: repository commit mismatch." >&2
  echo "Expected: ${EXPECTED_COMMIT}" >&2
  echo "Actual:   ${CURRENT_COMMIT}" >&2
  exit 3
fi

PA01_ACTUAL_SHA256="$(sha256sum "${PA01_HARNESS}" | awk '{print $1}')"
PA02_ACTUAL_SHA256="$(sha256sum "${PA02_HARNESS}" | awk '{print $1}')"

if [ "${PA01_ACTUAL_SHA256}" != "${PA01_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-01 harness hash mismatch." >&2
  echo "Expected: ${PA01_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA01_ACTUAL_SHA256}" >&2
  exit 4
fi

if [ "${PA02_ACTUAL_SHA256}" != "${PA02_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-02 harness hash mismatch." >&2
  echo "Expected: ${PA02_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA02_ACTUAL_SHA256}" >&2
  exit 4
fi

mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA06_ALL_PARAMETER_SETS_VERIFIED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Frozen PA-01 hash: ${PA01_ACTUAL_SHA256}"
  echo "Frozen PA-02 hash: ${PA02_ACTUAL_SHA256}"
  echo "Verification units: 15"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

for harness in \
  "${PA01_HARNESS}" \
  "${PA02_HARNESS}" \
  "${PA06A_HARNESS}" \
  "${PA06B_HARNESS}" \
  "${PA06C_HARNESS}"; do
  sha256sum "${harness}" >> "${OUT_DIR}/harness_sha256.txt"
  cp "${harness}" "${OUT_DIR}/"
done

sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
cp "$0" "${OUT_DIR}/"

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

run_success_unit()
{
  local parameter_set="$1"
  local label="$2"
  local harness="$3"
  local source_mode="$4"
  local required_marker="$5"

  local result_dir="${OUT_DIR}/${parameter_set}/${label}"
  local goto_model="${result_dir}/${label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1
  local verification_successful="no"
  local marker_success="no"
  local failure_lines="yes"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${parameter_set}"
    "${harness}"
    mlkem/src/poly.c
  )

  if [ "${source_mode}" = "poly_k_caller" ]; then
    build_command+=(mlkem/src/poly_k.c)
  fi

  build_command+=(-o "${goto_model}")

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-06 ${parameter_set}: ${label}"
  echo "============================================================"
  echo "Building GOTO model..."

  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  if [ "${build_exit}" -eq 0 ]; then
    local text_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --trace
    )

    printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
    printf '\n' >> "${result_dir}/cbmc_command.txt"

    echo "Running CBMC text verification..."
    "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
    text_exit=${PIPESTATUS[0]}
    echo "${text_exit}" > "${result_dir}/cbmc.exit"

    local json_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --json-ui
    )

    printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
    printf '\n' >> "${result_dir}/cbmc_json_command.txt"

    echo "Running CBMC JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 0 ] &&
     [ "${json_exit}" -eq 0 ] &&
     grep -q "VERIFICATION SUCCESSFUL" "${result_dir}/cbmc_output.txt"; then
    verification_successful="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${required_marker}" "${result_dir}/cbmc_output.txt" | \
       grep -q "SUCCESS"; then
    marker_success="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     ! grep -q "FAILURE" "${result_dir}/cbmc_output.txt"; then
    failure_lines="no"
  fi

  {
    echo "parameter_set=${parameter_set}"
    echo "label=${label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_successful=${verification_successful}"
    echo "required_marker_success=${marker_success}"
    echo "failure_lines_observed=${failure_lines}"
  } > "${result_dir}/summary.txt"

  cat "${result_dir}/summary.txt"

  if [ "${verification_successful}" = "yes" ] &&
     [ "${marker_success}" = "yes" ] &&
     [ "${failure_lines}" = "no" ]; then
    return 0
  fi

  return 1
}

ALL_OK="yes"

for PARAM in 512 768 1024; do
  PARAM_OK="yes"

  if ! run_success_unit \
    "${PARAM}" \
    "pa01_canonical_fips" \
    "${PA01_HARNESS}" \
    "poly_only" \
    "P1_EXACT_SUM"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa02_full_signed_valid" \
    "${PA02_HARNESS}" \
    "poly_only" \
    "PA02_P1_EXACT_SIGNED_SUM"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa06a_polyvec_production_caller" \
    "${PA06A_HARNESS}" \
    "poly_k_caller" \
    "PA06A_P1_CROSS_PARAMETER_EXACT_SUM"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa06b_indcpa_epp_callsite" \
    "${PA06B_HARNESS}" \
    "poly_only" \
    "PA06B_P1_CROSS_PARAMETER_CALL_UPPER"; then
    PARAM_OK="no"
  fi

  if ! run_success_unit \
    "${PARAM}" \
    "pa06c_indcpa_sequential_callsite" \
    "${PA06C_HARNESS}" \
    "poly_only" \
    "PA06C_P2_SECOND_CALL_UPPER"; then
    PARAM_OK="no"
  fi

  echo "parameter_set_${PARAM}_verified=${PARAM_OK}" \
    >> "${OUT_DIR}/parameter_status.txt"

  if [ "${PARAM_OK}" != "yes" ]; then
    ALL_OK="no"
  fi
done

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${ALL_OK}" = "yes" ]; then
  FINAL_STATUS="PA06_ALL_PARAMETER_SETS_VERIFIED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "verification_units=15"
  cat "${OUT_DIR}/parameter_status.txt"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-06 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA06_ALL_PARAMETER_SETS_VERIFIED" ]; then
  echo
  echo "PA-06 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Core function and production call-site obligations were verified"
  echo "for ML-KEM-512, ML-KEM-768, and ML-KEM-1024."
else
  echo
  echo "PA-06 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

### `pa07_mlk_poly_add_mutant_implementation.c`

```c
/*
 * PA-07 controlled mutant implementations for mlk_poly_add.
 *
 * IMPORTANT:
 *   This file is not production source and must never replace or modify
 *   mlkem/src/poly.c. The PA-07 runner compiles it only into temporary
 *   CBMC GOTO models.
 *
 * Compile with exactly one mutation identifier:
 *
 *   PA07_MUTATION_ID=1  addition replaced by subtraction
 *   PA07_MUTATION_ID=2  loop starts at coefficient 1
 *   PA07_MUTATION_ID=3  final coefficient is skipped
 *   PA07_MUTATION_ID=4  only the first half is processed
 *   PA07_MUTATION_ID=5  result is written into b instead of r
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

#ifndef PA07_MUTATION_ID
#error PA07_MUTATION_ID must be defined
#endif

#if PA07_MUTATION_ID < 1 || PA07_MUTATION_ID > 5
#error PA07_MUTATION_ID must be between 1 and 5
#endif

void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;

#if PA07_MUTATION_ID == 1

  /*
   * M1 — arithmetic operator mutation:
   *      + is replaced by -.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] - b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 2

  /*
   * M2 — lower-bound mutation:
   *      processing begins at coefficient 1, leaving coefficient 0
   *      unchanged.
   */
  for (i = 1; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 3

  /*
   * M3 — upper-bound mutation:
   *      coefficient MLKEM_N-1 is never processed.
   */
  for (i = 0; i + 1u < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 4

  /*
   * M4 — truncation mutation:
   *      only the first half of the polynomial is processed.
   */
  for (i = 0; i < MLKEM_N / 2u; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 5

  /*
   * M5 — destination mutation:
   *      the computed result is written into the read-only operand b
   *      rather than into the accumulator r.
   *
   * The harness objects themselves are not declared const. The cast is
   * used only to model this deliberate wrong-destination implementation.
   */
  {
    mlk_poly *mutable_b;

    mutable_b = (mlk_poly *)b;

    for (i = 0; i < MLKEM_N; i++)
    {
      mutable_b->coeffs[i] =
          (int16_t)(r->coeffs[i] + b->coeffs[i]);
    }
  }

#endif
}
```

### `run_pa07_mlk_poly_add_mutation_sensitivity.sh`

```bash
#!/usr/bin/env bash
#
# PA-07: Mutation-sensitivity campaign for the frozen mlk_poly_add harnesses.
#
# Purpose:
#   Demonstrate that the successful PA-01 and PA-02 harnesses are capable of
#   rejecting meaningful defective implementations rather than merely
#   succeeding against the production body.
#
# Production source is never modified.
#
# Baseline controls:
#   - frozen PA-01 against production mlkem/src/poly.c: expected success
#   - frozen PA-02 against production mlkem/src/poly.c: expected success
#
# Controlled mutants:
#   M1: addition replaced by subtraction
#   M2: loop starts at coefficient 1
#   M3: final coefficient skipped
#   M4: only first half processed
#   M5: result written to b instead of r
#
# Each mutant is checked against both frozen harnesses:
#
#   5 mutants × 2 frozen harnesses = 10 expected-failure pairs
#
# Expected final status:
#   PA07_ALL_MUTANTS_DETECTED
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa07_mlk_poly_add_mutation_sensitivity.sh
#   ./run_pa07_mlk_poly_add_mutation_sensitivity.sh
#

set -uo pipefail

CAMPAIGN_ID="PA-07"
CAMPAIGN_SCOPE="mutation_sensitivity_of_frozen_harnesses"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="768"

PA01_HARNESS="cleanroom_mlk_poly_add_fips_relational_harness_v2.c"
PA02_HARNESS="pa02_mlk_poly_add_full_signed_contract_valid_harness.c"
MUTANT_SOURCE="pa07_mlk_poly_add_mutant_implementation.c"

PA01_EXPECTED_SHA256="307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e"
PA02_EXPECTED_SHA256="e83d521e23f93c2435058598be5ef245bb02c554a4b7992dd8844418720c2ce2"
POLY_C_EXPECTED_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa07_mlk_poly_add_mutation_${TIMESTAMP}"

for tool in git cbmc goto-cc sha256sum tee grep awk; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

for file in \
  "mlkem/src/poly.c" \
  "mlkem/src/poly.h" \
  "${PA01_HARNESS}" \
  "${PA02_HARNESS}" \
  "${MUTANT_SOURCE}"; do
  if [ ! -f "${file}" ]; then
    echo "ERROR: required file missing: ${file}" >&2
    exit 2
  fi
done

CURRENT_COMMIT="$(git rev-parse HEAD)"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  echo "ERROR: repository commit mismatch." >&2
  echo "Expected: ${EXPECTED_COMMIT}" >&2
  echo "Actual:   ${CURRENT_COMMIT}" >&2
  exit 3
fi

if ! git diff --quiet -- mlkem/src/poly.c; then
  echo "ERROR: production mlkem/src/poly.c has tracked modifications." >&2
  echo "PA-07 refuses to run because mutants must remain external." >&2
  exit 4
fi

PA01_ACTUAL_SHA256="$(sha256sum "${PA01_HARNESS}" | awk '{print $1}')"
PA02_ACTUAL_SHA256="$(sha256sum "${PA02_HARNESS}" | awk '{print $1}')"
POLY_C_ACTUAL_SHA256="$(sha256sum mlkem/src/poly.c | awk '{print $1}')"

if [ "${PA01_ACTUAL_SHA256}" != "${PA01_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-01 harness hash mismatch." >&2
  echo "Expected: ${PA01_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA01_ACTUAL_SHA256}" >&2
  exit 5
fi

if [ "${PA02_ACTUAL_SHA256}" != "${PA02_EXPECTED_SHA256}" ]; then
  echo "ERROR: frozen PA-02 harness hash mismatch." >&2
  echo "Expected: ${PA02_EXPECTED_SHA256}" >&2
  echo "Actual:   ${PA02_ACTUAL_SHA256}" >&2
  exit 5
fi

if [ "${POLY_C_ACTUAL_SHA256}" != "${POLY_C_EXPECTED_SHA256}" ]; then
  echo "ERROR: production poly.c hash mismatch." >&2
  echo "Expected: ${POLY_C_EXPECTED_SHA256}" >&2
  echo "Actual:   ${POLY_C_ACTUAL_SHA256}" >&2
  exit 5
fi

mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA07_ALL_MUTANTS_DETECTED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Frozen PA-01 hash: ${PA01_ACTUAL_SHA256}"
  echo "Frozen PA-02 hash: ${PA02_ACTUAL_SHA256}"
  echo "Production poly.c hash: ${POLY_C_ACTUAL_SHA256}"
  echo "Production poly.c modified: no"
  echo "Mutants: 5"
  echo "Mutant-harness pairs: 10"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

sha256sum "${PA01_HARNESS}" > "${OUT_DIR}/pa01_harness_sha256.txt"
sha256sum "${PA02_HARNESS}" > "${OUT_DIR}/pa02_harness_sha256.txt"
sha256sum "${MUTANT_SOURCE}" > "${OUT_DIR}/mutant_source_sha256.txt"
sha256sum mlkem/src/poly.c > "${OUT_DIR}/production_poly_c_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"

cp "${PA01_HARNESS}" "${OUT_DIR}/"
cp "${PA02_HARNESS}" "${OUT_DIR}/"
cp "${MUTANT_SOURCE}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

run_baseline()
{
  local harness_label="$1"
  local harness="$2"
  local required_marker="$3"

  local result_dir="${OUT_DIR}/baseline/${harness_label}"
  local goto_model="${result_dir}/${harness_label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1
  local successful="no"
  local marker_success="no"
  local failure_lines="yes"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    "${harness}"
    mlkem/src/poly.c
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-07 BASELINE: ${harness_label}"
  echo "============================================================"

  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  if [ "${build_exit}" -eq 0 ]; then
    local text_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --trace
    )

    printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
    printf '\n' >> "${result_dir}/cbmc_command.txt"

    "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
    text_exit=${PIPESTATUS[0]}
    echo "${text_exit}" > "${result_dir}/cbmc.exit"

    local json_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --json-ui
    )

    printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
    printf '\n' >> "${result_dir}/cbmc_json_command.txt"

    echo "Running baseline JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 0 ] &&
     [ "${json_exit}" -eq 0 ] &&
     grep -q "VERIFICATION SUCCESSFUL" "${result_dir}/cbmc_output.txt"; then
    successful="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${required_marker}" "${result_dir}/cbmc_output.txt" | \
       grep -q "SUCCESS"; then
    marker_success="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     ! grep -q "FAILURE" "${result_dir}/cbmc_output.txt"; then
    failure_lines="no"
  fi

  {
    echo "harness=${harness_label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_successful=${successful}"
    echo "required_marker_success=${marker_success}"
    echo "failure_lines_observed=${failure_lines}"
  } > "${result_dir}/summary.txt"

  cat "${result_dir}/summary.txt"

  if [ "${successful}" = "yes" ] &&
     [ "${marker_success}" = "yes" ] &&
     [ "${failure_lines}" = "no" ]; then
    return 0
  fi

  return 1
}

run_mutant()
{
  local mutation_id="$1"
  local mutation_name="$2"
  local harness_label="$3"
  local harness="$4"
  local expected_failure_marker="$5"

  local result_dir="${OUT_DIR}/mutants/M${mutation_id}_${mutation_name}/${harness_label}"
  local goto_model="${result_dir}/M${mutation_id}_${harness_label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1
  local verification_failed="no"
  local expected_marker_failure="no"
  local no_body_failure="no"
  local detected="no"

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    -DPA07_MUTATION_ID="${mutation_id}"
    "${harness}"
    "${MUTANT_SOURCE}"
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-07 MUTANT M${mutation_id}: ${mutation_name}"
  echo "Harness: ${harness_label}"
  echo "Expected low-level result: VERIFICATION FAILED"
  echo "============================================================"

  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  if [ "${build_exit}" -eq 0 ]; then
    local text_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --trace
    )

    printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
    printf '\n' >> "${result_dir}/cbmc_command.txt"

    "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
    text_exit=${PIPESTATUS[0]}
    echo "${text_exit}" > "${result_dir}/cbmc.exit"

    local json_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --json-ui
    )

    printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
    printf '\n' >> "${result_dir}/cbmc_json_command.txt"

    echo "Running expected-failure JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -q "VERIFICATION FAILED" "${result_dir}/cbmc_output.txt"; then
    verification_failed="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -F "${expected_failure_marker}" "${result_dir}/cbmc_output.txt" | \
       grep -q "FAILURE"; then
    expected_marker_failure="yes"
  fi

  if [ -f "${result_dir}/cbmc_output.txt" ] &&
     grep -q "no body for callee" "${result_dir}/cbmc_output.txt"; then
    no_body_failure="yes"
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 10 ] &&
     [ "${json_exit}" -eq 10 ] &&
     [ "${verification_failed}" = "yes" ] &&
     [ "${expected_marker_failure}" = "yes" ] &&
     [ "${no_body_failure}" = "no" ]; then
    detected="yes"
  fi

  {
    echo "mutation_id=${mutation_id}"
    echo "mutation_name=${mutation_name}"
    echo "harness=${harness_label}"
    echo "expected_failure_marker=${expected_failure_marker}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "verification_failed=${verification_failed}"
    echo "expected_marker_failure_observed=${expected_marker_failure}"
    echo "no_body_failure_observed=${no_body_failure}"
    echo "mutant_detected=${detected}"
  } > "${result_dir}/summary.txt"

  cat "${result_dir}/summary.txt"

  if [ "${detected}" = "yes" ]; then
    return 0
  fi

  return 1
}

BASELINE_PA01="no"
BASELINE_PA02="no"

if run_baseline \
  "pa01_canonical_fips" \
  "${PA01_HARNESS}" \
  "P1_EXACT_SUM"; then
  BASELINE_PA01="yes"
fi

if run_baseline \
  "pa02_full_signed_valid" \
  "${PA02_HARNESS}" \
  "PA02_P1_EXACT_SIGNED_SUM"; then
  BASELINE_PA02="yes"
fi

DETECTED_PAIRS=0
ALL_MUTATIONS_OK="yes"
: > "${OUT_DIR}/mutation_status.txt"

for MUTATION_ID in 1 2 3 4 5; do
  case "${MUTATION_ID}" in
    1)
      MUTATION_NAME="subtract_instead_of_add"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    2)
      MUTATION_NAME="loop_starts_at_one"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    3)
      MUTATION_NAME="skip_final_coefficient"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    4)
      MUTATION_NAME="process_only_first_half"
      PA01_MARKER="P1_EXACT_SUM"
      PA02_MARKER="PA02_P1_EXACT_SIGNED_SUM"
      ;;
    5)
      MUTATION_NAME="write_result_to_b"
      PA01_MARKER="P4_RIGHT_INPUT_FRAME"
      PA02_MARKER="PA02_P4_RIGHT_INPUT_FRAME"
      ;;
  esac

  PA01_DETECTED="no"
  PA02_DETECTED="no"

  if run_mutant \
    "${MUTATION_ID}" \
    "${MUTATION_NAME}" \
    "pa01_canonical_fips" \
    "${PA01_HARNESS}" \
    "${PA01_MARKER}"; then
    PA01_DETECTED="yes"
    DETECTED_PAIRS=$((DETECTED_PAIRS + 1))
  fi

  if run_mutant \
    "${MUTATION_ID}" \
    "${MUTATION_NAME}" \
    "pa02_full_signed_valid" \
    "${PA02_HARNESS}" \
    "${PA02_MARKER}"; then
    PA02_DETECTED="yes"
    DETECTED_PAIRS=$((DETECTED_PAIRS + 1))
  fi

  MUTATION_DETECTED="no"
  if [ "${PA01_DETECTED}" = "yes" ] &&
     [ "${PA02_DETECTED}" = "yes" ]; then
    MUTATION_DETECTED="yes"
  else
    ALL_MUTATIONS_OK="no"
  fi

  {
    echo "mutation_${MUTATION_ID}_name=${MUTATION_NAME}"
    echo "mutation_${MUTATION_ID}_pa01_detected=${PA01_DETECTED}"
    echo "mutation_${MUTATION_ID}_pa02_detected=${PA02_DETECTED}"
    echo "mutation_${MUTATION_ID}_detected_by_both=${MUTATION_DETECTED}"
  } >> "${OUT_DIR}/mutation_status.txt"
done

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${BASELINE_PA01}" = "yes" ] &&
   [ "${BASELINE_PA02}" = "yes" ] &&
   [ "${ALL_MUTATIONS_OK}" = "yes" ] &&
   [ "${DETECTED_PAIRS}" -eq 10 ]; then
  FINAL_STATUS="PA07_ALL_MUTANTS_DETECTED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "production_source_modified=no"
  echo "baseline_pa01_verified=${BASELINE_PA01}"
  echo "baseline_pa02_verified=${BASELINE_PA02}"
  echo "mutants_total=5"
  echo "mutant_harness_pairs=10"
  echo "detected_pairs=${DETECTED_PAIRS}"
  cat "${OUT_DIR}/mutation_status.txt"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-07 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA07_ALL_MUTANTS_DETECTED" ]; then
  echo
  echo "PA-07 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Both frozen harnesses accepted the production baseline."
  echo "Both frozen harnesses rejected every controlled mutant."
  echo "Production source remained unchanged."
else
  echo
  echo "PA-07 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

### `pa08a_mlk_poly_add_boundary_hardening_harness.c`

```c
/*
 * PA-08A: Boundary, loop-endpoint, and target-completion hardening for
 *         the production mlk_poly_add implementation.
 *
 * This successful proof harness combines:
 *
 *   1. canonical-domain lower and upper arithmetic boundaries;
 *   2. complete signed-valid INT16_MIN and INT16_MAX boundaries;
 *   3. split-operand witnesses for both signed endpoints;
 *   4. explicit coefficient 0 and coefficient MLKEM_N-1 checks;
 *   5. target-call completion markers;
 *   6. exact-result and read-only-frame verification.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa08a_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa08a_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly canonical_r;
  mlk_poly canonical_b;
  mlk_poly canonical_r_before;
  mlk_poly canonical_b_before;

  mlk_poly signed_r;
  mlk_poly signed_b;
  mlk_poly signed_r_before;
  mlk_poly signed_b_before;

  unsigned i;
  int32_t mathematical_sum;

  int canonical_target_completed;
  int signed_target_completed;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA08A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA08A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA08A_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA08A_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  __CPROVER_assert(
      &canonical_r != &canonical_b,
      "PA08A_DISJOINTNESS: canonical operands are distinct");

  __CPROVER_assert(
      &signed_r != &signed_b,
      "PA08A_DISJOINTNESS: signed operands are distinct");

  /*
   * Canonical symbolic domain with concrete endpoint witnesses.
   *
   * Coefficient 0:
   *   0 + 0 = 0
   *
   * Coefficient MLKEM_N-1:
   *   (q-1) + (q-1) = 2*q-2
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    if (i == 0u)
    {
      canonical_r.coeffs[i] = 0;
      canonical_b.coeffs[i] = 0;
    }
    else if (i == MLKEM_N - 1u)
    {
      canonical_r.coeffs[i] = (int16_t)(MLKEM_Q - 1);
      canonical_b.coeffs[i] = (int16_t)(MLKEM_Q - 1);
    }
    else
    {
      canonical_r.coeffs[i] = pa08a_nondet_int16();
      canonical_b.coeffs[i] = pa08a_nondet_int16();

      __CPROVER_assume(
          (int32_t)canonical_r.coeffs[i] >= 0);
      __CPROVER_assume(
          (int32_t)canonical_r.coeffs[i] < (int32_t)MLKEM_Q);

      __CPROVER_assume(
          (int32_t)canonical_b.coeffs[i] >= 0);
      __CPROVER_assume(
          (int32_t)canonical_b.coeffs[i] < (int32_t)MLKEM_Q);
    }
  }

  /*
   * Complete signed-valid symbolic domain with four endpoint witnesses.
   *
   * index 0:           INT16_MIN + 0 = INT16_MIN
   * index 1:           -16384 + -16384 = INT16_MIN
   * index N-2:          16384 + 16383 = INT16_MAX
   * index N-1:         INT16_MAX + 0 = INT16_MAX
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    if (i == 0u)
    {
      signed_r.coeffs[i] = (int16_t)INT16_MIN;
      signed_b.coeffs[i] = 0;
    }
    else if (i == 1u)
    {
      signed_r.coeffs[i] = (int16_t)-16384;
      signed_b.coeffs[i] = (int16_t)-16384;
    }
    else if (i == MLKEM_N - 2u)
    {
      signed_r.coeffs[i] = (int16_t)16384;
      signed_b.coeffs[i] = (int16_t)16383;
    }
    else if (i == MLKEM_N - 1u)
    {
      signed_r.coeffs[i] = (int16_t)INT16_MAX;
      signed_b.coeffs[i] = 0;
    }
    else
    {
      signed_r.coeffs[i] = pa08a_nondet_int16();
      signed_b.coeffs[i] = pa08a_nondet_int16();

      mathematical_sum =
          (int32_t)signed_r.coeffs[i] +
          (int32_t)signed_b.coeffs[i];

      __CPROVER_assume(
          mathematical_sum >= (int32_t)INT16_MIN);
      __CPROVER_assume(
          mathematical_sum <= (int32_t)INT16_MAX);
    }
  }

  canonical_r_before = canonical_r;
  canonical_b_before = canonical_b;

  signed_r_before = signed_r;
  signed_b_before = signed_b;

  canonical_target_completed = 0;
  mlk_poly_add(&canonical_r, &canonical_b);
  canonical_target_completed = 1;

  signed_target_completed = 0;
  mlk_poly_add(&signed_r, &signed_b);
  signed_target_completed = 1;

  __CPROVER_assert(
      canonical_target_completed == 1,
      "PA08A_R1_CANONICAL_TARGET_COMPLETED: production call returned");

  __CPROVER_assert(
      signed_target_completed == 1,
      "PA08A_R2_SIGNED_TARGET_COMPLETED: production call returned");

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)canonical_r_before.coeffs[i] +
        (int32_t)canonical_b_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)canonical_r.coeffs[i] == mathematical_sum,
        "PA08A_P1_CANONICAL_EXACT_SUM: canonical result equals the exact sum");

    __CPROVER_assert(
        canonical_b.coeffs[i] == canonical_b_before.coeffs[i],
        "PA08A_P2_CANONICAL_FRAME: canonical right operand remains unchanged");

    __CPROVER_assert(
        pa08a_mod_q((int32_t)canonical_r.coeffs[i]) ==
            pa08a_mod_q(mathematical_sum),
        "PA08A_P3_CANONICAL_MOD_Q: canonical result has the correct residue");
  }

  __CPROVER_assert(
      canonical_r.coeffs[0] == 0,
      "PA08A_B1_CANONICAL_LOWER_BOUNDARY: coefficient 0 reaches exact sum zero");

  __CPROVER_assert(
      (int32_t)canonical_r.coeffs[MLKEM_N - 1u] ==
          (int32_t)(2 * MLKEM_Q - 2),
      "PA08A_B2_CANONICAL_UPPER_BOUNDARY: final coefficient reaches 2*q-2");

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)signed_r_before.coeffs[i] +
        (int32_t)signed_b_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)signed_r.coeffs[i] == mathematical_sum,
        "PA08A_P4_SIGNED_EXACT_SUM: signed-valid result equals the exact sum");

    __CPROVER_assert(
        signed_b.coeffs[i] == signed_b_before.coeffs[i],
        "PA08A_P5_SIGNED_FRAME: signed right operand remains unchanged");

    __CPROVER_assert(
        pa08a_mod_q((int32_t)signed_r.coeffs[i]) ==
            pa08a_mod_q(mathematical_sum),
        "PA08A_P6_SIGNED_MOD_Q: signed result has the correct residue");
  }

  __CPROVER_assert(
      signed_r.coeffs[0] == (int16_t)INT16_MIN,
      "PA08A_B3_SIGNED_MIN_DIRECT: coefficient 0 reaches INT16_MIN");

  __CPROVER_assert(
      signed_r.coeffs[1] == (int16_t)INT16_MIN,
      "PA08A_B4_SIGNED_MIN_SPLIT: split operands reach INT16_MIN");

  __CPROVER_assert(
      signed_r.coeffs[MLKEM_N - 2u] == (int16_t)INT16_MAX,
      "PA08A_B5_SIGNED_MAX_SPLIT: split operands reach INT16_MAX");

  __CPROVER_assert(
      signed_r.coeffs[MLKEM_N - 1u] == (int16_t)INT16_MAX,
      "PA08A_B6_SIGNED_MAX_DIRECT: final coefficient reaches INT16_MAX");

  return 0;
}
```

### `pa08b_mlk_poly_add_reachability_sentinel_harness.c`

```c
/*
 * PA-08B: Expected-failure reachability sentinel for mlk_poly_add.
 *
 * Purpose:
 *   Demonstrate that the canonical and complete signed-valid assumptions
 *   admit concrete executions that reach and return from production
 *   mlk_poly_add.
 *
 * The two deliberately false assertions occur only after their respective
 * target calls. Their expected failure is evidence that the paths are
 * reachable and the assumptions are not contradictory.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Expected campaign interpretation:
 *   BOTH_REACHABILITY_SENTINELS_CONFIRMED
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa08b_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly canonical_r;
  mlk_poly canonical_b;

  mlk_poly signed_r;
  mlk_poly signed_b;

  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA08B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA08B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  for (i = 0; i < MLKEM_N; i++)
  {
    canonical_r.coeffs[i] = pa08b_nondet_int16();
    canonical_b.coeffs[i] = pa08b_nondet_int16();

    __CPROVER_assume(
        (int32_t)canonical_r.coeffs[i] >= 0);
    __CPROVER_assume(
        (int32_t)canonical_r.coeffs[i] < (int32_t)MLKEM_Q);

    __CPROVER_assume(
        (int32_t)canonical_b.coeffs[i] >= 0);
    __CPROVER_assume(
        (int32_t)canonical_b.coeffs[i] < (int32_t)MLKEM_Q);
  }

  mlk_poly_add(&canonical_r, &canonical_b);

  /*
   * Expected FAILURE proves that at least one canonical execution reaches
   * this point after the production target returns.
   */
  __CPROVER_assert(
      0,
      "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET");

  for (i = 0; i < MLKEM_N; i++)
  {
    signed_r.coeffs[i] = pa08b_nondet_int16();
    signed_b.coeffs[i] = pa08b_nondet_int16();

    mathematical_sum =
        (int32_t)signed_r.coeffs[i] +
        (int32_t)signed_b.coeffs[i];

    __CPROVER_assume(
        mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(
        mathematical_sum <= (int32_t)INT16_MAX);
  }

  mlk_poly_add(&signed_r, &signed_b);

  /*
   * Expected FAILURE proves that at least one complete signed-valid
   * execution reaches this point after the production target returns.
   */
  __CPROVER_assert(
      0,
      "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET");

  return 0;
}
```

### `pa08c_mlk_poly_add_upper_outside_boundary_harness.c`

```c
/*
 * PA-08C: Positive just-outside-boundary negative control.
 *
 * Boundary witness:
 *   INT16_MAX + 1 = 32768
 *
 * The exact mathematical sum is one greater than the largest representable
 * int16_t value.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Required evidence:
 *   - exact-result assertion failure;
 *   - target signed-conversion failure;
 *   - no missing-body failure.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

int main(void)
{
  mlk_poly r;
  mlk_poly b;
  mlk_poly r_before;

  unsigned i;
  int32_t mathematical_sum;

  for (i = 0; i < MLKEM_N; i++)
  {
    r.coeffs[i] = 0;
    b.coeffs[i] = 0;
  }

  r.coeffs[0] = (int16_t)INT16_MAX;
  b.coeffs[0] = 1;

  r_before = r;

  __CPROVER_assert(
      &r != &b,
      "PA08C_DISJOINTNESS: positive-boundary operands are distinct");

  mlk_poly_add(&r, &b);

  mathematical_sum =
      (int32_t)r_before.coeffs[0] +
      (int32_t)b.coeffs[0];

  __CPROVER_assert(
      mathematical_sum == (int32_t)INT16_MAX + 1,
      "PA08C_BOUNDARY_BINDING: mathematical sum is INT16_MAX+1");

  __CPROVER_assert(
      (int32_t)r.coeffs[0] == mathematical_sum,
      "PA08C_P1_POSITIVE_JUST_OUTSIDE_EXACT_SUM: INT16_MAX+1 cannot be stored exactly");

  return 0;
}
```

### `pa08d_mlk_poly_add_lower_outside_boundary_harness.c`

```c
/*
 * PA-08D: Negative just-outside-boundary negative control.
 *
 * Boundary witness:
 *   INT16_MIN + (-1) = -32769
 *
 * The exact mathematical sum is one less than the smallest representable
 * int16_t value.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Required evidence:
 *   - exact-result assertion failure;
 *   - target signed-conversion failure;
 *   - no missing-body failure.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

int main(void)
{
  mlk_poly r;
  mlk_poly b;
  mlk_poly r_before;

  unsigned i;
  int32_t mathematical_sum;

  for (i = 0; i < MLKEM_N; i++)
  {
    r.coeffs[i] = 0;
    b.coeffs[i] = 0;
  }

  r.coeffs[MLKEM_N - 1u] = (int16_t)INT16_MIN;
  b.coeffs[MLKEM_N - 1u] = (int16_t)-1;

  r_before = r;

  __CPROVER_assert(
      &r != &b,
      "PA08D_DISJOINTNESS: negative-boundary operands are distinct");

  mlk_poly_add(&r, &b);

  mathematical_sum =
      (int32_t)r_before.coeffs[MLKEM_N - 1u] +
      (int32_t)b.coeffs[MLKEM_N - 1u];

  __CPROVER_assert(
      mathematical_sum == (int32_t)INT16_MIN - 1,
      "PA08D_BOUNDARY_BINDING: mathematical sum is INT16_MIN-1");

  __CPROVER_assert(
      (int32_t)r.coeffs[MLKEM_N - 1u] == mathematical_sum,
      "PA08D_P1_NEGATIVE_JUST_OUTSIDE_EXACT_SUM: INT16_MIN-1 cannot be stored exactly");

  return 0;
}
```

### `run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh`

```bash
#!/usr/bin/env bash
#
# PA-08: Vacuity, reachability, loop-endpoint, and arithmetic-boundary
#        hardening campaign for mlk_poly_add.
#
# PA-08A:
#   Successful proof of exact legal boundaries, target completion,
#   coefficient 0, and coefficient MLKEM_N-1.
#
# PA-08B:
#   Expected-failure reachability sentinels after canonical and signed-valid
#   target calls. The sentinel failures demonstrate satisfiable assumptions
#   and post-target path reachability.
#
# PA-08C:
#   Positive just-outside boundary:
#       INT16_MAX + 1
#
# PA-08D:
#   Negative just-outside boundary:
#       INT16_MIN - 1
#
# Expected final status:
#   PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED
#
# Production source is never modified.
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh
#   ./run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh
#

set -uo pipefail

CAMPAIGN_ID="PA-08"
CAMPAIGN_SCOPE="vacuity_reachability_loop_endpoint_and_boundary_hardening"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="768"

HARNESS_A="pa08a_mlk_poly_add_boundary_hardening_harness.c"
HARNESS_B="pa08b_mlk_poly_add_reachability_sentinel_harness.c"
HARNESS_C="pa08c_mlk_poly_add_upper_outside_boundary_harness.c"
HARNESS_D="pa08d_mlk_poly_add_lower_outside_boundary_harness.c"

POLY_C_EXPECTED_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa08_mlk_poly_add_hardening_${TIMESTAMP}"

for tool in git cbmc goto-cc sha256sum tee grep awk; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

for file in \
  "mlkem/src/poly.c" \
  "mlkem/src/poly.h" \
  "${HARNESS_A}" \
  "${HARNESS_B}" \
  "${HARNESS_C}" \
  "${HARNESS_D}"; do
  if [ ! -f "${file}" ]; then
    echo "ERROR: required file missing: ${file}" >&2
    exit 2
  fi
done

CURRENT_COMMIT="$(git rev-parse HEAD)"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  echo "ERROR: repository commit mismatch." >&2
  echo "Expected: ${EXPECTED_COMMIT}" >&2
  echo "Actual:   ${CURRENT_COMMIT}" >&2
  exit 3
fi

if ! git diff --quiet -- mlkem/src/poly.c; then
  echo "ERROR: production mlkem/src/poly.c has tracked modifications." >&2
  exit 4
fi

POLY_C_ACTUAL_SHA256="$(sha256sum mlkem/src/poly.c | awk '{print $1}')"

if [ "${POLY_C_ACTUAL_SHA256}" != "${POLY_C_EXPECTED_SHA256}" ]; then
  echo "ERROR: production poly.c hash mismatch." >&2
  echo "Expected: ${POLY_C_EXPECTED_SHA256}" >&2
  echo "Actual:   ${POLY_C_ACTUAL_SHA256}" >&2
  exit 5
fi

mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Production poly.c hash: ${POLY_C_ACTUAL_SHA256}"
  echo "Production source modified: no"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

for harness in "${HARNESS_A}" "${HARNESS_B}" "${HARNESS_C}" "${HARNESS_D}"; do
  sha256sum "${harness}" >> "${OUT_DIR}/harness_sha256.txt"
  cp "${harness}" "${OUT_DIR}/"
done

sha256sum mlkem/src/poly.c > "${OUT_DIR}/production_poly_c_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
cp "$0" "${OUT_DIR}/"

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

build_and_run()
{
  local label="$1"
  local harness="$2"
  local result_dir="${OUT_DIR}/${label}"
  local goto_model="${result_dir}/${label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    "${harness}"
    mlkem/src/poly.c
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-08 UNIT: ${label}"
  echo "============================================================"

  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  if [ "${build_exit}" -eq 0 ]; then
    local text_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --trace
    )

    printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
    printf '\n' >> "${result_dir}/cbmc_command.txt"

    "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
    text_exit=${PIPESTATUS[0]}
    echo "${text_exit}" > "${result_dir}/cbmc.exit"

    local json_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --json-ui
    )

    printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
    printf '\n' >> "${result_dir}/cbmc_json_command.txt"

    echo "Running JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  echo "${build_exit} ${text_exit} ${json_exit}"
}

marker_has_status()
{
  local output_file="$1"
  local marker="$2"
  local status="$3"

  grep -F "${marker}" "${output_file}" | grep -q "${status}"
}

unexpected_failure_exists()
{
  local allow_conversion="$1"
  local output_file="$2"
  shift 2

  local line
  local allowed="no"

  while IFS= read -r line; do
    allowed="no"

    for marker in "$@"; do
      if printf '%s\n' "${line}" | grep -Fq "${marker}"; then
        allowed="yes"
      fi
    done

    if [ "${allow_conversion}" = "yes" ] &&
       printf '%s\n' "${line}" | \
         grep -Fq "arithmetic overflow on signed type conversion"; then
      allowed="yes"
    fi

    if [ "${allowed}" = "no" ]; then
      return 0
    fi
  done < <(grep "FAILURE" "${output_file}" || true)

  return 1
}

read -r A_BUILD A_TEXT A_JSON < <(
  build_and_run "pa08a_boundary_proof" "${HARNESS_A}" |
    tee /dev/stderr | tail -n 1
)

A_VERIFIED="no"

if [ "${A_BUILD}" -eq 0 ] &&
   [ "${A_TEXT}" -eq 0 ] &&
   [ "${A_JSON}" -eq 0 ] &&
   grep -q "VERIFICATION SUCCESSFUL" \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" &&
   ! grep -q "FAILURE" \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B1_CANONICAL_LOWER_BOUNDARY" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B2_CANONICAL_UPPER_BOUNDARY" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B3_SIGNED_MIN_DIRECT" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B6_SIGNED_MAX_DIRECT" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_R1_CANONICAL_TARGET_COMPLETED" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_R2_SIGNED_TARGET_COMPLETED" \
     "SUCCESS"; then
  A_VERIFIED="yes"
fi

read -r B_BUILD B_TEXT B_JSON < <(
  build_and_run "pa08b_reachability_sentinels" "${HARNESS_B}" |
    tee /dev/stderr | tail -n 1
)

B_CANONICAL_REACHABLE="no"
B_SIGNED_REACHABLE="no"
B_NO_BODY_FAILURE="no"
B_UNEXPECTED_FAILURE="yes"

if [ -f "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" ]; then
  if marker_has_status \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" \
       "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET" \
       "FAILURE"; then
    B_CANONICAL_REACHABLE="yes"
  fi

  if marker_has_status \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" \
       "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET" \
       "FAILURE"; then
    B_SIGNED_REACHABLE="yes"
  fi

  if grep -q "no body for callee" \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt"; then
    B_NO_BODY_FAILURE="yes"
  fi

  if ! unexpected_failure_exists \
       "no" \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" \
       "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET" \
       "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET"; then
    B_UNEXPECTED_FAILURE="no"
  fi
fi

B_CONFIRMED="no"

if [ "${B_BUILD}" -eq 0 ] &&
   [ "${B_TEXT}" -eq 10 ] &&
   [ "${B_JSON}" -eq 10 ] &&
   grep -q "VERIFICATION FAILED" \
     "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" &&
   [ "${B_CANONICAL_REACHABLE}" = "yes" ] &&
   [ "${B_SIGNED_REACHABLE}" = "yes" ] &&
   [ "${B_NO_BODY_FAILURE}" = "no" ] &&
   [ "${B_UNEXPECTED_FAILURE}" = "no" ]; then
  B_CONFIRMED="yes"
fi

check_outside_boundary()
{
  local label="$1"
  local harness="$2"
  local exact_marker="$3"

  local build_exit
  local text_exit
  local json_exit
  local exact_failure="no"
  local conversion_failure="no"
  local no_body_failure="no"
  local unexpected_failure="yes"
  local confirmed="no"

  read -r build_exit text_exit json_exit < <(
    build_and_run "${label}" "${harness}" |
      tee /dev/stderr | tail -n 1
  )

  local output_file="${OUT_DIR}/${label}/cbmc_output.txt"

  if [ -f "${output_file}" ]; then
    if marker_has_status "${output_file}" "${exact_marker}" "FAILURE"; then
      exact_failure="yes"
    fi

    if grep -F "arithmetic overflow on signed type conversion" \
         "${output_file}" | grep -q "FAILURE"; then
      conversion_failure="yes"
    fi

    if grep -q "no body for callee" "${output_file}"; then
      no_body_failure="yes"
    fi

    if ! unexpected_failure_exists \
         "yes" \
         "${output_file}" \
         "${exact_marker}"; then
      unexpected_failure="no"
    fi
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 10 ] &&
     [ "${json_exit}" -eq 10 ] &&
     grep -q "VERIFICATION FAILED" "${output_file}" &&
     [ "${exact_failure}" = "yes" ] &&
     [ "${conversion_failure}" = "yes" ] &&
     [ "${no_body_failure}" = "no" ] &&
     [ "${unexpected_failure}" = "no" ]; then
    confirmed="yes"
  fi

  {
    echo "label=${label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "exact_assertion_failure_observed=${exact_failure}"
    echo "conversion_failure_observed=${conversion_failure}"
    echo "no_body_failure_observed=${no_body_failure}"
    echo "unexpected_failure_observed=${unexpected_failure}"
    echo "boundary_confirmed=${confirmed}"
  } > "${OUT_DIR}/${label}/summary.txt"

  cat "${OUT_DIR}/${label}/summary.txt"

  printf '%s\n' "${confirmed}"
}

C_CONFIRMED="$(
  check_outside_boundary \
    "pa08c_positive_outside_boundary" \
    "${HARNESS_C}" \
    "PA08C_P1_POSITIVE_JUST_OUTSIDE_EXACT_SUM" |
    tee /dev/stderr | tail -n 1
)"

D_CONFIRMED="$(
  check_outside_boundary \
    "pa08d_negative_outside_boundary" \
    "${HARNESS_D}" \
    "PA08D_P1_NEGATIVE_JUST_OUTSIDE_EXACT_SUM" |
    tee /dev/stderr | tail -n 1
)"

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${A_VERIFIED}" = "yes" ] &&
   [ "${B_CONFIRMED}" = "yes" ] &&
   [ "${C_CONFIRMED}" = "yes" ] &&
   [ "${D_CONFIRMED}" = "yes" ]; then
  FINAL_STATUS="PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "production_source_modified=no"
  echo "pa08a_boundary_and_endpoint_proof_verified=${A_VERIFIED}"
  echo "pa08b_canonical_path_reachable=${B_CANONICAL_REACHABLE}"
  echo "pa08b_signed_valid_path_reachable=${B_SIGNED_REACHABLE}"
  echo "pa08b_only_expected_sentinel_failures=$([ "${B_UNEXPECTED_FAILURE}" = "no" ] && echo yes || echo no)"
  echo "pa08c_positive_just_outside_boundary_confirmed=${C_CONFIRMED}"
  echo "pa08d_negative_just_outside_boundary_confirmed=${D_CONFIRMED}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-08 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED" ]; then
  echo
  echo "PA-08 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Valid assumptions were shown reachable after target execution."
  echo "Exact legal lower and upper boundaries were verified."
  echo "Both nearest out-of-range boundaries were rejected as expected."
  echo "Production source remained unchanged."
else
  echo
  echo "PA-08 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

## 12. Deterministic Stage-1 Status

```text
PA09_EVIDENCE_BUNDLE_READY_FOR_SEMANTIC_AUDIT
```
