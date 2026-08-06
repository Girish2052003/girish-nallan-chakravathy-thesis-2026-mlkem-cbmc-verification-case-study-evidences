# SUB-00I Independent Coverage and Non-Vacuity Review

## Verdict

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**SUB-00I is accepted as a successful coverage/non-vacuity run.**

The wrapper's displayed `COVERAGE_GOALS=0` result was a parser defect. It was
not a CBMC coverage failure.

The raw CBMC 6.9.0 JSON stores coverage information under:

- `goals`
- `goalsCovered`
- `totalGoals`
- `tests`

The wrapper incorrectly searched only for theorem-style `result` and
`cProverStatus` objects. Those keys are absent in this coverage-mode JSON.

## Archive integrity

- Retained archive SHA-256: `02dc578425a8851f532667717c3c080ea756f10f0ef859662a6e736b60bcaae5`
- Retained sidecar SHA-256: `02dc578425a8851f532667717c3c080ea756f10f0ef859662a6e736b60bcaae5`
- Sidecar match: `PASS`
- Archive members: `77`
- Unsafe archive paths: `0`
- Links or device entries: `0`
- Internal manifest entries: `72`
- Internal manifest failures: `0`
- Unmanifested evidence files: `0`

## Execution integrity

- Raw CBMC exit code: `0`
- Final GOTO validation exit code: `0`
- stderr size: `0 bytes`
- Coverage GOTO model SHA-256:
  `b1384631b0ad463807ab656a2d3fb13cf86c0c41bd468e4693e93b9d7fdbaf8a`
- Frozen coverage harness SHA-256:
  `132c34161c8230eb14e86acc0cae3af52fbf6eb429a8e55233080337dc4415d7`
- Executed runner SHA-256:
  `c2fb4f4ea9b69f203673e3f6a6a063baeb9145f9a95bf63e5590f17422024aa4`
- Executed runner matches the distributed runner: `YES`
- Exact expected/actual loop lists match: `YES`
- Explicit cover calls in frozen harness: `8`
- Explicit cover calls in GOTO model: `8`
- All cover calls occur after production `poly_reduce`: `YES`

## Raw CBMC coverage result

CBMC reports:

```text
** 8 of 8 covered (100.0%)
```

- Total goals: `8`
- Covered goals: `8`
- Satisfied goals:
  `8`
- Unsatisfied goals:
  `0`
- Generated test-suite witnesses: `3`

| Goal | Description | Status |
|---|---|---|
| `main.coverage.1` | condition 'has_positive_difference != 0' | `SATISFIED` |
| `main.coverage.2` | condition 'has_negative_difference != 0' | `SATISFIED` |
| `main.coverage.3` | condition 'has_zero_difference != 0' | `SATISFIED` |
| `main.coverage.4` | condition 'has_noncanonical_positive_input != 0' | `SATISFIED` |
| `main.coverage.5` | condition 'has_noncanonical_negative_input != 0' | `SATISFIED` |
| `main.coverage.6` | condition 'has_int16_min_difference != 0' | `SATISFIED` |
| `main.coverage.7` | condition 'has_int16_max_difference != 0' | `SATISFIED` |
| `main.coverage.8` | condition '1 != 0' | `SATISFIED` |

## Witness review

CBMC generated three cumulative test-suite witnesses.

The third witness covers all eight goals simultaneously. Its 256 input
coefficient pairs satisfy every representability assumption. It contains:

- positive coefficient differences;
- negative coefficient differences;
- zero coefficient differences;
- non-canonical positive inputs;
- non-canonical negative inputs;
- an exact `INT16_MAX` difference;
- an exact `INT16_MIN` difference;
- execution reaching the unconditional cover goal after production
  subtraction and reduction.

Concrete extreme witnesses from test 3:

```text
index 61:
A = 8326
B = -24441
A - B = 32767
value after poly_sub = 32767
value after poly_reduce = 2806

index 252:
A = -32768
B = 0
A - B = -32768
value after poly_sub = -32768
value after poly_reduce = 522
```

These canonical outputs agree with the boundary values recorded for the
campaign.

## Coverage interpretation

Coverage mode reports satisfiable witnesses, not a new correctness proof.
The raw JSON explicitly says that existing assertions are rewritten as
assumptions for coverage. The run also omits unwinding assertions because
coverage mode does not use them as a proof obligation.

Therefore SUB-00I establishes:

- the theorem input assumptions are satisfiable;
- the production `poly_sub -> poly_reduce` composition is reachable;
- every preregistered scenario is reachable;
- the two signed 16-bit boundary differences are reachable;
- the successful SUB-T1 result is not explained by an empty input domain.

SUB-00I does **not** independently establish:

- functional correctness;
- absence of all runtime failures;
- novelty;
- worldwide prior-art absence.

Those boundaries are satisfied by combining SUB-00I with the separately
accepted SUB-T1 correctness evidence, not by interpreting coverage as proof.

## Correct classification

```text
SUB00I_CLASSIFICATION=COVERAGE_PASS_ACCEPTED_AFTER_INDEPENDENT_REVIEW
RAW_CBMC_EXIT_CODE=0
TOTAL_GOALS=8
COVERED_GOALS=8
UNSATISFIED_GOALS=0
TEST_SUITE_WITNESSES=3
NONVACUITY_ESTABLISHED=YES
NOVELTY_ESTABLISHED_BY_THIS_RUN=NO
```

The original wrapper summary and classification must be retained as evidence
of the parser defect. They must not be silently overwritten.
