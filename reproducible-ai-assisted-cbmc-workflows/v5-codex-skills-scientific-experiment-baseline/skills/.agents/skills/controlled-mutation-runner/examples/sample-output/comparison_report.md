# Controlled Mutation Run

- Request: `controlled-mutation-example-001`
- Mutation: `replace-add-with-subtract`
- Target symbol: `compute`
- Execution status: **COMPLETE**
- Semantic authority: **NONE**

## Caller declarations

- Rationale: Replace addition with subtraction to test whether the selected assertion observes the changed behavior.
- Expected effect: The caller expects the selected property to change from SUCCESS in the baseline to FAILURE in the mutant.

## Patch application

- Result: `APPLIED_TO_DISPOSABLE_COPY`
- Touched files: 1

## Execution comparison

- Baseline CBMC: `PASS_REPORTED_BY_CBMC`
- Mutant CBMC: `FAIL_REPORTED_BY_CBMC`
- Baseline syntax: `PASSED`
- Mutant syntax: `PASSED`
- Declared transition comparison: `MATCHES_CALLER_DECLARATION`
- Changed property-status records: 1

## Authoritative source and cleanup

- Authoritative tree unchanged: `True`
- Disposable workspaces removed: `True`
- Restoration interpretation: `NO_AUTHORITATIVE_EDIT_WAS_REQUIRED`

## Warnings

- None recorded.

## Mandatory limitation

This report records an exact caller-designed mutation and bounded tool-output comparison. It does not determine whether the mutation is realistic, whether the property is useful or complete, or whether the implementation is correct.
