# CBMC Harness Scaffold Report

- Request ID: `mlk-poly-sub-scaffold-001`
- Status: `COMPLETE`
- Semantic authority: `NONE`
- Generated content class: `NEUTRAL_WIRING_ONLY`
- Target: `mlk_poly_sub`
- Harness: `mlk_poly_sub_harness.c`

## Scientific boundary

This utility generated neutral C wiring only. It did not select a theorem, insert input-domain assumptions, write a verification assertion, infer aliasing or range conditions, or judge correctness.

## Neutrality inventory

- Target-call count: `1`
- Inserted assumptions: `0`
- Inserted assertions: `0`
- Inserted initializers: `0`

## Compile check

- Enabled: `True`
- Required: `True`
- Status: `PASSED`

## Mandatory interpretation limits

- The scaffold does not establish that the target signature, arguments, object declarations, includes, or build flags are scientifically appropriate.
- No input-domain, pointer-validity, aliasing, range, loop, or mathematical assumptions were inferred or inserted.
- No verification property, assertion, contract, invariant, or expected output relationship was inferred or inserted.
- A successful syntax-only compile check establishes only compiler acceptance of the generated translation unit under the captured arguments.
- Uninitialized local declarations are emitted without a claim about their semantic suitability; Codex must decide input construction.
- The target call is generated from caller-supplied structured wiring and is not evidence that the intended implementation is reached at runtime.
