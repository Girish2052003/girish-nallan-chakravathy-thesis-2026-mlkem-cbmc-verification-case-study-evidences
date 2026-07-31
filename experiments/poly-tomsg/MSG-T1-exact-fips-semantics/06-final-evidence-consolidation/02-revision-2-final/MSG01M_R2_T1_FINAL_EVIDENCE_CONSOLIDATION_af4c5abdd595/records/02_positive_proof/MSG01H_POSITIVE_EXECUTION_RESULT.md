# MSG-01H — Authoritative MSG-T1 Positive Execution Result

## Frozen inputs

- Source commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Harness SHA-256: `5ce480427d7792b3dca091ac198b43562c4d4dfd6c9d96dae5a73e7ef1e72b55`
- GOTO SHA-256: `51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d`
- Unwindset: `main.0:257,main.1:257,mlk_msg01f_poly_tomsg.0:257,mlk_msg01f_poly_tomsg.1:257,mlk_msg01f_poly_tomsg.2:257`

## CBMC execution result

```text
CBMC_EXIT=0
PROPERTY_RECORD_COUNT=521
SUCCESS_COUNT=521
FAILURE_COUNT=0
UNKNOWN_COUNT=0
EXPECTED_MARKER_COUNT=7
FOUND_MARKER_COUNT=7
MSG_T1_EXACT_STATUS=SUCCESS
```

## Supported conclusion

Within the frozen canonical-domain verification model, under the recorded
CBMC checks and unwindset, CBMC returned no counterexample and every reported
property succeeded. In particular, the registered exact-output assertion
relating every produced output bit to the independent Compress1 threshold
oracle succeeded.

## Boundaries

This positive result does not by itself establish:

- complete ML-KEM decryption correctness;
- correctness outside the canonical coefficient domain;
- constant-time execution;
- timing or leakage non-interference;
- side-channel resistance;
- independence from the frozen model assumptions.

Reachability/non-vacuity and mutation evidence remain separate campaign gates.
