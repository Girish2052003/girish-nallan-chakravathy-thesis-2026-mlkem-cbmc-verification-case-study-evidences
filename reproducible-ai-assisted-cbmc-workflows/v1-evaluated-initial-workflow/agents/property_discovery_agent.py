#!/usr/bin/env python3
"""
Agent 4: Property Discovery Agent v2
====================================

Backward-compatible FIPS-aware upgrade.

This agent still reads the legacy inputs:
  - 01_spec_summary.json
  - 02_code_summary.json

and still produces the legacy outputs expected by Agent 5:
  - 03_candidate_properties.json
  - 03_candidate_properties.md
  - llm_prompts/03_property_discovery_prompt.txt
  - agent_status/03_property_discovery_status.json

New optional Agent 2 v2 inputs are also read when present:
  - selected_spec_excerpt.txt
  - 01_spec_sections_index.json
  - 01_algorithm_blocks.json
  - 01_symbol_table.json
  - 01_parameter_table.json
  - 01_equations_constraints.json
  - 01_preconditions_postconditions.json
  - 01_spec_to_code_hints.json

New v2 outputs:
  - 03_property_evidence_matrix.csv
  - 03_spec_code_traceability.json
  - 03_agent2v2_integration_report.json

Scientific guardrail:
This agent only proposes candidate properties. CBMC/formal tools and human review remain
final authority. No full ML-KEM proof is claimed.
"""

from __future__ import annotations

import argparse
import csv
import dataclasses
import datetime as _dt
import hashlib
import json
import re
import sys
import traceback
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

JsonDict = Dict[str, Any]
AGENT_VERSION = "2.0-fips-aware"


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


def read_json(path: Path) -> JsonDict:
    with path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected JSON object in {path}, got {type(data).__name__}")
    return data


def read_json_optional(path: Path, default: Any = None) -> Any:
    if default is None:
        default = {}
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except Exception as exc:
        return {"_load_error": True, "path": str(path), "error": str(exc)}


def read_text_optional(path: Path) -> str:
    if not path.exists():
        return ""
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return ""


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    tmp.replace(path)


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


def write_csv(path: Path, rows: List[JsonDict], fieldnames: List[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: csv_value(row.get(k, "")) for k in fieldnames})


def csv_value(v: Any) -> str:
    if isinstance(v, (dict, list)):
        return json.dumps(v, ensure_ascii=False)
    return "" if v is None else str(v)


def append_jsonl(path: Path, data: JsonDict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(data, ensure_ascii=False) + "\n")


def sha256_short(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8", errors="replace")).hexdigest()[:16]


def sha256_file(path: Path) -> Optional[str]:
    if not path.exists() or not path.is_file():
        return None
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def as_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    if isinstance(value, tuple):
        return list(value)
    return [value]


def first_nonempty(*values: Any, default: Any = None) -> Any:
    for value in values:
        if value not in (None, "", [], {}):
            return value
    return default


def normalize_text(value: Any) -> str:
    if value is None:
        return ""
    if not isinstance(value, str):
        try:
            value = json.dumps(value, ensure_ascii=False, sort_keys=True)
        except Exception:
            value = str(value)
    return re.sub(r"\s+", " ", value).strip()


def item_text(item: Any, keys: Sequence[str] = ("description", "claim", "message", "summary", "text", "raw", "line")) -> str:
    if isinstance(item, str):
        return normalize_text(item)
    if isinstance(item, dict):
        for key in keys:
            if isinstance(item.get(key), str) and item[key].strip():
                return normalize_text(item[key])
        return normalize_text(item)
    return normalize_text(item)


def item_evidence(item: Any) -> Any:
    if isinstance(item, dict):
        if "evidence" in item:
            return item.get("evidence")
        if any(k in item for k in ("source_file", "source", "start_line", "end_line", "line", "section", "algorithm_name")):
            return item
    return None


def evidence_ref(evidence: Any) -> JsonDict:
    if not evidence:
        return {}
    if isinstance(evidence, list):
        evidence = evidence[0] if evidence else {}
    if isinstance(evidence, dict):
        out: JsonDict = {}
        for key in (
            "source_file", "source", "section", "section_title", "algorithm_name",
            "start_line", "end_line", "line", "line_number", "text", "snippet", "confidence"
        ):
            if key in evidence:
                out[key] = evidence[key]
        return out or evidence
    return {"text": normalize_text(evidence)}


def unique_strings(values: Iterable[str]) -> List[str]:
    seen = set()
    out = []
    for value in values:
        text = normalize_text(value)
        if not text:
            continue
        key = text.lower()
        if key not in seen:
            seen.add(key)
            out.append(text)
    return out


def unique_dicts_by_text(items: Iterable[JsonDict], text_key: str = "description") -> List[JsonDict]:
    seen = set()
    out = []
    for item in items:
        text = normalize_text(item.get(text_key, "")).lower()
        if not text:
            text = sha256_short(json.dumps(item, ensure_ascii=False, sort_keys=True))
        if text not in seen:
            seen.add(text)
            out.append(item)
    return out


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
    return parent.parent if parent.name == "configs" else parent


def parse_numeric_literal(value: Any) -> Optional[int]:
    if isinstance(value, int):
        return value
    if not isinstance(value, str):
        return None
    s = value.strip().strip(",;.")
    try:
        if re.fullmatch(r"[-+]?\d+", s):
            return int(s)
        if re.fullmatch(r"0x[0-9a-fA-F]+", s):
            return int(s, 16)
    except Exception:
        return None
    return None


def record_list(data: Any, keys: Sequence[str]) -> List[JsonDict]:
    """Normalize different possible JSON shapes into list[dict]."""
    if data in (None, {}, []):
        return []
    if isinstance(data, list):
        return [x if isinstance(x, dict) else {"text": normalize_text(x)} for x in data]
    if not isinstance(data, dict):
        return [{"text": normalize_text(data)}]
    for key in keys:
        value = data.get(key)
        if isinstance(value, list):
            return [x if isinstance(x, dict) else {"text": normalize_text(x)} for x in value]
        if isinstance(value, dict):
            return [{"name": k, **(v if isinstance(v, dict) else {"value": v})} for k, v in value.items()]
    records: List[JsonDict] = []
    skip = {"schema_version", "agent", "created_at", "generated_at", "source_file", "_load_error"}
    for key, value in data.items():
        if key in skip:
            continue
        if isinstance(value, list):
            for item in value:
                rec = item if isinstance(item, dict) else {"text": normalize_text(item)}
                rec.setdefault("group", key)
                records.append(rec)
        elif isinstance(value, dict):
            rec = dict(value)
            rec.setdefault("name", key)
            records.append(rec)
        elif value not in (None, ""):
            records.append({"name": key, "value": value, "text": normalize_text(value)})
    return records


# ---------------------------------------------------------------------------
# Rich Agent 2 v2 bundle
# ---------------------------------------------------------------------------

@dataclasses.dataclass
class RichSpecBundle:
    selected_excerpt_text: str
    sections_index: Any
    algorithm_blocks: List[JsonDict]
    symbol_table: List[JsonDict]
    parameter_table: List[JsonDict]
    equations_constraints: List[JsonDict]
    preconditions_postconditions: List[JsonDict]
    spec_to_code_hints: List[JsonDict]
    loaded_files: Dict[str, JsonDict]
    missing_files: List[str]


def normalize_algorithm_blocks(data: Any) -> List[JsonDict]:
    raw = record_list(data, ("algorithm_blocks", "algorithms", "blocks", "algorithm_candidates"))
    out = []
    for idx, rec in enumerate(raw, start=1):
        rec = dict(rec)
        rec.setdefault("algorithm_name", first_nonempty(rec.get("name"), rec.get("title"), rec.get("algorithm"), default=f"algorithm_{idx}"))
        steps = first_nonempty(rec.get("steps"), rec.get("lines"), rec.get("body"), rec.get("pseudocode"), default=[])
        if isinstance(steps, str):
            rec["steps"] = [line.strip() for line in steps.splitlines() if line.strip()]
        elif isinstance(steps, list):
            rec["steps"] = steps
        else:
            rec["steps"] = []
        out.append(rec)
    return out


def normalize_symbols(data: Any) -> List[JsonDict]:
    raw = record_list(data, ("symbol_table", "symbols", "notations", "entries"))
    out = []
    for rec in raw:
        rec = dict(rec)
        rec.setdefault("symbol", first_nonempty(rec.get("name"), rec.get("id"), rec.get("notation"), default=""))
        rec.setdefault("meaning", first_nonempty(rec.get("description"), rec.get("definition"), rec.get("text"), rec.get("value"), default=""))
        out.append(rec)
    return out


def normalize_parameters(data: Any) -> List[JsonDict]:
    raw = record_list(data, ("parameter_table", "parameters", "parameter_sets", "constants", "rows"))
    out = []
    for rec in raw:
        rec = dict(rec)
        rec.setdefault("name", first_nonempty(rec.get("symbol"), rec.get("parameter"), rec.get("constant"), rec.get("id"), default=""))
        rec.setdefault("value", first_nonempty(rec.get("val"), rec.get("default"), rec.get("number"), default=rec.get("value")))
        out.append(rec)
    return out


def normalize_equations(data: Any) -> List[JsonDict]:
    raw = record_list(data, ("equations_constraints", "equations", "constraints", "relations", "items"))
    out = []
    for rec in raw:
        rec = dict(rec)
        text = item_text(rec)
        rec.setdefault("text", text)
        if "type" not in rec:
            if any(x in text for x in ("≤", "<=", ">=", "<", ">")):
                rec["type"] = "constraint"
            elif "mod" in text.lower() or "%" in text:
                rec["type"] = "modular_relation"
            elif any(x in text for x in ("=", "←", "<-", ":=")):
                rec["type"] = "equation"
            else:
                rec["type"] = "spec_relation"
        out.append(rec)
    return out


def normalize_prepost(data: Any) -> List[JsonDict]:
    out: List[JsonDict] = []
    if isinstance(data, dict):
        for key in ("preconditions", "input_preconditions", "requires"):
            for item in as_list(data.get(key)):
                rec = item if isinstance(item, dict) else {"text": normalize_text(item)}
                rec.setdefault("kind", "precondition")
                out.append(rec)
        for key in ("postconditions", "output_postconditions", "ensures", "guarantees"):
            for item in as_list(data.get(key)):
                rec = item if isinstance(item, dict) else {"text": normalize_text(item)}
                rec.setdefault("kind", "postcondition")
                out.append(rec)
    return out or record_list(data, ("preconditions_postconditions", "conditions", "items"))


# ---------------------------------------------------------------------------
# Domain helpers
# ---------------------------------------------------------------------------

PROPERTY_TYPE_PRIORITY: Dict[str, str] = {
    "memory_safety": "high",
    "array_bounds": "high",
    "pointer_validity": "high",
    "input_pointer_validity": "high",
    "output_pointer_validity": "high",
    "loop_bound": "high",
    "algorithm_loop_bound": "high",
    "algorithm_io_contract": "high",
    "parameter_consistency": "high",
    "spec_code_alignment": "high",
    "integer_overflow": "medium",
    "range_safety": "medium",
    "modular_arithmetic": "medium",
    "equation_conformance": "medium",
    "functional_correctness": "medium",
    "functional_update_shape": "medium",
    "algorithm_functional_step": "medium",
    "precondition_validity": "medium",
    "postcondition_validity": "medium",
    "helper_contract": "medium",
    "aliasing": "medium",
    "tool_compatibility": "medium",
    "side_channel_or_constant_time": "defer",
    "full_protocol_correctness": "reject",
}

CBMC_CHECKS_BY_TYPE: Dict[str, List[str]] = {
    "memory_safety": ["--bounds-check", "--pointer-check"],
    "array_bounds": ["--bounds-check", "--unwind", "--unwinding-assertions"],
    "pointer_validity": ["--pointer-check"],
    "input_pointer_validity": ["--pointer-check"],
    "output_pointer_validity": ["--pointer-check"],
    "loop_bound": ["--bounds-check", "--unwind", "--unwinding-assertions"],
    "algorithm_loop_bound": ["--bounds-check", "--unwind", "--unwinding-assertions"],
    "algorithm_io_contract": ["harness object setup", "--pointer-check", "--bounds-check"],
    "parameter_consistency": ["assert/static check constants", "review macros/headers"],
    "spec_code_alignment": ["traceability check", "critic review"],
    "integer_overflow": ["--signed-overflow-check", "--unsigned-overflow-check"],
    "range_safety": ["assert range property", "__CPROVER_assume only if justified"],
    "modular_arithmetic": ["assert modular relation", "overflow checks", "review arithmetic width"],
    "equation_conformance": ["assert equation relation", "pre-state copies if needed"],
    "functional_correctness": ["assert functional relation"],
    "functional_update_shape": ["assert output relation"],
    "algorithm_functional_step": ["assert step-level relation", "pre-state copies if needed"],
    "precondition_validity": ["document and justify assumptions"],
    "postcondition_validity": ["assert documented postcondition"],
    "helper_contract": ["include helper source or safe stub"],
    "aliasing": ["consider pointer aliasing assumptions only if justified"],
    "tool_compatibility": ["compile harness", "include required headers/sources"],
}


def infer_property_priority(prop_type: str, description: str = "") -> str:
    d = description.lower()
    if "full" in d and ("ml-kem" in d or "protocol" in d or "decapsulation" in d):
        return "reject"
    if "constant-time" in d or "side channel" in d or "timing" in d:
        return "defer"
    return PROPERTY_TYPE_PRIORITY.get(prop_type, "medium")


def operation_kind_from_text(text: str) -> str:
    t = text.lower()
    if "mod" in t or "%" in t:
        return "modular_arithmetic"
    if any(x in t for x in ("<=", ">=", "≤", "≥", "<", ">", "range", "bound")):
        return "range_safety"
    if any(x in t for x in ("←", "<-", ":=", "=")) and any(x in t for x in ("+", "-", "*", "sum", "add", "sub", "reduce")):
        return "algorithm_functional_step"
    return "equation_conformance"


def extract_spec_constant(spec_summary: JsonDict, name: str, rich: Optional[RichSpecBundle] = None) -> Optional[Any]:
    aliases = {
        "n": ["N", "n", "KYBER_N", "MLKEM_N", "MLK_N"],
        "q": ["q", "Q", "KYBER_Q", "MLKEM_Q", "MLK_Q"],
        "k": ["k", "K", "KYBER_K", "MLKEM_K"],
    }.get(name.lower(), [name])
    constants = spec_summary.get("constants")
    if isinstance(constants, dict):
        for alias in aliases:
            if alias in constants:
                value = constants[alias]
                return value.get("value") if isinstance(value, dict) and "value" in value else value
    if rich:
        for rec in rich.parameter_table:
            names = [str(rec.get(k, "")) for k in ("name", "symbol", "parameter", "constant")]
            if any(n in aliases for n in names):
                value = first_nonempty(rec.get("value"), rec.get("number"), rec.get("val"))
                parsed = parse_numeric_literal(value)
                return parsed if parsed is not None else value
    return None


def extract_code_constant(code_summary: JsonDict, name: str) -> Optional[Any]:
    aliases = {
        "n": ["N", "KYBER_N", "MLKEM_N", "MLK_N"],
        "q": ["q", "Q", "KYBER_Q", "MLKEM_Q", "MLK_Q"],
        "k": ["k", "K", "KYBER_K", "MLKEM_K"],
    }.get(name.lower(), [name])
    deps = code_summary.get("dependencies") if isinstance(code_summary.get("dependencies"), dict) else {}
    for macro in as_list(deps.get("relevant_macros_or_constants")):
        if isinstance(macro, dict) and macro.get("name") in aliases:
            parsed = parse_numeric_literal(macro.get("value"))
            return parsed if parsed is not None else macro.get("value")
    return None


# ---------------------------------------------------------------------------
# Property builder
# ---------------------------------------------------------------------------

@dataclasses.dataclass
class PropertyBuilder:
    spec_summary: JsonDict
    code_summary: JsonDict
    config: JsonDict
    settings: JsonDict
    rich: RichSpecBundle
    next_id: int = 1

    def make_property(
        self,
        prop_type: str,
        description: str,
        source_basis: str,
        priority: Optional[str] = None,
        spec_evidence: Optional[List[Any]] = None,
        code_evidence: Optional[List[Any]] = None,
        algorithm_evidence: Optional[List[Any]] = None,
        parameter_evidence: Optional[List[Any]] = None,
        equation_evidence: Optional[List[Any]] = None,
        prepost_evidence: Optional[List[Any]] = None,
        hint_evidence: Optional[List[Any]] = None,
        rationale: str = "",
        tags: Optional[List[str]] = None,
        confidence: str = "medium",
    ) -> JsonDict:
        pid = f"P{self.next_id}"
        self.next_id += 1
        priority_final = priority or infer_property_priority(prop_type, description)
        return {
            "id": pid,
            "type": prop_type,
            "status": "candidate",
            "priority": priority_final,
            "formal_tool": self.config.get("verification_tool", "CBMC"),
            "description": description,
            "source_basis": source_basis,
            "confidence": confidence,
            "rationale": rationale or "Generated by combining selected specification information and code summary.",
            "spec_evidence": [evidence_ref(e) for e in as_list(spec_evidence) if e],
            "code_evidence": [evidence_ref(e) for e in as_list(code_evidence) if e],
            "agent2v2_evidence": {
                "algorithm_blocks": [evidence_ref(e) for e in as_list(algorithm_evidence) if e],
                "parameters": [evidence_ref(e) for e in as_list(parameter_evidence) if e],
                "equations_constraints": [evidence_ref(e) for e in as_list(equation_evidence) if e],
                "preconditions_postconditions": [evidence_ref(e) for e in as_list(prepost_evidence) if e],
                "spec_to_code_hints": [evidence_ref(e) for e in as_list(hint_evidence) if e],
            },
            "candidate_assumptions": self.candidate_assumptions_for_type(prop_type),
            "candidate_assertions_or_checks": self.candidate_assertions_for_type(prop_type),
            "recommended_cbmc_checks": CBMC_CHECKS_BY_TYPE.get(prop_type, ["review manually"]),
            "harness_guidance": self.harness_guidance_for_type(prop_type),
            "human_review_required": True,
            "critic_agent_must_check": [
                "assumptions are not too strong",
                "assertions are connected to selected spec and code",
                "Agent 2 v2 parsed evidence is correct",
                "property is not trivial/vacuous",
                "CBMC command and unwind bound are suitable",
            ],
            "tags": sorted(set(tags or [])),
        }

    def candidate_assumptions_for_type(self, prop_type: str) -> List[JsonDict]:
        assumptions: List[JsonDict] = []
        function_name = first_nonempty(
            self.code_summary.get("target_function_detected"),
            self.code_summary.get("target_function_requested"),
            self.spec_summary.get("target_function"),
            self.config.get("target_function"),
            default="target_function",
        )
        if prop_type in {"memory_safety", "pointer_validity", "input_pointer_validity", "output_pointer_validity", "algorithm_io_contract"}:
            for param in as_list(self.code_summary.get("inputs")) + as_list(self.code_summary.get("outputs_or_inouts")):
                if isinstance(param, dict) and param.get("is_pointer"):
                    assumptions.append({
                        "kind": "pointer_object_validity",
                        "text": f"`{param.get('name')}` must refer to a valid object for `{function_name}`.",
                        "justification_status": "code_required_precondition_candidate",
                        "evidence": evidence_ref(item_evidence(param)),
                    })

        if prop_type in {"array_bounds", "loop_bound", "algorithm_loop_bound", "memory_safety"}:
            for loop in as_list(self.code_summary.get("loop_structure")):
                if isinstance(loop, dict) and loop.get("condition"):
                    assumptions.append({
                        "kind": "loop_unwinding_bound",
                        "text": f"CBMC unwind bound must cover loop condition `{loop.get('condition')}`.",
                        "justification_status": "derived_from_code_loop_candidate",
                        "evidence": evidence_ref(item_evidence(loop)),
                    })

        if prop_type in {"integer_overflow", "range_safety", "modular_arithmetic", "equation_conformance", "functional_correctness", "functional_update_shape", "algorithm_functional_step"}:
            q = extract_spec_constant(self.spec_summary, "q", self.rich)
            assumptions.append({
                "kind": "coefficient_range_precondition",
                "text": f"Coefficient input ranges may need assumptions related to q = {q}, but q alone does not automatically prove a safe input range." if q is not None else "Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful.",
                "justification_status": "needs_human_and_spec_confirmation",
            })

        if prop_type == "aliasing":
            assumptions.append({
                "kind": "aliasing_policy",
                "text": "Do not add non-aliasing assumptions unless implementation/spec context justifies them.",
                "justification_status": "must_not_invent",
            })
        return unique_dicts_by_text(assumptions, text_key="text")

    def candidate_assertions_for_type(self, prop_type: str) -> List[JsonDict]:
        assertions: List[JsonDict] = []
        function_name = first_nonempty(
            self.code_summary.get("target_function_detected"),
            self.code_summary.get("target_function_requested"),
            self.spec_summary.get("target_function"),
            self.config.get("target_function"),
            default="target_function",
        )
        if prop_type in {"array_bounds", "loop_bound", "algorithm_loop_bound", "memory_safety", "pointer_validity", "input_pointer_validity", "output_pointer_validity", "algorithm_io_contract"}:
            assertions.append({"kind": "cbmc_builtin_check", "text": "Use CBMC pointer/bounds checks with sufficient unwinding and valid harness object setup."})
        if prop_type == "integer_overflow":
            assertions.append({"kind": "cbmc_builtin_check", "text": "Use CBMC signed/unsigned overflow checks; separate this from functional equality assertions."})
        if prop_type in {"functional_correctness", "functional_update_shape", "algorithm_functional_step", "equation_conformance"}:
            writes = [w for w in as_list(self.code_summary.get("output_writes_and_assignments")) if isinstance(w, dict)]
            for write in writes[:5]:
                lhs, rhs = write.get("lhs"), write.get("rhs")
                if lhs and rhs:
                    assertions.append({
                        "kind": "candidate_functional_assertion",
                        "text": f"After `{function_name}`, check whether `{lhs}` matches intended expression `{rhs}` under documented assumptions.",
                        "warning": "Use pre-state copies if output may alias an input pointer.",
                    })
            for alg in self.rich.algorithm_blocks[:3]:
                for step in assignments_from_algorithm(alg)[:3]:
                    assertions.append({
                        "kind": "candidate_algorithm_step_assertion",
                        "text": f"If code mapping is confirmed, assert FIPS-style step relation: `{step}`.",
                        "warning": "Translate symbols to C variables/macros carefully.",
                    })
        if prop_type in {"range_safety", "modular_arithmetic", "postcondition_validity"}:
            q = extract_spec_constant(self.spec_summary, "q", self.rich)
            assertions.append({
                "kind": "candidate_range_or_modular_assertion",
                "text": f"If the function promises reduction/range preservation, assert an output range or congruent relation modulo q = {q}." if q is not None else "If the function promises range preservation, assert the documented output range.",
                "warning": "Only assert this when spec/code actually promises this property.",
            })
        if prop_type == "parameter_consistency":
            assertions.append({"kind": "constant_consistency_check", "text": "Check that spec parameters such as n and q match code macros/constants before using them in assumptions/assertions."})
        if prop_type == "spec_code_alignment":
            assertions.append({"kind": "traceability_check", "text": "Confirm selected FIPS algorithm/spec section corresponds to the selected C target function."})
        if prop_type == "helper_contract":
            assertions.append({"kind": "helper_contract_check", "text": "Include helper source files in CBMC or document safe helper stubs/contracts."})
        return unique_dicts_by_text(assertions, text_key="text")

    def harness_guidance_for_type(self, prop_type: str) -> List[str]:
        guidance: List[str] = []
        if prop_type in {"pointer_validity", "input_pointer_validity", "output_pointer_validity", "memory_safety", "algorithm_io_contract"}:
            guidance.append("Create concrete harness objects for pointer parameters before calling the target function.")
        if prop_type in {"array_bounds", "loop_bound", "algorithm_loop_bound", "memory_safety"}:
            guidance.append("Set CBMC unwind bound from implementation loops and parsed algorithm loop bounds; use --unwinding-assertions.")
        if prop_type in {"integer_overflow", "range_safety", "modular_arithmetic", "equation_conformance", "functional_correctness", "functional_update_shape", "algorithm_functional_step"}:
            guidance.append("Keep input range assumptions explicit and cite why each assumption is allowed.")
            guidance.append("Translate FIPS symbols to C variables/macros through symbol table/spec-to-code hints before asserting.")
        if prop_type == "parameter_consistency":
            guidance.append("Do not generate q/n/k assumptions until parsed spec parameters match code constants.")
        return unique_strings(guidance)


def assignments_from_algorithm(algorithm: JsonDict) -> List[str]:
    texts = [item_text(x) for x in as_list(algorithm.get("steps"))]
    texts += [item_text(x) for x in as_list(algorithm.get("assignments"))]
    return unique_strings([t for t in texts if any(op in t for op in ("←", "<-", ":=", "="))])


def loop_bounds_from_algorithm(algorithm: JsonDict) -> List[str]:
    out: List[str] = []
    for key in ("loop_bounds", "loops", "ranges"):
        out.extend(item_text(x) for x in as_list(algorithm.get(key)) if item_text(x))
    for text in [item_text(x) for x in as_list(algorithm.get("steps"))]:
        if re.search(r"\bfor\b|\bwhile\b|\bfrom\b|\bto\b|≤|<=|<", text, re.I):
            out.append(text)
    return unique_strings(out)


# ---------------------------------------------------------------------------
# Main agent
# ---------------------------------------------------------------------------

class PropertyDiscoveryAgent:
    def __init__(self, config_path: Path, run_dir: Optional[Path] = None) -> None:
        self.config_path = config_path.resolve()
        self.config = read_json(self.config_path)
        self.project_root = find_project_root(self.config_path)

        output_root = resolve_path(self.project_root, self.config.get("output_root", "runs"))
        run_id = first_nonempty(self.config.get("run_id"), f"run_{self.config.get('target_function', 'target')}")
        self.run_dir = run_dir.resolve() if run_dir else (output_root / str(run_id)).resolve()

        settings = self.config.get("property_discovery_settings", {})
        self.settings: JsonDict = settings if isinstance(settings, dict) else {}

        self.spec_summary_path = resolve_path(self.project_root, self.settings.get("spec_summary_file"), fallback=self.run_dir / "01_spec_summary.json")
        self.code_summary_path = resolve_path(self.project_root, self.settings.get("code_summary_file"), fallback=self.run_dir / "02_code_summary.json")

        self.rich_paths = {
            "selected_spec_excerpt": resolve_path(self.project_root, self.settings.get("selected_spec_excerpt_file"), fallback=self.run_dir / "selected_spec_excerpt.txt"),
            "sections_index": resolve_path(self.project_root, self.settings.get("spec_sections_index_file"), fallback=self.run_dir / "01_spec_sections_index.json"),
            "algorithm_blocks": resolve_path(self.project_root, self.settings.get("algorithm_blocks_file"), fallback=self.run_dir / "01_algorithm_blocks.json"),
            "symbol_table": resolve_path(self.project_root, self.settings.get("symbol_table_file"), fallback=self.run_dir / "01_symbol_table.json"),
            "parameter_table": resolve_path(self.project_root, self.settings.get("parameter_table_file"), fallback=self.run_dir / "01_parameter_table.json"),
            "equations_constraints": resolve_path(self.project_root, self.settings.get("equations_constraints_file"), fallback=self.run_dir / "01_equations_constraints.json"),
            "preconditions_postconditions": resolve_path(self.project_root, self.settings.get("preconditions_postconditions_file"), fallback=self.run_dir / "01_preconditions_postconditions.json"),
            "spec_to_code_hints": resolve_path(self.project_root, self.settings.get("spec_to_code_hints_file"), fallback=self.run_dir / "01_spec_to_code_hints.json"),
        }

        self.output_json_path = self.run_dir / "03_candidate_properties.json"
        self.output_md_path = self.run_dir / "03_candidate_properties.md"
        self.prompt_path = self.run_dir / "llm_prompts" / "03_property_discovery_prompt.txt"
        self.agent_status_path = self.run_dir / "agent_status" / "03_property_discovery_status.json"
        self.event_log_path = self.run_dir / "events.jsonl"

        self.evidence_matrix_path = self.run_dir / "03_property_evidence_matrix.csv"
        self.traceability_path = self.run_dir / "03_spec_code_traceability.json"
        self.integration_report_path = self.run_dir / "03_agent2v2_integration_report.json"

    def log_event(self, event_type: str, payload: JsonDict) -> None:
        append_jsonl(self.event_log_path, {"timestamp": utc_now(), "agent": "property_discovery", "agent_version": AGENT_VERSION, "event_type": event_type, **payload})

    def run(self) -> int:
        started_at = utc_now()
        try:
            self.log_event("agent_start", {"spec_summary": str(self.spec_summary_path), "code_summary": str(self.code_summary_path), "output": str(self.output_json_path)})
            self._validate_inputs_exist()
            spec_summary = read_json(self.spec_summary_path)
            code_summary = read_json(self.code_summary_path)
            rich = self._load_rich_spec_bundle()

            prompt = self._build_prompt(spec_summary, code_summary, rich)
            write_text(self.prompt_path, prompt)

            result = self._discover_properties(spec_summary, code_summary, rich, started_at)
            result["created_at"] = utc_now()
            result["agent_name"] = "property_discovery_agent"
            result["agent_version"] = AGENT_VERSION
            result["discovery_method"] = "deterministic_fips_aware_spec_code_merge"
            result["output_files"] = {
                "json": str(self.output_json_path),
                "markdown": str(self.output_md_path),
                "prompt": str(self.prompt_path),
                "status": str(self.agent_status_path),
                "evidence_matrix_csv": str(self.evidence_matrix_path),
                "traceability_json": str(self.traceability_path),
                "agent2v2_integration_report": str(self.integration_report_path),
            }

            self._validate_and_warn(result)
            write_json(self.output_json_path, result)
            write_text(self.output_md_path, self._to_markdown(result))
            write_csv(self.evidence_matrix_path, self._evidence_matrix_rows(result), [
                "property_id", "type", "priority", "source_basis", "confidence",
                "has_legacy_spec_evidence", "has_agent2v2_algorithm_evidence",
                "has_agent2v2_parameter_evidence", "has_agent2v2_equation_evidence",
                "has_agent2v2_prepost_evidence", "has_agent2v2_hint_evidence",
                "has_code_evidence", "human_review_required", "description",
            ])
            traceability = self._traceability_report(result, rich)
            write_json(self.traceability_path, traceability)
            integration = self._integration_report(result, rich)
            write_json(self.integration_report_path, integration)

            status = {
                "agent": "property_discovery",
                "agent_version": AGENT_VERSION,
                "status": "passed",
                "started_at": started_at,
                "finished_at": utc_now(),
                "output_json": str(self.output_json_path),
                "output_markdown": str(self.output_md_path),
                "prompt_file": str(self.prompt_path),
                "evidence_matrix_csv": str(self.evidence_matrix_path),
                "traceability_json": str(self.traceability_path),
                "integration_report_json": str(self.integration_report_path),
                "candidate_property_count": len(result.get("candidate_properties", [])),
                "rejected_property_count": len(result.get("rejected_properties", [])),
                "agent2v2_files_loaded": integration.get("loaded_file_count", 0),
                "agent2v2_files_missing": rich.missing_files,
                "human_review_required": True,
            }
            write_json(self.agent_status_path, status)
            self.log_event("agent_finish", status)

            print(f"[OK] Property Discovery Agent v2 wrote: {self.output_json_path}")
            print(f"[OK] Markdown summary: {self.output_md_path}")
            print(f"[OK] Evidence matrix: {self.evidence_matrix_path}")
            print(f"[OK] Traceability report: {self.traceability_path}")
            print(f"[OK] Candidate properties: {status['candidate_property_count']} | Rejected/deferred: {status['rejected_property_count']}")
            print("[NOTE] These are candidate properties only. CBMC and human review remain required.")
            return 0
        except Exception as exc:
            status = {
                "agent": "property_discovery",
                "agent_version": AGENT_VERSION,
                "status": "failed",
                "started_at": started_at,
                "finished_at": utc_now(),
                "error": str(exc),
                "traceback": traceback.format_exc(),
                "human_review_required": True,
            }
            write_json(self.agent_status_path, status)
            self.log_event("agent_error", status)
            print(f"[ERROR] Property Discovery Agent v2 failed: {exc}", file=sys.stderr)
            print(f"[INFO] Status file: {self.agent_status_path}", file=sys.stderr)
            return 1

    def _validate_inputs_exist(self) -> None:
        missing = []
        if not self.spec_summary_path.exists():
            missing.append(str(self.spec_summary_path))
        if not self.code_summary_path.exists():
            missing.append(str(self.code_summary_path))
        if missing:
            raise FileNotFoundError("Property Discovery Agent needs Agent 2 and Agent 3 outputs first. Missing: " + ", ".join(missing))

    def _load_rich_spec_bundle(self) -> RichSpecBundle:
        missing: List[str] = []
        loaded: Dict[str, JsonDict] = {}
        excerpt = read_text_optional(self.rich_paths["selected_spec_excerpt"])
        if self.rich_paths["selected_spec_excerpt"].exists():
            loaded["selected_spec_excerpt"] = {"path": str(self.rich_paths["selected_spec_excerpt"]), "sha256": sha256_file(self.rich_paths["selected_spec_excerpt"]), "size_chars": len(excerpt)}
        else:
            missing.append("selected_spec_excerpt.txt")

        raw: Dict[str, Any] = {}
        for key in ("sections_index", "algorithm_blocks", "symbol_table", "parameter_table", "equations_constraints", "preconditions_postconditions", "spec_to_code_hints"):
            path = self.rich_paths[key]
            if not path.exists():
                missing.append(path.name)
                raw[key] = {}
                continue
            value = read_json_optional(path, {})
            raw[key] = value
            loaded[key] = {"path": str(path), "sha256": sha256_file(path), "load_error": bool(isinstance(value, dict) and value.get("_load_error"))}

        return RichSpecBundle(
            selected_excerpt_text=excerpt,
            sections_index=raw.get("sections_index", {}),
            algorithm_blocks=normalize_algorithm_blocks(raw.get("algorithm_blocks", {})),
            symbol_table=normalize_symbols(raw.get("symbol_table", {})),
            parameter_table=normalize_parameters(raw.get("parameter_table", {})),
            equations_constraints=normalize_equations(raw.get("equations_constraints", {})),
            preconditions_postconditions=normalize_prepost(raw.get("preconditions_postconditions", {})),
            spec_to_code_hints=record_list(raw.get("spec_to_code_hints", {}), ("spec_to_code_hints", "hints", "matches", "mapping", "items")),
            loaded_files=loaded,
            missing_files=missing,
        )

    def _build_prompt(self, spec_summary: JsonDict, code_summary: JsonDict, rich: RichSpecBundle) -> str:
        target = first_nonempty(code_summary.get("target_function_detected"), code_summary.get("target_function_requested"), spec_summary.get("target_function"), self.config.get("target_function"), default="target_function")
        compact = {
            "legacy_spec_constants": spec_summary.get("constants", {}),
            "rich_counts": {
                "algorithms": len(rich.algorithm_blocks),
                "symbols": len(rich.symbol_table),
                "parameters": len(rich.parameter_table),
                "equations_constraints": len(rich.equations_constraints),
                "prepost": len(rich.preconditions_postconditions),
                "hints": len(rich.spec_to_code_hints),
            },
            "code_function": code_summary.get("function", {}),
            "code_loops": code_summary.get("loop_structure", []),
            "code_writes": code_summary.get("output_writes_and_assignments", []),
        }
        return (
            "You are the FIPS-aware Property Discovery Agent.\n"
            f"Target function: {target}\n"
            "Task: combine legacy spec summary, Agent 2 v2 rich parsed spec outputs, and code summary.\n"
            "Propose candidate properties only. Do not claim proof. Human review and CBMC remain required.\n\n"
            + json.dumps(compact, indent=2, ensure_ascii=False)
            + "\n"
        )

    def _discover_properties(self, spec_summary: JsonDict, code_summary: JsonDict, rich: RichSpecBundle, started_at: str) -> JsonDict:
        builder = PropertyBuilder(spec_summary, code_summary, self.config, self.settings, rich)
        candidates: List[JsonDict] = []
        rejected: List[JsonDict] = []
        target = first_nonempty(code_summary.get("target_function_detected"), code_summary.get("target_function_requested"), spec_summary.get("target_function"), self.config.get("target_function"), default="target_function")

        candidates.extend(self._properties_from_code(builder, code_summary, target))
        candidates.extend(self._properties_from_legacy_spec(builder, spec_summary, code_summary, target, rejected))
        candidates.extend(self._properties_from_rich_spec(builder, spec_summary, code_summary, rich, target, rejected))
        candidates.extend(self._matched_properties(builder, spec_summary, code_summary, rich, target))
        candidates.extend(self._tool_properties(builder, code_summary, target))

        rejected.extend(self._default_rejections(target))
        rejected.extend(self._inherited_rejections(spec_summary, code_summary))
        candidates = unique_dicts_by_text(candidates)
        candidates, settings_rejections = self._apply_settings(candidates)
        rejected.extend(settings_rejections)

        consistency = self._consistency_checks(spec_summary, code_summary, rich)
        traceability = self._spec_code_traceability(spec_summary, code_summary, rich, candidates)
        assumptions = self._assumption_bank(candidates, spec_summary, rich)
        plan = self._cbmc_plan(candidates, code_summary, rich)
        uncertainties = self._uncertainties(spec_summary, code_summary, rich, consistency, candidates)
        quality_flags = self._quality_flags(candidates, rejected, consistency, uncertainties, rich)

        return {
            "schema_version": "2.0",
            "agent_version": AGENT_VERSION,
            "target_scheme": first_nonempty(self.config.get("target_scheme"), spec_summary.get("target_scheme"), code_summary.get("target_scheme"), default="unknown"),
            "target_function": target,
            "verification_goal": self.config.get("verification_goal", ""),
            "verification_tool": self.config.get("verification_tool", "CBMC"),
            "artifact_type": self.config.get("artifact_type", "CBMC harness"),
            "input_files": {
                "spec_summary": str(self.spec_summary_path),
                "code_summary": str(self.code_summary_path),
                "config": str(self.config_path),
                "agent2v2_optional_files": {k: str(v) for k, v in self.rich_paths.items()},
            },
            "agent2v2_usage": {
                "rich_spec_files_loaded": rich.loaded_files,
                "rich_spec_files_missing": rich.missing_files,
                "algorithm_block_count": len(rich.algorithm_blocks),
                "symbol_count": len(rich.symbol_table),
                "parameter_count": len(rich.parameter_table),
                "equation_constraint_count": len(rich.equations_constraints),
                "prepost_count": len(rich.preconditions_postconditions),
                "spec_to_code_hint_count": len(rich.spec_to_code_hints),
                "selected_excerpt_chars": len(rich.selected_excerpt_text),
            },
            "candidate_properties": candidates,
            "property_groups": self._group_properties(candidates),
            "first_harness_selection": self._select_first_harness_properties(candidates),
            "assumption_bank": assumptions,
            "cbmc_property_plan": plan,
            "consistency_checks": consistency,
            "spec_code_traceability": traceability,
            "rejected_properties": unique_dicts_by_text(rejected),
            "uncertainties": uncertainties,
            "quality_flags": quality_flags,
            "next_agent_instructions": {
                "formal_artifact_generation_agent": [
                    "Use only selected candidate properties.",
                    "Use Agent 2 v2 parsed algorithm/symbol/parameter evidence only when traceability is clear.",
                    "Keep each __CPROVER_assume commented and justified.",
                    "Do not hide CBMC failures.",
                ],
                "review_critic_agent": [
                    "Check assumption strength and evidence.",
                    "Check symbol-to-code mapping.",
                    "Check whether selected properties match function scope.",
                ],
            },
            "scientific_guardrails": {
                "properties_are_candidates_only": True,
                "formal_tool_is_final_checker": True,
                "human_review_required": True,
                "no_claim_of_full_mlkem_proof": True,
                "agent2v2_extractions_are_not_blindly_trusted": True,
            },
            "agent_runtime": {"started_at": started_at, "finished_at": utc_now()},
        }

    # ------------------------------------------------------------------
    # Property creation
    # ---------------------------------------------------------------------------

    def _properties_from_code(self, builder: PropertyBuilder, code: JsonDict, target: str) -> List[JsonDict]:
        props: List[JsonDict] = []
        inputs = [p for p in as_list(code.get("inputs")) if isinstance(p, dict)]
        outputs = [p for p in as_list(code.get("outputs_or_inouts")) if isinstance(p, dict)]
        arrays = [a for a in as_list(code.get("array_accesses")) if isinstance(a, dict)]
        loops = [l for l in as_list(code.get("loop_structure")) if isinstance(l, dict)]
        ops = [o for o in as_list(code.get("integer_and_bit_operations")) if isinstance(o, dict)]
        writes = [w for w in as_list(code.get("output_writes_and_assignments")) if isinstance(w, dict)]
        helpers = [h for h in as_list(code.get("helper_function_or_macro_calls")) if isinstance(h, dict)]
        ptrs = [p for p in as_list(code.get("pointer_accesses")) if isinstance(p, dict)]

        for param in inputs:
            if param.get("is_pointer"):
                props.append(builder.make_property("input_pointer_validity", f"Input pointer `{param.get('name')}` must be valid and readable when `{target}` is called.", "code", "high", code_evidence=[item_evidence(param)], tags=["code", "pointer"], confidence="high"))
        for param in outputs:
            if param.get("is_pointer"):
                props.append(builder.make_property("output_pointer_validity", f"Output/in-out pointer `{param.get('name')}` must be valid and writable when `{target}` writes through it.", "code", "high", code_evidence=[item_evidence(param)], tags=["code", "pointer"], confidence="high"))
        if ptrs:
            props.append(builder.make_property("memory_safety", f"All pointer field/dereference accesses inside `{target}` should be memory-safe under documented harness assumptions.", "code", "high", code_evidence=[item_evidence(p) for p in ptrs[:6]], tags=["memory_safety"], confidence="high"))
        if arrays:
            desc = f"All detected array accesses in `{target}` should stay within valid bounds."
            props.append(builder.make_property("array_bounds", desc, "code", "high", code_evidence=[item_evidence(a) for a in arrays[:8]], tags=["array", "bounds"], confidence="high"))
        for loop in loops:
            condition = loop.get("condition") or loop.get("raw") or "detected loop"
            props.append(builder.make_property("loop_bound", f"Loop `{condition}` in `{target}` should be unwound sufficiently and should not drive array indices outside valid bounds.", "code", "high", code_evidence=[item_evidence(loop)], tags=["loop", "unwinding"], confidence="high"))
        if ops:
            props.append(builder.make_property("integer_overflow", f"Arithmetic/bit operations in `{target}` should not trigger undefined or unintended overflow under documented assumptions.", "code_plus_spec_needed", "medium", code_evidence=[item_evidence(o) for o in ops[:8]], tags=["overflow"], confidence="medium"))
        if writes:
            desc = f"The writes performed by `{target}` should match the intended function-level update shape under documented assumptions."
            props.append(builder.make_property("functional_update_shape", desc, "code_plus_spec", "medium", code_evidence=[item_evidence(w) for w in writes[:8]], tags=["functional"], confidence="medium"))
        if helpers:
            props.append(builder.make_property("helper_contract", f"Helper calls/macros used by `{target}` must be included, stubbed, or given documented contracts before CBMC results are trusted.", "code", "medium", code_evidence=[item_evidence(h) for h in helpers[:8]], tags=["helper"], confidence="medium"))
        if len(inputs) + len(outputs) >= 2 and any(p.get("is_pointer") for p in inputs + outputs):
            props.append(builder.make_property("aliasing", f"Pointer aliasing behavior for `{target}` should be documented before adding non-aliasing assumptions.", "code_plus_human_review", "medium", code_evidence=[item_evidence(p) for p in (inputs + outputs)[:6]], tags=["aliasing"], confidence="medium"))
        return props

    def _properties_from_legacy_spec(self, builder: PropertyBuilder, spec: JsonDict, code: JsonDict, target: str, rejected: List[JsonDict]) -> List[JsonDict]:
        props: List[JsonDict] = []
        items: List[Tuple[str, Any]] = []
        for key in ("candidate_safety_properties", "candidate_functional_properties", "candidate_output_guarantees"):
            for item in as_list(spec.get(key)):
                items.append((key, item))
        code_text = json.dumps(code, ensure_ascii=False).lower()

        for key, item in items:
            text = item_text(item)
            if not text:
                continue
            ptype = self._ptype_from_text(text, "functional_correctness" if "functional" in key or "guarantee" in key else "memory_safety")
            priority = infer_property_priority(ptype, text)
            if priority in ("reject", "defer"):
                rejected.append({"description": text, "reason": "Too broad/deferred for selected function-level CBMC prototype.", "source": "spec_summary", "status": priority})
                continue
            supported = self._text_supported_by_code(text, code_text, ptype)
            props.append(builder.make_property(ptype, f"For `{target}`, candidate spec-derived property: {text}", "spec_plus_code" if supported else "spec", priority, spec_evidence=[item_evidence(item)], code_evidence=self._related_code_evidence_for_type(code, ptype), tags=["legacy_spec", ptype], confidence="medium" if supported else "low"))
        return props

    def _properties_from_rich_spec(self, builder: PropertyBuilder, spec: JsonDict, code: JsonDict, rich: RichSpecBundle, target: str, rejected: List[JsonDict]) -> List[JsonDict]:
        props: List[JsonDict] = []

        if rich.parameter_table:
            tracked = self._tracked_parameters(rich)
            if tracked:
                props.append(builder.make_property("parameter_consistency", f"Parsed specification parameters/constants should match implementation macros/constants before using them in CBMC assumptions. Tracked parameters: {', '.join(tracked)}.", "agent2v2_parameters_plus_code", "high", parameter_evidence=rich.parameter_table[:12], code_evidence=self._macro_evidence(code), tags=["agent2v2", "parameters"], confidence="high"))

        for alg in rich.algorithm_blocks:
            alg_name = first_nonempty(alg.get("algorithm_name"), alg.get("name"), alg.get("title"), default="parsed_algorithm")
            if not self._algorithm_relevant_to_target(alg, target, code, rich):
                if self.settings.get("record_irrelevant_algorithm_rejections", True):
                    rejected.append({"description": f"Algorithm block `{alg_name}` was parsed but not clearly relevant to `{target}`.", "reason": "Not used for first harness properties because target-function mapping is uncertain.", "source": "01_algorithm_blocks.json", "status": "deferred_irrelevant_algorithm_candidate", "evidence": evidence_ref(alg)})
                continue

            if as_list(alg.get("inputs")) or as_list(alg.get("outputs")) or as_list(alg.get("input")) or as_list(alg.get("output")):
                props.append(builder.make_property("algorithm_io_contract", f"FIPS-style algorithm `{alg_name}` input/output contract should be reflected in the `{target}` harness setup.", "agent2v2_algorithm_plus_code", "high", algorithm_evidence=[alg], code_evidence=self._function_signature_evidence(code), tags=["agent2v2", "algorithm", "io"], confidence="medium"))

            for bound in loop_bounds_from_algorithm(alg)[:3]:
                props.append(builder.make_property("algorithm_loop_bound", f"FIPS-style algorithm `{alg_name}` loop/range `{bound}` should be consistent with implementation loop bounds and CBMC unwinding.", "agent2v2_algorithm_plus_code_loop", "high", algorithm_evidence=[alg], code_evidence=[item_evidence(x) for x in as_list(code.get("loop_structure"))[:5] if isinstance(x, dict)], tags=["agent2v2", "loop"], confidence="medium"))

            for step in assignments_from_algorithm(alg)[:4]:
                ptype = operation_kind_from_text(step)
                props.append(builder.make_property(ptype, f"FIPS-style algorithm `{alg_name}` step `{step}` should correspond to selected implementation behavior under reviewed symbol mapping.", "agent2v2_algorithm_step_plus_code", "medium", algorithm_evidence=[alg], parameter_evidence=self._parameters_referenced_in_text(step, rich), code_evidence=self._related_code_evidence_for_type(code, ptype), tags=["agent2v2", "algorithm_step"], confidence="medium"))

            if not loop_bounds_from_algorithm(alg) and not assignments_from_algorithm(alg):
                props.append(builder.make_property("spec_code_alignment", f"Parsed algorithm block `{alg_name}` should be manually reviewed for relevance to `{target}` before property generation.", "agent2v2_algorithm_review", "medium", algorithm_evidence=[alg], tags=["agent2v2", "review"], confidence="low"))

        for eq in rich.equations_constraints:
            text = item_text(eq)
            if not text or not self._equation_relevant_to_target(text, target, code):
                continue
            ptype = operation_kind_from_text(text)
            props.append(builder.make_property(ptype, f"Parsed FIPS equation/constraint `{text}` may define a candidate check for `{target}` if involved symbols map to code variables.", "agent2v2_equation_constraint_plus_code", "medium", equation_evidence=[eq], parameter_evidence=self._parameters_referenced_in_text(text, rich), code_evidence=self._related_code_evidence_for_type(code, ptype), tags=["agent2v2", "equation"], confidence="medium"))

        for cond in rich.preconditions_postconditions:
            text = item_text(cond)
            if not text:
                continue
            kind = str(first_nonempty(cond.get("kind"), cond.get("type"), default="condition")).lower()
            ptype = "precondition_validity" if "pre" in kind or "require" in kind else "postcondition_validity"
            props.append(builder.make_property(ptype, f"Parsed specification {kind} `{text}` should be treated as a candidate {'assumption' if ptype == 'precondition_validity' else 'assertion'} for `{target}` only after evidence review.", "agent2v2_prepost_plus_code", "medium", prepost_evidence=[cond], parameter_evidence=self._parameters_referenced_in_text(text, rich), code_evidence=self._function_signature_evidence(code), tags=["agent2v2", "prepost"], confidence="medium"))

        for hint in rich.spec_to_code_hints:
            text = item_text(hint)
            hint_target = normalize_text(first_nonempty(hint.get("target_function"), hint.get("code_function"), hint.get("code_symbol"), default=""))
            if hint_target and target.lower() not in hint_target.lower() and hint_target.lower() not in target.lower() and target.lower() not in text.lower():
                continue
            props.append(builder.make_property("spec_code_alignment", f"Agent 2 v2 spec-to-code hint should be checked: {text or 'mapping candidate'}.", "agent2v2_spec_to_code_hint", "high", hint_evidence=[hint], code_evidence=self._function_signature_evidence(code), tags=["agent2v2", "traceability"], confidence=str(first_nonempty(hint.get("confidence"), default="medium"))))
        return props

    def _matched_properties(self, builder: PropertyBuilder, spec: JsonDict, code: JsonDict, rich: RichSpecBundle, target: str) -> List[JsonDict]:
        props: List[JsonDict] = []
        writes = [w for w in as_list(code.get("output_writes_and_assignments")) if isinstance(w, dict)]
        text = "\n".join([item_text(x) for x in as_list(spec.get("candidate_output_guarantees")) + as_list(spec.get("candidate_functional_properties")) + rich.algorithm_blocks + rich.equations_constraints]).lower()
        target_l = target.lower()
        if writes and ("add" in target_l or "sum" in text or "addition" in text or any("+" in str(w.get("rhs", "")) for w in writes)):
            props.append(builder.make_property("functional_correctness", f"For `{target}`, each output update should match selected addition/sum behavior under documented preconditions.", "matched_spec_algorithm_plus_code", "medium", algorithm_evidence=rich.algorithm_blocks[:3], equation_evidence=[e for e in rich.equations_constraints if "+" in item_text(e)][:5], code_evidence=[item_evidence(w) for w in writes[:5]], tags=["functional", "matched", "agent2v2"], confidence="medium"))
        if any(w in target_l for w in ("reduce", "barrett", "montgomery", "csubq")) or any(w in text for w in ("reduce", "range", "modulus", "modulo", "mod q")):
            props.append(builder.make_property("range_safety", f"For `{target}`, output coefficient range should match selected reduction/modulus rule if explicitly supported by parsed spec and code.", "matched_spec_algorithm_plus_code", "medium", equation_evidence=[e for e in rich.equations_constraints if any(x in item_text(e).lower() for x in ("mod", "range", "<=", "≤"))][:5], code_evidence=self._related_code_evidence_for_type(code, "range_safety"), tags=["range", "modulus", "agent2v2"], confidence="medium"))
        if any(w in target_l for w in ("tobytes", "frombytes", "pack", "unpack", "encode", "decode", "compress", "decompress")):
            props.append(builder.make_property("array_bounds", f"For `{target}`, byte-buffer and polynomial-array accesses should stay within documented packing/unpacking sizes.", "matched_spec_algorithm_plus_code", "high", algorithm_evidence=rich.algorithm_blocks[:3], parameter_evidence=rich.parameter_table[:8], code_evidence=self._related_code_evidence_for_type(code, "array_bounds"), tags=["packing", "buffer", "agent2v2"], confidence="medium"))
        return props

    def _tool_properties(self, builder: PropertyBuilder, code: JsonDict, target: str) -> List[JsonDict]:
        helpers = as_list(code.get("helper_function_or_macro_calls"))
        missing = as_list(code.get("missing_header_files"))
        hints = code.get("cbmc_hints") if isinstance(code.get("cbmc_hints"), dict) else {}
        helper_sources = as_list(hints.get("helper_sources_or_stubs_may_be_needed"))
        if helpers or missing or helper_sources:
            return [builder.make_property("tool_compatibility", f"The CBMC harness for `{target}` should include all required headers, helper sources, or safe stubs so verification results are meaningful.", "code_plus_tool", "medium", code_evidence=[item_evidence(h) for h in helpers[:5] if isinstance(h, dict)], tags=["tool", "cbmc"], confidence="medium")]
        return []

    # ------------------------------------------------------------------
    # Analysis support
    # ---------------------------------------------------------------------------

    def _ptype_from_text(self, text: str, default: str) -> str:
        t = text.lower()
        if any(w in t for w in ("out-of-bounds", "bounds", "array", "index")):
            return "array_bounds"
        if "pointer" in t:
            return "pointer_validity"
        if "overflow" in t:
            return "integer_overflow"
        if any(w in t for w in ("mod", "modulo", "modulus", "congruent")):
            return "modular_arithmetic"
        if any(w in t for w in ("range", "coefficient")):
            return "range_safety"
        if "memory" in t:
            return "memory_safety"
        return default

    def _text_supported_by_code(self, spec_text: str, code_text: str, ptype: str) -> bool:
        t = spec_text.lower()
        if ptype in {"array_bounds", "loop_bound", "algorithm_loop_bound"}:
            return "[" in code_text or "loop" in code_text or "array" in code_text or "coeffs" in code_text
        if ptype in {"pointer_validity", "memory_safety", "algorithm_io_contract"}:
            return "pointer" in code_text or "->" in code_text or "*" in code_text
        if ptype in {"integer_overflow", "range_safety", "modular_arithmetic"}:
            return any(tok in code_text for tok in ("+", "-", "*", "coeff", "mod", "reduce"))
        return bool(set(re.findall(r"[a-zA-Z_][a-zA-Z0-9_]*", t)) & set(re.findall(r"[a-zA-Z_][a-zA-Z0-9_]*", code_text)) & {"poly", "polynomial", "coeff", "coeffs", "coefficient", "mod", "q", "n", "add", "reduce"})

    def _algorithm_relevant_to_target(self, alg: JsonDict, target: str, code: JsonDict, rich: RichSpecBundle) -> bool:
        target_l = target.lower()
        text = item_text(alg).lower()
        if target_l in text or target_l.replace("_", "") in text.replace("_", ""):
            return True
        tokens = [tok for tok in re.split(r"[_\W]+", target_l) if len(tok) >= 3]
        if tokens and sum(1 for tok in tokens if tok in text) >= max(1, len(tokens) // 2):
            return True
        for hint in rich.spec_to_code_hints:
            h = item_text(hint).lower()
            if target_l in h and any(str(alg.get(k, "")).lower() in h for k in ("algorithm_name", "name", "title")):
                return True
        if any(x in target_l for x in ("add", "sub", "reduce", "compress", "decompress", "tobytes", "frombytes", "encode", "decode", "ntt")):
            return any(x in text for x in ("add", "addition", "sub", "subtract", "reduce", "compress", "decompress", "encode", "decode", "ntt", "polynomial"))
        return False

    def _equation_relevant_to_target(self, text: str, target: str, code: JsonDict) -> bool:
        t = text.lower()
        if any(tok in t for tok in re.split(r"[_\W]+", target.lower()) if len(tok) >= 3):
            return True
        code_text = json.dumps(code, ensure_ascii=False).lower()
        important = {"q", "n", "mod", "coeff", "coefficient", "poly", "polynomial", "encode", "decode", "compress", "reduce", "add"}
        return bool(set(re.findall(r"[a-zA-Z_][a-zA-Z0-9_]*", t)) & set(re.findall(r"[a-zA-Z_][a-zA-Z0-9_]*", code_text)) & important)

    def _tracked_parameters(self, rich: RichSpecBundle) -> List[str]:
        values = []
        for rec in rich.parameter_table:
            name = first_nonempty(rec.get("name"), rec.get("symbol"), rec.get("parameter"), default="")
            value = first_nonempty(rec.get("value"), rec.get("number"), default="")
            if name:
                values.append(f"{name}={value}" if value not in (None, "") else str(name))
        return unique_strings(values[:20])

    def _parameters_referenced_in_text(self, text: str, rich: RichSpecBundle) -> List[JsonDict]:
        refs = []
        for rec in rich.parameter_table:
            names = [str(first_nonempty(rec.get(k), default="")).strip() for k in ("name", "symbol", "parameter", "constant")]
            if any(name and re.search(r"(?<![A-Za-z0-9_])" + re.escape(name) + r"(?![A-Za-z0-9_])", text) for name in names):
                refs.append(rec)
        return refs[:10]

    def _macro_evidence(self, code: JsonDict) -> List[Any]:
        deps = code.get("dependencies") if isinstance(code.get("dependencies"), dict) else {}
        return [item_evidence(x) for x in as_list(deps.get("relevant_macros_or_constants"))[:12] if isinstance(x, dict)]

    def _function_signature_evidence(self, code: JsonDict) -> List[Any]:
        evs = []
        if isinstance(code.get("function"), dict):
            evs.append(item_evidence(code.get("function")))
        evs.extend(item_evidence(x) for x in as_list(code.get("inputs"))[:5] if isinstance(x, dict))
        evs.extend(item_evidence(x) for x in as_list(code.get("outputs_or_inouts"))[:5] if isinstance(x, dict))
        return [e for e in evs if e]

    def _related_code_evidence_for_type(self, code: JsonDict, ptype: str) -> List[Any]:
        evs: List[Any] = []
        if ptype in {"array_bounds", "loop_bound", "memory_safety", "algorithm_loop_bound"}:
            evs.extend(item_evidence(x) for x in as_list(code.get("array_accesses"))[:5] if isinstance(x, dict))
            evs.extend(item_evidence(x) for x in as_list(code.get("loop_structure"))[:5] if isinstance(x, dict))
        if ptype in {"pointer_validity", "input_pointer_validity", "output_pointer_validity", "memory_safety", "algorithm_io_contract"}:
            evs.extend(item_evidence(x) for x in as_list(code.get("inputs"))[:5] if isinstance(x, dict))
            evs.extend(item_evidence(x) for x in as_list(code.get("outputs_or_inouts"))[:5] if isinstance(x, dict))
        if ptype in {"integer_overflow", "range_safety", "modular_arithmetic", "equation_conformance"}:
            evs.extend(item_evidence(x) for x in as_list(code.get("integer_and_bit_operations"))[:5] if isinstance(x, dict))
        if ptype in {"functional_correctness", "functional_update_shape", "algorithm_functional_step"}:
            evs.extend(item_evidence(x) for x in as_list(code.get("output_writes_and_assignments"))[:5] if isinstance(x, dict))
        return [e for e in evs if e]

    def _default_rejections(self, target: str) -> List[JsonDict]:
        return [
            {"description": "Full ML-KEM key generation, encapsulation, or decapsulation correctness for the entire implementation.", "reason": f"Too broad for selected function-level experiment focused on `{target}`.", "status": "rejected_scope_too_broad", "safe_alternative": "Check small function-level safety or functional properties first."},
            {"description": "The LLM-agent workflow proves the ML-KEM implementation correct.", "reason": "Scientifically unsafe overclaim. Agents generate candidate artifacts; formal tools and human review remain the authority.", "status": "rejected_overclaim", "safe_alternative": "Evaluate usefulness/failure modes of generated candidate artifacts."},
            {"description": "Constant-time/side-channel security is fully verified by CBMC harness generation alone.", "reason": "Constant-time verification needs specialized modeling/tooling and is outside first CBMC prototype unless scoped separately.", "status": "deferred_specialized_security_property", "safe_alternative": "Mention as future work or separate specialized case study."},
        ]

    def _inherited_rejections(self, spec: JsonDict, code: JsonDict) -> List[JsonDict]:
        out = []
        for source_name, data in (("spec_summary", spec), ("code_summary", code)):
            for key in ("rejected_properties", "rejected_or_unsupported_claims"):
                for item in as_list(data.get(key)):
                    text = item_text(item, keys=("claim", "description", "message", "reason"))
                    if text:
                        out.append({"description": text, "reason": first_nonempty(item.get("reason") if isinstance(item, dict) else None, "Rejected/unsupported by previous agent."), "source": source_name, "status": "inherited_rejection_or_unsupported_claim"})
        return out

    def _apply_settings(self, props: List[JsonDict]) -> Tuple[List[JsonDict], List[JsonDict]]:
        max_props = self.settings.get("max_candidate_properties")
        rejected: List[JsonDict] = []
        kept: List[JsonDict] = []
        include_agent2v2 = bool(self.settings.get("include_agent2v2_rich_properties", True))
        include_functional = bool(self.settings.get("include_functional_properties", True))
        include_overflow = bool(self.settings.get("include_overflow_properties", True))
        include_aliasing = bool(self.settings.get("include_aliasing_properties", True))

        for prop in props:
            ptype = prop.get("type")
            reason = None
            if ptype == "integer_overflow" and not include_overflow:
                reason = "Disabled by include_overflow_properties=false."
            elif ptype in {"functional_correctness", "functional_update_shape", "algorithm_functional_step", "equation_conformance"} and not include_functional:
                reason = "Disabled by include_functional_properties=false."
            elif ptype == "aliasing" and not include_aliasing:
                reason = "Disabled by include_aliasing_properties=false."
            elif str(prop.get("source_basis", "")).startswith("agent2v2") and not include_agent2v2:
                reason = "Disabled by include_agent2v2_rich_properties=false."
            if reason:
                rejected.append({"description": prop.get("description", ""), "reason": reason, "source_property_id": prop.get("id"), "status": "excluded_by_settings"})
            else:
                kept.append(prop)

        order = {"high": 0, "medium": 1, "low": 2, "defer": 3, "reject": 4}
        kept.sort(key=lambda p: (order.get(str(p.get("priority", "medium")), 9), str(p.get("type", "")), str(p.get("id", ""))))
        if isinstance(max_props, int) and max_props > 0 and len(kept) > max_props:
            for prop in kept[max_props:]:
                rejected.append({"description": prop.get("description", ""), "reason": f"Excluded because max_candidate_properties={max_props}.", "source_property_id": prop.get("id"), "status": "excluded_by_max_property_limit"})
            kept = kept[:max_props]
        return kept, rejected

    def _consistency_checks(self, spec: JsonDict, code: JsonDict, rich: RichSpecBundle) -> List[JsonDict]:
        checks = []
        for cname in ("N", "q", "k"):
            spec_val = extract_spec_constant(spec, cname, rich)
            code_val = extract_code_constant(code, cname)
            if spec_val is None and code_val is None:
                status, sev, msg = "missing_both", "medium", f"Constant/parameter {cname} was not found in spec/rich parameters or code summaries."
            elif spec_val is None:
                status, sev, msg = "missing_in_spec", "medium", f"Constant/parameter {cname} found in code as {code_val}, but not in spec/rich parameters."
            elif code_val is None:
                status, sev, msg = "missing_in_code", "medium", f"Constant/parameter {cname} found in spec/rich as {spec_val}, but not in code macros/constants."
            else:
                status = "match" if str(spec_val) == str(code_val) else "mismatch"
                sev = "info" if status == "match" else "high"
                msg = f"Constant/parameter {cname}: spec/rich={spec_val}, code={code_val}."
            checks.append({"check": f"constant_{cname}_consistency", "status": status, "severity": sev, "spec_value": spec_val, "code_value": code_val, "message": msg})

        detected = first_nonempty(code.get("target_function_detected"), code.get("target_function_requested"))
        spec_fn = first_nonempty(spec.get("target_function"), self.config.get("target_function"))
        checks.append({"check": "target_function_consistency", "status": "match" if detected == spec_fn else "review_needed", "severity": "info" if detected == spec_fn else "medium", "spec_value": spec_fn, "code_value": detected, "message": f"Spec target function={spec_fn}, code detected function={detected}."})
        relevant = [a for a in rich.algorithm_blocks if self._algorithm_relevant_to_target(a, str(spec_fn or detected or ""), code, rich)]
        checks.append({"check": "agent2v2_relevant_algorithm_available", "status": "available" if relevant else "missing_or_uncertain", "severity": "info" if relevant else "medium", "count": len(relevant), "message": f"Agent 2 v2 relevant algorithm blocks detected: {len(relevant)}."})
        return checks

    def _spec_code_traceability(self, spec: JsonDict, code: JsonDict, rich: RichSpecBundle, props: List[JsonDict]) -> JsonDict:
        target = first_nonempty(code.get("target_function_detected"), code.get("target_function_requested"), spec.get("target_function"), self.config.get("target_function"), default="target_function")
        return {
            "target_function": target,
            "algorithm_blocks_considered": [self._summarize(a, ("algorithm_name", "name", "title", "section")) for a in rich.algorithm_blocks],
            "spec_to_code_hints": [self._summarize(h, ("spec_symbol", "code_symbol", "target_function", "confidence", "text")) for h in rich.spec_to_code_hints],
            "properties_with_agent2v2_evidence": [p.get("id") for p in props if any(as_list(v) for v in (p.get("agent2v2_evidence") or {}).values())],
            "properties_without_code_evidence": [p.get("id") for p in props if not as_list(p.get("code_evidence"))],
            "human_review_questions": [
                "Does the selected algorithm block truly correspond to the target C function?",
                "Are parsed symbols and parameters mapped correctly to code constants/macros?",
                "Are extracted equations/preconditions directly stated in the selected FIPS section or inferred?",
                "Are candidate assumptions too strong for CBMC proof?",
            ],
        }

    def _assumption_bank(self, props: List[JsonDict], spec: JsonDict, rich: RichSpecBundle) -> List[JsonDict]:
        assumptions: List[JsonDict] = []
        for prop in props:
            for a in as_list(prop.get("candidate_assumptions")):
                if isinstance(a, dict):
                    entry = dict(a)
                    entry.setdefault("used_by_properties", [])
                    entry["used_by_properties"] = unique_strings(as_list(entry.get("used_by_properties")) + [str(prop.get("id"))])
                    assumptions.append(entry)
        for item in as_list(spec.get("input_assumptions")):
            text = item_text(item)
            if text:
                assumptions.append({"kind": "spec_extracted_assumption", "text": text, "justification_status": "needs_review", "evidence": evidence_ref(item_evidence(item)), "used_by_properties": ["review_before_use"]})
        for cond in rich.preconditions_postconditions:
            text = item_text(cond)
            kind = str(first_nonempty(cond.get("kind"), cond.get("type"), default="")).lower()
            if text and ("pre" in kind or "require" in kind or "input" in kind):
                assumptions.append({"kind": "agent2v2_precondition_candidate", "text": text, "justification_status": "extracted_from_fips_aware_parser_needs_review", "evidence": evidence_ref(cond), "used_by_properties": ["precondition_validity", "review_before_use"]})
        for rec in rich.parameter_table[:20]:
            name = first_nonempty(rec.get("name"), rec.get("symbol"), default="")
            value = first_nonempty(rec.get("value"), rec.get("number"), default="")
            if name and value not in (None, ""):
                assumptions.append({"kind": "agent2v2_parameter_candidate", "text": f"Parsed parameter `{name}` has candidate value `{value}`.", "justification_status": "must_match_code_before_use", "evidence": evidence_ref(rec), "used_by_properties": ["parameter_consistency"]})
        merged: Dict[str, JsonDict] = {}
        for a in assumptions:
            key = normalize_text(a.get("text", "")).lower()
            if key and key not in merged:
                merged[key] = a
            elif key:
                merged[key]["used_by_properties"] = unique_strings(as_list(merged[key].get("used_by_properties")) + as_list(a.get("used_by_properties")))
        return list(merged.values())

    def _cbmc_plan(self, props: List[JsonDict], code: JsonDict, rich: RichSpecBundle) -> JsonDict:
        hints = code.get("cbmc_hints") if isinstance(code.get("cbmc_hints"), dict) else {}
        checks: List[str] = []
        for prop in props:
            checks.extend(str(c) for c in as_list(prop.get("recommended_cbmc_checks")))
        selected = self._select_first_harness_properties(props)
        return {
            "target_function_for_harness_call": first_nonempty(hints.get("target_function_for_harness_call"), code.get("target_function_detected"), self.config.get("target_function")),
            "suggested_harness_function": first_nonempty(hints.get("suggested_cbmc_function"), f"harness_{self.config.get('target_function', 'target')}"),
            "recommended_checks": unique_strings(checks),
            "unwind_guess": first_nonempty(hints.get("unwind_guess"), self.config.get("cbmc_settings", {}).get("unwind") if isinstance(self.config.get("cbmc_settings"), dict) else None),
            "agent2v2_rich_inputs_used": {
                "algorithm_blocks": len(rich.algorithm_blocks),
                "symbols": len(rich.symbol_table),
                "parameters": len(rich.parameter_table),
                "equations_constraints": len(rich.equations_constraints),
                "prepost": len(rich.preconditions_postconditions),
                "hints": len(rich.spec_to_code_hints),
            },
            "selected_first_harness_property_ids": [p.get("id") for p in selected],
            "first_harness_strategy": [
                "Start with high-priority memory/pointer/bounds properties.",
                "Include parameter consistency when Agent 2 v2 parsed q/n/k values.",
                "Use algorithm loop bounds only after matching to implementation loop bounds.",
                "Add functional/modular property only when assumptions and symbol mapping are documented.",
                "Use --unwinding-assertions.",
            ],
            "do_not_do": [
                "Do not assert full ML-KEM correctness for a single function harness.",
                "Do not add q/n-based assumptions without cited preconditions.",
                "Do not translate a FIPS symbol to C variable unless evidence or human review supports that mapping.",
            ],
        }

    def _group_properties(self, props: List[JsonDict]) -> JsonDict:
        groups: Dict[str, List[str]] = {}
        for p in props:
            groups.setdefault(str(p.get("type", "unspecified")), []).append(str(p.get("id")))
        return groups

    def _select_first_harness_properties(self, props: List[JsonDict]) -> List[JsonDict]:
        selected: List[JsonDict] = []
        preferred = ["parameter_consistency", "spec_code_alignment", "output_pointer_validity", "input_pointer_validity", "algorithm_io_contract", "memory_safety", "array_bounds", "loop_bound", "algorithm_loop_bound"]
        for ptype in preferred:
            for p in props:
                if p.get("type") == ptype and p not in selected:
                    selected.append(p)
        for p in props:
            if p.get("type") in {"functional_update_shape", "functional_correctness", "algorithm_functional_step", "modular_arithmetic", "range_safety"} and p not in selected:
                selected.append(p)
                break
        max_first = self.settings.get("max_first_harness_properties", 8)
        return selected[:max_first] if isinstance(max_first, int) and max_first > 0 else selected

    def _uncertainties(self, spec: JsonDict, code: JsonDict, rich: RichSpecBundle, checks: List[JsonDict], props: List[JsonDict]) -> List[str]:
        out: List[str] = []
        for item in as_list(spec.get("uncertainties")):
            if item_text(item):
                out.append("Spec uncertainty: " + item_text(item))
        for item in as_list(code.get("uncertainties")):
            if item_text(item):
                out.append("Code uncertainty: " + item_text(item))
        for c in checks:
            if c.get("severity") in {"medium", "high"}:
                out.append("Consistency issue: " + str(c.get("message")))
        if rich.missing_files:
            out.append("Agent 2 v2 rich files missing or not generated: " + ", ".join(rich.missing_files))
        if not rich.algorithm_blocks:
            out.append("No Agent 2 v2 algorithm blocks were available; property discovery falls back to legacy spec summary + code summary.")
        if not props:
            out.append("No candidate properties were generated; check Agent 2 and Agent 3 outputs.")
        out.append("Every candidate property still requires Critic Agent review, CBMC/tool execution, and human confirmation.")
        return unique_strings(out)

    def _quality_flags(self, props: List[JsonDict], rejected: List[JsonDict], checks: List[JsonDict], uncertainties: List[str], rich: RichSpecBundle) -> List[JsonDict]:
        flags: List[JsonDict] = []
        if not props:
            flags.append({"severity": "high", "type": "no_properties", "message": "No candidate properties generated."})
        if not any(p.get("priority") == "high" for p in props):
            flags.append({"severity": "medium", "type": "no_high_priority_properties", "message": "No high-priority safety/traceability properties generated."})
        if any(c.get("status") == "mismatch" for c in checks):
            flags.append({"severity": "high", "type": "constant_mismatch", "message": "Spec/code constant mismatch must be resolved before artifact generation."})
        if not rich.algorithm_blocks:
            flags.append({"severity": "medium", "type": "agent2v2_algorithm_blocks_missing", "message": "Rich FIPS algorithm blocks were not available; Agent 4 v2 used fallback logic."})
        if rich.algorithm_blocks and not any(any(as_list(v) for v in (p.get("agent2v2_evidence") or {}).values()) for p in props):
            flags.append({"severity": "medium", "type": "agent2v2_evidence_unused", "message": "Rich Agent 2 v2 files were loaded but not used by candidate properties; check relevance/mapping."})
        if len(uncertainties) > 8:
            flags.append({"severity": "medium", "type": "many_uncertainties", "message": "Several uncertainties remain; keep first CBMC target narrow."})
        return flags

    def _summarize(self, rec: JsonDict, keys: Sequence[str]) -> JsonDict:
        out: JsonDict = {}
        for key in keys:
            if rec.get(key) not in (None, "", [], {}):
                out[key] = rec.get(key)
        return out or {"text": item_text(rec)[:300]}

    def _evidence_matrix_rows(self, result: JsonDict) -> List[JsonDict]:
        rows = []
        for p in as_list(result.get("candidate_properties")):
            if not isinstance(p, dict):
                continue
            a2 = p.get("agent2v2_evidence") if isinstance(p.get("agent2v2_evidence"), dict) else {}
            rows.append({
                "property_id": p.get("id"),
                "type": p.get("type"),
                "priority": p.get("priority"),
                "source_basis": p.get("source_basis"),
                "confidence": p.get("confidence"),
                "has_legacy_spec_evidence": bool(as_list(p.get("spec_evidence"))),
                "has_agent2v2_algorithm_evidence": bool(as_list(a2.get("algorithm_blocks"))),
                "has_agent2v2_parameter_evidence": bool(as_list(a2.get("parameters"))),
                "has_agent2v2_equation_evidence": bool(as_list(a2.get("equations_constraints"))),
                "has_agent2v2_prepost_evidence": bool(as_list(a2.get("preconditions_postconditions"))),
                "has_agent2v2_hint_evidence": bool(as_list(a2.get("spec_to_code_hints"))),
                "has_code_evidence": bool(as_list(p.get("code_evidence"))),
                "human_review_required": p.get("human_review_required", True),
                "description": p.get("description"),
            })
        return rows

    def _traceability_report(self, result: JsonDict, rich: RichSpecBundle) -> JsonDict:
        return {
            "agent": "property_discovery_agent",
            "agent_version": AGENT_VERSION,
            "created_at": utc_now(),
            "target_function": result.get("target_function"),
            "rich_spec_files_loaded": rich.loaded_files,
            "rich_spec_files_missing": rich.missing_files,
            "spec_code_traceability": result.get("spec_code_traceability", {}),
            "evidence_matrix_csv": str(self.evidence_matrix_path),
            "human_review_required": True,
        }

    def _integration_report(self, result: JsonDict, rich: RichSpecBundle) -> JsonDict:
        rich_props = [
            p.get("id") for p in as_list(result.get("candidate_properties"))
            if isinstance(p, dict) and any(as_list(v) for v in (p.get("agent2v2_evidence") or {}).values())
        ]
        return {
            "agent": "property_discovery_agent",
            "agent_version": AGENT_VERSION,
            "created_at": utc_now(),
            "loaded_file_count": len(rich.loaded_files),
            "missing_files": rich.missing_files,
            "rich_counts": {
                "algorithm_blocks": len(rich.algorithm_blocks),
                "symbols": len(rich.symbol_table),
                "parameters": len(rich.parameter_table),
                "equations_constraints": len(rich.equations_constraints),
                "preconditions_postconditions": len(rich.preconditions_postconditions),
                "spec_to_code_hints": len(rich.spec_to_code_hints),
            },
            "candidate_properties_total": len(as_list(result.get("candidate_properties"))),
            "candidate_properties_using_agent2v2_evidence": rich_props,
            "backward_compatibility": {
                "legacy_input_01_spec_summary_json_required": True,
                "legacy_input_02_code_summary_json_required": True,
                "legacy_output_03_candidate_properties_json_preserved": True,
                "legacy_output_03_candidate_properties_md_preserved": True,
                "new_agent2v2_files_are_optional": True,
            },
            "scientific_guardrail": "Agent 2 v2 parsed items and Agent 4 v2 properties are candidate inputs only; CBMC/formal tools and human review remain the authority.",
        }

    def _validate_and_warn(self, result: JsonDict) -> None:
        flags = result.setdefault("quality_flags", [])
        if not result.get("candidate_properties"):
            flags.append({"severity": "high", "type": "empty_candidate_properties", "message": "No candidate properties generated."})
        for prop in as_list(result.get("candidate_properties")):
            if not isinstance(prop, dict):
                flags.append({"severity": "high", "type": "bad_property_shape", "message": "Candidate property is not a JSON object."})
                continue
            for key in ("id", "type", "description", "priority", "formal_tool"):
                if not prop.get(key):
                    flags.append({"severity": "medium", "type": "missing_property_field", "message": f"Property missing field: {key}", "property": prop.get("id")})
            desc = str(prop.get("description", "")).lower()
            if "full ml-kem" in desc or "entire implementation" in desc:
                flags.append({"severity": "high", "type": "possible_overclaim", "message": f"Property {prop.get('id')} may be too broad."})

    def _to_markdown(self, result: JsonDict) -> str:
        lines: List[str] = []
        lines.append("# 03 Candidate Properties")
        lines.append("")
        lines.append("**Agent:** Property Discovery Agent v2")
        lines.append(f"**Agent version:** `{AGENT_VERSION}`")
        lines.append(f"**Target scheme:** {result.get('target_scheme')}")
        lines.append(f"**Target function:** `{result.get('target_function')}`")
        lines.append(f"**Verification tool:** {result.get('verification_tool')}")
        lines.append("")
        lines.append("> Scientific guardrail: these are candidate properties only. CBMC/formal tools and human review remain the authority. No full ML-KEM proof is claimed.")
        lines.append("")
        usage = result.get("agent2v2_usage") if isinstance(result.get("agent2v2_usage"), dict) else {}
        lines.append("## Agent 2 v2 Rich Input Usage")
        lines.append(f"- Algorithm blocks: {usage.get('algorithm_block_count', 0)}")
        lines.append(f"- Symbols: {usage.get('symbol_count', 0)}")
        lines.append(f"- Parameters: {usage.get('parameter_count', 0)}")
        lines.append(f"- Equations/constraints: {usage.get('equation_constraint_count', 0)}")
        lines.append(f"- Pre/post conditions: {usage.get('prepost_count', 0)}")
        lines.append(f"- Spec-to-code hints: {usage.get('spec_to_code_hint_count', 0)}")
        if usage.get("rich_spec_files_missing"):
            lines.append(f"- Missing rich files: {', '.join(str(x) for x in usage.get('rich_spec_files_missing'))}")
        lines.append("")
        lines.append("## First Harness Selection")
        selected = as_list(result.get("first_harness_selection"))
        if selected:
            for prop in selected:
                if isinstance(prop, dict):
                    lines.append(f"- **{prop.get('id')}** `{prop.get('type')}` ({prop.get('priority')}): {prop.get('description')}")
        else:
            lines.append("- No first harness properties selected.")
        lines.append("")
        lines.append("## Candidate Properties")
        for prop in as_list(result.get("candidate_properties")):
            if not isinstance(prop, dict):
                continue
            lines.append(f"### {prop.get('id')} — {prop.get('type')} [{prop.get('priority')}]")
            lines.append("")
            lines.append(prop.get("description", ""))
            lines.append("")
            lines.append(f"- **Source basis:** {prop.get('source_basis')}")
            lines.append(f"- **Confidence:** {prop.get('confidence', 'medium')}")
            lines.append("- **CBMC/check relevance:** " + ", ".join(str(x) for x in as_list(prop.get("recommended_cbmc_checks"))))
            a2 = prop.get("agent2v2_evidence") if isinstance(prop.get("agent2v2_evidence"), dict) else {}
            rich_count = sum(len(as_list(v)) for v in a2.values())
            if rich_count:
                lines.append(f"- **Agent 2 v2 evidence items:** {rich_count}")
            if prop.get("candidate_assumptions"):
                lines.append("- **Candidate assumptions:**")
                for a in as_list(prop.get("candidate_assumptions"))[:5]:
                    if isinstance(a, dict):
                        lines.append(f"  - {a.get('text')} ({a.get('justification_status', 'review')})")
            if prop.get("candidate_assertions_or_checks"):
                lines.append("- **Candidate assertions/checks:**")
                for a in as_list(prop.get("candidate_assertions_or_checks"))[:5]:
                    if isinstance(a, dict):
                        lines.append(f"  - {a.get('text')}")
            lines.append("")
        lines.append("## Assumption Bank")
        for a in as_list(result.get("assumption_bank"))[:50]:
            if isinstance(a, dict):
                lines.append(f"- **{a.get('kind', 'assumption')}**: {a.get('text')} — `{a.get('justification_status', 'review')}`")
        lines.append("")
        lines.append("## CBMC Property Plan")
        plan = result.get("cbmc_property_plan") if isinstance(result.get("cbmc_property_plan"), dict) else {}
        for key in ("target_function_for_harness_call", "suggested_harness_function", "unwind_guess"):
            if key in plan:
                lines.append(f"- **{key}:** {plan.get(key)}")
        if plan.get("recommended_checks"):
            lines.append("- **Recommended checks:** " + ", ".join(str(x) for x in as_list(plan.get("recommended_checks"))))
        lines.append("")
        lines.append("## Consistency Checks")
        for check in as_list(result.get("consistency_checks")):
            if isinstance(check, dict):
                lines.append(f"- **{check.get('check')}** [{check.get('status')} / {check.get('severity')}]: {check.get('message')}")
        lines.append("")
        trace = result.get("spec_code_traceability") if isinstance(result.get("spec_code_traceability"), dict) else {}
        lines.append("## Spec-Code Traceability")
        lines.append(f"- Properties with Agent 2 v2 evidence: {', '.join(str(x) for x in as_list(trace.get('properties_with_agent2v2_evidence'))) or 'None'}")
        lines.append(f"- Properties without code evidence: {', '.join(str(x) for x in as_list(trace.get('properties_without_code_evidence'))) or 'None'}")
        lines.append("")
        lines.append("## Rejected / Deferred Properties")
        for item in as_list(result.get("rejected_properties")):
            if isinstance(item, dict):
                lines.append(f"- **{item.get('status', 'rejected')}**: {item.get('description')} — {item.get('reason')}")
        lines.append("")
        lines.append("## Uncertainties")
        for u in as_list(result.get("uncertainties")):
            lines.append(f"- {u}")
        lines.append("")
        lines.append("## Quality Flags")
        flags = as_list(result.get("quality_flags"))
        if flags:
            for flag in flags:
                if isinstance(flag, dict):
                    lines.append(f"- **{flag.get('severity')} / {flag.get('type')}**: {flag.get('message')}")
        else:
            lines.append("- No major quality flags raised by this agent.")
        lines.append("")
        return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Agent 4 v2: FIPS-aware Property Discovery Agent.")
    parser.add_argument("--config", required=True, help="Path to run config JSON.")
    parser.add_argument("--run-dir", required=False, help="Run directory containing Agent 2/3 outputs.")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    run_dir = Path(args.run_dir).resolve() if args.run_dir else None
    return PropertyDiscoveryAgent(Path(args.config), run_dir).run()


if __name__ == "__main__":
    raise SystemExit(main())
