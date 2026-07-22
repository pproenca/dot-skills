---
title: Disable interpolation when a gap in a gauge means something
tags: query, interpolation, gauges, fill
---

## Disable interpolation when a gap in a gauge means something

A gap in a graph reads as "no data", and for aggregated gauges that reading is usually false. Datadog interpolates by default: *"The default interpolation for all metric types is linear and performed up to five minutes after real samples."* Up to five minutes of fabricated points are generated across each gap and included in the average or sum like real observations. The condition that switches it on is easy to meet without noticing — *"Interpolation occurs when more than one source corresponds to your graph query"* — so any query aggregating across hosts, pods, or containers qualifies.

The consequence depends on what the gap meant. A host that stopped reporting because it was terminated gets a straight line drawn from its last value to whatever comes next, so a fleet average stays flat through an outage that should have dented it. Conversely a metric that is genuinely absent between batch runs gets connected, turning a spiky workload into a plateau. When the absence is the signal, turn interpolation off.

```text
avg:kubernetes.memory.usage{env:prod,service:checkout} by {pod_name}.fill(null)
```

`.fill()` takes a method and an optional limit in seconds: `linear`, `last`, `zero`, or `null` to deactivate it. The limit defaults to **300** seconds and caps at 600, which is where the five-minute figure comes from. `.fill(zero)` and `default_zero()` differ from `.fill(null)` in intent — they assert that missing means zero, which is right for a counter that only emits when something happened and wrong for a gauge whose absence means the reporter died.

```text
default_zero(sum:checkout.payment.retries{env:prod})
```

`default_zero()` applies after time and space aggregation, and Datadog notes it *"only affects `GAUGE` type metrics"* in practice, because counts and rates queried with `.as_count()` or `.as_rate()` are already aligned as zero. It also has no effect when the evaluation window contains no points at all, so it cannot conjure a flat zero line for a metric that has stopped entirely — that still renders as a gap.

One neighbouring trap: `clamp_min()` and `clamp_max()` set `NaN` values to the threshold rather than leaving them absent, so clamping a sparse series silently fills its gaps with the boundary value. Datadog's own note is to *"use `default_zero()` beforehand to avoid this behavior."*

Reference: [Interpolation and the fill modifier](https://docs.datadoghq.com/metrics/guide/interpolation-the-fill-modifier-explained/) · [Interpolation functions](https://docs.datadoghq.com/dashboards/functions/interpolation/) · [Exclusion functions](https://docs.datadoghq.com/dashboards/functions/exclusion/)
