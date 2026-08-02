"""Version-bound CBMC capability profile and clause-specific validation.

This module does not decide whether a property is true.  It constrains generated
syntax to documented/tested forms and records the installed tool identity.
Actual ``goto-cc``/``goto-instrument`` execution remains the decisive frontend
and transformation readiness authority.
"""
from __future__ import annotations

import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple

JsonDict = Dict[str, Any]

CLAUSE_KINDS = {
    "requires",
    "ensures",
    "assigns",
    "frees",
    "loop_invariant",
    "decreases",
    "loop_assigns",
    "loop_frees",
}

MEMORY_PREDICATES = {
    "__CPROVER_rw_ok",
    "__CPROVER_r_ok",
    "__CPROVER_w_ok",
    "__CPROVER_is_fresh",
    "__CPROVER_pointer_in_range_dfcc",
}

HISTORY_VARIABLE_CONSTRUCTS = {
    "__CPROVER_old",
    "__CPROVER_loop_entry",
    "__CPROVER_return_value",
}

# Compact syntax boundary supplied to the model.  This is intentionally not a
# complete manual and is always subordinate to actual frontend acceptance.
PROFILE_BASE: JsonDict = {
    "schema_version": "cbmc_capability_profile.v1",
    "profile_family": "cbmc-6.x-contracts",
    "supported_clause_forms": {
        "requires": ["C Boolean expression"],
        "ensures": ["C Boolean expression", "__CPROVER_old(expr)", "__CPROVER_return_value"],
        "assigns": [
            "plain writable lvalue",
            "__CPROVER_object_whole(pointer)",
            "__CPROVER_object_from(pointer)",
            "__CPROVER_object_upto(pointer, size)",
        ],
        "frees": ["pointer expression identifying an object that may be freed"],
        "loop_invariant": ["C Boolean expression", "__CPROVER_loop_entry(expr)"],
        "decreases": ["integer expression", "comma-separated lexicographic tuple"],
        "loop_assigns": [
            "plain writable lvalue",
            "__CPROVER_object_whole(pointer)",
            "__CPROVER_object_from(pointer)",
            "__CPROVER_object_upto(pointer, size)",
        ],
        "loop_frees": ["pointer expression identifying an object that may be freed"],
    },
    "valid_minimal_examples": {
        "requires": ["r != NULL", "__CPROVER_rw_ok(r, sizeof(*r))"],
        "ensures": ["r->coeffs[0] == __CPROVER_old(r->coeffs[0])"],
        "assigns": [
            "r->coeffs[0]",
            "__CPROVER_object_upto(r->coeffs, sizeof(r->coeffs))",
        ],
        "loop_invariant": ["0 <= i && i <= MLKEM_N"],
        "decreases": ["MLKEM_N - i"],
    },
    "prohibited_known_pseudocode_forms": [
        "array[0 .. N]",
        "array[0:N]",
        "array[start:end]",
        "natural-language prose in executable_expression",
        "ACSL-style ranges",
        "Python/Rust slice notation",
    ],
    "builtin_arity": {
        "__CPROVER_object_whole": 1,
        "__CPROVER_object_from": 1,
        "__CPROVER_object_upto": 2,
        "__CPROVER_old": 1,
        "__CPROVER_loop_entry": 1,
        "__CPROVER_rw_ok": 2,
        "__CPROVER_r_ok": 2,
        "__CPROVER_w_ok": 2,
        "__CPROVER_is_fresh": 2,
        "__CPROVER_pointer_in_range_dfcc": 3,
    },
}


def _sha256_json(payload: Mapping[str, Any]) -> str:
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def _version(binary: str) -> JsonDict:
    resolved = shutil.which(binary)
    if not resolved:
        return {"configured": binary, "resolved": None, "available": False, "version_first_line": None}
    try:
        proc = subprocess.run([resolved, "--version"], text=True, capture_output=True, timeout=15, check=False)
        text = (proc.stdout or proc.stderr or "").strip()
        first = text.splitlines()[0] if text else ""
        return {
            "configured": binary,
            "resolved": str(Path(resolved).resolve()),
            "available": proc.returncode == 0,
            "version_first_line": first,
            "exit_code": proc.returncode,
        }
    except Exception as exc:
        return {
            "configured": binary,
            "resolved": str(Path(resolved).resolve()),
            "available": False,
            "version_first_line": None,
            "error": f"{type(exc).__name__}: {exc}",
        }


def build_capability_profile(
    *, goto_cc_binary: str = "goto-cc", goto_instrument_binary: str = "goto-instrument", cbmc_binary: str = "cbmc"
) -> JsonDict:
    profile = json.loads(json.dumps(PROFILE_BASE))
    profile["tools"] = {
        "goto_cc": _version(goto_cc_binary),
        "goto_instrument": _version(goto_instrument_binary),
        "cbmc": _version(cbmc_binary),
    }
    profile["capability_profile_sha256"] = _sha256_json(profile)
    return profile


def _balanced(text: str) -> bool:
    pairs = {")": "(", "]": "[", "}": "{"}
    stack: List[str] = []
    quote: Optional[str] = None
    escaped = False
    for char in text:
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in {'"', "'"}:
            quote = char
        elif char in "([{":
            stack.append(char)
        elif char in ")]}":
            if not stack or stack.pop() != pairs[char]:
                return False
    return quote is None and not stack


def _split_top_level_args(text: str) -> List[str]:
    args: List[str] = []
    start = 0
    depth = 0
    quote: Optional[str] = None
    escaped = False
    for index, char in enumerate(text):
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in {'"', "'"}:
            quote = char
        elif char in "([{":
            depth += 1
        elif char in ")]}" and depth:
            depth -= 1
        elif char == "," and depth == 0:
            args.append(text[start:index].strip())
            start = index + 1
    args.append(text[start:].strip())
    return args


def _builtin_calls(expression: str) -> Iterable[Tuple[str, str]]:
    pattern = re.compile(r"\b(__CPROVER_[A-Za-z0-9_]+)\s*\(")
    for match in pattern.finditer(expression):
        start = match.end()
        depth = 1
        quote: Optional[str] = None
        escaped = False
        index = start
        while index < len(expression) and depth:
            char = expression[index]
            if quote:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == quote:
                    quote = None
            elif char in {'"', "'"}:
                quote = char
            elif char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
            index += 1
        if depth == 0:
            yield match.group(1), expression[start:index - 1]


def normalize_clause_record(item: Any, *, clause_kind: str, index: int) -> JsonDict:
    """Normalize typed records while retaining legacy strings for replay only."""
    if isinstance(item, Mapping):
        record = dict(item)
        expression = str(record.get("executable_expression") or "").strip()
        return {
            "clause_id": str(record.get("clause_id") or f"{clause_kind.upper()}_{index + 1:02d}"),
            "clause_kind": str(record.get("clause_kind") or clause_kind),
            "description": str(record.get("description") or ""),
            "executable_expression": expression,
            "bound_symbols": [str(x) for x in record.get("bound_symbols", [])] if isinstance(record.get("bound_symbols"), list) else [],
            "evidence_references": list(record.get("evidence_references") or []) if isinstance(record.get("evidence_references"), list) else [],
            "expected_property_identity": str(record.get("expected_property_identity") or ""),
            "legacy_string_input": False,
        }
    return {
        "clause_id": f"{clause_kind.upper()}_{index + 1:02d}",
        "clause_kind": clause_kind,
        "description": "Legacy untyped executable clause retained for backward-compatible replay.",
        "executable_expression": str(item or "").strip(),
        "bound_symbols": [],
        "evidence_references": [],
        "expected_property_identity": "",
        "legacy_string_input": True,
    }


def normalize_clause_records(value: Any, *, clause_kind: str) -> List[JsonDict]:
    if not isinstance(value, list):
        return []
    return [normalize_clause_record(item, clause_kind=clause_kind, index=index) for index, item in enumerate(value)]


def clause_expressions(value: Any, *, clause_kind: str) -> List[str]:
    return [str(row.get("executable_expression") or "") for row in normalize_clause_records(value, clause_kind=clause_kind)]


def validate_clause_record(
    record: Mapping[str, Any], *, strict_typed: bool = True, profile: Mapping[str, Any] = PROFILE_BASE
) -> JsonDict:
    kind = str(record.get("clause_kind") or "").strip()
    expression = str(record.get("executable_expression") or "").strip()
    errors: List[str] = []
    warnings: List[str] = []
    if kind not in CLAUSE_KINDS:
        errors.append(f"Unknown contract clause kind: {kind!r}.")
    if strict_typed and bool(record.get("legacy_string_input")):
        errors.append("Production contract clauses must use typed clause records, not bare strings.")
    if not expression:
        errors.append("executable_expression must be non-empty.")
    if any(token in expression for token in ("\n", "\r", ";", "/*", "*/", "//", "#include", "#define")):
        errors.append("Executable clauses must be single expressions without statements, comments, or directives.")
    if not _balanced(expression):
        errors.append("Executable clause has unbalanced delimiters or quotes.")
    if re.search(r"\[[^\]]*\.\.[^\]]*\]", expression):
        errors.append("Unsupported mathematical/ACSL-style array range '[start .. end]'.")
    if re.search(r"\[[^\]]*:[^\]]*\]", expression):
        errors.append("Unsupported Python/Rust-style array slice '[start:end]'.")
    # Fail fast on obvious prose without confusing readable C identifiers with
    # English.  A single identifier such as ``buffer_is_valid`` remains valid;
    # a multi-word sentence with no C/CBMC operators or call/index syntax does
    # not.  Installed goto-cc is still the final syntax authority.
    prose_words = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", expression)
    has_c_expression_syntax = bool(re.search(r"(?:->|&&|\|\||==|!=|<=|>=|[()\[\]{}!<>=&|+*/%?:.,-])", expression))
    if len(prose_words) >= 3 and not has_c_expression_syntax:
        errors.append("Executable clause appears to contain natural-language prose rather than a C/CBMC expression.")
    if re.search(r"\b(and|or|not)\b", expression) and not re.search(r"\b(and|or|not)\s*\(", expression):
        warnings.append("Expression contains word-form logical operators; goto-cc parsing is required to decide validity.")
    if kind in {"assigns", "loop_assigns"}:
        # Assigns expressions are memory locations/sets, not Boolean relations.
        if re.search(r"(^|[^=!<>])=([^=]|$)|==|!=|<=|>=|&&|\|\|", expression):
            errors.append("Assigns clauses must denote writable locations/object ranges, not Boolean or assignment expressions.")
        if expression.startswith("&"):
            warnings.append("Address-of in an assigns target is unusual; verify against installed goto-cc.")
    if kind in {"requires", "ensures", "loop_invariant"} and expression in {"1", "true", "(1)", "(true)"}:
        errors.append("Literal-true clause is not accepted as a production selected-property claim.")
    history_errors: List[str] = []
    if kind != "ensures" and "__CPROVER_old" in expression:
        message = "__CPROVER_old is restricted to function ensures clauses."
        errors.append(message); history_errors.append(message)
    if kind not in {"loop_invariant", "decreases", "loop_assigns", "loop_frees"} and "__CPROVER_loop_entry" in expression:
        message = "__CPROVER_loop_entry is restricted to loop-contract clauses."
        errors.append(message); history_errors.append(message)
    if kind != "ensures" and "__CPROVER_return_value" in expression:
        message = "__CPROVER_return_value is restricted to function ensures clauses."
        errors.append(message); history_errors.append(message)

    calls = list(_builtin_calls(expression))
    used_builtins = sorted({name for name, _ in calls})
    used_memory_predicates = sorted(set(used_builtins) & MEMORY_PREDICATES)
    used_history_variables = sorted(
        name for name in HISTORY_VARIABLE_CONSTRUCTS if name in expression
    )
    memory_errors: List[str] = []
    arity = profile.get("builtin_arity") if isinstance(profile.get("builtin_arity"), Mapping) else {}
    for name, args_text in calls:
        expected = arity.get(name)
        if isinstance(expected, int):
            actual = len(_split_top_level_args(args_text)) if args_text.strip() else 0
            if actual != expected:
                message = f"{name} expects {expected} argument(s), got {actual}."
                errors.append(message)
                if name in MEMORY_PREDICATES:
                    memory_errors.append(message)
                if name in HISTORY_VARIABLE_CONSTRUCTS:
                    history_errors.append(message)
        elif name.startswith("__CPROVER_object_"):
            errors.append(f"Unsupported or unknown object-range builtin: {name}.")

    return {
        "schema_version": "cbmc_clause_validation.v1",
        "clause_id": str(record.get("clause_id") or ""),
        "clause_kind": kind,
        "valid": not errors,
        "errors": errors,
        "warnings": warnings,
        "memory_predicate_validation": {
            "schema_version": "cbmc_memory_predicate_validation.v1",
            "used": used_memory_predicates,
            "valid": not memory_errors,
            "errors": memory_errors,
            "frontend_parse_required": bool(used_memory_predicates),
        },
        "history_variable_validation": {
            "schema_version": "cbmc_history_variable_validation.v1",
            "used": used_history_variables,
            "valid": not history_errors,
            "errors": history_errors,
            "frontend_parse_required": bool(used_history_variables),
        },
        "frontend_parse_required": True,
        "claim_boundary": "Static clause validation is fail-fast screening; installed goto-cc remains the syntax authority.",
    }


def validate_clause_records(
    value: Any, *, clause_kind: str, strict_typed: bool = True, profile: Mapping[str, Any] = PROFILE_BASE
) -> JsonDict:
    records = normalize_clause_records(value, clause_kind=clause_kind)
    validations = [validate_clause_record(row, strict_typed=strict_typed, profile=profile) for row in records]
    return {
        "schema_version": "cbmc_clause_group_validation.v1",
        "clause_kind": clause_kind,
        "records": records,
        "validations": validations,
        "valid": all(row.get("valid") for row in validations),
        "errors": [error for row in validations for error in row.get("errors", [])],
        "warnings": [warning for row in validations for warning in row.get("warnings", [])],
    }


__all__ = [
    "CLAUSE_KINDS",
    "HISTORY_VARIABLE_CONSTRUCTS",
    "MEMORY_PREDICATES",
    "PROFILE_BASE",
    "build_capability_profile",
    "clause_expressions",
    "normalize_clause_record",
    "normalize_clause_records",
    "validate_clause_record",
    "validate_clause_records",
]
