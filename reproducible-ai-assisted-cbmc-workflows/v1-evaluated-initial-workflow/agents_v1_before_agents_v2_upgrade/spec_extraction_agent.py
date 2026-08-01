#!/usr/bin/env python3
"""
Specification Extraction Agent (Agent 2)
=======================================

Purpose
-------
Reads a selected cryptographic specification excerpt and extracts only the
formal-verification-relevant information needed for the selected implementation
component.

This agent follows the thesis guardrail:
- It does NOT claim to understand or prove the whole ML-KEM standard.
- It extracts candidate constants, assumptions, guarantees, safety properties,
  functional properties, artifact hints, and uncertainties.
- Every important extracted claim is tied to evidence text/line numbers when
  available.
- Unsupported or broad claims are recorded as uncertainties or rejected claims.

Designed to be called by:
    python3 agents/spec_extraction_agent.py --config runs/.../run_config.resolved.json --run-dir runs/...

Python: 3.10+
Dependencies: standard library only.

Optional future LLM mode
------------------------
This script is fully functional without an API key. It uses deterministic,
evidence-based extraction. Later, you can add a local/API LLM by setting:

{
  "spec_extraction_settings": {
    "use_external_llm": true,
    "llm_command": ["python3", "my_llm_wrapper.py"]
  }
}

The command receives the structured prompt on stdin and should return JSON on stdout.
If it fails or returns invalid JSON, this agent safely falls back to deterministic extraction.
"""

from __future__ import annotations

import argparse
import dataclasses
import datetime as _dt
import json
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


# ---------------------------------------------------------------------------
# Data models
# ---------------------------------------------------------------------------

@dataclasses.dataclass
class Evidence:
    """Small evidence object tying an extracted claim to the input excerpt."""

    source_file: str
    start_line: int
    end_line: int
    text: str

    def to_dict(self) -> Dict[str, Any]:
        return dataclasses.asdict(self)


@dataclasses.dataclass
class Sentence:
    """A sentence/snippet with source line tracking."""

    text: str
    start_line: int
    end_line: int

    def evidence(self, source_file: str) -> Evidence:
        return Evidence(
            source_file=source_file,
            start_line=self.start_line,
            end_line=self.end_line,
            text=self.text.strip(),
        )


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
        "\u2022": "-",
        "\uf0b7": "-",
        "\u00b7": "-",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    # Keep line numbers stable; only normalize intra-line whitespace later.
    return text


# ---------------------------------------------------------------------------
# Input loading
# ---------------------------------------------------------------------------

def read_docx_text(path: Path) -> str:
    """Extract text from a DOCX using only the Python standard library."""
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


def load_spec_text(path: Path) -> str:
    suffix = path.suffix.lower()
    if not path.exists():
        raise FileNotFoundError(f"Specification file not found: {path}")

    if suffix == ".docx":
        return normalize_text(read_docx_text(path))

    if suffix == ".json":
        data = read_json(path)
        # If the JSON has a clear text field, prefer it; otherwise preserve all content.
        for key in ["spec_text", "text", "excerpt", "content", "specification"]:
            if isinstance(data.get(key), str):
                return normalize_text(data[key])
        return normalize_text(json.dumps(data, indent=2, ensure_ascii=False))

    if suffix == ".pdf":
        raise ValueError(
            "PDF input is not supported by this no-dependency terminal agent. "
            "Please copy the selected FIPS/ML-KEM excerpt into a .txt/.md file first. "
            "This keeps the thesis experiment reproducible and avoids unreliable OCR."
        )

    return normalize_text(path.read_text(encoding="utf-8", errors="replace"))


# ---------------------------------------------------------------------------
# Text segmentation and evidence tracking
# ---------------------------------------------------------------------------

_BULLET_RE = re.compile(r"^\s*(?:[-*]+|\d+[.)]|[a-zA-Z][.)])\s+")
_SENTENCE_SPLIT_RE = re.compile(r"(?<=[.!?;:])\s+(?=[A-Z0-9_\-`'\"(])")


def clean_line(line: str) -> str:
    line = _BULLET_RE.sub("", line.strip())
    line = re.sub(r"\s+", " ", line)
    return line.strip()


def segment_sentences(text: str) -> List[Sentence]:
    """Split text into evidence-carrying sentences/snippets.

    We avoid aggressive NLP because thesis reproducibility matters. Each non-empty
    line becomes one or more snippets, with the original line number preserved.
    """
    result: List[Sentence] = []
    lines = text.splitlines()

    for idx, raw in enumerate(lines, start=1):
        line = clean_line(raw)
        if not line:
            continue
        parts = _SENTENCE_SPLIT_RE.split(line)
        for part in parts:
            part = part.strip()
            if len(part) < 2:
                continue
            result.append(Sentence(text=part, start_line=idx, end_line=idx))

    # Join obvious wrapped sentences: if a line does not end with sentence punctuation,
    # and the next line begins lowercase/continuation, combine them as additional snippets.
    combined: List[Sentence] = []
    buffer: Optional[Sentence] = None
    for sent in result:
        if buffer is None:
            buffer = sent
            continue
        prev = buffer.text
        starts_continuation = bool(re.match(r"^(and|or|with|where|such|that|to|for|of|in|modulo|under)\b", sent.text, re.I))
        if not prev.endswith((".", "!", "?", ";", ":")) and (starts_continuation or sent.start_line == buffer.end_line + 1):
            buffer = Sentence(
                text=(buffer.text + " " + sent.text).strip(),
                start_line=buffer.start_line,
                end_line=sent.end_line,
            )
        else:
            combined.append(buffer)
            buffer = sent
    if buffer is not None:
        combined.append(buffer)

    # Preserve both line-level and combined snippets by returning combined when useful.
    return combined or result


# ---------------------------------------------------------------------------
# Extraction logic
# ---------------------------------------------------------------------------

FUNCTION_ALIASES: Dict[str, List[str]] = {
    "poly_add": ["poly_add", "polynomial addition", "add", "addition", "sum", "coefficient-wise", "coefficients"],
    "poly_sub": ["poly_sub", "polynomial subtraction", "subtract", "subtraction", "difference", "coefficient-wise", "coefficients"],
    "poly_reduce": ["poly_reduce", "polynomial reduction", "reduce", "reduction", "modular reduction", "coefficients"],
    "barrett_reduce": ["barrett_reduce", "barrett", "reduce", "reduction", "modular reduction", "modulus"],
    "poly_tobytes": ["poly_tobytes", "encode", "serialize", "bytes", "pack", "packing", "polynomial"],
    "poly_frombytes": ["poly_frombytes", "decode", "deserialize", "bytes", "unpack", "unpacking", "polynomial"],
    "compress": ["compress", "compression", "round", "encoding"],
    "decompress": ["decompress", "decompression", "round", "decoding"],
}


def target_keywords(target_function: str, target_scheme: str = "") -> List[str]:
    base = set(FUNCTION_ALIASES.get(target_function, []))
    base.add(target_function)
    base.update(re.split(r"[_\W]+", target_function))
    if "poly" in target_function or "kem" in target_scheme.lower():
        base.update(["polynomial", "coefficients", "coefficient", "modulus", "modulo"])
    return sorted({kw.lower() for kw in base if kw and len(kw) > 1})


def contains_any(text: str, keywords: Sequence[str]) -> bool:
    low = text.lower()
    return any(kw.lower() in low for kw in keywords)


def rank_relevance(sentence: Sentence, keywords: Sequence[str]) -> int:
    low = sentence.text.lower()
    score = 0
    for kw in keywords:
        if kw in low:
            score += 2 if kw in {"poly_add", "barrett_reduce", "poly_reduce", "poly_sub"} else 1
    for important in ["must", "shall", "requires", "input", "output", "modulus", "coefficient", "array", "range", "valid"]:
        if important in low:
            score += 1
    return score


def choose_relevant_sentences(sentences: List[Sentence], keywords: Sequence[str], max_items: int = 80) -> List[Sentence]:
    scored = [(rank_relevance(s, keywords), s) for s in sentences]
    relevant = [s for score, s in scored if score > 0]
    if not relevant:
        # Do not give up; for very small excerpts, use all snippets.
        relevant = sentences[:]
    relevant.sort(key=lambda s: (-rank_relevance(s, keywords), s.start_line))
    selected = relevant[:max_items]
    selected.sort(key=lambda s: s.start_line)
    return selected


def make_claim(claim: str, evidence: Evidence, *, category: str, confidence: str = "medium", supported: bool = True) -> Dict[str, Any]:
    return {
        "claim": claim,
        "category": category,
        "confidence": confidence,
        "supported_by_excerpt": supported,
        "evidence": evidence.to_dict(),
    }


def add_unique_claim(items: List[Dict[str, Any]], item: Dict[str, Any]) -> None:
    norm = re.sub(r"\s+", " ", item.get("claim", "").strip().lower())
    existing = {re.sub(r"\s+", " ", x.get("claim", "").strip().lower()) for x in items}
    if norm and norm not in existing:
        items.append(item)


def extract_constants(relevant: List[Sentence], source_file: str, known_constants: Dict[str, Any]) -> Dict[str, Any]:
    constants: Dict[str, Any] = {}

    def put(name: str, value: Any, evidence: Evidence, confidence: str = "medium", note: str = "") -> None:
        key = str(name).strip()
        if not key:
            return
        prev = constants.get(key)
        entry = {
            "value": value,
            "confidence": confidence,
            "note": note,
            "evidence": evidence.to_dict(),
        }
        # Prefer directly named constants over vague later mentions.
        if prev is None or prev.get("confidence") == "low" and confidence in {"medium", "high"}:
            constants[key] = entry

    for sent in relevant:
        text = sent.text
        ev = sent.evidence(source_file)

        # Named constants: q = 3329, KYBER_N = 256, N: 256, modulus q is 3329.
        for m in re.finditer(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*(?:=|:|is)\s*(-?\d+)\b", text):
            name, value = m.group(1), int(m.group(2))
            if name.lower() in {"is", "are", "has", "have", "contains", "contain"}:
                continue
            put(name, value, ev, "high", "direct named numeric constant")

        # Modulus q is 3329 / modulus is 3329 / modulo 3329.
        for pattern in [
            r"\bmodulus\s+(?:q\s+)?(?:is|=|:)?\s*(\d+)\b",
            r"\bmodulo\s+(\d+)\b",
            r"\bmod\s+(\d+)\b",
        ]:
            for m in re.finditer(pattern, text, flags=re.I):
                put("q", int(m.group(1)), ev, "high", "modulus value extracted from excerpt")

        # Each polynomial has 256 coefficients.
        m = re.search(r"\b(?:polynomial|poly)\w*\s+(?:has|contains|with|of)\s+(\d+)\s+coefficients?\b", text, flags=re.I)
        if m:
            put("N", int(m.group(1)), ev, "high", "polynomial coefficient count extracted from excerpt")

        # 256 coefficients.
        m = re.search(r"\b(\d+)\s+coefficients?\b", text, flags=re.I)
        if m and ("polynomial" in text.lower() or "poly" in text.lower()):
            put("N", int(m.group(1)), ev, "medium", "coefficient count inferred from polynomial sentence")

        # Array size/length 256.
        m = re.search(r"\b(?:array|vector|list)\w*\s+(?:size|length|of)?\s*(?:is|=|:)?\s*(\d+)\b", text, flags=re.I)
        if m:
            put("array_length", int(m.group(1)), ev, "medium", "array/vector length extracted from excerpt")

        # bit width / signed 16-bit, etc.
        m = re.search(r"\b(signed|unsigned)?\s*(\d+)\s*-?bit\b", text, flags=re.I)
        if m:
            signedness = (m.group(1) or "unspecified").lower()
            width = int(m.group(2))
            name = "coefficient_bit_width" if "coeff" in text.lower() else "integer_bit_width"
            put(name, {"bits": width, "signedness": signedness}, ev, "medium", "bit width extracted from excerpt")

    # Config-known constants are allowed, but marked as config evidence, not spec evidence.
    for key, value in known_constants.items():
        if key not in constants:
            constants[key] = {
                "value": value,
                "confidence": "config_provided",
                "note": "Provided by config known_constants; verify against selected specification excerpt.",
                "evidence": {
                    "source_file": "config.known_constants",
                    "start_line": 0,
                    "end_line": 0,
                    "text": f"{key} = {value}",
                },
            }

    return constants


def extract_assumptions(relevant: List[Sentence], source_file: str) -> List[Dict[str, Any]]:
    assumption_keywords = [
        "input", "inputs", "valid", "must", "shall", "requires", "required", "requirement",
        "assume", "assumption", "precondition", "given", "provided", "represented", "contains",
        "length", "size", "range", "bounded", "coefficient", "polynomial", "array", "pointer",
    ]
    outputish = ["output", "result", "returns", "produces"]
    items: List[Dict[str, Any]] = []
    for sent in relevant:
        low = sent.text.lower()
        if contains_any(low, assumption_keywords):
            # Sentences can be both input and output; keep them if they express shape/range.
            if contains_any(low, outputish) and not contains_any(low, ["input", "valid", "range", "size", "length", "coefficient"]):
                continue
            category = "input_shape_or_precondition"
            if "range" in low or "bound" in low or "mod" in low:
                category = "range_or_modulus_assumption"
            elif "pointer" in low:
                category = "pointer_validity_assumption"
            elif "array" in low or "length" in low or "size" in low or "coefficients" in low:
                category = "shape_or_size_assumption"
            add_unique_claim(
                items,
                make_claim(
                    sent.text,
                    sent.evidence(source_file),
                    category=category,
                    confidence="medium",
                    supported=True,
                ),
            )
    return items[:30]


def extract_guarantees(relevant: List[Sentence], source_file: str) -> List[Dict[str, Any]]:
    keywords = [
        "output", "outputs", "result", "returns", "produces", "stores", "writes", "guarantee",
        "ensures", "after", "equals", "equal", "sum", "difference", "reduced", "modulo", "correct",
        "corresponding", "coefficient-wise", "coefficientwise",
    ]
    items: List[Dict[str, Any]] = []
    for sent in relevant:
        low = sent.text.lower()
        if contains_any(low, keywords):
            category = "output_guarantee"
            if "mod" in low or "reduc" in low:
                category = "modular_or_range_output_guarantee"
            elif "sum" in low or "add" in low or "equals" in low:
                category = "functional_output_guarantee"
            add_unique_claim(
                items,
                make_claim(
                    sent.text,
                    sent.evidence(source_file),
                    category=category,
                    confidence="medium",
                    supported=True,
                ),
            )
    return items[:30]


def constant_value(constants: Dict[str, Any], names: Sequence[str]) -> Optional[Any]:
    lower_map = {k.lower(): v for k, v in constants.items()}
    for name in names:
        entry = lower_map.get(name.lower())
        if entry is not None:
            return entry.get("value")
    return None


def extract_candidate_safety_properties(
    relevant: List[Sentence],
    source_file: str,
    constants: Dict[str, Any],
    target_function: str,
) -> List[Dict[str, Any]]:
    items: List[Dict[str, Any]] = []
    n_val = constant_value(constants, ["N", "KYBER_N", "MLKEM_N", "array_length"])
    q_val = constant_value(constants, ["q", "KYBER_Q", "MLKEM_Q"])

    # Properties directly motivated by constants.
    if n_val is not None:
        add_unique_claim(
            items,
            {
                "id": "SP1",
                "type": "memory_safety",
                "claim": f"For {target_function}, any coefficient-loop or array access should stay within the valid polynomial index range implied by N = {n_val}.",
                "cbmc_relevance": ["--bounds-check", "--pointer-check", "--unwind"],
                "supported_by_excerpt": True,
                "confidence": "medium",
                "evidence": _first_constant_evidence(constants, ["N", "KYBER_N", "MLKEM_N", "array_length"]),
                "human_review_note": "The code agent must later confirm the actual loop bound and array field name.",
            },
        )

    if q_val is not None:
        add_unique_claim(
            items,
            {
                "id": "SP2",
                "type": "range_safety",
                "claim": f"Coefficient values used by {target_function} should be checked against assumptions justified by modulus q = {q_val}, but q alone does not automatically justify an input range.",
                "cbmc_relevance": ["__CPROVER_assume", "assert range property if selected"],
                "supported_by_excerpt": True,
                "confidence": "medium",
                "evidence": _first_constant_evidence(constants, ["q", "KYBER_Q", "MLKEM_Q"]),
                "human_review_note": "Do not blindly assume [-q, q] or [0, q-1] unless the selected excerpt supports that precondition.",
            },
        )

    # Properties motivated by sentences.
    safety_keywords = ["out-of-bounds", "bounds", "array", "overflow", "integer", "memory", "valid", "range", "pointer", "access"]
    for sent in relevant:
        low = sent.text.lower()
        if contains_any(low, safety_keywords):
            ptype = "safety"
            cbmc_flags = []
            if "overflow" in low or "integer" in low or "signed" in low or "unsigned" in low:
                ptype = "integer_overflow"
                cbmc_flags = ["--signed-overflow-check", "--unsigned-overflow-check"]
            elif "array" in low or "bounds" in low or "access" in low:
                ptype = "memory_safety"
                cbmc_flags = ["--bounds-check", "--pointer-check"]
            elif "pointer" in low:
                ptype = "pointer_validity"
                cbmc_flags = ["--pointer-check"]
            add_unique_claim(
                items,
                {
                    "id": f"SP{len(items) + 1}",
                    "type": ptype,
                    "claim": sent.text,
                    "cbmc_relevance": cbmc_flags or ["CBMC safety checks"],
                    "supported_by_excerpt": True,
                    "confidence": "medium",
                    "evidence": sent.evidence(source_file).to_dict(),
                    "human_review_note": "Candidate property only; Code Understanding Agent must connect it to actual C accesses/operations.",
                },
            )
    return items[:25]


def _first_constant_evidence(constants: Dict[str, Any], names: Sequence[str]) -> Dict[str, Any]:
    lower_map = {k.lower(): v for k, v in constants.items()}
    for name in names:
        entry = lower_map.get(name.lower())
        if entry is not None:
            return entry.get("evidence", {})
    return {}


def extract_candidate_functional_properties(
    relevant: List[Sentence],
    source_file: str,
    target_function: str,
) -> List[Dict[str, Any]]:
    items: List[Dict[str, Any]] = []
    keywords = ["equals", "equal", "sum", "add", "addition", "subtract", "difference", "reduce", "reduction", "modulo", "coefficient-wise", "corresponding", "encode", "decode", "pack", "unpack"]
    for sent in relevant:
        low = sent.text.lower()
        if contains_any(low, keywords):
            ptype = "functional_correctness_candidate"
            if "mod" in low or "reduce" in low:
                ptype = "modular_functional_correctness_candidate"
            elif "pack" in low or "unpack" in low or "encode" in low or "decode" in low:
                ptype = "encoding_decoding_correctness_candidate"
            add_unique_claim(
                items,
                {
                    "id": f"FP{len(items) + 1}",
                    "type": ptype,
                    "claim": sent.text,
                    "supported_by_excerpt": True,
                    "confidence": "medium",
                    "evidence": sent.evidence(source_file).to_dict(),
                    "cbmc_hint": "Convert into assertions only after Code Understanding Agent confirms the implementation variables and representation.",
                    "human_review_note": "Candidate property; must not be treated as a final proof obligation without checking assumptions.",
                },
            )
    return items[:25]


def build_artifact_hints(
    constants: Dict[str, Any],
    assumptions: List[Dict[str, Any]],
    safety_properties: List[Dict[str, Any]],
    functional_properties: List[Dict[str, Any]],
    target_function: str,
    verification_tool: str,
) -> Dict[str, Any]:
    n_val = constant_value(constants, ["N", "KYBER_N", "MLKEM_N", "array_length"])
    q_val = constant_value(constants, ["q", "KYBER_Q", "MLKEM_Q"])

    cbmc_settings: Dict[str, Any] = {
        "recommended_checks": [],
        "candidate_unwind": None,
        "candidate_assumptions": [],
        "candidate_assertion_themes": [],
        "warnings": [],
    }

    if verification_tool.lower() == "cbmc":
        cbmc_settings["recommended_checks"].extend(["--bounds-check", "--pointer-check"])
        if any(p.get("type") == "integer_overflow" for p in safety_properties):
            cbmc_settings["recommended_checks"].extend(["--signed-overflow-check", "--unsigned-overflow-check"])
        else:
            cbmc_settings["recommended_checks"].append("--signed-overflow-check")

        if isinstance(n_val, int):
            cbmc_settings["candidate_unwind"] = n_val
            cbmc_settings["candidate_assumptions"].append(
                {
                    "assumption": f"Polynomial arrays have at least {n_val} coefficients when calling {target_function}.",
                    "support_level": "derived_from_extracted_constant",
                    "must_be_confirmed_by_code_agent": True,
                }
            )

        if q_val is not None:
            cbmc_settings["candidate_assumptions"].append(
                {
                    "assumption": f"Any coefficient range assumption should be justified from the selected excerpt before using q = {q_val} in __CPROVER_assume.",
                    "support_level": "warning_not_direct_precondition",
                    "must_be_confirmed_by_human": True,
                }
            )
            cbmc_settings["warnings"].append(
                "Modulus q does not automatically mean every input coefficient is already in [0, q-1] or [-q, q]. The harness must justify the exact range."
            )

        for prop in safety_properties[:5]:
            cbmc_settings["candidate_assertion_themes"].append({"type": prop.get("type"), "claim": prop.get("claim")})
        for prop in functional_properties[:5]:
            cbmc_settings["candidate_assertion_themes"].append({"type": prop.get("type"), "claim": prop.get("claim")})

    return {
        "tool": verification_tool,
        "target_function": target_function,
        "cbmc": cbmc_settings,
        "next_agent_needs": [
            "Code Understanding Agent must confirm actual C function signature and data structures.",
            "Property Discovery Agent must combine this summary with code_summary before selecting final candidate properties.",
            "Artifact Generation Agent must cite assumptions and keep generated harnesses as candidate artifacts only.",
        ],
    }


def build_uncertainties(
    constants: Dict[str, Any],
    assumptions: List[Dict[str, Any]],
    guarantees: List[Dict[str, Any]],
    relevant: List[Sentence],
    target_function: str,
) -> List[Dict[str, Any]]:
    uncertainties: List[Dict[str, Any]] = []

    def add(message: str, severity: str = "medium", next_step: str = "Human/code-agent review required.") -> None:
        if not any(u["message"] == message for u in uncertainties):
            uncertainties.append({"message": message, "severity": severity, "next_step": next_step})

    if constant_value(constants, ["N", "KYBER_N", "MLKEM_N", "array_length"]) is None:
        add("Polynomial/array length was not clearly extracted from the selected excerpt.", "medium", "Add the relevant size/length sentence to the spec excerpt or provide known_constants in config.")
    if constant_value(constants, ["q", "KYBER_Q", "MLKEM_Q"]) is None:
        add("Modulus q was not clearly extracted from the selected excerpt.", "medium", "Add the modulus sentence to the spec excerpt or provide known_constants in config.")
    if not assumptions:
        add("No clear input assumptions/preconditions were extracted.", "high", "Do not generate strong __CPROVER_assume statements until assumptions are available.")
    if not guarantees:
        add("No clear output guarantees were extracted.", "high", "Property Discovery Agent should avoid strong functional assertions until the expected behavior is clearer.")

    # Function relevance check.
    joined = "\n".join(s.text.lower() for s in relevant)
    tf_parts = [p for p in re.split(r"[_\W]+", target_function.lower()) if p]
    if tf_parts and not any(p in joined for p in tf_parts):
        add(f"The selected excerpt may not explicitly mention or clearly relate to target function '{target_function}'.", "medium", "Use a more focused excerpt or include scheme metadata explaining the mapping.")

    add("Specification excerpt alone may not define implementation-level C integer type behavior.", "medium", "Code Understanding Agent must inspect typedefs, macros, and helper functions.")
    add("Specification-level mathematical operations may not directly map to one C function if reduction/normalization is split across helper functions.", "medium", "Property Discovery Agent should avoid claiming full algorithm correctness from one helper function.")
    return uncertainties


def build_rejected_claims(target_function: str) -> List[Dict[str, Any]]:
    return [
        {
            "claim": "Full ML-KEM implementation correctness is proved by this specification extraction step.",
            "reason": "Too broad and scientifically unsafe. This agent only extracts candidate verification-relevant facts from a selected excerpt.",
        },
        {
            "claim": f"The function {target_function} is correct because the excerpt describes the intended operation.",
            "reason": "Specification extraction does not check C implementation behavior. Code understanding and CBMC/tool execution are required later.",
        },
        {
            "claim": "Any coefficient range assumption can be freely chosen from modulus q alone.",
            "reason": "A modulus value is not automatically a valid precondition for all implementation inputs. Assumptions must be explicitly justified.",
        },
        {
            "claim": "LLM-generated formal artifacts are final proof artifacts.",
            "reason": "The thesis guardrail says generated artifacts are candidates; formal tools and human review remain the authority.",
        },
    ]


# ---------------------------------------------------------------------------
# Optional external LLM support
# ---------------------------------------------------------------------------

def build_structured_prompt(
    *,
    target_scheme: str,
    target_function: str,
    verification_goal: str,
    spec_file: str,
    spec_text: str,
    known_constants: Dict[str, Any],
) -> str:
    # Keep prompt reproducible and saved even in deterministic mode.
    excerpt = spec_text
    max_prompt_chars = 25000
    if len(excerpt) > max_prompt_chars:
        excerpt = excerpt[:max_prompt_chars] + "\n\n[TRUNCATED_FOR_PROMPT_SAVE_ONLY]"

    return textwrap.dedent(
        f"""
        You are assisting early-stage formal verification of a post-quantum cryptographic implementation.

        Scientific guardrails:
        1. Do not claim that the whole implementation is proved.
        2. Do not invent unsupported claims.
        3. Separate extracted facts from candidate properties.
        4. Mark uncertainties clearly.
        5. Every assumption must be traceable to the selected excerpt, config metadata, or explicitly marked as requiring human/code review.

        Target scheme: {target_scheme}
        Target function: {target_function}
        Verification goal: {verification_goal}
        Specification file: {spec_file}
        Known constants from config: {json.dumps(known_constants, ensure_ascii=False)}

        Task:
        Extract the following as JSON:
        - constants
        - input_assumptions
        - candidate_output_guarantees
        - candidate_safety_properties
        - candidate_functional_properties
        - artifact_hints
        - uncertainties
        - rejected_or_unsupported_claims

        Selected specification excerpt:
        --- BEGIN SPEC EXCERPT ---
        {excerpt}
        --- END SPEC EXCERPT ---
        """
    ).strip() + "\n"


def run_external_llm_if_enabled(
    config: Dict[str, Any],
    prompt: str,
    run_dir: Path,
    event_log_path: Path,
) -> Optional[Dict[str, Any]]:
    settings = config.get("spec_extraction_settings", {})
    if not isinstance(settings, dict):
        settings = {}
    if not settings.get("use_external_llm", False):
        return None

    cmd = settings.get("llm_command")
    if not cmd:
        append_jsonl(event_log_path, {"timestamp": utc_now(), "event_type": "spec_llm_skipped", "reason": "use_external_llm=true but llm_command missing"})
        return None

    if isinstance(cmd, str):
        command = shlex.split(cmd)
    elif isinstance(cmd, list):
        command = [str(x) for x in cmd]
    else:
        append_jsonl(event_log_path, {"timestamp": utc_now(), "event_type": "spec_llm_skipped", "reason": "llm_command must be string or list"})
        return None

    timeout = int(settings.get("timeout_seconds", 120))
    stdout_path = run_dir / "stdout_stderr" / "spec_extraction_external_llm_stdout.txt"
    stderr_path = run_dir / "stdout_stderr" / "spec_extraction_external_llm_stderr.txt"

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
            "event_type": "spec_llm_attempted",
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
        data["extraction_method"] = "external_llm"
        data["llm_output_file"] = str(stdout_path)
        return data
    except Exception as e:
        append_jsonl(event_log_path, {
            "timestamp": utc_now(),
            "event_type": "spec_llm_failed_fallback_to_deterministic",
            "error": str(e),
        })
        return None


# ---------------------------------------------------------------------------
# Main extraction class
# ---------------------------------------------------------------------------

class SpecificationExtractionAgent:
    """Agent 2: extracts verification-relevant facts from selected spec excerpt."""

    def __init__(self, config_path: Path, run_dir_arg: Optional[Path] = None) -> None:
        self.config_path = config_path.resolve()
        self.config = read_json(self.config_path)
        self.project_root = Path(self.config.get("project_root", self.config_path.parent.parent)).resolve()
        self.run_dir = (run_dir_arg or resolve_path(self.project_root, str(self.config.get("run_dir", "runs/current")))).resolve()
        self.run_dir.mkdir(parents=True, exist_ok=True)
        (self.run_dir / "llm_prompts").mkdir(exist_ok=True)
        (self.run_dir / "llm_outputs").mkdir(exist_ok=True)
        (self.run_dir / "agent_status").mkdir(exist_ok=True)
        (self.run_dir / "stdout_stderr").mkdir(exist_ok=True)

        self.event_log_path = self.run_dir / "events.jsonl"
        self.output_json_path = self.run_dir / "01_spec_summary.json"
        self.output_md_path = self.run_dir / "01_spec_summary.md"
        self.prompt_path = self.run_dir / "llm_prompts" / "01_spec_extraction_prompt.txt"
        self.agent_status_path = self.run_dir / "agent_status" / "01_spec_extraction_status.json"

        self.target_scheme = str(self.config.get("target_scheme", "unknown_scheme"))
        self.target_function = str(self.config.get("target_function", "unknown_function"))
        self.verification_goal = str(self.config.get("verification_goal", "not specified"))
        self.verification_tool = str(self.config.get("verification_tool", "CBMC"))
        self.known_constants = self._load_known_constants()

        spec_file = self.config.get("spec_file")
        if not spec_file:
            raise ValueError("Config must include 'spec_file'.")
        self.spec_file = resolve_path(self.project_root, str(spec_file))

    def _load_known_constants(self) -> Dict[str, Any]:
        constants: Dict[str, Any] = {}
        for key in ["known_constants", "constants"]:
            value = self.config.get(key)
            if isinstance(value, dict):
                constants.update(value)
        settings = self.config.get("spec_extraction_settings", {})
        if isinstance(settings, dict) and isinstance(settings.get("known_constants"), dict):
            constants.update(settings["known_constants"])
        return constants

    def log_event(self, event_type: str, payload: Dict[str, Any]) -> None:
        append_jsonl(self.event_log_path, {"timestamp": utc_now(), "agent": "spec_extraction", "event_type": event_type, **payload})

    def run(self) -> int:
        started_at = utc_now()
        try:
            self.log_event("agent_start", {
                "target_scheme": self.target_scheme,
                "target_function": self.target_function,
                "spec_file": str(self.spec_file),
                "output": str(self.output_json_path),
            })

            spec_text = load_spec_text(self.spec_file)
            if not spec_text.strip():
                raise ValueError(f"Specification file is empty after parsing: {self.spec_file}")

            prompt = build_structured_prompt(
                target_scheme=self.target_scheme,
                target_function=self.target_function,
                verification_goal=self.verification_goal,
                spec_file=str(self.spec_file),
                spec_text=spec_text,
                known_constants=self.known_constants,
            )
            write_text(self.prompt_path, prompt)

            llm_result = run_external_llm_if_enabled(self.config, prompt, self.run_dir, self.event_log_path)
            if llm_result is not None:
                # Even when external extraction is used, wrap it with guardrail metadata.
                result = self._normalize_external_result(llm_result, spec_text, started_at)
                method = "external_llm_with_guardrails"
            else:
                result = self._deterministic_extract(spec_text, started_at)
                method = "deterministic_evidence_based"

            result["extraction_method"] = method
            result["created_at"] = utc_now()
            result["agent_name"] = "specification_extraction_agent"
            result["output_files"] = {
                "json": str(self.output_json_path),
                "markdown": str(self.output_md_path),
                "prompt": str(self.prompt_path),
                "status": str(self.agent_status_path),
            }

            self._validate_and_warn(result)
            write_json(self.output_json_path, result)
            write_text(self.output_md_path, self._to_markdown(result))

            status = {
                "agent": "spec_extraction",
                "status": "passed",
                "started_at": started_at,
                "finished_at": utc_now(),
                "output_json": str(self.output_json_path),
                "output_markdown": str(self.output_md_path),
                "prompt_file": str(self.prompt_path),
                "human_review_required": True,
            }
            write_json(self.agent_status_path, status)
            self.log_event("agent_finish", status)

            print(f"[OK] Specification Extraction Agent wrote: {self.output_json_path}")
            print(f"[OK] Markdown summary: {self.output_md_path}")
            print("[NOTE] Extracted items are candidate verification inputs; human/code review is still required.")
            return 0

        except Exception as e:
            status = {
                "agent": "spec_extraction",
                "status": "failed",
                "started_at": started_at,
                "finished_at": utc_now(),
                "error": str(e),
                "traceback": traceback.format_exc(),
                "human_review_required": True,
            }
            write_json(self.agent_status_path, status)
            self.log_event("agent_error", status)
            print(f"[ERROR] Specification Extraction Agent failed: {e}", file=sys.stderr)
            print(f"[INFO] Status file: {self.agent_status_path}", file=sys.stderr)
            return 1

    def _deterministic_extract(self, spec_text: str, started_at: str) -> Dict[str, Any]:
        sentences = segment_sentences(spec_text)
        keywords = target_keywords(self.target_function, self.target_scheme)
        relevant = choose_relevant_sentences(sentences, keywords)
        source_file = str(self.spec_file)

        constants = extract_constants(relevant, source_file, self.known_constants)
        input_assumptions = extract_assumptions(relevant, source_file)
        output_guarantees = extract_guarantees(relevant, source_file)
        safety_properties = extract_candidate_safety_properties(relevant, source_file, constants, self.target_function)
        functional_properties = extract_candidate_functional_properties(relevant, source_file, self.target_function)
        artifact_hints = build_artifact_hints(constants, input_assumptions, safety_properties, functional_properties, self.target_function, self.verification_tool)
        uncertainties = build_uncertainties(constants, input_assumptions, output_guarantees, relevant, self.target_function)
        rejected_claims = build_rejected_claims(self.target_function)

        return {
            "schema_version": "1.0",
            "target_scheme": self.target_scheme,
            "target_function": self.target_function,
            "verification_goal": self.verification_goal,
            "verification_tool": self.verification_tool,
            "spec_file": source_file,
            "spec_excerpt_stats": {
                "characters": len(spec_text),
                "lines": len(spec_text.splitlines()),
                "sentences_or_snippets": len(sentences),
                "relevant_snippets_used": len(relevant),
                "target_keywords": keywords,
            },
            "constants": constants,
            "input_assumptions": input_assumptions,
            "candidate_output_guarantees": output_guarantees,
            "candidate_safety_properties": safety_properties,
            "candidate_functional_properties": functional_properties,
            "artifact_hints": artifact_hints,
            "uncertainties": uncertainties,
            "rejected_or_unsupported_claims": rejected_claims,
            "relevant_excerpt_evidence": [s.evidence(source_file).to_dict() for s in relevant[:80]],
            "quality_flags": [],
            "scientific_guardrails": {
                "llm_or_heuristic_outputs_are_candidates_only": True,
                "formal_tool_is_not_replaced": True,
                "human_review_required": True,
                "no_claim_of_full_mlkem_proof": True,
                "assumptions_must_be_justified": True,
            },
            "agent_runtime": {
                "started_at": started_at,
                "finished_at": utc_now(),
            },
        }

    def _normalize_external_result(self, llm_result: Dict[str, Any], spec_text: str, started_at: str) -> Dict[str, Any]:
        # Build deterministic base to ensure required keys and guardrails exist.
        base = self._deterministic_extract(spec_text, started_at)
        allowed_keys = {
            "constants",
            "input_assumptions",
            "candidate_output_guarantees",
            "candidate_safety_properties",
            "candidate_functional_properties",
            "artifact_hints",
            "uncertainties",
            "rejected_or_unsupported_claims",
        }
        for key in allowed_keys:
            if key in llm_result and llm_result[key]:
                base[f"llm_{key}"] = llm_result[key]
        base["external_llm_metadata"] = {
            "used": True,
            "note": "LLM extraction is stored separately under llm_* keys; deterministic extraction remains available for auditability.",
        }
        return base

    def _validate_and_warn(self, result: Dict[str, Any]) -> None:
        flags: List[Dict[str, Any]] = []
        if not result.get("constants"):
            flags.append({"severity": "high", "message": "No constants extracted."})
        if not result.get("input_assumptions"):
            flags.append({"severity": "medium", "message": "No clear input assumptions extracted."})
        if not result.get("candidate_output_guarantees"):
            flags.append({"severity": "medium", "message": "No clear output guarantees extracted."})
        if not result.get("candidate_safety_properties") and not result.get("candidate_functional_properties"):
            flags.append({"severity": "high", "message": "No candidate properties extracted."})

        # Guard against accidental overclaiming in generated fields.
        serialized = json.dumps(result, ensure_ascii=False).lower()
        risky_phrases = [
            "fully proves ml-kem",
            "proves the entire ml-kem",
            "complete proof of ml-kem",
            "formally proved the full implementation",
        ]
        for phrase in risky_phrases:
            if phrase in serialized:
                flags.append({"severity": "critical", "message": f"Unsafe overclaim phrase detected: {phrase}"})

        result["quality_flags"] = flags

    def _to_markdown(self, data: Dict[str, Any]) -> str:
        def bullet_claims(items: Any, empty: str = "None extracted.") -> str:
            if not items:
                return f"- {empty}\n"
            lines: List[str] = []
            if isinstance(items, dict):
                for k, v in items.items():
                    lines.append(f"- **{k}**: `{json.dumps(v.get('value', v), ensure_ascii=False)}`")
                return "\n".join(lines) + "\n"
            if isinstance(items, list):
                for item in items:
                    if isinstance(item, dict):
                        claim = item.get("claim") or item.get("message") or json.dumps(item, ensure_ascii=False)
                        ev = item.get("evidence") or {}
                        loc = ""
                        if isinstance(ev, dict) and ev.get("start_line"):
                            loc = f" _(line {ev.get('start_line')})_"
                        lines.append(f"- {claim}{loc}")
                    else:
                        lines.append(f"- {item}")
                return "\n".join(lines) + "\n"
            return f"- {json.dumps(items, ensure_ascii=False)}\n"

        md = f"""# 01 Specification Summary

**Agent:** Specification Extraction Agent  
**Target scheme:** {data.get('target_scheme')}  
**Target function:** `{data.get('target_function')}`  
**Verification tool:** {data.get('verification_tool')}  
**Spec file:** `{data.get('spec_file')}`  
**Extraction method:** {data.get('extraction_method')}  

## Scientific Guardrail

This summary contains **candidate verification inputs only**. It does not prove the target function or the full ML-KEM implementation. Human review and formal tool checking are still required.

## Extracted Constants

{bullet_claims(data.get('constants'))}
## Input Assumptions / Preconditions

{bullet_claims(data.get('input_assumptions'))}
## Candidate Output Guarantees

{bullet_claims(data.get('candidate_output_guarantees'))}
## Candidate Safety Properties

{bullet_claims(data.get('candidate_safety_properties'))}
## Candidate Functional Properties

{bullet_claims(data.get('candidate_functional_properties'))}
## Artifact Hints for Next Agents

```json
{json.dumps(data.get('artifact_hints', {}), indent=2, ensure_ascii=False)}
```

## Uncertainties

{bullet_claims(data.get('uncertainties'))}
## Rejected / Unsupported Claims

{bullet_claims(data.get('rejected_or_unsupported_claims'))}
## Quality Flags

{bullet_claims(data.get('quality_flags'), empty='No major quality flags.')}
"""
        return md


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Agent 2: Specification Extraction Agent for AI-assisted formal-verification artifact workflow."
    )
    parser.add_argument("--config", required=True, help="Path to resolved run config JSON.")
    parser.add_argument("--run-dir", default=None, help="Run directory where outputs should be written.")
    return parser


def main(argv: Optional[List[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    run_dir = Path(args.run_dir).resolve() if args.run_dir else None
    agent = SpecificationExtractionAgent(Path(args.config), run_dir)
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
