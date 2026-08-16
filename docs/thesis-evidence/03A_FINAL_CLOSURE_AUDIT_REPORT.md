# 03A Final GitHub-Compatible Closure Audit Report

**Revision:** `RC4` — retains the RC3 live-gate and hygiene repairs and closes exact-changeset parser defect `GCR-17`.

**Audit date:** 16 August 2026
**Required repository base:** `4785f933dcf5c1fc5a1d6dae5af2211f98e66f1c`
**Source closure package:** `FORMALLY_AUDITED_DEEP_PROPERTY_EVIDENCE_FINAL_CLOSURE.zip`
**Source package SHA-256:** `c7398fe30c727edc3eacbd5db4b3f4dcddea19ebb786249311f27eb6376de851`

## Final package verdict

**PASS — final pre-push package approved for installation on the exact reconciled base, subject to the two repository-bound gates that can only run after installation: (1) the live current-ledger/path/hash validator and (2) the live GitHub Markdown REST API smoke gate.**

This approval concerns the evidence-documentation integration layer. It does not mean that the Markdown prose is itself a theorem-prover output, and it is not a rerun of all original CBMC campaigns. Formal support for `SUPPORTED` records remains grounded in the retained CBMC evidence under the pinned production source, harness, assumptions and analysis configuration.

## A. Preservation of the accepted scientific corpus — PASS

The source package's accepted classification inventory is retained without reclassification:

- substantive property/control records: **257**;
- supported property/obligation subset: **220**;
  - `SUPPORTED`: **215**;
  - `SUPPORTED_WITH_PARTIAL_PRESERVATION`: **5**;
- `RESOURCE_LIMITED_INCONCLUSIVE`: **16**;
- `SUPPORTING_CONTROL`: **7**;
- `SUPPORTED_DIAGNOSTIC`: **6**;
- `ASSUMED_FROM_DOCUMENTED_GUARANTEE`: **4**;
- `MEANINGFUL_NEGATIVE`: **2**;
- `SUPPORTED_BY_CONSTRUCTION`: **1**;
- `ABSTRACTION_LIMITED_INCONCLUSIVE`: **1**.

The 19 negative/inconclusive records remain non-supported, and the five Case-1 partial-preservation supported records remain explicitly qualified.

## B. Mathematical preservation across the GitHub repair — PASS

The prior package contained **210** blocked named-operator macros. Every occurrence was changed only from `\operatorname{Name}` to `\mathop{\text{Name}}`.

Independent before/after comparison established:

- record IDs before/after: **257/257 identical**;
- formal statements recovered before/after: **257/257**;
- reverse-normalised exact formal-statement matches: **257/257**;
- display-equation sequence counts: identical in **19/19 files**;
- reverse-normalised display equations: byte-identical in **19/19 files**;
- substantive formula edits introduced by the GitHub compatibility repair: **0**.

`03A_PRE_GITHUB_MATH_PRESERVATION_MANIFEST.csv` records SHA-256 identities for every record's accepted pre-fix statement, GitHub-safe statement and reverse-normalised statement.

## C. GitHub mathematical-rendering compatibility — PASS offline

Static GitHub-math validation reported:

```text
STATIC files=19 math_expressions=414 github_safe_named_operators=210
STATIC GITHUB-MATH COMPATIBILITY: PASS
```

The active 19 rendered files contain:

- `\operatorname{...}` in mathematical expressions: **0**;
- custom macro-definition/extension commands in mathematical expressions: **0**;
- GitHub-safe named-operator forms: **210**;
- unbalanced math braces: **0**;
- unbalanced math environments: **0**.

Pandoc 3.1.11.1 independently parsed all 19 rendered files to HTML/MathML with **0 warning lines**.

A live GitHub Markdown REST API smoke validator is bundled and must be run before the final push. GitHub documents this endpoint as Markdown/GFM-to-HTML rendering; it is not treated as a browser-side MathJax negative-control oracle. Macro-policy compatibility is established independently by the fail-closed static gate. The package-construction environment has no outbound access to `api.github.com`, so the network smoke gate is not falsely reported as complete here.

## D. Current repository/publication-state reconciliation — PASS by supplied base evidence

The required installation base is the post-reconciliation `main` commit `4785f933dcf5c1fc5a1d6dae5af2211f98e66f1c`, for which the user-provided terminal validation established:

- `v1.1.0` is the published expanded thesis-evidence release;
- 18/18 investigation locators resolved/hash-matched;
- 257/257 substantive records resolved/hash-matched;
- 573/573 representative artefacts resolved/hash-matched;
- repository strict validator PASS;
- Case-4 `PR-C04-013` corrected to $`1073741824\;(=2^{30})`$;
- clean working tree and local `main == origin/main`;
- 03A absent before this new installation.

The final package no longer represents `PENDING` / `UNRESOLVED_UNTIL_FINALIZER` as current record state. These values remain only under explicit **Historical RC2** labels, while every record exposes current `RESOLVED_HASH_MATCH` status and points to its current authoritative ledger row.

## E. Latest supplied thesis reconciliation — PASS

The active reconciliation target is the currently supplied `THESIS V2 15back (THESIS READY).docx`, SHA-256 `53a7ca70894694853e5f0d24f45b07bcbcd7a7229eb8f078aead71831bc45884`.

The current thesis explicitly states that the 14 unassisted cases contain 210 supported records and the four skill-available investigations add 10, giving the same **220 supported-record subset of the 257-record ledger** used by this catalogue. Appendix 2 continues to preserve the Case-1 meaningful negatives/partial preservation, the Case-13 abstraction-limited candidate and the 16 Case-14 resource-limited candidates.

The prior package's external thesis-only typo observation is no longer current: the supplied thesis now displays Case-1 item 4 as **“Modulo-(q) refinement”**.

## F. Case-4 correction — PASS and no longer an install-time patch

The rendered `PR-C04-013` formal statement remains:

```text
c_prod = 1073741824 = 2^30
```

The former correction patch is retained only under `03A_AUDIT_HISTORY/`. The active installation path does not apply it. The installed validator instead fails closed unless both live ledger twins already contain the corrected relation.

## G. Previous work preservation — PASS

The earlier closure was not discarded. Its complete exact source archive is preserved byte-for-byte under `03A_AUDIT_HISTORY/PRE_GITHUB_RENDER_FIX_EXACT_SOURCE_CLOSURE.zip` at SHA-256 `c7398fe30c727edc3eacbd5db4b3f4dcddea19ebb786249311f27eb6376de851`. Readable historical copies are retained beside it but normalised to LF/no trailing whitespace solely for Git staging hygiene.

The new active reports explicitly supersede those artefacts for current installation decisions while retaining them as provenance.

## H. Repository integration design — PASS

`03A_INSTALL_FINAL.py` is deliberately non-publishing. It:

1. requires the exact clean base commit;
2. verifies the current 18/257/573 resolved state and scientific class inventory;
3. verifies the Case-4 correction is already present;
4. copies the final 03A layer;
5. adds 03A navigation to root `README.md`, `THESIS_EVIDENCE_INDEX.md` and `docs/thesis-evidence/README.md`;
6. regenerates global evidence checksums;
7. runs the final 03A validator, GitHub-render validator and existing strict evidence validator;
8. runs `git diff --check`;
9. performs **no commit, push, tag or release operation**.

This leaves the final commit/push as an explicit, inspectable user action after all gates pass.

## I. Fresh re-audit Git staging hygiene — PASS

A second independent re-audit deliberately staged the preserved historical files in a temporary Git repository. It exposed two integration defects in the first GitHub-renderable package: four trailing-space lines in the historical closure report and CRLF line endings in the historical Case-4 patch would cause `git diff --cached --check` to fail.

The repaired package now:

- preserves the **exact original closure ZIP** byte-for-byte inside audit history;
- keeps readable historical copies normalised to LF and without trailing spaces/tabs;
- validates **all installable 03A text**, including audit history, for CRLF/trailing whitespace;
- no longer exempts audit history from the installer hygiene scan.

A fresh staged-diff simulation passes after this repair.

The final-approval recheck additionally found and closed two validator-robustness defects: the GitHub/rendered-catalogue validators formerly depended on the process working directory, and the redundant explicit text-hygiene loops did not independently descend into readable audit-history copies. Validators now resolve paths from their own file locations, and both package/install hygiene scans cover every text-like file under a top-level `03A_*` installation path. These repairs change no scientific record or formal statement.

The real RC2 installation then exposed `GCR-15`: GitHub's REST Markdown endpoint did not surface the browser-side MathJax rejection for the known-bad `\operatorname` sensitivity control. RC3 corrects the model rather than weakening the mathematical gate: the REST endpoint is now only a live Markdown-to-HTML smoke test, while the static macro-policy gate remains authoritative for the known GitHub macro restriction.

The real RC3 installation then exposed `GCR-17` in the final exact-changeset gate: `stdout.strip()` removed the leading porcelain-v1 status-column blank from ` M README.md`, so the parser reported `EADME.md`. RC4 preserves the fixed-width Git status columns using raw capture, centralises the parser, and regression-tests the triggering status forms. RC3 stopped before any commit or push, and this repair changes no scientific or mathematical content.

## Final scientific boundary

The final package may be described as a **formally audited evidence catalogue containing formally supported bounded properties/obligations**, not as a machine-checked theorem about the Markdown document itself. The 220 supported records inherit their formal force from retained CBMC evidence. Negative/inconclusive findings, controls, diagnostics, assumptions and preservation limitations remain distinct.

## Closure statement

No unresolved package-internal defect remains in record coverage, classification preservation, formal-statement preservation, GitHub-safe static mathematical syntax, MathML parsing, Case-4 correction treatment, current/historical path-state separation, or thesis-projection counts.

The only remaining gates are intentionally environment-bound and are bundled to fail closed: live repository path/hash verification and live GitHub Markdown REST API smoke validation before the final push.

## Offline package self-audit — PASS

The finalized active package was independently checked by `03A_VALIDATE_PACKAGE_SELF.py` after checksum regeneration. The offline result was:

```text
checks=37 pass=37 fail=0
FINAL 03A OFFLINE PACKAGE SELF-AUDIT: PASS
```

The self-audit verifies the 257-record manifest and rendered union, exact result-class inventory, 220 supported projection, 19 negative/inconclusive records, 257 historical/current path-state pairs, 257 formula-preservation hashes, zero blocked `\operatorname` forms, 210 GitHub-safe named operators, balanced mathematics, current-state wording, Case-4 correction, Pandoc/MathML parsing and the active 03A checksum manifest. The transcript is retained as `03A_FINAL_OFFLINE_PACKAGE_VALIDATION_TRANSCRIPT.txt`.
