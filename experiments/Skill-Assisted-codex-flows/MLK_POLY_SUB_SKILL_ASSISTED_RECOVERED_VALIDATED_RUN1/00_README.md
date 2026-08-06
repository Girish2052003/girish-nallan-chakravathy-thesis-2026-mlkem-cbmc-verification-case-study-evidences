# MLK_POLY_SUB_SKILL ASSISTED

This compact corpus defines and operationalises two relational CBMC theorems for the unchanged production `mlk_poly_sub` body at the frozen ML-KEM-768 source state.

## Selected theorems

1. **SA-SUB-T1 — Common-minuend difference reversal**

   `(a - b) - (a - c) = c - b`

2. **SA-SUB-T2 — Sequential-subtrahend aggregation equivalence**

   `(a - b) - c = a - (b + c)`

The selected claims deliberately exclude the earlier SUB-T1–SUB-T6 families: direct semantic refinement, normalization compatibility, exact and modular cancellation, canonical boundaries, frame/locality/non-interference/determinism, and the `sub → reduce → tomsg` caller slice.

Run exactly once from the frozen `mlkem-native` repository root:

```bash
bash "/absolute/path/MLK_POLY_SUB_SKILL ASSISTED/runner/run_skill_assisted_campaign.sh"
```

The runner fails closed on source, toolchain, proof, reachability, selected-claim mapping, distinctness, or artefact-completeness defects.
