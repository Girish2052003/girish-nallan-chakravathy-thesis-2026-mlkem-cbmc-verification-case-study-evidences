# PBCODEC-CV1 Review-2 Remediation

The first authoritative-closure candidate passed its outer and inner
manifest checks, positive-result checks, non-vacuity checks, mutation
result checks, claim-boundary review and archive-hash review.

However, the first candidate did not include the complete M1 and M2
mutation campaigns. It contained mutation result XML files and mutation
hash records, but omitted the mutant harnesses, Makefiles and GOTO
binding evidence.

This Review-2 candidate remedies that packaging defect by including:

- both mutation harnesses;
- both mutation Makefiles;
- both mutation model-identity records;
- both public-call-order records;
- both loop inventories;
- both property inventories;
- both GOTO binary hash records;
- both CBMC commands;
- both complete XML results;
- both exact-status records;
- both mutation acceptance records;
- the complete portable mutation evidence manifest;
- a source-binding snapshot;
- portable relative hash manifests;
- explicit tool identity.

No CBMC theorem or mutation result was changed or rerun for this
packaging correction.
