# Mutation results

## M4: implementation mutation

An isolated copy of `mlk_poly_reduce_c` was changed so the Barrett-reduction
loop omitted coefficient 255. The production worktree, accepted positive
control, assumptions and independent oracle remained unchanged.

Result: `FAIL_EXPECTED_MUTANT_KILLED`.

## M5: assertion mutation

Production code remained unchanged. Only the canonical expected value in an
isolated harness copy was shifted by `+1 modulo 3329`.

Result: `FAIL_EXPECTED_MUTANT_KILLED`.

M5 contained 90 properties rather than 89 because the inserted `+1U`
expression introduced one additional harness safety obligation. The intended
assertion was the sole failed target; non-target and unwinding failure counts
were zero.
