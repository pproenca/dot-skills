---
name: nuqs-codemod-runner
description: Use this skill whenever a codebase has nuqs code that may be stuck on pre-v2.5 patterns — deprecated `throttleMs`, hand-rolled setTimeout/useState debounce around `useQueryState`, unchecked `parseAsJson` casts, unversioned `nuqs/adapters/react-router` imports, or `ParserBuilder<T>` type references. The skill scans the repo, produces a dry-run report, asks for confirmation, applies AST codemods, then runs `tsc --noEmit` + the user's lint as a gate. Trigger even if the user only mentions "upgrade nuqs" or "migrate to nuqs v2.5+" without naming the specific patterns — they almost always exist in pre-v2.5 codebases.
---

# nuqs Codemod Runner

Migrate a codebase from pre-v2.5 nuqs patterns to current v2.5–v2.8 idioms. The skill is **read-only by default** — it never modifies files without an explicit confirmation step, and refuses to run on a dirty git working tree.

## When to Apply

Trigger this skill when:
- A user asks to "upgrade nuqs" or "migrate to nuqs 2.x" in a project that already uses nuqs
- You spot any of the 5 legacy patterns during a review (see the codemod table below)
- A `nuqs` version bump in `package.json` from `<2.5` to `>=2.5` is part of the diff
- The user has just installed/updated the [`nuqs` skill](../nuqs/SKILL.md) and wants to bring existing code into line with it

This skill is the **automation companion** to `skills/.curated/nuqs/` — that skill teaches what each correct pattern looks like; this skill rewrites legacy code to match.

## Workflow Overview

```
┌──────────┐    ┌────────────┐    ┌──────────────────┐    ┌───────────┐    ┌────────────┐
│  scan.sh │──▶ │ scan.json  │──▶ │   report.sh      │──▶ │ apply.sh  │──▶ │ verify.sh  │
└──────────┘    └────────────┘    │ (dry-run table)  │    │ (codemods)│    │ (tsc+lint) │
                                  └──────────────────┘    └───────────┘    └────────────┘
                                          │                     ▲                │
                                          ▼                     │                ▼
                                  user reviews ────────────  confirms       on fail: revert
```

1. **`scripts/scan.sh <repo-root>`** — ripgreps every `.ts/.tsx/.js/.jsx` file for the 5 legacy patterns, emits `scan.json` with `{path, line, matchedPattern, snippet, suggestion}`.
2. **`scripts/report.sh`** — renders `scan.json` as a markdown table grouped by codemod, with file paths and before/after pairs. **Show this output to the user verbatim** and ask for explicit confirmation before continuing.
3. **`scripts/apply.sh [--filter <codemod-id>]`** — runs the jscodeshift transforms in `scripts/transforms/`. Refuses to run unless a fresh `scan.json` exists for the current `git HEAD` and the working tree is clean (`--allow-dirty` overrides).
4. **`scripts/verify.sh`** — runs `tsc --noEmit` and `npm run lint` (or the equivalent commands from `config.json`). If anything fails, `git restore` reverts every file the codemod touched.

Run all four sequentially. If the user only wants to scan, stop at step 2.

## The Five Codemods

| ID | Detects | Rewrites to |
|----|---------|-------------|
| `throttle-ms` | `withOptions({ throttleMs: N })` or `setX(v, { throttleMs: N })` | `withOptions({ limitUrlUpdates: throttle(N) })` + adds `throttle` to the `nuqs` import |
| `manual-debounce` | `useState` mirror + `useEffect` + `setTimeout` debounce around a `useQueryState` setter | `withOptions({ limitUrlUpdates: debounce(N) })` + adds `debounce` to the `nuqs` import; deletes the mirror state and effect |
| `unchecked-json-cast` | `parseAsJson<T>()` (no validator) or `parseAsJson((v) => v as T)` | Inserts a `// TODO: validate` type-guard stub or, if Zod is detected in `package.json`, a `parseAsJson(SchemaName.parse)` form |
| `react-router-unversioned` | `from 'nuqs/adapters/react-router'` | `from 'nuqs/adapters/react-router/v6'` (the alias the unversioned import historically pointed at) |
| `parser-builder-type` | type references to `ParserBuilder<T>` from `nuqs` | `SingleParserBuilder<T>` |

See [`references/workflow.md`](references/workflow.md) for the exact AST shapes each codemod matches and the edge cases it deliberately skips.

## Setup

On first run, `config.json` is populated with the user's lint/typecheck commands and a default `min_node_version`. See `_setup_instructions` in `config.json` for what to fill in.

## Risk & Guardrails

This skill is **write-risk** (it modifies source files). Guardrails:

- `apply.sh` aborts if the working tree is dirty (use `git stash` first, or pass `--allow-dirty` after reading [`gotchas.md`](gotchas.md))
- `apply.sh` aborts if `scan.json` is older than 60 minutes or was generated against a different `git HEAD` — re-run `scan.sh`
- The `hooks/hooks.json` PreToolUse matcher blocks any direct `node scripts/transforms/*.js` invocation that bypasses the orchestrator
- `verify.sh` auto-reverts on TS or lint failure via `git restore` over the touched files (recorded in `last-run.json`)

## Related Skills

- [`nuqs`](../nuqs/) — Best-practice reference for nuqs v2.5+. This skill rewrites legacy code; that skill defines the target.

## Gotchas

See [`gotchas.md`](gotchas.md) for failure modes discovered during use.
