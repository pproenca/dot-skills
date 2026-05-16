---
title: Use Quickselect (Or `nth_element`) For The K-th Element
impact: MEDIUM-HIGH
impactDescription: O(n log n) sort to O(n) average — 20x at n = 10⁶
tags: srch, quickselect, selection, k-th
---

## Use Quickselect (Or `nth_element`) For The K-th Element

If the answer is "the k-th smallest" or "the median," sorting the whole array is wasted work. Quickselect (Hoare's selection algorithm) finds the k-th element in O(n) average time by partitioning like quicksort but recursing into only one side. C++ ships `std::nth_element`; Python ships `statistics.median_low/median_high` and the `heapq.nlargest`/`nsmallest` heap-based selection. Sort only when you also need the rest of the order.

The Median-of-Medians algorithm gives O(n) worst case at the cost of a larger constant — rarely worth it in practice unless adversarial input is a real concern.

**Incorrect (full sort to get the median — O(n log n)):**

```python
def median(arr: list[int]) -> float:
    a = sorted(arr)  # O(n log n) — we only need the middle element
    n = len(a)
    return a[n // 2] if n % 2 else (a[n // 2 - 1] + a[n // 2]) / 2
```

**Correct (heap-based selection for top-k — O(n log k)):**

```python
import heapq

def kth_smallest(arr: list[int], k: int) -> int:
    # nsmallest is O(n log k). For k = n it falls back to full sort.
    return heapq.nsmallest(k, arr)[-1]
```

**Quickselect (when you need true O(n) average and write your own):**

```python
import random

def quickselect(a: list[int], k: int) -> int:
    # Returns the k-th smallest (0-indexed) in O(n) average time.
    a = a[:]  # don't mutate caller's data
    lo, hi = 0, len(a) - 1
    while lo < hi:
        pivot = a[random.randint(lo, hi)]  # random pivot avoids adversarial O(n²)
        i, j = lo, hi
        while i <= j:
            while a[i] < pivot: i += 1
            while a[j] > pivot: j -= 1
            if i <= j:
                a[i], a[j] = a[j], a[i]
                i += 1; j -= 1
        if k <= j:
            hi = j
        elif k >= i:
            lo = i
        else:
            return a[k]
    return a[lo]
```

**Random pivots matter:** a deterministic pivot choice (first / middle element) is O(n²) on adversarial input. Randomize once before partitioning.

Reference: [Wikipedia — Quickselect](https://en.wikipedia.org/wiki/Quickselect)
