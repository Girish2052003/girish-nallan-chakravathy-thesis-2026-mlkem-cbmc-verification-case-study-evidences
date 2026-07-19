# SUB-00E External Build-Adapter Note

## Reason

The SUB-00E portable-C build uses `MLK_CONFIG_NO_ASM`.

On the non-Windows verification host, mlkem-native therefore requires
`MLK_CONFIG_CUSTOM_ZEROIZE` and an externally supplied definition of
`mlk_zeroize()`.

## Implementation

The accompanying external header provides a volatile byte-wise clearing
loop. It is force-included only as part of the recorded verification
build configuration.

## Assurance boundary

The adapter:

- does not modify the frozen mlkem-native source tree;
- does not modify `poly.c`, `poly_sub`, or repository headers;
- does not modify any frozen SUB-00C harness;
- does not alter SUB-T1 or SUB-T2 assumptions or assertions;
- does not use the existing repository poly_sub proof harness;
- is not evidence that secure zeroization has been formally verified;
- exists only to satisfy an unrelated translation-unit configuration
  requirement during GOTO-model construction.

The selected production `poly.c` translation unit contains no direct
reference to `mlk_zeroize` or `MLK_FREE`.
