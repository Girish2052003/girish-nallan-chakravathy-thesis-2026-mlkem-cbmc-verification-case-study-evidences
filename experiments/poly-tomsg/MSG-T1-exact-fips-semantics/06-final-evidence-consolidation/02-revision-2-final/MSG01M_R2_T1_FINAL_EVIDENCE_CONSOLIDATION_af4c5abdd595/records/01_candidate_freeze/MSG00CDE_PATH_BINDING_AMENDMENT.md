# MSG-00C–00E Source-Path Binding Amendment

## Amendment reason

The MSG-00C–00E command used the following clean detached source worktree:

```text
/home/girish/THESIS-2026/mlk_poly_tomsg_cleanroom/MSG00B_af4c5abdd595/frozen_source/mlkem-native
```

The authoritative source location selected by the researcher is:

```text
/home/girish/THESIS-2026/mlkem-native_af4c5abd
```

## Commit binding

Both paths were independently verified as clean Git worktrees at:

```text
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

## Equivalence result

All registered critical files used for the `mlk_poly_tomsg`,
`mlk_poly_sub`, `mlk_poly_reduce`, and `indcpa_dec` campaign boundary
were byte-for-byte identical between the two paths.

Therefore, the completed MSG-00C–00E source-delta, oracle, overlap and theorem
freeze results remain technically valid.

## Authoritative path from this amendment onward

```text
/home/girish/THESIS-2026/mlkem-native_af4c5abd
```

All subsequent GOTO construction, harness compilation, source inspection,
body-binding checks and CBMC execution must use this authoritative path.

## Evidence-handling rule

The previously frozen MSG-00C–00E artefacts were not edited or replaced.
This amendment records the path correction separately so the evidence history
remains transparent and reproducible.
