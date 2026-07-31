# MSG-01J-R1 — Unwinding-Property Derivation Correction

The first MSG-01J attempt stopped before CBMC execution because it attempted to
extract symbolic-execution unwinding assertions from the static
`--show-properties` inventory.

Unwinding assertions are generated during CBMC symbolic execution.

MSG-01J-R1 derives the five expected property identifiers directly from the
five frozen loop identifiers and then requires those exact properties to occur
with `SUCCESS` status in the companion JSON result.

```text
FAILED_MSG01J_CLASSIFICATION=PRE_EXECUTION_UNWIND_PROPERTY_DERIVATION_FALSE_REJECTION
COMPANION_PROOF_EXECUTED=NO
ORIGINAL_MODEL_COVERAGE_EXECUTED=NO
FUNCTIONAL_COUNTEREXAMPLE=NO
```
