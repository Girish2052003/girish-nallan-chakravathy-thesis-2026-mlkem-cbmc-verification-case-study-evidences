#!/usr/bin/env python3
from __future__ import annotations
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.common.experiment_protocol import build_experiment_protocol, validate_experiment_protocol
from agents.master_orchestrator import MasterOrchestrator

base={
 'max_iterations':3,
 'property_discovery':{'mode':'open_discovery'},
 'property_campaign':{'property_family_id':'UNMAPPED','verification_strategy':'UNSELECTED'},
 'experiment_protocol':{
  'repair_policy':'bounded_repair',
  'repair_retry_controls':{
   'tool_diagnostic_repair':{'enabled':True,'max_repairs':2},
   'semantic_repair':{'enabled':False},
  },
 },
 'llm':{'model':'test'},
}
protocol=build_experiment_protocol(base)
assert protocol['repair_retry_controls']=={
 'tool_diagnostic_repair':{'enabled':True,'max_repairs':2},
 'semantic_repair':{'enabled':False,'max_repairs':0},
},protocol
config=dict(base); config['experiment_protocol']=protocol
assert validate_experiment_protocol(config)==(),validate_experiment_protocol(config)

# The two categories consume independent budgets and record the exact source.
obj=MasterOrchestrator.__new__(MasterOrchestrator)
obj.repair_retry_controls=protocol['repair_retry_controls']
obj.repair_retry_counts={'tool_diagnostic_repair':0,'semantic_repair':0}
events=[]
obj.log_event=lambda event,data: events.append((event,data))
allowed,reason=obj._repair_category_allowed('tool_diagnostic_repair')
assert allowed and reason.endswith('0/2'),reason
obj._consume_repair_category('tool_diagnostic_repair',source='agent6_frontend',iteration=0)
obj._consume_repair_category('tool_diagnostic_repair',source='agent7_auxiliary',iteration=1)
allowed,reason=obj._repair_category_allowed('tool_diagnostic_repair')
assert not allowed and reason=='tool_diagnostic_repair_limit_reached:2/2',reason
allowed,reason=obj._repair_category_allowed('semantic_repair')
assert not allowed and reason=='semantic_repair_disabled_by_experiment_protocol',reason
assert [row[1]['source'] for row in events]==['agent6_frontend','agent7_auxiliary']
assert all(row[1]['category']=='tool_diagnostic_repair' for row in events)

# Objective readiness failures and semantic fidelity failures never share a category.
for gate in ('blocked_invalid_artifact','blocked_frontend_readiness_defect','blocked_transformation_readiness_defect','blocked_missing_selected_claim'):
 assert obj._critic_repair_category(gate)=='tool_diagnostic_repair'
assert obj._critic_repair_category('blocked_semantic_fidelity_defect')=='semantic_repair'

# Agent 7 result routing preserves a passing selected claim and scopes repair to auxiliaries.
obj.tool_status=lambda:{'selected_claim_result':'passed','auxiliary_property_result':'failed'}
assert obj._tool_repair_category()=='tool_diagnostic_repair'
obj.tool_status=lambda:{'selected_claim_result':'failed','auxiliary_property_result':'passed'}
assert obj._tool_repair_category()=='semantic_repair'

# A user may invert the controls without hidden defaults.
other=dict(base)
other['experiment_protocol']={
 'repair_policy':'bounded_repair',
 'repair_retry_controls':{
  'tool_diagnostic_repair':{'enabled':False},
  'semantic_repair':{'enabled':True,'max_repairs':3},
 },
}
p2=build_experiment_protocol(other)
assert p2['repair_retry_controls']['tool_diagnostic_repair']=={'enabled':False,'max_repairs':0}
assert p2['repair_retry_controls']['semantic_repair']=={'enabled':True,'max_repairs':3}
print('EXPLICIT REPAIR RETRY CONTROLS: PASS')
