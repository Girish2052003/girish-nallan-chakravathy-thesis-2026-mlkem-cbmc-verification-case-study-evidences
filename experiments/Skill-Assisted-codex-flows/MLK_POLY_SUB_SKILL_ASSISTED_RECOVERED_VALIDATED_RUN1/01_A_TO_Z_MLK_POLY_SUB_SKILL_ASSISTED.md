# A-to-Z record: skill-assisted relational verification of `mlk_poly_sub`

## 1. Aim and frozen boundary

This corpus binds two new multi-execution relational properties to the unchanged portable-C `mlk_poly_sub` implementation in `mlkem/src/poly.c`, commit `d9613cf60de3132d32475c102d8c2781d84feb34`, ML-KEM-768. The production translation unit is compiled directly; no copied body, stub, function-contract replacement, or source modification is used.

## 2. Prior-work exclusion

The supplied SUB records already establish or investigate: pointwise subtraction and modular refinement; subtraction/reduction compatibility; exact right and left cancellation; modular cancellation; canonical and representability boundaries; frame preservation; coefficient locality; cross-coefficient non-interference; exact local-change propagation; determinism; production-callsite preconditions; and the `sub → reduce → tomsg` handoff. None is reused as a selected claim here.

The upstream repository contract remains the authoritative single-call baseline:

```text
r_after[i] = r_before[i] - b[i]
```

The present contribution is the executable relational encoding, not discovery of new integer algebra.

## 3. Target and environment

```c
void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;
  for (i = 0; i < MLKEM_N; i++)
    r->coeffs[i] = (int16_t)(r->coeffs[i] - b->coeffs[i]);
}
```

Frozen environment: Ubuntu Linux x86-64, little endian, C90, CBMC/goto-cc/goto-instrument 6.9.0, GCC 13.3.0, Python 3.12.3, `MLKEM_N=256`, `MLKEM_Q=3329`, portable C, ML-KEM-768.

## 4. SA-SUB-T1 — Common-minuend difference reversal

Four production calls compare two schedules:

```text
nested = (a - b) - (a - c)
direct = c - b
```

### Preconditions

For every coefficient, `a-b`, `a-c`, and `c-b` are representable in signed 16-bit storage. Objects are separately allocated automatic `mlk_poly` values. The representability assumptions are target-call admissibility conditions; the theorem equality itself is never assumed.

### Postconditions

For every coefficient:

```text
nested == direct
nested == widened(c - b)
direct == widened(c - b)
```

This is a common-minuend elimination identity across four executions, not the earlier `(A-B)+B=A` or `(A+B)-B=A` cancellation family.

## 5. SA-SUB-T2 — Sequential-subtrahend aggregation equivalence

Three production calls compare:

```text
sequential = (a - b) - c
direct     = a - aggregate
aggregate  = widened(b + c), safely stored in int16_t
```

### Preconditions

For every coefficient, `a-b`, `b+c`, and `a-(b+c)` are representable in signed 16-bit storage. The aggregate is constructed by the harness from widened arithmetic; its defining equation is asserted, not assumed.

### Postconditions

For every coefficient:

```text
aggregate == widened(b + c)
sequential == direct
sequential == widened((a - b) - c)
direct == widened(a - (b + c))
```

This is a repeated-subtraction/aggregated-subtrahend equivalence. It is not normalization compatibility, a boundary theorem, or a frame/locality/determinism theorem.

## 6. Reachability and feasibility

Each cover-enabled companion model contains named goals for:

- completion of all assumptions;
- a nontrivial symbolic witness;
- return from every target call;
- entry into the final assertion block.

Universal proof uses a cover-neutral companion model with complete unwinding assertions. Coverage is executed separately because coverage intrinsics are not treated as ordinary safety evidence.

## 7. GOTO and CBMC workflow

For each theorem the runner creates a proof model and a cover model with the same production source and harness. It preserves build commands/logs, GOTO binaries, function/loop/property inventories, universal-proof JSON, coverage JSON and test suite, exit codes, failure traces when needed, hashes, tool versions, Git identity, distinctness audit, selected-claim mapping, and final status.

Proof checking enables bounds, pointer, pointer-overflow, signed/unsigned overflow, conversion, division-by-zero, undefined-shift, and unwinding assertions. Global unwind `257` covers every 256-iteration polynomial loop and its exit test.

## 8. Acceptance rules

- Every selected theorem has one frozen harness and named assertion IDs.
- The real namespaced `poly_sub` body must appear in each GOTO function inventory.
- All universal properties must succeed with no failure or unknown status.
- Every named cover goal must be satisfied.
- Source commit, `poly.c`, and `poly.h` hashes must match.
- No tracked repository file may contain the new theorem titles, harness names, or assertion IDs.
- Every expected run artefact must exist and be non-empty.

## 9. Scope and nonclaims

The results are bounded to the frozen portable-C source, ML-KEM-768, the recorded machine model, separate valid objects, and the explicit representability domains. They do not prove overflow-invalid calls, unsupported aliasing, assembly backends, full ML-KEM correctness, or worldwide novelty. Repository distinctness means no exact selected-claim artefact was found in the frozen tracked repository.

## 10. Corpus markings

```text
RUNS OCCURED               1
Selected-claim mapping     YES
Target reachability        YES
Assertion reachability     YES
Assumption feasibility     YES
Evidence completeness      COMPLETE
Repository distinctness    SUPPORTED
Contamination              NONE KNOWN
```

The static corpus is complete as a reproducible verification package. The included fail-closed run creates the authoritative solver and cover evidence in `evidence/run_1` without inventing results.
