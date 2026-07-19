# SUB00N B4.4 — Frozen Build Plan

## Authoritative compiler family

`goto-cc 6.9.0`

## Common build configuration

```text
-std=c90
-DMLK_CONFIG_PARAMETER_SET=768
-DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00n_b4
-DMLK_CONFIG_NO_ASM=1
-DMLK_CONFIG_CUSTOM_ZEROIZE=1
-include /home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/.frozen_harness_family_v1.tmp.12179/support/sub00n_b4_fail_closed_zeroize.h
-include /home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/.frozen_harness_family_v1.tmp.12179/support/sub00n_b4_verify_pragma_scope.h
-I/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/source/mlkem
-I/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/source/mlkem/src
<selected Batch-4 harness>
/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/source/mlkem/src/poly.c
/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00N_BATCH4_CANONICAL_DOMAIN/.frozen_harness_family_v1.tmp.12179/support/sub00n_b4_optblocker_zero.c
-o <case-specific GOTO output>
```

## Model inspection requirement

Each case must separately record:

- exact compiler command;
- compiler exit code;
- GOTO validation;
- symbol table;
- GOTO functions;
- reachable call graph;
- undefined functions;
- reachable loop identifiers;
- property inventory;
- GOTO hash.

## Execution order

1. Positive SUB-T4 theorem.
2. Reachability campaign.
3. Stricter-upper expected-failure control.
4. Stricter-lower expected-failure control.

Negative-control results must never overwrite or compensate for the
positive theorem result.
