# PFB Scope and Nonclaims V1

## Proof target

Positive semantic harnesses shall call the public `mlk_poly_frombytes`
wrapper in a portable configuration whose GOTO call graph reaches the real
`mlk_poly_frombytes_c` body.

Calling only the file-local portable body and claiming public-wrapper
correctness is prohibited.

## Permitted assumptions

* Input is a valid local 384-byte array.
* Output is a valid local `mlk_poly` object.
* Input and output do not alias.
* Selected block and bit indices are in their recorded ranges.
* T2 inputs satisfy only their declared differential relation.
* T4.P2 raw coefficients lie in `[0,4096)`.

No canonical-below-q assumption is permitted for T1, T2, T3, or T4.P1.

## Forbidden proof transformations

* No production-source modification in positive theorem runs.
* No contract replacement of `mlk_poly_frombytes`.
* No contract replacement of `mlk_poly_frombytes_c`.
* No native backend silently selected.
* No target stubbing or body removal.
* No target function call inside an independent oracle.
* No production `mlk_poly_tobytes` used as the T4 raw encoder.
* No production shift-and-mask expression copied into the T1 oracle.
* No assumption of the expected output relation.
* No contradictory, result-shaped, or vacuous assumptions.
* No generic frame, determinism, or safety property counted as a new family.

## Mandatory assurance controls

* Exact commit, tree and source-hash binding.
* GOTO call-graph binding.
* Public-wrapper and portable-body reachability.
* Complete loop unwinding.
* Unwinding assertions.
* Bounds, pointer, overflow, conversion and shift checks.
* Assertion reachability.
* Boundary-value reachability.
* Input-frame preservation.
* Output canaries.
* Complete output overwrite.
* Nonconstant-output witnesses.
* Targeted source-mutation sensitivity.
* Deterministic evidence and hash freezing.

## Cross-campaign controls, not primary PFB claims

* Canonical round trips.
* Production normalization correctness.
* Normalization idempotence.
* Representative multiplicity.
* Same-residue quotient equivalence.
* Canonical encoder-image characterization.

## Nonclaims

* Native AArch64 or x86-64 semantic correctness.
* Constant-time execution or side-channel resistance.
* Correctness of production `mlk_poly_tobytes`.
* Correctness of `mlk_poly_reduce`.
* Complete FIPS ByteDecode12 refinement including modular normalization.
* Complete ML-KEM correctness.
* Mathematical or worldwide first-ever novelty.
