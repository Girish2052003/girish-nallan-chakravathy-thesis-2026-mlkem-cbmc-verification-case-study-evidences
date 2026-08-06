#!/usr/bin/env python3
"""Deterministic CBMC execution and evidence preservation utility.

This utility executes only an explicitly supplied CBMC task. It does not select
properties, alter assumptions/assertions, repair artifacts, or interpret a CBMC
success as complete program correctness.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import pathlib
import platform
import re
import resource
import shlex
import signal
import stat
import subprocess
import sys
import traceback
from dataclasses import dataclass
from typing import Any, Iterable

SCHEMA_VERSION = "1.0"
SKILL_VERSION = "1.0.0-rc1"
MAX_TIMEOUT = 86400
MAX_OUTPUT_MB = 4096
SHELL_META_RE = re.compile(r"(?:[;&|`]|\$\(|\$\{|>|<|\n|\r)")
ENV_NAME_RE = re.compile(r"^[A-Z_][A-Z0-9_]*$")
SECRET_ENV_RE = re.compile(r"(?:TOKEN|SECRET|PASSWORD|PASSWD|API_KEY|PRIVATE_KEY|CREDENTIAL)", re.I)
FORBIDDEN_EXACT_OPTIONS = {
    "--json-ui", "--xml-ui", "--json-interface", "--xml-interface",
    "--show-properties", "--version", "--help", "-h", "-?",
}
FORBIDDEN_OUTPUT_OPTIONS = {
    "--outfile", "-o", "--export-symex-ready-goto", "--graphml-witness",
    "--json-cex", "--dimacs", "--smt2", "--write-solver-stats-to",
}
ALLOWED_ARTIFACT_OPTION = "--symex-coverage-report"
KNOWN_FAILURE_STATUSES = {"FAILURE", "FAILED", "FAIL", "FALSE", "SATISFIED"}
KNOWN_SUCCESS_STATUSES = {"SUCCESS", "PASS", "PASSED", "TRUE", "UNSATISFIABLE"}


class ContractError(Exception):
    pass


class IdentityError(Exception):
    pass


def canonical_json_bytes(value: Any) -> bytes:
    return (json.dumps(value, indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode("utf-8")


def write_json(path: pathlib.Path, value: Any) -> None:
    path.write_bytes(canonical_json_bytes(value))


def sha256_file(path: pathlib.Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def ensure_no_symlink_components(path: pathlib.Path, stop: pathlib.Path) -> None:
    current = path
    stop = stop.resolve()
    while True:
        if current.exists() and current.is_symlink():
            raise ContractError(f"symlink paths are not permitted: {current}")
        if current == stop:
            return
        if current.parent == current:
            raise ContractError(f"path is not beneath expected root: {path}")
        current = current.parent


def resolve_inside(root: pathlib.Path, rel: str, *, must_exist: bool = True, file_only: bool = False) -> pathlib.Path:
    p = pathlib.PurePosixPath(rel)
    if rel == ".":
        candidate = root
    else:
        if p.is_absolute() or ".." in p.parts or not p.parts:
            raise ContractError(f"path must be a non-empty repository-relative POSIX path: {rel!r}")
        candidate = root.joinpath(*p.parts)
    if must_exist and not candidate.exists():
        raise ContractError(f"required path does not exist: {rel}")
    ensure_no_symlink_components(candidate, root)
    resolved = candidate.resolve(strict=must_exist)
    try:
        resolved.relative_to(root.resolve())
    except ValueError as exc:
        raise ContractError(f"path escapes workspace root: {rel}") from exc
    if file_only and (not resolved.is_file() or resolved.is_symlink()):
        raise ContractError(f"path must be a regular non-symlink file: {rel}")
    return resolved


def strict_object(value: Any, name: str, allowed: set[str], required: set[str]) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ContractError(f"{name} must be an object")
    unknown = set(value) - allowed
    missing = required - set(value)
    if unknown:
        raise ContractError(f"{name} contains unknown fields: {sorted(unknown)}")
    if missing:
        raise ContractError(f"{name} is missing required fields: {sorted(missing)}")
    return value


def require_string(value: Any, name: str, *, nonempty: bool = True) -> str:
    if not isinstance(value, str) or (nonempty and not value.strip()):
        raise ContractError(f"{name} must be a non-empty string")
    return value


def require_bool(value: Any, name: str) -> bool:
    if not isinstance(value, bool):
        raise ContractError(f"{name} must be boolean")
    return value


def require_int(value: Any, name: str, minimum: int, maximum: int) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or not (minimum <= value <= maximum):
        raise ContractError(f"{name} must be an integer in [{minimum}, {maximum}]")
    return value


def validate_option_tokens(tokens: Any, name: str, artifact_dir: pathlib.Path) -> tuple[list[str], list[str]]:
    if not isinstance(tokens, list) or not all(isinstance(x, str) and x for x in tokens):
        raise ContractError(f"{name} must be an array of non-empty strings")
    expanded: list[str] = []
    declared_artifacts: list[str] = []
    expect_artifact_path = False
    for i, token in enumerate(tokens):
        if "\x00" in token or SHELL_META_RE.search(token):
            raise ContractError(f"{name}[{i}] contains forbidden shell/control syntax")
        if token.startswith("@"):
            raise ContractError(f"{name}[{i}] uses a hidden argument-file token, which is forbidden")
        if token in FORBIDDEN_EXACT_OPTIONS:
            raise ContractError(f"{name}[{i}] conflicts with wrapper-controlled instrumentation: {token}")
        if token in FORBIDDEN_OUTPUT_OPTIONS or any(token.startswith(x + "=") for x in FORBIDDEN_OUTPUT_OPTIONS):
            raise ContractError(f"{name}[{i}] may write an uncontrolled output file: {token}")
        if expect_artifact_path:
            if token != "{artifact_dir}/coverage.xml":
                raise ContractError(
                    f"{name}[{i}] must be exactly '{{artifact_dir}}/coverage.xml' after {ALLOWED_ARTIFACT_OPTION}"
                )
            path = artifact_dir / "coverage.xml"
            expanded.append(str(path))
            declared_artifacts.append("coverage.xml")
            expect_artifact_path = False
            continue
        if token == ALLOWED_ARTIFACT_OPTION:
            expect_artifact_path = True
            expanded.append(token)
            continue
        if "{artifact_dir}" in token:
            raise ContractError(f"{name}[{i}] uses artifact_dir outside the permitted coverage option")
        expanded.append(token)
    if expect_artifact_path:
        raise ContractError(f"{name} ends before the required coverage output path")
    return expanded, declared_artifacts


def utc_timestamp(clock: dict[str, Any]) -> str:
    mode = clock.get("mode", "wall_clock")
    if mode == "wall_clock":
        return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    if mode == "source_date_epoch":
        raw = os.environ.get("SOURCE_DATE_EPOCH")
        if raw is None or not raw.isdigit():
            raise ContractError("clock.mode=source_date_epoch requires numeric SOURCE_DATE_EPOCH")
        return dt.datetime.fromtimestamp(int(raw), tz=dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    raise ContractError("clock.mode must be wall_clock or source_date_epoch")


def validate_request(raw: Any) -> dict[str, Any]:
    req = strict_object(
        raw, "request",
        {"schema_version", "request_id", "working_directory", "analysis_sources", "tracked_inputs",
         "expected_sha256", "analysis", "inventory", "execution_environment", "limits", "clock", "notes"},
        {"schema_version", "request_id", "working_directory", "analysis_sources", "tracked_inputs", "analysis"},
    )
    if req["schema_version"] != SCHEMA_VERSION:
        raise ContractError(f"schema_version must be {SCHEMA_VERSION}")
    require_string(req["request_id"], "request_id")
    require_string(req["working_directory"], "working_directory")
    for field in ("analysis_sources", "tracked_inputs"):
        values = req[field]
        if not isinstance(values, list) or not values or not all(isinstance(x, str) and x for x in values):
            raise ContractError(f"{field} must be a non-empty array of paths")
        if len(values) != len(set(values)):
            raise ContractError(f"{field} contains duplicate paths")
    if not set(req["analysis_sources"]).issubset(set(req["tracked_inputs"])):
        raise ContractError("analysis_sources must be a subset of tracked_inputs")
    hashes = req.get("expected_sha256", {})
    if not isinstance(hashes, dict):
        raise ContractError("expected_sha256 must be an object")
    for key, value in hashes.items():
        if key not in req["tracked_inputs"] or not re.fullmatch(r"[0-9a-f]{64}", str(value)):
            raise ContractError("expected_sha256 keys must be tracked inputs and values lowercase SHA-256")
    analysis = strict_object(req["analysis"], "analysis", {"options", "timeout_seconds"}, {"options"})
    if not isinstance(analysis["options"], list):
        raise ContractError("analysis.options must be an array")
    if "timeout_seconds" in analysis:
        require_int(analysis["timeout_seconds"], "analysis.timeout_seconds", 1, MAX_TIMEOUT)
    inventory = req.get("inventory", {"enabled": True, "options": [], "timeout_seconds": 60})
    inventory = strict_object(inventory, "inventory", {"enabled", "options", "timeout_seconds"}, {"enabled"})
    require_bool(inventory["enabled"], "inventory.enabled")
    if inventory.get("enabled"):
        if "options" in inventory and not isinstance(inventory["options"], list):
            raise ContractError("inventory.options must be an array")
        if "timeout_seconds" in inventory:
            require_int(inventory["timeout_seconds"], "inventory.timeout_seconds", 1, MAX_TIMEOUT)
    env = req.get("execution_environment", {})
    if not isinstance(env, dict):
        raise ContractError("execution_environment must be an object")
    for key, value in env.items():
        if not ENV_NAME_RE.fullmatch(key) or SECRET_ENV_RE.search(key):
            raise ContractError(f"execution_environment contains forbidden variable name: {key}")
        if not isinstance(value, str) or "\x00" in value or "\n" in value or "\r" in value:
            raise ContractError(f"execution_environment[{key}] must be a single-line string")
    limits = req.get("limits", {})
    if not isinstance(limits, dict) or set(limits) - {"memory_mb", "file_size_mb"}:
        raise ContractError("limits may contain only memory_mb and file_size_mb")
    if "memory_mb" in limits:
        require_int(limits["memory_mb"], "limits.memory_mb", 64, 1048576)
    if "file_size_mb" in limits:
        require_int(limits["file_size_mb"], "limits.file_size_mb", 1, MAX_OUTPUT_MB)
    clock = req.get("clock", {"mode": "wall_clock"})
    strict_object(clock, "clock", {"mode"}, {"mode"})
    if clock["mode"] not in {"wall_clock", "source_date_epoch"}:
        raise ContractError("clock.mode must be wall_clock or source_date_epoch")
    if "notes" in req and not isinstance(req["notes"], str):
        raise ContractError("notes must be a string")
    req["inventory"] = inventory
    req["execution_environment"] = env
    req["limits"] = limits
    req["clock"] = clock
    req.setdefault("expected_sha256", {})
    req.setdefault("notes", "")
    analysis.setdefault("timeout_seconds", 300)
    inventory.setdefault("options", [])
    inventory.setdefault("timeout_seconds", 60)
    return req


def make_source_manifest(workspace: pathlib.Path, paths: list[str], expected: dict[str, str], phase: str) -> dict[str, Any]:
    files = []
    for rel in paths:
        p = resolve_inside(workspace, rel, file_only=True)
        digest = sha256_file(p)
        exp = expected.get(rel)
        files.append({
            "path": rel,
            "size_bytes": p.stat().st_size,
            "sha256": digest,
            "expected_sha256": exp,
            "expected_match": None if exp is None else digest == exp,
        })
    return {"schema_version": SCHEMA_VERSION, "phase": phase, "workspace_root_sha256_disclosure": "PATH_NOT_HASHED", "files": files}


def compare_manifests(before: dict[str, Any], after: dict[str, Any]) -> list[dict[str, str]]:
    b = {x["path"]: x["sha256"] for x in before["files"]}
    a = {x["path"]: x["sha256"] for x in after["files"]}
    return [{"path": p, "before_sha256": b[p], "after_sha256": a[p]} for p in sorted(b) if b[p] != a[p]]


def safe_environment(overrides: dict[str, str]) -> dict[str, str]:
    env = {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "HOME": os.environ.get("HOME", ""),
        "TMPDIR": os.environ.get("TMPDIR", "/tmp"),
        "LC_ALL": "C",
        "LANG": "C",
        "TZ": "UTC",
    }
    env.update(overrides)
    return env


def preexec_limits(memory_mb: int | None, file_size_mb: int | None):
    def apply() -> None:
        if memory_mb is not None:
            amount = memory_mb * 1024 * 1024
            resource.setrlimit(resource.RLIMIT_AS, (amount, amount))
        if file_size_mb is not None:
            amount = file_size_mb * 1024 * 1024
            resource.setrlimit(resource.RLIMIT_FSIZE, (amount, amount))
    return apply


@dataclass
class Invocation:
    name: str
    argv: list[str]
    cwd: pathlib.Path
    timeout_seconds: int
    stdout_path: pathlib.Path
    stderr_path: pathlib.Path
    start_time: str
    end_time: str = ""
    exit_code: int | None = None
    termination: str = "COMPLETED"


def run_invocation(inv: Invocation, env: dict[str, str], limits: dict[str, int], clock: dict[str, Any]) -> None:
    inv.stdout_path.parent.mkdir(parents=True, exist_ok=True)
    with inv.stdout_path.open("wb") as out, inv.stderr_path.open("wb") as err:
        proc = subprocess.Popen(
            inv.argv, cwd=str(inv.cwd), env=env, stdout=out, stderr=err,
            shell=False, start_new_session=True,
            preexec_fn=preexec_limits(limits.get("memory_mb"), limits.get("file_size_mb")),
        )
        try:
            inv.exit_code = proc.wait(timeout=inv.timeout_seconds)
        except subprocess.TimeoutExpired:
            inv.termination = "TIMEOUT"
            try:
                os.killpg(proc.pid, signal.SIGTERM)
                proc.wait(timeout=5)
            except Exception:
                try:
                    os.killpg(proc.pid, signal.SIGKILL)
                except Exception:
                    pass
                proc.wait()
            inv.exit_code = proc.returncode
    inv.end_time = utc_timestamp(clock)


def parse_json_file(path: pathlib.Path) -> tuple[Any | None, str | None]:
    try:
        return json.loads(path.read_text(encoding="utf-8")), None
    except Exception as exc:
        return None, f"{type(exc).__name__}: {exc}"


def walk_json(value: Any) -> Iterable[dict[str, Any]]:
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from walk_json(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk_json(child)


def normalize_location(value: Any) -> dict[str, Any] | None:
    if not isinstance(value, dict):
        return None
    allowed = ["file", "line", "column", "function", "workingDirectory"]
    result = {k: value[k] for k in allowed if k in value}
    return result or None


def parse_cbmc_json(value: Any) -> dict[str, Any]:
    properties: dict[str, dict[str, Any]] = {}
    inventory: dict[str, dict[str, Any]] = {}
    cprover_statuses: list[str] = []
    messages: list[dict[str, Any]] = []
    trace_property_ids: list[str] = []

    for obj in walk_json(value):
        if "cProverStatus" in obj:
            cprover_statuses.append(str(obj["cProverStatus"]))
        if "messageText" in obj:
            messages.append({
                "message_type": str(obj.get("messageType", "UNKNOWN")),
                "text": str(obj.get("messageText", "")),
            })
        raw_props = obj.get("properties")
        if isinstance(raw_props, list):
            for item in raw_props:
                if not isinstance(item, dict):
                    continue
                pid = str(item.get("name") or item.get("property") or item.get("propertyId") or "")
                if not pid:
                    continue
                inventory[pid] = {
                    "property_id": pid,
                    "class": item.get("class"),
                    "description": item.get("description"),
                    "expression": item.get("expression"),
                    "source_location": normalize_location(item.get("sourceLocation")),
                }
        raw_results = obj.get("result")
        if isinstance(raw_results, list):
            for item in raw_results:
                if not isinstance(item, dict):
                    continue
                pid = str(item.get("property") or item.get("name") or item.get("propertyId") or "")
                if not pid:
                    continue
                status = str(item.get("status", "UNKNOWN"))
                trace_present = isinstance(item.get("trace"), list) and bool(item.get("trace"))
                if trace_present:
                    trace_property_ids.append(pid)
                properties[pid] = {
                    "property_id": pid,
                    "status": status,
                    "description": item.get("description"),
                    "source_location": normalize_location(item.get("sourceLocation")),
                    "trace_present": trace_present,
                }
    statuses = [p["status"].upper() for p in properties.values()]
    failures = sum(1 for s in statuses if s in KNOWN_FAILURE_STATUSES)
    successes = sum(1 for s in statuses if s in KNOWN_SUCCESS_STATUSES)
    unknown = len(statuses) - failures - successes
    return {
        "cprover_statuses": cprover_statuses,
        "properties": [properties[k] for k in sorted(properties)],
        "property_counts": {"total": len(properties), "success": successes, "failure": failures, "unknown": unknown},
        "inventory": [inventory[k] for k in sorted(inventory)],
        "messages": messages,
        "trace_property_ids": sorted(set(trace_property_ids)),
    }


def invocation_record(inv: Invocation, json_error: str | None, parsed: dict[str, Any] | None) -> dict[str, Any]:
    return {
        "name": inv.name,
        "argv": inv.argv,
        "command_display": shlex.join(inv.argv),
        "working_directory": str(inv.cwd),
        "timeout_seconds": inv.timeout_seconds,
        "start_timestamp_utc": inv.start_time,
        "end_timestamp_utc": inv.end_time,
        "termination": inv.termination,
        "exit_code": inv.exit_code,
        "stdout_file": inv.stdout_path.name,
        "stderr_file": inv.stderr_path.name,
        "stdout_sha256": sha256_file(inv.stdout_path),
        "stderr_sha256": sha256_file(inv.stderr_path),
        "stdout_size_bytes": inv.stdout_path.stat().st_size,
        "stderr_size_bytes": inv.stderr_path.stat().st_size,
        "json_parse_error": json_error,
        "parsed_summary": parsed,
    }


def artifact_manifest(artifact_dir: pathlib.Path, declared: list[str]) -> dict[str, Any]:
    entries = []
    for rel in sorted(set(declared)):
        path = artifact_dir / rel
        entries.append({
            "path": f"artifacts/{rel}",
            "exists": path.is_file(),
            "size_bytes": path.stat().st_size if path.is_file() else None,
            "sha256": sha256_file(path) if path.is_file() else None,
        })
    return {"schema_version": SCHEMA_VERSION, "declared_artifacts": entries}


def determine_outcome(analysis: Invocation, parsed: dict[str, Any] | None, parse_error: str | None,
                      mutations: list[dict[str, str]]) -> tuple[str, str, list[str]]:
    warnings: list[str] = []
    if mutations:
        return "SOURCE_MUTATION_DETECTED", "INCOMPLETE", ["One or more tracked inputs changed during execution."]
    if analysis.termination == "TIMEOUT":
        return "TIMEOUT", "INCOMPLETE", ["CBMC analysis exceeded the declared timeout."]
    if parse_error is not None:
        return "UNPARSEABLE_JSON", "INCOMPLETE", ["CBMC stdout was not valid JSON; raw output is preserved."]
    assert parsed is not None
    counts = parsed["property_counts"]
    cstatuses = {s.lower() for s in parsed["cprover_statuses"]}
    if counts["failure"] > 0 or "failure" in cstatuses or "failed" in cstatuses:
        outcome = "FAIL_REPORTED_BY_CBMC"
    elif counts["total"] > 0 and counts["unknown"] == 0 and (counts["success"] == counts["total"]):
        outcome = "PASS_REPORTED_BY_CBMC"
    elif "success" in cstatuses:
        outcome = "PASS_REPORTED_BY_CBMC"
    elif analysis.exit_code == 0:
        outcome = "COMPLETED_STATUS_UNKNOWN"
        warnings.append("CBMC completed but the JSON contained no conclusive normalized status.")
    else:
        outcome = "TOOL_ERROR"
        warnings.append("CBMC exited nonzero without a normalized property-failure result.")
    if outcome == "TOOL_ERROR":
        report_status = "INCOMPLETE"
    else:
        report_status = "COMPLETE" if not warnings else "COMPLETE_WITH_WARNINGS"
    return outcome, report_status, warnings


def markdown_report(summary: dict[str, Any]) -> str:
    analysis = summary["analysis"]
    lines = [
        "# CBMC Execution Evidence", "",
        f"- Request: `{summary['request_id']}`",
        f"- Report status: **{summary['report_status']}**",
        f"- Tool outcome: **{summary['tool_outcome']}**",
        f"- Semantic authority: **NONE**",
        f"- CBMC exit code: `{analysis['exit_code']}`",
        f"- Termination: `{analysis['termination']}`",
        "",
        "## Exact analysis command", "", "```text", analysis["command_display"], "```", "",
        "## Normalized property counts", "",
    ]
    parsed = analysis.get("parsed_summary") or {}
    counts = parsed.get("property_counts", {"total": 0, "success": 0, "failure": 0, "unknown": 0})
    for key in ("total", "success", "failure", "unknown"):
        lines.append(f"- {key}: `{counts[key]}`")
    lines += ["", "## Warnings and limitations", ""]
    for warning in summary["warnings"] + summary["limitations"]:
        lines.append(f"- {warning}")
    lines += [
        "",
        "## Interpretation boundary", "",
        "A PASS_REPORTED_BY_CBMC outcome records only what CBMC reported for the exact bounded command, inputs, options, tool version, and environment captured here. It is not a declaration of complete functional correctness, theorem usefulness, assumption validity, source authenticity beyond the tracked hashes, or proof completeness.",
    ]
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Execute an exact CBMC task and preserve evidence")
    parser.add_argument("--request", required=True)
    parser.add_argument("--workspace-root", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--cbmc-path", default="cbmc")
    args = parser.parse_args()

    output = pathlib.Path(args.output_dir).expanduser().absolute()
    try:
        request_path = pathlib.Path(args.request).expanduser().resolve(strict=True)
        raw = json.loads(request_path.read_text(encoding="utf-8"))
        req = validate_request(raw)
        workspace = pathlib.Path(args.workspace_root).expanduser().resolve(strict=True)
        if not workspace.is_dir() or workspace.is_symlink():
            raise ContractError("workspace root must be a non-symlink directory")
        cwd = resolve_inside(workspace, req["working_directory"], file_only=False)
        if not cwd.is_dir():
            raise ContractError("working_directory must resolve to a directory")
        try:
            output.relative_to(workspace)
            raise ContractError("output directory must be outside the workspace root")
        except ValueError:
            pass
        if output.exists():
            raise ContractError("output directory already exists; refusing overwrite")
        cbmc_path = pathlib.Path(args.cbmc_path).expanduser()
        if cbmc_path.is_symlink():
            raise ContractError("--cbmc-path must not be a symlink")
        if cbmc_path.name != "cbmc":
            raise ContractError("--cbmc-path executable basename must be exactly 'cbmc'")
        if cbmc_path.parent != pathlib.Path(".") or cbmc_path.is_absolute():
            cbmc_path = cbmc_path.resolve(strict=True)
            if not cbmc_path.is_file() or cbmc_path.is_symlink() or not os.access(cbmc_path, os.X_OK):
                raise ContractError("--cbmc-path must identify an executable non-symlink file")
            cbmc_exec = str(cbmc_path)
        else:
            import shutil
            found = shutil.which(str(cbmc_path))
            if found is None:
                raise ContractError("cbmc executable was not found on PATH")
            cbmc_exec = str(pathlib.Path(found).resolve())

        # Resolve and verify all tracked inputs before creating output evidence.
        for rel in req["tracked_inputs"]:
            resolve_inside(workspace, rel, file_only=True)
        before = make_source_manifest(workspace, req["tracked_inputs"], req["expected_sha256"], "BEFORE")
        mismatches = [x for x in before["files"] if x["expected_match"] is False]
        if mismatches:
            raise IdentityError("one or more tracked inputs do not match expected SHA-256")

        artifact_dir = output / "artifacts"
        analysis_opts, analysis_artifacts = validate_option_tokens(req["analysis"]["options"], "analysis.options", artifact_dir)
        inventory_opts, inventory_artifacts = validate_option_tokens(req["inventory"]["options"], "inventory.options", artifact_dir)
        if inventory_artifacts:
            raise ContractError("inventory.options may not request execution artifacts")

        output.mkdir(parents=True, mode=0o700)
        artifact_dir.mkdir(mode=0o700)
        source_args = [str(resolve_inside(workspace, rel, file_only=True)) for rel in req["analysis_sources"]]
        analysis_argv = [cbmc_exec, *analysis_opts, "--json-ui", *source_args]
        inventory_argv = [cbmc_exec, *inventory_opts, "--show-properties", "--json-ui", *source_args]
        clock = req["clock"]
        env = safe_environment(req["execution_environment"])

        canonical_req = dict(req)
        canonical_req["resolved_execution"] = {
            "cbmc_path": cbmc_exec,
            "workspace_root": str(workspace),
            "working_directory": str(cwd),
            "analysis_argv": analysis_argv,
            "inventory_argv": inventory_argv if req["inventory"]["enabled"] else None,
            "output_path_disclosure": "OUTPUT_DIRECTORY_NOT_EMBEDDED",
        }
        write_json(output / "canonical_request.json", canonical_req)
        write_json(output / "source_manifest.before.json", before)
        (output / "analysis.command.txt").write_text(shlex.join(analysis_argv) + "\n", encoding="utf-8")
        write_json(output / "analysis.argv.json", analysis_argv)
        if req["inventory"]["enabled"]:
            (output / "inventory.command.txt").write_text(shlex.join(inventory_argv) + "\n", encoding="utf-8")
            write_json(output / "inventory.argv.json", inventory_argv)

        # Capture version as instrumentation, not as the analysis task.
        version = subprocess.run([cbmc_exec, "--version"], cwd=str(cwd), env=env, shell=False,
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
        (output / "cbmc.version.stdout.txt").write_bytes(version.stdout)
        (output / "cbmc.version.stderr.txt").write_bytes(version.stderr)
        environment_snapshot = {
            "schema_version": SCHEMA_VERSION,
            "platform": platform.platform(),
            "python_version": platform.python_version(),
            "cbmc_executable": cbmc_exec,
            "cbmc_version_exit_code": version.returncode,
            "cbmc_version_stdout_sha256": sha256_file(output / "cbmc.version.stdout.txt"),
            "cbmc_version_stderr_sha256": sha256_file(output / "cbmc.version.stderr.txt"),
            "effective_environment": {k: env[k] for k in sorted(env)},
            "secret_variable_policy": "SECRET_LIKE_VARIABLE_NAMES_REJECTED",
        }
        write_json(output / "environment_snapshot.json", environment_snapshot)

        inv_records: list[dict[str, Any]] = []
        if req["inventory"]["enabled"]:
            inv = Invocation("inventory", inventory_argv, cwd, req["inventory"]["timeout_seconds"],
                             output / "inventory.stdout.json", output / "inventory.stderr.txt", utc_timestamp(clock))
            run_invocation(inv, env, req["limits"], clock)
            inv_json, inv_err = parse_json_file(inv.stdout_path)
            inv_parsed = parse_cbmc_json(inv_json) if inv_json is not None else None
            inv_records.append(invocation_record(inv, inv_err, inv_parsed))
            write_json(output / "property_inventory.json", {
                "schema_version": SCHEMA_VERSION,
                "available": inv_parsed is not None,
                "properties": [] if inv_parsed is None else inv_parsed["inventory"],
                "cprover_statuses": [] if inv_parsed is None else inv_parsed["cprover_statuses"],
                "parse_error": inv_err,
                "exit_code": inv.exit_code,
                "termination": inv.termination,
            })
        else:
            write_json(output / "property_inventory.json", {
                "schema_version": SCHEMA_VERSION,
                "available": False,
                "properties": [],
                "cprover_statuses": [],
                "parse_error": None,
                "exit_code": None,
                "termination": "NOT_REQUESTED",
            })

        analysis = Invocation("analysis", analysis_argv, cwd, req["analysis"]["timeout_seconds"],
                              output / "analysis.stdout.json", output / "analysis.stderr.txt", utc_timestamp(clock))
        run_invocation(analysis, env, req["limits"], clock)
        analysis_json, analysis_err = parse_json_file(analysis.stdout_path)
        analysis_parsed = parse_cbmc_json(analysis_json) if analysis_json is not None else None
        analysis_record = invocation_record(analysis, analysis_err, analysis_parsed)
        inv_records.append(analysis_record)

        after = make_source_manifest(workspace, req["tracked_inputs"], req["expected_sha256"], "AFTER")
        write_json(output / "source_manifest.after.json", after)
        mutations = compare_manifests(before, after)
        write_json(output / "source_integrity_comparison.json", {
            "schema_version": SCHEMA_VERSION,
            "unchanged": not mutations,
            "changes": mutations,
        })

        artifacts = artifact_manifest(artifact_dir, analysis_artifacts)
        write_json(output / "execution_artifact_manifest.json", artifacts)
        missing_artifacts = [x["path"] for x in artifacts["declared_artifacts"] if not x["exists"]]
        tool_outcome, report_status, warnings = determine_outcome(analysis, analysis_parsed, analysis_err, mutations)
        if missing_artifacts:
            warnings.append(f"Declared execution artifacts were not produced: {missing_artifacts}")
            if report_status == "COMPLETE":
                report_status = "COMPLETE_WITH_WARNINGS"
        inventory_record = next((x for x in inv_records if x["name"] == "inventory"), None)
        if inventory_record and (inventory_record["termination"] != "COMPLETED" or inventory_record["json_parse_error"]):
            warnings.append("Property inventory was requested but was not completely captured.")
            if report_status == "COMPLETE":
                report_status = "COMPLETE_WITH_WARNINGS"

        limitations = [
            "The wrapper reports CBMC evidence for the exact captured bounded command; it does not establish unbounded or complete program correctness.",
            "The wrapper does not judge whether assumptions, assertions, properties, loop bounds, or source selection are scientifically justified.",
            "Only explicitly declared tracked inputs are protected by before/after SHA-256 comparison.",
            "A normalized status is a mechanical rendering of CBMC JSON fields, not an independent proof judgement.",
        ]
        summary = {
            "schema_version": SCHEMA_VERSION,
            "skill": {"name": "cbmc-execute", "version": SKILL_VERSION},
            "request_id": req["request_id"],
            "semantic_authority": "NONE",
            "analysis_nature": "TOOL_EXECUTION_AND_MECHANICAL_NORMALIZATION_ONLY",
            "report_status": report_status,
            "tool_outcome": tool_outcome,
            "analysis": analysis_record,
            "inventory": inventory_record,
            "source_integrity": {"unchanged": not mutations, "changes": mutations},
            "execution_artifacts": artifacts["declared_artifacts"],
            "warnings": warnings,
            "limitations": limitations,
        }
        write_json(output / "execution_summary.json", summary)
        (output / "execution_report.md").write_text(markdown_report(summary), encoding="utf-8")
        write_json(output / "invocation_manifest.json", {"schema_version": SCHEMA_VERSION, "invocations": inv_records})

        if mutations:
            return 5
        if tool_outcome in {"TIMEOUT", "UNPARSEABLE_JSON", "TOOL_ERROR"}:
            return 2
        return 0

    except IdentityError as exc:
        sys.stderr.write(f"IDENTITY_ERROR: {exc}\n")
        return 4
    except (ContractError, json.JSONDecodeError, OSError, subprocess.SubprocessError) as exc:
        sys.stderr.write(f"CONTRACT_ERROR: {exc}\n")
        return 3
    except Exception as exc:
        sys.stderr.write(f"INTERNAL_ERROR: {type(exc).__name__}: {exc}\n")
        traceback.print_exc(file=sys.stderr)
        return 6


if __name__ == "__main__":
    raise SystemExit(main())
