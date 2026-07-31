# Independent FIPS 203 `Compress_1` oracle

For canonical `x` in `0..3328`, the d=1 compression bit is:

```text
Compress_1(x) = round((2 / 3329) * x) mod 2
```

An exact integer realization is:

```text
((2*x + 1664) // 3329) mod 2
```

For `q = 3329`, this is equivalent to:

```text
0, when x is in 0..832
1, when x is in 833..2496
0, when x is in 2497..3328
```

The accompanying Python program exhaustively compares an exact rational-rounding
implementation, the integer formula, and the threshold partition for all 3329
canonical coefficients. It also checks the critical boundaries 832/833 and
2496/2497.
