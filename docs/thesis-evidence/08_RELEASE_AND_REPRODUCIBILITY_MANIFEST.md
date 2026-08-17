# Release and reproducibility manifest

- Public repository: https://github.com/Girish2052003/girish-nallan-chakravathy-thesis-2026-mlkem-cbmc-verification-case-study-evidences
- Repository visibility: PUBLIC (verified before package construction)
- Evidence documentation package date: 2026-08-06
- Frozen V5 release tag: `v1.0.0`
- Maintained release targets: `v1.0.0` and `v1.1.0` resolve to the same shared maintained release snapshot; later `main` commits may advance independently.
- Expanded thesis-evidence tag: `v1.1.0`
- CBMC version: `6.9.0`
- Principal source revisions: `d9613cf60de3132d32475c102d8c2781d84feb34` and `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Principal parameter set: ML-KEM-768
- Case count: 14 unassisted cases
- Skill-available contrasts: 4
- Substantive property records: 257
- Archive mapping: 257/257 property records resolved to exact audited archive entries and entry SHA-256 values
- Evidence package status: 13 complete unassisted packages; Case 1 partial; four skill-available packages technically accepted

## Reproducibility boundary

Reproducibility concerns preservation of source/build identity, prompts, transcripts, harnesses, commands, raw formal-tool outputs, controls, manifests and scientific classifications. It does not promise deterministic regeneration of the agent's reasoning or wording.

## Why the tagged commit is not self-embedded

A Git commit cannot contain its own final commit identifier because changing a tracked file changes the commit. The tag-to-commit binding is therefore recorded in Git/GitHub release metadata and in a release asset generated **after** tagging. This avoids a false or one-commit-behind identifier inside the tagged tree.

## Release freeze procedure

1. Install this overlay without moving or rewriting raw evidence.
2. Run `python3 tools/finalize_evidence_spine.py --repo-root .`.
3. Review `13_PUBLIC_REPOSITORY_PATH_AUDIT.md` and the property-path audit CSV.
4. Run `python3 tools/validate_evidence_spine.py --repo-root . --strict`.
5. Commit and push the validated documentation layer.
6. Create annotated tag `v1.0.0` on that commit and push it.
7. Run `python3 tools/create_release_freeze_record.py --repo-root . --tag v1.0.0` and upload the generated JSON as a GitHub release asset.
8. Download the GitHub release source archive, calculate SHA-256 and add it to the release metadata or a second release asset.

Chapters 4–6 should refer to `v1.0.0` only after the tag and release exist.

## v1.1.0 architectural-development extension

- V5 evidence baseline label: `v1.0.0`; expanded RQ2 evidence label: `v1.1.0`. Both labels resolve to the shared maintained release snapshot.
- Expanded thesis-evidence tag: `v1.1.0`.
- V5 scientific evidence: files `01`–`19`; `v1.0.0` remains the V5 baseline release label and shares the maintained release snapshot with `v1.1.0`.
- New RQ2 evidence: files `20`–`30`.
- RQ2 source archive: `reproducible-ai-assisted-cbmc-workflows1.zip`.
- RQ2 source archive SHA-256: `7e7d5f2f3f3d505983e39bcbaa5c88a493f7e9b9bf467ceca217f495a6ebe87b`.
- Selected archive-backed RQ2 records: 38.
- Repository-only host evidence units retained by reference: 2 (`mlk_poly_add`, `mlk_poly_sub`), represented by six evidence-role mappings under the repository evidence release-classification policy.
- V4 identity audit: 1,484 files in each preserved V4 state, identical relative path sets, 1,483 byte-identical files and one client-wiring difference.

### v1.1.0 publication and maintained-tag procedure

1. Install the addendum into `main` and validate the combined evidence state before maintained release-tag reconciliation.
2. Run `python3 tools/finalize_rq2_architectural_evidence.py --repo-root .`.
3. Review files 25, 27 and 29 for provenance, release-classification policy and claim-boundary consistency.
4. Run `python3 tools/validate_evidence_spine.py --repo-root . --strict`.
5. Commit and push only after `## PASS`.
6. Verify `origin/main` points to the new commit.
7. Reconcile the maintained annotated tags `v1.0.0` and `v1.1.0` to the selected validated shared release snapshot and push the updated tag references. Subsequent `main` commits do not automatically retarget those releases.
8. Run release-mode validation and create a release-freeze record if desired.

## Historical `v1.0.0` checksum-manifest disclosure

The originally published `v1.0.0` state remains retained in Git history. In that original release state,
`docs/thesis-evidence/SHA256SUMS` records SHA-256
`80e75fb90898904444c0d7c9875030ca73ff6340bd9bebd49521bfa6a348bf87`
for `docs/thesis-evidence/14_VALIDATION_REPORT.md`, whereas the
`14_VALIDATION_REPORT.md` blob actually stored in the tagged
`v1.0.0` tree has SHA-256
`af3ac2c0e23ed7e67e92297bd41074e156aeffb95858a2d7e4b99465c4f20e9f`.
Maintaining the shared `v1.0.0`/`v1.1.0` release snapshot does not alter the original commit retained in Git history or erase this disclosed historical discrepancy.
The original Git commit and the report blob stored in that historical release state remain
the authoritative historical record. RQ2 evidence identities are
controlled separately by the RQ2 provenance/path-and-hash records.


## Historical commit identities

Historical evidence and validation records are preserved as provenance records and may therefore contain commit identities that were current when those records were generated. Such values are historical record fields, not current release-tag targets.
