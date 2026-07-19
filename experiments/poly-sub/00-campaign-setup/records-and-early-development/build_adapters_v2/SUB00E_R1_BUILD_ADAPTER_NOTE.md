# SUB-00E-R1 Fail-Closed Zeroization Build Adapter

## Reason

The original SUB-00E direct builds selected `MLK_CONFIG_NO_ASM`.
Under that configuration, `verify.h` requires the embedding
application to supply `MLK_CONFIG_CUSTOM_ZEROIZE`.

The target `mlk_poly_sub` and `mlk_poly_reduce` paths do not require
zeroization, but the complete production translation unit still
includes declarations and other functions that refer to the hook.

## Adapter design

The rerun defines:

    MLK_CONFIG_CUSTOM_ZEROIZE=1

and force-includes:

    sub00e_r1_fail_closed_zeroize.h

The adapter provides a translation-unit-local `mlk_zeroize` body
containing a deliberately false CBMC assertion.

Consequences:

- no production source file is modified;
- no independently authored theorem harness is modified;
- the adapter cannot be used to claim zeroization correctness;
- an unexpected reachable call to `mlk_zeroize` fails closed;
- successful target proofs therefore require the adapter call to
  remain unreachable from the selected harness entry point.

## Scope

This adapter exists only to construct and inspect the GOTO models and,
after final manifest freeze, to support the selected poly_sub/poly_reduce
verification campaign. It is not a production zeroization implementation.
