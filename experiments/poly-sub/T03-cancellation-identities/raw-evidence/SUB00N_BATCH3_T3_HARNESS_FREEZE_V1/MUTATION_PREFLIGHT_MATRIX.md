# SUB00N T3 Mutation-Preflight Matrix

| ID | Mutation | Primary expected detector |
|---|---|---|
| T3-M1 | replace recovery add with subtraction | T3C cancellation/oracle assertion |
| T3-M2 | omit recovery addition | T3C cancellation/oracle assertion |
| T3-M3 | use the wrong recovery operand | T3C cancellation/oracle assertion |
| T3-M4 | skip coefficient 255 | coefficient-255 cancellation mismatch |
| T3-M5 | omit final T3C reduction | canonical range or oracle assertion |
| T3-M6 | perturb independent expected value by +1 mod q | independent oracle assertion |

The actual mutant models and exact expected property identifiers must
be frozen only after the original T3 GOTO models and property
inventories have passed preflight.
