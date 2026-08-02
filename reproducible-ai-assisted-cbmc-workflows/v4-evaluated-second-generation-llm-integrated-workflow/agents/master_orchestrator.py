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
import hashlib
import subprocess
import sys
import traceback
import threading
import signal
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
        ConfigContractError,
        apply_runtime_paths,
        canonical_input_summary,
        load_normalized_config,
        validate_pipeline_config,
    )
    from agents.common.llm_profile import (
        frozen_profile_metadata,
        resolved_profile_record,
    )
    from agents.common.experiment_protocol import logical_path
    from agents.common.workspace_mode import normalise_workspace_mode
    from agents.common.workflow_policy import REPAIR_GATES, normalise_critic_gate, critic_transition, tool_transition
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
        expected_handoff_outputs=("experiment_log", "run_reproducibility_record", "artifact_inventory", "checksum_manifest"),
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

def run_streaming_process(
    command: List[str],
    *,
    cwd: str,
    env: Mapping[str, str],
    timeout_seconds: int,
    stdout_file: Path,
    stderr_file: Path,
    label: str,
) -> subprocess.CompletedProcess[str]:
    """Stream a child live while writing identical stage logs.

    The child runs in its own process group so timeout/interruption cleanup does
    not leave API/tool descendants behind.
    """
    proc = subprocess.Popen(
        command,
        cwd=cwd,
        env=dict(env),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        bufsize=1,
        start_new_session=True,
    )
    captured = {"stdout": [], "stderr": []}

    def pump(stream, destination: Path, terminal, key: str) -> None:
        assert stream is not None
        with destination.open("w", encoding="utf-8") as handle:
            for line in iter(stream.readline, ""):
                captured[key].append(line)
                handle.write(line)
                handle.flush()
                terminal.write(f"[{label}] {line}")
                terminal.flush()
        stream.close()

    threads = [
        threading.Thread(target=pump, args=(proc.stdout, stdout_file, sys.stdout, "stdout"), daemon=True),
        threading.Thread(target=pump, args=(proc.stderr, stderr_file, sys.stderr, "stderr"), daemon=True),
    ]
    for thread in threads:
        thread.start()
    try:
        returncode = proc.wait(timeout=timeout_seconds)
    except subprocess.TimeoutExpired as exc:
        try:
            os.killpg(proc.pid, signal.SIGTERM)
            proc.wait(timeout=5)
        except Exception:
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except Exception:
                proc.kill()
            proc.wait()
        for thread in threads:
            thread.join(timeout=2)
        raise subprocess.TimeoutExpired(
            command, timeout_seconds,
            output="".join(captured["stdout"]),
            stderr="".join(captured["stderr"]),
        ) from exc
    for thread in threads:
        thread.join(timeout=5)
    return subprocess.CompletedProcess(
        command, returncode, "".join(captured["stdout"]), "".join(captured["stderr"])
    )


class MasterOrchestrator:
    """Controls one experiment run using manifest-based stage handoffs."""

    def __init__(
        self,
        config_path: Path,
        *,
        dry_run: bool = False,
        resume: bool = False,
        resume_policy: Optional[str] = None,
        strict_outputs: bool = False,
        skip_input_checks: bool = False,
        stop_on_optional_failure: bool = False,
    ) -> None:
        self.config_path = config_path.resolve()
        self.config: Dict[str, Any] = load_normalized_config(self.config_path)
        self.project_root = Path(str(self.config["project_root"])).resolve()
        self.workspace_mode = normalise_workspace_mode(self.config)
        self.config_validation_warnings: List[str] = []
        self.dry_run = dry_run
        self.resume = bool(resume or self.config.get("resume", False))
        self.resume_policy = str(
            resume_policy or self.config.get("resume_policy") or "abort"
        ).strip().lower()
        if self.resume_policy not in {"abort", "rerun", "force_reuse"}:
            raise ConfigContractError(
                "resume_policy must be one of: abort, rerun, force_reuse"
            )
        self.strict_outputs = bool(strict_outputs or self.config.get("strict_outputs", False))
        self.skip_input_checks = skip_input_checks
        self.stop_on_optional_failure = stop_on_optional_failure

        self.target_function = str(self.config.get("target_function", "unknown_function"))
        self.target_scheme = str(self.config.get("target_scheme", "unknown_scheme"))
        self.max_iterations = int(self.config.get("max_iterations", 0))
        protocol = self.config.get("experiment_protocol", {}) if isinstance(self.config.get("experiment_protocol"), Mapping) else {}
        self.repair_retry_controls = (
            protocol.get("repair_retry_controls", {})
            if isinstance(protocol.get("repair_retry_controls"), Mapping) else {}
        )
        self.repair_retry_counts = {"tool_diagnostic_repair": 0, "semantic_repair": 0}
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
        errors = list(report.errors)
        self.config_validation_warnings = list(report.warnings)
        if errors:
            rendered = "\n".join(f"  - {item}" for item in errors)
            raise ConfigContractError(f"Configuration contract validation failed:\n{rendered}")

    def setup_run_dir(self) -> None:
        if self.resume and self.run_dir.exists():
            self.layout = RunLayout(self.run_dir, create=False)
            required = [
                self.layout.run_manifest_path, self.resolved_config_path,
                self.layout.handoff_manifest_path("01_master_orchestrator"),
            ]
            missing = [str(path) for path in required if not path.exists()]
            if missing:
                raise RuntimeError(
                    "Resume requested but the existing run lacks required control evidence: "
                    + ", ".join(missing)
                )
            self.log_event("resume_session_started", {
                "resume_policy": self.resume_policy,
                "run_dir": str(self.run_dir),
                "control_files_preserved": True,
            })
            return

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
            ("archival_spec", canonical_inputs.get("archival_spec_paths", [])),
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
        self.layout.write_run_manifest(extra={
            "experiment_protocol_sha256": (self.config.get("experiment_protocol") or {}).get("protocol_sha256"),
            "experiment_protocol_version": (self.config.get("experiment_protocol") or {}).get("protocol_version"),
            "semantic_advisory_mode": (self.config.get("experiment_protocol") or {}).get("semantic_advisory_mode"),
            "workspace_mode": self.workspace_mode,
        })
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
                "run_dir": str(getattr(self, "run_dir", self.layout.run_dir)),
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
                "logical_paths": {
                    "project_root": "$WORKFLOW_ROOT",
                    "run_dir": "$RUN_DIR",
                    "status_path": "$RUN_DIR/status.json",
                    "event_log_path": "$RUN_DIR/events.jsonl",
                    "current_artifact_path": logical_path(self.current_artifact_path, (("$RUN_DIR", self.run_dir), ("$WORKFLOW_ROOT", self.project_root))) if self.current_artifact_path else None,
                    "current_artifact_plan_path": logical_path(self.current_artifact_plan_path, (("$RUN_DIR", self.run_dir), ("$WORKFLOW_ROOT", self.project_root))) if self.current_artifact_plan_path else None,
                },
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
            "property_discovery": self.config.get("property_discovery"),
            "property_campaign": self.config.get("property_campaign"),
            "experiment_protocol": self.config.get("experiment_protocol"),
            "experiment_protocol_sha256": (self.config.get("experiment_protocol") or {}).get("protocol_sha256"),
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

    def _sha256_file(self, path: Path) -> Optional[str]:
        if not path.is_file():
            return None
        h = hashlib.sha256()
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                h.update(chunk)
        return h.hexdigest()

    def _stable_config_sha256(self) -> str:
        payload = dict(self.config)
        for key in (
            "current_artifact_path", "current_artifact_plan_path",
            "current_artifact_manifest_path", "current_independence_audit_path",
            "status_path", "event_log_path", "resolved_llm_profile_path", "logical_paths",
        ):
            payload.pop(key, None)
        encoded = json.dumps(payload, sort_keys=True, separators=(",", ":"), default=str).encode("utf-8")
        return hashlib.sha256(encoded).hexdigest()

    def _resume_input_records(self) -> List[Dict[str, Any]]:
        summary = canonical_input_summary(self.config)
        records: List[Dict[str, Any]] = []
        for group in ("spec_paths", "archival_spec_paths", "code_paths"):
            values = summary.get(group, [])
            if not isinstance(values, list):
                continue
            for value in values:
                path = Path(str(value)).expanduser().resolve()
                records.append({
                    "group": group, "path": str(path), "exists": path.is_file(),
                    "sha256": self._sha256_file(path),
                })
        return records

    def _resume_binding_path(self, spec: AgentSpec) -> Path:
        suffix = (
            f"iteration_{self.current_iteration:02d}.resume_binding.json"
            if self.layout.is_iteration_sensitive(spec.stage_key)
            else "resume_binding.json"
        )
        path = self.layout.stage_dir(spec.stage_key) / "resume_bindings" / suffix
        path.parent.mkdir(parents=True, exist_ok=True)
        return path

    def _upstream_handoff_records(self, stage_key: str) -> List[Dict[str, Any]]:
        dependencies = {
            "02_spec_extraction": ["01_master_orchestrator"],
            "03_code_understanding": ["01_master_orchestrator"],
            "04_property_discovery": ["01_master_orchestrator", "02_spec_extraction", "03_code_understanding"],
            "05_artifact_generation": ["01_master_orchestrator", "02_spec_extraction", "03_code_understanding", "04_property_discovery"],
            "06_review_critic": ["01_master_orchestrator", "04_property_discovery", "05_artifact_generation"],
            "07_tool_execution": ["01_master_orchestrator", "05_artifact_generation", "06_review_critic"],
            "08_counterexample_analysis": ["01_master_orchestrator", "06_review_critic", "07_tool_execution"],
            "09_repair_refinement": ["01_master_orchestrator", "05_artifact_generation", "06_review_critic", "07_tool_execution", "08_counterexample_analysis"],
            "10_experiment_logger": [row.stage_key for row in DEFAULT_AGENTS.values() if row.stage_key not in {"10_experiment_logger", "11_evaluation_reporter"}],
            "11_evaluation_reporter": ["01_master_orchestrator", "10_experiment_logger"],
        }
        rows: List[Dict[str, Any]] = []
        for upstream in dependencies.get(stage_key, ["01_master_orchestrator"]):
            path = self.layout.handoff_manifest_path(upstream)
            if path.is_file():
                rows.append({"stage_key": upstream, "path": str(path), "sha256": self._sha256_file(path)})
        return rows

    def _build_resume_binding(self, spec: AgentSpec) -> Dict[str, Any]:
        handoff_path = self.layout.handoff_manifest_path(spec.stage_key)
        manifest = self.layout.read_handoff_manifest(spec.stage_key)
        outputs = manifest.get("handoff_outputs", {}) if isinstance(manifest.get("handoff_outputs"), dict) else {}
        declared = manifest.get("checksums_sha256", {}) if isinstance(manifest.get("checksums_sha256"), dict) else {}
        output_rows = []
        for key, rel in sorted(outputs.items()):
            path = (self.layout.stage_dir(spec.stage_key) / str(rel)).resolve()
            output_rows.append({
                "key": key, "path": str(path), "exists": path.is_file(),
                "declared_sha256": declared.get(key), "actual_sha256": self._sha256_file(path),
            })
        script = ensure_relative_to_project(self.project_root, spec.script)
        return {
            "schema_version": "stage_resume_binding.v1",
            "stage_key": spec.stage_key,
            "iteration": self.current_iteration if self.layout.is_iteration_sensitive(spec.stage_key) else None,
            "stable_config_sha256": self._stable_config_sha256(),
            "experiment_protocol_sha256": (self.config.get("experiment_protocol") or {}).get("protocol_sha256"),
            "agent_script": str(script),
            "agent_script_sha256": self._sha256_file(script),
            "orchestrator_sha256": self._sha256_file(Path(__file__).resolve()),
            "input_files": self._resume_input_records(),
            "upstream_handoffs": self._upstream_handoff_records(spec.stage_key),
            "handoff_manifest_path": str(handoff_path),
            "handoff_manifest_sha256": self._sha256_file(handoff_path),
            "handoff_outputs": output_rows,
            "authoritative_stage_outcome": (manifest.get("notes") or {}).get("stage_outcome"),
        }

    def _write_resume_binding(self, spec: AgentSpec) -> Path:
        return atomic_write_json(self._resume_binding_path(spec), self._build_resume_binding(spec))

    def _validate_resume_binding(self, spec: AgentSpec) -> Tuple[bool, List[str]]:
        path = self._resume_binding_path(spec)
        if not path.is_file():
            return False, [f"resume_binding_missing:{path}"]
        try:
            recorded = layout_read_json(path)
            current = self._build_resume_binding(spec)
        except Exception as exc:
            return False, [f"resume_binding_unreadable_or_unbuildable:{type(exc).__name__}:{exc}"]
        mismatches: List[str] = []
        for key in (
            "stable_config_sha256", "experiment_protocol_sha256",
            "agent_script_sha256", "orchestrator_sha256",
            "input_files", "upstream_handoffs", "handoff_manifest_sha256",
            "handoff_outputs", "authoritative_stage_outcome",
        ):
            if recorded.get(key) != current.get(key):
                mismatches.append(f"{key}_mismatch")
        return not mismatches, mismatches

    def should_skip_agent(self, spec: AgentSpec) -> bool:
        if not self.resume:
            return False
        missing = self.expected_handoff_missing(spec)
        valid, mismatches = self._validate_resume_binding(spec) if not missing else (False, missing)
        if valid:
            self.log_event("resume_stage_reused", {
                "stage_key": spec.stage_key, "iteration": self.current_iteration,
                "binding_path": str(self._resume_binding_path(spec)),
            })
            return True
        details = {
            "stage_key": spec.stage_key, "iteration": self.current_iteration,
            "resume_policy": self.resume_policy, "mismatches": mismatches,
        }
        if self.resume_policy == "force_reuse" and not missing:
            details["semantic_provenance_reduced"] = True
            self.log_event("resume_stage_force_reused", details)
            return True
        if self.resume_policy == "rerun":
            self.log_event("resume_stage_rerun_required", details)
            return False
        raise RuntimeError(
            "Hash-bound resume rejected stage " + spec.stage_key + ": " + "; ".join(mismatches)
        )

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

    def _stage_failure_diagnostic(self, spec: AgentSpec) -> str:
        """Return one concise root cause and the authoritative stage-status path."""
        stage_dir = self.layout.stage_dir(spec.stage_key)
        candidates = sorted(
            (p for p in stage_dir.rglob("*status.json") if p.is_file()),
            key=lambda p: p.stat().st_mtime,
            reverse=True,
        )
        for path in candidates:
            try:
                data = read_json(path)
            except Exception:
                continue
            errors = data.get("errors")
            message = ""
            if isinstance(errors, list) and errors:
                first = errors[0]
                if isinstance(first, dict):
                    message = str(first.get("message") or first.get("error") or first)
                else:
                    message = str(first)
            if not message:
                message = str(data.get("error") or data.get("message") or "")
            if message:
                return f"{message} [stage_status={path}]"
        return f"No populated stage-status error was found. [stage_dir={stage_dir}]"

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
            if spec.required or self.stop_on_optional_failure:
                raise FileNotFoundError(err)
            return result

        try:
            proc = run_streaming_process(
                command,
                cwd=str(self.project_root),
                env=self.build_agent_env(spec),
                timeout_seconds=spec.timeout_seconds,
                stdout_file=stdout_file,
                stderr_file=stderr_file,
                label=spec.stage_key,
            )

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
                error=(
                    None
                    if status == "passed"
                    else (read_text_if_exists(stderr_file).strip() or self._stage_failure_diagnostic(spec))
                ),
            )
            if result.status == "passed":
                self._write_resume_binding(spec)
            if result.status in {"failed", "passed_but_missing_expected_handoff_outputs"}:
                diagnostic = result.error or self._stage_failure_diagnostic(spec)
                if not read_text_if_exists(stderr_file).strip():
                    stderr_file.write_text(diagnostic + "\n", encoding="utf-8")
                result.error = diagnostic
            self.agent_results.append(result)
            self.log_event("agent_finish", dataclasses.asdict(result))

            if result.status in {"failed", "passed_but_missing_expected_handoff_outputs"} and spec.required:
                raise RuntimeError(
                    f"Required agent failed: {agent_name}: {result.error} "
                    f"[stderr={stderr_file}]"
                )
            if result.status in {"failed", "passed_but_missing_expected_handoff_outputs"} and self.stop_on_optional_failure:
                raise RuntimeError(
                    f"Optional agent failed closed and stop_on_optional_failure=True: {agent_name}: "
                    f"status={result.status}; missing={result.missing_handoff_outputs}; error={result.error}"
                )
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
            if spec.required or self.stop_on_optional_failure:
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

    def critic_gate_state(self) -> str:
        """Read the canonical gate without conflating human review and repair."""
        try:
            gate_path = self.layout.get_handoff(
                "06_review_critic",
                "review_gate_decision",
            )
            gate = unwrap_stage_content(read_json(gate_path))
        except Exception:
            return "missing_gate"

        return normalise_critic_gate(gate)

    def critic_requires_repair(self) -> bool:
        """Return true only for a canonical repair-blocking gate."""
        return self.critic_gate_state() in REPAIR_GATES

    def tool_status(self) -> Dict[str, Any]:
        try:
            status_path = self.layout.get_handoff("07_tool_execution", "cbmc_status")
            data = unwrap_stage_content(read_json(status_path))
        except Exception:
            return {}
        return dict(data) if isinstance(data, Mapping) else {}

    def tool_result_classification(self) -> str:
        data = self.tool_status()
        return str(data.get("result_classification") or data.get("status") or data.get("result") or "").strip().lower()

    def cbmc_passed(self) -> bool:
        data = self.tool_status()
        # Scientific success is never inferred from a generic success word.
        # Agent 7 must explicitly establish complete selected-property coverage
        # under the recorded model using structured CBMC evidence.
        return data.get("selected_property_verified_under_model") is True

    def canonical_tool_transition(self, *, iteration: int):
        """Route the complete Agent 7 status through the shared workflow policy."""
        status = self.tool_status()
        return tool_transition(
            result_classification=status,
            iteration=iteration,
            max_iterations=self.max_iterations,
        )

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

    def _repair_category_allowed(self, category: str) -> Tuple[bool, str]:
        block = (
            self.repair_retry_controls.get(category, {})
            if isinstance(self.repair_retry_controls, Mapping) else {}
        )
        enabled = bool(block.get("enabled", False)) if isinstance(block, Mapping) else False
        limit = int(block.get("max_repairs", 0) or 0) if isinstance(block, Mapping) else 0
        used = int(self.repair_retry_counts.get(category, 0))
        if not enabled:
            return False, f"{category}_disabled_by_experiment_protocol"
        if used >= limit:
            return False, f"{category}_limit_reached:{used}/{limit}"
        return True, f"{category}_allowed:{used}/{limit}"

    def _consume_repair_category(self, category: str, *, source: str, iteration: int) -> None:
        self.repair_retry_counts[category] = int(self.repair_retry_counts.get(category, 0)) + 1
        self.log_event("repair_retry_consumed", {
            "iteration": iteration, "category": category, "source": source,
            "used": self.repair_retry_counts[category],
            "policy": self.repair_retry_controls.get(category, {}),
        })

    @staticmethod
    def _critic_repair_category(gate_state: str) -> str:
        state = str(gate_state or "")
        objective = {
            "blocked_invalid_artifact", "blocked_frontend_readiness_defect",
            "blocked_transformation_readiness_defect", "blocked_missing_selected_claim",
        }
        return "tool_diagnostic_repair" if state in objective else "semantic_repair"

    def _tool_repair_category(self) -> str:
        status = self.tool_status()
        selected = str(status.get("selected_claim_result") or "")
        auxiliary = str(status.get("auxiliary_property_result") or "")
        if selected == "passed" and auxiliary in {"failed", "mixed", "unknown"}:
            return "tool_diagnostic_repair"
        return "semantic_repair"

    # ------------------------------------------------------------------
    # Main pipeline
    # ------------------------------------------------------------------

    def _refresh_current_artifact_handoffs(self) -> None:
        for attribute, output_key in (
            ("current_artifact_path", "generated_harness"),
            ("current_artifact_plan_path", "artifact_plan"),
            ("current_artifact_manifest_path", "artifact_manifest"),
            ("current_independence_audit_path", "independence_audit"),
        ):
            try:
                value = self.layout.get_handoff("05_artifact_generation", output_key)
            except Exception:
                value = None
            setattr(self, attribute, value)

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
            self._refresh_current_artifact_handoffs()
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

                gate_state = self.critic_gate_state()
                critic_step = critic_transition(
                    gate_state, iteration=iteration, max_iterations=self.max_iterations
                )

                if critic_step.action == "stop_for_human_review":
                    self.log_event(
                        "critic_decision",
                        {
                            "iteration": iteration,
                            "decision": "human_review_required_before_tool",
                        },
                    )
                    stopped_reason = "critic_requested_human_review_before_tool"
                    self.make_iteration_record(iteration)
                    break

                if critic_step.action in {"repair_then_rereview", "stop_iteration_limit"}:
                    self.log_event(
                        "critic_decision",
                        {
                            "iteration": iteration,
                            "decision": "repair_required_before_tool",
                            "gate_state": gate_state,
                        },
                    )
                    if critic_step.action == "stop_iteration_limit":
                        stopped_reason = critic_step.reason
                        self.make_iteration_record(iteration)
                        break
                    repair_category = self._critic_repair_category(gate_state)
                    repair_allowed, repair_policy_reason = self._repair_category_allowed(repair_category)
                    if not repair_allowed:
                        stopped_reason = repair_policy_reason
                        self.log_event("repair_retry_blocked", {
                            "iteration": iteration, "category": repair_category,
                            "source": "critic_review", "reason": repair_policy_reason,
                        })
                        self.make_iteration_record(iteration)
                        break
                    self._consume_repair_category(
                        repair_category, source="critic_review", iteration=iteration
                    )
                    self.run_agent(
                        "repair",
                        extra_args=[
                            "--iteration",
                            str(iteration),
                            "--reason",
                            "critic_review",
                        ],
                    )
                    if not self.promote_repaired_artifact():
                        stopped_reason = "critic_repair_produced_no_repaired_harness"
                        self.make_iteration_record(iteration)
                        break
                    self.make_iteration_record(iteration)
                    continue

                self.log_event(
                    "critic_decision",
                    {
                        "iteration": iteration,
                        "decision": "artifact_acceptable_for_tool_execution",
                        "gate_state": gate_state,
                    },
                )
                tool_args = ["--iteration", str(iteration)]
                if self.current_artifact_path:
                    tool_args.extend(["--artifact", str(self.current_artifact_path)])
                self.run_agent("tool_execution", extra_args=tool_args)

                # Agent 8 analyses every completed formal-tool result. On success it records
                # the checked scope and limitations; on failure it diagnoses the available
                # counterexample/build/tool evidence. Analysis is not itself a repair iteration.
                self.run_agent("counterexample_analysis", extra_args=["--iteration", str(iteration)])

                tool_step = self.canonical_tool_transition(iteration=iteration)
                self.log_event(
                    "tool_decision",
                    {"iteration": iteration, **tool_step.to_dict()},
                )
                if tool_step.action == "stop_verified":
                    verification_passed = True
                    stopped_reason = tool_step.reason
                    self.make_iteration_record(iteration)
                    break
                if tool_step.action == "repair_from_tool_evidence":
                    repair_category = self._tool_repair_category()
                    repair_allowed, repair_policy_reason = self._repair_category_allowed(repair_category)
                    if not repair_allowed:
                        stopped_reason = repair_policy_reason
                        self.log_event("repair_retry_blocked", {
                            "iteration": iteration, "category": repair_category,
                            "source": "counterexample_analysis", "reason": repair_policy_reason,
                        })
                        self.make_iteration_record(iteration)
                        break
                    self._consume_repair_category(
                        repair_category, source="counterexample_analysis", iteration=iteration
                    )
                    self.run_agent("repair", extra_args=["--iteration", str(iteration), "--reason", "counterexample_analysis"])
                    if not self.promote_repaired_artifact():
                        stopped_reason = "counterexample_repair_produced_no_repaired_harness"
                        self.make_iteration_record(iteration)
                        break
                    self.make_iteration_record(iteration)
                    continue
                if tool_step.terminal:
                    stopped_reason = tool_step.reason
                    self.make_iteration_record(iteration)
                    break
                stopped_reason = "unrecognised_tool_transition"
                self.make_iteration_record(iteration)
                break

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
            **self.layout.protocol_context(),
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
            "run_dir": str(getattr(self, "run_dir", self.layout.run_dir)),
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
    parser.add_argument("--resume", action="store_true", help="Reuse only stages whose hash-bound resume records match the current run inputs and engine.")
    parser.add_argument("--resume-policy", choices=["abort", "rerun", "force_reuse"], default=None, help="Action when a resume binding is missing or mismatched.")
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
        resume_policy=args.resume_policy,
        strict_outputs=args.strict_outputs,
        skip_input_checks=args.skip_input_checks,
        stop_on_optional_failure=args.stop_on_optional_failure,
    )
    exit_code = orchestrator.run_pipeline()

    print("\n=== Master Orchestrator finished ===")
    print(f"Run ID: {orchestrator.run_id}")
    print(f"Status: {orchestrator.final_status}")
    print(f"Workspace mode: {orchestrator.workspace_mode}")
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
