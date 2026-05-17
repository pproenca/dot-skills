---
title: Use Quickselect for the K-th Element, Not Full Sort
impact: MEDIUM
impactDescription: O(n log n) to O(n) average — useful when k is fixed and small
tags: search, quickselect, nth-element, selection, partial-sort
---

## Use Quickselect for the K-th Element, Not Full Sort

Finding the median, the 90th percentile, or the k-th smallest doesn't require a full sort. Quickselect (a.k.a. `std::nth_element`) finds the k-th element in O(n) average time by partitioning around a pivot and recursing only into the half that contains the target. The full result list isn't materialized, but the element at position k is correct and everything to its left is ≤ everything to its right. This is the right tool for percentile calculations, "median of medians" queries, and "find the closest k points" subproblems.

**Incorrect (full sort for one element — O(n log n)):**

```python
def percentile(values, p):
    sorted_vals = sorted(values)             # O(n log n)
    return sorted_vals[int(len(values) * p)]
# 10,000,000 values for one p95 query: O(n log n) ≈ 230M ops
```

**Correct (quickselect — O(n) average):**

```python
import heapq

def percentile(values, p):
    k = int(len(values) * p)
    return heapq.nsmallest(k + 1, values)[-1]
# heapq.nsmallest uses partial sort: O(n log k) — when k is small, ~linear
```

**Alternative (C++ `std::nth_element` — true O(n) average):**

```cpp
std::vector<int> values = ...;
auto kth = values.begin() + values.size() / 2;
std::nth_element(values.begin(), kth, values.end());   // O(n) avg
int median = *kth;
```

**Alternative (Numpy `partition` — vectorized quickselect):**

```python
import numpy as np
arr = np.asarray(values)
k = int(len(arr) * 0.95)
np.partition(arr, k)[k]    # O(n) average, vectorized
```

**When NOT to use this pattern:**
- When you also need the elements *before* k in sorted order — quickselect doesn't sort them; if you need both, sort once.
- When you need many percentiles at once (p50, p90, p99) on the same data — sort once and index O(1).

Reference: [Quickselect algorithm — Wikipedia](https://en.wikipedia.org/wiki/Quickselect)
