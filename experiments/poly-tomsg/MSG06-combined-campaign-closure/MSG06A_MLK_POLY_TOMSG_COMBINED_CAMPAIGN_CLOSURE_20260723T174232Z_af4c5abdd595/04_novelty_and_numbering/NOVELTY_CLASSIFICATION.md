# Novelty Classification

## Not claimed as novel

The campaign does not claim novelty for:

- ML-KEM or FIPS 203;
- the standard `Compress1` operation;
- the modulus, polynomial size, or message packing convention;
- CBMC, formal verification, relational verification, or mutation testing;
- broad formal verification of `mlkem-native`;
- the broad idea of LLM-assisted formal verification.

## Repository-level novelty

Inspection of the frozen native source, contracts, harnesses, Makefiles, and proof tree found fixed-function proof infrastructure for `mlk_scalar_compress_d1` and `mlk_poly_tomsg`.

No equivalent frozen native theorem obligation was located for the complete MSG-T1 all-bit oracle refinement, the MSG-T2 relational family, or the MSG-T5 exact symbolic-offset characterization.

Repository-level novelty is therefore accepted.

## Campaign-level originality

The integrated package is independently authored and combines:

- exact fixed-function semantics;
- two-execution relational properties;
- an exact production-bound parameter interval;
- independent oracle validation;
- reachability and non-vacuity;
- insufficient-bound controls;
- implementation, assertion, antecedent, and endpoint mutations;
- deterministic source/GOTO/result/archive binding;
- preserved correction history.

Campaign-level distinctness is accepted.

## Global novelty

A public review completed on 23 July 2026 located no exact match for the combined T1/T2/T5 theorem-and-evidence package and no exact public match for the T5 endpoint interval.

A public search cannot exclude unpublished, private, unindexed, differently named, or future work.

The defensible claim is:

> distinct from the frozen native proof obligations inspected and apparently original in the reviewed public record.

The prohibited claim is:

> an unconditional first-ever proof.
