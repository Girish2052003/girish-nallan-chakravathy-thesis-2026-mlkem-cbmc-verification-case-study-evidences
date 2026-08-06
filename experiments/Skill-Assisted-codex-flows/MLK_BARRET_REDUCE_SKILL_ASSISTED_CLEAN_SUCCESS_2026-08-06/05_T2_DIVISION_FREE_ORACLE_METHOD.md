# SA-BR-T2 division-free oracle method

The direct `% 3329` centered-oracle assertion timed out under CBMC 6.9.0
and Z3. The theorem was not weakened. The complete mathematical sum domain
of two `int16_t` operands, `[-65536, 65534]`, was partitioned into 41
contiguous centered-residue intervals. For interval `k`, the harness proves

`r_sum = full_sum - k * 3329`.

The intervals are exhaustive and mutually exclusive, and the harness proves
that exactly one interval matches every symbolic input pair. These case
properties jointly establish the same centered-oracle equality and full-sum
congruence without division or remainder. The production function, theorem
assumptions, and three target calls remain unchanged.
