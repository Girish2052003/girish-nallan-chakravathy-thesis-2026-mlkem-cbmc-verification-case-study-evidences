# Release Provenance and Approval Boundary

## Relationship to the frozen predecessor

This is a **new superseding extension**, not an in-place modification of the historical approved ZIP.

```text
Predecessor: PIPELINE_EIGHT_QA_DOCUMENT_VERIFIED_FINAL_2026-07-10.zip
SHA-256: 17cbc5bb9d30c960513bde4688ae18146a731b9aa43b5bb7c6df308302bffdf6
Predecessor mutated: no
```

The predecessor remains independently reproducible. This release adds a property-campaign layer, native CBMC loop/function-contract artefacts, relational profiles, analysis-only routing, contract-aware review/repair, and strategy-aware tool execution.

## Meaning of P01–P26 support

Support means that a property family can be selected, represented in prompts and structured handoffs, validated, reviewed, routed to its intended deterministic execution or analysis profile, preserved through diagnosis/repair, and reported with its scientific boundary. It does **not** guarantee that an LLM will discover a correct invariant or contract, that generated artefacts compile, that CBMC terminates, or that a property passes.

## Native-contract trust boundary

- Loop annotations are inserted only into copied run-local source files.
- Repository source is never rewritten by the renderer.
- Exact anchors, diffs, input/output hashes and intermediate GOTO-model hashes are preserved.
- Agent 6 must approve the exact artefact hash before Agent 7 executes it.
- GOTO transformation success is model-construction evidence, not property success.
- CBMC success is scoped to the exact transformed model, clauses, assumptions, source revision and options.

## Special property boundaries

- P19 remains analysis-only; the pipeline must not label it a CBMC constant-time proof.
- P23 checks modeled post-call bytes; it does not establish compiler-resistant or physical erasure.
- P24 checks scoped modeled determinism; it does not establish Keccak correctness or cryptographic security.
- P07, P11, P14, P18 and P20 are stretch families whose feasibility depends heavily on repository build context and tractable models.

## Sandbox limitations

The release tests exercise the OpenAI SDK path using a controlled local transport and exercise CBMC/GOTO command construction, sequencing, failure handling and model hashing using controlled tool substitutes. No university API key was used, and the sandbox did not contain real `cbmc`, `goto-cc` or `goto-instrument` binaries. The packaged operational preflight must therefore pass on the user's Ubuntu VM before any real experiment.
