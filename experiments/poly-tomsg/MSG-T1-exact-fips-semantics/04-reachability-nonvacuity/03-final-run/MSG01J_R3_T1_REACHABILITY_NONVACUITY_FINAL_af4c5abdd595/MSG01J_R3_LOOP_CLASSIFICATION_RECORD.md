# MSG-01J-R3 — Target-Loop Classification Correction

The failed MSG-01J-R2 stage assumed that reducing every loop bound to one must
produce an unwinding failure.

The exact frozen GOTO/source mapping is:

```text
mlk_msg01i_poly_tomsg.0 -> compress.c:720 -> mlk_assert_bound macro site
mlk_msg01i_poly_tomsg.1 -> compress.c:728 -> inner j loop
mlk_msg01i_poly_tomsg.2 -> compress.c:722 -> outer i loop
```

Reducing loop .0 from 257 to 1 returned CBMC exit 0 and produced the exact same
JSON SHA-256 as the accepted full-bound companion execution:

```text
d78f0cbc052ded4bed75cec905c5321c2e0176b78316ce08ff4ff7c1acef249d
```

It is therefore classified as a macro-origin loop for which bound one is
sufficient in this frozen model. It is not treated as a failed expected-failure
control.

The four multi-iteration loops are checked using U1, U2, U4 and U5.
