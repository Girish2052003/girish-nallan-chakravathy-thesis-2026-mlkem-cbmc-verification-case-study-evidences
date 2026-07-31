# MSG-01I-R1 — Reachability Parser Correction

The first MSG-01I attempt built and validated both control models.

The original model retained twelve `__CPROVER_cover` instructions, so its
reachable call graph correctly included `__CPROVER_cover`. The companion
model neutralised those instructions and correctly omitted that primitive.

The first parser incorrectly required the two raw reachable-function sets to
be identical.

MSG-01I-R1:

1. requires exactly twelve original-model cover edges;
2. requires zero companion-model cover edges;
3. permits `__CPROVER_cover` only in the original raw set;
4. excludes only that instrumentation primitive before comparing the
   production execution path;
5. requires identical reachable loops and unwindsets.

```text
FAILED_MSG01I_CLASSIFICATION=PARSER_FALSE_REJECTION
FUNCTIONAL_COUNTEREXAMPLE=NO
REACHABILITY_EXECUTION=NO
```
