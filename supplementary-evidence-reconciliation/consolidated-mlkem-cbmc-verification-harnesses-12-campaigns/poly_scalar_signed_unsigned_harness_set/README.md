# CANON Harness Collection

This directory contains convenience copies of the authoritative frozen
CANON theorem and coverage harnesses.

## Source campaign

- Repository: mlkem-native
- Pinned commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Primary target: `mlk_scalar_signed_to_unsigned_q`
- Composition target: `mlk_barrett_reduce`
- CBMC version: 6.9.0
- Campaign status: ACCEPTED

## Contents

- `CANON-T1`: exact fibres and equivalence classes
- `CANON-T2`: retraction and normalization dynamics
- `CANON-T3`: modular-operation compatibility
- `CANON-T4`: actual-body Barrett-normalizer composition

Each family contains:

- one theorem-only harness;
- one coverage-only harness;
- the theorem Makefile; and
- the coverage Makefile.

These files are copied from the corresponding final campaign `00_freeze`
directory. The original evidence directories remain authoritative and were not
modified by this collection operation.
