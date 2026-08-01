#!/usr/bin/env python3
"""
Code Understanding Agent (Agent 3)
==================================

Purpose
-------
Reads selected C implementation code and related headers, then produces an
implementation-level summary for formal-verification artifact generation.

This agent follows the thesis guardrails:
- It does NOT claim the implementation is correct.
- It does NOT claim formal proof.
- It summarizes what the code appears to do from visible evidence.
- It records uncertainties instead of inventing missing facts.
- It prepares candidate implementation facts for later agents.

Designed to be called by:
    python3 agents/code_understanding_agent.py --config runs/.../run_config.resolved.json --run-dir runs/...

Output:
    runs/<run_id>/02_code_summary.json
    runs/<run_id>/02_code_summary.md
    runs/<run_id>/llm_prompts/02_code_understanding_prompt.txt
    runs/<run_id>/agent_status/02_code_understanding_status.json

Python: 3.10+
Dependencies: standard library only.

Optional future LLM mode
------------------------
This script is fully functional without an API key. It uses deterministic,
conservative C-code extraction. Later, you can add a local/API LLM wrapper by
setting:

{
  "code_understanding_settings": {
    "use_external_llm": true,
    "llm_command": ["python3", "my_llm_wrapper.py"]
  }
}

The command receives the structured prompt on stdin and should return JSON on
stdout. If it fails or returns invalid JSON, this agent safely falls back to
this deterministic extraction.
"""

from __future__ import annotations

import argparse
import csv
import dataclasses
import datetime as _dt
import hashlib
import json
import os
import re
import shlex
import subprocess
import sys
import textwrap
import traceback
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# Data models
# ---------------------------------------------------------------------------

@dataclasses.dataclass
class Evidence:
    """Evidence tying an extracted implementation fact to source lines."""

    source_file: str
    start_line: int
    end_line: int
    text: str

    def to_dict(self) -> Dict[str, Any]:
        return dataclasses.asdict(self)


@dataclasses.dataclass
class FunctionInfo:
    """Extracted target function information."""

    requested_name: str
    detected_name: str
    signature: str
    return_type: str
    parameters_raw: str
    parameters: List[Dict[str, Any]]
    source_file: str
    start_line: int
    end_line: int
    body: str
    body_hash_sha256: str
    matched_by: str


# ---------------------------------------------------------------------------
# Basic utilities
# ---------------------------------------------------------------------------

def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


def read_json(path: Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def write_json(path: Path, data: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    tmp.replace(path)


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
    out: List[str] = []
    for ch in value.strip().lower():
        if ch.isalnum():
            out.append(ch)
        elif ch in {"_", "-", "."}:
            out.append(ch)
        elif ch.isspace():
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
        "\u2264": "<=",
        "\u2265": ">=",
        "\ufffd": "",
        "\t": "    ",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text


def read_text_file(path: Path) -> str:
    if not path.exists():
        raise FileNotFoundError(f"File not found: {path}")
    return normalize_text(path.read_text(encoding="utf-8", errors="replace"))


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="replace")).hexdigest()


def compact_ws(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def nonempty_lines(text: str) -> List[str]:
    return [line.rstrip() for line in text.splitlines() if line.strip()]


def unique_preserve_order(items: Iterable[Any]) -> List[Any]:
    seen: set[str] = set()
    out: List[Any] = []
    for item in items:
        key = json.dumps(item, sort_keys=True, default=str) if isinstance(item, (dict, list)) else str(item)
        if key not in seen:
            seen.add(key)
            out.append(item)
    return out


# ---------------------------------------------------------------------------
# C text preprocessing and source line helpers
# ---------------------------------------------------------------------------

def strip_comments_preserve_lines(code: str) -> str:
    """Remove C comments while preserving line count and approximate columns."""
    result: List[str] = []
    i = 0
    n = len(code)
    in_block = False
    in_line = False
    in_string = False
    in_char = False
    escape = False

    while i < n:
        ch = code[i]
        nxt = code[i + 1] if i + 1 < n else ""

        if in_line:
            if ch == "\n":
                in_line = False
                result.append(ch)
            else:
                result.append(" ")
            i += 1
            continue

        if in_block:
            if ch == "*" and nxt == "/":
                result.append("  ")
                in_block = False
                i += 2
            else:
                result.append("\n" if ch == "\n" else " ")
                i += 1
            continue

        if in_string:
            result.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if in_char:
            result.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == "'":
                in_char = False
            i += 1
            continue

        if ch == "/" and nxt == "/":
            result.append("  ")
            in_line = True
            i += 2
        elif ch == "/" and nxt == "*":
            result.append("  ")
            in_block = True
            i += 2
        elif ch == '"':
            in_string = True
            result.append(ch)
            i += 1
        elif ch == "'":
            in_char = True
            result.append(ch)
            i += 1
        else:
            result.append(ch)
            i += 1

    return "".join(result)


def line_start_offsets(text: str) -> List[int]:
    offsets = [0]
    for match in re.finditer("\n", text):
        offsets.append(match.end())
    return offsets


def offset_to_line(offsets: Sequence[int], offset: int) -> int:
    # Small binary search without importing bisect? Import is standard, but simple is okay.
    lo, hi = 0, len(offsets)
    while lo < hi:
        mid = (lo + hi) // 2
        if offsets[mid] <= offset:
            lo = mid + 1
        else:
            hi = mid
    return max(1, lo)


def line_range_text(text: str, start_line: int, end_line: int, max_chars: int = 1200) -> str:
    lines = text.splitlines()
    start = max(1, start_line)
    end = min(len(lines), end_line)
    snippet = "\n".join(lines[start - 1:end]).strip()
    if len(snippet) > max_chars:
        snippet = snippet[:max_chars].rstrip() + " ..."
    return snippet


def evidence_from_lines(source_file: str, text: str, start_line: int, end_line: int, max_chars: int = 1200) -> Dict[str, Any]:
    return Evidence(
        source_file=source_file,
        start_line=start_line,
        end_line=end_line,
        text=line_range_text(text, start_line, end_line, max_chars=max_chars),
    ).to_dict()


# ---------------------------------------------------------------------------
# Macro, typedef, and struct extraction
# ---------------------------------------------------------------------------

def extract_macros(text: str, source_file: str) -> List[Dict[str, Any]]:
    macros: List[Dict[str, Any]] = []
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        if not line.lstrip().startswith("#define"):
            i += 1
            continue
        start = i
        macro_lines = [line.rstrip()]
        while macro_lines[-1].rstrip().endswith("\\") and i + 1 < len(lines):
            i += 1
            macro_lines.append(lines[i].rstrip())
        full = "\n".join(macro_lines)
        m = re.match(r"\s*#\s*define\s+([A-Za-z_][A-Za-z0-9_]*)(?:\(([^)]*)\))?\s*(.*)", full, re.S)
        if m:
            name = m.group(1)
            args = m.group(2)
            value = m.group(3).replace("\\\n", " ").strip()
            macros.append({
                "name": name,
                "kind": "function_like_macro" if args is not None else "object_like_macro",
                "arguments": [] if args is None else [a.strip() for a in args.split(",") if a.strip()],
                "value": value,
                "source_file": source_file,
                "start_line": start + 1,
                "end_line": i + 1,
                "evidence": Evidence(source_file, start + 1, i + 1, full.strip()).to_dict(),
            })
        i += 1
    return macros


def extract_includes(text: str, source_file: str) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for idx, line in enumerate(text.splitlines(), start=1):
        m = re.match(r"\s*#\s*include\s+([<\"].*[>\"])", line)
        if m:
            out.append({
                "include": m.group(1),
                "source_file": source_file,
                "line": idx,
                "evidence": Evidence(source_file, idx, idx, line.strip()).to_dict(),
            })
    return out


def extract_typedefs_and_structs(text: str, source_file: str) -> List[Dict[str, Any]]:
    """Conservative typedef/struct extraction for nearby type understanding."""
    clean = strip_comments_preserve_lines(text)
    offsets = line_start_offsets(clean)
    out: List[Dict[str, Any]] = []

    patterns = [
        ("typedef", re.compile(r"typedef\s+(.+?);", re.S)),
        ("struct_definition", re.compile(r"(?:typedef\s+)?struct\s+([A-Za-z_][A-Za-z0-9_]*)?\s*\{(.+?)\}\s*([A-Za-z_][A-Za-z0-9_]*)?\s*;", re.S)),
    ]
    for kind, pat in patterns:
        for m in pat.finditer(clean):
            start_line = offset_to_line(offsets, m.start())
            end_line = offset_to_line(offsets, m.end())
            raw = line_range_text(text, start_line, end_line, max_chars=2000)
            names = re.findall(r"\b[A-Za-z_][A-Za-z0-9_]*\b", raw)
            out.append({
                "kind": kind,
                "names_detected": names[-6:],
                "source_file": source_file,
                "start_line": start_line,
                "end_line": end_line,
                "summary": compact_ws(raw)[:500],
                "evidence": Evidence(source_file, start_line, end_line, raw[:2000]).to_dict(),
            })
    return unique_preserve_order(out)


# ---------------------------------------------------------------------------
# Function extraction
# ---------------------------------------------------------------------------

C_CONTROL_KEYWORDS = {
    "if", "for", "while", "switch", "return", "sizeof", "do", "case",
    "typedef", "struct", "union", "enum", "__CPROVER_assume", "assert",
}

C_QUALIFIERS = {
    "const", "volatile", "restrict", "static", "inline", "extern", "register",
    "signed", "unsigned", "long", "short", "struct", "union", "enum",
}


def target_name_variants(target_function: str) -> List[str]:
    base = target_function.strip()
    variants = [base]
    # mlkem-native often uses namespacing prefixes after macro expansion / build setup.
    if not base.startswith("mlk_"):
        variants.append("mlk_" + base)
    if base.startswith("poly_"):
        variants.append("mlk_" + base)
    # If user passes a namespaced form, also try the short tail.
    if base.startswith("mlk_"):
        variants.append(base[4:])
    return unique_preserve_order([v for v in variants if v])


def find_matching_paren(text: str, open_index: int) -> int:
    depth = 0
    in_string = False
    in_char = False
    escape = False
    for i in range(open_index, len(text)):
        ch = text[i]
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
        if ch == '"':
            in_string = True
        elif ch == "'":
            in_char = True
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i
    return -1


def find_matching_brace(text: str, open_index: int) -> int:
    depth = 0
    in_string = False
    in_char = False
    escape = False
    for i in range(open_index, len(text)):
        ch = text[i]
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
        if ch == '"':
            in_string = True
        elif ch == "'":
            in_char = True
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
    return -1


def find_signature_start(clean: str, name_start: int) -> int:
    """Find likely start of C function signature before function name."""
    # Walk backward until a hard boundary. Allow multi-line return type/signature.
    boundaries = [clean.rfind(";", 0, name_start), clean.rfind("}", 0, name_start), clean.rfind("{", 0, name_start)]
    boundary = max(boundaries)
    candidate = boundary + 1
    # Also avoid swallowing preprocessor lines or unrelated blank-separated blocks.
    segment = clean[candidate:name_start]
    lines = segment.splitlines()
    keep: List[str] = []
    for line in reversed(lines):
        stripped = line.strip()
        if not stripped:
            if keep:
                break
            continue
        if stripped.startswith("#"):
            break
        keep.append(line)
        # Most normal function definitions have return type in one or two lines.
        if len(keep) >= 8:
            break
    if keep:
        prefix = "\n".join(reversed(keep))
        relative_start = segment.rfind(prefix)
        if relative_start >= 0:
            return candidate + relative_start
    return candidate


def parse_parameters(parameters_raw: str) -> List[Dict[str, Any]]:
    raw = parameters_raw.strip()
    if not raw or raw == "void":
        return []

    parts: List[str] = []
    current: List[str] = []
    depth = 0
    for ch in raw:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth = max(0, depth - 1)
        if ch == "," and depth == 0:
            part = "".join(current).strip()
            if part:
                parts.append(part)
            current = []
        else:
            current.append(ch)
    tail = "".join(current).strip()
    if tail:
        parts.append(tail)

    parsed: List[Dict[str, Any]] = []
    for idx, part in enumerate(parts):
        clean = compact_ws(part)
        # Function pointer parameter fallback.
        fp = re.search(r"\(\s*\*\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)", clean)
        if fp:
            name = fp.group(1)
        else:
            # Remove array suffix from final name.
            tmp = re.sub(r"\[[^\]]*\]", "", clean).strip()
            tokens = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", tmp)
            name = tokens[-1] if tokens else f"param_{idx}"
        pointer_depth = clean.count("*")
        is_const = bool(re.search(r"\bconst\b", clean))
        is_array = "[" in clean and "]" in clean
        parsed.append({
            "index": idx,
            "raw": clean,
            "name": name,
            "type_guess": clean.rsplit(name, 1)[0].strip() if name in clean else clean,
            "is_pointer": pointer_depth > 0 or is_array,
            "pointer_depth": pointer_depth,
            "is_const": is_const,
            "is_array_syntax": is_array,
            "direction_guess": classify_parameter_direction(clean, name),
        })
    return parsed


def classify_parameter_direction(raw: str, name: str) -> str:
    # Direction is a candidate inference only. Later checks refine it by writes.
    if "*" not in raw and "[" not in raw:
        return "value_input"
    if re.search(r"\bconst\b", raw):
        return "input_pointer_candidate"
    # Common C convention: first non-const pointer named r/out/dst is output.
    if name in {"r", "out", "dst", "dest", "result", "ret"}:
        return "output_pointer_candidate"
    return "mutable_pointer_candidate"


def parse_signature(signature: str, detected_name: str) -> Tuple[str, str, List[Dict[str, Any]]]:
    sig = compact_ws(signature)
    name_match = re.search(rf"\b{re.escape(detected_name)}\s*\(", sig)
    if not name_match:
        return "unknown", "", []
    before = sig[:name_match.start()].strip()
    open_paren = name_match.end() - 1
    close_paren = find_matching_paren(sig, open_paren)
    params_raw = sig[open_paren + 1:close_paren] if close_paren != -1 else ""
    return_type = before or "unknown"
    return return_type, params_raw, parse_parameters(params_raw)


def extract_target_function(source_text: str, source_file: str, target_function: str) -> FunctionInfo:
    clean = strip_comments_preserve_lines(source_text)
    offsets = line_start_offsets(clean)
    variants = target_name_variants(target_function)

    candidate_errors: List[str] = []
    for variant in variants:
        pattern = re.compile(rf"(?<![A-Za-z0-9_]){re.escape(variant)}\s*\(")
        for m in pattern.finditer(clean):
            name_start = m.start()
            # Reject obvious calls/control contexts by checking token before name.
            prefix_segment = clean[max(0, name_start - 80):name_start]
            prev_tokens = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", prefix_segment)
            if prev_tokens and prev_tokens[-1] in C_CONTROL_KEYWORDS:
                continue

            open_paren = clean.find("(", m.start(), m.end() + 2)
            close_paren = find_matching_paren(clean, open_paren)
            if close_paren == -1:
                candidate_errors.append(f"Could not match parameter ')' for {variant} at offset {m.start()}")
                continue
            after = clean[close_paren + 1: close_paren + 500]
            brace_rel = after.find("{")
            semi_rel = after.find(";")
            if brace_rel == -1:
                continue
            if semi_rel != -1 and semi_rel < brace_rel:
                # Prototype/declaration, not definition.
                continue
            brace_index = close_paren + 1 + brace_rel
            end_index = find_matching_brace(clean, brace_index)
            if end_index == -1:
                candidate_errors.append(f"Could not match body '}}' for {variant} at line {offset_to_line(offsets, brace_index)}")
                continue

            sig_start = find_signature_start(clean, name_start)
            start_line = offset_to_line(offsets, sig_start)
            end_line = offset_to_line(offsets, end_index)
            signature = source_text[sig_start:brace_index].strip()
            body = source_text[brace_index:end_index + 1]
            return_type, params_raw, parameters = parse_signature(signature, variant)
            return FunctionInfo(
                requested_name=target_function,
                detected_name=variant,
                signature=signature,
                return_type=return_type,
                parameters_raw=params_raw,
                parameters=parameters,
                source_file=source_file,
                start_line=start_line,
                end_line=end_line,
                body=body,
                body_hash_sha256=sha256_text(body),
                matched_by="exact_or_known_mlkem_variant",
            )

    msg = f"Could not find a C function definition for target '{target_function}'. Tried variants: {variants}."
    if candidate_errors:
        msg += " Candidate parse errors: " + "; ".join(candidate_errors[:5])
    raise ValueError(msg)


# ---------------------------------------------------------------------------
# Function body analysis
# ---------------------------------------------------------------------------

def make_body_line_map(function: FunctionInfo) -> Tuple[str, List[str]]:
    body = function.body
    return body, body.splitlines()


def absolute_line(function: FunctionInfo, body_relative_line: int) -> int:
    # body_relative_line is 1-based inside body.
    signature_line_count = max(0, function.body[:0].count("\n"))
    return function.start_line + body_relative_line - 1


def extract_local_variables(function: FunctionInfo) -> List[Dict[str, Any]]:
    body_clean = strip_comments_preserve_lines(function.body)
    lines = body_clean.splitlines()
    out: List[Dict[str, Any]] = []
    type_words = r"(?:const\s+)?(?:unsigned\s+|signed\s+)?(?:int|char|short|long|size_t|uint\d+_t|int\d+_t|bool|poly|mlk_poly|[A-Za-z_][A-Za-z0-9_]*)(?:\s*\*)*"
    decl_re = re.compile(rf"^\s*({type_words})\s+([^;()]+);\s*$")
    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("for") or stripped.startswith("if") or stripped.startswith("while"):
            continue
        m = decl_re.match(line)
        if not m:
            continue
        typ = compact_ws(m.group(1))
        rest = m.group(2).strip()
        # Split declarations like unsigned int i, j = 0; conservatively.
        names = []
        for part in rest.split(","):
            part = part.split("=")[0].strip()
            part = part.replace("*", " ").strip()
            arr = re.sub(r"\[[^\]]*\]", "", part).strip()
            toks = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", arr)
            if toks:
                names.append(toks[-1])
        if names:
            out.append({
                "type": typ,
                "names": names,
                "line": function.start_line + idx - 1,
                "evidence": Evidence(function.source_file, function.start_line + idx - 1, function.start_line + idx - 1, stripped).to_dict(),
            })
    return unique_preserve_order(out)


def extract_loops(function: FunctionInfo) -> List[Dict[str, Any]]:
    body_clean = strip_comments_preserve_lines(function.body)
    out: List[Dict[str, Any]] = []
    offsets = line_start_offsets(body_clean)
    for m in re.finditer(r"\bfor\s*\((.*?)\)\s*\{?", body_clean, re.S):
        content = compact_ws(m.group(1))
        parts = [p.strip() for p in content.split(";")]
        loop: Dict[str, Any] = {
            "kind": "for",
            "raw": content,
            "line": function.start_line + offset_to_line(offsets, m.start()) - 1,
            "init": parts[0] if len(parts) > 0 else "",
            "condition": parts[1] if len(parts) > 1 else "",
            "increment": parts[2] if len(parts) > 2 else "",
            "loop_variable_guess": None,
        }
        var_match = re.search(r"(?:^|\s)([A-Za-z_][A-Za-z0-9_]*)\s*=", loop["init"])
        if not var_match:
            var_match = re.search(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*(?:\+\+|--)", loop["increment"])
        if var_match:
            loop["loop_variable_guess"] = var_match.group(1)
        loop["evidence"] = Evidence(function.source_file, loop["line"], loop["line"], line_range_text(function.body, offset_to_line(offsets, m.start()), offset_to_line(offsets, m.start()))).to_dict()
        out.append(loop)

    for m in re.finditer(r"\bwhile\s*\((.*?)\)\s*\{?", body_clean, re.S):
        content = compact_ws(m.group(1))
        line = function.start_line + offset_to_line(offsets, m.start()) - 1
        out.append({
            "kind": "while",
            "raw": content,
            "line": line,
            "condition": content,
            "evidence": Evidence(function.source_file, line, line, line_range_text(function.body, offset_to_line(offsets, m.start()), offset_to_line(offsets, m.start()))).to_dict(),
        })
    return unique_preserve_order(out)


def extract_conditionals(function: FunctionInfo) -> List[Dict[str, Any]]:
    body_clean = strip_comments_preserve_lines(function.body)
    offsets = line_start_offsets(body_clean)
    out: List[Dict[str, Any]] = []
    for keyword in ["if", "switch"]:
        for m in re.finditer(rf"\b{keyword}\s*\((.*?)\)", body_clean, re.S):
            cond = compact_ws(m.group(1))
            line = function.start_line + offset_to_line(offsets, m.start()) - 1
            out.append({
                "kind": keyword,
                "condition": cond,
                "line": line,
                "evidence": Evidence(function.source_file, line, line, line_range_text(function.body, offset_to_line(offsets, m.start()), offset_to_line(offsets, m.start()))).to_dict(),
            })
    return unique_preserve_order(out)


def extract_array_accesses(function: FunctionInfo) -> List[Dict[str, Any]]:
    body_clean = strip_comments_preserve_lines(function.body)
    offsets = line_start_offsets(body_clean)
    out: List[Dict[str, Any]] = []
    access_re = re.compile(r"((?:[A-Za-z_][A-Za-z0-9_]*\s*(?:->|\.)\s*)?[A-Za-z_][A-Za-z0-9_]*)\s*\[\s*([^\]]+)\s*\]")
    for m in access_re.finditer(body_clean):
        expr = compact_ws(m.group(0))
        base = compact_ws(m.group(1).replace(" ", ""))
        index = compact_ws(m.group(2))
        line = function.start_line + offset_to_line(offsets, m.start()) - 1
        line_text = line_range_text(function.body, offset_to_line(offsets, m.start()), offset_to_line(offsets, m.start()))
        access_context = classify_access_context(line_text, expr)
        out.append({
            "expression": expr,
            "base": base,
            "index": index,
            "line": line,
            "access_context_guess": access_context,
            "evidence": Evidence(function.source_file, line, line, line_text.strip()).to_dict(),
        })
    return unique_preserve_order(out)


def classify_access_context(line_text: str, expr: str) -> str:
    stripped = line_text.strip()
    if "=" in stripped:
        lhs = stripped.split("=", 1)[0]
        if expr in lhs:
            if any(op in lhs for op in ["+=", "-=", "*=", "/=", "%=", "^=", "|=", "&="]):
                return "read_write_candidate"
            return "write_candidate"
    return "read_candidate"


def extract_pointer_accesses(function: FunctionInfo) -> List[Dict[str, Any]]:
    body_clean = strip_comments_preserve_lines(function.body)
    offsets = line_start_offsets(body_clean)
    out: List[Dict[str, Any]] = []
    for m in re.finditer(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*->\s*([A-Za-z_][A-Za-z0-9_]*)", body_clean):
        expr = f"{m.group(1)}->{m.group(2)}"
        line = function.start_line + offset_to_line(offsets, m.start()) - 1
        line_text = line_range_text(function.body, offset_to_line(offsets, m.start()), offset_to_line(offsets, m.start()))
        out.append({
            "expression": expr,
            "pointer": m.group(1),
            "field": m.group(2),
            "line": line,
            "access_context_guess": classify_access_context(line_text, expr),
            "evidence": Evidence(function.source_file, line, line, line_text.strip()).to_dict(),
        })
    for m in re.finditer(r"(?<![\w])\*\s*([A-Za-z_][A-Za-z0-9_]*)", body_clean):
        name = m.group(1)
        if name in {"if", "for", "while", "return"}:
            continue
        line = function.start_line + offset_to_line(offsets, m.start()) - 1
        line_text = line_range_text(function.body, offset_to_line(offsets, m.start()), offset_to_line(offsets, m.start()))
        out.append({
            "expression": f"*{name}",
            "pointer": name,
            "field": None,
            "line": line,
            "access_context_guess": classify_access_context(line_text, f"*{name}"),
            "evidence": Evidence(function.source_file, line, line, line_text.strip()).to_dict(),
        })
    return unique_preserve_order(out)


def extract_assignments_and_writes(function: FunctionInfo) -> List[Dict[str, Any]]:
    lines = strip_comments_preserve_lines(function.body).splitlines()
    out: List[Dict[str, Any]] = []
    assign_re = re.compile(r"(?P<lhs>.+?)\s*(?P<op>\+=|-=|\*=|/=|%=|<<=|>>=|&=|\|=|\^=|(?<![=!<>])=(?!=))\s*(?P<rhs>.+?);\s*$")
    for rel, line in enumerate(lines, start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("for") or stripped.startswith("if") or stripped.startswith("while"):
            continue
        m = assign_re.search(stripped)
        if not m:
            continue
        lhs = compact_ws(m.group("lhs"))
        rhs = compact_ws(m.group("rhs"))
        op = m.group("op")
        abs_line = function.start_line + rel - 1
        out.append({
            "lhs": lhs,
            "operator": op,
            "rhs": rhs,
            "line": abs_line,
            "write_kind_guess": "compound_read_write" if op != "=" else "assignment_write",
            "evidence": Evidence(function.source_file, abs_line, abs_line, stripped).to_dict(),
        })
    return unique_preserve_order(out)


def extract_function_calls(function: FunctionInfo) -> List[Dict[str, Any]]:
    body_clean = strip_comments_preserve_lines(function.body)
    offsets = line_start_offsets(body_clean)
    out: List[Dict[str, Any]] = []
    call_re = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*\(")
    for m in call_re.finditer(body_clean):
        name = m.group(1)
        if name in C_CONTROL_KEYWORDS or name == function.detected_name:
            continue
        # Avoid macro-like cast false positives is hard; keep as candidate.
        open_paren = body_clean.find("(", m.start(), m.end() + 2)
        close = find_matching_paren(body_clean, open_paren)
        args_raw = body_clean[open_paren + 1:close] if close != -1 else ""
        line = function.start_line + offset_to_line(offsets, m.start()) - 1
        line_text = line_range_text(function.body, offset_to_line(offsets, m.start()), offset_to_line(offsets, m.start()))
        out.append({
            "name": name,
            "arguments_raw": compact_ws(args_raw),
            "line": line,
            "evidence": Evidence(function.source_file, line, line, line_text.strip()).to_dict(),
        })
    return unique_preserve_order(out)


def extract_integer_and_bit_operations(function: FunctionInfo) -> List[Dict[str, Any]]:
    lines = strip_comments_preserve_lines(function.body).splitlines()
    out: List[Dict[str, Any]] = []
    op_patterns = [
        ("addition", "+"),
        ("subtraction", "-"),
        ("multiplication", "*"),
        ("division", "/"),
        ("modulus", "%"),
        ("left_shift", "<<"),
        ("right_shift", ">>"),
        ("bitwise_and", "&"),
        ("bitwise_or", "|"),
        ("bitwise_xor", "^"),
    ]
    for rel, line in enumerate(lines, start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        detected: List[str] = []
        for kind, op in op_patterns:
            if op in stripped:
                # Avoid treating pointer declarator/dereference as multiplication too eagerly.
                if kind == "multiplication" and re.match(r"^[A-Za-z_][\w\s]*\s+\*\s*[A-Za-z_]", stripped):
                    continue
                detected.append(kind)
        if detected:
            abs_line = function.start_line + rel - 1
            out.append({
                "operations": sorted(set(detected)),
                "line": abs_line,
                "statement": compact_ws(stripped),
                "evidence": Evidence(function.source_file, abs_line, abs_line, stripped).to_dict(),
            })
    return unique_preserve_order(out)


def extract_return_statements(function: FunctionInfo) -> List[Dict[str, Any]]:
    lines = strip_comments_preserve_lines(function.body).splitlines()
    out: List[Dict[str, Any]] = []
    for rel, line in enumerate(lines, start=1):
        m = re.search(r"\breturn\b\s*(.*?);", line)
        if m:
            abs_line = function.start_line + rel - 1
            out.append({
                "expression": compact_ws(m.group(1)),
                "line": abs_line,
                "evidence": Evidence(function.source_file, abs_line, abs_line, line.strip()).to_dict(),
            })
    return out


# ---------------------------------------------------------------------------
# Higher-level interpretation
# ---------------------------------------------------------------------------

def summarize_behavior(function: FunctionInfo, loops: List[Dict[str, Any]], writes: List[Dict[str, Any]], calls: List[Dict[str, Any]]) -> str:
    detected_name = function.detected_name
    param_names = [p["name"] for p in function.parameters]
    output_params = [p["name"] for p in function.parameters if p.get("direction_guess") in {"output_pointer_candidate", "mutable_pointer_candidate"}]
    const_inputs = [p["name"] for p in function.parameters if p.get("direction_guess") == "input_pointer_candidate"]

    parts: List[str] = []
    parts.append(f"The function `{detected_name}` appears to be a C implementation function with return type `{function.return_type}`.")
    if param_names:
        parts.append(f"It receives parameters: {', '.join(param_names)}.")
    if const_inputs:
        parts.append(f"The const pointer parameters {', '.join(const_inputs)} are likely read-only inputs.")
    if output_params:
        parts.append(f"The mutable pointer/value parameters {', '.join(output_params)} may be outputs or in/out values and require validity assumptions.")
    if loops:
        loop_bits = []
        for loop in loops[:3]:
            if loop.get("kind") == "for":
                loop_bits.append(f"for-loop with condition `{loop.get('condition', '')}`")
            else:
                loop_bits.append(f"{loop.get('kind')} loop with condition `{loop.get('condition', '')}`")
        parts.append("It contains " + "; ".join(loop_bits) + ".")
    if writes:
        parts.append(f"It performs {len(writes)} detected assignment/write statement(s), including `{writes[0].get('lhs')}`.")
    if calls:
        parts.append("It calls helper/candidate functions such as " + ", ".join(c["name"] for c in calls[:6]) + ".")
    parts.append("This is an implementation summary only; the later formal tool and human review must confirm whether the behavior satisfies the intended specification.")
    return " ".join(parts)


def build_inputs_outputs(function: FunctionInfo, writes: List[Dict[str, Any]]) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    written_names: set[str] = set()
    for w in writes:
        lhs = w.get("lhs", "")
        m = re.match(r"\(?\s*([A-Za-z_][A-Za-z0-9_]*)", lhs)
        if m:
            written_names.add(m.group(1))

    inputs: List[Dict[str, Any]] = []
    outputs: List[Dict[str, Any]] = []
    for p in function.parameters:
        item = dict(p)
        item["evidence"] = Evidence(function.source_file, function.start_line, function.start_line, function.signature.splitlines()[0].strip()).to_dict()
        name = p["name"]
        if p.get("is_const"):
            inputs.append(item)
        elif name in written_names or p.get("direction_guess") in {"output_pointer_candidate", "mutable_pointer_candidate"}:
            outputs.append(item)
            if not p.get("is_pointer") and p.get("direction_guess") == "value_input":
                inputs.append(item)
        else:
            inputs.append(item)
    return inputs, outputs


def filter_relevant_macros(macros: List[Dict[str, Any]], function: FunctionInfo, headers_text: str) -> List[Dict[str, Any]]:
    body = function.body
    sig = function.signature
    relevant: List[Dict[str, Any]] = []
    for macro in macros:
        name = macro.get("name", "")
        value = str(macro.get("value", ""))
        if not name:
            continue
        # Keep macros directly used in function or likely ML-KEM constants.
        if re.search(rf"\b{re.escape(name)}\b", body) or re.search(rf"\b{re.escape(name)}\b", sig):
            relevant.append(macro)
        elif name.upper() in {"N", "Q", "KYBER_N", "KYBER_Q", "MLKEM_N", "MLKEM_Q", "MLK_N", "MLK_Q"}:
            relevant.append(macro)
        elif re.search(r"\b(256|3329|128|768|1024)\b", value) and any(tok in name.upper() for tok in ["N", "Q", "KYBER", "MLK", "POLY"]):
            relevant.append(macro)
    return unique_preserve_order(relevant)


def filter_relevant_typedefs(typedefs: List[Dict[str, Any]], function: FunctionInfo) -> List[Dict[str, Any]]:
    signature_words = set(re.findall(r"\b[A-Za-z_][A-Za-z0-9_]*\b", function.signature))
    relevant: List[Dict[str, Any]] = []
    for td in typedefs:
        names = set(td.get("names_detected", []))
        if names & signature_words:
            relevant.append(td)
        elif any(name in {"poly", "mlk_poly", "polyvec", "mlk_polyvec"} for name in names):
            relevant.append(td)
    return unique_preserve_order(relevant)


def build_possible_properties(
    function: FunctionInfo,
    inputs: List[Dict[str, Any]],
    outputs: List[Dict[str, Any]],
    loops: List[Dict[str, Any]],
    array_accesses: List[Dict[str, Any]],
    pointer_accesses: List[Dict[str, Any]],
    int_ops: List[Dict[str, Any]],
    writes: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    props: List[Dict[str, Any]] = []
    prop_id = 1

    def add(kind: str, description: str, priority: str, evidence: Optional[Dict[str, Any]] = None) -> None:
        nonlocal prop_id
        props.append({
            "id": f"C{prop_id}",
            "type": kind,
            "description": description,
            "formal_tool_relevance": "CBMC",
            "priority": priority,
            "source": "code_understanding_agent_candidate",
            "evidence": evidence,
        })
        prop_id += 1

    for out in outputs:
        if out.get("is_pointer"):
            add(
                "pointer_validity",
                f"Pointer/output parameter `{out['name']}` should refer to a valid object before `{function.detected_name}` writes through it.",
                "high",
                out.get("evidence"),
            )
    for inp in inputs:
        if inp.get("is_pointer"):
            add(
                "input_pointer_validity",
                f"Input pointer parameter `{inp['name']}` should refer to a valid readable object for the duration of `{function.detected_name}`.",
                "high",
                inp.get("evidence"),
            )
    if array_accesses:
        add(
            "array_bounds",
            "Every detected array access should stay within the valid bounds of its base object.",
            "high",
            array_accesses[0].get("evidence"),
        )
    for loop in loops:
        cond = loop.get("condition") or loop.get("raw") or "unknown condition"
        add(
            "loop_bound",
            f"Loop condition `{cond}` should restrict the loop variable to valid implementation bounds.",
            "high",
            loop.get("evidence"),
        )
    if any("addition" in item.get("operations", []) or "subtraction" in item.get("operations", []) or "multiplication" in item.get("operations", []) for item in int_ops):
        add(
            "integer_overflow",
            "Arithmetic operations should not trigger signed/unsigned overflow under documented preconditions.",
            "medium",
            int_ops[0].get("evidence") if int_ops else None,
        )
    if writes:
        lhs_examples = ", ".join(w.get("lhs", "?") for w in writes[:3])
        add(
            "functional_update_shape",
            f"The write target(s) `{lhs_examples}` should match the intended implementation-level update described by the selected property.",
            "medium",
            writes[0].get("evidence"),
        )
    if pointer_accesses:
        add(
            "memory_safety",
            "Pointer field/dereference accesses should be memory-safe under the harness assumptions.",
            "high",
            pointer_accesses[0].get("evidence"),
        )

    return props


def build_risks_and_uncertainties(
    function: FunctionInfo,
    macros: List[Dict[str, Any]],
    relevant_typedefs: List[Dict[str, Any]],
    loops: List[Dict[str, Any]],
    array_accesses: List[Dict[str, Any]],
    pointer_accesses: List[Dict[str, Any]],
    int_ops: List[Dict[str, Any]],
    calls: List[Dict[str, Any]],
) -> Tuple[List[Dict[str, Any]], List[str]]:
    risks: List[Dict[str, Any]] = []
    uncertainties: List[str] = []

    if pointer_accesses or any(p.get("is_pointer") for p in function.parameters):
        risks.append({
            "type": "pointer_validity",
            "severity": "high",
            "message": "The function uses pointer parameters or pointer dereferences; CBMC harnesses must create valid objects and pass valid addresses.",
        })
    if array_accesses:
        risks.append({
            "type": "array_bounds",
            "severity": "high",
            "message": "The function contains array accesses; later properties should check bounds and unwind loops sufficiently.",
        })
    if int_ops:
        op_kinds = sorted({op for item in int_ops for op in item.get("operations", [])})
        risks.append({
            "type": "integer_behavior",
            "severity": "medium",
            "message": f"The function contains arithmetic/bit operations {op_kinds}; overflow and bit-width assumptions must be checked explicitly.",
        })
    if calls:
        risks.append({
            "type": "helper_dependency",
            "severity": "medium",
            "message": "The function calls helper functions/macros; the harness or CBMC command may need related source files or stubs.",
        })
    if loops and not macros:
        uncertainties.append("Loop bounds were detected, but no relevant macro/constants were found from headers/source. Confirm loop limits manually.")
    if any("condition" in loop and re.search(r"[A-Za-z_][A-Za-z0-9_]*", str(loop.get("condition"))) for loop in loops) and not macros:
        uncertainties.append("Loop conditions may depend on macros or constants not resolved by this agent.")
    if not relevant_typedefs:
        uncertainties.append("The exact struct/type definition used by the function signature was not confidently resolved from the provided headers/source.")
    if function.return_type == "unknown":
        uncertainties.append("Return type could not be confidently parsed from the function signature.")
    if function.detected_name != function.requested_name:
        uncertainties.append(f"Requested function `{function.requested_name}` was matched as `{function.detected_name}` using known naming variants. Confirm this namespacing is correct.")
    uncertainties.append("This code summary is not a proof. Later CBMC execution and human review must validate candidate properties and assumptions.")
    return risks, unique_preserve_order(uncertainties)


def build_cbmc_hints(
    function: FunctionInfo,
    inputs: List[Dict[str, Any]],
    outputs: List[Dict[str, Any]],
    loops: List[Dict[str, Any]],
    macros: List[Dict[str, Any]],
    calls: List[Dict[str, Any]],
) -> Dict[str, Any]:
    unwind_guess: Optional[int] = None
    loop_bounds: List[str] = []
    for loop in loops:
        cond = str(loop.get("condition", ""))
        loop_bounds.append(cond)
        m = re.search(r"<\s*(\d+)", cond)
        if m:
            unwind_guess = max(unwind_guess or 0, int(m.group(1)))
        for macro in macros:
            name = macro.get("name")
            value = str(macro.get("value", ""))
            if name and re.search(rf"\b{re.escape(str(name))}\b", cond):
                vm = re.search(r"\b(\d+)\b", value)
                if vm:
                    unwind_guess = max(unwind_guess or 0, int(vm.group(1)))

    object_setup: List[str] = []
    for p in inputs + outputs:
        if p.get("is_pointer"):
            object_setup.append(f"Create a concrete object for pointer parameter `{p['name']}` and pass its address to `{function.detected_name}`.")
        else:
            object_setup.append(f"Use nondeterministic value or documented constant for value parameter `{p['name']}`.")

    checks = ["--bounds-check", "--pointer-check"]
    if function.return_type != "void":
        checks.append("check return value against selected property if specification gives one")
    checks.extend(["--signed-overflow-check", "--unsigned-overflow-check"])

    return {
        "target_function_for_harness_call": function.detected_name,
        "suggested_cbmc_function": f"harness_{safe_name(function.requested_name)}",
        "object_setup_hints": unique_preserve_order(object_setup),
        "loop_bound_expressions": loop_bounds,
        "unwind_guess": unwind_guess,
        "recommended_checks": unique_preserve_order(checks),
        "helper_sources_or_stubs_may_be_needed": [c["name"] for c in calls],
        "assumption_warning": "Do not invent input ranges from code alone. Use spec summary + type definitions + human review before adding __CPROVER_assume constraints.",
    }


def build_dependencies(
    function: FunctionInfo,
    source_file: Path,
    header_files: List[Path],
    includes: List[Dict[str, Any]],
    macros: List[Dict[str, Any]],
    typedefs: List[Dict[str, Any]],
    calls: List[Dict[str, Any]],
) -> Dict[str, Any]:
    return {
        "source_file": str(source_file),
        "header_files": [str(p) for p in header_files],
        "includes_detected": includes,
        "relevant_macros_or_constants": macros,
        "relevant_type_definitions": typedefs,
        "helper_function_or_macro_calls": calls,
        "dependency_warning": "The next agents must ensure CBMC receives all required source/header files or safe stubs for unresolved helpers.",
    }


# ---------------------------------------------------------------------------
# Prompt and optional external LLM hook
# ---------------------------------------------------------------------------

def build_structured_prompt(
    target_scheme: str,
    target_function: str,
    verification_goal: str,
    source_file: str,
    header_files: List[str],
    function: FunctionInfo,
    relevant_headers_excerpt: str,
) -> str:
    body_excerpt = function.body
    if len(body_excerpt) > 12000:
        body_excerpt = body_excerpt[:12000] + "\n/* ... truncated for prompt ... */"
    headers_excerpt = relevant_headers_excerpt
    if len(headers_excerpt) > 10000:
        headers_excerpt = headers_excerpt[:10000] + "\n/* ... headers truncated for prompt ... */"

    return textwrap.dedent(
        f"""
        You are the Code Understanding Agent in an AI-assisted formal-verification workflow.

        Scientific guardrails:
        - Do not claim this proves the implementation.
        - Do not invent facts that are not visible in the code/header evidence.
        - Mark uncertain points as uncertainties.
        - Focus on implementation-level facts useful for CBMC harness/assertion generation.

        Target scheme: {target_scheme}
        Target function requested: {target_function}
        Target function detected: {function.detected_name}
        Verification goal: {verification_goal}
        Source file: {source_file}
        Header files: {header_files}

        Task:
        1. Summarize what the selected C function appears to do.
        2. Identify function signature, input parameters, output/in-out parameters.
        3. Identify loops and loop bounds.
        4. Identify array accesses and pointer dereferences.
        5. Identify output writes and assignment updates.
        6. Identify helper function/macro calls.
        7. Identify integer, bitwise, and memory-safety risks.
        8. Identify candidate implementation-level properties for CBMC.
        9. Identify dependencies and unresolved uncertainties.
        10. Avoid unsupported claims.

        Function signature:
        {function.signature}

        Function body:
        ```c
        {body_excerpt}
        ```

        Relevant header/source excerpt:
        ```c
        {headers_excerpt}
        ```

        Return JSON only if using external LLM mode.
        """
    ).strip() + "\n"


def run_external_llm_if_enabled(
    config: Dict[str, Any],
    prompt: str,
    run_dir: Path,
    event_log_path: Path,
) -> Optional[Dict[str, Any]]:
    settings = config.get("code_understanding_settings", {})
    if not isinstance(settings, dict):
        settings = {}
    if not settings.get("use_external_llm", False):
        return None

    cmd = settings.get("llm_command")
    if not cmd:
        append_jsonl(event_log_path, {"timestamp": utc_now(), "event_type": "code_llm_skipped", "reason": "use_external_llm=true but llm_command missing"})
        return None

    if isinstance(cmd, str):
        command = shlex.split(cmd)
    elif isinstance(cmd, list):
        command = [str(x) for x in cmd]
    else:
        append_jsonl(event_log_path, {"timestamp": utc_now(), "event_type": "code_llm_skipped", "reason": "llm_command must be string or list"})
        return None

    timeout = int(settings.get("timeout_seconds", 180))
    stdout_path = run_dir / "stdout_stderr" / "code_understanding_external_llm_stdout.txt"
    stderr_path = run_dir / "stdout_stderr" / "code_understanding_external_llm_stderr.txt"

    try:
        proc = subprocess.run(
            command,
            input=prompt,
            text=True,
            capture_output=True,
            timeout=timeout,
            check=False,
        )
        write_text(stdout_path, proc.stdout or "")
        write_text(stderr_path, proc.stderr or "")
        append_jsonl(event_log_path, {
            "timestamp": utc_now(),
            "event_type": "code_llm_attempted",
            "command": command,
            "returncode": proc.returncode,
            "stdout_file": str(stdout_path),
            "stderr_file": str(stderr_path),
        })
        if proc.returncode != 0:
            return None
        data = json.loads(proc.stdout)
        if not isinstance(data, dict):
            return None
        data["llm_output_file"] = str(stdout_path)
        return data
    except Exception as e:
        append_jsonl(event_log_path, {
            "timestamp": utc_now(),
            "event_type": "code_llm_failed_fallback_to_deterministic",
            "error": str(e),
        })
        return None



# ---------------------------------------------------------------------------
# Agent 3 v2: rich context, traceability, and auxiliary output helpers
# ---------------------------------------------------------------------------

AGENT3_V2_SCHEMA_VERSION = "2.0"

AGENT3_V2_OUTPUTS = {
    "code_structure_index": "02_code_structure_index.json",
    "function_signature_analysis": "02_function_signature_analysis.json",
    "code_symbol_table": "02_code_symbol_table.json",
    "macro_constant_map": "02_macro_constant_map.json",
    "loop_bounds_array_accesses": "02_loop_bounds_array_accesses.json",
    "memory_safety_obligations": "02_memory_safety_obligations.json",
    "integer_range_obligations": "02_integer_range_obligations.json",
    "spec_code_mapping_candidates": "02_spec_code_mapping_candidates.json",
    "cbmc_harness_hints": "02_cbmc_harness_hints.json",
    "agent2v2_integration_report": "02_agent2v2_integration_report.json",
    "code_understanding_v2_report": "02_code_understanding_v2_report.json",
}


def read_json_if_exists(path: Path, default: Any = None) -> Any:
    if default is None:
        default = {}
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except Exception:
        return default


def read_text_if_exists(path: Path, default: str = "") -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return default


def write_csv(path: Path, rows: List[Dict[str, Any]], fieldnames: Optional[List[str]] = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if fieldnames is None:
        fieldnames = []
        for row in rows:
            for key in row:
                if key not in fieldnames:
                    fieldnames.append(key)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            safe_row: Dict[str, str] = {}
            for key in fieldnames:
                value = row.get(key, "")
                if isinstance(value, (dict, list)):
                    safe_row[key] = json.dumps(value, ensure_ascii=False)
                elif value is None:
                    safe_row[key] = ""
                else:
                    safe_row[key] = str(value)
            writer.writerow(safe_row)
    tmp.replace(path)


def token_set_for_mapping(text: Any) -> set[str]:
    return {t.lower() for t in re.findall(r"[A-Za-z_][A-Za-z0-9_]*|\d+", flatten_for_v2(text))}


def flatten_for_v2(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    try:
        return json.dumps(value, ensure_ascii=False, sort_keys=True)
    except Exception:
        return str(value)


def load_agent2_v2_context(run_dir: Path) -> Dict[str, Any]:
    return {
        "selected_spec_excerpt": read_text_if_exists(run_dir / "selected_spec_excerpt.txt"),
        "spec_sections_index": read_json_if_exists(run_dir / "01_spec_sections_index.json", {}),
        "algorithm_blocks": read_json_if_exists(run_dir / "01_algorithm_blocks.json", {}),
        "symbol_table": read_json_if_exists(run_dir / "01_symbol_table.json", {}),
        "parameter_table": read_json_if_exists(run_dir / "01_parameter_table.json", {}),
        "equations_constraints": read_json_if_exists(run_dir / "01_equations_constraints.json", {}),
        "preconditions_postconditions": read_json_if_exists(run_dir / "01_preconditions_postconditions.json", {}),
        "spec_to_code_hints": read_json_if_exists(run_dir / "01_spec_to_code_hints.json", {}),
        "spec_summary": read_json_if_exists(run_dir / "01_spec_summary.json", {}),
    }


def iter_v2_items(data: Any, keys: Optional[List[str]] = None) -> List[Any]:
    if isinstance(data, list):
        return data
    if not isinstance(data, dict):
        return []
    keys = keys or [
        "items", "entries", "rows", "records", "symbols", "parameters", "constants",
        "algorithm_blocks", "algorithms", "blocks", "equations", "constraints",
        "preconditions", "postconditions", "input_requirements", "output_guarantees", "hints",
    ]
    out: List[Any] = []
    for key in keys:
        value = data.get(key)
        if isinstance(value, list):
            out.extend(value)
        elif value is not None and key in data:
            out.append(value)
    if not out:
        # Treat simple dictionaries as key-value tables.
        for key, value in data.items():
            if str(key).startswith("_"):
                continue
            if isinstance(value, dict):
                row = dict(value)
                row.setdefault("name", key)
                out.append(row)
            elif not isinstance(value, (list, tuple)):
                out.append({"name": key, "value": value})
    return out


def infer_numeric_literal(value: Any) -> Optional[int]:
    if isinstance(value, int):
        return value
    if isinstance(value, float) and value.is_integer():
        return int(value)
    text = str(value or "")
    m = re.search(r"(?<![A-Za-z0-9_])-?\d+(?![A-Za-z0-9_])", text)
    if not m:
        return None
    try:
        return int(m.group(0))
    except Exception:
        return None


def collect_spec_symbols(agent2_context: Dict[str, Any]) -> List[Dict[str, Any]]:
    symbols: List[Dict[str, Any]] = []
    symbol_table = agent2_context.get("symbol_table", {})
    for idx, item in enumerate(iter_v2_items(symbol_table, ["symbols", "entries", "items", "rows"]), start=1):
        if isinstance(item, dict):
            name = item.get("symbol") or item.get("name") or item.get("id") or item.get("parameter") or f"symbol_{idx}"
            meaning = item.get("meaning") or item.get("description") or item.get("text") or item.get("role") or ""
            value = item.get("value")
            evidence = item.get("evidence") or {"source_file": "01_symbol_table.json"}
        else:
            name = str(item)
            meaning = ""
            value = None
            evidence = {"source_file": "01_symbol_table.json"}
        if name:
            symbols.append({"name": str(name), "meaning": meaning, "value": value, "evidence": evidence})

    parameter_table = agent2_context.get("parameter_table", {})
    for idx, item in enumerate(iter_v2_items(parameter_table, ["parameters", "constants", "rows", "items", "entries"]), start=1):
        if isinstance(item, dict):
            name = item.get("name") or item.get("symbol") or item.get("parameter") or item.get("id") or f"parameter_{idx}"
            value = item.get("value")
            meaning = item.get("meaning") or item.get("description") or item.get("text") or "parameter/constant"
            evidence = item.get("evidence") or {"source_file": "01_parameter_table.json"}
        else:
            name = str(item)
            value = None
            meaning = "parameter/constant"
            evidence = {"source_file": "01_parameter_table.json"}
        if name:
            symbols.append({"name": str(name), "meaning": meaning, "value": value, "evidence": evidence})

    spec_summary = agent2_context.get("spec_summary", {})
    constants = spec_summary.get("constants") if isinstance(spec_summary, dict) else {}
    if isinstance(constants, dict):
        for key, value in constants.items():
            symbols.append({
                "name": str(key),
                "meaning": "constant from 01_spec_summary.json",
                "value": value.get("value") if isinstance(value, dict) else value,
                "evidence": value.get("evidence") if isinstance(value, dict) and isinstance(value.get("evidence"), dict) else {"source_file": "01_spec_summary.json"},
            })
    return unique_preserve_order(symbols)


def macro_value_score_against_symbol(macro: Dict[str, Any], symbol: Dict[str, Any]) -> float:
    macro_name = str(macro.get("name", "")).lower()
    macro_value = str(macro.get("value", ""))
    symbol_name = str(symbol.get("name", "")).lower()
    symbol_value = str(symbol.get("value", ""))
    score = 0.0
    if symbol_name and (symbol_name == macro_name or symbol_name in macro_name or macro_name.endswith("_" + symbol_name)):
        score += 0.55
    macro_num = infer_numeric_literal(macro_value)
    symbol_num = infer_numeric_literal(symbol_value)
    if macro_num is not None and symbol_num is not None and macro_num == symbol_num:
        score += 0.35
    elif symbol_value and symbol_value != "None" and symbol_value in macro_value:
        score += 0.25
    return min(score, 1.0)


def classify_c_type_family(type_guess: str) -> str:
    t = str(type_guess or "").lower()
    if "int8" in t or "uint8" in t:
        return "8_bit_integer"
    if "int16" in t or "uint16" in t:
        return "16_bit_integer"
    if "int32" in t or "uint32" in t:
        return "32_bit_integer"
    if "int64" in t or "uint64" in t:
        return "64_bit_integer"
    if "polyvec" in t:
        return "polyvec_struct_or_alias"
    if "poly" in t:
        return "poly_struct_or_alias"
    if "size_t" in t:
        return "size_type"
    if "bool" in t:
        return "boolean"
    if "char" in t:
        return "byte_or_char"
    if "int" in t:
        return "plain_integer"
    return "unknown_or_project_type"


def enrich_parameter_roles(parameters: List[Dict[str, Any]], writes: List[Dict[str, Any]], reads: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    write_text_blob = "\n".join(flatten_for_v2(w.get("lhs")) for w in writes)
    read_text_blob = "\n".join(flatten_for_v2(r) for r in reads)
    enriched: List[Dict[str, Any]] = []
    for param in parameters:
        item = dict(param)
        name = str(item.get("name", ""))
        raw = str(item.get("raw", ""))
        writes_to_param = bool(name and re.search(rf"\b{re.escape(name)}\b", write_text_blob))
        reads_param = bool(name and re.search(rf"\b{re.escape(name)}\b", read_text_blob))
        item["type_family"] = classify_c_type_family(item.get("type_guess", raw))
        item["observed_written"] = writes_to_param
        item["observed_read"] = reads_param
        if item.get("is_const"):
            item["role_v2"] = "read_only_input"
        elif item.get("is_pointer") and writes_to_param:
            item["role_v2"] = "output_or_inout_pointer_written"
        elif item.get("is_pointer"):
            item["role_v2"] = "mutable_pointer_needs_review"
        elif writes_to_param:
            item["role_v2"] = "local_or_value_written_unusual"
        else:
            item["role_v2"] = item.get("direction_guess", "value_input")
        item["cbmc_object_setup_hint"] = (
            f"Create a concrete object for `{name}` and pass its address/pointer safely."
            if item.get("is_pointer") else
            f"Use nondeterministic or documented value for `{name}` if needed."
        )
        enriched.append(item)
    return enriched


def build_loop_bound_analysis(loops: List[Dict[str, Any]], macros: List[Dict[str, Any]], spec_symbols: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    macro_by_name = {str(m.get("name")): m for m in macros if m.get("name")}
    symbol_by_name = {str(s.get("name")): s for s in spec_symbols if s.get("name")}
    rows: List[Dict[str, Any]] = []
    for idx, loop in enumerate(loops, start=1):
        condition = str(loop.get("condition") or loop.get("raw") or "")
        bound_expr = ""
        bound_kind = "unknown"
        bound_value: Optional[int] = None
        m = re.search(r"(?:<|<=)\s*([A-Za-z_][A-Za-z0-9_]*|\d+)", condition)
        if m:
            bound_expr = m.group(1)
            if bound_expr.isdigit():
                bound_kind = "literal"
                bound_value = int(bound_expr)
            elif bound_expr in macro_by_name:
                bound_kind = "macro"
                bound_value = infer_numeric_literal(macro_by_name[bound_expr].get("value"))
            elif bound_expr in symbol_by_name:
                bound_kind = "spec_symbol"
                bound_value = infer_numeric_literal(symbol_by_name[bound_expr].get("value"))
            else:
                bound_kind = "identifier_unresolved"
        rows.append({
            "loop_id": f"L{idx}",
            "line": loop.get("line"),
            "loop_variable_guess": loop.get("loop_variable_guess"),
            "condition": condition,
            "bound_expression": bound_expr,
            "bound_kind": bound_kind,
            "bound_value_guess": bound_value,
            "cbmc_unwind_recommendation": bound_value if bound_value is not None else bound_expr or None,
            "human_review_required": bound_kind in {"unknown", "identifier_unresolved", "spec_symbol"},
            "evidence": loop.get("evidence"),
        })
    return rows


def build_code_symbol_table(result: Dict[str, Any], relevant_macros: List[Dict[str, Any]], relevant_typedefs: List[Dict[str, Any]]) -> Dict[str, Any]:
    symbols: List[Dict[str, Any]] = []
    fn = result.get("function", {})
    for p in result.get("inputs", []) + result.get("outputs_or_inouts", []):
        symbols.append({
            "name": p.get("name"),
            "kind": "function_parameter",
            "type_guess": p.get("type_guess"),
            "role": p.get("role_v2") or p.get("direction_guess"),
            "source": "02_code_summary.json",
            "evidence": p.get("evidence"),
        })
    for item in result.get("local_variables", []):
        for name in item.get("names", []):
            symbols.append({
                "name": name,
                "kind": "local_variable",
                "type_guess": item.get("type"),
                "role": "local",
                "source": "source_code",
                "evidence": item.get("evidence"),
            })
    for macro in relevant_macros:
        symbols.append({
            "name": macro.get("name"),
            "kind": macro.get("kind", "macro"),
            "value": macro.get("value"),
            "source": macro.get("source_file"),
            "evidence": macro.get("evidence"),
        })
    for td in relevant_typedefs:
        symbols.append({
            "name": ", ".join(td.get("names_detected", [])),
            "kind": td.get("kind", "typedef_or_struct"),
            "summary": td.get("summary"),
            "source": td.get("source_file"),
            "evidence": td.get("evidence"),
        })
    return {
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "target_function": result.get("target_function_detected"),
        "function_signature": fn.get("signature"),
        "symbol_count": len(symbols),
        "symbols": unique_preserve_order(symbols),
        "human_review_required": True,
        "guardrail": "Code symbols are extracted candidates; they must be reviewed before becoming proof assumptions.",
    }


def build_macro_constant_map(relevant_macros: List[Dict[str, Any]], spec_symbols: List[Dict[str, Any]]) -> Dict[str, Any]:
    rows: List[Dict[str, Any]] = []
    for macro in relevant_macros:
        best_symbol: Optional[Dict[str, Any]] = None
        best_score = 0.0
        for symbol in spec_symbols:
            score = macro_value_score_against_symbol(macro, symbol)
            if score > best_score:
                best_score = score
                best_symbol = symbol
        rows.append({
            "macro_name": macro.get("name"),
            "macro_value": macro.get("value"),
            "macro_kind": macro.get("kind"),
            "macro_source_file": macro.get("source_file"),
            "matched_spec_symbol": best_symbol.get("name") if best_symbol and best_score >= 0.25 else None,
            "matched_spec_value": best_symbol.get("value") if best_symbol and best_score >= 0.25 else None,
            "match_score": round(best_score, 3),
            "match_status": "candidate_match" if best_score >= 0.55 else ("weak_candidate" if best_score >= 0.25 else "no_match"),
            "human_review_required": best_score < 0.8,
            "macro_evidence": macro.get("evidence"),
            "spec_evidence": best_symbol.get("evidence") if best_symbol else None,
        })
    return {
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "macro_constant_rows": rows,
        "rows_count": len(rows),
        "guardrail": "Macro/spec constant matches are candidate traceability links, not proof facts.",
    }


def collect_algorithm_assignment_like_texts(agent2_context: Dict[str, Any]) -> List[Dict[str, Any]]:
    blocks = iter_v2_items(agent2_context.get("algorithm_blocks", {}), ["algorithm_blocks", "algorithms", "blocks", "items"])
    out: List[Dict[str, Any]] = []
    for idx, block in enumerate(blocks, start=1):
        if isinstance(block, dict):
            name = block.get("name") or block.get("algorithm_name") or block.get("id") or f"algorithm_{idx}"
            evidence = block.get("evidence") or {"source_file": "01_algorithm_blocks.json"}
            raw_text = flatten_for_v2(block.get("steps") or block.get("operations") or block.get("assignments") or block.get("text") or block.get("body") or block)
        else:
            name = f"algorithm_{idx}"
            evidence = {"source_file": "01_algorithm_blocks.json"}
            raw_text = str(block)
        for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_\.\-\>\[\]]+)\s*(?:<-|←|:=|=)\s*([^;\n]+)", raw_text):
            out.append({
                "algorithm": str(name),
                "lhs": compact_ws(m.group(1)),
                "rhs": compact_ws(m.group(2)),
                "raw": compact_ws(m.group(0)),
                "evidence": evidence,
            })
        if not out and raw_text.strip():
            out.append({"algorithm": str(name), "lhs": "", "rhs": "", "raw": raw_text[:500], "evidence": evidence})
    return unique_preserve_order(out)


def build_spec_code_mapping_candidates(result: Dict[str, Any], agent2_context: Dict[str, Any]) -> Dict[str, Any]:
    code_text = flatten_for_v2({
        "function": result.get("function", {}),
        "loops": result.get("loop_structure", []),
        "array_accesses": result.get("array_accesses", []),
        "writes": result.get("output_writes_and_assignments", []),
        "calls": result.get("helper_function_or_macro_calls", []),
        "macros": result.get("dependencies", {}).get("relevant_macros_or_constants", []),
    })
    code_tokens = token_set_for_mapping(code_text)
    spec_symbols = collect_spec_symbols(agent2_context)
    mappings: List[Dict[str, Any]] = []

    for symbol in spec_symbols:
        name = str(symbol.get("name", ""))
        sym_tokens = token_set_for_mapping(name + " " + flatten_for_v2(symbol.get("meaning")) + " " + flatten_for_v2(symbol.get("value")))
        overlap = sorted(code_tokens & sym_tokens)
        direct_name_seen = bool(name and re.search(rf"\b{re.escape(name)}\b", code_text, re.I))
        value_seen = bool(symbol.get("value") not in (None, "") and str(symbol.get("value")) in code_text)
        score = (0.55 if direct_name_seen else 0.0) + (0.25 if value_seen else 0.0) + min(0.2, 0.05 * len(overlap))
        if score > 0:
            mappings.append({
                "mapping_type": "spec_symbol_to_code_candidate",
                "spec_symbol": name,
                "spec_value": symbol.get("value"),
                "code_evidence_kind": "token_or_value_overlap",
                "overlap_tokens": overlap[:20],
                "score": round(min(score, 1.0), 3),
                "status": "strong_candidate" if score >= 0.7 else "candidate_needs_review",
                "spec_evidence": symbol.get("evidence"),
                "human_review_required": True,
            })

    algorithm_steps = collect_algorithm_assignment_like_texts(agent2_context)
    writes = result.get("output_writes_and_assignments", [])
    for step in algorithm_steps:
        step_tokens = token_set_for_mapping(step)
        best_write = None
        best_score = 0.0
        for write in writes:
            write_tokens = token_set_for_mapping(write)
            if not write_tokens:
                continue
            score = len(step_tokens & write_tokens) / max(1, min(len(step_tokens), len(write_tokens)))
            if score > best_score:
                best_score = score
                best_write = write
        if best_write is not None and best_score >= 0.15:
            mappings.append({
                "mapping_type": "algorithm_step_to_code_write_candidate",
                "algorithm": step.get("algorithm"),
                "algorithm_step": step.get("raw"),
                "code_write_lhs": best_write.get("lhs"),
                "code_write_rhs": best_write.get("rhs"),
                "score": round(best_score, 3),
                "status": "candidate_needs_review" if best_score < 0.5 else "strong_candidate",
                "algorithm_evidence": step.get("evidence"),
                "code_evidence": best_write.get("evidence"),
                "human_review_required": True,
            })
    return {
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "target_function": result.get("target_function_detected"),
        "mapping_count": len(mappings),
        "mappings": unique_preserve_order(mappings),
        "agent2_v2_files_seen": {k: bool(v) for k, v in agent2_context.items() if k != "selected_spec_excerpt"},
        "selected_spec_excerpt_present": bool(agent2_context.get("selected_spec_excerpt")),
        "guardrail": "Mappings are candidate links for later agents. Human/code/spec review remains required.",
    }


def build_memory_safety_obligations(result: Dict[str, Any]) -> Dict[str, Any]:
    obligations: List[Dict[str, Any]] = []
    oid = 1
    for p in result.get("inputs", []) + result.get("outputs_or_inouts", []):
        if p.get("is_pointer"):
            obligations.append({
                "id": f"M{oid}",
                "kind": "pointer_validity",
                "description": f"Parameter `{p.get('name')}` must point to a valid object for the target call.",
                "suggested_cbmc_check": "--pointer-check",
                "suggested_harness_setup": p.get("cbmc_object_setup_hint") or f"Create concrete storage for `{p.get('name')}`.",
                "evidence": p.get("evidence"),
                "priority": "high",
                "human_review_required": True,
            }); oid += 1
    for access in result.get("array_accesses", []):
        obligations.append({
            "id": f"M{oid}",
            "kind": "array_bounds",
            "description": f"Array access `{access.get('expression')}` must remain inside the allocated object bounds.",
            "suggested_cbmc_check": "--bounds-check",
            "base": access.get("base"),
            "index": access.get("index"),
            "access_context_guess": access.get("access_context_guess"),
            "evidence": access.get("evidence"),
            "priority": "high",
            "human_review_required": True,
        }); oid += 1
    for access in result.get("pointer_accesses", []):
        obligations.append({
            "id": f"M{oid}",
            "kind": "pointer_dereference_or_field_access",
            "description": f"Pointer access `{access.get('expression')}` must be valid under harness assumptions.",
            "suggested_cbmc_check": "--pointer-check",
            "evidence": access.get("evidence"),
            "priority": "high",
            "human_review_required": True,
        }); oid += 1
    return {
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "target_function": result.get("target_function_detected"),
        "obligation_count": len(obligations),
        "obligations": obligations,
        "guardrail": "These are memory-safety obligations for harness generation; they are not proof results.",
    }


def build_integer_range_obligations(result: Dict[str, Any], agent2_context: Dict[str, Any]) -> Dict[str, Any]:
    obligations: List[Dict[str, Any]] = []
    spec_text = flatten_for_v2(agent2_context.get("equations_constraints")) + "\n" + flatten_for_v2(agent2_context.get("preconditions_postconditions"))
    range_markers_present = bool(re.search(r"(range|bound|<=|>=|<|>|between|mod|modulus|q|3329)", spec_text, re.I))
    for idx, op in enumerate(result.get("integer_and_bit_operations", []), start=1):
        operations = op.get("operations", [])
        obligations.append({
            "id": f"I{idx}",
            "kind": "integer_or_bit_operation",
            "operations": operations,
            "statement": op.get("statement"),
            "line": op.get("line"),
            "risk_level": "high" if any(x in operations for x in ["addition", "subtraction", "multiplication", "left_shift", "right_shift"]) else "medium",
            "suggested_cbmc_checks": ["--signed-overflow-check", "--unsigned-overflow-check", "--undefined-shift-check"],
            "spec_range_context_seen": range_markers_present,
            "human_review_required": True,
            "evidence": op.get("evidence"),
        })
    return {
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "target_function": result.get("target_function_detected"),
        "obligation_count": len(obligations),
        "obligations": obligations,
        "spec_range_context_seen": range_markers_present,
        "guardrail": "Integer range obligations must be justified by spec/code before becoming assumptions.",
    }


def build_cbmc_harness_hints_v2(result: Dict[str, Any], loop_analysis: List[Dict[str, Any]], memory: Dict[str, Any], integer: Dict[str, Any]) -> Dict[str, Any]:
    cbmc = dict(result.get("cbmc_hints", {}))
    checks = set(cbmc.get("recommended_checks", []))
    for obl in memory.get("obligations", []):
        check = obl.get("suggested_cbmc_check")
        if check:
            checks.add(check)
    for obl in integer.get("obligations", []):
        for c in obl.get("suggested_cbmc_checks", []):
            checks.add(c)
    unwind_candidates = [x.get("cbmc_unwind_recommendation") for x in loop_analysis if x.get("cbmc_unwind_recommendation")]
    cbmc.update({
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "target_function": result.get("target_function_detected"),
        "suggested_harness_function": cbmc.get("suggested_cbmc_function") or f"harness_{safe_name(str(result.get('target_function_requested') or result.get('target_function_detected')))}",
        "recommended_checks": sorted(checks),
        "unwind_recommendations": unwind_candidates,
        "object_setup_plan": [x.get("suggested_harness_setup") for x in memory.get("obligations", []) if x.get("kind") == "pointer_validity"],
        "assumption_policy": {
            "do_not_invent_ranges_from_code_alone": True,
            "allowed_sources_for_assumptions": ["01_spec_summary.json", "01_preconditions_postconditions.json", "01_equations_constraints.json", "02_code_summary.json", "human_notes.md"],
            "human_review_required": True,
        },
        "candidate_first_harness_strategy": "Start with memory/pointer/bounds checks before stronger functional assertions when the spec/code mapping is uncertain.",
        "guardrail": "These hints guide candidate CBMC harness generation only; they do not prove correctness.",
    })
    return cbmc


def build_function_signature_analysis(result: Dict[str, Any]) -> Dict[str, Any]:
    fn = result.get("function", {})
    params = result.get("inputs", []) + result.get("outputs_or_inouts", [])
    alias_pairs: List[Dict[str, Any]] = []
    pointer_params = [p for p in params if p.get("is_pointer")]
    for i, a in enumerate(pointer_params):
        for b in pointer_params[i + 1:]:
            alias_pairs.append({
                "param_a": a.get("name"),
                "param_b": b.get("name"),
                "aliasing_question": f"Can `{a.get('name')}` and `{b.get('name')}` refer to the same object?",
                "default_for_harness": "do_not_assume_distinct_unless_code_or_spec_requires_it",
                "human_review_required": True,
            })
    return {
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "target_function_requested": result.get("target_function_requested"),
        "target_function_detected": result.get("target_function_detected"),
        "signature": fn.get("signature"),
        "return_type": fn.get("return_type"),
        "parameter_count": len(params),
        "parameters": params,
        "aliasing_questions": alias_pairs,
        "function_evidence": fn.get("evidence"),
        "guardrail": "Parameter roles and aliasing questions are candidate interpretations requiring human/code review.",
    }


def build_code_structure_index(result: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "target_function": result.get("target_function_detected"),
        "source_file": result.get("source_file"),
        "function": result.get("function", {}),
        "counts": {
            "inputs": len(result.get("inputs", [])),
            "outputs_or_inouts": len(result.get("outputs_or_inouts", [])),
            "local_variables": len(result.get("local_variables", [])),
            "loops": len(result.get("loop_structure", [])),
            "conditionals": len(result.get("conditionals", [])),
            "array_accesses": len(result.get("array_accesses", [])),
            "pointer_accesses": len(result.get("pointer_accesses", [])),
            "writes": len(result.get("output_writes_and_assignments", [])),
            "helper_calls": len(result.get("helper_function_or_macro_calls", [])),
            "integer_bit_operations": len(result.get("integer_and_bit_operations", [])),
            "return_statements": len(result.get("return_statements", [])),
        },
        "loops": result.get("loop_structure", []),
        "array_accesses": result.get("array_accesses", []),
        "pointer_accesses": result.get("pointer_accesses", []),
        "writes": result.get("output_writes_and_assignments", []),
        "helper_calls": result.get("helper_function_or_macro_calls", []),
        "conditionals": result.get("conditionals", []),
        "guardrail": "This index is extracted code evidence, not a correctness proof.",
    }


def build_agent2v2_integration_report(agent2_context: Dict[str, Any], mappings: Dict[str, Any]) -> Dict[str, Any]:
    file_presence = {
        "selected_spec_excerpt.txt": bool(agent2_context.get("selected_spec_excerpt")),
        "01_spec_sections_index.json": bool(agent2_context.get("spec_sections_index")),
        "01_algorithm_blocks.json": bool(agent2_context.get("algorithm_blocks")),
        "01_symbol_table.json": bool(agent2_context.get("symbol_table")),
        "01_parameter_table.json": bool(agent2_context.get("parameter_table")),
        "01_equations_constraints.json": bool(agent2_context.get("equations_constraints")),
        "01_preconditions_postconditions.json": bool(agent2_context.get("preconditions_postconditions")),
        "01_spec_to_code_hints.json": bool(agent2_context.get("spec_to_code_hints")),
        "01_spec_summary.json": bool(agent2_context.get("spec_summary")),
    }
    present = sum(1 for v in file_presence.values() if v)
    return {
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "agent": "code_understanding_agent_v2",
        "agent2_v2_file_presence": file_presence,
        "agent2_v2_files_present_count": present,
        "candidate_mapping_count": mappings.get("mapping_count", 0),
        "integration_level": "rich_agent2v2_context" if present >= 5 else ("partial_agent2v2_context" if present else "legacy_no_agent2v2_context"),
        "used_for": [
            "spec symbol to code symbol candidate mapping",
            "macro/constant comparison",
            "algorithm step to code write overlap",
            "integer range obligation context",
            "CBMC assumption policy hints",
        ],
        "human_review_required": True,
        "guardrail": "Agent 2 v2 context improves traceability but does not certify that the code satisfies the specification.",
    }


def build_v2_report(result: Dict[str, Any], outputs: Dict[str, str], quality_notes: List[Dict[str, Any]]) -> Dict[str, Any]:
    return {
        "schema_version": AGENT3_V2_SCHEMA_VERSION,
        "agent": "code_understanding_agent_v2",
        "target_function": result.get("target_function_detected"),
        "created_at": utc_now(),
        "legacy_outputs_preserved": [
            "02_code_summary.json",
            "02_code_summary.md",
            "llm_prompts/02_code_understanding_prompt.txt",
            "agent_status/02_code_understanding_status.json",
        ],
        "v2_outputs": outputs,
        "quality_notes": quality_notes,
        "downstream_contract": {
            "agent4_property_discovery_reads": [
                "02_code_summary.json", "02_code_structure_index.json", "02_spec_code_mapping_candidates.json", "02_macro_constant_map.json",
            ],
            "agent5_artifact_generation_reads": [
                "02_code_summary.json", "02_cbmc_harness_hints.json", "02_memory_safety_obligations.json", "02_integer_range_obligations.json",
            ],
            "agent10_logger_tracks": list(outputs.values()),
            "agent11_evaluation_can_use": [
                "02_agent2v2_integration_report.json", "02_spec_code_mapping_candidates.json", "02_code_understanding_v2_report.json",
            ],
        },
        "scientific_guardrails": result.get("scientific_guardrails", {}),
    }


# ---------------------------------------------------------------------------
# Main Code Understanding Agent
# ---------------------------------------------------------------------------

class CodeUnderstandingAgent:
    """Agent 3: produces an implementation-level code summary."""

    def __init__(self, config_path: Path, run_dir_arg: Optional[Path] = None) -> None:
        self.config_path = config_path.resolve()
        self.config = read_json(self.config_path)
        self.project_root = Path(self.config.get("project_root", self.config_path.parent.parent)).resolve()
        self.run_dir = (run_dir_arg or resolve_path(self.project_root, str(self.config.get("run_dir", "runs/current")))).resolve()

        # Agent 3 v2 compatibility: if Master Orchestrator created a resolved
        # config in the run folder, merge it before resolving source/header data.
        # This preserves old CLI behaviour while allowing promoted artifacts,
        # normalized spec settings, and scientific guardrails to flow through.
        resolved_config_path = self.run_dir / "run_config.resolved.json"
        resolved_config = read_json_if_exists(resolved_config_path, {})
        if isinstance(resolved_config, dict) and resolved_config:
            merged = dict(self.config)
            merged.update(resolved_config)
            self.config = merged
            self.project_root = Path(self.config.get("project_root", self.project_root)).resolve()

        self.run_dir.mkdir(parents=True, exist_ok=True)
        (self.run_dir / "llm_prompts").mkdir(exist_ok=True)
        (self.run_dir / "llm_outputs").mkdir(exist_ok=True)
        (self.run_dir / "agent_status").mkdir(exist_ok=True)
        (self.run_dir / "stdout_stderr").mkdir(exist_ok=True)

        self.event_log_path = self.run_dir / "events.jsonl"
        self.output_json_path = self.run_dir / "02_code_summary.json"
        self.output_md_path = self.run_dir / "02_code_summary.md"
        self.prompt_path = self.run_dir / "llm_prompts" / "02_code_understanding_prompt.txt"
        self.agent_status_path = self.run_dir / "agent_status" / "02_code_understanding_status.json"
        self.v2_output_paths = {key: self.run_dir / rel for key, rel in AGENT3_V2_OUTPUTS.items()}

        self.target_scheme = str(self.config.get("target_scheme", "unknown_scheme"))
        self.target_function = str(self.config.get("target_function", "unknown_function"))
        self.verification_goal = str(self.config.get("verification_goal", "not specified"))
        self.verification_tool = str(self.config.get("verification_tool", "CBMC"))

        source_file = self.config.get("source_file") or self.config.get("code_file")
        if not source_file:
            raise ValueError("Config must include 'source_file' or 'code_file'.")
        self.source_file = resolve_path(self.project_root, str(source_file))

        self.header_files = self._load_header_files()

    def _load_header_files(self) -> List[Path]:
        values: List[Any] = []
        for key in ["header_files", "headers", "related_header_files"]:
            value = self.config.get(key)
            if isinstance(value, list):
                values.extend(value)
            elif isinstance(value, str):
                values.append(value)
        settings = self.config.get("code_understanding_settings", {})
        if isinstance(settings, dict):
            value = settings.get("header_files")
            if isinstance(value, list):
                values.extend(value)
        paths = [resolve_path(self.project_root, str(v)) for v in values]
        return unique_preserve_order(paths)

    def log_event(self, event_type: str, payload: Dict[str, Any]) -> None:
        append_jsonl(self.event_log_path, {"timestamp": utc_now(), "agent": "code_understanding", "event_type": event_type, **payload})

    def run(self) -> int:
        started_at = utc_now()
        try:
            self.log_event("agent_start", {
                "target_scheme": self.target_scheme,
                "target_function": self.target_function,
                "source_file": str(self.source_file),
                "header_files": [str(p) for p in self.header_files],
                "output": str(self.output_json_path),
            })

            source_text = read_text_file(self.source_file)
            header_texts: Dict[str, str] = {}
            missing_headers: List[str] = []
            for h in self.header_files:
                if h.exists():
                    header_texts[str(h)] = read_text_file(h)
                else:
                    missing_headers.append(str(h))

            function = extract_target_function(source_text, str(self.source_file), self.target_function)
            combined_header_text = "\n\n".join(f"/* FILE: {path} */\n{text}" for path, text in header_texts.items())
            prompt = build_structured_prompt(
                target_scheme=self.target_scheme,
                target_function=self.target_function,
                verification_goal=self.verification_goal,
                source_file=str(self.source_file),
                header_files=[str(p) for p in self.header_files],
                function=function,
                relevant_headers_excerpt=combined_header_text,
            )
            write_text(self.prompt_path, prompt)

            deterministic = self._deterministic_analyze(source_text, header_texts, missing_headers, function, started_at)
            external = run_external_llm_if_enabled(self.config, prompt, self.run_dir, self.event_log_path)
            if external is not None:
                result = self._merge_external_result(deterministic, external)
                result["analysis_method"] = "deterministic_with_external_llm_overlay"
            else:
                result = deterministic
                result["analysis_method"] = "deterministic_static_code_analysis"

            result["created_at"] = utc_now()
            result["agent_name"] = "code_understanding_agent"
            result["schema_version"] = AGENT3_V2_SCHEMA_VERSION
            result["legacy_schema_compatibility"] = ["1.0"]
            result["output_files"] = {
                "json": str(self.output_json_path),
                "markdown": str(self.output_md_path),
                "prompt": str(self.prompt_path),
                "status": str(self.agent_status_path),
                "v2_outputs": {key: str(path) for key, path in self.v2_output_paths.items()},
            }
            self._validate_and_warn(result)

            v2_outputs = self._write_v2_outputs(result)
            result["v2_outputs"] = v2_outputs

            write_json(self.output_json_path, result)
            write_text(self.output_md_path, self._to_markdown(result))

            status = {
                "agent": "code_understanding",
                "status": "passed",
                "started_at": started_at,
                "finished_at": utc_now(),
                "output_json": str(self.output_json_path),
                "output_markdown": str(self.output_md_path),
                "prompt_file": str(self.prompt_path),
                "v2_outputs": v2_outputs,
                "human_review_required": True,
            }
            write_json(self.agent_status_path, status)
            self.log_event("agent_finish", status)

            print(f"[OK] Code Understanding Agent wrote: {self.output_json_path}")
            print(f"[OK] Markdown summary: {self.output_md_path}")
            print("[NOTE] This is an implementation summary, not a proof. Human review and CBMC remain required.")
            return 0

        except Exception as e:
            status = {
                "agent": "code_understanding",
                "status": "failed",
                "started_at": started_at,
                "finished_at": utc_now(),
                "error": str(e),
                "traceback": traceback.format_exc(),
                "human_review_required": True,
            }
            write_json(self.agent_status_path, status)
            self.log_event("agent_error", status)
            print(f"[ERROR] Code Understanding Agent failed: {e}", file=sys.stderr)
            print(f"[INFO] Status file: {self.agent_status_path}", file=sys.stderr)
            return 1

    def _deterministic_analyze(
        self,
        source_text: str,
        header_texts: Dict[str, str],
        missing_headers: List[str],
        function: FunctionInfo,
        started_at: str,
    ) -> Dict[str, Any]:
        # Extract global/header-level facts.
        all_macros: List[Dict[str, Any]] = []
        all_includes: List[Dict[str, Any]] = []
        all_typedefs: List[Dict[str, Any]] = []

        all_macros.extend(extract_macros(source_text, str(self.source_file)))
        all_includes.extend(extract_includes(source_text, str(self.source_file)))
        all_typedefs.extend(extract_typedefs_and_structs(source_text, str(self.source_file)))
        for path, text in header_texts.items():
            all_macros.extend(extract_macros(text, path))
            all_includes.extend(extract_includes(text, path))
            all_typedefs.extend(extract_typedefs_and_structs(text, path))

        relevant_macros = filter_relevant_macros(all_macros, function, "\n".join(header_texts.values()))
        relevant_typedefs = filter_relevant_typedefs(all_typedefs, function)

        local_variables = extract_local_variables(function)
        loops = extract_loops(function)
        conditionals = extract_conditionals(function)
        array_accesses = extract_array_accesses(function)
        pointer_accesses = extract_pointer_accesses(function)
        writes = extract_assignments_and_writes(function)
        calls = extract_function_calls(function)
        int_ops = extract_integer_and_bit_operations(function)
        returns = extract_return_statements(function)
        inputs, outputs = build_inputs_outputs(function, writes)
        enriched_parameters = enrich_parameter_roles(function.parameters, writes, array_accesses + pointer_accesses + calls)
        enriched_by_name = {p.get("name"): p for p in enriched_parameters}
        inputs = [dict(p, **{k: v for k, v in enriched_by_name.get(p.get("name"), {}).items() if k not in p or k.startswith("role") or k.startswith("observed") or k in {"type_family", "cbmc_object_setup_hint"}}) for p in inputs]
        outputs = [dict(p, **{k: v for k, v in enriched_by_name.get(p.get("name"), {}).items() if k not in p or k.startswith("role") or k.startswith("observed") or k in {"type_family", "cbmc_object_setup_hint"}}) for p in outputs]
        behavior_summary = summarize_behavior(function, loops, writes, calls)
        possible_properties = build_possible_properties(function, inputs, outputs, loops, array_accesses, pointer_accesses, int_ops, writes)
        risks, uncertainties = build_risks_and_uncertainties(function, relevant_macros, relevant_typedefs, loops, array_accesses, pointer_accesses, int_ops, calls)
        if missing_headers:
            uncertainties.append("Some configured header files were missing: " + ", ".join(missing_headers))
            risks.append({
                "type": "missing_header",
                "severity": "medium",
                "message": "One or more configured headers were not found, so type/macro extraction may be incomplete.",
            })

        cbmc_hints = build_cbmc_hints(function, inputs, outputs, loops, relevant_macros, calls)
        dependencies = build_dependencies(function, self.source_file, self.header_files, all_includes, relevant_macros, relevant_typedefs, calls)

        return {
            "schema_version": "1.0",
            "target_scheme": self.target_scheme,
            "target_function_requested": self.target_function,
            "target_function_detected": function.detected_name,
            "verification_goal": self.verification_goal,
            "verification_tool": self.verification_tool,
            "source_file": str(self.source_file),
            "header_files": [str(p) for p in self.header_files],
            "missing_header_files": missing_headers,
            "function": {
                "requested_name": function.requested_name,
                "detected_name": function.detected_name,
                "matched_by": function.matched_by,
                "signature": compact_ws(function.signature),
                "return_type": function.return_type,
                "parameters_raw": function.parameters_raw,
                "parameters": function.parameters,
                "source_file": function.source_file,
                "start_line": function.start_line,
                "end_line": function.end_line,
                "body_hash_sha256": function.body_hash_sha256,
                "body_excerpt": function.body[:4000] + ("\n/* ... truncated ... */" if len(function.body) > 4000 else ""),
                "evidence": evidence_from_lines(function.source_file, source_text, function.start_line, min(function.end_line, function.start_line + 80), max_chars=5000),
            },
            "implementation_summary": behavior_summary,
            "inputs": inputs,
            "outputs_or_inouts": outputs,
            "local_variables": local_variables,
            "loop_structure": loops,
            "conditionals": conditionals,
            "array_accesses": array_accesses,
            "pointer_accesses": pointer_accesses,
            "output_writes_and_assignments": writes,
            "helper_function_or_macro_calls": calls,
            "integer_and_bit_operations": int_ops,
            "return_statements": returns,
            "dependencies": dependencies,
            "possible_properties_from_code": possible_properties,
            "implementation_risks": risks,
            "cbmc_hints": cbmc_hints,
            "uncertainties": unique_preserve_order(uncertainties),
            "rejected_or_unsupported_claims": [
                {
                    "claim": "The selected implementation is correct.",
                    "reason": "Code understanding is not formal proof; correctness must be checked by formal tools and human review.",
                },
                {
                    "claim": "The full ML-KEM implementation is automatically proved by this workflow.",
                    "reason": "The thesis scope is selected components and candidate artifacts, not full automatic ML-KEM proof.",
                },
                {
                    "claim": "All input ranges are known from code alone.",
                    "reason": "Input bounds usually require specification context, type definitions, and human confirmation.",
                },
            ],
            "quality_flags": [],
            "scientific_guardrails": {
                "code_summary_is_candidate_understanding_only": True,
                "formal_tool_is_not_replaced": True,
                "human_review_required": True,
                "no_claim_of_full_mlkem_proof": True,
                "assumptions_must_be_justified_by_spec_and_code": True,
            },
            "agent_runtime": {
                "started_at": started_at,
                "finished_at": utc_now(),
            },
        }

    def _write_v2_outputs(self, result: Dict[str, Any]) -> Dict[str, str]:
        """Write additive Agent 3 v2 outputs without breaking 02_code_summary.json."""
        agent2_context = load_agent2_v2_context(self.run_dir)
        dependencies = result.get("dependencies", {}) if isinstance(result.get("dependencies"), dict) else {}
        relevant_macros = dependencies.get("relevant_macros_or_constants", []) or []
        relevant_typedefs = dependencies.get("relevant_type_definitions", []) or []
        spec_symbols = collect_spec_symbols(agent2_context)

        loop_analysis = build_loop_bound_analysis(result.get("loop_structure", []), relevant_macros, spec_symbols)
        memory_obligations = build_memory_safety_obligations(result)
        integer_obligations = build_integer_range_obligations(result, agent2_context)
        code_structure = build_code_structure_index(result)
        signature_analysis = build_function_signature_analysis(result)
        code_symbol_table = build_code_symbol_table(result, relevant_macros, relevant_typedefs)
        macro_constant_map = build_macro_constant_map(relevant_macros, spec_symbols)
        spec_code_mappings = build_spec_code_mapping_candidates(result, agent2_context)
        harness_hints = build_cbmc_harness_hints_v2(result, loop_analysis, memory_obligations, integer_obligations)
        integration_report = build_agent2v2_integration_report(agent2_context, spec_code_mappings)

        loop_bundle = {
            "schema_version": AGENT3_V2_SCHEMA_VERSION,
            "target_function": result.get("target_function_detected"),
            "loop_bound_analysis": loop_analysis,
            "array_accesses": result.get("array_accesses", []),
            "pointer_accesses": result.get("pointer_accesses", []),
            "guardrail": "Loop and access facts are extracted candidates; CBMC and human review remain required.",
        }

        quality_notes: List[Dict[str, Any]] = []
        if not agent2_context.get("algorithm_blocks"):
            quality_notes.append({"severity": "info", "message": "Agent 2 v2 algorithm blocks were not available; spec-code mapping is limited."})
        if not relevant_macros:
            quality_notes.append({"severity": "warning", "message": "No relevant macros/constants were confidently extracted; loop bounds may need manual review."})
        if not result.get("array_accesses"):
            quality_notes.append({"severity": "info", "message": "No array accesses found in the selected function body."})
        if not result.get("outputs_or_inouts"):
            quality_notes.append({"severity": "warning", "message": "No output/in-out parameter was confidently detected."})

        output_payloads: Dict[str, Any] = {
            "code_structure_index": code_structure,
            "function_signature_analysis": signature_analysis,
            "code_symbol_table": code_symbol_table,
            "macro_constant_map": macro_constant_map,
            "loop_bounds_array_accesses": loop_bundle,
            "memory_safety_obligations": memory_obligations,
            "integer_range_obligations": integer_obligations,
            "spec_code_mapping_candidates": spec_code_mappings,
            "cbmc_harness_hints": harness_hints,
            "agent2v2_integration_report": integration_report,
        }
        output_map: Dict[str, str] = {}
        for key, payload in output_payloads.items():
            path = self.v2_output_paths[key]
            write_json(path, payload)
            output_map[key] = path.name

        v2_report = build_v2_report(result, output_map, quality_notes)
        write_json(self.v2_output_paths["code_understanding_v2_report"], v2_report)
        output_map["code_understanding_v2_report"] = self.v2_output_paths["code_understanding_v2_report"].name

        # CSV sidecars for thesis/evaluation convenience. They are additive and not
        # required by older agents, but useful for inspection and future evaluation.
        write_csv(self.run_dir / "02_macro_constant_map.csv", macro_constant_map.get("macro_constant_rows", []))
        write_csv(self.run_dir / "02_spec_code_mapping_candidates.csv", spec_code_mappings.get("mappings", []))
        write_csv(self.run_dir / "02_memory_safety_obligations.csv", memory_obligations.get("obligations", []))
        write_csv(self.run_dir / "02_integer_range_obligations.csv", integer_obligations.get("obligations", []))
        write_csv(self.run_dir / "02_loop_bound_analysis.csv", loop_analysis)
        output_map["macro_constant_map_csv"] = "02_macro_constant_map.csv"
        output_map["spec_code_mapping_candidates_csv"] = "02_spec_code_mapping_candidates.csv"
        output_map["memory_safety_obligations_csv"] = "02_memory_safety_obligations.csv"
        output_map["integer_range_obligations_csv"] = "02_integer_range_obligations.csv"
        output_map["loop_bound_analysis_csv"] = "02_loop_bound_analysis.csv"

        append_jsonl(self.event_log_path, {
            "timestamp": utc_now(),
            "agent": "code_understanding",
            "event_type": "v2_outputs_written",
            "outputs": output_map,
            "agent2_integration_level": integration_report.get("integration_level"),
        })
        return output_map

    def _merge_external_result(self, base: Dict[str, Any], external: Dict[str, Any]) -> Dict[str, Any]:
        # Deterministic extraction remains the safety backbone. External LLM data is
        # recorded separately and only overlays selected descriptive fields if present.
        merged = dict(base)
        merged["external_llm_observations"] = external
        for key in ["implementation_summary", "uncertainties"]:
            if key in external and external[key]:
                merged[f"external_{key}"] = external[key]
        merged.setdefault("quality_flags", []).append({
            "severity": "info",
            "message": "External LLM observations are included separately; deterministic evidence-based extraction remains the main structured output.",
        })
        return merged

    def _validate_and_warn(self, result: Dict[str, Any]) -> None:
        flags = result.setdefault("quality_flags", [])
        if not result.get("loop_structure"):
            flags.append({"severity": "info", "message": "No loops detected in target function. This may be correct for small helper functions."})
        if not result.get("array_accesses"):
            flags.append({"severity": "info", "message": "No array accesses detected in target function."})
        if not result.get("outputs_or_inouts"):
            flags.append({"severity": "warning", "message": "No clear output/in-out parameter detected; confirm function behavior manually."})
        if result.get("missing_header_files"):
            flags.append({"severity": "warning", "message": "Some configured header files are missing, so macro/type analysis may be incomplete."})
        if result.get("target_function_requested") != result.get("target_function_detected"):
            flags.append({"severity": "warning", "message": "Detected function name differs from requested function name due to namespacing/variant matching."})
        if len(result.get("function", {}).get("body_excerpt", "")) > 3900:
            flags.append({"severity": "info", "message": "Function body excerpt was truncated in JSON/markdown, but body hash and line references are preserved."})

    def _to_markdown(self, result: Dict[str, Any]) -> str:
        lines: List[str] = []
        fn = result.get("function", {})
        lines.append(f"# Code Understanding Summary: `{result.get('target_function_detected')}`")
        lines.append("")
        lines.append("## Guardrail")
        lines.append("This is an implementation-level summary only. It is not a correctness proof. CBMC/formal tools and human review remain required.")
        lines.append("")
        lines.append("## Function")
        lines.append(f"- Requested: `{result.get('target_function_requested')}`")
        lines.append(f"- Detected: `{result.get('target_function_detected')}`")
        lines.append(f"- Source: `{result.get('source_file')}`")
        lines.append(f"- Lines: {fn.get('start_line')}–{fn.get('end_line')}")
        lines.append(f"- Signature: `{fn.get('signature')}`")
        lines.append("")
        lines.append("## Implementation Summary")
        lines.append(str(result.get("implementation_summary", "")))
        lines.append("")

        def bullet_section(title: str, key: str, formatter) -> None:
            lines.append(f"## {title}")
            items = result.get(key, [])
            if not items:
                lines.append("- None detected / not confidently extracted.")
            else:
                for item in items[:30]:
                    lines.append("- " + formatter(item))
                if len(items) > 30:
                    lines.append(f"- ... {len(items) - 30} more item(s) omitted from markdown; see JSON.")
            lines.append("")

        bullet_section("Inputs", "inputs", lambda p: f"`{p.get('raw')}` direction guess: `{p.get('direction_guess')}`")
        bullet_section("Outputs / In-Outs", "outputs_or_inouts", lambda p: f"`{p.get('raw')}` direction guess: `{p.get('direction_guess')}`")
        bullet_section("Loops", "loop_structure", lambda l: f"`{l.get('kind')}` at line {l.get('line')}: `{l.get('raw') or l.get('condition')}`")
        bullet_section("Array Accesses", "array_accesses", lambda a: f"line {a.get('line')}: `{a.get('expression')}` index `{a.get('index')}` ({a.get('access_context_guess')})")
        bullet_section("Pointer Accesses", "pointer_accesses", lambda p: f"line {p.get('line')}: `{p.get('expression')}` ({p.get('access_context_guess')})")
        bullet_section("Writes / Assignments", "output_writes_and_assignments", lambda w: f"line {w.get('line')}: `{w.get('lhs')} {w.get('operator')} {w.get('rhs')}`")
        bullet_section("Helper Calls", "helper_function_or_macro_calls", lambda c: f"line {c.get('line')}: `{c.get('name')}({c.get('arguments_raw')})`")
        bullet_section("Integer / Bit Operations", "integer_and_bit_operations", lambda o: f"line {o.get('line')}: {', '.join(o.get('operations', []))} in `{o.get('statement')}`")
        bullet_section("Candidate Properties From Code", "possible_properties_from_code", lambda p: f"{p.get('id')} [{p.get('priority')}] {p.get('description')}")
        bullet_section("Risks", "implementation_risks", lambda r: f"[{r.get('severity')}] {r.get('type')}: {r.get('message')}")
        bullet_section("Uncertainties", "uncertainties", lambda u: str(u))

        lines.append("## Agent 3 v2 Additive Outputs")
        v2 = result.get("v2_outputs", {})
        if v2:
            for key, rel in v2.items():
                lines.append(f"- `{key}`: `{rel}`")
        else:
            lines.append("- v2 outputs are written after analysis; see run directory if not listed here.")
        lines.append("")

        lines.append("## CBMC Hints")
        cbmc = result.get("cbmc_hints", {})
        lines.append(f"- Harness function suggestion: `{cbmc.get('suggested_cbmc_function')}`")
        lines.append(f"- Target function call: `{cbmc.get('target_function_for_harness_call')}`")
        lines.append(f"- Unwind guess: `{cbmc.get('unwind_guess')}`")
        lines.append("- Recommended checks: " + ", ".join(cbmc.get("recommended_checks", [])))
        lines.append("")
        return "\n".join(lines).strip() + "\n"


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Agent 3: Code Understanding Agent for AI-assisted formal-verification artifact generation."
    )
    parser.add_argument("--config", required=True, help="Path to run config JSON or resolved config JSON.")
    parser.add_argument("--run-dir", required=False, help="Run directory where outputs should be written.")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    run_dir = Path(args.run_dir).expanduser().resolve() if args.run_dir else None
    agent = CodeUnderstandingAgent(Path(args.config), run_dir)
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
