# SUB-T6 B6.1 Call-Chain Binding

Status: `FROZEN`

## Exact upstream producer for v

`mlk_unpack_ciphertext` calls:

```c
mlk_poly_decompress_dv(v, c + MLKEM_POLYVECCOMPRESSEDBYTES_DU);
```

The authoritative native contract is bound to:

```text
File: /home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/source/mlkem/src/poly_k.h
Macro line: 143
Function line: 159
Canonical-output postcondition line: 165
SHA-256: 09bdfd4a19a9cb495832a78d0f099a6c949c40014472b33fb54d66bb56e660e0
```

The postcondition establishes:

```text
0 <= v[i] < MLKEM_Q
```

## Exact production slice

```c
mlk_poly_invntt_tomont(sb);  /* indcpa.c:623 */
mlk_poly_sub(v, sb);          /* indcpa.c:625 */
mlk_poly_reduce(v);           /* indcpa.c:626 */
mlk_poly_tomsg(m, v);         /* indcpa.c:628 */
```

All three earlier failed parser/search attempts are retained. They were not
CBMC failures and produced no proof results.
