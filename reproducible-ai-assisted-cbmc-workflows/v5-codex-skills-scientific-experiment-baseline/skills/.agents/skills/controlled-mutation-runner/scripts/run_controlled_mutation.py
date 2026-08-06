#!/usr/bin/env python3
"""Controlled mutation execution for disposable C/CBMC workspaces.

The caller, normally Codex, must supply the exact mutation, rationale, expected
verification effect, source identities, and commands. This utility applies no
reasoning to the mutation and emits no scientific verdict.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import re
import shutil
import signal
import subprocess
import sys
from dataclasses import dataclass
from typing import Any

SCHEMA_VERSION = "1.0"
SKILL_VERSION = "1.0.0-rc1"
MAX_TIMEOUT = 86400
MAX_FILE_BYTES = 16 * 1024 * 1024
SHA_RE = re.compile(r"^[0-9a-f]{64}$")
ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$")
SHELL_META_RE = re.compile(r"(?:[;&|`] |\$\(|\$\{|[<>]|\n|\r)".replace(" ", ""))
KNOWN_FAIL = {"FAILURE", "FAILED", "FAIL", "FALSE", "SATISFIABLE"}
KNOWN_PASS = {"SUCCESS", "PASS", "PASSED", "TRUE", "UNSATISFIABLE"}
FORBIDDEN_CBMC_OPTIONS = {
    "--json-ui", "--xml-ui", "--json-interface", "--xml-interface",
    "--outfile", "-o", "--graphml-witness", "--json-cex", "--dimacs",
    "--smt2", "--write-solver-stats-to", "--version", "--help", "-h", "-?",
}
FORBIDDEN_COMPILER_PREFIXES = (
    "-fplugin", "-specs=", "-wrapper", "-B", "-save-temps", "-dumpbase",
    "-dumpdir", "-o", "-MF", "-MJ", "-fdump", "-fprofile", "-finstrument-functions",
)


class ContractError(Exception):
    pass


class PatchError(Exception):
    pass


@dataclass
class RunResult:
    outcome: str
    exit_code: int | None
    timed_out: bool
    json_parse_status: str
    properties: list[dict[str, Any]]


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
    if "\x00" in value:
        raise ContractError(f"{name} contains NUL")
    return value


def require_bool(value: Any, name: str) -> bool:
    if not isinstance(value, bool):
        raise ContractError(f"{name} must be boolean")
    return value


def require_int(value: Any, name: str, minimum: int, maximum: int) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or not minimum <= value <= maximum:
        raise ContractError(f"{name} must be an integer in [{minimum}, {maximum}]")
    return value


def validate_relpath(value: str, name: str) -> str:
    require_string(value, name)
    p = pathlib.PurePosixPath(value)
    if p.is_absolute() or not p.parts or ".." in p.parts or value in {".", ""}:
        raise ContractError(f"{name} must be a non-empty relative POSIX path without '..'")
    return p.as_posix()


def ensure_no_symlink_components(path: pathlib.Path, root: pathlib.Path) -> None:
    root = root.resolve()
    current = path
    while True:
        if current.exists() and current.is_symlink():
            raise ContractError(f"symlink paths are forbidden: {current}")
        if current == root:
            break
        if current.parent == current:
            raise ContractError(f"path escaped expected root: {path}")
        current = current.parent


def resolve_inside(root: pathlib.Path, rel: str, *, must_exist: bool = True, file_only: bool = False) -> pathlib.Path:
    rel = validate_relpath(rel, "path")
    candidate = root.joinpath(*pathlib.PurePosixPath(rel).parts)
    ensure_no_symlink_components(candidate, root)
    resolved = candidate.resolve(strict=must_exist)
    try:
        resolved.relative_to(root.resolve())
    except ValueError as exc:
        raise ContractError(f"path escapes workspace root: {rel}") from exc
    if file_only and (not resolved.is_file() or resolved.is_symlink()):
        raise ContractError(f"path must be a regular non-symlink file: {rel}")
    return resolved


def ensure_output_outside(workspace_root: pathlib.Path, output_dir: pathlib.Path) -> None:
    if output_dir.exists():
        raise ContractError("output directory must not already exist")
    parent = output_dir.parent.resolve()
    work = workspace_root.resolve()
    try:
        parent.relative_to(work)
        raise ContractError("output directory must be outside the authoritative workspace")
    except ValueError:
        pass
    ensure_no_symlink_components(output_dir.parent, output_dir.parent.resolve())


def validate_tokens(tokens: Any, name: str) -> list[str]:
    if not isinstance(tokens, list) or not all(isinstance(x, str) and x for x in tokens):
        raise ContractError(f"{name} must be an array of non-empty strings")
    result: list[str] = []
    for i, token in enumerate(tokens):
        if "\x00" in token or SHELL_META_RE.search(token):
            raise ContractError(f"{name}[{i}] contains forbidden shell/control syntax")
        if token.startswith("@"):
            raise ContractError(f"{name}[{i}] uses a hidden argument file")
        result.append(token)
    return result


def validate_cbmc_options(tokens: Any) -> list[str]:
    result = validate_tokens(tokens, "execution.cbmc.arguments")
    for i, token in enumerate(result):
        if token in FORBIDDEN_CBMC_OPTIONS or any(token.startswith(x + "=") for x in FORBIDDEN_CBMC_OPTIONS):
            raise ContractError(f"execution.cbmc.arguments[{i}] conflicts with controlled evidence output: {token}")
    return result


def validate_compiler_options(tokens: Any) -> list[str]:
    result = validate_tokens(tokens, "execution.syntax_check.arguments")
    if "-fsyntax-only" not in result:
        raise ContractError("syntax_check.arguments must include -fsyntax-only")
    for i, token in enumerate(result):
        if token.startswith(FORBIDDEN_COMPILER_PREFIXES):
            raise ContractError(f"syntax_check.arguments[{i}] contains forbidden output/plugin option: {token}")
        if token.startswith("-I") and token != "-I":
            value = token[2:]
            if pathlib.PurePosixPath(value).is_absolute() or ".." in pathlib.PurePosixPath(value).parts:
                raise ContractError(f"syntax_check.arguments[{i}] include path must stay inside disposable workspace")
    # Reject split path/output options conservatively.
    for forbidden in {"-I", "-isystem", "-include", "-imacros", "-iquote"}:
        if forbidden in result:
            idxs = [i for i, x in enumerate(result) if x == forbidden]
            for idx in idxs:
                if idx + 1 >= len(result):
                    raise ContractError(f"{forbidden} requires a path")
                validate_relpath(result[idx + 1], f"syntax_check argument after {forbidden}")
    return result


def validate_request(raw: Any) -> dict[str, Any]:
    req = strict_object(
        raw,
        "request",
        {"schema_version", "request_id", "experiment_timestamp", "target_symbol", "files", "mutation", "execution", "expected_transition", "notes"},
        {"schema_version", "request_id", "experiment_timestamp", "files", "mutation", "execution"},
    )
    if req["schema_version"] != SCHEMA_VERSION:
        raise ContractError(f"schema_version must be {SCHEMA_VERSION}")
    if not ID_RE.fullmatch(require_string(req["request_id"], "request_id")):
        raise ContractError("request_id has invalid characters")
    require_string(req["experiment_timestamp"], "experiment_timestamp")
    if "target_symbol" in req and req["target_symbol"] is not None:
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", require_string(req["target_symbol"], "target_symbol")):
            raise ContractError("target_symbol must be a C identifier")
    if "notes" in req and not isinstance(req["notes"], str):
        raise ContractError("notes must be a string")

    files = req["files"]
    if not isinstance(files, list) or not files:
        raise ContractError("files must be a non-empty array")
    normalized_files = []
    seen: set[str] = set()
    for i, item in enumerate(files):
        item = strict_object(item, f"files[{i}]", {"path", "role", "expected_sha256", "mutation_allowed"}, {"path", "role", "expected_sha256", "mutation_allowed"})
        path = validate_relpath(item["path"], f"files[{i}].path")
        if path in seen:
            raise ContractError(f"duplicate file path: {path}")
        seen.add(path)
        role = require_string(item["role"], f"files[{i}].role")
        digest = require_string(item["expected_sha256"], f"files[{i}].expected_sha256")
        if not SHA_RE.fullmatch(digest):
            raise ContractError(f"files[{i}].expected_sha256 must be lowercase SHA-256")
        allowed = require_bool(item["mutation_allowed"], f"files[{i}].mutation_allowed")
        normalized_files.append({"path": path, "role": role, "expected_sha256": digest, "mutation_allowed": allowed})
    req["files"] = normalized_files

    mut = strict_object(req["mutation"], "mutation", {"mutation_id", "patch_path", "expected_sha256", "rationale", "expected_effect"}, {"mutation_id", "patch_path", "expected_sha256", "rationale", "expected_effect"})
    if not ID_RE.fullmatch(require_string(mut["mutation_id"], "mutation.mutation_id")):
        raise ContractError("mutation.mutation_id has invalid characters")
    mut["patch_path"] = validate_relpath(mut["patch_path"], "mutation.patch_path")
    if not SHA_RE.fullmatch(require_string(mut["expected_sha256"], "mutation.expected_sha256")):
        raise ContractError("mutation.expected_sha256 must be lowercase SHA-256")
    require_string(mut["rationale"], "mutation.rationale")
    require_string(mut["expected_effect"], "mutation.expected_effect")

    execution = strict_object(req["execution"], "execution", {"cbmc", "syntax_check"}, {"cbmc"})
    cbmc = strict_object(execution["cbmc"], "execution.cbmc", {"executable", "sources", "arguments", "timeout_seconds", "required"}, {"executable", "sources", "arguments", "timeout_seconds", "required"})
    exe = require_string(cbmc["executable"], "execution.cbmc.executable")
    if pathlib.Path(exe).name != "cbmc":
        raise ContractError("CBMC executable basename must be exactly 'cbmc'")
    sources = cbmc["sources"]
    if not isinstance(sources, list) or not sources:
        raise ContractError("execution.cbmc.sources must be a non-empty array")
    cbmc["sources"] = [validate_relpath(x, f"execution.cbmc.sources[{i}]") for i, x in enumerate(sources)]
    if len(cbmc["sources"]) != len(set(cbmc["sources"])):
        raise ContractError("execution.cbmc.sources contains duplicates")
    if not set(cbmc["sources"]).issubset(seen):
        raise ContractError("all execution.cbmc.sources must be declared in files")
    cbmc["arguments"] = validate_cbmc_options(cbmc["arguments"])
    cbmc["timeout_seconds"] = require_int(cbmc["timeout_seconds"], "execution.cbmc.timeout_seconds", 1, MAX_TIMEOUT)
    require_bool(cbmc["required"], "execution.cbmc.required")

    syntax = execution.get("syntax_check", {"enabled": False, "required": False, "executable": "gcc", "sources": [], "arguments": ["-fsyntax-only"], "timeout_seconds": 60})
    syntax = strict_object(syntax, "execution.syntax_check", {"enabled", "required", "executable", "sources", "arguments", "timeout_seconds"}, {"enabled", "required", "executable", "sources", "arguments", "timeout_seconds"})
    enabled = require_bool(syntax["enabled"], "execution.syntax_check.enabled")
    required = require_bool(syntax["required"], "execution.syntax_check.required")
    if required and not enabled:
        raise ContractError("syntax_check.required cannot be true when disabled")
    compiler = require_string(syntax["executable"], "execution.syntax_check.executable")
    if pathlib.Path(compiler).name not in {"gcc", "clang", "cc"}:
        raise ContractError("syntax checker executable basename must be gcc, clang, or cc")
    ssources = syntax["sources"]
    if not isinstance(ssources, list):
        raise ContractError("execution.syntax_check.sources must be an array")
    syntax["sources"] = [validate_relpath(x, f"execution.syntax_check.sources[{i}]") for i, x in enumerate(ssources)]
    if enabled and not syntax["sources"]:
        raise ContractError("enabled syntax check requires source files")
    if not set(syntax["sources"]).issubset(seen):
        raise ContractError("all syntax_check.sources must be declared in files")
    syntax["arguments"] = validate_compiler_options(syntax["arguments"])
    syntax["timeout_seconds"] = require_int(syntax["timeout_seconds"], "execution.syntax_check.timeout_seconds", 1, MAX_TIMEOUT)
    execution["syntax_check"] = syntax

    transition = req.get("expected_transition")
    if transition is not None:
        transition = strict_object(transition, "expected_transition", {"property_id", "baseline_allowed_statuses", "mutant_allowed_statuses"}, {"property_id", "baseline_allowed_statuses", "mutant_allowed_statuses"})
        require_string(transition["property_id"], "expected_transition.property_id")
        for key in ("baseline_allowed_statuses", "mutant_allowed_statuses"):
            vals = transition[key]
            if not isinstance(vals, list) or not vals or not all(isinstance(x, str) and x for x in vals):
                raise ContractError(f"expected_transition.{key} must be a non-empty string array")
            transition[key] = sorted(set(x.upper() for x in vals))
        req["expected_transition"] = transition

    req["execution"] = execution
    req.setdefault("target_symbol", None)
    req.setdefault("expected_transition", None)
    req.setdefault("notes", "")
    return req


def manifest_files(root: pathlib.Path, declared: list[dict[str, Any]], phase: str) -> dict[str, Any]:
    entries = []
    for item in declared:
        path = resolve_inside(root, item["path"], file_only=True)
        if path.stat().st_size > MAX_FILE_BYTES:
            raise ContractError(f"declared file exceeds {MAX_FILE_BYTES} bytes: {item['path']}")
        actual = sha256_file(path)
        entries.append({
            "path": item["path"],
            "role": item["role"],
            "mutation_allowed": item["mutation_allowed"],
            "expected_sha256": item["expected_sha256"],
            "actual_sha256": actual,
            "hash_match": actual == item["expected_sha256"],
            "size_bytes": path.stat().st_size,
        })
    return {"schema_version": SCHEMA_VERSION, "phase": phase, "files": entries}


def compare_manifests(before: dict[str, Any], after: dict[str, Any]) -> dict[str, Any]:
    b = {x["path"]: x for x in before["files"]}
    a = {x["path"]: x for x in after["files"]}
    changes = []
    for path in sorted(set(b) | set(a)):
        if path not in b or path not in a or b[path]["actual_sha256"] != a[path]["actual_sha256"]:
            changes.append({"path": path, "before_sha256": b.get(path, {}).get("actual_sha256"), "after_sha256": a.get(path, {}).get("actual_sha256")})
    return {
        "schema_version": SCHEMA_VERSION,
        "authoritative_tree_unchanged": not changes,
        "changed_files": changes,
        "restoration_interpretation": "NO_AUTHORITATIVE_EDIT_WAS_REQUIRED" if not changes else "AUTHORITATIVE_INPUT_CHANGED_DURING_RUN",
    }


def copy_declared_workspace(root: pathlib.Path, destination: pathlib.Path, declared: list[dict[str, Any]]) -> None:
    destination.mkdir(parents=True, exist_ok=False)
    for item in declared:
        src = resolve_inside(root, item["path"], file_only=True)
        dst = destination.joinpath(*pathlib.PurePosixPath(item["path"]).parts)
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, dst)
        os.chmod(dst, 0o600)


def strip_patch_prefix(path_text: str, prefix: str) -> str:
    path_text = path_text.split("\t", 1)[0].strip()
    if path_text == "/dev/null":
        raise PatchError("file creation/deletion patches are forbidden")
    if not path_text.startswith(prefix):
        raise PatchError(f"patch path must begin with {prefix!r}: {path_text}")
    return validate_relpath(path_text[len(prefix):], "patch path")


def apply_restricted_unified_diff(patch_bytes: bytes, mutant_root: pathlib.Path, declared: dict[str, dict[str, Any]]) -> list[dict[str, Any]]:
    if b"\x00" in patch_bytes:
        raise PatchError("binary/NUL-containing patches are forbidden")
    try:
        text = patch_bytes.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise PatchError("patch must be UTF-8 text") from exc
    if not text.endswith("\n"):
        raise PatchError("patch must end with a newline")
    if "GIT binary patch" in text or "Binary files " in text or "rename from " in text or "rename to " in text:
        raise PatchError("binary and rename patches are forbidden")
    lines = text.splitlines(keepends=True)
    i = 0
    changes: list[dict[str, Any]] = []
    while i < len(lines):
        # Ignore standard git metadata that does not change semantics.
        if lines[i].startswith(("diff --git ", "index ")):
            i += 1
            continue
        if not lines[i].startswith("--- "):
            raise PatchError(f"expected '---' file header at patch line {i + 1}")
        old_path = strip_patch_prefix(lines[i][4:].rstrip("\n"), "a/")
        i += 1
        if i >= len(lines) or not lines[i].startswith("+++ "):
            raise PatchError("missing '+++' file header")
        new_path = strip_patch_prefix(lines[i][4:].rstrip("\n"), "b/")
        i += 1
        if old_path != new_path:
            raise PatchError("renames are forbidden")
        if old_path not in declared:
            raise PatchError(f"patch touches undeclared file: {old_path}")
        if not declared[old_path]["mutation_allowed"]:
            raise PatchError(f"patch touches file not permitted for mutation: {old_path}")
        file_path = resolve_inside(mutant_root, old_path, file_only=True)
        raw = file_path.read_bytes()
        if b"\x00" in raw:
            raise PatchError(f"mutated file must be text: {old_path}")
        try:
            original = raw.decode("utf-8")
        except UnicodeDecodeError as exc:
            raise PatchError(f"mutated file must be UTF-8: {old_path}") from exc
        if not original.endswith("\n"):
            raise PatchError(f"mutated file must end with newline: {old_path}")
        src_lines = original.splitlines(keepends=True)
        out: list[str] = []
        cursor = 0
        hunk_count = 0
        while i < len(lines) and lines[i].startswith("@@ "):
            m = re.match(r"@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@", lines[i])
            if not m:
                raise PatchError(f"malformed hunk header at line {i + 1}")
            old_start = int(m.group(1))
            old_count = int(m.group(2) or "1")
            new_count = int(m.group(4) or "1")
            target_index = old_start - 1
            if target_index < cursor or target_index > len(src_lines):
                raise PatchError(f"invalid or overlapping hunk for {old_path}")
            out.extend(src_lines[cursor:target_index])
            cursor = target_index
            i += 1
            consumed_old = 0
            produced_new = 0
            while i < len(lines) and not lines[i].startswith(("@@ ", "--- ", "diff --git ", "index ")):
                line = lines[i]
                if line.startswith("\\ No newline at end of file"):
                    raise PatchError("no-newline markers are unsupported")
                if not line or line[0] not in " +-":
                    raise PatchError(f"invalid hunk line at {i + 1}")
                payload = line[1:]
                if line[0] == " ":
                    if cursor >= len(src_lines) or src_lines[cursor] != payload:
                        raise PatchError(f"context mismatch in {old_path} at source line {cursor + 1}")
                    out.append(payload)
                    cursor += 1
                    consumed_old += 1
                    produced_new += 1
                elif line[0] == "-":
                    if cursor >= len(src_lines) or src_lines[cursor] != payload:
                        raise PatchError(f"deletion mismatch in {old_path} at source line {cursor + 1}")
                    cursor += 1
                    consumed_old += 1
                else:
                    out.append(payload)
                    produced_new += 1
                i += 1
            if consumed_old != old_count or produced_new != new_count:
                raise PatchError(f"hunk count mismatch for {old_path}")
            hunk_count += 1
        if hunk_count == 0:
            raise PatchError(f"file patch contains no hunks: {old_path}")
        out.extend(src_lines[cursor:])
        mutated = "".join(out).encode("utf-8")
        before_sha = hashlib.sha256(raw).hexdigest()
        after_sha = hashlib.sha256(mutated).hexdigest()
        if before_sha == after_sha:
            raise PatchError(f"patch made no byte change: {old_path}")
        file_path.write_bytes(mutated)
        changes.append({
            "path": old_path,
            "before_sha256": before_sha,
            "after_sha256": after_sha,
            "before_size_bytes": len(raw),
            "after_size_bytes": len(mutated),
            "hunk_count": hunk_count,
        })
    if not changes:
        raise PatchError("patch contains no file changes")
    paths = [x["path"] for x in changes]
    if len(paths) != len(set(paths)):
        raise PatchError("multiple file sections for the same path are forbidden")
    return changes


def safe_env(workspace: pathlib.Path) -> dict[str, str]:
    env = {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "LANG": "C",
        "LC_ALL": "C",
        "TZ": "UTC",
        "HOME": str(workspace),
    }
    return env


def run_process(argv: list[str], cwd: pathlib.Path, timeout: int, stdout_path: pathlib.Path, stderr_path: pathlib.Path) -> tuple[int | None, bool]:
    timed_out = False
    proc = subprocess.Popen(
        argv,
        cwd=str(cwd),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=safe_env(cwd),
        shell=False,
        start_new_session=True,
    )
    try:
        stdout, stderr = proc.communicate(timeout=timeout)
        code: int | None = proc.returncode
    except subprocess.TimeoutExpired:
        timed_out = True
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        stdout, stderr = proc.communicate()
        code = None
    stdout_path.write_text(stdout, encoding="utf-8")
    stderr_path.write_text(stderr, encoding="utf-8")
    return code, timed_out


def normalize_properties(value: Any) -> list[dict[str, Any]]:
    found: list[dict[str, Any]] = []

    def walk(node: Any) -> None:
        if isinstance(node, dict):
            prop = node.get("property") or node.get("propertyId") or node.get("property_id")
            status = node.get("status") or node.get("result")
            if isinstance(prop, str) and isinstance(status, str):
                found.append({
                    "property_id": prop,
                    "status": status.upper(),
                    "description": node.get("description") if isinstance(node.get("description"), str) else None,
                    "trace_present": isinstance(node.get("trace"), list) and bool(node.get("trace")),
                })
            for child in node.values():
                walk(child)
        elif isinstance(node, list):
            for child in node:
                walk(child)

    walk(value)
    unique: dict[tuple[str, str, str | None, bool], dict[str, Any]] = {}
    for item in found:
        key = (item["property_id"], item["status"], item["description"], item["trace_present"])
        unique[key] = item
    return sorted(unique.values(), key=lambda x: (x["property_id"], x["status"], x["description"] or ""))


def classify_cbmc(exit_code: int | None, timed_out: bool, parse_status: str, properties: list[dict[str, Any]]) -> str:
    if timed_out:
        return "TIMEOUT"
    if parse_status != "PARSED":
        return "UNPARSEABLE_JSON"
    statuses = {p["status"] for p in properties}
    if statuses & KNOWN_FAIL:
        return "FAIL_REPORTED_BY_CBMC"
    if properties and statuses <= KNOWN_PASS:
        return "PASS_REPORTED_BY_CBMC"
    if exit_code not in {0, 10}:
        return "TOOL_ERROR"
    return "COMPLETED_STATUS_UNKNOWN"


def execute_cbmc(label: str, workspace: pathlib.Path, output: pathlib.Path, config: dict[str, Any]) -> RunResult:
    output.mkdir(parents=True, exist_ok=False)
    argv = [config["executable"], *config["arguments"], "--json-ui", *config["sources"]]
    write_json(output / "cbmc.argv.json", argv)
    (output / "cbmc.command.txt").write_text(" ".join(argv) + "\n", encoding="utf-8")
    code, timed_out = run_process(argv, workspace, config["timeout_seconds"], output / "cbmc.stdout.json", output / "cbmc.stderr.txt")
    parse_status = "NOT_PARSED"
    properties: list[dict[str, Any]] = []
    if not timed_out:
        try:
            raw = json.loads((output / "cbmc.stdout.json").read_text(encoding="utf-8"))
            parse_status = "PARSED"
            properties = normalize_properties(raw)
        except (json.JSONDecodeError, OSError):
            parse_status = "MALFORMED_OR_MISSING_JSON"
    outcome = classify_cbmc(code, timed_out, parse_status, properties)
    result = {
        "schema_version": SCHEMA_VERSION,
        "label": label,
        "outcome": outcome,
        "exit_code": code,
        "timed_out": timed_out,
        "json_parse_status": parse_status,
        "properties": properties,
        "semantic_authority": "NONE",
        "limitations": [
            "This records CBMC output for the captured bounded invocation only.",
            "A PASS_REPORTED_BY_CBMC value is not complete program correctness.",
            "This runner does not interpret the mathematical meaning of any status change.",
        ],
    }
    write_json(output / "cbmc.result.json", result)
    return RunResult(outcome, code, timed_out, parse_status, properties)


def execute_syntax(label: str, workspace: pathlib.Path, output: pathlib.Path, config: dict[str, Any]) -> dict[str, Any]:
    output.mkdir(parents=True, exist_ok=False)
    if not config["enabled"]:
        result = {"schema_version": SCHEMA_VERSION, "label": label, "status": "NOT_REQUESTED", "exit_code": None, "timed_out": False}
        write_json(output / "syntax_check.result.json", result)
        return result
    argv = [config["executable"], *config["arguments"], *config["sources"]]
    write_json(output / "syntax_check.argv.json", argv)
    (output / "syntax_check.command.txt").write_text(" ".join(argv) + "\n", encoding="utf-8")
    code, timed_out = run_process(argv, workspace, config["timeout_seconds"], output / "syntax_check.stdout.txt", output / "syntax_check.stderr.txt")
    status = "TIMEOUT" if timed_out else ("PASSED" if code == 0 else "FAILED")
    result = {"schema_version": SCHEMA_VERSION, "label": label, "status": status, "exit_code": code, "timed_out": timed_out}
    write_json(output / "syntax_check.result.json", result)
    return result


def property_statuses(properties: list[dict[str, Any]], property_id: str) -> list[str]:
    return sorted({x["status"] for x in properties if x["property_id"] == property_id})


def compare_results(req: dict[str, Any], baseline: RunResult, mutant: RunResult, baseline_syntax: dict[str, Any], mutant_syntax: dict[str, Any]) -> dict[str, Any]:
    transition = req.get("expected_transition")
    observed = None
    match = "NOT_DECLARED"
    warnings: list[str] = []
    if transition:
        b = property_statuses(baseline.properties, transition["property_id"])
        m = property_statuses(mutant.properties, transition["property_id"])
        observed = {"property_id": transition["property_id"], "baseline_statuses": b, "mutant_statuses": m}
        if not b or not m:
            match = "INDETERMINATE"
            warnings.append("The caller-selected property was not observed exactly once in both runs.")
        else:
            b_ok = set(b).issubset(set(transition["baseline_allowed_statuses"]))
            m_ok = set(m).issubset(set(transition["mutant_allowed_statuses"]))
            match = "MATCHES_CALLER_DECLARATION" if b_ok and m_ok else "DIFFERS_FROM_CALLER_DECLARATION"
    property_map_b = {x["property_id"]: sorted({y["status"] for y in baseline.properties if y["property_id"] == x["property_id"]}) for x in baseline.properties}
    property_map_m = {x["property_id"]: sorted({y["status"] for y in mutant.properties if y["property_id"] == x["property_id"]}) for x in mutant.properties}
    changed = []
    for pid in sorted(set(property_map_b) | set(property_map_m)):
        if property_map_b.get(pid, []) != property_map_m.get(pid, []):
            changed.append({"property_id": pid, "baseline_statuses": property_map_b.get(pid, []), "mutant_statuses": property_map_m.get(pid, [])})
    return {
        "schema_version": SCHEMA_VERSION,
        "request_id": req["request_id"],
        "mutation_id": req["mutation"]["mutation_id"],
        "caller_supplied_rationale": req["mutation"]["rationale"],
        "caller_supplied_expected_effect": req["mutation"]["expected_effect"],
        "baseline_cbmc_outcome": baseline.outcome,
        "mutant_cbmc_outcome": mutant.outcome,
        "baseline_syntax_status": baseline_syntax["status"],
        "mutant_syntax_status": mutant_syntax["status"],
        "property_status_changes": changed,
        "declared_transition_observation": observed,
        "declared_transition_match": match,
        "warnings": warnings,
        "semantic_authority": "NONE",
        "interpretation_boundary": [
            "A property-status difference is an observed tool-output difference, not a judgement that the mutation is scientifically meaningful.",
            "MATCHES_CALLER_DECLARATION compares recorded status strings only.",
            "Codex and the researcher must interpret the mutation, property, assumptions, and bounded analysis.",
        ],
    }


def generated_manifest(output_dir: pathlib.Path) -> dict[str, Any]:
    entries = []
    for path in sorted(output_dir.rglob("*")):
        if path.is_file() and path.name not in {"controlled_mutation_artifact_manifest.json"} and "._work" not in path.parts:
            entries.append({
                "path": path.relative_to(output_dir).as_posix(),
                "sha256": sha256_file(path),
                "size_bytes": path.stat().st_size,
            })
    return {"schema_version": SCHEMA_VERSION, "files": entries}


def markdown_report(req: dict[str, Any], patch_report: dict[str, Any], comparison: dict[str, Any], integrity: dict[str, Any], cleanup: dict[str, Any], final_status: str, warnings: list[str]) -> str:
    lines = [
        "# Controlled Mutation Run",
        "",
        f"- Request: `{req['request_id']}`",
        f"- Mutation: `{req['mutation']['mutation_id']}`",
        f"- Target symbol: `{req.get('target_symbol') or 'NOT_SUPPLIED'}`",
        f"- Execution status: **{final_status}**",
        f"- Semantic authority: **NONE**",
        "",
        "## Caller declarations",
        "",
        f"- Rationale: {req['mutation']['rationale']}",
        f"- Expected effect: {req['mutation']['expected_effect']}",
        "",
        "## Patch application",
        "",
        f"- Result: `{patch_report['status']}`",
        f"- Touched files: {len(patch_report.get('touched_files', []))}",
        "",
        "## Execution comparison",
        "",
        f"- Baseline CBMC: `{comparison['baseline_cbmc_outcome']}`",
        f"- Mutant CBMC: `{comparison['mutant_cbmc_outcome']}`",
        f"- Baseline syntax: `{comparison['baseline_syntax_status']}`",
        f"- Mutant syntax: `{comparison['mutant_syntax_status']}`",
        f"- Declared transition comparison: `{comparison['declared_transition_match']}`",
        f"- Changed property-status records: {len(comparison['property_status_changes'])}",
        "",
        "## Authoritative source and cleanup",
        "",
        f"- Authoritative tree unchanged: `{integrity['authoritative_tree_unchanged']}`",
        f"- Disposable workspaces removed: `{cleanup['disposable_workspaces_removed']}`",
        f"- Restoration interpretation: `{integrity['restoration_interpretation']}`",
        "",
        "## Warnings",
        "",
    ]
    if warnings:
        lines.extend([f"- {x}" for x in warnings])
    else:
        lines.append("- None recorded.")
    lines.extend([
        "",
        "## Mandatory limitation",
        "",
        "This report records an exact caller-designed mutation and bounded tool-output comparison. It does not determine whether the mutation is realistic, whether the property is useful or complete, or whether the implementation is correct.",
        "",
    ])
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--request", required=True)
    parser.add_argument("--workspace-root", required=True)
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args(argv)

    request_path = pathlib.Path(args.request).resolve()
    workspace_root = pathlib.Path(args.workspace_root).resolve()
    output_dir = pathlib.Path(args.output_dir).resolve()
    work_root: pathlib.Path | None = None
    created_output = False
    final_exit = 2

    try:
        if not request_path.is_file() or request_path.is_symlink():
            raise ContractError("request must be a regular non-symlink file")
        if not workspace_root.is_dir() or workspace_root.is_symlink():
            raise ContractError("workspace root must be a regular non-symlink directory")
        ensure_output_outside(workspace_root, output_dir)
        raw = json.loads(request_path.read_text(encoding="utf-8"))
        req = validate_request(raw)

        before = manifest_files(workspace_root, req["files"], "BEFORE")
        mismatches = [x["path"] for x in before["files"] if not x["hash_match"]]
        if mismatches:
            raise ContractError(f"authoritative input SHA-256 mismatch: {mismatches}")
        patch_path = resolve_inside(workspace_root, req["mutation"]["patch_path"], file_only=True)
        patch_bytes = patch_path.read_bytes()
        patch_sha = hashlib.sha256(patch_bytes).hexdigest()
        if patch_sha != req["mutation"]["expected_sha256"]:
            raise ContractError("mutation patch SHA-256 mismatch")
        if len(patch_bytes) > MAX_FILE_BYTES:
            raise ContractError("mutation patch exceeds size limit")

        output_dir.mkdir(parents=True, exist_ok=False)
        created_output = True
        write_json(output_dir / "canonical_request.json", req)
        write_json(output_dir / "authoritative_manifest.before.json", before)
        patch_manifest = {
            "schema_version": SCHEMA_VERSION,
            "path": req["mutation"]["patch_path"],
            "expected_sha256": req["mutation"]["expected_sha256"],
            "actual_sha256": patch_sha,
            "hash_match": True,
            "size_bytes": len(patch_bytes),
        }
        write_json(output_dir / "patch_input_manifest.json", patch_manifest)
        (output_dir / "applied.patch").write_bytes(patch_bytes)

        work_root = output_dir / "._work"
        baseline_workspace = work_root / "baseline"
        mutant_workspace = work_root / "mutant"
        work_root.mkdir(parents=True, exist_ok=False)
        copy_declared_workspace(workspace_root, baseline_workspace, req["files"])
        copy_declared_workspace(workspace_root, mutant_workspace, req["files"])
        declared_map = {x["path"]: x for x in req["files"]}
        touched = apply_restricted_unified_diff(patch_bytes, mutant_workspace, declared_map)
        patch_report = {
            "schema_version": SCHEMA_VERSION,
            "status": "APPLIED_TO_DISPOSABLE_COPY",
            "mutation_id": req["mutation"]["mutation_id"],
            "touched_files": touched,
            "authoritative_tree_edited": False,
            "semantic_authority": "NONE",
        }
        write_json(output_dir / "patch_application_report.json", patch_report)
        write_json(output_dir / "mutated_file_manifest.json", {"schema_version": SCHEMA_VERSION, "files": touched})

        baseline_dir = output_dir / "baseline"
        mutant_dir = output_dir / "mutant"
        baseline_syntax = execute_syntax("baseline", baseline_workspace, baseline_dir / "syntax", req["execution"]["syntax_check"])
        mutant_syntax = execute_syntax("mutant", mutant_workspace, mutant_dir / "syntax", req["execution"]["syntax_check"])
        baseline_cbmc = execute_cbmc("baseline", baseline_workspace, baseline_dir / "cbmc", req["execution"]["cbmc"])
        mutant_cbmc = execute_cbmc("mutant", mutant_workspace, mutant_dir / "cbmc", req["execution"]["cbmc"])

        comparison = compare_results(req, baseline_cbmc, mutant_cbmc, baseline_syntax, mutant_syntax)
        write_json(output_dir / "comparison_report.json", comparison)

        after = manifest_files(workspace_root, req["files"], "AFTER")
        write_json(output_dir / "authoritative_manifest.after.json", after)
        integrity = compare_manifests(before, after)
        write_json(output_dir / "authoritative_integrity_comparison.json", integrity)

        warnings = list(comparison["warnings"])
        syntax = req["execution"]["syntax_check"]
        required_failure = False
        if syntax["enabled"]:
            if baseline_syntax["status"] != "PASSED" or mutant_syntax["status"] != "PASSED":
                msg = "One or both syntax checks did not pass."
                warnings.append(msg)
                if syntax["required"]:
                    required_failure = True
        cbmc_cfg = req["execution"]["cbmc"]
        incomplete_outcomes = {"TIMEOUT", "UNPARSEABLE_JSON", "TOOL_ERROR"}
        if baseline_cbmc.outcome in incomplete_outcomes or mutant_cbmc.outcome in incomplete_outcomes:
            warnings.append("One or both CBMC runs were incomplete or tool-error outcomes.")
            if cbmc_cfg["required"]:
                required_failure = True
        if not integrity["authoritative_tree_unchanged"]:
            required_failure = True
            warnings.append("Authoritative input mutation was detected.")

        # Remove disposable copies before writing final cleanup evidence.
        cleanup_error = None
        try:
            shutil.rmtree(work_root)
        except Exception as exc:  # pragma: no cover - defensive
            cleanup_error = f"{type(exc).__name__}: {exc}"
        cleanup = {
            "schema_version": SCHEMA_VERSION,
            "disposable_workspaces_removed": cleanup_error is None and not work_root.exists(),
            "cleanup_error": cleanup_error,
            "authoritative_restoration_required": False,
            "authoritative_tree_unchanged": integrity["authoritative_tree_unchanged"],
            "restoration_confirmation": "NO_AUTHORITATIVE_EDIT_OCCURRED" if integrity["authoritative_tree_unchanged"] else "AUTHORITATIVE_CHANGE_DETECTED",
        }
        write_json(output_dir / "cleanup_and_restoration_report.json", cleanup)
        if not cleanup["disposable_workspaces_removed"]:
            required_failure = True
            warnings.append("Disposable workspace cleanup could not be confirmed.")

        final_status = "INCOMPLETE" if required_failure else ("COMPLETE_WITH_WARNINGS" if warnings else "COMPLETE")
        comparison["execution_completeness_status"] = final_status
        comparison["warnings"] = sorted(set(warnings))
        write_json(output_dir / "comparison_report.json", comparison)
        (output_dir / "comparison_report.md").write_text(
            markdown_report(req, patch_report, comparison, integrity, cleanup, final_status, comparison["warnings"]),
            encoding="utf-8",
        )
        write_json(output_dir / "controlled_mutation_artifact_manifest.json", generated_manifest(output_dir))
        final_exit = 0 if final_status != "INCOMPLETE" else 2
        return final_exit
    except (ContractError, PatchError, json.JSONDecodeError, UnicodeDecodeError) as exc:
        if created_output:
            error = {
                "schema_version": SCHEMA_VERSION,
                "status": "INCOMPLETE",
                "error_type": type(exc).__name__,
                "message": str(exc),
                "semantic_authority": "NONE",
            }
            write_json(output_dir / "error_report.json", error)
            if work_root and work_root.exists():
                shutil.rmtree(work_root, ignore_errors=True)
            write_json(output_dir / "controlled_mutation_artifact_manifest.json", generated_manifest(output_dir))
        else:
            print(f"ERROR: {exc}", file=sys.stderr)
        return 2
    except Exception as exc:  # pragma: no cover - defensive
        if created_output:
            write_json(output_dir / "error_report.json", {
                "schema_version": SCHEMA_VERSION,
                "status": "INCOMPLETE",
                "error_type": type(exc).__name__,
                "message": str(exc),
                "semantic_authority": "NONE",
            })
            if work_root and work_root.exists():
                shutil.rmtree(work_root, ignore_errors=True)
            write_json(output_dir / "controlled_mutation_artifact_manifest.json", generated_manifest(output_dir))
        else:
            print(f"UNEXPECTED ERROR: {exc}", file=sys.stderr)
        return 3


if __name__ == "__main__":
    raise SystemExit(main())
