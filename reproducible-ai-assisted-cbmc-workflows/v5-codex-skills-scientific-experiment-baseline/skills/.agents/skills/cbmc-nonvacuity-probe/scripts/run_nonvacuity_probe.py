#!/usr/bin/env python3
"""Deterministic disposable CBMC reachability probe.

Scientific boundary: this tool creates one companion copy per caller-selected probe,
inserts exactly one __CPROVER_cover(1) at an exact line anchor, runs CBMC without a
shell, preserves evidence, and reports only bounded reachability observations.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shlex
import shutil
import signal
import subprocess
import sys
from pathlib import Path
from typing import Any, Iterable

SKILL_NAME = "cbmc-nonvacuity-probe"
SKILL_VERSION = "1.0.0-rc1"
SCHEMA_VERSION = "1.0"

EXIT_OK = 0
EXIT_REQUEST_ERROR = 2
EXIT_EXECUTION_INCOMPLETE = 3
EXIT_SOURCE_MUTATION = 5

PROBE_KINDS = {
    "FEASIBLE_EXECUTION",
    "TARGET_CALL_REACHABILITY",
    "ASSERTION_LOCATION_REACHABILITY",
    "CUSTOM_ANCHOR_REACHABILITY",
}
POSITIONS = {"before", "after"}
REACHABILITY_STATUSES = {
    "REACHED_REPORTED_BY_CBMC",
    "NOT_REACHED_REPORTED_BY_CBMC",
    "INDETERMINATE",
    "TOOL_ERROR",
    "TIMEOUT",
}

FORBIDDEN_ARGUMENT_EXACT = {
    "--json-ui",
    "--xml-ui",
    "--xml-interface",
    "--show-test-suite",
    "--cover",
    "--property",
    "--all-properties",
    "--function",
    "--no-assertions",
    "--no-assumptions",
    "--assert-to-assume",
}
FORBIDDEN_ARGUMENT_PREFIXES = (
    "--outfile",
    "--output",
    "--xml-ui",
    "--json-ui",
    "--cover=",
    "--property=",
    "--function=",
    "@",
)
SECRET_ENV_RE = re.compile(r"(?i)(token|secret|password|api[_-]?key|credential)")
IDENT_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
PROBE_ID_RE = re.compile(r"^[a-z][a-z0-9_-]{0,63}$")
HEX64_RE = re.compile(r"^[0-9a-f]{64}$")
DEFINE_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*(?:=[^\r\n]*)?$")


class RequestError(ValueError):
    pass


def canonical_json_bytes(value: Any) -> bytes:
    return (json.dumps(value, sort_keys=True, indent=2, ensure_ascii=False) + "\n").encode("utf-8")


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(canonical_json_bytes(value))


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def ensure_object(value: Any, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise RequestError(f"{label} must be a JSON object")
    return value


def ensure_list(value: Any, label: str) -> list[Any]:
    if not isinstance(value, list):
        raise RequestError(f"{label} must be a JSON array")
    return value


def reject_unknown_keys(obj: dict[str, Any], allowed: set[str], label: str) -> None:
    unknown = sorted(set(obj) - allowed)
    if unknown:
        raise RequestError(f"{label} contains unknown fields: {', '.join(unknown)}")


def safe_relative_path(raw: Any, label: str) -> Path:
    if not isinstance(raw, str) or not raw:
        raise RequestError(f"{label} must be a non-empty string")
    if "\x00" in raw:
        raise RequestError(f"{label} contains NUL")
    path = Path(raw)
    if path.is_absolute() or any(part in {"", ".", ".."} for part in path.parts):
        raise RequestError(f"{label} must be a normalized relative path without '.' or '..': {raw}")
    return path


def path_is_within(path: Path, parent: Path) -> bool:
    try:
        path.resolve().relative_to(parent.resolve())
        return True
    except ValueError:
        return False


def resolve_existing_regular(root: Path, relative: Path, label: str) -> Path:
    candidate = root / relative
    if candidate.is_symlink():
        raise RequestError(f"{label} must not be a symlink: {relative.as_posix()}")
    if not candidate.exists() or not candidate.is_file():
        raise RequestError(f"{label} is not a regular file: {relative.as_posix()}")
    resolved = candidate.resolve()
    if not path_is_within(resolved, root):
        raise RequestError(f"{label} escapes probe root: {relative.as_posix()}")
    return candidate


def resolve_existing_dir(root: Path, relative: Path, label: str) -> Path:
    candidate = root / relative
    if candidate.is_symlink():
        raise RequestError(f"{label} must not be a symlink: {relative.as_posix()}")
    if not candidate.exists() or not candidate.is_dir():
        raise RequestError(f"{label} is not a directory: {relative.as_posix()}")
    if not path_is_within(candidate.resolve(), root):
        raise RequestError(f"{label} escapes probe root: {relative.as_posix()}")
    return candidate


def validate_request(raw: Any, probe_root: Path, output_dir: Path) -> dict[str, Any]:
    request = ensure_object(raw, "request")
    reject_unknown_keys(
        request,
        {
            "schema_version",
            "skill_version",
            "target_symbol",
            "tracked_inputs",
            "analysis_source_files",
            "build_context",
            "cbmc",
            "probes",
            "notes",
        },
        "request",
    )
    if request.get("schema_version") != SCHEMA_VERSION:
        raise RequestError(f"schema_version must be {SCHEMA_VERSION}")
    if request.get("skill_version") != SKILL_VERSION:
        raise RequestError(f"skill_version must be {SKILL_VERSION}")

    target_symbol = request.get("target_symbol")
    if not isinstance(target_symbol, str) or not IDENT_RE.fullmatch(target_symbol):
        raise RequestError("target_symbol must be a valid C identifier")

    if output_dir.exists():
        raise RequestError("output directory already exists")
    if path_is_within(output_dir, probe_root) or path_is_within(probe_root, output_dir):
        raise RequestError("output directory must be outside and must not contain the probe root")

    tracked_raw = ensure_list(request.get("tracked_inputs"), "tracked_inputs")
    if not tracked_raw:
        raise RequestError("tracked_inputs must contain at least one file")
    tracked: list[dict[str, Any]] = []
    seen_paths: set[str] = set()
    for index, item_raw in enumerate(tracked_raw):
        item = ensure_object(item_raw, f"tracked_inputs[{index}]")
        reject_unknown_keys(item, {"path", "sha256", "role"}, f"tracked_inputs[{index}]")
        rel = safe_relative_path(item.get("path"), f"tracked_inputs[{index}].path")
        rel_text = rel.as_posix()
        if rel_text in seen_paths:
            raise RequestError(f"duplicate tracked input: {rel_text}")
        seen_paths.add(rel_text)
        expected = item.get("sha256")
        if not isinstance(expected, str) or not HEX64_RE.fullmatch(expected):
            raise RequestError(f"tracked_inputs[{index}].sha256 must be lowercase SHA-256")
        role = item.get("role")
        if not isinstance(role, str) or not role or len(role) > 80:
            raise RequestError(f"tracked_inputs[{index}].role must be a short non-empty string")
        source = resolve_existing_regular(probe_root, rel, f"tracked_inputs[{index}]")
        actual = sha256_file(source)
        if actual != expected:
            raise RequestError(f"SHA-256 mismatch for {rel_text}: expected {expected}, actual {actual}")
        tracked.append({"path": rel_text, "sha256": expected, "role": role})

    analysis_sources_raw = ensure_list(request.get("analysis_source_files"), "analysis_source_files")
    if not analysis_sources_raw:
        raise RequestError("analysis_source_files must not be empty")
    analysis_sources: list[str] = []
    for index, value in enumerate(analysis_sources_raw):
        rel = safe_relative_path(value, f"analysis_source_files[{index}]")
        text = rel.as_posix()
        if text not in seen_paths:
            raise RequestError(f"analysis source is not hash-bound in tracked_inputs: {text}")
        if Path(text).suffix.lower() not in {".c", ".i", ".ii"}:
            raise RequestError(f"analysis source must be C/preprocessed C: {text}")
        if text in analysis_sources:
            raise RequestError(f"duplicate analysis source: {text}")
        analysis_sources.append(text)

    build_raw = ensure_object(request.get("build_context"), "build_context")
    reject_unknown_keys(build_raw, {"include_dirs", "defines", "undefines", "extra_arguments", "entry_function"}, "build_context")
    include_dirs: list[str] = []
    for index, value in enumerate(ensure_list(build_raw.get("include_dirs", []), "build_context.include_dirs")):
        rel = safe_relative_path(value, f"build_context.include_dirs[{index}]")
        resolve_existing_dir(probe_root, rel, f"build_context.include_dirs[{index}]")
        text = rel.as_posix()
        if text not in include_dirs:
            include_dirs.append(text)
    defines: list[str] = []
    for index, value in enumerate(ensure_list(build_raw.get("defines", []), "build_context.defines")):
        if not isinstance(value, str) or not DEFINE_RE.fullmatch(value):
            raise RequestError(f"invalid define at index {index}")
        defines.append(value)
    undefines: list[str] = []
    for index, value in enumerate(ensure_list(build_raw.get("undefines", []), "build_context.undefines")):
        if not isinstance(value, str) or not IDENT_RE.fullmatch(value):
            raise RequestError(f"invalid undefine at index {index}")
        undefines.append(value)
    extra_arguments = validate_extra_arguments(build_raw.get("extra_arguments", []))
    entry_function = build_raw.get("entry_function")
    if entry_function is not None and (not isinstance(entry_function, str) or not IDENT_RE.fullmatch(entry_function)):
        raise RequestError("build_context.entry_function must be a valid C identifier or null")

    cbmc_raw = ensure_object(request.get("cbmc"), "cbmc")
    reject_unknown_keys(cbmc_raw, {"executable", "timeout_seconds", "environment"}, "cbmc")
    executable_raw = cbmc_raw.get("executable", "cbmc")
    if not isinstance(executable_raw, str) or not executable_raw:
        raise RequestError("cbmc.executable must be a non-empty string")
    executable_path = Path(executable_raw)
    if executable_path.name != "cbmc":
        raise RequestError("CBMC executable basename must be exactly 'cbmc'")
    if any(ch in executable_raw for ch in "\r\n\x00"):
        raise RequestError("cbmc.executable contains forbidden characters")
    timeout = cbmc_raw.get("timeout_seconds")
    if not isinstance(timeout, int) or isinstance(timeout, bool) or not 1 <= timeout <= 86400:
        raise RequestError("cbmc.timeout_seconds must be an integer from 1 to 86400")
    environment_raw = ensure_object(cbmc_raw.get("environment", {}), "cbmc.environment")
    environment: dict[str, str] = {}
    for key, value in sorted(environment_raw.items()):
        if not isinstance(key, str) or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", key):
            raise RequestError(f"invalid environment variable name: {key!r}")
        if SECRET_ENV_RE.search(key):
            raise RequestError(f"secret-like environment variable is forbidden: {key}")
        if not isinstance(value, str) or any(ch in value for ch in "\x00\r\n"):
            raise RequestError(f"invalid environment value for {key}")
        environment[key] = value

    probes_raw = ensure_list(request.get("probes"), "probes")
    if not probes_raw:
        raise RequestError("probes must contain at least one probe")
    if len(probes_raw) > 64:
        raise RequestError("at most 64 probes are permitted")
    probes: list[dict[str, Any]] = []
    seen_ids: set[str] = set()
    tracked_paths = set(seen_paths)
    for index, item_raw in enumerate(probes_raw):
        item = ensure_object(item_raw, f"probes[{index}]")
        reject_unknown_keys(
            item,
            {"id", "kind", "source_path", "anchor_line", "occurrence", "insertion_position", "required", "note"},
            f"probes[{index}]",
        )
        probe_id = item.get("id")
        if not isinstance(probe_id, str) or not PROBE_ID_RE.fullmatch(probe_id):
            raise RequestError(f"probes[{index}].id is invalid")
        if probe_id in seen_ids:
            raise RequestError(f"duplicate probe id: {probe_id}")
        seen_ids.add(probe_id)
        kind = item.get("kind")
        if kind not in PROBE_KINDS:
            raise RequestError(f"invalid probe kind for {probe_id}")
        source_rel = safe_relative_path(item.get("source_path"), f"probes[{index}].source_path")
        source_text = source_rel.as_posix()
        if source_text not in tracked_paths:
            raise RequestError(f"probe source is not hash-bound: {source_text}")
        if Path(source_text).suffix.lower() not in {".c", ".i", ".ii"}:
            raise RequestError(f"probe source must be C/preprocessed C: {source_text}")
        anchor = item.get("anchor_line")
        if not isinstance(anchor, str) or not anchor.strip() or "\n" in anchor or "\r" in anchor or len(anchor) > 4096:
            raise RequestError(f"probes[{index}].anchor_line must be one non-empty line")
        anchor = anchor.strip()
        occurrence = item.get("occurrence", 1)
        if not isinstance(occurrence, int) or isinstance(occurrence, bool) or not 1 <= occurrence <= 100000:
            raise RequestError(f"probes[{index}].occurrence must be a positive integer")
        position = item.get("insertion_position")
        if position not in POSITIONS:
            raise RequestError(f"probes[{index}].insertion_position must be before or after")
        required = item.get("required", True)
        if not isinstance(required, bool):
            raise RequestError(f"probes[{index}].required must be boolean")
        note = item.get("note", "")
        if not isinstance(note, str) or len(note) > 1000:
            raise RequestError(f"probes[{index}].note must be a string up to 1000 characters")
        compact_anchor = re.sub(r"\s+", "", anchor)
        if kind == "TARGET_CALL_REACHABILITY" and f"{target_symbol}(" not in compact_anchor:
            raise RequestError(f"target-call probe {probe_id} anchor does not contain a lexical call to {target_symbol}")
        if kind == "ASSERTION_LOCATION_REACHABILITY" and not (
            "__CPROVER_assert(" in compact_anchor or re.search(r"(?:^|[^A-Za-z0-9_])assert\(", compact_anchor)
        ):
            raise RequestError(f"assertion-location probe {probe_id} anchor does not contain an assertion call")
        probes.append(
            {
                "id": probe_id,
                "kind": kind,
                "source_path": source_text,
                "anchor_line": anchor,
                "occurrence": occurrence,
                "insertion_position": position,
                "required": required,
                "note": note,
            }
        )

    notes = request.get("notes", "")
    if not isinstance(notes, str) or len(notes) > 5000:
        raise RequestError("notes must be a string up to 5000 characters")

    return {
        "schema_version": SCHEMA_VERSION,
        "skill_version": SKILL_VERSION,
        "target_symbol": target_symbol,
        "tracked_inputs": sorted(tracked, key=lambda item: item["path"]),
        "analysis_source_files": analysis_sources,
        "build_context": {
            "include_dirs": include_dirs,
            "defines": defines,
            "undefines": undefines,
            "extra_arguments": extra_arguments,
            "entry_function": entry_function,
        },
        "cbmc": {
            "executable": executable_raw,
            "timeout_seconds": timeout,
            "environment": environment,
        },
        "probes": probes,
        "notes": notes,
    }


def validate_extra_arguments(raw: Any) -> list[str]:
    values = ensure_list(raw, "build_context.extra_arguments")
    if len(values) > 256:
        raise RequestError("too many extra arguments")
    result: list[str] = []
    for index, value in enumerate(values):
        if not isinstance(value, str) or not value or any(ch in value for ch in "\x00\r\n"):
            raise RequestError(f"invalid extra argument at index {index}")
        if value in FORBIDDEN_ARGUMENT_EXACT or any(value.startswith(prefix) for prefix in FORBIDDEN_ARGUMENT_PREFIXES):
            raise RequestError(f"forbidden CBMC argument: {value}")
        if any(token in value for token in (";", "|", "`", "&&", "||", ">", "<")):
            raise RequestError(f"shell-like CBMC argument is forbidden: {value}")
        if "$(" in value:
            raise RequestError(f"shell-like CBMC argument is forbidden: {value}")
        result.append(value)
    return result


def authoritative_manifest(root: Path, tracked: Iterable[dict[str, Any]]) -> dict[str, Any]:
    files: list[dict[str, Any]] = []
    for item in tracked:
        rel = Path(item["path"])
        path = resolve_existing_regular(root, rel, f"tracked input {rel.as_posix()}")
        files.append(
            {
                "path": rel.as_posix(),
                "role": item["role"],
                "expected_sha256": item["sha256"],
                "actual_sha256": sha256_file(path),
                "size_bytes": path.stat().st_size,
                "hash_match": sha256_file(path) == item["sha256"],
            }
        )
    return {
        "schema_version": SCHEMA_VERSION,
        "skill_version": SKILL_VERSION,
        "files": files,
    }


def copy_tracked_inputs(root: Path, destination: Path, tracked: list[dict[str, Any]]) -> None:
    for item in tracked:
        rel = Path(item["path"])
        source = resolve_existing_regular(root, rel, f"tracked input {rel.as_posix()}")
        target = destination / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)


def insert_probe(source_path: Path, probe: dict[str, Any]) -> dict[str, Any]:
    raw = source_path.read_text(encoding="utf-8")
    lines = raw.splitlines(keepends=True)
    matches = [index for index, line in enumerate(lines) if line.strip() == probe["anchor_line"]]
    occurrence = probe["occurrence"]
    if len(matches) < occurrence:
        raise RequestError(
            f"probe {probe['id']} anchor occurrence {occurrence} not found; matching lines observed: {len(matches)}"
        )
    selected_index = matches[occurrence - 1]
    original_line = lines[selected_index]
    indent = original_line[: len(original_line) - len(original_line.lstrip())]
    newline = "\n" if original_line.endswith("\n") else "\n"
    marker_lines = [
        f"{indent}/* V5_NONVACUITY_PROBE_BEGIN:{probe['id']} */{newline}",
        f"{indent}__CPROVER_cover(1);{newline}",
        f"{indent}/* V5_NONVACUITY_PROBE_END:{probe['id']} */{newline}",
    ]
    insertion_index = selected_index if probe["insertion_position"] == "before" else selected_index + 1
    lines[insertion_index:insertion_index] = marker_lines
    source_path.write_text("".join(lines), encoding="utf-8", newline="\n")
    return {
        "probe_id": probe["id"],
        "source_path": probe["source_path"],
        "anchor_line": probe["anchor_line"],
        "matching_anchor_count": len(matches),
        "selected_occurrence": occurrence,
        "original_anchor_line_number": selected_index + 1,
        "insertion_position": probe["insertion_position"],
        "inserted_cover_line_number": insertion_index + 2,
        "marker_begin": f"V5_NONVACUITY_PROBE_BEGIN:{probe['id']}",
        "marker_end": f"V5_NONVACUITY_PROBE_END:{probe['id']}",
    }


def build_cbmc_argv(request: dict[str, Any], companion_root: Path) -> list[str]:
    argv = [request["cbmc"]["executable"]]
    for include_dir in request["build_context"]["include_dirs"]:
        argv.append(f"-I{include_dir}")
    for define in request["build_context"]["defines"]:
        argv.append(f"-D{define}")
    for undefine in request["build_context"]["undefines"]:
        argv.append(f"-U{undefine}")
    argv.extend(request["build_context"]["extra_arguments"])
    if request["build_context"]["entry_function"]:
        argv.extend(["--function", request["build_context"]["entry_function"]])
    argv.extend(["--cover", "cover", "--show-test-suite", "--json-ui"])
    argv.extend(request["analysis_source_files"])
    return argv


def safe_environment(extra: dict[str, str]) -> dict[str, str]:
    allowed = {key: value for key, value in os.environ.items() if key in {"PATH", "HOME", "LANG", "LC_ALL", "TMPDIR"}}
    allowed.update(extra)
    allowed.setdefault("LC_ALL", "C")
    return allowed


def run_process(argv: list[str], cwd: Path, timeout_seconds: int, environment: dict[str, str]) -> dict[str, Any]:
    try:
        process = subprocess.Popen(
            argv,
            cwd=str(cwd),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            errors="replace",
            env=safe_environment(environment),
            shell=False,
            start_new_session=True,
        )
    except OSError as exc:
        return {
            "exit_code": None,
            "timed_out": False,
            "launch_error": str(exc),
            "stdout": "",
            "stderr": "",
        }
    try:
        stdout, stderr = process.communicate(timeout=timeout_seconds)
        return {
            "exit_code": process.returncode,
            "timed_out": False,
            "launch_error": None,
            "stdout": stdout,
            "stderr": stderr,
        }
    except subprocess.TimeoutExpired:
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        try:
            stdout, stderr = process.communicate(timeout=2)
        except subprocess.TimeoutExpired:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            stdout, stderr = process.communicate()
        return {
            "exit_code": process.returncode,
            "timed_out": True,
            "launch_error": None,
            "stdout": stdout,
            "stderr": stderr,
        }


def walk_json(value: Any) -> Iterable[dict[str, Any]]:
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from walk_json(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk_json(child)


def property_like_records(parsed: Any) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    seen: set[str] = set()
    for obj in walk_json(parsed):
        status = obj.get("status")
        prop_id = obj.get("property") or obj.get("propertyId") or obj.get("property_id")
        description = obj.get("description") or obj.get("message") or obj.get("comment")
        source = obj.get("sourceLocation") or obj.get("source_location") or obj.get("location")
        if status is None or (prop_id is None and description is None):
            continue
        normalized = {
            "property_id": str(prop_id) if prop_id is not None else None,
            "status": str(status),
            "description": str(description) if description is not None else None,
            "source_location": source if isinstance(source, dict) else None,
        }
        key = json.dumps(normalized, sort_keys=True, default=str)
        if key not in seen:
            seen.add(key)
            records.append(normalized)
    return records


def classify_probe_result(process_result: dict[str, Any], parsed_json: Any, probe_id: str) -> dict[str, Any]:
    if process_result["timed_out"]:
        return {
            "reachability_status": "TIMEOUT",
            "mapping_confidence": "NONE",
            "matched_records": [],
            "reason": "Configured CBMC timeout expired.",
        }
    if process_result["launch_error"] is not None:
        return {
            "reachability_status": "TOOL_ERROR",
            "mapping_confidence": "NONE",
            "matched_records": [],
            "reason": "CBMC could not be launched.",
        }
    if parsed_json is None:
        return {
            "reachability_status": "TOOL_ERROR" if process_result["exit_code"] not in (0, 10) else "INDETERMINATE",
            "mapping_confidence": "NONE",
            "matched_records": [],
            "reason": "CBMC stdout was not valid JSON.",
        }
    records = property_like_records(parsed_json)
    cover_records = []
    for record in records:
        searchable = " ".join(
            part for part in [record.get("property_id"), record.get("description")] if isinstance(part, str)
        ).lower()
        prop = (record.get("property_id") or "").lower()
        if "cover" in searchable or "coverage" in searchable or prop.startswith("cover"):
            cover_records.append(record)
    candidates = cover_records if cover_records else records
    reachable_tokens = {"SATISFIED", "COVERED", "REACHABLE", "SUCCESS", "PASS"}
    unreachable_tokens = {"FAILED", "UNCOVERED", "UNREACHABLE", "FAILURE", "NOT_COVERED"}
    reached = [r for r in candidates if r["status"].upper().replace(" ", "_") in reachable_tokens]
    not_reached = [r for r in candidates if r["status"].upper().replace(" ", "_") in unreachable_tokens]

    # One probe is executed per companion run. A single recognized cover record is an unambiguous mapping.
    if len(candidates) == 1 and len(reached) == 1:
        return {
            "reachability_status": "REACHED_REPORTED_BY_CBMC",
            "mapping_confidence": "SINGLE_COVER_RECORD",
            "matched_records": candidates,
            "reason": "The single recognized coverage record was reported reached/covered.",
        }
    if len(candidates) == 1 and len(not_reached) == 1:
        return {
            "reachability_status": "NOT_REACHED_REPORTED_BY_CBMC",
            "mapping_confidence": "SINGLE_COVER_RECORD",
            "matched_records": candidates,
            "reason": "The single recognized coverage record was reported not reached/uncovered.",
        }
    if reached and not not_reached and len(reached) == len(candidates):
        return {
            "reachability_status": "REACHED_REPORTED_BY_CBMC",
            "mapping_confidence": "ALL_RECOGNIZED_RECORDS_AGREE",
            "matched_records": candidates,
            "reason": "All recognized coverage records were reported reached/covered.",
        }
    if not_reached and not reached and len(not_reached) == len(candidates):
        return {
            "reachability_status": "NOT_REACHED_REPORTED_BY_CBMC",
            "mapping_confidence": "ALL_RECOGNIZED_RECORDS_AGREE",
            "matched_records": candidates,
            "reason": "All recognized coverage records were reported not reached/uncovered.",
        }
    tool_error = any(
        isinstance(obj, dict)
        and str(obj.get("messageType", "")).upper() == "ERROR"
        for obj in walk_json(parsed_json)
    )
    if tool_error or (process_result["exit_code"] not in (0, 10)):
        return {
            "reachability_status": "TOOL_ERROR",
            "mapping_confidence": "NONE",
            "matched_records": candidates,
            "reason": "CBMC reported an error or returned a non-coverage exit code.",
        }
    return {
        "reachability_status": "INDETERMINATE",
        "mapping_confidence": "AMBIGUOUS_OR_UNRECOGNIZED",
        "matched_records": candidates,
        "reason": f"Coverage output for probe {probe_id} could not be mapped unambiguously.",
    }


def companion_manifest(companion_root: Path, tracked: list[dict[str, Any]], insertion: dict[str, Any]) -> dict[str, Any]:
    files: list[dict[str, Any]] = []
    for item in tracked:
        path = companion_root / item["path"]
        files.append(
            {
                "path": item["path"],
                "role": item["role"],
                "authoritative_sha256": item["sha256"],
                "companion_sha256": sha256_file(path),
                "modified_for_probe": item["path"] == insertion["source_path"],
                "size_bytes": path.stat().st_size,
            }
        )
    return {
        "schema_version": SCHEMA_VERSION,
        "skill_version": SKILL_VERSION,
        "disposable": True,
        "authoritative_tree_modified": False,
        "insertion": insertion,
        "files": files,
    }


def artifact_manifest(output_dir: Path) -> dict[str, Any]:
    files: list[dict[str, Any]] = []
    for path in sorted(p for p in output_dir.rglob("*") if p.is_file()):
        rel = path.relative_to(output_dir).as_posix()
        if rel == "nonvacuity_probe_artifact_manifest.json":
            continue
        files.append({"path": rel, "sha256": sha256_file(path), "size_bytes": path.stat().st_size})
    return {
        "schema_version": SCHEMA_VERSION,
        "skill_version": SKILL_VERSION,
        "files": files,
    }


def quote_command(argv: list[str]) -> str:
    return " ".join(shlex.quote(value) for value in argv) + "\n"


def build_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# CBMC Non-Vacuity Probe Report",
        "",
        f"- Report status: `{report['report_status']}`",
        f"- Target symbol: `{report['target_symbol']}`",
        f"- Semantic authority: `{report['semantic_authority']}`",
        f"- Authoritative inputs unchanged: `{str(report['authoritative_inputs_unchanged']).lower()}`",
        "",
        "## Probe results",
        "",
        "| Probe | Kind | Result | Required |",
        "|---|---|---|---|",
    ]
    for item in report["probe_results"]:
        lines.append(
            f"| `{item['probe_id']}` | `{item['kind']}` | `{item['reachability_status']}` | "
            f"`{str(item['required']).lower()}` |"
        )
    lines.extend(
        [
            "",
            "## Mandatory interpretation limits",
            "",
            "- A reached probe means only that CBMC reported the inserted cover goal reachable in the exact captured bounded run.",
            "- A reached target-call probe does not prove that the target result is used meaningfully or that the candidate theorem is non-vacuous.",
            "- An unreached probe does not identify whether assumptions, bounds, build context, probe placement, the implementation, or tool configuration caused the result.",
            "- Coverage mode and disposable instrumentation are diagnostic evidence, not the authoritative proof run.",
            "- The authoritative harness and source files remain the scientific artefacts; companion trees are disposable diagnostics.",
            "",
        ]
    )
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--request", required=True, type=Path)
    parser.add_argument("--probe-root", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args(argv)

    request_path = args.request.resolve()
    probe_root = args.probe_root.resolve()
    output_dir = args.output_dir.resolve()

    try:
        if request_path.is_symlink() or not request_path.is_file():
            raise RequestError("request must be a non-symlink regular file")
        if probe_root.is_symlink() or not probe_root.is_dir():
            raise RequestError("probe root must be a non-symlink directory")
        raw_request = json.loads(request_path.read_text(encoding="utf-8"))
        request = validate_request(raw_request, probe_root, output_dir)
    except (RequestError, json.JSONDecodeError, UnicodeDecodeError, OSError) as exc:
        print(f"REQUEST_ERROR: {exc}", file=sys.stderr)
        return EXIT_REQUEST_ERROR

    output_dir.mkdir(parents=True, exist_ok=False)
    write_json(output_dir / "canonical_request.json", request)

    before = authoritative_manifest(probe_root, request["tracked_inputs"])
    write_json(output_dir / "authoritative_input_manifest.before.json", before)

    probe_plan = {
        "schema_version": SCHEMA_VERSION,
        "skill_version": SKILL_VERSION,
        "target_symbol": request["target_symbol"],
        "probe_count": len(request["probes"]),
        "probes": request["probes"],
        "instrumentation": "ONE_DISPOSABLE_COMPANION_AND_ONE___CPROVER_cover(1)_PER_PROBE",
        "authoritative_tree_modification_permitted": False,
        "semantic_authority": "NONE",
    }
    write_json(output_dir / "probe_plan.json", probe_plan)

    aggregate_results: list[dict[str, Any]] = []
    incomplete = False
    try:
        for probe in request["probes"]:
            probe_dir = output_dir / "probes" / probe["id"]
            companion_root = probe_dir / "companion"
            companion_root.mkdir(parents=True, exist_ok=False)
            copy_tracked_inputs(probe_root, companion_root, request["tracked_inputs"])
            insertion = insert_probe(companion_root / probe["source_path"], probe)
            manifest = companion_manifest(companion_root, request["tracked_inputs"], insertion)
            write_json(probe_dir / "companion_manifest.json", manifest)

            cbmc_argv = build_cbmc_argv(request, companion_root)
            write_json(probe_dir / "cbmc.argv.json", cbmc_argv)
            write_text(probe_dir / "cbmc.command.txt", quote_command(cbmc_argv))
            process_result = run_process(
                cbmc_argv,
                companion_root,
                request["cbmc"]["timeout_seconds"],
                request["cbmc"]["environment"],
            )
            stdout_text = process_result["stdout"]
            stderr_text = process_result["stderr"]
            write_text(probe_dir / "cbmc.stdout.json", stdout_text)
            write_text(probe_dir / "cbmc.stderr.txt", stderr_text)
            parsed_json = None
            json_error = None
            if stdout_text.strip():
                try:
                    parsed_json = json.loads(stdout_text)
                except json.JSONDecodeError as exc:
                    json_error = str(exc)
            classification = classify_probe_result(process_result, parsed_json, probe["id"])
            result = {
                "schema_version": SCHEMA_VERSION,
                "skill_version": SKILL_VERSION,
                "probe_id": probe["id"],
                "kind": probe["kind"],
                "required": probe["required"],
                "source_path": probe["source_path"],
                "anchor_line": probe["anchor_line"],
                "occurrence": probe["occurrence"],
                "insertion_position": probe["insertion_position"],
                "inserted_cover_line_number": insertion["inserted_cover_line_number"],
                "reachability_status": classification["reachability_status"],
                "mapping_confidence": classification["mapping_confidence"],
                "classification_reason": classification["reason"],
                "matched_records": classification["matched_records"],
                "cbmc_exit_code": process_result["exit_code"],
                "timed_out": process_result["timed_out"],
                "launch_error": process_result["launch_error"],
                "stdout_json_parsed": parsed_json is not None,
                "stdout_json_error": json_error,
                "evidence_statement": "This status describes only the inserted cover goal in the exact captured bounded diagnostic run.",
                "semantic_authority": "NONE",
            }
            write_json(probe_dir / "probe_result.json", result)
            aggregate_results.append(result)
            if classification["reachability_status"] in {"TOOL_ERROR", "TIMEOUT", "INDETERMINATE"} and probe["required"]:
                incomplete = True
    except (RequestError, OSError) as exc:
        write_text(output_dir / "runtime_error.txt", f"{type(exc).__name__}: {exc}\n")
        incomplete = True

    after = authoritative_manifest(probe_root, request["tracked_inputs"])
    write_json(output_dir / "authoritative_input_manifest.after.json", after)
    before_by_path = {item["path"]: item for item in before["files"]}
    after_by_path = {item["path"]: item for item in after["files"]}
    changes = []
    for path in sorted(before_by_path):
        if before_by_path[path]["actual_sha256"] != after_by_path[path]["actual_sha256"]:
            changes.append(
                {
                    "path": path,
                    "before_sha256": before_by_path[path]["actual_sha256"],
                    "after_sha256": after_by_path[path]["actual_sha256"],
                }
            )
    integrity = {
        "schema_version": SCHEMA_VERSION,
        "skill_version": SKILL_VERSION,
        "authoritative_inputs_unchanged": not changes,
        "changed_files": changes,
    }
    write_json(output_dir / "authoritative_integrity_comparison.json", integrity)

    report_status = "INCOMPLETE" if incomplete else "COMPLETE"
    if changes:
        report_status = "SOURCE_MUTATION_DETECTED"
    report = {
        "schema_version": SCHEMA_VERSION,
        "skill_version": SKILL_VERSION,
        "report_status": report_status,
        "target_symbol": request["target_symbol"],
        "probe_count": len(aggregate_results),
        "probe_results": [
            {
                "probe_id": item["probe_id"],
                "kind": item["kind"],
                "required": item["required"],
                "reachability_status": item["reachability_status"],
                "mapping_confidence": item["mapping_confidence"],
                "result_path": f"probes/{item['probe_id']}/probe_result.json",
                "raw_stdout_path": f"probes/{item['probe_id']}/cbmc.stdout.json",
                "raw_stderr_path": f"probes/{item['probe_id']}/cbmc.stderr.txt",
            }
            for item in aggregate_results
        ],
        "authoritative_inputs_unchanged": not changes,
        "semantic_authority": "NONE",
        "gate_authority": "NONE",
        "mandatory_limitations": [
            "Reachability is bounded by the exact captured CBMC invocation and unwind configuration.",
            "A reached cover goal does not establish theorem validity, assertion quality, assumption justification, or implementation correctness.",
            "An unreached cover goal does not diagnose which input, assumption, bound, build choice, source path, or tool behavior caused unreachability.",
            "CBMC coverage mode is diagnostic and is separate from the authoritative verification run.",
            "Companion files are disposable diagnostic copies and must not replace the authoritative harness or production source.",
        ],
    }
    write_json(output_dir / "nonvacuity_probe_report.json", report)
    write_text(output_dir / "nonvacuity_probe_report.md", build_markdown(report))
    write_json(output_dir / "nonvacuity_probe_artifact_manifest.json", artifact_manifest(output_dir))

    if changes:
        return EXIT_SOURCE_MUTATION
    if incomplete:
        return EXIT_EXECUTION_INCOMPLETE
    return EXIT_OK


if __name__ == "__main__":
    raise SystemExit(main())
