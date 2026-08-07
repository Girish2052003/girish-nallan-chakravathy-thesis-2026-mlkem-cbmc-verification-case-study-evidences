# RC2 post-installation path reconciliation

The first live finalization attempt failed closed with:

- investigation roots: 5/18;
- principal summaries: 18/18 hash-matched;
- substantive-property evidence: 257/257 hash-matched;
- representative artefacts: 572/573 hash-matched.

The thirteen unresolved roots resulted from a locator mismatch between original
source-archive root names and the classified public repository layout.

The public repository deliberately contains similarly named directories under
`experiments/`, `provenance/`, and `reports/`. Therefore basename-only root
matching was insufficient. The live locator was corrected to resolve explicit
repository-relative `experiments/...` paths while preserving the original
archive-root provenance fields unchanged.

One Case-2 solver-replay result was also absent byte-for-byte from the public
mapping selected during the first run. The existing public result was preserved.
The audited archive entry was restored separately as supplementary evidence.

Restored SHA-256:

2f343feed2641f76c91b8b18a1dc8dce412054cb366bc6c60ad81100e7c13b16

No pre-RC2 tracked evidence file was modified or deleted.
