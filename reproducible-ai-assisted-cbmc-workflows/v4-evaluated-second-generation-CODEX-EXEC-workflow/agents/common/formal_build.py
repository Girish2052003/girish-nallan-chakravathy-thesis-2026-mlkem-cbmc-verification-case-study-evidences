"""Canonical formal-build plan for Agent 6 review and Agent 7 execution."""
from __future__ import annotations

import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Union

from agents.common.contract_artifacts import CONTRACT_STRATEGIES, validate_contract_plan
from agents.common.exact_traceability import build_traceability_record, exact_property_coverage
from agents.common.semantic_property import normalize_semantic_property

PathLike = Union[str, Path]
JsonDict = Dict[str, Any]

HARNESS_COMPLETE_CLAIM_KINDS = {"harness_assertion", "cbmc_builtin", "relational_assertion"}
CONTRACT_DEPENDENT_CLAIM_KINDS = {"contract_ensures", "loop_invariant", "loop_decreases"}



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



def sha256_json(value: Mapping[str, Any]) -> str:
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def reconcile_execution_strategy(
    config: Mapping[str, Any],
    *,
    requested_strategy: str,
    artifact_plan: Mapping[str, Any],
    contract_plan_validation: Mapping[str, Any],
    harness_text: str = "",
    target_function: Optional[str] = None,
) -> JsonDict:
    """Apply only an explicit, evidence-bound user reconciliation policy.

    Agent 5 is the strategy author for open discovery.  The deterministic engine
    no longer rewrites that strategy because of category words or family defaults.
    Optional contract-to-harness fallback remains user-controlled and is allowed
    only when exact traceability proves every selected claim is implemented in the
    harness and the semantic record does not require modular contract semantics.
    """
    policy = config.get("formal_strategy_reconciliation", {}) if isinstance(config.get("formal_strategy_reconciliation"), Mapping) else {}
    mode = str(policy.get("mode") or "no_silent_reconciliation")
    allow_fallback = bool(policy.get("allow_optional_contract_to_harness_fallback", False))
    explicit_fallback = bool(policy.get("request_optional_contract_to_harness_fallback", False))
    trace = artifact_plan.get("traceability_manifest", {}) if isinstance(artifact_plan.get("traceability_manifest"), Mapping) else {}
    selected = artifact_plan.get("selected_property") if isinstance(artifact_plan.get("selected_property"), Mapping) else {}
    prop = selected.get("property") if isinstance(selected.get("property"), Mapping) else {}
    semantic_source = artifact_plan.get("semantic_property") if isinstance(artifact_plan.get("semantic_property"), Mapping) else prop
    semantic = normalize_semantic_property(semantic_source, target_function=target_function or "")
    property_id = str(semantic.get("property_id") or trace.get("selected_property_id") or "")
    claim_map = [dict(x) for x in trace.get("claim_map", []) if isinstance(x, Mapping)] if isinstance(trace.get("claim_map"), list) else []
    harness_claim_ids = [
        str(row.get("assertion_id") or "") for row in claim_map
        if str(row.get("implementation_kind") or "") in {"harness_assertion", "relational_assertion"}
    ]
    assumption_map = [dict(x) for x in trace.get("assumption_map", []) if isinstance(x, Mapping)] if isinstance(trace.get("assumption_map"), list) else []
    harness_assumption_ids = [
        str(row.get("assumption_id") or "") for row in assumption_map
        if str(row.get("implementation_kind") or "") == "harness_assume"
    ]
    exact = build_traceability_record(
        harness_text=harness_text,
        target_function=str(target_function or semantic.get("target_call", {}).get("function") or ""),
        property_id=property_id,
        claim_ids=[x for x in harness_claim_ids if x],
        assumption_ids=[x for x in harness_assumption_ids if x],
    ) if harness_text and property_id and (target_function or semantic.get("target_call", {}).get("function")) else {"valid": False, "errors": ["Exact traceability unavailable."]}
    expected = trace.get("expected_claim_count")
    expected_count = expected if isinstance(expected, int) and not isinstance(expected, bool) else len(claim_map)
    only_harness_claims = bool(claim_map) and all(
        str(row.get("implementation_kind") or "") in HARNESS_COMPLETE_CLAIM_KINDS for row in claim_map
    )
    harness_complete = bool(exact.get("valid")) and only_harness_claims and len(claim_map) == expected_count and expected_count > 0
    contract_required = bool(semantic.get("requires_modular_call_replacement")) or any(
        str(row.get("implementation_kind") or "") in CONTRACT_DEPENDENT_CLAIM_KINDS for row in claim_map
    )
    effective = requested_strategy
    applied = False
    fallback_conditions = allow_fallback and explicit_fallback and harness_complete and not contract_required
    reason = "Agent 5 selected strategy retained; deterministic substitution is prohibited."
    if requested_strategy in CONTRACT_STRATEGIES and fallback_conditions:
        effective = "standard_cbmc_harness"
        applied = True
        reason = "User explicitly requested optional-contract fallback and exact traceability proves the complete selected claim exists in the harness."
    elif explicit_fallback and not fallback_conditions:
        reason = "Requested fallback was not applied because exact harness completeness or semantic non-dependence was not established."
    return {
        "schema_version": "formal_strategy_reconciliation.v2.explicit",
        "mode": mode,
        "requested_verification_strategy": requested_strategy,
        "effective_execution_strategy": effective,
        "strategy_reconciliation_applied": applied,
        "reconciliation_reason": reason,
        "selection_authority": str((artifact_plan.get("strategy_selection") or {}).get("selection_authority") or "agent5"),
        "selected_claim_ids": [str(x.get("assertion_id") or "") for x in claim_map],
        "exact_harness_traceability": exact,
        "expected_claim_count": expected_count,
        "harness_complete": harness_complete,
        "contract_required_for_selected_claim": contract_required,
        "contract_valid": bool(contract_plan_validation.get("valid")),
        "fallback_conditions_satisfied": fallback_conditions,
        "allow_optional_contract_to_harness_fallback": allow_fallback,
        "explicit_fallback_requested": explicit_fallback,
        "contract_dependent_downgrade_forbidden": True,
        "evidence_strength_reduced": False,
        "silent_strategy_substitution_performed": False,
    }


def _goto_compile_command(binary: str, plan: Mapping[str, Any], output_model: Path) -> List[str]:
    cmd: List[str] = [binary, "-o", str(output_model)]
    cmd.extend(str(x) for x in plan.get("extra_goto_cc_args", []) if isinstance(plan.get("extra_goto_cc_args"), list))
    harness = plan.get("harness", {}) if isinstance(plan.get("harness"), Mapping) else {}
    seen: set[str] = set()
    for record in [harness] + list(plan.get("source_units", [])) + list(plan.get("stub_units", [])):
        if isinstance(record, Mapping) and record.get("path"):
            path = str(record["path"])
            if path not in seen:
                seen.add(path)
                cmd.append(path)
    for record in plan.get("include_paths", []) if isinstance(plan.get("include_paths"), list) else []:
        if isinstance(record, Mapping) and record.get("path"):
            cmd.extend(["-I", str(record["path"])])
    for record in plan.get("forced_include_headers", []) if isinstance(plan.get("forced_include_headers"), list) else []:
        if isinstance(record, Mapping) and record.get("path"):
            cmd.extend(["-include", str(record["path"])])
    for define in plan.get("defines", []) if isinstance(plan.get("defines"), list) else []:
        cmd.extend(["-D", str(define)])
    return cmd


def build_frontend_readiness_command(
    plan: Mapping[str, Any], *, output_dir: PathLike, cbmc_binary: str = "cbmc", goto_cc_binary: str = "goto-cc"
) -> JsonDict:
    output = Path(output_dir).expanduser().resolve()
    output.mkdir(parents=True, exist_ok=True)
    profile = plan.get("execution_profile", {}) if isinstance(plan.get("execution_profile"), Mapping) else {}
    mode = str(profile.get("mode") or "direct_cbmc")
    if mode == "analysis_only":
        return {"tool": None, "command": [], "output_model": None, "route": mode}
    model = output / "frontend_readiness_model.gb"
    return {
        "tool": "goto-cc",
        "command": _goto_compile_command(goto_cc_binary, plan, model),
        "output_model": str(model),
        "route": mode,
    }


def _host_c_syntax_command(plan: Mapping[str, Any], binary: str) -> List[str]:
    cmd: List[str] = [binary, "-fsyntax-only", "-Wno-implicit-function-declaration"]
    harness = plan.get("harness", {}) if isinstance(plan.get("harness"), Mapping) else {}
    seen: set[str] = set()
    for record in [harness] + list(plan.get("source_units", [])) + list(plan.get("stub_units", [])):
        if isinstance(record, Mapping) and record.get("path"):
            path = str(record["path"])
            if path not in seen:
                seen.add(path)
                cmd.append(path)
    for record in plan.get("include_paths", []) if isinstance(plan.get("include_paths"), list) else []:
        if isinstance(record, Mapping) and record.get("path"):
            cmd.extend(["-I", str(record["path"])])
    for record in plan.get("forced_include_headers", []) if isinstance(plan.get("forced_include_headers"), list) else []:
        if isinstance(record, Mapping) and record.get("path"):
            cmd.extend(["-include", str(record["path"])])
    for define in plan.get("defines", []) if isinstance(plan.get("defines"), list) else []:
        cmd.extend(["-D", str(define)])
    return cmd


def _resolve_command(command: Sequence[str]) -> Optional[List[str]]:
    if not command:
        return []
    binary = str(command[0])
    resolved = binary if Path(binary).is_file() else shutil.which(binary)
    if not resolved:
        return None
    return [str(Path(resolved).resolve()), *[str(x) for x in command[1:]]]


def _parse_property_listing(stdout: str) -> JsonDict:
    try:
        payload = json.loads(stdout)
    except Exception:
        payload = None
    rows: List[JsonDict] = []
    def walk(value: Any) -> None:
        if isinstance(value, Mapping):
            if any(key in value for key in ("property", "property_id", "description")):
                rows.append(dict(value))
            for child in value.values():
                walk(child)
        elif isinstance(value, list):
            for child in value:
                walk(child)
    if payload is not None:
        walk(payload)
    return {
        "structured_json_parsed": payload is not None,
        "property_rows": rows,
        "property_count": len(rows),
        "stdout_sha256": hashlib.sha256(stdout.encode("utf-8", errors="replace")).hexdigest(),
    }


def _readiness_staged_fields(
    plan: Mapping[str, Any],
    *,
    frontend_parse_valid: Optional[bool],
    goto_transformation_valid: Optional[bool],
    selected_claim_generated: Optional[bool],
    execution_ready: bool,
) -> JsonDict:
    validation = plan.get("validation", {}) if isinstance(plan.get("validation"), Mapping) else {}
    artifacts = plan.get("contract_artifacts", {}) if isinstance(plan.get("contract_artifacts"), Mapping) else {}
    contract_validation = artifacts.get("contract_plan_validation", {}) if isinstance(artifacts.get("contract_plan_validation"), Mapping) else {}
    staged = contract_validation.get("staged_validity", {}) if isinstance(contract_validation.get("staged_validity"), Mapping) else {}
    return {
        "schema_valid": True,
        "semantic_binding_valid": bool(validation.get("valid", False)),
        "clause_lexically_valid": staged.get("clause_lexically_valid"),
        "frontend_parse_valid": frontend_parse_valid,
        "goto_transformation_valid": goto_transformation_valid,
        "selected_claim_generated": selected_claim_generated,
        "execution_ready": execution_ready,
    }


def _readiness_record(
    plan: Mapping[str, Any],
    semantic_hash: str,
    bindings: Mapping[str, Any],
    steps: Sequence[Mapping[str, Any]],
    *,
    attempted: bool,
    staged: Mapping[str, Any],
    **extra: Any,
) -> JsonDict:
    record: JsonDict = {
        "schema_version": "route_readiness.v2",
        "attempted": attempted,
        **dict(staged),
        "formal_property_evaluated": False,
        "formal_build_plan_semantic_sha256": semantic_hash,
        "input_bindings": dict(bindings),
        "steps": [dict(row) for row in steps],
    }
    if steps:
        record["stdout"] = "\n".join(str(row.get("stdout") or "") for row in steps)
        record["stderr"] = "\n".join(str(row.get("stderr") or "") for row in steps)
    record.update(extra)
    return record


def run_route_readiness_check(
    plan: Mapping[str, Any],
    *,
    output_dir: PathLike,
    cbmc_binary: str = "cbmc",
    goto_cc_binary: str = "goto-cc",
    goto_instrument_binary: str = "goto-instrument",
    timeout_seconds: int = 120,
    working_directory: Optional[PathLike] = None,
    require_cbmc_frontend: bool = False,
    require_full_route: bool = False,
) -> JsonDict:
    """Execute the exact route through non-solving property generation/listing."""
    output = Path(output_dir).expanduser().resolve()
    output.mkdir(parents=True, exist_ok=True)
    semantic_hash = sha256_json(plan)
    profile = plan.get("execution_profile", {}) if isinstance(plan.get("execution_profile"), Mapping) else {}
    mode = str(profile.get("mode") or "direct_cbmc")
    bindings = {
        "harness": plan.get("harness"),
        "source_units": plan.get("source_units", []),
        "stub_units": plan.get("stub_units", []),
        "forced_include_headers": plan.get("forced_include_headers", []),
    }
    if mode == "analysis_only":
        return _readiness_record(
            plan, semantic_hash, bindings, [], attempted=False,
            staged=_readiness_staged_fields(
                plan, frontend_parse_valid=None, goto_transformation_valid=None,
                selected_claim_generated=False, execution_ready=False,
            ),
            frontend_parse_and_build_ready=True, full_route_ready=True,
            analysis_only=True, analysis_stage_execution_ready=True,
            blocks_tool_execution=False,
        )

    model = output / "01_frontend_model.gb"
    compile_cmd = _goto_compile_command(goto_cc_binary, plan, model)
    resolved_compile = _resolve_command(compile_cmd)
    fallback_used = False
    if resolved_compile is None and mode == "direct_cbmc" and not require_cbmc_frontend:
        host = shutil.which("cc") or shutil.which("clang") or shutil.which("gcc")
        if host:
            fallback_used = True
            resolved_compile = _host_c_syntax_command(plan, host)
    if resolved_compile is None:
        return _readiness_record(
            plan, semantic_hash, bindings,
            [{"step_id": "goto_compile", "command": compile_cmd, "available": False}],
            attempted=False,
            staged=_readiness_staged_fields(
                plan, frontend_parse_valid=False, goto_transformation_valid=False,
                selected_claim_generated=False, execution_ready=False,
            ),
            tool_available=False, frontend_parse_and_build_ready=False,
            full_route_ready=False, classification="hard_frontend_tool_unavailable",
            blocks_tool_execution=True, require_cbmc_frontend=require_cbmc_frontend,
            require_full_route=require_full_route,
        )
    cwd = Path(working_directory or plan.get("working_directory") or Path.cwd()).expanduser().resolve()
    steps: List[JsonDict] = []
    current_model: Optional[Path] = model if not fallback_used else None

    def execute(step_id: str, tool: str, command: Sequence[str], expected_output: Optional[Path] = None) -> bool:
        resolved = _resolve_command(command)
        if resolved is None:
            steps.append({"step_id": step_id, "tool": tool, "command": list(command), "available": False, "ready": False})
            return False
        try:
            proc = subprocess.run(resolved, cwd=cwd, text=True, capture_output=True, timeout=timeout_seconds, check=False)
            ready = proc.returncode == 0 and (expected_output is None or expected_output.is_file())
            steps.append({
                "step_id": step_id,
                "tool": tool,
                "command": resolved,
                "command_sha256": hashlib.sha256("\0".join(resolved).encode()).hexdigest(),
                "exit_code": proc.returncode,
                "ready": ready,
                "stdout": proc.stdout,
                "stderr": proc.stderr,
                "expected_output": str(expected_output) if expected_output else None,
                "expected_output_sha256": sha256_file(expected_output) if ready and expected_output and expected_output.is_file() else None,
            })
            return ready
        except subprocess.TimeoutExpired as exc:
            steps.append({
                "step_id": step_id, "tool": tool, "command": resolved,
                "exit_code": None, "ready": False, "timed_out": True,
                "stdout": exc.stdout or "", "stderr": exc.stderr or "",
            })
            return False

    compile_ready = execute(
        "host_c_syntax_fallback" if fallback_used else "goto_compile",
        "host-c" if fallback_used else "goto-cc",
        resolved_compile,
        None if fallback_used else model,
    )
    if not compile_ready:
        return _readiness_record(
            plan, semantic_hash, bindings, steps, attempted=True,
            staged=_readiness_staged_fields(
                plan, frontend_parse_valid=False, goto_transformation_valid=False,
                selected_claim_generated=False, execution_ready=False,
            ),
            frontend_parse_and_build_ready=False, full_route_ready=False,
            classification="hard_frontend_parse_or_build_defect",
            frontend_authority=(
                "host_c_syntax_fallback_not_cbmc_frontend" if fallback_used else "cbmc_goto_frontend"
            ),
            cbmc_frontend_confirmed=False, fallback_used=fallback_used,
            blocks_tool_execution=True,
        )
    if fallback_used:
        authoritative = not require_cbmc_frontend and not require_full_route
        return _readiness_record(
            plan, semantic_hash, bindings, steps, attempted=True,
            staged=_readiness_staged_fields(
                plan, frontend_parse_valid=True, goto_transformation_valid=False,
                selected_claim_generated=False, execution_ready=authoritative,
            ),
            frontend_parse_and_build_ready=authoritative, full_route_ready=False,
            classification="reduced_host_c_syntax_only",
            frontend_authority="host_c_syntax_fallback_not_cbmc_frontend",
            cbmc_frontend_confirmed=False, fallback_used=True,
            blocks_tool_execution=not authoritative,
        )

    # Apply every configured transformation, but do not run the solver.
    if mode == "goto_contract_pipeline":
        counter = 1
        if bool(profile.get("apply_loop_contracts")):
            counter += 1
            nxt = output / f"{counter:02d}_loop_contracts.gb"
            cmd = [goto_instrument_binary, *[str(x) for x in plan.get("extra_goto_instrument_args", [])], "--apply-loop-contracts", str(current_model), str(nxt)]
            if not execute("apply_loop_contracts", "goto-instrument", cmd, nxt):
                current_model = nxt
                return _failed_route_record(plan, semantic_hash, bindings, steps, "hard_loop_contract_transformation_defect")
            current_model = nxt
        enforce = bool(profile.get("enforce_contract"))
        replacements = [str(x) for x in profile.get("replace_calls_with_contract", [])] if isinstance(profile.get("replace_calls_with_contract"), list) else []
        if enforce or replacements:
            counter += 1
            nxt = output / f"{counter:02d}_function_contracts.gb"
            cmd: List[str] = [goto_instrument_binary, *[str(x) for x in plan.get("extra_goto_instrument_args", [])]]
            if bool(profile.get("use_dfcc")):
                cmd.extend(["--dfcc", str(profile.get("dfcc_harness") or plan.get("cbmc_function") or "harness")])
            if enforce:
                symbol = str(profile.get("enforce_contract_symbol") or "").strip()
                if not symbol:
                    return _failed_route_record(plan, semantic_hash, bindings, steps, "hard_missing_contract_enforcement_symbol")
                cmd.extend(["--enforce-contract", symbol])
            for symbol in replacements:
                cmd.extend(["--replace-call-with-contract", symbol])
            cmd.extend([str(current_model), str(nxt)])
            if not execute("apply_function_contracts", "goto-instrument", cmd, nxt):
                return _failed_route_record(plan, semantic_hash, bindings, steps, "hard_function_contract_transformation_defect")
            current_model = nxt

    listing_cmd = [cbmc_binary, str(current_model)]
    entry = str(profile.get("analysis_entry_function") or plan.get("cbmc_function") or "")
    if entry:
        listing_cmd.extend(["--function", entry])
    listing_cmd.extend(str(x) for x in plan.get("readiness_cbmc_args", []) if isinstance(plan.get("readiness_cbmc_args"), list))
    unwind = plan.get("unwind")
    if unwind is not None:
        listing_cmd.extend(["--unwind", str(unwind), "--unwinding-assertions"])
    listing_cmd.extend(str(x) for x in plan.get("extra_cbmc_args", []) if isinstance(plan.get("extra_cbmc_args"), list))
    listing_cmd.extend(["--show-properties", "--json-ui"])
    listing_ready = execute("list_generated_properties", "cbmc", listing_cmd)
    property_listing = _parse_property_listing(str(steps[-1].get("stdout") or "")) if steps else {}
    expectations = plan.get("selected_claim_expectations", []) if isinstance(plan.get("selected_claim_expectations"), list) else []
    selected_coverage = exact_property_coverage(expectations, property_listing.get("property_rows", []))
    listing_structured = bool(property_listing.get("structured_json_parsed"))
    claim_generation_ready = bool(selected_coverage.get("coverage_complete"))
    full_ready = listing_ready and listing_structured and claim_generation_ready
    if require_full_route:
        ready = full_ready
    else:
        ready = listing_ready and (claim_generation_ready if expectations else True)
    classification = "full_route_ready"
    if not listing_ready or not listing_structured:
        classification = "hard_property_listing_or_route_defect"
    elif not expectations:
        classification = "hard_missing_selected_claim_expectation"
        ready = False
        full_ready = False
    elif not claim_generation_ready:
        classification = "hard_selected_claim_not_generated_or_ambiguous"
    transformation_ready = all(
        bool(row.get("ready"))
        for row in steps
        if row.get("step_id") not in {"goto_compile", "list_generated_properties"}
    )
    return _readiness_record(
        plan, semantic_hash, bindings, steps, attempted=True,
        staged=_readiness_staged_fields(
            plan, frontend_parse_valid=compile_ready,
            goto_transformation_valid=transformation_ready,
            selected_claim_generated=claim_generation_ready, execution_ready=ready,
        ),
        frontend_parse_and_build_ready=compile_ready,
        goto_transformation_ready=transformation_ready,
        selected_claim_coverage=selected_coverage, full_route_ready=full_ready,
        classification=classification, frontend_authority="cbmc_goto_frontend",
        cbmc_frontend_confirmed=True, fallback_used=False,
        blocks_tool_execution=not ready, property_listing=property_listing,
        claim_boundary=(
            "Readiness confirms parsing, transformations and property generation only; "
            "no property was solved."
        ),
    )



def _failed_route_record(
    plan: Mapping[str, Any], semantic_hash: str, bindings: Mapping[str, Any], steps: Sequence[Mapping[str, Any]], classification: str
) -> JsonDict:
    return _readiness_record(
        plan, semantic_hash, bindings, steps, attempted=True,
        staged=_readiness_staged_fields(
            plan, frontend_parse_valid=True, goto_transformation_valid=False,
            selected_claim_generated=False, execution_ready=False,
        ),
        frontend_parse_and_build_ready=True, full_route_ready=False,
        classification=classification, blocks_tool_execution=True,
    )



def run_frontend_readiness_check(
    plan: Mapping[str, Any],
    *,
    output_dir: PathLike,
    cbmc_binary: str = "cbmc",
    goto_cc_binary: str = "goto-cc",
    goto_instrument_binary: str = "goto-instrument",
    timeout_seconds: int = 120,
    working_directory: Optional[PathLike] = None,
    require_cbmc_frontend: bool = False,
    require_full_route: bool = False,
) -> JsonDict:
    """Backward-compatible name for the route-specific non-solving gate."""
    return run_route_readiness_check(
        plan,
        output_dir=output_dir,
        cbmc_binary=cbmc_binary,
        goto_cc_binary=goto_cc_binary,
        goto_instrument_binary=goto_instrument_binary,
        timeout_seconds=timeout_seconds,
        working_directory=working_directory,
        require_cbmc_frontend=require_cbmc_frontend,
        require_full_route=require_full_route,
    )


def _contract_replacement_map(contract_summary: Mapping[str, Any], enabled: bool) -> Dict[str, Path]:
    replacement_map: Dict[str, Path] = {}
    manifest_path = contract_summary.get("contract_instrumentation_manifest") if enabled else None
    if not manifest_path:
        return replacement_map
    path = Path(str(manifest_path)).expanduser().resolve()
    if not path.is_file():
        return replacement_map
    content = json.loads(path.read_text(encoding="utf-8"))
    for record in content.get("source_records", []) if isinstance(content, Mapping) else []:
        if isinstance(record, Mapping) and record.get("original_path") and record.get("instrumented_copy_path"):
            replacement_map[str(Path(str(record["original_path"])).resolve())] = Path(str(record["instrumented_copy_path"])).resolve()
    return replacement_map


def _merge_contract_validation(
    validation: Mapping[str, Any], reconciliation: Mapping[str, Any], enabled: bool,
    errors: List[str], warnings: List[str],
) -> None:
    contract_errors = [str(x) for x in validation.get("errors", [])]
    if enabled or bool(reconciliation.get("contract_required_for_selected_claim")):
        errors.extend(f"Contract-plan validation: {err}" for err in contract_errors)
    elif contract_errors:
        warnings.append("Optional native contract was excluded by evidence-bound harness routing: " + "; ".join(contract_errors))
    warnings.extend(f"Contract-plan validation: {warning}" for warning in validation.get("warnings", []))


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
    trace_manifest = plan_obj.get("traceability_manifest", {}) if isinstance(plan_obj.get("traceability_manifest"), Mapping) else {}
    selected_property_id = str(trace_manifest.get("selected_property_id") or "")
    selected_claim_expectations: List[JsonDict] = []
    for row in trace_manifest.get("claim_map", []) if isinstance(trace_manifest.get("claim_map"), list) else []:
        if not isinstance(row, Mapping):
            continue
        claim_id = str(row.get("assertion_id") or "").strip()
        identity = str(row.get("expected_property_identity") or "").strip()
        if not identity and selected_property_id and claim_id:
            identity = f"TRACE_CLAIM::{selected_property_id}::{claim_id}"
        selected_claim_expectations.append({
            "property_id": selected_property_id,
            "claim_id": claim_id,
            "identity": identity,
            "implementation_kind": str(row.get("implementation_kind") or ""),
            "expression_sha256": str(row.get("expression_sha256") or ""),
            "code_marker": str(row.get("code_marker") or ""),
        })
    strategy = str(plan_obj.get("verification_strategy") or campaign.get("verification_strategy") or "standard_cbmc_harness")
    contract_plan = plan_obj.get("contract_plan", {}) if isinstance(plan_obj.get("contract_plan"), Mapping) else {}
    contract_summary = manifest_obj.get("contract_summary", {}) if isinstance(manifest_obj.get("contract_summary"), Mapping) else {}
    formal_policy = config.get("formal_artifact_policy", {}) if isinstance(config.get("formal_artifact_policy"), Mapping) else {}
    strict_typed = bool(formal_policy.get("require_typed_contract_clauses", False))
    contract_plan_validation = validate_contract_plan(contract_plan, strategy, strict_typed=strict_typed)
    harness_text = harness.read_text(encoding="utf-8", errors="replace") if harness.is_file() else ""
    reconciliation = reconcile_execution_strategy(
        config, requested_strategy=strategy, artifact_plan=plan_obj,
        contract_plan_validation=contract_plan_validation, harness_text=harness_text,
        target_function=target_function,
    )
    effective_strategy = str(reconciliation["effective_execution_strategy"])
    contract_execution_enabled = effective_strategy in CONTRACT_STRATEGIES

    explicit_source_key_present = "source_files" in te or "source_units" in te
    explicit_source_value = te.get("source_files") if "source_files" in te else te.get("source_units")
    explicit_sources = _list(explicit_source_value)
    source_selection_authority = "tool_execution.explicit_source_files"
    if explicit_source_key_present:
        # An explicit empty list is meaningful: it declares that the harness is
        # intentionally self-contained.  Do not reinterpret it as permission to
        # infer unrelated translation units from inputs.code_paths.
        source_paths = _paths(explicit_sources, project_root)
    else:
        code_values = _list(inputs.get("code_paths")) + _list(inputs.get("source_files"))
        source_paths = [p for p in _paths(code_values, project_root) if p.suffix.lower() == ".c"]
        source_selection_authority = "inputs.code_paths_legacy_inference"

    # Contract-instrumented copies replace their exact original source units for this run only.
    replacement_map = _contract_replacement_map(contract_summary, contract_execution_enabled)
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
    contract_header_path = contract_summary.get("contract_header") if contract_execution_enabled else None
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
    if source_selection_authority != "tool_execution.explicit_source_files":
        if str(te.get("execution_mode") or "reviewed") == "reviewed" and bool(formal_policy.get("require_explicit_source_units", True)):
            errors.append("Reviewed execution requires explicit tool_execution.source_files; source-unit inference is prohibited.")
        else:
            warnings.append("Source units were inferred from inputs.code_paths under an explicit reduced/manual policy.")
    if not source_records:
        warnings.append(
            "No implementation .c source unit is configured. This is acceptable only when the harness "
            "intentionally includes/defines the implementation or the target is otherwise self-contained."
        )

    _merge_contract_validation(
        contract_plan_validation, reconciliation, contract_execution_enabled, errors, warnings
    )
    contract_mode = str(contract_plan.get("contract_mode") or "none") if contract_execution_enabled else "none"
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
        "schema_version": "formal_build_plan.v3.strategy_reconciled_readiness_bound",
        "trust_boundary": "deterministic_build_configuration_reviewed_before_execution",
        "target_function": target_function,
        "property_family_id": campaign.get("property_family_id"),
        "verification_strategy": strategy,
        "requested_verification_strategy": strategy,
        "effective_execution_strategy": effective_strategy,
        "strategy_reconciliation": reconciliation,
        "harness": harness_record,
        "source_units": source_records,
        "source_selection_authority": source_selection_authority,
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
        "execution_mode": str(te.get("execution_mode") or "reviewed"),
        "selected_property_id": selected_property_id,
        "selected_claim_expectations": selected_claim_expectations,
        "argument_provenance": {
            "extra_cbmc_args": [{"argument": value, "source": "tool_execution.extra_cbmc_args", "position": index} for index, value in enumerate(extra_args)],
            "extra_goto_cc_args": [{"argument": value, "source": "tool_execution.extra_goto_cc_args", "position": index} for index, value in enumerate(extra_goto_cc_args)],
            "extra_goto_instrument_args": [{"argument": value, "source": "tool_execution.extra_goto_instrument_args", "position": index} for index, value in enumerate(extra_goto_instrument_args)],
        },
        "execution_profile": {
            "mode": (
                "analysis_only" if effective_strategy == "analysis_only_no_formal_claim" else
                "goto_contract_pipeline" if effective_strategy in CONTRACT_STRATEGIES else
                "direct_cbmc"
            ),
            "goto_cc_binary": str(te.get("goto_cc_binary") or "goto-cc"),
            "goto_instrument_binary": str(te.get("goto_instrument_binary") or "goto-instrument"),
            "apply_loop_contracts": bool(contract_plan.get("apply_loop_contracts")) if contract_execution_enabled else False,
            "enforce_contract": bool(contract_plan.get("enforce_contract")) if contract_execution_enabled else False,
            "enforce_contract_symbol": enforce_symbol,
            "replace_calls_with_contract": list(contract_plan.get("replace_calls_with_contract") or []) if contract_execution_enabled else [],
            "use_dfcc": use_dfcc if contract_execution_enabled else False,
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


def _validate_plan_file_bindings(plan: Mapping[str, Any], errors: List[str]) -> None:
    """Re-hash every execution input so Agent 7 cannot execute a post-review mutation."""
    groups = (("source_units", "Implementation source"), ("stub_units", "Stub source"),
              ("forced_include_headers", "Forced include header"))
    for group, label in groups:
        records = plan.get(group, []) if isinstance(plan.get(group), list) else []
        for record in records:
            if not isinstance(record, Mapping) or not record.get("path"):
                errors.append(f"{label} record is malformed in the formal-build plan.")
                continue
            path = Path(str(record["path"])).expanduser().resolve()
            if not path.is_file():
                errors.append(f"{label} is missing at execution time: {path}")
                continue
            expected = str(record.get("sha256") or "")
            if expected and sha256_file(path) != expected:
                errors.append(f"{label} checksum differs from the reviewed formal-build plan: {path}")
    include_records = plan.get("include_paths", []) if isinstance(plan.get("include_paths"), list) else []
    for record in include_records:
        path = Path(str(record.get("path") or "")).expanduser().resolve() if isinstance(record, Mapping) else Path()
        if not path.is_dir():
            errors.append(f"Include directory is missing at execution time: {path}")


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
    _validate_plan_file_bindings(plan, errors)
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
    compile_cmd = _goto_compile_command(goto_cc_binary, plan, model_current)
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
