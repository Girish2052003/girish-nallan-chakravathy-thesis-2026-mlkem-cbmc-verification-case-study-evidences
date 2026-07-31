# MSG-01M-R1 — Frozen-Root Lock-Boundary Correction

The first MSG-01M consolidation attempt successfully verified all five
authoritative manifests, then stopped before result-cardinality auditing.

The failed check applied the read-only requirement to the outer container:

```text
/home/girish/THESIS-2026/mlk_poly_tomsg_cleanroom/MSG01G_R1_T1_FROZEN_EXECUTION_INPUT_V1_af4c5abdd595
```

That outer directory contains the terminal capture written after the inner
candidate family was frozen. Its recorded mode was therefore not part of the
frozen-candidate lock promise.

The authoritative MSG-01G-R1 frozen evidence root is:

```text
/home/girish/THESIS-2026/mlk_poly_tomsg_cleanroom/MSG01G_R1_T1_FROZEN_EXECUTION_INPUT_V1_af4c5abdd595/frozen_candidate_v1
```

MSG-01M-R1 verifies that exact root recursively as files `0444` and
directories `0555`. It does not modify either the outer container or the
frozen candidate.

```text
FAILED_MSG01M_CLASSIFICATION=OUTER_DIRECTORY_LOCK_BOUNDARY_FALSE_REJECTION
AUTHORITATIVE_EVIDENCE_FAILURE=NO
CBMC_SOLVING_EXECUTED=NO
GOTO_REBUILD_EXECUTED=NO
SOURCE_MUTATION_EXECUTED=NO
```
