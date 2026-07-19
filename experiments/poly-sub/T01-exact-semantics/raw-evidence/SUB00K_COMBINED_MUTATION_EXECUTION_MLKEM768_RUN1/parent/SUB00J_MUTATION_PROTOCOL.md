# SUB-00J Mutation-Sensitivity Protocol

## Purpose

The successful SUB-T1 result is subjected to mutation testing to determine
whether the frozen assertions and independent oracle are capable of rejecting
plausible faults.

Mutation testing does not prove correctness and does not establish novelty.
It supplies sensitivity evidence complementary to SUB-T1 and SUB-00I.

## Frozen controls

The following remain unchanged:

- frozen repository commit;
- production source snapshot outside isolated mutant copies;
- SUB-T1 assumptions;
- machine-model assertions;
- frame assertions;
- safety flags;
- loop bounds;
- solver configuration planned for the later execution stage.

## Mutants

### M1 — addition instead of subtraction

One production statement is changed:

```c
r->coeffs[i] = (int16_t)(r->coeffs[i] - b->coeffs[i]);
```

to:

```c
r->coeffs[i] = (int16_t)(r->coeffs[i] + b->coeffs[i]);
```

Expected kill criterion: the independent canonical-oracle assertion must be
reported as failing. Additional safety failures may also occur, but they do
not replace the semantic kill criterion.

### M2 — coefficient 255 skipped

The production subtraction loop condition is changed:

```c
i < MLKEM_N
```

to:

```c
i + 1u < MLKEM_N
```

Expected kill criterion: the independent canonical-oracle assertion must be
reported as failing for coefficient 255 on at least one admissible input.

### M3 — oracle shifted by one

Production source remains unchanged. The independent oracle is changed:

```c
expected = shifted % FIPS_Q;
```

to:

```c
expected = (shifted + 1) % FIPS_Q;
```

Expected kill criterion: the equality-to-oracle assertion must be reported as
failing. This checks that the assertion is active and not trivially satisfied.

## Preflight boundary

This package contains only:

- isolated mutated source/harness copies;
- exact diffs and hashes;
- validated GOTO binaries;
- reachable-call and loop inventories;
- property inventories generated with `--show-properties`;
- frozen future expected-failure commands.

No mutant solver command has been executed.

## Acceptance rule for the later execution stage

A mutant is killed only when:

1. the exact preflight model hash is reverified;
2. GOTO validation passes immediately before execution;
3. CBMC returns a failing verification result;
4. the independent canonical-oracle property is specifically listed as
   `FAILURE`;
5. the trace demonstrates an admissible input satisfying the frozen
   representability assumptions.

A crash, timeout, malformed JSON, missing property, or unrelated-only failure
does not count as a killed mutant.
