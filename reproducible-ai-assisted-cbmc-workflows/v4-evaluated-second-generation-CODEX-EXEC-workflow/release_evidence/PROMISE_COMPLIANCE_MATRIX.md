# Final Promise-Compliance Matrix

**Implementation:** 38/38 complete  
**Local acceptance inventory:** 51 tests  
**Real CBMC 6.9.0 host acceptance:** mandatory for requirements 11, 12 and 19

| # | Requirement | Implementation | Local evidence | Real CBMC 6.9 |
|---:|---|---|---|---|
| 1 | Replace keyword-driven strategy classification | Complete | verify_open_discovery_mode.py, verify_strategy_neutrality_and_semantic_repair_guard.py | N/A |
| 2 | Remove hidden family-default substitutions | Complete | verify_agent4_campaign_candidate_separation.py, verify_open_discovery_agent5_reporting.py | N/A |
| 3 | Remove self-rating selection bias and use honest explicit policies | Complete | verify_final_partial_items_closed.py, verify_open_discovery_mode.py | N/A |
| 4 | Remove hidden open-discovery taxonomy restrictions | Complete | verify_open_discovery_mode.py, verify_open_discovery_mutable_workspace_compatibility.py | N/A |
| 5 | Introduce a strategy-neutral semantic-property record | Complete | verify_strategy_neutrality_and_semantic_repair_guard.py, verify_26_property_repair_and_claim_boundaries.py | N/A |
| 6 | Rewrite Agent 4 prompt for semantic, evidence-bound discovery | Complete | verify_open_discovery_mode.py, verify_agent4_campaign_candidate_separation.py | N/A |
| 7 | Allow Agent 5 to choose complete executable encodings | Complete | verify_strategy_neutrality_and_semantic_repair_guard.py, verify_offline_open_discovery_fake_llm_cbmc_e2e.py | N/A |
| 8 | Make complete property-checking harnesses the baseline when expressible | Complete | verify_live_harness_hardening.py, verify_mandatory_semantic_evidence_gates.py | N/A |
| 9 | Remove executable TODO fallback harnesses from real mode | Complete | verify_live_harness_hardening.py, verify_property_campaign_orchestration.py | N/A |
| 10 | Use typed contract-clause records | Complete | verify_26_property_contract_extension.py, verify_run002_exact_replay_and_clause_grammar.py | N/A |
| 11 | Add clause-specific CBMC validation | Complete | verify_run002_exact_replay_and_clause_grammar.py, verify_final_partial_items_closed.py | Pending host gate |
| 12 | Add an installed-CBMC capability profile | Complete | verify_strategy_reconciliation_and_frontend_readiness.py, accept_real_cbmc_69.py | Pending host gate |
| 13 | Rewrite Agent 5 prompt with exact CBMC syntax boundaries | Complete | verify_26_property_contract_extension.py, verify_run002_exact_replay_and_clause_grammar.py | N/A |
| 14 | Replace fuzzy traceability with exact engine identities | Complete | verify_exact_traceability_edge_cases.py, verify_mandatory_semantic_evidence_gates.py | N/A |
| 15 | Replace regex-only semantic reachability checks | Complete | verify_exact_traceability_edge_cases.py, verify_mandatory_semantic_evidence_gates.py | N/A |
| 16 | Remove model-authored regexes from authoritative CBMC coverage | Complete | verify_canonical_tool_result_contract.py, verify_definitive_winner_result_integrity.py | N/A |
| 17 | Separate selected-claim and auxiliary-property results | Complete | verify_canonical_tool_result_contract.py, verify_canonical_tool_workflow_transitions.py | N/A |
| 18 | Expose staged validity instead of overloaded contract_valid | Complete | verify_strategy_reconciliation_and_frontend_readiness.py, verify_critic_tool_readiness_policy.py | N/A |
| 19 | Run complete route-specific non-solving readiness | Complete | verify_strategy_reconciliation_and_frontend_readiness.py, verify_offline_fake_llm_cbmc_e2e.py | Pending host gate |
| 20 | Always transmit objective tool facts to Agent 6 | Complete | verify_critic_tool_readiness_policy.py, verify_strategy_reconciliation_and_frontend_readiness.py | N/A |
| 21 | Redesign Agent 6 blocker semantics | Complete | verify_critic_tool_readiness_policy.py, verify_gate_boolean_fail_closed.py | N/A |
| 22 | Preserve user freedom with explicit execution modes | Complete | verify_user_override_command_provenance.py, verify_blockers3_to_8.py | N/A |
| 23 | Bind user overrides to the exact executed command | Complete | verify_user_override_command_provenance.py, verify_blockers3_to_8.py | N/A |
| 24 | Surface duplicated/conflicting CBMC arguments | Complete | verify_user_override_command_provenance.py | N/A |
| 25 | Create one canonical gate vocabulary | Complete | verify_gate_boolean_fail_closed.py, verify_canonical_tool_workflow_transitions.py | N/A |
| 26 | Separate process success from semantic stage outcome | Complete | verify_agent10_stage_classification_and_agent11_wording.py, verify_canonical_tool_workflow_transitions.py | N/A |
| 27 | Separate analysis-only and formal-execution permissions | Complete | verify_critic_tool_readiness_policy.py, verify_gate_boolean_fail_closed.py | N/A |
| 28 | Bind exact source units, entry function and tool configuration | Complete | verify_strategy_reconciliation_and_frontend_readiness.py, verify_26_property_contract_extension.py | N/A |
| 29 | Strengthen strict JSON-schema enforcement | Complete | verify_blocker1_schemas.py, verify_central_fail_closed_hardening.py | N/A |
| 30 | Make retries user-controlled and evidence-aware | Complete | verify_explicit_llm_retry_categories.py, verify_llm_incomplete_retry_budget.py | N/A |
| 31 | Regenerate complete bound repair bundles | Complete | verify_26_property_repair_and_claim_boundaries.py, verify_blockers3_to_8.py | N/A |
| 32 | Allow explicit strategy switching during repair | Complete | verify_strategy_neutrality_and_semantic_repair_guard.py, verify_26_property_repair_and_claim_boundaries.py | N/A |
| 33 | Add pre-Agent-7 readiness diagnosis | Complete | verify_pre_agent7_readiness_diagnosis.py | N/A |
| 34 | Replace keyword-only weakening detection with semantic comparison | Complete | verify_strategy_neutrality_and_semantic_repair_guard.py, verify_26_property_repair_and_claim_boundaries.py | N/A |
| 35 | Make resume hash-bound with explicit policies | Complete | verify_hash_bound_resume_semantics.py | N/A |
| 36 | Implement real live child-process streaming | Complete | verify_live_child_process_streaming.py | N/A |
| 37 | Improve Agent 10 missing-stage classification | Complete | verify_agent10_stage_classification_and_agent11_wording.py | N/A |
| 38 | Strengthen Agent 11 outcome wording | Complete | verify_agent10_stage_classification_and_agent11_wording.py, verify_success_text_failure_hint_gating.py | N/A |

## Trust boundary

Implementation completion and local/fake-tool regressions do not substitute for the packaged real CBMC 6.9.0 grammar/transformation acceptance on an Ubuntu host.
