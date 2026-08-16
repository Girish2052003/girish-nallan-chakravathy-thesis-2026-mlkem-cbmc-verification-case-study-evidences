# 03A Final Closure Defect and Repair Log

**Audit date:** 16 August 2026

This log records defects found by the final independent closure audit and the action taken. It distinguishes evidence-document defects from observations that belong to the thesis or to repository installation.

| ID | Finding | Severity | Repair / treatment | Final status |
|---|---|---|---|---|
| CL-01 | Row-level `PENDING` / `UNRESOLVED_UNTIL_FINALIZER` fields could be misread as saying the repository itself was unpublished. | Interpretive ambiguity | Added a master reconciliation section and an explicit note to all 18 detail files. Publication/release state and row-level path re-resolution state are now separate. | CLOSED |
| CL-02 | The source ledger's blank `public_evidence_sha256` field was omitted from the rendered traceability blocks. | Exhaustiveness | Added `Public evidence SHA-256: [not populated in the frozen RC2 source ledger]` to all 257 records. No hash was invented. | CLOSED |
| CL-03 | Principal-claim wording was less precise than the thesis methodology. | Methodological traceability | Added the thesis distinction among primary, formally supported and principal claims, including post-closure selection, reporting-only status, classification preservation and no novelty implication. | CLOSED |
| CL-04 | `PR-C13-009` displayed the non-OOM implication but not the exact allocation-aware OR structure of the retained assertion. | Formal transcription | Re-rendered the candidate as prefix equality implying `r1 = OOM ∨ r2 = OOM ∨ r1 = r2`; clarified that seed suffixes may differ. Status remains `ABSTRACTION_LIMITED_INCONCLUSIVE`. | CLOSED |
| CL-05 | `PR-C14-008` omitted the explicit divisibility sub-obligation retained in the MONT-T2.P3 source. | Formal transcription | Added `b-a ∈ Rℤ` alongside `M(b)-M(a)=(b-a)/R` under the equal-low-word premise. Status remains `RESOURCE_LIMITED_INCONCLUSIVE`. | CLOSED |
| CL-06 | `PR-C14-013` title included “reflection” but the display contained only the two zero-annihilation equations. | Source-boundary ambiguity | Added symbolic `R_0(a,b)` for the separately named normalised zero-product reflection sub-obligation and explicitly stated that its internal algebraic formula is not reconstructed because the retained summary does not reproduce it. | CLOSED |
| CL-07 | Case-4 `PR-C04-013` had corrected `2^30` mathematics but its copied “Ledger formal relation” metadata still repeated the stale `2^25` text. | Internal contradiction | Corrected the 03A traceability metadata to `1073741824 (=2^30)`. The supplied patch applies the same repair to the authoritative CSV/Markdown ledger twins. | CLOSED IN PACKAGE; PATCH REQUIRED ON LIVE REPO |
| CL-08 | Five populated ledger `mutation_status = N/A` values were omitted from rendered metadata. | Exhaustiveness | Added explicit `Mutation status: N/A` to `PR-C01-001`, `PR-C01-002`, `PR-C01-018`, `PR-C01-025`, and `PR-C03-001`. | CLOSED |
| CL-09 | Nineteen Appendix-2 projection sentences lacked punctuation before the Chapter-4 explanation. | Presentation | Added sentence boundaries without changing any scientific content. | CLOSED |
| CL-10 | Thirty-five Appendix projection labels, concentrated in Cases 8 and 9, retained older concise item titles although record position/identity was correct. | Traceability locator | Reconciled all 220 manifest/case-file Appendix-1 projection labels against the newest thesis `(5)` item numbers and displayed titles. Exact title projection now matches 220/220. | CLOSED |
| CL-11 | Latest thesis Appendix Case-1 item 4 displays “Modulo-(q) refinemen”. | Thesis-only typography | Not changed in the evidence package. Recorded here so the later appendix edit can restore “refinement”. It does not change the mapped property or mathematics. | OUTSIDE 03A; THESIS EDIT LATER |

## No silent claim upgrades

The audit did not change any result classification. In particular:

- the two Case-1 meaningful negatives remain meaningful negatives;
- `PR-C13-009` remains abstraction-limited and inconclusive;
- all sixteen MONT-T2–T4 records remain resource-limited and inconclusive;
- the five Case-1 partial-preservation records remain supported **with** their preservation qualification;
- controls, diagnostics, construction invariants and documented guarantees remain distinct from the 220 supported-property/obligation subset.

## Mathematics preservation

No supported mathematical display was changed during final closure: **220/220 supported displays are byte-identical to the previously accepted deep-catalogue displays**. Only the three non-supported candidate displays identified above were refined, and each refinement is source-conservative.
