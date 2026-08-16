#!/usr/bin/env python3
"""
Final structural, evidence-consistency, current-state and GitHub-math compatibility
validator for the 03A rendered catalogue.

Run from the repository root after installing the 03A package:

    python3 docs/thesis-evidence/03A_VALIDATE_RENDERED_CATALOGUE.py

Optional live GitHub Markdown rendering is performed by the companion script:

    python3 docs/thesis-evidence/03A_VALIDATE_GITHUB_RENDER.py --live

This validator does NOT re-execute the original CBMC campaigns. It validates the
rendered documentation against the repository's authoritative ledgers, preserved
formal-tool classifications, path/hash state, and catalogue invariants. The formal
force of SUPPORTED records remains grounded in the retained CBMC evidence under the
pinned source, harness, assumptions and analysis configuration.
"""
from __future__ import annotations

import csv
import hashlib
import re
import sys
from collections import Counter
from pathlib import Path

E = Path(__file__).resolve().parent
ROOT = E.parent.parent
MASTER = E / "03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md"
MANIFEST = E / "03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE_MANIFEST.csv"
CASES = E / "03A_RENDERED_CATALOGUE_CASES"
LEDGER = E / "02_COMPLETE_PROPERTY_LEDGER.csv"
LEDGER_MD = E / "02_COMPLETE_PROPERTY_LEDGER.md"
LOCATORS = E / "01_CASE_EVIDENCE_LOCATOR.csv"
REPRESENTATIVE = E / "16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv"

checks: list[tuple[str, bool, str]] = []
failures: list[tuple[str, str]] = []


def gate(name: str, condition: bool, detail: str = "") -> bool:
    ok = bool(condition)
    checks.append((name, ok, detail))
    if not ok:
        failures.append((name, detail))
    print(f"{'PASS' if ok else 'FAIL'}: {name}" + (f" — {detail}" if detail else ""))
    return ok


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def section_blocks(text: str) -> dict[str, tuple[str, str]]:
    ms = list(re.finditer(r"(?m)^## (PR-[A-Z0-9-]+) — (.+)$", text))
    out: dict[str, tuple[str, str]] = {}
    for i, m in enumerate(ms):
        end = ms[i + 1].start() if i + 1 < len(ms) else len(text)
        out[m.group(1)] = (m.group(2).strip(), text[m.start():end])
    return out


def md_value(block: str, label: str) -> str | None:
    m = re.search(rf"(?m)^- \*\*{re.escape(label)}:\*\* (.*)$", block)
    return None if not m else m.group(1).strip()


def strip_ticks(value: str | None) -> str | None:
    if value is None:
        return None
    if len(value) >= 2 and value[0] == "`" and value[-1] == "`":
        return value[1:-1]
    return value


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def status_count(rows: list[dict[str, str]], value: str = "RESOLVED_HASH_MATCH") -> int:
    return sum(any(str(v).strip() == value for v in row.values()) for row in rows)


def extract_math(text: str) -> list[str]:
    """Extract Markdown math outside fenced/inline code conservatively."""
    # Remove fenced code and inline code first; none of the catalogue's substantive
    # equations live in code spans.
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    text = re.sub(r"`[^`\n]*`", "", text)
    out: list[str] = []
    # Display math first.
    spans: list[tuple[int, int]] = []
    for m in re.finditer(r"\$\$(.*?)\$\$", text, flags=re.S):
        out.append(m.group(1))
        spans.append((m.start(), m.end()))
    # Mask displays, then collect inline math.
    chars = list(text)
    for a, b in spans:
        chars[a:b] = " " * (b - a)
    masked = "".join(chars)
    for m in re.finditer(r"(?<!\$)\$(?!\$)([^\n$]+?)(?<!\$)\$(?!\$)", masked):
        out.append(m.group(1))
    return out


required = [MASTER, MANIFEST, CASES, LEDGER, LEDGER_MD, LOCATORS, REPRESENTATIVE]
gate("required catalogue and authoritative ledger paths exist", all(p.exists() for p in required))
if failures:
    sys.exit(1)

ledger = read_csv(LEDGER)
manifest = read_csv(MANIFEST)
locators = read_csv(LOCATORS)
representative = read_csv(REPRESENTATIVE)
case_files = sorted(CASES.glob("*.md"))
case_texts = {p.name: p.read_text(encoding="utf-8") for p in case_files}
master_text = MASTER.read_text(encoding="utf-8")
ledger_md_text = LEDGER_MD.read_text(encoding="utf-8")

# -----------------------------------------------------------------------------
# A. Corpus identity and classification
# -----------------------------------------------------------------------------
gate("authoritative ledger contains 257 substantive records", len(ledger) == 257, str(len(ledger)))
gate("ledger property IDs are unique", len({r["property_record_id"] for r in ledger}) == 257)
gate("manifest contains 257 records", len(manifest) == 257, str(len(manifest)))
gate("manifest property IDs are unique", len({r["property_record_id"] for r in manifest}) == 257)

ledger_ids = [r["property_record_id"] for r in ledger]
manifest_ids = [r["property_record_id"] for r in manifest]
gate("manifest ID set equals ledger ID set", set(manifest_ids) == set(ledger_ids))
gate("manifest order equals ledger order", manifest_ids == ledger_ids)

classes = Counter(r["result"].strip() for r in ledger)
expected_classes = {
    "SUPPORTED": 215,
    "SUPPORTED_WITH_PARTIAL_PRESERVATION": 5,
    "RESOURCE_LIMITED_INCONCLUSIVE": 16,
    "SUPPORTING_CONTROL": 7,
    "SUPPORTED_DIAGNOSTIC": 6,
    "ASSUMED_FROM_DOCUMENTED_GUARANTEE": 4,
    "MEANINGFUL_NEGATIVE": 2,
    "SUPPORTED_BY_CONSTRUCTION": 1,
    "ABSTRACTION_LIMITED_INCONCLUSIVE": 1,
}
gate(
    "result-class inventory exactly matches the accepted 257-record corpus",
    all(classes[k] == v for k, v in expected_classes.items())
    and sum(classes.values()) == 257
    and set(classes) == set(expected_classes),
    repr(classes),
)
supported = [r for r in ledger if r["result"] in {"SUPPORTED", "SUPPORTED_WITH_PARTIAL_PRESERVATION"}]
gate("supported subset contains exactly 220 records", len(supported) == 220, str(len(supported)))
gate("unassisted/skill-supported split is preserved by manifest projections", sum(1 for m in manifest if m["appendix_projection"].startswith("Appendix 1")) == 220)

# -----------------------------------------------------------------------------
# B. Current public path/hash state — separate from scientific result status
# -----------------------------------------------------------------------------
gate("investigation locator census is 18/18", len(locators) == 18, str(len(locators)))
gate("all 18 investigation locators are resolved/hash-matched", status_count(locators) == 18, str(status_count(locators)))
gate("all 257 substantive records are resolved/hash-matched", sum(r.get("public_path_resolution_status", "").strip() == "RESOLVED_HASH_MATCH" for r in ledger) == 257)
gate("representative artefact census is 573/573", len(representative) == 573, str(len(representative)))
gate("all 573 representative artefacts are resolved/hash-matched", status_count(representative) == 573, str(status_count(representative)))

current_public_fields_ok = True
current_public_problem = ""
current_hash_match_ok = True
current_hash_problem = ""
for r in ledger:
    pid = r["property_record_id"]
    path_value = r.get("resolved_public_evidence_path", "").strip()
    sha_value = r.get("public_evidence_sha256", "").strip()
    status = r.get("public_path_resolution_status", "").strip()
    if status != "RESOLVED_HASH_MATCH" or not path_value or not re.fullmatch(r"[0-9a-f]{64}", sha_value):
        current_public_fields_ok = False
        current_public_problem = f"{pid}: status={status!r} path={path_value!r} sha={sha_value!r}"
        break
    candidate = Path(path_value)
    resolved = candidate if candidate.is_absolute() else ROOT / candidate
    if not resolved.is_file():
        current_hash_match_ok = False
        current_hash_problem = f"{pid}: current public path is not a file: {path_value}"
        break
    got = sha256_file(resolved)
    if got != sha_value:
        current_hash_match_ok = False
        current_hash_problem = f"{pid}: hash mismatch {path_value} got={got} expected={sha_value}"
        break

gate("all 257 current ledger rows have populated resolved path + valid SHA-256", current_public_fields_ok, current_public_problem)
gate("all 257 current ledger paths exist and hash-match their recorded SHA-256", current_hash_match_ok, current_hash_problem)

# -----------------------------------------------------------------------------
# C. Rendered catalogue structure
# -----------------------------------------------------------------------------
gate("exactly 18 rendered case/investigation files exist", len(case_files) == 18, str(len(case_files)))
gate(
    "all 18 detail files include opening notation/equations",
    all(
        re.search(r"(?m)^## (Case notation|Investigation notation|Case-specific notation|Opening notation|Case notation and opening equations)", t)
        for t in case_texts.values()
    ),
)
gate("all 18 detail files include publication-state reconciliation note", all("## Publication-state and traceability-field note" in t for t in case_texts.values()))

all_blocks: dict[str, tuple[str, str, str]] = {}
duplicates: list[str] = []
for fn, text in case_texts.items():
    for pid, pair in section_blocks(text).items():
        if pid in all_blocks:
            duplicates.append(pid)
        all_blocks[pid] = (fn, pair[0], pair[1])

gate("rendered case union contains 257 record sections", len(all_blocks) == 257, str(len(all_blocks)))
gate("no record appears in more than one rendered case file", not duplicates, ",".join(duplicates))
gate("rendered record ID set equals ledger ID set", set(all_blocks) == set(ledger_ids))

gate(
    "all rendered record headings match approved ledger property names",
    all(all_blocks[r["property_record_id"]][1] == r["approved_property_name"] for r in ledger),
)

mandatory_heads = [
    "### Formal statement",
    "### What the property/control means",
    "### Why it matters",
    "### Relationship to the principal claim",
    "### Formal-support basis and evidential status",
    "### Exact experimental obligation and admitted domain",
    "### Permitted conclusion and explicit boundary",
    "### Native-baseline relationship",
    "### Thesis projection",
]
gate("all 257 records contain every required explanatory section", all(all(h in b[2] for h in mandatory_heads) for b in all_blocks.values()))

math_blocks = 0
math_ok = True
for _, _, block in all_blocks.values():
    a = block.find("### Formal statement")
    b = block.find("### What the property/control means")
    mm = re.search(r"\$\$(.*?)\$\$", block[a:b], flags=re.S)
    if not mm or not mm.group(1).strip():
        math_ok = False
        break
    math_blocks += 1
gate("all 257 records contain a non-empty display-math statement", math_ok and math_blocks == 257, str(math_blocks))

# -----------------------------------------------------------------------------
# D. Immutable traceability fields + explicit historical/current path split
# -----------------------------------------------------------------------------
mapping = {
    "Property record": "property_record_id",
    "Historical identifier": "historical_id",
    "Case identifier": "case_id",
    "Condition": "condition",
    "Target": "target",
    "Property class": "property_class",
    "Source revision": "source_revision",
    "Parameter set": "parameter_set",
    "Input domain": "input_domain",
    "Assumptions and grounding": "assumptions_and_grounding",
    "Ledger formal relation": "formal_relation",
    "Assertion / harness mapping": "assertion_or_harness_mapping",
    "Result": "result",
    "Target reachability": "target_reachability",
    "Assumption feasibility": "assumption_feasibility",
    "Non-vacuity evidence": "nonvacuity_evidence",
    "Mutation status": "mutation_status",
    "Strongest bounded conclusion": "strongest_bounded_conclusion",
    "Explicit exclusion": "explicit_exclusion",
    "Evidence locator": "evidence_locator_id",
    "Evidence path hint": "evidence_path_hint",
    "Evidence completeness": "evidence_completeness",
    "Archive name": "archive_name_resolved",
    "Archive SHA-256": "archive_sha256",
    "Archive evidence path": "archive_evidence_path",
    "Archive entry SHA-256": "archive_entry_sha256",
    "Archive resolution status": "archive_resolution_status",
    "Archive candidate count": "archive_candidate_count",
}
metadata_ok = True
metadata_problem = ""
for r in ledger:
    block = all_blocks[r["property_record_id"]][2]
    for label, field in mapping.items():
        source = r.get(field, "").strip()
        got = md_value(block, label)
        if got is None:
            if source:
                metadata_ok = False
                metadata_problem = f"{r['property_record_id']}: missing {label}"
                break
            continue
        normalized = strip_ticks(got)
        if normalized != source:
            metadata_ok = False
            metadata_problem = f"{r['property_record_id']}: {label} got={normalized!r} source={source!r}"
            break
    if not metadata_ok:
        break
gate("rendered immutable traceability metadata matches the current authoritative ledger", metadata_ok, metadata_problem)

historical_ok = True
historical_problem = ""
current_overlay_ok = True
current_overlay_problem = ""
for pid, (_, _, block) in all_blocks.items():
    if strip_ticks(md_value(block, "Historical RC2 resolved public evidence path")) != "UNRESOLVED_UNTIL_FINALIZER":
        historical_ok = False
        historical_problem = f"{pid}: historical RC2 path placeholder changed"
        break
    if md_value(block, "Historical RC2 public evidence SHA-256") != "[not populated in the frozen RC2 source ledger]":
        historical_ok = False
        historical_problem = f"{pid}: historical blank SHA disclosure changed"
        break
    if strip_ticks(md_value(block, "Historical RC2 public path resolution status")) != "PENDING":
        historical_ok = False
        historical_problem = f"{pid}: historical RC2 PENDING state changed"
        break
    if strip_ticks(md_value(block, "Historical RC2 public path candidate count")) != "0":
        historical_ok = False
        historical_problem = f"{pid}: historical RC2 candidate count changed"
        break
    if strip_ticks(md_value(block, "Current public path resolution status")) != "RESOLVED_HASH_MATCH":
        current_overlay_ok = False
        current_overlay_problem = f"{pid}: current status overlay not RESOLVED_HASH_MATCH"
        break
    authority = md_value(block, "Current public path/hash authority") or ""
    if f"row `{pid}`" not in authority or "02_COMPLETE_PROPERTY_LEDGER.csv" not in authority:
        current_overlay_ok = False
        current_overlay_problem = f"{pid}: current path/hash authority row link missing"
        break

gate("all 257 frozen RC2 path fields are preserved explicitly as historical provenance", historical_ok, historical_problem)
gate("all 257 rendered records expose the current RESOLVED_HASH_MATCH state and authoritative ledger row", current_overlay_ok, current_overlay_problem)

# -----------------------------------------------------------------------------
# E. Manifest and thesis projection
# -----------------------------------------------------------------------------
manifest_by_id = {r["property_record_id"]: r for r in manifest}
manifest_ok = all(
    manifest_by_id[r["property_record_id"]]["status"] == r["result"]
    and manifest_by_id[r["property_record_id"]]["historical_id"] == r["historical_id"]
    and manifest_by_id[r["property_record_id"]]["evidence_locator_id"] == r["evidence_locator_id"]
    for r in ledger
)
gate("manifest status/historical-ID/locator fields match authoritative ledger", manifest_ok)

appendix1 = [m for m in manifest if m["appendix_projection"].startswith("Appendix 1")]
appendix2 = [m for m in manifest if m["appendix_projection"].startswith("Appendix 2")]
exception_ids = {
    r["property_record_id"]
    for r in ledger
    if r["result"] in {"MEANINGFUL_NEGATIVE", "ABSTRACTION_LIMITED_INCONCLUSIVE", "RESOURCE_LIMITED_INCONCLUSIVE"}
}
gate("Appendix-1 projection contains exactly the 220 supported records", len(appendix1) == 220 and {m["property_record_id"] for m in appendix1} == {r["property_record_id"] for r in supported}, str(len(appendix1)))
gate("Appendix-2 exceptional projection contains exactly 19 negative/inconclusive records", len(appendix2) == 19 and {m["property_record_id"] for m in appendix2} == exception_ids, str(len(appendix2)))

partial_ids = {r["property_record_id"] for r in ledger if r["result"] == "SUPPORTED_WITH_PARTIAL_PRESERVATION"}
gate("exact five partial-preservation supported IDs remain unchanged", partial_ids == {"PR-C01-013", "PR-C01-014", "PR-C01-049", "PR-C01-050", "PR-C01-051"})

# -----------------------------------------------------------------------------
# F. Interpretation/policy and resolved Case-4 correction
# -----------------------------------------------------------------------------
gate("master explicitly distinguishes exhaustive evidence from compact thesis appendices", "compact projection" in master_text and "difference in scientific meaning is not" in master_text)
gate("master preserves thesis methodology definition of principal claim", "applied only after run closure and scientific evaluation" in master_text and "does not alter row classifications" in master_text and "create a separate theorem class" in master_text and "mathematical novelty" in master_text)
gate("master states current 4785f933 base and published v1.1.0 path state", "4785f933dcf5c1fc5a1d6dae5af2211f98e66f1c" in master_text and "`v1.1.0` is already published" in master_text and "257/257 substantive property/control records" in master_text and "573/573 representative artefact records" in master_text)
gate("master separates current resolved path state from historical RC2 metadata", "historical RC2 metadata" in master_text and "RESOLVED_HASH_MATCH" in master_text and "repository publication/path resolution does not upgrade a scientific result" in master_text)

r4013 = next(r for r in ledger if r["property_record_id"] == "PR-C04-013")
gate("PR-C04-013 CSV ledger retains evidence-verified 1073741824 (=2^30) production offset", "1073741824 (=2^30)" in r4013["formal_relation"] and "2^25 lies" not in r4013["formal_relation"])
md_line = next((ln for ln in ledger_md_text.splitlines() if "PR-C04-013" in ln), "")
gate("PR-C04-013 Markdown ledger twin retains corrected production offset", "1073741824 (=2^30)" in md_line and "2^25 lies" not in md_line)
b4013 = all_blocks["PR-C04-013"][2]
gate("PR-C04-013 rendered relation is 2^30 and correction is described as resolved provenance", "1073741824=2^{30}" in b4013 and "current public CSV and Markdown ledger twins have already been corrected" in b4013)

# Previously repaired exceptional candidate displays.
b13 = all_blocks["PR-C13-009"][2]
gate("PR-C13-009 preserves allocation-aware OOM disjunction", "r_1=\\mathrm{OOM}" in b13 and "r_2=\\mathrm{OOM}" in b13 and "\\lor" in b13 and "public-seed suffix may differ" in b13)
b14008 = all_blocks["PR-C14-008"][2]
gate("PR-C14-008 preserves divisibility and affine-difference obligations", "b-a\\in R\\mathbb{Z}" in b14008 and "M(b)-M(a)=\\frac{b-a}{R}" in b14008)
b14013 = all_blocks["PR-C14-013"][2]
gate("PR-C14-013 preserves zero annihilation and unreconstructed reflection boundary", "F(a,0)=0" in b14013 and "F(0,b)=0" in b14013 and "\\mathcal{R}_0" in b14013 and "do not reproduce its internal algebraic formula" in b14013)

# -----------------------------------------------------------------------------
# G. GitHub mathematical-rendering compatibility
# -----------------------------------------------------------------------------
rendered_texts = [master_text] + [case_texts[p.name] for p in case_files]
math_exprs = [expr for text in rendered_texts for expr in extract_math(text)]
all_rendered = "\n".join(rendered_texts)

gate("GitHub-blocked operator-name macro is absent from all 19 rendered files", "\\operatorname{" not in all_rendered)
forbidden = [
    r"\\newcommand\b",
    r"\\renewcommand\b",
    r"\\providecommand\b",
    r"\\DeclareMathOperator\b",
    r"\\def\b",
    r"\\gdef\b",
    r"\\edef\b",
    r"\\xdef\b",
    r"\\require\b",
]
forbidden_hits = [pat for pat in forbidden if any(re.search(pat, expr) for expr in math_exprs)]
gate("no custom-definition/extension macros occur inside catalogue mathematics", not forbidden_hits, ",".join(forbidden_hits))

brace_ok = all(expr.count("{") == expr.count("}") for expr in math_exprs)
gate("all extracted math expressions have balanced braces", brace_ok, str(len(math_exprs)))

env_ok = True
env_problem = ""
for expr in math_exprs:
    begins = re.findall(r"\\begin\{([^}]+)\}", expr)
    ends = re.findall(r"\\end\{([^}]+)\}", expr)
    if begins != ends:
        env_ok = False
        env_problem = f"begin={begins!r} end={ends!r} expr={expr[:100]!r}"
        break
gate("all math environments are balanced and ordered", env_ok, env_problem)

mathop_count = sum(expr.count(r"\mathop{\text{") for expr in math_exprs)
gate("all 210 formerly blocked named operators are now GitHub-safe mathop/text forms", mathop_count == 210, str(mathop_count))

gate("master documents the GitHub MathJax rendering policy", "## GitHub mathematical-rendering policy" in master_text and "presentation-only" in master_text)

# -----------------------------------------------------------------------------
# H. Cross-ledger counts, links, stale-state/drafting guards
# -----------------------------------------------------------------------------
expected_csv_counts = {
    "01_CASE_EVIDENCE_LOCATOR.csv": 18,
    "04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv": 18,
    "05_LITERATURE_ASSURANCE_RELATIONSHIP_MATRIX.csv": 48,
    "06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv": 27,
    "07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv": 15,
    "09_MASTER_PROVENANCE_MATRIX.csv": 14,
    "16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv": 573,
    "17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv": 18,
}
count_ok = True
details: list[str] = []
for fn, expected in expected_csv_counts.items():
    p = E / fn
    if not p.exists():
        count_ok = False
        details.append(f"{fn}=MISSING")
        continue
    got = len(read_csv(p))
    if got != expected:
        count_ok = False
    details.append(f"{fn}={got}/{expected}")
gate("cross-ledger evidence-spine row counts match the accepted corpus", count_ok, "; ".join(details))

neg = read_csv(E / "06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv")
gate("negative/limit/conflict ledger still contains 27 records", len(neg) == 27)

dist_path = E / "04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.md"
dist = dist_path.read_text(encoding="utf-8") if dist_path.exists() else ""
gate("native distinctness layer retains repository-relative, non-global-novelty boundary", ("repository-relative" in dist.lower() or "inspected" in dist.lower()) and "global" in dist.lower())

links = re.findall(r"\]\((03A_RENDERED_CATALOGUE_CASES/[^)]+\.md)\)", master_text)
gate("master links to all 18 detail files", len(set(links)) == 18)
gate("all master detail-file links resolve", all((E / x).exists() for x in set(links)))

stale_current_patterns = [
    r"required before repository installation",
    r"current public `main` still carries",
    r"release remains pending",
    r"not yet published",
    r"to be pushed",
]
stale_hits = [pat for pat in stale_current_patterns if re.search(pat, all_rendered, flags=re.I)]
gate("active 03A rendered prose contains no stale current-state installation/publication wording", not stale_hits, ",".join(stale_hits))

historical_tokens_ok = True
historical_problem = ""
for fn, text in [(MASTER.name, master_text)] + list(case_texts.items()):
    for line_no, line in enumerate(text.splitlines(), 1):
        if "PENDING" in line or "UNRESOLVED_UNTIL_FINALIZER" in line:
            low = line.lower()
            if "historical" not in low and "frozen rc2" not in low:
                historical_tokens_ok = False
                historical_problem = f"{fn}:{line_no}: {line.strip()}"
                break
    if not historical_tokens_ok:
        break
gate("PENDING/UNRESOLVED_UNTIL_FINALIZER appear only in explicitly historical RC2 context", historical_tokens_ok, historical_problem)

gate("catalogue contains no TODO/TBD/FIXME/XXX drafting markers", not re.search(r"(?im)\b(?:TODO|TBD|FIXME|XXX)\b", all_rendered))

unresolved = [r for r in ledger if r["result"] in {"MEANINGFUL_NEGATIVE", "ABSTRACTION_LIMITED_INCONCLUSIVE", "RESOURCE_LIMITED_INCONCLUSIVE"}]
gate("all 19 negative/inconclusive records retain exact non-supported status", all(f"- **Result:** `{r['result']}`" in all_blocks[r["property_record_id"]][2] for r in unresolved))

gate("scientific unresolved classifications are not rewritten as current path resolution", classes["RESOURCE_LIMITED_INCONCLUSIVE"] == 16 and classes["ABSTRACTION_LIMITED_INCONCLUSIVE"] == 1 and classes["MEANINGFUL_NEGATIVE"] == 2)

projection_punct_ok = True
for _, _, block in all_blocks.values():
    m = re.search(r"### Thesis projection\s*\n\n([^\n]+)", block)
    if m and " Chapter 4 uses" in m.group(1):
        pre = m.group(1).split(" Chapter 4 uses")[0]
        if not pre.endswith((".", "!", "?")):
            projection_punct_ok = False
            break
gate("thesis-projection prose has a sentence boundary before Chapter 4 explanation", projection_punct_ok)

print("\nSUMMARY")
print(f"checks={len(checks)} pass={sum(1 for _, ok, _ in checks if ok)} fail={len(failures)}")
if failures:
    print("\nFAILURES")
    for name, detail in failures:
        print(f"- {name}: {detail}")
    sys.exit(1)
print("FINAL 03A STRUCTURAL / EVIDENCE / CURRENT-STATE / GITHUB-MATH VALIDATION: PASS")
