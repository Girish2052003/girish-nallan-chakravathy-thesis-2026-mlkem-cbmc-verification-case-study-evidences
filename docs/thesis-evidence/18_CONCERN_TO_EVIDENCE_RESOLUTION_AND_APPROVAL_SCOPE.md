# Concern-to-evidence resolution and installation approval scope

This document records exactly what the evidence-spine package resolves before Chapter 4 is rewritten. It is intended to prevent later scope drift or retrospective strengthening.

## Resolved by this package

| Original concern | Authoritative package response | Status after archive audit | Final public-release gate |
|---|---|---|---|
| What substantive properties were investigated across all fourteen campaigns? | `02_COMPLETE_PROPERTY_LEDGER.csv` records 257 substantive properties/controls with historical ID, approved name, domain, assumptions, formal relation, mapping, result and exclusion. | RESOLVED AT ARCHIVE LEVEL | Every property evidence path must hash-match in the public checkout. |
| Are exact mathematical/logical statements available where needed? | `03_FORMAL_CLAIM_CATALOGUE.md` gives selective principal statements; the property ledger carries row-level relations. | RESOLVED, WITH CASE-SPECIFIC NON-CONFLICTING NOTATION | Thesis equations must be copied from this catalogue/ledger and the accepted harness, not re-invented. |
| Were “theorems proved”? | `11_TERMINOLOGY_AND_CLAIM_POLICY.md` forbids that formulation and preserves historical T/PA identifiers only for traceability. | RESOLVED | Chapter 4 must use bounded-claim terminology. |
| How does each campaign differ from the frozen mlkem-native repository? | `04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv` plus archive-verified `17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv` records the actual native harness/source baseline, necessary overlap and substantive distinction for all 14+4 investigations. | RESOLVED WITH FROZEN-SOURCE CONTROL | Public release must include these ledgers; no global-novelty claim is permitted. |
| How do the claims relate to literature and other assurance work? | `05_LITERATURE_ASSURANCE_RELATIONSHIP_MATRIX.csv` records assurance-layer relationships and an explicit exact-match boundary. | RESOLVED AS A RELATIONSHIP MATRIX, NOT AN EXHAUSTIVE PRIOR-ART CERTIFICATE | Chapter 5 may interpret these relationships; it may not claim world-first status. |
| Are negative, inconclusive, excluded, partial and conflicting findings visible? | `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv` preserves the required contrary results, preservation gaps, invalid summaries and frozen-source conflicts. | RESOLVED | Chapter 4 surgery must retain or cross-reference every applicable record. |
| Can an examiner locate the evidence publicly? | Files 01, 12 and 16 identify roots, summaries, property evidence and 573 representative artefacts with archive hashes. | RESOLVED AT ARCHIVE LEVEL | `finalize_evidence_spine.py` and strict validation must resolve/hash-match them in the Git/LFS checkout. |
| Can Chapter 4 remain within budget? | File 15 and the template require replacement/compression rather than adding all ledgers to the chapter body. | SURGERY PLAN RESOLVED | Page count must be checked after the evidence-based rewrite. |

## Deliberate limits that remain after installation

1. The 257 rows are substantive property/control records, not every tool-emitted safety property. Counts such as 1,046 Case-10 CBMC records and 652 skilled successful property records are retained as tool-record counts and must not be recoded as independent scientific claims.
2. The literature matrix is not an exhaustive worldwide novelty search. It supports assurance-layer comparison and explicitly refuses world-first conclusions.
3. A strict PASS certifies the public availability and byte identity of every indexed root, summary, substantive-property evidence file and representative artefact. It does not assert that every repeated preservation view inside the ten ZIP archives appears as a separate Git path.
4. Case 1 remains `PARTIAL`; publication cannot restore subordinate outputs that were never retained.
5. Public availability is not equivalent to scientific validity. Claim validity remains controlled by the property ledger, evidence hierarchy and bounded interpretation.
6. The package does not rewrite Chapter 4. It makes the subsequent surgery traceable and safe.

## Approval rule

Installation is approved only for the corrected RC2 package. Final thesis citation of a frozen release is approved only after:

- the finalizer reports all 18 roots and summaries, 257 property evidence files and 573 representative artefacts resolved and hash-matched;
- strict validation reports PASS;
- the reviewed generated files are committed;
- the working tree is clean;
- tag `v1.0.0` points to that commit; and
- the GitHub release is created from that tag.
