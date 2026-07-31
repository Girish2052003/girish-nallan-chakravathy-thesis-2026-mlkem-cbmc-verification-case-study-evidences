# ML-KEM `mlk_kem_check_pk` CBMC campaign evidence

## Scope

This directory contains the classified evidence from the MLKEM768 `mlk_kem_check_pk` clean-room campaign bound to production commit:

```text
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

The campaign's own final closure classifies the work as successfully closed, while explicitly **not** claiming whole-library functional correctness, cryptographic security, constant-time behaviour, proof of every allocator, or a fully concrete two-call seed-noninterference theorem.

## Scientific folder structure

- `00-campaign-setup/`: source admission attempts, native baseline proof output, diagnostics, and redesign gates.
- `T01-validation-semantics/`: actual-body malformed-coefficient rejection and canonical-encoding acceptance evidence.
- `T02-frame-and-relational-properties/`: input-frame, redzone, cleanup-unwind, and the documented contract-abstraction counterexample.
- `T03-prefix-access/`: contract-backed proof that the concrete validator body does not read beyond the polynomial-vector prefix in the selected model.
- `T04-encapsulation-guard/`: stub-backed early validation-failure propagation and caller-side frame preservation for the concrete `mlk_enc_derand` caller body.
- `campaign-closure/`: final campaign closure and verdict-hash records.

Each theorem folder separates authored `curated-harnesses`, generated `raw-evidence`, historical `records-and-early-development`, and final `reports-and-packets` where available.

## Deduplication and preservation rule

Three complete campaign worktrees contained 2,118 common paths with identical SHA-256 values. One representative copy is retained under:

```text
upstream/mlkem-native/pkcheck-af4c5abd-source-snapshot/
```

The other exact worktree mirrors are omitted from the active tree and mapped to the retained copy. Context-bearing duplicate outputs, such as empty stderr files or repeated run-local records, remain when their path is part of a distinct experiment bundle. Nested `.git` database files are not published as an active nested repository; all original bytes remain preserved in the frozen original ZIP under `provenance/kem-check-pk/frozen-baseline/`.

## Audit files

The complete original-to-retained mapping, duplicate classifications, collision report, and checksums are under `provenance/kem-check-pk/`.
