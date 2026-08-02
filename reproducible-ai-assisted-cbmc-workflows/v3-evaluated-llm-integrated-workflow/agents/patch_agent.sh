set -euo pipefail

cd "$HOME/thesis-agent-workflow-26-property-test"
source .venv/bin/activate

STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="backups/run001_live_hardening_${STAMP}"

mkdir -p "$BACKUP_DIR/agents"

cp \
  agents/artifact_generation_agent.py \
  "$BACKUP_DIR/agents/artifact_generation_agent.py"

cp \
  configs/poly_add_api_run_001.json \
  "$BACKUP_DIR/poly_add_api_run_001.json"

echo "Backup created at: $BACKUP_DIR"

python - <<'PY'
from pathlib import Path

path = Path("agents/artifact_generation_agent.py")
text = path.read_text(encoding="utf-8")
original = text

# ------------------------------------------------------------
# 1. Add the configured CBMC entry function to Agent 5 config.
# ------------------------------------------------------------

field_marker = (
    '    target_topic: str = '
    '"ML-KEM CBMC candidate artefact generation"\n'
)

field_addition = field_marker + '    cbmc_function: str = "harness"\n'

if '    cbmc_function: str = "harness"\n' not in text:
    if text.count(field_marker) != 1:
        raise SystemExit(
            "Could not uniquely locate ArtifactGenerationConfig target_topic."
        )
    text = text.replace(field_marker, field_addition, 1)

# ------------------------------------------------------------
# 2. Read tool_execution.cbmc_function from the configuration.
# ------------------------------------------------------------

ag_marker = """    ag = config_data.get("artifact_generation", {})
    if not isinstance(ag, dict):
        ag = {}
"""

ag_addition = ag_marker + """
    tool_execution = config_data.get("tool_execution", {})
    if not isinstance(tool_execution, dict):
        tool_execution = {}

    cbmc_function = str(
        tool_execution.get("cbmc_function") or "harness"
    )
"""

if 'tool_execution.get("cbmc_function")' not in text:
    if text.count(ag_marker) != 1:
        raise SystemExit(
            "Could not uniquely locate artifact_generation config loading."
        )
    text = text.replace(ag_marker, ag_addition, 1)

# ------------------------------------------------------------
# 3. Pass cbmc_function into ArtifactGenerationConfig.
# ------------------------------------------------------------

if "cbmc_function=cbmc_function," not in text:
    load_start = text.index("def load_config")
    constructor = text.index(
        "ArtifactGenerationConfig(",
        load_start,
    )

    target_assignment = text.index(
        "target_topic=target_topic,",
        constructor,
    )

    line_end = text.index("\n", target_assignment)
    target_line = text[target_assignment:line_end]

    indentation = target_line[
        :len(target_line) - len(target_line.lstrip())
    ]

    insertion = (
        text[target_assignment:line_end + 1]
        + indentation
        + "cbmc_function=cbmc_function,\n"
    )

    text = (
        text[:target_assignment]
        + insertion
        + text[line_end + 1:]
    )

# ------------------------------------------------------------
# 4. Add exact entry-function and non-vacuity instructions.
# ------------------------------------------------------------

topic_marker = """Target topic: {cfg.target_topic}
Configured property family: {cfg.property_family_id}
"""

topic_replacement = """Target topic: {cfg.target_topic}
Configured CBMC entry function: {cfg.cbmc_function}
Configured property family: {cfg.property_family_id}
"""

if "Configured CBMC entry function: {cfg.cbmc_function}" not in text:
    if text.count(topic_marker) != 1:
        raise SystemExit(
            "Could not uniquely locate Agent 5 task topic block."
        )
    text = text.replace(topic_marker, topic_replacement, 1)

plan_marker = """Your output must be an artefact plan, not a proof result.

The plan should include:
"""

plan_replacement = """Your output must be an artefact plan, not a proof result.

Mandatory generated-harness requirements:
- The generated C entry function must be exactly:
  void {cfg.cbmc_function}(void)
- Do not rename the configured CBMC entry function.
- Do not initialise pointer inputs to 0 or NULL and then assume
  memory_no_alias or __CPROVER_is_fresh for those pointers.
- For a standard CBMC harness, model pointer inputs as nondeterministic
  pointers or use another non-vacuous object model justified by primary
  repository evidence.
- The generated code must call the exact target function
  {cfg.target_function}.
- A custom descriptive harness name is prohibited unless the configured
  cbmc_function itself has that exact name.

The plan should include:
"""

if "Mandatory generated-harness requirements:" not in text:
    if text.count(plan_marker) != 1:
        raise SystemExit(
            "Could not uniquely locate Agent 5 plan requirements."
        )
    text = text.replace(plan_marker, plan_replacement, 1)

# ------------------------------------------------------------
# 5. Replace weak structural validation with stronger checks.
# ------------------------------------------------------------

validation_start = text.index(
    "def validate_rendered_harness("
)

validation_end = text.index(
    "\ndef render_contract_artifacts",
    validation_start,
)

new_validation = r'''def validate_rendered_harness(
    harness_text: str,
    cfg: ArtifactGenerationConfig,
    plan: JsonDict,
) -> JsonDict:
    required_terms = [
        cfg.target_function,
    ]

    optional_terms = [
        "#include",
        "assert",
        "__CPROVER",
        "harness",
        "MLKEM",
        "coeff",
    ]

    missing_required = [
        term
        for term in required_terms
        if term and term not in harness_text
    ]

    present_optional = [
        term
        for term in optional_terms
        if term in harness_text
    ]

    risky_patterns = []
    blocking_patterns = []

    expected_entry_signature = (
        f"void {cfg.cbmc_function}(void)"
    )

    entry_pattern = re.compile(
        rf"\bvoid\s+"
        rf"{re.escape(cfg.cbmc_function)}"
        rf"\s*\(\s*void\s*\)\s*\{{"
    )

    entry_function_defined = bool(
        entry_pattern.search(harness_text)
    )

    if not entry_function_defined:
        blocking_patterns.append(
            "missing_exact_cbmc_entry_function"
        )

    null_initialized_pointers = sorted(
        {
            match.group(1)
            for match in re.finditer(
                r"\b[A-Za-z_]\w*\s*\*\s*"
                r"([A-Za-z_]\w*)\s*=\s*"
                r"(?:0|NULL)\s*;",
                harness_text,
            )
        }
    )

    null_freshness_pointers = []

    for pointer_name in null_initialized_pointers:
        freshness_pattern = re.compile(
            rf"\b(?:memory_no_alias|"
            rf"__CPROVER_is_fresh)"
            rf"\s*\(\s*"
            rf"{re.escape(pointer_name)}\b"
        )

        if freshness_pattern.search(harness_text):
            null_freshness_pointers.append(
                pointer_name
            )

    if null_freshness_pointers:
        blocking_patterns.append(
            "null_initialized_pointer_used_with_freshness"
        )

    if re.search(
        r"assert\s*\(\s*1\s*\)",
        harness_text,
    ):
        risky_patterns.append("trivial_assert_true")

    if re.search(
        r"assert\s*\(\s*0\s*\)",
        harness_text,
    ):
        risky_patterns.append("trivial_assert_false")

    if "TODO" in harness_text:
        risky_patterns.append(
            "contains_todo_placeholders"
        )

    if "FALLBACK-RENDERED" in harness_text:
        risky_patterns.append(
            "fallback_rendered_skeleton"
        )

    valid_for_handoff = (
        not missing_required
        and entry_function_defined
        and not blocking_patterns
    )

    requires_human_review = (
        bool(risky_patterns)
        or bool(blocking_patterns)
        or not valid_for_handoff
    )

    return {
        "schema_version":
            "rendered_harness_validation.v2.live_hardening",
        "created_utc": utc_now_iso(),
        "target_function": cfg.target_function,
        "configured_cbmc_function":
            cfg.cbmc_function,
        "expected_entry_signature":
            expected_entry_signature,
        "entry_function_defined":
            entry_function_defined,
        "contains_target_function":
            cfg.target_function in harness_text,
        "missing_required_terms":
            missing_required,
        "present_optional_terms":
            present_optional,
        "null_initialized_pointers":
            null_initialized_pointers,
        "null_freshness_pointers":
            null_freshness_pointers,
        "risky_patterns":
            risky_patterns,
        "blocking_patterns":
            blocking_patterns,
        "valid_for_handoff":
            valid_for_handoff,
        "requires_human_review":
            requires_human_review,
        "limitations": [
            "This is strengthened structural validation.",
            "It does not compile the harness.",
            "It does not run CBMC.",
            "It does not prove semantic correctness.",
            "Agent 6 review remains mandatory.",
        ],
    }

'''

text = (
    text[:validation_start]
    + new_validation
    + text[validation_end + 1:]
)

if text == original:
    raise SystemExit("No changes were made.")

path.write_text(text, encoding="utf-8")

print("Patched:", path)
PY

# ------------------------------------------------------------
# 6. Create a targeted regression test.
# ------------------------------------------------------------

cat > tests/verify_live_harness_hardening.py <<'PY'
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
PY

# ------------------------------------------------------------
# 7. Create Run 002 config without modifying Run 001.
# ------------------------------------------------------------

python - <<'PY'
import json
from pathlib import Path

source = Path(
    "configs/poly_add_api_run_001.json"
)

destination = Path(
    "configs/poly_add_api_run_002.json"
)

config = json.loads(
    source.read_text(encoding="utf-8")
)

config["run_id"] = (
    "run_002_poly_add_hardened_real_20260711"
)

# This is a per-file raw-evidence ceiling.
# FIPS text contains 146,391 characters.
config["llm"]["max_inline_file_chars"] = 200000

config["llm"]["max_output_tokens"] = 12000
config["max_iterations"] = 0

destination.write_text(
    json.dumps(config, indent=2) + "\n",
    encoding="utf-8",
)

print("Created:", destination)
print(
    "max_inline_file_chars:",
    config["llm"]["max_inline_file_chars"],
)
PY

# ------------------------------------------------------------
# 8. Syntax, regression and configuration checks.
# ------------------------------------------------------------

python -m py_compile \
  agents/artifact_generation_agent.py

python \
  tests/verify_live_harness_hardening.py

python -m json.tool \
  configs/poly_add_api_run_002.json \
  >/dev/null

echo
echo "=== Run 002 critical settings ==="

python - <<'PY'
import json
from pathlib import Path

config = json.loads(
    Path(
        "configs/poly_add_api_run_002.json"
    ).read_text()
)

print("run_id:", config["run_id"])
print(
    "cbmc_function:",
    config["tool_execution"]["cbmc_function"],
)
print(
    "max_inline_file_chars:",
    config["llm"]["max_inline_file_chars"],
)
print(
    "max_output_tokens:",
    config["llm"]["max_output_tokens"],
)
print(
    "max_iterations:",
    config["max_iterations"],
)
PY

echo
echo "=== Patched-file hashes ==="

sha256sum \
  agents/artifact_generation_agent.py \
  tests/verify_live_harness_hardening.py \
  configs/poly_add_api_run_002.json
