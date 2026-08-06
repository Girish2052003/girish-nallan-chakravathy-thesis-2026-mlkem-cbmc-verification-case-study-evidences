#!/usr/bin/env python3
"""Regression: CBMC 6.9 loop clauses use the parser keyword and exact order."""
from __future__ import annotations

import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACCEPT = ROOT / "tests" / "accept_real_cbmc_69.py"
RENDERER = ROOT / "agents" / "common" / "contract_artifacts.py"

FAKE_TOOL = r'''#!/usr/bin/env python3
import json, shutil, sys
from pathlib import Path
name = Path(sys.argv[0]).name
args = sys.argv[1:]
if "--version" in args:
    print(f"{name} version 6.9.0")
    raise SystemExit(0)
if name == "goto-cc":
    source = next((Path(x) for x in args if x.endswith(".c")), None)
    if source is None:
        raise SystemExit(93)
    text = source.read_text(encoding="utf-8")
    if source.name in {"loop_contract.c", "hybrid_contract.c"}:
        if "__CPROVER_loop_assigns(" in text:
            print("unsupported __CPROVER_loop_assigns spelling", file=sys.stderr)
            raise SystemExit(94)
        assigns = text.find("__CPROVER_assigns(i, __CPROVER_object_upto(a, sizeof(a)))")
        invariant = text.find("__CPROVER_loop_invariant", assigns + 1)
        decreases = text.find("__CPROVER_decreases", invariant + 1)
        if not (0 <= assigns < invariant < decreases):
            print("wrong CBMC 6.9 loop-clause order", file=sys.stderr)
            raise SystemExit(95)
    if source.name.startswith("invalid_"):
        raise SystemExit(1)
    if "-o" in args:
        Path(args[args.index("-o") + 1]).write_text("fake goto binary\n", encoding="utf-8")
    raise SystemExit(0)
if name == "goto-instrument":
    shutil.copyfile(Path(args[-2]), Path(args[-1]))
    raise SystemExit(0)
if name == "cbmc":
    print(json.dumps([{"description": "TRACE_CLAIM::REAL_FUNCTION::C01 TRACE_CLAIM::REAL_LOOP::C01 TRACE_CLAIM::REAL_HYBRID::C01"}]))
    raise SystemExit(0)
raise SystemExit(99)
'''


def assert_order(text: str, assigns: str, invariant: str, decreases: str) -> None:
    a = text.find(assigns)
    i = text.find(invariant, a + 1)
    d = text.find(decreases, i + 1)
    assert 0 <= a < i < d, (a, i, d)


def main() -> int:
    source = ACCEPT.read_text(encoding="utf-8")
    assert "__CPROVER_loop_assigns(" not in source
    assert source.count("__CPROVER_assigns(i, __CPROVER_object_upto(a, sizeof(a)))") == 2
    assert_order(source,
        "__CPROVER_assigns(i, __CPROVER_object_upto(a, sizeof(a)))",
        "__CPROVER_loop_invariant(0 <= i && i <= 4)",
        "__CPROVER_decreases(4 - i)")
    second = source.find("__CPROVER_assigns(i, __CPROVER_object_upto(a, sizeof(a)))",
                         source.find("__CPROVER_decreases(4 - i)") + 1)
    assert second >= 0
    assert_order(source[second:],
        "__CPROVER_assigns(i, __CPROVER_object_upto(a, sizeof(a)))",
        "__CPROVER_loop_invariant(0 <= i && i <= 2)",
        "__CPROVER_decreases(2-i)")

    renderer_source = RENDERER.read_text(encoding="utf-8")
    start = renderer_source.index("def _render_loop_annotation_block")
    end = renderer_source.index("\ndef apply_contract_source_patches", start)
    function = renderer_source[start:end]
    assert (function.index('contract_plan.get("loop_assigns_clauses")')
            < function.index('contract_plan.get("loop_invariant_clauses")')
            < function.index('contract_plan.get("decreases_clauses")'))
    assert '__CPROVER_assigns({clause})' in function

    with tempfile.TemporaryDirectory(prefix="verify_cbmc_loop_grammar_") as td:
        temp = Path(td)
        bindir = temp / "bin"
        bindir.mkdir()
        for name in ("goto-cc", "goto-instrument", "cbmc"):
            tool = bindir / name
            tool.write_text(FAKE_TOOL, encoding="utf-8")
            tool.chmod(0o755)
        report = temp / "acceptance.json"
        env = os.environ.copy()
        env.update({
            "PATH": str(bindir) + os.pathsep + env.get("PATH", ""),
            "REQUIRE_REAL_CBMC": "1",
            "CBMC_ACCEPTANCE_REPORT": str(report),
            "PYTHONDONTWRITEBYTECODE": "1",
        })
        proc = subprocess.run([sys.executable, str(ACCEPT)], cwd=ROOT, env=env,
                              text=True, capture_output=True, timeout=60, check=False)
        assert proc.returncode == 0, proc.stdout + "\n" + proc.stderr
        assert report.is_file()
    print("REAL CBMC 6.9 LOOP GRAMMAR: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
