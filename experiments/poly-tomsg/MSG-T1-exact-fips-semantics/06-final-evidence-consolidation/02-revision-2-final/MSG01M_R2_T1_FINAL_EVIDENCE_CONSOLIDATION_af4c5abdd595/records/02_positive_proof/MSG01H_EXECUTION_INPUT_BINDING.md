# MSG-01H — Authoritative Positive-Execution Input Binding

## Source

- Repository: `/home/girish/THESIS-2026/mlkem-native_af4c5abd`
- Commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`

## Frozen candidate

- Harness: `/home/girish/THESIS-2026/mlk_poly_tomsg_cleanroom/MSG01G_R1_T1_FROZEN_EXECUTION_INPUT_V1_af4c5abdd595/frozen_candidate_v1/harness/msg_t1_exact_fips_candidate_v4.c`
- Harness SHA-256: `5ce480427d7792b3dca091ac198b43562c4d4dfd6c9d96dae5a73e7ef1e72b55`
- GOTO: `/home/girish/THESIS-2026/mlk_poly_tomsg_cleanroom/MSG01G_R1_T1_FROZEN_EXECUTION_INPUT_V1_af4c5abdd595/frozen_candidate_v1/build/msg_t1_exact_fips_v4_direct_pragma.goto`
- GOTO SHA-256: `51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d`

## Frozen unwindset

```text
main.0:257,main.1:257,mlk_msg01f_poly_tomsg.0:257,mlk_msg01f_poly_tomsg.1:257,mlk_msg01f_poly_tomsg.2:257
```

## Reachable proof path

```text
main
 ├── msg_t1_threshold_oracle
 └── mlk_msg01f_poly_tomsg
      └── mlk_scalar_compress_d1
```

## Execution boundary

This run executes the frozen GOTO without modifying the source, harness,
verification adapter, GOTO model or unwindset.

The result establishes only the registered canonical-domain MSG-T1 model.
It does not establish complete ML-KEM decryption correctness, constant-time
execution, leakage freedom or side-channel resistance.
