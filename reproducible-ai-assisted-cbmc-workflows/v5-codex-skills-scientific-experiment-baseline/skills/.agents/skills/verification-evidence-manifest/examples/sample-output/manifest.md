# Verification Evidence Manifest

- Run ID: `run-vector-subtract-001`
- Target: `vector_subtract`
- Manifest status: `COMPLETE`
- Semantic authority: `NONE`
- Gate authority: `NONE`

> This status describes evidence-manifest completeness only. It does not establish theorem validity, implementation correctness, novelty, or scientific acceptance.

## Source revision

- Kind: `GIT_COMMIT`
- Value: `0123456789abcdef0123456789abcdef01234567`
- Evidence path: `source/revision.txt`

## Property records supplied by Codex

### `vector-subtract.component`

For each valid index i, result[i] equals left[i] minus right[i] under the harness assumptions.

- Codex-supplied status: `CHECKED_IN_CAPTURED_CBMC_RUN`
- Provenance: `{'path': 'property/property.md', 'line_start': 3, 'line_end': 3}`

## Final status supplied by Codex

- Value: `CANDIDATE_RUN_COMPLETED`
- Notes: `Preserved as a Codex-supplied declaration; not evaluated by this skill.`
- Authority: `CODEX_SUPPLIED_UNVERIFIED`

## Evidence summary

- Declared artefacts: 11
- Present artefacts: 11
- Required-role gaps: 0
- Assumptions inventoried: 1
- Assertions inventoried: 2
- JSON fields requested: 7
- JSON fields found: 7
- Skill-labelled artefacts: 5
- Iterations represented: 2

## Evidence by role

| Role | Declared | Present | Hash-consistent |
|---|---:|---:|---:|
| `BUILD_CONTEXT_EVIDENCE` | 1 | 1 | 1 |
| `CBMC_COMMAND` | 1 | 1 | 1 |
| `CBMC_EXECUTION_SUMMARY` | 1 | 1 | 1 |
| `CBMC_RAW_STDOUT` | 1 | 1 | 1 |
| `ENVIRONMENT_SNAPSHOT` | 1 | 1 | 1 |
| `HARNESS` | 1 | 1 | 1 |
| `OTHER` | 1 | 1 | 1 |
| `PROPERTY_RECORD` | 1 | 1 | 1 |
| `REPAIR_LOG` | 1 | 1 | 1 |
| `SOURCE_REVISION_EVIDENCE` | 1 | 1 | 1 |
| `SPECIFICATION_EVIDENCE` | 1 | 1 | 1 |

## Warnings and gaps

No warnings were recorded.

## Raw evidence

See `input_file_manifest.before.json`, the caller-declared artefact paths, and the supporting inventory files. Raw evidence remains authoritative over this index.

## Mandatory limitations

- The skill does not execute or reinterpret CBMC.
- Harness claims are lexical call inventories, not semantic justification.
- Skill use and repair iteration are caller-declared labels, not inferred agent behavior.
- A complete manifest is not a valid proof, correct implementation, useful theorem, novel result, or accepted experiment.
