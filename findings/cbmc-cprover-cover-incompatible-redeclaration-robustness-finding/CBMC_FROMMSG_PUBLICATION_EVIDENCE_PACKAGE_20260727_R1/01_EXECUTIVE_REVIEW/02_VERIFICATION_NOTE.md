# Verification Note: Isolated CBMC Robustness Finding

## 1. Executive finding

A direct-body CBMC campaign verified the selected binary-embedding property of the production `mlk_poly_frommsg` implementation using the real function body, exact unwind calibration, repeated runs, reachability witnesses and mutation controls.

A separate minimal experiment identified the following deterministic robustness behaviour:

- canonical `__CPROVER_cover` usage completes normally;
- manually redeclaring the built-in with `_Bool` or `int` changes its symbol-table type;
- requesting `--cover cover` then produces a fatal internal `not_exprt` Boolean-expression invariant instead of a controlled incompatible-declaration diagnostic;
- the pattern reproduces in the tested official CBMC 6.9.0 and 6.10.0 Docker images.

## 2. Production-function control

The selected theorem states that for every 32-byte message and each coefficient index `k` from 0 to 255, `mlk_poly_frommsg` writes `0` when the corresponding message bit is zero and `MLKEM_Q_HALF` when the bit is one.

The authoritative T1 campaign retained the real production body and necessary helpers. It used no contract replacement, contract havoc or `__CPROVER_assume`, and it did not modify the production source. The evidence contains:

- exact inner- and outer-loop unwind calibration;
- successful repeated proof runs;
- function-return reachability;
- reachable bit-zero and bit-one witnesses;
- rejection of false “always zero” and “always half” mutations;
- source/model/tool hashes and a complete evidence manifest.

This supports the selected property under the frozen source, model and CBMC configuration. It is not a claim of complete correctness for all ML-KEM behaviour.

## 3. Minimal robustness reproducer

Canonical control:

```c
int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
```

Malformed `_Bool` declaration:

```c
void __CPROVER_cover(_Bool condition);

int main(void)
{
  __CPROVER_cover((_Bool)1);
  return 0;
}
```

Malformed `int` declaration:

```c
void __CPROVER_cover(int condition);

int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
```

Relevant command:

```sh
cbmc reproducer.c --function main --cover cover
```

Canonical use reports its coverage goal as satisfied. In the affected tested releases, the incompatible declarations terminate with an internal report containing:

```text
Invariant check failed
function: not_exprt
Condition: as_const(*this).op().is_boolean()
```

The crash does not require `--show-test-suite`; `--cover cover` alone is sufficient.

## 4. Cross-version result

The defect pattern was reproduced in official Docker images tagged CBMC 6.9.0 and 6.10.0. In both environments:

- canonical coverage commands returned normally;
- `_Bool` and `int` incompatible redeclarations caused fatal internal invariant termination;
- the same `not_exprt` Boolean-condition invariant was reported;
- image identities, repository digests, CBMC binary hashes, commands, stdout, stderr and return codes were captured.

A completed pinned-`develop` result is not present in the uploaded evidence and is therefore not claimed here.

## 5. Scientific interpretation

The evidence supports the following statement:

> In the tested official CBMC 6.9.0 and 6.10.0 Docker images, an incompatible manual redeclaration of the built-in `__CPROVER_cover` can cause coverage instrumentation to reach an internal Boolean-expression invariant instead of returning a controlled diagnostic. Canonical use of the coverage built-in works normally.

The triggering programs are malformed because they replace the built-in parameter type. This lowers the likely severity but does not make an internal invariant termination desirable tool behaviour.

## 6. Explicitly excluded claims

The evidence does not establish:

- a SAT or SMT solver defect;
- an ML-KEM implementation defect or vulnerability;
- a general failure of canonical CBMC coverage;
- unsound successful verification;
- a security vulnerability;
- major severity;
- novelty or maintainer confirmation;
- affected/fixed status of the pinned `develop` revision.

## 7. Relationship between the campaigns

The direct-body T1 proof and the minimal robustness reproducer answer different questions. The T1 campaign provides a successful semantic control for the production implementation. The minimal reproducer isolates an internal tool failure caused by malformed handling of a built-in during coverage instrumentation. Together, they show that the observed internal coverage crash is not evidence that the selected production computation is incorrect.
