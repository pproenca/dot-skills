# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Query Key Structure (tquery)

**Impact:** CRITICAL
**Description:** Query key structure cascades through cache lookups, invalidation patterns, and request deduplication—wrong structure means broken cache management.

## 2. Caching Configuration (cache)

**Impact:** CRITICAL
**Description:** Misconfigured staleTime/gcTime causes unnecessary refetches (waterfalls) or stale data display—the most common TanStack Query mistakes.

## 3. Mutation Patterns (mutation)

**Impact:** HIGH
**Description:** Mutation callbacks (onMutate, onError, onSettled) coordinate optimistic updates, rollback, and cache invalidation for responsive UX.

## 4. Prefetching & Waterfalls (prefetch)

**Impact:** HIGH
**Description:** Request waterfalls multiply latency—prefetching and query hoisting parallelize data fetching for faster page loads.

## 5. Infinite Queries (infinite)

**Impact:** MEDIUM
**Description:** Infinite query memory grows unbounded without maxPages, and refetching all pages serially causes performance degradation.

## 6. Suspense Integration (suspense)

**Impact:** MEDIUM
**Description:** Suspense hooks simplify loading states but require proper error boundaries and understanding of data availability guarantees.

## 7. Error & Retry Handling (error)

**Impact:** MEDIUM
**Description:** Retry configuration determines user experience during transient failures—wrong defaults waste time or hide real errors.

## 8. Render Optimization (render)

**Impact:** LOW-MEDIUM
**Description:** Select functions, notifyOnChangeProps, and structural sharing reduce unnecessary re-renders in high-frequency update scenarios.
