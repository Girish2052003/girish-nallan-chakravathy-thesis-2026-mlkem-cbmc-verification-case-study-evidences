# MSG-01J-R2 — Correct Interpretation of Successful Full Unwinding

The MSG-01J-R1 companion run used:

- `--unwinding-assertions`;
- the five-loop frozen unwindset;
- bound 257 for every reachable loop.

It returned:

```text
CBMC_EXIT=0
PROPERTY_RECORD_COUNT=522
SUCCESS_COUNT=522
FAILURE_COUNT=0
UNKNOWN_COUNT=0

Neither the property IDs nor descriptions contained an unwinding record.

For these statically bounded loops, symbolic execution completed before the
257 limit was reached. CBMC therefore did not retain a standalone unwinding
assertion property in the result.

MSG-01J-R2 does not infer five nonexistent success records. Instead, it checks
the option operationally: each frozen loop is separately assigned an
insufficient bound while all other loop bounds remain frozen at 257. Each such
control must produce an unwinding-assertion failure and no unrelated failure.
