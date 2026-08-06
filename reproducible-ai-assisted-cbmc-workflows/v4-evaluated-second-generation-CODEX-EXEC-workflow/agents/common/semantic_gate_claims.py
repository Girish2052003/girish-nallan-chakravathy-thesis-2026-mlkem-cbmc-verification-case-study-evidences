"""Exact assumption and selected-claim binding checks for semantic_gate."""
from __future__ import annotations
from typing import Any,Dict,List,Mapping,Sequence
from agents.common.cbmc_capability import normalize_clause_records
from agents.common.exact_traceability import expected_claim_identity
JsonDict=Dict[str,Any]

def _issue(issue_id:str,message:str,*,evidence:JsonDict|None=None,affected_claim_ids:Sequence[str]=())->JsonDict:
 return {'issue_id':issue_id,'severity':'critical','category':'semantic_fidelity','message':message,'blocks_tool_execution':True,'affected_claim_ids':list(affected_claim_ids),'evidence':evidence or {}}
def _dict_list(value:Any)->List[JsonDict]: return [dict(x) for x in value] if isinstance(value,list) else []
def _clause_records(plan:Mapping[str,Any],field:str,kind:str)->List[JsonDict]:
 contract=plan.get('contract_plan') if isinstance(plan.get('contract_plan'),Mapping) else {}
 return normalize_clause_records(contract.get(field),clause_kind=kind)
def _contract_identity_matches(plan:Mapping[str,Any],field:str,kind:str,identity:str)->List[JsonDict]:
 return [r for r in _clause_records(plan,field,kind) if str(r.get('expected_property_identity') or '')==identity]

def validate_assumption_semantics(plan:Mapping[str,Any],assumption_map:Sequence[Mapping[str,Any]],*,analysis_only:bool)->List[JsonDict]:
 issues=[]; plan_assumptions=_dict_list(plan.get('assumption_plan')); mapped={str(r.get('assumption_id') or '') for r in assumption_map}
 for item in plan_assumptions:
  aid=str(item.get('assumption_id') or '')
  if aid and aid not in mapped: issues.append(_issue('assumption_not_mapped',f'Planned assumption {aid} has no traceability mapping.'))
 for row in assumption_map:
  aid=str(row.get('assumption_id') or ''); kind=str(row.get('implementation_kind') or '')
  if kind=='contract_requires' and not _clause_records(plan,'requires_clauses','requires'): issues.append(_issue('contract_assumption_absent',f"Assumption {aid or '<unknown>'} is mapped to contract_requires but no requires clause exists."))
  elif kind=='no_runtime_clause' and not analysis_only: issues.append(_issue('assumption_not_executable',f"Assumption {aid or '<unknown>'} is not represented in the executable model."))
 return issues

def validate_claim_semantics(plan:Mapping[str,Any],claim_map:Sequence[Mapping[str,Any]],exact:Mapping[str,Any],*,property_id:str,analysis_only:bool)->tuple[List[JsonDict],int,int]:
 issues=[]
 plan_ids={str(r.get('assertion_id') or '') for r in _dict_list(plan.get('assertion_plan')) if str(r.get('assertion_id') or '')}
 mapped_ids={str(r.get('assertion_id') or '') for r in claim_map if str(r.get('assertion_id') or '')}
 for cid in sorted(plan_ids-mapped_ids): issues.append(_issue('claim_not_mapped',f'Planned claim {cid} has no exact traceability mapping.',affected_claim_ids=[cid]))
 meaningful=0; contract_field={'contract_ensures':('ensures_clauses','ensures'),'loop_invariant':('loop_invariant_clauses','loop_invariant'),'loop_decreases':('decreases_clauses','decreases')}
 observed=set(); bindings=exact.get('claim_bindings',{}).get('bindings',[])
 for row in claim_map:
  cid=str(row.get('assertion_id') or ''); kind=str(row.get('implementation_kind') or ''); expected=expected_claim_identity(property_id,cid); identity=str(row.get('expected_property_identity') or row.get('code_marker') or '')
  if identity!=expected: issues.append(_issue('claim_identity_mismatch',f"Claim {cid or '<unknown>'} does not use the exact property identity.",evidence={'expected':expected,'observed':identity},affected_claim_ids=[cid]))
  if identity in observed: issues.append(_issue('duplicate_claim_identity',f'Claim identity {identity!r} is duplicated.',affected_claim_ids=[cid]))
  observed.add(identity)
  if kind in {'harness_assertion','relational_assertion'}:
   if any(b.get('identity')==expected for b in bindings): meaningful+=1
  elif kind in contract_field:
   field,clause_kind=contract_field[kind]; matches=_contract_identity_matches(plan,field,clause_kind,expected)
   if len(matches)!=1: issues.append(_issue('contract_claim_binding_invalid',f"Claim {cid or '<unknown>'} must bind to exactly one typed {clause_kind} clause; found {len(matches)}.",affected_claim_ids=[cid]))
   else: meaningful+=1
  elif kind=='cbmc_builtin':
   if not identity: issues.append(_issue('builtin_claim_identity_absent',f'CBMC built-in claim {cid} lacks an exact expected property identity.',affected_claim_ids=[cid]))
   else: meaningful+=1
  elif kind=='analysis_only':
   if not analysis_only: issues.append(_issue('analysis_only_mapping_in_formal_strategy','A formal strategy maps its selected claim as analysis-only.',affected_claim_ids=[cid]))
  else: issues.append(_issue('unknown_claim_implementation',f'Unsupported claim implementation kind {kind!r}.',affected_claim_ids=[cid]))
 expected_count=plan.get('traceability_manifest',{}).get('expected_claim_count'); expected_count=expected_count if isinstance(expected_count,int) and not isinstance(expected_count,bool) else len(claim_map)
 if not analysis_only and expected_count<=0: issues.append(_issue('zero_selected_claims','A formal strategy must declare at least one selected claim.'))
 if expected_count!=len(claim_map): issues.append(_issue('claim_count_mismatch','expected_claim_count does not equal the exact claim-map size.',evidence={'expected_claim_count':expected_count,'claim_map_count':len(claim_map)}))
 if not analysis_only and meaningful!=expected_count: issues.append(_issue('selected_claim_not_fully_implemented','Not every selected claim has exactly one executable encoding.',evidence={'meaningful_mapped_claim_count':meaningful,'expected_claim_count':expected_count}))
 return issues,meaningful,expected_count
