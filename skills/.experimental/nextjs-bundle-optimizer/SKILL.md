---
name: nextjs-bundle-optimizer
description: Use this skill whenever a Next.js 16 app needs smaller bundles or faster builds — even if the user doesn't say "optimize" explicitly. Triggers on phrases like "First Load JS is huge", "bundle size", "build takes too long", "page is slow to TTI", "reduce bundle", "tree-shake", or when the user shares output from `next experimental-analyze` / `@next/bundle-analyzer`. Runs a data-driven iteration loop — measure baseline → analyze top offenders → apply ONE recipe → re-measure → verify nothing broke (build + types + tests + no regression) → commit or revert. Built for Next.js 16 with Turbopack default, and falls back to webpack-mode tooling when the project hasn't migrated yet.
---

# Next.js Bundle & Build-Time Optimizer

Data-driven optimization loop for Next.js 16 applications. The skill orchestrates `next experimental-analyze`, builds, type checks, and tests to make verifiable improvements one change at a time.

## When to Apply

Use this skill when:
- The user wants to reduce bundle size / First Load JS / route bundles in a Next.js 16 app.
- Production builds are slow and the user wants to diagnose and fix the bottleneck.
- The user shares analyzer output, a screenshot of the treemap, or asks "why is `<X>` so big?"
- A new dependency was added and bundles grew — they want to understand why and unwind it.
- The user wants to set a performance budget and enforce it iteratively.

## Why iterative (not "apply all optimizations at once")

Bundle optimization is full of foot-guns. Examples:
- Moving a "client-only" dep behind `next/dynamic` can break SSR consumers that depended on its presence at first paint.
- `experimental.optimizePackageImports` with the wrong package can mis-resolve subpath exports.
- Aggressive `modularizeImports` regex rewrites can hit unintended modules.
- Narrowing the polyfill target can break older mobile browsers in production.

The only reliable way is: **one change, measure, verify, commit (or revert)**. This skill enforces that discipline through scripts.

## Prerequisites

- Next.js 16+ project (the skill auto-detects from `package.json`).
- `git` (the workflow uses commits as checkpoints and revert as rollback).
- `jq` available on PATH (used by analyze/compare scripts).
- A clean working tree before starting (the verify step uses `git status` to confirm).
- For projects still on Next.js 15 or earlier in webpack mode: the skill detects this and uses `@next/bundle-analyzer` instead of `experimental-analyze`. See [gotchas.md](gotchas.md).

## Setup

On first use, run:

```bash
bash scripts/baseline.sh --setup
```

This walks through `config.json` interactively. If `config.json` already has values, scripts use those and skip the prompts.

## Workflow Overview

```
┌── 1. baseline ──┐   Clean build, snapshot bundles + timing → baselines/{timestamp}/
│                 │
│   2. analyze ───┤   Run `next experimental-analyze --output`, extract top offenders
│                 │
│   3. diagnose ──┤   Map each offender to a recipe in references/optimizations.md
│                 │
│   ── apply ─────┤   User (or agent) applies ONE recipe. Skill helps draft the change.
│                 │
│   4. measure ───┤   Re-build, re-analyze, save to iterations/{n}/
│                 │
│   5. compare ───┤   Diff vs baseline; flag regressions; print delta table
│                 │
│   6. verify ────┤   Build + tsc + tests + no overall regression. Hard PASS/FAIL.
│                 │
│   commit OR ────┘   `git commit` (PASS+improvement) or `git revert` (FAIL/no win)
│   revert
│
└── loop back to step 2 with new baseline if you want a fresh measurement point.
```

Read [references/workflow.md](references/workflow.md) for the detailed loop with error handling, rollback procedures, and what each script's output looks like.

## Quick Reference

### Scripts (run from the Next.js app root)

| Script | Purpose | Output |
|--------|---------|--------|
| `scripts/baseline.sh` | Establish the reference point | `baselines/{ts}/{bundle,timing,manifest}.json` |
| `scripts/analyze.sh` | Run analyzer, parse top offenders | `iterations/{n}/findings.json` |
| `scripts/diagnose.sh [findings.json]` | Map findings → recipes | stdout: prioritized recipe list |
| `scripts/measure.sh` | Re-measure after a change | `iterations/{n}/{bundle,timing}.json` |
| `scripts/compare.sh [baseline] [current]` | Diff snapshots | stdout: delta table; exit 1 on regression |
| `scripts/verify.sh` | Full verification | exit 0 = safe to commit, exit 1 = revert |

### Optimization Recipes

[references/optimizations.md](references/optimizations.md) catalogs recipes by analyzer signal:

**Bundle size**
- Barrel-import bloat → `experimental.optimizePackageImports` (webpack) / auto in Turbopack
- Heavy client lib pulled in on every route → `next/dynamic({ ssr: false })`
- Server-only lib imported from a client component → move to Server Component
- Duplicate dependency versions → dedupe via `overrides` / `resolutions`
- Polyfill bloat → tighten `browserslist`
- Per-icon imports for icon libraries

**Build time**
- Enable `experimental.turbopackFileSystemCacheForBuild`
- Narrow `transpilePackages` (overuse balloons compile time)
- Split `tsc --noEmit` from `next build` in CI
- Identify single-file bottlenecks with `NEXT_TURBOPACK_TRACING=1`

Each recipe documents: **signal → fix → expected impact → verify step**.

## Gotchas

See [gotchas.md](gotchas.md) for accumulated failure points. Initially seeded with the most common Next.js 16 traps:
- `next build` no longer prints First Load JS — don't grep build output for it.
- `optimizePackageImports` is a no-op under Turbopack (default in 16) — Turbopack auto-optimizes.
- Comparing build times needs cache state controlled — either delete `.next/` (cold) or pre-warm (warm).

## Related Skills

- `vercel:nextjs` — general Next.js App Router guidance; consult for refactoring decisions while applying recipes.
- `vercel:turbopack` — for build-time debugging beyond what this skill covers.
- `vercel:next-cache-components` — when a recipe touches caching boundaries.
