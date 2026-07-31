# MSG-01G-R1 — Property-Inventory Audit Correction

## Failed MSG-01G classification

The first MSG-01G attempt successfully:

- bound the frozen source, harness, support files and GOTO;
- validated the frozen GOTO;
- derived four reachable functions;
- derived five reachable loops;
- produced the expected unwindset;
- completed CBMC property inventory;
- found all seven MSG-T1 markers.

It then falsely rejected every property whose name matched
`mlk_scalar_compress_d1.*overflow`.

The legitimate conversion properties are:

```text
mlk_scalar_compress_d1.overflow.1
mlk_scalar_compress_d1.overflow.2
```

The intended addition-wrap property suppressed by the direct pragma adapter is:

```text
mlk_scalar_compress_d1.overflow.3
```

MSG-01G-R1 requires properties 1 and 2 and forbids only property 3.

```text
FAILED_MSG01G_CLASSIFICATION=PROPERTY_INVENTORY_AUDIT_FALSE_REJECTION
FUNCTIONAL_COUNTEREXAMPLE=NO
CBMC_PROPERTY_SOLVING_EXECUTED=NO
```
