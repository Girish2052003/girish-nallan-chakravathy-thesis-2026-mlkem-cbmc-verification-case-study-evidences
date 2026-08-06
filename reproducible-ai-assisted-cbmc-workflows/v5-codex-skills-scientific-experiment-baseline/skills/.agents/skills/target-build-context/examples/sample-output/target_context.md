# Target build context — `mlk_poly_sub`

- **Status:** `COMPLETE`
- **Semantic authority:** `NONE`
- **Analysis nature:** `LEXICAL_AND_BUILD_STRUCTURAL_ONLY`
- **Request:** `fixture-valid`

## Target identity

- Requested source: `src/poly.c`
- Definition count: `1`
- Declaration/call occurrence count: `3`
- First definition: `src/poly.c:8-17`
- Signature: `void mlk_poly_sub(poly *r, const poly *a, const poly *b)`

## Build context

- Mode: `explicit`
- Source: `request`
- Preprocessing: `SUCCEEDED`

## Direct lexical callers

- `use_sub` at `src/use_poly.c:5`

## Direct lexical callees

- `helper_touch` at `src/poly.c:16` — `direct_lexical_call_candidate`

## Loop headers

- `src/poly.c:13` `for (i = 0; i < MLKEM_N; i++)`; bound classification `NOT_INFERRED`

## Array expressions

- `src/poly.c:14` `r->coeffs[i]`; bounds `NOT_INFERRED`
- `src/poly.c:14` `a->coeffs[i]`; bounds `NOT_INFERRED`
- `src/poly.c:14` `b->coeffs[i]`; bounds `NOT_INFERRED`

## Pointer expressions

- `src/poly.c:14` `a->coeffs`; validity `NOT_INFERRED`
- `src/poly.c:14` `b->coeffs`; validity `NOT_INFERRED`
- `src/poly.c:14` `r->coeffs`; validity `NOT_INFERRED`

## Referenced macro definitions

- `MLKEM_N` = `4` at `include/poly.h:4`

## Relevant type declarations

- `poly` at `include/poly.h:6-8`

## Warnings and incomplete reasons

_None._

## Fixed limitations

- All declaration, definition, caller, callee, macro-reference, loop, array, pointer, and type relationships are lexical or structural observations, not semantic proofs.
- The skill does not infer active macro values unless an explicit preprocessing command succeeds; even then, the excerpt is evidence rather than build equivalence proof.
- Loop bound tokens are reported without deciding whether the loop is fixed, terminating, sufficient, or safe.
- Array and pointer expressions are reported without inferring bounds, validity, aliasing, lifetime, or memory safety.
- The direct-call map can miss macro-expanded, indirect, function-pointer, generated, assembly, or dynamically selected calls.
- A supplied explicit or compile-database command is recorded and used mechanically; the skill does not certify that it is the authoritative project build.
- No report status means that the implementation, theorem, harness, or proof is correct.
