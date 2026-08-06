#!/usr/bin/env python3
"""Build a bounded, mechanical view of one CBMC JSON counterexample.

Scientific boundary: this program performs parsing, exact property selection,
lexical filtering, bounded context selection, hashing, and evidence rendering.
It does not diagnose a failure, recommend a repair, or judge whether the
harness or implementation is correct.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Iterable

SKILL_NAME = "cbmc-counterexample-view"
SKILL_VERSION = "1.0.0-rc1"
MAX_INPUT_BYTES = 512 * 1024 * 1024
MAX_TRACE_STEPS = 2_000_000
ALLOWED_FORMATS = {"cbmc-json-ui"}

class ContractError(Exception):
    pass


def canonical_json_bytes(value: Any) -> bytes:
    return (json.dumps(value, sort_keys=True, indent=2, ensure_ascii=False) + "\n").encode("utf-8")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def ensure_plain_relative_path(value: str, field: str) -> Path:
    if not isinstance(value, str) or not value or "\x00" in value:
        raise ContractError(f"{field} must be a non-empty relative path string")
    p = Path(value)
    if p.is_absolute() or any(part in {"", ".", ".."} for part in p.parts):
        raise ContractError(f"{field} must be a normalized relative path without '.' or '..'")
    return p


def resolve_existing_regular_file(root: Path, rel: Path, field: str) -> Path:
    candidate = root / rel
    # Reject every symlink component rather than following it.
    cur = root
    for part in rel.parts:
        cur = cur / part
        if cur.is_symlink():
            raise ContractError(f"{field} must not contain symlink components: {rel}")
    if not candidate.exists() or not candidate.is_file():
        raise ContractError(f"{field} does not identify an existing regular file: {rel}")
    root_real = root.resolve()
    cand_real = candidate.resolve()
    try:
        cand_real.relative_to(root_real)
    except ValueError as exc:
        raise ContractError(f"{field} escapes the input root") from exc
    return candidate


def ensure_new_output_dir(input_root: Path, output_dir: Path) -> None:
    if output_dir.exists():
        raise ContractError("output directory must not already exist")
    input_real = input_root.resolve()
    out_parent_real = output_dir.parent.resolve()
    try:
        out_parent_real.relative_to(input_real)
    except ValueError:
        return
    raise ContractError("output directory must be outside the input root")


def load_request(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise ContractError(f"request is not valid UTF-8 JSON: {exc}") from exc
    if not isinstance(value, dict):
        raise ContractError("request root must be a JSON object")
    allowed = {"schema_version", "request_id", "trace_source", "failed_property_id", "selection"}
    unknown = sorted(set(value) - allowed)
    if unknown:
        raise ContractError(f"unknown request fields: {unknown}")
    if value.get("schema_version") != "1.0":
        raise ContractError("schema_version must equal '1.0'")
    request_id = value.get("request_id")
    if not isinstance(request_id, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,127}", request_id):
        raise ContractError("request_id has an invalid format")
    property_id = value.get("failed_property_id")
    if not isinstance(property_id, str) or not property_id or len(property_id) > 512 or any(ord(c) < 32 for c in property_id):
        raise ContractError("failed_property_id must be a printable non-empty string of at most 512 characters")
    ts = value.get("trace_source")
    if not isinstance(ts, dict) or set(ts) != {"path", "expected_sha256", "format"}:
        raise ContractError("trace_source must contain exactly path, expected_sha256, and format")
    ensure_plain_relative_path(ts["path"], "trace_source.path")
    if ts.get("format") not in ALLOWED_FORMATS:
        raise ContractError("trace_source.format must be 'cbmc-json-ui'")
    if not isinstance(ts.get("expected_sha256"), str) or not re.fullmatch(r"[0-9a-f]{64}", ts["expected_sha256"]):
        raise ContractError("trace_source.expected_sha256 must be a lowercase SHA-256 hex digest")
    selection = value.get("selection")
    if not isinstance(selection, dict):
        raise ContractError("selection must be an object")
    selection_allowed = {
        "target_variables", "target_function", "source_files", "context_steps",
        "max_selected_steps", "tail_steps_when_unfocused", "include_hidden_steps",
        "include_function_steps", "include_assumption_steps", "include_location_steps"
    }
    unknown_sel = sorted(set(selection) - selection_allowed)
    if unknown_sel:
        raise ContractError(f"unknown selection fields: {unknown_sel}")
    for list_field, max_items in (("target_variables", 64), ("source_files", 64)):
        items = selection.get(list_field, [])
        if not isinstance(items, list) or len(items) > max_items or any(not isinstance(x, str) or not x or len(x) > 512 or any(ord(c) < 32 for c in x) for x in items):
            raise ContractError(f"selection.{list_field} must be a list of printable non-empty strings")
        if len(set(items)) != len(items):
            raise ContractError(f"selection.{list_field} must not contain duplicates")
    tf = selection.get("target_function")
    if tf is not None and (not isinstance(tf, str) or not tf or len(tf) > 512 or any(ord(c) < 32 for c in tf)):
        raise ContractError("selection.target_function must be null or a printable non-empty string")
    for field, lo, hi, default in (
        ("context_steps", 0, 50, 2),
        ("max_selected_steps", 1, 5000, 500),
        ("tail_steps_when_unfocused", 1, 5000, 200),
    ):
        v = selection.get(field, default)
        if not isinstance(v, int) or isinstance(v, bool) or not lo <= v <= hi:
            raise ContractError(f"selection.{field} must be an integer from {lo} to {hi}")
    for field, default in (
        ("include_hidden_steps", False),
        ("include_function_steps", True),
        ("include_assumption_steps", True),
        ("include_location_steps", False),
    ):
        v = selection.get(field, default)
        if not isinstance(v, bool):
            raise ContractError(f"selection.{field} must be boolean")
    return normalize_request(value)


def normalize_request(value: dict[str, Any]) -> dict[str, Any]:
    s = value["selection"]
    return {
        "schema_version": "1.0",
        "request_id": value["request_id"],
        "trace_source": {
            "path": value["trace_source"]["path"],
            "expected_sha256": value["trace_source"]["expected_sha256"],
            "format": "cbmc-json-ui",
        },
        "failed_property_id": value["failed_property_id"],
        "selection": {
            "target_variables": s.get("target_variables", []),
            "target_function": s.get("target_function"),
            "source_files": s.get("source_files", []),
            "context_steps": s.get("context_steps", 2),
            "max_selected_steps": s.get("max_selected_steps", 500),
            "tail_steps_when_unfocused": s.get("tail_steps_when_unfocused", 200),
            "include_hidden_steps": s.get("include_hidden_steps", False),
            "include_function_steps": s.get("include_function_steps", True),
            "include_assumption_steps": s.get("include_assumption_steps", True),
            "include_location_steps": s.get("include_location_steps", False),
        },
    }


def compact_render(value: Any, limit: int = 2000) -> str | None:
    if value is None:
        return None
    if isinstance(value, str):
        text = value
    elif isinstance(value, (int, float, bool)):
        text = json.dumps(value, ensure_ascii=False)
    else:
        text = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    if len(text) > limit:
        return text[: limit - 1] + "…"
    return text


def normalize_location(value: Any) -> dict[str, Any] | None:
    if not isinstance(value, dict):
        return None
    allowed = ("file", "line", "column", "function", "workingDirectory")
    result = {k: compact_render(value.get(k), 512) for k in allowed if value.get(k) is not None}
    return result or None


def get_first(d: dict[str, Any], keys: Iterable[str]) -> Any:
    for k in keys:
        if k in d:
            return d[k]
    return None


def normalize_step(step: Any, index: int) -> dict[str, Any]:
    if not isinstance(step, dict):
        return {
            "original_index": index,
            "step_type": "unstructured",
            "hidden": False,
            "source_location": None,
            "function": None,
            "called_function": None,
            "thread": None,
            "lhs": None,
            "value": compact_render(step),
            "condition": None,
            "property_id": None,
            "assignment_type": None,
            "raw_step": step,
        }
    step_type_raw = get_first(step, ("stepType", "step_type", "type"))
    step_type = str(step_type_raw).strip().lower().replace("_", "-") if step_type_raw is not None else "unknown"
    loc = normalize_location(get_first(step, ("sourceLocation", "source_location", "location")))
    function = get_first(step, ("function", "functionId", "function_id"))
    if function is None and loc:
        function = loc.get("function")
    called = get_first(step, ("calledFunction", "called_function", "functionIdentifier", "function_identifier"))
    lhs = get_first(step, ("rawLhs", "raw_lhs", "lhs", "fullLhs", "full_lhs"))
    value = get_first(step, ("value", "fullLhsValue", "full_lhs_value", "rhs"))
    condition = get_first(step, ("condition", "cond", "guard"))
    property_id = get_first(step, ("property", "propertyId", "property_id"))
    assignment_type = get_first(step, ("assignmentType", "assignment_type"))
    hidden = bool(step.get("hidden", False))
    return {
        "original_index": index,
        "step_type": step_type,
        "hidden": hidden,
        "source_location": loc,
        "function": compact_render(function, 512),
        "called_function": compact_render(called, 512),
        "thread": compact_render(get_first(step, ("thread", "threadId", "thread_id")), 128),
        "lhs": compact_render(lhs),
        "value": compact_render(value),
        "condition": compact_render(condition),
        "property_id": compact_render(property_id, 512),
        "assignment_type": compact_render(assignment_type, 256),
        "raw_step": step,
    }


def walk_dicts(value: Any) -> Iterable[dict[str, Any]]:
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from walk_dicts(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk_dicts(child)


def property_records(document: Any) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    seen: set[int] = set()
    for obj in walk_dicts(document):
        pid = get_first(obj, ("property", "propertyId", "property_id"))
        status = get_first(obj, ("status", "propertyStatus", "property_status"))
        trace = get_first(obj, ("trace", "counterexample", "counterexampleTrace"))
        if pid is None:
            continue
        # A property record has at least status or trace. Avoid trace steps that
        # merely carry a property field.
        if status is None and trace is None:
            continue
        ident = id(obj)
        if ident in seen:
            continue
        seen.add(ident)
        records.append({
            "property_id": str(pid),
            "status": None if status is None else str(status),
            "description": compact_render(get_first(obj, ("description", "message", "comment")), 2000),
            "source_location": normalize_location(get_first(obj, ("sourceLocation", "source_location", "location"))),
            "trace": trace,
            "raw_record": obj,
        })
    return records


def status_is_failure(status: str | None) -> bool:
    if status is None:
        return False
    return status.strip().lower() in {"failure", "failed", "fail", "violated"}


def step_text(step: dict[str, Any]) -> str:
    parts = [
        step.get("step_type"), step.get("function"), step.get("called_function"),
        step.get("lhs"), step.get("value"), step.get("condition"), step.get("property_id"),
    ]
    loc = step.get("source_location") or {}
    parts.extend([loc.get("file"), loc.get("function"), loc.get("line")])
    return "\n".join(str(x) for x in parts if x is not None)


def is_function_step(step: dict[str, Any]) -> bool:
    t = step["step_type"]
    return "function" in t and ("call" in t or "return" in t)


def is_assumption_step(step: dict[str, Any]) -> bool:
    t = step["step_type"]
    return "assum" in t


def is_location_step(step: dict[str, Any]) -> bool:
    return step["step_type"] in {"location", "location-only"}


def is_failure_step(step: dict[str, Any], property_id: str) -> bool:
    t = step["step_type"]
    pid = step.get("property_id")
    return ("assert" in t or "failure" in t or "property" in t) and (pid is None or pid == property_id)


def select_steps(normalized: list[dict[str, Any]], request: dict[str, Any]) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    s = request["selection"]
    visible_indices = [i for i, st in enumerate(normalized) if s["include_hidden_steps"] or not st["hidden"]]
    anchors: set[int] = set()
    reasons: dict[int, set[str]] = {}

    def mark(i: int, reason: str) -> None:
        anchors.add(i)
        reasons.setdefault(i, set()).add(reason)

    focused = bool(s["target_variables"] or s["target_function"] or s["source_files"])
    for i in visible_indices:
        st = normalized[i]
        text = step_text(st)
        if any(v in text for v in s["target_variables"]):
            mark(i, "TARGET_VARIABLE_LITERAL_MATCH")
        if s["target_function"] and (st.get("function") == s["target_function"] or st.get("called_function") == s["target_function"] or (st.get("source_location") or {}).get("function") == s["target_function"]):
            mark(i, "TARGET_FUNCTION_EXACT_MATCH")
        if s["source_files"] and (st.get("source_location") or {}).get("file") in s["source_files"]:
            mark(i, "SOURCE_FILE_EXACT_MATCH")
        if s["include_function_steps"] and is_function_step(st):
            mark(i, "FUNCTION_STEP")
        if s["include_assumption_steps"] and is_assumption_step(st):
            mark(i, "ASSUMPTION_STEP")
        if s["include_location_steps"] and is_location_step(st):
            mark(i, "LOCATION_STEP")
        if is_failure_step(st, request["failed_property_id"]):
            mark(i, "FAILURE_STEP")

    # Always retain the last visible step as the trace endpoint.
    if visible_indices:
        mark(visible_indices[-1], "TRACE_ENDPOINT")

    if not focused:
        for i in visible_indices[-s["tail_steps_when_unfocused"]:]:
            mark(i, "UNFOCUSED_TAIL")

    selected_indices: set[int] = set(anchors)
    context = s["context_steps"]
    for i in list(anchors):
        for j in range(max(0, i - context), min(len(normalized), i + context + 1)):
            if j in visible_indices:
                selected_indices.add(j)
                if j != i:
                    reasons.setdefault(j, set()).add("CONTEXT")

    ordered = sorted(selected_indices)
    truncated = False
    original_selected_count = len(ordered)
    max_steps = s["max_selected_steps"]
    if len(ordered) > max_steps:
        # Keep the most recent selected steps. This is deterministic and favors
        # the violating end of the trace. Endpoint/failure anchors are naturally
        # near the end; no semantic ranking is attempted.
        ordered = ordered[-max_steps:]
        truncated = True

    output = []
    for output_index, i in enumerate(ordered):
        st = dict(normalized[i])
        st["selected_index"] = output_index
        st["selection_reasons"] = sorted(reasons.get(i, {"CONTEXT"}))
        output.append(st)
    meta = {
        "focused_selection": focused,
        "visible_step_count": len(visible_indices),
        "anchor_count": len(anchors),
        "selected_count_before_limit": original_selected_count,
        "selected_count": len(output),
        "truncated_by_max_selected_steps": truncated,
        "variable_match_mode": "LITERAL_SUBSTRING_OVER_NORMALIZED_STEP_TEXT",
        "function_match_mode": "EXACT_NORMALIZED_FIELD_MATCH",
        "source_file_match_mode": "EXACT_NORMALIZED_FIELD_MATCH",
    }
    return output, meta


def latest_assignments(steps: list[dict[str, Any]], target_variables: list[str]) -> list[dict[str, Any]]:
    latest: dict[str, dict[str, Any]] = {}
    for st in steps:
        lhs = st.get("lhs")
        if lhs is None:
            continue
        if target_variables and not any(v in lhs for v in target_variables):
            continue
        latest[lhs] = {
            "lhs": lhs,
            "value": st.get("value"),
            "original_index": st["original_index"],
            "source_location": st.get("source_location"),
        }
    return [latest[k] for k in sorted(latest)]


def function_sequence(steps: list[dict[str, Any]]) -> list[dict[str, Any]]:
    result = []
    for st in steps:
        if is_function_step(st):
            result.append({
                "original_index": st["original_index"],
                "step_type": st["step_type"],
                "function": st.get("function"),
                "called_function": st.get("called_function"),
                "source_location": st.get("source_location"),
            })
    return result


def markdown_report(report: dict[str, Any], compact: dict[str, Any]) -> str:
    lines = [
        "# CBMC Counterexample View",
        "",
        f"- Request ID: `{report['request_id']}`",
        f"- Report status: `{report['report_status']}`",
        f"- View outcome: `{report['view_outcome']}`",
        f"- Failed property: `{report['failed_property']['property_id']}`",
        f"- Property status as recorded: `{report['failed_property']['recorded_status']}`",
        f"- Raw trace steps: `{report['trace_counts']['raw']}`",
        f"- Visible normalized steps: `{report['trace_counts']['visible']}`",
        f"- Selected compact steps: `{report['trace_counts']['selected']}`",
        f"- Semantic authority: `{report['semantic_authority']}`",
        "",
        "## Mandatory interpretation boundary",
        "",
        "This output is a mechanical, bounded presentation of trace data recorded in the supplied CBMC JSON. It does not diagnose the mathematical or software cause, recommend a repair, determine whether the harness is wrong, or determine whether the implementation contains a defect.",
        "",
        "## Failed property record",
        "",
        f"- Description: {report['failed_property'].get('description') or '`NOT_RECORDED`'}",
        f"- Source location: `{json.dumps(report['failed_property'].get('source_location'), sort_keys=True)}`",
        "",
        "## Compact trace",
        "",
        "| Selected | Raw | Type | Function | LHS | Value | Source | Reasons |",
        "|---:|---:|---|---|---|---|---|---|",
    ]
    for st in compact["selected_steps"]:
        loc = st.get("source_location") or {}
        source = f"{loc.get('file','')}:{loc.get('line','')}"
        def esc(v: Any) -> str:
            if v is None:
                return ""
            return str(v).replace("|", "\\|").replace("\n", " ")
        lines.append(
            f"| {st['selected_index']} | {st['original_index']} | {esc(st['step_type'])} | "
            f"{esc(st.get('function') or st.get('called_function'))} | {esc(st.get('lhs'))} | "
            f"{esc(st.get('value'))} | {esc(source)} | {esc(', '.join(st['selection_reasons']))} |"
        )
    lines += [
        "",
        "## Latest observed assignments",
        "",
        "These are only the latest assignments observed in the selected trace steps; they are not a complete program state.",
        "",
        "```json",
        json.dumps(compact["latest_observed_assignments"], sort_keys=True, indent=2, ensure_ascii=False),
        "```",
        "",
        "## Warnings",
        "",
    ]
    if report["warnings"]:
        lines.extend(f"- {w}" for w in report["warnings"])
    else:
        lines.append("- None")
    lines += ["", "## Raw evidence", "", "The complete input trace is not rewritten or interpreted. Its exact path and SHA-256 are recorded in `input_manifest.json`.", ""]
    return "\n".join(lines)


def write_json(path: Path, value: Any) -> None:
    path.write_bytes(canonical_json_bytes(value))


def build_artifact_manifest(output_dir: Path, exclude: set[str] | None = None) -> dict[str, Any]:
    exclude = exclude or set()
    artifacts = []
    for p in sorted(output_dir.rglob("*")):
        if p.is_file():
            rel = p.relative_to(output_dir).as_posix()
            if rel in exclude:
                continue
            artifacts.append({"path": rel, "sha256": sha256_file(p), "size_bytes": p.stat().st_size})
    return {
        "schema_version": "1.0",
        "skill": {"name": SKILL_NAME, "version": SKILL_VERSION},
        "artifacts": artifacts,
    }


def run(request_path: Path, input_root: Path, output_dir: Path) -> int:
    request = load_request(request_path)
    if not input_root.exists() or not input_root.is_dir() or input_root.is_symlink():
        raise ContractError("input root must be an existing non-symlink directory")
    ensure_new_output_dir(input_root, output_dir)
    rel = ensure_plain_relative_path(request["trace_source"]["path"], "trace_source.path")
    trace_path = resolve_existing_regular_file(input_root, rel, "trace_source.path")
    if trace_path.stat().st_size > MAX_INPUT_BYTES:
        raise ContractError(f"trace input exceeds the {MAX_INPUT_BYTES}-byte safety limit")
    actual_hash = sha256_file(trace_path)
    if actual_hash != request["trace_source"]["expected_sha256"]:
        # No output directory is created on identity mismatch.
        raise ContractError("trace input SHA-256 does not match expected_sha256")
    try:
        document = json.loads(trace_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise ContractError(f"trace input is not valid UTF-8 JSON: {exc}") from exc
    records = [r for r in property_records(document) if r["property_id"] == request["failed_property_id"]]
    if len(records) == 0:
        raise ContractError("failed_property_id was not found in a CBMC property record")
    trace_records = [r for r in records if isinstance(r.get("trace"), list)]
    if len(trace_records) == 0:
        raise ContractError("the requested property record does not contain a trace array")
    if len(trace_records) > 1:
        raise ContractError("multiple trace-bearing records exist for the requested property; selection is ambiguous")
    record = trace_records[0]
    if not status_is_failure(record["status"]):
        raise ContractError("the selected property record is not marked as failed/violated")
    raw_trace = record["trace"]
    if len(raw_trace) > MAX_TRACE_STEPS:
        raise ContractError(f"trace exceeds the {MAX_TRACE_STEPS}-step safety limit")
    normalized = [normalize_step(st, i) for i, st in enumerate(raw_trace)]
    selected, selection_meta = select_steps(normalized, request)
    warnings: list[str] = []
    if not raw_trace:
        warnings.append("The selected property contains an empty trace array.")
    if selection_meta["truncated_by_max_selected_steps"]:
        warnings.append("The compact view was truncated by max_selected_steps; use the raw trace for complete evidence.")
    if any(st["step_type"] == "unknown" for st in normalized):
        warnings.append("One or more trace steps did not expose a recognized step-type field and were labelled 'unknown'.")
    if request["selection"]["target_variables"] and not any("TARGET_VARIABLE_LITERAL_MATCH" in st["selection_reasons"] for st in selected):
        warnings.append("No selected step matched the requested target-variable literals.")
    if request["selection"]["target_function"] and not any("TARGET_FUNCTION_EXACT_MATCH" in st["selection_reasons"] for st in selected):
        warnings.append("No selected step exactly matched the requested target function.")

    output_dir.mkdir(parents=True, exist_ok=False)
    write_json(output_dir / "canonical_request.json", request)
    input_manifest = {
        "schema_version": "1.0",
        "trace_source": {
            "path_relative_to_input_root": rel.as_posix(),
            "expected_sha256": request["trace_source"]["expected_sha256"],
            "actual_sha256": actual_hash,
            "sha256_match": True,
            "size_bytes": trace_path.stat().st_size,
            "format": request["trace_source"]["format"],
        },
        "input_root_recorded": str(input_root.resolve()),
    }
    write_json(output_dir / "input_manifest.json", input_manifest)
    selected_property = {
        "schema_version": "1.0",
        "property_id": record["property_id"],
        "recorded_status": record["status"],
        "description": record["description"],
        "source_location": record["source_location"],
        "raw_trace_step_count": len(raw_trace),
    }
    write_json(output_dir / "selected_property.json", selected_property)
    trace_index = {
        "schema_version": "1.0",
        "analysis_nature": "MECHANICAL_TRACE_NORMALIZATION_ONLY",
        "semantic_authority": "NONE",
        "step_count": len(normalized),
        "steps": normalized,
    }
    write_json(output_dir / "trace_index.json", trace_index)
    compact = {
        "schema_version": "1.0",
        "analysis_nature": "MECHANICAL_BOUNDED_TRACE_PRESENTATION_ONLY",
        "semantic_authority": "NONE",
        "selection": selection_meta,
        "selected_steps": selected,
        "function_call_return_sequence": function_sequence(selected),
        "latest_observed_assignments": latest_assignments(selected, request["selection"]["target_variables"]),
        "endpoint_step": selected[-1] if selected else None,
        "limitations": [
            "The compact view may omit trace steps; the complete raw input remains authoritative evidence.",
            "Target-variable matching is literal substring matching over normalized text, not semantic data-flow analysis.",
            "The latest observed assignments are not a complete state reconstruction.",
            "No diagnosis, repair recommendation, defect classification, or correctness judgement is performed.",
        ],
    }
    write_json(output_dir / "compact_trace.json", compact)
    report = {
        "schema_version": "1.0",
        "request_id": request["request_id"],
        "skill": {"name": SKILL_NAME, "version": SKILL_VERSION},
        "report_status": "COMPLETE_WITH_WARNINGS" if warnings else "COMPLETE",
        "view_outcome": "COUNTEREXAMPLE_VIEW_CREATED",
        "analysis_nature": "MECHANICAL_COUNTEREXAMPLE_PRESENTATION_ONLY",
        "semantic_authority": "NONE",
        "failed_property": selected_property,
        "trace_counts": {
            "raw": len(raw_trace),
            "visible": selection_meta["visible_step_count"],
            "selected": selection_meta["selected_count"],
        },
        "warnings": warnings,
        "limitations": compact["limitations"],
    }
    write_json(output_dir / "counterexample_view_report.json", report)
    (output_dir / "counterexample_view_report.md").write_text(markdown_report(report, compact), encoding="utf-8", newline="\n")
    manifest = build_artifact_manifest(output_dir, {"counterexample_view_artifact_manifest.json"})
    write_json(output_dir / "counterexample_view_artifact_manifest.json", manifest)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--request", required=True, type=Path)
    parser.add_argument("--input-root", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args()
    try:
        return run(args.request, args.input_root, args.output_dir)
    except ContractError as exc:
        print(f"CONTRACT_ERROR: {exc}", file=sys.stderr)
        return 3
    except Exception as exc:  # defensive evidence-friendly failure
        print(f"INTERNAL_ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 5

if __name__ == "__main__":
    raise SystemExit(main())
