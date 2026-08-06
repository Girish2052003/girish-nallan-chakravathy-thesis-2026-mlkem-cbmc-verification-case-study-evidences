#!/usr/bin/env python3
"""Prove the mutable bootstrap works and obsolete hardened-launch residue is absent."""
from __future__ import annotations

import os
import shutil
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOTSTRAP = ROOT / "bootstrap_ubuntu.sh"
RUNNER = ROOT / "scripts" / "run_regressions.py"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def write_executable(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    path.chmod(path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def invoke_fixture(*, fail_runner: bool) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory(prefix="mutable_bootstrap_") as td:
        workspace = Path(td)
        fixture = workspace / "thesis-pipeline"
        fixture.mkdir()
        shutil.copy2(BOOTSTRAP, fixture / "bootstrap_ubuntu.sh")
        (fixture / "requirements.txt").write_text("# fixture\n", encoding="utf-8")
        (fixture / "scripts").mkdir()
        (fixture / "scripts" / "run_regressions.py").write_text(
            "print('fixture runner')\n", encoding="utf-8"
        )
        (fixture / "reports").mkdir()
        log_path = fixture / "python_calls.log"
        write_executable(
            workspace / "venv" / "bin" / "python",
            """#!/usr/bin/env bash
set -euo pipefail
printf '%s\\n' "$*" >> "$FAKE_PYTHON_LOG"
if [[ "${1:-}" == "-m" && "${2:-}" == "pip" ]]; then
  exit 0
fi
if [[ "${1:-}" == *"scripts/run_regressions.py" ]]; then
  if [[ "${FAKE_RUNNER_FAIL:-0}" == "1" ]]; then
    exit 7
  fi
  exit 0
fi
exit 0
""",
        )
        env = os.environ.copy()
        env["FAKE_PYTHON_LOG"] = str(log_path)
        env["FAKE_RUNNER_FAIL"] = "1" if fail_runner else "0"
        result = subprocess.run(
            ["bash", str(fixture / "bootstrap_ubuntu.sh")],
            cwd=str(fixture),
            env=env,
            text=True,
            capture_output=True,
            timeout=30,
            check=False,
        )
        calls = log_path.read_text(encoding="utf-8")
        require("-m pip install --upgrade pip" in calls, "Bootstrap skipped pip upgrade")
        require("-m pip install -r requirements.txt" in calls, "Bootstrap skipped requirements")
        require("scripts/run_regressions.py" in calls, "Bootstrap did not invoke regression runner")
        require("--root" in calls and "--python" in calls, "Bootstrap runner arguments incomplete")
        if fail_runner:
            require(result.returncode == 7, f"Runner failure was not propagated: {result.returncode}")
            require(
                "BOOTSTRAP AND MUTABLE WORKSPACE REGRESSIONS PASSED" not in result.stdout,
                "Bootstrap printed success after runner failure",
            )
        else:
            require(result.returncode == 0, (result.stdout + result.stderr))
            require(
                "BOOTSTRAP AND MUTABLE WORKSPACE REGRESSIONS PASSED" in result.stdout,
                "Bootstrap success message missing",
            )
        return result


def main() -> int:
    for absent in (
        "agents/patch_agent.sh",
        "scripts/pre_run_housekeeping.sh",
        "verify_release.sh",
    ):
        require(not (ROOT / absent).exists(), f"Obsolete executable residue remains: {absent}")

    require(BOOTSTRAP.is_file(), "bootstrap_ubuntu.sh missing")
    require(RUNNER.is_file(), "Mutable regression runner missing")
    bootstrap_text = BOOTSTRAP.read_text(encoding="utf-8")
    require("scripts/run_regressions.py" in bootstrap_text, "Bootstrap target is not mutable runner")
    require("verify_release.sh" not in bootstrap_text, "Bootstrap still references release verifier")
    require("../venv" in bootstrap_text, "Bootstrap does not default to sibling venv directory")

    help_text = subprocess.check_output(
        [os.sys.executable, str(ROOT / "preflight_first_api.py"), "--help"],
        text=True,
    )
    for obsolete_flag in ("--release-zip", "--bound-config"):
        require(obsolete_flag not in help_text, f"Release-only preflight flag remains: {obsolete_flag}")

    forbidden_guide_phrases = (
        "exact source ZIP",
        "release-bound config",
        "package-manifest",
        "release identity",
    )
    for relative in (
        "docs/CENTRAL_LLM_PROFILE_GUIDE.md",
        "docs/COMPLETE_26_PROPERTY_CAMPAIGN_GUIDE.md",
    ):
        text = (ROOT / relative).read_text(encoding="utf-8")
        for phrase in forbidden_guide_phrases:
            require(phrase not in text, f"Stale guide phrase remains in {relative}: {phrase}")

    invoke_fixture(fail_runner=False)
    invoke_fixture(fail_runner=True)
    print("MUTABLE BOOTSTRAP AND RESIDUE CLEANUP: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
