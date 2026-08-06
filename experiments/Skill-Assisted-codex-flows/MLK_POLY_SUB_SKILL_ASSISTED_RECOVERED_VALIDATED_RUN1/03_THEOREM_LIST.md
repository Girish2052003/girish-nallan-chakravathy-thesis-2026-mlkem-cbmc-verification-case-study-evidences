# Selected theorem list

| ID | Theorem | Target calls | Core postcondition |
|---|---|---:|---|
| SA-SUB-T1 | Common-minuend difference reversal | 4 | `(a-b)-(a-c) = c-b` |
| SA-SUB-T2 | Sequential-subtrahend aggregation equivalence | 3 | `(a-b)-c = a-(b+c)` |

Both are coefficient-wise over all 256 polynomial positions and are verified against widened signed arithmetic under explicit signed-16-bit representability preconditions.
