# CANON Control Registry

## CANON-G1 — Source binding

The pinned commit, clean-tree status and relevant source hashes must match the
frozen CANON-00B record.

## CANON-G2 — Target reachability

The actual production target body must be reachable and return.

## CANON-G3 — Domain reachability

Negative, zero and positive target-input classes must each be independently
reachable.

## CANON-G4 — Anti-vacuity and forbidden transformations

The campaign rejects:

- `assume(false)`;
- contradictory assumptions;
- unreachable implication antecedents;
- tautological assertions;
- target stubs;
- copied target bodies;
- unauthorized function-contract replacement;
- production-code modification.

## CANON-G5 — Actual-body composition binding

For CANON-T4, the reachable function model must contain the actual production
bodies of both Barrett reduction and the signed-to-unsigned converter.

## CANON-G6 — Safety and oracle integrity

Required checks include applicable:

- signed overflow;
- unsigned overflow;
- conversion safety;
- shift safety;
- division and modulo safety;
- undefined behaviour;
- assertion reachability;
- model validation;
- undefined-function inspection;
- independent-oracle review.
