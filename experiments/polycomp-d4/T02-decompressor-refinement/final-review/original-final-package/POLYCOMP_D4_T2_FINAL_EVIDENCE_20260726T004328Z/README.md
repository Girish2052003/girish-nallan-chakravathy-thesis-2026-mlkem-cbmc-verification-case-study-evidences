# POLYCOMP-D4-T2 Evidence Package

This package contains the clean-room CBMC evidence for the portable-C D4
decompressor refinement theorem.

Recommended reading order:

1. `T2_FINAL_VERDICT.md`
2. `FINAL_VALIDATION.txt`
3. `SHA256SUMS.txt`
4. `metadata/`
5. `campaign_stages/`
6. `proof_artefacts/`

The failed static-count gate in stage 00A is retained as diagnostic provenance.
It counted the `__CPROVER_assert` declaration in addition to the two real
assertion calls. Stage 00B corrected that parser without altering the harness
or production source.
