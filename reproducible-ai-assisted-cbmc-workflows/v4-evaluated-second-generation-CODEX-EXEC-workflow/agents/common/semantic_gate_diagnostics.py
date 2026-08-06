"""Focused vacuity, triviality, and legacy issue diagnostics for semantic_gate."""
from __future__ import annotations
import re
from typing import Any, Dict, List, Mapping
JsonDict=Dict[str,Any]
HARD='critical'; WARNING='warning'

def _issue(issue_id:str,message:str,*,severity:str=HARD,category:str='semantic_fidelity',evidence:JsonDict|None=None)->JsonDict:
 return {'issue_id':issue_id,'severity':severity,'category':category,'message':message,'blocks_tool_execution':severity==HARD,'affected_claim_ids':[],'evidence':evidence or {}}

def normalize_expr(value:str)->str:
 value=re.sub(r"/\*.*?\*/|//[^\n]*","",value,flags=re.S)
 return re.sub(r"\s+","",value)

def assume_expressions(harness:str)->List[str]:
 rows=[]
 for match in re.finditer(r"\b__CPROVER_assume\s*\(",harness):
  start=harness.find('(',match.start())+1; depth=1; index=start
  while index<len(harness) and depth:
   if harness[index]=='(': depth+=1
   elif harness[index]==')': depth-=1
   index+=1
  if depth==0: rows.append(harness[start:index-1].strip())
 return rows

def vacuity_findings(harness:str)->List[JsonDict]:
 raw=assume_expressions(harness); normalized={normalize_expr(x).lower():x for x in raw}; findings=[]
 for expr,original in normalized.items():
  if expr in {'0','false','__cprover_false'}: findings.append({'kind':'literal_false','expression':original})
  if re.fullmatch(r"([a-z_]\w*)!=\1",expr,re.I) or re.fullmatch(r"([a-z_]\w*)<\1",expr,re.I): findings.append({'kind':'self_contradiction','expression':original})
  opposites=[]
  if '==' in expr: opposites.append(expr.replace('==','!=',1))
  elif '!=' in expr: opposites.append(expr.replace('!=','==',1))
  opposites.append(expr[1:] if expr.startswith('!') else '!'+expr)
  for opposite in opposites:
   if opposite in normalized:
    findings.append({'kind':'direct_contradiction','expression':original,'opposite':normalized[opposite]}); break
 null_vars=set(re.findall(r"\b([A-Za-z_]\w*)\s*=\s*(?:NULL|0)\s*;",harness))
 for var in sorted(null_vars):
  if re.search(rf"__CPROVER_(?:is_fresh|memory_no_alias)\s*\(\s*{re.escape(var)}\b",harness): findings.append({'kind':'null_plus_freshness','variable':var})
 return findings

def loop_guard_tautologies(harness:str)->List[JsonDict]:
 findings=[]; loop_re=re.compile(r"for\s*\([^;]*;(?P<guard>[^;]+);[^)]*\)\s*\{(?P<body>.*?)\}",re.S); assert_re=re.compile(r"__CPROVER_assert\s*\((?P<expr>[^,;]+)",re.S)
 for loop in loop_re.finditer(harness):
  guard=normalize_expr(loop.group('guard'))
  for assertion in assert_re.finditer(loop.group('body')):
   expr=normalize_expr(assertion.group('expr'))
   if expr and (expr==guard or expr in guard or guard in expr): findings.append({'guard':loop.group('guard').strip(),'assertion':assertion.group('expr').strip(),'line':harness.count('\n',0,loop.start()+assertion.start())+1})
 return findings

def trivial_assertions(harness:str)->List[JsonDict]:
 findings=[]
 for match in re.finditer(r"\b__CPROVER_assert\s*\((?P<expr>[^,;]+)",harness,re.S):
  raw=match.group('expr').strip(); expr=normalize_expr(raw).lower()
  if expr in {'1','true','__cprover_true'}: findings.append({'kind':'literal_true','expression':raw})
  if re.fullmatch(r"([a-z_]\w*)==\1",expr,re.I): findings.append({'kind':'self_equality','expression':raw})
 return findings

def append_legacy_compatibility_issues(issues:List[JsonDict],plan:Mapping[str,Any],harness_text:str,*,analysis_only:bool)->None:
 issue_ids={str(r.get('issue_id') or '') for r in issues}
 if issue_ids & {'assumption_not_mapped','harness_assumption_binding_invalid','contract_assumption_absent','assumption_not_executable'} and 'missing_required_assumption' not in issue_ids:
  issues.append(_issue('missing_required_assumption','A required assumption is absent or not exactly bound to executable evidence.')); issue_ids.add('missing_required_assumption')
 if issue_ids & {'claim_not_mapped','claim_identity_mismatch','builtin_claim_identity_absent','contract_claim_binding_invalid','harness_claim_binding_invalid'} and 'missing_claim_to_cbmc_mapping' not in issue_ids:
  issues.append(_issue('missing_claim_to_cbmc_mapping','At least one selected claim lacks an exact executable-to-CBMC identity mapping.')); issue_ids.add('missing_claim_to_cbmc_mapping')
 if not analysis_only and issue_ids & {'zero_selected_claims','selected_claim_not_fully_implemented','semantic_property_incomplete','missing_claim_to_cbmc_mapping'} and 'missing_selected_property_claim' not in issue_ids:
  issues.append(_issue('missing_selected_property_claim','The selected property has no complete, uniquely bound executable claim.')); issue_ids.add('missing_selected_property_claim')
 if 'trivial_selected_assertion' in issue_ids and 'trivial_assertion' not in issue_ids:
  issues.append(_issue('trivial_assertion','The harness contains a trivial assertion that cannot establish the selected property.')); issue_ids.add('trivial_assertion')
 if issue_ids & {'target_function_call_absent','target_call_marker_absent','target_call_marker_misplaced','target_marker_identity_mismatch'} and 'target_call_missing_or_irrelevant' not in issue_ids:
  issues.append(_issue('target_call_missing_or_irrelevant','The exact target call or its identity binding is absent or invalid.'))
 selected=plan.get('selected_property') if isinstance(plan.get('selected_property'),Mapping) else {}; prop=selected.get('property') if isinstance(selected.get('property'),Mapping) else {}
 obligation=str(prop.get('proof_obligation_kind') or '').lower(); safety_only=obligation in {'safety','array_bounds','memory_safety'} or 'bounds' in obligation
 equality=any('==' in m.group('expr') and '!=' not in m.group('expr') for m in re.finditer(r"__CPROVER_assert\s*\((?P<expr>[^,;]+)",harness_text,re.S))
 old_plan=plan.get('old_state_snapshot_plan') if isinstance(plan.get('old_state_snapshot_plan'),Mapping) else {}
 if safety_only and (equality or str(old_plan.get('required') or '') in {'required_for_selected_property','partial_for_selected_property'}) and 'selected_property_scope_drift' not in issue_ids:
  issues.append(_issue('selected_property_scope_drift','A safety-only property contains an unselected functional equality or old-state obligation.'))
