#!/usr/bin/env python3
"""Verify the lean mutable package structure without introducing runtime release locks."""
from __future__ import annotations
import json, stat
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def main() -> int:
    for absent in ("agents/common/release_identity.py","PACKAGE_MANIFEST.sha256","RELEASE_METADATA.json","verify_release.sh","NO_RELEASE_LOCKS.md","scripts/build_source_release.py"):
        assert not (ROOT/absent).exists(),absent
    assert (ROOT/"runs").is_dir() and (ROOT/"reports").is_dir()
    assert not any(ROOT.rglob("*.pyc")),"Packaged/source tree contains pyc files"
    assert not any(ROOT.rglob("__pycache__")),"Packaged/source tree contains __pycache__"
    templates=sorted((ROOT/"configs").glob("CONFIG_TEMPLATE_*.json"))
    assert templates
    for p in templates:
        data=json.loads(p.read_text())
        assert data.get("output_root")=="runs",p
        assert "workspace_mode" not in data,p
        assert "pipeline_release" not in data and "preflight_authorization" not in data,p
    assert (ROOT/"configs/CONFIG_TEMPLATE_TARGETED_CAMPAIGN.json").is_file()
    print("MUTABLE PACKAGE STRUCTURE: PASS")
    return 0
if __name__=="__main__": raise SystemExit(main())
