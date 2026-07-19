# ML-KEM / CBMC full classified evidence baseline

This directory is a **conservative reorganization** of the frozen `EXPIREMENTS.zip` archive.

## Preservation boundary

- Original archive files: **7935**
- Files physically retained from the original archive: **7466**
- High-confidence mirror copies replaced by provenance references: **469**
- Same-content files retained because they belong to distinct scientific contexts: **3878**
- Original archive SHA-256: `b200e1de7abd6866ad002f0f00ee9315ca6f98c4aac1e65c4d44c12fb59ec813`

No file was removed merely because its bytes matched another run's output. Separate results, exit codes, logs, manifests, source freezes, failed attempts, expected-failure controls, and mutation evidence remain present when their original paths represent distinct contexts.

Only two explicitly recognized mirror families were deduplicated:

1. the convenience source copy under `OUTPUT TXT FILES( POLY ADD, SUB)/source/` when the same tracked source path exists under the SUB00A source snapshot;
2. T6 stage directories copied both beside and inside the authoritative `SUB00R_BATCH6_T6_CALLSITE_INTEGRATION` campaign.

Every original path is represented in `provenance/original-to-retained-map.tsv`. A removed mirror path points to the retained physical file with the same SHA-256.

## Scientific organization

- `experiments/poly-add/`: PA01–PA09 evidence, curated records, raw runs, and terminal transcripts.
- `experiments/poly-sub/`: campaign setup and T01–T06 evidence.
- `upstream/mlkem-native/`: tracked source snapshot and the distinct VC-SR1 full frozen source snapshot.
- `support/`: development scripts and cross-campaign transcripts.
- `reports/`: campaign-wide and novelty reports.
- `provenance/`: complete maps, hashes, duplicate decisions, and classification summaries.

This is the correct baseline for later Git/Git-LFS preparation. It intentionally contains large raw evidence files.
