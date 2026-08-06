# MLK_BARRET_REDUCE_SKILL ASSISTED

Compact one-run CBMC evidence-generation corpus for `mlk_barrett_reduce`.

## Frozen target

- repository: `pq-code-package/mlkem-native`
- current snapshot reviewed: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- source: `mlkem/src/poly.c`
- tools: CBMC/GOTO 6.9.0, GCC 13.3.0, Python 3.12.3

## Execute

From the root of a clean repository checkout at the pinned commit:

```bash
bash "/absolute/path/MLK_BARRET_REDUCE_SKILL ASSISTED/runner/run_skill_assisted_campaign.sh"
```

The runner is fail-closed, accepts exactly one run, leaves production source
untouched, creates proof/coverage/expected-failure GOTO models, and emits the final
requested markings only after every mapping, reachability, feasibility, body-binding,
and completeness gate passes.

Start with `01_A_TO_Z_MLK_BARRET_REDUCE_SKILL_ASSISTED.md`.
