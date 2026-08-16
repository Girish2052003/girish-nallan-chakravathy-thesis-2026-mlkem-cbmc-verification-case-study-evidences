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
