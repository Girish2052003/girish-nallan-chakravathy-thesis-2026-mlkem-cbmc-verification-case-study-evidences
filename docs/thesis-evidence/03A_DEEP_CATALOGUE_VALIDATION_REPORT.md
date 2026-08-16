# 03A Deep Catalogue Validation Report — Final GitHub-Compatible Package

**Date:** 16 August 2026

## Scope

This validation pass re-examined the previously accepted 03A closure rather than treating it as immutable. The audit included record coverage, result classifications, mathematical preservation, exceptional candidates, current/historical path-state semantics, Case-4 correction state, thesis projection, GitHub mathematical syntax, MathML parsing and repository-integration safeguards.

## Package-internal counts

- rendered master files: 1;
- rendered case/investigation files: 18;
- record sections: 257;
- manifest rows: 257;
- supported subset: 220;
- negative/inconclusive subset: 19;
- partial-preservation supported records: 5.

Accepted result inventory:

```text
SUPPORTED                               215
SUPPORTED_WITH_PARTIAL_PRESERVATION       5
RESOURCE_LIMITED_INCONCLUSIVE             16
SUPPORTING_CONTROL                         7
SUPPORTED_DIAGNOSTIC                       6
ASSUMED_FROM_DOCUMENTED_GUARANTEE          4
MEANINGFUL_NEGATIVE                        2
SUPPORTED_BY_CONSTRUCTION                  1
ABSTRACTION_LIMITED_INCONCLUSIVE           1
TOTAL                                     257
```

## Re-verification of the GitHub rendering repair

The source closure package contained 210 mathematical `\operatorname{...}` uses. They were replaced mechanically with `\mathop{\text{...}}`.

Independent preservation checks:

- 257/257 record IDs unchanged;
- 257/257 formal statements present before/after;
- 257/257 reverse-normalised formal statements byte-identical;
- all 19 display-math sequences retain identical counts;
- every display equation is byte-identical after reverse-normalising only the named-operator spelling;
- no blocked operator-name macro remains in active rendered files;
- no custom macro-definition/extension command occurs in mathematical expressions;
- braces and environments balanced;
- Pandoc MathML parse: 19/19, zero warnings.

## Re-verification of exceptional findings

The package continues to preserve, without promotion:

- Case 1: `PR-C01-018`, `PR-C01-025` as `MEANINGFUL_NEGATIVE`;
- Case 13: `PR-C13-009` as `ABSTRACTION_LIMITED_INCONCLUSIVE`;
- Case 14: `PR-C14-006`–`PR-C14-021` as `RESOURCE_LIMITED_INCONCLUSIVE`;
- Case 1 partial-preservation supported IDs: `PR-C01-013`, `PR-C01-014`, `PR-C01-049`, `PR-C01-050`, `PR-C01-051`.

The previously repaired exceptional formulae for `PR-C13-009`, `PR-C14-008` and `PR-C14-013` were not rewritten by the GitHub pass.

## Current path state and historical provenance

The final rendering no longer leaves a reader to infer whether `PENDING` is current. All 257 record blocks now contain both:

- explicitly labelled frozen **Historical RC2** public-path fields; and
- current `RESOLVED_HASH_MATCH` classification with a pointer to the corresponding current row of `02_COMPLETE_PROPERTY_LEDGER.csv`.

The installed validator is strengthened beyond the old 42-gate validator: it requires all 257 current ledger rows to have populated resolved paths and SHA-256 values, requires those paths to exist, and recomputes each file hash for exact equality.

It additionally requires 18/18 current investigation locators and 573/573 representative artefact rows to carry the resolved/hash-matched classification.

## Case-4 correction

`PR-C04-013` remains mathematically rendered with production offset $`1073741824=2^{30}`$. The old $`2^{25}`$ transcription is retained only as repair provenance. The active validator requires both current ledger twins to contain the corrected $`2^{30}`$ relation.

## Thesis projection

The current supplied thesis continues to state that 210 unassisted supported records plus 10 skill-available supported records form the 220 supported subset of the complete 257-record ledger. The current thesis also shows the previously observed Case-1 item-4 title as “Modulo-(q) refinement”.

## Validation boundary

This is a structural/evidential/documentation audit. It does not re-execute the original CBMC campaigns and does not transform Markdown prose into a theorem-prover result. Formal support is inherited only from the retained formal-tool evidence mapped by the authoritative ledger.

## Verdict

**DEEP PACKAGE AUDIT: PASS.**

The live repository path/hash gate and GitHub Markdown REST rendering gate are bundled as mandatory install-time/pre-push checks because they depend on the user's live repository and network environment.

## Offline package self-audit — PASS

The finalized active package was independently checked by `03A_VALIDATE_PACKAGE_SELF.py` after checksum regeneration. The offline result was:

```text
checks=37 pass=37 fail=0
FINAL 03A OFFLINE PACKAGE SELF-AUDIT: PASS
```

The self-audit verifies the 257-record manifest and rendered union, exact result-class inventory, 220 supported projection, 19 negative/inconclusive records, 257 historical/current path-state pairs, 257 formula-preservation hashes, zero blocked `\operatorname` forms, 210 GitHub-safe named operators, balanced mathematics, current-state wording, Case-4 correction, Pandoc/MathML parsing and the active 03A checksum manifest. The transcript is retained as `03A_FINAL_OFFLINE_PACKAGE_VALIDATION_TRANSCRIPT.txt`.
