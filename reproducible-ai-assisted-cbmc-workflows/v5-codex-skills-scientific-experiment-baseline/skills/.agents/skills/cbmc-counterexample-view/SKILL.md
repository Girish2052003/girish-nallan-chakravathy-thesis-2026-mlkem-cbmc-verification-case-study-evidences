---
name: cbmc-counterexample-view
description: Deterministically select one explicitly named failed property from local CBMC JSON output and produce a bounded, inspectable counterexample view containing normalized trace steps, source locations, function call/return events, assumption steps, requested variable transitions, the trace endpoint, and links to the complete hash-bound raw evidence. Use when a CBMC failure trace is too large to inspect directly. Do not use to diagnose the cause, recommend a repair, decide whether the harness or implementation is wrong, or judge correctness.
---

# CBMC Counterexample View

Use this skill only to mechanically reduce and present a **caller-selected CBMC failure trace**. The skill is not a counterexample analyst, critic, repair agent, theorem judge, or defect classifier.

## Scientific boundary

You remain responsible for all interpretation. This skill may:

- verify the SHA-256 identity of one local CBMC JSON output;
- locate an exact caller-supplied failed property identifier;
- reject missing, non-failed, trace-free, or ambiguous property records;
- preserve the selected property description and source location as recorded;
- normalize trace steps without changing the raw input;
- retain function-call/return, assumption, failure, endpoint, target-variable, target-function, and exact source-file matches;
- add a bounded number of surrounding context steps;
- exclude trace steps marked `hidden` unless explicitly requested;
- report selected variable assignments and the latest assignment **observed in selected trace steps**;
- write machine-readable and human-readable evidence with hashes and limitations.

This skill must not:

- explain why the property failed;
- classify the failure as a harness, tool, assumption, implementation, specification, or environment defect;
- recommend or apply a repair;
- say that an assumption is unjustified or justified;
- infer mathematical meaning from a variable value;
- claim that the compact slice is a complete state or complete trace;
- modify the raw CBMC output, harness, production source, or build files;
- rerun CBMC or silently choose another property;
- use the internet, an LLM/API, a shell, or an external command.

## Required inputs

Supply:

1. an input root containing the raw CBMC JSON output;
2. an output directory outside the input root that does not already exist;
3. the exact repository-relative trace path and SHA-256;
4. the exact failed property identifier selected by Codex;
5. optional literal target-variable strings, exact target function, exact source files, context size, and selection limit.

Do not ask the skill to decide which failed property matters. Codex must select it from the CBMC evidence.

## Request format

Create a request conforming to `references/INPUT_SCHEMA.json`.

```json
{
  "schema_version": "1.0",
  "request_id": "mlk-poly-sub-counterexample-001",
  "trace_source": {
    "path": "analysis.stdout.json",
    "expected_sha256": "<sha256>",
    "format": "cbmc-json-ui"
  },
  "failed_property_id": "main.assertion.1",
  "selection": {
    "target_variables": ["r.coeffs[0]", "observed"],
    "target_function": "mlk_poly_sub",
    "source_files": [],
    "context_steps": 0,
    "max_selected_steps": 500,
    "tail_steps_when_unfocused": 200,
    "include_hidden_steps": false,
    "include_function_steps": true,
    "include_assumption_steps": true,
    "include_location_steps": false
  }
}
```

Target-variable matching is deliberately transparent and weak: it is literal substring matching over normalized step text. It is not semantic data-flow analysis.

## Execute

```bash
python3 .agents/skills/cbmc-counterexample-view/scripts/build_counterexample_view.py \
  --request work/requests/counterexample-view.json \
  --input-root evidence/cbmc-run \
  --output-dir evidence/counterexample-view/main.assertion.1
```

The script performs no process execution and makes no network or model calls.

## Required outputs

Preserve:

- `canonical_request.json` — validated normalized request;
- `input_manifest.json` — raw input path, size, expected hash, actual hash, and match result;
- `selected_property.json` — exact selected property metadata;
- `trace_index.json` — mechanical normalization of every raw trace step;
- `compact_trace.json` — bounded selected steps, call/return sequence, latest observed assignments, and endpoint;
- `counterexample_view_report.json` — structured outcome, counts, warnings, and limitations;
- `counterexample_view_report.md` — human-readable compact trace;
- `counterexample_view_artifact_manifest.json` — hashes of generated evidence.

The complete raw CBMC JSON remains authoritative evidence. The compact view is only an index and presentation aid.

## Status and exit codes

- `0`: `COMPLETE` or `COMPLETE_WITH_WARNINGS`, with `COUNTEREXAMPLE_VIEW_CREATED`;
- `3`: request, identity, path, property-selection, trace-presence, ambiguity, or format contract error;
- `5`: unexpected internal error.

A successful skill run does not mean that the cause of the failure is understood. It means only that the exact selected trace was mechanically presented under the captured selection rules.

## Continue with Codex reasoning

After the skill finishes, inspect the complete raw trace whenever the compact view is insufficient. Codex must independently interpret the execution, distinguish harness/tool/code/specification issues, choose any repair, and justify every conclusion. Preserve the skill output as evidence of what was mechanically selected and what remained outside the helper's authority.
