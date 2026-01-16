# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Async Data Fetching (async)

**Impact:** CRITICAL
**Description:** Waterfalls are the #1 performance killer. Each sequential await adds full network latency, multiplying total request time.

## 2. Bundle Optimization (bundle)

**Impact:** CRITICAL
**Description:** Initial bundle size directly impacts Time to Interactive and Largest Contentful Paint. Smaller bundles mean faster hydration.

## 3. Server Components (server)

**Impact:** HIGH
**Description:** RSC boundary placement and data flow patterns determine how much JavaScript ships to the client and when content becomes interactive.

## 4. Caching Strategies (cache)

**Impact:** HIGH
**Description:** Proper use of fetch caching, unstable_cache, and revalidation eliminates redundant requests and reduces server load.

## 5. Rendering Patterns (render)

**Impact:** MEDIUM
**Description:** Choosing static vs dynamic rendering and using generateStaticParams affects Time to First Byte and edge cacheability.

## 6. Route Architecture (route)

**Impact:** MEDIUM
**Description:** Layout composition, parallel routes, and Link prefetching strategies impact navigation performance and code organization.

## 7. Client Components (client)

**Impact:** MEDIUM
**Description:** Hydration boundary placement, state management patterns, and event handlers affect client-side interactivity and bundle size.

## 8. Advanced Patterns (advanced)

**Impact:** LOW
**Description:** Middleware optimization, metadata generation, image and font loading provide incremental performance gains.
