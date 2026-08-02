#!/usr/bin/env python3
"""
experiment_logger_agent_refactored.py

Agent 10 — Experiment Logger Agent, refactored for the new thesis workflow.

Architecture implemented:
- Deterministic-only stage.
- No LLM calls.
- Scans the run directory and all stage manifests/handoff manifests.
- Builds reproducibility indexes without duplicating all artefacts.
- Computes checksums for referenced artefacts.
- Records LLM usage/status from validation and prompt-package metadata.
- Records tool evidence from Agent 7.
- Records review gates, repair outputs, and failure classifications.
- Produces a complete experiment log and integrity validation.
- Downstream Agent 11 consumes only manifest-declared handoff outputs.
- No root-level output dumping.
- No duplicate copies of stage artefacts.

Trust boundary:
- Agent 10 does not reinterpret scientific results.
- Agent 10 does not claim proof, verification success, correctness, FIPS compliance, or security.
- Agent 10 records what happened, where files are, what checksums they have, and what evidence exists.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import platform
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
except Exception as import_exc:  # pragma: no cover
    raise SystemExit(
        "Failed to import shared workflow module:\n"
        "  agents/common/run_layout.py\n"
        f"Original import error: {type(import_exc).__name__}: {import_exc}"
    )


JsonDict = Dict[str, Any]
PathLike = Union[str, Path]


# ---------------------------------------------------------------------------
# Stage metadata
# ---------------------------------------------------------------------------

KNOWN_STAGES: List[JsonDict] = [
    {"stage_key": "01_master_orchestrator", "agent": "Master Orchestrator", "stage_type": "deterministic_control"},
    {"stage_key": "02_spec_extraction", "agent": "Specification Extraction", "stage_type": "llm_backed"},
    {"stage_key": "03_code_understanding", "agent": "Code Understanding", "stage_type": "llm_backed"},
    {"stage_key": "04_property_discovery", "agent": "Property Discovery", "stage_type": "llm_backed"},
    {"stage_key": "05_artifact_generation", "agent": "Formal Artefact Generation", "stage_type": "llm_backed_plus_rendering"},
    {"stage_key": "06_review_critic", "agent": "Review/Critic", "stage_type": "llm_backed_plus_gate"},
    {"stage_key": "07_tool_execution", "agent": "Formal Tool Execution", "stage_type": "deterministic_tool"},
    {"stage_key": "08_counterexample_analysis", "agent": "Counterexample Analysis", "stage_type": "llm_backed"},
    {"stage_key": "09_repair_refinement", "agent": "Repair/Refinement", "stage_type": "llm_backed_plus_candidate_rendering"},
    {"stage_key": "10_experiment_logger", "agent": "Experiment Logger", "stage_type": "deterministic_logging"},
    {"stage_key": "11_evaluation_reporter", "agent": "Evaluation Reporter", "stage_type": "mixed_or_llm_backed"},
]

LLM_STAGES = {
    "02_spec_extraction",
    "03_code_understanding",
    "04_property_discovery",
    "05_artifact_generation",
    "06_review_critic",
    "08_counterexample_analysis",
    "09_repair_refinement",
}

DETERMINISTIC_ONLY_STAGES = {
    "01_master_orchestrator",
    "07_tool_execution",
    "10_experiment_logger",
}


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


def safe_read_text(path: PathLike, *, max_chars: Optional[int] = None) -> str:
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    if max_chars is not None and len(text) > max_chars:
        return text[:max_chars] + "\n[TRUNCATED]\n"
    return text


def sha256_file(path: PathLike) -> Optional[str]:
    p = Path(path)
    if not p.exists() or not p.is_file():
        return None
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def file_record(path: PathLike, *, run_dir: Path, role: str = "unknown", stage_key: Optional[str] = None) -> JsonDict:
    p = Path(path)
    try:
        rel = str(p.relative_to(run_dir))
    except Exception:
        rel = str(p)

    if not p.exists():
        return {
            "path": str(p),
            "relative_path": rel,
            "exists": False,
            "role": role,
            "stage_key": stage_key,
        }

    stat = p.stat()
    return {
        "path": str(p),
        "relative_path": rel,
        "exists": True,
        "is_file": p.is_file(),
        "is_dir": p.is_dir(),
        "role": role,
        "stage_key": stage_key,
        "size_bytes": stat.st_size if p.is_file() else None,
        "sha256": sha256_file(p) if p.is_file() else None,
        "modified_time_utc": datetime.fromtimestamp(stat.st_mtime, timezone.utc).isoformat(),
        "suffix": p.suffix if p.is_file() else None,
    }


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


def try_load_json(path: PathLike) -> Tuple[Optional[JsonDict], Optional[str]]:
    try:
        return read_json_file(path), None
    except Exception as exc:
        return None, f"{type(exc).__name__}: {exc}"


def flatten_manifest_paths(obj: Any, base_dir: Path) -> List[Path]:
    """
    Collect path-like string values from manifests.
    This is intentionally conservative and used for inventory/checksum indexing.
    """
    out: List[Path] = []

    def maybe_add(x: str) -> None:
        s = x.strip()
        if not s:
            return
        # Avoid normal prose and very long values.
        if len(s) > 400:
            return
        looks_path = (
            "/" in s or "\\" in s or
            s.endswith((".json", ".txt", ".c", ".h", ".csv", ".md", ".patch", ".log"))
        )
        if not looks_path:
            return

        p = Path(s)
        if not p.is_absolute():
            p = (base_dir / p).resolve()
        out.append(p)

    def walk(x: Any) -> None:
        if isinstance(x, str):
            maybe_add(x)
        elif isinstance(x, dict):
            for v in x.values():
                walk(v)
        elif isinstance(x, list):
            for v in x:
                walk(v)

    walk(obj)
    # De-duplicate preserving order.
    seen = set()
    unique = []
    for p in out:
        key = str(p)
        if key not in seen:
            seen.add(key)
            unique.append(p)
    return unique


def safe_relative(path: Path, base: Path) -> str:
    try:
        return str(path.relative_to(base))
    except Exception:
        return str(path)


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

@dataclass
class ExperimentLoggerConfig:
    run_dir: Path
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM reproducibility logging"
    include_file_inventory: bool = True
    include_checksums: bool = True
    include_prompt_index: bool = True
    include_llm_index: bool = True
    include_tool_index: bool = True
    include_event_log: bool = True
    max_file_inventory_count: int = 5000
    strict_required_stages: bool = False
    allow_missing_previous_stages: bool = True


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


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, ExperimentLoggerConfig]:
    config_data: JsonDict = {}
    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        config_data = load_normalized_config(config_path)

    el = config_data.get("experiment_logger", {})
    if not isinstance(el, dict):
        el = {}

    target_function = (
        args.target_function
        or str(config_data.get("target_function") or "")
        or str(config_data.get("function_name") or "")
        or "mlk_poly_add"
    )

    target_topic = (
        args.target_topic
        or str(config_data.get("target_topic") or "")
        or f"Reproducibility logging for {target_function}"
    )

    cfg = ExperimentLoggerConfig(
        run_dir=resolve_run_dir(config_data, args),
        target_function=target_function,
        target_topic=target_topic,
        include_file_inventory=bool(el.get("include_file_inventory", True)),
        include_checksums=bool(el.get("include_checksums", True)),
        include_prompt_index=bool(el.get("include_prompt_index", True)),
        include_llm_index=bool(el.get("include_llm_index", True)),
        include_tool_index=bool(el.get("include_tool_index", True)),
        include_event_log=bool(el.get("include_event_log", True)),
        max_file_inventory_count=int(el.get("max_file_inventory_count", 5000)),
        strict_required_stages=bool(args.strict_required_stages or el.get("strict_required_stages", False)),
        allow_missing_previous_stages=bool(el.get("allow_missing_previous_stages", True)),
    )
    return config_data, cfg


# ---------------------------------------------------------------------------
# Directory helpers
# ---------------------------------------------------------------------------

def stage_dir(run_dir: Path, stage_key: str) -> Path:
    return run_dir / "stages" / stage_key


def stage_manifest_path(run_dir: Path, stage_key: str) -> Path:
    return stage_dir(run_dir, stage_key) / "stage_manifest.json"


def handoff_manifest_path(run_dir: Path, stage_key: str) -> Path:
    return stage_dir(run_dir, stage_key) / "handoff" / "handoff_manifest.json"


def resolve_handoff_output(run_dir: Path, stage_key: str, output_key: str) -> Optional[Path]:
    """Resolve one canonical output through the stage handoff manifest."""
    manifest_path = handoff_manifest_path(run_dir, stage_key)
    if not manifest_path.exists():
        return None
    try:
        manifest = read_json_file(manifest_path)
        outputs = manifest.get("handoff_outputs", {})
        if not isinstance(outputs, dict):
            return None
        rel = outputs.get(output_key)
        if not rel:
            return None
        return (stage_dir(run_dir, stage_key) / str(rel)).resolve()
    except Exception:
        return None


def build_iteration_evidence_index(run_dir: Path, stage_key: str) -> List[JsonDict]:
    """Index immutable iteration directories without assuming fixed output locations."""
    root = stage_dir(run_dir, stage_key) / "iterations"
    rows: List[JsonDict] = []
    if not root.exists():
        return rows
    for iteration_dir in sorted(p for p in root.iterdir() if p.is_dir() and p.name.startswith("iteration_")):
        manifest_path = iteration_dir / "handoff" / "handoff_manifest.json"
        outputs: Dict[str, Any] = {}
        manifest_error = None
        if manifest_path.exists():
            try:
                manifest = read_json_file(manifest_path)
                raw_outputs = manifest.get("handoff_outputs", {})
                if isinstance(raw_outputs, dict):
                    for key, rel in raw_outputs.items():
                        resolved = (stage_dir(run_dir, stage_key) / str(rel)).resolve() if not Path(str(rel)).is_absolute() else Path(str(rel)).resolve()
                        outputs[str(key)] = {
                            "path": str(resolved),
                            "exists": resolved.is_file(),
                            "sha256": sha256_file(resolved) if resolved.is_file() else None,
                        }
            except Exception as exc:
                manifest_error = f"{type(exc).__name__}: {exc}"
        rows.append({
            "iteration": iteration_dir.name,
            "iteration_dir": str(iteration_dir),
            "handoff_manifest": str(manifest_path),
            "handoff_manifest_exists": manifest_path.is_file(),
            "handoff_manifest_sha256": sha256_file(manifest_path) if manifest_path.is_file() else None,
            "manifest_error": manifest_error,
            "outputs": outputs,
        })
    return rows


def experiment_log_dir(layout: RunLayout) -> Path:
    # Use direct path to avoid requiring a new RunLayout method.
    p = layout.stage_dir("10_experiment_logger") / "experiment_log"
    ensure_dir(p)
    return p


# ---------------------------------------------------------------------------
# Index builders
# ---------------------------------------------------------------------------

def discover_stage_dirs(run_dir: Path) -> List[Path]:
    stages_root = run_dir / "stages"
    if not stages_root.exists():
        return []
    return sorted([p for p in stages_root.iterdir() if p.is_dir()])


def build_run_metadata(config_data: JsonDict, cfg: ExperimentLoggerConfig) -> JsonDict:
    root_files = []
    for name in ["run_config.resolved.json", "workflow_plan.json", "run_manifest.json", "status.json", "events.jsonl"]:
        path = cfg.run_dir / name
        root_files.append(file_record(path, run_dir=cfg.run_dir, role=f"run_root_{name}", stage_key=None))

    status_path = cfg.run_dir / "status.json"
    final_summary_path = cfg.run_dir / "final" / "final_run_summary.json"
    status_data, status_error = try_load_json(status_path) if status_path.exists() else (None, "missing")
    final_data, final_error = try_load_json(final_summary_path) if final_summary_path.exists() else (None, "missing")
    status_content = status_data.get("content") if isinstance(status_data, dict) and isinstance(status_data.get("content"), dict) else status_data
    final_content = final_data.get("content") if isinstance(final_data, dict) and isinstance(final_data.get("content"), dict) else final_data

    invocation_origin = os.environ.get("THESIS_INVOCATION_ORIGIN") or "manual_or_external_invocation"
    root_status = status_content.get("status") if isinstance(status_content, dict) else None
    provisional_status = status_content.get("provisional_final_status") if isinstance(status_content, dict) else None
    final_status = final_content.get("final_status") if isinstance(final_content, dict) else None
    normal_orchestrated = invocation_origin == "master_orchestrator" and root_status in {
        "orchestration_core_completed",
        "passed_selected_properties",
        "completed_with_failures_or_unresolved_items",
    }

    return {
        "schema_version": "run_reproducibility_record.v2.provenance",
        "created_utc": utc_now_iso(),
        "stage": "10_experiment_logger",
        "target_function": cfg.target_function,
        "target_topic": cfg.target_topic,
        "run_dir": str(cfg.run_dir),
        "run_dir_exists": cfg.run_dir.exists(),
        "config_summary": {
            "run_id": config_data.get("run_id"),
            "runs_dir": config_data.get("runs_dir"),
            "target_function": config_data.get("target_function"),
            "target_topic": config_data.get("target_topic"),
            "property_campaign": config_data.get("property_campaign"),
            "llm_config_present": isinstance(config_data.get("llm"), dict),
            "tool_execution_config_present": isinstance(config_data.get("tool_execution"), dict),
        },
        "execution_provenance": {
            "invocation_origin": invocation_origin,
            "orchestrator_pid": os.environ.get("THESIS_ORCHESTRATOR_PID"),
            "root_status": root_status,
            "provisional_final_status": provisional_status,
            "final_summary_status": final_status,
            "normal_orchestrated_execution": normal_orchestrated,
            "status_path": str(status_path),
            "status_error": status_error,
            "final_summary_path": str(final_summary_path),
            "final_summary_error": final_error,
        },
        "root_status_record": status_content,
        "final_summary_record": final_content,
        "platform": {
            "system": platform.system(),
            "release": platform.release(),
            "machine": platform.machine(),
            "python_version": platform.python_version(),
        },
        "known_stage_plan": KNOWN_STAGES,
        "run_root_files": root_files,
        "trust_boundary": {
            "logger": "deterministic_evidence_indexing_only",
            "formal_truth": "not_claimed",
            "interpretation": "left_to_evaluation_reporter_and_human_review",
        },
    }


def build_stage_manifest_index(run_dir: Path) -> JsonDict:
    rows = []
    for info in KNOWN_STAGES:
        key = info["stage_key"]
        p = stage_manifest_path(run_dir, key)
        data, err = try_load_json(p) if p.exists() else (None, "missing")
        content = data.get("content") if isinstance(data, dict) and isinstance(data.get("content"), dict) else data

        rows.append({
            "stage_key": key,
            "agent": info["agent"],
            "stage_type": info["stage_type"],
            "stage_dir_exists": stage_dir(run_dir, key).exists(),
            "manifest_path": str(p),
            "manifest_exists": p.exists(),
            "manifest_sha256": sha256_file(p) if p.exists() else None,
            "manifest_error": err,
            "manifest_stage": content.get("stage") if isinstance(content, dict) else None,
            "manifest_success": content.get("success") if isinstance(content, dict) else None,
            "notes": content.get("notes") if isinstance(content, dict) else None,
        })

    # Add any unexpected stage dirs.
    known = {x["stage_key"] for x in KNOWN_STAGES}
    for d in discover_stage_dirs(run_dir):
        if d.name not in known:
            p = d / "stage_manifest.json"
            data, err = try_load_json(p) if p.exists() else (None, "missing")
            rows.append({
                "stage_key": d.name,
                "agent": "unexpected_or_custom_stage",
                "stage_type": "unknown",
                "stage_dir_exists": True,
                "manifest_path": str(p),
                "manifest_exists": p.exists(),
                "manifest_sha256": sha256_file(p) if p.exists() else None,
                "manifest_error": err,
                "manifest_stage": data.get("stage") if isinstance(data, dict) else None,
                "manifest_success": data.get("success") if isinstance(data, dict) else None,
                "notes": data.get("notes") if isinstance(data, dict) else None,
            })

    manifest_exists_count = sum(1 for row in rows if row.get("manifest_exists"))
    manifest_missing_count = sum(1 for row in rows if not row.get("manifest_exists"))
    return {
        "schema_version": "stage_manifest_index.v1",
        "created_utc": utc_now_iso(),
        "indexed_stage_record_count": len(rows),
        "expected_stage_count": len(KNOWN_STAGES),
        "stage_manifest_count": manifest_exists_count,
        "missing_stage_manifest_count": manifest_missing_count,
        # Backwards-compatible alias: this is the number of indexed stage records,
        # not the number of existing manifests.
        "stage_count": len(rows),
        "rows": rows,
    }


def build_handoff_index(run_dir: Path) -> JsonDict:
    rows = []
    output_rows = []

    for info in KNOWN_STAGES:
        key = info["stage_key"]
        p = handoff_manifest_path(run_dir, key)
        data, err = try_load_json(p) if p.exists() else (None, "missing")
        content = data.get("content") if isinstance(data, dict) and isinstance(data.get("content"), dict) else data

        output_count = 0
        authoritative_source = None
        next_consumers = []
        if isinstance(content, dict):
            outputs = content.get("handoff_outputs", {})
            if isinstance(outputs, dict):
                output_count = len(outputs)
                for out_key, rel in outputs.items():
                    out_path = Path(str(rel))
                    if not out_path.is_absolute():
                        out_path = (stage_dir(run_dir, key) / out_path).resolve()
                    actual_checksum = sha256_file(out_path) if out_path.exists() and out_path.is_file() else None
                    declared_checksums = content.get("checksums_sha256", {}) if isinstance(content.get("checksums_sha256"), dict) else {}
                    declared_checksum = declared_checksums.get(out_key)
                    output_rows.append({
                        "producer_stage": key,
                        "output_key": out_key,
                        "declared_path": str(rel),
                        "resolved_path": str(out_path),
                        "exists": out_path.exists(),
                        "declared_sha256": declared_checksum,
                        "sha256": actual_checksum,
                        "checksum_matches_manifest": bool(declared_checksum and actual_checksum and declared_checksum == actual_checksum),
                        "checksum_declared": declared_checksum is not None,
                        "size_bytes": out_path.stat().st_size if out_path.exists() and out_path.is_file() else None,
                    })
            authoritative_source = content.get("authoritative_source")
            next_consumers = content.get("next_stage_consumers") or []

        rows.append({
            "stage_key": key,
            "handoff_path": str(p),
            "handoff_exists": p.exists(),
            "handoff_sha256": sha256_file(p) if p.exists() else None,
            "handoff_error": err,
            "authoritative_source": authoritative_source,
            "output_count": output_count,
            "next_stage_consumers": next_consumers,
        })

    return {
        "schema_version": "handoff_index.v1",
        "created_utc": utc_now_iso(),
        "stage_handoffs": rows,
        "handoff_outputs": output_rows,
        "handoff_output_count": len(output_rows),
    }


def build_artifact_inventory(run_dir: Path, cfg: ExperimentLoggerConfig) -> JsonDict:
    rows = []
    stages_root = run_dir / "stages"
    if not stages_root.exists():
        return {
            "schema_version": "artifact_inventory.v1",
            "created_utc": utc_now_iso(),
            "artifact_count": 0,
            "rows": [],
            "warning": "stages directory missing",
        }

    count = 0
    for p in sorted(stages_root.rglob("*")):
        if count >= cfg.max_file_inventory_count:
            rows.append({
                "relative_path": "[TRUNCATED]",
                "warning": f"inventory limited to {cfg.max_file_inventory_count} files",
            })
            break
        if p.is_file():
            parts = p.relative_to(stages_root).parts
            stage_key = parts[0] if parts else None
            role = parts[1] if len(parts) > 1 else "stage_root"
            rec = file_record(p, run_dir=run_dir, role=role, stage_key=stage_key)
            rows.append(rec)
            count += 1

    return {
        "schema_version": "artifact_inventory.v1",
        "created_utc": utc_now_iso(),
        "artifact_count": len([r for r in rows if r.get("exists")]),
        "max_file_inventory_count": cfg.max_file_inventory_count,
        "rows": rows,
    }


def build_checksum_manifest(artifact_inventory: JsonDict) -> JsonDict:
    rows = []
    for rec in artifact_inventory.get("rows", []):
        if rec.get("exists") and rec.get("is_file"):
            rows.append({
                "relative_path": rec.get("relative_path"),
                "stage_key": rec.get("stage_key"),
                "role": rec.get("role"),
                "size_bytes": rec.get("size_bytes"),
                "sha256": rec.get("sha256"),
            })
    return {
        "schema_version": "checksum_manifest.v1",
        "created_utc": utc_now_iso(),
        "checksum_count": len(rows),
        "rows": rows,
    }


def _latest_file(paths: Sequence[Path]) -> Optional[Path]:
    existing = [p for p in paths if p.exists() and p.is_file()]
    return max(existing, key=lambda p: p.stat().st_mtime_ns) if existing else None


def build_llm_call_index(run_dir: Path) -> JsonDict:
    rows = []
    for stage_key in sorted(LLM_STAGES):
        sdir = stage_dir(run_dir, stage_key)
        validation = _latest_file(list(sdir.rglob("llm_call_validation.json")))
        prompt_meta = _latest_file(list(sdir.rglob("prompt_metadata.json")))
        response_files = sorted(sdir.rglob("api_responses/attempt_*_response.json"))
        request_files = sorted(sdir.rglob("api_requests/attempt_*_request.json"))
        # Backwards-compatible discovery for old mock fixtures.
        if not response_files:
            response_files = sorted(sdir.rglob("raw_llm_response.json"))
        raw_response = _latest_file(response_files)

        validation_data, validation_err = try_load_json(validation) if validation else (None, "missing")
        prompt_data, prompt_err = try_load_json(prompt_meta) if prompt_meta else (None, "missing")
        raw_data, raw_err = try_load_json(raw_response) if raw_response else (None, "missing")
        validation_content = validation_data.get("content") if isinstance(validation_data, dict) and isinstance(validation_data.get("content"), dict) else validation_data
        prompt_content = prompt_data.get("content") if isinstance(prompt_data, dict) and isinstance(prompt_data.get("content"), dict) else prompt_data

        request_records = []
        for req in request_files:
            data, err = try_load_json(req)
            request_records.append({
                "path": str(req),
                "sha256": sha256_file(req),
                "parse_error": err,
                "request_sha256": data.get("request_sha256") if isinstance(data, dict) else None,
                "attempt": data.get("attempt") if isinstance(data, dict) else None,
            })

        llm_executed = get_nested(validation_content, ["llm_call_executed"])
        mode = get_nested(validation_content, ["mode"]) or get_nested(validation_content, ["llm_mode"])
        rows.append({
            "stage_key": stage_key,
            "validation_path": str(validation) if validation else None,
            "validation_exists": validation is not None,
            "validation_sha256": sha256_file(validation) if validation else None,
            "validation_error": validation_err,
            "llm_call_executed": llm_executed,
            "mode": mode,
            "success": get_nested(validation_content, ["valid"]),
            "mock": mode == "mock",
            "schema_validation_success": get_nested(validation_content, ["schema_validation", "valid"]),
            "prompt_metadata_path": str(prompt_meta) if prompt_meta else None,
            "prompt_metadata_exists": prompt_meta is not None,
            "prompt_metadata_sha256": sha256_file(prompt_meta) if prompt_meta else None,
            "prompt_metadata_error": prompt_err,
            "raw_response_path": str(raw_response) if raw_response else None,
            "raw_response_exists": raw_response is not None,
            "raw_response_sha256": sha256_file(raw_response) if raw_response else None,
            "raw_response_error": raw_err,
            "response_attempt_count": len(response_files),
            "exact_request_snapshot_count": len(request_files),
            "exact_request_snapshots": request_records,
            "request_response_attempt_counts_match": len(request_files) == len(response_files) if llm_executed else True,
        })

    return {
        "schema_version": "llm_call_index.v2.exact_requests",
        "created_utc": utc_now_iso(),
        "llm_stage_count": len(rows),
        "rows": rows,
        "security_note": "API keys are not recorded; each real attempt has a redacted exact payload snapshot.",
    }


def get_nested(obj: Any, keys: Sequence[str]) -> Any:
    cur = obj
    for key in keys:
        if not isinstance(cur, dict):
            return None
        cur = cur.get(key)
    return cur


def build_prompt_package_index(run_dir: Path) -> JsonDict:
    rows = []
    for stage_key in sorted(LLM_STAGES):
        pdir = stage_dir(run_dir, stage_key) / "prompt_package"
        if not pdir.exists():
            rows.append({
                "stage_key": stage_key,
                "prompt_package_exists": False,
            })
            continue
        for p in sorted(pdir.rglob("*")):
            if p.is_file():
                rec = file_record(p, run_dir=run_dir, role="prompt_package", stage_key=stage_key)
                rows.append(rec)

    return {
        "schema_version": "prompt_package_index.v1",
        "created_utc": utc_now_iso(),
        "file_count": len(rows),
        "rows": rows,
        "security_note": "Prompt packages are indexed for reproducibility. They should not contain API keys.",
    }


def build_tool_evidence_index(run_dir: Path) -> JsonDict:
    stage_key = "07_tool_execution"
    handoff_keys = [
        "cbmc_status",
        "cbmc_output",
        "cbmc_stderr",
        "cbmc_command",
        "cbmc_property_results",
        "cbmc_trace_summary",
        "failed_property_mapping",
        "tool_command_manifest",
        "tool_environment_snapshot",
        "cbmc_diagnostics",
        "tool_execution_traceability",
    ]

    rows = []
    status_data = None
    diagnostics_data = None
    for key in handoff_keys:
        p = resolve_handoff_output(run_dir, stage_key, key)
        if p is None:
            rec = {
                "path": None,
                "relative_path": None,
                "exists": False,
                "is_file": False,
                "sha256": None,
                "size_bytes": None,
                "role": f"tool_evidence_{key}",
                "stage_key": stage_key,
                "resolution": "handoff_key_missing",
            }
        else:
            rec = file_record(p, run_dir=run_dir, role=f"tool_evidence_{key}", stage_key=stage_key)
            rec["resolution"] = "canonical_handoff_manifest"
        rows.append({"evidence_key": key, **rec})
        if key == "cbmc_status" and p and p.exists():
            status_data, _ = try_load_json(p)
        if key == "cbmc_diagnostics" and p and p.exists():
            diagnostics_data, _ = try_load_json(p)

    return {
        "schema_version": "tool_evidence_index.v2.manifest_resolved",
        "created_utc": utc_now_iso(),
        "tool_stage": stage_key,
        "evidence_files": rows,
        "iteration_evidence": build_iteration_evidence_index(run_dir, stage_key),
        "cbmc_status_summary": status_data,
        "cbmc_diagnostics_summary": diagnostics_data,
        "formal_claim_boundary": {
            "property_specific_tool_evidence_only": True,
            "full_correctness_claimed": False,
            "fips_compliance_claimed": False,
            "cryptographic_security_claimed": False,
        },
    }


def build_gate_and_repair_index(run_dir: Path) -> JsonDict:
    items = {}
    sources = {
        "review_gate_decision": ("06_review_critic", "review_gate_decision"),
        "formal_build_plan": ("06_review_critic", "formal_build_plan"),
        "independence_audit": ("05_artifact_generation", "independence_audit"),
        "counterexample_analysis": ("08_counterexample_analysis", "counterexample_analysis"),
        "repair_plan": ("09_repair_refinement", "repair_plan"),
        "repair_manifest_update": ("09_repair_refinement", "repair_manifest_update"),
        "repair_safety_review": ("09_repair_refinement", "repair_safety_review"),
        "repaired_harness": ("09_repair_refinement", "repaired_harness"),
        "repair_diff": ("09_repair_refinement", "repair_diff"),
    }

    for key, (producer, handoff_key) in sources.items():
        p = resolve_handoff_output(run_dir, producer, handoff_key)
        data, err = try_load_json(p) if p and p.exists() and p.suffix.lower() == ".json" else (None, None if p and p.exists() else "missing")
        items[key] = {
            "producer_stage": producer,
            "handoff_key": handoff_key,
            "path": str(p) if p else None,
            "exists": bool(p and p.exists()),
            "sha256": sha256_file(p) if p and p.is_file() else None,
            "error": err,
            "summary": summarize_known_json(key, data),
            "resolution": "canonical_handoff_manifest" if p else "handoff_key_missing",
        }

    return {
        "schema_version": "gate_and_repair_index.v2.manifest_resolved",
        "created_utc": utc_now_iso(),
        "items": items,
        "iterations": {
            stage: build_iteration_evidence_index(run_dir, stage)
            for stage in [
                "06_review_critic",
                "08_counterexample_analysis",
                "09_repair_refinement",
            ]
        },
    }


def summarize_known_json(key: str, data: Optional[JsonDict]) -> Any:
    if not isinstance(data, dict):
        return None
    content = data.get("content") if isinstance(data.get("content"), dict) else data

    if key == "review_gate_decision":
        return {
            "final_gate": content.get("final_gate"),
            "tool_execution_allowed": content.get("tool_execution_allowed"),
            "reason": content.get("reason"),
        }
    if key == "independence_audit":
        return {
            "copying_risk": content.get("copying_risk"),
            "requires_human_similarity_review": content.get("requires_human_similarity_review"),
            "max_similarity_score": content.get("max_similarity_score"),
        }
    if key == "counterexample_analysis":
        trs = content.get("tool_result_summary") if isinstance(content.get("tool_result_summary"), dict) else {}
        fc = content.get("failure_classification") if isinstance(content.get("failure_classification"), dict) else {}
        return {
            "result_classification": trs.get("result_classification") or fc.get("result_classification"),
            "mock": content.get("mock"),
        }
    if key == "repair_plan":
        return {
            "mock": content.get("mock"),
            "repair_decision": content.get("repair_decision"),
            "proposed_repair_count": len(content.get("proposed_repairs", [])) if isinstance(content.get("proposed_repairs"), list) else None,
        }
    if key == "repair_manifest_update":
        return {
            "applied_to_original": content.get("applied_to_original"),
            "requires_human_review": content.get("requires_human_review"),
        }
    if key == "repair_safety_review":
        return {
            "requires_human_review": content.get("requires_human_review"),
            "safety_flags": content.get("safety_flags"),
            "applied_to_original": content.get("applied_to_original"),
        }
    return None


def build_event_log_index(run_dir: Path) -> JsonDict:
    p = run_dir / "events.jsonl"
    rows = []
    parse_errors = []

    if p.exists():
        for idx, line in enumerate(p.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
            if not line.strip():
                continue
            try:
                obj = json.loads(line)
                rows.append({
                    "line": idx,
                    "timestamp": obj.get("timestamp") or obj.get("created_utc") or obj.get("time"),
                    "event_type": obj.get("event_type") or obj.get("type"),
                    "stage": obj.get("stage"),
                    "message": obj.get("message"),
                })
            except Exception as exc:
                parse_errors.append({"line": idx, "error": f"{type(exc).__name__}: {exc}"})

    return {
        "schema_version": "event_log_index.v1",
        "created_utc": utc_now_iso(),
        "events_path": str(p),
        "events_exists": p.exists(),
        "events_sha256": sha256_file(p) if p.exists() else None,
        "event_count": len(rows),
        "parse_error_count": len(parse_errors),
        "events": rows[-500:],
        "parse_errors": parse_errors,
    }


def build_failure_mode_log(run_dir: Path) -> JsonDict:
    records = []

    cbmc_status_path = stage_dir(run_dir, "07_tool_execution") / "tool_outputs" / "06_cbmc_status.json"
    cex_det_path = stage_dir(run_dir, "08_counterexample_analysis") / "deterministic_reference" / "07_counterexample_analysis.deterministic.json"
    repair_triage_path = stage_dir(run_dir, "09_repair_refinement") / "deterministic_reference" / "08_repair_triage.deterministic.json"

    for key, p in [
        ("cbmc_status", cbmc_status_path),
        ("counterexample_deterministic_analysis", cex_det_path),
        ("repair_triage", repair_triage_path),
    ]:
        data, err = try_load_json(p) if p.exists() else (None, "missing")
        content = data.get("content") if isinstance(data, dict) and isinstance(data.get("content"), dict) else data
        records.append({
            "record_key": key,
            "path": str(p),
            "exists": p.exists(),
            "sha256": sha256_file(p) if p.exists() else None,
            "error": err,
            "summary": summarize_failure_record(key, content),
        })

    return {
        "schema_version": "failure_mode_log.v1",
        "created_utc": utc_now_iso(),
        "records": records,
    }


def summarize_failure_record(key: str, content: Any) -> Any:
    if not isinstance(content, dict):
        return None
    if key == "cbmc_status":
        return {
            "result_classification": content.get("result_classification"),
            "tool_executed": content.get("tool_executed"),
            "execution_skipped": content.get("execution_skipped"),
            "exit_code": content.get("exit_code"),
        }
    if key == "counterexample_deterministic_analysis":
        cls = content.get("classification", {})
        return {
            "result_classification": cls.get("result_classification") if isinstance(cls, dict) else None,
            "failure_categories": cls.get("failure_categories") if isinstance(cls, dict) else None,
            "repair_needed": cls.get("repair_needed") if isinstance(cls, dict) else None,
        }
    if key == "repair_triage":
        return {
            "result_classification": content.get("result_classification"),
            "repair_needed": content.get("repair_needed"),
            "triage_decision": content.get("triage_decision"),
            "source_code_repair_allowed": content.get("source_code_repair_allowed"),
        }
    return None


def build_integrity_validation(
    *,
    run_dir: Path,
    stage_index: JsonDict,
    handoff_index: JsonDict,
    artifact_inventory: JsonDict,
    llm_index: JsonDict,
    tool_index: JsonDict,
    run_metadata: JsonDict,
    cfg: ExperimentLoggerConfig,
) -> JsonDict:
    warnings = []
    errors = []

    # Required stage directories/manifests.
    for row in stage_index.get("rows", []):
        key = row.get("stage_key")
        if key in {"10_experiment_logger", "11_evaluation_reporter"}:
            # Agent 10 is currently writing its own manifest, and Agent 11 is a future consumer.
            continue
        if not row.get("stage_dir_exists"):
            item = {
                "severity": "warning" if cfg.allow_missing_previous_stages else "error",
                "kind": "missing_stage_dir",
                "stage_key": key,
                "message": f"Stage directory missing: {key}",
            }
            (warnings if cfg.allow_missing_previous_stages else errors).append(item)
        elif not row.get("manifest_exists"):
            warnings.append({
                "severity": "warning",
                "kind": "missing_stage_manifest",
                "stage_key": key,
                "message": f"Stage manifest missing: {key}",
            })

    # Handoff outputs that point to missing files.
    missing_handoff_outputs = [
        r for r in handoff_index.get("handoff_outputs", [])
        if not r.get("exists")
    ]
    for r in missing_handoff_outputs:
        warnings.append({
            "severity": "warning",
            "kind": "missing_handoff_output",
            "stage_key": r.get("producer_stage"),
            "output_key": r.get("output_key"),
            "message": f"Handoff output missing: {r.get('producer_stage')}::{r.get('output_key')}",
            "resolved_path": r.get("resolved_path"),
        })

    # LLM stages with missing validation.
    for row in llm_index.get("rows", []):
        if not row.get("validation_exists"):
            warnings.append({
                "severity": "warning",
                "kind": "missing_llm_validation",
                "stage_key": row.get("stage_key"),
                "message": f"LLM validation missing for {row.get('stage_key')}",
            })

    # Tool evidence boundary.
    tool_files = tool_index.get("evidence_files", [])
    cbmc_status = next((r for r in tool_files if r.get("evidence_key") == "cbmc_status"), None)
    if cbmc_status and not cbmc_status.get("exists"):
        warnings.append({
            "severity": "warning",
            "kind": "missing_cbmc_status",
            "stage_key": "07_tool_execution",
            "message": "CBMC status file missing.",
        })

    # Manifest-declared handoff checksums must match actual canonical files.
    for row in handoff_index.get("handoff_outputs", []):
        if row.get("exists") and not row.get("checksum_declared"):
            errors.append({
                "severity": "error",
                "kind": "handoff_checksum_not_declared",
                "stage_key": row.get("producer_stage"),
                "output_key": row.get("output_key"),
                "message": "Canonical handoff output has no declared checksum.",
            })
        elif row.get("exists") and not row.get("checksum_matches_manifest"):
            errors.append({
                "severity": "error",
                "kind": "handoff_checksum_mismatch",
                "stage_key": row.get("producer_stage"),
                "output_key": row.get("output_key"),
                "message": "Canonical handoff checksum differs from the manifest declaration.",
                "declared_sha256": row.get("declared_sha256"),
                "actual_sha256": row.get("sha256"),
            })

    # Real API calls require exact request/response evidence for every attempt.
    for row in llm_index.get("rows", []):
        if row.get("llm_call_executed"):
            if int(row.get("exact_request_snapshot_count") or 0) == 0:
                errors.append({
                    "severity": "error",
                    "kind": "missing_exact_api_request_snapshot",
                    "stage_key": row.get("stage_key"),
                    "message": "Real LLM call recorded without an exact redacted request snapshot.",
                })
            if not row.get("raw_response_exists"):
                errors.append({
                    "severity": "error",
                    "kind": "missing_api_response_record",
                    "stage_key": row.get("stage_key"),
                    "message": "Real LLM call recorded without a per-attempt response record.",
                })
            if not row.get("request_response_attempt_counts_match"):
                errors.append({
                    "severity": "error",
                    "kind": "api_attempt_record_count_mismatch",
                    "stage_key": row.get("stage_key"),
                    "message": "API request and response attempt records do not match.",
                })

    provenance = run_metadata.get("execution_provenance", {}) if isinstance(run_metadata.get("execution_provenance"), dict) else {}
    root_status = str(provenance.get("root_status") or "missing")
    if root_status == "orchestrator_failed":
        errors.append({
            "severity": "error",
            "kind": "orchestrator_failed_run",
            "stage_key": "01_master_orchestrator",
            "message": "The root orchestration status is orchestrator_failed. Later/manual files cannot make this a valid run.",
        })
    if not provenance.get("normal_orchestrated_execution"):
        severity = "error" if root_status in {"orchestrator_failed", "missing"} else "warning"
        item = {
            "severity": severity,
            "kind": "manual_or_external_logger_invocation",
            "stage_key": "10_experiment_logger",
            "message": "Agent 10 was not invoked by the normal master-orchestrator path; provenance is explicitly downgraded.",
            "invocation_origin": provenance.get("invocation_origin"),
            "root_status": root_status,
        }
        (errors if severity == "error" else warnings).append(item)

    validation_status = "valid_with_warnings" if warnings and not errors else "valid" if not errors else "invalid"

    return {
        "schema_version": "log_integrity_validation.v1",
        "created_utc": utc_now_iso(),
        "validation_status": validation_status,
        "error_count": len(errors),
        "warning_count": len(warnings),
        "errors": errors,
        "warnings": warnings,
        "missing_handoff_output_count": len(missing_handoff_outputs),
        "strict_required_stages": cfg.strict_required_stages,
        "limitations": [
            "Integrity validation checks presence, parseability, and checksums. It does not validate scientific correctness.",
            "Missing future Agent 11 outputs are expected when Agent 10 runs before reporting.",
        ],
    }


def build_missing_expected_outputs(validation: JsonDict) -> JsonDict:
    missing = []
    for item in validation.get("errors", []) + validation.get("warnings", []):
        if item.get("kind", "").startswith("missing"):
            missing.append(item)
    return {
        "schema_version": "missing_expected_outputs.v1",
        "created_utc": utc_now_iso(),
        "missing_count": len(missing),
        "items": missing,
    }


def build_run_summary(
    *,
    run_metadata: JsonDict,
    stage_index: JsonDict,
    handoff_index: JsonDict,
    llm_index: JsonDict,
    tool_index: JsonDict,
    gate_and_repair_index: JsonDict,
    failure_log: JsonDict,
    validation: JsonDict,
) -> JsonDict:
    llm_rows = llm_index.get("rows", [])
    llm_executed_count = len([r for r in llm_rows if r.get("llm_call_executed")])
    mock_count = len([r for r in llm_rows if r.get("mode") == "mock" or r.get("mock")])

    tool_summary = tool_index.get("cbmc_status_summary") or {}
    tool_content = tool_summary.get("content") if isinstance(tool_summary.get("content"), dict) else tool_summary

    gate_summary = gate_and_repair_index.get("items", {}).get("review_gate_decision", {}).get("summary")

    stage_rows = stage_index.get("rows", [])
    existing_stage_manifests = sum(1 for row in stage_rows if row.get("manifest_exists"))
    missing_stage_manifests = sum(1 for row in stage_rows if not row.get("manifest_exists"))

    return {
        "schema_version": "experiment_summary.v1",
        "created_utc": utc_now_iso(),
        "target_function": run_metadata.get("target_function"),
        "target_topic": run_metadata.get("target_topic"),
        "property_campaign": (run_metadata.get("config_summary") or {}).get("property_campaign") if isinstance(run_metadata.get("config_summary"), dict) else None,
        "run_dir": run_metadata.get("run_dir"),
        "expected_stage_count": len(KNOWN_STAGES),
        "indexed_stage_record_count": len(stage_rows),
        "stage_manifest_count": existing_stage_manifests,
        "missing_stage_manifest_count": missing_stage_manifests,
        "handoff_output_count": handoff_index.get("handoff_output_count"),
        "llm_stage_count": len(llm_rows),
        "llm_call_executed_count": llm_executed_count,
        "llm_mock_or_mocklike_count": mock_count,
        "cbmc_result_classification": tool_content.get("result_classification") if isinstance(tool_content, dict) else None,
        "cbmc_tool_executed": tool_content.get("tool_executed") if isinstance(tool_content, dict) else None,
        "review_gate": gate_summary,
        "integrity_validation_status": validation.get("validation_status"),
        "integrity_warning_count": validation.get("warning_count"),
        "integrity_error_count": validation.get("error_count"),
        "execution_provenance": run_metadata.get("execution_provenance"),
        "root_status": (run_metadata.get("execution_provenance") or {}).get("root_status") if isinstance(run_metadata.get("execution_provenance"), dict) else None,
        "normal_orchestrated_execution": (run_metadata.get("execution_provenance") or {}).get("normal_orchestrated_execution") if isinstance(run_metadata.get("execution_provenance"), dict) else False,
        "formal_claim_boundary": {
            "experiment_log_only": True,
            "proof_claimed": False,
            "verification_success_claimed_by_logger": False,
            "full_correctness_claimed": False,
            "fips_compliance_claimed": False,
            "cryptographic_security_claimed": False,
        },
    }


def build_markdown_summary(summary: JsonDict, validation: JsonDict) -> str:
    lines = [
        "# Agent 10 Experiment Log Summary",
        "",
        f"- Target function: `{summary.get('target_function')}`",
        f"- Run directory: `{summary.get('run_dir')}`",
        f"- Expected workflow stages: `{summary.get('expected_stage_count')}`",
        f"- Indexed stage records: `{summary.get('indexed_stage_record_count')}`",
        f"- Existing stage manifests: `{summary.get('stage_manifest_count')}`",
        f"- Missing stage manifests: `{summary.get('missing_stage_manifest_count')}`",
        f"- Handoff outputs indexed: `{summary.get('handoff_output_count')}`",
        f"- LLM calls executed: `{summary.get('llm_call_executed_count')}`",
        f"- Mock/mock-like LLM stages: `{summary.get('llm_mock_or_mocklike_count')}`",
        f"- CBMC result classification: `{summary.get('cbmc_result_classification')}`",
        f"- CBMC tool executed: `{summary.get('cbmc_tool_executed')}`",
        f"- Integrity status: `{summary.get('integrity_validation_status')}`",
        f"- Integrity warnings: `{summary.get('integrity_warning_count')}`",
        f"- Integrity errors: `{summary.get('integrity_error_count')}`",
        "",
        "## Claim boundary",
        "",
        "Agent 10 is a deterministic evidence logger. It indexes artefacts, manifests, checksums, LLM-call records, and tool evidence. It does not claim proof, full correctness, FIPS 203 compliance, cryptographic security, or verification success.",
        "",
    ]

    if validation.get("warnings"):
        lines.append("## Integrity warnings")
        lines.append("")
        for w in validation.get("warnings", [])[:50]:
            lines.append(f"- `{w.get('kind')}`: {w.get('message')}")
        lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main runner
# ---------------------------------------------------------------------------

def run_agent10(config_data: JsonDict, cfg: ExperimentLoggerConfig) -> int:
    stage = "10_experiment_logger"
    layout = RunLayout(cfg.run_dir, create=False)

    # Agent 10 is running while scanning the same run dir. Its own stage dir exists.
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 10 Experiment Logger started.",
        data={"target_function": cfg.target_function, "target_topic": cfg.target_topic},
    )

    stage_status: JsonDict = {
        "schema_version": "agent_status.v1",
        "stage": stage,
        "started_utc": utc_now_iso(),
        "completed_utc": None,
        "success": False,
        "handoff_available": False,
        "errors": [],
        "warnings": [],
    }

    try:
        elog = experiment_log_dir(layout)

        # --------------------------------------------------------------
        # 1. Build indexes.
        # --------------------------------------------------------------
        run_metadata = build_run_metadata(config_data, cfg)
        stage_index = build_stage_manifest_index(cfg.run_dir)
        handoff_index = build_handoff_index(cfg.run_dir)
        artifact_inventory = build_artifact_inventory(cfg.run_dir, cfg) if cfg.include_file_inventory else {
            "schema_version": "artifact_inventory.v1",
            "created_utc": utc_now_iso(),
            "artifact_count": 0,
            "rows": [],
            "disabled": True,
        }
        checksum_manifest = build_checksum_manifest(artifact_inventory) if cfg.include_checksums else {
            "schema_version": "checksum_manifest.v1",
            "created_utc": utc_now_iso(),
            "checksum_count": 0,
            "rows": [],
            "disabled": True,
        }
        llm_index = build_llm_call_index(cfg.run_dir) if cfg.include_llm_index else {
            "schema_version": "llm_call_index.v1",
            "created_utc": utc_now_iso(),
            "rows": [],
            "disabled": True,
        }
        prompt_index = build_prompt_package_index(cfg.run_dir) if cfg.include_prompt_index else {
            "schema_version": "prompt_package_index.v1",
            "created_utc": utc_now_iso(),
            "rows": [],
            "disabled": True,
        }
        tool_index = build_tool_evidence_index(cfg.run_dir) if cfg.include_tool_index else {
            "schema_version": "tool_evidence_index.v1",
            "created_utc": utc_now_iso(),
            "disabled": True,
        }
        event_index = build_event_log_index(cfg.run_dir) if cfg.include_event_log else {
            "schema_version": "event_log_index.v1",
            "created_utc": utc_now_iso(),
            "disabled": True,
        }
        gate_and_repair_index = build_gate_and_repair_index(cfg.run_dir)
        failure_log = build_failure_mode_log(cfg.run_dir)

        validation = build_integrity_validation(
            run_dir=cfg.run_dir,
            stage_index=stage_index,
            handoff_index=handoff_index,
            artifact_inventory=artifact_inventory,
            llm_index=llm_index,
            tool_index=tool_index,
            run_metadata=run_metadata,
            cfg=cfg,
        )
        missing_outputs = build_missing_expected_outputs(validation)

        summary = build_run_summary(
            run_metadata=run_metadata,
            stage_index=stage_index,
            handoff_index=handoff_index,
            llm_index=llm_index,
            tool_index=tool_index,
            gate_and_repair_index=gate_and_repair_index,
            failure_log=failure_log,
            validation=validation,
        )

        # The final experiment_log is a compact top-level index pointing to all detailed logs.
        experiment_log = {
            "schema_version": "experiment_log.v1",
            "created_utc": utc_now_iso(),
            "stage": stage,
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
            "property_campaign": config_data.get("property_campaign"),
            "summary": summary,
            "index_files": {},
            "claim_boundary": {
                "deterministic_logger_only": True,
                "proof_claimed": False,
                "verification_success_claimed_by_logger": False,
                "full_correctness_claimed": False,
                "fips_compliance_claimed": False,
                "cryptographic_security_claimed": False,
            },
            "notes": [
                "Detailed artefacts remain in their producing stage folders.",
                "Agent 10 records indexes and checksums rather than duplicating stage outputs.",
                "Use this log for reproducibility and audit, not as a proof result.",
            ],
        }

        # --------------------------------------------------------------
        # 2. Write detailed logs.
        # --------------------------------------------------------------
        paths: Dict[str, Path] = {}
        paths["run_reproducibility_record"] = atomic_write_json(elog / "09_run_reproducibility_record.json", run_metadata)
        paths["stage_manifest_index"] = atomic_write_json(elog / "09_stage_manifest_index.json", stage_index)
        paths["handoff_index"] = atomic_write_json(elog / "09_handoff_index.json", handoff_index)
        paths["artifact_inventory"] = atomic_write_json(elog / "09_artifact_inventory.json", artifact_inventory)
        paths["checksum_manifest"] = atomic_write_json(elog / "09_checksum_manifest.json", checksum_manifest)
        paths["llm_call_index"] = atomic_write_json(elog / "09_llm_call_index.json", llm_index)
        paths["prompt_package_index"] = atomic_write_json(elog / "09_prompt_package_index.json", prompt_index)
        paths["tool_evidence_index"] = atomic_write_json(elog / "09_tool_evidence_index.json", tool_index)
        paths["event_log_index"] = atomic_write_json(elog / "09_event_log_index.json", event_index)
        paths["gate_and_repair_index"] = atomic_write_json(elog / "09_gate_and_repair_index.json", gate_and_repair_index)
        paths["failure_mode_log"] = atomic_write_json(elog / "09_failure_mode_log.json", failure_log)

        validation_paths: Dict[str, Path] = {}
        validation_paths["log_integrity_validation"] = layout.write_validation_json(stage, "09_log_integrity_validation.json", validation)
        validation_paths["missing_expected_outputs"] = layout.write_validation_json(stage, "09_missing_expected_outputs.json", missing_outputs)

        # CSV exports for human inspection.
        validation_paths["reproducibility_warnings_csv"] = write_csv(
            layout.validation_dir(stage) / "09_reproducibility_warnings.csv",
            validation.get("warnings", []),
        )
        validation_paths["handoff_outputs_csv"] = write_csv(
            elog / "09_handoff_outputs.csv",
            handoff_index.get("handoff_outputs", []),
        )
        validation_paths["stage_manifest_index_csv"] = write_csv(
            elog / "09_stage_manifest_index.csv",
            stage_index.get("rows", []),
        )
        validation_paths["llm_call_index_csv"] = write_csv(
            elog / "09_llm_call_index.csv",
            llm_index.get("rows", []),
        )
        validation_paths["checksum_manifest_csv"] = write_csv(
            elog / "09_checksum_manifest.csv",
            checksum_manifest.get("rows", []),
        )

        # Now write compact experiment log after paths are known.
        experiment_log["index_files"] = {k: safe_relative(v, cfg.run_dir) for k, v in paths.items()}
        experiment_log["validation_files"] = {k: safe_relative(v, cfg.run_dir) for k, v in validation_paths.items()}
        experiment_log["summary"] = summary

        paths["experiment_log"] = atomic_write_json(elog / "09_experiment_log.json", experiment_log)

        md_summary_path = elog / "09_experiment_log.md"
        atomic_write_text(md_summary_path, build_markdown_summary(summary, validation))
        paths["experiment_log_markdown"] = md_summary_path

        # A rerun/replay manifest with commands and evidence pointers, not file copies.
        replay_manifest = {
            "schema_version": "replay_manifest.v1",
            "created_utc": utc_now_iso(),
            "run_dir": str(cfg.run_dir),
            "target_function": cfg.target_function,
            "stage_order": [s["stage_key"] for s in KNOWN_STAGES if s["stage_key"] != "11_evaluation_reporter"],
            "important_indexes": {k: safe_relative(v, cfg.run_dir) for k, v in paths.items()},
            "tool_evidence_index": safe_relative(paths["tool_evidence_index"], cfg.run_dir),
            "checksum_manifest": safe_relative(paths["checksum_manifest"], cfg.run_dir),
            "instructions": [
                "Use the stage manifests and handoff manifests to locate artefacts.",
                "Use checksum_manifest to verify file integrity.",
                "Do not treat this replay manifest as proof or verification evidence by itself.",
            ],
        }
        paths["replay_manifest"] = atomic_write_json(elog / "09_replay_manifest.json", replay_manifest)

        # --------------------------------------------------------------
        # 3. Handoff manifest.
        # --------------------------------------------------------------
        handoff_outputs = {
            "experiment_log": paths["experiment_log"],
            "experiment_log_markdown": paths["experiment_log_markdown"],
            "run_reproducibility_record": paths["run_reproducibility_record"],
            "stage_manifest_index": paths["stage_manifest_index"],
            "handoff_index": paths["handoff_index"],
            "artifact_inventory": paths["artifact_inventory"],
            "file_index": paths["artifact_inventory"],
            "checksum_manifest": paths["checksum_manifest"],
            "checksums": paths["checksum_manifest"],
            "llm_call_index": paths["llm_call_index"],
            "tool_evidence_index": paths["tool_evidence_index"],
            "gate_and_repair_index": paths["gate_and_repair_index"],
            "failure_mode_log": paths["failure_mode_log"],
            "log_integrity_validation": validation_paths["log_integrity_validation"],
            "missing_expected_outputs": validation_paths["missing_expected_outputs"],
            "replay_manifest": paths["replay_manifest"],
        }

        layout.write_handoff_manifest(
            stage,
            outputs=handoff_outputs,
            authoritative_source="deterministic_experiment_logging",
            next_stage_consumers=[
                "11_evaluation_reporter",
            ],
            notes={
                "handoff_policy": (
                    "Experiment logger hands off reproducibility indexes, checksums, and validation records. "
                    "It does not duplicate all producing-stage artefacts."
                ),
                "llm_used": False,
                "formal_truth_claimed": False,
                "verification_success_claimed_by_logger": False,
                "integrity_validation_status": validation.get("validation_status"),
                "warning_count": validation.get("warning_count"),
                "error_count": validation.get("error_count"),
            },
        )

        # --------------------------------------------------------------
        # 4. Stage manifest and status.
        # --------------------------------------------------------------
        layout.write_stage_manifest(
            stage,
            primary_evidence_inputs=[
                str(cfg.run_dir / "stages"),
                str(cfg.run_dir / "events.jsonl"),
            ],
            deterministic_reference_outputs=paths,
            validation_outputs=validation_paths,
            notes={
                "agent_version": "agent10_experiment_logger_refactored.v1",
                "stage_type": "deterministic_only",
                "llm_used": False,
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
                "integrity_validation_status": validation.get("validation_status"),
                "formal_truth_claimed": False,
                "output_category_note": "Agent 10 experiment_log_outputs are recorded under deterministic_reference_outputs for RunLayout compatibility.",
            },
        )

        stage_status["success"] = True
        stage_status["handoff_available"] = True
        stage_status["completed_utc"] = utc_now_iso()
        stage_status["integrity_validation_status"] = validation.get("validation_status")
        stage_status["warning_count"] = validation.get("warning_count")
        stage_status["error_count"] = validation.get("error_count")

        atomic_write_json(layout.logs_dir(stage) / "10_experiment_logger_status.json", stage_status)

        layout.log_event(
            event_type="stage_completed",
            stage=stage,
            message="Agent 10 Experiment Logger completed.",
            data={
                "success": True,
                "integrity_validation_status": validation.get("validation_status"),
                "warning_count": validation.get("warning_count"),
                "error_count": validation.get("error_count"),
            },
        )

        # Agent completion is success if log created, even with integrity warnings.
        # If strict mode and errors exist, return 2.
        if cfg.strict_required_stages and validation.get("error_count", 0) > 0:
            return 2
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
        atomic_write_json(layout.logs_dir(stage) / "10_experiment_logger_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 10 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        try:
            layout.write_stage_manifest(
                stage,
                notes={
                    "agent_version": "agent10_experiment_logger_refactored.v1",
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
    parser = argparse.ArgumentParser(description="Agent 10 — deterministic Experiment Logger Agent")
    parser.add_argument("--config", help="Path to run config JSON.")
    parser.add_argument("--run-dir", help="Override run directory.")
    parser.add_argument("--target-function", help="Implementation function name, e.g. mlk_poly_add.")
    parser.add_argument("--target-topic", help="Human-readable target topic.")
    parser.add_argument("--strict-required-stages", action="store_true", help="Return non-zero if required stage evidence is missing.")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    config_data, cfg = load_config(args)
    return run_agent10(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
