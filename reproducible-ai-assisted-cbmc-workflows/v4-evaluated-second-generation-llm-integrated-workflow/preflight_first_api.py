#!/usr/bin/env python3
"""Fail-closed local preflight and explicitly authorised live API probe."""
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, Mapping, Sequence

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

try:
    from openai import OpenAI
except ImportError:  # local-only preflight remains network-free and import-tolerant
    OpenAI = None  # type: ignore[assignment]

from agents.common.config_contract import (  # noqa: E402
    ConfigContractError,
    load_normalized_config,
    resolve_run_dir_from_config,
    validate_pipeline_config,
)
from agents.common.experiment_protocol import prompt_budget, semantic_advisory_mode  # noqa: E402
from agents.common.workspace_mode import normalise_workspace_mode  # noqa: E402
from agents.common.llm_client import (  # noqa: E402
    LLMClientConfig,
    build_openai_client_kwargs,
    build_responses_api_input,
    build_responses_control_payload,
    build_primary_evidence_transmission_manifest,
    enforce_primary_evidence_completeness,
    summarise_responses_api_input,
)

PLACEHOLDER_MARKERS = (
    "SET_TO_", "REPLACE_WITH_", "YOUR_", "CHANGEME", "PLACEHOLDER",
)


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def atomic_write_json(path: Path, value: Mapping[str, Any]) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(dict(value), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    os.replace(tmp, path)
    return path


def run_text(
    command: list[str],
    *,
    cwd: Path | None = None,
    timeout: int = 30,
) -> tuple[int, str]:
    try:
        proc = subprocess.run(
            command,
            cwd=str(cwd) if cwd else None,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
            check=False,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        return 1, str(exc)
    return proc.returncode, proc.stdout.strip()


def has_placeholder(value: Any) -> bool:
    if isinstance(value, str):
        upper = value.upper()
        return any(marker in upper for marker in PLACEHOLDER_MARKERS)
    if isinstance(value, Mapping):
        return any(has_placeholder(v) for v in value.values())
    if isinstance(value, list):
        return any(has_placeholder(v) for v in value)
    return False


def resolve_path(value: Any, project_root: Path) -> Path:
    path = Path(str(value)).expanduser()
    if not path.is_absolute():
        path = project_root / path
    return path.resolve()


def collect_preflight_primary_evidence(
    config: Mapping[str, Any], project_root: Path
) -> list[Path]:
    """Collect the configured specification/code evidence used by live stages.

    code_dir is expanded conservatively to the source/header/include extensions
    used by the workflow, so the live preflight tests a production-sized input
    rather than only a tiny connectivity prompt.
    """
    inputs = config.get("inputs", {}) if isinstance(config.get("inputs"), Mapping) else {}
    values: list[Any] = []
    for key in ("spec_paths", "code_paths"):
        configured = inputs.get(key, [])
        if isinstance(configured, list):
            values.extend(configured)

    code_dir_value = inputs.get("code_dir")
    if code_dir_value:
        code_dir = resolve_path(code_dir_value, project_root)
        if code_dir.is_dir():
            allowed = {".c", ".h", ".inc", ".s", ".S"}
            values.extend(
                path for path in sorted(code_dir.rglob("*"))
                if path.is_file() and path.suffix in allowed
            )

    result: list[Path] = []
    seen: set[str] = set()
    for value in values:
        path = resolve_path(value, project_root)
        key = str(path)
        if key not in seen:
            seen.add(key)
            result.append(path)
    return result


def _usage_mapping(value: Any) -> dict[str, Any]:
    dumped = _model_dump(value)
    return dict(dumped) if isinstance(dumped, Mapping) else {"value": dumped}


def _model_dump(value: Any) -> Any:
    if value is None:
        return None
    if hasattr(value, "model_dump"):
        try:
            return value.model_dump()
        except Exception:
            pass
    if isinstance(value, (dict, list, str, int, float, bool)):
        return value
    return str(value)


def check_live_api_access(
    llm: Mapping[str, Any],
    *,
    primary_evidence_files: Sequence[Path] = (),
    client_factory: Callable[..., Any] | None = None,
) -> dict[str, Any]:
    """Probe the exact model/controls with complete configured primary evidence.

    The preflight uses the same shared Responses input builder as runtime and
    changes only the output-token cap.  Provider acceptance establishes that
    this concrete preflight input fits the selected model.  Exact later-stage
    requests are checked again immediately before every runtime API call.
    """
    cfg = LLMClientConfig.from_mapping(llm)
    model = cfg.model.strip()
    key_env = cfg.api_key_env.strip()
    api_key = os.environ.get(key_env, "").strip()
    if not api_key:
        raise RuntimeError(f"API credential environment variable {key_env} is empty.")

    evidence_manifest = build_primary_evidence_transmission_manifest(
        primary_evidence_files,
        config=cfg,
    )
    if cfg.fail_on_primary_evidence_truncation:
        enforce_primary_evidence_completeness(evidence_manifest)

    api_input = build_responses_api_input(
        """Operational preflight only. Do not analyse or summarise the supplied thesis evidence.
Confirm that this complete input was accepted by replying with the single word READY.""",
        primary_evidence_files,
        config=cfg,
    )
    input_summary = summarise_responses_api_input(api_input)
    if input_summary.get("contains_primary_truncation_marker"):
        raise RuntimeError("A primary-evidence truncation marker reached the preflight API input.")

    factory = client_factory or OpenAI
    if factory is None:
        raise RuntimeError("The pinned openai package is required only for --live-api-probe.")
    client = factory(**build_openai_client_kwargs(cfg, api_key))
    request_payload: dict[str, Any] = {
        "model": model,
        "input": api_input,
    }
    request_payload.update(
        build_responses_control_payload(
            cfg,
            max_output_tokens_override=cfg.preflight_max_output_tokens,
        )
    )
    response = client.responses.create(**request_payload)

    status = str(getattr(response, "status", "") or "unknown")
    error = _model_dump(getattr(response, "error", None))
    if status.lower() in {"failed", "cancelled"} or error:
        raise RuntimeError(f"Responses API returned status={status!r}, error={error!r}")

    usage = _usage_mapping(getattr(response, "usage", None))
    input_tokens = usage.get("input_tokens")
    return {
        "performed": True,
        "purpose": "complete_configured_primary_evidence_and_model_control_probe",
        "model_requested": model,
        "model_reported": getattr(response, "model", None),
        "resolved_controls": {
            "reasoning_mode": cfg.reasoning_mode,
            "reasoning_effort": cfg.reasoning_effort,
            "reasoning_summary": cfg.reasoning_summary,
            "text_verbosity": cfg.text_verbosity,
            "store": cfg.store,
            "preflight_max_output_tokens": cfg.preflight_max_output_tokens,
            "max_inline_file_chars": cfg.max_inline_file_chars,
            "fail_on_primary_evidence_truncation": cfg.fail_on_primary_evidence_truncation,
        },
        "response_id": getattr(response, "id", None),
        "status": status,
        "usage": usage,
        "input_token_check": {
            "provider_accepted_exact_preflight_input": True,
            "provider_reported_input_tokens": input_tokens,
            "note": (
                "Provider acceptance proves this concrete preflight input fit the selected model. "
                "Every later exact stage request is independently checked at runtime."
            ),
        },
        "primary_evidence_transmission": evidence_manifest,
        "exact_input_summary": input_summary,
        "thesis_evidence_sent": bool(primary_evidence_files),
        "semantic_quality_established": False,
        "later_stage_context_fit_established": False,
        "secret_logged": False,
    }


def check_live_cbmc_smoke(binary_path: Path) -> dict[str, Any]:
    """Execute a tiny passing C assertion through the real CBMC binary."""
    with tempfile.TemporaryDirectory(prefix="cbmc_live_preflight_") as td:
        tmp = Path(td)
        smoke = tmp / "cbmc_smoke.c"
        smoke.write_text(
            "#include <assert.h>\n"
            "int main(void) {\n"
            "  int x = 0;\n"
            "  assert(x == 0);\n"
            "  return 0;\n"
            "}\n",
            encoding="utf-8",
        )
        command = [
            str(binary_path), str(smoke),
            "--function", "main",
            "--bounds-check", "--pointer-check", "--signed-overflow-check",
            "--unwinding-assertions",
        ]
        rc, output = run_text(command, cwd=tmp, timeout=45)
        success_marker = "VERIFICATION SUCCESSFUL" in output.upper()
        if rc != 0 or not success_marker:
            tail = "\n".join(output.splitlines()[-30:])
            raise RuntimeError(
                "CBMC smoke verification did not report success. "
                f"exit_code={rc}; output_tail={tail!r}"
            )
        return {
            "performed": True,
            "purpose": "real_cbmc_execution_smoke_only",
            "binary": str(binary_path),
            "command": command,
            "exit_code": rc,
            "verification_success_marker_seen": True,
            "target_repository_checked": False,
            "selected_thesis_property_checked": False,
        }


def check_live_loop_contract_toolchain_smoke(
    *, goto_cc_path: Path, goto_instrument_path: Path, cbmc_path: Path
) -> dict[str, Any]:
    """Run a tiny native loop-contract pipeline through the real GOTO tools."""
    with tempfile.TemporaryDirectory(prefix="cbmc_contract_preflight_") as td:
        tmp = Path(td)
        source = tmp / "loop_contract_smoke.c"
        source.write_text(
            "#include <assert.h>\n"
            "void harness(void) {\n"
            "  int i = 0;\n"
            "  while (i < 3)\n"
            "  __CPROVER_loop_invariant(0 <= i && i <= 3)\n"
            "  __CPROVER_decreases(3 - i)\n"
            "  { ++i; }\n"
            "  assert(i == 3);\n"
            "}\n",
            encoding="utf-8",
        )
        model = tmp / "model.gb"
        instrumented = tmp / "instrumented.gb"
        commands = [
            [str(goto_cc_path), "-o", str(model), str(source)],
            [str(goto_instrument_path), "--apply-loop-contracts", str(model), str(instrumented)],
            [str(cbmc_path), str(instrumented), "--function", "harness", "--bounds-check", "--pointer-check"],
        ]
        outputs: list[dict[str, Any]] = []
        for command in commands:
            rc, output = run_text(command, cwd=tmp, timeout=45)
            outputs.append({"command": command, "exit_code": rc, "output_tail": "\n".join(output.splitlines()[-20:])})
            if rc != 0:
                raise RuntimeError(f"Native contract smoke step failed: {command}; output={output[-2000:]!r}")
        if "VERIFICATION SUCCESSFUL" not in outputs[-1]["output_tail"].upper():
            raise RuntimeError("Native contract smoke did not report VERIFICATION SUCCESSFUL.")
        return {
            "performed": True,
            "purpose": "native_loop_contract_toolchain_smoke_only",
            "commands": commands,
            "steps": outputs,
            "selected_thesis_property_checked": False,
        }


def check_live_function_contract_toolchain_smoke(
    *, goto_cc_path: Path, goto_instrument_path: Path, cbmc_path: Path
) -> dict[str, Any]:
    """Run a tiny function-contract/DFCC pipeline through the real GOTO tools."""
    with tempfile.TemporaryDirectory(prefix="cbmc_function_contract_preflight_") as td:
        tmp = Path(td)
        source = tmp / "function_contract_smoke.c"
        source.write_text(
            "#include <assert.h>\n"
            "int increment(int x)\n"
            "__CPROVER_requires(x < 100)\n"
            "__CPROVER_ensures(__CPROVER_return_value == x + 1)\n"
            "{ return x + 1; }\n"
            "void harness(void) {\n"
            "  int x;\n"
            "  __CPROVER_assume(x < 100);\n"
            "  int y = increment(x);\n"
            "  assert(y == x + 1);\n"
            "}\n",
            encoding="utf-8",
        )
        model = tmp / "model.gb"
        instrumented = tmp / "instrumented.gb"
        commands = [
            [str(goto_cc_path), "-o", str(model), str(source)],
            [
                str(goto_instrument_path),
                "--dfcc", "harness",
                "--enforce-contract", "increment",
                str(model), str(instrumented),
            ],
            [str(cbmc_path), str(instrumented), "--function", "harness", "--bounds-check", "--pointer-check"],
        ]
        outputs: list[dict[str, Any]] = []
        for command in commands:
            rc, output = run_text(command, cwd=tmp, timeout=45)
            outputs.append({"command": command, "exit_code": rc, "output_tail": "\n".join(output.splitlines()[-20:])})
            if rc != 0:
                raise RuntimeError(f"Native function-contract smoke step failed: {command}; output={output[-2000:]!r}")
        if "VERIFICATION SUCCESSFUL" not in outputs[-1]["output_tail"].upper():
            raise RuntimeError("Native function-contract smoke did not report VERIFICATION SUCCESSFUL.")
        return {
            "performed": True,
            "purpose": "native_function_contract_dfcc_toolchain_smoke_only",
            "commands": commands,
            "steps": outputs,
            "selected_thesis_property_checked": False,
        }


def check_live_native_contract_toolchain_smoke(
    *, strategy: str, goto_cc_path: Path, goto_instrument_path: Path, cbmc_path: Path
) -> dict[str, Any]:
    """Exercise exactly the native contract modes required by the selected campaign."""
    checks: dict[str, Any] = {}
    if strategy in {"native_loop_contract", "hybrid_contract_and_harness"}:
        checks["loop_contract"] = check_live_loop_contract_toolchain_smoke(
            goto_cc_path=goto_cc_path, goto_instrument_path=goto_instrument_path, cbmc_path=cbmc_path
        )
    if strategy in {"native_function_contract", "hybrid_contract_and_harness"}:
        checks["function_contract_dfcc"] = check_live_function_contract_toolchain_smoke(
            goto_cc_path=goto_cc_path, goto_instrument_path=goto_instrument_path, cbmc_path=cbmc_path
        )
    if not checks:
        raise ValueError(f"Native-contract smoke requested for unsupported strategy: {strategy!r}")
    return {
        "performed": True,
        "purpose": "strategy_specific_native_contract_toolchain_smoke_only",
        "verification_strategy": strategy,
        "checks": checks,
        "selected_thesis_property_checked": False,
    }


def run_preflight(
    config_path: Path,
    *,
    mode: str = "local_only",
    normalized_config_path: Path | None = None,
    allow_existing_run: bool = False,
    api_client_factory: Callable[..., Any] | None = None,
) -> tuple[int, dict[str, Any]]:
    errors: list[str] = []
    warnings: list[str] = []
    report: dict[str, Any] = {
        "schema_version": "first_api_operational_preflight.v3",
        "created_utc": utc_now_iso(),
        "config_path": str(config_path.expanduser().resolve()),
        "preflight_mode": mode,
        "network_request_performed": False,
        "approved_for_one_controlled_first_experiment": False,
        "checks": {},
        "errors": errors,
        "warnings": warnings,
    }

    if mode not in {"local_only", "live_api_probe"}:
        errors.append("Preflight mode must be 'local_only' or 'live_api_probe'.")
        return 1, report
    try:
        config = load_normalized_config(config_path)
    except (ConfigContractError, OSError, json.JSONDecodeError) as exc:
        errors.append(f"Configuration could not be normalized: {exc}")
        return 1, report

    project_root = Path(str(config["project_root"])).resolve()
    workspace_mode = normalise_workspace_mode(config)
    report["workspace_mode"] = workspace_mode
    report["checks"]["mutable_workspace_contract"] = {
        "passed": True,
        "release_binding_performed": False,
        "in_tree_runs_allowed": True,
        "ordinary_config_launch_allowed": True,
    }

    contract = validate_pipeline_config(config, check_input_files=True)
    errors.extend(contract.errors)
    warnings.extend(contract.warnings)
    report["checks"]["configuration_contract"] = {
        "passed": not contract.errors,
        "warnings": list(contract.warnings),
    }

    llm = config.get("llm", {}) if isinstance(config.get("llm"), Mapping) else {}
    preflight_primary_evidence = collect_preflight_primary_evidence(config, project_root)
    tool = config.get("tool_execution", {}) if isinstance(config.get("tool_execution"), Mapping) else {}
    provenance = config.get("provenance", {}) if isinstance(config.get("provenance"), Mapping) else {}
    campaign = config.get("property_campaign", {}) if isinstance(config.get("property_campaign"), Mapping) else {}
    property_discovery = config.get("property_discovery", {}) if isinstance(config.get("property_discovery"), Mapping) else {}
    protocol = config.get("experiment_protocol", {}) if isinstance(config.get("experiment_protocol"), Mapping) else {}
    strategy = str(campaign.get("verification_strategy") or "standard_cbmc_harness")
    analysis_only = strategy == "analysis_only_no_formal_claim"
    native_contract = strategy in {"native_loop_contract", "native_function_contract", "hybrid_contract_and_harness"}

    if str(llm.get("mode", "")).lower() != "real":
        errors.append("llm.mode must be 'real' for the first API experiment.")
    model = str(llm.get("model") or "").strip()
    if not model or has_placeholder(model):
        errors.append("llm.model is missing or still contains a placeholder.")
    key_env = str(llm.get("api_key_env") or "OPENAI_API_KEY").strip()
    if mode == "live_api_probe" and not os.environ.get(key_env, "").strip():
        errors.append(
            f"API credential environment variable {key_env} is not set or is empty; "
            "credentials are required only for --live-api-probe."
        )

    if bool(tool.get("dry_run", False)):
        errors.append("tool_execution.dry_run must be false for the first real experiment.")
    if bool(tool.get("force_run", False)):
        errors.append("tool_execution.force_run must remain false; review-gate bypass is not approved.")
    if not bool(tool.get("require_gate_approval", True)):
        errors.append("tool_execution.require_gate_approval must be true.")
    max_iterations = int(config.get("max_iterations", -1))
    repair_policy = str(protocol.get("repair_policy") or "")
    if repair_policy == "none_initial_run" and max_iterations != 0:
        errors.append("The initial LLM-first experiment mandates max_iterations=0 at all cost.")
    elif repair_policy == "single_repair_followup" and max_iterations != 1:
        errors.append("A separately identified single-repair follow-up mandates max_iterations=1.")
    elif repair_policy not in {"none_initial_run", "single_repair_followup", "bounded_repair"}:
        errors.append("experiment_protocol.repair_policy is not approved.")
    if semantic_advisory_mode(config) != "off":
        errors.append(
            "The main thesis preflight mandates experiment_protocol.semantic_advisory_mode='off'. "
            "reference_only is permitted only in a separately labelled comparison experiment."
        )
    if not bool(protocol.get("structured_cbmc_json_required", False)):
        errors.append("The controlled protocol requires structured_cbmc_json_required=true.")
    if not bool(tool.get("structured_json_required", False)):
        errors.append("tool_execution.structured_json_required must be true.")
    for field in ("step_timeout_seconds", "pipeline_timeout_seconds"):
        value = tool.get(field)
        if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
            errors.append(f"tool_execution.{field} must be a positive integer.")

    binary = str(tool.get("cbmc_binary") or "cbmc")
    binary_resolved = shutil.which(binary) if not Path(binary).is_absolute() else binary
    binary_path: Path | None = Path(binary_resolved).resolve() if binary_resolved and Path(binary_resolved).exists() else None
    if not analysis_only:
        if binary_path is None:
            errors.append(f"CBMC executable was not found: {binary}")
        else:
            rc, output = run_text([str(binary_path), "--version"])
            if rc != 0:
                errors.append(f"CBMC version command failed: {output}")
            else:
                report["checks"]["cbmc_version"] = {
                    "passed": True,
                    "version_first_line": output.splitlines()[0] if output else "unknown",
                }

    goto_cc_path: Path | None = None
    goto_instrument_path: Path | None = None
    if native_contract:
        for config_key, default_name in (("goto_cc_binary", "goto-cc"), ("goto_instrument_binary", "goto-instrument")):
            configured = str(tool.get(config_key) or default_name)
            resolved = shutil.which(configured) if not Path(configured).is_absolute() else configured
            path = Path(resolved).resolve() if resolved and Path(resolved).exists() else None
            if path is None:
                errors.append(f"Native contract strategy requires {config_key}, but it was not found: {configured}")
            elif config_key == "goto_cc_binary":
                goto_cc_path = path
            else:
                goto_instrument_path = path

    if not analysis_only:
        required_build_fields = ("source_files", "include_paths", "defines", "working_directory")
        for field in required_build_fields:
            if field not in tool:
                errors.append(f"tool_execution.{field} is required by the formal-build contract.")
        source_files = tool.get("source_files", [])
        if not isinstance(source_files, list) or not source_files:
            errors.append("tool_execution.source_files must list the implementation .c translation units.")
        else:
            for value in source_files:
                path = resolve_path(value, project_root)
                if not path.is_file():
                    errors.append(f"Configured implementation source does not exist: {path}")
        for value in tool.get("stub_files", []) if isinstance(tool.get("stub_files"), list) else []:
            path = resolve_path(value, project_root)
            if not path.is_file():
                errors.append(f"Configured stub file does not exist: {path}")
        for value in tool.get("include_paths", []) if isinstance(tool.get("include_paths"), list) else []:
            path = resolve_path(value, project_root)
            if not path.is_dir():
                errors.append(f"Configured include path does not exist: {path}")
        working = resolve_path(tool.get("working_directory", "."), project_root)
        if not working.is_dir():
            errors.append(f"Formal-build working directory does not exist: {working}")
    else:
        report["checks"]["formal_build_configuration"] = {
            "passed": True,
            "required": False,
            "reason": "Analysis-only property family has no CBMC/GOTO execution claim.",
        }

    revision = str(provenance.get("source_revision") or "").strip()
    repository_paths = provenance.get("repository_paths", [])
    if not revision or has_placeholder(revision):
        errors.append("provenance.source_revision must be replaced with the exact repository commit or tag.")
    resolved_repositories: list[Path] = []
    if not isinstance(repository_paths, list) or not repository_paths:
        errors.append("provenance.repository_paths must list at least one source repository.")
    else:
        git_matches = 0
        for value in repository_paths:
            repo = resolve_path(value, project_root)
            resolved_repositories.append(repo)
            if not repo.is_dir():
                errors.append(f"Repository provenance path does not exist: {repo}")
                continue
            rc_head, head = run_text(["git", "-C", str(repo), "rev-parse", "HEAD"])
            if rc_head != 0:
                errors.append(f"Repository provenance path is not a readable Git worktree: {repo}")
                continue
            rc_rev, resolved_revision = run_text(["git", "-C", str(repo), "rev-parse", revision])
            if rc_rev != 0:
                errors.append(f"Configured source revision cannot be resolved in {repo}: {revision}")
                continue
            git_matches += 1
            if head.splitlines()[0] != resolved_revision.splitlines()[0]:
                errors.append(
                    f"Repository HEAD does not match provenance.source_revision in {repo}: "
                    f"HEAD={head.splitlines()[0]} configured={resolved_revision.splitlines()[0]}"
                )
            rc_dirty, dirty = run_text(["git", "-C", str(repo), "status", "--porcelain"])
            if rc_dirty != 0:
                errors.append(f"Could not inspect repository cleanliness: {repo}")
            elif dirty:
                warnings.append(f"Repository contains uncommitted changes: {repo}")
        if git_matches == 0:
            errors.append("No configured repository path produced verifiable Git revision provenance.")

    if resolved_repositories:
        implementation_paths = [Path(str(v)).resolve() for v in config.get("inputs", {}).get("code_paths", [])]
        for implementation_path in implementation_paths:
            if not any(implementation_path == repo or repo in implementation_path.parents for repo in resolved_repositories):
                errors.append(f"Implementation input is outside every provenance repository path: {implementation_path}")

    try:
        run_dir = resolve_run_dir_from_config(config)
    except ConfigContractError as exc:
        errors.append(str(exc))
        run_dir = None
    else:
        output_root = Path(str(config.get("output_root") or run_dir.parent)).resolve()
        if run_dir.exists() and not allow_existing_run:
            errors.append(f"Run directory already exists; choose a unique run_id: {run_dir}")
        run_dir.parent.mkdir(parents=True, exist_ok=True)
        if not os.access(run_dir.parent, os.W_OK):
            errors.append(f"Run output parent is not writable: {run_dir.parent}")

    if has_placeholder(config):
        errors.append("The configuration still contains one or more placeholder values.")

    try:
        preflight_llm_cfg = LLMClientConfig.from_mapping(llm)
        evidence_manifest = build_primary_evidence_transmission_manifest(
            preflight_primary_evidence,
            config=preflight_llm_cfg,
        )
        report["checks"]["primary_evidence_completeness"] = {
            "passed": bool(evidence_manifest.get("all_primary_evidence_complete")),
            **evidence_manifest,
        }
        if preflight_llm_cfg.fail_on_primary_evidence_truncation:
            enforce_primary_evidence_completeness(evidence_manifest)
    except Exception as exc:
        errors.append(f"Primary-evidence completeness check failed: {type(exc).__name__}: {exc}")
        report["checks"]["primary_evidence_completeness"] = {
            "passed": False,
            "error": str(exc),
        }

    try:
        budget = prompt_budget(config)
        budget_llm_cfg = LLMClientConfig.from_mapping(llm)
        budget_input = build_responses_api_input(
            "Operational preflight request-budget check. Do not analyse the supplied evidence.",
            preflight_primary_evidence,
            config=budget_llm_cfg,
        )
        budget_payload = {
            "model": str(llm.get("model") or ""),
            "input": budget_input,
            **build_responses_control_payload(budget_llm_cfg, max_output_tokens_override=budget_llm_cfg.preflight_max_output_tokens),
        }
        request_bytes = len(json.dumps(budget_payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8"))
        estimate_tokens = max(1, request_bytes // 4)
        budget_passed = (
            request_bytes <= int(budget["max_request_bytes"])
            and estimate_tokens <= int(budget["max_stage_input_tokens_estimate"])
        )
        report["checks"]["prompt_budget"] = {
            "passed": budget_passed,
            "estimated_request_bytes": request_bytes,
            "estimated_input_tokens": estimate_tokens,
            "budget": budget,
            "deterministic_advisory_bundle_present": False,
        }
        if not budget_passed:
            errors.append(
                f"Preflight request exceeds the mandatory prompt budget: {request_bytes} bytes / "
                f"~{estimate_tokens} tokens. Narrow primary evidence deliberately before spending API money."
            )
    except Exception as exc:
        errors.append(f"Prompt-budget check failed: {type(exc).__name__}: {exc}")
        report["checks"]["prompt_budget"] = {"passed": False, "error": str(exc)}

    # A provider request is made only when the user explicitly selects live_api_probe.
    if mode == "live_api_probe":
        if errors:
            report["checks"]["live_api_access"] = {
                "passed": False,
                "performed": False,
                "reason": "live probe was not sent because one or more mandatory local checks failed",
            }
        else:
            estimate = report.get("checks", {}).get("prompt_budget", {})
            print(
                "LIVE API PROBE AUTHORIZED: about "
                f"{estimate.get('estimated_request_bytes', 'unknown')} request bytes / "
                f"~{estimate.get('estimated_input_tokens', 'unknown')} estimated input tokens will be sent.",
                flush=True,
            )
            try:
                report["checks"]["live_api_access"] = {
                    "passed": True,
                    **check_live_api_access(
                        llm,
                        primary_evidence_files=preflight_primary_evidence,
                        client_factory=api_client_factory,
                    ),
                }
                report["network_request_performed"] = True
            except Exception as exc:
                errors.append(f"Live Responses API/model-access probe failed: {type(exc).__name__}: {exc}")
                report["checks"]["live_api_access"] = {"passed": False, "performed": True, "error": str(exc)}
    else:
        report["checks"]["live_api_access"] = {
            "passed": True,
            "performed": False,
            "reason": "local-only mode: zero provider requests are permitted",
        }

    if not errors and analysis_only:
        report["checks"]["formal_tool_smoke"] = {
            "passed": True,
            "performed": False,
            "reason": "Analysis-only property family intentionally permits no CBMC proof claim.",
        }
    elif not errors and native_contract and binary_path and goto_cc_path and goto_instrument_path:
        try:
            report["checks"]["live_native_contract_smoke"] = {
                "passed": True,
                **check_live_native_contract_toolchain_smoke(
                    strategy=strategy,
                    goto_cc_path=goto_cc_path,
                    goto_instrument_path=goto_instrument_path,
                    cbmc_path=binary_path,
                ),
            }
        except Exception as exc:
            errors.append(f"Live native-contract toolchain smoke failed: {type(exc).__name__}: {exc}")
            report["checks"]["live_native_contract_smoke"] = {"passed": False, "error": str(exc)}
    elif not errors and binary_path is not None:
        try:
            report["checks"]["live_cbmc_smoke"] = {
                "passed": True,
                **check_live_cbmc_smoke(binary_path),
            }
        except Exception as exc:
            errors.append(f"Live CBMC smoke verification failed: {type(exc).__name__}: {exc}")
            report["checks"]["live_cbmc_smoke"] = {"passed": False, "error": str(exc)}

    report["approved_for_one_controlled_first_experiment"] = not errors
    if not errors and normalized_config_path is not None:
        destination = normalized_config_path.expanduser().resolve()
        atomic_write_json(destination, config)
        report["normalized_config_path"] = str(destination)
        report["checks"]["normalized_config_output"] = {
            "passed": True,
            "authorization_or_binding_added": False,
        }
    report["run_id"] = config.get("run_id")
    report["model"] = model
    report["property_discovery"] = {
        "mode": property_discovery.get("mode"),
        "catalogue_visibility": property_discovery.get("catalogue_visibility"),
        "allow_uncatalogued_properties": property_discovery.get("allow_uncatalogued_properties"),
        "selection_policy": property_discovery.get("selection_policy"),
        "selection_pending": bool(campaign.get("selection_pending")),
    }
    report["property_family_id"] = campaign.get("property_family_id")
    report["verification_strategy"] = strategy
    report["protocol_sha256"] = protocol.get("protocol_sha256")
    report["semantic_advisory_mode"] = protocol.get("semantic_advisory_mode")
    report["run_dir"] = str(run_dir) if run_dir else None
    report["claim_boundary"] = {
        "local_only_performs_provider_request": False,
        "api_probe_proves_semantic_quality": False,
        "api_probe_proves_later_stage_context_fit": False,
        "runtime_rechecks_each_exact_stage_request": True,
        "cbmc_smoke_proves_target_property": False,
        "approval_scope": "one controlled first run with this exact reviewed configuration",
    }
    return (0 if not errors else 1), report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", required=True, type=Path)
    modes = parser.add_mutually_exclusive_group(required=False)
    modes.add_argument(
        "--local-only",
        action="store_true",
        help="Run all local config, provenance, cost-estimate and CBMC checks with zero provider requests.",
    )
    modes.add_argument(
        "--live-api-probe",
        action="store_true",
        help="Explicitly authorise the small paid provider-access probe after every local check passes.",
    )
    parser.add_argument(
        "--acknowledge-paid-probe",
        action="store_true",
        help="Required with --live-api-probe to confirm that the explicit provider request may incur API cost.",
    )
    parser.add_argument(
        "--normalized-config",
        required=False,
        type=Path,
        help="Optional path for a normalized config copy; no authorization or release binding is added.",
    )
    parser.add_argument(
        "--report",
        required=False,
        type=Path,
        default=ROOT / "reports" / "preflight_report.json",
        help="Output path for the redacted preflight JSON report (defaults inside reports/).",
    )
    parser.add_argument(
        "--allow-existing-run",
        action="store_true",
        help="Permit an already-existing run directory. Do not use this for a new experiment.",
    )
    args = parser.parse_args()
    mode = "live_api_probe" if args.live_api_probe else "local_only"
    if args.live_api_probe and not args.acknowledge_paid_probe:
        parser.error("--live-api-probe requires --acknowledge-paid-probe")
    if args.local_only and args.acknowledge_paid_probe:
        parser.error("--acknowledge-paid-probe is valid only with --live-api-probe")
    rc, report = run_preflight(
        args.config,
        mode=mode,
        normalized_config_path=args.normalized_config,
        allow_existing_run=args.allow_existing_run,
    )
    report_path = args.report.expanduser().resolve()
    atomic_write_json(report_path, report)

    if rc != 0:
        print("OPERATIONAL PREFLIGHT FAILED")
        for message in report["errors"]:
            print(f"  - {message}")
        print(f"Redacted preflight report: {report_path}")
        return rc

    print("Configuration contract: PASS")
    print("Mutable workspace: PASS (ordinary configs and in-tree runs are allowed)")
    print("Release ZIP/manifest authorization: NOT IMPLEMENTED IN THIS EDITION")
    print("Input files and formal-build paths: PASS")
    print("Repository revision provenance: PASS")
    if mode == "local_only":
        print("Provider request: NOT PERFORMED (local-only zero-cost mode)")
    else:
        print("Explicit live complete-evidence configured-model/input probe: PASS")
    print("Formal-tool strategy smoke verification: PASS")
    print("Review-gate and first-run controls: PASS")
    for warning in report["warnings"]:
        print(f"WARNING: {warning}")
    print("\nOPERATIONAL PREFLIGHT PASSED")
    if args.normalized_config is not None:
        print(f"Normalized config: {args.normalized_config.expanduser().resolve()}")
    print("Direct launch of the original or normalized config is allowed.")
    print("This does not establish model semantic quality or verify the selected thesis property.")
    print(f"Redacted preflight report: {report_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
