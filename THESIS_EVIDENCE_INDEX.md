# Thesis evidence index

This index connects the thesis's fourteen unassisted ML-KEM/CBMC cases and four skill-available investigations to the retained public evidence.

Start with:

1. `docs/thesis-evidence/01_CASE_EVIDENCE_LOCATOR.md`
2. `docs/thesis-evidence/02_COMPLETE_PROPERTY_LEDGER.md`
3. `docs/thesis-evidence/03_FORMAL_CLAIM_CATALOGUE.md`
4. `docs/thesis-evidence/04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.md`
5. `docs/thesis-evidence/06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.md`
6. `docs/thesis-evidence/09_MASTER_PROVENANCE_MATRIX.md`
7. `docs/thesis-evidence/12_ARCHIVE_EVIDENCE_PATH_AND_HASH_MAP.md`
8. `docs/thesis-evidence/15_THESIS_SURGERY_AND_CONSISTENCY_QUEUE.md`

The raw evidence directories are not renamed or reorganised by this package. Exact live paths are generated from the existing repository tree by `tools/finalize_evidence_spine.py`.

## Evidence authority

When sources conflict, use this order:

1. source/build identity and manifests;
2. exact generated artefact;
3. exact executed command and raw formal-tool output;
4. reachability/non-vacuity and mutation evidence;
5. contemporaneous transcript or run record;
6. later summary or interpretation.

A checksum establishes stored-file identity, not scientific validity. A CBMC success result supports only the selected encoded property under the recorded model.

## Additional strict evidence gates

The evidence index is completed by:

- `docs/thesis-evidence/16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv`;
- `docs/thesis-evidence/17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv`;
- `docs/thesis-evidence/18_CONCERN_TO_EVIDENCE_RESOLUTION_AND_APPROVAL_SCOPE.md`; and
- `docs/thesis-evidence/19_PUBLIC_EVIDENCE_AVAILABILITY_CLAIM_POLICY.md`.

A release claim is permitted only after the strict validator resolves and hash-matches all indexed evidence in the full Git/LFS checkout.
