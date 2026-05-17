---
title: Sort Once Outside the Loop, Not on Every Iteration
impact: HIGH
impactDescription: O(n²·log n) to O(n·log n + n) — orders of magnitude on hot paths
tags: search, sort, hoisting, loop-invariant, cache
---

## Sort Once Outside the Loop, Not on Every Iteration

Sorting is O(n log n) per call — already not free. Re-running the same sort on the same array inside a loop multiplies that by the loop length: O(n² log n) total for n iterations against an n-element array. This pattern appears in "find the median of this list" or "the k smallest" called per request, where the underlying list rarely changes. Sort once at module load (or whenever the data is updated), cache the sorted view, query it as needed.

**Incorrect (sort per iteration — O(n² log n)):**

```python
scores = [...]                          # 10,000 scores, mostly static

def report_top_5_for_request(request):
    sorted_scores = sorted(scores, reverse=True)   # O(n log n) each request
    return sorted_scores[:5]
# 100 requests/sec × 10,000 × log(10,000) ≈ 13M ops/sec just sorting
```

**Correct (sort once, maintain on update):**

```python
sorted_scores = sorted(scores, reverse=True)       # once

def report_top_5_for_request(request):
    return sorted_scores[:5]                       # O(1)

def add_score(new_score):
    bisect.insort(sorted_scores, new_score)        # O(log n) lookup + O(n) shift
```

**Alternative (when insertions dominate — heap):**

```python
import heapq
# For "always read top-k, frequent inserts" use a heap, not a sorted list
top_k = []
def add(score):
    if len(top_k) < 5:
        heapq.heappush(top_k, score)
    else:
        heapq.heappushpop(top_k, score)
```

**When NOT to use this pattern:**
- When the underlying list changes more often than it's queried — sorting on read is fine; lazy approaches are wasteful.
- When the comparator depends on per-request state (sort by relevance to this user) — you can't precompute; consider partial sort or top-k heap instead.

Reference: [Python `sorted` is Timsort, O(n log n) worst case](https://docs.python.org/3/howto/sorting.html)
