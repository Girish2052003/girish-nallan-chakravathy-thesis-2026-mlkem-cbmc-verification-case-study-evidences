# V5 Architecture and Skill Boundaries

## Architectural principle

V5 uses one principal repository-aware Codex agent. Optional deterministic skills may retrieve, map, scaffold, execute, parse, audit, probe, organise, or reproducibly apply caller-designed mutations. They do not select the theorem, invent substantive assumptions, design assertions, diagnose semantic causes, select repairs, or declare scientific validity.

## Common experiment shell

Both assisted and unassisted conditions must receive equivalent frozen inputs, environment, sandbox, resource policy, event capture, artefact preservation, post-run anti-copy analysis, and external evaluation. Observability surrounds Codex; it does not orchestrate Codex.

## Skills

| Skill | Bounded mechanical role | Explicitly excluded semantic role |
|---|---|---|
| `mlkem-spec-grounding` | Local specification retrieval, hashing and traceability | Property selection or theorem formulation |
| `target-build-context` | Lexical source/build mapping and preprocessing evidence | Safety, bounds or assumption inference |
| `cbmc-harness-scaffold` | Neutral C/CBMC wiring | Assumption/assertion/property generation |
| `cbmc-execute` | Exact tool execution and raw evidence preservation | Strategy selection or proof interpretation |
| `cbmc-counterexample-view` | Bounded trace presentation | Diagnosis or repair recommendation |
| `harness-integrity-audit` | Structural red-flag checks | Acceptance, rejection or semantic criticism |
| `cbmc-nonvacuity-probe` | Disposable bounded reachability probes | Theorem-validity judgment |
| `verification-evidence-manifest` | Evidence indexing and completeness warnings | Grading, novelty or conclusions |
| `controlled-mutation-runner` | Apply Codex-designed patches on disposable copies | Mutation invention or property-strength judgment |

## Experimental conditions

- Condition A: Codex without V5 skills.
- Condition B: Codex with Skills 1–8 available.

Skill availability is optional assistance, not a mandatory stage sequence.
