#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
VENV_DIR="${VENV_DIR:-$ROOT/../venv}"

python3 - <<'PY'
import sys
if sys.version_info < (3, 10):
    raise SystemExit("Python 3.10 or newer is required.")
print(f"Python {sys.version.split()[0]} detected")
PY

if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi

"$VENV_DIR/bin/python" -m pip install --upgrade pip
"$VENV_DIR/bin/python" -m pip install -r requirements.txt

"$VENV_DIR/bin/python" \
  "$ROOT/scripts/run_regressions.py" \
  --root "$ROOT" \
  --python "$VENV_DIR/bin/python" \
  --output-dir "$ROOT/reports/bootstrap_regressions"

printf '\nBOOTSTRAP AND MUTABLE WORKSPACE REGRESSIONS PASSED\n'
