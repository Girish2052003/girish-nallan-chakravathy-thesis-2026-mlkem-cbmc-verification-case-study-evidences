#!/usr/bin/env python3
from pathlib import Path
import tempfile, json, sys
ROOT=Path(__file__).resolve().parents[1]; sys.path.insert(0,str(ROOT))
from agents.evaluation_reporter import build_agent11_compact_evidence_bundle, select_agent11_request_evidence
with tempfile.TemporaryDirectory() as td:
 t=Path(td); raw=t/'raw.json'; req=t/'request.json'; spec=t/'fips.txt'; harness=t/'harness.c'; tool=t/'cbmc.txt'; prior=t/'critic.json'; compact=t/'compact.json'
 raw.write_text('x'*1200000); req.write_text('y'*800000); spec.write_text('s'*500000); harness.write_text('void harness(void){}'); tool.write_text('VERIFICATION FAILED'); prior.write_text('{}')
 idx={'rows':[{'stage':'02_spec_extraction','raw_response_path':str(raw),'request_snapshot_path':str(req)}]}
 b=build_agent11_compact_evidence_bundle(measured={'status':'x'},taxonomy={},rq_mapping={},threats={},run_dir=t,llm_index=idx,handoff_index={},tool_index={})
 assert b['policy']['raw_api_response_envelopes_included'] is False
 assert b['policy']['exact_prior_prompts_included'] is False
 assert len(json.dumps(b).encode()) < 100000
 refs=b['omitted_full_file_references']; assert len(refs)==2 and all(x['sha256'] for x in refs)
 compact.write_text(json.dumps(b))
 primary, prior_files, trusted=select_agent11_request_evidence(
  config_data={'inputs':{'spec_paths':[str(spec)]}},compact_bundle_path=compact,
  raw_primary=[spec,harness,tool,raw],prior_context=[prior],trusted_control=[],llm_index=idx,
 )
 assert compact not in primary and harness in primary and tool in primary
 assert spec not in primary and raw not in primary and req not in primary
 assert prior_files==[prior] and compact in trusted
 estimated=sum(p.stat().st_size for p in [*primary,*prior_files,*trusted])
 assert estimated < 900000, estimated
print('AGENT11 COMPACT EVIDENCE BUDGET PASSED')
