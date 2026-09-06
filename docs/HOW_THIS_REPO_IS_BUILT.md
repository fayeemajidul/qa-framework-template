# How this repo is built

This framework is built one unit of work per day, Monday to Saturday, by a
scheduled GitHub Actions workflow that runs Claude Code. I review the work
weekly and I am accountable for all of it. I am saying so plainly here because
a portfolio that hides how it was made is not worth much.

## What the automation actually does

Each morning the workflow takes the next item from `ROADMAP.md`, implements it,
and stops. It cannot commit, push, or use the GitHub CLI. Those tools are
disabled for it. It edits files and runs tests, and that is all.

The workflow then reruns the full gate itself, independently, and a guard script
in `scripts/daily/change-guard.sh` decides whether the work is allowed to become
a commit. That script rejects, among other things:

- an empty diff, or a whitespace only diff
- fewer than eight real changed lines
- a commit message that is not a specific Conventional Commit
- a newly skipped or disabled test with no written reason
- any edit to the workflows or the guard scripts themselves
- anything that looks like a secret or a client reference

If the gate fails, nothing is merged. The work is parked as a draft pull request
with the failure log attached, and the next day repairs it. If the repair also
fails, the item is moved to a Blocked list and the loop moves on.

## Why it is not a green squares farm

Every commit here changes real files, carries a message that names what was
tested, and is attached to a public CI run that actually passed. The agent does
not run on Sundays. A separate nightly job runs the whole suite against the live
target site and publishes the result publicly, so the badge on the README is
current rather than aspirational, and it goes red in public when something breaks.

You can verify all of that yourself. The workflow is at
`.github/workflows/daily-engineering.yml` and every run is public.
