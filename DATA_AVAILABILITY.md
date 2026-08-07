# Data availability

The accompanying research repository is public:

https://github.com/Girish2052003/girish-nallan-chakravathy-thesis-2026-mlkem-cbmc-verification-case-study-evidences

This package establishes archive-level traceability for the complete **retained** case-study corpus: all 18 investigation roots and principal summaries were found in the ten audited source archives, and all 257 substantive property records were resolved to an exact archive entry and SHA-256. The qualifier **retained** is necessary because the recovered Case 1 package has explicitly documented subordinate preservation gaps.

## Current repository-validation status

Public visibility is confirmed. Exact path and byte-identity matching between every archive-mapped record and the current public Git checkout must still be completed by running:

```bash
python3 tools/finalize_evidence_spine.py --repo-root .
python3 tools/validate_evidence_spine.py --repo-root . --strict
```

Until the strict audit passes, the thesis should state:

> The accompanying research repository is publicly accessible. Final case-to-path validation and the versioned thesis evidence release will be completed before submission.

After strict path validation but before release freeze:

> The complete retained case-study evidence corpus is publicly accessible in the accompanying research repository. A versioned thesis evidence release will be frozen before submission.

## Final thesis wording after release freeze

> **Data availability.** The complete retained case-study evidence corpus—including the registered prompts, transcripts, generated verification artefacts, source and build manifests, executed commands, raw CBMC outputs, counterexample records, coverage and mutation evidence, checksums and case-level summaries—is publicly available in the versioned research repository accompanying this thesis (Nallan Chakravathy, 2026). The results reported in Chapters 4–6 refer to release `v1.0.0`; the exact tagged commit and release-archive checksum are recorded in the GitHub release metadata and the accompanying release-freeze record.

## Validation scope

Before a frozen-release claim is used in the thesis, strict validation must hash-match all 18 investigation roots and principal summaries, all 257 substantive property/control evidence paths and all 573 representative harness, command/runner, raw-result, manifest/hash and coverage/mutation/control paths.
