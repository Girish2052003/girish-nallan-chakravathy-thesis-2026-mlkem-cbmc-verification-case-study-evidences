"""Strategy-neutral semantic property records and explicit selection policies.

The property proposed by Agent 4 is preserved independently from catalogue
classification and executable artefact strategy.  This module deliberately
avoids deriving an execution strategy from prose labels or keywords.
"""
from __future__ import annotations

import copy
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple

JsonDict = Dict[str, Any]

DEPRECATED_SELECTION_POLICY_ALIASES = {
    # Historical name was misleading: no frontend compilation occurs while
    # selecting an Agent 4 property.  Preserve old configs through an explicit,
    # logged migration to the honest expressibility policy.
    "frontend_ready_first": "harness_expressibility_first",
}

SELECTION_POLICIES = {
    "user_selected",
    "llm_ranked",
    "scientific_priority",
    "diversity_first",
    "harness_preferred",
    "contract_preferred",
    "harness_expressibility_first",
    "campaign_order",
    # Accepted only as named legacy policies; never used as silent defaults.
    "feasibility_then_risk_then_rank",
    "configured_campaign_preferred_category",
}

ENCODING_STRATEGIES = (
    "standard_cbmc_harness",
    "native_function_contract",
    "native_loop_contract",
    "relational_cbmc_harness",
    "hybrid_contract_and_harness",
    "analysis_only_no_formal_claim",
)


def _strings(value: Any) -> List[str]:
    if not isinstance(value, list):
        return []
    return [str(item).strip() for item in value if str(item).strip()]


def _mapping(value: Any) -> JsonDict:
    return copy.deepcopy(dict(value)) if isinstance(value, Mapping) else {}


def _target_call(candidate: Mapping[str, Any], target_function: str = "") -> JsonDict:
    raw = _mapping(candidate.get("target_call"))
    function = str(raw.get("function") or candidate.get("target_function") or target_function).strip()
    args = _strings(raw.get("arguments"))
    return {
        "function": function,
        "arguments": args,
        "call_count": raw.get("call_count") if isinstance(raw.get("call_count"), int) else 1,
    }


def normalize_semantic_property(
    candidate: Mapping[str, Any], *, target_function: str = ""
) -> JsonDict:
    """Return a strategy-neutral record while preserving the original proposal.

    New Agent 4 outputs should supply ``semantic_property`` directly.  Legacy
    candidates are upgraded conservatively without inventing executable syntax
    or choosing an artefact strategy.
    """
    original = copy.deepcopy(dict(candidate))
    raw = _mapping(original.get("semantic_property"))
    # Idempotence is mandatory: already-normalized semantic_property.v2
    # records must survive every downstream handoff without losing fields.
    source = raw if raw else original
    statement = str(
        source.get("statement")
        or original.get("candidate_statement")
        or original.get("statement")
        or ""
    ).strip()
    property_id = str(source.get("property_id") or original.get("property_id") or "").strip()
    quantified = _mapping(source.get("quantified_domain"))
    if not quantified:
        quantified = {
            "variable": "",
            "lower_bound": "",
            "upper_bound_exclusive": "",
        }
    record: JsonDict = {
        "schema_version": "semantic_property.v2",
        "property_id": property_id,
        "statement": statement,
        "target_call": _target_call(source, target_function),
        "pre_state_objects": _strings(source.get("pre_state_objects")),
        "post_state_objects": _strings(source.get("post_state_objects")),
        "observed_memory": _strings(source.get("observed_memory")),
        "permitted_writes": _strings(source.get("permitted_writes")),
        "required_assumptions": _strings(
            source.get("required_assumptions")
            if isinstance(source.get("required_assumptions"), list)
            else original.get("required_assumptions")
        ),
        "success_predicate": str(source.get("success_predicate") or "").strip(),
        "quantified_domain": {
            "variable": str(quantified.get("variable") or "").strip(),
            "lower_bound": str(quantified.get("lower_bound") or "").strip(),
            "upper_bound_exclusive": str(quantified.get("upper_bound_exclusive") or "").strip(),
        },
        "requires_pre_state_snapshot": bool(source.get("requires_pre_state_snapshot")),
        "requires_modular_call_replacement": bool(source.get("requires_modular_call_replacement")),
        "requires_loop_reasoning": bool(source.get("requires_loop_reasoning")),
        "requires_relational_execution": bool(source.get("requires_relational_execution")),
        "analysis_only": bool(source.get("analysis_only")),
        "evidence_references": copy.deepcopy(
            source.get("evidence_references")
            if isinstance(source.get("evidence_references"), list)
            else original.get("supporting_evidence") or []
        ),
        "uncertainty": str(source.get("uncertainty") or original.get("uncertainty") or "").strip(),
    }
    # Explicit semantic fields, not category words, determine genuine route
    # requirements.  Missing fields remain unknown rather than being guessed.
    record["semantic_completeness"] = semantic_completeness(record)
    return record


def semantic_completeness(record: Mapping[str, Any]) -> JsonDict:
    target = record.get("target_call") if isinstance(record.get("target_call"), Mapping) else {}
    missing: List[str] = []
    if not str(record.get("property_id") or "").strip():
        missing.append("property_id")
    if not str(record.get("statement") or "").strip():
        missing.append("statement")
    if not str(target.get("function") or "").strip():
        missing.append("target_call.function")
    has_predicate = bool(str(record.get("success_predicate") or "").strip())
    has_write_set = bool(record.get("permitted_writes"))
    if not bool(record.get("analysis_only")) and not (has_predicate or has_write_set):
        missing.append("success_predicate_or_permitted_writes")
    return {
        "complete": not missing,
        "missing_fields": missing,
        "claim_boundary": "Completeness means the semantic claim is structurally specified; it is not proof or frontend readiness.",
    }


def possible_encodings(record: Mapping[str, Any]) -> List[JsonDict]:
    """Return evidence-based possibilities without selecting one silently."""
    options: List[JsonDict] = []
    if bool(record.get("analysis_only")):
        return [{
            "strategy": "analysis_only_no_formal_claim",
            "expressible": True,
            "required": True,
            "reason": "The semantic record explicitly marks the property analysis-only.",
            "authority": "semantic_property_record",
        }]

    predicate = bool(str(record.get("success_predicate") or "").strip())
    target = record.get("target_call") if isinstance(record.get("target_call"), Mapping) else {}
    target_known = bool(str(target.get("function") or "").strip())
    modular_required = bool(record.get("requires_modular_call_replacement"))
    harness_expressible = (not modular_required) and target_known and (
        predicate or bool(record.get("permitted_writes")) or bool(record.get("observed_memory"))
    )
    options.append({
        "strategy": "standard_cbmc_harness",
        "expressible": harness_expressible,
        "required": False,
        "reason": (
            "The target call and selected claim can be represented by explicit harness assumptions, snapshots, and assertions."
            if harness_expressible else
            "The semantic record requires modular call replacement, or lacks a concrete target call/executable selected-claim predicate."
        ),
        "authority": "semantic_property_record",
    })
    if bool(record.get("requires_relational_execution")):
        options.append({
            "strategy": "relational_cbmc_harness",
            "expressible": target_known and not modular_required,
            "reason": "The semantic record explicitly requires two-execution or relational comparison; plain relational encoding does not satisfy a separate modular-call requirement.",
            "authority": "semantic_property_record",
        })
    if bool(record.get("requires_loop_reasoning")):
        options.append({
            "strategy": "native_loop_contract",
            "expressible": target_known and not modular_required,
            "reason": "The semantic record explicitly requires loop reasoning; a loop-only contract does not satisfy a separate modular-call requirement.",
            "authority": "semantic_property_record",
        })
    # Function contracts are available as an alternative whenever a target is
    # known, but are *required* only for explicit modular call replacement.
    options.append({
        "strategy": "native_function_contract",
        "expressible": target_known,
        "required": bool(record.get("requires_modular_call_replacement")),
        "reason": (
            "The semantic record explicitly requires modular call replacement."
            if bool(record.get("requires_modular_call_replacement")) else
            "A function contract is an optional alternative; the semantic record does not require modular replacement."
        ),
        "authority": "semantic_property_record",
    })
    options.append({
        "strategy": "hybrid_contract_and_harness",
        "expressible": target_known and harness_expressible,
        "required": False,
        "reason": "Hybrid encoding is optional when both a complete harness claim and contract artefact are available.",
        "authority": "semantic_property_record",
    })
    return options


def canonical_selection_policy(policy: str) -> str:
    """Return the honest canonical policy name for legacy user configs."""
    value = str(policy or "").strip()
    return DEPRECATED_SELECTION_POLICY_ALIASES.get(value, value)


def choose_property(
    candidates: Sequence[Mapping[str, Any]],
    *,
    policy: str,
    selected_property_id: Optional[str] = None,
    ranking_rows: Sequence[Mapping[str, Any]] = (),
) -> Tuple[JsonDict, str]:
    """Choose one candidate using an explicit, auditable policy."""
    rows = [copy.deepcopy(dict(item)) for item in candidates if isinstance(item, Mapping)]
    if not rows:
        raise ValueError("No property candidates are available for selection.")
    requested_policy = str(policy or "").strip()
    policy = canonical_selection_policy(requested_policy)
    migrated_from = requested_policy if requested_policy != policy else ""
    if policy not in SELECTION_POLICIES:
        raise ValueError(f"Unsupported property selection policy: {requested_policy!r}.")
    if selected_property_id:
        for row in rows:
            if str(row.get("property_id") or "") == str(selected_property_id):
                return row, "explicit_user_selected_property_id"
        raise ValueError(f"Selected property id {selected_property_id!r} was not produced by Agent 4.")
    if policy == "user_selected":
        raise ValueError("selection_policy='user_selected' requires property_discovery.selected_property_id.")

    rank_map: Dict[str, int] = {}
    for item in ranking_rows:
        if not isinstance(item, Mapping):
            continue
        try:
            rank_map[str(item.get("property_id") or "")] = int(item.get("rank"))
        except (TypeError, ValueError):
            continue

    if policy in {"llm_ranked", "scientific_priority", "campaign_order", "configured_campaign_preferred_category"}:
        rows.sort(key=lambda row: (
            rank_map.get(str(row.get("property_id") or ""), 10_000),
            str(row.get("property_id") or ""),
        ))
        return rows[0], f"explicit_policy:{policy}"

    if policy == "diversity_first":
        rows.sort(key=lambda row: (
            str(row.get("category") or ""),
            rank_map.get(str(row.get("property_id") or ""), 10_000),
            str(row.get("property_id") or ""),
        ))
        return rows[0], "explicit_policy:diversity_first"

    if policy in {"harness_preferred", "contract_preferred", "harness_expressibility_first"}:
        preferred = "standard_cbmc_harness" if policy != "contract_preferred" else "native_function_contract"
        rows.sort(key=lambda row: (
            0 if any(
                opt.get("strategy") == preferred and opt.get("expressible")
                for opt in possible_encodings(normalize_semantic_property(row))
            ) else 1,
            rank_map.get(str(row.get("property_id") or ""), 10_000),
            str(row.get("property_id") or ""),
        ))
        authority = f"explicit_policy:{policy}"
        if migrated_from:
            authority += f";migrated_from:{migrated_from}"
        return rows[0], authority

    # Legacy policy remains available only by explicit name and is recorded as
    # self-rated, not objective frontend feasibility.
    feasibility_score = {"high": 0, "medium": 1, "unknown": 2, "low": 3}
    risk_score = {"low": 0, "medium": 1, "unknown": 2, "high": 3, "critical": 4}
    rows.sort(key=lambda row: (
        feasibility_score.get(str(row.get("cbmc_feasibility") or "unknown"), 2),
        risk_score.get(str(row.get("risk_level") or "unknown"), 2),
        rank_map.get(str(row.get("property_id") or ""), 10_000),
        str(row.get("property_id") or ""),
    ))
    return rows[0], "explicit_legacy_policy:feasibility_then_risk_then_rank"


def select_encoding(
    semantic_record: Mapping[str, Any],
    *,
    requested_strategy: Optional[str],
    preference: str = "harness_when_complete",
) -> JsonDict:
    """Select an encoding only from explicit semantic capabilities/policy."""
    options = possible_encodings(semantic_record)
    expressible = [row for row in options if row.get("expressible")]
    by_strategy = {str(row.get("strategy")): row for row in options}
    requested = str(requested_strategy or "").strip()
    if requested:
        row = by_strategy.get(requested)
        if row is None:
            raise ValueError(f"Unknown requested strategy: {requested!r}.")
        if not row.get("expressible"):
            raise ValueError(f"Requested strategy {requested!r} is not expressible from the semantic record.")
        return {
            "selected_strategy": requested,
            "selection_authority": "explicit_user_or_agent5_request",
            "selection_reason": str(row.get("reason") or ""),
            "possible_encodings": options,
        }
    if not expressible:
        raise ValueError("No executable encoding is supported by the semantic property record.")
    if preference == "contract_when_required":
        required = [row for row in expressible if row.get("required")]
        if required:
            chosen = required[0]
        else:
            chosen = next((row for row in expressible if row.get("strategy") == "standard_cbmc_harness"), expressible[0])
    elif preference == "contract_preferred":
        chosen = next((row for row in expressible if row.get("strategy") == "native_function_contract"), expressible[0])
    else:
        chosen = next((row for row in expressible if row.get("strategy") == "standard_cbmc_harness"), expressible[0])
    return {
        "selected_strategy": str(chosen.get("strategy")),
        "selection_authority": f"explicit_policy:{preference}",
        "selection_reason": str(chosen.get("reason") or ""),
        "possible_encodings": options,
    }


def compare_semantic_properties(
    original: Mapping[str, Any], repaired: Mapping[str, Any], *, target_function: str = ""
) -> JsonDict:
    """Compare semantic claim strength structurally instead of by suspicious words."""
    left = normalize_semantic_property(original, target_function=target_function)
    right = normalize_semantic_property(repaired, target_function=target_function)
    fields = (
        "target_call", "pre_state_objects", "post_state_objects",
        "quantified_domain", "success_predicate", "required_assumptions",
        "observed_memory", "permitted_writes", "requires_modular_call_replacement",
    )
    changes: List[JsonDict] = []
    for field in fields:
        if left.get(field) != right.get(field):
            changes.append({"field": field, "original": left.get(field), "repaired": right.get(field)})
    weakening_reasons: List[str] = []
    if set(right.get("required_assumptions", [])) > set(left.get("required_assumptions", [])):
        weakening_reasons.append("repaired_property_adds_assumptions")
    if set(right.get("observed_memory", [])) < set(left.get("observed_memory", [])):
        weakening_reasons.append("repaired_property_observes_less_memory")
    if str(right.get("success_predicate") or "") != str(left.get("success_predicate") or ""):
        weakening_reasons.append("success_predicate_changed_requires_human_strength_review")
    if right.get("target_call") != left.get("target_call"):
        weakening_reasons.append("target_call_changed")
    return {
        "schema_version": "semantic_property_difference.v1",
        "same_semantic_property": not changes,
        "change_count": len(changes),
        "changes": changes,
        "potential_weakening": bool(weakening_reasons),
        "weakening_reasons": weakening_reasons,
        "original_property_id": left.get("property_id"),
        "repaired_property_id": right.get("property_id"),
        "claim_boundary": "Structural differences identify potential weakening; explicit user acknowledgement remains authoritative when weakening is allowed.",
    }


__all__ = [
    "ENCODING_STRATEGIES",
    "DEPRECATED_SELECTION_POLICY_ALIASES",
    "SELECTION_POLICIES",
    "canonical_selection_policy",
    "choose_property",
    "compare_semantic_properties",
    "normalize_semantic_property",
    "possible_encodings",
    "select_encoding",
    "semantic_completeness",
]
