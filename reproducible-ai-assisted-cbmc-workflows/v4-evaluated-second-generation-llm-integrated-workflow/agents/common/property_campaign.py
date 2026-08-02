"""Semantic validation for the 26-property campaign extension.

JSON Schema validation proves shape only.  This module checks the cross-field
rules that bind a selected property family to its permitted verification
strategy and to the correct candidate artefact profile.  It never decides that
a property is true or provable.
"""
from __future__ import annotations

from typing import Any, Dict, List, Mapping

from agents.common.contract_artifacts import validate_contract_plan
from agents.common.property_discovery_mode import OPEN_DISCOVERY, UNSELECTED_STRATEGY
from agents.common.semantic_property import normalize_semantic_property, semantic_completeness

from agents.common.property_catalog import (
    ANALYSIS_ONLY,
    FUNCTION_CONTRACT,
    HYBRID,
    LOOP_CONTRACT,
    RELATIONAL,
    STANDARD,
    get_property_family,
)

JsonDict = Dict[str, Any]


def _mapping(value: Any) -> Mapping[str, Any]:
    return value if isinstance(value, Mapping) else {}


def _list(value: Any) -> List[Any]:
    return list(value) if isinstance(value, list) else []


def _campaign_family(campaign: Mapping[str, Any]) -> JsonDict:
    family_id = str(campaign.get("property_family_id") or "")
    try:
        return get_property_family(family_id)
    except KeyError:
        if family_id == "UNMAPPED" and str(campaign.get("discovery_mode") or "") == "open_discovery":
            return {
                "id": "UNMAPPED",
                "title": "Unmapped/new open-discovery property",
                "allowed_strategies": [STANDARD, FUNCTION_CONTRACT, LOOP_CONTRACT, RELATIONAL, HYBRID, ANALYSIS_ONLY],
                "default_strategy": STANDARD,
                "support_level": "uncatalogued_candidate",
                "claim_boundary": str(campaign.get("claim_boundary") or "Local selected claim only."),
            }
        raise


def validate_candidate_properties_for_campaign(
    output: Mapping[str, Any],
    campaign: Mapping[str, Any],
    *,
    allow_mock_empty: bool = True,
) -> JsonDict:
    """Validate Agent 4 candidates without turning metadata into strategy authority.

    Targeted campaigns retain catalogue compatibility checks.  Open discovery
    permits uncatalogued semantic kinds and requires strategy-neutral candidates;
    Agent 5 chooses an executable encoding later from the semantic record.
    """
    errors: List[str] = []
    warnings: List[str] = []
    family_id = str(campaign.get("property_family_id") or "")
    configured_strategy = str(campaign.get("verification_strategy") or "")
    discovery_mode = str(campaign.get("discovery_mode") or "targeted_campaign")
    open_unselected = discovery_mode == OPEN_DISCOVERY and configured_strategy == UNSELECTED_STRATEGY
    family = _campaign_family(campaign)
    legacy_compatibility = bool(campaign.get("legacy_compatibility_default"))
    candidates = _list(output.get("candidate_properties"))
    is_mock = bool(output.get("mock")) or not bool(output.get("llm_call_executed"))

    matching: List[Mapping[str, Any]] = []
    for index, candidate in enumerate(candidates):
        if not isinstance(candidate, Mapping):
            errors.append(f"candidate_properties[{index}] is not an object.")
            continue
        candidate_id = str(candidate.get("property_id") or "").strip()
        if not candidate_id:
            errors.append(f"candidate_properties[{index}] has no property_id.")
        candidate_family = str(candidate.get("property_family_id") or "").strip()
        candidate_strategy = str(candidate.get("verification_strategy") or "").strip()
        semantic = candidate.get("semantic_property")
        if not isinstance(semantic, Mapping):
            errors.append(f"Candidate {candidate_id or index!r} lacks semantic_property.")
        else:
            normalized_semantic = normalize_semantic_property(semantic, target_function=str((semantic.get("target_call") or {}).get("function") or ""))
            completeness = semantic_completeness(normalized_semantic)
            if not completeness.get("complete"):
                errors.append(
                    f"Candidate {candidate_id or index!r} has incomplete semantic_property: "
                    + ", ".join(completeness.get("missing_fields", []))
                )
            if str(normalized_semantic.get("property_id") or "") != candidate_id:
                errors.append(
                    f"Candidate {candidate_id or index!r} semantic_property.property_id does not match the candidate id."
                )

        if open_unselected:
            if candidate_strategy not in {"", UNSELECTED_STRATEGY}:
                errors.append(
                    f"Open-discovery candidate {candidate_id or index!r} selected executable strategy "
                    f"{candidate_strategy!r} before Agent 5 encoding selection."
                )
            # Catalogue family/category is optional descriptive metadata only.
            if candidate_family:
                try:
                    get_property_family(candidate_family)
                except KeyError:
                    warnings.append(
                        f"Open-discovery candidate {candidate_id or index!r} uses uncatalogued descriptive family "
                        f"{candidate_family!r}; it remains preserved as an uncatalogued candidate."
                    )
            matching.append(candidate)
            continue

        try:
            candidate_catalogue = get_property_family(candidate_family)
        except KeyError as exc:
            errors.append(str(exc))
            continue
        if candidate_strategy not in candidate_catalogue.get("allowed_strategies", []):
            errors.append(
                f"Candidate {candidate_id or index!r} uses strategy {candidate_strategy!r}, "
                f"which is not allowed for {candidate_family}."
            )
        if candidate_family == family_id:
            matching.append(candidate)

    if not matching:
        if legacy_compatibility:
            warnings.append(
                "Legacy compatibility configuration did not explicitly select a property family; "
                "Agent 4 may supply any catalogue-valid candidate using the preserved direct-CBMC strategy."
            )
        elif is_mock and allow_mock_empty:
            warnings.append(
                "Mock/non-API Agent 4 output contains no campaign candidate; this is allowed "
                "for wiring tests only and is not eligible for a real experiment."
            )
        elif open_unselected:
            errors.append("Open discovery produced no strategy-neutral semantic property candidate.")
        else:
            errors.append(f"No candidate property matches configured family {family_id}.")
    elif not open_unselected and not any(
        str(item.get("verification_strategy") or "") == configured_strategy for item in matching
    ):
        errors.append(
            f"No {family_id} candidate uses configured strategy {configured_strategy!r}; "
            f"allowed strategies are {family.get('allowed_strategies', [])}."
        )

    return {
        "schema_version": "property_campaign_candidate_validation.v2.strategy_neutral",
        "valid": not errors,
        "errors": errors,
        "warnings": warnings,
        "discovery_mode": discovery_mode,
        "configured_property_family_id": family_id,
        "configured_verification_strategy": configured_strategy,
        "effective_plan_strategy": None if open_unselected else configured_strategy,
        "strategy_selection_deferred_to_agent5": open_unselected,
        "candidate_count": len(candidates),
        "matching_candidate_count": len(matching),
        "mock_or_non_api_output": is_mock,
        "legacy_compatibility_default": legacy_compatibility,
        "claim_boundary": "Campaign compatibility and semantic completeness are not evidence that a property is true or provable.",
    }


def validate_artifact_plan_for_campaign(
    plan: Mapping[str, Any], campaign: Mapping[str, Any]
) -> JsonDict:
    """Check Agent 5's plan against the selected campaign and strategy.

    Real/API-backed plans fail closed on every strategy/profile mismatch. Mock
    plans may retain an intentionally non-executable profile for wiring tests,
    but the mismatch is recorded as a warning and downstream review must block
    formal execution.
    """
    errors: List[str] = []
    warnings: List[str] = []
    family_id = str(campaign.get("property_family_id") or "")
    configured_strategy = str(campaign.get("verification_strategy") or "")
    family = _campaign_family(campaign)
    legacy_compatibility = bool(campaign.get("legacy_compatibility_default"))
    is_mock = bool(plan.get("mock")) or not bool(plan.get("llm_call_executed"))

    plan_strategy = str(plan.get("verification_strategy") or "")
    open_selection = str(campaign.get("discovery_mode") or "") == OPEN_DISCOVERY
    # After Agent 5 explicitly chooses an encoding, the effective open campaign
    # records that chosen strategy.  The immutable Agent 4 property itself must
    # nevertheless remain strategy-neutral (UNSELECTED).
    strategy = plan_strategy if open_selection else configured_strategy
    if not open_selection and plan_strategy != configured_strategy:
        errors.append(
            f"Artifact plan strategy {plan_strategy!r} does not match configured strategy {configured_strategy!r}."
        )
    if open_selection:
        selection = _mapping(plan.get("strategy_selection"))
        if str(selection.get("selected_strategy") or "") != plan_strategy:
            errors.append("Open discovery requires strategy_selection.selected_strategy to equal verification_strategy.")
        if bool(selection.get("family_recommendation_was_authoritative")):
            errors.append("Open-discovery family recommendation may not be execution authority.")
        if bool(selection.get("llm_feasibility_was_authoritative")):
            errors.append("Agent 4 self-rated feasibility may not be execution authority.")

    selected = _mapping(plan.get("selected_property"))
    selected_property = _mapping(selected.get("property"))
    selected_family = str(selected_property.get("property_family_id") or "")
    selected_strategy = str(selected_property.get("verification_strategy") or "")
    if bool(selected.get("selected")):
        if selected_family != family_id:
            if legacy_compatibility and strategy == STANDARD:
                warnings.append(
                    f"LEGACY_17CBC_COMPATIBILITY: selected property family {selected_family!r} differs "
                    f"from the non-authoritative compatibility placeholder {family_id!r}; direct-CBMC "
                    "execution is preserved. Set property_campaign explicitly to enforce a family."
                )
            else:
                errors.append(
                    f"Selected property family {selected_family!r} does not match configured family {family_id}."
                )
        if open_selection:
            if selected_strategy not in {"", UNSELECTED_STRATEGY}:
                errors.append("Open-discovery selected semantic property must remain strategy-neutral before Agent 5 encoding selection.")
        elif selected_strategy != strategy:
            errors.append(
                f"Selected property strategy {selected_strategy!r} does not match configured strategy {strategy!r}."
            )
    elif not is_mock:
        errors.append("A real Agent 5 plan must select a property.")

    contract_plan = _mapping(plan.get("contract_plan"))
    relational_plan = _mapping(plan.get("relational_plan"))
    analysis_plan = _mapping(plan.get("analysis_only_plan"))
    contract_validation = validate_contract_plan(contract_plan, strategy)

    profile_issues: List[str] = [str(x) for x in contract_validation.get("errors", [])]
    warnings.extend(str(x) for x in contract_validation.get("warnings", []))

    contract_enabled = bool(contract_plan.get("enabled"))
    relational_enabled = bool(relational_plan.get("enabled"))
    analysis_enabled = bool(analysis_plan.get("enabled"))

    if strategy == STANDARD:
        if contract_enabled or relational_enabled or analysis_enabled:
            profile_issues.append("standard_cbmc_harness requires contract, relational, and analysis-only plans to be disabled.")
    elif strategy == FUNCTION_CONTRACT:
        if not contract_enabled or str(contract_plan.get("contract_mode")) not in {"function", "loop_and_function"}:
            profile_issues.append("native_function_contract requires an enabled function contract plan.")
        if relational_enabled or analysis_enabled:
            profile_issues.append("native_function_contract cannot enable relational or analysis-only plans.")
    elif strategy == LOOP_CONTRACT:
        if not contract_enabled or str(contract_plan.get("contract_mode")) not in {"loop", "loop_and_function"}:
            profile_issues.append("native_loop_contract requires an enabled loop contract plan.")
        if relational_enabled or analysis_enabled:
            profile_issues.append("native_loop_contract cannot enable relational or analysis-only plans.")
    elif strategy == HYBRID:
        if not contract_enabled:
            profile_issues.append("hybrid_contract_and_harness requires an enabled native contract plan plus a harness.")
        if analysis_enabled:
            profile_issues.append("hybrid_contract_and_harness cannot enable analysis-only mode.")
    elif strategy == RELATIONAL:
        if not relational_enabled:
            profile_issues.append("relational_cbmc_harness requires relational_plan.enabled=true.")
        if str(relational_plan.get("relation_kind") or "none") == "none":
            profile_issues.append("A relational strategy requires a non-'none' relation_kind.")
        if not _list(relational_plan.get("relation_assertions")):
            profile_issues.append("A relational strategy requires at least one relation assertion.")
        if contract_enabled or analysis_enabled:
            profile_issues.append("relational_cbmc_harness cannot enable native-contract or analysis-only plans.")
    elif strategy == ANALYSIS_ONLY:
        if not analysis_enabled:
            profile_issues.append("analysis_only_no_formal_claim requires analysis_only_plan.enabled=true.")
        if not bool(analysis_plan.get("formal_claim_prohibited")):
            profile_issues.append("Analysis-only strategy requires formal_claim_prohibited=true.")
        if contract_enabled or relational_enabled:
            profile_issues.append("Analysis-only strategy cannot enable contract or relational proof plans.")
    else:
        profile_issues.append(f"Unsupported verification strategy: {strategy!r}.")

    if strategy != ANALYSIS_ONLY and not str(plan.get("generated_harness_code") or "").strip():
        profile_issues.append("A formal verification strategy requires non-empty generated_harness_code.")

    if is_mock and profile_issues:
        warnings.extend(
            "MOCK_WIRING_ONLY: " + issue for issue in profile_issues
        )
    else:
        errors.extend(profile_issues)

    return {
        "schema_version": "property_campaign_artifact_plan_validation.v2",
        "valid": not errors,
        "valid_for_real_experiment": (not errors) and (not is_mock) and (not profile_issues),
        "mock_wiring_only": is_mock,
        "legacy_compatibility_default": legacy_compatibility,
        "errors": errors,
        "warnings": warnings,
        "configured_property_family_id": family_id,
        "configured_property_family_title": family.get("title"),
        "configured_verification_strategy": strategy,
        "effective_plan_strategy": strategy,
        "selected_property_family_id": selected_family,
        "selected_property_strategy": selected_strategy,
        "contract_validation": contract_validation,
        "claim_boundary": "Strategy-plan compatibility does not prove the contract, harness, relation, or property.",
    }

def validate_repair_plan_for_campaign(
    repair_plan: Mapping[str, Any],
    campaign: Mapping[str, Any],
) -> JsonDict:
    """Check that Agent 9 preserves the selected strategy and claim boundary.

    Real/API-backed repairs fail closed. Mock repairs may be incomplete for wiring
    tests, but every incompleteness is recorded and cannot authorize formal use.
    """
    errors: List[str] = []
    warnings: List[str] = []
    strategy = str(campaign.get("verification_strategy") or "")
    is_mock = bool(repair_plan.get("mock")) or not bool(repair_plan.get("llm_call_executed"))
    contract = _mapping(repair_plan.get("candidate_repaired_contract_plan"))
    relational = _mapping(repair_plan.get("candidate_repaired_relational_plan"))
    analysis = _mapping(repair_plan.get("candidate_repaired_analysis_only_plan"))
    profile_issues: List[str] = []

    if strategy in {FUNCTION_CONTRACT, LOOP_CONTRACT, HYBRID}:
        validation = validate_contract_plan(contract, strategy)
        profile_issues.extend(str(x) for x in validation.get("errors", []))
        warnings.extend(str(x) for x in validation.get("warnings", []))
    elif bool(contract.get("enabled")):
        profile_issues.append(f"Repair plan enables a native contract while configured strategy is {strategy!r}.")

    if strategy == RELATIONAL:
        if not bool(relational.get("enabled")):
            profile_issues.append("Relational repair must provide a complete enabled relational plan.")
        if not _list(relational.get("relation_assertions")):
            profile_issues.append("Relational repair must preserve at least one relation assertion.")
    elif bool(relational.get("enabled")):
        profile_issues.append(f"Repair plan enables a relational plan while configured strategy is {strategy!r}.")

    if strategy == ANALYSIS_ONLY:
        if not bool(analysis.get("enabled")) or not bool(analysis.get("formal_claim_prohibited")):
            profile_issues.append("Analysis-only repair must preserve enabled=true and formal_claim_prohibited=true.")
        if str(repair_plan.get("candidate_repaired_harness_code") or "").strip():
            warnings.append("Analysis-only repair includes candidate C code; it must not be treated as formal evidence.")
    elif bool(analysis.get("enabled")):
        profile_issues.append(f"Repair plan enables analysis-only mode while configured strategy is {strategy!r}.")

    if is_mock and profile_issues:
        warnings.extend("MOCK_WIRING_ONLY: " + issue for issue in profile_issues)
    else:
        errors.extend(profile_issues)

    return {
        "schema_version": "property_campaign_repair_plan_validation.v2",
        "valid": not errors,
        "valid_for_real_experiment": (not errors) and (not is_mock) and (not profile_issues),
        "mock_wiring_only": is_mock,
        "errors": errors,
        "warnings": warnings,
        "configured_verification_strategy": strategy,
        "effective_plan_strategy": strategy,
        "claim_boundary": "Repair-plan compatibility does not establish that the repair is sound or preserves evidence strength.",
    }
