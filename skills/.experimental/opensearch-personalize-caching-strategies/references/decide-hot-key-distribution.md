---
title: Profile Traffic Distribution Before Sizing the Cache
impact: CRITICAL
impactDescription: 80/20 sizing without measurement wastes 50-200% of cache capacity
tags: decide, sizing, pareto, working-set, hot-keys
---

## Profile Traffic Distribution Before Sizing the Cache

Cache sizing has a closed-form answer given the traffic distribution: the cache hits the desired hit-rate when it holds the working set up to that percentile. For Zipf-like traffic with α=1, a cache holding the top 10% of keys delivers ~78% hit rate; doubling cache size to 20% adds ~9 percentage points. Without measuring α and the long-tail shape, teams either under-provision (constant eviction churn) or over-provision (paying for cache that holds keys never accessed twice). Both are visible in production only after the cache is in the request path.

**Incorrect (size by guess, then iterate in production):**

```bash
# "Let's start with 16GB Redis, that feels right."
# Six months later:
#   Working set is 80GB. Hit rate plateaued at 31%.
#   Or:
#   Working set is 2GB. We're paying for 16GB of unused capacity.
```

**Correct (profile, fit a curve, then size):**

```python
# scripts/profile_traffic.py — run against 7 days of cache-key access logs
import math
from collections import Counter

# Log line per request: {"timestamp": ..., "cache_key": "...", "bytes": ...}
key_counts = Counter()
key_bytes  = {}

for log_line in read_logs("s3://search-logs/cache-keys/7d/"):
    rec = json.loads(log_line)
    key_counts[rec["cache_key"]] += 1
    key_bytes[rec["cache_key"]] = rec["bytes"]

# Sort by frequency descending
ranked = sorted(key_counts.items(), key=lambda kv: -kv[1])

# Compute cumulative hit-rate curve as a function of cache size in bytes
total_requests = sum(key_counts.values())
cumulative_hits = 0
cumulative_bytes = 0

print("cache_size_gb,hit_rate")
for key, count in ranked:
    cumulative_hits  += count
    cumulative_bytes += key_bytes[key]
    if cumulative_bytes % (1024**3) < key_bytes[key]:  # crossed a GB boundary
        gb = cumulative_bytes / 1024**3
        hit_rate = cumulative_hits / total_requests
        print(f"{gb:.1f},{hit_rate:.3f}")

# Output (real workload, marketplace search):
# cache_size_gb,hit_rate
# 1.0,0.51
# 2.0,0.63
# 4.0,0.72       <- knee of the curve
# 8.0,0.79
# 16.0,0.84
# 32.0,0.87      <- diminishing returns, +3pp for 2x capacity
# 64.0,0.89
#
# Decision: provision 8-16 GB. Beyond that, marginal hit rate < marginal cost.
```

**Fit α to confirm:**

```python
# Zipf fit: log(frequency) = -α * log(rank) + c
import numpy as np
ranks = np.arange(1, len(ranked) + 1)
freqs = np.array([c for _, c in ranked])
log_ranks = np.log(ranks)
log_freqs = np.log(freqs)
alpha, _  = np.polyfit(log_ranks, log_freqs, 1)
alpha = -alpha
# Marketplace search queries: α ~ 1.0-1.2 (caching very effective)
# Recommender outputs per-user: α ~ 0.4-0.6 (caching less effective without cohorts)
# Catalog item-by-ID:           α ~ 0.7-1.1 (depends on traffic source mix)
```

**Recompute quarterly:** distribution shifts with seasonality, new features, and ad-driven traffic. A cache sized for last summer's distribution under-provisions during a holiday spike. Set a quarterly cron to re-run this analysis and flag if recommended size differs by >25% from current.

Reference: [Breslau et al. — Web Caching and Zipf-like Distributions (INFOCOM 1999)](https://pages.cs.wisc.edu/~cao/papers/zipf-implications.html) · [Beckmann et al. — LHD: Improving Cache Hit Rate by Maximizing Hit Density (NSDI 2018)](https://www.usenix.org/system/files/conference/nsdi18/nsdi18-beckmann.pdf)
