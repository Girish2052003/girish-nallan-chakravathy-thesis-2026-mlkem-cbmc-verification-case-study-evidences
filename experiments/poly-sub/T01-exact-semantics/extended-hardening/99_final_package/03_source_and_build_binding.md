# Source and build binding

- Frozen commit: `d9613cf60de3132d32475c102d8c2781d84feb34`
- Frozen source status: clean
- Production source: `00_frozen_source/mlkem-native/mlkem/src/poly.c`
- Portable implementation selected: yes
- Assembly path selected: no
- Function-contract body replacement: no
- Target execution order:
  1. `mlk_poly_sub`
  2. `mlk_poly_reduce`
  3. `mlk_poly_reduce_c`
  4. `mlk_barrett_reduce`
  5. `mlk_scalar_signed_to_unsigned_q`

The positive model contains ten reachable fixed-bound loops and 89 verified
properties.
