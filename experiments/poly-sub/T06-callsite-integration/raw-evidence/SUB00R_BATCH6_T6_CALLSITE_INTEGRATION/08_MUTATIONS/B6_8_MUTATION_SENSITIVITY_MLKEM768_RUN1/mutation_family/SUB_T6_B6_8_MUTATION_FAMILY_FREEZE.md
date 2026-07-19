# SUB-T6 B6.8 mutation family freeze

Status: FROZEN before mutant GOTO construction and CBMC execution.

Mandatory mutants:
- M6.1: replace the production subtraction operator with addition.
- M6.2: remove only mlk_poly_reduce from a mutation copy of the frozen
  T6.6 harness.
- M6.3: insert one write to the source operand sb after the actual
  subtraction assignment.
- M6.4: alter only the mlk_poly_sub loop bound to skip coefficient 255.

Registered detectors:
- M6.1 -> T6.3
- M6.2 -> T6.6
- M6.3 -> T6.4
- M6.4 -> T6.3 and T6.5

The frozen production tree and frozen positive harness family are not edited.
