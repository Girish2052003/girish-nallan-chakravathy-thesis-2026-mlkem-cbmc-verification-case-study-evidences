# OR-SR1 final acceptance

- Classification: `PASS_EXPECTED`
- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Frozen worktree clean: `True`
- CBMC exit code: `0`
- Property-result records: `11`
- Unexpected property results: `0`
- Loops: `none`
- Unwinding assertions: `not applicable`

## Exact property results

- `OR_SR1_SHIFTED_SIGNED_LOWER_BOUND` → `main.assertion.1` → `['SUCCESS']`
- `OR_SR1_SHIFTED_SIGNED_UPPER_BOUND` → `main.assertion.2` → `['SUCCESS']`
- `OR_SR1_UINT32_CONVERSION_PRESERVES_VALUE` → `main.assertion.3` → `['SUCCESS']`
- `OR_SR1_SHIFTED_ORACLE_CANONICAL_RANGE` → `main.assertion.4` → `['SUCCESS']`
- `OR_SR1_NORMALIZED_ORACLE_LOWER_BOUND` → `main.assertion.5` → `['SUCCESS']`
- `OR_SR1_NORMALIZED_ORACLE_UPPER_BOUND` → `main.assertion.6` → `['SUCCESS']`
- `OR_SR1_ORACLE_EQUIVALENCE` → `main.assertion.7` → `['SUCCESS']`

## Accepted conclusion

For every `int16_t`-representable difference, the shifted unsigned oracle and the independently normalized signed-remainder oracle produce the same canonical representative modulo 3329.

## Scope boundary

OR-SR1 establishes scalar oracle equivalence only. It does not verify `mlk_poly_sub`, `mlk_poly_reduce`, ciphertext decompression, inverse NTT, or their production call sequence.
