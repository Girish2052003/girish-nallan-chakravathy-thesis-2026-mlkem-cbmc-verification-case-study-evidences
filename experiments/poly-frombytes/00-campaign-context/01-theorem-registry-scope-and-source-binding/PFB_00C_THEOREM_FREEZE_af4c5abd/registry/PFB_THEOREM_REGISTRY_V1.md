# PFB Theorem Registry V1

## Frozen target

- Campaign: PFB
- Public target: `mlk_poly_frombytes`
- Portable body: `mlk_poly_frombytes_c`
- Source commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Initial configuration: portable ML-KEM-768
- Core theorem families: 4
- Primary semantic obligations: 11
- Native semantic claim: excluded

## Independent arithmetic notation

For block `i`:

```text
W[i] =
    a[3*i]
  + 256*a[3*i + 1]
  + 65536*a[3*i + 2]

even(i) = W[i] mod 4096
odd(i)  = floor(W[i] / 4096)

pack12(x,y) = x + 4096*y
```

The oracle shall use widened arithmetic, division and remainder. It shall not
call `mlk_poly_frombytes`, `mlk_poly_frombytes_c`, or copy the production
shift-and-mask expression.

## PFB-T1 — Exact raw-decoding semantics

1. **PFB-T1.P1** — For every block `i`, output coefficient `2*i` equals
   `W[i] mod 4096`.
2. **PFB-T1.P2** — For every block `i`, output coefficient `2*i+1` equals
   `floor(W[i] / 4096)`.

Supporting lemma, not separately counted:

```text
r[2*i] + 4096*r[2*i+1] = W[i]
```

## PFB-T2 — Exact single-bit influence and block locality

1. **PFB-T2.P1** — Flipping bit `j` of the first byte toggles exactly bit `j`
   of the even coefficient.
2. **PFB-T2.P2** — Flipping low-nibble bit `j` of the second byte toggles
   exactly even-coefficient bit `8+j`.
3. **PFB-T2.P3** — Flipping high-nibble bit `j` of the second byte toggles
   exactly odd-coefficient bit `j`.
4. **PFB-T2.P4** — Flipping bit `j` of the third byte toggles exactly
   odd-coefficient bit `4+j`.
5. **PFB-T2.P5** — Arbitrarily changing one three-byte block leaves every
   other coefficient pair unchanged.

## PFB-T3 — Arbitrary differential conservation

1. **PFB-T3.P1** — For a selected block and two arbitrary inputs, the XOR of
   the packed output pairs equals the XOR of the corresponding 24-bit input
   words.
2. **PFB-T3.P2** — For every block, the three input bytes differ if and only
   if the corresponding output coefficient pair differs.

Full-array injectivity is a supporting consequence and is not separately
counted.

## PFB-T4 — Full raw-domain inverse and bijection

The independent raw encoder is defined for `0 <= x,y < 4096` as:

```text
c0 = x mod 256
c1 = floor(x / 256) + 16*(y mod 16)
c2 = floor(y / 16)
```

It shall not call production `mlk_poly_tobytes`.

1. **PFB-T4.P1** — For every arbitrary 384-byte array, independently
   raw-encoding the real decoded polynomial reproduces all original bytes.
2. **PFB-T4.P2** — For every raw polynomial with coefficients in `[0,4096)`,
   real decoding of its independent raw encoding reproduces all coefficients.

## Count

* T1: 2
* T2: 5
* T3: 2
* T4: 2
* Total: 11
