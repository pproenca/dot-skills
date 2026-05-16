---
title: Use Counting Or Radix Sort For Bounded Integer Keys
impact: MEDIUM
impactDescription: O(n log n) to O(n + k) — 5-10x at large n with small key range
tags: srch, counting-sort, radix-sort, linear-sort
---

## Use Counting Or Radix Sort For Bounded Integer Keys

Comparison-based sorts have an Ω(n log n) lower bound — that's the floor for any algorithm that learns about the data only through `<`. But if the keys are integers in a known small range, you don't need comparisons: counting sort is O(n + k) where k is the key range; radix sort handles wider integer keys in O(d·(n + b)) where d is the number of digits and b is the base. Both beat O(n log n) when k or d·b is small relative to n log n.

This pays off in: histogramming, sorting bytes, integer-keyed bucket aggregations, and "sort 10⁸ values that all fit in [0, 10⁵]."

**Incorrect (comparison sort on bounded integers — O(n log n)):**

```python
def sort_ages(ages: list[int]) -> list[int]:
    # Ages are bounded in [0, 120]. Timsort still does O(n log n) comparisons.
    return sorted(ages)
```

**Correct (counting sort — O(n + k)):**

```python
def sort_ages(ages: list[int], max_age: int = 120) -> list[int]:
    # Count occurrences of each value, then emit. O(n + max_age).
    count = [0] * (max_age + 1)
    for a in ages:
        count[a] += 1
    out: list[int] = []
    for value, c in enumerate(count):
        out.extend([value] * c)
    return out
```

**Radix sort for 32-bit integers:**

```python
def radix_sort_u32(arr: list[int]) -> list[int]:
    # 4 passes of base-256 counting sort. O(4·(n + 256)) = O(n).
    for shift in (0, 8, 16, 24):
        buckets: list[list[int]] = [[] for _ in range(256)]
        for x in arr:
            buckets[(x >> shift) & 0xFF].append(x)
        arr = [x for b in buckets for x in b]
    return arr
```

**When NOT to use:**

- Key range k is comparable to or larger than n (e.g. sorting arbitrary 64-bit hashes — k = 2⁶⁴ dwarfs any n)
- Keys are floats or strings of arbitrary length (use comparison sort or specialized string radix)
- Memory for the count array is prohibitive (k = 10⁹ counts use 4 GB)

Reference: [CLRS Chapter 8 — Sorting in Linear Time](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
