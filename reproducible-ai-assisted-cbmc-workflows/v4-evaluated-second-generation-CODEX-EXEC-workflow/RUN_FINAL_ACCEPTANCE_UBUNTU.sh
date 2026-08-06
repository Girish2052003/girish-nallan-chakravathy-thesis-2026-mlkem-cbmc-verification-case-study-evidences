#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
PYTHON_BIN="${PYTHON_BIN:-$ROOT/../venv/bin/python}"
if [[ ! -x "$PYTHON_BIN" ]]; then
  PYTHON_BIN="${PYTHON:-python3}"
fi
OUT="${FINAL_ACCEPTANCE_OUTPUT:-$ROOT/reports/FINAL_TRUST_CHAIN_ACCEPTANCE_$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$OUT"
exec "$PYTHON_BIN" scripts/run_final_trust_chain_acceptance.py \
  --root "$ROOT" \
  --python "$PYTHON_BIN" \
  --timeout-seconds "${FINAL_TEST_TIMEOUT_SECONDS:-600}" \
  --output-dir "$OUT"
