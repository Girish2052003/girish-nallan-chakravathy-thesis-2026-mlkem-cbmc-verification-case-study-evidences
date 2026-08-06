# A-to-Z record: skill-assisted relational verification of `mlk_poly_add`

## 1. Aim

This corpus isolates two relational properties not used as selected claims in the prior PA-01–PA-09 campaign. It links the new harnesses to the unchanged production `mlkem/src/poly.c` at commit `d9613cf60de3132d32475c102d8c2781d84feb34` and ML-KEM-768.

## 2. Prior-work exclusion boundary

The new selected claims are not: canonical exact addition, full signed-domain exact addition, modulo-`q` refinement, frame preservation, commutativity, additive identity, unrestricted overflow failure, aliasing, production call-site closure, cross-parameter replication, mutation sensitivity, boundary reachability, or provenance auditing. Those functions remain authoritative in PA-01–PA-09 and are not repeated as the contribution here.

## 3. Target

```c
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;
  for (i = 0; i < MLKEM_N; i++)
    r->coeffs[i] = (int16_t)(r->coeffs[i] + b->coeffs[i]);
}
```

The runner compiles the repository production translation unit directly; no copied implementation or stub replaces the target.

## 4. Theorem SA-ADD-T1: common-addend translation invariance

For arbitrary polynomials `x`, `y`, and common operand `b`, whenever both `x+b` and `y+b` are representable in `int16_t`, two production calls must preserve every coefficient difference:

```text
(x + b) - (y + b) = x - y
```

The harness also checks that equality is both preserved and reflected:

```text
x + b = y + b  iff  x = y
```

This is a relational injectivity/cancellation property across two target executions, not a restatement of commutativity or identity.

### Preconditions

- Three separately allocated `mlk_poly` objects.
- For each coefficient, `x[i]+b[i]` and `y[i]+b[i]` lie in `[-32768,32767]`.
- `MLKEM_N=256`, `MLKEM_Q=3329`, and the expected 16-bit representation are asserted.

### Postconditions

- Two target calls return.
- Each post-state difference equals its pre-state difference in `int32_t`.
- Equality of the two accumulators is preserved and reflected coefficient-wise.

## 5. Theorem SA-ADD-T2: arbitrary disjoint-support decomposition

For arbitrary valid `a` and operand `b`, each coefficient of `b` is nondeterministically assigned to one of two disjoint parts `p` or `q`, with `p+q=b`. The theorem compares:

```text
direct schedule: a := a + b
split schedule:  a := (a + p) + q
```

The schedules must be coefficient-wise identical for every symbolic support partition. This directly tests decomposition invariance under arbitrary sparse partitioning rather than a fixed even/odd test.

### Preconditions

- `a[i]+b[i]` is representable in `int16_t` for every coefficient.
- The harness constructs `p` and `q`; it does not assume their recomposition or disjointness.
- All target operands are separate objects.

### Postconditions

- Three target calls return.
- `p[i]+q[i]=b[i]` and at least one part is zero at each coefficient.
- Direct and split schedules are identical.
- Both schedules agree with an independent `int32_t` oracle.

## 6. Assumption discipline

All semantic assumptions state only the target contract’s necessary non-overflow domain. Mathematical sums are formed in `int32_t`. The partition equations, parameter bindings, call counters, theorem equations, and oracle bridges are assertions, not assumptions.

Concrete feasible states include all-zero inputs. The cover pass separately requests witnesses after assumptions, after each production call, and at the final assertion block.

## 7. CBMC construction

The runner uses:

```text
goto-cc -I. -Imlkem -Imlkem/src   -DMLK_CONFIG_PARAMETER_SET=768 <harness> mlkem/src/poly.c -o <model>
```

Each proof enables bounds, pointer, pointer-overflow, signed-overflow, unsigned-overflow, conversion, division-by-zero, undefined-shift, and unwinding checks. `--unwind 257 --unwinding-assertions` covers the 256-coefficient loops and their exit tests. The default CBMC decision procedure is used.

A separate `--cover cover --show-test-suite` query evaluates all explicit `__CPROVER_cover` goals. Coverage mode is not used as proof evidence; it is anti-vacuity evidence.

## 8. Evidence produced by run 1

For each theorem the runner preserves the harness, GOTO model, build command and log, property inventory, proof command, proof JSON/stderr/exit code, cover command, cover JSON/stderr/exit code, and SHA-256 values. It also records Git identity, tool versions, production-source hash, and final acceptance status.

## 9. Acceptance rules

- **Selected-claim mapping:** every selected theorem maps to named assertions and one harness.
- **Target reachability:** every post-call cover goal receives a witness.
- **Assertion reachability:** the final assertion-block cover goal receives a witness.
- **Assumption feasibility:** the post-assumption cover goal receives a witness.
- **Evidence completeness:** every expected artefact exists and is non-empty.
- **Repository distinctness:** source commit/hash match and no existing tracked source is modified.
- **Contamination:** no known copied harness, property ID, or selected-claim text is detected.

## 10. Scope

The theorems concern the portable C production body, the pinned source state, ML-KEM-768, separate valid objects, and contract-valid additions. They do not prove native assembly backends, overflow-invalid executions, every possible algebraic law, or the complete ML-KEM implementation.

## 11. Corpus status

```text
Selected-claim mapping     YES
Target reachability        YES (encoded; confirmed by run-1 cover evidence)
Assertion reachability     YES (encoded; confirmed by run-1 cover evidence)
Assumption feasibility     YES (encoded; confirmed by run-1 cover evidence)
Evidence completeness      COMPLETE after run-1 acceptance
Repository distinctness    SUPPORTED
Contamination              NONE KNOWN
```

The static package supplies the complete harness, runner, ledgers, source binding, and distinctness evidence. The authoritative universal-verification verdict and cover witnesses are generated only by executing the included fail-closed runner in the specified Ubuntu/CBMC environment.
