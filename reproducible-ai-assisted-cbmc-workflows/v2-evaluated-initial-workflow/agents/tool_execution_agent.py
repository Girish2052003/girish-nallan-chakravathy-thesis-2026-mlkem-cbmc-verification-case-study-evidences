#!/usr/bin/env python3
"""
Formal Tool Execution Agent v2 (Agent 7)
========================================

Purpose
-------
Runs CBMC, or prepares a dry-run CBMC command, for one candidate formal-
verification artifact produced by the workflow.

This v2 upgrade preserves the old Agent 7 pipeline contract while adding:
- critic-gate enforcement from Agent 6
- stronger reproducibility command manifest
- environment snapshot
- richer CBMC diagnostics and trace extraction
- property-result mapping back to candidate properties / critic issues
- safer handling of missing tools, missing artifacts, dry runs, and timeouts

Legacy outputs preserved
------------------------
- 06_cbmc_output.txt
- 06_cbmc_status.json
- 06_cbmc_command.txt
- 06_tool_execution.md
- 06_cbmc_property_results.json
- agent_status/06_tool_execution_status.json
- tool_outputs/cbmc_output_iteration_<N>.txt
- llm_prompts/06_tool_execution_instruction.txt

New v2 outputs
--------------
- 06_tool_command_manifest.json
- 06_tool_environment_snapshot.json
- 06_critic_gate_decision.json
- 06_cbmc_diagnostics.json
- 06_cbmc_trace_summary.json
- 06_failed_property_mapping.json
- 06_property_mapping.csv
- 06_tool_execution_traceability.json

Scientific guardrail
--------------------
This agent does not prove ML-KEM. It only runs or prepares a formal-tool check
for a selected candidate harness under recorded assumptions. A CBMC pass applies
only to the selected harness, selected properties, and stated assumptions.
Human review remains mandatory.
"""

from __future__ import annotations

import argparse
import csv
import dataclasses
import datetime as _dt
import hashlib
import json
import os
import platform
import re
import shlex
import shutil
import subprocess
import sys
import textwrap
import time
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

JsonDict = Dict[str, Any]

AGENT_NAME = "tool_execution_agent"
AGENT_NUMBER = 7
SCHEMA_VERSION = "2.0.0"
OUTPUT_PREFIX = "06"

SCIENTIFIC_GUARDRAIL = (
    "This result applies only to the selected candidate harness/properties "
    "under recorded assumptions. It is not a proof of the full ML-KEM "
    "implementation. Human review remains required."
)


# ---------------------------------------------------------------------------
# Small file/helpers layer
# ---------------------------------------------------------------------------


def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


def read_text(path: Path, default: str = "") -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return default
    except OSError as exc:
        return default if default else f"[READ_ERROR {type(exc).__name__}: {exc}]"


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


def read_json(path: Path, default: Optional[Any] = None) -> Any:
    if default is None:
        default = {}
    try:
        return json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        if isinstance(default, dict):
            return dict(default)
        if isinstance(default, list):
            return list(default)
        return default


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    tmp.replace(path)


def append_jsonl(path: Path, event: JsonDict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False) + "\n")


def sha256_file(path: Path) -> Optional[str]:
    if not path.exists() or not path.is_file():
        return None
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="replace")).hexdigest()


def file_record(path: Path) -> JsonDict:
    return {
        "path": str(path),
        "exists": path.exists(),
        "is_file": path.is_file() if path.exists() else False,
        "size_bytes": path.stat().st_size if path.exists() and path.is_file() else None,
        "sha256": sha256_file(path),
    }


def unique_preserve_order(items: Iterable[Any]) -> List[Any]:
    seen = set()
    out: List[Any] = []
    for item in items:
        key = json.dumps(item, sort_keys=True, default=str) if isinstance(item, (dict, list)) else str(item)
        if key in seen:
            continue
        seen.add(key)
        out.append(item)
    return out


def as_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def as_bool(value: Any, default: bool = False) -> bool:
    if isinstance(value, bool):
        return value
    if value is None:
        return default
    if isinstance(value, (int, float)):
        return bool(value)
    text = str(value).strip().lower()
    if text in {"1", "true", "yes", "y", "on"}:
        return True
    if text in {"0", "false", "no", "n", "off"}:
        return False
    return default


def flatten_text(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    try:
        return json.dumps(value, ensure_ascii=False, sort_keys=True)
    except Exception:
        return str(value)


def safe_get(obj: Any, *keys: Any, default: Any = None) -> Any:
    cur = obj
    for key in keys:
        if isinstance(cur, dict) and key in cur:
            cur = cur[key]
        elif isinstance(cur, list) and isinstance(key, int) and 0 <= key < len(cur):
            cur = cur[key]
        else:
            return default
    return cur


def compact_ws(text: Any) -> str:
    return re.sub(r"\s+", " ", str(text or "")).strip()


def token_set(text: Any) -> set[str]:
    return {t.lower() for t in re.findall(r"[A-Za-z_][A-Za-z0-9_]*|\d+", str(text or ""))}


def quote_cmd(command: Sequence[str]) -> str:
    return shlex.join([str(x) for x in command])


def write_csv(path: Path, rows: List[JsonDict], fieldnames: Optional[List[str]] = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if fieldnames is None:
        fieldnames = []
        for row in rows:
            for key in row:
                if key not in fieldnames:
                    fieldnames.append(key)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({key: flatten_text(row.get(key, "")) if isinstance(row.get(key), (dict, list)) else ("" if row.get(key) is None else str(row.get(key))) for key in fieldnames})


# ---------------------------------------------------------------------------
# CBMC parsing data structures
# ---------------------------------------------------------------------------


@dataclasses.dataclass
class PropertyResult:
    raw_line: str
    property_id: Optional[str]
    description: str
    status: str
    property_type: Optional[str] = None
    line_number: Optional[int] = None
    source: str = "cbmc_output"


@dataclasses.dataclass
class ParsedToolOutput:
    status: str
    verification_passed: bool
    counterexample_available: bool
    failed_property: Optional[str]
    failed_properties_count: int
    successful_properties_count: int
    unknown_properties_count: int
    property_results: List[PropertyResult]
    detected_errors: List[str]
    warnings: List[str]
    summary: str
    diagnostics: JsonDict
    trace_summary: JsonDict


# ---------------------------------------------------------------------------
# Agent class
# ---------------------------------------------------------------------------


class ToolExecutionAgentV2:
    """Runs CBMC and stores a reproducible formal-tool result."""

    CHECK_FLAG_MAP: Dict[str, str] = {
        "bounds_check": "--bounds-check",
        "pointer_check": "--pointer-check",
        "memory_leak_check": "--memory-leak-check",
        "signed_overflow_check": "--signed-overflow-check",
        "unsigned_overflow_check": "--unsigned-overflow-check",
        "div_by_zero_check": "--div-by-zero-check",
        "undefined_shift_check": "--undefined-shift-check",
        "conversion_check": "--conversion-check",
        "float_overflow_check": "--float-overflow-check",
        "nan_check": "--nan-check",
    }

    DEFAULT_CBMC_FLAGS: Dict[str, bool] = {
        "bounds_check": True,
        "pointer_check": True,
        "signed_overflow_check": True,
        "unsigned_overflow_check": True,
        "unwinding_assertions": True,
        "trace": True,
    }

    def __init__(
        self,
        config_path: Path,
        run_dir: Optional[Path] = None,
        iteration: int = 0,
        artifact: Optional[str] = None,
        dry_run: bool = False,
        force: bool = False,
        timeout_seconds: Optional[int] = None,
        ignore_critic_gate: bool = False,
    ) -> None:
        self.config_path = config_path.expanduser().resolve()
        self.project_root = self.infer_project_root(self.config_path)
        self.config = read_json(self.config_path, default={})

        # Prefer resolved config when available because it can contain current_artifact
        # after repair promotion and normalized run metadata.
        initial_run_dir = self.resolve_run_dir(run_dir)
        self.resolved_config_path = initial_run_dir / "run_config.resolved.json"
        self.resolved_config = read_json(self.resolved_config_path, default={})
        if isinstance(self.resolved_config, dict) and self.resolved_config:
            merged = dict(self.config)
            merged.update(self.resolved_config)
            self.config = merged

        self.run_dir = self.resolve_run_dir(run_dir)
        self.iteration = int(iteration)
        self.artifact_arg = artifact or self.config.get("current_artifact") or "04_generated_harness.c"
        self.dry_run = dry_run
        self.force = force
        self.timeout_seconds = timeout_seconds
        self.ignore_critic_gate = ignore_critic_gate

        # Legacy output paths.
        self.output_path = self.run_dir / "06_cbmc_output.txt"
        self.status_path = self.run_dir / "06_cbmc_status.json"
        self.command_path = self.run_dir / "06_cbmc_command.txt"
        self.md_path = self.run_dir / "06_tool_execution.md"
        self.property_results_path = self.run_dir / "06_cbmc_property_results.json"
        self.agent_status_path = self.run_dir / "agent_status" / "06_tool_execution_status.json"
        self.events_path = self.run_dir / "events.jsonl"
        self.tool_outputs_dir = self.run_dir / "tool_outputs"
        self.prompts_dir = self.run_dir / "llm_prompts"

        # v2 output paths.
        self.command_manifest_path = self.run_dir / "06_tool_command_manifest.json"
        self.environment_snapshot_path = self.run_dir / "06_tool_environment_snapshot.json"
        self.critic_gate_path = self.run_dir / "06_critic_gate_decision.json"
        self.diagnostics_path = self.run_dir / "06_cbmc_diagnostics.json"
        self.trace_summary_path = self.run_dir / "06_cbmc_trace_summary.json"
        self.failed_property_mapping_path = self.run_dir / "06_failed_property_mapping.json"
        self.property_mapping_csv_path = self.run_dir / "06_property_mapping.csv"
        self.traceability_path = self.run_dir / "06_tool_execution_traceability.json"

        # Context.
        self.manifest = self.load_manifest()
        self.critic_review = read_json(self.run_dir / "05_critic_review.json", default={})
        self.properties = read_json(self.run_dir / "03_candidate_properties.json", default={})
        self.code_summary = read_json(self.run_dir / "02_code_summary.json", default={})
        self.spec_summary = read_json(self.run_dir / "01_spec_summary.json", default={})
        self.agent5_assertion_plan = read_json(self.run_dir / "04_spec_grounded_assertion_plan.json", default={})
        self.agent5_grounding_report = read_json(self.run_dir / "04_spec_grounding_report.json", default={})
        self.agent6_grounding_review = read_json(self.run_dir / "05_spec_grounding_review.json", default={})

    # ------------------------------------------------------------------
    # Path/config resolution
    # ------------------------------------------------------------------

    @staticmethod
    def infer_project_root(config_path: Path) -> Path:
        if config_path.parent.name == "configs":
            return config_path.parent.parent.resolve()
        return Path.cwd().resolve()

    def resolve_project_path(self, maybe_path: Any) -> Path:
        p = Path(str(maybe_path)).expanduser()
        if p.is_absolute():
            return p.resolve()
        return (self.project_root / p).resolve()

    def resolve_run_dir(self, run_dir: Optional[Path]) -> Path:
        if run_dir is not None:
            p = Path(run_dir).expanduser()
            if p.is_absolute():
                return p.resolve()
            return (self.project_root / p).resolve()
        configured = self.config.get("run_dir") or safe_get(self.config, "paths", "run_dir")
        if configured:
            p = Path(str(configured)).expanduser()
            if p.is_absolute():
                return p.resolve()
            return (self.project_root / p).resolve()
        configured_root = self.config.get("output_root", "runs")
        run_id = self.config.get("run_id") or "run_001"
        return (self.project_root / str(configured_root) / str(run_id)).resolve()

    def resolve_artifact_path(self) -> Path:
        candidates: List[Path] = []
        if self.artifact_arg:
            p = Path(str(self.artifact_arg)).expanduser()
            if p.is_absolute():
                candidates.append(p.resolve())
            else:
                candidates.append((self.run_dir / p).resolve())
                candidates.append((self.project_root / p).resolve())
        # If no explicit artifact, prefer repaired artifact in later iterations.
        if self.iteration > 0:
            candidates.append((self.run_dir / "08_repaired_harness.c").resolve())
        candidates.append((self.run_dir / "04_generated_harness.c").resolve())
        candidates.append((self.run_dir / "08_repaired_harness.c").resolve())

        for p in candidates:
            if p.exists():
                return p.resolve()
        # Prefer run-directory version of artifact arg if missing.
        if self.artifact_arg:
            p = Path(str(self.artifact_arg)).expanduser()
            return p.resolve() if p.is_absolute() else (self.run_dir / p).resolve()
        return (self.run_dir / "04_generated_harness.c").resolve()

    def load_manifest(self) -> JsonDict:
        candidates = [
            self.run_dir / "04_artifact_manifest.json",
            self.run_dir / "04_generated_artifact_notes.json",
            self.run_dir / "artifact_manifest.json",
        ]
        for p in candidates:
            data = read_json(p, default={})
            if isinstance(data, dict) and data:
                data["_manifest_path"] = str(p)
                data["_manifest_sha256"] = sha256_file(p)
                return data
        return {}

    def log_event(self, event_type: str, payload: JsonDict, status: str = "info") -> None:
        append_jsonl(
            self.events_path,
            {
                "timestamp": utc_now(),
                "agent": AGENT_NAME,
                "agent_number": AGENT_NUMBER,
                "event_type": event_type,
                "status": status,
                **payload,
            },
        )

    # ------------------------------------------------------------------
    # Settings and critic gate
    # ------------------------------------------------------------------

    def tool_settings(self) -> JsonDict:
        settings = self.config.get("tool_execution_settings")
        return settings if isinstance(settings, dict) else {}

    def cbmc_settings(self) -> JsonDict:
        base: JsonDict = {}
        if isinstance(self.config.get("cbmc_settings"), dict):
            base.update(self.config.get("cbmc_settings") or {})
        tes = self.tool_settings()
        if isinstance(tes.get("cbmc_settings"), dict):
            base.update(tes.get("cbmc_settings") or {})
        for key in [
            "cbmc_binary", "function", "unwind", "object_bits", "bounds_check",
            "pointer_check", "memory_leak_check", "signed_overflow_check",
            "unsigned_overflow_check", "div_by_zero_check", "undefined_shift_check",
            "conversion_check", "float_overflow_check", "nan_check", "unwinding_assertions",
            "trace", "extra_args", "timeout_seconds", "execute", "include_dirs",
            "extra_source_files", "source_files", "prefer_manifest_command",
        ]:
            if key in tes:
                base[key] = tes[key]
        return base

    def critic_gate_decision(self) -> JsonDict:
        respect_gate = as_bool(self.tool_settings().get("respect_critic_gate"), default=True)
        if self.ignore_critic_gate:
            respect_gate = False
        if self.force:
            respect_gate = False

        critic_present = bool(self.critic_review)
        review_status = str(self.critic_review.get("review_status") or self.critic_review.get("status") or "missing")
        tool_allowed = self.critic_review.get("tool_execution_allowed")
        repair_before_tool = self.critic_review.get("repair_recommended_before_tool")
        issues = as_list(self.critic_review.get("issues"))
        high_or_critical = []
        for issue in issues:
            if not isinstance(issue, dict):
                continue
            if str(issue.get("severity", "")).lower() in {"high", "critical"}:
                high_or_critical.append(issue)

        reasons: List[str] = []
        should_block = False
        if not critic_present:
            reasons.append("05_critic_review.json not found or empty; tool execution is allowed but marked as lower-confidence.")
        else:
            reasons.append(f"Critic review status: {review_status}")
            if tool_allowed is False:
                should_block = True
                reasons.append("Critic explicitly set tool_execution_allowed=false.")
            if repair_before_tool is True:
                should_block = True
                reasons.append("Critic explicitly recommended repair before tool execution.")
            if review_status.lower() in {"reject", "needs_revision", "failed", "blocked"}:
                should_block = True
                reasons.append("Critic status indicates the artifact should be revised before tool execution.")
            if high_or_critical and self.tool_settings().get("block_on_high_critic_issues") is True:
                should_block = True
                reasons.append("High/critical critic issues exist and block_on_high_critic_issues=true.")

        effective_block = bool(should_block and respect_gate)
        decision = {
            "schema_version": "1.0",
            "created_at": utc_now(),
            "agent": AGENT_NAME,
            "critic_present": critic_present,
            "respect_critic_gate": respect_gate,
            "force_used": self.force,
            "ignore_critic_gate_used": self.ignore_critic_gate,
            "review_status": review_status,
            "tool_execution_allowed_from_critic": tool_allowed,
            "repair_recommended_before_tool": repair_before_tool,
            "high_or_critical_issue_count": len(high_or_critical),
            "should_block_without_override": should_block,
            "blocked": effective_block,
            "decision": "blocked_by_critic" if effective_block else "allowed_to_prepare_or_run_tool",
            "reasons": reasons,
            "guardrail": "Critic gating prevents running CBMC on artifacts that Agent 6 judged unsafe, unless --force or --ignore-critic-gate is used.",
        }
        return decision

    # ------------------------------------------------------------------
    # Command construction
    # ------------------------------------------------------------------

    def infer_harness_function(self, artifact_text: str) -> str:
        cbmc = self.cbmc_settings()
        configured = cbmc.get("function") or self.manifest.get("harness_function")
        if configured:
            return str(configured)
        patterns = [
            r"\bvoid\s+(harness_[A-Za-z_][A-Za-z0-9_]*)\s*\(",
            r"\bint\s+(harness_[A-Za-z_][A-Za-z0-9_]*)\s*\(",
            r"\bvoid\s+([A-Za-z_][A-Za-z0-9_]*harness[A-Za-z0-9_]*)\s*\(",
            r"\bint\s+([A-Za-z_][A-Za-z0-9_]*harness[A-Za-z0-9_]*)\s*\(",
        ]
        for pat in patterns:
            m = re.search(pat, artifact_text or "")
            if m:
                return m.group(1)
        target = str(self.config.get("target_function") or self.manifest.get("target_function") or "target")
        return f"harness_{target}"

    def values_from_manifest_input_files(self, keys: Sequence[str]) -> List[Any]:
        input_files = self.manifest.get("input_files") if isinstance(self.manifest.get("input_files"), dict) else {}
        out: List[Any] = []
        for key in keys:
            value = input_files.get(key)
            if isinstance(value, str):
                out.append(value)
            elif isinstance(value, list):
                out.extend(value)
        return out

    def source_files_from_config_and_manifest(self, artifact_path: Path) -> Tuple[List[Path], List[Path]]:
        raw_files: List[Any] = []
        raw_files.extend(self.values_from_manifest_input_files(["source_files", "code_files", "implementation_files"]))
        for key in ["source_file", "source_files", "code_file", "code_files"]:
            value = self.config.get(key)
            if isinstance(value, str):
                raw_files.append(value)
            elif isinstance(value, list):
                raw_files.extend(value)
        cbmc = self.cbmc_settings()
        for key in ["extra_source_files", "source_files"]:
            value = cbmc.get(key)
            if isinstance(value, str):
                raw_files.append(value)
            elif isinstance(value, list):
                raw_files.extend(value)

        existing: List[Path] = []
        missing: List[Path] = []
        for value in raw_files:
            p = Path(str(value)).expanduser()
            if not p.is_absolute():
                p = self.resolve_project_path(value)
            p = p.resolve()
            if p == artifact_path.resolve():
                continue
            if p.exists():
                existing.append(p)
            else:
                missing.append(p)
        return unique_preserve_order(existing), unique_preserve_order(missing)

    def header_include_dirs(self) -> List[Path]:
        raw_headers: List[Any] = []
        for key in ["header_files", "headers", "related_header_files"]:
            value = self.config.get(key)
            if isinstance(value, str):
                raw_headers.append(value)
            elif isinstance(value, list):
                raw_headers.extend(value)
        raw_headers.extend(self.values_from_manifest_input_files(["header_files", "headers"]))
        cbmc = self.cbmc_settings()
        include_dirs_raw = cbmc.get("include_dirs") or []
        if isinstance(include_dirs_raw, str):
            include_dirs_raw = [include_dirs_raw]

        dirs: List[Path] = []
        for value in raw_headers:
            p = Path(str(value)).expanduser()
            if not p.is_absolute():
                p = self.resolve_project_path(value)
            if p.parent.exists():
                dirs.append(p.parent.resolve())
        for value in include_dirs_raw:
            p = Path(str(value)).expanduser()
            if not p.is_absolute():
                p = self.resolve_project_path(value)
            if p.exists():
                dirs.append(p.resolve())
        return unique_preserve_order(dirs)

    def infer_unwind(self) -> Optional[Any]:
        cbmc = self.cbmc_settings()
        if cbmc.get("unwind") is not None:
            return cbmc.get("unwind")
        for candidate in [
            self.manifest.get("loop_bound_used"),
            self.manifest.get("recommended_unwind"),
            self.properties.get("recommended_unwind"),
            safe_get(self.code_summary, "cbmc_hints", "unwind_guess"),
        ]:
            if candidate not in (None, ""):
                return candidate
        # Extract simple numeric loop bounds from Agent 3 if available.
        loop_structure = as_list(self.code_summary.get("loop_structure"))
        best: Optional[int] = None
        for loop in loop_structure:
            if not isinstance(loop, dict):
                continue
            cond = str(loop.get("condition") or loop.get("raw") or "")
            m = re.search(r"<\s*(\d+)", cond)
            if m:
                best = max(best or 0, int(m.group(1)))
        return best

    def build_cbmc_command(self, artifact_path: Path, artifact_text: str) -> Tuple[List[str], JsonDict]:
        cbmc = self.cbmc_settings()
        binary = str(cbmc.get("cbmc_binary") or os.environ.get("CBMC", "cbmc"))
        harness_function = self.infer_harness_function(artifact_text)

        command: List[str] = [binary, str(artifact_path)]
        existing_source_files, missing_source_files = self.source_files_from_config_and_manifest(artifact_path)
        for p in existing_source_files:
            command.append(str(p))

        include_dirs = self.header_include_dirs()
        for d in include_dirs:
            command.extend(["-I", str(d)])

        command.extend(["--function", harness_function])

        for setting_name, flag in self.CHECK_FLAG_MAP.items():
            value = cbmc.get(setting_name, self.DEFAULT_CBMC_FLAGS.get(setting_name, False))
            if as_bool(value, default=False):
                command.append(flag)

        unwind = self.infer_unwind()
        if unwind is not None and str(unwind).strip() != "":
            command.extend(["--unwind", str(unwind)])

        if as_bool(cbmc.get("unwinding_assertions", self.DEFAULT_CBMC_FLAGS["unwinding_assertions"]), default=True):
            command.append("--unwinding-assertions")
        if as_bool(cbmc.get("trace", self.DEFAULT_CBMC_FLAGS["trace"]), default=True):
            command.append("--trace")
        if cbmc.get("object_bits") is not None:
            command.extend(["--object-bits", str(cbmc["object_bits"])])

        extra_args = cbmc.get("extra_args") or []
        if isinstance(extra_args, str):
            extra_args = shlex.split(extra_args)
        if isinstance(extra_args, list):
            command.extend(str(x) for x in extra_args)

        recommended_manifest_command = (
            self.manifest.get("recommended_cbmc_command")
            or self.manifest.get("cbmc_command")
            or safe_get(self.manifest, "recommended_commands", "cbmc")
        )
        meta = {
            "schema_version": "1.0",
            "created_at": utc_now(),
            "agent": AGENT_NAME,
            "cbmc_binary": binary,
            "harness_function": harness_function,
            "command": command,
            "command_shell": quote_cmd(command),
            "recommended_manifest_command_seen": recommended_manifest_command,
            "manifest_command_used_directly": False,
            "reason_manifest_command_not_used_directly": "The agent constructs argv safely instead of executing a manifest shell string directly.",
            "existing_source_files": [str(p) for p in existing_source_files],
            "missing_source_files": [str(p) for p in missing_source_files],
            "include_dirs": [str(p) for p in include_dirs],
            "settings_used": cbmc,
            "unwind_used": unwind,
            "checks_enabled": [flag for flag in command if flag.startswith("--")],
            "scientific_guardrail": SCIENTIFIC_GUARDRAIL,
        }
        return command, meta

    # ------------------------------------------------------------------
    # Environment snapshot
    # ------------------------------------------------------------------

    def run_version_command(self, command: List[str], timeout: int = 8) -> JsonDict:
        try:
            proc = subprocess.run(command, text=True, capture_output=True, timeout=timeout, check=False)
            return {
                "command": command,
                "returncode": proc.returncode,
                "stdout": (proc.stdout or "")[:4000],
                "stderr": (proc.stderr or "")[:4000],
            }
        except Exception as exc:
            return {"command": command, "error": f"{type(exc).__name__}: {exc}"}

    def build_environment_snapshot(self, artifact_path: Path, command_meta: JsonDict) -> JsonDict:
        cbmc_binary = str(command_meta.get("cbmc_binary") or "cbmc")
        cbmc_path = shutil.which(cbmc_binary)
        source_records = [file_record(Path(p)) for p in command_meta.get("existing_source_files", [])]
        missing_records = [file_record(Path(p)) for p in command_meta.get("missing_source_files", [])]
        include_records = [file_record(Path(p)) for p in command_meta.get("include_dirs", [])]
        snapshot = {
            "schema_version": "1.0",
            "created_at": utc_now(),
            "agent": AGENT_NAME,
            "python_version": sys.version,
            "platform": platform.platform(),
            "machine": platform.machine(),
            "processor": platform.processor(),
            "cwd": str(Path.cwd()),
            "project_root": str(self.project_root),
            "run_dir": str(self.run_dir),
            "config_file": file_record(self.config_path),
            "resolved_config_file": file_record(self.resolved_config_path),
            "artifact_file": file_record(artifact_path),
            "manifest_file": file_record(Path(self.manifest.get("_manifest_path", self.run_dir / "04_artifact_manifest.json"))),
            "critic_review_file": file_record(self.run_dir / "05_critic_review.json"),
            "source_files": source_records,
            "missing_source_files": missing_records,
            "include_dirs": include_records,
            "path_env_preview": os.environ.get("PATH", "")[:2000],
            "cbmc_binary": cbmc_binary,
            "cbmc_binary_path": cbmc_path,
            "cbmc_available": bool(cbmc_path),
            "cbmc_version": self.run_version_command([cbmc_binary, "--version"]) if cbmc_path else {"available": False, "reason": "not found in PATH"},
            "guardrail": SCIENTIFIC_GUARDRAIL,
        }
        return snapshot

    # ------------------------------------------------------------------
    # Tool output parsing
    # ------------------------------------------------------------------

    @staticmethod
    def classify_property_type(line: str) -> Optional[str]:
        lower = line.lower()
        if "pointer" in lower or "dereference" in lower or "null" in lower:
            return "pointer_safety"
        if "array" in lower or "bounds" in lower or "out of bounds" in lower or "buffer" in lower:
            return "bounds_safety"
        if "overflow" in lower:
            return "integer_overflow"
        if "unwind" in lower:
            return "loop_unwinding"
        if "assert" in lower or "assertion" in lower:
            return "assertion"
        if "memory" in lower or "leak" in lower:
            return "memory_safety"
        if "division" in lower or "divide" in lower:
            return "division_by_zero"
        if "shift" in lower:
            return "undefined_shift"
        if "conversion" in lower or "cast" in lower:
            return "conversion"
        return None

    def extract_trace_summary(self, raw_output: str) -> JsonDict:
        lines = raw_output.splitlines()
        trace_lines: List[JsonDict] = []
        assignments: List[JsonDict] = []
        violated: List[JsonDict] = []
        states: List[JsonDict] = []
        in_trace = False
        for idx, line in enumerate(lines, start=1):
            stripped = line.strip()
            lower = stripped.lower()
            if re.search(r"trace for|counterexample|violated property|state \d+", lower):
                in_trace = True
            if not in_trace:
                continue
            if len(trace_lines) < 200:
                trace_lines.append({"line": idx, "text": stripped[:500]})
            if re.search(r"violated property", lower):
                violated.append({"line": idx, "text": stripped[:500]})
            if re.match(r"^state\s+\d+", lower):
                states.append({"line": idx, "text": stripped[:500]})
            # Conservative assignment extraction from common CBMC traces.
            if len(assignments) < 120:
                m = re.match(r"^([A-Za-z_][A-Za-z0-9_\.\->\[\]]*)\s*=\s*(.+)$", stripped)
                if m and "SUCCESS" not in stripped and "FAILURE" not in stripped:
                    assignments.append({"line": idx, "variable": m.group(1), "value": m.group(2)[:300], "raw": stripped[:500]})
                m2 = re.match(r"^value\s*:\s*(.+)$", stripped, flags=re.I)
                if m2:
                    assignments.append({"line": idx, "variable": "value", "value": m2.group(1)[:300], "raw": stripped[:500]})
        return {
            "schema_version": "1.0",
            "created_at": utc_now(),
            "trace_detected": bool(trace_lines),
            "trace_line_count_captured": len(trace_lines),
            "state_count_captured": len(states),
            "assignment_count_captured": len(assignments),
            "violated_property_lines": violated[:30],
            "states_sample": states[:50],
            "assignments_sample": assignments[:80],
            "trace_lines_sample": trace_lines[:120],
            "note": "This is a conservative textual trace summary for repair guidance; raw CBMC output remains authoritative.",
        }

    def extract_errors_and_warnings(self, lines: List[str]) -> Tuple[List[str], List[str]]:
        error_patterns = [
            r"\bERROR:\s*(.+)", r"\bFailed to open\s+(.+)", r"\bfile .* not found\b",
            r"\bparse error\b.*", r"\bsyntax error\b.*", r"\bcompilation failed\b.*",
            r"\bPARSING ERROR\b.*", r"\bCONVERSION ERROR\b.*", r"\btypecheck\b.*error",
            r"\bundefined reference\b.*", r"\bno such file\b.*", r"\bCannot open\b.*",
        ]
        warning_patterns = [r"\bwarning[: ]", r"\bWARNING\b", r"\bunwinding assertion\b"]
        errors: List[str] = []
        warnings: List[str] = []
        for line in lines:
            for pat in error_patterns:
                if re.search(pat, line, flags=re.IGNORECASE):
                    errors.append(line.strip())
                    break
            for pat in warning_patterns:
                if re.search(pat, line, flags=re.IGNORECASE):
                    warnings.append(line.strip())
                    break
        return unique_preserve_order(errors), unique_preserve_order(warnings)

    def parse_tool_output(self, raw_output: str, returncode: Optional[int], timed_out: bool = False) -> ParsedToolOutput:
        text = raw_output or ""
        lines = text.splitlines()
        lower = text.lower()
        property_results: List[PropertyResult] = []

        for idx, line in enumerate(lines, start=1):
            stripped = line.strip()
            # CBMC common result line:
            # [foo.pointer_dereference.1] line 10 dereference failure: SUCCESS
            m = re.match(r"^\[([^\]]+)\]\s*(.*?):\s*(SUCCESS|FAILURE|UNKNOWN)\s*$", stripped, flags=re.IGNORECASE)
            if m:
                property_results.append(
                    PropertyResult(
                        raw_line=stripped,
                        property_id=m.group(1),
                        description=m.group(2).strip(),
                        status=m.group(3).upper(),
                        property_type=self.classify_property_type(stripped),
                        line_number=idx,
                    )
                )
                continue
            m2 = re.match(r"^Status:\s*(SUCCESS|FAILURE|UNKNOWN)\s*$", stripped, flags=re.IGNORECASE)
            if m2:
                property_results.append(
                    PropertyResult(
                        raw_line=stripped,
                        property_id=None,
                        description="CBMC status line",
                        status=m2.group(1).upper(),
                        property_type=None,
                        line_number=idx,
                    )
                )

        successful = sum(1 for p in property_results if p.status == "SUCCESS")
        failed = [p for p in property_results if p.status == "FAILURE"]
        unknown = sum(1 for p in property_results if p.status == "UNKNOWN")
        failed_property = failed[0].property_id if failed else None
        detected_errors, warnings = self.extract_errors_and_warnings(lines)
        trace_summary = self.extract_trace_summary(text)

        # Top-level classification.
        if timed_out:
            status = "timeout"
            verification_passed = False
            summary = "CBMC execution timed out."
        elif "verification successful" in lower:
            status = "passed"
            verification_passed = True
            summary = "CBMC reported VERIFICATION SUCCESSFUL for the selected harness/properties."
        elif "verification failed" in lower or failed or "violated property" in lower:
            status = "failed"
            verification_passed = False
            summary = "CBMC reported a verification failure or at least one failed property."
        elif detected_errors:
            status = "tool_error"
            verification_passed = False
            summary = "CBMC produced parsing/conversion/tool errors before a clean verification result."
        elif returncode not in (0, None):
            status = "tool_error_or_failure"
            verification_passed = False
            summary = "CBMC exited with non-zero return code, but output did not clearly classify pass/fail."
        elif property_results and not failed and unknown == 0:
            status = "passed"
            verification_passed = True
            summary = "CBMC property result lines contain no failures."
        elif property_results and unknown > 0:
            status = "unknown"
            verification_passed = False
            summary = "CBMC output contains UNKNOWN property result(s)."
        else:
            status = "unknown"
            verification_passed = False
            summary = "CBMC output did not contain a clear verification success/failure marker."

        counterexample_available = bool(
            failed or trace_summary.get("trace_detected") or "counterexample" in lower
            or "trace for" in lower or "violated property" in lower or "verification failed" in lower
        )

        diagnostics = self.build_diagnostics_from_text(
            raw_output=text,
            returncode=returncode,
            timed_out=timed_out,
            detected_errors=detected_errors,
            warnings=warnings,
            property_results=[dataclasses.asdict(p) for p in property_results],
            status=status,
        )

        return ParsedToolOutput(
            status=status,
            verification_passed=verification_passed,
            counterexample_available=counterexample_available,
            failed_property=failed_property,
            failed_properties_count=len(failed),
            successful_properties_count=successful,
            unknown_properties_count=unknown,
            property_results=property_results,
            detected_errors=detected_errors,
            warnings=warnings,
            summary=summary,
            diagnostics=diagnostics,
            trace_summary=trace_summary,
        )

    def build_diagnostics_from_text(
        self,
        *,
        raw_output: str,
        returncode: Optional[int],
        timed_out: bool,
        detected_errors: List[str],
        warnings: List[str],
        property_results: List[JsonDict],
        status: str,
    ) -> JsonDict:
        lower = raw_output.lower()
        categories: List[str] = []
        checks = [
            ("tool_timeout", ["timeout", "timed out"]),
            ("tool_or_parse_error", ["parse error", "syntax error", "conversion error", "failed to open", "no such file", "error:"]),
            ("pointer_failure", ["pointer", "dereference", "null pointer", "invalid pointer"]),
            ("bounds_failure", ["array bounds", "out of bounds", "object bounds", "buffer"]),
            ("integer_overflow_failure", ["overflow", "signed", "unsigned"]),
            ("unwinding_issue", ["unwind", "unwinding assertion"]),
            ("assertion_failure", ["assertion", "violated property"]),
        ]
        for category, needles in checks:
            if any(n in lower for n in needles):
                categories.append(category)
        if timed_out and "tool_timeout" not in categories:
            categories.append("tool_timeout")
        if detected_errors and "tool_or_parse_error" not in categories:
            categories.append("tool_or_parse_error")

        failed_types = sorted({str(p.get("property_type")) for p in property_results if p.get("status") == "FAILURE" and p.get("property_type")})
        return {
            "schema_version": "1.0",
            "created_at": utc_now(),
            "status": status,
            "returncode": returncode,
            "timed_out": timed_out,
            "category_guess": categories or ["none_or_unknown"],
            "failed_property_types": failed_types,
            "detected_error_count": len(detected_errors),
            "warning_count": len(warnings),
            "property_result_count": len(property_results),
            "failed_property_count": sum(1 for p in property_results if p.get("status") == "FAILURE"),
            "successful_property_count": sum(1 for p in property_results if p.get("status") == "SUCCESS"),
            "unknown_property_count": sum(1 for p in property_results if p.get("status") == "UNKNOWN"),
            "detected_errors_sample": detected_errors[:20],
            "warnings_sample": warnings[:20],
            "guardrail": "Diagnostics classify the tool output only. They do not classify the full implementation as correct or incorrect.",
        }

    # ------------------------------------------------------------------
    # Mapping and traceability
    # ------------------------------------------------------------------

    def candidate_properties(self) -> List[JsonDict]:
        candidates: List[JsonDict] = []
        for key in ["candidate_properties", "properties", "selected_properties"]:
            value = self.properties.get(key)
            if isinstance(value, list):
                candidates.extend(x for x in value if isinstance(x, dict))
        nested = safe_get(self.properties, "cbmc_property_plan", "selected_properties", default=[])
        if isinstance(nested, list):
            candidates.extend(x for x in nested if isinstance(x, dict))
        return unique_preserve_order(candidates)

    def selected_manifest_properties(self) -> List[JsonDict]:
        selected: List[JsonDict] = []
        for key in ["selected_properties_used", "selected_properties", "properties_covered"]:
            value = self.manifest.get(key)
            if isinstance(value, list):
                selected.extend(x for x in value if isinstance(x, dict))
        return unique_preserve_order(selected)

    def map_property_results(self, property_results: List[JsonDict]) -> Tuple[JsonDict, List[JsonDict]]:
        candidates = self.candidate_properties()
        manifest_selected = self.selected_manifest_properties()
        all_known = unique_preserve_order(candidates + manifest_selected)
        critic_issues = [x for x in as_list(self.critic_review.get("issues")) if isinstance(x, dict)]

        rows: List[JsonDict] = []
        for pr in property_results:
            pid = str(pr.get("property_id") or "")
            desc = str(pr.get("description") or pr.get("raw_line") or "")
            result_tokens = token_set(pid + " " + desc + " " + str(pr.get("property_type") or ""))
            best_prop: Optional[JsonDict] = None
            best_score = 0.0
            for prop in all_known:
                prop_text = flatten_text(prop)
                prop_tokens = token_set(prop_text)
                if not prop_tokens or not result_tokens:
                    continue
                score = len(result_tokens & prop_tokens) / max(1, min(len(result_tokens), len(prop_tokens)))
                # ID substring match is strong.
                prop_id = str(prop.get("id") or prop.get("property_id") or "")
                if prop_id and prop_id.lower() in (pid + " " + desc).lower():
                    score += 0.6
                if score > best_score:
                    best_score = score
                    best_prop = prop

            related_critic: List[JsonDict] = []
            for issue in critic_issues:
                issue_text = flatten_text(issue)
                overlap = len(result_tokens & token_set(issue_text))
                if overlap >= 2 or (pid and pid.lower() in issue_text.lower()):
                    related_critic.append({
                        "severity": issue.get("severity"),
                        "type": issue.get("type"),
                        "message": str(issue.get("message") or issue.get("description") or "")[:300],
                    })

            row = {
                "cbmc_property_id": pid or None,
                "cbmc_status": pr.get("status"),
                "cbmc_property_type": pr.get("property_type"),
                "cbmc_description": desc,
                "matched_candidate_property_id": (best_prop or {}).get("id") or (best_prop or {}).get("property_id"),
                "matched_candidate_property_type": (best_prop or {}).get("type"),
                "match_score": round(best_score, 3),
                "mapping_status": "matched_candidate" if best_prop and best_score >= 0.25 else "unmapped_or_builtin_cbmc_check",
                "related_critic_issue_count": len(related_critic),
                "related_critic_issues": related_critic[:5],
            }
            rows.append(row)

        mapping = {
            "schema_version": "1.0",
            "created_at": utc_now(),
            "agent": AGENT_NAME,
            "known_candidate_property_count": len(candidates),
            "manifest_selected_property_count": len(manifest_selected),
            "cbmc_property_result_count": len(property_results),
            "mappings": rows,
            "note": "Mapping is heuristic. CBMC built-in checks may not directly correspond to Agent 4 candidate property IDs.",
        }
        return mapping, rows

    def build_traceability_report(self, status: JsonDict, mapping: JsonDict, gate: JsonDict, command_meta: JsonDict) -> JsonDict:
        return {
            "schema_version": "1.0",
            "created_at": utc_now(),
            "agent": AGENT_NAME,
            "iteration": self.iteration,
            "flow": [
                {"stage": "Agent 5", "file": "04_artifact_manifest.json", "used": bool(self.manifest), "purpose": "candidate harness and CBMC command hints"},
                {"stage": "Agent 6", "file": "05_critic_review.json", "used": bool(self.critic_review), "purpose": "critic gate and pre-tool warnings"},
                {"stage": "Agent 7", "file": "06_cbmc_command.txt", "used": True, "purpose": "recorded command"},
                {"stage": "Agent 7", "file": "06_cbmc_output.txt", "used": True, "purpose": "raw formal-tool output"},
                {"stage": "Agent 7", "file": "06_cbmc_status.json", "used": True, "purpose": "machine-readable tool result"},
                {"stage": "Agent 8", "file": "07_counterexample_analysis.json", "used_next_if": "status is not passed", "purpose": "explain non-pass result"},
            ],
            "artifact": status.get("artifact_file"),
            "artifact_sha256": status.get("artifact_sha256"),
            "command_shell": status.get("command_shell"),
            "critic_gate_decision": gate.get("decision"),
            "critic_gate_blocked": gate.get("blocked"),
            "tool_status": status.get("status"),
            "verification_passed": status.get("verification_passed"),
            "counterexample_available": status.get("counterexample_available"),
            "property_mapping_summary": {
                "mapping_count": len(mapping.get("mappings", [])),
                "matched_count": sum(1 for m in mapping.get("mappings", []) if m.get("mapping_status") == "matched_candidate"),
            },
            "command_manifest_file": str(self.command_manifest_path),
            "environment_snapshot_file": str(self.environment_snapshot_path),
            "diagnostics_file": str(self.diagnostics_path),
            "trace_summary_file": str(self.trace_summary_path),
            "failed_property_mapping_file": str(self.failed_property_mapping_path),
            "guardrail": SCIENTIFIC_GUARDRAIL,
        }

    # ------------------------------------------------------------------
    # Execution and output rendering
    # ------------------------------------------------------------------

    def execute_command(self, command: List[str], timeout_seconds: int) -> Tuple[str, Optional[int], bool, Optional[str], float]:
        started = time.monotonic()
        try:
            proc = subprocess.run(
                command,
                cwd=str(self.project_root),
                text=True,
                capture_output=True,
                timeout=timeout_seconds,
                check=False,
            )
            duration = time.monotonic() - started
            combined = ""
            if proc.stdout:
                combined += proc.stdout
            if proc.stderr:
                if combined and not combined.endswith("\n"):
                    combined += "\n"
                combined += "\n--- STDERR ---\n" + proc.stderr
            return combined, proc.returncode, False, None, duration
        except subprocess.TimeoutExpired as e:
            duration = time.monotonic() - started
            combined = ""
            if e.stdout:
                combined += e.stdout if isinstance(e.stdout, str) else e.stdout.decode("utf-8", errors="replace")
            if e.stderr:
                stderr = e.stderr if isinstance(e.stderr, str) else e.stderr.decode("utf-8", errors="replace")
                if combined and not combined.endswith("\n"):
                    combined += "\n"
                combined += "\n--- STDERR ---\n" + stderr
            combined += f"\n\n[TIMEOUT] CBMC command exceeded {timeout_seconds} seconds.\n"
            return combined, None, True, f"Timeout after {timeout_seconds} seconds", duration
        except OSError as e:
            duration = time.monotonic() - started
            return f"[OS ERROR] Could not execute command: {e}\n", None, False, str(e), duration

    def render_prompt_record(self, artifact_path: Path, command: List[str], gate: JsonDict) -> str:
        return textwrap.dedent(
            f"""
            Agent 7 v2 Formal Tool Execution Instruction
            ===========================================

            Task:
            Run or prepare the formal verification tool for the current candidate artifact.

            Tool:
            CBMC

            Artifact:
            {artifact_path}

            Shell command:
            {quote_cmd(command)}

            Critic gate:
            {json.dumps(gate, indent=2, ensure_ascii=False)}

            Scientific guardrails:
            - Treat the harness as a candidate formal-verification artifact.
            - Treat CBMC as the formal checker for the selected harness/property only.
            - Do not claim full ML-KEM verification from this run.
            - Save stdout, stderr, command, status, property results, environment snapshot, and traceability.
            - If the critic blocks tool execution, do not run CBMC unless --force or --ignore-critic-gate is used.
            """
        ).strip() + "\n"

    def render_markdown(self, status: JsonDict, gate: JsonDict, diagnostics: JsonDict, mapping: JsonDict) -> str:
        lines = [
            "# Agent 7 v2 — Formal Tool Execution Report",
            "",
            f"- **Created at:** {status.get('created_at')}",
            f"- **Tool:** {status.get('tool')}",
            f"- **Target function:** `{status.get('target_function')}`",
            f"- **Harness function:** `{status.get('harness_function')}`",
            f"- **Artifact:** `{status.get('artifact_file')}`",
            f"- **Iteration:** {status.get('iteration')}",
            f"- **Status:** `{status.get('status')}`",
            f"- **Execution status:** `{status.get('execution_status')}`",
            f"- **Runtime seconds:** {status.get('runtime_seconds')}",
            f"- **Counterexample available:** {status.get('counterexample_available')}",
            "",
            "## Critic Gate",
            "",
            f"- Decision: `{gate.get('decision')}`",
            f"- Blocked: `{gate.get('blocked')}`",
            f"- Force used: `{gate.get('force_used')}`",
        ]
        for reason in gate.get("reasons", []):
            lines.append(f"- {reason}")
        lines.extend([
            "",
            "## Command",
            "",
            "```bash",
            str(status.get("command_shell") or ""),
            "```",
            "",
            "## Tool Result Summary",
            "",
            str(status.get("summary") or "No summary available."),
            "",
        ])
        if status.get("failed_property"):
            lines.extend(["## First Failed Property", "", f"`{status.get('failed_property')}`", ""])

        if status.get("detected_errors"):
            lines.extend(["## Detected Tool/Parsing Errors", ""])
            for e in as_list(status.get("detected_errors"))[:30]:
                lines.append(f"- {e}")
            lines.append("")
        if status.get("warnings"):
            lines.extend(["## Warnings", ""])
            for w in as_list(status.get("warnings"))[:30]:
                lines.append(f"- {w}")
            lines.append("")

        lines.extend([
            "## Diagnostics",
            "",
            f"- Category guess: `{diagnostics.get('category_guess')}`",
            f"- Failed property types: `{diagnostics.get('failed_property_types')}`",
            f"- Property results: `{diagnostics.get('property_result_count')}`",
            "",
            "## Property Mapping",
            "",
            f"- CBMC property result count: `{mapping.get('cbmc_property_result_count')}`",
            f"- Known candidate property count: `{mapping.get('known_candidate_property_count')}`",
            f"- Matched mappings: `{sum(1 for m in mapping.get('mappings', []) if m.get('mapping_status') == 'matched_candidate')}`",
            "",
            "## Scientific Guardrail",
            "",
            SCIENTIFIC_GUARDRAIL,
            "",
            "## Output Files",
            "",
            "- `06_cbmc_output.txt`",
            "- `06_cbmc_status.json`",
            "- `06_cbmc_command.txt`",
            "- `06_tool_execution.md`",
            "- `06_cbmc_property_results.json`",
            "- `06_tool_command_manifest.json`",
            "- `06_tool_environment_snapshot.json`",
            "- `06_critic_gate_decision.json`",
            "- `06_cbmc_diagnostics.json`",
            "- `06_cbmc_trace_summary.json`",
            "- `06_failed_property_mapping.json`",
            "- `06_property_mapping.csv`",
            "- `06_tool_execution_traceability.json`",
            "",
        ])
        return "\n".join(lines)

    def determine_timeout(self, cbmc: JsonDict) -> int:
        if self.timeout_seconds is not None:
            timeout = int(self.timeout_seconds)
        elif cbmc.get("timeout_seconds") is not None:
            timeout = int(cbmc.get("timeout_seconds"))
        else:
            timeout = int(self.tool_settings().get("timeout_seconds", 600))
        return timeout if timeout > 0 else 600

    def base_status(self, artifact_path: Path, command: List[str], command_meta: JsonDict, environment: JsonDict, timeout_seconds: int, notes: List[str]) -> JsonDict:
        return {
            "schema_version": SCHEMA_VERSION,
            "agent": AGENT_NAME,
            "agent_number": AGENT_NUMBER,
            "created_at": utc_now(),
            "iteration": self.iteration,
            "target_scheme": self.config.get("target_scheme"),
            "target_function": self.config.get("target_function") or self.manifest.get("target_function"),
            "tool": "CBMC",
            "verification_tool": self.config.get("verification_tool", "CBMC"),
            "artifact_type": self.config.get("artifact_type"),
            "artifact_file": str(artifact_path),
            "artifact_exists": artifact_path.exists(),
            "artifact_sha256": sha256_file(artifact_path),
            "harness_function": command_meta.get("harness_function"),
            "command": command,
            "command_shell": quote_cmd(command),
            "command_file": str(self.command_path),
            "cbmc_binary": command_meta.get("cbmc_binary"),
            "cbmc_binary_path": environment.get("cbmc_binary_path"),
            "cbmc_available": environment.get("cbmc_available"),
            "project_root": str(self.project_root),
            "run_dir": str(self.run_dir),
            "existing_source_files": command_meta.get("existing_source_files", []),
            "missing_source_files": command_meta.get("missing_source_files", []),
            "include_dirs": command_meta.get("include_dirs", []),
            "timeout_seconds": timeout_seconds,
            "notes": notes,
            "scientific_guardrails": {
                "candidate_artifact_only": True,
                "formal_tool_checks_selected_harness_only": True,
                "human_review_required": True,
                "do_not_claim_full_mlkem_proof": True,
                "log_failures_honestly": True,
            },
        }

    def run(self) -> int:
        self.run_dir.mkdir(parents=True, exist_ok=True)
        self.tool_outputs_dir.mkdir(parents=True, exist_ok=True)
        self.prompts_dir.mkdir(parents=True, exist_ok=True)
        (self.run_dir / "agent_status").mkdir(parents=True, exist_ok=True)

        self.log_event("agent_start", {"iteration": self.iteration, "artifact_arg": str(self.artifact_arg)}, status="started")

        artifact_path = self.resolve_artifact_path()
        artifact_text = read_text(artifact_path, default="")
        command, command_meta = self.build_cbmc_command(artifact_path, artifact_text)
        gate = self.critic_gate_decision()
        environment = self.build_environment_snapshot(artifact_path, command_meta)
        cbmc = self.cbmc_settings()
        timeout_seconds = self.determine_timeout(cbmc)
        execute_enabled = as_bool(cbmc.get("execute", True), default=True)

        notes: List[str] = [SCIENTIFIC_GUARDRAIL]
        if self.critic_review:
            notes.append(f"Critic review status before tool execution: {gate.get('review_status')}")
        else:
            notes.append("Critic review was not found; execution is allowed but lower confidence.")
        if command_meta.get("missing_source_files"):
            notes.append("Some configured source files are missing; CBMC may fail unless the harness is self-contained.")
        if gate.get("blocked"):
            notes.append("Critic gate blocked CBMC execution. Use --force only after conscious human decision.")

        write_text(self.command_path, quote_cmd(command) + "\n")
        write_text(self.prompts_dir / "06_tool_execution_instruction.txt", self.render_prompt_record(artifact_path, command, gate))
        write_json(self.command_manifest_path, command_meta)
        write_json(self.environment_snapshot_path, environment)
        write_json(self.critic_gate_path, gate)

        base = self.base_status(artifact_path, command, command_meta, environment, timeout_seconds, notes)

        raw_output = ""
        returncode: Optional[int] = None
        timed_out = False
        runtime_seconds = 0.0
        execution_error: Optional[str] = None

        if gate.get("blocked"):
            raw_output = textwrap.dedent(
                f"""
                [CRITIC GATE BLOCKED]
                Agent 6 / Critic Review blocked formal-tool execution.

                Decision: {gate.get('decision')}
                Reasons:
                {chr(10).join('- ' + str(r) for r in gate.get('reasons', []))}

                Command that would have been executed:
                {quote_cmd(command)}

                This is not a CBMC failure and not a proof result. It means the candidate artifact should be repaired/reviewed before tool execution, unless --force is deliberately used.
                """
            ).strip() + "\n"
            parsed = self.parse_tool_output(raw_output, returncode=None)
            status = {
                **base,
                "execution_status": "blocked_by_critic_gate",
                "status": "critic_blocked",
                "result": "critic_blocked",
                "verification_passed": False,
                "counterexample_available": False,
                "returncode": None,
                "runtime_seconds": runtime_seconds,
                "summary": "Formal tool execution was blocked by Agent 6 critic gate before running CBMC.",
                "failed_property": None,
                "failed_properties_count": 0,
                "successful_properties_count": 0,
                "unknown_properties_count": 0,
                "property_results": [],
                "detected_errors": [],
                "warnings": parsed.warnings,
                "execution_error": None,
                "next_required_agent": "repair_agent",
            }
        elif not artifact_path.exists():
            raw_output = f"[TOOL EXECUTION AGENT] Artifact file not found: {artifact_path}\n"
            parsed = self.parse_tool_output(raw_output, returncode=None)
            status = {
                **base,
                "execution_status": "artifact_missing",
                "status": "artifact_missing",
                "result": "artifact_missing",
                "verification_passed": False,
                "counterexample_available": False,
                "returncode": None,
                "runtime_seconds": runtime_seconds,
                "summary": raw_output.strip(),
                "failed_property": None,
                "failed_properties_count": 0,
                "successful_properties_count": 0,
                "unknown_properties_count": 0,
                "property_results": [],
                "detected_errors": [raw_output.strip()],
                "warnings": [],
                "execution_error": None,
                "next_required_agent": "repair_agent_or_human_fix",
            }
        elif self.dry_run or not execute_enabled:
            raw_output = (
                "[DRY RUN] CBMC was not executed. Command was constructed and logged.\n\n"
                f"Command:\n{quote_cmd(command)}\n"
            )
            parsed = self.parse_tool_output(raw_output, returncode=None)
            status = {
                **base,
                "execution_status": "dry_run_not_executed",
                "status": "dry_run",
                "result": "dry_run",
                "verification_passed": False,
                "counterexample_available": False,
                "returncode": None,
                "runtime_seconds": runtime_seconds,
                "summary": "Dry run only. CBMC command was generated but not executed.",
                "failed_property": None,
                "failed_properties_count": 0,
                "successful_properties_count": 0,
                "unknown_properties_count": 0,
                "property_results": [],
                "detected_errors": [],
                "warnings": parsed.warnings,
                "execution_error": None,
                "next_required_agent": "formal_tool_execution_when_ready",
            }
        elif not environment.get("cbmc_available"):
            raw_output = textwrap.dedent(
                f"""
                [TOOL UNAVAILABLE]
                CBMC binary was not found in PATH.

                Requested binary: {command_meta.get('cbmc_binary')}
                Project root: {self.project_root}

                Command that would have been executed:
                {quote_cmd(command)}

                This is not a proof failure and not an implementation bug.
                It means the formal tool is not installed or not visible to this shell.
                """
            ).strip() + "\n"
            parsed = self.parse_tool_output(raw_output, returncode=None)
            status = {
                **base,
                "execution_status": "tool_unavailable",
                "status": "tool_unavailable",
                "result": "tool_unavailable",
                "verification_passed": False,
                "counterexample_available": False,
                "returncode": None,
                "runtime_seconds": runtime_seconds,
                "summary": "CBMC binary was not found in PATH. The command was logged but not executed.",
                "failed_property": None,
                "failed_properties_count": 0,
                "successful_properties_count": 0,
                "unknown_properties_count": 0,
                "property_results": [],
                "detected_errors": ["CBMC binary not found in PATH"],
                "warnings": parsed.warnings,
                "execution_error": None,
                "next_required_agent": "install_or_configure_cbmc_then_rerun",
            }
        else:
            raw_output, returncode, timed_out, execution_error, runtime_seconds = self.execute_command(command, timeout_seconds)
            parsed = self.parse_tool_output(raw_output, returncode=returncode, timed_out=timed_out)
            status = {
                **base,
                "execution_status": "executed_timeout" if timed_out else "executed",
                "status": parsed.status,
                "result": parsed.status,
                "verification_passed": parsed.verification_passed,
                "counterexample_available": parsed.counterexample_available,
                "returncode": returncode,
                "runtime_seconds": round(runtime_seconds, 3),
                "summary": parsed.summary,
                "failed_property": parsed.failed_property,
                "failed_properties_count": parsed.failed_properties_count,
                "successful_properties_count": parsed.successful_properties_count,
                "unknown_properties_count": parsed.unknown_properties_count,
                "property_results": [dataclasses.asdict(p) for p in parsed.property_results],
                "detected_errors": parsed.detected_errors,
                "warnings": parsed.warnings,
                "execution_error": execution_error,
                "next_required_agent": "evaluation_reporter" if parsed.verification_passed else "counterexample_analysis_agent",
            }

        # Ensure parsed exists in all branches.
        if "parsed" not in locals():
            parsed = self.parse_tool_output(raw_output, returncode=returncode, timed_out=timed_out)

        # Root and iteration-specific outputs.
        write_text(self.output_path, raw_output)
        iteration_output = self.tool_outputs_dir / f"cbmc_output_iteration_{self.iteration:02d}.txt"
        write_text(iteration_output, raw_output)
        status["output_file"] = str(self.output_path)
        status["iteration_output_file"] = str(iteration_output)
        status["v2_outputs"] = {
            "command_manifest": str(self.command_manifest_path),
            "environment_snapshot": str(self.environment_snapshot_path),
            "critic_gate_decision": str(self.critic_gate_path),
            "diagnostics": str(self.diagnostics_path),
            "trace_summary": str(self.trace_summary_path),
            "failed_property_mapping": str(self.failed_property_mapping_path),
            "property_mapping_csv": str(self.property_mapping_csv_path),
            "traceability": str(self.traceability_path),
        }

        property_results = status.get("property_results", [])
        mapping, mapping_rows = self.map_property_results(property_results)
        diagnostics = parsed.diagnostics if isinstance(parsed.diagnostics, dict) else self.build_diagnostics_from_text(
            raw_output=raw_output,
            returncode=returncode,
            timed_out=timed_out,
            detected_errors=status.get("detected_errors", []),
            warnings=status.get("warnings", []),
            property_results=property_results,
            status=status.get("status", "unknown"),
        )
        trace_summary = parsed.trace_summary if isinstance(parsed.trace_summary, dict) else self.extract_trace_summary(raw_output)
        traceability = self.build_traceability_report(status, mapping, gate, command_meta)

        property_results_json = {
            "schema_version": "2.0",
            "created_at": utc_now(),
            "agent": AGENT_NAME,
            "iteration": self.iteration,
            "artifact_file": str(artifact_path),
            "property_results": property_results,
            "failed_properties_count": status.get("failed_properties_count", 0),
            "successful_properties_count": status.get("successful_properties_count", 0),
            "unknown_properties_count": status.get("unknown_properties_count", 0),
            "mapping_file": str(self.failed_property_mapping_path),
        }

        write_json(self.property_results_path, property_results_json)
        write_json(self.diagnostics_path, diagnostics)
        write_json(self.trace_summary_path, trace_summary)
        write_json(self.failed_property_mapping_path, mapping)
        write_csv(self.property_mapping_csv_path, mapping_rows)
        write_json(self.traceability_path, traceability)

        markdown = self.render_markdown(status, gate, diagnostics, mapping)
        write_text(self.md_path, markdown)
        write_json(self.status_path, status)
        write_json(
            self.agent_status_path,
            {
                "agent": AGENT_NAME,
                "agent_number": AGENT_NUMBER,
                "schema_version": SCHEMA_VERSION,
                "status": "completed",
                "tool_status": status.get("status"),
                "execution_status": status.get("execution_status"),
                "created_at": utc_now(),
                "iteration": self.iteration,
                "human_review_required": True,
                "outputs": {
                    "cbmc_output": str(self.output_path),
                    "cbmc_status": str(self.status_path),
                    "cbmc_command": str(self.command_path),
                    "markdown_report": str(self.md_path),
                    "property_results": str(self.property_results_path),
                    "command_manifest": str(self.command_manifest_path),
                    "environment_snapshot": str(self.environment_snapshot_path),
                    "critic_gate_decision": str(self.critic_gate_path),
                    "diagnostics": str(self.diagnostics_path),
                    "trace_summary": str(self.trace_summary_path),
                    "failed_property_mapping": str(self.failed_property_mapping_path),
                    "property_mapping_csv": str(self.property_mapping_csv_path),
                    "traceability": str(self.traceability_path),
                },
            },
        )

        self.log_event(
            "agent_finish",
            {
                "iteration": self.iteration,
                "status": status.get("status"),
                "execution_status": status.get("execution_status"),
                "verification_passed": status.get("verification_passed"),
                "counterexample_available": status.get("counterexample_available"),
                "runtime_seconds": status.get("runtime_seconds"),
                "output_file": str(self.output_path),
                "status_file": str(self.status_path),
                "critic_gate_blocked": gate.get("blocked"),
            },
            status=str(status.get("status")),
        )

        print(f"[OK] Formal Tool Execution Agent v2 wrote: {self.status_path}")
        print(f"[OK] Raw tool output: {self.output_path}")
        print(f"[OK] Command manifest: {self.command_manifest_path}")
        print(f"[OK] Environment snapshot: {self.environment_snapshot_path}")
        print(f"[STATUS] {status.get('status')}")
        if status.get("status") == "passed":
            print("[NOTE] CBMC passed only the selected candidate harness/properties under recorded assumptions.")
        elif status.get("status") == "critic_blocked":
            print("[NOTE] Critic gate blocked CBMC execution; repair/human review should happen first.")
        elif status.get("status") == "tool_unavailable":
            print("[NOTE] CBMC is not installed or not on PATH; command was saved for later execution.")
        else:
            print("[NOTE] Non-pass status is recorded honestly for counterexample analysis / repair.")
        return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Agent 7 v2: Formal Tool Execution Agent for the AI-assisted formal-verification artifact workflow."
    )
    parser.add_argument("--config", required=True, help="Path to run config JSON, e.g., configs/poly_add_run.json")
    parser.add_argument("--run-dir", required=False, help="Run directory, e.g., runs/run_001_poly_add")
    parser.add_argument("--iteration", type=int, default=0, help="Current refinement iteration number")
    parser.add_argument("--artifact", default=None, help="Artifact filename/path to verify, e.g., 04_generated_harness.c or 08_repaired_harness.c")
    parser.add_argument("--dry-run", action="store_true", help="Build and save CBMC command without executing CBMC")
    parser.add_argument("--force", action="store_true", help="Override critic gate and run/prepare tool execution anyway")
    parser.add_argument("--ignore-critic-gate", action="store_true", help="Do not enforce Agent 6 critic gate for this run")
    parser.add_argument("--timeout-seconds", type=int, default=None, help="Override CBMC timeout in seconds")
    return parser


def main(argv: Optional[List[str]] = None) -> int:
    args = build_arg_parser().parse_args(argv)
    agent = ToolExecutionAgentV2(
        config_path=Path(args.config),
        run_dir=Path(args.run_dir) if args.run_dir else None,
        iteration=args.iteration,
        artifact=args.artifact,
        dry_run=args.dry_run,
        force=args.force,
        timeout_seconds=args.timeout_seconds,
        ignore_critic_gate=args.ignore_critic_gate,
    )
    return agent.run()


if __name__ == "__main__":
    raise SystemExit(main())
