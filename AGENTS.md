# Agent rulebook

You are doing one day of real engineering on a public QA automation framework.
This file is the contract. Read it fully before touching anything.

`CLAUDE.md` points here. Do not duplicate rules into it.

---

## 1. What a day is

One roadmap item. Not two, not half of one.

A day is finished when all of these are true:

1. The item's **Done when** line in `ROADMAP.md` is actually true.
2. The gate command passes locally in your run.
3. That item's checkbox is flipped from `- [ ]` to `- [x]`, and no other checkbox moved.
4. The summary file is written in the exact format in section 7.

Then you stop. You do not commit. You do not push. The workflow does that.

---

## 2. Hard rules

These are checked by a script after you finish. Breaking one means the day does
not land, so there is no upside to bending them.

1. **Never run `git commit`, `git push`, `git checkout`, `gh`, or `curl`.** You edit
   files and run tests. The workflow handles version control.
2. **Never edit** `.github/workflows/**`, `scripts/daily/**`, `scripts/report/**`,
   `AGENTS.md`, or `LICENSE`. Those are the referee. A player does not edit the referee.
3. **Never weaken a test to make the gate pass.** Do not add `.skip`, `.only`, `.fixme`,
   `@Ignore`, `xit(`, or `enabled = false`. Do not delete an assertion. Do not widen a
   timeout to paper over a race. If a test is genuinely wrong, fix the cause, or park
   the day and say why. A skip is not a pass.
4. **Never write a secret, a password, an API key, or a real person's data** into any
   file. Test credentials come from environment variables and are documented as names
   only in `.env.example`.
5. **Never reference a client, an employer, or any internal system.** These repos are
   public and target public practice sites only.
6. **Never add a dependency** without adding a line to `docs/DECISIONS.md` saying what
   it is for and what you considered instead.
7. **Keep the diff focused.** No drive by reformatting, no renaming files the item does
   not mention, no refactors nobody asked for.

---

## 3. Priority, in this order

Check these before picking anything from the roadmap.

1. **Repair mode.** The workflow tells you `MODE=repair`. Yesterday's work is on this
   branch and it failed the gate. Read the failure, fix it, do not start a new item.
2. **Red regression.** An open issue labelled `regression-red` means the nightly suite
   is failing in public. Fixing it outranks any new feature.
3. **Site is down.** `SITE_UP=false` means you may only pick an item tagged
   `[offline-ok]`, such as docs, unit tests, the API client, or config work.
4. **Otherwise**, take the first unchecked item in `ROADMAP.md` that is not under
   Blocked.

---

## 4. Engineering standards

These are the standards the framework is judged on. They are also the reason this
portfolio exists, so they are not negotiable for convenience.

### Locators
Prefer, in this order: a role plus accessible name, a stable `data-test` attribute, a
label association, then visible text. Never a locator that depends on layout position,
generated class names, or a full CSS or XPath chain from the document root. If the site
gives you nothing stable, add a comment naming the constraint.

### Waiting
Three tiers, and nothing else. Short for an element that should already be present.
Standard for a normal navigation or update. Long only for a documented slow operation,
with a comment saying why. **Never a fixed sleep.** Wait for a condition, never for a
duration.

### Page objects
A page object exposes actions and queries. It never asserts. It never contains test
data. Assertions live in tests. A page object that has grown past roughly 200 lines is
telling you the page has more than one responsibility, so split it.

### Tests
A test body reads as a sentence about behaviour. Setup goes through the API layer, not
by clicking through the interface, because that is faster and it is not what is being
tested. Each test creates its own data and can run in parallel with any other. No test
depends on another test having run first.

### Logging
Structured, one event per meaningful step, with the run identifier attached. Logs are
evidence for a failure you did not watch happen. Never log a credential.

### Retries
Retry only on genuine environmental noise, with a hard cap, and record that a retry
happened. A test that only passes on retry is a bug you have hidden, so it gets an
issue.

### Failure triage
When something fails, classify it before fixing it: a product bug on the target site, a
defect in the test, or an environment problem. Evidence order is the report, then the
trace or screenshot, then the logs. Write the classification into the summary.

---

## 5. Never load test somebody else's server

Load, stress, spike, and soak tests run **only** against a container that the CI job
starts itself. Sustained traffic against infrastructure you do not own is a terms of
service problem and possibly a legal one. A single request smoke check against a public
host is fine. Anything beyond that is not.

---

## 6. Definition of done for the month

The month is complete when the framework genuinely has all eight, each backed by a
roadmap item:

logging, an API layer, reporting, CI, page objects, retries, environment config, docs.

---

## 7. The summary file

Write it to the path in `$DAILY_SUMMARY`. Exact format, front matter included:

```markdown
---
item: PW-07
title: "feat(cart): page object for cart with quantity and remove actions"
---
Why: the checkout flow needs a stable cart abstraction before PW-09 can assert totals.
What changed: src/pages/CartPage.ts, tests/smoke/cart.spec.ts, docs/ARCHITECTURE.md.
Verified: gate passed, 7 smoke tests green, 1 retry on remove which is now waited properly.
```

`title` becomes the commit title, so it must be a valid Conventional Commit: one of
`feat fix test refactor docs ci build chore perf`, an optional scope in brackets, then
a description between 10 and 72 characters. Write what a reviewer needs to know, not
what you did minute by minute.

---

## 8. Style

Write like an engineer explaining to another engineer. Short sentences. No filler, no
marketing adjectives, no exclamation marks. Comments explain why, never what.
