#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

python3 - <<'PY'
import sys
if sys.version_info < (3, 10):
    raise SystemExit("Python 3.10 or newer is required.")
print(f"Python {sys.version.split()[0]} detected")
PY

if [[ ! -d .venv ]]; then
  python3 -m venv .venv
fi

"$ROOT/.venv/bin/python" -m pip install --upgrade pip
"$ROOT/.venv/bin/python" -m pip install -r requirements.txt

PYTHON_BIN="$ROOT/.venv/bin/python" "$ROOT/verify_release.sh"

printf '\nBOOTSTRAP AND LOCAL RELEASE VERIFICATION PASSED\n'
