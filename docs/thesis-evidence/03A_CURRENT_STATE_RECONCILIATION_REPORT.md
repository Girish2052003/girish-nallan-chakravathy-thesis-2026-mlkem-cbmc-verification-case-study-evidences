# 03A Current Repository-State Reconciliation Report

**Reconciliation date:** 16 August 2026
**Required installation base:** `4785f933dcf5c1fc5a1d6dae5af2211f98e66f1c`
**Repository branch:** `main`

## Current state supplied and validated before package construction

The repository was returned to a clean pre-03A tree, the stale `v1.1.0` publication wording was reconciled, and the resulting current `main` state was pushed and verified before this package was rebuilt.

The accepted current-state facts are:

- `v1.0.0`: preserved historical V5 baseline;
- `v1.1.0`: published expanded thesis-evidence release;
- investigation locators: **18/18 `RESOLVED_HASH_MATCH`**;
- substantive property/control records: **257/257 `RESOLVED_HASH_MATCH`**;
- representative artefact records: **573/573 `RESOLVED_HASH_MATCH`**;
- working tree at the package base: clean;
- 03A catalogue: absent from the base before installation;
- repository strict evidence-spine validation: PASS;
- Case-4 `PR-C04-013` ledger correction: already applied as $`1073741824\;(=2^{30})`$;
- tags/releases: not modified by the 03A removal or publication-state reconciliation.

## Historical RC2 path fields versus current path state

The pre-finalization RC2 source snapshot carried the following public-path fields for the 257 substantive records:

- `resolved_public_evidence_path = UNRESOLVED_UNTIL_FINALIZER`;
- blank `public_evidence_sha256`;
- `public_path_resolution_status = PENDING`;
- candidate count `0`.

These values remain useful provenance because they describe the source package before final public-path resolution. They are therefore retained in every rendered record, but the labels now begin with **Historical RC2** so they cannot be mistaken for the current repository state.

Every rendered record additionally states:

```text
Current public path resolution status: RESOLVED_HASH_MATCH
Current public path/hash authority: 02_COMPLETE_PROPERTY_LEDGER.csv row <record ID>
```

The exact current public path and SHA-256 are deliberately not duplicated into the narrative catalogue. The current authoritative ledger remains the single mutable source for those values, and the installed 03A validator verifies the current ledger path/hash state against the actual repository files.

## Scientific classifications are independent

Current repository resolution must never be confused with scientific resolution. The accepted 257-record class inventory remains:

| Result class | Records |
|---|---:|
| `SUPPORTED` | 215 |
| `SUPPORTED_WITH_PARTIAL_PRESERVATION` | 5 |
| `RESOURCE_LIMITED_INCONCLUSIVE` | 16 |
| `SUPPORTING_CONTROL` | 7 |
| `SUPPORTED_DIAGNOSTIC` | 6 |
| `ASSUMED_FROM_DOCUMENTED_GUARANTEE` | 4 |
| `MEANINGFUL_NEGATIVE` | 2 |
| `SUPPORTED_BY_CONSTRUCTION` | 1 |
| `ABSTRACTION_LIMITED_INCONCLUSIVE` | 1 |

Therefore:

- 16 Montgomery candidates remain **resource-limited and inconclusive**;
- the Case-13 two-call seed relation remains **abstraction-limited and inconclusive**;
- the two Case-1 negative findings remain **meaningful negatives**;
- the five Case-1 supported records retain **partial-preservation** qualification.

None of these scientific outcomes is upgraded merely because its public evidence path is now resolved/hash-matched.

## Current-facing repository documents

The package does not rewrite the already reconciled `DATA_AVAILABILITY.md` or `19_PUBLIC_EVIDENCE_AVAILABILITY_CLAIM_POLICY.md`. The installer verifies that they remain in the current published/historical state and fails if stale `v1.1.0` candidate/in-progress wording reappears.

The installer adds only the missing 03A navigation entry to:

- root `README.md`;
- `THESIS_EVIDENCE_INDEX.md`;
- `docs/thesis-evidence/README.md`.

## Case-4 correction status

The old closure package included `PR-C04-013_LEDGER_CORRECTION.patch` as an install-time prerequisite because the public ledger still contained a $`2^{25}`$ transcription. That is no longer true at the required base.

The patch itself is retained only under `03A_AUDIT_HISTORY/` for provenance. The active installation instructions do **not** apply it. Instead, the final validator fails closed unless both current ledger twins already contain the corrected $`1073741824\;(=2^{30})`$ relation.

## Verdict

**CURRENT-STATE RECONCILIATION DESIGN: PASS.**

The package cleanly separates current repository publication/path status, historical pre-finalization metadata, and scientific verification outcomes.

<!-- CURRENT-03A-PUBLICATION:START -->
## Post-publication current-state reconciliation

The final browser-rendering closure baseline for the active 03A catalogue
was established on repository `main` at commit
`f19654fbd05386769a852cc45fbd9ebb06690902`.

That closure preserved the authoritative current public-path state:
**18/18 investigation locators**, **257/257 substantive property/control
records**, and **573/573 representative artefact records** remain
resolved/hash-matched.

The scientific inventory remains **257 records**, including the qualified
**220-record supported subset**. The final genuine GitHub mathematical
surface contains **1075 expressions** (**395 display**, **680
protected-inline**, **0 plain-inline**) and passed strict MathJax 3.2.2 and
4.1.3 validation at **1075/1075**.

The earlier pre-installation and pre-publication descriptions above remain
historical provenance. Current documentation must not interpret their
required future gates as still pending.

No tag or release was created or modified by the final 03A presentation
closure.
<!-- CURRENT-03A-PUBLICATION:END -->
