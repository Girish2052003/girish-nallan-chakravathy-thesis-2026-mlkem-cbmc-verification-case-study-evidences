#!/usr/bin/env python3
"""Canonical configuration loading, normalization, and validation.

This module gives every workflow component one configuration contract.  It
accepts a controlled set of legacy aliases, resolves relative paths against the
project root (not the caller's current working directory), and writes a stable
canonical shape for downstream agents.

Canonical input keys
--------------------
inputs.primary_spec   absolute path to the primary specification file
inputs.spec_paths     ordered, de-duplicated absolute specification paths
inputs.primary_source absolute path to the primary implementation source file
inputs.code_paths     ordered, de-duplicated absolute C/header/include paths
inputs.code_dir       optional absolute source directory

Compatibility aliases such as top-level ``spec_file`` and ``source_file`` are
retained, but their values are synchronized with the canonical keys.
"""

from __future__ import annotations

import copy
import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple, Union

from agents.common.property_catalog import get_property_family, resolve_strategy, strategy_ids
from agents.common.property_discovery_mode import (
    OPEN_DISCOVERY,
    PropertyDiscoveryModeError,
    normalize_property_discovery,
    open_discovery_campaign_placeholder,
    validate_property_discovery_config,
)
from agents.common.llm_profile import (
    LLMProfileError,
    canonical_json_sha256,
    resolve_llm_configuration,
)
from agents.common.experiment_protocol import (
    build_experiment_protocol,
    validate_experiment_protocol,
)
from agents.common.workspace_mode import normalise_workspace_mode
from agents.common.semantic_property import SELECTION_POLICIES
from agents.common.gate_contract import EXECUTION_MODES

JsonDict = Dict[str, Any]
PathLike = Union[str, Path]
CONFIG_SCHEMA_VERSION = "thesis_agent_config.v1"
CODE_SUFFIXES: Tuple[str, ...] = ("*.c", "*.h", "*.inc")


class ConfigContractError(ValueError):
    """Raised when a configuration violates the pipeline contract."""


@dataclass(frozen=True)
class ConfigValidationReport:
    """Machine-readable result from configuration validation."""

    valid: bool
    errors: Tuple[str, ...]
    warnings: Tuple[str, ...]

    def raise_for_errors(self) -> None:
        if self.errors:
            rendered = "\n".join(f"  - {item}" for item in self.errors)
            raise ConfigContractError(f"Configuration contract validation failed:\n{rendered}")


def read_json_object(path: PathLike) -> JsonDict:
    p = Path(path).expanduser().resolve()
    try:
        with p.open("r", encoding="utf-8") as handle:
            value = json.load(handle)
    except json.JSONDecodeError as exc:
        raise ConfigContractError(
            f"Configuration is not valid JSON: {p} (line {exc.lineno}, column {exc.colno}: {exc.msg})"
        ) from exc
    if not isinstance(value, dict):
        raise ConfigContractError(f"Configuration root must be a JSON object: {p}")
    return dict(value)


def _expanded_path(value: Any, base: Path) -> Path:
    text = os.path.expandvars(os.path.expanduser(str(value).strip()))
    if not text:
        raise ConfigContractError("Empty path value is not allowed.")
    candidate = Path(text)
    if not candidate.is_absolute():
        candidate = base / candidate
    return candidate.resolve()


def _first_nonempty(mapping: Mapping[str, Any], keys: Sequence[str]) -> Tuple[Optional[str], Any]:
    for key in keys:
        value = mapping.get(key)
        if value is not None and value != "" and value != []:
            return key, value
    return None, None


def _flatten_path_values(value: Any) -> List[Any]:
    if value is None or value == "":
        return []
    if isinstance(value, (str, Path)):
        # Comma-separated CLI-style values are accepted for backwards compatibility.
        return [item.strip() for item in str(value).split(",") if item.strip()]
    if isinstance(value, (list, tuple)):
        out: List[Any] = []
        for item in value:
            out.extend(_flatten_path_values(item))
        return out
    raise ConfigContractError(
        f"Path values must be strings or arrays of strings, not {type(value).__name__}."
    )


def _append_paths(out: List[Path], value: Any, base: Path) -> None:
    for item in _flatten_path_values(value):
        out.append(_expanded_path(item, base))


def _dedupe_paths(paths: Iterable[Path]) -> List[Path]:
    seen: set[str] = set()
    result: List[Path] = []
    for path in paths:
        key = str(path)
        if key in seen:
            continue
        seen.add(key)
        result.append(path)
    return result


def _discover_project_root(config_path: Path, raw: Mapping[str, Any], explicit: Optional[PathLike]) -> Path:
    if explicit is not None:
        return _expanded_path(explicit, Path.cwd())

    configured = raw.get("project_root")
    if configured:
        return _expanded_path(configured, config_path.parent)

    # Standard user-authored configuration location: <project>/configs/name.json
    if config_path.parent.name == "configs":
        return config_path.parent.parent.resolve()

    # Resolved run config location: <project>/runs/<run-id>/run_config.resolved.json
    # Search upwards for the workflow's agents directory.
    for ancestor in [config_path.parent, *config_path.parents]:
        if (ancestor / "agents").is_dir():
            return ancestor.resolve()

    # Last resort for standalone tests.  This is recorded as a warning by the
    # validation report when it leads to missing inputs.
    return Path.cwd().resolve()


def infer_project_root(
    config_path: PathLike,
    raw_config: Optional[Mapping[str, Any]] = None,
    explicit_project_root: Optional[PathLike] = None,
) -> Path:
    p = Path(config_path).expanduser().resolve()
    raw = raw_config or {}
    return _discover_project_root(p, raw, explicit_project_root)


def _singular_alias_candidates(
    raw: Mapping[str, Any],
    inputs: Mapping[str, Any],
    project_root: Path,
    *,
    nested_keys: Sequence[str],
    top_keys: Sequence[str],
) -> Dict[str, str]:
    candidates: Dict[str, str] = {}
    for key in nested_keys:
        value = inputs.get(key)
        if value not in (None, "", []):
            values = _flatten_path_values(value)
            if len(values) != 1:
                raise ConfigContractError(f"inputs.{key} is a singular path alias and must contain exactly one path.")
            candidates[f"inputs.{key}"] = str(_expanded_path(values[0], project_root))
    for key in top_keys:
        value = raw.get(key)
        if value not in (None, "", []):
            values = _flatten_path_values(value)
            if len(values) != 1:
                raise ConfigContractError(f"{key} is a singular path alias and must contain exactly one path.")
            candidates[key] = str(_expanded_path(values[0], project_root))
    return candidates


def _collect_spec_paths(raw: Mapping[str, Any], inputs: Mapping[str, Any], project_root: Path) -> Tuple[List[Path], List[str]]:
    paths: List[Path] = []
    aliases: List[str] = []

    # Canonical values are preferred, followed by legacy nested and top-level aliases.
    for key in ("primary_spec", "spec_paths", "spec_path", "spec_file", "specs"):
        if inputs.get(key) not in (None, "", []):
            aliases.append(f"inputs.{key}")
            _append_paths(paths, inputs.get(key), project_root)

    for key in (
        "spec_file",
        "spec_source",
        "fips_source",
        "spec_path",
        "fips_text_path",
        "fips203_text_path",
        "fips_pdf_path",
        "selected_spec_excerpt",
        "selected_spec_excerpt_path",
    ):
        if raw.get(key) not in (None, "", []):
            aliases.append(key)
            _append_paths(paths, raw.get(key), project_root)

    # Additional nested legacy aliases used by Agent 2.
    for key in (
        "fips_text_path",
        "fips203_text_path",
        "fips_pdf_path",
        "selected_spec_excerpt",
        "selected_spec_excerpt_path",
    ):
        if inputs.get(key) not in (None, "", []):
            aliases.append(f"inputs.{key}")
            _append_paths(paths, inputs.get(key), project_root)

    return _dedupe_paths(paths), aliases


def _collect_code_paths(
    raw: Mapping[str, Any],
    inputs: Mapping[str, Any],
    project_root: Path,
) -> Tuple[List[Path], Optional[Path], List[str]]:
    paths: List[Path] = []
    aliases: List[str] = []

    # Put the primary source first so source_file remains deterministic.
    for key in ("primary_source", "source_file", "code_path", "source_path"):
        if inputs.get(key) not in (None, "", []):
            aliases.append(f"inputs.{key}")
            _append_paths(paths, inputs.get(key), project_root)

    for key in ("source_file", "code_path", "source_path"):
        if raw.get(key) not in (None, "", []):
            aliases.append(key)
            _append_paths(paths, raw.get(key), project_root)

    for key in (
        "code_paths",
        "source_paths",
        "implementation_files",
        "code_files",
        "source_files",
        "headers",
        "header_path",
        "implementation_path",
        "target_code_path",
        "poly_c_path",
    ):
        if inputs.get(key) not in (None, "", []):
            aliases.append(f"inputs.{key}")
            _append_paths(paths, inputs.get(key), project_root)

    for key in ("code_paths", "source_files", "source_paths", "implementation_files"):
        if raw.get(key) not in (None, "", []):
            aliases.append(key)
            _append_paths(paths, raw.get(key), project_root)

    code_dir_key, code_dir_value = _first_nonempty(inputs, ("code_dir", "code_directory"))
    if code_dir_value is None:
        code_dir_key, code_dir_value = _first_nonempty(raw, ("code_dir", "code_directory"))
        if code_dir_key:
            code_dir_key = code_dir_key
    elif code_dir_key:
        code_dir_key = f"inputs.{code_dir_key}"

    code_dir: Optional[Path] = None
    if code_dir_value is not None:
        aliases.append(str(code_dir_key))
        code_dir = _expanded_path(code_dir_value, project_root)
        if code_dir.is_dir():
            for pattern in CODE_SUFFIXES:
                paths.extend(sorted(p.resolve() for p in code_dir.glob(pattern) if p.is_file()))

    return _dedupe_paths(paths), code_dir, aliases


def _normalize_archival_spec_paths(inputs: JsonDict, project_root: Path) -> List[Path]:
    paths: List[Path] = []
    if inputs.get("archival_spec_paths") not in (None, "", []):
        _append_paths(paths, inputs.get("archival_spec_paths"), project_root)
        paths = _dedupe_paths(paths)
        inputs["archival_spec_paths"] = [str(path) for path in paths]
    return paths


def _copy_with_workspace_mode(raw_config: Mapping[str, Any]) -> JsonDict:
    normalized: JsonDict = copy.deepcopy(dict(raw_config))
    ignored_release_fields = [
        key for key in ("pipeline_release", "preflight_authorization")
        if key in normalized
    ]
    for key in ignored_release_fields:
        normalized.pop(key, None)
    try:
        normalized["workspace_mode"] = normalise_workspace_mode(normalized)
    except ValueError as exc:
        raise ConfigContractError(str(exc)) from exc
    if ignored_release_fields:
        normalized["_obsolete_release_fields_ignored"] = ignored_release_fields
    return normalized




def _normalize_discovery_and_campaign(normalized: JsonDict) -> None:
    """Normalize targeted and open discovery without changing legacy targeted behaviour."""
    campaign_was_explicit = "property_campaign" in normalized and normalized.get("property_campaign") is not None
    try:
        discovery = normalize_property_discovery(
            normalized,
            campaign_explicit=campaign_was_explicit,
        )
    except PropertyDiscoveryModeError as exc:
        raise ConfigContractError(str(exc)) from exc
    normalized["property_discovery"] = discovery

    if discovery["mode"] == OPEN_DISCOVERY:
        raw_campaign = normalized.get("property_campaign")
        if isinstance(raw_campaign, Mapping):
            family = str(raw_campaign.get("property_family_id") or raw_campaign.get("property_family") or "").strip()
            strategy = str(raw_campaign.get("verification_strategy") or "").strip()
            generated_placeholder = (
                str(raw_campaign.get("schema_version") or "").strip()
                == "property_campaign.v2.open_unselected"
                and family in ("", "UNMAPPED")
                and strategy in ("", "UNSELECTED")
                and bool(raw_campaign.get("selection_pending"))
                and str(raw_campaign.get("discovery_mode") or "").strip() == OPEN_DISCOVERY
            )
            if (family or strategy) and not generated_placeholder:
                raise ConfigContractError(
                    "open_discovery may not preselect property_campaign.property_family_id or verification_strategy. "
                    "Remove the targeted property_campaign block; classification and selection occur after Agent 4."
                )
        elif raw_campaign not in (None, {}):
            raise ConfigContractError("'property_campaign' must be an object when present.")
        # Recreate the canonical placeholder on every normalization pass. This
        # makes the resolved run configuration safe to reload independently by
        # Agents 2--11 without allowing a user-selected family or strategy.
        normalized["property_campaign"] = open_discovery_campaign_placeholder()
        return

    raw_campaign = normalized.get("property_campaign", {})
    if raw_campaign is None:
        raw_campaign = {}
    if not isinstance(raw_campaign, Mapping):
        raise ConfigContractError("'property_campaign' must be an object when present.")
    campaign = copy.deepcopy(dict(raw_campaign))
    family_value = str(
        campaign.get("property_family_id")
        or campaign.get("property_family")
        or normalized.get("property_family_id")
        or "P16"
    ).strip()
    try:
        family = get_property_family(family_value)
        requested_strategy = campaign.get("verification_strategy")
        if not campaign_was_explicit and requested_strategy in (None, "", "auto"):
            requested_strategy = "standard_cbmc_harness"
        strategy = resolve_strategy(family, requested_strategy)
    except (KeyError, ValueError) as exc:
        raise ConfigContractError(str(exc)) from exc
    campaign.update({
        "schema_version": "property_campaign.v1",
        "property_family_id": family["id"],
        "property_family_slug": family["slug"],
        "property_family_title": family["title"],
        "verification_strategy": strategy,
        "support_level": family["support_level"],
        "claim_boundary": family["claim_boundary"],
        "allowed_strategies": list(family["allowed_strategies"]),
        "target_examples": list(family["targets"]),
        "allow_analysis_only": bool(campaign.get("allow_analysis_only", family["support_level"] == "analysis_only")),
        "require_native_contract_tools": strategy in {"native_loop_contract", "native_function_contract", "hybrid_contract_and_harness"},
        "explicitly_configured": campaign_was_explicit,
        "legacy_compatibility_default": not campaign_was_explicit,
        "discovery_mode": "targeted_campaign",
        "selection_pending": False,
    })
    normalized["property_campaign"] = campaign


def _normalize_formal_strategy_reconciliation(normalized: JsonDict) -> None:
    raw = normalized.get("formal_strategy_reconciliation", {})
    if raw is None:
        raw = {}
    if not isinstance(raw, Mapping):
        raise ConfigContractError("'formal_strategy_reconciliation' must be an object when present.")
    reconciliation = copy.deepcopy(dict(raw))
    reconciliation.setdefault("mode", "no_silent_reconciliation")
    reconciliation.setdefault("allow_optional_contract_to_harness_fallback", False)
    reconciliation.setdefault("request_optional_contract_to_harness_fallback", False)
    reconciliation.setdefault("require_cbmc_frontend_readiness", True)
    reconciliation.setdefault("require_full_route_readiness", True)
    reconciliation.setdefault("forbid_silent_strategy_substitution", True)
    normalized["formal_strategy_reconciliation"] = reconciliation


def _normalize_formal_artifact_policy(normalized: JsonDict) -> None:
    raw = normalized.get("formal_artifact_policy", {})
    if raw is None:
        raw = {}
    if not isinstance(raw, Mapping):
        raise ConfigContractError("'formal_artifact_policy' must be an object when present.")
    policy = copy.deepcopy(dict(raw))
    policy.setdefault("schema_version", "formal_artifact_policy.v2")
    policy.setdefault("strategy_authority", "agent5_evidence_bound")
    policy.setdefault("encoding_preference", "harness_when_complete")
    policy.setdefault("allow_multiple_candidates", True)
    policy.setdefault("require_typed_contract_clauses", True)
    policy.setdefault("require_exact_traceability", True)
    policy.setdefault("require_real_cbmc_frontend", True)
    policy.setdefault("require_full_route_readiness", True)
    policy.setdefault("require_explicit_source_units", True)
    policy.setdefault("allow_test_scaffolds_in_real_mode", False)
    policy.setdefault("allow_strategy_switch_during_repair", True)
    policy.setdefault("allow_user_authorized_semantic_weakening", True)
    policy.setdefault("require_complete_repair_bundle", True)
    policy.setdefault("family_strategy_is_advisory_only", True)
    policy.setdefault("llm_feasibility_is_advisory_only", True)
    policy.setdefault("execution_mode", "reviewed")
    normalized["formal_artifact_policy"] = policy


def _normalize_tool_execution_controls(normalized: JsonDict) -> None:
    raw = normalized.get("tool_execution", {})
    if raw is None:
        raw = {}
    if not isinstance(raw, Mapping):
        raise ConfigContractError("'tool_execution' must be an object when present.")
    controls = copy.deepcopy(dict(raw))
    legacy_timeout = controls.get("timeout_seconds", normalized.get("timeout_seconds", 120))
    try:
        timeout_seconds = int(legacy_timeout)
    except (TypeError, ValueError):
        timeout_seconds = 120
    if timeout_seconds <= 0:
        timeout_seconds = 120
    controls.setdefault("step_timeout_seconds", timeout_seconds)
    controls.setdefault("pipeline_timeout_seconds", max(180, timeout_seconds))
    controls.setdefault("structured_json_required", True)
    policy = normalized.get("formal_artifact_policy", {})
    controls.setdefault("execution_mode", str(policy.get("execution_mode") or "reviewed"))
    controls.setdefault("allow_missing_gate", False)
    controls.setdefault("allow_missing_harness", False)
    normalized["tool_execution"] = controls


def _normalize_llm_runtime_settings(normalized: JsonDict) -> None:
    raw = normalized.get("llm", {})
    if raw is None:
        raw = {}
    if not isinstance(raw, Mapping):
        raise ConfigContractError("'llm' must be an object when present.")
    settings = copy.deepcopy(dict(raw))
    settings.setdefault("require_json_object", True)
    settings.setdefault("strict_json_object_only", True)
    settings.setdefault("validate_with_jsonschema", True)
    settings.setdefault("allow_minimal_schema_validation", False)
    try:
        legacy_retry_default = int(settings.get("max_retries", 2))
    except (TypeError, ValueError):
        legacy_retry_default = 2
    raw_retry_policy = settings.get("retry_policy", {})
    if raw_retry_policy is None:
        raw_retry_policy = {}
    if not isinstance(raw_retry_policy, Mapping):
        raise ConfigContractError("llm.retry_policy must be an object when present.")
    retry_policy = copy.deepcopy(dict(raw_retry_policy))
    defaults = {
        "schema": {"enabled": True, "max_retries": max(0, legacy_retry_default)},
        "incomplete_response": {"enabled": False, "max_retries": 0},
        "provider_error": {"enabled": True, "max_retries": max(0, legacy_retry_default)},
    }
    for category, default in defaults.items():
        block = retry_policy.get(category, {})
        if block is None:
            block = {}
        if not isinstance(block, Mapping):
            raise ConfigContractError(f"llm.retry_policy.{category} must be an object.")
        merged = copy.deepcopy(default)
        merged.update(dict(block))
        retry_policy[category] = merged
    settings["retry_policy"] = retry_policy
    normalized["llm"] = settings
    profile_metadata = normalized.get("_llm_profile")
    if isinstance(profile_metadata, Mapping):
        updated = copy.deepcopy(dict(profile_metadata))
        updated["resolved_llm_sha256"] = canonical_json_sha256(settings)
        normalized["_llm_profile"] = updated


def normalize_config(
    raw_config: Mapping[str, Any],
    *,
    config_path: Optional[PathLike] = None,
    project_root: Optional[PathLike] = None,
) -> JsonDict:
    """Return a deep-copied configuration in the canonical contract shape."""
    if not isinstance(raw_config, Mapping):
        raise ConfigContractError("Configuration root must be an object.")

    source_path = Path(config_path).expanduser().resolve() if config_path else (Path.cwd() / "config.json").resolve()
    root = _discover_project_root(source_path, raw_config, project_root)
    normalized = _copy_with_workspace_mode(raw_config)

    # Resolve the shared LLM profile once; frozen resolved configs do not reread it.
    try:
        resolved_llm, llm_profile_meta, llm_profile_path = resolve_llm_configuration(
            normalized,
            project_root=root,
        )
    except LLMProfileError as exc:
        raise ConfigContractError(str(exc)) from exc

    if resolved_llm is not None:
        normalized["llm"] = resolved_llm
    if llm_profile_meta is not None:
        normalized["_llm_profile"] = llm_profile_meta
    if llm_profile_path is not None:
        normalized["llm_profile"] = str(llm_profile_path)

    original_inputs = normalized.get("inputs", {})
    if original_inputs is None:
        original_inputs = {}
    if not isinstance(original_inputs, dict):
        raise ConfigContractError("'inputs' must be a JSON object when present.")
    inputs: JsonDict = copy.deepcopy(original_inputs)

    spec_primary_candidates = _singular_alias_candidates(
        normalized,
        inputs,
        root,
        nested_keys=("primary_spec", "spec_path", "spec_file"),
        top_keys=(
            "spec_file",
            "spec_source",
            "fips_source",
            "spec_path",
            "fips_text_path",
            "fips203_text_path",
            "fips_pdf_path",
            "selected_spec_excerpt",
            "selected_spec_excerpt_path",
        ),
    )
    code_primary_candidates = _singular_alias_candidates(
        normalized,
        inputs,
        root,
        nested_keys=("primary_source", "source_file", "code_path", "source_path"),
        top_keys=("source_file", "code_path", "source_path"),
    )

    spec_paths, spec_aliases = _collect_spec_paths(normalized, inputs, root)
    code_paths, code_dir, code_aliases = _collect_code_paths(normalized, inputs, root)
    archival_spec_paths = _normalize_archival_spec_paths(inputs, root)

    if spec_paths:
        inputs["primary_spec"] = str(spec_paths[0])
        inputs["spec_path"] = str(spec_paths[0])
        inputs["spec_file"] = str(spec_paths[0])
        inputs["spec_paths"] = [str(path) for path in spec_paths]
        normalized["spec_file"] = str(spec_paths[0])

    if code_paths:
        inputs["primary_source"] = str(code_paths[0])
        inputs["source_file"] = str(code_paths[0])
        inputs["code_path"] = str(code_paths[0])
        inputs["code_paths"] = [str(path) for path in code_paths]
        normalized["source_file"] = str(code_paths[0])

    if code_dir is not None:
        inputs["code_dir"] = str(code_dir)

    output_value = normalized.get("output_root", normalized.get("runs_dir", "runs"))
    output_root = _expanded_path(output_value, root)
    normalized["output_root"] = str(output_root)
    normalized["runs_dir"] = str(output_root)

    run_id = str(normalized.get("run_id", "")).strip()
    explicit_run_dir = normalized.get("run_dir") or normalized.get("output_dir")
    if explicit_run_dir:
        run_dir = _expanded_path(explicit_run_dir, root)
        normalized["run_dir"] = str(run_dir)
        normalized["output_dir"] = str(run_dir)
    elif run_id:
        run_dir = (output_root / run_id).resolve()
        normalized["run_dir"] = str(run_dir)
        normalized["output_dir"] = str(run_dir)

    _normalize_discovery_and_campaign(normalized)
    _normalize_formal_strategy_reconciliation(normalized)
    _normalize_formal_artifact_policy(normalized)

    # Upgrade legacy tool/LLM controls before constructing the immutable protocol.
    _normalize_tool_execution_controls(normalized)
    _normalize_llm_runtime_settings(normalized)

    # One immutable experiment-design object governs semantic advice, repair
    # policy, prompt budgets, strategy, model provenance, and source revision.
    # It is rebuilt canonically so every downstream stage records the same hash.
    normalized["experiment_protocol"] = build_experiment_protocol(normalized)

    normalized["inputs"] = inputs
    normalized["project_root"] = str(root)
    normalized["config_schema_version"] = CONFIG_SCHEMA_VERSION
    normalized["config_source_path"] = str(source_path)
    normalized["_config_contract"] = {
        "schema_version": CONFIG_SCHEMA_VERSION,
        "normalizer": "agents.common.config_contract",
        "project_root": str(root),
        "spec_aliases_observed": spec_aliases,
        "code_aliases_observed": code_aliases,
        "canonical_spec_count": len(spec_paths),
        "canonical_code_count": len(code_paths),
        "archival_spec_count": len(archival_spec_paths),
        "primary_spec_candidates": spec_primary_candidates,
        "primary_source_candidates": code_primary_candidates,
        "primary_spec_conflict": len(set(spec_primary_candidates.values())) > 1,
        "primary_source_conflict": len(set(code_primary_candidates.values())) > 1,
        "relative_paths_resolved_against": str(root),
        "obsolete_release_fields_ignored": list(normalized.pop("_obsolete_release_fields_ignored", [])),
    }
    return normalized


def load_normalized_config(
    config_path: PathLike,
    *,
    project_root: Optional[PathLike] = None,
) -> JsonDict:
    path = Path(config_path).expanduser().resolve()
    raw = read_json_object(path)
    return normalize_config(raw, config_path=path, project_root=project_root)


def apply_runtime_paths(
    config: Mapping[str, Any],
    *,
    project_root: PathLike,
    run_id: str,
    output_root: Optional[PathLike] = None,
    run_dir: Optional[PathLike] = None,
) -> JsonDict:
    """Synchronize run-level canonical aliases after an orchestrator chooses a run ID."""

    root = _expanded_path(project_root, Path.cwd())
    result: JsonDict = copy.deepcopy(dict(config))
    chosen_output = _expanded_path(output_root if output_root is not None else result.get("output_root", "runs"), root)
    chosen_run = _expanded_path(run_dir, root) if run_dir is not None else (chosen_output / run_id).resolve()

    result["project_root"] = str(root)
    result["run_id"] = str(run_id)
    result["output_root"] = str(chosen_output)
    result["runs_dir"] = str(chosen_output)
    result["run_dir"] = str(chosen_run)
    result["output_dir"] = str(chosen_run)
    result["config_schema_version"] = CONFIG_SCHEMA_VERSION
    contract = result.get("_config_contract", {})
    if not isinstance(contract, dict):
        contract = {}
    contract.update(
        {
            "schema_version": CONFIG_SCHEMA_VERSION,
            "runtime_paths_applied": True,
            "project_root": str(root),
            "run_id": str(run_id),
            "output_root": str(chosen_output),
            "run_dir": str(chosen_run),
        }
    )
    result["_config_contract"] = contract
    return result


def resolve_run_dir_from_config(config: Mapping[str, Any], cli_run_dir: Optional[PathLike] = None) -> Path:
    """Resolve a run directory from canonical config or an explicit CLI override."""

    root = Path(str(config.get("project_root", Path.cwd()))).expanduser().resolve()
    if cli_run_dir:
        return _expanded_path(cli_run_dir, root)

    for key in ("run_dir", "output_dir"):
        if config.get(key):
            return _expanded_path(config[key], root)

    run = config.get("run", {})
    if isinstance(run, Mapping):
        for key in ("run_dir", "output_dir"):
            if run.get(key):
                return _expanded_path(run[key], root)

    output_root = _expanded_path(config.get("output_root", config.get("runs_dir", "runs")), root)
    run_id = str(config.get("run_id", "run_001_refactored"))
    return (output_root / run_id).resolve()


def _validate_archival_spec_inputs(inputs: Mapping[str, Any]) -> List[str]:
    errors: List[str] = []
    values = inputs.get("archival_spec_paths", [])
    if values is not None and not isinstance(values, list):
        return ["inputs.archival_spec_paths must be a list of file paths when provided."]
    for value in values or []:
        path = Path(str(value))
        if not path.exists():
            errors.append(f"Archival specification source does not exist: {path}")
        elif not path.is_file():
            errors.append(f"Archival specification source is not a regular file: {path}")
    return errors


def _validate_real_mode_provenance(config: Mapping[str, Any]) -> List[str]:
    errors: List[str] = []
    provenance = config.get("provenance", {})
    if isinstance(provenance, Mapping):
        revision = str(provenance.get("source_revision", "")).strip()
        if not revision or "REPLACE_WITH" in revision.upper() or "SET_TO_" in revision.upper():
            errors.append("Real experiment configuration requires provenance.source_revision to record an exact commit or tag.")
    return errors


def _validate_workspace_mode(config: Mapping[str, Any], errors: List[str]) -> None:
    try:
        normalise_workspace_mode(config)
    except ValueError as exc:
        errors.append(str(exc))



def _obsolete_release_field_warnings(config: Mapping[str, Any]) -> List[str]:
    contract_meta = config.get("_config_contract", {})
    if not isinstance(contract_meta, Mapping):
        return []
    return [
        f"Ignored obsolete {field} field in mutable-only edition."
        for field in contract_meta.get("obsolete_release_fields_ignored", []) or []
    ]

def _validate_formal_strategy_reconciliation(config: Mapping[str, Any]) -> List[str]:
    errors: List[str] = []
    reconciliation = config.get("formal_strategy_reconciliation", {})
    if not isinstance(reconciliation, Mapping):
        return ["'formal_strategy_reconciliation' must be an object after normalization."]
    if str(reconciliation.get("mode") or "") not in {"no_silent_reconciliation", "evidence_bound", "strict_requested"}:
        errors.append("formal_strategy_reconciliation.mode must be no_silent_reconciliation, evidence_bound, or strict_requested.")
    if not isinstance(reconciliation.get("allow_optional_contract_to_harness_fallback"), bool):
        errors.append("formal_strategy_reconciliation.allow_optional_contract_to_harness_fallback must be boolean.")
    if not isinstance(reconciliation.get("require_cbmc_frontend_readiness"), bool):
        errors.append("formal_strategy_reconciliation.require_cbmc_frontend_readiness must be boolean.")
    if not isinstance(reconciliation.get("require_full_route_readiness"), bool):
        errors.append("formal_strategy_reconciliation.require_full_route_readiness must be boolean.")
    if not isinstance(reconciliation.get("forbid_silent_strategy_substitution"), bool):
        errors.append("formal_strategy_reconciliation.forbid_silent_strategy_substitution must be boolean.")
    return errors


def _validate_formal_artifact_policy(config: Mapping[str, Any]) -> List[str]:
    errors: List[str] = []
    policy = config.get("formal_artifact_policy", {})
    if not isinstance(policy, Mapping):
        return ["'formal_artifact_policy' must be an object after normalization."]
    if str(policy.get("strategy_authority") or "") not in {"agent5_evidence_bound", "user_selected", "targeted_campaign"}:
        errors.append("formal_artifact_policy.strategy_authority is unsupported.")
    if str(policy.get("encoding_preference") or "") not in {"harness_when_complete", "contract_when_required", "contract_preferred"}:
        errors.append("formal_artifact_policy.encoding_preference is unsupported.")
    for key in (
        "allow_multiple_candidates", "require_typed_contract_clauses",
        "require_exact_traceability", "require_real_cbmc_frontend",
        "require_full_route_readiness", "require_explicit_source_units", "allow_test_scaffolds_in_real_mode",
        "allow_strategy_switch_during_repair", "allow_user_authorized_semantic_weakening",
        "require_complete_repair_bundle", "family_strategy_is_advisory_only", "llm_feasibility_is_advisory_only",
    ):
        if not isinstance(policy.get(key), bool):
            errors.append(f"formal_artifact_policy.{key} must be boolean.")
    if str(policy.get("execution_mode") or "") not in EXECUTION_MODES:
        errors.append("formal_artifact_policy.execution_mode must be reviewed, user_forced_review_bypass, or raw_manual.")
    discovery = config.get("property_discovery", {})
    if isinstance(discovery, Mapping):
        selection_policy = str(discovery.get("selection_policy") or "")
        if selection_policy not in SELECTION_POLICIES:
            errors.append(f"Unsupported property_discovery.selection_policy: {selection_policy!r}.")
    return errors


def _validate_tool_execution_config(config: Mapping[str, Any], errors: List[str]) -> None:
    tool_execution = config.get("tool_execution", {})
    if not isinstance(tool_execution, Mapping):
        errors.append("'tool_execution' must be an object when provided.")
        return
    for binary_key in ("cbmc_binary", "goto_cc_binary", "goto_instrument_binary"):
        value = tool_execution.get(binary_key)
        if binary_key in tool_execution and (not isinstance(value, str) or not str(value).strip()):
            errors.append(f"tool_execution.{binary_key} must be a non-empty string when provided.")
    for list_key in (
        "source_files", "source_units", "stub_files", "stubs", "include_paths", "include_dirs",
        "extra_cbmc_args", "cbmc_args", "extra_goto_cc_args", "extra_goto_instrument_args",
    ):
        if list_key in tool_execution:
            value = tool_execution.get(list_key)
            if not isinstance(value, list) or any(not isinstance(item, str) for item in value):
                errors.append(f"tool_execution.{list_key} must be a list of strings when provided.")
    for timeout_key in ("step_timeout_seconds", "pipeline_timeout_seconds"):
        value = tool_execution.get(timeout_key)
        if isinstance(value, bool) or not isinstance(value, (int, float)) or value <= 0:
            errors.append(f"tool_execution.{timeout_key} must be a positive number.")
    step = tool_execution.get("step_timeout_seconds")
    pipeline = tool_execution.get("pipeline_timeout_seconds")
    if isinstance(step, (int, float)) and isinstance(pipeline, (int, float)) and pipeline < step:
        errors.append("tool_execution.pipeline_timeout_seconds must be >= step_timeout_seconds.")
    if tool_execution.get("structured_json_required") is not True:
        errors.append("tool_execution.structured_json_required must be true for authoritative CBMC evidence.")
    protocol = config.get("experiment_protocol", {})
    if (
        isinstance(protocol, Mapping)
        and bool(protocol.get("structured_cbmc_json_required", True))
        and tool_execution.get("structured_json_required") is not True
    ):
        errors.append("experiment_protocol requires structured CBMC JSON but tool_execution does not enable it.")


def _validate_llm_config(config: Mapping[str, Any], errors: List[str]) -> None:
    llm = config.get("llm", {})
    if llm is not None and not isinstance(llm, Mapping):
        errors.append("'llm' must be an object when provided.")
        llm = {}
    if not isinstance(llm, Mapping):
        return
    mode = str(llm.get("mode", "")).strip().lower()
    if mode and mode not in {"real", "mock", "disabled"}:
        errors.append("llm.mode must be one of: real, mock, disabled.")
    if str(llm.get("provider", "openai")).strip().lower() != "openai":
        errors.append("Only llm.provider='openai' is supported by this pipeline.")
    model = str(llm.get("model", "")).strip()
    placeholders = ("REPLACE_WITH", "SET_TO_", "CHOOSE_", "YOUR_MODEL")
    if mode == "real" and (not model or any(token in model.upper() for token in placeholders)):
        errors.append("Real LLM mode requires a concrete model identifier; placeholder model text is not allowed.")
    if mode == "real" and not str(llm.get("api_key_env", "")).strip():
        errors.append("Real LLM mode requires a non-empty llm.api_key_env name.")
    if "store" in llm and not isinstance(llm.get("store"), bool):
        errors.append("llm.store must be a JSON boolean when provided.")
    if mode == "real" and bool(llm.get("store", False)):
        errors.append("Thesis real-mode policy requires llm.store=false; local run records provide reproducibility.")
    execution_mode = str((config.get("tool_execution") or {}).get("execution_mode") or "reviewed")
    if mode == "real" and execution_mode == "reviewed":
        requirements = (
            ("require_json_object", True, "Reviewed real mode requires llm.require_json_object=true."),
            ("strict_json_object_only", True, "Reviewed real mode requires llm.strict_json_object_only=true."),
            ("validate_with_jsonschema", True, "Reviewed real mode requires llm.validate_with_jsonschema=true."),
            ("allow_minimal_schema_validation", False, "Reviewed real mode forbids minimal schema validation fallback."),
        )
        for key, expected, message in requirements:
            if llm.get(key, expected) is not expected:
                errors.append(message)
    retry_policy = llm.get("retry_policy", {})
    if not isinstance(retry_policy, Mapping):
        errors.append("llm.retry_policy must be an object after normalization.")
    else:
        for category in ("schema", "incomplete_response", "provider_error"):
            block = retry_policy.get(category)
            if not isinstance(block, Mapping):
                errors.append(f"llm.retry_policy.{category} must be an object.")
                continue
            if not isinstance(block.get("enabled"), bool):
                errors.append(f"llm.retry_policy.{category}.enabled must be boolean.")
            limit = block.get("max_retries")
            if isinstance(limit, bool) or not isinstance(limit, int) or limit < 0:
                errors.append(f"llm.retry_policy.{category}.max_retries must be a non-negative integer.")
    max_tokens = llm.get("max_output_tokens")
    if max_tokens is not None and (isinstance(max_tokens, bool) or not isinstance(max_tokens, int) or max_tokens <= 0):
        errors.append("llm.max_output_tokens must be a positive integer when provided.")
    reasoning = llm.get("reasoning")
    if reasoning is not None and not isinstance(reasoning, Mapping):
        errors.append("llm.reasoning must be an object when provided.")
    elif isinstance(reasoning, Mapping):
        for key in ("mode", "effort", "summary"):
            value = reasoning.get(key)
            if value is not None and (not isinstance(value, str) or not value.strip()):
                errors.append(f"llm.reasoning.{key} must be a non-empty string when provided.")
        summary = str(reasoning.get("summary") or "").strip().lower()
        if summary and summary not in {"auto", "concise", "detailed"}:
            errors.append("llm.reasoning.summary must be one of: auto, concise, detailed.")
    text_cfg = llm.get("text")
    if text_cfg is not None and not isinstance(text_cfg, Mapping):
        errors.append("llm.text must be an object when provided.")
    elif isinstance(text_cfg, Mapping):
        verbosity = str(text_cfg.get("verbosity") or "").strip().lower()
        if verbosity and verbosity not in {"low", "medium", "high"}:
            errors.append("llm.text.verbosity must be one of: low, medium, high.")
    client_cfg = llm.get("client")
    if client_cfg is not None and not isinstance(client_cfg, Mapping):
        errors.append("llm.client must be an object when provided.")
    elif isinstance(client_cfg, Mapping):
        timeout = client_cfg.get("timeout_seconds")
        if timeout is not None and (isinstance(timeout, bool) or not isinstance(timeout, (int, float)) or timeout <= 0):
            errors.append("llm.client.timeout_seconds must be a positive number when provided.")
    if mode == "real":
        errors.extend(_validate_real_mode_provenance(config))
    profile = config.get("_llm_profile")
    if profile is not None:
        if not isinstance(profile, Mapping):
            errors.append("_llm_profile must be an object when present.")
        else:
            expected_hash = str(profile.get("resolved_llm_sha256") or "").strip()
            if not expected_hash or expected_hash != canonical_json_sha256(dict(llm)):
                errors.append("Resolved LLM profile hash does not match the embedded llm configuration.")


def validate_pipeline_config(
    config: Mapping[str, Any],
    *,
    check_input_files: bool = True,
) -> ConfigValidationReport:
    """Validate the canonical full-pipeline configuration without mutating it."""
    errors: List[str] = []
    warnings: List[str] = []
    _validate_workspace_mode(config, errors)
    warnings.extend(_obsolete_release_field_warnings(config))

    required_text = ("target_scheme", "target_function", "verification_tool", "artifact_type")
    for key in required_text:
        value = config.get(key)
        if not isinstance(value, str) or not value.strip():
            errors.append(f"'{key}' must be a non-empty string.")

    iterations = config.get("max_iterations")
    if isinstance(iterations, bool) or not isinstance(iterations, int):
        errors.append("'max_iterations' must be an integer between 0 and 20.")
    elif not 0 <= iterations <= 20:
        errors.append("'max_iterations' must be between 0 and 20.")
    elif iterations > 5:
        warnings.append("max_iterations is above 5; thesis experiments normally use 2 or 3 to control cost and evidence volume.")

    inputs = config.get("inputs")
    if not isinstance(inputs, Mapping):
        errors.append("'inputs' must be an object after normalization.")
        inputs = {}

    contract = config.get("_config_contract", {})
    if isinstance(contract, Mapping):
        if contract.get("primary_spec_conflict"):
            candidates = contract.get("primary_spec_candidates", {})
            errors.append(f"Conflicting primary specification aliases resolve to different files: {candidates}")
        if contract.get("primary_source_conflict"):
            candidates = contract.get("primary_source_candidates", {})
            errors.append(f"Conflicting primary source aliases resolve to different files: {candidates}")

    spec_values = inputs.get("spec_paths", []) if isinstance(inputs, Mapping) else []
    code_values = inputs.get("code_paths", []) if isinstance(inputs, Mapping) else []
    if not isinstance(spec_values, list) or not spec_values:
        errors.append("At least one specification file is required in inputs.spec_paths (or a supported legacy alias).")
    if not isinstance(code_values, list) or not code_values:
        errors.append("At least one implementation file is required in inputs.code_paths (or a supported legacy alias/code_dir).")

    source_file = config.get("source_file")
    spec_file = config.get("spec_file")
    if not source_file:
        errors.append("Canonical top-level 'source_file' could not be derived.")
    if not spec_file:
        errors.append("Canonical top-level 'spec_file' could not be derived.")

    if isinstance(inputs, Mapping):
        if inputs.get("primary_source") and source_file and str(inputs.get("primary_source")) != str(source_file):
            errors.append("inputs.primary_source and source_file are not synchronized.")
        if inputs.get("primary_spec") and spec_file and str(inputs.get("primary_spec")) != str(spec_file):
            errors.append("inputs.primary_spec and spec_file are not synchronized.")

    if check_input_files:
        for label, values in (("specification", spec_values), ("implementation", code_values)):
            if not isinstance(values, list):
                continue
            for value in values:
                path = Path(str(value))
                if not path.exists():
                    errors.append(f"{label.capitalize()} input does not exist: {path}")
                elif not path.is_file():
                    errors.append(f"{label.capitalize()} input is not a regular file: {path}")

        errors.extend(_validate_archival_spec_inputs(inputs))

        code_dir = inputs.get("code_dir") if isinstance(inputs, Mapping) else None
        if code_dir:
            path = Path(str(code_dir))
            if not path.exists():
                errors.append(f"Configured code directory does not exist: {path}")
            elif not path.is_dir():
                errors.append(f"Configured code directory is not a directory: {path}")

    run_id = config.get("run_id")
    if run_id is not None and (not isinstance(run_id, str) or not run_id.strip()):
        errors.append("'run_id', when provided, must be a non-empty string.")

    errors.extend(validate_experiment_protocol(config))
    errors.extend(validate_property_discovery_config(config))

    campaign = config.get("property_campaign", {})
    if not isinstance(campaign, Mapping):
        errors.append("'property_campaign' must be an object after normalization.")
    elif str((config.get("property_discovery") or {}).get("mode") or "targeted_campaign") == "targeted_campaign":
        family_id = str(campaign.get("property_family_id") or "")
        strategy = str(campaign.get("verification_strategy") or "")
        try:
            family = get_property_family(family_id)
            if strategy not in strategy_ids():
                errors.append(f"Unknown property_campaign.verification_strategy: {strategy!r}.")
            elif strategy not in family.get("allowed_strategies", []):
                errors.append(
                    f"Strategy {strategy!r} is not allowed for property family {family_id}; "
                    f"allowed: {family.get('allowed_strategies', [])}."
                )
            if family.get("support_level") == "analysis_only" and not bool(campaign.get("allow_analysis_only")):
                errors.append(
                    f"Property family {family_id} is analysis-only and requires property_campaign.allow_analysis_only=true."
                )
        except KeyError as exc:
            errors.append(str(exc))

    _validate_tool_execution_config(config, errors)
    errors.extend(_validate_formal_strategy_reconciliation(config))
    errors.extend(_validate_formal_artifact_policy(config))
    _validate_llm_config(config, errors)

    if config.get("config_schema_version") != CONFIG_SCHEMA_VERSION:
        warnings.append(
            f"config_schema_version is not '{CONFIG_SCHEMA_VERSION}'; normalize the config before execution."
        )

    return ConfigValidationReport(valid=not errors, errors=tuple(errors), warnings=tuple(warnings))


def canonical_input_summary(config: Mapping[str, Any]) -> JsonDict:
    inputs = config.get("inputs", {})
    if not isinstance(inputs, Mapping):
        inputs = {}
    return {
        "project_root": config.get("project_root"),
        "run_id": config.get("run_id"),
        "run_dir": config.get("run_dir"),
        "primary_spec": inputs.get("primary_spec"),
        "spec_paths": list(inputs.get("spec_paths", [])) if isinstance(inputs.get("spec_paths", []), list) else [],
        "archival_spec_paths": list(inputs.get("archival_spec_paths", [])) if isinstance(inputs.get("archival_spec_paths", []), list) else [],
        "primary_source": inputs.get("primary_source"),
        "code_paths": list(inputs.get("code_paths", [])) if isinstance(inputs.get("code_paths", []), list) else [],
        "code_dir": inputs.get("code_dir"),
        "property_campaign": copy.deepcopy(config.get("property_campaign", {})),
        "experiment_protocol": copy.deepcopy(config.get("experiment_protocol", {})),
    }
