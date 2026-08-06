#!/usr/bin/env python3
from __future__ import annotations
import json, os, sys, tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
import agents.common.llm_client as lc
from agents.common.llm_client import LLMClient, LLMClientConfig, LLMStageRequest

class Layout:
    def __init__(self, root:Path): self.run_dir=root
    def prompt_package_dir(self,stage):
        p=self.run_dir/stage/'prompt_package'; p.mkdir(parents=True,exist_ok=True); return p
    def llm_authoritative_dir(self,stage):
        p=self.run_dir/stage/'llm_authoritative'; p.mkdir(parents=True,exist_ok=True); return p
    def write_prompt_package(self,stage,**kwargs):
        p=self.prompt_package_dir(stage)/'prompt.txt'; p.write_text(str(kwargs.get('prompt_text') or ''))
        m=self.prompt_package_dir(stage)/'metadata.json'; m.write_text(json.dumps(kwargs.get('extra_metadata') or {}))
        return {'prompt':p,'prompt_metadata':m}
    def write_validation_json(self,stage,name,value):
        p=self.run_dir/stage/'validation'/name; p.parent.mkdir(parents=True,exist_ok=True); p.write_text(json.dumps(value,indent=2)); return p
    def write_llm_authoritative_json(self,stage,name,value):
        p=self.llm_authoritative_dir(stage)/name; p.write_text(json.dumps(value)); return p

class Usage:
    input_tokens=10; output_tokens=5; total_tokens=15
    def model_dump(self): return {'input_tokens':10,'output_tokens':5,'total_tokens':15}
class Response:
    def __init__(self,text,status='completed',reason=''):
        self.output_text=text; self.status=status; self.id='r'; self.usage=Usage()
        self.incomplete_details={'reason':reason} if reason else None
    def model_dump(self): return {'id':self.id,'status':self.status,'output_text':self.output_text,'incomplete_details':self.incomplete_details}

class SequenceOpenAI:
    sequence=[]; calls=0
    def __init__(self,**kwargs): self.responses=self
    def create(self,**kwargs):
        type(self).calls+=1
        item=type(self).sequence.pop(0)
        if isinstance(item,BaseException): raise item
        return item

def run_case(name,sequence,retry_policy,expect_success,expect_calls,expect_category):
    with tempfile.TemporaryDirectory(prefix='retry_category_') as td:
        old_openai=lc.OpenAI; old_key=os.environ.get('OPENAI_API_KEY')
        lc.OpenAI=SequenceOpenAI; SequenceOpenAI.sequence=list(sequence); SequenceOpenAI.calls=0
        os.environ['OPENAI_API_KEY']='sk-test-not-real'
        try:
            cfg=LLMClientConfig.from_mapping({
                'mode':'real','model':'retry-test-model','retry_sleep_seconds':0,
                'max_request_bytes':500000,'max_retry_growth_percent':1000,
                'max_stage_input_tokens_estimate':200000,'max_total_input_tokens_estimate':1000000,
                'retry_policy':retry_policy,
            })
            req=LLMStageRequest(
                stage='02_spec_extraction',prompt_text='Return one strict JSON object.',output_filename='out.json',
                json_schema={'type':'object','properties':{'stage':{'type':'string'}},'required':['stage'],'additionalProperties':False},
            )
            layout=Layout(Path(td)); result=LLMClient(cfg).run_stage(layout,req)
            assert result.success is expect_success,(name,result.error,result.validation)
            assert SequenceOpenAI.calls==expect_calls,(name,SequenceOpenAI.calls)
            validation=json.loads((Path(td)/'02_spec_extraction/validation/llm_call_validation.json').read_text())
            assert validation['retry_policy'][expect_category]['max_retries']==retry_policy[
                {'schema_or_json':'schema','incomplete_response':'incomplete_response','provider_error':'provider_error'}[expect_category]
            ]['max_retries']
            if expect_calls>1:
                assert validation['retry_history'],(name,validation)
                assert validation['retry_history'][0]['category']==expect_category
                snap=json.loads((Path(td)/'02_spec_extraction/prompt_package/api_requests/attempt_02_request.json').read_text())
                assert snap['retry'] is True and snap['retry_category']==expect_category,snap
                assert snap['retry_reason'] and snap['previous_request_size_bytes']>0
                assert snap['request_size_bytes']>0 and isinstance(snap['request_growth_bytes'],int)
                assert snap['api_payload']['model']=='retry-test-model'
                assert len(snap['prompt_sha256'])==64 and len(snap['request_sha256'])==64
            else:
                assert validation['retry_history']==[],(name,validation)
        finally:
            lc.OpenAI=old_openai
            if old_key is None: os.environ.pop('OPENAI_API_KEY',None)
            else: os.environ['OPENAI_API_KEY']=old_key

base={
 'schema':{'enabled':False,'max_retries':0},
 'incomplete_response':{'enabled':False,'max_retries':0},
 'provider_error':{'enabled':False,'max_retries':0},
}
policy=json.loads(json.dumps(base)); policy['incomplete_response']={'enabled':True,'max_retries':1}
run_case('incomplete enabled',[Response('',status='incomplete',reason='max_output_tokens'),Response('{"stage":"ok"}')],policy,True,2,'incomplete_response')
policy=json.loads(json.dumps(base)); policy['schema']={'enabled':True,'max_retries':1}
run_case('schema enabled',[Response('{"wrong":1}'),Response('{"stage":"ok"}')],policy,True,2,'schema_or_json')
policy=json.loads(json.dumps(base)); policy['provider_error']={'enabled':True,'max_retries':1}
run_case('provider enabled',[RuntimeError('temporary provider failure'),Response('{"stage":"ok"}')],policy,True,2,'provider_error')
# Disabled category must never borrow another category's budget.
run_case('provider disabled',[RuntimeError('temporary provider failure'),Response('{"stage":"should-not-run"}')],base,False,1,'provider_error')
print('EXPLICIT LLM RETRY CATEGORIES: PASS')
