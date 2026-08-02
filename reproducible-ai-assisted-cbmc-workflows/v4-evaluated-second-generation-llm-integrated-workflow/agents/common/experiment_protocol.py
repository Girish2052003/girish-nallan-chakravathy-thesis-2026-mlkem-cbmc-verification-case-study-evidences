#!/usr/bin/env python3
"""Canonical experiment protocol and release-safety helpers.

The protocol is deliberately immutable once a run is created.  Every stage
records the same protocol hash so that semantic-advisory mode, repair policy,
property family, verification strategy, model profile, and provenance cannot
silently drift between stages.
"""
from __future__ import annotations

import copy
import hashlib
import json
from pathlib import Path
from typing import Any, Dict, Mapping, Optional, Sequence, Tuple

JsonDict = Dict[str, Any]
PROTOCOL_VERSION = "llm-first-v1"
SEMANTIC_ADVISORY_MODES = {"off", "reference_only", "baseline_only"}
REPAIR_POLICIES = {"none_initial_run", "single_repair_followup", "bounded_repair"}
DEFAULT_PROMPT_BUDGET: JsonDict = {
    "max_request_bytes": 450_000,
    "max_retry_growth_percent": 10,
    "max_stage_input_tokens_estimate": 120_000,
    "max_total_input_tokens_estimate": 600_000,
}


class ExperimentProtocolError(ValueError):
    """Raised when experiment settings contradict the canonical protocol."""


def canonical_json_sha256(value: Mapping[str, Any]) -> str:
    payload = json.dumps(dict(value), ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def _mapping(value: Any) -> JsonDict:
    return copy.deepcopy(dict(value)) if isinstance(value, Mapping) else {}


def build_experiment_protocol(config: Mapping[str, Any]) -> JsonDict:
    """Return a canonical protocol block derived from one normalized config."""
    existing = _mapping(config.get("experiment_protocol"))
    campaign = _mapping(config.get("property_campaign"))
    provenance = _mapping(config.get("provenance"))
    llm_meta = _mapping(config.get("_llm_profile"))
    llm = _mapping(config.get("llm"))

    mode = str(existing.get("semantic_advisory_mode") or "off").strip().lower()
    configured_iterations = config.get("max_iterations", 0)
    if isinstance(configured_iterations, bool) or not isinstance(configured_iterations, int):
        configured_iterations = 0
    inferred_repair_policy = (
        "none_initial_run" if configured_iterations == 0
        else "single_repair_followup" if configured_iterations == 1
        else "bounded_repair"
    )
    repair_policy = str(existing.get("repair_policy") or inferred_repair_policy).strip().lower()
    raw_retry_controls = _mapping(existing.get("repair_retry_controls"))

    def repair_control(category: str) -> JsonDict:
        raw = _mapping(raw_retry_controls.get(category))
        enabled = bool(raw.get("enabled", configured_iterations > 0))
        # A disabled category is unambiguously zero-budget even when the outer
        # experiment permits other repair categories.  This keeps user control
        # independent instead of manufacturing a contradictory normalized
        # protocol (enabled=false with a positive implicit limit).
        default_limit = max(0, configured_iterations) if enabled else 0
        return {
            "enabled": enabled,
            "max_repairs": int(raw.get("max_repairs", default_limit)),
        }

    repair_retry_controls = {
        "tool_diagnostic_repair": repair_control("tool_diagnostic_repair"),
        "semantic_repair": repair_control("semantic_repair"),
    }
    prompt_budget = copy.deepcopy(DEFAULT_PROMPT_BUDGET)
    prompt_budget.update(_mapping(existing.get("prompt_budget")))

    protocol: JsonDict = {
        "protocol_version": str(existing.get("protocol_version") or PROTOCOL_VERSION),
        "semantic_advisory_mode": mode,
        "repair_policy": repair_policy,
        "repair_retry_controls": repair_retry_controls,
        "property_discovery_mode": str((_mapping(config.get("property_discovery"))).get("mode") or "targeted_campaign"),
        "property_family": str(
            existing.get("property_family")
            or campaign.get("property_family_id")
            or config.get("property_family_id")
            or ""
        ),
        "strategy": str(
            existing.get("strategy")
            or campaign.get("verification_strategy")
            or ""
        ),
        "model_profile_sha256": str(
            existing.get("model_profile_sha256")
            or llm_meta.get("resolved_llm_sha256")
            or ""
        ),
        "model_identifier": str(existing.get("model_identifier") or llm.get("model") or ""),
        "source_revision": str(existing.get("source_revision") or provenance.get("source_revision") or ""),
        "prompt_budget": prompt_budget,
        "initial_run_requires_zero_repairs": bool(
            existing.get("initial_run_requires_zero_repairs", True)
        ),
        "selected_property_claims_required": bool(
            existing.get("selected_property_claims_required", True)
        ),
        "structured_cbmc_json_required": bool(
            existing.get("structured_cbmc_json_required", True)
        ),
        "mutation_non_vacuity_required": bool(
            existing.get("mutation_non_vacuity_required", True)
        ),
    }
    protocol["protocol_sha256"] = canonical_json_sha256(protocol)
    return protocol


def validate_experiment_protocol(config: Mapping[str, Any]) -> Tuple[str, ...]:
    protocol = _mapping(config.get("experiment_protocol"))
    errors = []
    if not protocol:
        return ("experiment_protocol is required after configuration normalization.",)

    version = str(protocol.get("protocol_version") or "")
    if version != PROTOCOL_VERSION:
        errors.append(f"experiment_protocol.protocol_version must be {PROTOCOL_VERSION!r}.")

    mode = str(protocol.get("semantic_advisory_mode") or "").lower()
    if mode not in SEMANTIC_ADVISORY_MODES:
        errors.append(
            "experiment_protocol.semantic_advisory_mode must be one of: "
            + ", ".join(sorted(SEMANTIC_ADVISORY_MODES))
        )

    repair_policy = str(protocol.get("repair_policy") or "").lower()
    if repair_policy not in REPAIR_POLICIES:
        errors.append(
            "experiment_protocol.repair_policy must be one of: "
            + ", ".join(sorted(REPAIR_POLICIES))
        )

    retry_controls = _mapping(protocol.get("repair_retry_controls"))
    for category in ("tool_diagnostic_repair", "semantic_repair"):
        block = _mapping(retry_controls.get(category))
        if not block:
            errors.append(f"experiment_protocol.repair_retry_controls.{category} is required.")
            continue
        if not isinstance(block.get("enabled"), bool):
            errors.append(f"experiment_protocol.repair_retry_controls.{category}.enabled must be boolean.")
        limit = block.get("max_repairs")
        if isinstance(limit, bool) or not isinstance(limit, int) or limit < 0:
            errors.append(f"experiment_protocol.repair_retry_controls.{category}.max_repairs must be a non-negative integer.")
        if block.get("enabled") is False and isinstance(limit, int) and limit != 0:
            errors.append(f"Disabled {category} must use max_repairs=0 to avoid contradictory policy.")

    iterations = config.get("max_iterations")
    if repair_policy == "none_initial_run" and iterations != 0:
        errors.append(
            "Initial LLM-first experiments use repair_policy='none_initial_run' and require max_iterations=0."
        )
    if repair_policy == "single_repair_followup" and iterations != 1:
        errors.append(
            "single_repair_followup requires max_iterations=1 and a distinct follow-up run_id."
        )

    discovery = _mapping(config.get("property_discovery"))
    discovery_mode = str(discovery.get("mode") or "targeted_campaign")
    if str(protocol.get("property_discovery_mode") or "") != discovery_mode:
        errors.append("experiment_protocol.property_discovery_mode disagrees with property_discovery.mode.")

    campaign = _mapping(config.get("property_campaign"))
    if str(protocol.get("property_family") or "") != str(campaign.get("property_family_id") or ""):
        errors.append("experiment_protocol.property_family disagrees with property_campaign.property_family_id.")
    if str(protocol.get("strategy") or "") != str(campaign.get("verification_strategy") or ""):
        errors.append("experiment_protocol.strategy disagrees with property_campaign.verification_strategy.")

    expected_hash = canonical_json_sha256({k: v for k, v in protocol.items() if k != "protocol_sha256"})
    if str(protocol.get("protocol_sha256") or "") != expected_hash:
        errors.append("experiment_protocol.protocol_sha256 does not match the canonical protocol content.")

    budget = _mapping(protocol.get("prompt_budget"))
    for key in (
        "max_request_bytes",
        "max_stage_input_tokens_estimate",
        "max_total_input_tokens_estimate",
    ):
        value = budget.get(key)
        if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
            errors.append(f"experiment_protocol.prompt_budget.{key} must be a positive integer.")

    # This is a user-controlled operational budget, not a hidden protocol
    # ceiling.  Zero means that retry requests may not grow; any larger
    # non-negative integer (for example 100 or 150) is accepted explicitly.
    retry_growth = budget.get("max_retry_growth_percent")
    if isinstance(retry_growth, bool) or not isinstance(retry_growth, int) or retry_growth < 0:
        errors.append(
            "experiment_protocol.prompt_budget.max_retry_growth_percent "
            "must be a non-negative integer."
        )

    return tuple(errors)


def semantic_advisory_mode(config: Mapping[str, Any]) -> str:
    protocol = config.get("experiment_protocol")
    if isinstance(protocol, Mapping):
        mode = str(protocol.get("semantic_advisory_mode") or "off").strip().lower()
        if mode in SEMANTIC_ADVISORY_MODES:
            return mode
    return "off"


def semantic_advisory_enabled(config: Mapping[str, Any]) -> bool:
    return semantic_advisory_mode(config) == "reference_only"


def semantic_reference_or_none(config: Mapping[str, Any], bundle: Optional[JsonDict]) -> Optional[JsonDict]:
    """Return semantic advisory material only in the explicit comparison mode."""
    return bundle if semantic_advisory_enabled(config) else None


def prompt_budget(config: Mapping[str, Any]) -> JsonDict:
    protocol = config.get("experiment_protocol")
    result = copy.deepcopy(DEFAULT_PROMPT_BUDGET)
    if isinstance(protocol, Mapping) and isinstance(protocol.get("prompt_budget"), Mapping):
        result.update(dict(protocol["prompt_budget"]))
    return result


def logical_path(path: Any, roots: Sequence[Tuple[str, Any]]) -> str:
    """Return a portable logical path when *path* is below a configured root."""
    p = Path(str(path)).expanduser().resolve()
    for token, root in roots:
        if root in (None, ""):
            continue
        r = Path(str(root)).expanduser().resolve()
        try:
            rel = p.relative_to(r)
        except ValueError:
            continue
        return token if str(rel) == "." else f"{token}/{rel.as_posix()}"
    return str(p)


__all__ = [
    "DEFAULT_PROMPT_BUDGET",
    "ExperimentProtocolError",
    "PROTOCOL_VERSION",
    "REPAIR_POLICIES",
    "SEMANTIC_ADVISORY_MODES",
    "build_experiment_protocol",
    "canonical_json_sha256",
    "logical_path",
    "prompt_budget",
    "semantic_advisory_enabled",
    "semantic_advisory_mode",
    "semantic_reference_or_none",
    "validate_experiment_protocol",
]
