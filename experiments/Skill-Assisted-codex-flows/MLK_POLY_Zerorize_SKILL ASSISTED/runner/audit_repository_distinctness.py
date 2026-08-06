#!/usr/bin/env python3
import json, subprocess, sys
from pathlib import Path
TOKENS=[
'whole-object secret-history convergence',
'targeted recovery after symbolic subrange recontamination',
'SA_ZERO_T1_WHOLE_OBJECT_SECRET_HISTORY_CONVERGENCE',
'SA_ZERO_T2_OUTER_INTERVAL_FULL_RECOVERY',
'SA_ZERO_T2_RECONTAMINATION_WITNESS_REERASED']

def main():
    if len(sys.argv)!=3: return 2
    repo=Path(sys.argv[1]).resolve(); out=Path(sys.argv[2]).resolve()
    raw=subprocess.check_output(['git','-C',str(repo),'ls-files','-z'])
    files=[x.decode('utf-8','surrogateescape') for x in raw.split(b'\0') if x]
    matches=[]; scanned=0
    for rel in files:
        p=repo/rel
        try:
            if not p.is_file() or p.stat().st_size>5_000_000: continue
            text=p.read_text(encoding='utf-8',errors='ignore')
        except OSError: continue
        scanned+=1
        for token in TOKENS:
            if token in text: matches.append({'file':rel,'token':token})
    data={'tracked_files':len(files),'scanned_text_files':scanned,'matches':matches,
          'repository_distinctness':'SUPPORTED' if not matches else 'NOT_SUPPORTED',
          'contamination':'NONE KNOWN' if not matches else 'POSSIBLE',
          'scope':'Exact-token audit of the pinned repository; not a worldwide novelty claim.'}
    out.write_text(json.dumps(data,indent=2)+'\n')
    return 0 if not matches else 1
if __name__=='__main__': raise SystemExit(main())
