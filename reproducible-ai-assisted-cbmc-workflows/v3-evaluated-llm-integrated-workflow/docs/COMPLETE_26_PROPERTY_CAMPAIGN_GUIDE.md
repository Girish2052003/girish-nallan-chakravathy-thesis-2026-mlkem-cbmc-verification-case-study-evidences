# Complete 26-Property Campaign Guide

## One build, many experiments

This release uses one production package and separate JSON experiment configurations. You do not need a new code build for each property. Select the property family in `property_campaign`:

```json
{
  "property_campaign": {
    "property_family_id": "P12",
    "verification_strategy": "auto",
    "allow_analysis_only": false
  }
}
```

`auto` selects the catalogue default. A caller can choose another strategy only when that strategy is explicitly allowed for the family.

## Useful commands

```bash
python property_campaign_cli.py list
python property_campaign_cli.py show P12
python property_campaign_cli.py fragment P12 --strategy auto
python property_campaign_cli.py validate-config configs/my_experiment.json
```

Campaign fragments are available in `configs/property_campaigns/`. They are fragments, not standalone experiment configs.

## Evidence and artefact strategies

1. `standard_cbmc_harness` — bounded safety/range/frame assertions.
2. `native_function_contract` — requires/ensures/assigns/frees contract checking.
3. `native_loop_contract` — invariant/decreases/frame clauses on copied source.
4. `relational_cbmc_harness` — round-trip, pack/unpack or two-run determinism relations.
5. `hybrid_contract_and_harness` — contract plus property harness.
6. `analysis_only_no_formal_claim` — evidence-based analysis with formal proof claims prohibited.

## Property 19

Secret-dependent branch/access support is deliberately analysis-only. The workflow may identify candidate dependencies and point to external/manual constant-time evidence, but it cannot label this as a CBMC constant-time proof.

## Stretch families

P07, P11, P14, P18 and P20 may require repository-specific stubs, larger unwinds, dependency models or decomposition. The package supports their experiment lifecycle; it does not promise automatic tractability.

## First experiment safety

Keep `max_iterations: 0`, never force the review gate, run `preflight_first_api.py`, and use a new run ID. Native contract campaigns additionally require `goto-cc` and `goto-instrument`; the preflight executes the native loop-contract smoke, function-contract/DFCC smoke, or both, according to the selected strategy before approving the run.

## Result interpretation

- `verification_successful`: CBMC reported success for the exact recorded scope.
- `verification_failed`: a selected assertion/property failed in the model.
- `contract_build_or_instrumentation_failed`: no property conclusion; inspect GOTO construction/contract syntax.
- `analysis_only_no_formal_tool_claim`: expected for P19; not a formal pass or fail.
- `skipped_by_review_gate`: candidate was not approved for execution.
