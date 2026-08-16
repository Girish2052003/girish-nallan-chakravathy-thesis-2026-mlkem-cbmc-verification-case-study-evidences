# Installation note for the complete rendered evidence catalogue suite

Place the packaged contents under `docs/thesis-evidence/` exactly as supplied. The main entry point is:

- `03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md`

Its complete row-level content is split into 18 linked files under:

- `03A_RENDERED_CATALOGUE_CASES/`

Also retain:

- `03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE_MANIFEST.csv`
- `03A_CATALOGUE_AUDIT_AND_RECONCILIATION_REPORT.md`
- `03A_DEEP_CATALOGUE_VALIDATION_REPORT.md`
- `03A_CATALOGUE_SHA256SUMS.txt`
- `PR-C04-013_LEDGER_CORRECTION.patch`
- `03A_VALIDATE_RENDERED_CATALOGUE.py`
- `03A_FINAL_CLOSURE_AUDIT_REPORT.md`
- `03A_FINAL_CLOSURE_DEFECT_AND_REPAIR_LOG.md`
- `03A_FINAL_42_GATE_VALIDATION_TRANSCRIPT.txt`
- `03A_RC2_STANDALONE_VERIFICATION_TRANSCRIPT.txt`
- `03A_FINAL_PANDOC_MATH_RENDERING_STATUS.txt`
- `03A_LATEST_THESIS_RECONCILIATION_SUMMARY.txt`

Before committing, apply the `PR-C04-013` correction to both `02_COMPLETE_PROPERTY_LEDGER.csv` and `02_COMPLETE_PROPERTY_LEDGER.md`, then rerun the repository strict evidence-spine validator. Add the master `03A` entry to `THESIS_EVIDENCE_INDEX.md` immediately after `03_FORMAL_CLAIM_CATALOGUE.md`.

Do not replace the authoritative ledgers (`02`, `04`, `06`, `07`, `09`, `16`, `17`) with this catalogue. `03A` is the exhaustive rendered explanation and reconciliation layer over those records. The thesis appendices remain the compact thesis projection.

## Required closure sequence

1. Apply `PR-C04-013_LEDGER_CORRECTION.patch` to the ledger CSV/Markdown twins. The current public `main` still carries the stale Case-4 `2^25` transcription; the retained Case-4 evidence supports `1073741824 = 2^30`.
2. Copy the `03A` master, manifest, case directory, validator and audit reports into `docs/thesis-evidence/`.
3. Run `python3 docs/thesis-evidence/03A_VALIDATE_RENDERED_CATALOGUE.py` from the repository root.
4. Run the repository's existing strict evidence-spine validator.
5. Add the master `03A` entry to `THESIS_EVIDENCE_INDEX.md` immediately after `03_FORMAL_CLAIM_CATALOGUE.md`.
6. Review `git diff --check`, confirm a clean expected diff, commit, and then freeze/update any release only under the repository's existing release policy.

The row-level RC2 values `PENDING`, `UNRESOLVED_UNTIL_FINALIZER`, and blank `public_evidence_sha256` fields are historical path-validation metadata. They must not be silently replaced with guessed current paths or hashes. The master catalogue explains the distinction between those fields and the repository's published release status.
