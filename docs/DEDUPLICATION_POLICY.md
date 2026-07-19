# Conservative deduplication policy

Byte equality alone is not sufficient to classify two scientific artifacts as redundant. Files from different executions may legitimately contain the same bytes while documenting separate runs.

A file was omitted only when all of the following held:

1. SHA-256 and size were identical;
2. both paths normalized to one explicitly recognized mirror identity;
3. one preferred authoritative location remained;
4. the omitted path was recorded in the original-to-retained provenance map.

All other byte-identical files were retained as distinct contextual evidence.
