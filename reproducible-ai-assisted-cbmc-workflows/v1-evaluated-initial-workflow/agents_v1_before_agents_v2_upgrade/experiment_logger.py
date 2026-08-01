#!/usr/bin/env python3
"""
Experiment Logger Agent
=======================

Agent 10 in the fully automated agentic workflow for AI-assisted
formal-verification artifact generation.

Purpose
-------
This agent records the full experiment trail for one workflow run. It does not
prove the target implementation and it does not decide scientific correctness.
It creates a reproducible, inspectable log of what happened in the run:

- original/resolved configuration
- selected inputs and source references
- prompts sent to model/API layers, when present
- deterministic/LLM outputs from previous agents
- generated candidate formal-verification artifacts
- critic review output
- CBMC/formal-tool commands and raw outputs
- counterexample analysis
- repair/refinement artifacts and notes
- status files, events, warnings, and missing outputs
- SHA-256 checksums for reproducibility
- a human-notes template for final researcher review

Thesis guardrail
----------------
The logger intentionally labels generated artifacts as *candidate* artifacts.
A CBMC success is recorded only as success for the selected harness/property
under the recorded assumptions; it is not treated as full proof of ML-KEM.
Human review remains mandatory.

Example
-------
python3 agents/experiment_logger.py \
  --config configs/poly_add_run.json \
  --run-dir runs/run_001_poly_add

Optional reproducibility bundle:
python3 agents/experiment_logger.py \
  --config configs/poly_add_run.json \
  --run-dir runs/run_001_poly_add \
  --bundle
"""

from __future__ import annotations

import argparse
import csv
import datetime as _dt
import hashlib
import json
import os
import re
import shutil
import sys
import zipfile
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple


AGENT_NAME = "experiment_logger_agent"
AGENT_NUMBER = "09"
SCHEMA_VERSION = "1.0.0"

# Standard outputs promised by the pipeline so far. The logger treats missing
# files as research-visible facts, not as reasons to fake a successful run.
EXPECTED_CORE_FILES: List[str] = [
    "01_spec_summary.json",
    "01_spec_summary.md",
    "02_code_summary.json",
    "02_code_summary.md",
    "03_candidate_properties.json",
    "03_candidate_properties.md",
    "04_generated_harness.c",
    "04_artifact_manifest.json",
    "04_generated_harness.md",
    "05_critic_review.json",
    "05_critic_review.md",
    "06_cbmc_command.txt",
    "06_cbmc_output.txt",
    "06_cbmc_status.json",
    "06_tool_execution.md",
    "06_cbmc_property_results.json",
    "07_counterexample_analysis.json",
    "07_counterexample_analysis.md",
    "08_repaired_harness.c",
    "08_repair_notes.json",
    "08_repair_notes.md",
    "08_repair_patch.diff",
]

PROMISED_AGENT_ORDER: List[Tuple[str, str, str]] = [
    ("01", "spec_extraction_agent", "Specification Extraction Agent"),
    ("02", "code_understanding_agent", "Code Understanding Agent"),
    ("03", "property_discovery_agent", "Property Discovery Agent"),
    ("04", "artifact_generation_agent", "Formal Artifact Generation Agent"),
    ("05", "review_critic_agent", "Review / Critic Agent"),
    ("06", "tool_execution_agent", "Formal Tool Execution Agent"),
    ("07", "counterexample_analysis_agent", "Counterexample Analysis Agent"),
    ("08", "repair_agent", "Repair / Refinement Agent"),
    ("09", "experiment_logger_agent", "Experiment Logger Agent"),
    ("10", "evaluation_reporter_agent", "Evaluation and Reporting Agent"),
]

TEXT_SUFFIXES = {
    ".txt", ".md", ".json", ".jsonl", ".c", ".h", ".py", ".csv",
    ".diff", ".patch", ".toml", ".yaml", ".yml", ".ini", ".log",
}

LARGE_FILE_BYTES = 5 * 1024 * 1024


@dataclass
class FileRecord:
    rel_path: str
    category: str
    suffix: str
    size_bytes: int
    sha256: str
    modified_utc: str
    preview: Optional[str] = None


@dataclass
class StageRecord:
    stage_number: str
    agent_name: str
    human_name: str
    expected_outputs: List[str]
    present_outputs: List[str]
    missing_outputs: List[str]
    status: str
    status_source: Optional[str]
    main_summary: Dict[str, Any]


# ---------------------------------------------------------------------------
# General utilities
# ---------------------------------------------------------------------------


def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


def safe_read_text(path: Path, max_chars: Optional[int] = None) -> str:
    try:
        data = path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return ""
    except Exception as exc:  # keep logger resilient
        return f"[LOGGER_READ_ERROR: {type(exc).__name__}: {exc}]"
    if max_chars is not None and len(data) > max_chars:
        return data[:max_chars] + f"\n...[truncated by logger after {max_chars} chars]"
    return data


def safe_read_json(path: Path) -> Dict[str, Any]:
    if not path.exists():
        return {}
    try:
        raw = path.read_text(encoding="utf-8", errors="replace")
        obj = json.loads(raw)
        if isinstance(obj, dict):
            return obj
        return {"_non_object_json": obj}
    except Exception as exc:
        return {"_json_read_error": f"{type(exc).__name__}: {exc}"}


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def write_text(path: Path, data: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(data, encoding="utf-8")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def modified_utc(path: Path) -> str:
    ts = path.stat().st_mtime
    return _dt.datetime.fromtimestamp(ts, _dt.timezone.utc).isoformat(timespec="seconds")


def load_config(config_path: Path) -> Dict[str, Any]:
    cfg = safe_read_json(config_path)
    if not cfg:
        raise SystemExit(f"[ERROR] Could not read config JSON: {config_path}")
    if "_json_read_error" in cfg:
        raise SystemExit(f"[ERROR] Invalid config JSON: {cfg['_json_read_error']}")
    return cfg


def infer_project_root(config_path: Path, run_dir: Path) -> Path:
    # Common layout: thesis-agent-workflow/configs/foo.json and thesis-agent-workflow/runs/run_x
    if config_path.parent.name == "configs":
        return config_path.parent.parent.resolve()
    # fallback: parent of run directory's parent if run_dir is runs/<run>
    if run_dir.parent.name == "runs":
        return run_dir.parent.parent.resolve()
    return Path.cwd().resolve()


def resolve_possible_path(project_root: Path, config_path: Path, raw: Optional[str]) -> Optional[Path]:
    if not raw:
        return None
    p = Path(raw).expanduser()
    if p.is_absolute():
        return p
    # Try project root first, then config directory.
    cand = project_root / p
    if cand.exists():
        return cand.resolve()
    return (config_path.parent / p).resolve()


def append_event(run_dir: Path, event_type: str, details: Dict[str, Any], status: str = "info") -> None:
    events_path = run_dir / "events.jsonl"
    events_path.parent.mkdir(parents=True, exist_ok=True)
    record = {
        "timestamp_utc": utc_now(),
        "agent": AGENT_NAME,
        "event_type": event_type,
        "status": status,
        "details": details,
    }
    with events_path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")


# ---------------------------------------------------------------------------
# File discovery and categorisation
# ---------------------------------------------------------------------------


def should_skip_for_index(path: Path, run_dir: Path) -> bool:
    try:
        rel = path.relative_to(run_dir)
    except ValueError:
        return True
    parts = set(rel.parts)
    if ".git" in parts or "__pycache__" in parts:
        return True
    if path.suffix.lower() in {".pyc", ".pyo"}:
        return True
    # Avoid recursively indexing previously generated zip bundles as core evidence.
    if path.suffix.lower() == ".zip":
        return True
    return False


def categorize_path(rel_path: str) -> str:
    p = rel_path.replace("\\", "/")
    name = Path(p).name.lower()
    suffix = Path(p).suffix.lower()

    if p.startswith("input/") or p.startswith("inputs/"):
        return "input_snapshot"
    if p.startswith("llm_prompts/") or "prompt" in name:
        return "prompt"
    if p.startswith("llm_outputs/"):
        return "llm_output"
    if p.startswith("tool_outputs/") or "cbmc_output" in name or "cbmc_command" in name:
        return "tool_output"
    if p.startswith("agent_status/") or name.endswith("_status.json") or name == "status.json":
        return "agent_status"
    if p.startswith("repairs/") or "repair" in name:
        return "repair"
    if p.startswith("evaluation/") or "evaluation" in name:
        return "evaluation"
    if "generated_harness" in name or suffix in {".c", ".h"}:
        return "formal_artifact_or_code"
    if name.endswith("config.json") or "config" in name:
        return "configuration"
    if name == "events.jsonl":
        return "event_log"
    if "human_notes" in name:
        return "human_notes"
    if suffix == ".md":
        return "markdown_summary"
    if suffix == ".json":
        return "structured_output"
    return "other"


def build_preview(path: Path, max_preview_chars: int) -> Optional[str]:
    suffix = path.suffix.lower()
    if suffix not in TEXT_SUFFIXES:
        return None
    if path.stat().st_size > LARGE_FILE_BYTES:
        return "[large text file preview skipped]"
    text = safe_read_text(path, max_preview_chars)
    if not text:
        return ""
    # Keep previews readable and not too noisy.
    return text.strip()[:max_preview_chars]


def index_run_files(run_dir: Path, max_preview_chars: int) -> List[FileRecord]:
    records: List[FileRecord] = []
    if not run_dir.exists():
        return records
    for path in sorted(run_dir.rglob("*")):
        if not path.is_file():
            continue
        if should_skip_for_index(path, run_dir):
            continue
        rel = str(path.relative_to(run_dir))
        try:
            stat = path.stat()
            records.append(
                FileRecord(
                    rel_path=rel,
                    category=categorize_path(rel),
                    suffix=path.suffix.lower(),
                    size_bytes=stat.st_size,
                    sha256=sha256_file(path),
                    modified_utc=modified_utc(path),
                    preview=build_preview(path, max_preview_chars),
                )
            )
        except Exception as exc:
            records.append(
                FileRecord(
                    rel_path=rel,
                    category="index_error",
                    suffix=path.suffix.lower(),
                    size_bytes=-1,
                    sha256="",
                    modified_utc="",
                    preview=f"[index error: {type(exc).__name__}: {exc}]",
                )
            )
    return records


# ---------------------------------------------------------------------------
# Stage summaries
# ---------------------------------------------------------------------------


def expected_outputs_for_stage(stage_number: str) -> List[str]:
    mapping = {
        "01": ["01_spec_summary.json", "01_spec_summary.md"],
        "02": ["02_code_summary.json", "02_code_summary.md"],
        "03": ["03_candidate_properties.json", "03_candidate_properties.md"],
        "04": ["04_generated_harness.c", "04_artifact_manifest.json", "04_generated_harness.md"],
        "05": ["05_critic_review.json", "05_critic_review.md"],
        "06": ["06_cbmc_command.txt", "06_cbmc_output.txt", "06_cbmc_status.json"],
        "07": ["07_counterexample_analysis.json", "07_counterexample_analysis.md"],
        "08": ["08_repaired_harness.c", "08_repair_notes.json", "08_repair_notes.md"],
        "09": ["09_experiment_log.json", "09_experiment_log.md", "09_file_index.csv"],
        "10": ["10_evaluation_report.json", "10_evaluation_report.md"],
    }
    return mapping.get(stage_number, [])


def status_file_for_stage(run_dir: Path, stage_number: str) -> Optional[Path]:
    status_dir = run_dir / "agent_status"
    if not status_dir.exists():
        return None
    # Use naming conventions from previous agents and tolerate variants.
    candidates = sorted(status_dir.glob(f"{stage_number}_*.json"))
    if candidates:
        return candidates[0]
    return None


def summarize_json_file(path: Path) -> Dict[str, Any]:
    obj = safe_read_json(path)
    if not obj:
        return {}

    # Keep summaries compact and stable. Do not copy huge generated content.
    keys_of_interest = [
        "target_function", "function", "target_scheme", "status", "review_status",
        "decision", "tool_execution_allowed", "highest_severity", "verification_status",
        "cbmc_status", "result", "failed_property", "counterexample_available",
        "failure_type", "primary_failure_type", "recommended_next_agent", "repair_possible",
        "changes_made", "warnings", "uncertainties", "human_review_required",
    ]
    summary: Dict[str, Any] = {}
    for key in keys_of_interest:
        if key in obj:
            summary[key] = obj[key]

    # Add counts for common list fields.
    for key in [
        "constants", "input_assumptions", "candidate_output_guarantees",
        "candidate_safety_properties", "candidate_functional_properties",
        "candidate_properties", "rejected_properties", "issues", "recommended_fix",
        "array_accesses", "loops", "helper_calls", "risks", "repair_guidance",
        "failed_properties", "property_results",
    ]:
        if key in obj:
            value = obj[key]
            if isinstance(value, dict):
                summary[f"{key}_count"] = len(value)
            elif isinstance(value, list):
                summary[f"{key}_count"] = len(value)

    return summary


def summarize_stage(run_dir: Path, stage_number: str, agent_name: str, human_name: str) -> StageRecord:
    expected = expected_outputs_for_stage(stage_number)
    present = [p for p in expected if (run_dir / p).exists()]
    missing = [p for p in expected if not (run_dir / p).exists()]
    status_source = None
    status = "not_run"
    main_summary: Dict[str, Any] = {}

    sfile = status_file_for_stage(run_dir, stage_number)
    if sfile and sfile.exists():
        status_source = str(sfile.relative_to(run_dir))
        sobj = safe_read_json(sfile)
        status = str(sobj.get("status") or sobj.get("agent_status") or "completed_with_unknown_status")
        main_summary["status_file"] = summarize_json_file(sfile)
    elif present and not missing:
        status = "completed_outputs_present"
    elif present and missing:
        status = "partial_outputs_present"
    elif stage_number in {"07", "08"}:
        # Counterexample/repair only run when needed, so missing may be valid.
        status = "not_required_or_not_run"
    elif stage_number == "10":
        status = "future_stage_not_run_yet"

    # Add summary from the primary JSON output if available.
    primary_json = {
        "01": "01_spec_summary.json",
        "02": "02_code_summary.json",
        "03": "03_candidate_properties.json",
        "04": "04_artifact_manifest.json",
        "05": "05_critic_review.json",
        "06": "06_cbmc_status.json",
        "07": "07_counterexample_analysis.json",
        "08": "08_repair_notes.json",
        "09": "09_experiment_log.json",
        "10": "10_evaluation_report.json",
    }.get(stage_number)
    if primary_json and (run_dir / primary_json).exists():
        main_summary["primary_output"] = summarize_json_file(run_dir / primary_json)

    return StageRecord(
        stage_number=stage_number,
        agent_name=agent_name,
        human_name=human_name,
        expected_outputs=expected,
        present_outputs=present,
        missing_outputs=missing,
        status=status,
        status_source=status_source,
        main_summary=main_summary,
    )


def build_stage_records(run_dir: Path) -> List[StageRecord]:
    return [summarize_stage(run_dir, num, name, human) for num, name, human in PROMISED_AGENT_ORDER]


# ---------------------------------------------------------------------------
# Higher-level summaries
# ---------------------------------------------------------------------------


def read_events(run_dir: Path, limit: Optional[int] = None) -> List[Dict[str, Any]]:
    path = run_dir / "events.jsonl"
    if not path.exists():
        return []
    events: List[Dict[str, Any]] = []
    for line in safe_read_text(path).splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
            if isinstance(obj, dict):
                events.append(obj)
        except json.JSONDecodeError:
            events.append({"parse_error": line[:500]})
    if limit is not None and len(events) > limit:
        return events[-limit:]
    return events


def summarize_config(config: Dict[str, Any]) -> Dict[str, Any]:
    # Avoid leaking API keys/secrets if config ever contains them.
    redacted: Dict[str, Any] = {}
    sensitive_patterns = re.compile(r"(api|token|secret|key|password)", re.IGNORECASE)
    for k, v in config.items():
        if sensitive_patterns.search(str(k)):
            redacted[k] = "[REDACTED_BY_EXPERIMENT_LOGGER]"
        else:
            redacted[k] = v
    return {
        "target_scheme": redacted.get("target_scheme"),
        "target_function": redacted.get("target_function"),
        "source_file": redacted.get("source_file"),
        "header_files": redacted.get("header_files"),
        "spec_file": redacted.get("spec_file"),
        "verification_tool": redacted.get("verification_tool", "CBMC"),
        "artifact_type": redacted.get("artifact_type", "CBMC harness"),
        "max_iterations": redacted.get("max_iterations"),
        "run_id": redacted.get("run_id"),
        "redacted_config": redacted,
    }


def load_cbmc_summary(run_dir: Path) -> Dict[str, Any]:
    status = safe_read_json(run_dir / "06_cbmc_status.json")
    prop = safe_read_json(run_dir / "06_cbmc_property_results.json")
    cmd = safe_read_text(run_dir / "06_cbmc_command.txt", max_chars=3000).strip()
    output = safe_read_text(run_dir / "06_cbmc_output.txt", max_chars=6000)
    return {
        "status_file_present": bool(status),
        "status": status,
        "property_results_present": bool(prop),
        "property_results_summary": summarize_json_file(run_dir / "06_cbmc_property_results.json"),
        "command": cmd,
        "raw_output_preview": output,
    }


def load_critic_summary(run_dir: Path) -> Dict[str, Any]:
    critic = safe_read_json(run_dir / "05_critic_review.json")
    if not critic:
        return {"present": False}
    issues = critic.get("issues", [])
    by_severity: Dict[str, int] = {}
    if isinstance(issues, list):
        for issue in issues:
            if isinstance(issue, dict):
                sev = str(issue.get("severity", "unknown"))
                by_severity[sev] = by_severity.get(sev, 0) + 1
    return {
        "present": True,
        "review_status": critic.get("review_status") or critic.get("status"),
        "decision": critic.get("decision"),
        "tool_execution_allowed": critic.get("tool_execution_allowed"),
        "highest_severity": critic.get("highest_severity"),
        "issue_count": len(issues) if isinstance(issues, list) else None,
        "issues_by_severity": by_severity,
        "summary": summarize_json_file(run_dir / "05_critic_review.json"),
    }


def load_counterexample_summary(run_dir: Path) -> Dict[str, Any]:
    ce = safe_read_json(run_dir / "07_counterexample_analysis.json")
    if not ce:
        return {"present": False, "note": "No counterexample analysis file found. This may be acceptable if CBMC did not fail or the tool was not run."}
    return {
        "present": True,
        "failure_type": ce.get("failure_type") or ce.get("primary_failure_type"),
        "recommended_next_agent": ce.get("recommended_next_agent"),
        "repair_guidance_count": len(ce.get("repair_guidance", [])) if isinstance(ce.get("repair_guidance"), list) else None,
        "summary": summarize_json_file(run_dir / "07_counterexample_analysis.json"),
    }


def load_repair_summary(run_dir: Path) -> Dict[str, Any]:
    repair = safe_read_json(run_dir / "08_repair_notes.json")
    if not repair:
        return {"present": False, "note": "No repair notes found. This may be acceptable if repair was not required."}
    changes = repair.get("changes_made", [])
    return {
        "present": True,
        "repair_possible": repair.get("repair_possible"),
        "changes_count": len(changes) if isinstance(changes, list) else None,
        "summary": summarize_json_file(run_dir / "08_repair_notes.json"),
    }


def missing_expected_files(run_dir: Path) -> List[str]:
    return [rel for rel in EXPECTED_CORE_FILES if not (run_dir / rel).exists()]


def create_human_notes_template(path: Path, config_summary: Dict[str, Any]) -> bool:
    if path.exists():
        return False
    target = config_summary.get("target_function") or "selected_function"
    tool = config_summary.get("verification_tool") or "CBMC"
    text = f"""# Human Notes for Experiment Run

Generated by: {AGENT_NAME}  
Generated at UTC: {utc_now()}

## Target

- Scheme: {config_summary.get('target_scheme') or 'not specified'}
- Function/component: {target}
- Verification tool: {tool}
- Artifact type: {config_summary.get('artifact_type') or 'not specified'}

## Human Review Checklist

Please review and fill this section manually.

1. Are the specification excerpts sufficient for the selected function?
2. Are the extracted constants and assumptions justified by the specification/code?
3. Are the generated CBMC assumptions too strong, too weak, or reasonable?
4. Are the generated assertions meaningful for the selected function?
5. Did {tool} parse and run the artifact correctly?
6. If verification failed, was the failure due to:
   - bad harness,
   - bad assumption,
   - too-strong assertion,
   - tool configuration problem,
   - missing dependency,
   - or possible implementation behavior?
7. Was the repair/refinement step scientifically justified?
8. What manual corrections were required?
9. What should be reported as a limitation?

## Researcher Notes

- Add observations here.

## Final Human Judgment

- [ ] Artifact useful as a starting point
- [ ] Artifact not useful
- [ ] Needs more correction
- [ ] Suitable for thesis evaluation table

Important: This note does not certify full implementation correctness. It records human judgment for this selected experiment only.
"""
    write_text(path, text)
    return True


# ---------------------------------------------------------------------------
# Output generation
# ---------------------------------------------------------------------------


def write_file_index_csv(path: Path, records: List[FileRecord]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["rel_path", "category", "suffix", "size_bytes", "sha256", "modified_utc"],
        )
        writer.writeheader()
        for rec in records:
            row = asdict(rec)
            row.pop("preview", None)
            writer.writerow(row)


def write_checksums(path: Path, records: List[FileRecord]) -> None:
    lines = []
    for rec in sorted(records, key=lambda r: r.rel_path):
        if rec.sha256:
            lines.append(f"{rec.sha256}  {rec.rel_path}")
    write_text(path, "\n".join(lines) + "\n")


def stage_status_icon(status: str) -> str:
    lowered = status.lower()
    if "completed" in lowered or lowered in {"success", "passed", "ok"}:
        return "✅"
    if "partial" in lowered or "warning" in lowered or "conditional" in lowered:
        return "⚠️"
    if "future" in lowered or "not_required" in lowered:
        return "➖"
    if "error" in lowered or "failed" in lowered or "reject" in lowered:
        return "❌"
    return "•"


def build_markdown_report(experiment_log: Dict[str, Any]) -> str:
    cfg = experiment_log["config_summary"]
    stages = experiment_log["stage_summary"]
    missing = experiment_log["missing_expected_files"]
    critic = experiment_log["critic_summary"]
    cbmc = experiment_log["cbmc_summary"]
    ce = experiment_log["counterexample_summary"]
    repair = experiment_log["repair_summary"]

    lines: List[str] = []
    lines.append("# Experiment Log")
    lines.append("")
    lines.append(f"Generated by: `{AGENT_NAME}`")
    lines.append(f"Generated at UTC: `{experiment_log['generated_at_utc']}`")
    lines.append(f"Run ID: `{experiment_log['run_id']}`")
    lines.append("")
    lines.append("## Thesis Guardrail")
    lines.append("")
    lines.append("This run records candidate formal-verification artifacts only. A generated harness, repaired harness, or selected CBMC result must not be reported as a full proof of ML-KEM. Formal-tool output and human review remain the final authority for the selected property and assumptions.")
    lines.append("")
    lines.append("## Target Configuration")
    lines.append("")
    lines.append(f"- Scheme: `{cfg.get('target_scheme')}`")
    lines.append(f"- Target function: `{cfg.get('target_function')}`")
    lines.append(f"- Source file: `{cfg.get('source_file')}`")
    lines.append(f"- Spec file: `{cfg.get('spec_file')}`")
    lines.append(f"- Verification tool: `{cfg.get('verification_tool')}`")
    lines.append(f"- Artifact type: `{cfg.get('artifact_type')}`")
    lines.append(f"- Max iterations: `{cfg.get('max_iterations')}`")
    lines.append("")

    lines.append("## Agent Stage Summary")
    lines.append("")
    lines.append("| Stage | Agent | Status | Present outputs | Missing outputs |")
    lines.append("|---:|---|---|---:|---:|")
    for st in stages:
        lines.append(
            f"| {st['stage_number']} | {st['human_name']} | {stage_status_icon(st['status'])} `{st['status']}` | {len(st['present_outputs'])} | {len(st['missing_outputs'])} |"
        )
    lines.append("")

    lines.append("## Critic Review Summary")
    lines.append("")
    if critic.get("present"):
        lines.append(f"- Review status: `{critic.get('review_status')}`")
        lines.append(f"- Decision: `{critic.get('decision')}`")
        lines.append(f"- Tool execution allowed: `{critic.get('tool_execution_allowed')}`")
        lines.append(f"- Highest severity: `{critic.get('highest_severity')}`")
        lines.append(f"- Issue count: `{critic.get('issue_count')}`")
        lines.append(f"- Issues by severity: `{critic.get('issues_by_severity')}`")
    else:
        lines.append("- Critic review file not found.")
    lines.append("")

    lines.append("## Formal Tool Execution Summary")
    lines.append("")
    cbmc_status = cbmc.get("status") if isinstance(cbmc.get("status"), dict) else {}
    if cbmc_status:
        for key in ["tool", "status", "verification_status", "result", "target_function", "counterexample_available", "runtime_seconds", "exit_code"]:
            if key in cbmc_status:
                lines.append(f"- {key}: `{cbmc_status.get(key)}`")
    else:
        lines.append("- CBMC status file not found or empty.")
    command = cbmc.get("command")
    if command:
        lines.append("")
        lines.append("Command:")
        lines.append("```bash")
        lines.append(command)
        lines.append("```")
    lines.append("")

    lines.append("## Counterexample / Failure Analysis Summary")
    lines.append("")
    if ce.get("present"):
        lines.append(f"- Failure type: `{ce.get('failure_type')}`")
        lines.append(f"- Recommended next agent: `{ce.get('recommended_next_agent')}`")
        lines.append(f"- Repair guidance count: `{ce.get('repair_guidance_count')}`")
    else:
        lines.append(f"- {ce.get('note')}")
    lines.append("")

    lines.append("## Repair Summary")
    lines.append("")
    if repair.get("present"):
        lines.append(f"- Repair possible: `{repair.get('repair_possible')}`")
        lines.append(f"- Changes count: `{repair.get('changes_count')}`")
    else:
        lines.append(f"- {repair.get('note')}")
    lines.append("")

    lines.append("## Missing Expected Files")
    lines.append("")
    if missing:
        for item in missing:
            lines.append(f"- `{item}`")
    else:
        lines.append("No expected core files are missing.")
    lines.append("")

    lines.append("## Reproducibility Outputs")
    lines.append("")
    lines.append("- `09_experiment_log.json` — structured experiment log")
    lines.append("- `09_experiment_log.md` — readable experiment report")
    lines.append("- `09_file_index.csv` — file index with SHA-256 hashes")
    lines.append("- `09_checksums.sha256` — checksum list")
    lines.append("- `human_notes.md` — manual researcher review template")
    lines.append("")

    lines.append("## Required Human Review")
    lines.append("")
    lines.append("Human review is required before using any generated artifact or result as thesis evidence. In particular, assumptions, assertions, CBMC command settings, and repaired harness changes must be checked manually.")
    lines.append("")
    return "\n".join(lines)


def make_bundle(run_dir: Path, bundle_path: Path, include_large: bool = False) -> None:
    bundle_path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(bundle_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(run_dir.rglob("*")):
            if not path.is_file():
                continue
            if should_skip_for_index(path, run_dir):
                continue
            if not include_large and path.stat().st_size > LARGE_FILE_BYTES:
                continue
            rel = str(path.relative_to(run_dir))
            zf.write(path, arcname=rel)


def write_agent_status(run_dir: Path, status: str, details: Dict[str, Any]) -> None:
    data = {
        "agent": AGENT_NAME,
        "agent_number": AGENT_NUMBER,
        "status": status,
        "generated_at_utc": utc_now(),
        "details": details,
        "human_review_required": True,
    }
    write_json(run_dir / "agent_status" / "09_experiment_logger_status.json", data)


def write_prompt_record(run_dir: Path) -> None:
    prompt = """Experiment Logger Agent task record

Task:
Collect the full evidence trail for this workflow run, including configuration, agent outputs, prompts, generated candidate formal-verification artifacts, CBMC commands/results, counterexample analysis, repair notes, file hashes, missing files, and human-review requirements.

Important constraints:
- Do not claim the generated artifacts prove full ML-KEM correctness.
- Treat all LLM/deterministic generated artifacts as candidate artifacts.
- Preserve failures and missing files as scientific evidence.
- Require human review for assumptions, assertions, tool configuration, and final interpretation.
"""
    write_text(run_dir / "llm_prompts" / "09_experiment_logger_prompt.txt", prompt)


# ---------------------------------------------------------------------------
# Main agent logic
# ---------------------------------------------------------------------------


def run_logger(args: argparse.Namespace) -> int:
    config_path = Path(args.config).expanduser().resolve()
    run_dir = Path(args.run_dir).expanduser().resolve()
    run_dir.mkdir(parents=True, exist_ok=True)

    config = load_config(config_path)
    project_root = infer_project_root(config_path, run_dir)
    config_summary = summarize_config(config)
    run_id = str(config.get("run_id") or run_dir.name)

    append_event(run_dir, "logger_started", {"run_id": run_id, "config": str(config_path)}, status="started")
    write_prompt_record(run_dir)

    # Create a human notes template early so it is included in the file index.
    human_notes_created = create_human_notes_template(run_dir / "human_notes.md", config_summary)

    records = index_run_files(run_dir, max_preview_chars=args.max_preview_chars)
    stages = build_stage_records(run_dir)
    missing = missing_expected_files(run_dir)
    events = read_events(run_dir)

    source_file = resolve_possible_path(project_root, config_path, config.get("source_file"))
    spec_file = resolve_possible_path(project_root, config_path, config.get("spec_file"))
    header_files_raw = config.get("header_files") or []
    if isinstance(header_files_raw, str):
        header_files_raw = [header_files_raw]
    header_files = [resolve_possible_path(project_root, config_path, h) for h in header_files_raw]

    external_inputs: List[Dict[str, Any]] = []
    for label, path in [("source_file", source_file), ("spec_file", spec_file)]:
        if path is None:
            external_inputs.append({"label": label, "path": None, "exists": False})
        else:
            external_inputs.append({
                "label": label,
                "path": str(path),
                "exists": path.exists(),
                "sha256": sha256_file(path) if path.exists() and path.is_file() else None,
                "size_bytes": path.stat().st_size if path.exists() and path.is_file() else None,
            })
    for idx, path in enumerate(header_files):
        if path is None:
            external_inputs.append({"label": f"header_file_{idx}", "path": None, "exists": False})
        else:
            external_inputs.append({
                "label": f"header_file_{idx}",
                "path": str(path),
                "exists": path.exists(),
                "sha256": sha256_file(path) if path.exists() and path.is_file() else None,
                "size_bytes": path.stat().st_size if path.exists() and path.is_file() else None,
            })

    experiment_log: Dict[str, Any] = {
        "schema_version": SCHEMA_VERSION,
        "agent": AGENT_NAME,
        "agent_number": AGENT_NUMBER,
        "generated_at_utc": utc_now(),
        "run_id": run_id,
        "project_root": str(project_root),
        "run_dir": str(run_dir),
        "config_path": str(config_path),
        "config_summary": config_summary,
        "thesis_guardrails": {
            "llm_outputs_are_candidate_artifacts": True,
            "formal_tool_is_final_checker_for_selected_properties": True,
            "human_review_required": True,
            "no_full_mlkem_proof_claim": True,
            "failure_is_research_evidence": True,
        },
        "promised_agent_order": [
            {"stage_number": n, "agent_name": a, "human_name": h}
            for n, a, h in PROMISED_AGENT_ORDER
        ],
        "stage_summary": [asdict(s) for s in stages],
        "critic_summary": load_critic_summary(run_dir),
        "cbmc_summary": load_cbmc_summary(run_dir),
        "counterexample_summary": load_counterexample_summary(run_dir),
        "repair_summary": load_repair_summary(run_dir),
        "external_input_files": external_inputs,
        "file_index": [asdict(r) for r in records],
        "file_count": len(records),
        "missing_expected_files": missing,
        "events_count": len(events),
        "events_tail": events[-50:],
        "human_notes_created": human_notes_created,
        "reproducibility": {
            "checksums_file": "09_checksums.sha256",
            "file_index_csv": "09_file_index.csv",
            "file_index_json": "09_file_index.json",
            "bundle_created": False,
            "bundle_path": None,
        },
        "limitations": [
            "This log records what the workflow produced; it does not certify formal correctness.",
            "Missing files may mean a stage was not required, not yet implemented, failed, or intentionally skipped.",
            "Generated assumptions and assertions require human review before thesis interpretation.",
            "CBMC success, if present, applies only to the selected harness/property under recorded assumptions.",
        ],
        "recommended_next_step": "Run evaluation_reporter_agent after reviewing this log and human_notes.md.",
    }

    # Write structured outputs.
    write_json(run_dir / "09_experiment_log.json", experiment_log)
    write_json(run_dir / "09_file_index.json", [asdict(r) for r in records])
    write_file_index_csv(run_dir / "09_file_index.csv", records)
    write_checksums(run_dir / "09_checksums.sha256", records)
    write_text(run_dir / "09_experiment_log.md", build_markdown_report(experiment_log))

    # Re-index after logger outputs so the status can include them? We keep the main
    # log stable; this avoids self-referential hash churn. The checksum file is a
    # reproducibility snapshot before these last files were written.

    bundle_path = None
    if args.bundle:
        bundle_path = run_dir / "09_reproducibility_bundle.zip"
        make_bundle(run_dir, bundle_path, include_large=args.include_large)
        experiment_log["reproducibility"]["bundle_created"] = True
        experiment_log["reproducibility"]["bundle_path"] = str(bundle_path)
        # Update log to include bundle metadata. Do not re-hash the bundle inside itself.
        write_json(run_dir / "09_experiment_log.json", experiment_log)
        write_text(run_dir / "09_experiment_log.md", build_markdown_report(experiment_log))

    output_details = {
        "run_id": run_id,
        "file_count": len(records),
        "missing_expected_file_count": len(missing),
        "human_notes_created": human_notes_created,
        "outputs": [
            "09_experiment_log.json",
            "09_experiment_log.md",
            "09_file_index.json",
            "09_file_index.csv",
            "09_checksums.sha256",
            "human_notes.md",
        ],
    }
    if bundle_path:
        output_details["outputs"].append("09_reproducibility_bundle.zip")

    status = "completed_with_warnings" if missing else "completed"
    write_agent_status(run_dir, status, output_details)
    append_event(run_dir, "logger_finished", output_details, status=status)

    if args.strict and missing:
        print(f"[WARN] Experiment Logger completed, but {len(missing)} expected file(s) are missing.")
        for item in missing:
            print(f"  - {item}")
        print(f"[OK] Wrote experiment log: {run_dir / '09_experiment_log.json'}")
        return 2

    print(f"[OK] Experiment Logger wrote: {run_dir / '09_experiment_log.json'}")
    print(f"[OK] Markdown report: {run_dir / '09_experiment_log.md'}")
    print(f"[OK] File index: {run_dir / '09_file_index.csv'}")
    print("[NOTE] This log records candidate artifacts and tool results; human review remains required.")
    if missing:
        print(f"[WARN] Missing expected files recorded: {len(missing)}")
    if bundle_path:
        print(f"[OK] Reproducibility bundle: {bundle_path}")
    return 0


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Experiment Logger Agent for the AI-assisted formal-verification workflow."
    )
    parser.add_argument(
        "--config",
        required=True,
        help="Path to the workflow configuration JSON file.",
    )
    parser.add_argument(
        "--run-dir",
        required=True,
        help="Path to the run directory, e.g., runs/run_001_poly_add.",
    )
    parser.add_argument(
        "--iteration",
        type=int,
        default=None,
        help="Optional iteration number. Stored indirectly through existing files/events.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return non-zero if expected core files are missing.",
    )
    parser.add_argument(
        "--bundle",
        action="store_true",
        help="Create a zip reproducibility bundle of the run directory.",
    )
    parser.add_argument(
        "--include-large",
        action="store_true",
        help="Include files larger than 5 MiB in the optional zip bundle.",
    )
    parser.add_argument(
        "--max-preview-chars",
        type=int,
        default=1200,
        help="Maximum text preview length stored per indexed file in JSON output.",
    )
    return parser


def main(argv: Optional[List[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    try:
        return run_logger(args)
    except KeyboardInterrupt:
        print("[ERROR] Experiment Logger interrupted by user.", file=sys.stderr)
        return 130
    except Exception as exc:
        # Try to record failure if possible.
        run_dir_arg = getattr(args, "run_dir", None)
        if run_dir_arg:
            try:
                rd = Path(run_dir_arg).expanduser().resolve()
                rd.mkdir(parents=True, exist_ok=True)
                write_agent_status(rd, "failed", {"error": f"{type(exc).__name__}: {exc}"})
                append_event(rd, "logger_failed", {"error": f"{type(exc).__name__}: {exc}"}, status="failed")
            except Exception:
                pass
        print(f"[ERROR] Experiment Logger failed: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
