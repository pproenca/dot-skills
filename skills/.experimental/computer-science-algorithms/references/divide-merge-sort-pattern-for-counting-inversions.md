---
title: Reuse The Merge-Sort Skeleton For Order-Pair Counting Problems
impact: MEDIUM-HIGH
impactDescription: O(n²) to O(n log n) — inversion counting, reverse pairs
tags: divide, merge-sort, inversions, order-statistics
---

## Reuse The Merge-Sort Skeleton For Order-Pair Counting Problems

Many "count pairs (i, j) with some relationship" problems — counting inversions, reverse pairs, smaller-numbers-after-self, range sum below k — are O(n²) by naive enumeration but O(n log n) when piggy-backed onto a merge sort. During the merge step you already know that the left half is sorted and the right half is sorted; that lets you count cross-pairs in O(n) per merge, totalling O(n log n).

The pattern: do a standard merge sort, but during the merge, when an element from the right half is smaller than the current left, every remaining left-half element forms a counted pair. Same code, one extra accumulator.

**Incorrect (count inversions in O(n²)):**

```python
def count_inversions(a: list[int]) -> int:
    # n² comparisons. For n = 10⁵ this is 10¹⁰ — many minutes.
    return sum(1 for i in range(len(a)) for j in range(i + 1, len(a)) if a[i] > a[j])
```

**Correct (count inversions via merge sort — O(n log n)):**

```python
def count_inversions(a: list[int]) -> int:
    # Sort a copy; accumulate inversions during merge.
    buf = list(a)

    def sort(lo: int, hi: int) -> int:
        if hi - lo <= 1:
            return 0
        mid = (lo + hi) // 2
        inv = sort(lo, mid) + sort(mid, hi)
        # Merge two sorted halves a[lo..mid] and a[mid..hi].
        left, right = buf[lo:mid], buf[mid:hi]
        i = j = 0
        for k in range(lo, hi):
            if i < len(left) and (j == len(right) or left[i] <= right[j]):
                buf[k] = left[i]; i += 1
            else:
                buf[k] = right[j]; j += 1
                # Every remaining `left` element is an inversion with right[j-1].
                inv += len(left) - i
        return inv

    return sort(0, len(a))
```

**Same skeleton works for:** counting "reverse pairs" (i < j with a[i] > 2·a[j]), counting "range-sum-in-[lo,hi]" using prefix sums + merge sort on prefix arrays, and external sort of huge files (merge sort is the only sort that's I/O-optimal).

Reference: [Sedgewick & Wayne — Mergesort](https://algs4.cs.princeton.edu/22mergesort/)
