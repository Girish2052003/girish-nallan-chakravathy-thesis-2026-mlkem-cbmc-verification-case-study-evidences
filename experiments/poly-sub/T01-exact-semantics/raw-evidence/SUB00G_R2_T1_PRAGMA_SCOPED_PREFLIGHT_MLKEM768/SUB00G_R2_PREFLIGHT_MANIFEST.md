# SUB-00G-R2 Pragma-Scoped Corrected-Model Preflight

## Scope

This stage performs model construction and inspection only.

- CBMC theorem execution: **not performed**
- Coverage execution: **not performed**
- Frozen SUB-T1 harness modified: **no**
- Production poly.c modified: **no**
- Function-contract abstraction used: **no**
- Loop contracts applied: **no**

## Corrections tested

1. The namespaced portable value-barrier blocker is defined as volatile
   64-bit zero in a separate environment translation unit.
2. CBMC remains globally undefined.
3. cbmc.h is first included with CBMC undefined, keeping contracts disabled.
4. CBMC is then defined only while verify.h is parsed, activating the
   repository's narrowly scoped conversion-check pragma.
5. CBMC is undefined before production poly.c and the theorem harness are
   parsed.

## Identity

- Frozen commit:
  `d9613cf60de3132d32475c102d8c2781d84feb34`
- Namespace:
  `mlk_sub00g_r2`
- Frozen harness SHA-256:
  `42c09c2f004d567d8b886058bd2304d960a219d36f0f6605b015966db3bc5682`
- Corrected model SHA-256:
  `e9bef62631fbad4711d3eebf1ff8c48d5c2ea29d4dc4b4e9ef588ff6805260bb`
- Reachable-only inspection model SHA-256:
  `4a799f584939e3ef2bf461076aeaa3abf3b6df9deebc2c5cc65b66dc9d757416`
- Pragma adapter SHA-256:
  `5c39e68460e2660da0d76d21797893cb6ec47988ee9a1cc863cf709838e8568c`
- Zero-blocker adapter SHA-256:
  `300d4d8bc2b8d467356ba2548920ccef509d9e03d748d3151f42ec3608a9aa19`
- Exact future unwindset:
  `main.0:257,main.1:257,main.2:257,main.3:257,mlk_barrett_reduce.0:2,mlk_sub00g_r2_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2`

## Repository comparison already frozen

The dedicated repository poly_sub harness at the frozen commit calls only
`mlk_poly_sub(r, b)` and relies on the existing function contract. It does
not call `mlk_poly_reduce`, compute an independent modular oracle, or state
the SUB-T2 relational equation.

This is a repository-level distinction only. It is not a worldwide novelty
claim.

## Next gate

No theorem runner is authorized until this preflight package is independently
reviewed.
