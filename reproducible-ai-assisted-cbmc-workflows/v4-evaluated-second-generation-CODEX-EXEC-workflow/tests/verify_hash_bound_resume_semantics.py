#!/usr/bin/env python3
from __future__ import annotations
import sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.master_orchestrator import MasterOrchestrator,AgentSpec
from agents.common.run_layout import RunLayout

with tempfile.TemporaryDirectory(prefix='resume_binding_') as td:
 root=Path(td); (root/'agents').mkdir(); script=root/'agents/stage.py'; script.write_text('print("stage")\n')
 inp=root/'input.c'; inp.write_text('int x;\n')
 run=root/'runs/r'; layout=RunLayout(run,create=True,active_iteration=0)
 # Stage 1 upstream control evidence.
 control=layout.stage_dir('01_master_orchestrator')/'control.json'; control.write_text('{"v":1}\n')
 layout.write_handoff_manifest('01_master_orchestrator',outputs={'control':control},authoritative_source='test',next_stage_consumers=['02_spec_extraction'],notes={'stage_outcome':'ready'})
 output=layout.stage_dir('02_spec_extraction')/'llm_authoritative/out.json'; output.parent.mkdir(parents=True,exist_ok=True); output.write_text('{"ok":true}\n')
 layout.write_handoff_manifest('02_spec_extraction',outputs={'spec_summary':output},authoritative_source='test',next_stage_consumers=['03_code_understanding'],notes={'stage_outcome':'completed'})
 spec=AgentSpec('spec','02_spec_extraction','agents/stage.py',('spec_summary',))
 obj=MasterOrchestrator.__new__(MasterOrchestrator)
 obj.project_root=root; obj.layout=layout; obj.current_iteration=0
 obj.config={
  'project_root':str(root),'inputs':{'spec_paths':[str(inp)],'code_paths':[]},
  'experiment_protocol':{'protocol_sha256':'p1'},'run_id':'r',
 }
 obj.resume=True; obj.resume_policy='abort'; events=[]
 obj.log_event=lambda name,data: events.append((name,data))
 path=obj._write_resume_binding(spec); assert path.is_file()
 assert obj.should_skip_agent(spec) is True
 assert events[-1][0]=='resume_stage_reused'

 # Output tampering is detected even though the file still exists.
 output.write_text('{"ok":false}\n')
 try: obj.should_skip_agent(spec)
 except RuntimeError as exc: assert 'handoff_outputs_mismatch' in str(exc),exc
 else: raise AssertionError('abort policy accepted changed output')
 obj.resume_policy='rerun'; assert obj.should_skip_agent(spec) is False
 assert events[-1][0]=='resume_stage_rerun_required'
 obj.resume_policy='force_reuse'; assert obj.should_skip_agent(spec) is True
 assert events[-1][0]=='resume_stage_force_reused' and events[-1][1]['semantic_provenance_reduced'] is True

 # Restore a new canonical binding, then independently tamper each trust input.
 output.write_text('{"ok":true}\n')
 layout.write_handoff_manifest('02_spec_extraction',outputs={'spec_summary':output},authoritative_source='test',next_stage_consumers=[],notes={'stage_outcome':'completed'})
 obj.resume_policy='abort'; obj._write_resume_binding(spec)
 inp.write_text('int changed;\n')
 valid,m=obj._validate_resume_binding(spec); assert not valid and 'input_files_mismatch' in m,m
 inp.write_text('int x;\n'); obj._write_resume_binding(spec)
 script.write_text('print("changed")\n')
 valid,m=obj._validate_resume_binding(spec); assert not valid and 'agent_script_sha256_mismatch' in m,m
 script.write_text('print("stage")\n'); obj._write_resume_binding(spec)
 obj.config['experiment_protocol']['protocol_sha256']='p2'
 valid,m=obj._validate_resume_binding(spec); assert not valid and 'experiment_protocol_sha256_mismatch' in m,m
 obj.config['experiment_protocol']['protocol_sha256']='p1'; obj._write_resume_binding(spec)
 control.write_text('{"v":2}\n')
 layout.write_handoff_manifest('01_master_orchestrator',outputs={'control':control},authoritative_source='test',next_stage_consumers=['02_spec_extraction'],notes={'stage_outcome':'ready'})
 valid,m=obj._validate_resume_binding(spec); assert not valid and 'upstream_handoffs_mismatch' in m,m

 # Missing declared files may never be force-reused.
 output.unlink(); obj.resume_policy='force_reuse'
 try: obj.should_skip_agent(spec)
 except RuntimeError as exc: assert 'missing_file:spec_summary' in str(exc),exc
 else: raise AssertionError('force_reuse accepted missing output')
print('HASH-BOUND RESUME SEMANTICS: PASS')
