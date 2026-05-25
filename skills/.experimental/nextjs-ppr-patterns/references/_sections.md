# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance ×
frequency** — what a model defaulting to Next.js 14/15 gets most often and most
expensively wrong with Partial Prerendering goes first. This is an API-correctness
skill for Next.js 16's Cache Components model, not a performance skill, so
categories carry no impact tier. The order is also a learning arc: enable PPR →
understand the static/dynamic boundary → cache → handle runtime data → compose
whole pages → handle forms and wizards.

---

## 1. Setup & Mental Model (setup)

**Description:** How PPR is turned on in Next.js 16 and the rendering-model inversion every other rule depends on. The `experimental.ppr` flag and `export const experimental_ppr` route export were **removed** in Next.js 16; PPR is now the default behavior of Cache Components (`cacheComponents: true`). Caching also flipped from implicit to opt-in: everything is dynamic at request time unless you mark it `'use cache'`. Get this wrong and nothing else applies.

## 2. The Suspense Boundary (shell)

**Description:** `<Suspense>` is the literal seam between the static prerendered shell and the dynamically streamed holes — not just a loading-spinner nicety. Covers where the boundary goes, why the fallback ships in the shell while children stream, the build error you get when uncached data escapes a boundary, the subtlety that Suspense does not by itself make work dynamic, and choosing boundary granularity so the static shell stays as large as possible.

## 3. Caching with `'use cache'` (cache)

**Description:** Opting work back into the static shell with the `'use cache'` directive. Covers the directive's levels (function / component / page / layout / file), the automatically-generated cache key, the hard constraint that runtime APIs cannot be read inside a cached scope (pass values as props), passing dynamic `children`/Server Actions through a cached component, `cacheLife`/`cacheTag`, and why in-memory caching does not persist across serverless invocations.

## 4. Runtime APIs & Non-Determinism (runtime)

**Description:** The inputs that force a component to render at request time. Covers `cookies()`/`headers()`/`draftMode()`/`searchParams`/`params` (all async now) forcing a dynamic boundary, keeping dynamic-segment routes in the static shell with `generateStaticParams`, and gating non-deterministic operations (`Math.random()`, `Date.now()`, `crypto.randomUUID()`) behind `connection()` so they don't break prerendering.

## 5. Page Composition Recipes (compose)

**Description:** Assembling whole pages, from the simplest to the most involved. Covers the canonical single-hole page, multiple independent holes streaming in parallel, streaming server data into an interactive Client Component via an un-awaited Promise + `use()`, and why you should not "fix" a build error by opting the entire app out of the static shell.

## 6. Forms, Mutations & Wizards (mutate)

**Description:** The interactive, stateful end of the spectrum. Covers choosing `updateTag` (read-your-writes) vs `revalidateTag(tag, profile)` (stale-while-revalidate) vs `refresh()` after a mutation, and building a multi-step wizard whose step is URL-driven, whose chrome is static, and whose in-progress field state survives navigation via React's `<Activity>` (used automatically by Cache Components).
