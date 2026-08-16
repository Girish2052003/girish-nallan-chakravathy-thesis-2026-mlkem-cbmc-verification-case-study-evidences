> **Superseded for final closure:** see `03A_FINAL_CLOSURE_AUDIT_REPORT.md` and `03A_FINAL_CLOSURE_DEFECT_AND_REPAIR_LOG.md`. The earlier report is retained as an audit-history artefact.

# 03A Deep Rendered Catalogue Validation Report

**Overall status: PASS**
**Gates passed: 36/36**

## Validation scope

This validation checks corpus completeness, record identity and classification, thesis-appendix projection, case-level principal-claim architecture, mathematical-display completeness, preservation of previously audited equations, explicit candidate mathematics for negative/inconclusive records, native-baseline/distinctness integration, negative/limit and literature-context coverage, internal links, Markdown/MathML renderability, arithmetic constants and the retained RC2 evidence-spine structural validator.

It is **not** a new independent execution of all original CBMC campaigns, a formal proof of the English prose, or a claim that the Markdown document itself is theorem-proved. Formal support remains exactly the status recorded by the underlying evidence ledger and raw formal-tool evidence.

## Gate results

| Gate | Status | Detail |
|---|---|---|
| 18 case files exist | **PASS** | 18 |
| master exists | **PASS** |  |
| manifest has 257 rows | **PASS** | 257 |
| ledger has 257 unique record IDs | **PASS** | 257/257 |
| manifest exact ID set equals ledger | **PASS** | missing=set() extra=set() |
| manifest exact order equals ledger | **PASS** |  |
| manifest result-class counts equal ledger | **PASS** | ledger={'SUPPORTED': 215, 'RESOURCE_LIMITED_INCONCLUSIVE': 16, 'SUPPORTING_CONTROL': 7, 'SUPPORTED_DIAGNOSTIC': 6, 'SUPPORTED_WITH_PARTIAL_PRESERVATION': 5, 'ASSUMED_FROM_DOCUMENTED_GUARANTEE': 4, 'MEANINGFUL_NEGATIVE': 2, 'SUPPORTED_BY_CONSTRUCTION': 1, 'ABSTRACTION_LIMITED_INCONCLUSIVE': 1}; manifest={'SUPPORTED': 215, 'RESOURCE_LIMITED_INCONCLUSIVE': 16, 'SUPPORTING_CONTROL': 7, 'SUPPORTED_DIAGNOSTIC': 6, 'SUPPORTED_WITH_PARTIAL_PRESERVATION': 5, 'ASSUMED_FROM_DOCUMENTED_GUARANTEE': 4, 'MEANINGFUL_NEGATIVE': 2, 'SUPPORTED_BY_CONSTRUCTION': 1, 'ABSTRACTION_LIMITED_INCONCLUSIVE': 1} |
| supported subset is 220 | **PASS** |  |
| latest thesis Appendix 1 item count is 220 (including directly inspected Case-8/9 item 1) | **PASS** | {'Case 1: Polynomial Addition: mlk_poly_add': 36, 'Case 2: Polynomial Subtraction: mlk_poly_sub': 24, 'Case 3: Sequential Subtraction and Reduction': 1, 'Case 4: Message Extraction: mlk_poly_tomsg': 13, 'Case 5: Message Embedding: mlk_poly_frommsg': 13, 'Case 6: D4 Compression and Decompression': 18, 'Case 7: Signed-to-Canonical Conversion': 17, 'Case 8: Barrett Reduction: mlk_barrett_reduce': 23, 'Case 9: Zeroisation: mlk_zeroize': 16, 'Case 10: Polynomial Serialisation: mlk_poly_tobytes': 19, 'Case 11: Polynomial Deserialisation: mlk_poly_frombytes': 11, 'Case 12: Direct Codec Composition': 2, 'Case 13: Public-Key Validation: mlk_kem_check_pk': 12, 'Case 14: Montgomery Reduction: mlk_montg |
| Appendix-1 per-case counts equal supported ledger counts | **PASS** | app={'1': 36, '2': 24, '3': 1, '4': 13, '5': 13, '6': 18, '7': 17, '8': 23, '9': 16, '10': 19, '11': 11, '12': 2, '13': 12, '14': 5, 'SA-ADD': 3, 'SA-SUB': 2, 'SA-BR': 3, 'SA-ZERO': 2}; ledger={'1': 36, '2': 24, '3': 1, '4': 13, '5': 13, '6': 18, '7': 17, '8': 23, '9': 16, '10': 19, '11': 11, '12': 2, '13': 12, '14': 5, 'SA-ADD': 3, 'SA-SUB': 2, 'SA-BR': 3, 'SA-ZERO': 2} |
| manifest maps exactly 220 records to Appendix 1 | **PASS** | 220 |
| manifest maps 19 exceptional records to Appendix 2 | **PASS** | 19 |
| case-file union contains 257 record sections | **PASS** | 257 |
| each record appears exactly once | **PASS** | [] |
| case-file record set exactly equals ledger | **PASS** | missing=set() extra=set() |
| all required deep-explanation sections present for every record | **PASS** | [] |
| all 257 records have non-empty display mathematics | **PASS** | [] |
| all record display-math braces structurally balanced | **PASS** | [] |
| 238 previously vetted non-empty record equations preserved byte-for-byte | **PASS** | [] |
| all 19 previously empty negative/inconclusive candidates now have formal displays | **PASS** | ['PR-C01-018', 'PR-C01-025', 'PR-C13-009', 'PR-C14-006', 'PR-C14-007', 'PR-C14-008', 'PR-C14-009', 'PR-C14-010', 'PR-C14-011', 'PR-C14-012', 'PR-C14-013', 'PR-C14-014', 'PR-C14-015', 'PR-C14-016', 'PR-C14-017', 'PR-C14-018', 'PR-C14-019', 'PR-C14-020', 'PR-C14-021'] |
| PR-C04-013 uses corrected 2^30 production offset | **PASS** |  |
| Case 8 retains 2^25 Barrett offset | **PASS** |  |
| independent arithmetic constants/ranges rechecked | **PASS** |  |
| all 18 case files contain complete case-level evidence architecture | **PASS** | [] |
| all Markdown files are below 1 MiB | **PASS** | max=294198 |
| no unwanted generated-language wording in catalogue prose | **PASS** | [] |
| no drafting placeholders TODO/TBD/FIXME/XXX | **PASS** | [] |
| master links all 18 case files | **PASS** | ['03A_RENDERED_CATALOGUE_CASES/CASE_01_POLYNOMIAL_ADDITION.md', '03A_RENDERED_CATALOGUE_CASES/CASE_02_POLYNOMIAL_SUBTRACTION.md', '03A_RENDERED_CATALOGUE_CASES/CASE_03_SEQUENTIAL_SUBTRACTION_REDUCTION.md', '03A_RENDERED_CATALOGUE_CASES/CASE_04_MESSAGE_EXTRACTION.md', '03A_RENDERED_CATALOGUE_CASES/CASE_05_MESSAGE_EMBEDDING.md', '03A_RENDERED_CATALOGUE_CASES/CASE_06_D4_COMPRESSION_DECOMPRESSION.md', '03A_RENDERED_CATALOGUE_CASES/CASE_07_SIGNED_TO_CANONICAL.md', '03A_RENDERED_CATALOGUE_CASES/CASE_08_BARRETT_REDUCTION.md', '03A_RENDERED_CATALOGUE_CASES/CASE_09_ZEROISATION.md', '03A_RENDERED_CATALOGUE_CASES/CASE_10_POLYNOMIAL_SERIALISATION.md', '03A_RENDERED_CATALOGUE_CASES/CASE_11_POLYNOMIAL_DES |
| all 27 negative/limit/conflict records surfaced in case evidence | **PASS** | [] |
| all 48 literature/assurance relationship rows surfaced by case | **PASS** | [] |
| principal-claim survival IDs resolve to ledger or declared conflict/limit records | **PASS** | [] |
| Pandoc Markdown→HTML/MathML succeeds for master + 18 case files | **PASS** |  |
| Pandoc reports zero math/render warnings | **PASS** | [] |
| rendered MathML contains at least 257 formulae | **PASS** | 406 |
| RC2 standalone evidence-spine validator exits PASS | **PASS** | # Evidence-spine validation report  - Mode: STRUCTURAL - Locators: 18 - Substantive property/control records: 257 - Representative artefact records: 573 - Native distinctness rows: 18 - Native baseline census rows: 18 - Literature relationship rows: 48 - Negative/limit/conflict records: 27 - Survival-ledger rows: 15 - Master case rows: 14  ## PASS All selected structure, traceability, terminology, archive mapping, native-baseline correction, literature-boundary, public-path, source-revision, referential-integrity and preservation checks passed. PACKAGE PASS: 58 file checksums and structural evidence-spine validation passed.  |
| catalogue does not falsely claim live public path/hash resolution | **PASS** |  |

## Source populations

- Complete property/control ledger: **257** records.
- Formally supported subset: **220**.
- Appendix-1 parsed supported items: **220**.
- Negative/limit/conflict ledger: **27** records.
- Literature/assurance relationship rows: **48**.
- Case detail files: **18**.
- Total MathML elements in render test: **406**.

## Result-class inventory

- `SUPPORTED`: 215
- `RESOURCE_LIMITED_INCONCLUSIVE`: 16
- `SUPPORTING_CONTROL`: 7
- `SUPPORTED_DIAGNOSTIC`: 6
- `SUPPORTED_WITH_PARTIAL_PRESERVATION`: 5
- `ASSUMED_FROM_DOCUMENTED_GUARANTEE`: 4
- `MEANINGFUL_NEGATIVE`: 2
- `SUPPORTED_BY_CONSTRUCTION`: 1
- `ABSTRACTION_LIMITED_INCONCLUSIVE`: 1

## Mathematics correction/reconstruction register

- `PR-C04-013`: retains the evidence-verified production offset `1073741824 = 2^30`; the supplied ledger patch corrects the stale `2^25` transcription in the current ledger twins.
- `PR-C01-018`, `PR-C01-025`: the rejected universal candidate propositions are now displayed explicitly; their status remains `MEANINGFUL_NEGATIVE`.
- `PR-C13-009`: the allocation-aware two-call seed-noninterference candidate is displayed explicitly; its status remains `ABSTRACTION_LIMITED_INCONCLUSIVE`.
- `PR-C14-006`–`PR-C14-021`: the MONT-T2–T4 candidate relations are now displayed rather than left blank; all remain `RESOURCE_LIMITED_INCONCLUSIVE`. Candidate expressions not printed verbatim in the compact appendix are labelled conservative formalisation and do not alter status or bounded conclusion.

## Approval boundary

On the gates above, the suite is approved as a **structurally complete, mathematically renderable, cross-ledger-consistent and thesis-reconciled evidence catalogue**. This approval concerns the documentation/evidence integration layer. The formal-verification force of each substantive result comes from its retained CBMC evidence under the recorded source, harness, assumptions and analysis configuration.
