# SUB-T6 B6.2 Arithmetic and Assumption Audit

Status: `FROZEN`

```text
0 <= v[i] <= 3328
-26631 <= sb[i] <= 26631

minimum = 0 - 26631 = -26631
maximum = 3328 - (-26631) = 29959

[-26631, 29959]
is contained in
[-32768, 32767]
```

Representability is derived from the exact upstream contracts. It is not an
independent assumption.
