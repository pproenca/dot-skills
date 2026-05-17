---
name: opensearch-personalize-caching-strategies
description: Use this skill whenever designing, sizing, tuning, reviewing, or debugging caching in front of AWS OpenSearch (Elasticsearch) or an AWS Personalize-fronting microservice — search results, recommender outputs, multi-recommender pages, anonymous vs logged-in traffic, cohort-based recommendations, real-time session signals. Covers the empirical "should we cache?" decision (cost calculus, Personalize TPS / minProvisionedTPS math, Zipf-distribution profiling, latency budget, multi-recommender amplification), cache-key design (canonicalisation, cohort vs user, solution-version pinning, locale/currency, volatile-param stripping, bucketed ranges, stable hashing), personalisation boundary (anonymous/logged split, cold-start fallback, fan-out coalescing, shared-candidates private-ranking, session-vector write-through), strategies (cache-aside default, refresh-ahead for hot keys, write-through for mutations, batch precomputation, tiered L1+L2 promotion, async warm-up), TTL & freshness (volatility-driven TTL, soft/hard TTL, jitter, model-version pinning, event-driven invalidation, staleness-budget caps), stampede protection (single-flight, XFetch probabilistic early expiry, stale-while-revalidate, circuit breaker, distributed lock), observability (hit-rate by key class, latency-with-and-without histograms, cost-per-1k attribution, key-cardinality drift, stale-served ratio, log-replay simulation), negative & defensive caching (empty results, Personalize-throttle fallback, Bloom-filter cache-penetration defense, poison-pill detection via checksum), and tier composition (in-process LRU, ElastiCache Redis sizing, CloudFront for anonymous, OpenSearch request cache, OpenSearch filter-context auto-cache). Triggers on "cache hit rate", "cache miss storm", "Personalize too expensive", "Personalize throttling", "multi-recommender page", "cohort caching", "cache stampede", "TTL", "stale-while-revalidate", "single-flight", "L1 L2 tiered cache", "CloudFront search caching", "OpenSearch slow queries", "ElastiCache sizing", "Redis hot key", "cache key collision", "thundering herd", "warm-up", "circuit breaker", "Bloom filter cache", and "why is my cache hit rate low". Complements `opensearch-function-scoring-algorithms` — that skill covers what the ranking *does*; this skill covers how to scale it without overwhelming OpenSearch or Personalize.
---

# Marketplace-Research OpenSearch + Personalize Caching Best Practices

A reference distillation of caching strategies for two-sided marketplaces running AWS OpenSearch (search) and AWS Personalize (recommendations behind a microservice). Contains **52 rules across 9 categories**, ordered by cascade effect — from the upstream decision of *whether* to cache, through key design, personalisation boundary, strategy selection, TTL design, stampede protection, observability, and the lower-cascade categories of negative caching and tier composition. Each rule explains the WHY (the cost, latency, or correctness mechanism), shows incorrect-vs-correct code (TypeScript/Node for the microservice layer, Python for batch and analytics, OpenSearch JSON for OS-specific queries, YAML for CDN/Kubernetes), and cites the canonical source — AWS Personalize/OpenSearch/ElastiCache documentation, the XFetch paper (Vattani et al. VLDB 2015), RFC 5861 (stale-while-revalidate), and the engineering blogs of cache infrastructure teams (Netflix EVCache, Pinterest Cachelib, Twitter Twemcache, Cloudflare).

This is the **complement** to [`opensearch-function-scoring-algorithms`](../opensearch-function-scoring-algorithms/) — that skill answers "what should the ranking compute?", this skill answers "how do you scale it to production traffic without burning down OpenSearch or Personalize?"

## When to Apply

Reach for this skill when:

- Adding caching to a search or recommendation surface for the first time — start with [decide-cache-roi-calculation](references/decide-cache-roi-calculation.md) and [decide-hot-key-distribution](references/decide-hot-key-distribution.md)
- A homepage or category page renders 5+ recommenders and Personalize bills are growing faster than traffic — [decide-amplification-multiplier](references/decide-amplification-multiplier.md), [pers-recommender-fan-out-coalescing](references/pers-recommender-fan-out-coalescing.md), [pers-cohort-precomputation](references/pers-cohort-precomputation.md)
- Cache hit rate is suspiciously low (under 30-40%) and you don't know why — [key-canonicalize-query](references/key-canonicalize-query.md), [key-strip-volatile-params](references/key-strip-volatile-params.md), [key-bucket-numerical-ranges](references/key-bucket-numerical-ranges.md), [obs-key-cardinality-tracking](references/obs-key-cardinality-tracking.md)
- Personalize is throttling (HTTP 429) during traffic spikes — [decide-personalize-quota-budget](references/decide-personalize-quota-budget.md), [neg-cache-throttled-personalize](references/neg-cache-throttled-personalize.md), [stamp-circuit-breaker-on-origin-error](references/stamp-circuit-breaker-on-origin-error.md)
- p99 spikes at TTL boundaries — [stamp-coalesce-concurrent-misses](references/stamp-coalesce-concurrent-misses.md), [stamp-probabilistic-early-expiration](references/stamp-probabilistic-early-expiration.md), [stamp-serve-stale-on-rebuild](references/stamp-serve-stale-on-rebuild.md), [ttl-soft-and-hard](references/ttl-soft-and-hard.md), [ttl-jitter-to-prevent-thundering](references/ttl-jitter-to-prevent-thundering.md)
- Recommendations stay stale after a model retrain — [key-version-the-model](references/key-version-the-model.md), [ttl-personalize-solution-version](references/ttl-personalize-solution-version.md), [strat-async-warm-up](references/strat-async-warm-up.md)
- A read-after-write surface shows stale data (user favourites, saved searches) — [strat-write-through-mutations](references/strat-write-through-mutations.md), [ttl-event-driven-invalidation](references/ttl-event-driven-invalidation.md)
- Cache decisions need to be defensible to finance — [decide-cache-roi-calculation](references/decide-cache-roi-calculation.md), [obs-cost-attribution](references/obs-cost-attribution.md), [obs-cache-simulation-from-logs](references/obs-cache-simulation-from-logs.md)
- Anonymous and logged-in traffic mix on the same routes — [pers-anonymous-vs-logged-split](references/pers-anonymous-vs-logged-split.md), [tier-cdn-for-anonymous](references/tier-cdn-for-anonymous.md)
- Cache is at memory pressure and you need to know whether to upsize, shorten TTL, or change strategy — [decide-hot-key-distribution](references/decide-hot-key-distribution.md), [tier-l2-elasticache-redis](references/tier-l2-elasticache-redis.md), [obs-cache-simulation-from-logs](references/obs-cache-simulation-from-logs.md)
- OpenSearch CPU is high on common queries — [tier-opensearch-request-cache](references/tier-opensearch-request-cache.md), [tier-opensearch-filter-context](references/tier-opensearch-filter-context.md), [neg-cache-empty-results](references/neg-cache-empty-results.md)
- A traffic spike from a viral link or crawler is hammering the origin — [neg-bloom-filter-against-misses](references/neg-bloom-filter-against-misses.md), [neg-cache-empty-results](references/neg-cache-empty-results.md), [stamp-circuit-breaker-on-origin-error](references/stamp-circuit-breaker-on-origin-error.md)

The rules apply to any AWS-based marketplace with OpenSearch and Personalize fronted by an application microservice, regardless of vertical — accommodation, food delivery, fashion, services, jobs, secondhand goods, real estate. Triggers include "cache hit rate", "cache miss storm", "Personalize throttling", "Personalize cost", "multi-recommender page", "cohort caching", "single-flight", "stale-while-revalidate", "XFetch", "OpenSearch slow queries", "ElastiCache sizing", "CloudFront search caching", "Bloom filter cache penetration", and "thundering herd".

## The Caching Pipeline

Categories are derived from the request-time caching pipeline. Earlier stages cascade: a wrong "should we cache?" decision wastes everything below; un-canonicalised keys cap hit rate at a fraction of the achievable ceiling; without observability you can't tell whether any of the rules helped.

```text
Request → [1] Decide → [2] Key construction → [3] Personalisation boundary
        → [4] Strategy (read/write path) → [5] TTL/freshness → [6] Stampede protection
        → [8] Negative/defensive → [9] Tier composition (L1/L2/CDN/OS-internal) → Response
                                                ↑
                                [7] Observability (meta-layer applied to all stages:
                                    hit rate by key class, latency-with-and-without,
                                    cost-per-1k, cardinality, staleness, log-replay)
```

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Decision & Cost Calculus | CRITICAL | `decide-` | 7 |
| 2 | Cache Key Design | CRITICAL | `key-` | 7 |
| 3 | Personalisation Boundary | HIGH | `pers-` | 6 |
| 4 | Strategies & Write Paths | HIGH | `strat-` | 6 |
| 5 | TTL & Freshness | HIGH | `ttl-` | 6 |
| 6 | Stampede Protection | HIGH | `stamp-` | 5 |
| 7 | Observability & Empirical Measurement | HIGH | `obs-` | 6 |
| 8 | Negative & Defensive Caching | MEDIUM-HIGH | `neg-` | 4 |
| 9 | Tiered & Edge Caching | MEDIUM-HIGH | `tier-` | 5 |

## Quick Reference

### 1. Decision & Cost Calculus (CRITICAL)

- [`decide-cache-roi-calculation`](references/decide-cache-roi-calculation.md) — Compute Cache ROI Before Adding the Cache
- [`decide-cardinality-floor`](references/decide-cardinality-floor.md) — Skip Caching When Traffic Distribution is Flat
- [`decide-personalize-quota-budget`](references/decide-personalize-quota-budget.md) — Model Personalize TPS Budget Before Choosing a Cache Strategy
- [`decide-latency-budget`](references/decide-latency-budget.md) — Cache Only When Origin p99 Exceeds the Latency Budget
- [`decide-amplification-multiplier`](references/decide-amplification-multiplier.md) — Account for Multi-Recommender Page Amplification
- [`decide-hot-key-distribution`](references/decide-hot-key-distribution.md) — Profile Traffic Distribution Before Sizing the Cache
- [`decide-search-vs-personalize-asymmetry`](references/decide-search-vs-personalize-asymmetry.md) — Cache Candidate Sets for Search, Full Payloads for Personalize

### 2. Cache Key Design (CRITICAL)

- [`key-canonicalize-query`](references/key-canonicalize-query.md) — Canonicalise Queries Before Hashing
- [`key-segment-not-user`](references/key-segment-not-user.md) — Key Recommenders by Cohort When Users Outnumber Cohorts
- [`key-version-the-model`](references/key-version-the-model.md) — Include the Personalize Solution Version in the Cache Key
- [`key-locale-currency-explicit`](references/key-locale-currency-explicit.md) — Make Locale, Currency, and Timezone Explicit in the Key
- [`key-strip-volatile-params`](references/key-strip-volatile-params.md) — Strip Volatile and Tracking Params Before Hashing
- [`key-bucket-numerical-ranges`](references/key-bucket-numerical-ranges.md) — Bucket Continuous Filters Before Hashing
- [`key-stable-hash-algorithm`](references/key-stable-hash-algorithm.md) — Use SHA-256 over MD5 for High-Cardinality Keys

### 3. Personalisation Boundary (HIGH)

- [`pers-cohort-precomputation`](references/pers-cohort-precomputation.md) — Precompute Recommendations Per Cohort Offline
- [`pers-anonymous-vs-logged-split`](references/pers-anonymous-vs-logged-split.md) — Route Anonymous Traffic to Global Cache, Logged-in to Cohort Cache
- [`pers-cold-start-cache-priority`](references/pers-cold-start-cache-priority.md) — Serve Cold-Start Users From Popularity Cache, Skip Personalize
- [`pers-recommender-fan-out-coalescing`](references/pers-recommender-fan-out-coalescing.md) — Coalesce Multi-Recommender Fan-Out Into Batched Calls
- [`pers-shared-candidates-private-ranking`](references/pers-shared-candidates-private-ranking.md) — Cache Retrieval Candidates Globally, Re-Rank Per-User From Cache
- [`pers-session-vector-write-through`](references/pers-session-vector-write-through.md) — Maintain Session Vectors in Cache with Write-Through on Every Event

### 4. Strategies & Write Paths (HIGH)

- [`strat-cache-aside-default`](references/strat-cache-aside-default.md) — Use Cache-Aside as the Default Strategy for Read-Heavy Paths
- [`strat-refresh-ahead-hot-keys`](references/strat-refresh-ahead-hot-keys.md) — Use Refresh-Ahead Only for the Top 1% of Hot Keys
- [`strat-write-through-mutations`](references/strat-write-through-mutations.md) — Use Write-Through When User Mutations Are Immediately Re-Read
- [`strat-precompute-batch`](references/strat-precompute-batch.md) — Precompute the Popular Fraction with Batch Jobs
- [`strat-tiered-promotion`](references/strat-tiered-promotion.md) — Promote to L1 In-Process Cache on L2 Hit
- [`strat-async-warm-up`](references/strat-async-warm-up.md) — Async Warm-Up After Deploy, Restart, or Model Retrain

### 5. TTL & Freshness (HIGH)

- [`ttl-by-content-volatility`](references/ttl-by-content-volatility.md) — Set TTL From Content Volatility, Not Engineering Convenience
- [`ttl-soft-and-hard`](references/ttl-soft-and-hard.md) — Separate Soft TTL (Async Refresh) from Hard TTL (Sync Miss)
- [`ttl-jitter-to-prevent-thundering`](references/ttl-jitter-to-prevent-thundering.md) — Add Random Jitter to TTL to Prevent Synchronized Expiry
- [`ttl-personalize-solution-version`](references/ttl-personalize-solution-version.md) — Pin TTL to Personalize Solution Version, Not Wall Clock
- [`ttl-event-driven-invalidation`](references/ttl-event-driven-invalidation.md) — Pair TTL with Event-Driven Invalidation for Critical Freshness
- [`ttl-bound-by-staleness-tolerance`](references/ttl-bound-by-staleness-tolerance.md) — Bound TTL by Product Staleness Tolerance, Not the Default

### 6. Stampede Protection (HIGH)

- [`stamp-coalesce-concurrent-misses`](references/stamp-coalesce-concurrent-misses.md) — Coalesce Concurrent Misses Into a Single Origin Call
- [`stamp-probabilistic-early-expiration`](references/stamp-probabilistic-early-expiration.md) — Use XFetch Probabilistic Early Expiration for Hot Keys
- [`stamp-serve-stale-on-rebuild`](references/stamp-serve-stale-on-rebuild.md) — Serve Stale While Refresh Is In Flight
- [`stamp-circuit-breaker-on-origin-error`](references/stamp-circuit-breaker-on-origin-error.md) — Trip the Circuit Breaker on Origin Errors; Fall Back to Stale
- [`stamp-distributed-lock-rebuild`](references/stamp-distributed-lock-rebuild.md) — Use a Distributed Lock to Coordinate Cross-Instance Cache Rebuilds

### 7. Observability & Empirical Measurement (HIGH)

- [`obs-hit-rate-by-key-class`](references/obs-hit-rate-by-key-class.md) — Track Hit Rate by Key Class, Never Aggregate Only
- [`obs-latency-histograms-with-without`](references/obs-latency-histograms-with-without.md) — Measure Latency Histograms With-Hit and With-Miss Separately
- [`obs-cost-attribution`](references/obs-cost-attribution.md) — Attribute Cost Per Thousand Requests With and Without Cache
- [`obs-key-cardinality-tracking`](references/obs-key-cardinality-tracking.md) — Sample Key Cardinality Daily; Alert on Explosion
- [`obs-stale-served-ratio`](references/obs-stale-served-ratio.md) — Measure Stale-Served Ratio to Validate TTL Choice
- [`obs-cache-simulation-from-logs`](references/obs-cache-simulation-from-logs.md) — Replay Production Logs Through a Cache Simulator Before Changing TTL or Strategy

### 8. Negative & Defensive Caching (MEDIUM-HIGH)

- [`neg-cache-empty-results`](references/neg-cache-empty-results.md) — Cache Empty Search Results With a Short TTL
- [`neg-cache-throttled-personalize`](references/neg-cache-throttled-personalize.md) — Serve Last-Known-Good When Personalize Throttles
- [`neg-bloom-filter-against-misses`](references/neg-bloom-filter-against-misses.md) — Use a Bloom Filter to Block High-Cardinality Miss Storms
- [`neg-poison-pill-detection`](references/neg-poison-pill-detection.md) — Checksum Cache Entries to Detect and Reject Poisoned Writes

### 9. Tiered & Edge Caching (MEDIUM-HIGH)

- [`tier-l1-in-process`](references/tier-l1-in-process.md) — Use In-Process LRU as L1 for Sub-Millisecond Reads
- [`tier-l2-elasticache-redis`](references/tier-l2-elasticache-redis.md) — Size L2 ElastiCache to the Cross-Instance Working Set
- [`tier-cdn-for-anonymous`](references/tier-cdn-for-anonymous.md) — Use CDN for Anonymous Traffic; Bypass for Cookies
- [`tier-opensearch-request-cache`](references/tier-opensearch-request-cache.md) — Enable OpenSearch Request Cache for Aggregation-Heavy Queries
- [`tier-opensearch-filter-context`](references/tier-opensearch-filter-context.md) — Put Reusable Predicates in Filter Context for Segment-Level Caching

## How to Use

For a focused question ("should I cache this?", "why is my hit rate low?", "how do I survive Personalize throttling?"), jump directly to the relevant rule — each is self-contained with the WHY, code, and citation.

For a full caching-design review of a new or struggling surface, work the categories top-to-bottom. The cascade is real: a wrong [decide-cache-roi-calculation](references/decide-cache-roi-calculation.md) wastes engineering effort on a cache that doesn't pay; a leaky [key-canonicalize-query](references/key-canonicalize-query.md) caps the achievable hit rate; a missing [pers-cohort-precomputation](references/pers-cohort-precomputation.md) keeps Personalize bills proportional to MAU. Stampede and observability are mandatory once hit rate exceeds 90% — the 10% miss in a thundering herd kills the origin, and without per-class hit-rate dashboards you can't tell.

**For tuning an existing cache empirically**, start with [obs-cache-simulation-from-logs](references/obs-cache-simulation-from-logs.md) (replay your logs through what-if configs) and pair with [obs-hit-rate-by-key-class](references/obs-hit-rate-by-key-class.md), [obs-cost-attribution](references/obs-cost-attribution.md), and [obs-stale-served-ratio](references/obs-stale-served-ratio.md) for the dashboards. The trio answers: is the cache doing its job, what does it cost, and are users seeing stale data?

**For the multi-recommender homepage problem specifically** (the most common Personalize cost-explosion pattern), the priority order is: [decide-amplification-multiplier](references/decide-amplification-multiplier.md) → [pers-cohort-precomputation](references/pers-cohort-precomputation.md) → [pers-recommender-fan-out-coalescing](references/pers-recommender-fan-out-coalescing.md) → [pers-anonymous-vs-logged-split](references/pers-anonymous-vs-logged-split.md). These four typically cut Personalize spend by 70-90% on consumer marketplaces.

**For the "Personalize is throttling under load" incident**, the priority is: [stamp-circuit-breaker-on-origin-error](references/stamp-circuit-breaker-on-origin-error.md) → [neg-cache-throttled-personalize](references/neg-cache-throttled-personalize.md) → [decide-personalize-quota-budget](references/decide-personalize-quota-budget.md). The first two stabilise the user-facing impact; the third right-sizes minProvisionedTPS so it doesn't happen again.

**For sibling-skill cross-reference**, see [`opensearch-function-scoring-algorithms`](../opensearch-function-scoring-algorithms/) — that skill covers what to compute in OpenSearch (function_score, kNN, RRF, rank_feature, decay, LTR, MMR, evaluation). This skill covers how to cache it so the cluster survives production traffic.

Read [section definitions](references/_sections.md) for the cascade-impact rationale, or [the rule template](assets/templates/_template.md) when adding a new rule.

## Related Skills

- [`opensearch-function-scoring-algorithms`](../opensearch-function-scoring-algorithms/) — Research-backed ranking, retrieval, and evaluation rules for OpenSearch. The "what to compute"; this skill is the "how to scale it."

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering by cascade impact |
| [AGENTS.md](AGENTS.md) | Compact TOC navigation (auto-built; do not edit by hand) |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version and authoritative reference URLs |
