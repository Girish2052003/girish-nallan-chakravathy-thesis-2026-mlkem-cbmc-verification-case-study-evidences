# OR-SR1 classification

- Classification: `PASS_EXPECTED`
- CBMC exit code: `0`
- JSON validity: `PASS`
- Property-result records: `11`
- Unexpected property results: `0`
- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Frozen worktree clean: `True`
- Loops: `none`
- Unwinding assertions: `not applicable`

## Required exact property results

- `OR_SR1_SHIFTED_SIGNED_LOWER_BOUND` → `main.assertion.1` → `['SUCCESS']`
- `OR_SR1_SHIFTED_SIGNED_UPPER_BOUND` → `main.assertion.2` → `['SUCCESS']`
- `OR_SR1_UINT32_CONVERSION_PRESERVES_VALUE` → `main.assertion.3` → `['SUCCESS']`
- `OR_SR1_SHIFTED_ORACLE_CANONICAL_RANGE` → `main.assertion.4` → `['SUCCESS']`
- `OR_SR1_NORMALIZED_ORACLE_LOWER_BOUND` → `main.assertion.5` → `['SUCCESS']`
- `OR_SR1_NORMALIZED_ORACLE_UPPER_BOUND` → `main.assertion.6` → `['SUCCESS']`
- `OR_SR1_ORACLE_EQUIVALENCE` → `main.assertion.7` → `['SUCCESS']`

## Accepted conclusion

The shifted unsigned oracle and the independently normalized signed-remainder oracle agree for every `int16_t`-representable difference.

## Scope boundary

OR-SR1 verifies only the equivalence of the two scalar oracle formulations and their supporting arithmetic bounds. It does not call or verify any mlkem-native subtraction or reduction implementation.
