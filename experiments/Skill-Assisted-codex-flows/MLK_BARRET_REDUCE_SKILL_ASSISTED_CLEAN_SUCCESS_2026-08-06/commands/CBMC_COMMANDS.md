# Command model

The authoritative exact commands are written into `evidence/run_1` by the runner.
Their structure is:

```bash
goto-cc -std=c90 -I. -Imlkem -Imlkem/src \
  -DMLK_CONFIG_PARAMETER_SET=768 \
  -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sa_br \
  -DMLK_CONFIG_NO_ASM=1 -DCBMC \
  harness.c generated/mlk_barrett_reduce_exposed.c -o proof_model.goto

cbmc proof_model.goto --function main \
  --bounds-check --pointer-check --pointer-overflow-check \
  --signed-overflow-check --unsigned-overflow-check --conversion-check \
  --div-by-zero-check --undefined-shift-check \
  --unwind 4 --unwinding-assertions --slice-formula --json-ui

goto-cc ... -DSKILL_COVER_MODE=1 ... -o cover_model.goto
cbmc cover_model.goto --function main --cover cover --show-test-suite \
  --unwind 4 --json-ui

goto-cc ... -DSKILL_FAIL_CONTROL=1 ... -o fail_control_model.goto
cbmc fail_control_model.goto <proof checks> --trace
```

The runner additionally records `goto-instrument --show-goto-functions`,
`--show-symbol-table`, `--show-loops`, and `--show-properties` outputs.
