# SUB00N Batch 4 — RUN3 Correction Record

## RUN1

The positive SUB-T4 theorem passed 351 of 351 properties.

The reachability command was rejected during option processing because
coverage mode was combined with explicit unwinding assertions.

No reachability property result was generated.

## RUN2

RUN2 passed its parent-integrity and scientific-parent-binding gates.

It stopped before executing any CBMC case because its runner required an
exact sentence to appear in local `cbmc --help` output.

That wording check was unnecessarily brittle and is removed in RUN3.

## RUN3 policy

RUN3 establishes actual compatibility by executing:

    --cover cover --show-properties

against the frozen reachability model without invoking a solver.

Coverage execution omits an explicit unwinding-assertion option.

Loop completeness and safety are separately established first through a
333-property companion verification with explicit unwinding assertions.

No frozen parent, production source, harness, RUN1 result, RUN2 result or
Batch-3 artefact is modified.
