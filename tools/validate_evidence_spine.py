#!/usr/bin/env python3
from pathlib import Path
import argparse,csv,subprocess
from collections import Counter
EXPECTED_COUNTS={'locators':18,'properties':257,'native':18,'literature':48,'negative':27,'survival':15,'master':14,'representative':573,'native_census':18}
EXPECTED_PROPERTY_COUNTS={'1':51,'2':24,'3':3,'4':13,'5':13,'6':18,'7':17,'8':23,'9':16,'10':19,'11':11,'12':2,'13':16,'14':21,'SA-ADD':3,'SA-SUB':2,'SA-BR':3,'SA-ZERO':2}
ALLOWED_RESULTS={'SUPPORTED','SUPPORTED_WITH_PARTIAL_PRESERVATION','SUPPORTED_DIAGNOSTIC','SUPPORTED_BY_CONSTRUCTION','ASSUMED_FROM_DOCUMENTED_GUARANTEE','SUPPORTING_CONTROL','MEANINGFUL_NEGATIVE','ABSTRACTION_LIMITED_INCONCLUSIVE','RESOURCE_LIMITED_INCONCLUSIVE'}
REVISIONS={'EARLY':'d9613cf60de3132d32475c102d8c2781d84feb34','LATE':'af4c5abdd5958bdc65a03cd5ee86708264f93304'}
REQUIRED_NEGATIVE_IDS={'NEG-C01-PA03','NEG-C01-PA04B','LIM-C01-PA02B','LIM-C01-PA06','LIM-C01-PA07','LIM-C01-PA08','LIM-C02-T3M','EXC-C02-T4TPL','INC-C13-SEED','INC-C14-T2','INC-C14-T3','INC-C14-T4','EXC-C14-SYN','LIM-RQ2-ATTR','LIM-RQ2-EFF','REP-C01-PA01V1','CTRL-C02-T4LOW','CTRL-C02-T4UP','CONFLICT-C04-NATIVE-DIR','CONFLICT-C05-NATIVE-HARNESS','CONFLICT-C07-NATIVE-DIR'}
REQUIRED_NEGATIVE_CATEGORIES={'MEANINGFUL_NEGATIVE','ABSTRACTION_LIMITED_INCONCLUSIVE','RESOURCE_LIMITED_INCONCLUSIVE','EXCLUDED_INVALID','PARTIAL_PRESERVATION','NOT_DEMONSTRABLE','SUPERSEDED_REPAIRED_FAILURE','EXPECTED_FAILURE_CONTROL','EVIDENCE_SOURCE_CONFLICT'}

def load(d,n,e):
 p=d/n
 if not p.exists():e.append(f'Missing {n}');return []
 with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def git(root,*args):
 try:return subprocess.check_output(['git','-C',str(root),*args],text=True,stderr=subprocess.DEVNULL).strip()
 except Exception:return 'UNAVAILABLE'
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--repo-root',default='.');ap.add_argument('--strict',action='store_true');ap.add_argument('--release',action='store_true');ap.add_argument('--no-write-report',action='store_true');a=ap.parse_args()
 root=Path(a.repo_root).resolve();d=root/'docs'/'thesis-evidence';errors=[];warnings=[]
 loc=load(d,'01_CASE_EVIDENCE_LOCATOR.csv',errors);prop=load(d,'02_COMPLETE_PROPERTY_LEDGER.csv',errors);native=load(d,'04_NATIVE_REPOSITORY_DISTINCTNESS_MATRIX.csv',errors);lit=load(d,'05_LITERATURE_ASSURANCE_RELATIONSHIP_MATRIX.csv',errors);neg=load(d,'06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv',errors);surv=load(d,'07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv',errors);master=load(d,'09_MASTER_PROVENANCE_MATRIX.csv',errors);archives=load(d,'10_ARCHIVE_INVENTORY.csv',errors);amap=load(d,'12_ARCHIVE_EVIDENCE_PATH_AND_HASH_MAP.csv',errors);rep=load(d,'16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv',errors);census=load(d,'17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv',errors)
 actual={'locators':len(loc),'properties':len(prop),'native':len(native),'literature':len(lit),'negative':len(neg),'survival':len(surv),'master':len(master),'representative':len(rep),'native_census':len(census)}
 for k,v in EXPECTED_COUNTS.items():
  if actual[k]!=v:errors.append(f'Expected {v} {k} rows, found {actual[k]}')
 if len(archives)!=10:errors.append(f'Expected 10 archive inventory rows, found {len(archives)}')
 if len(amap)!=257:errors.append(f'Expected 257 archive-map rows, found {len(amap)}')
 lids=[r.get('locator_id','') for r in loc];pids=[r.get('property_record_id','') for r in prop];rids=[r.get('artifact_record_id','') for r in rep]
 for name,vals in [('locator_id',lids),('property_record_id',pids),('artifact_record_id',rids)]:
  if len(vals)!=len(set(vals)):errors.append(f'Duplicate {name} values')
 if Counter(r.get('case_id','') for r in prop)!=Counter(EXPECTED_PROPERTY_COUNTS):errors.append(f"Property distribution mismatch: {dict(Counter(r.get('case_id','') for r in prop))}")
 lset=set(lids);inv={r.get('archive_name',''):r for r in archives};amb={r.get('property_record_id',''):r for r in amap}
 req=['formal_relation','input_domain','assumptions_and_grounding','assertion_or_harness_mapping','strongest_bounded_conclusion','explicit_exclusion','archive_name_resolved','archive_sha256','archive_evidence_path','archive_entry_sha256']
 for r in prop:
  key=f"{r.get('case_id')} {r.get('historical_id')}"
  for f in req:
   if not r.get(f,'').strip():errors.append(f'Missing {f}: {key}')
  if r.get('result') not in ALLOWED_RESULTS:errors.append(f"Unknown result {r.get('result')}: {key}")
  if r.get('evidence_locator_id') not in lset:errors.append(f"Unknown evidence locator {r.get('evidence_locator_id')}: {key}")
  if r.get('archive_resolution_status')!='RESOLVED':errors.append(f'Unresolved archive evidence: {key}')
  if r.get('archive_name_resolved') not in inv or inv[r.get('archive_name_resolved')].get('sha256')!=r.get('archive_sha256'):errors.append(f'Archive inventory/hash mismatch: {key}')
  m=amb.get(r.get('property_record_id'))
  if not m:errors.append(f'Missing archive-map row: {key}')
  else:
   for f in ['archive_name_resolved','archive_sha256','archive_evidence_path','archive_entry_sha256','archive_resolution_status']:
    if r.get(f)!=m.get(f):errors.append(f'Ledger/archive-map mismatch {f}: {key}')
 early={'1','2','3','SA-ADD','SA-SUB'}
 for r in prop:
  ex=REVISIONS['EARLY'] if r.get('case_id') in early else REVISIONS['LATE']
  if r.get('source_revision')!=ex:errors.append(f"Unexpected source revision: {r.get('case_id')} {r.get('historical_id')}")
  comp='PARTIAL' if r.get('case_id')=='1' else 'COMPLETE'
  if r.get('evidence_completeness')!=comp:errors.append(f"Unexpected evidence completeness: {r.get('case_id')} {r.get('historical_id')}")
 nids={r.get('record_id','') for r in neg};miss=sorted(REQUIRED_NEGATIVE_IDS-nids)
 if miss:errors.append('Missing required negative/limit/conflict records: '+', '.join(miss))
 cats={r.get('category','') for r in neg};miss=sorted(REQUIRED_NEGATIVE_CATEGORIES-cats)
 if miss:errors.append('Missing required negative/limit categories: '+', '.join(miss))
 hids={r.get('historical_id','') for r in prop};ntok=nids|{r.get('item','') for r in neg}
 for r in surv:
  for t in [x.strip() for x in r.get('supporting_property_ids','').split(';') if x.strip()]:
   if t not in hids:errors.append(f"Survival claim {r.get('claim_id')} references missing supporting property {t}")
  for t in [x.strip() for x in r.get('contrary_or_unresolved_ids','').split(';') if x.strip()]:
   if t not in hids and t not in ntok:warnings.append(f"Survival claim {r.get('claim_id')} contrary token is not directly resolved: {t}")
 if len({r.get('case_id','') for r in native})!=len(native):errors.append('Duplicate native-distinctness case rows')
 if {r.get('case_id','') for r in master}!={str(i) for i in range(1,15)}:errors.append('Master matrix must contain cases 1–14 exactly')
 # Native baseline corrections are mandatory.
 cb={r.get('case_id'):r for r in census}
 if cb.get('7',{}).get('native_proof_directory_status')!='DEDICATED_ONE_CALL_HARNESS_PRESENT':errors.append('Case 7 native scalar harness presence is not recorded correctly')
 if cb.get('9',{}).get('native_proof_directory_status')!='NO_DEDICATED_ZEROIZE_PROOF_DIRECTORY':errors.append('Case 9 zeroize proof-directory absence is not recorded correctly')
 for r in census:
  if r.get('archive_validation_status')!='RESOLVED_AND_HASHED':errors.append(f"Unresolved native census row: {r.get('case_id')}")
 # Literature must refuse exhaustive exact-match/global-novelty claims.
 for r in lit:
  if not r.get('exact_target_property_match_status','').strip():errors.append(f"Missing literature exact-match status: {r.get('case_id')} {r.get('relevant_source_or_project')}")
  if r.get('global_novelty_claim_permitted')!='NO':errors.append(f"Literature row permits global novelty: {r.get('case_id')} {r.get('relevant_source_or_project')}")
 # Representative archive records must be complete.
 for r in rep:
  if r.get('archive_resolution_status')!='RESOLVED' or not r.get('archive_entry_sha256'):errors.append(f"Invalid representative archive mapping: {r.get('artifact_record_id')}")
 required=[root/'README.md',root/'DATA_AVAILABILITY.md',root/'THESIS_EVIDENCE_INDEX.md',root/'REUSE_AND_LICENSING.md',d/'03_FORMAL_CLAIM_CATALOGUE.md',d/'11_TERMINOLOGY_AND_CLAIM_POLICY.md',d/'15_THESIS_SURGERY_AND_CONSISTENCY_QUEUE.md',d/'16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv',d/'17_NATIVE_BASELINE_EVIDENCE_CENSUS.csv',d/'18_CONCERN_TO_EVIDENCE_RESOLUTION_AND_APPROVAL_SCOPE.md',d/'19_PUBLIC_EVIDENCE_AVAILABILITY_CLAIM_POLICY.md']
 for p in required:
  if not p.exists():errors.append(f'Missing required authored file: {p.relative_to(root)}')
 for p in [d/'README.md',d/'03_FORMAL_CLAIM_CATALOGUE.md',d/'09_MASTER_PROVENANCE_MATRIX.md',root/'DATA_AVAILABILITY.md',root/'THESIS_EVIDENCE_INDEX.md']:
  if p.exists():
   low=p.read_text(encoding='utf-8').lower()
   for phrase in ['theorems proved','successful proof-property records']:
    if phrase in low:errors.append(f'Prohibited affirmative terminology in {p.relative_to(root)}: {phrase}')
 if a.strict or a.release:
  badl=[r.get('locator_id','') for r in loc if r.get('resolution_status')!='RESOLVED_HASH_MATCH' or r.get('resolved_repository_root') in {'','UNRESOLVED','AMBIGUOUS'}]
  badp=[r.get('property_record_id','') for r in prop if r.get('public_path_resolution_status')!='RESOLVED_HASH_MATCH' or r.get('resolved_public_evidence_path') in {'','UNRESOLVED','UNRESOLVED_UNTIL_FINALIZER'}]
  badr=[r.get('artifact_record_id','') for r in rep if r.get('public_path_resolution_status')!='RESOLVED_HASH_MATCH' or r.get('resolved_public_path') in {'','UNRESOLVED','UNRESOLVED_UNTIL_FINALIZER'}]
  if badl:errors.append('Unresolved/hash-mismatched repository locators: '+', '.join(badl))
  if badp:errors.append(f'Unresolved/hash-mismatched public property evidence paths: {len(badp)}')
  if badr:errors.append(f'Unresolved/hash-mismatched public representative artefacts: {len(badr)}')
  for fn in ['13_PUBLIC_REPOSITORY_PATH_AUDIT.md','13_PUBLIC_REPOSITORY_PROPERTY_PATH_AUDIT.csv','13_PUBLIC_REPOSITORY_REPRESENTATIVE_ARTEFACT_AUDIT.csv','SHA256SUMS']:
   if not (d/fn).exists():errors.append(f'Missing strict audit output: {fn}')
 if a.release:
  tag=git(root,'describe','--tags','--exact-match');head=git(root,'rev-parse','HEAD');tagcommit=git(root,'rev-list','-n','1','v1.0.0');dirty=git(root,'status','--porcelain')
  if tag!='v1.0.0':errors.append(f'Release mode requires exact tag v1.0.0; found {tag}')
  if head=='UNAVAILABLE' or tagcommit!=head:errors.append(f'Release tag does not point to HEAD: tag={tagcommit} HEAD={head}')
  if dirty not in {'','UNAVAILABLE'}:errors.append('Release mode requires a clean working tree')
 mode='RELEASE' if a.release else 'STRICT' if a.strict else 'STRUCTURAL'
 report=['# Evidence-spine validation report','',f'- Mode: {mode}',f'- Locators: {len(loc)}',f'- Substantive property/control records: {len(prop)}',f'- Representative artefact records: {len(rep)}',f'- Native distinctness rows: {len(native)}',f'- Native baseline census rows: {len(census)}',f'- Literature relationship rows: {len(lit)}',f'- Negative/limit/conflict records: {len(neg)}',f'- Survival-ledger rows: {len(surv)}',f'- Master case rows: {len(master)}','']
 if warnings:report+=['## Warnings']+[f'- {x}' for x in warnings]+['']
 report += (['## FAIL']+[f'- {x}' for x in errors]) if errors else ['## PASS','All selected structure, traceability, terminology, archive mapping, native-baseline correction, literature-boundary, public-path, source-revision, referential-integrity and preservation checks passed.']
 if not (a.release or a.no_write_report):(d/'14_VALIDATION_REPORT.md').write_text('\n'.join(report)+'\n',encoding='utf-8')
 print('\n'.join(report));raise SystemExit(1 if errors else 0)
if __name__=='__main__':main()
