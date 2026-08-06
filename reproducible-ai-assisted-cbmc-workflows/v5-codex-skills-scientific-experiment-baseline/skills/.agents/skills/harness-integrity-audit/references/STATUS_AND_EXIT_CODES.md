# Status and exit codes

## Report status

- `COMPLETE`: all enabled checks completed without a `WARNING`.
- `COMPLETE_WITH_WARNINGS`: at least one mechanical warning was recorded.

## Finding status

- `CHECKED`
- `WARNING`
- `NOT_CHECKABLE`

## Process exit codes

- `0`: complete audit, including audits containing warnings;
- `3`: malformed request, unsafe path, missing file, symlink, unsupported diagnostic format, or output-location contract error;
- `5`: unexpected internal error.

A warning does not make the wrapper fail. It remains evidence for Codex and the researcher.
