#!/usr/bin/env python3
"""Deterministic structural audit for C/CBMC harnesses.

This tool reports syntactic and structural findings only. It does not judge
semantic validity, theorem usefulness, implementation correctness, or proof
acceptance.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

VERSION = "1.0.0-rc1"
ALLOWED_TOP = {
    "schema_version", "request_id", "target", "harness", "production_files",
    "allowed_build_inputs", "actual_build_inputs", "diagnostics", "checks"
}
ALLOWED_TARGET = {"symbol", "authoritative_definition_path", "minimum_call_count"}
ALLOWED_FILE = {"path", "expected_sha256", "role"}
ALLOWED_DIAGNOSTICS = {"undefined_functions"}
ALLOWED_DIAG_FILE = {"path", "expected_sha256", "format"}
ALLOWED_CHECKS = {
    "require_target_call", "require_user_assertion", "scan_assumptions",
    "scan_assertions", "detect_obvious_false_assumptions",
    "detect_constant_false_controls", "detect_duplicate_assertions",
    "detect_trivial_assertions", "detect_assumed_assertions",
    "detect_replacement_definitions", "compare_build_inputs",
    "inspect_undefined_functions"
}
STATUSES = {"CHECKED", "WARNING", "NOT_CHECKABLE"}


class ContractError(Exception):
    pass


def canonical_json(obj: Any) -> str:
    return json.dumps(obj, sort_keys=True, indent=2, ensure_ascii=False) + "\n"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def require_exact_keys(obj: dict[str, Any], allowed: set[str], where: str) -> None:
    extra = set(obj) - allowed
    if extra:
        raise ContractError(f"Unknown field(s) in {where}: {', '.join(sorted(extra))}")


def validate_rel_path(raw: str, where: str) -> str:
    if not isinstance(raw, str) or not raw.strip():
        raise ContractError(f"{where} must be a non-empty string")
    p = Path(raw)
    if p.is_absolute() or ".." in p.parts:
        raise ContractError(f"{where} must be repository-relative without '..'")
    normalized = p.as_posix()
    if normalized in {".", ""}:
        raise ContractError(f"{where} must name a file")
    return normalized


def resolve_regular(root: Path, rel: str, where: str) -> Path:
    p = root / rel
    if p.is_symlink():
        raise ContractError(f"{where} must not be a symlink: {rel}")
    try:
        resolved = p.resolve(strict=True)
    except FileNotFoundError as e:
        raise ContractError(f"Missing file for {where}: {rel}") from e
    root_resolved = root.resolve(strict=True)
    if root_resolved not in resolved.parents and resolved != root_resolved:
        raise ContractError(f"{where} escapes the audit root: {rel}")
    if not resolved.is_file():
        raise ContractError(f"{where} is not a regular file: {rel}")
    return resolved


def ensure_output_location(root: Path, output: Path) -> None:
    root_r = root.resolve(strict=True)
    out_parent = output.parent.resolve(strict=True)
    if output.exists():
        raise ContractError(f"Output directory already exists: {output}")
    if root_r == out_parent or root_r in out_parent.parents:
        raise ContractError("Output directory must be outside the audit root")


def validate_sha(raw: Any, where: str) -> str:
    if not isinstance(raw, str) or not re.fullmatch(r"[0-9a-f]{64}", raw):
        raise ContractError(f"{where} must be a lowercase SHA-256 hex string")
    return raw


def validate_request(obj: Any) -> dict[str, Any]:
    if not isinstance(obj, dict):
        raise ContractError("Request must be a JSON object")
    require_exact_keys(obj, ALLOWED_TOP, "request")
    required = {"schema_version", "request_id", "target", "harness", "production_files", "allowed_build_inputs", "actual_build_inputs", "checks"}
    missing = required - set(obj)
    if missing:
        raise ContractError(f"Missing request field(s): {', '.join(sorted(missing))}")
    if obj["schema_version"] != "1.0":
        raise ContractError("schema_version must be '1.0'")
    if not isinstance(obj["request_id"], str) or not obj["request_id"].strip():
        raise ContractError("request_id must be a non-empty string")

    target = obj["target"]
    if not isinstance(target, dict):
        raise ContractError("target must be an object")
    require_exact_keys(target, ALLOWED_TARGET, "target")
    if set(target) != ALLOWED_TARGET:
        raise ContractError("target requires symbol, authoritative_definition_path, and minimum_call_count")
    if not isinstance(target["symbol"], str) or not re.fullmatch(r"[A-Za-z_]\w*", target["symbol"]):
        raise ContractError("target.symbol must be a C identifier")
    target["authoritative_definition_path"] = validate_rel_path(target["authoritative_definition_path"], "target.authoritative_definition_path")
    if not isinstance(target["minimum_call_count"], int) or target["minimum_call_count"] < 1 or target["minimum_call_count"] > 100:
        raise ContractError("target.minimum_call_count must be an integer from 1 to 100")

    def validate_file_record(rec: Any, where: str) -> dict[str, Any]:
        if not isinstance(rec, dict):
            raise ContractError(f"{where} must be an object")
        require_exact_keys(rec, ALLOWED_FILE, where)
        if set(rec) != ALLOWED_FILE:
            raise ContractError(f"{where} requires path, expected_sha256, and role")
        rec["path"] = validate_rel_path(rec["path"], f"{where}.path")
        rec["expected_sha256"] = validate_sha(rec["expected_sha256"], f"{where}.expected_sha256")
        if not isinstance(rec["role"], str) or not rec["role"].strip():
            raise ContractError(f"{where}.role must be a non-empty string")
        return rec

    obj["harness"] = validate_file_record(obj["harness"], "harness")
    for key in ("production_files", "actual_build_inputs"):
        if not isinstance(obj[key], list) or not obj[key]:
            raise ContractError(f"{key} must be a non-empty array")
        obj[key] = [validate_file_record(x, f"{key}[{i}]") for i, x in enumerate(obj[key])]
    if not isinstance(obj["allowed_build_inputs"], list) or not obj["allowed_build_inputs"]:
        raise ContractError("allowed_build_inputs must be a non-empty array")
    obj["allowed_build_inputs"] = [validate_rel_path(x, f"allowed_build_inputs[{i}]") for i, x in enumerate(obj["allowed_build_inputs"])]

    all_paths = [obj["harness"]["path"]] + [x["path"] for x in obj["production_files"]] + [x["path"] for x in obj["actual_build_inputs"]]
    if len(all_paths) != len(set(all_paths)) + (len([x["path"] for x in obj["actual_build_inputs"] if x["path"] in {obj["harness"]["path"], *[p["path"] for p in obj["production_files"]]}])):
        # The same file may legitimately appear once in identity records and once in actual_build_inputs.
        pass
    if len({x["path"] for x in obj["production_files"]}) != len(obj["production_files"]):
        raise ContractError("production_files contains duplicate paths")
    if len({x["path"] for x in obj["actual_build_inputs"]}) != len(obj["actual_build_inputs"]):
        raise ContractError("actual_build_inputs contains duplicate paths")
    if len(set(obj["allowed_build_inputs"])) != len(obj["allowed_build_inputs"]):
        raise ContractError("allowed_build_inputs contains duplicate paths")

    diagnostics = obj.get("diagnostics", {})
    if diagnostics is None:
        diagnostics = {}
    if not isinstance(diagnostics, dict):
        raise ContractError("diagnostics must be an object")
    require_exact_keys(diagnostics, ALLOWED_DIAGNOSTICS, "diagnostics")
    if "undefined_functions" in diagnostics:
        rec = diagnostics["undefined_functions"]
        if not isinstance(rec, dict):
            raise ContractError("diagnostics.undefined_functions must be an object")
        require_exact_keys(rec, ALLOWED_DIAG_FILE, "diagnostics.undefined_functions")
        if set(rec) != ALLOWED_DIAG_FILE:
            raise ContractError("diagnostics.undefined_functions requires path, expected_sha256, and format")
        rec["path"] = validate_rel_path(rec["path"], "diagnostics.undefined_functions.path")
        rec["expected_sha256"] = validate_sha(rec["expected_sha256"], "diagnostics.undefined_functions.expected_sha256")
        if rec["format"] != "goto-instrument-list-undefined-functions-text":
            raise ContractError("Unsupported undefined-functions diagnostic format")
    obj["diagnostics"] = diagnostics

    checks = obj["checks"]
    if not isinstance(checks, dict):
        raise ContractError("checks must be an object")
    require_exact_keys(checks, ALLOWED_CHECKS, "checks")
    if set(checks) != ALLOWED_CHECKS:
        missing = ALLOWED_CHECKS - set(checks)
        raise ContractError(f"checks missing field(s): {', '.join(sorted(missing))}")
    for key, value in checks.items():
        if not isinstance(value, bool):
            raise ContractError(f"checks.{key} must be boolean")
    return obj


def strip_c_comments_and_literals(text: str) -> str:
    """Replace comments/string/char contents with spaces while preserving newlines."""
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
                out.extend("  "); i += 2; state = "line_comment"; continue
            if c == "/" and nxt == "*":
                out.extend("  "); i += 2; state = "block_comment"; continue
            if c in {'"', "'"}:
                quote = c; out.append(" "); i += 1; state = "literal"; continue
            out.append(c); i += 1; continue
        if state == "line_comment":
            if c == "\n": out.append("\n"); state = "code"
            else: out.append(" ")
            i += 1; continue
        if state == "block_comment":
            if c == "*" and nxt == "/":
                out.extend("  "); i += 2; state = "code"; continue
            out.append("\n" if c == "\n" else " "); i += 1; continue
        if state == "literal":
            if c == "\\":
                out.append(" ")
                if i + 1 < n:
                    out.append("\n" if text[i + 1] == "\n" else " ")
                    i += 2
                else: i += 1
                continue
            if c == quote:
                out.append(" "); i += 1; state = "code"; continue
            out.append("\n" if c == "\n" else " "); i += 1
    return "".join(out)


def line_of(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1


def find_matching(text: str, open_index: int, open_char: str = "(", close_char: str = ")") -> int | None:
    depth = 0
    for i in range(open_index, len(text)):
        if text[i] == open_char: depth += 1
        elif text[i] == close_char:
            depth -= 1
            if depth == 0: return i
    return None


def split_first_argument(arg_text: str) -> str:
    depth = 0
    for i, c in enumerate(arg_text):
        if c in "([{": depth += 1
        elif c in ")]}": depth -= 1
        elif c == "," and depth == 0:
            return arg_text[:i].strip()
    return arg_text.strip()


def extract_calls(text: str, names: Iterable[str]) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    for name in names:
        for m in re.finditer(rf"\b{re.escape(name)}\s*\(", text):
            open_idx = text.find("(", m.start())
            close_idx = find_matching(text, open_idx)
            if close_idx is None: continue
            args = text[open_idx + 1:close_idx]
            results.append({
                "name": name, "start": m.start(), "end": close_idx + 1,
                "line": line_of(text, m.start()), "arguments": args,
                "condition": split_first_argument(args)
            })
    return sorted(results, key=lambda x: x["start"])


def normalize_expr(expr: str) -> str:
    x = re.sub(r"\s+", "", expr)
    changed = True
    while changed and len(x) >= 2 and x[0] == "(" and x[-1] == ")":
        end = find_matching(x, 0)
        if end == len(x) - 1: x = x[1:-1]; changed = True
        else: changed = False
    return x


def strip_int_suffix(token: str) -> str:
    return re.sub(r"(?i)(u|l)+$", "", token)


def parse_int_literal(token: str) -> int | None:
    t = strip_int_suffix(token.strip())
    try:
        return int(t, 0)
    except Exception:
        return None


def obvious_truth(expr: str) -> str:
    """Return TRUE, FALSE, or UNKNOWN using intentionally tiny syntactic rules."""
    x = normalize_expr(expr)
    lower = x.lower()
    if lower in {"true", "1", "1u", "1ul", "1lu"}: return "TRUE"
    if lower in {"false", "0", "0u", "0ul", "0lu", "null"}: return "FALSE"
    m = re.fullmatch(r"(.+?)(==|!=|<=|>=|<|>)(.+)", x)
    if m:
        left, op, right = m.groups()
        li, ri = parse_int_literal(left), parse_int_literal(right)
        if li is not None and ri is not None:
            result = {"==": li == ri, "!=": li != ri, "<=": li <= ri, ">=": li >= ri, "<": li < ri, ">": li > ri}[op]
            return "TRUE" if result else "FALSE"
        if left == right:
            if op in {"==", "<=", ">="}: return "TRUE"
            if op in {"!=", "<", ">"}: return "FALSE"
    return "UNKNOWN"


def function_definitions(text: str, symbol: str) -> list[dict[str, Any]]:
    pattern = re.compile(
        rf"(?m)(?:^|[;}}])\s*(?:[A-Za-z_]\w*(?:\s+|\s*\*+\s*))+{re.escape(symbol)}\s*\([^;{{}}]*\)\s*\{{"
    )
    return [{"line": line_of(text, m.start()), "snippet": re.sub(r"\s+", " ", m.group(0)).strip()} for m in pattern.finditer(text)]


def function_declaration_spans(text: str, symbol: str) -> list[tuple[int, int]]:
    pattern = re.compile(
        rf"(?m)(?:^|[;}}])\s*(?:[A-Za-z_]\w*(?:\s+|\s*\*+\s*))+{re.escape(symbol)}\s*\([^;{{}}]*\)\s*;"
    )
    return [m.span() for m in pattern.finditer(text)]


def target_call_locations(text: str, symbol: str) -> list[int]:
    def_spans = []
    pattern_def = re.compile(
        rf"(?m)(?:^|[;}}])\s*(?:[A-Za-z_]\w*(?:\s+|\s*\*+\s*))+{re.escape(symbol)}\s*\([^;{{}}]*\)\s*\{{"
    )
    def_spans.extend(m.span() for m in pattern_def.finditer(text))
    decl_spans = function_declaration_spans(text, symbol)
    positions = []
    for m in re.finditer(rf"\b{re.escape(symbol)}\s*\(", text):
        if any(a <= m.start() < b for a, b in def_spans + decl_spans):
            continue
        positions.append(line_of(text, m.start()))
    return positions


def parse_undefined_functions(text: str) -> list[str]:
    names: list[str] = []
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith("#") or s.lower().startswith("function") or s.lower().startswith("undefined"):
            continue
        m = re.search(r"([A-Za-z_$][A-Za-z0-9_$:.@]*)", s)
        if m: names.append(m.group(1))
    return sorted(set(names))


def finding(check_id: str, status: str, summary: str, evidence: Any, limitation: str | None = None) -> dict[str, Any]:
    if status not in STATUSES:
        raise AssertionError(status)
    item = {"check_id": check_id, "status": status, "summary": summary, "evidence": evidence}
    if limitation: item["limitation"] = limitation
    return item


def write_json(path: Path, obj: Any) -> None:
    path.write_text(canonical_json(obj), encoding="utf-8")


def audit(request_path: Path, audit_root: Path, output_dir: Path) -> int:
    audit_root = audit_root.resolve(strict=True)
    ensure_output_location(audit_root, output_dir)
    try:
        raw_request = json.loads(request_path.read_text(encoding="utf-8"))
    except Exception as e:
        raise ContractError(f"Could not parse request JSON: {e}") from e
    request = validate_request(raw_request)

    # Resolve and inventory every declared input without treating hash mismatch as a contract failure.
    declared_records: list[tuple[str, dict[str, Any]]] = [("harness", request["harness"])]
    declared_records += [("production", x) for x in request["production_files"]]
    declared_records += [("build", x) for x in request["actual_build_inputs"]]
    resolved_by_path: dict[str, Path] = {}
    manifest_entries: list[dict[str, Any]] = []
    for category, rec in declared_records:
        rel = rec["path"]
        path = resolved_by_path.get(rel) or resolve_regular(audit_root, rel, f"{category} input")
        resolved_by_path[rel] = path
        actual = sha256_file(path)
        manifest_entries.append({
            "category": category, "path": rel, "role": rec["role"],
            "expected_sha256": rec["expected_sha256"], "actual_sha256": actual,
            "hash_match": actual == rec["expected_sha256"], "size_bytes": path.stat().st_size
        })

    diag_manifest = None
    diag_text = None
    if "undefined_functions" in request["diagnostics"]:
        rec = request["diagnostics"]["undefined_functions"]
        p = resolve_regular(audit_root, rec["path"], "undefined-functions diagnostic")
        actual = sha256_file(p)
        diag_manifest = {
            "path": rec["path"], "format": rec["format"], "expected_sha256": rec["expected_sha256"],
            "actual_sha256": actual, "hash_match": actual == rec["expected_sha256"], "size_bytes": p.stat().st_size
        }
        diag_text = p.read_text(encoding="utf-8", errors="replace")

    harness_path = resolved_by_path[request["harness"]["path"]]
    raw_harness = harness_path.read_text(encoding="utf-8", errors="replace")
    clean_harness = strip_c_comments_and_literals(raw_harness)
    target = request["target"]["symbol"]
    checks = request["checks"]
    findings: list[dict[str, Any]] = []

    # Hash integrity.
    prod_entries = [x for x in manifest_entries if x["category"] == "production"]
    mismatched_prod = [x for x in prod_entries if not x["hash_match"]]
    findings.append(finding(
        "PRODUCTION_SOURCE_HASH_BINDING",
        "WARNING" if mismatched_prod else "CHECKED",
        f"{len(mismatched_prod)} production file hash mismatch(es)" if mismatched_prod else "All declared production-file hashes match",
        {"mismatches": mismatched_prod, "checked_count": len(prod_entries)},
        "Hash equality establishes file identity only; it does not establish source correctness."
    ))
    harness_entry = next(x for x in manifest_entries if x["category"] == "harness")
    findings.append(finding(
        "HARNESS_HASH_BINDING", "CHECKED" if harness_entry["hash_match"] else "WARNING",
        "Harness hash matches the declared identity" if harness_entry["hash_match"] else "Harness hash differs from the declared identity",
        harness_entry,
        "A mismatch is recorded rather than interpreted as malicious or erroneous."
    ))

    # Target call and replacement checks.
    call_lines = target_call_locations(clean_harness, target)
    if checks["require_target_call"]:
        status = "CHECKED" if len(call_lines) >= request["target"]["minimum_call_count"] else "WARNING"
        summary = f"Observed {len(call_lines)} lexical target call(s); minimum required is {request['target']['minimum_call_count']}"
    else:
        status, summary = "NOT_CHECKABLE", "Target-call requirement disabled by the caller"
    findings.append(finding(
        "EXPECTED_TARGET_CALL", status, summary,
        {"target_symbol": target, "lexical_call_count": len(call_lines), "line_numbers": call_lines, "minimum_required": request["target"]["minimum_call_count"]},
        "Call recognition is lexical and does not prove reachability or dynamic dispatch behavior."
    ))

    replacement_evidence: list[dict[str, Any]] = []
    macro_pat = re.compile(rf"(?m)^\s*#\s*define\s+{re.escape(target)}(?:\s|\()")
    for m in macro_pat.finditer(raw_harness):
        replacement_evidence.append({"kind": "TARGET_MACRO_DEFINITION_IN_HARNESS", "path": request["harness"]["path"], "line": line_of(raw_harness, m.start())})
    for rec in request["actual_build_inputs"]:
        p = resolved_by_path[rec["path"]]
        if p.suffix.lower() not in {".c", ".h", ".i", ".ii"}: continue
        text = strip_c_comments_and_literals(p.read_text(encoding="utf-8", errors="replace"))
        defs = function_definitions(text, target)
        for d in defs:
            if rec["path"] != request["target"]["authoritative_definition_path"]:
                replacement_evidence.append({"kind": "TARGET_DEFINITION_OUTSIDE_AUTHORITATIVE_FILE", "path": rec["path"], **d})
    findings.append(finding(
        "TARGET_REPLACEMENT_OR_STUB_PATTERN",
        "WARNING" if replacement_evidence else ("CHECKED" if checks["detect_replacement_definitions"] else "NOT_CHECKABLE"),
        f"Observed {len(replacement_evidence)} target replacement/stub pattern(s)" if replacement_evidence else ("No configured replacement/stub pattern observed" if checks["detect_replacement_definitions"] else "Replacement detection disabled"),
        {"patterns": replacement_evidence, "authoritative_definition_path": request["target"]["authoritative_definition_path"]},
        "Absence of these lexical patterns does not prove that all replacement mechanisms are absent."
    ))

    # Assumption/assertion inventory.
    assumes = extract_calls(clean_harness, ["__CPROVER_assume"])
    assertions = extract_calls(clean_harness, ["__CPROVER_assert", "assert"])
    assumption_inventory = []
    for a in assumes:
        assumption_inventory.append({
            "kind": a["name"], "line": a["line"], "condition": a["condition"],
            "normalized_condition": normalize_expr(a["condition"]), "obvious_truth_classification": obvious_truth(a["condition"])
        })
    assertion_inventory = []
    for a in assertions:
        assertion_inventory.append({
            "kind": a["name"], "line": a["line"], "condition": a["condition"],
            "normalized_condition": normalize_expr(a["condition"]), "obvious_truth_classification": obvious_truth(a["condition"])
        })
    findings.append(finding(
        "ASSUMPTION_INVENTORY", "CHECKED" if checks["scan_assumptions"] else "NOT_CHECKABLE",
        f"Recorded {len(assumption_inventory)} lexical assumption call(s)" if checks["scan_assumptions"] else "Assumption scanning disabled",
        {"count": len(assumption_inventory), "items": assumption_inventory},
        "Inventory does not judge whether assumptions are necessary, sufficient, or justified."
    ))
    if checks["require_user_assertion"]:
        astatus = "CHECKED" if assertions else "WARNING"
        asummary = f"Recorded {len(assertions)} lexical user assertion call(s)" if assertions else "No lexical user assertion call was found"
    else:
        astatus, asummary = "NOT_CHECKABLE", "User-assertion requirement disabled by the caller"
    findings.append(finding(
        "USER_ASSERTION_PRESENCE", astatus, asummary,
        {"count": len(assertion_inventory), "items": assertion_inventory},
        "This inventory does not include properties inserted internally by CBMC safety-check options."
    ))

    false_assumes = [x for x in assumption_inventory if x["obvious_truth_classification"] == "FALSE"]
    findings.append(finding(
        "OBVIOUS_FALSE_ASSUMPTION",
        "WARNING" if false_assumes else ("CHECKED" if checks["detect_obvious_false_assumptions"] else "NOT_CHECKABLE"),
        f"Observed {len(false_assumes)} assumption(s) classified FALSE by narrow syntactic rules" if false_assumes else ("No configured obvious-false assumption pattern observed" if checks["detect_obvious_false_assumptions"] else "Obvious-false assumption detection disabled"),
        {"items": false_assumes, "classification_method": "TINY_SYNTACTIC_LITERAL_AND_REFLEXIVE_COMPARISON_RULES"},
        "UNKNOWN expressions are not evaluated, simplified, or sent to a solver."
    ))

    false_controls: list[dict[str, Any]] = []
    if checks["detect_constant_false_controls"]:
        for keyword in ("if", "while"):
            for m in re.finditer(rf"\b{keyword}\s*\(", clean_harness):
                op = clean_harness.find("(", m.start()); cl = find_matching(clean_harness, op)
                if cl is None: continue
                cond = clean_harness[op + 1:cl]
                if obvious_truth(cond) == "FALSE":
                    false_controls.append({"kind": keyword.upper(), "line": line_of(clean_harness, m.start()), "condition": cond.strip()})
        for m in re.finditer(r"\bfor\s*\(", clean_harness):
            op = clean_harness.find("(", m.start()); cl = find_matching(clean_harness, op)
            if cl is None: continue
            body = clean_harness[op + 1:cl]
            parts, start, depth = [], 0, 0
            for i, c in enumerate(body):
                if c in "([{" : depth += 1
                elif c in ")]}": depth -= 1
                elif c == ";" and depth == 0:
                    parts.append(body[start:i]); start = i + 1
            parts.append(body[start:])
            if len(parts) == 3 and obvious_truth(parts[1]) == "FALSE":
                false_controls.append({"kind": "FOR", "line": line_of(clean_harness, m.start()), "condition": parts[1].strip()})
    findings.append(finding(
        "OBVIOUS_CONSTANT_FALSE_CONTROL",
        "WARNING" if false_controls else ("CHECKED" if checks["detect_constant_false_controls"] else "NOT_CHECKABLE"),
        f"Observed {len(false_controls)} constant-false control condition(s)" if false_controls else ("No configured constant-false control pattern observed" if checks["detect_constant_false_controls"] else "Constant-false control detection disabled"),
        {"items": false_controls},
        "The check does not determine which statements are dynamically unreachable."
    ))

    duplicate_groups: list[dict[str, Any]] = []
    if checks["detect_duplicate_assertions"]:
        by_norm: dict[str, list[int]] = {}
        for x in assertion_inventory: by_norm.setdefault(x["normalized_condition"], []).append(x["line"])
        duplicate_groups = [{"normalized_condition": k, "line_numbers": v, "count": len(v)} for k, v in sorted(by_norm.items()) if len(v) > 1]
    findings.append(finding(
        "DUPLICATE_ASSERTION_PATTERN",
        "WARNING" if duplicate_groups else ("CHECKED" if checks["detect_duplicate_assertions"] else "NOT_CHECKABLE"),
        f"Observed {len(duplicate_groups)} duplicate normalized assertion group(s)" if duplicate_groups else ("No duplicate normalized assertion condition observed" if checks["detect_duplicate_assertions"] else "Duplicate assertion detection disabled"),
        {"groups": duplicate_groups},
        "Textual equality does not establish semantic equivalence, and textual difference does not establish semantic distinctness."
    ))

    trivial_items = [x for x in assertion_inventory if x["obvious_truth_classification"] in {"TRUE", "FALSE"}] if checks["detect_trivial_assertions"] else []
    findings.append(finding(
        "OBVIOUS_TRIVIAL_ASSERTION_PATTERN",
        "WARNING" if trivial_items else ("CHECKED" if checks["detect_trivial_assertions"] else "NOT_CHECKABLE"),
        f"Observed {len(trivial_items)} assertion(s) classified constant TRUE/FALSE by narrow rules" if trivial_items else ("No configured trivial assertion pattern observed" if checks["detect_trivial_assertions"] else "Trivial assertion detection disabled"),
        {"items": trivial_items, "classification_method": "TINY_SYNTACTIC_LITERAL_AND_REFLEXIVE_COMPARISON_RULES"},
        "The check is deliberately incomplete and performs no theorem proving."
    ))

    assume_norms = {x["normalized_condition"] for x in assumption_inventory}
    assumed_assertions = [x for x in assertion_inventory if x["normalized_condition"] in assume_norms] if checks["detect_assumed_assertions"] else []
    findings.append(finding(
        "ASSERTION_IDENTICAL_TO_ASSUMPTION_PATTERN",
        "WARNING" if assumed_assertions else ("CHECKED" if checks["detect_assumed_assertions"] else "NOT_CHECKABLE"),
        f"Observed {len(assumed_assertions)} assertion(s) textually identical to an assumption" if assumed_assertions else ("No assertion condition was textually identical to an assumption" if checks["detect_assumed_assertions"] else "Assumed-assertion detection disabled"),
        {"items": assumed_assertions},
        "This is a normalized-text comparison, not semantic implication checking."
    ))

    # Build input comparison.
    allowed = set(request["allowed_build_inputs"])
    actual = {x["path"] for x in request["actual_build_inputs"]}
    unexpected = sorted(actual - allowed)
    missing = sorted(allowed - actual)
    if checks["compare_build_inputs"]:
        bstatus = "WARNING" if unexpected or missing else "CHECKED"
        bsummary = f"Observed {len(unexpected)} unexpected and {len(missing)} missing declared build input(s)" if bstatus == "WARNING" else "Actual build inputs exactly match the caller-declared allowlist"
    else:
        bstatus, bsummary = "NOT_CHECKABLE", "Build-input comparison disabled"
    findings.append(finding(
        "BUILD_INPUT_ALLOWLIST_COMPARISON", bstatus, bsummary,
        {"allowed": sorted(allowed), "actual": sorted(actual), "unexpected": unexpected, "missing": missing},
        "The comparison covers only caller-declared build inputs; it does not observe hidden compiler or environment inputs."
    ))

    # Optional unresolved-function evidence.
    if not checks["inspect_undefined_functions"]:
        ustatus, usummary, uevidence = "NOT_CHECKABLE", "Undefined-function inspection disabled", {"functions": []}
    elif diag_manifest is None:
        ustatus, usummary, uevidence = "NOT_CHECKABLE", "No hash-bound undefined-functions diagnostic was supplied", {"functions": []}
    elif not diag_manifest["hash_match"]:
        ustatus, usummary, uevidence = "WARNING", "Undefined-functions diagnostic hash differs from the declared identity", {"functions": [], "diagnostic_manifest": diag_manifest}
    else:
        undefined = parse_undefined_functions(diag_text or "")
        ustatus = "WARNING" if undefined else "CHECKED"
        usummary = f"Diagnostic listed {len(undefined)} undefined function(s)" if undefined else "Diagnostic listed no undefined functions"
        uevidence = {"functions": undefined, "diagnostic_manifest": diag_manifest}
    findings.append(finding(
        "UNDEFINED_FUNCTION_DIAGNOSTIC", ustatus, usummary, uevidence,
        "The skill trusts only the supplied diagnostic text and does not reconstruct the GOTO program or call graph."
    ))

    # Global report.
    warning_count = sum(1 for x in findings if x["status"] == "WARNING")
    not_checkable_count = sum(1 for x in findings if x["status"] == "NOT_CHECKABLE")
    report_status = "COMPLETE_WITH_WARNINGS" if warning_count else "COMPLETE"
    limitations = [
        "This audit is syntactic and structural; it does not establish semantic validity.",
        "CHECKED means the configured mechanical check completed without the specific pattern being flagged.",
        "WARNING is evidence for Codex and the researcher to inspect; it is not rejection.",
        "NOT_CHECKABLE means the configured evidence was absent or the check was disabled.",
        "The audit does not prove reachability, non-vacuity, theorem usefulness, assumption justification, or implementation correctness.",
        "No finding produced by this skill is an acceptance or rejection gate."
    ]
    report = {
        "schema_version": "1.0", "skill_version": VERSION, "request_id": request["request_id"],
        "report_status": report_status, "audit_outcome": "STRUCTURAL_AUDIT_RECORDED",
        "semantic_authority": "NONE", "gate_authority": "NONE",
        "target_symbol": target, "finding_counts": {
            "total": len(findings), "checked": sum(1 for x in findings if x["status"] == "CHECKED"),
            "warning": warning_count, "not_checkable": not_checkable_count
        },
        "findings": findings, "limitations": limitations
    }
    source_manifest = {
        "schema_version": "1.0", "request_id": request["request_id"],
        "audit_root_identity": "CALLER_SUPPLIED_LOCAL_ROOT_NOT_EMBEDDED",
        "files": sorted(manifest_entries, key=lambda x: (x["path"], x["category"])),
        "undefined_functions_diagnostic": diag_manifest
    }
    target_report = {
        "schema_version": "1.0", "target_symbol": target,
        "authoritative_definition_path": request["target"]["authoritative_definition_path"],
        "harness_lexical_call_count": len(call_lines), "harness_call_line_numbers": call_lines,
        "replacement_patterns": replacement_evidence,
        "analysis_nature": "LEXICAL_AND_MANIFEST_STRUCTURAL_ONLY", "semantic_authority": "NONE"
    }

    output_dir.mkdir(parents=False)
    write_json(output_dir / "canonical_request.json", request)
    write_json(output_dir / "source_manifest.json", source_manifest)
    write_json(output_dir / "assumption_inventory.json", {"schema_version": "1.0", "items": assumption_inventory, "semantic_authority": "NONE"})
    write_json(output_dir / "assertion_inventory.json", {"schema_version": "1.0", "items": assertion_inventory, "semantic_authority": "NONE"})
    write_json(output_dir / "target_binding_report.json", target_report)
    write_json(output_dir / "findings.json", {"schema_version": "1.0", "status_vocabulary": sorted(STATUSES), "items": findings})
    write_json(output_dir / "harness_integrity_audit_report.json", report)

    md = [
        "# Harness Integrity Audit", "", f"- Request: `{request['request_id']}`",
        f"- Target: `{target}`", f"- Report status: **{report_status}**",
        "- Semantic authority: **NONE**", "- Gate authority: **NONE**", "",
        "## Findings", ""
    ]
    for x in findings:
        md += [f"### {x['check_id']} — {x['status']}", "", x["summary"], ""]
        if x.get("limitation"): md += [f"_Limitation: {x['limitation']}_", ""]
    md += ["## Mandatory interpretation boundary", ""] + [f"- {x}" for x in limitations] + [""]
    (output_dir / "harness_integrity_audit_report.md").write_text("\n".join(md), encoding="utf-8")

    artifacts = []
    for p in sorted(output_dir.iterdir(), key=lambda x: x.name):
        if p.is_file() and p.name != "harness_integrity_audit_artifact_manifest.json":
            artifacts.append({"path": p.name, "sha256": sha256_file(p), "size_bytes": p.stat().st_size})
    artifact_manifest = {
        "schema_version": "1.0", "request_id": request["request_id"],
        "artifacts": artifacts, "manifest_excludes_itself": True
    }
    write_json(output_dir / "harness_integrity_audit_artifact_manifest.json", artifact_manifest)
    return 0


def run(request_path: Path, audit_root: Path, output_dir: Path) -> int:
    return audit(Path(request_path), Path(audit_root), Path(output_dir))


def main() -> int:
    parser = argparse.ArgumentParser(description="Deterministic structural audit for a C/CBMC harness")
    parser.add_argument("--request", required=True, type=Path)
    parser.add_argument("--audit-root", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args()
    try:
        return run(args.request, args.audit_root, args.output_dir)
    except ContractError as e:
        print(f"CONTRACT_ERROR: {e}", file=sys.stderr)
        return 3
    except Exception as e:
        print(f"INTERNAL_ERROR: {type(e).__name__}: {e}", file=sys.stderr)
        return 5


if __name__ == "__main__":
    raise SystemExit(main())
