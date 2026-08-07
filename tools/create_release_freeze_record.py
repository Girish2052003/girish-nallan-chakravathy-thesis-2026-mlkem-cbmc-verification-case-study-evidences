#!/usr/bin/env python3
from pathlib import Path
import argparse,subprocess,json,hashlib,datetime

def git(root,*args):return subprocess.check_output(['git','-C',str(root),*args],text=True).strip()
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return h.hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--repo-root',default='.');ap.add_argument('--tag',default='v1.0.0');ap.add_argument('--release-archive');ap.add_argument('--output');ns=ap.parse_args()
 root=Path(ns.repo_root).resolve();head=git(root,'rev-parse','HEAD');commit=git(root,'rev-list','-n','1',ns.tag);tagtype=git(root,'cat-file','-t',ns.tag);dirty=git(root,'status','--porcelain')
 if commit!=head:raise SystemExit(f'Tag {ns.tag} does not point to HEAD: tag={commit} HEAD={head}')
 if dirty:raise SystemExit('Working tree is not clean; freeze record refused')
 out=Path(ns.output) if ns.output else Path.cwd()/f'RELEASE_FREEZE_RECORD_{ns.tag}.json'
 evidence_sum=root/'docs'/'thesis-evidence'/'SHA256SUMS';index=root/'THESIS_EVIDENCE_INDEX.md'
 data={'repository_url':'https://github.com/Girish2052003/girish-nallan-chakravathy-thesis-2026-mlkem-cbmc-verification-case-study-evidences','release_tag':ns.tag,'tag_object_type':tagtype,'tagged_commit':commit,'head_commit':head,'working_tree_clean':True,'generated_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'evidence_documentation_sha256s':{'THESIS_EVIDENCE_INDEX.md':sha(index) if index.exists() else None,'docs/thesis-evidence/SHA256SUMS':sha(evidence_sum) if evidence_sum.exists() else None},'release_archive':None}
 if ns.release_archive:
  p=Path(ns.release_archive);data['release_archive']={'path':str(p),'size_bytes':p.stat().st_size,'sha256':sha(p)}
 out.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8');print(out);print(json.dumps(data,indent=2))
if __name__=='__main__':main()
