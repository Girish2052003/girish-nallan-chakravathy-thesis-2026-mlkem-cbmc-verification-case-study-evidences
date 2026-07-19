# Evidence matrix

| Evidence case | Classification | Interpretation |
|---|---|---|
| AC-SR1 | PASS | Production callsite satisfies the signed-representability precondition. |
| OR-SR1 | PASS | Independent modulo oracle is mathematically equivalent over the signed 16-bit domain. |
| VC-SR1 | PASS_EXPECTED | All 89 positive-control properties succeeded in the frozen finite model. |
| M4 | FAIL_EXPECTED_MUTANT_KILLED | Skipping reduction of coefficient 255 was detected by the unchanged oracle. |
| M5 | FAIL_EXPECTED_MUTANT_KILLED | Shifting the expected canonical value by one was detected while non-target properties remained successful. |

The combined outcome supports the scoped functional-correctness claim and
provides implementation- and assertion-level non-vacuity evidence.
