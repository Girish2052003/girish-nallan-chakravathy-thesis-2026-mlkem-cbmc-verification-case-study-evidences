# Mutable-Only ML-KEM/CBMC Research Workspace

This private thesis edition has one workspace behaviour: it is editable and writes each experiment to `runs/<run_id>/` inside the same project. It does not implement release-ZIP, package-manifest, or bound-config authorization.

## Two independent property-research modes

- `targeted_campaign`: select one P01–P26 family before Agent 4.
- `open_discovery`: hide the P01–P26 catalogue from the LLM, classify candidates afterward, retain new candidates as `UNMAPPED`, and select one concrete candidate before Agent 5.

Both modes retain Agent 5 traceability, Agent 6 tautology/vacuity/scope/assumption checks, structured CBMC evidence, repair routing, Agent 10 logging, and Agent 11 reporting.

## Folder layout

```text
agents/      pipeline programs
inputs/      editable specification and code inputs
configs/     editable experiment configurations
runs/        one separate directory per run
reports/     optional preflight and analysis reports
```

No `workspace_mode` field is required. An older config containing `"workspace_mode": "mutable_workspace"` still works. An old `verified_release` value is rejected with a clear migration error.

## Zero-cost local preflight

```bash
python preflight_first_api.py \
  --config configs/my_experiment.json \
  --local-only \
  --normalized-config configs/my_experiment.normalized.json \
  --report reports/my_experiment.preflight.json
```

`--local-only` creates no provider client and makes no API request. `--normalized-config` is optional and adds no authorization or binding.

## Direct launch

```bash
python agents/master_orchestrator.py \
  --config configs/my_experiment.json \
  --strict-outputs
```

Results appear under `runs/<run_id>/`, with separate directories for Agents 1–11 and their handoffs, iterations, tool evidence, diagnostics, and final reports.

## What may be edited

You may edit specifications, source/header inputs, configs, targets, property families, agents, schemas, preflight, and orchestration code. Do not edit files during an active official run because different stages could then execute different code or inputs.

## What must remain for the workflow to function

Internal run, stage, handoff, artifact, iteration, and tool-evidence manifests are Agent-to-Agent wiring and scientific evidence. They are not release locks.
