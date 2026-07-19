# VC-SR1 structural model audit

- Classification: `PASS`
- Required-function count: `6`
- Missing-function count: `0`
- Reachable-loop count: `10`
- Property count: `75`

## Checks

- `all_required_functions_present`: `PASS`
- `main_calls_sub_before_reduce`: `PASS`
- `subtraction_executable_body_present`: `PASS`
- `reduce_wrapper_calls_reduce_c`: `PASS`
- `reduce_c_calls_barrett_reduce`: `PASS`
- `reduce_c_calls_signed_to_unsigned`: `PASS`
- `frozen_poly_source_referenced`: `PASS`
- `native_reduction_path_absent`: `PASS`
- `contract_expansion_absent`: `PASS`
- `reachable_loop_inventory_nonempty`: `PASS`
- `property_inventory_nonempty`: `PASS`

## Reachable loop identifiers

- `main.0`
- `main.1`
- `main.2`
- `main.3`
- `mlk_vc_sr1_poly_sub.0`
- `mlk_barrett_reduce.0`
- `mlk_poly_reduce_c.0`
- `mlk_poly_reduce_c.1`
- `mlk_scalar_signed_to_unsigned_q.0`
- `mlk_scalar_signed_to_unsigned_q.1`
