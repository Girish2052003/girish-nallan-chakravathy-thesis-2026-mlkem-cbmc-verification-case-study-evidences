# ZERO-FINAL Run1 Failure Classification

## Classification

`FINAL_EVIDENCE_VERIFIER_PARSER_FAILURE`

## Stage reached

ZERO-FINAL Run1 successfully completed:

- authoritative commit and tree binding;
- source-cleanliness checking;
- ZERO-T1 through ZERO-T4 package SHA-256 checks;
- ZERO-T1 through ZERO-T4 internal-manifest checks;
- ZERO-V1 plan hash revalidation;
- ZERO-V1 result-count revalidation.

It then stopped during per-mutant detector revalidation.

## Cause

The detector check used a multi-line `awk` END rule that was not accepted by
the installed awk implementation:

`awk: syntax error at or near end of line`

This produced verifier false negatives for M1 through M8.

## Meaning

This was not:

- a theorem failure;
- a mutation survivor;
- a CBMC failure;
- a hash mismatch;
- a source-integrity failure.

The mutation campaign remained:

- total mutants: 8;
- killed mutants: 8;
- survived mutants: 0;
- error mutants: 0.

## Correction

ZERO-FINAL Run2 replaces the awk detector matcher with a portable literal
grep pipeline and independently repeats all final package-integrity checks.
