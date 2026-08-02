#!/usr/bin/env python3
"""Behavioral regression: failures must point to populated authoritative evidence."""
from __future__ import annotations
import json
import sys
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.master_orchestrator import MasterOrchestrator


def main()->int:
    with tempfile.TemporaryDirectory(prefix='failure_diagnostic_') as td:
        project=Path(td)
        template=json.loads((ROOT/'configs/CONFIG_TEMPLATE_CANONICAL.json').read_text())
        template['project_root']=str(project)
        template['run_id']='diagnostic_fixture'
        template['output_root']='runs'
        spec=project/'spec.txt'; spec.write_text('fixture specification',encoding='utf-8')
        code=project/'target.c'; code.write_text('void mlk_poly_add(void) {}',encoding='utf-8')
        template['inputs']={'spec_paths':[str(spec)],'code_dir':str(project),'code_paths':[str(code)]}
        template['provenance']={'repository_paths':[],'source_revision':'fixture-revision'}
        template['llm']={'mode':'mock','model':'mock-model','provider':'openai','api_key_env':'OPENAI_API_KEY','store':False,'max_retries':0}
        cfg=project/'config.json'; cfg.write_text(json.dumps(template),encoding='utf-8')
        failer=project/'fail_agent.py'
        failer.write_text('''#!/usr/bin/env python3
import json,os,sys
from pathlib import Path
stage=Path(os.environ["THESIS_STAGE_DIR"])
out=stage/"diagnostics"/"forced_status.json"
out.parent.mkdir(parents=True,exist_ok=True)
out.write_text(json.dumps({"stage":"02_spec_extraction","status":"failed","errors":[{"message":"forced diagnostic root cause"}]}),encoding="utf-8")
sys.exit(7)
''',encoding='utf-8')
        orch=MasterOrchestrator(cfg,skip_input_checks=True,strict_outputs=True)
        orch.validate_config(); orch.setup_run_dir()
        orch.build_agent_command=lambda spec, extra_args=None: [sys.executable,str(failer)]
        try:
            orch.run_agent('spec_extraction')
            raise AssertionError('Required failure was not propagated')
        except RuntimeError as exc:
            text=str(exc)
            assert 'forced diagnostic root cause' in text, text
            assert 'stage_status=' in text, text
            assert 'stderr=' in text, text
        stderr=orch.layout.logs_dir('02_spec_extraction')/'spec_extraction_stderr.txt'
        assert stderr.is_file(), stderr
        stderr_text=stderr.read_text()
        assert 'forced diagnostic root cause' in stderr_text, stderr_text
        assert 'stage_status=' in stderr_text, stderr_text
    print('FAILURE DIAGNOSTIC REGRESSION: PASS')
    return 0

if __name__=='__main__': raise SystemExit(main())
