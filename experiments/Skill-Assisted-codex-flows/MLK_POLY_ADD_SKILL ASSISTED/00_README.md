# MLK_POLY_ADD_SKILL ASSISTED

Compact skill-assisted CBMC corpus for two relational `mlk_poly_add` theorems that are not selected claims in PA-01 through PA-09.

## Run identity

- Campaign runs: **1**
- Authoritative source commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Expected `mlkem/src/poly.c` SHA-256: `f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722`
- Parameter set: ML-KEM-768
- CBMC: 6.9.0
- `goto-cc`: 6.9.0
- Architecture: x86_64 Linux

## Execute

From the frozen `mlkem-native` repository root:

```bash
bash "/absolute/path/MLK_POLY_ADD_SKILL ASSISTED/runner/run_skill_assisted_campaign.sh"
```

The runner creates exactly `evidence/run_1`, builds two GOTO models, records properties, runs the universal proofs, runs `__CPROVER_cover` reachability checks, and emits the final status matrix. It refuses a second run unless `evidence/run_1` is deliberately removed.

## Contents

- `01_A_TO_Z_MLK_POLY_ADD_SKILL_ASSISTED.md`: compact research record.
- `harnesses/`: the two independent theorem harnesses.
- `runner/`: fail-closed execution and result summarisation.
- `ledgers/`: claim, assumption, and expected-artifact mappings.
- `provenance/`: source binding and distinctness audit.
- `manifests/`: package hashes.
