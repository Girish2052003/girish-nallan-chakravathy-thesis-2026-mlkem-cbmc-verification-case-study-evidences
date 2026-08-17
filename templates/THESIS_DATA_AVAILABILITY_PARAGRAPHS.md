# Data availability

The accompanying research repository is public:

https://github.com/Girish2052003/girish-nallan-chakravathy-thesis-2026-mlkem-cbmc-verification-case-study-evidences

## Frozen V5 baseline — `v1.0.0`

Release/tag `v1.0.0` identifies the validated V5 evidence spine. Release/tag `v1.1.0` identifies the expanded evidence corpus containing the RQ2 architectural-development evidence. Under the maintained publication policy, both release tags resolve to the same current published repository commit. The V5 evidence layer covers the fourteen unassisted V5 cases and four skill-available investigations. Its validated scope includes 18/18 investigation roots and summaries, 257/257 substantive property/control mappings and 573/573 representative artefact mappings. Case 1 remains explicitly `PARTIAL` where subordinate historical outputs were not retained; the release does not recreate missing evidence.

## RQ2 architectural-development extension — `v1.1.0`

The refined RQ2 makes the retained V1–V4 deterministic-orchestration and architectural-transfer programme a principal evidence stream. Files `20`–`30` index that evidence without changing the scientific V5 ledgers in files `01`–`19`.


For final release-state verification, run:

```bash
python3 tools/finalize_rq2_architectural_evidence.py --repo-root .
python3 tools/validate_evidence_spine.py --repo-root . --strict
```


## Safe wording during installation

> The V5 case-study evidence is publicly identified by release `v1.0.0`, while the expanded corpus containing the architectural-development evidence is identified by release `v1.1.0`. Both maintained release tags resolve to the same current published repository commit.

## Safe wording after combined strict validation but before the new tag

> The complete retained evidence indexed for the V1–V4 architectural-development analysis and the V5 case study is publicly available in the accompanying research repository. An expanded versioned thesis evidence release remains pending.

## Final thesis wording

> **Data availability.** The complete retained evidence corpus supporting the architectural-development analysis, the fourteen-case V5 study and the secondary V5 helper-skill probe is publicly available in release `v1.1.0` of the versioned research repository accompanying this thesis (Nallan Chakravathy, 2026). The repository evidence index maps architecture-level and case-level claims to their retained public artefacts and integrity records.

## Interpretation boundary

“Complete retained evidence corpus” means all evidence retained and published for the reported study. It does not imply recreation of missing historical artefacts, complete correctness or security of ML-KEM, exhaustive worldwide prior-art coverage, global novelty, causal superiority of one architecture, preservation of a numerical percentage of model capability, or individual-skill causal effectiveness.


## Release-maintenance note

Historical validation and execution records may retain commit identities captured when those records were generated; such values are historical provenance fields rather than current release-tag targets.
