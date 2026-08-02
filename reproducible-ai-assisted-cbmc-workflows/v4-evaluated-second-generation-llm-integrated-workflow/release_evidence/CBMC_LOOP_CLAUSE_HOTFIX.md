# CBMC 6.9.0 loop-clause acceptance hotfix

The first real Ubuntu gate exposed a synthetic acceptance-fixture error:
function-contract `__CPROVER_assigns(...)` was attached to loop annotations.
CBMC 6.9.0 rejected this before transformation.

The acceptance fixtures now use the loop-contract clause:

```c
__CPROVER_loop_assigns(i, __CPROVER_object_upto(a, sizeof(a)))
```

This correction is applied to both the loop-only and hybrid synthetic fixtures.
The new regression `tests/verify_real_cbmc_loop_clause_syntax.py` executes the
full acceptance script against instrumented fake tools and fails if the loop-
specific clause is absent or the former function-level spelling returns.

This hotfix changes only acceptance tests/release evidence. Frozen Run 001 and
Run 002 evidence remains byte-identical.
