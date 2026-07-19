# SUB00N B4.5 — V1 Failure and V2 Correction Record

## V1 outcome

The first B4.5 preflight attempt stopped during the POSITIVE case's
loop-identifier comparison.

This was not a theorem, coverage, or negative-control failure.

No verification solver was executed.

The temporary POSITIVE GOTO model and inspection outputs were held only
inside the fail-closed staging directory and were removed by the cleanup
trap after the preflight script exited unsuccessfully.

## V1 script defects

The original script incorrectly applied loop discovery to the complete
linked GOTO model. That model intentionally retained unrelated production
functions, so loops from NTT, reduction, multiplication, poly_add and other
functions appeared even though they were unreachable from main.

The original parser also searched every output line with an unanchored
regular expression. It therefore misclassified the staging-path suffix
".tmp.<pid>" as a loop identifier.

## V2 correction

V2 keeps two models per case:

1. The authoritative original GOTO model.
   This remains the later verification input.

2. A reachable-only inspection model produced with:
       goto-instrument --drop-unused-functions

Loop discovery is applied only to the reachable-only inspection model.

The parser accepts only explicit loop-declaration lines beginning with:
       Loop

Paths, diagnostics and unrelated numeric suffixes cannot become loop IDs.

## Integrity boundary

The B4.4 frozen harnesses are unchanged.

The production poly.c source is unchanged.

Batch 3 is untouched.

The failed V1 attempt produced no theorem result and may not be reported
as scientific evidence.
