from pathlib import Path
import sys
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from pathlib import Path

from agents.artifact_generation_agent import (
    ArtifactGenerationConfig,
    validate_rendered_harness,
)


cfg = ArtifactGenerationConfig(
    run_dir=Path("."),
    target_function="mlk_poly_add",
    cbmc_function="harness",
)


good_harness = r'''
#include "cbmc.h"
#include "poly.h"

void harness(void)
{
    mlk_poly *r;
    mlk_poly *b;

    __CPROVER_assume(
        memory_no_alias(r, sizeof(mlk_poly))
    );

    __CPROVER_assume(
        memory_no_alias(b, sizeof(mlk_poly))
    );

    mlk_poly_add(r, b);
}
'''

good_result = validate_rendered_harness(
    good_harness,
    cfg,
    {},
)

assert good_result["entry_function_defined"] is True
assert good_result["valid_for_handoff"] is True
assert good_result["blocking_patterns"] == []


wrong_entry_harness = good_harness.replace(
    "void harness(void)",
    "void harness_custom_name(void)",
)

wrong_entry_result = validate_rendered_harness(
    wrong_entry_harness,
    cfg,
    {},
)

assert wrong_entry_result["entry_function_defined"] is False
assert wrong_entry_result["valid_for_handoff"] is False
assert (
    "missing_exact_cbmc_entry_function"
    in wrong_entry_result["blocking_patterns"]
)


null_freshness_harness = good_harness.replace(
    "mlk_poly *r;",
    "mlk_poly *r = 0;",
)

null_freshness_result = validate_rendered_harness(
    null_freshness_harness,
    cfg,
    {},
)

assert null_freshness_result["valid_for_handoff"] is False
assert null_freshness_result["null_freshness_pointers"] == [
    "r"
]

assert (
    "null_initialized_pointer_used_with_freshness"
    in null_freshness_result["blocking_patterns"]
)

print(
    "LIVE HARNESS HARDENING REGRESSION TEST PASSED"
)
