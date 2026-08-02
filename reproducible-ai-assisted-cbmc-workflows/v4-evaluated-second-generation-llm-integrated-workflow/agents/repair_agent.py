#!/usr/bin/env python3
"""
repair_refinement_agent_refactored.py

Agent 9 — Repair/Refinement Agent, refactored for the new thesis workflow.

Architecture implemented:
- LLM-backed stage.
- Consumes Agent 8 counterexample analysis, repair guidance, and repair action plan through handoff.
- Consumes Agent 5/6/7 artefact/tool context through handoff where available.
- Python deterministic repair triage is advisory diagnostic only.
- The shared LLM client produces the authoritative candidate repair plan:
    stages/09_repair_refinement/llm_authoritative/08_repair_plan.json
- Compatibility output:
    stages/09_repair_refinement/llm_authoritative/08_repair_notes.json
- Python can render candidate repaired harness code from the LLM plan:
    stages/09_repair_refinement/rendered_outputs/08_repaired_harness.c
- Repairs are not silently applied to the original artefact.
- Source-code repair is blocked by default unless explicitly allowed.
- Downstream agents consume only manifest-declared handoff outputs.
- No root-level output dumping.
- No duplicate output copies.

Trust boundary:
- Agent 9 does not prove a repair is correct.
- Agent 9 does not claim a repaired harness will pass CBMC.
- Agent 9 does not silently weaken properties/assumptions without recording evidence loss.
- Agent 9 proposes candidate repair/refinement actions for a later rerun/review cycle.
"""

from __future__ import annotations

import argparse
import csv
import difflib
from copy import deepcopy
import json
import os
import re
import sys
import traceback
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple, Union

from jsonschema import Draft202012Validator


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
    from agents.common.contract_artifacts import (
        apply_contract_source_patches,
        build_contract_header,
        validate_contract_plan,
    )
    from agents.common.llm_client import LLMClient, LLMStageRequest, record_llm_stage_failure
    from agents.common.prompt_templates import build_common_stage_prompt
    from agents.common.schemas import ARTIFACT_PLAN_SCHEMA, REPAIR_PLAN_SCHEMA
    from agents.common.property_campaign import validate_artifact_plan_for_campaign, validate_repair_plan_for_campaign
    from agents.common.property_discovery_mode import effective_campaign_for_plan
    from agents.common.semantic_gate import validate_artifact_semantics
    from agents.common.semantic_property import compare_semantic_properties, normalize_semantic_property
    from agents.common.exact_traceability import build_traceability_record
    from agents.common.cbmc_capability import build_capability_profile
    from agents.common.formal_build import create_formal_build_plan, run_frontend_readiness_check
    from agents.common.tool_result_contract import interpret_tool_result
    from agents.common.similarity_audit import (
        audit_candidate_files, explicit_prohibited_reference_files, write_audit,
    )
except Exception as import_exc:  # pragma: no cover
    raise SystemExit(
        "Failed to import shared workflow modules. Ensure these files exist and schemas.py includes REPAIR_PLAN_SCHEMA:\n"
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


def sha256_file(path: PathLike) -> str:
    import hashlib
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def sha256_text(text: str) -> str:
    import hashlib
    return hashlib.sha256(text.encode("utf-8", errors="replace")).hexdigest()


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


def extract_code_from_repair_plan(plan: JsonDict) -> Optional[str]:
    keys = [
        "repaired_harness_code",
        "candidate_repaired_harness_code",
        "updated_harness_code",
        "renderable_repaired_harness_c",
        "patched_harness_code",
    ]
    for key in keys:
        value = plan.get(key)
        if isinstance(value, str) and value.strip():
            return value

    artefacts = plan.get("rendered_candidate_outputs")
    if isinstance(artefacts, list):
        for item in artefacts:
            if isinstance(item, dict):
                for key in keys + ["content", "code"]:
                    value = item.get(key)
                    if isinstance(value, str) and ("harness" in value or "#include" in value or "assert" in value):
                        return value

    return None


def make_unified_diff(old_text: str, new_text: str, fromfile: str = "original_harness.c", tofile: str = "candidate_repaired_harness.c") -> str:
    return "".join(difflib.unified_diff(
        old_text.splitlines(keepends=True),
        new_text.splitlines(keepends=True),
        fromfile=fromfile,
        tofile=tofile,
    ))


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

@dataclass
class RepairRefinementConfig:
    run_dir: Path
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM CBMC repair/refinement"
    llm_mode_override: Optional[str] = None
    allow_missing_inputs: bool = False
    allow_empty_handoff_on_failure: bool = True
    render_candidate_repaired_harness: bool = True
    apply_repair: bool = False
    allow_source_code_repair: bool = False
    max_text_chars: int = 160_000
    iteration: int = 0
    reason: str = "counterexample_analysis"


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


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, RepairRefinementConfig]:
    config_data: JsonDict = {}
    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        config_data = load_normalized_config(config_path)

    rr = config_data.get("repair_refinement", {})
    if not isinstance(rr, dict):
        rr = {}

    target_function = (
        args.target_function
        or str(config_data.get("target_function") or "")
        or str(config_data.get("function_name") or "")
        or "mlk_poly_add"
    )

    target_topic = (
        args.target_topic
        or str(config_data.get("target_topic") or "")
        or f"CBMC repair/refinement for {target_function}"
    )

    cfg = RepairRefinementConfig(
        run_dir=resolve_run_dir(config_data, args),
        target_function=target_function,
        target_topic=target_topic,
        llm_mode_override=args.llm_mode,
        allow_missing_inputs=bool(args.allow_missing_inputs or rr.get("allow_missing_inputs")),
        render_candidate_repaired_harness=bool(rr.get("render_candidate_repaired_harness", True)),
        apply_repair=bool(args.apply_repair or rr.get("apply_repair", False)),
        allow_source_code_repair=bool(args.allow_source_code_repair or rr.get("allow_source_code_repair", False)),
        max_text_chars=int(rr.get("max_text_chars", 160_000)),
        iteration=int(args.iteration),
        reason=str(args.reason),
    )
    return config_data, cfg


# ---------------------------------------------------------------------------
# Handoff loading
# ---------------------------------------------------------------------------

def load_handoff_path(layout: RunLayout, producer_stage: str, output_key: str) -> Tuple[Optional[Path], JsonDict]:
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
            return path, status
        status["available"] = True
        return path, status
    except Exception as exc:
        status["warning"] = f"Could not load handoff path: {type(exc).__name__}: {exc}"
        return None, status


def load_handoff_json(layout: RunLayout, producer_stage: str, output_key: str) -> Tuple[Optional[Path], Optional[JsonDict], JsonDict]:
    path, status = load_handoff_path(layout, producer_stage, output_key)
    if not path or not path.exists():
        return path, None, status
    try:
        data = extract_content_wrapper(read_json_file(path))
        status["available"] = True
        return path, data, status
    except Exception as exc:
        status["available"] = False
        status["warning"] = f"Could not parse JSON handoff: {type(exc).__name__}: {exc}"
        return path, None, status


def load_handoff_text(layout: RunLayout, producer_stage: str, output_key: str, *, max_chars: Optional[int] = None) -> Tuple[Optional[Path], Optional[str], JsonDict]:
    path, status = load_handoff_path(layout, producer_stage, output_key)
    if not path or not path.exists():
        return path, None, status
    try:
        text = safe_read_text(path, max_chars=max_chars)
        status["available"] = True
        return path, text, status
    except Exception as exc:
        status["available"] = False
        status["warning"] = f"Could not read text handoff: {type(exc).__name__}: {exc}"
        return path, None, status


# ---------------------------------------------------------------------------
# Deterministic repair triage
# ---------------------------------------------------------------------------

def result_classification_from_inputs(cbmc_status: Optional[JsonDict], counterexample_analysis: Optional[JsonDict]) -> str:
    if cbmc_status:
        rc = cbmc_status.get("result_classification")
        if isinstance(rc, str) and rc:
            return rc

    if counterexample_analysis:
        trs = counterexample_analysis.get("tool_result_summary", {})
        if isinstance(trs, dict):
            rc = trs.get("result_classification")
            if isinstance(rc, str) and rc:
                return rc
        fc = counterexample_analysis.get("failure_classification", {})
        if isinstance(fc, dict):
            rc = fc.get("result_classification")
            if isinstance(rc, str) and rc:
                return rc

    return "unknown"


def flatten_repair_actions(repair_action_plan: Optional[JsonDict]) -> List[JsonDict]:
    if not repair_action_plan:
        return []
    content = repair_action_plan.get("content")
    if isinstance(content, list):
        return [x for x in content if isinstance(x, dict)]
    if isinstance(content, dict):
        maybe = content.get("content") or content.get("repair_action_plan") or content.get("actions")
        if isinstance(maybe, list):
            return [x for x in maybe if isinstance(x, dict)]
    maybe = repair_action_plan.get("repair_action_plan") or repair_action_plan.get("actions")
    if isinstance(maybe, list):
        return [x for x in maybe if isinstance(x, dict)]
    return []


def deterministic_repair_triage(
    *,
    cfg: RepairRefinementConfig,
    cbmc_status: Optional[JsonDict],
    counterexample_analysis: Optional[JsonDict],
    repair_guidance: Optional[JsonDict],
    repair_action_plan: Optional[JsonDict],
    original_harness_text: Optional[str],
) -> JsonDict:
    result_class = result_classification_from_inputs(cbmc_status, counterexample_analysis)
    interpretation_input: JsonDict = dict(cbmc_status or {})
    interpretation_input.setdefault("result_classification", result_class)
    failure_classification = (counterexample_analysis or {}).get("failure_classification", {})
    if isinstance(failure_classification, dict):
        for key in ("emitted_failure_count", "emitted_unknown_count"):
            if key not in interpretation_input and key in failure_classification:
                interpretation_input[key] = failure_classification[key]
    interpretation = interpret_tool_result(interpretation_input)
    actions = flatten_repair_actions(repair_action_plan)

    decision = str(interpretation["triage_decision"])
    repair_needed = bool(interpretation["repair_needed"])
    selected_claim_passed = interpretation.get("semantic_outcome") == "selected_property_passed_auxiliary_failed_or_unknown"
    allowed_repair_scope = (
        ["auxiliary_safety_model", "cbmc_command_or_unwind", "harness_supporting_context"]
        if selected_claim_passed
        else ["harness", "assumptions", "assertions", "cbmc_command_or_unwind"]
    )

    # Source code repair is blocked unless explicitly allowed.
    source_repair_blocked = not cfg.allow_source_code_repair

    risky_signals = []
    if original_harness_text:
        if "TODO" in original_harness_text or "FALLBACK-RENDERED" in original_harness_text:
            risky_signals.append("original_harness_contains_todo_or_fallback_marker")
        if re.search(r"assert\s*\(\s*1\s*\)", original_harness_text):
            risky_signals.append("original_harness_trivial_assert_true")
        if re.search(r"assert\s*\(\s*0\s*\)", original_harness_text):
            risky_signals.append("original_harness_trivial_assert_false")

    guidance_text = json.dumps(repair_guidance or {}, ensure_ascii=False).lower()
    if "weaken" in guidance_text or "remove assertion" in guidance_text or "skip assertion" in guidance_text:
        risky_signals.append("guidance_may_weaken_property_or_assertion")
    if "assume" in guidance_text and "assert" in guidance_text:
        risky_signals.append("guidance_mixes_assumption_and_assertion_changes_review_needed")

    suggested_action_types = []
    for a in actions:
        at = a.get("action_type") or a.get("repair_type") or a.get("target_stage")
        if at:
            suggested_action_types.append(str(at))

    return {
        "schema_version": "deterministic_repair_triage.v1",
        "created_utc": utc_now_iso(),
        "target_function": cfg.target_function,
        "result_classification": result_class,
        "semantic_outcome": interpretation["semantic_outcome"],
        "canonical_result_valid": interpretation["canonical_result_valid"],
        "repair_needed": repair_needed,
        "triage_decision": decision,
        "selected_claim_result": interpretation.get("selected_claim_result"),
        "auxiliary_property_result": interpretation.get("auxiliary_property_result"),
        "counterexample_scope": interpretation.get("counterexample_scope"),
        "selected_claim_must_be_preserved": selected_claim_passed,
        "allowed_repair_scope": allowed_repair_scope,
        "source_code_repair_allowed": cfg.allow_source_code_repair,
        "source_code_repair_blocked_by_default": source_repair_blocked,
        "candidate_actions_from_agent8": actions,
        "candidate_action_count": len(actions),
        "suggested_action_types": suggested_action_types,
        "risky_signals": risky_signals,
        "repair_policy": {
            "do_not_silently_apply": True,
            "do_not_weaken_property_without_recording_evidence_loss": True,
            "do_not_modify_implementation_source_by_default": True,
            "prefer_harness_assumption_assertion_command_refinement": True,
            "preserve_passing_selected_claim_when_only_auxiliary_checks_fail": True,
        },
        "trust_boundary": "deterministic_repair_triage_advisory_only",
        "limitations": [
            "This triage is heuristic and does not replace LLM/human review.",
            "It does not prove that a proposed repair is correct.",
            "Raw CBMC output and Agent 8 analysis remain key evidence.",
        ],
    }


def write_deterministic_files(layout: RunLayout, triage: JsonDict) -> Dict[str, Path]:
    stage = "09_repair_refinement"
    paths: Dict[str, Path] = {}

    paths["repair_triage"] = layout.write_deterministic_reference_json(
        stage,
        "08_repair_triage.deterministic.json",
        triage,
    )

    paths["repair_decision_log_deterministic"] = layout.write_deterministic_reference_json(
        stage,
        "08_repair_decision_log.deterministic.json",
        {
            "created_utc": utc_now_iso(),
            "triage_decision": triage.get("triage_decision"),
            "repair_needed": triage.get("repair_needed"),
            "result_classification": triage.get("result_classification"),
            "trust_boundary": "deterministic_repair_decision_advisory_only",
        },
    )

    actions = triage.get("candidate_actions_from_agent8", [])
    paths["repair_action_plan_consumed_csv"] = write_csv(
        layout.deterministic_reference_dir(stage) / "08_repair_action_plan_consumed.deterministic.csv",
        actions if isinstance(actions, list) else [],
    )

    risky_rows = [{"risk_signal": x} for x in triage.get("risky_signals", [])]
    paths["repair_risk_signals_csv"] = write_csv(
        layout.deterministic_reference_dir(stage) / "08_repair_risk_signals.deterministic.csv",
        risky_rows,
        fieldnames=["risk_signal"],
    )

    return paths


# ---------------------------------------------------------------------------
# Prompt and mock output
# ---------------------------------------------------------------------------

def build_agent9_prompt(cfg: RepairRefinementConfig, availability: Mapping[str, bool], result_classification: str, triage_decision: str) -> str:
    responsibilities = """
- Propose a candidate repair/refinement plan based on Agent 8 analysis and raw tool evidence.
- Separate harness repair, assumption repair, assertion repair, CBMC-command/unwind repair, and source-code repair.
- Block source-code repair unless explicitly justified and allowed by workflow policy.
- Preserve the original semantic property record unless an explicit, evidence-supported change is necessary.
- You may explicitly switch harness/contract/hybrid strategy when that is the smallest evidence-supported repair; never preserve a broken strategy merely because it was previously selected.
- Produce a complete repaired bundle, not a delta mixed with stale plan/manifest/readiness files.
- If a repair weakens an assumption, assertion, property, or evidence claim, explicitly record the evidence strength lost.
- Do not make assertions trivially true by adding over-strong assumptions.
- Do not remove failing assertions merely to get CBMC success.
- For old-state/new-state errors, propose explicit pre-call snapshots and correct post-call assertions.
- For tool/infrastructure errors, propose environment, include-path, build, timeout, or unwind fixes before semantic repair.
- For verification success, do not invent repairs; propose scope/evaluation follow-up only.
- Produce a safe rerun recommendation for the next workflow iteration.
- Provide evidence references for every proposed repair.
""".strip()

    prohibitions = """
- Do not claim the repair is correct.
- Do not claim CBMC will pass after repair.
- Do not claim implementation correctness, FIPS compliance, or cryptographic security.
- Do not silently weaken the property.
- Do not remove assertions just to obtain a green result.
- Do not add assumptions that make the assertion tautological.
- Do not modify implementation source code unless explicitly allowed and justified.
- Do not overwrite the original generated harness.
- Do not hide evidence loss caused by a repair.
- Do not invent counterexample facts not supported by Agent 7/8 or pre-Agent-7 readiness evidence.
- Do not reuse unsupported CBMC pseudo-syntax; use only the supplied version-bound capability profile.
""".strip()

    task = f"""
This stage proposes candidate repairs/refinements after Agent 8 counterexample/tool-result analysis.

Target function: {cfg.target_function}
Target topic: {cfg.target_topic}
Agent 7/8 result classification: {result_classification}
Deterministic triage decision: {triage_decision}

Available evidence:
- Agent 8 counterexample analysis: {availability.get("counterexample_analysis")}
- Agent 8 repair guidance: {availability.get("repair_guidance")}
- Agent 8 repair action plan: {availability.get("repair_action_plan")}
- Agent 7 CBMC status/output/property results: {availability.get("cbmc_status")}
- Agent 5 artefact plan: {availability.get("artifact_plan")}
- Original generated harness: {availability.get("generated_harness")}
- Agent 6 critic review/gate: {availability.get("critic_review")}

Your output is a candidate repair plan, not an applied patch and not a proof.

If no formal tool result exists because route readiness failed, use the supplied pre-Agent-7 diagnosis to repair the exact parser, transformation, traceability, capability, or claim-generation defect. Do not invent a counterexample.
If CBMC succeeded, propose no counterexample repair; record scope/evaluation follow-up only.
If CBMC failed, propose the smallest repair consistent with preserving the intended property.

For a native-contract campaign, candidate_repaired_contract_plan must be a COMPLETE replacement
contract plan, not a prose delta. Copy unchanged clauses from the reviewed Agent 5 plan and change
only evidence-supported fields. Loop-contract source operations must use
insert_loop_contract_after_guard with one exact guard/header anchor; Python—not the model—renders
annotations into a copied source file. Never rewrite the loop body or production repository.
Every candidate repaired requires/ensures/assigns/frees/invariant/decreases clause must use a typed clause record with separate description and executable_expression fields. Use only constructs in the supplied CBMC capability profile; prohibit mathematical/Python/Rust/ACSL slice notation.
For a relational campaign, candidate_repaired_relational_plan must be a complete replacement plan.
For analysis-only campaigns, preserve formal_claim_prohibited=true.
""".strip()

    schema_summary = """
Top-level required fields:
- stage
- repair_decision
- repair_scope
- proposed_repairs
- assumption_changes
- assertion_changes
- harness_changes
- contract_changes
- command_or_environment_changes
- source_code_changes
- evidence_strength_impact
- safety_review
- rerun_recommendation
- candidate_repaired_harness_code
- candidate_repaired_semantic_property
- candidate_repaired_strategy_selection
- semantic_property_change_acknowledgement
- candidate_repaired_traceability_manifest
- candidate_repaired_contract_plan
- candidate_repaired_relational_plan
- candidate_repaired_analysis_only_plan
- deterministic_reference_assessment
- evidence_references
- limitations

Every proposed repair should include:
- repair_id
- repair_type
- target_file_or_stage
- proposed_change
- evidence_basis
- preserves_property_strength
- risk_if_applied
- evidence_strength_lost_if_any
- requires_human_review
""".strip()

    return build_common_stage_prompt(
        stage_name="Agent 9 — Repair/Refinement Agent",
        task_description=task,
        responsibilities=responsibilities,
        prohibitions=prohibitions,
        schema_summary=schema_summary,
        include_non_copying_rule=True,
    )


def build_mock_repair_plan(cfg: RepairRefinementConfig, triage: JsonDict) -> JsonDict:
    result_class = triage.get("result_classification", "unknown")
    decision = triage.get("triage_decision", "manual_review_required")
    return {
        "stage": "09_repair_refinement",
        "mock": True,
        "llm_call_executed": False,
        "repair_decision": {
            "decision": "mock_no_real_repair_plan",
            "based_on_result_classification": result_class,
            "deterministic_triage_decision": decision,
        },
        "repair_scope": {
            "allowed": triage.get("allowed_repair_scope", []),
            "source_code_repair_allowed": cfg.allow_source_code_repair,
            "apply_repair_requested": cfg.apply_repair,
            "note": "Mock mode only."
        },
        "proposed_repairs": [],
        "assumption_changes": [],
        "assertion_changes": [],
        "harness_changes": [],
        "contract_changes": [],
        "command_or_environment_changes": [],
        "source_code_changes": [],
        "evidence_strength_impact": {
            "status": "not_assessed_in_mock_mode",
            "evidence_strength_lost_if_any": "unknown_mock_mode"
        },
        "safety_review": {
            "status": "not_reviewed_in_mock_mode",
            "blocks_silent_application": True
        },
        "rerun_recommendation": {
            "recommend_rerun": False,
            "reason": "Mock output cannot recommend a real rerun.",
            "next_stage": "human_review"
        },
        "candidate_repaired_harness_code": "",
        "candidate_repaired_semantic_property": normalize_semantic_property(
            {
                "property_id": "MOCK_ONLY",
                "candidate_statement": "Mock mode only.",
                "target_call": {"function": cfg.target_function, "arguments": [], "call_count": 1},
                "semantic_property": {
                    "property_id": "MOCK_ONLY",
                    "statement": "Mock mode only.",
                    "target_call": {"function": cfg.target_function, "arguments": [], "call_count": 1},
                    "pre_state_objects": [],
                    "post_state_objects": [],
                    "quantified_domain": {"variable": "", "lower_bound": "", "upper_bound_exclusive": ""},
                    "success_predicate": "",
                    "required_assumptions": [],
                    "observed_memory": [],
                    "permitted_writes": [],
                    "requires_pre_state_snapshot": False,
                    "requires_modular_call_replacement": False,
                    "requires_loop_reasoning": False,
                    "requires_relational_execution": False,
                    "analysis_only": False,
                    "evidence_references": [],
                    "uncertainty": "Mock mode only."
                },
            },
            target_function=cfg.target_function,
        ),
        "candidate_repaired_strategy_selection": {
            "requested_strategy": "",
            "selected_strategy": "standard_cbmc_harness",
            "selection_authority": "mock_wiring_policy",
            "selection_reason": "Mock mode only.",
            "family_recommendation_considered": "",
            "family_recommendation_was_authoritative": False,
            "llm_feasibility_was_authoritative": False
        },
        "semantic_property_change_acknowledgement": {
            "semantic_property_changed": False,
            "potential_weakening": False,
            "user_authorized_weakening": False,
            "authorization_reference": "",
            "reason": "Mock mode only."
        },
        "candidate_repaired_traceability_manifest": {
            "selected_property_id": "MOCK_ONLY",
            "target_call_marker": "",
            "target_call_identity": "TRACE_TARGET_CALL::MOCK_ONLY",
            "target_call_expression": "",
            "assumption_map": [],
            "claim_map": [],
            "expected_claim_count": 0,
            "non_vacuity_strategy": ["Mock mode only; no formal claim or mutation result."]
        },
        "candidate_repaired_contract_plan": {
            "enabled": False,
            "contract_mode": "none",
            "target_symbol": "",
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
            "invariant_initialization_argument": "",
            "invariant_preservation_argument": "",
            "postcondition_use_argument": "",
            "frame_condition_argument": "",
            "history_variable_usage": []
        },
        "candidate_repaired_relational_plan": {
            "enabled": False,
            "relation_kind": "none",
            "first_call": "",
            "second_call": "",
            "state_reset_or_snapshot": [],
            "relation_assertions": [],
            "normalization_assumptions": []
        },
        "candidate_repaired_analysis_only_plan": {
            "enabled": False,
            "analysis_kind": "none",
            "evidence_to_collect": [],
            "external_tools_or_tests": [],
            "formal_claim_prohibited": True
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
            "No API-backed repair/refinement reasoning was performed.",
            "Do not use this output as thesis evidence for LLM repair performance.",
        ],
    }


# ---------------------------------------------------------------------------
# Rendering / safety review
# ---------------------------------------------------------------------------

def render_candidate_repair_outputs(
    *,
    layout: RunLayout,
    cfg: RepairRefinementConfig,
    config_data: Optional[JsonDict] = None,
    repair_plan: JsonDict,
    original_artifact_plan: Optional[JsonDict] = None,
    original_harness_path: Optional[Path],
    original_harness_text: Optional[str],
) -> Tuple[Dict[str, Path], JsonDict]:
    """Render a complete, review-gated repaired artefact bundle.

    A repair is promoted only as a bundle: candidate harness pointer/file,
    revised artefact plan, revised manifest, and a fresh anti-copy audit. Native
    loop annotations are inserted only into copied configured sources. The
    repository and the previous candidate are never overwritten.
    """
    config_data = dict(config_data or {})
    stage = "09_repair_refinement"
    output_dir = layout.rendered_outputs_dir(stage)
    validation_dir = layout.validation_dir(stage)
    outputs: Dict[str, Path] = {}
    safety_flags: List[JsonDict] = []

    repaired_code = extract_code_from_repair_plan(repair_plan)
    selected_harness_path: Optional[Path] = None
    if cfg.render_candidate_repaired_harness and repaired_code:
        repaired_path = output_dir / "08_repaired_harness.c"
        atomic_write_text(repaired_path, repaired_code.rstrip() + "\n")
        outputs["repaired_harness"] = repaired_path
        selected_harness_path = repaired_path
        if original_harness_text is not None:
            diff_path = output_dir / "08_repair_diff.patch"
            atomic_write_text(diff_path, make_unified_diff(original_harness_text, repaired_code))
            outputs["repair_diff"] = diff_path
        if re.search(r"assert\s*\(\s*1\s*\)", repaired_code):
            safety_flags.append({"severity": "critical", "flag": "trivial_assert_true_in_repaired_harness"})
        if re.search(r"assert\s*\(\s*0\s*\)", repaired_code):
            safety_flags.append({"severity": "critical", "flag": "trivial_assert_false_in_repaired_harness"})
        if "TODO" in repaired_code or "FALLBACK" in repaired_code:
            safety_flags.append({"severity": "major", "flag": "todo_or_fallback_marker_in_repaired_harness"})
        if cfg.target_function and cfg.target_function not in repaired_code:
            safety_flags.append({"severity": "critical", "flag": "target_function_missing_from_repaired_harness"})
    elif original_harness_path and original_harness_path.is_file():
        selected_harness_path = original_harness_path.resolve()

    campaign = effective_campaign_for_plan(config_data, original_artifact_plan or {})
    original_strategy = str(
        (original_artifact_plan or {}).get("verification_strategy")
        or campaign.get("verification_strategy")
        or "standard_cbmc_harness"
    )
    artifact_policy = (
        config_data.get("formal_artifact_policy", {})
        if isinstance(config_data.get("formal_artifact_policy"), Mapping) else {}
    )
    repaired_selection = (
        repair_plan.get("candidate_repaired_strategy_selection", {})
        if isinstance(repair_plan.get("candidate_repaired_strategy_selection"), Mapping) else {}
    )
    strategy = str(repaired_selection.get("selected_strategy") or original_strategy)
    strategy_changed = strategy != original_strategy
    supported_strategies = {
        "standard_cbmc_harness", "native_function_contract", "native_loop_contract",
        "relational_cbmc_harness", "hybrid_contract_and_harness",
        "analysis_only_no_formal_claim",
    }
    if strategy not in supported_strategies:
        safety_flags.append({
            "severity": "critical", "flag": "unsupported_repaired_strategy",
            "selected_strategy": strategy,
        })
    if strategy_changed and not bool(artifact_policy.get("allow_strategy_switch_during_repair", True)):
        safety_flags.append({
            "severity": "critical", "flag": "strategy_switch_not_allowed_by_policy",
            "original_strategy": original_strategy, "repaired_strategy": strategy,
        })

    original_semantic = (
        (original_artifact_plan or {}).get("semantic_property", {})
        if isinstance((original_artifact_plan or {}).get("semantic_property"), Mapping) else {}
    )
    repaired_semantic_raw = (
        repair_plan.get("candidate_repaired_semantic_property", {})
        if isinstance(repair_plan.get("candidate_repaired_semantic_property"), Mapping) else original_semantic
    )
    repaired_semantic = normalize_semantic_property(repaired_semantic_raw, target_function=cfg.target_function)
    semantic_difference = compare_semantic_properties(
        original_semantic, repaired_semantic, target_function=cfg.target_function
    )
    semantic_ack = (
        repair_plan.get("semantic_property_change_acknowledgement", {})
        if isinstance(repair_plan.get("semantic_property_change_acknowledgement"), Mapping) else {}
    )
    acknowledged_changed = bool(semantic_ack.get("semantic_property_changed"))
    if bool(semantic_difference.get("same_semantic_property")) == acknowledged_changed:
        safety_flags.append({
            "severity": "critical", "flag": "semantic_change_acknowledgement_mismatch",
            "semantic_difference": semantic_difference, "acknowledgement": dict(semantic_ack),
        })
    if bool(semantic_difference.get("potential_weakening")):
        weakening_authorized = (
            bool(artifact_policy.get("allow_user_authorized_semantic_weakening", True))
            and bool(semantic_ack.get("potential_weakening"))
            and bool(semantic_ack.get("user_authorized_weakening"))
            and bool(str(semantic_ack.get("authorization_reference") or "").strip())
        )
        if not weakening_authorized:
            safety_flags.append({
                "severity": "critical", "flag": "semantic_property_weakening_not_authorized",
                "semantic_difference": semantic_difference, "acknowledgement": dict(semantic_ack),
            })

    semantic_difference_path = validation_dir / "08_semantic_property_difference.json"
    atomic_write_json(semantic_difference_path, semantic_difference)
    outputs["semantic_property_difference"] = semantic_difference_path

    contract_repair = repair_plan.get("candidate_repaired_contract_plan")
    relational_repair = repair_plan.get("candidate_repaired_relational_plan")
    analysis_repair = repair_plan.get("candidate_repaired_analysis_only_plan")
    any_plan_change = any([
        isinstance(contract_repair, Mapping) and bool(contract_repair.get("enabled")),
        isinstance(relational_repair, Mapping) and bool(relational_repair.get("enabled")),
        isinstance(analysis_repair, Mapping) and bool(analysis_repair.get("enabled")),
    ])
    repair_requested = bool(repaired_code) or any_plan_change

    contract_summary: JsonDict = {
        "verification_strategy": strategy,
        "contract_enabled": False,
        "contract_valid": True,
        "instrumented_source_files": [],
        "contract_header": None,
        "contract_instrumentation_manifest": None,
        "contract_instrumentation_diff": None,
        "production_source_modified": False,
    }

    if repair_requested and isinstance(original_artifact_plan, Mapping):
        revised_plan = deepcopy(dict(original_artifact_plan))
        revised_plan["verification_strategy"] = strategy
        revised_plan["strategy_selection"] = deepcopy(dict(repaired_selection))
        revised_plan["semantic_property"] = repaired_semantic
        if repaired_code:
            revised_plan["generated_harness_code"] = repaired_code.rstrip() + "\n"
        if isinstance(contract_repair, Mapping):
            revised_plan["contract_plan"] = deepcopy(dict(contract_repair))
        if isinstance(relational_repair, Mapping):
            revised_plan["relational_plan"] = deepcopy(dict(relational_repair))
        if isinstance(analysis_repair, Mapping):
            revised_plan["analysis_only_plan"] = deepcopy(dict(analysis_repair))
        repaired_traceability = repair_plan.get("candidate_repaired_traceability_manifest")
        if isinstance(repaired_traceability, Mapping):
            revised_plan["traceability_manifest"] = deepcopy(dict(repaired_traceability))

        schema_errors = sorted(
            error.message for error in Draft202012Validator(ARTIFACT_PLAN_SCHEMA).iter_errors(revised_plan)
        )
        campaign_validation = validate_artifact_plan_for_campaign(revised_plan, campaign)
        campaign_validation_path = validation_dir / "08_repaired_property_campaign_validation.json"
        atomic_write_json(campaign_validation_path, campaign_validation)
        outputs["repaired_property_campaign_validation"] = campaign_validation_path
        if schema_errors:
            safety_flags.append({
                "severity": "critical", "flag": "candidate_repaired_artifact_plan_schema_invalid",
                "errors": schema_errors,
            })
        if not campaign_validation.get("valid"):
            safety_flags.append({
                "severity": "critical", "flag": "candidate_repaired_artifact_plan_campaign_invalid",
                "errors": campaign_validation.get("errors", []),
            })

        semantic_validation = validate_artifact_semantics(
            artifact_plan=revised_plan,
            harness_text=(repaired_code or original_harness_text or ""),
            target_function=cfg.target_function,
            property_campaign=campaign,
        )
        semantic_validation_path = validation_dir / "08_repaired_semantic_traceability_validation.json"
        atomic_write_json(semantic_validation_path, semantic_validation)
        outputs["repaired_semantic_traceability_validation"] = semantic_validation_path
        for issue in semantic_validation.get("blocking_issues", []):
            safety_flags.append({
                "severity": "critical",
                "flag": str(issue.get("issue_id") or "repaired_semantic_traceability_invalid"),
                "details": issue,
            })

        if not schema_errors and campaign_validation.get("valid") and semantic_validation.get("valid"):
            contract_plan = revised_plan.get("contract_plan", {})
            contract_validation = validate_contract_plan(contract_plan, strategy)
            contract_validation_path = validation_dir / "08_repaired_contract_plan_validation.json"
            atomic_write_json(contract_validation_path, {
                "schema_version": "repaired_contract_plan_validation.v2",
                "verification_strategy": strategy,
                **contract_validation,
            })
            outputs["repaired_contract_plan_validation"] = contract_validation_path
            if not contract_validation.get("valid"):
                safety_flags.append({
                    "severity": "critical", "flag": "candidate_repaired_contract_plan_invalid",
                    "errors": list(contract_validation.get("errors", [])),
                })
            else:
                contract_dir = output_dir / "contract_repair"
                contract_candidate_files: List[Path] = []
                if bool(contract_plan.get("enabled")):
                    allowed_sources = [
                        Path(str(value)).expanduser().resolve()
                        for value in ((config_data.get("inputs") or {}).get("code_paths", []) or [])
                    ]
                    instrumented, contract_manifest, contract_diff = apply_contract_source_patches(
                        contract_plan,
                        project_root=Path(str(config_data.get("project_root") or PROJECT_ROOT)).resolve(),
                        output_dir=contract_dir / "instrumented_sources",
                        allowed_source_paths=allowed_sources,
                    )
                    for index, path in enumerate(instrumented, start=1):
                        outputs[f"repaired_instrumented_source_{index:02d}"] = path
                    manifest_path = contract_dir / "08_repaired_contract_instrumentation_manifest.json"
                    atomic_write_json(manifest_path, contract_manifest)
                    outputs["repaired_contract_instrumentation_manifest"] = manifest_path
                    diff_path = contract_dir / "08_repaired_contract_instrumentation.patch"
                    atomic_write_text(diff_path, contract_diff)
                    outputs["repaired_contract_instrumentation_diff"] = diff_path
                    header_text = build_contract_header(
                        contract_plan,
                        required_includes=[str(x) for x in revised_plan.get("required_includes", [])]
                        if isinstance(revised_plan.get("required_includes"), list) else [],
                    )
                    header_path: Optional[Path] = None
                    if header_text:
                        header_path = contract_dir / "08_repaired_function_contract.h"
                        atomic_write_text(header_path, header_text)
                        outputs["repaired_contract_header"] = header_path
                        contract_candidate_files.append(header_path)
                    contract_summary = {
                        "verification_strategy": strategy,
                        "contract_enabled": True,
                        "contract_valid": True,
                        "instrumented_source_files": [str(path) for path in instrumented],
                        "contract_header": str(header_path) if header_path else None,
                        "contract_instrumentation_manifest": str(manifest_path),
                        "contract_instrumentation_diff": str(diff_path),
                        "production_source_modified": False,
                    }

                if selected_harness_path and selected_harness_path.is_file():
                    revised_plan_path = output_dir / "08_repaired_artifact_plan.json"
                    atomic_write_json(revised_plan_path, revised_plan)
                    outputs["repaired_artifact_plan"] = revised_plan_path

                    references = explicit_prohibited_reference_files(config_data)
                    candidate_files = [selected_harness_path, *contract_candidate_files]
                    audit, rows = audit_candidate_files(candidate_files, references)
                    audit_path = validation_dir / "08_repaired_independence_audit.json"
                    audit_csv_path = validation_dir / "08_repaired_similarity_audit_details.csv"
                    write_audit(audit_path, audit_csv_path, audit, rows)
                    outputs["repaired_independence_audit"] = audit_path
                    outputs["repaired_similarity_audit_details"] = audit_csv_path

                    repaired_manifest = {
                        "schema_version": "artifact_manifest.v3.complete_repair_bundle",
                        "created_utc": utc_now_iso(),
                        "stage": stage,
                        "target_function": cfg.target_function,
                        "target_topic": cfg.target_topic,
                        "verification_strategy": strategy,
                        "original_verification_strategy": original_strategy,
                        "strategy_switched_during_repair": strategy_changed,
                        "semantic_property_difference": semantic_difference,
                        "property_family_id": campaign.get("property_family_id"),
                        "artefacts": {
                            "artifact_plan": str(revised_plan_path),
                            "generated_harness": str(selected_harness_path),
                            "independence_audit": str(audit_path),
                            "contract_outputs": {
                                key: str(value) for key, value in outputs.items()
                                if key.startswith("repaired_contract_") or key.startswith("repaired_instrumented_source_")
                            },
                        },
                        "checksums_sha256": {
                            "artifact_plan": sha256_file(revised_plan_path),
                            "generated_harness": sha256_file(selected_harness_path),
                            "independence_audit": sha256_file(audit_path),
                            "contract_outputs": {
                                key: sha256_file(Path(value)) for key, value in outputs.items()
                                if (key.startswith("repaired_contract_") or key.startswith("repaired_instrumented_source_"))
                                and Path(value).is_file()
                            },
                        },
                        "contract_summary": contract_summary,
                        "repair_provenance": {
                            "repair_plan_source": "08_repair_plan.json",
                            "iteration": cfg.iteration,
                            "reason": cfg.reason,
                            "original_harness": str(original_harness_path) if original_harness_path else None,
                            "production_source_modified": False,
                        },
                        "trust_boundary": {
                            "artifact_plan": "llm_candidate_repair_plan_requiring_agent6_review",
                            "generated_harness": "candidate_harness_requiring_agent6_review",
                            "independence_audit": "fresh_deterministic_similarity_screen_for_this_bundle",
                            "formal_truth": "not_claimed",
                        },
                    }
                    repaired_manifest_path = output_dir / "08_repaired_artifact_manifest.json"
                    atomic_write_json(repaired_manifest_path, repaired_manifest)
                    outputs["repaired_artifact_manifest"] = repaired_manifest_path
                else:
                    safety_flags.append({
                        "severity": "critical", "flag": "repaired_artifact_plan_has_no_candidate_harness_binding",
                    })
    elif repair_requested:
        safety_flags.append({
            "severity": "critical", "flag": "repair_requested_without_original_artifact_plan_complete_bundle_unavailable",
        })

    plan_text = json.dumps(repair_plan, ensure_ascii=False).lower()
    weakening_terms = ["remove assertion", "delete assertion", "weaken", "skip check", "disable assertion", "assume false"]
    found = [term for term in weakening_terms if term in plan_text]
    if found:
        safety_flags.append({"severity": "major", "flag": "possible_property_weakening_language", "terms": found})

    proposed_source_changes = repair_plan.get("source_code_changes")
    if isinstance(proposed_source_changes, list) and proposed_source_changes and not cfg.allow_source_code_repair:
        safety_flags.append({
            "severity": "critical", "flag": "production_source_changes_proposed_but_not_allowed",
            "proposed_change_count": len(proposed_source_changes),
            "policy": "Production implementation code is never modified unless explicitly enabled and human-reviewed.",
        })

    complete_bundle = all(key in outputs for key in (
        "repaired_artifact_plan", "repaired_artifact_manifest", "repaired_independence_audit"
    )) and bool(selected_harness_path and selected_harness_path.is_file())
    metadata = {
        "schema_version": "repair_render_metadata.v3.complete_bundle",
        "created_utc": utc_now_iso(),
        "source": "08_repair_plan.json",
        "original_harness": str(original_harness_path) if original_harness_path else None,
        "selected_candidate_harness": str(selected_harness_path) if selected_harness_path else None,
        "selected_candidate_harness_sha256": sha256_file(selected_harness_path) if selected_harness_path and selected_harness_path.is_file() else None,
        "repaired_harness_physically_created": "repaired_harness" in outputs,
        "complete_repaired_bundle_created": complete_bundle,
        "production_source_modified": False,
        "applied_to_original": False,
        "apply_repair_requested": cfg.apply_repair,
        "source_code_repair_allowed": cfg.allow_source_code_repair,
    }
    metadata_path = output_dir / "08_repair_render_metadata.json"
    atomic_write_json(metadata_path, metadata)
    outputs["repair_render_metadata"] = metadata_path

    safety = {
        "schema_version": "repair_safety_review.v3.complete_bundle",
        "created_utc": utc_now_iso(),
        "rendered": bool(outputs),
        "complete_repaired_bundle_created": complete_bundle,
        "safety_flags": safety_flags,
        "requires_human_review": True,
        "silent_application_blocked": True,
        "applied_to_original": False,
        "production_source_modified": False,
        "candidate_harness_path": str(selected_harness_path) if selected_harness_path else None,
        "formal_claim_boundary": {
            "repair_correctness_claimed": False,
            "cbmc_success_claimed": False,
            "full_correctness_claimed": False,
            "fips_compliance_claimed": False,
        },
    }
    safety_path = validation_dir / "08_repair_safety_review.json"
    atomic_write_json(safety_path, safety)
    outputs["repair_safety_review"] = safety_path
    return outputs, safety

def derive_change_csvs(layout: RunLayout, repair_plan: JsonDict) -> Dict[str, Path]:
    stage = "09_repair_refinement"
    outputs: Dict[str, Path] = {}

    def list_from(key: str) -> List[JsonDict]:
        value = repair_plan.get(key)
        if isinstance(value, list):
            return [x for x in value if isinstance(x, dict)]
        return []

    outputs["assumption_changes_csv"] = write_csv(
        layout.validation_dir(stage) / "08_assumption_changes.csv",
        list_from("assumption_changes"),
    )
    outputs["assertion_changes_csv"] = write_csv(
        layout.validation_dir(stage) / "08_assertion_changes.csv",
        list_from("assertion_changes"),
    )
    outputs["harness_changes_csv"] = write_csv(
        layout.validation_dir(stage) / "08_harness_changes.csv",
        list_from("harness_changes"),
    )
    outputs["proposed_repairs_csv"] = write_csv(
        layout.validation_dir(stage) / "08_proposed_repairs.csv",
        list_from("proposed_repairs"),
    )

    return outputs


def write_repair_manifest_update(
    *,
    layout: RunLayout,
    cfg: RepairRefinementConfig,
    repair_plan_path: Path,
    rendered_outputs: Mapping[str, Path],
    safety_review: JsonDict,
) -> Path:
    stage = "09_repair_refinement"
    manifest = {
        "schema_version": "repair_manifest_update.v1",
        "created_utc": utc_now_iso(),
        "stage": stage,
        "target_function": cfg.target_function,
        "repair_plan": str(repair_plan_path),
        "rendered_outputs": {k: str(v) for k, v in rendered_outputs.items()},
        "apply_repair_requested": cfg.apply_repair,
        "applied_to_original": False,
        "source_code_repair_allowed": cfg.allow_source_code_repair,
        "requires_human_review": safety_review.get("requires_human_review", True),
        "silent_application_blocked": True,
        "next_recommended_stages": [
            "06_review_critic for repaired candidate review",
            "07_tool_execution only after review gate approval"
        ],
        "trust_boundary": {
            "repair_plan": "llm_authoritative_candidate_repair_plan_not_proof",
            "repaired_harness": "candidate_rendered_output_not_applied",
            "formal_truth": "not_claimed",
        },
    }
    path = layout.rendered_outputs_dir(stage) / "08_repair_manifest_update.json"
    return atomic_write_json(path, manifest)


# ---------------------------------------------------------------------------
# Main runner
# ---------------------------------------------------------------------------

def run_agent9(config_data: JsonDict, cfg: RepairRefinementConfig) -> int:
    stage = "09_repair_refinement"
    layout = RunLayout(
        cfg.run_dir,
        create=False,
        active_iteration=cfg.iteration,
        active_reason=cfg.reason,
    )
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 9 Repair/Refinement started.",
        data={
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
            "apply_repair": cfg.apply_repair,
            "allow_source_code_repair": cfg.allow_source_code_repair,
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
        # 1. Load Agent 8 analysis/guidance and context.
        # --------------------------------------------------------------
        cex_path, cex_analysis, cex_status = load_handoff_json(layout, "08_counterexample_analysis", "counterexample_analysis")
        guidance_path, repair_guidance, guidance_status = load_handoff_json(layout, "08_counterexample_analysis", "repair_guidance")
        action_path, repair_action_plan, action_status = load_handoff_json(layout, "08_counterexample_analysis", "repair_action_plan")
        failure_matrix_path, failure_matrix, failure_matrix_status = load_handoff_json(layout, "08_counterexample_analysis", "failure_classification_matrix")
        diagnosis_path, diagnosis, diagnosis_status = load_handoff_json(layout, "08_counterexample_analysis", "tool_vs_harness_vs_code_diagnosis")

        cbmc_status_path, cbmc_status, cbmc_status_status = load_handoff_json(layout, "07_tool_execution", "cbmc_status")
        cbmc_output_path, cbmc_output, cbmc_output_status = load_handoff_text(layout, "07_tool_execution", "cbmc_output", max_chars=cfg.max_text_chars)
        cbmc_stderr_path, cbmc_stderr, cbmc_stderr_status = load_handoff_text(layout, "07_tool_execution", "cbmc_stderr", max_chars=cfg.max_text_chars)
        command_manifest_path, command_manifest, command_manifest_status = load_handoff_json(layout, "07_tool_execution", "tool_command_manifest")
        property_results_path, property_results, property_results_status = load_handoff_json(layout, "07_tool_execution", "cbmc_property_results")

        artifact_plan_path, artifact_plan, artifact_plan_status = load_handoff_json(
            layout, "06_review_critic", "artifact_plan_under_review"
        )
        if not artifact_plan:
            artifact_plan_path, artifact_plan, artifact_plan_status = load_handoff_json(
                layout, "05_artifact_generation", "artifact_plan"
            )
        effective_campaign = effective_campaign_for_plan(config_data, artifact_plan or {})
        original_harness_path, original_harness_text, harness_status = load_handoff_text(layout, "06_review_critic", "generated_harness_under_review", max_chars=cfg.max_text_chars)
        critic_review_path, critic_review, critic_review_status = load_handoff_json(layout, "06_review_critic", "critic_review")
        review_gate_path, review_gate, review_gate_status = load_handoff_json(layout, "06_review_critic", "review_gate_decision")

        statuses = {
            "counterexample_analysis": cex_status,
            "repair_guidance": guidance_status,
            "repair_action_plan": action_status,
            "failure_classification_matrix": failure_matrix_status,
            "tool_vs_harness_vs_code_diagnosis": diagnosis_status,
            "cbmc_status": cbmc_status_status,
            "cbmc_output": cbmc_output_status,
            "cbmc_stderr": cbmc_stderr_status,
            "tool_command_manifest": command_manifest_status,
            "cbmc_property_results": property_results_status,
            "artifact_plan": artifact_plan_status,
            "generated_harness": harness_status,
            "critic_review": critic_review_status,
            "review_gate_decision": review_gate_status,
        }
        availability = {k: bool(v.get("available")) for k, v in statuses.items()}

        required = (
            ["critic_review", "review_gate_decision", "generated_harness"]
            if cfg.reason == "critic_review"
            else ["counterexample_analysis", "repair_guidance", "repair_action_plan"]
        )
        missing_required = [k for k in required if not availability.get(k)]
        if missing_required and not cfg.allow_missing_inputs:
            raise FileNotFoundError(
                f"Agent 9 missing required inputs for repair reason {cfg.reason!r}: {missing_required}. "
                "Use --allow-missing-inputs only for wiring tests."
            )

        for k, st in statuses.items():
            if not st.get("available"):
                stage_status["warnings"].append(f"{k} unavailable: {st.get('warning')}")

        # --------------------------------------------------------------
        # 2. Deterministic repair triage.
        # --------------------------------------------------------------
        triage = deterministic_repair_triage(
            cfg=cfg,
            cbmc_status=cbmc_status,
            counterexample_analysis=cex_analysis,
            repair_guidance=repair_guidance,
            repair_action_plan=repair_action_plan,
            original_harness_text=original_harness_text,
        )

        previous_inputs_record = layout.write_deterministic_reference_json(
            stage,
            "08_previous_stage_input_status.json",
            {
                "trust_boundary": "previous_outputs_are_candidate_context_raw_tool_output_remains_primary",
                "statuses": statuses,
                "availability": availability,
                "result_classification": triage.get("result_classification"),
            },
        )

        deterministic_paths = write_deterministic_files(layout, triage)
        deterministic_paths["previous_stage_input_status"] = previous_inputs_record

        deterministic_bundle = {
            "deterministic_repair_triage": triage,
            "previous_stage_input_status": {
                "statuses": statuses,
                "availability": availability,
            },
            "evidence_preview": {
                "counterexample_analysis": cex_analysis,
                "repair_guidance": repair_guidance,
                "repair_action_plan": repair_action_plan,
                "failure_classification_matrix": failure_matrix,
                "tool_vs_harness_vs_code_diagnosis": diagnosis,
                "cbmc_status": cbmc_status,
                "cbmc_property_results": property_results,
                "artifact_plan": artifact_plan,
                "critic_review": critic_review,
                "review_gate": review_gate,
                "original_harness_path": str(original_harness_path) if original_harness_path else None,
                "original_harness_text": original_harness_text,
            },
        }

        # --------------------------------------------------------------
        # 3. LLM repair plan.
        # --------------------------------------------------------------
        result_class = triage.get("result_classification", "unknown")
        triage_decision = triage.get("triage_decision", "manual_review_required")
        prompt_text = build_agent9_prompt(cfg, availability, result_class, triage_decision)
        prompt_text += (
            "\n\nRepair trigger contract:\n"
            f"- trigger_reason: {cfg.reason}\n"
            f"- iteration: {cfg.iteration}\n"
            "When trigger_reason is critic_review, base the repair on Agent 6 critic findings and gate evidence; "
            "do not invent a CBMC counterexample. When trigger_reason is counterexample_analysis, prioritize raw "
            "Agent 7 tool evidence and Agent 8 analysis.\n"
        )

        run_config_for_client = dict(config_data)
        if cfg.llm_mode_override:
            llm_cfg = dict(run_config_for_client.get("llm") or {})
            llm_cfg["mode"] = cfg.llm_mode_override
            run_config_for_client["llm"] = llm_cfg

        client = LLMClient.from_run_config(run_config_for_client)

        primary_files = existing_unique_paths(
            canonical_raw_evidence_files(config_data, include_specs=True, include_code=True)
            + [p for p in [
                cbmc_status_path, cbmc_output_path, cbmc_stderr_path, command_manifest_path
            ] if p]
        )
        # Parsed property summaries and Agent 8 derived matrices/diagnoses remain
        # deterministic advisory material rather than raw formal-tool evidence.
        prior_context_files = existing_unique_paths(
            [p for p in [cex_path, guidance_path, action_path, artifact_plan_path, original_harness_path, critic_review_path, review_gate_path] if p]
        )
        prior_authoritative_context = {
            "counterexample_analysis": cex_analysis,
            "repair_guidance": repair_guidance,
            "repair_action_plan": repair_action_plan,
            "artifact_plan": artifact_plan,
            "critic_review": critic_review,
            "review_gate": review_gate,
        }

        request = LLMStageRequest(
            stage=stage,
            prompt_text=prompt_text,
            output_filename="08_repair_plan.json",
            json_schema=REPAIR_PLAN_SCHEMA,
            primary_evidence_files=primary_files,
            prior_authoritative_context_files=prior_context_files,
            prior_authoritative_context_bundle=prior_authoritative_context,
            deterministic_reference_bundle=deterministic_bundle,
            extra_prompt_metadata={
                "agent": "Agent 9 Repair/Refinement",
                "target_function": cfg.target_function,
                "target_topic": cfg.target_topic,
                "result_classification": result_class,
                "triage_decision": triage_decision,
                "iteration": cfg.iteration,
                "repair_reason": cfg.reason,
                "apply_repair": cfg.apply_repair,
                "allow_source_code_repair": cfg.allow_source_code_repair,
                "trust_boundary": {
                    "raw_cbmc_output": "primary_tool_evidence_when_available",
                    "agent8_analysis": "candidate_interpretation_and_guidance",
                    "deterministic_triage": "advisory_only",
                    "llm_output": "authoritative_stage_candidate_repair_plan_not_formal_truth",
                    "rendered_repaired_harness": "candidate_output_not_applied",
                    "formal_truth": "not_claimed",
                },
            },
            mock_response_content=build_mock_repair_plan(cfg, triage),
        )

        result = client.run_stage(layout, request)
        stage_status["llm_call_executed"] = result.llm_call_executed
        stage_status["llm_mode"] = result.mode
        stage_status["llm_success"] = result.success
        record_llm_stage_failure(stage_status, result)

        campaign_repair_validation_path: Optional[Path] = None
        if result.success and result.output_path:
            repair_wrapped_for_campaign = read_json_file(result.output_path)
            repair_for_campaign = extract_content_wrapper(repair_wrapped_for_campaign)
            campaign_repair_validation = validate_repair_plan_for_campaign(
                repair_for_campaign, effective_campaign
            )
            campaign_repair_validation_path = layout.write_validation_json(
                stage, "08_property_campaign_repair_validation.json", campaign_repair_validation
            )
            if not campaign_repair_validation.get("valid"):
                result.success = False
                result.error = "Repair campaign semantic validation failed: " + "; ".join(campaign_repair_validation.get("errors", []))
                stage_status["errors"].append({
                    "type": "PropertyCampaignValidationError",
                    "message": result.error,
                })
                stage_status["llm_success"] = False
                record_llm_stage_failure(stage_status, result)

        # --------------------------------------------------------------
        # 4. Compatibility notes + render candidate repair.
        # --------------------------------------------------------------
        llm_outputs: Dict[str, Path] = {}
        validation_outputs: Dict[str, Path] = {}
        if campaign_repair_validation_path:
            validation_outputs["property_campaign_repair_validation"] = campaign_repair_validation_path
        rendered_outputs: Dict[str, Path] = {}
        prompt_outputs: Dict[str, Path] = {}

        repair_notes_path: Optional[Path] = None
        repair_manifest_update_path: Optional[Path] = None
        safety_review: JsonDict = {
            "rendered": False,
            "requires_human_review": True,
            "silent_application_blocked": True,
        }

        campaign_validation_path: Optional[Path] = None
        if result.success and result.output_path:
            repair_plan_for_campaign = extract_content_wrapper(read_json_file(result.output_path))
            campaign_validation = validate_repair_plan_for_campaign(
                repair_plan_for_campaign, effective_campaign
            )
            campaign_validation_path = layout.write_validation_json(
                stage, "08_property_campaign_repair_validation.json", campaign_validation
            )
            validation_outputs["property_campaign_repair_validation"] = campaign_validation_path
            stage_status["warnings"].extend(campaign_validation.get("warnings", []))
            if not campaign_validation.get("valid"):
                result.success = False
                result.error = "Repair campaign semantic validation failed: " + "; ".join(campaign_validation.get("errors", []))
                stage_status["errors"].append({
                    "type": "PropertyCampaignValidationError",
                    "message": result.error,
                })
                stage_status["llm_success"] = False
                record_llm_stage_failure(stage_status, result)

        if result.success and result.output_path:
            repair_plan_wrapped = read_json_file(result.output_path)
            repair_plan = extract_content_wrapper(repair_plan_wrapped)

            # Compatibility copy as repair notes, but it is a separate schema wrapper, not a duplicate root output.
            repair_notes_path = layout.llm_authoritative_dir(stage) / "08_repair_notes.json"
            atomic_write_json(repair_notes_path, {
                "schema_version": "repair_notes_compatibility.v1",
                "created_utc": utc_now_iso(),
                "source": "08_repair_plan.json",
                "content": {
                    "repair_decision": repair_plan.get("repair_decision"),
                    "summary": repair_plan.get("overall_summary") or repair_plan.get("repair_decision"),
                    "limitations": repair_plan.get("limitations", []),
                },
                "trust_boundary": "compatibility_summary_of_llm_repair_plan_not_separate_authority",
            })
            llm_outputs["repair_notes"] = repair_notes_path

            rendered_outputs, safety_review = render_candidate_repair_outputs(
                layout=layout,
                cfg=cfg,
                config_data=config_data,
                repair_plan=repair_plan,
                original_artifact_plan=artifact_plan,
                original_harness_path=original_harness_path,
                original_harness_text=original_harness_text,
            )

            change_csvs = derive_change_csvs(layout, repair_plan)
            validation_outputs.update(change_csvs)

            repair_manifest_update_path = write_repair_manifest_update(
                layout=layout,
                cfg=cfg,
                repair_plan_path=Path(result.output_path),
                rendered_outputs=rendered_outputs,
                safety_review=safety_review,
            )
            rendered_outputs["repair_manifest_update"] = repair_manifest_update_path

            # Important: even if --apply-repair is true, do not overwrite in this implementation.
            if cfg.apply_repair:
                apply_block_path = layout.validation_dir(stage) / "08_apply_repair_blocked.json"
                atomic_write_json(apply_block_path, {
                    "schema_version": "apply_repair_blocked.v1",
                    "created_utc": utc_now_iso(),
                    "requested": True,
                    "applied": False,
                    "reason": (
                        "This refactored Agent 9 does not silently overwrite previous artefacts. "
                        "Candidate repairs must be reviewed and rerun through Agent 6/7."
                    ),
                    "requires_human_review": True,
                })
                validation_outputs["apply_repair_blocked"] = apply_block_path

        # --------------------------------------------------------------
        # 5. Handoff manifest.
        # --------------------------------------------------------------
        if result.success and result.output_path:
            handoff_outputs: Dict[str, Path] = {
                "repair_plan": Path(result.output_path),
            }
            if repair_notes_path:
                handoff_outputs["repair_notes"] = repair_notes_path
            if result.validation_path:
                handoff_outputs["repair_plan_validation"] = Path(result.validation_path)
            if repair_manifest_update_path:
                handoff_outputs["repair_manifest_update"] = repair_manifest_update_path

            for key in [
                "repaired_harness", "repair_diff", "repair_safety_review", "repair_render_metadata",
                "repaired_artifact_plan", "repaired_artifact_manifest",
                "repaired_independence_audit", "repaired_similarity_audit_details",
                "repaired_property_campaign_validation",
                "repaired_contract_plan_validation", "repaired_contract_header",
                "repaired_contract_instrumentation_manifest", "repaired_contract_instrumentation_diff",
            ]:
                if key in rendered_outputs:
                    handoff_outputs[key] = rendered_outputs[key]
            for key, value in rendered_outputs.items():
                if key.startswith("repaired_instrumented_source_"):
                    handoff_outputs[key] = value
            # A contract-only repair deliberately reuses the existing canonical harness by pointer.
            candidate_harness = safety_review.get("candidate_harness_path")
            if "repaired_harness" not in handoff_outputs and candidate_harness:
                candidate_path = Path(str(candidate_harness)).resolve()
                if candidate_path.is_file() and "repaired_artifact_plan" in handoff_outputs:
                    handoff_outputs["repaired_harness"] = candidate_path

            for key in ["assumption_changes_csv", "assertion_changes_csv", "harness_changes_csv", "proposed_repairs_csv"]:
                if key in validation_outputs:
                    handoff_outputs[key] = validation_outputs[key]

            handoff_outputs["repair_triage_deterministic"] = deterministic_paths["repair_triage"]

            layout.write_handoff_manifest(
                stage,
                outputs=handoff_outputs,
                authoritative_source="llm_authoritative_plus_candidate_rendered_outputs",
                next_stage_consumers=[
                    "06_review_critic",
                    "07_tool_execution",
                    "10_experiment_logger",
                    "11_evaluation_reporter",
                ],
                notes={
                    "handoff_policy": (
                        "repair_plan is LLM-authoritative stage candidate repair plan. "
                        "repaired_harness may be a new candidate or a manifest pointer to the unchanged canonical harness. "
                        "A repaired_artifact_plan/manifest, if present, is re-reviewed before execution and never applied to the repository."
                    ),
                    "llm_mode": result.mode,
                    "llm_call_executed": result.llm_call_executed,
                    "mock_output": result.mode == "mock",
                    "apply_repair_requested": cfg.apply_repair,
                    "iteration": cfg.iteration,
                    "repair_reason": cfg.reason,
                    "applied_to_original": False,
                    "source_code_repair_allowed": cfg.allow_source_code_repair,
                    "requires_human_review": safety_review.get("requires_human_review", True),
                    "formal_truth_claimed": False,
                },
            )
            stage_status["handoff_available"] = True
            stage_status["success"] = True
        else:
            message = "No authoritative LLM repair plan was produced."
            stage_status["warnings"].append(message)
            if cfg.allow_empty_handoff_on_failure:
                layout.write_handoff_manifest(
                    stage,
                    outputs={"repair_triage_deterministic": deterministic_paths["repair_triage"]},
                    authoritative_source="deterministic_triage_only_llm_failed_or_disabled",
                    next_stage_consumers=["10_experiment_logger", "11_evaluation_reporter"],
                    notes={
                        "handoff_policy": "LLM repair plan unavailable; only deterministic triage handed off.",
                        "llm_result": result.to_dict(),
                        "formal_truth_claimed": False,
                    },
                )

        # --------------------------------------------------------------
        # 6. Stage manifest.
        # --------------------------------------------------------------
        if result.output_path:
            llm_outputs["repair_plan"] = Path(result.output_path)
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
            primary_evidence_inputs=[str(p) for p in primary_files],
            deterministic_reference_outputs=deterministic_paths,
            prompt_package_outputs=prompt_outputs,
            llm_authoritative_outputs=llm_outputs,
            rendered_outputs=rendered_outputs,
            validation_outputs=validation_outputs,
            notes={
                "agent_version": "agent9_repair_refinement_refactored.v2.dual_repair_iteration_contract",
                "iteration": cfg.iteration,
                "repair_reason": cfg.reason,
                "deterministic_reference_policy": "repair_triage_advisory_only",
                "repair_plan_policy": "candidate_plan_not_applied",
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
                "applied_to_original": False,
                "source_code_repair_allowed": cfg.allow_source_code_repair,
                "formal_truth_claimed": False,
                "result_classification": result_class,
                "triage_decision": triage_decision,
            },
        )

        stage_status["completed_utc"] = utc_now_iso()
        atomic_write_json(layout.logs_dir(stage) / "09_repair_refinement_status.json", stage_status)

        layout.log_event(
            event_type="stage_completed" if stage_status["success"] else "stage_completed_without_llm_repair_plan",
            stage=stage,
            message="Agent 9 Repair/Refinement completed.",
            data={
                "success": stage_status["success"],
                "handoff_available": stage_status["handoff_available"],
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
                "applied_to_original": False,
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
        atomic_write_json(layout.logs_dir(stage) / "09_repair_refinement_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 9 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        try:
            layout.write_stage_manifest(
                stage,
                notes={
                    "agent_version": "agent9_repair_refinement_refactored.v1",
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
    parser = argparse.ArgumentParser(description="Agent 9 — refactored LLM-backed Repair/Refinement Agent")
    parser.add_argument("--config", help="Path to run config JSON.")
    parser.add_argument("--run-dir", help="Override run directory.")
    parser.add_argument("--target-function", help="Implementation function name, e.g. mlk_poly_add.")
    parser.add_argument("--target-topic", help="Human-readable target topic.")
    parser.add_argument("--allow-missing-inputs", action="store_true", help="Allow missing Agent 8 inputs only for wiring tests.")
    parser.add_argument("--apply-repair", action="store_true", help="Request repair application. This implementation still blocks silent overwrite and records the request.")
    parser.add_argument("--allow-source-code-repair", action="store_true", help="Permit source-code repair proposals. Disabled by default.")
    parser.add_argument("--llm-mode", choices=["real", "mock", "disabled"], help="Override llm.mode from config.")
    parser.add_argument("--iteration", type=int, default=0, help="Repair iteration number (>= 0).")
    parser.add_argument(
        "--reason",
        choices=["critic_review", "counterexample_analysis"],
        default="counterexample_analysis",
        help="Evidence branch that triggered this repair.",
    )
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    if args.iteration < 0:
        parser.error("--iteration must be >= 0")
    config_data, cfg = load_config(args)
    return run_agent9(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
