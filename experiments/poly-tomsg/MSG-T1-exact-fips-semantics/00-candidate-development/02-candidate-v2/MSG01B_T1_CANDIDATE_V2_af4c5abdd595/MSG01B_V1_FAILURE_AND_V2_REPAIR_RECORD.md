# MSG-01B — V1 Failure Classification and V2 Repair Record

## V1 result

MSG-01A candidate V1 terminated before GOTO construction with:

```text
ORACLE_INDEPENDENCE_STATIC_AUDIT=FAIL
CAPTURE_STATUS=5
```

## Root cause

The audit counted every textual occurrence of
`mlk_scalar_compress_d1` in the complete harness. The only occurrence was
inside a comment stating that the oracle did not call that function.

The V1 oracle body itself contained no production-helper invocation.

## Classification

```text
V1_FAILURE_CLASSIFICATION=AUDIT_SCRIPT_FALSE_REJECTION
V1_HARNESS_FUNCTIONAL_COUNTEREXAMPLE=NO
V1_GOTO_CONSTRUCTION_EXECUTED=NO
V1_CBMC_PROOF_EXECUTED=NO
```

## Repair

V2 retains the executable V1 harness semantics but:

1. replaces the misleading comment text;
2. extracts the oracle function body;
3. checks prohibited calls only inside that function body;
4. performs a second semantic audit on the generated GOTO program;
5. constructs fresh harness and production GOTO objects separately before
   linking them.

V1 is retained unmodified as failed-attempt evidence.
