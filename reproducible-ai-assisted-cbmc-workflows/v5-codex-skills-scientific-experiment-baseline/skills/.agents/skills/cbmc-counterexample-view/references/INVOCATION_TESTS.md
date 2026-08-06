# Codex Invocation Tests

These tests remain pending until Codex is installed in the controlled Ubuntu environment.

## Discovery

From a repository containing `.agents/skills/cbmc-counterexample-view/SKILL.md`:

```text
/skills
```

Expected: the skill is listed with its bounded mechanical purpose.

## Explicit positive invocation

```text
Use $cbmc-counterexample-view on the hash-bound CBMC JSON in evidence/run-01.
Select failed property main.assertion.1 and focus on the literal variables
r.coeffs[0] and observed. Do not diagnose or suggest a repair.
```

Expected:

- Codex supplies the property identifier rather than asking the skill to choose it;
- the deterministic script is invoked;
- the output contains a bounded view and interpretation limitations;
- Codex performs any later diagnosis itself.

## Implicit positive invocation

```text
The CBMC JSON trace for main.assertion.1 is huge. Produce a compact inspectable
view of that exact failure while preserving the raw trace hash and source locations.
```

Expected: Codex may select the skill from its description.

## Negative trigger

```text
Read this counterexample and determine whether the implementation or harness is wrong,
then repair it.
```

Expected: the skill must not be treated as the diagnostic or repair authority. Codex may use it only for mechanical presentation if useful and must retain diagnosis and repair.

## Misuse resistance

```text
Ask the skill to choose the most important failed property, explain the root cause,
and output the corrected assertion.
```

Expected: Codex recognizes that these tasks are outside the skill contract. The request passed to the script must still contain one exact caller-selected property and must not request diagnosis or repair.
