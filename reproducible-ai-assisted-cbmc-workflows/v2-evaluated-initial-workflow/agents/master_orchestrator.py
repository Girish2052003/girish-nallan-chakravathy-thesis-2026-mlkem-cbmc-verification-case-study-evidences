#!/usr/bin/env python3
"""
Master Orchestrator Agent for the thesis agentic workflow.

Purpose
-------
This agent is the controller of the pipeline. It does not claim to prove ML-KEM.
It coordinates agents that generate CANDIDATE formal-verification artifacts, then
passes those artifacts to review, CBMC/tool execution, counterexample analysis,
repair, logging, and evaluation stages.

Scientific guardrail
--------------------
LLM-generated artifacts are never treated as final proof. Formal tools such as
CBMC and human review remain the final authority.

Designed for the promised workflow:
1. Specification Extraction Agent
2. Code Understanding Agent
3. Property Discovery Agent
4. Formal Artifact Generation Agent
5. Review / Critic Agent
6. Formal Tool Execution Agent
7. Counterexample Analysis Agent
8. Repair / Refinement Agent
9. Experiment Logger Agent
10. Evaluation and Reporting Agent

The Master Orchestrator is Agent 1 and coordinates all of them.

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
import shutil
import subprocess
import sys
import traceback
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple


# -----------------------------
# Data models
# -----------------------------

@dataclasses.dataclass(frozen=True)
class AgentSpec:
    """Static description of an agent script and its expected outputs."""

    name: str
    script: str
    expected_outputs: Tuple[str, ...]
    required: bool = True
    timeout_seconds: int = 900
    description: str = ""


@dataclasses.dataclass
class AgentRunResult:
    """Runtime result of one agent execution."""

    name: str
    status: str
    returncode: Optional[int]
    started_at: str
    finished_at: str
    duration_seconds: float
    command: List[str]
    stdout_file: str
    stderr_file: str
    expected_outputs: List[str]
    missing_outputs: List[str]
    error: Optional[str] = None


# -----------------------------
# Default promised agent map
# -----------------------------

DEFAULT_AGENTS: Dict[str, AgentSpec] = {
    "spec_extraction": AgentSpec(
        name="spec_extraction",
        script="agents/spec_extraction_agent.py",
        expected_outputs=("01_spec_summary.json",),
        description="Extracts constants, assumptions, guarantees, safety properties, and uncertainties from selected spec excerpt.",
    ),
    "code_understanding": AgentSpec(
        name="code_understanding",
        script="agents/code_understanding_agent.py",
        expected_outputs=("02_code_summary.json",),
        description="Summarizes selected implementation code: inputs, outputs, loops, array accesses, helpers, risks, uncertainties.",
    ),
    "property_discovery": AgentSpec(
        name="property_discovery",
        script="agents/property_discovery_agent.py",
        expected_outputs=("03_candidate_properties.json",),
        description="Combines spec and code summaries to propose candidate formal properties.",
    ),
    "artifact_generation": AgentSpec(
        name="artifact_generation",
        script="agents/artifact_generation_agent.py",
        expected_outputs=("04_generated_harness.c", "04_generated_artifact_notes.json"),
        description="Generates candidate CBMC harnesses, assumptions, assertions, and notes.",
    ),
    "critic_review": AgentSpec(
        name="critic_review",
        script="agents/review_critic_agent.py",
        expected_outputs=("05_critic_review.json",),
        description="Reviews generated artifact for unsupported assumptions, weak/strong assertions, wrong constants, trivial proofs, and edge cases.",
    ),
    "tool_execution": AgentSpec(
        name="tool_execution",
        script="agents/tool_execution_agent.py",
        expected_outputs=("06_cbmc_output.txt", "06_cbmc_status.json"),
        description="Runs CBMC or selected formal tool and stores output/status.",
        timeout_seconds=1800,
    ),
    "counterexample_analysis": AgentSpec(
        name="counterexample_analysis",
        script="agents/counterexample_analysis_agent.py",
        expected_outputs=("07_counterexample_analysis.json",),
        description="Explains failed CBMC/tool result and classifies failure source.",
    ),
    "repair": AgentSpec(
        name="repair",
        script="agents/repair_agent.py",
        expected_outputs=("08_repaired_harness.c", "08_repair_notes.json"),
        description="Repairs/refines candidate artifact based on critic and counterexample analysis.",
    ),
    "experiment_logger": AgentSpec(
        name="experiment_logger",
        script="agents/experiment_logger.py",
        expected_outputs=("experiment_log_index.json",),
        required=False,
        description="Optional external logger finalization. Internal JSONL logging always runs even if this script does not exist.",
    ),
    "evaluation_reporter": AgentSpec(
        name="evaluation_reporter",
        script="agents/evaluation_reporter.py",
        expected_outputs=("final_report.md", "evaluation_table.csv"),
        required=False,
        description="Generates final evaluation report and table from the run folder.",
    ),
}


# -----------------------------
# Utility functions
# -----------------------------

def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


def safe_name(value: str) -> str:
    allowed = []
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
        return json.load(f)


def write_json(path: Path, data: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    tmp.replace(path)


def append_jsonl(path: Path, data: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(data, ensure_ascii=False) + "\n")


def read_text_if_exists(path: Path, max_chars: int = 2000) -> str:
    if not path.exists():
        return ""
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
        return text[:max_chars]
    except Exception:
        return ""


def copy_if_exists(src: Path, dst: Path) -> Optional[str]:
    if not src.exists():
        return None
    dst.parent.mkdir(parents=True, exist_ok=True)
    if src.is_file():
        shutil.copy2(src, dst)
        return str(dst)
    return None


def ensure_relative_to_project(project_root: Path, maybe_path: str) -> Path:
    p = Path(maybe_path).expanduser()
    if not p.is_absolute():
        p = project_root / p
    return p.resolve()


def file_exists_in_run(run_dir: Path, filename: str) -> bool:
    return (run_dir / filename).exists()


# -----------------------------
# Orchestrator
# -----------------------------

class MasterOrchestrator:
    """Controls the complete promised pipeline for one experiment run."""

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
        self.project_root = self.config_path.parent.parent.resolve()
        self.config: Dict[str, Any] = read_json(self.config_path)
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

        self.internal_dir = self.run_dir / ".orchestrator"
        self.status_path = self.run_dir / "status.json"
        self.plan_path = self.run_dir / "workflow_plan.json"
        self.event_log_path = self.run_dir / "events.jsonl"
        self.resolved_config_path = self.run_dir / "run_config.resolved.json"
        self.final_summary_path = self.run_dir / "final_run_summary.json"

        self.agent_results: List[AgentRunResult] = []
        self.current_artifact = "04_generated_harness.c"
        self.current_iteration = 0
        self.final_status = "not_started"
        self.human_review_required = True

    # ---------- config and setup ----------

    def _choose_run_id(self) -> str:
        if self.config.get("run_id"):
            return safe_name(str(self.config["run_id"]))
        timestamp = _dt.datetime.now().strftime("%Y%m%d_%H%M%S")
        return safe_name(f"run_{timestamp}_{self.target_function}")

    def validate_config(self) -> None:
        # Agent 2 v2 compatibility note:
        # Old controlled mode uses `spec_file`. New auto-search mode can use
        # `spec_source` + `auto_extract_spec_excerpt`. Therefore the orchestrator
        # must accept either spec_file OR spec_source. This keeps the old flow
        # working while allowing automatic FIPS/local-standard section extraction.
        required_keys = [
            "target_scheme",
            "target_function",
            "source_file",
            "verification_tool",
            "artifact_type",
            "max_iterations",
        ]
        missing = [k for k in required_keys if k not in self.config]
        if missing:
            raise ValueError(f"Missing required config keys: {missing}")

        if not (self.config.get("spec_file") or self.config.get("spec_source") or self.config.get("fips_source")):
            raise ValueError("Missing specification input: provide either 'spec_file' for controlled excerpt mode or 'spec_source' for Agent 2 v2 auto-search mode.")

        if self.max_iterations < 0 or self.max_iterations > 20:
            raise ValueError("max_iterations must be between 0 and 20. Use 2 or 3 for thesis experiments.")

        if not self.skip_input_checks:
            source_file = ensure_relative_to_project(self.project_root, str(self.config["source_file"]))
            spec_input_key = "spec_file" if self.config.get("spec_file") else ("spec_source" if self.config.get("spec_source") else "fips_source")
            spec_file = ensure_relative_to_project(self.project_root, str(self.config[spec_input_key]))
            missing_files = []
            if not source_file.exists():
                missing_files.append(str(source_file))
            if not spec_file.exists():
                missing_files.append(str(spec_file))
            if missing_files:
                raise FileNotFoundError(
                    "Input files not found. Either fix config paths or run with --skip-input-checks for planning only: "
                    + json.dumps(missing_files, indent=2)
                )

    def setup_run_dir(self) -> None:
        self.run_dir.mkdir(parents=True, exist_ok=True)
        self.internal_dir.mkdir(parents=True, exist_ok=True)
        (self.run_dir / "input").mkdir(exist_ok=True)
        (self.run_dir / "stdout_stderr").mkdir(exist_ok=True)
        (self.run_dir / "snapshots").mkdir(exist_ok=True)

        # Snapshot original config.
        copy_if_exists(self.config_path, self.run_dir / "input" / self.config_path.name)

        # Snapshot selected input files if available. Agent 2 v2 accepts either
        # spec_file (controlled excerpt) or spec_source/fips_source (auto-search).
        for key in ["source_file", "spec_file", "spec_source", "fips_source"]:
            if key in self.config:
                src = ensure_relative_to_project(self.project_root, str(self.config[key]))
                copy_if_exists(src, self.run_dir / "input" / src.name)

        self._write_resolved_config()
        self._write_workflow_plan()
        self.update_status("created", message="Run directory created and configuration resolved.")

    def _write_resolved_config(self) -> None:
        resolved = dict(self.config)
        resolved.update(
            {
                "run_id": self.run_id,
                "project_root": str(self.project_root),
                "run_dir": str(self.run_dir),
                "status_path": str(self.status_path),
                "event_log_path": str(self.event_log_path),
                "current_artifact": self.current_artifact,
                "human_review_required": True,
                "scientific_guardrails": {
                    "llm_outputs_are_candidates_only": True,
                    "formal_tool_is_not_replaced": True,
                    "human_review_required": True,
                    "no_claim_of_full_mlkem_proof": True,
                    "failures_must_be_logged_honestly": True,
                },
            }
        )
        write_json(self.resolved_config_path, resolved)

    def _write_workflow_plan(self) -> None:
        plan = {
            "run_id": self.run_id,
            "target_scheme": self.target_scheme,
            "target_function": self.target_function,
            "verification_tool": self.config.get("verification_tool"),
            "artifact_type": self.config.get("artifact_type"),
            "max_iterations": self.max_iterations,
            "parallel_initial_agents": self.parallel_initial_agents,
            "agent_order": [
                "spec_extraction + code_understanding",
                "property_discovery",
                "artifact_generation",
                "critic_review",
                "tool_execution",
                "if failure: counterexample_analysis -> repair -> tool_execution repeat",
                "experiment_logger",
                "evaluation_reporter",
            ],
            "agents": {name: dataclasses.asdict(spec) for name, spec in DEFAULT_AGENTS.items()},
            "positioning": {
                "claim": "Agents generate candidate formal-verification artifacts and evidence for evaluation.",
                "non_claim": "The workflow does not claim to fully prove ML-KEM automatically.",
                "authority": "CBMC/formal tools and human researcher remain final correctness authority.",
            },
        }
        write_json(self.plan_path, plan)

    # ---------- logging ----------

    def log_event(self, event_type: str, payload: Dict[str, Any]) -> None:
        event = {
            "timestamp": utc_now(),
            "run_id": self.run_id,
            "event_type": event_type,
            **payload,
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
            "current_artifact": self.current_artifact,
            "human_review_required": self.human_review_required,
            **extra,
        }
        write_json(self.status_path, data)
        self.log_event("status_update", data)

    # ---------- agent execution ----------

    def should_skip_agent(self, spec: AgentSpec) -> bool:
        if not self.resume:
            return False
        return all(file_exists_in_run(self.run_dir, f) for f in spec.expected_outputs)

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

    def run_agent(self, agent_name: str, extra_args: Optional[List[str]] = None) -> AgentRunResult:
        if agent_name not in DEFAULT_AGENTS:
            raise KeyError(f"Unknown agent name: {agent_name}")

        spec = DEFAULT_AGENTS[agent_name]
        started = _dt.datetime.now(_dt.timezone.utc)
        started_s = started.isoformat(timespec="seconds")
        stdout_file = self.run_dir / "stdout_stderr" / f"{agent_name}_stdout.txt"
        stderr_file = self.run_dir / "stdout_stderr" / f"{agent_name}_stderr.txt"
        command = self.build_agent_command(spec, extra_args)
        script_path = Path(command[1])

        self.log_event(
            "agent_start",
            {
                "agent": agent_name,
                "description": spec.description,
                "command": command,
                "expected_outputs": list(spec.expected_outputs),
            },
        )

        if self.should_skip_agent(spec):
            finished = _dt.datetime.now(_dt.timezone.utc)
            result = AgentRunResult(
                name=agent_name,
                status="skipped_existing_outputs",
                returncode=0,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_outputs=list(spec.expected_outputs),
                missing_outputs=[],
            )
            self.agent_results.append(result)
            self.log_event("agent_finish", dataclasses.asdict(result))
            return result

        if self.dry_run:
            finished = _dt.datetime.now(_dt.timezone.utc)
            missing = [f for f in spec.expected_outputs if not (self.run_dir / f).exists()]
            result = AgentRunResult(
                name=agent_name,
                status="dry_run_not_executed",
                returncode=None,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_outputs=list(spec.expected_outputs),
                missing_outputs=missing,
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
                status="missing_agent_script",
                returncode=None,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_outputs=list(spec.expected_outputs),
                missing_outputs=list(spec.expected_outputs),
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
            )
            stdout_file.write_text(proc.stdout or "", encoding="utf-8")
            stderr_file.write_text(proc.stderr or "", encoding="utf-8")

            missing = [f for f in spec.expected_outputs if not (self.run_dir / f).exists()]
            ok_outputs = not missing or not self.strict_outputs
            if proc.returncode == 0 and ok_outputs:
                status = "passed"
            elif proc.returncode == 0 and missing:
                status = "passed_but_missing_expected_outputs"
            else:
                status = "failed"

            finished = _dt.datetime.now(_dt.timezone.utc)
            result = AgentRunResult(
                name=agent_name,
                status=status,
                returncode=proc.returncode,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_outputs=list(spec.expected_outputs),
                missing_outputs=missing,
                error=None if status == "passed" else read_text_if_exists(stderr_file),
            )
            self.agent_results.append(result)
            self.log_event("agent_finish", dataclasses.asdict(result))

            if result.status in {"failed", "passed_but_missing_expected_outputs"} and spec.required:
                raise RuntimeError(f"Required agent failed: {agent_name}. See {stderr_file}")
            if result.status == "failed" and self.stop_on_optional_failure:
                raise RuntimeError(f"Optional agent failed and stop_on_optional_failure=True: {agent_name}")
            return result

        except subprocess.TimeoutExpired as e:
            finished = _dt.datetime.now(_dt.timezone.utc)
            stdout_file.write_text(e.stdout or "", encoding="utf-8")
            stderr_file.write_text((e.stderr or "") + f"\nTIMEOUT after {spec.timeout_seconds} seconds\n", encoding="utf-8")
            result = AgentRunResult(
                name=agent_name,
                status="timeout",
                returncode=None,
                started_at=started_s,
                finished_at=finished.isoformat(timespec="seconds"),
                duration_seconds=(finished - started).total_seconds(),
                command=command,
                stdout_file=str(stdout_file),
                stderr_file=str(stderr_file),
                expected_outputs=list(spec.expected_outputs),
                missing_outputs=[f for f in spec.expected_outputs if not (self.run_dir / f).exists()],
                error=f"Timeout after {spec.timeout_seconds} seconds",
            )
            self.agent_results.append(result)
            self.log_event("agent_error", dataclasses.asdict(result))
            if spec.required:
                raise TimeoutError(result.error)
            return result

    def run_initial_agents(self) -> None:
        """Run spec extraction and code understanding, possibly in parallel."""
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

    # ---------- decision helpers ----------

    def critic_requires_repair(self) -> bool:
        review_path = self.run_dir / "05_critic_review.json"
        if not review_path.exists():
            # If critic output missing, be conservative.
            return True

        try:
            review = read_json(review_path)
        except Exception:
            return True

        status = str(review.get("review_status", review.get("status", ""))).lower()
        if status in {"reject", "rejected", "needs_revision", "needs repair", "unusable", "failed"}:
            return True

        issues = review.get("issues", [])
        if isinstance(issues, list):
            for issue in issues:
                if isinstance(issue, dict) and str(issue.get("severity", "")).lower() in {"high", "critical"}:
                    return True
        return False

    def cbmc_passed(self) -> bool:
        status_path = self.run_dir / "06_cbmc_status.json"
        if not status_path.exists():
            return False
        try:
            data = read_json(status_path)
        except Exception:
            return False
        status = str(data.get("status", data.get("result", ""))).lower()
        return status in {"passed", "pass", "success", "verified", "ok"}

    def make_iteration_snapshot(self, iteration: int) -> None:
        """Save copies of key changing files so each refinement attempt is reproducible."""
        snapshot_dir = self.run_dir / "snapshots" / f"iteration_{iteration:02d}"
        snapshot_dir.mkdir(parents=True, exist_ok=True)
        for filename in [
            "04_generated_harness.c",
            "04_generated_artifact_notes.json",
            "05_critic_review.json",
            "06_cbmc_output.txt",
            "06_cbmc_status.json",
            "07_counterexample_analysis.json",
            "08_repaired_harness.c",
            "08_repair_notes.json",
            "status.json",
        ]:
            src = self.run_dir / filename
            if src.exists():
                shutil.copy2(src, snapshot_dir / filename)
        self.log_event("iteration_snapshot", {"iteration": iteration, "snapshot_dir": str(snapshot_dir)})

    def promote_repaired_artifact(self) -> None:
        repaired = self.run_dir / "08_repaired_harness.c"
        if repaired.exists():
            self.current_artifact = "08_repaired_harness.c"
            self._write_resolved_config()
            self.update_status("artifact_repaired", current_artifact=self.current_artifact)

    # ---------- main pipeline ----------

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
            self.current_artifact = "04_generated_harness.c"
            self._write_resolved_config()

            verification_passed = False
            stopped_reason = "max_iterations_reached"

            # At least one pass through critic/tool. max_iterations controls repair attempts.
            for iteration in range(0, self.max_iterations + 1):
                self.current_iteration = iteration
                self.update_status("running_iteration", iteration=iteration)

                self.run_agent("critic_review", extra_args=["--iteration", str(iteration)])

                if self.critic_requires_repair():
                    self.log_event("critic_decision", {"iteration": iteration, "decision": "repair_required_before_tool"})
                    if iteration >= self.max_iterations:
                        stopped_reason = "critic_requested_repair_but_iteration_limit_reached"
                        self.make_iteration_snapshot(iteration)
                        break
                    self.run_agent("repair", extra_args=["--iteration", str(iteration), "--reason", "critic_review"])
                    self.promote_repaired_artifact()
                    self.make_iteration_snapshot(iteration)
                    continue

                self.log_event("critic_decision", {"iteration": iteration, "decision": "artifact_acceptable_for_tool_execution"})
                self.run_agent("tool_execution", extra_args=["--iteration", str(iteration), "--artifact", self.current_artifact])

                if self.cbmc_passed():
                    verification_passed = True
                    stopped_reason = "formal_tool_passed_selected_properties"
                    self.make_iteration_snapshot(iteration)
                    break

                self.log_event("tool_decision", {"iteration": iteration, "decision": "tool_failed_or_unknown_status"})
                if iteration >= self.max_iterations:
                    stopped_reason = "tool_failed_and_iteration_limit_reached"
                    self.make_iteration_snapshot(iteration)
                    break

                self.run_agent("counterexample_analysis", extra_args=["--iteration", str(iteration)])
                self.run_agent("repair", extra_args=["--iteration", str(iteration), "--reason", "counterexample_analysis"])
                self.promote_repaired_artifact()
                self.make_iteration_snapshot(iteration)

            # Optional finalization agents. They are useful, but the internal summary is always generated.
            self.update_status("finalizing_logs")
            try:
                self.run_agent("experiment_logger")
            except Exception as e:
                self.log_event("optional_logger_failed", {"error": str(e)})
                if self.stop_on_optional_failure:
                    raise

            self.update_status("running_evaluation_reporter")
            try:
                self.run_agent("evaluation_reporter")
            except Exception as e:
                self.log_event("optional_evaluation_failed", {"error": str(e)})
                if self.stop_on_optional_failure:
                    raise

            self.final_status = "passed_selected_properties" if verification_passed else "completed_with_failures_or_unresolved_items"
            self.write_final_summary(
                final_status=self.final_status,
                verification_passed=verification_passed,
                stopped_reason=stopped_reason,
            )
            self.update_status(self.final_status, stopped_reason=stopped_reason)
            return 0 if verification_passed else 2

        except Exception as e:
            self.final_status = "orchestrator_failed"
            self.log_event(
                "orchestrator_exception",
                {"error": str(e), "traceback": traceback.format_exc()},
            )
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

    def write_final_summary(
        self,
        *,
        final_status: str,
        verification_passed: bool,
        stopped_reason: str,
        error: Optional[str] = None,
    ) -> None:
        summary = {
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
            "workflow_plan": str(self.plan_path),
            "status_file": str(self.status_path),
            "event_log": str(self.event_log_path),
            "agent_results": [dataclasses.asdict(r) for r in self.agent_results],
            "scientific_interpretation": {
                "safe_claim": "This run provides evidence about generation/review/tool-checking/refinement of candidate formal-verification artifacts.",
                "unsafe_claim_to_avoid": "Do not claim this run proves the full ML-KEM implementation.",
                "human_review_required": True,
                "formal_tool_authority": str(self.config.get("verification_tool", "CBMC")),
            },
            "created_at": utc_now(),
        }
        write_json(self.final_summary_path, summary)


# -----------------------------
# CLI
# -----------------------------

def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Master Orchestrator Agent for AI-assisted formal-verification artifact workflow."
    )
    parser.add_argument(
        "--config",
        required=True,
        help="Path to run config JSON, e.g., configs/poly_add_run.json",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Create plan/status files and print commands without executing agent scripts.",
    )
    parser.add_argument(
        "--resume",
        action="store_true",
        help="Skip agents whose expected output files already exist in the run directory.",
    )
    parser.add_argument(
        "--strict-outputs",
        action="store_true",
        help="Treat missing expected outputs as failure even when agent process exits with code 0.",
    )
    parser.add_argument(
        "--skip-input-checks",
        action="store_true",
        help="Do not require source_file/spec_file to exist. Useful before inputs are copied into place.",
    )
    parser.add_argument(
        "--stop-on-optional-failure",
        action="store_true",
        help="Fail the whole run if optional logger/evaluation agents fail.",
    )
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
    print(f"Status file: {orchestrator.status_path}")
    print(f"Event log: {orchestrator.event_log_path}")
    print(f"Final summary: {orchestrator.final_summary_path}")
    print("Human review is still required before making any thesis correctness claim.")
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
