---
name: django-recommender-search-backend-patterns
description: Django backend patterns for recommendation services (AWS Personalize, Databricks Model Serving, internal microservices) and OpenSearch-backed search/feed endpoints. Covers fan-out orchestration (asyncio.gather, deadline propagation, partial results, async client reuse), external service protection (timeouts, circuit breakers, jittered retry, bulkheads, rate limits), OpenSearch query patterns (search_after, _source filtering, function_score, aliases, routing, bool.filter), result blending (score normalization, MMR, dedup, cold-start), Redis caching (stampede protection, model-versioned keys, two-tier, negative), resilience (partial-response envelope, stale-on-error, graceful degradation), async (sync_to_async, async ORM, uvicorn, contextvars, disconnect cancellation), and DRF response shape (cursor pagination, ETag, throttling). Use when building, reviewing, or refactoring such a Django backend. Triggers even without explicit "scale" cues. Includes 5 scaffolding templates.
---
# Experimental Django Recommender + Search Backend Best Practices

Implementation patterns for a Django backend serving mixed-results recommendations (Personalize / Databricks / microservice fan-out) and OpenSearch-backed search/feeds. **48 rules across 8 categories**, ordered by execution lifecycle impact — earlier categories cascade through everything downstream.

This is the *backend* peer of the `react-fetch-cache-patterns` skill. React handles client-side waterfalls and caching; this skill handles server-side fan-out, downstream protection, OpenSearch query design, and ML-blend orchestration.

## When to Apply

- Building or reviewing Django views that fan out to AWS Personalize, Databricks Model Serving, internal microservices, or any ML inference downstream
- Designing OpenSearch query endpoints (search results, infinite feeds, faceted search)
- Implementing a recommendations endpoint that blends multiple ranker outputs
- Investigating "Django backend slow when downstream is degraded" or "Personalize quota exhausted"
- Adding caching, retry, circuit breakers, or rate limiting to outbound calls
- Choosing between sync and async Django views, configuring uvicorn vs gunicorn
- Designing DRF response shapes for paginated feeds, partial results, or degraded paths

## Rule Categories by Priority

| # | Category | Impact | Prefix | Rules |
|---|----------|--------|--------|-------|
| 1 | Fan-out Orchestration | CRITICAL | `orch-` | 8 |
| 2 | External Service Protection | CRITICAL | `protect-` | 7 |
| 3 | OpenSearch Query Patterns | CRITICAL | `search-` | 8 |
| 4 | Result Blending & Personalization | HIGH | `blend-` | 5 |
| 5 | Caching Strategy | HIGH | `cache-` | 5 |
| 6 | Resilience & Partial Results | HIGH | `resilience-` | 5 |
| 7 | Async & Concurrency | MEDIUM-HIGH | `async-` | 5 |
| 8 | API Response Design | MEDIUM | `api-` | 5 |

## Quick Reference

### 1. Fan-out Orchestration (CRITICAL)

- [`orch-parallel-fanout-asyncio-gather`](references/orch-parallel-fanout-asyncio-gather.md) — Use `asyncio.gather` for independent downstream calls; never await sequentially
- [`orch-return-exceptions-on-fanout`](references/orch-return-exceptions-on-fanout.md) — `return_exceptions=True` so one failure doesn't poison the whole gather
- [`orch-propagate-request-deadline`](references/orch-propagate-request-deadline.md) — Pass a deadline through every downstream call to bound whole-request latency
- [`orch-reuse-async-clients`](references/orch-reuse-async-clients.md) — One `httpx.AsyncClient` per downstream at module scope; never per-request
- [`orch-bounded-fanout-concurrency`](references/orch-bounded-fanout-concurrency.md) — Cap per-request fan-out with `asyncio.Semaphore` to protect the pool
- [`orch-no-blocking-in-async-view`](references/orch-no-blocking-in-async-view.md) — Never block the event loop with sync ORM/IO in async views
- [`orch-avoid-await-in-loop`](references/orch-avoid-await-in-loop.md) — `for item in items: await ...` is serial; use `asyncio.gather` with comprehension
- [`orch-batch-with-bulk-endpoint`](references/orch-batch-with-bulk-endpoint.md) — Bulk endpoint over N parallel calls; DataLoader pattern for batchers

### 2. External Service Protection (CRITICAL)

- [`protect-per-downstream-timeout-budget`](references/protect-per-downstream-timeout-budget.md) — Different timeouts per service matched to each downstream's p99
- [`protect-circuit-breaker-per-downstream`](references/protect-circuit-breaker-per-downstream.md) — One breaker per downstream so failures stay isolated
- [`protect-jittered-retry-backoff`](references/protect-jittered-retry-backoff.md) — Full-jitter exponential backoff to prevent thundering-herd recovery
- [`protect-no-retry-on-4xx`](references/protect-no-retry-on-4xx.md) — Skip retry on 4xx and non-idempotent failures; distinguish connect vs read errors
- [`protect-bulkhead-connection-pool`](references/protect-bulkhead-connection-pool.md) — One connection pool per downstream so one slow service doesn't starve others
- [`protect-client-side-rate-limit`](references/protect-client-side-rate-limit.md) — Token bucket toward each downstream to stay under their quota
- [`protect-honor-retry-after-header`](references/protect-honor-retry-after-header.md) — Parse `Retry-After` (seconds or HTTP-date) on 429/503

### 3. OpenSearch Query Patterns (CRITICAL)

- [`search-use-search-after-not-from`](references/search-use-search-after-not-from.md) — `search_after` cursor instead of `from/size` for any paginated endpoint
- [`search-filter-source-fields`](references/search-filter-source-fields.md) — Restrict `_source` to fields you render; use `docvalue_fields` for sortable
- [`search-bool-filter-vs-must`](references/search-bool-filter-vs-must.md) — Non-scoring clauses in `filter` (cacheable), scoring clauses in `must`
- [`search-function-score-for-blending`](references/search-function-score-for-blending.md) — Use `function_score` to blend personalization signals in-engine
- [`search-stable-tiebreaker-sort`](references/search-stable-tiebreaker-sort.md) — Always end sort with `_id` (or unique numeric field) for stable cursors
- [`search-alias-for-blue-green-reindex`](references/search-alias-for-blue-green-reindex.md) — Query through aliases; never direct index names
- [`search-enable-request-cache`](references/search-enable-request-cache.md) — `request_cache=true` for hit-returning queries; canonicalize request body
- [`search-shard-aware-routing`](references/search-shard-aware-routing.md) — Use routing keys to limit per-query shard fan-out

### 4. Result Blending & Personalization (HIGH)

- [`blend-normalize-scores-across-sources`](references/blend-normalize-scores-across-sources.md) — Min-max or RRF normalize before blending Personalize/Databricks/OpenSearch
- [`blend-mmr-for-diversity`](references/blend-mmr-for-diversity.md) — Maximal Marginal Relevance to avoid monocultures in top-K
- [`blend-dedup-across-sources`](references/blend-dedup-across-sources.md) — Canonical item ID dedup; bonus for cross-source corroboration
- [`blend-cold-start-fallback`](references/blend-cold-start-fallback.md) — Popular/editorial fallback for new users; tiered personalization
- [`blend-anonymous-vs-personalized-paths`](references/blend-anonymous-vs-personalized-paths.md) — Cheap segment-keyed cache for anon traffic; ML only for logged-in

### 5. Caching Strategy (HIGH)

- [`cache-redis-with-stampede-protection`](references/cache-redis-with-stampede-protection.md) — `SETNX` lock + jittered TTL + probabilistic early refresh
- [`cache-version-on-model-deploy`](references/cache-version-on-model-deploy.md) — Bake model version into cache keys; no flush needed on retrain
- [`cache-segment-keyed-isolation`](references/cache-segment-keyed-isolation.md) — Include auth/role/locale/segment in keys to prevent cross-context leakage
- [`cache-two-tier-process-and-redis`](references/cache-two-tier-process-and-redis.md) — Process LRU in front of Redis for the hottest keys
- [`cache-negative-results`](references/cache-negative-results.md) — Cache absences and empty results with shorter TTL

### 6. Resilience & Partial Results (HIGH)

- [`resilience-partial-response-envelope`](references/resilience-partial-response-envelope.md) — `partial: true` + `sources_used` + `failed_sources` in response
- [`resilience-serve-stale-from-redis`](references/resilience-serve-stale-from-redis.md) — Two TTLs (fresh + stale); serve stale on origin failure
- [`resilience-default-ranking-fallback`](references/resilience-default-ranking-fallback.md) — Precomputed default ranking when all ML sources are down
- [`resilience-per-source-observability`](references/resilience-per-source-observability.md) — Tag every downstream call with structured source/outcome metadata
- [`resilience-degrade-search-gracefully`](references/resilience-degrade-search-gracefully.md) — Tier 1 → tier 2 → tier 3 fallback for OpenSearch outages

### 7. Async & Concurrency (MEDIUM-HIGH)

- [`async-sync-to-async-orm`](references/async-sync-to-async-orm.md) — Use Django 4.1+ async ORM (`aget`, `afilter`) or `sync_to_async` with `thread_sensitive=True`
- [`async-worker-model-uvicorn-vs-gunicorn`](references/async-worker-model-uvicorn-vs-gunicorn.md) — Run ASGI (uvicorn or gunicorn+UvicornWorker) for true async concurrency
- [`async-fire-and-forget-with-create-task`](references/async-fire-and-forget-with-create-task.md) — `create_task` for analytics/audit; add error handler; hold task references
- [`async-context-vars-for-request-scope`](references/async-context-vars-for-request-scope.md) — `contextvars.ContextVar` for per-request state; not `threading.local`
- [`async-cancel-on-client-disconnect`](references/async-cancel-on-client-disconnect.md) — Check `await request.is_disconnected()`; propagate cancellation

### 8. API Response Design (MEDIUM)

- [`api-cursor-pagination-in-drf`](references/api-cursor-pagination-in-drf.md) — Cursor pagination over page-number; opaque base64 cursors
- [`api-serializer-perf-select-related`](references/api-serializer-perf-select-related.md) — `select_related`/`prefetch_related`/`only` to eliminate N+1
- [`api-etag-and-cache-control-headers`](references/api-etag-and-cache-control-headers.md) — `ETag` + `Cache-Control` + `Vary` for CDN/client reuse
- [`api-compression-and-payload-shaping`](references/api-compression-and-payload-shaping.md) — gzip/brotli; sparse fieldsets; msgpack for internal APIs
- [`api-throttle-per-user-and-endpoint`](references/api-throttle-per-user-and-endpoint.md) — DRF throttle classes per user/anon and per expensive endpoint

## How to Use

1. Open [references/_sections.md](references/_sections.md) for category definitions and impact rationale
2. Read individual rule files for incorrect-vs-correct code examples (each ~150-300 lines with Python code)
3. For ready-to-use scaffolds, see [scaffolding templates](assets/templates/)
4. The [AGENTS.md](AGENTS.md) navigation document (auto-generated) provides a TOC for browsing

## Scaffolding Templates

Five ready-to-adapt Python templates under `assets/templates/`:

| Template | Purpose |
|----------|---------|
| `fanout_recommender_service.py.template` | Async fan-out client to Personalize/Databricks/microservice with per-downstream circuit breaker, bounded timeout, partial-result return |
| `opensearch_search_view.py.template` | DRF view + OpenSearch `search_after` cursor + `function_score` blending + `_source` filtering |
| `result_blender.py.template` | Score normalization + MMR diversity + canonical-ID dedup + cold-start fallback |
| `redis_cache_with_stampede.py.template` | Stampede-safe cached function decorator with SETNX lock and jittered TTL |
| `degraded_response.py.template` | Partial-results envelope with per-source status flags + tier-based fallback |

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions, ordering, impact rationale, tier definitions |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version, references, abstract |

## Related Skills

- `react-fetch-cache-patterns` — Client-side peer covering React data fetching/caching (Suspense, query libraries, prefetch)
- `io-bound-data-processing` — Python async patterns for batch and pipeline workloads
- `inngest-nextjs-patterns` — Workflow patterns for server-side step functions
