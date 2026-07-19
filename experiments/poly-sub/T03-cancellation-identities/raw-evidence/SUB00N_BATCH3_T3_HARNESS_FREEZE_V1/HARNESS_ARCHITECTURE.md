# SUB00N T3 Harness Architecture

## Universal theorem harnesses

1. `sub_t3a_exact_sub_add_harness.c`
2. `sub_t3b_exact_add_sub_harness.c`
3. `sub_t3c_modular_cancellation_harness.c`

## Reachability harness

4. `sub_t3_coverage_harness.c`

## Boundary controls

5. `sub_t3a_valid_lower_harness.c`
6. `sub_t3a_valid_upper_harness.c`
7. `sub_t3a_invalid_lower_harness.c`
8. `sub_t3a_invalid_upper_harness.c`
9. `sub_t3b_valid_lower_harness.c`
10. `sub_t3b_valid_upper_harness.c`
11. `sub_t3b_invalid_lower_harness.c`
12. `sub_t3b_invalid_upper_harness.c`
13. `sub_t3c_recovery_sum_boundaries_harness.c`

The common header contains only machine-model checks, FIPS parameter
bindings, and a deterministic zero-initialization helper. It does not
encode any cancellation conclusion.
