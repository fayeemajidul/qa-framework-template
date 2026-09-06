# Decisions

One entry per meaningful choice. Every new dependency needs a line here.

Format: what was chosen, what else was considered, and why.

## Template

### 2026-09 Report hosting: GitHub Pages per repo
Considered a single shared reports repo. Chose per repo Pages because each repo
then publishes with its own built in token and needs no cross repo credential.

### 2026-09 The agent cannot use git
Considered letting the agent commit its own work. Chose to disable git, gh, and
curl for it, and to have the workflow run the gate and land the commit. An agent
that grades its own homework is exactly how filler reaches a public history.
