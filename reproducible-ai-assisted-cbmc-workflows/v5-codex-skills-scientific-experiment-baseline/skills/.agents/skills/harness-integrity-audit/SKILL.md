---
name: harness-integrity-audit
description: Deterministically audit a local C/CBMC harness and its hash-bound source/build inputs for structural red flags such as production-file changes, missing target calls, target replacement or stubbing patterns, absent user assertions, assumption/assertion inventories, obvious assume(false) and constant-false controls, duplicate or syntactically trivial assertions, unexpected build inputs, and caller-supplied undefined-function diagnostics. Use after a candidate harness exists and before scientific interpretation. Do not use to accept or reject a proof, judge assumption justification, diagnose semantic correctness, or repair code.
---

# Harness Integrity Audit

Use this skill only for a deterministic **structural and syntactic audit** of a caller-selected C/CBMC harness and its declared source/build context. It is not an LLM critic, proof checker, theorem judge, repair agent, or acceptance gate.

## Scientific boundary

This skill may:

- compare declared production and harness files with caller-supplied SHA-256 identities;
- inventory the final caller-declared build inputs and compare them with a caller-declared allowlist;
- locate lexical calls to one explicitly named target function;
- flag lexical target definitions or target macros outside the authoritative definition file;
- inventory `__CPROVER_assume`, `__CPROVER_assert`, and C `assert` calls;
- flag only narrow obvious-false assumptions and constant-false control expressions;
- flag duplicate normalized assertions, narrow constant/reflexive assertions, and assertions textually identical to assumptions;
- consume one optional hash-bound `goto-instrument --list-undefined-functions` text artifact;
- produce findings using only `CHECKED`, `WARNING`, and `NOT_CHECKABLE`.

This skill must not:

- declare `ACCEPTED`, `REJECTED`, `PROOF_VALID`, `THEOREM_CORRECT`, or `IMPLEMENTATION_CORRECT`;
- decide whether an assumption is scientifically justified;
- determine whether an assertion is meaningful or complete;
- prove reachability, non-vacuity, semantic non-triviality, or target-call execution;
- classify a finding as deception, a harness defect, an implementation defect, or a tool defect;
- alter the harness, production source, build files, or diagnostic evidence;
- choose a theorem, add an assertion, weaken assumptions, or recommend a repair;
- invoke a model/API, access the network, execute a shell, or run CBMC automatically.

## Required inputs

Supply:

1. a local audit root containing the harness, production files, build inputs, and optional diagnostic file;
2. an output directory outside the audit root that does not already exist;
3. one exact target symbol and authoritative definition path;
4. the candidate harness path and expected SHA-256;
5. hash-bound production-file records;
6. a caller-declared allowed-build-input list and actual-build-input list;
7. explicit booleans enabling or disabling each mechanical check;
8. optionally, a hash-bound undefined-functions diagnostic.

Create a request conforming to `references/INPUT_SCHEMA.json`.

## Execute

```bash
python3 .agents/skills/harness-integrity-audit/scripts/audit_harness_integrity.py \
  --request work/requests/harness-integrity-audit.json \
  --audit-root work/candidate-run \
  --output-dir evidence/harness-integrity-audit
```

The script uses only the Python standard library. It does not execute external programs.

## Required outputs

Preserve:

- `canonical_request.json` — validated normalized request;
- `source_manifest.json` — expected/actual hashes and caller-declared build inputs;
- `assumption_inventory.json` — lexical assumption calls and narrow truth classification;
- `assertion_inventory.json` — lexical assertion calls and narrow truth classification;
- `target_binding_report.json` — target call count and replacement-pattern evidence;
- `findings.json` — complete finding list using the three-status vocabulary;
- `harness_integrity_audit_report.json` — structured audit summary and limitations;
- `harness_integrity_audit_report.md` — human-readable findings;
- `harness_integrity_audit_artifact_manifest.json` — hashes of generated evidence.

## Status interpretation

- `CHECKED`: the configured mechanical check completed and did not flag its specific narrow pattern;
- `WARNING`: the configured check recorded evidence requiring Codex or researcher inspection;
- `NOT_CHECKABLE`: the check was disabled or required evidence was not supplied.

None of these values is an acceptance or rejection decision.

## Continue with Codex reasoning

After the skill finishes, Codex must independently inspect every warning, assess semantic meaning, justify assumptions and assertions, determine whether further CBMC/non-vacuity work is needed, and choose any repair. The audit output is evidence—not authority.
