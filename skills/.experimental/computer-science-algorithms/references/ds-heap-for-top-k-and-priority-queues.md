---
title: Use A Heap For Top-K And Priority Queues, Not Sort-Then-Slice
impact: HIGH
impactDescription: O(n log n) to O(n log k) — huge when k << n
tags: ds, heap, priority-queue, top-k
---

## Use A Heap For Top-K And Priority Queues, Not Sort-Then-Slice

A binary heap supports `push` and `pop-min` in O(log n). When you only need the top-k items out of n, a size-k heap solves it in O(n log k) — strictly better than the O(n log n) full sort for any k < n. The trick: keep a min-heap of size k; each new element either replaces the smallest in the heap or is discarded. At the end, the heap holds the top-k.

Heaps also implement priority queues for graph algorithms (Dijkstra, Prim), event-driven simulation, and scheduling. The "is this thing the smallest/largest right now?" question is exactly what a heap answers.

**Incorrect (full sort to get top 10 from 10⁷ items — O(n log n)):**

```python
def top_k(scores: list[int], k: int) -> list[int]:
    # Sort all 10⁷ elements just to take the largest 10 — wastes O(n log n)
    # when we only need O(n log k) work.
    return sorted(scores, reverse=True)[:k]
```

**Correct (size-k min-heap — O(n log k)):**

```python
import heapq

def top_k(scores: list[int], k: int) -> list[int]:
    # heapq.nlargest uses a size-k heap internally. O(n log k) time, O(k) space.
    return heapq.nlargest(k, scores)
```

**Explicit heap example (priority queue for scheduling):**

```python
import heapq

def process_jobs_by_priority(jobs):
    # Min-heap; jobs with smaller priority numbers come out first.
    pq: list[tuple[int, str]] = []
    for j in jobs:
        heapq.heappush(pq, (j.priority, j.id))
    while pq:
        priority, job_id = heapq.heappop(pq)
        run(job_id)
```

**Use `heapq` (Python) idioms:**

- Min-heap by default — negate values to get a max-heap, or use `heapq.nlargest`.
- For ties on the primary key, push `(priority, counter, item)` to avoid comparing arbitrary objects.

Reference: [CLRS Chapter 6 — Heapsort](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
