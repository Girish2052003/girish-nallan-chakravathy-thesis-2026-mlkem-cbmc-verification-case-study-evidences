# Final 26-Property and Native-Contract Release Approval

## Release relationship

This is a new superseding release built from the frozen eight-session package. The historical predecessor remains unchanged:

```text
SHA-256: 17cbc5bb9d30c960513bde4688ae18146a731b9aa43b5bb7c6df308302bffdf6
```

The predecessor ZIP is retained as evidence and is not modified by this extension.

## Added experiment-family support

The release contains one canonical catalogue for all twenty-six property families in the thesis planning document. Each family has an explicit default verification strategy, supported target classes, expected artefact type, support level and scientific claim boundary.

Six strategy profiles are supported:

1. standard bounded-CBMC harness;
2. relational/two-call CBMC harness;
3. native CBMC loop contract;
4. native CBMC function contract, including optional DFCC/call replacement;
5. hybrid contract plus harness;
6. analysis-only support with no formal proof claim.

## Native contract controls

- Function-contract candidates represent requires, ensures, assigns and frees clauses.
- Loop-contract candidates represent invariant, decreases and loop-assigns clauses.
- Loop annotations are inserted only into copied source files in the run directory.
- Production/repository source files are never modified by the renderer.
- Source anchors must match exactly once.
- Original and copied-source hashes, patch manifests and unified diffs are preserved.
- Agent 6 review is mandatory before native contract transformation.
- Agent 7 records goto-cc, goto-instrument and CBMC steps plus intermediate GOTO model hashes.
- Missing tools, malformed clauses, ambiguous anchors and incomplete transformations fail closed.
- Agent 9 repairs remain candidate-only and must return through Agent 6 review.

## Twenty-six-family boundary

The release can select, prompt, validate, review, execute when applicable, diagnose, repair and report every P01-P26 family. This does not mean every selected property can be automatically proved. In particular:

- P19 is analysis-only and cannot be promoted to a CBMC constant-time proof.
- NTT, top-level API, rejection-sampling and other stretch families may be computationally or modelling intensive.
- Relational properties require deliberately scoped two-call models.
- Native contracts still require valid inductive invariants, sound frames and correct repository build context.

## Regression result

The extension passed:

- strict schema regression;
- canonical configuration regression;
- the complete historical Blockers 3-8 repair-loop suite;
- eight-session architecture conformance;
- deployment/API/build safety gate;
- all-P01-P26 catalogue/configuration tests;
- native loop/function contract rendering and execution-profile tests;
- contract-aware repair and claim-boundary tests;
- orchestrator-level P12 native-loop-contract campaign;
- orchestrator-level P19 analysis-only campaign.

## Deployment boundary

The package is approved for clean installation and local verification. A real API experiment is allowed only after the packaged preflight accepts the exact model, key, repository revision, source/build inputs and required CBMC/GOTO tools.

No result may be described as proof of full ML-KEM correctness, FIPS compliance, cryptographic security or universal contract correctness.
