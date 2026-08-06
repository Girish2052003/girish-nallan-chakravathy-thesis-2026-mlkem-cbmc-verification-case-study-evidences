# Tests

Run the local suite:

```bash
python3 -m unittest -v tests/test_cbmc_counterexample_view.py
```

Run the later Ubuntu real-CBMC smoke test:

```bash
python3 tests/run_real_cbmc_smoke.py --cbmc /usr/bin/cbmc
```

The real smoke test is not a substitute for the controlled Codex activation matrix.
