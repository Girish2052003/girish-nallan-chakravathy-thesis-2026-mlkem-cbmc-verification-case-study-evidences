# Run 003 Result Summary: Improved Agent-Generated CBMC Harness for mlk_poly_add

## Run identity

- Run ID: run_003_mlk_poly_add_agent_improved_cbmc
- Target scheme: ML-KEM
- Target implementation function: mlk_poly_add
- Verification tool: CBMC
- Generated artifact: 04_generated_harness.c
- Harness function: harness_mlk_poly_add
- Final status: passed_selected_properties

## Purpose

This run evaluates whether the artifact-generation workflow could be improved after the human-corrected Run 002 result.

The improved Agent 5 template generated a CBMC harness for mlk_poly_add using the Run 002 correction pattern:

- local mlk_poly r and b objects;
- nondeterministic initialization of both r.coeffs and b.coeffs;
- old_r_coeffs snapshot before the function call;
- documented no-overflow assumptions;
- call to mlk_poly_add(&r, &b);
- post-call assertion comparing final r against old_r + b.

## Final CBMC result

- CBMC execution status: executed
- CBMC return code: 0
- Verification result: VERIFICATION SUCCESSFUL
- Failed properties: 0
- Successful properties: 228
- Counterexample available: false
- Unwind bound: 257
- Object bits: 8

## Thesis-safe interpretation

Run 003 provides evidence that the workflow was improved after human review. The improved Agent 5 generated a CBMC-checkable harness for the selected mlk_poly_add property, and CBMC reported success under the recorded assumptions and build context.

This does not prove full ML-KEM, full FIPS 203 conformance, or complete mlkem-native correctness. The result applies only to the selected harness, selected local property, stated assumptions, and recorded CBMC configuration.

## Research significance

Run 003 is important because it shows a complete refinement cycle:

1. Run 001 generated a candidate harness but exposed assertion and setup weaknesses.
2. Run 002 used human correction to construct a successful harness.
3. Run 003 transferred the Run 002 correction pattern back into the workflow.
4. The improved workflow generated a harness that CBMC accepted for the selected property.

This supports the thesis claim that an AI-assisted formal-methods workflow can generate useful candidate artifacts when combined with critic review, human correction, and formal-tool feedback.
