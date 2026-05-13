# Next.js 16 App Router

**Version 1.0.3**
Next.js Community
January 2026

> **Note:**
> This Next.js 16 App Router guide is mainly for agents and LLMs to follow when
> maintaining, generating, or refactoring Next.js codebases. Humans may also
> find it useful, but guidance here is optimized for automation and consistency
> by AI-assisted workflows.

---

## Abstract

Comprehensive Next.js 16 App Router guide for AI agents and LLMs. Contains **45 rules across 9 categories**, prioritized by impact from critical (build optimization, caching strategy) through to cross-cutting codebase hygiene (dedup, dead routes, boundary coherence). Reflects Next.js 16 changes: `'use cache'` directive (no implicit caching), `revalidateTag(tag, cacheLife)` requirement, `proxy.ts` replacing `middleware.ts`, Turbopack persistent caching.

Rule files describe **pattern shapes** rather than API names and open with a **"Shapes to recognize"** section listing 2–4 syntactic disguises the same break can wear. Selected high-value rules (where pattern-disguise is most common in practice) include a concrete **"In disguise"** incorrect/correct example pair.

The skill ships a category-major **review/refactor algorithm** ([`references/_review-algorithm.md`](references/_review-algorithm.md)) with two modes (scoped vs whole-repo) and required forcing functions: scope declaration, per-category progress lines, and a coverage table that makes silent category skipping immediately visible.

---

## Table of Contents

1. [Build & Bundle Optimization](references/_sections.md#1-build--bundle-optimization) — **CRITICAL**
   - 1.1 [Import from the source module, not from a barrel `index.ts`](references/build-barrel-files.md) — CRITICAL
   - 1.2 [Declare package-flat-export libraries in `optimizePackageImports`](references/build-optimize-package-imports.md) — CRITICAL
   - 1.3 [Mark Node packages with native bindings as `serverExternalPackages`](references/build-external-packages.md) — HIGH
   - 1.4 [Don't disable Turbopack's persistent caching](references/build-turbopack-config.md) — CRITICAL
   - 1.5 [Split heavy components into separately loaded chunks](references/build-dynamic-imports.md) — CRITICAL
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
   - 3.5 [Initial page data lands in HTML via a Server Component](references/server-avoid-client-fetching.md) — MEDIUM-HIGH
   - 3.6 [Contain async failures via `error.tsx` or `ErrorBoundary`](references/server-error-handling.md) — MEDIUM
4. [Routing & Navigation](references/_sections.md#4-routing--navigation) — **HIGH**
   - 4.1 [Multi-region layouts use parallel-route slots](references/route-parallel-routes.md) — HIGH
   - 4.2 [Modal/lightbox detail views use intercepting routes](references/route-intercepting-routes.md) — HIGH
   - 4.3 [Tune `<Link prefetch>` to traffic likelihood](references/route-prefetching.md) — MEDIUM-HIGH
   - 4.4 [Network-boundary logic lives in `proxy.ts` — not `middleware.ts`](references/route-proxy-ts.md) — MEDIUM-HIGH
   - 4.5 [Missing dynamic resource calls `notFound()` for real HTTP 404](references/route-not-found.md) — MEDIUM
5. [Server Actions & Mutations](references/_sections.md#5-server-actions--mutations) — **MEDIUM-HIGH**
   - 5.1 [Mutations from forms run through Server Actions](references/action-server-action-forms.md) — MEDIUM-HIGH
   - 5.2 [Submit buttons read parent-form pending state from `useFormStatus`](references/action-pending-states.md) — MEDIUM-HIGH
   - 5.3 [Server Actions return a typed error/state result](references/action-error-handling.md) — MEDIUM-HIGH
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
   - 7.2 [Generate sitemaps from actual data](references/meta-sitemap.md) — MEDIUM
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

---

## References

1. [Next.js Documentation](https://nextjs.org/docs)
2. [Next.js 16 Release Notes](https://nextjs.org/blog/next-16)
3. [React Documentation](https://react.dev)
4. [Vercel Engineering Blog](https://vercel.com/blog)
