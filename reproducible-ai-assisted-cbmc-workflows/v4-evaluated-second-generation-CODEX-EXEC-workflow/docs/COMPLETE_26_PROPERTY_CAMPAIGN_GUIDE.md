# Complete 26-Property Campaign Guide

## One mutable workspace, many experiments

The same editable pipeline supports separate JSON experiment configurations for all planned property families. You do not need to change pipeline code for each property. Select the property family in `property_campaign`:

```json
{
  "property_discovery": {
    "mode": "targeted_campaign"
  },
  "property_campaign": {
    "property_family_id": "P12",
    "verification_strategy": "auto",
    "allow_analysis_only": false
  }
}
```

`auto` selects the catalogue default. Another strategy is accepted only when the catalogue explicitly permits it for that family.

## Create a targeted experiment config

Copy the targeted template:

```bash
cp configs/CONFIG_TEMPLATE_TARGETED_CAMPAIGN.json \
   configs/my_targeted_experiment.json
```

Then set at least:

```text
unique run_id
target function and topic
specification and code/header paths
mlkem-native source revision
property family and strategy
model profile
CBMC working directory, sources, includes, stubs, and entry function
```

Keep `output_root` as `runs` unless you intentionally choose another local directory.

## Useful campaign commands

```bash
python property_campaign_cli.py list
python property_campaign_cli.py show P12
python property_campaign_cli.py fragment P12 --strategy auto
python property_campaign_cli.py validate-config configs/my_targeted_experiment.json
```

Campaign fragments are available in `configs/property_campaigns/`. They are fragments, not standalone experiment configs.

## Zero-cost local preflight

Before spending API money, run:

```bash
python preflight_first_api.py \
  --config configs/my_targeted_experiment.json \
  --local-only \
  --normalized-config configs/my_targeted_experiment.normalized.json \
  --report reports/my_targeted_experiment.preflight.json
```

The normalized copy is optional. Local preflight checks configuration, inputs, evidence completeness, source revision, prompt size, property/strategy compatibility, CBMC availability, and run-directory readiness without making a provider request.

For native-contract strategies, install `goto-cc` and `goto-instrument`; local preflight executes the strategy-specific contract-tool smoke check.

## Optional paid provider probe

Only when deliberately authorising a provider-access check:

```bash
python preflight_first_api.py \
  --config configs/my_targeted_experiment.json \
  --live-api-probe \
  --acknowledge-paid-probe \
  --report reports/my_targeted_experiment.live-probe.json
```

This step is optional and may incur API cost.

## Direct launch

Launch the reviewed ordinary config or its normalized copy:

```bash
python agents/master_orchestrator.py \
  --config configs/my_targeted_experiment.normalized.json \
  --strict-outputs
```

Review the isolated result under:

```text
runs/<run_id>/
```

Keep `max_iterations: 0` for the initial unassisted experiment, never force the review gate, and use a new run ID for each official run.

## Evidence and artefact strategies

1. `standard_cbmc_harness` — bounded safety, range, and frame assertions.
2. `native_function_contract` — requires, ensures, assigns, and frees contract checking.
3. `native_loop_contract` — invariant, decreases, and frame clauses on copied source.
4. `relational_cbmc_harness` — round-trip, pack/unpack, or two-run determinism relations.
5. `hybrid_contract_and_harness` — contract plus property harness.
6. `analysis_only_no_formal_claim` — evidence-based analysis with formal proof claims prohibited.

## Property 19

Secret-dependent branch/access support is deliberately analysis-only. The workflow may identify candidate dependencies and point to external or manual constant-time evidence, but it cannot label this as a CBMC constant-time proof.

## Stretch families

P07, P11, P14, P18, and P20 may require repository-specific stubs, larger unwinds, dependency models, or decomposition. The package supports their experiment lifecycle; it does not promise automatic tractability.

## Canonical Agent 7 result interpretation

All downstream agents use the shared `agents/common/tool_result_contract.py` contract.

- `selected_property_verified_under_recorded_model`: all mapped selected-property claims succeeded under the recorded harness, assumptions, command and model; this is bounded success only.
- `verification_failed_or_unknown`: inspect `emitted_failure_count` and `emitted_unknown_count`; failures, unknowns and mixed outcomes are reported separately.
- `tool_output_not_structured_json`: evidence-format failure; no scientific property conclusion.
- `tool_success_no_emitted_property_evidence`: the tool ran but emitted no structured property rows.
- `tool_error_no_property_evidence`: tool/build execution failed without property evidence.
- `tool_success_no_selected_property_evidence`: emitted claims succeeded but selected-property traceability is incomplete.
- `tool_execution_or_evidence_inconsistent`: tool status, properties and selected-property coverage contradict each other.
- `contract_build_or_instrumentation_failed`: no property conclusion; inspect GOTO construction or contract syntax.
- `tool_timeout`, `tool_unavailable`, `skipped_by_review_gate`, and `dry_run_not_executed`: no completed formal result.
- `analysis_only_no_formal_tool_claim`: expected for P19; not a formal pass or fail.
