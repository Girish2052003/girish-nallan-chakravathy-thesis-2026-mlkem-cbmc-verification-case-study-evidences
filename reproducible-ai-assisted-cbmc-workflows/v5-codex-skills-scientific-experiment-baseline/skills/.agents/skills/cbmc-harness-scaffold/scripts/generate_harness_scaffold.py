#!/usr/bin/env python3
"""Generate a neutral C/CBMC harness scaffold from a strict structured request.

This utility intentionally performs no theorem selection, assumption generation,
assertion generation, property discovery, or semantic verification reasoning.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shlex
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

SKILL_NAME = "cbmc-harness-scaffold"
SKILL_VERSION = "1.0.0-rc1"
SCHEMA_VERSION = "1.0"

IDENT_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
TYPE_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*(?:[ \t]+[A-Za-z_][A-Za-z0-9_]*|[ \t]*\*+)*$")
DIM_RE = re.compile(r"^(?:[1-9][0-9]*|[A-Za-z_][A-Za-z0-9_]*)$")
ARG_RE = re.compile(
    r"^[&*]?[A-Za-z_][A-Za-z0-9_]*"
    r"(?:(?:->|\.)[A-Za-z_][A-Za-z0-9_]*|\[(?:[0-9]+|[A-Za-z_][A-Za-z0-9_]*)\])*$"
)
INCLUDE_RE = re.compile(r"^[A-Za-z0-9_./+\-]+$")
DEFINE_VALUE_RE = re.compile(r"^[A-Za-z0-9_()+\-*/.%]+$")
HASH_RE = re.compile(r"^[0-9a-f]{64}$")

FORBIDDEN_FRAGMENTS = (
    "__cprover_assume",
    "__cprover_assert",
    "assert(",
    "assume(",
    "requires",
    "ensures",
    "invariant",
    "proof valid",
    "implementation correct",
)

ALLOWED_STANDARDS = {"c90", "c99", "c11", "gnu90", "gnu99", "gnu11"}
ALLOWED_COMPILERS = {"gcc", "clang", "cc"}
ALLOWED_EXTRA_ARGS = {
    "-Wall",
    "-Wextra",
    "-Werror",
    "-pedantic",
    "-pedantic-errors",
    "-Wno-unused-variable",
    "-Wno-unused-parameter",
    "-Wno-unused-function",
    "-Wno-uninitialized",
    "-Wno-maybe-uninitialized",
}


class ContractError(Exception):
    pass


@dataclass(frozen=True)
class Binding:
    path: str
    expected_sha256: str
    actual_sha256: str
    size_bytes: int


def canonical_json_bytes(value: Any) -> bytes:
    return (json.dumps(value, indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode("utf-8")


def write_json(path: Path, value: Any) -> None:
    path.write_bytes(canonical_json_bytes(value))


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def ensure_plain_dict(value: Any, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ContractError(f"{label} must be a JSON object")
    return value


def ensure_keys(obj: dict[str, Any], allowed: set[str], required: set[str], label: str) -> None:
    missing = sorted(required - obj.keys())
    unknown = sorted(obj.keys() - allowed)
    if missing:
        raise ContractError(f"{label} missing required field(s): {', '.join(missing)}")
    if unknown:
        raise ContractError(f"{label} contains unknown field(s): {', '.join(unknown)}")


def ensure_string(value: Any, label: str, *, nonempty: bool = True) -> str:
    if not isinstance(value, str):
        raise ContractError(f"{label} must be a string")
    if nonempty and not value.strip():
        raise ContractError(f"{label} must not be empty")
    if "\x00" in value or "\n" in value or "\r" in value:
        raise ContractError(f"{label} must be a single NUL-free line")
    return value


def ensure_identifier(value: Any, label: str) -> str:
    text = ensure_string(value, label)
    if not IDENT_RE.fullmatch(text):
        raise ContractError(f"{label} is not a conservative C identifier: {text!r}")
    lowered = text.lower()
    if any(fragment in lowered for fragment in FORBIDDEN_FRAGMENTS):
        raise ContractError(f"{label} contains a forbidden verification fragment")
    return text


def safe_relative_path(value: Any, label: str) -> str:
    text = ensure_string(value, label)
    p = Path(text)
    if p.is_absolute():
        raise ContractError(f"{label} must be repository-relative")
    if any(part in {"", ".", ".."} for part in p.parts):
        raise ContractError(f"{label} contains an unsafe path component")
    return p.as_posix()


def resolve_repo_member(repo_root: Path, rel: str, label: str, *, expect_dir: bool = False) -> Path:
    candidate = repo_root / rel
    current = repo_root
    for part in Path(rel).parts:
        current = current / part
        if current.is_symlink():
            raise ContractError(f"{label} traverses a symlink: {rel}")
    if not candidate.exists():
        raise ContractError(f"{label} does not exist: {rel}")
    if expect_dir:
        if not candidate.is_dir():
            raise ContractError(f"{label} is not a directory: {rel}")
    else:
        if not candidate.is_file():
            raise ContractError(f"{label} is not a regular file: {rel}")
    resolved = candidate.resolve()
    try:
        resolved.relative_to(repo_root.resolve())
    except ValueError as exc:
        raise ContractError(f"{label} escapes repository root: {rel}") from exc
    return candidate


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def validate_output_path(repo_root: Path, output_dir: Path) -> None:
    if output_dir.exists():
        raise ContractError("output directory already exists; refusing to overwrite evidence")
    parent = output_dir.parent.resolve()
    repo = repo_root.resolve()
    target = parent / output_dir.name
    if is_relative_to(target, repo):
        raise ContractError("output directory must be outside the repository root")


def load_request(path: Path) -> dict[str, Any]:
    if path.is_symlink():
        raise ContractError("request file must not be a symlink")
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise ContractError(f"unable to read request JSON: {exc}") from exc
    req = ensure_plain_dict(raw, "request")
    ensure_keys(
        req,
        {"schema_version", "request_id", "target", "harness", "source_bindings", "compile_check"},
        {"schema_version", "request_id", "target", "harness", "source_bindings"},
        "request",
    )
    if req["schema_version"] != SCHEMA_VERSION:
        raise ContractError(f"schema_version must be {SCHEMA_VERSION!r}")
    ensure_string(req["request_id"], "request.request_id")
    return req


def validate_type(value: Any, label: str) -> str:
    text = ensure_string(value, label)
    if not TYPE_RE.fullmatch(text):
        raise ContractError(f"{label} is not a conservative declaration type")
    lowered = text.lower()
    if any(fragment in lowered for fragment in FORBIDDEN_FRAGMENTS):
        raise ContractError(f"{label} contains a forbidden verification fragment")
    return " ".join(text.split()).replace(" *", "*")


def validate_argument(value: Any, label: str, declared_names: set[str]) -> str:
    text = ensure_string(value, label)
    if not ARG_RE.fullmatch(text):
        raise ContractError(f"{label} is not an allowed neutral lvalue/address expression")
    base = re.match(r"^[&*]?([A-Za-z_][A-Za-z0-9_]*)", text)
    assert base is not None
    if base.group(1) not in declared_names:
        raise ContractError(f"{label} refers to undeclared object {base.group(1)!r}")
    return text


def validate_request(req: dict[str, Any], repo_root: Path) -> dict[str, Any]:
    target = ensure_plain_dict(req["target"], "request.target")
    ensure_keys(
        target,
        {"symbol", "source_file", "arguments", "return_capture"},
        {"symbol", "source_file", "arguments"},
        "request.target",
    )
    symbol = ensure_identifier(target["symbol"], "request.target.symbol")
    source_file = safe_relative_path(target["source_file"], "request.target.source_file")
    if not isinstance(target["arguments"], list):
        raise ContractError("request.target.arguments must be an array")
    if len(target["arguments"]) > 32:
        raise ContractError("request.target.arguments exceeds 32 entries")

    harness = ensure_plain_dict(req["harness"], "request.harness")
    ensure_keys(
        harness,
        {"filename", "entry_function", "language_standard", "includes", "declarations"},
        {"filename", "entry_function", "language_standard", "includes", "declarations"},
        "request.harness",
    )
    filename = safe_relative_path(harness["filename"], "request.harness.filename")
    if "/" in filename or not filename.endswith(".c"):
        raise ContractError("request.harness.filename must be a plain .c filename")
    entry_function = ensure_identifier(harness["entry_function"], "request.harness.entry_function")
    if entry_function == symbol:
        raise ContractError("entry function must differ from target symbol")
    standard = ensure_string(harness["language_standard"], "request.harness.language_standard")
    if standard not in ALLOWED_STANDARDS:
        raise ContractError(f"unsupported language standard: {standard}")

    includes_raw = harness["includes"]
    if not isinstance(includes_raw, list):
        raise ContractError("request.harness.includes must be an array")
    if len(includes_raw) > 64:
        raise ContractError("request.harness.includes exceeds 64 entries")
    includes: list[dict[str, str]] = []
    seen_includes: set[tuple[str, str]] = set()
    for i, item_raw in enumerate(includes_raw):
        item = ensure_plain_dict(item_raw, f"request.harness.includes[{i}]")
        ensure_keys(item, {"style", "value"}, {"style", "value"}, f"request.harness.includes[{i}]")
        style = ensure_string(item["style"], f"request.harness.includes[{i}].style")
        if style not in {"quoted", "system"}:
            raise ContractError("include style must be 'quoted' or 'system'")
        value = ensure_string(item["value"], f"request.harness.includes[{i}].value")
        if not INCLUDE_RE.fullmatch(value) or Path(value).is_absolute() or ".." in Path(value).parts:
            raise ContractError(f"unsafe include token: {value!r}")
        lowered = value.lower()
        if any(fragment in lowered for fragment in FORBIDDEN_FRAGMENTS):
            raise ContractError("include contains a forbidden verification fragment")
        key = (style, value)
        if key in seen_includes:
            raise ContractError(f"duplicate include: {style}:{value}")
        seen_includes.add(key)
        includes.append({"style": style, "value": value})

    declarations_raw = harness["declarations"]
    if not isinstance(declarations_raw, list) or not declarations_raw:
        raise ContractError("request.harness.declarations must be a non-empty array")
    if len(declarations_raw) > 128:
        raise ContractError("request.harness.declarations exceeds 128 entries")
    declarations: list[dict[str, Any]] = []
    declared_names: set[str] = set()
    for i, item_raw in enumerate(declarations_raw):
        item = ensure_plain_dict(item_raw, f"request.harness.declarations[{i}]")
        ensure_keys(
            item,
            {"type", "name", "array_dimensions", "role"},
            {"type", "name"},
            f"request.harness.declarations[{i}]",
        )
        c_type = validate_type(item["type"], f"request.harness.declarations[{i}].type")
        name = ensure_identifier(item["name"], f"request.harness.declarations[{i}].name")
        if name in declared_names:
            raise ContractError(f"duplicate declaration name: {name}")
        declared_names.add(name)
        dims_raw = item.get("array_dimensions", [])
        if not isinstance(dims_raw, list) or len(dims_raw) > 8:
            raise ContractError(f"request.harness.declarations[{i}].array_dimensions must be an array of at most 8 items")
        dims: list[str] = []
        for j, dim_raw in enumerate(dims_raw):
            dim = ensure_string(dim_raw, f"request.harness.declarations[{i}].array_dimensions[{j}]")
            if not DIM_RE.fullmatch(dim):
                raise ContractError(f"unsupported neutral array dimension: {dim!r}")
            dims.append(dim)
        role = item.get("role", "auxiliary")
        if role not in {"input", "output", "inout", "auxiliary", "return"}:
            raise ContractError(f"unsupported declaration role: {role!r}")
        declarations.append({"type": c_type, "name": name, "array_dimensions": dims, "role": role})

    arguments = [
        validate_argument(value, f"request.target.arguments[{i}]", declared_names)
        for i, value in enumerate(target["arguments"])
    ]

    capture_raw = target.get("return_capture", {"mode": "none"})
    capture = ensure_plain_dict(capture_raw, "request.target.return_capture")
    ensure_keys(capture, {"mode", "variable"}, {"mode"}, "request.target.return_capture")
    mode = ensure_string(capture["mode"], "request.target.return_capture.mode")
    if mode not in {"none", "assign"}:
        raise ContractError("return_capture.mode must be 'none' or 'assign'")
    return_capture: dict[str, str] = {"mode": mode}
    if mode == "assign":
        if "variable" not in capture:
            raise ContractError("return_capture.variable is required for assign mode")
        variable = ensure_identifier(capture["variable"], "request.target.return_capture.variable")
        if variable not in declared_names:
            raise ContractError(f"return_capture variable {variable!r} is not declared")
        return_capture["variable"] = variable
    elif "variable" in capture:
        raise ContractError("return_capture.variable is not allowed for none mode")

    bindings_raw = req["source_bindings"]
    if not isinstance(bindings_raw, list) or not bindings_raw:
        raise ContractError("request.source_bindings must be a non-empty array")
    if len(bindings_raw) > 512:
        raise ContractError("request.source_bindings exceeds 512 entries")
    bindings: list[dict[str, str]] = []
    seen_paths: set[str] = set()
    for i, item_raw in enumerate(bindings_raw):
        item = ensure_plain_dict(item_raw, f"request.source_bindings[{i}]")
        ensure_keys(item, {"path", "expected_sha256"}, {"path", "expected_sha256"}, f"request.source_bindings[{i}]")
        path = safe_relative_path(item["path"], f"request.source_bindings[{i}].path")
        expected = ensure_string(item["expected_sha256"], f"request.source_bindings[{i}].expected_sha256").lower()
        if not HASH_RE.fullmatch(expected):
            raise ContractError(f"request.source_bindings[{i}].expected_sha256 must be lowercase SHA-256")
        if path in seen_paths:
            raise ContractError(f"duplicate source binding: {path}")
        seen_paths.add(path)
        resolve_repo_member(repo_root, path, f"request.source_bindings[{i}].path")
        bindings.append({"path": path, "expected_sha256": expected})
    if source_file not in seen_paths:
        raise ContractError("target.source_file must appear in source_bindings")

    compile_raw = req.get("compile_check", {"enabled": False, "required": False})
    compile_obj = ensure_plain_dict(compile_raw, "request.compile_check")
    ensure_keys(
        compile_obj,
        {"enabled", "required", "compiler", "include_dirs", "defines", "extra_args", "timeout_seconds"},
        {"enabled"},
        "request.compile_check",
    )
    enabled = compile_obj["enabled"]
    if not isinstance(enabled, bool):
        raise ContractError("request.compile_check.enabled must be boolean")
    required = compile_obj.get("required", False)
    if not isinstance(required, bool):
        raise ContractError("request.compile_check.required must be boolean")
    if required and not enabled:
        raise ContractError("compile_check.required cannot be true when enabled is false")
    compiler = compile_obj.get("compiler", "gcc")
    compiler = ensure_string(compiler, "request.compile_check.compiler")
    if compiler not in ALLOWED_COMPILERS:
        raise ContractError(f"unsupported compiler basename: {compiler}")
    include_dirs_raw = compile_obj.get("include_dirs", [])
    if not isinstance(include_dirs_raw, list) or len(include_dirs_raw) > 64:
        raise ContractError("request.compile_check.include_dirs must be an array of at most 64 items")
    include_dirs: list[str] = []
    for i, value in enumerate(include_dirs_raw):
        rel = safe_relative_path(value, f"request.compile_check.include_dirs[{i}]")
        resolve_repo_member(repo_root, rel, f"request.compile_check.include_dirs[{i}]", expect_dir=True)
        include_dirs.append(rel)
    defines_raw = compile_obj.get("defines", [])
    if not isinstance(defines_raw, list) or len(defines_raw) > 128:
        raise ContractError("request.compile_check.defines must be an array of at most 128 items")
    defines: list[dict[str, str | None]] = []
    seen_defines: set[str] = set()
    for i, item_raw in enumerate(defines_raw):
        item = ensure_plain_dict(item_raw, f"request.compile_check.defines[{i}]")
        ensure_keys(item, {"name", "value"}, {"name"}, f"request.compile_check.defines[{i}]")
        name = ensure_identifier(item["name"], f"request.compile_check.defines[{i}].name")
        if name in seen_defines:
            raise ContractError(f"duplicate compile define: {name}")
        seen_defines.add(name)
        raw_value = item.get("value")
        if raw_value is None:
            value: str | None = None
        else:
            value = ensure_string(raw_value, f"request.compile_check.defines[{i}].value")
            if not DEFINE_VALUE_RE.fullmatch(value):
                raise ContractError(f"unsafe compile define value: {value!r}")
        defines.append({"name": name, "value": value})
    extra_args_raw = compile_obj.get("extra_args", [])
    if not isinstance(extra_args_raw, list) or len(extra_args_raw) > 32:
        raise ContractError("request.compile_check.extra_args must be an array of at most 32 items")
    extra_args: list[str] = []
    for i, raw in enumerate(extra_args_raw):
        arg = ensure_string(raw, f"request.compile_check.extra_args[{i}]")
        if arg not in ALLOWED_EXTRA_ARGS:
            raise ContractError(f"compile extra argument is not allowlisted: {arg!r}")
        extra_args.append(arg)
    timeout = compile_obj.get("timeout_seconds", 30)
    if not isinstance(timeout, int) or isinstance(timeout, bool) or not 1 <= timeout <= 300:
        raise ContractError("request.compile_check.timeout_seconds must be an integer from 1 to 300")

    return {
        "schema_version": SCHEMA_VERSION,
        "request_id": req["request_id"],
        "target": {
            "symbol": symbol,
            "source_file": source_file,
            "arguments": arguments,
            "return_capture": return_capture,
        },
        "harness": {
            "filename": filename,
            "entry_function": entry_function,
            "language_standard": standard,
            "includes": includes,
            "declarations": declarations,
        },
        "source_bindings": sorted(bindings, key=lambda x: x["path"]),
        "compile_check": {
            "enabled": enabled,
            "required": required,
            "compiler": compiler,
            "include_dirs": include_dirs,
            "defines": defines,
            "extra_args": extra_args,
            "timeout_seconds": timeout,
        },
    }


def inspect_bindings(repo_root: Path, bindings: list[dict[str, str]]) -> tuple[list[Binding], list[str]]:
    inspected: list[Binding] = []
    mismatches: list[str] = []
    for item in bindings:
        path = resolve_repo_member(repo_root, item["path"], f"source binding {item['path']}")
        actual = sha256_file(path)
        binding = Binding(
            path=item["path"],
            expected_sha256=item["expected_sha256"],
            actual_sha256=actual,
            size_bytes=path.stat().st_size,
        )
        inspected.append(binding)
        if actual != item["expected_sha256"]:
            mismatches.append(f"SHA-256 mismatch for {item['path']}: expected {item['expected_sha256']}, found {actual}")
    return inspected, mismatches


def declaration_text(item: dict[str, Any]) -> str:
    dims = "".join(f"[{dim}]" for dim in item["array_dimensions"])
    c_type = item["type"]
    separator = "" if c_type.endswith("*") else " "
    return f"{c_type}{separator}{item['name']}{dims};"


def generate_scaffold(req: dict[str, Any]) -> str:
    lines: list[str] = []
    lines.append("/* Generated neutral harness scaffold.")
    lines.append(" * No assumptions, assertions, properties, contracts, or initializers were inserted.")
    lines.append(" * Codex remains responsible for every scientifically meaningful addition.")
    lines.append(" */")
    for include in req["harness"]["includes"]:
        if include["style"] == "quoted":
            lines.append(f'#include "{include["value"]}"')
        else:
            lines.append(f'#include <{include["value"]}>')
    if req["harness"]["includes"]:
        lines.append("")
    entry = req["harness"]["entry_function"]
    lines.append(f"int {entry}(void)")
    lines.append("{")
    for item in req["harness"]["declarations"]:
        lines.append(f"  {declaration_text(item)}")
    lines.append("")
    lines.append("  /* V5_CODEX_INPUT_PREPARATION_BEGIN */")
    lines.append("  /* CODEX: insert task-justified input preparation or nondeterministic setup here. */")
    lines.append("  /* V5_CODEX_INPUT_PREPARATION_END */")
    lines.append("")
    lines.append("  /* V5_CODEX_ASSUMPTIONS_BEGIN */")
    lines.append("  /* CODEX: insert only explicitly justified assumptions here. */")
    lines.append("  /* V5_CODEX_ASSUMPTIONS_END */")
    lines.append("")
    args = ", ".join(req["target"]["arguments"])
    call = f"{req['target']['symbol']}({args})"
    if req["target"]["return_capture"]["mode"] == "assign":
        call = f"{req['target']['return_capture']['variable']} = {call}"
    lines.append("  /* V5_TARGET_CALL_BEGIN */")
    lines.append(f"  {call};")
    lines.append("  /* V5_TARGET_CALL_END */")
    lines.append("")
    lines.append("  /* V5_CODEX_ASSERTIONS_BEGIN */")
    lines.append("  /* CODEX: insert the selected verification property here. */")
    lines.append("  /* V5_CODEX_ASSERTIONS_END */")
    lines.append("")
    lines.append("  return 0;")
    lines.append("}")
    return "\n".join(lines) + "\n"


def marker_line_map(text: str) -> dict[str, int]:
    wanted = {
        "input_preparation_begin": "V5_CODEX_INPUT_PREPARATION_BEGIN",
        "input_preparation_end": "V5_CODEX_INPUT_PREPARATION_END",
        "assumptions_begin": "V5_CODEX_ASSUMPTIONS_BEGIN",
        "assumptions_end": "V5_CODEX_ASSUMPTIONS_END",
        "target_call_begin": "V5_TARGET_CALL_BEGIN",
        "target_call_end": "V5_TARGET_CALL_END",
        "assertions_begin": "V5_CODEX_ASSERTIONS_BEGIN",
        "assertions_end": "V5_CODEX_ASSERTIONS_END",
    }
    result: dict[str, int] = {}
    for number, line in enumerate(text.splitlines(), start=1):
        for key, token in wanted.items():
            if token in line:
                result[key] = number
    if set(result) != set(wanted):
        raise RuntimeError("generated scaffold is missing required markers")
    return result


def static_scaffold_checks(text: str, target_symbol: str) -> dict[str, Any]:
    lowered = text.lower()
    forbidden_present = [fragment for fragment in FORBIDDEN_FRAGMENTS if fragment in lowered]
    call_pattern = re.compile(rf"\b{re.escape(target_symbol)}\s*\(")
    target_call_count = len(call_pattern.findall(text))
    return {
        "forbidden_fragments_present": forbidden_present,
        "target_call_count": target_call_count,
        "assumption_statement_count": 0,
        "assertion_statement_count": 0,
        "initializer_count": 0,
        "passes_neutrality_checks": not forbidden_present and target_call_count == 1,
    }


def build_compile_argv(req: dict[str, Any], repo_root: Path, harness_path: Path) -> list[str]:
    compile_cfg = req["compile_check"]
    argv = [compile_cfg["compiler"], "-fsyntax-only", f"-std={req['harness']['language_standard']}"]
    for rel in compile_cfg["include_dirs"]:
        argv.extend(["-I", str((repo_root / rel).resolve())])
    for item in compile_cfg["defines"]:
        token = item["name"] if item["value"] is None else f"{item['name']}={item['value']}"
        argv.append(f"-D{token}")
    argv.extend(compile_cfg["extra_args"])
    argv.append(str(harness_path.resolve()))
    return argv


def run_compile_check(req: dict[str, Any], repo_root: Path, harness_path: Path, output_dir: Path) -> dict[str, Any]:
    cfg = req["compile_check"]
    if not cfg["enabled"]:
        return {
            "enabled": False,
            "required": False,
            "status": "NOT_REQUESTED",
            "argv": [],
            "exit_code": None,
            "timed_out": False,
        }
    argv = build_compile_argv(req, repo_root, harness_path)
    write_json(output_dir / "compile_check.argv.json", argv)
    (output_dir / "compile_check.command.txt").write_text(shlex.join(argv) + "\n", encoding="utf-8")
    try:
        completed = subprocess.run(
            argv,
            cwd=str(repo_root),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=cfg["timeout_seconds"],
            check=False,
            shell=False,
        )
        stdout = completed.stdout
        stderr = completed.stderr
        exit_code: int | None = completed.returncode
        timed_out = False
        status = "PASSED" if completed.returncode == 0 else "FAILED"
    except FileNotFoundError as exc:
        stdout = b""
        stderr = str(exc).encode("utf-8", errors="replace")
        exit_code = None
        timed_out = False
        status = "TOOL_NOT_FOUND"
    except subprocess.TimeoutExpired as exc:
        stdout = exc.stdout or b""
        stderr = exc.stderr or b""
        exit_code = None
        timed_out = True
        status = "TIMEOUT"
    (output_dir / "compile_check.stdout.txt").write_bytes(stdout)
    (output_dir / "compile_check.stderr.txt").write_bytes(stderr)
    result = {
        "enabled": True,
        "required": cfg["required"],
        "status": status,
        "argv": argv,
        "exit_code": exit_code,
        "timed_out": timed_out,
        "stdout_sha256": sha256_bytes(stdout),
        "stderr_sha256": sha256_bytes(stderr),
        "stdout_size_bytes": len(stdout),
        "stderr_size_bytes": len(stderr),
    }
    write_json(output_dir / "compile_check.result.json", result)
    return result


def artifact_entry(path: Path, output_dir: Path, role: str) -> dict[str, Any]:
    return {
        "path": path.relative_to(output_dir).as_posix(),
        "role": role,
        "sha256": sha256_file(path),
        "size_bytes": path.stat().st_size,
    }


def render_markdown(report: dict[str, Any]) -> str:
    lines = [
        "# CBMC Harness Scaffold Report",
        "",
        f"- Request ID: `{report['request_id']}`",
        f"- Status: `{report['status']}`",
        f"- Semantic authority: `{report['semantic_authority']}`",
        f"- Generated content class: `{report['generated_content_class']}`",
        f"- Target: `{report['target']['symbol']}`",
        f"- Harness: `{report['scaffold']['filename'] if report['scaffold']['generated'] else 'NOT_GENERATED'}`",
        "",
        "## Scientific boundary",
        "",
        "This utility generated neutral C wiring only. It did not select a theorem, insert input-domain assumptions, write a verification assertion, infer aliasing or range conditions, or judge correctness.",
        "",
        "## Neutrality inventory",
        "",
        f"- Target-call count: `{report['scaffold']['static_checks']['target_call_count'] if report['scaffold']['generated'] else 0}`",
        f"- Inserted assumptions: `{report['scaffold']['static_checks']['assumption_statement_count'] if report['scaffold']['generated'] else 0}`",
        f"- Inserted assertions: `{report['scaffold']['static_checks']['assertion_statement_count'] if report['scaffold']['generated'] else 0}`",
        f"- Inserted initializers: `{report['scaffold']['static_checks']['initializer_count'] if report['scaffold']['generated'] else 0}`",
        "",
        "## Compile check",
        "",
        f"- Enabled: `{report['compile_check']['enabled']}`",
        f"- Required: `{report['compile_check']['required']}`",
        f"- Status: `{report['compile_check']['status']}`",
    ]
    if report["warnings"]:
        lines.extend(["", "## Warnings", ""])
        lines.extend(f"- {item}" for item in report["warnings"])
    if report["incomplete_reasons"]:
        lines.extend(["", "## Incomplete reasons", ""])
        lines.extend(f"- {item}" for item in report["incomplete_reasons"])
    lines.extend(["", "## Mandatory interpretation limits", ""])
    lines.extend(f"- {item}" for item in report["limitations"])
    return "\n".join(lines) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--request", required=True, type=Path)
    parser.add_argument("--repo-root", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args(argv)

    try:
        repo_root = args.repo_root
        if repo_root.is_symlink() or not repo_root.is_dir():
            raise ContractError("repository root must be a real directory and not a symlink")
        validate_output_path(repo_root, args.output_dir)
        raw_req = load_request(args.request)
        req = validate_request(raw_req, repo_root)
    except ContractError as exc:
        print(f"CONTRACT_ERROR: {exc}", file=sys.stderr)
        return 3

    try:
        args.output_dir.mkdir(parents=True, exist_ok=False)
        write_json(args.output_dir / "canonical_request.json", req)

        bindings, hash_mismatches = inspect_bindings(repo_root, req["source_bindings"])
        source_manifest = {
            "schema_version": SCHEMA_VERSION,
            "request_id": req["request_id"],
            "repository_root_sha256_scope": "DECLARED_SOURCE_BINDINGS_ONLY",
            "files": [
                {
                    "path": b.path,
                    "expected_sha256": b.expected_sha256,
                    "actual_sha256": b.actual_sha256,
                    "sha256_matches": b.expected_sha256 == b.actual_sha256,
                    "size_bytes": b.size_bytes,
                }
                for b in bindings
            ],
            "all_hashes_match": not hash_mismatches,
        }
        write_json(args.output_dir / "source_manifest.json", source_manifest)

        warnings: list[str] = []
        incomplete_reasons: list[str] = list(hash_mismatches)
        harness_path = args.output_dir / req["harness"]["filename"]
        scaffold_generated = not incomplete_reasons
        compile_result: dict[str, Any]
        static_checks: dict[str, Any] = {
            "forbidden_fragments_present": [],
            "target_call_count": 0,
            "assumption_statement_count": 0,
            "assertion_statement_count": 0,
            "initializer_count": 0,
            "passes_neutrality_checks": False,
        }
        marker_lines: dict[str, int] = {}
        scaffold_sha256: str | None = None
        scaffold_line_count = 0

        if scaffold_generated:
            text = generate_scaffold(req)
            static_checks = static_scaffold_checks(text, req["target"]["symbol"])
            if not static_checks["passes_neutrality_checks"]:
                incomplete_reasons.append("generated scaffold failed internal neutrality checks")
                scaffold_generated = False
            else:
                harness_path.write_text(text, encoding="utf-8", newline="\n")
                marker_lines = marker_line_map(text)
                scaffold_sha256 = sha256_file(harness_path)
                scaffold_line_count = len(text.splitlines())

        if scaffold_generated:
            compile_result = run_compile_check(req, repo_root, harness_path, args.output_dir)
            if compile_result["enabled"] and compile_result["status"] != "PASSED":
                message = f"syntax-only compile check reported {compile_result['status']}"
                if compile_result["required"]:
                    incomplete_reasons.append(message)
                else:
                    warnings.append(message)
        else:
            compile_result = {
                "enabled": req["compile_check"]["enabled"],
                "required": req["compile_check"]["required"],
                "status": "NOT_RUN",
                "argv": [],
                "exit_code": None,
                "timed_out": False,
            }

        status = "INCOMPLETE" if incomplete_reasons else ("COMPLETE_WITH_WARNINGS" if warnings else "COMPLETE")
        report = {
            "schema_version": SCHEMA_VERSION,
            "request_id": req["request_id"],
            "skill": {"name": SKILL_NAME, "version": SKILL_VERSION},
            "status": status,
            "semantic_authority": "NONE",
            "generated_content_class": "NEUTRAL_WIRING_ONLY",
            "target": req["target"],
            "source_binding_summary": {
                "declared_file_count": len(bindings),
                "all_hashes_match": not hash_mismatches,
                "target_source_bound": req["target"]["source_file"] in {b.path for b in bindings},
            },
            "scaffold": {
                "generated": scaffold_generated,
                "filename": req["harness"]["filename"] if scaffold_generated else None,
                "sha256": scaffold_sha256,
                "line_count": scaffold_line_count,
                "language_standard": req["harness"]["language_standard"],
                "entry_function": req["harness"]["entry_function"],
                "declarations": req["harness"]["declarations"],
                "marker_lines": marker_lines,
                "static_checks": static_checks,
                "caller_supplied_wiring": True,
            },
            "compile_check": compile_result,
            "warnings": warnings,
            "incomplete_reasons": incomplete_reasons,
            "limitations": [
                "The scaffold does not establish that the target signature, arguments, object declarations, includes, or build flags are scientifically appropriate.",
                "No input-domain, pointer-validity, aliasing, range, loop, or mathematical assumptions were inferred or inserted.",
                "No verification property, assertion, contract, invariant, or expected output relationship was inferred or inserted.",
                "A successful syntax-only compile check establishes only compiler acceptance of the generated translation unit under the captured arguments.",
                "Uninitialized local declarations are emitted without a claim about their semantic suitability; Codex must decide input construction.",
                "The target call is generated from caller-supplied structured wiring and is not evidence that the intended implementation is reached at runtime.",
            ],
        }
        write_json(args.output_dir / "scaffold_report.json", report)
        (args.output_dir / "scaffold_report.md").write_text(render_markdown(report), encoding="utf-8", newline="\n")

        artifact_roles = {
            "canonical_request.json": "canonical_request",
            "source_manifest.json": "source_manifest",
            "scaffold_report.json": "structured_report",
            "scaffold_report.md": "human_report",
        }
        if scaffold_generated:
            artifact_roles[req["harness"]["filename"]] = "neutral_harness_scaffold"
        for optional, role in (
            ("compile_check.argv.json", "compile_argv"),
            ("compile_check.command.txt", "compile_command_display"),
            ("compile_check.stdout.txt", "compile_stdout"),
            ("compile_check.stderr.txt", "compile_stderr"),
            ("compile_check.result.json", "compile_result"),
        ):
            if (args.output_dir / optional).exists():
                artifact_roles[optional] = role
        artifact_manifest = {
            "schema_version": SCHEMA_VERSION,
            "request_id": req["request_id"],
            "manifest_scope": "Generated run artefacts excluding scaffold_artifact_manifest.json itself",
            "artifacts": [
                artifact_entry(args.output_dir / name, args.output_dir, role)
                for name, role in sorted(artifact_roles.items())
            ],
        }
        write_json(args.output_dir / "scaffold_artifact_manifest.json", artifact_manifest)

        print(f"STATUS={status}")
        print(f"OUTPUT_DIR={args.output_dir}")
        return 2 if status == "INCOMPLETE" else 0
    except ContractError as exc:
        print(f"CONTRACT_ERROR: {exc}", file=sys.stderr)
        return 3
    except Exception as exc:  # defensive evidence boundary
        print(f"INTERNAL_ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 5


if __name__ == "__main__":
    raise SystemExit(main())
