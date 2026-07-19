# SUB00N B4.4 — Frozen SUB-T4 Harness Family

## Campaign root

`/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3`

## Frozen commit

`d9613cf60de3132d32475c102d8c2781d84feb34`

## Parameter configuration

- `MLK_CONFIG_PARAMETER_SET=768`
- `MLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00n_b4`
- `MLK_CONFIG_NO_ASM=1`
- `MLK_CONFIG_CUSTOM_ZEROIZE=1`

## Harnesses

1. `harnesses/sub_t4_canonical_domain_harness.c`
   - Positive canonical-domain range and representability theorem.
2. `harnesses/sub_t4_reachability_harness.c`
   - Five satisfiability and reachability goals.
3. `harnesses/sub_t4_invalid_upper_harness.c`
   - Deliberately false stricter upper bound.
4. `harnesses/sub_t4_invalid_lower_harness.c`
   - Deliberately false stricter lower bound.

## Positive-theorem assumption boundary

The positive harness assumes only:

- every A coefficient is in `[0,3329)`;
- every B coefficient is in `[0,3329)`.

It does not assume that subtraction is representable.

The representability and exact `[-3328,3328]` bounds are assertions.

## Production binding

Every harness calls the genuine production `mlk_poly_sub` body from:

`/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3/source/mlkem/src/poly.c`

No replacement subtraction implementation is present in a harness.

## Support artefacts

The previously validated fail-closed adapter, pragma-scope header and
optimization-blocker source were copied into this package.

The pragma-scope namespace was changed mechanically from
`mlk_sub00g_r2` to `mlk_sub00n_b4`.

## Execution boundary

At this freeze stage:

- no GOTO model was created;
- no CBMC theorem was executed;
- no coverage command was executed;
- no production source was modified;
- no Batch-3 artefact or process was touched.

Exact reachable loop identifiers and unwindsets will be frozen only
after the four GOTO models are built and inspected.
