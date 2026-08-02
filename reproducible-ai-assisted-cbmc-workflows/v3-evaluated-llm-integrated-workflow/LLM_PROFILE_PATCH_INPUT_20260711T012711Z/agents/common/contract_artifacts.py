"""Controlled rendering and validation of native CBMC contract artefacts.

This module deliberately does not edit implementation repositories.  Loop
annotations are inserted only into copied, explicitly configured source files,
using a single exact loop-header anchor.  Function contracts are rendered as a
separate forced-include declaration.  All results remain candidate artefacts
until Agent 6 and a human reviewer approve tool execution.
"""
from __future__ import annotations

import difflib
import hashlib
import re
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Sequence, Tuple

JsonDict = Dict[str, Any]

CONTRACT_STRATEGIES = {
    "native_loop_contract",
    "native_function_contract",
    "hybrid_contract_and_harness",
}
LOOP_MODES = {"loop", "loop_and_function"}
FUNCTION_MODES = {"function", "loop_and_function"}
_C_IDENTIFIER = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
_CONTRACT_SYMBOL = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*(?:/[A-Za-z_][A-Za-z0-9_]*)?$")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _clean_clause_list(value: Any) -> List[str]:
    if not isinstance(value, list):
        return []
    return [str(x).strip() for x in value]


def _looks_side_effecting(expression: str) -> bool:
    text = expression.strip()
    if "++" in text or "--" in text:
        return True
    # Assignment that is not ==, !=, <=, >=, or implication ==>
    return bool(re.search(r"(?<![=!<>])=(?!=|>)", text))


def _unsafe_clause_syntax(expression: str) -> bool:
    return any(token in expression for token in ("\n", "\r", ";", "{", "}", "#", "/*", "*/", "//"))


def _is_within(path: Path, roots: Sequence[Path]) -> bool:
    for root in roots:
        try:
            path.relative_to(root)
            return True
        except ValueError:
            continue
    return False


def _validate_symbol(symbol: str, *, allow_contract_pair: bool = False) -> bool:
    return bool((_CONTRACT_SYMBOL if allow_contract_pair else _C_IDENTIFIER).fullmatch(symbol))


def validate_contract_plan(contract_plan: Mapping[str, Any], strategy: str) -> JsonDict:
    errors: List[str] = []
    warnings: List[str] = []
    enabled = bool(contract_plan.get("enabled"))

    if strategy in CONTRACT_STRATEGIES and not enabled:
        errors.append(f"Strategy {strategy} requires contract_plan.enabled=true.")
    if strategy not in CONTRACT_STRATEGIES and enabled:
        warnings.append(
            f"contract_plan.enabled=true is unnecessary for strategy {strategy}; "
            "Agent 6 must confirm that the strategy was not changed accidentally."
        )
    if not enabled:
        return {"valid": not errors, "errors": errors, "warnings": warnings, "enabled": False}

    mode = str(contract_plan.get("contract_mode") or "")
    allowed_modes = {"loop", "function", "loop_and_function"}
    if mode not in allowed_modes:
        errors.append(f"contract_mode must be one of {sorted(allowed_modes)}, got {mode!r}.")

    if strategy == "native_loop_contract" and mode not in LOOP_MODES:
        errors.append("native_loop_contract requires contract_mode loop or loop_and_function.")
    if strategy == "native_function_contract" and mode not in FUNCTION_MODES:
        errors.append("native_function_contract requires contract_mode function or loop_and_function.")

    requires = _clean_clause_list(contract_plan.get("requires_clauses"))
    ensures = _clean_clause_list(contract_plan.get("ensures_clauses"))
    assigns = _clean_clause_list(contract_plan.get("assigns_clauses"))
    frees = _clean_clause_list(contract_plan.get("frees_clauses"))
    invariants = _clean_clause_list(contract_plan.get("loop_invariant_clauses"))
    decreases = _clean_clause_list(contract_plan.get("decreases_clauses"))
    loop_assigns = _clean_clause_list(contract_plan.get("loop_assigns_clauses"))
    loop_frees = _clean_clause_list(contract_plan.get("loop_frees_clauses"))
    patches = list(contract_plan.get("source_patch_operations") or [])

    if mode in FUNCTION_MODES:
        declaration = str(contract_plan.get("function_declaration") or "").strip()
        target_symbol = str(contract_plan.get("target_symbol") or "").strip()
        if not declaration:
            errors.append("Function-contract mode requires function_declaration.")
        if not target_symbol:
            errors.append("Function-contract mode requires target_symbol.")
        if target_symbol and not _validate_symbol(target_symbol):
            errors.append("target_symbol must be a plain C identifier.")
        if any(token in declaration for token in (";", "{", "}", "\n", "\r", "#", "/*", "*/", "//")):
            errors.append("function_declaration must be a single declaration prefix without ';', body, comments, or directives.")
        if target_symbol and declaration and not re.search(rf"\b{re.escape(target_symbol)}\s*\(", declaration):
            errors.append("function_declaration does not contain the configured target_symbol.")
        if not (requires or ensures or assigns or frees):
            errors.append("Function-contract mode requires at least one requires/ensures/assigns/frees clause.")
        replacements = [str(x).strip() for x in (contract_plan.get("replace_calls_with_contract") or [])]
        if not bool(contract_plan.get("enforce_contract")) and not replacements:
            errors.append("Function-contract mode requires enforce_contract=true or at least one replacement symbol.")
        for symbol in replacements:
            if not _validate_symbol(symbol, allow_contract_pair=True):
                errors.append(f"Invalid replace_calls_with_contract symbol: {symbol!r}.")

    if mode in LOOP_MODES:
        if not invariants:
            errors.append("Loop-contract mode requires at least one non-empty loop invariant clause.")
        if not patches:
            errors.append("Loop contracts require at least one controlled source_patch_operation.")
        if not bool(contract_plan.get("apply_loop_contracts")):
            errors.append("Loop-contract mode requires apply_loop_contracts=true.")

    if decreases and not invariants:
        errors.append("Decreases clauses require loop invariant clauses.")

    clause_groups = {
        "requires": requires,
        "ensures": ensures,
        "assigns": assigns,
        "frees": frees,
        "loop_invariant": invariants,
        "decreases": decreases,
        "loop_assigns": loop_assigns,
        "loop_frees": loop_frees,
    }
    for name, clauses in clause_groups.items():
        for index, clause in enumerate(clauses):
            if not clause:
                errors.append(f"{name} clause {index} is empty.")
                continue
            if "TODO" in clause or "SET_TO_" in clause:
                errors.append(f"{name} clause {index} contains a placeholder.")
            if _unsafe_clause_syntax(clause):
                errors.append(f"{name} clause {index} contains forbidden multi-statement or directive syntax.")
            if name in {"requires", "ensures", "loop_invariant", "decreases"} and _looks_side_effecting(clause):
                errors.append(f"{name} clause {index} appears to contain a side effect or assignment.")

    trivial = {"1", "true", "(1)", "(true)"}
    for clause in invariants:
        if clause.lower() in trivial:
            errors.append("Trivial loop invariant is not accepted as a production contract candidate.")

    if any("__CPROVER_old" in c for c in invariants + decreases + loop_assigns + loop_frees):
        errors.append("__CPROVER_old is only valid in function ensures clauses; use __CPROVER_loop_entry in loop contracts.")
    if any("__CPROVER_loop_entry" in c for c in requires + ensures + assigns + frees):
        errors.append("__CPROVER_loop_entry is loop-contract history syntax and must not appear in function contracts.")
    if any("__CPROVER_return_value" in c for c in requires + assigns + frees + invariants + decreases + loop_assigns + loop_frees):
        errors.append("__CPROVER_return_value is restricted to function ensures clauses.")

    if bool(contract_plan.get("use_dfcc")) and mode not in FUNCTION_MODES:
        errors.append("use_dfcc=true requires a function contract.")

    for index, patch in enumerate(patches):
        if not isinstance(patch, Mapping):
            errors.append(f"Patch operation {index} is not an object.")
            continue
        for key in ("patch_id", "operation_kind", "target_source_path", "expected_original", "purpose"):
            if not str(patch.get(key) or "").strip():
                errors.append(f"Patch operation {index} missing {key}.")
        kind = str(patch.get("operation_kind") or "")
        if kind != "insert_loop_contract_after_guard":
            errors.append(
                f"Patch operation {index} has unsupported operation_kind {kind!r}; "
                "only controlled loop-annotation insertion is allowed."
            )
        count = patch.get("expected_occurrences")
        if isinstance(count, bool) or not isinstance(count, int) or count != 1:
            errors.append(f"Patch operation {index} expected_occurrences must be exactly 1.")
        expected = str(patch.get("expected_original") or "")
        stripped_expected = expected.rstrip()
        # A same-line opening brace is common in production C and is safe to
        # split deterministically.  Any closing brace or any non-trailing opening
        # brace would risk capturing/replacing loop-body text and is rejected.
        if "}" in expected or ("{" in expected and not stripped_expected.endswith("{")) or stripped_expected.count("{") > 1:
            errors.append(
                f"Patch operation {index} anchor appears to contain loop-body text; "
                "use the exact loop guard with at most one trailing opening brace."
            )
        if len(expected) > 2000:
            errors.append(f"Patch operation {index} anchor is unexpectedly large.")
        replacement = str(patch.get("replacement") or "")
        if replacement.strip():
            errors.append(
                f"Patch {patch.get('patch_id', index)} supplies replacement text; "
                "Python constructs the annotation block and replacement must be empty."
            )

    return {
        "valid": not errors,
        "errors": errors,
        "warnings": warnings,
        "enabled": True,
        "contract_mode": mode,
        "clause_counts": {name: len(values) for name, values in clause_groups.items()},
        "patch_operation_count": len(patches),
    }


def _render_loop_annotation_block(contract_plan: Mapping[str, Any], indent: str = "") -> str:
    lines: List[str] = []
    for clause in _clean_clause_list(contract_plan.get("loop_invariant_clauses")):
        lines.append(f"{indent}__CPROVER_loop_invariant({clause})")
    for clause in _clean_clause_list(contract_plan.get("decreases_clauses")):
        lines.append(f"{indent}__CPROVER_decreases({clause})")
    for clause in _clean_clause_list(contract_plan.get("loop_assigns_clauses")):
        lines.append(f"{indent}__CPROVER_assigns({clause})")
    for clause in _clean_clause_list(contract_plan.get("loop_frees_clauses")):
        lines.append(f"{indent}__CPROVER_frees({clause})")
    return "\n".join(lines)


def apply_contract_source_patches(
    contract_plan: Mapping[str, Any],
    *,
    project_root: Path,
    output_dir: Path,
    allowed_source_paths: Iterable[Path],
    allowed_source_roots: Iterable[Path] = (),
) -> Tuple[List[Path], JsonDict, str]:
    """Insert reviewed loop clauses into copied implementation files.

    ``allowed_source_roots`` exists for controlled test fixtures; production
    agents pass exact configured implementation paths.  No unrestricted source
    rewrite operation is supported.
    """
    validation = validate_contract_plan(contract_plan, "native_loop_contract" if str(contract_plan.get("contract_mode")) == "loop" else "hybrid_contract_and_harness")
    if not validation.get("valid"):
        raise ValueError("Invalid contract plan: " + "; ".join(validation.get("errors", [])))

    output_dir = output_dir.expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    allowed_exact = {Path(p).expanduser().resolve() for p in allowed_source_paths}
    allowed_roots = [Path(p).expanduser().resolve() for p in allowed_source_roots]
    operations = list(contract_plan.get("source_patch_operations") or [])
    grouped: Dict[Path, List[Mapping[str, Any]]] = {}
    for operation in operations:
        source = Path(str(operation["target_source_path"])).expanduser()
        if not source.is_absolute():
            source = project_root / source
        source = source.resolve()
        if source not in allowed_exact and not _is_within(source, allowed_roots):
            raise PermissionError(f"Contract patch target is outside approved implementation evidence: {source}")
        if source.suffix.lower() not in {".c", ".h"}:
            raise ValueError(f"Contract patch target must be a configured C/header file: {source}")
        grouped.setdefault(source, []).append(operation)

    rendered: List[Path] = []
    records: List[JsonDict] = []
    all_diff: List[str] = []

    for source, source_operations in grouped.items():
        if not source.is_file():
            raise FileNotFoundError(f"Contract patch source is missing: {source}")
        original = source.read_text(encoding="utf-8", errors="strict")
        original_hash_before = sha256_file(source)
        modified = original
        op_records: List[JsonDict] = []
        for operation in source_operations:
            expected = str(operation["expected_original"])
            expected_count = int(operation["expected_occurrences"])
            actual_count = modified.count(expected)
            if actual_count != expected_count:
                raise ValueError(
                    f"Contract patch {operation['patch_id']} expected {expected_count} occurrence(s) "
                    f"in {source}, found {actual_count}."
                )
            start = modified.index(expected)
            line_start = modified.rfind("\n", 0, start) + 1
            prefix = modified[line_start:start]
            # The exact anchor may itself include indentation and therefore begin
            # at the physical line start. Preserve that indentation explicitly.
            anchor_indent_match = re.match(r"[ \t]*", expected)
            anchor_indent = anchor_indent_match.group(0) if anchor_indent_match else ""
            indent = prefix if prefix.strip() == "" and prefix else anchor_indent
            annotation_block = _render_loop_annotation_block(contract_plan, indent=indent)
            if not annotation_block:
                raise ValueError("Loop annotation insertion requested but no loop contract clauses were rendered.")
            expected_trimmed = expected.rstrip()
            if expected_trimmed.endswith("{"):
                loop_header = expected_trimmed[:-1].rstrip()
                replacement = loop_header + "\n" + annotation_block + "\n" + indent + "{"
            else:
                replacement = expected_trimmed + "\n" + annotation_block
            modified = modified.replace(expected, replacement, expected_count)
            op_records.append({
                "patch_id": operation["patch_id"],
                "operation_kind": "insert_loop_contract_after_guard",
                "purpose": operation["purpose"],
                "expected_occurrences": expected_count,
                "actual_occurrences": actual_count,
                "expected_original_sha256": hashlib.sha256(expected.encode()).hexdigest(),
                "replacement_sha256": hashlib.sha256(replacement.encode()).hexdigest(),
                "requires_human_review": bool(operation.get("requires_human_review", True)),
            })

        destination = output_dir / source.name
        if destination.exists():
            destination = output_dir / f"{source.stem}_{hashlib.sha256(str(source).encode()).hexdigest()[:10]}{source.suffix}"
        destination.write_text(modified, encoding="utf-8")
        if sha256_file(source) != original_hash_before:
            raise RuntimeError(f"Production source changed during contract rendering: {source}")
        try:
            destination.resolve().relative_to(output_dir)
        except ValueError as exc:
            raise RuntimeError("Rendered contract copy escaped the controlled output directory.") from exc
        rendered.append(destination)
        diff_lines = list(difflib.unified_diff(
            original.splitlines(), modified.splitlines(),
            fromfile=str(source), tofile=str(destination), lineterm=""
        ))
        all_diff.extend(diff_lines)
        records.append({
            "original_path": str(source),
            "instrumented_copy_path": str(destination),
            "original_sha256": original_hash_before,
            "original_sha256_after_render": sha256_file(source),
            "instrumented_sha256": sha256_file(destination),
            "operation_count": len(op_records),
            "operations": op_records,
            "production_source_modified": False,
        })

    manifest = {
        "schema_version": "contract_instrumentation_manifest.v3.annotation_only",
        "contract_mode": contract_plan.get("contract_mode"),
        "instrumented_source_count": len(rendered),
        "source_records": records,
        "production_source_modified": False,
        "allowed_source_policy": "configured_implementation_inputs_only",
        "transformation_policy": "exact_single_anchor_loop_annotation_insertion_no_loop_body_rewrite",
        "trust_boundary": (
            "Generated files are candidate instrumented copies for formal-tool review. "
            "They do not change the repository and do not prove contract correctness."
        ),
    }
    return rendered, manifest, "\n".join(all_diff) + ("\n" if all_diff else "")


def build_contract_header(
    contract_plan: Mapping[str, Any], *, required_includes: Sequence[str] = ()
) -> str:
    """Render a standalone declaration carrying a native CBMC function contract.

    Required includes are rendered before the declaration because this header is
    passed to goto-cc with ``-include`` and may otherwise appear before the
    implementation's own include directives.
    """
    if not bool(contract_plan.get("enabled")):
        return ""
    mode = str(contract_plan.get("contract_mode") or "")
    if mode not in FUNCTION_MODES:
        return ""
    declaration = str(contract_plan.get("function_declaration") or "").strip().rstrip(";")
    if not declaration:
        return ""
    lines = ["/* Candidate CBMC function contract — generated for review; not proof. */"]
    for raw_include in required_includes:
        include = str(raw_include).strip()
        if not include:
            continue
        if "\n" in include or "\r" in include:
            raise ValueError("Contract required include contains a newline.")
        if include.startswith("#include"):
            lines.append(include)
        elif include.startswith("<") or include.startswith('"'):
            lines.append(f"#include {include}")
        else:
            lines.append(f'#include "{include}"')
    lines.append(declaration)
    for clause in _clean_clause_list(contract_plan.get("requires_clauses")):
        lines.append(f"__CPROVER_requires({clause})")
    for clause in _clean_clause_list(contract_plan.get("ensures_clauses")):
        lines.append(f"__CPROVER_ensures({clause})")
    for clause in _clean_clause_list(contract_plan.get("assigns_clauses")):
        lines.append(f"__CPROVER_assigns({clause})")
    for clause in _clean_clause_list(contract_plan.get("frees_clauses")):
        lines.append(f"__CPROVER_frees({clause})")
    lines.append(";")
    return "\n".join(lines) + "\n"


def validate_relational_plan(relational_plan: Mapping[str, Any], strategy: str) -> JsonDict:
    """Validate two-call/round-trip/determinism planning without claiming equivalence."""
    errors: List[str] = []
    warnings: List[str] = []
    enabled = bool(relational_plan.get("enabled"))
    requires_relational = strategy == "relational_cbmc_harness"
    if requires_relational and not enabled:
        errors.append("relational_cbmc_harness requires relational_plan.enabled=true.")
    if not requires_relational and enabled:
        warnings.append(f"relational_plan.enabled=true is unusual for strategy {strategy}.")
    if not enabled:
        return {"valid": not errors, "errors": errors, "warnings": warnings, "enabled": False}

    kind = str(relational_plan.get("relation_kind") or "").strip()
    first = str(relational_plan.get("first_call") or "").strip()
    second = str(relational_plan.get("second_call") or "").strip()
    assertions = _clean_clause_list(relational_plan.get("relation_assertions"))
    reset = _clean_clause_list(relational_plan.get("state_reset_or_snapshot"))
    if not kind or kind == "none":
        errors.append("Enabled relational plan requires a specific relation_kind.")
    if not first or not second:
        errors.append("Enabled relational plan requires both first_call and second_call descriptions.")
    if not assertions:
        errors.append("Enabled relational plan requires at least one relation assertion.")
    if not reset:
        warnings.append("Relational plan has no explicit state reset/snapshot step; Agent 6 must assess hidden state risk.")
    for index, assertion in enumerate(assertions):
        if assertion.lower() in {"true", "1", "(true)", "(1)"}:
            errors.append(f"Relational assertion {index} is trivial.")
        if _looks_side_effecting(assertion):
            errors.append(f"Relational assertion {index} appears side-effecting.")
    return {"valid": not errors, "errors": errors, "warnings": warnings, "enabled": True}


def validate_analysis_only_plan(analysis_plan: Mapping[str, Any], strategy: str) -> JsonDict:
    """Validate an explicitly non-formal property campaign such as P19."""
    errors: List[str] = []
    warnings: List[str] = []
    enabled = bool(analysis_plan.get("enabled"))
    requires_analysis = strategy == "analysis_only_no_formal_claim"
    if requires_analysis and not enabled:
        errors.append("analysis_only_no_formal_claim requires analysis_only_plan.enabled=true.")
    if not requires_analysis and enabled:
        warnings.append(f"analysis_only_plan.enabled=true is unusual for strategy {strategy}.")
    if not enabled:
        return {"valid": not errors, "errors": errors, "warnings": warnings, "enabled": False}
    if not bool(analysis_plan.get("formal_claim_prohibited")):
        errors.append("Analysis-only campaigns must set formal_claim_prohibited=true.")
    kind = str(analysis_plan.get("analysis_kind") or "").strip()
    if not kind or kind == "none":
        errors.append("Enabled analysis-only plan requires analysis_kind.")
    evidence = _clean_clause_list(analysis_plan.get("evidence_to_collect"))
    if not evidence:
        errors.append("Enabled analysis-only plan requires evidence_to_collect.")
    external = _clean_clause_list(analysis_plan.get("external_tools_or_tests"))
    if not external:
        warnings.append("No external/manual validation method is listed for the analysis-only campaign.")
    return {"valid": not errors, "errors": errors, "warnings": warnings, "enabled": True}


def validate_strategy_specific_plans(artifact_plan: Mapping[str, Any], strategy: str) -> JsonDict:
    contract = artifact_plan.get("contract_plan", {}) if isinstance(artifact_plan.get("contract_plan"), Mapping) else {}
    relational = artifact_plan.get("relational_plan", {}) if isinstance(artifact_plan.get("relational_plan"), Mapping) else {}
    analysis = artifact_plan.get("analysis_only_plan", {}) if isinstance(artifact_plan.get("analysis_only_plan"), Mapping) else {}
    contract_result = validate_contract_plan(contract, strategy)
    relational_result = validate_relational_plan(relational, strategy)
    analysis_result = validate_analysis_only_plan(analysis, strategy)
    errors = [
        *[f"contract: {x}" for x in contract_result.get("errors", [])],
        *[f"relational: {x}" for x in relational_result.get("errors", [])],
        *[f"analysis_only: {x}" for x in analysis_result.get("errors", [])],
    ]
    warnings = [
        *[f"contract: {x}" for x in contract_result.get("warnings", [])],
        *[f"relational: {x}" for x in relational_result.get("warnings", [])],
        *[f"analysis_only: {x}" for x in analysis_result.get("warnings", [])],
    ]
    return {
        "valid": not errors,
        "verification_strategy": strategy,
        "contract_plan": contract_result,
        "relational_plan": relational_result,
        "analysis_only_plan": analysis_result,
        "errors": errors,
        "warnings": warnings,
    }
