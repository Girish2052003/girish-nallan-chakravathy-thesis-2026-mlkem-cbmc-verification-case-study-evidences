#!/usr/bin/env python3
"""
Agent 5: Formal Artifact Generation Agent
=========================================

Purpose
-------
This agent reads:
  01_spec_summary.json
  02_code_summary.json
  03_candidate_properties.json
  Agent 2 v2 rich specification outputs when available
  Agent 4 v2 traceability/evidence outputs when available
  selected source/header files from config

and generates candidate formal-verification artifacts. For the thesis prototype,
the main artifact is a spec-grounded CBMC C harness:
  04_generated_harness.c

It also writes:
  04_artifact_manifest.json
  04_generated_harness.md
  04_spec_grounding_report.json
  04_spec_grounded_assertion_plan.json
  04_harness_assumption_traceability.csv
  llm_prompts/04_artifact_generation_prompt.txt
  agent_status/04_artifact_generation_status.json

Scientific guardrail
--------------------
This agent DOES NOT prove ML-KEM and DOES NOT claim generated artifacts are correct.
It creates candidate CBMC artifacts that must be reviewed by the Critic Agent,
checked by CBMC/formal tools, and inspected by the human researcher.

Design notes
------------
- Standard-library only.
- Works deterministically without an API key.
- Includes clean hooks for future LLM/API generation.
- Uses template-backed generation for safer, reproducible first artifacts.
- Separates assumptions, assertions, CBMC checks, and human-review notes.
- Consumes Agent 2 v2 parsed FIPS algorithms/symbols/parameters/constraints when present.
- Consumes Agent 4 v2 traceability/property evidence when present.
- Keeps all spec-grounded assumptions candidate/human-reviewable rather than silently trusted.

Typical use
-----------
python3 agents/artifact_generation_agent.py \
  --config configs/poly_add_run.json \
  --run-dir runs/run_001_poly_add
"""

from __future__ import annotations

import argparse
import dataclasses
import datetime as _dt
import hashlib
import json
import os
import re
import sys
import traceback
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple


JsonDict = Dict[str, Any]


# ---------------------------------------------------------------------------
# Generic utilities
# ---------------------------------------------------------------------------

def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


def read_json(path: Path) -> JsonDict:
    with path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected JSON object in {path}, got {type(data).__name__}")
    return data


def write_json(path: Path, data: JsonDict) -> None:
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


def append_jsonl(path: Path, data: JsonDict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(data, ensure_ascii=False) + "\n")


def sha256_short(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8", errors="replace")).hexdigest()[:16]


def normalize_text(value: str) -> str:
    return re.sub(r"\s+", " ", value or "").strip()


def as_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def first_nonempty(*values: Any, default: Any = None) -> Any:
    for value in values:
        if value not in (None, "", [], {}):
            return value
    return default


def resolve_path(project_root: Path, path_value: Optional[str], fallback: Optional[Path] = None) -> Path:
    if path_value:
        p = Path(path_value).expanduser()
        if not p.is_absolute():
            p = project_root / p
        return p.resolve()
    if fallback is None:
        raise ValueError("Missing required path value and no fallback was provided")
    return fallback.resolve()


def find_project_root(config_path: Path) -> Path:
    parent = config_path.resolve().parent
    if parent.name == "configs":
        return parent.parent
    return parent


def safe_identifier(value: str, fallback: str = "x") -> str:
    value = re.sub(r"[^A-Za-z0-9_]", "_", value or "")
    value = re.sub(r"_+", "_", value).strip("_")
    if not value:
        value = fallback
    if value[0].isdigit():
        value = "_" + value
    return value


def strip_c_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"//.*?$", "", text, flags=re.M)
    return text


def read_text_if_exists(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return ""


def item_text(item: Any, keys: Sequence[str] = ("description", "claim", "text", "message", "summary")) -> str:
    if isinstance(item, str):
        return normalize_text(item)
    if isinstance(item, dict):
        for key in keys:
            value = item.get(key)
            if isinstance(value, str) and value.strip():
                return normalize_text(value)
        return normalize_text(json.dumps(item, ensure_ascii=False, sort_keys=True))
    return normalize_text(str(item))


def unique_list(values: Iterable[str]) -> List[str]:
    seen: set[str] = set()
    out: List[str] = []
    for value in values:
        value = normalize_text(value)
        if not value or value in seen:
            continue
        seen.add(value)
        out.append(value)
    return out


def read_json_if_exists(path: Path, default: Optional[JsonDict] = None) -> JsonDict:
    """Read JSON if present; return {} by default. Never fail for optional v2 files."""
    if default is None:
        default = {}
    if not path.exists():
        return default
    try:
        return read_json(path)
    except Exception as exc:
        return {
            "_read_error": str(exc),
            "_path": str(path),
            "_human_review_required": True,
        }


def write_csv(path: Path, rows: Sequence[JsonDict], fieldnames: Optional[Sequence[str]] = None) -> None:
    """Small CSV writer for traceability artifacts."""
    import csv
    path.parent.mkdir(parents=True, exist_ok=True)
    if fieldnames is None:
        keys: List[str] = []
        for row in rows:
            for key in row.keys():
                if key not in keys:
                    keys.append(key)
        fieldnames = keys
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(fieldnames))
        writer.writeheader()
        for row in rows:
            cleaned = {}
            for key in fieldnames:
                value = row.get(key, "")
                if isinstance(value, (dict, list)):
                    value = json.dumps(value, ensure_ascii=False, sort_keys=True)
                cleaned[key] = value
            writer.writerow(cleaned)


def flatten_text(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, (int, float, bool)):
        return str(value)
    if isinstance(value, dict):
        return " ".join(flatten_text(v) for v in value.values())
    if isinstance(value, list):
        return " ".join(flatten_text(v) for v in value)
    return str(value)


def parse_int_loose(value: Any) -> Optional[int]:
    if isinstance(value, int):
        return value
    if isinstance(value, float) and value.is_integer():
        return int(value)
    text = str(value or "").strip()
    if not text:
        return None
    text = text.replace("−", "-")
    m = re.fullmatch(r"[-+]?\d+", text)
    if m:
        return int(text)
    m = re.fullmatch(r"0x[0-9a-fA-F]+", text)
    if m:
        return int(text, 16)
    # Accept strings like "n = 256", "q: 3329", "KYBER_N 256"
    m = re.search(r"[-+]?\d+", text)
    if m:
        try:
            return int(m.group(0))
        except Exception:
            return None
    return None


def collect_rich_agent2_outputs(run_dir: Path) -> JsonDict:
    """Load optional Agent 2 v2 files without breaking old runs.

    These files are extra; downstream agents must still work if they are absent.
    """
    files = {
        "selected_spec_excerpt": run_dir / "selected_spec_excerpt.txt",
        "sections_index": run_dir / "01_spec_sections_index.json",
        "algorithm_blocks": run_dir / "01_algorithm_blocks.json",
        "symbol_table": run_dir / "01_symbol_table.json",
        "parameter_table": run_dir / "01_parameter_table.json",
        "equations_constraints": run_dir / "01_equations_constraints.json",
        "preconditions_postconditions": run_dir / "01_preconditions_postconditions.json",
        "spec_to_code_hints": run_dir / "01_spec_to_code_hints.json",
    }
    out: JsonDict = {
        "available": {},
        "paths": {k: str(v) for k, v in files.items()},
        "selected_spec_excerpt": read_text_if_exists(files["selected_spec_excerpt"]),
        "sections_index": read_json_if_exists(files["sections_index"]),
        "algorithm_blocks": read_json_if_exists(files["algorithm_blocks"]),
        "symbol_table": read_json_if_exists(files["symbol_table"]),
        "parameter_table": read_json_if_exists(files["parameter_table"]),
        "equations_constraints": read_json_if_exists(files["equations_constraints"]),
        "preconditions_postconditions": read_json_if_exists(files["preconditions_postconditions"]),
        "spec_to_code_hints": read_json_if_exists(files["spec_to_code_hints"]),
    }
    for key, path in files.items():
        out["available"][key] = path.exists()
    out["any_available"] = any(out["available"].values())
    return out


def collect_agent4_v2_outputs(run_dir: Path) -> JsonDict:
    """Load optional Agent 4 v2 traceability files."""
    files = {
        "spec_code_traceability": run_dir / "03_spec_code_traceability.json",
        "agent2v2_integration_report": run_dir / "03_agent2v2_integration_report.json",
        "property_evidence_matrix_csv": run_dir / "03_property_evidence_matrix.csv",
    }
    out: JsonDict = {
        "available": {},
        "paths": {k: str(v) for k, v in files.items()},
        "spec_code_traceability": read_json_if_exists(files["spec_code_traceability"]),
        "agent2v2_integration_report": read_json_if_exists(files["agent2v2_integration_report"]),
    }
    for key, path in files.items():
        out["available"][key] = path.exists()
    out["any_available"] = any(out["available"].values())
    return out


def extract_rich_constants(spec_summary: JsonDict, rich_spec: JsonDict) -> JsonDict:
    """Collect constants from legacy spec summary and Agent 2 v2 outputs."""
    constants: JsonDict = {}

    legacy = spec_summary.get("constants") if isinstance(spec_summary.get("constants"), dict) else {}
    for key, value in legacy.items():
        if isinstance(value, dict) and "value" in value:
            constants[str(key)] = {
                "value": value.get("value"),
                "source": "01_spec_summary.json",
                "evidence": value.get("evidence"),
                "confidence": value.get("confidence", "legacy"),
            }
        else:
            constants[str(key)] = {
                "value": value,
                "source": "01_spec_summary.json",
                "confidence": "legacy",
            }

    # Parameter table may be list/dict depending on Agent 2 v2 parsing shape.
    param_data = rich_spec.get("parameter_table", {})
    candidates: List[Any] = []
    if isinstance(param_data, dict):
        for key in ("parameters", "rows", "items", "table", "constants"):
            candidates.extend(as_list(param_data.get(key)))
        # Also scan top-level mapping.
        for key, value in param_data.items():
            if key in {"parameters", "rows", "items", "table", "constants"}:
                continue
            if isinstance(value, (str, int, float, dict)):
                candidates.append({"name": key, "value": value})
    elif isinstance(param_data, list):
        candidates.extend(param_data)

    for item in candidates:
        if isinstance(item, dict):
            name = first_nonempty(item.get("name"), item.get("symbol"), item.get("parameter"), item.get("key"), default="")
            value = first_nonempty(item.get("value"), item.get("number"), item.get("default"), item.get("definition"), default=None)
            if name:
                constants[str(name)] = {
                    "value": value,
                    "source": "01_parameter_table.json",
                    "evidence": item.get("evidence") or item.get("source") or item.get("line"),
                    "confidence": item.get("confidence", "candidate"),
                }

    # Symbol table may include q/n definitions.
    sym_data = rich_spec.get("symbol_table", {})
    sym_items: List[Any] = []
    if isinstance(sym_data, dict):
        for key in ("symbols", "items", "table"):
            sym_items.extend(as_list(sym_data.get(key)))
        for key, value in sym_data.items():
            if key not in {"symbols", "items", "table"} and isinstance(value, (str, int, float, dict)):
                sym_items.append({"symbol": key, "definition": value})
    elif isinstance(sym_data, list):
        sym_items.extend(sym_data)
    for item in sym_items:
        if isinstance(item, dict):
            name = first_nonempty(item.get("symbol"), item.get("name"), item.get("key"), default="")
            value = first_nonempty(item.get("value"), item.get("number"), item.get("definition"), default=None)
            if name and name not in constants:
                constants[str(name)] = {
                    "value": value,
                    "source": "01_symbol_table.json",
                    "evidence": item.get("evidence") or item.get("source") or item.get("line"),
                    "confidence": item.get("confidence", "candidate"),
                }

    return constants


def constant_value(constants: JsonDict, names: Sequence[str]) -> Optional[Any]:
    lower_map = {str(k).lower(): v for k, v in constants.items()}
    for name in names:
        if name in constants:
            value = constants[name]
        elif name.lower() in lower_map:
            value = lower_map[name.lower()]
        else:
            continue
        if isinstance(value, dict) and "value" in value:
            return value.get("value")
        return value
    return None


def infer_loop_bound_from_rich_spec(
    config: JsonDict,
    spec_summary: JsonDict,
    properties: JsonDict,
    rich_spec: JsonDict,
    fallback: str,
) -> str:
    """Prefer explicit FIPS/Agent 2 v2 parameter/algorithm loop bounds when present."""
    settings = config.get("artifact_generation_settings", {}) if isinstance(config.get("artifact_generation_settings"), dict) else {}
    if settings.get("loop_bound"):
        return str(settings["loop_bound"])

    # Agent 4 v2 may already choose a CBMC plan.
    plan = properties.get("cbmc_property_plan") if isinstance(properties.get("cbmc_property_plan"), dict) else {}
    for key in ("unwind_guess", "loop_bound", "array_length", "n"):
        if plan.get(key):
            return str(plan[key])

    constants = extract_rich_constants(spec_summary, rich_spec)
    n_value = constant_value(constants, ["N", "n", "KYBER_N", "MLKEM_N", "MLK_N", "length"])
    parsed_n = parse_int_loose(n_value)
    if parsed_n is not None:
        return str(parsed_n)

    # Search algorithm blocks for loops like 0..255, 0 to n-1, i < n.
    alg_text = flatten_text(rich_spec.get("algorithm_blocks", ""))
    patterns = [
        r"\b(?:for|For)\s+\w+\s+(?:from|=)\s+0\s+(?:to|\.\.)\s*(\d+)",
        r"\b\w+\s*<\s*([A-Za-z_][A-Za-z0-9_]*|\d+)",
        r"\b0\s*[≤<=]+\s*\w+\s*<\s*([A-Za-z_][A-Za-z0-9_]*|\d+)",
    ]
    for pat in patterns:
        m = re.search(pat, alg_text)
        if not m:
            continue
        bound = m.group(1)
        if bound.isdigit():
            # "0 to 255" means 256 iterations.
            if "to" in m.group(0).lower() or ".." in m.group(0):
                return str(int(bound) + 1)
            return bound
        value = constant_value(constants, [bound])
        parsed = parse_int_loose(value)
        if parsed is not None:
            return str(parsed)
        return bound

    return fallback


def infer_modulus_from_rich_spec(spec_summary: JsonDict, rich_spec: JsonDict) -> Optional[str]:
    constants = extract_rich_constants(spec_summary, rich_spec)
    q_value = constant_value(constants, ["q", "Q", "KYBER_Q", "MLKEM_Q", "MLK_Q", "modulus"])
    if q_value is None:
        text = flatten_text(rich_spec.get("equations_constraints", "")) + " " + flatten_text(rich_spec.get("selected_spec_excerpt", ""))
        m = re.search(r"\bq\s*(?:=|is)\s*(\d+)", text, flags=re.I)
        if m:
            q_value = m.group(1)
    if q_value is None:
        return None
    parsed = parse_int_loose(q_value)
    return str(parsed) if parsed is not None else str(q_value)


def infer_algorithm_assignments(rich_spec: JsonDict) -> List[JsonDict]:
    """Extract candidate algorithm assignments from Agent 2 v2 algorithm blocks."""
    assignments: List[JsonDict] = []
    sources = [
        rich_spec.get("algorithm_blocks", {}),
        rich_spec.get("equations_constraints", {}),
        rich_spec.get("preconditions_postconditions", {}),
        rich_spec.get("selected_spec_excerpt", ""),
    ]

    def add_assignment(lhs: str, rhs: str, source: str, evidence: Any = None) -> None:
        lhs = normalize_text(lhs.replace("←", "").replace("<-", ""))
        rhs = normalize_text(rhs)
        if not lhs or not rhs:
            return
        key = (lhs, rhs)
        for existing in assignments:
            if (existing.get("lhs"), existing.get("rhs")) == key:
                return
        assignments.append({
            "lhs": lhs,
            "rhs": rhs,
            "source": source,
            "evidence": evidence,
            "status": "candidate_from_spec_algorithm",
            "human_review_required": True,
        })

    # Structured algorithm steps.
    alg = rich_spec.get("algorithm_blocks", {})
    blocks = []
    if isinstance(alg, dict):
        blocks.extend(as_list(alg.get("algorithm_blocks")))
        blocks.extend(as_list(alg.get("algorithms")))
        blocks.extend(as_list(alg.get("blocks")))
        if not blocks:
            blocks.append(alg)
    elif isinstance(alg, list):
        blocks.extend(alg)

    for block in blocks:
        if isinstance(block, dict):
            steps = []
            for key in ("steps", "body", "lines", "operations", "assignments"):
                steps.extend(as_list(block.get(key)))
            if not steps:
                steps = [block]
            for step in steps:
                text = item_text(step, keys=("text", "raw", "statement", "operation", "description"))
                # Match <-, ←, :=, =
                for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_\[\]\.\(\), ]*)\s*(?:←|<-|:=|=)\s*([^;\n]+)", text):
                    lhs, rhs = m.group(1), m.group(2)
                    if "==" not in lhs and rhs:
                        add_assignment(lhs, rhs, "01_algorithm_blocks.json", step)
        elif isinstance(block, str):
            for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_\[\]\.\(\), ]*)\s*(?:←|<-|:=|=)\s*([^;\n]+)", block):
                add_assignment(m.group(1), m.group(2), "01_algorithm_blocks.json", block)

    # Raw text fallback.
    for raw in sources:
        text = flatten_text(raw)
        for line in text.splitlines() if "\n" in text else re.split(r"\.|\;", text):
            if not any(sym in line for sym in ("←", "<-", ":=")):
                continue
            m = re.search(r"(.+?)\s*(?:←|<-|:=)\s*(.+)", line)
            if m:
                add_assignment(m.group(1), m.group(2), "rich_spec_text", line)

    return assignments[:20]


def infer_algorithm_io_contract(rich_spec: JsonDict) -> JsonDict:
    """Extract candidate inputs/outputs from Algorithm blocks."""
    contract: JsonDict = {"inputs": [], "outputs": [], "source": "agent2v2_rich_spec", "human_review_required": True}
    text = flatten_text(rich_spec.get("algorithm_blocks", "")) + "\n" + rich_spec.get("selected_spec_excerpt", "")
    for label, key in [("Input", "inputs"), ("Inputs", "inputs"), ("Output", "outputs"), ("Outputs", "outputs")]:
        for m in re.finditer(rf"\b{label}\s*:\s*([^\n]+)", text, flags=re.I):
            items = [normalize_text(x) for x in re.split(r",|;", m.group(1)) if normalize_text(x)]
            contract[key].extend(items)
    contract["inputs"] = unique_list(contract["inputs"])
    contract["outputs"] = unique_list(contract["outputs"])
    return contract


def build_spec_grounding_report(spec_summary: JsonDict, properties: JsonDict, rich_spec: JsonDict, agent4_context: JsonDict, loop_bound: str, modulus_q: Optional[str]) -> JsonDict:
    constants = extract_rich_constants(spec_summary, rich_spec)
    assignments = infer_algorithm_assignments(rich_spec)
    io_contract = infer_algorithm_io_contract(rich_spec)
    return {
        "schema_version": "2.0",
        "agent": "artifact_generation_agent_v2",
        "purpose": "Record how the generated harness is grounded in Agent 2 v2 FIPS-aware parsing and Agent 4 v2 property discovery.",
        "rich_spec_files_available": rich_spec.get("available", {}),
        "agent4_v2_files_available": agent4_context.get("available", {}),
        "constants_used_or_available": constants,
        "loop_bound_selected": loop_bound,
        "modulus_q_detected": modulus_q,
        "algorithm_io_contract": io_contract,
        "candidate_algorithm_assignments": assignments,
        "property_plan_summary": {
            "candidate_property_count": len(as_list(properties.get("candidate_properties"))),
            "selected_first_harness_property_ids": as_list(
                (properties.get("cbmc_property_plan") or {}).get("selected_first_harness_property_ids")
            ) if isinstance(properties.get("cbmc_property_plan"), dict) else [],
            "first_harness_selection_count": len(as_list(properties.get("first_harness_selection"))),
        },
        "safety_position": {
            "spec_facts_are_candidate_until_reviewed": True,
            "assumptions_must_be_checked_by_critic": True,
            "human_review_required": True,
            "no_full_mlkem_proof_claimed": True,
        },
    }


def build_assumption_traceability_rows(assumption_notes: Sequence[JsonDict], spec_grounding: JsonDict) -> List[JsonDict]:
    rows: List[JsonDict] = []
    constants = spec_grounding.get("constants_used_or_available", {})
    q = spec_grounding.get("modulus_q_detected")
    n = spec_grounding.get("loop_bound_selected")
    for idx, note in enumerate(assumption_notes, start=1):
        rows.append({
            "assumption_id": f"A{idx}",
            "kind": note.get("kind", ""),
            "target": note.get("target") or note.get("parameter") or note.get("passed_argument") or "",
            "inserted_into_harness": "yes" if note.get("kind") in {"coefficient_range_assumption"} else "no_or_structural",
            "basis": note.get("justification") or note.get("reason") or "",
            "q_context": q or "",
            "n_context": n or "",
            "human_review_required": note.get("human_review_required", True),
        })
    if not rows:
        rows.append({
            "assumption_id": "A0",
            "kind": "no_assumptions_recorded",
            "target": "",
            "inserted_into_harness": "no",
            "basis": "No explicit assumption notes were generated.",
            "q_context": q or "",
            "n_context": n or "",
            "human_review_required": True,
        })
    return rows


def build_spec_grounded_assertion_plan(assertion_notes: Sequence[JsonDict], spec_grounding: JsonDict, properties: JsonDict) -> JsonDict:
    return {
        "schema_version": "2.0",
        "agent": "artifact_generation_agent_v2",
        "assertions_inserted": list(assertion_notes),
        "candidate_algorithm_assignments": spec_grounding.get("candidate_algorithm_assignments", []),
        "selected_property_types": unique_list(
            str(p.get("type", "")) for p in selected_properties(properties) if isinstance(p, dict)
        ),
        "critic_agent_checks_required": [
            "Confirm each assertion follows the selected algorithm/spec section.",
            "Confirm loop bound and array length are correct.",
            "Confirm modulus/range assumptions are not invented.",
            "Confirm functional assertions are not vacuous and account for aliasing/narrowing.",
        ],
        "human_review_required": True,
    }


# ---------------------------------------------------------------------------
# C model extraction helpers
# ---------------------------------------------------------------------------

@dataclasses.dataclass
class CParameter:
    index: int
    raw: str
    name: str
    type_guess: str
    is_pointer: bool
    is_const: bool
    pointer_depth: int
    direction_guess: str

    @property
    def base_type(self) -> str:
        t = self.type_guess or self.raw
        # Remove common qualifiers and pointer symbols. Preserve struct/typedef name.
        t = re.sub(r"\b(const|volatile|restrict|static|register)\b", "", t)
        t = t.replace("*", " ")
        t = re.sub(r"\s+", " ", t).strip()
        return t or "int"

    @property
    def local_name(self) -> str:
        return safe_identifier(self.name, f"param_{self.index}")

    @property
    def call_expr(self) -> str:
        if self.is_pointer:
            return f"&{self.local_name}"
        return self.local_name


def parse_parameters_from_summary(code_summary: JsonDict) -> List[CParameter]:
    function = code_summary.get("function") if isinstance(code_summary.get("function"), dict) else {}
    raw_params = function.get("parameters") or code_summary.get("parameters") or []
    params: List[CParameter] = []
    if isinstance(raw_params, list):
        for idx, p in enumerate(raw_params):
            if not isinstance(p, dict):
                continue
            name = str(p.get("name") or "").strip()
            raw = str(p.get("raw") or "").strip()
            type_guess = str(p.get("type_guess") or raw.replace(name, "") or "int").strip()
            is_pointer = bool(p.get("is_pointer")) or "*" in raw or "*" in type_guess
            pointer_depth = int(p.get("pointer_depth") or (raw.count("*") + type_guess.count("*")) or (1 if is_pointer else 0))
            is_const = bool(p.get("is_const")) or bool(re.search(r"\bconst\b", raw + " " + type_guess))
            direction = str(p.get("direction_guess") or "").strip()
            if not name:
                m = re.search(r"([A-Za-z_][A-Za-z0-9_]*)\s*(?:\[[^\]]*\])?\s*$", raw)
                name = m.group(1) if m else f"param_{idx}"
            if not direction:
                direction = "input_pointer_candidate" if is_const else "output_or_inout_candidate"
            params.append(CParameter(idx, raw, name, type_guess, is_pointer, is_const, pointer_depth, direction))
    return params


def get_target_function(config: JsonDict, code_summary: JsonDict) -> str:
    function = code_summary.get("function") if isinstance(code_summary.get("function"), dict) else {}
    return str(first_nonempty(function.get("detected_name"), code_summary.get("target_function_detected"), code_summary.get("target_function"), config.get("target_function"), default="target_function"))


def get_function_signature(code_summary: JsonDict) -> str:
    function = code_summary.get("function") if isinstance(code_summary.get("function"), dict) else {}
    return str(first_nonempty(function.get("signature"), code_summary.get("function_signature"), default=""))


def get_function_body_excerpt(code_summary: JsonDict) -> str:
    function = code_summary.get("function") if isinstance(code_summary.get("function"), dict) else {}
    return str(first_nonempty(function.get("body_excerpt"), code_summary.get("body_excerpt"), default=""))


def collect_array_accesses(code_summary: JsonDict) -> List[JsonDict]:
    accesses = code_summary.get("array_accesses", [])
    if isinstance(accesses, list):
        return [a for a in accesses if isinstance(a, dict)]
    return []


def collect_loops(code_summary: JsonDict) -> List[JsonDict]:
    loops = code_summary.get("loop_structure", [])
    if isinstance(loops, list):
        return [l for l in loops if isinstance(l, dict)]
    return []


def infer_primary_loop_bound(config: JsonDict, spec_summary: JsonDict, code_summary: JsonDict) -> str:
    settings = config.get("artifact_generation_settings", {}) if isinstance(config.get("artifact_generation_settings"), dict) else {}
    if settings.get("loop_bound"):
        return str(settings["loop_bound"])

    cbmc = config.get("cbmc_settings", {}) if isinstance(config.get("cbmc_settings"), dict) else {}
    # Prefer symbolic bound from code loop condition.
    for loop in collect_loops(code_summary):
        condition = str(loop.get("condition") or "")
        m = re.search(r"[A-Za-z_][A-Za-z0-9_]*\s*<\s*([A-Za-z_][A-Za-z0-9_]*|\d+)", condition)
        if m:
            return m.group(1)
        raw = str(loop.get("raw") or "")
        m = re.search(r"[A-Za-z_][A-Za-z0-9_]*\s*<\s*([A-Za-z_][A-Za-z0-9_]*|\d+)", raw)
        if m:
            return m.group(1)
    constants = spec_summary.get("constants", {}) if isinstance(spec_summary.get("constants"), dict) else {}
    for key in ("N", "KYBER_N", "MLKEM_N"):
        if key in constants:
            if isinstance(constants[key], dict) and constants[key].get("value") is not None:
                return str(constants[key]["value"])
            return str(constants[key])
    if cbmc.get("unwind"):
        return str(cbmc["unwind"])
    return "256"


def infer_primary_loop_index(code_summary: JsonDict) -> str:
    for loop in collect_loops(code_summary):
        var = str(loop.get("loop_variable_guess") or "").strip()
        if var:
            return safe_identifier(var, "i")
        init = str(loop.get("init") or loop.get("raw") or "")
        m = re.search(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*=\s*0\b", init)
        if m:
            return m.group(1)
    for access in collect_array_accesses(code_summary):
        idx = str(access.get("index") or "").strip()
        if re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", idx):
            return idx
    return "i"


def object_field_from_base(base: str) -> Optional[Tuple[str, str]]:
    # Examples: r->coeffs -> (r, coeffs), a.coeffs -> (a, coeffs)
    base = base.strip()
    m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s*(?:->|\.)\s*([A-Za-z_][A-Za-z0-9_]*)$", base)
    if m:
        return m.group(1), m.group(2)
    return None


def collect_pointer_field_accesses(code_summary: JsonDict) -> List[Tuple[str, str, str, str]]:
    # returns (param/object name, field name, index expression, context)
    out: List[Tuple[str, str, str, str]] = []
    for access in collect_array_accesses(code_summary):
        base = str(access.get("base") or "").strip()
        idx = str(access.get("index") or "i").strip()
        context = str(access.get("access_context_guess") or "unknown")
        parsed = object_field_from_base(base)
        if parsed:
            out.append((parsed[0], parsed[1], idx, context))
    return out


def detect_field_element_type(header_texts: Sequence[str], struct_type: str, field_name: str) -> str:
    """Best-effort field type detector for declarations like int16_t coeffs[KYBER_N]."""
    combined = "\n".join(strip_c_comments(t) for t in header_texts)
    field_pat = re.compile(r"([A-Za-z_][A-Za-z0-9_]*(?:\s+[A-Za-z_][A-Za-z0-9_]*){0,3})\s+" + re.escape(field_name) + r"\s*\[[^\]]+\]\s*;")
    candidates = []
    for m in field_pat.finditer(combined):
        t = re.sub(r"\s+", " ", m.group(1)).strip()
        candidates.append(t)
    if candidates:
        # Prefer small integer types if present.
        for preferred in ("int16_t", "uint16_t", "int32_t", "uint32_t", "int", "unsigned int", "int64_t", "uint64_t"):
            if preferred in candidates:
                return preferred
        return candidates[0]
    # ML-KEM polynomial coefficient default. Kept as a candidate guess and recorded in manifest.
    if field_name == "coeffs":
        return "int16_t"
    return "int"


def c_type_to_nondet(type_name: str) -> Tuple[str, str]:
    t = re.sub(r"\b(const|volatile|restrict)\b", "", type_name or "int")
    t = re.sub(r"\s+", " ", t).strip()
    mapping = {
        "int8_t": "nondet_int8_t",
        "uint8_t": "nondet_uint8_t",
        "int16_t": "nondet_int16_t",
        "uint16_t": "nondet_uint16_t",
        "int32_t": "nondet_int32_t",
        "uint32_t": "nondet_uint32_t",
        "int64_t": "nondet_int64_t",
        "uint64_t": "nondet_uint64_t",
        "int": "nondet_int",
        "unsigned": "nondet_unsigned_int",
        "unsigned int": "nondet_unsigned_int",
        "size_t": "nondet_size_t",
        "char": "nondet_char",
        "unsigned char": "nondet_uchar",
        "bool": "nondet_bool",
    }
    fn = mapping.get(t, f"nondet_{safe_identifier(t)}")
    return t, fn


def detect_write_assignment(code_summary: JsonDict) -> Optional[Tuple[str, str]]:
    """Detect simple assignment 'lhs = rhs;' from code summary or body."""
    writes = code_summary.get("writes_or_assignments") or code_summary.get("assignments") or []
    if isinstance(writes, list):
        for item in writes:
            text = item_text(item)
            m = re.match(r"(.+?)\s*=\s*(.+?);?$", text)
            if m and "==" not in text:
                return normalize_text(m.group(1)), normalize_text(m.group(2).rstrip(";"))
    body = get_function_body_excerpt(code_summary)
    for line in body.splitlines():
        line = strip_c_comments(line).strip()
        if not line or line.startswith("for") or line.startswith("while") or "==" in line:
            continue
        m = re.match(r"(.+?)\s*=\s*(.+?);\s*$", line)
        if m:
            lhs = normalize_text(m.group(1))
            rhs = normalize_text(m.group(2))
            if lhs and rhs and not lhs.startswith(("unsigned ", "int ", "size_t ", "uint", "int")):
                return lhs, rhs
    return None


def pointer_arrow_to_dot(expr: str) -> str:
    return re.sub(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*->\s*", r"\1.", expr)


def has_property_type(properties: JsonDict, wanted: Sequence[str]) -> bool:
    wanted_set = set(wanted)
    for p in properties.get("candidate_properties", []) if isinstance(properties.get("candidate_properties"), list) else []:
        if isinstance(p, dict) and str(p.get("type") or "") in wanted_set:
            return True
    return False


def selected_properties(properties: JsonDict) -> List[JsonDict]:
    selected = properties.get("selected_first_harness_properties")
    if isinstance(selected, list) and selected:
        return [p for p in selected if isinstance(p, dict)]
    candidates = properties.get("candidate_properties", [])
    if isinstance(candidates, list):
        # Choose high priority + CBMC-compatible first.
        filtered = []
        for p in candidates:
            if not isinstance(p, dict):
                continue
            ptype = str(p.get("type") or "")
            priority = str(p.get("priority") or "").lower()
            if priority == "high" or ptype in {"pointer_validity", "input_pointer_validity", "output_pointer_validity", "memory_safety", "array_bounds", "loop_bound", "unwinding", "functional_update_shape", "functional_correctness"}:
                filtered.append(p)
        return filtered[:8]
    return []


# ---------------------------------------------------------------------------
# Artifact generation
# ---------------------------------------------------------------------------

@dataclasses.dataclass
class ArtifactGenerationResult:
    harness_c: str
    manifest: JsonDict
    markdown: str
    prompt: str


class ArtifactGenerationAgent:
    def __init__(self, config_path: Path, run_dir: Path, strict: bool = False):
        self.config_path = config_path.resolve()
        self.project_root = find_project_root(self.config_path)
        self.config = read_json(self.config_path)
        self.run_dir = run_dir.resolve()
        self.strict = strict
        self.events_path = self.run_dir / "events.jsonl"

        self.spec_summary_path = self.run_dir / "01_spec_summary.json"
        self.code_summary_path = self.run_dir / "02_code_summary.json"
        self.properties_path = self.run_dir / "03_candidate_properties.json"

        self.harness_path = self.run_dir / "04_generated_harness.c"
        self.manifest_path = self.run_dir / "04_artifact_manifest.json"
        self.markdown_path = self.run_dir / "04_generated_harness.md"
        self.spec_grounding_report_path = self.run_dir / "04_spec_grounding_report.json"
        self.assertion_plan_path = self.run_dir / "04_spec_grounded_assertion_plan.json"
        self.assumption_traceability_path = self.run_dir / "04_harness_assumption_traceability.csv"
        self.prompt_path = self.run_dir / "llm_prompts" / "04_artifact_generation_prompt.txt"
        self.status_path = self.run_dir / "agent_status" / "04_artifact_generation_status.json"

    def log_event(self, event_type: str, **payload: Any) -> None:
        append_jsonl(self.events_path, {
            "time": utc_now(),
            "agent": "artifact_generation_agent",
            "event_type": event_type,
            **payload,
        })

    def validate_inputs(self) -> None:
        missing = [str(p) for p in (self.spec_summary_path, self.code_summary_path, self.properties_path) if not p.exists()]
        if missing:
            raise FileNotFoundError(
                "Artifact Generation Agent requires previous agent outputs. Missing: " + ", ".join(missing)
            )

    def load_inputs(self) -> Tuple[JsonDict, JsonDict, JsonDict, List[str], List[Path], List[Path]]:
        spec_summary = read_json(self.spec_summary_path)
        code_summary = read_json(self.code_summary_path)
        properties = read_json(self.properties_path)

        source_file = resolve_path(self.project_root, self.config.get("source_file"), fallback=None)
        header_files = [resolve_path(self.project_root, str(p), fallback=None) for p in as_list(self.config.get("header_files"))]
        all_input_paths = [source_file, *header_files]
        missing_paths = [p for p in all_input_paths if not p.exists()]
        if missing_paths and self.strict:
            raise FileNotFoundError("Missing configured source/header files: " + ", ".join(str(p) for p in missing_paths))

        header_texts = [read_text_if_exists(p) for p in header_files]
        return spec_summary, code_summary, properties, header_texts, [source_file], header_files

    def generate(self) -> ArtifactGenerationResult:
        self.validate_inputs()
        self.log_event("started", run_dir=str(self.run_dir), config=str(self.config_path))
        spec_summary, code_summary, properties, header_texts, source_files, header_files = self.load_inputs()
        rich_spec = collect_rich_agent2_outputs(self.run_dir)
        agent4_context = collect_agent4_v2_outputs(self.run_dir)

        target_function = get_target_function(self.config, code_summary)
        harness_function = str(first_nonempty(
            (self.config.get("cbmc_settings") or {}).get("function") if isinstance(self.config.get("cbmc_settings"), dict) else None,
            f"harness_{target_function}",
            default=f"harness_{target_function}",
        ))
        harness_function = safe_identifier(harness_function, f"harness_{target_function}")
        artifact_type = str(first_nonempty(self.config.get("artifact_type"), default="CBMC harness"))
        verification_tool = str(first_nonempty(self.config.get("verification_tool"), default="CBMC"))

        if verification_tool.lower() != "cbmc" or "harness" not in artifact_type.lower():
            note = f"Configured tool/artifact is {verification_tool}/{artifact_type}; deterministic generator currently emits a CBMC harness candidate."
        else:
            note = "Configured for CBMC harness generation."
        if rich_spec.get("any_available"):
            note += " Agent 2 v2 FIPS-aware outputs were available and used for grounding where safe."
        if agent4_context.get("any_available"):
            note += " Agent 4 v2 traceability outputs were available and recorded."

        params = parse_parameters_from_summary(code_summary)
        if not params:
            raise ValueError("Could not find target function parameters in 02_code_summary.json; cannot safely generate harness.")

        loop_bound = infer_primary_loop_bound(self.config, spec_summary, code_summary)
        loop_bound = infer_loop_bound_from_rich_spec(self.config, spec_summary, properties, rich_spec, loop_bound)
        modulus_q = infer_modulus_from_rich_spec(spec_summary, rich_spec)
        algorithm_assignments = infer_algorithm_assignments(rich_spec)
        algorithm_io_contract = infer_algorithm_io_contract(rich_spec)
        field_accesses = collect_pointer_field_accesses(code_summary)
        loop_index = safe_identifier(infer_primary_loop_index(code_summary), "i")

        selected = selected_properties(properties)
        property_types = [str(p.get("type") or "") for p in selected]
        check_functional = any(t in {"functional_correctness", "functional_update_shape"} for t in property_types) or has_property_type(properties, ["functional_correctness", "functional_update_shape"])
        check_bounds = any(t in {"array_bounds", "memory_safety", "loop_bound", "unwinding"} for t in property_types) or True
        check_pointers = any("pointer" in t for t in property_types) or any(p.is_pointer for p in params)
        check_overflow = any(t == "integer_overflow" for t in property_types) or has_property_type(properties, ["integer_overflow"])

        function_signature = get_function_signature(code_summary)
        assignment = detect_write_assignment(code_summary)
        if assignment is None and algorithm_assignments:
            # Do not blindly convert FIPS pseudocode into C assertions unless mapping is obvious.
            # Store it in the assertion plan; Critic/Human can decide whether to enable it later.
            pass

        # Header include strategy
        base_settings = self.config.get("artifact_generation_settings", {}) if isinstance(self.config.get("artifact_generation_settings"), dict) else {}
        settings = dict(base_settings)
        # Store rich spec context for report and optional user-controlled assumption insertion.
        settings.setdefault("_rich_modulus_q", modulus_q)
        settings.setdefault("_rich_loop_bound", loop_bound)
        settings.setdefault("_algorithm_io_contract", algorithm_io_contract)
        settings.setdefault("_algorithm_assignments", algorithm_assignments)
        # Safety: do NOT create q-based coefficient assumptions automatically unless explicitly enabled.
        # q/n are used for comments, traceability, loop bounds, and review notes by default.
        include_strategy = str(settings.get("include_strategy") or "basename")
        include_lines = self.build_include_lines(header_files, include_strategy)

        declarations, init_lines, call_args, declared_nondets, field_types, assumption_notes = self.build_parameter_setup(
            params=params,
            header_texts=header_texts,
            field_accesses=field_accesses,
            loop_bound=loop_bound,
            loop_index=loop_index,
            settings=settings,
        )

        assertion_lines, assertion_notes = self.build_assertions(
            code_summary=code_summary,
            params=params,
            assignment=assignment,
            loop_bound=loop_bound,
            loop_index=loop_index,
            check_functional=check_functional,
            field_accesses=field_accesses,
            settings=settings,
        )

        cbmc_command = self.build_cbmc_command(source_files, header_files, harness_function, loop_bound, check_bounds, check_pointers, check_overflow)

        harness_c = self.render_harness(
            target_function=target_function,
            harness_function=harness_function,
            include_lines=include_lines,
            nondet_declarations=declared_nondets,
            local_declarations=declarations,
            init_lines=init_lines,
            call_args=call_args,
            assertion_lines=assertion_lines,
            function_signature=function_signature,
            note=note,
            selected_property_types=property_types,
            cbmc_command=cbmc_command,
        )

        if (
            target_function == "mlk_poly_add"
            and bool(settings.get("use_human_learned_mlk_poly_add_template", False))
        ):
            harness_c = self.render_mlk_poly_add_learned_harness(
                target_function=target_function,
                harness_function=harness_function,
                include_lines=include_lines,
                nondet_declarations=declared_nondets,
                function_signature=function_signature,
                note=note,
                selected_property_types=property_types,
                cbmc_command=cbmc_command,
            )
            assertion_notes.append({
                "kind": "human_learned_mlk_poly_add_template",
                "text": "Applied Run 002 learned harness pattern: old_r snapshot, no-overflow assumptions, and post-call coefficient-wise assertion.",
                "basis": "human-corrected successful CBMC Run 002",
                "human_review_required": True,
            })

        spec_grounding_report = build_spec_grounding_report(
            spec_summary=spec_summary,
            properties=properties,
            rich_spec=rich_spec,
            agent4_context=agent4_context,
            loop_bound=loop_bound,
            modulus_q=modulus_q,
        )
        assumption_traceability_rows = build_assumption_traceability_rows(assumption_notes, spec_grounding_report)
        spec_grounded_assertion_plan = build_spec_grounded_assertion_plan(assertion_notes, spec_grounding_report, properties)

        manifest: JsonDict = {
            "schema_version": "2.0",
            "agent": "artifact_generation_agent",
            "created_at": utc_now(),
            "target_scheme": self.config.get("target_scheme"),
            "target_function": target_function,
            "harness_function": harness_function,
            "verification_tool": verification_tool,
            "artifact_type": artifact_type,
            "artifact_file": str(self.harness_path),
            "input_files": {
                "spec_summary": str(self.spec_summary_path),
                "code_summary": str(self.code_summary_path),
                "candidate_properties": str(self.properties_path),
                "config": str(self.config_path),
                "source_files": [str(p) for p in source_files],
                "header_files": [str(p) for p in header_files],
            },
            "selected_properties_used": selected,
            "selected_property_types": unique_list(property_types),
            "agent2v2_rich_spec_files_available": rich_spec.get("available", {}),
            "agent4v2_traceability_files_available": agent4_context.get("available", {}),
            "spec_grounding_report": str(self.spec_grounding_report_path),
            "spec_grounded_assertion_plan": str(self.assertion_plan_path),
            "assumption_traceability_csv": str(self.assumption_traceability_path),
            "modulus_q_detected": modulus_q,
            "algorithm_io_contract_detected": algorithm_io_contract,
            "candidate_algorithm_assignments_detected": algorithm_assignments,
            "generation_strategy": "deterministic_template_backed_spec_grounded_cbmc_harness_v2",
            "loop_bound_used": loop_bound,
            "loop_index_used": loop_index,
            "parameters_used": [dataclasses.asdict(p) for p in params],
            "field_types_inferred": field_types,
            "detected_assignment_for_functional_assertion": {"lhs": assignment[0], "rhs": assignment[1]} if assignment else None,
            "candidate_assumptions_inserted": assumption_notes,
            "candidate_assertions_inserted": assertion_notes,
            "recommended_cbmc_command": cbmc_command,
            "scientific_guardrails": {
                "llm_outputs_are_candidates_only": True,
                "formal_tool_is_final_checker": True,
                "human_review_required": True,
                "do_not_claim_full_mlkem_proof": True,
                "critic_agent_must_review": True,
            },
            "known_limitations": self.known_limitations(params, assignment, settings, field_accesses),
            "next_required_agent": "review_critic_agent",
            "harness_sha256": hashlib.sha256(harness_c.encode("utf-8")).hexdigest(),
            "_spec_grounding_report_object": spec_grounding_report,
            "_assumption_traceability_rows": assumption_traceability_rows,
            "_spec_grounded_assertion_plan_object": spec_grounded_assertion_plan,
        }

        markdown = self.render_markdown(manifest, harness_c)
        prompt = self.render_prompt(spec_summary, code_summary, properties, target_function, harness_function)
        if rich_spec.get("any_available"):
            prompt += "\n\nAgent 2 v2 rich specification context was available and used by the deterministic generator.\n"
            prompt += json.dumps({
                "rich_spec_files_available": rich_spec.get("available", {}),
                "modulus_q_detected": modulus_q,
                "loop_bound_used": loop_bound,
                "algorithm_io_contract": algorithm_io_contract,
                "candidate_algorithm_assignments": algorithm_assignments[:5],
            }, indent=2, ensure_ascii=False)
        if agent4_context.get("any_available"):
            prompt += "\n\nAgent 4 v2 traceability context was available and recorded in the manifest.\n"
            prompt += json.dumps(agent4_context.get("available", {}), indent=2, ensure_ascii=False)

        return ArtifactGenerationResult(harness_c=harness_c, manifest=manifest, markdown=markdown, prompt=prompt)

    def build_include_lines(self, header_files: Sequence[Path], include_strategy: str) -> List[str]:
        lines = ["#include <assert.h>", "#include <stdint.h>", "#include <stddef.h>", "#include <stdbool.h>"]
        seen = set(lines)
        for path in header_files:
            if not path.name:
                continue
            if include_strategy == "relative_from_project":
                try:
                    inc = path.relative_to(self.project_root).as_posix()
                except ValueError:
                    inc = path.name
            else:
                inc = path.name
            line = f'#include "{inc}"'
            if line not in seen:
                seen.add(line)
                lines.append(line)
        return lines

    def build_parameter_setup(
        self,
        params: Sequence[CParameter],
        header_texts: Sequence[str],
        field_accesses: Sequence[Tuple[str, str, str, str]],
        loop_bound: str,
        loop_index: str,
        settings: JsonDict,
    ) -> Tuple[List[str], List[str], List[str], List[str], JsonDict, List[JsonDict]]:
        declarations: List[str] = []
        init_lines: List[str] = []
        call_args: List[str] = []
        nondet_decls: Dict[str, str] = {}
        field_types: JsonDict = {}
        assumption_notes: List[JsonDict] = []

        field_by_object: Dict[str, List[Tuple[str, str]]] = {}
        for obj, field, idx, context in field_accesses:
            field_by_object.setdefault(obj, []).append((field, context))

        # Optional user-provided range assumptions. Example:
        # "artifact_generation_settings": {
        #   "coefficient_assumptions": {
        #     "a.coeffs": {"min": 0, "max": "KYBER_Q - 1", "justification": "..."}
        #   }
        # }
        coefficient_assumptions = settings.get("coefficient_assumptions", {}) if isinstance(settings.get("coefficient_assumptions"), dict) else {}

        for p in params:
            local = p.local_name
            if p.is_pointer:
                declarations.append(f"  {p.base_type} {local};")
                call_args.append(f"&{local}")
            else:
                clean_type, nondet_fn = c_type_to_nondet(p.base_type)
                declarations.append(f"  {clean_type} {local} = {nondet_fn}();")
                nondet_decls[nondet_fn] = f"extern {clean_type} {nondet_fn}(void);"
                call_args.append(local)

        # Initialize fields for input pointer candidates. Avoid writing to output-only fields before call unless explicitly needed.
        for p in params:
            if not p.is_pointer:
                continue
            local = p.local_name
            is_likely_input = p.is_const or "input" in p.direction_guess.lower()
            fields = field_by_object.get(p.name, []) + field_by_object.get(local, [])
            fields_unique = []
            seen_fields: set[str] = set()
            for field, context in fields:
                if field in seen_fields:
                    continue
                seen_fields.add(field)
                fields_unique.append((field, context))
            if not fields_unique:
                continue

            for field, context in fields_unique:
                element_type = detect_field_element_type(header_texts, p.base_type, field)
                field_types[f"{local}.{field}"] = {
                    "element_type_guess": element_type,
                    "basis": "header_field_detection_or_mlkem_coeffs_default",
                    "source_parameter": p.name,
                    "context_guess": context,
                }
                clean_type, nondet_fn = c_type_to_nondet(element_type)
                nondet_decls[nondet_fn] = f"extern {clean_type} {nondet_fn}(void);"
                if is_likely_input:
                    q_context = settings.get("_rich_modulus_q")
                    init_lines.append(f"  /* Initialize input field {local}.{field} with nondeterministic values. */")
                    if q_context:
                        init_lines.append(f"  /* Spec context: detected modulus q = {q_context}. No q-based range assumption is inserted unless explicitly configured. */")
                    init_lines.append(f"  for (unsigned int {loop_index} = 0; {loop_index} < {loop_bound}; {loop_index}++) {{")
                    init_lines.append(f"    {local}.{field}[{loop_index}] = {nondet_fn}();")
                    key1 = f"{local}.{field}"
                    key2 = f"{p.name}.{field}"
                    assumption = coefficient_assumptions.get(key1) or coefficient_assumptions.get(key2)
                    if isinstance(assumption, dict) and ("min" in assumption or "max" in assumption):
                        min_v = assumption.get("min")
                        max_v = assumption.get("max")
                        if min_v is not None:
                            init_lines.append(f"    __CPROVER_assume({local}.{field}[{loop_index}] >= ({min_v}));")
                        if max_v is not None:
                            init_lines.append(f"    __CPROVER_assume({local}.{field}[{loop_index}] <= ({max_v}));")
                        assumption_notes.append({
                            "kind": "coefficient_range_assumption",
                            "target": key1,
                            "min": min_v,
                            "max": max_v,
                            "justification": assumption.get("justification", "Provided in artifact_generation_settings; Critic Agent must verify it is supported."),
                            "human_review_required": True,
                        })
                    else:
                        assumption_notes.append({
                            "kind": "no_default_coefficient_range_assumption",
                            "target": key1,
                            "reason": "No coefficient range was inserted because q or N alone does not safely justify value bounds.",
                            "spec_modulus_q_context": settings.get("_rich_modulus_q"),
                            "spec_loop_bound_context": settings.get("_rich_loop_bound"),
                            "human_review_required": True,
                        })
                    init_lines.append("  }")
                    init_lines.append("")
                else:
                    assumption_notes.append({
                        "kind": "valid_output_object_by_local_allocation",
                        "target": local,
                        "reason": "Harness declares a local object and passes its address, giving CBMC a valid output object candidate.",
                        "human_review_required": True,
                    })

        # Ensure pointer validity note for local objects.
        for p in params:
            if p.is_pointer:
                assumption_notes.append({
                    "kind": "pointer_validity_by_local_object",
                    "parameter": p.name,
                    "passed_argument": f"&{p.local_name}",
                    "reason": "The harness passes the address of a stack/local object instead of an unconstrained raw pointer.",
                    "human_review_required": True,
                })

        return declarations, init_lines, call_args, list(nondet_decls.values()), field_types, assumption_notes

    def build_assertions(
        self,
        code_summary: JsonDict,
        params: Sequence[CParameter],
        assignment: Optional[Tuple[str, str]],
        loop_bound: str,
        loop_index: str,
        check_functional: bool,
        field_accesses: Sequence[Tuple[str, str, str, str]],
        settings: JsonDict,
    ) -> Tuple[List[str], List[JsonDict]]:
        lines: List[str] = []
        notes: List[JsonDict] = []

        lines.append("  /* CBMC built-in checks should cover pointer/bounds/overflow according to command flags. */")
        notes.append({
            "kind": "cbmc_builtin_checks",
            "text": "Bounds, pointer, and overflow checks are primarily requested through CBMC command-line flags.",
            "human_review_required": True,
        })
        algorithm_assignments = as_list(settings.get("_algorithm_assignments"))
        if algorithm_assignments:
            lines.append("  /* Candidate spec algorithm assignment(s) were parsed by Agent 2 v2. */")
            lines.append("  /* They are recorded in 04_spec_grounded_assertion_plan.json; this harness only inserts assertions when mapping is safe. */")
            for spec_step in algorithm_assignments[:3]:
                if isinstance(spec_step, dict):
                    lhs = str(spec_step.get("lhs", "")).replace("*/", "")
                    rhs = str(spec_step.get("rhs", "")).replace("*/", "")
                    lines.append(f"  /* Spec candidate: {lhs} := {rhs} */")
            notes.append({
                "kind": "spec_algorithm_assignment_reference",
                "text": "Agent 2 v2 parsed algorithm assignment(s); recorded for Critic/Human review before converting into strong assertions.",
                "count": len(algorithm_assignments),
                "human_review_required": True,
            })

        if check_functional and assignment:
            lhs, rhs = assignment
            lhs_dot = pointer_arrow_to_dot(lhs)
            rhs_dot = pointer_arrow_to_dot(rhs)
            # Replace detected loop index with harness loop index if needed.
            lhs_dot = re.sub(r"\[[A-Za-z_][A-Za-z0-9_]*\]", f"[{loop_index}]", lhs_dot)
            rhs_dot = re.sub(r"\[[A-Za-z_][A-Za-z0-9_]*\]", f"[{loop_index}]", rhs_dot)
            use_cast = bool(settings.get("functional_assertion_use_assignment_cast", True))

            lhs_obj_field = None
            m = re.match(r"([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\[", lhs_dot)
            if m:
                lhs_obj_field = f"{m.group(1)}.{m.group(2)}"

            lines.append("  /* Candidate functional-shape assertion derived from the implementation assignment. */")
            lines.append(f"  for (unsigned int {loop_index} = 0; {loop_index} < {loop_bound}; {loop_index}++) {{")
            if use_cast and lhs_obj_field:
                # Use typeof when available? CBMC supports GCC extensions often, but keep C99-ish by avoiding typeof.
                # We do not know field type at this point. Avoid unsupported cast; assert direct relation.
                lines.append(f"    assert({lhs_dot} == ({rhs_dot}));")
                notes.append({
                    "kind": "functional_assertion",
                    "text": f"assert({lhs_dot} == ({rhs_dot}))",
                    "basis": "detected implementation assignment",
                    "warning": "If target storage type narrows the RHS, Critic Agent may need to revise this assertion or add justified range assumptions.",
                    "human_review_required": True,
                })
            else:
                lines.append(f"    assert({lhs_dot} == ({rhs_dot}));")
                notes.append({
                    "kind": "functional_assertion",
                    "text": f"assert({lhs_dot} == ({rhs_dot}))",
                    "basis": "detected implementation assignment",
                    "human_review_required": True,
                })
            lines.append("  }")
        elif check_functional and not assignment:
            lines.append("  /* No simple implementation assignment was detected, so no functional assertion was inserted automatically. */")
            notes.append({
                "kind": "functional_assertion_deferred",
                "reason": "No simple lhs = rhs assignment was detected from code summary.",
                "human_review_required": True,
            })

        # Optional range assertions if user provided explicit settings.
        range_assertions = settings.get("range_assertions", {}) if isinstance(settings.get("range_assertions"), dict) else {}
        for target, spec in range_assertions.items():
            if not isinstance(spec, dict):
                continue
            min_v = spec.get("min")
            max_v = spec.get("max")
            expr = str(target)
            lines.append(f"  /* Candidate range assertion for {expr}; Critic Agent must check justification. */")
            lines.append(f"  for (unsigned int {loop_index} = 0; {loop_index} < {loop_bound}; {loop_index}++) {{")
            indexed = expr if "[" in expr else f"{expr}[{loop_index}]"
            if min_v is not None:
                lines.append(f"    assert({indexed} >= ({min_v}));")
            if max_v is not None:
                lines.append(f"    assert({indexed} <= ({max_v}));")
            lines.append("  }")
            notes.append({
                "kind": "range_assertion",
                "target": expr,
                "min": min_v,
                "max": max_v,
                "justification": spec.get("justification", "Provided in artifact_generation_settings; Critic Agent must verify."),
                "human_review_required": True,
            })

        return lines, notes

    def build_cbmc_command(
        self,
        source_files: Sequence[Path],
        header_files: Sequence[Path],
        harness_function: str,
        loop_bound: str,
        check_bounds: bool,
        check_pointers: bool,
        check_overflow: bool,
    ) -> str:
        cbmc = self.config.get("cbmc_settings", {}) if isinstance(self.config.get("cbmc_settings"), dict) else {}
        pieces = ["cbmc", str(self.harness_path)]
        pieces.extend(str(p) for p in source_files if p.exists())

        include_dirs = []
        for h in header_files:
            if h.parent.exists():
                include_dirs.append(h.parent)
        for d in sorted(set(include_dirs)):
            pieces.append(f"-I {d}")

        pieces.extend(["--function", harness_function])
        if cbmc.get("bounds_check", check_bounds):
            pieces.append("--bounds-check")
        if cbmc.get("pointer_check", check_pointers):
            pieces.append("--pointer-check")
        if cbmc.get("signed_overflow_check", check_overflow):
            pieces.append("--signed-overflow-check")
        if cbmc.get("unsigned_overflow_check", check_overflow):
            pieces.append("--unsigned-overflow-check")
        unwind = cbmc.get("unwind") or loop_bound
        if unwind:
            pieces.extend(["--unwind", str(unwind)])
        if cbmc.get("unwinding_assertions", True):
            pieces.append("--unwinding-assertions")
        return " ".join(pieces)


    def render_mlk_poly_add_learned_harness(
        self,
        target_function: str,
        harness_function: str,
        include_lines: Sequence[str],
        nondet_declarations: Sequence[str],
        function_signature: str,
        note: str,
        selected_property_types: Sequence[str],
        cbmc_command: str,
    ) -> str:
        """
        Human-learned template for mlk_poly_add.

        This template is based on the successful human-corrected Run 002
        harness. It avoids the earlier weak assertion pattern that compared
        the final r value against final r + b. Instead, it snapshots old r,
        assumes the documented no-overflow precondition, then checks the
        in-place coefficient-wise postcondition.
        """
        includes = list(include_lines)
        if "#include <limits.h>" not in includes:
            includes.append("#include <limits.h>")

        nondets = list(nondet_declarations)
        if not any("nondet_int16_t" in d for d in nondets):
            nondets.append("extern int16_t nondet_int16_t(void);")

        header = f"""/*
 * Generated by Agent 5: Formal Artifact Generation Agent
 * Artifact: candidate CBMC harness
 * Target function: {target_function}
 * Harness function: {harness_function}
 *
 * SCIENTIFIC GUARDRAIL:
 * This file is a candidate formal-verification artifact only.
 * It does not prove ML-KEM and it must be reviewed by the Critic Agent,
 * checked by CBMC, and inspected by the human researcher.
 *
 * Human-learned template:
 * This mlk_poly_add harness shape was derived from the corrected Run 002
 * experiment. It snapshots old r, applies the documented no-overflow
 * precondition, calls mlk_poly_add(&r, &b), and checks the coefficient-wise
 * in-place update property.
 *
 * Generation note: {note}
 * Selected candidate property types: {', '.join(unique_list(selected_property_types)) or 'not explicitly selected'}
 *
 * Recommended CBMC command saved in 04_artifact_manifest.json:
 * {cbmc_command}
 */
"""
        parts: List[str] = [header]
        parts.extend(includes)
        parts.append("")
        parts.append("#ifndef __CPROVER__")
        parts.append("#define __CPROVER_assume(cond) ((void)0)")
        parts.append("#endif")
        parts.append("")
        if function_signature:
            parts.append(f"/* Target signature observed by Code Understanding Agent: {function_signature} */")
        parts.append("/* Nondeterministic input functions for CBMC. */")
        parts.extend(nondets)
        parts.append("")
        parts.append(f"void {harness_function}(void)")
        parts.append("{")
        parts.append("  mlk_poly r;")
        parts.append("  mlk_poly b;")
        parts.append("  int16_t old_r_coeffs[MLKEM_N];")
        parts.append("")
        parts.append("  /* Initialize both in-place input r and input b, then snapshot old r. */")
        parts.append("  for (unsigned int i = 0; i < MLKEM_N; i++)")
        parts.append("  {")
        parts.append("    r.coeffs[i] = nondet_int16_t();")
        parts.append("    b.coeffs[i] = nondet_int16_t();")
        parts.append("")
        parts.append("    /* Documented precondition from poly.h: coefficient addition must not overflow int16_t. */")
        parts.append("    __CPROVER_assume((int32_t)r.coeffs[i] + (int32_t)b.coeffs[i] <= INT16_MAX);")
        parts.append("    __CPROVER_assume((int32_t)r.coeffs[i] + (int32_t)b.coeffs[i] >= INT16_MIN);")
        parts.append("")
        parts.append("    old_r_coeffs[i] = r.coeffs[i];")
        parts.append("  }")
        parts.append("")
        parts.append("  mlk_poly_add(&r, &b);")
        parts.append("")
        parts.append("  /* Check selected local in-place coefficient-wise update property. */")
        parts.append("  for (unsigned int i = 0; i < MLKEM_N; i++)")
        parts.append("  {")
        parts.append("    assert(r.coeffs[i] ==")
        parts.append("           (int16_t)((int32_t)old_r_coeffs[i] + (int32_t)b.coeffs[i]));")
        parts.append("  }")
        parts.append("}")
        parts.append("")
        return "\n".join(parts)

    def render_harness(
        self,
        target_function: str,
        harness_function: str,
        include_lines: Sequence[str],
        nondet_declarations: Sequence[str],
        local_declarations: Sequence[str],
        init_lines: Sequence[str],
        call_args: Sequence[str],
        assertion_lines: Sequence[str],
        function_signature: str,
        note: str,
        selected_property_types: Sequence[str],
        cbmc_command: str,
    ) -> str:
        args = ", ".join(call_args)
        header = f"""/*
 * Generated by Agent 5: Formal Artifact Generation Agent
 * Artifact: candidate CBMC harness
 * Target function: {target_function}
 * Harness function: {harness_function}
 *
 * SCIENTIFIC GUARDRAIL:
 * This file is a candidate formal-verification artifact only.
 * It does not prove ML-KEM and it must be reviewed by the Critic Agent,
 * checked by CBMC, and inspected by the human researcher.
 *
 * Generation note: {note}
 * Selected candidate property types: {', '.join(unique_list(selected_property_types)) or 'not explicitly selected'}
 *
 * This v2 generator may use Agent 2 v2 parsed FIPS algorithms, parameters,
 * symbols, loop bounds, and constraints where available. Those extracted facts
 * are still candidate verification inputs and must be reviewed.
 *
 * Recommended CBMC command saved in 04_artifact_manifest.json:
 * {cbmc_command}
 */
"""
        parts: List[str] = [header]
        parts.extend(include_lines)
        parts.append("")
        parts.append("#ifndef __CPROVER__")
        parts.append("#define __CPROVER_assume(cond) ((void)0)")
        parts.append("#endif")
        parts.append("")
        if function_signature:
            parts.append(f"/* Target signature observed by Code Understanding Agent: {function_signature} */")
        parts.append("/* Nondeterministic input functions for CBMC. */")
        for decl in nondet_declarations:
            parts.append(decl)
        if not nondet_declarations:
            parts.append("/* No scalar nondeterministic declarations were needed for the detected harness shape. */")
        parts.append("")
        parts.append(f"void {harness_function}(void) {{")
        if local_declarations:
            parts.append("  /* Local objects give pointer parameters valid objects for CBMC analysis. */")
            parts.extend(local_declarations)
        else:
            parts.append("  /* No local declarations generated. Critic Agent should inspect this. */")
        parts.append("")
        if init_lines:
            parts.extend(init_lines)
        else:
            parts.append("  /* No automatic input field initialization was generated. */")
            parts.append("")
        parts.append("  /* Call the selected implementation function. */")
        parts.append(f"  {target_function}({args});")
        parts.append("")
        if assertion_lines:
            parts.extend(assertion_lines)
        else:
            parts.append("  /* No explicit assertions generated. Use CBMC built-in safety checks only. */")
        parts.append("}")
        parts.append("")
        return "\n".join(parts)

    def render_markdown(self, manifest: JsonDict, harness_c: str) -> str:
        props = manifest.get("selected_property_types") or []
        limitations = manifest.get("known_limitations") or []
        assumptions = manifest.get("candidate_assumptions_inserted") or []
        assertions = manifest.get("candidate_assertions_inserted") or []
        lines = [
            "# 04 Generated Formal Artifact",
            "",
            f"**Agent:** {manifest.get('agent')}",
            f"**Target function:** `{manifest.get('target_function')}`",
            f"**Harness function:** `{manifest.get('harness_function')}`",
            f"**Artifact file:** `{manifest.get('artifact_file')}`",
            "",
            "## Scientific guardrail",
            "",
            "This is a candidate artifact. It must be reviewed by the Critic Agent, checked by CBMC, and inspected by the human researcher. It is not a proof of ML-KEM.",
            "",
            "## Selected property types",
            "",
        ]
        if props:
            for p in props:
                lines.append(f"- `{p}`")
        else:
            lines.append("- No explicit property types were selected; harness may rely mainly on CBMC built-in checks.")
        lines.extend(["", "## Candidate assumptions inserted", ""])
        for a in assumptions[:20]:
            lines.append(f"- **{a.get('kind', 'assumption')}**: {a.get('reason') or a.get('justification') or a.get('target') or a.get('text')}")
        if not assumptions:
            lines.append("- None recorded.")
        lines.extend(["", "## Candidate assertions/checks inserted", ""])
        for a in assertions[:20]:
            lines.append(f"- **{a.get('kind', 'assertion')}**: {a.get('text') or a.get('reason')}")
        if not assertions:
            lines.append("- None recorded.")
        lines.extend(["", "## Spec grounding outputs", ""])
        lines.append(f"- Spec grounding report: `{manifest.get('spec_grounding_report')}`")
        lines.append(f"- Spec-grounded assertion plan: `{manifest.get('spec_grounded_assertion_plan')}`")
        lines.append(f"- Assumption traceability CSV: `{manifest.get('assumption_traceability_csv')}`")
        if manifest.get("modulus_q_detected"):
            lines.append(f"- Detected modulus q: `{manifest.get('modulus_q_detected')}`")
        if manifest.get("candidate_algorithm_assignments_detected"):
            lines.append(f"- Candidate algorithm assignments detected: `{len(manifest.get('candidate_algorithm_assignments_detected') or [])}`")
        lines.extend(["", "## Recommended CBMC command", "", "```bash", str(manifest.get("recommended_cbmc_command") or ""), "```", ""])
        lines.extend(["## Known limitations", ""])
        for lim in limitations:
            lines.append(f"- {lim}")
        if not limitations:
            lines.append("- None recorded.")
        lines.extend(["", "## Generated harness preview", "", "```c", harness_c, "```", ""])
        return "\n".join(lines)

    def render_prompt(self, spec_summary: JsonDict, code_summary: JsonDict, properties: JsonDict, target_function: str, harness_function: str) -> str:
        # This is saved for reproducibility and future LLM integration, even though the current generator is deterministic.
        brief_spec = json.dumps({
            "target_function": spec_summary.get("target_function"),
            "constants": spec_summary.get("constants"),
            "input_assumptions": spec_summary.get("input_assumptions"),
            "candidate_output_guarantees": spec_summary.get("candidate_output_guarantees"),
            "uncertainties": spec_summary.get("uncertainties"),
        }, indent=2, ensure_ascii=False)[:6000]
        brief_code = json.dumps({
            "function": code_summary.get("function"),
            "inputs": code_summary.get("inputs"),
            "outputs_or_inouts": code_summary.get("outputs_or_inouts"),
            "loop_structure": code_summary.get("loop_structure"),
            "array_accesses": code_summary.get("array_accesses"),
            "implementation_risks": code_summary.get("implementation_risks"),
            "uncertainties": code_summary.get("uncertainties"),
        }, indent=2, ensure_ascii=False)[:8000]
        brief_props = json.dumps({
            "candidate_properties": properties.get("candidate_properties"),
            "assumption_bank": properties.get("assumption_bank"),
            "cbmc_property_plan": properties.get("cbmc_property_plan"),
        }, indent=2, ensure_ascii=False)[:8000]
        return f"""You are generating a CBMC harness for formal-verification artifact research.

Scientific rules:
1. Generate candidate artifacts only.
2. Do not claim proof of ML-KEM.
3. Do not invent unsupported assumptions.
4. Every assumption must be reviewable.
5. The Critic Agent, CBMC, and human researcher remain final authorities.

Target function: {target_function}
Harness function: {harness_function}

Specification summary:
{brief_spec}

Code summary:
{brief_code}

Candidate properties:
{brief_props}

Task:
Generate a CBMC harness that creates valid local objects for pointer parameters, initializes nondeterministic inputs, calls the target function, uses CBMC built-in checks, adds only justified/simple assertions, and documents limitations.
"""

    def known_limitations(
        self,
        params: Sequence[CParameter],
        assignment: Optional[Tuple[str, str]],
        settings: JsonDict,
        field_accesses: Sequence[Tuple[str, str, str, str]],
    ) -> List[str]:
        limitations: List[str] = []
        if not assignment:
            limitations.append("No simple implementation assignment was detected, so functional correctness assertions may be deferred.")
        if not field_accesses:
            limitations.append("No object-field array accesses were detected, so automatic field initialization may be incomplete.")
        if not settings.get("coefficient_assumptions"):
            limitations.append("No default coefficient range assumptions were inserted; this avoids unsupported assumptions but may make overflow/range properties fail.")
        if any(p.pointer_depth > 1 for p in params):
            limitations.append("One or more parameters have pointer depth greater than 1; generated local-object setup may need manual review.")
        if any(not p.is_pointer for p in params):
            limitations.append("Scalar parameters are initialized with nondeterministic values but may need explicit assumptions.")
        limitations.append("Generated include paths may need adjustment depending on where CBMC is executed from.")
        limitations.append("The Critic Agent must check whether assertions are meaningful, non-vacuous, and connected to the selected specification.")
        return limitations

    def write_outputs(self, result: ArtifactGenerationResult) -> None:
        # Pull internal report objects out of manifest before writing the public manifest.
        manifest_to_write = dict(result.manifest)
        spec_grounding_report = manifest_to_write.pop("_spec_grounding_report_object", {})
        assumption_traceability_rows = manifest_to_write.pop("_assumption_traceability_rows", [])
        spec_grounded_assertion_plan = manifest_to_write.pop("_spec_grounded_assertion_plan_object", {})

        write_text(self.harness_path, result.harness_c)
        write_json(self.manifest_path, manifest_to_write)
        write_json(self.spec_grounding_report_path, spec_grounding_report)
        write_json(self.assertion_plan_path, spec_grounded_assertion_plan)
        write_csv(
            self.assumption_traceability_path,
            assumption_traceability_rows,
            fieldnames=["assumption_id", "kind", "target", "inserted_into_harness", "basis", "q_context", "n_context", "human_review_required"],
        )
        write_text(self.markdown_path, result.markdown)
        write_text(self.prompt_path, result.prompt)
        result.manifest = manifest_to_write
        status = {
            "agent": "artifact_generation_agent",
            "status": "ok",
            "created_at": utc_now(),
            "outputs": {
                "harness": str(self.harness_path),
                "manifest": str(self.manifest_path),
                "markdown": str(self.markdown_path),
                "spec_grounding_report": str(self.spec_grounding_report_path),
                "spec_grounded_assertion_plan": str(self.assertion_plan_path),
                "assumption_traceability_csv": str(self.assumption_traceability_path),
                "prompt": str(self.prompt_path),
            },
            "target_function": result.manifest.get("target_function"),
            "harness_function": result.manifest.get("harness_function"),
            "next_required_agent": "review_critic_agent",
            "human_review_required": True,
        }
        write_json(self.status_path, status)
        self.log_event("finished", status="ok", outputs=status["outputs"])

    def run(self) -> int:
        try:
            result = self.generate()
            self.write_outputs(result)
            print(f"[OK] Formal Artifact Generation Agent wrote: {self.harness_path}")
            print(f"[OK] Artifact manifest: {self.manifest_path}")
            print("[NOTE] Generated harness is a candidate artifact; Critic Agent, CBMC, and human review are still required.")
            return 0
        except Exception as exc:  # pragma: no cover - CLI safety path
            self.run_dir.mkdir(parents=True, exist_ok=True)
            error_status = {
                "agent": "artifact_generation_agent",
                "status": "failed",
                "time": utc_now(),
                "error_type": type(exc).__name__,
                "error": str(exc),
                "traceback": traceback.format_exc(),
                "human_review_required": True,
            }
            write_json(self.status_path, error_status)
            self.log_event("failed", error_type=type(exc).__name__, error=str(exc))
            print(f"[ERROR] Formal Artifact Generation Agent failed: {exc}", file=sys.stderr)
            print(f"[INFO] Status file: {self.status_path}", file=sys.stderr)
            return 1


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Agent 5 v2: Spec-grounded Formal Artifact Generation Agent")
    parser.add_argument("--config", required=True, help="Path to run config JSON, e.g. configs/poly_add_run.json")
    parser.add_argument("--run-dir", required=True, help="Path to current run directory, e.g. runs/run_001_poly_add")
    parser.add_argument("--strict", action="store_true", help="Fail if configured source/header files are missing")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    agent = ArtifactGenerationAgent(config_path=Path(args.config), run_dir=Path(args.run_dir), strict=bool(args.strict))
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
