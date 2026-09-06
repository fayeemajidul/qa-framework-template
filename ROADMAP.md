---
repo: <repo-name>
month: <YYYY-MM>
site: <target site url>
gate: pnpm gate
prefix: XX
---
# Roadmap

The daily agent takes the first unchecked item that is not under Blocked, and does
exactly one per day. Every item has a **Done when** line that must be true before
the checkbox moves.

Tags: `[offline-ok]` means the item needs no live site, so it is safe on a day the
target is down. `[scaffold]` lifts the diff size ceiling for that item only.

## Capability checklist

The month is not finished until all eight of these are real.

- [ ] Logging
- [ ] API layer
- [ ] Reporting
- [ ] CI
- [ ] Page objects
- [ ] Retries
- [ ] Environment config
- [ ] Docs

## Week 1, foundation

- [ ] XX-01 [offline-ok] [scaffold] Project scaffold: package manager, TypeScript strict, test runner, lint, format, `.env.example`, and a `gate` script. Done when: `pnpm gate` passes with one placeholder test.
- [ ] XX-02 [offline-ok] Typed environment config validated at startup. Done when: a unit test proves an invalid environment fails fast with a readable message.
- [ ] XX-03 [offline-ok] Architecture doc with the layer table and a Mermaid diagram. Done when: the README links to it.

## Week 2, the framework

## Week 3, breadth

## Week 4, hardening

- [ ] XX-25 [offline-ok] README final pass. Done when: every badge resolves and the report link is live.
- [ ] XX-26 [offline-ok] Month retrospective in `docs/RETRO.md`. Done when: it names what was hard, what was cut, and what a reviewer should read first.

## Backlog

Used only when every dated item is done.

## Blocked

Items the loop failed twice, moved here automatically with a link to the run.
