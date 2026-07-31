# PBYTES Scope and Nonclaims V1

## Proof target

The semantic harnesses shall call the public `mlk_poly_tobytes` wrapper in a
portable configuration whose GOTO call graph reaches `mlk_poly_tobytes_c`.

Calling only the file-local portable body and then claiming public-wrapper
correctness is prohibited.

## Permitted assumptions

- Input polynomial is a valid local object.
- Output is a valid 384-byte local object.
- Input and output do not alias.
- Every input coefficient is in `[0, MLKEM_Q)`.
- T2 incremented coefficients remain in `[0, MLKEM_Q)`.
- T3 arbitrary encoded inputs may be constrained only by the explicitly
  tested canonical-field predicate.
- Selected indices are within their recorded ranges.

## Forbidden proof transformations

- No production-source modification in the positive theorem run.
- No replacement of `mlk_poly_tobytes` by a contract.
- No replacement of `mlk_poly_tobytes_c` by a contract.
- No native backend silently selected.
- No call to `mlk_poly_frombytes` inside an independent oracle.
- No reuse of the production shift-and-mask expression as the T1 oracle.
- No assumption of the expected output relation.
- No contradictory or result-shaped assumptions.
- No stubbing of the target function.
- No fixed-point or round-trip theorem presented as a new primary family.
- No generic locality, frame or determinism theorem counted as a new family.

## Mandatory assurance controls

- Exact source and commit binding.
- GOTO call-graph binding.
- Complete unwinding.
- Memory and arithmetic safety.
- Assertion reachability.
- Boundary-case reachability.
- Input-frame preservation.
- Output canaries.
- Complete output overwrite.
- Nonconstant-output witnesses.
- Mutation sensitivity.
- Deterministic evidence and hash freezing.

## Nonclaims

- Native AArch64 or x86-64 semantic correctness.
- Constant-time execution or side-channel resistance.
- `mlk_poly_frombytes` correctness.
- Compression or decompression correctness.
- Complete ML-KEM correctness.
- Out-of-domain behaviour.
- Mathematical or worldwide first-ever novelty.
