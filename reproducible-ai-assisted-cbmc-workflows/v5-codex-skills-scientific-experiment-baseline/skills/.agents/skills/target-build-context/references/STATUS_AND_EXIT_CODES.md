# Status and exit codes

## Report statuses

- `COMPLETE`: a unique target definition was found, all explicitly required identity/build operations succeeded, and no warnings were recorded.
- `COMPLETE_WITH_WARNINGS`: a unique target definition was found, but non-fatal limitations or missing optional context were recorded.
- `INCOMPLETE`: the target definition was missing or ambiguous, an expected target hash mismatched, the selected compile database entry was unavailable or ambiguous, or required preprocessing failed.

None of these statuses means that the implementation is correct or that a verification property is valid.

## Process exit codes

- `0`: `COMPLETE` or `COMPLETE_WITH_WARNINGS` report written.
- `2`: `INCOMPLETE` report written.
- `3`: malformed request, unsafe path, unsupported argument, or contract violation.
- `4`: no supported source files available for inspection.
- `5`: unexpected internal failure.
