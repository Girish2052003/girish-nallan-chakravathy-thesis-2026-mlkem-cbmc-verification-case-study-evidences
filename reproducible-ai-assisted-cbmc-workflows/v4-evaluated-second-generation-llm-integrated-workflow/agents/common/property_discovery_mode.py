"""Discovery-mode controls and post-LLM catalogue classification.

This module keeps two scientifically distinct workflows separate:

* ``targeted_campaign`` preserves the existing P01--P26 campaign behaviour.
* ``open_discovery`` hides the deterministic catalogue from Agents 2--4,
  preserves the raw Agent 4 output, classifies candidates only afterwards,
  permits ``UNMAPPED`` candidates, and selects one concrete candidate before
  Agent 5.

Classification is deterministic experiment metadata, not formal evidence and
not a claim that a candidate is true or provable.
"""
from __future__ import annotations

import copy
import re
from typing import Any, Dict, List, Mapping, Optional, Sequence, Tuple

from agents.common.semantic_property import choose_property, normalize_semantic_property, possible_encodings

from agents.common.semantic_property import canonical_selection_policy
from agents.common.property_catalog import (
    ANALYSIS_ONLY,
    FUNCTION_CONTRACT,
    LOOP_CONTRACT,
    PROPERTY_FAMILIES,
    RELATIONAL,
    STANDARD,
    get_property_family,
    property_family_ids,
    strategy_ids,
)

JsonDict = Dict[str, Any]
TARGETED_CAMPAIGN = "targeted_campaign"
OPEN_DISCOVERY = "open_discovery"
DISCOVERY_MODES = {TARGETED_CAMPAIGN, OPEN_DISCOVERY}
CATALOGUE_HIDDEN = "hidden"
UNMAPPED_FAMILY_ID = "UNMAPPED"
UNSELECTED_STRATEGY = "UNSELECTED"


class PropertyDiscoveryModeError(ValueError):
    """Raised when discovery-mode configuration is contradictory."""


def _mapping(value: Any) -> JsonDict:
    return copy.deepcopy(dict(value)) if isinstance(value, Mapping) else {}


def discovery_mode(config: Mapping[str, Any]) -> str:
    block = config.get("property_discovery")
    if isinstance(block, Mapping):
        value = str(block.get("mode") or TARGETED_CAMPAIGN).strip().lower()
        if value in DISCOVERY_MODES:
            return value
    return TARGETED_CAMPAIGN


def is_open_discovery(config: Mapping[str, Any]) -> bool:
    return discovery_mode(config) == OPEN_DISCOVERY


def normalize_property_discovery(
    config: Mapping[str, Any],
    *,
    campaign_explicit: bool,
) -> JsonDict:
    """Return a canonical discovery block without changing targeted defaults."""
    raw = _mapping(config.get("property_discovery"))
    requested = str(raw.get("mode") or TARGETED_CAMPAIGN).strip().lower()
    if requested not in DISCOVERY_MODES:
        raise PropertyDiscoveryModeError(
            "property_discovery.mode must be one of: "
            + ", ".join(sorted(DISCOVERY_MODES))
        )

    requested_selection_policy = str(
        raw.get("selection_policy")
        or ("llm_ranked" if requested == OPEN_DISCOVERY else "configured_campaign_preferred_category")
    ).strip()
    canonical_policy = canonical_selection_policy(requested_selection_policy)
    policy_audit = (
        {"selection_policy_migrated_from": requested_selection_policy}
        if canonical_policy != requested_selection_policy else {}
    )

    if requested == OPEN_DISCOVERY:
        visibility = str(raw.get("catalogue_visibility") or CATALOGUE_HIDDEN).strip().lower()
        if visibility != CATALOGUE_HIDDEN:
            raise PropertyDiscoveryModeError(
                "open_discovery requires property_discovery.catalogue_visibility='hidden'."
            )
        allow_uncatalogued = bool(raw.get("allow_uncatalogued_properties", True))
        if not allow_uncatalogued:
            raise PropertyDiscoveryModeError(
                "open_discovery requires allow_uncatalogued_properties=true; otherwise the catalogue remains a hidden hard boundary."
            )
        selected_property_id = str(raw.get("selected_property_id") or "").strip()
        return {
            **raw,
            "schema_version": "property_discovery.v2",
            "mode": OPEN_DISCOVERY,
            "catalogue_visibility": CATALOGUE_HIDDEN,
            "allow_uncatalogued_properties": True,
            "selected_property_id": selected_property_id or None,
            "selection_policy": canonical_policy,
            **policy_audit,
            "classification_timing": "post_llm_authoritative_output",
            "raw_candidate_family_marker": UNMAPPED_FAMILY_ID,
            "raw_candidate_strategy_marker": UNSELECTED_STRATEGY,
        }

    return {
        **raw,
        "schema_version": "property_discovery.v2",
        "mode": TARGETED_CAMPAIGN,
        "catalogue_visibility": str(raw.get("catalogue_visibility") or "configured_family_only"),
        "allow_uncatalogued_properties": bool(raw.get("allow_uncatalogued_properties", False)),
        "selected_property_id": str(raw.get("selected_property_id") or "").strip() or None,
        "selection_policy": canonical_policy,
        **policy_audit,
        "classification_timing": "configured_before_llm",
        "campaign_explicit": bool(campaign_explicit),
    }


def validate_property_discovery_config(config: Mapping[str, Any]) -> Tuple[str, ...]:
    errors: List[str] = []
    block = config.get("property_discovery")
    if not isinstance(block, Mapping):
        return ("property_discovery must be an object after normalization.",)
    mode = str(block.get("mode") or "")
    if mode not in DISCOVERY_MODES:
        errors.append("Unknown property_discovery.mode: " + repr(mode))
        return tuple(errors)

    campaign = config.get("property_campaign")
    if not isinstance(campaign, Mapping):
        errors.append("property_campaign must be an object after normalization.")
        return tuple(errors)

    if mode == OPEN_DISCOVERY:
        protocol = config.get("experiment_protocol")
        if isinstance(protocol, Mapping) and str(protocol.get("semantic_advisory_mode") or "off") != "off":
            errors.append("Open discovery requires experiment_protocol.semantic_advisory_mode='off' so no deterministic semantic catalogue can reach Agents 2--4.")
        if str(block.get("catalogue_visibility") or "") != CATALOGUE_HIDDEN:
            errors.append("Open discovery must hide the property catalogue from Agents 2--4.")
        if not bool(block.get("allow_uncatalogued_properties")):
            errors.append("Open discovery must allow uncatalogued properties.")
        if campaign.get("property_family_id") not in (None, "", UNMAPPED_FAMILY_ID):
            errors.append("Open discovery may not preselect a P01--P26 property family.")
        if campaign.get("verification_strategy") not in (None, "", UNSELECTED_STRATEGY):
            errors.append("Open discovery may not preselect a verification strategy.")
    else:
        family_id = str(campaign.get("property_family_id") or "")
        strategy = str(campaign.get("verification_strategy") or "")
        if family_id not in property_family_ids():
            errors.append("Targeted campaign requires a valid P01--P26 property_family_id.")
        if strategy not in strategy_ids():
            errors.append("Targeted campaign requires a supported verification_strategy.")
    return tuple(errors)


def open_discovery_campaign_placeholder() -> JsonDict:
    """Return non-semantic control metadata for an unselected open run."""
    return {
        "schema_version": "property_campaign.v2.open_unselected",
        "property_family_id": UNMAPPED_FAMILY_ID,
        "property_family_slug": "unmapped_open_discovery",
        "property_family_title": "Unmapped open-discovery candidate",
        "verification_strategy": UNSELECTED_STRATEGY,
        "support_level": "unclassified",
        "claim_boundary": "No property family or formal strategy is selected before open LLM discovery.",
        "allowed_strategies": [],
        "target_examples": [],
        "allow_analysis_only": True,
        "require_native_contract_tools": False,
        "explicitly_configured": False,
        "legacy_compatibility_default": False,
        "discovery_mode": OPEN_DISCOVERY,
        "selection_pending": True,
    }


def _tokens(text: str) -> List[str]:
    tokens: List[str] = []
    for token in re.split(r"[^a-z0-9]+", text.lower()):
        if len(token) < 3:
            continue
        # Conservative singularisation improves obvious lexical matches such as
        # "array bounds" versus "object bound" without using the catalogue to
        # generate or rewrite any candidate semantics.
        if len(token) > 4 and token.endswith("s") and not token.endswith("ss"):
            token = token[:-1]
        tokens.append(token)
    return tokens


_FAMILY_ALIASES: Dict[str, Sequence[str]] = {
    "P01": ("array bound", "index bound", "out of bounds", "memory access"),
    "P02": ("barrett",),
    "P03": ("compression output", "compress range"),
    "P04": ("decompression", "decompress coefficient"),
    "P05": ("encoding length", "encoded length", "write length"),
    "P06": ("round trip", "encode decode", "serialization round trip"),
    "P07": ("api buffer", "global buffer"),
    "P08": ("hash buffer", "xof buffer", "shake buffer"),
    "P09": ("integer overflow", "signed overflow", "arithmetic overflow"),
    "P10": ("packing consistency", "pack unpack", "join split"),
    "P11": ("keypair output", "keypair size"),
    "P12": ("loop invariant", "inductive invariant"),
    "P13": ("montgomery",),
    "P14": ("ntt bound", "inverse ntt", "number theoretic transform"),
    "P15": ("non alias", "nonalias", "buffer separation", "overlap"),
    "P16": ("polynomial add", "polynomial sub", "coefficient sum", "coefficient difference"),
    "P17": ("modulus range", "q range", "canonical coefficient"),
    "P18": ("rejection sampling", "rej uniform", "sampling safety"),
    "P19": ("secret independent", "constant time", "secret dependent branch", "secret dependent memory"),
    "P20": ("decapsulation memory", "crypto kem dec"),
    "P21": ("unpack validation", "unpack safety"),
    "P22": ("vector operation", "polyvec"),
    "P23": ("zeroization", "wipe", "clear secret"),
    "P24": ("xof deterministic", "deterministic expansion", "shake determinism"),
    "P25": ("return code", "return value range"),
    "P26": ("valid pointer", "pointer precondition", "size precondition", "invalid size"),
}


def _family_score(candidate_text: str, family: Mapping[str, Any]) -> int:
    low = candidate_text.lower()
    score = 0
    slug = str(family.get("slug") or "").replace("_", " ")
    title = str(family.get("title") or "")
    candidate_tokens = set(_tokens(low))
    for phrase in (slug, title, *_FAMILY_ALIASES.get(str(family.get("id")), ())):
        phrase_low = phrase.lower().strip()
        if not phrase_low:
            continue
        if phrase_low in low:
            score += 8 if " " in phrase_low else 5
            continue
        phrase_tokens = set(_tokens(phrase_low))
        if len(phrase_tokens) >= 2 and phrase_tokens.issubset(candidate_tokens):
            score += 6
        elif len(phrase_tokens & candidate_tokens) >= 2:
            score += 2
    family_tokens = set(_tokens(slug + " " + title))
    score += len(family_tokens & candidate_tokens)
    return score


def _strategy_for_candidate(candidate: Mapping[str, Any], family: Optional[Mapping[str, Any]]) -> str:
    """Return a non-authoritative catalogue recommendation only.

    Execution strategy is intentionally not selected here.  This helper remains
    solely to preserve family recommendation metadata for later user/model
    consideration.
    """
    if family is None:
        return STANDARD
    return str(family.get("default_strategy") or STANDARD)


def classify_open_candidate(candidate: Mapping[str, Any], *, index: int) -> JsonDict:
    """Classify one raw open candidate without mutating or deleting it."""
    original = copy.deepcopy(dict(candidate))
    raw_id = str(original.get("property_id") or "").strip()
    stable_id = raw_id or f"OPEN_CAND_{index:03d}"
    searchable = " ".join(
        str(original.get(key) or "")
        for key in (
            "title",
            "category",
            "candidate_statement",
            "proof_obligation_kind",
            "expected_artifact_type",
        )
    )
    scored = sorted(
        (( _family_score(searchable, family), family) for family in PROPERTY_FAMILIES),
        key=lambda item: (-item[0], str(item[1].get("id"))),
    )
    best_score, best_family = scored[0]
    second_score = scored[1][0] if len(scored) > 1 else 0
    mapped = best_score >= 6 and best_score >= second_score + 2
    family = copy.deepcopy(best_family) if mapped else None
    family_id = str(family.get("id")) if family else UNMAPPED_FAMILY_ID
    family_recommendation = _strategy_for_candidate(original, family)
    semantic_property = normalize_semantic_property(original)
    encodings = possible_encodings(semantic_property)
    support = str(family.get("support_level")) if family else "uncatalogued_candidate"
    boundaries = original.get("out_of_scope_boundaries")
    if not isinstance(boundaries, list):
        boundaries = []
    if family and family.get("claim_boundary") and family["claim_boundary"] not in boundaries:
        boundaries = [*boundaries, str(family["claim_boundary"])]

    canonical: JsonDict = {
        "property_id": stable_id,
        "property_family_id": family_id,
        "title": str(original.get("title") or stable_id),
        "category": str(original.get("category") or "uncategorized"),
        "verification_strategy": UNSELECTED_STRATEGY,
        "proposed_strategy": str(original.get("verification_strategy") or UNSELECTED_STRATEGY),
        "family_recommendation": family_recommendation,
        "selection_authority": "not_selected_before_agent5",
        "possible_encodings": encodings,
        "semantic_property": semantic_property,
        "proof_obligation_kind": str(original.get("proof_obligation_kind") or "other"),
        "support_classification": support,
        "required_tool_capabilities": [],
        "candidate_statement": str(original.get("candidate_statement") or ""),
        "supporting_evidence": copy.deepcopy(original.get("supporting_evidence") or []),
        "required_assumptions": [str(x) for x in (original.get("required_assumptions") or [])],
        "cbmc_feasibility": str(original.get("cbmc_feasibility") or "unknown"),
        "risk_level": str(original.get("risk_level") or "unknown"),
        "expected_artifact_type": "strategy-neutral semantic property; Agent 5 must select an explicit encoding",
        "out_of_scope_boundaries": [str(x) for x in boundaries],
        "uncertainty": str(original.get("uncertainty") or ""),
        "limitations": [str(x) for x in (original.get("limitations") or [])],
    }
    classification = {
        "property_id": stable_id,
        "catalogue_family_id": family_id,
        "catalogue_family_title": str(family.get("title")) if family else "Unmapped/new property",
        "verification_strategy": UNSELECTED_STRATEGY,
        "family_strategy_recommendation": family_recommendation,
        "strategy_is_execution_authority": False,
        "classification_status": "mapped" if family else "unmapped_new",
        "classification_score": best_score,
        "runner_up_score": second_score,
        "classification_basis": "post_llm_catalogue_metadata_only_no_strategy_selection",
        "raw_candidate_preserved": True,
        "candidate_not_rejected_for_being_uncatalogued": True,
        "claim_boundary": "Classification is experiment metadata, not proof and not a truth judgment.",
    }
    return {"canonical_candidate": canonical, "classification": classification, "raw_candidate": original}


def classify_open_candidates(raw_payload: Mapping[str, Any]) -> Tuple[JsonDict, JsonDict]:
    raw_candidates = raw_payload.get("candidate_properties")
    if not isinstance(raw_candidates, list):
        raw_candidates = []
    canonical_candidates: List[JsonDict] = []
    classifications: List[JsonDict] = []
    raw_snapshots: List[JsonDict] = []
    seen: Dict[str, int] = {}
    for index, item in enumerate(raw_candidates, start=1):
        if not isinstance(item, Mapping):
            continue
        result = classify_open_candidate(item, index=index)
        candidate = result["canonical_candidate"]
        base_id = str(candidate["property_id"])
        seen[base_id] = seen.get(base_id, 0) + 1
        if seen[base_id] > 1:
            candidate["property_id"] = f"{base_id}_{seen[base_id]:02d}"
            result["classification"]["property_id"] = candidate["property_id"]
        canonical_candidates.append(candidate)
        classifications.append(result["classification"])
        raw_snapshots.append(result["raw_candidate"])

    derived: JsonDict = {
        "stage": "04_property_discovery",
        "mock": bool(raw_payload.get("mock")),
        "llm_call_executed": bool(raw_payload.get("llm_call_executed")),
        "source_scope": copy.deepcopy(raw_payload.get("source_scope") or {}),
        "candidate_properties": canonical_candidates,
        "rejected_or_downgraded_properties": copy.deepcopy(raw_payload.get("rejected_or_downgraded_properties") or []),
        "assumptions_catalogue": copy.deepcopy(raw_payload.get("assumptions_catalogue") or []),
        "feasibility_ranking": copy.deepcopy(raw_payload.get("feasibility_ranking") or []),
        "uncertainty_register": copy.deepcopy(raw_payload.get("uncertainty_register") or []),
        "deterministic_reference_assessment": {
            "used": False,
            "status": "not_provided_to_open_discovery_llm",
            "warning": "The P01--P26 semantic catalogue was hidden from Agents 2--4 and used only after raw Agent 4 output persistence.",
            "disagreements": [],
        },
        "evidence_references": copy.deepcopy(raw_payload.get("evidence_references") or []),
        "limitations": copy.deepcopy(raw_payload.get("limitations") or []),
    }
    audit = {
        "schema_version": "open_discovery_post_classification.v1",
        "discovery_mode": OPEN_DISCOVERY,
        "catalogue_was_visible_to_llm": False,
        "raw_candidate_count": len(raw_snapshots),
        "derived_candidate_count": len(canonical_candidates),
        "mapped_count": sum(1 for row in classifications if row["classification_status"] == "mapped"),
        "unmapped_count": sum(1 for row in classifications if row["classification_status"] == "unmapped_new"),
        "classifications": classifications,
        "raw_candidate_ids": [str(item.get("property_id") or "") for item in raw_snapshots],
        "candidate_deletion_permitted": False,
        "candidate_rewrite_permitted": False,
        "claim_boundary": "Post-discovery classification organizes candidates; it does not establish truth, feasibility, or proof.",
    }
    return derived, audit


def select_open_candidate(
    classified_payload: Mapping[str, Any],
    *,
    selected_property_id: Optional[str] = None,
    selection_policy: str = "llm_ranked",
) -> JsonDict:
    candidates = classified_payload.get("candidate_properties")
    if not isinstance(candidates, list):
        candidates = []
    candidates = [copy.deepcopy(dict(item)) for item in candidates if isinstance(item, Mapping)]
    if not candidates:
        raise PropertyDiscoveryModeError("Open discovery produced no candidate property to select before Agent 5.")

    try:
        chosen, method = choose_property(
            candidates,
            policy=str(selection_policy or "llm_ranked"),
            selected_property_id=selected_property_id,
            ranking_rows=(classified_payload.get("feasibility_ranking") or []),
        )
    except ValueError as exc:
        raise PropertyDiscoveryModeError(str(exc)) from exc

    return {
        "schema_version": "selected_property_handoff.v1",
        "discovery_mode": OPEN_DISCOVERY,
        "selected": True,
        "selection_method": method,
        "property": chosen,
        "selection_reason": (
            "Selected after the LLM-authored candidate set was saved and post-classified. "
            "Selection is an experiment-control decision, not proof that the property is true."
        ),
        "catalogue_mapping_status": (
            "unmapped_new" if chosen.get("property_family_id") == UNMAPPED_FAMILY_ID else "mapped"
        ),
    }


def effective_campaign_from_selected(selection: Mapping[str, Any]) -> JsonDict:
    prop = selection.get("property") if isinstance(selection.get("property"), Mapping) else {}
    family_id = str(prop.get("property_family_id") or UNMAPPED_FAMILY_ID)
    strategy = UNSELECTED_STRATEGY
    if family_id in property_family_ids():
        family = get_property_family(family_id)
        allowed = list(strategy_ids())
        return {
            "schema_version": "property_campaign.v2.open_selected",
            "property_family_id": family["id"],
            "property_family_slug": family["slug"],
            "property_family_title": family["title"],
            "verification_strategy": strategy,
            "support_level": family["support_level"],
            "claim_boundary": family["claim_boundary"],
            "allowed_strategies": allowed,
            "target_examples": list(family.get("targets") or []),
            "allow_analysis_only": family["support_level"] == "analysis_only",
            "require_native_contract_tools": False,
            "explicitly_configured": False,
            "legacy_compatibility_default": False,
            "discovery_mode": OPEN_DISCOVERY,
            "selection_pending": False,
            "selected_property_id": prop.get("property_id"),
        }
    return {
        "schema_version": "property_campaign.v2.open_selected_unmapped",
        "property_family_id": UNMAPPED_FAMILY_ID,
        "property_family_slug": "unmapped_new_property",
        "property_family_title": "Unmapped/new open-discovery property",
        "verification_strategy": strategy,
        "support_level": "uncatalogued_candidate",
        "claim_boundary": "Local selected claim only; uncatalogued status does not imply truth, novelty, or provability.",
        "allowed_strategies": list(strategy_ids()),
        "target_examples": [],
        "allow_analysis_only": True,
        "require_native_contract_tools": False,
        "explicitly_configured": False,
        "legacy_compatibility_default": False,
        "discovery_mode": OPEN_DISCOVERY,
        "selection_pending": False,
        "selected_property_id": prop.get("property_id"),
    }


def validate_plan_against_open_selection(
    plan: Mapping[str, Any],
    selected_handoff: Mapping[str, Any],
) -> JsonDict:
    """Fail closed if Agent 5 changes or invents the property selected after open discovery."""
    errors: List[str] = []
    expected = selected_handoff.get("property") if isinstance(selected_handoff.get("property"), Mapping) else {}
    selected = plan.get("selected_property") if isinstance(plan.get("selected_property"), Mapping) else {}
    actual = selected.get("property") if isinstance(selected.get("property"), Mapping) else {}
    if not bool(selected.get("selected")):
        errors.append("Agent 5 must mark the Agent 4 open-discovery selection as selected.")
    for key in ("property_id", "property_family_id", "candidate_statement"):
        if str(actual.get(key) or "") != str(expected.get(key) or ""):
            errors.append(
                f"Agent 5 selected_property.{key} does not match the immutable Agent 4 selection."
            )
    return {
        "schema_version": "open_discovery_agent5_selection_binding.v1",
        "valid": not errors,
        "errors": errors,
        "expected_property_id": expected.get("property_id"),
        "actual_property_id": actual.get("property_id"),
        "selection_was_pre_agent5": True,
        "agent5_guessing_permitted": False,
        "claim_boundary": "Selection binding preserves experiment provenance; it does not prove the property.",
    }


def effective_campaign_for_plan(config: Mapping[str, Any], plan: Mapping[str, Any]) -> JsonDict:
    """Return the preconfigured targeted campaign or derive the selected open campaign from an Agent 5 plan."""
    if not is_open_discovery(config):
        return _mapping(config.get("property_campaign"))
    selected = plan.get("selected_property") if isinstance(plan.get("selected_property"), Mapping) else {}
    prop = selected.get("property") if isinstance(selected.get("property"), Mapping) else {}
    if not bool(selected.get("selected")) or not prop:
        raise PropertyDiscoveryModeError(
            "Open discovery requires a selected property in the Agent 5 plan before review or repair."
        )
    selection = {
        "selected": True,
        "property": dict(prop),
        "selection_method": str(selected.get("selection_method") or "agent5_plan_selection"),
    }
    campaign = effective_campaign_from_selected(selection)
    strategy = str(plan.get("verification_strategy") or "").strip()
    if strategy not in strategy_ids():
        raise PropertyDiscoveryModeError("Agent 5 must select a supported verification_strategy from explicit encoding evidence.")
    campaign["verification_strategy"] = strategy
    campaign["require_native_contract_tools"] = strategy in {LOOP_CONTRACT, FUNCTION_CONTRACT, "hybrid_contract_and_harness"}
    campaign["selection_pending"] = False
    campaign["strategy_selection_authority"] = str(
        (plan.get("strategy_selection") or {}).get("selection_authority")
        if isinstance(plan.get("strategy_selection"), Mapping) else "agent5_explicit_output"
    )
    return campaign


__all__ = [
    "CATALOGUE_HIDDEN",
    "DISCOVERY_MODES",
    "OPEN_DISCOVERY",
    "PropertyDiscoveryModeError",
    "TARGETED_CAMPAIGN",
    "UNMAPPED_FAMILY_ID",
    "UNSELECTED_STRATEGY",
    "classify_open_candidates",
    "discovery_mode",
    "effective_campaign_for_plan",
    "effective_campaign_from_selected",
    "is_open_discovery",
    "normalize_property_discovery",
    "open_discovery_campaign_placeholder",
    "select_open_candidate",
    "validate_plan_against_open_selection",
    "validate_property_discovery_config",
]
