# CBMC `mlk_poly_frommsg` Verification Finding — Professor Review Package

## summary

A frozen direct-body CBMC campaign verified the selected binary-embedding property of the production `mlk_poly_frommsg` implementation using the real function body, exact unwind calibration, repeated proof runs, reachability witnesses, and mutation controls. A separate minimal experiment isolated a CBMC robustness/type-handling defect: canonical `__CPROVER_cover` usage succeeds, whereas manually redeclaring that built-in with an incompatible `_Bool` or `int` parameter and requesting `--cover cover` causes an internal `not_exprt` Boolean-expression invariant rather than a controlled diagnostic. The defect pattern was reproduced in the tested official CBMC 6.9.0 and 6.10.0 Docker images; no solver defect, ML-KEM vulnerability, general canonical-coverage failure, unsound proof success, or major-severity claim is made.

## Recommended review order

1. The original professor-email file is not included in this publication derivative.
2. `01_EXECUTIVE_REVIEW/02_VERIFICATION_NOTE.md`
3. `01_EXECUTIVE_REVIEW/03_FINAL_SCIENTIFIC_CLASSIFICATION.txt`
4. `01_EXECUTIVE_REVIEW/04_EVIDENCE_INDEX.md`
5. `02_MINIMAL_REPRODUCER/`
6. Frozen evidence packets under `03_FROZEN_CORE_EVIDENCE/`
7. Integrity manifest under `07_INTEGRITY/`

## Important evidence boundary

This package contains complete, independently hash-bound evidence for the direct-body T1 control and the official CBMC 6.9.0/6.10.0 release reproductions. The uploaded evidence does not contain a completed successful run against the pinned `develop` build; therefore this package does not state whether that pinned `develop` revision is affected or fixed.

---

## Publication-Derivative Record

This directory is a reconciled publication derivative of
`CBMC_FROMMSG_PROFESSOR_VERIFICATION_PACKAGE_FINAL_20260727`.

The source directory supplied for publication contained 26 files. It did not
contain the professor-email file referenced by the original package inventory,
and that correspondence has not been reconstructed or published. The retained
verification note is byte-identical to the originally recorded note and is
published under the shortened path
`01_EXECUTIVE_REVIEW/02_VERIFICATION_NOTE.md`.

The file inventory, package statistics, and SHA-256 manifest were regenerated
for this 26-file publication tree at `2026-08-01T06:15:05Z`. The frozen TAR.GZ
archives, raw logs, minimal reproducers, reproduction scripts, scientific
classification, evidence index, issue draft, and known core hashes were not
rewritten during publication reconciliation.

