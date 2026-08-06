# Boundary and generation policy

## Permitted generated C

- `#include` directives exactly supplied in the request;
- an `int <entry>(void)` function;
- conservative declarations exactly assembled from caller-supplied type/name/dimension fields;
- fixed comment markers for input preparation, assumptions, target call, and assertions;
- exactly one target call assembled from the named symbol and conservative declared-object arguments;
- optional assignment of the target return to an already declared variable;
- `return 0;`.

## Prohibited generated C

The generator cannot emit:

- initializers;
- arbitrary caller-provided statements;
- literals as target arguments;
- function calls as target arguments;
- assumption/assertion primitives;
- contracts, loop invariants, expected relations, mutations, stubs, or replacement functions;
- user-controlled preprocessor bodies or compiler output paths.

## Structured rather than free-form input

The request does not accept a raw declaration block, target-call statement, assumption block, assertion block, or shell command. This prevents a neutral wiring helper from becoming a code-injection channel or a hidden theorem generator.

## Source binding

Every declared source binding is checked against an expected SHA-256 before the scaffold is emitted. The target source must be among those bindings. This does not claim that the binding set is complete; its scope is explicitly `DECLARED_SOURCE_BINDINGS_ONLY`.

## Compiler check

The optional compiler action is `-fsyntax-only`, invoked with `shell=False`. Compiler names, language standards, include directories, defines, and extra warning flags are constrained. A successful result is syntactic evidence only.
