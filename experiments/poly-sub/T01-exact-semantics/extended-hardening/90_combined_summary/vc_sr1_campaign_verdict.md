# VC-SR1 combined authoritative verdict

## Campaign result

- Campaign status: `COMPLETE`
- Combined classification: `PASS_EXPECTED`
- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Configuration: `ML-KEM-768`
- Positive-control properties: `89`
- Reachable loops: `10`
- Implementation mutant killed: `yes`
- Assertion mutant killed: `yes`

## Verified claim

For all modelled polynomial inputs satisfying the recorded signed-int16
representability assumptions, execution of the frozen portable C bodies of
`mlk_poly_sub` followed by `mlk_poly_reduce` produces coefficients in
`[0,3329)` equal to the independent canonical modular-difference oracle,
while preserving the recorded frame conditions.

## Evidence chain

| Case | Result | Role |
|---|---|---|
| AC-SR1 | PASS | Establishes that the production decryption callsite satisfies signed-int16 representability. |
| OR-SR1 | PASS | Validates the independent canonical modulo oracle for all signed 16-bit differences. |
| VC-SR1 | PASS_EXPECTED | Checks the real portable C subtraction and reduction bodies. |
| M4 | FAIL_EXPECTED_MUTANT_KILLED | Shows that omitting reduction of coefficient 255 is detected. |
| M5 | FAIL_EXPECTED_MUTANT_KILLED | Shows that a deliberately false canonical assertion is detected. |

## Scope limitation

The result applies only to the frozen finite CBMC model under the recorded
assumptions, ML-KEM-768 configuration, selected C machine model, verification
options and complete recorded unwind bounds. It is not an unrestricted
universal theorem and is not an end-to-end proof of all ML-KEM.
