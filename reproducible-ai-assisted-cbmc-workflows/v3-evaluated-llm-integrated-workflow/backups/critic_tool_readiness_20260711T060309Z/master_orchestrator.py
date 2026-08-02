#!/usr/bin/env python3
"""
Master Orchestrator — layout-integrated refactor version.

Purpose
-------
This version integrates the new stage-organised run layout:

- No root-level dumping of stage outputs.
- No duplicate copies of the 146 generated files.
- Each agent writes outputs once inside its own stage folder.
- Downstream agents discover outputs through handoff_manifest.json.
- Deterministic reference outputs stay advisory-only.
- LLM-authoritative outputs become the candidate stage outputs passed downstream.

Important
---------
This orchestrator expects refactored agents to write stage handoff manifests.
It is the foundation step before refactoring Agent 2, Agent 3, etc.

Required companion file:
    agents/common/run_layout.py

Python: 3.10+
Dependencies: standard library only.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import dataclasses
import datetime as _dt
import json
import os
import subprocess
import sys
import traceback
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Tuple

# When this file is executed as `python agents/master_orchestrator.py`,
# Python puts `agents/` on sys.path, not the project root. Add the project
# root explicitly so `agents.common.run_layout` imports reliably.
_PROJECT_ROOT_FOR_IMPORT = Path(__file__).resolve().parent.parent
if str(_PROJECT_ROOT_FOR_IMPORT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT_FOR_IMPORT))

try:
    from agents.common.run_layout import RunLayout, read_json as layout_read_json, atomic_write_json
    from agents.common.config_contract import (
        apply_runtime_paths,
        canonical_input_summary,
        load_normalized_config,
        validate_pipeline_config,
    )
    from agents.common.llm_profile import (
        frozen_profile_metadata,
        resolved_profile_record,
    )
except Exception as import_error:  # pragma: no cover - user-facing setup error
    raise SystemExit(
        "Could not import agents.common.run_layout.\n"
        "Copy run_layout.py to agents/common/run_layout.py before using this orchestrator.\n"
        f"Original import error: {import_error}"
    )


# ---------------------------------------------------------------------------
# Data models
# ---------------------------------------------------------------------------

@dataclasses.dataclass(frozen=True)
class AgentSpec:
    """Static description of one stage agent."""

    name: str
    stage_key: str
    script: str
    expected_handoff_outputs: Tuple[str, ...]
    required: bool = True
    timeout_seconds: int = 900
    description: str = ""


@dataclasses.dataclass
class AgentRunResult:
    """Runtime result of one agent execution."""

    name: str
    stage_key: str
    status: str
    returncode: Optional[int]
    started_at: str
    finished_at: str
    duration_seconds: float
    command: List[str]
    stdout_file: str
    stderr_file: str
    expected_handoff_outputs: List[str]
    missing_handoff_outputs: List[str]
    handoff_manifest: Optional[str]
    error: Optional[str] = None


# ---------------------------------------------------------------------------
# Agent map — output expectations are handoff keys, not root-level filenames
# ---------------------------------------------------------------------------

DEFAULT_AGENTS: Dict[str, AgentSpec] = {
    "spec_extraction": AgentSpec(
        name="spec_extraction",
        stage_key="02_spec_extraction",
        script="agents/spec_extraction_agent.py",
        expected_handoff_outputs=("spec_summary",),
        description="LLM-backed specification extraction; writes authoritative candidate spec summary handoff.",
    ),
    "code_understanding": AgentSpec(
        name="code_understanding",
        stage_key="03_code_understanding",
        script="agents/code_understanding_agent.py",
        expected_handoff_outputs=("code_summary",),
        description="LLM-backed code understanding; writes authoritative candidate code summary handoff.",
    ),
    "property_discovery": AgentSpec(
        name="property_discovery",
        stage_key="04_property_discovery",
        script="agents/property_discovery_agent.py",
        expected_handoff_outputs=("candidate_properties",),
        description="LLM-backed property discovery; writes candidate property list handoff.",
    ),
    "artifact_generation": AgentSpec(
        name="artifact_generation",
        stage_key="05_artifact_generation",
        script="agents/artifact_generation_agent.py",
        expected_handoff_outputs=("artifact_plan", "generated_harness", "artifact_manifest"),
        description="LLM-backed artefact planning with Python rendering/validation of candidate harness.",
    ),
    "critic_review": AgentSpec(
        name="critic_review",
        stage_key="06_review_critic",
        script="agents/review_critic_agent.py",
        expected_handoff_outputs=("critic_review", "review_gate_decision", "formal_build_plan"),
        description="LLM-backed critic review and gate decision before CBMC execution.",
    ),
    "tool_execution": AgentSpec(
        name="tool_execution",
        stage_key="07_tool_execution",
        script="agents/tool_execution_agent.py",
        expected_handoff_outputs=("cbmc_output", "cbmc_status"),
        description="Deterministic CBMC/tool execution stage.",
        timeout_seconds=1800,
    ),
    "counterexample_analysis": AgentSpec(
        name="counterexample_analysis",
        stage_key="08_counterexample_analysis",
        script="agents/counterexample_analysis_agent.py",
        expected_handoff_outputs=("counterexample_analysis", "repair_guidance", "repair_action_plan"),
        description="LLM-backed analysis of CBMC/tool outputs and candidate repair direction.",
    ),
    "repair": AgentSpec(
        name="repair",
        stage_key="09_repair_refinement",
        script="agents/repair_agent.py",
        expected_handoff_outputs=("repair_plan",),
        description="LLM-backed repair/refinement plan; Python controls patch application.",
    ),
    "experiment_logger": AgentSpec(
        name="experiment_logger",
        stage_key="10_experiment_logger",
        script="agents/experiment_logger.py",
        expected_handoff_outputs=("experiment_log", "artifact_inventory", "checksum_manifest"),
        required=False,
        description="Deterministic evidence logger and file/checksum indexer.",
    ),
    "evaluation_reporter": AgentSpec(
        name="evaluation_reporter",
        stage_key="11_evaluation_reporter",
        script="agents/evaluation_reporter.py",
        expected_handoff_outputs=("evaluation_report",),
        required=False,
        description="Mixed evaluation stage: deterministic facts plus cautious LLM interpretation if enabled.",
    ),
}


# ---------------------------------------------------------------------------
# Utility helpers
# ---------------------------------------------------------------------------

def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


def safe_name(value: str) -> str:
    allowed: List[str] = []
    for ch in value.strip().lower():
        if ch.isalnum():
            allowed.append(ch)
        elif ch in {"-", "_", "."}:
            allowed.append(ch)
        elif ch.isspace():
            allowed.append("_")
    result = "".join(allowed).strip("._-")
    return result or "run"


def read_json(path: Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected JSON object in {path}, got {type(data).__name__}")
    return data


def write_json(path: Path, data: Mapping[str, Any]) -> None:
    atomic_write_json(path, dict(data))


def append_jsonl(path: Path, data: Mapping[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(dict(data), ensure_ascii=False) + "\n")


def read_text_if_exists(path: Path, max_chars: int = 4000) -> str:
    if not path.exists():
        return ""
    try:
        return path.read_text(encoding="utf-8", errors="replace")[:max_chars]
    except Exception:
        return ""


def copy_if_exists(src: Path, dst: Path) -> Optional[str]:
    """Copy input evidence/config once into the orchestrator control snapshot folder."""
    if not src.exists() or not src.is_file():
        return None
    dst.parent.mkdir(parents=True, exist_ok=True)
    import shutil
    shutil.copy2(src, dst)
    return str(dst)


def ensure_relative_to_project(project_root: Path, maybe_path: str) -> Path:
    p = Path(maybe_path).expanduser()
    if not p.is_absolute():
        p = project_root / p
    return p.resolve()


def _git_text(path: Path, *args: str) -> Optional[str]:
    try:
        proc = subprocess.run(
            ["git", "-C", str(path), *args],
            text=True,
            capture_output=True,
            check=False,
            timeout=15,
        )
        if proc.returncode != 0:
            return None
        return proc.stdout.strip()
    except Exception:
        return None


def capture_repository_provenance(config: Mapping[str, Any], project_root: Path) -> Dict[str, Any]:
    """Capture local Git revisions without recording remotes, credentials, or file contents."""
    candidates: List[Path] = [project_root]
    inputs = config.get("inputs") if isinstance(config.get("inputs"), Mapping) else {}
    tool = config.get("tool_execution") if isinstance(config.get("tool_execution"), Mapping) else {}
    for value in [inputs.get("code_dir"), tool.get("working_directory")]:
        if value:
            path = Path(str(value)).expanduser()
            if not path.is_absolute():
                path = project_root / path
            candidates.append(path.resolve())
    provenance = config.get("provenance") if isinstance(config.get("provenance"), Mapping) else {}
    extra = provenance.get("repository_paths") if isinstance(provenance, Mapping) else None
    if isinstance(extra, list):
        for value in extra:
            path = Path(str(value)).expanduser()
            if not path.is_absolute():
                path = project_root / path
            candidates.append(path.resolve())

    records: List[Dict[str, Any]] = []
    seen_roots = set()
    for candidate in candidates:
        probe = candidate if candidate.is_dir() else candidate.parent
        root_text = _git_text(probe, "rev-parse", "--show-toplevel")
        if not root_text:
            records.append({
                "candidate_path": str(candidate),
                "git_repository_detected": False,
            })
            continue
        repo_root = Path(root_text).resolve()
        if str(repo_root) in seen_roots:
            continue
        seen_roots.add(str(repo_root))
        commit = _git_text(repo_root, "rev-parse", "HEAD")
        branch = _git_text(repo_root, "rev-parse", "--abbrev-ref", "HEAD")
        status = _git_text(repo_root, "status", "--porcelain", "--untracked-files=normal")
        status_lines = status.splitlines() if status else []
        records.append({
            "candidate_path": str(candidate),
            "git_repository_detected": True,
            "repository_root": str(repo_root),
            "commit": commit,
            "branch": branch,
            "dirty": bool(status_lines),
            "changed_path_count": len(status_lines),
            "remote_urls_recorded": False,
        })
    return {
        "schema_version": "repository_provenance.v1",
        "created_at": utc_now(),
        "repositories": records,
        "user_declared_revision": provenance.get("source_revision") if isinstance(provenance, Mapping) else None,
        "limitations": [
            "File hashes remain the primary evidence when selected files are copied outside their source repository.",
            "Remote URLs are intentionally not recorded because they may contain credentials or private locations.",
        ],
    }


def unwrap_stage_content(data: Mapping[str, Any]) -> Dict[str, Any]:
    """
    Many refactored stage outputs may use:
        {"schema_version": ..., "content": {...}}
    This helper returns content when present, otherwise the original dict.
    """
    content = data.get("content")
    if isinstance(content, dict):
        return content
    return dict(data)


# ---------------------------------------------------------------------------
# Master Orchestrator
# ---------------------------------------------------------------------------

class MasterOrchestrator:
    """Controls one experiment run using manifest-based stage handoffs."""

    def __init__(
        self,
        config_path: Path,
        *,
        dry_run: bool = False,
        resume: bool = False,
        strict_outputs: bool = False,
        skip_input_checks: bool = False,
        stop_on_optional_failure: bool = False,
    ) -> None:
        self.config_path = config_path.resolve()
        self.config: Dict[str, Any] = load_normalized_config(self.config_path)
        self.project_root = Path(str(self.config["project_root"])).resolve()
        self.config_validation_warnings: List[str] = []
        self.dry_run = dry_run
        self.resume = bool(resume or self.config.get("resume", False))
        self.strict_outputs = bool(strict_outputs or self.config.get("strict_outputs", False))
        self.skip_input_checks = skip_input_checks
        self.stop_on_optional_failure = stop_on_optional_failure

        self.target_function = str(self.config.get("target_function", "unknown_function"))
        self.target_scheme = str(self.config.get("target_scheme", "unknown_scheme"))
        self.max_iterations = int(self.config.get("max_iterations", 3))
        self.parallel_initial_agents = bool(self.config.get("parallel_initial_agents", True))

        self.run_id = self._choose_run_id()
        output_root = self.config.get("output_root", "runs")
        self.output_root = ensure_relative_to_project(self.project_root, str(output_root))
        self.run_dir = ensure_relative_to_project(
            self.project_root,
            str(self.config.get("run_dir", self.output_root / self.run_id)),
        )
        self.config = apply_runtime_paths(
            self.config,
            project_root=self.project_root,
            run_id=self.run_id,
            output_root=self.output_root,
            run_dir=self.run_dir,
        )

        # New layout object. It creates stage folders and run_manifest.json.
        self.layout = RunLayout(self.run_dir, create=False)

        # Run-level control files only. Stage outputs do not live at root.
        self.status_path = self.run_dir / "status.json"
        self.plan_path = self.run_dir / "workflow_plan.json"
        self.event_log_path = self.run_dir / "events.jsonl"
        self.resolved_config_path = self.run_dir / "run_config.resolved.json"
        self.resolved_llm_profile_path = self.run_dir / "llm_profile.resolved.json"
        self.final_summary_path = self.layout.final_dir / "final_run_summary.json"
        self.repository_snapshot_path = (
            self.run_dir / "stages" / "01_master_orchestrator" / "control" / "repository_provenance.json"
        )

        self.agent_results: List[AgentRunResult] = []
        self.current_artifact_path: Optional[Path] = None
        self.current_artifact_plan_path: Optional[Path] = None
        self.current_artifact_manifest_path: Optional[Path] = None
        self.current_independence_audit_path: Optional[Path] = None
        self.current_iteration = 0
        self.final_status = "not_started"
        self.human_review_required = True

    # ------------------------------------------------------------------
    # Config/setup
    # ------------------------------------------------------------------

    def _choose_run_id(self) -> str:
        if self.config.get("run_id"):
            return safe_name(str(self.config["run_id"]))
        timestamp = _dt.datetime.now().strftime("%Y%m%d_%H%M%S")
        return safe_name(f"run_{timestamp}_{self.target_function}")

    def validate_config(self) -> None:
        report = validate_pipeline_config(
            self.config,
            check_input_files=not self.skip_input_checks,
        )
        self.config_validation_warnings = list(report.warnings)
        report.raise_for_errors()

    def setup_run_dir(self) -> None:
        # Create complete clean stage layout.
        self.layout = RunLayout(self.run_dir, create=True)
        self.run_dir.mkdir(parents=True, exist_ok=True)
        self.layout.final_dir.mkdir(parents=True, exist_ok=True)

        # Snapshot config and selected primary inputs once under Stage 1 control.
        input_snapshot_dir = self.layout.control_dir("01_master_orchestrator") / "input_snapshot"
        input_snapshot_dir.mkdir(parents=True, exist_ok=True)
        copied_inputs: Dict[str, str] = {}

        copied = copy_if_exists(self.config_path, input_snapshot_dir / self.config_path.name)
        if copied:
            copied_inputs["config"] = copied

        llm_profile_meta = self.config.get("_llm_profile")
        if isinstance(llm_profile_meta, Mapping):
            source_profile = llm_profile_meta.get("source_path")
            if source_profile:
                source_path = Path(str(source_profile))
                copied = copy_if_exists(
                    source_path,
                    input_snapshot_dir / f"llm_profile_{source_path.name}",
                )
                if copied:
                    copied_inputs["llm_profile"] = copied

        canonical_inputs = canonical_input_summary(self.config)
        snapshot_groups = (
            ("spec", canonical_inputs.get("spec_paths", [])),
            ("code", canonical_inputs.get("code_paths", [])),
        )
        for group, values in snapshot_groups:
            if not isinstance(values, list):
                continue
            for index, value in enumerate(values, start=1):
                src = Path(str(value))
                destination = input_snapshot_dir / f"{group}_{index:02d}_{src.name}"
                copied = copy_if_exists(src, destination)
                if copied:
                    copied_inputs[f"{group}_{index:02d}"] = copied

        self._write_resolved_config()
        self._write_workflow_plan()
        atomic_write_json(
            self.repository_snapshot_path,
            capture_repository_provenance(self.config, self.project_root),
        )

        # Orchestrator stage manifests point to run-level control files.
        orchestrator_control_outputs: Dict[str, Path] = {
            "resolved_config": self.resolved_config_path,
            "workflow_plan": self.plan_path,
            "run_manifest": self.layout.run_manifest_path,
            "repository_provenance": self.repository_snapshot_path,
        }
        if self.resolved_llm_profile_path.exists():
            orchestrator_control_outputs["resolved_llm_profile"] = self.resolved_llm_profile_path

        self.layout.write_stage_manifest(
            "01_master_orchestrator",
            primary_evidence_inputs=[Path(v) for v in copied_inputs.values()],
            deterministic_reference_outputs=orchestrator_control_outputs,
            notes={
                "purpose": "Initialises clean stage-organised layout and records run-level control files.",
                "root_level_stage_outputs_allowed": False,
            },
        )
        self.layout.write_handoff_manifest(
            "01_master_orchestrator",
            outputs=orchestrator_control_outputs,
            authoritative_source="deterministic_control_plane",
            next_stage_consumers=[spec.stage_key for spec in DEFAULT_AGENTS.values()],
            notes={
                "handoff_policy": "Manifest pointers only; no duplicated stage output files.",
            },
        )

        self.update_status("created", message="Run directory created with stage-organised layout.")
        self._refresh_stage1_control_handoff("initial_run_setup_complete")

    def _write_resolved_config(self) -> None:
        resolved = dict(self.config)

        llm = self.config.get("llm")
        profile_meta = self.config.get("_llm_profile")
        if isinstance(llm, Mapping) and isinstance(profile_meta, Mapping):
            atomic_write_json(
                self.resolved_llm_profile_path,
                resolved_profile_record(
                    resolved_llm=llm,
                    metadata=profile_meta,
                ),
            )
            resolved["_llm_profile"] = frozen_profile_metadata(
                profile_meta,
                snapshot_path=self.resolved_llm_profile_path,
            )

        resolved.update(
            {
                "run_id": self.run_id,
                "project_root": str(self.project_root),
                "run_dir": str(self.run_dir),
                "layout_mode": "stage_manifest_no_root_output_dump",
                "status_path": str(self.status_path),
                "event_log_path": str(self.event_log_path),
                "resolved_llm_profile_path": (
                    str(self.resolved_llm_profile_path)
                    if isinstance(llm, Mapping) and isinstance(profile_meta, Mapping)
                    else None
                ),
                "current_artifact_path": str(self.current_artifact_path) if self.current_artifact_path else None,
                "current_artifact_plan_path": str(self.current_artifact_plan_path) if self.current_artifact_plan_path else None,
                "current_artifact_manifest_path": str(self.current_artifact_manifest_path) if self.current_artifact_manifest_path else None,
                "current_independence_audit_path": str(self.current_independence_audit_path) if self.current_independence_audit_path else None,
                "human_review_required": True,
                "canonical_input_summary": canonical_input_summary(self.config),
                "config_validation_warnings": list(self.config_validation_warnings),
                "scientific_guardrails": {
                    "llm_outputs_are_candidates_only": True,
                    "deterministic_reference_outputs_are_advisory_only": True,
                    "formal_tool_is_not_replaced": True,
                    "human_review_required": True,
                    "no_claim_of_full_mlkem_proof": True,
                    "failures_must_be_logged_honestly": True,
                    "no_root_level_stage_output_dump": True,
                    "handoff_via_manifest_pointers": True,
                    "no_duplicate_stage_outputs": True,
                },
            }
        )
        write_json(self.resolved_config_path, resolved)

    def _write_workflow_plan(self) -> None:
        plan = {
            "schema_version": "workflow_plan.v2.stage_layout",
            "run_id": self.run_id,
            "target_scheme": self.target_scheme,
            "target_function": self.target_function,
            "verification_tool": self.config.get("verification_tool"),
            "artifact_type": self.config.get("artifact_type"),
            "property_campaign": self.config.get("property_campaign"),
            "max_iterations": self.max_iterations,
            "parallel_initial_agents": self.parallel_initial_agents,
            "layout_policy": {
                "stage_outputs_written_once": True,
                "root_level_stage_outputs_allowed": False,
                "handoff_uses_manifest_pointers": True,
                "deterministic_reference_is_advisory_only": True,
                "llm_authoritative_is_candidate_stage_output": True,
            },
            "agent_order": [
                "spec_extraction + code_understanding",
                "property_discovery",
                "artifact_generation",
                "critic_review",
                "tool_execution",
                "after every tool result: counterexample_analysis; if failure and iterations remain: repair -> re-review -> tool execution",
                "experiment_logger",
                "evaluation_reporter",
            ],
            "agents": {name: dataclasses.asdict(spec) for name, spec in DEFAULT_AGENTS.items()},
            "positioning": {
                "claim": "Agents generate and evaluate candidate formal-verification artefacts in a reproducible workflow.",
                "non_claim": "The workflow does not claim to fully prove ML-KEM automatically.",
                "authority": "CBMC/formal tools and human researcher remain final correctness authority.",
            },
        }
        write_json(self.plan_path, plan)

    def _refresh_stage1_control_handoff(self, reason: str) -> None:
        """Refresh mutable control-file hashes with explicit provenance."""
        outputs = {
            "resolved_config": self.resolved_config_path,
            "workflow_plan": self.plan_path,
            "run_manifest": self.layout.run_manifest_path,
            "repository_provenance": self.repository_snapshot_path,
        }
        self.layout.write_stage_manifest(
            "01_master_orchestrator",
            deterministic_reference_outputs=outputs,
            notes={
                "purpose": "Current deterministic control-plane records.",
                "refresh_reason": reason,
                "mutable_control_files_refreshed_deliberately": True,
                "root_level_stage_outputs_allowed": False,
            },
        )
        self.layout.write_handoff_manifest(
            "01_master_orchestrator",
            outputs=outputs,
            authoritative_source="deterministic_control_plane",
            next_stage_consumers=[spec.stage_key for spec in DEFAULT_AGENTS.values()],
            notes={
                "handoff_policy": "Manifest pointers only; checksums refreshed after deliberate control-file mutation.",
                "refresh_reason": reason,
            },
        )

    # ------------------------------------------------------------------
    # Logging/status
    # ------------------------------------------------------------------

    def log_event(self, event_type: str, payload: Mapping[str, Any]) -> None:
        event = {
            "timestamp": utc_now(),
            "run_id": self.run_id,
            "event_type": event_type,
            **dict(payload),
        }
        append_jsonl(self.event_log_path, event)

    def update_status(self, status: str, **extra: Any) -> None:
        data = {
            "run_id": self.run_id,
            "status": status,
            "updated_at": utc_now(),
            "target_scheme": self.target_scheme,
            "target_function": self.target_function,
            "current_iteration": self.current_iteration,
            "current_artifact_path": str(self.current_artifact_path) if self.current_artifact_path else None,
            "current_artifact_plan_path": str(self.current_artifact_plan_path) if self.current_artifact_plan_path else None,
            "current_artifact_manifest_path": str(self.current_artifact_manifest_path) if self.current_artifact_manifest_path else None,
            "current_independence_audit_path": str(self.current_independence_audit_path) if self.current_independence_audit_path else None,
            "human_review_required": self.human_review_required,
            "layout_mode": "stage_manifest_no_root_output_dump",
            **extra,
        }
        write_json(self.status_path, data)
        self.log_event("status_update", data)

    # ------------------------------------------------------------------
    # Handoff validation
    # ------------------------------------------------------------------

    def expected_handoff_missing(self, spec: AgentSpec) -> List[str]:
        """Return missing expected handoff keys or files for an agent stage."""
        hpath = self.layout.handoff_manifest_path(spec.stage_key)
        if not hpath.exists():
            return [f"handoff_manifest_missing:{hpath}"]

        try:
            manifest = layout_read_json(hpath)
        except Exception as e:
            return [f"handoff_manifest_unreadable:{hpath}:{e}"]

        outputs = manifest.get("handoff_outputs", {})
        if not isinstance(outputs, dict):
            return ["handoff_outputs_not_object"]

        missing: List[str] = []
        for key in spec.expected_handoff_outputs:
            rel = outputs.get(key)
            if not rel:
                missing.append(f"missing_key:{key}")
                continue
            real_path = (self.layout.stage_dir(spec.stage_key) / str(rel)).resolve()
            if not real_path.exists():
                missing.append(f"missing_file:{key}:{real_path}")
        return missing

    def should_skip_agent(self, spec: AgentSpec) -> bool:
        if not self.resume:
            return False
        return not self.expected_handoff_missing(spec)

    def stage_logs_for_agent(self, spec: AgentSpec) -> Tuple[Path, Path]:
        if spec.stage_key in {
            "06_review_critic",
            "07_tool_execution",
            "08_counterexample_analysis",
            "09_repair_refinement",
        }:
            logs_dir = (
                self.layout.stage_dir(spec.stage_key)
                / "iterations"
                / f"iteration_{self.current_iteration:02d}"
                / "process_logs"
            )
        else:
            logs_dir = self.layout.logs_dir(spec.stage_key)
        logs_dir.mkdir(parents=True, exist_ok=True)
        return (
            logs_dir / f"{spec.name}_stdout.txt",
            logs_dir / f"{spec.name}_stderr.txt",
        )

    # ------------------------------------------------------------------
    # Agent execution
    # ------------------------------------------------------------------

    def build_agent_command(self, spec: AgentSpec, extra_args: Optional[List[str]] = None) -> List[str]:
        script_path = ensure_relative_to_project(self.project_root, spec.script)
        cmd = [
            sys.executable,
            str(script_path),
            "--config",
            str(self.resolved_config_path),
            "--run-dir",
            str(self.run_dir),
        ]
        if extra_args:
            cmd.extend(extra_args)
        return cmd

    def build_agent_env(self, spec: AgentSpec) -> Dict[str, str]:
        env = dict(os.environ)
        env.update(
            {
                "THESIS_RUN_DIR": str(self.run_dir),
                "THESIS_STAGE_KEY": spec.stage_key,
                "THESIS_STAGE_DIR": str(self.layout.stage_dir(spec.stage_key)),
                "THESIS_HANDOFF_MANIFEST": str(self.layout.handoff_manifest_path(spec.stage_key)),
                "THESIS_LAYOUT_MODE": "stage_manifest_no_root_output_dump",
                "THESIS_ITERATION": str(self.current_iteration),
                "THESIS_CURRENT_ARTIFACT": str(self.current_artifact_path) if self.current_artifact_path else "",
                "THESIS_CURRENT_ARTIFACT_PLAN": str(self.current_artifact_plan_path) if self.current_artifact_plan_path else "",
                "THESIS_CURRENT_ARTIFACT_MANIFEST": str(self.current_artifact_manifest_path) if self.current_artifact_manifest_path else "",
                "THESIS_CURRENT_INDEPENDENCE_AUDIT": str(self.current_independence_audit_path) if self.current_independence_audit_path else "",
                "THESIS_INVOCATION_ORIGIN": "master_orchestrator",
                "THESIS_ORCHESTRATOR_PID": str(os.getpid()),
                "THESIS_RUN_ID": self.run_id,
            }
        )
        return env

    def run_agent(self, agent_name: str, extra_args: Optional[List[str]] = None) -> AgentRunResult:
        if agent_name not in DEFAULT_AGENTS:
            raise KeyError(f"Unknown agent name: {agent_name}")

        spec = DEFAULT_AGENTS[agent_name]
        started = _dt.datetime.now(_dt.timezone.utc)
        started_s = started.isoformat(timespec="seconds")
        stdout_file, stderr_file = self.stage_logs_for_agent(spec)
        command = self.build_agent_command(spec, extra_args)
        script_path = Path(command[1])

        self.log_event(
            "agent_start",
            {
                "agent": agent_name,
                "stage_key": spec.stage_key,
                "description": spec.description,
                "command": command,
                "expected_handoff_outputs": list(spec.expected_handoff_outputs),
                "stage_dir": str(self.layout.stage_dir(spec.stage_key)),
            },
        )

        if self.should_skip_agent(spec):
            finished = _dt.datetime.now(_dt.timezone.utc)
            result = AgentRunResult(
                name=agent_name,
                stage_key=spec.stage_key,
                status="skipped_existing_handoff_outputs",
                returncode=0,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_handoff_outputs=list(spec.expected_handoff_outputs),
                missing_handoff_outputs=[],
                handoff_manifest=str(self.layout.handoff_manifest_path(spec.stage_key)),
            )
            self.agent_results.append(result)
            self.log_event("agent_finish", dataclasses.asdict(result))
            return result

        if self.dry_run:
            finished = _dt.datetime.now(_dt.timezone.utc)
            result = AgentRunResult(
                name=agent_name,
                stage_key=spec.stage_key,
                status="dry_run_not_executed",
                returncode=None,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_handoff_outputs=list(spec.expected_handoff_outputs),
                missing_handoff_outputs=list(spec.expected_handoff_outputs),
                handoff_manifest=str(self.layout.handoff_manifest_path(spec.stage_key)),
            )
            self.agent_results.append(result)
            self.log_event("agent_finish", dataclasses.asdict(result))
            return result

        if not script_path.exists():
            finished = _dt.datetime.now(_dt.timezone.utc)
            err = f"Agent script not found: {script_path}"
            stderr_file.write_text(err + "\n", encoding="utf-8")
            result = AgentRunResult(
                name=agent_name,
                stage_key=spec.stage_key,
                status="missing_agent_script",
                returncode=None,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_handoff_outputs=list(spec.expected_handoff_outputs),
                missing_handoff_outputs=list(spec.expected_handoff_outputs),
                handoff_manifest=str(self.layout.handoff_manifest_path(spec.stage_key)),
                error=err,
            )
            self.agent_results.append(result)
            self.log_event("agent_error", dataclasses.asdict(result))
            if spec.required:
                raise FileNotFoundError(err)
            return result

        try:
            proc = subprocess.run(
                command,
                cwd=str(self.project_root),
                text=True,
                capture_output=True,
                timeout=spec.timeout_seconds,
                check=False,
                env=self.build_agent_env(spec),
            )
            stdout_file.write_text(proc.stdout or "", encoding="utf-8")
            stderr_file.write_text(proc.stderr or "", encoding="utf-8")

            missing = self.expected_handoff_missing(spec)
            ok_outputs = not missing or not self.strict_outputs
            if proc.returncode == 0 and ok_outputs:
                status = "passed"
            elif proc.returncode == 0 and missing:
                status = "passed_but_missing_expected_handoff_outputs"
            else:
                status = "failed"

            finished = _dt.datetime.now(_dt.timezone.utc)
            result = AgentRunResult(
                name=agent_name,
                stage_key=spec.stage_key,
                status=status,
                returncode=proc.returncode,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_handoff_outputs=list(spec.expected_handoff_outputs),
                missing_handoff_outputs=missing,
                handoff_manifest=str(self.layout.handoff_manifest_path(spec.stage_key)),
                error=None if status == "passed" else read_text_if_exists(stderr_file),
            )
            self.agent_results.append(result)
            self.log_event("agent_finish", dataclasses.asdict(result))

            if result.status in {"failed", "passed_but_missing_expected_handoff_outputs"} and spec.required:
                raise RuntimeError(f"Required agent failed: {agent_name}. See {stderr_file}")
            if result.status == "failed" and self.stop_on_optional_failure:
                raise RuntimeError(f"Optional agent failed and stop_on_optional_failure=True: {agent_name}")
            return result

        except subprocess.TimeoutExpired as e:
            finished = _dt.datetime.now(_dt.timezone.utc)
            stdout_file.write_text(e.stdout or "", encoding="utf-8")
            stderr_file.write_text(
                (e.stderr or "") + f"\nTIMEOUT after {spec.timeout_seconds} seconds\n",
                encoding="utf-8",
            )
            result = AgentRunResult(
                name=agent_name,
                stage_key=spec.stage_key,
                status="timeout",
                returncode=None,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_handoff_outputs=list(spec.expected_handoff_outputs),
                missing_handoff_outputs=self.expected_handoff_missing(spec),
                handoff_manifest=str(self.layout.handoff_manifest_path(spec.stage_key)),
                error=f"Timeout after {spec.timeout_seconds} seconds",
            )
            self.agent_results.append(result)
            self.log_event("agent_error", dataclasses.asdict(result))
            if spec.required:
                raise TimeoutError(result.error)
            return result

    def run_initial_agents(self) -> None:
        self.update_status("running_initial_agents")
        names = ["spec_extraction", "code_understanding"]

        if not self.parallel_initial_agents or self.dry_run:
            for name in names:
                self.run_agent(name)
            return

        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            futures = {executor.submit(self.run_agent, name): name for name in names}
            for future in concurrent.futures.as_completed(futures):
                name = futures[future]
                try:
                    future.result()
                except Exception as e:
                    self.log_event(
                        "parallel_agent_exception",
                        {"agent": name, "error": str(e), "traceback": traceback.format_exc()},
                    )
                    raise

    # ------------------------------------------------------------------
    # Decision helpers
    # ------------------------------------------------------------------

    def critic_requires_repair(self) -> bool:
        """Consume only the canonical deterministic review gate contract."""
        try:
            gate_path = self.layout.get_handoff("06_review_critic", "review_gate_decision")
            gate = unwrap_stage_content(read_json(gate_path))
        except Exception:
            return True
        allowed = bool(gate.get("tool_execution_allowed", False))
        final_gate = str(gate.get("final_gate") or "missing_gate").strip().lower()
        return (not allowed) or final_gate not in {"approved_for_tool_execution", "approved_for_analysis_only"}

    def tool_result_classification(self) -> str:
        try:
            status_path = self.layout.get_handoff("07_tool_execution", "cbmc_status")
            data = unwrap_stage_content(read_json(status_path))
        except Exception:
            return ""
        return str(data.get("result_classification") or data.get("status") or data.get("result") or "").strip().lower()

    def cbmc_passed(self) -> bool:
        try:
            status_path = self.layout.get_handoff("07_tool_execution", "cbmc_status")
            data = unwrap_stage_content(read_json(status_path))
        except Exception:
            return False
        status = self.tool_result_classification()
        return status in {
            "passed",
            "pass",
            "success",
            "verified",
            "ok",
            "verification_successful",
        }

    def make_iteration_record(self, iteration: int) -> None:
        """
        Record iteration evidence by manifest pointer, not by copying files.
        This replaces old snapshot copies and avoids duplicate generated outputs.
        """
        diagnostics_dir = self.layout.diagnostics_dir("01_master_orchestrator") / "iterations"
        diagnostics_dir.mkdir(parents=True, exist_ok=True)
        record: Dict[str, Any] = {
            "schema_version": "iteration_record.v1",
            "created_utc": utc_now(),
            "iteration": iteration,
            "policy": "pointer_record_no_file_copies",
            "current_artifact_path": str(self.current_artifact_path) if self.current_artifact_path else None,
            "current_artifact_plan_path": str(self.current_artifact_plan_path) if self.current_artifact_plan_path else None,
            "current_artifact_manifest_path": str(self.current_artifact_manifest_path) if self.current_artifact_manifest_path else None,
            "current_independence_audit_path": str(self.current_independence_audit_path) if self.current_independence_audit_path else None,
            "available_handoffs": self.collect_handoff_index(),
        }
        path = diagnostics_dir / f"iteration_{iteration:02d}.json"
        write_json(path, record)
        self.log_event("iteration_record", {"iteration": iteration, "record_path": str(path)})

    def promote_repaired_artifact(self) -> bool:
        try:
            repaired = self.layout.get_handoff("09_repair_refinement", "repaired_harness")
        except Exception as exc:
            self.log_event(
                "repair_artifact_not_promoted",
                {"iteration": self.current_iteration, "reason": f"handoff_unavailable: {exc}"},
            )
            return False
        if not repaired.is_file():
            self.log_event(
                "repair_artifact_not_promoted",
                {"iteration": self.current_iteration, "reason": "repaired_harness_missing", "path": str(repaired)},
            )
            return False

        repaired_plan: Optional[Path] = None
        repaired_manifest: Optional[Path] = None
        repaired_audit: Optional[Path] = None
        try:
            candidate = self.layout.get_handoff("09_repair_refinement", "repaired_artifact_plan")
            if candidate.is_file():
                repaired_plan = candidate.resolve()
        except Exception:
            pass
        try:
            candidate = self.layout.get_handoff("09_repair_refinement", "repaired_artifact_manifest")
            if candidate.is_file():
                repaired_manifest = candidate.resolve()
        except Exception:
            pass
        try:
            candidate = self.layout.get_handoff("09_repair_refinement", "repaired_independence_audit")
            if candidate.is_file():
                repaired_audit = candidate.resolve()
        except Exception:
            pass

        # A repaired plan, manifest and fresh anti-copy audit are one promotion unit.
        # Contract-only repairs may reuse the existing harness by canonical pointer, but
        # they may never reuse the previous bundle's audit as if it covered new clauses.
        bundle_flags = [bool(repaired_plan), bool(repaired_manifest), bool(repaired_audit)]
        if any(bundle_flags) and not all(bundle_flags):
            self.log_event(
                "repair_artifact_not_promoted",
                {
                    "iteration": self.current_iteration,
                    "reason": "incomplete_repaired_artifact_bundle",
                    "repaired_plan": str(repaired_plan) if repaired_plan else None,
                    "repaired_manifest": str(repaired_manifest) if repaired_manifest else None,
                    "repaired_independence_audit": str(repaired_audit) if repaired_audit else None,
                },
            )
            return False

        self.current_artifact_path = repaired.resolve()
        if repaired_plan and repaired_manifest and repaired_audit:
            self.current_artifact_plan_path = repaired_plan
            self.current_artifact_manifest_path = repaired_manifest
            self.current_independence_audit_path = repaired_audit
        self._write_resolved_config()
        self._refresh_stage1_control_handoff("repaired_artifact_promoted")
        self.update_status(
            "artifact_repaired",
            current_artifact_path=str(self.current_artifact_path),
            current_artifact_plan_path=(str(self.current_artifact_plan_path) if self.current_artifact_plan_path else None),
            current_artifact_manifest_path=(str(self.current_artifact_manifest_path) if self.current_artifact_manifest_path else None),
            current_independence_audit_path=(str(self.current_independence_audit_path) if self.current_independence_audit_path else None),
            promoted_from_iteration=self.current_iteration,
        )
        return True

    # ------------------------------------------------------------------
    # Main pipeline
    # ------------------------------------------------------------------

    def run_pipeline(self) -> int:
        try:
            self.final_status = "running"
            self.validate_config()
            self.setup_run_dir()
            self.update_status("running", message="Master Orchestrator started.")

            self.run_initial_agents()

            self.update_status("running_property_discovery")
            self.run_agent("property_discovery")

            self.update_status("running_artifact_generation")
            self.run_agent("artifact_generation")
            try:
                self.current_artifact_path = self.layout.get_handoff("05_artifact_generation", "generated_harness")
            except Exception:
                self.current_artifact_path = None
            try:
                self.current_artifact_plan_path = self.layout.get_handoff("05_artifact_generation", "artifact_plan")
            except Exception:
                self.current_artifact_plan_path = None
            try:
                self.current_artifact_manifest_path = self.layout.get_handoff("05_artifact_generation", "artifact_manifest")
            except Exception:
                self.current_artifact_manifest_path = None
            try:
                self.current_independence_audit_path = self.layout.get_handoff("05_artifact_generation", "independence_audit")
            except Exception:
                self.current_independence_audit_path = None
            self._write_resolved_config()
            self._refresh_stage1_control_handoff("initial_candidate_artifact_selected")

            verification_passed = False
            stopped_reason = "max_iterations_reached"

            for iteration in range(0, self.max_iterations + 1):
                self.current_iteration = iteration
                self.update_status("running_iteration", iteration=iteration)

                critic_args = ["--iteration", str(iteration)]
                if self.current_artifact_path:
                    critic_args.extend(["--artifact", str(self.current_artifact_path)])
                if self.current_artifact_plan_path:
                    critic_args.extend(["--artifact-plan", str(self.current_artifact_plan_path)])
                if self.current_artifact_manifest_path:
                    critic_args.extend(["--artifact-manifest", str(self.current_artifact_manifest_path)])
                if self.current_independence_audit_path:
                    critic_args.extend(["--independence-audit", str(self.current_independence_audit_path)])
                self.run_agent("critic_review", extra_args=critic_args)

                if self.critic_requires_repair():
                    self.log_event("critic_decision", {"iteration": iteration, "decision": "repair_required_before_tool"})
                    if iteration >= self.max_iterations:
                        stopped_reason = "critic_requested_repair_but_iteration_limit_reached"
                        self.make_iteration_record(iteration)
                        break
                    self.run_agent("repair", extra_args=["--iteration", str(iteration), "--reason", "critic_review"])
                    if not self.promote_repaired_artifact():
                        stopped_reason = "critic_repair_produced_no_repaired_harness"
                        self.make_iteration_record(iteration)
                        break
                    self.make_iteration_record(iteration)
                    continue

                self.log_event("critic_decision", {"iteration": iteration, "decision": "artifact_acceptable_for_tool_execution"})
                tool_args = ["--iteration", str(iteration)]
                if self.current_artifact_path:
                    tool_args.extend(["--artifact", str(self.current_artifact_path)])
                self.run_agent("tool_execution", extra_args=tool_args)

                # Agent 8 analyses every completed formal-tool result. On success it records
                # the checked scope and limitations; on failure it diagnoses the available
                # counterexample/build/tool evidence. Analysis is not itself a repair iteration.
                self.run_agent("counterexample_analysis", extra_args=["--iteration", str(iteration)])

                if self.tool_result_classification() == "analysis_only_no_formal_tool_claim":
                    stopped_reason = "analysis_only_stage_completed_no_formal_claim"
                    self.make_iteration_record(iteration)
                    break

                if self.cbmc_passed():
                    verification_passed = True
                    stopped_reason = "formal_tool_passed_selected_properties"
                    self.make_iteration_record(iteration)
                    break

                self.log_event("tool_decision", {"iteration": iteration, "decision": "tool_failed_or_unknown_status"})
                if iteration >= self.max_iterations:
                    stopped_reason = "tool_failed_and_iteration_limit_reached"
                    self.make_iteration_record(iteration)
                    break

                self.run_agent("repair", extra_args=["--iteration", str(iteration), "--reason", "counterexample_analysis"])
                if not self.promote_repaired_artifact():
                    stopped_reason = "counterexample_repair_produced_no_repaired_harness"
                    self.make_iteration_record(iteration)
                    break
                self.make_iteration_record(iteration)

            # Write the core orchestration outcome before Agent 10 reads provenance.
            self.final_status = (
                "passed_selected_properties" if verification_passed else
                "completed_analysis_only_no_formal_claim" if stopped_reason == "analysis_only_stage_completed_no_formal_claim" else
                "completed_with_failures_or_unresolved_items"
            )
            self.write_final_summary(
                final_status=self.final_status,
                verification_passed=verification_passed,
                stopped_reason=stopped_reason,
            )
            self.update_status(
                "orchestration_core_completed",
                provisional_final_status=self.final_status,
                verification_passed_selected_properties=verification_passed,
                stopped_reason=stopped_reason,
                normal_orchestrated_execution=True,
            )
            self._write_resolved_config()
            self._refresh_stage1_control_handoff("before_experiment_logger")

            try:
                self.run_agent("experiment_logger")
            except Exception as e:
                self.log_event("optional_logger_failed", {"error": str(e)})
                if self.stop_on_optional_failure:
                    raise

            try:
                self.run_agent("evaluation_reporter")
            except Exception as e:
                self.log_event("optional_evaluation_failed", {"error": str(e)})
                if self.stop_on_optional_failure:
                    raise

            self.write_final_summary(
                final_status=self.final_status,
                verification_passed=verification_passed,
                stopped_reason=stopped_reason,
            )
            self.update_status(
                self.final_status,
                verification_passed_selected_properties=verification_passed,
                stopped_reason=stopped_reason,
                normal_orchestrated_execution=True,
                logging_and_evaluation_completed=True,
            )
            return 0 if verification_passed else 2

        except Exception as e:
            self.final_status = "orchestrator_failed"
            try:
                self.log_event(
                    "orchestrator_exception",
                    {"error": str(e), "traceback": traceback.format_exc()},
                )
            except Exception:
                pass
            self.write_final_summary(
                final_status=self.final_status,
                verification_passed=False,
                stopped_reason="orchestrator_exception",
                error=str(e),
            )
            try:
                self.update_status("orchestrator_failed", error=str(e))
            except Exception:
                pass
            print(f"[ERROR] Master Orchestrator failed: {e}", file=sys.stderr)
            print(f"[INFO] Check run folder: {self.run_dir}", file=sys.stderr)
            return 1

    # ------------------------------------------------------------------
    # Final summary/index helpers
    # ------------------------------------------------------------------

    def collect_handoff_index(self) -> Dict[str, Any]:
        index: Dict[str, Any] = {}
        for spec in DEFAULT_AGENTS.values():
            hpath = self.layout.handoff_manifest_path(spec.stage_key)
            if not hpath.exists():
                continue
            try:
                manifest = layout_read_json(hpath)
                stage_dir = self.layout.stage_dir(spec.stage_key)
                outputs = manifest.get("handoff_outputs", {})
                index[spec.stage_key] = {
                    "handoff_manifest": str(hpath),
                    "outputs": {
                        key: str((stage_dir / rel).resolve())
                        for key, rel in outputs.items()
                    } if isinstance(outputs, dict) else {},
                }
            except Exception as e:
                index[spec.stage_key] = {"handoff_manifest": str(hpath), "error": str(e)}
        return index

    def write_final_summary(
        self,
        *,
        final_status: str,
        verification_passed: bool,
        stopped_reason: str,
        error: Optional[str] = None,
    ) -> None:
        summary = {
            "schema_version": "final_run_summary.v2.stage_layout",
            "run_id": self.run_id,
            "final_status": final_status,
            "verification_passed_selected_properties": verification_passed,
            "stopped_reason": stopped_reason,
            "error": error,
            "target_scheme": self.target_scheme,
            "target_function": self.target_function,
            "verification_tool": self.config.get("verification_tool"),
            "artifact_type": self.config.get("artifact_type"),
            "max_iterations": self.max_iterations,
            "actual_iterations_reached": self.current_iteration,
            "run_dir": str(self.run_dir),
            "layout_policy": {
                "stage_outputs_written_once": True,
                "root_level_stage_outputs_allowed": False,
                "handoff_uses_manifest_pointers": True,
            },
            "workflow_plan": str(self.plan_path),
            "status_file": str(self.status_path),
            "event_log": str(self.event_log_path),
            "handoff_index": self.collect_handoff_index(),
            "agent_results": [dataclasses.asdict(r) for r in self.agent_results],
            "scientific_interpretation": {
                "safe_claim": "This run provides evidence about generation/review/tool-checking/refinement of candidate formal-verification artefacts.",
                "unsafe_claim_to_avoid": "Do not claim this run proves the full ML-KEM implementation.",
                "human_review_required": True,
                "formal_tool_authority": str(self.config.get("verification_tool", "CBMC")),
            },
            "created_at": utc_now(),
        }
        write_json(self.final_summary_path, summary)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Master Orchestrator with stage-organised manifest handoff layout."
    )
    parser.add_argument("--config", required=True, help="Path to run config JSON, e.g., configs/poly_add_run.json")
    parser.add_argument("--dry-run", action="store_true", help="Create layout/plan/status and print commands without executing agents.")
    parser.add_argument("--resume", action="store_true", help="Skip agents whose expected handoff outputs already exist.")
    parser.add_argument("--strict-outputs", action="store_true", help="Treat missing expected handoff outputs as failure even if agent exits 0.")
    parser.add_argument("--skip-input-checks", action="store_true", help="Do not require source/spec files to exist.")
    parser.add_argument("--stop-on-optional-failure", action="store_true", help="Fail run if optional logger/evaluation fails.")
    return parser


def main(argv: Optional[List[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)

    orchestrator = MasterOrchestrator(
        Path(args.config),
        dry_run=args.dry_run,
        resume=args.resume,
        strict_outputs=args.strict_outputs,
        skip_input_checks=args.skip_input_checks,
        stop_on_optional_failure=args.stop_on_optional_failure,
    )
    exit_code = orchestrator.run_pipeline()

    print("\n=== Master Orchestrator finished ===")
    print(f"Run ID: {orchestrator.run_id}")
    print(f"Status: {orchestrator.final_status}")
    print(f"Run folder: {orchestrator.run_dir}")
    print(f"Run manifest: {orchestrator.layout.run_manifest_path}")
    print(f"Workflow plan: {orchestrator.plan_path}")
    print(f"Status file: {orchestrator.status_path}")
    print(f"Event log: {orchestrator.event_log_path}")
    print(f"Final summary: {orchestrator.final_summary_path}")
    print("Stage outputs are under run_dir/stages/* and are discovered through handoff manifests.")
    print("Human review is still required before making any thesis correctness claim.")
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
