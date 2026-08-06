# SUB-00H Independent Evidence Review

## Verdict

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**SUB-T1 is accepted as a successful body-level CBMC proof for the frozen ML-KEM-768 model and recorded assumptions.**

This verdict establishes the theorem under the frozen model. It does not, by itself, establish a worldwide novelty claim.

## Archive integrity

- Retained archive SHA-256: `054ca49dc569642c4e1395b9f0027dca01da440a6b8653885a1d448ba0ca9a96`
- Retained sidecar SHA-256: `054ca49dc569642c4e1395b9f0027dca01da440a6b8653885a1d448ba0ca9a96`
- Sidecar match: `PASS`
- Archive members: `26`
- Unsafe paths, links, or device entries: `0`
- Result-manifest entries: `23`
- Result-manifest verification: `PASS`

## Frozen inputs

- GOTO model SHA-256: `e9bef62631fbad4711d3eebf1ff8c48d5c2ea29d4dc4b4e9ef588ff6805260bb`
- Frozen SUB-T1 harness SHA-256: `42c09c2f004d567d8b886058bd2304d960a219d36f0f6605b015966db3bc5682`
- Final GOTO validation exit code: `0`
- CBMC version: `6.9.0`
- Raw CBMC exit code: `0`
- stderr size: `0 bytes`

## CBMC result

- JSON parse: `PASS`
- CProver status: `success`
- `VERIFICATION SUCCESSFUL` message present: `YES`
- SAT result: `UNSATISFIABLE`
- Total result properties: `361`
- Successful: `361`
- Failed: `0`
- Other: `0`
- Property inventory/result identifiers identical and in the same order: `YES`

## Theorem-relevant result subset

- Properties attached to the confirmed reachable SUB-T1 call chain: `89`
- Successful: `89`
- Explicit theorem/model/frame assertions: `20`
- Array-bounds checks: `21`
- Overflow/conversion checks: `24`
- Pointer checks: `24`

All twelve harness theorem/frame assertions and all eight machine-model assertions returned `SUCCESS`.

The remaining `272` reported properties belong to other functions retained in the full `poly.c` GOTO model. They must not be presented as additional SUB-T1 evidence.

## Proven statement

For distinct polynomial objects with 256 signed 16-bit coefficients, under the recorded 64-bit x86 machine model and the assumption that each direct coefficient difference is representable as `int16_t`, the retained production path `mlk_poly_sub` followed by `mlk_poly_reduce` returns, coefficient by coefficient, the canonical representative in `[0, 3329)` equal to the independent oracle `(A[i] - B[i] + 10 * 3329) mod 3329`.

The checked frame assertions also establish that the separate second input and the saved source objects are unchanged.

## Resource record

- Wall time: `18:37.60`
- User CPU time: `1113.93 seconds`
- Maximum resident set: `1,782,352 kB`
- Swap activity: `0`
- Timed-command exit status: `0`

## Runner provenance correction

- Distributed runner SHA-256: `5d660a68a900334771807d05ff9d3b88475b2859f296be2d59380ae4f353e2be`
- Executed runner SHA-256: `746066213716d91b9753bcdf5bebc25aec3461ed4dd5a60bfe0d757504eeaabf`

The complete textual difference is:

```diff
--- distributed
+++ executed
@@ -1,7 +1,7 @@
 #!/usr/bin/env bash
 set -euo pipefail
 
-BASE="/home/girish/THESIS-2026/mlkem_poly_sub_cleanroom/SUB00A_d9613cf60de3"
+BASE="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
 PREFLIGHT="${BASE}/SUB00G_R2_T1_PRAGMA_SCOPED_PREFLIGHT_MLKEM768"
 PREFLIGHT_PACKAGE="${BASE}/SUB00G_R2_T1_PRAGMA_SCOPED_PREFLIGHT_MLKEM768.tar.gz"
 FREEZE="${BASE}/sub00f_mode_a_execution_freeze_v1"
```

The only change corrects the campaign directory spelling from `mlkem_poly_sub_cleanroom` to `mlk_poly_sub_cleanroom`. The executed runner still verified the accepted preflight package, frozen model, frozen harness, property inventory, and final GOTO validation before invoking the recorded CBMC command. This path correction must be disclosed in the provenance record; it does not alter the theorem, model, solver flags, or result.

## Novelty boundary

Established now:

- The artefact is independently authored.
- It is distinct from the frozen repository's dedicated `poly_sub` harness, which checks the existing subtraction contract and does not compose subtraction with canonical reduction or an independent oracle.
- The frozen SUB-T1 theorem passed CBMC under its recorded assumptions.

Not established by this result:

- new mathematics;
- first formal verification of Kyber/ML-KEM subtraction;
- worldwide absence of an equivalent proof;
- a world-first CBMC claim.

Defensible current wording:

> An independently authored, body-level CBMC semantic-composition proof for the frozen mlkem-native ML-KEM-768 implementation, establishing that production polynomial subtraction followed by canonical reduction agrees coefficientwise with an independent modular oracle over all representable signed 16-bit differences.

A public-code and literature equivalence audit, plus non-vacuity and mutation experiments, should be completed before presenting the artefact as a novel thesis contribution.
