# Release and reproducibility manifest

- Public repository: https://github.com/Girish2052003/girish-nallan-chakravathy-thesis-2026-mlkem-cbmc-verification-case-study-evidences
- Repository visibility: PUBLIC (verified before package construction)
- Evidence documentation package date: 2026-08-06
- Versioned thesis release tag: `UNFROZEN`
- Intended tag: `v1.0.0`
- Exact tagged commit: recorded after tag creation in GitHub release metadata and `RELEASE_FREEZE_RECORD_v1.0.0.json`
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
