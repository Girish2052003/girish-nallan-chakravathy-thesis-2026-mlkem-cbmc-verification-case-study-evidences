#!/usr/bin/env python3
"""Build a deterministic, non-semantic evidence manifest for a verification run."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Iterable

VERSION = "1.0.0-rc1"
SCHEMA_VERSION = "1.0"
SEMANTIC_AUTHORITY = "NONE"
GATE_AUTHORITY = "NONE"

ROLES = {
    "SOURCE_REVISION_EVIDENCE",
    "SPECIFICATION_EVIDENCE",
    "BUILD_CONTEXT_EVIDENCE",
    "HARNESS",
    "CBMC_COMMAND",
    "CBMC_RAW_STDOUT",
    "CBMC_RAW_STDERR",
    "CBMC_EXECUTION_SUMMARY",
    "COUNTEREXAMPLE_VIEW",
    "INTEGRITY_AUDIT",
    "NONVACUITY_REPORT",
    "CODEX_EVENT_LOG",
    "SKILL_OUTPUT",
    "ENVIRONMENT_SNAPSHOT",
    "REPAIR_LOG",
    "FINAL_STATUS_RECORD",
    "PROPERTY_RECORD",
    "OTHER",
}

TOP_KEYS = {
    "schema_version",
    "run_id",
    "generated_at_utc",
    "target",
    "source_revision",
    "final_status_supplied_by_codex",
    "property_records",
    "artifacts",
    "required_roles",
    "scan_policy",
    "harness_parsing",
}
TARGET_KEYS = {"symbol", "source_file", "configuration"}
REVISION_KEYS = {"kind", "value", "evidence_path"}
FINAL_STATUS_KEYS = {"value", "notes"}
PROPERTY_KEYS = {"property_id", "statement", "provenance", "status_supplied_by_codex"}
PROVENANCE_KEYS = {"path", "line_start", "line_end"}
ARTIFACT_KEYS = {
    "path",
    "role",
    "required",
    "expected_sha256",
    "media_type",
    "skill_name",
    "iteration",
    "description",
    "extract_json_fields",
}
FIELD_KEYS = {"label", "json_pointer"}
SCAN_KEYS = {"report_unlisted_files", "max_files", "max_total_bytes", "max_text_parse_bytes"}
HARNESS_KEYS = {"enabled", "roles", "assume_functions", "assert_functions"}

HEX64 = re.compile(r"^[0-9a-f]{64}$")
IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_.:-]*$")
SYMBOL = re.compile(r"^[A-Za-z_$][A-Za-z0-9_$]*$")


class ContractError(Exception):
    pass


class ProcessingError(Exception):
    pass


def canonical_json(obj: Any) -> str:
    return json.dumps(obj, sort_keys=True, indent=2, ensure_ascii=False) + "\n"


def write_json(path: Path, obj: Any) -> None:
    path.write_text(canonical_json(obj), encoding="utf-8")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def require_exact_keys(obj: dict[str, Any], allowed: set[str], label: str) -> None:
    unknown = set(obj) - allowed
    if unknown:
        raise ContractError(f"{label} contains unknown field(s): {', '.join(sorted(unknown))}")


def require_string(value: Any, label: str, *, allow_empty: bool = False) -> str:
    if not isinstance(value, str):
        raise ContractError(f"{label} must be a string")
    if not allow_empty and not value.strip():
        raise ContractError(f"{label} must not be empty")
    return value


def validate_rel_path(value: Any, label: str) -> str:
    s = require_string(value, label)
    p = Path(s)
    if p.is_absolute():
        raise ContractError(f"{label} must be relative")
    if any(part in {"", ".", ".."} for part in p.parts):
        raise ContractError(f"{label} contains an unsafe path component")
    return p.as_posix()


def validate_nullable_rel_path(value: Any, label: str) -> str | None:
    if value is None:
        return None
    return validate_rel_path(value, label)


def validate_sha(value: Any, label: str) -> str | None:
    if value is None:
        return None
    s = require_string(value, label).lower()
    if not HEX64.fullmatch(s):
        raise ContractError(f"{label} must be a lowercase 64-character SHA-256 value or null")
    return s


def ensure_output_location(run_root: Path, output_dir: Path) -> None:
    rr = run_root.resolve(strict=True)
    out = output_dir.resolve(strict=False)
    try:
        out.relative_to(rr)
        raise ContractError("output directory must be outside the run root")
    except ValueError:
        pass
    if output_dir.exists():
        raise ContractError("output directory already exists")
    parent = output_dir.parent.resolve(strict=True)
    if parent == rr or rr in parent.parents:
        raise ContractError("output directory parent must be outside the run root")


def resolve_input(run_root: Path, rel: str, label: str) -> Path:
    candidate = run_root / rel
    current = run_root
    for part in Path(rel).parts:
        current = current / part
        if current.is_symlink():
            raise ContractError(f"{label} must not use a symlinked path component: {rel}")
        if not current.exists():
            return candidate
    resolved = candidate.resolve(strict=True)
    try:
        resolved.relative_to(run_root)
    except ValueError as e:
        raise ContractError(f"{label} escapes the run root: {rel}") from e
    return resolved


def validate_request(obj: Any) -> dict[str, Any]:
    if not isinstance(obj, dict):
        raise ContractError("request must be a JSON object")
    require_exact_keys(obj, TOP_KEYS, "request")
    if set(obj) != TOP_KEYS:
        missing = TOP_KEYS - set(obj)
        raise ContractError(f"request missing field(s): {', '.join(sorted(missing))}")
    if obj["schema_version"] != SCHEMA_VERSION:
        raise ContractError(f"schema_version must be {SCHEMA_VERSION}")
    run_id = require_string(obj["run_id"], "run_id")
    if not IDENT.fullmatch(run_id):
        raise ContractError("run_id contains unsupported characters")
    require_string(obj["generated_at_utc"], "generated_at_utc")

    target = obj["target"]
    if not isinstance(target, dict):
        raise ContractError("target must be an object")
    require_exact_keys(target, TARGET_KEYS, "target")
    if set(target) != TARGET_KEYS:
        raise ContractError("target must contain symbol, source_file, and configuration")
    symbol = require_string(target["symbol"], "target.symbol")
    if not SYMBOL.fullmatch(symbol):
        raise ContractError("target.symbol must be a C-style symbol")
    if target["source_file"] is not None:
        validate_rel_path(target["source_file"], "target.source_file")
    if target["configuration"] is not None:
        require_string(target["configuration"], "target.configuration")

    revision = obj["source_revision"]
    if not isinstance(revision, dict):
        raise ContractError("source_revision must be an object")
    require_exact_keys(revision, REVISION_KEYS, "source_revision")
    if set(revision) != REVISION_KEYS:
        raise ContractError("source_revision must contain kind, value, and evidence_path")
    if revision["kind"] not in {"GIT_COMMIT", "ARCHIVE_HASH", "DECLARED_OTHER", "NOT_SUPPLIED"}:
        raise ContractError("source_revision.kind is invalid")
    if revision["value"] is not None:
        require_string(revision["value"], "source_revision.value")
    validate_nullable_rel_path(revision["evidence_path"], "source_revision.evidence_path")
    if revision["kind"] == "NOT_SUPPLIED" and (revision["value"] is not None or revision["evidence_path"] is not None):
        raise ContractError("NOT_SUPPLIED source revision must have null value and evidence_path")

    final_status = obj["final_status_supplied_by_codex"]
    if not isinstance(final_status, dict):
        raise ContractError("final_status_supplied_by_codex must be an object")
    require_exact_keys(final_status, FINAL_STATUS_KEYS, "final_status_supplied_by_codex")
    if set(final_status) != FINAL_STATUS_KEYS:
        raise ContractError("final_status_supplied_by_codex must contain value and notes")
    if final_status["value"] is not None:
        require_string(final_status["value"], "final_status_supplied_by_codex.value")
    if final_status["notes"] is not None:
        require_string(final_status["notes"], "final_status_supplied_by_codex.notes", allow_empty=True)

    properties = obj["property_records"]
    if not isinstance(properties, list):
        raise ContractError("property_records must be an array")
    seen_property_ids: set[str] = set()
    for i, item in enumerate(properties):
        label = f"property_records[{i}]"
        if not isinstance(item, dict):
            raise ContractError(f"{label} must be an object")
        require_exact_keys(item, PROPERTY_KEYS, label)
        if set(item) != PROPERTY_KEYS:
            raise ContractError(f"{label} must contain all required fields")
        pid = require_string(item["property_id"], f"{label}.property_id")
        if not IDENT.fullmatch(pid):
            raise ContractError(f"{label}.property_id contains unsupported characters")
        if pid in seen_property_ids:
            raise ContractError(f"duplicate property_id: {pid}")
        seen_property_ids.add(pid)
        require_string(item["statement"], f"{label}.statement")
        if item["status_supplied_by_codex"] is not None:
            require_string(item["status_supplied_by_codex"], f"{label}.status_supplied_by_codex")
        provenance = item["provenance"]
        if provenance is not None:
            if not isinstance(provenance, dict):
                raise ContractError(f"{label}.provenance must be an object or null")
            require_exact_keys(provenance, PROVENANCE_KEYS, f"{label}.provenance")
            if set(provenance) != PROVENANCE_KEYS:
                raise ContractError(f"{label}.provenance must contain path, line_start, and line_end")
            validate_rel_path(provenance["path"], f"{label}.provenance.path")
            for key in ("line_start", "line_end"):
                if not isinstance(provenance[key], int) or provenance[key] < 1:
                    raise ContractError(f"{label}.provenance.{key} must be a positive integer")
            if provenance["line_end"] < provenance["line_start"]:
                raise ContractError(f"{label}.provenance line_end must be >= line_start")

    artifacts = obj["artifacts"]
    if not isinstance(artifacts, list) or not artifacts:
        raise ContractError("artifacts must be a non-empty array")
    seen_paths: set[str] = set()
    for i, item in enumerate(artifacts):
        label = f"artifacts[{i}]"
        if not isinstance(item, dict):
            raise ContractError(f"{label} must be an object")
        require_exact_keys(item, ARTIFACT_KEYS, label)
        if set(item) != ARTIFACT_KEYS:
            raise ContractError(f"{label} must contain all required fields")
        rel = validate_rel_path(item["path"], f"{label}.path")
        if rel in seen_paths:
            raise ContractError(f"duplicate artifact path: {rel}")
        seen_paths.add(rel)
        if item["role"] not in ROLES:
            raise ContractError(f"{label}.role is invalid")
        if not isinstance(item["required"], bool):
            raise ContractError(f"{label}.required must be boolean")
        validate_sha(item["expected_sha256"], f"{label}.expected_sha256")
        if item["media_type"] is not None:
            require_string(item["media_type"], f"{label}.media_type")
        if item["skill_name"] is not None:
            sname = require_string(item["skill_name"], f"{label}.skill_name")
            if not IDENT.fullmatch(sname):
                raise ContractError(f"{label}.skill_name contains unsupported characters")
        if not isinstance(item["iteration"], int) or item["iteration"] < 0:
            raise ContractError(f"{label}.iteration must be a non-negative integer")
        require_string(item["description"], f"{label}.description", allow_empty=True)
        fields = item["extract_json_fields"]
        if not isinstance(fields, list):
            raise ContractError(f"{label}.extract_json_fields must be an array")
        seen_labels: set[str] = set()
        for j, field in enumerate(fields):
            flabel = f"{label}.extract_json_fields[{j}]"
            if not isinstance(field, dict):
                raise ContractError(f"{flabel} must be an object")
            require_exact_keys(field, FIELD_KEYS, flabel)
            if set(field) != FIELD_KEYS:
                raise ContractError(f"{flabel} must contain label and json_pointer")
            field_label = require_string(field["label"], f"{flabel}.label")
            if field_label in seen_labels:
                raise ContractError(f"duplicate JSON extraction label in {rel}: {field_label}")
            seen_labels.add(field_label)
            pointer = require_string(field["json_pointer"], f"{flabel}.json_pointer", allow_empty=True)
            if pointer and not pointer.startswith("/"):
                raise ContractError(f"{flabel}.json_pointer must be empty or begin with /")

    required_roles = obj["required_roles"]
    if not isinstance(required_roles, list):
        raise ContractError("required_roles must be an array")
    if len(set(required_roles)) != len(required_roles):
        raise ContractError("required_roles contains duplicates")
    for role in required_roles:
        if role not in ROLES:
            raise ContractError(f"invalid required role: {role}")

    scan = obj["scan_policy"]
    if not isinstance(scan, dict):
        raise ContractError("scan_policy must be an object")
    require_exact_keys(scan, SCAN_KEYS, "scan_policy")
    if set(scan) != SCAN_KEYS:
        raise ContractError("scan_policy must contain all required fields")
    if not isinstance(scan["report_unlisted_files"], bool):
        raise ContractError("scan_policy.report_unlisted_files must be boolean")
    for key in ("max_files", "max_total_bytes", "max_text_parse_bytes"):
        if not isinstance(scan[key], int) or scan[key] < 1:
            raise ContractError(f"scan_policy.{key} must be a positive integer")

    hp = obj["harness_parsing"]
    if not isinstance(hp, dict):
        raise ContractError("harness_parsing must be an object")
    require_exact_keys(hp, HARNESS_KEYS, "harness_parsing")
    if set(hp) != HARNESS_KEYS:
        raise ContractError("harness_parsing must contain all required fields")
    if not isinstance(hp["enabled"], bool):
        raise ContractError("harness_parsing.enabled must be boolean")
    if not isinstance(hp["roles"], list) or not hp["roles"]:
        raise ContractError("harness_parsing.roles must be a non-empty array")
    for role in hp["roles"]:
        if role not in ROLES:
            raise ContractError(f"invalid harness parsing role: {role}")
    for key in ("assume_functions", "assert_functions"):
        values = hp[key]
        if not isinstance(values, list) or not values:
            raise ContractError(f"harness_parsing.{key} must be a non-empty array")
        if len(set(values)) != len(values):
            raise ContractError(f"harness_parsing.{key} contains duplicates")
        for name in values:
            if not isinstance(name, str) or not SYMBOL.fullmatch(name):
                raise ContractError(f"harness_parsing.{key} contains an invalid function name")

    evidence_path = revision["evidence_path"]
    if evidence_path is not None:
        matches = [a for a in artifacts if a["path"] == evidence_path and a["role"] == "SOURCE_REVISION_EVIDENCE"]
        if len(matches) != 1:
            raise ContractError("source_revision.evidence_path must identify one SOURCE_REVISION_EVIDENCE artifact")

    return obj


def strip_comments_and_literals(text: str) -> str:
    out: list[str] = []
    i = 0
    n = len(text)
    state = "code"
    quote = ""
    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if state == "code":
            if c == "/" and nxt == "/":
                out.extend("  ")
                i += 2
                state = "line_comment"
                continue
            if c == "/" and nxt == "*":
                out.extend("  ")
                i += 2
                state = "block_comment"
                continue
            if c in {'"', "'"}:
                quote = c
                out.append(" ")
                i += 1
                state = "literal"
                continue
            out.append(c)
            i += 1
            continue
        if state == "line_comment":
            if c == "\n":
                out.append("\n")
                state = "code"
            else:
                out.append(" ")
            i += 1
            continue
        if state == "block_comment":
            if c == "*" and nxt == "/":
                out.extend("  ")
                i += 2
                state = "code"
                continue
            out.append("\n" if c == "\n" else " ")
            i += 1
            continue
        if state == "literal":
            if c == "\\":
                out.append(" ")
                if i + 1 < n:
                    out.append("\n" if text[i + 1] == "\n" else " ")
                    i += 2
                else:
                    i += 1
                continue
            if c == quote:
                out.append(" ")
                i += 1
                state = "code"
                continue
            out.append("\n" if c == "\n" else " ")
            i += 1
    return "".join(out)


def line_of(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1


def find_matching(masked: str, open_index: int) -> int | None:
    depth = 0
    for i in range(open_index, len(masked)):
        if masked[i] == "(":
            depth += 1
        elif masked[i] == ")":
            depth -= 1
            if depth == 0:
                return i
    return None


def split_argument_ranges(masked_args: str) -> list[tuple[int, int]]:
    ranges: list[tuple[int, int]] = []
    depth = 0
    start = 0
    for i, c in enumerate(masked_args):
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
        elif c == "," and depth == 0:
            ranges.append((start, i))
            start = i + 1
    ranges.append((start, len(masked_args)))
    return ranges


def normalize_whitespace(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def extract_call_inventory(original: str, function_names: Iterable[str], call_kind: str) -> list[dict[str, Any]]:
    masked = strip_comments_and_literals(original)
    results: list[dict[str, Any]] = []
    for name in function_names:
        for match in re.finditer(rf"\b{re.escape(name)}\s*\(", masked):
            open_idx = masked.find("(", match.start())
            close_idx = find_matching(masked, open_idx)
            if close_idx is None:
                continue
            masked_args = masked[open_idx + 1:close_idx]
            original_args = original[open_idx + 1:close_idx]
            arg_ranges = split_argument_ranges(masked_args)
            args = [original_args[a:b].strip() for a, b in arg_ranges]
            item: dict[str, Any] = {
                "kind": call_kind,
                "function": name,
                "line": line_of(original, match.start()),
                "raw_call": normalize_whitespace(original[match.start():close_idx + 1]),
                "argument_count": len(args),
                "condition_raw": args[0] if args else "",
                "condition_normalized": normalize_whitespace(args[0]) if args else "",
            }
            if call_kind == "ASSERTION" and len(args) >= 2:
                item["message_raw"] = normalize_whitespace(args[1])
            results.append(item)
    return sorted(results, key=lambda x: (x["line"], x["function"], x["raw_call"]))


def json_pointer_get(doc: Any, pointer: str) -> tuple[bool, Any]:
    if pointer == "":
        return True, doc
    current = doc
    for raw_token in pointer.split("/")[1:]:
        token = raw_token.replace("~1", "/").replace("~0", "~")
        if isinstance(current, dict):
            if token not in current:
                return False, None
            current = current[token]
        elif isinstance(current, list):
            if not re.fullmatch(r"0|[1-9][0-9]*", token):
                return False, None
            idx = int(token)
            if idx >= len(current):
                return False, None
            current = current[idx]
        else:
            return False, None
    return True, current


def make_input_manifest(request: dict[str, Any], run_root: Path) -> list[dict[str, Any]]:
    entries: list[dict[str, Any]] = []
    for artifact in request["artifacts"]:
        rel = artifact["path"]
        path = resolve_input(run_root, rel, "artifact path")
        exists = path.exists()
        is_regular = exists and path.is_file()
        actual_sha = sha256_file(path) if is_regular else None
        size = path.stat().st_size if is_regular else None
        expected = artifact["expected_sha256"]
        entries.append({
            "path": rel,
            "role": artifact["role"],
            "required": artifact["required"],
            "expected_sha256": expected,
            "actual_sha256": actual_sha,
            "hash_match": None if expected is None or actual_sha is None else expected == actual_sha,
            "exists": exists,
            "is_regular_file": is_regular,
            "size_bytes": size,
            "media_type": artifact["media_type"],
            "skill_name": artifact["skill_name"],
            "iteration": artifact["iteration"],
            "description": artifact["description"],
        })
    return entries


def scan_unlisted(request: dict[str, Any], run_root: Path, listed: set[str]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    policy = request["scan_policy"]
    if not policy["report_unlisted_files"]:
        return [], []
    records: list[dict[str, Any]] = []
    warnings: list[dict[str, Any]] = []
    count = 0
    total = 0
    truncated = False
    for root, dirs, files in os.walk(run_root, followlinks=False):
        root_path = Path(root)
        safe_dirs: list[str] = []
        for d in sorted(dirs):
            p = root_path / d
            if p.is_symlink():
                warnings.append({"code": "UNLISTED_SYMLINK_SKIPPED", "path": p.relative_to(run_root).as_posix()})
            else:
                safe_dirs.append(d)
        dirs[:] = safe_dirs
        for name in sorted(files):
            p = root_path / name
            rel = p.relative_to(run_root).as_posix()
            if rel in listed:
                continue
            if p.is_symlink():
                warnings.append({"code": "UNLISTED_SYMLINK_SKIPPED", "path": rel})
                continue
            if not p.is_file():
                continue
            size = p.stat().st_size
            if count + 1 > policy["max_files"] or total + size > policy["max_total_bytes"]:
                truncated = True
                break
            records.append({"path": rel, "size_bytes": size, "sha256": sha256_file(p)})
            count += 1
            total += size
        if truncated:
            break
    if records:
        warnings.append({"code": "UNLISTED_FILES_PRESENT", "count": len(records)})
    if truncated:
        warnings.append({
            "code": "UNLISTED_SCAN_TRUNCATED",
            "max_files": policy["max_files"],
            "max_total_bytes": policy["max_total_bytes"],
        })
    return records, warnings


def compare_manifests(before: list[dict[str, Any]], after: list[dict[str, Any]]) -> dict[str, Any]:
    b = {x["path"]: x for x in before}
    a = {x["path"]: x for x in after}
    changes: list[dict[str, Any]] = []
    for path in sorted(set(b) | set(a)):
        old, new = b.get(path), a.get(path)
        if old != new:
            changes.append({"path": path, "before": old, "after": new})
    return {"unchanged": not changes, "changed_count": len(changes), "changes": changes}


def severity_for_artifact(entry: dict[str, Any]) -> tuple[str | None, str | None]:
    if not entry["exists"] or not entry["is_regular_file"]:
        return ("INCOMPLETE" if entry["required"] else "WARNING", "MISSING_REQUIRED_ARTIFACT" if entry["required"] else "MISSING_OPTIONAL_ARTIFACT")
    if entry["expected_sha256"] is not None and entry["hash_match"] is False:
        return ("INCOMPLETE" if entry["required"] else "WARNING", "REQUIRED_HASH_MISMATCH" if entry["required"] else "OPTIONAL_HASH_MISMATCH")
    return None, None


def build_markdown(manifest: dict[str, Any]) -> str:
    lines = [
        "# Verification Evidence Manifest",
        "",
        f"- Run ID: `{manifest['run_id']}`",
        f"- Target: `{manifest['target']['symbol']}`",
        f"- Manifest status: `{manifest['manifest_status']}`",
        f"- Semantic authority: `{manifest['semantic_authority']}`",
        f"- Gate authority: `{manifest['gate_authority']}`",
        "",
        "> This status describes evidence-manifest completeness only. It does not establish theorem validity, implementation correctness, novelty, or scientific acceptance.",
        "",
        "## Source revision",
        "",
        f"- Kind: `{manifest['source_revision']['kind']}`",
        f"- Value: `{manifest['source_revision']['value']}`",
        f"- Evidence path: `{manifest['source_revision']['evidence_path']}`",
        "",
        "## Property records supplied by Codex",
        "",
    ]
    if manifest["property_records"]:
        for p in manifest["property_records"]:
            lines.extend([
                f"### `{p['property_id']}`",
                "",
                p["statement"],
                "",
                f"- Codex-supplied status: `{p['status_supplied_by_codex']}`",
                f"- Provenance: `{p['provenance']}`",
                "",
            ])
    else:
        lines.extend(["No property records were supplied.", ""])
    lines.extend(["## Final status supplied by Codex", ""])
    lines.extend([
        f"- Value: `{manifest['final_status_supplied_by_codex']['value']}`",
        f"- Notes: `{manifest['final_status_supplied_by_codex']['notes']}`",
        f"- Authority: `{manifest['final_status_supplied_by_codex']['authority']}`",
        "",
        "## Evidence summary",
        "",
        f"- Declared artefacts: {manifest['counts']['declared_artifacts']}",
        f"- Present artefacts: {manifest['counts']['present_artifacts']}",
        f"- Required-role gaps: {manifest['counts']['missing_required_roles']}",
        f"- Assumptions inventoried: {manifest['counts']['assumptions']}",
        f"- Assertions inventoried: {manifest['counts']['assertions']}",
        f"- JSON fields requested: {manifest['counts']['json_fields_requested']}",
        f"- JSON fields found: {manifest['counts']['json_fields_found']}",
        f"- Skill-labelled artefacts: {manifest['counts']['skill_labelled_artifacts']}",
        f"- Iterations represented: {manifest['counts']['iterations']}",
        "",
        "## Evidence by role",
        "",
        "| Role | Declared | Present | Hash-consistent |",
        "|---|---:|---:|---:|",
    ])
    for row in manifest["evidence_by_role"]:
        lines.append(f"| `{row['role']}` | {row['declared']} | {row['present']} | {row['hash_consistent']} |")
    lines.extend(["", "## Warnings and gaps", ""])
    if manifest["warnings"]:
        for w in manifest["warnings"]:
            details = ", ".join(f"{k}={v}" for k, v in w.items() if k != "code")
            lines.append(f"- `{w['code']}`" + (f": {details}" if details else ""))
    else:
        lines.append("No warnings were recorded.")
    lines.extend([
        "",
        "## Raw evidence",
        "",
        "See `input_file_manifest.before.json`, the caller-declared artefact paths, and the supporting inventory files. Raw evidence remains authoritative over this index.",
        "",
        "## Mandatory limitations",
        "",
        "- The skill does not execute or reinterpret CBMC.",
        "- Harness claims are lexical call inventories, not semantic justification.",
        "- Skill use and repair iteration are caller-declared labels, not inferred agent behavior.",
        "- A complete manifest is not a valid proof, correct implementation, useful theorem, novel result, or accepted experiment.",
        "",
    ])
    return "\n".join(lines)


def build_manifest(request_path: Path, run_root: Path, output_dir: Path) -> int:
    run_root = run_root.resolve(strict=True)
    if not run_root.is_dir():
        raise ContractError("run root must be a directory")
    ensure_output_location(run_root, output_dir)
    try:
        raw = json.loads(request_path.read_text(encoding="utf-8"))
    except Exception as e:
        raise ContractError(f"could not parse request JSON: {e}") from e
    request = validate_request(raw)

    before = make_input_manifest(request, run_root)
    output_dir.mkdir(parents=True, exist_ok=False)
    write_json(output_dir / "canonical_request.json", request)
    write_json(output_dir / "input_file_manifest.before.json", before)

    warnings: list[dict[str, Any]] = []
    incomplete = False
    for entry in before:
        severity, code = severity_for_artifact(entry)
        if code:
            warnings.append({"code": code, "path": entry["path"], "role": entry["role"]})
            if severity == "INCOMPLETE":
                incomplete = True

    listed_paths = {a["path"] for a in request["artifacts"]}
    unlisted, scan_warnings = scan_unlisted(request, run_root, listed_paths)
    warnings.extend(scan_warnings)

    present_good = {
        e["path"] for e in before
        if e["exists"] and e["is_regular_file"] and (e["expected_sha256"] is None or e["hash_match"] is True)
    }
    roles_present_good = {
        e["role"] for e in before
        if e["path"] in present_good
    }
    missing_roles = sorted(set(request["required_roles"]) - roles_present_good)
    for role in missing_roles:
        warnings.append({"code": "MISSING_REQUIRED_ROLE", "role": role})
        incomplete = True

    artifact_by_path = {a["path"]: a for a in request["artifacts"]}
    before_by_path = {e["path"]: e for e in before}

    property_inventory: list[dict[str, Any]] = []
    for p in request["property_records"]:
        record = dict(p)
        record["authority"] = "CODEX_SUPPLIED_UNVERIFIED"
        prov = p["provenance"]
        if prov is not None:
            entry = before_by_path.get(prov["path"])
            if not entry or not entry["exists"]:
                warnings.append({"code": "PROPERTY_PROVENANCE_MISSING", "property_id": p["property_id"], "path": prov["path"]})
            elif entry["size_bytes"] is not None and entry["size_bytes"] <= request["scan_policy"]["max_text_parse_bytes"]:
                try:
                    line_count = (run_root / prov["path"]).read_text(encoding="utf-8").count("\n") + 1
                    if prov["line_end"] > line_count:
                        warnings.append({"code": "PROPERTY_PROVENANCE_LINE_OUT_OF_RANGE", "property_id": p["property_id"], "path": prov["path"], "line_count": line_count})
                except UnicodeDecodeError:
                    warnings.append({"code": "PROPERTY_PROVENANCE_NOT_UTF8", "property_id": p["property_id"], "path": prov["path"]})
            else:
                warnings.append({"code": "PROPERTY_PROVENANCE_NOT_RANGE_CHECKED", "property_id": p["property_id"], "path": prov["path"]})
        property_inventory.append(record)
    property_obj = {
        "schema_version": SCHEMA_VERSION,
        "semantic_authority": SEMANTIC_AUTHORITY,
        "records": property_inventory,
        "limitations": [
            "Statements and statuses are preserved exactly as supplied by Codex.",
            "The skill does not determine property meaning, validity, usefulness, or novelty.",
        ],
    }
    write_json(output_dir / "property_inventory.json", property_obj)

    harness_records: list[dict[str, Any]] = []
    if request["harness_parsing"]["enabled"]:
        roles = set(request["harness_parsing"]["roles"])
        for artifact in request["artifacts"]:
            if artifact["role"] not in roles:
                continue
            entry = before_by_path[artifact["path"]]
            if artifact["path"] not in present_good:
                continue
            if entry["size_bytes"] is not None and entry["size_bytes"] > request["scan_policy"]["max_text_parse_bytes"]:
                warnings.append({"code": "HARNESS_PARSE_SKIPPED_SIZE", "path": artifact["path"], "size_bytes": entry["size_bytes"]})
                continue
            try:
                text = (run_root / artifact["path"]).read_text(encoding="utf-8")
            except UnicodeDecodeError:
                warnings.append({"code": "HARNESS_PARSE_NOT_UTF8", "path": artifact["path"]})
                continue
            assumes = extract_call_inventory(text, request["harness_parsing"]["assume_functions"], "ASSUMPTION")
            asserts = extract_call_inventory(text, request["harness_parsing"]["assert_functions"], "ASSERTION")
            harness_records.append({
                "path": artifact["path"],
                "sha256": entry["actual_sha256"],
                "assumptions": assumes,
                "assertions": asserts,
            })
    harness_obj = {
        "schema_version": SCHEMA_VERSION,
        "semantic_authority": SEMANTIC_AUTHORITY,
        "analysis_nature": "LEXICAL_CALL_INVENTORY_ONLY",
        "files": harness_records,
        "limitations": [
            "The inventory does not determine whether assumptions are justified.",
            "The inventory does not determine whether assertions are meaningful, non-trivial, sufficient, or correct.",
            "Macros, wrappers, generated code, or non-call syntax may not be represented.",
        ],
    }
    write_json(output_dir / "harness_claim_inventory.json", harness_obj)

    extracted: list[dict[str, Any]] = []
    for artifact in request["artifacts"]:
        fields = artifact["extract_json_fields"]
        if not fields:
            continue
        entry = before_by_path[artifact["path"]]
        if artifact["path"] not in present_good:
            for f in fields:
                extracted.append({"artifact_path": artifact["path"], "label": f["label"], "json_pointer": f["json_pointer"], "found": False, "value": None, "reason": "ARTIFACT_UNAVAILABLE_OR_HASH_MISMATCH"})
            continue
        if entry["size_bytes"] is not None and entry["size_bytes"] > request["scan_policy"]["max_text_parse_bytes"]:
            for f in fields:
                extracted.append({"artifact_path": artifact["path"], "label": f["label"], "json_pointer": f["json_pointer"], "found": False, "value": None, "reason": "JSON_PARSE_SKIPPED_SIZE"})
            warnings.append({"code": "JSON_PARSE_SKIPPED_SIZE", "path": artifact["path"]})
            continue
        try:
            doc = json.loads((run_root / artifact["path"]).read_text(encoding="utf-8"))
        except Exception as e:
            for f in fields:
                extracted.append({"artifact_path": artifact["path"], "label": f["label"], "json_pointer": f["json_pointer"], "found": False, "value": None, "reason": "JSON_PARSE_FAILED"})
            warnings.append({"code": "JSON_PARSE_FAILED", "path": artifact["path"], "detail": type(e).__name__})
            continue
        for f in fields:
            found, value = json_pointer_get(doc, f["json_pointer"])
            extracted.append({
                "artifact_path": artifact["path"],
                "label": f["label"],
                "json_pointer": f["json_pointer"],
                "found": found,
                "value": value if found else None,
                "reason": None if found else "JSON_POINTER_NOT_FOUND",
            })
            if not found:
                warnings.append({"code": "JSON_POINTER_NOT_FOUND", "path": artifact["path"], "label": f["label"], "json_pointer": f["json_pointer"]})
    extracted_obj = {
        "schema_version": SCHEMA_VERSION,
        "semantic_authority": SEMANTIC_AUTHORITY,
        "fields": extracted,
        "limitations": ["Values are copied from caller-selected JSON Pointers without interpretation."],
    }
    write_json(output_dir / "extracted_field_index.json", extracted_obj)

    skills: dict[str, list[dict[str, Any]]] = {}
    iterations: dict[str, list[dict[str, Any]]] = {}
    for entry in before:
        compact = {
            "path": entry["path"],
            "role": entry["role"],
            "required": entry["required"],
            "exists": entry["exists"],
            "actual_sha256": entry["actual_sha256"],
            "hash_match": entry["hash_match"],
        }
        if entry["skill_name"] is not None:
            skills.setdefault(entry["skill_name"], []).append(compact | {"iteration": entry["iteration"]})
        iterations.setdefault(str(entry["iteration"]), []).append(compact | {"skill_name": entry["skill_name"]})
    skill_obj = {
        "schema_version": SCHEMA_VERSION,
        "semantic_authority": SEMANTIC_AUTHORITY,
        "records_are": "CALLER_DECLARED_ARTIFACT_LABELS_NOT_INFERRED_INVOCATIONS",
        "skills": {k: sorted(v, key=lambda x: x["path"]) for k, v in sorted(skills.items())},
    }
    iteration_obj = {
        "schema_version": SCHEMA_VERSION,
        "semantic_authority": SEMANTIC_AUTHORITY,
        "records_are": "CALLER_DECLARED_ITERATION_LABELS_NOT_INFERRED_REPAIRS",
        "iterations": {k: sorted(v, key=lambda x: x["path"]) for k, v in sorted(iterations.items(), key=lambda kv: int(kv[0]))},
    }
    write_json(output_dir / "skill_use_records.json", skill_obj)
    write_json(output_dir / "iteration_index.json", iteration_obj)

    after = make_input_manifest(request, run_root)
    comparison = compare_manifests(before, after)
    if not comparison["unchanged"]:
        warnings.append({"code": "INPUT_MUTATION_DETECTED", "changed_count": comparison["changed_count"]})
        incomplete = True
    write_json(output_dir / "input_file_manifest.after.json", after)
    write_json(output_dir / "input_integrity_comparison.json", comparison)

    by_role: list[dict[str, Any]] = []
    for role in sorted({e["role"] for e in before} | set(request["required_roles"])):
        entries = [e for e in before if e["role"] == role]
        by_role.append({
            "role": role,
            "declared": len(entries),
            "present": sum(1 for e in entries if e["exists"] and e["is_regular_file"]),
            "hash_consistent": sum(1 for e in entries if e["exists"] and e["is_regular_file"] and (e["expected_sha256"] is None or e["hash_match"] is True)),
            "required_role": role in request["required_roles"],
        })

    if incomplete:
        status = "INCOMPLETE"
    elif warnings:
        status = "COMPLETE_WITH_WARNINGS"
    else:
        status = "COMPLETE"

    warning_obj = {
        "schema_version": SCHEMA_VERSION,
        "manifest_status": status,
        "warnings": warnings,
        "unlisted_files": unlisted,
        "missing_required_roles": missing_roles,
        "limitations": ["Warnings are mechanical evidence and do not accept or reject the run."],
    }
    write_json(output_dir / "missing_evidence_warnings.json", warning_obj)

    assumption_count = sum(len(f["assumptions"]) for f in harness_records)
    assertion_count = sum(len(f["assertions"]) for f in harness_records)
    manifest = {
        "schema_version": SCHEMA_VERSION,
        "skill": "verification-evidence-manifest",
        "skill_version": VERSION,
        "run_id": request["run_id"],
        "generated_at_utc": request["generated_at_utc"],
        "manifest_status": status,
        "semantic_authority": SEMANTIC_AUTHORITY,
        "gate_authority": GATE_AUTHORITY,
        "target": request["target"],
        "source_revision": request["source_revision"],
        "property_records": property_inventory,
        "final_status_supplied_by_codex": {
            "value": request["final_status_supplied_by_codex"]["value"],
            "notes": request["final_status_supplied_by_codex"]["notes"],
            "authority": "CODEX_SUPPLIED_UNVERIFIED",
        },
        "counts": {
            "declared_artifacts": len(before),
            "present_artifacts": sum(1 for e in before if e["exists"] and e["is_regular_file"]),
            "missing_required_roles": len(missing_roles),
            "assumptions": assumption_count,
            "assertions": assertion_count,
            "json_fields_requested": len(extracted),
            "json_fields_found": sum(1 for x in extracted if x["found"]),
            "skill_labelled_artifacts": sum(1 for e in before if e["skill_name"] is not None),
            "iterations": len(iterations),
            "warnings": len(warnings),
            "unlisted_files": len(unlisted),
        },
        "evidence_by_role": by_role,
        "supporting_files": {
            "input_manifest_before": "input_file_manifest.before.json",
            "input_manifest_after": "input_file_manifest.after.json",
            "input_integrity": "input_integrity_comparison.json",
            "harness_claim_inventory": "harness_claim_inventory.json",
            "property_inventory": "property_inventory.json",
            "extracted_fields": "extracted_field_index.json",
            "skill_use_records": "skill_use_records.json",
            "iteration_index": "iteration_index.json",
            "warnings": "missing_evidence_warnings.json",
        },
        "warnings": warnings,
        "mandatory_limitations": [
            "Manifest completeness is not theorem validity or scientific acceptance.",
            "CBMC and other tool statuses are preserved or extracted but never reinterpreted.",
            "Harness assumption/assertion records are lexical inventories only.",
            "Skill names and iterations are caller-declared labels, not inferred agent behavior.",
            "Raw artefacts remain authoritative over this manifest.",
        ],
    }
    write_json(output_dir / "manifest.json", manifest)
    (output_dir / "manifest.md").write_text(build_markdown(manifest), encoding="utf-8")

    generated_files = sorted(p for p in output_dir.rglob("*") if p.is_file() and p.name != "generated_artifact_manifest.json")
    generated_manifest = {
        "schema_version": SCHEMA_VERSION,
        "skill": "verification-evidence-manifest",
        "files": [
            {"path": p.relative_to(output_dir).as_posix(), "sha256": sha256_file(p), "size_bytes": p.stat().st_size}
            for p in generated_files
        ],
    }
    write_json(output_dir / "generated_artifact_manifest.json", generated_manifest)
    return 2 if status == "INCOMPLETE" else 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--request", required=True, type=Path)
    parser.add_argument("--run-root", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args(argv)
    try:
        return build_manifest(args.request, args.run_root, args.output_dir)
    except ContractError as e:
        print(f"CONTRACT_ERROR: {e}", file=sys.stderr)
        return 3
    except Exception as e:
        print(f"PROCESSING_ERROR: {type(e).__name__}: {e}", file=sys.stderr)
        return 4


if __name__ == "__main__":
    raise SystemExit(main())
