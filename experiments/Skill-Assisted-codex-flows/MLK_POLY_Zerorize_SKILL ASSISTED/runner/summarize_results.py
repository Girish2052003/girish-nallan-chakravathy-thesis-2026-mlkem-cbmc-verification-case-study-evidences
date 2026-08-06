#!/usr/bin/env python3
import json, sys
from pathlib import Path
THEOREMS={
'SA_ZERO_T1':{
 'assertions':['SA_ZERO_T1_LEFT_SELECTED_BYTES_ZERO','SA_ZERO_T1_RIGHT_SELECTED_BYTES_ZERO','SA_ZERO_T1_LEFT_OUTER_FRAME_PRESERVED','SA_ZERO_T1_RIGHT_OUTER_FRAME_PRESERVED','SA_ZERO_T1_WHOLE_OBJECT_SECRET_HISTORY_CONVERGENCE'],
 'covers':['SA_ZERO_T1_ASSUMPTIONS_FEASIBLE','SA_ZERO_T1_NONTRIVIAL_SECRET_DIFFERENCE','SA_ZERO_T1_TARGET_1_REACHED','SA_ZERO_T1_TARGET_2_REACHED','SA_ZERO_T1_ASSERTION_BLOCK_REACHED'],
 'fail':'SA_ZERO_T1_FC_SECRET_DIFFERENCE_PERSISTS'},
'SA_ZERO_T2':{
 'assertions':['SA_ZERO_T2_FIRST_ERASURE_WITNESS_ZERO','SA_ZERO_T2_OUTER_INTERVAL_FULL_RECOVERY','SA_ZERO_T2_ORIGINAL_OUTER_FRAME_PRESERVED','SA_ZERO_T2_SECOND_CALL_FRAME_PRESERVED','SA_ZERO_T2_RECONTAMINATION_WITNESS_WAS_NONZERO','SA_ZERO_T2_RECONTAMINATION_WITNESS_REERASED'],
 'covers':['SA_ZERO_T2_ASSUMPTIONS_FEASIBLE','SA_ZERO_T2_INITIAL_NONZERO_WITNESS','SA_ZERO_T2_TARGET_1_REACHED','SA_ZERO_T2_RECONTAMINATION_REACHED','SA_ZERO_T2_NONZERO_RECONTAMINATION_WITNESS','SA_ZERO_T2_TARGET_2_REACHED','SA_ZERO_T2_ASSERTION_BLOCK_REACHED'],
 'fail':'SA_ZERO_T2_FC_RECONTAMINATION_PERSISTS'}}

def recs(x):
    if isinstance(x,dict):
        if 'status' in x: yield x
        for v in x.values(): yield from recs(v)
    elif isinstance(x,list):
        for v in x: yield from recs(v)

def statuses(data, token):
    return [str(r.get('status','')).upper() for r in recs(data) if token in json.dumps(r,sort_keys=True)]

def main():
    run=Path(sys.argv[1]).resolve(); results={}; total_success=0; total_cover=0
    for label,spec in THEOREMS.items():
        d=run/label
        required=['harness.c','preprocessed.c','proof_model.goto','cover_model.goto','fail_control_model.goto','proof_properties.txt','cover_properties.txt','fail_control_properties.txt','proof.json','cover.json','fail_control.json','proof_exit_code.txt','cover_exit_code.txt','fail_control_exit_code.txt','body_binding.json','sha256.txt']
        for rel in required:
            p=d/rel
            if not p.is_file() or p.stat().st_size==0: raise RuntimeError(f'missing or empty: {p}')
        if (d/'proof_exit_code.txt').read_text().strip()!='0': raise RuntimeError(label+' proof failed')
        if (d/'cover_exit_code.txt').read_text().strip()!='10': raise RuntimeError(label+' reachability control did not exit 10')
        if (d/'fail_control_exit_code.txt').read_text().strip()!='10': raise RuntimeError(label+' fail control not exit 10')
        binding=json.loads((d/'body_binding.json').read_text())
        if binding.get('body_binding')!='PASS': raise RuntimeError(label+' body binding failed')
        props=(d/'proof_properties.txt').read_text(errors='ignore')
        missing=[x for x in spec['assertions'] if x not in props]
        if missing: raise RuntimeError(f'{label} missing assertion mapping {missing}')
        pd=json.loads((d/'proof.json').read_text()); ps=[str(r.get('status','')).upper() for r in recs(pd)]
        if not ps or any(s in {'FAILURE','FAILED','UNKNOWN','ERROR'} for s in ps): raise RuntimeError(label+' unacceptable proof status')
        success=sum(s in {'SUCCESS','SATISFIED','PASS','PASSED'} for s in ps)
        if success==0: raise RuntimeError(label+' no successful properties')
        cd=json.loads((d/'cover.json').read_text()); covered=[]
        for token in spec['covers']:
            ss=statuses(cd,token)
            if not ss or not any(s in {'FAILURE','FAILED'} for s in ss): raise RuntimeError(f'{label} unreachable {token}: {ss}')
            covered.append(token)
        unexpected_cover=[r for r in recs(cd) if str(r.get('status','')).upper() in {'FAILURE','FAILED'} and not any(t in json.dumps(r,sort_keys=True) for t in spec['covers'])]
        if unexpected_cover: raise RuntimeError(f'{label} unexpected reachability-model failures: {unexpected_cover}')
        fd=json.loads((d/'fail_control.json').read_text()); fs=statuses(fd,spec['fail'])
        if not fs or not any(s in {'FAILURE','FAILED'} for s in fs): raise RuntimeError(label+' planned false claim not rejected')
        unexpected_fail=[r for r in recs(fd) if str(r.get('status','')).upper() in {'FAILURE','FAILED'} and spec['fail'] not in json.dumps(r,sort_keys=True)]
        if unexpected_fail: raise RuntimeError(f'{label} unexpected fail-control failures: {unexpected_fail}')
        results[label]={'proof':'PASS','body_binding':'PASS','expected_failure_control':'PASS','selected_claim_mapping':'YES','target_reachability':'YES','assertion_reachability':'YES','assumption_feasibility':'YES','successful_property_records':success,'satisfied_cover_goals':covered}
        total_success+=success; total_cover+=len(covered)
    dist=json.loads((run/'repository_distinctness.json').read_text())
    if dist.get('repository_distinctness')!='SUPPORTED': raise RuntimeError('distinctness failed')
    final={'campaign':'MLK_POLY_Zerorize_SKILL ASSISTED','technical_target':'mlk_zeroize','authoritative_commit':'af4c5abdd5958bdc65a03cd5ee86708264f93304','authoritative_tree':'54805daff6a91a010c05467ea678117c42a71559','runs_occurred':1,'theorems':results,'successful_property_records_total':total_success,'satisfied_named_cover_goals_total':total_cover,'Selected-claim mapping':'YES','Target reachability':'YES','Assertion reachability':'YES','Assumption feasibility':'YES','Evidence completeness':'COMPLETE','Repository distinctness':'SUPPORTED','Contamination':'NONE KNOWN','overall_verdict':'PASS_COMPLETE_SKILL_ASSISTED_MLK_ZEROIZE_AF4C5ABD_CORPUS'}
    (run/'final_status.json').write_text(json.dumps(final,indent=2)+'\n')
if __name__=='__main__':
    try: main()
    except Exception as e: print('ERROR:',e,file=sys.stderr); raise SystemExit(1)
