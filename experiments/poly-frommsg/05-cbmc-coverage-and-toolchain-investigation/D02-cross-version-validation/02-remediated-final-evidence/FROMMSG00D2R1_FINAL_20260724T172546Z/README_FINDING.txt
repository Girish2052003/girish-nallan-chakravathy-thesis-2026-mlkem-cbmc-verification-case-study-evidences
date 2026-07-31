Finding under test:

Canonical CBMC __CPROVER_cover usage works normally.

However, manually redeclaring __CPROVER_cover using an incompatible
parameter type such as C _Bool or int, followed by --cover cover,
may cause an internal not_exprt Boolean-expression invariant failure
instead of a controlled incompatible-declaration diagnostic.

This is a robustness/type-handling finding.

It is not:
- a solver defect;
- an ML-KEM implementation defect;
- a general coverage failure;
- evidence of unsound verification success;
- a security vulnerability.
