# CBMC JSON normalization boundary

The parser walks the JSON tree and mechanically records recognized fields:

- `cProverStatus`;
- `properties` entries from property inventory output;
- `result` entries containing property IDs, statuses, descriptions, source locations, and trace presence;
- `messageType` and `messageText`.

Status strings are preserved verbatim in each property record. Counts classify only a small explicit vocabulary of success and failure spellings; unfamiliar values remain `unknown`.

The parser does not:

- evaluate expressions;
- reconstruct missing properties;
- infer semantic equivalence;
- diagnose a counterexample;
- judge assertion usefulness;
- treat a missing result as success;
- rewrite raw CBMC output.

The complete raw stdout remains authoritative tool evidence. The normalized summary is only an index over recognized JSON fields.
