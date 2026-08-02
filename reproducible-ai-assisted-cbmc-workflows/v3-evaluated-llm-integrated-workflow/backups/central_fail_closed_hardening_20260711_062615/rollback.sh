#!/usr/bin/env bash
set -euo pipefail
ROOT="/home/girish/thesis-agent-workflow-26-property-test"
BACKUP="/home/girish/thesis-agent-workflow-26-property-test/backups/central_fail_closed_hardening_20260711_062615"
(cd "$BACKUP/originals" && find . -type f -print0) | while IFS= read -r -d '' rel; do
  mkdir -p "$ROOT/$(dirname "$rel")"
  cp -a "$BACKUP/originals/$rel" "$ROOT/$rel"
done
rm -f "$ROOT/tests/verify_central_fail_closed_hardening.py"
echo "Rollback completed from $BACKUP"
