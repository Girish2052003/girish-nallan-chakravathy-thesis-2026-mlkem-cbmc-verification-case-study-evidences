#!/usr/bin/env bash
set -euo pipefail

RUN_DIR="${1:-$(find runs -mindepth 1 -maxdepth 1 -type d \
  -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d' ' -f2-)}"

EVENTS="$RUN_DIR/events.jsonl"

echo
echo "Watching: $RUN_DIR"
echo "Press Ctrl+C to stop watching — the experiment will continue."
echo

tail -n 15 -F "$EVENTS" |
jq --unbuffered -r '
  (.timestamp // .timestamp_utc // "") as $time
  |
  if .event_type == "agent_start" then
    "▶️  STARTED   " + (.agent // .stage // "unknown")
  elif .event_type == "agent_finish" then
    "✅ FINISHED  " + (.name // .agent // .stage // "unknown")
    + " — " + (.status // "unknown")
  elif .event_type == "stage_started" then
    "🔄 WORKING   " + (.message // .stage // "unknown")
  elif .event_type == "stage_completed" then
    "✅ COMPLETED " + (.message // .stage // "unknown")
  elif .event_type == "status_update" then
    "📍 STATUS    " + (.status // "unknown")
  else
    empty
  end
'
