# Provenance for the Polynomial Byte-Codec Campaign

This directory preserves the classification and integrity records for
the supplied `mlk_poly_bytes_codec_cleanroom.zip` archive.

## Preservation policy

All 431 original files were inventoried and SHA-256 hashed before
deduplication. The active scientific tree retains 171 original files.
The remaining 260 files were omitted only where a byte-identical
canonical copy was retained elsewhere. No original byte is lost because
the complete source ZIP is preserved under `frozen-baseline/`.

Thirty retained instances share content with another retained instance.
They remain because their run-specific paths carry distinct experimental
meaning, such as separate model exit-code or empty-stderr records.

## Frozen packages

The supplied harness-freeze and Review-2 closure TAR.GZ packages are
retained with their checksum records. Their archive structures were
successfully read in full during classification. A checksum record for
the first closure-candidate archive is preserved even though that
archive itself was not present as a top-level file in the supplied ZIP;
the supplied expanded first-candidate directory was an exact mirror of
the canonical stage evidence and is mapped in the classification table.

## Result status

The supplied records report successful P1 and P2 obligations, reachable
non-vacuity endpoints, and two killed bridge mutations. The final
Review-2 status supplied by the archive is
`CANDIDATE_PENDING_INDEPENDENT_ACCEPTANCE`; no independent CBMC rerun was
performed during this file-classification task.
