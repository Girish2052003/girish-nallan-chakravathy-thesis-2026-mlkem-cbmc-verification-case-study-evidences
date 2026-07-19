# SUB00N B4.5 — GOTO Preflight and Execution-Input Freeze

## Frozen identity

Repository commit:

`d9613cf60de3132d32475c102d8c2781d84feb34`

Parameter configuration:

```text
MLK_CONFIG_PARAMETER_SET=768
MLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00n_b4
MLK_CONFIG_NO_ASM=1
MLK_CONFIG_CUSTOM_ZEROIZE=1
```

## Authoritative source

`/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/source/mlkem/src/poly.c`

SHA-256:

`f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722`

## Cases built and inspected

1. Positive SUB-T4 theorem.
2. SUB-T4 reachability controls.
3. Stricter-upper expected-failure control.
4. Stricter-lower expected-failure control.

## Frozen inspection policy

Every GOTO model was:

- produced with `goto-cc 6.9.0`;
- validated with `goto-instrument --validate-goto-binary`;
- inspected for its symbol table;
- inspected for retained GOTO functions;
- checked for the production
  `mlk_sub00n_b4_poly_sub` body;
- inspected for exact loop identifiers;
- assigned a case-specific explicit unwindset;
- inspected for its property inventory.

No theorem, coverage or negative-control solver execution occurred.

## Unwinding rule

Every 256-coefficient loop is frozen at 257 unwindings, including the
terminating loop condition.

All cases retain unwinding assertions.

## Execution boundary

The next stage may execute only the four GOTO models frozen inside this
B4.5 package.

A later rebuild must receive a new version and may not silently replace
these models.
