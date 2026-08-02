#!/usr/bin/env python3
"""
tool_execution_agent_refactored.py

Agent 7 — Formal Tool Execution Agent, refactored for the new thesis workflow.

Architecture implemented:
- Deterministic-only stage.
- No LLM calls.
- Consumes Agent 6 review gate decision through handoff manifest.
- Consumes reviewed/generated harness through handoff manifest.
- Runs CBMC only if the gate allows tool execution, unless explicitly forced.
- Records exact command, environment, stdout/stderr, exit code, status classification,
  property results, trace summary, and reproducibility metadata.
- Writes outputs only under:
    stages/07_tool_execution/
- Downstream agents consume only manifest-declared handoff outputs.
- No root-level output dumping.
- No duplicate output copies.

Trust boundary:
- CBMC output is formal-tool evidence under the recorded harness, command,
  assumptions, unwinding bounds, tool version, and environment.
- A CBMC success is property-specific, harness-specific, and assumption-dependent.
- Agent 7 does not claim full implementation correctness, FIPS compliance,
  cryptographic security, or full ML-KEM correctness.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import platform
import re
import shutil
import subprocess
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
    from agents.common.formal_build import (
        build_cbmc_command_from_plan, build_tool_pipeline_from_plan, validate_formal_build_plan
    )
except Exception as import_exc:  # pragma: no cover
    raise SystemExit(
        "Failed to import shared workflow module:\n"
        "  agents/common/run_layout.py\n"
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
class ToolExecutionConfig:
    run_dir: Path
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM CBMC tool execution"
    cbmc_binary: str = "cbmc"
    goto_cc_binary: str = "goto-cc"
    goto_instrument_binary: str = "goto-instrument"
    cbmc_function: str = "harness"
    timeout_seconds: int = 120
    unwind: Optional[int] = None
    extra_cbmc_args: List[str] = None  # type: ignore
    working_directory: Optional[Path] = None
    force_run: bool = False
    dry_run: bool = False
    allow_missing_gate: bool = False
    allow_missing_harness: bool = False
    require_gate_approval: bool = True
    save_environment: bool = True
    max_output_chars_for_summary: int = 200_000
    iteration: int = 0
    artifact_path: Optional[Path] = None

    def __post_init__(self) -> None:
        if self.extra_cbmc_args is None:
            self.extra_cbmc_args = []


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


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, ToolExecutionConfig]:
    config_data: JsonDict = {}
    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        config_data = load_normalized_config(config_path)

    te = config_data.get("tool_execution", {})
    if not isinstance(te, dict):
        te = {}

    cbmc_args = []
    cbmc_args.extend(parse_list_arg(args.cbmc_arg))
    cfg_args = te.get("extra_cbmc_args") or te.get("cbmc_args")
    if isinstance(cfg_args, list):
        cbmc_args.extend(str(x) for x in cfg_args)
    elif isinstance(cfg_args, str):
        cbmc_args.extend(parse_list_arg(cfg_args))

    unwind = args.unwind if args.unwind is not None else te.get("unwind")
    if unwind is not None:
        unwind = int(unwind)

    target_function = (
        args.target_function
        or str(config_data.get("target_function") or "")
        or str(config_data.get("function_name") or "")
        or "mlk_poly_add"
    )

    target_topic = (
        args.target_topic
        or str(config_data.get("target_topic") or "")
        or f"CBMC tool execution for {target_function}"
    )

    working_dir = args.working_directory or te.get("working_directory")
    working_path = Path(str(working_dir)).expanduser().resolve() if working_dir else None

    cfg = ToolExecutionConfig(
        run_dir=resolve_run_dir(config_data, args),
        target_function=target_function,
        target_topic=target_topic,
        cbmc_binary=args.cbmc_binary or str(te.get("cbmc_binary") or "cbmc"),
        goto_cc_binary=str(te.get("goto_cc_binary") or "goto-cc"),
        goto_instrument_binary=str(te.get("goto_instrument_binary") or "goto-instrument"),
        cbmc_function=args.cbmc_function or str(te.get("cbmc_function") or "harness"),
        timeout_seconds=int(args.timeout_seconds or te.get("timeout_seconds") or 120),
        unwind=unwind,
        extra_cbmc_args=cbmc_args,
        working_directory=working_path,
        force_run=bool(args.force_run or te.get("force_run")),
        dry_run=bool(args.dry_run or te.get("dry_run")),
        allow_missing_gate=bool(args.allow_missing_gate or te.get("allow_missing_gate")),
        allow_missing_harness=bool(args.allow_missing_harness or te.get("allow_missing_harness")),
        require_gate_approval=bool(te.get("require_gate_approval", True)),
        iteration=int(args.iteration),
        artifact_path=Path(args.artifact).expanduser().resolve() if args.artifact else None,
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


def get_gate_value(gate_decision: Optional[JsonDict]) -> Tuple[str, bool, str]:
    if not gate_decision:
        return "missing_gate", False, "No gate decision was available."

    # llm_client/layout validation wrapper may wrap content.
    gate = extract_content_wrapper(gate_decision)

    final_gate = str(gate.get("final_gate") or gate.get("gate") or "unknown_gate")
    allowed = bool(gate.get("tool_execution_allowed", False))
    reason = str(gate.get("reason") or "")
    return final_gate, allowed, reason


# ---------------------------------------------------------------------------
# Command and environment
# ---------------------------------------------------------------------------

def resolve_cbmc_binary(binary: str) -> Optional[str]:
    # Absolute/path-like binary.
    if os.path.sep in binary or (os.path.altsep and os.path.altsep in binary):
        p = Path(binary).expanduser()
        if p.exists() and os.access(str(p), os.X_OK):
            return str(p.resolve())
        return None
    return shutil.which(binary)


def build_cbmc_command(cfg: ToolExecutionConfig, harness_path: Path, formal_build_plan: Mapping[str, Any]) -> List[str]:
    default_args = [
        "--bounds-check",
        "--pointer-check",
        "--memory-leak-check",
        "--div-by-zero-check",
        "--signed-overflow-check",
        "--unsigned-overflow-check",
        "--conversion-check",
        "--undefined-shift-check",
    ]
    cmd = build_cbmc_command_from_plan(
        cfg.cbmc_binary,
        formal_build_plan,
        default_checks=default_args,
        unwind_override=cfg.unwind,
        extra_args=(),
    )
    # CLI/config extras are appended only when not already present in the reviewed plan.
    for arg in cfg.extra_cbmc_args:
        if arg not in cmd:
            cmd.append(arg)
    return cmd


def capture_tool_version(binary_resolved: Optional[str], original_binary: str) -> JsonDict:
    """Capture a redacted version record for any formal tool binary."""
    if not binary_resolved:
        return {
            "available": False,
            "binary": original_binary,
            "version_output": None,
        }

    try:
        proc = subprocess.run(
            [binary_resolved, "--version"],
            capture_output=True,
            text=True,
            timeout=15,
        )
        return {
            "available": True,
            "binary": binary_resolved,
            "exit_code": proc.returncode,
            "version_output": (proc.stdout + proc.stderr).strip(),
        }
    except Exception as exc:
        return {
            "available": True,
            "binary": binary_resolved,
            "version_error": f"{type(exc).__name__}: {exc}",
        }


def environment_snapshot(cbmc_version: JsonDict) -> JsonDict:
    return {
        "schema_version": "tool_environment_snapshot.v1",
        "created_utc": utc_now_iso(),
        "platform": {
            "system": platform.system(),
            "release": platform.release(),
            "version": platform.version(),
            "machine": platform.machine(),
            "processor": platform.processor(),
            "python_version": platform.python_version(),
        },
        "cbmc": cbmc_version,
        "environment_variables_recorded": {
            "PATH": os.environ.get("PATH", ""),
        },
        "security_note": "No API keys or secrets are recorded by Agent 7.",
    }


# ---------------------------------------------------------------------------
# CBMC output parsing
# ---------------------------------------------------------------------------

def classify_cbmc_result(
    exit_code: Optional[int], stdout: str, stderr: str, *, skipped: bool = False,
    dry_run: bool = False, timeout: bool = False, unavailable: bool = False,
    analysis_only: bool = False, pipeline_setup_failed: bool = False,
) -> Tuple[str, str]:
    combined = (stdout + "\n" + stderr).lower()

    if analysis_only:
        return "analysis_only_no_formal_tool_claim", "Selected property family is analysis-only; Agent 7 intentionally produced no CBMC proof claim."
    if skipped:
        return "skipped_by_review_gate", "Tool execution was skipped because Agent 6 gate did not allow CBMC."
    if dry_run:
        return "dry_run_not_executed", "Dry run mode wrote command but did not execute CBMC."
    if unavailable:
        return "tool_unavailable", "CBMC binary was not found or not executable."
    if timeout:
        return "tool_timeout", "Formal-tool pipeline exceeded timeout."
    if pipeline_setup_failed:
        return "contract_build_or_instrumentation_failed", "goto-cc or goto-instrument failed before the authoritative CBMC step."

    if "verification successful" in combined:
        return "verification_successful", "CBMC reported VERIFICATION SUCCESSFUL."
    if "verification failed" in combined:
        return "verification_failed", "CBMC reported VERIFICATION FAILED."
    if exit_code == 0:
        return "tool_exit_zero_unknown_verification_text", "CBMC exited 0 but success text was not detected."
    if exit_code is not None:
        return "tool_error_or_nonzero_exit", f"CBMC exited with non-zero code {exit_code}."
    return "unknown", "No result classification available."


def parse_property_results(stdout: str, stderr: str) -> JsonDict:
    combined = stdout + "\n" + stderr
    lines = combined.splitlines()
    property_rows: List[JsonDict] = []

    # Common CBMC plain text forms:
    # [function.property] line ... SUCCESS/FAILURE
    # ** Results:
    # file.c function ... FAILURE
    prop_line_re = re.compile(r"(?P<name>[A-Za-z0-9_.$:/\-\[\]]+).*?\b(?P<status>SUCCESS|FAILURE|UNKNOWN)\b")
    violated_re = re.compile(r"Violated property:\s*(?P<prop>.*)", re.IGNORECASE)

    for idx, line in enumerate(lines, start=1):
        if "SUCCESS" in line or "FAILURE" in line or "UNKNOWN" in line:
            m = prop_line_re.search(line)
            if m:
                property_rows.append({
                    "line": idx,
                    "property": m.group("name"),
                    "status": m.group("status"),
                    "raw_text": line.strip(),
                })

        m2 = violated_re.search(line)
        if m2:
            property_rows.append({
                "line": idx,
                "property": m2.group("prop").strip() or "violated_property",
                "status": "FAILURE",
                "raw_text": line.strip(),
            })

    # De-duplicate by raw_text.
    seen = set()
    unique = []
    for row in property_rows:
        key = row.get("raw_text", "")
        if key not in seen:
            seen.add(key)
            unique.append(row)

    failed = [r for r in unique if r.get("status") == "FAILURE"]
    successful = [r for r in unique if r.get("status") == "SUCCESS"]

    return {
        "schema_version": "cbmc_property_results.v1",
        "property_result_count": len(unique),
        "failure_count": len(failed),
        "success_count": len(successful),
        "property_results": unique,
        "failed_properties": failed,
        "limitations": [
            "This parser is a best-effort summary of CBMC text output.",
            "The raw CBMC output remains the authoritative tool evidence.",
        ],
    }


def parse_trace_summary(stdout: str, stderr: str, *, max_lines: int = 300) -> JsonDict:
    combined_lines = (stdout + "\n" + stderr).splitlines()
    trace_keywords = ["Trace for", "Counterexample", "Violated property", "State ", "assignment", "function ", "FAILED"]
    selected = []
    for idx, line in enumerate(combined_lines, start=1):
        if any(k.lower() in line.lower() for k in trace_keywords):
            start = max(1, idx - 2)
            end = min(len(combined_lines), idx + 8)
            for j in range(start, end + 1):
                selected.append({
                    "line": j,
                    "text": combined_lines[j - 1],
                })
            selected.append({"line": None, "text": "[...]"})

    # De-duplicate ordered.
    out = []
    seen = set()
    for item in selected:
        key = (item["line"], item["text"])
        if key not in seen:
            seen.add(key)
            out.append(item)
        if len(out) >= max_lines:
            out.append({"line": None, "text": "[TRUNCATED_TRACE_SUMMARY]"})
            break

    return {
        "schema_version": "cbmc_trace_summary.v1",
        "selected_line_count": len(out),
        "trace_excerpt_lines": out,
        "limitations": [
            "This is a best-effort trace excerpt.",
            "The raw CBMC output is the authoritative trace record.",
        ],
    }


def map_failed_properties_to_harness(property_results: JsonDict, harness_path: Optional[Path]) -> JsonDict:
    harness_lines = []
    if harness_path and harness_path.exists():
        harness_lines = safe_read_text(harness_path).splitlines()

    failed = property_results.get("failed_properties", [])
    mappings = []

    for row in failed:
        raw = str(row.get("raw_text", ""))
        line_nums = re.findall(r"\bline\s+(\d+)\b|:(\d+):", raw)
        flat_nums = []
        for pair in line_nums:
            for x in pair:
                if x:
                    flat_nums.append(int(x))

        context = []
        for n in flat_nums[:3]:
            if 1 <= n <= len(harness_lines):
                for j in range(max(1, n - 2), min(len(harness_lines), n + 2) + 1):
                    context.append({"line": j, "text": harness_lines[j - 1]})

        mappings.append({
            "property": row.get("property"),
            "raw_text": raw,
            "candidate_harness_lines": flat_nums,
            "harness_context": context,
        })

    return {
        "schema_version": "failed_property_mapping.v1",
        "failed_property_count": len(failed),
        "mappings": mappings,
        "limitations": [
            "Mapping is best-effort and depends on CBMC text format.",
            "Use raw output for authoritative counterexample details.",
        ],
    }


# ---------------------------------------------------------------------------
# Execution
# ---------------------------------------------------------------------------

def execute_cbmc(cmd: List[str], *, cwd: Optional[Path], timeout_seconds: int) -> JsonDict:
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(cwd) if cwd else None,
            capture_output=True,
            text=True,
            timeout=timeout_seconds,
        )
        return {
            "executed": True,
            "timeout": False,
            "exit_code": proc.returncode,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
            "exception": None,
        }
    except subprocess.TimeoutExpired as exc:
        return {
            "executed": True,
            "timeout": True,
            "exit_code": None,
            "stdout": exc.stdout.decode("utf-8", errors="replace") if isinstance(exc.stdout, bytes) else (exc.stdout or ""),
            "stderr": exc.stderr.decode("utf-8", errors="replace") if isinstance(exc.stderr, bytes) else (exc.stderr or ""),
            "exception": f"TimeoutExpired: {exc}",
        }
    except Exception as exc:
        return {
            "executed": False,
            "timeout": False,
            "exit_code": None,
            "stdout": "",
            "stderr": "",
            "exception": f"{type(exc).__name__}: {exc}",
        }


def execute_tool_pipeline(
    steps: List[JsonDict], *, cwd: Optional[Path], timeout_seconds: int, output_dir: Path
) -> JsonDict:
    """Execute sequential formal-tool steps and preserve every model/result."""
    ensure_dir(output_dir)
    records: List[JsonDict] = []
    authoritative: Optional[JsonDict] = None
    setup_failed = False
    any_timeout = False
    for index, step in enumerate(steps, start=1):
        command = [str(x) for x in step.get("command", [])]
        input_model = Path(str(step["input_model"])).resolve() if step.get("input_model") else None
        input_record = {
            "path": str(input_model) if input_model else None,
            "exists": bool(input_model and input_model.is_file()),
            "sha256": sha256_file(input_model) if input_model and input_model.is_file() else None,
        }
        result = execute_cbmc(command, cwd=cwd, timeout_seconds=timeout_seconds)
        stdout_path = output_dir / f"{index:02d}_{step['step_id']}_stdout.txt"
        stderr_path = output_dir / f"{index:02d}_{step['step_id']}_stderr.txt"
        atomic_write_text(stdout_path, str(result.get("stdout") or ""))
        atomic_write_text(stderr_path, str(result.get("stderr") or ""))
        output_model = Path(str(step["output_model"])).resolve() if step.get("output_model") else None
        output_exists = bool(output_model and output_model.is_file())
        output_required_missing = bool(
            output_model and result.get("executed") and result.get("exit_code") == 0 and not output_exists
        )
        if output_required_missing:
            result = dict(result)
            result["exception"] = (
                (str(result.get("exception")) + "; ") if result.get("exception") else ""
            ) + f"Expected output GOTO model was not created: {output_model}"
        record = {
            "step_id": step.get("step_id"),
            "tool": step.get("tool"),
            "command": command,
            "executed": result.get("executed"),
            "exit_code": result.get("exit_code"),
            "timeout": result.get("timeout"),
            "exception": result.get("exception"),
            "stdout_path": str(stdout_path),
            "stderr_path": str(stderr_path),
            "input_model": input_record,
            "output_model": str(output_model) if output_model else None,
            "output_model_exists": output_exists,
            "output_model_sha256": sha256_file(output_model) if output_exists and output_model else None,
            "output_model_required_but_missing": output_required_missing,
            "authoritative_result_step": bool(step.get("authoritative_result_step")),
        }
        records.append(record)
        any_timeout = any_timeout or bool(result.get("timeout"))
        if step.get("authoritative_result_step"):
            authoritative = dict(result)
            authoritative["step_id"] = step.get("step_id")
        failed = (
            result.get("exit_code") not in (0, None)
            or result.get("timeout")
            or not result.get("executed")
            or output_required_missing
        )
        if failed:
            if not step.get("authoritative_result_step"):
                setup_failed = True
            if authoritative is None:
                authoritative = dict(result)
                authoritative["step_id"] = step.get("step_id")
            break
    if authoritative is None:
        authoritative = {
            "executed": False, "timeout": False, "exit_code": None,
            "stdout": "", "stderr": "", "exception": "No authoritative tool step executed."
        }
    return {
        "steps": records,
        "authoritative": authoritative,
        "pipeline_setup_failed": setup_failed,
        "timeout": any_timeout,
        "completed_step_count": len(records),
        "planned_step_count": len(steps),
        "all_planned_steps_completed": len(records) == len(steps) and not setup_failed,
    }


# ---------------------------------------------------------------------------
# Main runner
# ---------------------------------------------------------------------------

def run_agent7(config_data: JsonDict, cfg: ToolExecutionConfig) -> int:
    stage = "07_tool_execution"
    layout = RunLayout(cfg.run_dir, create=False, active_iteration=cfg.iteration)
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 7 Formal Tool Execution started.",
        data={
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
            "dry_run": cfg.dry_run,
            "force_run": cfg.force_run,
        },
    )

    stage_status: JsonDict = {
        "schema_version": "agent_status.v1",
        "stage": stage,
        "started_utc": utc_now_iso(),
        "completed_utc": None,
        "success": False,
        "tool_executed": False,
        "handoff_available": False,
        "errors": [],
        "warnings": [],
    }

    try:
        # --------------------------------------------------------------
        # 1. Load Agent 6 gate and harness.
        # --------------------------------------------------------------
        gate_path, gate_decision, gate_status = load_handoff_json(layout, "06_review_critic", "review_gate_decision")
        formal_build_plan_path, formal_build_plan, formal_build_plan_status = load_handoff_json(
            layout, "06_review_critic", "formal_build_plan"
        )
        reviewed_harness_path, reviewed_harness_status = load_handoff_path(
            layout, "06_review_critic", "generated_harness_under_review"
        )
        if cfg.artifact_path is not None:
            harness_path = cfg.artifact_path
            harness_status = {
                "producer_stage": "orchestrator_current_artifact",
                "output_key": "generated_harness_under_review",
                "available": cfg.artifact_path.is_file(),
                "path": str(cfg.artifact_path),
                "warning": None if cfg.artifact_path.is_file() else "Explicit artifact path is missing or is not a file.",
            }
            if reviewed_harness_path is not None and reviewed_harness_path.exists():
                if reviewed_harness_path.resolve() != cfg.artifact_path.resolve():
                    raise ValueError(
                        "Artifact-review binding violation: --artifact does not match "
                        "Agent 6 generated_harness_under_review. Review the selected artifact before CBMC execution."
                    )
        else:
            harness_path, harness_status = reviewed_harness_path, reviewed_harness_status

        if not gate_decision and not cfg.allow_missing_gate:
            raise FileNotFoundError(
                f"Agent 7 requires Agent 6 review_gate_decision unless --allow-missing-gate is used. Status: {gate_status}"
            )
        if not harness_path and not cfg.allow_missing_harness:
            raise FileNotFoundError(
                f"Agent 7 requires generated harness unless --allow-missing-harness is used. Status: {harness_status}"
            )

        if not formal_build_plan:
            raise FileNotFoundError(
                f"Agent 7 requires Agent 6 formal_build_plan. Status: {formal_build_plan_status}"
            )
        if not harness_path:
            raise FileNotFoundError("Cannot validate formal build plan without a selected harness.")
        build_binding_validation = validate_formal_build_plan(
            formal_build_plan,
            harness_path,
            expected_cbmc_function=cfg.cbmc_function,
            expected_target_function=cfg.target_function,
        )
        if not build_binding_validation.get("valid"):
            raise ValueError(
                "Formal-build binding violation: " + "; ".join(build_binding_validation.get("errors", []))
            )

        final_gate, tool_allowed, gate_reason = get_gate_value(gate_decision)
        gate_blocks_execution = cfg.require_gate_approval and not tool_allowed and not cfg.force_run

        if gate_blocks_execution:
            stage_status["warnings"].append(
                f"Tool execution blocked by Agent 6 gate: {final_gate}. Reason: {gate_reason}"
            )

        # --------------------------------------------------------------
        # 2. Resolve formal tools and build the direct or contract pipeline.
        # --------------------------------------------------------------
        execution_profile = formal_build_plan.get("execution_profile", {}) if isinstance(formal_build_plan.get("execution_profile"), dict) else {}
        execution_mode = str(execution_profile.get("mode") or "direct_cbmc")
        analysis_only = execution_mode == "analysis_only"

        if not harness_path:
            harness_path = layout.tool_inputs_dir(stage) / "missing_harness.c"

        plan_working_directory = Path(str(formal_build_plan.get("working_directory"))).resolve()
        effective_working_directory = cfg.working_directory or plan_working_directory
        pipeline_output_dir = layout.tool_outputs_dir(stage) / "tool_pipeline"
        pipeline_steps = build_tool_pipeline_from_plan(
            formal_build_plan,
            output_dir=pipeline_output_dir,
            cbmc_binary=cfg.cbmc_binary,
            goto_cc_binary=cfg.goto_cc_binary,
            goto_instrument_binary=cfg.goto_instrument_binary,
            default_checks=[
                "--bounds-check", "--pointer-check", "--memory-leak-check",
                "--div-by-zero-check", "--signed-overflow-check",
                "--unsigned-overflow-check", "--conversion-check",
                "--undefined-shift-check",
            ],
            unwind_override=cfg.unwind,
            extra_args=cfg.extra_cbmc_args,
        )

        resolved_tools: Dict[str, Optional[str]] = {}
        for step in pipeline_steps:
            command = [str(x) for x in step.get("command", [])]
            if not command:
                continue
            original = command[0]
            resolved = resolve_cbmc_binary(original)
            resolved_tools[original] = resolved
            if resolved:
                command[0] = resolved
                step["execution_command"] = command
            else:
                step["execution_command"] = [str(x) for x in step.get("command", [])]
        cbmc_resolved = resolved_tools.get(cfg.cbmc_binary) or resolve_cbmc_binary(cfg.cbmc_binary)
        cbmc_version = capture_tool_version(cbmc_resolved, cfg.cbmc_binary)
        tool_version_records = {
            original: capture_tool_version(resolved, original)
            for original, resolved in sorted(resolved_tools.items())
        }
        # Preserve an explicit CBMC record even if no command step was generated
        # (for example, a review-blocked or analysis-only campaign).
        tool_version_records.setdefault(cfg.cbmc_binary, cbmc_version)
        unavailable_tools = sorted({
            str(step.get("command", [""])[0])
            for step in pipeline_steps
            if step.get("command") and not resolved_tools.get(str(step.get("command", [""])[0]))
        })

        authoritative_step = next((step for step in reversed(pipeline_steps) if step.get("authoritative_result_step")), None)
        cmd_for_record = [str(x) for x in (authoritative_step or {}).get("command", [])]
        cmd = [str(x) for x in (authoritative_step or {}).get("execution_command", cmd_for_record)]
        command_text = " && ".join(
            " ".join(quote_arg(str(x)) for x in step.get("command", [])) for step in pipeline_steps
        ) if pipeline_steps else "ANALYSIS_ONLY_NO_FORMAL_TOOL_COMMAND"
        pipeline_setup_failed = False
        pipeline_execution: JsonDict = {"steps": [], "authoritative": {}}
        # --------------------------------------------------------------
        # 3. Write input/control manifests.
        # --------------------------------------------------------------
        env_snapshot = environment_snapshot(cbmc_version)
        env_snapshot["formal_tools"] = {
            "execution_mode": execution_mode,
            "resolved_tools": resolved_tools,
            "tool_versions": tool_version_records,
            "unavailable_tools": unavailable_tools,
        }

        harness_input_manifest = {
            "schema_version": "tool_input_harness_manifest.v1",
            "created_utc": utc_now_iso(),
            "harness_path": str(harness_path),
            "harness_exists": Path(harness_path).exists(),
            "harness_sha256": sha256_file(harness_path) if Path(harness_path).exists() else None,
            "source_stage": harness_status.get("producer_stage") or "06_review_critic.generated_harness_under_review",
            "iteration": cfg.iteration,
            "trust_boundary": "candidate_harness_for_tool_execution_not_verified_before_cbmc",
        }

        gate_input_record = {
            "schema_version": "tool_input_gate_record.v1",
            "created_utc": utc_now_iso(),
            "gate_path": str(gate_path) if gate_path else None,
            "gate_available": bool(gate_decision),
            "final_gate": final_gate,
            "tool_execution_allowed": tool_allowed,
            "gate_reason": gate_reason,
            "force_run": cfg.force_run,
            "dry_run": cfg.dry_run,
        }

        command_manifest = {
            "schema_version": "tool_command_manifest.v2.iteration_contract",
            "iteration": cfg.iteration,
            "created_utc": utc_now_iso(),
            "tool": "cbmc_contract_pipeline" if execution_mode == "goto_contract_pipeline" else ("analysis_only" if analysis_only else "cbmc"),
            "execution_mode": execution_mode,
            "verification_strategy": formal_build_plan.get("verification_strategy"),
            "original_binary": cfg.cbmc_binary,
            "resolved_binary": cbmc_resolved,
            "resolved_tools": resolved_tools,
            "tool_versions": tool_version_records,
            "unavailable_tools": unavailable_tools,
            "command": cmd_for_record,
            "command_text": command_text,
            "pipeline_step_count": len(pipeline_steps),
            "pipeline_setup_failed": pipeline_setup_failed,
            "execution_command": cmd,
            "pipeline_steps": pipeline_steps,
            "working_directory": str(effective_working_directory),
            "formal_build_plan_path": str(formal_build_plan_path),
            "formal_build_plan_validation": build_binding_validation,
            "source_units": formal_build_plan.get("source_units", []),
            "stub_units": formal_build_plan.get("stub_units", []),
            "include_paths": formal_build_plan.get("include_paths", []),
            "defines": formal_build_plan.get("defines", []),
            "timeout_seconds": cfg.timeout_seconds,
            "cbmc_function": cfg.cbmc_function,
            "unwind": cfg.unwind,
            "extra_cbmc_args": cfg.extra_cbmc_args,
            "gate": gate_input_record,
            "artifact_review_binding": {
                "reviewed_harness_path": str(reviewed_harness_path) if reviewed_harness_path else None,
                "executed_harness_path": str(harness_path),
                "paths_match": bool(
                    reviewed_harness_path
                    and harness_path
                    and reviewed_harness_path.resolve() == Path(harness_path).resolve()
                ),
            },
            "formal_claim_boundary": {
                "full_correctness_claimed": False,
                "fips_compliance_claimed": False,
                "cryptographic_security_claimed": False,
                "property_specific_tool_evidence_only": True,
            },
        }

        input_paths: Dict[str, Path] = {
            "harness_input_manifest": atomic_write_json(
                layout.tool_inputs_dir(stage) / "06_harness_input_manifest.json",
                harness_input_manifest,
            ),
            "critic_gate_decision_input": atomic_write_json(
                layout.tool_inputs_dir(stage) / "06_critic_gate_decision_input.json",
                gate_input_record,
            ),
            "tool_command_manifest": atomic_write_json(
                layout.tool_inputs_dir(stage) / "06_tool_command_manifest.json",
                command_manifest,
            ),
            "tool_environment_snapshot": atomic_write_json(
                layout.tool_inputs_dir(stage) / "06_tool_environment_snapshot.json",
                env_snapshot,
            ),
            "formal_build_plan_reference": atomic_write_json(
                layout.tool_inputs_dir(stage) / "06_formal_build_plan_reference.json",
                {
                    "schema_version": "formal_build_plan_reference.v1",
                    "path": str(formal_build_plan_path),
                    "validation": build_binding_validation,
                    "policy": "pointer_and_checksum_reference_no_duplicate_build_plan_copy",
                },
            ),
        }

        command_path = layout.tool_outputs_dir(stage) / "06_cbmc_command.txt"
        atomic_write_text(command_path, command_text + "\n")

        # --------------------------------------------------------------
        # 4. Decide execution mode and execute every reviewed step.
        # --------------------------------------------------------------
        skipped = False
        unavailable = False
        dry_run = False
        execution_result: JsonDict

        if analysis_only:
            execution_result = {
                "executed": False, "timeout": False, "exit_code": None,
                "stdout": "", "stderr": "",
                "exception": "Analysis-only property family: no formal-tool claim is permitted.",
            }
        elif gate_blocks_execution:
            skipped = True
            execution_result = {
                "executed": False, "timeout": False, "exit_code": None,
                "stdout": "", "stderr": "",
                "exception": "Skipped because review gate did not allow tool execution.",
            }
        elif cfg.dry_run:
            dry_run = True
            execution_result = {
                "executed": False, "timeout": False, "exit_code": None,
                "stdout": "", "stderr": "",
                "exception": "Dry run mode: formal-tool pipeline was not executed.",
            }
        elif unavailable_tools:
            unavailable = True
            execution_result = {
                "executed": False, "timeout": False, "exit_code": None,
                "stdout": "", "stderr": "",
                "exception": "Formal tool(s) not found or not executable: " + ", ".join(unavailable_tools),
            }
        else:
            executable_steps = []
            for step in pipeline_steps:
                copied = dict(step)
                copied["command"] = list(step.get("execution_command") or step.get("command") or [])
                executable_steps.append(copied)
            pipeline_execution = execute_tool_pipeline(
                executable_steps,
                cwd=effective_working_directory,
                timeout_seconds=cfg.timeout_seconds,
                output_dir=pipeline_output_dir,
            )
            execution_result = dict(pipeline_execution.get("authoritative") or {})
            pipeline_setup_failed = bool(pipeline_execution.get("pipeline_setup_failed"))

        command_manifest["pipeline_setup_failed"] = pipeline_setup_failed
        command_manifest["pipeline_execution_summary"] = {
            "planned_step_count": pipeline_execution.get("planned_step_count", len(pipeline_steps)),
            "completed_step_count": pipeline_execution.get("completed_step_count", 0),
            "all_planned_steps_completed": pipeline_execution.get("all_planned_steps_completed", False),
        }
        atomic_write_json(layout.tool_inputs_dir(stage) / "06_tool_command_manifest.json", command_manifest)

        stage_status["tool_executed"] = bool(execution_result.get("executed"))

        stdout = str(execution_result.get("stdout") or "")
        stderr = str(execution_result.get("stderr") or "")
        exit_code = execution_result.get("exit_code")
        timeout = bool(execution_result.get("timeout"))

        result_class, result_reason = classify_cbmc_result(
            exit_code,
            stdout,
            stderr,
            skipped=skipped,
            dry_run=dry_run,
            timeout=timeout,
            unavailable=unavailable,
            analysis_only=analysis_only,
            pipeline_setup_failed=pipeline_setup_failed,
        )
        # --------------------------------------------------------------
        # 5. Write raw outputs and parsed summaries.
        # --------------------------------------------------------------
        stdout_path = layout.tool_outputs_dir(stage) / "06_cbmc_output.txt"
        stderr_path = layout.tool_outputs_dir(stage) / "06_cbmc_stderr.txt"
        raw_json_path = layout.tool_outputs_dir(stage) / "06_cbmc_raw_execution.json"
        iteration_output_path = layout.tool_outputs_dir(stage) / f"cbmc_output_iteration_{cfg.iteration:02d}.txt"

        atomic_write_text(stdout_path, stdout)
        atomic_write_text(stderr_path, stderr)
        atomic_write_text(iteration_output_path, stdout + ("\n\n[STDERR]\n" + stderr if stderr else ""))

        atomic_write_json(raw_json_path, {
            "schema_version": "cbmc_raw_execution.v1",
            "created_utc": utc_now_iso(),
            "executed": execution_result.get("executed"),
            "timeout": timeout,
            "exit_code": exit_code,
            "exception": execution_result.get("exception"),
            "stdout_path": str(stdout_path),
            "stderr_path": str(stderr_path),
            "execution_mode": execution_mode,
            "pipeline_execution": pipeline_execution,
        })

        property_results = parse_property_results(stdout, stderr)
        trace_summary = parse_trace_summary(stdout, stderr)
        failed_mapping = map_failed_properties_to_harness(property_results, Path(harness_path) if harness_path else None)

        property_results_path = atomic_write_json(
            layout.tool_outputs_dir(stage) / "06_cbmc_property_results.json",
            property_results,
        )
        trace_summary_path = atomic_write_json(
            layout.tool_outputs_dir(stage) / "06_cbmc_trace_summary.json",
            trace_summary,
        )
        failed_mapping_path = atomic_write_json(
            layout.tool_outputs_dir(stage) / "06_failed_property_mapping.json",
            failed_mapping,
        )

        property_mapping_csv_path = write_csv(
            layout.tool_outputs_dir(stage) / "06_property_mapping.csv",
            property_results.get("property_results", []),
        )

        cbmc_status = {
            "schema_version": "cbmc_status.v1",
            "created_utc": utc_now_iso(),
            "stage": stage,
            "tool": "cbmc_contract_pipeline" if execution_mode == "goto_contract_pipeline" else ("analysis_only" if analysis_only else "cbmc"),
            "execution_mode": execution_mode,
            "verification_strategy": formal_build_plan.get("verification_strategy"),
            "tool_executed": bool(execution_result.get("executed")),
            "execution_skipped": skipped,
            "dry_run": dry_run,
            "tool_unavailable": unavailable,
            "timeout": timeout,
            "exit_code": exit_code,
            "result_classification": result_class,
            "result_reason": result_reason,
            "review_gate": {
                "final_gate": final_gate,
                "tool_execution_allowed": tool_allowed,
                "force_run": cfg.force_run,
                "gate_reason": gate_reason,
            },
            "command": cmd_for_record,
            "command_text": command_text,
            "harness_path": str(harness_path),
            "harness_sha256": sha256_file(harness_path) if Path(harness_path).exists() else None,
            "formal_claim_boundary": {
                "property_specific_tool_evidence_only": True,
                "full_correctness_claimed": False,
                "fips_compliance_claimed": False,
                "cryptographic_security_claimed": False,
                "mlkem_correctness_claimed": False,
                "general_semantic_non_vacuity_claimed": False,
            },
            "pre_execution_structural_validation": build_binding_validation,
            "limitations": [
                "CBMC evidence is specific to the generated harness, command-line options, assumptions, unwind bounds, and source context.",
                "A successful CBMC run does not establish full ML-KEM correctness or FIPS 203 compliance.",
                "A failed CBMC run may indicate a real bug, harness error, missing assumption, unsupported construct, or modelling issue.",
                "Raw CBMC output remains the authoritative tool evidence.",
                "The known Run 001 null-plus-freshness vacuity pattern is rejected structurally, but arbitrary assumption consistency is not thereby proved.",
            ],
        }

        cbmc_status_path = atomic_write_json(
            layout.tool_outputs_dir(stage) / "06_cbmc_status.json",
            cbmc_status,
        )

        diagnostics = {
            "schema_version": "tool_execution_diagnostics.v1",
            "created_utc": utc_now_iso(),
            "result_classification": result_class,
            "result_reason": result_reason,
            "cbmc_available": bool(cbmc_resolved),
            "gate_blocks_execution": gate_blocks_execution,
            "property_failure_count": property_results.get("failure_count"),
            "property_success_count": property_results.get("success_count"),
            "exception": execution_result.get("exception"),
            "stdout_chars": len(stdout),
            "stderr_chars": len(stderr),
            "diagnostic_recommendation": diagnostic_recommendation(result_class),
        }
        diagnostics_path = atomic_write_json(
            layout.diagnostics_dir(stage) / "06_cbmc_diagnostics.json",
            diagnostics,
        )

        tool_execution_md = build_tool_execution_markdown(cbmc_status, property_results, diagnostics)
        tool_execution_md_path = layout.tool_outputs_dir(stage) / "06_tool_execution.md"
        atomic_write_text(tool_execution_md_path, tool_execution_md)

        traceability = {
            "schema_version": "tool_execution_traceability.v1",
            "created_utc": utc_now_iso(),
            "inputs": {
                "review_gate_decision": str(gate_path) if gate_path else None,
                "generated_harness": str(harness_path),
                "command_manifest": str(input_paths["tool_command_manifest"]),
            },
            "outputs": {
                "cbmc_status": str(cbmc_status_path),
                "cbmc_stdout": str(stdout_path),
                "cbmc_stderr": str(stderr_path),
                "property_results": str(property_results_path),
                "trace_summary": str(trace_summary_path),
                "failed_property_mapping": str(failed_mapping_path),
            },
            "result_classification": result_class,
        }
        traceability_path = atomic_write_json(
            layout.tool_outputs_dir(stage) / "06_tool_execution_traceability.json",
            traceability,
        )

        # --------------------------------------------------------------
        # 6. Handoff manifest.
        # --------------------------------------------------------------
        handoff_outputs = {
            "cbmc_status": cbmc_status_path,
            "cbmc_output": stdout_path,
            "cbmc_stderr": stderr_path,
            "cbmc_command": command_path,
            "cbmc_property_results": property_results_path,
            "cbmc_trace_summary": trace_summary_path,
            "failed_property_mapping": failed_mapping_path,
            "tool_command_manifest": input_paths["tool_command_manifest"],
            "tool_environment_snapshot": input_paths["tool_environment_snapshot"],
            "tool_execution_traceability": traceability_path,
            "tool_execution_markdown": tool_execution_md_path,
            "cbmc_diagnostics": diagnostics_path,
        }

        layout.write_handoff_manifest(
            stage,
            outputs=handoff_outputs,
            authoritative_source="deterministic_formal_tool_execution",
            next_stage_consumers=[
                "08_counterexample_analysis",
                "09_repair_refinement",
                "10_experiment_logger",
                "11_evaluation_reporter",
            ],
            notes={
                "handoff_policy": (
                    "CBMC outputs are deterministic formal-tool evidence under the recorded command, "
                    "harness, assumptions, tool version, and execution environment."
                ),
                "tool_executed": bool(execution_result.get("executed")),
                "result_classification": result_class,
                "formal_truth_claimed": False,
                "full_correctness_claimed": False,
                "fips_compliance_claimed": False,
            },
        )
        stage_status["handoff_available"] = True
        stage_status["success"] = True

        # --------------------------------------------------------------
        # 7. Stage manifest.
        # --------------------------------------------------------------
        layout.write_stage_manifest(
            stage,
            primary_evidence_inputs=[
                str(p) for p in [gate_path, harness_path] if p is not None
            ],
            rendered_outputs={},
            tool_outputs=handoff_outputs,
            diagnostics_outputs={"cbmc_diagnostics": diagnostics_path},
            validation_outputs={},
            notes={
                "agent_version": "agent7_tool_execution_refactored.v2.iteration_contract",
                "iteration": cfg.iteration,
                "selected_harness_path": str(harness_path),
                "selected_harness_source": harness_status.get("producer_stage"),
                "stage_type": "deterministic_only",
                "llm_used": False,
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
                "result_classification": result_class,
                "tool_executed": bool(execution_result.get("executed")),
                "formal_truth_claimed": False,
            },
        )

        stage_status["completed_utc"] = utc_now_iso()
        atomic_write_json(layout.logs_dir(stage) / "07_tool_execution_status.json", stage_status)

        layout.log_event(
            event_type="stage_completed",
            stage=stage,
            message="Agent 7 Formal Tool Execution completed.",
            data={
                "success": stage_status["success"],
                "tool_executed": stage_status["tool_executed"],
                "result_classification": result_class,
                "exit_code": exit_code,
            },
        )

        # Exit code semantics:
        # 0 = agent completed and wrote handoff, regardless of CBMC verification success/failure.
        # CBMC result is stored in cbmc_status.json.
        return 0

    except Exception as exc:
        stage_status["completed_utc"] = utc_now_iso()
        stage_status["success"] = False
        stage_status["errors"].append({
            "type": type(exc).__name__,
            "message": str(exc),
            "traceback": traceback.format_exc(),
        })

        ensure_dir(layout.logs_dir(stage))
        atomic_write_json(layout.logs_dir(stage) / "07_tool_execution_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 7 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        try:
            layout.write_stage_manifest(
                stage,
                notes={
                    "agent_version": "agent7_tool_execution_refactored.v1",
                    "failed": True,
                    "error": f"{type(exc).__name__}: {exc}",
                },
            )
        except Exception:
            pass

        return 1


def quote_arg(arg: str) -> str:
    if re.search(r"\s", arg):
        return "'" + arg.replace("'", "'\"'\"'") + "'"
    return arg


def diagnostic_recommendation(result_class: str) -> str:
    if result_class == "verification_successful":
        return "Proceed to evaluation/reporting, while preserving assumption and scope limitations."
    if result_class == "verification_failed":
        return "Proceed to counterexample analysis and possible repair/refinement."
    if result_class == "skipped_by_review_gate":
        return "Return to review or repair before tool execution."
    if result_class == "tool_unavailable":
        return "Install/configure CBMC or record tool-unavailable limitation."
    if result_class == "dry_run_not_executed":
        return "Use real execution mode for formal-tool evidence."
    if result_class == "tool_timeout":
        return "Inspect harness, reduce complexity, tune unwinding/timeout, or repair."
    if result_class == "contract_build_or_instrumentation_failed":
        return "Inspect goto-cc/goto-instrument stderr, contract syntax, source-copy patches, and transformation options before any property conclusion."
    if result_class == "analysis_only_no_formal_tool_claim":
        return "Preserve the analysis-only boundary and use configured manual/external constant-time evidence; do not claim CBMC verification."
    return "Inspect raw output and diagnostics."


def build_tool_execution_markdown(cbmc_status: JsonDict, property_results: JsonDict, diagnostics: JsonDict) -> str:
    lines = [
        "# Agent 7 Tool Execution Summary",
        "",
        f"- Tool: `{cbmc_status.get('tool')}`",
        f"- Tool executed: `{cbmc_status.get('tool_executed')}`",
        f"- Result classification: `{cbmc_status.get('result_classification')}`",
        f"- Exit code: `{cbmc_status.get('exit_code')}`",
        f"- Review gate: `{cbmc_status.get('review_gate', {}).get('final_gate')}`",
        f"- Force run: `{cbmc_status.get('review_gate', {}).get('force_run')}`",
        "",
        "## Formal claim boundary",
        "",
        "This stage records property-specific CBMC tool evidence under the exact generated harness, command, assumptions, tool version, and environment. It does not claim full ML-KEM correctness, FIPS 203 compliance, cryptographic security, or whole-program correctness.",
        "",
        "## Property summary",
        "",
        f"- Parsed property results: `{property_results.get('property_result_count')}`",
        f"- Parsed failures: `{property_results.get('failure_count')}`",
        f"- Parsed successes: `{property_results.get('success_count')}`",
        "",
        "## Diagnostic recommendation",
        "",
        diagnostics.get("diagnostic_recommendation", ""),
        "",
    ]
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Agent 7 — deterministic Formal Tool Execution Agent")
    parser.add_argument("--config", help="Path to run config JSON.")
    parser.add_argument("--run-dir", help="Override run directory.")
    parser.add_argument("--target-function", help="Implementation function name, e.g. mlk_poly_add.")
    parser.add_argument("--target-topic", help="Human-readable target topic.")
    parser.add_argument("--cbmc-binary", help="CBMC binary path/name. Default: cbmc")
    parser.add_argument("--cbmc-function", help="CBMC entry function. Default: harness")
    parser.add_argument("--cbmc-arg", help="Extra CBMC arg(s), comma-separated. Can also be in config.")
    parser.add_argument("--unwind", type=int, help="CBMC unwind bound.")
    parser.add_argument("--timeout-seconds", type=int, help="CBMC timeout in seconds.")
    parser.add_argument("--working-directory", help="Working directory for CBMC execution.")
    parser.add_argument("--dry-run", action="store_true", help="Write command/manifests but do not execute CBMC.")
    parser.add_argument("--force-run", action="store_true", help="Run CBMC even if Agent 6 gate does not approve.")
    parser.add_argument("--allow-missing-gate", action="store_true", help="Allow missing Agent 6 gate only for wiring tests.")
    parser.add_argument("--allow-missing-harness", action="store_true", help="Allow missing harness only for wiring tests.")
    parser.add_argument("--iteration", type=int, default=0, help="Tool-execution iteration number (>= 0).")
    parser.add_argument("--artifact", help="Explicit harness path selected and reviewed for this iteration.")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    if args.iteration < 0:
        parser.error("--iteration must be >= 0")
    config_data, cfg = load_config(args)
    return run_agent7(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
