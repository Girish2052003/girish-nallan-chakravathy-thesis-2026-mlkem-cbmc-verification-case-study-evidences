# Final Eight-Q&A Document-to-Code Deployment Approval

**Date:** 10 July 2026  
**Source architecture:** Eight numbered Q&A sessions in `ALL MY QUESTION ANSWERS AND CHATGPT RESPONSES AND COMPLETE A TO Z PLANNING FOR DEVISING THE LLM BACKED API WORKFLOW.docx`  
**Decision basis:** Final explicit decisions and later-session overrides take precedence over temporary earlier proposals.

## Final verdict

- **Architecture/code conformance:** APPROVED.
- **Installation in a new Ubuntu test workspace:** APPROVED.
- **One first controlled real API experiment:** CONDITIONALLY APPROVED only after the packaged bootstrap and operational preflight both pass on the user's Ubuntu VM.
- **Scientific or formal-result preapproval:** NOT GIVEN. A future LLM output, harness, CBMC outcome, or human judgement remains an experimental result.

## Session-level decisions verified

1. The system is a controlled role-specialised LLM-assisted workflow, not an autonomous proof engine.
2. Actual API responses become candidate semantic handoffs in real mode; saved prompts alone do not count.
3. Raw FIPS/source/build evidence outranks prior candidates and deterministic advisory findings.
4. Strict schemas, explicit uncertainty/disagreement records, scoped claim language, and agent-specific trust boundaries are enforced.
5. Existing proof harnesses/templates/prior corrected outputs are comparison-only material; anti-copy checks are heuristic and do not claim 100% novelty.
6. Agents 5, 9, and 11 are mixed stages; Agents 7 and 10 remain deterministic.
7. Each stage separates deterministic references, prompts, candidate LLM output, validation, rendered/tool evidence, and handoff metadata.
8. Session 8 overrides compatibility duplication: every artefact has one canonical physical location, with manifest aliases/pointers rather than copied files.

## Runtime evidence

The final candidate passed:

- all strict-schema tests;
- canonical configuration and conflicting-alias rejection;
- orchestrator/agent CLI contracts;
- critic-to-repair and counterexample-to-repair branches;
- repaired-harness re-review and exact-checksum tool binding;
- unreviewed artefact substitution rejection;
- immutable iteration evidence;
- controlled OpenAI SDK request construction with retry and exact redacted request/response snapshots;
- formal build-plan and old-state/new-state checks;
- anti-copy similarity and critic blocking;
- provenance checks preventing failed/manual runs from looking normally valid;
- dedicated eight-session architecture conformance tests;
- a fresh persistent 11-stage conservative mock run.

The persistent mock run correctly produced:

- process exit code `2`;
- final status `completed_with_failures_or_unresolved_items`;
- no selected-property verification claim;
- review gate `human_review_required`;
- no CBMC execution after the blocked mock review;
- separate critic-triggered repair evidence;
- zero real API calls;
- mock narrative not promoted;
- scientific-result reporting eligibility `false`;
- unqualified success wording `false`;
- human review required `true`.

## Final hardening beyond the previous approval

The document-first reread identified and corrected thirteen literal conformance issues beyond the original twelve defects. The final three reporting corrections were:

1. planned stage-index rows are no longer reported as existing manifests;
2. mock/non-API Agent 11 output cannot be marked as a promoted LLM narrative;
3. mock/no-API runs cannot be marked eligible for scientific-result reporting, and unqualified success wording is always disabled.

## Honest remaining external boundaries

This sandbox has not and cannot certify:

- access permissions of the user's Tampere University API project;
- semantic quality of a real model response on the full selected evidence;
- the user's installed CBMC binary and actual mlkem-native build environment;
- whether a generated candidate harness will compile or pass;
- whether the assumptions/property are scientifically meaningful after human review.

These are why the packaged operational preflight remains mandatory.

## Authorized first-run boundary

Proceed with one first real experiment only after both messages appear locally:

```text
BOOTSTRAP AND LOCAL RELEASE VERIFICATION PASSED
OPERATIONAL PREFLIGHT PASSED
approved_for_one_controlled_first_experiment: true
```

Use a new run ID, `max_iterations = 0`, `force_run = false`, gate approval enabled, exact repository revision and build inputs, and an environment-variable API key.
