# Canonical Workflow State-Transition Policy

This table is authoritative for critic, tool and repair routing.

| Observed state | Mandatory next action |
|---|---|
| Agent 6 deterministic hard blocker | Do not execute Agent 7. Stop the initial run, or enter Agent 9 only in a separately identified repair-enabled follow-up with remaining iteration budget. |
| Agent 6 non-blocking warning/caveat | Record warning and proceed to Agent 7 when all hard safety checks pass. |
| LLM critic says `human_review_required` | Stop for human review. Never silently convert this to tool approval unless the recommendation consists only of non-blocking caveats and the canonical normaliser records that distinction. |
| Mock critic output | Never counts as real approval for a paid/formal experiment. |
| Concrete revision required, repair policy permits, budget remains | Agent 9 creates a complete replacement artefact and traceability manifest; the result returns through Agent 6. |
| CBMC tool/configuration failure | Record tool failure; do not call it property failure or proof failure. |
| CBMC emits a counterexample for mapped selected claim | Agent 8 analyses the evidence; Agent 9 may run only if the separate repair policy permits. |
| CBMC exits successfully but emits zero mapped selected claims | `tool_success_no_selected_property_evidence`; never scientific success. |
| CBMC mapped selected claims all succeed | `selected_property_verified_under_recorded_model`, subject to complete traceability and non-vacuity gates. |

## Hard blocker identifiers

At minimum, the gate recognises and preserves stable identifiers for:

- `missing_required_assumption`
- `missing_selected_property_claim`
- `loop_guard_tautology`
- `selected_property_scope_drift`
- `target_call_missing_or_irrelevant`
- `contradictory_or_vacuous_assumption`
- `selected_property_unreachable`
- `missing_claim_to_cbmc_mapping`

These identifiers are behavioural API, not cosmetic wording. Regression tests must fail if the corresponding defect is allowed through.
