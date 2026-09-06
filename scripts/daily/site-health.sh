#!/usr/bin/env bash
# Is the target site reachable? A dead practice site must not fail the day;
# it redirects the agent to work that does not need the site.
set -uo pipefail
URL="${1:?usage: site-health.sh <url>}"
up=false
for i in 1 2 3; do
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 20 \
         -A 'Mozilla/5.0 (compatible; portfolio-healthcheck)' "$URL" 2>/dev/null || echo 000)
  echo "attempt $i: HTTP $code"
  case "$code" in 2*|3*) up=true; break ;; esac
  sleep 5
done
echo "site_up=$up" >> "${GITHUB_OUTPUT:-/dev/stdout}"
echo "Target $URL reachable: $up"
