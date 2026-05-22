# Symptom Catalog

Each symptom is an entry point into a decision tree. Match the situation to a row, then open the tree. **Severity** reflects how badly the *reader* is failed right now — P1 means readers are blocked or actively misled today.

| # | Symptom / trigger | Entry tree | Severity | What it usually means |
|---|-------------------|-----------|----------|-----------------------|
| 1 | "Write docs for X" / "document this" / "we need docs" — and the *kind* of doc is unclear | [compass-tree.md](compass-tree.md) | P2 | No mode chosen yet. Classify before writing. This is the master tree — start here whenever unsure. |
| 2 | New users can't get started; they bounce off; "I don't know where to begin" | [gaps-tree.md](gaps-tree.md) | P1 | Missing or broken **tutorial** — the learning/acquisition path is closed. |
| 3 | A competent user can't accomplish a specific goal; "how do I do X?" has no answer | [gaps-tree.md](gaps-tree.md) | P1 | Missing **how-to guide** for a real task. |
| 4 | Users can't find a fact; specs are scattered, inconsistent, or not trusted | [gaps-tree.md](gaps-tree.md) | P2 | **Reference** missing/incomplete, or not led by the product's structure. |
| 5 | Users don't understand *why*; no mental model; they keep misusing the thing | [gaps-tree.md](gaps-tree.md) | P2 | Missing **explanation** — understanding was never offered. |
| 6 | A page is bloated/rambling, or mixes teaching + steps + specs + opinion | [wrong-type-tree.md](wrong-type-tree.md) | P2 | Type-mixing: one document serving two or more needs at once. |
| 7 | A tutorial stalls into explanation; a how-to lectures; reference editorialises | [wrong-type-tree.md](wrong-type-tree.md) | P2 | A mode has drifted — content sits in the wrong quadrant. |
| 8 | "Our docs are a sprawling mess — where do I even start?" | [restructure-tree.md](restructure-tree.md) | P3 | Needs the iterative workflow, not a top-down rewrite. |

## How severity maps to action

- **P1** — Readers are blocked or failing *right now* (can't get started, can't complete a task). Fix the closed acquisition/goal path first; this is where users are leaving.
- **P2** — Content exists but in the wrong mode or incomplete, creating friction and eroding trust. Separate it, or complete it.
- **P3** — The corpus needs structural / meta work. Valuable, but improve it incrementally — never by tearing it down.

## Terminal states (every tree ends in one)

1. **Identify the mode** — decide which of the four modes the content serves, and write/route it there.
2. **Split** — separate a mixed document into the single-mode pieces it was conflating; link them instead of inlining.
3. **Create** — write the missing mode that a failing user need points to.
4. **Improve in place** — apply one small workflow iteration and publish; let structure emerge.
5. **Dismiss** — the document is already single-mode and serving its need. No Diátaxis action (optionally hand prose issues to a copy-editing skill).

## Audit history

When auditing an existing doc set, record findings with [../assets/templates/report.md](../assets/templates/report.md) and append a one-line entry per audit to the log (default `${CLAUDE_PLUGIN_DATA:-$HOME/.claude}/diataxis-audits.log`, set in `config.json`). Over time this shows which gaps recur and whether splits actually held.
