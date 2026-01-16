# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Network Waterfalls & Data Fetching (async)

**Impact:** CRITICAL
**Description:** Eliminates request waterfalls and cascading fetches that multiply latency; a single waterfall can add 600ms+ of waiting time that no amount of component optimization can recover.

## 2. Bundle Size & Code Splitting (bundle)

**Impact:** CRITICAL
**Description:** Reduces JavaScript payload sent to clients; every 100KB of unoptimized JS adds 1-2 seconds on mobile networks, and barrel file imports can silently bundle 10,000+ unused exports.

## 3. Server vs Client Component Boundaries (server)

**Impact:** HIGH
**Description:** Ensures computation happens server-side by default, reducing client JS to zero for non-interactive content; misplacing 'use client' can inflate bundles by 250KB+ and expose secrets.

## 4. Client-Side Data & State (client)

**Impact:** HIGH
**Description:** Optimizes interactive client components for minimal re-renders and efficient state management; poorly structured client state causes cascade re-renders affecting perceived performance.

## 5. Rendering Strategy Selection (render)

**Impact:** MEDIUM-HIGH
**Description:** Chooses between static, dynamic, and streaming rendering based on data requirements; static pages serve in 0-50ms from CDN while dynamic rendering adds 200-1000ms per request.

## 6. Caching & Revalidation (cache)

**Impact:** MEDIUM
**Description:** Implements time-based and on-demand cache invalidation strategies; proper caching can serve millions of requests from edge cache while improper caching causes stale data or unnecessary origin hits.

## 7. Routing & Navigation (route)

**Impact:** MEDIUM
**Description:** Leverages Next.js Link prefetching, loading states, and route organization for instant navigation; proper prefetching achieves 50-200ms navigations vs 500ms+ without it.

## 8. Advanced Patterns & Security (advanced)

**Impact:** LOW-MEDIUM
**Description:** Covers authentication patterns, middleware usage, image/font optimization, and error boundaries; these patterns round out production-ready applications with proper security and UX polish.
