Codex CLI 0.144.4 — GPT-5.6 sol — reasoning high

# `mlk_zeroize` Skill-Assisted CBMC Verification Record

## 1. Purpose of this record

This record documents the two theorem families proved for the real
`mlk_zeroize` implementation in the pinned `mlkem-native` source tree. It
states the verified properties, symbolic preconditions, retained assumptions,
reachability obligations, expected-failure controls, source-binding rules, and
accepted campaign result.

The record concerns source-level C semantics. It does not claim physical
destruction of residual data in hardware, every compiler-generated binary, or
every platform-specific zeroization branch.

## 2. Authoritative campaign identity

```text
Campaign folder:       MLK_POLY_Zerorize_SKILL ASSISTED
Technical target:      mlk_zeroize
Repository:            pq-code-package/mlkem-native
Authoritative commit:  af4c5abdd5958bdc65a03cd5ee86708264f93304
Authoritative tree:    54805daff6a91a010c05467ea678117c42a71559
Accepted runs:         1
CBMC:                  6.9.0
goto-cc:               6.9.0
goto-instrument:       6.9.0
Build context:         ML-KEM-768
Language mode:         C90
Symbolic host object:  16 writable bytes
Loop unwind:           17, with unwinding assertions in proof models
```

The campaign runner rejected every source state except the authoritative commit
and tree. Production source was not modified, stubbed, or replaced by a
contract-only abstraction.

## 3. Accepted campaign result

The complete execution produced the following terminal verdict:

```text
RUN_1_ACCEPTED
FINAL_STATUS_VALIDATION=PASS
runs_occurred=1
Selected-claim mapping=YES
Target reachability=YES
Assertion reachability=YES
Assumption feasibility=YES
Evidence completeness=COMPLETE
Repository distinctness=SUPPORTED
Contamination=NONE KNOWN
overall_verdict=PASS_COMPLETE_SKILL_ASSISTED_MLK_ZEROIZE_AF4C5ABD_CORPUS
MLK_ZEROIZE_AF4C5ABD_BOTH_THEOREMS_COMPLETE
```

This verdict was issued only after both theorem families completed their
positive proof, named reachability model, body-binding check, and deliberately
false expected-failure control.

# 4. Theorem SA-ZERO-T1

## 4.1 Name

**Whole-object secret-history convergence**

## 4.2 Verification question

Suppose two writable objects are identical outside the same symbolic
non-empty wipe interval, but contain different secret histories inside that
interval. After applying the real `mlk_zeroize` to the same interval in both
objects, do the complete observable post-states converge to one identical
object?

## 4.3 Symbolic preconditions

Let the 16-byte objects be `left` and `right`, and let the selected interval be:

```text
I = [offset, offset + length)
```

The harness constrained:

```text
0 <= offset < 16
1 <= length <= 16 - offset
left[i] = right[i] for every i outside I
left and right may contain arbitrary uint8_t values inside I
left[offset] != right[offset]
```

The final inequality supplies a concrete nontrivial witness. It prevents the
relational claim from passing only because the two initial objects happened to
be identical.

## 4.4 Production executions

The harness performed two genuine target calls:

```c
mlk_zeroize(left + offset, length);
mlk_zeroize(right + offset, length);
```

The target-call counter was asserted to equal two.

## 4.5 Proved properties

### SA-ZERO-T1.P1 — Left selected interval is erased

```text
For every i in I:
left_after[i] = 0
```

CBMC assertion:

```text
SA_ZERO_T1_LEFT_SELECTED_BYTES_ZERO
```

### SA-ZERO-T1.P2 — Right selected interval is erased

```text
For every i in I:
right_after[i] = 0
```

CBMC assertion:

```text
SA_ZERO_T1_RIGHT_SELECTED_BYTES_ZERO
```

### SA-ZERO-T1.P3 — Left outer frame is preserved

```text
For every i outside I:
left_after[i] = left_before[i]
```

CBMC assertion:

```text
SA_ZERO_T1_LEFT_OUTER_FRAME_PRESERVED
```

### SA-ZERO-T1.P4 — Right outer frame is preserved

```text
For every i outside I:
right_after[i] = right_before[i]
```

CBMC assertion:

```text
SA_ZERO_T1_RIGHT_OUTER_FRAME_PRESERVED
```

### SA-ZERO-T1.P5 — Complete post-state convergence

```text
For every byte index i:
left_after[i] = right_after[i]
```

CBMC assertion:

```text
SA_ZERO_T1_WHOLE_OBJECT_SECRET_HISTORY_CONVERGENCE
```

This is the primary relational theorem. It establishes that differences
confined to the selected secret interval cannot remain observable anywhere in
the complete bounded object after both real zeroization calls.

### SA-ZERO-T1.P6 — Exact target-call count

```text
target_calls = 2
```

CBMC assertion:

```text
SA_ZERO_T1_TARGET_CALL_COUNT
```

This excludes accidental omission of either target execution.

## 4.6 Reachability and feasibility obligations

The separate reachability model established:

```text
SA_ZERO_T1_ASSUMPTIONS_FEASIBLE
SA_ZERO_T1_NONTRIVIAL_SECRET_DIFFERENCE
SA_ZERO_T1_TARGET_1_REACHED
SA_ZERO_T1_TARGET_2_REACHED
SA_ZERO_T1_ASSERTION_BLOCK_REACHED
```

The accepted result therefore did not rely on an infeasible assumption set,
an identical-input shortcut, an unreachable target call, or an unreachable
assertion block.

## 4.7 Expected-failure sensitivity control

The fail-control model deliberately asserted:

```text
left_after[offset] != right_after[offset]
```

Named property:

```text
SA_ZERO_T1_FC_SECRET_DIFFERENCE_PERSISTS
```

This false claim was required to fail. Its rejection demonstrated that the
verification model was capable of detecting persistence of the selected
secret difference rather than mechanically returning success.

# 5. Theorem SA-ZERO-T2

## 5.1 Name

**Recovery after symbolic subrange recontamination**

## 5.2 Verification question

After a symbolic outer interval has been zeroized, suppose an adversarial write
reintroduces arbitrary data into a symbolic non-empty subrange. Does a second
real `mlk_zeroize` call on exactly that subrange restore the entire original
outer interval to zero while preserving storage outside the second call's
frame?

## 5.3 Symbolic interval structure

Let:

```text
I = [outer_offset, outer_offset + outer_length)
J = [repair_start, repair_start + repair_length)
```

with:

```text
J is non-empty
J is contained completely inside I
I is contained completely inside the 16-byte host object
```

The harness constrained:

```text
host[outer_offset] != 0 before the first call
host[repair_start] != 0 after recontamination
```

These witnesses ensure that both the initial erase and the later repair have a
real nonzero byte to remove.

## 5.4 Temporal execution sequence

The harness performed:

```text
1. Zeroize the complete outer interval I.
2. Rewrite every byte in symbolic subrange J nondeterministically.
3. Require a concrete rewritten byte in J to be nonzero.
4. Save the state immediately before the second call.
5. Zeroize only J.
```

The real target was therefore called twice, with an adversarial state-changing
operation between the calls.

## 5.5 Proved properties

### SA-ZERO-T2.P1 — First erasure is effective

```text
host_after_first_call[outer_offset] = 0
```

CBMC assertion:

```text
SA_ZERO_T2_FIRST_ERASURE_WITNESS_ZERO
```

### SA-ZERO-T2.P2 — Complete outer interval recovery

```text
For every i in I:
host_final[i] = 0
```

CBMC assertion:

```text
SA_ZERO_T2_OUTER_INTERVAL_FULL_RECOVERY
```

This is the primary temporal-recovery theorem. Bytes of `I` outside `J` remain
zero from the first call, while the second call removes the newly introduced
contents of `J`.

### SA-ZERO-T2.P3 — Original outer frame is preserved

```text
For every i outside I:
host_final[i] = original[i]
```

CBMC assertion:

```text
SA_ZERO_T2_ORIGINAL_OUTER_FRAME_PRESERVED
```

### SA-ZERO-T2.P4 — Second-call frame is preserved

```text
For every i outside J:
host_final[i] = state_immediately_before_second_call[i]
```

CBMC assertion:

```text
SA_ZERO_T2_SECOND_CALL_FRAME_PRESERVED
```

This property is stronger than checking only the final outer frame. It directly
constrains the second target execution not to alter any byte outside its own
requested subrange.

### SA-ZERO-T2.P5 — Recontamination witness was genuinely nonzero

```text
state_immediately_before_second_call[repair_start] != 0
```

CBMC assertion:

```text
SA_ZERO_T2_RECONTAMINATION_WITNESS_WAS_NONZERO
```

### SA-ZERO-T2.P6 — Recontamination witness is erased

```text
host_final[repair_start] = 0
```

CBMC assertion:

```text
SA_ZERO_T2_RECONTAMINATION_WITNESS_REERASED
```

### SA-ZERO-T2.P7 — Exact target-call count

```text
target_calls = 2
```

CBMC assertion:

```text
SA_ZERO_T2_TARGET_CALL_COUNT
```

## 5.6 Reachability and feasibility obligations

The separate reachability model established:

```text
SA_ZERO_T2_ASSUMPTIONS_FEASIBLE
SA_ZERO_T2_INITIAL_NONZERO_WITNESS
SA_ZERO_T2_TARGET_1_REACHED
SA_ZERO_T2_RECONTAMINATION_REACHED
SA_ZERO_T2_NONZERO_RECONTAMINATION_WITNESS
SA_ZERO_T2_TARGET_2_REACHED
SA_ZERO_T2_ASSERTION_BLOCK_REACHED
```

These obligations establish that the first call, intervening recontamination,
nonzero rewritten witness, second call, and final assertions were all
reachable under one satisfiable symbolic model.

## 5.7 Expected-failure sensitivity control

The fail-control model deliberately asserted that the rewritten witness
survived:

```text
host_final[repair_start] != 0
```

Named property:

```text
SA_ZERO_T2_FC_RECONTAMINATION_PERSISTS
```

CBMC was required to reject this false claim at that exact property. Tool
errors or unrelated assertion failures were not accepted as sensitivity
evidence.

# 6. Combined theorem meaning

Together, the two theorem families establish two complementary guarantees:

1. **Relational information removal:** selected secret-history differences
   between two objects disappear from their complete bounded post-states.
2. **Temporal recovery:** data reintroduced after an earlier wipe can be
   removed by a correctly targeted later wipe without corrupting storage
   outside the later call's frame.

The result is stronger than a single assertion that one chosen buffer becomes
zero. It covers two executions, relational pre-state differences, an
intervening adversarial write, nested symbolic intervals, and both original and
second-call frame conditions.

# 7. Retained assumptions and proof boundary

The accepted proofs rely on the following explicit assumptions:

- both target pointers refer to valid writable slices;
- the native non-aliasing requirement is satisfied;
- all symbolic intervals fit inside the 16-byte host object;
- nondeterministic `uint8_t` values represent the complete byte domain;
- explicit difference and nonzero witnesses are satisfiable;
- unwind 17 is sufficient for the bounded loops and is checked;
- CBMC, `goto-cc`, and `goto-instrument` 6.9.0 are trusted;
- the GCC-compatible branch containing the real zero-valued memory write and
  compiler barrier is the branch modeled in this environment.

The campaign does not establish:

- physical-memory remanence resistance;
- cache, register, swap, DMA, or storage-device erasure;
- correctness of every compiler optimization or generated binary;
- Windows `SecureZeroMemory` semantics;
- a user-supplied custom zeroizer;
- arbitrary object lengths beyond the documented bounded harness;
- universal correctness of every future `mlkem-native` revision.

# 8. Body binding and evidence integrity

For each theorem, the corpus retained:

```text
proof model
reachability model
expected-failure model
preprocessed harness
GOTO function inventory
GOTO symbol inventory
GOTO loop inventory
GOTO property inventory
CBMC proof JSON
reachability result JSON
expected-failure trace
exit-code records
body-binding JSON
per-theorem SHA-256 record
```

Acceptance required the proof model to retain the real `mlk_zeroize` path and
the zero-valued memory operation. Target stubbing, contract replacement,
production-source modification, `assume(false)`, contradictory assumptions,
and counting a tool failure as proof were forbidden.

# 9. Final scientific claim

The strongest supported claim is:

> At `mlkem-native` commit
> `af4c5abdd5958bdc65a03cd5ee86708264f93304`, CBMC 6.9.0 verified, within
> the documented 16-byte C-level bounded model, that the real `mlk_zeroize`
> implementation eliminates selected secret-history differences from the
> complete post-state of two related objects and restores a previously wiped
> interval after symbolic nonzero subrange recontamination, while preserving
> the relevant outer frames. Named feasibility, target-reachability,
> assertion-reachability, body-binding, and expected-failure controls all
> passed in the sole accepted run.

This is a bounded source-level result, not a claim of universal or physical
erasure.
