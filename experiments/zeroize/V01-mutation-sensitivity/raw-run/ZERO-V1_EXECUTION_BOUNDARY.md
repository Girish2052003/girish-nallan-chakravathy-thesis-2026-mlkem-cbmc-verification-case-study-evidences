# ZERO-V1 Execution Boundary

ZERO-V1 evaluates property-detector sensitivity using isolated local mutant
models and faulty release sequences.

The authoritative mlkem-native source tree is not modified.

A mutant counts as killed only when:

1. its local mutant source differs from its paired reference source;
2. it compiles successfully;
3. CPROVER library instrumentation succeeds;
4. the mutant function is present and reached;
5. CBMC returns exit code 10;
6. the planned detector property fails;
7. exactly one property fails in that mutant execution;
8. the result is not a timeout, compile failure or tool error.
