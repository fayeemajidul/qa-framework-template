#!/usr/bin/env bash
# Three failures in a row is a second signal beyond the failure emails.
set -euo pipefail
fails=$(gh run list --workflow daily-engineering.yml --limit 3 \
        --json conclusion --jq '[.[]|select(.conclusion=="failure")]|length' 2>/dev/null || echo 0)
if [ "$fails" -ge 3 ]; then
  if [ -z "$(gh issue list --state open --label daily-blocked --json number --jq '.[0]//empty')" ]; then
    gh issue create --label daily-blocked \
      --title "Daily loop has failed three runs in a row" \
      --body "The last three scheduled runs of daily-engineering.yml failed. Something structural is wrong: a broken gate, an expired token, or a target site that changed. Check the newest run log, then close this issue once a run lands green." >/dev/null
    echo "Opened daily-blocked issue"
  fi
fi
exit 0
