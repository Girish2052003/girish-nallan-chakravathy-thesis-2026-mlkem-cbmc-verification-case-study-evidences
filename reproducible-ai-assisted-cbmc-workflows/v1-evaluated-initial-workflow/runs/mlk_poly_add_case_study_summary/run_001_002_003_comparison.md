# ML-KEM `mlk_poly_add` Case-Study Run Comparison

## Purpose

This table compares the first three `mlk_poly_add` case-study runs. The purpose is to show how the workflow moved from an initial generated candidate artefact, through human correction, to an improved agent-generated harness that passed CBMC for the selected local property.

## Run comparison table

| Run | Role in case study | Artefact source | CBMC status | Main outcome | Main limitation or lesson |
|---|---|---|---|---|---|
| Run 001: `run_001_mlk_poly_add_fresh_baseline` | Baseline deterministic agent run | Initial agent-generated candidate harness | Dry-run / inconclusive | The full pipeline produced structured outputs, critic review, logs, and evaluation material. | The generated functional assertion was not acceptable for an in-place update because it did not snapshot the old value of `r`; the run is evidence of workflow execution and failure-mode discovery, not proof evidence. |
| Run 002: `run_002_mlk_poly_add_human_corrected_cbmc` | Human-corrected verification attempt | Manually corrected CBMC harness | `VERIFICATION SUCCESSFUL` | CBMC successfully checked the selected local coefficient-wise update property under no-overflow assumptions and reconstructed build context. | The correction required human review, repository header/configuration repair, and an unwind adjustment from 256 to 257. |
| Run 003: `run_003_mlk_poly_add_agent_improved_cbmc` | Improved workflow run after Run 002 | Agent-generated harness using human-learned correction pattern | `VERIFICATION SUCCESSFUL` | The improved Agent 5 generated a CBMC-checkable harness with old-value snapshot, no-overflow assumptions, and post-call assertion; CBMC reported zero failed properties. | The result remains scoped to the selected harness/property and does not prove full ML-KEM, full FIPS 203 conformance, or complete mlkem-native correctness. |

## Thesis-safe interpretation

The three runs demonstrate a controlled refinement cycle. Run 001 shows that the initial automated workflow can generate candidate artefacts and expose reviewable failure modes. Run 002 shows that human correction can transform the candidate idea into a CBMC-checkable harness. Run 003 shows that the correction pattern can be transferred back into the workflow so that a later agent-generated harness passes CBMC for the selected local property.

This supports the thesis claim that an AI-assisted formal-methods workflow can be useful for producing candidate formal-verification artefacts when it is combined with critic review, human correction, build-context reconstruction, formal-tool execution, and careful scope control.

## Strict scope boundary

The successful Run 002 and Run 003 results apply only to the selected `mlk_poly_add` harnesses, selected local coefficient-wise update property, stated no-overflow assumptions, reconstructed build context, CBMC settings, and unwind bound. They must not be described as proofs of full ML-KEM, full FIPS 203 conformance, or complete mlkem-native correctness.
