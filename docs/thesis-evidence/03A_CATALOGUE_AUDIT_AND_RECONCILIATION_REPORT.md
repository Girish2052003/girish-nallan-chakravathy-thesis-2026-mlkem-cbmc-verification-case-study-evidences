> **Superseded for final closure:** see `03A_FINAL_CLOSURE_AUDIT_REPORT.md` and `03A_FINAL_CLOSURE_DEFECT_AND_REPAIR_LOG.md`. The earlier report is retained as an audit-history artefact.

# 03A Catalogue Audit and Reconciliation Report

This report records deficiencies found in the first rendered catalogue and the corrective action incorporated automatically into the revised evidence suite.

| ID | Deficiency | Detected | Resolution |
|---|---|---|---|
| `D01` | Case-level experiment question absent | YES | Added a verification-question section to all 18 case files and a concise version to the master. |
| `D02` | Case-specific appendix opening equations absent | YES | Added clean case notation and opening equations for every unassisted case; skill cases use the shared notation unless additional definitions are needed. |
| `D03` | How experiment was conducted not synthesised per case | YES | Added source/configuration, property focus, CBMC status, mapping, reachability, feasibility, non-vacuity, mutation/control status, evidence completeness, summary identity and representative artefact counts. |
| `D04` | Frozen native baseline not explained per case | YES | Added archive-verified native baseline, proof paths/hashes, necessary overlap, generated suite, substantive distinction and claim limit. |
| `D05` | Principal-claim selection basis absent | YES | Added global selection policy and a case-specific rationale for every case/skill investigation. |
| `D06` | Property-to-principal-claim relationship absent | YES | Every record now has a principal-claim role and explicit explanation of whether it is direct support, domain/range support, frame support, relational strengthening, composition/caller support, control, negative boundary or unresolved boundary. |
| `D07` | Appendix projection absent | YES | Every supported record maps to an Appendix-1 item; exceptional records map to Appendix 2; controls/diagnostics state why they remain evidence-only. |
| `D08` | Record meaning too compressed/generic | YES | Expanded every record with separate sections for meaning, why it matters, formal-support basis, native relationship and thesis projection while retaining full metadata. |
| `D09` | Assurance-layer/novelty context not carried into catalogue | YES | Added case-level literature/assurance rows and explicit no-global-novelty boundaries. |
| `D10` | Single very large file risks poor GitHub usability | YES | Split the exhaustive record layer into 18 linked case files while retaining a complete master index; validation checks exact union and uniqueness. |

| `D11` | Negative and inconclusive records had classification/prose but no visible candidate equation in the first rendered catalogue | YES | Added explicit candidate mathematics for `PR-C01-018`, `PR-C01-025`, `PR-C13-009` and `PR-C14-006`–`PR-C14-021`; their non-supported classifications are unchanged. |
| `D12` | Strongest conclusion and exclusion were buried in metadata | YES | Added a visible “Permitted conclusion and explicit boundary” section to every one of the 257 records. |
| `D13` | Exact harness/domain obligation was not surfaced in prose for every record | YES | Added the assertion/harness mapping, admitted input domain and recorded assumptions immediately beside each property explanation. |
| `D14` | Risk of treating archive-era `PENDING` live-path fields as completed public hash validation | YES | Kept archive resolution and live public-path resolution separate; the catalogue does not claim final live path/hash matching while the current locator still reports that gate as pending. |

## Governing reconciliation decision

The repository evidence is the exhaustive layer. The thesis appendices are a compact projection and are not used to delete controls, diagnostics, assumptions, negative findings, unresolved candidates, native-baseline context or evidential qualifications from the repository. Chapter 4 principal claims are treated as compressed case-level syntheses whose supporting property families remain visible in full.
