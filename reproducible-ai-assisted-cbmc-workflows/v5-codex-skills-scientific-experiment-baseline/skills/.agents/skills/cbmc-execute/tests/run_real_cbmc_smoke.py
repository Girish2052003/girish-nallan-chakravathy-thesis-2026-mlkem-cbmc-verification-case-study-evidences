#!/usr/bin/env python3
from __future__ import annotations
import argparse, hashlib, json, os, pathlib, shutil, subprocess, tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "execute_cbmc.py"
FIXTURE = ROOT / "tests" / "fixtures" / "workspace"

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cbmc-path", default="/usr/bin/cbmc")
    args = ap.parse_args()
    base = pathlib.Path(tempfile.mkdtemp(prefix="cbmc-execute-real-smoke-"))
    try:
        ws = base / "workspace"; shutil.copytree(FIXTURE, ws)
        tracked = ["include/demo.h", "src/demo.c", "src/harness.c"]
        req = {
            "schema_version": "1.0", "request_id": "real-cbmc-smoke-001", "working_directory": ".",
            "analysis_sources": ["src/demo.c", "src/harness.c"], "tracked_inputs": tracked,
            "expected_sha256": {p: sha(ws / p) for p in tracked},
            "analysis": {"options": ["-I", "include", "--bounds-check", "--pointer-check", "--signed-overflow-check", "--trace"], "timeout_seconds": 120},
            "inventory": {"enabled": True, "options": ["-I", "include"], "timeout_seconds": 60},
            "execution_environment": {}, "clock": {"mode": "wall_clock"}
        }
        request = base / "request.json"; request.write_text(json.dumps(req, indent=2) + "\n")
        out = base / "evidence"
        cp = subprocess.run(["python3", str(SCRIPT), "--request", str(request), "--workspace-root", str(ws), "--output-dir", str(out), "--cbmc-path", args.cbmc_path])
        if cp.returncode != 0:
            raise SystemExit(f"FAIL: wrapper exit {cp.returncode}; evidence retained at {out}")
        summary = json.loads((out / "execution_summary.json").read_text())
        if summary["tool_outcome"] != "PASS_REPORTED_BY_CBMC":
            raise SystemExit(f"FAIL: unexpected outcome {summary['tool_outcome']}; evidence retained at {out}")
        if not summary["source_integrity"]["unchanged"]:
            raise SystemExit(f"FAIL: source integrity changed; evidence retained at {out}")
        inv = json.loads((out / "property_inventory.json").read_text())
        if not inv["available"]:
            raise SystemExit(f"FAIL: property inventory unavailable; evidence retained at {out}")
        print("REAL_CBMC_SMOKE_PASS")
        print(f"CBMC_PATH={args.cbmc_path}")
        print(f"EVIDENCE={out}")
    except Exception:
        print(f"WORKSPACE_RETAINED={base}")
        raise

if __name__ == "__main__": main()
