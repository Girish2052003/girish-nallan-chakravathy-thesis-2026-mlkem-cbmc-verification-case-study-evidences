# Selected theorem list

## SA-ZERO-T1 — Whole-object secret-history convergence

**Preconditions:** valid non-empty interval; objects equal outside it; arbitrary
selected contents with at least one difference.

**Postconditions:** selected bytes are zero in both objects; both outer frames
are preserved; complete post-state objects are identical.

## SA-ZERO-T2 — Recovery after symbolic recontamination

**Preconditions:** valid non-empty outer interval; valid nested repair subrange;
nonzero initial and rewritten witnesses.

**Postconditions:** the entire outer interval is zero after the second call;
the original outer frame and second-call frame are preserved; the rewritten
witness is erased.
