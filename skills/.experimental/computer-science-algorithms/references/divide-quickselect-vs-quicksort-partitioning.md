---
title: Partition Carefully — Pivot Choice Decides Worst Case
impact: MEDIUM
impactDescription: O(n²) to O(n log n) — random or median-of-3 pivots avoid pathological inputs
tags: divide, partitioning, pivot, randomization
---

## Partition Carefully — Pivot Choice Decides Worst Case

Quicksort and quickselect both rely on partitioning around a pivot. With a deterministic "first element" or "last element" pivot, sorted-or-nearly-sorted input degrades to O(n²) — and adversaries can craft inputs that exploit any fixed pivot rule. Two robust mitigations: (1) **randomize** the pivot — expected O(n log n) regardless of input; (2) **median-of-three** (pick the median of first, middle, last) — works well in practice and beats random for nearly-sorted data.

The deeper lesson generalizes beyond partitioning: any divide-and-conquer that splits work unevenly degrades the recursion. If T(n) = T(αn) + T((1-α)n) + O(n) with α very small (e.g. 0.01), the recursion is still O(n log n) (any α < 1 keeps it logarithmic in *depth*) — but with α = 0 it's O(n²).

**Incorrect (first-element pivot — O(n²) on sorted input):**

```python
def quicksort(a, lo=0, hi=None):
    if hi is None: hi = len(a) - 1
    if lo >= hi: return
    pivot = a[lo]                    # ← deterministic; sorted input is worst case
    i = lo + 1
    for j in range(lo + 1, hi + 1):
        if a[j] < pivot:
            a[i], a[j] = a[j], a[i]; i += 1
    a[lo], a[i - 1] = a[i - 1], a[lo]
    quicksort(a, lo, i - 2)
    quicksort(a, i, hi)
```

**Correct (random pivot — expected O(n log n)):**

```python
import random

def quicksort(a, lo=0, hi=None):
    if hi is None: hi = len(a) - 1
    if lo >= hi: return
    # Random pivot: expected O(n log n) regardless of input order.
    p = random.randint(lo, hi)
    a[lo], a[p] = a[p], a[lo]
    pivot = a[lo]
    i = lo + 1
    for j in range(lo + 1, hi + 1):
        if a[j] < pivot:
            a[i], a[j] = a[j], a[i]; i += 1
    a[lo], a[i - 1] = a[i - 1], a[lo]
    quicksort(a, lo, i - 2)
    quicksort(a, i, hi)
```

**Three-way partitioning (Dutch national flag)** for arrays with many duplicate keys:

```python
import random

def quicksort_3way(a, lo, hi):
    # Partitions into < pivot, == pivot, > pivot in one pass.
    # On heavily-duplicated data this beats 2-way partitioning by an order of magnitude.
    if lo >= hi: return
    pivot = a[lo + random.randint(0, hi - lo)]
    lt, i, gt = lo, lo, hi
    while i <= gt:
        if a[i] < pivot:
            a[lt], a[i] = a[i], a[lt]; lt += 1; i += 1
        elif a[i] > pivot:
            a[gt], a[i] = a[i], a[gt]; gt -= 1
        else:
            i += 1
    quicksort_3way(a, lo, lt - 1)
    quicksort_3way(a, gt + 1, hi)
```

**Real-world stdlibs use hybrids:** Introsort (C++) starts with quicksort, watches recursion depth, and falls back to heapsort if it exceeds 2·log₂(n) — guaranteed O(n log n) worst case.

Reference: [Sedgewick & Wayne — Quicksort](https://algs4.cs.princeton.edu/23quicksort/)
