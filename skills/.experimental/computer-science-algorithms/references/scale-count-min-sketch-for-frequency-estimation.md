---
title: Use Count-Min Sketch For Frequency Estimation On Massive Streams
impact: MEDIUM-HIGH
impactDescription: O(n) memory to O(log n) fixed — frequency estimates and heavy hitters in KBs
tags: scale, count-min-sketch, frequency, heavy-hitters
---

## Use Count-Min Sketch For Frequency Estimation On Massive Streams

"How many times did item x appear?" and "which items are the top-k most frequent?" don't need exact answers in most analytics — but `Counter` on a 10⁹-event stream over 10⁸ distinct keys eats tens of GBs. **Count-Min Sketch (CMS)** answers frequency queries in **fixed memory** (typically 10-100 KB), with strong probabilistic guarantees: the estimate is never less than the true count, and overshoots by at most ε·N with probability ≥ 1-δ (for chosen ε, δ).

CMS pairs naturally with a small heap to maintain top-k heavy hitters in O(1) amortized per event. It's how Twitter Heron tracks trending topics, how DDoS defense systems identify abusive IPs, how databases pick join orders.

**Incorrect (exact frequency on a 10⁹-event stream over 10⁸ keys — tens of GBs):**

```python
from collections import Counter

def top_k_frequent(events, k):
    # Counter grows with distinct keys: 10⁸ keys × ~50 bytes overhead = 5 GB+
    c = Counter(events)
    return c.most_common(k)
```

**Correct (Count-Min Sketch + size-k heap — fixed ~100 KB, ~1% error):**

```python
import math
import heapq
import mmh3

class CountMinSketch:
    def __init__(self, eps: float = 0.001, delta: float = 0.001):
        # Width controls overestimate (ε); depth controls failure probability (δ).
        # eps=0.001, delta=0.001 → ~2718 wide, 7 deep ≈ 76 KB (4-byte counters).
        self.w = math.ceil(math.e / eps)
        self.d = math.ceil(math.log(1 / delta))
        self.table = [[0] * self.w for _ in range(self.d)]

    def add(self, key, count: int = 1) -> None:
        for i in range(self.d):
            j = mmh3.hash(str(key), seed=i, signed=False) % self.w
            self.table[i][j] += count

    def estimate(self, key) -> int:
        # Conservative: take min across rows — overshoots are absorbed by other rows.
        return min(
            self.table[i][mmh3.hash(str(key), seed=i, signed=False) % self.w]
            for i in range(self.d)
        )

def top_k_frequent(events, k: int):
    # CMS for frequency; min-heap of size k for the running top.
    cms = CountMinSketch()
    heap: list[tuple[int, str]] = []
    seen_in_heap: set[str] = set()
    for e in events:
        cms.add(e)
        est = cms.estimate(e)
        if e in seen_in_heap:
            # Lazy update: push fresh entry; cleanup on pop.
            heapq.heappush(heap, (est, e))
        else:
            if len(heap) < k:
                heapq.heappush(heap, (est, e))
                seen_in_heap.add(e)
            elif est > heap[0][0]:
                _, removed = heapq.heapreplace(heap, (est, e))
                seen_in_heap.discard(removed)
                seen_in_heap.add(e)
    # Final pass: take fresh estimates for the heap members.
    return sorted({k_ for _, k_ in heap}, key=cms.estimate, reverse=True)[:k]
```

**Tuning:** for top-k heavy hitters where you only care about items appearing >5% of the stream, ε = 0.01, δ = 0.001 gives ~100 KB and is plenty accurate. Tighter bounds quadruple memory for diminishing accuracy gains.

**Alternative — Misra-Gries / Space-Saving:** deterministic top-k algorithms that use O(k) counters. Faster and bounded-error, but only return approximate top-k (not arbitrary frequency queries). Use Misra-Gries when k is small (≤ 1000) and you only need top-k; use CMS when you also need to query "how often did X appear?"

**When NOT to use:**

- You need exact counts (billing, fraud evidence, audit logs)
- The number of distinct keys is small enough for `Counter` (≤ ~10⁶)
- You need to enumerate which keys exist (CMS only estimates counts of *queried* keys)

**Production:** Apache DataSketches (LinkedIn), Twitter Heron streaming top-k, Google AdWords click counters, network DDoS mitigation, query-plan cost estimation in databases.

Reference: [Count-Min Sketch — Wikipedia](https://en.wikipedia.org/wiki/Count%E2%80%93min_sketch)
