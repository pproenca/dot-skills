# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Build & Bundle Optimization (build)

**Impact:** CRITICAL
**Description:** Turbopack configuration, optimizePackageImports, and dynamic imports reduce cold start times and bundle size by up to 70%.

## 2. Caching Strategy (cache)

**Impact:** CRITICAL
**Description:** The 'use cache' directive, revalidateTag, and cacheLife profiles control data freshness and reduce server load by eliminating redundant fetches.

## 3. Server Components & Data Fetching (server)

**Impact:** HIGH
**Description:** Parallel fetching, React cache(), and streaming patterns eliminate server-side waterfalls and reduce Time to First Byte.

## 4. Routing & Navigation (route)

**Impact:** HIGH
**Description:** Parallel routes, intercepting routes, prefetching, and proxy.ts optimize navigation performance and user experience.

## 5. Server Actions & Mutations (action)

**Impact:** MEDIUM-HIGH
**Description:** Form handling, revalidatePath, and redirect patterns enable secure, performant data mutations with proper cache invalidation.

## 6. Streaming & Loading States (stream)

**Impact:** MEDIUM
**Description:** Strategic Suspense boundaries, loading.tsx, and error.tsx enable progressive rendering and faster perceived performance.

## 7. Metadata & SEO (meta)

**Impact:** MEDIUM
**Description:** generateMetadata, sitemap generation, and OpenGraph optimization improve search visibility and social sharing.

## 8. Client Components (client)

**Impact:** LOW-MEDIUM
**Description:** Proper 'use client' boundaries and hydration optimization minimize client-side JavaScript and improve interactivity.
