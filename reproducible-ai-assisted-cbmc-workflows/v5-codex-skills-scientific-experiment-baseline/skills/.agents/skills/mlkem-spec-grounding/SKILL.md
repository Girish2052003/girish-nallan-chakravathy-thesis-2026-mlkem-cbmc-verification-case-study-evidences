---
name: mlkem-spec-grounding
description: Locate, extract, hash, and cite passages from a supplied local ML-KEM specification corpus for a named implementation target and user/Codex-supplied lexical queries. Use for specification grounding, constants, parameter definitions, algorithm text, equations, encodings, and representation rules. Do not use to select verification properties, infer assumptions, write assertions, rank theorems, diagnose code, or declare correctness.
---

# ML-KEM Specification Grounding

Use this skill only for bounded evidence retrieval from a local specification corpus. Treat all outputs as lexical grounding evidence, never as semantic or scientific authority.

## Scientific boundary

You remain responsible for all reasoning. This skill may:

- read a supplied local specification package;
- hash the source files;
- search explicit lexical queries that you or the researcher selected;
- extract bounded passages with line and, for PDFs, page information;
- report missing matches, skipped files, extraction failures, and uncertainty;
- write deterministic JSON and Markdown evidence.

This skill must not:

- choose or propose a theorem or verification property;
- infer coefficient, pointer, aliasing, range, or domain assumptions;
- write CBMC assumptions, assertions, contracts, harnesses, or mutations;
- rank candidate properties;
- convert a textual specification statement into a C-level claim;
- declare that an implementation, harness, theorem, or proof is correct;
- use the internet or a withheld proof corpus;
- modify the specification corpus or production source tree.

## Required inputs

Before invoking the script, identify:

1. a local specification corpus directory;
2. an output directory outside that corpus;
3. a target implementation symbol;
4. an optional target source-file label;
5. one or more explicit grounding queries selected by you or the researcher.

The query selection is not delegated to the script. If the task does not provide concepts, choose queries as part of your own reasoning and record them transparently in the request JSON.

## Request format

Create a request JSON that conforms to `references/INPUT_SCHEMA.json`. Prefer a run-specific path such as:

```text
work/requests/mlk_poly_sub-grounding.json
```

Example:

```json
{
  "schema_version": "1.0",
  "request_id": "mlk-poly-sub-grounding-001",
  "target": {
    "symbol": "mlk_poly_sub",
    "source_file": "mlkem/poly.c"
  },
  "queries": [
    {
      "id": "polynomial-subtraction",
      "text": "polynomial subtraction",
      "mode": "all_terms",
      "required": true
    },
    {
      "id": "modulus-3329",
      "text": "3329",
      "mode": "literal",
      "required": false
    }
  ],
  "options": {
    "case_sensitive": false,
    "context_lines": 3,
    "max_matches_per_query": 25
  }
}
```

Supported query modes:

- `literal`: the complete query string must occur in one extracted line;
- `all_terms`: every alphanumeric query term must occur in one extracted line;
- `any_term`: at least one alphanumeric query term must occur in one extracted line.

Do not use `any_term` merely to manufacture broad or favourable evidence. Use it only when broad lexical recall is genuinely intended and record that choice.

## Execute

Run the bundled deterministic utility with absolute or repository-relative paths:

```bash
python3 .agents/skills/mlkem-spec-grounding/scripts/ground_spec.py \
  --request work/requests/mlk_poly_sub-grounding.json \
  --spec-root inputs/specification \
  --output-dir evidence/spec-grounding/mlk_poly_sub
```

The output directory must not be inside the specification corpus. The utility never follows source-corpus symlinks.

## Exit codes

- `0`: report created with status `COMPLETE` or `COMPLETE_WITH_WARNINGS`;
- `2`: report created with status `INCOMPLETE` because at least one required query had no match;
- `3`: request/path contract error;
- `4`: no supported source material could be extracted;
- `5`: unexpected internal error.

Exit code `2` is an evidence outcome, not a tool crash. Inspect the generated report before continuing.

## Required outputs

Read and preserve:

- `canonical_request.json` — exact normalised request;
- `source_manifest.json` — source hashes, extraction methods, skipped paths, and failures;
- `grounding_report.json` — structured query results and limitations;
- `grounding_report.md` — human-readable passages and citations.

Validate the JSON structure against `references/OUTPUT_SCHEMA.json` when strict schema validation is available. Never discard the raw report merely because a query did not match.

## Interpret cautiously

A lexical match establishes only that the supplied query matched the supplied local corpus. It does not prove:

- semantic equivalence between the passage and the implementation;
- that a proposed assumption is justified;
- that a candidate property is meaningful;
- that CBMC has proved the complete function correct.

A non-match also does not establish absence. Different terminology, poor PDF extraction, or an incomplete corpus may explain it.

After presenting the grounding evidence and uncertainties, return to your own reasoning. Do not let this skill become a hidden property-discovery stage.
