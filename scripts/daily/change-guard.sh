#!/usr/bin/env bash
# The referee. Everything here answers one question: is this a real day of
# engineering, or is it filler? Filler must never reach the public history.
# Exit non zero and the workflow parks the day instead of landing it.
set -uo pipefail

SUMMARY="${DAILY_SUMMARY:?DAILY_SUMMARY not set}"
fail() { echo "BLOCKED: $*" >&2; exit 1; }

# --- 1. There must be a summary, and it must be well formed ------------------
[ -f "$SUMMARY" ] || fail "no summary file at $SUMMARY. The agent did not finish."
item=$(sed -n 's/^item:[[:space:]]*//p'  "$SUMMARY" | head -1 | tr -d '"'"'"'\r')
title=$(sed -n 's/^title:[[:space:]]*//p' "$SUMMARY" | head -1 | sed 's/^"//;s/"$//' | tr -d '\r')
[ -n "$item" ]  || fail "summary has no item id"
[ -n "$title" ] || fail "summary has no title"

# --- 2. The title must be a real Conventional Commit -------------------------
echo "$title" | grep -Eq '^(feat|fix|test|refactor|docs|ci|build|chore|perf)(\([a-z0-9._-]+\))?: .{10,72}$' \
  || fail "title is not a valid Conventional Commit: $title"
echo "$title" | grep -Eqi '^(feat|fix|test|refactor|docs|ci|build|chore|perf)(\([a-z0-9._-]+\))?: (update|fix|changes|stuff|wip|misc)\.?$' \
  && fail "title is too vague to be useful: $title"

# --- 3. There must be a real diff, not whitespace ----------------------------
git add -A
git diff --cached --quiet && fail "nothing changed. A day with no diff is not a day."
# Ignore the roadmap here: flipping a checkbox is always a real change, so
# including it would hide a day whose actual code change was only whitespace.
[ -n "$(git diff --cached -w --stat -- . ':(exclude)ROADMAP.md')" ] \
  || fail "the only real change is the roadmap checkbox. Whitespace and checkbox flips are exactly what a commit farm looks like."

# --- 4. Exactly one roadmap checkbox flipped, and it is this item ------------
flips=$(git diff --cached -U0 -- ROADMAP.md | grep -c '^+.*- \[x\]' || true)
[ "$flips" -eq 1 ] || fail "expected exactly 1 roadmap item to be completed, found $flips"
git diff --cached -U0 -- ROADMAP.md | grep '^+.*- \[x\]' | grep -q -- "$item" \
  || fail "the completed roadmap item does not match the summary item $item"

# --- 5. Substance: enough real work, but not an unreviewable dump ------------
lines=$(git diff --cached --numstat -- . ':(exclude)ROADMAP.md' ':(exclude)*.lock' \
        ':(exclude)*lock.json' ':(exclude)*lock.yaml' | awk '{a+=$1; d+=$2} END {print a+d+0}')
scaffold=$(grep -c -- "$item.*\[scaffold\]" ROADMAP.md || true)
[ "$lines" -ge 8 ] || fail "only $lines changed lines outside the roadmap. Too thin to be a real unit of work."
if [ "$scaffold" -eq 0 ] && [ "$lines" -gt 1500 ]; then
  fail "$lines changed lines. Too large to review; split it across days."
fi

# --- 6. No weakening tests to get green --------------------------------------
weak=$(git diff --cached -U0 | grep '^+' | grep -vE '^\+\+\+' \
       | grep -Ei '(\.(skip|only|fixme)\(|\bxit\(|\bxdescribe\(|@Ignore|@Disabled|enabled[[:space:]]*=[[:space:]]*false|test\.todo)' || true)
if [ -n "$weak" ]; then
  grep -q '^Skip-Reason:' "$SUMMARY" \
    || fail "a test was skipped or disabled with no Skip-Reason line in the summary:
$weak"
fi

# --- 7. The referee is not editable by the player ----------------------------
protected=$(git diff --cached --name-only \
            -- .github/workflows scripts/daily scripts/report AGENTS.md LICENSE)
[ -z "$protected" ] || fail "these files are off limits to the daily agent:
$protected"

# --- 8. Nothing secret, nothing client related, nothing huge -----------------
staged=$(git diff --cached --name-only --diff-filter=AM)
for f in $staged; do
  [ -f "$f" ] || continue
  sz=$(wc -c < "$f")
  [ "$sz" -le 1048576 ] || fail "$f is $sz bytes. Large binaries do not belong in git."
done
echo "$staged" | grep -Eq '(^|/)\.env$|(^|/)\.env\.(local|prod)' && fail "a real .env file is staged"
secrets=$(git diff --cached -U0 | grep '^+' | grep -vE '^\+\+\+' \
          | grep -Ei 'sk-ant-[a-z0-9-]{10}|ghp_[A-Za-z0-9]{20}|AKIA[0-9A-Z]{12}|-----BEGIN [A-Z ]*PRIVATE KEY-----' || true)
[ -z "$secrets" ] || fail "possible secret in the diff. Rotate it if it is real."
client=$(git diff --cached -U0 -- . ':(exclude)ROADMAP.md' | grep '^+' | grep -vE '^\+\+\+' \
         | grep -Eiw 'publix|recrewit|corserv' || true)
[ -z "$client" ] || fail "client or employer reference in a public repo:
$client"

echo "Guard passed: item $item, $lines changed lines."
echo "  $title"
