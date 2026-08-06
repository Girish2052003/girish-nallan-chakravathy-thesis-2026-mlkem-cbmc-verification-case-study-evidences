#!/usr/bin/env python3
"""Prove child cleanup and cryptographically bound resumable regression execution."""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "scripts" / "run_regressions.py"


def process_active(pid: int) -> bool:
    stat_path = Path(f"/proc/{pid}/stat")
    if not stat_path.exists():
        return False
    try:
        state = stat_path.read_text(encoding="utf-8").split()[2]
    except (OSError, IndexError):
        return False
    return state != "Z"


def invoke(fake_root: Path, output_dir: Path, *extra: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(RUNNER), "--root", str(fake_root), "--python", sys.executable,
         "--timeout-seconds", "10", "--output-dir", str(output_dir), *extra],
        cwd=str(ROOT), text=True, capture_output=True, timeout=20, check=False,
    )


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="runner_cleanup_") as td:
        fake_root = Path(td)
        tests_dir = fake_root / "tests"
        tests_dir.mkdir()
        pid_path = fake_root / "leaked_child.pid"
        (tests_dir / "verify_01_leaked_child.py").write_text(
            "from pathlib import Path\nimport subprocess, sys\n"
            f"pid_path = Path({str(pid_path)!r})\n"
            "child = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(60)'])\n"
            "pid_path.write_text(str(child.pid), encoding='utf-8')\n",
            encoding="utf-8",
        )
        for number in (2, 3):
            (tests_dir / f"verify_0{number}_pass.py").write_text("print('pass')\n", encoding="utf-8")
        output_dir = fake_root / "results"

        started = time.monotonic()
        first = invoke(fake_root, output_dir, "--resume", "--max-tests", "1")
        elapsed = time.monotonic() - started
        assert first.returncode == 75, (first.stdout, first.stderr)
        assert elapsed < 8, elapsed
        child_pid = int(pid_path.read_text(encoding="utf-8"))
        deadline = time.monotonic() + 3
        while process_active(child_pid) and time.monotonic() < deadline:
            time.sleep(0.05)
        assert not process_active(child_pid), f"leaked child process remains active: {child_pid}"

        second = invoke(fake_root, output_dir, "--resume", "--max-tests", "1")
        assert second.returncode == 75, (second.stdout, second.stderr)
        final = invoke(fake_root, output_dir, "--resume")
        assert final.returncode == 0, (final.stdout, final.stderr)
        report = json.loads((output_dir / "regression_results.json").read_text(encoding="utf-8"))
        assert report["schema_version"] == "regression_run.v2", report
        assert report["complete"] is True and report["all_passed"] is True, report
        assert report["test_count"] == report["passed_count"] == 3, report

        (tests_dir / "verify_03_pass.py").write_text("print('mutated')\n", encoding="utf-8")
        stale = invoke(fake_root, output_dir, "--resume")
        assert stale.returncode == 2, (stale.stdout, stale.stderr)
        assert "RESUME STATE REJECTED" in stale.stderr, stale.stderr

    verifier_path = ROOT / "verify_release.sh"
    assert not verifier_path.exists(), "Mutable-only edition must not reintroduce a release verifier lock."
    print("REGRESSION RUNNER CLEANUP/RESUME TEST: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
