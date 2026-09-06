#!/usr/bin/env bash
# Decide whether today repairs yesterday's parked work or starts something new.
set -euo pipefail
FORCED="${1:-}"
out="${GITHUB_OUTPUT:-/dev/stdout}"

wip=$(gh pr list --state open --label daily-wip --json number,headRefName --jq '.[0] // empty')
if [ -n "$wip" ]; then
  branch=$(echo "$wip" | jq -r .headRefName)
  num=$(echo "$wip" | jq -r .number)
  git fetch origin "$branch"
  git checkout "$branch"
  echo "mode=repair"   >> "$out"
  echo "branch=$branch" >> "$out"
  echo "attempt=2"      >> "$out"
  echo "pr=$num"        >> "$out"
  echo "Repair mode on $branch, reopening PR #$num"
else
  branch="daily/$(date -u +%Y-%m-%d)"
  git checkout -b "$branch" 2>/dev/null || git checkout "$branch"
  echo "mode=new"       >> "$out"
  echo "branch=$branch" >> "$out"
  echo "attempt=1"      >> "$out"
  echo "pr="            >> "$out"
  echo "New work on $branch"
fi
[ -n "$FORCED" ] && echo "Forced item: $FORCED"
exit 0
