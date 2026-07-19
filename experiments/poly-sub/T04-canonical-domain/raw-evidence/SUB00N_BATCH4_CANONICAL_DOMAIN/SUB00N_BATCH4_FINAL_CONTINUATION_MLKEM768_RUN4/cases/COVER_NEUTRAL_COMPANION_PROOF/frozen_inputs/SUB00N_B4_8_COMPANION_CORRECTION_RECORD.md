# SUB00N B4.8 — Cover-Neutral Companion Correction

## Observed RUN3 result

RUN3 produced:

```text
SUCCESS=333
FAILURE=1
FAILURE_PROPERTY=main.no-body.__CPROVER_cover
FAILURE_DESCRIPTION=no body for callee __CPROVER_cover
UNWINDING_FAILURES=0
```

The sole failure was caused by executing a model containing
`__CPROVER_cover` calls outside coverage mode.

It was not an arithmetic, frame, bounds, overflow, production-exactness
or unwinding failure.

## Correction

A separate companion-verification model is built from:

- the same frozen reachability harness;
- the same production `poly.c`;
- the same ML-KEM-768 configuration;
- the same portable-C Mode-A support artefacts.

The additional forced-include header defines:

```c
#define __CPROVER_cover(condition) ((void)0)
```

This neutralizes only the five coverage observations.

## Evidence boundary

This derived model may be used only for:

- safety-property verification;
- production exactness verification;
- frame verification;
- explicit unwinding verification.

It may not be used as coverage evidence.

Actual coverage must use the original authoritative reachability model
with `--cover cover`.

## Integrity

- Frozen reachability harness modified: no.
- Original coverage GOTO model modified: no.
- Production source modified: no.
- RUN1 modified: no.
- RUN2 modified: no.
- RUN3 modified: no.
- Batch 3 touched: no.
