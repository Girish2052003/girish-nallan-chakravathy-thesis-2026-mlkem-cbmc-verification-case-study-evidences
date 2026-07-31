# MSG-01C — V2 Failure Classification and V3 SCU Repair

## MSG-01A

MSG-01A stopped before GOTO construction because a textual audit counted a
production-helper name appearing only in a comment.

```text
CLASSIFICATION=AUDIT_SCRIPT_FALSE_REJECTION
CBMC_PROOF_EXECUTED=NO
```

## MSG-01B

MSG-01B repaired the oracle audit. The harness and production translation
units compiled and linked, but validation of the linked GOTO binary aborted
because the namespace lacked:

```text
mlk_poly_tomont::r
```

The MSG-01B command omitted the native CBMC build definitions:

```text
-Dstatic=
-DMLK_INLINE=
-DMLK_ALWAYS_INLINE=
```

The resulting failure occurred before property solving.

```text
CLASSIFICATION=VERIFICATION_ADAPTER_LINK_NAMESPACE_FAILURE
FUNCTIONAL_COUNTEREXAMPLE=NO
CBMC_PROOF_EXECUTED=NO
```

## MSG-01C repair

MSG-01C:

1. preserves V1 and V2 unmodified;
2. hashes the frozen production `compress.c`;
3. includes that exact source in one verification translation unit;
4. restores the native CBMC symbol-exposure definitions;
5. validates the raw GOTO before proof execution;
6. audits production-body presence and oracle separation.

The single-unit adapter changes compilation structure for verification. It
does not edit or replace the frozen production implementation.
