#!/usr/bin/env python3
from __future__ import annotations
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.counterexample_analysis_agent import classify_readiness_failure,classify_failure_mode
from agents.common.tool_result_contract import CONTRACT_BUILD_FAILED

cases=[
 ({'classification':'hard_frontend_parse_or_build_defect','stderr':"syntax error before '.' [0 .. N] PARSING ERROR",'selected_claim_generated':False},
  {'frontend_parser_error','unsupported_or_invented_syntax','selected_claim_generation_or_mapping_failure'}),
 ({'classification':'hard_transformation_readiness_defect','stderr':'goto-instrument --enforce-contract failed'},
  {'goto_transformation_failure'}),
 ({'classification':'hard_frontend_tool_unavailable','stderr':'goto-cc not found'},
  {'capability_or_tool_unavailable'}),
 ({'classification':'hard_frontend_parse_or_build_defect','stderr':'failed to open missing header include/x.h'},
  {'missing_source_or_include'}),
]
for record,expected in cases:
 result=classify_readiness_failure(record)
 assert expected<=set(result['failure_categories']),(record,result)
 assert result['formal_property_evaluated'] is False and result['cbmc_solving_attempted'] is False

synthetic={
 'result_classification':CONTRACT_BUILD_FAILED,'selected_claim_result':'not_generated',
 'auxiliary_property_result':'unknown','overall_model_result':'incomplete',
 'readiness_failure_before_agent7':True,
}
classification=classify_failure_mode(synthetic,'',"syntax error before '.' PARSING ERROR",None)
assert classification['canonical_result_valid'] is True,classification
assert classification['semantic_outcome']=='tool_or_build_failure'
assert classification['no_formal_tool_result'] is False  # real frontend evidence exists, but no solver result
assert 'possible_harness_syntax_or_compile_error' in classification['failure_categories']
assert classification['selected_claim_result']=='not_generated'
print('PRE-AGENT7 READINESS DIAGNOSIS: PASS')
