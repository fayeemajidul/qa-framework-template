#!/usr/bin/env bash
# Turn a passing day into a commit on main, authored by the human, through a
# reviewable pull request rather than a direct push.
set -euo pipefail
SUMMARY="${DAILY_SUMMARY:?}"
BRANCH="${DAILY_BRANCH:?}"
RUN_URL="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-}"

item=$(sed -n 's/^item:[[:space:]]*//p'  "$SUMMARY" | head -1 | tr -d '"'"'"'\r')
title=$(sed -n 's/^title:[[:space:]]*//p' "$SUMMARY" | head -1 | sed 's/^"//;s/"$//' | tr -d '\r')
body=$(sed '1,/^---$/d;1,/^---$/d' "$SUMMARY")

msg=$(printf '%s\n\n%s\n\nRoadmap-Item: %s\nAgent-Run: %s\n\nCo-Authored-By: Claude <noreply@anthropic.com>\n' \
      "$title" "$body" "$item" "$RUN_URL")

git add -A
git commit -q -m "$msg"
git push -q -u origin "$BRANCH"

if [ -n "${DAILY_PR:-}" ]; then
  pr="$DAILY_PR"
  gh pr edit "$pr" --title "$title" --remove-label daily-wip --add-label daily >/dev/null
  gh pr ready "$pr" >/dev/null 2>&1 || true
else
  pr=$(gh pr create --title "$title" --label daily --base main --head "$BRANCH" \
       --body "$(printf '%s\n\n---\nGate passed in [this run](%s).\nRoadmap item: `%s`\n\nOpened and merged automatically. See `docs/HOW_THIS_REPO_IS_BUILT.md`.\n' "$body" "$RUN_URL" "$item")" \
       | grep -oE '[0-9]+$')
fi

gh pr merge "$pr" --rebase --delete-branch
echo "Landed $item as PR #$pr"
