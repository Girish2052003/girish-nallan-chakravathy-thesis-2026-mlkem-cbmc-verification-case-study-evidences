#!/usr/bin/env python3
"""Regression: every synthetic real-CBMC fixture binds an explicit entry function.

This protects the Ubuntu acceptance gate from compiling a GOTO binary with no
entry point, which can make goto-instrument's DFCC pass abort in nondet_static.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACCEPT = ROOT / "tests" / "accept_real_cbmc_69.py"

FAKE_TOOL = r'''#!/usr/bin/env python3
import json, os, shutil, sys
from pathlib import Path
name = Path(sys.argv[0]).name
args = sys.argv[1:]
log = Path(os.environ["FAKE_CBMC_COMMAND_LOG"])
with log.open("a", encoding="utf-8") as h:
    h.write(json.dumps({"tool": name, "args": args}) + "\n")
if "--version" in args:
    print(f"{name} version 6.9.0")
    raise SystemExit(0)
if name == "goto-cc":
    source = next((Path(x) for x in args if x.endswith(".c")), None)
    expected = {
        "valid_contract.c": "harness",
        "loop_contract.c": "loop_harness",
        "hybrid_contract.c": "hybrid_harness",
    }.get(source.name if source else "", "f")
    if "--function" not in args:
        print("missing --function", file=sys.stderr)
        raise SystemExit(91)
    i = args.index("--function")
    if i + 1 >= len(args) or args[i + 1] != expected:
        print(f"wrong entry: expected {expected!r}, got {args[i+1] if i+1 < len(args) else None!r}", file=sys.stderr)
        raise SystemExit(92)
    if source and source.name.startswith("invalid_"):
        raise SystemExit(1)
    if "-o" in args:
        Path(args[args.index("-o") + 1]).write_text("fake goto binary\\n", encoding="utf-8")
    raise SystemExit(0)
if name == "goto-instrument":
    src, dst = Path(args[-2]), Path(args[-1])
    shutil.copyfile(src, dst)
    raise SystemExit(0)
if name == "cbmc":
    print(json.dumps([{"description": "TRACE_CLAIM::REAL_FUNCTION::C01 TRACE_CLAIM::REAL_LOOP::C01 TRACE_CLAIM::REAL_HYBRID::C01"}]))
    raise SystemExit(0)
raise SystemExit(99)
'''


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="verify_cbmc_entry_binding_") as td:
        t = Path(td)
        bindir = t / "bin"
        bindir.mkdir()
        for name in ("goto-cc", "goto-instrument", "cbmc"):
            tool = bindir / name
            tool.write_text(FAKE_TOOL, encoding="utf-8")
            tool.chmod(0o755)
        log = t / "commands.jsonl"
        report = t / "acceptance.json"
        env = os.environ.copy()
        env.update({
            "PATH": str(bindir) + os.pathsep + env.get("PATH", ""),
            "REQUIRE_REAL_CBMC": "1",
            "CBMC_ACCEPTANCE_REPORT": str(report),
            "FAKE_CBMC_COMMAND_LOG": str(log),
            "PYTHONDONTWRITEBYTECODE": "1",
        })
        proc = subprocess.run(
            [sys.executable, str(ACCEPT)], cwd=ROOT, env=env,
            text=True, capture_output=True, timeout=60, check=False,
        )
        assert proc.returncode == 0, proc.stdout + "\n" + proc.stderr
        payload = json.loads(report.read_text(encoding="utf-8"))
        assert payload["passed"] is True
        commands = [json.loads(line) for line in log.read_text(encoding="utf-8").splitlines()]
        compiles = [row for row in commands if row["tool"] == "goto-cc" and "--version" not in row["args"]]
        assert len(compiles) == 8, compiles
        for row in compiles:
            assert "--function" in row["args"], row
        expected = {
            "valid_contract.c": "harness",
            "loop_contract.c": "loop_harness",
            "hybrid_contract.c": "hybrid_harness",
        }
        for filename, entry in expected.items():
            row = next(row for row in compiles if any(arg.endswith(filename) for arg in row["args"]))
            i = row["args"].index("--function")
            assert row["args"][i + 1] == entry, row
        invalid = [row for row in compiles if any("invalid_" in arg and arg.endswith(".c") for arg in row["args"])]
        assert len(invalid) == 5
        for row in invalid:
            i = row["args"].index("--function")
            assert row["args"][i + 1] == "f", row
    print("REAL CBMC ACCEPTANCE ENTRY BINDING: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
