# 08 Repair / Refinement Report

- **Agent:** `repair_refinement_agent` v2.0.0
- **Target function:** `mlk_poly_add`
- **Iteration:** `0`
- **Status:** `repaired_candidate_generated`
- **Source artifact:** `04_generated_harness.c`
- **Repaired artifact:** `08_repaired_harness.c`
- **Tool execution recommended:** `True`
- **Human review required:** `True`

## Research Guardrail

The repaired harness is a candidate formal-verification artifact only. It must be checked by CBMC/formal tools and reviewed by a human. It is not a proof of full ML-KEM correctness or full implementation correctness.

## Failure Modes Seen

- `pointer_validity_failure`
- `critic_blocked`
- `timeout`
- `pointer_validity`
- `signed_overflow`
- `overflow`
- `unwinding`
- `assertion_failure`
- `assumption_issue`
- `separate_overflow_from_functional_assertion`
- `review_loop_bound_and_object_size`
- `fix_pointer_object_setup`
- `adjust_unwind_configuration`
- `repair_harness_assumptions_and_assertions`

## Repair Actions

### R001 — traceability
- **Applied:** yes
- **Confidence:** high
- **Description:** Add repair provenance and research guardrail banner to the harness.
- **Reason:** Reproducibility requires repaired artifacts to be clearly marked.
- **Evidence source stage:** `agent9_v2`
- **Human review note:** Banner does not affect verification semantics.

### R_INC_LIMITS_H — cbmc_compatibility
- **Applied:** yes
- **Confidence:** high
- **Description:** Add missing include <limits.h>.
- **Reason:** Harness uses assertions, fixed-width integer casts, or INT16_MIN/INT16_MAX-style guards.
- **Evidence source stage:** `agent9_v2`

### R002 — cbmc_compatibility
- **Applied:** no
- **Confidence:** high
- **Description:** Add external declarations for CBMC nondeterministic input functions used by the harness.
- **Reason:** CBMC harnesses commonly use nondet_* symbols; explicit declarations reduce type/parsing problems.
- **Evidence source stage:** `agent9_v2`

### R003 — assumption_transparency
- **Applied:** yes
- **Confidence:** high
- **Description:** Annotate CPROVER assumptions as candidate preconditions requiring spec/code review.
- **Reason:** Generated assumptions can be too strong or unsupported; comments make the limitation explicit.
- **Evidence source stage:** `agent6_agent8_agent9_v2`
- **Human review note:** Every generated assumption must be checked against selected specification and implementation context.

### R003B — assertion_transparency
- **Applied:** yes
- **Confidence:** high
- **Description:** Annotate assertions as candidate assertions requiring property/spec review.
- **Reason:** Candidate assertions need traceability to Agent 4 properties and Agent 5 assertion plan.
- **Evidence source stage:** `agent5_agent6_agent8_agent9_v2`
- **Human review note:** Every assertion must be checked against the selected candidate property and spec/code evidence.

### R004 — assertion_rewrite
- **Applied:** no
- **Confidence:** low
- **Description:** Rewrite simple coefficient functional assertion with int32_t casts to reduce assertion-side overflow noise.
- **Reason:** CBMC failures involving signed overflow/equality assertions often come from expression semantics or over-broad input ranges.
- **Evidence source stage:** `agent7_agent8_agent9_v2`
- **Human review note:** This preserves the intended equality check shape but does not prove the specification-level property by itself.

### R006 — tool_command_recommendation
- **Applied:** no
- **Confidence:** medium
- **Description:** Update or add CBMC unwinding recommendation in the artifact manifest.
- **Reason:** Loop-based harnesses need appropriate unwinding and unwinding assertions.
- **Evidence source stage:** `agent3_agent7_agent8_agent9_v2`

## Warnings

- Agent 7/critic gate indicates tool execution was blocked. Review Agent 6 issues before relying on repair.
- Critic/counterexample analysis mentions unsupported/too-strong assumptions. The repaired harness remains candidate-only.

## Limitations

- No additional limitation recorded beyond mandatory human/formal-tool review.

## New v2 Evidence Files

- `08_repair_decision_log.json`
- `08_repair_traceability.json`
- `08_assumption_changes.csv`
- `08_assertion_changes.csv`
- `08_repair_safety_review.json`
- `08_repair_input_snapshot.json`
- `08_repair_manifest_update.json`
- `08_repair_action_plan_consumed.json`

## Next Step

Run Formal Tool Execution Agent on 08_repaired_harness.c, then re-run counterexample analysis if CBMC fails.
