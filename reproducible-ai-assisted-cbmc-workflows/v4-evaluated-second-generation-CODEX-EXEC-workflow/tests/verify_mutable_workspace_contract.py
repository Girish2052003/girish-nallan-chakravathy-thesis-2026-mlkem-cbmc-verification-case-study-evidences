#!/usr/bin/env python3
"""Prove that the production package is mutable-only while scientific gates remain."""
from __future__ import annotations
import json, subprocess, sys, tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.common.config_contract import ConfigContractError, normalize_config, validate_pipeline_config
from agents.master_orchestrator import MasterOrchestrator


def base(root: Path) -> dict:
    inputs = root / "inputs"
    inputs.mkdir(parents=True, exist_ok=True)
    spec = inputs / "spec.txt"
    source = inputs / "source.c"
    spec.write_text("ML-KEM fixture\n", encoding="utf-8")
    source.write_text("void target(void){}\n", encoding="utf-8")
    return {"project_root":str(root),"run_id":"contract_001","output_root":"runs",
      "target_scheme":"ML-KEM","target_function":"target","target_topic":"contract",
      "verification_tool":"CBMC","artifact_type":"CBMC verification harness","max_iterations":0,
      "inputs":{"spec_paths":[str(spec)],"code_paths":[str(source)]},"llm":{"mode":"mock","model":"mock"},
      "tool_execution":{"dry_run":True,"force_run":False,"require_gate_approval":True},
      "provenance":{"source_revision":"fixture"},
      "property_campaign":{"property_family_id":"P16","verification_strategy":"standard_cbmc_harness"}}


def main() -> int:
    assert not (ROOT/"agents/common/release_identity.py").exists()
    for absent in ("PACKAGE_MANIFEST.sha256","RELEASE_METADATA.json","verify_release.sh","NO_RELEASE_LOCKS.md"):
        assert not (ROOT/absent).exists(),absent
    production=[ROOT/"agents",ROOT/"preflight_first_api.py"]
    text="\n".join(p.read_text(encoding="utf-8",errors="replace") for basep in production for p in ([basep] if basep.is_file() else basep.rglob("*.py")))
    for forbidden in ("build_pipeline_release_identity","validate_preflight_authorization","--release-zip","--bound-config","_real_execution_binding_errors"):
        assert forbidden not in text,forbidden
    with tempfile.TemporaryDirectory(prefix="mutable_contract_") as td:
        ws=Path(td)
        raw=base(ws)
        normalized=normalize_config(raw,config_path=ws/"config.json",project_root=ws)
        assert normalized["workspace_mode"]=="mutable_workspace"
        report=validate_pipeline_config(normalized,check_input_files=False); report.raise_for_errors()
        legacy=dict(raw); legacy["workspace_mode"]="mutable_workspace"
        assert normalize_config(legacy,config_path=ws/"legacy.json",project_root=ws)["workspace_mode"]=="mutable_workspace"
        old=dict(raw); old["workspace_mode"]="verified_release"
        try: normalize_config(old,config_path=ws/"old.json",project_root=ws)
        except ConfigContractError as exc: assert "not supported" in str(exc)
        else: raise AssertionError("verified_release unexpectedly accepted")
        obsolete=dict(raw); obsolete["pipeline_release"]={"fake":True}; obsolete["preflight_authorization"]={"fake":True}
        n=normalize_config(obsolete,config_path=ws/"obsolete.json",project_root=ws)
        assert "pipeline_release" not in n and "preflight_authorization" not in n
        warnings=validate_pipeline_config(n,check_input_files=False).warnings
        assert any("pipeline_release" in w for w in warnings) and any("preflight_authorization" in w for w in warnings)
        cfg=ws/"config.json"; cfg.write_text(json.dumps(raw,indent=2)+"\n")
        orch=MasterOrchestrator(cfg,dry_run=True,strict_outputs=True,skip_input_checks=True)
        orch.validate_config(); orch.setup_run_dir()
        assert orch.run_dir==ws/"runs/contract_001"
    help_text=subprocess.check_output([sys.executable,str(ROOT/"preflight_first_api.py"),"--help"],text=True)
    assert "--normalized-config" in help_text
    assert "--release-zip" not in help_text and "--bound-config" not in help_text
    print("MUTABLE-ONLY WORKSPACE CONTRACT: PASS")
    return 0
if __name__=="__main__": raise SystemExit(main())
