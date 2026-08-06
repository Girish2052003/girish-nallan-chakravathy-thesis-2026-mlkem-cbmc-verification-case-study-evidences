#!/usr/bin/env python3
"""
property_discovery_agent_refactored.py

Agent 4 — Property Discovery Agent, refactored for the new thesis workflow.

Architecture implemented:
- Agent 4 consumes Agent 2's LLM-authored spec summary through handoff manifest.
- Agent 4 consumes Agent 3's LLM-authored code summary through handoff manifest.
- Python creates deterministic candidate-property references, but these are advisory only.
- Python builds a strict prompt package.
- The shared LLM client produces the authoritative stage candidate output:
    stages/04_property_discovery/llm_authoritative/03_candidate_properties.json
- Downstream agents consume only manifest-declared handoff outputs.
- No root-level output dumping.
- No duplicate output copies.

Trust boundary:
- Agent 4 does not prove anything.
- Agent 4 does not claim CBMC will verify any property.
- Agent 4 does not claim FIPS compliance, implementation correctness, or cryptographic security.
- Agent 4 only proposes candidate CBMC-style properties, assumptions, risks, and evidence links.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import traceback
from dataclasses import dataclass
from datetime import datetime, timezone
from hashlib import sha256
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
    from agents.common.evidence_contract import canonical_raw_evidence_files, existing_unique_paths, without_keys
    from agents.common.llm_client import LLMClient, LLMStageRequest
    from agents.common.prompt_templates import build_common_stage_prompt
    from agents.common.schemas import CANDIDATE_PROPERTIES_SCHEMA, OPEN_CANDIDATE_PROPERTIES_SCHEMA
    from agents.common.property_catalog import catalogue_summary, get_property_family, resolve_strategy
    from agents.common.property_campaign import validate_candidate_properties_for_campaign
    from agents.common.property_discovery_mode import (
        OPEN_DISCOVERY,
        classify_open_candidates,
        effective_campaign_from_selected,
        is_open_discovery,
        select_open_candidate,
    )
except Exception as import_exc:  # pragma: no cover
    raise SystemExit(
        "Failed to import shared workflow modules. Ensure these files exist and schemas.py includes CANDIDATE_PROPERTIES_SCHEMA:\n"
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


def extract_content_wrapper(data: JsonDict) -> JsonDict:
    """
    Shared llm_client writes:
      {"schema_version": ..., "content": {...}}
    This helper returns content if present, otherwise original dict.
    """
    content = data.get("content")
    if isinstance(content, dict):
        return content
    return data


def safe_json_preview(data: Any, max_chars: int = 40_000) -> str:
    text = json.dumps(data, indent=2, ensure_ascii=False)
    if len(text) > max_chars:
        return text[:max_chars] + "\n[TRUNCATED_JSON_PREVIEW]\n"
    return text


def parse_list_arg(value: Optional[str]) -> List[str]:
    if not value:
        return []
    parts = re.split(r"[,;]", value)
    return [p.strip() for p in parts if p.strip()]


def write_csv(path: PathLike, rows: List[Mapping[str, Any]], fieldnames: Optional[List[str]] = None) -> Path:
    p = Path(path)
    ensure_dir(p.parent)
    if fieldnames is None:
        keys = []
        for row in rows:
            for key in row.keys():
                if key not in keys:
                    keys.append(key)
        fieldnames = keys or ["empty"]

    with p.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: row.get(k, "") for k in fieldnames})
    return p


def flatten_strings(obj: Any, limit: int = 2000) -> List[str]:
    out: List[str] = []

    def walk(x: Any) -> None:
        if len(out) >= limit:
            return
        if isinstance(x, str):
            if x.strip():
                out.append(x.strip())
        elif isinstance(x, dict):
            for v in x.values():
                walk(v)
        elif isinstance(x, list):
            for v in x:
                walk(v)

    walk(obj)
    return out


def contains_any(text: str, terms: Sequence[str]) -> bool:
    low = text.lower()
    return any(t.lower() in low for t in terms)


def score_terms(text: str, terms: Sequence[str]) -> int:
    low = text.lower()
    return sum(1 for t in terms if t.lower() in low)


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

@dataclass
class PropertyDiscoveryConfig:
    run_dir: Path
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM candidate CBMC property discovery"
    llm_mode_override: Optional[str] = None
    allow_missing_agent2_or_agent3: bool = False
    allow_empty_handoff_on_failure: bool = True
    max_previous_stage_preview_chars: int = 80_000
    discovery_mode: str = "targeted_campaign"
    property_family_id: str = "P16"
    verification_strategy: str = "standard_cbmc_harness"
    property_support_level: str = "production_supported"

    property_focus: List[str] = None  # type: ignore

    def __post_init__(self) -> None:
        if self.property_focus is None:
            self.property_focus = [
                "array_bounds",
                "memory_safety",
                "pointer_validity",
                "non_aliasing",
                "integer_overflow",
                "arithmetic_range",
                "coefficient_range",
                "local_functional_postcondition",
                "old_state_new_state",
                "contract_consistency",
                "loop_bound",
                "serialization_safety",
                "buffer_length",
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


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, PropertyDiscoveryConfig]:
    config_data: JsonDict = {}
    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        config_data = load_normalized_config(config_path)

    run_dir = resolve_run_dir(config_data, args)

    target_function = (
        args.target_function
        or str(config_data.get("target_function") or "")
        or str(config_data.get("function_name") or "")
        or "mlk_poly_add"
    )

    target_topic = (
        args.target_topic
        or str(config_data.get("target_topic") or "")
        or f"CBMC candidate property discovery for {target_function}"
    )

    focus = parse_list_arg(args.property_focus)
    if not focus:
        cfg_focus = (
            config_data.get("property_discovery", {}).get("property_focus")
            if isinstance(config_data.get("property_discovery"), dict)
            else None
        )
        if isinstance(cfg_focus, list):
            focus = [str(x) for x in cfg_focus]

    allow_missing = bool(
        args.allow_missing_inputs
        or (
            isinstance(config_data.get("property_discovery"), dict)
            and config_data.get("property_discovery", {}).get("allow_missing_agent2_or_agent3")
        )
    )

    campaign = config_data.get("property_campaign", {}) if isinstance(config_data.get("property_campaign"), dict) else {}
    cfg = PropertyDiscoveryConfig(
        run_dir=run_dir,
        target_function=target_function,
        target_topic=target_topic,
        llm_mode_override=args.llm_mode,
        allow_missing_agent2_or_agent3=allow_missing,
        discovery_mode=str((config_data.get("property_discovery") or {}).get("mode") or "targeted_campaign"),
        property_family_id=str(campaign.get("property_family_id") or "P16"),
        verification_strategy=str(campaign.get("verification_strategy") or "standard_cbmc_harness"),
        property_support_level=str(campaign.get("support_level") or "production_supported"),
        property_focus=focus or None,  # type: ignore
    )
    return config_data, cfg


# ---------------------------------------------------------------------------
# Previous-stage handoff consumption
# ---------------------------------------------------------------------------

def load_handoff_json(layout: RunLayout, producer_stage: str, output_key: str) -> Tuple[Optional[Path], Optional[JsonDict], JsonDict]:
    status = {
        "producer_stage": producer_stage,
        "output_key": output_key,
        "available": False,
        "path": None,
        "warning": None,
    }

    try:
        path = layout.get_handoff(producer_stage, output_key)
        status["path"] = str(path)
        if not path.exists():
            status["warning"] = "Handoff path exists in manifest but file is missing."
            return path, None, status

        data = extract_content_wrapper(read_json_file(path))
        status["available"] = True
        return path, data, status
    except Exception as exc:
        status["warning"] = f"Could not load handoff: {type(exc).__name__}: {exc}"
        return None, None, status


# ---------------------------------------------------------------------------
# Deterministic advisory property discovery
# ---------------------------------------------------------------------------

def make_property(
    *,
    property_id: str,
    title: str,
    category: str,
    candidate_statement: str,
    evidence_basis: List[str],
    assumptions: List[str],
    feasibility: str,
    risk: str,
    cbmc_relevance: str,
    limitations: List[str],
) -> JsonDict:
    category_family = {
        "memory_safety": "P01",
        "array_bounds": "P01",
        "integer_overflow": "P09",
        "local_functional_consistency": "P16",
        "pointer_validity_and_aliasing": "P15",
        "contract_consistency": "P26",
    }.get(category, "P16")
    family = get_property_family(category_family)
    return {
        "property_id": property_id,
        "property_family_id": family["id"],
        "title": title,
        "category": category,
        "verification_strategy": family["default_strategy"],
        "proof_obligation_kind": "safety" if category in {"memory_safety", "array_bounds", "integer_overflow"} else "functional",
        "support_classification": family["support_level"],
        "required_tool_capabilities": [family["default_strategy"]],
        "candidate_statement": candidate_statement,
        "evidence_basis": evidence_basis,
        "required_assumptions": assumptions,
        "feasibility": feasibility,
        "risk": risk,
        "cbmc_relevance": cbmc_relevance,
        "limitations": limitations,
        "trust_boundary": "deterministic_reference_advisory_only",
    }


def infer_deterministic_candidate_properties(
    *,
    cfg: PropertyDiscoveryConfig,
    spec_summary: Optional[JsonDict],
    code_summary: Optional[JsonDict],
) -> JsonDict:
    """
    Create advisory candidate properties from simple keyword/evidence patterns.

    This is intentionally not authoritative.
    The LLM must verify, reject, refine, or replace these candidates.
    """
    spec_strings = flatten_strings(spec_summary or {})
    code_strings = flatten_strings(code_summary or {})
    all_spec_text = "\n".join(spec_strings)
    all_code_text = "\n".join(code_strings)
    combined = all_spec_text + "\n" + all_code_text

    properties: List[JsonDict] = []
    rejected_or_downgraded: List[JsonDict] = []
    trace_rows: List[JsonDict] = []
    risk_rows: List[JsonDict] = []

    target = cfg.target_function

    # Always useful for CBMC C-level harnesses if a function pointer/array operation exists.
    if code_summary is not None:
        properties.append(make_property(
            property_id="P_MEM_001",
            title="Pointer validity and memory readability/writability for target function arguments",
            category="memory_safety",
            candidate_statement=(
                f"Candidate harness assumptions may require valid readable/writable memory for "
                f"objects passed to {target}, according to the actual function signature."
            ),
            evidence_basis=["Agent 3 code summary / raw code should confirm pointer parameters and accessed fields."],
            assumptions=["Object sizes and pointer validity must match the actual C type definitions."],
            feasibility="high",
            risk="medium",
            cbmc_relevance="CBMC can check invalid pointer dereference and memory-safety failures under harness assumptions.",
            limitations=["Advisory only until LLM verifies exact function signature and memory accesses."],
        ))

    if contains_any(combined, ["mlkem_n", "256", "coeffs", "array", "index", "loop"]):
        properties.append(make_property(
            property_id="P_ARR_001",
            title="Array-index safety for coefficient loop",
            category="array_bounds",
            candidate_statement=(
                f"Candidate property: loops or accesses associated with {target} should not access "
                "coefficient arrays outside their declared bounds."
            ),
            evidence_basis=["Detected terms such as MLKEM_N, coeffs, array/index/loop, or n=256 in previous-stage outputs."],
            assumptions=["Loop bound and coefficient array length must be verified from raw source/header files."],
            feasibility="high",
            risk="low",
            cbmc_relevance="CBMC is suitable for bounded C array-index safety checks.",
            limitations=["Does not prove mathematical correctness of polynomial operation."],
        ))

    if contains_any(combined, ["int16_t", "uint16_t", "overflow", "range", "coeff", "3329", "mlkem_q"]):
        properties.append(make_property(
            property_id="P_ARITH_001",
            title="Arithmetic range / overflow under explicit coefficient assumptions",
            category="integer_overflow_or_range",
            candidate_statement=(
                f"Candidate property: arithmetic inside {target} should avoid C integer overflow "
                "under explicit coefficient-range assumptions."
            ),
            evidence_basis=["Detected integer types, coefficient terminology, range/modulus constants, or overflow-related hints."],
            assumptions=[
                "Input coefficient ranges must be stated explicitly.",
                "C integer promotions and casts must be checked from raw implementation code.",
            ],
            feasibility="medium",
            risk="medium",
            cbmc_relevance="CBMC can check signed overflow and arithmetic assertions under bounded assumptions.",
            limitations=[
                "Strong assumptions may be required.",
                "Success would not prove full ML-KEM arithmetic correctness."
            ],
        ))

    if contains_any(combined, ["old-state", "old_state", "new-state", "new_state", "in place", "inplace", "mutates", "modified memory", "r->coeffs", "r.coeffs", "coeffs[i]"]):
        properties.append(make_property(
            property_id="P_FUNC_001",
            title="Local functional relation with old-state snapshot",
            category="local_functional_consistency",
            candidate_statement=(
                f"Candidate property: after {target}, each affected output coefficient should match "
                "a local relation between the old output state and input state, if supported by code/spec evidence."
            ),
            evidence_basis=[
                "Detected possible mutation/in-place-update or coefficient assignment hints in Agent 3 output."
            ],
            assumptions=[
                "The harness must snapshot old output state before calling the function.",
                "The property must not use post-call values on both sides of the assertion.",
            ],
            feasibility="medium",
            risk="medium",
            cbmc_relevance="CBMC can check local post-call assertions if old-state values are stored explicitly.",
            limitations=[
                "The exact mathematical relation must be verified from raw code and specification evidence.",
                "This is local functional consistency only, not full FIPS compliance."
            ],
        ))

    if contains_any(combined, ["memory_no_alias", "alias", "non-alias", "non_alias", "separate", "overlap"]):
        properties.append(make_property(
            property_id="P_ALIAS_001",
            title="Non-aliasing assumptions for input/output objects",
            category="pointer_validity_and_aliasing",
            candidate_statement=(
                f"Candidate property or assumption: if {target} requires non-overlapping objects, "
                "the harness must state the aliasing condition explicitly."
            ),
            evidence_basis=["Detected aliasing-related terms in previous-stage outputs or contracts."],
            assumptions=["Actual aliasing requirements must be verified from function contracts/source comments."],
            feasibility="medium",
            risk="high",
            cbmc_relevance="CBMC harnesses can encode aliasing/non-aliasing assumptions.",
            limitations=["Over-strong non-aliasing assumptions can hide real behaviours and must be reviewed carefully."],
        ))

    if contains_any(combined, ["requires", "ensures", "__cprover", "contract", "assert", "assume"]):
        properties.append(make_property(
            property_id="P_CONTRACT_001",
            title="Consistency with existing contracts or annotations",
            category="contract_consistency",
            candidate_statement=(
                f"Candidate property: generated harness assumptions/assertions for {target} should be "
                "consistent with existing source-level contracts or CBMC annotations where present."
            ),
            evidence_basis=["Detected contract/assertion/assumption-related terms in code summary."],
            assumptions=["Existing annotations must be verified from raw headers/source files."],
            feasibility="medium",
            risk="medium",
            cbmc_relevance="Can guide harness assumptions and avoid contradicting repository contracts.",
            limitations=["Existing contracts are evidence, not proof; they may be assumptions rather than established facts."],
        ))

    # Always include the configured property family as an explicit campaign candidate.
    configured_family = get_property_family(cfg.property_family_id)
    configured_strategy = resolve_strategy(configured_family, cfg.verification_strategy)
    properties.insert(0, {
        "property_id": f"{configured_family['id']}_CAMPAIGN_001",
        "property_family_id": configured_family["id"],
        "title": configured_family["title"],
        "category": configured_family["slug"],
        "verification_strategy": configured_strategy,
        "proof_obligation_kind": (
            "loop_contract" if configured_strategy == "native_loop_contract" else
            "function_contract" if configured_strategy == "native_function_contract" else
            "relational" if configured_strategy == "relational_cbmc_harness" else
            "analysis_only" if configured_strategy == "analysis_only_no_formal_claim" else
            "functional"
        ),
        "support_classification": configured_family["support_level"],
        "required_tool_capabilities": [configured_strategy],
        "candidate_statement": (
            f"Candidate {configured_family['title']} obligation for {cfg.target_function}; the exact statement, "
            "bounds, assumptions and representation must be derived from primary FIPS/code evidence."
        ),
        "evidence_basis": ["Configured from the canonical 26-property thesis catalogue."],
        "required_assumptions": [],
        "feasibility": "unknown",
        "risk": "high" if configured_family["difficulty"] == "hard" else "medium",
        "cbmc_relevance": configured_strategy,
        "limitations": [configured_family["claim_boundary"]],
        "trust_boundary": "deterministic_reference_advisory_only",
    })

    # Broad properties that must be downgraded/rejected.
    broad_claims = [
        ("BROAD_001", "Full ML-KEM correctness", "Reject/downgrade: too broad for this stage and not a local CBMC property."),
        ("BROAD_002", "Full FIPS 203 compliance", "Reject/downgrade: cannot be established by a local C harness."),
        ("BROAD_003", "Cryptographic security / IND-CCA security", "Reject/downgrade: outside CBMC C-level local property scope."),
        ("BROAD_004", "Full side-channel resistance", "Reject/downgrade: not supported by this workflow stage unless narrowly scoped and separately evidenced."),
        ("BROAD_005", "Whole-program correctness", "Reject/downgrade: too broad for selected-function CBMC case study."),
    ]

    for pid, title, reason in broad_claims:
        rejected_or_downgraded.append({
            "property_id": pid,
            "title": title,
            "decision": "reject_or_downgrade",
            "reason": reason,
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    # Evidence matrix rows.
    for prop in properties:
        trace_rows.append({
            "property_id": prop["property_id"],
            "category": prop["category"],
            "title": prop["title"],
            "spec_evidence_available": bool(spec_summary),
            "code_evidence_available": bool(code_summary),
            "feasibility": prop["feasibility"],
            "risk": prop["risk"],
            "requires_llm_verification": True,
            "trust_boundary": "deterministic_reference_advisory_only",
        })
        risk_rows.append({
            "property_id": prop["property_id"],
            "risk": prop["risk"],
            "risk_reason": "; ".join(prop["limitations"][:3]),
            "human_review_needed": prop["risk"] in {"medium", "high"},
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    summary = {
        "stage": "04_property_discovery",
        "mode": "deterministic_reference_only",
        "trust_boundary": "advisory_only_not_authoritative",
        "target_function": cfg.target_function,
        "target_topic": cfg.target_topic,
        "spec_summary_available": bool(spec_summary),
        "code_summary_available": bool(code_summary),
        "candidate_property_count": len(properties),
        "rejected_or_downgraded_count": len(rejected_or_downgraded),
        "warning": (
            "These deterministic candidate properties are advisory only. The LLM must verify, refine, "
            "downgrade, reject, or replace them against the primary and previous-stage evidence."
        ),
    }

    return {
        "03_candidate_properties_deterministic": {
            "summary": summary,
            "candidate_properties": properties,
            "rejected_or_downgraded_properties": rejected_or_downgraded,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "03_property_evidence_matrix": {
            "rows": trace_rows,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "03_spec_code_traceability": {
            "target_function": cfg.target_function,
            "spec_summary_available": bool(spec_summary),
            "code_summary_available": bool(code_summary),
            "candidate_trace_items": trace_rows,
            "warning": "Traceability is advisory only until LLM and human review.",
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "03_property_risk_register": {
            "rows": risk_rows,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "03_property_filtering_decisions": {
            "rejected_or_downgraded_properties": rejected_or_downgraded,
            "scope_policy": {
                "prefer": [
                    "array bounds",
                    "buffer length constraints",
                    "pointer validity",
                    "non-aliasing assumptions",
                    "bounded loop safety",
                    "integer-overflow/range checks under stated assumptions",
                    "coefficient range preservation",
                    "local function postconditions",
                    "contract consistency",
                ],
                "avoid_or_downgrade": [
                    "full ML-KEM correctness",
                    "full FIPS 203 compliance",
                    "cryptographic security",
                    "IND-CCA security",
                    "whole-program correctness",
                    "full side-channel resistance",
                    "full NTT correctness unless narrowly scoped",
                ],
            },
            "trust_boundary": "deterministic_reference_advisory_only",
        },
    }


def write_deterministic_reference_files(layout: RunLayout, deterministic: JsonDict) -> Dict[str, Path]:
    stage = "04_property_discovery"
    paths: Dict[str, Path] = {}

    file_map = {
        "candidate_properties_deterministic": ("03_candidate_properties.deterministic.json", "03_candidate_properties_deterministic"),
        "property_evidence_matrix": ("03_property_evidence_matrix.deterministic.json", "03_property_evidence_matrix"),
        "spec_code_traceability": ("03_spec_code_traceability.deterministic.json", "03_spec_code_traceability"),
        "property_risk_register": ("03_property_risk_register.deterministic.json", "03_property_risk_register"),
        "property_filtering_decisions": ("03_property_filtering_decisions.deterministic.json", "03_property_filtering_decisions"),
    }

    for key, (filename, data_key) in file_map.items():
        paths[key] = layout.write_deterministic_reference_json(
            stage,
            filename,
            deterministic[data_key],
        )

    # CSV views for human-friendly inspection.
    evidence_rows = deterministic["03_property_evidence_matrix"]["rows"]
    risk_rows = deterministic["03_property_risk_register"]["rows"]

    paths["property_evidence_matrix_csv"] = write_csv(
        layout.deterministic_reference_dir(stage) / "03_property_evidence_matrix.deterministic.csv",
        evidence_rows,
    )
    paths["property_risk_register_csv"] = write_csv(
        layout.deterministic_reference_dir(stage) / "03_property_risk_register.deterministic.csv",
        risk_rows,
    )

    return paths


# ---------------------------------------------------------------------------
# Prompt generation
# ---------------------------------------------------------------------------

def _semantic_property_schema_summary() -> str:
    return """  - property_id
  - statement
  - target_call.function
  - target_call.arguments
  - pre_state_objects
  - post_state_objects
  - observed_memory
  - permitted_writes
  - required_assumptions
  - success_predicate
  - quantified_domain.variable
  - quantified_domain.lower_bound
  - quantified_domain.upper_bound_exclusive
  - requires_pre_state_snapshot
  - requires_modular_call_replacement
  - requires_loop_reasoning
  - requires_relational_execution
  - analysis_only
  - evidence_references
  - uncertainty"""


def build_agent4_prompt(*, cfg: PropertyDiscoveryConfig, spec_available: bool, code_available: bool) -> str:
    if cfg.discovery_mode == OPEN_DISCOVERY:
        responsibilities = """
- Independently identify any local, evidence-grounded verification properties relevant to the selected C function.
- Do not limit discovery to familiar property categories or to examples implied by pipeline configuration.
- Preserve distinct candidates even when they concern different semantic aspects of the function.
- Preserve genuinely novel candidates rather than forcing them into an existing classification.
- State every required assumption explicitly.
- Rank candidates by scientific relevance and evidence quality; feasibility is advisory and must not silently choose a harness, contract, or tool strategy.
- For every candidate, provide a strategy-neutral semantic_property record defining the exact target call, pre/post-state objects, observed memory, permitted writes, quantified domain, assumptions, and success predicate.
- Explicitly state whether modular call replacement, loop reasoning, relational execution, or analysis-only treatment is genuinely required.
- You may list possible encodings as advisory alternatives, but must not choose the executable strategy.
- Mark speculative, broad, unsupported, risky, or out-of-scope candidates clearly.
- Provide evidence references for every major candidate property.
""".strip()
    else:
        responsibilities = """
- Identify candidate memory-safety properties.
- Identify candidate pointer-validity and non-aliasing properties.
- Identify candidate array-bounds properties.
- Identify candidate integer-overflow or arithmetic-range properties.
- Identify candidate coefficient-range properties.
- Identify candidate serialization/deserialization size properties where relevant.
- Identify candidate local functional-consistency properties.
- Identify candidate contract-consistency properties.
- Identify candidate loop-invariant ideas.
- Identify candidate assumptions needed for later CBMC artefacts.
- Rank or classify candidate properties by feasibility where the schema allows.
- Mark speculative, risky, broad, unsupported, or out-of-scope properties clearly.
- Provide evidence references for every major candidate property.
- Include required assumptions, feasibility rating, risk rating, and why each property is realistic for C-level checking.
""".strip()

    prohibitions = """
- Do not claim that a property is proven.
- Do not claim that CBMC can definitely verify the property.
- Do not generate final CBMC harness code.
- Do not generate final assertions.
- Do not claim full ML-KEM correctness.
- Do not claim full FIPS 203 compliance.
- Do not claim cryptographic security, IND-CCA security, or side-channel resistance.
- Do not claim whole-program correctness.
- Do not broaden a local property into a global correctness/security claim.
- Do not hide missing evidence or uncertainty.
""".strip()

    availability = f"""
Previous-stage availability:
- Agent 2 LLM specification summary available: {spec_available}
- Agent 3 LLM code summary available: {code_available}

If either previous-stage summary is missing, record the missing evidence and restrict the property claims accordingly.
""".strip()

    semantic_schema = _semantic_property_schema_summary()
    if cfg.discovery_mode == OPEN_DISCOVERY:
        task = f"""
This stage performs independent open property discovery from the supplied FIPS, source, header, comment, contract, and previous-stage candidate evidence.

Target function: {cfg.target_function}
Target topic: {cfg.target_topic}
Discovery mode: open_discovery

No predefined property taxonomy, campaign category, category description, or artefact-construction approach is available in this mode. Do not assume one. Discover a broad but local set of evidence-grounded properties that may span different categories. Preserve genuinely novel candidates instead of forcing them into a pre-existing category.

{availability}

Your role is not to prove anything and not to generate final CBMC code. Propose realistic local properties, assumptions, risks, uncertainties, and evidence. Later deterministic processing may classify the saved candidate set for experiment organization, but that later classification must not influence this discovery.

Candidate identifiers must be stable within this response, for example OPEN_CAND_001, OPEN_CAND_002, and so on. Do not reuse identifiers from any external taxonomy. Describe the semantic property precisely; later stages will choose a concrete artefact-construction approach from the semantic record rather than from category words.

The semantic_property must not contain executable C or CBMC syntax except a concise success_predicate expression when primary evidence makes it unambiguous. Do not invent syntax. If an executable predicate is uncertain, leave it empty and record the uncertainty instead of guessing.
""".strip()
        schema_summary = f"""
Top-level required fields:
- stage
- source_scope
- candidate_properties
- rejected_or_downgraded_properties
- assumptions_catalogue
- feasibility_ranking
- uncertainty_register
- evidence_references
- limitations

Every raw open-discovery candidate must include:
- property_id
- title
- category
- proof_obligation_kind
- candidate_statement
- supporting_evidence
- required_assumptions
- cbmc_feasibility
- risk_level
- out_of_scope_boundaries
- uncertainty
- limitations
- semantic_property, containing exactly:
{semantic_schema}

Do not output any external taxonomy identifier, taxonomy title, support classification, required tool list, or preselected artefact-construction approach.
""".strip()
    else:
        task = f"""
This stage identifies candidate formal-verification properties from available specification facts, code facts, comments, contracts, previous-stage LLM outputs, and deterministic advisory hints.

Target function: {cfg.target_function}
Target topic: {cfg.target_topic}
Configured property family: {cfg.property_family_id}
Configured verification strategy: {cfg.verification_strategy}

Use the supplied canonical 26-property catalogue as control metadata. Verify all semantic details against primary evidence.

{availability}

Your role is not to prove anything and not to generate final CBMC code. Your role is to propose realistic candidate properties for later artefact generation and review.

Candidate properties must be scoped narrowly and remain inside the configured campaign family and allowed strategies. The configured strategy is explicit user/control metadata, not a substitute for the semantic claim. Every candidate must include a complete strategy-neutral semantic_property record. Do not infer the claim from the category, family, or strategy label.
""".strip()
        schema_summary = f"""
Top-level required fields:
- stage
- source_scope
- candidate_properties
- rejected_or_downgraded_properties
- assumptions_catalogue
- feasibility_ranking
- uncertainty_register
- evidence_references
- limitations

Every candidate property should include:
- property_id
- property_family_id
- title
- category
- verification_strategy
- proof_obligation_kind
- support_classification
- required_tool_capabilities
- candidate_statement
- supporting_evidence
- required_assumptions
- cbmc_feasibility
- risk_level
- expected_artifact_type
- out_of_scope_boundaries
- uncertainty
- limitations
- semantic_property, containing exactly:
{semantic_schema}

The semantic_property must describe the claim independently of the configured artefact strategy.
""".strip()

    return build_common_stage_prompt(
        stage_name="Agent 4 — Property Discovery Agent",
        task_description=task,
        responsibilities=responsibilities,
        prohibitions=prohibitions,
        schema_summary=schema_summary,
        include_non_copying_rule=True,
    )


def build_mock_candidate_properties(cfg: PropertyDiscoveryConfig, spec_available: bool, code_available: bool) -> JsonDict:
    base: JsonDict = {
        "stage": "04_property_discovery",
        "mock": True,
        "llm_call_executed": False,
        "source_scope": {
            "previous_spec_summary_available": spec_available,
            "previous_code_summary_available": code_available,
            "provided_material_complete": False,
            "missing_or_unavailable_material": [
                "Mock mode was used, so no real LLM property discovery was executed."
            ],
        },
        "candidate_properties": [],
        "rejected_or_downgraded_properties": [],
        "assumptions_catalogue": [],
        "feasibility_ranking": [],
        "uncertainty_register": [{
            "issue": "No real LLM call was executed.",
            "impact": "Mock output is wiring evidence only and not thesis property-discovery evidence.",
        }],
        "deterministic_reference_assessment": {
            "used": False,
            "status": "not_assessed_by_real_llm",
            "warning": "Mock output only.",
            "disagreements": [],
        },
        "evidence_references": [],
        "limitations": ["Mock mode output is not a property-discovery result."],
    }
    if cfg.discovery_mode == OPEN_DISCOVERY:
        base.pop("deterministic_reference_assessment", None)
        base["candidate_properties"] = [{
            "property_id": "OPEN_CAND_001",
            "title": "Mock local array-access safety candidate",
            "category": "array_bounds",
            "proof_obligation_kind": "safety",
            "candidate_statement": "Candidate: modeled accesses in the target remain within valid object bounds.",
            "supporting_evidence": [],
            "required_assumptions": ["Objects supplied by the harness are valid for the accessed range."],
            "cbmc_feasibility": "high",
            "risk_level": "medium",
            "out_of_scope_boundaries": ["Mock candidate is not evidence that the property is true."],
            "uncertainty": "Mock wiring candidate only.",
            "limitations": ["Not LLM-authored and not suitable for thesis-result claims."],
        }]
        base["feasibility_ranking"] = [{
            "property_id": "OPEN_CAND_001",
            "rank": 1,
            "feasibility": "high",
            "rationale": "Mock wiring selection only.",
        }]
    return base


# ---------------------------------------------------------------------------
# Open-discovery post-processing
# ---------------------------------------------------------------------------

def process_open_discovery_output(
    *,
    layout: RunLayout,
    stage: str,
    raw_output_path: Path,
    llm_json: Mapping[str, Any],
    config_data: Mapping[str, Any],
) -> JsonDict:
    """Classify and select only after preserving the raw LLM output byte-for-byte."""
    raw_sha256_before = sha256(raw_output_path.read_bytes()).hexdigest()
    classified_payload, classification_audit = classify_open_candidates(llm_json)
    raw_sha256_after = sha256(raw_output_path.read_bytes()).hexdigest()
    if raw_sha256_before != raw_sha256_after:
        raise RuntimeError(
            "Open-discovery raw authoritative output changed during post-classification."
        )
    classification_audit.update({
        "raw_authoritative_output_sha256_before": raw_sha256_before,
        "raw_authoritative_output_sha256_after": raw_sha256_after,
        "raw_authoritative_output_byte_identical": True,
        "classification_performed_after_raw_output_persistence": True,
    })
    classification_path = layout.write_validation_json(
        stage, "04_open_discovery_catalogue_classification.json", classification_audit
    )
    selected_property = select_open_candidate(
        classified_payload,
        selected_property_id=str(
            (config_data.get("property_discovery") or {}).get("selected_property_id") or ""
        ).strip() or None,
        selection_policy=str(
            (config_data.get("property_discovery") or {}).get("selection_policy") or "llm_ranked"
        ),
    )
    selected_property["effective_property_campaign"] = effective_campaign_from_selected(
        selected_property
    )
    classified_path = layout.write_validation_json(
        stage, "05_open_discovery_classified_candidates.json", classified_payload
    )
    selected_path = layout.write_validation_json(
        stage, "06_open_discovery_selected_property.json", selected_property
    )
    return {
        "classified_payload": classified_payload,
        "selected_property": selected_property,
        "classification_path": classification_path,
        "classified_path": classified_path,
        "selected_path": selected_path,
        "stage_status": {
            "raw_output_preserved": True,
            "raw_output_sha256": raw_sha256_after,
            "catalogue_visible_to_llm": False,
            "candidate_count": len(classified_payload.get("candidate_properties", [])),
            "unmapped_count": classification_audit.get("unmapped_count", 0),
            "selected_property_id": selected_property.get("property", {}).get("property_id"),
            "selection_method": selected_property.get("selection_method"),
        },
    }


def process_property_discovery_result(
    *, layout: RunLayout, stage: str, output_path: Path, wrapped_payload: JsonDict,
    payload: JsonDict, config_data: Mapping[str, Any], discovery_mode: str,
) -> JsonDict:
    """Validate targeted output or derive open classification/selection records."""
    if discovery_mode == OPEN_DISCOVERY:
        processed = process_open_discovery_output(
            layout=layout, stage=stage, raw_output_path=output_path,
            llm_json=payload, config_data=config_data,
        )
        return {
            "candidate_path": processed["classified_path"],
            "selected_path": processed["selected_path"],
            "validation_outputs": {
                "open_discovery_catalogue_classification": processed["classification_path"],
                "open_discovery_classified_candidates": processed["classified_path"],
                "open_discovery_selected_property": processed["selected_path"],
            },
            "stage_status": {"open_discovery": processed["stage_status"]},
            "warnings": [],
            "properties": processed["classified_payload"].get("candidate_properties", []),
        }
    campaign = config_data.get("property_campaign")
    campaign = campaign if isinstance(campaign, Mapping) else {}
    normalized, separation = normalize_candidate_properties_for_campaign(payload, campaign)
    separation_path = layout.write_validation_json(
        stage, "03_campaign_candidate_separation.json", separation
    )
    if separation.get("moved_count", 0):
        if isinstance(wrapped_payload.get("content"), dict):
            wrapped_payload["content"] = normalized
        else:
            wrapped_payload = normalized
        atomic_write_json(output_path, wrapped_payload)
    validation = validate_candidate_properties_for_campaign(normalized, campaign)
    validation_path = layout.write_validation_json(
        stage, "03_property_campaign_validation.json", validation
    )
    if not validation.get("valid"):
        raise ValueError(
            "Property campaign semantic validation failed: "
            + "; ".join(validation.get("errors", []))
        )
    return {
        "candidate_path": output_path, "selected_path": None,
        "validation_outputs": {
            "campaign_candidate_separation": separation_path,
            "property_campaign_validation": validation_path,
        },
        "stage_status": {},
        "warnings": [*separation.get("warnings", []), *validation.get("warnings", [])],
        "properties": normalized.get("candidate_properties", []),
    }


# ---------------------------------------------------------------------------
# Main Agent 4 runner
# ---------------------------------------------------------------------------

def run_agent4(config_data: JsonDict, cfg: PropertyDiscoveryConfig) -> int:
    stage = "04_property_discovery"
    layout = RunLayout(cfg.run_dir, create=False)
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 4 Property Discovery started.",
        data={
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
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
        # 1. Load Agent 2 and Agent 3 handoff outputs.
        # --------------------------------------------------------------
        spec_path, spec_summary, spec_status = load_handoff_json(layout, "02_spec_extraction", "spec_summary")
        code_path, code_summary, code_status = load_handoff_json(layout, "03_code_understanding", "code_summary")

        spec_available = bool(spec_summary)
        code_available = bool(code_summary)

        if not spec_available:
            stage_status["warnings"].append(spec_status.get("warning") or "Agent 2 spec summary unavailable.")
        if not code_available:
            stage_status["warnings"].append(code_status.get("warning") or "Agent 3 code summary unavailable.")

        if (not spec_available or not code_available) and not cfg.allow_missing_agent2_or_agent3:
            raise FileNotFoundError(
                "Agent 4 requires both Agent 2 spec_summary and Agent 3 code_summary. "
                "Use --allow-missing-inputs only for wiring tests."
            )

        previous_inputs_record = layout.write_deterministic_reference_json(
            stage,
            "03_previous_stage_input_status.json",
            {
                "trust_boundary": "previous_llm_stage_outputs_are_candidate_context_not_formal_truth",
                "agent2_spec_summary": spec_status,
                "agent3_code_summary": code_status,
                "spec_summary_preview": spec_summary,
                "code_summary_preview": code_summary,
            },
        )

        # --------------------------------------------------------------
        # 2. Deterministic advisory property discovery.
        # --------------------------------------------------------------
        advisory_enabled = semantic_advisory_enabled(config_data) and cfg.discovery_mode != OPEN_DISCOVERY
        deterministic_paths: Dict[str, Path] = {"previous_stage_input_status": previous_inputs_record}
        deterministic_bundle: Optional[JsonDict] = None
        if advisory_enabled:
            deterministic = infer_deterministic_candidate_properties(
                cfg=cfg,
                spec_summary=spec_summary,
                code_summary=code_summary,
            )
            deterministic_paths.update(write_deterministic_reference_files(layout, deterministic))
            property_catalogue = catalogue_summary()
            catalogue_path = layout.write_deterministic_reference_json(
                stage, "03_property_family_catalogue.json", property_catalogue
            )
            deterministic_paths["property_family_catalogue"] = catalogue_path
            deterministic_bundle = {
                **deterministic,
                "property_family_catalogue": property_catalogue,
                "configured_property_campaign": config_data.get("property_campaign", {}),
                "previous_stage_input_status": {
                    "agent2_spec_summary": spec_status,
                    "agent3_code_summary": code_status,
                },
            }
        else:
            stage_status["warnings"].append(
                "semantic_advisory_mode=off: deterministic candidate properties and semantic catalogue advice were not generated or transmitted."
            )
        prior_authoritative_context = {
            "agent2_spec_summary": spec_summary,
            "agent3_code_summary": code_summary,
        }

        # --------------------------------------------------------------
        # 3. Build prompt and call shared LLM client.
        # --------------------------------------------------------------
        prompt_text = build_agent4_prompt(
            cfg=cfg,
            spec_available=spec_available,
            code_available=code_available,
        )

        run_config_for_client = dict(config_data)
        if cfg.llm_mode_override:
            llm_cfg = dict(run_config_for_client.get("llm") or {})
            llm_cfg["mode"] = cfg.llm_mode_override
            run_config_for_client["llm"] = llm_cfg

        client = LLMClient.from_run_config(run_config_for_client)

        # Raw FIPS/source/header inputs are primary; previous LLM outputs are separate candidate context.
        primary_files = canonical_raw_evidence_files(config_data, include_specs=True, include_code=True)
        prior_context_files = existing_unique_paths([p for p in [spec_path, code_path] if p])

        if cfg.discovery_mode != OPEN_DISCOVERY:
            campaign_for_prompt = (
                config_data.get("property_campaign", {})
                if isinstance(config_data.get("property_campaign"), Mapping)
                else {}
            )
            allowed_for_prompt = campaign_for_prompt.get("allowed_strategies", [])
            prompt_text += (
                "\n\nCAMPAIGN-CANDIDATE SEPARATION — MANDATORY:\n"
                f"- Selected property family: {cfg.property_family_id}.\n"
                f"- Allowed formal candidate strategies: {allowed_for_prompt}.\n"
                "- Every object inside candidate_properties MUST use one of those allowed formal strategies.\n"
                "- Preserve analysis-only notes, scope reminders, non-properties, and rejected ideas outside candidate_properties.\n"
                "- Do not invent a campaign-incompatible candidate merely to make the candidate list longer.\n"
            )

        request_schema = (
            OPEN_CANDIDATE_PROPERTIES_SCHEMA
            if cfg.discovery_mode == OPEN_DISCOVERY
            else CANDIDATE_PROPERTIES_SCHEMA
        )

        request = LLMStageRequest(
            stage=stage,
            prompt_text=prompt_text,
            output_filename="03_candidate_properties.json",
            json_schema=request_schema,
            primary_evidence_files=primary_files,
            prior_authoritative_context_files=prior_context_files,
            prior_authoritative_context_bundle=prior_authoritative_context,
            deterministic_reference_bundle=deterministic_bundle,
            extra_prompt_metadata={
                "agent": "Agent 4 Property Discovery",
                "target_function": cfg.target_function,
                "target_topic": cfg.target_topic,
                "property_discovery_mode": cfg.discovery_mode,
                "catalogue_visible_to_llm": cfg.discovery_mode != OPEN_DISCOVERY,
                "previous_agent2_spec_summary_available": spec_available,
                "previous_agent3_code_summary_available": code_available,
                "trust_boundary": {
                    "agent2_spec_summary": "previous_stage_candidate_context_not_formal_truth",
                    "agent3_code_summary": "previous_stage_candidate_context_not_formal_truth",
                    "deterministic_reference": "advisory_only",
                    "llm_output": "authoritative_stage_candidate_not_formal_truth",
                    "formal_truth": "not_claimed",
                },
            },
            mock_response_content=build_mock_candidate_properties(cfg, spec_available, code_available),
        )

        result = client.run_stage(layout, request)
        stage_status["llm_call_executed"] = result.llm_call_executed
        stage_status["llm_mode"] = result.mode
        stage_status["llm_success"] = result.success
        stage_status["llm_result"] = result.to_dict()

        campaign_handoff_allowed = False
        candidate_handoff_path: Optional[Path] = None
        selected_property_path: Optional[Path] = None
        validation_outputs: Dict[str, Path] = {}
        derived_outputs: Dict[str, Path] = {}

        # --------------------------------------------------------------
        # 4. Mode-specific semantic validation and derived handoff.
        # --------------------------------------------------------------
        if result.success and result.output_path:
            try:
                wrapped = read_json_file(result.output_path)
                post = process_property_discovery_result(
                    layout=layout, stage=stage, output_path=Path(result.output_path),
                    wrapped_payload=wrapped, payload=extract_content_wrapper(wrapped),
                    config_data=config_data, discovery_mode=cfg.discovery_mode,
                )
                candidate_handoff_path, selected_property_path = post["candidate_path"], post["selected_path"]
                validation_outputs.update(post["validation_outputs"])
                stage_status.update(post["stage_status"])
                stage_status["warnings"].extend(post["warnings"])
                campaign_handoff_allowed = True
                rows = [{
                    "property_id": item.get("property_id", ""),
                    "property_family_id": item.get("property_family_id", ""),
                    "title": item.get("title", ""),
                    "category": item.get("category", ""),
                    "verification_strategy": item.get("verification_strategy", ""),
                    "cbmc_feasibility": item.get("cbmc_feasibility", item.get("feasibility", "")),
                    "risk_level": item.get("risk_level", item.get("risk", "")),
                    "expected_artifact_type": item.get("expected_artifact_type", ""),
                } for item in post["properties"] if isinstance(item, dict)]
                if rows:
                    derived_outputs["candidate_properties_csv"] = write_csv(
                        layout.validation_dir(stage) / "03_candidate_properties.llm_summary.csv", rows
                    )
            except Exception as exc:
                result.success = False
                result.error = f"Property discovery post-processing failed closed: {type(exc).__name__}: {exc}"
                stage_status["errors"].append({
                    "type": "PropertyDiscoveryPostProcessingError", "message": result.error,
                })
                stage_status["llm_success"] = False
                stage_status["llm_result"] = result.to_dict()
                validation_outputs["derived_summary_error"] = layout.write_validation_json(
                    stage, "03_candidate_properties_derived_summary_error.json", {"error": result.error}
                )

        # --------------------------------------------------------------
        # 5. Handoff manifest.
        # --------------------------------------------------------------
        if result.success and result.output_path and campaign_handoff_allowed:
            handoff_outputs: Dict[str, Path] = {
                "candidate_properties": candidate_handoff_path or Path(result.output_path),
            }
            if selected_property_path is not None:
                handoff_outputs["selected_property"] = selected_property_path

            if result.validation_path:
                handoff_outputs["candidate_properties_validation"] = Path(result.validation_path)

            # Advisory, not authoritative.
            ev_path = deterministic_paths.get("property_evidence_matrix")
            if ev_path:
                handoff_outputs["property_evidence_matrix_advisory"] = ev_path

            trace_path = deterministic_paths.get("spec_code_traceability")
            if trace_path:
                handoff_outputs["spec_code_traceability_advisory"] = trace_path

            risk_path = deterministic_paths.get("property_risk_register")
            if risk_path:
                handoff_outputs["property_risk_register_advisory"] = risk_path

            layout.write_handoff_manifest(
                stage,
                outputs=handoff_outputs,
                authoritative_source="llm_authoritative",
                next_stage_consumers=[
                    "05_artifact_generation",
                    "06_review_critic",
                    "11_evaluation_reporter",
                ],
                notes={
                    "handoff_policy": (
                        "In targeted mode candidate_properties is the validated LLM-authoritative campaign output. "
                        "In open mode the raw LLM output remains immutable and candidate_properties is a deterministic "
                        "post-classified copy; selected_property is chosen only after raw output persistence."
                    ),
                    "llm_mode": result.mode,
                    "llm_call_executed": result.llm_call_executed,
                    "mock_output": result.mode == "mock",
                    "agent2_spec_summary_available": spec_available,
                    "agent3_code_summary_available": code_available,
                    "scope_policy": "CBMC-realistic local properties only; broad crypto/FIPS/full-correctness claims must be rejected or downgraded.",
                    "property_discovery_mode": cfg.discovery_mode,
                    "catalogue_visible_to_llm": cfg.discovery_mode != OPEN_DISCOVERY,
                    "raw_llm_output_preserved": cfg.discovery_mode == OPEN_DISCOVERY,
                },
            )
            stage_status["handoff_available"] = True
            stage_status["success"] = True
        else:
            message = (
                "No campaign-valid authoritative LLM candidate_properties output was produced. "
                "Deterministic property guesses were not handed off as authoritative."
            )
            stage_status["warnings"].append(message)

            if cfg.allow_empty_handoff_on_failure:
                layout.write_handoff_manifest(
                    stage,
                    outputs={},
                    authoritative_source="none_llm_failed_or_disabled",
                    next_stage_consumers=[],
                    notes={
                        "handoff_policy": "No property handoff because LLM output is unavailable or invalid.",
                        "deterministic_reference_available": True,
                        "deterministic_reference_is_authoritative": False,
                        "llm_result": result.to_dict(),
                    },
                )

        # --------------------------------------------------------------
        # 6. Stage manifest.
        # --------------------------------------------------------------
        llm_outputs = {}
        prompt_outputs = {}

        if result.output_path:
            llm_outputs["candidate_properties"] = Path(result.output_path)
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

        # Include derived CSV as validation/derived output.
        validation_outputs.update(derived_outputs)

        layout.write_stage_manifest(
            stage,
            primary_evidence_inputs=[
                str(p) for p in [spec_path, code_path] if p is not None
            ],
            deterministic_reference_outputs=deterministic_paths,
            prompt_package_outputs=prompt_outputs,
            llm_authoritative_outputs=llm_outputs,
            validation_outputs=validation_outputs,
            notes={
                "agent_version": "agent4_property_discovery_refactored.v1",
                "deterministic_reference_policy": "advisory_only_not_authoritative",
                "agent2_spec_summary_available": spec_available,
                "agent3_code_summary_available": code_available,
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
            },
        )

        stage_status["completed_utc"] = utc_now_iso()
        status_path = layout.logs_dir(stage) / "04_property_discovery_status.json"
        atomic_write_json(status_path, stage_status)

        layout.log_event(
            event_type="stage_completed" if stage_status["success"] else "stage_completed_without_handoff",
            stage=stage,
            message="Agent 4 Property Discovery completed.",
            data={
                "success": stage_status["success"],
                "handoff_available": stage_status["handoff_available"],
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
                "agent2_spec_summary_available": spec_available,
                "agent3_code_summary_available": code_available,
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
        atomic_write_json(layout.logs_dir(stage) / "04_property_discovery_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 4 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        try:
            layout.write_stage_manifest(
                stage,
                notes={
                    "agent_version": "agent4_property_discovery_refactored.v1",
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


def normalize_candidate_properties_for_campaign(
    payload: Mapping[str, Any],
    campaign: Mapping[str, Any],
) -> Tuple[JsonDict, JsonDict]:
    """Separate analysis-only scoping notes from formal campaign candidates.

    Only analysis-only entries that use a strategy unavailable to the selected
    campaign are moved. Other incompatible formal strategies remain untouched
    so the strict campaign validator can fail closed.
    """
    normalized: JsonDict = json.loads(json.dumps(dict(payload)))

    candidates = normalized.get("candidate_properties", [])
    rejected = normalized.get("rejected_or_downgraded_properties", [])

    if not isinstance(candidates, list):
        return normalized, {
            "schema_version": "agent4_campaign_candidate_separation.v1",
            "moved_count": 0,
            "moved_property_ids": [],
            "warnings": [],
        }

    if not isinstance(rejected, list):
        rejected = []

    allowed = {
        str(value)
        for value in campaign.get("allowed_strategies", [])
        if str(value)
    }

    family_id = str(campaign.get("property_family_id") or "unknown")
    kept = []
    moved = []

    for item in candidates:
        if not isinstance(item, Mapping):
            kept.append(item)
            continue

        strategy = str(item.get("verification_strategy") or "")
        proof_kind = str(item.get("proof_obligation_kind") or "")
        support = str(item.get("support_classification") or "")
        category = str(item.get("category") or "")

        is_analysis_only = (
            strategy == "analysis_only_no_formal_claim"
            or proof_kind == "analysis_only"
            or support == "analysis_only"
            or category == "analysis_only_no_formal_claim"
        )

        strategy_not_allowed = bool(allowed) and strategy not in allowed

        if is_analysis_only and strategy_not_allowed:
            property_id = str(item.get("property_id") or "UNNAMED_ANALYSIS_NOTE")
            title = str(item.get("title") or "Analysis-only scoping note")

            evidence = item.get("supporting_evidence", [])
            if not isinstance(evidence, list):
                evidence = []

            rejected.append({
                "property_id": property_id,
                "title": title,
                "reason": (
                    f"Downgraded automatically to an analysis-only scoping note: "
                    f"strategy {strategy!r} is not an allowed formal candidate "
                    f"strategy for campaign family {family_id}. The note remains "
                    "preserved but is not handed to later stages as a proof obligation."
                ),
                "evidence_references": evidence,
            })

            moved.append(property_id)
        else:
            kept.append(dict(item))

    normalized["candidate_properties"] = kept
    normalized["rejected_or_downgraded_properties"] = rejected

    warnings = []

    if moved:
        warnings.append(
            "Agent 4 moved analysis-only scoping note(s) out of "
            "candidate_properties before strict campaign validation: "
            + ", ".join(moved)
        )

    audit = {
        "schema_version": "agent4_campaign_candidate_separation.v1",
        "campaign_property_family_id": family_id,
        "allowed_strategies": sorted(allowed),
        "moved_count": len(moved),
        "moved_property_ids": moved,
        "remaining_candidate_count": len(kept),
        "warnings": warnings,
        "strict_validator_remains_authoritative": True,
        "non_analysis_strategy_mismatches_are_not_repaired": True,
    }

    return normalized, audit

def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Agent 4 — refactored LLM-backed Property Discovery Agent"
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
        "--target-function",
        help="Implementation function name, e.g. mlk_poly_add.",
    )
    parser.add_argument(
        "--target-topic",
        help="Human-readable target topic.",
    )
    parser.add_argument(
        "--property-focus",
        help="Comma-separated property focus categories.",
    )
    parser.add_argument(
        "--allow-missing-inputs",
        action="store_true",
        help="Allow Agent 4 to run even if Agent 2/3 handoffs are missing. Intended only for wiring tests.",
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
    return run_agent4(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
