# MSG-01G-R1 — MSG-T1 Candidate Freeze Record

Status: **FROZEN BEFORE CBMC PROPERTY SOLVING**

## Frozen theorem candidate

For every 256-coefficient polynomial satisfying:

```text
0 <= a[k] < 3329
```

every flat output bit produced by the actual frozen
`mlk_msg01f_poly_tomsg` body equals the independently registered canonical
Compress1 threshold oracle.

## Frozen reachable path

```text
main
 ├── msg_t1_threshold_oracle
 └── mlk_msg01f_poly_tomsg
      └── mlk_scalar_compress_d1
```

## Frozen unwindset

```text
main.0:257,main.1:257,mlk_msg01f_poly_tomsg.0:257,mlk_msg01f_poly_tomsg.1:257,mlk_msg01f_poly_tomsg.2:257
```

## Boundaries

- Canonical coefficients only.
- All 256 coefficients and all 32 output bytes.
- Actual production target and compression-helper bodies.
- No target or helper contract substitution.
- No complete-decryption correctness claim.
- No constant-time, leakage or side-channel claim.

## Execution status

```text
CBMC_PROPERTY_INVENTORY_EXECUTED=YES
CBMC_PROPERTY_SOLVING_EXECUTED=NO
```
