#!/usr/bin/env python3
"""
code_understanding_agent_refactored.py

Agent 3 — Code Understanding Agent, refactored for the new thesis workflow.

Architecture implemented:
- Python reads local implementation/source/header material.
- Python creates deterministic static-analysis reference artefacts.
- Deterministic artefacts are advisory only, never authoritative.
- If Agent 2 handoff exists, Agent 3 consumes the LLM-authored specification summary.
- Python builds a strict prompt package.
- The shared LLM client produces the authoritative stage candidate output:
    stages/03_code_understanding/llm_authoritative/02_code_summary.json
- Downstream agents consume only manifest-declared handoff outputs.
- No root-level output dumping.
- No duplicate output copies.

Trust boundary:
- Agent 3 does not prove implementation correctness.
- Agent 3 does not claim FIPS compliance.
- Agent 3 does not generate final CBMC harnesses.
- Agent 3 produces candidate implementation facts for later property discovery.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import traceback
from dataclasses import dataclass
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
    from agents.common.evidence_contract import canonical_raw_evidence_files, existing_unique_paths, without_keys
    from agents.common.llm_client import LLMClient, LLMStageRequest
    from agents.common.prompt_templates import build_common_stage_prompt
    from agents.common.schemas import CODE_SUMMARY_SCHEMA
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
# Helpers
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
        return text[:max_chars] + "\n\n[TRUNCATED_BY_CODE_UNDERSTANDING_AGENT]\n"
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


def parse_list_arg(value: Optional[str]) -> List[str]:
    if not value:
        return []
    parts = re.split(r"[,;]", value)
    return [p.strip() for p in parts if p.strip()]


def make_line_records(text: str, *, file_path: PathLike) -> List[JsonDict]:
    return [
        {
            "file": str(file_path),
            "line": i + 1,
            "text": line.rstrip("\n"),
        }
        for i, line in enumerate(text.splitlines())
    ]


def compact_ws(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def strip_comments_light(text: str) -> str:
    """
    Light comment stripper for pattern finding only.

    It is intentionally not a C parser.
    """
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.DOTALL)
    text = re.sub(r"//.*", " ", text)
    return text


def json_safe_excerpt(text: str, max_chars: int = 4000) -> str:
    if len(text) <= max_chars:
        return text
    return text[:max_chars] + "\n[TRUNCATED_EXCERPT]\n"


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

@dataclass
class CodeUnderstandingConfig:
    run_dir: Path
    code_paths: List[Path]
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM implementation code understanding"
    property_family_id: str = "P16"
    property_family_title: str = "Polynomial addition/subtraction bounds"
    verification_strategy: str = "standard_cbmc_harness"
    property_claim_boundary: str = "Property-specific candidate evidence only."
    max_code_chars_for_deterministic: int = 800_000
    max_function_excerpt_chars: int = 80_000
    llm_mode_override: Optional[str] = None
    allow_missing_agent2_spec_summary: bool = True
    allow_empty_handoff_on_failure: bool = True

    focus_terms: List[str] = None  # type: ignore

    def __post_init__(self) -> None:
        if self.focus_terms is None:
            self.focus_terms = [
                self.target_function,
                "mlk_poly",
                "coeffs",
                "MLKEM_N",
                "MLKEM_Q",
                "MLKEM_Q_HALF",
                "int16_t",
                "uint16_t",
                "__CPROVER",
                "requires",
                "ensures",
                "assert",
                "assume",
                "for",
                "while",
                "memory",
                "alias",
                "overflow",
                "poly",
                "add",
                "sub",
                "barrett",
                "montgomery",
                "ntt",
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


def _as_paths(value: Any) -> List[Path]:
    if value is None:
        return []
    if isinstance(value, str):
        return [Path(p).expanduser().resolve() for p in parse_list_arg(value)]
    if isinstance(value, list):
        return [Path(str(v)).expanduser().resolve() for v in value]
    return []


def resolve_code_paths(config_data: JsonDict, args: argparse.Namespace) -> List[Path]:
    paths: List[Path] = []

    if args.code_path:
        paths.extend(Path(p).expanduser().resolve() for p in parse_list_arg(args.code_path))

    inputs = config_data.get("inputs", {})
    if isinstance(inputs, dict):
        for key in [
            "code_path",
            "source_path",
            "implementation_path",
            "target_code_path",
            "poly_c_path",
        ]:
            paths.extend(_as_paths(inputs.get(key)))

        for key in [
            "header_path",
            "headers",
            "code_paths",
            "source_paths",
            "implementation_files",
            "code_files",
            "source_files",
        ]:
            paths.extend(_as_paths(inputs.get(key)))

        # Common previous project shape: inputs/code directory.
        code_dir_value = inputs.get("code_dir") or inputs.get("code_directory")
        if code_dir_value:
            code_dir = Path(str(code_dir_value)).expanduser().resolve()
            if code_dir.exists():
                for suffix in ["*.c", "*.h", "*.inc"]:
                    paths.extend(sorted(code_dir.glob(suffix)))

    for key in ["code_path", "source_path", "code_paths", "source_files"]:
        paths.extend(_as_paths(config_data.get(key)))

    # If still empty, try a default local input folder.
    if not paths:
        default_dir = Path("inputs/code").resolve()
        if default_dir.exists():
            for suffix in ["*.c", "*.h", "*.inc"]:
                paths.extend(sorted(default_dir.glob(suffix)))

    # De-duplicate preserving order and keep only existing files if possible.
    seen = set()
    unique: List[Path] = []
    for p in paths:
        key = str(p)
        if key not in seen:
            unique.append(p)
            seen.add(key)

    return unique


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, CodeUnderstandingConfig]:
    config_data: JsonDict = {}
    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        config_data = load_normalized_config(config_path)

    run_dir = resolve_run_dir(config_data, args)
    code_paths = resolve_code_paths(config_data, args)

    if not code_paths:
        raise ValueError(
            "No code/header paths provided. Use --code-path or config inputs.code_dir/code_paths/source_files."
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
        or f"ML-KEM implementation understanding for {target_function}"
    )

    focus_terms = parse_list_arg(args.focus_terms)
    if not focus_terms:
        cfg_terms = (
            config_data.get("code_understanding", {}).get("focus_terms")
            if isinstance(config_data.get("code_understanding"), dict)
            else None
        )
        if isinstance(cfg_terms, list):
            focus_terms = [str(x) for x in cfg_terms]

    campaign = config_data.get("property_campaign", {}) if isinstance(config_data.get("property_campaign"), dict) else {}
    cfg = CodeUnderstandingConfig(
        run_dir=run_dir,
        code_paths=code_paths,
        target_function=target_function,
        target_topic=target_topic,
        property_family_id=str(campaign.get("property_family_id") or "P16"),
        property_family_title=str(campaign.get("property_family_title") or "Polynomial addition/subtraction bounds"),
        verification_strategy=str(campaign.get("verification_strategy") or "standard_cbmc_harness"),
        property_claim_boundary=str(campaign.get("claim_boundary") or "Property-specific candidate evidence only."),
        llm_mode_override=args.llm_mode,
        focus_terms=focus_terms or None,  # type: ignore
    )
    return config_data, cfg


# ---------------------------------------------------------------------------
# Code reading
# ---------------------------------------------------------------------------

def read_code_material(paths: Sequence[Path], *, max_chars: int) -> Tuple[str, JsonDict, List[JsonDict]]:
    texts: List[str] = []
    records: List[JsonDict] = []
    line_records: List[JsonDict] = []

    for path in paths:
        p = Path(path)
        meta = file_metadata(p)
        if not p.exists() or not p.is_file():
            meta["read_success"] = False
            meta["warnings"] = ["File not found or not a file."]
            records.append(meta)
            continue

        try:
            text = safe_read_text(p, max_chars=max_chars)
            meta["read_success"] = True
            meta["local_text_chars_used"] = len(text)
            texts.append(f"\n===== CODE SOURCE BEGIN: {p} =====\n{text}\n===== CODE SOURCE END: {p} =====\n")
            line_records.extend(make_line_records(text, file_path=p))
        except Exception as exc:
            meta["read_success"] = False
            meta["warnings"] = [f"{type(exc).__name__}: {exc}"]

        records.append(meta)

    return "\n".join(texts), {
        "source_records": records,
        "combined_text_chars": sum(len(t) for t in texts),
        "combined_text_available": bool(texts),
        "file_count": len(paths),
    }, line_records


# ---------------------------------------------------------------------------
# Deterministic reference extraction
# ---------------------------------------------------------------------------

INCLUDE_RE = re.compile(r"^\s*#\s*include\s+[<\"](?P<header>[^>\"]+)[>\"]", re.MULTILINE)
MACRO_RE = re.compile(r"^\s*#\s*define\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)\b(?P<body>.*)$", re.MULTILINE)
TYPEDEF_RE = re.compile(r"^\s*typedef\s+(?P<body>.*?;)", re.MULTILINE | re.DOTALL)
STRUCT_RE = re.compile(r"\bstruct\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)?\s*\{(?P<body>.*?)\}\s*(?P<alias>[A-Za-z_][A-Za-z0-9_]*)?\s*;", re.DOTALL)

# Conservative function-signature regex. Good enough for advisory hints, not a C parser.
FUNCTION_SIG_RE = re.compile(
    r"""
    (?P<signature>
        (?:^|\n)
        \s*
        (?:
            [A-Za-z_][A-Za-z0-9_\s\*\(\)]*
        )
        \b(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*
        \(
            (?P<params>[^;{}]*?)
        \)
        \s*
        (?P<trailer>__CPROVER_[A-Za-z_][A-Za-z0-9_]*\s*\([^;{}]*\)\s*)*
        \{
    )
    """,
    re.VERBOSE | re.MULTILINE,
)

FOR_RE = re.compile(r"\bfor\s*\((?P<header>[^)]*)\)")
WHILE_RE = re.compile(r"\bwhile\s*\((?P<condition>[^)]*)\)")
ARRAY_ACCESS_RE = re.compile(r"\b(?P<base>[A-Za-z_][A-Za-z0-9_]*(?:->|\.)?[A-Za-z_][A-Za-z0-9_]*)\s*\[(?P<index>[^\]]+)\]")
C_CONTRACT_HINT_RE = re.compile(r"\b(__CPROVER_[A-Za-z_][A-Za-z0-9_]*|assert|__CPROVER_assert|__CPROVER_assume|requires|ensures|assigns|invariant|loop invariant)\b")
ARITHMETIC_HINT_RE = re.compile(r"(\+|\-|\*|/|%|<<|>>|\bint16_t\b|\buint16_t\b|\bint32_t\b|\buint32_t\b|\(int16_t\)|\(uint16_t\)|MLKEM_Q|MLKEM_N)")
POINTER_HINT_RE = re.compile(r"(\*|->|&|\bNULL\b|__CPROVER_is_fresh|__CPROVER_r_ok|__CPROVER_w_ok|memory_no_alias|valid)")


def line_number_from_offset(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def find_matching_brace(text: str, open_brace_index: int) -> Optional[int]:
    depth = 0
    in_string = False
    in_char = False
    escape = False
    in_line_comment = False
    in_block_comment = False

    for i in range(open_brace_index, len(text)):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""

        if in_line_comment:
            if ch == "\n":
                in_line_comment = False
            continue
        if in_block_comment:
            if ch == "*" and nxt == "/":
                in_block_comment = False
            continue
        if in_string:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            continue
        if in_char:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == "'":
                in_char = False
            continue

        if ch == "/" and nxt == "/":
            in_line_comment = True
            continue
        if ch == "/" and nxt == "*":
            in_block_comment = True
            continue
        if ch == '"':
            in_string = True
            continue
        if ch == "'":
            in_char = True
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i

    return None


def extract_functions_from_file(path: Path, text: str) -> List[JsonDict]:
    functions: List[JsonDict] = []

    for m in FUNCTION_SIG_RE.finditer(text):
        name = m.group("name")
        sig_start = m.start("signature")
        open_brace = text.find("{", m.start("signature"), m.end("signature"))
        if open_brace == -1:
            continue
        close_brace = find_matching_brace(text, open_brace)
        if close_brace is None:
            continue

        signature_text = compact_ws(text[sig_start:open_brace])
        body_text = text[open_brace:close_brace + 1]
        start_line = line_number_from_offset(text, sig_start)
        end_line = line_number_from_offset(text, close_brace)

        functions.append({
            "file": str(path),
            "function_name": name,
            "start_line": start_line,
            "end_line": end_line,
            "signature_text": signature_text,
            "parameters_text": compact_ws(m.group("params") or ""),
            "body_excerpt": json_safe_excerpt(body_text, max_chars=12000),
            "body_char_count": len(body_text),
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    return functions


def detect_includes_macros_types(path: Path, text: str) -> JsonDict:
    includes = [
        {
            "file": str(path),
            "header": m.group("header"),
            "line": line_number_from_offset(text, m.start()),
            "raw_text": m.group(0).strip(),
            "trust_boundary": "deterministic_reference_advisory_only",
        }
        for m in INCLUDE_RE.finditer(text)
    ]

    macros = []
    for m in MACRO_RE.finditer(text):
        body = compact_ws(m.group("body") or "")
        macros.append({
            "file": str(path),
            "name": m.group("name"),
            "body": body,
            "line": line_number_from_offset(text, m.start()),
            "raw_text": m.group(0).strip(),
            "detected_numbers": re.findall(r"\b\d+\b", body),
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    typedefs = []
    for m in TYPEDEF_RE.finditer(text):
        raw = compact_ws(m.group(0))
        if len(raw) > 500:
            raw = raw[:500] + " [TRUNCATED_TYPEDEF]"
        typedefs.append({
            "file": str(path),
            "line": line_number_from_offset(text, m.start()),
            "raw_text": raw,
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    structs = []
    for m in STRUCT_RE.finditer(text):
        structs.append({
            "file": str(path),
            "line": line_number_from_offset(text, m.start()),
            "struct_name": m.group("name"),
            "alias": m.group("alias"),
            "body_excerpt": json_safe_excerpt(compact_ws(m.group("body")), max_chars=1000),
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    return {
        "includes": includes,
        "macros": macros,
        "typedefs": typedefs,
        "structs": structs,
    }


def detect_loops_arrays_contracts(path: Path, text: str) -> JsonDict:
    rows_loops = []
    for m in FOR_RE.finditer(text):
        rows_loops.append({
            "file": str(path),
            "line": line_number_from_offset(text, m.start()),
            "kind": "for",
            "header_or_condition": compact_ws(m.group("header")),
            "detected_numbers": re.findall(r"\b\d+\b", m.group("header")),
            "mentions_MLKEM_N": "MLKEM_N" in m.group("header"),
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    for m in WHILE_RE.finditer(text):
        rows_loops.append({
            "file": str(path),
            "line": line_number_from_offset(text, m.start()),
            "kind": "while",
            "header_or_condition": compact_ws(m.group("condition")),
            "detected_numbers": re.findall(r"\b\d+\b", m.group("condition")),
            "mentions_MLKEM_N": "MLKEM_N" in m.group("condition"),
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    rows_arrays = []
    for m in ARRAY_ACCESS_RE.finditer(text):
        rows_arrays.append({
            "file": str(path),
            "line": line_number_from_offset(text, m.start()),
            "base": m.group("base"),
            "index": compact_ws(m.group("index")),
            "raw_text": compact_ws(m.group(0)),
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    rows_contracts = []
    lines = text.splitlines()
    for i, line in enumerate(lines, start=1):
        if C_CONTRACT_HINT_RE.search(line):
            rows_contracts.append({
                "file": str(path),
                "line": i,
                "raw_text": line.strip(),
                "detected_terms": sorted(set(C_CONTRACT_HINT_RE.findall(line))),
                "trust_boundary": "deterministic_reference_advisory_only",
            })

    return {
        "loops": rows_loops[:500],
        "array_accesses": rows_arrays[:1000],
        "contract_assertion_annotation_lines": rows_contracts[:500],
    }


def detect_arithmetic_memory_facts(path: Path, text: str) -> JsonDict:
    arithmetic_lines = []
    pointer_memory_lines = []

    for i, line in enumerate(text.splitlines(), start=1):
        if ARITHMETIC_HINT_RE.search(line):
            arithmetic_lines.append({
                "file": str(path),
                "line": i,
                "raw_text": line.strip(),
                "detected_numbers": re.findall(r"\b\d+\b", line),
                "mentions_target_constants": [x for x in ["MLKEM_Q", "MLKEM_N", "MLKEM_Q_HALF"] if x in line],
                "trust_boundary": "deterministic_reference_advisory_only",
            })
        if POINTER_HINT_RE.search(line):
            pointer_memory_lines.append({
                "file": str(path),
                "line": i,
                "raw_text": line.strip(),
                "detected_pointer_memory_terms": sorted(set(POINTER_HINT_RE.findall(line))),
                "trust_boundary": "deterministic_reference_advisory_only",
            })

    return {
        "integer_range_obligation_candidates": arithmetic_lines[:800],
        "memory_pointer_obligation_candidates": pointer_memory_lines[:800],
    }


def target_function_analysis(functions: Sequence[JsonDict], target_function: str) -> JsonDict:
    matches = [f for f in functions if f.get("function_name") == target_function]

    if not matches:
        close = [
            f for f in functions
            if target_function.lower() in str(f.get("function_name", "")).lower()
            or str(f.get("function_name", "")).lower() in target_function.lower()
        ]
        return {
            "target_function": target_function,
            "found_exact_match": False,
            "candidate_near_matches": close[:10],
            "warning": "Target function was not found exactly by deterministic parser. LLM must verify from raw code.",
            "trust_boundary": "deterministic_reference_advisory_only",
        }

    items = []
    for f in matches:
        body = str(f.get("body_excerpt", ""))
        assignments = []
        for line in body.splitlines():
            if "=" in line and "==" not in line:
                assignments.append(line.strip())

        possible_inplace = any(
            token in body for token in [
                "->coeffs", ".coeffs", f"{target_function}(", "r->", "r.", "a->", "b->"
            ]
        )

        old_new_warning = None
        if possible_inplace:
            old_new_warning = (
                "Function may modify object fields in place. Later harnesses may need explicit "
                "old-state snapshots before the function call."
            )

        items.append({
            "function_name": f.get("function_name"),
            "file": f.get("file"),
            "start_line": f.get("start_line"),
            "end_line": f.get("end_line"),
            "signature_text": f.get("signature_text"),
            "parameters_text": f.get("parameters_text"),
            "possible_assignment_lines": assignments[:80],
            "possible_inplace_update": possible_inplace,
            "old_state_new_state_warning": old_new_warning,
            "body_excerpt": f.get("body_excerpt"),
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    return {
        "target_function": target_function,
        "found_exact_match": True,
        "matches": items,
        "warning": (
            "This is deterministic parser output only. The LLM must verify target function "
            "behaviour against raw source/header evidence."
        ),
        "trust_boundary": "deterministic_reference_advisory_only",
    }


def build_code_mapping_candidates(
    *,
    target_function: str,
    functions: Sequence[JsonDict],
    macros_types: JsonDict,
    loops_arrays: JsonDict,
    arithmetic_memory: JsonDict,
) -> JsonDict:
    candidates = []

    target_low = target_function.lower()
    for f in functions:
        name = str(f.get("function_name", ""))
        body = str(f.get("body_excerpt", ""))
        score = 0
        reasons = []
        if name.lower() == target_low:
            score += 10
            reasons.append("exact target function name")
        if "coeff" in body.lower():
            score += 3
            reasons.append("mentions coefficient field/access")
        if "MLKEM_N" in body:
            score += 3
            reasons.append("mentions MLKEM_N loop/array bound")
        if "MLKEM_Q" in body:
            score += 2
            reasons.append("mentions MLKEM_Q modulus/constant")
        if "+" in body or "-" in body:
            score += 1
            reasons.append("contains arithmetic operator")

        if score:
            candidates.append({
                "function_name": name,
                "file": f.get("file"),
                "start_line": f.get("start_line"),
                "end_line": f.get("end_line"),
                "score": score,
                "reasons": reasons,
                "candidate_mapping_note": (
                    "May be relevant to later spec-code/property mapping; requires LLM verification."
                ),
                "trust_boundary": "deterministic_reference_advisory_only",
            })

    return {
        "target_function": target_function,
        "candidate_mappings": sorted(candidates, key=lambda x: x["score"], reverse=True)[:100],
        "warning": (
            "These mapping candidates do not establish semantic equivalence to FIPS 203. "
            "They are advisory only."
        ),
    }


def run_deterministic_code_reference_extraction(
    *,
    cfg: CodeUnderstandingConfig,
    combined_code_text: str,
    line_records: Sequence[JsonDict],
) -> JsonDict:
    per_file = []
    all_functions: List[JsonDict] = []
    all_includes = []
    all_macros = []
    all_typedefs = []
    all_structs = []
    all_loops = []
    all_arrays = []
    all_contracts = []
    all_integer_candidates = []
    all_memory_candidates = []

    for path in cfg.code_paths:
        p = Path(path)
        if not p.exists() or not p.is_file():
            continue
        text = safe_read_text(p, max_chars=cfg.max_code_chars_for_deterministic)

        funcs = extract_functions_from_file(p, text)
        all_functions.extend(funcs)

        imt = detect_includes_macros_types(p, text)
        all_includes.extend(imt["includes"])
        all_macros.extend(imt["macros"])
        all_typedefs.extend(imt["typedefs"])
        all_structs.extend(imt["structs"])

        lac = detect_loops_arrays_contracts(p, text)
        all_loops.extend(lac["loops"])
        all_arrays.extend(lac["array_accesses"])
        all_contracts.extend(lac["contract_assertion_annotation_lines"])

        armem = detect_arithmetic_memory_facts(p, text)
        all_integer_candidates.extend(armem["integer_range_obligation_candidates"])
        all_memory_candidates.extend(armem["memory_pointer_obligation_candidates"])

        per_file.append({
            "file": str(p),
            "function_count": len(funcs),
            "include_count": len(imt["includes"]),
            "macro_count": len(imt["macros"]),
            "typedef_count": len(imt["typedefs"]),
            "struct_count": len(imt["structs"]),
            "loop_count": len(lac["loops"]),
            "array_access_count": len(lac["array_accesses"]),
            "contract_annotation_count": len(lac["contract_assertion_annotation_lines"]),
            "integer_candidate_count": len(armem["integer_range_obligation_candidates"]),
            "memory_candidate_count": len(armem["memory_pointer_obligation_candidates"]),
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    macros_types = {
        "includes": all_includes,
        "macros": all_macros,
        "typedefs": all_typedefs,
        "structs": all_structs,
        "trust_boundary": "deterministic_reference_advisory_only",
    }

    loops_arrays = {
        "loops": all_loops[:1000],
        "array_accesses": all_arrays[:1500],
        "contract_assertion_annotation_lines": all_contracts[:1000],
        "trust_boundary": "deterministic_reference_advisory_only",
    }

    arithmetic_memory = {
        "integer_range_obligation_candidates": all_integer_candidates[:1500],
        "memory_pointer_obligation_candidates": all_memory_candidates[:1500],
        "trust_boundary": "deterministic_reference_advisory_only",
    }

    target = target_function_analysis(all_functions, cfg.target_function)

    mapping = build_code_mapping_candidates(
        target_function=cfg.target_function,
        functions=all_functions,
        macros_types=macros_types,
        loops_arrays=loops_arrays,
        arithmetic_memory=arithmetic_memory,
    )

    summary = {
        "stage": "03_code_understanding",
        "mode": "deterministic_reference_only",
        "trust_boundary": "advisory_only_not_authoritative",
        "target_function": cfg.target_function,
        "target_topic": cfg.target_topic,
        "file_count": len(cfg.code_paths),
        "function_count": len(all_functions),
        "include_count": len(all_includes),
        "macro_count": len(all_macros),
        "typedef_count": len(all_typedefs),
        "struct_count": len(all_structs),
        "loop_count": len(all_loops),
        "array_access_count": len(all_arrays),
        "contract_annotation_count": len(all_contracts),
        "integer_candidate_count": len(all_integer_candidates),
        "memory_candidate_count": len(all_memory_candidates),
        "warning": (
            "This deterministic code summary is not authoritative. It must only be used "
            "as advisory prompt reference material for the LLM."
        ),
    }

    cbmc_harness_hints = {
        "target_function": cfg.target_function,
        "candidate_harness_considerations": [
            {
                "hint": "Use actual function signature and required headers from primary source.",
                "trust_boundary": "deterministic_reference_advisory_only",
            },
            {
                "hint": "If the target function mutates a structure in place, later harnesses may need an explicit old-state snapshot.",
                "trust_boundary": "deterministic_reference_advisory_only",
            },
            {
                "hint": "Do not infer correctness from function name. Verify behaviour from source body and contracts.",
                "trust_boundary": "deterministic_reference_advisory_only",
            },
        ],
        "target_function_analysis": target,
    }

    return {
        "02_code_summary_deterministic": summary,
        "02_function_signature_analysis": {
            "functions": all_functions,
            "target_function_analysis": target,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "02_code_structure_index": {
            "per_file_summary": per_file,
            "source_files": [str(p) for p in cfg.code_paths],
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "02_code_symbol_table": {
            "functions": [
                {
                    "function_name": f.get("function_name"),
                    "file": f.get("file"),
                    "start_line": f.get("start_line"),
                    "end_line": f.get("end_line"),
                    "signature_text": f.get("signature_text"),
                    "parameters_text": f.get("parameters_text"),
                    "trust_boundary": "deterministic_reference_advisory_only",
                }
                for f in all_functions
            ],
            "macros": all_macros,
            "typedefs": all_typedefs,
            "structs": all_structs,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "02_macro_constant_map": {
            "includes": all_includes,
            "macros": all_macros,
            "typedefs": all_typedefs,
            "structs": all_structs,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "02_loop_bounds_array_accesses": loops_arrays,
        "02_memory_safety_obligations": {
            "memory_pointer_obligation_candidates": all_memory_candidates[:1500],
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "02_integer_range_obligations": {
            "integer_range_obligation_candidates": all_integer_candidates[:1500],
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "02_spec_code_mapping_candidates": mapping,
        "02_cbmc_harness_hints": cbmc_harness_hints,
    }


def write_deterministic_reference_files(layout: RunLayout, deterministic: JsonDict) -> Dict[str, Path]:
    stage = "03_code_understanding"
    paths: Dict[str, Path] = {}

    file_map = {
        "code_summary_deterministic": ("02_code_summary.deterministic.json", "02_code_summary_deterministic"),
        "function_signature_analysis": ("02_function_signature_analysis.deterministic.json", "02_function_signature_analysis"),
        "code_structure_index": ("02_code_structure_index.deterministic.json", "02_code_structure_index"),
        "code_symbol_table": ("02_code_symbol_table.deterministic.json", "02_code_symbol_table"),
        "macro_constant_map": ("02_macro_constant_map.deterministic.json", "02_macro_constant_map"),
        "loop_bounds_array_accesses": ("02_loop_bounds_array_accesses.deterministic.json", "02_loop_bounds_array_accesses"),
        "memory_safety_obligations": ("02_memory_safety_obligations.deterministic.json", "02_memory_safety_obligations"),
        "integer_range_obligations": ("02_integer_range_obligations.deterministic.json", "02_integer_range_obligations"),
        "spec_code_mapping_candidates": ("02_spec_code_mapping_candidates.deterministic.json", "02_spec_code_mapping_candidates"),
        "cbmc_harness_hints": ("02_cbmc_harness_hints.deterministic.json", "02_cbmc_harness_hints"),
    }

    for key, (filename, data_key) in file_map.items():
        paths[key] = layout.write_deterministic_reference_json(
            stage,
            filename,
            deterministic[data_key],
        )

    return paths


# ---------------------------------------------------------------------------
# Prompt generation
# ---------------------------------------------------------------------------

def build_agent3_prompt(*, cfg: CodeUnderstandingConfig, spec_summary_available: bool) -> str:
    responsibilities = """
- Identify relevant functions and their signatures.
- Identify relevant macros, constants, typedefs, structs, array sizes, and parameter dependencies.
- Identify relevant loops, loop bounds, indexing patterns, and memory accesses.
- Identify pointer assumptions, aliasing assumptions, buffer requirements, and array-size expectations.
- Identify integer types, arithmetic operations, casts, and possible overflow-sensitive areas.
- Identify existing contracts, assertions, comments, and verification annotations.
- Identify relationships between function inputs, outputs, and modified memory.
- Explicitly identify old-state versus new-state relationships when a selected function mutates memory in place.
- Identify candidate code-level facts that later agents can use for property discovery.
- Identify missing context, unresolved dependencies, or unavailable source files.
- Provide precise evidence references for every major claim.
- Assess deterministic Python code analysis only as fallible advisory material.
- Record disagreements if deterministic reference material conflicts with the raw code or headers.
""".strip()

    prohibitions = """
- Do not claim that the implementation satisfies FIPS 203.
- Do not claim that any property is proven.
- Do not generate final CBMC harnesses.
- Do not generate final assertions.
- Do not ignore macros or header-defined constants.
- Do not assume that a function name proves semantic equivalence to the specification.
- Do not copy deterministic Python explanations blindly.
- Do not treat previous stage LLM outputs as formal proof.
- Do not silently invent unavailable declarations or build dependencies.
""".strip()

    spec_context_sentence = (
        "Agent 2's LLM-authored specification summary is available as previous-stage candidate context. "
        "Use it cautiously for terminology and traceability hints, but verify implementation claims from raw code/header evidence."
        if spec_summary_available
        else
        "Agent 2's specification summary was not available. Record this missing context and avoid unsupported spec-code mapping claims."
    )

    task = f"""
This stage analyses the provided implementation source files, header files, existing comments, and existing contracts.

Target function for this stage: {cfg.target_function}
Target topic: {cfg.target_topic}
Configured thesis property family: {cfg.property_family_id} — {cfg.property_family_title}
Planned downstream verification strategy: {cfg.verification_strategy}
Property-specific claim boundary: {cfg.property_claim_boundary}

Your role is not to prove anything and not to generate final CBMC artefacts. Your role is to understand selected implementation behaviour and produce traceable code facts for later property discovery.

{spec_context_sentence}

When linking implementation facts to specification material, use cautious wording unless direct evidence is available, such as:
- appears intended to correspond to,
- may be related to,
- candidate implementation counterpart,
- requires confirmation by later traceability/property stages.

The final JSON must be suitable for downstream property discovery and artefact generation agents, but it remains candidate implementation analysis, not formal truth.
""".strip()

    schema_summary = """
Top-level required fields:
- stage
- source_scope
- functions
- macros_constants_types
- memory_and_pointer_facts
- candidate_code_level_facts
- uncertainties
- evidence_references
- limitations

Every major claim should include evidence references when possible, such as file name, line number, function name, macro name, contract line, or code excerpt identifier.
""".strip()

    return build_common_stage_prompt(
        stage_name="Agent 3 — Code Understanding Agent",
        task_description=task,
        responsibilities=responsibilities,
        prohibitions=prohibitions,
        schema_summary=schema_summary,
        include_non_copying_rule=False,
    )


def build_mock_code_summary(cfg: CodeUnderstandingConfig, code_meta: JsonDict, spec_summary_available: bool) -> JsonDict:
    return {
        "stage": "03_code_understanding",
        "mock": True,
        "llm_call_executed": False,
        "source_scope": {
            "primary_sources_used": [str(p) for p in cfg.code_paths],
            "provided_material_complete": False,
            "missing_or_unavailable_material": [
                "Mock mode was used, so no real LLM code understanding was executed."
            ],
            "previous_spec_summary_available": spec_summary_available,
        },
        "functions": [],
        "macros_constants_types": [],
        "loops_and_indexing": [],
        "memory_and_pointer_facts": [],
        "arithmetic_and_range_facts": [],
        "existing_contracts_assertions_annotations": [],
        "input_output_mutation_facts": [],
        "candidate_code_level_facts": [],
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
# Agent 2 handoff consumption
# ---------------------------------------------------------------------------

def load_agent2_spec_summary_if_available(layout: RunLayout) -> Tuple[Optional[Path], Optional[JsonDict], JsonDict]:
    """
    Load Agent 2 spec summary through handoff manifest if available.

    Returns:
        (path, data, status_record)
    """
    status = {
        "producer_stage": "02_spec_extraction",
        "output_key": "spec_summary",
        "available": False,
        "path": None,
        "warning": None,
    }

    try:
        path = layout.get_handoff("02_spec_extraction", "spec_summary")
        status["path"] = str(path)
        if not path.exists():
            status["warning"] = "Agent 2 handoff path exists in manifest but file is missing."
            return path, None, status

        data = read_json_file(path)
        status["available"] = True
        return path, data, status
    except Exception as exc:
        status["warning"] = f"Could not load Agent 2 spec summary handoff: {type(exc).__name__}: {exc}"
        return None, None, status


# ---------------------------------------------------------------------------
# Main Agent 3 runner
# ---------------------------------------------------------------------------

def run_agent3(config_data: JsonDict, cfg: CodeUnderstandingConfig) -> int:
    stage = "03_code_understanding"
    layout = RunLayout(cfg.run_dir, create=False)
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 3 Code Understanding started.",
        data={
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
            "code_paths": [str(p) for p in cfg.code_paths],
        },
    )

    stage_status: JsonDict = {
        "schema_version": "agent_status.v1",
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
        # 1. Load Agent 2 LLM spec summary if available.
        # --------------------------------------------------------------
        spec_summary_path, spec_summary_data, spec_status = load_agent2_spec_summary_if_available(layout)
        spec_summary_available = bool(spec_summary_data)
        if not spec_summary_available:
            stage_status["warnings"].append(spec_status.get("warning") or "Agent 2 spec summary unavailable.")
            if not cfg.allow_missing_agent2_spec_summary:
                raise FileNotFoundError("Agent 2 spec summary is required but unavailable.")

        prev_stage_record_path = layout.write_deterministic_reference_json(
            stage,
            "02_agent2_spec_summary_input_status.json",
            {
                "trust_boundary": "previous_llm_stage_candidate_context_not_formal_truth",
                "spec_summary_status": spec_status,
                "spec_summary_excerpt": spec_summary_data if spec_summary_data else None,
            },
        )

        # --------------------------------------------------------------
        # 2. Read code/header material.
        # --------------------------------------------------------------
        combined_code_text, code_meta, line_records = read_code_material(
            cfg.code_paths,
            max_chars=cfg.max_code_chars_for_deterministic,
        )

        source_meta_path = layout.write_deterministic_reference_json(
            stage,
            "02_source_material_read_report.deterministic.json",
            code_meta,
        )

        if not combined_code_text.strip():
            stage_status["warnings"].append("No local text could be read from implementation files.")

        # --------------------------------------------------------------
        # 3. Deterministic advisory extraction.
        # --------------------------------------------------------------
        deterministic = run_deterministic_code_reference_extraction(
            cfg=cfg,
            combined_code_text=combined_code_text,
            line_records=line_records,
        )

        deterministic_paths = write_deterministic_reference_files(layout, deterministic)
        deterministic_paths["source_material_read_report"] = source_meta_path
        deterministic_paths["agent2_spec_summary_input_status"] = prev_stage_record_path

        deterministic_bundle = {
            **deterministic,
            "source_material_read_report": code_meta,
        }
        prior_authoritative_context = {
            "agent2_spec_summary": {
                "trust_boundary": "previous_llm_stage_candidate_context_not_formal_truth",
                "available": spec_summary_available,
                "path": str(spec_summary_path) if spec_summary_path else None,
                "content": spec_summary_data,
            }
        }

        # --------------------------------------------------------------
        # 4. Build prompt and call shared LLM client.
        # --------------------------------------------------------------
        prompt_text = build_agent3_prompt(
            cfg=cfg,
            spec_summary_available=spec_summary_available,
        )

        run_config_for_client = dict(config_data)
        if cfg.llm_mode_override:
            llm_cfg = dict(run_config_for_client.get("llm") or {})
            llm_cfg["mode"] = cfg.llm_mode_override
            run_config_for_client["llm"] = llm_cfg

        client = LLMClient.from_run_config(run_config_for_client)

        # Raw specification and implementation files remain primary evidence.
        primary_files = existing_unique_paths(
            canonical_raw_evidence_files(config_data, include_specs=True, include_code=True)
            + [p for p in cfg.code_paths if Path(p).exists() and Path(p).is_file()]
        )

        request = LLMStageRequest(
            stage=stage,
            prompt_text=prompt_text,
            output_filename="02_code_summary.json",
            json_schema=CODE_SUMMARY_SCHEMA,
            primary_evidence_files=primary_files,
            prior_authoritative_context_files=[spec_summary_path] if spec_summary_path and spec_summary_path.exists() else [],
            prior_authoritative_context_bundle=prior_authoritative_context,
            deterministic_reference_bundle=deterministic_bundle,
            extra_prompt_metadata={
                "agent": "Agent 3 Code Understanding",
                "target_function": cfg.target_function,
                "target_topic": cfg.target_topic,
                "previous_agent2_spec_summary_available": spec_summary_available,
                "trust_boundary": {
                    "raw_code_headers": "primary_evidence",
                    "agent2_spec_summary": "previous_stage_candidate_context_not_formal_truth",
                    "deterministic_reference": "advisory_only",
                    "llm_output": "authoritative_stage_candidate_not_formal_truth",
                    "formal_truth": "not_claimed",
                },
            },
            mock_response_content=build_mock_code_summary(cfg, code_meta, spec_summary_available),
        )

        result = client.run_stage(layout, request)
        stage_status["llm_call_executed"] = result.llm_call_executed
        stage_status["llm_mode"] = result.mode
        stage_status["llm_success"] = result.success
        stage_status["llm_result"] = result.to_dict()

        # --------------------------------------------------------------
        # 5. Handoff manifest.
        # --------------------------------------------------------------
        if result.success and result.output_path:
            handoff_outputs: Dict[str, Path] = {
                "code_summary": Path(result.output_path),
            }

            if result.validation_path:
                handoff_outputs["code_summary_validation"] = Path(result.validation_path)

            # Useful advisory files for downstream audit, not authoritative.
            target_analysis_path = deterministic_paths.get("function_signature_analysis")
            if target_analysis_path:
                handoff_outputs["function_signature_analysis_advisory"] = target_analysis_path

            cbmc_hints_path = deterministic_paths.get("cbmc_harness_hints")
            if cbmc_hints_path:
                handoff_outputs["cbmc_harness_hints_advisory"] = cbmc_hints_path

            layout.write_handoff_manifest(
                stage,
                outputs=handoff_outputs,
                authoritative_source="llm_authoritative",
                next_stage_consumers=[
                    "04_property_discovery",
                    "05_artifact_generation",
                    "06_review_critic",
                    "08_counterexample_analysis",
                    "09_repair_refinement",
                    "11_evaluation_reporter",
                ],
                notes={
                    "handoff_policy": (
                        "code_summary is LLM-authoritative stage candidate output. "
                        "advisory handoff files are deterministic references only."
                    ),
                    "llm_mode": result.mode,
                    "llm_call_executed": result.llm_call_executed,
                    "mock_output": result.mode == "mock",
                    "agent2_spec_summary_available": spec_summary_available,
                },
            )
            stage_status["handoff_available"] = True
            stage_status["success"] = True
        else:
            message = (
                "No authoritative LLM code_summary was produced. "
                "Deterministic code analysis was not handed off as authoritative."
            )
            stage_status["warnings"].append(message)

            if cfg.allow_empty_handoff_on_failure:
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
        # 6. Stage manifest.
        # --------------------------------------------------------------
        llm_outputs = {}
        validation_outputs = {}
        prompt_outputs = {}

        if result.output_path:
            llm_outputs["code_summary"] = Path(result.output_path)
        if result.raw_response_path:
            llm_outputs["raw_llm_response"] = Path(result.raw_response_path)
        if result.validation_path:
            validation_outputs["llm_call_validation"] = Path(result.validation_path)
        if result.prompt_path:
            prompt_outputs["prompt"] = Path(result.prompt_path)
        if result.metadata_path:
            prompt_outputs["prompt_metadata"] = Path(result.metadata_path)

        pdir = layout.prompt_package_dir(stage)
        for name in ["deterministic_reference_bundle.json", "primary_evidence_manifest.json"]:
            p = pdir / name
            if p.exists():
                prompt_outputs[name.replace(".json", "")] = p

        layout.write_stage_manifest(
            stage,
            primary_evidence_inputs=[str(p) for p in cfg.code_paths],
            deterministic_reference_outputs=deterministic_paths,
            prompt_package_outputs=prompt_outputs,
            llm_authoritative_outputs=llm_outputs,
            validation_outputs=validation_outputs,
            notes={
                "agent_version": "agent3_code_understanding_refactored.v1",
                "deterministic_reference_policy": "advisory_only_not_authoritative",
                "agent2_spec_summary_available": spec_summary_available,
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
            },
        )

        stage_status["completed_utc"] = utc_now_iso()
        status_path = layout.logs_dir(stage) / "03_code_understanding_status.json"
        atomic_write_json(status_path, stage_status)

        layout.log_event(
            event_type="stage_completed" if stage_status["success"] else "stage_completed_without_handoff",
            stage=stage,
            message="Agent 3 Code Understanding completed.",
            data={
                "success": stage_status["success"],
                "handoff_available": stage_status["handoff_available"],
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
                "agent2_spec_summary_available": spec_summary_available,
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
        atomic_write_json(layout.logs_dir(stage) / "03_code_understanding_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 3 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        try:
            layout.write_stage_manifest(
                stage,
                primary_evidence_inputs=[str(p) for p in cfg.code_paths],
                notes={
                    "agent_version": "agent3_code_understanding_refactored.v1",
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
        description="Agent 3 — refactored LLM-backed Code Understanding Agent"
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
        "--code-path",
        help="Code/header file path(s). Comma-separated accepted.",
    )
    parser.add_argument(
        "--target-function",
        help="Implementation function name, e.g. mlk_poly_add.",
    )
    parser.add_argument(
        "--target-topic",
        help="Human-readable target topic.",
    )
    parser.add_argument(
        "--focus-terms",
        help="Comma-separated terms for deterministic advisory extraction.",
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
    return run_agent3(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
