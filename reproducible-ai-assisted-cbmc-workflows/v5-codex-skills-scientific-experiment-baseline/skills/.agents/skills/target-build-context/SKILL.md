---
name: target-build-context
description: Deterministically map a named C implementation target to its local declaration, definition, signature, source hashes, includes, macros, typedef or structure mentions, direct lexical callers and callees, loop headers, array and pointer expressions, and an explicitly supplied build or preprocessing context. Use to inspect exact source/build facts before formal-verification work. Do not use to select properties, infer mathematical bounds, invent aliasing or domain assumptions, write assertions, judge semantic correctness, or repair code.
---

# Target Build Context

Use this skill only for bounded structural inspection of a supplied local C repository. Treat its outputs as lexical and build-context evidence, never as semantic verification authority.

## Scientific boundary

You remain responsible for all reasoning. This skill may:

- enumerate an explicit or bounded local C source scope without following symlinks;
- hash every inspected source file;
- locate lexical declarations and definitions for a named symbol;
- record the target signature and raw parameter text;
- resolve repository-local includes using explicitly supplied include directories;
- report local macro definitions and lexical macro references;
- report typedef and structure declarations whose names occur lexically in the target;
- identify direct lexical callers and callees;
- record loop headers, syntactic bound tokens, array expressions, and pointer-expression candidates;
- normalise an explicit build context or a selected `compile_commands.json` entry;
- optionally run a compiler preprocessor and preserve a bounded target excerpt;
- report ambiguity, missing context, unresolved local inputs, and tool failures;
- write deterministic JSON, Markdown, source manifests, and preprocessing evidence.

This skill must not:

- choose or propose a verification theorem or property;
- infer coefficient, integer, memory, pointer, aliasing, range, or domain assumptions;
- classify a loop as mathematically bounded or safe;
- infer array bounds or pointer validity;
- write CBMC assumptions, assertions, contracts, harnesses, or mutations;
- claim that a caller/callee relationship is semantically complete;
- modify production source or build files;
- compile, link, execute, test, or repair the production program;
- declare an implementation, build, harness, theorem, or proof correct;
- use the internet or a withheld proof corpus.

## Required inputs

Before invoking the script, identify:

1. a local repository root;
2. an output directory outside that repository;
3. a target implementation symbol;
4. preferably the repository-relative source file expected to contain its definition;
5. an explicit build context or an explicit `compile_commands.json` path when preprocessing is requested.

Do not ask the script to discover a verification claim. The target symbol and build facts are inputs; the scientific claim remains your responsibility.

## Request format

Create a request JSON conforming to `references/INPUT_SCHEMA.json`. Prefer a run-specific path such as:

```text
work/requests/mlk_poly_sub-build-context.json
```

Example:

```json
{
  "schema_version": "1.0",
  "request_id": "mlk-poly-sub-context-001",
  "target": {
    "symbol": "mlk_poly_sub",
    "source_file": "src/poly.c"
  },
  "scope": {
    "source_files": [
      "include/poly.h",
      "src/poly.c",
      "src/use_poly.c"
    ],
    "exclude_globs": []
  },
  "build": {
    "mode": "explicit",
    "working_directory": ".",
    "compiler": "gcc",
    "language_standard": "c90",
    "include_dirs": ["include"],
    "defines": [{"name": "MLKEM_K", "value": "3"}],
    "undefines": [],
    "forced_includes": [],
    "extra_args": []
  },
  "options": {
    "preprocess": true,
    "preprocess_required": true,
    "preprocess_timeout_seconds": 30,
    "excerpt_context_lines": 8,
    "max_items_per_category": 500
  }
}
```

A build mode of `none` is allowed when only source structure is needed. In that case the report records that exact preprocessing context was not supplied.

## Execute

Run the bundled deterministic utility with absolute or repository-relative paths:

```bash
python3 .agents/skills/target-build-context/scripts/analyze_target_context.py \
  --request work/requests/mlk_poly_sub-build-context.json \
  --repo-root inputs/mlkem-native \
  --output-dir evidence/target-build-context/mlk_poly_sub
```

The output directory must not be inside the repository. The utility never follows repository-source symlinks and never invokes a shell.

## Exit codes

- `0`: report created with status `COMPLETE` or `COMPLETE_WITH_WARNINGS`;
- `2`: report created with status `INCOMPLETE` because authoritative target/build requirements were not met;
- `3`: request or path contract error;
- `4`: no supported source material could be inspected;
- `5`: unexpected internal error.

Exit code `2` is an evidence outcome, not a tool crash. Inspect the generated report before continuing.

## Required outputs

Always read and preserve:

- `canonical_request.json` — exact normalised request;
- `source_manifest.json` — source identities, decoding status, skipped paths, and scope;
- `compile_context.json` — supplied or selected build context and preprocessing evidence;
- `target_context.json` — structured target/source/build map and limitations;
- `target_context.md` — human-readable report.

When preprocessing succeeds, also preserve:

- `preprocessed_target_excerpt.c` — bounded excerpt around the target definition;
- `preprocess_stdout.sha256` — SHA-256 of the complete preprocessor stdout, whose full body is intentionally not duplicated.

Validate the JSON outputs against `references/OUTPUT_SCHEMA.json` when strict schema validation is available.

## Interpret cautiously

A lexical occurrence establishes only that syntax matching the requested pattern appears in the inspected source. It does not prove:

- semantic completeness of the caller or callee map;
- that a macro value is active at the target site;
- that a loop bound is fixed, sufficient, or safe;
- that an array access is in bounds;
- that a pointer is valid or non-aliasing;
- that the supplied build context reproduces the authoritative project build;
- that the implementation satisfies any specification property.

After inspecting the evidence and limitations, return to your own reasoning. Do not let this skill become a hidden code-understanding agent or property-discovery stage.
