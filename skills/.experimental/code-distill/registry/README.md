# Registry — Per-Library Code Topography Records

This directory holds **code topography records** — one file per library — capturing where things live in that library's GitHub repo. Each record is reference data, not a rule pack: ~30 lines of pure facts that let the next code-distill session skip the discovery phase.

The registry is **intentionally empty at v0.1.0**. The radical-simplification recommendation that produced this skill said: do not pre-empt; add the first entry from a real lookup. If you find yourself writing a record for a repo you have not actually queried in this session, stop — the record will rot before it's used.

## When to add a record

Add a record at the **end of a successful code-distill session** for a library that does not yet have one. The work to discover the topography was already done during the session; capturing it costs seconds. See [`references/capture-registry-record.md`](../references/capture-registry-record.md) for the full rule.

## Record format

Each library gets its own file: `registry/<library>.md`, where `<library>` is the lowercase, hyphen-separated name as the library calls itself (`shadcn-ui`, `base-ui`, `opencode`, `effect-ts`).

```yaml
---
library: <library-slug>
repo: <github-url>
default-branch: main | master | other
last-verified-sha: <SHA>
last-verified-date: YYYY-MM-DD
agents-md: true | false              # AGENTS.md at root?
contributing-md: true | false        # CONTRIBUTING.md at root?
folder-map:
  components: <path-or-glob>
  tokens: <path-or-glob>
  state: <path-or-glob>
  effects: <path-or-glob>
  tests: <path-or-glob>
  examples: <path-or-glob>
  docs: <path-or-glob>
naming-conventions:
  - <one-line>
  - <...>
package-manager: pnpm | yarn | npm | cargo | other
notable-landmarks:
  - <one-line description of useful files/dirs>
  - <...>
lookup-count: <integer, incremented per successful session>
---

## Notes

(Optional prose section for anything that doesn't fit structured fields.)
```

## The graduation rule

When `lookup-count >= 3` on a single library, it has earned a full static **code-atlas distillation** skill (see `opencode-ts`, `openai-codex-rust-patterns`, `nextjs-ppr-patterns` for the heavy form). When you ship that static skill:

1. Retire (delete) the `registry/<library>.md` entry
2. Add the library to this skill's "When NOT to Apply" section, pointing future users at the new static skill
3. The library moves from light layer (this skill) to heavy layer (its own dedicated skill)

The threshold is intentionally low — 3 lookups demonstrates real repeat demand, and the investment in a static skill (heavy: 30-60 rules, source-priority-ladder mining, failure-gap extraction) is justified.

## What does NOT belong in a record

- **Specific patterns or idioms** ("how shadcn implements variants"). Those go in the static code-atlas skill if/when it's authored.
- **API method documentation**. The code itself is the source.
- **Opinions about the library**. Topography is observable; opinions are not.
- **Stale SHA without a verification date**. Either pin AND date, or do not pin.

## Refreshing records

- On every session that uses a record: increment `lookup-count`, refresh `last-verified-sha` and `last-verified-date`
- If the folder map changed: update it; note the change in `## Notes`
- If the SHA is more than 30 days behind on a fast-moving repo: re-verify before relying on the record
- If the repo was renamed, moved, or archived: update or delete the record in the same session that hit the failure
