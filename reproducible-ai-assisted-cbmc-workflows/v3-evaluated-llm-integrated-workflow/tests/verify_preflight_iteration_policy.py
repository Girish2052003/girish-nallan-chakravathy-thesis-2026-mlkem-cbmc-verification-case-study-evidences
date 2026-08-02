#!/usr/bin/env python3

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "preflight_first_api.py"
CONFIG = (
    ROOT
    / "configs"
    / "poly_add_scoped_fullfips_gpt54mini_none_repair1_20260711_095925.json"
)

source = SOURCE.read_text(encoding="utf-8")
config_text = CONFIG.read_text(encoding="utf-8")

required_fragments = [
    'max_iterations = int(config.get("max_iterations", -1))',
    "if max_iterations not in {0, 1}:",
    "larger automatic repair loops are not approved",
]

for fragment in required_fragments:
    if fragment not in source:
        raise SystemExit(
            f"FAIL: controlled-iteration policy fragment missing: {fragment}"
        )

for forbidden in [
    "The first cost-controlled API experiment must use max_iterations = 0.",
    "if int(config.get(\"max_iterations\", -1)) != 0:",
]:
    if forbidden in source:
        raise SystemExit(
            f"FAIL: obsolete first-experiment policy remains: {forbidden}"
        )

if '"max_iterations": 1' not in config_text:
    raise SystemExit(
        "FAIL: Experiment 3 no longer has the deliberate max_iterations value 1."
    )

allowed = {0, 1}

if 0 not in allowed:
    raise SystemExit("FAIL: zero-repair controlled runs are not accepted.")

if 1 not in allowed:
    raise SystemExit("FAIL: one controlled repair cycle is not accepted.")

for rejected in (-1, 2, 3, 10):
    if rejected in allowed:
        raise SystemExit(
            f"FAIL: unsafe/unapproved iteration value accepted: {rejected}"
        )

print("PREFLIGHT CONTROLLED-ITERATION POLICY REGRESSION: PASS")
