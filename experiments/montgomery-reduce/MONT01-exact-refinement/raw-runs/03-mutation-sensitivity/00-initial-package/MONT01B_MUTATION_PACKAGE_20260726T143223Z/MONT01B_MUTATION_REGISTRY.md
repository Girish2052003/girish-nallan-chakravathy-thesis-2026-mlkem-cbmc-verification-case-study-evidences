# MONT-01B Targeted Mutation Registry

- Pinned commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Target: `mlk_montgomery_reduce`
- Accepted harness SHA-256:
  `ba7aa005f34f4cfdead81067223a35b968ed46eca942c350c6ae48bbaa1f341d`
- Accepted Makefile SHA-256:
  `404c11722ef402f06973916a4a07b394a456108edb78a75790fca9754d4f577e`
- Accepted GOTO SHA-256:
  `4630a866855c0806afb02f62302fa9af3b689e2594c661b4b4d15ecae61749aa`
- Bound MONT-01A-D2 capture SHA-256:
  `d4949dd1b654bd5c1c3b3e3b525a83afc20d7510958f0c6776da5825c01f2460`

## Mutations

1. **M1_QINV_PLUS_ONE**
   - Change: `QINV` to `QINV + 1`
   - Defect class: incorrect Montgomery inverse constant.
   - Required outcome: T1 exact oracle equality must fail.

2. **M2_RECONSTRUCTION_SIGN**
   - Change: `a - t*q` to `a + t*q`
   - Defect class: incorrect signed reconstruction.
   - Required outcome: T1 exact oracle equality must fail.

3. **M3_SHIFT_BY_15**
   - Change: arithmetic shift by 16 to arithmetic shift by 15.
   - Defect class: incorrect Montgomery scaling.
   - Required outcome: T1 exact oracle equality must fail.

Each mutation is applied in an independent detached worktree.
The accepted harness and Makefile are copied without modification.
The authoritative and accepted production sources are not changed.
