#!/usr/bin/env bash
# A red badge on a public portfolio is worse than a missed feature. Three red
# nights opens an issue, and tomorrow's daily run must fix it before anything new.
set -euo pipefail
OUTCOME="${1:-unknown}"
open=$(gh issue list --state open --label regression-red --json number --jq '.[0].number // empty')

if [ "$OUTCOME" = "success" ]; then
  [ -n "$open" ] && gh issue close "$open" --comment "Nightly is green again. Closing." >/dev/null && echo "Closed #$open"
  exit 0
fi

reds=$(gh run list --workflow nightly.yml --limit 3 --json conclusion \
       --jq '[.[]|select(.conclusion=="failure")]|length' 2>/dev/null || echo 0)
if [ "$reds" -ge 3 ] && [ -z "$open" ]; then
  gh issue create --label regression-red \
    --title "Nightly regression has been red for three nights" \
    --body "The nightly suite has failed three runs in a row. Tomorrow's daily run must fix this before starting any new roadmap item. Classify it first: a product bug on the target site, a defect in the test, or an environment problem." >/dev/null
  echo "Opened regression-red issue"
fi
