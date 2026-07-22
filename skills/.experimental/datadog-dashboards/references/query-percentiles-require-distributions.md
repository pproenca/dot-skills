---
title: Use distribution metrics for percentiles and never average one
tags: query, percentiles, distributions, latency
---

## Use distribution metrics for percentiles and never average one

`p95` reads like an aggregator that applies to any metric, alongside `avg` and `max`. It is not — it is a query prefix that resolves only against a **DISTRIBUTION** metric with percentile aggregations explicitly enabled, and that flag defaults to off (`include_percentiles`, *"Defaults to false"*). Without it, a distribution offers only `count, min, max, sum, avg`. Reaching for `p95:` on a gauge simply has no valid form, so the fallback is to grab whatever percentile-shaped metric exists and average it — which is where the real damage happens.

The metric that invites this is a DogStatsD HISTOGRAM, which the Agent aggregates locally and ships as a family of GAUGEs — `.avg`, `.max`, `.median`, `.95percentile`. A field named `.95percentile` reads like a p95 and is one, per host, per flush. Averaging those is an average of averages, and Datadog states the mechanism: *"If you have two reporting streams of aggregated data, it is not possible today to aggregate across the raw datapoints from both streams, only aggregate across the aggregates."* A host serving 10 requests a minute and a host serving 10,000 contribute equally, so the result is not the 95th percentile of anything. It moves plausibly, tracks real degradations loosely enough to look right, and cannot be reconciled with any SLO. Adding a tag makes it worse rather than better: splitting the stream into more bins means more per-bin aggregates to average across.

**Incorrect (unweighted mean of per-host p95s — not a percentile):**

```text
avg:checkout.request.duration.95percentile{env:prod}
```

**Correct (sketches merged across hosts, so this is the true global p95):**

```text
p95:trace.http.request{env:prod,service:checkout}
```

Distributions avoid the problem because Datadog stores DDSketch structures server-side from raw values and merges the sketches, giving globally accurate percentiles across any scope. For APM this maps onto a naming distinction worth memorising: `trace.<SPAN_NAME>` **is** the latency distribution and supports percentiles, while the legacy `trace.<SPAN_NAME>.duration` is a GAUGE and does not. Datadog's own guidance is to use the distribution for both averages and percentiles.

Two consequences follow. Rollup aggregators are a no-op on percentile-queried distributions — `p99:latency.dist.rollup(avg, 60)` and `p99:latency.dist.rollup(60)` return the same value, because distributions merge in time and space simultaneously rather than time-then-space. And enabling percentiles **doubles** the billable custom metric count for that distribution, so it is a request to make deliberately rather than a default to switch on everywhere.

Nested queries can compute a `pXX` over a count, rate, or gauge, and this is a trap dressed as a solution: Datadog notes those are *"calculated using the results of an existing, aggregated"* metric, so it is a percentile across per-interval averages. For percentiles of raw observations there is no substitute for a distribution.

Reference: [Distributions](https://docs.datadoghq.com/metrics/distributions/) · [How to graph percentiles](https://docs.datadoghq.com/dashboards/guide/how-to-graph-percentiles-in-datadog/) · [Rollup for distributions with percentiles](https://docs.datadoghq.com/metrics/faq/rollup-for-distributions-with-percentiles/)
