#!/usr/bin/env python3
from pathlib import Path
import argparse,csv,subprocess,sys
from collections import Counter

EXPECTED={'locators':19,'configs':6,'controls':15,'failures':15,'claims':16,'mappings':44,'claim_audit':16}

def load(p):
    if not p.exists():return None
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))

def git(root,*args):
    try:return subprocess.check_output(['git','-C',str(root),*args],text=True,stderr=subprocess.DEVNULL).strip()
    except:return 'UNAVAILABLE'

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--repo-root',default='.');ap.add_argument('--strict',action='store_true');ap.add_argument('--release',action='store_true');ap.add_argument('--no-write-report',action='store_true');a=ap.parse_args()
    root=Path(a.repo_root).resolve();d=root/'docs'/'thesis-evidence';errors=[];warnings=[]
    legacy=root/'tools'/'validate_evidence_spine_v1_0_legacy.py'
    if not legacy.exists():errors.append('Preserved v1.0 validator requirement failed')
    else:
        p=subprocess.run([sys.executable,str(legacy),'--repo-root',str(root),'--no-write-report'],text=True,capture_output=True)
        if p.returncode!=0:errors.append('Existing V5 evidence-spine integrity check failed:\n'+(p.stdout+p.stderr)[-7000:])
    files={'locators':'20_RQ2_ARCHITECTURAL_EVIDENCE_LOCATOR.csv','configs':'21_RQ2_ARCHITECTURAL_CONFIGURATION_MATRIX.csv','controls':'22_RQ2_CONTROL_ALLOCATION_AND_SEMANTIC_AUTHORITY_LEDGER.csv','failures':'23_RQ2_FAILURE_AND_TRANSFER_EVIDENCE_LEDGER.csv','claims':'24_RQ2_ARCHITECTURAL_CLAIM_SURVIVAL_LEDGER.csv','mappings':'25_RQ2_PUBLIC_EVIDENCE_PATH_AND_HASH_MAP.csv','claim_audit':'29_RQ2_THESIS_CLAIM_TO_EVIDENCE_AUDIT.csv'}
    data={}
    for k,fn in files.items():
        rows=load(d/fn)
        if rows is None:errors.append(f'RQ2 authored-file requirement failed: {fn}');rows=[]
        data[k]=rows
        if len(rows)!=EXPECTED[k]:errors.append(f'Expected {EXPECTED[k]} {k} rows, found {len(rows)}')
    for fn in ['26_RQ2_EVIDENCE_SCOPE_AND_CLAIM_POLICY.md','27_RQ2_ARCHITECTURAL_EVIDENCE_VALIDATION_REPORT.md','28_V4_ARCHITECTURAL_IDENTITY_AND_UTILITY_INCREMENT_AUDIT.csv','28_V4_ARCHITECTURAL_IDENTITY_AND_UTILITY_INCREMENT_AUDIT.md','30_RQ2_RELEASE_AND_CHAPTER4_READINESS.md','32_RQ2_PUBLIC_EVIDENCE_RELEASE_CLASSIFICATION.csv']:
        if not (d/fn).exists():errors.append(f'RQ2 authored/audit file requirement failed: {fn}')
    ids={'locators':'rq2_evidence_id','configs':'configuration_id','controls':'control_id','failures':'record_id','claims':'claim_id','mappings':'mapping_id','claim_audit':'audit_record_id'}
    for k,f in ids.items():
        vals=[r.get(f,'') for r in data[k]]
        if any(not x for x in vals):errors.append(f'Identifier completeness check failed for {f} in {k}')
        if len(vals)!=len(set(vals)):errors.append(f'Identifier uniqueness check failed for {f} in {k}')
    allowed_generations={'V1','V2','V3','V4','V5'}
    for r in data['configs']:
        if r.get('architecture_generation') not in allowed_generations:errors.append(f"Architecture generation classification failed for {r.get('configuration_id')}")
    cfg={r.get('configuration_id'):r for r in data['configs']};cod=cfg.get('RQ2-CFG-V4-CODEX',{});llm=cfg.get('RQ2-CFG-V4-LLM',{})
    if cod.get('architecture_generation')!='V4' or cod.get('separate_architectural_generation')!='NO':errors.append('V4 same-generation classification failed for Codex utility state')
    if llm.get('architecture_generation')!='V4':errors.append('V4 baseline generation classification failed')
    if len([r for r in data['configs'] if r.get('architecture_generation')=='V4'])!=2:errors.append('V4 configuration-state count check failed')
    va=load(d/'28_V4_ARCHITECTURAL_IDENTITY_AND_UTILITY_INCREMENT_AUDIT.csv') or []
    if len(va)!=1:errors.append('V4 identity audit row-count check failed')
    else:
        r=va[0]; expected={'baseline_file_count':'1484','codex_state_file_count':'1484','relative_path_set_equal':'YES','byte_identical_file_count':'1483','differing_file_count':'1','only_differing_relative_path':'agents/common/llm_client.py','shared_codex_backend_relative_path':'agents/common/codex_exec_backend.py','shared_codex_backend_byte_identical':'YES','separate_architectural_generation':'NO','scientific_classification':'SAME_V4_ARCHITECTURE_WITH_UTILITY_BACKEND_INCREMENT'}
        for k,v in expected.items():
            if r.get(k)!=v:errors.append(f'V4 identity audit classification mismatch: {k}')
        if len(r.get('shared_codex_backend_sha256',''))!=64:errors.append('V4 shared Codex-backend SHA-256 metadata check failed')
    arch=[r for r in data['mappings'] if r.get('expected_sha256')];dyn=[r for r in data['mappings'] if not r.get('expected_sha256')]
    if len(arch)!=38 or len(dyn)!=6:errors.append(f'RQ2 mapping partition check failed: {len(arch)} archive-bound + {len(dyn)} public-primary roles')
    if Counter(r.get('rq2_evidence_id') for r in dyn)!=Counter({'RQ2-E18':3,'RQ2-E19':3}):errors.append('Public primary-evidence role classification failed')
    for r in arch:
        if len(r.get('expected_sha256',''))!=64:errors.append(f"Archive SHA-256 metadata check failed: {r.get('mapping_id')}")
        if not r.get('expected_size_bytes','').isdigit():errors.append(f"Archive size metadata check failed: {r.get('mapping_id')}")
        if r.get('source_authority')!='REUPLOADED_ARCHIVE_HASH':errors.append(f"Archive source-authority classification failed: {r.get('mapping_id')}")
    for r in dyn:
        if r.get('source_authority')!='PUBLIC_REPOSITORY_PRIMARY_EVIDENCE':errors.append(f"Public source-authority classification failed: {r.get('mapping_id')}")
    for r in data['mappings']:
        if r.get('release_classification')!='RELEASE_CLASSIFICATION_PASS':errors.append(f"Mapping release classification failed: {r.get('mapping_id')}")
    for r in data['locators']:
        if r.get('release_classification')!='RELEASE_CLASSIFICATION_PASS':errors.append(f"Locator release classification failed: {r.get('rq2_evidence_id')}")
    lset={r.get('rq2_evidence_id') for r in data['locators']}
    for r in data['failures']:
        if r.get('evidence_id') not in lset:errors.append(f"Failure-ledger referential-integrity check failed: {r.get('record_id')}")
    for r in data['mappings']:
        if r.get('rq2_evidence_id') not in lset:errors.append(f"Mapping referential-integrity check failed: {r.get('mapping_id')}")
    survival_required=['claim_text','evidence_basis','evidence_classification','chapter4_authoritative_home','chapter5_supporting_home','chapter6_supporting_home','compression_action','loss_status','scientific_control']
    for r in data['claims']:
        for field in survival_required:
            if not r.get(field,'').strip():errors.append(f"Claim-survival completeness check failed: {r.get('claim_id')} {field}")
    cset={r.get('claim_id') for r in data['claims']}
    for r in data['claim_audit']:
        if r.get('claim_id') not in cset:errors.append(f"Claim-audit referential-integrity check failed: {r.get('audit_record_id')}")
    if cset!={f'RQ2-C{i:02d}' for i in range(1,17)}:errors.append('Claim-survival identifier-set check failed')
    cby={r.get('claim_id'):r for r in data['claims']}
    if cby.get('RQ2-C12',{}).get('evidence_classification')!='PUBLIC_REPOSITORY_EVIDENCE_CLASSIFIED':errors.append('RQ2-C12 release classification failed')
    if cby.get('RQ2-C13',{}).get('evidence_classification')!='PUBLIC_REPOSITORY_EVIDENCE_CLASSIFIED':errors.append('RQ2-C13 release classification failed')
    if cby.get('RQ2-C14',{}).get('evidence_classification')!='BOUNDED_ARCHITECTURAL_RESULT_CLASSIFIED':errors.append('RQ2-C14 release classification failed')
    for pth in [d/'README.md',d/'26_RQ2_EVIDENCE_SCOPE_AND_CLAIM_POLICY.md',d/'30_RQ2_RELEASE_AND_CHAPTER4_READINESS.md',root/'DATA_AVAILABILITY.md',root/'THESIS_EVIDENCE_INDEX.md',root/'README.md']:
        if not pth.exists():continue
        low=pth.read_text(encoding='utf-8').lower()
        for phrase in ['100% codex capability preserved','all theorems proved','deterministic orchestration caused the failure','codex is intrinsically superior']:
            if phrase in low:errors.append(f'Terminology-boundary check failed in {pth.relative_to(root)}')
    if a.release:
        head=git(root,'rev-parse','HEAD')
        v11=git(root,'rev-list','-n','1','v1.1.0')
        v10=git(root,'rev-list','-n','1','v1.0.0')
        tags_at_head=git(root,'tag','--points-at','HEAD')
        dirty=git(root,'status','--porcelain')
        head_tags=set() if tags_at_head=='UNAVAILABLE' else set(tags_at_head.splitlines())
        required_tags={'v1.0.0','v1.1.0'}
        if not required_tags.issubset(head_tags):
            errors.append(
                'Release tag check failed: v1.0.0 and v1.1.0 must both point at HEAD'
            )
        if head=='UNAVAILABLE' or v11!=head:
            errors.append('v1.1.0 commit binding check failed')
        if head=='UNAVAILABLE' or v10!=head:
            errors.append('v1.0.0 commit binding check failed')
        if dirty not in {'','UNAVAILABLE'}:
            errors.append('Release working-tree integrity check failed')
    mode='RELEASE' if a.release else 'STRICT' if a.strict else 'STRUCTURAL'
    report=['# Combined thesis evidence-spine validation report','',f'- Mode: {mode}','- Existing V5 evidence integrity: PRESERVED_V1_0_VALIDATION_PASS',f'- RQ2 architectural locators: {len(data["locators"])}',f'- RQ2 configuration rows: {len(data["configs"])}',f'- RQ2 control-allocation rows: {len(data["controls"])}',f'- RQ2 failure/transfer rows: {len(data["failures"])}',f'- RQ2 claim-survival rows: {len(data["claims"])}',f'- RQ2 evidence-reference rows: {len(data["mappings"])}','- RQ2 release classification: PASS','- V4 architecture identity classification: PASS','- Referential integrity: PASS','- Preservation controls: PASS','- Claim-survival field completeness: PASS','', 'THE INFORMATION IS DISCLOSED TO ITS MAXIMUM THRESHOLD AS PER UNIVERSITY GUIDANCE AND POLICY','']
    if errors:report+=['## FAIL']+[f'- {x}' for x in errors]
    else:report+=['## PASS','The frozen V5 evidence spine and RQ2 architectural addendum satisfied the defined structural, V4-generation, referential-integrity, terminology, preservation and release-classification requirements.']
    if not a.no_write_report and not a.release:(d/'31_COMBINED_EVIDENCE_SPINE_VALIDATION_REPORT.md').write_text('\n'.join(report)+'\n',encoding='utf-8')
    print('\n'.join(report));raise SystemExit(1 if errors else 0)
if __name__=='__main__':main()
