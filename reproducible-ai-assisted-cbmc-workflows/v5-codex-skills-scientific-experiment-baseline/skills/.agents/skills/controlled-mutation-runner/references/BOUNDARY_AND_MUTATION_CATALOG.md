# Boundary and Mutation Catalogue

## Caller-owned intellectual work

Codex or the researcher must supply:

- the exact mutation diff;
- why that mutation was selected;
- the theorem/property under investigation;
- the expected verification effect;
- the exact baseline analysis configuration;
- interpretation of the observed result.

## Skill-owned mechanical work

The skill may:

- verify identities;
- apply the exact patch to a disposable copy;
- execute the same captured commands;
- preserve raw evidence;
- compare recorded status strings;
- confirm no authoritative edit occurred.

## Supported RC1 patch subset

Supported:

- UTF-8 text unified diff;
- one or more declared existing files;
- one file section per path;
- exact context/addition/deletion hunks;
- files ending with newline.

Rejected:

- creation and deletion through `/dev/null`;
- renames;
- binary patches;
- no-newline markers;
- duplicate file sections;
- symlink targets;
- undeclared paths;
- paths not explicitly marked `mutation_allowed`;
- mismatched hunk context;
- no-op patches.

## Evidence vocabulary

Permitted examples:

```text
APPLIED_TO_DISPOSABLE_COPY
PASS_REPORTED_BY_CBMC
FAIL_REPORTED_BY_CBMC
MATCHES_CALLER_DECLARATION
DIFFERS_FROM_CALLER_DECLARATION
AUTHORITATIVE_TREE_UNCHANGED
```

Forbidden scientific verdicts:

```text
MUTANT_KILLED
MUTANT_SURVIVED
PROOF_VALID
PROPERTY_STRONG
IMPLEMENTATION_CORRECT
SCIENTIFICALLY_ACCEPTED
NOVEL
```

The prohibited mutation-testing shorthand is avoided because it can sound like a substantive evaluation. The report instead preserves the exact property-status transition.

## RC1 scope limitation

RC1 supports a single exact patch per run and direct C/CBMC source sets. Codex can always bypass the skill and create a more specialised experiment when callbacks, generated build systems, multiple dependent patches, assembly, linker scripts, or non-C languages require broader handling.
