# ZERO-V1 Mutation Registry

## Purpose

ZERO-V1 evaluates whether the accepted theorem harnesses reject deliberately
faulty implementations or release sequences.

A mutant is classified as killed only when:

1. the mutant compiles successfully;
2. the relevant target or release sequence is reached;
3. CBMC returns a semantic counterexample;
4. the failure is a planned property or safety-property failure;
5. the result is not a timeout, compiler error or tool error.

## Mutants

### ZERO-V1.M1 — Remove wipe

Replace the zero-valued memory overwrite with no overwrite.

Expected detector:

- ZERO-T1 exact erasure;
- ZERO-T1 non-vacuity.

### ZERO-V1.M2 — Fill with one

Replace the zero fill value with byte value `1`.

Expected detector:

- ZERO-T1 exact erasure.

### ZERO-V1.M3 — Length minus one

Wipe one byte fewer than requested for non-empty intervals.

Expected detector:

- ZERO-T1 exact erasure;
- final-byte witness.

### ZERO-V1.M4 — Pointer plus one

Begin wiping one byte after the requested start and reduce the length
accordingly.

Expected detector:

- ZERO-T1 exact erasure;
- first-byte witness.

### ZERO-V1.M5 — Length plus one

Wipe one byte beyond the requested interval.

Expected detector:

- ZERO-T2 suffix-frame property;
- pointer/bounds safety when applicable.

### ZERO-V1.M6 — Free before wipe

Invoke the observational custom free hook before zeroization.

Expected detector:

- ZERO-T4.P3 all-zero release observation;
- zero-before-free order evidence.

### ZERO-V1.M7 — Double custom free

Invoke the custom free hook twice for a non-null allocation.

Expected detector:

- ZERO-T4.P4 exactly-once release.

### ZERO-V1.M8 — Omit one adjacent partition

Execute only the first of two adjacent zeroization operations while comparing
against zeroization of the complete union.

Expected detector:

- ZERO-T3.P2 adjacent partition equivalence;
- ZERO-T3.NV2 partition non-vacuity.

## Source isolation

Mutations must be applied only to workspace-local source copies or
harness-local mutant macros.

The authoritative repository must remain unchanged.
