# 03A Final Closure Audit Report

**Audit date:** 16 August 2026
**Audit target:** complete rendered property/control evidence catalogue and its 18 case/investigation files
**Latest thesis comparison target:** `THESIS V2 15back (THESIS READY)(5).docx`
**Latest-thesis SHA-256:** `3851f8ca9a22ff38ac9b84aa4520c7f65bf0ac5d59fc8a1abf27768833565f1c`
**Authoritative structured source:** `02_COMPLETE_PROPERTY_LEDGER.csv` plus the linked native-distinctness, negative/limit, survival, provenance, representative-artefact and native-baseline ledgers.

## Final verdict

**PASS — document/evidence integration layer approved for repository installation, subject to applying the supplied `PR-C04-013_LEDGER_CORRECTION.patch` before the installed validator is run.**

This approval means that the rendered catalogue is structurally complete against the 257-row evidence ledger, preserves result classifications and explicit limitations, renders every record mathematically, reconciles the principal-claim reporting layer with the full case evidence, and matches the current thesis Appendix-1 projection by record count, order and displayed item title.

This approval is **not** a claim that this Markdown prose is itself a machine-checked theorem and is **not** a new execution of all original CBMC campaigns. Formal support remains grounded in the retained CBMC evidence, pinned production source, harnesses, assumptions, analysis configuration and preserved controls.

## Closure gates

### A. Repository-structured 03A validator — 42/42 PASS

The bundled `03A_VALIDATE_RENDERED_CATALOGUE.py` was executed against a clean simulation of the frozen RC2 overlay after applying the Case-4 ledger correction. It reported:

- authoritative property/control records: **257/257**;
- unique ledger IDs: **257/257**;
- manifest records: **257/257**;
- exact manifest ID set and order: **PASS**;
- supported subset: **220** = 215 `SUPPORTED` + 5 `SUPPORTED_WITH_PARTIAL_PRESERVATION`;
- detail files: **18/18**;
- record sections: **257/257**, exactly once;
- record headings equal approved ledger names: **257/257**;
- required explanatory sections: **257/257**;
- non-empty formal display: **257/257**;
- populated traceability metadata matches the authoritative ledger: **PASS**;
- blank source-ledger public SHA field disclosed explicitly: **257/257**;
- Appendix-1 projection set equals supported set: **220/220**;
- Appendix-2 negative/inconclusive projection set: **19/19**;
- native/distinctness and cross-ledger counts: **PASS**;
- internal master-to-case links: **18/18**;
- unresolved results retain their non-supported status: **19/19**;
- Case-1 partial-preservation supported records: **5/5**;
- drafting markers (`TODO`, `TBD`, `FIXME`, `XXX`): **none**.

### B. Latest thesis `(5)` reconciliation — PASS

The newest Library thesis variant was independently converted from DOCX to Markdown for structural comparison.

Appendix 1 contains **220 numbered supported entries** with the following case/investigation counts:

| Appendix section | Count |
|---|---:|
| Case 1: Polynomial Addition: mlk_poly_add | 36 |
| Case 2: Polynomial Subtraction: mlk_poly_sub | 24 |
| Case 3: Sequential Subtraction and Reduction | 1 |
| Case 4: Message Extraction: mlk_poly_tomsg | 13 |
| Case 5: Message Embedding: mlk_poly_frommsg | 13 |
| Case 6: D4 Compression and Decompression | 18 |
| Case 7: Signed-to-Canonical Conversion | 17 |
| Case 8: Barrett Reduction: mlk_barrett_reduce | 23 |
| Case 9: Zeroisation: mlk_zeroize | 16 |
| Case 10: Polynomial Serialisation: mlk_poly_tobytes | 19 |
| Case 11: Polynomial Deserialisation: mlk_poly_frombytes | 11 |
| Case 12: Direct Codec Composition | 2 |
| Case 13: Public-Key Validation: mlk_kem_check_pk | 12 |
| Case 14: Montgomery Reduction: mlk_montgomery_reduce | 5 |
| Skill-Available Addition | 3 |
| Skill-Available Subtraction | 2 |
| Skill-Available Barrett Reduction | 3 |
| Skill-Available Zeroisation | 2 |

Total: **220**.

The final 03A manifest's 220 Appendix-1 projections match the newest thesis Appendix item number and displayed item title **220/220**.

The Appendix-1 opening notation was independently recovered and includes:

- `q = 3329`;
- `n = 256`;
- the canonical representative `canon_q(x)`;
- `canon_q(x) ≡ x (mod q)`;
- `0 ≤ i < 256`.

The complete 03A master and case files retain this common/case-specific opening notation before the detailed property records.

Appendix 2 contains all **19** negative/inconclusive property IDs required by the ledger (2 meaningful negatives, 1 abstraction-limited candidate, 16 resource-limited candidates), together with the five Case-1 supported records whose **evidence preservation** is explicitly qualified. No exceptional record is silently promoted into Appendix 1.

The thesis methodology's distinction among *primary property*, *formally supported property/obligation* and *principal case-level claim* is now mirrored in the 03A master: the principal designation is applied after run closure/scientific evaluation for compact reporting, and it does not change row classifications, suppress contrary/unresolved findings, create a theorem class or imply mathematical novelty.

### C. Mathematical-stability and rendering gates — PASS

All **220 supported mathematical displays** are byte-identical to the previously accepted deep-catalogue supported displays: **220/220 unchanged**. The final closure edits therefore did not silently change supported mathematics.

Three non-supported candidate displays were deliberately refined during this closure audit:

1. `PR-C13-009` now mirrors the allocation-aware two-call OOM disjunction rather than only an equivalent non-OOM implication.
2. `PR-C14-008` now records both equal-low-word consequences retained by the MONT-T2.P3 technical evidence: `b-a ∈ Rℤ` and the affine output-difference relation.
3. `PR-C14-013` retains the two explicit zero-annihilation equations and names the separately registered normalised zero-product reflection sub-obligation as `R_0` without inventing an algebraic formula absent from the surviving source.

Pandoc 3.1.11.1 converted the master plus all 18 case files with MathML:

- files rendered: **19/19**;
- mathematical-rendering warnings: **0**.

### D. Evidence-spine source-package gates — PASS

The original RC2 standalone verifier was rerun independently:

- locators: 18;
- substantive property/control records: 257;
- representative artefact records: 573;
- native distinctness rows: 18;
- native baseline census rows: 18;
- literature relationship rows: 48;
- negative/limit/conflict records: 27;
- survival-ledger rows: 15;
- master case rows: 14;
- source-package checksums: **58/58**;
- result: **PACKAGE PASS**.

### E. Current-public-repository interpretation gates — PASS WITH REQUIRED INSTALL-TIME CORRECTION

The public repository README currently identifies the V5 evidence baseline as frozen at `v1.0.0`, the RQ2 extension as frozen at `v1.1.0`, and `v1.1.0` as published. It also explains that the finalizer/validator do not independently re-resolve every public path. The final 03A catalogue therefore keeps historical row-level `PENDING`/`UNRESOLVED_UNTIL_FINALIZER` fields separate from repository publication status.

The current public `main` ledger still carries the stale `PR-C04-013` text saying that the Case-4 production offset is `2^25`. The retained Case-4 technical evidence supports `1073741824 = 2^30`. The package therefore retains an exact patch for both ledger twins, and the installed validator **fails closed** unless that correction has been applied.

The native-distinctness layer remains explicitly repository-relative. Nothing in the final 03A catalogue upgrades it into a worldwide novelty claim.

## External thesis observation not silently altered

The latest thesis Appendix 1 currently displays Case 1 item 4 as **“Modulo-(q) refinemen”** (missing the final `t`). The evidence package reproduces the current Appendix locator faithfully but does not alter the thesis DOCX. This is a minor thesis presentation typo, not a property/evidence contradiction; it can be corrected when the appendix itself is edited.

## Final closure statement

After the repairs recorded in `03A_FINAL_CLOSURE_DEFECT_AND_REPAIR_LOG.md`, no unresolved **catalogue-internal** structural, classification, traceability, mathematical-rendering or thesis-projection defect remains in this audit.

The only required repository-integration action is mechanical and explicit: apply the supplied `PR-C04-013` ledger correction, install the 03A suite, run the bundled 42-gate validator, then run the repository's existing strict evidence-spine validator.
