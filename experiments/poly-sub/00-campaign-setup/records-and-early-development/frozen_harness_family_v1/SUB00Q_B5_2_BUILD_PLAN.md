# SUB00Q B5.2 — Frozen Build Plan

## Authoritative compiler family

`goto-cc 6.9.0`

## Expected installation path

```text
/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/SUB00Q_BATCH5_T5_RELATIONAL/frozen_harness_family_v1
```

## Common compilation model

```bash
BASE=/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3
SRC="$BASE/source/mlkem"
FAMILY="$BASE/SUB00Q_BATCH5_T5_RELATIONAL/frozen_harness_family_v1"
BUILD="$BASE/SUB00Q_BATCH5_T5_RELATIONAL/B5_4_GOTO_PREFLIGHT_MLKEM768/build"
mkdir -p "$BUILD"

goto-cc -std=c90 \
  -DMLK_CONFIG_PARAMETER_SET=768 \
  -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00q_b5 \
  -DMLK_CONFIG_NO_ASM=1 \
  -DMLK_CONFIG_CUSTOM_ZEROIZE=1 \
  -include "$FAMILY/support/sub00q_b5_fail_closed_zeroize.h" \
  -include "$FAMILY/support/sub00q_b5_verify_pragma_scope.h" \
  -I"$SRC" \
  -I"$SRC/src" \
  -I"$FAMILY/support" \
  "$FAMILY/harnesses/<selected-harness>.c" \
  "$SRC/src/poly.c" \
  "$FAMILY/support/sub00q_b5_optblocker_zero.c" \
  -o "$BUILD/<case>.goto"
```

Each harness must be built into a separate GOTO binary. Expected-failure
controls must never share a binary or result directory with positive cases.

## B5.4 inspection requirements

For every case record: exact command, exit code, GOTO hash, validation,
functions, symbols, reachable call graph, undefined functions, loop identifiers,
property inventory, and the exact unwindset selected from the inspected model.

No unwindset is frozen at B5.2 because loop identifiers must come from the
actual constructed GOTO binaries rather than being guessed from source text.
