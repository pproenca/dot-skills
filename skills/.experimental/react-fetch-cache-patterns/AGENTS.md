# React Data Fetching & Caching

**Version 0.1.0**  
Experimental  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Implementation patterns for React applications that fetch and cache many API requests without overwhelming the backend. 48 rules across 8 categories ordered by execution lifecycle impact: Request Orchestration (parallelism, batching, deduplication, route loaders), Cache Strategy (deterministic keys, normalization, staleTime, stale-while-revalidate, key factories, tiered freshness), Backend Protection (concurrency caps, request collapsing, debounce/throttle, jittered retries, circuit breakers, rate-limit awareness), Prefetch & Hydration (hover/intent prefetch, parallel loader queries, server hydration, idle prefetch, viewport-triggered, budget tiers), Failure Resilience (AbortController, bounded timeouts, scoped error boundaries, stale fallback, mutation idempotency, graceful degradation), Feed & Carousel Patterns (virtualization, cursor pagination, summary/detail split, multi-carousel failure isolation, stable keys, lazy images, bounded working set), Mutation & Invalidation (optimistic updates with rollback, surgical invalidation, setQueryData, cancel-on-mutate), and Component Patterns (stable query keys, fan-out caps, Suspense per section, colocation). Bundled with 6 scaffolding templates including both library-based (TanStack Query) and library-free (pure React + AbortController) implementations: resource query hook, no-deps resource query hook, carousel data loader (single + multi-carousel feed with failure isolation), infinite feed, prefetch link, request collapser.

---

## Table of Contents

1. [Request Orchestration](references/_sections.md#1-request-orchestration) — **CRITICAL**
   - 1.1 [Avoid useEffect Fetch Chains](references/orch-avoid-effect-chains.md) — CRITICAL (prevents render-fetch-render-fetch waterfalls)
   - 1.2 [Batch N+1 Fan-Out with DataLoader Pattern](references/orch-batch-n-plus-one-fanout.md) — CRITICAL (reduces N requests to 1)
   - 1.3 [Deduplicate In-Flight Requests by Key](references/orch-dedupe-in-flight-requests.md) — CRITICAL (reduces M concurrent calls to 1)
   - 1.4 [Lift Fetches into Route Loaders](references/orch-lift-fetch-to-route-loader.md) — CRITICAL (200-800ms saved on route entry)
   - 1.5 [Move Fetches to the Server When Possible](references/orch-server-fetch-when-possible.md) — HIGH (eliminates client-side round-trip + JS payload)
   - 1.6 [Parallelize Independent Fetches](references/orch-parallelize-independent-fetches.md) — CRITICAL (eliminates N-1 sequential round-trips)
   - 1.7 [Prefer a Bulk Endpoint over N Parallel Endpoints](references/orch-prefer-bulk-endpoint-for-fanout.md) — CRITICAL (reduces N round-trips to 1)
2. [Cache Strategy](references/_sections.md#2-cache-strategy) — **CRITICAL**
   - 2.1 [Build Deterministic Cache Keys](references/cache-deterministic-keys.md) — CRITICAL (prevents accidental cache misses on every render)
   - 2.2 [Centralize Cache Keys in a Key Factory](references/cache-shared-key-factory.md) — CRITICAL (prevents read/write key drift)
   - 2.3 [Normalize Shared Entities Across Views](references/cache-normalize-shared-entities.md) — CRITICAL (N-fold cache size reduction for shared entities)
   - 2.4 [Set staleTime to Suppress Redundant Refetches](references/cache-set-stale-time.md) — CRITICAL (5-50x reduction in refetch rate)
   - 2.5 [Tier staleTime by Data Volatility](references/cache-tiered-stale-fresh.md) — HIGH (reduces stale-data refetches 10-100×)
   - 2.6 [Use select to Subscribe to a Subset of Cache Data](references/cache-select-subscribed-fields.md) — CRITICAL (5-20x reduction in re-render rate)
   - 2.7 [Use Stale-While-Revalidate for Instant Renders](references/cache-stale-while-revalidate.md) — CRITICAL (0ms perceived wait for cached data)
3. [Backend Protection](references/_sections.md#3-backend-protection) — **CRITICAL**
   - 3.1 [Add Jitter to Retry Backoff](references/protect-jittered-retry-backoff.md) — CRITICAL (prevents thundering-herd recovery)
   - 3.2 [Cap Concurrency on Client-Side Fan-Out](references/protect-concurrency-limit-fanout.md) — CRITICAL (prevents browser connection exhaustion + backend overload)
   - 3.3 [Collapse Identical Requests at the Fetch Layer](references/protect-collapse-identical-requests.md) — HIGH (prevents auth-refresh storms and retry-original races)
   - 3.4 [Debounce User-Driven Fetches](references/protect-debounce-user-driven-fetches.md) — HIGH (10-30× reduction in search/filter requests)
   - 3.5 [Honor Server Rate-Limit Headers Client-Side](references/protect-rate-limit-aware-client.md) — HIGH (prevents 429 retry loops + ban risk)
   - 3.6 [Throttle Scroll-Triggered Fetches](references/protect-throttle-scroll-triggered.md) — HIGH (reduces 60Hz event firing to 4-10Hz fetches)
   - 3.7 [Use Circuit Breakers on Persistently Failing Endpoints](references/protect-circuit-breaker.md) — HIGH (prevents retry storms on persistent failure)
4. [Prefetch & Hydration](references/_sections.md#4-prefetch-&-hydration) — **HIGH**
   - 4.1 [Bound Prefetch Bandwidth by Priority Tier](references/prefetch-budget-and-priority.md) — MEDIUM-HIGH (prevents prefetch from competing with critical fetches)
   - 4.2 [Hydrate the Client Cache from Server-Rendered Data](references/prefetch-hydrate-server-cache.md) — HIGH (eliminates first-fetch on cached entities)
   - 4.3 [Prefetch Likely-Next Data on Idle](references/prefetch-idle-likely-next.md) — MEDIUM-HIGH (maintains instant transitions for predictable paths)
   - 4.4 [Prefetch Links on Hover and Intent](references/prefetch-hover-intent-links.md) — HIGH (100-300ms faster perceived navigation)
   - 4.5 [Prefetch the Next Page Before the Sentinel Hits Viewport](references/prefetch-viewport-triggered-next-page.md) — HIGH (eliminates loading-more spinners in feeds)
   - 4.6 [Run Route Loader Queries in Parallel](references/prefetch-parallel-loader-queries.md) — HIGH (reduces N sequential awaits to 1 round-trip)
5. [Failure Resilience](references/_sections.md#5-failure-resilience) — **HIGH**
   - 5.1 [Abort Requests on Unmount or Navigation](references/resilience-abort-on-unmount.md) — HIGH (prevents stale-response races and memory leaks)
   - 5.2 [Avoid Auto-Retrying Non-Idempotent Mutations](references/resilience-no-auto-retry-mutations.md) — HIGH (prevents double-charging, duplicate posts, double sends)
   - 5.3 [Bound Request Timeouts per Endpoint Class](references/resilience-bounded-timeouts.md) — HIGH (prevents indefinite hangs on degraded backends)
   - 5.4 [Fall Back to Stale Cache When Fresh Fetch Fails](references/resilience-stale-fallback.md) — HIGH (prevents temporary outages from becoming visible errors)
   - 5.5 [Gracefully Degrade Non-Critical Sections](references/resilience-graceful-degradation.md) — MEDIUM-HIGH (preserves core flow when peripheral data fails)
   - 5.6 [Scope Error Boundaries to Data Sections](references/resilience-scoped-error-boundaries.md) — HIGH (prevents one fetch failure from breaking the entire page)
6. [Feed & Carousel Patterns](references/_sections.md#6-feed-&-carousel-patterns) — **MEDIUM-HIGH**
   - 6.1 [Bound the In-Memory Working Set on Long Feeds](references/feed-bounded-working-set.md) — MEDIUM-HIGH (prevents unbounded memory growth on infinite scroll)
   - 6.2 [Defer Off-Screen Feed Images with Explicit Dimensions](references/feed-image-lazy-and-sized.md) — MEDIUM-HIGH (prevents layout shift and saves 70-90% image bandwidth)
   - 6.3 [Isolate Failure Across a Feed of Carousels](references/feed-multi-carousel-isolation.md) — MEDIUM-HIGH (prevents one failing carousel from breaking the homepage)
   - 6.4 [Split Carousel Summaries from Item Details](references/feed-split-summary-from-detail.md) — MEDIUM-HIGH (reduces initial carousel payload 5-20×)
   - 6.5 [Use Cursor Pagination over Offset](references/feed-cursor-pagination.md) — MEDIUM-HIGH (prevents skip/duplicate items as the list shifts)
   - 6.6 [Use Stable Item Keys Across Paginated Pages](references/feed-stable-keys-across-pages.md) — MEDIUM (prevents full-list re-render on each new page)
   - 6.7 [Virtualize Long Lists Beyond ~50 Items](references/feed-virtualize-long-lists.md) — MEDIUM-HIGH (10-100× fewer DOM nodes)
7. [Mutation & Invalidation](references/_sections.md#7-mutation-&-invalidation) — **MEDIUM**
   - 7.1 [Apply Optimistic Updates with Rollback on Failure](references/mutate-optimistic-updates-with-rollback.md) — MEDIUM (eliminates 200-800ms perceived mutation latency)
   - 7.2 [Cancel In-Flight Queries Before Mutating Their Cache](references/mutate-cancel-queries-on-mutate.md) — MEDIUM (prevents race conditions between mutation and refetch)
   - 7.3 [Invalidate Surgically, Not Globally](references/mutate-surgical-invalidation.md) — MEDIUM (reduces post-mutation refetch storms 10-100×)
   - 7.4 [Use setQueryData over Invalidate When the Result is Known](references/mutate-set-data-over-invalidate.md) — MEDIUM (eliminates 1 refetch per mutation)
8. [Component Patterns](references/_sections.md#8-component-patterns) — **MEDIUM**
   - 8.1 [Cap Fan-Out of Queries Inside Lists](references/render-cap-fanout-in-lists.md) — MEDIUM (prevents unbounded query fan-out as lists grow)
   - 8.2 [Colocate Fetches with Their Consumers](references/render-colocate-fetch-with-consumer.md) — MEDIUM (prevents prop drilling and unnecessary re-renders up the tree)
   - 8.3 [Place Suspense Boundaries Per Logical Section](references/render-suspense-per-section.md) — MEDIUM (enables independent streaming of data sections)
   - 8.4 [Stabilize Object-Shaped Query Keys](references/render-stable-query-keys.md) — MEDIUM (prevents new fetch on every parent render)

---

## References

1. [https://react.dev/reference/react/Suspense](https://react.dev/reference/react/Suspense)
2. [https://tanstack.com/query/latest/docs/framework/react/overview](https://tanstack.com/query/latest/docs/framework/react/overview)
3. [https://swr.vercel.app/](https://swr.vercel.app/)
4. [https://nextjs.org/docs/app/building-your-application/data-fetching](https://nextjs.org/docs/app/building-your-application/data-fetching)
5. [https://tanstack.com/router/latest/docs/framework/react/guide/data-loading](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading)
6. [https://tanstack.com/virtual/latest](https://tanstack.com/virtual/latest)
7. [https://vercel.com/blog/everything-about-data-fetching-in-nextjs](https://vercel.com/blog/everything-about-data-fetching-in-nextjs)
8. [https://github.com/graphql/dataloader](https://github.com/graphql/dataloader)
9. [https://developer.mozilla.org/en-US/docs/Web/API/AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)
10. [https://datatracker.ietf.org/doc/html/rfc5861](https://datatracker.ietf.org/doc/html/rfc5861)
11. [https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
12. [https://tkdodo.eu/blog/practical-react-query](https://tkdodo.eu/blog/practical-react-query)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |