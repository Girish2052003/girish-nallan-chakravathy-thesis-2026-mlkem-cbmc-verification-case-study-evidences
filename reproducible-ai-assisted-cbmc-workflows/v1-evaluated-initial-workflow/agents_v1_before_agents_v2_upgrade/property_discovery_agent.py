#!/usr/bin/env python3
"""
Agent 4: Property Discovery Agent
=================================

Purpose
-------
This agent combines:
  01_spec_summary.json  -> what the selected specification excerpt appears to require
  02_code_summary.json  -> what the selected implementation code appears to do

and produces:
  03_candidate_properties.json
  03_candidate_properties.md

The output is a prioritized list of CANDIDATE formal-verification properties for a
selected PQC implementation component. For the thesis prototype, the main target is
CBMC-friendly properties such as pointer validity, bounds safety, overflow checks,
and small function-level functional assertions.

Scientific guardrail
--------------------
This agent does NOT prove ML-KEM, does NOT prove the selected function correct, and
DOES NOT treat LLM/static output as truth. It proposes candidate properties that must
be reviewed by the Critic Agent, checked by CBMC/formal tools, and inspected by the
human researcher.

Python: 3.10+
Dependencies: standard library only.

Typical use
-----------
python3 agents/property_discovery_agent.py \
  --config configs/poly_add_run.json \
  --run-dir runs/run_001_poly_add

Expected input files in run-dir
-------------------------------
01_spec_summary.json
02_code_summary.json

Output files
------------
03_candidate_properties.json
03_candidate_properties.md
llm_prompts/03_property_discovery_prompt.txt
agent_status/03_property_discovery_status.json
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


# ---------------------------------------------------------------------------
# Generic utilities
# ---------------------------------------------------------------------------

JsonDict = Dict[str, Any]


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


def safe_str(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    return json.dumps(value, ensure_ascii=False, sort_keys=True)


def normalize_text(value: str) -> str:
    return re.sub(r"\s+", " ", value or "").strip()


def lower_words(value: str) -> List[str]:
    return re.findall(r"[a-zA-Z_][a-zA-Z0-9_]*", (value or "").lower())


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
    # The config usually lives in <project>/configs/file.json.
    parent = config_path.resolve().parent
    if parent.name == "configs":
        return parent.parent
    return parent


def item_text(item: Any, keys: Sequence[str] = ("claim", "description", "message", "summary", "text")) -> str:
    if isinstance(item, str):
        return normalize_text(item)
    if isinstance(item, dict):
        for key in keys:
            if isinstance(item.get(key), str) and item[key].strip():
                return normalize_text(item[key])
        return normalize_text(json.dumps(item, ensure_ascii=False, sort_keys=True))
    return normalize_text(str(item))


def item_type(item: Any, default: str = "unspecified") -> str:
    if isinstance(item, dict):
        for key in ("type", "category", "kind"):
            if isinstance(item.get(key), str) and item[key].strip():
                return item[key].strip()
    return default


def item_evidence(item: Any) -> Any:
    if isinstance(item, dict):
        if "evidence" in item:
            return item.get("evidence")
        # Some entries are themselves evidence objects.
        if "source_file" in item and ("start_line" in item or "line" in item):
            return item
    return None


def unique_dicts_by_text(items: Iterable[JsonDict], text_key: str = "description") -> List[JsonDict]:
    seen: set[str] = set()
    out: List[JsonDict] = []
    for item in items:
        text = normalize_text(str(item.get(text_key, ""))).lower()
        if not text:
            text = sha256_short(json.dumps(item, ensure_ascii=False, sort_keys=True))
        if text in seen:
            continue
        seen.add(text)
        out.append(item)
    return out


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
    "unwinding": "high",
    "integer_overflow": "medium",
    "range_safety": "medium",
    "functional_correctness": "medium",
    "functional_update_shape": "medium",
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
    "unwinding": ["--unwind", "--unwinding-assertions"],
    "integer_overflow": ["--signed-overflow-check", "--unsigned-overflow-check"],
    "range_safety": ["assert range property", "__CPROVER_assume only if justified"],
    "functional_correctness": ["assert functional relation"],
    "functional_update_shape": ["assert output relation"],
    "helper_contract": ["include helper source or safe stub", "assert helper postcondition if selected"],
    "aliasing": ["consider pointer aliasing assumptions only if justified"],
    "tool_compatibility": ["compile harness", "include required headers/sources"],
}


def infer_property_priority(prop_type: str, description: str = "") -> str:
    prop_type_l = (prop_type or "").lower()
    desc_l = (description or "").lower()
    if "full" in desc_l and ("ml-kem" in desc_l or "protocol" in desc_l or "decapsulation" in desc_l):
        return "reject"
    if "constant-time" in desc_l or "side channel" in desc_l or "timing" in desc_l:
        return "defer"
    return PROPERTY_TYPE_PRIORITY.get(prop_type_l, "medium")


def candidate_assumptions_for_type(prop_type: str, code_summary: JsonDict, spec_summary: JsonDict) -> List[JsonDict]:
    function_name = first_nonempty(
        code_summary.get("target_function_detected"),
        code_summary.get("target_function_requested"),
        spec_summary.get("target_function"),
        default="target_function",
    )
    assumptions: List[JsonDict] = []

    if prop_type in {"memory_safety", "pointer_validity", "input_pointer_validity", "output_pointer_validity"}:
        for param in as_list(code_summary.get("inputs")) + as_list(code_summary.get("outputs_or_inouts")):
            if isinstance(param, dict) and param.get("is_pointer"):
                assumptions.append({
                    "kind": "pointer_object_validity",
                    "text": f"`{param.get('name')}` must refer to a valid object for `{function_name}`.",
                    "justification_status": "code_required_precondition_candidate",
                    "evidence": item_evidence(param),
                })

    if prop_type in {"array_bounds", "loop_bound", "memory_safety"}:
        for loop in as_list(code_summary.get("loop_structure")):
            if isinstance(loop, dict) and loop.get("condition"):
                assumptions.append({
                    "kind": "loop_unwinding_bound",
                    "text": f"CBMC unwind bound must cover loop condition `{loop.get('condition')}`.",
                    "justification_status": "derived_from_code_loop_candidate",
                    "evidence": item_evidence(loop),
                })

    if prop_type in {"integer_overflow", "range_safety", "functional_correctness", "functional_update_shape"}:
        q = extract_spec_constant(spec_summary, "q")
        if q is not None:
            assumptions.append({
                "kind": "coefficient_range_precondition",
                "text": f"Coefficient input ranges may need assumptions related to q = {q}, but q alone does not automatically prove a safe input range.",
                "justification_status": "needs_human_and_spec_confirmation",
            })
        else:
            assumptions.append({
                "kind": "coefficient_range_precondition",
                "text": "Coefficient input ranges may be needed before overflow/range assertions can be meaningful.",
                "justification_status": "missing_from_current_spec_summary",
            })

    if prop_type == "aliasing":
        assumptions.append({
            "kind": "aliasing_policy",
            "text": "Do not add non-aliasing assumptions unless implementation/spec context justifies them; aliases may be valid for some C APIs.",
            "justification_status": "must_not_invent",
        })

    return unique_dicts_by_text(assumptions, text_key="text")


def candidate_assertions_for_type(prop_type: str, code_summary: JsonDict, spec_summary: JsonDict) -> List[JsonDict]:
    assertions: List[JsonDict] = []
    function_name = first_nonempty(
        code_summary.get("target_function_detected"),
        code_summary.get("target_function_requested"),
        spec_summary.get("target_function"),
        default="target_function",
    )

    if prop_type in {"array_bounds", "loop_bound"}:
        assertions.append({
            "kind": "cbmc_builtin_check",
            "text": "Use CBMC bounds checking and sufficient unwinding; explicit source assertions may not be needed for basic array bounds.",
        })

    if prop_type in {"memory_safety", "pointer_validity", "input_pointer_validity", "output_pointer_validity"}:
        assertions.append({
            "kind": "cbmc_builtin_check",
            "text": "Use CBMC pointer/bounds checks after constructing valid harness objects.",
        })

    if prop_type == "integer_overflow":
        assertions.append({
            "kind": "cbmc_builtin_check",
            "text": "Use CBMC signed/unsigned overflow checks; separate this from functional equality assertions.",
        })

    if prop_type in {"functional_correctness", "functional_update_shape"}:
        writes = [w for w in as_list(code_summary.get("output_writes_and_assignments")) if isinstance(w, dict)]
        for write in writes[:5]:
            lhs = write.get("lhs")
            rhs = write.get("rhs")
            if lhs and rhs:
                assertions.append({
                    "kind": "candidate_functional_assertion",
                    "text": f"After `{function_name}`, check whether `{lhs}` matches the intended expression `{rhs}` under documented assumptions.",
                    "evidence": item_evidence(write),
                    "warning": "Use pre-state copies for inputs if the output may alias an input pointer.",
                })
        if not assertions:
            assertions.append({
                "kind": "candidate_functional_assertion",
                "text": f"Add a small postcondition assertion for `{function_name}` only after the intended relation is confirmed from spec + code.",
                "warning": "No simple output assignment was detected by the Code Understanding Agent.",
            })

    if prop_type == "range_safety":
        q = extract_spec_constant(spec_summary, "q")
        if q is not None:
            assertions.append({
                "kind": "candidate_range_assertion",
                "text": f"If the selected function promises reduction/range preservation, assert output coefficients are within a justified range related to q = {q}.",
                "warning": "Only assert this for functions whose spec/code actually promises reduction or normalization.",
            })
        else:
            assertions.append({
                "kind": "candidate_range_assertion",
                "text": "If the selected function promises range preservation, assert the documented output coefficient range.",
                "warning": "No q/modulus constant was found in the current spec summary.",
            })

    if prop_type == "helper_contract":
        assertions.append({
            "kind": "helper_postcondition_or_stub_check",
            "text": "For unresolved helper calls, either include the real helper source in CBMC or document a safe stub/contract separately.",
        })

    return unique_dicts_by_text(assertions, text_key="text")


def extract_spec_constant(spec_summary: JsonDict, canonical_name: str) -> Optional[Any]:
    constants = spec_summary.get("constants")
    if not isinstance(constants, dict):
        return None
    aliases = {
        "n": ["N", "n", "KYBER_N", "MLKEM_N"],
        "q": ["q", "Q", "KYBER_Q", "MLKEM_Q"],
    }.get(canonical_name.lower(), [canonical_name])
    for alias in aliases:
        if alias in constants:
            value = constants[alias]
            if isinstance(value, dict) and "value" in value:
                return value.get("value")
            return value
    return None


def extract_code_constant(code_summary: JsonDict, canonical_name: str) -> Optional[Any]:
    aliases = {
        "n": ["N", "KYBER_N", "MLKEM_N", "MLK_N"],
        "q": ["q", "Q", "KYBER_Q", "MLKEM_Q", "MLK_Q"],
    }.get(canonical_name.lower(), [canonical_name])

    deps = code_summary.get("dependencies") if isinstance(code_summary.get("dependencies"), dict) else {}
    macros = deps.get("relevant_macros_or_constants") if isinstance(deps, dict) else []
    for macro in as_list(macros):
        if not isinstance(macro, dict):
            continue
        name = macro.get("name")
        if name in aliases:
            value = macro.get("value")
            parsed = parse_numeric_literal(value)
            return parsed if parsed is not None else value
    return None


def parse_numeric_literal(value: Any) -> Optional[int]:
    if isinstance(value, int):
        return value
    if not isinstance(value, str):
        return None
    s = value.strip()
    if re.fullmatch(r"[-+]?\d+", s):
        try:
            return int(s)
        except Exception:
            return None
    if re.fullmatch(r"0x[0-9a-fA-F]+", s):
        try:
            return int(s, 16)
        except Exception:
            return None
    return None


def evidence_ref(evidence: Any) -> JsonDict:
    if isinstance(evidence, dict):
        out: JsonDict = {}
        for key in ("source_file", "start_line", "end_line", "line", "text"):
            if key in evidence:
                out[key] = evidence[key]
        return out or evidence
    return {}


@dataclasses.dataclass
class PropertyBuilder:
    spec_summary: JsonDict
    code_summary: JsonDict
    config: JsonDict
    settings: JsonDict
    next_id: int = 1

    def make_property(
        self,
        prop_type: str,
        description: str,
        source_basis: str,
        priority: Optional[str] = None,
        spec_evidence: Optional[List[Any]] = None,
        code_evidence: Optional[List[Any]] = None,
        rationale: str = "",
        dependency_notes: Optional[List[str]] = None,
        tags: Optional[List[str]] = None,
    ) -> JsonDict:
        pid = f"P{self.next_id}"
        self.next_id += 1
        priority_final = priority or infer_property_priority(prop_type, description)
        prop: JsonDict = {
            "id": pid,
            "type": prop_type,
            "status": "candidate",
            "priority": priority_final,
            "formal_tool": self.config.get("verification_tool", "CBMC"),
            "description": description,
            "source_basis": source_basis,
            "rationale": rationale or "Generated by combining the selected specification summary and code summary.",
            "spec_evidence": [evidence_ref(e) for e in as_list(spec_evidence) if e],
            "code_evidence": [evidence_ref(e) for e in as_list(code_evidence) if e],
            "candidate_assumptions": candidate_assumptions_for_type(prop_type, self.code_summary, self.spec_summary),
            "candidate_assertions_or_checks": candidate_assertions_for_type(prop_type, self.code_summary, self.spec_summary),
            "recommended_cbmc_checks": CBMC_CHECKS_BY_TYPE.get(prop_type, ["review manually"]),
            "harness_guidance": self.harness_guidance_for_type(prop_type),
            "human_review_required": True,
            "critic_agent_must_check": [
                "assumptions are not too strong",
                "assertions are connected to selected spec and code",
                "property is not trivial/vacuous",
                "CBMC command and unwind bound are suitable",
            ],
            "tags": sorted(set(tags or [])),
        }
        if dependency_notes:
            prop["dependency_notes"] = dependency_notes
        return prop

    def harness_guidance_for_type(self, prop_type: str) -> List[str]:
        hints = self.code_summary.get("cbmc_hints") if isinstance(self.code_summary.get("cbmc_hints"), dict) else {}
        guidance: List[str] = []
        if prop_type in {"pointer_validity", "input_pointer_validity", "output_pointer_validity", "memory_safety"}:
            for hint in as_list(hints.get("object_setup_hints")):
                if isinstance(hint, str):
                    guidance.append(hint)
            if not guidance:
                guidance.append("Create concrete harness objects for pointer parameters before calling the target function.")
        if prop_type in {"array_bounds", "loop_bound", "unwinding", "memory_safety"}:
            unwind = hints.get("unwind_guess")
            if unwind:
                guidance.append(f"Use an unwind bound around {unwind}, then confirm with --unwinding-assertions.")
            else:
                guidance.append("Set CBMC unwind bound according to the detected loop limits.")
        if prop_type in {"integer_overflow", "range_safety", "functional_correctness", "functional_update_shape"}:
            guidance.append("Keep input range assumptions explicit and cite why each assumption is allowed.")
            guidance.append("Separate arithmetic-overflow checks from functional-correctness checks where possible.")
        if prop_type == "helper_contract":
            guidance.append("Include helper source files in the CBMC command or create documented stubs/contracts.")
        if prop_type == "aliasing":
            guidance.append("Before assuming non-aliasing, test or document whether aliases are allowed by the implementation contract.")
        return unique_strings(guidance)


def unique_strings(values: Iterable[str]) -> List[str]:
    seen: set[str] = set()
    out: List[str] = []
    for value in values:
        text = normalize_text(value)
        if not text:
            continue
        key = text.lower()
        if key in seen:
            continue
        seen.add(key)
        out.append(text)
    return out


# ---------------------------------------------------------------------------
# Prompt generation
# ---------------------------------------------------------------------------


def build_structured_prompt(config: JsonDict, spec_summary: JsonDict, code_summary: JsonDict) -> str:
    target_function = first_nonempty(
        code_summary.get("target_function_detected"),
        code_summary.get("target_function_requested"),
        spec_summary.get("target_function"),
        config.get("target_function"),
        default="target_function",
    )
    target_scheme = first_nonempty(config.get("target_scheme"), spec_summary.get("target_scheme"), code_summary.get("target_scheme"), default="PQC scheme")
    verification_tool = config.get("verification_tool", "CBMC")
    verification_goal = config.get("verification_goal", "Generate candidate formal-verification properties.")

    # Keep prompt concise but complete enough for future LLM overlay.
    spec_compact = {
        "constants": spec_summary.get("constants", {}),
        "input_assumptions": spec_summary.get("input_assumptions", [])[:8],
        "candidate_output_guarantees": spec_summary.get("candidate_output_guarantees", [])[:8],
        "candidate_safety_properties": spec_summary.get("candidate_safety_properties", [])[:8],
        "candidate_functional_properties": spec_summary.get("candidate_functional_properties", [])[:8],
        "uncertainties": spec_summary.get("uncertainties", [])[:8],
    }
    code_compact = {
        "function": code_summary.get("function", {}),
        "inputs": code_summary.get("inputs", []),
        "outputs_or_inouts": code_summary.get("outputs_or_inouts", []),
        "loop_structure": code_summary.get("loop_structure", []),
        "array_accesses": code_summary.get("array_accesses", [])[:12],
        "output_writes_and_assignments": code_summary.get("output_writes_and_assignments", [])[:12],
        "possible_properties_from_code": code_summary.get("possible_properties_from_code", [])[:12],
        "implementation_risks": code_summary.get("implementation_risks", []),
        "cbmc_hints": code_summary.get("cbmc_hints", {}),
        "uncertainties": code_summary.get("uncertainties", [])[:8],
    }

    return f"""You are the Property Discovery Agent for an AI-assisted formal-verification artifact workflow.

Target scheme: {target_scheme}
Target function: {target_function}
Verification tool: {verification_tool}
Verification goal: {verification_goal}

Task:
1. Combine the selected specification summary and code summary.
2. Propose candidate formal-verification properties only for the selected function/component.
3. Prioritize memory safety, pointer validity, array bounds, loop bounds, overflow checks, and small functional properties.
4. Reject properties that are too broad, unsupported, or outside the selected function scope.
5. For every property, state assumptions, possible assertions/checks, CBMC relevance, evidence from spec/code, uncertainty, and human-review needs.
6. Do not claim full ML-KEM proof. Do not claim correctness. These are candidate properties only.

Specification summary excerpt:
{json.dumps(spec_compact, indent=2, ensure_ascii=False)}

Code summary excerpt:
{json.dumps(code_compact, indent=2, ensure_ascii=False)}

Return JSON with fields:
- candidate_properties
- rejected_properties
- assumption_bank
- cbmc_property_plan
- consistency_checks
- uncertainties
- scientific_guardrails
"""


# ---------------------------------------------------------------------------
# Property discovery engine
# ---------------------------------------------------------------------------


class PropertyDiscoveryAgent:
    def __init__(self, config_path: Path, run_dir: Optional[Path] = None) -> None:
        self.config_path = config_path.resolve()
        self.config = read_json(self.config_path)
        self.project_root = find_project_root(self.config_path)

        output_root = resolve_path(self.project_root, self.config.get("output_root", "runs"))
        run_id = first_nonempty(self.config.get("run_id"), f"run_{self.config.get('target_function', 'target')}")
        self.run_dir = (run_dir.resolve() if run_dir else (output_root / str(run_id)).resolve())

        settings = self.config.get("property_discovery_settings", {})
        self.settings: JsonDict = settings if isinstance(settings, dict) else {}

        self.spec_summary_path = resolve_path(
            self.project_root,
            self.settings.get("spec_summary_file"),
            fallback=self.run_dir / "01_spec_summary.json",
        )
        self.code_summary_path = resolve_path(
            self.project_root,
            self.settings.get("code_summary_file"),
            fallback=self.run_dir / "02_code_summary.json",
        )

        self.output_json_path = self.run_dir / "03_candidate_properties.json"
        self.output_md_path = self.run_dir / "03_candidate_properties.md"
        self.prompt_path = self.run_dir / "llm_prompts" / "03_property_discovery_prompt.txt"
        self.agent_status_path = self.run_dir / "agent_status" / "03_property_discovery_status.json"
        self.event_log_path = self.run_dir / "events.jsonl"

    def log_event(self, event_type: str, payload: JsonDict) -> None:
        append_jsonl(self.event_log_path, {
            "timestamp": utc_now(),
            "agent": "property_discovery",
            "event_type": event_type,
            **payload,
        })

    def run(self) -> int:
        started_at = utc_now()
        try:
            self.log_event("agent_start", {
                "spec_summary": str(self.spec_summary_path),
                "code_summary": str(self.code_summary_path),
                "output": str(self.output_json_path),
            })

            self._validate_inputs_exist()
            spec_summary = read_json(self.spec_summary_path)
            code_summary = read_json(self.code_summary_path)

            prompt = build_structured_prompt(self.config, spec_summary, code_summary)
            write_text(self.prompt_path, prompt)

            deterministic = self._discover_properties(spec_summary, code_summary, started_at)
            external = self._run_external_property_discovery_if_enabled(prompt)
            if external is not None:
                result = self._merge_external_result(deterministic, external)
                result["discovery_method"] = "deterministic_with_external_overlay"
            else:
                result = deterministic
                result["discovery_method"] = "deterministic_spec_code_merge"

            result["created_at"] = utc_now()
            result["agent_name"] = "property_discovery_agent"
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
                "agent": "property_discovery",
                "status": "passed",
                "started_at": started_at,
                "finished_at": utc_now(),
                "output_json": str(self.output_json_path),
                "output_markdown": str(self.output_md_path),
                "prompt_file": str(self.prompt_path),
                "candidate_property_count": len(result.get("candidate_properties", [])),
                "rejected_property_count": len(result.get("rejected_properties", [])),
                "human_review_required": True,
            }
            write_json(self.agent_status_path, status)
            self.log_event("agent_finish", status)

            print(f"[OK] Property Discovery Agent wrote: {self.output_json_path}")
            print(f"[OK] Markdown summary: {self.output_md_path}")
            print(f"[OK] Candidate properties: {status['candidate_property_count']} | Rejected/deferred: {status['rejected_property_count']}")
            print("[NOTE] These are candidate properties only. CBMC and human review remain required.")
            return 0

        except Exception as e:
            status = {
                "agent": "property_discovery",
                "status": "failed",
                "started_at": started_at,
                "finished_at": utc_now(),
                "error": str(e),
                "traceback": traceback.format_exc(),
                "human_review_required": True,
            }
            write_json(self.agent_status_path, status)
            self.log_event("agent_error", status)
            print(f"[ERROR] Property Discovery Agent failed: {e}", file=sys.stderr)
            print(f"[INFO] Status file: {self.agent_status_path}", file=sys.stderr)
            return 1

    def _validate_inputs_exist(self) -> None:
        missing = []
        if not self.spec_summary_path.exists():
            missing.append(str(self.spec_summary_path))
        if not self.code_summary_path.exists():
            missing.append(str(self.code_summary_path))
        if missing:
            raise FileNotFoundError(
                "Property Discovery Agent needs Agent 2 and Agent 3 outputs first. Missing: " + ", ".join(missing)
            )

    def _discover_properties(self, spec_summary: JsonDict, code_summary: JsonDict, started_at: str) -> JsonDict:
        builder = PropertyBuilder(spec_summary=spec_summary, code_summary=code_summary, config=self.config, settings=self.settings)
        candidate_properties: List[JsonDict] = []
        rejected_properties: List[JsonDict] = []

        target_function = first_nonempty(
            code_summary.get("target_function_detected"),
            code_summary.get("target_function_requested"),
            spec_summary.get("target_function"),
            self.config.get("target_function"),
            default="target_function",
        )

        # 1) Core properties directly from code structure.
        candidate_properties.extend(self._properties_from_code_structure(builder, spec_summary, code_summary, target_function))

        # 2) Properties from specification summary that can be grounded in code.
        candidate_properties.extend(self._properties_from_spec(builder, spec_summary, code_summary, target_function, rejected_properties))

        # 3) Matched spec+code functional update properties.
        matched = self._matched_functional_properties(builder, spec_summary, code_summary, target_function)
        candidate_properties.extend(matched)

        # 4) Tool/harness readiness property if dependencies or helpers are present.
        candidate_properties.extend(self._tool_compatibility_properties(builder, spec_summary, code_summary, target_function))

        # 5) Always reject/defer unsafe broad claims.
        rejected_properties.extend(self._default_rejected_properties(target_function))
        rejected_properties.extend(self._rejected_from_previous_agents(spec_summary, code_summary))

        # Dedupe, filter settings, assign IDs are already assigned by builder, but dedupe by description.
        candidate_properties = unique_dicts_by_text(candidate_properties, text_key="description")

        # Apply settings-based filters.
        candidate_properties, settings_rejections = self._apply_settings(candidate_properties)
        rejected_properties.extend(settings_rejections)

        # Build banks and plans.
        consistency_checks = self._consistency_checks(spec_summary, code_summary)
        assumption_bank = self._assumption_bank(candidate_properties, spec_summary, code_summary)
        cbmc_property_plan = self._cbmc_property_plan(candidate_properties, spec_summary, code_summary)
        property_groups = self._group_properties(candidate_properties)
        first_harness_selection = self._select_first_harness_properties(candidate_properties)
        uncertainties = self._uncertainties(spec_summary, code_summary, consistency_checks, candidate_properties)
        quality_flags = self._quality_flags(candidate_properties, rejected_properties, consistency_checks, uncertainties)

        return {
            "schema_version": "1.0",
            "target_scheme": first_nonempty(self.config.get("target_scheme"), spec_summary.get("target_scheme"), code_summary.get("target_scheme"), default="unknown"),
            "target_function": target_function,
            "verification_goal": self.config.get("verification_goal", ""),
            "verification_tool": self.config.get("verification_tool", "CBMC"),
            "artifact_type": self.config.get("artifact_type", "CBMC harness"),
            "input_files": {
                "spec_summary": str(self.spec_summary_path),
                "code_summary": str(self.code_summary_path),
                "config": str(self.config_path),
            },
            "candidate_properties": candidate_properties,
            "property_groups": property_groups,
            "first_harness_selection": first_harness_selection,
            "assumption_bank": assumption_bank,
            "cbmc_property_plan": cbmc_property_plan,
            "consistency_checks": consistency_checks,
            "rejected_properties": unique_dicts_by_text(rejected_properties, text_key="description"),
            "uncertainties": uncertainties,
            "quality_flags": quality_flags,
            "next_agent_instructions": {
                "formal_artifact_generation_agent": [
                    "Generate a candidate CBMC harness only for selected candidate properties, not all possible broad claims.",
                    "Use assumption_bank entries as candidates and keep every __CPROVER_assume commented and justified.",
                    "Prefer memory safety + simple functional/update-shape properties for the first prototype.",
                    "Do not hide CBMC failures; make artifacts easy for the Critic Agent to review.",
                ],
                "review_critic_agent": [
                    "Check every assumption for over-strength and evidence support.",
                    "Check whether each assertion is meaningful and not vacuous.",
                    "Check whether selected properties match the chosen function scope.",
                ],
            },
            "scientific_guardrails": {
                "properties_are_candidates_only": True,
                "formal_tool_is_final_checker": True,
                "human_review_required": True,
                "no_claim_of_full_mlkem_proof": True,
                "failures_must_be_logged_honestly": True,
                "unsupported_properties_are_rejected_or_deferred": True,
            },
            "agent_runtime": {
                "started_at": started_at,
                "finished_at": utc_now(),
            },
        }

    # ------------------------------------------------------------------
    # Property generation blocks
    # ------------------------------------------------------------------

    def _properties_from_code_structure(
        self,
        builder: PropertyBuilder,
        spec_summary: JsonDict,
        code_summary: JsonDict,
        target_function: str,
    ) -> List[JsonDict]:
        props: List[JsonDict] = []

        inputs = [p for p in as_list(code_summary.get("inputs")) if isinstance(p, dict)]
        outputs = [p for p in as_list(code_summary.get("outputs_or_inouts")) if isinstance(p, dict)]
        arrays = [a for a in as_list(code_summary.get("array_accesses")) if isinstance(a, dict)]
        loops = [l for l in as_list(code_summary.get("loop_structure")) if isinstance(l, dict)]
        operations = [o for o in as_list(code_summary.get("integer_and_bit_operations")) if isinstance(o, dict)]
        writes = [w for w in as_list(code_summary.get("output_writes_and_assignments")) if isinstance(w, dict)]
        helpers = [h for h in as_list(code_summary.get("helper_function_or_macro_calls")) if isinstance(h, dict)]
        pointer_accesses = [p for p in as_list(code_summary.get("pointer_accesses")) if isinstance(p, dict)]

        function_ev = item_evidence(code_summary.get("function")) if isinstance(code_summary.get("function"), dict) else None

        for param in inputs:
            if param.get("is_pointer"):
                props.append(builder.make_property(
                    "input_pointer_validity",
                    f"Input pointer `{param.get('name')}` must be valid and readable when `{target_function}` is called.",
                    source_basis="code",
                    priority="high",
                    code_evidence=[item_evidence(param) or function_ev],
                    rationale="The code signature contains a pointer input. CBMC harness must pass a valid object, otherwise pointer-safety results are meaningless.",
                    tags=["code", "pointer", "precondition"],
                ))

        for param in outputs:
            if param.get("is_pointer"):
                props.append(builder.make_property(
                    "output_pointer_validity",
                    f"Output/in-out pointer `{param.get('name')}` must be valid and writable when `{target_function}` writes through it.",
                    source_basis="code",
                    priority="high",
                    code_evidence=[item_evidence(param) or function_ev],
                    rationale="The code writes through mutable pointer/output parameters. CBMC must check pointer validity while the harness creates valid objects.",
                    tags=["code", "pointer", "memory_safety", "precondition"],
                ))

        if pointer_accesses:
            props.append(builder.make_property(
                "memory_safety",
                f"All pointer field/dereference accesses inside `{target_function}` should be memory-safe under documented harness assumptions.",
                source_basis="code",
                priority="high",
                code_evidence=[item_evidence(p) for p in pointer_accesses[:5]],
                rationale="The selected function uses pointer dereference/field access, so the first CBMC checks should include pointer safety.",
                tags=["code", "memory_safety", "pointer"],
            ))

        if arrays:
            desc = f"All detected array accesses in `{target_function}` should stay within the valid bounds of their base objects."
            if len(arrays) <= 4:
                desc += " Detected accesses: " + ", ".join(str(a.get("expression")) for a in arrays if a.get("expression")) + "."
            props.append(builder.make_property(
                "array_bounds",
                desc,
                source_basis="code",
                priority="high",
                code_evidence=[item_evidence(a) for a in arrays[:8]],
                rationale="Array accesses are direct CBMC bounds-check targets. This is a safe first prototype property because it is implementation-local.",
                tags=["code", "array", "bounds", "memory_safety"],
            ))

        for loop in loops:
            condition = loop.get("condition") or loop.get("raw") or "detected loop"
            props.append(builder.make_property(
                "loop_bound",
                f"Loop `{condition}` in `{target_function}` should be unwound sufficiently and should not drive array indices outside valid bounds.",
                source_basis="code",
                priority="high",
                code_evidence=[item_evidence(loop)],
                rationale="CBMC requires finite loop unwinding. Loop-bound properties connect implementation loops to memory-safety checks.",
                tags=["code", "loop", "unwinding", "bounds"],
            ))

        if operations:
            operation_names: List[str] = []
            operation_evidence: List[Any] = []
            for op in operations:
                operation_names.extend([str(x) for x in as_list(op.get("operations"))])
                operation_evidence.append(item_evidence(op))
            operation_names = unique_strings(operation_names)
            arithmetic_words = {"addition", "subtraction", "multiplication", "shift", "left_shift", "right_shift", "bitwise_and", "bitwise_or", "xor"}
            if any(name.lower() in arithmetic_words or "shift" in name.lower() for name in operation_names):
                props.append(builder.make_property(
                    "integer_overflow",
                    f"Arithmetic/bit operations in `{target_function}` should not trigger undefined or unintended overflow under documented input assumptions.",
                    source_basis="code_plus_spec_needed",
                    priority="medium",
                    code_evidence=operation_evidence[:8],
                    rationale="The code performs integer operations. Overflow safety requires code-level checks and spec-supported input bounds.",
                    tags=["code", "integer", "overflow", "cbmc"],
                ))

        if writes:
            desc = f"The writes performed by `{target_function}` should match the intended function-level update shape under documented assumptions."
            if len(writes) <= 3:
                desc += " Detected write(s): " + "; ".join(f"{w.get('lhs')} = {w.get('rhs')}" for w in writes if w.get("lhs")) + "."
            props.append(builder.make_property(
                "functional_update_shape",
                desc,
                source_basis="code_plus_spec",
                priority="medium",
                code_evidence=[item_evidence(w) for w in writes[:8]],
                spec_evidence=self._functional_spec_evidence(spec_summary),
                rationale="A small function-level postcondition can be generated when code writes and spec behavior line up. This remains a candidate until reviewed.",
                tags=["functional", "postcondition", "code", "spec"],
            ))

        if helpers:
            props.append(builder.make_property(
                "helper_contract",
                f"Helper calls/macros used by `{target_function}` must be included, stubbed, or given documented contracts before CBMC results are trusted.",
                source_basis="code",
                priority="medium",
                code_evidence=[item_evidence(h) for h in helpers[:8]],
                rationale="Unresolved helpers can make a harness fail to compile or make a property scientifically weak.",
                tags=["dependency", "helper", "tool_compatibility"],
            ))

        # Aliasing is important for C pointer functions, but we keep it as medium.
        if len(inputs) + len(outputs) >= 2 and any(p.get("is_pointer") for p in inputs + outputs):
            props.append(builder.make_property(
                "aliasing",
                f"Pointer aliasing behavior for `{target_function}` should be documented before adding non-aliasing assumptions to the harness.",
                source_basis="code_plus_human_review",
                priority="medium",
                code_evidence=[item_evidence(p) for p in (inputs + outputs)[:5]],
                rationale="Many C verification harnesses accidentally become too strong by assuming pointers do not alias. This must be checked instead of invented.",
                tags=["aliasing", "assumption_quality", "c"],
            ))

        return props

    def _properties_from_spec(
        self,
        builder: PropertyBuilder,
        spec_summary: JsonDict,
        code_summary: JsonDict,
        target_function: str,
        rejected_properties: List[JsonDict],
    ) -> List[JsonDict]:
        props: List[JsonDict] = []

        spec_items: List[Tuple[str, Any]] = []
        for key in ("candidate_safety_properties", "candidate_functional_properties", "candidate_output_guarantees"):
            for item in as_list(spec_summary.get(key)):
                spec_items.append((key, item))

        code_text = json.dumps({
            "function": code_summary.get("function", {}),
            "arrays": code_summary.get("array_accesses", []),
            "loops": code_summary.get("loop_structure", []),
            "writes": code_summary.get("output_writes_and_assignments", []),
            "ops": code_summary.get("integer_and_bit_operations", []),
        }, ensure_ascii=False).lower()

        for key, item in spec_items:
            text = item_text(item)
            if not text:
                continue
            text_l = text.lower()
            ptype = item_type(item, default="functional_correctness" if "functional" in key or "guarantee" in key else "memory_safety")

            # Map common wording to stable property types.
            if any(w in text_l for w in ["out-of-bounds", "bounds", "array", "index"]):
                ptype = "array_bounds"
            elif any(w in text_l for w in ["pointer", "valid object", "valid polynomial object"]):
                ptype = "pointer_validity"
            elif any(w in text_l for w in ["overflow", "integer"]):
                ptype = "integer_overflow"
            elif any(w in text_l for w in ["range", "modulus", "modulo", "coefficient"]):
                ptype = "range_safety" if "functional" not in key else "functional_correctness"
            elif "memory" in text_l:
                ptype = "memory_safety"

            supported_by_code = self._spec_item_supported_by_code(text_l, code_text, ptype)
            if not supported_by_code and self.settings.get("reject_spec_items_not_seen_in_code", False):
                rejected_properties.append({
                    "description": text,
                    "reason": "Specification-derived property was not clearly connected to detected code behavior in this run.",
                    "source": "spec_summary",
                    "evidence": evidence_ref(item_evidence(item)),
                    "status": "rejected_for_current_target",
                })
                continue

            priority = infer_property_priority(ptype, text)
            if priority == "reject":
                rejected_properties.append({
                    "description": text,
                    "reason": "Property is too broad or outside the selected function-level scope.",
                    "source": "spec_summary",
                    "evidence": evidence_ref(item_evidence(item)),
                    "status": "rejected",
                })
                continue

            if priority == "defer":
                rejected_properties.append({
                    "description": text,
                    "reason": "Property may be valuable but is deferred because the first CBMC prototype focuses on safety/function-level harnesses, not side-channel verification.",
                    "source": "spec_summary",
                    "evidence": evidence_ref(item_evidence(item)),
                    "status": "deferred",
                })
                continue

            props.append(builder.make_property(
                ptype,
                f"For `{target_function}`, candidate spec-derived property: {text}",
                source_basis="spec" if not supported_by_code else "spec_plus_code",
                priority=priority,
                spec_evidence=[item_evidence(item)],
                code_evidence=self._related_code_evidence_for_type(code_summary, ptype),
                rationale="This property came from the Specification Extraction Agent and is kept only as a candidate if it is suitable for the selected function scope.",
                tags=["spec", ptype],
            ))

        return props

    def _matched_functional_properties(
        self,
        builder: PropertyBuilder,
        spec_summary: JsonDict,
        code_summary: JsonDict,
        target_function: str,
    ) -> List[JsonDict]:
        props: List[JsonDict] = []
        writes = [w for w in as_list(code_summary.get("output_writes_and_assignments")) if isinstance(w, dict)]
        guarantees = as_list(spec_summary.get("candidate_output_guarantees")) + as_list(spec_summary.get("candidate_functional_properties"))
        guarantee_texts = [item_text(g) for g in guarantees]
        joined = "\n".join(guarantee_texts).lower()

        # For poly_add/addition/sum style functions, detect a strong simple property candidate.
        target_l = target_function.lower()
        if writes and ("add" in target_l or "sum" in joined or "addition" in joined or any("+" in str(w.get("rhs", "")) for w in writes)):
            evs = [item_evidence(w) for w in writes[:5]]
            spec_evs = [item_evidence(g) for g in guarantees[:5]]
            props.append(builder.make_property(
                "functional_correctness",
                f"For `{target_function}`, each output update should match the selected addition/sum behavior under documented preconditions.",
                source_basis="matched_spec_plus_code",
                priority="medium",
                spec_evidence=spec_evs,
                code_evidence=evs,
                rationale="The target name/spec language/code writes suggest a small function-level functional property. This should be checked only under reviewed assumptions and preferably with pre-state copies.",
                tags=["functional", "addition", "matched"],
            ))

        # For reduce/modular functions, propose range-preservation only as candidate if language supports it.
        if any(w in target_l for w in ["reduce", "barrett", "montgomery", "csubq"]) or any(w in joined for w in ["reduce", "range", "modulus", "modulo"]):
            props.append(builder.make_property(
                "range_safety",
                f"For `{target_function}`, output coefficient range should match the selected reduction/modulus rule if that rule is explicitly supported by spec and code.",
                source_basis="matched_spec_plus_code",
                priority="medium",
                spec_evidence=[item_evidence(g) for g in guarantees[:5]],
                code_evidence=self._related_code_evidence_for_type(code_summary, "range_safety"),
                rationale="Range properties are useful for ML-KEM polynomial/reduction code, but they must not be asserted unless the function is meant to normalize or reduce values.",
                tags=["range", "modulus", "matched"],
            ))

        # For packing/serialization functions, propose buffer/size properties.
        if any(w in target_l for w in ["tobytes", "frombytes", "pack", "unpack", "encode", "decode", "compress", "decompress"]):
            props.append(builder.make_property(
                "array_bounds",
                f"For `{target_function}`, byte-buffer and polynomial-array accesses should stay within documented packing/unpacking sizes.",
                source_basis="matched_spec_plus_code",
                priority="high",
                spec_evidence=[item_evidence(g) for g in guarantees[:5]],
                code_evidence=self._related_code_evidence_for_type(code_summary, "array_bounds"),
                rationale="Packing/unpacking functions are high-value CBMC targets because many errors are buffer-size or index mistakes.",
                tags=["packing", "buffer", "bounds"],
            ))

        return props

    def _tool_compatibility_properties(
        self,
        builder: PropertyBuilder,
        spec_summary: JsonDict,
        code_summary: JsonDict,
        target_function: str,
    ) -> List[JsonDict]:
        props: List[JsonDict] = []
        deps = code_summary.get("dependencies") if isinstance(code_summary.get("dependencies"), dict) else {}
        helpers = as_list(code_summary.get("helper_function_or_macro_calls"))
        missing_headers = as_list(code_summary.get("missing_header_files"))
        helper_sources = []
        hints = code_summary.get("cbmc_hints") if isinstance(code_summary.get("cbmc_hints"), dict) else {}
        helper_sources.extend(as_list(hints.get("helper_sources_or_stubs_may_be_needed")))

        if missing_headers or helper_sources or helpers:
            evs = [item_evidence(h) for h in helpers[:5] if isinstance(h, dict)]
            props.append(builder.make_property(
                "tool_compatibility",
                f"The CBMC harness for `{target_function}` should include all required headers, helper sources, or safe stubs so that verification results are meaningful.",
                source_basis="code_plus_tool",
                priority="medium",
                code_evidence=evs,
                rationale="A generated property is useless if the tool cannot compile the harness or if unresolved helpers are silently ignored.",
                dependency_notes=[
                    f"Missing header files: {missing_headers}" if missing_headers else "No missing headers reported by Code Understanding Agent.",
                    f"Helper sources/stubs may be needed: {helper_sources}" if helper_sources else "No helper source/stub hints reported.",
                ],
                tags=["tool", "cbmc", "dependency"],
            ))
        return props

    # ------------------------------------------------------------------
    # Analysis support
    # ------------------------------------------------------------------

    def _spec_item_supported_by_code(self, spec_text_l: str, code_text_l: str, prop_type: str) -> bool:
        if prop_type in {"array_bounds", "loop_bound"}:
            return "[" in code_text_l or "loop" in code_text_l or "array" in code_text_l or "coeffs" in code_text_l
        if prop_type in {"pointer_validity", "memory_safety"}:
            return "pointer" in code_text_l or "->" in code_text_l or "*" in code_text_l
        if prop_type in {"integer_overflow", "range_safety"}:
            return any(tok in code_text_l for tok in ["addition", "subtraction", "multiplication", "+", "-", "*", "coeff"])
        if prop_type in {"functional_correctness", "functional_update_shape"}:
            return "lhs" in code_text_l or "rhs" in code_text_l or "assignment" in code_text_l or "write" in code_text_l
        # Keyword overlap fallback.
        spec_words = set(lower_words(spec_text_l))
        code_words = set(lower_words(code_text_l))
        important = spec_words & code_words & {"poly", "polynomial", "coeff", "coeffs", "coefficient", "mod", "q", "n", "add", "reduce"}
        return bool(important)

    def _functional_spec_evidence(self, spec_summary: JsonDict) -> List[Any]:
        out: List[Any] = []
        for key in ("candidate_output_guarantees", "candidate_functional_properties", "input_assumptions"):
            for item in as_list(spec_summary.get(key))[:5]:
                text = item_text(item).lower()
                if any(w in text for w in ["output", "sum", "addition", "corresponding", "coefficient", "modulo", "range", "reduce"]):
                    out.append(item_evidence(item))
        return out

    def _related_code_evidence_for_type(self, code_summary: JsonDict, prop_type: str) -> List[Any]:
        evs: List[Any] = []
        if prop_type in {"array_bounds", "loop_bound", "memory_safety"}:
            evs.extend(item_evidence(x) for x in as_list(code_summary.get("array_accesses"))[:5])
            evs.extend(item_evidence(x) for x in as_list(code_summary.get("loop_structure"))[:5])
        if prop_type in {"pointer_validity", "input_pointer_validity", "output_pointer_validity", "memory_safety"}:
            evs.extend(item_evidence(x) for x in as_list(code_summary.get("inputs"))[:5])
            evs.extend(item_evidence(x) for x in as_list(code_summary.get("outputs_or_inouts"))[:5])
        if prop_type in {"integer_overflow", "range_safety"}:
            evs.extend(item_evidence(x) for x in as_list(code_summary.get("integer_and_bit_operations"))[:5])
        if prop_type in {"functional_correctness", "functional_update_shape"}:
            evs.extend(item_evidence(x) for x in as_list(code_summary.get("output_writes_and_assignments"))[:5])
        return [e for e in evs if e]

    def _default_rejected_properties(self, target_function: str) -> List[JsonDict]:
        return [
            {
                "description": "Full ML-KEM key generation, encapsulation, or decapsulation correctness for the entire implementation.",
                "reason": f"Too broad for a selected function-level experiment focused on `{target_function}`.",
                "status": "rejected_scope_too_broad",
                "safe_alternative": "Check small function-level safety or functional properties first.",
            },
            {
                "description": "The LLM-agent workflow proves the ML-KEM implementation correct.",
                "reason": "Scientifically unsafe overclaim. Agents generate candidate artifacts; formal tools and human review remain the authority.",
                "status": "rejected_overclaim",
                "safe_alternative": "Evaluate usefulness/failure modes of generated candidate artifacts.",
            },
            {
                "description": "Constant-time/side-channel security is fully verified by CBMC harness generation alone.",
                "reason": "Constant-time verification needs specialized modeling/tooling and is outside the first CBMC safety/functionality prototype unless explicitly scoped.",
                "status": "deferred_specialized_security_property",
                "safe_alternative": "Mention as future work or separate specialized case study.",
            },
        ]

    def _rejected_from_previous_agents(self, spec_summary: JsonDict, code_summary: JsonDict) -> List[JsonDict]:
        out: List[JsonDict] = []
        for source_name, data in (("spec_summary", spec_summary), ("code_summary", code_summary)):
            for key in ("rejected_properties", "rejected_or_unsupported_claims"):
                for item in as_list(data.get(key)):
                    text = item_text(item, keys=("claim", "description", "message", "reason"))
                    if not text:
                        continue
                    out.append({
                        "description": text,
                        "reason": first_nonempty(item.get("reason") if isinstance(item, dict) else None, "Rejected/unsupported by previous agent."),
                        "source": source_name,
                        "status": "inherited_rejection_or_unsupported_claim",
                    })
        return out

    def _apply_settings(self, candidate_properties: List[JsonDict]) -> Tuple[List[JsonDict], List[JsonDict]]:
        include_overflow = bool(self.settings.get("include_overflow_properties", True))
        include_functional = bool(self.settings.get("include_functional_properties", True))
        include_aliasing = bool(self.settings.get("include_aliasing_properties", True))
        max_props = self.settings.get("max_candidate_properties")
        first_prototype_only = bool(self.settings.get("first_prototype_focus", False))

        kept: List[JsonDict] = []
        rejected: List[JsonDict] = []
        for prop in candidate_properties:
            ptype = prop.get("type")
            reason = None
            if ptype == "integer_overflow" and not include_overflow:
                reason = "Disabled by property_discovery_settings.include_overflow_properties=false."
            elif ptype in {"functional_correctness", "functional_update_shape"} and not include_functional:
                reason = "Disabled by property_discovery_settings.include_functional_properties=false."
            elif ptype == "aliasing" and not include_aliasing:
                reason = "Disabled by property_discovery_settings.include_aliasing_properties=false."
            elif first_prototype_only and prop.get("priority") not in {"high", "medium"}:
                reason = "Excluded by first_prototype_focus setting."

            if reason:
                rejected.append({
                    "description": prop.get("description", ""),
                    "reason": reason,
                    "source_property_id": prop.get("id"),
                    "status": "excluded_by_settings",
                })
            else:
                kept.append(prop)

        # Order: high first, then medium, low, defer.
        priority_order = {"high": 0, "medium": 1, "low": 2, "defer": 3, "reject": 4}
        kept.sort(key=lambda p: (priority_order.get(str(p.get("priority", "medium")), 9), str(p.get("type", "")), str(p.get("id", ""))))

        if isinstance(max_props, int) and max_props > 0 and len(kept) > max_props:
            overflow = kept[max_props:]
            kept = kept[:max_props]
            for prop in overflow:
                rejected.append({
                    "description": prop.get("description", ""),
                    "reason": f"Excluded because max_candidate_properties={max_props}.",
                    "source_property_id": prop.get("id"),
                    "status": "excluded_by_max_property_limit",
                })
        return kept, rejected

    def _consistency_checks(self, spec_summary: JsonDict, code_summary: JsonDict) -> List[JsonDict]:
        checks: List[JsonDict] = []
        for cname in ("N", "q"):
            spec_value = extract_spec_constant(spec_summary, cname)
            code_value = extract_code_constant(code_summary, cname)
            status = "not_checked"
            severity = "info"
            message = ""
            if spec_value is None and code_value is None:
                status = "missing_both"
                severity = "medium"
                message = f"Constant {cname} was not found in spec or code summaries."
            elif spec_value is None:
                status = "missing_in_spec"
                severity = "medium"
                message = f"Constant {cname} was found in code as {code_value}, but not in spec summary."
            elif code_value is None:
                status = "missing_in_code"
                severity = "medium"
                message = f"Constant {cname} was found in spec as {spec_value}, but not in code macros/constants."
            else:
                status = "match" if str(spec_value) == str(code_value) else "mismatch"
                severity = "info" if status == "match" else "high"
                message = f"Constant {cname}: spec={spec_value}, code={code_value}."
            checks.append({
                "check": f"constant_{cname}_consistency",
                "status": status,
                "severity": severity,
                "spec_value": spec_value,
                "code_value": code_value,
                "message": message,
            })

        detected_function = first_nonempty(code_summary.get("target_function_detected"), code_summary.get("target_function_requested"), default=None)
        spec_function = first_nonempty(spec_summary.get("target_function"), self.config.get("target_function"), default=None)
        checks.append({
            "check": "target_function_consistency",
            "status": "match" if detected_function == spec_function else "review_needed",
            "severity": "info" if detected_function == spec_function else "medium",
            "spec_value": spec_function,
            "code_value": detected_function,
            "message": f"Spec target function={spec_function}, code detected function={detected_function}.",
        })
        return checks

    def _assumption_bank(self, candidate_properties: List[JsonDict], spec_summary: JsonDict, code_summary: JsonDict) -> List[JsonDict]:
        assumptions: List[JsonDict] = []
        for prop in candidate_properties:
            for assump in as_list(prop.get("candidate_assumptions")):
                if isinstance(assump, dict):
                    entry = dict(assump)
                    entry.setdefault("used_by_properties", [])
                    entry["used_by_properties"] = unique_strings(as_list(entry.get("used_by_properties")) + [str(prop.get("id"))])
                    assumptions.append(entry)

        # Add assumptions from spec summary as evidence bank, not necessarily directly as CBMC assumptions.
        for item in as_list(spec_summary.get("input_assumptions")):
            text = item_text(item)
            if text:
                assumptions.append({
                    "kind": "spec_extracted_assumption",
                    "text": text,
                    "justification_status": "supported_by_selected_spec_excerpt" if isinstance(item, dict) and item.get("supported_by_excerpt") else "needs_review",
                    "evidence": evidence_ref(item_evidence(item)),
                    "used_by_properties": ["review_before_use"],
                })

        # Merge by text.
        merged: Dict[str, JsonDict] = {}
        for a in assumptions:
            text = normalize_text(str(a.get("text", "")))
            if not text:
                continue
            key = text.lower()
            if key not in merged:
                merged[key] = a
            else:
                merged[key]["used_by_properties"] = unique_strings(as_list(merged[key].get("used_by_properties")) + as_list(a.get("used_by_properties")))
        return list(merged.values())

    def _cbmc_property_plan(self, candidate_properties: List[JsonDict], spec_summary: JsonDict, code_summary: JsonDict) -> JsonDict:
        hints = code_summary.get("cbmc_hints") if isinstance(code_summary.get("cbmc_hints"), dict) else {}
        checks: List[str] = []
        for prop in candidate_properties:
            checks.extend([str(c) for c in as_list(prop.get("recommended_cbmc_checks"))])
        checks = unique_strings(checks)

        selected_first = self._select_first_harness_properties(candidate_properties)
        return {
            "target_function_for_harness_call": first_nonempty(hints.get("target_function_for_harness_call"), code_summary.get("target_function_detected"), self.config.get("target_function")),
            "suggested_harness_function": first_nonempty(hints.get("suggested_cbmc_function"), f"harness_{self.config.get('target_function', 'target')}") ,
            "recommended_checks": checks,
            "unwind_guess": first_nonempty(hints.get("unwind_guess"), self.config.get("cbmc_settings", {}).get("unwind") if isinstance(self.config.get("cbmc_settings"), dict) else None),
            "selected_first_harness_property_ids": [p.get("id") for p in selected_first],
            "first_harness_strategy": [
                "Start with high-priority memory/pointer/bounds properties.",
                "Add simple functional/update-shape property only when assumptions are clearly documented.",
                "Keep overflow checks enabled but separate overflow failures from functional failures in the final report.",
                "Use --unwinding-assertions so an under-unwound proof is not accepted silently.",
            ],
            "do_not_do": [
                "Do not assert full ML-KEM correctness for a single function harness.",
                "Do not add coefficient range assumptions merely because q exists; cite the specific precondition.",
                "Do not assume non-aliasing unless the C API/spec clearly requires it.",
            ],
        }

    def _group_properties(self, candidate_properties: List[JsonDict]) -> JsonDict:
        groups: Dict[str, List[str]] = {}
        for prop in candidate_properties:
            ptype = str(prop.get("type", "unspecified"))
            groups.setdefault(ptype, []).append(str(prop.get("id")))
        return groups

    def _select_first_harness_properties(self, candidate_properties: List[JsonDict]) -> List[JsonDict]:
        # Strong practical first run: safety first, then one simple functional/update property.
        selected: List[JsonDict] = []
        preferred_types = ["output_pointer_validity", "input_pointer_validity", "memory_safety", "array_bounds", "loop_bound"]
        for ptype in preferred_types:
            for prop in candidate_properties:
                if prop.get("type") == ptype and prop not in selected:
                    selected.append(prop)
        for prop in candidate_properties:
            if prop.get("type") in {"functional_update_shape", "functional_correctness"} and prop not in selected:
                selected.append(prop)
                break
        max_first = self.settings.get("max_first_harness_properties", 6)
        if isinstance(max_first, int) and max_first > 0:
            selected = selected[:max_first]
        return selected

    def _uncertainties(self, spec_summary: JsonDict, code_summary: JsonDict, consistency_checks: List[JsonDict], candidate_properties: List[JsonDict]) -> List[str]:
        uncertainties: List[str] = []
        for item in as_list(spec_summary.get("uncertainties")):
            text = item_text(item)
            if text:
                uncertainties.append("Spec uncertainty: " + text)
        for item in as_list(code_summary.get("uncertainties")):
            text = item_text(item)
            if text:
                uncertainties.append("Code uncertainty: " + text)
        for check in consistency_checks:
            if check.get("severity") in {"medium", "high"}:
                uncertainties.append("Consistency issue: " + str(check.get("message")))
        if not candidate_properties:
            uncertainties.append("No candidate properties were generated; check Agent 2 and Agent 3 outputs.")
        uncertainties.append("Every candidate property still requires Critic Agent review, CBMC/tool execution, and human confirmation.")
        return unique_strings(uncertainties)

    def _quality_flags(
        self,
        candidate_properties: List[JsonDict],
        rejected_properties: List[JsonDict],
        consistency_checks: List[JsonDict],
        uncertainties: List[str],
    ) -> List[JsonDict]:
        flags: List[JsonDict] = []
        if not candidate_properties:
            flags.append({"severity": "high", "type": "no_properties", "message": "No candidate properties generated."})
        high_props = [p for p in candidate_properties if p.get("priority") == "high"]
        if not high_props:
            flags.append({"severity": "medium", "type": "no_high_priority_properties", "message": "No high-priority safety properties generated."})
        if any(c.get("status") == "mismatch" for c in consistency_checks):
            flags.append({"severity": "high", "type": "constant_mismatch", "message": "Spec/code constant mismatch must be resolved before artifact generation."})
        if len(rejected_properties) > 8:
            flags.append({"severity": "info", "type": "many_rejections", "message": "Many properties/claims were rejected or deferred; this can be useful for thesis failure-mode analysis."})
        if len(uncertainties) > 6:
            flags.append({"severity": "medium", "type": "many_uncertainties", "message": "Several uncertainties remain; keep the first CBMC target narrow."})
        return flags

    # ------------------------------------------------------------------
    # Optional external overlay hook
    # ------------------------------------------------------------------

    def _run_external_property_discovery_if_enabled(self, prompt: str) -> Optional[JsonDict]:
        """Optional future hook.

        To keep this agent runnable on day one, no API dependency is required.
        If desired later, the user can configure an external command that reads the prompt
        file path from argv and prints JSON to stdout:

        "property_discovery_settings": {
          "external_command": ["python3", "my_llm_property_discovery.py", "--prompt-file"]
        }

        The command receives the prompt path as the final argument.
        """
        if not self.settings.get("use_external_property_discovery", False):
            return None
        command = self.settings.get("external_command")
        if not isinstance(command, list) or not command:
            self.log_event("external_overlay_skipped", {"reason": "use_external_property_discovery=true but no external_command list configured"})
            return None
        import subprocess

        try:
            full_cmd = [str(x) for x in command] + [str(self.prompt_path)]
            proc = subprocess.run(full_cmd, cwd=str(self.project_root), text=True, capture_output=True, timeout=int(self.settings.get("external_timeout_seconds", 180)))
            self.log_event("external_overlay_command", {
                "command": full_cmd,
                "returncode": proc.returncode,
                "stdout_preview": proc.stdout[:1000],
                "stderr_preview": proc.stderr[:1000],
            })
            if proc.returncode != 0:
                return None
            data = json.loads(proc.stdout)
            return data if isinstance(data, dict) else None
        except Exception as e:
            self.log_event("external_overlay_error", {"error": str(e)})
            return None

    def _merge_external_result(self, deterministic: JsonDict, external: JsonDict) -> JsonDict:
        """Merge safe external suggestions without allowing them to replace guardrails."""
        result = dict(deterministic)
        external_props = external.get("candidate_properties") if isinstance(external.get("candidate_properties"), list) else []
        external_rejected = external.get("rejected_properties") if isinstance(external.get("rejected_properties"), list) else []
        notes = external.get("notes") or external.get("summary")

        if external_props:
            # Store external suggestions separately so the Critic/Human can inspect them.
            result["external_property_suggestions"] = external_props
            result.setdefault("uncertainties", []).append("External property suggestions were stored separately and not trusted automatically.")
        if external_rejected:
            result.setdefault("rejected_properties", []).extend(external_rejected)
        if notes:
            result["external_overlay_notes"] = notes
        # Reassert guardrails after merge.
        result["scientific_guardrails"] = {
            "properties_are_candidates_only": True,
            "formal_tool_is_final_checker": True,
            "human_review_required": True,
            "no_claim_of_full_mlkem_proof": True,
            "failures_must_be_logged_honestly": True,
            "unsupported_properties_are_rejected_or_deferred": True,
        }
        return result

    # ------------------------------------------------------------------
    # Validation and reporting
    # ------------------------------------------------------------------

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
            if "full ml-kem" in str(prop.get("description", "")).lower() or "entire implementation" in str(prop.get("description", "")).lower():
                flags.append({"severity": "high", "type": "possible_overclaim", "message": f"Property {prop.get('id')} may be too broad."})

    def _to_markdown(self, result: JsonDict) -> str:
        lines: List[str] = []
        lines.append("# 03 Candidate Properties")
        lines.append("")
        lines.append(f"**Agent:** Property Discovery Agent")
        lines.append(f"**Target scheme:** {result.get('target_scheme')}")
        lines.append(f"**Target function:** `{result.get('target_function')}`")
        lines.append(f"**Verification tool:** {result.get('verification_tool')}")
        lines.append(f"**Artifact type:** {result.get('artifact_type')}")
        lines.append("")
        lines.append("> Scientific guardrail: these are candidate properties only. CBMC/formal tools and human review remain the authority. No full ML-KEM proof is claimed.")
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
            checks = ", ".join(str(x) for x in as_list(prop.get("recommended_cbmc_checks")))
            lines.append(f"- **CBMC/check relevance:** {checks if checks else 'review manually'}")
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
        for a in as_list(result.get("assumption_bank"))[:40]:
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
    parser = argparse.ArgumentParser(
        description="Agent 4: Property Discovery Agent for AI-assisted formal-verification artifact workflow."
    )
    parser.add_argument("--config", required=True, help="Path to resolved run config JSON.")
    parser.add_argument("--run-dir", required=False, help="Run directory containing 01_spec_summary.json and 02_code_summary.json.")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    run_dir = Path(args.run_dir).resolve() if args.run_dir else None
    agent = PropertyDiscoveryAgent(Path(args.config), run_dir)
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
