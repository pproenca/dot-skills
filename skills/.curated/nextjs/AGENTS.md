# Next.js 16 App Router

**Version 0.1.0**  
Next.js Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Next.js 16 App Router applications, designed for AI agents and LLMs. Contains 40+ rules across 8 categories, prioritized by impact from critical (build optimization, caching strategy) to incremental (client components). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Build & Bundle Optimization](references/_sections.md#1-build-&-bundle-optimization) — **CRITICAL**
   - 1.1 [Avoid Barrel File Imports in App Router](references/build-barrel-files.md) — CRITICAL (2-10× faster dev startup)
   - 1.2 [Configure optimizePackageImports for Icon Libraries](references/build-optimize-package-imports.md) — CRITICAL (200-800ms faster imports, 50-80% smaller bundles)
   - 1.3 [Configure Server External Packages for Node Dependencies](references/build-external-packages.md) — HIGH (prevents bundling issues, faster builds)
   - 1.4 [Enable Turbopack File System Caching](references/build-turbopack-config.md) — CRITICAL (5-10× faster cold starts on large apps)
   - 1.5 [Use Dynamic Imports for Heavy Components](references/build-dynamic-imports.md) — CRITICAL (30-70% smaller initial bundle)
2. [Caching Strategy](references/_sections.md#2-caching-strategy) — **CRITICAL**
   - 2.1 [Configure Fetch Cache Options Correctly](references/cache-fetch-options.md) — HIGH (controls data freshness per request)
   - 2.2 [Configure Route Segment Caching with Exports](references/cache-segment-config.md) — MEDIUM-HIGH (controls caching at route level)
   - 2.3 [Use React cache() for Request Deduplication](references/cache-react-cache.md) — HIGH (eliminates duplicate fetches per request)
   - 2.4 [Use revalidatePath for Route-Level Cache Invalidation](references/cache-revalidate-path.md) — HIGH (invalidates all cached data for a route)
   - 2.5 [Use revalidateTag with cacheLife Profiles](references/cache-revalidate-tag.md) — CRITICAL (stale-while-revalidate behavior, instant updates)
   - 2.6 [Use the 'use cache' Directive for Explicit Caching](references/cache-use-cache-directive.md) — CRITICAL (eliminates implicit caching confusion, explicit control)
3. [Server Components & Data Fetching](references/_sections.md#3-server-components-&-data-fetching) — **HIGH**
   - 3.1 [Avoid Client-Side Data Fetching for Initial Data](references/server-avoid-client-fetching.md) — MEDIUM-HIGH (eliminates client waterfalls, better SEO)
   - 3.2 [Colocate Data Fetching with Components](references/server-data-colocation.md) — HIGH (eliminates prop drilling, enables streaming)
   - 3.3 [Fetch Data in Parallel in Server Components](references/server-parallel-fetching.md) — HIGH (eliminates server-side waterfalls, 2-5× faster)
   - 3.4 [Handle Server Component Errors Gracefully](references/server-error-handling.md) — MEDIUM (prevents full page crashes, better UX)
   - 3.5 [Stream Server Components for Progressive Loading](references/server-component-streaming.md) — HIGH (faster Time to First Byte, progressive rendering)
   - 3.6 [Use Preload Pattern for Critical Data](references/server-preload-pattern.md) — MEDIUM-HIGH (starts fetches earlier in render tree)
4. [Routing & Navigation](references/_sections.md#4-routing-&-navigation) — **HIGH**
   - 4.1 [Configure Link Prefetching Appropriately](references/route-prefetching.md) — MEDIUM-HIGH (instant navigation for likely destinations)
   - 4.2 [Use Intercepting Routes for Modal Patterns](references/route-intercepting-routes.md) — HIGH (enables shareable modal URLs, better UX)
   - 4.3 [Use notFound() for Missing Resources](references/route-not-found.md) — MEDIUM (proper 404 handling, better SEO)
   - 4.4 [Use Parallel Routes for Independent Content](references/route-parallel-routes.md) — HIGH (independent loading, streaming, error handling)
   - 4.5 [Use proxy.ts for Network Boundary Logic](references/route-proxy-ts.md) — MEDIUM-HIGH (clearer network boundary, Node.js runtime)
5. [Server Actions & Mutations](references/_sections.md#5-server-actions-&-mutations) — **MEDIUM-HIGH**
   - 5.1 [Handle Server Action Errors Gracefully](references/action-error-handling.md) — MEDIUM-HIGH (prevents silent failures, better error UX)
   - 5.2 [Revalidate Cache After Mutations](references/action-revalidation.md) — MEDIUM (ensures fresh data after changes)
   - 5.3 [Show Pending States with useFormStatus](references/action-pending-states.md) — MEDIUM-HIGH (better UX during form submission)
   - 5.4 [Use Optimistic Updates for Instant Feedback](references/action-optimistic-updates.md) — MEDIUM (instant UI response, better perceived performance)
   - 5.5 [Use Server Actions for Form Submissions](references/action-server-action-forms.md) — MEDIUM-HIGH (eliminates API routes, type-safe mutations)
6. [Streaming & Loading States](references/_sections.md#6-streaming-&-loading-states) — **MEDIUM**
   - 6.1 [Match Skeleton Dimensions to Actual Content](references/stream-skeleton-matching.md) — MEDIUM (prevents layout shift, better CLS score)
   - 6.2 [Nest Suspense for Progressive Disclosure](references/stream-nested-suspense.md) — LOW-MEDIUM (fine-grained loading control, better UX)
   - 6.3 [Place Suspense Boundaries Strategically](references/stream-suspense-boundaries.md) — MEDIUM (faster perceived performance, progressive loading)
   - 6.4 [Use error.tsx for Route-Level Error Boundaries](references/stream-error-tsx.md) — MEDIUM (graceful error recovery, prevents full page crashes)
   - 6.5 [Use loading.tsx for Route-Level Loading States](references/stream-loading-tsx.md) — MEDIUM (automatic loading UI, instant navigation feedback)
7. [Metadata & SEO](references/_sections.md#7-metadata-&-seo) — **MEDIUM**
   - 7.1 [Configure Robots for Crawl Control](references/meta-robots.md) — MEDIUM (prevents indexing of private pages)
   - 7.2 [Generate Dynamic OpenGraph Images](references/meta-opengraph-images.md) — LOW-MEDIUM (better social sharing, higher CTR)
   - 7.3 [Generate Sitemaps Dynamically](references/meta-sitemap.md) — MEDIUM (improved crawlability, faster indexing)
   - 7.4 [Use generateMetadata for Dynamic Metadata](references/meta-generate-metadata.md) — MEDIUM (dynamic SEO, social sharing optimization)
8. [Client Components](references/_sections.md#8-client-components) — **LOW-MEDIUM**
   - 8.1 [Avoid Hydration Mismatches](references/client-hydration-mismatch.md) — LOW-MEDIUM (prevents React warnings, ensures correct rendering)
   - 8.2 [Load Third-Party Scripts Efficiently](references/client-third-party-scripts.md) — LOW-MEDIUM (prevents blocking, improves LCP)
   - 8.3 [Minimize 'use client' Boundary Scope](references/client-use-client-boundary.md) — LOW-MEDIUM (reduces client JS, better performance)
   - 8.4 [Pass Server Components as Children to Client Components](references/client-children-pattern.md) — LOW-MEDIUM (keeps static content on server, reduces bundle)

---

## References

1. [https://nextjs.org/docs](https://nextjs.org/docs)
2. [https://nextjs.org/blog/next-16](https://nextjs.org/blog/next-16)
3. [https://react.dev](https://react.dev)
4. [https://vercel.com/blog](https://vercel.com/blog)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |