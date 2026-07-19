# SUB00N Batch 4 — RUN4 Execution Boundary

## Accepted parent result

The RUN1 positive SUB-T4 theorem passed all 351 properties with explicit
unwinding assertions.

It is not rerun or replaced by RUN4.

## Companion verification

RUN4 uses the B4.8 cover-neutral companion GOTO model.

That model:

- retains the production mlk_poly_sub body;
- retains the original reachability harness logic;
- neutralizes only the five __CPROVER_cover observations;
- exposes exactly 333 substantive verification properties.

The companion proof uses explicit unwinding assertions.

## Actual coverage

Coverage uses the original B4.5 reachability model, not the cover-neutral
companion model.

The coverage command uses the same explicit unwindset but omits
--unwinding-assertions because CBMC coverage mode rejected that explicit
combination in RUN1.

Before solver execution, RUN4 extracts and freezes the exact five coverage
property identifiers using --cover cover --show-properties.

## Negative controls

The original upper and lower negative-control models are executed with
explicit unwinding assertions.

Each must produce exactly one failure at its preregistered intended
property and no other failure.

## Integrity

No production source, frozen harness, prior run, prior diagnostic or
Batch-3 artefact is modified.
