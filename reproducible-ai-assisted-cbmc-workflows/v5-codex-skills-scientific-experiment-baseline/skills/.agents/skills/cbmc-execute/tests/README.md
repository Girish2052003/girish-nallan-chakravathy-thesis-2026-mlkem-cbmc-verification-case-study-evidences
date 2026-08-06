# Local validation

Run from the skill root:

```bash
python3 -m unittest -v tests/test_cbmc_execute.py
```

The suite uses a deterministic executable named `cbmc` under `tests/fixtures/bin/`. It simulates CBMC JSON success, property failure, tool error, malformed output, timeout, property inventory, coverage artefact creation, and source mutation. It does **not** substitute for runtime validation against the target environment's installed CBMC 6.9.0.
