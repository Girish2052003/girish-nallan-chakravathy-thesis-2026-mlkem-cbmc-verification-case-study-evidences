# Complete 26-Property + Native-Contract Superseding Release

This is the cumulative superseding release for the controlled 11-stage ML-KEM/CBMC workflow. It preserves every verified guarantee of the hash-approved predecessor and adds explicit P01-P26 campaign routing plus native CBMC loop/function-contract execution profiles.

## Release identity

```text
Release: PIPELINE_COMPLETE_26_PROPERTY_NATIVE_CONTRACTS_FINAL_2026-07-10
Predecessor SHA-256: 17cbc5bb9d30c960513bde4688ae18146a731b9aa43b5bb7c6df308302bffdf6
Relationship: new superseding package; predecessor remains untouched
```

## Approval boundary

- **Approved now:** install into a new Ubuntu test workspace and run the complete local release verification.
- **Approved after local preflight passes:** one cost-controlled real API experiment with `max_iterations = 0`.
- **Not pre-approved:** any claim that an LLM artefact is correct, that CBMC proves full ML-KEM correctness, or that a successful run establishes FIPS compliance or cryptographic security.

## Final architecture

| Agent | Role |
|---|---|
| 1 Master Orchestrator | Deterministic control and provenance |
| 2 Specification Extraction | LLM-authoritative candidate JSON |
| 3 Code Understanding | LLM-authoritative candidate JSON |
| 4 Property Discovery | LLM-authoritative candidate JSON |
| 5 Formal Artefact Generation | LLM plan/code candidate; Python rendering and validation |
| 6 Review/Critic | LLM review plus deterministic fail-closed gate |
| 7 Formal Tool Execution | Deterministic CBMC execution |
| 8 Counterexample/Tool-Result Analysis | LLM analysis of every completed tool result |
| 9 Repair/Refinement | LLM repair plan; controlled Python application |
| 10 Experiment Logger | Deterministic evidence/provenance logger |
| 11 Evaluation Reporter | Deterministic facts plus separated LLM interpretation |

The LLM is a candidate reasoning component, not a proof engine. CBMC evidence is scoped to the exact harness, assumptions, source/build inputs and options. Human review remains the final scientific judgement.

## Package contents

```text
agents/
  master_orchestrator.py
  spec_extraction_agent.py
  code_understanding_agent.py
  property_discovery_agent.py
  artifact_generation_agent.py
  review_critic_agent.py
  tool_execution_agent.py
  counterexample_analysis_agent.py
  repair_agent.py
  experiment_logger.py
  evaluation_reporter.py
  common/
    config_contract.py
    evidence_contract.py
    formal_build.py
    llm_client.py
    prompt_templates.py
    run_layout.py
    schemas.py
    property_catalog.py
    property_campaign.py
    contract_artifacts.py
configs/
  CONFIG_TEMPLATE_CANONICAL.json
  CONFIG_TEMPLATE_FIRST_API_PREFLIGHT.json
  CONFIG_TEMPLATE_26_PROPERTY_CAMPAIGN.json
  property_campaigns/P01_...json through P26_...json
docs/
  BLOCKER_RESOLUTION_MATRIX.md
  FINAL_ARCHITECTURE_CONFORMANCE_REPORT.md
  FIRST_API_EXPERIMENT_READINESS.md
  VERIFICATION_EVIDENCE.md
  EIGHT_SESSION_DOCUMENT_TO_CODE_VERIFICATION.md
  EIGHT_SESSION_QA_COMPLIANCE_MATRIX.csv
  EIGHT_SESSION_QA_VERIFICATION_SUMMARY.json
tests/
property_campaign_cli.py
README_COMPLETE_26_PROPERTY_RELEASE.md
bootstrap_ubuntu.sh
preflight_first_api.py
requirements.txt
verify_release.sh
PACKAGE_MANIFEST.sha256
```

## Safe Ubuntu installation

Do not overwrite the live thesis project first.

```bash
cd ~
mv thesis-agent-workflow-refactored-test \
   "thesis-agent-workflow-refactored-test.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
mkdir thesis-agent-workflow-refactored-test
cd thesis-agent-workflow-refactored-test
```

Extract the ZIP so this directory contains `agents/`, `configs/`, `bootstrap_ubuntu.sh`, and the other package files.

Then run:

```bash
chmod +x bootstrap_ubuntu.sh verify_release.sh
./bootstrap_ubuntu.sh
```

Required ending:

```text
FINAL DEPLOYMENT GATE PASSED
FINAL DEPLOYMENT VERIFICATION PASSED
BOOTSTRAP AND LOCAL RELEASE VERIFICATION PASSED
```

The bootstrap creates `.venv`, installs the pinned packages from `requirements.txt`, checks all package checksums, compiles the source, opens every agent CLI, runs the cumulative integration suite, and runs the final deployment gate.

## Complete property-campaign extension

This superseding release supports all twenty-six thesis property families through explicit strategy profiles: standard bounded CBMC, relational/two-call harnesses, native loop contracts, native function contracts including optional DFCC, hybrid profiles, and analysis-only constant-time support. “Support” means the workflow can create, validate, review, execute when applicable, diagnose, repair and report the correct artefact class. It does not guarantee automatic proof success.

Inspect the catalogue with:

```bash
source .venv/bin/activate
python property_campaign_cli.py list
python property_campaign_cli.py show P12
```

See `README_COMPLETE_26_PROPERTY_RELEASE.md`, `docs/COMPLETE_26_PROPERTY_CAMPAIGN_GUIDE.md`, and `docs/NATIVE_CBMC_CONTRACTS_GUIDE.md`.

## Before the first API experiment

Read `docs/FIRST_API_EXPERIMENT_READINESS.md`.

Copy the real-run template:

```bash
cp configs/CONFIG_TEMPLATE_FIRST_API_PREFLIGHT.json configs/poly_add_api_run_001.json
```

Replace every `SET_TO_...` placeholder with actual mlkem-native repository/source/include paths, an exact commit/tag, and a model available to the university API project.

Export the key only through the environment:

```bash
export OPENAI_API_KEY='...'
```

Run the fail-closed preflight:

```bash
python preflight_first_api.py --config configs/poly_add_api_run_001.json
```

Only when it ends with `OPERATIONAL PREFLIGHT PASSED`, run:

```bash
python agents/master_orchestrator.py --config configs/poly_add_api_run_001.json
```

## Exit codes

- `0`: the formal tool reported success for the selected recorded properties under the exact saved model/configuration.
- `2`: completed but blocked, failed, unresolved, mock/dry, or no selected-property success.
- `1`: orchestration/infrastructure failure.

## Reproducibility and safety highlights

- Strict stage schemas.
- Exact redacted API request/response snapshots for every attempt and retry.
- Raw primary evidence, prior authoritative outputs, deterministic facts and advisory hints transmitted as separate categories.
- API secrets redacted from logs.
- One canonical physical location per stage output; pointer-only handoffs.
- Anti-copy similarity auditing and critic blocking.
- Exact reviewed artefact checksum bound to Agent 7 execution.
- Structured source/include/define/stub/working-directory CBMC build plan.
- Immutable iteration evidence.
- Failed or manually continued runs marked invalid and blocked from normal thesis-result wording.
- Frozen Agent 11 fields: `measured_facts`, `llm_interpretation`, `limitations`, `threats_to_validity`, and `human_review_required`.
- Structured disagreement recording for every reasoning-stage schema.
- Iteration-level latest manifests implemented as true pointers rather than duplicate JSON copies.
- Agent 10/11 planning-name aliases point to the same canonical physical outputs (`file_index`, `checksums`, and `final_report`).
- Planned stage records, existing stage manifests, and missing stage manifests are reported as separate counts.
- Mock/non-API Agent 11 narratives are wiring-only and are never marked as promoted scientific interpretation.
- Scientific-result reporting eligibility requires real API-backed evidence; unqualified success wording is always disabled.

See `docs/EIGHT_SESSION_DOCUMENT_TO_CODE_VERIFICATION.md` for the final document-first audit and `docs/FINAL_ARCHITECTURE_CONFORMANCE_REPORT.md` for the broader deployment verdict.

## Formal-tool provenance

Agent 7 records resolved paths and version output for `cbmc`, `goto-cc`, and `goto-instrument`, together with every command and intermediate-model checksum.
