# 03A Package Provenance and Preservation Record

**Closure date:** 16 August 2026
**Required installation base:** `4785f933dcf5c1fc5a1d6dae5af2211f98e66f1c`

## Source closure

This GitHub-renderable package was derived from the previously accepted closure archive:

```text
FORMALLY_AUDITED_DEEP_PROPERTY_EVIDENCE_FINAL_CLOSURE.zip
SHA-256: c7398fe30c727edc3eacbd5db4b3f4dcddea19ebb786249311f27eb6376de851
```

The earlier closure was not discarded. The complete exact source archive is preserved byte-for-byte as `03A_AUDIT_HISTORY/PRE_GITHUB_RENDER_FIX_EXACT_SOURCE_CLOSURE.zip` with SHA-256 `c7398fe30c727edc3eacbd5db4b3f4dcddea19ebb786249311f27eb6376de851`. Readable `PRE_GITHUB_RENDER_FIX__*` provenance copies are also retained in that directory, normalised only to LF line endings and without trailing spaces/tabs so that staging cannot fail Git whitespace checks. Exact historical bytes remain authoritative in the preserved ZIP.

## Active-versus-historical boundary

Files in `03A_AUDIT_HISTORY/` are provenance only. They record what the earlier closure package stated at that time and must not be interpreted as the current installation procedure or current repository publication/path state.

The active package is defined by the files outside `03A_AUDIT_HISTORY/`, especially:

- `03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md`;
- `03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE_MANIFEST.csv`;
- `03A_RENDERED_CATALOGUE_CASES/`;
- `03A_VALIDATE_RENDERED_CATALOGUE.py`;
- `03A_VALIDATE_GITHUB_RENDER.py`;
- `03A_VALIDATE_PACKAGE_SELF.py`;
- `03A_PRE_GITHUB_MATH_PRESERVATION_MANIFEST.csv`;
- the current closure/reconciliation/rendering reports;
- `03A_CATALOGUE_SHA256SUMS.txt`.

## Scientific preservation

The GitHub-rendering change is limited to the deterministic typesetting substitution

```text
\operatorname{Name}  ->  \mathop{\text{Name}}
```

for 210 named-operator occurrences in the 19 rendered Markdown files. The preservation manifest binds all 257 record-level formal statements before and after that transformation and records an exact reverse-normalised match.

No scientific result class is promoted or weakened by publication/path resolution. The accepted result inventory remains 215 `SUPPORTED`, 5 `SUPPORTED_WITH_PARTIAL_PRESERVATION`, 16 `RESOURCE_LIMITED_INCONCLUSIVE`, 7 `SUPPORTING_CONTROL`, 6 `SUPPORTED_DIAGNOSTIC`, 4 `ASSUMED_FROM_DOCUMENTED_GUARANTEE`, 2 `MEANINGFUL_NEGATIVE`, 1 `SUPPORTED_BY_CONSTRUCTION`, and 1 `ABSTRACTION_LIMITED_INCONCLUSIVE`.

## Case-4 repair provenance

The earlier closure carried `PR-C04-013_LEDGER_CORRECTION.patch` as an installation prerequisite. The required current base already contains the corrected production offset `1073741824 (=2^30)`, so the patch is no longer active. Its exact earlier bytes remain inside `PRE_GITHUB_RENDER_FIX_EXACT_SOURCE_CLOSURE.zip`; the readable audit-history patch copy is line-ending-normalised for Git hygiene.


## Checksum layering

`03A_CATALOGUE_SHA256SUMS.txt` covers the active/preserved 03A content except itself and `03A_FINAL_OFFLINE_PACKAGE_VALIDATION_TRANSCRIPT.txt`. The transcript is produced by validating that checksum manifest, so excluding it avoids a self-referential checksum cycle. The top-level `FINAL_GITHUB_CLOSURE_SHA256SUMS.txt` is generated afterwards and covers the transcript, installer, installation note and every other package file except the top-level checksum manifest itself.

## Validation boundary

The package self-audit, formula-preservation comparison, GitHub-static syntax gate and Pandoc/MathML gate can be completed offline. The repository-bound validator and GitHub REST rendering gate must be executed after installation on the exact required repository base. Neither documentation validation nor rendering validation is represented as an independent theorem proof; `SUPPORTED` claims derive their formal force from the retained CBMC evidence identified by the authoritative ledgers.

## Offline package self-audit — PASS

The finalized active package was independently checked by `03A_VALIDATE_PACKAGE_SELF.py` after checksum regeneration. The offline result was:

```text
checks=37 pass=37 fail=0
FINAL 03A OFFLINE PACKAGE SELF-AUDIT: PASS
```

The self-audit verifies the 257-record manifest and rendered union, exact result-class inventory, 220 supported projection, 19 negative/inconclusive records, 257 historical/current path-state pairs, 257 formula-preservation hashes, zero blocked `\operatorname` forms, 210 GitHub-safe named operators, balanced mathematics, current-state wording, Case-4 correction, Pandoc/MathML parsing and the active 03A checksum manifest. The transcript is retained as `03A_FINAL_OFFLINE_PACKAGE_VALIDATION_TRANSCRIPT.txt`.

<!-- CURRENT-03A-PUBLICATION:START -->
## Final publication provenance

The repaired GitHub-renderable 03A layer was first committed to repository
`main` as `73cba2c5bc9a51a156d0931669ee58123ce0037e`.

The pre-GitHub-render-fix closure remains preserved under
`03A_AUDIT_HISTORY/`; it is retained as historical provenance and is not the
active rendered catalogue.

Publication of the 03A layer did not rewrite the authoritative scientific
ledger or move the existing `v1.0.0` / `v1.1.0` tags or releases.
<!-- CURRENT-03A-PUBLICATION:END -->
