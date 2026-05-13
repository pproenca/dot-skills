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

## 9. Codebase Hygiene (cross)

**Impact:** LOW-MEDIUM
**Description:** Cross-cutting findings that only surface across files: duplicated server-side fetchers/actions that should be a shared module, near-duplicate routes/layouts that should be one, unused route files/server actions/components, `'use client'` files (or parent layouts) that don't need client execution, and same-concept-different-name prop drift across server boundaries. The category sits at LOW-MEDIUM **as a baseline urgency** because most well-maintained codebases are clean here; the *individual rule impacts* within are calibrated separately (extract-shared-logic and route consolidation are HIGH when they fire, dead-code and boundary-coherence are MEDIUM-HIGH, etc.). These rules use a multi-file format alongside the standard single-file Incorrect/Correct shape, and run as a final sweep after Categories 1–8 in the review algorithm. Required for any whole-repo audit — single-file rule sweeps cannot, by construction, produce these findings.
