"""Canonical formal-build plan for Agent 6 review and Agent 7 execution."""
from __future__ import annotations

import hashlib
import re
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Union

from agents.common.contract_artifacts import validate_contract_plan

PathLike = Union[str, Path]
JsonDict = Dict[str, Any]


def sha256_file(path: PathLike) -> str:
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return list(value)
    if isinstance(value, tuple):
        return list(value)
    return [value]


def _paths(values: Iterable[Any], project_root: Path) -> List[Path]:
    out: List[Path] = []
    seen = set()
    for value in values:
        if value is None or str(value).strip() == "":
            continue
        p = Path(str(value)).expanduser()
        if not p.is_absolute():
            p = project_root / p
        p = p.resolve()
        if str(p) in seen:
            continue
        seen.add(str(p))
        out.append(p)
    return out


def _file_record(path: Path) -> JsonDict:
    return {
        "path": str(path),
        "exists": path.exists(),
        "is_file": path.is_file(),
        "sha256": sha256_file(path) if path.is_file() else None,
        "size_bytes": path.stat().st_size if path.is_file() else None,
    }


def _dir_record(path: Path) -> JsonDict:
    return {"path": str(path), "exists": path.exists(), "is_dir": path.is_dir()}


def create_formal_build_plan(
    config: Mapping[str, Any],
    harness_path: PathLike,
    *,
    target_function: Optional[str] = None,
    artifact_plan: Optional[Mapping[str, Any]] = None,
    artifact_manifest: Optional[Mapping[str, Any]] = None,
) -> JsonDict:
    project_root = Path(str(config.get("project_root") or Path.cwd())).expanduser().resolve()
    inputs = config.get("inputs", {}) if isinstance(config.get("inputs"), Mapping) else {}
    te = config.get("tool_execution", {}) if isinstance(config.get("tool_execution"), Mapping) else {}

    harness = Path(harness_path).expanduser().resolve()
    campaign = config.get("property_campaign", {}) if isinstance(config.get("property_campaign"), Mapping) else {}
    plan_obj = artifact_plan if isinstance(artifact_plan, Mapping) else {}
    manifest_obj = artifact_manifest if isinstance(artifact_manifest, Mapping) else {}
    strategy = str(plan_obj.get("verification_strategy") or campaign.get("verification_strategy") or "standard_cbmc_harness")
    contract_plan = plan_obj.get("contract_plan", {}) if isinstance(plan_obj.get("contract_plan"), Mapping) else {}
    contract_summary = manifest_obj.get("contract_summary", {}) if isinstance(manifest_obj.get("contract_summary"), Mapping) else {}
    contract_plan_validation = validate_contract_plan(contract_plan, strategy)

    explicit_sources = _list(te.get("source_files") or te.get("source_units"))
    if explicit_sources:
        source_paths = _paths(explicit_sources, project_root)
    else:
        code_values = _list(inputs.get("code_paths")) + _list(inputs.get("source_files"))
        source_paths = [p for p in _paths(code_values, project_root) if p.suffix.lower() == ".c"]

    # Contract-instrumented copies replace their exact original source units for this run only.
    replacement_map: Dict[str, Path] = {}
    contract_manifest_path = contract_summary.get("contract_instrumentation_manifest")
    if contract_manifest_path:
        cm_path = Path(str(contract_manifest_path)).expanduser().resolve()
        if cm_path.is_file():
            import json
            cm = json.loads(cm_path.read_text(encoding="utf-8"))
            for record in cm.get("source_records", []) if isinstance(cm, Mapping) else []:
                if isinstance(record, Mapping) and record.get("original_path") and record.get("instrumented_copy_path"):
                    replacement_map[str(Path(str(record["original_path"])).resolve())] = Path(str(record["instrumented_copy_path"])).resolve()
    source_paths = [replacement_map.get(str(p.resolve()), p) for p in source_paths]

    stub_paths = _paths(_list(te.get("stub_files") or te.get("stubs")), project_root)

    include_values = _list(te.get("include_paths") or te.get("include_dirs"))
    code_dir = inputs.get("code_dir")
    if code_dir:
        include_values.append(code_dir)
    # Header parents are valid default include candidates.
    for p in _paths(_list(inputs.get("code_paths")), project_root):
        if p.suffix.lower() in {".h", ".inc"}:
            include_values.append(str(p.parent))
    include_paths = _paths(include_values, project_root)

    defines_raw = te.get("defines") or te.get("preprocessor_defines") or []
    defines: List[str] = []
    if isinstance(defines_raw, Mapping):
        for key, value in defines_raw.items():
            defines.append(str(key) if value is None or value is True or value == "" else f"{key}={value}")
    else:
        defines = [str(v) for v in _list(defines_raw) if str(v).strip()]

    working_value = te.get("working_directory") or project_root
    working_directory = _paths([working_value], project_root)[0]

    source_records = [_file_record(p) for p in source_paths]
    stub_records = [_file_record(p) for p in stub_paths]
    include_records = [_dir_record(p) for p in include_paths]
    harness_record = _file_record(harness)
    contract_header_path = contract_summary.get("contract_header")
    forced_include_headers = []
    if contract_header_path:
        forced_include_headers.append(_file_record(Path(str(contract_header_path)).expanduser().resolve()))

    errors: List[str] = []
    warnings: List[str] = []
    if not harness_record["is_file"]:
        errors.append(f"Harness is missing or not a regular file: {harness}")
    for record in source_records:
        if not record["is_file"]:
            errors.append(f"Implementation source is missing: {record['path']}")
    for record in stub_records:
        if not record["is_file"]:
            errors.append(f"Stub source is missing: {record['path']}")
    for record in include_records:
        if not record["is_dir"]:
            errors.append(f"Include directory is missing: {record['path']}")
    for record in forced_include_headers:
        if not record["is_file"]:
            errors.append(f"Forced contract header is missing: {record['path']}")
    if not working_directory.is_dir():
        errors.append(f"Formal-build working directory is missing: {working_directory}")
    if not source_records:
        warnings.append(
            "No implementation .c source unit is configured. This is acceptable only when the harness "
            "intentionally includes/defines the implementation or the target is otherwise self-contained."
        )

    for err in contract_plan_validation.get("errors", []):
        errors.append(f"Contract-plan validation: {err}")
    for warning in contract_plan_validation.get("warnings", []):
        warnings.append(f"Contract-plan validation: {warning}")
    contract_mode = str(contract_plan.get("contract_mode") or "none")
    if contract_mode in {"loop", "loop_and_function"} and not replacement_map:
        errors.append("Loop-contract execution requires at least one rendered instrumented source copy.")
    if contract_mode in {"function", "loop_and_function"} and not forced_include_headers:
        errors.append("Function-contract execution requires the generated forced-include contract header.")

    extra_args = [str(v) for v in _list(te.get("extra_cbmc_args") or te.get("cbmc_args"))]
    extra_goto_cc_args = [str(v) for v in _list(te.get("extra_goto_cc_args"))]
    extra_goto_instrument_args = [str(v) for v in _list(te.get("extra_goto_instrument_args"))]
    function_name = str(te.get("cbmc_function") or target_function or "harness")
    enforce_symbol = str(contract_plan.get("target_symbol") or target_function or "")
    use_dfcc = bool(contract_plan.get("use_dfcc"))
    analysis_entry_function = enforce_symbol if bool(contract_plan.get("enforce_contract")) and not use_dfcc else function_name

    return {
        "schema_version": "formal_build_plan.v2.property_contracts",
        "trust_boundary": "deterministic_build_configuration_reviewed_before_execution",
        "target_function": target_function,
        "property_family_id": campaign.get("property_family_id"),
        "verification_strategy": strategy,
        "harness": harness_record,
        "source_units": source_records,
        "stub_units": stub_records,
        "include_paths": include_records,
        "forced_include_headers": forced_include_headers,
        "defines": defines,
        "working_directory": str(working_directory),
        "cbmc_function": function_name,
        "unwind": te.get("unwind"),
        "extra_cbmc_args": extra_args,
        "extra_goto_cc_args": extra_goto_cc_args,
        "extra_goto_instrument_args": extra_goto_instrument_args,
        "execution_profile": {
            "mode": (
                "analysis_only" if strategy == "analysis_only_no_formal_claim" else
                "goto_contract_pipeline" if strategy in {"native_loop_contract", "native_function_contract", "hybrid_contract_and_harness"} else
                "direct_cbmc"
            ),
            "goto_cc_binary": str(te.get("goto_cc_binary") or "goto-cc"),
            "goto_instrument_binary": str(te.get("goto_instrument_binary") or "goto-instrument"),
            "apply_loop_contracts": bool(contract_plan.get("apply_loop_contracts")),
            "enforce_contract": bool(contract_plan.get("enforce_contract")),
            "enforce_contract_symbol": enforce_symbol,
            "replace_calls_with_contract": list(contract_plan.get("replace_calls_with_contract") or []),
            "use_dfcc": use_dfcc,
            "dfcc_harness": function_name,
            "analysis_entry_function": analysis_entry_function,
            "contract_mode": contract_mode,
            "intermediate_models_must_be_hashed": True,
        },
        "contract_artifacts": {
            "contract_summary": dict(contract_summary),
            "contract_plan_validation": dict(contract_plan_validation),
            "repository_source_modified": False,
            "instrumented_copy_count": len(replacement_map),
        },
        "validation": {
            "valid": not errors,
            "error_count": len(errors),
            "warning_count": len(warnings),
            "errors": errors,
            "warnings": warnings,
        },
        "claim_boundary": {
            "build_plan_review_does_not_prove_property": True,
            "cbmc_result_remains_property_and_configuration_specific": True,
        },
    }


def _strip_c_comments_and_literals(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", " ", text)
    text = re.sub(r'"(?:\\.|[^"\\])*"', '""', text)
    text = re.sub(r"'(?:\\.|[^'\\])*'", "''", text)
    return text


def _extract_function_body(code: str, function_name: str) -> Optional[str]:
    match = re.search(
        rf"\bvoid\s+{re.escape(function_name)}\s*\(\s*void\s*\)\s*\{{",
        code,
    )
    if not match:
        return None
    opening = code.find("{", match.start())
    depth = 0
    for index in range(opening, len(code)):
        char = code[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return code[opening + 1:index]
    return None


def _null_freshness_pointer_names(text: str) -> List[str]:
    names = sorted({
        match.group(1)
        for match in re.finditer(
            r"\b[A-Za-z_]\w*\s*\*\s*([A-Za-z_]\w*)\s*=\s*(?:0|NULL)\s*;",
            text,
        )
    })
    bad: List[str] = []
    for name in names:
        if re.search(
            rf"\b(?:memory_no_alias|__CPROVER_is_fresh)\s*\(\s*{re.escape(name)}\b",
            text,
        ):
            bad.append(name)
    return bad


def validate_formal_build_plan(
    plan: Mapping[str, Any],
    harness_path: PathLike,
    *,
    expected_cbmc_function: Optional[str] = None,
    expected_target_function: Optional[str] = None,
) -> JsonDict:
    """Bind the reviewed harness to the deterministic execution plan.

    In addition to path/hash binding, reject the exact live defects observed in
    Run 001: a renamed/missing entry function, a missing target call, and a null
    pointer followed by a freshness assumption.
    """
    errors: List[str] = []
    warnings: List[str] = []
    structural_checks: JsonDict = {}
    harness = Path(harness_path).expanduser().resolve()
    plan_harness = plan.get("harness", {}) if isinstance(plan.get("harness"), Mapping) else {}
    recorded_path = Path(str(plan_harness.get("path") or "")).expanduser()
    if recorded_path and recorded_path.resolve() != harness:
        errors.append(
            f"Formal-build harness path differs from reviewed artifact: {recorded_path.resolve()} != {harness}"
        )

    harness_text = ""
    if not harness.is_file():
        errors.append(f"Reviewed harness is missing: {harness}")
    else:
        recorded_hash = plan_harness.get("sha256")
        actual_hash = sha256_file(harness)
        if recorded_hash and recorded_hash != actual_hash:
            errors.append("Formal-build harness checksum differs from the reviewed artifact checksum.")
        harness_text = harness.read_text(encoding="utf-8", errors="replace")

    planned_entry = str(plan.get("cbmc_function") or "").strip()
    entry = str(expected_cbmc_function or planned_entry).strip()
    if expected_cbmc_function and planned_entry and planned_entry != expected_cbmc_function:
        errors.append(
            f"Formal-build cbmc_function differs from execution configuration: {planned_entry} != {expected_cbmc_function}"
        )
    if not entry:
        errors.append("Formal-build plan does not identify a CBMC entry function.")

    planned_target = str(plan.get("target_function") or "").strip()
    target = str(expected_target_function or planned_target).strip()
    if expected_target_function and planned_target and planned_target != expected_target_function:
        errors.append(
            f"Formal-build target_function differs from execution configuration: {planned_target} != {expected_target_function}"
        )
    if not target:
        warnings.append("Formal-build plan does not record target_function; exact target-call binding could not be established.")

    if harness_text:
        code = _strip_c_comments_and_literals(harness_text)
        entry_body = _extract_function_body(code, entry) if entry else None
        entry_defined = entry_body is not None
        target_called = bool(
            target
            and entry_body is not None
            and re.search(rf"\b{re.escape(target)}\s*\(", entry_body)
        )
        null_freshness = _null_freshness_pointer_names(code)
        structural_checks = {
            "configured_entry_function": entry,
            "entry_function_defined": entry_defined,
            "target_function": target or None,
            "target_function_called": target_called if target else None,
            "null_freshness_pointers": null_freshness,
            "known_run001_vacuity_pattern_absent": not null_freshness,
            "general_semantic_non_vacuity_proved": False,
        }
        if entry and not entry_defined:
            errors.append(f"Reviewed harness does not define exact CBMC entry: void {entry}(void).")
        if target and not target_called:
            errors.append(f"Reviewed harness does not call the configured target function: {target}.")
        if null_freshness:
            errors.append(
                "Reviewed harness contains null-initialized pointer(s) used with freshness assumptions: "
                + ", ".join(null_freshness)
            )

    plan_validation = plan.get("validation", {}) if isinstance(plan.get("validation"), Mapping) else {}
    for err in plan_validation.get("errors", []) if isinstance(plan_validation.get("errors"), list) else []:
        errors.append(str(err))
    return {
        "valid": not errors,
        "errors": errors,
        "warnings": warnings,
        "structural_checks": structural_checks,
        "claim_boundary": {
            "known_run001_structural_vacuity_pattern_rejected": True,
            "arbitrary_assumption_consistency_proved": False,
            "cbmc_execution_still_required": True,
        },
    }


def build_cbmc_command_from_plan(
    binary: str,
    plan: Mapping[str, Any],
    *,
    default_checks: Sequence[str],
    unwind_override: Optional[int] = None,
    extra_args: Sequence[str] = (),
) -> List[str]:
    harness = plan.get("harness", {}) if isinstance(plan.get("harness"), Mapping) else {}
    cmd = [binary, str(harness.get("path"))]
    for group in ("source_units", "stub_units"):
        records = plan.get(group, []) if isinstance(plan.get(group), list) else []
        for record in records:
            if isinstance(record, Mapping) and record.get("path"):
                path = str(record["path"])
                if path not in cmd:
                    cmd.append(path)
    for record in plan.get("include_paths", []) if isinstance(plan.get("include_paths"), list) else []:
        if isinstance(record, Mapping) and record.get("path"):
            cmd.extend(["-I", str(record["path"])])
    for record in plan.get("forced_include_headers", []) if isinstance(plan.get("forced_include_headers"), list) else []:
        if isinstance(record, Mapping) and record.get("path"):
            cmd.extend(["-include", str(record["path"])])
    for define in plan.get("defines", []) if isinstance(plan.get("defines"), list) else []:
        cmd.extend(["-D", str(define)])
    function_name = str(plan.get("cbmc_function") or "")
    if function_name:
        cmd.extend(["--function", function_name])
    cmd.extend(str(x) for x in default_checks)
    unwind = unwind_override if unwind_override is not None else plan.get("unwind")
    if unwind is not None:
        cmd.extend(["--unwind", str(unwind), "--unwinding-assertions"])
    cmd.extend(str(x) for x in plan.get("extra_cbmc_args", []) if isinstance(plan.get("extra_cbmc_args"), list))
    cmd.extend(str(x) for x in extra_args)
    return cmd


def build_tool_pipeline_from_plan(
    plan: Mapping[str, Any],
    *,
    output_dir: PathLike,
    cbmc_binary: str = "cbmc",
    goto_cc_binary: str = "goto-cc",
    goto_instrument_binary: str = "goto-instrument",
    default_checks: Sequence[str] = (),
    unwind_override: Optional[int] = None,
    extra_args: Sequence[str] = (),
) -> List[JsonDict]:
    """Build an auditable direct-CBMC or native-contract command pipeline.

    Loop and function transformations are deliberately separate.  The official
    CBMC interface documents ``--apply-loop-contracts`` for loop transformation
    and ``--dfcc <harness>``/``--enforce-contract`` for dynamic-frame function
    contracts.  A combined campaign therefore produces sequential GOTO models
    rather than relying on an undocumented one-command combination.
    """
    output = Path(output_dir).expanduser().resolve()
    output.mkdir(parents=True, exist_ok=True)
    profile = plan.get("execution_profile", {}) if isinstance(plan.get("execution_profile"), Mapping) else {}
    mode = str(profile.get("mode") or "direct_cbmc")
    if mode == "analysis_only":
        return []
    if mode == "direct_cbmc":
        return [{
            "step_id": "cbmc_direct",
            "tool": "cbmc",
            "command": build_cbmc_command_from_plan(
                cbmc_binary, plan, default_checks=default_checks,
                unwind_override=unwind_override, extra_args=extra_args
            ),
            "input_model": None,
            "output_model": None,
            "authoritative_result_step": True,
        }]

    model_counter = 1
    model_current = output / f"{model_counter:02d}_compiled_model.gb"
    compile_cmd: List[str] = [goto_cc_binary, "-o", str(model_current)]
    compile_cmd.extend(str(x) for x in plan.get("extra_goto_cc_args", []) if isinstance(plan.get("extra_goto_cc_args"), list))
    harness = plan.get("harness", {}) if isinstance(plan.get("harness"), Mapping) else {}
    seen_sources: set[str] = set()
    for record in [harness] + list(plan.get("source_units", [])) + list(plan.get("stub_units", [])):
        if isinstance(record, Mapping) and record.get("path"):
            path = str(record["path"])
            if path not in seen_sources:
                seen_sources.add(path)
                compile_cmd.append(path)
    for record in plan.get("include_paths", []) if isinstance(plan.get("include_paths"), list) else []:
        if isinstance(record, Mapping) and record.get("path"):
            compile_cmd.extend(["-I", str(record["path"])])
    for record in plan.get("forced_include_headers", []) if isinstance(plan.get("forced_include_headers"), list) else []:
        if isinstance(record, Mapping) and record.get("path"):
            compile_cmd.extend(["-include", str(record["path"])])
    for define in plan.get("defines", []) if isinstance(plan.get("defines"), list) else []:
        compile_cmd.extend(["-D", str(define)])
    # Compile the complete selected translation units into a GOTO model.
    # The code-contract CLI selects the DFCC harness at the goto-instrument
    # transformation step and selects the analysis entry at the final CBMC step;
    # do not pass CBMC's --function option to goto-cc.

    steps: List[JsonDict] = [{
        "step_id": "goto_compile",
        "tool": "goto-cc",
        "command": compile_cmd,
        "input_model": None,
        "output_model": str(model_current),
        "authoritative_result_step": False,
    }]

    if bool(profile.get("apply_loop_contracts")):
        model_counter += 1
        model_next = output / f"{model_counter:02d}_loop_contracts_applied.gb"
        cmd = [goto_instrument_binary]
        cmd.extend(str(x) for x in plan.get("extra_goto_instrument_args", []) if isinstance(plan.get("extra_goto_instrument_args"), list))
        cmd.extend(["--apply-loop-contracts", str(model_current), str(model_next)])
        steps.append({
            "step_id": "apply_loop_contracts",
            "tool": "goto-instrument",
            "command": cmd,
            "input_model": str(model_current),
            "output_model": str(model_next),
            "authoritative_result_step": False,
        })
        model_current = model_next

    enforce = bool(profile.get("enforce_contract"))
    replacements = [str(x) for x in profile.get("replace_calls_with_contract", [])] if isinstance(profile.get("replace_calls_with_contract"), list) else []
    if enforce or replacements:
        model_counter += 1
        model_next = output / f"{model_counter:02d}_function_contracts_applied.gb"
        cmd = [goto_instrument_binary]
        cmd.extend(str(x) for x in plan.get("extra_goto_instrument_args", []) if isinstance(plan.get("extra_goto_instrument_args"), list))
        if bool(profile.get("use_dfcc")):
            cmd.extend(["--dfcc", str(profile.get("dfcc_harness") or plan.get("cbmc_function") or "harness")])
        if enforce:
            symbol = str(profile.get("enforce_contract_symbol") or "").strip()
            if not symbol:
                raise ValueError("Function contract enforcement requested without enforce_contract_symbol.")
            cmd.extend(["--enforce-contract", symbol])
        for symbol in replacements:
            cmd.extend(["--replace-call-with-contract", symbol])
        cmd.extend([str(model_current), str(model_next)])
        steps.append({
            "step_id": "apply_function_contracts",
            "tool": "goto-instrument",
            "command": cmd,
            "input_model": str(model_current),
            "output_model": str(model_next),
            "authoritative_result_step": False,
        })
        model_current = model_next

    if len(steps) == 1:
        raise ValueError("goto_contract_pipeline selected but no loop/function contract transformation was configured.")

    cbmc_cmd: List[str] = [cbmc_binary, str(model_current)]
    function_name = str(profile.get("analysis_entry_function") or plan.get("cbmc_function") or "")
    if function_name:
        cbmc_cmd.extend(["--function", function_name])
    cbmc_cmd.extend(str(x) for x in default_checks)
    unwind = unwind_override if unwind_override is not None else plan.get("unwind")
    if unwind is not None:
        cbmc_cmd.extend(["--unwind", str(unwind), "--unwinding-assertions"])
    cbmc_cmd.extend(str(x) for x in plan.get("extra_cbmc_args", []) if isinstance(plan.get("extra_cbmc_args"), list))
    cbmc_cmd.extend(str(x) for x in extra_args)
    steps.append({
        "step_id": "cbmc_contract_check",
        "tool": "cbmc",
        "command": cbmc_cmd,
        "input_model": str(model_current),
        "output_model": None,
        "authoritative_result_step": True,
    })
    return steps
