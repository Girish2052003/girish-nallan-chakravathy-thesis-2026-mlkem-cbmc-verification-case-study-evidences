#!/usr/bin/env python3
from pathlib import Path
import argparse,csv,hashlib,subprocess

def git(root,*args):
 try:return subprocess.check_output(['git','-C',str(root),*args],text=True,stderr=subprocess.DEVNULL).strip()
 except Exception:return 'UNAVAILABLE'

def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return h.hexdigest()

def norm(s):return str(s).replace('\\','/').strip('/').lower()

def resolve_file(files,expected_path,expected_sha='',preferred_root=''):
 ep=norm(expected_path); base=Path(expected_path).name.lower(); pref=norm(preferred_root)
 suffix=[p for p in files if norm(p).endswith(ep)]
 candidates=suffix or [p for p in files if p.name.lower()==base]
 candidates=sorted(set(candidates),key=lambda p:(0 if pref and norm(p).startswith(pref+'/') else 1,len(p.parts),str(p)))
 if not candidates:return '', '', 'UNRESOLVED',0
 if expected_sha:
  matching=[p for p in candidates if sha(p)==expected_sha]
  if matching:candidates=matching+[p for p in candidates if p not in matching]
 p=candidates[0];actual=sha(p)
 status='RESOLVED_HASH_MATCH' if expected_sha and actual==expected_sha else 'RESOLVED_HASH_MISMATCH' if expected_sha else 'RESOLVED'
 return p,actual,status,len(candidates)

def load(path):
 with path.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))

def save(path,rows,fields):
 with path.open('w',newline='',encoding='utf-8') as f:
  w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(rows)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--repo-root',default='.');ns=ap.parse_args()
 root=Path(ns.repo_root).resolve();d=root/'docs'/'thesis-evidence'
 locp=d/'01_CASE_EVIDENCE_LOCATOR.csv';propp=d/'02_COMPLETE_PROPERTY_LEDGER.csv';repp=d/'16_REPRESENTATIVE_ARTEFACT_PATH_AND_HASH_MAP.csv'
 if not locp.exists() or not propp.exists() or not repp.exists():raise SystemExit('Evidence-spine CSV files are missing')
 allpaths=[p for p in root.rglob('*') if '.git' not in p.parts]
 dirs=[p for p in allpaths if p.is_dir()];files=[p for p in allpaths if p.is_file()]
 lr=load(locp);lf=list(lr[0]);audit=[];root_fail=[];summary_fail=[]
 for r in lr:
  suffix=Path(r['archive_root']).parts
  exact=[p for p in dirs if len(p.parts)>=len(suffix) and tuple(p.parts[-len(suffix):])==suffix]
  if not exact:
   term=r['repository_root_search_term'].replace('\\','/').strip('/')
   explicit=root/term
   exact=[explicit] if explicit.is_dir() else [p for p in dirs if p.name==Path(term).name]
  exact=sorted(set(exact),key=lambda p:(len(p.relative_to(root).parts),str(p)))
  resolved=str(exact[0].relative_to(root)) if len(exact)==1 else ('AMBIGUOUS' if exact else 'UNRESOLVED')
  sp,ssha,sstatus,scount=resolve_file(files,r['principal_summary_archive_path'],r['principal_summary_entry_sha256'],resolved if resolved not in {'UNRESOLVED','AMBIGUOUS'} else '')
  r['resolved_repository_root']=resolved
  r['resolved_principal_summary']=str(sp.relative_to(root)) if sp else 'UNRESOLVED'
  r['resolution_status']='RESOLVED_HASH_MATCH' if resolved not in {'UNRESOLVED','AMBIGUOUS'} and sstatus=='RESOLVED_HASH_MATCH' else 'UNRESOLVED_AMBIGUOUS_OR_HASH_MISMATCH'
  r['resolution_notes']=f'root_candidates={len(exact)}; summary_candidates={scount}; summary_status={sstatus}'
  if resolved in {'UNRESOLVED','AMBIGUOUS'}:root_fail.append(r['locator_id'])
  if sstatus!='RESOLVED_HASH_MATCH':summary_fail.append(r['locator_id'])
  audit.append({'locator_id':r['locator_id'],'case_id':r['case_id'],'resolved_root':resolved,'resolved_summary':r['resolved_principal_summary'],'summary_hash_status':sstatus,'root_candidates':len(exact),'summary_candidates':scount,'status':r['resolution_status']})
 save(locp,lr,lf)
 locroot={r['locator_id']:r['resolved_repository_root'] for r in lr}

 pr=load(propp);pf=list(pr[0]);pa=[];prop_fail=[]
 for r in pr:
  preferred=locroot.get(r['evidence_locator_id'],'')
  p,actual,status,count=resolve_file(files,r['archive_evidence_path'],r['archive_entry_sha256'],preferred)
  r['resolved_public_evidence_path']=str(p.relative_to(root)) if p else 'UNRESOLVED';r['public_evidence_sha256']=actual;r['public_path_resolution_status']=status;r['public_path_candidate_count']=str(count)
  if status!='RESOLVED_HASH_MATCH':prop_fail.append(r['property_record_id'])
  pa.append({'property_record_id':r['property_record_id'],'case_id':r['case_id'],'historical_id':r['historical_id'],'archive_evidence_path':r['archive_evidence_path'],'resolved_public_evidence_path':r['resolved_public_evidence_path'],'expected_sha256':r['archive_entry_sha256'],'actual_sha256':actual,'candidate_count':count,'status':status})
 save(propp,pr,pf)

 rr=load(repp);rf=list(rr[0]);ra=[];rep_fail=[]
 for r in rr:
  preferred=locroot.get(r['locator_id'],'')
  p,actual,status,count=resolve_file(files,r['archive_path'],r['archive_entry_sha256'],preferred)
  r['resolved_public_path']=str(p.relative_to(root)) if p else 'UNRESOLVED';r['public_sha256']=actual;r['public_path_resolution_status']=status;r['public_path_candidate_count']=str(count)
  if status!='RESOLVED_HASH_MATCH':rep_fail.append(r['artifact_record_id'])
  ra.append({'artifact_record_id':r['artifact_record_id'],'locator_id':r['locator_id'],'case_id':r['case_id'],'artifact_category':r['artifact_category'],'archive_path':r['archive_path'],'resolved_public_path':r['resolved_public_path'],'expected_sha256':r['archive_entry_sha256'],'actual_sha256':actual,'candidate_count':count,'status':status})
 save(repp,rr,rf)

 head=git(root,'rev-parse','HEAD');tag=git(root,'describe','--tags','--exact-match')
 report=['# Public repository path-resolution audit','',f'- Repository root: `{root}`',f'- Working-tree base HEAD: `{head}`',f'- Exact tag at base HEAD: `{tag}`',f'- Investigation roots resolved: {len(lr)-len(root_fail)}/{len(lr)}',f'- Principal summaries hash-matched: {len(lr)-len(summary_fail)}/{len(lr)}',f'- Property evidence files hash-matched: {len(pr)-len(prop_fail)}/{len(pr)}',f'- Representative artefacts hash-matched: {len(rr)-len(rep_fail)}/{len(rr)}','', '| Locator | Case | Resolved root | Resolved summary | Summary hash | Status |','|---|---|---|---|---|---|']
 for a in audit:report.append(f"| {a['locator_id']} | {a['case_id']} | `{a['resolved_root']}` | `{a['resolved_summary']}` | {a['summary_hash_status']} | {a['status']} |")
 if root_fail or summary_fail or prop_fail or rep_fail:
  report += ['','## FAIL']
  if root_fail:report.append('- Unresolved roots: '+', '.join(root_fail))
  if summary_fail:report.append('- Unresolved/hash-mismatched summaries: '+', '.join(summary_fail))
  if prop_fail:report.append(f'- Unresolved/hash-mismatched property records: {len(prop_fail)}; see `13_PUBLIC_REPOSITORY_PROPERTY_PATH_AUDIT.csv`.')
  if rep_fail:report.append(f'- Unresolved/hash-mismatched representative artefacts: {len(rep_fail)}; see `13_PUBLIC_REPOSITORY_REPRESENTATIVE_ARTEFACT_AUDIT.csv`.')
 else:report += ['','## PASS','All investigation roots, principal summaries, substantive-property evidence files and representative artefacts were resolved and hash-matched against the audited archive entries.']
 (d/'13_PUBLIC_REPOSITORY_PATH_AUDIT.md').write_text('\n'.join(report)+'\n',encoding='utf-8')
 save(d/'13_PUBLIC_REPOSITORY_PROPERTY_PATH_AUDIT.csv',pa,list(pa[0]))
 save(d/'13_PUBLIC_REPOSITORY_REPRESENTATIVE_ARTEFACT_AUDIT.csv',ra,list(ra[0]))
 targets=[]
 for base in [d,root/'tools',root/'templates']:
  if base.exists():targets += [p for p in base.rglob('*') if p.is_file() and p.name!='SHA256SUMS']
 (d/'SHA256SUMS').write_text('\n'.join(f'{sha(p)}  {p.relative_to(root)}' for p in sorted(set(targets)))+'\n',encoding='utf-8')
 print(f'roots={len(lr)-len(root_fail)}/{len(lr)} summaries={len(lr)-len(summary_fail)}/{len(lr)} properties={len(pr)-len(prop_fail)}/{len(pr)} representative={len(rr)-len(rep_fail)}/{len(rr)} HEAD={head} tag={tag}')
 raise SystemExit(2 if root_fail or summary_fail or prop_fail or rep_fail else 0)
if __name__=='__main__':main()
