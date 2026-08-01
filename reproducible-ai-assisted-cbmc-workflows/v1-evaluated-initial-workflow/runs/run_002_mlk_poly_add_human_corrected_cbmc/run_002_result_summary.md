# Run 002 Result Summary: mlk_poly_add Human-Corrected CBMC Harness

## Run identity

- Run ID: run_002_mlk_poly_add_human_corrected_cbmc
- Target scheme: ML-KEM
- Target implementation function: mlk_poly_add
- Verification tool: CBMC 6.9.0
- Harness: mlk_poly_add_human_corrected_harness.c
- Final command file: cbmc_command_v6.txt
- Final CBMC output: cbmc_output_v6.txt

## Purpose

This run checks a scoped, human-corrected CBMC harness for the local implementation-level behaviour of `mlk_poly_add`.

The checked property is that, under the documented no-overflow preconditions, the in-place output satisfies:

r.coeffs[i] == old_r.coeffs[i] + b.coeffs[i]

for each coefficient index i in 0..MLKEM_N-1.

## Important setup corrections

The first CBMC attempts did not reach verification because the local input context was missing repository build/configuration headers. The following context was added:

- mlkem_native_config.h copied from the CBMC proof configuration.
- missing mlkem-native headers refreshed into inputs/code.
- fips202 headers copied into inputs/code/fips202.
- unwind bound increased from 256 to 257 after an unwinding assertion failure.

## Final CBMC result

- Final command: cbmc_command_v6.txt
- Final exit code: 0
- Final result: VERIFICATION SUCCESSFUL
- Failed properties: 0
- Reported checked properties: 228

## Thesis-safe interpretation

This run provides evidence that a human-corrected CBMC harness for the selected local `mlk_poly_add` property can be successfully checked under the recorded assumptions and build context.

This result must not be described as a proof of full ML-KEM, full FIPS 203 conformance, or complete mlkem-native correctness.

## Main lessons for the thesis

1. The initial agent-generated harness was useful as a starting point but required human correction.
2. The critic stage correctly identified assertion and overflow risks.
3. Reconstructing repository build context was necessary before CBMC could parse and check the harness.
4. The unwind bound required adjustment from 256 to 257.
5. Human review remains necessary for interpreting assumptions, assertions, and verification scope.
