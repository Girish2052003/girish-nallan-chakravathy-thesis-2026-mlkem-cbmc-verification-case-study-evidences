# Status and exit-code vocabulary

## Report statuses

- `COMPLETE`: every required and optional query matched; no source paths were skipped and no extraction failed.
- `COMPLETE_WITH_WARNINGS`: every required query matched, but at least one optional query missed, result truncation occurred, a path was skipped, or a supported source failed extraction.
- `INCOMPLETE`: at least one required query produced no passage.

These statuses describe retrieval completeness only. None means `ACCEPTED`, `PROOF VALID`, or `IMPLEMENTATION CORRECT`.

## Process exit codes

- `0`: a `COMPLETE` or `COMPLETE_WITH_WARNINGS` report was written.
- `2`: an `INCOMPLETE` report was written.
- `3`: request or path validation failed; no authoritative report should be assumed.
- `4`: no supported source document could be extracted.
- `5`: unexpected internal error.
