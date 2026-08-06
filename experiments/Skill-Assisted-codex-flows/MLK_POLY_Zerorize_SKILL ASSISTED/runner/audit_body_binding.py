#!/usr/bin/env python3
import json,re,sys
from pathlib import Path
if len(sys.argv)!=4:
    raise SystemExit('usage: audit_body_binding.py FUNCTIONS PREPROCESSED OUTPUT')
functions=Path(sys.argv[1]).read_text(encoding='utf-8',errors='ignore')
source=Path(sys.argv[2]).read_text(encoding='utf-8',errors='ignore')
out=Path(sys.argv[3])
data={
  'production_target_present_in_goto':'mlk_zeroize' in functions,
  'memset_present_in_goto':any(x in functions for x in ('memset','__CPROVER_memset','mlk_memset')),
  'production_target_present_in_preprocessed_source':'mlk_zeroize' in source,
  'zero_fill_memset_present_in_preprocessed_source':bool(re.search(r'(?:mlk_)?memset\s*\([^;]*,\s*0\s*,',source,re.S)),
  'inline_memory_barrier_present_in_preprocessed_source':('__asm__' in source and 'memory' in source),
}
data['body_binding']='PASS' if all(data.values()) else 'FAIL'
out.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
raise SystemExit(0 if data['body_binding']=='PASS' else 1)
