#!/usr/bin/env python3
"""
review_critic_agent_refactored.py

Agent 6 — Review/Critic Agent, refactored for the new thesis workflow.

Architecture implemented:
- Consumes previous LLM stage outputs through handoff manifests.
- Consumes Agent 5 generated harness, artefact plan, artefact manifest, and independence audit.
- Python deterministic review checks are advisory/gate-supporting diagnostics only.
- The shared LLM client produces the authoritative critic review:
    stages/06_review_critic/llm_authoritative/05_critic_review.json
- Python derives a concrete review gate decision from LLM review + deterministic diagnostics:
    stages/06_review_critic/validation/05_review_gate_decision.json
- Downstream Agent 7 reads the gate decision and harness through handoff manifest.
- No root-level output dumping.
- No duplicate output copies.

Trust boundary:
- Agent 6 does not prove the harness correct.
- Agent 6 does not claim verification success.
- Agent 6 does not run CBMC.
- Agent 6 reviews whether the candidate artefact is reasonable enough to send to tool execution.
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
    from agents.common.formal_build import create_formal_build_plan, run_frontend_readiness_check
    from agents.common.gate_contract import build_gate_record, canonical_gate, gate_hash
    from agents.common.contract_artifacts import validate_contract_plan, validate_strategy_specific_plans
    from agents.common.property_campaign import validate_artifact_plan_for_campaign
    from agents.common.property_discovery_mode import effective_campaign_for_plan
    from agents.common.semantic_gate import validate_artifact_semantics
    from agents.common.llm_client import LLMClient, LLMStageRequest
    from agents.common.prompt_templates import build_common_stage_prompt
    from agents.common.schemas import CRITIC_REVIEW_SCHEMA
except Exception as import_exc:  # pragma: no cover
    raise SystemExit(
        "Failed to import shared workflow modules. Ensure these files exist and schemas.py includes CRITIC_REVIEW_SCHEMA:\n"
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


def sha256_file(path: PathLike) -> str:
    import hashlib
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

@dataclass
class ReviewCriticConfig:
    run_dir: Path
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM CBMC artefact review"
    llm_mode_override: Optional[str] = None
    allow_missing_previous_inputs: bool = False
    allow_empty_handoff_on_failure: bool = True
    block_high_similarity: bool = True
    block_todo_harness: bool = True
    block_missing_target_function: bool = True
    block_trivial_assertions: bool = True
    iteration: int = 0
    artifact_path: Optional[Path] = None
    artifact_plan_path: Optional[Path] = None
    artifact_manifest_path: Optional[Path] = None
    independence_audit_path: Optional[Path] = None


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


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, ReviewCriticConfig]:
    config_data: JsonDict = {}
    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        config_data = load_normalized_config(config_path)

    rc = config_data.get("review_critic", {})
    if not isinstance(rc, dict):
        rc = {}

    target_function = (
        args.target_function
        or str(config_data.get("target_function") or "")
        or str(config_data.get("function_name") or "")
        or "mlk_poly_add"
    )

    target_topic = (
        args.target_topic
        or str(config_data.get("target_topic") or "")
        or f"CBMC candidate artefact review for {target_function}"
    )

    cfg = ReviewCriticConfig(
        run_dir=resolve_run_dir(config_data, args),
        target_function=target_function,
        target_topic=target_topic,
        llm_mode_override=args.llm_mode,
        allow_missing_previous_inputs=bool(args.allow_missing_inputs or rc.get("allow_missing_previous_inputs")),
        block_high_similarity=bool(rc.get("block_high_similarity", True)),
        block_todo_harness=bool(rc.get("block_todo_harness", True)),
        block_missing_target_function=bool(rc.get("block_missing_target_function", True)),
        block_trivial_assertions=bool(rc.get("block_trivial_assertions", True)),
        iteration=int(args.iteration),
        artifact_path=(
            Path(args.artifact).expanduser().resolve()
            if args.artifact
            else (Path(str(config_data["current_artifact_path"])).expanduser().resolve()
                  if config_data.get("current_artifact_path") else None)
        ),
        artifact_plan_path=(
            Path(args.artifact_plan).expanduser().resolve()
            if args.artifact_plan
            else (Path(str(config_data["current_artifact_plan_path"])).expanduser().resolve()
                  if config_data.get("current_artifact_plan_path") else None)
        ),
        artifact_manifest_path=(
            Path(args.artifact_manifest).expanduser().resolve()
            if args.artifact_manifest
            else (Path(str(config_data["current_artifact_manifest_path"])).expanduser().resolve()
                  if config_data.get("current_artifact_manifest_path") else None)
        ),
        independence_audit_path=(
            Path(args.independence_audit).expanduser().resolve()
            if args.independence_audit
            else (Path(str(config_data["current_independence_audit_path"])).expanduser().resolve()
                  if config_data.get("current_independence_audit_path") else None)
        ),
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


# ---------------------------------------------------------------------------
# Deterministic critic checks
# ---------------------------------------------------------------------------

def detect_assertions(harness_text: str) -> List[JsonDict]:
    rows = []
    for i, line in enumerate(harness_text.splitlines(), start=1):
        if "assert" in line or "__CPROVER_assert" in line:
            rows.append({
                "line": i,
                "raw_text": line.strip(),
                "trivial_true": bool(re.search(r"assert\s*\(\s*1\s*\)", line)),
                "trivial_false": bool(re.search(r"assert\s*\(\s*0\s*\)", line)),
                "possible_self_comparison": bool(re.search(r"([A-Za-z_][A-Za-z0-9_\.\->\[\]]+)\s*==\s*\1", line)),
                "trust_boundary": "deterministic_review_diagnostic",
            })
    return rows


def detect_assumptions(harness_text: str) -> List[JsonDict]:
    rows = []
    for i, line in enumerate(harness_text.splitlines(), start=1):
        if "__CPROVER_assume" in line or "assume" in line:
            rows.append({
                "line": i,
                "raw_text": line.strip(),
                "possible_overstrong_range": bool(re.search(r"==\s*\d+", line)),
                "possible_assertion_hiding": "assert" in line,
                "trust_boundary": "deterministic_review_diagnostic",
            })
    return rows


def detect_old_state_patterns(harness_text: str) -> JsonDict:
    old_terms = ["old_", "_old", "pre_", "_pre", "before", "snapshot", "old_state"]
    has_old_terms = any(t in harness_text for t in old_terms)
    has_target_call = False

    # Detect target call position later in validate.
    return {
        "old_state_terms_detected": has_old_terms,
        "old_state_related_terms": [t for t in old_terms if t in harness_text],
        "warning": None if has_old_terms else "No obvious old-state snapshot terms detected.",
        "trust_boundary": "deterministic_review_diagnostic",
    }


def deterministic_review(
    *,
    cfg: ReviewCriticConfig,
    harness_path: Optional[Path],
    artifact_plan: Optional[JsonDict],
    artifact_manifest: Optional[JsonDict],
    independence_audit: Optional[JsonDict],
    property_campaign: Optional[Mapping[str, Any]] = None,
) -> JsonDict:
    issues: List[JsonDict] = []
    warnings: List[JsonDict] = []
    checks: List[JsonDict] = []
    strategy = str((artifact_plan or {}).get("verification_strategy") or "standard_cbmc_harness")
    analysis_only = strategy == "analysis_only_no_formal_claim"

    harness_text = ""
    if harness_path and harness_path.exists():
        harness_text = safe_read_text(harness_path)
    elif not analysis_only:
        issues.append({
            "severity": "critical",
            "check": "generated_harness_available",
            "message": "Generated harness file is missing.",
            "blocks_tool_execution": True,
        })

    contains_target = cfg.target_function in harness_text if harness_text else False
    checks.append({
        "check": "contains_target_function",
        "passed": contains_target,
        "details": cfg.target_function,
    })
    if cfg.block_missing_target_function and harness_text and not contains_target and not analysis_only:
        issues.append({
            "severity": "critical",
            "check": "contains_target_function",
            "message": f"Harness does not mention target function {cfg.target_function}.",
            "blocks_tool_execution": True,
        })

    contains_todo = "TODO" in harness_text or "FALLBACK-RENDERED" in harness_text
    checks.append({
        "check": "contains_no_todo_or_fallback_marker",
        "passed": not contains_todo,
        "details": "TODO or FALLBACK-RENDERED marker detected" if contains_todo else "",
    })
    if cfg.block_todo_harness and contains_todo:
        issues.append({
            "severity": "major",
            "check": "todo_or_fallback_harness",
            "message": "Harness contains TODO/fallback markers and is not ready for tool execution.",
            "blocks_tool_execution": True,
        })

    assertions = detect_assertions(harness_text)
    assumptions = detect_assumptions(harness_text)
    old_state = detect_old_state_patterns(harness_text)

    trivial_asserts = [a for a in assertions if a.get("trivial_true") or a.get("trivial_false")]
    if cfg.block_trivial_assertions and trivial_asserts:
        issues.append({
            "severity": "critical",
            "check": "trivial_assertions",
            "message": "Harness contains trivial true/false assertions.",
            "evidence": trivial_asserts,
            "blocks_tool_execution": True,
        })

    self_comparisons = [a for a in assertions if a.get("possible_self_comparison")]
    if self_comparisons:
        warnings.append({
            "severity": "major",
            "check": "possible_self_comparison",
            "message": "Possible self-comparison assertion detected. Human/LLM review must check for post-call self-comparison.",
            "evidence": self_comparisons,
            "blocks_tool_execution": False,
        })

    if artifact_plan:
        snapshot_plan = artifact_plan.get("old_state_snapshot_plan")
        snapshot_required_raw = snapshot_plan.get("required") if isinstance(snapshot_plan, dict) else None
        snapshot_required_text = str(snapshot_required_raw or "").strip().lower()
        required_tokens = {
            "true", "yes", "required", "needed", "mandatory", "must",
            "required_for_selected_property", "required_for_property",
        }
        not_required_tokens = {
            "false", "no", "not_required", "not required", "unnecessary",
            "not_required_for_selected_property", "not_required_for_property",
        }
        if isinstance(snapshot_required_raw, bool):
            requires_old = snapshot_required_raw
        elif snapshot_required_text in required_tokens:
            requires_old = True
        elif snapshot_required_text in not_required_tokens:
            requires_old = False
        else:
            requires_old = False
            if snapshot_required_text not in {"", "unknown", "uncertain", "unknown_in_mock_mode"}:
                warnings.append({
                    "severity": "minor",
                    "check": "ambiguous_old_state_snapshot_requirement",
                    "message": "Artefact plan used an unrecognised old-state snapshot requirement value.",
                    "value": snapshot_required_raw,
                    "blocks_tool_execution": False,
                })
        if requires_old and not old_state.get("old_state_terms_detected"):
            issues.append({
                "severity": "major",
                "check": "missing_old_state_snapshot",
                "message": "Artefact plan explicitly requires an old-state snapshot, but the harness has no obvious old-state/snapshot terms.",
                "blocks_tool_execution": True,
            })

    campaign_validation: JsonDict = {
        "valid": True,
        "errors": [],
        "warnings": [],
        "claim_boundary": "not_checked_no_artifact_plan",
    }
    if artifact_plan and property_campaign:
        campaign_validation = validate_artifact_plan_for_campaign(artifact_plan, property_campaign)
        checks.append({
            "check": "property_campaign_artifact_plan_valid",
            "passed": bool(campaign_validation.get("valid")),
            "details": campaign_validation,
        })
        if not campaign_validation.get("valid"):
            issues.append({
                "severity": "critical",
                "check": "property_campaign_artifact_plan_invalid",
                "message": "; ".join(str(x) for x in campaign_validation.get("errors", [])),
                "blocks_tool_execution": True,
            })
        for warning in campaign_validation.get("warnings", []):
            warnings.append({
                "severity": "major",
                "check": "property_campaign_artifact_plan_warning",
                "message": str(warning),
                "blocks_tool_execution": False,
            })

    contract_validation = {"valid": True, "enabled": False, "errors": [], "warnings": []}
    if artifact_plan:
        contract_plan = artifact_plan.get("contract_plan", {}) if isinstance(artifact_plan.get("contract_plan"), dict) else {}
        strategy_validation = validate_strategy_specific_plans(artifact_plan, strategy)
        contract_validation = strategy_validation["contract_plan"]
        checks.append({
            "check": "strategy_specific_plans_valid",
            "passed": bool(strategy_validation.get("valid")),
            "details": strategy_validation,
        })
        if not strategy_validation.get("valid"):
            issues.append({
                "severity": "critical",
                "check": "strategy_specific_plan_invalid",
                "message": "; ".join(str(x) for x in strategy_validation.get("errors", [])),
                "blocks_tool_execution": True,
            })
        for warning in strategy_validation.get("warnings", []):
            warnings.append({
                "severity": "major",
                "check": "contract_plan_warning",
                "message": str(warning),
                "blocks_tool_execution": False,
            })
        if strategy in {"native_loop_contract", "native_function_contract", "hybrid_contract_and_harness"}:
            summary = artifact_manifest.get("contract_summary", {}) if isinstance(artifact_manifest, dict) and isinstance(artifact_manifest.get("contract_summary"), dict) else {}
            if not summary.get("contract_valid"):
                issues.append({
                    "severity": "critical",
                    "check": "rendered_contract_bundle_invalid",
                    "message": "Artifact manifest does not record a valid rendered contract bundle.",
                    "blocks_tool_execution": True,
                })
            if summary.get("production_source_modified"):
                issues.append({
                    "severity": "critical",
                    "check": "production_source_modification",
                    "message": "Native contract workflow must use instrumented copies, not modify repository source.",
                    "blocks_tool_execution": True,
                })

    copying_risk = None
    if independence_audit:
        copying_risk = independence_audit.get("copying_risk")
        checks.append({
            "check": "independence_audit_available",
            "passed": True,
            "details": copying_risk,
        })
        if cfg.block_high_similarity and copying_risk in {"high_similarity_risk", "blocked_due_to_near_copy", "high"}:
            issues.append({
                "severity": "critical",
                "check": "copying_similarity_risk",
                "message": f"Independence audit reports copying risk: {copying_risk}.",
                "blocks_tool_execution": True,
            })
        elif copying_risk in {"moderate_similarity_risk", "moderate"}:
            warnings.append({
                "severity": "major",
                "check": "copying_similarity_risk",
                "message": f"Independence audit reports moderate copying risk: {copying_risk}.",
                "blocks_tool_execution": False,
            })
    else:
        warnings.append({
            "severity": "major",
            "check": "independence_audit_missing",
            "message": "Independence audit is missing.",
            "blocks_tool_execution": False,
        })

    broad_claim_terms = [
        "proves ml-kem", "proves fips", "fips compliant", "cryptographic security",
        "ind-cca", "full correctness", "verified implementation", "side-channel secure"
    ]
    broad_found = [t for t in broad_claim_terms if t in harness_text.lower()]
    if broad_found:
        warnings.append({
            "severity": "major",
            "check": "overclaiming_language",
            "message": "Harness/comments contain broad proof/security/compliance language.",
            "terms": broad_found,
            "blocks_tool_execution": False,
        })

    cbmc_markers = ["__CPROVER", "assert", "harness", "void harness", "int main"]
    cbmc_marker_present = any(m in harness_text for m in cbmc_markers)
    checks.append({
        "check": "cbmc_or_harness_marker_present",
        "passed": cbmc_marker_present,
        "details": [m for m in cbmc_markers if m in harness_text],
    })
    if not cbmc_marker_present and not analysis_only:
        issues.append({
            "severity": "major",
            "check": "no_harness_or_assert_marker",
            "message": "No obvious harness/CBMC/assert marker present.",
            "blocks_tool_execution": True,
        })

    semantic_gate = validate_artifact_semantics(
        artifact_plan,
        harness_text,
        target_function=cfg.target_function,
        property_campaign=property_campaign,
    )
    for item in semantic_gate.get("blocking_issues", []):
        issues.append({
            "severity": item.get("severity", "critical"),
            "check": item.get("issue_id", "semantic_gate_blocker"),
            "message": item.get("message", "Semantic gate blocker."),
            "evidence": item.get("evidence", {}),
            "blocks_tool_execution": True,
        })
    for item in semantic_gate.get("warnings", []):
        warnings.append({
            "severity": item.get("severity", "warning"),
            "check": item.get("issue_id", "semantic_gate_warning"),
            "message": item.get("message", "Semantic gate warning."),
            "evidence": item.get("evidence", {}),
            "blocks_tool_execution": False,
        })

    blocking_issues = [i for i in issues if i.get("blocks_tool_execution")]

    # Warnings and minor caveats are preserved in the review record, but they
    # do not block CBMC. This gate answers tool-readiness, not whether the
    # selected property will ultimately pass.
    recommended_gate = (
        "blocked" if blocking_issues else
        "approved_for_analysis_only" if analysis_only else
        "approved_for_tool_execution"
    )

    return {
        "schema_version": "deterministic_critic_review.v1",
        "created_utc": utc_now_iso(),
        "target_function": cfg.target_function,
        "verification_strategy": strategy,
        "analysis_only": analysis_only,
        "contract_validation": contract_validation,
        "property_campaign_validation": campaign_validation,
        "harness_path": str(harness_path) if harness_path else None,
        "artifact_plan_available": bool(artifact_plan),
        "artifact_manifest_available": bool(artifact_manifest),
        "independence_audit_available": bool(independence_audit),
        "assertions_detected": assertions,
        "assumptions_detected": assumptions,
        "old_state_pattern_check": old_state,
        "semantic_tool_readiness_gate": semantic_gate,
        "checks": checks,
        "issues": issues,
        "warnings": warnings,
        "blocking_issue_count": len(blocking_issues),
        "warning_count": len(warnings),
        "recommended_gate": recommended_gate,
        "trust_boundary": "deterministic_review_diagnostic_not_authoritative_critic_reasoning",
        "limitations": [
            "This is deterministic pattern-based review, not proof.",
            "It can miss semantic errors.",
            "LLM critic and human review are still required.",
        ],
    }


def write_deterministic_review_files(layout: RunLayout, deterministic: JsonDict) -> Dict[str, Path]:
    stage = "06_review_critic"
    paths: Dict[str, Path] = {}

    paths["deterministic_critic_review"] = layout.write_deterministic_reference_json(
        stage,
        "05_critic_review.deterministic.json",
        deterministic,
    )

    issue_rows = []
    for issue in deterministic.get("issues", []):
        issue_rows.append({
            "severity": issue.get("severity"),
            "check": issue.get("check"),
            "message": issue.get("message"),
            "blocks_tool_execution": issue.get("blocks_tool_execution"),
        })
    for warning in deterministic.get("warnings", []):
        issue_rows.append({
            "severity": warning.get("severity"),
            "check": warning.get("check"),
            "message": warning.get("message"),
            "blocks_tool_execution": warning.get("blocks_tool_execution"),
        })

    paths["review_issue_matrix_csv"] = write_csv(
        layout.deterministic_reference_dir(stage) / "05_review_issue_matrix.deterministic.csv",
        issue_rows,
        fieldnames=["severity", "check", "message", "blocks_tool_execution"],
    )

    assertion_rows = deterministic.get("assertions_detected", [])
    paths["assertion_algorithm_alignment_csv"] = write_csv(
        layout.deterministic_reference_dir(stage) / "05_assertion_algorithm_alignment.deterministic.csv",
        assertion_rows,
    )

    assumption_rows = deterministic.get("assumptions_detected", [])
    paths["assumption_evidence_review_csv"] = write_csv(
        layout.deterministic_reference_dir(stage) / "05_assumption_evidence_review.deterministic.csv",
        assumption_rows,
    )

    return paths


# ---------------------------------------------------------------------------
# LLM prompt and mock review
# ---------------------------------------------------------------------------

def build_agent6_prompt(cfg: ReviewCriticConfig, available: Mapping[str, bool]) -> str:
    responsibilities = """
- Review the LLM artefact plan from Agent 5.
- Review the rendered C harness from Agent 5.
- Review the artefact manifest and independence audit.
- Check whether assumptions are explicit, justified, and not over-strong.
- Check whether assertions match the selected property.
- Check for circular assertions, self-comparisons, and post-call/post-call comparisons.
- Check old-state versus new-state logic for in-place mutation.
- Review the selected verification strategy and reject strategy/property mismatches.
- For native loop contracts, check initialization, inductiveness/preservation, usefulness for the postcondition, non-triviality, decreases clauses, loop assigns clauses, history variables, and exact source-patch anchors.
- For native function contracts, check requires/ensures/assigns/frees clauses, frame completeness, memory predicates, old-state use, enforce/replace configuration, and DFCC assumptions.
- Check whether the harness only checks a narrow local property.
- Check whether the harness overclaims proof, FIPS compliance, cryptographic security, or full ML-KEM correctness.
- Check whether copying/similarity risks require human review.
- Check required includes, types, function symbols, macros, stubs, and formal-build inputs; flag unsupported or unresolved dependencies.
- Check whether the harness is ready for Agent 7 tool execution, needs revision, or must be blocked.
- Provide evidence references for every major criticism.
- Distinguish blocking issues, warnings, and minor issues.
""".strip()

    prohibitions = """
- Do not claim the harness is verified.
- Do not claim CBMC will pass.
- Do not claim FIPS compliance.
- Do not claim cryptographic security.
- Do not ignore high similarity or missing independence evidence.
- Do not approve a harness with trivial or circular assertions, assumptions that make the assertion tautological, missing target-function call, unsupported symbols/build dependencies, missing old-state snapshot when required, or TODO/fallback placeholders.
- Do not approve broad correctness/security claims.
- Do not treat deterministic semantic advice as authoritative without checking artefact evidence.
- Treat objective tool facts (exact commands, tool versions, exit codes, parser/instrumentation diagnostics, generated-property listings, and bundle hashes) as authoritative evidence about executability.
- Never speculate that a route may be usable when the supplied objective tool facts record that parsing, transformation, or selected-claim generation failed.
- Do not convert every concern into a hard tool blocker. A concern blocks execution only when the evidence shows an executable defect or a semantic-fidelity defect affecting the selected claim.
""".strip()

    task = f"""
This stage reviews a candidate CBMC-style artefact before tool execution.

Target function: {cfg.target_function}
Target topic: {cfg.target_topic}

Available evidence:
- Agent 2 spec summary: {available.get("spec_summary")}
- Agent 3 code summary: {available.get("code_summary")}
- Agent 4 candidate properties: {available.get("candidate_properties")}
- Agent 5 artefact plan: {available.get("artifact_plan")}
- Agent 5 generated harness: {available.get("generated_harness")}
- Agent 5 artefact manifest: {available.get("artifact_manifest")}
- Agent 5 independence audit: {available.get("independence_audit")}

Your output is a critic review and gate recommendation. It is not proof and not CBMC output.

Gate recommendation must be one of:
- approved_for_tool_execution
- needs_revision_before_tool_execution
- blocked_due_to_critical_issue
- human_review_required

Approve only if the artefact appears narrow, non-trivial, evidence-linked, and ready to be attempted by Agent 7. If evidence is incomplete or mock/fallback markers are present, do not give a clean approval.
""".strip()

    schema_summary = """
Top-level required fields:
- stage
- reviewed_artefacts
- overall_assessment
- gate_recommendation
- blocking_issues
- warnings
- minor_issues
- assumption_review
- assertion_review
- old_state_new_state_review
- contract_review
- verification_strategy_review
- independence_review
- scope_and_overclaim_review
- deterministic_reference_assessment
- evidence_references
- limitations
""".strip()

    return build_common_stage_prompt(
        stage_name="Agent 6 — Review/Critic Agent",
        task_description=task,
        responsibilities=responsibilities,
        prohibitions=prohibitions,
        schema_summary=schema_summary,
        include_non_copying_rule=True,
    )


def build_mock_critic_review(cfg: ReviewCriticConfig, deterministic_review_obj: JsonDict) -> JsonDict:
    return {
        "stage": "06_review_critic",
        "mock": True,
        "llm_call_executed": False,
        "reviewed_artefacts": {
            "target_function": cfg.target_function,
            "deterministic_recommended_gate": deterministic_review_obj.get("recommended_gate"),
        },
        "overall_assessment": "Mock mode only; no real LLM critic review was performed.",
        "gate_recommendation": "human_review_required",
        "blocking_issues": [],
        "warnings": [
            {
                "issue": "Mock critic review",
                "impact": "This cannot approve artefacts for thesis evidence or real CBMC interpretation."
            }
        ],
        "minor_issues": [],
        "assumption_review": {
            "status": "not_reviewed_in_mock_mode",
            "findings": []
        },
        "assertion_review": {
            "status": "not_reviewed_in_mock_mode",
            "findings": []
        },
        "old_state_new_state_review": {
            "status": "not_reviewed_in_mock_mode",
            "findings": []
        },
        "contract_review": {
            "status": "not_reviewed_in_mock_mode",
            "findings": []
        },
        "verification_strategy_review": {
            "status": "not_reviewed_in_mock_mode",
            "findings": []
        },
        "independence_review": {
            "status": "not_reviewed_in_mock_mode",
            "findings": []
        },
        "scope_and_overclaim_review": {
            "status": "not_reviewed_in_mock_mode",
            "findings": []
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
            "No API-backed review was performed.",
            "Do not use this output as thesis evidence for LLM review performance.",
        ],
    }


# ---------------------------------------------------------------------------
# Gate decision
# ---------------------------------------------------------------------------

def derive_gate_decision(
    *,
    cfg: ReviewCriticConfig,
    critic_review: Optional[JsonDict],
    deterministic_review_obj: JsonDict,
    harness_path: Optional[Path],
    artifact_plan_path: Optional[Path],
    independence_audit_path: Optional[Path],
    llm_mode: str,
    execution_mode: str = "reviewed",
) -> JsonDict:
    """Merge semantic review signals without confusing concern lists with tool facts."""
    deterministic_gate = str(deterministic_review_obj.get("recommended_gate") or "blocked")
    deterministic_issues = deterministic_review_obj.get("issues", [])
    deterministic_blockers = [
        issue for issue in deterministic_issues
        if isinstance(issue, dict) and bool(issue.get("blocks_tool_execution"))
    ]

    llm_recommendation = None
    llm_blocking_issues: List[Any] = []
    if critic_review:
        llm_recommendation = critic_review.get("gate_recommendation")
        candidate_blockers = critic_review.get("blocking_issues", [])
        if isinstance(candidate_blockers, list):
            llm_blocking_issues = candidate_blockers

    if llm_mode == "mock":
        final_gate = "human_review_required"
        reason = "Mock LLM review is wiring-only and cannot establish reviewed semantic fidelity or authorize formal execution."
    elif deterministic_gate == "approved_for_analysis_only":
        final_gate = "approved_for_analysis_only"
        reason = "The configured strategy is analysis-only; formal-tool execution is not applicable."
    elif deterministic_gate == "blocked" or deterministic_blockers:
        final_gate = "blocked_semantic_fidelity_defect"
        reason = "Objective deterministic checks found a selected-claim semantic-fidelity or executable blocker."
    elif llm_recommendation in {"blocked_due_to_critical_issue", "needs_revision_before_tool_execution"}:
        final_gate = "blocked_semantic_fidelity_defect"
        reason = "The LLM critic identified a concrete selected-claim defect requiring revision before execution."
    elif deterministic_gate == "approved_for_tool_execution" and llm_recommendation in {
        "approved_for_tool_execution", "human_review_required", None
    }:
        final_gate = "approved_for_tool_execution"
        reason = "No objective executable or selected-claim semantic-fidelity blocker was found."
    else:
        final_gate = "blocked_semantic_fidelity_defect"
        reason = "Review evidence was incomplete or ambiguous; reviewed execution remains fail-closed."

    base = build_gate_record(
        final_gate=final_gate,
        stage_output_valid=True,
        execution_mode=execution_mode,
        reason=reason,
    )
    base.update({
        "created_utc": utc_now_iso(),
        "stage": "06_review_critic",
        "target_function": cfg.target_function,
        "tool_execution_allowed": bool(base["formal_tool_execution_allowed"]),  # legacy compatibility
        "llm_gate_recommendation": llm_recommendation,
        "deterministic_recommended_gate": deterministic_gate,
        "llm_mode": llm_mode,
        "inputs": {
            "generated_harness": str(harness_path) if harness_path else None,
            "artifact_plan": str(artifact_plan_path) if artifact_plan_path else None,
            "independence_audit": str(independence_audit_path) if independence_audit_path else None,
        },
        "blocking_diagnostics": deterministic_blockers,
        "llm_reported_blocking_issues": llm_blocking_issues,
        "trust_boundary": {
            "gate_decision": "workflow_control_not_formal_truth",
            "objective_tool_facts": "authoritative_for_executability_only",
            "formal_truth": "not_claimed",
            "cbmc_execution": "not_performed_in_agent6",
        },
        "limitations": [
            "Approval means only that the exact candidate may proceed to the configured tool route.",
            "Approval is not proof and not a verification result.",
            "CBMC may still fail, produce counterexamples, or leave the selected claim unknown.",
        ],
    })
    base["gate_sha256"] = gate_hash(base)
    return base


def validate_artifact_bundle_binding(
    *,
    artifact_plan_path: Optional[Path],
    harness_path: Optional[Path],
    artifact_manifest: Optional[Mapping[str, Any]],
    independence_audit_path: Optional[Path],
) -> JsonDict:
    """Bind the exact plan, harness, audit and contract outputs selected for review."""
    errors: List[str] = []
    checks: List[JsonDict] = []
    if not isinstance(artifact_manifest, Mapping):
        return {"valid": False, "errors": ["Artifact manifest is unavailable."], "checks": []}
    artefacts = artifact_manifest.get("artefacts") if isinstance(artifact_manifest.get("artefacts"), Mapping) else {}
    hashes = artifact_manifest.get("checksums_sha256") if isinstance(artifact_manifest.get("checksums_sha256"), Mapping) else {}

    def check_one(label: str, selected: Optional[Path], recorded_path: Any, recorded_hash: Any, *, required: bool = True) -> None:
        if selected is None or not selected.is_file():
            if required:
                errors.append(f"Selected {label} is missing.")
            return
        selected = selected.resolve()
        if not recorded_path:
            if required:
                errors.append(f"Manifest does not bind {label} path.")
            return
        recorded = Path(str(recorded_path)).expanduser().resolve()
        path_match = recorded == selected
        actual_hash = sha256_file(selected)
        hash_match = bool(recorded_hash) and str(recorded_hash) == actual_hash
        checks.append({
            "artifact": label,
            "selected_path": str(selected),
            "manifest_path": str(recorded),
            "paths_match": path_match,
            "selected_sha256": actual_hash,
            "manifest_sha256": recorded_hash,
            "hashes_match": hash_match,
        })
        if not path_match:
            errors.append(f"Manifest {label} path does not match the exact selected file.")
        if not hash_match:
            errors.append(f"Manifest {label} checksum does not match the exact selected file.")

    check_one("artifact_plan", artifact_plan_path, artefacts.get("artifact_plan"), hashes.get("artifact_plan"))
    check_one("generated_harness", harness_path, artefacts.get("generated_harness"), hashes.get("generated_harness"))
    # Older approved manifests did not bind the audit internally.  For legacy
    # initial candidates, the separately selected audit remains acceptable;
    # every repaired v3 bundle must bind it explicitly.
    repaired_manifest = str(artifact_manifest.get("schema_version") or "").startswith("artifact_manifest.v3")
    check_one(
        "independence_audit", independence_audit_path,
        artefacts.get("independence_audit"), hashes.get("independence_audit"),
        required=repaired_manifest,
    )

    contract_paths = artefacts.get("contract_outputs") if isinstance(artefacts.get("contract_outputs"), Mapping) else {}
    contract_hashes = hashes.get("contract_outputs") if isinstance(hashes.get("contract_outputs"), Mapping) else {}
    for key, raw_path in contract_paths.items():
        path = Path(str(raw_path)).expanduser().resolve()
        if not path.is_file():
            errors.append(f"Manifest contract output {key!r} is missing: {path}")
            continue
        actual_hash = sha256_file(path)
        expected_hash = contract_hashes.get(key)
        hash_match = bool(expected_hash) and str(expected_hash) == actual_hash
        checks.append({
            "artifact": f"contract_outputs.{key}",
            "selected_path": str(path),
            "manifest_sha256": expected_hash,
            "selected_sha256": actual_hash,
            "hashes_match": hash_match,
        })
        if not hash_match:
            errors.append(f"Contract output checksum mismatch for {key!r}.")

    return {
        "schema_version": "artifact_bundle_binding_validation.v1",
        "valid": not errors,
        "errors": errors,
        "checks": checks,
        "trust_boundary": "file_identity_and_checksum_binding_only_not_semantic_correctness",
    }


# ---------------------------------------------------------------------------
# Main runner
# ---------------------------------------------------------------------------

def compact_objective_readiness(readiness: Mapping[str, Any], *, excerpt_chars: int = 8000) -> JsonDict:
    """Bound objective tool facts for the critic without hiding failure evidence."""
    compact = dict(readiness)
    steps: List[JsonDict] = []
    for row in readiness.get("steps", []) if isinstance(readiness.get("steps"), list) else []:
        if not isinstance(row, Mapping):
            continue
        item = dict(row)
        for key in ("stdout", "stderr"):
            value = str(item.get(key) or "")
            if len(value) > excerpt_chars:
                item[key + "_excerpt"] = value[:excerpt_chars] + "\n[TRUNCATED_OBJECTIVE_TOOL_EXCERPT]\n"
                item[key + "_original_chars"] = len(value)
                item.pop(key, None)
        steps.append(item)
    compact["steps"] = steps
    compact["trust_boundary"] = (
        "Objective tool facts are authoritative for executability only; they do not establish semantic truth or verification success."
    )
    return compact

def diagnose_route_readiness_failure(readiness: Mapping[str, Any]) -> JsonDict:
    """Classify a pre-Agent-7 failure without making a semantic truth claim."""
    classification = str(readiness.get("classification") or "")
    steps = [dict(row) for row in readiness.get("steps", []) if isinstance(row, Mapping)] if isinstance(readiness.get("steps"), list) else []
    failed = next((row for row in steps if not bool(row.get("ready", False))), None)
    stderr = str((failed or {}).get("stderr") or "")
    lowered = stderr.lower()
    categories: List[str] = []
    if "parsing error" in lowered or "syntax error" in lowered:
        categories.append("frontend_parser_error")
    if "no such file" in lowered or "not found" in lowered:
        categories.append("missing_source_or_dependency")
    if "unsupported" in lowered or "unknown option" in lowered:
        categories.append("unsupported_syntax_or_capability_mismatch")
    if "selected_claim" in classification or classification == "hard_missing_selected_claim_expectation":
        categories.append("selected_claim_mapping_or_generation_failure")
    if "transformation" in classification or (failed and str(failed.get("tool")) == "goto-instrument"):
        categories.append("goto_transformation_failure")
    if not categories and classification:
        categories.append(classification)
    return {
        "schema_version": "pre_agent7_readiness_diagnosis.v1",
        "diagnosis_applicable": not bool(readiness.get("execution_ready")),
        "classification": classification or "not_applicable",
        "failure_categories": categories,
        "failed_step": failed,
        "selected_claim_coverage": readiness.get("selected_claim_coverage"),
        "repair_evidence_available": bool(categories),
        "formal_property_evaluated": False,
        "claim_boundary": "This diagnosis classifies route construction/readiness only; CBMC solving was not attempted.",
    }


def record_frontend_readiness(
    *, layout: RunLayout, stage: str, config_data: Mapping[str, Any],
    formal_build_plan: Mapping[str, Any], det_review: JsonDict,
) -> Tuple[JsonDict, Path]:
    """Run and persist the complete route-specific non-solving readiness gate."""
    tool_cfg = config_data.get("tool_execution", {}) if isinstance(config_data.get("tool_execution"), Mapping) else {}
    reconciliation = config_data.get("formal_strategy_reconciliation", {})
    formal_policy = config_data.get("formal_artifact_policy", {}) if isinstance(config_data.get("formal_artifact_policy"), Mapping) else {}
    require_cbmc_frontend = bool(
        reconciliation.get("require_cbmc_frontend_readiness", False)
        if isinstance(reconciliation, Mapping) else False
    )
    require_full_route = bool(
        reconciliation.get("require_full_route_readiness", formal_policy.get("require_full_route_readiness", False))
        if isinstance(reconciliation, Mapping) else formal_policy.get("require_full_route_readiness", False)
    )
    readiness = run_frontend_readiness_check(
        formal_build_plan,
        output_dir=layout.validation_dir(stage) / "frontend_readiness_artifacts",
        cbmc_binary=str(tool_cfg.get("cbmc_binary") or "cbmc"),
        goto_cc_binary=str(tool_cfg.get("goto_cc_binary") or "goto-cc"),
        goto_instrument_binary=str(tool_cfg.get("goto_instrument_binary") or "goto-instrument"),
        timeout_seconds=int(tool_cfg.get("step_timeout_seconds") or 120),
        working_directory=formal_build_plan.get("working_directory"),
        require_cbmc_frontend=require_cbmc_frontend,
        require_full_route=require_full_route,
    )
    stdout_path = layout.validation_dir(stage) / "05_frontend_parse_and_build_readiness.stdout.txt"
    stderr_path = layout.validation_dir(stage) / "05_frontend_parse_and_build_readiness.stderr.txt"
    atomic_write_text(stdout_path, str(readiness.pop("stdout", "")))
    atomic_write_text(stderr_path, str(readiness.pop("stderr", "")))
    readiness["stdout_path"] = str(stdout_path)
    readiness["stderr_path"] = str(stderr_path)
    readiness["require_cbmc_frontend"] = require_cbmc_frontend
    readiness["require_full_route"] = require_full_route
    readiness_path = layout.write_validation_json(
        stage, "05_frontend_parse_and_build_readiness.json", readiness
    )
    diagnosis = diagnose_route_readiness_failure(readiness)
    diagnosis_path = layout.write_validation_json(
        stage, "05_pre_agent7_readiness_diagnosis.json", diagnosis
    )
    readiness["diagnosis_path"] = str(diagnosis_path)
    readiness_path = layout.write_validation_json(
        stage, "05_frontend_parse_and_build_readiness.json", readiness
    )
    execution_ready = bool(readiness.get("execution_ready"))
    if not execution_ready:
        classification = str(readiness.get("classification") or "unknown_route_readiness_failure")
        det_review.setdefault("issues", []).append({
            "severity": "critical",
            "check": "route_specific_non_solving_readiness_not_ready",
            "message": (
                "The exact reviewed artefact bundle did not complete the configured non-solving CBMC route: "
                + classification
            ),
            "blocks_tool_execution": True,
            "objective_tool_fact": True,
            "affected_claim_ids": [
                str(row.get("claim_id") or "")
                for row in formal_build_plan.get("selected_claim_expectations", [])
                if isinstance(row, Mapping) and str(row.get("claim_id") or "")
            ],
        })
        det_review["blocking_issue_count"] = len([
            issue for issue in det_review.get("issues", []) if issue.get("blocks_tool_execution")
        ])
        det_review["recommended_gate"] = "blocked"
    det_review["frontend_parse_and_build_readiness"] = readiness
    return readiness, readiness_path


def prepare_formal_build_review(
    *, config_data: JsonDict, cfg: ReviewCriticConfig, layout: RunLayout, stage: str,
    harness_path: Optional[Path], artifact_plan: Optional[JsonDict],
    artifact_manifest: Optional[JsonDict], independence_audit: Optional[JsonDict],
) -> Tuple[JsonDict, JsonDict, Path, JsonDict, JsonDict, Path, Path]:
    """Create the canonical plan, deterministic review, and frontend evidence."""
    effective_campaign = effective_campaign_for_plan(config_data, artifact_plan or {})
    config_for_formal_build = {**config_data, "property_campaign": effective_campaign}
    formal_build_plan = create_formal_build_plan(
        config_for_formal_build,
        harness_path if harness_path else layout.rendered_outputs_dir("05_artifact_generation") / "missing_harness.c",
        target_function=cfg.target_function, artifact_plan=artifact_plan, artifact_manifest=artifact_manifest,
    )
    formal_build_plan_path = layout.write_validation_json(
        stage, "05_formal_build_plan.json", formal_build_plan
    )
    det_review = deterministic_review(
        cfg=cfg, harness_path=harness_path, artifact_plan=artifact_plan,
        artifact_manifest=artifact_manifest, independence_audit=independence_audit,
        property_campaign=effective_campaign,
    )
    readiness, readiness_path = record_frontend_readiness(
        layout=layout, stage=stage, config_data=config_data,
        formal_build_plan=formal_build_plan, det_review=det_review,
    )
    campaign_validation = det_review.get(
        "property_campaign_validation", {"valid": False, "errors": ["Campaign validation result unavailable."]}
    )
    campaign_validation_path = layout.write_validation_json(
        stage, "05_property_campaign_review_validation.json", campaign_validation
    )
    return (effective_campaign, formal_build_plan, formal_build_plan_path, det_review,
            readiness, readiness_path, campaign_validation_path)


def run_agent6(config_data: JsonDict, cfg: ReviewCriticConfig) -> int:
    stage = "06_review_critic"
    layout = RunLayout(cfg.run_dir, create=False, active_iteration=cfg.iteration)
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 6 Review/Critic started.",
        data={
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
            "iteration": cfg.iteration,
            "artifact_override": str(cfg.artifact_path) if cfg.artifact_path else None,
            "artifact_plan_override": str(cfg.artifact_plan_path) if cfg.artifact_plan_path else None,
            "artifact_manifest_override": str(cfg.artifact_manifest_path) if cfg.artifact_manifest_path else None,
            "independence_audit_override": str(cfg.independence_audit_path) if cfg.independence_audit_path else None,
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
        # 1. Load previous-stage handoffs.
        # --------------------------------------------------------------
        spec_path, spec_summary, spec_status = load_handoff_json(layout, "02_spec_extraction", "spec_summary")
        code_path, code_summary, code_status = load_handoff_json(layout, "03_code_understanding", "code_summary")
        props_path, candidate_properties, props_status = load_handoff_json(layout, "04_property_discovery", "candidate_properties")
        if cfg.artifact_plan_path is not None:
            plan_path = cfg.artifact_plan_path
            try:
                artifact_plan = extract_content_wrapper(read_json_file(plan_path))
                plan_status = {
                    "producer_stage": "orchestrator_current_artifact_plan",
                    "output_key": "artifact_plan",
                    "available": True,
                    "path": str(plan_path),
                    "warning": None,
                }
            except Exception as exc:
                artifact_plan = None
                plan_status = {
                    "producer_stage": "orchestrator_current_artifact_plan",
                    "output_key": "artifact_plan",
                    "available": False,
                    "path": str(plan_path),
                    "warning": f"Explicit artifact-plan path could not be parsed: {type(exc).__name__}: {exc}",
                }
        else:
            plan_path, artifact_plan, plan_status = load_handoff_json(layout, "05_artifact_generation", "artifact_plan")
        if cfg.artifact_path is not None:
            harness_path = cfg.artifact_path
            harness_status = {
                "producer_stage": "orchestrator_current_artifact",
                "output_key": "generated_harness",
                "available": cfg.artifact_path.is_file(),
                "path": str(cfg.artifact_path),
                "warning": None if cfg.artifact_path.is_file() else "Explicit artifact path is missing or is not a file.",
            }
        else:
            harness_path, harness_status = load_handoff_path(layout, "05_artifact_generation", "generated_harness")
        if cfg.artifact_manifest_path is not None:
            manifest_path = cfg.artifact_manifest_path
            try:
                artifact_manifest = extract_content_wrapper(read_json_file(manifest_path))
                manifest_status = {
                    "producer_stage": "orchestrator_current_artifact_manifest",
                    "output_key": "artifact_manifest",
                    "available": True,
                    "path": str(manifest_path),
                    "warning": None,
                }
            except Exception as exc:
                artifact_manifest = None
                manifest_status = {
                    "producer_stage": "orchestrator_current_artifact_manifest",
                    "output_key": "artifact_manifest",
                    "available": False,
                    "path": str(manifest_path),
                    "warning": f"Explicit artifact-manifest path could not be parsed: {type(exc).__name__}: {exc}",
                }
        else:
            manifest_path, artifact_manifest, manifest_status = load_handoff_json(layout, "05_artifact_generation", "artifact_manifest")
        if cfg.independence_audit_path is not None:
            audit_path = cfg.independence_audit_path
            try:
                independence_audit = extract_content_wrapper(read_json_file(audit_path))
                audit_status = {
                    "producer_stage": "orchestrator_current_independence_audit",
                    "output_key": "independence_audit",
                    "available": True,
                    "path": str(audit_path),
                    "warning": None,
                }
            except Exception as exc:
                independence_audit = None
                audit_status = {
                    "producer_stage": "orchestrator_current_independence_audit",
                    "output_key": "independence_audit",
                    "available": False,
                    "path": str(audit_path),
                    "warning": f"Explicit independence-audit path could not be parsed: {type(exc).__name__}: {exc}",
                }
        else:
            audit_path, independence_audit, audit_status = load_handoff_json(layout, "05_artifact_generation", "independence_audit")
        exact_trace_path, exact_traceability, exact_trace_status = load_handoff_json(
            layout, "05_artifact_generation", "exact_traceability_validation"
        )
        capability_path, capability_profile, capability_status = load_handoff_json(
            layout, "05_artifact_generation", "cbmc_capability_profile"
        )

        statuses = {
            "spec_summary": spec_status,
            "code_summary": code_status,
            "candidate_properties": props_status,
            "artifact_plan": plan_status,
            "generated_harness": harness_status,
            "artifact_manifest": manifest_status,
            "independence_audit": audit_status,
            "exact_traceability_validation": exact_trace_status,
            "cbmc_capability_profile": capability_status,
        }

        available = {k: bool(v.get("available")) for k, v in statuses.items()}

        required = ["artifact_plan", "generated_harness", "artifact_manifest", "independence_audit"]
        formal_policy = config_data.get("formal_artifact_policy", {}) if isinstance(config_data.get("formal_artifact_policy"), Mapping) else {}
        if bool(formal_policy.get("require_exact_traceability", True)):
            required.append("exact_traceability_validation")
        if bool(formal_policy.get("require_cbmc_capability_profile", True)):
            required.append("cbmc_capability_profile")
        missing_required = [k for k in required if not available.get(k)]
        if missing_required and not cfg.allow_missing_previous_inputs:
            raise FileNotFoundError(
                "Agent 6 requires Agent 5 artefact_plan, generated_harness, artifact_manifest, and independence_audit. "
                f"Missing: {missing_required}. Use --allow-missing-inputs only for wiring tests."
            )

        for k, st in statuses.items():
            if not st.get("available"):
                stage_status["warnings"].append(f"{k} unavailable: {st.get('warning')}")

        previous_inputs_record = layout.write_deterministic_reference_json(
            stage,
            "05_previous_stage_input_status.json",
            {
                "trust_boundary": "previous_outputs_are_candidate_context_not_formal_truth",
                "statuses": statuses,
                "available": available,
                "spec_summary_preview": spec_summary,
                "code_summary_preview": code_summary,
                "candidate_properties_preview": candidate_properties,
                "artifact_plan_preview": artifact_plan,
                "artifact_manifest_preview": artifact_manifest,
                "independence_audit_preview": independence_audit,
                "exact_traceability_preview": exact_traceability,
                "cbmc_capability_profile_preview": capability_profile,
                "iteration": cfg.iteration,
                "selected_harness_path": str(harness_path) if harness_path else None,
                "selected_harness_source": harness_status.get("producer_stage"),
            },
        )

        # 2. Deterministic formal-build plan and review diagnostics.
        (effective_campaign, formal_build_plan, formal_build_plan_path, det_review, readiness,
         frontend_readiness_path, campaign_validation_path) = prepare_formal_build_review(
            config_data=config_data, cfg=cfg, layout=layout, stage=stage, harness_path=harness_path,
            artifact_plan=artifact_plan, artifact_manifest=artifact_manifest, independence_audit=independence_audit,
        )
        bundle_binding = validate_artifact_bundle_binding(
            artifact_plan_path=plan_path,
            harness_path=harness_path,
            artifact_manifest=artifact_manifest,
            independence_audit_path=audit_path,
        )
        bundle_binding_path = layout.write_validation_json(
            stage, "05_artifact_bundle_binding_validation.json", bundle_binding
        )
        if not bundle_binding.get("valid"):
            det_review.setdefault("issues", []).append({
                "severity": "critical",
                "check": "artifact_bundle_binding_invalid",
                "message": "; ".join(bundle_binding.get("errors", [])),
                "blocks_tool_execution": True,
            })
            det_review["blocking_issue_count"] = len([
                issue for issue in det_review.get("issues", []) if issue.get("blocks_tool_execution")
            ])
            det_review["recommended_gate"] = "blocked"
        deterministic_paths = write_deterministic_review_files(layout, det_review)
        deterministic_paths["previous_stage_input_status"] = previous_inputs_record

        advisory_enabled = semantic_advisory_enabled(config_data)
        deterministic_bundle: Optional[JsonDict] = None
        if advisory_enabled:
            deterministic_bundle = {
                "deterministic_review": det_review,
                "previous_stage_input_status": {
                    "statuses": statuses,
                    "available": available,
                },
            }
        else:
            stage_status["warnings"].append(
                "semantic_advisory_mode=off: deterministic semantic advice was withheld; objective tool facts remain supplied to the critic."
            )
        prior_authoritative_context = {
            "spec_summary": spec_summary,
            "code_summary": code_summary,
            "candidate_properties": candidate_properties,
            "artifact_plan": artifact_plan,
            "artifact_manifest": artifact_manifest,
            "independence_audit": independence_audit,
            "exact_traceability_validation": exact_traceability,
            "cbmc_capability_profile": capability_profile,
        }

        # --------------------------------------------------------------
        # 3. LLM critic review.
        # --------------------------------------------------------------
        prompt_text = build_agent6_prompt(cfg, available)

        run_config_for_client = dict(config_data)
        if cfg.llm_mode_override:
            llm_cfg = dict(run_config_for_client.get("llm") or {})
            llm_cfg["mode"] = cfg.llm_mode_override
            run_config_for_client["llm"] = llm_cfg

        client = LLMClient.from_run_config(run_config_for_client)

        primary_files = canonical_raw_evidence_files(config_data, include_specs=True, include_code=True)
        prior_context_files = existing_unique_paths(
            [p for p in [spec_path, code_path, props_path, plan_path, harness_path, manifest_path, audit_path, exact_trace_path, capability_path] if p]
        )

        request = LLMStageRequest(
            stage=stage,
            prompt_text=prompt_text,
            output_filename="05_critic_review.json",
            json_schema=CRITIC_REVIEW_SCHEMA,
            primary_evidence_files=primary_files,
            prior_authoritative_context_files=prior_context_files,
            prior_authoritative_context_bundle=prior_authoritative_context,
            trusted_deterministic_fact_files=existing_unique_paths([
                formal_build_plan_path, frontend_readiness_path,
                Path(str(readiness.get("stdout_path"))) if readiness.get("stdout_path") else None,
                Path(str(readiness.get("stderr_path"))) if readiness.get("stderr_path") else None,
                exact_trace_path, capability_path,
            ]),
            trusted_deterministic_facts_bundle={
                "formal_build_plan": formal_build_plan,
                "objective_route_readiness": compact_objective_readiness(readiness),
                "exact_traceability_validation": exact_traceability,
                "cbmc_capability_profile": capability_profile,
            },
            deterministic_reference_bundle=deterministic_bundle,
            extra_prompt_metadata={
                "agent": "Agent 6 Review/Critic",
                "target_function": cfg.target_function,
                "target_topic": cfg.target_topic,
                "available_inputs": available,
                "trust_boundary": {
                    "artefact_plan": "candidate_context_not_formal_truth",
                    "generated_harness": "candidate_artefact_not_verified",
                    "deterministic_review": "semantic_advice_controlled_by_semantic_advisory_mode",
                    "objective_route_readiness": "always_visible_authoritative_executability_facts_not_formal_truth",
                    "llm_output": "authoritative_stage_candidate_review_not_formal_truth",
                    "gate_decision": "workflow_control_decision_not_proof",
                    "formal_truth": "not_claimed",
                },
            },
            mock_response_content=build_mock_critic_review(cfg, det_review),
        )

        result = client.run_stage(layout, request)
        stage_status["llm_call_executed"] = result.llm_call_executed
        stage_status["llm_mode"] = result.mode
        stage_status["llm_success"] = result.success
        stage_status["llm_result"] = result.to_dict()

        # --------------------------------------------------------------
        # 4. Gate decision.
        # --------------------------------------------------------------
        critic_review = None
        if result.output_path:
            try:
                critic_review = extract_content_wrapper(read_json_file(result.output_path))
            except Exception as exc:
                stage_status["warnings"].append(f"Could not parse LLM critic output for gate decision: {exc}")

        gate = derive_gate_decision(
            cfg=cfg,
            critic_review=critic_review,
            deterministic_review_obj=det_review,
            harness_path=harness_path,
            artifact_plan_path=plan_path,
            independence_audit_path=audit_path,
            llm_mode=result.mode,
            execution_mode=str(formal_build_plan.get("execution_mode") or "reviewed"),
        )
        build_validation = formal_build_plan.get("validation", {})
        mock_wiring_only = result.mode == "mock" and not result.llm_call_executed
        if not bool(build_validation.get("valid", False)) and not mock_wiring_only:
            gate.update(build_gate_record(
                final_gate="blocked_invalid_artifact",
                stage_output_valid=True,
                execution_mode=str(formal_build_plan.get("execution_mode") or "reviewed"),
                reason="Formal build plan is invalid; exact execution inputs must be corrected before reviewed execution.",
            ))
            gate["tool_execution_allowed"] = False
            gate.setdefault("blocking_diagnostics", []).append({
                "category": "formal_build_plan",
                "severity": "critical",
                "errors": build_validation.get("errors", []),
                "warnings": build_validation.get("warnings", []),
            })
        gate["formal_build_plan"] = {
            "path": str(formal_build_plan_path),
            "valid": bool(build_validation.get("valid", False)),
            "error_count": int(build_validation.get("error_count", 0)),
            "warning_count": int(build_validation.get("warning_count", 0)),
        }

        gate["frontend_parse_and_build_readiness"] = {
            "path": str(frontend_readiness_path),
            "frontend_ready": bool(readiness.get("frontend_parse_and_build_ready")),
            "transformation_ready": bool(readiness.get("goto_transformation_ready", True)),
            "selected_claim_generated": bool(readiness.get("selected_claim_generated")),
            "full_route_ready": bool(readiness.get("full_route_ready")),
            "execution_ready": bool(readiness.get("execution_ready")),
            "classification": readiness.get("classification"),
            "formal_build_plan_semantic_sha256": readiness.get("formal_build_plan_semantic_sha256"),
        }
        if not bool(readiness.get("execution_ready")):
            classification = str(readiness.get("classification") or "route readiness failed")
            if not mock_wiring_only:
                if not bool(readiness.get("frontend_parse_and_build_ready")):
                    blocked_gate = "blocked_frontend_readiness_defect"
                elif "selected_claim" in classification or not bool(readiness.get("selected_claim_generated")):
                    blocked_gate = "blocked_missing_selected_claim"
                else:
                    blocked_gate = "blocked_transformation_readiness_defect"
                gate.update(build_gate_record(
                    final_gate=blocked_gate,
                    stage_output_valid=True,
                    execution_mode=str(formal_build_plan.get("execution_mode") or "reviewed"),
                    reason="The exact reviewed artefact bundle failed the configured non-solving route readiness gate.",
                ))
                gate["tool_execution_allowed"] = False
            gate.setdefault("blocking_diagnostics", []).append({
                "category": "route_specific_non_solving_readiness",
                "message": classification,
                "selected_claim_coverage": readiness.get("selected_claim_coverage"),
                "mock_wiring_only": mock_wiring_only,
                "blocks_formal_execution": True,
            })
        gate["gate_sha256"] = gate_hash(gate)

        gate_path = layout.write_validation_json(
            stage,
            "05_review_gate_decision.json",
            gate,
        )

        # Also save a Markdown review summary for human inspection.
        md_lines = [
            "# Agent 6 Review Gate Decision",
            "",
            f"- Target function: `{cfg.target_function}`",
            f"- Final gate: `{gate['final_gate']}`",
            f"- Tool execution allowed: `{gate['tool_execution_allowed']}`",
            f"- Reason: {gate['reason']}",
            f"- LLM recommendation: `{gate.get('llm_gate_recommendation')}`",
            f"- Deterministic recommendation: `{gate.get('deterministic_recommended_gate')}`",
            "",
            "This is a workflow-control decision, not proof or verification.",
            "",
        ]
        gate_md_path = layout.validation_dir(stage) / "05_review_gate_decision.md"
        atomic_write_text(gate_md_path, "\n".join(md_lines))

        # --------------------------------------------------------------
        # 5. Handoff manifest.
        # --------------------------------------------------------------
        if result.success and result.output_path:
            handoff_outputs: Dict[str, Path] = {
                "critic_review": Path(result.output_path),
                "review_gate_decision": gate_path,
                "formal_build_plan": formal_build_plan_path,
                "frontend_parse_and_build_readiness": frontend_readiness_path,
            }
            if readiness.get("stdout_path"):
                handoff_outputs["frontend_readiness_stdout"] = Path(str(readiness["stdout_path"]))
            if readiness.get("stderr_path"):
                handoff_outputs["frontend_readiness_stderr"] = Path(str(readiness["stderr_path"]))
            if readiness.get("diagnosis_path"):
                handoff_outputs["pre_agent7_readiness_diagnosis"] = Path(str(readiness["diagnosis_path"]))
            if exact_trace_path and Path(exact_trace_path).exists():
                handoff_outputs["exact_traceability_validation"] = Path(exact_trace_path)
            if capability_path and Path(capability_path).exists():
                handoff_outputs["cbmc_capability_profile"] = Path(capability_path)
            if harness_path and Path(harness_path).exists():
                handoff_outputs["generated_harness_under_review"] = Path(harness_path)
            if plan_path and Path(plan_path).exists():
                handoff_outputs["artifact_plan_under_review"] = Path(plan_path)
            if manifest_path and Path(manifest_path).exists():
                handoff_outputs["artifact_manifest_under_review"] = Path(manifest_path)
            if audit_path and Path(audit_path).exists():
                handoff_outputs["independence_audit_under_review"] = Path(audit_path)
            if result.validation_path:
                handoff_outputs["critic_review_validation"] = Path(result.validation_path)
            handoff_outputs["review_gate_decision_md"] = gate_md_path
            handoff_outputs["deterministic_review_diagnostics"] = deterministic_paths["deterministic_critic_review"]

            layout.write_handoff_manifest(
                stage,
                outputs=handoff_outputs,
                authoritative_source="llm_authoritative_plus_deterministic_gate",
                next_stage_consumers=[
                    "07_tool_execution",
                    "08_counterexample_analysis",
                    "09_repair_refinement",
                    "10_experiment_logger",
                    "11_evaluation_reporter",
                ],
                notes={
                    "handoff_policy": (
                        "critic_review is LLM-authoritative stage candidate review. "
                        "review_gate_decision is a conservative deterministic workflow-control decision "
                        "derived from LLM review and diagnostics."
                    ),
                    "llm_mode": result.mode,
                    "llm_call_executed": result.llm_call_executed,
                    "mock_output": result.mode == "mock",
                    "tool_execution_allowed": gate["tool_execution_allowed"],
                    "final_gate": gate["final_gate"],
                    "formal_truth_claimed": False,
                    "cbmc_executed": False,
                },
            )
            stage_status["handoff_available"] = True
            stage_status["success"] = True
            stage_status["process_completed"] = True
            stage_status["process_return_code"] = 0
            stage_status["stage_output_valid"] = True
            stage_status["stage_outcome"] = gate["final_gate"]
            stage_status["formal_tool_execution_allowed"] = gate.get("formal_tool_execution_allowed", False)
            stage_status["analysis_stage_execution_allowed"] = gate.get("analysis_stage_execution_allowed", False)
            stage_status["gate_sha256"] = gate.get("gate_sha256")
        else:
            message = "No authoritative LLM critic review was produced."
            stage_status["warnings"].append(message)
            if cfg.allow_empty_handoff_on_failure:
                layout.write_handoff_manifest(
                    stage,
                    outputs={"review_gate_decision": gate_path, "formal_build_plan": formal_build_plan_path, "frontend_parse_and_build_readiness": frontend_readiness_path},
                    authoritative_source="deterministic_gate_only_llm_failed_or_disabled",
                    next_stage_consumers=["10_experiment_logger", "11_evaluation_reporter"],
                    notes={
                        "handoff_policy": "LLM critic review unavailable. Gate decision is conservative and should not be treated as LLM review.",
                        "llm_result": result.to_dict(),
                        "tool_execution_allowed": gate["tool_execution_allowed"],
                        "final_gate": gate["final_gate"],
                    },
                )

        # --------------------------------------------------------------
        # 6. Stage manifest.
        # --------------------------------------------------------------
        llm_outputs: Dict[str, Path] = {}
        validation_outputs: Dict[str, Path] = {
            "review_gate_decision": gate_path,
            "review_gate_decision_md": gate_md_path,
            "formal_build_plan": formal_build_plan_path,
            "frontend_parse_and_build_readiness": frontend_readiness_path,
            "property_campaign_review_validation": campaign_validation_path,
            "artifact_bundle_binding_validation": bundle_binding_path,
        }
        prompt_outputs: Dict[str, Path] = {}

        if result.output_path:
            llm_outputs["critic_review"] = Path(result.output_path)
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
                str(p) for p in [spec_path, code_path, props_path, plan_path, harness_path, manifest_path, audit_path]
                if p is not None
            ],
            deterministic_reference_outputs=deterministic_paths,
            prompt_package_outputs=prompt_outputs,
            llm_authoritative_outputs=llm_outputs,
            validation_outputs=validation_outputs,
            notes={
                "agent_version": "agent6_review_critic_refactored.v2.iteration_contract",
                "iteration": cfg.iteration,
                "selected_harness_path": str(harness_path) if harness_path else None,
                "selected_harness_source": harness_status.get("producer_stage"),
                "deterministic_reference_policy": "diagnostic_advisory_gate_support",
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
                "cbmc_executed": False,
                "formal_truth_claimed": False,
                "final_gate": gate["final_gate"],
                "tool_execution_allowed": gate["tool_execution_allowed"],
            },
        )

        stage_status["completed_utc"] = utc_now_iso()
        status_path = layout.logs_dir(stage) / "06_review_critic_status.json"
        atomic_write_json(status_path, stage_status)

        layout.log_event(
            event_type="stage_completed" if stage_status["success"] else "stage_completed_without_llm_review",
            stage=stage,
            message="Agent 6 Review/Critic completed.",
            data={
                "success": stage_status["success"],
                "handoff_available": stage_status["handoff_available"],
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
                "final_gate": gate["final_gate"],
                "tool_execution_allowed": gate["tool_execution_allowed"],
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
        atomic_write_json(layout.logs_dir(stage) / "06_review_critic_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 6 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        try:
            layout.write_stage_manifest(
                stage,
                notes={
                    "agent_version": "agent6_review_critic_refactored.v1",
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
    parser = argparse.ArgumentParser(description="Agent 6 — refactored LLM-backed Review/Critic Agent")
    parser.add_argument("--config", help="Path to run config JSON.")
    parser.add_argument("--run-dir", help="Override run directory.")
    parser.add_argument("--target-function", help="Implementation function name, e.g. mlk_poly_add.")
    parser.add_argument("--target-topic", help="Human-readable target topic.")
    parser.add_argument("--allow-missing-inputs", action="store_true", help="Allow missing inputs only for wiring tests.")
    parser.add_argument("--llm-mode", choices=["real", "mock", "disabled"], help="Override llm.mode from config.")
    parser.add_argument("--iteration", type=int, default=0, help="Repair/review iteration number (>= 0).")
    parser.add_argument("--artifact", help="Explicit candidate harness path selected by the orchestrator.")
    parser.add_argument("--artifact-plan", help="Explicit candidate artifact-plan JSON selected by the orchestrator.")
    parser.add_argument("--artifact-manifest", help="Explicit candidate artifact-manifest JSON selected by the orchestrator.")
    parser.add_argument("--independence-audit", help="Explicit candidate independence-audit JSON selected by the orchestrator.")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    if args.iteration < 0:
        parser.error("--iteration must be >= 0")
    config_data, cfg = load_config(args)
    return run_agent6(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
