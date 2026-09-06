#!/usr/bin/env bash
# A failed day is not a lost day. Park the work where tomorrow can repair it,
# and never let a broken item block the roadmap forever.
set -uo pipefail
BRANCH="${DAILY_BRANCH:?}"
ATTEMPT="${DAILY_ATTEMPT:-1}"
LOG="${GATE_LOG:-/dev/null}"
RUN_URL="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-}"
item=$(sed -n 's/^item:[[:space:]]*//p' "${DAILY_SUMMARY:-/dev/null}" 2>/dev/null | head -1 | tr -d '"'"'"'\r')
item="${item:-unknown}"
tail_log=$(tail -60 "$LOG" 2>/dev/null || echo "no gate log produced")

git add -A
if git diff --cached --quiet; then
  echo "Nothing to park; the agent produced no changes."
  exit 0
fi

if [ "$ATTEMPT" -ge 2 ]; then
  # Second failure on the same item. Stop trying, record it, move on tomorrow.
  git reset -q
  git checkout -q main
  git pull -q --rebase origin main
  python3 - "$item" "$RUN_URL" <<'PY'
import sys, re, pathlib
item, run = sys.argv[1], sys.argv[2]
p = pathlib.Path("ROADMAP.md"); t = p.read_text()
line = next((l for l in t.splitlines() if item in l and "- [ ]" in l), None)
if line:
    t = t.replace(line + "\n", "")
    entry = f"{line.strip()}\n  Parked twice, see {run}\n"
    t = t.rstrip("\n") + "\n" + ("" if "## Blocked" in t else "\n## Blocked\n") + entry
    p.write_text(t)
PY
  git add ROADMAP.md
  git commit -q -m "chore(roadmap): move $item to Blocked after two failed attempts

The daily loop attempted this item twice and the gate failed both times.
Moved to Blocked so tomorrow can continue. See $RUN_URL

Co-Authored-By: Claude <noreply@anthropic.com>" || true
  git push -q origin main || true
  gh pr close "${DAILY_PR:-0}" --delete-branch >/dev/null 2>&1 || true
  echo "Item $item blocked after two attempts."
  exit 1
fi

git commit -q -m "wip($item): parked, gate failed

Automated work in progress. The gate did not pass, so this was not merged.
Tomorrow's run will attempt a repair on this branch. See $RUN_URL

Co-Authored-By: Claude <noreply@anthropic.com>"
git push -q -u origin "$BRANCH"

pr="${DAILY_PR:-}"
if [ -z "$pr" ]; then
  pr=$(gh pr create --draft --label daily-wip --base main --head "$BRANCH" \
       --title "wip($item): parked, gate failed" \
       --body "The daily run could not get this item green. Tomorrow's run repairs this branch. If it fails again the item moves to Blocked." \
       | grep -oE '[0-9]+$')
fi
gh pr comment "$pr" --body "$(printf 'Gate failed in [this run](%s).\n\n```\n%s\n```\n' "$RUN_URL" "$tail_log")" >/dev/null
echo "Parked $item on $BRANCH as draft PR #$pr"
exit 1
