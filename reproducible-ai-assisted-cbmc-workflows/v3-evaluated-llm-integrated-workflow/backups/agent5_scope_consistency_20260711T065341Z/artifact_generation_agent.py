#!/usr/bin/env python3
"""
artifact_generation_agent_refactored.py

Agent 5 — Formal Artefact Generation Agent, refactored for the new thesis workflow.

Architecture implemented:
- Consumes Agent 2 LLM spec summary through handoff.
- Consumes Agent 3 LLM code summary through handoff.
- Consumes Agent 4 LLM candidate properties through handoff.
- Python deterministic artefact sketches are advisory/prohibited-copy references only.
- Existing proof harnesses/templates can be indexed as prohibited-copy references.
- The LLM produces the authoritative stage candidate artefact plan:
    stages/05_artifact_generation/llm_authoritative/04_artifact_plan.json
- Python renders concrete C artefacts from the LLM plan into:
    stages/05_artifact_generation/rendered_outputs/04_generated_harness.c
- Python performs structural validation and similarity/independence audit.
- Downstream agents consume only manifest-declared handoff outputs.
- No root-level output dumping.
- No duplicate output copies.

Trust boundary:
- Agent 5 does not prove anything.
- Agent 5 does not claim the harness is correct, complete, novel, or verified.
- The rendered harness is a candidate artefact for review and CBMC execution.
- Similarity audit is a risk screen, not a legal/copyright determination.
"""

from __future__ import annotations

import argparse
import csv
import difflib
import hashlib
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
    from agents.common.schemas import ARTIFACT_PLAN_SCHEMA
    from agents.common.property_catalog import get_property_family, resolve_strategy
    from agents.common.property_campaign import validate_artifact_plan_for_campaign
    from agents.common.contract_artifacts import (
        apply_contract_source_patches, build_contract_header, validate_contract_plan,
        validate_strategy_specific_plans
    )
except Exception as import_exc:  # pragma: no cover
    raise SystemExit(
        "Failed to import shared workflow modules. Ensure these files exist and schemas.py includes ARTIFACT_PLAN_SCHEMA:\n"
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
    content = data.get("content")
    if isinstance(content, dict):
        return content
    return data


def safe_read_text(path: PathLike, *, max_chars: Optional[int] = None) -> str:
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    if max_chars is not None and len(text) > max_chars:
        return text[:max_chars] + "\n[TRUNCATED]\n"
    return text


def parse_list_arg(value: Optional[str]) -> List[str]:
    if not value:
        return []
    return [p.strip() for p in re.split(r"[,;]", value) if p.strip()]


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="replace")).hexdigest()


def sha256_file(path: PathLike) -> str:
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def normalize_code_for_similarity(text: str) -> str:
    # Remove comments and normalize identifiers lightly.
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.DOTALL)
    text = re.sub(r"//.*", " ", text)
    text = re.sub(r"\s+", " ", text)
    # Keep function/macro names, but normalize local variable names conservatively impossible without parser.
    return text.strip()


def normalized_lines(text: str) -> List[str]:
    lines = []
    for line in text.splitlines():
        line = re.sub(r"/\*.*?\*/", " ", line)
        line = re.sub(r"//.*", " ", line)
        line = re.sub(r"\s+", " ", line).strip()
        if line:
            lines.append(line)
    return lines


def jaccard(a: Sequence[str], b: Sequence[str]) -> float:
    sa, sb = set(a), set(b)
    if not sa and not sb:
        return 0.0
    return len(sa & sb) / max(1, len(sa | sb))


def sequence_similarity(a: str, b: str) -> float:
    return difflib.SequenceMatcher(None, a, b).ratio()


def extract_code_from_plan(plan: JsonDict) -> Optional[str]:
    """
    Pull C harness code from common possible plan fields.
    """
    candidate_keys = [
        "generated_harness_code",
        "harness_code",
        "c_harness",
        "renderable_harness_c",
        "candidate_harness_c",
    ]

    for key in candidate_keys:
        value = plan.get(key)
        if isinstance(value, str) and value.strip():
            return value

    artefacts = plan.get("artefacts")
    if isinstance(artefacts, list):
        for item in artefacts:
            if isinstance(item, dict):
                for key in candidate_keys + ["content", "code"]:
                    value = item.get(key)
                    if isinstance(value, str) and ("#include" in value or "void" in value or "int main" in value):
                        return value

    return None


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


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

@dataclass
class ArtifactGenerationConfig:
    run_dir: Path
    project_root: Path = PROJECT_ROOT
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM CBMC candidate artefact generation"
    cbmc_function: str = "harness"
    selected_property_id: Optional[str] = None
    llm_mode_override: Optional[str] = None
    allow_missing_previous_inputs: bool = False
    allow_empty_handoff_on_failure: bool = True
    proof_reference_dirs: List[Path] = None  # type: ignore
    proof_reference_files: List[Path] = None  # type: ignore
    source_reference_files: List[Path] = None  # type: ignore
    max_reference_file_chars: int = 80_000
    similarity_high_threshold: float = 0.72
    similarity_moderate_threshold: float = 0.50
    property_family_id: str = "P16"
    verification_strategy: str = "standard_cbmc_harness"

    def __post_init__(self) -> None:
        if self.proof_reference_dirs is None:
            self.proof_reference_dirs = []
        if self.proof_reference_files is None:
            self.proof_reference_files = []
        if self.source_reference_files is None:
            self.source_reference_files = []


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


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, ArtifactGenerationConfig]:
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
        or f"CBMC artefact generation for {target_function}"
    )

    ag = config_data.get("artifact_generation", {})
    if not isinstance(ag, dict):
        ag = {}

    tool_execution = config_data.get("tool_execution", {})
    if not isinstance(tool_execution, dict):
        tool_execution = {}

    cbmc_function = str(
        tool_execution.get("cbmc_function") or "harness"
    )

    proof_dirs = _as_paths(args.proof_reference_dir) if args.proof_reference_dir else []
    proof_dirs.extend(_as_paths(ag.get("proof_reference_dirs")))

    proof_files = _as_paths(args.proof_reference_file) if args.proof_reference_file else []
    proof_files.extend(_as_paths(ag.get("proof_reference_files")))

    source_files = _as_paths(args.source_reference_file) if args.source_reference_file else []
    inputs = config_data.get("inputs", {})
    if isinstance(inputs, dict):
        for key in ["code_paths", "source_files", "implementation_files", "headers"]:
            source_files.extend(_as_paths(inputs.get(key)))
        code_dir = inputs.get("code_dir") or inputs.get("code_directory")
        if code_dir:
            d = Path(str(code_dir)).expanduser().resolve()
            if d.exists():
                for suffix in ["*.c", "*.h", "*.inc"]:
                    source_files.extend(sorted(d.glob(suffix)))
    source_files.extend(_as_paths(ag.get("source_reference_files")))

    # De-duplicate.
    def unique(paths: List[Path]) -> List[Path]:
        seen = set()
        out = []
        for p in paths:
            key = str(p)
            if key not in seen:
                seen.add(key)
                out.append(p)
        return out

    campaign = config_data.get("property_campaign", {}) if isinstance(config_data.get("property_campaign"), dict) else {}
    cfg = ArtifactGenerationConfig(
        run_dir=run_dir,
        project_root=Path(str(config_data.get("project_root") or PROJECT_ROOT)).expanduser().resolve(),
        target_function=target_function,
        target_topic=target_topic,
cbmc_function=cbmc_function,
        selected_property_id=args.selected_property_id or ag.get("selected_property_id"),
        llm_mode_override=args.llm_mode,
        allow_missing_previous_inputs=bool(args.allow_missing_inputs or ag.get("allow_missing_previous_inputs")),
        proof_reference_dirs=unique(proof_dirs),
        proof_reference_files=unique(proof_files),
        source_reference_files=unique(source_files),
        property_family_id=str(campaign.get("property_family_id") or "P16"),
        verification_strategy=str(campaign.get("verification_strategy") or "standard_cbmc_harness"),
    )
    return config_data, cfg


# ---------------------------------------------------------------------------
# Handoff loading
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
# Property selection and deterministic advisory plan
# ---------------------------------------------------------------------------

def select_candidate_property(
    candidate_properties: Optional[JsonDict],
    selected_property_id: Optional[str],
    *,
    property_family_id: str = "P16",
    verification_strategy: str = "standard_cbmc_harness",
) -> JsonDict:
    """Select only a campaign-compatible property unless an explicit ID is requested.

    A missing Agent 4 candidate creates a clearly marked campaign-local fallback for
    mock/wiring and diagnostic packaging. It is never presented as LLM reasoning.
    """
    props: List[JsonDict] = []
    if candidate_properties:
        raw = candidate_properties.get("candidate_properties")
        if isinstance(raw, list):
            props = [p for p in raw if isinstance(p, dict)]

    if selected_property_id:
        for p in props:
            if str(p.get("property_id")) == selected_property_id:
                return {
                    "selected": True,
                    "selection_method": "explicit_selected_property_id",
                    "property": p,
                }

    compatible = [
        p for p in props
        if str(p.get("property_family_id") or "") == property_family_id
        and str(p.get("verification_strategy") or "") == verification_strategy
    ]

    preferred_categories = [
        "array_bounds", "memory_safety", "local_functional_consistency",
        "local_functional_postcondition", "integer_overflow_or_range",
        "coefficient_range", "contract_consistency", "loop_contract",
        "function_contract", "relational", "analysis_only",
    ]
    for cat in preferred_categories:
        for candidate in compatible:
            if cat.lower() in str(candidate.get("category", "")).lower() or cat.lower() in str(candidate.get("title", "")).lower():
                return {
                    "selected": True,
                    "selection_method": "configured_campaign_preferred_category",
                    "property": candidate,
                }

    if compatible:
        return {
            "selected": True,
            "selection_method": "configured_campaign_first_match",
            "property": compatible[0],
        }

    family = get_property_family(property_family_id)
    artefact_by_strategy = {
        "standard_cbmc_harness": "cbmc_harness_candidate",
        "native_function_contract": "native_cbmc_function_contract_candidate",
        "native_loop_contract": "native_cbmc_loop_contract_candidate",
        "relational_cbmc_harness": "relational_cbmc_harness_candidate",
        "hybrid_contract_and_harness": "hybrid_contract_and_harness_candidate",
        "analysis_only_no_formal_claim": "analysis_only_review_record",
    }
    obligation_by_strategy = {
        "standard_cbmc_harness": "safety",
        "native_function_contract": "function_contract",
        "native_loop_contract": "loop_contract",
        "relational_cbmc_harness": "relational",
        "hybrid_contract_and_harness": "function_contract",
        "analysis_only_no_formal_claim": "analysis_only",
    }
    return {
        "selected": True,
        "selection_method": "campaign_local_fallback_no_agent4_candidate_available",
        "property": {
            "property_id": f"{property_family_id}_FALLBACK_001",
            "property_family_id": property_family_id,
            "title": f"Fallback candidate for {family['title']}",
            "category": family["slug"],
            "verification_strategy": verification_strategy,
            "proof_obligation_kind": obligation_by_strategy.get(verification_strategy, "functional"),
            "support_classification": family["support_level"],
            "required_tool_capabilities": [verification_strategy],
            "candidate_statement": (
                "Diagnostic campaign-local fallback because Agent 4 produced no matching candidate. "
                "A real API experiment must independently derive and justify the property from primary evidence."
            ),
            "supporting_evidence": [],
            "required_assumptions": [],
            "cbmc_feasibility": "unknown",
            "risk_level": "unknown",
            "expected_artifact_type": artefact_by_strategy.get(verification_strategy, "candidate_verification_artefact"),
            "out_of_scope_boundaries": [family["claim_boundary"]],
            "uncertainty": "Fallback is for wiring/diagnostic continuity only and is not LLM-authored thesis evidence.",
            "limitations": [
                "No matching Agent 4 candidate property was available.",
                "Must not be used as evidence of LLM property-discovery performance.",
            ],
        },
    }


def deterministic_harness_template(cfg: ArtifactGenerationConfig, selected_property: JsonDict) -> str:
    """
    Advisory/prohibited-copy template only. The LLM must not copy this blindly.
    """
    target = cfg.target_function
    title = selected_property.get("title", "selected candidate property")
    return f"""/*
 * DETERMINISTIC ADVISORY TEMPLATE ONLY — DO NOT TREAT AS AUTHORITATIVE.
 * This file is stored as deterministic/prohibited-copy reference material.
 * The LLM must independently generate an artefact plan from primary evidence.
 *
 * Target function: {target}
 * Candidate property: {title}
 */

#include <assert.h>
#include <stdint.h>
#include "params.h"
#include "poly.h"

void harness(void)
{{
  /*
   * Advisory sketch only:
   * - allocate target inputs using real implementation types,
   * - state explicit assumptions,
   * - snapshot old state before in-place mutation,
   * - call {target},
   * - assert the selected local property.
   *
   * This template intentionally omits final assertions because Agent 5's
   * authoritative plan must be produced by the LLM and reviewed later.
   */
}}
"""


def build_deterministic_advisory_outputs(
    *,
    cfg: ArtifactGenerationConfig,
    spec_summary: Optional[JsonDict],
    code_summary: Optional[JsonDict],
    candidate_properties: Optional[JsonDict],
) -> JsonDict:
    selected = select_candidate_property(
        candidate_properties, cfg.selected_property_id,
        property_family_id=cfg.property_family_id,
        verification_strategy=cfg.verification_strategy,
    )
    selected_property = selected["property"]

    assumption_plan = [
        {
            "assumption_id": "A_TYPES_001",
            "description": "Use the actual C types, macros, and function signature from raw source/header evidence.",
            "risk": "high_if_guessed",
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        {
            "assumption_id": "A_MEMORY_001",
            "description": "Use explicit pointer validity and object-size assumptions where pointer parameters are present.",
            "risk": "medium",
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        {
            "assumption_id": "A_OLDSTATE_001",
            "description": "If the target mutates an object in place, snapshot old state before calling the function.",
            "risk": "medium",
            "trust_boundary": "deterministic_reference_advisory_only",
        },
    ]

    assertion_plan = [
        {
            "assertion_id": "AS_SCOPE_001",
            "description": "Assertions must check only the selected local property, not full ML-KEM correctness.",
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        {
            "assertion_id": "AS_NO_TRIVIAL_001",
            "description": "Avoid assertions that are made trivially true by over-strong assumptions.",
            "trust_boundary": "deterministic_reference_advisory_only",
        },
    ]

    if "functional" in str(selected_property).lower() or "old" in str(selected_property).lower():
        assertion_plan.append({
            "assertion_id": "AS_OLDSTATE_001",
            "description": "For local functional postconditions, compare post-call state against saved pre-call values.",
            "trust_boundary": "deterministic_reference_advisory_only",
        })

    template = deterministic_harness_template(cfg, selected_property)

    return {
        "04_selected_property.deterministic": {
            "selection": selected,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "04_artifact_generation_plan.deterministic": {
            "stage": "05_artifact_generation",
            "mode": "deterministic_reference_only",
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
            "selected_property": selected_property,
            "assumption_plan": assumption_plan,
            "assertion_plan": assertion_plan,
            "required_outputs": [
                "04_artifact_plan.json",
                "04_generated_harness.c",
                "04_artifact_manifest.json",
                "04_independence_audit.json",
            ],
            "warning": (
                "This deterministic plan is advisory only. The LLM must independently produce "
                "the authoritative artefact plan."
            ),
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "04_spec_grounded_assertion_plan.deterministic": {
            "selected_property": selected_property,
            "candidate_assertion_plan": assertion_plan,
            "spec_summary_available": bool(spec_summary),
            "code_summary_available": bool(code_summary),
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "04_harness_assumption_traceability.deterministic": {
            "selected_property": selected_property,
            "assumptions": assumption_plan,
            "trust_boundary": "deterministic_reference_advisory_only",
        },
        "04_generated_harness.deterministic.c": template,
    }


def write_deterministic_reference_files(layout: RunLayout, deterministic: JsonDict) -> Dict[str, Path]:
    stage = "05_artifact_generation"
    paths: Dict[str, Path] = {}

    json_map = {
        "selected_property": ("04_selected_property.deterministic.json", "04_selected_property.deterministic"),
        "artifact_generation_plan": ("04_artifact_generation_plan.deterministic.json", "04_artifact_generation_plan.deterministic"),
        "spec_grounded_assertion_plan": ("04_spec_grounded_assertion_plan.deterministic.json", "04_spec_grounded_assertion_plan.deterministic"),
        "harness_assumption_traceability": ("04_harness_assumption_traceability.deterministic.json", "04_harness_assumption_traceability.deterministic"),
    }

    for key, (filename, data_key) in json_map.items():
        paths[key] = layout.write_deterministic_reference_json(
            stage,
            filename,
            deterministic[data_key],
        )

    template_path = layout.deterministic_reference_dir(stage) / "04_generated_harness.deterministic.c"
    atomic_write_text(template_path, deterministic["04_generated_harness.deterministic.c"])
    paths["generated_harness_deterministic_template"] = template_path

    return paths


# ---------------------------------------------------------------------------
# Prohibited-copy reference indexing and audit
# ---------------------------------------------------------------------------

def collect_reference_files(cfg: ArtifactGenerationConfig, deterministic_paths: Mapping[str, Path]) -> List[Path]:
    files: List[Path] = []

    for d in cfg.proof_reference_dirs:
        if d.exists() and d.is_dir():
            for pattern in ["*.c", "*.h", "*.inc", "*.json", "*.md"]:
                files.extend(sorted(d.rglob(pattern)))

    # Only explicit proof/reference artefacts belong in the prohibited-copy set.
    # Implementation source/header files remain raw primary evidence and must not be
    # silently reclassified as copy templates.
    for f in cfg.proof_reference_files:
        if f.exists() and f.is_file():
            files.append(f)

    # Deterministic harness template is a prohibited-copy source too.
    template = deterministic_paths.get("generated_harness_deterministic_template")
    if template and Path(template).exists():
        files.append(Path(template))

    # De-duplicate and limit.
    out = []
    seen = set()
    for f in files:
        key = str(Path(f).resolve())
        if key not in seen:
            out.append(Path(f).resolve())
            seen.add(key)

    return out[:300]


def configured_prohibited_copy_files(cfg: ArtifactGenerationConfig) -> List[Path]:
    """Return explicit existing proof/reference files before any internal template is added."""
    files: List[Path] = []
    for directory in cfg.proof_reference_dirs:
        if directory.exists() and directory.is_dir():
            for pattern in ["*.c", "*.h", "*.inc", "*.json", "*.md"]:
                files.extend(sorted(directory.rglob(pattern)))
    files.extend(f for f in cfg.proof_reference_files if f.exists() and f.is_file())
    out: List[Path] = []
    seen = set()
    for value in files:
        resolved = Path(value).resolve()
        if str(resolved) not in seen:
            seen.add(str(resolved))
            out.append(resolved)
    return out


def assert_no_primary_prohibited_overlap(
    primary_files: Sequence[Path],
    prohibited_files: Sequence[Path],
) -> None:
    primary = {str(Path(p).resolve()) for p in primary_files}
    prohibited = {str(Path(p).resolve()) for p in prohibited_files}
    overlap = sorted(primary & prohibited)
    if overlap:
        raise ValueError(
            "Evidence-category conflict: prohibited-copy/reference files also appear as raw primary evidence. "
            "Remove proof harnesses/templates from inputs.code_paths/code_dir or from the proof-reference set. "
            f"Conflicting paths: {overlap}"
        )


def index_prohibited_copy_references(layout: RunLayout, cfg: ArtifactGenerationConfig, deterministic_paths: Mapping[str, Path]) -> Tuple[Dict[str, Path], JsonDict]:
    stage = "05_artifact_generation"
    ref_files = collect_reference_files(cfg, deterministic_paths)
    entries = []

    for f in ref_files:
        try:
            text = safe_read_text(f, max_chars=cfg.max_reference_file_chars)
            entry = {
                "path": str(f),
                "name": f.name,
                "suffix": f.suffix,
                "size_bytes": f.stat().st_size,
                "sha256": sha256_file(f),
                "text_sha256_truncated_or_full": sha256_text(text),
                "line_count_used": len(text.splitlines()),
                "normalized_line_count": len(normalized_lines(text)),
                "role": "prohibited_copy_or_similarity_reference",
                "warning": "Do not copy verbatim or near-verbatim from this file.",
            }
        except Exception as exc:
            entry = {
                "path": str(f),
                "name": f.name,
                "error": f"{type(exc).__name__}: {exc}",
            }
        entries.append(entry)

    index = {
        "schema_version": "prohibited_copy_reference_index.v1",
        "created_utc": utc_now_iso(),
        "reference_count": len(entries),
        "entries": entries,
        "policy": {
            "copying_allowed": False,
            "required_identifiers_allowed": True,
            "purpose": "comparison_and_similarity_audit_only",
            "warning": (
                "Existing harnesses, deterministic templates, and previous generated artefacts "
                "must not be copied. Required implementation identifiers may be reused."
            ),
        },
    }

    paths = {
        "existing_harness_index": atomic_write_json(
            layout.prohibited_copy_reference_dir(stage) / "existing_harness_similarity_sources.json",
            index,
        )
    }
    return paths, index


def run_similarity_audit(layout: RunLayout, cfg: ArtifactGenerationConfig, generated_harness_path: Path, reference_files: Sequence[Path]) -> Tuple[Path, Path, JsonDict]:
    stage = "05_artifact_generation"
    generated_text = safe_read_text(generated_harness_path)
    gen_norm = normalize_code_for_similarity(generated_text)
    gen_lines = normalized_lines(generated_text)

    rows = []
    max_score = 0.0
    highest = None

    for ref in reference_files:
        if not ref.exists() or not ref.is_file():
            continue
        try:
            ref_text = safe_read_text(ref, max_chars=cfg.max_reference_file_chars)
        except Exception:
            continue

        ref_norm = normalize_code_for_similarity(ref_text)
        ref_lines = normalized_lines(ref_text)
        seq = sequence_similarity(gen_norm, ref_norm)
        jac = jaccard(gen_lines, ref_lines)
        combined = max(seq, jac)
        max_score = max(max_score, combined)
        if highest is None or combined > highest["combined_similarity"]:
            highest = {
                "path": str(ref),
                "sequence_similarity": round(seq, 4),
                "line_jaccard": round(jac, 4),
                "combined_similarity": round(combined, 4),
            }
        rows.append({
            "reference_path": str(ref),
            "sequence_similarity": round(seq, 4),
            "line_jaccard": round(jac, 4),
            "combined_similarity": round(combined, 4),
        })

    if max_score >= cfg.similarity_high_threshold:
        risk = "high_similarity_risk"
        human_review = True
        action = "block_or_require_major_revision_before_thesis_claim"
    elif max_score >= cfg.similarity_moderate_threshold:
        risk = "moderate_similarity_risk"
        human_review = True
        action = "human_review_required"
    else:
        risk = "low_similarity_risk"
        human_review = False
        action = "record_and_continue"

    audit = {
        "schema_version": "independence_audit.v1",
        "created_utc": utc_now_iso(),
        "generated_harness": str(generated_harness_path),
        "reference_file_count": len(reference_files),
        "highest_similarity": highest,
        "max_similarity_score": round(max_score, 4),
        "copying_risk": risk,
        "requires_human_similarity_review": human_review,
        "recommended_action": action,
        "limitations": [
            "This audit is a heuristic similarity screen, not a legal or originality proof.",
            "Required identifiers, type names, macro names, and CBMC primitives can legitimately overlap.",
            "A low score does not prove novelty; a high score requires human inspection.",
        ],
    }

    audit_path = layout.validation_dir(stage) / "04_independence_audit.json"
    csv_path = layout.validation_dir(stage) / "04_similarity_audit_details.csv"
    atomic_write_json(audit_path, audit)
    write_csv(csv_path, rows, fieldnames=["reference_path", "sequence_similarity", "line_jaccard", "combined_similarity"])
    return audit_path, csv_path, audit


# ---------------------------------------------------------------------------
# Rendering and validation
# ---------------------------------------------------------------------------

def render_harness_from_plan(plan: JsonDict, cfg: ArtifactGenerationConfig) -> Tuple[str, JsonDict]:
    """
    Render C harness code from LLM artefact plan.

    Preferred:
    - If the plan contains generated_harness_code/harness_code/c_harness, use it.

    Fallback:
    - Create a conservative skeleton from plan fields and mark it as fallback-rendered.
    """
    code = extract_code_from_plan(plan)
    if code:
        return code.rstrip() + "\n", {
            "rendering_strategy": "used_llm_plan_embedded_harness_code",
            "fallback": False,
        }

    selected = plan.get("selected_property", {})
    if not isinstance(selected, dict):
        selected = {}

    target = str(plan.get("target_function") or cfg.target_function)
    property_id = str(selected.get("property_id") or plan.get("property_id") or "UNKNOWN_PROPERTY")
    title = str(selected.get("title") or plan.get("title") or "candidate property")

    assumptions = plan.get("assumption_plan") or plan.get("assumptions") or []
    assertions = plan.get("assertion_plan") or plan.get("assertions") or []

    assumptions_comment = json.dumps(assumptions, indent=2, ensure_ascii=False)
    assertions_comment = json.dumps(assertions, indent=2, ensure_ascii=False)

    skeleton = f"""/*
 * FALLBACK-RENDERED CANDIDATE HARNESS SKELETON.
 *
 * This file was rendered by Python because the LLM artefact plan did not provide
 * direct C harness code. It is a candidate scaffold only and requires human review.
 *
 * Target function: {target}
 * Selected property: {property_id} — {title}
 *
 * Assumption plan from LLM:
{indent_block(assumptions_comment, " * ")}
 *
 * Assertion plan from LLM:
{indent_block(assertions_comment, " * ")}
 */

#include <assert.h>
#include <stdint.h>

/*
 * TODO: Include the exact implementation headers required for {target}.
 * TODO: Declare/allocate objects using the actual implementation types.
 * TODO: Add CBMC assumptions exactly as justified by the artefact plan.
 * TODO: Snapshot old state before in-place mutation if required.
 * TODO: Call {target}.
 * TODO: Add assertions for the selected local property only.
 */

void harness(void)
{{
  /* Candidate scaffold only. Not a verified harness. */
}}
"""
    return skeleton, {
        "rendering_strategy": "fallback_skeleton_from_llm_plan",
        "fallback": True,
        "warning": "LLM plan did not provide direct C harness code.",
    }


def indent_block(text: str, prefix: str) -> str:
    return "\n".join(prefix + line for line in text.splitlines())


def validate_rendered_harness(
    harness_text: str,
    cfg: ArtifactGenerationConfig,
    plan: JsonDict,
) -> JsonDict:
    required_terms = [
        cfg.target_function,
    ]

    optional_terms = [
        "#include",
        "assert",
        "__CPROVER",
        "harness",
        "MLKEM",
        "coeff",
    ]

    missing_required = [
        term
        for term in required_terms
        if term and term not in harness_text
    ]

    present_optional = [
        term
        for term in optional_terms
        if term in harness_text
    ]

    risky_patterns = []
    blocking_patterns = []

    expected_entry_signature = (
        f"void {cfg.cbmc_function}(void)"
    )

    entry_pattern = re.compile(
        rf"\bvoid\s+"
        rf"{re.escape(cfg.cbmc_function)}"
        rf"\s*\(\s*void\s*\)\s*\{{"
    )

    entry_function_defined = bool(
        entry_pattern.search(harness_text)
    )

    if not entry_function_defined:
        blocking_patterns.append(
            "missing_exact_cbmc_entry_function"
        )

    null_initialized_pointers = sorted(
        {
            match.group(1)
            for match in re.finditer(
                r"\b[A-Za-z_]\w*\s*\*\s*"
                r"([A-Za-z_]\w*)\s*=\s*"
                r"(?:0|NULL)\s*;",
                harness_text,
            )
        }
    )

    null_freshness_pointers = []

    for pointer_name in null_initialized_pointers:
        freshness_pattern = re.compile(
            rf"\b(?:memory_no_alias|"
            rf"__CPROVER_is_fresh)"
            rf"\s*\(\s*"
            rf"{re.escape(pointer_name)}\b"
        )

        if freshness_pattern.search(harness_text):
            null_freshness_pointers.append(
                pointer_name
            )

    if null_freshness_pointers:
        blocking_patterns.append(
            "null_initialized_pointer_used_with_freshness"
        )

    if re.search(
        r"assert\s*\(\s*1\s*\)",
        harness_text,
    ):
        risky_patterns.append("trivial_assert_true")

    if re.search(
        r"assert\s*\(\s*0\s*\)",
        harness_text,
    ):
        risky_patterns.append("trivial_assert_false")

    if "TODO" in harness_text:
        risky_patterns.append(
            "contains_todo_placeholders"
        )

    if "FALLBACK-RENDERED" in harness_text:
        risky_patterns.append(
            "fallback_rendered_skeleton"
        )

    valid_for_handoff = (
        not missing_required
        and entry_function_defined
        and not blocking_patterns
    )

    requires_human_review = (
        bool(risky_patterns)
        or bool(blocking_patterns)
        or not valid_for_handoff
    )

    return {
        "schema_version":
            "rendered_harness_validation.v2.live_hardening",
        "created_utc": utc_now_iso(),
        "target_function": cfg.target_function,
        "configured_cbmc_function":
            cfg.cbmc_function,
        "expected_entry_signature":
            expected_entry_signature,
        "entry_function_defined":
            entry_function_defined,
        "contains_target_function":
            cfg.target_function in harness_text,
        "missing_required_terms":
            missing_required,
        "present_optional_terms":
            present_optional,
        "null_initialized_pointers":
            null_initialized_pointers,
        "null_freshness_pointers":
            null_freshness_pointers,
        "risky_patterns":
            risky_patterns,
        "blocking_patterns":
            blocking_patterns,
        "valid_for_handoff":
            valid_for_handoff,
        "requires_human_review":
            requires_human_review,
        "limitations": [
            "This is strengthened structural validation.",
            "It does not compile the harness.",
            "It does not run CBMC.",
            "It does not prove semantic correctness.",
            "Agent 6 review remains mandatory.",
        ],
    }

def render_contract_artifacts(
    layout: RunLayout,
    cfg: ArtifactGenerationConfig,
    plan: JsonDict,
) -> Tuple[Dict[str, Path], JsonDict]:
    """Render controlled native-contract artefacts without modifying repository files."""
    strategy = str(plan.get("verification_strategy") or cfg.verification_strategy)
    contract_plan = plan.get("contract_plan", {}) if isinstance(plan.get("contract_plan"), dict) else {}
    strategy_validation = validate_strategy_specific_plans(plan, strategy)
    validation = strategy_validation["contract_plan"]
    outputs: Dict[str, Path] = {}
    rendered_dir = layout.rendered_outputs_dir("05_artifact_generation") / "contracts"
    ensure_dir(rendered_dir)

    validation_path = layout.write_validation_json(
        "05_artifact_generation", "04_contract_plan_validation.json", {
            "schema_version": "contract_plan_validation.v1",
            "verification_strategy": strategy,
            **validation,
            "strategy_specific_plan_validation": strategy_validation,
            "production_source_modified": False,
        }
    )
    outputs["contract_plan_validation"] = validation_path

    if not strategy_validation.get("valid") or not validation.get("enabled"):
        return outputs, {
            "verification_strategy": strategy,
            "strategy_plan_valid": bool(strategy_validation.get("valid")),
            "strategy_plan_validation": strategy_validation,
            "contract_enabled": bool(validation.get("enabled")),
            "contract_valid": bool(validation.get("valid")),
            "instrumented_source_files": [],
            "contract_header": None,
        }

    header_text = build_contract_header(
        contract_plan,
        required_includes=[str(x) for x in plan.get("required_includes", [])] if isinstance(plan.get("required_includes"), list) else [],
    )
    if header_text:
        header_path = rendered_dir / "04_generated_contracts.h"
        atomic_write_text(header_path, header_text)
        outputs["generated_contract_header"] = header_path

    instrumented, instrumentation_manifest, diff_text = apply_contract_source_patches(
        contract_plan,
        project_root=cfg.project_root,
        output_dir=rendered_dir / "instrumented_sources",
        allowed_source_paths=cfg.source_reference_files,
    )
    manifest_path = atomic_write_json(
        rendered_dir / "04_contract_instrumentation_manifest.json", instrumentation_manifest
    )
    diff_path = rendered_dir / "04_contract_instrumentation.diff"
    atomic_write_text(diff_path, diff_text)
    outputs["contract_instrumentation_manifest"] = manifest_path
    outputs["contract_instrumentation_diff"] = diff_path
    for index, source_path in enumerate(instrumented, start=1):
        outputs[f"instrumented_source_{index:02d}"] = source_path

    return outputs, {
        "verification_strategy": strategy,
        "strategy_plan_valid": True,
        "strategy_plan_validation": strategy_validation,
        "contract_enabled": True,
        "contract_valid": True,
        "instrumented_source_files": [str(p) for p in instrumented],
        "contract_header": str(outputs.get("generated_contract_header")) if outputs.get("generated_contract_header") else None,
        "contract_instrumentation_manifest": str(manifest_path),
        "contract_instrumentation_diff": str(diff_path),
        "production_source_modified": False,
    }


def write_artifact_manifest(
    layout: RunLayout,
    cfg: ArtifactGenerationConfig,
    plan_path: Path,
    harness_path: Path,
    validation: JsonDict,
    audit: JsonDict,
    audit_path: Optional[Path] = None,
    contract_summary: Optional[JsonDict] = None,
    contract_outputs: Optional[Mapping[str, Path]] = None,
) -> Path:
    manifest = {
        "schema_version": "artifact_manifest.v1",
        "created_utc": utc_now_iso(),
        "stage": "05_artifact_generation",
        "target_function": cfg.target_function,
        "target_topic": cfg.target_topic,
        "verification_strategy": (contract_summary or {}).get("verification_strategy", cfg.verification_strategy),
        "property_family_id": cfg.property_family_id,
        "artefacts": {
            "artifact_plan": str(plan_path),
            "generated_harness": str(harness_path),
            "independence_audit": str(audit_path) if audit_path else None,
            "contract_outputs": {k: str(v) for k, v in (contract_outputs or {}).items()},
        },
        "checksums_sha256": {
            "artifact_plan": sha256_file(plan_path),
            "generated_harness": sha256_file(harness_path),
            "independence_audit": sha256_file(audit_path) if audit_path and audit_path.is_file() else None,
            "contract_outputs": {k: sha256_file(v) for k, v in (contract_outputs or {}).items() if Path(v).is_file()},
        },
        "contract_summary": contract_summary or {
            "contract_enabled": False,
            "contract_valid": True,
            "instrumented_source_files": [],
            "production_source_modified": False,
        },
        "validation_summary": {
            "rendered_harness_valid_for_handoff": validation.get("valid_for_handoff"),
            "rendered_harness_requires_human_review": validation.get("requires_human_review"),
            "copying_risk": audit.get("copying_risk"),
            "similarity_review_required": audit.get("requires_human_similarity_review"),
        },
        "trust_boundary": {
            "artifact_plan": "llm_authoritative_stage_candidate_not_formal_truth",
            "generated_harness": "python_rendered_candidate_from_llm_plan",
            "formal_truth": "not_claimed",
            "cbmc_execution": "not_performed_in_agent5",
        },
    }
    path = layout.rendered_outputs_dir("05_artifact_generation") / "04_artifact_manifest.json"
    return atomic_write_json(path, manifest)


# ---------------------------------------------------------------------------
# Prompt
# ---------------------------------------------------------------------------

def build_agent5_prompt(cfg: ArtifactGenerationConfig, spec_ok: bool, code_ok: bool, props_ok: bool, prohibited_count: int) -> str:
    responsibilities = """
- Select or confirm one candidate property for artefact generation.
- Produce a structured artefact plan for a candidate CBMC-style harness.
- Identify required includes, types, macros, function signature assumptions, assumptions, assertions, and old-state snapshots.
- Specify exactly what the generated harness is intended to check.
- Specify exactly what the generated harness does not check.
- Preserve implementation identifiers where required, such as function names, type names, macro names, field names, and CBMC primitives.
- Avoid over-strong assumptions that make assertions trivially true.
- Avoid post-call self-comparison mistakes.
- For in-place mutation, require explicit old-state snapshots where the selected property needs pre-call values.
- Record independence and non-copying information.
- Record unavoidable similarities separately from independent design choices.
- Mark uncertain or missing evidence explicitly.
""".strip()

    prohibitions = """
- Do not claim the harness is verified.
- Do not claim the harness proves ML-KEM correctness.
- Do not claim FIPS 203 compliance.
- Do not claim cryptographic security.
- Do not copy existing proof harnesses, deterministic templates, previous generated artefacts, or human-corrected examples.
- Do not merely rename variables or reorder statements from prohibited-copy material.
- Do not generate assertions that are trivially true because of assumptions.
- Do not generate a property that checks only implementation self-consistency without explaining the limitation.
- Do not ignore missing headers, missing types, missing macros, or unresolved build assumptions.
""".strip()

    task = f"""
This stage generates a candidate formal artefact plan for later Python rendering, review, and CBMC execution.

Target function: {cfg.target_function}
Target topic: {cfg.target_topic}
Configured CBMC entry function: {cfg.cbmc_function}
Configured property family: {cfg.property_family_id}
Configured verification strategy: {cfg.verification_strategy}
Selected property id requested: {cfg.selected_property_id or "not explicitly selected; choose the configured campaign candidate from Agent 4 when supported"}

Previous-stage availability:
- Agent 2 LLM specification summary available: {spec_ok}
- Agent 3 LLM code summary available: {code_ok}
- Agent 4 LLM candidate properties available: {props_ok}
- Prohibited-copy/similarity reference count: {prohibited_count}

Your output must be an artefact plan, not a proof result.

Mandatory generated-harness requirements:
- The generated C entry function must be exactly:
  void {cfg.cbmc_function}(void)
- Do not rename the configured CBMC entry function.
- Do not initialise pointer inputs to 0 or NULL and then assume
  memory_no_alias or __CPROVER_is_fresh for those pointers.
- For a standard CBMC harness, model pointer inputs as nondeterministic
  pointers or use another non-vacuous object model justified by primary
  repository evidence.
- The generated code must call the exact target function
  {cfg.target_function}.
- A custom descriptive harness name is prohibited unless the configured
  cbmc_function itself has that exact name.

The plan should include:
- selected_property,
- artefact_kind,
- intended_check,
- non_goals,
- required_includes,
- required_types_and_macros,
- assumption_plan,
- assertion_plan,
- old_state_snapshot_plan,
  - old_state_snapshot_plan.required must be exactly one of:
    required_for_selected_property,
    partial_for_selected_property,
    not_required_for_selected_property,
  - do not add punctuation, prefixes, or free-form values such as ": partial",
- verification_strategy,
- contract_plan (use enabled=false and empty clauses when not applicable),
  - for loop contracts, use source_patch_operations.operation_kind="insert_loop_contract_after_guard",
    set expected_original to one exact loop guard/header only, expected_occurrences=1, and leave replacement empty;
    Python inserts the validated invariant/decreases/assigns clauses into a copied configured source file,
  - never include a loop body or production-source rewrite in a patch anchor,
  - for function contracts, provide a declaration prefix without a trailing semicolon/body and configure
    enforce_contract and/or replace_calls_with_contract explicitly,
- relational_plan (use enabled=false when not applicable),
- analysis_only_plan (use enabled=false when not applicable),
- generated_harness_code or renderable_harness_c when enough evidence is available,
- validation_expectations,
- independence_statement,
- limitations.

Use careful candidate wording.
""".strip()

    schema_summary = """
Top-level required fields:
- stage
- target_function
- selected_property
- artefact_kind
- verification_strategy
- intended_check
- non_goals
- required_includes
- required_types_and_macros
- assumption_plan
- assertion_plan
- old_state_snapshot_plan
- contract_plan
- relational_plan
- analysis_only_plan
- generated_harness_code
- validation_expectations
- independence_statement
- deterministic_reference_assessment
- evidence_references
- limitations

The independence_statement must include:
- existing_artefacts_consulted
- deterministic_hints_consulted
- unavoidable_similarities
- intentional_differences
- copying_risk
- requires_human_similarity_review
""".strip()

    return build_common_stage_prompt(
        stage_name="Agent 5 — Formal Artefact Generation Agent",
        task_description=task,
        responsibilities=responsibilities,
        prohibitions=prohibitions,
        schema_summary=schema_summary,
        include_non_copying_rule=True,
    )



def _mock_selected_property_for_campaign(cfg: ArtifactGenerationConfig) -> JsonDict:
    """Return a schema-valid wiring-only candidate aligned with the configured campaign.

    This is deliberately non-semantic: it exists only so mock/integration runs
    exercise the same family/strategy routing as a real API-backed plan.  It is
    never promoted as LLM evidence or as a provable property.
    """
    family = get_property_family(cfg.property_family_id)
    strategy = cfg.verification_strategy
    obligation_by_strategy = {
        "standard_cbmc_harness": "safety",
        "native_function_contract": "function_contract",
        "native_loop_contract": "loop_contract",
        "relational_cbmc_harness": "relational",
        "analysis_only_no_formal_claim": "analysis_only",
        "hybrid_contract_and_harness": "function_contract",
    }
    artefact_by_strategy = {
        "standard_cbmc_harness": "cbmc_harness_candidate",
        "native_function_contract": "native_function_contract_plus_harness_candidate",
        "native_loop_contract": "native_loop_contract_plus_harness_candidate",
        "relational_cbmc_harness": "relational_cbmc_harness_candidate",
        "analysis_only_no_formal_claim": "analysis_only_review_candidate",
        "hybrid_contract_and_harness": "hybrid_contract_and_harness_candidate",
    }
    tools_by_strategy = {
        "standard_cbmc_harness": ["cbmc"],
        "native_function_contract": ["goto-cc", "goto-instrument", "cbmc", "dfcc_function_contracts"],
        "native_loop_contract": ["goto-cc", "goto-instrument", "cbmc", "apply_loop_contracts"],
        "relational_cbmc_harness": ["cbmc", "relational_harness"],
        "analysis_only_no_formal_claim": ["manual_or_external_constant_time_analysis"],
        "hybrid_contract_and_harness": ["goto-cc", "goto-instrument", "cbmc", "native_contracts", "direct_harness"],
    }
    return {
        "selected": True,
        "selection_method": "mock_configured_campaign_placeholder",
        "property": {
            "property_id": f"{cfg.property_family_id}_MOCK_WIRING_ONLY",
            "property_family_id": cfg.property_family_id,
            "title": str(family.get("title") or f"Property family {cfg.property_family_id}"),
            "category": str(family.get("slug") or "configured_property_campaign"),
            "verification_strategy": strategy,
            "proof_obligation_kind": obligation_by_strategy.get(strategy, "safety"),
            "support_classification": str(family.get("support_level") or "production_supported_scoped"),
            "required_tool_capabilities": tools_by_strategy.get(strategy, [strategy]),
            "candidate_statement": (
                "Mock wiring-only placeholder aligned with the configured property campaign; "
                "no semantic property was generated and no proof claim is permitted."
            ),
            "supporting_evidence": [],
            "required_assumptions": [],
            "cbmc_feasibility": "unknown",
            "risk_level": "unknown",
            "expected_artifact_type": artefact_by_strategy.get(strategy, "candidate_verification_artefact"),
            "out_of_scope_boundaries": [
                str(family.get("claim_boundary") or "Only the exact configured local claim may be evaluated."),
                "No full ML-KEM correctness claim.",
                "No FIPS 203 compliance claim.",
                "No cryptographic-security claim.",
            ],
            "uncertainty": "Mock mode: no API-backed semantic property generation occurred.",
            "limitations": [
                "Wiring-only placeholder.",
                "Must not be used as thesis evidence for model capability or formal verification success.",
            ],
        },
    }

def build_mock_artifact_plan(cfg: ArtifactGenerationConfig, selected_property: JsonDict) -> JsonDict:
    target = cfg.target_function
    if {"selected", "selection_method", "property"}.issubset(selected_property.keys()):
        selected_property_record = selected_property
    else:
        selected_property_record = {
            "selected": True,
            "selection_method": "mock_normalized_property_input",
            "property": selected_property,
        }

    selected_payload = selected_property_record.get("property")
    if (
        not isinstance(selected_payload, dict)
        or str(selected_payload.get("property_family_id") or "") != cfg.property_family_id
        or str(selected_payload.get("verification_strategy") or "") != cfg.verification_strategy
    ):
        selected_property_record = _mock_selected_property_for_campaign(cfg)
    return {
        "stage": "05_artifact_generation",
        "mock": True,
        "llm_call_executed": False,
        "target_function": target,
        "selected_property": selected_property_record,
        "artefact_kind": "cbmc_harness_candidate",
        "verification_strategy": cfg.verification_strategy,
        "intended_check": "Mock mode only; no real LLM artefact plan was generated.",
        "non_goals": [
            "No proof.",
            "No CBMC execution.",
            "No FIPS compliance claim.",
            "No cryptographic security claim."
        ],
        "required_includes": [],
        "required_types_and_macros": [],
        "assumption_plan": [],
        "assertion_plan": [],
        "old_state_snapshot_plan": {
            "required": "unknown_in_mock_mode",
            "reason": "Mock mode only.",
            "snapshot_items": []
        },
        "contract_plan": {
            "enabled": False,
            "contract_mode": "none",
            "target_symbol": target,
            "function_declaration": "",
            "requires_clauses": [],
            "ensures_clauses": [],
            "assigns_clauses": [],
            "frees_clauses": [],
            "loop_invariant_clauses": [],
            "decreases_clauses": [],
            "loop_assigns_clauses": [],
            "loop_frees_clauses": [],
            "source_patch_operations": [],
            "apply_loop_contracts": False,
            "enforce_contract": False,
            "replace_calls_with_contract": [],
            "use_dfcc": False,
            "invariant_initialization_argument": "not_assessed_in_mock_mode",
            "invariant_preservation_argument": "not_assessed_in_mock_mode",
            "postcondition_use_argument": "not_assessed_in_mock_mode",
            "frame_condition_argument": "not_assessed_in_mock_mode",
            "history_variable_usage": []
        },
        "relational_plan": {
            "enabled": False,
            "relation_kind": "none",
            "first_call": "",
            "second_call": "",
            "state_reset_or_snapshot": [],
            "relation_assertions": [],
            "normalization_assumptions": []
        },
        "analysis_only_plan": {
            "enabled": cfg.verification_strategy == "analysis_only_no_formal_claim",
            "analysis_kind": "manual_review_support" if cfg.verification_strategy == "analysis_only_no_formal_claim" else "none",
            "evidence_to_collect": [],
            "external_tools_or_tests": [],
            "formal_claim_prohibited": True
        },
        "generated_harness_code": f"""/*
 * MOCK HARNESS ONLY — NOT API-BACKED AND NOT FOR THESIS EVIDENCE.
 * Target function: {target}
 */
void harness(void)
{{
  /* mock mode: no real LLM artefact generated */
  (void)0;
}}
""",
        "validation_expectations": [
            {"check": "mock_output_marker_present", "expected": True}
        ],
        "independence_statement": {
            "existing_artefacts_consulted": [],
            "deterministic_hints_consulted": [],
            "unavoidable_similarities": [
                "Target function identifier may appear because it is required by the task."
            ],
            "intentional_differences": [],
            "copying_risk": "mock_not_assessed",
            "requires_human_similarity_review": True
        },
        "deterministic_reference_assessment": {
            "used": True,
            "status": "not_assessed_by_real_llm",
            "warning": "Mock output only.",
            "disagreements": []
        },
        "evidence_references": [],
        "limitations": [
            "Mock mode output only.",
            "No API-backed reasoning was performed.",
            "Do not use this output as thesis evidence for LLM artefact generation performance."
        ],
    }


# ---------------------------------------------------------------------------
# Main runner
# ---------------------------------------------------------------------------

def run_agent5(config_data: JsonDict, cfg: ArtifactGenerationConfig) -> int:
    stage = "05_artifact_generation"
    layout = RunLayout(cfg.run_dir, create=False)
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 5 Formal Artefact Generation started.",
        data={
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
            "selected_property_id": cfg.selected_property_id,
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
        # 1. Load previous-stage LLM handoffs.
        # --------------------------------------------------------------
        spec_path, spec_summary, spec_status = load_handoff_json(layout, "02_spec_extraction", "spec_summary")
        code_path, code_summary, code_status = load_handoff_json(layout, "03_code_understanding", "code_summary")
        props_path, candidate_properties, props_status = load_handoff_json(layout, "04_property_discovery", "candidate_properties")

        spec_ok = bool(spec_summary)
        code_ok = bool(code_summary)
        props_ok = bool(candidate_properties)

        for ok, status, label in [
            (spec_ok, spec_status, "Agent 2 spec summary"),
            (code_ok, code_status, "Agent 3 code summary"),
            (props_ok, props_status, "Agent 4 candidate properties"),
        ]:
            if not ok:
                stage_status["warnings"].append(f"{label} unavailable: {status.get('warning')}")

        if (not spec_ok or not code_ok or not props_ok) and not cfg.allow_missing_previous_inputs:
            raise FileNotFoundError(
                "Agent 5 requires Agent 2 spec_summary, Agent 3 code_summary, and Agent 4 candidate_properties. "
                "Use --allow-missing-inputs only for wiring tests."
            )

        previous_inputs_record = layout.write_deterministic_reference_json(
            stage,
            "04_previous_stage_input_status.json",
            {
                "trust_boundary": "previous_llm_stage_outputs_are_candidate_context_not_formal_truth",
                "agent2_spec_summary": spec_status,
                "agent3_code_summary": code_status,
                "agent4_candidate_properties": props_status,
                "spec_summary_preview": spec_summary,
                "code_summary_preview": code_summary,
                "candidate_properties_preview": candidate_properties,
            },
        )

        # --------------------------------------------------------------
        # 2. Deterministic advisory artefact plan/sketch.
        # --------------------------------------------------------------
        deterministic = build_deterministic_advisory_outputs(
            cfg=cfg,
            spec_summary=spec_summary,
            code_summary=code_summary,
            candidate_properties=candidate_properties,
        )
        deterministic_paths = write_deterministic_reference_files(layout, deterministic)
        deterministic_paths["previous_stage_input_status"] = previous_inputs_record

        # --------------------------------------------------------------
        # 3. Prohibited-copy reference index.
        # --------------------------------------------------------------
        prohibited_paths, prohibited_index = index_prohibited_copy_references(
            layout,
            cfg,
            deterministic_paths,
        )

        selected_property = deterministic["04_selected_property.deterministic"]["selection"]["property"]

        deterministic_bundle = {
            **deterministic,
            "previous_stage_input_status": {
                "agent2_spec_summary": spec_status,
                "agent3_code_summary": code_status,
                "agent4_candidate_properties": props_status,
            },
            "prohibited_copy_reference_index": prohibited_index,
        }
        prior_authoritative_context = {
            "agent2_spec_summary": spec_summary,
            "agent3_code_summary": code_summary,
            "agent4_candidate_properties": candidate_properties,
        }

        # --------------------------------------------------------------
        # 4. LLM artefact plan.
        # --------------------------------------------------------------
        prompt_text = build_agent5_prompt(
            cfg,
            spec_ok=spec_ok,
            code_ok=code_ok,
            props_ok=props_ok,
            prohibited_count=prohibited_index.get("reference_count", 0),
        )

        run_config_for_client = dict(config_data)
        if cfg.llm_mode_override:
            llm_cfg = dict(run_config_for_client.get("llm") or {})
            llm_cfg["mode"] = cfg.llm_mode_override
            run_config_for_client["llm"] = llm_cfg

        client = LLMClient.from_run_config(run_config_for_client)

        # Raw specification/source/header files are primary; earlier LLM outputs are separate candidate context.
        primary_files = existing_unique_paths(
            canonical_raw_evidence_files(config_data, include_specs=True, include_code=True)
            + [p for p in cfg.source_reference_files if p.exists() and p.is_file()]
        )
        assert_no_primary_prohibited_overlap(
            primary_files, configured_prohibited_copy_files(cfg)
        )
        prior_context_files = existing_unique_paths([p for p in [spec_path, code_path, props_path] if p])

        request = LLMStageRequest(
            stage=stage,
            prompt_text=prompt_text,
            output_filename="04_artifact_plan.json",
            json_schema=ARTIFACT_PLAN_SCHEMA,
            primary_evidence_files=primary_files,
            prior_authoritative_context_files=prior_context_files,
            prior_authoritative_context_bundle=prior_authoritative_context,
            deterministic_reference_bundle=deterministic_bundle,
            extra_prompt_metadata={
                "agent": "Agent 5 Formal Artefact Generation",
                "target_function": cfg.target_function,
                "target_topic": cfg.target_topic,
                "selected_property_id": cfg.selected_property_id,
                "prohibited_copy_reference_count": prohibited_index.get("reference_count", 0),
                "trust_boundary": {
                    "previous_stage_outputs": "candidate_context_not_formal_truth",
                    "deterministic_reference": "advisory_or_prohibited_copy_reference_only",
                    "llm_output": "authoritative_stage_candidate_plan_not_formal_truth",
                    "rendered_harness": "python_rendered_candidate_from_llm_plan",
                    "formal_truth": "not_claimed",
                },
            },
            mock_response_content=build_mock_artifact_plan(cfg, selected_property),
        )

        result = client.run_stage(layout, request)
        stage_status["llm_call_executed"] = result.llm_call_executed
        stage_status["llm_mode"] = result.mode
        stage_status["llm_success"] = result.success
        stage_status["llm_result"] = result.to_dict()

        campaign_validation_path: Optional[Path] = None
        if result.success and result.output_path:
            plan_wrapped_for_campaign = read_json_file(result.output_path)
            plan_for_campaign = extract_content_wrapper(plan_wrapped_for_campaign)
            campaign_validation = validate_artifact_plan_for_campaign(
                plan_for_campaign, config_data.get("property_campaign", {})
            )
            campaign_validation_path = layout.write_validation_json(
                stage, "04_property_campaign_artifact_validation.json", campaign_validation
            )
            if not campaign_validation.get("valid"):
                result.success = False
                result.error = "Artifact campaign semantic validation failed: " + "; ".join(campaign_validation.get("errors", []))
                stage_status["errors"].append({
                    "type": "PropertyCampaignValidationError",
                    "message": result.error,
                })
                stage_status["llm_success"] = False
                stage_status["llm_result"] = result.to_dict()

        # --------------------------------------------------------------
        # 5. Render harness and validate.
        # --------------------------------------------------------------
        rendered_outputs: Dict[str, Path] = {}
        validation_outputs: Dict[str, Path] = {}
        if campaign_validation_path:
            validation_outputs["property_campaign_artifact_validation"] = campaign_validation_path
        llm_outputs: Dict[str, Path] = {}
        prompt_outputs: Dict[str, Path] = {}

        artifact_manifest_path: Optional[Path] = None
        independence_audit_path: Optional[Path] = None
        similarity_csv_path: Optional[Path] = None
        harness_path: Optional[Path] = None
        contract_outputs: Dict[str, Path] = {}
        contract_summary: JsonDict = {
            "verification_strategy": cfg.verification_strategy,
            "contract_enabled": False,
            "contract_valid": True,
            "instrumented_source_files": [],
            "production_source_modified": False,
        }

        if result.success and result.output_path:
            artifact_plan_wrapped = read_json_file(result.output_path)
            artifact_plan = extract_content_wrapper(artifact_plan_wrapped)

            harness_text, render_meta = render_harness_from_plan(artifact_plan, cfg)
            harness_path = layout.rendered_outputs_dir(stage) / "04_generated_harness.c"
            atomic_write_text(harness_path, harness_text)
            rendered_outputs["generated_harness"] = harness_path

            render_meta_path = layout.rendered_outputs_dir(stage) / "04_render_metadata.json"
            atomic_write_json(render_meta_path, {
                "schema_version": "render_metadata.v1",
                "created_utc": utc_now_iso(),
                "rendering": render_meta,
                "source_plan": str(result.output_path),
            })
            rendered_outputs["render_metadata"] = render_meta_path

            harness_validation = validate_rendered_harness(harness_text, cfg, artifact_plan)
            harness_validation_path = layout.write_validation_json(
                stage,
                "04_harness_structural_validation.json",
                harness_validation,
            )
            validation_outputs["harness_structural_validation"] = harness_validation_path

            contract_outputs, contract_summary = render_contract_artifacts(layout, cfg, artifact_plan)
            for key, value in contract_outputs.items():
                if key.endswith("validation"):
                    validation_outputs[key] = value
                else:
                    rendered_outputs[key] = value

            reference_files = collect_reference_files(cfg, deterministic_paths)
            independence_audit_path, similarity_csv_path, independence_audit = run_similarity_audit(
                layout,
                cfg,
                harness_path,
                reference_files,
            )
            validation_outputs["independence_audit"] = independence_audit_path
            validation_outputs["similarity_audit_details"] = similarity_csv_path

            artifact_manifest_path = write_artifact_manifest(
                layout,
                cfg,
                plan_path=Path(result.output_path),
                harness_path=harness_path,
                validation=harness_validation,
                audit=independence_audit,
                audit_path=independence_audit_path,
                contract_summary=contract_summary,
                contract_outputs=contract_outputs,
            )
            rendered_outputs["artifact_manifest"] = artifact_manifest_path

        # --------------------------------------------------------------
        # 6. Handoff manifest.
        # --------------------------------------------------------------
        if result.success and result.output_path and harness_path and artifact_manifest_path and independence_audit_path:
            handoff_outputs: Dict[str, Path] = {
                "artifact_plan": Path(result.output_path),
                "generated_harness": harness_path,
                "artifact_manifest": artifact_manifest_path,
                "independence_audit": independence_audit_path,
            }

            if result.validation_path:
                handoff_outputs["artifact_plan_validation"] = Path(result.validation_path)
            if similarity_csv_path:
                handoff_outputs["similarity_audit_details"] = similarity_csv_path
            for key, value in contract_outputs.items():
                handoff_outputs[key] = value

            # Advisory/prohibited references for reviewer context.
            if deterministic_paths.get("selected_property"):
                handoff_outputs["selected_property_advisory"] = deterministic_paths["selected_property"]
            if prohibited_paths.get("existing_harness_index"):
                handoff_outputs["prohibited_copy_reference_index"] = prohibited_paths["existing_harness_index"]

            layout.write_handoff_manifest(
                stage,
                outputs=handoff_outputs,
                authoritative_source="llm_authoritative_plus_python_rendered_outputs",
                next_stage_consumers=[
                    "06_review_critic",
                    "07_tool_execution",
                    "10_experiment_logger",
                    "11_evaluation_reporter",
                ],
                notes={
                    "handoff_policy": (
                        "artifact_plan is LLM-authoritative stage candidate output. "
                        "generated_harness is Python-rendered candidate code from the LLM plan. "
                        "independence_audit is a deterministic similarity-risk screen."
                    ),
                    "llm_mode": result.mode,
                    "llm_call_executed": result.llm_call_executed,
                    "mock_output": result.mode == "mock",
                    "formal_truth_claimed": False,
                    "cbmc_executed": False,
                    "copying_risk_must_be_reviewed": True,
                },
            )
            stage_status["handoff_available"] = True
            stage_status["success"] = True
        else:
            message = (
                "No complete Agent 5 handoff was produced. Deterministic artefact sketches were not "
                "handed off as authoritative."
            )
            stage_status["warnings"].append(message)
            if cfg.allow_empty_handoff_on_failure:
                layout.write_handoff_manifest(
                    stage,
                    outputs={},
                    authoritative_source="none_llm_failed_or_render_failed",
                    next_stage_consumers=[],
                    notes={
                        "handoff_policy": "No artefact handoff because LLM output or rendering/validation failed.",
                        "deterministic_reference_available": True,
                        "deterministic_reference_is_authoritative": False,
                        "llm_result": result.to_dict(),
                    },
                )

        # --------------------------------------------------------------
        # 7. Stage manifest.
        # --------------------------------------------------------------
        if result.output_path:
            llm_outputs["artifact_plan"] = Path(result.output_path)
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
            primary_evidence_inputs=[
                str(p) for p in [spec_path, code_path, props_path] if p is not None
            ] + [str(p) for p in cfg.source_reference_files if p.exists()],
            deterministic_reference_outputs=deterministic_paths,
            prompt_package_outputs=prompt_outputs,
            llm_authoritative_outputs=llm_outputs,
            rendered_outputs=rendered_outputs,
            validation_outputs=validation_outputs,
            diagnostics_outputs=prohibited_paths,
            notes={
                "agent_version": "agent5_artifact_generation_refactored.v1",
                "deterministic_reference_policy": "advisory_or_prohibited_copy_reference_only",
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
                "cbmc_executed": False,
                "formal_truth_claimed": False,
            },
        )

        stage_status["completed_utc"] = utc_now_iso()
        status_path = layout.logs_dir(stage) / "05_artifact_generation_status.json"
        atomic_write_json(status_path, stage_status)

        layout.log_event(
            event_type="stage_completed" if stage_status["success"] else "stage_completed_without_handoff",
            stage=stage,
            message="Agent 5 Formal Artefact Generation completed.",
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
        atomic_write_json(layout.logs_dir(stage) / "05_artifact_generation_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 5 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        try:
            layout.write_stage_manifest(
                stage,
                notes={
                    "agent_version": "agent5_artifact_generation_refactored.v1",
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
        description="Agent 5 — refactored LLM-backed Formal Artefact Generation Agent"
    )
    parser.add_argument("--config", help="Path to run config JSON.")
    parser.add_argument("--run-dir", help="Override run directory.")
    parser.add_argument("--target-function", help="Implementation function name, e.g. mlk_poly_add.")
    parser.add_argument("--target-topic", help="Human-readable target topic.")
    parser.add_argument("--selected-property-id", help="Optional Agent 4 property_id to use.")
    parser.add_argument("--proof-reference-dir", help="Directory containing existing proof harnesses/templates to index as prohibited-copy references.")
    parser.add_argument("--proof-reference-file", help="Specific existing proof/template file(s), comma-separated.")
    parser.add_argument("--source-reference-file", help="Source/header file(s), comma-separated, used as primary evidence and similarity context.")
    parser.add_argument("--allow-missing-inputs", action="store_true", help="Allow missing Agent 2/3/4 handoffs only for wiring tests.")
    parser.add_argument("--llm-mode", choices=["real", "mock", "disabled"], help="Override llm.mode from config.")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    config_data, cfg = load_config(args)
    return run_agent5(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
