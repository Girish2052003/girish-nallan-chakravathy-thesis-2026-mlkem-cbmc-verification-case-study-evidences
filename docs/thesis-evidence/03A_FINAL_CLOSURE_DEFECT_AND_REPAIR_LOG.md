# 03A Final GitHub-Closure Defect and Repair Log

**Audit date:** 16 August 2026
**Supersedes:** the pre-GitHub-render-fix closure log preserved under `03A_AUDIT_HISTORY/`.

This log records the additional defects or stale assumptions discovered after the first 03A installation was viewed on live GitHub, together with the repair incorporated into this final package.

| ID | Finding | Severity | Repair / treatment | Final package status |
|---|---|---|---|---|
| `GCR-01` | GitHub displayed macro errors instead of many catalogue equations because the rendered suite used `\operatorname{...}`. | High presentation/integrity risk | Replaced all 210 mathematical uses deterministically with GitHub-safe `\mathop{\text{...}}`. Added a fail-closed static GitHub-math policy validator plus a live GitHub Markdown REST API smoke gate. | CLOSED |
| `GCR-02` | The earlier closure treated a 19/19 Pandoc/MathML pass as sufficient rendering assurance, but Pandoc does not enforce GitHub's MathJax macro allowlist. | Validation-gap | Added a separate GitHub-specific compatibility layer. Pandoc remains an independent syntax/MathML gate rather than a proxy for GitHub. | CLOSED |
| `GCR-03` | The old package still described the Case-4 `2^25 → 2^30` repair as an installation prerequisite. The current public base already contains the corrected ledger twins. | Stale current-state instruction | Removed the patch from the active install path, retained it only in audit history, and made the validator fail closed unless the current ledger already contains `1073741824 (=2^30)`. | CLOSED |
| `GCR-04` | Record traceability blocks reproduced `PENDING` / `UNRESOLVED_UNTIL_FINALIZER` without labels that clearly identify them as historical RC2 fields, while the live ledger is now 257/257 resolved/hash-matched. | Current-state ambiguity | Renamed all four frozen public-path fields as **Historical RC2** metadata and added a per-record current `RESOLVED_HASH_MATCH` overlay pointing to the authoritative live ledger row. | CLOSED |
| `GCR-05` | The first 03A installation was reverted, so root/evidence README navigation to 03A was absent from the clean base. | Discoverability | Added an idempotent installer that inserts the 03A link into root `README.md`, `THESIS_EVIDENCE_INDEX.md`, and `docs/thesis-evidence/README.md`, while refusing to rewrite already reconciled release-state documents. | CLOSED at package design; install-time action required |
| `GCR-06` | The earlier thesis-reconciliation report targeted `THESIS V2 15back (THESIS READY)(5).docx` and recorded a Case-1 Appendix typo (“refinemen”). The current thesis attachment shows “Modulo-(q) refinement”. | Stale external observation | Updated the thesis-reconciliation summary to the current supplied thesis file and removed the stale typo finding from the active closure. The earlier observation remains preserved in audit history. | CLOSED |
| `GCR-07` | A rendering fix could accidentally alter substantive mathematics while appearing purely typographical. | Scientific-integrity risk | Generated `03A_PRE_GITHUB_MATH_PRESERVATION_MANIFEST.csv`: 257/257 formal statements are SHA-bound before/after; reverse-normalising only the GitHub-safe operator spelling gives exact equality for 257/257 formal statements and every display equation in 19/19 files. | CLOSED |
| `GCR-08` | Current public-path status could be copied into prose and later drift from the authoritative ledger. | Traceability drift risk | The catalogue records only current classification `RESOLVED_HASH_MATCH` plus the exact authoritative ledger row ID; current path/hash strings stay in `02_COMPLETE_PROPERTY_LEDGER.csv` and are checked against repository files by the installed validator. | CLOSED |
| `GCR-09` | Historical pre-release text and scientific unresolved findings risk being flattened by generic “pending/unresolved” cleanup. | Scientific/provenance risk | Final validators separately preserve historical RC2 status, current path state and scientific result classes. `RESOURCE_LIMITED_INCONCLUSIVE`, `ABSTRACTION_LIMITED_INCONCLUSIVE`, `MEANINGFUL_NEGATIVE` and partial-preservation classifications are explicitly counted and protected. | CLOSED |
| `GCR-10` | Previous closure artefacts could be lost or silently rewritten during cleanup. | Audit-history risk | Preserved the complete exact pre-GitHub source closure as `03A_AUDIT_HISTORY/PRE_GITHUB_RENDER_FIX_EXACT_SOURCE_CLOSURE.zip` at its original SHA-256; readable provenance copies remain beside it. | CLOSED |
| `GCR-11` | Fresh re-audit found that two readable historical files retained CRLF/trailing whitespace from the source closure, so a later `git diff --cached --check` would fail after staging even though the active 03A files were clean. | Git-integration defect | Kept the exact source closure inside the preserved ZIP, normalised only the readable historical copies to LF/no trailing whitespace, extended the package self-audit to all installable text, and removed the installer exemption for `03A_AUDIT_HISTORY`. | CLOSED |
| `GCR-12` | The first implementation of the new package-level staged-diff simulation copied one directory above the candidate package, so it unintentionally included unrelated `/mnt/data` artefacts in the temporary Git check. | Validator-scope defect | Corrected the simulation root from `E.parent.parent.parent` to the actual package root `E.parent.parent`, then regenerated checksums and reran the full self-audit. | CLOSED |
| `GCR-13` | The GitHub-render and repository-aware catalogue validators depended on the process working directory. | Validator portability defect | Resolve package/evidence paths from `Path(__file__).resolve()` rather than `Path.cwd()`. | CLOSED |
| `GCR-14` | The redundant installer/self-audit text-hygiene scans did not independently descend to readable `PRE_GITHUB_RENDER_FIX__*` files inside `03A_AUDIT_HISTORY`. | Validation-coverage defect | Scan every text-like file beneath a top-level installed `03A_*` path, including `.patch`; package-level staged-Git simulation remains an independent redundant gate. | CLOSED |
| `GCR-15` | The RC2 live validator incorrectly required GitHub's REST Markdown endpoint to expose the browser-side MathJax rejection of a known-bad `\operatorname` control. The endpoint returned HTML without exposing that client-side macro-policy error, so installation correctly stopped. | Live-gate model defect | Reclassified the REST endpoint according to its documented contract: it is used only as a live GFM Markdown-to-HTML transport/render smoke gate. Browser-side macro-policy compatibility remains fail-closed in the static validator: zero `\operatorname`, zero custom-definition macros, exactly 210 approved `\mathop{\text{...}}` replacements, plus 257/257 formula-preservation bindings. | CLOSED in RC3 |
| `GCR-16` | RC3 report editing initially left an extra blank line at EOF in two documentation files, which would fail `git diff --cached --check`. | Packaging-hygiene defect | The staged-Git simulation caught the defect before packaging; both files were normalized to exactly one final newline and the complete package staging gate was rerun. | CLOSED in RC3 |

## Final repair principle

No accepted property is strengthened, weakened, deleted or promoted by this GitHub-closure pass. The repair changes presentation, current-state labelling, validator coverage and repository integration only. Scientific outcomes continue to be governed by the authoritative evidence ledger and retained CBMC evidence.

## GCR-13 — validator working-directory dependence

**Detected by:** independent final-approval invocation from the package root.

**Defect:** the GitHub-render validator and repository-aware rendered-catalogue validator resolved the repository through `Path.cwd()`. A valid package therefore failed when the validator was launched from any directory other than the expected repository root.

**Repair:** both validators now derive `docs/thesis-evidence` from `Path(__file__).resolve()` and derive the repository root from that location. The static GitHub gate is therefore location-independent, while the repository-aware validator resolves the installed repository deterministically from its own path.

**Scientific effect:** none. No formal statement, result classification, evidence path or mathematical expression changed.

## GCR-14 — installer/self-audit audit-history text-scan coverage

**Detected by:** independent inspection of the installer after the staged-Git whitespace gate was strengthened.

**Defect:** the redundant text-hygiene loops in the installer and package self-audit selected `rglob("03A_*")`; this matched active 03A filenames but not readable `PRE_GITHUB_RENDER_FIX__*` files nested inside `03A_AUDIT_HISTORY`. The package-level staged-Git simulation already covered trailing-whitespace integration, but the explicit carriage-return/text-hygiene gates did not cover those nested readable copies independently.

**Repair:** both the installer and package self-audit now scan every text-like file whose top-level installed path begins with `03A_`, including `.patch` audit-history copies, and reject any carriage return or trailing horizontal whitespace.

**Scientific effect:** none. This strengthens installation hygiene only.
## GCR-15 — REST Markdown endpoint is not a browser-side MathJax policy oracle

**Detected during real RC2 installation on 17 August 2026.**

**Defect:** the RC2 `--live` validator used a known-bad `\operatorname{P}` expression as a negative sensitivity control and required the REST Markdown endpoint itself to emit GitHub web UI's "macros are not allowed" message. The REST endpoint accepted the request and returned Markdown-rendered HTML without exposing that browser-side MathJax macro-policy error. The gate therefore failed closed before commit or push.

**Repair:** RC3 removes the invalid negative-control assumption. The live endpoint is used only for what GitHub documents it to do: render submitted Markdown/GFM to HTML and return a successful, non-empty response. The GitHub-macro compatibility conclusion is made by the independent static gate, which rejects the known blocked `\operatorname` form and custom-definition macros and requires all 210 named-operator replacements to use the accepted `\mathop{\text{...}}` spelling. The 257-record preservation manifest independently proves that this presentation normalization does not change the accepted mathematics.

**Scientific effect:** none. No record, formula, result class, assumption, path/hash state, or evidence mapping changed.
## GCR-16 — RC3 documentation EOF hygiene

**Detected during RC3 construction before packaging.**

The first RC3 documentation edit left an additional blank line at end-of-file in `03A_INSTALLATION.md` and `03A_FINAL_CLOSURE_DEFECT_AND_REPAIR_LOG.md`. The package-level temporary Git staging simulation rejected those bytes. Both files were normalized to one terminal newline and all package checks were rerun before RC3 was sealed. No scientific or mathematical content was affected.

## GCR-17 — RC3 porcelain-v1 exact-changeset parser

**Detected by the real RC3 installation on 17 August 2026 before commit or push.**

RC3 captured `git status --porcelain=v1` through a helper that returned `stdout.strip()`. For a tracked work-tree modification such as ` M README.md`, `.strip()` removed the leading blank status column. The later fixed-width `line[3:]` extraction therefore produced `EADME.md`, causing the exact-approved-changeset gate to reject an otherwise correct installation.

RC4 adds a raw Git-capture helper that removes only terminal newline characters, preserves the two porcelain XY columns, centralises path parsing in `parse_porcelain_paths()`, and adds a package self-audit regression test covering both ` M README.md` and an untracked `?? docs/thesis-evidence/03A_*` path. The real RC3 stop occurred before commit, push, tag or release operations; no scientific record, formula, classification or repository evidence path was altered by this defect.
## GCR-18 — Authenticated GitHub live-render validation

**Status:** CLOSED

During the final live Markdown REST smoke test, the unauthenticated GitHub API allowance was exhausted after most catalogue files had already rendered successfully, producing HTTP 403 rate-limit responses for the remaining requests.

The live validator was hardened to use an existing GitHub authentication token through the `GITHUB_TOKEN` environment variable. Authentication changes only API transport capacity; it does not modify catalogue mathematics, evidence records, classifications, repository path mappings or scientific conclusions.

The static GitHub-math policy gate remains authoritative for blocked macro detection. The authenticated REST pass remains a live Markdown-to-HTML smoke test.
## GCR-19 — Repository-wide GitHub mathematical rendering hardening

**Status:** CLOSED

A post-publication browser review identified remaining red-rendered mathematical expressions outside the original named-operator repair boundary. A repository-wide audit was therefore performed across all current-facing Markdown under `docs/thesis-evidence`, excluding only frozen `03A_AUDIT_HISTORY` provenance.

The deterministic rendering-only transformation replaced:

- `0` remaining `\operatorname{...}` occurrences with the already accepted GitHub-safe `\mathop{\text{...}}` form;
- `4` `cases` layout environments with equivalent left-braced base `array` layouts; and
- `12` `aligned` layout environments with equivalent two-column base `array` layouts.

No row content, equality, inequality, constant, quantifier, condition, domain, record classification or evidence path was intentionally altered. For the formal 03A catalogue, all 257 current statements were independently reverse-normalized and required to match the exact pre-GitHub accepted source closure byte-for-byte at the statement level.

Changed current-facing Markdown files:

- `docs/thesis-evidence/03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md`
- `docs/thesis-evidence/03A_RENDERED_CATALOGUE_CASES/CASE_01_POLYNOMIAL_ADDITION.md`
- `docs/thesis-evidence/03A_RENDERED_CATALOGUE_CASES/CASE_02_POLYNOMIAL_SUBTRACTION.md`
- `docs/thesis-evidence/03A_RENDERED_CATALOGUE_CASES/CASE_04_MESSAGE_EXTRACTION.md`
- `docs/thesis-evidence/03A_RENDERED_CATALOGUE_CASES/CASE_06_D4_COMPRESSION_DECOMPRESSION.md`
- `docs/thesis-evidence/03A_RENDERED_CATALOGUE_CASES/CASE_08_BARRETT_REDUCTION.md`
- `docs/thesis-evidence/03A_RENDERED_CATALOGUE_CASES/CASE_09_ZEROISATION.md`
- `docs/thesis-evidence/03A_RENDERED_CATALOGUE_CASES/CASE_10_POLYNOMIAL_SERIALISATION.md`
- `docs/thesis-evidence/03A_RENDERED_CATALOGUE_CASES/CASE_13_PUBLIC_KEY_VALIDATION.md`
- `docs/thesis-evidence/03A_RENDERED_CATALOGUE_CASES/CASE_14_MONTGOMERY_REDUCTION.md`
## GCR-20 — Installed-repository self-validation mode

**Status:** CLOSED

The 03A package self-validator contained one standalone-installer regression
guard that unconditionally imported `03A_INSTALL_FINAL.py` from the repository
root. The installed public repository does not retain that standalone package
installer, and neither the preserved pre-GitHub closure nor repository history
contains it.

The guard was therefore made context-aware: when the installer is present in a
standalone package, its porcelain-v1 parsing regression test remains mandatory;
when validating the already-installed repository, that installer-specific check
is explicitly recorded as not applicable. No scientific, evidence, catalogue,
mathematical, checksum, rendering or repository-integrity gate was removed.
## GCR-21 — Strict MathJax control-word delimiter adjacency

**Status:** CLOSED

A strict MathJax audit of all 414 catalogue mathematical expressions identified
exactly four browser-rendering failures: PR-C04-012, PR-C05-002, PR-C05-010
and PR-C08-022.

The affected expressions used `\left\lbrace` immediately followed by an
alphabetic token. Under TeX control-word tokenisation, the following letters
were consumed into the control sequence (for example, `\lbracec`), producing
MathJax's `Missing or unrecognized delimiter for \left` error.

The repair inserts one presentation-only separator space after `\lbrace` in
those four expressions. Reverse normalisation removes that separator, and all
257/257 current formal statements continue to reconstruct exactly to their
accepted pre-GitHub statements.

The same strict MathJax audit reported zero undefined macros. Apparent lexical
patterns such as `\\0` and `\\M` occur at array row boundaries and are not
undefined control sequences.
