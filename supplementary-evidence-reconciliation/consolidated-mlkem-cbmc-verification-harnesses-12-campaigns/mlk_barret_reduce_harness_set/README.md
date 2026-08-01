# BR-AF4 Barrett-reduce harness collection

This directory is a convenience collection of the canonical harness files
used by the BR-AF4 `mlk_barrett_reduce` campaign.

The original evidence directories remain authoritative and were not moved,
renamed, edited or deleted.

## Directory structure

- `00_upstream_native/` — repository-provided Barrett harness;
- `01_positive_theorems/` — T1 through T5 positive theorem harnesses;
- `02_controls/` — C1 through C5 concrete controls;
- `03_mutation_harnesses/` — isolated false-property and mutant harnesses;
- `metadata/` — origin mapping, hashes, inventory and copy log.

## T3 source-mutant clarification

T3-M1 and T3-M2 did not require independent harness files. Both reused:

`br_af4_t3_quotient_partition_harness.c`

against the isolated production-source mutations:

- `poly_shift_25.c`;
- `poly_shift_27.c`.

Those source-mutant files remain in their original mutation-evidence
directory and are not harnesses.

## Evidence status

This collection does not replace the frozen theorem archives, GOTO models,
CBMC outputs, manifests or forensic verdicts. It only gathers the canonical
C harness sources in one location.
