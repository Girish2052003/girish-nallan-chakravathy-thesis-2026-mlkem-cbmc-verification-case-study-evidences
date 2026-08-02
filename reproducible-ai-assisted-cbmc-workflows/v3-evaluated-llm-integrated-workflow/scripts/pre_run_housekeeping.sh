#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 5 ]; then
  echo "Usage:"
  echo "  $0 RUN_ID CONFIG REPORT CONFIG_SHA256 REPORT_SHA256"
  exit 2
fi

RUN_ID="$1"
CONFIG="$2"
REPORT="$3"
EXPECTED_CONFIG_SHA="$4"
EXPECTED_REPORT_SHA="$5"

PROJECT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." \
    && pwd
)"

PY="$PROJECT/.venv/bin/python"

cd "$PROJECT"

echo "================================================================"
echo "MANDATORY PRE-RUN HOUSEKEEPING ROUTINE"
echo "================================================================"

test -x "$PY" || {
  echo "STOP: project virtual-environment Python is missing."
  exit 1
}

ACTIVE="$(
  pgrep -af \
    '[m]aster_orchestrator.py|[p]reflight_first_api.py|[t]ool_execution_agent.py' \
    || true
)"

if [ -n "$ACTIVE" ]; then
  echo "STOP: a workflow-related process is active:"
  echo "$ACTIVE"
  exit 1
fi

test -f "$CONFIG" || {
  echo "STOP: protected configuration is missing: $CONFIG"
  exit 1
}

test -f "$REPORT" || {
  echo "STOP: protected preflight report is missing: $REPORT"
  exit 1
}

echo "$EXPECTED_CONFIG_SHA  $CONFIG" \
  | sha256sum --check

echo "$EXPECTED_REPORT_SHA  $REPORT" \
  | sha256sum --check

test ! -e "runs/$RUN_ID" || {
  echo "STOP: run directory already exists: runs/$RUN_ID"
  exit 1
}

export RUN_ID CONFIG REPORT

"$PY" - <<'PY'
import json
import os
from pathlib import Path

run_id = os.environ["RUN_ID"]
config_path = Path(os.environ["CONFIG"])
report_path = Path(os.environ["REPORT"])
spec_path = Path("inputs/specs/fips203_clean.txt")

config = json.loads(
    config_path.read_text(encoding="utf-8")
)
report = json.loads(
    report_path.read_text(encoding="utf-8")
)

checks = report.get("checks", {})
primary = checks.get(
    "primary_evidence_completeness",
    {},
)
live = checks.get("live_api_access", {})
token_check = live.get("input_token_check", {})

tool = config.get("tool_execution", {})
overrides = config.get("llm_overrides", {})

spec_chars = len(
    spec_path.read_text(
        encoding="utf-8",
        errors="replace",
    )
)

conditions = {
    "config run_id matches":
        config.get("run_id") == run_id,

    "central profile used":
        bool(config.get("llm_profile"))
        and "llm" not in config,

    "broad code_dir absent":
        "code_dir" not in config.get("inputs", {}),

    "five scoped code files":
        len(
            config.get("inputs", {}).get(
                "code_paths",
                [],
            )
        ) == 5,

    "complete-FIPS allowance":
        isinstance(
            overrides.get("max_inline_file_chars"),
            int,
        )
        and overrides["max_inline_file_chars"] >= spec_chars,

    "exact harness entry":
        tool.get("cbmc_function") == "harness",

    "real execution":
        tool.get("dry_run") is False,

    "force bypass disabled":
        tool.get("force_run") is False,

    "critic approval required":
        tool.get("require_gate_approval") is True,

    "preflight approved":
        report.get(
            "approved_for_one_controlled_first_experiment"
        ) is True,

    "preflight errors empty":
        report.get("errors") == [],

    "six complete primary files":
        primary.get("file_count") == 6
        and primary.get("incomplete_file_count") == 0
        and primary.get(
            "all_primary_evidence_complete"
        ) is True,

    "full-input API check passed":
        live.get("passed") is True
        and live.get("thesis_evidence_sent") is True
        and token_check.get(
            "provider_accepted_exact_preflight_input"
        ) is True,
}

failed = []

for name, passed in conditions.items():
    print(f"{name}: {'PASS' if passed else 'FAIL'}")

    if not passed:
        failed.append(name)

if failed:
    print("\nFAILED CONDITIONS:")

    for name in failed:
        print(" -", name)

    raise SystemExit(
        "STOP: mandatory pre-run control validation failed."
    )
PY

"$PY" - <<'PY'
import shutil
from pathlib import Path

root = Path(".").resolve()

protected_roots = {
    ".venv",
    "runs",
    "backups",
    "archives",
    "diagnostics",
    "inputs",
    "launch_records",
    ".git",
}

cache_names = {
    "__pycache__",
    ".pytest_cache",
    ".mypy_cache",
    ".ruff_cache",
}

removed = 0

for path in sorted(root.rglob("*"), key=lambda p: len(p.parts), reverse=True):
    try:
        relative = path.relative_to(root)
    except ValueError:
        continue

    if not relative.parts:
        continue

    if relative.parts[0] in protected_roots:
        continue

    if path.is_dir() and path.name in cache_names:
        shutil.rmtree(path)
        removed += 1

print("Safe project cache directories removed:", removed)
PY

echo
echo "Running mandatory non-network regressions..."

PYTHONDONTWRITEBYTECODE=1 \
PYTHONPATH="$PROJECT${PYTHONPATH:+:$PYTHONPATH}" \
  "$PY" tests/verify_live_harness_hardening.py

PYTHONDONTWRITEBYTECODE=1 \
PYTHONPATH="$PROJECT${PYTHONPATH:+:$PYTHONPATH}" \
  "$PY" tests/verify_central_fail_closed_hardening.py

mkdir -p diagnostics

RECORD="diagnostics/pre_run_housekeeping_$(date +%Y%m%d_%H%M%S).txt"

{
  echo "schema_version: pre_run_housekeeping_record.v1"
  echo "created_utc: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "run_id: $RUN_ID"
  echo "config: $CONFIG"
  echo "report: $REPORT"
  echo "run_directory_fresh: true"
  echo "active_workflow_processes: false"
  echo "safe_project_caches_removed: true"
  echo "live_harness_regression: passed"
  echo "central_fail_closed_regression: passed"
  echo
  sha256sum "$CONFIG" "$REPORT"
} > "$RECORD"

echo
echo "Housekeeping record: $RECORD"
echo
echo "MANDATORY PRE-RUN HOUSEKEEPING: PASS"
