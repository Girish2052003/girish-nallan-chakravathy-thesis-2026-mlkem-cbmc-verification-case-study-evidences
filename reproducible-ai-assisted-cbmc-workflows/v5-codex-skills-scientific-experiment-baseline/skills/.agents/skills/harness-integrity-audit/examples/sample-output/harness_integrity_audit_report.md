# Harness Integrity Audit

- Request: `vector-subtract-integrity-001`
- Target: `vector_subtract`
- Report status: **COMPLETE**
- Semantic authority: **NONE**
- Gate authority: **NONE**

## Findings

### PRODUCTION_SOURCE_HASH_BINDING — CHECKED

All declared production-file hashes match

_Limitation: Hash equality establishes file identity only; it does not establish source correctness._

### HARNESS_HASH_BINDING — CHECKED

Harness hash matches the declared identity

_Limitation: A mismatch is recorded rather than interpreted as malicious or erroneous._

### EXPECTED_TARGET_CALL — CHECKED

Observed 1 lexical target call(s); minimum required is 1

_Limitation: Call recognition is lexical and does not prove reachability or dynamic dispatch behavior._

### TARGET_REPLACEMENT_OR_STUB_PATTERN — CHECKED

No configured replacement/stub pattern observed

_Limitation: Absence of these lexical patterns does not prove that all replacement mechanisms are absent._

### ASSUMPTION_INVENTORY — CHECKED

Recorded 1 lexical assumption call(s)

_Limitation: Inventory does not judge whether assumptions are necessary, sufficient, or justified._

### USER_ASSERTION_PRESENCE — CHECKED

Recorded 1 lexical user assertion call(s)

_Limitation: This inventory does not include properties inserted internally by CBMC safety-check options._

### OBVIOUS_FALSE_ASSUMPTION — CHECKED

No configured obvious-false assumption pattern observed

_Limitation: UNKNOWN expressions are not evaluated, simplified, or sent to a solver._

### OBVIOUS_CONSTANT_FALSE_CONTROL — CHECKED

No configured constant-false control pattern observed

_Limitation: The check does not determine which statements are dynamically unreachable._

### DUPLICATE_ASSERTION_PATTERN — CHECKED

No duplicate normalized assertion condition observed

_Limitation: Textual equality does not establish semantic equivalence, and textual difference does not establish semantic distinctness._

### OBVIOUS_TRIVIAL_ASSERTION_PATTERN — CHECKED

No configured trivial assertion pattern observed

_Limitation: The check is deliberately incomplete and performs no theorem proving._

### ASSERTION_IDENTICAL_TO_ASSUMPTION_PATTERN — CHECKED

No assertion condition was textually identical to an assumption

_Limitation: This is a normalized-text comparison, not semantic implication checking._

### BUILD_INPUT_ALLOWLIST_COMPARISON — CHECKED

Actual build inputs exactly match the caller-declared allowlist

_Limitation: The comparison covers only caller-declared build inputs; it does not observe hidden compiler or environment inputs._

### UNDEFINED_FUNCTION_DIAGNOSTIC — CHECKED

Diagnostic listed no undefined functions

_Limitation: The skill trusts only the supplied diagnostic text and does not reconstruct the GOTO program or call graph._

## Mandatory interpretation boundary

- This audit is syntactic and structural; it does not establish semantic validity.
- CHECKED means the configured mechanical check completed without the specific pattern being flagged.
- WARNING is evidence for Codex and the researcher to inspect; it is not rejection.
- NOT_CHECKABLE means the configured evidence was absent or the check was disabled.
- The audit does not prove reachability, non-vacuity, theorem usefulness, assumption justification, or implementation correctness.
- No finding produced by this skill is an acceptance or rejection gate.
