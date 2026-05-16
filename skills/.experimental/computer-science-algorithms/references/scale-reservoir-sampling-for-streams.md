---
title: Use Reservoir Sampling To Take A Uniform Sample From A Stream Of Unknown Length
impact: MEDIUM-HIGH
impactDescription: O(n) memory to O(k) — uniform k-sample without buffering n
tags: scale, reservoir-sampling, streaming, random-sample
---

## Use Reservoir Sampling To Take A Uniform Sample From A Stream Of Unknown Length

You're consuming a log file, Kafka topic, or unbounded HTTP stream and want a uniformly random sample of k items. The naive approach — collect everything, then `random.sample` — needs O(n) memory and assumes you know n in advance. **Reservoir sampling (Algorithm R, Vitter 1985)** maintains a uniformly-random size-k sample in O(k) memory using a single pass, **without ever knowing n**. The i-th element joins the reservoir with probability k/i; if it joins, it evicts a uniformly random current member.

This unlocks single-pass random selection from streams that don't fit in memory: sampled crash reports, weighted load tests, click-trail subsampling, A/B-test treatment assignment from an event stream.

**Incorrect (buffer everything to sample — O(n) memory and needs known n):**

```python
import random

def sample_k(events, k):
    # `list(events)` materializes the whole stream; fails or OOMs on real Kafka topics.
    # Also requires the stream to be finite and re-readable.
    return random.sample(list(events), k)
```

**Correct (Algorithm R — O(k) memory, single pass, no n needed):**

```python
import random

def reservoir_sample(stream, k: int) -> list:
    # Fill the reservoir with the first k items, then for each later item i (0-indexed):
    #   - pick a random j in [0, i]
    #   - if j < k, replace reservoir[j] with the new item.
    # Resulting reservoir is a uniform random subset of size k.
    reservoir: list = []
    for i, item in enumerate(stream):
        if i < k:
            reservoir.append(item)
        else:
            j = random.randint(0, i)
            if j < k:
                reservoir[j] = item
    return reservoir
```

**Algorithm L (Vitter 1985)** is asymptotically faster: instead of rolling a random per item, it rolls a geometric distribution to skip ahead to the next replacement. For very long streams with small k, this is much cheaper:

```python
import math, random

def algorithm_L(stream, k: int) -> list:
    # Algorithm L: O(k(1 + log(n/k))) expected work instead of O(n).
    reservoir: list = []
    it = iter(stream)
    for _ in range(k):
        reservoir.append(next(it))

    w = math.exp(math.log(random.random()) / k)
    i = k - 1
    while True:
        i += int(math.log(random.random()) / math.log(1 - w)) + 1
        # Advance the iterator to position i.
        try:
            item = None
            for _ in range(i - (i - 1)):  # consume up to position i
                item = next(it)
        except StopIteration:
            return reservoir
        reservoir[random.randint(0, k - 1)] = item
        w *= math.exp(math.log(random.random()) / k)
```

**Weighted reservoir sampling** (A-Res / A-ExpJ — Efraimidis & Spirakis): give each item weight wᵢ and sample with probability proportional to weight. Key trick: assign each item key `random() ** (1/wᵢ)` and keep the k items with the largest keys. Use this when sampled events should reflect "importance" (clicks weighted by revenue, errors weighted by severity).

**When NOT to use:**

- The full stream fits in memory and you can rerun it (use plain `random.sample`)
- You need a fixed-rate sample (e.g. "1% of events") — that's Bernoulli sampling, simpler: `if random() < 0.01: keep(item)`
- You need k items that satisfy a predicate — pre-filter, then reservoir sample the filtered stream

**Production:** sampled crash reports in Crashlytics, distributed-trace sampling at Honeycomb / Datadog, training-data subsampling in ML pipelines, observability log sampling at Uber.

Reference: [Reservoir sampling — Wikipedia](https://en.wikipedia.org/wiki/Reservoir_sampling)
