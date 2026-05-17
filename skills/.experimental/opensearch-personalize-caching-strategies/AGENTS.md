# Caching Strategies for AWS OpenSearch and AWS Personalize

**Version 0.1.0**  
Marketplace-Research  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive caching reference for two-sided marketplaces running AWS OpenSearch (search) and AWS Personalize (recommenders fronted by a microservice). Contains 52 rules across 9 categories ordered by cascade effect in the request-time caching pipeline — from the upstream decision of whether to cache (cost calculus, Personalize TPS / minProvisionedTPS modelling, Zipf-distribution profiling, latency budget, multi-recommender amplification), through cache-key design (canonicalisation, cohort vs user, solution-version pinning, locale/currency, volatile-param stripping, bucketed ranges, stable hashing), personalisation boundary (anonymous/logged split, cold-start fallback, fan-out coalescing, shared-candidates private-ranking, session-vector write-through), strategies (cache-aside default, refresh-ahead for hot keys, write-through for mutations, batch precomputation, tiered L1+L2 promotion, async warm-up), TTL and freshness (volatility-driven TTL, soft/hard TTL, jitter, model-version pinning, event-driven invalidation, staleness-budget caps), stampede protection (single-flight, XFetch probabilistic early expiry, stale-while-revalidate, circuit breaker, distributed lock), observability and empirical measurement (hit-rate by key class, latency-with-and-without histograms, cost-per-1k attribution, key-cardinality drift, stale-served ratio, log-replay simulation), to the lower-cascade negative & defensive caching (empty results, Personalize-throttle fallback, Bloom-filter cache-penetration defense, poison-pill detection) and tier composition (in-process LRU, ElastiCache Redis sizing, CloudFront for anonymous, OpenSearch request cache, OpenSearch filter-context auto-cache). Each rule explains the underlying mechanism, shows incorrect-vs-correct code (TypeScript/Node for microservices, Python for batch/analytics, OpenSearch JSON for OS-specific queries, YAML for CDN/Kubernetes), and cites the canonical source — AWS Personalize/OpenSearch/ElastiCache documentation, the XFetch paper (Vattani, Chierichetti, Lowenstein VLDB 2015), RFC 5861 (stale-while-revalidate), and the engineering blogs of cache infrastructure teams (Netflix EVCache, Pinterest Cachelib, Twitter Twemcache, Cloudflare). Complements the opensearch-function-scoring-algorithms skill — that one covers what the ranking computes; this one covers how to cache it without overwhelming OpenSearch or Personalize.

---

## Table of Contents

1. [Decision & Cost Calculus](references/_sections.md#1-decision-&-cost-calculus) — **CRITICAL**
   - 1.1 [Account for Multi-Recommender Page Amplification](references/decide-amplification-multiplier.md) — CRITICAL (5-10x request-rate multiplier hidden by per-recommender metrics)
   - 1.2 [Cache Candidate Sets for Search, Full Payloads for Personalize](references/decide-search-vs-personalize-asymmetry.md) — CRITICAL (2-3x storage savings and faster invalidation by caching at the right grain)
   - 1.3 [Cache Only When Origin p99 Exceeds the Latency Budget](references/decide-latency-budget.md) — CRITICAL (prevents caches that add latency on hits)
   - 1.4 [Compute Cache ROI Before Adding the Cache](references/decide-cache-roi-calculation.md) — CRITICAL (prevents shipping caches that cost more than they save)
   - 1.5 [Model Personalize TPS Budget Before Choosing a Cache Strategy](references/decide-personalize-quota-budget.md) — CRITICAL (prevents minProvisionedTPS bills 3-5x above actual usage)
   - 1.6 [Profile Traffic Distribution Before Sizing the Cache](references/decide-hot-key-distribution.md) — CRITICAL (80/20 sizing without measurement wastes 50-200% of cache capacity)
   - 1.7 [Skip Caching When Traffic Distribution is Flat](references/decide-cardinality-floor.md) — CRITICAL (caching flat-distribution traffic produces <15% hit rate)
2. [Cache Key Design](references/_sections.md#2-cache-key-design) — **CRITICAL**
   - 2.1 [Bucket Continuous Filters Before Hashing](references/key-bucket-numerical-ranges.md) — CRITICAL (5-20x hit rate increase on price/distance/date filters)
   - 2.2 [Canonicalise Queries Before Hashing](references/key-canonicalize-query.md) — CRITICAL (3-10x hit rate increase by collapsing equivalent queries)
   - 2.3 [Include the Personalize Solution Version in the Cache Key](references/key-version-the-model.md) — CRITICAL (prevents serving stale recommendations for hours after retrain)
   - 2.4 [Key Recommenders by Cohort When Users Outnumber Cohorts](references/key-segment-not-user.md) — CRITICAL (50-500x hit rate increase by collapsing N users into K cohorts)
   - 2.5 [Make Locale, Currency, and Timezone Explicit in the Key](references/key-locale-currency-explicit.md) — CRITICAL (prevents silent cross-locale cache poisoning)
   - 2.6 [Strip Volatile and Tracking Params Before Hashing](references/key-strip-volatile-params.md) — CRITICAL (hit rate collapses to <5% with UTM/request-id leakage)
   - 2.7 [Use SHA-256 over MD5 for High-Cardinality Keys](references/key-stable-hash-algorithm.md) — CRITICAL (prevents silent key collisions on >100M keyspace)
3. [Personalisation Boundary](references/_sections.md#3-personalisation-boundary) — **HIGH**
   - 3.1 [Cache Retrieval Candidates Globally, Re-Rank Per-User From Cache](references/pers-shared-candidates-private-ranking.md) — HIGH (70-90% hit rate on the candidate set with per-user personalisation preserved)
   - 3.2 [Coalesce Multi-Recommender Fan-Out Into Batched Calls](references/pers-recommender-fan-out-coalescing.md) — HIGH (5-10x latency and TPS reduction on multi-recommender pages)
   - 3.3 [Maintain Session Vectors in Cache with Write-Through on Every Event](references/pers-session-vector-write-through.md) — HIGH (<1ms session-vector reads for real-time rerank)
   - 3.4 [Precompute Recommendations Per Cohort Offline](references/pers-cohort-precomputation.md) — HIGH (80-95% reduction in Personalize TPS, sub-millisecond serve time)
   - 3.5 [Route Anonymous Traffic to Global Cache, Logged-in to Cohort Cache](references/pers-anonymous-vs-logged-split.md) — HIGH (90%+ hit rate on anonymous traffic, 60-80% on logged-in)
   - 3.6 [Serve Cold-Start Users From Popularity Cache, Skip Personalize](references/pers-cold-start-cache-priority.md) — HIGH (cuts Personalize cost on cold users by 100%, faster latency)
4. [Strategies & Write Paths](references/_sections.md#4-strategies-&-write-paths) — **HIGH**
   - 4.1 [Async Warm-Up After Deploy, Restart, or Model Retrain](references/strat-async-warm-up.md) — HIGH (avoids 5-30 min of degraded latency after cold start)
   - 4.2 [Precompute the Popular Fraction with Batch Jobs](references/strat-precompute-batch.md) — HIGH (serves 40-60% of traffic from precomputed cache at near-zero per-request cost)
   - 4.3 [Promote to L1 In-Process Cache on L2 Hit](references/strat-tiered-promotion.md) — HIGH (95%+ of L1-eligible reads served in <100µs)
   - 4.4 [Use Cache-Aside as the Default Strategy for Read-Heavy Paths](references/strat-cache-aside-default.md) — HIGH (simplest correctness-preserving strategy, no coupling to writers)
   - 4.5 [Use Refresh-Ahead Only for the Top 1% of Hot Keys](references/strat-refresh-ahead-hot-keys.md) — HIGH (eliminates p99 spikes at TTL expiry on hot keys)
   - 4.6 [Use Write-Through When User Mutations Are Immediately Re-Read](references/strat-write-through-mutations.md) — HIGH (eliminates the "I saved it but I don't see it" UX bug)
5. [TTL & Freshness](references/_sections.md#5-ttl-&-freshness) — **HIGH**
   - 5.1 [Add Random Jitter to TTL to Prevent Synchronized Expiry](references/ttl-jitter-to-prevent-thundering.md) — HIGH (smooths origin-load spikes from cohort batch writes)
   - 5.2 [Bound TTL by Product Staleness Tolerance, Not the Default](references/ttl-bound-by-staleness-tolerance.md) — HIGH (prevents serving non-compliant data hours after the rule changed)
   - 5.3 [Pair TTL with Event-Driven Invalidation for Critical Freshness](references/ttl-event-driven-invalidation.md) — HIGH (closes the gap between mutation and cache update from TTL-bound to seconds)
   - 5.4 [Pin TTL to Personalize Solution Version, Not Wall Clock](references/ttl-personalize-solution-version.md) — HIGH (prevents serving previous-model output for hours after retrain)
   - 5.5 [Separate Soft TTL (Async Refresh) from Hard TTL (Sync Miss)](references/ttl-soft-and-hard.md) — HIGH (keeps p99 flat across TTL boundaries)
   - 5.6 [Set TTL From Content Volatility, Not Engineering Convenience](references/ttl-by-content-volatility.md) — HIGH (matches staleness to product tolerance, not a default)
6. [Stampede Protection](references/_sections.md#6-stampede-protection) — **HIGH**
   - 6.1 [Coalesce Concurrent Misses Into a Single Origin Call](references/stamp-coalesce-concurrent-misses.md) — HIGH (1 origin call per key per miss instead of N concurrent)
   - 6.2 [Serve Stale While Refresh Is In Flight](references/stamp-serve-stale-on-rebuild.md) — HIGH (keeps p99 flat under origin slowdown or failure)
   - 6.3 [Trip the Circuit Breaker on Origin Errors; Fall Back to Stale](references/stamp-circuit-breaker-on-origin-error.md) — HIGH (prevents cascade failure when OpenSearch or Personalize errors)
   - 6.4 [Use a Distributed Lock to Coordinate Cross-Instance Cache Rebuilds](references/stamp-distributed-lock-rebuild.md) — HIGH (prevents N-machine duplicate origin calls during a fleet-wide cold start)
   - 6.5 [Use XFetch Probabilistic Early Expiration for Hot Keys](references/stamp-probabilistic-early-expiration.md) — HIGH (smooths origin load by spreading refresh decisions across the TTL window)
7. [Observability & Empirical Measurement](references/_sections.md#7-observability-&-empirical-measurement) — **HIGH**
   - 7.1 [Attribute Cost Per Thousand Requests With and Without Cache](references/obs-cost-attribution.md) — HIGH (turns "cache helps" intuition into a finance-grade number)
   - 7.2 [Measure Latency Histograms With-Hit and With-Miss Separately](references/obs-latency-histograms-with-without.md) — HIGH (reveals the true latency saving and the miss-path tail)
   - 7.3 [Measure Stale-Served Ratio to Validate TTL Choice](references/obs-stale-served-ratio.md) — HIGH (makes TTL tuning empirical instead of guesswork)
   - 7.4 [Replay Production Logs Through a Cache Simulator Before Changing TTL or Strategy](references/obs-cache-simulation-from-logs.md) — HIGH (predicts hit rate and cost impact before shipping the change)
   - 7.5 [Sample Key Cardinality Daily; Alert on Explosion](references/obs-key-cardinality-tracking.md) — HIGH (catches canonicalisation regressions before they collapse hit rate)
   - 7.6 [Track Hit Rate by Key Class, Never Aggregate Only](references/obs-hit-rate-by-key-class.md) — HIGH (aggregate hit rate hides 5-50% per-class variance)
8. [Negative & Defensive Caching](references/_sections.md#8-negative-&-defensive-caching) — **MEDIUM-HIGH**
   - 8.1 [Cache Empty Search Results With a Short TTL](references/neg-cache-empty-results.md) — MEDIUM-HIGH (prevents repeated empty-query CPU on OpenSearch)
   - 8.2 [Checksum Cache Entries to Detect and Reject Poisoned Writes](references/neg-poison-pill-detection.md) — MEDIUM-HIGH (prevents one bad write from corrupting hours of traffic)
   - 8.3 [Serve Last-Known-Good When Personalize Throttles](references/neg-cache-throttled-personalize.md) — MEDIUM-HIGH (prevents user-visible failures during Personalize 429s)
   - 8.4 [Use a Bloom Filter to Block High-Cardinality Miss Storms](references/neg-bloom-filter-against-misses.md) — MEDIUM-HIGH (rejects invalid-id traffic before it reaches cache or origin)
9. [Tiered & Edge Caching](references/_sections.md#9-tiered-&-edge-caching) — **MEDIUM-HIGH**
   - 9.1 [Enable OpenSearch Request Cache for Aggregation-Heavy Queries](references/tier-opensearch-request-cache.md) — MEDIUM-HIGH (10-100x faster repeated aggregations at the shard level)
   - 9.2 [Put Reusable Predicates in Filter Context for Segment-Level Caching](references/tier-opensearch-filter-context.md) — MEDIUM-HIGH (5-50x speedup on repeated filters via auto-caching at segment level)
   - 9.3 [Size L2 ElastiCache to the Cross-Instance Working Set](references/tier-l2-elasticache-redis.md) — MEDIUM-HIGH (prevents L2 eviction churn while not over-provisioning)
   - 9.4 [Use CDN for Anonymous Traffic; Bypass for Cookies](references/tier-cdn-for-anonymous.md) — MEDIUM-HIGH (serves anonymous search/recs at edge with zero origin RTT)
   - 9.5 [Use In-Process LRU as L1 for Sub-Millisecond Reads](references/tier-l1-in-process.md) — MEDIUM-HIGH (1000x faster than Redis for hot keys; eliminates network RTT)

---

## References

1. [https://docs.aws.amazon.com/personalize/latest/dg/API_CreateCampaign.html](https://docs.aws.amazon.com/personalize/latest/dg/API_CreateCampaign.html)
2. [https://docs.aws.amazon.com/personalize/latest/dg/limits.html](https://docs.aws.amazon.com/personalize/latest/dg/limits.html)
3. [https://docs.aws.amazon.com/personalize/latest/dg/campaigns.html](https://docs.aws.amazon.com/personalize/latest/dg/campaigns.html)
4. [https://docs.aws.amazon.com/personalize/latest/dg/getting-recommendations.html](https://docs.aws.amazon.com/personalize/latest/dg/getting-recommendations.html)
5. [https://docs.aws.amazon.com/personalize/latest/dg/recommendations-batch.html](https://docs.aws.amazon.com/personalize/latest/dg/recommendations-batch.html)
6. [https://docs.aws.amazon.com/personalize/latest/dg/recording-item-interaction-events.html](https://docs.aws.amazon.com/personalize/latest/dg/recording-item-interaction-events.html)
7. [https://docs.aws.amazon.com/personalize/latest/dg/native-recipe-new-item-USER_PERSONALIZATION.html](https://docs.aws.amazon.com/personalize/latest/dg/native-recipe-new-item-USER_PERSONALIZATION.html)
8. [https://docs.aws.amazon.com/personalize/latest/dg/eventbridge.html](https://docs.aws.amazon.com/personalize/latest/dg/eventbridge.html)
9. [https://docs.aws.amazon.com/personalize/latest/dg/updating-campaign.html](https://docs.aws.amazon.com/personalize/latest/dg/updating-campaign.html)
10. [https://aws.amazon.com/personalize/pricing/](https://aws.amazon.com/personalize/pricing/)
11. [https://aws.amazon.com/blogs/machine-learning/create-a-batch-recommendation-pipeline-using-amazon-personalize-with-no-code/](https://aws.amazon.com/blogs/machine-learning/create-a-batch-recommendation-pipeline-using-amazon-personalize-with-no-code/)
12. [https://aws.amazon.com/blogs/machine-learning/amazon-personalize-can-now-create-up-to-50-better-recommendations-for-fast-changing-catalogs-of-new-products-and-fresh-content/](https://aws.amazon.com/blogs/machine-learning/amazon-personalize-can-now-create-up-to-50-better-recommendations-for-fast-changing-catalogs-of-new-products-and-fresh-content/)
13. [https://docs.opensearch.org/latest/search-plugins/caching/request-cache/](https://docs.opensearch.org/latest/search-plugins/caching/request-cache/)
14. [https://docs.opensearch.org/latest/search-plugins/caching/index/](https://docs.opensearch.org/latest/search-plugins/caching/index/)
15. [https://docs.opensearch.org/latest/query-dsl/query-filter-context/](https://docs.opensearch.org/latest/query-dsl/query-filter-context/)
16. [https://docs.opensearch.org/latest/query-dsl/term/range/](https://docs.opensearch.org/latest/query-dsl/term/range/)
17. [https://docs.opensearch.org/latest/search-plugins/search-pipelines/index/](https://docs.opensearch.org/latest/search-plugins/search-pipelines/index/)
18. [https://opensearch.org/blog/understanding-index-request-cache/](https://opensearch.org/blog/understanding-index-request-cache/)
19. [https://opster.com/guides/opensearch/opensearch-basics/cache-node-request-shard-data-field-data-cache/](https://opster.com/guides/opensearch/opensearch-basics/cache-node-request-shard-data-field-data-cache/)
20. [https://bigdataboutique.com/blog/properly-use-elasticsearch-query-cache-to-accelerate-search-performance-9566ad](https://bigdataboutique.com/blog/properly-use-elasticsearch-query-cache-to-accelerate-search-performance-9566ad)
21. [https://opensourceconnections.com/blog/2017/07/10/caching_in_elasticsearch/](https://opensourceconnections.com/blog/2017/07/10/caching_in_elasticsearch/)
22. [https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/Strategies.html](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/Strategies.html)
23. [https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/BestPractices.html](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/BestPractices.html)
24. [https://docs.aws.amazon.com/whitepapers/latest/database-caching-strategies-using-redis/caching-patterns.html](https://docs.aws.amazon.com/whitepapers/latest/database-caching-strategies-using-redis/caching-patterns.html)
25. [https://aws.amazon.com/elasticache/pricing/](https://aws.amazon.com/elasticache/pricing/)
26. [https://aws.amazon.com/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/](https://aws.amazon.com/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/)
27. [https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
28. [https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/](https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/)
29. [https://cseweb.ucsd.edu/~avattani/papers/cache_stampede.pdf](https://cseweb.ucsd.edu/~avattani/papers/cache_stampede.pdf)
30. [https://datatracker.ietf.org/doc/html/rfc5861](https://datatracker.ietf.org/doc/html/rfc5861)
31. [https://www.rfc-editor.org/rfc/rfc9111](https://www.rfc-editor.org/rfc/rfc9111)
32. [https://www.rfc-editor.org/rfc/rfc6234](https://www.rfc-editor.org/rfc/rfc6234)
33. [https://en.wikipedia.org/wiki/Cache_stampede](https://en.wikipedia.org/wiki/Cache_stampede)
34. [https://en.wikipedia.org/wiki/Bloom_filter](https://en.wikipedia.org/wiki/Bloom_filter)
35. [https://web.dev/articles/stale-while-revalidate](https://web.dev/articles/stale-while-revalidate)
36. [https://www.fastly.com/documentation/guides/concepts/edge-state/cache/stale/](https://www.fastly.com/documentation/guides/concepts/edge-state/cache/stale/)
37. [https://www.debugbear.com/docs/stale-while-revalidate](https://www.debugbear.com/docs/stale-while-revalidate)
38. [https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html](https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html)
39. [https://martinfowler.com/bliki/CircuitBreaker.html](https://martinfowler.com/bliki/CircuitBreaker.html)
40. [https://pkg.go.dev/golang.org/x/sync/singleflight](https://pkg.go.dev/golang.org/x/sync/singleflight)
41. [https://github.com/ben-manes/caffeine](https://github.com/ben-manes/caffeine)
42. [https://github.com/Netflix/EVCache](https://github.com/Netflix/EVCache)
43. [https://github.com/Netflix/rend](https://github.com/Netflix/rend)
44. [https://netflix.github.io/EVCache/features/](https://netflix.github.io/EVCache/features/)
45. [https://netflixtechblog.com/announcing-evcache-distributed-in-memory-datastore-for-cloud-c26a698c27f7](https://netflixtechblog.com/announcing-evcache-distributed-in-memory-datastore-for-cloud-c26a698c27f7)
46. [https://blog.bytebytego.com/p/how-netflix-warms-petabytes-of-cache](https://blog.bytebytego.com/p/how-netflix-warms-petabytes-of-cache)
47. [https://medium.com/pinterest-engineering/feature-caching-for-recommender-systems-w-cachelib-8fb7bacc2762](https://medium.com/pinterest-engineering/feature-caching-for-recommender-systems-w-cachelib-8fb7bacc2762)
48. [https://medium.com/pinterest-engineering/pinnersage-multi-modal-user-embedding-framework-for-recommendations-at-pinterest-bfd116b49475](https://medium.com/pinterest-engineering/pinnersage-multi-modal-user-embedding-framework-for-recommendations-at-pinterest-bfd116b49475)
49. [https://stackshare.io/pinterest/scaling-cache-infrastructure-at-pinterest](https://stackshare.io/pinterest/scaling-cache-infrastructure-at-pinterest)
50. [https://github.com/facebook/CacheLib](https://github.com/facebook/CacheLib)
51. [https://blog.x.com/engineering/en_us/a/2012/caching-with-twemcache](https://blog.x.com/engineering/en_us/a/2012/caching-with-twemcache)
52. [https://airbnb.tech/uncategorized/embedding-based-retrieval-for-airbnb-search/](https://airbnb.tech/uncategorized/embedding-based-retrieval-for-airbnb-search/)
53. [https://medium.com/airbnb-engineering/listing-embeddings-for-similar-listing-recommendations-and-real-time-personalization-in-search-601172f7603e](https://medium.com/airbnb-engineering/listing-embeddings-for-similar-listing-recommendations-and-real-time-personalization-in-search-601172f7603e)
54. [https://blog.cloudflare.com/when-bloom-filters-dont-bloom/](https://blog.cloudflare.com/when-bloom-filters-dont-bloom/)
55. [https://developers.cloudflare.com/cache/how-to/cache-keys/](https://developers.cloudflare.com/cache/how-to/cache-keys/)
56. [https://developers.cloudflare.com/cache/concepts/cache-behavior/](https://developers.cloudflare.com/cache/concepts/cache-behavior/)
57. [https://developers.cloudflare.com/cache/how-to/purge-cache/purge-by-tags/](https://developers.cloudflare.com/cache/how-to/purge-cache/purge-by-tags/)
58. [https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-the-cache-key.html](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-the-cache-key.html)
59. [https://www.fastly.com/documentation/guides/concepts/edge-state/purging/](https://www.fastly.com/documentation/guides/concepts/edge-state/purging/)
60. [https://cloud.google.com/cdn/docs/using-negative-caching](https://cloud.google.com/cdn/docs/using-negative-caching)
61. [https://pages.cs.wisc.edu/~cao/papers/zipf-implications.html](https://pages.cs.wisc.edu/~cao/papers/zipf-implications.html)
62. [https://www.usenix.org/system/files/conference/nsdi18/nsdi18-beckmann.pdf](https://www.usenix.org/system/files/conference/nsdi18/nsdi18-beckmann.pdf)
63. [https://stefanheule.com/papers/edbt2013-hyperloglog.pdf](https://stefanheule.com/papers/edbt2013-hyperloglog.pdf)
64. [https://redis.io/docs/latest/develop/data-types/probabilistic/hyperloglogs/](https://redis.io/docs/latest/develop/data-types/probabilistic/hyperloglogs/)
65. [https://redis.io/docs/latest/develop/use/patterns/distributed-locks/](https://redis.io/docs/latest/develop/use/patterns/distributed-locks/)
66. [https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/](https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/)
67. [https://redis.io/docs/latest/develop/reference/eviction/](https://redis.io/docs/latest/develop/reference/eviction/)
68. [https://www.designgurus.io/course-play/grokking-scalable-systems-for-interviews/doc/what-is-negative-caching-and-when-should-you-cache-404-or-empty-results](https://www.designgurus.io/course-play/grokking-scalable-systems-for-interviews/doc/what-is-negative-caching-and-when-should-you-cache-404-or-empty-results)
69. [https://prometheus.io/docs/practices/histograms/](https://prometheus.io/docs/practices/histograms/)
70. [https://www.unicode.org/reports/tr15/](https://www.unicode.org/reports/tr15/)
71. [https://www.iana.org/time-zones](https://www.iana.org/time-zones)
72. [https://gdpr-info.eu/art-17-gdpr/](https://gdpr-info.eu/art-17-gdpr/)
73. [https://github.com/graphql/dataloader](https://github.com/graphql/dataloader)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |