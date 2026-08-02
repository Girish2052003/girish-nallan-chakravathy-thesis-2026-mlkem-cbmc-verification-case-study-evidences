# Complete 26-Property + Native CBMC Contracts Release

This package extends the frozen eight-session, hash-approved 17cbc baseline without modifying the historical ZIP. It supports one configurable workflow for all 26 thesis property families and preserves the predecessor's direct-CBMC behaviour for legacy configs.

## Important meaning of support

Support means the workflow can select the property family, collect evidence, ask the LLM for the correct candidate artefact type, validate/review it, run the appropriate deterministic tool profile when applicable, preserve evidence, classify failures and report the scientific boundary. It does **not** guarantee that every candidate compiles or that every property is automatically proved.

## Added files

```text
agents/common/property_catalog.py
agents/common/contract_artifacts.py
property_campaign_cli.py
configs/CONFIG_TEMPLATE_26_PROPERTY_CAMPAIGN.json
configs/property_campaigns/P01_...json through P26_...json
docs/PROPERTY_SUPPORT_MATRIX.md
docs/PROPERTY_SUPPORT_MATRIX.csv
docs/PROPERTY_SUPPORT_CATALOGUE.json
docs/NATIVE_CBMC_CONTRACTS_GUIDE.md
docs/COMPLETE_26_PROPERTY_CAMPAIGN_GUIDE.md
tests/verify_26_property_contract_extension.py
tests/verify_26_property_repair_and_claim_boundaries.py
tests/verify_property_campaign_orchestration.py
```

## Verification

```bash
./bootstrap_ubuntu.sh
```

The release verifier checks every frozen baseline regression, both deep 26-property/native-contract suites, and full orchestrator-level P12 native-loop-contract and P19 analysis-only campaigns. All three extension suites are mandatory release gates.

## Select a property

```bash
source .venv/bin/activate
python property_campaign_cli.py list
python property_campaign_cli.py show P12
```

Copy `configs/CONFIG_TEMPLATE_26_PROPERTY_CAMPAIGN.json`, fill all real input/build/provenance fields, select a P01–P26 family, then run the mandatory preflight.

## Native tools

Native contract strategies require the CBMC distribution tools:

```text
cbmc
goto-cc
goto-instrument
```

The preflight checks them and runs strategy-specific loop-contract and/or function-contract/DFCC transformations. P19 intentionally requires no formal-tool success claim.

## Formal-tool provenance

Agent 7 records resolved paths and version output for `cbmc`, `goto-cc`, and `goto-instrument`, together with every command and intermediate-model checksum.
