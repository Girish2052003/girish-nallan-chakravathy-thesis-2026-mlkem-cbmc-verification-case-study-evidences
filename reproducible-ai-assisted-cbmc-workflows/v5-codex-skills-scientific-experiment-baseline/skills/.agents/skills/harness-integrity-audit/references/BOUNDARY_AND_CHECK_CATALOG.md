# Boundary and check catalogue

## Authority

`semantic_authority = NONE` and `gate_authority = NONE` are mandatory. The skill is a reporting instrument, not a critic or firewall gate.

## Checks

| Check ID | Mechanical evidence | Deliberate limitation |
|---|---|---|
| `PRODUCTION_SOURCE_HASH_BINDING` | SHA-256 equality for declared production files | Identity is not correctness |
| `HARNESS_HASH_BINDING` | SHA-256 equality for the harness | A mismatch is not attributed to intent |
| `EXPECTED_TARGET_CALL` | Lexical target-call count | Does not prove reachability or dynamic execution |
| `TARGET_REPLACEMENT_OR_STUB_PATTERN` | Target definition outside authoritative file or target macro in harness | Incomplete for link-time, pointer, or compiler substitution |
| `ASSUMPTION_INVENTORY` | Lexical `__CPROVER_assume` calls | No justification analysis |
| `USER_ASSERTION_PRESENCE` | Lexical `__CPROVER_assert`/`assert` calls | Excludes tool-inserted safety properties |
| `OBVIOUS_FALSE_ASSUMPTION` | Tiny literal/reflexive rules | No solver or symbolic simplification |
| `OBVIOUS_CONSTANT_FALSE_CONTROL` | `if`, `while`, or `for` condition classified literal false | Does not compute enclosed reachability |
| `DUPLICATE_ASSERTION_PATTERN` | Whitespace-normalized textual equality | Not semantic equivalence |
| `OBVIOUS_TRIVIAL_ASSERTION_PATTERN` | Tiny constant/reflexive rules | Intentionally incomplete |
| `ASSERTION_IDENTICAL_TO_ASSUMPTION_PATTERN` | Normalized-text equality | Not implication checking |
| `BUILD_INPUT_ALLOWLIST_COMPARISON` | Caller-declared set comparison | Cannot observe undeclared hidden tool inputs |
| `UNDEFINED_FUNCTION_DIAGNOSTIC` | Hash-bound caller-supplied diagnostic text | Does not reconstruct the GOTO program |

## Forbidden output vocabulary

The generated audit must not use `ACCEPTED`, `REJECTED`, `PROOF_VALID`, `CORRECT`, or equivalent scientific verdicts as statuses.
