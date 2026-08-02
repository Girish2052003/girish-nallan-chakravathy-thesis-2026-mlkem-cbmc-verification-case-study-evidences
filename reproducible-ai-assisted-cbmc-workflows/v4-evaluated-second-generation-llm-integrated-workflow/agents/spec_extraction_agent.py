#!/usr/bin/env python3
"""
spec_extraction_agent_refactored.py

Agent 2 — Specification Extraction Agent, refactored for the new thesis workflow.

This version implements the agreed architecture:

- Python reads local specification material and creates deterministic reference artefacts.
- Deterministic artefacts are advisory only, never authoritative.
- Python builds a strict prompt package.
- The shared LLM client produces the authoritative stage candidate output.
- The authoritative output is saved under:
    stages/02_spec_extraction/llm_authoritative/01_spec_summary.json
- The next stage receives only manifest-based handoff pointers.
- No root-level output dumping.
- No duplicate copies.

Trust boundary:
- The LLM output is the authoritative stage candidate output for downstream agents.
- It is not proof, not verification, not FIPS compliance, and not implementation correctness.
- CBMC/formal-tool evidence is handled later by deterministic tool stages.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import traceback
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple, Union


# ---------------------------------------------------------------------------
# Import path hardening
# ---------------------------------------------------------------------------

THIS_FILE = Path(__file__).resolve()
PROJECT_ROOT = THIS_FILE.parents[1] if THIS_FILE.parent.name == "agents" else Path.cwd()
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))


try:
    from agents.common.run_layout import RunLayout, atomic_write_json, atomic_write_text, ensure_dir
    from agents.common.config_contract import load_normalized_config
    from agents.common.experiment_protocol import semantic_advisory_enabled
    from agents.common.llm_client import LLMClient, LLMStageRequest, LLMMode, record_llm_stage_failure
    from agents.common.prompt_templates import build_common_stage_prompt
    from agents.common.schemas import SPEC_SUMMARY_SCHEMA
except Exception as import_exc:  # pragma: no cover
    raise SystemExit(
        "Failed to import shared workflow modules. Ensure these files exist:\n"
        "  agents/common/run_layout.py\n"
        "  agents/common/llm_client.py\n"
        "  agents/common/prompt_templates.py\n"
        "  agents/common/schemas.py\n"
        f"Original import error: {type(import_exc).__name__}: {import_exc}"
    )


JsonDict = Dict[str, Any]
PathLike = Union[str, Path]


# ---------------------------------------------------------------------------
# General helpers
# ---------------------------------------------------------------------------

def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def read_json_file(path: PathLike) -> JsonDict:
    p = Path(path)
    with p.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected JSON object in {p}")
    return data


def safe_read_text(path: PathLike, *, max_chars: Optional[int] = None) -> str:
    p = Path(path)
    text = p.read_text(encoding="utf-8", errors="replace")
    if max_chars is not None and len(text) > max_chars:
        return text[:max_chars] + "\n\n[TRUNCATED_BY_SPEC_EXTRACTION_AGENT]\n"
    return text


def file_metadata(path: PathLike) -> JsonDict:
    p = Path(path)
    if not p.exists():
        return {"path": str(p), "exists": False}
    stat = p.stat()
    return {
        "path": str(p),
        "exists": True,
        "name": p.name,
        "suffix": p.suffix,
        "size_bytes": stat.st_size,
        "modified_time_utc": datetime.fromtimestamp(stat.st_mtime, timezone.utc).isoformat(),
    }


def compact_whitespace(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def make_line_records(text: str) -> List[JsonDict]:
    return [
        {"line": i + 1, "text": line.rstrip("\n")}
        for i, line in enumerate(text.splitlines())
    ]


def parse_list_arg(value: Optional[str]) -> List[str]:
    if not value:
        return []
    # Accept comma-separated or semicolon-separated values.
    parts = re.split(r"[,;]", value)
    return [p.strip() for p in parts if p.strip()]


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

@dataclass
class SpecExtractionConfig:
    run_dir: Path
    spec_paths: List[Path]
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM polynomial addition"
    discovery_mode: str = "targeted_campaign"
    property_family_id: str = "P16"
    property_family_title: str = "Polynomial addition/subtraction bounds"
    verification_strategy: str = "standard_cbmc_harness"
    property_claim_boundary: str = "Property-specific candidate evidence only."
    max_spec_chars_for_deterministic: int = 500_000
    max_excerpt_chars: int = 120_000
    excerpt_context_lines: int = 8
    llm_mode_override: Optional[str] = None
    write_stage_status: bool = True
    allow_empty_handoff_on_failure: bool = True

    # Search terms guide deterministic reference only.
    focus_terms: List[str] = None  # type: ignore

    def __post_init__(self) -> None:
        if self.focus_terms is None:
            self.focus_terms = [
                "ML-KEM",
                "Kyber",
                "polynomial",
                "polynomial addition",
                "coefficient",
                "coefficients",
                "q",
                "3329",
                "n",
                "256",
                "Z_q",
                "R_q",
                "mod",
                "modulo",
                "field",
                "array",
                "vector",
                "encoding",
                "decoding",
                "Compress",
                "Decompress",
                "NTT",
                "addition",
                "subtraction",
            ]


def resolve_run_dir(config_data: JsonDict, args: argparse.Namespace) -> Path:
    if args.run_dir:
        return Path(args.run_dir).expanduser().resolve()

    for key in ["run_dir", "output_dir"]:
        if config_data.get(key):
            return Path(str(config_data[key])).expanduser().resolve()

    run = config_data.get("run", {})
    if isinstance(run, dict):
        for key in ["run_dir", "output_dir"]:
            if run.get(key):
                return Path(str(run[key])).expanduser().resolve()

    runs_dir = Path(str(config_data.get("runs_dir", "runs"))).expanduser()
    run_id = str(config_data.get("run_id", "run_001_refactored"))
    return (runs_dir / run_id).resolve()


def resolve_spec_paths(config_data: JsonDict, args: argparse.Namespace) -> List[Path]:
    paths: List[Path] = []

    if args.spec_path:
        paths.extend(Path(p).expanduser().resolve() for p in parse_list_arg(args.spec_path))

    # Support several config shapes.
    inputs = config_data.get("inputs", {})
    if isinstance(inputs, dict):
        for key in [
            "spec_path",
            "spec_file",
            "fips_text_path",
            "fips203_text_path",
            "fips_pdf_path",
            "selected_spec_excerpt",
            "selected_spec_excerpt_path",
        ]:
            value = inputs.get(key)
            if value:
                paths.append(Path(str(value)).expanduser().resolve())

        value = inputs.get("spec_paths")
        if isinstance(value, list):
            paths.extend(Path(str(v)).expanduser().resolve() for v in value)

        specs = inputs.get("specs")
        if isinstance(specs, list):
            paths.extend(Path(str(v)).expanduser().resolve() for v in specs)

    for key in ["spec_path", "fips_text_path", "fips203_text_path", "fips_pdf_path"]:
        if config_data.get(key):
            paths.append(Path(str(config_data[key])).expanduser().resolve())

    # De-duplicate preserving order.
    seen = set()
    unique: List[Path] = []
    for p in paths:
        key = str(p)
        if key not in seen:
            unique.append(p)
            seen.add(key)

    return unique


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, SpecExtractionConfig]:
    config_data: JsonDict = {}
    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        config_data = load_normalized_config(config_path)

    run_dir = resolve_run_dir(config_data, args)
    spec_paths = resolve_spec_paths(config_data, args)

    if not spec_paths:
        raise ValueError(
            "No specification path provided. Use --spec-path or config inputs.spec_path/fips_text_path."
        )

    target_function = (
        args.target_function
        or str(config_data.get("target_function") or "")
        or str(config_data.get("function_name") or "")
        or "mlk_poly_add"
    )

    target_topic = (
        args.target_topic
        or str(config_data.get("target_topic") or "")
        or f"ML-KEM specification context for {target_function}"
    )

    focus_terms = parse_list_arg(args.focus_terms)
    if not focus_terms:
        cfg_terms = (
            config_data.get("spec_extraction", {}).get("focus_terms")
            if isinstance(config_data.get("spec_extraction"), dict)
            else None
        )
        if isinstance(cfg_terms, list):
            focus_terms = [str(x) for x in cfg_terms]

    campaign = config_data.get("property_campaign", {}) if isinstance(config_data.get("property_campaign"), dict) else {}
    cfg = SpecExtractionConfig(
        run_dir=run_dir,
        spec_paths=spec_paths,
        target_function=target_function,
        target_topic=target_topic,
        discovery_mode=str((config_data.get("property_discovery") or {}).get("mode") or "targeted_campaign"),
        property_family_id=str(campaign.get("property_family_id") or "P16"),
        property_family_title=str(campaign.get("property_family_title") or "Polynomial addition/subtraction bounds"),
        verification_strategy=str(campaign.get("verification_strategy") or "standard_cbmc_harness"),
        property_claim_boundary=str(campaign.get("claim_boundary") or "Property-specific candidate evidence only."),
        llm_mode_override=args.llm_mode,
        focus_terms=focus_terms or None,  # type: ignore
    )
    return config_data, cfg


# ---------------------------------------------------------------------------
# Specification reading
# ---------------------------------------------------------------------------

def read_pdf_text(path: PathLike) -> Tuple[str, JsonDict]:
    """
    Best-effort PDF text extraction.

    For full thesis-grade PDF handling, prefer providing a pre-cleaned text file.
    This fallback supports common local setups with pypdf/PyPDF2.
    """
    p = Path(path)
    extraction_meta: JsonDict = {
        "path": str(p),
        "method": None,
        "success": False,
        "warnings": [],
    }

    try:
        try:
            from pypdf import PdfReader  # type: ignore
            method = "pypdf"
        except Exception:
            from PyPDF2 import PdfReader  # type: ignore
            method = "PyPDF2"

        reader = PdfReader(str(p))
        pages = []
        for idx, page in enumerate(reader.pages):
            try:
                pages.append(f"\n[PDF_PAGE {idx + 1} BEGIN]\n{page.extract_text() or ''}\n[PDF_PAGE {idx + 1} END]\n")
            except Exception as exc:
                pages.append(f"\n[PDF_PAGE {idx + 1} EXTRACTION_FAILED: {exc}]\n")
        extraction_meta.update({
            "method": method,
            "success": True,
            "page_count": len(reader.pages),
        })
        return "\n".join(pages), extraction_meta

    except Exception as exc:
        extraction_meta.update({
            "method": "pypdf_or_PyPDF2",
            "success": False,
            "warnings": [
                "Could not extract PDF text locally. The PDF can still be supplied as primary evidence to the LLM client if supported.",
                f"{type(exc).__name__}: {exc}",
            ],
        })
        return "", extraction_meta


def read_spec_material(paths: Sequence[Path], *, max_chars: int) -> Tuple[str, JsonDict]:
    texts: List[str] = []
    records: List[JsonDict] = []

    for path in paths:
        p = Path(path)
        meta = file_metadata(p)
        if not p.exists():
            meta["read_success"] = False
            meta["warnings"] = ["File not found."]
            records.append(meta)
            continue

        suffix = p.suffix.lower()
        if suffix == ".pdf":
            text, pdf_meta = read_pdf_text(p)
            meta["read_success"] = bool(text)
            meta["pdf_extraction"] = pdf_meta
            if text:
                texts.append(f"\n===== SPEC SOURCE BEGIN: {p} =====\n{text}\n===== SPEC SOURCE END: {p} =====\n")
        else:
            try:
                text = safe_read_text(p, max_chars=max_chars)
                meta["read_success"] = True
                meta["local_text_chars_used"] = len(text)
                texts.append(f"\n===== SPEC SOURCE BEGIN: {p} =====\n{text}\n===== SPEC SOURCE END: {p} =====\n")
            except Exception as exc:
                meta["read_success"] = False
                meta["warnings"] = [f"{type(exc).__name__}: {exc}"]
        records.append(meta)

    return "\n".join(texts), {
        "source_records": records,
        "combined_text_chars": sum(len(t) for t in texts),
        "combined_text_available": bool(texts),
    }


# ---------------------------------------------------------------------------
# Deterministic reference extraction
# ---------------------------------------------------------------------------

SECTION_RE = re.compile(
    r"^\s*(?P<number>(?:\d+)(?:\.\d+){0,4})\s+(?P<title>[A-Z][A-Za-z0-9 ,;:/()_\-\[\]–—]+)\s*$"
)

ALGORITHM_RE = re.compile(
    r"\bAlgorithm\s+(?P<number>\d+)\b[:.\s-]*(?P<title>[^\n]*)",
    re.IGNORECASE
)

CONSTANT_PATTERNS = [
    re.compile(r"\b(?P<symbol>q)\s*(?:=|:=|is)\s*(?P<value>3329)\b", re.IGNORECASE),
    re.compile(r"\b(?P<symbol>n)\s*(?:=|:=|is)\s*(?P<value>256)\b", re.IGNORECASE),
    re.compile(r"\b(?P<symbol>k)\s*(?:=|:=|is)\s*(?P<value>[234])\b", re.IGNORECASE),
    re.compile(r"\b(?P<symbol>eta_?[12]|η_?[12])\s*(?:=|:=|is)\s*(?P<value>\d+)\b", re.IGNORECASE),
    re.compile(r"\b(?P<symbol>d[uv]?)\s*(?:=|:=|is)\s*(?P<value>\d+)\b", re.IGNORECASE),
]

MATH_LINE_HINTS = [
    "=", "≤", ">=", "≥", "<", ">", "mod", "modulo", "Z_q", "Zq", "R_q",
    "polynomial", "coefficient", "coefficients", "bound", "range", "Compress", "Decompress",
]

PREPOST_HINTS = [
    "Input", "Output", "Require", "Requires", "Ensure", "Ensures", "Returns",
    "shall", "must", "valid", "invalid", "reject", "accept"
]


def find_sections(line_records: Sequence[JsonDict]) -> List[JsonDict]:
    sections: List[JsonDict] = []
    for rec in line_records:
        line = rec["text"].strip()
        m = SECTION_RE.match(line)
        if m:
            sections.append({
                "line": rec["line"],
                "section_number": m.group("number"),
                "title": m.group("title").strip(),
                "raw": line,
                "trust_boundary": "deterministic_reference_advisory_only",
            })
    return sections


def find_algorithm_blocks(line_records: Sequence[JsonDict], *, max_lines_per_block: int = 80) -> List[JsonDict]:
    starts: List[Tuple[int, JsonDict]] = []
    for idx, rec in enumerate(line_records):
        m = ALGORITHM_RE.search(rec["text"])
        if m:
            starts.append((idx, {
                "start_line": rec["line"],
                "algorithm_number": m.group("number"),
                "title": compact_whitespace(m.group("title") or ""),
            }))

    blocks: List[JsonDict] = []
    for i, (idx, info) in enumerate(starts):
        next_idx = starts[i + 1][0] if i + 1 < len(starts) else min(len(line_records), idx + max_lines_per_block)
        end_idx = min(next_idx, idx + max_lines_per_block)
        block_lines = line_records[idx:end_idx]
        text = "\n".join(f"{r['line']}: {r['text']}" for r in block_lines)
        blocks.append({
            **info,
            "end_line": block_lines[-1]["line"] if block_lines else info["start_line"],
            "text_excerpt": text,
            "trust_boundary": "deterministic_reference_advisory_only",
        })
    return blocks


def score_line_for_focus(line: str, terms: Sequence[str]) -> int:
    low = line.lower()
    score = 0
    for term in terms:
        t = term.lower()
        if t and t in low:
            score += 3 if len(t) > 3 else 1
    if any(x in low for x in ["algorithm", "input", "output", "coefficient", "polynomial", "mod", "shall"]):
        score += 2
    if re.search(r"\b(3329|256|128|384|768|1024)\b", line):
        score += 2
    return score


def select_relevant_excerpt(
    line_records: Sequence[JsonDict],
    *,
    focus_terms: Sequence[str],
    context_lines: int,
    max_chars: int,
) -> Tuple[str, List[JsonDict]]:
    hits = []
    for idx, rec in enumerate(line_records):
        score = score_line_for_focus(rec["text"], focus_terms)
        if score > 0:
            hits.append((idx, score))

    # Prefer high-score lines and keep order after selecting windows.
    hits_sorted = sorted(hits, key=lambda x: x[1], reverse=True)
    selected_indices = set()
    selected_hits: List[JsonDict] = []

    for idx, score in hits_sorted:
        if len(selected_indices) > max_chars // 40:
            break
        start = max(0, idx - context_lines)
        end = min(len(line_records), idx + context_lines + 1)
        for j in range(start, end):
            selected_indices.add(j)
        selected_hits.append({
            "line": line_records[idx]["line"],
            "score": score,
            "text": line_records[idx]["text"],
        })

    ordered = sorted(selected_indices)
    chunks = []
    current_chars = 0
    last_idx = None

    for idx in ordered:
        rec = line_records[idx]
        if last_idx is not None and idx != last_idx + 1:
            chunks.append("\n[... omitted unrelated lines ...]\n")
        line_text = f"{rec['line']}: {rec['text']}"
        current_chars += len(line_text) + 1
        if current_chars > max_chars:
            chunks.append("\n[TRUNCATED_SELECTED_SPEC_EXCERPT]\n")
            break
        chunks.append(line_text)
        last_idx = idx

    return "\n".join(chunks), selected_hits[:200]


def extract_symbol_table(line_records: Sequence[JsonDict]) -> List[JsonDict]:
    candidates: Dict[str, JsonDict] = {}

    symbol_terms = [
        "ML-KEM", "K-PKE", "q", "n", "k", "du", "dv", "η1", "η2", "eta1", "eta2",
        "Z_q", "R_q", "polynomial", "coefficient", "Compress", "Decompress",
        "Encode", "Decode", "NTT"
    ]

    for rec in line_records:
        text = rec["text"]
        for term in symbol_terms:
            if term.lower() in text.lower():
                key = term
                item = candidates.setdefault(key, {
                    "symbol_or_term": key,
                    "first_seen_line": rec["line"],
                    "evidence_lines": [],
                    "trust_boundary": "deterministic_reference_advisory_only",
                })
                if len(item["evidence_lines"]) < 5:
                    item["evidence_lines"].append({
                        "line": rec["line"],
                        "text": text.strip(),
                    })

        for pat in CONSTANT_PATTERNS:
            m = pat.search(text)
            if m:
                symbol = m.group("symbol")
                item = candidates.setdefault(symbol, {
                    "symbol_or_term": symbol,
                    "first_seen_line": rec["line"],
                    "evidence_lines": [],
                    "possible_values": [],
                    "trust_boundary": "deterministic_reference_advisory_only",
                })
                item.setdefault("possible_values", [])
                val = m.group("value")
                if val not in item["possible_values"]:
                    item["possible_values"].append(val)
                if len(item["evidence_lines"]) < 5:
                    item["evidence_lines"].append({
                        "line": rec["line"],
                        "text": text.strip(),
                    })

    return list(candidates.values())


def extract_parameter_table(line_records: Sequence[JsonDict]) -> List[JsonDict]:
    rows: List[JsonDict] = []
    for rec in line_records:
        text = rec["text"]
        if any(token in text for token in ["ML-KEM-512", "ML-KEM-768", "ML-KEM-1024", "3329", "256"]):
            if any(keyword.lower() in text.lower() for keyword in ["parameter", "k", "eta", "du", "dv", "q", "n", "ML-KEM"]):
                rows.append({
                    "line": rec["line"],
                    "raw_text": text.strip(),
                    "detected_values": re.findall(r"\b\d+\b", text),
                    "trust_boundary": "deterministic_reference_advisory_only",
                })
    return rows[:300]


def extract_equations_constraints(line_records: Sequence[JsonDict]) -> List[JsonDict]:
    rows: List[JsonDict] = []
    for rec in line_records:
        text = rec["text"]
        low = text.lower()
        if any(h.lower() in low for h in MATH_LINE_HINTS):
            # Avoid collecting every prose sentence with equals only.
            if any(x in text for x in ["=", "≤", "≥", "<", ">", "mod"]) or any(
                x.lower() in low for x in ["coefficient", "polynomial", "bound", "range", "z_q", "compress", "decompress"]
            ):
                rows.append({
                    "line": rec["line"],
                    "raw_text": text.strip(),
                    "detected_numbers": re.findall(r"\b\d+\b", text),
                    "detected_math_tokens": [h for h in MATH_LINE_HINTS if h.lower() in low],
                    "trust_boundary": "deterministic_reference_advisory_only",
                })
    return rows[:500]


def extract_preconditions_postconditions(line_records: Sequence[JsonDict]) -> JsonDict:
    candidates: List[JsonDict] = []
    for rec in line_records:
        text = rec["text"]
        low = text.lower()
        if any(h.lower() in low for h in PREPOST_HINTS):
            candidates.append({
                "line": rec["line"],
                "raw_text": text.strip(),
                "detected_hint_terms": [h for h in PREPOST_HINTS if h.lower() in low],
                "trust_boundary": "deterministic_reference_advisory_only",
            })

    return {
        "candidate_precondition_postcondition_lines": candidates[:500],
        "note": (
            "These are deterministic advisory candidates only. The LLM must verify all "
            "precondition/postcondition claims against the FIPS material."
        ),
    }


def build_spec_to_code_hints(line_records: Sequence[JsonDict], target_function: str, focus_terms: Sequence[str]) -> JsonDict:
    hints = []
    for rec in line_records:
        text = rec["text"]
        score = score_line_for_focus(text, focus_terms)
        if score >= 3:
            hints.append({
                "line": rec["line"],
                "score": score,
                "raw_text": text.strip(),
                "candidate_relevance": (
                    f"May be relevant to later implementation/property mapping for {target_function}; "
                    "requires LLM verification."
                ),
                "trust_boundary": "deterministic_reference_advisory_only",
            })

    return {
        "target_function": target_function,
        "candidate_mapping_hints": hints[:300],
        "warning": (
            "These hints do not establish that any implementation function corresponds to the specification. "
            "They are only advisory material for the LLM prompt."
        ),
    }


def run_deterministic_reference_extraction(
    spec_text: str,
    *,
    cfg: SpecExtractionConfig,
) -> Tuple[JsonDict, Dict[str, Path]]:
    line_records = make_line_records(spec_text)

    sections = find_sections(line_records)
    algorithms = find_algorithm_blocks(line_records)
    selected_excerpt, selected_hits = select_relevant_excerpt(
        line_records,
        focus_terms=cfg.focus_terms,
        context_lines=cfg.excerpt_context_lines,
        max_chars=cfg.max_excerpt_chars,
    )
    symbol_table = extract_symbol_table(line_records)
    parameter_table = extract_parameter_table(line_records)
    equations_constraints = extract_equations_constraints(line_records)
    prepost = extract_preconditions_postconditions(line_records)
    spec_to_code_hints = build_spec_to_code_hints(line_records, cfg.target_function, cfg.focus_terms)

    summary = {
        "stage": "02_spec_extraction",
        "mode": "deterministic_reference_only",
        "trust_boundary": "advisory_only_not_authoritative",
        "target_function": cfg.target_function,
        "target_topic": cfg.target_topic,
        "source_text_line_count": len(line_records),
        "section_count": len(sections),
        "algorithm_block_count": len(algorithms),
        "symbol_count": len(symbol_table),
        "parameter_candidate_count": len(parameter_table),
        "equation_constraint_candidate_count": len(equations_constraints),
        "prepost_candidate_count": len(prepost.get("candidate_precondition_postcondition_lines", [])),
        "selected_hit_count": len(selected_hits),
        "warning": (
            "This deterministic summary is not authoritative. It must only be used as advisory "
            "prompt reference material for the LLM."
        ),
    }

    bundle = {
        "01_spec_summary_deterministic": summary,
        "01_spec_sections_index": {
            "sections": sections,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "01_algorithm_blocks": {
            "algorithm_blocks": algorithms,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "01_symbol_table": {
            "symbols": symbol_table,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "01_parameter_table": {
            "parameter_candidates": parameter_table,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "01_equations_constraints": {
            "equation_constraint_candidates": equations_constraints,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "01_preconditions_postconditions": prepost,
        "01_spec_to_code_hints": spec_to_code_hints,
        "selected_excerpt_metadata": {
            "focus_terms": cfg.focus_terms,
            "context_lines": cfg.excerpt_context_lines,
            "max_excerpt_chars": cfg.max_excerpt_chars,
            "selected_hits": selected_hits[:100],
            "trust_boundary": "deterministic_reference_advisory_only",
        },
    }

    # The actual writing is handled by write_deterministic_reference_files().
    # Returning paths happens there.
    return {
        "bundle": bundle,
        "selected_spec_excerpt_text": selected_excerpt,
    }, {}


def write_deterministic_reference_files(
    layout: RunLayout,
    deterministic: JsonDict,
) -> Dict[str, Path]:
    stage = "02_spec_extraction"
    bundle = deterministic["bundle"]

    paths: Dict[str, Path] = {}

    paths["spec_summary_deterministic"] = layout.write_deterministic_reference_json(
        stage,
        "01_spec_summary.deterministic.json",
        bundle["01_spec_summary_deterministic"],
    )
    paths["sections_index"] = layout.write_deterministic_reference_json(
        stage,
        "01_spec_sections_index.deterministic.json",
        bundle["01_spec_sections_index"],
    )
    paths["algorithm_blocks"] = layout.write_deterministic_reference_json(
        stage,
        "01_algorithm_blocks.deterministic.json",
        bundle["01_algorithm_blocks"],
    )
    paths["symbol_table"] = layout.write_deterministic_reference_json(
        stage,
        "01_symbol_table.deterministic.json",
        bundle["01_symbol_table"],
    )
    paths["parameter_table"] = layout.write_deterministic_reference_json(
        stage,
        "01_parameter_table.deterministic.json",
        bundle["01_parameter_table"],
    )
    paths["equations_constraints"] = layout.write_deterministic_reference_json(
        stage,
        "01_equations_constraints.deterministic.json",
        bundle["01_equations_constraints"],
    )
    paths["preconditions_postconditions"] = layout.write_deterministic_reference_json(
        stage,
        "01_preconditions_postconditions.deterministic.json",
        bundle["01_preconditions_postconditions"],
    )
    paths["spec_to_code_hints"] = layout.write_deterministic_reference_json(
        stage,
        "01_spec_to_code_hints.deterministic.json",
        bundle["01_spec_to_code_hints"],
    )
    paths["selected_excerpt_metadata"] = layout.write_deterministic_reference_json(
        stage,
        "selected_spec_excerpt_metadata.deterministic.json",
        bundle["selected_excerpt_metadata"],
    )

    excerpt_path = layout.deterministic_reference_dir(stage) / "selected_spec_excerpt.txt"
    atomic_write_text(
        excerpt_path,
        deterministic.get("selected_spec_excerpt_text", ""),
    )
    paths["selected_spec_excerpt"] = excerpt_path

    return paths


# ---------------------------------------------------------------------------
# Prompt generation
# ---------------------------------------------------------------------------

def build_agent2_prompt(*, cfg: SpecExtractionConfig) -> str:
    responsibilities = """
- Identify relevant FIPS definitions.
- Identify relevant constants and parameters.
- Identify relevant algorithms or algorithm steps.
- Identify relevant equations or arithmetic constraints.
- Identify relevant array, vector, polynomial, coefficient, modulus, encoding, or decoding facts.
- Identify candidate specification-level preconditions and postconditions.
- Identify terminology that later agents must preserve exactly.
- Identify facts that may be relevant to C-level verification.
- Identify what is not available or not confirmed from the provided FIPS material.
- Provide precise evidence references for every major claim.
- Assess deterministic Python extraction output only as fallible advisory material.
- Record disagreements if deterministic reference material conflicts with the FIPS material.
""".strip()

    prohibitions = """
- Do not interpret implementation code in this stage unless the schema explicitly asks for cautious cross-reference hints.
- Do not generate CBMC harnesses.
- Do not generate final assertions.
- Do not claim proof.
- Do not claim verification.
- Do not claim implementation correctness.
- Do not claim full FIPS compliance.
- Do not copy deterministic Python extraction text blindly.
- Do not fill gaps from memory when the provided FIPS material is incomplete; mark uncertainty instead.
""".strip()

    discovery_scope = (
        "Property discovery mode: open_discovery. No predefined property taxonomy, campaign category, or artefact "
        "construction approach is disclosed at this stage. Extract broad, evidence-grounded specification facts "
        "that may support later independent property discovery."
        if cfg.discovery_mode == "open_discovery"
        else (
            f"Property discovery mode: targeted_campaign\n"
            f"Configured thesis property family: {cfg.property_family_id} — {cfg.property_family_title}\n"
            f"Planned downstream verification strategy: {cfg.verification_strategy}\n"
            f"Property-specific claim boundary: {cfg.property_claim_boundary}"
        )
    )

    task = f"""
This stage extracts specification-level facts from the provided FIPS 203 ML-KEM material for the target topic:

Target topic: {cfg.target_topic}
Target implementation function for later stages: {cfg.target_function}
{discovery_scope}

Your role is not to prove anything and not to generate CBMC artefacts. Your role is to identify relevant specification facts, constants, definitions, algorithms, equations, bounds, preconditions, postconditions, and traceable references that later agents may use.

When mentioning possible verification relevance, use candidate wording only, such as:
- candidate specification fact for later range checking,
- candidate bound relevant to later C-level assertions,
- candidate algorithm-to-code trace item,
- candidate precondition suggested by the specification.

The final JSON must be suitable for downstream property discovery and artefact generation agents, but it remains candidate specification analysis, not formal truth.
""".strip()

    schema_summary = """
Top-level required fields:
- stage
- source_scope
- spec_facts
- constants_and_parameters
- candidate_verification_relevance
- uncertainties
- evidence_references
- limitations

Every major claim should include evidence references when possible, such as file name, line range, page label, section number, algorithm number, table number, or excerpt line number.
""".strip()

    return build_common_stage_prompt(
        stage_name="Agent 2 — Specification Extraction Agent",
        task_description=task,
        responsibilities=responsibilities,
        prohibitions=prohibitions,
        schema_summary=schema_summary,
        include_non_copying_rule=False,
    )


def build_mock_spec_summary(cfg: SpecExtractionConfig, source_meta: JsonDict) -> JsonDict:
    """
    A schema-compatible mock object for pipeline testing.

    This is never evidence. It is marked as mock.
    """
    return {
        "stage": "02_spec_extraction",
        "mock": True,
        "llm_call_executed": False,
        "source_scope": {
            "primary_sources_used": [str(p) for p in cfg.spec_paths],
            "provided_material_complete": False,
            "missing_or_unavailable_material": [
                "Mock mode was used, so no real LLM specification extraction was executed."
            ],
        },
        "spec_facts": [],
        "constants_and_parameters": [],
        "algorithms_or_steps": [],
        "equations_and_bounds": [],
        "candidate_preconditions": [],
        "candidate_postconditions": [],
        "candidate_verification_relevance": [],
        "terminology_to_preserve": [],
        "deterministic_reference_assessment": {
            "used": True,
            "status": "not_assessed_by_real_llm",
            "warning": "Mock output only.",
            "disagreements": []
        },
        "uncertainties": [
            {
                "issue": "No real LLM call was executed.",
                "impact": "This output is valid only for pipeline wiring tests."
            }
        ],
        "evidence_references": [],
        "limitations": [
            "Mock mode output only.",
            "No API-backed reasoning was performed.",
            "Do not use this output as thesis evidence for LLM performance."
        ],
    }


# ---------------------------------------------------------------------------
# Main Agent 2 runner
# ---------------------------------------------------------------------------

def run_agent2(config_data: JsonDict, cfg: SpecExtractionConfig) -> int:
    stage = "02_spec_extraction"
    layout = RunLayout(cfg.run_dir, create=False)
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 2 Specification Extraction started.",
        data={
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
            "spec_paths": [str(p) for p in cfg.spec_paths],
        },
    )

    stage_status: JsonDict = {
        "schema_version": "agent_status.v1",
        **layout.protocol_context(),
        "stage": stage,
        "started_utc": utc_now_iso(),
        "completed_utc": None,
        "success": False,
        "llm_call_executed": False,
        "handoff_available": False,
        "errors": [],
        "warnings": [],
    }

    try:
        # --------------------------------------------------------------
        # 1. Read specification material locally for deterministic hints.
        # --------------------------------------------------------------
        spec_text, source_meta = read_spec_material(
            cfg.spec_paths,
            max_chars=cfg.max_spec_chars_for_deterministic,
        )

        source_meta_path = layout.write_deterministic_reference_json(
            stage,
            "01_source_material_read_report.deterministic.json",
            source_meta,
        )

        if not spec_text.strip():
            stage_status["warnings"].append(
                "No local text could be extracted from specification files. LLM may still use attached files if supported."
            )

        # --------------------------------------------------------------
        # 2. Deterministic advisory extraction.
        # --------------------------------------------------------------
        advisory_enabled = semantic_advisory_enabled(config_data) and cfg.discovery_mode != "open_discovery"
        deterministic_paths: Dict[str, Path] = {"source_material_read_report": source_meta_path}
        deterministic_bundle: Optional[JsonDict] = None
        if advisory_enabled:
            deterministic, _ = run_deterministic_reference_extraction(
                spec_text,
                cfg=cfg,
            )
            deterministic_paths.update(write_deterministic_reference_files(layout, deterministic))
            deterministic_bundle = dict(deterministic["bundle"])
            deterministic_bundle["source_material_read_report"] = source_meta
        else:
            stage_status["warnings"].append(
                "semantic_advisory_mode=off: deterministic semantic specification extraction was not generated or transmitted."
            )

        # --------------------------------------------------------------
        # 3. Build prompt and call shared LLM client.
        # --------------------------------------------------------------
        prompt_text = build_agent2_prompt(cfg=cfg)

        # Apply CLI llm-mode override without mutating original config too broadly.
        run_config_for_client = dict(config_data)
        if cfg.llm_mode_override:
            llm_cfg = dict(run_config_for_client.get("llm") or {})
            llm_cfg["mode"] = cfg.llm_mode_override
            run_config_for_client["llm"] = llm_cfg

        client = LLMClient.from_run_config(run_config_for_client)
        request = LLMStageRequest(
            stage=stage,
            prompt_text=prompt_text,
            output_filename="01_spec_summary.json",
            json_schema=SPEC_SUMMARY_SCHEMA,
            primary_evidence_files=list(cfg.spec_paths),
            deterministic_reference_bundle=deterministic_bundle,
            extra_prompt_metadata={
                "agent": "Agent 2 Specification Extraction",
                "target_function": cfg.target_function,
                "target_topic": cfg.target_topic,
                "trust_boundary": {
                    "deterministic_reference": "advisory_only",
                    "llm_output": "authoritative_stage_candidate_not_formal_truth",
                    "formal_truth": "not_claimed",
                },
            },
            mock_response_content=build_mock_spec_summary(cfg, source_meta),
        )

        result = client.run_stage(layout, request)
        stage_status["llm_call_executed"] = result.llm_call_executed
        stage_status["llm_mode"] = result.mode
        stage_status["llm_success"] = result.success
        record_llm_stage_failure(stage_status, result)

        # --------------------------------------------------------------
        # 4. Handoff manifest.
        # --------------------------------------------------------------
        handoff_outputs: Dict[str, Path] = {}
        if result.success and result.output_path:
            handoff_outputs["spec_summary"] = Path(result.output_path)

            # Validation is useful for downstream audit but not semantic input.
            if result.validation_path:
                handoff_outputs["spec_summary_validation"] = Path(result.validation_path)

            # Include deterministic excerpt as advisory evidence pointer, not authoritative summary.
            if deterministic_paths.get("selected_spec_excerpt"):
                handoff_outputs["selected_spec_excerpt_advisory"] = deterministic_paths["selected_spec_excerpt"]

            handoff_notes = {
                "handoff_policy": (
                    "spec_summary is LLM-authoritative stage candidate output. "
                    "selected_spec_excerpt_advisory is deterministic advisory evidence only."
                ),
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
                "mock_output": result.mode == "mock",
            }
            layout.write_handoff_manifest(
                stage,
                outputs=handoff_outputs,
                authoritative_source="llm_authoritative",
                next_stage_consumers=[
                    "03_code_understanding",
                    "04_property_discovery",
                    "05_artifact_generation",
                    "06_review_critic",
                    "11_evaluation_reporter",
                ],
                notes=handoff_notes,
            )
            stage_status["handoff_available"] = True
            stage_status["success"] = True
        else:
            message = (
                "No authoritative LLM spec_summary was produced. "
                "Deterministic reference output was not handed off as authoritative."
            )
            stage_status["warnings"].append(message)

            if cfg.allow_empty_handoff_on_failure:
                # Empty handoff manifest gives orchestrator an explicit failure record
                # without pretending deterministic output is official.
                layout.write_handoff_manifest(
                    stage,
                    outputs={},
                    authoritative_source="none_llm_failed_or_disabled",
                    next_stage_consumers=[],
                    notes={
                        "handoff_policy": "No semantic handoff because LLM output is unavailable or invalid.",
                        "deterministic_reference_available": True,
                        "deterministic_reference_is_authoritative": False,
                        "llm_result": result.to_dict(),
                    },
                )

        # --------------------------------------------------------------
        # 5. Stage manifest.
        # --------------------------------------------------------------
        llm_outputs = {}
        validation_outputs = {}
        prompt_outputs = {}

        if result.output_path:
            llm_outputs["spec_summary"] = Path(result.output_path)
        if result.raw_response_path:
            llm_outputs["raw_llm_response"] = Path(result.raw_response_path)
        if result.validation_path:
            validation_outputs["llm_call_validation"] = Path(result.validation_path)
        if result.prompt_path:
            prompt_outputs["prompt"] = Path(result.prompt_path)
        if result.metadata_path:
            prompt_outputs["prompt_metadata"] = Path(result.metadata_path)

        # Collect known prompt package files if they exist.
        pdir = layout.prompt_package_dir(stage)
        for name in ["deterministic_reference_bundle.json", "primary_evidence_manifest.json"]:
            p = pdir / name
            if p.exists():
                prompt_outputs[name.replace(".json", "")] = p

        layout.write_stage_manifest(
            stage,
            primary_evidence_inputs=[str(p) for p in cfg.spec_paths],
            deterministic_reference_outputs=deterministic_paths,
            prompt_package_outputs=prompt_outputs,
            llm_authoritative_outputs=llm_outputs,
            validation_outputs=validation_outputs,
            notes={
                "agent_version": "agent2_spec_extraction_refactored.v1",
                "deterministic_reference_policy": "advisory_only_not_authoritative",
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
            },
        )

        stage_status["completed_utc"] = utc_now_iso()
        status_path = layout.logs_dir(stage) / "02_spec_extraction_status.json"
        atomic_write_json(status_path, stage_status)

        layout.log_event(
            event_type="stage_completed" if stage_status["success"] else "stage_completed_without_handoff",
            stage=stage,
            message="Agent 2 Specification Extraction completed.",
            data={
                "success": stage_status["success"],
                "handoff_available": stage_status["handoff_available"],
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
            },
        )

        return 0 if stage_status["success"] else 2

    except Exception as exc:
        stage_status["completed_utc"] = utc_now_iso()
        stage_status["success"] = False
        stage_status["errors"].append({
            "type": type(exc).__name__,
            "message": str(exc),
            "traceback": traceback.format_exc(),
        })

        ensure_dir(layout.logs_dir(stage))
        atomic_write_json(layout.logs_dir(stage) / "02_spec_extraction_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 2 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        # Try to write a stage manifest even on failure.
        try:
            layout.write_stage_manifest(
                stage,
                primary_evidence_inputs=[str(p) for p in cfg.spec_paths],
                notes={
                    "agent_version": "agent2_spec_extraction_refactored.v1",
                    "failed": True,
                    "error": f"{type(exc).__name__}: {exc}",
                },
            )
        except Exception:
            pass

        return 1


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Agent 2 — refactored LLM-backed Specification Extraction Agent"
    )
    parser.add_argument(
        "--config",
        help="Path to run config JSON.",
    )
    parser.add_argument(
        "--run-dir",
        help="Override run directory.",
    )
    parser.add_argument(
        "--spec-path",
        help="Specification file path(s). Comma-separated accepted. Text preferred; PDF supported best-effort.",
    )
    parser.add_argument(
        "--target-function",
        help="Implementation function name for later mapping context, e.g. mlk_poly_add.",
    )
    parser.add_argument(
        "--target-topic",
        help="Human-readable target topic.",
    )
    parser.add_argument(
        "--focus-terms",
        help="Comma-separated terms for deterministic advisory excerpt selection.",
    )
    parser.add_argument(
        "--llm-mode",
        choices=["real", "mock", "disabled"],
        help="Override llm.mode from config.",
    )
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)

    config_data, cfg = load_config(args)
    return run_agent2(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
