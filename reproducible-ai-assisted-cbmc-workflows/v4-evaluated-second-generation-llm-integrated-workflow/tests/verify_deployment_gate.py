#!/usr/bin/env python3
"""Mutable-only deployment gate: ordinary configs, in-tree runs and zero-cost preflight."""
from __future__ import annotations
import json, os, subprocess, sys, tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.master_orchestrator import MasterOrchestrator
import preflight_first_api as preflight


def write_json(path: Path, value: dict) -> None:
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(value,indent=2)+"\n",encoding="utf-8")


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="mutable_deployment_") as td:
        ws=Path(td)/"workspace"; (ws/"inputs").mkdir(parents=True)
        spec=ws/"inputs/spec.txt"
        spec.write_text("ML-KEM fixture\n",encoding="utf-8")
        repo=ws/"repo"; repo.mkdir()
        src=repo/"source.c"
        src.write_text("void target(void){}\n",encoding="utf-8")
        subprocess.run(["git","init","-q",str(repo)],check=True)
        subprocess.run(["git","-C",str(repo),"config","user.email","mutable@example.invalid"],check=True)
        subprocess.run(["git","-C",str(repo),"config","user.name","Mutable Gate"],check=True)
        (repo/"README").write_text("fixture\n",encoding="utf-8")
        subprocess.run(["git","-C",str(repo),"add","."],check=True)
        subprocess.run(["git","-C",str(repo),"commit","-qm","fixture"],check=True)
        rev=subprocess.check_output(["git","-C",str(repo),"rev-parse","HEAD"],text=True).strip()
        cbmc=ws/"cbmc"
        cbmc.write_text("#!/usr/bin/env bash\nif [[ ${1:-} == --version ]]; then echo 'CBMC fake'; exit 0; fi\necho 'VERIFICATION SUCCESSFUL'\n",encoding="utf-8")
        cbmc.chmod(0o755)
        config={
          "project_root":str(ws),"run_id":"mutable_deployment_001","output_root":"runs",
          "target_scheme":"ML-KEM","target_function":"target","target_topic":"deployment",
          "verification_tool":"CBMC","artifact_type":"CBMC verification harness","max_iterations":0,
          "parallel_initial_agents":False,"strict_outputs":True,
          "inputs":{"spec_paths":[str(spec)],"code_paths":[str(src)],"code_dir":str(ws/"inputs")},
          "llm":{"mode":"real","model":"local-test-model","api_key_env":"OPENAI_API_KEY"},
          "tool_execution":{"cbmc_binary":str(cbmc),"cbmc_function":"harness","dry_run":False,
             "force_run":False,"require_gate_approval":True,"source_files":[str(src)],"stub_files":[],
             "include_paths":[str(repo)],"defines":[],"working_directory":str(repo),
             "extra_cbmc_args":[],"unwind":3,"step_timeout_seconds":30,"pipeline_timeout_seconds":60,
             "structured_json_required":True},
          "provenance":{"repository_paths":[str(repo)],"source_revision":rev},
          "property_campaign":{"property_family_id":"P16","verification_strategy":"standard_cbmc_harness"},
          "experiment_protocol":{"protocol_version":"llm-first-v1","semantic_advisory_mode":"off",
             "repair_policy":"none_initial_run","structured_cbmc_json_required":True,
             "selected_property_claims_required":True,"mutation_non_vacuity_required":True}
        }
        cfg=ws/"configs/run.json"; norm=ws/"configs/run.normalized.json"; report=ws/"reports/preflight.json"
        write_json(cfg,config)
        rc,result=preflight.run_preflight(cfg,mode="local_only",normalized_config_path=norm)
        assert rc==0,result
        assert result["network_request_performed"] is False
        assert result["workspace_mode"]=="mutable_workspace"
        assert result["checks"]["mutable_workspace_contract"]["in_tree_runs_allowed"] is True
        assert norm.is_file()
        normalized=json.loads(norm.read_text())
        assert "pipeline_release" not in normalized and "preflight_authorization" not in normalized
        orch=MasterOrchestrator(cfg,dry_run=True,strict_outputs=True)
        orch.validate_config(); orch.setup_run_dir()
        assert orch.run_dir==ws/"runs/mutable_deployment_001"
        assert (orch.run_dir/"run_manifest.json").is_file()
        assert len([p for p in (orch.run_dir/"stages").iterdir() if p.is_dir()])==11
    print("MUTABLE-ONLY DEPLOYMENT GATE: PASS")
    return 0
if __name__=="__main__": raise SystemExit(main())
