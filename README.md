# qa-framework-template

The template every month of the [daily QA portfolio](https://github.com/fayeemajidul)
is created from. It is not a framework itself. It is the machinery that lets one
framework get built a little each day, in public, without the result looking like
filler.

## What is in here

| Path | What it does |
|---|---|
| `AGENTS.md` | The rulebook the daily agent must follow. Engineering standards, hard rules, and what a finished day means. |
| `.github/workflows/daily-engineering.yml` | Runs one unit of work each morning, Monday to Saturday, on GitHub's servers. |
| `.github/workflows/nightly.yml` | Runs the full suite against the live target site and publishes the report. |
| `.github/workflows/ci.yml` | The same gate on human pull requests. |
| `scripts/daily/change-guard.sh` | The referee. Decides whether a day's work is real enough to become a commit. |
| `scripts/daily/park.sh` | Turns a failed day into a repairable draft rather than a lost day. |
| `scripts/new-month.sh` | Creates and configures the next month's repo in one command. |

## Starting a month

```bash
./scripts/new-month.sh playwright-ts-automationexercise https://automationexercise.com PW
```

Then set the token secret, register a throwaway account on the target site, write
`ROADMAP.md`, and do item 01 by hand so the first commit of every repo is human
verified. The script prints these steps when it finishes.

## The idea

An agent that commits its own work will eventually commit filler, because nothing
stops it. So the agent here cannot use git at all. It edits files and runs tests.
The workflow independently reruns the gate, a guard script checks the diff is real
engineering, and only then does a commit exist. See
[`docs/HOW_THIS_REPO_IS_BUILT.md`](docs/HOW_THIS_REPO_IS_BUILT.md).

## License

MIT
