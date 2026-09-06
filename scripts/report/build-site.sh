#!/usr/bin/env bash
# Assemble the published report site: this run, an index of recent runs, and a
# machine readable status file the README badge and the year end hub both read.
set -euo pipefail
OUTCOME="${1:-unknown}"
STAMP=$(date -u +%Y-%m-%d)
KEEP=30
REPORT_DIR="${REPORT_DIR:-playwright-report}"
RUN_URL="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-}"

mkdir -p site/runs
[ -d "$REPORT_DIR" ] || { echo "no report at $REPORT_DIR"; mkdir -p "$REPORT_DIR"; echo "<p>No report produced.</p>" > "$REPORT_DIR/index.html"; }
rm -rf "site/runs/$STAMP"; cp -r "$REPORT_DIR" "site/runs/$STAMP"
rm -rf site/latest;        cp -r "$REPORT_DIR" site/latest

# Keep the site small. GitHub Pages caps a published site at 1 GB.
ls -1d site/runs/*/ 2>/dev/null | sort -r | tail -n +$((KEEP+1)) | xargs -r rm -rf

cat > site/status.json <<JSON
{"repo":"${GITHUB_REPOSITORY:-}","date":"$STAMP","outcome":"$OUTCOME","run":"$RUN_URL"}
JSON

{
  echo "<!doctype html><meta charset=utf-8><title>Nightly reports</title>"
  echo "<style>body{font:15px/1.6 system-ui,sans-serif;max-width:52rem;margin:3rem auto;padding:0 1rem}"
  echo "a{color:#0969da}li{margin:.3rem 0}.ok{color:#1a7f37}.bad{color:#cf222e}</style>"
  echo "<h1>${GITHUB_REPOSITORY:-Nightly} reports</h1>"
  echo "<p>Last run <strong>$STAMP</strong>: <span class=\"$([ "$OUTCOME" = success ] && echo ok || echo bad)\">$OUTCOME</span>."
  echo "<a href=\"latest/\">Open the latest report</a>.</p><h2>Recent runs</h2><ul>"
  ls -1d site/runs/*/ 2>/dev/null | sort -r | while read -r d; do
    n=$(basename "$d"); echo "<li><a href=\"runs/$n/\">$n</a></li>"
  done
  echo "</ul>"
} > site/index.html
echo "Report site built for $STAMP, outcome $OUTCOME"
