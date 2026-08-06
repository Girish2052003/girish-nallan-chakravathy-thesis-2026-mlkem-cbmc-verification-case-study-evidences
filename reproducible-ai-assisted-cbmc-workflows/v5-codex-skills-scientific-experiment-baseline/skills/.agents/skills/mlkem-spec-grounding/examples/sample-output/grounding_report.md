# ML-KEM Specification Grounding Report

- **Skill:** `mlkem-spec-grounding` `1.0.0-rc1`
- **Request ID:** `fixture-valid`
- **Status:** `COMPLETE_WITH_WARNINGS`
- **Target symbol:** `mlk_poly_sub`
- **Target source file:** `mlkem/poly.c`
- **Semantic authority:** None. This report contains lexical retrieval evidence only.

## Boundary statement

The utility did not select a theorem, infer assumptions, write assertions, rank properties, or declare implementation correctness.

## Warnings

- Skipped 1 source path(s); inspect source_manifest.json.

## Query results

### `subtraction` — polynomial subtraction

- Required: `true`
- Mode: `all_terms`
- Matched: `true`
- Passages: `1`
- Raw matching lines: `1`
- Truncated: `false`

#### Passage 1

- Citation: `sample_spec.md:L10-L12`
- Source SHA-256: `276d2144b21af6aeeb3694a710014e6bb8cc275f68b09478763e7bd03c725511`
- Nearest heading: `## 2 Polynomial operations`

```text

Polynomial subtraction computes a result coefficient from corresponding input coefficients.
The operation is interpreted coefficient-wise before any representation-specific reduction.
```

### `modulus` — 3329

- Required: `true`
- Mode: `literal`
- Matched: `true`
- Passages: `2`
- Raw matching lines: `2`
- Truncated: `false`

#### Passage 1

- Citation: `notes.txt:L1-L3`
- Source SHA-256: `59a1e71b2e16f9cad8ae1ecaba8c3f5f50c4b2a37edbb3366ef9e2ad4b1597fa`

```text
Supplementary fixture notes.
The modulus value 3329 appears here as a repeated lexical fact.
No implementation theorem is stated by this fixture.
```

#### Passage 2

- Citation: `sample_spec.md:L6-L8`
- Source SHA-256: `276d2144b21af6aeeb3694a710014e6bb8cc275f68b09478763e7bd03c725511`
- Nearest heading: `## 1 Parameters`

```text

The fixed polynomial degree is 256 and the coefficient modulus is 3329.

```

## Interpretation limit

A match means only that the supplied lexical query matched the supplied local corpus. A non-match does not show that the concept is absent from the specification; different wording, extraction limits, or missing source material may explain it.
