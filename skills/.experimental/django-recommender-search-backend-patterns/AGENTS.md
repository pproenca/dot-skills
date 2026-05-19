# Django Recommender + Search Backend

**Version 0.1.0**  
Experimental  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Implementation patterns for a Django backend API that serves mixed-results recommendations (fan-out to AWS Personalize, Databricks Model Serving endpoints, and internal microservices) and OpenSearch-backed search/feed endpoints. 46 rules across 8 categories ordered by execution lifecycle impact: Fan-out Orchestration (asyncio.gather, return_exceptions, deadline propagation, async client reuse, bounded concurrency, no-blocking-in-async, no-await-in-loop, DataLoader batching), External Service Protection (per-downstream timeouts, per-downstream circuit breakers, full-jitter retry, 4xx/non-idempotent retry policy, bulkhead pools, client-side rate limits, Retry-After parsing), OpenSearch Query Patterns (search_after vs from/size, _source filtering, bool.filter vs must, function_score for blending, stable tiebreaker sort, blue-green index aliases, request_cache, shard-aware routing), Result Blending & Personalization (score normalization, MMR diversity, canonical-ID dedup, cold-start fallback, anonymous-vs-personalized paths), Caching Strategy (Redis stampede protection via SETNX, model-version-keyed cache, segment-keyed isolation, two-tier process+Redis, negative result caching), Resilience & Partial Results (partial-response envelope, stale-on-error from Redis, default ranking fallback, per-source observability tags, tiered search degradation), Async & Concurrency (async ORM and sync_to_async, uvicorn/UvicornWorker deployment, create_task fire-and-forget, contextvars for request scope, cancel on client disconnect), and API Response Design (cursor pagination in DRF, select_related/prefetch_related/only, ETag + Cache-Control + Vary, gzip/brotli compression and payload shaping, throttling per user and endpoint). Bundled with 5 Python scaffolding templates: fanout_recommender_service, opensearch_search_view, result_blender, redis_cache_with_stampede, degraded_response. Backend peer to react-fetch-cache-patterns.

---

## Table of Contents

1. [Fan-out Orchestration](references/_sections.md#1-fan-out-orchestration) — **CRITICAL**
   - 1.1 [Avoid await Inside Independent Loops](references/orch-avoid-await-in-loop.md) — CRITICAL (reduces N sequential awaits to 1 round-trip time)
   - 1.2 [Batch Fan-out via Bulk Endpoints](references/orch-batch-with-bulk-endpoint.md) — CRITICAL (reduces N parallel calls to 1 round-trip)
   - 1.3 [Bound Per-Request Fan-out with a Semaphore](references/orch-bounded-fanout-concurrency.md) — CRITICAL (prevents one user's request from saturating the pool)
   - 1.4 [Fan Out to Recommenders with asyncio.gather](references/orch-parallel-fanout-asyncio-gather.md) — CRITICAL (reduces N sequential downstream calls to 1 round-trip time)
   - 1.5 [Never Block the Event Loop in Async Views](references/orch-no-blocking-in-async-view.md) — CRITICAL (prevents 1 slow request from blocking all other requests)
   - 1.6 [Propagate a Request Deadline Across All Downstreams](references/orch-propagate-request-deadline.md) — CRITICAL (prevents unbounded request latency on slow downstream)
   - 1.7 [Reuse Async HTTP Clients Across Requests](references/orch-reuse-async-clients.md) — CRITICAL (prevents 50-200ms per-request TLS handshake overhead)
   - 1.8 [Use return_exceptions=True for Partial-Results Fan-out](references/orch-return-exceptions-on-fanout.md) — CRITICAL (prevents one downstream failure from failing the whole request)
2. [External Service Protection](references/_sections.md#2-external-service-protection) — **CRITICAL**
   - 2.1 [Honor Retry-After Headers from Downstreams](references/protect-honor-retry-after-header.md) — HIGH (prevents 429 escalation and downstream bans)
   - 2.2 [Isolate Connection Pools per Downstream](references/protect-bulkhead-connection-pool.md) — HIGH (prevents one slow downstream from starving fast ones)
   - 2.3 [Run One Circuit Breaker per Downstream](references/protect-circuit-breaker-per-downstream.md) — CRITICAL (prevents one degraded downstream from cascading)
   - 2.4 [Set Per-Downstream Timeout Budgets](references/protect-per-downstream-timeout-budget.md) — CRITICAL (prevents one slow service from blowing the whole budget)
   - 2.5 [Skip Retry on 4xx and Non-Idempotent Failures](references/protect-no-retry-on-4xx.md) — HIGH (prevents wasted retries on permanent errors)
   - 2.6 [Throttle Outbound Calls with a Token Bucket](references/protect-client-side-rate-limit.md) — HIGH (prevents downstream rate-limit bans)
   - 2.7 [Use Full-Jitter Backoff for Server-to-Server Retries](references/protect-jittered-retry-backoff.md) — CRITICAL (prevents thundering-herd recovery storms)
3. [OpenSearch Query Patterns](references/_sections.md#3-opensearch-query-patterns) — **CRITICAL**
   - 3.1 [Blend Personalization Signals with function_score](references/search-function-score-for-blending.md) — HIGH (eliminates client-side re-rank of large candidate sets)
   - 3.2 [Enable request_cache for Repeat Queries](references/search-enable-request-cache.md) — HIGH (10-100× faster for hot identical queries)
   - 3.3 [Include a Unique Tiebreaker in Every Sort](references/search-stable-tiebreaker-sort.md) — HIGH (prevents duplicate/missing items on paginated queries)
   - 3.4 [Paginate OpenSearch with search_after, Not from/size](references/search-use-search-after-not-from.md) — CRITICAL (O(N) deep pagination → O(1))
   - 3.5 [Query Through Aliases, Never Direct Index Names](references/search-alias-for-blue-green-reindex.md) — HIGH (enables zero-downtime reindex and rollback)
   - 3.6 [Restrict _source to Fields You Actually Render](references/search-filter-source-fields.md) — CRITICAL (reduces search response size 10-100×)
   - 3.7 [Use bool.filter for Non-Scoring Clauses](references/search-bool-filter-vs-must.md) — CRITICAL (2-10× faster queries via filter cache)
   - 3.8 [Use Routing to Limit Shards Per Query](references/search-shard-aware-routing.md) — HIGH (10× faster queries when partition key known)
4. [Result Blending & Personalization](references/_sections.md#4-result-blending-&-personalization) — **HIGH**
   - 4.1 [Apply MMR Diversity to Avoid Recommendation Monocultures](references/blend-mmr-for-diversity.md) — HIGH (prevents top-K from showing 10 near-duplicate items)
   - 4.2 [Dedup by Canonical ID Across All Sources](references/blend-dedup-across-sources.md) — HIGH (prevents duplicate items in the final ranking)
   - 4.3 [Fall Back to Popular/Editorial on Cold-Start](references/blend-cold-start-fallback.md) — HIGH (prevents empty recommendations for new users)
   - 4.4 [Normalize Scores Before Blending Across Sources](references/blend-normalize-scores-across-sources.md) — HIGH (prevents one source from dominating the ranking)
   - 4.5 [Separate Anonymous and Personalized Code Paths](references/blend-anonymous-vs-personalized-paths.md) — MEDIUM-HIGH (prevents 60-80% of traffic hitting expensive personalization)
5. [Caching Strategy](references/_sections.md#5-caching-strategy) — **HIGH**
   - 5.1 [Cache Negative Results to Prevent Origin Hammering](references/cache-negative-results.md) — MEDIUM-HIGH (prevents N% origin traffic from invalid IDs and empty results)
   - 5.2 [Isolate Cache Keys by Segment and Auth State](references/cache-segment-keyed-isolation.md) — HIGH (prevents cross-segment data leakage in cached responses)
   - 5.3 [Layer a Process LRU in Front of Redis](references/cache-two-tier-process-and-redis.md) — HIGH (reduces Redis RTT 30-90× for the hottest keys)
   - 5.4 [Protect Cache Misses from Stampede with a Lock](references/cache-redis-with-stampede-protection.md) — HIGH (prevents N concurrent regenerations on cold miss)
   - 5.5 [Version Cache Keys by Model Deploy](references/cache-version-on-model-deploy.md) — HIGH (prevents serving stale recommendations after model retrain)
6. [Resilience & Partial Results](references/_sections.md#6-resilience-&-partial-results) — **HIGH**
   - 6.1 [Define a Default Ranking for Total ML Outage](references/resilience-default-ranking-fallback.md) — HIGH (prevents empty recommendations when all sources fail)
   - 6.2 [Degrade Gracefully When OpenSearch Is Slow or Down](references/resilience-degrade-search-gracefully.md) — MEDIUM-HIGH (prevents search outages cascading to API outages)
   - 6.3 [Serve Stale Redis Data When Fresh Fetch Fails](references/resilience-serve-stale-from-redis.md) — HIGH (prevents transient downstream outages from breaking the API)
   - 6.4 [Surface Partiality in the Response Envelope](references/resilience-partial-response-envelope.md) — HIGH (prevents callers caching degraded responses as complete)
   - 6.5 [Tag Every Downstream Call with Structured Source Metadata](references/resilience-per-source-observability.md) — HIGH (prevents silent degradation in production)
7. [Async & Concurrency](references/_sections.md#7-async-&-concurrency) — **MEDIUM-HIGH**
   - 7.1 [Cancel In-Flight Work When the Client Disconnects](references/async-cancel-on-client-disconnect.md) — MEDIUM (prevents wasted compute on abandoned requests)
   - 7.2 [Run Async Views Under Uvicorn or Gunicorn+UvicornWorker](references/async-worker-model-uvicorn-vs-gunicorn.md) — MEDIUM-HIGH (enables true async concurrency per worker)
   - 7.3 [Use Async ORM Methods in Async Views](references/async-sync-to-async-orm.md) — MEDIUM-HIGH (prevents event-loop blocking on ORM calls)
   - 7.4 [Use contextvars for Request-Scoped State Across Async Calls](references/async-context-vars-for-request-scope.md) — MEDIUM (prevents cross-request state leakage in async code)
   - 7.5 [Use create_task for Fire-and-Forget Background Work](references/async-fire-and-forget-with-create-task.md) — MEDIUM (prevents user requests blocking on analytics/audit writes)
8. [API Response Design](references/_sections.md#8-api-response-design) — **MEDIUM**
   - 8.1 [Apply Throttling per User and per Expensive Endpoint](references/api-throttle-per-user-and-endpoint.md) — MEDIUM (prevents one user exhausting expensive downstream quota)
   - 8.2 [Compress Responses and Shape Payloads](references/api-compression-and-payload-shaping.md) — MEDIUM (reduces 60-80% of API egress bandwidth)
   - 8.3 [Return Cursor-Based Pagination from DRF](references/api-cursor-pagination-in-drf.md) — MEDIUM (prevents page-skip bugs as data shifts)
   - 8.4 [Set ETag and Cache-Control for CDN/Client Reuse](references/api-etag-and-cache-control-headers.md) — MEDIUM (enables 304 Not Modified responses and CDN caching)
   - 8.5 [Use select_related, prefetch_related, and only in DRF Serializers](references/api-serializer-perf-select-related.md) — MEDIUM (reduces N+1 queries from serialization)

---

## References

1. [https://docs.djangoproject.com/en/5.0/topics/async/](https://docs.djangoproject.com/en/5.0/topics/async/)
2. [https://www.django-rest-framework.org/api-guide/pagination/](https://www.django-rest-framework.org/api-guide/pagination/)
3. [https://opensearch.org/docs/latest/search-plugins/searching-data/paginate/](https://opensearch.org/docs/latest/search-plugins/searching-data/paginate/)
4. [https://opensearch.org/docs/latest/query-dsl/compound/function-score/](https://opensearch.org/docs/latest/query-dsl/compound/function-score/)
5. [https://docs.aws.amazon.com/personalize/latest/dg/getting-real-time-recommendations.html](https://docs.aws.amazon.com/personalize/latest/dg/getting-real-time-recommendations.html)
6. [https://docs.databricks.com/en/machine-learning/model-serving/index.html](https://docs.databricks.com/en/machine-learning/model-serving/index.html)
7. [https://www.python-httpx.org/async/](https://www.python-httpx.org/async/)
8. [https://docs.python.org/3/library/asyncio-task.html](https://docs.python.org/3/library/asyncio-task.html)
9. [https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
10. [https://redis.io/docs/manual/patterns/distributed-locks/](https://redis.io/docs/manual/patterns/distributed-locks/)
11. [https://datatracker.ietf.org/doc/html/rfc5861](https://datatracker.ietf.org/doc/html/rfc5861)
12. [https://github.com/danielfm/pybreaker](https://github.com/danielfm/pybreaker)
13. [https://www.uvicorn.org/deployment/](https://www.uvicorn.org/deployment/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |