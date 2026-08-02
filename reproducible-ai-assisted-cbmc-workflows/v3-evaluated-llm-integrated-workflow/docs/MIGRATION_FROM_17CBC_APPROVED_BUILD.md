# Migration from the 17cbc Approved Build

## Preserved baseline

The predecessor is retained unchanged as the historical approved package:

```text
SHA-256: 17cbc5bb9d30c960513bde4688ae18146a731b9aa43b5bb7c6df308302bffdf6
```

This extension is a new package. It does not overwrite or mutate the historical ZIP.

## Compatibility rule

A configuration that does not contain `property_campaign` is normalized to:

```json
{
  "property_family_id": "P16",
  "verification_strategy": "standard_cbmc_harness",
  "legacy_compatibility_default": true
}
```

That preserves the predecessor's ordinary bounded-CBMC path.

## New capabilities

- canonical P01–P26 property catalogue;
- property-specific prompts and handoffs;
- native loop contracts and decreases/frame clauses;
- native function requires/ensures/assigns/frees contracts;
- optional DFCC and call replacement;
- relational two-call harness profile;
- analysis-only constant-time support boundary;
- copied-source instrumentation with exact anchors, diffs and hashes;
- multi-step GOTO model execution and intermediate-model checksums;
- property-aware preflight and evaluation reporting.

## What did not change

- LLM candidate outputs are not proof;
- deterministic references remain advisory;
- Agent 6 remains fail closed;
- Agent 7 remains the deterministic tool stage;
- Agent 10 remains a deterministic logger;
- Agent 11 separates facts from interpretation;
- canonical stage-local output and pointer-only handoff rules remain;
- human review remains the final scientific trust boundary.
