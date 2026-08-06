#!/usr/bin/env python3
"""Discover and run every approved regression script with bounded, resumable execution."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import signal
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path

INCOMPLETE_EXIT = 75


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def atomic_json(path: Path, payload: dict) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def build_report(
    *, root: Path, python: str, timeout_seconds: int, inventory: list[dict],
    inventory_hash: str, results_by_test: dict[str, dict], complete: bool,
) -> dict:
    ordered = [results_by_test[item["path"]] for item in inventory if item["path"] in results_by_test]
    passed = sum(item["status"] == "passed" for item in ordered)
    failed = sum(item["status"] != "passed" for item in ordered)
    return {
        "schema_version": "regression_run.v2",
        "updated_utc": datetime.now(timezone.utc).isoformat(),
        "root": str(root),
        "python": python,
        "timeout_seconds_per_test": timeout_seconds,
        "test_inventory_sha256": inventory_hash,
        "test_count": len(inventory),
        "executed_count": len(ordered),
        "remaining_count": len(inventory) - len(ordered),
        "passed_count": passed,
        "failed_count": failed,
        "inventory": inventory,
        "results": ordered,
        "complete": complete,
        "all_passed": complete and failed == 0 and passed == len(inventory),
    }


def load_resume_report(
    report_path: Path, *, root: Path, python: str, timeout_seconds: int,
    inventory_hash: str, inventory: list[dict],
) -> dict[str, dict]:
    if not report_path.exists():
        return {}
    try:
        report = json.loads(report_path.read_text(encoding="utf-8"))
    except Exception as exc:
        raise RuntimeError(f"Cannot resume from invalid regression report: {exc}") from exc
    expected = {
        "root": str(root),
        "python": python,
        "timeout_seconds_per_test": timeout_seconds,
        "test_inventory_sha256": inventory_hash,
    }
    mismatches = [f"{key}: {report.get(key)!r} != {value!r}" for key, value in expected.items() if report.get(key) != value]
    if mismatches:
        raise RuntimeError("Resume state is not bound to this exact release/test environment: " + "; ".join(mismatches))
    current = {item["path"]: item for item in inventory}
    results: dict[str, dict] = {}
    for item in report.get("results", []):
        path = item.get("test")
        if path not in current:
            raise RuntimeError(f"Resume state contains an unapproved test: {path!r}")
        if item.get("sha256") != current[path]["sha256"]:
            raise RuntimeError(f"Resume result hash mismatch for {path}")
        if path in results:
            raise RuntimeError(f"Duplicate resume result for {path}")
        if item.get("status") == "passed" and item.get("returncode") == 0:
            results[path] = item
    return results


def terminate_group(proc: subprocess.Popen) -> None:
    try:
        os.killpg(proc.pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        proc.wait()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--python", default=sys.executable)
    parser.add_argument("--timeout-seconds", type=int, default=240)
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--resume", action="store_true", help="Reuse only hash-bound passing results from the output report.")
    parser.add_argument("--max-tests", type=int, default=0, help="Run at most this many pending tests; 0 means all.")
    args = parser.parse_args()
    if args.timeout_seconds <= 0 or args.max_tests < 0:
        parser.error("timeouts must be positive and --max-tests cannot be negative")

    root = args.root.resolve()
    tests = sorted((root / "tests").glob("verify_*.py"))
    if not tests:
        print("No regression tests discovered.", file=sys.stderr)
        return 2

    output_dir = (args.output_dir or Path(tempfile.mkdtemp(prefix="thesis_regressions_"))).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    report_path = output_dir / "regression_results.json"
    env = os.environ.copy()
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    env["PYTHONPATH"] = str(root) + (os.pathsep + env["PYTHONPATH"] if env.get("PYTHONPATH") else "")

    inventory = [
        {"path": str(path.relative_to(root)), "sha256": sha256(path), "size_bytes": path.stat().st_size}
        for path in tests
    ]
    inventory_payload = json.dumps(inventory, sort_keys=True, separators=(",", ":")).encode()
    inventory_hash = hashlib.sha256(inventory_payload).hexdigest()
    try:
        results_by_test = load_resume_report(
            report_path,
            root=root,
            python=args.python,
            timeout_seconds=args.timeout_seconds,
            inventory_hash=inventory_hash,
            inventory=inventory,
        ) if args.resume else {}
    except RuntimeError as exc:
        print(f"RESUME STATE REJECTED: {exc}", file=sys.stderr)
        return 2

    executed_now = 0
    for index, test in enumerate(tests, start=1):
        rel = str(test.relative_to(root))
        name = test.name
        if rel in results_by_test:
            print(f"[{index}/{len(tests)}] {name}\n  REUSE PASS (hash-bound)", flush=True)
            continue
        if args.max_tests and executed_now >= args.max_tests:
            break
        print(f"[{index}/{len(tests)}] {name}", flush=True)
        started = time.monotonic()
        stdout_path = output_dir / f"{name}.stdout.txt"
        stderr_path = output_dir / f"{name}.stderr.txt"
        timed_out = False
        with stdout_path.open("w", encoding="utf-8") as stdout_handle, stderr_path.open("w", encoding="utf-8") as stderr_handle:
            proc = subprocess.Popen(
                [args.python, str(test)], cwd=str(root), env=env, text=True,
                stdout=stdout_handle, stderr=stderr_handle, start_new_session=True,
            )
            try:
                returncode = proc.wait(timeout=args.timeout_seconds)
                status = "passed" if returncode == 0 else "failed"
            except subprocess.TimeoutExpired:
                timed_out = True
                status = "timeout"
                returncode = None
            finally:
                terminate_group(proc)

        stdout = stdout_path.read_text(encoding="utf-8", errors="replace")
        stderr = stderr_path.read_text(encoding="utf-8", errors="replace")
        if timed_out:
            stderr += f"\nTIMEOUT after {args.timeout_seconds} seconds; process group terminated\n"
            stderr_path.write_text(stderr, encoding="utf-8")
        duration = time.monotonic() - started
        result = {
            "test": rel,
            "sha256": sha256(test),
            "status": status,
            "returncode": returncode,
            "duration_seconds": round(duration, 3),
            "stdout_path": str(stdout_path),
            "stderr_path": str(stderr_path),
        }
        results_by_test[rel] = result
        executed_now += 1
        complete = len(results_by_test) == len(inventory)
        atomic_json(report_path, build_report(
            root=root, python=args.python, timeout_seconds=args.timeout_seconds,
            inventory=inventory, inventory_hash=inventory_hash,
            results_by_test=results_by_test, complete=complete,
        ))
        if status != "passed":
            print(f"  {status.upper()} ({duration:.1f}s)", flush=True)
            if stderr.strip():
                print(stderr.strip()[-2000:], file=sys.stderr, flush=True)
            print("REGRESSION SUITE FAILED", file=sys.stderr)
            return 1
        print(f"  PASS ({duration:.1f}s)", flush=True)

    complete = len(results_by_test) == len(inventory)
    report = build_report(
        root=root, python=args.python, timeout_seconds=args.timeout_seconds,
        inventory=inventory, inventory_hash=inventory_hash,
        results_by_test=results_by_test, complete=complete,
    )
    atomic_json(report_path, report)
    print(f"Test inventory SHA-256: {inventory_hash}")
    print(f"Results: {report_path}")
    if not complete:
        print(f"REGRESSION SUITE INCOMPLETE: {report['remaining_count']} approved tests remain; rerun with --resume")
        return INCOMPLETE_EXIT
    if not report["all_passed"]:
        print("REGRESSION SUITE FAILED", file=sys.stderr)
        return 1
    print(f"ALL {len(tests)} DISCOVERED REGRESSIONS PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
