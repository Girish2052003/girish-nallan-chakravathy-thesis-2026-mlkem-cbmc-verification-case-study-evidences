# SUB-T6 B6.7 expected-failure control family

Status: FROZEN before GOTO construction.

Controls:
1. False overflow-existence claim.
2. False post-reduction noncanonical-existence claim.
3. False reduced-input incompatibility claim after actual mlk_poly_tomsg.

The third control uses the exact known-good intended-wrap adapter frozen in
B6.5. Acceptance requires exactly one registered target failure, no unrelated
failure, no unknown property and one targeted counterexample per control.
