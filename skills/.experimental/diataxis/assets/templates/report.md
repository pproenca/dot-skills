# Documentation Audit Report: {doc set / page}

**Date:** {YYYY-MM-DD}
**Reviewer:** {agent or user}
**Scope:** {what was reviewed — a single page, a section, or the whole corpus}
**Docs root:** {path or URL}

## Summary

{1–2 sentences: the dominant problem and the single highest-value next action.}

## Coverage map (the four modes)

Which user needs are served, and how well. A blank "Exists?" cell is a gap (see [gaps-tree](../../references/gaps-tree.md)).

| Mode | User need | Exists? | Functional quality | Deep quality | Verdict |
|------|-----------|---------|--------------------|--------------|---------|
| Tutorial | beginner learning by doing | {yes/no/weak} | {accurate · complete-for-need · consistent · precise} | {flows? anticipates?} | {keep / fix / create} |
| How-to guide | competent user, a real goal | | | | |
| Reference | look up an exact fact | | | | |
| Explanation | understand the *why* | | | | |

## Per-page findings

| Page | Compass verdict (mode) | Right mode? | Intrusions found | Action |
|------|------------------------|-------------|------------------|--------|
| {path} | {tutorial / how-to / reference / explanation} | {yes / mixed / wrong} | {explains / instructs / describes / embedded lesson} | {keep / split / move / rewrite-in-mode} |

## Timeline

| Time | Event |
|------|-------|
| {HH:MM} | Scope chosen: {what} |
| {HH:MM} | Ran the compass on {page(s)}; classified as {mode(s)} |
| {HH:MM} | Found {type-mixing / gap}: {detail} |
| {HH:MM} | Decided next action: {what} |
| {HH:MM} | Published: {the small change shipped} |

## Root Cause

{The dominant pattern. Almost always one of two: **type-mixing** (one page serving more than one user need at once) or a **missing quadrant** (a user need with no content at all). State which, with the evidence from the findings above.}

## Resolution

{What to do — the splits to make, the modes to create, the passages to move. Reference the trees/guides used: [compass-tree](../../references/compass-tree.md), [wrong-type-tree](../../references/wrong-type-tree.md), [gaps-tree](../../references/gaps-tree.md), and the four type guides.}

## Action Items

Smallest-useful-first; each item independently shippable (workflow: choose → assess → decide → do → **publish**). Do **not** bundle these into a single big-bang restructure.

- [ ] {one small, published improvement}
- [ ] {next small improvement}
- [ ] {the next worst gap to create, by failing user need}
- [ ] Append a one-line entry to the audit log (`config.json` → `audit_log`)
