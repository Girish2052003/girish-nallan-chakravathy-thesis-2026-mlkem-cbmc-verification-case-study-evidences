# ML-KEM scalar signed-to-unsigned canonicalization campaign

This directory classifies the supplied clean-room evidence for
`mlk_scalar_signed_to_unsigned_q` at pinned mlkem-native commit
`af4c5abdd5958bdc65a03cd5ee86708264f93304`.

The supplied campaign registers four theorem families:

- T1: exact fibres and equivalence classes;
- T2: retraction, idempotence, fixed points and injectivity;
- T3: modular addition, subtraction and negation compatibility;
- T4: actual-body composition with `mlk_barrett_reduce`.

The campaign closure supplied by the user classifies all four families as
accepted, with 17 registered semantic properties, 41 non-vacuity coverage
goals and 12 targeted mutants. These are source-reported results; this
classification operation did not rerun CBMC.

## Layout

- `00-campaign-setup/`: preregistration, source binding, build-model evidence,
  validator limitations/recovery, and early T1 development;
- `T01-*` through `T04-*`: positive runs, final evidence, mutation evidence and
  retained worktree deltas;
- `campaign-closure/`: final family status, result matrices, claim boundary and
  master manifests.

Full source/worktree mirrors and generated example-local copies are not
repeated in the active tree. They remain byte-for-byte available in the frozen
original archive under `provenance/scalar-signed-to-unsigned-q/frozen-baseline/`, and every original
path is accounted for in the provenance mapping tables.
