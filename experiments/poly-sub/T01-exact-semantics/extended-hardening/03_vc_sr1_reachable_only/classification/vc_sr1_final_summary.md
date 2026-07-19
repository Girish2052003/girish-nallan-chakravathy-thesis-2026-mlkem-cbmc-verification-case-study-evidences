# VC-SR1 final positive-control result

## Authoritative result

- Classification: `PASS_EXPECTED`
- Claim status: `PROVED_WITHIN_FROZEN_FINITE_CBMC_MODEL`
- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Reachable loops: `10`
- Frozen properties: `89`
- Returned successful properties: `89`
- Non-successful properties: `0`
- CBMC exit: `0`
- stderr bytes: `0`
- Elapsed wall-clock time: `mm:ss or m:ss): 27:43.97`
- Maximum resident set size: `1781288 KB`

## Verified claim

For all modelled polynomial inputs satisfying the recorded signed-representability assumptions, execution of the frozen portable C bodies of `mlk_poly_sub` followed by `mlk_poly_reduce` produces coefficients in `[0,3329)` equal to the independent canonical modular-difference oracle while preserving the recorded frame conditions.

## Scope limitation

The result applies only to the frozen finite CBMC model under the recorded assumptions, ML-KEM-768 configuration, selected machine model, verification options, and complete recorded loop bounds. It is not an unrestricted universal theorem.

## Classifier correction

Classifier v1 was preserved as a false negative because it incorrectly required separately returned unwind-property records for every source loop. Classifier v2 used the frozen command, exact 89-property equality, all-success statuses, zero exits, empty stderr, and CBMC's verification-success message.
