---
title: Use Two Pointers On Sorted Data To Replace Nested Loops
impact: MEDIUM-HIGH
impactDescription: O(n²) to O(n log n) including sort, or O(n) if already sorted
tags: srch, two-pointers, sliding-window, sorted
---

## Use Two Pointers On Sorted Data To Replace Nested Loops

The two-pointer technique walks two indices through a sorted array (or two sorted arrays) to answer pair/range questions in O(n) instead of O(n²). Each pointer moves monotonically — never backwards — so the total work is bounded by the array length. It applies to: two-sum on sorted input, merging sorted lists, finding the closest pair, sliding-window problems, three-sum (one fixed + two pointers).

The mental model: "since the array is sorted, moving a pointer in one direction monotonically increases or decreases the quantity I'm looking at."

**Incorrect (nested loop for two-sum — O(n²)):**

```python
def two_sum_sorted(arr: list[int], target: int) -> tuple[int, int] | None:
    # O(n²) — but `arr` is already sorted; we're throwing that information away.
    n = len(arr)
    for i in range(n):
        for j in range(i + 1, n):
            if arr[i] + arr[j] == target:
                return (i, j)
    return None
```

**Correct (two pointers — O(n)):**

```python
def two_sum_sorted(arr: list[int], target: int) -> tuple[int, int] | None:
    # If arr[lo] + arr[hi] is too small, only increasing lo can help.
    # If too large, only decreasing hi can help. Each pointer moves at most n times.
    lo, hi = 0, len(arr) - 1
    while lo < hi:
        s = arr[lo] + arr[hi]
        if s == target:
            return (lo, hi)
        elif s < target:
            lo += 1
        else:
            hi -= 1
    return None
```

**Sliding-window variant** (the closest analog for un-sorted data):

```python
def longest_window_with_at_most_k_distinct(s: str, k: int) -> int:
    # Each character enters and leaves the window at most once → O(n).
    from collections import Counter
    count: Counter[str] = Counter()
    best = lo = 0
    for hi, c in enumerate(s):
        count[c] += 1
        while len(count) > k:
            count[s[lo]] -= 1
            if count[s[lo]] == 0:
                del count[s[lo]]
            lo += 1
        best = max(best, hi - lo + 1)
    return best
```

Reference: [Competitive Programmer's Handbook — Two-pointer technique](https://cses.fi/book/book.pdf)
