# MSG-00D — Repository and Prior-Campaign Overlap Classification

## Source identities

- Previous SUB-T6 commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- New MSG campaign commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- New source worktree: `/home/girish/THESIS-2026/mlk_poly_tomsg_cleanroom/MSG00B_af4c5abdd595/frozen_source/mlkem-native`

## Historical correction

SUB-T6 was completed at the older commit. It was a caller-oriented
subtract–reduce handoff and bounded-slice campaign, not an exact functional
verification of the 32-byte output of `mlk_poly_tomsg`.

The old `tomsg` harness established:

1. exact subtraction before reduction;
2. canonical coefficient bounds before `mlk_poly_tomsg`;
3. execution and bounded safety of the downstream function;
4. preservation of the polynomial input.

It did not assert the value of any output byte or output bit.

## New-family classification

### MSG-T1 — Exact FIPS message-decoding refinement

Classification: **NEW IMPLEMENTATION-LEVEL FUNCTIONAL CAMPAIGN**

Overlap boundary:

- FIPS Compress1 is an existing mathematical specification.
- `mlk_scalar_compress_d1` already has a functional production contract.
- The old T6 campaign did not compare the complete 32-byte output against an
  independent oracle.

### MSG-T2 — Functional separability and bit locality

Classification: **NEW RELATIONAL CBMC MODEL**

This family uses two symbolic executions. It does not claim constant-time,
timing non-interference, leakage freedom or side-channel security.

### MSG-T3 — Output-initialization independence and exact state footprint

Classification: **PARTIALLY OVERLAPPING**

- Polynomial-input preservation is inherited prior evidence and must be
  revalidated at the new commit.
- Initial-output independence, complete overwrite, output guard preservation
  and complete harness-owned-state footprint are new registered obligations.

### MSG-T4 — Canonical-difference-to-message functional composition

Classification: **PARTIALLY OVERLAPPING, FUNCTIONALLY STRENGTHENED**

The old campaign proved subtraction, canonical handoff and bounded slice
safety. The new family must prove the exact canonical residue and the final
message bits against an independent oracle.

## Prohibited claims

The campaign must not claim:

- discovery of the FIPS Compress1 equation;
- the first formal analysis of any function named `poly_tomsg`;
- constant-time or side-channel freedom;
- complete K-PKE decryption correctness;
- universal absence of related unpublished work;
- that all 25 obligations are newly invented mathematical theorems;
- that an older-commit CBMC verdict automatically transfers to the new commit.

## Permitted contribution claim

The contribution is an independently specified, commit-bound CBMC campaign
that executes the frozen production C implementation and checks new
functional, relational, state-transformation and canonical-difference
message-refinement obligations using explicit controls and reproducible
evidence.
