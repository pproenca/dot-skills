---
title: Use Prefix Sums For Repeated Range Sums
impact: HIGH
impactDescription: O(n) per range sum to O(1) after O(n) preprocessing
tags: ds, prefix-sum, range-query, cumulative
---

## Use Prefix Sums For Repeated Range Sums

If you sum a slice of an array more than once, build a prefix-sum array first. After O(n) preprocessing, every "sum from index l to r" query becomes a single subtraction: `prefix[r+1] - prefix[l]`. For q queries this is O(n + q) instead of O(n·q).

This generalizes to: 2D prefix sums (sub-rectangle queries), prefix XOR (range XOR), prefix counts (number of occurrences up to i), and difference arrays (range updates as a dual of range queries).

**Incorrect (recomputing the sum for every query — O(n·q)):**

```python
def range_sums(arr: list[int], queries: list[tuple[int, int]]) -> list[int]:
    # Each query scans O(n) elements. q queries → O(n·q).
    return [sum(arr[l:r+1]) for l, r in queries]
```

**Correct (prefix sums — O(n + q)):**

```python
from itertools import accumulate

def range_sums(arr: list[int], queries: list[tuple[int, int]]) -> list[int]:
    # prefix[i] = sum of arr[0..i-1]. sum(arr[l..r]) = prefix[r+1] - prefix[l].
    prefix = [0, *accumulate(arr)]  # O(n)
    return [prefix[r + 1] - prefix[l] for l, r in queries]  # O(1) per query
```

**Difference-array variant (for many range *updates* followed by point reads):**

```python
def apply_range_increments(n: int, updates):
    # Each update +x on [l, r] becomes diff[l] += x, diff[r+1] -= x. O(1) per update.
    diff = [0] * (n + 1)
    for l, r, x in updates:
        diff[l] += x
        diff[r + 1] -= x
    # Finalize with one prefix-sum pass.
    out = []
    running = 0
    for i in range(n):
        running += diff[i]
        out.append(running)
    return out
```

**When a Fenwick tree or segment tree beats prefix sums:**

If the array also changes between queries, prefix sums must be rebuilt O(n) per update. A Fenwick tree gives O(log n) for both update and prefix sum — better whenever updates are frequent.

Reference: [USACO Guide — Introduction to Prefix Sums](https://usaco.guide/silver/prefix-sums)
