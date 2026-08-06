"""Exact, deterministic traceability identities for generated C/CBMC artefacts.

The scanner is intentionally narrow: it ignores comments and literals, locates
real C identifier calls with balanced parentheses, and binds trace markers to
source spans.  It is not a full C semantic parser; actual goto-cc remains the
frontend authority.
"""
from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple

JsonDict = Dict[str, Any]

TARGET_PREFIX = "TRACE_TARGET_CALL::"
CLAIM_PREFIX = "TRACE_CLAIM::"
ASSUMPTION_PREFIX = "TRACE_ASSUMPTION::"


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


@dataclass(frozen=True)
class Span:
    start: int
    end: int
    line: int
    column: int

    def to_dict(self) -> JsonDict:
        return {"start": self.start, "end": self.end, "line": self.line, "column": self.column}


def _line_column(text: str, offset: int) -> Tuple[int, int]:
    line = text.count("\n", 0, offset) + 1
    previous = text.rfind("\n", 0, offset)
    column = offset + 1 if previous < 0 else offset - previous
    return line, column


def code_mask(text: str) -> str:
    """Replace comment/literal contents with spaces while preserving offsets."""
    out = list(text)
    i = 0
    state = "code"
    quote = ""
    while i < len(text):
        if state == "code":
            if text.startswith("//", i):
                out[i] = out[i + 1] = " "
                i += 2
                state = "line_comment"
                continue
            if text.startswith("/*", i):
                out[i] = out[i + 1] = " "
                i += 2
                state = "block_comment"
                continue
            if text[i] in {'"', "'"}:
                quote = text[i]
                out[i] = " "
                i += 1
                state = "literal"
                continue
            i += 1
            continue
        if state == "line_comment":
            if text[i] == "\n":
                state = "code"
            else:
                out[i] = " "
            i += 1
            continue
        if state == "block_comment":
            if text.startswith("*/", i):
                out[i] = out[i + 1] = " "
                i += 2
                state = "code"
            else:
                if text[i] != "\n":
                    out[i] = " "
                i += 1
            continue
        # literal
        if text[i] == "\\":
            out[i] = " "
            if i + 1 < len(text):
                if text[i + 1] != "\n":
                    out[i + 1] = " "
                i += 2
            else:
                i += 1
            continue
        if text[i] == quote:
            out[i] = " "
            i += 1
            state = "code"
        else:
            if text[i] != "\n":
                out[i] = " "
            i += 1
    return "".join(out)


def _looks_like_function_declaration(masked: str, start: int, end: int) -> bool:
    """Exclude prototypes/definitions from target-call binding.

    This is a conservative token heuristic, not a full C parser. It avoids the
    previous false call count where ``void target(void);`` was treated as an
    invocation. The exact frontend remains the authority for C syntax.
    """
    after = end
    while after < len(masked) and masked[after].isspace():
        after += 1
    if after < len(masked) and masked[after] == "{":
        return True
    boundary = max(
        masked.rfind(";", 0, start), masked.rfind("{", 0, start),
        masked.rfind("}", 0, start), masked.rfind("\n", 0, start),
    )
    prefix = masked[boundary + 1:start].strip()
    if not prefix or prefix.startswith(("return ", "if ", "while ", "for ", "switch ")):
        return False
    if any(token in prefix for token in ("=", "+", "-", "/", "%", "!", "?", ",", "(")):
        return False
    # A prototype has a declaration-like prefix and ends in a semicolon.
    if after < len(masked) and masked[after] == ";":
        return bool(re.fullmatch(r"(?:[A-Za-z_]\w*|\*|\s)+", prefix))
    return False


def find_function_calls(text: str, function_name: str) -> List[JsonDict]:
    masked = code_mask(text)
    pattern = re.compile(rf"(?<![A-Za-z0-9_]){re.escape(function_name)}\s*\(")
    calls: List[JsonDict] = []
    for match in pattern.finditer(masked):
        open_pos = masked.find("(", match.start())
        depth = 1
        index = open_pos + 1
        while index < len(masked) and depth:
            if masked[index] == "(":
                depth += 1
            elif masked[index] == ")":
                depth -= 1
            index += 1
        if depth:
            continue
        close_end = index
        if _looks_like_function_declaration(masked, match.start(), close_end):
            continue
        end = close_end
        while end < len(masked) and masked[end].isspace():
            end += 1
        if end < len(masked) and masked[end] == ";":
            end += 1
        line, column = _line_column(text, match.start())
        call_text = text[match.start():end]
        calls.append({
            "function": function_name,
            "source_text": call_text,
            "source_text_sha256": sha256_text(call_text.strip()),
            "span": Span(match.start(), end, line, column).to_dict(),
        })
    return calls


def _comment_markers(text: str, prefix: str) -> List[JsonDict]:
    pattern = re.compile(re.escape(prefix) + r"([A-Za-z0-9_.:-]+)")
    markers: List[JsonDict] = []
    for match in pattern.finditer(text):
        line, column = _line_column(text, match.start())
        markers.append({
            "identity": prefix + match.group(1),
            "suffix": match.group(1),
            "span": Span(match.start(), match.end(), line, column).to_dict(),
        })
    return markers


def expected_target_identity(property_id: str) -> str:
    return TARGET_PREFIX + str(property_id)


def expected_claim_identity(property_id: str, claim_id: str) -> str:
    return CLAIM_PREFIX + str(property_id) + "::" + str(claim_id)


def expected_assumption_identity(property_id: str, assumption_id: str) -> str:
    return ASSUMPTION_PREFIX + str(property_id) + "::" + str(assumption_id)


def bind_target_call(text: str, *, function_name: str, property_id: str) -> JsonDict:
    calls = find_function_calls(text, function_name)
    identity = expected_target_identity(property_id)
    markers = [row for row in _comment_markers(text, TARGET_PREFIX) if row["identity"] == identity]
    errors: List[str] = []
    bindings: List[JsonDict] = []
    for marker in markers:
        marker_end = int(marker["span"]["end"])
        following = [call for call in calls if int(call["span"]["start"]) >= marker_end]
        if not following:
            continue
        call = min(following, key=lambda row: int(row["span"]["start"]))
        between = text[marker_end:int(call["span"]["start"])]
        # Only comment terminators, whitespace and an optional newline may occur.
        cleaned = re.sub(r"\*/|//[^\n]*", "", between).strip()
        same_or_previous_line = int(call["span"]["line"]) - int(marker["span"]["line"]) <= 1
        if not cleaned and same_or_previous_line:
            bindings.append({
                "identity": identity,
                "marker": marker,
                "call": call,
                "binding_sha256": sha256_text(identity + "\n" + call["source_text_sha256"]),
            })
    if not calls:
        errors.append(f"Exact target function call {function_name!r} is absent outside comments and literals.")
    if not markers:
        errors.append(f"Exact target marker {identity!r} is absent.")
    if len(bindings) != 1:
        errors.append(f"Expected exactly one marker-to-call binding for {identity!r}, found {len(bindings)}.")
    return {
        "schema_version": "exact_target_call_binding.v1",
        "property_id": property_id,
        "target_function": function_name,
        "expected_identity": identity,
        "call_count": len(calls),
        "marker_count": len(markers),
        "bindings": bindings,
        "valid": not errors,
        "errors": errors,
    }


def _assertion_messages(text: str) -> List[JsonDict]:
    masked = code_mask(text)
    pattern = re.compile(r"\b__CPROVER_assert\s*\(")
    rows: List[JsonDict] = []
    for match in pattern.finditer(masked):
        open_pos = masked.find("(", match.start())
        depth = 1
        comma: Optional[int] = None
        index = open_pos + 1
        while index < len(masked) and depth:
            char = masked[index]
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
            elif char == "," and depth == 1 and comma is None:
                comma = index
            index += 1
        if depth or comma is None:
            continue
        expression = text[open_pos + 1:comma].strip()
        remainder = text[comma + 1:index - 1]
        string_match = re.search(r'"((?:\\.|[^"\\])*)"', remainder, re.S)
        message = string_match.group(1) if string_match else ""
        line, column = _line_column(text, match.start())
        rows.append({
            "expression": expression,
            "expression_sha256": sha256_text(expression),
            "message": message,
            "span": Span(match.start(), index, line, column).to_dict(),
        })
    return rows


def bind_harness_claims(
    text: str, *, property_id: str, expected_claim_ids: Sequence[str]
) -> JsonDict:
    assertions = _assertion_messages(text)
    errors: List[str] = []
    bindings: List[JsonDict] = []
    for claim_id in expected_claim_ids:
        identity = expected_claim_identity(property_id, claim_id)
        matches = [row for row in assertions if row.get("message") == identity]
        if len(matches) != 1:
            errors.append(f"Expected exactly one assertion message {identity!r}, found {len(matches)}.")
        else:
            row = dict(matches[0])
            row["claim_id"] = claim_id
            row["identity"] = identity
            row["binding_sha256"] = sha256_text(identity + "\n" + row["expression_sha256"])
            bindings.append(row)
    duplicates = [
        message for message in {str(row.get("message") or "") for row in assertions}
        if message.startswith(CLAIM_PREFIX) and sum(1 for row in assertions if row.get("message") == message) > 1
    ]
    if duplicates:
        errors.append("Duplicate exact claim identities: " + ", ".join(sorted(duplicates)))
    return {
        "schema_version": "exact_harness_claim_binding.v1",
        "property_id": property_id,
        "expected_claim_ids": list(expected_claim_ids),
        "assertion_count": len(assertions),
        "bindings": bindings,
        "valid": not errors,
        "errors": errors,
    }



def _assume_calls(text: str) -> List[JsonDict]:
    masked = code_mask(text)
    pattern = re.compile(r"\b__CPROVER_assume\s*\(")
    rows: List[JsonDict] = []
    for match in pattern.finditer(masked):
        open_pos = masked.find("(", match.start())
        depth = 1
        index = open_pos + 1
        while index < len(masked) and depth:
            if masked[index] == "(":
                depth += 1
            elif masked[index] == ")":
                depth -= 1
            index += 1
        if depth:
            continue
        expression = text[open_pos + 1:index - 1].strip()
        line, column = _line_column(text, match.start())
        rows.append({
            "expression": expression,
            "expression_sha256": sha256_text(expression),
            "span": Span(match.start(), index, line, column).to_dict(),
        })
    return rows


def bind_harness_assumptions(
    text: str, *, property_id: str, expected_assumption_ids: Sequence[str]
) -> JsonDict:
    calls = _assume_calls(text)
    markers = _comment_markers(text, ASSUMPTION_PREFIX)
    errors: List[str] = []
    bindings: List[JsonDict] = []
    for assumption_id in expected_assumption_ids:
        identity = expected_assumption_identity(property_id, assumption_id)
        exact_markers = [row for row in markers if row.get("identity") == identity]
        matches: List[JsonDict] = []
        for marker in exact_markers:
            marker_end = int(marker["span"]["end"])
            following = [row for row in calls if int(row["span"]["start"]) >= marker_end]
            if not following:
                continue
            call = min(following, key=lambda row: int(row["span"]["start"]))
            between = text[marker_end:int(call["span"]["start"])]
            cleaned = re.sub(r"\*/|//[^\n]*", "", between).strip()
            if not cleaned and int(call["span"]["line"]) - int(marker["span"]["line"]) <= 1:
                matches.append({"identity": identity, "marker": marker, "assume": call})
        if len(matches) != 1:
            errors.append(f"Expected exactly one marker-to-assume binding for {identity!r}, found {len(matches)}.")
        else:
            row = matches[0]
            row["assumption_id"] = assumption_id
            row["binding_sha256"] = sha256_text(identity + "\n" + row["assume"]["expression_sha256"])
            bindings.append(row)
    return {
        "schema_version": "exact_harness_assumption_binding.v1",
        "property_id": property_id,
        "expected_assumption_ids": list(expected_assumption_ids),
        "assume_count": len(calls),
        "bindings": bindings,
        "valid": not errors,
        "errors": errors,
    }

def build_traceability_record(
    *,
    harness_text: str,
    target_function: str,
    property_id: str,
    claim_ids: Sequence[str],
    assumption_ids: Sequence[str] = (),
    harness_path: str = "",
) -> JsonDict:
    target = bind_target_call(harness_text, function_name=target_function, property_id=property_id)
    claims = bind_harness_claims(harness_text, property_id=property_id, expected_claim_ids=claim_ids)
    assumptions = bind_harness_assumptions(
        harness_text, property_id=property_id, expected_assumption_ids=assumption_ids
    )
    return {
        "schema_version": "exact_traceability_record.v2",
        "harness_path": harness_path,
        "harness_sha256": sha256_text(harness_text),
        "property_id": property_id,
        "target_call_binding": target,
        "claim_bindings": claims,
        "assumption_bindings": assumptions,
        "valid": bool(target.get("valid")) and bool(claims.get("valid")) and bool(assumptions.get("valid")),
        "errors": [*target.get("errors", []), *claims.get("errors", []), *assumptions.get("errors", [])],
        "claim_boundary": "Exact traceability establishes source identity and placement, not semantic truth or verification success.",
    }


def _row_exact_strings(row: Mapping[str, Any]) -> List[str]:
    values: List[str] = []
    for key in ("property", "property_id", "description", "message", "expression", "condition"):
        value = row.get(key)
        if isinstance(value, str) and value.strip():
            values.append(value.strip())
    return values


def _normalized_expression_hash(text: str) -> str:
    return sha256_text(re.sub(r"\s+", " ", str(text).strip()))


def exact_property_coverage(
    expected_claim_bindings: Sequence[Mapping[str, Any]],
    property_rows: Sequence[Mapping[str, Any]],
) -> JsonDict:
    """Map generated properties by exact identity or exact expression hash, never regex."""
    rows = [dict(row) for row in property_rows if isinstance(row, Mapping)]
    used: set[int] = set()
    mapped: List[JsonDict] = []
    missing: List[JsonDict] = []
    ambiguous: List[JsonDict] = []
    for binding in expected_claim_bindings:
        identity = str(binding.get("identity") or binding.get("expected_property_identity") or "").strip()
        expression_sha256 = str(binding.get("expression_sha256") or "").strip()
        matches: List[Tuple[int, JsonDict, str]] = []
        for index, row in enumerate(rows):
            strings = _row_exact_strings(row)
            reason = ""
            if identity and identity in strings:
                reason = "exact_identity"
            elif expression_sha256 and any(_normalized_expression_hash(value) == expression_sha256 for value in strings):
                reason = "exact_expression_sha256"
            if reason:
                matches.append((index, row, reason))
        record = {
            "identity": identity,
            "expression_sha256": expression_sha256,
            "implementation_kind": str(binding.get("implementation_kind") or ""),
            "matches": [{"row": row, "authority": reason} for _, row, reason in matches],
        }
        if not matches:
            missing.append(record)
        elif len(matches) > 1 or any(index in used for index, _, _ in matches):
            ambiguous.append(record)
        else:
            used.add(matches[0][0])
            mapped.append(record)
    return {
        "schema_version": "exact_selected_property_coverage.v2",
        "expected_claim_count": len(expected_claim_bindings),
        "covered_claim_count": len(mapped),
        "missing_claim_count": len(missing),
        "ambiguous_claim_count": len(ambiguous),
        "coverage_complete": bool(expected_claim_bindings) and not missing and not ambiguous,
        "mapped_claims": mapped,
        "missing_claims": missing,
        "ambiguous_claims": ambiguous,
        "mapping_authority": "exact_identity_or_exact_expression_sha256_only",
    }


__all__ = [
    "ASSUMPTION_PREFIX",
    "CLAIM_PREFIX",
    "TARGET_PREFIX",
    "bind_harness_assumptions",
    "bind_harness_claims",
    "bind_target_call",
    "build_traceability_record",
    "code_mask",
    "exact_property_coverage",
    "expected_assumption_identity",
    "expected_claim_identity",
    "expected_target_identity",
    "find_function_calls",
    "sha256_text",
]
