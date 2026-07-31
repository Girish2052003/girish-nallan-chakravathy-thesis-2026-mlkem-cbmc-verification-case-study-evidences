# MSG-01E Adapter Recovery Record

## Preserved failed attempts

- MSG-01A: audit-script false rejection.
- MSG-01B: contract-bearing linked GOTO validation failure.
- MSG-01C: contract-bearing single-unit GOTO validation failure.
- MSG-01D-R1: reachability cleanup completed, but parameter-dependent contract
  metadata still caused GOTO validation failure.

No MSG-T1 property solving occurred in those attempts.

## V4 correction

V4 follows the previously validated SUB-T6 adapter architecture:

1. CBMC is not globally defined.
2. cbmc.h is loaded while CBMC is undefined, erasing production contracts.
3. verify.h is loaded briefly with CBMC defined.
4. compress.h is loaded briefly with CBMC defined, activating the unchanged
   production overflow pragma scopes.
5. The actual frozen compress.c is compiled.
6. No function contract replaces mlk_poly_tomsg or mlk_scalar_compress_d1.
7. The V2 functional harness semantics are retained.

This is a verification compilation adapter. It does not edit production code.
