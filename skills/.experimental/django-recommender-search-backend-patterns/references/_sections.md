# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by lifecycle position and cascade effect. Problems at the
top (fan-out orchestration, external service protection, search query design)
multiply downstream — getting them wrong creates p99 spikes, cascading downstream
failures, or wasted compute on every request. Problems at the bottom (response
serialization, pagination shape) are localized.

## Impact tier definitions

Used by rule frontmatter and category headings:

| Tier | Meaning | When to assign |
|------|---------|----------------|
| **CRITICAL** | Cascades through every request; affects whole-API SLOs | Multiplicative failure modes (uncapped fan-out, missing timeouts, naive OpenSearch pagination at depth) |
| **HIGH** | Affects a major user path or compute budget; not multiplicative but compounding | Per-endpoint policy (blending strategy, cache stampede, partial-results envelope) |
| **MEDIUM-HIGH** | Important for a specific scenario (async views, large fan-out) but not universal | Stack-specific patterns (asgiref correctness, sync_to_async ORM pitfalls) |
| **MEDIUM** | Localized correctness or efficiency; high frequency, contained blast radius | Per-view patterns (DRF serializer perf, cursor pagination format, headers) |
| **LOW-MEDIUM** / **LOW** | Edge cases | Rarely used in this skill |

---

## 1. Fan-out Orchestration (orch)

**Impact:** CRITICAL  
**Description:** How concurrent calls to Personalize, internal microservices, and Databricks ML endpoints are coordinated — `asyncio.gather` with `return_exceptions=True`, deadline propagation across hops, partial-result aggregation, parallel-not-serial fan-out, async client reuse. Wrong here turns a 200ms p99 into a 2-second p99 (slowest-downstream bottleneck) or one downstream failure into a full request failure.

## 2. External Service Protection (protect)

**Impact:** CRITICAL  
**Description:** Per-downstream guardrails — circuit breakers tuned per service (Personalize fails differently than Databricks), per-endpoint timeout budgets, full-jitter exponential backoff, bulkhead pools, client-side rate-limiting toward downstreams. Without these, one slow service hangs every worker thread; one outage cascades into client-quota exhaustion.

## 3. OpenSearch Query Patterns (search)

**Impact:** CRITICAL  
**Description:** Index, query, and pagination design — `search_after` cursor instead of deep `from/size`, `_source` filtering to bound payload size, `function_score` for blending personalization signals, request cache enablement, index aliases for blue/green, tie-breaker sort for stable cursors. Bad query design turns a 50ms search into a 5-second search at production data volume.

## 4. Result Blending & Personalization (blend)

**Impact:** HIGH  
**Description:** Mixing heterogeneous recommender outputs — score normalization across sources with different score scales (Personalize 0..1, Databricks logits, OpenSearch BM25), MMR diversity to avoid recommendation monocultures, cross-source dedup by canonical item ID, cold-start fallback for new users, anonymous-vs-personalized response splits.

## 5. Caching Strategy (cache)

**Impact:** HIGH  
**Description:** Redis-tier patterns for an API serving expensive ML/search calls — key design with user-segment isolation, stampede protection via SETNX locks + jittered TTLs, cache versioning keyed on ML model deploy, two-tier caching (process LRU + Redis), negative caching for empty results. Wrong here means thundering-herd refetches on TTL expiry and stale recommendations after a model swap.

## 6. Resilience & Partial Results (resilience)

**Impact:** HIGH  
**Description:** How the API degrades when some downstreams fail — `partial: true` response envelopes flagging which sources contributed, stale-from-Redis fallback when fresh fetch fails, default ranking fallback when all recommenders are down, per-source observability tags so downstream failures are visible in metrics. Without these, one Databricks blip becomes a 500 for the entire recommendation page.

## 7. Async & Concurrency (async)

**Impact:** MEDIUM-HIGH  
**Description:** Django-specific async patterns — async views vs. sync, `sync_to_async`/`async_to_sync` correctness, ORM async pitfalls, gunicorn worker model vs. uvicorn for IO-bound workloads, connection pool sizing per downstream, `httpx.AsyncClient` reuse across requests. Wrong here either negates async benefits (blocking-in-async) or corrupts request-scoped state.

## 8. API Response Design (api)

**Impact:** MEDIUM  
**Description:** DRF-level response shape — cursor pagination instead of page-number, serializer performance (`select_related`/`prefetch_related`/`only`/`values`), `ETag`/`Cache-Control` headers for CDN/proxy reuse, streaming responses for large result sets, response compression. These don't change throughput dramatically but compound across endpoints.
