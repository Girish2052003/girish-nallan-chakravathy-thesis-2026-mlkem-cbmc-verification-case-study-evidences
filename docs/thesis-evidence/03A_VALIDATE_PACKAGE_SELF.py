#!/usr/bin/env python3
"""Offline self-audit for the extracted final GitHub-renderable 03A package.

This script validates package-internal structure, accepted result counts, mathematical
preservation relative to the pre-GitHub-render-fix closure, GitHub-safe math syntax,
current-state wording, and package checksums. It does not need the repository's
existing ledgers and does not re-execute CBMC.
"""
from __future__ import annotations

import csv
import hashlib
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from collections import Counter
from pathlib import Path

E = Path(__file__).resolve().parent
MASTER = E / "03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md"
CASES = E / "03A_RENDERED_CATALOGUE_CASES"
MANIFEST = E / "03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE_MANIFEST.csv"
PRESERVATION = E / "03A_PRE_GITHUB_MATH_PRESERVATION_MANIFEST.csv"
SUMS = E / "03A_CATALOGUE_SHA256SUMS.txt"
HISTORY = E / "03A_AUDIT_HISTORY"
EXACT_SOURCE = HISTORY / "PRE_GITHUB_RENDER_FIX_EXACT_SOURCE_CLOSURE.zip"
EXACT_SOURCE_SHA256 = "c7398fe30c727edc3eacbd5db4b3f4dcddea19ebb786249311f27eb6376de851"

checks = []
failures = []

def gate(name, condition, detail=""):
    ok = bool(condition)
    checks.append((name, ok, detail))
    print(f"{'PASS' if ok else 'FAIL'}: {name}" + (f" — {detail}" if detail else ""))
    if not ok:
        failures.append((name, detail))
    return ok

def read_csv(path):
    with path.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))

def sha_text(s):
    return hashlib.sha256(s.encode("utf-8")).hexdigest()

def sha_file(p):
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def denorm(s):
    # Post-publication GitHub layout reverse-normalization
    s = re.sub(
        r"\\mathop\{\\text\{([^{}]+)\}\}",
        lambda m: r"\operatorname{" + m.group(1) + "}",
        s,
    )

    # Restore the exact accepted cases presentation.
    s = s.replace(
        r"\left\lbrace\begin{array}{ll}",
        r"\begin{cases}",
    )

    s = s.replace(
        r"\end{array}\right.",
        r"\end{cases}",
    )

    # Restore standalone historical left-brace presentation.
    # The GitHub-safe form carries one lexical separator space so
    # TeX does not consume the following letter into the control word.
    # Remove that presentation-only separator during reconstruction.
    s = s.replace(
        r"\left\lbrace ",
        r"\left\{",
    )

    # Retain compatibility with any standalone lbrace form whose
    # following token does not require a separator.
    s = s.replace(
        r"\left\lbrace",
        r"\left\{",
    )

    # Restore standalone historical right-brace presentation.
    s = s.replace(
        r"\right\rbrace",
        r"\right\}",
    )

    # Restore the exact accepted aligned presentation.
    s = s.replace(
        r"\begin{array}{rl}",
        r"\begin{aligned}",
    )

    s = s.replace(
        r"\end{array}",
        r"\end{aligned}",
    )

    return s

def sections(text):
    ms = list(re.finditer(r"(?m)^## (PR-[A-Z0-9-]+) — (.+)$", text))
    out = {}
    for i, m in enumerate(ms):
        end = ms[i+1].start() if i+1 < len(ms) else len(text)
        out[m.group(1)] = (m.group(2).strip(), text[m.start():end])
    return out

def md_value(block, label):
    m = re.search(rf"(?m)^- \*\*{re.escape(label)}:\*\* (.*)$", block)
    return None if not m else m.group(1).strip()

def strip_ticks(v):
    if v is None:
        return None
    return v[1:-1] if len(v) >= 2 and v[0] == "`" and v[-1] == "`" else v

def extract_math(text):
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    text = re.sub(r"`[^`\n]*`", "", text)
    out=[]; spans=[]
    for m in re.finditer(r"\$\$(.*?)\$\$", text, flags=re.S):
        out.append(m.group(1)); spans.append((m.start(),m.end()))
    chars=list(text)
    for a,b in spans: chars[a:b]=" "*(b-a)
    masked="".join(chars)
    out.extend(m.group(1) for m in re.finditer(r"(?<!\$)\$(?!\$)([^\n$]+?)(?<!\$)\$(?!\$)", masked))
    return out

required=[MASTER,CASES,MANIFEST,PRESERVATION,HISTORY,EXACT_SOURCE]
gate("required final package files exist", all(p.exists() for p in required))
if failures: sys.exit(1)

# Exact source-closure preservation and Git staging hygiene.
exact_ok = sha_file(EXACT_SOURCE) == EXACT_SOURCE_SHA256
exact_zip_ok = False
exact_zip_problem = ""
if exact_ok:
    try:
        with zipfile.ZipFile(EXACT_SOURCE) as zf:
            bad = zf.testzip()
            exact_zip_ok = bad is None
            if bad is not None:
                exact_zip_problem = bad
    except Exception as exc:
        exact_zip_problem = str(exc)
gate("exact pre-GitHub source closure is preserved at its accepted SHA-256", exact_ok, sha_file(EXACT_SOURCE))
gate("exact pre-GitHub source closure ZIP integrity passes", exact_zip_ok, exact_zip_problem)

text_hygiene_ok = True
text_hygiene_problem = ""
for p in sorted(E.rglob("*")):
    if not p.is_file():
        continue
    rel = p.relative_to(E)
    if not rel.parts or not rel.parts[0].startswith("03A_"):
        continue
    if p.suffix.lower() not in {".md", ".txt", ".csv", ".py", ".patch"}:
        continue
    raw = p.read_bytes()
    if b"\r" in raw:
        text_hygiene_ok = False
        text_hygiene_problem = f"CR/CRLF: {p.relative_to(E)}"
        break
    text = raw.decode("utf-8", errors="strict")
    for n, line in enumerate(text.splitlines(), 1):
        if line.rstrip(" \t") != line:
            text_hygiene_ok = False
            text_hygiene_problem = f"trailing whitespace: {p.relative_to(E)}:{n}"
            break
    if not text_hygiene_ok:
        break
gate("all installable 03A text is LF-only and free of trailing whitespace", text_hygiene_ok, text_hygiene_problem)

# Simulate a real staging whitespace gate over the package tree. This catches
# historical-provenance text as well as active files, unlike git diff --check
# before untracked files are staged.
git_stage_ok = True
git_stage_problem = ""
git_bin = shutil.which("git")
if not git_bin:
    git_stage_ok = False
    git_stage_problem = "git executable not found"
else:
    with tempfile.TemporaryDirectory(prefix="03a-git-stage-") as td:
        td = Path(td)
        staged = td / "package"
        shutil.copytree(E.parent.parent, staged)
        cp = subprocess.run([git_bin, "init", "-q"], cwd=staged, capture_output=True, text=True)
        if cp.returncode != 0:
            git_stage_ok = False
            git_stage_problem = cp.stderr.strip()
        else:
            subprocess.run([git_bin, "add", "-A"], cwd=staged, check=True, capture_output=True, text=True)
            cp = subprocess.run([git_bin, "diff", "--cached", "--check"], cwd=staged, capture_output=True, text=True)
            if cp.returncode != 0:
                git_stage_ok = False
                git_stage_problem = (cp.stdout + cp.stderr).strip()[:1000]
gate("fresh staged Git whitespace simulation passes for the complete package", git_stage_ok, git_stage_problem)

manifest=read_csv(MANIFEST)
preservation=read_csv(PRESERVATION)
case_files=sorted(CASES.glob("*.md"))
master_text=MASTER.read_text(encoding="utf-8")
case_texts={p.name:p.read_text(encoding="utf-8") for p in case_files}

# Corpus counts/classes from accepted final manifest.
gate("manifest contains 257 substantive records", len(manifest)==257, str(len(manifest)))
gate("manifest IDs are unique", len({r['property_record_id'] for r in manifest})==257)
classes=Counter(r['status'] for r in manifest)
expected={
    'SUPPORTED':215,
    'SUPPORTED_WITH_PARTIAL_PRESERVATION':5,
    'RESOURCE_LIMITED_INCONCLUSIVE':16,
    'SUPPORTING_CONTROL':7,
    'SUPPORTED_DIAGNOSTIC':6,
    'ASSUMED_FROM_DOCUMENTED_GUARANTEE':4,
    'MEANINGFUL_NEGATIVE':2,
    'SUPPORTED_BY_CONSTRUCTION':1,
    'ABSTRACTION_LIMITED_INCONCLUSIVE':1,
}
gate("manifest result-class inventory is exact", classes==Counter(expected), repr(classes))
gate("supported subset remains 220", classes['SUPPORTED']+classes['SUPPORTED_WITH_PARTIAL_PRESERVATION']==220)
gate("scientific unresolved/negative subset remains 19", classes['RESOURCE_LIMITED_INCONCLUSIVE']+classes['ABSTRACTION_LIMITED_INCONCLUSIVE']+classes['MEANINGFUL_NEGATIVE']==19)

# Record structure.
gate("exactly 18 case/investigation files exist", len(case_files)==18, str(len(case_files)))
blocks={}; dups=[]
for fn,text in case_texts.items():
    for pid,pair in sections(text).items():
        if pid in blocks: dups.append(pid)
        blocks[pid]=(fn,pair[0],pair[1])
gate("case union contains exactly 257 record sections", len(blocks)==257, str(len(blocks)))
gate("no duplicate record sections", not dups, ",".join(dups))
gate("record ID set equals manifest ID set", set(blocks)=={r['property_record_id'] for r in manifest})

mandatory=[
    '### Formal statement','### What the property/control means','### Why it matters',
    '### Relationship to the principal claim','### Formal-support basis and evidential status',
    '### Exact experimental obligation and admitted domain','### Permitted conclusion and explicit boundary',
    '### Native-baseline relationship','### Thesis projection',
]
gate("all 257 records retain every required explanatory section", all(all(h in b[2] for h in mandatory) for b in blocks.values()))

# Current/historical path distinction.
hist=0; current=0; auth=0
for pid,(_,_,b) in blocks.items():
    if strip_ticks(md_value(b,'Historical RC2 public path resolution status'))=='PENDING': hist+=1
    if strip_ticks(md_value(b,'Current public path resolution status'))=='RESOLVED_HASH_MATCH': current+=1
    a=md_value(b,'Current public path/hash authority') or ''
    if '02_COMPLETE_PROPERTY_LEDGER.csv' in a and f'row `{pid}`' in a: auth+=1
gate("257/257 historical RC2 PENDING statuses are explicitly preserved", hist==257, str(hist))
gate("257/257 current path statuses are explicitly RESOLVED_HASH_MATCH", current==257, str(current))
gate("257/257 current path/hash statements point to their authoritative ledger rows", auth==257, str(auth))

# Mathematical preservation manifest.
gate("pre-GitHub math preservation manifest has 257 rows", len(preservation)==257, str(len(preservation)))
pmap={r['property_record_id']:r for r in preservation}
gate("math preservation ID set equals rendered record set", set(pmap)==set(blocks))
formal_ok=True; formal_problem=''; formal_count=0
for pid,(_,_,b) in blocks.items():
    a=b.find('### Formal statement'); z=b.find('### What the property/control means')
    m=re.search(r'\$\$(.*?)\$\$', b[a:z], flags=re.S)
    if not m:
        formal_ok=False; formal_problem=f'{pid}: missing display'; break
    formula=m.group(1).strip(); formal_count+=1
    row=pmap[pid]
    if sha_text(formula)!=row['github_safe_formal_statement_sha256']:
        formal_ok=False; formal_problem=f'{pid}: GitHub-safe formula hash changed'; break
    normalized=denorm(formula)
    if sha_text(normalized)!=row['pre_github_formal_statement_sha256'] or row['normalized_exact_match']!='YES':
        formal_ok=False; formal_problem=f'{pid}: normalized formula no longer equals accepted pre-fix formula'; break
gate("all 257 formal statements are cryptographically bound to the accepted pre-GitHub formulas", formal_ok and formal_count==257, formal_problem or str(formal_count))

# GitHub-safe math syntax.
texts=[master_text]+list(case_texts.values())
math=[x for t in texts for x in extract_math(t)]
mathop=sum(x.count(r'\mathop{\text{') for x in math)
gate("GitHub-blocked operator-name macro is absent", all(r'\operatorname{' not in t for t in texts))
gate("exactly 210 accepted named operators use GitHub-safe mathop/text rendering", mathop==210, str(mathop))
forbidden=[r'\\newcommand\b',r'\\renewcommand\b',r'\\DeclareMathOperator\b',r'\\def\b',r'\\require\b']
hits=[p for p in forbidden if any(re.search(p,x) for x in math)]
gate("no custom-definition/extension macros occur in math", not hits, ','.join(hits))
gate("all math braces are balanced", all(x.count('{')==x.count('}') for x in math), str(len(math)))
env_ok=all(re.findall(r'\\begin\{([^}]+)\}',x)==re.findall(r'\\end\{([^}]+)\}',x) for x in math)
gate("all math environments are balanced", env_ok)

# GitHub live-gate model guard. The REST Markdown endpoint is a Markdown-to-HTML
# smoke path, not a browser-side MathJax negative-control oracle. This gate prevents
# regression to RC2's invalid requirement that the REST endpoint itself expose the
# known web-UI operatorname rejection.
gh_validator=(E/"03A_VALIDATE_GITHUB_RENDER.py").read_text(encoding="utf-8")
defect_log=(E/"03A_FINAL_CLOSURE_DEFECT_AND_REPAIR_LOG.md").read_text(encoding="utf-8")
live_model_ok=(
    "bad_html = github_render" not in gh_validator
    and "positive control only" in gh_validator.lower()
    and "browser-side MathJax" in gh_validator
    and "GCR-15" in defect_log
)
gate("live GitHub REST gate is a smoke test, not an invalid MathJax negative oracle", live_model_ok)

# GCR-17 regression guard: porcelain-v1 XY columns are fixed-width and
# a leading blank must survive capture. In a standalone package, load and test
# the installer exactly. In an installed repository the standalone installer is
# intentionally absent, so this installer-specific regression gate is N/A;
# every repository/catalogue/evidence/math gate remains mandatory.
import importlib.util
installer_path=E.parent.parent/"03A_INSTALL_FINAL.py"

if installer_path.is_file():
    spec=importlib.util.spec_from_file_location(
        "03a_install_final_regression_guard",
        installer_path,
    )
    installer_mod=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(installer_mod)

    sample_status=" M README.md\n?? docs/thesis-evidence/03A_SAMPLE.md"
    parsed=installer_mod.parse_porcelain_paths(sample_status)

    gate(
        "installer preserves porcelain-v1 XY columns in exact-changeset parsing",
        parsed=={"README.md","docs/thesis-evidence/03A_SAMPLE.md"}
        and "git_raw" in installer_path.read_text(encoding="utf-8"),
        repr(sorted(parsed)),
    )
else:
    gate(
        "installer porcelain-v1 regression guard is applicable or explicitly N/A",
        True,
        "installed-repository mode: standalone 03A_INSTALL_FINAL.py is not retained",
    )

# Interpretation/current state guards.
gate("master is pinned to reconciled base commit", '4785f933dcf5c1fc5a1d6dae5af2211f98e66f1c' in master_text)
gate("master states published v1.1.0 and 18/257/573 resolved current state", '`v1.1.0` is already published' in master_text and '18/18 investigation locators' in master_text and '257/257 substantive property/control records' in master_text and '573/573 representative artefact records' in master_text)
gate("master preserves scientific/current-path distinction", 'repository publication/path resolution does not upgrade a scientific result' in master_text)

all_text='\n'.join(texts)
stale=[p for p in [r'required before repository installation',r'current public `main` still carries',r'release remains pending'] if re.search(p,all_text,re.I)]
gate("active catalogue has no stale pre-install/current-publication wording", not stale, ','.join(stale))

bad_hist=[]
for fn,t in [(MASTER.name,master_text)]+list(case_texts.items()):
    for i,line in enumerate(t.splitlines(),1):
        if 'PENDING' in line or 'UNRESOLVED_UNTIL_FINALIZER' in line:
            low=line.lower()
            if 'historical' not in low and 'frozen rc2' not in low:
                bad_hist.append(f'{fn}:{i}')
gate("PENDING/UNRESOLVED tokens occur only in explicitly historical RC2 context", not bad_hist, ','.join(bad_hist[:8]))

gate("Case-4 rendered correction is 1073741824 = 2^30 and no longer an install precondition", '1073741824=2^{30}' in blocks['PR-C04-013'][2] and 'current public CSV and Markdown ledger twins have already been corrected' in blocks['PR-C04-013'][2])

gate("no TODO/TBD/FIXME/XXX markers occur in active rendered catalogue", not re.search(r'(?im)\b(?:TODO|TBD|FIXME|XXX)\b',all_text))

# Optional local Pandoc/MathML parse gate if pandoc exists.
pandoc=shutil.which('pandoc')
if pandoc:
    pandoc_ok=True; pandoc_problem=''
    with tempfile.TemporaryDirectory(prefix='03a-pandoc-') as td:
        for p in [MASTER]+case_files:
            out=Path(td)/(p.stem+'.html')
            cp=subprocess.run([pandoc,str(p),'--from=gfm+tex_math_dollars','--to=html5','--mathml','-o',str(out)],capture_output=True,text=True)
            if cp.returncode!=0 or cp.stderr.strip():
                pandoc_ok=False; pandoc_problem=f'{p.name}: rc={cp.returncode} stderr={cp.stderr.strip()[:300]}'; break
    gate("Pandoc MathML parses all 19 rendered files without warnings", pandoc_ok, pandoc_problem)
else:
    gate("Pandoc MathML gate available", True, 'pandoc not installed; skipped in this environment')

# Package checksums if already generated.
if SUMS.exists():
    sum_ok=True; sum_problem=''; entries=0
    for line in SUMS.read_text(encoding='utf-8').splitlines():
        if not line.strip(): continue
        expected_hash, rel=line.split('  ',1); entries+=1
        p=E/rel
        if not p.is_file() or sha_file(p)!=expected_hash:
            sum_ok=False; sum_problem=rel; break
    gate("03A package checksum manifest verifies", sum_ok, f'entries={entries}' + (f' problem={sum_problem}' if sum_problem else ''))
else:
    gate("03A package checksum manifest present", False, str(SUMS))

print('\nSUMMARY')
print(f'checks={len(checks)} pass={sum(1 for _,ok,_ in checks if ok)} fail={len(failures)}')
if failures:
    print('\nFAILURES')
    for n,d in failures: print(f'- {n}: {d}')
    raise SystemExit(1)
print('FINAL 03A OFFLINE PACKAGE SELF-AUDIT: PASS')
