# Status and Exit Codes

## Manifest status

- `COMPLETE`: all required artefacts/roles are available and hash-consistent, inputs remained unchanged, and no warnings were recorded.
- `COMPLETE_WITH_WARNINGS`: required evidence is available and hash-consistent, but optional, parsing, provenance, or scan warnings exist.
- `INCOMPLETE`: required evidence is missing/hash-inconsistent or an input changed during processing.

These values describe manifest completeness only.

## Process exit codes

- `0`: manifest produced with `COMPLETE` or `COMPLETE_WITH_WARNINGS`.
- `2`: manifest produced with `INCOMPLETE`.
- `3`: request or path contract error; no valid manifest claim is made.
- `4`: unexpected processing error.
