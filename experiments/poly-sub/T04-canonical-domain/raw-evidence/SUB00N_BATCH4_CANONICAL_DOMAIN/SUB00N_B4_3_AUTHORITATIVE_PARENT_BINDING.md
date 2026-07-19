# SUB00N B4.3 — Frozen Authoritative Parent Selection

## Frozen campaign root

`/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3`

## Selected MODE-A manifest

`/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/sub00f_mode_a_execution_freeze_v1/SUB00F_MODE_A_EXECUTION_MANIFEST.md`

SHA-256:

`20f392542441c996ba58e9caddc950ca7d5dd9ed222dc9858077b1a187cb782a`

## Selected successful reference harness

`/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/sub00f_mode_a_execution_freeze_v1/harnesses/sub_t1_semantic_harness.c`

SHA-256:

`42c09c2f004d567d8b886058bd2304d960a219d36f0f6605b015966db3bc5682`

## Selected successful result

`/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00H_T1_PRAGMA_SCOPED_MODE_A_MLKEM768_RUN1/cbmc_result.json`

SHA-256:

`3e78e8c95ccaaedbf3f1b0fc9420192807f4576beec7350dd26a0095ace7f7ba`

## Selection decision

The two discovered MODE-A manifests are byte-identical copies.

The manifest inside the original SUB00F freeze directory is selected.

The successful SUB-T1 CBMC result explicitly references the
read-only harness inside that same freeze directory.

No theorem execution or source modification occurred during B4.3.
