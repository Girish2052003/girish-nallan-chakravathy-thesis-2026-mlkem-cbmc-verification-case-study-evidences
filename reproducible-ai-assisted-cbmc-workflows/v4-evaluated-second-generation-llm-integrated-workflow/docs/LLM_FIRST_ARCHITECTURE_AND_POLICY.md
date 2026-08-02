# LLM-First Architecture and Canonical Policy

## Purpose

This source release implements an LLM-first experimental workflow. The LLM performs semantic work in Agents 2–6; deterministic code provides orchestration, typed interfaces, provenance, safety gates, formal-tool execution, measurements and evidence integrity.

## Canonical main experiment

The primary thesis experiment is fixed to:

```json
{
  "protocol_version": "llm-first-v1",
  "semantic_advisory_mode": "off",
  "repair_policy": "none_initial_run",
  "max_iterations": 0,
  "structured_cbmc_json_required": true,
  "selected_property_claims_required": true,
  "mutation_non_vacuity_required": true
}
```

In `off` mode the workflow must not generate or transmit deterministic semantic code summaries, candidate properties, assertion suggestions, contract suggestions or harness sketches to the LLM. Raw specification/source evidence and deterministic measured facts remain permitted.

## Supported comparison modes

- `off`: primary LLM-first experiment.
- `reference_only`: separately identified comparison run in which deterministic semantic advice is transmitted as explicitly non-authoritative reference material.
- `baseline_only`: deterministic baseline; it must not be reported as LLM semantic generation.

A mode change requires a new run identifier and a new protocol hash.

## Required deterministic infrastructure

The following components remain mandatory because they protect reproducibility rather than replacing LLM reasoning:

- master orchestration and stage state machine;
- strict schemas and handoff validation;
- source revision, hashes and protocol binding;
- compilation and tool-readiness checks;
- semantic non-vacuity gate after LLM artefact/review stages;
- CBMC/goto subprocess execution with structured evidence;
- per-step and whole-pipeline deadlines;
- immutable run isolation, logging, inventories and manifests;
- Agent 10 measured facts and Agent 11 bounded interpretation;
- claim-boundary enforcement.

## Formal-evidence rule

A zero exit code or the word `SUCCESS` is not scientific verification. The workflow records four separate states:

1. tool execution successful;
2. all emitted CBMC properties successful;
3. selected-property coverage complete and non-empty;
4. selected property verified under the recorded bounded model.

Only the fourth state may support a selected-property verification statement, and only with the exact assumptions, bound, source revision, protocol hash and CBMC result attached.

## Cost-protection rule

No live API call is authorised when any mandatory local gate is red. Each request is checked before sending for request bytes, estimated stage input tokens, cumulative run input tokens and retry-growth percentage. The retry-growth percentage is fully user controlled: `0` forbids growth, while any non-negative integer such as `100` or `150` is accepted; the default remains `10`. Incomplete provider responses are typed and do not trigger schema parsing of the response envelope.

## Release rule

This private mutable-only workspace keeps editable pipeline code, inputs, configs, reports, and per-run evidence in one project. Every run still receives an isolated `runs/<run_id>/` tree and preserves scientific provenance, but no release-ZIP or package-manifest authorization is used.
