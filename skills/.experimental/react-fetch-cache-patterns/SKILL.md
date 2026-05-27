---
name: react-fetch-cache-patterns
description: React data-fetching patterns at scale — recommender carousels, infinite feeds, pages with many parallel fetches, dashboards. Covers request orchestration (parallelism, batching, deduplication), cache strategy (keys, normalization, staleTime, SWR), backend protection (concurrency caps, debounce/throttle, jittered retries, circuit breakers), prefetching (route loaders, hover/intent, idle, server hydration), failure resilience (AbortController, timeouts, error boundaries, stale fallback, idempotent mutations), and feed/carousel patterns (virtualization, cursor pagination, summary/detail split). Includes 5 ready-to-use scaffolding templates (resource query hook, carousel data loader, infinite feed, hover-prefetch link, request collapser). Trigger when building, reviewing, or refactoring React components that fetch data — even if the user doesn't explicitly mention "performance" or "scale".
---
# Experimental React Data Fetching & Caching Best Practices

Implementation patterns for React applications that fetch and cache many API requests without overwhelming the backend. **48 rules across 8 categories**, ordered by execution lifecycle impact — earlier categories cascade through everything downstream. Templates show both library-based (TanStack Query, SWR) **and library-free** (pure React + AbortController) implementations so the patterns are usable regardless of stack constraints.

## When to Apply

- Writing or reviewing a React component that calls `fetch`, `useQuery`, `useSWR`, or any data-fetching hook
- Designing a list, feed, or carousel that displays many items each requiring data
- Investigating "the backend is getting hammered" or "the page loads slowly" symptoms
- Choosing between client-side fetching, route loaders, server components, or SSR
- Implementing prefetch, retry, optimistic updates, or any failure-handling logic
- Refactoring code that already does data fetching but with waterfalls, no cache strategy, or no concurrency limits

## Rule Categories by Priority

| # | Category | Impact | Prefix | Rules |
|---|----------|--------|--------|-------|
| 1 | Request Orchestration | CRITICAL | `orch-` | 7 |
| 2 | Cache Strategy | CRITICAL | `cache-` | 7 |
| 3 | Backend Protection | CRITICAL | `protect-` | 7 |
| 4 | Prefetch & Hydration | HIGH | `prefetch-` | 6 |
| 5 | Failure Resilience | HIGH | `resilience-` | 6 |
| 6 | Feed & Carousel Patterns | MEDIUM-HIGH | `feed-` | 7 |
| 7 | Mutation & Invalidation | MEDIUM | `mutate-` | 4 |
| 8 | Component Patterns | MEDIUM | `render-` | 4 |

## Quick Reference

### 1. Request Orchestration (CRITICAL)

- [`orch-parallelize-independent-fetches`](references/orch-parallelize-independent-fetches.md) — Use `Promise.all` for independent requests; never serial `await`
- [`orch-batch-n-plus-one-fanout`](references/orch-batch-n-plus-one-fanout.md) — Collapse per-row fetches via DataLoader-style batching
- [`orch-dedupe-in-flight-requests`](references/orch-dedupe-in-flight-requests.md) — One in-flight request per key, shared across subscribers
- [`orch-lift-fetch-to-route-loader`](references/orch-lift-fetch-to-route-loader.md) — Fetch in parallel with route chunk download
- [`orch-avoid-effect-chains`](references/orch-avoid-effect-chains.md) — Flatten the dependency graph; only true dependencies wait
- [`orch-server-fetch-when-possible`](references/orch-server-fetch-when-possible.md) — Move fetches to RSC/server when they don't depend on client state
- [`orch-prefer-bulk-endpoint-for-fanout`](references/orch-prefer-bulk-endpoint-for-fanout.md) — One bulk request beats N parallel requests

### 2. Cache Strategy (CRITICAL)

- [`cache-deterministic-keys`](references/cache-deterministic-keys.md) — Canonicalize cache keys; strip undefined, sort arrays
- [`cache-normalize-shared-entities`](references/cache-normalize-shared-entities.md) — Store each entity once; views hold references
- [`cache-set-stale-time`](references/cache-set-stale-time.md) — Tune `staleTime` to data volatility, not refresh frequency
- [`cache-stale-while-revalidate`](references/cache-stale-while-revalidate.md) — Render stale instantly; revalidate in background
- [`cache-select-subscribed-fields`](references/cache-select-subscribed-fields.md) — Subscribe to slices, not whole objects
- [`cache-shared-key-factory`](references/cache-shared-key-factory.md) — One typed source of truth for keys; prevents read/write drift
- [`cache-tiered-stale-fresh`](references/cache-tiered-stale-fresh.md) — Different `staleTime` per data class (realtime, fresh, warm, cold, static)

### 3. Backend Protection (CRITICAL)

- [`protect-concurrency-limit-fanout`](references/protect-concurrency-limit-fanout.md) — Cap simultaneous requests with `p-limit`/semaphore
- [`protect-collapse-identical-requests`](references/protect-collapse-identical-requests.md) — In-flight dedup at the fetch layer
- [`protect-debounce-user-driven-fetches`](references/protect-debounce-user-driven-fetches.md) — Wait for user pause before firing search/filter requests
- [`protect-throttle-scroll-triggered`](references/protect-throttle-scroll-triggered.md) — Use IntersectionObserver for viewport-triggered fetches
- [`protect-jittered-retry-backoff`](references/protect-jittered-retry-backoff.md) — Add random jitter to prevent thundering-herd retries
- [`protect-circuit-breaker`](references/protect-circuit-breaker.md) — Stop calling persistently failing endpoints for a cooldown window
- [`protect-rate-limit-aware-client`](references/protect-rate-limit-aware-client.md) — Honor `Retry-After` and `X-RateLimit-*` headers

### 4. Prefetch & Hydration (HIGH)

- [`prefetch-hover-intent-links`](references/prefetch-hover-intent-links.md) — Prefetch on hover/pointerdown for instant navigation
- [`prefetch-parallel-loader-queries`](references/prefetch-parallel-loader-queries.md) — Parallelize independent queries inside loaders
- [`prefetch-hydrate-server-cache`](references/prefetch-hydrate-server-cache.md) — Ship server-fetched data via `HydrationBoundary` / RSC
- [`prefetch-idle-likely-next`](references/prefetch-idle-likely-next.md) — Use `requestIdleCallback` for likely-next data
- [`prefetch-viewport-triggered-next-page`](references/prefetch-viewport-triggered-next-page.md) — Fire next-page prefetch via `rootMargin`
- [`prefetch-budget-and-priority`](references/prefetch-budget-and-priority.md) — Tier prefetches by priority; respect `Save-Data`

### 5. Failure Resilience (HIGH)

- [`resilience-abort-on-unmount`](references/resilience-abort-on-unmount.md) — Forward `AbortSignal` to cancel stale fetches
- [`resilience-bounded-timeouts`](references/resilience-bounded-timeouts.md) — Set per-endpoint timeouts via `AbortSignal.timeout()`
- [`resilience-scoped-error-boundaries`](references/resilience-scoped-error-boundaries.md) — One boundary per data section, not per page
- [`resilience-stale-fallback`](references/resilience-stale-fallback.md) — Render stale cache when fresh fetch fails
- [`resilience-no-auto-retry-mutations`](references/resilience-no-auto-retry-mutations.md) — Use idempotency keys or don't auto-retry
- [`resilience-graceful-degradation`](references/resilience-graceful-degradation.md) — Critical/important/decorative tiers with different failure modes

### 6. Feed & Carousel Patterns (MEDIUM-HIGH)

- [`feed-virtualize-long-lists`](references/feed-virtualize-long-lists.md) — Use TanStack Virtual for lists > 50 items
- [`feed-cursor-pagination`](references/feed-cursor-pagination.md) — Cursors beat offset for inserts and large offsets
- [`feed-split-summary-from-detail`](references/feed-split-summary-from-detail.md) — Carousel summaries lightweight; detail on demand
- [`feed-multi-carousel-isolation`](references/feed-multi-carousel-isolation.md) — Per-carousel error/Suspense boundaries + tiered fallbacks for homepage feeds
- [`feed-stable-keys-across-pages`](references/feed-stable-keys-across-pages.md) — Use entity IDs as keys; never index
- [`feed-image-lazy-and-sized`](references/feed-image-lazy-and-sized.md) — `loading="lazy"` + explicit dimensions
- [`feed-bounded-working-set`](references/feed-bounded-working-set.md) — `maxPages` + entity LRU eviction for unbounded feeds

### 7. Mutation & Invalidation (MEDIUM)

- [`mutate-optimistic-updates-with-rollback`](references/mutate-optimistic-updates-with-rollback.md) — Snapshot, optimistic write, rollback on error
- [`mutate-surgical-invalidation`](references/mutate-surgical-invalidation.md) — Invalidate specific keys, not entire trees
- [`mutate-set-data-over-invalidate`](references/mutate-set-data-over-invalidate.md) — Write mutation responses directly into the cache
- [`mutate-cancel-queries-on-mutate`](references/mutate-cancel-queries-on-mutate.md) — Cancel in-flight queries before optimistic writes

### 8. Component Patterns (MEDIUM)

- [`render-stable-query-keys`](references/render-stable-query-keys.md) — `useMemo` object keys to keep references stable
- [`render-cap-fanout-in-lists`](references/render-cap-fanout-in-lists.md) — Lift fetches; batch via DataLoader; virtualize
- [`render-suspense-per-section`](references/render-suspense-per-section.md) — One Suspense boundary per data section
- [`render-colocate-fetch-with-consumer`](references/render-colocate-fetch-with-consumer.md) — Put `useQuery` next to its consumer, not at the root

## How to Use

1. Open [references/_sections.md](references/_sections.md) for category definitions and impact rationale
2. Read individual rule files for incorrect-vs-correct code examples
3. For ready-to-use scaffolds, see [scaffolding templates](assets/templates/)
4. The [AGENTS.md](AGENTS.md) navigation document (auto-generated) provides a TOC for browsing

## Scaffolding Templates

Six ready-to-adapt code templates under `assets/templates/`:

| Template | Library deps | Purpose |
|----------|-------------|---------|
| `use-resource-query.template.tsx` | TanStack Query | Standard query hook with key factory, retry, abort, optional suspense |
| `use-resource-query-no-deps.template.tsx` | **None** (pure React + AbortController) | Same patterns as above, library-free: hand-rolled cache, dedup, retry with jitter, staleTime/gcTime, concurrency limit |
| `carousel-data-loader.template.tsx` | TanStack Query + react-error-boundary | Single carousel (summary + viewport-triggered detail) *and* multi-carousel feed with per-carousel failure isolation |
| `infinite-feed.template.tsx` | TanStack Query + TanStack Virtual | Cursor-paginated infinite feed with virtualization and bounded working set |
| `prefetch-link.template.tsx` | None | Hover/intent prefetch link wrapper |
| `request-collapser.template.ts` | None | In-flight deduplication + concurrency limit utility |

**Library-free path:** if you can't add TanStack Query / SWR / DataLoader to your bundle (size constraints, host-app conflicts, dependency bans), start with `use-resource-query-no-deps.template.tsx` — it implements the core cache/dedup/retry/abort patterns in ~250 lines using only React and the web platform. The other templates that depend on TanStack can be adapted on top of it; only the `request-collapser` and `prefetch-link` templates are zero-dep out of the box.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions, ordering, impact rationale |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version, references, abstract |

## Related Skills

- `react-optimise` — General React render performance (this skill is data-fetching-specific)
- `nextjs-bundle-optimizer` — Bundle/payload optimization for Next.js
- `inngest-nextjs-patterns` — Server-side workflow patterns (complements server-fetch guidance)
