# RQ2 architectural evidence locator

This locator reconstructs the V1–V4 architectural-development evidence as evidence units rather than filename-derived versions. Historical names remain traceability locators; release classification records architecture, evidential role, source reference and preservation status.

| ID | Architecture | Configuration | Target | Class | Evidence reference | Release classification | Preservation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| RQ2-E01 | V1 | initial architectural prototype | workflow architecture | ARCHITECTURE_SNAPSHOT | manifests/v1-evaluated-initial-workflow-publication-metadata.txt | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E02 | V2 | completed replayable deterministic workflow | workflow architecture and three-run development sequence | ARCHITECTURE_AND_RUN_SEQUENCE | v2-evaluated-initial-workflow/runs/mlk_poly_add_case_study_summary/run_001_002_003_comparison.csv | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E03 | V2 | initial deterministic run | mlk_poly_add run 001 | RUN | v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/final_run_summary.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E04 | V2 | human-corrected continuation | mlk_poly_add run 002 | RUN | v2-evaluated-initial-workflow/runs/run_002_mlk_poly_add_human_corrected_cbmc/run_002_result_summary.md | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E05 | V2 | post-correction workflow run | mlk_poly_add run 003 | RUN | v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/final_run_summary.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E06 | V3 | API-backed LLM-integrated workflow | workflow architecture | ARCHITECTURE_SNAPSHOT | v3-evaluated-llm-integrated-workflow/README_FINAL_DEPLOYMENT.md | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E07 | V3 | real API run 001 | mlk_poly_add | RUN | v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/status.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E08 | V3 | scoped full-FIPS real API run | mlk_poly_add | RUN | v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/status.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E09 | V3 | repair follow-up run | mlk_poly_add | RUN | v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_repair1_20260711_095925/status.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E10 | V3 | xhigh follow-up run | mlk_poly_add | RUN | v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_xhigh_20260711_063722/status.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E11 | V4 | LLM-first second-generation baseline | workflow architecture | ARCHITECTURE_SNAPSHOT | v4-evaluated-second-generation-llm-integrated-workflow/docs/LLM_FIRST_ARCHITECTURE_AND_POLICY.md | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E12 | V4 | LLM-first run 001 | mlk_poly_add | RUN | v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/07_tool_execution/iterations/iteration_00/tool_outputs/06_cbmc_status.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E13 | V4 | LLM-first run 002 | mlk_poly_add | RUN | v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/final/final_run_summary.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E14 | V4 | LLM-first run 003 | mlk_poly_add | RUN | v4-evaluated-second-generation-llm-integrated-workflow/runs/run_003_mlk_poly_add_open_discovery_repair_enabled_20260715/final/final_run_summary.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E15 | V4 | pre-Codex local regression baseline | engineering readiness | ENGINEERING_REGRESSION | v4-evaluated-second-generation-llm-integrated-workflow/release_evidence/FINAL_LOCAL_53_REGRESSION_RESULTS.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E16 | V4 | Codex backend utility increment | Codex integration mechanism | UTILITY_INCREMENT | v4-codex-skills-scientific-experiment-baseline/agents/common/llm_client.py | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E17 | V4 | Codex backend offline acceptance | engineering readiness | ENGINEERING_REGRESSION | v4-codex-skills-scientific-experiment-baseline/release_evidence/codex_exec_integration/FINAL_INTEGRATION_STATUS.json | RELEASE_CLASSIFICATION_PASS | COMPLETE |
| RQ2-E18 | V4 | live Codex host investigation | mlk_poly_add | LIVE_HOST_RUN | PUBLIC_REPOSITORY_PRIMARY_EVIDENCE | RELEASE_CLASSIFICATION_PASS | PUBLIC_EVIDENCE_RETAINED |
| RQ2-E19 | V4 | live Codex host investigation | mlk_poly_sub | LIVE_HOST_RUN | PUBLIC_REPOSITORY_PRIMARY_EVIDENCE | RELEASE_CLASSIFICATION_PASS | PUBLIC_EVIDENCE_RETAINED |
