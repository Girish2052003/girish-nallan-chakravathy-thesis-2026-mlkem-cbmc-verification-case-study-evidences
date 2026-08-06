# Boundary and Evidence Catalogue

## Permitted mechanical work

- Hash explicitly declared files.
- Preserve caller-declared roles, skill labels, iterations, properties, and final status.
- Lexically inventory configured C assumption/assertion calls.
- Extract caller-selected JSON Pointer values.
- Group evidence by role, skill label, and iteration.
- Warn about missing files/roles, hash mismatches, parsing limits, unlisted files, and input mutation.

## Forbidden semantic work

- No property discovery, ranking, strengthening, weakening, or repair.
- No inference that an assumption is justified or an assertion is meaningful.
- No execution or interpretation of CBMC, compiler, GOTO, or shell commands.
- No acceptance/rejection, grading, novelty claim, or thesis conclusion.

## Role catalogue

The request may classify artefacts as source revision, specification evidence, build context, harness, CBMC command/raw output/summary, counterexample view, integrity audit, non-vacuity report, Codex event log, skill output, environment snapshot, repair log, final-status record, property record, or other.

These are caller-declared organizational labels. They do not change the authority of the underlying artefact.
