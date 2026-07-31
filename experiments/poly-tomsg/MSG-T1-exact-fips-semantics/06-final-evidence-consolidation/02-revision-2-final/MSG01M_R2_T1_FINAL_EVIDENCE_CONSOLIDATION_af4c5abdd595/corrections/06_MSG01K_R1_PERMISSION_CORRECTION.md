# MSG-01K-R1 — Read-Only Copy Permission Correction

The first combined MSG-01K/L attempt stopped during generation of mutant I1.

The generator used `shutil.copy2()` to copy the frozen authoritative harness
and source files. `copy2()` preserved their read-only `0444` file modes. The
generator then attempted to write the isolated copies and received
`PermissionError`.

The failure occurred before:

- completion of any mutant;
- construction or validation of any mutant GOTO;
- any mutant CBMC property solving.

MSG-01K-R1 preserves the failed attempt and changes only the isolated-copy
mechanism:

1. `shutil.copyfile()` copies bytes without preserving the frozen mode;
2. each isolated copy is explicitly set to mode `0644`;
3. the authoritative frozen files remain unchanged and read-only;
4. the one-changed-file and byte-difference audits remain mandatory.

```text
FAILED_MSG01K_L_CLASSIFICATION=PRE_MUTATION_GENERATION_COPY2_PERMISSION_PRESERVATION
MUTANT_GENERATION_COMPLETED=NO
MUTANT_GOTO_BUILD_EXECUTED=NO
MUTANT_CBMC_SOLVING_EXECUTED=NO
```
