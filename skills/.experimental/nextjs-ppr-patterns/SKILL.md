---
name: nextjs-ppr-patterns
description: "Use this skill when building, reviewing, or refactoring Next.js 16 App Router pages that mix static and dynamic content — Partial Prerendering (PPR) under the Cache Components model. Covers enabling it with cacheComponents (the removed experimental.ppr / experimental_ppr flags), the dynamic-by-default rendering inversion, the Suspense static-shell/dynamic-hole boundary, the 'use cache' directive (automatic keys, cacheLife/cacheTag, children/action pass-through, runtime values as props, serverless durability), async runtime APIs and connection() for non-determinism, page composition from a single hole to parallel dashboards to streaming a Promise into a Client Component with use(), and forms/wizards with updateTag read-your-writes and Activity state preservation. Triggers on PPR, cacheComponents, 'use cache', Suspense streaming, partial prerendering, or static-shell work even when not named explicitly."
---

# Next.js 16 Partial Prerendering Patterns

Partial Prerendering (PPR) for the **Next.js 16 App Router** under the **Cache Components** model — the decisions PPR forces and how to settle them, written so an agent applies them while writing or reviewing code. Contains **21 rules across 6 categories**, ordered from easy to complex: enable PPR → understand the static/dynamic boundary → cache → handle runtime data → compose whole pages → build forms and wizards. Each rule corrects a specific wrong default of a model defaulting to Next.js 14/15; there is no rule for things the model already gets right.

> **Version-specific.** This skill targets **Next.js 16** (PPR via `cacheComponents`, React 19.2). The Next.js 14/15 `experimental.ppr` flag and `export const experimental_ppr` route export were **removed** — see `setup-enable-cache-components`. For migrating an existing app, see the [migration guide](https://nextjs.org/docs/app/guides/migrating-to-cache-components).

> **Write, then verify.** These rules are for *authoring* PPR; they can't tell you what actually rendered. To empirically deconstruct the boundary — diff the static shell against the hydrated DOM to find the dynamic holes, locate the `'use client'` islands, measure loading, and explain why a route is dynamic — drive `next build` and a real browser per [_debug-boundaries.md](references/_debug-boundaries.md).

## When to Apply

- Building or reviewing a Next.js 16 page that mixes static chrome with personalized, real-time, or per-request content
- Enabling or migrating PPR (`cacheComponents`), or seeing dead `experimental.ppr` / `experimental_ppr` code
- Deciding where `<Suspense>` boundaries go, or debugging an `Uncached data was accessed outside of <Suspense>` build error
- Adding `'use cache'`, `cacheLife`, `cacheTag`, or choosing `updateTag` / `revalidateTag` / `refresh` after a mutation
- Composing forms, multi-step wizards, dashboards, or streaming server data into interactive Client Components
- Empirically verifying or debugging what actually rendered — which parts are in the static shell vs streamed, where the CSR/SSR boundary is, and why a route went dynamic

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Setup & Mental Model | `setup-` | Enabling PPR with `cacheComponents`; the removed experimental flags; dynamic-by-default / opt-in caching inversion |
| 2 | The Suspense Boundary | `shell-` | `<Suspense>` as the static/dynamic seam; the build error; boundary granularity; what Suspense does *not* do |
| 3 | Caching with `'use cache'` | `cache-` | Directive levels; automatic keys; runtime values as props; pass-through; `cacheLife`/`cacheTag`; serverless durability |
| 4 | Runtime APIs & Non-Determinism | `runtime-` | Async request APIs forcing a boundary; `generateStaticParams`; `connection()` for randomness/time |
| 5 | Page Composition Recipes | `compose-` | Single hole → parallel dashboard → Promise + `use()` streaming → not opting the whole app out of the shell |
| 6 | Forms, Mutations & Wizards | `mutate-` | `updateTag` vs `revalidateTag` vs `refresh`; URL-driven wizard steps; `<Activity>` field preservation |

## Quick Reference

### 1. Setup & Mental Model

- [`setup-enable-cache-components`](references/setup-enable-cache-components.md) — Enable PPR via `cacheComponents: true`; the `experimental.ppr` / `experimental_ppr` flags are removed
- [`setup-dynamic-by-default`](references/setup-dynamic-by-default.md) — Everything renders at request time; caching is opt-in via `'use cache'` (and `fetch` is no longer cached)

### 2. The Suspense Boundary

- [`shell-suspense-is-the-boundary`](references/shell-suspense-is-the-boundary.md) — `<Suspense>` is the static-shell/dynamic-stream seam, not a spinner
- [`shell-wrap-uncached-data`](references/shell-wrap-uncached-data.md) — Uncached/runtime reads must be wrapped (or `'use cache'`d) or the build errors
- [`shell-suspense-does-not-force-dynamic`](references/shell-suspense-does-not-force-dynamic.md) — Suspense alone does not make synchronous work dynamic
- [`shell-place-boundaries-low`](references/shell-place-boundaries-low.md) — Wrap the dynamic leaf, not the whole page, so the shell stays large

### 3. Caching with `'use cache'`

- [`cache-use-cache-directive`](references/cache-use-cache-directive.md) — Mark static/cacheable work at the function / component / page / layout / file level
- [`cache-keys-are-automatic`](references/cache-keys-are-automatic.md) — Arguments and closures form the cache key; pass varying inputs as args
- [`cache-pass-runtime-values-as-props`](references/cache-pass-runtime-values-as-props.md) — You can't read `cookies()`/`headers()` inside a cached scope; pass values in
- [`cache-pass-through-children-and-actions`](references/cache-pass-through-children-and-actions.md) — Pass dynamic `children` and Server Actions through a cached component untouched
- [`cache-set-lifetime-and-tags`](references/cache-set-lifetime-and-tags.md) — `cacheLife` controls TTL, `cacheTag` enables on-demand invalidation
- [`cache-in-memory-not-durable-serverless`](references/cache-in-memory-not-durable-serverless.md) — In-memory cache isn't durable on serverless; use `'use cache: remote'`

### 4. Runtime APIs & Non-Determinism

- [`runtime-request-apis-force-a-boundary`](references/runtime-request-apis-force-a-boundary.md) — Async `cookies`/`headers`/`searchParams`/`params` force a dynamic boundary
- [`runtime-keep-param-routes-static`](references/runtime-keep-param-routes-static.md) — `generateStaticParams` keeps `[slug]` routes in the static shell
- [`runtime-gate-nondeterminism-with-connection`](references/runtime-gate-nondeterminism-with-connection.md) — Gate `Math.random`/`Date.now`/`crypto` behind `connection()`, or cache the value

### 5. Page Composition Recipes

- [`compose-single-dynamic-hole`](references/compose-single-dynamic-hole.md) — The baseline: static shell + one `<Suspense>` hole
- [`compose-parallel-holes`](references/compose-parallel-holes.md) — One boundary per widget → parallel streaming, no waterfall
- [`compose-stream-to-client-with-use`](references/compose-stream-to-client-with-use.md) — Pass an un-awaited Promise and unwrap with `use()` in a Client Component
- [`compose-do-not-opt-out-the-shell`](references/compose-do-not-opt-out-the-shell.md) — Don't defer the whole app to silence a boundary error

### 6. Forms, Mutations & Wizards

- [`mutate-updatetag-vs-revalidatetag`](references/mutate-updatetag-vs-revalidatetag.md) — `updateTag` (read-your-writes) vs `revalidateTag(tag, profile)` (SWR) vs `refresh()`
- [`mutate-wizard-url-driven-steps`](references/mutate-wizard-url-driven-steps.md) — URL-driven steps + static chrome + `<Activity>` field preservation

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical way (with an incorrect/correct contrast only where the wrong way is a real trap). If you're starting cold, read `setup-` first — the rest assumes the dynamic-by-default mental model.

- [Section definitions](references/_sections.md) — category structure and ordering
- [Boundary debugging](references/_debug-boundaries.md) — empirically deconstruct the static/dynamic boundary and loading with `next build` and chrome-devtools-mcp (via mcporter); use it when a PPR result surprises you or you're chasing a `blocking-route` error
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- `nextjs` — broader Next.js 16 App Router best practices (caching, server components, routing, hygiene)
- `opinionated-nextjs-patterns` — full opinionated architecture (data layer, mutations, client boundaries) that uses these PPR patterns
- `react-fetch-cache-patterns` — request orchestration and client-side caching for data-heavy React UIs

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [references/_debug-boundaries.md](references/_debug-boundaries.md) | Empirical CSR/SSR boundary & loading debugging (`next build` + chrome-devtools-mcp via mcporter) |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
