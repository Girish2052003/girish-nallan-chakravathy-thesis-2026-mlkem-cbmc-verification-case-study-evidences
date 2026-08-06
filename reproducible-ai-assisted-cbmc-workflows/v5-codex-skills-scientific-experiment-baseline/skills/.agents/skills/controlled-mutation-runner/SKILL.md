---
name: controlled-mutation-runner
description: Deterministically verify and apply an exact caller-supplied unified-diff mutation to a disposable copy of a hash-bound C/CBMC workspace, run the same optional syntax check and bounded CBMC invocation on baseline and mutant copies, preserve raw evidence, compare caller-selected property statuses, and confirm that the authoritative source tree remained unchanged. Use only after Codex has already designed the mutation, supplied its rationale, and declared the expected verification effect. Do not use to invent mutations, select properties, weaken assumptions, edit authoritative sources, interpret mathematical meaning, grade a theorem, or claim novelty.
---

# Controlled Mutation Runner

Use this advanced optional skill only after Codex has already selected and written an exact mutation. The skill is a deterministic executor and evidence recorder, not a mutation designer, critic, repair agent, or scientific judge.

## Scientific boundary

This skill may:

- verify caller-supplied SHA-256 identities for the authoritative files and patch;
- parse a restricted text unified diff without calling `patch` or `git apply`;
- reject creations, deletions, renames, binary patches, path traversal, symlinks, undeclared files, and mismatched context;
- copy the declared workspace into independent disposable baseline and mutant directories;
- apply the exact patch only to the mutant copy;
- record before/after hashes for every touched file;
- run the same caller-supplied optional syntax check on both copies;
- run the same bounded CBMC analysis on both copies with controlled JSON output;
- preserve exact argv, exit codes, stdout, stderr, timeouts, raw CBMC JSON, and normalized property-status observations;
- compare a caller-declared property-status transition mechanically;
- verify the authoritative files before and after execution;
- delete the disposable workspaces and record cleanup/restoration evidence.

This skill must not:

- invent, suggest, rank, strengthen, weaken, or repair a mutation;
- decide which theorem or property deserves mutation testing;
- infer a mutation from a failed property or counterexample;
- modify the authoritative source tree;
- silently alter the harness, assumptions, assertions, analysis options, or property selection;
- call a model/API, network service, shell, `patch`, or `git apply`;
- interpret a changed property status as proof usefulness, completeness, novelty, or implementation correctness;
- use `KILLED`, `SURVIVED`, `VALID`, `ACCEPTED`, or `REJECTED` as scientific verdicts.

## Required inputs

Supply:

1. an authoritative workspace root;
2. a new output directory outside the authoritative workspace;
3. a request conforming to `references/INPUT_SCHEMA.json`;
4. every file required by the bounded task, with expected SHA-256 and mutation permission;
5. one exact unified-diff patch and its expected SHA-256;
6. Codex's mutation rationale and expected effect as caller declarations;
7. the exact CBMC source list and analysis arguments;
8. an optional restricted syntax-check configuration;
9. an optional structured expected property-status transition.

## Execute

```bash
python3 .agents/skills/controlled-mutation-runner/scripts/run_controlled_mutation.py \
  --request work/requests/controlled-mutation.json \
  --workspace-root work/authoritative-source \
  --output-dir evidence/controlled-mutation
```

The script uses Python's standard library. It executes only an optional compiler named `gcc`, `clang`, or `cc`, and a model checker whose executable basename is `cbmc`. It never invokes a shell.

## Required outputs

Preserve:

- `canonical_request.json`;
- `authoritative_manifest.before.json` and `.after.json`;
- `authoritative_integrity_comparison.json`;
- `patch_input_manifest.json`;
- `applied.patch`;
- `patch_application_report.json`;
- `mutated_file_manifest.json`;
- `baseline/` exact command and raw evidence;
- `mutant/` exact command and raw evidence;
- `comparison_report.json` and `.md`;
- `cleanup_and_restoration_report.json`;
- `controlled_mutation_artifact_manifest.json`.

## Status interpretation

- `COMPLETE`: the exact patch was applied to a disposable copy, requested executions completed, authoritative inputs were unchanged, and cleanup succeeded;
- `COMPLETE_WITH_WARNINGS`: the core run completed, but optional syntax checks, optional property observations, or parsing produced warnings;
- `INCOMPLETE`: the patch could not be safely applied, required execution failed or timed out, an authoritative input changed, or cleanup could not be confirmed.

These statuses describe **execution and evidence completeness only**. They do not declare that the mutation was scientifically meaningful or that a property is strong.

## Continue with Codex and researcher evaluation

Codex and the researcher must interpret why the observed baseline/mutant difference occurred, whether the mutation is realistic and relevant, whether the selected property should detect it, and what the result means for the thesis. This skill only preserves the controlled experiment.
