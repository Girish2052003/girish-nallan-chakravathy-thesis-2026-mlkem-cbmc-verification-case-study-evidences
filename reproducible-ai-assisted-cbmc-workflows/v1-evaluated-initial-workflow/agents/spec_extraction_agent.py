#!/usr/bin/env python3
"""
Specification Extraction Agent v2 (Agent 2)
===========================================

Thesis-agent-workflow Agent 2.

This upgraded version keeps the old Agent 2 interface and output contract while
adding two professor-grade capabilities:

1. Auto FIPS/local-standard section extraction
   - Can read a full cleaned standard/specification text file via `spec_source`.
   - Automatically finds and ranks relevant sections for the selected target.
   - Saves the selected candidate excerpt for human review and reproducibility.

2. FIPS-aware structured specification parsing
   - Parses prose, algorithms, symbols, numeric constants, parameter tables,
     inputs/outputs, loops, ranges, equations, constraints, and candidate proof
     obligations.

Important scientific guardrail
------------------------------
This agent produces candidate verification inputs. It does not prove ML-KEM,
FIPS 203, or any implementation. Every extracted assumption/guarantee is logged
with evidence and may require human review before being used for strong claims.

Backward compatibility
----------------------
The old controlled excerpt mode still works:

    "spec_file": "inputs/specs/mlkem_poly_add_excerpt.txt"

The new auto-search mode also works:

    "spec_mode": "auto_search",
    "spec_source": "inputs/specs/fips203_clean.txt",
    "auto_extract_spec_excerpt": true,
    "spec_search_terms": ["polynomial addition", "coefficients", "modulo q"]

Old outputs are preserved:
    01_spec_summary.json
    01_spec_summary.md
    llm_prompts/01_spec_extraction_prompt.txt
    agent_status/01_spec_extraction_status.json
    events.jsonl

New outputs are additive:
    selected_spec_excerpt.txt
    01_spec_sections_index.json
    01_algorithm_blocks.json
    01_symbol_table.json
    01_parameter_table.json
    01_equations_constraints.json
    01_preconditions_postconditions.json
    01_spec_to_code_hints.json

Python: 3.10+
Dependencies: standard library only; optional pypdf/PyPDF2 if reading PDFs.
"""

from __future__ import annotations

import argparse
import dataclasses
import datetime as _dt
import json
import math
import os
import re
import shlex
import subprocess
import sys
import textwrap
import traceback
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple


AGENT_NAME = "specification_extraction_agent_v2"
AGENT_NUMBER = 2
OUTPUT_PREFIX = "01"

SCIENTIFIC_GUARDRAIL = (
    "The extracted specification items are candidate verification inputs. "
    "They must not be treated as a complete proof or as a replacement for "
    "formal-tool checking and human review."
)

# Conservative aliases used only for retrieval/scoring. They do not create claims.
FUNCTION_ALIASES: Dict[str, List[str]] = {
    "poly_add": ["poly_add", "polynomial addition", "add polynomials", "addition of polynomials", "Add", "coefficients"],
    "poly_sub": ["poly_sub", "polynomial subtraction", "subtract polynomials", "subtraction of polynomials", "Sub", "coefficients"],
    "poly_reduce": ["poly_reduce", "reduce coefficients", "modulo q", "reduction", "Reduce"],
    "barrett_reduce": ["barrett_reduce", "Barrett", "Barrett reduction", "modulo q", "reduce"],
    "poly_tobytes": ["poly_tobytes", "encode", "Encode", "ByteEncode", "serialization", "compress", "bytes"],
    "poly_frombytes": ["poly_frombytes", "decode", "Decode", "ByteDecode", "deserialization", "bytes"],
    "poly_compress": ["poly_compress", "Compress", "compression", "d_u", "d_v"],
    "poly_decompress": ["poly_decompress", "Decompress", "decompression", "d_u", "d_v"],
    "poly_ntt": ["poly_ntt", "NTT", "number theoretic transform", "transform"],
    "poly_invntt_tomont": ["poly_invntt", "inverse NTT", "InvNTT", "inverse transform"],
    "poly_getnoise_eta1": ["noise", "eta1", "sample", "CBD", "centered binomial"],
    "poly_getnoise_eta2": ["noise", "eta2", "sample", "CBD", "centered binomial"],
    "mlkem_keygen": ["ML-KEM.KeyGen", "KeyGen", "key generation"],
    "mlkem_encaps": ["ML-KEM.Encaps", "Encaps", "encapsulation"],
    "mlkem_decaps": ["ML-KEM.Decaps", "Decaps", "decapsulation"],
}

KNOWN_MLKEM_SYMBOL_HINTS: Dict[str, str] = {
    "q": "ML-KEM modulus; commonly used for polynomial coefficients modulo q.",
    "n": "Number of coefficients / polynomial dimension in ML-KEM contexts.",
    "k": "Parameter-set dependent module rank / vector dimension in ML-KEM contexts.",
    "eta1": "Noise sampling parameter eta_1 for selected ML-KEM parameter sets.",
    "eta2": "Noise sampling parameter eta_2 for selected ML-KEM parameter sets.",
    "du": "Compression/encoding parameter d_u in ML-KEM contexts.",
    "dv": "Compression/encoding parameter d_v in ML-KEM contexts.",
    "A": "Matrix or public matrix-like object in ML-KEM/K-PKE descriptions.",
    "s": "Secret vector or polynomial/vector secret in ML-KEM/K-PKE descriptions.",
    "e": "Error/noise vector or polynomial in ML-KEM/K-PKE descriptions.",
    "t": "Public-key related vector/value in ML-KEM/K-PKE descriptions.",
    "u": "Ciphertext component in ML-KEM/K-PKE descriptions.",
    "v": "Ciphertext component in ML-KEM/K-PKE descriptions.",
}

# Words that tend to indicate formal-verification relevance.
FORMAL_RELEVANCE_TERMS = [
    "input", "output", "return", "algorithm", "step", "for", "while", "if", "else",
    "mod", "modulo", "coefficient", "coefficients", "polynomial", "vector", "matrix",
    "byte", "bytes", "encode", "decode", "compress", "decompress", "sample",
    "range", "bound", "bounds", "length", "array", "integer", "overflow",
    "shall", "must", "is defined", "set", "let", "where", "denote", "parameter",
]

HEADING_PATTERNS = [
    re.compile(r"^\s*(?:Section\s+)?(\d+(?:\.\d+){0,5})\s+(.{3,140})\s*$", re.IGNORECASE),
    re.compile(r"^\s*(Algorithm\s+\d+(?:\s*[:.-]\s*.*)?)\s*$", re.IGNORECASE),
    re.compile(r"^\s*(Table\s+\d+(?:\s*[:.-]\s*.*)?)\s*$", re.IGNORECASE),
    re.compile(r"^\s*(Appendix\s+[A-Z](?:\s*[:.-]\s*.*)?)\s*$", re.IGNORECASE),
]


# ---------------------------------------------------------------------------
# Data models
# ---------------------------------------------------------------------------

@dataclasses.dataclass
class Evidence:
    source_file: str
    start_line: int
    end_line: int
    text: str
    section_title: str = ""
    confidence: float = 0.0
    extraction_method: str = "deterministic"

    def to_dict(self) -> Dict[str, Any]:
        return dataclasses.asdict(self)


@dataclasses.dataclass
class Line:
    number: int
    text: str


@dataclasses.dataclass
class Section:
    id: str
    title: str
    start_line: int
    end_line: int
    text: str
    score: float = 0.0
    matched_terms: List[str] = dataclasses.field(default_factory=list)

    def evidence(self, source_file: str) -> Evidence:
        return Evidence(
            source_file=source_file,
            start_line=self.start_line,
            end_line=self.end_line,
            text=self.text[:1000],
            section_title=self.title,
            confidence=min(1.0, self.score / 20.0) if self.score else 0.0,
            extraction_method="section_scoring",
        )


# ---------------------------------------------------------------------------
# Basic IO utilities
# ---------------------------------------------------------------------------

def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    tmp.replace(path)


def read_json(path: Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


def append_jsonl(path: Path, data: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(data, ensure_ascii=False) + "\n")


def safe_name(value: str) -> str:
    out = []
    for ch in str(value).strip().lower():
        if ch.isalnum():
            out.append(ch)
        elif ch in {"_", "-", "."}:
            out.append(ch)
        elif ch.isspace() or ch in {"/", ":"}:
            out.append("_")
    return "".join(out).strip("._-") or "unknown"


def resolve_path(project_root: Path, value: str | os.PathLike[str]) -> Path:
    p = Path(value).expanduser()
    if not p.is_absolute():
        p = project_root / p
    return p.resolve()


def normalize_text(text: str) -> str:
    replacements = {
        "\u00a0": " ",
        "\u2010": "-",
        "\u2011": "-",
        "\u2012": "-",
        "\u2013": "-",
        "\u2014": "-",
        "\u2212": "-",
        "\u2217": "*",
        "\u00d7": "*",
        "\u22c5": "*",
        "\u2264": "<=",
        "\u2265": ">=",
        "\u2260": "!=",
        "\u2208": " in ",
        "\u2200": "for all ",
        "\u2227": " and ",
        "\u2228": " or ",
        "\u2190": "<-",
        "\u2192": "->",
        "\u21d0": "<=",
        "\u21d2": "=>",
        "\uf0b7": "-",
        "\u2022": "-",
        "\ufffd": "",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    # Normalize common PDF hyphenation across line breaks.
    text = re.sub(r"(\w)-\n(\w)", r"\1\2", text)
    return text


def read_docx_text(path: Path) -> str:
    paragraphs: List[str] = []
    with zipfile.ZipFile(path) as zf:
        xml_bytes = zf.read("word/document.xml")
    root = ET.fromstring(xml_bytes)
    ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
    for para in root.findall(".//w:p", ns):
        texts = [node.text or "" for node in para.findall(".//w:t", ns)]
        if texts:
            paragraphs.append("".join(texts))
    return "\n".join(paragraphs)


def read_pdf_text_optional(path: Path) -> str:
    """Best-effort PDF text extraction if pypdf/PyPDF2 is installed."""
    try:
        from pypdf import PdfReader  # type: ignore
        reader = PdfReader(str(path))
        return "\n".join(page.extract_text() or "" for page in reader.pages)
    except Exception:
        try:
            from PyPDF2 import PdfReader  # type: ignore
            reader = PdfReader(str(path))
            return "\n".join(page.extract_text() or "" for page in reader.pages)
        except Exception as exc:
            raise RuntimeError(
                f"Cannot read PDF directly without pypdf/PyPDF2. Convert the PDF to cleaned .txt first, or install pypdf. Original error: {exc}"
            ) from exc


def load_spec_text(path: Path) -> str:
    if not path.exists():
        raise FileNotFoundError(f"Specification source not found: {path}")
    suffix = path.suffix.lower()
    if suffix == ".docx":
        return normalize_text(read_docx_text(path))
    if suffix == ".json":
        data = read_json(path)
        for key in ["spec_text", "text", "excerpt", "content", "specification", "body"]:
            if isinstance(data, dict) and isinstance(data.get(key), str):
                return normalize_text(data[key])
        return normalize_text(json.dumps(data, indent=2, ensure_ascii=False))
    if suffix == ".pdf":
        return normalize_text(read_pdf_text_optional(path))
    return normalize_text(path.read_text(encoding="utf-8", errors="replace"))


def numbered_lines(text: str) -> List[Line]:
    return [Line(i + 1, line.rstrip()) for i, line in enumerate(text.splitlines())]


def get_line_range(lines: List[Line], start: int, end: int) -> str:
    selected = [ln.text for ln in lines if start <= ln.number <= end]
    return "\n".join(selected).strip()


# ---------------------------------------------------------------------------
# Config helpers
# ---------------------------------------------------------------------------

def infer_project_root(config_path: Path) -> Path:
    # Common layout: thesis-agent-workflow/configs/x.json
    if config_path.parent.name == "configs":
        return config_path.parent.parent.resolve()
    return config_path.parent.resolve()


def first_present(config: Dict[str, Any], keys: Sequence[str], default: Any = None) -> Any:
    for key in keys:
        cur: Any = config
        ok = True
        for part in key.split("."):
            if isinstance(cur, dict) and part in cur:
                cur = cur[part]
            else:
                ok = False
                break
        if ok and cur not in (None, "", []):
            return cur
    return default


def target_keywords(target_function: str, target_scheme: str = "", user_terms: Optional[List[str]] = None) -> List[str]:
    terms: List[str] = []
    tf = target_function or ""
    if tf:
        terms.append(tf)
        terms.extend([p for p in re.split(r"[_\W]+", tf) if len(p) >= 2])
        terms.extend(FUNCTION_ALIASES.get(tf, []))
    if target_scheme:
        terms.append(target_scheme)
        terms.extend([p for p in re.split(r"[-_\W]+", target_scheme) if len(p) >= 2])
    if user_terms:
        terms.extend([str(x) for x in user_terms if str(x).strip()])
    # Helpful ML-KEM default context, but low weight during scoring.
    if "poly" in tf.lower() or "kem" in target_scheme.lower() or "ml" in target_scheme.lower():
        terms.extend(["ML-KEM", "K-PKE", "polynomial", "coefficient", "modulo q", "q", "n"])
    # Deduplicate case-insensitively while preserving order.
    seen = set()
    out = []
    for term in terms:
        clean = re.sub(r"\s+", " ", str(term).strip())
        if not clean:
            continue
        key = clean.lower()
        if key not in seen:
            out.append(clean)
            seen.add(key)
    return out


# ---------------------------------------------------------------------------
# Section detection and auto extraction
# ---------------------------------------------------------------------------

def is_heading(line: str) -> Optional[str]:
    stripped = line.strip()
    if not stripped:
        return None
    if len(stripped) > 160:
        return None
    for pat in HEADING_PATTERNS:
        m = pat.match(stripped)
        if m:
            if len(m.groups()) >= 2:
                return f"{m.group(1)} {m.group(2)}".strip()
            return m.group(1).strip()
    # All-caps short headings, common in converted standards.
    if 4 <= len(stripped) <= 90 and stripped.upper() == stripped and re.search(r"[A-Z]", stripped):
        return stripped
    # Common heading words.
    if re.match(r"^\s*(Parameters|Symbols|Notation|Definitions|Algorithm|Inputs?|Outputs?|Preconditions?|Postconditions?)\b", stripped, re.I):
        return stripped
    return None


def split_sections(text: str) -> List[Section]:
    lines = numbered_lines(text)
    headings: List[Tuple[int, str]] = []
    for ln in lines:
        h = is_heading(ln.text)
        if h:
            headings.append((ln.number, h))

    if not headings:
        # Fallback: fixed-size windows of 80 lines.
        sections: List[Section] = []
        window = 80
        for start in range(1, len(lines) + 1, window):
            end = min(len(lines), start + window - 1)
            txt = get_line_range(lines, start, end)
            sections.append(Section(
                id=f"window_{start}_{end}",
                title=f"Lines {start}-{end}",
                start_line=start,
                end_line=end,
                text=txt,
            ))
        return sections

    sections = []
    for idx, (start_line, title) in enumerate(headings):
        end_line = headings[idx + 1][0] - 1 if idx + 1 < len(headings) else len(lines)
        if end_line < start_line:
            continue
        txt = get_line_range(lines, start_line, end_line)
        sections.append(Section(
            id=safe_name(title)[:80] or f"section_{idx+1}",
            title=title,
            start_line=start_line,
            end_line=end_line,
            text=txt,
        ))
    return sections


def score_section(section: Section, terms: List[str], target_function: str) -> Section:
    blob = f"{section.title}\n{section.text}".lower()
    score = 0.0
    matched: List[str] = []

    for term in terms:
        t = term.lower().strip()
        if not t:
            continue
        count = blob.count(t)
        if count:
            # Exact multi-word matches get more weight.
            weight = 4.0 if " " in t or "_" in t or "-" in t else 1.3
            if t == target_function.lower():
                weight += 5.0
            score += min(20.0, count * weight)
            matched.append(term)

    for rel in FORMAL_RELEVANCE_TERMS:
        if rel in blob:
            score += 0.4

    # Algorithm/table/parameter sections are highly relevant for professor feedback.
    if re.search(r"\balgorithm\b", blob):
        score += 4.0
    if re.search(r"\btable\b|\bparameters?\b", blob):
        score += 3.0
    if re.search(r"\binput\b|\boutput\b", blob):
        score += 2.0
    if re.search(r"\bfor\b.+\bto\b|\bfor\s+.*=|\breturn\b", blob):
        score += 2.0
    if re.search(r"\bmod\b|\bmodulo\b|<=|>=|=|<-", blob):
        score += 1.0

    section.score = round(score, 3)
    section.matched_terms = sorted(set(matched), key=lambda x: x.lower())
    return section


def rank_sections(sections: List[Section], terms: List[str], target_function: str) -> List[Section]:
    scored = [score_section(s, terms, target_function) for s in sections]
    return sorted(scored, key=lambda s: (s.score, -(s.end_line - s.start_line)), reverse=True)


def build_selected_excerpt(ranked: List[Section], lines: List[Line], max_sections: int = 3, context_lines: int = 8) -> Tuple[str, List[Dict[str, Any]]]:
    chosen = [s for s in ranked if s.score > 0][:max_sections]
    if not chosen and ranked:
        chosen = ranked[:1]

    chunks: List[str] = []
    selected_meta: List[Dict[str, Any]] = []
    used_ranges: List[Tuple[int, int]] = []

    for sec in chosen:
        start = max(1, sec.start_line - context_lines)
        end = min(len(lines), sec.end_line + context_lines)
        # Avoid duplicate overlapping chunks.
        if any(not (end < a or start > b) for a, b in used_ranges):
            continue
        used_ranges.append((start, end))
        chunk = get_line_range(lines, start, end)
        chunks.append(f"--- SELECTED SECTION: {sec.title} (lines {start}-{end}, score {sec.score}) ---\n{chunk}")
        selected_meta.append({
            "id": sec.id,
            "title": sec.title,
            "start_line": start,
            "end_line": end,
            "section_start_line": sec.start_line,
            "section_end_line": sec.end_line,
            "score": sec.score,
            "matched_terms": sec.matched_terms,
        })

    return "\n\n".join(chunks).strip(), selected_meta


# ---------------------------------------------------------------------------
# Parsing helpers
# ---------------------------------------------------------------------------

def evidence_from_line(source_file: str, line: Line, section_title: str = "", confidence: float = 0.65, method: str = "regex") -> Dict[str, Any]:
    return Evidence(
        source_file=source_file,
        start_line=line.number,
        end_line=line.number,
        text=line.text.strip(),
        section_title=section_title,
        confidence=confidence,
        extraction_method=method,
    ).to_dict()


def evidence_from_range(source_file: str, lines: List[Line], start: int, end: int, section_title: str = "", confidence: float = 0.65, method: str = "regex") -> Dict[str, Any]:
    return Evidence(
        source_file=source_file,
        start_line=start,
        end_line=end,
        text=get_line_range(lines, start, end)[:1500],
        section_title=section_title,
        confidence=confidence,
        extraction_method=method,
    ).to_dict()


def nearby_section_title(line_no: int, sections: List[Section]) -> str:
    for sec in sections:
        if sec.start_line <= line_no <= sec.end_line:
            return sec.title
    return ""


def parse_numeric_value(raw: str) -> Any:
    s = raw.strip().strip(".,;:)")
    # Remove thousands separators in numbers.
    s_clean = re.sub(r"(?<=\d),(?=\d)", "", s)
    if re.fullmatch(r"[-+]?\d+", s_clean):
        try:
            return int(s_clean)
        except Exception:
            return s
    if re.fullmatch(r"[-+]?\d+\.\d+", s_clean):
        try:
            return float(s_clean)
        except Exception:
            return s
    return s


def extract_constants(lines: List[Line], source_file: str, sections: List[Section]) -> Dict[str, Any]:
    constants: Dict[str, Any] = {}
    evidence: Dict[str, List[Dict[str, Any]]] = {}

    # Strong explicit assignments: q = 3329, n := 256, KYBER_N 256.
    patterns = [
        re.compile(r"\b([A-Za-z][A-Za-z0-9_\-]{0,30})\s*(?:=|:=|<-|is)\s*(-?\d+(?:\.\d+)?)\b"),
        re.compile(r"\b(?:modulus|module|prime)\s+([A-Za-z][A-Za-z0-9_]*)\s*(?:=|is)?\s*(-?\d+)\b", re.I),
        re.compile(r"\b([A-Za-z][A-Za-z0-9_\-]{0,30})\s+is\s+(?:set\s+to\s+)?(-?\d+)\b", re.I),
        re.compile(r"\b#define\s+([A-Za-z][A-Za-z0-9_]{0,40})\s+(-?\d+)\b"),
    ]

    for line in lines:
        text = line.text.strip()
        if not text or len(text) > 400:
            continue
        for pat in patterns:
            for m in pat.finditer(text):
                key = m.group(1).strip()
                val = parse_numeric_value(m.group(2))
                if len(key) > 40:
                    continue
                lowkey = key.lower()
                if lowkey in {"section", "algorithm", "table", "figure", "page"}:
                    continue
                constants[key] = val
                evidence.setdefault(key, []).append(evidence_from_line(source_file, line, nearby_section_title(line.number, sections), 0.78, "constant_regex"))

        # FIPS-style prose: q, the modulus, is 3329 / n is 256.
        for m in re.finditer(r"\b([qnk]|eta_?1|eta_?2|d_?u|d_?v)\b.{0,40}\b(?:is|=)\s*(-?\d+)\b", text, re.I):
            key = m.group(1).replace("_", "")
            constants[key] = parse_numeric_value(m.group(2))
            evidence.setdefault(key, []).append(evidence_from_line(source_file, line, nearby_section_title(line.number, sections), 0.72, "constant_prose_regex"))

    # Known ML-KEM values if evidence text mentions them exactly. We still store evidence.
    for line in lines:
        text = line.text
        for key, val in [("q", 3329), ("n", 256), ("N", 256)]:
            if re.search(rf"\b{re.escape(str(val))}\b", text) and re.search(rf"\b{re.escape(key)}\b|modulus|coefficients|degree|polynomial", text, re.I):
                constants.setdefault(key, val)
                evidence.setdefault(key, []).append(evidence_from_line(source_file, line, nearby_section_title(line.number, sections), 0.62, "known_value_evidence"))

    return {
        "values": constants,
        "evidence": evidence,
    }


def extract_parameter_tables(lines: List[Line], source_file: str, sections: List[Section]) -> List[Dict[str, Any]]:
    tables: List[Dict[str, Any]] = []
    current: List[Line] = []
    in_table = False

    def flush() -> None:
        nonlocal current, in_table
        if not current:
            return
        text = "\n".join(l.text for l in current)
        parsed_rows = parse_table_like_text(text)
        if parsed_rows or any(re.search(r"ML-KEM|parameter|Table|\|", l.text, re.I) for l in current):
            tables.append({
                "table_id": f"table_candidate_{len(tables)+1}",
                "start_line": current[0].number,
                "end_line": current[-1].number,
                "title_or_context": nearby_section_title(current[0].number, sections),
                "raw_text": text,
                "parsed_rows": parsed_rows,
                "evidence": evidence_from_range(source_file, current, current[0].number, current[-1].number, nearby_section_title(current[0].number, sections), 0.68, "parameter_table_detection"),
                "human_review_required": True,
            })
        current = []
        in_table = False

    for line in lines:
        text = line.text.rstrip()
        looks_table = (
            "|" in text
            or bool(re.search(r"\bML-KEM[- ]?(512|768|1024)\b", text, re.I))
            or bool(re.search(r"\b(parameter|parameters|Table\s+\d+)\b", text, re.I))
            or bool(re.search(r"\b(k|n|q|eta_?1|eta_?2|d_?u|d_?v)\b.*\b\d+\b", text))
        )
        if looks_table:
            current.append(line)
            in_table = True
        elif in_table and text.strip() and len(current) < 25 and re.search(r"\d", text):
            current.append(line)
        else:
            flush()
    flush()
    return tables


def parse_table_like_text(text: str) -> List[Dict[str, Any]]:
    rows: List[Dict[str, Any]] = []
    raw_lines = [l.strip() for l in text.splitlines() if l.strip()]
    # Pipe table parsing.
    pipe_lines = [l for l in raw_lines if "|" in l]
    if len(pipe_lines) >= 2:
        cells = [[c.strip() for c in l.strip("|").split("|")] for l in pipe_lines]
        header = cells[0]
        for row in cells[1:]:
            if len(row) != len(header) or all(re.fullmatch(r"[-: ]+", c) for c in row):
                continue
            rows.append({header[i]: parse_numeric_value(row[i]) for i in range(len(header))})
        if rows:
            return rows

    # Space-aligned ML-KEM rows: ML-KEM-512 2 3 2 ...
    for l in raw_lines:
        if re.search(r"ML-KEM[- ]?(512|768|1024)", l, re.I):
            parts = re.split(r"\s{2,}|\t+|\s+", l.strip())
            rows.append({
                "raw_row": l,
                "tokens": [parse_numeric_value(p) for p in parts],
                "parameter_set": next((p for p in parts if re.search(r"ML-KEM", p, re.I)), "unknown"),
            })
    return rows


def extract_symbol_table(lines: List[Line], source_file: str, sections: List[Section]) -> List[Dict[str, Any]]:
    symbols: Dict[str, Dict[str, Any]] = {}

    def add(symbol: str, meaning: str, line: Line, confidence: float, method: str) -> None:
        s = symbol.strip().strip(".,;:()[]{}")
        if not s or len(s) > 20:
            return
        entry = symbols.setdefault(s, {
            "symbol": s,
            "candidate_meanings": [],
            "evidence": [],
            "confidence": 0.0,
            "human_review_required": True,
        })
        if meaning and meaning not in entry["candidate_meanings"]:
            entry["candidate_meanings"].append(meaning[:300])
        entry["evidence"].append(evidence_from_line(source_file, line, nearby_section_title(line.number, sections), confidence, method))
        entry["confidence"] = max(float(entry["confidence"]), confidence)

    definition_patterns = [
        re.compile(r"\b(?:let|where|denote|denotes)\s+([A-Za-z][A-Za-z0-9_]{0,15})\s+(?:be|is|denote|denotes)\s+(.{3,160})", re.I),
        re.compile(r"\b([A-Za-z][A-Za-z0-9_]{0,15})\s+(?:denotes|is defined as|is the|is a|is an)\s+(.{3,160})", re.I),
        re.compile(r"\b([A-Za-z][A-Za-z0-9_]{0,15})\s*[:=]\s*(.{3,160})"),
    ]

    for line in lines:
        text = line.text.strip()
        if not text or len(text) > 500:
            continue
        for pat in definition_patterns:
            for m in pat.finditer(text):
                sym = m.group(1)
                meaning = m.group(2).strip()
                # Avoid swallowing algorithm/table headings as definitions.
                if sym.lower() in {"input", "output", "return", "algorithm", "table", "section"}:
                    continue
                add(sym, meaning, line, 0.70, "symbol_definition_regex")
        for sym, hint in KNOWN_MLKEM_SYMBOL_HINTS.items():
            if re.search(rf"\b{re.escape(sym)}\b", text):
                # Add only if the line is spec-relevant, not random prose.
                if re.search(r"modulus|polynomial|coefficient|parameter|matrix|vector|secret|error|ciphertext|compression|ML-KEM|K-PKE|encode|decode", text, re.I):
                    add(sym, hint, line, 0.45, "known_mlkem_symbol_hint")

    return sorted(symbols.values(), key=lambda x: (x["symbol"].lower()))


def extract_algorithm_blocks(lines: List[Line], source_file: str, sections: List[Section]) -> List[Dict[str, Any]]:
    blocks: List[Tuple[int, int, str]] = []
    starts: List[Tuple[int, str]] = []

    for line in lines:
        text = line.text.strip()
        if re.match(r"^(Algorithm\s+\d+|[A-Za-z0-9_.-]+\s*\([^)]*\)|[A-Za-z0-9_.-]+\s*:)\b", text, re.I):
            if re.search(r"Algorithm|Input|Output|ML-KEM|K-PKE|Encode|Decode|Compress|Decompress|KeyGen|Encaps|Decaps|NTT|Sample", text, re.I):
                starts.append((line.number, text[:120]))

    # Also detect algorithm-like Input/Output regions.
    for line in lines:
        if re.match(r"^\s*Input\s*:", line.text, re.I):
            starts.append((line.number, "Input/Output algorithm-like block"))

    starts = sorted(set(starts), key=lambda x: x[0])
    for idx, (start, title) in enumerate(starts):
        end = min(len(lines), start + 80)
        if idx + 1 < len(starts):
            end = min(end, starts[idx + 1][0] - 1)
        # Stop at next heading if near.
        for ln in range(start + 1, end + 1):
            line_text = lines[ln - 1].text if 0 <= ln - 1 < len(lines) else ""
            h = is_heading(line_text)
            if h and ln > start + 3:
                end = ln - 1
                break
        if end >= start:
            blocks.append((start, end, title))

    parsed: List[Dict[str, Any]] = []
    seen_ranges = set()
    for start, end, title in blocks:
        key = (start, end)
        if key in seen_ranges:
            continue
        seen_ranges.add(key)
        text = get_line_range(lines, start, end)
        if len(text.strip()) < 30:
            continue
        parsed.append(parse_algorithm_block(text, start, end, title, source_file, lines, sections))
    return parsed


def parse_algorithm_block(text: str, start: int, end: int, title: str, source_file: str, lines: List[Line], sections: List[Section]) -> Dict[str, Any]:
    block_lines = numbered_lines(text)
    # Convert block-local line numbers to original line numbers when creating evidence.
    def orig(local_no: int) -> int:
        return start + local_no - 1

    inputs: List[Dict[str, Any]] = []
    outputs: List[Dict[str, Any]] = []
    steps: List[Dict[str, Any]] = []
    loops: List[Dict[str, Any]] = []
    assignments: List[Dict[str, Any]] = []
    returns: List[Dict[str, Any]] = []
    conditions: List[Dict[str, Any]] = []

    for bl in block_lines:
        raw = bl.text.strip()
        if not raw:
            continue
        original_line = Line(orig(bl.number), raw)
        ev = evidence_from_line(source_file, original_line, nearby_section_title(orig(bl.number), sections), 0.70, "algorithm_parser")

        m_in = re.match(r"^(Input|Inputs)\s*:\s*(.+)$", raw, re.I)
        m_out = re.match(r"^(Output|Outputs)\s*:\s*(.+)$", raw, re.I)
        if m_in:
            inputs.append({"raw": m_in.group(2).strip(), "symbols": extract_symbols_from_expression(m_in.group(2)), "evidence": ev})
            continue
        if m_out:
            outputs.append({"raw": m_out.group(2).strip(), "symbols": extract_symbols_from_expression(m_out.group(2)), "evidence": ev})
            continue

        if re.match(r"^(for|while)\b", raw, re.I):
            loops.append(parse_loop_line(raw, ev))
        if re.match(r"^if\b", raw, re.I):
            conditions.append({"condition": raw, "evidence": ev})
        if re.search(r"(<-|:=|=)", raw) and not re.match(r"^(Input|Output)\b", raw, re.I):
            parsed_assignment = parse_assignment_line(raw, ev)
            if parsed_assignment:
                assignments.append(parsed_assignment)
        if re.match(r"^return\b", raw, re.I):
            returns.append({"raw": raw, "symbols": extract_symbols_from_expression(raw), "evidence": ev})
        if re.match(r"^(\d+\.|[a-z]\)|-)\s*", raw) or any(tok in raw.lower() for tok in ["for", "return", "set", "compute", "sample"]):
            steps.append({"raw": raw, "evidence": ev})

    return {
        "algorithm_id": safe_name(title)[:80] or f"algorithm_lines_{start}_{end}",
        "title": title,
        "start_line": start,
        "end_line": end,
        "raw_text": text,
        "inputs": inputs,
        "outputs": outputs,
        "steps": steps,
        "loops": loops,
        "assignments": assignments,
        "conditions": conditions,
        "returns": returns,
        "evidence": evidence_from_range(source_file, lines, start, end, nearby_section_title(start, sections), 0.72, "algorithm_block_detection"),
        "human_review_required": True,
    }


def extract_symbols_from_expression(expr: str) -> List[str]:
    candidates = re.findall(r"\b[A-Za-z][A-Za-z0-9_]{0,20}\b", expr)
    stop = {"Input", "Output", "return", "for", "from", "to", "mod", "and", "or", "if", "then", "else", "the", "a", "an", "of", "in", "is", "be"}
    out: List[str] = []
    for c in candidates:
        if c not in stop and c.lower() not in {s.lower() for s in stop} and c not in out:
            out.append(c)
    return out


def parse_loop_line(raw: str, evidence: Dict[str, Any]) -> Dict[str, Any]:
    patterns = [
        re.compile(r"for\s+([A-Za-z][A-Za-z0-9_]*)\s+(?:from|=)\s*([^\s,;]+)\s+(?:to|;\s*\1\s*[<]=?)\s*([^\s,;:]+)", re.I),
        re.compile(r"for\s+([A-Za-z][A-Za-z0-9_]*)\s*\(?\s*=\s*([^;]+);\s*\1\s*([<]=?)\s*([^;]+);", re.I),
    ]
    for pat in patterns:
        m = pat.search(raw)
        if m:
            if len(m.groups()) >= 4 and m.group(3) in {"<", "<="}:
                return {
                    "raw": raw,
                    "variable": m.group(1).strip(),
                    "lower_bound": m.group(2).strip(),
                    "comparison": m.group(3).strip(),
                    "upper_bound": m.group(4).strip(),
                    "evidence": evidence,
                }
            return {
                "raw": raw,
                "variable": m.group(1).strip(),
                "lower_bound": m.group(2).strip(),
                "upper_bound": m.group(3).strip(),
                "evidence": evidence,
            }
    return {"raw": raw, "variable": None, "lower_bound": None, "upper_bound": None, "evidence": evidence}


def parse_assignment_line(raw: str, evidence: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    m = re.search(r"(.+?)\s*(<-|:=|=)\s*(.+)", raw)
    if not m:
        return None
    lhs = m.group(1).strip().lstrip("0123456789. )-").strip()
    op = m.group(2).strip()
    rhs = m.group(3).strip().rstrip(".;")
    if not lhs or not rhs:
        return None
    return {
        "raw": raw,
        "lhs": lhs,
        "operator": op,
        "rhs": rhs,
        "lhs_symbols": extract_symbols_from_expression(lhs),
        "rhs_symbols": extract_symbols_from_expression(rhs),
        "evidence": evidence,
    }


def extract_equations_constraints(lines: List[Line], source_file: str, sections: List[Section]) -> Dict[str, Any]:
    equations: List[Dict[str, Any]] = []
    constraints: List[Dict[str, Any]] = []
    ranges: List[Dict[str, Any]] = []

    mathy = re.compile(r"(?:<=|>=|!=|=|<-|:=|\bmod\b|\bmodulo\b|\+|-|\*|/|\^|\[|\])")
    range_pat = re.compile(r"(-?\d+)\s*(?:<=|≤)\s*([A-Za-z][A-Za-z0-9_\[\]]*)\s*(?:<|<=|≤)\s*(-?\d+|[A-Za-z][A-Za-z0-9_]*)")
    simple_range_pat = re.compile(r"\b([A-Za-z][A-Za-z0-9_\[\]]*)\s*(?:<|<=|>|>=)\s*(-?\d+|[A-Za-z][A-Za-z0-9_]*)")

    for line in lines:
        text = line.text.strip()
        if not text or len(text) > 500:
            continue
        ev = evidence_from_line(source_file, line, nearby_section_title(line.number, sections), 0.62, "math_constraint_regex")
        if mathy.search(text) and re.search(r"[A-Za-z]", text) and not re.match(r"^(http|www|Table of Contents)", text, re.I):
            item = {
                "raw": text,
                "symbols": extract_symbols_from_expression(text),
                "evidence": ev,
                "human_review_required": True,
            }
            if re.search(r"\bmod\b|\bmodulo\b", text, re.I):
                item["kind"] = "modular_arithmetic"
            elif re.search(r"<=|>=|<|>", text):
                item["kind"] = "inequality_or_range"
            elif re.search(r"<-|:=|=", text):
                item["kind"] = "assignment_or_equation"
            else:
                item["kind"] = "math_expression"
            equations.append(item)

        for m in range_pat.finditer(text):
            ranges.append({
                "raw": m.group(0),
                "lower": parse_numeric_value(m.group(1)),
                "symbol": m.group(2),
                "upper": parse_numeric_value(m.group(3)),
                "evidence": ev,
            })
        for m in simple_range_pat.finditer(text):
            constraints.append({
                "raw": m.group(0),
                "symbol": m.group(1),
                "bound": parse_numeric_value(m.group(2)),
                "evidence": ev,
            })

    return {
        "equations": equations,
        "constraints": constraints,
        "ranges": ranges,
    }


def extract_preconditions_postconditions(lines: List[Line], source_file: str, sections: List[Section]) -> Dict[str, Any]:
    pre: List[Dict[str, Any]] = []
    post: List[Dict[str, Any]] = []
    guarantees: List[Dict[str, Any]] = []
    assumptions: List[Dict[str, Any]] = []

    for line in lines:
        text = line.text.strip()
        if not text:
            continue
        low = text.lower()
        ev = evidence_from_line(source_file, line, nearby_section_title(line.number, sections), 0.66, "prepost_keyword_regex")
        if re.search(r"\b(input|requires?|precondition|given|assume|valid|shall be|must be)\b", low):
            pre.append({"claim": text, "evidence": ev, "human_review_required": True})
        if re.search(r"\b(output|returns?|result|guarantee|ensures?|postcondition|produces|shall output|must output)\b", low):
            post.append({"claim": text, "evidence": ev, "human_review_required": True})
        if re.search(r"\b(shall|must|required|is defined as|is set to)\b", low):
            guarantees.append({"claim": text, "evidence": ev, "human_review_required": True})
        if re.search(r"\b(assuming|assume|provided that|where|given)\b", low):
            assumptions.append({"claim": text, "evidence": ev, "human_review_required": True})

    return {
        "preconditions": pre,
        "postconditions": post,
        "guarantees": guarantees,
        "assumptions": assumptions,
    }


# ---------------------------------------------------------------------------
# Build old-compatible summary outputs
# ---------------------------------------------------------------------------

def build_input_assumptions(parsed: Dict[str, Any], target_function: str) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    constants = parsed["constants"].get("values", {})
    n_val = constants.get("N", constants.get("n"))
    q_val = constants.get("q")

    if n_val is not None:
        out.append({
            "assumption": f"Polynomial/vector coefficient arrays relevant to {target_function} should respect the extracted length/dimension value n/N = {n_val}, where applicable.",
            "source": "derived_from_extracted_constant",
            "evidence": parsed["constants"].get("evidence", {}).get("N") or parsed["constants"].get("evidence", {}).get("n", []),
            "confidence": 0.70,
            "human_review_required": True,
        })
    if q_val is not None:
        out.append({
            "assumption": f"Operations involving coefficients may be interpreted modulo q = {q_val} only when the selected specification section supports modular arithmetic for this target.",
            "source": "derived_from_extracted_constant",
            "evidence": parsed["constants"].get("evidence", {}).get("q", []),
            "confidence": 0.62,
            "human_review_required": True,
        })

    for item in parsed["prepost"].get("preconditions", [])[:20]:
        out.append({
            "assumption": item["claim"],
            "source": "precondition_keyword_extraction",
            "evidence": [item["evidence"]],
            "confidence": item["evidence"].get("confidence", 0.6),
            "human_review_required": True,
        })
    # Deduplicate by assumption text.
    seen = set()
    dedup: List[Dict[str, Any]] = []
    for item in out:
        key = item["assumption"].lower()
        if key not in seen:
            dedup.append(item)
            seen.add(key)
    return dedup


def build_output_guarantees(parsed: Dict[str, Any], target_function: str) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for alg in parsed["algorithm_blocks"]:
        for ret in alg.get("returns", []):
            out.append({
                "guarantee": f"Algorithm block returns/outputs: {ret.get('raw')}",
                "source": "algorithm_return_parser",
                "evidence": [ret.get("evidence")],
                "confidence": 0.68,
                "human_review_required": True,
            })
        for assignment in alg.get("assignments", [])[:20]:
            out.append({
                "guarantee": f"Algorithm assignment candidate: {assignment.get('lhs')} {assignment.get('operator')} {assignment.get('rhs')}",
                "source": "algorithm_assignment_parser",
                "evidence": [assignment.get("evidence")],
                "confidence": 0.64,
                "human_review_required": True,
            })
    for item in parsed["prepost"].get("postconditions", [])[:20]:
        out.append({
            "guarantee": item["claim"],
            "source": "postcondition_keyword_extraction",
            "evidence": [item["evidence"]],
            "confidence": item["evidence"].get("confidence", 0.6),
            "human_review_required": True,
        })
    seen = set()
    dedup: List[Dict[str, Any]] = []
    for item in out:
        key = item["guarantee"].lower()
        if key not in seen:
            dedup.append(item)
            seen.add(key)
    return dedup


def build_candidate_safety_properties(parsed: Dict[str, Any], target_function: str, verification_tool: str) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    constants = parsed["constants"].get("values", {})
    n_val = constants.get("N", constants.get("n"))
    q_val = constants.get("q")

    if n_val is not None:
        out.append({
            "property": f"For {target_function}, loops/indexing over polynomial coefficients should stay within the extracted dimension n/N = {n_val} where the implementation uses coefficient arrays.",
            "type": "array_bounds_or_loop_bound",
            "formal_tool_hint": verification_tool,
            "evidence": parsed["constants"].get("evidence", {}).get("N") or parsed["constants"].get("evidence", {}).get("n", []),
            "priority": "high",
            "confidence": 0.70,
            "human_review_required": True,
        })
    if q_val is not None:
        out.append({
            "property": f"For {target_function}, coefficient arithmetic involving modular reduction should be checked against q = {q_val} when supported by the selected spec/code mapping.",
            "type": "range_or_modular_arithmetic",
            "formal_tool_hint": verification_tool,
            "evidence": parsed["constants"].get("evidence", {}).get("q", []),
            "priority": "medium",
            "confidence": 0.62,
            "human_review_required": True,
        })
    for alg in parsed["algorithm_blocks"]:
        for loop in alg.get("loops", [])[:10]:
            out.append({
                "property": f"Loop/index variable in algorithm block should respect parsed loop bounds: {loop.get('raw')}",
                "type": "loop_bound",
                "formal_tool_hint": verification_tool,
                "evidence": [loop.get("evidence")],
                "priority": "high",
                "confidence": 0.68,
                "human_review_required": True,
            })
    return out


def build_candidate_functional_properties(parsed: Dict[str, Any], target_function: str, verification_tool: str) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for alg in parsed["algorithm_blocks"]:
        for assign in alg.get("assignments", [])[:25]:
            rhs = str(assign.get("rhs", ""))
            lhs = str(assign.get("lhs", ""))
            ptype = "functional_assignment_relation"
            if re.search(r"\bmod\b|modulo", rhs, re.I):
                ptype = "functional_modular_relation"
            elif re.search(r"Encode|Decode|Compress|Decompress", rhs + lhs, re.I):
                ptype = "functional_encoding_relation"
            out.append({
                "property": f"Candidate relation from specification algorithm: {lhs} {assign.get('operator')} {rhs}",
                "type": ptype,
                "formal_tool_hint": verification_tool,
                "evidence": [assign.get("evidence")],
                "priority": "medium",
                "confidence": 0.64,
                "human_review_required": True,
            })
    for eq in parsed["equations_constraints"].get("equations", [])[:25]:
        if eq.get("kind") in {"assignment_or_equation", "modular_arithmetic"}:
            out.append({
                "property": f"Candidate equation/constraint from specification: {eq.get('raw')}",
                "type": eq.get("kind"),
                "formal_tool_hint": verification_tool,
                "evidence": [eq.get("evidence")],
                "priority": "medium",
                "confidence": 0.55,
                "human_review_required": True,
            })
    return out


def build_spec_to_code_hints(parsed: Dict[str, Any], target_function: str, source_file: Optional[str] = None) -> Dict[str, Any]:
    constants = parsed["constants"].get("values", {})
    hints = {
        "target_function": target_function,
        "source_file": source_file,
        "candidate_macro_mappings": [],
        "candidate_field_mappings": [],
        "candidate_loop_bounds": [],
        "candidate_cbmc_assumptions": [],
        "candidate_cbmc_assertions": [],
        "human_review_required": True,
        "notes": [
            "These hints are not proof obligations by themselves.",
            "They are bridge material for the Property Discovery and Artifact Generation agents.",
        ],
    }
    n_val = constants.get("N", constants.get("n"))
    q_val = constants.get("q")
    if n_val is not None:
        hints["candidate_macro_mappings"].append({"spec_symbol": "n/N", "value": n_val, "possible_code_names": ["KYBER_N", "MLKEM_N", "MLK_N", "N"]})
        hints["candidate_loop_bounds"].append({"bound": n_val, "cbmc_unwind_hint": int(n_val) if isinstance(n_val, int) else n_val})
        hints["candidate_cbmc_assumptions"].append("Polynomial coefficient arrays should be allocated/valid for n/N elements where applicable.")
    if q_val is not None:
        hints["candidate_macro_mappings"].append({"spec_symbol": "q", "value": q_val, "possible_code_names": ["KYBER_Q", "MLKEM_Q", "MLK_Q", "Q"]})
        hints["candidate_cbmc_assumptions"].append("Any coefficient range assumptions involving q must be justified by the selected function context.")
    for sym in parsed["symbol_table"]:
        if sym.get("symbol") in {"r", "a", "b", "c", "u", "v", "s", "e", "t"}:
            hints["candidate_field_mappings"].append({
                "spec_symbol": sym.get("symbol"),
                "candidate_meanings": sym.get("candidate_meanings", [])[:3],
                "possible_code_fields": ["coeffs", "vec", "polyvec", "bytes"],
            })
    return hints


def build_uncertainties(parsed: Dict[str, Any], mode: str, target_function: str) -> List[Dict[str, Any]]:
    uncertainties: List[Dict[str, Any]] = []
    constants = parsed["constants"].get("values", {})
    if not constants:
        uncertainties.append({
            "uncertainty": "No numeric constants were extracted from the selected specification material.",
            "severity": "medium",
            "suggested_action": "Check whether the selected excerpt includes parameter definitions or provide a more relevant spec_source/spec_file.",
        })
    if not parsed["algorithm_blocks"]:
        uncertainties.append({
            "uncertainty": "No algorithm-like block was detected. The selected section may be prose-only or converted text may need cleanup.",
            "severity": "medium",
            "suggested_action": "Use a cleaned FIPS text source and ensure algorithm headings/Input/Output lines are preserved.",
        })
    if mode == "auto_search":
        selected = parsed.get("selected_sections", [])
        if not selected:
            uncertainties.append({
                "uncertainty": "Auto-search mode did not find a clearly relevant section.",
                "severity": "high",
                "suggested_action": "Add spec_search_terms or use controlled spec_file mode for this run.",
            })
        elif max((s.get("score", 0) for s in selected), default=0) < 5:
            uncertainties.append({
                "uncertainty": "Auto-selected section has low relevance score.",
                "severity": "medium",
                "suggested_action": "Human review should confirm selected_spec_excerpt.txt before relying on extracted facts.",
            })
    uncertainties.append({
        "uncertainty": f"Mapping between FIPS-level symbols/algorithms and implementation function '{target_function}' requires Code Understanding Agent and human review.",
        "severity": "normal",
        "suggested_action": "Use Agent 3 and Agent 4 to connect extracted spec facts to actual code behavior.",
    })
    return uncertainties


def build_rejected_claims(target_function: str) -> List[Dict[str, Any]]:
    return [
        {
            "claim": f"The function {target_function} is fully correct because the specification excerpt was parsed.",
            "reason": "Specification parsing only produces candidate verification inputs; it is not a proof.",
        },
        {
            "claim": "The AI workflow proves full ML-KEM correctness automatically.",
            "reason": "The thesis scope is selected artifacts/properties checked by formal tools under assumptions, with human review.",
        },
        {
            "claim": "Every extracted FIPS symbol/algorithm mapping is flawless.",
            "reason": "FIPS parsing is logged with confidence/evidence and requires review for high-assurance claims.",
        },
    ]


# ---------------------------------------------------------------------------
# Optional LLM hook
# ---------------------------------------------------------------------------

def maybe_call_external_llm(config: Dict[str, Any], prompt: str) -> Optional[Dict[str, Any]]:
    settings = config.get("spec_extraction_settings", {}) if isinstance(config, dict) else {}
    if not isinstance(settings, dict) or not settings.get("use_external_llm"):
        return None
    cmd = settings.get("llm_command")
    if not cmd:
        return None
    if isinstance(cmd, str):
        cmd_list = shlex.split(cmd)
    else:
        cmd_list = [str(x) for x in cmd]
    try:
        proc = subprocess.run(cmd_list, input=prompt, text=True, capture_output=True, timeout=int(settings.get("timeout_seconds", 120)))
        if proc.returncode != 0:
            return {"llm_error": proc.stderr[:2000], "llm_returncode": proc.returncode}
        try:
            return json.loads(proc.stdout)
        except json.JSONDecodeError:
            return {"llm_error": "LLM command returned non-JSON output", "raw_output_preview": proc.stdout[:2000]}
    except Exception as exc:
        return {"llm_error": str(exc)}


# ---------------------------------------------------------------------------
# Main agent implementation
# ---------------------------------------------------------------------------

class SpecExtractionAgentV2:
    def __init__(self, config_path: Path, run_dir: Optional[Path] = None) -> None:
        self.config_path = config_path.resolve()
        self.config = read_json(self.config_path)
        self.project_root = infer_project_root(self.config_path)
        self.run_dir = (run_dir.resolve() if run_dir else self._infer_run_dir())
        self.run_dir.mkdir(parents=True, exist_ok=True)

        self.target_function = str(first_present(self.config, ["target_function", "function", "target.function"], "unknown_function"))
        self.target_scheme = str(first_present(self.config, ["target_scheme", "scheme", "target.scheme"], "unknown_scheme"))
        self.verification_tool = str(first_present(self.config, ["verification_tool", "tool"], "CBMC"))
        self.source_file = str(first_present(self.config, ["source_file", "code_file", "target.source_file"], ""))

        self.spec_file_raw = first_present(self.config, ["spec_file", "spec.excerpt_file", "specification_file"], None)
        self.spec_source_raw = first_present(self.config, ["spec_source", "spec.source", "fips_source", "full_spec_file"], None)
        self.auto_extract = bool(first_present(self.config, ["auto_extract_spec_excerpt", "spec.auto_extract", "spec_extraction_settings.auto_extract_spec_excerpt"], False))
        self.spec_mode = str(first_present(self.config, ["spec_mode", "spec.mode", "spec_extraction_settings.mode"], "auto_search" if self.auto_extract else "controlled_excerpt"))
        user_terms = first_present(self.config, ["spec_search_terms", "spec.search_terms", "spec_extraction_settings.search_terms"], [])
        if not isinstance(user_terms, list):
            user_terms = [str(user_terms)]
        self.search_terms = target_keywords(self.target_function, self.target_scheme, user_terms)

        self.events_path = self.run_dir / "events.jsonl"
        self.prompt_dir = self.run_dir / "llm_prompts"
        self.status_dir = self.run_dir / "agent_status"

    def _infer_run_dir(self) -> Path:
        run_dir = first_present(self.config, ["run_dir", "output.run_dir", "paths.run_dir"], None)
        if run_dir:
            return resolve_path(self.project_root, str(run_dir))
        run_id = str(first_present(self.config, ["run_id", "experiment.run_id"], f"run_001_{safe_name(self.target_function if hasattr(self, 'target_function') else 'unknown')}"))
        output_root = str(first_present(self.config, ["output_root", "runs_dir", "paths.runs_dir"], "runs"))
        return resolve_path(self.project_root, output_root) / run_id

    def choose_input(self) -> Tuple[Path, str, str]:
        """Return path, text, mode."""
        if self.spec_mode.lower() in {"auto", "auto_search", "fips_auto", "section_search"} or self.auto_extract:
            if not self.spec_source_raw:
                if self.spec_file_raw:
                    # Soft fallback: use spec_file as source if user set auto mode accidentally.
                    source_path = resolve_path(self.project_root, str(self.spec_file_raw))
                else:
                    raise ValueError("Auto spec extraction requires 'spec_source' or fallback 'spec_file'.")
            else:
                source_path = resolve_path(self.project_root, str(self.spec_source_raw))
            text = load_spec_text(source_path)
            return source_path, text, "auto_search"

        if not self.spec_file_raw:
            if self.spec_source_raw:
                source_path = resolve_path(self.project_root, str(self.spec_source_raw))
                text = load_spec_text(source_path)
                return source_path, text, "auto_search"
            raise ValueError("Config must include either 'spec_file' or 'spec_source'.")
        source_path = resolve_path(self.project_root, str(self.spec_file_raw))
        text = load_spec_text(source_path)
        return source_path, text, "controlled_excerpt"

    def build_prompt(self, source_path: Path, mode: str, selected_excerpt: str) -> str:
        return textwrap.dedent(f"""
        You are assisting formal verification of PQC implementation code.

        Agent: Specification Extraction Agent v2
        Target scheme: {self.target_scheme}
        Target function: {self.target_function}
        Verification tool: {self.verification_tool}
        Mode: {mode}
        Specification source: {source_path}

        Task:
        1. Extract constants/numeric parameters.
        2. Extract FIPS-style algorithm blocks, inputs, outputs, steps, loops, assignments, returns.
        3. Extract symbols and candidate meanings.
        4. Extract equations, ranges, and constraints.
        5. Extract preconditions and postconditions.
        6. Produce candidate safety and functional properties.
        7. Link claims to evidence lines.
        8. Mark uncertainty and human-review needs.
        9. Do not claim proof of full ML-KEM or full implementation correctness.

        Scientific guardrail:
        {SCIENTIFIC_GUARDRAIL}

        Selected excerpt preview:
        {selected_excerpt[:4000]}
        """).strip() + "\n"

    def run(self) -> Dict[str, Any]:
        append_jsonl(self.events_path, {
            "timestamp": utc_now(),
            "agent": AGENT_NAME,
            "event": "started",
            "target_function": self.target_function,
            "spec_mode": self.spec_mode,
        })

        source_path, full_text, mode = self.choose_input()
        if not full_text.strip():
            raise ValueError(f"Specification source is empty after loading: {source_path}")

        full_lines = numbered_lines(full_text)
        sections = split_sections(full_text)
        ranked = rank_sections(sections, self.search_terms, self.target_function)

        selected_sections: List[Dict[str, Any]] = []
        if mode == "auto_search":
            max_sections = int(first_present(self.config, ["spec_max_sections", "spec_extraction_settings.max_sections"], 3))
            context_lines = int(first_present(self.config, ["spec_context_lines", "spec_extraction_settings.context_lines"], 8))
            selected_text, selected_sections = build_selected_excerpt(ranked, full_lines, max_sections=max_sections, context_lines=context_lines)
            if not selected_text.strip():
                selected_text = full_text[:8000]
            write_text(self.run_dir / "selected_spec_excerpt.txt", selected_text + "\n")
            parse_text = selected_text
            parse_source_file = str(source_path)
        else:
            parse_text = full_text
            write_text(self.run_dir / "selected_spec_excerpt.txt", parse_text + "\n")
            # In controlled mode, whole file is the selected excerpt.
            selected_sections = [{
                "id": "controlled_excerpt",
                "title": source_path.name,
                "start_line": 1,
                "end_line": len(full_lines),
                "score": None,
                "matched_terms": [],
            }]
            parse_source_file = str(source_path)

        parse_lines = numbered_lines(parse_text)
        parse_sections = split_sections(parse_text)

        parsed: Dict[str, Any] = {
            "mode": mode,
            "source_path": str(source_path),
            "selected_sections": selected_sections,
            "sections_index": [dataclasses.asdict(s) for s in ranked[:50]],
            "constants": extract_constants(parse_lines, parse_source_file, parse_sections),
            "parameter_tables": extract_parameter_tables(parse_lines, parse_source_file, parse_sections),
            "symbol_table": extract_symbol_table(parse_lines, parse_source_file, parse_sections),
            "algorithm_blocks": extract_algorithm_blocks(parse_lines, parse_source_file, parse_sections),
            "equations_constraints": extract_equations_constraints(parse_lines, parse_source_file, parse_sections),
            "prepost": extract_preconditions_postconditions(parse_lines, parse_source_file, parse_sections),
        }
        parsed["spec_to_code_hints"] = build_spec_to_code_hints(parsed, self.target_function, self.source_file)

        input_assumptions = build_input_assumptions(parsed, self.target_function)
        output_guarantees = build_output_guarantees(parsed, self.target_function)
        safety_properties = build_candidate_safety_properties(parsed, self.target_function, self.verification_tool)
        functional_properties = build_candidate_functional_properties(parsed, self.target_function, self.verification_tool)
        uncertainties = build_uncertainties(parsed, mode, self.target_function)
        rejected_claims = build_rejected_claims(self.target_function)

        prompt = self.build_prompt(source_path, mode, parse_text)
        write_text(self.prompt_dir / "01_spec_extraction_prompt.txt", prompt)
        llm_result = maybe_call_external_llm(self.config, prompt)

        summary: Dict[str, Any] = {
            "agent": AGENT_NAME,
            "agent_number": AGENT_NUMBER,
            "generated_at": utc_now(),
            "target_scheme": self.target_scheme,
            "target_function": self.target_function,
            "verification_tool": self.verification_tool,
            "spec_mode": mode,
            "spec_file": str(source_path),
            "spec_source": str(source_path),
            "selected_excerpt_file": "selected_spec_excerpt.txt",
            "scientific_guardrail": SCIENTIFIC_GUARDRAIL,
            # Old-compatible keys expected by later agents.
            "constants": parsed["constants"].get("values", {}),
            "constant_evidence": parsed["constants"].get("evidence", {}),
            "input_assumptions": input_assumptions,
            "candidate_output_guarantees": output_guarantees,
            "candidate_safety_properties": safety_properties,
            "candidate_functional_properties": functional_properties,
            "artifact_hints": parsed["spec_to_code_hints"],
            "uncertainties": uncertainties,
            "rejected_claims": rejected_claims,
            # New v2 structured parsing outputs summarized here.
            "fips_aware_parsing": {
                "sections_detected": len(sections),
                "selected_sections": selected_sections,
                "algorithm_blocks_detected": len(parsed["algorithm_blocks"]),
                "symbol_entries_detected": len(parsed["symbol_table"]),
                "parameter_table_candidates_detected": len(parsed["parameter_tables"]),
                "equation_candidates_detected": len(parsed["equations_constraints"].get("equations", [])),
                "range_candidates_detected": len(parsed["equations_constraints"].get("ranges", [])),
                "human_review_required": True,
            },
            "traceability_files": {
                "sections_index": "01_spec_sections_index.json",
                "algorithm_blocks": "01_algorithm_blocks.json",
                "symbol_table": "01_symbol_table.json",
                "parameter_table": "01_parameter_table.json",
                "equations_constraints": "01_equations_constraints.json",
                "preconditions_postconditions": "01_preconditions_postconditions.json",
                "spec_to_code_hints": "01_spec_to_code_hints.json",
            },
            "external_llm_result": llm_result,
            "human_review_required": True,
        }

        # Additive v2 outputs.
        write_json(self.run_dir / "01_spec_sections_index.json", {
            "source_path": str(source_path),
            "target_function": self.target_function,
            "search_terms": self.search_terms,
            "selected_sections": selected_sections,
            "ranked_sections": [dataclasses.asdict(s) for s in ranked[:100]],
            "human_review_required": True,
        })
        write_json(self.run_dir / "01_algorithm_blocks.json", {
            "algorithm_blocks": parsed["algorithm_blocks"],
            "human_review_required": True,
        })
        write_json(self.run_dir / "01_symbol_table.json", {
            "symbol_table": parsed["symbol_table"],
            "human_review_required": True,
        })
        write_json(self.run_dir / "01_parameter_table.json", {
            "parameter_tables": parsed["parameter_tables"],
            "human_review_required": True,
        })
        write_json(self.run_dir / "01_equations_constraints.json", parsed["equations_constraints"])
        write_json(self.run_dir / "01_preconditions_postconditions.json", parsed["prepost"])
        write_json(self.run_dir / "01_spec_to_code_hints.json", parsed["spec_to_code_hints"])

        # Old outputs preserved.
        write_json(self.run_dir / "01_spec_summary.json", summary)
        write_text(self.run_dir / "01_spec_summary.md", render_markdown(summary, parsed))

        status = {
            "agent": AGENT_NAME,
            "agent_number": AGENT_NUMBER,
            "status": "completed",
            "generated_at": utc_now(),
            "target_function": self.target_function,
            "spec_mode": mode,
            "outputs": [
                "selected_spec_excerpt.txt",
                "01_spec_summary.json",
                "01_spec_summary.md",
                "01_spec_sections_index.json",
                "01_algorithm_blocks.json",
                "01_symbol_table.json",
                "01_parameter_table.json",
                "01_equations_constraints.json",
                "01_preconditions_postconditions.json",
                "01_spec_to_code_hints.json",
                "llm_prompts/01_spec_extraction_prompt.txt",
            ],
            "human_review_required": True,
            "guardrail": SCIENTIFIC_GUARDRAIL,
        }
        write_json(self.status_dir / "01_spec_extraction_status.json", status)

        append_jsonl(self.events_path, {
            "timestamp": utc_now(),
            "agent": AGENT_NAME,
            "event": "completed",
            "target_function": self.target_function,
            "spec_mode": mode,
            "algorithm_blocks": len(parsed["algorithm_blocks"]),
            "symbols": len(parsed["symbol_table"]),
            "constants": len(parsed["constants"].get("values", {})),
            "human_review_required": True,
        })

        print(f"[OK] Specification Extraction Agent v2 wrote: {self.run_dir / '01_spec_summary.json'}")
        print(f"[OK] Selected excerpt: {self.run_dir / 'selected_spec_excerpt.txt'}")
        print(f"[OK] Algorithm blocks: {len(parsed['algorithm_blocks'])}; symbols: {len(parsed['symbol_table'])}; constants: {len(parsed['constants'].get('values', {}))}")
        print("[NOTE] Extracted items are candidate verification inputs; human/code review is still required.")
        return summary


def render_markdown(summary: Dict[str, Any], parsed: Dict[str, Any]) -> str:
    constants = summary.get("constants", {})
    selected = summary.get("fips_aware_parsing", {}).get("selected_sections", [])

    def bullet(items: List[Any], key: str) -> str:
        if not items:
            return "- None detected."
        out = []
        for item in items[:20]:
            if isinstance(item, dict):
                out.append(f"- {item.get(key) or item.get('claim') or item.get('property') or item.get('guarantee') or str(item)[:200]}")
            else:
                out.append(f"- {item}")
        return "\n".join(out)

    selected_lines = "\n".join(
        f"- `{s.get('title')}` lines {s.get('start_line')}-{s.get('end_line')} score={s.get('score')} terms={s.get('matched_terms')}"
        for s in selected[:10]
    ) or "- Controlled excerpt mode or no selected sections recorded."

    alg_lines = "\n".join(
        f"- `{a.get('title')}` lines {a.get('start_line')}-{a.get('end_line')} inputs={len(a.get('inputs', []))} outputs={len(a.get('outputs', []))} assignments={len(a.get('assignments', []))}"
        for a in parsed.get("algorithm_blocks", [])[:20]
    ) or "- None detected."

    symbol_lines = "\n".join(
        f"- `{s.get('symbol')}`: {', '.join(s.get('candidate_meanings', [])[:2])}"
        for s in parsed.get("symbol_table", [])[:30]
    ) or "- None detected."

    return f"""# Specification Extraction Summary v2

Generated: `{summary.get('generated_at')}`

## Scientific Guardrail

{summary.get('scientific_guardrail')}

## Target

- Scheme: `{summary.get('target_scheme')}`
- Function: `{summary.get('target_function')}`
- Tool: `{summary.get('verification_tool')}`
- Mode: `{summary.get('spec_mode')}`
- Source: `{summary.get('spec_file')}`

## Selected / Candidate Sections

{selected_lines}

## Extracted Constants

```json
{json.dumps(constants, indent=2, ensure_ascii=False)}
```

## Algorithm Blocks Parsed

{alg_lines}

## Symbol Table Preview

{symbol_lines}

## Input Assumptions / Preconditions

{bullet(summary.get('input_assumptions', []), 'assumption')}

## Output Guarantees / Postconditions

{bullet(summary.get('candidate_output_guarantees', []), 'guarantee')}

## Candidate Safety Properties

{bullet(summary.get('candidate_safety_properties', []), 'property')}

## Candidate Functional Properties

{bullet(summary.get('candidate_functional_properties', []), 'property')}

## Uncertainties

{bullet(summary.get('uncertainties', []), 'uncertainty')}

## Traceability Files

- `selected_spec_excerpt.txt`
- `01_spec_sections_index.json`
- `01_algorithm_blocks.json`
- `01_symbol_table.json`
- `01_parameter_table.json`
- `01_equations_constraints.json`
- `01_preconditions_postconditions.json`
- `01_spec_to_code_hints.json`

## Thesis-Safe Meaning

This agent parsed specification material into structured candidate verification inputs. These outputs are designed for Agent 4 and Agent 5, but they still require human review before strong correctness claims are made.
"""


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Agent 2 v2: FIPS-aware Specification Extraction Agent.")
    parser.add_argument("--config", required=True, help="Path to workflow config JSON.")
    parser.add_argument("--run-dir", default=None, help="Run directory where outputs should be written.")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    config_path = Path(args.config)
    run_dir = Path(args.run_dir) if args.run_dir else None
    try:
        agent = SpecExtractionAgentV2(config_path=config_path, run_dir=run_dir)
        agent.run()
        return 0
    except Exception as exc:
        # Best-effort status logging.
        try:
            config = read_json(config_path)
            project_root = infer_project_root(config_path.resolve())
            rd_raw = first_present(config, ["run_dir", "output.run_dir", "paths.run_dir"], None)
            if run_dir:
                rd = run_dir.resolve()
            elif rd_raw:
                rd = resolve_path(project_root, str(rd_raw))
            else:
                run_id = str(first_present(config, ["run_id", "experiment.run_id"], "run_unknown"))
                output_root = str(first_present(config, ["output_root", "runs_dir", "paths.runs_dir"], "runs"))
                rd = resolve_path(project_root, output_root) / run_id
            rd.mkdir(parents=True, exist_ok=True)
            write_json(rd / "agent_status" / "01_spec_extraction_status.json", {
                "agent": AGENT_NAME,
                "agent_number": AGENT_NUMBER,
                "status": "failed",
                "generated_at": utc_now(),
                "error": str(exc),
                "traceback": traceback.format_exc(limit=8),
                "human_review_required": True,
            })
            append_jsonl(rd / "events.jsonl", {
                "timestamp": utc_now(),
                "agent": AGENT_NAME,
                "event": "failed",
                "error": str(exc),
            })
        except Exception:
            pass
        print(f"[ERROR] Specification Extraction Agent v2 failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
