---
title: Attribute Cost Per Thousand Requests With and Without Cache
impact: HIGH
impactDescription: turns "cache helps" intuition into a finance-grade number
tags: obs, cost-attribution, finops, personalize-cost, redis-cost
---

## Attribute Cost Per Thousand Requests With and Without Cache

"The cache saves money" is intuitive but rarely measured. The actual question — "what is the cost per 1000 cache reads vs the cost per 1000 origin calls, and what's the net saving at our hit rate?" — has a number, and that number should be on a dashboard. When it is, decisions about cache infrastructure (cluster size, eviction policy, TTL tuning) become finance-grounded rather than vibe-driven. When it isn't, teams over-spend on cache to chase marginal hit-rate gains, or under-spend and pay 10× the origin cost.

**Incorrect (no cost attribution; sign-off via vibe):**

```text
"The cache is great. Hit rate is 85%."
"Should we add more Redis nodes?"
"Sure, latency is better when we do."

Six months later, the bill:
   ElastiCache:  $4,200 / month
   Personalize: $11,800 / month
   OpenSearch:   $8,400 / month
No one knows what the bill would be without the cache, or whether the cache
is sized right. The "cache is great" claim is unbacked.
```

**Correct (per-1k-requests cost panels per origin):**

```typescript
// Per-request emit: cache outcome + origin called or not
async function getRecs(key: string, userId: string) {
  const cached = await redis.get(key);
  if (cached) {
    metrics.increment('cache.requests', { outcome: 'hit', origin: 'personalize' });
    return JSON.parse(cached);
  }
  metrics.increment('cache.requests', { outcome: 'miss', origin: 'personalize' });
  const fresh = await personalize.getRecommendations({ userId });
  // ...
}

// Aggregation (e.g. Cost Allocation dashboard, refreshed hourly):
//
//   personalize_calls_per_1k_requests = miss_rate * 1000
//   personalize_cost_per_1k_requests  = personalize_calls_per_1k_requests * tier_unit_cost
//                                     = miss_rate * 1000 * $0.0000556   (tier 1, first 72M/mo)
//                                     = miss_rate * $0.0556
//
//   At hit_rate=85%: personalize_cost_per_1k = 0.15 * $0.0556 = $0.0083 per 1k requests
//   Without cache:   personalize_cost_per_1k = 1.00 * $0.0556 = $0.0556 per 1k requests
//   Saving:                                                    ~$0.047 per 1k requests
//
// At 100 req/s = 8.64M req/day = 8640 1k-units/day
//   Saving from cache:  ~$408/day ≈ $12.2k/month from Personalize variable cost
//   (Plus floor savings via decide-personalize-quota-budget right-sizing.)
//   At higher tiers ($0.0278, $0.0139) the per-1k saving shrinks proportionally;
//   recompute against your actual tier mix from AWS Cost Explorer.
```

**Where to source costs:**
- **Personalize:** per transaction price + minProvisionedTPS floor. AWS Cost Explorer with `service=Personalize` and tag the campaign.
- **OpenSearch:** instance-hour cost; harder to attribute per-query, but cache reduces CPU and lets you down-size. Track `opensearch_cluster_cost_per_month` alongside `opensearch_cpu_p95`.
- **ElastiCache:** node-hour cost. Constant whether the cache is full or empty.
- **CDN:** per-request + per-GB egress.

**Effective cost per request as a single SLO metric:**

```text
effective_cost_per_request = (cache_infra_cost + origin_cost * (1 - hit_rate)) / total_requests
```

Track this over time. Re-run the [decide-cache-roi-calculation](decide-cache-roi-calculation.md) worksheet every quarter and assert: "actuals match the model within ±30%." If they diverge, your hit rate, working set, or unit costs have shifted.

**Cost dashboards per cohort, per surface:** for marketplaces with very different surface dynamics (homepage vs PDP vs search), attribute the cost split per 1k *end-user requests* (not per 1k Personalize calls — those are already the post-cache figure). "Homepage recommenders cost 5× search at 100% miss rate, but with cohort caching collapse to ~0.5× search" is the most-actionable framing for capacity planning.

**Don't optimise for cost at the expense of latency.** A cheaper but slower cache that pushes p99 above SLO is a regression. Cost is one axis; latency, freshness, and reliability are others.

**Personalize-specific gotcha:** the `minProvisionedTPS` floor cost is NOT reduced by caching. Cache reduces above-floor TPS only. The floor cost = `min_tps × 86400 × tier_unit_cost` (e.g. min_tps=10 at $0.0000556/req ≈ $48/day) — that's fixed regardless of cache hit rate. Caching saves on the *delta* above floor. Right-size minProvisionedTPS down as cache hit rate stabilises ([decide-personalize-quota-budget](decide-personalize-quota-budget.md)).

Reference: [AWS Cost Explorer](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html) · [Personalize pricing](https://aws.amazon.com/personalize/pricing/) · [FinOps Foundation principles](https://www.finops.org/framework/principles/)
