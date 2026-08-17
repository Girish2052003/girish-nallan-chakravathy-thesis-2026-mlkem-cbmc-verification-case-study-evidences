# 03A GitHub Mathematical-Rendering Compatibility Report

**Revision:** `RC4` — retains the RC3 live-gate and hygiene repairs and closes exact-changeset parser defect `GCR-17`.

**Audit date:** 16 August 2026
**Scope:** `03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md` plus the 18 files in `03A_RENDERED_CATALOGUE_CASES/`
**Source package:** `FORMALLY_AUDITED_DEEP_PROPERTY_EVIDENCE_FINAL_CLOSURE.zip`
**Source package SHA-256:** `c7398fe30c727edc3eacbd5db4b3f4dcddea19ebb786249311f27eb6376de851`

## Finding that triggered this closure pass

The earlier closure used Pandoc/MathML as the mathematical rendering gate. That proved the TeX was structurally parseable, but it did not simulate GitHub's own MathJax macro restrictions. The previously accepted rendered catalogue contained **210** uses of `\operatorname{...}` across the master and 18 detail files. GitHub's Markdown interface can reject that macro with the message that `operatorname` is not allowed.

GitHub documents that Markdown mathematical expressions are rendered with MathJax. GitHub's `github/markup` issue #1688 records the `\operatorname` restriction and gives `\mathop{\text{...}}` as a working operator-spacing workaround. GitHub also provides a public REST Markdown-rendering endpoint that can be used for a final live pre-push rendering gate.

References:

- GitHub Docs, **Writing mathematical expressions**: <https://docs.github.com/en/enterprise-cloud@latest/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions>
- GitHub `github/markup` issue #1688, **Markdown doesn't recognize \operatorname anymore**: <https://github.com/github/markup/issues/1688>
- GitHub Docs, **REST API endpoints for Markdown**: <https://docs.github.com/en/rest/markdown/markdown>

## Repair

Every mathematical use of

```text
\operatorname{Name}
```

was converted deterministically to

```text
\mathop{\text{Name}}
```

No other formal-statement content was changed by this compatibility transformation.

### Transformation count

- rendered files: **19**;
- blocked named-operator forms before repair: **210**;
- blocked named-operator forms after repair: **0**;
- GitHub-safe `\mathop{\text{...}}` operator forms inside mathematical expressions: **210**.

## Mathematical preservation proof

The pre-fix accepted package and the GitHub-safe package were compared record by record.

- property/control record sections: **257/257**;
- formal statements recovered: **257/257**;
- record-ID sets before/after: identical;
- after converting each new `\mathop{\text{Name}}` back to its old `\operatorname{Name}` spelling, formal-statement exact matches: **257/257**;
- master and case display-math sequence counts before/after: identical for **19/19 files**;
- all display equations, after the same one-way normalization, are byte-identical to the accepted pre-fix package.

`03A_PRE_GITHUB_MATH_PRESERVATION_MANIFEST.csv` cryptographically binds every formal statement to both its pre-fix and GitHub-safe SHA-256 values and records the normalized exact-match result.

This proves that the GitHub compatibility repair is a **presentation transformation**, not a semantic rewrite of the mathematical claims.

## Static GitHub-math compatibility gate

`03A_VALIDATE_GITHUB_RENDER.py` checks the 19 rendered files for:

- absence of `\operatorname` in mathematical expressions;
- absence of custom macro-definition/extension commands such as `\newcommand`, `\renewcommand`, `\DeclareMathOperator`, `\def` and `\require`;
- balanced mathematical braces;
- balanced `\begin{...}` / `\end{...}` environments;
- exactly 210 GitHub-safe named-operator replacements.

Result in this closure environment:

```text
STATIC files=19 math_expressions=414 github_safe_named_operators=210
STATIC GITHUB-MATH COMPATIBILITY: PASS
```

## Independent MathML parse gate

Pandoc 3.1.11.1 was rerun after the GitHub-safe conversion using GFM input with TeX-dollar mathematics and MathML output.

- files parsed: **19/19**;
- Pandoc return-code failures: **0**;
- mathematical-rendering warning lines: **0**;
- result: **PASS**.

## Live GitHub REST API smoke gate

The package includes a mandatory pre-push live **Markdown API smoke gate**:

```bash
python3 docs/thesis-evidence/03A_VALIDATE_GITHUB_RENDER.py --live
```

GitHub documents the REST Markdown endpoint as a service that renders submitted Markdown/GFM to HTML. It does **not** document that endpoint as an execution oracle for the browser-side MathJax macro-policy layer. A real RC2 installation confirmed this distinction: the REST endpoint did not expose the known web-UI `\operatorname` rejection, so RC2 correctly stopped rather than claiming a false discriminating live PASS.

RC3 therefore uses two separate controls:

1. **Static macro-policy gate (authoritative for this defect class):** all 19 files must contain zero `\operatorname` expressions, zero custom-definition/extension macros, exactly 210 accepted `\mathop{\text{...}}` operator forms, balanced mathematics, and 257/257 cryptographic formula-preservation matches.
2. **Live GitHub REST gate:** the GitHub Markdown endpoint must accept the `\mathop{\text{...}}` positive control and all 19 complete Markdown documents in GFM mode, return HTTP 200/non-empty HTML, and expose no macro error if one is present in the REST response.

The live gate is therefore evidence that GitHub accepts the complete documents through its documented Markdown-to-HTML API path. The browser-side macro-policy conclusion is not inferred from a negative REST control; it is enforced fail-closed by the static gate and grounded in GitHub's documented MathJax use plus the recorded `github/markup` `\operatorname` defect/workaround.

The package-construction environment cannot run the live network request, so the REST smoke gate remains an installation-time gate. It does not publish or modify repository content.

## Verdict

**OFFLINE GITHUB-COMPATIBILITY AUDIT: PASS.**

The earlier `\operatorname` defect is removed without altering the accepted mathematics. Final installation acceptance additionally requires the bundled live GitHub Markdown REST API smoke gate to pass in the user's repository environment before commit/push.

<!-- CURRENT-03A-PUBLICATION:START -->
## Final live publication validation

Before the catalogue was committed, the static GitHub-math gate passed with
19 rendered documents, 414 extracted mathematical expressions, 210 approved
GitHub-safe named-operator forms, and zero blocked `\operatorname` forms.

The authenticated GitHub Markdown REST smoke test then completed successfully
for all 19/19 rendered catalogue documents.

The first publication commit for the validated catalogue is `73cba2c5bc9a51a156d0931669ee58123ce0037e`.
<!-- CURRENT-03A-PUBLICATION:END -->

<!-- REPOSITORY-WIDE-GITHUB-MATH-AUDIT:START -->

## Repository-wide post-publication GitHub math audit

The current-facing `docs/thesis-evidence` Markdown corpus was audited after browser-visible red rendering remained in a subset of equations.

Rendering-only replacements:

- `\operatorname{...}` → `\mathop{\text{...}}`: **0**
- `cases` → equivalent left-braced base `array`: **4**
- `aligned` → equivalent two-column base `array`: **12**
- Markdown files changed by the deterministic source repair: **10**

For the exhaustive 03A formal layer, 257/257 repaired current statements reverse-normalize exactly to the accepted pre-GitHub source statements.

<!-- REPOSITORY-WIDE-GITHUB-MATH-AUDIT:END -->

<!-- STRICT-MATHJAX-AUDIT:START -->

## Strict MathJax audit

A browser-oriented strict MathJax parse was performed over the complete
414-expression rendered catalogue corpus with undefined-command masking
disabled.

Initial result:

- expressions tested: **414**
- strict failures: **4**
- undefined macros: **0**

The four failures were PR-C04-012, PR-C05-002, PR-C05-010 and PR-C08-022.
Each arose from alphabetic-token adjacency immediately after `\left\lbrace`,
causing TeX control-word consumption. One lexical separator space was inserted
after `\lbrace` in each affected expression.

The repaired expressions remain mathematically unchanged and reverse-normalise
exactly to their accepted historical statements.

<!-- STRICT-MATHJAX-AUDIT:END -->

<!-- RC4_ROWBREAK_BOUNDARY_FIX_2026_08_17 -->

## Live GitHub row-boundary rendering correction — 17 August 2026

Post-publication browser inspection exposed five presentation-layer TeX row boundaries in which the first token of the following row was directly adjacent to the preceding `\\` row-break command. The affected source forms included `\\0`, `\\M[j]`, and `\\c_{\mathrm{prod}}`.

The active GitHub-facing catalogue was normalized to the semantically equivalent forms `\\ 0`, `\\ M[j]`, and `\\ c_{\mathrm{prod}}`. The correction inserts only an explicit token boundary after the TeX row break.

A before/after comparison against the immutable pre-repair Git `HEAD` confirmed preservation of all 414 mathematical expressions. The total number of `\mathop{\text{...}}` constructs was also unchanged from the pre-repair `HEAD`; therefore the row-boundary correction did not create or remove named mathematical operators. The existing 210-conversion invariant concerns the formerly GitHub-blocked named-operator transformations and is distinct from the total number of `\mathop{\text{...}}` constructs present in the catalogue.

No property identifier, result classification, verification domain, bounded conclusion, evidential status, public evidence locator, or scientific claim was changed by this correction.

<!-- RC4_GITHUB_PROTECTED_INLINE_DELIMITER_FIX -->

## Protected-inline GitHub Markdown correction — 17 August 2026

Live browser inspection after the earlier macro and TeX-row-boundary corrections showed that a further GitHub-specific presentation failure remained. The affected class was ordinary inline `$...$` mathematics containing TeX structures that overlap with Markdown parsing, including commands, braces, and subscripts.

GitHub documents `$`…`` `$` as the protected inline-mathematics delimiter for expressions whose contents can interact with Markdown syntax. Accordingly, every ordinary inline mathematical expression in the active 03A master and 18 case/investigation documents was converted to the protected GitHub delimiter form.

The TeX body of every expression was preserved byte-for-byte. This correction changes only the Markdown delimiter surrounding inline mathematics. The 414-expression inventory, all 257 property/control records, the 220 supported-property/obligation subset, scientific result classifications, formal relations, domains, evidence mappings and bounded conclusions are unchanged.

The pre-fix material under `03A_AUDIT_HISTORY/` remains immutable historical provenance and was not modified.

<!-- RC4_EXACT_OPERATOR_MULTISET_RECONCILIATION -->

## Exact historical named-operator multiset reconciliation — 17 August 2026

The protected-inline GitHub correction exposed a defect in the legacy named-operator validation metric. The immutable pre-GitHub-render source contains exactly 210 `\operatorname{...}` occurrences, whereas the current active catalogue contains 211 `\mathop{\text{...}}` occurrences and zero remaining blocked `\operatorname{...}` occurrences. The additional safe `\mathop{\text{...}}` occurrence was already present in the immutable pre-current-repair Git `HEAD`; it was not introduced by the protected-inline delimiter correction.

Accordingly, the formal validation invariant is now defined by exact multiset preservation rather than total current safe-command count. Every historical `\operatorname{BODY}` occurrence, including multiplicity, must have a corresponding current `\mathop{\text{BODY}}` occurrence. The immutable historical multiset contains exactly 210 occurrences, zero may be missing, and the active source must contain zero blocked `\operatorname{...}` commands.

This strengthens the gate by distinguishing the 210 historically transformed operators from any independently existing GitHub-safe `\mathop{\text{...}}` construct. No mathematical expression, property record, domain, result classification, evidence mapping or bounded conclusion was changed by this validator correction.

<!-- RC4_PROFESSIONAL_GITHUB_MATH_NORMALISATION -->

## Professional GitHub-math normalisation — 17 August 2026

A full presentation audit of the active rendered catalogue distinguished mathematical presentation defects from ordinary code, paths, status labels and evidence identifiers.

The repair promoted 27 audit-confirmed mathematical relations that had been enclosed in ordinary Markdown code spans into GitHub protected-inline MathJax. This does not create 27 new scientific properties: the canonical pre-existing mathematical corpus remains 414 expressions, while the active presentation surface now contains 441 MathJax-rendered expressions because previously textual/code-formatted repetitions of established relations are now typeset as mathematics.

The two low-nibble relations that used `\mathbin{\&}` were rewritten using the mathematically equivalent modulo-16 representation appropriate to the recorded byte-valued operands. Raw mathematical less-than/greater-than characters were replaced by TeX-safe comparison macros, and the single C-style `=>` / `!=` textual relation was normalised to mathematical implication/inequality notation.

The transformation is presentation-only. Property IDs, result classifications, verification domains, evidence mappings, path/hash authority, bounded conclusions and the 257-record / 220-supported scientific inventories are unchanged.

Historical source under `03A_AUDIT_HISTORY/` remains immutable and was not modified.

<!-- RC4_FINAL_ACTIVE_03A_PROFESSIONAL_MATH_CLOSURE_2026_08_17 -->

## Final active-03A professional-mathematics closure — 17 August 2026

The final presentation-closure pass covered all 26 active 03A Markdown files outside the immutable `03A_AUDIT_HISTORY/` source. The resulting active presentation surface contains 919 MathJax expressions.

All 257 Ledger formal relations are rendered from the corresponding record-local Formal statement. Exact semantic-source comparison passed for 257/257 records. Strict parsing passed for 919/919 expressions with MathJax 3.2.2 and independently for 919/919 expressions with MathJax 4.1.3. The final high-confidence residual audit found zero remaining mathematical expressions in plain prose under the defined closure rules.

The scientific inventory remained unchanged at 257 substantive property/control records, including the preserved 220-record supported subset. The repair was presentation-only: scientific statuses, evidence locators, archive identities, hashes, assumptions, bounded conclusions and formal semantics were not intentionally altered. The immutable historical audit source and validator sources remained untouched.

No new evidence package, release or tag was created as part of this presentation closure.

<!-- RC4_POST_CLOSURE_MECHANICAL_REAUDIT_2026_08_17 -->

## Post-closure mechanical re-audit — 17 August 2026

After the initial 919-expression professional-mathematics closure had passed strict MathJax validation and browser inspection, a deliberately wider mechanical residual scan was run over the complete active 03A Markdown surface. That independent scan identified 32 additional genuine mathematical domain/configuration fragments still presented as ordinary prose. They comprised repeated ML-KEM parameter assignments and numerical domain intervals in Cases 1, 2, 4 and 14.

Those 32 occurrences were repaired presentation-only in exactly four rendered case files. The resulting active 03A mathematical surface contains 951 MathJax expressions. Strict parsing passed independently for 951/951 expressions with MathJax 3.2.2 and for 951/951 expressions with MathJax 4.1.3. The widened high-confidence residual scan then returned zero plain-math residuals.

The Ledger/Formal semantic comparison remained 257/257, the substantive scientific inventory remained 257 records, and the supported subset remained 220 records. The strict evidence-spine validator continued to pass. No scientific status, formal relation, evidence locator, archive identity, assumption, bounded conclusion or retained historical audit source was changed by this follow-up presentation repair.

This follow-up did not create a new evidence package, release or tag.

<!-- RC4_FOURTH_PASS_MATHEMATICAL_PRESENTATION_CLOSURE_2026_08_17 -->

## Fourth-pass mathematical-presentation closure — 17 August 2026

A further deliberately broadened mechanical audit was applied after the 951-expression closure. It reviewed symbolic intervals, compact parameter/domain notation, plain-prose mathematical tokens and formula-like ordinary code spans across all 26 active 03A Markdown files.

That audit identified 27 additional genuine mathematical presentation occurrences in the master catalogue, Case 1 and Case 7. They consisted of symbolic domains and intervals such as `[0,q)`, `[0,q-1]`, and related admitted-domain notation. The repair was presentation-only and changed exactly those three Markdown sources.

The resulting active 03A mathematical surface contains 978 MathJax expressions. Strict parsing passed for 978/978 expressions with MathJax 3.2.2 and independently for 978/978 expressions with MathJax 4.1.3. The broadened fourth-pass audit then returned zero plain-prose mathematical candidates and zero formula-like ordinary code spans.

The scientific evidence spine remained valid. No historical audit source, validator source, scientific status, formal relation, evidence locator, assumption or bounded conclusion was altered. No evidence package, release or tag was created.
