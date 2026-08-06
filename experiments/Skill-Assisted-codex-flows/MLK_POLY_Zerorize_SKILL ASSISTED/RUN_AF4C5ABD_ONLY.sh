#!/usr/bin/env bash
set -Eeuo pipefail
PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="${1:-$HOME/THESIS-2026/mlkem-native}"
COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
TREE="54805daff6a91a010c05467ea678117c42a71559"
RUN_DIR="$PACKAGE_ROOT/evidence/run_1"
FINAL_ZIP="$HOME/Downloads/MLK_POLY_Zerorize_SKILL_ASSISTED_EXECUTED_AF4C5ABD_RUN1.zip"
LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT

[ -d "$REPO/.git" ] || { echo "ERROR: repository not found: $REPO" >&2; exit 2; }
[ ! -e "$RUN_DIR" ] || { echo 'ERROR: evidence/run_1 already exists; no second run permitted.' >&2; exit 2; }
STATUS="$(git -C "$REPO" status --porcelain=v1)"
[ -z "$STATUS" ] || { echo 'ERROR: repository changes or untracked files exist; refusing checkout.' >&2; git -C "$REPO" status --short; exit 3; }

if ! git -C "$REPO" cat-file -e "$COMMIT^{commit}" 2>/dev/null; then
  git -C "$REPO" fetch --no-tags origin
fi
git -C "$REPO" cat-file -e "$COMMIT^{commit}"
git -C "$REPO" checkout --detach "$COMMIT"
[ "$(git -C "$REPO" rev-parse HEAD)" = "$COMMIT" ]
[ "$(git -C "$REPO" rev-parse 'HEAD^{tree}')" = "$TREE" ]
[ -z "$(git -C "$REPO" status --porcelain=v1)" ]

set +e
(
  cd "$REPO"
  bash "$PACKAGE_ROOT/runner/run_skill_assisted_campaign.sh"
) 2>&1 | tee "$LOG"
RC=${PIPESTATUS[0]}
set -e
[ "$RC" -eq 0 ] || exit "$RC"

cp "$LOG" "$RUN_DIR/EXECUTION_TERMINAL.log"
printf '%s
' "git checkout --detach $COMMIT" > "$RUN_DIR/source_checkout_command.txt"
[ -z "$(git -C "$REPO" status --porcelain=v1)" ] || { echo 'ERROR: repository changed during proof.' >&2; exit 21; }
(
  cd "$RUN_DIR"
  find . -type f ! -name RUN_MANIFEST.sha256 -print0 | sort -z | xargs -0 sha256sum > RUN_MANIFEST.sha256
  sha256sum -c RUN_MANIFEST.sha256 >/dev/null
)

python3 - "$RUN_DIR/final_status.json" <<'PY_STATUS'
import json,sys
x=json.load(open(sys.argv[1],encoding='utf-8'))
expected={
'authoritative_commit':'af4c5abdd5958bdc65a03cd5ee86708264f93304',
'authoritative_tree':'54805daff6a91a010c05467ea678117c42a71559',
'Selected-claim mapping':'YES','Target reachability':'YES',
'Assertion reachability':'YES','Assumption feasibility':'YES',
'Evidence completeness':'COMPLETE','Repository distinctness':'SUPPORTED',
'Contamination':'NONE KNOWN',
'overall_verdict':'PASS_COMPLETE_SKILL_ASSISTED_MLK_ZEROIZE_AF4C5ABD_CORPUS'}
for key,value in expected.items():
    assert x.get(key)==value,(key,x.get(key),value)
for theorem in ('SA_ZERO_T1','SA_ZERO_T2'):
    t=x['theorems'][theorem]
    for key,value in {'proof':'PASS','body_binding':'PASS','expected_failure_control':'PASS','selected_claim_mapping':'YES','target_reachability':'YES','assertion_reachability':'YES','assumption_feasibility':'YES'}.items():
        assert t.get(key)==value,(theorem,key,t.get(key),value)
print('FINAL_STATUS_VALIDATION=PASS')
PY_STATUS

(
  cd "$PACKAGE_ROOT"
  find . -type f ! -path './manifests/FINAL_EXECUTED_MANIFEST.sha256' -print0 | sort -z | xargs -0 sha256sum > manifests/FINAL_EXECUTED_MANIFEST.sha256
  sha256sum -c manifests/FINAL_EXECUTED_MANIFEST.sha256 >/dev/null
)
rm -f "$FINAL_ZIP" "$FINAL_ZIP.sha256"
(cd "$(dirname "$PACKAGE_ROOT")" && zip -r -X -9 "$FINAL_ZIP" "$(basename "$PACKAGE_ROOT")" >/dev/null)
unzip -t "$FINAL_ZIP" >/dev/null
sha256sum "$FINAL_ZIP" | tee "$FINAL_ZIP.sha256"
echo "AUTHORITATIVE_COMMIT=$COMMIT"
echo "AUTHORITATIVE_TREE=$TREE"
echo "FINAL_EXECUTED_PACKAGE=$FINAL_ZIP"
echo MLK_ZEROIZE_AF4C5ABD_RUN1_COMPLETE
