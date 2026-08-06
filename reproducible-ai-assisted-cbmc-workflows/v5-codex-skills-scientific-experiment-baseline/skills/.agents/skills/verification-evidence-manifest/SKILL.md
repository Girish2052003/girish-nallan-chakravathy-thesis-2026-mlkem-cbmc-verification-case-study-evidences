---
name: verification-evidence-manifest
description: Deterministically hash, index, and summarize already-produced formal-verification artefacts into manifest.json and manifest.md, including declared property records, source revision evidence, environment records, lexical harness assumption/assertion inventories, CBMC commands/results, skill-labelled outputs, repair iterations, missing-evidence warnings, and raw-evidence paths. Use near the end of a run when Codex needs a compact evidence ledger. Do not use to execute CBMC, discover or judge properties, reinterpret tool results, grade Codex, claim novelty, or write thesis conclusions.
---

# Verification Evidence Manifest

Use this skill only to organize **existing evidence** that Codex or surrounding instrumentation has already produced. It is not a logger agent, proof checker, evaluator, critic, or thesis-writing agent.

## Scientific boundary

This skill may:

- verify caller-supplied SHA-256 identities for explicitly declared artefacts;
- record a caller-declared source revision and its evidence path;
- preserve caller-supplied property statements and final status as unverified declarations;
- lexically inventory configured assumption and assertion calls in declared harness files;
- extract caller-selected JSON Pointer fields from declared JSON artefacts;
- group artefacts by caller-declared skill name and repair iteration;
- report missing required/optional artefacts, missing roles, hash mismatches, parse limitations, unlisted files, and input mutation;
- create `manifest.json`, `manifest.md`, supporting inventories, and hashes of every generated output.

This skill must not:

- select, discover, strengthen, weaken, or rank a verification property;
- infer substantive preconditions, aliasing rules, mathematical bounds, or proof strategy;
- execute CBMC, a compiler, a shell command, a model/API, or a network request;
- reinterpret `PASS`, `FAILURE`, coverage, timeout, or counterexample evidence;
- decide whether assumptions or assertions are scientifically justified;
- grade Codex, accept/reject a run, claim novelty, or write the thesis conclusion;
- modify, copy over, repair, or delete any input artefact.

## Required inputs

Supply:

1. a local run root containing artefacts already produced;
2. a new output directory outside that run root;
3. a request conforming to `references/INPUT_SCHEMA.json`;
4. an explicit artefact list with role, required/optional status, expected hash, optional skill name, iteration, and caller-selected JSON fields;
5. caller-declared property records, source revision, required evidence roles, and final status if available.

## Execute

```bash
python3 .agents/skills/verification-evidence-manifest/scripts/build_evidence_manifest.py \
  --request work/requests/verification-evidence-manifest.json \
  --run-root work/completed-run \
  --output-dir evidence/verification-evidence-manifest
```

The script uses only Python's standard library. It does not invoke external commands.

## Required outputs

Preserve:

- `canonical_request.json` — validated normalized request;
- `input_file_manifest.before.json` and `.after.json` — declared input identities;
- `input_integrity_comparison.json` — before/after comparison;
- `harness_claim_inventory.json` — lexical assumption/assertion calls only;
- `property_inventory.json` — caller-supplied property records;
- `extracted_field_index.json` — caller-selected JSON Pointer results;
- `skill_use_records.json` — artefacts grouped by caller-declared skill name;
- `iteration_index.json` — artefacts grouped by caller-declared iteration;
- `missing_evidence_warnings.json` — mechanical completeness warnings;
- `manifest.json` and `manifest.md` — compact evidence ledger;
- `generated_artifact_manifest.json` — hashes of generated outputs.

## Status interpretation

- `COMPLETE`: all required artefacts and roles were present, their expected hashes matched, inputs remained unchanged, and no warning was recorded;
- `COMPLETE_WITH_WARNINGS`: all required evidence remained available and hash-consistent, but optional or parse/scan warnings exist;
- `INCOMPLETE`: at least one required artefact/role is missing, a required hash mismatched, or an input changed during processing.

These values describe **manifest completeness only**. They do not determine theorem validity or scientific acceptance.

## Continue with Codex and researcher evaluation

After the skill finishes, Codex and the researcher must inspect the raw artefacts, the exact CBMC commands and outputs, property meaning, assumptions, repair history, non-vacuity evidence, and limitations. The manifest is an index—not a scientific conclusion.
