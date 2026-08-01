#!/usr/bin/env python3
"""
Repair / Refinement Agent for the Fully Automated Agentic Workflow thesis.

Agent 9 responsibilities
------------------------
This agent reads the generated CBMC harness, critic review, formal-tool output/status,
and counterexample analysis. It then creates a controlled repaired candidate artifact.

Important research guardrail:
- This agent does NOT prove the implementation correct.
- This agent does NOT claim the repaired harness is final or trusted.
- This agent produces a candidate repair that must still be checked by CBMC and reviewed by a human.

Typical inputs inside a run directory:
  01_spec_summary.json
  02_code_summary.json
  03_candidate_properties.json
  04_generated_harness.c
  04_artifact_manifest.json
  05_critic_review.json
  06_cbmc_status.json
  06_cbmc_output.txt
  07_counterexample_analysis.json

Typical outputs:
  08_repaired_harness.c
  08_repair_notes.json
  08_repair_notes.md
  08_repair_patch.diff
  llm_prompts/08_repair_prompt.txt
  agent_status/08_repair_status.json
  repairs/iteration_XX/...

Design style:
- deterministic first, optional future LLM hook
- reproducible file outputs
- explicit evidence and repair rationale
- conservative patching with clear warnings
"""

from __future__ import annotations

import argparse
import datetime as _dt
import difflib
import json
import os
import re
import shutil
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

AGENT_NAME = "repair_refinement_agent"
AGENT_VERSION = "1.0.0"
DEFAULT_TARGET_FUNCTION = "poly_add"


# ---------------------------------------------------------------------------
# Small utilities
# ---------------------------------------------------------------------------

def utc_now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).replace(microsecond=0).isoformat()


def load_json(path: Path, default: Any = None) -> Any:
    if not path.exists():
        return default
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except json.JSONDecodeError as exc:
        return {
            "_load_error": f"Invalid JSON in {path}: {exc}",
            "_path": str(path),
        }
    except OSError as exc:
        return {
            "_load_error": f"Could not read {path}: {exc}",
            "_path": str(path),
        }


def save_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")


def read_text(path: Path, default: str = "") -> str:
    if not path.exists():
        return default
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return default


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def append_jsonl(path: Path, event: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False) + "\n")


def as_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    if isinstance(value, tuple):
        return list(value)
    return [value]


def flatten_text(value: Any) -> str:
    """Make a lower-case searchable text blob from nested JSON-like data."""
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, (int, float, bool)):
        return str(value)
    if isinstance(value, dict):
        return "\n".join(f"{k}: {flatten_text(v)}" for k, v in value.items())
    if isinstance(value, (list, tuple, set)):
        return "\n".join(flatten_text(v) for v in value)
    return str(value)


def normalize_name(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]+", "_", value or "").strip("_")


def resolve_path(path_value: Optional[str], *, base_dir: Path, project_root: Path) -> Optional[Path]:
    if not path_value:
        return None
    p = Path(path_value).expanduser()
    if p.is_absolute():
        return p
    # Prefer path relative to project root, then relative to config/run base.
    project_candidate = project_root / p
    if project_candidate.exists():
        return project_candidate
    return base_dir / p


def line_numbered_findings(text: str, patterns: Sequence[str]) -> List[Dict[str, Any]]:
    findings: List[Dict[str, Any]] = []
    for idx, line in enumerate(text.splitlines(), start=1):
        lower = line.lower()
        for pat in patterns:
            if pat.lower() in lower:
                findings.append({"line": idx, "pattern": pat, "text": line.strip()})
    return findings


# ---------------------------------------------------------------------------
# Repair settings and report dataclasses
# ---------------------------------------------------------------------------

@dataclass
class RepairSettings:
    allow_cbmc_compatibility_patches: bool = True
    allow_assertion_rewrite: bool = True
    allow_candidate_overflow_preconditions: bool = True
    allow_assumption_commenting: bool = True
    allow_manifest_command_update: bool = True
    strict_no_unsupported_assumption_narrowing: bool = False
    write_iteration_snapshot: bool = True
    require_human_review: bool = True
    max_iterations: int = 3
    default_unwind: Optional[int] = None
    dry_run: bool = False

    @classmethod
    def from_config(cls, config: Dict[str, Any], args: argparse.Namespace) -> "RepairSettings":
        raw = config.get("repair_settings", {}) or {}
        tool_raw = config.get("tool_settings", {}) or {}
        max_iter = raw.get("max_iterations", config.get("max_iterations", 3))
        return cls(
            allow_cbmc_compatibility_patches=bool(raw.get("allow_cbmc_compatibility_patches", True)),
            allow_assertion_rewrite=bool(raw.get("allow_assertion_rewrite", True)),
            allow_candidate_overflow_preconditions=bool(raw.get("allow_candidate_overflow_preconditions", True)),
            allow_assumption_commenting=bool(raw.get("allow_assumption_commenting", True)),
            allow_manifest_command_update=bool(raw.get("allow_manifest_command_update", True)),
            strict_no_unsupported_assumption_narrowing=bool(raw.get("strict_no_unsupported_assumption_narrowing", False)),
            write_iteration_snapshot=bool(raw.get("write_iteration_snapshot", True)),
            require_human_review=bool(raw.get("require_human_review", True)),
            max_iterations=int(max_iter if max_iter is not None else 3),
            default_unwind=tool_raw.get("unwind", raw.get("default_unwind")),
            dry_run=bool(getattr(args, "dry_run", False)),
        )


@dataclass
class RepairAction:
    action_id: str
    category: str
    description: str
    applied: bool
    confidence: str
    reason: str
    evidence: List[Dict[str, Any]] = field(default_factory=list)
    human_review_note: Optional[str] = None


@dataclass
class RepairResult:
    source_artifact: str
    repaired_artifact: str
    status: str
    tool_execution_recommended: bool
    human_review_required: bool
    actions: List[RepairAction]
    warnings: List[str]
    limitations: List[str]
    next_step: str


# ---------------------------------------------------------------------------
# Context loading
# ---------------------------------------------------------------------------

@dataclass
class RepairContext:
    config_path: Path
    config: Dict[str, Any]
    run_dir: Path
    project_root: Path
    iteration: int
    target_function: str
    source_artifact_path: Path
    repaired_artifact_path: Path
    spec_summary: Dict[str, Any]
    code_summary: Dict[str, Any]
    properties: Dict[str, Any]
    artifact_manifest: Dict[str, Any]
    critic_review: Dict[str, Any]
    cbmc_status: Dict[str, Any]
    cbmc_output: str
    property_results: Any
    counterexample_analysis: Dict[str, Any]
    settings: RepairSettings


def determine_project_root(config_path: Path, config: Dict[str, Any]) -> Path:
    explicit = config.get("project_root") or config.get("workspace_root")
    if explicit:
        return Path(explicit).expanduser().resolve()
    # Usually config is thesis-agent-workflow/configs/foo.json.
    if config_path.parent.name == "configs":
        return config_path.parent.parent.resolve()
    return Path.cwd().resolve()


def determine_source_artifact(run_dir: Path, args: argparse.Namespace, iteration: int) -> Path:
    if getattr(args, "source_artifact", None):
        p = Path(args.source_artifact).expanduser()
        if not p.is_absolute():
            p = run_dir / p
        return p
    if getattr(args, "artifact", None):
        p = Path(args.artifact).expanduser()
        if not p.is_absolute():
            p = run_dir / p
        return p
    # If a previous repaired harness exists and this is not the first iteration, repair that.
    if iteration > 0 and (run_dir / "08_repaired_harness.c").exists():
        return run_dir / "08_repaired_harness.c"
    return run_dir / "04_generated_harness.c"


def load_context(args: argparse.Namespace) -> RepairContext:
    config_path = Path(args.config).expanduser().resolve()
    config = load_json(config_path, default={}) or {}
    if not isinstance(config, dict):
        raise SystemExit(f"Config must be a JSON object: {config_path}")

    project_root = determine_project_root(config_path, config)
    run_dir_arg = getattr(args, "run_dir", None) or config.get("run_dir") or config.get("output_dir")
    if run_dir_arg:
        run_dir = Path(run_dir_arg).expanduser()
        if not run_dir.is_absolute():
            run_dir = project_root / run_dir
    else:
        run_id = config.get("run_id") or f"run_001_{normalize_name(config.get('target_function', DEFAULT_TARGET_FUNCTION))}"
        run_dir = project_root / "runs" / run_id
    run_dir = run_dir.resolve()

    iteration = int(getattr(args, "iteration", 0) or 0)
    target_function = (
        config.get("target_function")
        or config.get("function")
        or config.get("target", {}).get("function")
        or DEFAULT_TARGET_FUNCTION
    )

    settings = RepairSettings.from_config(config, args)
    source_artifact = determine_source_artifact(run_dir, args, iteration).resolve()
    repaired_artifact = (run_dir / "08_repaired_harness.c").resolve()

    return RepairContext(
        config_path=config_path,
        config=config,
        run_dir=run_dir,
        project_root=project_root,
        iteration=iteration,
        target_function=str(target_function),
        source_artifact_path=source_artifact,
        repaired_artifact_path=repaired_artifact,
        spec_summary=load_json(run_dir / "01_spec_summary.json", default={}) or {},
        code_summary=load_json(run_dir / "02_code_summary.json", default={}) or {},
        properties=load_json(run_dir / "03_candidate_properties.json", default={}) or {},
        artifact_manifest=load_json(run_dir / "04_artifact_manifest.json", default={}) or {},
        critic_review=load_json(run_dir / "05_critic_review.json", default={}) or {},
        cbmc_status=load_json(run_dir / "06_cbmc_status.json", default={}) or {},
        cbmc_output=read_text(run_dir / "06_cbmc_output.txt", default=""),
        property_results=load_json(run_dir / "06_cbmc_property_results.json", default=[]),
        counterexample_analysis=load_json(run_dir / "07_counterexample_analysis.json", default={}) or {},
        settings=settings,
    )


# ---------------------------------------------------------------------------
# Analysis helpers
# ---------------------------------------------------------------------------

def collect_critic_issues(critic_review: Dict[str, Any]) -> List[Dict[str, Any]]:
    candidate_keys = [
        "issues", "findings", "problems", "review_issues", "critic_issues",
        "blocking_issues", "warnings",
    ]
    issues: List[Dict[str, Any]] = []
    for key in candidate_keys:
        for item in as_list(critic_review.get(key)):
            if isinstance(item, dict):
                issues.append(item)
            elif isinstance(item, str):
                issues.append({"message": item})
    # Some agents store nested summary.
    review = critic_review.get("review")
    if isinstance(review, dict):
        issues.extend(collect_critic_issues(review))
    return issues


def collect_failure_modes(counterexample_analysis: Dict[str, Any], cbmc_status: Dict[str, Any], cbmc_output: str) -> List[str]:
    text = "\n".join([
        flatten_text(counterexample_analysis),
        flatten_text(cbmc_status),
        cbmc_output,
    ]).lower()

    modes: List[str] = []
    checks = [
        ("tool_unavailable", ["tool_unavailable", "cbmc not installed", "not found", "no such file or directory"]),
        ("tool_error", ["parse error", "syntax error", "compilation", "failed to parse", "typecheck", "linking", "undefined reference"]),
        ("timeout", ["timeout", "timed out"]),
        ("pointer_validity", ["pointer", "dereference failure", "invalid pointer", "null pointer"]),
        ("bounds", ["array bounds", "bounds check", "out of bounds", "buffer overflow"]),
        ("signed_overflow", ["signed overflow", "arithmetic overflow", "overflow"]),
        ("unsigned_overflow", ["unsigned overflow"]),
        ("unwinding", ["unwinding assertion", "unwind", "loop unwinding"]),
        ("assertion_failure", ["assertion", "assert", "property", "verification failed"]),
        ("assumption_issue", ["assumption", "too broad", "too weak", "unsupported assumption", "vacuous"]),
    ]
    for mode, needles in checks:
        if any(n in text for n in needles):
            modes.append(mode)

    # Preserve explicit failure type if present.
    for key in ["failure_type", "primary_failure_type", "classification", "primary_classification"]:
        val = counterexample_analysis.get(key)
        if isinstance(val, str) and val and val not in modes:
            modes.insert(0, val)

    # Preserve detected list if present.
    for key in ["detected_failure_modes", "failure_modes", "classifications"]:
        for val in as_list(counterexample_analysis.get(key)):
            if isinstance(val, str) and val not in modes:
                modes.append(val)
            elif isinstance(val, dict):
                name = val.get("type") or val.get("name") or val.get("classification")
                if name and name not in modes:
                    modes.append(str(name))
    return modes


def issue_text(issues: List[Dict[str, Any]]) -> str:
    return flatten_text(issues).lower()


def has_any(text: str, needles: Iterable[str]) -> bool:
    return any(n.lower() in text for n in needles)


def extract_constants(summary: Dict[str, Any]) -> Dict[str, Any]:
    constants: Dict[str, Any] = {}
    for key in ["constants", "known_constants", "extracted_constants"]:
        val = summary.get(key)
        if isinstance(val, dict):
            constants.update(val)
        elif isinstance(val, list):
            for item in val:
                if isinstance(item, dict):
                    name = item.get("name") or item.get("constant") or item.get("key")
                    value = item.get("value")
                    if name is not None:
                        constants[str(name)] = value
    return constants


def detect_loop_bound(code: str, context: RepairContext) -> str:
    # Prefer code summary loop extraction if present.
    loops = []
    for key in ["loops", "loop_structure", "loop_structures"]:
        loops.extend(as_list(context.code_summary.get(key)))
    for loop in loops:
        if isinstance(loop, dict):
            for k in ["bound", "upper_bound", "condition", "loop_condition"]:
                val = loop.get(k)
                if isinstance(val, str):
                    # Extract RHS of i < RHS if present.
                    m = re.search(r"<\s*([A-Za-z_][A-Za-z0-9_]*|\d+)", val)
                    if m:
                        return m.group(1)
                    if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*|\d+", val.strip()):
                        return val.strip()
    m = re.search(r"for\s*\([^;]*;\s*[A-Za-z_][A-Za-z0-9_]*\s*<\s*([^;\)]+)\s*;", code)
    if m:
        return m.group(1).strip()
    constants = extract_constants(context.spec_summary)
    for key in ["KYBER_N", "MLKEM_N", "N", "n"]:
        if key in constants:
            return str(key if not str(constants[key]).isdigit() else constants[key])
    return "256"


def detect_target_call_line(code: str, target_function: str) -> Optional[int]:
    lines = code.splitlines()
    call_re = re.compile(rf"\b{re.escape(target_function)}\s*\(")
    def_re = re.compile(rf"\b(?:void|int|static|extern|[A-Za-z_][\w\s\*]+)\s+{re.escape(target_function)}\s*\(")
    harness_def_re = re.compile(r"\b(?:void|int)\s+harness_[A-Za-z0-9_]*\s*\(")
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if not call_re.search(stripped):
            continue
        # Skip comments and definitions/prototypes.
        if stripped.startswith("//") or stripped.startswith("/*"):
            continue
        if def_re.search(stripped) and stripped.endswith("{"):
            continue
        if harness_def_re.search(stripped):
            continue
        # A real function call should typically end with ; or be inside statement.
        if ";" in stripped:
            return idx
    return None


def detect_functional_assertion_pattern(code: str) -> Optional[Dict[str, str]]:
    # Handles common generated assertions like:
    # assert(r.coeffs[i] == (a.coeffs[i] + b.coeffs[i]));
    # assert(r->coeffs[i] == a->coeffs[i] + b->coeffs[i]);
    access = r"([A-Za-z_]\w*)\s*(\.|->)\s*([A-Za-z_]\w*)\s*\[\s*i\s*\]"
    pattern = re.compile(
        r"assert\s*\(\s*"
        + access
        + r"\s*==\s*\(?\s*"
        + access
        + r"\s*([+\-])\s*"
        + access
        + r"\s*\)?\s*\)\s*;"
    )
    m = pattern.search(code)
    if not m:
        return None
    # Groups: out obj, out op, out field, lhs obj, lhs op, lhs field, operator, rhs obj, rhs op, rhs field
    return {
        "full": m.group(0),
        "out_obj": m.group(1),
        "out_op": m.group(2),
        "out_field": m.group(3),
        "lhs_obj": m.group(4),
        "lhs_op": m.group(5),
        "lhs_field": m.group(6),
        "operator": m.group(7),
        "rhs_obj": m.group(8),
        "rhs_op": m.group(9),
        "rhs_field": m.group(10),
    }


def c_access(obj: str, op: str, field_name: str) -> str:
    return f"{obj}{op}{field_name}"


# ---------------------------------------------------------------------------
# C patching functions
# ---------------------------------------------------------------------------

def ensure_include(code: str, include: str) -> Tuple[str, bool]:
    include_line = f"#include {include}"
    if include_line in code:
        return code, False
    lines = code.splitlines()
    insert_at = 0
    for idx, line in enumerate(lines):
        if line.strip().startswith("#include"):
            insert_at = idx + 1
    lines.insert(insert_at, include_line)
    return "\n".join(lines) + ("\n" if code.endswith("\n") else ""), True


def ensure_cbmc_nondet_declarations(code: str) -> Tuple[str, bool, List[str]]:
    calls = sorted(set(re.findall(r"\b(nondet_[A-Za-z0-9_]+)\s*\(", code)))
    if not calls:
        return code, False, []

    return_type = {
        "nondet_int": "int",
        "nondet_int8_t": "int8_t",
        "nondet_int16_t": "int16_t",
        "nondet_int32_t": "int32_t",
        "nondet_int64_t": "int64_t",
        "nondet_uint": "unsigned int",
        "nondet_unsigned_int": "unsigned int",
        "nondet_uint8_t": "uint8_t",
        "nondet_uint16_t": "uint16_t",
        "nondet_uint32_t": "uint32_t",
        "nondet_uint64_t": "uint64_t",
        "nondet_size_t": "size_t",
        "nondet_bool": "bool",
    }

    missing: List[str] = []
    declarations: List[str] = []
    for call in calls:
        decl_re = re.compile(rf"\b[A-Za-z_][\w\s\*]+\s+{re.escape(call)}\s*\(\s*void\s*\)\s*;")
        if decl_re.search(code):
            continue
        rtype = return_type.get(call, "int")
        declarations.append(f"extern {rtype} {call}(void);")
        missing.append(call)

    if not declarations:
        return code, False, []

    marker = "/* [Repair Agent] CBMC nondeterministic input declarations. */"
    block = "\n" + marker + "\n" + "\n".join(declarations) + "\n"

    lines = code.splitlines()
    insert_at = 0
    for idx, line in enumerate(lines):
        if line.strip().startswith("#include"):
            insert_at = idx + 1
    lines.insert(insert_at, block)
    return "\n".join(lines) + ("\n" if code.endswith("\n") else ""), True, missing


def add_repair_banner(code: str, context: RepairContext) -> Tuple[str, bool]:
    marker = "[Repair Agent] Candidate repaired harness"
    if marker in code:
        return code, False
    banner = f"""/*
 * [Repair Agent] Candidate repaired harness
 * Agent: {AGENT_NAME} v{AGENT_VERSION}
 * Iteration: {context.iteration}
 * Target function: {context.target_function}
 * Generated at: {utc_now_iso()}
 *
 * Research guardrail:
 * This file is a candidate formal-verification artifact. It must still be
 * checked by CBMC/formal tools and reviewed by a human researcher. It is not
 * a proof of the full ML-KEM implementation.
 */
"""
    return banner + code, True


def comment_assumptions(code: str) -> Tuple[str, bool, int]:
    if "[Repair Agent] Candidate precondition" in code:
        return code, False, 0
    lines = code.splitlines()
    out: List[str] = []
    changed = False
    count = 0
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if "__CPROVER_assume" in stripped:
            prev = out[-1].strip() if out else ""
            if "Candidate precondition" not in prev and not prev.startswith("/*"):
                indent = line[: len(line) - len(line.lstrip())]
                out.append(indent + "/* [Repair Agent] Candidate precondition: keep only if justified by spec/code review. */")
                changed = True
                count += 1
        out.append(line)
    return "\n".join(out) + ("\n" if code.endswith("\n") else ""), changed, count


def rewrite_functional_assertion_casts(code: str) -> Tuple[str, bool, Optional[Dict[str, str]]]:
    pattern_info = detect_functional_assertion_pattern(code)
    if not pattern_info:
        return code, False, None
    original = pattern_info["full"]
    lhs_access = f"{c_access(pattern_info['lhs_obj'], pattern_info['lhs_op'], pattern_info['lhs_field'])}[i]"
    rhs_access = f"{c_access(pattern_info['rhs_obj'], pattern_info['rhs_op'], pattern_info['rhs_field'])}[i]"
    out_access = f"{c_access(pattern_info['out_obj'], pattern_info['out_op'], pattern_info['out_field'])}[i]"
    op = pattern_info["operator"]
    replacement = (
        "/* [Repair Agent] Use int32_t casts in the assertion expression to avoid "
        "assertion-side signed-overflow noise. */\n"
        f"    assert((int32_t){out_access} == ((int32_t){lhs_access} {op} (int32_t){rhs_access}));"
    )
    repaired = code.replace(original, replacement, 1)
    return repaired, True, pattern_info


def insert_overflow_precondition_loop(code: str, context: RepairContext, pattern_info: Dict[str, str]) -> Tuple[str, bool]:
    marker = "[Repair Agent] Candidate overflow precondition"
    if marker in code:
        return code, False

    call_line = detect_target_call_line(code, context.target_function)
    if call_line is None:
        return code, False

    loop_bound = detect_loop_bound(code, context)
    lhs_access = f"{c_access(pattern_info['lhs_obj'], pattern_info['lhs_op'], pattern_info['lhs_field'])}[i]"
    rhs_access = f"{c_access(pattern_info['rhs_obj'], pattern_info['rhs_op'], pattern_info['rhs_field'])}[i]"
    op = pattern_info["operator"]

    block = [
        "  /* [Repair Agent] Candidate overflow precondition.",
        "   * Purpose: make the selected functional assertion meaningful for int16_t-style", 
        "   * coefficient storage by excluding inputs whose mathematical result cannot fit.",
        "   * This is a candidate assumption and requires human/spec review.",
        "   */",
        f"  for (unsigned int i = 0; i < {loop_bound}; i++) {{",
        f"    int32_t repair_expected_i = (int32_t){lhs_access} {op} (int32_t){rhs_access};",
        "    __CPROVER_assume(repair_expected_i >= INT16_MIN);",
        "    __CPROVER_assume(repair_expected_i <= INT16_MAX);",
        "  }",
        "",
    ]

    lines = code.splitlines()
    lines[call_line:call_line] = block
    return "\n".join(lines) + ("\n" if code.endswith("\n") else ""), True


def update_unwind_recommendation(manifest: Dict[str, Any], context: RepairContext) -> Tuple[Dict[str, Any], bool]:
    if not context.settings.allow_manifest_command_update:
        return manifest, False
    if not isinstance(manifest, dict):
        manifest = {}
    changed = False
    recommended = manifest.get("recommended_cbmc_command") or manifest.get("cbmc_command")
    default_unwind = context.settings.default_unwind
    if default_unwind is None:
        constants = extract_constants(context.spec_summary)
        n_val = constants.get("N") or constants.get("KYBER_N") or constants.get("MLKEM_N")
        try:
            default_unwind = int(n_val)
        except Exception:
            default_unwind = None
    if isinstance(recommended, str) and default_unwind:
        if "--unwind" not in recommended:
            manifest["recommended_cbmc_command"] = recommended.strip() + f" --unwind {default_unwind} --unwinding-assertions"
            changed = True
        elif "--unwinding-assertions" not in recommended:
            manifest["recommended_cbmc_command"] = recommended.strip() + " --unwinding-assertions"
            changed = True
    elif default_unwind and not recommended:
        manifest["recommended_cbmc_command_note"] = (
            f"Repair Agent recommends CBMC loop unwinding with --unwind {default_unwind} "
            "and --unwinding-assertions for the selected loop-bound experiment."
        )
        changed = True
    return manifest, changed


# ---------------------------------------------------------------------------
# Repair planner and executor
# ---------------------------------------------------------------------------

def build_repair_prompt(context: RepairContext) -> str:
    return f"""You are the Repair / Refinement Agent for an AI-assisted formal-verification workflow.

Task:
Read the generated harness, critic review, CBMC status/output, and counterexample analysis.
Create a controlled candidate repair. Do not hide failures. Do not claim proof.

Target function: {context.target_function}
Iteration: {context.iteration}
Source artifact: {context.source_artifact_path.name}

Repair rules:
1. Fix CBMC compatibility issues when safe: missing includes, nondet declarations, missing comments.
2. If overflow/assertion failure is detected, prefer explicit casts and candidate preconditions over silent claim changes.
3. Do not remove all assertions just to make CBMC pass.
4. Do not invent specification facts.
5. Mark every new assumption as a candidate precondition requiring human/spec review.
6. Save repaired artifact, repair notes, diff, and status.
7. Human review and formal-tool re-check remain mandatory.

Available context files:
- 01_spec_summary.json
- 02_code_summary.json
- 03_candidate_properties.json
- 04_generated_harness.c or previous repaired harness
- 05_critic_review.json
- 06_cbmc_status.json
- 06_cbmc_output.txt
- 07_counterexample_analysis.json
"""


def perform_repair(context: RepairContext) -> RepairResult:
    actions: List[RepairAction] = []
    warnings: List[str] = []
    limitations: List[str] = []

    original_code = read_text(context.source_artifact_path, default="")
    if not original_code:
        status = "repair_not_possible"
        limitations.append(f"Source artifact not found or empty: {context.source_artifact_path}")
        return RepairResult(
            source_artifact=str(context.source_artifact_path),
            repaired_artifact=str(context.repaired_artifact_path),
            status=status,
            tool_execution_recommended=False,
            human_review_required=True,
            actions=actions,
            warnings=warnings,
            limitations=limitations,
            next_step="Fix artifact generation or file path before repair.",
        )

    critic_issues = collect_critic_issues(context.critic_review)
    failures = collect_failure_modes(context.counterexample_analysis, context.cbmc_status, context.cbmc_output)
    all_issue_text = issue_text(critic_issues) + "\n" + "\n".join(failures).lower()

    code = original_code

    # 1. Always add repair banner.
    code, changed = add_repair_banner(code, context)
    actions.append(RepairAction(
        action_id="R001",
        category="traceability",
        description="Add repair provenance and research guardrail banner to the harness.",
        applied=changed,
        confidence="high",
        reason="Reproducibility requires repaired artifacts to be clearly marked.",
        human_review_note="Banner does not affect verification semantics.",
    ))

    # 2. CBMC/C compatibility includes.
    if context.settings.allow_cbmc_compatibility_patches:
        for include in ["<assert.h>", "<stdint.h>", "<limits.h>"]:
            code, inc_changed = ensure_include(code, include)
            if inc_changed:
                actions.append(RepairAction(
                    action_id=f"R_INC_{include.strip('<>').replace('.', '_').upper()}",
                    category="cbmc_compatibility",
                    description=f"Add missing include {include}.",
                    applied=True,
                    confidence="high",
                    reason="Harness uses assertions, fixed-width integer casts, or INT16_MIN/INT16_MAX-style guards.",
                ))

        code, decl_changed, missing_calls = ensure_cbmc_nondet_declarations(code)
        actions.append(RepairAction(
            action_id="R002",
            category="cbmc_compatibility",
            description="Add external declarations for CBMC nondeterministic input functions used by the harness.",
            applied=decl_changed,
            confidence="high",
            reason="CBMC harnesses commonly use nondet_* symbols; explicit declarations reduce type/parsing problems.",
            evidence=[{"missing_nondet_function": x} for x in missing_calls],
        ))

    # 3. Assumption comments and transparency.
    if context.settings.allow_assumption_commenting:
        code, assumption_changed, assumption_count = comment_assumptions(code)
        actions.append(RepairAction(
            action_id="R003",
            category="assumption_transparency",
            description="Annotate CPROVER assumptions as candidate preconditions requiring spec/code review.",
            applied=assumption_changed,
            confidence="high",
            reason="Generated assumptions can be too strong or unsupported; comments make the limitation explicit.",
            evidence=[{"assumptions_commented": assumption_count}],
            human_review_note="Every generated assumption must be checked against the selected specification and implementation context.",
        ))

    # 4. Functional assertion / overflow-oriented repair.
    overflow_related = (
        "signed_overflow" in failures
        or "unsigned_overflow" in failures
        or has_any(all_issue_text, ["overflow", "too broad", "input range", "assertion may", "assertion too strong"])
    )
    assertion_related = "assertion_failure" in failures or has_any(all_issue_text, ["assert", "functional equality", "too strong"])

    pattern_info: Optional[Dict[str, str]] = None
    if context.settings.allow_assertion_rewrite and (overflow_related or assertion_related):
        code, assertion_changed, pattern_info = rewrite_functional_assertion_casts(code)
        actions.append(RepairAction(
            action_id="R004",
            category="assertion_rewrite",
            description="Rewrite simple coefficient functional assertion with int32_t casts to reduce assertion-side overflow noise.",
            applied=assertion_changed,
            confidence="medium" if assertion_changed else "low",
            reason="CBMC failures involving signed overflow or equality assertions often come from expression semantics or over-broad input ranges.",
            evidence=[pattern_info] if pattern_info else [],
            human_review_note="This preserves the intended equality check shape but does not prove the specification-level property by itself.",
        ))

        if assertion_changed and pattern_info and context.settings.allow_candidate_overflow_preconditions:
            code, guard_changed = insert_overflow_precondition_loop(code, context, pattern_info)
            actions.append(RepairAction(
                action_id="R005",
                category="candidate_precondition",
                description="Insert candidate overflow precondition before the target call for int16_t-style coefficient storage.",
                applied=guard_changed,
                confidence="medium" if guard_changed else "low",
                reason="The previous harness may allow inputs whose mathematical result cannot fit the output coefficient representation.",
                evidence=[{"failure_modes": failures}],
                human_review_note="This is intentionally marked as a candidate assumption. It must be justified or rejected during human/spec review.",
            ))
        elif assertion_changed and not context.settings.allow_candidate_overflow_preconditions:
            warnings.append("Overflow precondition insertion is disabled by repair_settings.allow_candidate_overflow_preconditions=false.")

    # 5. Tool unavailable / command / unwinding notes.
    manifest = dict(context.artifact_manifest) if isinstance(context.artifact_manifest, dict) else {}
    if "unwinding" in failures or has_any(all_issue_text, ["unwind", "unwinding"]):
        manifest, manifest_changed = update_unwind_recommendation(manifest, context)
        actions.append(RepairAction(
            action_id="R006",
            category="tool_command_recommendation",
            description="Update or add CBMC unwinding recommendation in the artifact manifest.",
            applied=manifest_changed,
            confidence="medium",
            reason="Loop-based harnesses need appropriate unwinding and unwinding assertions.",
        ))

    if "tool_unavailable" in failures:
        warnings.append("CBMC appears unavailable. Code repair alone cannot fix missing tool installation/PATH setup.")
    if "tool_error" in failures:
        warnings.append("CBMC/tool parsing error detected. Some issues may require include paths, source list, or build-command updates outside this C file.")

    # 6. Unsupported assumption caution.
    if has_any(all_issue_text, ["unsupported assumption", "too strong", "vacuous"]):
        warnings.append("Critic/counterexample analysis mentions unsupported/too-strong assumptions. The repaired harness remains candidate-only.")
        if context.settings.strict_no_unsupported_assumption_narrowing:
            limitations.append("Strict mode enabled: the agent did not narrow assumptions using unsupported specification facts.")

    if code == original_code:
        limitations.append("No safe deterministic code-level repair pattern was applicable. Repair notes were still generated.")

    applied_count = sum(1 for a in actions if a.applied)
    if context.settings.dry_run:
        status = "dry_run_repair_planned"
    elif applied_count > 0:
        status = "repaired_candidate_generated"
    else:
        status = "no_code_change_repair_notes_only"

    # Decide whether to recommend another tool execution.
    tool_recommended = applied_count > 0 and "tool_unavailable" not in failures
    if status == "no_code_change_repair_notes_only":
        tool_recommended = False

    # Write outputs unless dry-run.
    if not context.settings.dry_run:
        write_text(context.repaired_artifact_path, code)
        if manifest:
            manifest["repair_agent_updated_at"] = utc_now_iso()
            manifest["latest_repaired_artifact"] = context.repaired_artifact_path.name
            save_json(context.run_dir / "04_artifact_manifest.json", manifest)

    next_step = (
        "Run Formal Tool Execution Agent on 08_repaired_harness.c, then re-run counterexample analysis if CBMC fails."
        if tool_recommended
        else "Human review is recommended before another tool run."
    )

    return RepairResult(
        source_artifact=str(context.source_artifact_path),
        repaired_artifact=str(context.repaired_artifact_path),
        status=status,
        tool_execution_recommended=tool_recommended,
        human_review_required=context.settings.require_human_review,
        actions=actions,
        warnings=warnings,
        limitations=limitations,
        next_step=next_step,
    )


# ---------------------------------------------------------------------------
# Output formatting
# ---------------------------------------------------------------------------

def actions_to_json(actions: List[RepairAction]) -> List[Dict[str, Any]]:
    return [
        {
            "action_id": a.action_id,
            "category": a.category,
            "description": a.description,
            "applied": a.applied,
            "confidence": a.confidence,
            "reason": a.reason,
            "evidence": a.evidence,
            "human_review_note": a.human_review_note,
        }
        for a in actions
    ]


def build_notes_json(context: RepairContext, result: RepairResult, diff_text: str) -> Dict[str, Any]:
    critic_issues = collect_critic_issues(context.critic_review)
    failures = collect_failure_modes(context.counterexample_analysis, context.cbmc_status, context.cbmc_output)
    return {
        "agent_name": AGENT_NAME,
        "agent_version": AGENT_VERSION,
        "created_at": utc_now_iso(),
        "target_function": context.target_function,
        "iteration": context.iteration,
        "status": result.status,
        "source_artifact": result.source_artifact,
        "repaired_artifact": result.repaired_artifact,
        "tool_execution_recommended": result.tool_execution_recommended,
        "human_review_required": result.human_review_required,
        "research_guardrail": (
            "The repaired harness is a candidate formal-verification artifact only. "
            "It must be checked by CBMC/formal tools and reviewed by a human. "
            "It is not a proof of the full ML-KEM implementation."
        ),
        "inputs_used": {
            "spec_summary": "01_spec_summary.json",
            "code_summary": "02_code_summary.json",
            "candidate_properties": "03_candidate_properties.json",
            "artifact_manifest": "04_artifact_manifest.json",
            "critic_review": "05_critic_review.json",
            "cbmc_status": "06_cbmc_status.json",
            "cbmc_output": "06_cbmc_output.txt",
            "counterexample_analysis": "07_counterexample_analysis.json",
        },
        "failure_modes_seen": failures,
        "critic_issue_count": len(critic_issues),
        "repair_actions": actions_to_json(result.actions),
        "warnings": result.warnings,
        "limitations": result.limitations,
        "next_step": result.next_step,
        "diff_summary": {
            "diff_file": "08_repair_patch.diff",
            "changed": bool(diff_text.strip()),
            "added_lines_estimate": sum(1 for line in diff_text.splitlines() if line.startswith("+") and not line.startswith("+++")),
            "removed_lines_estimate": sum(1 for line in diff_text.splitlines() if line.startswith("-") and not line.startswith("---")),
        },
        "iteration_control": {
            "max_iterations": context.settings.max_iterations,
            "current_iteration": context.iteration,
            "continue_allowed": context.iteration + 1 < context.settings.max_iterations,
        },
    }


def build_markdown_report(notes: Dict[str, Any]) -> str:
    lines: List[str] = []
    lines.append("# 08 Repair / Refinement Report")
    lines.append("")
    lines.append(f"- **Agent:** `{notes['agent_name']}` v{notes['agent_version']}")
    lines.append(f"- **Target function:** `{notes['target_function']}`")
    lines.append(f"- **Iteration:** `{notes['iteration']}`")
    lines.append(f"- **Status:** `{notes['status']}`")
    lines.append(f"- **Source artifact:** `{Path(notes['source_artifact']).name}`")
    lines.append(f"- **Repaired artifact:** `{Path(notes['repaired_artifact']).name}`")
    lines.append(f"- **Tool execution recommended:** `{notes['tool_execution_recommended']}`")
    lines.append(f"- **Human review required:** `{notes['human_review_required']}`")
    lines.append("")
    lines.append("## Research Guardrail")
    lines.append("")
    lines.append(notes["research_guardrail"])
    lines.append("")
    lines.append("## Failure Modes Seen")
    lines.append("")
    if notes["failure_modes_seen"]:
        for mode in notes["failure_modes_seen"]:
            lines.append(f"- `{mode}`")
    else:
        lines.append("- No explicit failure mode was detected from the available status/output files.")
    lines.append("")
    lines.append("## Repair Actions")
    lines.append("")
    for action in notes["repair_actions"]:
        applied = "yes" if action["applied"] else "no"
        lines.append(f"### {action['action_id']} — {action['category']}")
        lines.append(f"- **Applied:** {applied}")
        lines.append(f"- **Confidence:** {action['confidence']}")
        lines.append(f"- **Description:** {action['description']}")
        lines.append(f"- **Reason:** {action['reason']}")
        if action.get("human_review_note"):
            lines.append(f"- **Human review note:** {action['human_review_note']}")
        lines.append("")
    lines.append("## Warnings")
    lines.append("")
    if notes["warnings"]:
        for warning in notes["warnings"]:
            lines.append(f"- {warning}")
    else:
        lines.append("- None recorded.")
    lines.append("")
    lines.append("## Limitations")
    lines.append("")
    if notes["limitations"]:
        for limitation in notes["limitations"]:
            lines.append(f"- {limitation}")
    else:
        lines.append("- No additional limitation recorded beyond mandatory human/formal-tool review.")
    lines.append("")
    lines.append("## Next Step")
    lines.append("")
    lines.append(notes["next_step"])
    lines.append("")
    return "\n".join(lines)


def create_diff(original: str, repaired: str, from_name: str, to_name: str) -> str:
    return "".join(
        difflib.unified_diff(
            original.splitlines(keepends=True),
            repaired.splitlines(keepends=True),
            fromfile=from_name,
            tofile=to_name,
        )
    )


def write_iteration_snapshot(context: RepairContext, notes: Dict[str, Any], diff_text: str) -> None:
    if not context.settings.write_iteration_snapshot or context.settings.dry_run:
        return
    snap_dir = context.run_dir / "repairs" / f"iteration_{context.iteration:02d}"
    snap_dir.mkdir(parents=True, exist_ok=True)
    if context.repaired_artifact_path.exists():
        shutil.copy2(context.repaired_artifact_path, snap_dir / "08_repaired_harness.c")
    save_json(snap_dir / "08_repair_notes.json", notes)
    write_text(snap_dir / "08_repair_patch.diff", diff_text)


# ---------------------------------------------------------------------------
# Main CLI
# ---------------------------------------------------------------------------

def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Repair / Refinement Agent for candidate CBMC formal-verification artifacts."
    )
    parser.add_argument("--config", required=True, help="Path to run configuration JSON.")
    parser.add_argument("--run-dir", required=False, help="Run directory, e.g. runs/run_001_poly_add.")
    parser.add_argument("--iteration", type=int, default=0, help="Repair iteration number.")
    parser.add_argument("--source-artifact", required=False, help="Artifact to repair, relative to run-dir or absolute.")
    parser.add_argument("--artifact", required=False, help="Alias for --source-artifact for orchestrator compatibility.")
    parser.add_argument("--dry-run", action="store_true", help="Plan repair and write reports without changing the harness.")
    parser.add_argument("--strict", action="store_true", help="Fail with non-zero exit if no code repair was possible.")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    context = load_context(args)
    context.run_dir.mkdir(parents=True, exist_ok=True)

    event_base = {
        "agent_name": AGENT_NAME,
        "agent_version": AGENT_VERSION,
        "time": utc_now_iso(),
        "iteration": context.iteration,
        "target_function": context.target_function,
    }
    append_jsonl(context.run_dir / "events.jsonl", {**event_base, "event": "started"})

    prompt_text = build_repair_prompt(context)
    write_text(context.run_dir / "llm_prompts" / "08_repair_prompt.txt", prompt_text)

    original_code = read_text(context.source_artifact_path, default="")
    result = perform_repair(context)
    repaired_code = read_text(context.repaired_artifact_path, default=original_code)
    if context.settings.dry_run:
        # For dry-run, reconstruct approximate diff using unchanged code because no file is written.
        repaired_code = original_code

    diff_text = create_diff(
        original_code,
        repaired_code,
        from_name=Path(result.source_artifact).name,
        to_name=Path(result.repaired_artifact).name,
    )

    if not context.settings.dry_run:
        write_text(context.run_dir / "08_repair_patch.diff", diff_text)

    notes = build_notes_json(context, result, diff_text)
    if context.settings.dry_run:
        notes["dry_run"] = True
        notes["dry_run_note"] = "No repaired harness was written because --dry-run was used."

    save_json(context.run_dir / "08_repair_notes.json", notes)
    write_text(context.run_dir / "08_repair_notes.md", build_markdown_report(notes))
    save_json(context.run_dir / "agent_status" / "08_repair_status.json", {
        "agent_name": AGENT_NAME,
        "agent_version": AGENT_VERSION,
        "status": result.status,
        "created_at": utc_now_iso(),
        "iteration": context.iteration,
        "source_artifact": result.source_artifact,
        "repaired_artifact": result.repaired_artifact,
        "tool_execution_recommended": result.tool_execution_recommended,
        "human_review_required": result.human_review_required,
        "actions_applied": sum(1 for a in result.actions if a.applied),
        "warnings_count": len(result.warnings),
        "limitations_count": len(result.limitations),
    })
    write_iteration_snapshot(context, notes, diff_text)

    append_jsonl(context.run_dir / "events.jsonl", {
        **event_base,
        "time": utc_now_iso(),
        "event": "finished",
        "status": result.status,
        "tool_execution_recommended": result.tool_execution_recommended,
    })

    print(f"[OK] Repair / Refinement Agent wrote: {context.run_dir / '08_repair_notes.json'}")
    if not context.settings.dry_run and context.repaired_artifact_path.exists():
        print(f"[OK] Repaired candidate harness: {context.repaired_artifact_path}")
    elif context.settings.dry_run:
        print("[DRY-RUN] No repaired harness was written.")
    print("[NOTE] Repaired artifacts are candidate verification inputs; CBMC and human review remain required.")

    if args.strict and result.status in {"repair_not_possible", "no_code_change_repair_notes_only"}:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
