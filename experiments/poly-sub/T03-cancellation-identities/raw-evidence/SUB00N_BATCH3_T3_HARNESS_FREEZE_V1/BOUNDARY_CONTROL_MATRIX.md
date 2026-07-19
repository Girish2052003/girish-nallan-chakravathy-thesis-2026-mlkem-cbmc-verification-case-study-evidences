# SUB00N T3 Boundary-Control Matrix

| Control | Constructed arithmetic | Expected classification |
|---|---:|---|
| T3A valid lower | A-B = INT16_MIN | verification success |
| T3A valid upper | A-B = INT16_MAX | verification success |
| T3A invalid lower | A-B = INT16_MIN-1 | expected failure |
| T3A invalid upper | A-B = INT16_MAX+1 | expected failure |
| T3B valid lower | A+B = INT16_MIN | verification success |
| T3B valid upper | A+B = INT16_MAX | verification success |
| T3B invalid lower | A+B = INT16_MIN-1 | expected failure |
| T3B invalid upper | A+B = INT16_MAX+1 | expected failure |
| T3C recovery sums | 0, q-1, q, 2q-2 | verification success |

Negative controls are outside the theorem domain. They must not be
reported as failed positive theorems.
