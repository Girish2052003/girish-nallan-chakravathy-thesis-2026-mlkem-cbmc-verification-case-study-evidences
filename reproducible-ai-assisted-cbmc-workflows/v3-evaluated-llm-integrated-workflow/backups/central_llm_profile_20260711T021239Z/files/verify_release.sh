#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
PYTHON_BIN="${PYTHON_BIN:-python3}"
export PYTHONDONTWRITEBYTECODE=1

printf '[1/10] Verifying package checksums...\n'
sha256sum -c PACKAGE_MANIFEST.sha256

printf '[2/10] Compiling Python files...\n'
"$PYTHON_BIN" -m compileall -q agents tests preflight_first_api.py property_campaign_cli.py

printf '[3/10] Checking every production CLI...\n'
for file in agents/*.py; do
  "$PYTHON_BIN" "$file" --help >/dev/null
  printf '  PASS %s\n' "$file"
done
"$PYTHON_BIN" property_campaign_cli.py --help >/dev/null
"$PYTHON_BIN" preflight_first_api.py --help >/dev/null
printf '  PASS property_campaign_cli.py\n'
printf '  PASS preflight_first_api.py\n'

printf '[4/10] Running strict-schema and canonical-configuration regressions...\n'
"$PYTHON_BIN" tests/verify_blocker1_schemas.py
"$PYTHON_BIN" tests/verify_blocker2_config_contract.py

printf '[5/10] Running cumulative orchestrator/repair regressions...\n'
"$PYTHON_BIN" tests/verify_blockers3_to_8.py

printf '[6/10] Running frozen eight-session architecture and deployment gates...\n'
"$PYTHON_BIN" tests/verify_eight_session_conformance.py
"$PYTHON_BIN" tests/verify_deployment_gate.py

printf '[7/10] Running the 26-property catalogue/native-tool profile suite...\n'
"$PYTHON_BIN" tests/verify_26_property_contract_extension.py

printf '[8/10] Running contract-aware repair and claim-boundary suite...\n'
"$PYTHON_BIN" tests/verify_26_property_repair_and_claim_boundaries.py

printf '[9/10] Running property-campaign orchestrator routing tests...\n'
"$PYTHON_BIN" tests/verify_property_campaign_orchestration.py

printf '[10/10] Checking catalogue CLI and campaign-fragment completeness...\n'
"$PYTHON_BIN" property_campaign_cli.py list >/dev/null
fragment_count="$(find configs/property_campaigns -maxdepth 1 -type f -name 'P??_*.json' | wc -l | tr -d ' ')"
if [[ "$fragment_count" != "26" ]]; then
  printf 'Expected 26 property-campaign fragments, found %s\n' "$fragment_count" >&2
  exit 1
fi
printf '  PASS 26 property families and 26 configuration fragments\n'

printf '\nCOMPLETE 26-PROPERTY + NATIVE-CONTRACT RELEASE VERIFICATION PASSED\n'
