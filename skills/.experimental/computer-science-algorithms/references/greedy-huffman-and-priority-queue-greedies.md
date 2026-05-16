---
title: Use A Priority Queue For "Always Pick The Smallest" Greedies
impact: LOW-MEDIUM
impactDescription: O(n²) repeated min-scans to O(n log n) — Huffman, scheduling, merge-k-lists
tags: greedy, huffman, priority-queue, merge
---

## Use A Priority Queue For "Always Pick The Smallest" Greedies

A common greedy pattern is "repeatedly pick the smallest (or largest) element from a changing collection." Naively re-scanning for the minimum is O(n) per step and O(n²) overall; a binary heap makes each pick O(log n) and the whole algorithm O(n log n). Canonical examples: **Huffman coding** (repeatedly merge the two smallest frequencies), **merge-k-sorted-lists** (smallest head from k lists at each step), **task scheduling with cooldowns**, **rope-merging** (minimize total merge cost).

The heap variant has identical correctness to the naive version — only the data structure changes — but the time complexity changes dramatically once n > ~10³.

**Incorrect (Huffman with linear min-scan — O(n²)):**

```python
def huffman_cost_slow(freqs: list[int]) -> int:
    freqs = list(freqs)
    cost = 0
    while len(freqs) > 1:
        # Find two smallest by scanning — O(n) per iteration, n iterations → O(n²).
        freqs.sort()
        a, b = freqs.pop(0), freqs.pop(0)
        cost += a + b
        freqs.append(a + b)
    return cost
```

**Correct (Huffman with a min-heap — O(n log n)):**

```python
import heapq

def huffman_cost(freqs: list[int]) -> int:
    # Each heap pop/push is O(log n). 2n-1 ops total.
    heap = list(freqs)
    heapq.heapify(heap)
    cost = 0
    while len(heap) > 1:
        a = heapq.heappop(heap)
        b = heapq.heappop(heap)
        cost += a + b
        heapq.heappush(heap, a + b)
    return cost
```

**Merge k sorted lists** (priority queue keyed on list heads):

```python
import heapq

def merge_k_sorted(lists: list[list[int]]) -> list[int]:
    # O(N log k) where N is the total element count and k is the number of lists.
    pq = []
    for i, lst in enumerate(lists):
        if lst:
            heapq.heappush(pq, (lst[0], i, 0))
    out = []
    while pq:
        val, i, j = heapq.heappop(pq)
        out.append(val)
        if j + 1 < len(lists[i]):
            heapq.heappush(pq, (lists[i][j + 1], i, j + 1))
    return out
```

**The "decrease-key" gotcha:** standard binary heaps don't support efficient decrease-key. Common pattern is **lazy deletion** — push the new (smaller) entry and skip stale entries on pop. This is the same trick used in Dijkstra's algorithm.

Reference: [CLRS Chapter 16 — Greedy Algorithms (Huffman)](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
