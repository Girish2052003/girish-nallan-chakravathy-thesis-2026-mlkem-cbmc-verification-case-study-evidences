# CBMC `__CPROVER_cover` Incompatible-Redeclaration Robustness Finding

## Status

This directory documents an **independently discovered and minimised CBMC robustness/type-handling finding** identified during the `mlk_poly_frommsg` case study.

The controlled behaviour was reproduced in the tested official Docker image tags:

- `diffblue/cbmc:6.9.0`
- `diffblue/cbmc:6.10.0`

The status of a pinned `develop` revision remained unresolved in the accepted evidence. Maintainer confirmation, global priority, security severity, and a fixed-version classification are not claimed.

## Summary

Canonical use of the CBMC built-in `__CPROVER_cover` completed normally. In contrast, manually redeclaring that built-in with an incompatible C `_Bool` or `int` parameter type and requesting coverage instrumentation with `--cover cover` caused the tested CBMC versions to terminate through an internal `not_exprt` Boolean-expression invariant instead of issuing a controlled incompatible-declaration diagnostic.

The finding was reduced to a minimal standalone reproducer independent of ML-KEM. A separate direct-body CBMC campaign established the selected `mlk_poly_frommsg` binary-embedding property in the frozen model, so the coverage-instrumentation failure is not evidence of an ML-KEM implementation defect.

## Detailed technical report

The complete investigation record is preserved in:

[`MLK_POLY_FROMMSG_CBMC_COMPLETE_A_TO_Z_TECHNICAL_RECORD_20260727.md`](./MLK_POLY_FROMMSG_CBMC_COMPLETE_A_TO_Z_TECHNICAL_RECORD_20260727.md)

That report documents the full case-study context, including native-proof triage, counterexample admissibility analysis, direct-body model construction, exact unwind calibration, reachability and mutation controls, crash minimisation, canonical-versus-malformed isolation, cross-version reproduction, evidence hashes, limitations, and publication-safe wording.

The report is broader than this finding directory because it records both:

1. the property-specific `mlk_poly_frommsg` direct-body verification result; and
2. the separate CBMC robustness/type-handling finding.

## Reproducible evidence

Commands, source reproducers, symbol inspections, standard output, standard error, return codes, result matrices, Docker environment bindings, binary identities, manifests, and frozen evidence packets are preserved under:

[`experiments/poly-frommsg/05-cbmc-coverage-and-toolchain-investigation`](../../experiments/poly-frommsg/05-cbmc-coverage-and-toolchain-investigation/)

This finding directory is the **human-readable index and interpretation layer**. The experiment tree is the **reproducible execution-evidence layer**. The technical report does not replace the raw evidence.

Key investigation stages described in the report include:

- `FROMMSG00D1_COVERAGE_ABORT_MINIMIZATION`
- `FROMMSG00D1R1_CANONICAL_COVER_ISOLATION`
- `FROMMSG00D2_CROSS_VERSION_*`
- `FROMMSG00D2R1_*`
- `FROMMSG00D3_*`

## Minimal trigger

An incompatible redeclaration can be represented by:

```c
void __CPROVER_cover(_Bool condition);

int main(void)
{
  __CPROVER_cover((_Bool)1);
  return 0;
}
```

with:

```sh
cbmc reproducer.c --function main --cover cover
```

The expected robust behaviour is a controlled diagnostic rejecting or otherwise safely handling the incompatible declaration. The affected tested behaviour was fatal termination through an internal invariant containing the stable diagnostic fingerprint:

```text
Invariant check failed
not_exprt
operand.is_boolean()
```

## Controlled differential

| Case | Tested outcome |
|---|---|
| Canonical `__CPROVER_cover` use | Normal completion |
| Canonical use with `--show-test-suite` | Normal completion |
| Incompatible `_Bool` redeclaration | Fatal internal invariant |
| Incompatible `int` redeclaration | Fatal internal invariant |

The same differential was reproduced in the tested CBMC 6.9.0 and 6.10.0 Docker image tags. The evidence is bound to those tested images, binaries, commands, and configurations; behaviour in other revisions may differ.

## Scientific scope

The preserved evidence supports the following description:

> A reproducible CBMC robustness/type-handling defect was independently isolated in which incompatible manual redeclarations of `__CPROVER_cover` trigger an internal Boolean-expression invariant during coverage instrumentation in the tested CBMC 6.9.0 and 6.10.0 Docker image tags, while canonical controls complete normally.

The evidence does **not** establish:

- an ML-KEM implementation vulnerability;
- an incorrect `mlk_poly_frommsg` production computation;
- a SAT or SMT solver defect;
- a general failure of canonical CBMC coverage;
- unsound verification success;
- a confirmed security vulnerability;
- major severity;
- that a pinned `develop` revision is affected or fixed;
- worldwide first discovery; or
- maintainer confirmation.
