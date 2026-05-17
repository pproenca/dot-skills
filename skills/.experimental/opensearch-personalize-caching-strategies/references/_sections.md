# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories appear in **impact order** (CRITICAL → MEDIUM-HIGH). The request lifecycle for a search-or-recommendation surface runs in a related order: a request arrives → you decide whether to cache it → if yes, a key is constructed → the key is bucketed by the personalisation boundary → a strategy chooses how to read/write → a TTL governs freshness → stampede protection guards the miss → tier composition determines where the lookup happens → and observability tells you whether any of the above worked. Defensive (negative) caching is applied opportunistically across the pipeline. The cascade is real: a wrong "should we cache?" decision wastes everything below it; un-canonicalised keys cap hit-rate at a fraction of the theoretical ceiling; and without measurement infrastructure you cannot tell whether any of the 50 rules helped.

---

## 1. Decision & Cost Calculus (decide)

**Impact:** CRITICAL  
**Description:** The decision of whether to cache at all, and the math that justifies it. Personalize bills per provisioned TPS and per transaction; OpenSearch cluster CPU is finite; multi-recommender pages amplify backend load by 5-10×. Caching the wrong things (flat-distribution traffic, low-cardinality misses, ultra-fresh data) burns infrastructure for negligible benefit, while not caching the right things (hot-cohort recommendations, repeated searches, anonymous traffic) starves the cluster. The rules here are the gate every other rule depends on.

## 2. Cache Key Design (key)

**Impact:** CRITICAL  
**Description:** Cache keys define the hit-rate ceiling. Un-canonicalised whitespace, sort-order in filter arrays, leaky tracking params (UTM, request_id, timestamp), full-precision numerical filters, missing locale/currency/model-version — each silently collapses hit rate by an order of magnitude. Two requests for the same logical result must produce the same key, and two requests for different logical results must not collide. Wilson's "the cache works fine, the hit rate is just 4%" almost always traces to this category.

## 3. Personalisation Boundary (pers)

**Impact:** HIGH  
**Description:** Where shared cache ends and per-user cache begins. The single biggest lever for Personalize cost on a multi-recommender page. Cohort precomputation collapses N users into K cohorts (often N/K > 100), the anonymous/logged split lets anonymous traffic reuse a global cache, recommender fan-out coalescing batches 5+ Personalize calls per page, and session-vector write-through keeps real-time personalisation under 1ms without blowing up TPS. Getting this wrong means paying Personalize per-user per-request when 80% of users belong to one of a small number of cohorts.

## 4. Strategies & Write Paths (strat)

**Impact:** HIGH  
**Description:** How data enters and exits the cache — cache-aside (lazy loading), read-through, write-through, refresh-ahead, tiered-promotion, async warm-up. The choice is dictated by mutation frequency, staleness tolerance, and the cost ratio between origin and cache, not by taste. Cache-aside is the default for read-heavy paths; write-through is mandatory when the user mutates state they immediately re-read; refresh-ahead is reserved for the top 1% of hot keys where TTL-expiry spikes would be visible.

## 5. TTL & Freshness (ttl)

**Impact:** HIGH  
**Description:** TTL is the freshness-vs-hit-rate dial — most teams set it once at "5 minutes" and never re-tune. Soft/hard TTL separates async refresh from sync miss, jittered TTL prevents synchronized expiry stampedes, event-driven invalidation closes the gap between mutation and cache update, Personalize-solution-version-pinned TTL invalidates on model retrain, and per-content-class volatility bounds (inventory: minutes, user prefs: days) come from product staleness tolerance, not engineering convenience.

## 6. Stampede Protection (stamp)

**Impact:** HIGH  
**Description:** Concurrent-miss protection. At >90% hit rate, the 10% miss in a thundering herd kills the origin — N machines simultaneously refresh the same hot key on TTL expiry. Single-flight (Go semantics) collapses concurrent misses into one origin call; XFetch (Vattani et al. VLDB 2015) probabilistically refreshes before expiry to spread load; stale-while-revalidate (RFC 5861) returns stale during refresh; circuit-breaker on origin error keeps stale rather than propagating failure. These are not optional once cached traffic dwarfs origin capacity.

## 7. Observability & Empirical Measurement (obs)

**Impact:** HIGH  
**Description:** The empirical backbone. Aggregate hit rate hides everything — measure hit rate **by key class** (search-anon, search-logged, recommender-popular, recommender-personalized). Measure latency histograms with-hit and with-miss separately to know the actual saving. Track cost-per-thousand-requests with cache vs without cache. Sample key cardinality daily to catch a normalization regression. Measure the stale-served ratio to know if TTLs are right. Replay yesterday's logs through a simulator before changing TTL or strategy. Without this category, every other rule is a guess.

## 8. Negative & Defensive Caching (neg)

**Impact:** MEDIUM-HIGH  
**Description:** Caching the absence of a result, and surviving downstream failures. Empty search results still consume OpenSearch cluster CPU — cache the "0 hits" with a short TTL. Personalize 429s should not propagate to users — serve last-known-good. High-cardinality miss storms (slug-not-found, hash-not-found) overwhelm Redis lookup before the origin — a Bloom filter in front rejects them. Poison-pill detection (checksums on cache entries) prevents one bad write from corrupting hours of traffic.

## 9. Tiered & Edge Caching (tier)

**Impact:** MEDIUM-HIGH  
**Description:** Composition of cache layers — L1 (in-process, Caffeine/Guava/Ristretto) for hot keys at sub-millisecond latency, L2 (ElastiCache Redis/Memcached) for cross-instance reuse, CDN (CloudFront/Fastly) for anonymous traffic, OpenSearch's own shard-request cache and segment-level filter cache. Each tier has different hit-rate characteristics, latency, eviction semantics, and consistency guarantees. The rules cover when to add a tier, where to invalidate, and how to size each.
