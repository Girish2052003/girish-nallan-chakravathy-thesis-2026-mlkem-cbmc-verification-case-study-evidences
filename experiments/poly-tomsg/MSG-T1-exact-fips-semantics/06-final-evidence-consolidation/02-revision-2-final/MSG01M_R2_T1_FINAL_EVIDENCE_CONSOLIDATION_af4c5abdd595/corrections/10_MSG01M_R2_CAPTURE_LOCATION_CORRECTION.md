# MSG-01M-R2 — Post-tee Status-Location Correction

MSG-01M-R1 correctly changed the MSG-01G-R1 lock audit to the inner
`frozen_candidate_v1` root, but its provenance gate searched the failed
MSG-01M terminal-capture file for `CAPTURE_STATUS=15`.

That status was printed by the wrapper after the main `tee` pipeline had
closed. It appeared in the interactive terminal output but was not part of
`MSG01M_TERMINAL_CAPTURE.txt`. The R1 gate was therefore impossible to satisfy.

MSG-01M-R2 binds the first failed attempt to the failure line actually present
inside its capture:

```text
MSG01G_R1_READ_ONLY_LOCK=FAIL
```

It binds the failed R1 attempt to its actual in-capture failure line:

```text
FAILED_MSG01M_STATUS_BINDING=FAIL
```

Neither failed attempt contains `FINAL_CONSOLIDATION_AUDIT=PASS`. No accepted
source, GOTO, CBMC result, mutation result, manifest or lock rule is changed.
