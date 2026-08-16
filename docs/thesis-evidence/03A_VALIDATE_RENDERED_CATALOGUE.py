#!/usr/bin/env python3
"""
Self-contained structural and evidence-consistency validator for the 03A rendered catalogue.

Run from the repository root:
    python3 docs/thesis-evidence/03A_VALIDATE_RENDERED_CATALOGUE.py

This validator checks the rendered documentation against the repository's authoritative
structured ledgers. It does not re-execute the original CBMC campaigns and must not be
described as a replacement for the formal-tool evidence.
"""
from __future__ import annotations

import csv
import hashlib
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path.cwd()
E = ROOT / "docs" / "thesis-evidence"
MASTER = E / "03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md"
MANIFEST = E / "03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE_MANIFEST.csv"
CASES = E / "03A_RENDERED_CATALOGUE_CASES"
LEDGER = E / "02_COMPLETE_PROPERTY_LEDGER.csv"
LEDGER_MD = E / "02_COMPLETE_PROPERTY_LEDGER.md"

checks = []
failures = []

def gate(name, condition, detail=""):
    ok = bool(condition)
    checks.append((name, ok, detail))
    if not ok:
        failures.append((name, detail))
    print(f"{'PASS' if ok else 'FAIL'}: {name}" + (f" — {detail}" if detail else ""))
    return ok

def read_csv(path):
    with path.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))

def section_blocks(text):
    ms = list(re.finditer(r"(?m)^## (PR-[A-Z0-9-]+) — (.+)$", text))
    out = {}
    for i,m in enumerate(ms):
        end = ms[i+1].start() if i+1 < len(ms) else len(text)
        out[m.group(1)] = (m.group(2).strip(), text[m.start():end])
    return out

def md_value(block, label):
    m = re.search(rf"(?m)^- \*\*{re.escape(label)}:\*\* (.*)$", block)
    return None if not m else m.group(1).strip()

required = [MASTER, MANIFEST, CASES, LEDGER, LEDGER_MD]
gate("required catalogue and ledger paths exist", all(p.exists() for p in required))

if failures:
    sys.exit(1)

ledger = read_csv(LEDGER)
manifest = read_csv(MANIFEST)
case_files = sorted(CASES.glob("*.md"))
case_texts = {p.name: p.read_text(encoding="utf-8") for p in case_files}
master_text = MASTER.read_text(encoding="utf-8")
ledger_md_text = LEDGER_MD.read_text(encoding="utf-8")

gate("authoritative ledger contains 257 substantive records", len(ledger) == 257, str(len(ledger)))
gate("ledger property IDs are unique", len({r["property_record_id"] for r in ledger}) == 257)
gate("manifest contains 257 records", len(manifest) == 257, str(len(manifest)))
gate("manifest property IDs are unique", len({r["property_record_id"] for r in manifest}) == 257)

ledger_ids = [r["property_record_id"] for r in ledger]
manifest_ids = [r["property_record_id"] for r in manifest]
gate("manifest ID set equals ledger ID set", set(manifest_ids) == set(ledger_ids))
gate("manifest order equals ledger order", manifest_ids == ledger_ids)

expected_classes = Counter(r["result"] for r in ledger)
supported = [r for r in ledger if r["result"] in {"SUPPORTED","SUPPORTED_WITH_PARTIAL_PRESERVATION"}]
gate("supported subset contains exactly 220 records", len(supported) == 220, str(len(supported)))
gate("result-class inventory is 215 SUPPORTED + 5 partial-supported + remaining classified records",
     expected_classes["SUPPORTED"] == 215 and
     expected_classes["SUPPORTED_WITH_PARTIAL_PRESERVATION"] == 5 and
     sum(expected_classes.values()) == 257,
     repr(expected_classes))

gate("exactly 18 rendered case/investigation files exist", len(case_files) == 18, str(len(case_files)))
gate("all 18 detail files include opening notation/equations",
     all(re.search(r"(?m)^## (Case notation|Investigation notation|Case-specific notation|Opening notation|Case notation and opening equations)", t)
         for t in case_texts.values()))
gate("all 18 detail files include publication-state reconciliation note",
     all("## Publication-state and traceability-field note" in t for t in case_texts.values()))

all_blocks = {}
duplicates = []
for fn, text in case_texts.items():
    for pid, pair in section_blocks(text).items():
        if pid in all_blocks:
            duplicates.append(pid)
        all_blocks[pid] = (fn, pair[0], pair[1])

gate("rendered case union contains 257 record sections", len(all_blocks) == 257, str(len(all_blocks)))
gate("no record appears in more than one rendered case file", not duplicates, ",".join(duplicates))
gate("rendered record ID set equals ledger ID set", set(all_blocks) == set(ledger_ids))

name_ok = True
for r in ledger:
    got = all_blocks[r["property_record_id"]][1]
    if got != r["approved_property_name"]:
        name_ok = False
        break
gate("all rendered record headings match approved ledger property names", name_ok)

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
gate("all 257 records contain every required explanatory section",
     all(all(h in b[2] for h in mandatory_heads) for b in all_blocks.values()))

math_ok = True
math_blocks = 0
for pid, (_,_,block) in all_blocks.items():
    p = block.find("### Formal statement")
    q = block.find("### What the property/control means")
    piece = block[p:q]
    mm = re.search(r"\$\$(.*?)\$\$", piece, flags=re.S)
    if not mm or not mm.group(1).strip():
        math_ok = False
        break
    math_blocks += 1
gate("all 257 records contain a non-empty display-math statement", math_ok and math_blocks == 257, str(math_blocks))

# Basic TeX delimiter/brace sanity; Pandoc conversion is a separate closure gate.
brace_ok = True
for _,_,block in all_blocks.values():
    for m in re.finditer(r"\$\$(.*?)\$\$", block, flags=re.S):
        x = m.group(1)
        if x.count("{") != x.count("}"):
            brace_ok = False
            break
gate("display-math braces are balanced in all rendered records", brace_ok)

# Exact traceability metadata comparison.
mapping = {
    "Property record":"property_record_id",
    "Historical identifier":"historical_id",
    "Case identifier":"case_id",
    "Condition":"condition",
    "Target":"target",
    "Property class":"property_class",
    "Source revision":"source_revision",
    "Parameter set":"parameter_set",
    "Input domain":"input_domain",
    "Assumptions and grounding":"assumptions_and_grounding",
    "Ledger formal relation":"formal_relation",
    "Assertion / harness mapping":"assertion_or_harness_mapping",
    "Result":"result",
    "Target reachability":"target_reachability",
    "Assumption feasibility":"assumption_feasibility",
    "Non-vacuity evidence":"nonvacuity_evidence",
    "Mutation status":"mutation_status",
    "Strongest bounded conclusion":"strongest_bounded_conclusion",
    "Explicit exclusion":"explicit_exclusion",
    "Evidence locator":"evidence_locator_id",
    "Evidence path hint":"evidence_path_hint",
    "Evidence completeness":"evidence_completeness",
    "Archive name":"archive_name_resolved",
    "Archive SHA-256":"archive_sha256",
    "Archive evidence path":"archive_evidence_path",
    "Archive entry SHA-256":"archive_entry_sha256",
    "Archive resolution status":"archive_resolution_status",
    "Archive candidate count":"archive_candidate_count",
    "Resolved public evidence path":"resolved_public_evidence_path",
    "Public path resolution status":"public_path_resolution_status",
    "Public path candidate count":"public_path_candidate_count",
}
metadata_ok = True
metadata_problem = ""
for r in ledger:
    block = all_blocks[r["property_record_id"]][2]
    for label, field in mapping.items():
        source = r[field].strip()
        got = md_value(block, label)
        if got is None:
            # mutation_status is allowed to be absent only if source is blank; current corpus is already generated accordingly.
            if source:
                metadata_ok = False
                metadata_problem = f'{r["property_record_id"]}: missing {label}'
                break
            continue
        # strip paired backticks for exact scalar metadata
        normalized = got
        if len(normalized)>=2 and normalized[0]=='`' and normalized[-1]=='`':
            normalized = normalized[1:-1]
        if normalized != source:
            metadata_ok = False
            metadata_problem = f'{r["property_record_id"]}: {label} got={normalized!r} source={source!r}'
            break
    if not metadata_ok:
        break
gate("traceability metadata reproduces populated authoritative ledger fields exactly", metadata_ok, metadata_problem)

public_sha_ok = True
for r in ledger:
    block = all_blocks[r["property_record_id"]][2]
    got = md_value(block, "Public evidence SHA-256")
    if r["public_evidence_sha256"].strip():
        if got != r["public_evidence_sha256"].strip():
            public_sha_ok=False; break
    else:
        if got != "[not populated in the frozen RC2 source ledger]":
            public_sha_ok=False; break
gate("all 257 blank source-ledger public SHA fields are explicitly disclosed, never invented", public_sha_ok)

# Hash syntax for populated source-ledger SHA fields.
sha_fields = ["archive_sha256","archive_entry_sha256","public_evidence_sha256"]
sha_ok = True
for r in ledger:
    for f in sha_fields:
        v = r[f].strip()
        if v and not re.fullmatch(r"[0-9a-f]{64}", v):
            sha_ok=False
gate("all populated ledger SHA-256 values have valid 64-hex syntax", sha_ok)

# Manifest consistency.
manifest_by_id = {r["property_record_id"]:r for r in manifest}
manifest_ok = all(
    manifest_by_id[r["property_record_id"]]["status"] == r["result"] and
    manifest_by_id[r["property_record_id"]]["historical_id"] == r["historical_id"] and
    manifest_by_id[r["property_record_id"]]["evidence_locator_id"] == r["evidence_locator_id"]
    for r in ledger
)
gate("manifest status/historical-ID/locator fields match authoritative ledger", manifest_ok)

appendix1 = [m for m in manifest if m["appendix_projection"].startswith("Appendix 1")]
appendix2 = [m for m in manifest if m["appendix_projection"].startswith("Appendix 2")]
gate("Appendix-1 projection contains exactly the 220 supported records",
     len(appendix1)==220 and {m["property_record_id"] for m in appendix1} == {r["property_record_id"] for r in supported},
     str(len(appendix1)))
exception_ids = {r["property_record_id"] for r in ledger if r["result"] in
                 {"MEANINGFUL_NEGATIVE","ABSTRACTION_LIMITED_INCONCLUSIVE","RESOURCE_LIMITED_INCONCLUSIVE"}}
gate("Appendix-2 exceptional projection contains exactly 19 negative/inconclusive records",
     len(appendix2)==19 and {m["property_record_id"] for m in appendix2} == exception_ids,
     str(len(appendix2)))

# Master interpretation and principal-claim policy.
gate("master explicitly distinguishes exhaustive evidence from compact thesis appendices",
     "compact projection" in master_text and "difference in scientific meaning is not" in master_text)
gate("master preserves thesis methodology definition of principal claim",
     "applied only after run closure and scientific evaluation" in master_text and
     "does not alter row classifications" in master_text and
     "create a separate theorem class" in master_text and
     "mathematical novelty" in master_text)
gate("master separates published release state from historical row-level PENDING path fields",
     "Publication-state and row-level path-status reconciliation" in master_text and
     "statements that the repository itself is unpublished" in master_text and
     "Blank public-file hashes are never inferred or reconstructed" in master_text)

# Case-specific final corrections.
b13 = all_blocks["PR-C13-009"][2]
gate("PR-C13-009 preserves exact allocation-aware OOM disjunction",
     "r_1=\\mathrm{OOM}" in b13 and "r_2=\\mathrm{OOM}" in b13 and "\\lor" in b13 and
     "public-seed suffix may differ" in b13)
b14008 = all_blocks["PR-C14-008"][2]
gate("PR-C14-008 includes both equal-low-word divisibility and affine-difference obligations",
     "b-a\\in R\\mathbb{Z}" in b14008 and "M(b)-M(a)=\\frac{b-a}{R}" in b14008)
b14013 = all_blocks["PR-C14-013"][2]
gate("PR-C14-013 preserves zero annihilation and names unreconstructed reflection sub-obligation",
     "F(a,0)=0" in b14013 and "F(0,b)=0" in b14013 and "\\mathcal{R}_0" in b14013 and
     "do not reproduce its internal algebraic formula" in b14013)

# PR-C04-013 correction must be applied to both ledger twins.
r4013 = next(r for r in ledger if r["property_record_id"]=="PR-C04-013")
gate("PR-C04-013 CSV ledger has evidence-verified 1073741824 (=2^30) production offset",
     "1073741824 (=2^30)" in r4013["formal_relation"] and "2^25 lies" not in r4013["formal_relation"])
md_line = next((ln for ln in ledger_md_text.splitlines() if "PR-C04-013" in ln), "")
gate("PR-C04-013 Markdown ledger twin matches corrected production offset",
     "1073741824 (=2^30)" in md_line and "2^25 lies" not in md_line)

# Cross-ledger evidence-spine counts if present.
expected_csv_counts = {
    "01_CASE_EVIDENCE_LOCATOR.csv":18,
    "04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv":18,
    "05_LITERATURE_ASSURANCE_RELATIONSHIP_MATRIX.csv":48,
    "06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv":27,
    "07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv":15,
    "09_MASTER_PROVENANCE_MATRIX.csv":14,
    "16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv":573,
    "17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv":18,
}
count_ok = True
detail=[]
for fn,n in expected_csv_counts.items():
    p=E/fn
    if not p.exists():
        count_ok=False; detail.append(f"{fn}=MISSING"); continue
    c=len(read_csv(p))
    if c!=n:
        count_ok=False
    detail.append(f"{fn}={c}/{n}")
gate("cross-ledger evidence-spine row counts match frozen corpus", count_ok, "; ".join(detail))

# Distinctness and boundary policy text.
dist = (E/"04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.md").read_text(encoding="utf-8") if (E/"04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.md").exists() else ""
gate("native distinctness layer retains repository-relative, non-global-novelty boundary",
     ("repository-relative" in dist.lower() or "inspected" in dist.lower()) and "global" in dist.lower())

neg = read_csv(E/"06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv")
gate("negative/limit/conflict ledger still contains 27 records", len(neg)==27)

# Master links resolve.
links = re.findall(r"\]\((03A_RENDERED_CATALOGUE_CASES/[^)]+\.md)\)", master_text)
gate("master links to all 18 detail files", len(set(links))==18)
gate("all master detail-file links resolve", all((E/x).exists() for x in set(links)))

# No incomplete drafting markers in catalogue prose.
all_catalogue_text = master_text + "\n".join(case_texts.values())
gate("catalogue contains no TODO/TBD/FIXME/XXX drafting markers",
     not re.search(r"(?im)\b(?:TODO|TBD|FIXME|XXX)\b", all_catalogue_text))

# Preserve limitations; avoid accidental class upgrades in unresolved records.
unresolved = [r for r in ledger if r["result"] in
              {"MEANINGFUL_NEGATIVE","ABSTRACTION_LIMITED_INCONCLUSIVE","RESOURCE_LIMITED_INCONCLUSIVE"}]
status_wording_ok = True
for r in unresolved:
    block=all_blocks[r["property_record_id"]][2]
    if f"- **Result:** `{r['result']}`" not in block:
        status_wording_ok=False; break
gate("all 19 negative/inconclusive records retain their exact non-supported status", status_wording_ok)

# Case-1 partial preservation stays explicit.
partial_ids = {r["property_record_id"] for r in ledger if r["result"]=="SUPPORTED_WITH_PARTIAL_PRESERVATION"}
gate("exactly five partial-preservation supported records remain explicitly classified", len(partial_ids)==5)

# Record names and projections should not concatenate sentence boundary.
projection_punct_ok = True
for _,_,block in all_blocks.values():
    m = re.search(r"### Thesis projection\s*\n\n([^\n]+)", block)
    if m and " Chapter 4 uses" in m.group(1):
        pre=m.group(1).split(" Chapter 4 uses")[0]
        if not pre.endswith((".", "!", "?")):
            projection_punct_ok=False; break
gate("thesis-projection prose has a sentence boundary before Chapter 4 explanation", projection_punct_ok)

print("\nSUMMARY")
print(f"checks={len(checks)} pass={sum(1 for _,ok,_ in checks if ok)} fail={len(failures)}")
if failures:
    print("\nFAILURES")
    for name, detail in failures:
        print(f"- {name}: {detail}")
    sys.exit(1)
print("FINAL CATALOGUE STRUCTURAL/EVIDENCE-CONSISTENCY VALIDATION: PASS")
