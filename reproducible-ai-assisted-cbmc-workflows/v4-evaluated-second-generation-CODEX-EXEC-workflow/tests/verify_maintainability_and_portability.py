#!/usr/bin/env python3
"""Guard extracted critical modules and portable-path behavior against regression."""
from __future__ import annotations
import ast
import json
import tempfile
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.common.experiment_protocol import logical_path

MODULES=[
 'agents/common/experiment_protocol.py',
 'agents/common/semantic_gate.py',
 'agents/common/cbmc_evidence.py',
 'agents/common/workflow_policy.py',
 'agents/common/tool_result_contract.py',
]

def main()->int:
    for rel in MODULES:
        path=ROOT/rel; text=path.read_text(encoding='utf-8'); lines=text.splitlines()
        assert len(lines)<=500,(rel,len(lines))
        tree=ast.parse(text)
        for node in ast.walk(tree):
            if isinstance(node,(ast.FunctionDef,ast.AsyncFunctionDef)):
                length=(node.end_lineno or node.lineno)-node.lineno+1
                assert length<=225,(rel,node.name,length)
    registry_path=ROOT/'docs/MAINTAINABILITY_EXCEPTION_REGISTRY.json'
    registry=json.loads(registry_path.read_text(encoding='utf-8'))
    exceptions=registry.get('exceptions',[])
    registered={(row.get('path'),row.get('function')):row for row in exceptions}
    actual={}
    for path in sorted((ROOT/'agents').rglob('*.py')):
        rel=path.relative_to(ROOT).as_posix()
        tree=ast.parse(path.read_text(encoding='utf-8'))
        for node in ast.walk(tree):
            if not isinstance(node,(ast.FunctionDef,ast.AsyncFunctionDef)):
                continue
            length=(node.end_lineno or node.lineno)-node.lineno+1
            if length>150:
                actual[(rel,node.name)]=length
    assert set(actual)==set(registered),(sorted(set(actual)-set(registered)),sorted(set(registered)-set(actual)))
    discovered={path.name for path in (ROOT/'tests').glob('verify_*.py')}
    for key,length in actual.items():
        row=registered[key]
        assert isinstance(row.get('approved_max_lines'),int) and length<=row['approved_max_lines'],(key,length,row.get('approved_max_lines'))
        assert str(row.get('justification') or '').strip(),key
        controls=row.get('mandatory_controls')
        assert isinstance(controls,list) and len(controls)>=3,key
        regressions=row.get('behavioral_regressions')
        assert isinstance(regressions,list) and regressions,key
        assert set(regressions)<=discovered,(key,set(regressions)-discovered)

    marker='/home/'+'girish/'
    shipped_roots=['agents','tests','scripts','docs']
    hits=[]
    paths=[]
    for name in shipped_roots:
        paths.extend((ROOT/name).rglob('*'))
    paths.extend([ROOT/'configs/CONFIG_TEMPLATE_CANONICAL.json', ROOT/'configs/CONFIG_TEMPLATE_FIRST_API_PREFLIGHT.json', ROOT/'configs/CONFIG_TEMPLATE_26_PROPERTY_CAMPAIGN.json'])
    paths.extend((ROOT/'configs/llm_profiles').rglob('*'))
    paths.extend((ROOT/'configs/property_campaigns').rglob('*'))
    for path in paths:
        if path.is_file() and path.suffix.lower() in {'.py','.sh','.json','.md','.txt','.csv'}:
            if marker in path.read_text(encoding='utf-8',errors='replace'):
                hits.append(str(path.relative_to(ROOT)))
    assert not hits,hits
    with tempfile.TemporaryDirectory(prefix='logical_path_') as td:
        base=Path(td).resolve(); child=base/'src'/'poly.c'; child.parent.mkdir(); child.write_text('x')
        assert logical_path(child,(('$WORKFLOW_ROOT',base),))=='$WORKFLOW_ROOT/src/poly.c'
    print('MAINTAINABILITY AND PORTABILITY REGRESSION: PASS')
    return 0
if __name__=='__main__': raise SystemExit(main())
