---
name: cbmc-execute
description: Execute an explicitly supplied local CBMC task without a shell, preserve exact argv, tool version, source hashes, raw JSON stdout and stderr, timestamps, property inventory, normalized per-property statuses, traces when CBMC emits them, controlled coverage artifacts, timeouts, and before/after source integrity evidence. Use after Codex has chosen the verification property, harness, source set, assumptions, assertions, and CBMC options. Do not use to select properties, change options, weaken assumptions, repair failures, or treat CBMC success as complete correctness.
---

# CBMC Execute

Use this skill only to run a CBMC task whose scientifically meaningful content has already been chosen by you. This skill is an execution and evidence-preservation utility, not a verification strategist or critic.

## Scientific boundary

You remain responsible for:

- selecting the property and verification strategy;
- choosing the harness and production source set;
- justifying all assumptions, assertions, contracts, loop bounds, and CBMC checks;
- deciding whether a failure is caused by the harness, build, bound, property, or implementation;
- deciding whether a successful bounded result is useful, sufficient, or scientifically valid;
- repairing or strengthening the artefacts.

This skill may only:

- validate a structured execution request;
- verify declared input SHA-256 identities;
- run the declared CBMC analysis through an argv array with `shell=False`;
- add the declared evidence UI option `--json-ui`;
- optionally run a separately recorded `--show-properties --json-ui` inventory command;
- capture CBMC version output, exact argv, working directory, selected environment, timestamps, exit codes, stdout, and stderr;
- enforce declared timeout, address-space, and output-file limits;
- mechanically normalize property IDs, CBMC statuses, source locations, trace presence, and property counts from JSON fields;
- preserve controlled symbolic-execution coverage output when explicitly requested;
- compare all declared tracked-input hashes before and after execution;
- report warnings, incomplete evidence, and source mutation.

It must never:

- create or select a theorem;
- insert, remove, or rewrite assumptions or assertions;
- add semantic CBMC checks that Codex did not request;
- add or change unwind bounds, property selection, architecture, solver, contracts, or function entry points;
- retry with weaker settings after failure;
- interpret a counterexample or recommend a repair;
- convert a CBMC failure into success;
- declare `PROOF VALID`, `IMPLEMENTATION CORRECT`, or complete correctness;
- execute through a shell, hidden argument file, network call, or model call;
- modify production source or silently tolerate source changes.

## Request preparation

Create a JSON request conforming to `references/INPUT_SCHEMA.json`. All paths in the request are relative to the separately supplied workspace root.

Example:

```json
{
  "schema_version": "1.0",
  "request_id": "mlk-poly-sub-safety-001",
  "working_directory": ".",
  "analysis_sources": [
    "proofs/mlk_poly_sub_harness.c",
    "mlkem/poly.c"
  ],
  "tracked_inputs": [
    "proofs/mlk_poly_sub_harness.c",
    "mlkem/poly.c",
    "mlkem/poly.h",
    "mlkem/params.h"
  ],
  "expected_sha256": {},
  "analysis": {
    "options": [
      "--function", "mlk_poly_sub_harness",
      "--bounds-check",
      "--pointer-check",
      "--signed-overflow-check",
      "--trace",
      "--unwind", "257",
      "--unwinding-assertions"
    ],
    "timeout_seconds": 1800
  },
  "inventory": {
    "enabled": true,
    "options": ["--function", "mlk_poly_sub_harness"],
    "timeout_seconds": 120
  },
  "execution_environment": {},
  "limits": {
    "memory_mb": 8192,
    "file_size_mb": 1024
  },
  "clock": {"mode": "wall_clock"}
}
```

The skill appends `--json-ui` and the declared `analysis_sources`; it records the complete expanded argv before execution. Do not include `--json-ui`, `--xml-ui`, `--show-properties`, source-file arguments, shell redirection, or output-file options in `analysis.options`.

For a controlled CBMC coverage report, use exactly:

```json
"analysis": {
  "options": [
    "--symex-coverage-report",
    "{artifact_dir}/coverage.xml"
  ]
}
```

The placeholder is expanded only to the skill-owned `artifacts/coverage.xml` path. Other output paths are rejected.

## Execute

```bash
python3 .agents/skills/cbmc-execute/scripts/execute_cbmc.py \
  --request work/requests/mlk-poly-sub-safety-001.json \
  --workspace-root workspaces/run-001 \
  --output-dir evidence/run-001/cbmc-execute \
  --cbmc-path /usr/bin/cbmc
```

The output directory must not already exist and must be outside the workspace root.

## Exit codes

- `0` — complete evidence captured, including either CBMC-reported pass or CBMC-reported property failure;
- `2` — incomplete execution evidence, including timeout, unparseable JSON, or tool error;
- `3` — request, path, executable, option, or output contract error;
- `4` — declared input identity mismatch before execution;
- `5` — one or more tracked inputs changed during execution;
- `6` — unexpected wrapper failure.

A CBMC property failure is evidence, not a wrapper crash, so it can still produce wrapper exit code `0`. Always inspect `execution_summary.json`.

## Required evidence

Preserve the entire output directory, especially:

- `canonical_request.json`;
- `analysis.argv.json` and `analysis.command.txt`;
- `analysis.stdout.json` and `analysis.stderr.txt`;
- `inventory.argv.json`, `inventory.stdout.json`, and `inventory.stderr.txt` when requested;
- `property_inventory.json`;
- `cbmc.version.stdout.txt` and `cbmc.version.stderr.txt`;
- `environment_snapshot.json`;
- `source_manifest.before.json` and `source_manifest.after.json`;
- `source_integrity_comparison.json`;
- `execution_artifact_manifest.json` and `artifacts/`;
- `invocation_manifest.json`;
- `execution_summary.json` and `execution_report.md`.

## Interpretation boundary

`PASS_REPORTED_BY_CBMC` means only that the captured CBMC JSON reported success for the exact bounded invocation, declared inputs, tool version, options, and environment. It does not establish that:

- the theorem is meaningful;
- assumptions are justified;
- the harness is non-vacuous;
- the source selection is complete;
- the unwind bound is sufficient;
- all implementation behaviours were represented;
- the implementation is completely correct.

Return to your own reasoning after reading the evidence. Use the later counterexample-view, integrity-audit, and non-vacuity skills only when independently relevant; do not treat this skill as an orchestrator.
