---
title: Use HyperLogLog For Cardinality Estimation On Massive Streams
impact: MEDIUM-HIGH
impactDescription: O(n) memory to ~12 KB fixed — count distinct over billions with ~0.81% standard error
tags: scale, hyperloglog, cardinality, sketch
---

## Use HyperLogLog For Cardinality Estimation On Massive Streams

"How many distinct users visited the site today?" with naive `len(set(user_ids))` needs memory proportional to the number of distinct users — gigabytes for a busy site. **HyperLogLog** answers the same question in **fixed ~12 KB of memory** with ~0.81% standard error, regardless of whether the answer is 10⁴ or 10¹⁰. The intuition: the number of leading zeros in a hash of each item is a noisy log-of-cardinality estimator; HLL takes the max over many independent buckets and harmonically averages.

HLL is **mergeable**: count distinct on shard A, count distinct on shard B, merge the two sketches in O(buckets) to get total distinct count without re-scanning the raw data. This makes it the canonical cardinality structure in distributed analytics (Presto, BigQuery `APPROX_COUNT_DISTINCT`, Redis `PFCOUNT`, Druid).

**Incorrect (exact count distinct on a 10⁹-row stream — many GB of memory):**

```python
def distinct_users(events):
    # Hash set holding 10⁹ 16-byte user IDs ≈ 64 GB+ with load factor and pointers.
    # Won't fit in RAM on a normal box; forces sharding or disk spills.
    return len({e.user_id for e in events})
```

**Correct (HyperLogLog — fixed ~12 KB, ~0.81% error):**

```python
# Production: use a battle-tested implementation — `datasketches`, `redis.pfadd`,
# `pyhll`, or the BigQuery / Presto built-ins. The version below is illustrative.

import math, mmh3

class HyperLogLog:
    def __init__(self, p: int = 14):
        # m = 2^p registers. p=14 → 16384 registers → ~16 KB → ~0.81% std error.
        self.p = p
        self.m = 1 << p
        self.registers = bytearray(self.m)
        # Bias-correction constant (Flajolet et al. 2007).
        self.alpha = 0.7213 / (1 + 1.079 / self.m) if self.m >= 128 else 0.673

    def add(self, key) -> None:
        h = mmh3.hash64(str(key), signed=False)[0]
        idx = h & (self.m - 1)           # first p bits → bucket index
        w = h >> self.p                  # remaining bits → leading-zero count
        leading = (w.bit_length() ^ 63) - (63 - (63 - self.p))  # simplified
        leading = max(1, 64 - self.p - w.bit_length() + 1)
        if leading > self.registers[idx]:
            self.registers[idx] = leading

    def count(self) -> int:
        # Harmonic mean of 2^register, scaled by alpha and m².
        z = sum(2.0 ** -r for r in self.registers)
        return int(self.alpha * self.m * self.m / z)

    def merge(self, other: "HyperLogLog") -> None:
        # Mergeable: take per-register max → same result as if both streams
        # had been added to one HLL.
        assert self.m == other.m
        for i in range(self.m):
            if other.registers[i] > self.registers[i]:
                self.registers[i] = other.registers[i]

def distinct_users(events):
    hll = HyperLogLog(p=14)
    for e in events:
        hll.add(e.user_id)
    return hll.count()
```

**Error vs memory tradeoff:** standard error = 1.04 / sqrt(m). p=10 → ~3.25% error in 1 KB. p=14 → ~0.81% in 16 KB. p=18 → ~0.20% in 256 KB. Going beyond p=18 rarely pays off.

**When NOT to use:**

- You need an exact count (audit, compliance, billing)
- Cardinality is small enough that a hash set fits (n < ~10⁵)
- You need to *enumerate* the distinct items, not just count them

**Production:** Redis `PFADD/PFCOUNT/PFMERGE` is HLL. Presto/Trino, Snowflake, BigQuery, Spark all expose HLL-backed `approx_count_distinct`. Druid stores HLLs as the primary aggregate for unique-counts at ingest time.

Reference: [HyperLogLog — Wikipedia](https://en.wikipedia.org/wiki/HyperLogLog)
