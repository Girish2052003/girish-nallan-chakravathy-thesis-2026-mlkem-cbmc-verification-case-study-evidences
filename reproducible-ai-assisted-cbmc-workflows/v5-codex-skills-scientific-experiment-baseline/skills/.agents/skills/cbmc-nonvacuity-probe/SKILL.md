---
name: cbmc-nonvacuity-probe
description: Deterministically create disposable companion copies of hash-bound C/CBMC inputs, insert caller-selected __CPROVER_cover reachability goals at exact source anchors, execute bounded CBMC coverage runs, and preserve reachability, feasibility, command, trace, coverage, timeout, and source-integrity evidence. Use after a candidate harness exists to probe whether an intended path, target call, assertion location, or caller-selected marker is reachable. Do not use to change the authoritative harness, invent probe locations, weaken assumptions, judge theorem validity, diagnose failures, or repair code.
---

# CBMC Non-Vacuity Probe

Use this skill only to collect bounded **reachability and feasibility evidence** from disposable companion copies of caller-selected C/CBMC inputs. It is not a proof checker, property generator, critic, repair agent, or acceptance gate.

## Scientific boundary

This skill may:

- verify SHA-256 identities for the authoritative harness and declared source inputs;
- copy only declared files into one disposable companion tree per probe;
- insert exactly one `__CPROVER_cover(1);` statement at an exact caller-supplied source-line anchor;
- probe a caller-selected target call, assertion location, end-of-path marker, or custom marker;
- execute a structured CBMC coverage command using `--cover cover --show-test-suite --json-ui`;
- preserve exact argv, exit code, stdout, stderr, timeout state, and raw JSON;
- report whether CBMC recorded the inserted cover goal as reachable, not reached, or indeterminate;
- verify that the authoritative input files remain byte-for-byte unchanged.

This skill must not:

- alter the authoritative harness or production source tree;
- choose where a probe belongs or infer the intended verification path;
- invent or weaken assumptions;
- add or change the candidate theorem or assertion;
- treat a reached probe as proof validity, semantic non-vacuity, completeness, or implementation correctness;
- treat an unreached probe as a diagnosis of the harness, assumptions, implementation, or CBMC;
- manufacture favourable inputs for the authoritative proof;
- silently change caller-supplied CBMC analysis options;
- invoke a model/API, access the network, or execute through a shell.

## Required inputs

Supply:

1. a local probe root containing the authoritative harness and declared inputs;
2. a new output directory outside the probe root;
3. exact hash-bound tracked-input records;
4. exact analysis source files and build context;
5. an exact target symbol;
6. one or more explicit probes with a source path, exact stripped anchor line, occurrence number, and insertion side;
7. a CBMC executable whose basename is `cbmc`, a timeout, and caller-selected bounded analysis arguments.

Create a request conforming to `references/INPUT_SCHEMA.json`.

## Execute

```bash
python3 .agents/skills/cbmc-nonvacuity-probe/scripts/run_nonvacuity_probe.py \
  --request work/requests/cbmc-nonvacuity-probe.json \
  --probe-root work/candidate-run \
  --output-dir evidence/cbmc-nonvacuity-probe
```

The script uses only Python's standard library and launches CBMC with an argument array and `shell=False`.

## Required outputs

Preserve:

- `canonical_request.json` — validated normalized request;
- `authoritative_input_manifest.before.json` and `.after.json` — authoritative hashes;
- `authoritative_integrity_comparison.json` — before/after comparison;
- `probe_plan.json` — exact anchors, insertion sides, and companion locations;
- `probes/<probe-id>/companion_manifest.json` — companion hashes and inserted marker identity;
- `probes/<probe-id>/cbmc.argv.json` and `cbmc.command.txt` — exact execution;
- `probes/<probe-id>/cbmc.stdout.json` and `cbmc.stderr.txt` — raw tool evidence;
- `probes/<probe-id>/probe_result.json` — mechanical reachability classification;
- `nonvacuity_probe_report.json` and `.md` — aggregate evidence and limitations;
- `nonvacuity_probe_artifact_manifest.json` — hashes of generated evidence.

## Reachability result interpretation

- `REACHED_REPORTED_BY_CBMC`: the inserted cover goal was reported covered/reachable in the exact captured bounded run;
- `NOT_REACHED_REPORTED_BY_CBMC`: the inserted cover goal was reported uncovered/unreachable in the exact captured bounded run;
- `INDETERMINATE`: output completed but the inserted goal could not be mapped unambiguously;
- `TOOL_ERROR`: CBMC reported or returned an execution error;
- `TIMEOUT`: the configured timeout expired.

None of these values decides theorem validity.

## Continue with Codex reasoning

After the skill finishes, Codex must independently inspect the authoritative harness, assumptions, command, probe placement, unwind choices, coverage result, and raw output. Codex—not this skill—decides what the evidence means and whether another probe, a different bound, or a repair is justified.
