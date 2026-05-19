# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by lifecycle position and cascade effect. Problems at the
top (orchestration, cache keys) multiply downstream — getting them wrong creates
hundreds of redundant backend hits per user. Problems at the bottom (render
patterns, mutation invalidation) are localized and addable later.

## Impact tier definitions

Used by rule frontmatter and category headings:

| Tier | Meaning | When to assign |
|------|---------|----------------|
| **CRITICAL** | Cascades through all downstream operations; wrong here = self-inflicted outage or N× backend amplification | Multiplicative bugs (N+1 fan-out, missing concurrency cap, wrong cache key strategy) |
| **HIGH** | Affects a major user-visible path or backend budget; not multiplicative but compounding | Per-endpoint policy (debounce, timeout, retry-with-jitter), architectural choice (server-fetch, hydration) |
| **MEDIUM-HIGH** | Important for a specific scenario (long feeds, recommender carousels) but not universal | Domain-specific patterns: virtualization (only matters at scale), prefetch budgeting (only matters on slow networks), summary/detail split (only matters for carousels) |
| **MEDIUM** | Localized correctness or render efficiency; high frequency, contained blast radius | Per-component patterns: stable keys, scoped Suspense, optimistic mutations |
| **LOW-MEDIUM** | Micro-optimization on hot paths | Reserved for very specific hot loops; rarely used in this skill |
| **LOW** | Edge case or expert pattern | Reserved for niche scenarios; rarely used in this skill |

A rule's tier is independent of its category's tier — a CRITICAL category can contain HIGH or MEDIUM rules, and vice versa. The category tier reflects the *typical* severity of issues in that domain; individual rule tiers reflect the specific impact of each pattern.

---

## 1. Request Orchestration (orch)

**Impact:** CRITICAL  
**Description:** How concurrent fetches are coordinated — parallelism vs waterfalls, batching of N+1 fan-out, in-flight deduplication, and lifting fetches into route loaders. Wrong orchestration multiplies latency (sequential awaits) and multiplies backend load (every child component independently fetching). The single biggest source of backend overload from React apps.

## 2. Cache Strategy (cache)

**Impact:** CRITICAL  
**Description:** How fetched data is keyed, stored, and shared across components — deterministic cache keys, normalized graph cache for shared entities (the same product appearing in three carousels), stale-while-revalidate semantics, `staleTime`, and selector-scoped subscriptions. A bad key strategy creates a cache miss for every user; a flat cache forces N requests for the same entity reused N times.

## 3. Backend Protection (protect)

**Impact:** CRITICAL  
**Description:** Guardrails that prevent the client from overwhelming the backend — concurrency caps on fan-out, request collapsing for identical in-flight calls, debounce/throttle on user-driven triggers, and stampede protection (jittered retries, cache-warming locks). Without these, a refresh, a viral page, or a brief backend slowdown becomes a self-DDoS.

## 4. Prefetch & Hydration (prefetch)

**Impact:** HIGH  
**Description:** Eager fetching strategies that start requests before the component needs them — route loaders, hover/intent prefetch, idle-time and viewport-triggered prefetch, and server-rendered cache hydration. Done right, this shifts latency out of the user's critical path; done wrong, it doubles backend load by prefetching data the user never views.

## 5. Failure Resilience (resilience)

**Impact:** HIGH  
**Description:** Patterns that keep the app working when fetches fail — exponential backoff with jitter, circuit breakers, request cancellation via `AbortController`, scoped error boundaries, and stale-cache fallback. Naive retries turn transient blips into outages by hammering the recovering service; missing cancellation leaks completed requests after navigation.

## 6. Feed & Carousel Patterns (feed)

**Impact:** MEDIUM-HIGH  
**Description:** Patterns specific to feeds and recommender carousels at scale — virtualization, cursor-based pagination, infinite query dedup, splitting summary fetches from detail fetches, and viewport-triggered detail loading. These collapse hundreds of off-screen renders and hundreds of unviewed-item detail fetches into a bounded working set.

## 7. Mutation & Invalidation (mutate)

**Impact:** MEDIUM  
**Description:** How writes update the cache — optimistic updates with rollback, surgical invalidation (target specific keys, not entire trees), `setQueryData` instead of refetch when the result is known, and mutation idempotency. Wrong invalidation triggers an avalanche of refetches; over-aggressive invalidation defeats the cache.

## 8. Component Patterns (render)

**Impact:** MEDIUM  
**Description:** Component-level patterns that prevent render-driven re-fetches — stable query keys, scoped Suspense boundaries, fan-out caps inside `map()`, selector hooks that subscribe to only the rendered fields, and co-locating queries near the components that consume them. These collapse re-render storms and prevent components from accidentally refetching on every parent update.
