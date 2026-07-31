# MSG-T1 Campaign History and Correction Record

## Clean-room and source binding

The campaign began by binding the clean-room work to the authoritative
mlkem-native source commit and production source hashes. The path-binding
amendment records that the critical files were byte-identical across the
examined source locations.

## Candidate development

Early candidates were rejected at preflight for static-audit, namespace or
structural reasons. These were not functional counterexamples.

MSG-01F produced the accepted direct-pragma candidate. MSG-01G initially
misclassified retained arithmetic checks; MSG-01G-R1 corrected that audit and
froze the accepted candidate before solving.

## Positive proof

MSG-01H executed the frozen positive model and obtained an all-success result.

## Reachability and non-vacuity

MSG-01I initially compared raw call graphs without accounting for the original
model’s cover primitive. MSG-01I-R1 corrected that instrumentation-aware
comparison.

MSG-01J attempted to derive symbolic-execution unwinding properties from a
static inventory. MSG-01J-R1 corrected the derivation but still expected
standalone full-bound unwind records. Diagnostic evidence showed no such
records because the full bounds were not reached.

MSG-01J-R2 introduced insufficient-bound controls. One macro-origin loop was
incorrectly expected to fail at bound one. MSG-01J-R3 bound every target loop
to its exact source statement, classified that loop correctly, completed the
remaining controls and obtained twelve-of-twelve coverage.

## Mutation sensitivity

The first combined MSG-01K/L attempt used permission-preserving copies of
read-only frozen files. Mutation generation stopped before any mutant model
was built or solved.

MSG-01K-R1 corrected the isolated-copy method while preserving all
authoritative frozen inputs. It froze eight validated non-equivalent mutants
before solving. MSG-01L-R1 then killed all eight with the exact MSG-T1
assertion.

## Final consolidation corrections

The first MSG-01M attempt verified all five authoritative manifests but applied
the read-only check to the MSG-01G-R1 outer container instead of the inner
frozen-candidate root. MSG-01M-R1 corrected that evidence boundary, but then
searched an in-pipeline terminal capture for a status printed only after the
pipeline closed. MSG-01M-R2 corrects that provenance-location check. No proof,
GOTO model, source file, accepted result, manifest or lock rule was changed.

## Scientific treatment of corrections

Rejected attempts are preserved as provenance. No rejected result is presented
as a theorem failure. No accepted theorem was obtained by deleting a failing
property, weakening the canonical domain, suppressing an unexpected
counterexample, changing the authoritative production source, or bypassing a
failed mutation.
