#!/usr/bin/env python3
from __future__ import annotations
import copy,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.common.semantic_property import normalize_semantic_property,possible_encodings,select_encoding,compare_semantic_properties

semantic=normalize_semantic_property({
 'schema_version':'semantic_property.v2','property_id':'PSEM','statement':'Input remains unchanged after target.',
 'target_call':{'function':'target','arguments':['&out','&in'],'call_count':1},
 'pre_state_objects':['in'],'post_state_objects':['in'],'observed_memory':['in.bytes'],
 'permitted_writes':['out.bytes'],'required_assumptions':[],'success_predicate':'in.bytes[i] == old_in.bytes[i]',
 'quantified_domain':{'variable':'i','lower_bound':'0','upper_bound_exclusive':'N'},
 'requires_pre_state_snapshot':True,'requires_modular_call_replacement':False,
 'requires_loop_reasoning':False,'requires_relational_execution':False,'analysis_only':False,
 'evidence_references':['source:target'],'uncertainty':'none',
},target_function='target')
assert semantic['semantic_completeness']['complete'] is True,semantic
opts={row['strategy']:row for row in possible_encodings(semantic)}
assert opts['standard_cbmc_harness']['expressible'] is True
assert opts['native_function_contract']['expressible'] is True
assert opts['hybrid_contract_and_harness']['expressible'] is True
# Same property, three explicit encodings; no keyword decides the route.
for strategy in ('standard_cbmc_harness','native_function_contract','hybrid_contract_and_harness'):
 selected=select_encoding(semantic,requested_strategy=strategy)
 assert selected['selected_strategy']==strategy
 assert selected['selection_authority']=='explicit_user_or_agent5_request'
assert select_encoding(semantic,requested_strategy=None,preference='harness_when_complete')['selected_strategy']=='standard_cbmc_harness'
assert select_encoding(semantic,requested_strategy=None,preference='contract_preferred')['selected_strategy']=='native_function_contract'

# Normalization is idempotent across Agent 4 -> 5 -> 6 -> 9 handoffs.
assert normalize_semantic_property(semantic,target_function='target')==semantic

# Exact same property is not a weakening.
same=compare_semantic_properties(semantic,copy.deepcopy(semantic),target_function='target')
assert same['same_semantic_property'] is True and same['potential_weakening'] is False

# Added assumptions, reduced observation, changed predicate, or changed call are surfaced structurally.
weaker=copy.deepcopy(semantic)
weaker['required_assumptions']=['in.bytes[0] == 0']
weaker['observed_memory']=[]
weaker['success_predicate']='1'
weaker['target_call']={'function':'other','arguments':[],'call_count':1}
diff=compare_semantic_properties(semantic,weaker,target_function='target')
assert diff['same_semantic_property'] is False and diff['potential_weakening'] is True,diff
reasons=set(diff['weakening_reasons'])
assert {'repaired_property_adds_assumptions','repaired_property_observes_less_memory','success_predicate_changed_requires_human_strength_review','target_call_changed'}<=reasons

# A contract-dependent modular claim cannot be silently encoded as a plain harness.
modular=copy.deepcopy(semantic); modular['requires_modular_call_replacement']=True
options={row['strategy']:row for row in possible_encodings(modular)}
assert options['native_function_contract']['required'] is True
try: select_encoding(modular,requested_strategy='standard_cbmc_harness')
except ValueError as exc: assert 'not expressible' in str(exc)
else: raise AssertionError('contract-dependent semantic claim silently downgraded to harness')
assert select_encoding(modular,requested_strategy=None,preference='contract_when_required')['selected_strategy']=='native_function_contract'
print('STRATEGY NEUTRALITY + SEMANTIC REPAIR GUARD: PASS')
