# Internal invariant when `__CPROVER_cover` is redeclared with an incompatible parameter type

## Summary

Canonical `__CPROVER_cover` usage works normally. In the tested official CBMC 6.9.0 and 6.10.0 Docker images, manually redeclaring the built-in with `_Bool` or `int` and running with `--cover cover` causes an internal `not_exprt` Boolean-expression invariant instead of a controlled diagnostic.

## Minimal reproducer

```c
void __CPROVER_cover(_Bool condition);

int main(void)
{
  __CPROVER_cover((_Bool)1);
  return 0;
}
```

## Command

```sh
cbmc reproducer.c --function main --cover cover
```

## Expected behaviour

CBMC should reject or safely diagnose the incompatible declaration. It should not terminate through an internal invariant.

## Actual behaviour

```text
Invariant check failed
function: not_exprt
Condition: as_const(*this).op().is_boolean()
```

## Canonical control

```c
int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
```

The control completes normally and reports the coverage goal as satisfied.

## Scope

This is a robustness/type-handling report concerning malformed use of a CBMC built-in. It is not a solver defect, ML-KEM defect, security vulnerability, general canonical-coverage failure, or unsound-success claim.
