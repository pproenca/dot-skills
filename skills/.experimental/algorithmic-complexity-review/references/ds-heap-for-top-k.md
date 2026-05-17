---
title: Use a Heap for Top-K, Not Full Sort + Slice
impact: HIGH
impactDescription: O(n log n) to O(n log k) — 10-1000× speedup when k << n
tags: ds, heap, top-k, priority-queue, partial-sort
---

## Use a Heap for Top-K, Not Full Sort + Slice

"Find the top 10 scores from a million entries" doesn't need a full sort. A sort is O(n log n) and produces a fully ordered list you immediately throw 999,990 elements of. A bounded min-heap of size k visits each element once, pushing if it's larger than the current minimum — O(n log k) total, which is dramatically faster when k is small relative to n. The Python `heapq.nlargest`, JS `priority-queue` libraries, and Java `PriorityQueue` all implement this directly.

**Incorrect (sort everything then take k — O(n log n)):**

```python
top_10 = sorted(scores, reverse=True)[:10]
# 1,000,000 scores: full sort touches every element, O(n log n) ≈ 20M ops
```

**Correct (bounded heap — O(n log k)):**

```python
import heapq
top_10 = heapq.nlargest(10, scores)
# 1,000,000 scores: O(n log 10) ≈ 3.3M ops, plus much less memory churn
```

**Alternative (when items have a key function):**

```python
top_10_users = heapq.nlargest(10, users, key=lambda u: u.score)
```

**When NOT to use this pattern:**
- When k is close to n (e.g., top 90% of 100 items) — the heap saves nothing; a full sort is clearer.
- When you also need the remaining items in some order — you'll sort anyway; combine the two passes.

Reference: [Python `heapq.nlargest` — runs in O(n log k)](https://docs.python.org/3/library/heapq.html#heapq.nlargest)
