#!/usr/bin/env bash
# Start a month. Creates the repo from this template and sets everything the
# daily loop needs. Run once, on the first of the month, then the cron owns it.
#
#   ./scripts/new-month.sh <repo-name> <site-url> <item-prefix>
set -euo pipefail
REPO="${1:?repo name}"; SITE="${2:?target site url}"; PREFIX="${3:?item prefix, e.g. PW}"
OWNER=fayeemajidul
FULL="$OWNER/$REPO"

gh repo create "$FULL" --public --template "$OWNER/qa-framework-template" \
  --description "Test automation framework built one commit a day against $SITE"

sleep 4
gh repo edit "$FULL" --homepage "https://$OWNER.github.io/$REPO/" \
  --add-topic test-automation --add-topic qa --add-topic github-actions

# Let the built in token open pull requests for the daily loop.
gh api -X PUT "repos/$FULL/actions/permissions/workflow" \
  -f default_workflow_permissions=write -F can_approve_pull_request_reviews=true

gh variable set SITE_URL --repo "$FULL" --body "$SITE"

for l in "daily:0e8a16:Landed by the daily loop" \
         "daily-wip:fbca04:Parked, gate failed, repair tomorrow" \
         "regression-red:d73a4a:Nightly is failing in public" \
         "daily-blocked:5319e7:The loop itself is stuck"; do
  gh label create "${l%%:*}" --repo "$FULL" \
    --color "$(echo "$l"|cut -d: -f2)" --description "$(echo "$l"|cut -d: -f3-)" 2>/dev/null || true
done

cat <<NOTE

Repo created: https://github.com/$FULL

Three things only you can do now:

  1. Install the Claude Code GitHub App on this repo, or the daily job cannot
     authenticate at all: https://github.com/apps/claude
     Choose "Only select repositories" and add $REPO. Never grant it all repos.

  2. gh secret set CLAUDE_CODE_OAUTH_TOKEN --repo $FULL
     Paste the token from 'claude setup-token'. It never goes through chat.

  3. Register a throwaway account on $SITE, then:
     gh secret set SITE_USER --repo $FULL
     gh secret set SITE_PASS --repo $FULL

  4. Enable Pages on the gh-pages branch once the first nightly has run:
     gh api -X POST repos/$FULL/pages -f 'source[branch]=gh-pages' -f 'source[path]=/'

Then write ROADMAP.md with about 26 items using prefix $PREFIX, and do item 01 by hand.
NOTE
