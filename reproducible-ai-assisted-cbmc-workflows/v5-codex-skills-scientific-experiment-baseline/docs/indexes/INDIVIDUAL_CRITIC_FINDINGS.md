# Individual Critic and Gate Findings Index

All underlying critic, review, and gate files are preserved at the listed paths. Extracted scalar fields are navigation aids only.

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v1-evaluated-initial-workflow/agents_v1_before_agents_v2_upgrade/review_critic_agent.py`

- Size: `56442` bytes
- SHA-256: `1f79930217949268e07c6bea6c90dfaab45bd5aab6b14dce37dcf86ad739e837`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/agents/review_critic_agent.py`

- Size: `78035` bytes
- SHA-256: `1453f2e9146853308c051a3ff41e0bca1676a80016fb5a46243a1382a3fcbdcc`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/05_assumption_evidence_review.csv`

- Size: `72` bytes
- SHA-256: `5ff1695352532e457b1eeaeeb3cbe323eb580afc46295920c5901320223c92ff`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/05_critic_review.json`

- Size: `15089` bytes
- SHA-256: `045d2fc0cad48dbf9e2760a9a8703269b921893a141ab6efecfbbdd4e49232d2`

| Field | Recorded value |
|---|---|
| `review_status` | `conditional_accept_for_tool` |
| `status` | `conditional_accept_for_tool` |
| `input_files.rich_agent2v2_files.algorithm_blocks` | `/home/<user>/thesis-agent-workflow/runs/run_001_mlk_poly_add_fresh_baseline/01_algorithm_blocks.json` |
| `review_checklist[0].severity_if_failed` | `critical` |
| `review_checklist[1].severity_if_failed` | `low` |
| `review_checklist[2].severity_if_failed` | `high` |
| `review_checklist[3].severity_if_failed` | `high` |
| `review_checklist[4].severity_if_failed` | `medium` |
| `review_checklist[5].severity_if_failed` | `critical` |
| `review_checklist[6].severity_if_failed` | `medium` |
| `issues[0].severity` | `medium` |
| `issues[0].recommendation` | `Check whether this assertion is implementation-derived only, or add explicit spec/algorithm evidence before relying on it.` |
| `issues[1].severity` | `medium` |
| `issues[1].recommendation` | `Separate memory-safety checking from arithmetic correctness, or add carefully justified coefficient preconditions before checking equality.` |
| `issues[2].severity` | `low` |
| `issues[2].recommendation` | `Decide whether aliases like r == a or r == b are allowed by the implementation contract, and document the choice.` |
| `quality_metrics.highest_severity` | `medium` |
| `quality_metrics.issue_count` | `3` |
| `tool_execution_allowed` | `True` |
| `repair_recommended_before_tool` | `False` |
| `next_recommended_action` | `Artifact may go to Formal Tool Execution Agent, but preserve critic warnings for counterexample analysis and human review.` |
| `property_coverage[0].coverage_status` | `covered_candidate` |
| `property_coverage[1].coverage_status` | `covered_candidate` |
| `property_coverage[2].coverage_status` | `covered_candidate` |
| `property_coverage[3].coverage_status` | `covered_candidate` |
| `property_coverage[4].coverage_status` | `covered_candidate` |
| `property_coverage[5].coverage_status` | `covered_candidate` |
| `property_coverage[6].coverage_status` | `covered_candidate` |
| `property_coverage[7].coverage_status` | `covered_candidate` |
| `rich_spec_review.assertion_algorithm_alignment[0].alignment_status` | `not_aligned` |
| `rich_spec_review.uncertainty_review.status` | `acknowledged` |
| `rich_spec_review.uncertainty_review.severity` | `info` |
| `rich_spec_review.rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/05_critic_review.md`

- Size: `4310` bytes
- SHA-256: `3150e12701aea14dd7cfdebbabb82f220aed489daef9696711f134c236a336f7`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/05_spec_grounding_review.json`

- Size: `3115` bytes
- SHA-256: `e470799b641e11a6ee88a2154d530401146ece0cb1c94776e7290c43e859f1ac`

| Field | Recorded value |
|---|---|
| `assertion_algorithm_alignment[0].alignment_status` | `not_aligned` |
| `uncertainty_review.status` | `acknowledged` |
| `uncertainty_review.severity` | `info` |
| `rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/05_symbol_uncertainty_review.json`

- Size: `2704` bytes
- SHA-256: `8fa11a0adfbb7506d8aca2dc843384a678e8f925e43403936ddca80911faacad`

| Field | Recorded value |
|---|---|
| `uncertainty_review.status` | `acknowledged` |
| `uncertainty_review.severity` | `info` |
| `rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/06_critic_gate_decision.json`

- Size: `731` bytes
- SHA-256: `3ffc099289ad55c407321b76023d5b2ad4eaf7717b0c18996c79865056b1b1de`

| Field | Recorded value |
|---|---|
| `respect_critic_gate` | `True` |
| `ignore_critic_gate_used` | `False` |
| `review_status` | `conditional_accept_for_tool` |
| `tool_execution_allowed_from_critic` | `True` |
| `repair_recommended_before_tool` | `False` |
| `high_or_critical_issue_count` | `0` |
| `should_block_without_override` | `False` |
| `blocked` | `False` |
| `decision` | `allowed_to_prepare_or_run_tool` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/agent_status/05_critic_review_status.json`

- Size: `1315` bytes
- SHA-256: `a2370adcbc5b77c49541f3257d6b93402bbd6e125a69db8936b27f56d3ab9f63`

| Field | Recorded value |
|---|---|
| `status` | `passed` |
| `review_status` | `conditional_accept_for_tool` |
| `tool_execution_allowed` | `True` |
| `repair_recommended_before_tool` | `False` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/llm_prompts/05_critic_review_prompt.txt`

- Size: `8477` bytes
- SHA-256: `bf71e88251ebc974fee84dc6ddf8d67ec78fafa06595ee2aef47a03d3393d616`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/stdout_stderr/critic_review_stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/failed_runs/run_001_mlk_poly_add_fresh_baseline_repair_arg_fail_20260709_053326/stdout_stderr/critic_review_stdout.txt`

- Size: `890` bytes
- SHA-256: `2386dfe57a19fa2bddee8a027832e8681ef099dac68a9f9311d56299f8ad179b`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/05_assumption_evidence_review.csv`

- Size: `72` bytes
- SHA-256: `5ff1695352532e457b1eeaeeb3cbe323eb580afc46295920c5901320223c92ff`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/05_critic_review.json`

- Size: `15083` bytes
- SHA-256: `fce0a1db1b68b8fe6fb4362fdbebcc35c8012ed5cbb03e2ef0b59bc3d2fceae3`

| Field | Recorded value |
|---|---|
| `review_status` | `conditional_accept_for_tool` |
| `status` | `conditional_accept_for_tool` |
| `input_files.rich_agent2v2_files.algorithm_blocks` | `/home/<user>/thesis-agent-workflow/runs/run_001_mlk_poly_add_fresh_baseline/01_algorithm_blocks.json` |
| `review_checklist[0].severity_if_failed` | `critical` |
| `review_checklist[1].severity_if_failed` | `low` |
| `review_checklist[2].severity_if_failed` | `high` |
| `review_checklist[3].severity_if_failed` | `high` |
| `review_checklist[4].severity_if_failed` | `medium` |
| `review_checklist[5].severity_if_failed` | `critical` |
| `review_checklist[6].severity_if_failed` | `medium` |
| `issues[0].severity` | `medium` |
| `issues[0].recommendation` | `Check whether this assertion is implementation-derived only, or add explicit spec/algorithm evidence before relying on it.` |
| `issues[1].severity` | `medium` |
| `issues[1].recommendation` | `Separate memory-safety checking from arithmetic correctness, or add carefully justified coefficient preconditions before checking equality.` |
| `issues[2].severity` | `low` |
| `issues[2].recommendation` | `Decide whether aliases like r == a or r == b are allowed by the implementation contract, and document the choice.` |
| `quality_metrics.highest_severity` | `medium` |
| `quality_metrics.issue_count` | `3` |
| `tool_execution_allowed` | `True` |
| `repair_recommended_before_tool` | `False` |
| `next_recommended_action` | `Artifact may go to Formal Tool Execution Agent, but preserve critic warnings for counterexample analysis and human review.` |
| `property_coverage[0].coverage_status` | `covered_candidate` |
| `property_coverage[1].coverage_status` | `covered_candidate` |
| `property_coverage[2].coverage_status` | `covered_candidate` |
| `property_coverage[3].coverage_status` | `covered_candidate` |
| `property_coverage[4].coverage_status` | `covered_candidate` |
| `property_coverage[5].coverage_status` | `covered_candidate` |
| `property_coverage[6].coverage_status` | `covered_candidate` |
| `property_coverage[7].coverage_status` | `covered_candidate` |
| `rich_spec_review.assertion_algorithm_alignment[0].alignment_status` | `not_aligned` |
| `rich_spec_review.uncertainty_review.status` | `acknowledged` |
| `rich_spec_review.uncertainty_review.severity` | `info` |
| `rich_spec_review.rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/05_critic_review.md`

- Size: `4309` bytes
- SHA-256: `048f4596dba6c64f5093bdf88f9b2b78eef41223e9e4ca2614cf91ef3b91ab99`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/05_spec_grounding_review.json`

- Size: `3115` bytes
- SHA-256: `0aceb83f4ce87436b56d9594d0e1be975a2ac5bc9ca5594b57bf2c377ad1de0a`

| Field | Recorded value |
|---|---|
| `assertion_algorithm_alignment[0].alignment_status` | `not_aligned` |
| `uncertainty_review.status` | `acknowledged` |
| `uncertainty_review.severity` | `info` |
| `rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/05_symbol_uncertainty_review.json`

- Size: `2704` bytes
- SHA-256: `8fa11a0adfbb7506d8aca2dc843384a678e8f925e43403936ddca80911faacad`

| Field | Recorded value |
|---|---|
| `uncertainty_review.status` | `acknowledged` |
| `uncertainty_review.severity` | `info` |
| `rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/06_critic_gate_decision.json`

- Size: `731` bytes
- SHA-256: `b4773a5230d46bb9e3db72446fa63d70042973db1f051ceec5bd2e7c2d3d3e33`

| Field | Recorded value |
|---|---|
| `respect_critic_gate` | `True` |
| `ignore_critic_gate_used` | `False` |
| `review_status` | `conditional_accept_for_tool` |
| `tool_execution_allowed_from_critic` | `True` |
| `repair_recommended_before_tool` | `False` |
| `high_or_critical_issue_count` | `0` |
| `should_block_without_override` | `False` |
| `blocked` | `False` |
| `decision` | `allowed_to_prepare_or_run_tool` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/08_repair_safety_review.json`

- Size: `1090` bytes
- SHA-256: `0e706dbc6524250df16473f62c7a5e51c370900dcd0d874d22dd482fb8179a32`

| Field | Recorded value |
|---|---|
| `overall_safety_status` | `candidate_safe_with_review` |
| `checks.recheck_recommended_when_code_changed` | `True` |
| `risk_items[0].severity` | `medium` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/agent_status/05_critic_review_status.json`

- Size: `1315` bytes
- SHA-256: `a23846f4dda5a72c5712c62889bfd2faf381944d1b4a39129b97aa4e8d4777a8`

| Field | Recorded value |
|---|---|
| `status` | `passed` |
| `review_status` | `conditional_accept_for_tool` |
| `tool_execution_allowed` | `True` |
| `repair_recommended_before_tool` | `False` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/evaluation/human_review_checklist.md`

- Size: `13436` bytes
- SHA-256: `263df0a12adfb8a8bb51c0f40d69d8872b8cbf54dfe0c48096beb6932b7b0437`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/evaluation/spec_claim_human_review_status.csv`

- Size: `85592` bytes
- SHA-256: `61c9ffae605e2009e43cb8253cc137a0729a1875411ff7eae80a87d3589a833b`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/llm_prompts/05_critic_review_prompt.txt`

- Size: `9102` bytes
- SHA-256: `13f8c365d083e9959f3d2854148ae4f2436146521998ed259f8ed96051ec7966`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/repairs/iteration_00/08_repair_safety_review.json`

- Size: `1090` bytes
- SHA-256: `0e706dbc6524250df16473f62c7a5e51c370900dcd0d874d22dd482fb8179a32`

| Field | Recorded value |
|---|---|
| `overall_safety_status` | `candidate_safe_with_review` |
| `checks.recheck_recommended_when_code_changed` | `True` |
| `risk_items[0].severity` | `medium` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/snapshots/iteration_00/05_critic_review.json`

- Size: `15089` bytes
- SHA-256: `aafe8c8f7fdcfe2974242ceb4d2db1f5e6b8689a2607c84159aa4c64de90dab5`

| Field | Recorded value |
|---|---|
| `review_status` | `conditional_accept_for_tool` |
| `status` | `conditional_accept_for_tool` |
| `input_files.rich_agent2v2_files.algorithm_blocks` | `/home/<user>/thesis-agent-workflow/runs/run_001_mlk_poly_add_fresh_baseline/01_algorithm_blocks.json` |
| `review_checklist[0].severity_if_failed` | `critical` |
| `review_checklist[1].severity_if_failed` | `low` |
| `review_checklist[2].severity_if_failed` | `high` |
| `review_checklist[3].severity_if_failed` | `high` |
| `review_checklist[4].severity_if_failed` | `medium` |
| `review_checklist[5].severity_if_failed` | `critical` |
| `review_checklist[6].severity_if_failed` | `medium` |
| `issues[0].severity` | `medium` |
| `issues[0].recommendation` | `Check whether this assertion is implementation-derived only, or add explicit spec/algorithm evidence before relying on it.` |
| `issues[1].severity` | `medium` |
| `issues[1].recommendation` | `Separate memory-safety checking from arithmetic correctness, or add carefully justified coefficient preconditions before checking equality.` |
| `issues[2].severity` | `low` |
| `issues[2].recommendation` | `Decide whether aliases like r == a or r == b are allowed by the implementation contract, and document the choice.` |
| `quality_metrics.highest_severity` | `medium` |
| `quality_metrics.issue_count` | `3` |
| `tool_execution_allowed` | `True` |
| `repair_recommended_before_tool` | `False` |
| `next_recommended_action` | `Artifact may go to Formal Tool Execution Agent, but preserve critic warnings for counterexample analysis and human review.` |
| `property_coverage[0].coverage_status` | `covered_candidate` |
| `property_coverage[1].coverage_status` | `covered_candidate` |
| `property_coverage[2].coverage_status` | `covered_candidate` |
| `property_coverage[3].coverage_status` | `covered_candidate` |
| `property_coverage[4].coverage_status` | `covered_candidate` |
| `property_coverage[5].coverage_status` | `covered_candidate` |
| `property_coverage[6].coverage_status` | `covered_candidate` |
| `property_coverage[7].coverage_status` | `covered_candidate` |
| `rich_spec_review.assertion_algorithm_alignment[0].alignment_status` | `not_aligned` |
| `rich_spec_review.uncertainty_review.status` | `acknowledged` |
| `rich_spec_review.uncertainty_review.severity` | `info` |
| `rich_spec_review.rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/snapshots/iteration_01/05_critic_review.json`

- Size: `15083` bytes
- SHA-256: `fce0a1db1b68b8fe6fb4362fdbebcc35c8012ed5cbb03e2ef0b59bc3d2fceae3`

| Field | Recorded value |
|---|---|
| `review_status` | `conditional_accept_for_tool` |
| `status` | `conditional_accept_for_tool` |
| `input_files.rich_agent2v2_files.algorithm_blocks` | `/home/<user>/thesis-agent-workflow/runs/run_001_mlk_poly_add_fresh_baseline/01_algorithm_blocks.json` |
| `review_checklist[0].severity_if_failed` | `critical` |
| `review_checklist[1].severity_if_failed` | `low` |
| `review_checklist[2].severity_if_failed` | `high` |
| `review_checklist[3].severity_if_failed` | `high` |
| `review_checklist[4].severity_if_failed` | `medium` |
| `review_checklist[5].severity_if_failed` | `critical` |
| `review_checklist[6].severity_if_failed` | `medium` |
| `issues[0].severity` | `medium` |
| `issues[0].recommendation` | `Check whether this assertion is implementation-derived only, or add explicit spec/algorithm evidence before relying on it.` |
| `issues[1].severity` | `medium` |
| `issues[1].recommendation` | `Separate memory-safety checking from arithmetic correctness, or add carefully justified coefficient preconditions before checking equality.` |
| `issues[2].severity` | `low` |
| `issues[2].recommendation` | `Decide whether aliases like r == a or r == b are allowed by the implementation contract, and document the choice.` |
| `quality_metrics.highest_severity` | `medium` |
| `quality_metrics.issue_count` | `3` |
| `tool_execution_allowed` | `True` |
| `repair_recommended_before_tool` | `False` |
| `next_recommended_action` | `Artifact may go to Formal Tool Execution Agent, but preserve critic warnings for counterexample analysis and human review.` |
| `property_coverage[0].coverage_status` | `covered_candidate` |
| `property_coverage[1].coverage_status` | `covered_candidate` |
| `property_coverage[2].coverage_status` | `covered_candidate` |
| `property_coverage[3].coverage_status` | `covered_candidate` |
| `property_coverage[4].coverage_status` | `covered_candidate` |
| `property_coverage[5].coverage_status` | `covered_candidate` |
| `property_coverage[6].coverage_status` | `covered_candidate` |
| `property_coverage[7].coverage_status` | `covered_candidate` |
| `rich_spec_review.assertion_algorithm_alignment[0].alignment_status` | `not_aligned` |
| `rich_spec_review.uncertainty_review.status` | `acknowledged` |
| `rich_spec_review.uncertainty_review.severity` | `info` |
| `rich_spec_review.rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/stdout_stderr/critic_review_stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_001_mlk_poly_add_fresh_baseline/stdout_stderr/critic_review_stdout.txt`

- Size: `890` bytes
- SHA-256: `2386dfe57a19fa2bddee8a027832e8681ef099dac68a9f9311d56299f8ad179b`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/05_assumption_evidence_review.csv`

- Size: `330` bytes
- SHA-256: `1efe386145210db6722258f92f2add2364dbf6ca7055bfe6c6578b41bb6122d9`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/05_critic_review.json`

- Size: `16124` bytes
- SHA-256: `7c702889caf9b749cc7fdb9bb92cb9b5280a538fcb47101d963cffb7facbd0d4`

| Field | Recorded value |
|---|---|
| `review_status` | `conditional_accept_for_tool` |
| `status` | `conditional_accept_for_tool` |
| `input_files.rich_agent2v2_files.algorithm_blocks` | `/home/<user>/thesis-agent-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/01_algorithm_blocks.json` |
| `review_checklist[0].severity_if_failed` | `critical` |
| `review_checklist[1].severity_if_failed` | `low` |
| `review_checklist[2].severity_if_failed` | `high` |
| `review_checklist[3].severity_if_failed` | `high` |
| `review_checklist[4].severity_if_failed` | `medium` |
| `review_checklist[5].severity_if_failed` | `critical` |
| `review_checklist[6].severity_if_failed` | `medium` |
| `issues[0].severity` | `medium` |
| `issues[0].recommendation` | `Add evidence in Agent 5 manifest/traceability CSV, cite the selected spec precondition, or move this assumption to a human-reviewed variant.` |
| `issues[1].severity` | `medium` |
| `issues[1].recommendation` | `Add evidence in Agent 5 manifest/traceability CSV, cite the selected spec precondition, or move this assumption to a human-reviewed variant.` |
| `issues[2].severity` | `low` |
| `issues[2].recommendation` | `This is acceptable only if selected properties are intentionally checked through CBMC built-in checks; document that clearly.` |
| `issues[3].severity` | `low` |
| `issues[3].recommendation` | `Decide whether aliases like r == a or r == b are allowed by the implementation contract, and document the choice.` |
| `quality_metrics.highest_severity` | `medium` |
| `quality_metrics.issue_count` | `4` |
| `tool_execution_allowed` | `True` |
| `repair_recommended_before_tool` | `False` |
| `next_recommended_action` | `Artifact may go to Formal Tool Execution Agent, but preserve critic warnings for counterexample analysis and human review.` |
| `property_coverage[0].coverage_status` | `covered_candidate` |
| `property_coverage[1].coverage_status` | `covered_candidate` |
| `property_coverage[2].coverage_status` | `covered_candidate` |
| `property_coverage[3].coverage_status` | `covered_candidate` |
| `property_coverage[4].coverage_status` | `covered_candidate` |
| `property_coverage[5].coverage_status` | `covered_candidate` |
| `property_coverage[6].coverage_status` | `covered_candidate` |
| `property_coverage[7].coverage_status` | `covered_candidate` |
| `rich_spec_review.assumption_evidence_review[0].traceability_status` | `not_traced` |
| `rich_spec_review.assumption_evidence_review[1].traceability_status` | `not_traced` |
| `rich_spec_review.uncertainty_review.status` | `acknowledged` |
| `rich_spec_review.uncertainty_review.severity` | `info` |
| `rich_spec_review.rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/05_critic_review.md`

- Size: `4478` bytes
- SHA-256: `fdc39994c9593ff160d253f9444e8be6146575ac2c0a7e9161fb3f29e0640b93`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/05_spec_grounding_review.json`

- Size: `3319` bytes
- SHA-256: `4b952ea002fc2069355b4371841b7005fc19f9757bcc70e3a614477d0bc6347b`

| Field | Recorded value |
|---|---|
| `assumption_evidence_review[0].traceability_status` | `not_traced` |
| `assumption_evidence_review[1].traceability_status` | `not_traced` |
| `uncertainty_review.status` | `acknowledged` |
| `uncertainty_review.severity` | `info` |
| `rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/05_symbol_uncertainty_review.json`

- Size: `2704` bytes
- SHA-256: `8fa11a0adfbb7506d8aca2dc843384a678e8f925e43403936ddca80911faacad`

| Field | Recorded value |
|---|---|
| `uncertainty_review.status` | `acknowledged` |
| `uncertainty_review.severity` | `info` |
| `rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/06_critic_gate_decision.json`

- Size: `731` bytes
- SHA-256: `b47d1e363546e990504a9983c4495c335a28fe099033b3069c2d77db18586872`

| Field | Recorded value |
|---|---|
| `respect_critic_gate` | `True` |
| `ignore_critic_gate_used` | `False` |
| `review_status` | `conditional_accept_for_tool` |
| `tool_execution_allowed_from_critic` | `True` |
| `repair_recommended_before_tool` | `False` |
| `high_or_critical_issue_count` | `0` |
| `should_block_without_override` | `False` |
| `blocked` | `False` |
| `decision` | `allowed_to_prepare_or_run_tool` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/agent_status/05_critic_review_status.json`

- Size: `1350` bytes
- SHA-256: `ee97e962cdd10f73d7573b129e4e5a6f8ce47cc377b87fba8a1f37ed7b3cf6b1`

| Field | Recorded value |
|---|---|
| `status` | `passed` |
| `review_status` | `conditional_accept_for_tool` |
| `tool_execution_allowed` | `True` |
| `repair_recommended_before_tool` | `False` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/evaluation/human_review_checklist.md`

- Size: `13515` bytes
- SHA-256: `cfdf45f33726bc0abbec7ded01e2b9da9d64107751dcee098540d438d3b7a26e`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/evaluation/spec_claim_human_review_status.csv`

- Size: `85592` bytes
- SHA-256: `61c9ffae605e2009e43cb8253cc137a0729a1875411ff7eae80a87d3589a833b`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/llm_prompts/05_critic_review_prompt.txt`

- Size: `8305` bytes
- SHA-256: `1b8c5f55aece4b67c8c66b1806232f476f7dcf01d14dc733879954ed121add7b`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/snapshots/iteration_00/05_critic_review.json`

- Size: `16124` bytes
- SHA-256: `7c702889caf9b749cc7fdb9bb92cb9b5280a538fcb47101d963cffb7facbd0d4`

| Field | Recorded value |
|---|---|
| `review_status` | `conditional_accept_for_tool` |
| `status` | `conditional_accept_for_tool` |
| `input_files.rich_agent2v2_files.algorithm_blocks` | `/home/<user>/thesis-agent-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/01_algorithm_blocks.json` |
| `review_checklist[0].severity_if_failed` | `critical` |
| `review_checklist[1].severity_if_failed` | `low` |
| `review_checklist[2].severity_if_failed` | `high` |
| `review_checklist[3].severity_if_failed` | `high` |
| `review_checklist[4].severity_if_failed` | `medium` |
| `review_checklist[5].severity_if_failed` | `critical` |
| `review_checklist[6].severity_if_failed` | `medium` |
| `issues[0].severity` | `medium` |
| `issues[0].recommendation` | `Add evidence in Agent 5 manifest/traceability CSV, cite the selected spec precondition, or move this assumption to a human-reviewed variant.` |
| `issues[1].severity` | `medium` |
| `issues[1].recommendation` | `Add evidence in Agent 5 manifest/traceability CSV, cite the selected spec precondition, or move this assumption to a human-reviewed variant.` |
| `issues[2].severity` | `low` |
| `issues[2].recommendation` | `This is acceptable only if selected properties are intentionally checked through CBMC built-in checks; document that clearly.` |
| `issues[3].severity` | `low` |
| `issues[3].recommendation` | `Decide whether aliases like r == a or r == b are allowed by the implementation contract, and document the choice.` |
| `quality_metrics.highest_severity` | `medium` |
| `quality_metrics.issue_count` | `4` |
| `tool_execution_allowed` | `True` |
| `repair_recommended_before_tool` | `False` |
| `next_recommended_action` | `Artifact may go to Formal Tool Execution Agent, but preserve critic warnings for counterexample analysis and human review.` |
| `property_coverage[0].coverage_status` | `covered_candidate` |
| `property_coverage[1].coverage_status` | `covered_candidate` |
| `property_coverage[2].coverage_status` | `covered_candidate` |
| `property_coverage[3].coverage_status` | `covered_candidate` |
| `property_coverage[4].coverage_status` | `covered_candidate` |
| `property_coverage[5].coverage_status` | `covered_candidate` |
| `property_coverage[6].coverage_status` | `covered_candidate` |
| `property_coverage[7].coverage_status` | `covered_candidate` |
| `rich_spec_review.assumption_evidence_review[0].traceability_status` | `not_traced` |
| `rich_spec_review.assumption_evidence_review[1].traceability_status` | `not_traced` |
| `rich_spec_review.uncertainty_review.status` | `acknowledged` |
| `rich_spec_review.uncertainty_review.severity` | `info` |
| `rich_spec_review.rich_context_files_seen.algorithm_blocks` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/stdout_stderr/critic_review_stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v2-evaluated-initial-workflow/runs/run_003_mlk_poly_add_agent_improved_cbmc/stdout_stderr/critic_review_stdout.txt`

- Size: `915` bytes
- SHA-256: `15699e1ace949252f5c592f27b9ef356967259d83aeb42b600c0a8df8aba4723`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/LLM_PROFILE_PATCH_INPUT_20260711T012711Z/agents/review_critic_agent.py`

- Size: `67841` bytes
- SHA-256: `46895bb1fde42bbaf1e2610e700f519bf35dd0d13ed3e8e57def9cf4f1905318`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/agents/review_critic_agent.py`

- Size: `68473` bytes
- SHA-256: `4395b80f3a7f712ef7dfa98b1e0f319eb4327a2da5442ba259aa18a04efc7a15`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/backups/critic_tool_readiness_20260711T060309Z/review_critic_agent.py`

- Size: `67841` bytes
- SHA-256: `46895bb1fde42bbaf1e2610e700f519bf35dd0d13ed3e8e57def9cf4f1905318`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_assumption_evidence_review.deterministic.csv`

- Size: `7` bytes
- SHA-256: `24526432f951ea86e61db71a2c7df058d690643d1792c6525c784823544d3c03`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_critic_review.deterministic.json`

- Size: `5713` bytes
- SHA-256: `0217e4dd32eb192022ba097b45ba5cad99541c24fc34877ab6b16637dd4430e3`

| Field | Recorded value |
|---|---|
| `content.old_state_pattern_check.warning` | `No obvious old-state snapshot terms detected.` |
| `content.issues[0].severity` | `critical` |
| `content.issues[0].blocks_tool_execution` | `True` |
| `content.warnings[0].severity` | `major` |
| `content.warnings[0].blocks_tool_execution` | `False` |
| `content.blocking_issue_count` | `1` |
| `content.warning_count` | `1` |
| `content.recommended_gate` | `blocked` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_review_issue_matrix.deterministic.csv`

- Size: `293` bytes
- SHA-256: `4d41488b99839b20b5a5ec60ff97ede6898de47907f973d577df972b71366ff0`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/llm_authoritative/05_critic_review.json`

- Size: `1908` bytes
- SHA-256: `24ae9b85180dad7b8bd909e0efd6648651afdc12c1861365c64923f3a01385dc`

| Field | Recorded value |
|---|---|
| `content.reviewed_artefacts.deterministic_recommended_gate` | `blocked` |
| `content.gate_recommendation` | `human_review_required` |
| `content.warnings[0].issue` | `Mock critic review` |
| `content.assumption_review.status` | `not_reviewed_in_mock_mode` |
| `content.assertion_review.status` | `not_reviewed_in_mock_mode` |
| `content.old_state_new_state_review.status` | `not_reviewed_in_mock_mode` |
| `content.contract_review.status` | `not_reviewed_in_mock_mode` |
| `content.verification_strategy_review.status` | `not_reviewed_in_mock_mode` |
| `content.independence_review.status` | `not_reviewed_in_mock_mode` |
| `content.scope_and_overclaim_review.status` | `not_reviewed_in_mock_mode` |
| `content.deterministic_reference_assessment.status` | `not_assessed_by_real_llm` |
| `content.deterministic_reference_assessment.warning` | `Mock output only.` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/logs/06_review_critic_status.json`

- Size: `4082` bytes
- SHA-256: `79c74f87c16c1bf8d3a405128a501e75d1fdd7faecb52fa95ffdc28fc5038cdb`

| Field | Recorded value |
|---|---|
| `llm_result.parsed_json.reviewed_artefacts.deterministic_recommended_gate` | `blocked` |
| `llm_result.parsed_json.gate_recommendation` | `human_review_required` |
| `llm_result.parsed_json.warnings[0].issue` | `Mock critic review` |
| `llm_result.parsed_json.assumption_review.status` | `not_reviewed_in_mock_mode` |
| `llm_result.parsed_json.assertion_review.status` | `not_reviewed_in_mock_mode` |
| `llm_result.parsed_json.old_state_new_state_review.status` | `not_reviewed_in_mock_mode` |
| `llm_result.parsed_json.contract_review.status` | `not_reviewed_in_mock_mode` |
| `llm_result.parsed_json.verification_strategy_review.status` | `not_reviewed_in_mock_mode` |
| `llm_result.parsed_json.independence_review.status` | `not_reviewed_in_mock_mode` |
| `llm_result.parsed_json.scope_and_overclaim_review.status` | `not_reviewed_in_mock_mode` |
| `llm_result.parsed_json.deterministic_reference_assessment.status` | `not_assessed_by_real_llm` |
| `llm_result.parsed_json.deterministic_reference_assessment.warning` | `Mock output only.` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stdout.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/prompt_package/06_review_critic_prompt.txt`

- Size: `7792` bytes
- SHA-256: `89ee3edab72d9dad01f3985a37fb6598e6575991ce29f3a67f278bc0e9e18986`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/validation/05_property_campaign_review_validation.json`

- Size: `915` bytes
- SHA-256: `a166f4fc7e4b05a79373705db7166b860cdd37f1d98d014e8f739726211853ac`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.json`

- Size: `2337` bytes
- SHA-256: `b7c0456c98ce645b5f0c06dbb697c64e97fe6c5629f56d19b3ae1c7caceafe21`

| Field | Recorded value |
|---|---|
| `content.final_gate` | `human_review_required` |
| `content.tool_execution_allowed` | `False` |
| `content.reason` | `Mock LLM review cannot provide clean approval.` |
| `content.llm_gate_recommendation` | `human_review_required` |
| `content.deterministic_recommended_gate` | `blocked` |
| `content.blocking_diagnostics[0].severity` | `critical` |
| `content.blocking_diagnostics[0].blocks_tool_execution` | `True` |
| `content.trust_boundary.gate_decision` | `conservative_workflow_control_decision` |
| `content.formal_build_plan.warning_count` | `0` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/diagnostics/p19_orchestration_probe_20260711T080622Z/P19/runs/campaign_p19_mock/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.md`

- Size: `356` bytes
- SHA-256: `06d704b2fec6f083ff8cb78554e18e956a49f9b3f34792157b60a4b64f8d6f53`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_assumption_evidence_review.deterministic.csv`

- Size: `550` bytes
- SHA-256: `7395b7b51a40b495210ece98cef36bfb2e6a8fe36ae6ea5ae91aa5bde64c0aeb`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_critic_review.deterministic.json`

- Size: `6802` bytes
- SHA-256: `62e992ff4ace69ac7fd7680c56bbbc95480fcadb6502d24d68a3c345111e0a40`

| Field | Recorded value |
|---|---|
| `content.warnings[0].severity` | `minor` |
| `content.warnings[0].blocks_tool_execution` | `False` |
| `content.blocking_issue_count` | `0` |
| `content.warning_count` | `1` |
| `content.recommended_gate` | `needs_human_review` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_review_issue_matrix.deterministic.csv`

- Size: `173` bytes
- SHA-256: `5aa44ae53b784855bea1dbf5c7a2bab7b684a09665dcb3a7c1ee56db7593e594`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/llm_authoritative/05_critic_review.json`

- Size: `16610` bytes
- SHA-256: `67500293e52975d308121f72f0abb2768f75006e21c0eb1c4c1bc2382a1ebe1c`

| Field | Recorded value |
|---|---|
| `content.reviewed_artefacts.deterministic_recommended_gate` | `needs_human_review` |
| `content.gate_recommendation` | `needs_revision_before_tool_execution` |
| `content.blocking_issues[0].issue` | `The deterministic formal build plan selects CBMC entry function "harness", but the rendered C harness defines "void harness_mlk_poly_add_int16_safe_sum(void)" and no function named "harness" is evidenced.` |
| `content.warnings[0].issue` | `The harness assumes memory_no_alias(r, sizeof(mlk_poly)) and memory_no_alias(b, sizeof(mlk_poly)), which maps to __CPROVER_is_fresh and is stronger than ordinary non-null/non-overlap reasoning.` |
| `content.warnings[1].issue` | `The selected property is conditional on explicit per-coefficient INT16_MIN..INT16_MAX sum assumptions and does not derive those assumptions from real callers.` |
| `content.minor_issues[0].issue` | `The second assertion largely follows from the first assertion plus the pre-assumed INT16 range, so it adds limited independent checking value.` |
| `content.minor_issues[1].issue` | `The old_state_snapshot_plan field in the prior artefact plan uses a free-form value for "required" rather than a simple boolean-like status.` |
| `content.assumption_review.status` | `warning` |
| `content.assumption_review.findings[0].issue` | `Pointer assumptions are explicit and traceable to the mlk_poly_add contract, but they adopt the strong freshness semantics of memory_no_alias/__CPROVER_is_fresh.` |
| `content.assumption_review.findings[1].issue` | `Arithmetic assumptions exactly mirror the source preconditions that every coefficient-wise sum fits in int16_t when evaluated in int32_t.` |
| `content.assertion_review.status` | `pass_with_minor_issues` |
| `content.assertion_review.findings[0].issue` | `Assertions compare post-state r against a genuine pre-state snapshot old_r plus current b, matching the source ensures relation and avoiding self-comparison.` |
| `content.assertion_review.findings[1].issue` | `The second assertion on (int32_t)r->coeffs[k] == expected is stronger-looking but becomes close to redundant once expected is assumed in INT16 range and the first assertion holds.` |
| `content.old_state_new_state_review.status` | `pass` |
| `content.old_state_new_state_review.findings[0].issue` | `Because mlk_poly_add mutates r in place, a pre-call snapshot is required; the harness takes memcpy(&old_r, r, sizeof(mlk_poly)) before the call.` |
| `content.old_state_new_state_review.findings[1].issue` | `The harness does not snapshot b, but b is only read and not targeted by assertions that require an old-state copy.` |
| `content.contract_review.status` | `pass_with_warning` |
| `content.contract_review.findings[0].issue` | `The harness is consistent with the existing native function contract in poly.h: freshness requirements, int16-safe sum preconditions, and post-state additive relation.` |
| `content.contract_review.findings[1].issue` | `No native function or loop contract instrumentation is being added, which matches the selected strategy and deterministic plan stating contract_mode none / apply_loop_contracts false.` |
| `content.verification_strategy_review.status` | `warning` |
| `content.verification_strategy_review.findings[0].issue` | `The selected strategy standard_cbmc_harness matches the artefact manifest and build-plan metadata.` |
| `content.verification_strategy_review.findings[1].issue` | `The build configuration names cbmc_function as "harness", but the actual harness symbol evidenced in C is different.` |
| `content.independence_review.status` | `pass_with_warning` |
| `content.independence_review.findings[0].issue` | `The supplied independence audit reports low similarity risk (combined similarity 0.1487) and no required human similarity review.` |
| `content.independence_review.findings[1].issue` | `Some structural similarities are unavoidable because the artefact must use exact repository identifiers, CBMC primitives, and an old-state snapshot for an in-place accumulator function.` |
| `content.scope_and_overclaim_review.status` | `pass` |
| `content.scope_and_overclaim_review.findings[0].issue` | `The artefact plan explicitly excludes claims about canonical modulo-q output, full ML-KEM correctness, FIPS compliance, cryptographic security, and caller-side proof of assumptions.` |
| `content.scope_and_overclaim_review.findings[1].issue` | `The selected property is framed as a local machine-level conditional check, which matches primary code evidence that mlk_poly_add performs unreduced addition and later callers apply reduction separately.` |
| `content.deterministic_reference_assessment.status` | `used_as_fallible_diagnostic_and_measured_build_metadata_only` |
| `content.deterministic_reference_assessment.warning` | `Deterministic material was used for measured facts about file existence/build-plan configuration and as a non-authoritative review hint. The main substantive assessment was checked against raw source/header/spec evidence. One deterministic claim prompting concern—the recommended human review gate—was downgraded because the primary evidence and independence audit do not themselves show a copying problem; the stronger primary issue is the harness entry-point mismatch in the measured build plan.` |
| `content.deterministic_reference_assessment.disagreements[0].primary_evidence_finding` | `The available primary evidence and the supplied independence audit do not show a similarity crisis or missing independence evidence requiring human review; instead, the concrete blocking problem is an execution-readiness mismatch between the configured CBMC entry symbol and the actual harness symbol.` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/logs/06_review_critic_status.json`

- Size: `19497` bytes
- SHA-256: `a56f246387845a29ef6bb57144fc97ac7c200137a011b80ca4b10b379e9a1564`

| Field | Recorded value |
|---|---|
| `llm_result.parsed_json.reviewed_artefacts.deterministic_recommended_gate` | `needs_human_review` |
| `llm_result.parsed_json.gate_recommendation` | `needs_revision_before_tool_execution` |
| `llm_result.parsed_json.blocking_issues[0].issue` | `The deterministic formal build plan selects CBMC entry function "harness", but the rendered C harness defines "void harness_mlk_poly_add_int16_safe_sum(void)" and no function named "harness" is evidenced.` |
| `llm_result.parsed_json.warnings[0].issue` | `The harness assumes memory_no_alias(r, sizeof(mlk_poly)) and memory_no_alias(b, sizeof(mlk_poly)), which maps to __CPROVER_is_fresh and is stronger than ordinary non-null/non-overlap reasoning.` |
| `llm_result.parsed_json.warnings[1].issue` | `The selected property is conditional on explicit per-coefficient INT16_MIN..INT16_MAX sum assumptions and does not derive those assumptions from real callers.` |
| `llm_result.parsed_json.minor_issues[0].issue` | `The second assertion largely follows from the first assertion plus the pre-assumed INT16 range, so it adds limited independent checking value.` |
| `llm_result.parsed_json.minor_issues[1].issue` | `The old_state_snapshot_plan field in the prior artefact plan uses a free-form value for "required" rather than a simple boolean-like status.` |
| `llm_result.parsed_json.assumption_review.status` | `warning` |
| `llm_result.parsed_json.assumption_review.findings[0].issue` | `Pointer assumptions are explicit and traceable to the mlk_poly_add contract, but they adopt the strong freshness semantics of memory_no_alias/__CPROVER_is_fresh.` |
| `llm_result.parsed_json.assumption_review.findings[1].issue` | `Arithmetic assumptions exactly mirror the source preconditions that every coefficient-wise sum fits in int16_t when evaluated in int32_t.` |
| `llm_result.parsed_json.assertion_review.status` | `pass_with_minor_issues` |
| `llm_result.parsed_json.assertion_review.findings[0].issue` | `Assertions compare post-state r against a genuine pre-state snapshot old_r plus current b, matching the source ensures relation and avoiding self-comparison.` |
| `llm_result.parsed_json.assertion_review.findings[1].issue` | `The second assertion on (int32_t)r->coeffs[k] == expected is stronger-looking but becomes close to redundant once expected is assumed in INT16 range and the first assertion holds.` |
| `llm_result.parsed_json.old_state_new_state_review.status` | `pass` |
| `llm_result.parsed_json.old_state_new_state_review.findings[0].issue` | `Because mlk_poly_add mutates r in place, a pre-call snapshot is required; the harness takes memcpy(&old_r, r, sizeof(mlk_poly)) before the call.` |
| `llm_result.parsed_json.old_state_new_state_review.findings[1].issue` | `The harness does not snapshot b, but b is only read and not targeted by assertions that require an old-state copy.` |
| `llm_result.parsed_json.contract_review.status` | `pass_with_warning` |
| `llm_result.parsed_json.contract_review.findings[0].issue` | `The harness is consistent with the existing native function contract in poly.h: freshness requirements, int16-safe sum preconditions, and post-state additive relation.` |
| `llm_result.parsed_json.contract_review.findings[1].issue` | `No native function or loop contract instrumentation is being added, which matches the selected strategy and deterministic plan stating contract_mode none / apply_loop_contracts false.` |
| `llm_result.parsed_json.verification_strategy_review.status` | `warning` |
| `llm_result.parsed_json.verification_strategy_review.findings[0].issue` | `The selected strategy standard_cbmc_harness matches the artefact manifest and build-plan metadata.` |
| `llm_result.parsed_json.verification_strategy_review.findings[1].issue` | `The build configuration names cbmc_function as "harness", but the actual harness symbol evidenced in C is different.` |
| `llm_result.parsed_json.independence_review.status` | `pass_with_warning` |
| `llm_result.parsed_json.independence_review.findings[0].issue` | `The supplied independence audit reports low similarity risk (combined similarity 0.1487) and no required human similarity review.` |
| `llm_result.parsed_json.independence_review.findings[1].issue` | `Some structural similarities are unavoidable because the artefact must use exact repository identifiers, CBMC primitives, and an old-state snapshot for an in-place accumulator function.` |
| `llm_result.parsed_json.scope_and_overclaim_review.status` | `pass` |
| `llm_result.parsed_json.scope_and_overclaim_review.findings[0].issue` | `The artefact plan explicitly excludes claims about canonical modulo-q output, full ML-KEM correctness, FIPS compliance, cryptographic security, and caller-side proof of assumptions.` |
| `llm_result.parsed_json.scope_and_overclaim_review.findings[1].issue` | `The selected property is framed as a local machine-level conditional check, which matches primary code evidence that mlk_poly_add performs unreduced addition and later callers apply reduction separately.` |
| `llm_result.parsed_json.deterministic_reference_assessment.status` | `used_as_fallible_diagnostic_and_measured_build_metadata_only` |
| `llm_result.parsed_json.deterministic_reference_assessment.warning` | `Deterministic material was used for measured facts about file existence/build-plan configuration and as a non-authoritative review hint. The main substantive assessment was checked against raw source/header/spec evidence. One deterministic claim prompting concern—the recommended human review gate—was downgraded because the primary evidence and independence audit do not themselves show a copying problem; the stronger primary issue is the harness entry-point mismatch in the measured build plan.` |
| `llm_result.parsed_json.deterministic_reference_assessment.disagreements[0].primary_evidence_finding` | `The available primary evidence and the supplied independence audit do not show a similarity crisis or missing independence evidence requiring human review; instead, the concrete blocking problem is an execution-readiness mismatch between the configured CBMC entry symbol and the actual harness symbol.` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stdout.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/prompt_package/06_review_critic_prompt.txt`

- Size: `7775` bytes
- SHA-256: `049beb5aec135505d719c0fb00f8ad19a9242622eb7dde805774f47d86d571a0`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/validation/05_property_campaign_review_validation.json`

- Size: `888` bytes
- SHA-256: `6b91f3e16d04741afacbb9411fd57b4c0b3d9352647abb2d55125435a23f7dc5`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.json`

- Size: `1964` bytes
- SHA-256: `e91845750c78f36366939fc83b723388f8fb8d41ec0213b689cbde4e7c526793`

| Field | Recorded value |
|---|---|
| `content.final_gate` | `needs_revision_before_tool_execution` |
| `content.tool_execution_allowed` | `False` |
| `content.reason` | `LLM critic requested revision before tool execution.` |
| `content.llm_gate_recommendation` | `needs_revision_before_tool_execution` |
| `content.deterministic_recommended_gate` | `needs_human_review` |
| `content.trust_boundary.gate_decision` | `conservative_workflow_control_decision` |
| `content.formal_build_plan.warning_count` | `0` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_001_poly_add_real_20260711/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.md`

- Size: `395` bytes
- SHA-256: `6e32fec9633f055b11b74669b5de0243df8bfe4eb2977627ef9d67c323216c1c`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_assumption_evidence_review.deterministic.csv`

- Size: `156` bytes
- SHA-256: `5913113bf0d4614f0d6564c5d7d53737e438bb6396b031eab18de9cecf47428c`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_critic_review.deterministic.json`

- Size: `5856` bytes
- SHA-256: `ac90eb78ea8a5b05cd59ea110b650466d91c48c1935375f87163a23bbca10477`

| Field | Recorded value |
|---|---|
| `content.warnings[0].severity` | `minor` |
| `content.warnings[0].blocks_tool_execution` | `False` |
| `content.blocking_issue_count` | `0` |
| `content.warning_count` | `1` |
| `content.recommended_gate` | `needs_human_review` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_review_issue_matrix.deterministic.csv`

- Size: `173` bytes
- SHA-256: `5aa44ae53b784855bea1dbf5c7a2bab7b684a09665dcb3a7c1ee56db7593e594`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/llm_authoritative/05_critic_review.json`

- Size: `19334` bytes
- SHA-256: `5afeb6b7d56c643a6a21011b774965d4ba083fdd530a562c28f98b86d40d8127`

| Field | Recorded value |
|---|---|
| `content.reviewed_artefacts.deterministic_recommended_gate` | `needs_human_review` |
| `content.gate_recommendation` | `human_review_required` |
| `content.warnings[0].issue` | `The artefact plan contains an unrecognized old-state snapshot requirement value `: partial` in `old_state_snapshot_plan.required`.` |
| `content.warnings[1].issue` | `The generated harness includes a post-call relation assertion using `pre_r[i] + b->coeffs[i]` even though the selected property is stated as bounds safety rather than functional correctness.` |
| `content.warnings[2].issue` | `The independence audit reports low similarity risk, but the harness necessarily shares many fixed identifiers and CBMC primitives with the repository’s contract style.` |
| `content.minor_issues[0].issue` | `The harness does not explicitly assert or model `memory_no_alias`, instead using `__CPROVER_assume(r != b)` on concrete local objects.` |
| `content.minor_issues[1].issue` | `The selected property is array-bounds safety, yet the harness also stores and uses a full `pre_r` snapshot.` |
| `content.minor_issues[2].issue` | `The harness includes `b` only through direct use after the call and does not separately assert frame preservation for `b`.` |
| `content.assumption_review.status` | `pass_with_caveats` |
| `content.assumption_review.findings[0].issue` | `The non-aliasing assumption is explicit in the source contract, but the harness uses a direct object-distinctness assumption rather than the repository macro `memory_no_alias`.` |
| `content.assumption_review.findings[1].issue` | `The overflow-free arithmetic assumptions in the source contract are not encoded as explicit harness assumptions.` |
| `content.assumption_review.findings[2].issue` | `The harness relies on concrete stack objects `r_obj` and `b_obj` being valid mlk_poly instances.` |
| `content.assertion_review.status` | `pass_with_caveats` |
| `content.assertion_review.findings[0].issue` | `The assertion `i < MLKEM_N` inside the loop is trivially true given the loop header.` |
| `content.assertion_review.findings[1].issue` | `The post-call equality assertion `r->coeffs[i] == (int16_t)(pre_r[i] + b->coeffs[i])` is a functional relation, not a pure bounds assertion.` |
| `content.assertion_review.findings[2].issue` | `No assertion explicitly checks that the loop body is the only source of mutation to `r` or that `b` remains unchanged.` |
| `content.old_state_new_state_review.status` | `pass` |
| `content.old_state_new_state_review.findings[0].issue` | `The harness snapshots `pre_r[i]` before the function call, which is consistent with the source’s `old(*r)` / `loop_entry(*r)` pattern.` |
| `content.old_state_new_state_review.findings[1].issue` | `There is no full-object pre-state snapshot for `r`, only a coefficient array snapshot.` |
| `content.old_state_new_state_review.findings[2].issue` | `The current selected property does not inherently require old-state reasoning.` |
| `content.contract_review.status` | `pass_with_caveats` |
| `content.contract_review.findings[0].issue` | `The artifact plan correctly keeps `contract_plan.enabled` false, avoiding accidental claim that native contracts are being enforced or replaced.` |
| `content.contract_review.findings[1].issue` | `The plan acknowledges the source contract’s non-aliasing and overflow preconditions but does not attempt to reproduce them as a native contract artifact.` |
| `content.contract_review.findings[2].issue` | `The source contract is strong enough to support a local functional check, but the chosen harness is still a harness, not a DFCC-style contract proof.` |
| `content.verification_strategy_review.status` | `pass` |
| `content.verification_strategy_review.findings[0].issue` | ``standard_cbmc_harness` is consistent with the selected property and with the source’s simple bounded loop over 256 coefficients.` |
| `content.verification_strategy_review.findings[1].issue` | `The plan explicitly avoids relational, analysis-only, and contract-enforcement modes.` |
| `content.verification_strategy_review.findings[2].issue` | `The harness targets one direct call to `mlk_poly_add` and does not require source instrumentation.` |
| `content.independence_review.status` | `pass_with_caveats` |
| `content.independence_review.findings[0].issue` | `The heuristic similarity score is low (`0.21`), and the audit marks copying risk as low.` |
| `content.independence_review.findings[1].issue` | `The harness necessarily shares required identifiers and CBMC primitives with any credible `mlk_poly_add` harness.` |
| `content.independence_review.findings[2].issue` | `The audit itself says human similarity review is not required, yet the broader stage instructions still ask to flag copying-risk situations.` |
| `content.scope_and_overclaim_review.status` | `pass` |
| `content.scope_and_overclaim_review.findings[0].issue` | `The artefact explicitly rejects full ML-KEM correctness, FIPS compliance, cryptographic security, and modular normalization claims.` |
| `content.scope_and_overclaim_review.findings[1].issue` | `The source-level distinction between FIPS modular semantics and the C routine’s plain `int16_t` addition is preserved in the plan.` |
| `content.scope_and_overclaim_review.findings[2].issue` | `The selected property is intentionally narrower than the source contract and narrower than the FIPS math semantics.` |
| `content.deterministic_reference_assessment.status` | `advisory_only_verified_against_primary_evidence` |
| `content.deterministic_reference_assessment.warning` | `Deterministic review material was useful as a locator and sanity check, but the final judgment here is based on the raw FIPS 203 text and the repository source/header evidence. Where deterministic material suggested a more permissive gate, I downgraded it because the artefact plan has a minor inconsistency and the harness is close enough to the template-like CBMC pattern to merit human confirmation.` |
| `content.deterministic_reference_assessment.disagreements[0].primary_evidence_finding` | `The manifest and audit are positive, but the plan contains an internally inconsistent old-state requirement value (`: partial`), and the harness includes an auxiliary post-state equality assertion that broadens the scope beyond the selected bounds property.` |
| `content.deterministic_reference_assessment.disagreements[1].primary_evidence_finding` | `That is broadly correct, but the artifact should not be treated as semantically closed because the same harness also encodes a post-state equality relation and does not explicitly encode the repository’s no-alias macro semantics.` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/logs/06_review_critic_status.json`

- Size: `23619` bytes
- SHA-256: `43f930db2d31bf81ba8be57fc7691539dfce29fd611cc2d94088f2fd88fa01ed`

| Field | Recorded value |
|---|---|
| `llm_result.parsed_json.reviewed_artefacts.deterministic_recommended_gate` | `needs_human_review` |
| `llm_result.parsed_json.gate_recommendation` | `human_review_required` |
| `llm_result.parsed_json.warnings[0].issue` | `The artefact plan contains an unrecognized old-state snapshot requirement value `: partial` in `old_state_snapshot_plan.required`.` |
| `llm_result.parsed_json.warnings[1].issue` | `The generated harness includes a post-call relation assertion using `pre_r[i] + b->coeffs[i]` even though the selected property is stated as bounds safety rather than functional correctness.` |
| `llm_result.parsed_json.warnings[2].issue` | `The independence audit reports low similarity risk, but the harness necessarily shares many fixed identifiers and CBMC primitives with the repository’s contract style.` |
| `llm_result.parsed_json.minor_issues[0].issue` | `The harness does not explicitly assert or model `memory_no_alias`, instead using `__CPROVER_assume(r != b)` on concrete local objects.` |
| `llm_result.parsed_json.minor_issues[1].issue` | `The selected property is array-bounds safety, yet the harness also stores and uses a full `pre_r` snapshot.` |
| `llm_result.parsed_json.minor_issues[2].issue` | `The harness includes `b` only through direct use after the call and does not separately assert frame preservation for `b`.` |
| `llm_result.parsed_json.assumption_review.status` | `pass_with_caveats` |
| `llm_result.parsed_json.assumption_review.findings[0].issue` | `The non-aliasing assumption is explicit in the source contract, but the harness uses a direct object-distinctness assumption rather than the repository macro `memory_no_alias`.` |
| `llm_result.parsed_json.assumption_review.findings[1].issue` | `The overflow-free arithmetic assumptions in the source contract are not encoded as explicit harness assumptions.` |
| `llm_result.parsed_json.assumption_review.findings[2].issue` | `The harness relies on concrete stack objects `r_obj` and `b_obj` being valid mlk_poly instances.` |
| `llm_result.parsed_json.assertion_review.status` | `pass_with_caveats` |
| `llm_result.parsed_json.assertion_review.findings[0].issue` | `The assertion `i < MLKEM_N` inside the loop is trivially true given the loop header.` |
| `llm_result.parsed_json.assertion_review.findings[1].issue` | `The post-call equality assertion `r->coeffs[i] == (int16_t)(pre_r[i] + b->coeffs[i])` is a functional relation, not a pure bounds assertion.` |
| `llm_result.parsed_json.assertion_review.findings[2].issue` | `No assertion explicitly checks that the loop body is the only source of mutation to `r` or that `b` remains unchanged.` |
| `llm_result.parsed_json.old_state_new_state_review.status` | `pass` |
| `llm_result.parsed_json.old_state_new_state_review.findings[0].issue` | `The harness snapshots `pre_r[i]` before the function call, which is consistent with the source’s `old(*r)` / `loop_entry(*r)` pattern.` |
| `llm_result.parsed_json.old_state_new_state_review.findings[1].issue` | `There is no full-object pre-state snapshot for `r`, only a coefficient array snapshot.` |
| `llm_result.parsed_json.old_state_new_state_review.findings[2].issue` | `The current selected property does not inherently require old-state reasoning.` |
| `llm_result.parsed_json.contract_review.status` | `pass_with_caveats` |
| `llm_result.parsed_json.contract_review.findings[0].issue` | `The artifact plan correctly keeps `contract_plan.enabled` false, avoiding accidental claim that native contracts are being enforced or replaced.` |
| `llm_result.parsed_json.contract_review.findings[1].issue` | `The plan acknowledges the source contract’s non-aliasing and overflow preconditions but does not attempt to reproduce them as a native contract artifact.` |
| `llm_result.parsed_json.contract_review.findings[2].issue` | `The source contract is strong enough to support a local functional check, but the chosen harness is still a harness, not a DFCC-style contract proof.` |
| `llm_result.parsed_json.verification_strategy_review.status` | `pass` |
| `llm_result.parsed_json.verification_strategy_review.findings[0].issue` | ``standard_cbmc_harness` is consistent with the selected property and with the source’s simple bounded loop over 256 coefficients.` |
| `llm_result.parsed_json.verification_strategy_review.findings[1].issue` | `The plan explicitly avoids relational, analysis-only, and contract-enforcement modes.` |
| `llm_result.parsed_json.verification_strategy_review.findings[2].issue` | `The harness targets one direct call to `mlk_poly_add` and does not require source instrumentation.` |
| `llm_result.parsed_json.independence_review.status` | `pass_with_caveats` |
| `llm_result.parsed_json.independence_review.findings[0].issue` | `The heuristic similarity score is low (`0.21`), and the audit marks copying risk as low.` |
| `llm_result.parsed_json.independence_review.findings[1].issue` | `The harness necessarily shares required identifiers and CBMC primitives with any credible `mlk_poly_add` harness.` |
| `llm_result.parsed_json.independence_review.findings[2].issue` | `The audit itself says human similarity review is not required, yet the broader stage instructions still ask to flag copying-risk situations.` |
| `llm_result.parsed_json.scope_and_overclaim_review.status` | `pass` |
| `llm_result.parsed_json.scope_and_overclaim_review.findings[0].issue` | `The artefact explicitly rejects full ML-KEM correctness, FIPS compliance, cryptographic security, and modular normalization claims.` |
| `llm_result.parsed_json.scope_and_overclaim_review.findings[1].issue` | `The source-level distinction between FIPS modular semantics and the C routine’s plain `int16_t` addition is preserved in the plan.` |
| `llm_result.parsed_json.scope_and_overclaim_review.findings[2].issue` | `The selected property is intentionally narrower than the source contract and narrower than the FIPS math semantics.` |
| `llm_result.parsed_json.deterministic_reference_assessment.status` | `advisory_only_verified_against_primary_evidence` |
| `llm_result.parsed_json.deterministic_reference_assessment.warning` | `Deterministic review material was useful as a locator and sanity check, but the final judgment here is based on the raw FIPS 203 text and the repository source/header evidence. Where deterministic material suggested a more permissive gate, I downgraded it because the artefact plan has a minor inconsistency and the harness is close enough to the template-like CBMC pattern to merit human confirmation.` |
| `llm_result.parsed_json.deterministic_reference_assessment.disagreements[0].primary_evidence_finding` | `The manifest and audit are positive, but the plan contains an internally inconsistent old-state requirement value (`: partial`), and the harness includes an auxiliary post-state equality assertion that broadens the scope beyond the selected bounds property.` |
| `llm_result.parsed_json.deterministic_reference_assessment.disagreements[1].primary_evidence_finding` | `That is broadly correct, but the artifact should not be treated as semantically closed because the same harness also encodes a post-state equality relation and does not explicitly encode the repository’s no-alias macro semantics.` |
| `llm_result.validation.exact_input_summary.input_text_block_count` | `1` |
| `llm_result.validation.provider_usage.output_tokens_details.reasoning_tokens` | `0` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stdout.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/prompt_package/06_review_critic_prompt.txt`

- Size: `7775` bytes
- SHA-256: `049beb5aec135505d719c0fb00f8ad19a9242622eb7dde805774f47d86d571a0`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/validation/05_property_campaign_review_validation.json`

- Size: `888` bytes
- SHA-256: `17ebc44db3105f7fb0bf4d660ed912359a341c0d3e64599f12580a08d52aef78`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.json`

- Size: `2045` bytes
- SHA-256: `1c53bff82ff39a7ba8d70db8f5a65e57508d2b64978cf050b1767ad52cec0ad4`

| Field | Recorded value |
|---|---|
| `content.final_gate` | `human_review_required` |
| `content.tool_execution_allowed` | `False` |
| `content.reason` | `At least one review path requires human review.` |
| `content.llm_gate_recommendation` | `human_review_required` |
| `content.deterministic_recommended_gate` | `needs_human_review` |
| `content.trust_boundary.gate_decision` | `conservative_workflow_control_decision` |
| `content.formal_build_plan.warning_count` | `0` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/runs/run_poly_add_scoped_fullfips_gpt54mini_none_20260711_080559/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.md`

- Size: `360` bytes
- SHA-256: `c7ccacf78ec298248a2f05cbd2f58e8fbec0224e934a7793691e0b4acf823bb6`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v3-evaluated-llm-integrated-workflow/tests/verify_critic_tool_readiness_policy.py`

- Size: `2954` bytes
- SHA-256: `72f2275f805f550cfeb846ec1748c4519d03a08c7a79214129f685586758b5bc`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/.patch_backups/agent5_structured_outputs_integrated_20260715_v1_20260715T062707Z/agents/review_critic_agent.py`

- Size: `84608` bytes
- SHA-256: `e4ba628b1c8850acde2b9f346c74a34dbe433618154d7db345f8347750d00265`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/.patch_validation/agent5_structured_outputs_integrated_20260715_v1_20260715T062707Z/full_regressions/verify_critic_tool_readiness_policy.py.stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/.patch_validation/agent5_structured_outputs_integrated_20260715_v1_20260715T062707Z/full_regressions/verify_critic_tool_readiness_policy.py.stdout.txt`

- Size: `46` bytes
- SHA-256: `ef174321bbeb8b2c4f3b770c4f0043e821730683bce8a14777e7b7efaa22fb05`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/agents/review_critic_agent.py`

- Size: `84635` bytes
- SHA-256: `33f02ce1877af196960a38aaf3ba967c34016d0c9f7830a2b508ffaf47a5868c`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/release_evidence/local_regression_logs/verify_critic_tool_readiness_policy.py.stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/release_evidence/local_regression_logs/verify_critic_tool_readiness_policy.py.stdout.txt`

- Size: `46` bytes
- SHA-256: `ef174321bbeb8b2c4f3b770c4f0043e821730683bce8a14777e7b7efaa22fb05`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/reports/FINAL_TRUST_CHAIN_ACCEPTANCE_20260715T031522Z/regressions/verify_critic_tool_readiness_policy.py.stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/reports/FINAL_TRUST_CHAIN_ACCEPTANCE_20260715T031522Z/regressions/verify_critic_tool_readiness_policy.py.stdout.txt`

- Size: `46` bytes
- SHA-256: `ef174321bbeb8b2c4f3b770c4f0043e821730683bce8a14777e7b7efaa22fb05`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/reports/FINAL_TRUST_CHAIN_ACCEPTANCE_20260715T035643Z/regressions/verify_critic_tool_readiness_policy.py.stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/reports/FINAL_TRUST_CHAIN_ACCEPTANCE_20260715T035643Z/regressions/verify_critic_tool_readiness_policy.py.stdout.txt`

- Size: `46` bytes
- SHA-256: `ef174321bbeb8b2c4f3b770c4f0043e821730683bce8a14777e7b7efaa22fb05`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/reports/regressions_after_final_relocation/verify_critic_tool_readiness_policy.py.stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/reports/regressions_after_final_relocation/verify_critic_tool_readiness_policy.py.stdout.txt`

- Size: `46` bytes
- SHA-256: `ef174321bbeb8b2c4f3b770c4f0043e821730683bce8a14777e7b7efaa22fb05`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/reports/regressions_after_underscore_rename/verify_critic_tool_readiness_policy.py.stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/reports/regressions_after_underscore_rename/verify_critic_tool_readiness_policy.py.stdout.txt`

- Size: `46` bytes
- SHA-256: `ef174321bbeb8b2c4f3b770c4f0043e821730683bce8a14777e7b7efaa22fb05`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_assumption_evidence_review.deterministic.csv`

- Size: `7` bytes
- SHA-256: `24526432f951ea86e61db71a2c7df058d690643d1792c6525c784823544d3c03`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_critic_review.deterministic.json`

- Size: `7325` bytes
- SHA-256: `8c7f96f0dd1e76fa50af45ae9d3217fcf3d5eb1d4e44e43214dd02067e1b651e`

| Field | Recorded value |
|---|---|
| `content.semantic_tool_readiness_gate.recommended_gate` | `approved_for_tool_execution` |
| `content.semantic_tool_readiness_gate.blocking_issue_count` | `0` |
| `content.semantic_tool_readiness_gate.warning_count` | `0` |
| `content.warnings[0].severity` | `minor` |
| `content.warnings[0].blocks_tool_execution` | `False` |
| `content.blocking_issue_count` | `0` |
| `content.warning_count` | `1` |
| `content.recommended_gate` | `approved_for_tool_execution` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_review_issue_matrix.deterministic.csv`

- Size: `173` bytes
- SHA-256: `5aa44ae53b784855bea1dbf5c7a2bab7b684a09665dcb3a7c1ee56db7593e594`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/llm_authoritative/05_critic_review.json`

- Size: `9241` bytes
- SHA-256: `8116ec530d3b57d18238a34d55ebf26ef139a92912d57b2fe2cde2a952d57cc9`

| Field | Recorded value |
|---|---|
| `content.gate_recommendation` | `approved_for_tool_execution` |
| `content.warnings[0].issue` | `The harness models a distinct local-object case and does not exercise overlapping r/b aliasing.` |
| `content.warnings[1].issue` | `The contract plan has no ensures clauses and no explicit alias policy.` |
| `content.minor_issues[0].issue` | `The assertion checks that b is unchanged rather than directly asserting a post-state relation on r.` |
| `content.assumption_review.status` | `pass_with_warning` |
| `content.assumption_review.findings[0].issue` | `Assumption A01 relies on two concrete local mlk_poly objects and a pre-call snapshot of b, without introducing NULL or fresh-pointer modeling.` |
| `content.assertion_review.status` | `pass` |
| `content.assertion_review.findings[0].issue` | `C01 is non-trivial because b is havoced before the call and then compared against a pre-call snapshot after the target invocation.` |
| `content.old_state_new_state_review.status` | `pass` |
| `content.old_state_new_state_review.findings[0].issue` | `The harness snapshots the full source object b before the call and reuses that snapshot after the call.` |
| `content.contract_review.status` | `pass_with_warning` |
| `content.contract_review.findings[0].issue` | `The function contract’s requires and assigns clauses match the visible single-store body and the narrow frame property.` |
| `content.contract_review.findings[1].issue` | `The contract does not encode alias separation or any semantic postcondition beyond the frame condition.` |
| `content.verification_strategy_review.status` | `pass` |
| `content.verification_strategy_review.findings[0].issue` | `native_function_contract is a suitable strategy for a write-footprint/frame property on a small in-place primitive.` |
| `content.independence_review.status` | `pass` |
| `content.independence_review.findings[0].issue` | `The heuristic similarity audit reports zero reference-file overlap and low similarity risk.` |
| `content.scope_and_overclaim_review.status` | `pass_with_warning` |
| `content.scope_and_overclaim_review.findings[0].issue` | `The artefact deliberately avoids claims about modulo-q normalization, overflow safety, FIPS compliance, cryptographic security, and full ML-KEM correctness.` |
| `content.deterministic_reference_assessment.status` | `used_for_readiness_only` |
| `content.deterministic_reference_assessment.warning` | `The recorded build-plan/validation evidence supports handoff readiness and low similarity risk, but it does not establish the property or any CBMC outcome.` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/logs/06_review_critic_status.json`

- Size: `13490` bytes
- SHA-256: `67b68cc84c83d3e175ae2f2cc4596fb09679734b251e8e23d6798658f1ad9d6c`

| Field | Recorded value |
|---|---|
| `llm_result.parsed_json.gate_recommendation` | `approved_for_tool_execution` |
| `llm_result.parsed_json.warnings[0].issue` | `The harness models a distinct local-object case and does not exercise overlapping r/b aliasing.` |
| `llm_result.parsed_json.warnings[1].issue` | `The contract plan has no ensures clauses and no explicit alias policy.` |
| `llm_result.parsed_json.minor_issues[0].issue` | `The assertion checks that b is unchanged rather than directly asserting a post-state relation on r.` |
| `llm_result.parsed_json.assumption_review.status` | `pass_with_warning` |
| `llm_result.parsed_json.assumption_review.findings[0].issue` | `Assumption A01 relies on two concrete local mlk_poly objects and a pre-call snapshot of b, without introducing NULL or fresh-pointer modeling.` |
| `llm_result.parsed_json.assertion_review.status` | `pass` |
| `llm_result.parsed_json.assertion_review.findings[0].issue` | `C01 is non-trivial because b is havoced before the call and then compared against a pre-call snapshot after the target invocation.` |
| `llm_result.parsed_json.old_state_new_state_review.status` | `pass` |
| `llm_result.parsed_json.old_state_new_state_review.findings[0].issue` | `The harness snapshots the full source object b before the call and reuses that snapshot after the call.` |
| `llm_result.parsed_json.contract_review.status` | `pass_with_warning` |
| `llm_result.parsed_json.contract_review.findings[0].issue` | `The function contract’s requires and assigns clauses match the visible single-store body and the narrow frame property.` |
| `llm_result.parsed_json.contract_review.findings[1].issue` | `The contract does not encode alias separation or any semantic postcondition beyond the frame condition.` |
| `llm_result.parsed_json.verification_strategy_review.status` | `pass` |
| `llm_result.parsed_json.verification_strategy_review.findings[0].issue` | `native_function_contract is a suitable strategy for a write-footprint/frame property on a small in-place primitive.` |
| `llm_result.parsed_json.independence_review.status` | `pass` |
| `llm_result.parsed_json.independence_review.findings[0].issue` | `The heuristic similarity audit reports zero reference-file overlap and low similarity risk.` |
| `llm_result.parsed_json.scope_and_overclaim_review.status` | `pass_with_warning` |
| `llm_result.parsed_json.scope_and_overclaim_review.findings[0].issue` | `The artefact deliberately avoids claims about modulo-q normalization, overflow safety, FIPS compliance, cryptographic security, and full ML-KEM correctness.` |
| `llm_result.parsed_json.deterministic_reference_assessment.status` | `used_for_readiness_only` |
| `llm_result.parsed_json.deterministic_reference_assessment.warning` | `The recorded build-plan/validation evidence supports handoff readiness and low similarity risk, but it does not establish the property or any CBMC outcome.` |
| `llm_result.validation.exact_input_summary.input_text_block_count` | `1` |
| `llm_result.validation.provider_usage.output_tokens_details.reasoning_tokens` | `11912` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stdout.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/prompt_package/06_review_critic_prompt.txt`

- Size: `7853` bytes
- SHA-256: `6952ebd7b63b2d7c6ecb5eb054f810054207a592ba08bb2030775aba674023a6`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/validation/05_property_campaign_review_validation.json`

- Size: `1195` bytes
- SHA-256: `3ff74964a99de4070ee30ebec6c444750eb977cde4f2a6c74c5094c549228a16`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.json`

- Size: `2042` bytes
- SHA-256: `b02ec0d74fb5cfc2f9845230935f863c2a007045beb6b2aa2f742cee9cfb9c57`

| Field | Recorded value |
|---|---|
| `content.final_gate` | `approved_for_tool_execution` |
| `content.tool_execution_allowed` | `True` |
| `content.reason` | `No blocking tool-readiness issue was found. Non-blocking warnings and human-review caveats remain recorded for post-tool review.` |
| `content.llm_gate_recommendation` | `approved_for_tool_execution` |
| `content.deterministic_recommended_gate` | `approved_for_tool_execution` |
| `content.trust_boundary.gate_decision` | `conservative_workflow_control_decision` |
| `content.formal_build_plan.warning_count` | `0` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.md`

- Size: `461` bytes
- SHA-256: `c110c0fae1bce21f1c83d2b9b763248ce5f4f710820c309bda07d322a050de3c`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/07_tool_execution/iterations/iteration_00/tool_inputs/06_critic_gate_decision_input.json`

- Size: `600` bytes
- SHA-256: `985cf0ce7fe5cfc1529c7293f193906883e3565d3c86fd96fe849fbadb3f1295`

| Field | Recorded value |
|---|---|
| `gate_path` | `/home/<user>/THESIS-2026/thesis-pipeline/runs/run_001_mlk_poly_add_open_discovery_20260714/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.json` |
| `gate_available` | `True` |
| `final_gate` | `approved_for_tool_execution` |
| `tool_execution_allowed` | `True` |
| `gate_reason` | `No blocking tool-readiness issue was found. Non-blocking warnings and human-review caveats remain recorded for post-tool review.` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_assumption_evidence_review.deterministic.csv`

- Size: `198` bytes
- SHA-256: `1601f6696a2109a33294312bfe352dc14b42cec91ee35d591ecf9cc4bd3bd395`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_critic_review.deterministic.json`

- Size: `14002` bytes
- SHA-256: `cae631156da811b934751cfa0add926bc96df91a353b94f3c1969e8543c606da`

| Field | Recorded value |
|---|---|
| `content.semantic_tool_readiness_gate.recommended_gate` | `blocked` |
| `content.semantic_tool_readiness_gate.issues[0].issue_id` | `target_call_missing_or_irrelevant` |
| `content.semantic_tool_readiness_gate.issues[0].severity` | `critical` |
| `content.semantic_tool_readiness_gate.issues[0].blocks_tool_execution` | `True` |
| `content.semantic_tool_readiness_gate.issues[1].issue_id` | `selected_property_unreachable` |
| `content.semantic_tool_readiness_gate.issues[1].severity` | `critical` |
| `content.semantic_tool_readiness_gate.issues[1].blocks_tool_execution` | `True` |
| `content.semantic_tool_readiness_gate.blocking_issues[0].issue_id` | `target_call_missing_or_irrelevant` |
| `content.semantic_tool_readiness_gate.blocking_issues[0].severity` | `critical` |
| `content.semantic_tool_readiness_gate.blocking_issues[0].blocks_tool_execution` | `True` |
| `content.semantic_tool_readiness_gate.blocking_issues[1].issue_id` | `selected_property_unreachable` |
| `content.semantic_tool_readiness_gate.blocking_issues[1].severity` | `critical` |
| `content.semantic_tool_readiness_gate.blocking_issues[1].blocks_tool_execution` | `True` |
| `content.semantic_tool_readiness_gate.hard_blockers[0].issue_id` | `target_call_missing_or_irrelevant` |
| `content.semantic_tool_readiness_gate.hard_blockers[0].severity` | `critical` |
| `content.semantic_tool_readiness_gate.hard_blockers[0].blocks_tool_execution` | `True` |
| `content.semantic_tool_readiness_gate.hard_blockers[1].issue_id` | `selected_property_unreachable` |
| `content.semantic_tool_readiness_gate.hard_blockers[1].severity` | `critical` |
| `content.semantic_tool_readiness_gate.hard_blockers[1].blocks_tool_execution` | `True` |
| `content.semantic_tool_readiness_gate.blocking_issue_count` | `2` |
| `content.semantic_tool_readiness_gate.warning_count` | `0` |
| `content.issues[0].severity` | `critical` |
| `content.issues[0].blocks_tool_execution` | `True` |
| `content.issues[1].severity` | `critical` |
| `content.issues[1].blocks_tool_execution` | `True` |
| `content.issues[2].severity` | `critical` |
| `content.issues[2].blocks_tool_execution` | `True` |
| `content.warnings[0].severity` | `minor` |
| `content.warnings[0].blocks_tool_execution` | `False` |
| `content.blocking_issue_count` | `3` |
| `content.warning_count` | `1` |
| `content.recommended_gate` | `blocked` |
| `content.frontend_parse_and_build_readiness.blocks_tool_execution` | `True` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/deterministic_reference/05_review_issue_matrix.deterministic.csv`

- Size: `628` bytes
- SHA-256: `f19988797e146b8aa745ebed678aa10407862804d8ef478346430ca128bb417d`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/llm_authoritative/05_critic_review.json`

- Size: `12669` bytes
- SHA-256: `11a56b80e8a41a026e17c7d0da538a78ff8a8f280a6ec99a33ae40ed8d99e59d`

| Field | Recorded value |
|---|---|
| `content.gate_recommendation` | `needs_revision_before_tool_execution` |
| `content.warnings[0].issue` | `Traceability metadata is incomplete: the readiness record reports claim_markers_complete=false and fallback_conditions_satisfied=false, while the rendered harness body only shows the witness sentinel and the target call marker.` |
| `content.warnings[1].issue` | `The selected property is carried only indirectly by the rendered harness body; the actual footprint claim depends on the external generated contract header and DFCC instrumentation.` |
| `content.warnings[2].issue` | `The A01 disjointness assumption is redundant in the current harness shape because witness_obj is a separate local object that is not passed to mlk_poly_add.` |
| `content.minor_issues[0].issue` | `The harness does not snapshot r for old-state/new-state comparison because the selected property is a frame claim rather than a functional postcondition.` |
| `content.minor_issues[1].issue` | `The harness uses local distinct objects, so it does not exercise alias-sensitive corner cases such as self-aliasing between destination and source.` |
| `content.assumption_review.status` | `acceptable_with_redundancy` |
| `content.assumption_review.findings[0].issue` | `A01 is justified as a disjoint-witness condition, but it is effectively tautological for the current local harness because witness_obj, r_obj, and b_obj are distinct automatic objects.` |
| `content.assertion_review.status` | `supported_but_indirect` |
| `content.assertion_review.findings[0].issue` | `C01 is non-tautological because witness_obj is nondeterministically initialized and copied into witness_before before the call, so a stray write to that unrelated object would be observable.` |
| `content.old_state_new_state_review.status` | `adequate_for_selected_frame_claim` |
| `content.old_state_new_state_review.findings[0].issue` | `The harness snapshots only witness_obj rather than the mutated destination, which is sufficient for the chosen frame sentinel but not for a functional old/new-state relation on r.` |
| `content.contract_review.status` | `valid_with_traceability_gap` |
| `content.contract_review.findings[0].issue` | `The planned function contract is well aligned with the local write footprint: the assigns clause is restricted to r->coeffs[0 .. MLKEM_N - 1], and the build-plan record marks the contract path valid.` |
| `content.contract_review.findings[1].issue` | `The readiness record still flags incomplete marker coverage and incomplete fallback conditions even though the contract path is valid.` |
| `content.verification_strategy_review.status` | `aligned_with_narrow_frame_property` |
| `content.verification_strategy_review.findings[0].issue` | `native_function_contract is an appropriate strategy for a local footprint claim about writes confined to the destination coefficient array.` |
| `content.verification_strategy_review.findings[1].issue` | `The selected property intentionally avoids modular-q correctness and whole-scheme reasoning.` |
| `content.independence_review.status` | `low_similarity_risk` |
| `content.independence_review.findings[0].issue` | `The similarity audit reports reference_file_count=0, max_similarity_score=0.0, copying_risk=low_similarity_risk, and similarity_review_required=false.` |
| `content.independence_review.findings[1].issue` | `The unavoidable overlaps are mostly fixed identifiers and standard CBMC primitives required by the target function and verification style.` |
| `content.scope_and_overclaim_review.status` | `appropriately_narrow` |
| `content.scope_and_overclaim_review.findings[0].issue` | `The artefact explicitly avoids modular-q correctness, FIPS compliance, cryptographic security, and whole-scheme ML-KEM claims.` |
| `content.scope_and_overclaim_review.findings[1].issue` | `The visible source body does not show explicit q-reduction, and the artefact does not try to infer it into a stronger semantic claim.` |
| `content.deterministic_reference_assessment.status` | `used_as_readiness_hint_with_caveats` |
| `content.deterministic_reference_assessment.warning` | `The deterministic build-plan record validates the contract path and target-call presence, but it also logs claim_markers_complete=false and fallback_conditions_satisfied=false; I treated that as a readiness hint, not as proof of a clean handoff.` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/logs/06_review_critic_status.json`

- Size: `17045` bytes
- SHA-256: `9691ecd17b721288ad9083dc5ce64e3384e78ca99c31917d1d6a4a286bc47d54`

| Field | Recorded value |
|---|---|
| `llm_result.parsed_json.gate_recommendation` | `needs_revision_before_tool_execution` |
| `llm_result.parsed_json.warnings[0].issue` | `Traceability metadata is incomplete: the readiness record reports claim_markers_complete=false and fallback_conditions_satisfied=false, while the rendered harness body only shows the witness sentinel and the target call marker.` |
| `llm_result.parsed_json.warnings[1].issue` | `The selected property is carried only indirectly by the rendered harness body; the actual footprint claim depends on the external generated contract header and DFCC instrumentation.` |
| `llm_result.parsed_json.warnings[2].issue` | `The A01 disjointness assumption is redundant in the current harness shape because witness_obj is a separate local object that is not passed to mlk_poly_add.` |
| `llm_result.parsed_json.minor_issues[0].issue` | `The harness does not snapshot r for old-state/new-state comparison because the selected property is a frame claim rather than a functional postcondition.` |
| `llm_result.parsed_json.minor_issues[1].issue` | `The harness uses local distinct objects, so it does not exercise alias-sensitive corner cases such as self-aliasing between destination and source.` |
| `llm_result.parsed_json.assumption_review.status` | `acceptable_with_redundancy` |
| `llm_result.parsed_json.assumption_review.findings[0].issue` | `A01 is justified as a disjoint-witness condition, but it is effectively tautological for the current local harness because witness_obj, r_obj, and b_obj are distinct automatic objects.` |
| `llm_result.parsed_json.assertion_review.status` | `supported_but_indirect` |
| `llm_result.parsed_json.assertion_review.findings[0].issue` | `C01 is non-tautological because witness_obj is nondeterministically initialized and copied into witness_before before the call, so a stray write to that unrelated object would be observable.` |
| `llm_result.parsed_json.old_state_new_state_review.status` | `adequate_for_selected_frame_claim` |
| `llm_result.parsed_json.old_state_new_state_review.findings[0].issue` | `The harness snapshots only witness_obj rather than the mutated destination, which is sufficient for the chosen frame sentinel but not for a functional old/new-state relation on r.` |
| `llm_result.parsed_json.contract_review.status` | `valid_with_traceability_gap` |
| `llm_result.parsed_json.contract_review.findings[0].issue` | `The planned function contract is well aligned with the local write footprint: the assigns clause is restricted to r->coeffs[0 .. MLKEM_N - 1], and the build-plan record marks the contract path valid.` |
| `llm_result.parsed_json.contract_review.findings[1].issue` | `The readiness record still flags incomplete marker coverage and incomplete fallback conditions even though the contract path is valid.` |
| `llm_result.parsed_json.verification_strategy_review.status` | `aligned_with_narrow_frame_property` |
| `llm_result.parsed_json.verification_strategy_review.findings[0].issue` | `native_function_contract is an appropriate strategy for a local footprint claim about writes confined to the destination coefficient array.` |
| `llm_result.parsed_json.verification_strategy_review.findings[1].issue` | `The selected property intentionally avoids modular-q correctness and whole-scheme reasoning.` |
| `llm_result.parsed_json.independence_review.status` | `low_similarity_risk` |
| `llm_result.parsed_json.independence_review.findings[0].issue` | `The similarity audit reports reference_file_count=0, max_similarity_score=0.0, copying_risk=low_similarity_risk, and similarity_review_required=false.` |
| `llm_result.parsed_json.independence_review.findings[1].issue` | `The unavoidable overlaps are mostly fixed identifiers and standard CBMC primitives required by the target function and verification style.` |
| `llm_result.parsed_json.scope_and_overclaim_review.status` | `appropriately_narrow` |
| `llm_result.parsed_json.scope_and_overclaim_review.findings[0].issue` | `The artefact explicitly avoids modular-q correctness, FIPS compliance, cryptographic security, and whole-scheme ML-KEM claims.` |
| `llm_result.parsed_json.scope_and_overclaim_review.findings[1].issue` | `The visible source body does not show explicit q-reduction, and the artefact does not try to infer it into a stronger semantic claim.` |
| `llm_result.parsed_json.deterministic_reference_assessment.status` | `used_as_readiness_hint_with_caveats` |
| `llm_result.parsed_json.deterministic_reference_assessment.warning` | `The deterministic build-plan record validates the contract path and target-call presence, but it also logs claim_markers_complete=false and fallback_conditions_satisfied=false; I treated that as a readiness hint, not as proof of a clean handoff.` |
| `llm_result.validation.exact_input_summary.input_text_block_count` | `1` |
| `llm_result.validation.provider_usage.output_tokens_details.reasoning_tokens` | `21103` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stderr.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/process_logs/critic_review_stdout.txt`

- Size: `0` bytes
- SHA-256: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/prompt_package/06_review_critic_prompt.txt`

- Size: `7884` bytes
- SHA-256: `7d5098e7f6df4d4ed410d01aba9ea7881684b5426bdca29cd036d7d842d3ae5f`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/validation/05_property_campaign_review_validation.json`

- Size: `1195` bytes
- SHA-256: `13469d4f7d24b76b8ee509307e7c0cf30ab38df1be4cdc4253bbb327dee4da83`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.json`

- Size: `3550` bytes
- SHA-256: `e19cc957344c22777e716dcbfbda5d8c0830f4ab15387a315d665a5ecc7b4488`

| Field | Recorded value |
|---|---|
| `content.final_gate` | `blocked_hard_tool_readiness_defect` |
| `content.tool_execution_allowed` | `False` |
| `content.reason` | `The reviewed artefact bundle failed route-specific frontend parse/build readiness.` |
| `content.llm_gate_recommendation` | `needs_revision_before_tool_execution` |
| `content.deterministic_recommended_gate` | `blocked` |
| `content.blocking_diagnostics[0].severity` | `critical` |
| `content.blocking_diagnostics[0].blocks_tool_execution` | `True` |
| `content.blocking_diagnostics[1].severity` | `critical` |
| `content.blocking_diagnostics[1].blocks_tool_execution` | `True` |
| `content.blocking_diagnostics[2].severity` | `critical` |
| `content.blocking_diagnostics[2].blocks_tool_execution` | `True` |
| `content.trust_boundary.gate_decision` | `conservative_workflow_control_decision` |
| `content.formal_build_plan.warning_count` | `0` |

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/runs/run_002_mlk_poly_add_open_discovery_repaired_20260714/stages/06_review_critic/iterations/iteration_00/validation/05_review_gate_decision.md`

- Size: `412` bytes
- SHA-256: `5049df1c45b79f24a8c0e837fa1012d2bdb4b4ac95c406dc61820bb4e1528c4b`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/tests/fixtures/run002_contract_and_traceability_failure/review_gate.json.fixture`

- Size: `3550` bytes
- SHA-256: `e19cc957344c22777e716dcbfbda5d8c0830f4ab15387a315d665a5ecc7b4488`

## `historical-workflows/reproducible-ai-assisted-cbmc-workflows/v4-evaluated-second-generation-llm-integrated-workflow/tests/verify_critic_tool_readiness_policy.py`

- Size: `3106` bytes
- SHA-256: `856bded3be267a29e56004ec52bfb8324cfec7eef74367778464b6b78fdcac9e`

