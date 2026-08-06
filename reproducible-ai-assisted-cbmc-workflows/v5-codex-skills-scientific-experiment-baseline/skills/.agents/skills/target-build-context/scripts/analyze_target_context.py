#!/usr/bin/env python3
from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

SUPPORTED_EXTENSIONS = {".c", ".h", ".inc", ".i"}
DEFAULT_EXCLUDED_DIRS = {".git", ".hg", ".svn", ".agents", "node_modules", "__pycache__"}
CONTROL_KEYWORDS = {"if", "for", "while", "switch", "return", "sizeof", "_Alignof"}
SHELL_META = {";", "&&", "||", "|", ">", ">>", "<", "<<", "`"}
STATUS_COMPLETE = "COMPLETE"
STATUS_WARN = "COMPLETE_WITH_WARNINGS"
STATUS_INCOMPLETE = "INCOMPLETE"


class ContractError(Exception):
    pass


@dataclass(frozen=True)
class SourceFile:
    path: str
    abs_path: Path
    sha256: str
    size: int
    text: str
    decode_status: str


@dataclass(frozen=True)
class FunctionDef:
    name: str
    path: str
    signature: str
    parameter_text: str
    start_line: int
    body_start_line: int
    end_line: int
    start_offset: int
    body_start_offset: int
    body_end_offset: int
    body_text: str


def canonical_json(data: Any) -> str:
    return json.dumps(data, indent=2, sort_keys=True, ensure_ascii=False) + "\n"


def write_text(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8", newline="\n")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def normalise_ws(text: str) -> str:
    return " ".join(text.split())


def is_inside(child: Path, parent: Path) -> bool:
    try:
        child.relative_to(parent)
        return True
    except ValueError:
        return False


def require_repo_relative(value: str, field: str) -> str:
    p = Path(value)
    if p.is_absolute():
        raise ContractError(f"{field} must be repository-relative")
    if any(part in {"", ".", ".."} for part in p.parts):
        if ".." in p.parts:
            raise ContractError(f"{field} must not escape the repository")
    normal = p.as_posix()
    if normal.startswith("../") or normal == "..":
        raise ContractError(f"{field} must not escape the repository")
    return normal


def safe_repo_path(repo: Path, relative: str, field: str, *, must_exist: bool = True) -> Path:
    rel = require_repo_relative(relative, field)
    candidate = repo / rel
    current = repo
    for part in Path(rel).parts:
        current = current / part
        if current.exists() and current.is_symlink():
            raise ContractError(f"{field} must not traverse a symlink: {rel}")
    resolved = candidate.resolve(strict=False)
    if not is_inside(resolved, repo):
        raise ContractError(f"{field} must remain inside the repository")
    if must_exist and not candidate.exists():
        raise ContractError(f"{field} does not exist: {rel}")
    return candidate


def validate_request(raw: Any) -> dict[str, Any]:
    if not isinstance(raw, dict):
        raise ContractError("request root must be a JSON object")
    allowed_top = {"schema_version", "request_id", "target", "scope", "build", "options"}
    unknown = sorted(set(raw) - allowed_top)
    if unknown:
        raise ContractError(f"unknown top-level fields: {', '.join(unknown)}")
    if raw.get("schema_version") != "1.0":
        raise ContractError("schema_version must equal '1.0'")
    request_id = raw.get("request_id")
    if not isinstance(request_id, str) or not request_id.strip() or len(request_id) > 200:
        raise ContractError("request_id must be a non-empty string of at most 200 characters")

    target = raw.get("target")
    if not isinstance(target, dict):
        raise ContractError("target must be an object")
    unknown = sorted(set(target) - {"symbol", "source_file", "expected_sha256"})
    if unknown:
        raise ContractError(f"unknown target fields: {', '.join(unknown)}")
    symbol = target.get("symbol")
    if not isinstance(symbol, str) or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", symbol):
        raise ContractError("target.symbol must be a valid C identifier")
    source_file = target.get("source_file")
    if source_file is not None:
        if not isinstance(source_file, str) or not source_file:
            raise ContractError("target.source_file must be a non-empty string")
        require_repo_relative(source_file, "target.source_file")
    expected_sha = target.get("expected_sha256")
    if expected_sha is not None and (not isinstance(expected_sha, str) or not re.fullmatch(r"[0-9a-f]{64}", expected_sha)):
        raise ContractError("target.expected_sha256 must be a lowercase 64-character SHA-256")

    scope = raw.get("scope", {})
    if not isinstance(scope, dict):
        raise ContractError("scope must be an object")
    unknown = sorted(set(scope) - {"source_files", "exclude_globs"})
    if unknown:
        raise ContractError(f"unknown scope fields: {', '.join(unknown)}")
    source_files = scope.get("source_files", [])
    if not isinstance(source_files, list) or any(not isinstance(x, str) or not x for x in source_files):
        raise ContractError("scope.source_files must be an array of non-empty strings")
    if len(set(source_files)) != len(source_files):
        raise ContractError("scope.source_files entries must be unique")
    for idx, item in enumerate(source_files):
        require_repo_relative(item, f"scope.source_files[{idx}]")
    exclude_globs = scope.get("exclude_globs", [])
    if not isinstance(exclude_globs, list) or any(not isinstance(x, str) or not x for x in exclude_globs):
        raise ContractError("scope.exclude_globs must be an array of non-empty strings")
    if len(set(exclude_globs)) != len(exclude_globs):
        raise ContractError("scope.exclude_globs entries must be unique")

    build = raw.get("build", {"mode": "none"})
    if not isinstance(build, dict):
        raise ContractError("build must be an object")
    mode = build.get("mode", "none")
    if mode not in {"none", "explicit", "compile_commands"}:
        raise ContractError("build.mode must be 'none', 'explicit', or 'compile_commands'")
    if mode == "none":
        unknown = sorted(set(build) - {"mode"})
        if unknown:
            raise ContractError(f"build.mode 'none' does not accept: {', '.join(unknown)}")
        build_out = {"mode": "none"}
    elif mode == "explicit":
        allowed = {"mode", "working_directory", "compiler", "language_standard", "include_dirs", "defines", "undefines", "forced_includes", "extra_args"}
        unknown = sorted(set(build) - allowed)
        if unknown:
            raise ContractError(f"unknown explicit build fields: {', '.join(unknown)}")
        compiler = build.get("compiler")
        if not isinstance(compiler, str) or not compiler.strip() or any(ch.isspace() for ch in compiler):
            raise ContractError("build.compiler must be one executable token")
        working_directory = build.get("working_directory", ".")
        if working_directory != ".":
            require_repo_relative(working_directory, "build.working_directory")
        language_standard = build.get("language_standard")
        if language_standard is not None and (not isinstance(language_standard, str) or not re.fullmatch(r"[A-Za-z0-9+_.-]+", language_standard)):
            raise ContractError("build.language_standard contains unsupported characters")
        include_dirs = build.get("include_dirs", [])
        if not isinstance(include_dirs, list) or any(not isinstance(x, str) or not x for x in include_dirs):
            raise ContractError("build.include_dirs must be an array of non-empty strings")
        for idx, item in enumerate(include_dirs):
            require_repo_relative(item, f"build.include_dirs[{idx}]")
        defines = build.get("defines", [])
        if not isinstance(defines, list):
            raise ContractError("build.defines must be an array")
        norm_defines = []
        seen_define_names: set[str] = set()
        for idx, item in enumerate(defines):
            if not isinstance(item, dict) or set(item) - {"name", "value"}:
                raise ContractError(f"build.defines[{idx}] must contain only name and optional value")
            name = item.get("name")
            if not isinstance(name, str) or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
                raise ContractError(f"build.defines[{idx}].name must be a C identifier")
            if name in seen_define_names:
                raise ContractError(f"duplicate build define: {name}")
            seen_define_names.add(name)
            value = item.get("value")
            if value is not None and not isinstance(value, str):
                raise ContractError(f"build.defines[{idx}].value must be a string")
            norm_defines.append({"name": name, **({"value": value} if value is not None else {})})
        undefines = build.get("undefines", [])
        if not isinstance(undefines, list) or any(not isinstance(x, str) or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", x) for x in undefines):
            raise ContractError("build.undefines must be an array of C identifiers")
        forced_includes = build.get("forced_includes", [])
        if not isinstance(forced_includes, list) or any(not isinstance(x, str) or not x for x in forced_includes):
            raise ContractError("build.forced_includes must be an array of non-empty strings")
        for idx, item in enumerate(forced_includes):
            require_repo_relative(item, f"build.forced_includes[{idx}]")
        extra_args = build.get("extra_args", [])
        if not isinstance(extra_args, list) or any(not isinstance(x, str) for x in extra_args):
            raise ContractError("build.extra_args must be an array of strings")
        for arg in extra_args:
            if arg in SHELL_META or "\n" in arg or "\r" in arg or "\x00" in arg:
                raise ContractError(f"unsafe build.extra_args token: {arg!r}")
        build_out = {
            "mode": "explicit",
            "working_directory": working_directory,
            "compiler": compiler,
            "language_standard": language_standard,
            "include_dirs": include_dirs,
            "defines": norm_defines,
            "undefines": undefines,
            "forced_includes": forced_includes,
            "extra_args": extra_args,
        }
    else:
        unknown = sorted(set(build) - {"mode", "compile_commands_file"})
        if unknown:
            raise ContractError(f"unknown compile_commands build fields: {', '.join(unknown)}")
        compdb = build.get("compile_commands_file")
        if not isinstance(compdb, str) or not compdb:
            raise ContractError("build.compile_commands_file is required")
        require_repo_relative(compdb, "build.compile_commands_file")
        build_out = {"mode": "compile_commands", "compile_commands_file": compdb}

    options = raw.get("options", {})
    if not isinstance(options, dict):
        raise ContractError("options must be an object")
    allowed = {"preprocess", "preprocess_required", "preprocess_timeout_seconds", "excerpt_context_lines", "max_items_per_category"}
    unknown = sorted(set(options) - allowed)
    if unknown:
        raise ContractError(f"unknown options fields: {', '.join(unknown)}")
    preprocess = options.get("preprocess", False)
    preprocess_required = options.get("preprocess_required", False)
    timeout = options.get("preprocess_timeout_seconds", 60)
    context = options.get("excerpt_context_lines", 8)
    max_items = options.get("max_items_per_category", 1000)
    if not isinstance(preprocess, bool) or not isinstance(preprocess_required, bool):
        raise ContractError("preprocess options must be booleans")
    if preprocess_required and not preprocess:
        raise ContractError("options.preprocess_required requires options.preprocess=true")
    if not isinstance(timeout, int) or isinstance(timeout, bool) or not 1 <= timeout <= 600:
        raise ContractError("options.preprocess_timeout_seconds must be 1..600")
    if not isinstance(context, int) or isinstance(context, bool) or not 0 <= context <= 200:
        raise ContractError("options.excerpt_context_lines must be 0..200")
    if not isinstance(max_items, int) or isinstance(max_items, bool) or not 1 <= max_items <= 10000:
        raise ContractError("options.max_items_per_category must be 1..10000")

    return {
        "schema_version": "1.0",
        "request_id": request_id.strip(),
        "target": {
            "symbol": symbol,
            **({"source_file": source_file} if source_file is not None else {}),
            **({"expected_sha256": expected_sha} if expected_sha is not None else {}),
        },
        "scope": {"source_files": source_files, "exclude_globs": exclude_globs},
        "build": build_out,
        "options": {
            "preprocess": preprocess,
            "preprocess_required": preprocess_required,
            "preprocess_timeout_seconds": timeout,
            "excerpt_context_lines": context,
            "max_items_per_category": max_items,
        },
    }


def enumerate_sources(repo: Path, request: dict[str, Any], output_dir: Path) -> tuple[list[Path], list[dict[str, str]]]:
    source_files = request["scope"]["source_files"]
    exclude_globs = request["scope"]["exclude_globs"]
    skipped: list[dict[str, str]] = []
    paths: list[Path] = []
    if source_files:
        for idx, rel in enumerate(source_files):
            p = safe_repo_path(repo, rel, f"scope.source_files[{idx}]")
            if p.is_symlink():
                raise ContractError(f"scope source must not be a symlink: {rel}")
            if not p.is_file():
                raise ContractError(f"scope source is not a regular file: {rel}")
            if p.suffix.lower() not in SUPPORTED_EXTENSIONS:
                raise ContractError(f"unsupported source extension in explicit scope: {rel}")
            paths.append(p)
    else:
        for root, dirs, files in os.walk(repo, followlinks=False):
            root_path = Path(root)
            dirs[:] = sorted(
                d for d in dirs
                if d not in DEFAULT_EXCLUDED_DIRS
                and not (root_path / d).is_symlink()
                and not is_inside((root_path / d).resolve(strict=False), output_dir)
            )
            for name in sorted(files):
                p = root_path / name
                rel = p.relative_to(repo).as_posix()
                if p.is_symlink():
                    skipped.append({"path": rel, "reason": "symlink_not_followed"})
                    continue
                if any(fnmatch.fnmatch(rel, pattern) for pattern in exclude_globs):
                    skipped.append({"path": rel, "reason": "excluded_by_glob"})
                    continue
                if p.suffix.lower() not in SUPPORTED_EXTENSIONS:
                    continue
                paths.append(p)
    return sorted(set(paths), key=lambda p: p.relative_to(repo).as_posix()), sorted(skipped, key=lambda x: (x["path"], x["reason"]))


def load_sources(repo: Path, paths: Iterable[Path]) -> tuple[list[SourceFile], list[str]]:
    sources: list[SourceFile] = []
    warnings: list[str] = []
    for p in paths:
        raw = p.read_bytes()
        try:
            text = raw.decode("utf-8")
            status = "utf8"
        except UnicodeDecodeError:
            text = raw.decode("utf-8", errors="replace")
            status = "utf8_with_replacement"
            warnings.append(f"Decoded with replacement characters: {p.relative_to(repo).as_posix()}")
        sources.append(SourceFile(
            path=p.relative_to(repo).as_posix(),
            abs_path=p,
            sha256=sha256_bytes(raw),
            size=len(raw),
            text=text,
            decode_status=status,
        ))
    return sources, warnings


def mask_comments_and_literals(text: str) -> str:
    chars = list(text)
    i = 0
    state = "normal"
    while i < len(chars):
        c = chars[i]
        n = chars[i + 1] if i + 1 < len(chars) else ""
        if state == "normal":
            if c == "/" and n == "/":
                chars[i] = chars[i + 1] = " "
                i += 2
                state = "line_comment"
                continue
            if c == "/" and n == "*":
                chars[i] = chars[i + 1] = " "
                i += 2
                state = "block_comment"
                continue
            if c == '"':
                chars[i] = " "
                i += 1
                state = "string"
                continue
            if c == "'":
                chars[i] = " "
                i += 1
                state = "char"
                continue
            i += 1
        elif state == "line_comment":
            if c == "\n":
                state = "normal"
            else:
                chars[i] = " "
            i += 1
        elif state == "block_comment":
            if c == "*" and n == "/":
                chars[i] = chars[i + 1] = " "
                i += 2
                state = "normal"
            else:
                if c != "\n":
                    chars[i] = " "
                i += 1
        elif state in {"string", "char"}:
            delimiter = '"' if state == "string" else "'"
            if c == "\\":
                chars[i] = " "
                if i + 1 < len(chars):
                    if chars[i + 1] != "\n":
                        chars[i + 1] = " "
                    i += 2
                else:
                    i += 1
            elif c == delimiter:
                chars[i] = " "
                i += 1
                state = "normal"
            else:
                if c != "\n":
                    chars[i] = " "
                i += 1
    return "".join(chars)


def matching_delimiter(text: str, start: int, opening: str, closing: str) -> int | None:
    depth = 0
    for i in range(start, len(text)):
        if text[i] == opening:
            depth += 1
        elif text[i] == closing:
            depth -= 1
            if depth == 0:
                return i
    return None


def signature_start(masked: str, name_start: int) -> int:
    lower_bound = max(0, name_start - 2000)
    i = name_start - 1
    while i >= lower_bound:
        if masked[i] in ";}":
            return i + 1
        i -= 1
    line_start = masked.rfind("\n", lower_bound, name_start)
    return line_start + 1 if line_start >= 0 else lower_bound


def parse_functions(source: SourceFile) -> list[FunctionDef]:
    masked = mask_comments_and_literals(source.text)
    defs: list[FunctionDef] = []
    pattern = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*\(")
    for m in pattern.finditer(masked):
        name = m.group(1)
        if name in CONTROL_KEYWORDS:
            continue
        open_paren = masked.find("(", m.start(1) + len(name))
        close_paren = matching_delimiter(masked, open_paren, "(", ")")
        if close_paren is None:
            continue
        j = close_paren + 1
        while j < len(masked) and masked[j].isspace():
            j += 1
        # Handle common GCC attribute or CPROVER annotation groups between ')' and '{'.
        while j < len(masked) and (masked.startswith("__attribute__", j) or masked.startswith("__CPROVER_", j)):
            attr_open = masked.find("(", j)
            if attr_open < 0:
                break
            attr_close = matching_delimiter(masked, attr_open, "(", ")")
            if attr_close is None:
                break
            j = attr_close + 1
            while j < len(masked) and masked[j].isspace():
                j += 1
        if j >= len(masked) or masked[j] != "{":
            continue
        body_end = matching_delimiter(masked, j, "{", "}")
        if body_end is None:
            continue
        start = signature_start(masked, m.start(1))
        signature = normalise_ws(source.text[start:j])
        parameter_text = normalise_ws(source.text[open_paren + 1:close_paren])
        defs.append(FunctionDef(
            name=name,
            path=source.path,
            signature=signature,
            parameter_text=parameter_text,
            start_line=line_number(source.text, start),
            body_start_line=line_number(source.text, j),
            end_line=line_number(source.text, body_end),
            start_offset=start,
            body_start_offset=j,
            body_end_offset=body_end,
            body_text=source.text[j:body_end + 1],
        ))
    # Remove nested false positives by retaining the outer function when ranges overlap.
    defs.sort(key=lambda d: (d.start_offset, -(d.body_end_offset - d.start_offset)))
    filtered: list[FunctionDef] = []
    for item in defs:
        if any(prev.start_offset <= item.start_offset <= prev.body_end_offset for prev in filtered):
            continue
        filtered.append(item)
    return filtered


def find_symbol_occurrences(source: SourceFile, symbol: str, functions: list[FunctionDef]) -> list[dict[str, Any]]:
    masked = mask_comments_and_literals(source.text)
    occurrences: list[dict[str, Any]] = []
    pattern = re.compile(rf"\b{re.escape(symbol)}\s*\(")
    def_ranges = {(f.start_offset, f.body_end_offset): f for f in functions if f.name == symbol}
    for m in pattern.finditer(masked):
        open_paren = masked.find("(", m.start())
        close_paren = matching_delimiter(masked, open_paren, "(", ")")
        if close_paren is None:
            classification = "unclassified"
        else:
            j = close_paren + 1
            while j < len(masked) and masked[j].isspace():
                j += 1
            if any(start <= m.start() <= end for (start, end) in def_ranges):
                classification = "definition"
            elif j < len(masked) and masked[j] == ";":
                containing = next((f for f in functions if f.body_start_offset <= m.start() <= f.body_end_offset), None)
                classification = "call" if containing else "declaration"
            else:
                containing = next((f for f in functions if f.body_start_offset <= m.start() <= f.body_end_offset), None)
                classification = "call" if containing else "declaration_or_macro_context"
        occurrences.append({
            "path": source.path,
            "line": line_number(source.text, m.start()),
            "classification": classification,
            "text": source.text[source.text.rfind("\n", 0, m.start()) + 1: source.text.find("\n", m.start()) if source.text.find("\n", m.start()) >= 0 else len(source.text)].strip(),
        })
    return occurrences


def split_parameters(raw: str) -> list[str]:
    if not raw or raw == "void":
        return []
    parts: list[str] = []
    depth = 0
    start = 0
    for i, c in enumerate(raw):
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth = max(0, depth - 1)
        elif c == "," and depth == 0:
            parts.append(normalise_ws(raw[start:i]))
            start = i + 1
    parts.append(normalise_ws(raw[start:]))
    return [p for p in parts if p]


def parse_includes(source: SourceFile) -> list[dict[str, Any]]:
    items = []
    for idx, line in enumerate(source.text.splitlines(), start=1):
        m = re.match(r"\s*#\s*include\s*([<\"])([^>\"]+)[>\"]", line)
        if m:
            items.append({"path": source.path, "line": idx, "kind": "quoted" if m.group(1) == '"' else "system", "include": m.group(2)})
    return items


def resolve_include(repo: Path, include_item: dict[str, Any], source: SourceFile, include_dirs: list[str]) -> dict[str, Any]:
    candidates: list[Path] = []
    if include_item["kind"] == "quoted":
        candidates.append(source.abs_path.parent / include_item["include"])
    candidates.extend(repo / d / include_item["include"] for d in include_dirs)
    for candidate in candidates:
        try:
            resolved = candidate.resolve(strict=False)
        except OSError:
            continue
        if is_inside(resolved, repo) and candidate.is_file() and not candidate.is_symlink():
            return {**include_item, "resolution": "repository_local", "resolved_path": candidate.relative_to(repo).as_posix()}
    if include_item["kind"] == "system":
        return {**include_item, "resolution": "external_or_system", "resolved_path": None}
    return {**include_item, "resolution": "unresolved_local", "resolved_path": None}


def parse_macros(source: SourceFile) -> list[dict[str, Any]]:
    lines = source.text.splitlines()
    result = []
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r"\s*#\s*define\s+([A-Za-z_][A-Za-z0-9_]*)(.*)$", line)
        if not m:
            i += 1
            continue
        start_line = i + 1
        combined = line
        while combined.rstrip().endswith("\\") and i + 1 < len(lines):
            i += 1
            combined += "\n" + lines[i]
        m2 = re.match(r"\s*#\s*define\s+([A-Za-z_][A-Za-z0-9_]*)(.*)$", combined, flags=re.S)
        if m2:
            result.append({"name": m2.group(1), "value": m2.group(2).strip(), "path": source.path, "line": start_line})
        i += 1
    return result


def scan_typedefs(source: SourceFile) -> list[dict[str, Any]]:
    masked = mask_comments_and_literals(source.text)
    result = []
    for m in re.finditer(r"\btypedef\b", masked):
        depth_brace = depth_paren = depth_bracket = 0
        end = None
        for i in range(m.start(), min(len(masked), m.start() + 10000)):
            c = masked[i]
            if c == "{": depth_brace += 1
            elif c == "}": depth_brace = max(0, depth_brace - 1)
            elif c == "(": depth_paren += 1
            elif c == ")": depth_paren = max(0, depth_paren - 1)
            elif c == "[": depth_bracket += 1
            elif c == "]": depth_bracket = max(0, depth_bracket - 1)
            elif c == ";" and depth_brace == depth_paren == depth_bracket == 0:
                end = i
                break
        if end is None:
            continue
        snippet = source.text[m.start():end + 1]
        names = re.findall(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*;\s*$", snippet, flags=re.S)
        name = names[-1] if names else None
        result.append({
            "name": name,
            "path": source.path,
            "start_line": line_number(source.text, m.start()),
            "end_line": line_number(source.text, end),
            "text": normalise_ws(snippet),
        })
    return result


def scan_named_structs(source: SourceFile) -> list[dict[str, Any]]:
    masked = mask_comments_and_literals(source.text)
    result = []
    for m in re.finditer(r"\b(struct|union|enum)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{", masked):
        brace = masked.find("{", m.start())
        end_brace = matching_delimiter(masked, brace, "{", "}")
        if end_brace is None:
            continue
        semicolon = masked.find(";", end_brace)
        end = semicolon if semicolon >= 0 else end_brace
        result.append({
            "kind": m.group(1),
            "name": m.group(2),
            "path": source.path,
            "start_line": line_number(source.text, m.start()),
            "end_line": line_number(source.text, end),
            "text": normalise_ws(source.text[m.start():end + 1]),
        })
    return result


def call_sites(function: FunctionDef, source: SourceFile) -> list[dict[str, Any]]:
    masked = mask_comments_and_literals(source.text)
    body = masked[function.body_start_offset:function.body_end_offset + 1]
    result = []
    for m in re.finditer(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*\(", body):
        name = m.group(1)
        if name in CONTROL_KEYWORDS:
            continue
        absolute = function.body_start_offset + m.start(1)
        result.append({"symbol": name, "path": source.path, "line": line_number(source.text, absolute), "classification": "direct_lexical_call_candidate"})
    return result


def loop_headers(function: FunctionDef, source: SourceFile) -> list[dict[str, Any]]:
    masked = mask_comments_and_literals(source.text)
    body = masked[function.body_start_offset:function.body_end_offset + 1]
    result = []
    for m in re.finditer(r"\b(for|while)\s*\(", body):
        kind = m.group(1)
        open_paren = body.find("(", m.start())
        close = matching_delimiter(body, open_paren, "(", ")")
        if close is None:
            continue
        header = normalise_ws(function.body_text[m.start():close + 1])
        condition = header
        if kind == "for":
            raw_inside = body[open_paren + 1:close]
            parts = raw_inside.split(";")
            if len(parts) >= 2:
                condition = parts[1]
        tokens = sorted(set(re.findall(r"\b(?:[A-Z_][A-Z0-9_]*|0[xX][0-9A-Fa-f]+|\d+)\b", condition)))
        result.append({
            "kind": kind,
            "path": source.path,
            "line": line_number(source.text, function.body_start_offset + m.start()),
            "header": header,
            "syntactic_bound_tokens": tokens,
            "bound_classification": "NOT_INFERRED",
        })
    for m in re.finditer(r"\bdo\b", body):
        result.append({
            "kind": "do",
            "path": source.path,
            "line": line_number(source.text, function.body_start_offset + m.start()),
            "header": "do",
            "syntactic_bound_tokens": [],
            "bound_classification": "NOT_INFERRED",
        })
    return sorted(result, key=lambda x: (x["line"], x["kind"]))


def array_expressions(function: FunctionDef, source: SourceFile) -> list[dict[str, Any]]:
    masked = mask_comments_and_literals(source.text)
    body = masked[function.body_start_offset:function.body_end_offset + 1]
    result = []
    pattern = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*(?:(?:->|\.)[A-Za-z_][A-Za-z0-9_]*)*)\s*\[([^\]\n]{0,200})\]")
    for m in pattern.finditer(body):
        absolute = function.body_start_offset + m.start()
        result.append({
            "expression": normalise_ws(function.body_text[m.start():m.end()]),
            "base": m.group(1),
            "index_text": normalise_ws(m.group(2)),
            "path": source.path,
            "line": line_number(source.text, absolute),
            "bounds_classification": "NOT_INFERRED",
        })
    return result


def pointer_expressions(function: FunctionDef, source: SourceFile) -> list[dict[str, Any]]:
    masked = mask_comments_and_literals(source.text)
    body = masked[function.body_start_offset:function.body_end_offset + 1]
    result = []
    seen = set()
    for m in re.finditer(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*->\s*([A-Za-z_][A-Za-z0-9_]*)", body):
        absolute = function.body_start_offset + m.start()
        key = (m.start(), m.end(), "member_access")
        if key not in seen:
            result.append({
                "kind": "pointer_member_access",
                "expression": normalise_ws(function.body_text[m.start():m.end()]),
                "path": source.path,
                "line": line_number(source.text, absolute),
                "validity_classification": "NOT_INFERRED",
            })
            seen.add(key)
    for m in re.finditer(r"(?<![A-Za-z0-9_])\*\s*([A-Za-z_][A-Za-z0-9_]*)", body):
        absolute = function.body_start_offset + m.start()
        result.append({
            "kind": "dereference_candidate",
            "expression": normalise_ws(function.body_text[m.start():m.end()]),
            "path": source.path,
            "line": line_number(source.text, absolute),
            "validity_classification": "NOT_INFERRED",
        })
    return sorted(result, key=lambda x: (x["line"], x["kind"], x["expression"]))


def truncate(items: list[Any], max_items: int, category: str, warnings: list[str]) -> list[Any]:
    if len(items) > max_items:
        warnings.append(f"Truncated {category} from {len(items)} to {max_items} items")
        return items[:max_items]
    return items


def select_compile_command(repo: Path, request: dict[str, Any], target_rel: str | None) -> tuple[dict[str, Any], list[str], list[str]]:
    build = request["build"]
    warnings: list[str] = []
    incomplete: list[str] = []
    if build["mode"] == "none":
        return {
            "mode": "none",
            "source": "not_supplied",
            "working_directory": None,
            "compiler": None,
            "arguments": [],
            "preprocess_command": None,
        }, ["No exact build context was supplied; preprocessing and active-macro claims are unavailable"], []

    if target_rel is None:
        incomplete.append("A target.source_file is required for build-context selection and preprocessing")
        return {
            "mode": build["mode"], "source": "unresolved", "working_directory": None,
            "compiler": None, "arguments": [], "preprocess_command": None,
        }, warnings, incomplete

    if build["mode"] == "explicit":
        cwd_rel = build["working_directory"]
        cwd = repo if cwd_rel == "." else safe_repo_path(repo, cwd_rel, "build.working_directory")
        if not cwd.is_dir():
            raise ContractError("build.working_directory must be a directory")
        for idx, inc in enumerate(build["include_dirs"]):
            p = safe_repo_path(repo, inc, f"build.include_dirs[{idx}]")
            if not p.is_dir():
                raise ContractError(f"build include directory is not a directory: {inc}")
        for idx, forced in enumerate(build["forced_includes"]):
            p = safe_repo_path(repo, forced, f"build.forced_includes[{idx}]")
            if not p.is_file():
                raise ContractError(f"forced include is not a file: {forced}")
        args = [build["compiler"]]
        if build["language_standard"]:
            args.append(f"-std={build['language_standard']}")
        for inc in build["include_dirs"]:
            args.append(f"-I{inc}")
        for define in build["defines"]:
            args.append(f"-D{define['name']}={define['value']}" if "value" in define else f"-D{define['name']}")
        for undef in build["undefines"]:
            args.append(f"-U{undef}")
        for forced in build["forced_includes"]:
            args.extend(["-include", forced])
        args.extend(build["extra_args"])
        target_arg = os.path.relpath(repo / target_rel, cwd).replace(os.sep, "/")
        preprocess = args + ["-E", "-dD", "-P", target_arg]
        return {
            "mode": "explicit",
            "source": "request",
            "working_directory": "." if cwd == repo else cwd.relative_to(repo).as_posix(),
            "compiler": build["compiler"],
            "arguments": args,
            "preprocess_command": preprocess,
        }, warnings, incomplete

    compdb_path = safe_repo_path(repo, build["compile_commands_file"], "build.compile_commands_file")
    try:
        database = json.loads(compdb_path.read_text(encoding="utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ContractError(f"compile_commands_file is not valid UTF-8 JSON: {exc}") from exc
    if not isinstance(database, list):
        raise ContractError("compile_commands_file root must be an array")
    target_abs = (repo / target_rel).resolve()
    matches = []
    for idx, entry in enumerate(database):
        if not isinstance(entry, dict):
            continue
        directory = entry.get("directory")
        file_value = entry.get("file")
        if not isinstance(directory, str) or not isinstance(file_value, str):
            continue
        directory_path = Path(directory)
        if not directory_path.is_absolute():
            directory_path = repo / directory_path
        try:
            file_abs = (directory_path / file_value).resolve()
        except OSError:
            continue
        if file_abs == target_abs:
            matches.append((idx, entry, directory_path.resolve()))
    if len(matches) != 1:
        incomplete.append(f"Expected exactly one compile_commands entry for {target_rel}; found {len(matches)}")
        return {
            "mode": "compile_commands", "source": build["compile_commands_file"],
            "working_directory": None, "compiler": None, "arguments": [], "preprocess_command": None,
        }, warnings, incomplete
    idx, entry, cwd = matches[0]
    if not is_inside(cwd, repo):
        raise ContractError("selected compile_commands directory must remain inside the repository")
    if "arguments" in entry:
        argv = entry["arguments"]
        if not isinstance(argv, list) or not argv or any(not isinstance(x, str) for x in argv):
            raise ContractError("compile_commands arguments must be a non-empty string array")
    elif "command" in entry:
        command = entry["command"]
        if not isinstance(command, str) or not command.strip():
            raise ContractError("compile_commands command must be a non-empty string")
        if any(token in command for token in [";", "&&", "||", "`", "$(", "\n", "\r"]):
            raise ContractError("compile_commands command contains shell syntax; use an arguments array")
        argv = shlex.split(command, posix=True)
    else:
        raise ContractError("selected compile_commands entry requires arguments or command")
    if not argv:
        raise ContractError("selected compile command is empty")
    if any(arg in SHELL_META or "\x00" in arg or "\n" in arg or "\r" in arg for arg in argv):
        raise ContractError("selected compile command contains unsafe shell tokens")

    stripped: list[str] = [argv[0]]
    i = 1
    target_variants = {target_rel, str(target_abs), os.path.relpath(target_abs, cwd)}
    while i < len(argv):
        arg = argv[i]
        if arg == "-c":
            i += 1
            continue
        if arg == "-o":
            i += 2
            continue
        if arg.startswith("-o") and len(arg) > 2:
            i += 1
            continue
        try:
            arg_path = (cwd / arg).resolve() if not Path(arg).is_absolute() else Path(arg).resolve()
        except OSError:
            arg_path = None
        if arg in target_variants or arg_path == target_abs:
            i += 1
            continue
        stripped.append(arg)
        i += 1
    target_arg = os.path.relpath(target_abs, cwd).replace(os.sep, "/")
    preprocess = stripped + ["-E", "-dD", "-P", target_arg]
    return {
        "mode": "compile_commands",
        "source": build["compile_commands_file"],
        "entry_index": idx,
        "working_directory": "." if cwd == repo else cwd.relative_to(repo).as_posix(),
        "compiler": argv[0],
        "arguments": argv,
        "preprocess_command": preprocess,
    }, warnings, incomplete


def run_preprocessor(repo: Path, compile_context: dict[str, Any], request: dict[str, Any], symbol: str) -> tuple[dict[str, Any], str | None, list[str], list[str]]:
    warnings: list[str] = []
    incomplete: list[str] = []
    if not request["options"]["preprocess"]:
        return {"requested": False, "status": "NOT_REQUESTED"}, None, warnings, incomplete
    command = compile_context.get("preprocess_command")
    if not command:
        message = "Preprocessing was requested but no executable build context was available"
        (incomplete if request["options"]["preprocess_required"] else warnings).append(message)
        return {"requested": True, "status": "UNAVAILABLE"}, None, warnings, incomplete
    executable = shutil.which(command[0])
    if executable is None:
        message = f"Compiler executable not found: {command[0]}"
        (incomplete if request["options"]["preprocess_required"] else warnings).append(message)
        return {"requested": True, "status": "COMPILER_NOT_FOUND", "command": command}, None, warnings, incomplete
    cwd_rel = compile_context["working_directory"]
    cwd = repo if cwd_rel == "." else repo / cwd_rel
    env = os.environ.copy()
    env.update({"LC_ALL": "C", "LANG": "C", "TZ": "UTC", "SOURCE_DATE_EPOCH": "0"})
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            env=env,
            text=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=request["options"]["preprocess_timeout_seconds"],
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        message = f"Preprocessor timed out after {request['options']['preprocess_timeout_seconds']} seconds"
        (incomplete if request["options"]["preprocess_required"] else warnings).append(message)
        return {"requested": True, "status": "TIMEOUT", "command": command}, None, warnings, incomplete
    stdout = result.stdout
    stderr = result.stderr.decode("utf-8", errors="replace")
    evidence = {
        "requested": True,
        "status": "SUCCEEDED" if result.returncode == 0 else "FAILED",
        "command": command,
        "working_directory": cwd_rel,
        "exit_code": result.returncode,
        "stdout_sha256": sha256_bytes(stdout),
        "stdout_bytes": len(stdout),
        "stderr": stderr[:20000],
        "stderr_truncated": len(stderr) > 20000,
        "environment_overrides": {"LC_ALL": "C", "LANG": "C", "TZ": "UTC", "SOURCE_DATE_EPOCH": "0"},
    }
    if result.returncode != 0:
        message = f"Preprocessor exited with code {result.returncode}"
        (incomplete if request["options"]["preprocess_required"] else warnings).append(message)
        return evidence, None, warnings, incomplete
    text = stdout.decode("utf-8", errors="replace")
    pseudo = SourceFile(path="<preprocessed>", abs_path=Path("<preprocessed>"), sha256=evidence["stdout_sha256"], size=len(stdout), text=text, decode_status="utf8" if "\ufffd" not in text else "utf8_with_replacement")
    defs = [f for f in parse_functions(pseudo) if f.name == symbol]
    if not defs:
        warnings.append("Preprocessing succeeded but no target definition was found in the preprocessed output")
        evidence["target_definition_count"] = 0
        return evidence, None, warnings, incomplete
    chosen = defs[0]
    lines = text.splitlines()
    start = max(1, chosen.start_line - request["options"]["excerpt_context_lines"])
    end = min(len(lines), chosen.end_line + request["options"]["excerpt_context_lines"])
    excerpt_lines = [f"/* preprocessed lines {start}-{end}; lexical excerpt only */"]
    excerpt_lines.extend(lines[start - 1:end])
    excerpt = "\n".join(excerpt_lines) + "\n"
    evidence["target_definition_count"] = len(defs)
    evidence["excerpt_start_line"] = start
    evidence["excerpt_end_line"] = end
    if len(defs) > 1:
        warnings.append(f"Preprocessed output contained {len(defs)} lexical definitions for {symbol}; excerpt uses the first")
    return evidence, excerpt, warnings, incomplete


def markdown_report(report: dict[str, Any]) -> str:
    lines = [
        f"# Target build context — `{report['target']['symbol']}`",
        "",
        f"- **Status:** `{report['status']}`",
        f"- **Semantic authority:** `{report['semantic_authority']}`",
        f"- **Analysis nature:** `{report['analysis_nature']}`",
        f"- **Request:** `{report['request_id']}`",
        "",
        "## Target identity",
        "",
        f"- Requested source: `{report['target'].get('source_file') or 'not supplied'}`",
        f"- Definition count: `{len(report['definitions'])}`",
        f"- Declaration/call occurrence count: `{len(report['occurrences'])}`",
    ]
    if report["definitions"]:
        d = report["definitions"][0]
        lines += [
            f"- First definition: `{d['path']}:{d['start_line']}-{d['end_line']}`",
            f"- Signature: `{d['signature']}`",
        ]
    lines += ["", "## Build context", "", f"- Mode: `{report['build_summary']['mode']}`", f"- Source: `{report['build_summary']['source']}`"]
    pre = report["build_summary"]["preprocessing"]
    lines.append(f"- Preprocessing: `{pre['status']}`")

    def section(title: str, items: list[dict[str, Any]], formatter) -> None:
        lines.extend(["", f"## {title}", ""])
        if not items:
            lines.append("_None recorded._")
        else:
            for item in items:
                lines.append(f"- {formatter(item)}")

    section("Direct lexical callers", report["direct_callers"], lambda x: f"`{x['caller']}` at `{x['path']}:{x['line']}`")
    section("Direct lexical callees", report["direct_callees"], lambda x: f"`{x['symbol']}` at `{x['path']}:{x['line']}` — `{x['classification']}`")
    section("Loop headers", report["loops"], lambda x: f"`{x['path']}:{x['line']}` `{x['header']}`; bound classification `{x['bound_classification']}`")
    section("Array expressions", report["array_expressions"], lambda x: f"`{x['path']}:{x['line']}` `{x['expression']}`; bounds `{x['bounds_classification']}`")
    section("Pointer expressions", report["pointer_expressions"], lambda x: f"`{x['path']}:{x['line']}` `{x['expression']}`; validity `{x['validity_classification']}`")
    section("Referenced macro definitions", report["referenced_macros"], lambda x: f"`{x['name']}` = `{x['value']}` at `{x['path']}:{x['line']}`")
    section("Relevant type declarations", report["relevant_type_declarations"], lambda x: f"`{x.get('name')}` at `{x['path']}:{x['start_line']}-{x['end_line']}`")

    lines += ["", "## Warnings and incomplete reasons", ""]
    if not report["warnings"] and not report["incomplete_reasons"]:
        lines.append("_None._")
    else:
        for item in report["incomplete_reasons"]:
            lines.append(f"- **INCOMPLETE:** {item}")
        for item in report["warnings"]:
            lines.append(f"- **WARNING:** {item}")

    lines += [
        "",
        "## Fixed limitations",
        "",
    ]
    for item in report["limitations"]:
        lines.append(f"- {item}")
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Deterministically map a local C target and supplied build context")
    parser.add_argument("--request", required=True)
    parser.add_argument("--repo-root", required=True)
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()

    try:
        request_path = Path(args.request).resolve(strict=True)
        repo = Path(args.repo_root).resolve(strict=True)
        output_dir = Path(args.output_dir).resolve(strict=False)
        if not request_path.is_file():
            raise ContractError("--request must be a regular file")
        if not repo.is_dir():
            raise ContractError("--repo-root must be a directory")
        if is_inside(output_dir, repo):
            raise ContractError("--output-dir must not be inside the repository")
        try:
            raw_request = json.loads(request_path.read_text(encoding="utf-8"))
        except UnicodeDecodeError as exc:
            raise ContractError("request is not valid UTF-8") from exc
        except json.JSONDecodeError as exc:
            raise ContractError(f"request is not valid JSON: {exc}") from exc
        request = validate_request(raw_request)
        target_rel = request["target"].get("source_file")
        if target_rel is not None:
            target_path = safe_repo_path(repo, target_rel, "target.source_file")
            if not target_path.is_file() or target_path.suffix.lower() not in SUPPORTED_EXTENSIONS:
                raise ContractError("target.source_file must be a supported regular source file")

        source_paths, skipped = enumerate_sources(repo, request, output_dir)
        if not source_paths:
            print("No supported source files were available for inspection", file=sys.stderr)
            return 4
        sources, warnings = load_sources(repo, source_paths)
        source_by_path = {s.path: s for s in sources}
        if target_rel is not None and target_rel not in source_by_path:
            raise ContractError("target.source_file must be included in the inspected source scope")

        incomplete: list[str] = []
        if target_rel is not None and "expected_sha256" in request["target"]:
            actual = source_by_path[target_rel].sha256
            if actual != request["target"]["expected_sha256"]:
                incomplete.append(f"Target SHA-256 mismatch for {target_rel}: expected {request['target']['expected_sha256']}, found {actual}")

        all_functions: dict[str, list[FunctionDef]] = {}
        all_occurrences: list[dict[str, Any]] = []
        symbol = request["target"]["symbol"]
        for source in sources:
            funcs = parse_functions(source)
            all_functions[source.path] = funcs
            all_occurrences.extend(find_symbol_occurrences(source, symbol, funcs))

        definitions = [f for path, funcs in all_functions.items() for f in funcs if f.name == symbol]
        if target_rel is not None:
            target_defs = [f for f in definitions if f.path == target_rel]
            other_defs = [f for f in definitions if f.path != target_rel]
            if len(target_defs) != 1:
                incomplete.append(f"Expected exactly one definition of {symbol} in {target_rel}; found {len(target_defs)}")
            if other_defs:
                incomplete.append(f"Found {len(other_defs)} additional definition(s) of {symbol} outside {target_rel}")
            chosen = target_defs[0] if len(target_defs) == 1 else None
        else:
            if len(definitions) != 1:
                incomplete.append(f"Expected exactly one definition of {symbol} in the inspected scope; found {len(definitions)}")
            chosen = definitions[0] if len(definitions) == 1 else None

        include_dirs = request["build"].get("include_dirs", []) if request["build"]["mode"] == "explicit" else []
        include_items = []
        for source in sources:
            for item in parse_includes(source):
                include_items.append(resolve_include(repo, item, source, include_dirs))
        unresolved_local = [x for x in include_items if x["resolution"] == "unresolved_local"]
        if unresolved_local:
            warnings.append(f"Unresolved repository-local include directives: {len(unresolved_local)}")

        macro_defs = [m for source in sources for m in parse_macros(source)]
        typedefs = [t for source in sources for t in scan_typedefs(source)]
        structs = [s for source in sources for s in scan_named_structs(source)]
        direct_callers: list[dict[str, Any]] = []
        direct_callees: list[dict[str, Any]] = []
        loops: list[dict[str, Any]] = []
        arrays: list[dict[str, Any]] = []
        pointers: list[dict[str, Any]] = []
        referenced_macros: list[dict[str, Any]] = []
        relevant_types: list[dict[str, Any]] = []
        parameters: list[str] = []

        if chosen is not None:
            source = source_by_path[chosen.path]
            parameters = split_parameters(chosen.parameter_text)
            for path, funcs in all_functions.items():
                src = source_by_path[path]
                for function in funcs:
                    if function.name == symbol and function.path == chosen.path:
                        continue
                    for call in call_sites(function, src):
                        if call["symbol"] == symbol:
                            direct_callers.append({"caller": function.name, "path": path, "line": call["line"], "classification": "direct_lexical_caller"})
            direct_callees = [x for x in call_sites(chosen, source) if x["symbol"] != symbol]
            loops = loop_headers(chosen, source)
            arrays = array_expressions(chosen, source)
            pointers = pointer_expressions(chosen, source)
            target_text = f"{chosen.signature} {chosen.body_text}"
            identifiers = set(re.findall(r"\b[A-Za-z_][A-Za-z0-9_]*\b", target_text))
            referenced_macros = [m for m in macro_defs if m["name"] in identifiers]
            for item in typedefs:
                if item.get("name") and item["name"] in identifiers:
                    relevant_types.append({"kind": "typedef", **item})
            for item in structs:
                if item["name"] in identifiers:
                    relevant_types.append(item)

        compile_context, build_warnings, build_incomplete = select_compile_command(repo, request, target_rel)
        warnings.extend(build_warnings)
        incomplete.extend(build_incomplete)
        preprocessing, excerpt, pp_warnings, pp_incomplete = run_preprocessor(repo, compile_context, request, symbol)
        warnings.extend(pp_warnings)
        incomplete.extend(pp_incomplete)
        compile_context["preprocessing"] = preprocessing

        max_items = request["options"]["max_items_per_category"]
        all_occurrences = truncate(sorted(all_occurrences, key=lambda x: (x["path"], x["line"], x["classification"])), max_items, "occurrences", warnings)
        direct_callers = truncate(sorted(direct_callers, key=lambda x: (x["path"], x["line"], x["caller"])), max_items, "direct callers", warnings)
        direct_callees = truncate(sorted(direct_callees, key=lambda x: (x["path"], x["line"], x["symbol"])), max_items, "direct callees", warnings)
        loops = truncate(loops, max_items, "loops", warnings)
        arrays = truncate(arrays, max_items, "array expressions", warnings)
        pointers = truncate(pointers, max_items, "pointer expressions", warnings)
        referenced_macros = truncate(sorted(referenced_macros, key=lambda x: (x["name"], x["path"], x["line"])), max_items, "referenced macros", warnings)
        relevant_types = truncate(sorted(relevant_types, key=lambda x: (str(x.get("name")), x["path"], x["start_line"])), max_items, "relevant type declarations", warnings)

        limitations = [
            "All declaration, definition, caller, callee, macro-reference, loop, array, pointer, and type relationships are lexical or structural observations, not semantic proofs.",
            "The skill does not infer active macro values unless an explicit preprocessing command succeeds; even then, the excerpt is evidence rather than build equivalence proof.",
            "Loop bound tokens are reported without deciding whether the loop is fixed, terminating, sufficient, or safe.",
            "Array and pointer expressions are reported without inferring bounds, validity, aliasing, lifetime, or memory safety.",
            "The direct-call map can miss macro-expanded, indirect, function-pointer, generated, assembly, or dynamically selected calls.",
            "A supplied explicit or compile-database command is recorded and used mechanically; the skill does not certify that it is the authoritative project build.",
            "No report status means that the implementation, theorem, harness, or proof is correct.",
        ]

        status = STATUS_INCOMPLETE if incomplete else STATUS_WARN if warnings else STATUS_COMPLETE
        definitions_json = [{
            "path": d.path,
            "start_line": d.start_line,
            "body_start_line": d.body_start_line,
            "end_line": d.end_line,
            "signature": d.signature,
            "parameter_text": d.parameter_text,
        } for d in sorted(definitions, key=lambda x: (x.path, x.start_line))]
        declarations = [x for x in all_occurrences if x["classification"] in {"declaration", "declaration_or_macro_context"}]

        report = {
            "schema_version": "1.0",
            "request_id": request["request_id"],
            "status": status,
            "semantic_authority": "NONE",
            "analysis_nature": "LEXICAL_AND_BUILD_STRUCTURAL_ONLY",
            "target": {
                "symbol": symbol,
                "source_file": target_rel,
                "expected_sha256": request["target"].get("expected_sha256"),
                "actual_sha256": source_by_path[target_rel].sha256 if target_rel in source_by_path else None,
            },
            "definitions": definitions_json,
            "declarations": declarations,
            "occurrences": all_occurrences,
            "parameters": parameters,
            "includes": sorted(include_items, key=lambda x: (x["path"], x["line"], x["include"])),
            "direct_callers": direct_callers,
            "direct_callees": direct_callees,
            "loops": loops,
            "array_expressions": arrays,
            "pointer_expressions": pointers,
            "referenced_macros": referenced_macros,
            "relevant_type_declarations": relevant_types,
            "build_summary": {
                "mode": compile_context["mode"],
                "source": compile_context["source"],
                "working_directory": compile_context.get("working_directory"),
                "compiler": compile_context.get("compiler"),
                "preprocessing": preprocessing,
            },
            "warnings": sorted(set(warnings)),
            "incomplete_reasons": sorted(set(incomplete)),
            "limitations": limitations,
        }

        manifest = {
            "schema_version": "1.0",
            "request_id": request["request_id"],
            "repository_identity": {
                "root_label": repo.name,
                "root_path_recorded": False,
                "note": "Absolute repository paths are intentionally excluded from deterministic outputs"
            },
            "scope": request["scope"],
            "files": [{
                "path": s.path, "sha256": s.sha256, "size_bytes": s.size,
                "decode_status": s.decode_status, "extension": s.abs_path.suffix.lower(),
            } for s in sources],
            "skipped_paths": skipped,
        }

        output_dir.mkdir(parents=True, exist_ok=False)
        write_text(output_dir / "canonical_request.json", canonical_json(request))
        write_text(output_dir / "source_manifest.json", canonical_json(manifest))
        write_text(output_dir / "compile_context.json", canonical_json(compile_context))
        write_text(output_dir / "target_context.json", canonical_json(report))
        write_text(output_dir / "target_context.md", markdown_report(report))
        if excerpt is not None:
            write_text(output_dir / "preprocessed_target_excerpt.c", excerpt)
            write_text(output_dir / "preprocess_stdout.sha256", preprocessing["stdout_sha256"] + "\n")

        print(canonical_json({"status": status, "output_dir": str(output_dir), "exit_code": 2 if status == STATUS_INCOMPLETE else 0}), end="")
        return 2 if status == STATUS_INCOMPLETE else 0
    except ContractError as exc:
        print(f"CONTRACT ERROR: {exc}", file=sys.stderr)
        return 3
    except FileExistsError:
        print("CONTRACT ERROR: --output-dir already exists; use a new run-specific directory", file=sys.stderr)
        return 3
    except Exception as exc:  # defensive boundary
        print(f"UNEXPECTED ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 5


if __name__ == "__main__":
    raise SystemExit(main())
