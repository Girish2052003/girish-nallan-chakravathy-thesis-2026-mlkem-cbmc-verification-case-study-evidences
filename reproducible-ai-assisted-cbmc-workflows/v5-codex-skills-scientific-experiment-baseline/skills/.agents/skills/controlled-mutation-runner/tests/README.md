# Tests

Run the complete suite:

```bash
python3 -m unittest -v tests/test_controlled_mutation_runner.py
```

The suite contains 52 tests. It uses temporary generic C workspaces and controlled executables named `gcc` and `cbmc`; it does not require system CBMC.

Run the real Ubuntu smoke test after integration:

```bash
python3 tests/run_real_cbmc_smoke.py --cbmc /usr/bin/cbmc --gcc /usr/bin/gcc
```
