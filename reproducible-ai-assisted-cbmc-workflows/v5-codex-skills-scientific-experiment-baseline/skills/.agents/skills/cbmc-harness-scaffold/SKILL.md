---
name: cbmc-harness-scaffold
description: Deterministically generate a neutral, syntax-checkable C/CBMC harness skeleton for an explicitly named local C target from caller-supplied includes, object declarations, arguments, source hashes, and build facts. Use when repetitive harness wiring is needed but the theorem, assumptions, assertions, contracts, input domains, and repair strategy must remain Codex's responsibility. Do not use to discover properties, infer bounds or aliasing, insert verification claims, copy native contracts, or judge correctness.
---

# CBMC Harness Scaffold

Use this skill only to generate **neutral C wiring** around a caller-selected target. The skill is not a theorem generator, property generator, contract generator, or verification critic.

## Scientific boundary

You remain responsible for all scientifically meaningful choices. This skill may:

- bind the request to explicitly declared local source/header hashes;
- emit caller-supplied include directives;
- emit caller-supplied object declarations without initializers;
- emit clearly marked, intentionally empty input-preparation, assumption, and assertion regions;
- emit exactly one call to the explicitly named target using caller-supplied structured arguments;
- optionally capture a return value into an already declared object;
- optionally run a syntax-only compiler check with a narrow allowlist of arguments;
- preserve the exact compiler argument vector, stdout, stderr, exit code, and hashes;
- report deterministic structural facts and mandatory interpretation limits;
- write machine-readable and human-readable evidence.

This skill must not:

- select, propose, rank, strengthen, or weaken a verification property;
- infer or insert coefficient, integer, memory, pointer, aliasing, range, loop, or domain assumptions;
- insert `__CPROVER_assume`, `__CPROVER_assert`, C `assert`, contracts, invariants, or expected output relationships;
- initialize objects to scientifically meaningful values;
- derive declarations or target arguments from implementation semantics;
- copy native harnesses, production contracts, or withheld proof material;
- modify production source, headers, build files, or the repository;
- invoke CBMC, interpret counterexamples, repair a harness, or declare correctness;
- use the internet, an LLM/API, or a shell command string.

## Required inputs

Before invoking the script, supply:

1. a local repository root;
2. an output directory outside that repository that does not already exist;
3. the exact target symbol and repository-relative source file;
4. the exact call arguments, expressed only as conservative object/lvalue forms;
5. exact include directives and uninitialized object declarations;
6. SHA-256 bindings for the target source and every other file whose identity must be preserved;
7. an optional syntax-only compiler context.

Do not ask this skill to work out what objects, assumptions, assertions, or property should exist. Those are Codex decisions.

## Request format

Create a request conforming to `references/INPUT_SCHEMA.json`.

```json
{
  "schema_version": "1.0",
  "request_id": "mlk-poly-sub-scaffold-001",
  "target": {
    "symbol": "mlk_poly_sub",
    "source_file": "src/poly.c",
    "arguments": ["&r", "&a", "&b"],
    "return_capture": {"mode": "none"}
  },
  "harness": {
    "filename": "mlk_poly_sub_harness.c",
    "entry_function": "main",
    "language_standard": "c90",
    "includes": [{"style": "quoted", "value": "poly.h"}],
    "declarations": [
      {"type": "mlk_poly", "name": "r", "role": "output"},
      {"type": "mlk_poly", "name": "a", "role": "input"},
      {"type": "mlk_poly", "name": "b", "role": "input"}
    ]
  },
  "source_bindings": [
    {"path": "include/poly.h", "expected_sha256": "<sha256>"},
    {"path": "src/poly.c", "expected_sha256": "<sha256>"}
  ],
  "compile_check": {
    "enabled": true,
    "required": true,
    "compiler": "gcc",
    "include_dirs": ["include"],
    "defines": [],
    "extra_args": ["-Wall", "-Wextra"],
    "timeout_seconds": 30
  }
}
```

The `role` label is descriptive only. It does not change generated code or establish an input/output theorem.

## Execute

```bash
python3 .agents/skills/cbmc-harness-scaffold/scripts/generate_harness_scaffold.py \
  --request work/requests/mlk_poly_sub-scaffold.json \
  --repo-root inputs/mlkem-native \
  --output-dir evidence/harness-scaffold/mlk_poly_sub
```

The script never invokes a shell. The optional compiler command is assembled as an argument array and is restricted to syntax checking.

## Generated scaffold shape

The generated C file contains:

```c
/* includes supplied by Codex */

int main(void)
{
  /* uninitialized declarations supplied by Codex */

  /* V5_CODEX_INPUT_PREPARATION_BEGIN */
  /* CODEX: insert task-justified input preparation or nondeterministic setup here. */
  /* V5_CODEX_INPUT_PREPARATION_END */

  /* V5_CODEX_ASSUMPTIONS_BEGIN */
  /* CODEX: insert only explicitly justified assumptions here. */
  /* V5_CODEX_ASSUMPTIONS_END */

  /* V5_TARGET_CALL_BEGIN */
  target(...);
  /* V5_TARGET_CALL_END */

  /* V5_CODEX_ASSERTIONS_BEGIN */
  /* CODEX: insert the selected verification property here. */
  /* V5_CODEX_ASSERTIONS_END */

  return 0;
}
```

The three Codex-edit regions are intentionally empty. Never treat their presence as evidence that assumptions, input construction, or a verification property have been supplied.

## Required outputs

Preserve:

- `canonical_request.json` — validated and normalized caller input;
- `source_manifest.json` — declared source identities and hash matches;
- the generated `.c` scaffold when source bindings pass;
- `scaffold_report.json` — structured neutrality and status report;
- `scaffold_report.md` — human-readable report;
- `scaffold_artifact_manifest.json` — hashes of generated evidence;
- compile-check argv, command display, stdout, stderr, and result when requested.

Validate outputs against the JSON Schemas in `references/` when strict schema validation is available.

## Status and exit codes

- `0`: `COMPLETE` or `COMPLETE_WITH_WARNINGS`;
- `2`: `INCOMPLETE`, for example a source-hash mismatch or required syntax-check failure;
- `3`: request, path, injection, or containment contract error;
- `5`: unexpected internal error.

A successful syntax-only compile check means only that the generated translation unit was accepted under the captured compiler arguments. It does not show that the harness is meaningful, the target is reachable under CBMC, the inputs are valid, or any theorem holds.

## Continue with Codex reasoning

After this skill finishes, inspect its limitations and edit a **working copy** of the scaffold. Codex must independently justify every input preparation statement, assumption, assertion, contract, and verification option it adds. Preserve the untouched scaffold as evidence of what the helper contributed.
