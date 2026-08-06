# Authoritative command pattern

The runner materialises the exact commands. The essential forms are:

```text
goto-cc -std=c90 -I. -Imlkem -Imlkem/src \
  -DMLK_CONFIG_PARAMETER_SET=768 \
  -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sa_sub \
  -DMLK_CONFIG_NO_ASM=1 \
  -DMLK_CONFIG_CUSTOM_ZEROIZE=1 \
  <harness.c> mlkem/src/poly.c -o <proof-model.goto>
```

The cover companion adds `-DSKILL_COVER_MODE=1`.

```text
cbmc <proof-model.goto> --function main \
  --bounds-check --pointer-check --pointer-overflow-check \
  --signed-overflow-check --unsigned-overflow-check \
  --conversion-check --div-by-zero-check --undefined-shift-check \
  --unwind 257 --unwinding-assertions --json-ui
```

```text
cbmc <cover-model.goto> --function main --cover cover \
  --show-test-suite --unwind 257 --json-ui
```

Function, loop, and property inventories are captured from both GOTO models before solver execution.
