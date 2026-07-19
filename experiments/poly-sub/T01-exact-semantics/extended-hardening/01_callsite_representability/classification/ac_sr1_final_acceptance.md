# AC-SR1 final acceptance

- Classification: `PASS_EXPECTED`
- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Frozen worktree clean: `True`
- CBMC exit code: `0`
- Loops: `none`
- Unwinding assertions: `not applicable`

## Exact property results

- `AC_SR1_EXACT_LOWER_BOUND` → `main.assertion.1` → `['SUCCESS']`
- `AC_SR1_EXACT_UPPER_BOUND` → `main.assertion.2` → `['SUCCESS']`
- `AC_SR1_IMPLIES_INT16_MIN` → `main.assertion.3` → `['SUCCESS']`
- `AC_SR1_IMPLIES_INT16_MAX` → `main.assertion.4` → `['SUCCESS']`

## Accepted conclusion

The frozen decryption call-site bounds imply that every coefficient subtraction admitted at the audited call site satisfies the signed-representability precondition required by `mlk_poly_sub`.

## Scope boundary

AC-SR1 verifies only the scalar implication between the recorded bounds and signed representability. It does not independently verify ciphertext decompression, inverse NTT, `mlk_poly_sub`, or `mlk_poly_reduce`.
