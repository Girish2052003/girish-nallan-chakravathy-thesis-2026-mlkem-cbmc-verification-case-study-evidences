# Test suite

Run:

```bash
python3 -m unittest -v tests/test_cbmc_nonvacuity_probe.py
```

The suite uses a deterministic executable named `cbmc` that emits controlled CBMC-shaped JSON. It validates request safety, companion isolation, reachability parsing, timeout/error handling, source mutation detection, schemas, hashes, reproducibility, and the no-authority boundary.

A separate real-CBMC smoke test is provided for the target Ubuntu integration phase.
