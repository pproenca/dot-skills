---
title: Measure Latency Histograms With-Hit and With-Miss Separately
impact: HIGH
impactDescription: prevents misdiagnosis when hit p99 and miss p99 differ 5-50x
tags: obs, latency, histograms, p99, hit-vs-miss
---

## Measure Latency Histograms With-Hit and With-Miss Separately

A single latency histogram for "everything served by this service" averages hits and misses into one distribution. The p50 looks great (most requests are hits, so the median is fast); the p99 looks scary (the miss tail dominates). Neither number is actionable: you can't tell whether p99 is from origin slowness or from a poorly-sized cache. Split into two histograms — `latency{outcome="hit"}` and `latency{outcome="miss"}` — and you can read directly: "hits p99 = 3ms is healthy"; "misses p99 = 800ms is the origin's problem."

**Incorrect (single histogram for all outcomes):**

```typescript
async function search(q: string, ctx: Ctx) {
  const start = performance.now();
  const result = await searchImpl(q, ctx);
  metrics.histogram('search.latency_ms', performance.now() - start);
  return result;
}

// Dashboard:
//   search.latency_ms p50 = 8ms        (mostly hits)
//   search.latency_ms p99 = 220ms      (mostly misses) — but you can't tell from this
//
// "Is p99 high because cache misses are taking 220ms or because cache hits sometimes do?"
// You can't answer from a single histogram.
```

**Correct (tag the histogram by outcome):**

```typescript
async function search(q: string, ctx: Ctx) {
  const start = performance.now();
  const { result, outcome } = await searchImpl(q, ctx);  // outcome: 'hit' | 'miss' | 'stale' | 'error'
  metrics.histogram('search.latency_ms', performance.now() - start, { outcome });
  return result;
}

// Dashboard:
//   search.latency_ms{outcome="hit"}   p50 = 4ms,  p99 = 12ms     (healthy)
//   search.latency_ms{outcome="miss"}  p50 = 80ms, p99 = 800ms    (origin)
//   search.latency_ms{outcome="stale"} p50 = 6ms,  p99 = 14ms     (healthy — stale serves)
//   search.latency_ms{outcome="error"} p50 = 50ms, p99 = 2s       (fallback)
//
// You can directly see:
//   - Hits are healthy
//   - Miss tail = origin tail. Investigate origin if too high.
//   - Stale serves are nearly as fast as hits (good)
//   - Errors fall back to fallback path (verify this is the fallback recommender)
```

**Why p99 of hits matters too.** A 12ms hit p99 means even hits have some slow path — possibly Redis under load, GC pauses, or serialization spikes on big payloads. If hit p99 starts climbing, investigate the cache infrastructure (Redis memory pressure, network) rather than the origin.

**Cumulative impact view:** to know the user's experience, weight by traffic. If hit rate is 90%, the user-visible p99 ≈ 0.9 × hit_p99 + 0.1 × miss_p99. Track this as `effective_latency_p99`. It moves with both cache health AND origin health, and is the right number for SLO dashboards.

**Stratify further by key class:** `latency{outcome="hit", keyClass="recommender-cohort"}`. Cohort recs may serve from a different Redis pool with different latency characteristics than search results. Aggregating across classes hides this.

**Synthetic monitoring:** in addition to real-traffic histograms, run a small synthetic probe per minute that exercises the cache miss path deliberately. This gives you "what would a fresh miss look like RIGHT NOW?" — useful when real traffic has 99% hit rate and the miss histogram is sparsely populated.

**For Personalize specifically:** track `personalize.latency_ms` separately from `cache.latency_ms`. The miss path's latency is dominated by Personalize, and Personalize has its own behaviour (auto-scale, throttle, retrain windows). You want to see when "miss latency rose" coincides with "Personalize TPS approaching minProvisionedTPS limit."

**Histogram bucketing:** use exponential buckets covering 0.5ms-10s. The default Prometheus histogram buckets are too coarse for cache hits; use buckets like `[0.5, 1, 2, 5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000]` ms.

Reference: [Prometheus best practices for histograms](https://prometheus.io/docs/practices/histograms/) · [Gil Tene — latency-histogram analysis (HdrHistogram)](http://hdrhistogram.org/)
