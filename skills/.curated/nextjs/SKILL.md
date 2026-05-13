---
name: nextjs
description: Next.js 16 App Router performance, caching, server components, server actions, routing, and codebase-hygiene best practices — plus a category-major review/refactor algorithm with codebase-level (remove/dedup/reuse) findings. This skill should be used when writing Next.js 16 App Router code, configuring caching with 'use cache', building Server Components, setting up parallel/intercepting routes, configuring next.config.js OR proxy.ts, OR auditing/refactoring a Next.js codebase (single file or whole repo). This skill does NOT cover generic React 19 patterns (use react skill) or non-Next.js server rendering.
---

# Next.js 16 App Router Best Practices

Comprehensive Next.js 16 App Router guide for AI agents. Contains **45 rules across 9 categories**, prioritized by impact from critical (build optimization, caching strategy) through to cross-cutting codebase hygiene (dedup, dead routes, boundary coherence). Reflects Next.js 16 changes: `'use cache'` directive replacing implicit caching, `revalidateTag(tag, cacheLife)` requirement, `proxy.ts` replacing `middleware.ts`, Turbopack persistent caching, App Router conventions.

Rule files describe **pattern shapes** (not API names) and open with a **"Shapes to recognize"** section listing 2–4 syntactic disguises the same break can wear. **Selected high-value rules** (those whose disguises are most common in practice — `'use cache'`, parallel-fetching, dynamic-imports, server-action-forms, client-boundary, server-vs-client-fetching) include an extra concrete **"In disguise"** incorrect/correct example pair to teach pattern detection beyond the grep-friendly cases.

## When to Apply

- Writing new Next.js 16 App Router code
- **Auditing or modernizing a Next.js codebase** — single file, PR, or whole repo (see [`references/_review-algorithm.md`](references/_review-algorithm.md))
- Migrating from Next.js 15 to 16 (implicit caching → `'use cache'`, `middleware.ts` → `proxy.ts`, `revalidateTag` single-arg → with `cacheLife`)
- Configuring caching strategies with `'use cache'`, `unstable_cache`, `revalidateTag`, `revalidatePath`
- Implementing Server Components and parallel/colocated data fetching
- Setting up parallel routes, intercepting routes, prefetching, `proxy.ts`
- Creating Server Actions for form handling and mutations
- Tuning `'use client'` boundaries to minimize client bundle
- **Finding codebase-level issues** that single-file rules can't see: duplicated server fetchers, near-duplicate routes/layouts, dead routes, `'use client'` propagation across the route tree, prop-shape drift (see Category 9)

## How to Review or Refactor a Codebase

**When the user asks to review, refactor, modernize, or audit Next.js code — single file or whole repo — follow [`references/_review-algorithm.md`](references/_review-algorithm.md). Do not improvise.**

Four non-negotiables from that doc:

1. **Two modes — never refuse a whole-repo audit.** Pick **Mode A** (scoped, ≤~20 files) or **Mode B** (whole-tree: inventory pass + targeted sweeps + full Category 9).
2. **Judgment over grep.** Each rule names a *pattern shape*, not a syntactic marker. Read each rule's **Shapes to recognize** section before sweeping — grep finds the easy violations and misses the high-value ones (a layout marked `'use client'` for one button; TanStack Query fetching initial page data; a route handler doing the work of a Server Action; a hand-rolled cache layer mimicking `'use cache'`; sequential fetches hidden across parent/child Server Components).
3. **Category-major, not file-major — with forcing functions.** Sweep one category at a time across all in-scope files in priority order (CRITICAL → … → CROSS-CUTTING). The algorithm requires a **scope declaration**, **per-category progress lines**, and a final **coverage table** (category × file/bucket, cells ∈ `{clean, N findings, n/a}`). A missing category in the output is *immediately visible*.
4. **Codebase-level findings come from Category 9.** Single-file rules can't tell you "these two routes should be one" or "this server action is dead." Category 9 (Codebase Hygiene) sweeps the full inventory at the end and produces remove / dedup / reuse / consolidate findings.

Single-file ad-hoc questions ("is this caching strategy right?") can go straight to the relevant rule. The algorithm exists for the multi-file and whole-repo cases.

## Rule Categories

| # | Category | Impact | Rules | Key Topics |
|---|----------|--------|-------|------------|
| 1 | Build & Bundle Optimization | CRITICAL | 5 | Turbopack, optimizePackageImports, dynamic imports, barrel files, serverExternalPackages |
| 2 | Caching Strategy | CRITICAL | 6 | `'use cache'`, `revalidateTag`+cacheLife, fetch options, segment config |
| 3 | Server Components & Data Fetching | HIGH | 6 | Parallel fetching, streaming, colocation, preload, no-client-fetch, error handling |
| 4 | Routing & Navigation | HIGH | 5 | Parallel routes, intercepting routes, prefetching, `proxy.ts`, `notFound()` |
| 5 | Server Actions & Mutations | MEDIUM-HIGH | 5 | Server actions, useFormStatus, action-result errors, useOptimistic, revalidation |
| 6 | Streaming & Loading States | MEDIUM | 5 | Suspense placement, loading.tsx, error.tsx, skeleton matching, nested Suspense |
| 7 | Metadata & SEO | MEDIUM | 4 | generateMetadata, sitemap.ts, robots.ts, opengraph-image.tsx |
| 8 | Client Components | LOW-MEDIUM | 4 | `'use client'` boundary, children pattern, hydration mismatch, next/script |
| 9 | **Codebase Hygiene** | **LOW-MEDIUM** | **5** | **Dedup server fetchers, route consolidation, dead routes/actions, `'use client'` propagation, prop drift** |

## Quick Reference

**Critical patterns** — get these right first:
- Add `'use cache'` to Server Components/functions whose results should be cached (Next.js 16 dropped implicit fetch caching)
- Call `revalidateTag(tag, cacheLife)` with a profile — never the one-arg API
- Configure `optimizePackageImports` for icon/utility libraries with flat-export surfaces
- Don't disable Turbopack persistent caching
- Wrap `<form action={serverAction}>` instead of POST-to-`/api/...`

**Next.js 16 idioms (do NOT generate Next.js 15 patterns):**
- `proxy.ts` (Node runtime) — not `middleware.ts` (Edge)
- Explicit `'use cache'` — not implicit fetch caching
- `revalidateTag(tag, cacheLife)` — not single-arg `revalidateTag(tag)`
- Server Action + `useActionState` — not client `fetch` + `useState`
- `app/sitemap.ts` — not hand-maintained `public/sitemap.xml`

**Common single-file mistakes** — avoid these anti-patterns:
- Sequential `await` for independent data (use `Promise.all` or preload)
- `useEffect` + `fetch` in a Client Component for initial page data
- `'use client'` at the layout level for one interactive button
- Missing `revalidatePath`/`revalidateTag` after a mutating Server Action
- Skeletons that don't match content dimensions (CLS hit)

**Codebase-level patterns** — surface these in Category 9 sweeps:
- 2+ Server Components hitting the same upstream with drifting cache policies — **extract** to a shared cached fetcher
- 2+ near-duplicate routes/layouts that should be one with a variant or dynamic segment — **consolidate**
- Routes / route handlers / Server Actions with no inbound traffic for 90+ days — **delete** (after analytics check)
- `'use client'` propagating up the route tree because of one interactive leaf — **demote** layouts/parents to Server Components, leave a client island
- Same concept under different route-param/search-param/prop names — **converge** on a canonical name (watch out for SEO redirects)

## Table of Contents

1. [Build & Bundle Optimization](references/_sections.md#1-build--bundle-optimization) — **CRITICAL**
   - 1.1 [Import from the source module, not from a barrel `index.ts`](references/build-barrel-files.md) — CRITICAL (2-10x faster dev startup)
   - 1.2 [Declare package-flat-export libraries in `optimizePackageImports`](references/build-optimize-package-imports.md) — CRITICAL (200-800ms faster imports, 50-80% smaller bundles)
   - 1.3 [Mark Node packages with native bindings as `serverExternalPackages`](references/build-external-packages.md) — HIGH
   - 1.4 [Don't disable Turbopack's persistent caching](references/build-turbopack-config.md) — CRITICAL (5-10x faster cold starts)
   - 1.5 [Split heavy components into separately loaded chunks](references/build-dynamic-imports.md) — CRITICAL (30-70% smaller initial bundle)
2. [Caching Strategy](references/_sections.md#2-caching-strategy) — **CRITICAL**
   - 2.1 [Make every server `fetch` declare its caching intent](references/cache-fetch-options.md) — HIGH
   - 2.2 [Declare route-level caching via segment-config exports](references/cache-segment-config.md) — MEDIUM-HIGH
   - 2.3 [Mark cacheable Server Components/functions explicitly with `'use cache'`](references/cache-use-cache-directive.md) — CRITICAL
   - 2.4 [Call `revalidateTag(tag, cacheLife)` with a profile](references/cache-revalidate-tag.md) — CRITICAL
   - 2.5 [Every Server Action that mutates must invalidate the routes/tags that surface it](references/cache-revalidate-path.md) — HIGH
   - 2.6 [Wrap per-request fetchers with React `cache()` for dedup](references/cache-react-cache.md) — HIGH
3. [Server Components & Data Fetching](references/_sections.md#3-server-components--data-fetching) — **HIGH**
   - 3.1 [Independent server fetches run concurrently — sequential `await` is a waterfall](references/server-parallel-fetching.md) — HIGH
   - 3.2 [Wrap each independently-paced async leaf in its own `<Suspense>`](references/server-component-streaming.md) — HIGH
   - 3.3 [Each Server Component fetches the data it renders](references/server-data-colocation.md) — HIGH
   - 3.4 [Trigger critical data fetches at the top via a `preload` call](references/server-preload-pattern.md) — MEDIUM-HIGH
   - 3.5 [Initial page data lands in HTML via a Server Component — never `useEffect`+`fetch`](references/server-avoid-client-fetching.md) — MEDIUM-HIGH
   - 3.6 [Contain async failures via `error.tsx` or `ErrorBoundary`](references/server-error-handling.md) — MEDIUM
4. [Routing & Navigation](references/_sections.md#4-routing--navigation) — **HIGH**
   - 4.1 [Multi-region layouts use parallel-route slots](references/route-parallel-routes.md) — HIGH
   - 4.2 [Modal/lightbox detail views use intercepting routes](references/route-intercepting-routes.md) — HIGH
   - 4.3 [Tune `<Link prefetch>` to traffic likelihood](references/route-prefetching.md) — MEDIUM-HIGH
   - 4.4 [Network-boundary logic lives in `proxy.ts` — not `middleware.ts`](references/route-proxy-ts.md) — MEDIUM-HIGH
   - 4.5 [Missing dynamic resource calls `notFound()` for real HTTP 404](references/route-not-found.md) — MEDIUM
5. [Server Actions & Mutations](references/_sections.md#5-server-actions--mutations) — **MEDIUM-HIGH**
   - 5.1 [Mutations from forms run through Server Actions — not API routes + client `fetch`](references/action-server-action-forms.md) — MEDIUM-HIGH
   - 5.2 [Submit buttons read parent-form pending state from `useFormStatus`](references/action-pending-states.md) — MEDIUM-HIGH
   - 5.3 [Server Actions return a typed error/state result — never throw silently](references/action-error-handling.md) — MEDIUM-HIGH
   - 5.4 [Mutations with predictable UI outcomes apply optimistically](references/action-optimistic-updates.md) — MEDIUM
   - 5.5 [Every Server Action invalidates the routes/tags that surface its data](references/action-revalidation.md) — MEDIUM
6. [Streaming & Loading States](references/_sections.md#6-streaming--loading-states) — **MEDIUM**
   - 6.1 [Place Suspense around independently-paced subtrees](references/stream-suspense-boundaries.md) — MEDIUM
   - 6.2 [Every route has a `loading.tsx` adjacent to its `page.tsx`](references/stream-loading-tsx.md) — MEDIUM
   - 6.3 [Every route has an `error.tsx` next to it](references/stream-error-tsx.md) — MEDIUM
   - 6.4 [Skeletons match the dimensions of the content they replace](references/stream-skeleton-matching.md) — MEDIUM
   - 6.5 [Nest Suspense when content has a natural reveal order](references/stream-nested-suspense.md) — LOW-MEDIUM
7. [Metadata & SEO](references/_sections.md#7-metadata--seo) — **MEDIUM**
   - 7.1 [Dynamic routes export `generateMetadata` for per-resource SEO](references/meta-generate-metadata.md) — MEDIUM
   - 7.2 [Generate sitemaps from actual data — never hand-maintain XML](references/meta-sitemap.md) — MEDIUM
   - 7.3 [Make crawl rules explicit via `app/robots.ts` and per-page metadata](references/meta-robots.md) — MEDIUM
   - 7.4 [Generate per-page OG images via `opengraph-image.tsx`](references/meta-opengraph-images.md) — LOW-MEDIUM
8. [Client Components](references/_sections.md#8-client-components) — **LOW-MEDIUM**
   - 8.1 [Push `'use client'` down to the interactive leaf](references/client-use-client-boundary.md) — LOW-MEDIUM
   - 8.2 [Server content reaches inside a Client Component via `children`](references/client-children-pattern.md) — LOW-MEDIUM
   - 8.3 [SSR and client initial render must produce identical HTML](references/client-hydration-mismatch.md) — LOW-MEDIUM
   - 8.4 [Wrap third-party scripts in `next/script` with the right `strategy`](references/client-third-party-scripts.md) — LOW-MEDIUM
9. [Codebase Hygiene](references/_sections.md#9-codebase-hygiene) — **CROSS-CUTTING** (multi-file findings; required for whole-repo audits)
   - 9.1 [Extract duplicated server-side fetchers/actions into a shared module](references/cross-extract-shared-logic.md) — HIGH
   - 9.2 [Consolidate near-duplicate routes/layouts/components](references/cross-component-consolidation.md) — HIGH
   - 9.3 [Delete unreachable routes, unused Server Actions, orphan utilities](references/cross-dead-code.md) — MEDIUM-HIGH
   - 9.4 [Audit `'use client'` placement across the route tree](references/cross-boundary-coherence.md) — HIGH
   - 9.5 [Converge on canonical names for the same concept across routes/components](references/cross-prop-shape-drift.md) — MEDIUM-HIGH

## References

1. [Next.js Documentation](https://nextjs.org/docs)
2. [Next.js 16 Release Notes](https://nextjs.org/blog/next-16)
3. [React Documentation](https://react.dev)
4. [Vercel Engineering Blog](https://vercel.com/blog)

## Related Skills

- For React 19 fundamentals (concurrent rendering, hooks, components), see `react` skill
- For client-side form handling, see `react-hook-form` skill
- For client data caching with TanStack Query, see `tanstack-query` skill

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
