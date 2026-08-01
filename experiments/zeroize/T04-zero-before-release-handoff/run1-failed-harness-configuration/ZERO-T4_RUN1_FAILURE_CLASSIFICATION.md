# ZERO-T4 RUN1 Failure Classification

## Classification

`HARNESS_CONFIGURATION_COMPILE_FAILURE`

## Stage reached

Static source inspection passed, but all three harnesses failed during
GOTO conversion or preprocessing. CBMC verification was not executed.

## Causes

1. The native CBMC configuration enables custom allocation/free macros.
   Therefore, the intended default-branch harness did not declare the
   stack-backed `mlk_alloc_secret` array.

2. The custom harnesses defined `MLK_CUSTOM_ALLOC` and `MLK_CUSTOM_FREE`
   before including the native CBMC configuration, which already defines
   those macros. With `-Werror`, preprocessing rejected the redefinitions.

## Meaning

This is not:

- an `mlk_zeroize` implementation failure;
- an `MLK_FREE` semantic counterexample;
- a CBMC theorem failure;
- a production-source modification.

The failure occurred before theorem execution.

## Corrective action

Run2 uses isolated configuration-wrapper headers:

- a default wrapper that removes the CBMC configuration's custom allocator;
- a custom wrapper that replaces the CBMC allocator macros after importing
  all other native CBMC settings.

The authoritative repository remains unchanged.
